CLASS z2ui5_cl_fw_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    DATA mt_attri TYPE z2ui5_if_fw_types=>ty_t_attri.
    DATA mo_app TYPE REF TO object.

    METHODS attri_get_by_data
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_fw_types=>ty_s_attri.

    METHODS json_client_stringify
      RETURNING
        VALUE(result) TYPE string.
    METHODS json_client_parse
      IMPORTING
        viewname TYPE string
        o_model  TYPE REF TO z2ui5_if_ajson.

    METHODS xml_db_stringify.

    METHODS xml_db_parse.

    METHODS attri_get_val_ref
      IMPORTING
        i_lr_bind     TYPE REF TO z2ui5_if_fw_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS attri_set_refs.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_model IMPLEMENTATION.

  METHOD attri_get_by_data.

    DATA(lr_data) = REF #( val ).

    IF mt_attri IS INITIAL.
      DATA(lo_dissolver) =  NEW z2ui5_cl_fw_hlp_dissolver(
        attri = REF #( mt_attri )
        app = mo_app ).
      lo_dissolver->main( ).
    ENDIF.

    DO 2 TIMES.

      LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
          WHERE check_ready = abap_true
          AND depth < 5.

        IF lr_bind->r_ref IS NOT BOUND.
          lr_bind->r_ref = attri_get_val_ref( lr_bind ).
        ENDIF.

        IF lr_data = lr_bind->r_ref.
          result = lr_bind.
          RETURN.
        ENDIF.
      ENDLOOP.

      DATA(lo_dissolver_2) =  NEW z2ui5_cl_fw_hlp_dissolver(
         attri = REF #( mt_attri )
         app = mo_app ).
      lo_dissolver_2->main( ).

      LOOP AT mt_attri REFERENCE INTO lr_bind
          WHERE check_ready = abap_true
          AND depth >= 5.

        IF lr_bind->r_ref IS NOT BOUND.
          lr_bind->r_ref = attri_get_val_ref( lr_bind ).
        ENDIF.

        IF lr_data = lr_bind->r_ref.
          result = lr_bind.
          RETURN.
        ENDIF.
      ENDLOOP.

    ENDDO.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class or switch to bind_local`.

  ENDMETHOD.


  METHOD attri_get_val_ref.

    FIELD-SYMBOLS <attri> TYPE any.
    DATA(lv_name) = `MO_APP->` && i_lr_bind->name.
    DATA lr_ref TYPE REF TO data.
    ASSIGN (lv_name) TO <attri>.
    ASSERT sy-subrc = 0.

    GET REFERENCE OF <attri> INTO result.
    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD json_client_parse.

    NEW z2ui5_cl_fw_hlp_json_mapper(
            )->model_client_to_server(
                view    = viewname
                t_attri = REF #( mt_attri )
                model   = o_model ).

  ENDMETHOD.


  METHOD json_client_stringify.

    result = NEW z2ui5_cl_fw_hlp_json_mapper(
            )->model_server_to_client( mt_attri ).

  ENDMETHOD.


  METHOD xml_db_parse.

  ENDMETHOD.

  METHOD xml_db_stringify.

  ENDMETHOD.

  METHOD attri_set_refs.

    LOOP AT mt_attri REFERENCE INTO DATA(lr_attri)
    WHERE bind_type IS NOT INITIAL
    AND r_ref IS NOT BOUND.
      lr_attri->r_ref = attri_get_val_ref( lr_attri ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
