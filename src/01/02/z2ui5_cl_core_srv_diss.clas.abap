CLASS z2ui5_cl_core_srv_diss DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        app   TYPE REF TO object.

    METHODS main.

  PROTECTED SECTION.
    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS main_run.
    METHODS main_init.

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

    METHODS main_update_refs.
ENDCLASS.


CLASS z2ui5_cl_core_srv_diss IMPLEMENTATION.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD create_new_entry.

    result = VALUE z2ui5_if_core_types=>ty_s_attri( ).
    result-name = name.
    DATA(lo_model) = NEW z2ui5_cl_core_srv_attri( attri = mt_attri
                                                  app   = mo_app ).
    result-r_ref       = lo_model->attri_get_val_ref( name ).
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
        DATA(lo_model) = NEW z2ui5_cl_core_srv_attri( attri = mt_attri
                                                      app   = mo_app ).
        ls_attri2-r_ref = lo_model->attri_get_val_ref( ls_attri2-name ).
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
         WHERE     visibility   = cl_abap_objectdescr=>public
               AND is_interface = abap_false
               AND is_constant  = abap_false.
      TRY.
          DATA(lv_name) = COND #( WHEN ir_attri->name IS NOT INITIAL THEN |{ ir_attri->name }->| ) && lr_attri->name.
          DATA(ls_new) = create_new_entry( lv_name ).
          ls_new-is_class = lr_attri->is_class.
          ls_new-type_kind = lr_attri->type_kind.
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

  METHOD main.

    main_init( ).

    DO 5 TIMES.
      IF line_exists( mt_attri->*[ check_dissolved = abap_false ] ).
        TRY.
            main_run( ).
          CATCH cx_root.
            CLEAR mt_attri->*.
            main_init( ).
        ENDTRY.
        CONTINUE.
      ENDIF.
      EXIT.
    ENDDO.

    main_update_refs( ).

  ENDMETHOD.


  METHOD main_update_refs.


    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE     check_dissolved  = abap_true
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
        ASSIGN lr_attri->r_ref->* TO FIELD-SYMBOL(<any>).
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

  METHOD main_init.

    IF mt_attri->* IS NOT INITIAL.
      LOOP AT mt_attri->* TRANSPORTING NO FIELDS
           WHERE bind_type <> z2ui5_if_core_types=>cs_bind_type-one_time.
        RETURN.
      ENDLOOP.
*      IF sy-subrc = 0.
*        RETURN.
*      ENDIF.
    ENDIF.

    DATA(ls_attri) = VALUE z2ui5_if_core_types=>ty_s_attri( r_ref = REF #( mo_app ) ).
    DATA(lt_init) = diss_oref( REF #( ls_attri ) ).
    INSERT LINES OF lt_init INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD main_run.

    DATA(lt_attri_new) = VALUE z2ui5_if_core_types=>ty_t_attri( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE     check_dissolved  = abap_false
               AND bind_type       <> z2ui5_if_core_types=>cs_bind_type-one_time.

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

    IF lt_attri_new IS INITIAL.
      RETURN.
    ENDIF.

    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.


  ENDMETHOD.

ENDCLASS.
