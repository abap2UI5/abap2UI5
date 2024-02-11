CLASS z2ui5_cl_core_model_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app TYPE REF TO object.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        app   TYPE REF TO object.


    METHODS dissolve.
    METHODS attri_refs_update.
    METHODS attri_before_save.
    METHODS attri_after_load.

  PROTECTED SECTION.

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
      IMPORTING
        ir_attri      TYPE REF TO z2ui5_if_core_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_t_attri.

    METHODS dissolve_init.
    METHODS dissolve_main.

  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_core_model_srv IMPLEMENTATION.


  METHOD attri_after_load.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
        WHERE data_rtti IS NOT INITIAL
          AND type_kind = cl_abap_classdescr=>typekind_dref.

      lr_attri->r_ref = attri_get_val_ref( lr_attri->name ).

      ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val>).
      z2ui5_cl_util=>xml_srtti_parse(
        EXPORTING
          rtti_data = lr_attri->data_rtti
         IMPORTING
           e_data   = <val> ).

      CLEAR lr_attri->data_rtti.
    ENDLOOP.

    attri_refs_update( ).

  ENDMETHOD.


  METHOD attri_before_save.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).

      IF lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-one_time.
        DELETE mt_attri->*.
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


  METHOD attri_get_val_ref.

    FIELD-SYMBOLS <attri> TYPE any.
    ASSIGN mo_app->(iv_path) TO <attri>.
    IF sy-subrc <> 0.
      RETURN.
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

    me->mt_attri = attri.
    me->mo_app = app.

  ENDMETHOD.


  METHOD dissolve.

    IF mt_attri->* IS INITIAL.
      dissolve_init(  ).
      RETURN.
    ENDIF.

    dissolve_main( ).

  ENDMETHOD.


  METHOD dissolve_init.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_oref( mo_app ).
    LOOP AT lt_attri INTO DATA(ls_attri)
        WHERE visibility = cl_abap_objectdescr=>public.

      DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
      ls_attri2-name  = ls_attri-name.
      ls_attri2-r_ref = attri_get_val_ref( ls_attri-name ).
      ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( ls_attri2-r_ref ).
      ls_attri2-type_kind = z2ui5_cl_util=>rtti_get_type_kind_by_descr(  ls_attri2-o_typedescr ).
      INSERT ls_attri2 INTO TABLE mt_attri->*.

    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_main.

    DATA(lt_attri_new) = VALUE z2ui5_if_core_types=>ty_t_attri( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
        WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      CASE z2ui5_cl_util=>rtti_get_type_kind_by_descr( lr_attri->o_typedescr ).

        WHEN cl_abap_typedescr=>typekind_struct1
        OR cl_abap_typedescr=>typekind_struct2.
          lt_attri_new = diss_struc( lr_attri ).

        WHEN cl_abap_typedescr=>typekind_oref.
*         lt_attri_new = diss_oref( lr_attri ).

        WHEN cl_abap_typedescr=>typekind_dref.
          lt_attri_new = diss_dref( lr_attri ).

        WHEN OTHERS.

      ENDCASE.

    ENDLOOP.

    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.

  ENDMETHOD.


  METHOD diss_dref.

    FIELD-SYMBOLS <deref> TYPE any.
    ASSIGN ir_attri->r_ref->* TO <deref>.

    DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
    ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( <deref> ).
    ls_attri2-type_kind = z2ui5_cl_util=>rtti_get_type_kind_by_descr( ls_attri2-o_typedescr ).

    CASE ls_attri2-o_typedescr->type_kind.

      WHEN cl_abap_datadescr=>typekind_struct1 OR
        cl_abap_datadescr=>typekind_struct2.

        DATA(lt_attri) = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.
        ls_attri2-name = ir_attri->name && `->*`.
        ls_attri2-r_ref = attri_get_val_ref( ls_attri2-name ).

        INSERT ls_attri2 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.


  METHOD diss_oref.
    ASSERT 1 = 0.
  ENDMETHOD.


  METHOD diss_struc.

    DATA(lv_name) = ir_attri->name && SWITCH #( ir_attri->type_kind
        WHEN cl_abap_typedescr=>typekind_struct1
        OR cl_abap_typedescr=>typekind_struct2
            THEN `-`
        WHEN cl_abap_typedescr=>typekind_dref
            THEN `->` ).

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_struc( ir_attri->r_ref ).

    LOOP AT lt_attri INTO DATA(ls_attri).

      DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
      ls_attri2-name  = lv_name && ls_attri-name.
      ls_attri2-r_ref = attri_get_val_ref( lv_name && ls_attri-name ).
      ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( ls_attri2-r_ref ).
      ls_attri2-type_kind = z2ui5_cl_util=>rtti_get_type_kind_by_descr(  ls_attri2-o_typedescr ).
      INSERT ls_attri2 INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
