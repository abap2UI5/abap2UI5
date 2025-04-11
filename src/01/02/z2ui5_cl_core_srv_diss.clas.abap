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

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_diss IMPLEMENTATION.
  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD create_new_entry.

    DATA temp1 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.
    CLEAR temp1.
    result = temp1.
    result-name = name.
    
    CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = mt_attri app = mo_app.
    result-r_ref       = lo_model->attri_get_val_ref( name ).
    result-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( result-r_ref ).

  ENDMETHOD.

  METHOD diss_dref.
    DATA lr_ref TYPE REF TO data.
    DATA temp2 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_attri2 LIKE temp2.
        DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
        DATA lo_model TYPE REF TO z2ui5_cl_core_srv_attri.

    IF z2ui5_cl_util=>check_unassign_inital( ir_attri->r_ref ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_data( ir_attri->r_ref ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    
    CLEAR temp2.
    
    ls_attri2 = temp2.
    ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref ).

    CASE ls_attri2-o_typedescr->kind.

      WHEN cl_abap_datadescr=>kind_struct.
        
        lt_attri = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.

        ls_attri2-name = |{ ir_attri->name }->*|.
        
        CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_attri EXPORTING attri = mt_attri app = mo_app.
        ls_attri2-r_ref = lo_model->attri_get_val_ref( ls_attri2-name ).
        INSERT ls_attri2 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.

  METHOD diss_oref.
    DATA lr_ref TYPE REF TO object.
    DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp3 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp3.
          DATA temp4 TYPE string.
          DATA lv_name TYPE string.
          DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.

    IF z2ui5_cl_util=>check_unassign_inital( ir_attri->r_ref ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_object( ir_attri->r_ref ).
    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_oref( lr_ref ).

    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri
         WHERE visibility   = cl_abap_objectdescr=>public
               AND is_interface = abap_false
               AND is_constant  = abap_false.
      TRY.
          
          IF ir_attri->name IS NOT INITIAL.
            temp4 = |{ ir_attri->name }->|.
          ELSE.
            CLEAR temp4.
          ENDIF.
          
          lv_name = temp4 && lr_attri->name.
          
          ls_new = create_new_entry( lv_name ).
          INSERT ls_new INTO TABLE result.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD diss_struc.
      DATA lv_name TYPE string.
      DATA lr_ref TYPE REF TO data.
    DATA lt_attri TYPE abap_component_tab.
    DATA ls_attri LIKE LINE OF lt_attri.
      DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.

    IF ir_attri->o_typedescr->kind = cl_abap_typedescr=>kind_ref.
      
      lv_name = |{ ir_attri->name }->|.
      
      lr_ref = z2ui5_cl_util=>unassign_data( ir_attri->r_ref ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = ir_attri->r_ref.
    ENDIF.

    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( lr_ref ).

    
    LOOP AT lt_attri INTO ls_attri.
      
      ls_new = create_new_entry( lv_name && ls_attri-name ).
      INSERT ls_new INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD main.
        DATA temp5 LIKE sy-subrc.
        DATA temp6 LIKE sy-subrc.

    TRY.

        main_init( ).

        
        READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
        temp5 = sy-subrc.
        IF temp5 = 0.
          main_run( ).
        ENDIF.

      CATCH cx_root.
        CLEAR mt_attri->*.
        main_init( ).

        
        READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
        temp6 = sy-subrc.
        IF temp6 = 0.
          main_run( ).
        ENDIF.
    ENDTRY.

  ENDMETHOD.

  METHOD main_init.
    DATA temp7 LIKE REF TO mo_app.
DATA temp1 TYPE z2ui5_if_core_types=>ty_s_attri.
DATA ls_attri LIKE temp1.
    DATA temp8 LIKE REF TO ls_attri.
DATA lt_init TYPE z2ui5_if_core_types=>ty_t_attri.

    IF mt_attri->* IS NOT INITIAL.
      LOOP AT mt_attri->* TRANSPORTING NO FIELDS
           WHERE bind_type <> z2ui5_if_core_types=>cs_bind_type-one_time.
      ENDLOOP.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDIF.

    
    GET REFERENCE OF mo_app INTO temp7.

CLEAR temp1.
temp1-r_ref = temp7.

ls_attri = temp1.
    
    GET REFERENCE OF ls_attri INTO temp8.

lt_init = diss_oref( temp8 ).
    INSERT LINES OF lt_init INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD main_run.

    DATA temp9 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri_new LIKE temp9.
    DATA temp10 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp10.
        DATA ls_entry TYPE z2ui5_if_core_types=>ty_s_attri.
          DATA lt_attri_struc TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_oref TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_dref TYPE z2ui5_if_core_types=>ty_t_attri.
    CLEAR temp9.
    
    lt_attri_new = temp9.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE check_dissolved  = abap_false
               AND bind_type       <> z2ui5_if_core_types=>cs_bind_type-one_time.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.
        
        ls_entry = create_new_entry( lr_attri->name ).
        lr_attri->o_typedescr = ls_entry-o_typedescr.
        lr_attri->r_ref       = ls_entry-r_ref.
      ENDIF.

      CASE lr_attri->o_typedescr->kind.

        WHEN cl_abap_typedescr=>kind_struct.
          
          lt_attri_struc = diss_struc( lr_attri ).
          INSERT LINES OF lt_attri_struc INTO TABLE lt_attri_new.

        WHEN cl_abap_typedescr=>kind_ref.

          CASE lr_attri->o_typedescr->type_kind.

            WHEN cl_abap_typedescr=>typekind_oref.
              
              lt_attri_oref = diss_oref( lr_attri ).
              INSERT LINES OF lt_attri_oref INTO TABLE lt_attri_new.
            WHEN cl_abap_typedescr=>typekind_dref.
              
              lt_attri_dref = diss_dref( lr_attri ).
              INSERT LINES OF lt_attri_dref INTO TABLE lt_attri_new.
            WHEN OTHERS.
              ASSERT 1 = 0.
          ENDCASE.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.
    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.

  ENDMETHOD.
ENDCLASS.
