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

    METHODS main_attri_db_before_save.
    METHODS main_attri_db_after_load.

  PROTECTED SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS attri_update_entry_refs.
    METHODS dissolve_run_init.

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


  METHOD main_attri_db_after_load.

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

    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE name_ref IS NOT INITIAL.
      TRY.

          ASSIGN mt_attri->* TO FIELD-SYMBOL(<table>).
          READ TABLE <table> INTO DATA(lr_attri_deref)
            WITH KEY name = lr_attri->name_ref.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          DATA(lr_val)      = attri_get_val_ref( lr_attri_deref-name ).

          ASSIGN mo_app->(lr_attri->name) TO FIELD-SYMBOL(<val4>).
          IF sy-subrc = 0.
            DATA(lo_test) = cl_abap_datadescr=>describe_by_data( <val4> ).
          ENDIF.
          TRY.
              DATA(lv_dummy) = CAST cl_abap_refdescr( lo_test ).
              FIELD-SYMBOLS <any> TYPE any.
              ASSIGN lr_val->* TO <any>.
              DATA(lo_test2) = cl_abap_datadescr=>describe_by_data( <any> ).
              TRY.
                  DATA(lv_dummy2) = CAST cl_abap_refdescr( lo_test2 ).
                  <val4> = lr_val->*.
                  lr_attri->r_ref = lr_val.
                CATCH cx_root.
                  <val4> = lr_val.
                  lr_attri->r_ref = lr_val.
              ENDTRY.

            CATCH cx_root.
              lr_attri->r_ref = REF #( <val4> ).
          ENDTRY.
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_before_save.

    dissolve( ).

    ASSIGN mt_attri->* TO FIELD-SYMBOL(<tab>).
    LOOP AT <tab> REFERENCE INTO DATA(lr_attri).

      IF lr_attri->o_typedescr IS NOT BOUND.
        CONTINUE.
      ENDIF.

      IF lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-one_time.
        DELETE mt_attri->*.
        CONTINUE.
      ENDIF.

      "extra case - conversion exit alpha numeric
      IF lr_attri->bind_type = z2ui5_if_core_types=>cs_bind_type-two_way AND (
          lr_attri->o_typedescr->type_kind = cl_abap_classdescr=>typekind_num OR
          lr_attri->o_typedescr->type_kind = cl_abap_classdescr=>typekind_numeric ).
        ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val_ref2>).
        CLEAR <val_ref2>.
        CLEAR lr_attri->r_ref.
        CONTINUE.
      ENDIF.

      IF lr_attri->o_typedescr->type_kind <> cl_abap_classdescr=>typekind_dref.
        CLEAR lr_attri->r_ref.
        CONTINUE.
      ENDIF.

      IF lr_attri->r_ref IS NOT BOUND.
        CONTINUE.
      ENDIF.

      ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<val_ref>).
      IF <val_ref> IS NOT INITIAL.
        ASSIGN <val_ref>->* TO FIELD-SYMBOL(<val>).
        IF lr_attri->name_ref IS INITIAL.
          lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val> ).
          CLEAR <val>.
          CLEAR <val_ref>.
          CLEAR lr_attri->r_ref.
          CONTINUE.
        ENDIF.

        ASSIGN mo_app->(lr_attri->name) TO FIELD-SYMBOL(<ref>).
        IF sy-subrc = 0.
          CLEAR <ref>.
        ENDIF.
      ENDIF.
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

    dissolve_run_init( ).
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

    attri_update_entry_refs( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE o_typedescr IS BOUND AND
                name_ref IS INITIAL.

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
    result-type_kind   =  result-o_typedescr->type_kind.
    result-kind         =  result-o_typedescr->kind.
    result-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( result-r_ref ).

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
               AND is_constant  = abap_false.
      TRY.
          DATA(lv_name) = COND #( WHEN ir_attri->name IS NOT INITIAL THEN |{ ir_attri->name }->| ) && lr_attri->name.
          DATA(ls_new) = create_new_entry( lv_name ).
          ls_new-is_class = lr_attri->is_class.
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
      INSERT ls_new INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve.

    WHILE line_exists( mt_attri->*[ check_dissolved = abap_false ] ) OR mt_attri->* IS INITIAL.

      IF sy-index = 5.
        RETURN.
      ENDIF.

      TRY.
          dissolve_run( ).
        CATCH cx_root.
          dissolve_run_init( ).
      ENDTRY.

    ENDWHILE.

  ENDMETHOD.


  METHOD attri_update_entry_refs.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).
      TRY.
          lr_attri->r_ref       = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).
        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE check_dissolved  = abap_true
               AND name_ref        IS INITIAL
               AND is_class = abap_false.

      IF lr_attri->type_kind <> cl_abap_typedescr=>typekind_dref AND
          lr_attri->type_kind IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_length) = strlen( lr_attri->name ) - 1.

      LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri2)
           WHERE check_dissolved = abap_true.

        IF lr_attri->name = lr_attri2->name.
          CONTINUE.
        ENDIF.

        DATA(lv_length2) = strlen( lr_attri2->name ) - 1.

        IF lv_length2 > lv_length.
          CONTINUE.
        ENDIF.

        IF lr_attri2->o_typedescr = lr_attri->o_typedescr AND lr_attri->r_ref = lr_attri2->r_ref.
          lr_attri->name_ref = lr_attri2->name.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    " check for root data
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE name_ref IS NOT INITIAL.

      DATA(lv_name_ref) = lr_attri->name_ref.
      TRY.
          DO.
            DATA(lr_attri_new) = REF #( mt_attri->*[ name = lv_name_ref ] ).
            lv_name_ref = lr_attri_new->name_ref.
          ENDDO.
        CATCH cx_root.
      ENDTRY.

      IF lr_attri_new IS BOUND.
        lr_attri->name_ref = lr_attri_new->name.
      ENDIF.
      CLEAR lr_attri_new.
    ENDLOOP.

    " check for root of struct and tables
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE name_ref IS INITIAL
            AND is_class = abap_false.

      IF lr_attri->type_kind <> cl_abap_typedescr=>typekind_dref.
        CONTINUE.
      ENDIF.

      DATA(length) = strlen( lr_attri->name ).

      IF lr_attri->r_ref IS NOT INITIAL.
        ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<dummy>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      LOOP AT mt_attri->* REFERENCE INTO DATA(lr_dref)
           WHERE name_ref IS NOT INITIAL.
        IF lr_dref->name_ref NS '-'.
          CONTINUE.
        ENDIF.

        TRY.
            DATA(lv_name) = lr_dref->name(length).
            IF lr_attri->name = lv_name.
              length = length + 1.
              SPLIT lr_dref->name+length AT '-' INTO DATA(lv_dummy4) DATA(lv_dummy).
              IF lv_dummy IS INITIAL.
                " TODO: variable is assigned but never used (ABAP cleaner)
                SPLIT lr_dref->name_ref AT '-' INTO lr_attri->name_ref DATA(lv_dummy2).
                EXIT.
              ENDIF.

            ENDIF.
          CATCH cx_root.
        ENDTRY.
      ENDLOOP.
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
*               AND bind_type <> z2ui5_if_core_types=>cs_bind_type-one_time.

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
    attri_update_entry_refs( ).

  ENDMETHOD.

  METHOD dissolve_run_init.

    DATA(lt_attri) = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL.
    CLEAR mt_attri->*.

    dissolve( ).

    ASSIGN mt_attri->* TO FIELD-SYMBOL(<tab>).
    LOOP AT <tab> REFERENCE INTO DATA(lr_attri).
      DATA(lv_name) = lr_attri->name.
      IF line_exists( lt_attri[ name = lv_name ] ).
        lr_attri->bind_type   = lt_attri[ name = lv_name ]-bind_type.
        lr_attri->name_client = lt_attri[ name = lv_name ]-name_client.
        lr_attri->view        = lt_attri[ name = lv_name ]-view.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
