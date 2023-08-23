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

    METHODS get_t_attri_by_obj
      IMPORTING
        io_app           TYPE REF TO object
      RETURNING
        VALUE(rt_attri2) TYPE ty_t_attri.

    METHODS bind
      IMPORTING
        bind          TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result) TYPE string.

    METHODS init_attri.

    METHODS get_t_dissolve_oref
      IMPORTING
        is_attri_descr TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result)  TYPE ty_t_attri.

    METHODS dissolve_struc.

    METHODS dissolve_drefs.

    METHODS search_binding
      RETURNING
        VALUE(result) TYPE string.

    METHODS dissolve_orefs.

    METHODS set_attri_ready
      IMPORTING
        t_attri         TYPE REF TO ty_t_attri
      RETURNING
        VALUE(rr_attri) TYPE REF TO ty_s_attri.

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

      mt_attri  = get_t_attri_by_obj( mo_app ).
      set_attri_ready( REF #( mt_attri ) ).

    ELSE.
      LOOP AT mt_attri REFERENCE INTO DATA(lr_attri).
        lr_attri->check_tested = abap_false.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_t_dissolve_oref.

    FIELD-SYMBOLS <obj> TYPE any.
    UNASSIGN <obj>.
    DATA(lv_name) = `MO_APP->` && to_upper( is_attri_descr->name ).
    ASSIGN (lv_name) TO <obj>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    IF <obj> IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lt_attri) = get_t_attri_by_obj( <obj> ).

    LOOP AT lt_attri INTO DATA(ls_attri).

      ls_attri-name = is_attri_descr->name && `->` && ls_attri-name.
      ls_attri-check_temp  = abap_true.

      CASE ls_attri-type_kind.
        WHEN cl_abap_classdescr=>typekind_iref OR cl_abap_classdescr=>typekind_intf.
          CONTINUE.
        WHEN cl_abap_classdescr=>typekind_oref
          OR cl_abap_classdescr=>typekind_dref
          OR cl_abap_classdescr=>typekind_struct2
          OR cl_abap_classdescr=>typekind_struct1.
        WHEN OTHERS.
          ls_attri-check_ready = abap_true.
      ENDCASE.

      INSERT ls_attri INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD main2.

    init_attri( ).

    "level 0 / MO_APP->MV_VAL
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 2 / MO_APP->MR_DATA->*
    dissolve_drefs( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_orefs( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_drefs( ).
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
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

    init_attri( ).

    "level 0 / MO_APP->MV_VAL
    result = search_binding(  ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    "level 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    "level 2 / MO_APP->MR_DATA->*
    dissolve_drefs( ).
    "level 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    "level 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_orefs( ).
    "level 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    "level 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_drefs( ).
    "level 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
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
    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

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
      bind->name_front = z2ui5_cl_fw_utility=>get_uuid_22( ).
      result = COND #( WHEN mv_type = cs_bind_type-two_way THEN `/` && cv_model_edit_name && `/` ELSE `/` ) && bind->name_front.
    ENDIF.

  ENDMETHOD.


  METHOD dissolve_struc.

    DATA(lt_dissolve) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO DATA(lr_attri)
        WHERE ( type_kind = cl_abap_classdescr=>typekind_struct1
           OR type_kind = cl_abap_classdescr=>typekind_struct2 ) AND
           check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      DATA(lt_attri) = z2ui5_cl_fw_utility=>get_t_attri_by_struc( io_app = mo_app iv_attri = lr_attri->name ).
      LOOP AT lt_attri INTO DATA(ls_struc).
        DATA(ls_attri_struc) = VALUE ty_s_attri( ).
        ls_attri_struc = CORRESPONDING #( ls_struc ).
        ls_attri_struc-check_ready = abap_true.
        INSERT ls_attri_struc INTO TABLE lt_dissolve.
      ENDLOOP.

    ENDLOOP.

    set_attri_ready( REF #( lt_dissolve ) ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD dissolve_drefs.

    DATA(lt_dissolve) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind) WHERE
          type_kind = cl_abap_classdescr=>typekind_dref AND
          check_dissolved = abap_false.

      DATA(lv_name) = `MO_APP->` && lr_bind->name && `->*`.
      FIELD-SYMBOLS <data> TYPE any.
      UNASSIGN <data>.
      ASSIGN (lv_name) TO <data>.
      IF <data> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <data> ).

      DATA(ls_new_bind) = VALUE ty_s_attri(
         name = lr_bind->name && `->*`
         type_kind = lo_descr->type_kind
         type = lo_descr->get_relative_name(  )
         check_temp = abap_true
         check_ready = abap_true
       ).

      INSERT ls_new_bind INTO TABLE lt_dissolve.

      lr_bind->check_dissolved = abap_true.

    ENDLOOP.

    set_attri_ready( REF #( lt_dissolve ) ).
    INSERT LINES OF lt_dissolve INTO TABLE mt_attri.

  ENDMETHOD.


  METHOD search_binding.

    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
        WHERE ( bind_type = `` OR bind_type = mv_type ) AND check_ready = abap_true
            AND check_tested = abap_false.

      lr_bind->check_tested = abap_true.
      result = bind( lr_bind ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_orefs.

    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
      WHERE type_kind = cl_abap_classdescr=>typekind_oref AND
        check_dissolved = abap_false.

      DATA(lt_diss_oref) = get_t_dissolve_oref( is_attri_descr = lr_bind ).
      INSERT LINES OF lt_diss_oref INTO TABLE mt_attri.
      lr_bind->check_dissolved = abap_true.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_attri_ready.

    LOOP AT t_attri->*  REFERENCE INTO  rr_attri
      WHERE check_ready = abap_false.


      CASE rr_attri->type_kind.
        WHEN cl_abap_classdescr=>typekind_iref
          OR cl_abap_classdescr=>typekind_intf.
          DELETE t_attri->*.

        WHEN cl_abap_classdescr=>typekind_oref
           OR cl_abap_classdescr=>typekind_dref
           OR cl_abap_classdescr=>typekind_struct2
           OR cl_abap_classdescr=>typekind_struct1.

        WHEN OTHERS.
          rr_attri->check_ready = abap_true.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_t_attri_by_obj.

    DATA(lo_obj_ref) = cl_abap_objectdescr=>describe_by_object_ref( io_app ).
    DATA(lt_attri)  = CAST cl_abap_classdescr( lo_obj_ref )->attributes.
    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public OR is_interface = abap_true.
    rt_attri2  = CORRESPONDING ty_t_attri( lt_attri ).

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

ENDCLASS.
