CLASS z2ui5_cl_core_model_srv DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        app   TYPE REF TO object.

    METHODS attri_refs_update.
    METHODS attri_before_save.
    METHODS attri_after_load.

    METHODS search_a_dissolve_attribute
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

  PROTECTED SECTION.

    METHODS dissolve.
    METHODS dissolve_main.
    METHODS dissolve_init.

    METHODS attri_get_val_ref
      IMPORTING
        iv_path       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS diss_struc
      IMPORTING
        ir_attri      TYPE REF TO z2ui5_if_core_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_t_attri.

    METHODS diss_dref
      IMPORTING
        ir_attri      TYPE REF TO z2ui5_if_core_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_t_attri.

    METHODS diss_oref
      IMPORTING ir_attri      TYPE REF TO z2ui5_if_core_types=>ty_s_attri
      RETURNING VALUE(result) TYPE z2ui5_if_core_types=>ty_t_attri.

    METHODS search_attribute
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

ENDCLASS.


CLASS z2ui5_cl_core_model_srv IMPLEMENTATION.

  METHOD attri_after_load.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE     data_rtti IS NOT INITIAL
         AND type_kind  = cl_abap_classdescr=>typekind_dref.

      lr_attri->r_ref = attri_get_val_ref( lr_attri->name ).
      ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val>).

      z2ui5_cl_util=>xml_srtti_parse(
        EXPORTING
            rtti_data = lr_attri->data_rtti
        IMPORTING
            e_data    = <val> ).

      CLEAR lr_attri->data_rtti.
    ENDLOOP.

    attri_refs_update( ).

  ENDMETHOD.

  METHOD attri_before_save.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).

      IF lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-one_time.
        DELETE mt_attri->*.
        CONTINUE.
      ENDIF.

      IF lr_attri->type_kind <> cl_abap_classdescr=>typekind_dref.
        CLEAR lr_attri->r_ref.
        CONTINUE.
      ENDIF.

      ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val_ref>).
      ASSIGN <val_ref>->* TO FIELD-SYMBOL(<val>).

      lr_attri->data_rtti = z2ui5_cl_util=>xml_srtti_stringify( <val> ).

      CLEAR <val>.
      CLEAR <val_ref>.
      CLEAR lr_attri->r_ref.

    ENDLOOP.

  ENDMETHOD.

  METHOD search_a_dissolve_attribute.

    result = search_attribute( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    DO 5 TIMES.
      dissolve( ).
      result = search_attribute( val ).
      IF result IS BOUND.
        RETURN.
      ENDIF.
    ENDDO.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class or switch to bind_local`.

  ENDMETHOD.

  METHOD attri_get_val_ref.

    FIELD-SYMBOLS <attri> TYPE any.

    ASSIGN mo_app->(iv_path) TO <attri>.

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

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE bind_type <> z2ui5_if_core_types=>cs_bind_type-one_time.
      lr_attri->r_ref = attri_get_val_ref( lr_attri->name ).
    ENDLOOP.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD dissolve.

    IF mt_attri->* IS INITIAL.
      dissolve_init( ).
      RETURN.
    ENDIF.
    dissolve_main( ).

  ENDMETHOD.

  METHOD dissolve_init.

    DATA(ls_attri) = VALUE z2ui5_if_core_types=>ty_s_attri( r_ref = REF #( mo_app ) ).
    DATA(lt_init) = diss_oref( REF #( ls_attri ) ).
    INSERT LINES OF lt_init INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD dissolve_main.

    DATA(lt_attri_new) = VALUE z2ui5_if_core_types=>ty_t_attri( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      CASE lr_attri->type_kind.

        WHEN cl_abap_typedescr=>typekind_struct1
        OR cl_abap_typedescr=>typekind_struct2.
          DATA(lt_attri_struc) = diss_struc( lr_attri ).
          INSERT LINES OF lt_attri_struc INTO TABLE lt_attri_new.

        WHEN cl_abap_typedescr=>typekind_oref.
          DATA(lt_attri_oref) = diss_oref( lr_attri ).
          INSERT LINES OF lt_attri_oref INTO TABLE lt_attri_new.

        WHEN cl_abap_typedescr=>typekind_dref.
          DATA(lt_attri_dref) = diss_dref( lr_attri ).
          INSERT LINES OF lt_attri_dref INTO TABLE lt_attri_new.

        WHEN OTHERS.

      ENDCASE.

    ENDLOOP.
    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD diss_dref.

    FIELD-SYMBOLS <deref> TYPE any.

    ASSIGN ir_attri->r_ref->* TO <deref>.

    IF <deref> IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
    ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( <deref> ).
    ls_attri2-type_kind   = z2ui5_cl_util=>rtti_get_type_kind_by_descr( ls_attri2-o_typedescr ).

    CASE ls_attri2-o_typedescr->type_kind.

      WHEN cl_abap_datadescr=>typekind_struct1 OR
        cl_abap_datadescr=>typekind_struct2.

        DATA(lt_attri) = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.
        ls_attri2-name  = ir_attri->name && `->*`.
        ls_attri2-r_ref = attri_get_val_ref( ls_attri2-name ).
        INSERT ls_attri2 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.

  METHOD diss_oref.
    IF z2ui5_cl_util=>check_unassign_inital( ir_attri->r_ref ).
      RETURN.
    ENDIF.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_oref( z2ui5_cl_util=>unassign_object( ir_attri->r_ref ) ).

    LOOP AT lt_attri REFERENCE INTO DATA(lr_attri)
         WHERE     visibility   = cl_abap_objectdescr=>public
               AND is_interface = abap_false
               AND is_constant  = abap_false.
      TRY.

          DATA(lv_name) = COND #( WHEN ir_attri->name IS NOT INITIAL THEN ir_attri->name && `->` ).
          lv_name = lv_name && lr_attri->name.
          DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
          ls_attri2-name        = lv_name.
          ls_attri2-r_ref       = attri_get_val_ref( ls_attri2-name ).
          ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( ls_attri2-r_ref ).
          ls_attri2-type_kind   = z2ui5_cl_util=>rtti_get_type_kind_by_descr( ls_attri2-o_typedescr ).
          INSERT ls_attri2 INTO TABLE result.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD diss_struc.

    FIELD-SYMBOLS <any> TYPE any.

    CASE ir_attri->type_kind.
      WHEN cl_abap_typedescr=>typekind_struct1
      OR cl_abap_typedescr=>typekind_struct2.
        DATA(lv_name) = ir_attri->name && `-`.
        ASSIGN ir_attri->r_ref TO <any>.

      WHEN cl_abap_typedescr=>typekind_dref.
        lv_name = ir_attri->name && `->`.
        ASSIGN ir_attri->r_ref->* TO <any>.

    ENDCASE.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_struc( <any> ).

    LOOP AT lt_attri INTO DATA(ls_attri).

      DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
      ls_attri2-name        = lv_name && ls_attri-name.
      ls_attri2-r_ref       = attri_get_val_ref( lv_name && ls_attri-name ).
      ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( ls_attri2-r_ref ).
      ls_attri2-type_kind   = z2ui5_cl_util=>rtti_get_type_kind_by_descr( ls_attri2-o_typedescr ).
      INSERT ls_attri2 INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD search_attribute.

    LOOP AT mt_attri->* REFERENCE INTO result
         WHERE type_kind <> cl_abap_typedescr=>typekind_dref
           AND type_kind <> cl_abap_typedescr=>typekind_oref.

      IF result->r_ref = val.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

