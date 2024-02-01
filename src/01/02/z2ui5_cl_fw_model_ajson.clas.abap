CLASS z2ui5_cl_fw_model_ajson DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS front_to_back
      IMPORTING
        app         TYPE REF TO object
        viewname    TYPE string
        t_attri     TYPE  z2ui5_cl_fw_binding=>ty_t_attri
        json_string TYPE string.

    CLASS-METHODS back_to_front
      IMPORTING
        app           TYPE REF TO object
        t_attri       TYPE  z2ui5_cl_fw_binding=>ty_t_attri
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_fw_model_ajson IMPLEMENTATION.

  METHOD front_to_back.

    DATA(ajson) = z2ui5_cl_ajson=>parse( json_string )->slice( `/EDIT` ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri)
        WHERE bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way
        AND  viewname  = viewname.

      DATA(lv_name_back) = `APP->` && lr_attri->name.
      ASSIGN (lv_name_back) TO FIELD-SYMBOL(<backend>).
      ASSERT sy-subrc = 0.

      DATA(ajson_val) = ajson->slice( `/` && lr_attri->name_front ).

      TRY.
          ajson_val->to_abap(
            IMPORTING
              ev_container     = <backend> ).

        CATCH cx_root INTO DATA(lx).

      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD back_to_front.

    DATA(ajson) = z2ui5_cl_ajson=>create_empty( ).

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

      IF lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_time.
        ajson->set( iv_path = `/` iv_val = z2ui5_cl_ajson=>parse( lr_attri->data_stringify ) ).
        CONTINUE.
      ENDIF.

      DATA(lv_name_back) = `APP->` && lr_attri->name.
      FIELD-SYMBOLS <attribute> TYPE any.
      ASSIGN (lv_name_back) TO <attribute>.
      ASSERT 1 = 0.

      CASE lr_attri->bind_type.
        WHEN z2ui5_cl_fw_binding=>cs_bind_type-one_way.
          ajson->set( iv_path = `/` iv_val = <attribute> ).
        WHEN OTHERS.
          ajson->set( iv_path = `/` && z2ui5_cl_fw_binding=>cv_model_edit_name iv_val = <attribute> ).
      ENDCASE.

    ENDLOOP.

    result = ajson->stringify( ).

  ENDMETHOD.

ENDCLASS.
