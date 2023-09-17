CLASS z2ui5_cl_fw_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS factory
      IMPORTING
        app             TYPE REF TO object
        attri           TYPE z2ui5_cl_fw_binding=>ty_t_attri
        viewname        TYPE string
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_fw_model.

    METHODS main_set_backend
      IMPORTING
        model TYPE REF TO data ##NEEDED.

    METHODS main_set_frontend
      RETURNING
        VALUE(result) TYPE string.

    DATA mo_app   TYPE REF TO object.
    DATA mt_attri TYPE z2ui5_cl_fw_binding=>ty_t_attri.
    DATA mv_viewname TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_model IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->mo_app = app.
    r_result->mt_attri = attri.
    r_result->mv_viewname = viewname.

  ENDMETHOD.

  METHOD main_set_backend.

    LOOP AT mt_attri REFERENCE INTO DATA(lr_attri)
        WHERE bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way AND
              viewname  = mv_viewname.
      TRY.

          DATA(lv_name_back) = `MO_APP->` && lr_attri->name.

          FIELD-SYMBOLS <backend> TYPE any.
          UNASSIGN <backend>.
          ASSIGN (lv_name_back) TO <backend>.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_cx_fw_error
              EXPORTING
                val = `NO_BACKEND_VALUE_FOUND_WITH_NAME__` && lv_name_back.
          ENDIF.

          DATA(lv_name_front) = `MODEL->` && lr_attri->name_front.
          FIELD-SYMBOLS <frontend> TYPE any.
          UNASSIGN <frontend>.
          ASSIGN (lv_name_front) TO <frontend>.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_cx_fw_error
              EXPORTING
                val = `NO_FRONTEND_VALUE_FOUND_WITH_NAME__` && lv_name_front.
          ENDIF.

          CASE lr_attri->type_kind.

            WHEN `h`.
              z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
                EXPORTING
                    ir_tab_from = <frontend>
                IMPORTING
                    t_result    = <backend> ).

            WHEN OTHERS.

              ASSIGN <frontend>->* TO <frontend>.
              CASE lr_attri->type_kind.
                WHEN 'D' OR 'T'.
                  z2ui5_cl_fw_utility=>trans_json_2_any(
                    EXPORTING
                        val = `"` && <frontend> && `"`
                    CHANGING
                        data = <backend> ).

                WHEN OTHERS.
                  <backend> = <frontend>.
              ENDCASE.

          ENDCASE.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD main_set_frontend.

    DATA(lr_view_model) = z2ui5_cl_fw_utility_json=>factory( ).
    DATA(lo_update) = lr_view_model->add_attribute_object( z2ui5_cl_fw_binding=>cv_model_edit_name ).

    LOOP AT mt_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

      IF lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_time.
        lr_view_model->add_attribute( n           = lr_attri->name
                                      v           = lr_attri->data_stringify
                                      apos_active = abap_false ).
        CONTINUE.
      ENDIF.

      DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way THEN lr_view_model
                                ELSE lo_update ).

      DATA(lv_name_back) = `MO_APP->` && lr_attri->name.
      FIELD-SYMBOLS <attribute> TYPE any.
      ASSIGN (lv_name_back) TO <attribute>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_fw_error
          EXPORTING
            val = `Error while creating the response, seems that some app data is not available anymore. <p>BINDING_ERROR - No attribute found with name: ` && lr_attri->name && `</p>`.
      ENDIF.

      CASE lr_attri->type_kind.

        WHEN `h`.
          lo_actual->add_attribute( n           = lr_attri->name_front
                                    v           = z2ui5_cl_fw_utility=>trans_json_any_2( any = <attribute>  pretty_name = /ui2/cl_json=>pretty_mode-low_case )
                                    apos_active = abap_false ).

        WHEN OTHERS.

          CASE lr_attri->type.

            WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.

              lo_actual->add_attribute( n           = lr_attri->name_front
                                        v           = SWITCH #( <attribute> WHEN abap_true THEN `true` ELSE `false` )
                                        apos_active = abap_false ).

            WHEN OTHERS.

              lo_actual->add_attribute( n           = lr_attri->name_front
                                        v           = z2ui5_cl_fw_utility=>trans_json_any_2( <attribute> )
                                        apos_active = abap_false ).
          ENDCASE.
      ENDCASE.

*      IF lr_attri->bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way.
*        INSERT VALUE #( n = lr_attri->name_front v = lr_attri->name ) INTO TABLE lt_binds.
*      ENDIF.
    ENDLOOP.

*    lo_update->add_attribute( n           = `OBINDS`
*                              v           = z2ui5_cl_fw_utility=>trans_json_any_2( lt_binds )
*                                apos_active = abap_false ).

    result = lr_view_model->stringify( ).

  ENDMETHOD.

ENDCLASS.
