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

    DATA temp1 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp1.
            FIELD-SYMBOLS <val> TYPE data.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri.
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

  ENDMETHOD.

  METHOD attri_before_save.

    DATA temp2 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp2.
        FIELD-SYMBOLS <val_ref2> TYPE data.
      FIELD-SYMBOLS <val_ref> TYPE data.
        FIELD-SYMBOLS <val> TYPE data.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri.

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
          lr_attri->o_typedescr->type_kind = cl_abap_classdescr=>typekind_numeric
          ).
        
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
        lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val> ).
        CLEAR <val>.
      ENDIF.

      CLEAR <val_ref>.
      CLEAR lr_attri->r_ref.

    ENDLOOP.

  ENDMETHOD.

  METHOD attri_search_a_dissolve.
    DATA lo_dissolve TYPE REF TO z2ui5_cl_core_srv_diss.
      DATA temp3 LIKE sy-subrc.
    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
        FIELD-SYMBOLS <ls_attri> LIKE LINE OF mt_attri->*.
          DATA lv_name LIKE <ls_attri>-name.
          DATA temp4 LIKE sy-subrc.
            DATA temp5 LIKE LINE OF lt_attri.
            DATA temp6 LIKE sy-tabix.
            DATA temp7 LIKE LINE OF lt_attri.
            DATA temp8 LIKE sy-tabix.
            DATA temp9 LIKE LINE OF lt_attri.
            DATA temp10 LIKE sy-tabix.
      DATA temp11 LIKE sy-subrc.

    result = attri_search( val ).
    IF result IS BOUND.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_dissolve TYPE z2ui5_cl_core_srv_diss EXPORTING attri = mt_attri app = mo_app.

    DO 5 TIMES.

      lo_dissolve->main( ).

      result = attri_search( val ).
      IF result IS BOUND.
        RETURN.
      ENDIF.

      
      READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
      temp3 = sy-subrc.
      IF temp3 = 0.
        CONTINUE.
      ENDIF.

      EXIT.
    ENDDO.

    """"" new
    
    lt_attri = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL.
    CLEAR mt_attri->*.
    DO 5 TIMES.

      lo_dissolve->main( ).

      result = attri_search( val ).
      IF result IS BOUND.
        
        LOOP AT mt_attri->* ASSIGNING <ls_attri>.
          
          lv_name = <ls_attri>-name.
          
          READ TABLE lt_attri WITH KEY name = lv_name TRANSPORTING NO FIELDS.
          temp4 = sy-subrc.
          IF temp4 = 0.
            
            
            temp6 = sy-tabix.
            READ TABLE lt_attri WITH KEY name = lv_name INTO temp5.
            sy-tabix = temp6.
            IF sy-subrc <> 0.
              ASSERT 1 = 0.
            ENDIF.
            <ls_attri>-bind_type   = temp5-bind_type.
            
            
            temp8 = sy-tabix.
            READ TABLE lt_attri WITH KEY name = lv_name INTO temp7.
            sy-tabix = temp8.
            IF sy-subrc <> 0.
              ASSERT 1 = 0.
            ENDIF.
            <ls_attri>-name_client = temp7-name_client.
            
            
            temp10 = sy-tabix.
            READ TABLE lt_attri WITH KEY name = lv_name INTO temp9.
            sy-tabix = temp10.
            IF sy-subrc <> 0.
              ASSERT 1 = 0.
            ENDIF.
            <ls_attri>-view        = temp9-view.
          ENDIF.
        ENDLOOP.
        RETURN.
      ENDIF.

      
      READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
      temp11 = sy-subrc.
      IF temp11 = 0.
        CONTINUE.
      ENDIF.

      EXIT.
    ENDDO.

    """""

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

    DATA temp12 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp12.
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

    DATA temp13 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp13.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE o_typedescr IS BOUND.

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

