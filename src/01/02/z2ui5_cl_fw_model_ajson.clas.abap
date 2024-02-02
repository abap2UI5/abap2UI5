CLASS z2ui5_cl_fw_model_ajson DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.

    CLASS-METHODS front_to_back
      IMPORTING
        app      TYPE REF TO object
        viewname TYPE string
        t_attri  TYPE  z2ui5_cl_fw_binding=>ty_t_attri
        ajson_in TYPE REF TO z2ui5_if_ajson ##NEEDED.

    CLASS-METHODS back_to_front
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE  z2ui5_cl_fw_binding=>ty_t_attri
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson ##NEEDED.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_model_ajson IMPLEMENTATION.


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

  METHOD back_to_front.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.


          "(1) set pretty mode
          CASE lr_attri->pretty_name.

            WHEN z2ui5_if_client=>cs_pretty_mode-none.
              DATA(ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

            WHEN z2ui5_if_client=>cs_pretty_mode-camel_case.
              ajson  = z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_camel_case( iv_first_json_upper = abap_false ) ).

            WHEN OTHERS.
              ASSERT `` = `ERROR_UNKNOWN_PRETTY_MODE`.
          ENDCASE.


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
              ajson->set( iv_ignore_empty = abap_false iv_path = `/` iv_val = lr_attri->ajson_local ).

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
          IF lr_attri->compress_custom IS NOT INITIAL.
            DATA li_filter TYPE REF TO z2ui5_if_ajson_filter.
            CREATE OBJECT li_filter TYPE (lr_attri->compress_custom).
            ajson =  ajson->filter( li_filter ).

          ELSEIF lr_attri->compress = z2ui5_if_client=>cs_compress_mode-full.
            "obsolete - is this still needed? use compress_custom instead
            ASSERT `` = `OBSOLET_COMPRESS_MODE_USE_CUSTOM_INSTEAD`.

          ELSEIF lr_attri->compress = z2ui5_if_client=>cs_compress_mode-standard.
            ajson =  ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).

          ELSE.
            ASSERT `` = `ERROR_UNKNOW_COMPRESS_MODE`.
          ENDIF.


          "(5) write into result
          "todo performance - write directly into result
          ajson_result->set( iv_path = `/` && lv_path iv_val = ajson ).
        ENDLOOP.

*        result = ajson_result->stringify( ).
        result = ajson_result. "->stringify( ).

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD front_to_back.


    DATA(ajson) = ajson_in->slice( `/EDIT` ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri)
        WHERE bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way
        AND  viewname  = viewname.

      TRY.

          DATA(lv_name_back) = `APP->` && lr_attri->name.
          FIELD-SYMBOLS <backend> TYPE any.
          ASSIGN (lv_name_back) TO <backend>.
          ASSERT sy-subrc = 0.

          DATA(ajson_val) = ajson->slice( `/` && lr_attri->name_front ).

          TRY.

              CASE lr_attri->pretty_name.

                WHEN z2ui5_if_client=>cs_pretty_mode-none.


                WHEN z2ui5_if_client=>cs_pretty_mode-camel_case.
                  ajson_val  = ajson_val->map( z2ui5_cl_ajson_mapping=>create_to_snake_case( ) ).

                WHEN OTHERS.
                  ASSERT `` = `ToDo -> UNKNOWN_PRETTY_MODE`.
              ENDCASE.

              ajson_val->to_abap(
                IMPORTING
                  ev_container     = <backend> ).

            CATCH cx_root.

          ENDTRY.

        CATCH cx_root INTO DATA(x).
          ASSERT x IS BOUND.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
