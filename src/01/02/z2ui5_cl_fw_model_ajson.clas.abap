CLASS z2ui5_cl_fw_model_ajson DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ajson_filter.
    CLASS-METHODS front_to_back
      IMPORTING
        app         TYPE REF TO object
        viewname    TYPE string
        t_attri     TYPE  z2ui5_cl_fw_binding=>ty_t_attri
        json_string TYPE string ##NEEDED.

    CLASS-METHODS back_to_front
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE  z2ui5_cl_fw_binding=>ty_t_attri
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_fw_model_ajson IMPLEMENTATION.

  METHOD front_to_back.
    TRY.
        DATA(ajson) = z2ui5_cl_ajson=>parse( json_string )->slice( `/EDIT` ).

        LOOP AT t_attri REFERENCE INTO DATA(lr_attri)
            WHERE bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way
            AND  viewname  = viewname.

          DATA(lv_name_back) = `APP->` && lr_attri->name.
          FIELD-SYMBOLS <backend> TYPE any.
          ASSIGN (lv_name_back) TO <backend>.
          ASSERT sy-subrc = 0.

          DATA(ajson_val) = ajson->slice( `/` && lr_attri->name_front ).

          TRY.

              CASE lr_attri->pretty_name.

                WHEN z2ui5_if_client=>cs_pretty_mode-none.
*                  ajson_val  = ajson_val->map( z2ui5_cl_ajson_mapping=>create_upper_case( ) ).

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
        ENDLOOP.

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD back_to_front.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

          CASE lr_attri->pretty_name.

            WHEN z2ui5_if_client=>cs_pretty_mode-none.
              DATA(ajson)  = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

            WHEN z2ui5_if_client=>cs_pretty_mode-camel_case.
              ajson  = z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_camel_case( iv_first_json_upper = abap_false ) ).

            WHEN OTHERS.
              ASSERT `` = `ToDo -> UNKNOWN_PRETTY_MODE`.
          ENDCASE.


          IF lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way
          OR lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way.
            DATA(lv_name_back) = `APP->` && lr_attri->name.
            FIELD-SYMBOLS <attribute> TYPE any.
            ASSIGN (lv_name_back) TO <attribute>.
            ASSERT sy-subrc = 0.
          ENDIF.


          CASE lr_attri->bind_type.

            WHEN z2ui5_cl_fw_binding=>cs_bind_type-one_time.
              DATA(lv_path) = `/`  && lr_attri->name_front.
              ajson->set( iv_ignore_empty = abap_false iv_path = `/` iv_val = lr_attri->ajson_local ).

            WHEN z2ui5_cl_fw_binding=>cs_bind_type-one_way.
              lv_path = `/` && lr_attri->name_front.
              ajson->set( iv_ignore_empty = abap_false iv_path = `/` iv_val =  <attribute> ).

            WHEN z2ui5_cl_fw_binding=>cs_bind_type-two_way.
              lv_path = `/` && z2ui5_cl_fw_binding=>cv_model_edit_name && `/` && lr_attri->name_front.
              ajson->set( iv_ignore_empty = abap_false iv_path =  `/` iv_val = <attribute> ).

            WHEN OTHERS.
              ASSERT `` = `ERROR_UNKNOWN_BIND_MODE`.
          ENDCASE.


          CASE lr_attri->compress.
            WHEN  z2ui5_if_client=>cs_compress_mode-full.
              ajson = ajson->filter( NEW z2ui5_cl_fw_model_ajson( ) ).
              ajson = ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).

            WHEN  z2ui5_if_client=>cs_compress_mode-standard.
              ajson = CAST #( ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ) ).

            WHEN z2ui5_if_client=>cs_compress_mode-none.
            WHEN OTHERS.
              ASSERT `` = `To-Do -> UNKNOW_COMPRESS_MODE`.
          ENDCASE.

          ajson_result->set( iv_path = lv_path iv_val = ajson ).
        ENDLOOP.


        result = ajson_result->stringify( ).

      CATCH cx_root INTO DATA(lx).
        ASSERT lx IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.

  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

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
    ENDCASE..

  ENDMETHOD.

ENDCLASS.
