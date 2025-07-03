CLASS z2ui5_cl_core_srv_attri DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri
        app   TYPE REF TO object.

    METHODS attri_refs_update.
    METHODS attri_before_save.
    METHODS attri_after_load.

    METHODS attri_get_val_ref
      IMPORTING
        iv_path       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS attri_search_a_dissolve
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

  PROTECTED SECTION.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS attri_search
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_attri IMPLEMENTATION.

  METHOD attri_after_load.

    DATA temp20 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp20.
            FIELD-SYMBOLS <val> TYPE data.
          FIELD-SYMBOLS <table> TYPE z2ui5_if_core_types=>ty_t_attri.
          DATA lr_attri_deref TYPE z2ui5_if_core_types=>ty_s_attri.
          DATA lr_val TYPE REF TO data.
          FIELD-SYMBOLS <val4> TYPE any.
            DATA lo_test TYPE REF TO cl_abap_typedescr.
              DATA temp21 TYPE REF TO cl_abap_refdescr.
              DATA lv_dummy LIKE temp21.
              FIELD-SYMBOLS <any> TYPE any.
              DATA lo_test2 TYPE REF TO cl_abap_typedescr.
                  DATA temp22 TYPE REF TO cl_abap_refdescr.
                  DATA lv_dummy2 LIKE temp22.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
        WHERE name_ref IS INITIAL.
      TRY.
          lr_attri->r_ref       = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

          IF lr_attri->srtti_data IS NOT INITIAL.
            
            ASSIGN lr_attri->r_ref->* TO <val>.
            <val> = z2ui5_cl_util=>xml_srtti_parse( lr_attri->srtti_data ).
            CLEAR lr_attri->srtti_data.
          ENDIF.

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE name_ref IS NOT INITIAL.
      TRY.

          
          ASSIGN mt_attri->* TO <table>.
          
          READ TABLE <table> INTO lr_attri_deref
            WITH KEY name = lr_attri->name_ref.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
*          DATA(lr_attri_deref)  = <table>[ name = lr_attri->name_ref ].
          
          lr_val      = attri_get_val_ref( lr_attri_deref-name ).

          
          ASSIGN mo_app->(lr_attri->name) TO <val4>.
          IF sy-subrc = 0.
            
            lo_test = cl_abap_datadescr=>describe_by_data( <val4> ).
          ENDIF.
          TRY.
              
              temp21 ?= lo_test.
              
              lv_dummy = temp21.
              
              ASSIGN lr_val->* TO <any>.
              
              lo_test2 = cl_abap_datadescr=>describe_by_data( <any> ).
              TRY.
                  
                  temp22 ?= lo_test2.
                  
                  lv_dummy2 = temp22.
                  <val4> = lr_val->*.
                  lr_attri->r_ref = lr_val.
                CATCH cx_root.
                  <val4> = lr_val.
                  lr_attri->r_ref = lr_val.
              ENDTRY.

            CATCH cx_root.
              GET REFERENCE OF <val4> INTO lr_attri->r_ref.
          ENDTRY.
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).

        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD attri_before_save.

    FIELD-SYMBOLS <tab> TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp23 LIKE LINE OF <tab>.
    DATA lr_attri LIKE REF TO temp23.
        FIELD-SYMBOLS <val_ref2> TYPE data.
      FIELD-SYMBOLS <val_ref> TYPE data.
        FIELD-SYMBOLS <val> TYPE data.
        FIELD-SYMBOLS <ref> TYPE any.
    ASSIGN mt_attri->* TO <tab>.
    
    
    LOOP AT <tab> REFERENCE INTO lr_attri.

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
        
        ASSIGN lr_attri->r_ref->* TO <val_ref2>.
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

      
      ASSIGN lr_attri->r_ref->* TO <val_ref>.
      IF <val_ref> IS NOT INITIAL.
        
        ASSIGN <val_ref>->* TO <val>.
        IF lr_attri->name_ref IS INITIAL.
          lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val> ).
          CLEAR <val>.
          CLEAR <val_ref>.
          CLEAR lr_attri->r_ref.
          CONTINUE.
        ENDIF.

        
        ASSIGN mo_app->(lr_attri->name) TO <ref>.
        IF sy-subrc = 0.
          CLEAR <ref>.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD attri_search_a_dissolve.
    DATA lo_dissolve TYPE REF TO z2ui5_cl_core_srv_diss.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    FIELD-SYMBOLS <tab> TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp24 LIKE LINE OF <tab>.
    DATA lr_attri LIKE REF TO temp24.
      DATA lv_name LIKE lr_attri->name.
      DATA temp25 LIKE sy-subrc.
        DATA temp26 LIKE LINE OF lt_attri.
        DATA temp27 LIKE sy-tabix.
        DATA temp28 LIKE LINE OF lt_attri.
        DATA temp29 LIKE sy-tabix.
        DATA temp30 LIKE LINE OF lt_attri.
        DATA temp31 LIKE sy-tabix.

    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_dissolve TYPE z2ui5_cl_core_srv_diss EXPORTING attri = mt_attri app = mo_app.

    lo_dissolve->main( ).

    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    
    lt_attri = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL.
    CLEAR mt_attri->*.

    lo_dissolve->main( ).

    result = attri_search( val ).
    
    ASSIGN mt_attri->* TO <tab>.
    
    
    LOOP AT <tab> REFERENCE INTO lr_attri.
      
      lv_name = lr_attri->name.
      
      READ TABLE lt_attri WITH KEY name = lv_name TRANSPORTING NO FIELDS.
      temp25 = sy-subrc.
      IF temp25 = 0.
        
        
        temp27 = sy-tabix.
        READ TABLE lt_attri WITH KEY name = lv_name INTO temp26.
        sy-tabix = temp27.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lr_attri->bind_type   = temp26-bind_type.
        
        
        temp29 = sy-tabix.
        READ TABLE lt_attri WITH KEY name = lv_name INTO temp28.
        sy-tabix = temp29.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lr_attri->name_client = temp28-name_client.
        
        
        temp31 = sy-tabix.
        READ TABLE lt_attri WITH KEY name = lv_name INTO temp30.
        sy-tabix = temp31.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lr_attri->view        = temp30-view.
      ENDIF.
    ENDLOOP.
    RETURN.

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

    DATA temp32 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp32.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri.
      TRY.
          lr_attri->r_ref       = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_attri->r_ref ).
        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    DATA temp33 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp33.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
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
ENDCLASS.
