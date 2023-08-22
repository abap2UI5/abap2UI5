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

    CONSTANTS cv_model_edit_name type string value `EDIT`.

    TYPES:
      BEGIN OF ty_s_attri,
        name            TYPE string,
        type_kind       TYPE string,
        type            TYPE string,
        bind_type       TYPE string,
        data_stringify  TYPE string,
        data_rtti       TYPE string,
        check_temp      TYPE abap_bool,
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

    METHODS main_bind
      RETURNING
        VALUE(result) TYPE string.

    DATA mo_app   TYPE REF TO object.
    DATA mt_attri TYPE ty_t_attri.

    DATA mv_type  TYPE string.
    DATA mr_data TYPE REF TO data.

  PROTECTED SECTION.

    METHODS bind
      IMPORTING
        bind          TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind_one_time
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_t_dissolve_data
      IMPORTING
        is_attri_descr TYPE abap_attrdescr
      RETURNING
        VALUE(result)  TYPE ty_t_attri.

    METHODS get_t_dissolve_dref
      IMPORTING
        is_attri_descr TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result)  TYPE ty_t_attri.

    METHODS get_t_dissolve_oref
      IMPORTING
        is_attri_descr TYPE REF TO ty_s_attri
      RETURNING
        VALUE(result)  TYPE ty_t_attri.


  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_binding IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.

    r_result->mo_app = app.
    r_result->mt_attri = attri.
    r_result->mv_type = type.
    r_result->mr_data = REF #( data ).

  ENDMETHOD.


  METHOD get_t_dissolve_oref.

    FIELD-SYMBOLS <obj> TYPE any.
    UNASSIGN <obj>.
    DATA(lv_name) = `MO_APP->` && to_upper( is_attri_descr->name ).
    ASSIGN (lv_name) TO <obj>.
    IF <obj> IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lt_attri) = z2ui5_cl_fw_utility=>get_t_attri_by_obj( <obj> ).

    LOOP AT lt_attri INTO DATA(ls_attri_descr).

      DATA(ls_attri) = VALUE ty_s_attri( ).
      CASE ls_attri_descr-type_kind.
        WHEN cl_abap_classdescr=>typekind_iref OR cl_abap_classdescr=>typekind_intf.
          CONTINUE.

        WHEN cl_abap_classdescr=>typekind_oref
          OR cl_abap_classdescr=>typekind_dref.

        WHEN cl_abap_classdescr=>typekind_struct2
          OR cl_abap_classdescr=>typekind_struct1.

          ls_attri-check_dissolved = abap_true.
          DATA(lt_attri_struc) = z2ui5_cl_fw_utility=>get_t_attri_by_struc(
                                       io_app   = mo_app
                                       iv_attri = ls_attri_descr-name ).

          LOOP AT lt_attri_struc INTO DATA(ls_struc).
            DATA(ls_attri_struc) = CORRESPONDING ty_s_attri( ls_struc ).
            ls_attri_struc-name = is_attri_descr->name && `->` && ls_attri_struc-name.
            ls_attri_struc-check_ready = abap_true.
            ls_attri_struc-check_temp  = abap_true.
            INSERT ls_attri_struc INTO TABLE result.
          ENDLOOP.

        WHEN OTHERS.
          ls_attri_struc = CORRESPONDING #( ls_attri_descr ).
          ls_attri_struc-name = is_attri_descr->name && `->` && ls_attri_struc-name.
          ls_attri_struc-check_ready = abap_true.
          ls_attri_struc-check_temp  = abap_true.
          INSERT ls_attri_struc INTO TABLE result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.



  METHOD get_t_dissolve_dref.

    DATA(lv_name) = `MO_APP->` && is_attri_descr->name && `->*`.
    FIELD-SYMBOLS <data> TYPE any.
    UNASSIGN <data>.
    ASSIGN (lv_name) TO <data>.
    IF <data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    DATA(ls_attri) = VALUE ty_s_attri(  ).

    DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <data> ).

    CASE lo_descr->type_kind.

      WHEN cl_abap_classdescr=>typekind_struct2
        OR cl_abap_classdescr=>typekind_struct1.

        ls_attri-check_dissolved = abap_true.
        DATA(lt_attri_struc) = z2ui5_cl_fw_utility=>get_t_attri_by_struc(
                                     io_app = mo_app
                                     iv_attri = is_attri_descr->name && `->*` ).

        LOOP AT lt_attri_struc INTO DATA(ls_struc).
          DATA(ls_new_struc) = VALUE ty_s_attri( ).
          ls_new_struc = CORRESPONDING #( ls_struc ).
          ls_new_struc-name = replace( val = ls_new_struc-name sub = is_attri_descr->name && `->*-` with = is_attri_descr->name && `->` ).
          ls_new_struc-check_ready = abap_true.
          ls_new_struc-check_temp = abap_true.
          INSERT ls_new_struc INTO TABLE result.
        ENDLOOP.

      WHEN OTHERS.
        DATA(ls_new_bind) = VALUE ty_s_attri(
           name = is_attri_descr->name && `->*`
           type_kind = lo_descr->type_kind
           type = lo_descr->get_relative_name(  )
           check_temp = abap_true
           check_ready = abap_true
         ).

        INSERT ls_new_bind INTO TABLE result.
    ENDCASE.

  ENDMETHOD.

  METHOD get_t_dissolve_data.

    DATA(ls_attri) = CORRESPONDING ty_s_attri( is_attri_descr ).
    CASE ls_attri-type_kind.
      WHEN cl_abap_classdescr=>typekind_iref
        OR cl_abap_classdescr=>typekind_intf.
        RETURN.

      WHEN cl_abap_classdescr=>typekind_oref
       OR cl_abap_classdescr=>typekind_dref.

      WHEN cl_abap_classdescr=>typekind_struct2
        OR cl_abap_classdescr=>typekind_struct1.

        ls_attri-check_dissolved = abap_true.
        DATA(lt_attri_struc) = z2ui5_cl_fw_utility=>get_t_attri_by_struc( io_app = mo_app iv_attri = ls_attri-name ).

        LOOP AT lt_attri_struc INTO DATA(ls_struc).
          DATA(ls_attri_struc) = VALUE ty_s_attri( ).
          ls_attri_struc = CORRESPONDING #( ls_struc ).
          ls_attri_struc-check_ready = abap_true.
          INSERT ls_attri_struc INTO TABLE result.
        ENDLOOP.

      WHEN OTHERS.
        ls_attri-check_ready = abap_true.
    ENDCASE.

    INSERT ls_attri INTO TABLE result.

  ENDMETHOD.


  METHOD bind_one_time.

    DATA(lv_id) = z2ui5_cl_fw_utility=>get_uuid_22( ).
    INSERT VALUE #( name           = lv_id
                    data_stringify = z2ui5_cl_fw_utility=>trans_any_2_json( mr_data )
                    bind_type      = cs_bind_type-one_time )
           INTO TABLE mt_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.


  METHOD main_bind.


    " dissolve - first time
    IF mt_attri IS INITIAL.

      DATA(lt_attri) = z2ui5_cl_fw_utility=>get_t_attri_by_obj( mo_app ).
      LOOP AT lt_attri INTO DATA(ls_attri_descr).
        DATA(lt_dissolve) = get_t_dissolve_data( is_attri_descr = ls_attri_descr ).
        INSERT LINES OF lt_dissolve INTO TABLE mt_attri.
      ENDLOOP.

    ENDIF.


    " check - data
    LOOP AT mt_attri REFERENCE INTO DATA(lr_bind)
        WHERE ( bind_type = `` OR bind_type = mv_type ) AND check_ready = abap_true.

      result = bind( bind = lr_bind ).
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.


    " dissolve - data refs
    DATA(lt_dref_diss_new) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO lr_bind WHERE
          type_kind = cl_abap_classdescr=>typekind_dref AND
          check_dissolved = abap_false.

      DATA(lt_dissolve_dref) = get_t_dissolve_dref( is_attri_descr = lr_bind ).
      INSERT LINES OF lt_dissolve_dref INTO TABLE lt_dref_diss_new.
      lr_bind->check_dissolved = abap_true.
    ENDLOOP.


    " check - data refs
    LOOP AT lt_dref_diss_new REFERENCE INTO lr_bind
           WHERE bind_type = `` OR bind_type = mv_type.
      result = bind( bind = lr_bind ).
      IF result IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF result IS NOT INITIAL.
      INSERT LINES OF lt_dref_diss_new INTO TABLE mt_attri.
      RETURN.
    ENDIF.


    " dissolve - obj refs
    DATA(lt_oref_diss_new) = VALUE ty_t_attri( ).

    LOOP AT mt_attri REFERENCE INTO lr_bind
      WHERE type_kind = cl_abap_classdescr=>typekind_oref AND
        check_dissolved = abap_false.

      DATA(lt_diss_oref) = get_t_dissolve_oref( is_attri_descr = lr_bind ).
      INSERT LINES OF lt_diss_oref INTO TABLE lt_oref_diss_new.
      lr_bind->check_dissolved = abap_true.
    ENDLOOP.


    " check - obj refs
    LOOP AT lt_oref_diss_new REFERENCE INTO lr_bind
           WHERE bind_type = `` OR bind_type = mv_type.
      result = bind( bind = lr_bind ).
      IF result IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF result IS NOT INITIAL.
      INSERT LINES OF lt_oref_diss_new INTO TABLE mt_attri.
      RETURN.
    ENDIF.


    "error or one time
    z2ui5_cl_fw_utility=>raise( when = xsdbool( mv_type = cs_bind_type-two_way ) v = `Binding Error - Two way binding used but no attribute found` ).
    result = bind_one_time( ).

  ENDMETHOD.


  METHOD bind.

    FIELD-SYMBOLS <attri> TYPE any.
    DATA(lv_name) = `MO_APP->` && to_upper( bind->name ).
    ASSIGN (lv_name) TO <attri>.
    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA lr_ref TYPE REF TO data.
    GET REFERENCE OF <attri> INTO lr_ref.

    IF mr_data = lr_ref.
      IF bind->bind_type <> mv_type AND bind->bind_type IS NOT INITIAL.
        z2ui5_cl_fw_utility=>raise(
          `<p>Binding Error - Two different binding types for same attribute used (` && bind->name && `).` ).
      ENDIF.
      bind->bind_type = mv_type.
      bind->name_front = bind->name.
      bind->name_front = replace( val = bind->name sub = `*` with = `_` occ = 0 ).
      bind->name_front = replace( val = bind->name_front sub = `>` with = `_` occ = 0 ).
      bind->name_front = replace( val = bind->name_front sub = `-` with = `_` occ = 0 ).

      result = COND #( WHEN mv_type = cs_bind_type-two_way THEN `/` && cv_model_edit_name && `/` ELSE `/` ) && bind->name_front.
      IF strlen( result ) > 30.
        bind->name_front = z2ui5_cl_fw_utility=>get_uuid_22( ).
        result = COND #( WHEN mv_type = cs_bind_type-two_way THEN `/` && cv_model_edit_name && `/` ELSE `/` ) && bind->name_front.
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
