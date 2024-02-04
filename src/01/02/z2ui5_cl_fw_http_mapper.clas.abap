CLASS z2ui5_cl_fw_http_mapper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.

    METHODS request_json_to_abap
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_s_http_request_post.

    METHODS response_abap_to_json
      IMPORTING
        val           TYPE z2ui5_if_client=>ty_s_http_response_post
      RETURNING
        VALUE(result) TYPE string.

    METHODS model_front_to_back
      IMPORTING
        app      TYPE REF TO object
        viewname TYPE string
        t_attri  TYPE  z2ui5_cl_fw_binding=>ty_t_attri
        ajson_in TYPE REF TO z2ui5_if_ajson ##NEEDED.

    METHODS model_back_to_front
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE  z2ui5_cl_fw_binding=>ty_t_attri
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson ##NEEDED.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_HTTP_MAPPER IMPLEMENTATION.


  METHOD model_back_to_front.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.


          "(1) set pretty mode
          IF lr_attri->custom_mapper IS BOUND.
            DATA(ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lr_attri->custom_mapper ) ).
          ELSE.
            ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
          ENDIF.


          "(2) read attribute of end-user app
          IF lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way
          OR lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way.
            DATA(lv_name_back) = `APP->` && lr_attri->name.
            FIELD-SYMBOLS <attribute> TYPE any.
            ASSIGN (lv_name_back) TO <attribute>.
            ASSERT sy-subrc = 0.
          ENDIF.


          "(3) write into json
          CASE lr_attri->bind_type.

            WHEN z2ui5_cl_fw_binding=>cs_bind_type-one_time.
              DATA(lv_path) = lr_attri->name_front.
              ajson->set( iv_ignore_empty = abap_false iv_path = `/` iv_val = lr_attri->json_bind_local ).

            WHEN z2ui5_cl_fw_binding=>cs_bind_type-one_way.
              lv_path = lr_attri->name_front.
              ajson->set( iv_ignore_empty = abap_false iv_path = `/` iv_val =  <attribute> ).

            WHEN z2ui5_cl_fw_binding=>cs_bind_type-two_way.
              lv_path =  z2ui5_cl_fw_binding=>cv_model_edit_name && `/` && lr_attri->name_front.
              ajson->set( iv_ignore_empty = abap_false iv_path = `/` iv_val =  <attribute> ).

            WHEN OTHERS.
              ASSERT `` = `ERROR_UNKNOWN_BIND_MODE`.
          ENDCASE.


          "(4) set compress mode
          "todo performance - add and filter in a single loop
          IF lr_attri->custom_filter IS BOUND.
            ajson =  ajson->filter( lr_attri->custom_filter ).
          ELSE.
            ajson =  ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
          ENDIF.

          "(5) write into result
          "todo performance - write directly into result
          ajson_result->set( iv_path = `/` && lv_path iv_val = ajson ).
        ENDLOOP.

        result = ajson_result.

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.

  ENDMETHOD.


  METHOD model_front_to_back.

*    DATA(ajson) = ajson_in->slice( `/EDIT` ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri)
    WHERE bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way
    AND  viewname  = viewname.
      TRY.

          DATA(lv_name_back) = `APP->` && lr_attri->name.
          FIELD-SYMBOLS <backend> TYPE any.
          ASSIGN (lv_name_back) TO <backend>.
          ASSERT sy-subrc = 0.

          DATA(ajson_val) = ajson_in->slice( `/` && lr_attri->name_front ).

          IF lr_attri->custom_mapper_back IS BOUND.
            ajson_val = ajson_val->map( lr_attri->custom_mapper_back ).
          ENDIF.

          ajson_val->to_abap(
            IMPORTING
              ev_container = <backend> ).

        CATCH cx_root INTO DATA(x).
          ASSERT x IS BOUND.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD request_json_to_abap.
    TRY.
        DATA(lo_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( val ) ).


        result-model = lo_ajson->slice( `/EDIT` ).

        result-s_frontend-id = lo_ajson->get( `/ID` ).
        result-s_frontend-viewname = lo_ajson->get( `/VIEWNAME` ).
        result-s_frontend-app_start = to_upper( lo_ajson->get( `/APP_START` ) ).
        result-s_frontend-arguments = lo_ajson->slice( `/ARGUMENTS` ).

        lo_ajson = lo_ajson->slice( `/OLOCATION` ).
        lo_ajson->to_abap(
            EXPORTING
                iv_corresponding = abap_true
            IMPORTING
                ev_container     = result-s_frontend-s_config ).


        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        result-s_control-check_launchpad = xsdbool(
          result-s_frontend-s_config-search CS `scenario=LAUNCHPAD` ).

        IF result-s_frontend-arguments IS BOUND.

          DATA(lo_event) = result-s_frontend-arguments->clone( ).
          result-s_control-event = lo_event->get( `/1/EVENT` ).
          lo_event->delete( `/1` ).
          lo_event->to_abap(
            IMPORTING
              ev_container = result-s_control-t_event_arg
          ).
        ENDIF.


        IF result-s_frontend-id IS INITIAL.
          TRY.
              result-s_control-app_start = to_upper( z2ui5_cl_util_func=>c_trim( result-s_frontend-app_start ) ).
            CATCH cx_root.
          ENDTRY.

          IF result-s_control-app_start IS INITIAL.
            result-s_control-app_start = to_upper( z2ui5_cl_util_func=>url_param_get( val = `app_start`
                                                              url = result-s_frontend-s_config-search ) ).
          ENDIF.

        ENDIF.

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD response_abap_to_json.
    TRY.

        "todo performance - write all data directly into the target ajson
        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
          ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

*        ajson_result->set( iv_path = `/PARAMS` iv_val = ms_next-s_set ).
*        ajson_result->set( iv_path = `/ID` iv_val = ms_db-id ).
        ajson_result->set( iv_path = `/` iv_val = val-s_frontend ).
        ajson_result = ajson_result->filter( NEW z2ui5_cl_fw_http_mapper( ) ).

*        DATA(lo_ajson) = NEW z2ui5_cl_fw_http_mapper( )->model_back_to_front(
*              app     = ms_db-app
*              t_attri = ms_db-t_attri ).

        ajson_result->set( iv_path = `/OVIEWMODEL` iv_val = val-oviewmodel ).
        result = ajson_result->stringify( ).

*        z2ui5_cl_fw_db=>create( id = ms_db-id db = ms_db ).


      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.


    CASE iv_visit.

      WHEN  z2ui5_if_ajson_filter=>visit_type-value.

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

      WHEN  z2ui5_if_ajson_filter=>visit_type-close.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
