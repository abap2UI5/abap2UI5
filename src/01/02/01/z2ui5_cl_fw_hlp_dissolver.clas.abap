CLASS z2ui5_cl_fw_hlp_dissolver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_fw_types=>ty_t_attri.
    DATA mo_app TYPE REF TO object.

    METHODS main.

    METHODS get_t_attri_by_dref
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_t_attri.

    METHODS get_t_attri_by_struc
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_t_attri.

    METHODS get_t_attri_by_include
      IMPORTING
        type          TYPE REF TO cl_abap_datadescr
        attri         TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_t_attri.

    METHODS get_t_attri_by_oref
      IMPORTING
        val           TYPE clike OPTIONAL
          PREFERRED PARAMETER val
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_t_attri.

    METHODS set_attri_ready.

    METHODS dissolve_struc.

    METHODS dissolve_dref.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_fw_types=>ty_t_attri
        app   TYPE REF TO object.
    METHODS dissolve_oref.

ENDCLASS.

CLASS z2ui5_cl_fw_hlp_dissolver IMPLEMENTATION.

  METHOD constructor.

    me->mt_attri = attri.
    me->mo_app = app.

  ENDMETHOD.


  METHOD set_attri_ready.

    LOOP AT mt_attri->* REFERENCE INTO DATA(result)
        WHERE check_ready = abap_false AND
            bind_type <> z2ui5_if_fw_types=>cs_bind_type-one_time.

      CASE result->type_kind.
        WHEN cl_abap_classdescr=>typekind_iref
            OR cl_abap_classdescr=>typekind_intf.
          DELETE mt_attri->*.

        WHEN cl_abap_classdescr=>typekind_oref
            OR cl_abap_classdescr=>typekind_dref
            OR cl_abap_classdescr=>typekind_struct2
            OR cl_abap_classdescr=>typekind_struct1.

        WHEN OTHERS.
          result->check_ready = abap_true.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_dref.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_bind)
        WHERE type_kind = cl_abap_classdescr=>typekind_dref
        AND check_dissolved = abap_false.

      DATA(lt_attri) = get_t_attri_by_dref( lr_bind->name ).
      IF lt_attri IS INITIAL.
        CONTINUE.
      ENDIF.
      lr_bind->check_dissolved = abap_true.
      INSERT LINES OF lt_attri INTO TABLE mt_attri->*.
    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_oref.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_bind)
        WHERE type_kind = cl_abap_classdescr=>typekind_oref
        AND check_dissolved = abap_false
        AND depth < 5.

      DATA(lt_attri) = get_t_attri_by_oref( lr_bind->name ).
      IF lt_attri IS INITIAL.
        CONTINUE.
      ENDIF.
      lr_bind->check_dissolved = abap_true.
      LOOP AT lt_attri REFERENCE INTO DATA(lr_attri).
        lr_attri->depth = lr_bind->depth + 1.
      ENDLOOP.
      INSERT LINES OF lt_attri INTO TABLE mt_attri->*.
    ENDLOOP.

  ENDMETHOD.


  METHOD dissolve_struc.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
        WHERE ( type_kind = cl_abap_classdescr=>typekind_struct1
        OR type_kind = cl_abap_classdescr=>typekind_struct2 )
        AND check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.
      lr_attri->check_ready     = abap_true.
      DATA(lt_attri) = get_t_attri_by_struc( lr_attri->name ).
      INSERT LINES OF lt_attri INTO TABLE mt_attri->*.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_t_attri_by_dref.

    DATA(lv_name) = `MO_APP->` && val && `->*`.
    FIELD-SYMBOLS <data> TYPE any.
    ASSIGN (lv_name) TO <data>.
    IF <data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <data> ).

    DATA(ls_new_bind) = VALUE z2ui5_if_fw_types=>ty_s_attri(
       name        = val && `->*`
       type_kind   = lo_descr->type_kind
       type        = lo_descr->get_relative_name( )
       check_ready = abap_true
       check_temp  = abap_true ).

    INSERT ls_new_bind INTO TABLE result.

  ENDMETHOD.


  METHOD get_t_attri_by_include.

    DATA(sdescr) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( type->absolute_name ) ).

    LOOP AT sdescr->components REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = attri && lr_comp->name.

      DATA(ls_attri) = VALUE z2ui5_if_fw_types=>ty_s_attri(
        name      = lv_element
        type_kind = lr_comp->type_kind ).
      INSERT ls_attri INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_t_attri_by_oref.

    DATA(lv_name) = COND #( WHEN val IS NOT INITIAL THEN `MO_APP` && `->` && val ELSE `MO_APP` ).
    FIELD-SYMBOLS <obj> TYPE any.
    ASSIGN (lv_name) TO <obj>.
    IF sy-subrc <> 0 OR <obj> IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lt_attri2) = z2ui5_cl_util_func=>rtti_get_t_attri_by_object( <obj> ).

    LOOP AT lt_attri2 INTO DATA(ls_attri2)
        WHERE visibility = cl_abap_classdescr=>public
           AND is_interface = abap_false.
      DATA(ls_attri) = CORRESPONDING z2ui5_if_fw_types=>ty_s_attri( ls_attri2 ).
      IF val IS NOT INITIAL.
        ls_attri-name = val && `->` && ls_attri-name.
        ls_attri-check_temp = abap_true.
      ENDIF.
      INSERT ls_attri INTO TABLE mt_attri->*.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_t_attri_by_struc.

    DATA(lv_name) = `MO_APP->` && val.
    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN (lv_name) TO <attribute>.
    ASSERT sy-subrc = 0.

    DATA(lt_comp) = z2ui5_cl_util_func=>rtti_get_t_comp_by_data( <attribute> ).

    DATA(lv_attri) = z2ui5_cl_util_func=>c_replace_assign_struc( val ).
    LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = lv_attri && lr_comp->name.

      IF lr_comp->as_include = abap_true
          OR lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct2
          OR lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct1.

        IF lr_comp->name IS INITIAL.
          DATA(lt_attri) = me->get_t_attri_by_include( type  = lr_comp->type
                                                       attri = lv_attri ).
        ELSE.
          lt_attri = get_t_attri_by_struc( lv_element ).
        ENDIF.
        INSERT LINES OF lt_attri INTO TABLE result.

      ELSE.

        DATA(lv_type_name) = substring_after( val = lr_comp->type->absolute_name sub = '\TYPE=').
        IF z2ui5_cl_util_func=>boolean_check_by_name( lv_type_name ).

          DATA(ls_attri) = VALUE z2ui5_if_fw_types=>ty_s_attri(
                name      = lv_element
                type      = 'ABAP_BOOL'
                type_kind = lr_comp->type->type_kind ).

        ELSE.

          ls_attri = VALUE z2ui5_if_fw_types=>ty_s_attri(
            name      = lv_element
            type_kind = lr_comp->type->type_kind ).

        ENDIF.
        INSERT ls_attri INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD main.

    "step 0 / MO_APP->MV_VAL
    IF mt_attri->* IS INITIAL.
      get_t_attri_by_oref( ).
    ENDIF.

    "step 1 / MO_APP->MS_STRUC-COMP
    dissolve_struc( ).
    "step 2 / MO_APP->MR_DATA->*
    dissolve_dref( ).
    "step 3 / MO_APP->MR_STRUC->COMP
    dissolve_struc( ).
    "step 4 / MO_APP->MO_OBJ->MV_VAL
    dissolve_oref( ).
    "step 5 / MO_APP->MO_OBJ->MR_STRUC-COMP
    dissolve_struc( ).
    "step 6 / MO_APP->MO_OBJ->MR_VAL->*
    dissolve_dref( ).
    "step 7 / MO_APP->MO_OBJ->MR_STRUC->COMP
    dissolve_struc( ).

    set_attri_ready( ).

  ENDMETHOD.

ENDCLASS.
