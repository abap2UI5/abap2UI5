CLASS z2ui5_cl_core_srv_model DEFINITION
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

    METHODS main_attri_db_save_srtti.
    METHODS main_attri_db_load.
    METHODS main_attri_refresh.

    METHODS main_json_to_attri
      IMPORTING
        view  TYPE string
        model TYPE REF TO z2ui5_if_ajson.

    METHODS main_json_stringify
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

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

    METHODS attri_create_new
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_core_types=>ty_s_attri.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_model IMPLEMENTATION.

  METHOD main_json_to_attri.

    DATA temp72 LIKE sy-subrc.
      DATA lv_view LIKE view.
    DATA temp73 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp73.
          DATA lo_val_front TYPE REF TO z2ui5_if_ajson.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
          DATA x TYPE REF TO cx_root.
    READ TABLE mt_attri->* WITH KEY view = view TRANSPORTING NO FIELDS.
    temp72 = sy-subrc.
    IF temp72 = 0. "#EC CI_SORTSEQ
      
      lv_view = view.
    ELSE.
      lv_view = z2ui5_if_client=>cs_view-main.
    ENDIF.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE bind_type = z2ui5_if_core_types=>cs_bind_type-two_way "#EC CI_SORTSEQ
               AND view      = lv_view.
      TRY.

          
          lo_val_front = model->slice( lr_attri->name_client ).
          IF lo_val_front IS NOT BOUND.
            CONTINUE.
          ENDIF.

          IF lr_attri->custom_mapper_back IS BOUND.
            lo_val_front = lo_val_front->map( lr_attri->custom_mapper_back ).
          ENDIF.

          IF lr_attri->custom_filter_back IS BOUND.
            lo_val_front = lo_val_front->filter( lr_attri->custom_filter_back ).
          ENDIF.

          TRY.
              
              lr_ref = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          
          ASSIGN lr_ref->* TO <val>.

          lo_val_front->to_abap( EXPORTING iv_corresponding = abap_true
                                 IMPORTING ev_container     = <val> ).

          
        CATCH cx_root INTO x.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING val = |JSON_PARSING_ERROR: { x->get_text( ) } |.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_json_stringify.
        DATA temp74 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp74.
        DATA temp75 LIKE LINE OF mt_attri->*.
        DATA lr_attri LIKE REF TO temp75.
            DATA temp76 TYPE REF TO z2ui5_if_ajson.
            DATA ajson LIKE temp76.
            DATA temp77 TYPE REF TO z2ui5_if_ajson.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
        DATA temp78 TYPE string.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp74 ?= z2ui5_cl_ajson=>create_empty( ).
        
        ajson_result = temp74.
        
        
        LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
             WHERE bind_type <> ``
                   AND type_kind <> cl_abap_datadescr=>typekind_dref
                   AND type_kind <> cl_abap_datadescr=>typekind_oref.

          IF lr_attri->custom_mapper IS BOUND.
            
            temp76 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lr_attri->custom_mapper ).
            
            ajson = temp76.
          ELSE.
            
            temp77 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ).
            ajson = temp77.
          ENDIF.

          TRY.
              
              lr_ref = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          
          ASSIGN lr_ref->* TO <val>.

          ajson->set( iv_ignore_empty = abap_false
                      iv_path         = `/`
                      iv_val          = <val> ).

          IF lr_attri->custom_filter IS BOUND.
            ajson = ajson->filter( lr_attri->custom_filter ).
          ENDIF.

          ajson_result->set( iv_path = lr_attri->name_client
                             iv_val  = ajson ).
        ENDLOOP.

        result = ajson_result->stringify( ).
        
        IF result IS INITIAL.
          temp78 = `{}`.
        ELSE.
          temp78 = result.
        ENDIF.
        result = temp78.

        
      CATCH cx_root INTO x.
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.

  METHOD main_attri_db_load.

    DATA temp79 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp79.
          DATA lr_ref TYPE REF TO data.
            FIELD-SYMBOLS <val> TYPE data.
          DATA lr_ref2 TYPE REF TO data.
          DATA lr_attri_parent TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
          DATA lv_name TYPE string.
          FIELD-SYMBOLS <val4> TYPE any.
          FIELD-SYMBOLS <val3> TYPE data.
          DATA lr_ref_parent TYPE REF TO data.
          DATA lv_name2 TYPE string.
          FIELD-SYMBOLS <val5> TYPE any.
          DATA lv_name3 TYPE string.
          DATA temp80 LIKE LINE OF mt_attri->*.
          DATA lr_child LIKE REF TO temp80.
            DATA lr_child_ref TYPE REF TO data.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name_ref IS INITIAL.
      TRY.
          
          lr_ref = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref ).

          IF lr_attri->srtti_data IS NOT INITIAL.
            
            ASSIGN lr_ref->* TO <val>.
            <val> = z2ui5_cl_util=>xml_srtti_parse( lr_attri->srtti_data ).
            CLEAR lr_attri->srtti_data.
          ENDIF.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name_ref IS NOT INITIAL.

      CASE lr_attri->type_kind.

        WHEN cl_abap_datadescr=>typekind_table.

          
          lr_ref2 = attri_get_val_ref( lr_attri->name_ref ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref2 ).

          
          READ TABLE mt_attri->* REFERENCE INTO lr_attri_parent
               WITH KEY name = lr_attri->name_parent.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          
          lv_name = |MO_APP->{ lr_attri_parent->name }|.
          
          ASSIGN (lv_name) TO <val4>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          
          ASSIGN lr_ref2->* TO <val3>.
          GET REFERENCE OF <val3> INTO <val4>.

          
GET REFERENCE OF <val4> INTO lr_ref_parent.
          lr_attri_parent->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref_parent ).

        WHEN cl_abap_datadescr=>typekind_dref.

          
          lv_name2 = |MO_APP->{ lr_attri->name_ref }|.
          
          ASSIGN (lv_name2) TO <val5>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          
          lv_name3 = |MO_APP->{ lr_attri->name }|.
          ASSIGN (lv_name3) TO <val4>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          GET REFERENCE OF <val5> INTO <val4>.
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( <val4> ).

          
          
          LOOP AT mt_attri->* REFERENCE INTO lr_child "#EC CI_SORTSEQ
               WHERE name_parent = lr_attri->name.
            
            lr_child_ref = attri_get_val_ref( lr_child->name ).
            lr_child->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_child_ref ).
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.
    DATA temp81 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp81.
      DATA lv_name5 TYPE string.
      FIELD-SYMBOLS <ref> TYPE any.
      DATA lv_name TYPE string.
      FIELD-SYMBOLS <val1> TYPE any.
      DATA lo_descr TYPE REF TO cl_abap_typedescr.
          DATA temp82 LIKE LINE OF mt_attri->*.
          DATA lr_attri_child LIKE REF TO temp82.
            DATA lv_name6 TYPE string.
            FIELD-SYMBOLS <val_ref> TYPE any.
    DATA temp83 LIKE LINE OF mt_attri->*.
    DATA lr_attri2 LIKE REF TO temp83.
      DATA lv_name8 TYPE string.
      FIELD-SYMBOLS <ref2> TYPE any.
      DATA lv_name10 TYPE string.
      FIELD-SYMBOLS <val8> TYPE any.

    dissolve( ).

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = cl_abap_datadescr=>typekind_dref.

      
      lv_name5 = |MO_APP->{ lr_attri->name }|.
      
      ASSIGN (lv_name5) TO <ref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lv_name = |MO_APP->{ lr_attri->name }->*|.
      
      ASSIGN (lv_name) TO <val1>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lo_descr = cl_abap_datadescr=>describe_by_data( <val1> ).

      CASE lo_descr->type_kind.

        WHEN cl_abap_datadescr=>typekind_table.

          
          
          LOOP AT mt_attri->* REFERENCE INTO lr_attri_child "#EC CI_SORTSEQ
               WHERE name_ref    IS INITIAL
                     AND type_kind    = cl_abap_datadescr=>typekind_table
                     AND name_parent  = lr_attri->name.

            
            lv_name6 = |MO_APP->{ lr_attri_child->name }|.
            
            ASSIGN (lv_name6) TO <val_ref>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val_ref> ).
            CLEAR <val_ref>.
            CLEAR <val1>.
            CLEAR <ref>.
            EXIT.
          ENDLOOP.

        WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
          lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <val1> ).

      ENDCASE.

    ENDLOOP.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri2 "#EC CI_SORTSEQ
         WHERE type_kind = cl_abap_datadescr=>typekind_dref.

      
      lv_name8 = |MO_APP->{ lr_attri2->name }|.
      
      ASSIGN (lv_name8) TO <ref2>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <ref2>.

      IF lr_attri2->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      
      lv_name10 = |MO_APP->{ lr_attri2->name }->*|.
      
      ASSIGN (lv_name10) TO <val8>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <val8>.
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
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the bound values are public attributes of your class or switch to bind_local`.

  ENDMETHOD.

  METHOD attri_get_val_ref.

    FIELD-SYMBOLS <attri> TYPE any.
      DATA lv_name TYPE string.

    IF iv_path IS INITIAL.
      ASSIGN mo_app TO <attri>.
    ELSE.
      
      lv_name = |MO_APP->{ iv_path }|.
      ASSIGN (lv_name) TO <attri>.
    ENDIF.

    IF <attri> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

    GET REFERENCE OF <attri> INTO result.
    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    DATA lo_datadescr TYPE REF TO cl_abap_typedescr.
    DATA temp84 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp84.
          DATA lr_ref TYPE REF TO data.
    lo_datadescr = cl_abap_datadescr=>describe_by_data_ref( val ).

    IF lo_datadescr->type_kind = cl_abap_typedescr=>typekind_dref
        OR lo_datadescr->type_kind = cl_abap_typedescr=>typekind_oref.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = |NO DATA REFERENCES FOR BINDING ALLOWED: DEREFERENCE YOUR DATA FIRST|.
    ENDIF.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = lo_datadescr->type_kind
               AND kind       = lo_datadescr->kind.

      IF lr_attri->o_typedescr <> lo_datadescr.
        CONTINUE.
      ENDIF.

      TRY.
          
          lr_ref = attri_get_val_ref( lr_attri->name ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.

      IF lr_ref = val.
        result = lr_attri.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD attri_create_new.

    DATA temp85 TYPE z2ui5_if_core_types=>ty_s_attri.
    CLEAR temp85.
    result = temp85.
    result-name        = name.
    result-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( attri_get_val_ref( name ) ).
    result-type_kind   = result-o_typedescr->type_kind.
    result-kind        = result-o_typedescr->kind.

  ENDMETHOD.

  METHOD diss_dref.

    DATA lr_ref_tmp TYPE REF TO data.
    DATA lr_ref TYPE REF TO data.
    DATA temp86 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_attri2 LIKE temp86.
        DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    lr_ref_tmp = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_util=>check_unassign_inital( lr_ref_tmp ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_data( lr_ref_tmp ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    
    CLEAR temp86.
    
    ls_attri2 = temp86.
    ls_attri2-o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref ).

    CASE ls_attri2-o_typedescr->kind.

      WHEN cl_abap_datadescr=>kind_struct.
        
        lt_attri = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.

        ls_attri2-name        = |{ ir_attri->name }->*|.
        ls_attri2-name_parent = ir_attri->name.
        ls_attri2-type_kind   = ls_attri2-o_typedescr->type_kind.
        ls_attri2-kind        = ls_attri2-o_typedescr->kind.
        INSERT ls_attri2 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.

  METHOD diss_oref.

    DATA lr_ref_tmp TYPE REF TO data.
    DATA lr_ref TYPE REF TO object.
    DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp87 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp87.
          DATA temp88 TYPE string.
          DATA lv_name TYPE string.
          DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_ref_tmp = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_util=>check_unassign_inital( lr_ref_tmp ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_object( lr_ref_tmp ).
    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_oref( lr_ref ).

    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri
         WHERE visibility   = cl_abap_objectdescr=>public
               AND is_interface = abap_false
               AND is_class     = abap_false
               AND is_constant  = abap_false.
      TRY.
          
          IF ir_attri->name IS NOT INITIAL.
            temp88 = |{ ir_attri->name }->|.
          ELSE.
            CLEAR temp88.
          ENDIF.
          
          lv_name = temp88 && lr_attri->name.
          
          ls_new = attri_create_new( lv_name ).
          ls_new-name_parent = ir_attri->name.
          INSERT ls_new INTO TABLE result.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD diss_struc.

    DATA lr_ref_tmp TYPE REF TO data.
      DATA lv_name TYPE string.
      DATA lr_ref TYPE REF TO data.
      DATA lt_attri TYPE abap_component_tab.
      DATA ls_attri LIKE LINE OF lt_attri.
        DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_ref_tmp = attri_get_val_ref( ir_attri->name ).

    IF ir_attri->o_typedescr->kind = cl_abap_typedescr=>kind_ref.
      
      lv_name = |{ ir_attri->name }->|.
      
      lr_ref = z2ui5_cl_util=>unassign_data( lr_ref_tmp ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = lr_ref_tmp.
    ENDIF.

    IF lr_ref IS BOUND.
      
      lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( lr_ref ).

      
      LOOP AT lt_attri INTO ls_attri.
        
        ls_new = attri_create_new( lv_name && ls_attri-name ).
        ls_new-name_parent = ir_attri->name.
        INSERT ls_new INTO TABLE result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD dissolve.

    DATA temp89 LIKE sy-subrc.
      DATA lv_check_update_refs LIKE abap_true.
    READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp89 = sy-subrc.
    WHILE temp89 = 0 OR mt_attri->* IS INITIAL. "#EC CI_SORTSEQ
      
      lv_check_update_refs = abap_true.

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

    DATA temp90 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp90.
          DATA lr_ref TYPE REF TO data.
          DATA temp91 LIKE LINE OF mt_attri->*.
          DATA lr_attri_ref LIKE REF TO temp91.
                DATA lr_attri_ref_ref TYPE REF TO data.
          FIELD-SYMBOLS <ref> TYPE data.
            DATA temp92 LIKE LINE OF mt_attri->*.
            DATA lr_attri_child LIKE REF TO temp92.
              DATA lv_name TYPE string.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE check_dissolved  = abap_true
               AND name_ref        IS INITIAL.

      TRY.
          
          lr_ref = attri_get_val_ref( lr_attri->name ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.

      CASE lr_attri->type_kind.

        WHEN cl_abap_typedescr=>typekind_table.

          
          
          LOOP AT mt_attri->* REFERENCE INTO lr_attri_ref "#EC CI_SORTSEQ
               WHERE check_dissolved  = abap_true
                     AND name            <> lr_attri->name
                     AND name_ref        IS INITIAL
                     AND type_kind        = cl_abap_typedescr=>typekind_table.

            TRY.
                
                lr_attri_ref_ref = attri_get_val_ref( lr_attri_ref->name ).
              CATCH cx_root.
                CONTINUE.
            ENDTRY.

            IF lr_ref <> lr_attri_ref_ref.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_attri_ref->name.
          ENDLOOP.

        WHEN cl_abap_typedescr=>typekind_dref.

          
          ASSIGN lr_ref->* TO <ref>.

          LOOP AT mt_attri->* REFERENCE INTO lr_attri_ref "#EC CI_SORTSEQ
               WHERE check_dissolved  = abap_true
                     AND name            <> lr_attri->name
                     AND name_ref        IS INITIAL
                     AND (    type_kind = cl_abap_typedescr=>typekind_struct1
                           OR type_kind = cl_abap_typedescr=>typekind_struct2 ).

            TRY.
                lr_attri_ref_ref = attri_get_val_ref( lr_attri_ref->name ).
              CATCH cx_root.
                CONTINUE.
            ENDTRY.

            IF <ref> <> lr_attri_ref_ref.
              CONTINUE.
            ENDIF.

            IF lr_attri->name_ref IS NOT INITIAL AND strlen( lr_attri->name_ref ) <= lr_attri_ref->name.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_attri_ref->name.

            
            
            LOOP AT mt_attri->* REFERENCE INTO lr_attri_child "#EC CI_SORTSEQ
                 WHERE name_parent = lr_attri->name.

              
              lv_name = shift_left( val = lr_attri_child->name
                                          sub = |{ lr_attri->name }->| ).
              lr_attri_child->name_ref = |{ lr_attri->name_ref }-{ lv_name }|.

            ENDLOOP.
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.
      DATA temp93 TYPE z2ui5_if_core_types=>ty_s_attri.
      DATA ls_attri LIKE temp93.
      DATA temp94 LIKE REF TO ls_attri.
DATA lt_init TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp95 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri_new LIKE temp95.
    DATA temp96 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp96.
        DATA ls_entry TYPE z2ui5_if_core_types=>ty_s_attri.
          DATA lt_attri_struc TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_oref TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_dref TYPE z2ui5_if_core_types=>ty_t_attri.

    IF mt_attri->* IS INITIAL.
      
      CLEAR temp93.
      
      ls_attri = temp93.
      
      GET REFERENCE OF ls_attri INTO temp94.

lt_init = diss_oref( temp94 ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.

    
    CLEAR temp95.
    
    lt_attri_new = temp95.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.
        
        ls_entry = attri_create_new( lr_attri->name ).
        lr_attri->o_typedescr = ls_entry-o_typedescr.
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

  METHOD main_attri_refresh.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp97 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp97.
      DATA lv_name LIKE lr_attri->name.
      DATA temp98 LIKE sy-subrc.
        DATA temp99 LIKE LINE OF lt_attri.
        DATA temp100 LIKE sy-tabix.
        DATA temp101 LIKE LINE OF lt_attri.
        DATA temp102 LIKE sy-tabix.
        DATA temp103 LIKE LINE OF lt_attri.
        DATA temp104 LIKE sy-tabix.
    lt_attri = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL. "#EC CI_SORTSEQ
    CLEAR mt_attri->*.

    dissolve( ).

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri.
      
      lv_name = lr_attri->name.
      
      READ TABLE lt_attri WITH KEY name = lv_name TRANSPORTING NO FIELDS.
      temp98 = sy-subrc.
      IF temp98 = 0.
        
        
        temp100 = sy-tabix.
        READ TABLE lt_attri WITH KEY name = lv_name INTO temp99.
        sy-tabix = temp100.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lr_attri->bind_type   = temp99-bind_type.
        
        
        temp102 = sy-tabix.
        READ TABLE lt_attri WITH KEY name = lv_name INTO temp101.
        sy-tabix = temp102.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lr_attri->name_client = temp101-name_client.
        
        
        temp104 = sy-tabix.
        READ TABLE lt_attri WITH KEY name = lv_name INTO temp103.
        sy-tabix = temp104.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lr_attri->view        = temp103-view.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
