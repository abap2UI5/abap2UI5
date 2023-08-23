CLASS z2ui5_cl_fw_binding DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF cs_bind_type.

    CONSTANTS cv_model_edit_name TYPE string VALUE `EDIT`.

    TYPES:
      BEGIN OF ty_s_attri,
        name            TYPE string,
        type_kind       TYPE string,
        type            TYPE string,
        bind_type       TYPE string,
        data_stringify  TYPE string,
        data_rtti       TYPE string,
        check_temp      TYPE abap_bool,
        check_tested    TYPE abap_bool,
        check_ready     TYPE abap_bool,
        check_dissolved TYPE abap_bool,
        name_front      TYPE string,
      END OF ty_s_attri.
    TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name.

    CLASS-METHODS factory
      IMPORTING
        app             TYPE REF TO object
        attri           TYPE ty_t_attri
        type            TYPE string
        data            TYPE data
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_fw_binding.

    METHODS main
      RETURNING
        VALUE(result) TYPE string.

    METHODS main2
      RETURNING
        VALUE(result) TYPE string.

    DATA mo_app   TYPE REF TO object.
    DATA mt_attri TYPE ty_t_attri.
    DATA mv_type  TYPE string.
    DATA mr_data TYPE REF TO data.

    CLASS-METHODS update_attri
      IMPORTING
        t_attri       TYPE ty_t_attri
        app           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE ty_t_attri.

  PROTECTED SECTION.

    METHODS get_t_attri_by_dref
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_attri.

    METHODS get_t_attri_by_struc
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_attri.

    METHODS get_t_attri_by_oref
      IMPORTING
        val           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_attri.

    METHODS get_t_attri_by_object
      IMPORTING
        app              TYPE REF TO object
      RETURNING
        VALUE(rt_attri2) TYPE ty_t_attri.

    METHODS bind
      IMPORTING
        bind          TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result) TYPE string.



    METHODS init_attri.

    METHODS dissolve_struc.

    METHODS dissolve_drefs.

    METHODS search_binding
      RETURNING
        VALUE(result) TYPE string.

    METHODS dissolve_orefs.

    METHODS set_attri_ready
      IMPORTING
        t_attri       TYPE REF TO ty_t_attri
      RETURNING
        VALUE(result) TYPE REF TO ty_s_attri.




  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_fw_binding IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->mo_app = app.
    r_result->mt_attri = attri.
    r_result->mv_type = type.
    r_result->mr_data = REF #( data ).

  ENDMETHOD.


  METHOD init_attri.

    IF mt_attri IS INITIAL.

      mt_attri  = get_t_attri_by_oref( ).
      set_attri_ready( REF #( mt_attri ) ).

    ELSE.
      LOOP AT mt_attri REFERENCE INTO DATA(lr_attri).
        lr_attri->check_tested = abap_false.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_t_attri_by_oref.

    FIELD-SYMBOLS <obj> TYPE any.
    UNASSIGN <obj>.

    DATA(lv_name) = `MO_APP`.
    IF val IS NOT INITIAL.
      lv_name = lv_name && `->` && val.
    ENDIF.
*    DATA(lv_name) = `MO_APP->` && to_upper( val ).
    ASSIGN (lv_name) TO <obj>.
*    ASSIGN (lv_name) TO <obj>.
    IF sy-subrc <> 0 OR <obj> IS NOT BOUND.
      RETURN.
    ENDIF.

*    DATA(lt_attri) = get_t_attri_by_object( <obj> ).

    DATA(lt_attri2) = z2ui5_cl_fw_utility=>rtti_get_t_attri_by_object( <obj> ).
    DELETE lt_attri2 WHERE visibility <> cl_abap_classdescr=>public OR is_interface = abap_true.
    DATA(lt_attri)  = CORRESPONDING ty_t_attri( lt_attri2 ).

    LOOP AT lt_attri INTO DATA(ls_attri).

*      ls_attri-name = val && `->` && ls_attri-name.
*      ls_attri-check_temp  = abap_true.

*      CASE ls_attri-type_kind.
*        WHEN cl_abap_classdescr=>typekind_iref OR cl_abap_classdescr=>typekind_intf.
*          CONTINUE.
*        WHEN cl_abap_classdescr=>typekind_oref
*          OR cl_abap_classdescr=>typekind_dref
*          OR cl_abap_classdescr=>typekind_struct2
*          OR cl_abap_classdescr=>typekind_struct1.
*        WHEN OTHERS.
*          ls_attri-check_ready = abap_true.
*      ENDCASE.

      INSERT ls_attri INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD main2.

    init_attri( ).

    "step 0 / MO_APP->MV_VAL
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 2 / MO_APP->MR_DATA->*
    dissolve_drefs( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_orefs( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_drefs( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE z2ui5_cx_fw_error
      EXPORTING
        val = `Binding Error - No attribute found`.

  ENDMETHOD.

  METHOD main.

    "step 0 / MO_APP->MV_VAL
    init_attri( ).

    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "step 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    "step 2 / MO_APP->MR_DATA->*
    dissolve_drefs( ).
    "step 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    "step 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_orefs( ).
    "step 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    "step 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_drefs( ).
    "step 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
    dissolve_struc( ).

    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE z2ui5_cx_fw_error
      EXPORTING
        val = `Binding Error - No attribute found`.

  ENDMETHOD.

  METHOD bind.

    FIELD-SYMBOLS <attri> TYPE any.
    DATA(lv_name) = `MO_APP->` && to_upper( bind->name ).
    ASSIGN (lv_name) TO <attri>.
    z2ui5_cl_fw_utility=>x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF <attri> INTO lr_ref.

    IF mr_data <> lr_ref.
      RETURN.
    ENDIF.

    IF bind->bind_type <> mv_type AND bind->bind_type IS NOT INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_fw_error
        EXPORTING
          val = `<p>Binding Error - Two different binding types for same attribute used (` && bind->name && `).`.
    ENDIF.

    bind->bind_type  = mv_type.
    bind->name_front = bind->name.
    bind->name_front = replace( val = bind->name sub = `*` with = `_` occ = 0 ).
    bind->name_front = replace( val = bind->name_front sub = `>` with = `_` occ = 0 ).
    bind->name_front = replace( val = bind->name_front sub = `-` with = `_` occ = 0 ).

    result = COND #( WHEN mv_type = cs_bind_type-two_way THEN `/` && cv_model_edit_name && `/` ELSE `/` ) && bind->name_front.
    IF strlen( result ) > 30.
      bind->name_front = z2ui5_cl_fw_utility=>func_get_uuid_22( ).
      result = COND #( WHEN mv_type = cs_bind_type-two_way THEN `/` && cv_model_edit_name && `/` ELSE `/` ) && bind->name_front.
    ENDIF.

  ENDMETHOD.

  METHOD get_t_attri_by_struc.

    DATA(lv_name) = `MO_APP->` && val.
*    DATA(lv_name) = to_upper( val ).
    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN (lv_name) TO <attribute>.
    z2ui5_cl_fw_utility=>x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA(lv_attri) = z2ui5_cl_fw_utility=>c_replace_assign_struc( val ).

    DATA(lt_comp) = z2ui5_cl_fw_utility=>rtti_get_t_comp_by_struc( <attribute> ).
    LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = lv_attri && lr_comp->name.

      IF lr_comp->as_include = abap_true
      OR lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct2
      OR lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct1.

        DATA(lt_attri) = get_t_attri_by_struc( lv_element ).
        INSERT LINES OF lt_attri INTO TABLE result.

      ELSE.

        DATA(ls_attri) = VALUE ty_s_attri(
            name      = lv_element
            type_kind = lr_comp->type->type_kind ).
        INSERT ls_attri INTO TABLE result.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD dissolve_struc.

    DATA(lt_dissolve) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO DATA(lr_attri)
        WHERE type_kind = cl_abap_classdescr=>typekind_struct1
        OR    type_kind = cl_abap_classdescr=>typekind_struct2
        AND   check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.
      DATA(lt_attri) = get_t_attri_by_struc( lr_attri->name ).
      INSERT LINES OF lt_attri INTO TABLE lt_dissolve.
    ENDLOOP.

    set_attri_ready( REF #( lt_dissolve ) ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD dissolve_drefs.

    DATA(lt_dissolve) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
        WHERE type_kind = cl_abap_classdescr=>typekind_dref
        AND   check_dissolved = abap_false.

      DATA(lt_attri) = get_t_attri_by_dref( lr_bind->name ).
      lr_bind->check_dissolved = abap_true.
      INSERT LINES OF lt_attri INTO TABLE lt_dissolve.
    ENDLOOP.

    set_attri_ready( REF #( lt_dissolve ) ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD search_binding.

    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
        WHERE ( bind_type = `` OR bind_type = mv_type )
        AND   check_ready = abap_true
        AND   check_tested = abap_false.

      lr_bind->check_tested = abap_true.
      result = bind( lr_bind ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_orefs.

    DATA(lt_dissolve) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
      WHERE type_kind = cl_abap_classdescr=>typekind_oref
      AND   check_dissolved = abap_false.

      lr_bind->check_dissolved = abap_true.
      DATA(lt_attri) = get_t_attri_by_oref( lr_bind->name ).
      INSERT LINES OF lt_attri INTO TABLE lt_dissolve.
    ENDLOOP.

    set_attri_ready( REF #( lt_dissolve ) ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD set_attri_ready.

    LOOP AT t_attri->*  REFERENCE INTO  result
      WHERE check_ready = abap_false.

      CASE result->type_kind.
        WHEN cl_abap_classdescr=>typekind_iref
          OR cl_abap_classdescr=>typekind_intf.
          DELETE t_attri->*.

        WHEN cl_abap_classdescr=>typekind_oref
          OR cl_abap_classdescr=>typekind_dref
          OR cl_abap_classdescr=>typekind_struct2
          OR cl_abap_classdescr=>typekind_struct1.

        WHEN OTHERS.
          result->check_ready = abap_true.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_t_attri_by_object.

*    DATA(lt_attri) = z2ui5_cl_fw_utility=>rtti_get_t_attri_by_object( app ).
*    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public OR is_interface = abap_true.
*    rt_attri2  = CORRESPONDING ty_t_attri( lt_attri ).

  ENDMETHOD.

  METHOD update_attri.

    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
    lo_bind->mo_app = app.
    lo_bind->mt_attri = t_attri.

    lo_bind->init_attri( ).

    lo_bind->dissolve_orefs( ).
    lo_bind->dissolve_orefs( ).
    lo_bind->dissolve_drefs( ).

    result = lo_bind->mt_attri.

  ENDMETHOD.


  METHOD get_t_attri_by_dref.

    DATA(lv_name) = `MO_APP->` && val && `->*`.
*    DATA(lv_name) = val && `->*`.
    FIELD-SYMBOLS <data> TYPE any.
    UNASSIGN <data>.
    ASSIGN (lv_name) TO <data>.
    IF <data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <data> ).

    DATA(ls_new_bind) = VALUE ty_s_attri(
       name = val && `->*`
       type_kind = lo_descr->type_kind
       type = lo_descr->get_relative_name(  )
       check_temp = abap_true
       check_ready = abap_true
     ).

    INSERT ls_new_bind INTO TABLE result.

  ENDMETHOD.


ENDCLASS.
