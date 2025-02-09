CLASS z2ui5_cl_core_srv_json DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ajson_filter.

    METHODS request_json_to_abap
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_request.

    METHODS response_abap_to_json
      IMPORTING
        val           TYPE z2ui5_if_core_types=>ty_s_response
      RETURNING
        VALUE(result) TYPE string.

    METHODS model_front_to_back
      IMPORTING
        view    TYPE string
        t_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        model   TYPE REF TO z2ui5_if_ajson.

    METHODS model_back_to_front
      IMPORTING
        t_attri       TYPE REF TO z2ui5_if_core_types=>ty_t_attri
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_srv_json IMPLEMENTATION.


  METHOD model_front_to_back.

    IF line_exists( t_attri->*[ view = view ] ).
      DATA(lv_view) = view.
    ELSE.
      lv_view = z2ui5_if_client=>cs_view-main.
    ENDIF.

    LOOP AT t_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE     bind_type = z2ui5_if_core_types=>cs_bind_type-two_way
               AND view      = lv_view.
      TRY.

          DATA(lo_val_front) = model->slice( lr_attri->name_client ).
          IF lo_val_front IS NOT BOUND.
            CONTINUE.
          ENDIF.

          IF lr_attri->custom_mapper_back IS BOUND.
            lo_val_front = lo_val_front->map( lr_attri->custom_mapper_back ).
          ENDIF.

          IF lr_attri->custom_filter_back IS BOUND.
            lo_val_front = lo_val_front->filter( lr_attri->custom_filter_back ).
          ENDIF.

          ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val>).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          lo_val_front->to_abap( IMPORTING ev_container = <val> ).

        CATCH cx_root INTO DATA(x).
          z2ui5_cl_util=>x_raise( |JSON_PARSING_ERROR: { x->get_text( ) } | ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD model_back_to_front.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        LOOP AT t_attri->* REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

          IF lr_attri->custom_mapper IS BOUND.
            DATA(ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                                   ii_custom_mapping = lr_attri->custom_mapper ) ).
          ELSE.
            ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                             ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
          ENDIF.

          CASE lr_attri->bind_type.
            WHEN z2ui5_if_core_types=>cs_bind_type-one_way
            OR z2ui5_if_core_types=>cs_bind_type-two_way.

              ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<attribute>).
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              ajson->set( iv_ignore_empty = abap_false
                          iv_path         = `/`
                          iv_val          = <attribute> ).

            WHEN z2ui5_if_core_types=>cs_bind_type-one_time.
              ajson->set( iv_ignore_empty = abap_false
                          iv_path         = `/`
                          iv_val          = lr_attri->json_bind_local ).

            WHEN OTHERS.
              ASSERT `` = `ERROR_UNKNOWN_BIND_MODE`.
          ENDCASE.

          IF lr_attri->custom_filter IS BOUND.
            ajson = ajson->filter( lr_attri->custom_filter ).
          ENDIF.

          ajson_result->set( iv_path = lr_attri->name_client
                             iv_val  = ajson ).
        ENDLOOP.

        result = ajson_result->stringify( ).
        result = COND #( WHEN result IS INITIAL THEN `{}` ELSE result ).

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD request_json_to_abap.
    TRY.

        DATA(lo_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( val ) ).

        DATA(lv_model_edit_name) = |/{ z2ui5_if_core_types=>cs_ui5-two_way_model }|.

        result-o_model = z2ui5_cl_ajson=>create_empty( ).
        DATA(lo_model) = lo_ajson->slice( lv_model_edit_name ).
        result-o_model->set( iv_path = lv_model_edit_name
                             iv_val  = lo_model ).
        lo_ajson->delete( lv_model_edit_name ).

        lo_ajson = lo_ajson->slice( `/S_FRONT` ).
        lo_ajson->to_abap( EXPORTING iv_corresponding = abap_true
                           IMPORTING ev_container     = result-s_front ).

        result-s_front-o_comp_data = lo_ajson->slice( `/CONFIG/ComponentData` ).

        result-s_control-check_launchpad = xsdbool(    result-s_front-search   CS `scenario=LAUNCHPAD`
                                                    OR result-s_front-pathname CS `/ui2/flp`
                                                    OR result-s_front-pathname CS `test/flpSandbox`
             ).
        IF result-s_front-id IS NOT INITIAL.
          RETURN.
        ENDIF.

        TRY.
            IF result-s_front-o_comp_data IS BOUND.
              DATA(lo_comp) = result-s_front-o_comp_data.
              DATA(lv_app_start) = lo_comp->get( `/startupParameters/app_start/1` ).
              result-s_control-app_start = lv_app_start.
              result-s_control-app_start = z2ui5_cl_util=>c_trim_upper( result-s_control-app_start ).
            ENDIF.
          CATCH cx_root.
        ENDTRY.

        TRY.
            DATA(lv_hash) = result-s_front-hash.
            SPLIT lv_hash AT '&/' INTO DATA(lv_dummy) lv_hash.
            IF lv_hash IS INITIAL.
              lv_hash = result-s_front-hash+2.
            ENDIF.
            result-s_control-app_start_draft = z2ui5_cl_util=>c_trim_upper(
                                           z2ui5_cl_util=>url_param_get( val = `z2ui5-xapp-state`
                                                                         url = lv_hash ) ).
          CATCH cx_root.
        ENDTRY.
        IF result-s_control-app_start IS NOT INITIAL.
          IF result-s_control-app_start(1) = `-`.
            REPLACE FIRST OCCURRENCE OF `-` IN result-s_control-app_start WITH `/`.
            REPLACE FIRST OCCURRENCE OF `-` IN result-s_control-app_start WITH `/`.
          ENDIF.
          RETURN.
        ENDIF.

        result-s_control-app_start = z2ui5_cl_util=>c_trim_upper(
                                         z2ui5_cl_util=>url_param_get( val = `app_start`
                                                                       url = result-s_front-search ) ).


      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.


  METHOD response_abap_to_json.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                                      ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

        ajson_result->set( iv_path = `/`
                           iv_val  = val-s_front ).
        ajson_result = ajson_result->filter( NEW z2ui5_cl_core_srv_json( ) ).
        DATA(lv_frontend) = ajson_result->stringify( ).

        result = |\{| &&
            |"S_FRONT":{ lv_frontend },| &&
            |"MODEL":{ val-model }| &&
          |\}|.

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            IF is_node-value = `false`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-number.
            IF is_node-value = `0`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-string.
            IF is_node-value = ``.
              rv_keep = abap_false.
            ENDIF.
        ENDCASE.

      WHEN z2ui5_if_ajson_filter=>visit_type-close.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
