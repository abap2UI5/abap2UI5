CLASS z2ui5_cl_core_srv_diss DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        app   TYPE REF TO object.

    METHODS main_attri_search
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    METHODS main_attri_db_save
      IMPORTING
        check_clear_two_way_data TYPE abap_bool DEFAULT abap_false.

    METHODS main_attri_db_save_srtti.
    METHODS main_attri_db_load.
    METHODS main_attri_refresh.

  PROTECTED SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS attri_update_entry_refs.


    METHODS attri_get_val_ref
      IMPORTING
        iv_path       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS attri_search
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    METHODS dissolve.
    METHODS dissolve_run.

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

    METHODS create_new_entry
      IMPORTING
        !name         TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_attri.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_diss IMPLEMENTATION.


  METHOD main_attri_db_load.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
        WHERE name_ref IS INITIAL.
      TRY.
          lr_attri->r_ref       = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

          IF lr_attri->srtti_data IS NOT INITIAL.
            ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val>).
            <val> = z2ui5_cl_util=>xml_srtti_parse( lr_attri->srtti_data ).
            CLEAR lr_attri->srtti_data.
          ENDIF.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.


    ASSIGN mt_attri->* TO FIELD-SYMBOL(<table>).
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE name_ref IS NOT INITIAL.

      CASE lr_attri->type_kind.

        WHEN cl_abap_datadescr=>typekind_table.

          lr_attri->r_ref       = attri_get_val_ref( lr_attri->name_ref ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

          READ TABLE <table> REFERENCE INTO DATA(lr_attri_parent)
            WITH KEY name = lr_attri->name_parent.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          ASSIGN mo_app->(lr_attri_parent->name) TO FIELD-SYMBOL(<val4>).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          GET REFERENCE OF lr_attri->r_ref->* INTO <val4>.
          lr_attri_parent->r_ref       = REF #( <val4> ).
          lr_attri_parent->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri_parent->r_ref ).

        WHEN cl_abap_datadescr=>typekind_dref.

          ASSIGN mo_app->(lr_attri->name_ref) TO FIELD-SYMBOL(<val5>).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ASSIGN mo_app->(lr_attri->name) TO <val4>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          GET REFERENCE OF <val5> INTO <val4>.

          lr_attri->r_ref       = <val4>.
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

          LOOP AT mt_attri->* REFERENCE INTO DATA(lr_child) WHERE
              name_parent = lr_attri->name.
            lr_child->r_ref       = attri_get_val_ref( lr_child->name ).
            lr_child->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_child->r_ref ).
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.

    dissolve( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
        WHERE name_ref IS INITIAL
         AND type_kind = cl_abap_datadescr=>typekind_dref.

      ASSIGN mo_app->(lr_attri->name) TO FIELD-SYMBOL(<ref>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lv_name) = |MO_APP->{ lr_attri->name }->*|.
      ASSIGN (lv_name) TO FIELD-SYMBOL(<val1>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <val1> ).

      CASE lo_descr->type_kind.

        WHEN cl_abap_datadescr=>typekind_table.

          LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_child)
              WHERE name_ref IS INITIAL AND
               type_kind = cl_abap_datadescr=>typekind_table AND
               name_parent = lr_attri->name.
            ASSIGN mo_app->(lr_attri_child->name) TO FIELD-SYMBOL(<val_ref>).
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val_ref> ).
            CLEAR <val_ref>.
            EXIT.
          ENDLOOP.

        WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
          lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val1> ).

      ENDCASE.

      CLEAR <val1>.
      CLEAR <ref>.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_search.

    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    dissolve( ).
    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    main_attri_refresh( ).
    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

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

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE o_typedescr IS BOUND
             AND name_ref IS INITIAL.

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

  METHOD create_new_entry.

    result = VALUE z2ui5_if_core_types=>ty_s_attri( ).
    result-name = name.
    result-r_ref       = attri_get_val_ref( name ).
    result-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( result-r_ref ).
    result-type_kind   = result-o_typedescr->type_kind.
    result-kind        = result-o_typedescr->kind.

  ENDMETHOD.

  METHOD diss_dref.

    IF z2ui5_cl_util=>check_unassign_inital( ir_attri->r_ref ).
      RETURN.
    ENDIF.

    DATA(lr_ref) = z2ui5_cl_util=>unassign_data( ir_attri->r_ref ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
    ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref ).

    CASE ls_attri2-o_typedescr->kind.

      WHEN cl_abap_datadescr=>kind_struct.
        DATA(lt_attri) = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.

        ls_attri2-name = |{ ir_attri->name }->*|.
        ls_attri2-r_ref = attri_get_val_ref( ls_attri2-name ).
        ls_attri2-name_parent = ir_attri->name.
        ls_attri2-type_kind   = ls_attri2-o_typedescr->type_kind.
        ls_attri2-kind        = ls_attri2-o_typedescr->kind.
        INSERT ls_attri2 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.

  METHOD diss_oref.

    IF z2ui5_cl_util=>check_unassign_inital( ir_attri->r_ref ).
      RETURN.
    ENDIF.

    DATA(lr_ref) = z2ui5_cl_util=>unassign_object( ir_attri->r_ref ).
    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_oref( lr_ref ).

    LOOP AT lt_attri REFERENCE INTO DATA(lr_attri)
         WHERE visibility   = cl_abap_objectdescr=>public
            AND is_interface = abap_false
            AND is_class     = abap_false
            AND is_constant  = abap_false.
      TRY.
          DATA(lv_name) = COND #( WHEN ir_attri->name IS NOT INITIAL THEN |{ ir_attri->name }->| ) && lr_attri->name.
          DATA(ls_new) = create_new_entry( lv_name ).
*          ls_new-is_class = lr_attri->is_class.
          ls_new-name_parent = ir_attri->name.
          INSERT ls_new INTO TABLE result.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD diss_struc.

    IF ir_attri->o_typedescr->kind = cl_abap_typedescr=>kind_ref.
      DATA(lv_name) = |{ ir_attri->name }->|.
      DATA(lr_ref) = z2ui5_cl_util=>unassign_data( ir_attri->r_ref ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = ir_attri->r_ref.
    ENDIF.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( lr_ref ).

    LOOP AT lt_attri INTO DATA(ls_attri).
      DATA(ls_new) = create_new_entry( lv_name && ls_attri-name ).
      ls_new-name_parent = ir_attri->name.
      INSERT ls_new INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve.

    WHILE line_exists( mt_attri->*[ check_dissolved = abap_false ] ) OR mt_attri->* IS INITIAL.
      DATA(lv_check_update_refs) = abap_true.

      IF sy-index = 5.
        RETURN.
      ENDIF.

      TRY.
          dissolve_run( ).
        CATCH cx_root.
          main_attri_refresh( ).
      ENDTRY.

    ENDWHILE.

    IF lv_check_update_refs = abap_true.
      attri_update_entry_refs( ).
    ENDIF.

  ENDMETHOD.


  METHOD attri_update_entry_refs.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE check_dissolved  = abap_true
               AND name_ref        IS INITIAL.

      CASE lr_attri->type_kind.

        WHEN cl_abap_typedescr=>typekind_table.

          LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_ref)
              WHERE check_dissolved  = abap_true AND
              name <> lr_attri->name
                AND name_ref IS INITIAL
                AND type_kind = cl_abap_typedescr=>typekind_table.

            IF lr_attri->r_ref <> lr_attri_ref->r_ref.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_attri_ref->name.
          ENDLOOP.


        WHEN cl_abap_typedescr=>typekind_dref.

          DATA lr_ref TYPE REF TO data.
          lr_ref = lr_attri->r_ref->*.

          LOOP AT mt_attri->* REFERENCE INTO lr_attri_ref
              WHERE check_dissolved  = abap_true AND
                name <> lr_attri->name
                    AND name_ref IS INITIAL
                    AND ( type_kind = cl_abap_typedescr=>typekind_struct1 OR
                     type_kind = cl_abap_typedescr=>typekind_struct2 ).

            IF lr_ref <> lr_attri_ref->r_ref.
              CONTINUE.
            ENDIF.

            IF lr_attri->name_ref IS NOT INITIAL AND strlen( lr_attri->name_ref ) <= lr_attri_ref->name.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_attri_ref->name.

            LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_child)
                WHERE name_parent = lr_attri->name.

              DATA(lv_name) = shift_left( val = lr_attri_child->name
                                          sub = lr_attri->name && '->' ).
              lr_attri_child->name_ref = lr_attri->name_ref && '-' && lv_name.

            ENDLOOP.
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.

    IF mt_attri->* IS INITIAL.
      DATA(ls_attri) = VALUE z2ui5_if_core_types=>ty_s_attri( r_ref = REF #( mo_app ) ).
      DATA(lt_init) = diss_oref( REF #( ls_attri ) ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.

    DATA(lt_attri_new) = VALUE z2ui5_if_core_types=>ty_t_attri( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE check_dissolved  = abap_false.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.
        DATA(ls_entry) = create_new_entry( lr_attri->name ).
        lr_attri->o_typedescr = ls_entry-o_typedescr.
        lr_attri->r_ref       = ls_entry-r_ref.
      ENDIF.

      CASE lr_attri->o_typedescr->kind.

        WHEN cl_abap_typedescr=>kind_struct.
          DATA(lt_attri_struc) = diss_struc( lr_attri ).
          INSERT LINES OF lt_attri_struc INTO TABLE lt_attri_new.

        WHEN cl_abap_typedescr=>kind_ref.

          CASE lr_attri->o_typedescr->type_kind.

            WHEN cl_abap_typedescr=>typekind_oref.
              DATA(lt_attri_oref) = diss_oref( lr_attri ).
              INSERT LINES OF lt_attri_oref INTO TABLE lt_attri_new.
            WHEN cl_abap_typedescr=>typekind_dref.
              DATA(lt_attri_dref) = diss_dref( lr_attri ).
              INSERT LINES OF lt_attri_dref INTO TABLE lt_attri_new.
            WHEN OTHERS.
              ASSERT 1 = 0.
          ENDCASE.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.


  ENDMETHOD.

  METHOD main_attri_refresh.

    DATA(lt_attri) = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL.
    CLEAR mt_attri->*.

    dissolve( ).

    ASSIGN mt_attri->* TO FIELD-SYMBOL(<tab>).
    LOOP AT <tab> REFERENCE INTO DATA(lr_attri).
      DATA(lv_name) = lr_attri->name.
      IF line_exists( lt_attri[ name = lv_name ] ).
*        IF  lr_attri->type_kind <> cl_abap_datadescr=>typekind_dref.
        lr_attri->bind_type   = lt_attri[ name = lv_name ]-bind_type.
        lr_attri->name_client = lt_attri[ name = lv_name ]-name_client.
        lr_attri->view        = lt_attri[ name = lv_name ]-view.
*        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).

      IF check_clear_two_way_data = abap_true AND lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-two_way.
        ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<data>).
        CLEAR <data>.
      ENDIF.
      CLEAR lr_attri->r_ref.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
