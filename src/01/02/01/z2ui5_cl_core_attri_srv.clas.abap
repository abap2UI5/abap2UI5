CLASS z2ui5_cl_core_attri_srv DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        app   TYPE REF TO object.

    METHODS attri_refs_update.
    METHODS attri_before_save.
    METHODS attri_after_load.

    METHODS attri_get_val_ref
      IMPORTING
        iv_path       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS attri_search_a_dissolve
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

  PROTECTED SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS attri_search
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_attri_srv IMPLEMENTATION.

  METHOD attri_after_load.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).

      lr_attri->r_ref = attri_get_val_ref( lr_attri->name ).
      lr_attri->o_typedescr =  cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

      IF lr_attri->srtti_data IS NOT INITIAL.
        ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val>).
        <val> = z2ui5_cl_util=>xml_srtti_parse( lr_attri->srtti_data ).
        CLEAR lr_attri->srtti_data.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD attri_before_save.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).

      IF lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-one_time.
        DELETE mt_attri->*.
        CONTINUE.
      ENDIF.

      IF lr_attri->o_typedescr->type_kind <> cl_abap_classdescr=>typekind_dref.
        CLEAR lr_attri->r_ref.
        CONTINUE.
      ENDIF.

      ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val_ref>).
      ASSIGN <val_ref>->* TO FIELD-SYMBOL(<val>).

      lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val> ).

      CLEAR <val>.
      CLEAR <val_ref>.
      CLEAR lr_attri->r_ref.

    ENDLOOP.

  ENDMETHOD.

  METHOD attri_search_a_dissolve.

    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    DATA(lo_dissolve) = NEW z2ui5_cl_core_dissolve_srv(
       attri = mt_attri
       app   = mo_app ).

    DO 10 TIMES.

      lo_dissolve->main( ).

      result = attri_search( val ).
      IF result IS BOUND.
        RETURN.
      ENDIF.

      IF line_exists( mt_attri->*[ check_dissolved = abap_false ] ).
        CONTINUE.
      ENDIF.

      EXIT.
    ENDDO.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class or switch to bind_local`.

  ENDMETHOD.

  METHOD attri_get_val_ref.

    ASSIGN mo_app->(iv_path) TO FIELD-SYMBOL(<attri>).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `DEREF_FAILED_TARGET_INITIAL`.
    ENDIF.

    GET REFERENCE OF <attri> INTO result.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

  ENDMETHOD.

  METHOD attri_refs_update.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).

      lr_attri->r_ref = attri_get_val_ref( lr_attri->name ).
      lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

    ENDLOOP.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE o_typedescr IS BOUND.

      IF lr_attri->o_typedescr->kind <> cl_abap_typedescr=>kind_elem
         AND lr_attri->o_typedescr->kind <> cl_abap_typedescr=>kind_struct
         AND lr_attri->o_typedescr->kind <> cl_abap_typedescr=>kind_table.
        CONTINUE.
      ENDIF.

      IF lr_attri->r_ref = val.
        result = lr_attri.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


ENDCLASS.

