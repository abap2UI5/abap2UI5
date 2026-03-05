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
    CONSTANTS max_dissolve_depth TYPE i VALUE 5.

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
    METHODS delta_apply_to_table
      IMPORTING
        io_val_front TYPE REF TO z2ui5_if_ajson
        iv_name      TYPE string.
ENDCLASS.


CLASS z2ui5_cl_core_srv_model IMPLEMENTATION.

  METHOD main_json_to_attri.

    DATA temp129 LIKE sy-subrc.
      DATA lv_view LIKE view.
    DATA temp130 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp130.
          DATA lo_val_front TYPE REF TO z2ui5_if_ajson.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
          DATA x TYPE REF TO cx_root.
    READ TABLE mt_attri->* WITH KEY view = view TRANSPORTING NO FIELDS.
    temp129 = sy-subrc.
    IF temp129 = 0. "#EC CI_SORTSEQ
      
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

          IF lo_val_front->exists( '/__delta' ) = abap_true.
            delta_apply_to_table( io_val_front = lo_val_front
                                  iv_name      = lr_attri->name ).
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
        DATA temp131 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp131.
        DATA lo_upper_mapper TYPE REF TO z2ui5_if_ajson_mapping.
        DATA temp132 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_default LIKE temp132.
TYPES BEGIN OF ty_s_mapper_cache.
TYPES mapper TYPE REF TO z2ui5_if_ajson_mapping.
TYPES ajson TYPE REF TO z2ui5_if_ajson.
TYPES END OF ty_s_mapper_cache.
        DATA lt_mapper_cache TYPE STANDARD TABLE OF ty_s_mapper_cache WITH DEFAULT KEY.
        DATA temp133 LIKE LINE OF mt_attri->*.
        DATA lr_attri LIKE REF TO temp133.
            DATA lr_mapper_cache TYPE REF TO ty_s_mapper_cache.
              DATA ajson LIKE lr_mapper_cache->ajson.
              DATA temp134 TYPE REF TO z2ui5_if_ajson.
              DATA temp135 TYPE ty_s_mapper_cache.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
        DATA temp136 TYPE string.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp131 ?= z2ui5_cl_ajson=>create_empty( ).
        
        ajson_result = temp131.
        
        lo_upper_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
        
        temp132 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lo_upper_mapper ).
        
        ajson_default = temp132.

        
        

        
        
        LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
             WHERE bind_type <> ``
                   AND type_kind <> cl_abap_datadescr=>typekind_dref
                   AND type_kind <> cl_abap_datadescr=>typekind_oref.

          IF lr_attri->custom_mapper IS BOUND.
            
            READ TABLE lt_mapper_cache REFERENCE INTO lr_mapper_cache
                 WITH KEY mapper = lr_attri->custom_mapper. "#EC CI_SORTSEQ
            IF sy-subrc = 0.
              
              ajson = lr_mapper_cache->ajson.
            ELSE.
              
              temp134 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lr_attri->custom_mapper ).
              ajson = temp134.
              
              CLEAR temp135.
              temp135-mapper = lr_attri->custom_mapper.
              temp135-ajson = ajson.
              INSERT temp135 INTO TABLE lt_mapper_cache.
            ENDIF.
          ELSE.
            ajson = ajson_default.
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
          temp136 = `{}`.
        ELSE.
          temp136 = result.
        ENDIF.
        result = temp136.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD main_attri_db_load.

    DATA temp137 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp137.
          DATA lr_ref TYPE REF TO data.
            FIELD-SYMBOLS <val> TYPE data.
TYPES BEGIN OF ty_s_child_idx.
TYPES name_parent TYPE string.
TYPES name TYPE string.
TYPES END OF ty_s_child_idx.
    DATA lt_child_idx TYPE SORTED TABLE OF ty_s_child_idx WITH NON-UNIQUE KEY name_parent.
    DATA temp138 LIKE LINE OF mt_attri->*.
    DATA lr_pre LIKE REF TO temp138.
      DATA temp139 TYPE ty_s_child_idx.
          DATA lr_ref_source TYPE REF TO data.
          DATA lr_attri_parent TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
          DATA lv_parent_path TYPE string.
          FIELD-SYMBOLS <parent_ref> TYPE any.
          FIELD-SYMBOLS <source_value> TYPE data.
          DATA lr_ref_parent TYPE REF TO data.
          DATA lv_source_path TYPE string.
          FIELD-SYMBOLS <source_ref> TYPE any.
          DATA lv_target_path TYPE string.
          DATA temp140 LIKE LINE OF lt_child_idx.
          DATA lr_child_idx LIKE REF TO temp140.
            DATA lr_child TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
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

    
    

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_pre "#EC CI_SORTSEQ
         WHERE name_parent IS NOT INITIAL.
      
      CLEAR temp139.
      temp139-name_parent = lr_pre->name_parent.
      temp139-name = lr_pre->name.
      INSERT temp139 INTO TABLE lt_child_idx.
    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name_ref IS NOT INITIAL.

      CASE lr_attri->type_kind.

        WHEN cl_abap_datadescr=>typekind_table.

          
          lr_ref_source = attri_get_val_ref( lr_attri->name_ref ).
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref_source ).

          
          READ TABLE mt_attri->* REFERENCE INTO lr_attri_parent
               WITH KEY name = lr_attri->name_parent.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          
          lv_parent_path = |MO_APP->{ lr_attri_parent->name }|.
          
          ASSIGN (lv_parent_path) TO <parent_ref>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          
          ASSIGN lr_ref_source->* TO <source_value>.
          GET REFERENCE OF <source_value> INTO <parent_ref>.

          
GET REFERENCE OF <parent_ref> INTO lr_ref_parent.
          lr_attri_parent->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref_parent ).

        WHEN cl_abap_datadescr=>typekind_dref.

          
          lv_source_path = |MO_APP->{ lr_attri->name_ref }|.
          
          ASSIGN (lv_source_path) TO <source_ref>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          
          lv_target_path = |MO_APP->{ lr_attri->name }|.
          ASSIGN (lv_target_path) TO <parent_ref>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          GET REFERENCE OF <source_ref> INTO <parent_ref>.
          lr_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( <parent_ref> ).

          
          
          LOOP AT lt_child_idx REFERENCE INTO lr_child_idx
               WHERE name_parent = lr_attri->name.
            
            READ TABLE mt_attri->* REFERENCE INTO lr_child
                 WITH KEY name = lr_child_idx->name.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            
            lr_child_ref = attri_get_val_ref( lr_child->name ).
            lr_child->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_child_ref ).
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.
    DATA temp141 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp141.
      DATA lv_dref_path TYPE string.
      FIELD-SYMBOLS <dref> TYPE any.
      DATA lv_deref_path TYPE string.
      FIELD-SYMBOLS <dref_value> TYPE any.
      DATA lo_descr TYPE REF TO cl_abap_typedescr.
          DATA temp142 LIKE LINE OF mt_attri->*.
          DATA lr_attri_child LIKE REF TO temp142.
            DATA lv_child_path TYPE string.
            FIELD-SYMBOLS <child_table> TYPE any.
    DATA temp143 LIKE LINE OF mt_attri->*.
    DATA lr_dref_attri LIKE REF TO temp143.
      DATA lv_clear_path TYPE string.
      FIELD-SYMBOLS <clear_ref> TYPE any.
      DATA lv_clear_deref_path TYPE string.
      FIELD-SYMBOLS <clear_value> TYPE any.

    dissolve( ).

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = cl_abap_datadescr=>typekind_dref.

      
      lv_dref_path = |MO_APP->{ lr_attri->name }|.
      
      ASSIGN (lv_dref_path) TO <dref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lv_deref_path = |MO_APP->{ lr_attri->name }->*|.
      
      ASSIGN (lv_deref_path) TO <dref_value>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lo_descr = cl_abap_datadescr=>describe_by_data( <dref_value> ).

      CASE lo_descr->type_kind.

        WHEN cl_abap_datadescr=>typekind_table.

          
          
          LOOP AT mt_attri->* REFERENCE INTO lr_attri_child "#EC CI_SORTSEQ
               WHERE name_ref    IS INITIAL
                     AND type_kind    = cl_abap_datadescr=>typekind_table
                     AND name_parent  = lr_attri->name.

            
            lv_child_path = |MO_APP->{ lr_attri_child->name }|.
            
            ASSIGN (lv_child_path) TO <child_table>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <child_table> ).
            CLEAR <child_table>.
            CLEAR <dref_value>.
            CLEAR <dref>.
            EXIT.
          ENDLOOP.

        WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
          lr_attri->srtti_data = z2ui5_cl_util=>xml_srtti_stringify( <dref_value> ).

      ENDCASE.

    ENDLOOP.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_dref_attri "#EC CI_SORTSEQ
         WHERE type_kind = cl_abap_datadescr=>typekind_dref.

      
      lv_clear_path = |MO_APP->{ lr_dref_attri->name }|.
      
      ASSIGN (lv_clear_path) TO <clear_ref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <clear_ref>.

      IF lr_dref_attri->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      
      lv_clear_deref_path = |MO_APP->{ lr_dref_attri->name }->*|.
      
      ASSIGN (lv_clear_deref_path) TO <clear_value>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <clear_value>.
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
    DATA temp144 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp144.
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

    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA temp145 TYPE z2ui5_if_core_types=>ty_s_attri.
    lo_descr = cl_abap_datadescr=>describe_by_data_ref( attri_get_val_ref( name ) ).
    
    CLEAR temp145.
    temp145-name = name.
    temp145-o_typedescr = lo_descr.
    temp145-type_kind = lo_descr->type_kind.
    temp145-kind = lo_descr->kind.
    result = temp145.

  ENDMETHOD.

  METHOD diss_dref.

    DATA lr_val TYPE REF TO data.
    DATA lr_ref TYPE REF TO data.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
        DATA temp146 TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_val = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_util=>check_unassign_inital( lr_val ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_data( lr_val ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    
    lo_descr = cl_abap_datadescr=>describe_by_data_ref( lr_ref ).

    CASE lo_descr->kind.

      WHEN cl_abap_datadescr=>kind_struct.
        
        lt_attri = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.
        
        CLEAR temp146.
        temp146-name = |{ ir_attri->name }->*|.
        temp146-name_parent = ir_attri->name.
        temp146-o_typedescr = lo_descr.
        temp146-type_kind = lo_descr->type_kind.
        temp146-kind = lo_descr->kind.
        INSERT temp146 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.

  METHOD diss_oref.

    DATA lr_val TYPE REF TO data.
    DATA lr_ref TYPE REF TO object.
    DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp147 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp147.
          DATA temp148 TYPE string.
          DATA lv_name TYPE string.
          DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_val = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_util=>check_unassign_inital( lr_val ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_object( lr_val ).
    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_oref( lr_ref ).

    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri
         WHERE visibility   = cl_abap_objectdescr=>public
               AND is_interface = abap_false
               AND is_class     = abap_false
               AND is_constant  = abap_false.
      TRY.
          
          IF ir_attri->name IS NOT INITIAL.
            temp148 = |{ ir_attri->name }->|.
          ELSE.
            CLEAR temp148.
          ENDIF.
          
          lv_name = temp148 && lr_attri->name.
          
          ls_new = attri_create_new( lv_name ).
          ls_new-name_parent = ir_attri->name.
          INSERT ls_new INTO TABLE result.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD diss_struc.

    DATA lr_val TYPE REF TO data.
      DATA lv_name TYPE string.
      DATA lr_ref TYPE REF TO data.
      DATA lt_attri TYPE abap_component_tab.
      DATA ls_attri LIKE LINE OF lt_attri.
        DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_val = attri_get_val_ref( ir_attri->name ).

    IF ir_attri->o_typedescr->kind = cl_abap_typedescr=>kind_ref.
      
      lv_name = |{ ir_attri->name }->|.
      
      lr_ref = z2ui5_cl_util=>unassign_data( lr_val ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = lr_val.
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

    DATA temp149 LIKE sy-subrc.
    READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp149 = sy-subrc.
    WHILE temp149 = 0 OR mt_attri->* IS INITIAL. "#EC CI_SORTSEQ

      IF sy-index = max_dissolve_depth.
        RETURN.
      ENDIF.

      TRY.
          dissolve_run( ).
        CATCH cx_root.
          main_attri_refresh( ).
      ENDTRY.

    ENDWHILE.

    attri_update_entry_refs( ).

  ENDMETHOD.

  METHOD attri_update_entry_refs.

    TYPES: BEGIN OF ty_s_ref_cache,
             name      TYPE string,
             ref       TYPE REF TO data,
             type_kind TYPE string,
           END OF ty_s_ref_cache.
    DATA lt_ref_cache TYPE SORTED TABLE OF ty_s_ref_cache WITH UNIQUE KEY name.
    DATA lt_tables TYPE STANDARD TABLE OF ty_s_ref_cache WITH DEFAULT KEY.
    DATA lt_structs TYPE STANDARD TABLE OF ty_s_ref_cache WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_s_child_entry,
             name_parent TYPE string,
             name        TYPE string,
           END OF ty_s_child_entry.
    DATA lt_children TYPE SORTED TABLE OF ty_s_child_entry WITH NON-UNIQUE KEY name_parent.

    DATA temp150 LIKE LINE OF mt_attri->*.
    DATA lr_pre LIKE REF TO temp150.
          DATA temp151 TYPE ty_s_ref_cache.
          DATA ls_entry LIKE temp151.
      DATA temp152 TYPE ty_s_child_entry.
    DATA temp153 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp153.
      DATA lr_cache TYPE REF TO ty_s_ref_cache.
      DATA lr_ref LIKE lr_cache->ref.
          DATA temp154 LIKE LINE OF lt_tables.
          DATA lr_tbl_entry LIKE REF TO temp154.
          FIELD-SYMBOLS <ref> TYPE data.
          DATA temp155 LIKE LINE OF lt_structs.
          DATA lr_struct_entry LIKE REF TO temp155.
            DATA lv_parent_prefix TYPE string.
            DATA temp156 LIKE LINE OF lt_children.
            DATA lr_child_entry LIKE REF TO temp156.
              DATA lr_attri_child TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
              DATA lv_name TYPE string.
    LOOP AT mt_attri->* REFERENCE INTO lr_pre "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_true
               AND name_ref IS INITIAL.
      TRY.
          
          CLEAR temp151.
          temp151-name = lr_pre->name.
          temp151-ref = attri_get_val_ref( lr_pre->name ).
          temp151-type_kind = lr_pre->type_kind.
          
          ls_entry = temp151.
          INSERT ls_entry INTO TABLE lt_ref_cache.
          CASE lr_pre->type_kind.
            WHEN cl_abap_typedescr=>typekind_table.
              INSERT ls_entry INTO TABLE lt_tables.
            WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2.
              INSERT ls_entry INTO TABLE lt_structs.
          ENDCASE.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO lr_pre "#EC CI_SORTSEQ
         WHERE name_parent IS NOT INITIAL.
      
      CLEAR temp152.
      temp152-name_parent = lr_pre->name_parent.
      temp152-name = lr_pre->name.
      INSERT temp152 INTO TABLE lt_children.
    ENDLOOP.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE check_dissolved  = abap_true
               AND name_ref        IS INITIAL.

      
      READ TABLE lt_ref_cache REFERENCE INTO lr_cache WITH KEY name = lr_attri->name.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lr_ref = lr_cache->ref.

      CASE lr_attri->type_kind.

        WHEN cl_abap_typedescr=>typekind_table.

          
          
          LOOP AT lt_tables REFERENCE INTO lr_tbl_entry
               WHERE name <> lr_attri->name.

            IF lr_ref <> lr_tbl_entry->ref.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_tbl_entry->name.
          ENDLOOP.

        WHEN cl_abap_typedescr=>typekind_dref.

          
          ASSIGN lr_ref->* TO <ref>.

          
          
          LOOP AT lt_structs REFERENCE INTO lr_struct_entry
               WHERE name <> lr_attri->name.

            IF <ref> <> lr_struct_entry->ref.
              CONTINUE.
            ENDIF.

            IF lr_attri->name_ref IS NOT INITIAL AND strlen( lr_attri->name_ref ) <= lr_struct_entry->name.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_struct_entry->name.

            
            lv_parent_prefix = |{ lr_attri->name }->|.

            
            
            LOOP AT lt_children REFERENCE INTO lr_child_entry
                 WHERE name_parent = lr_attri->name.

              
              READ TABLE mt_attri->* REFERENCE INTO lr_attri_child
                   WITH KEY name = lr_child_entry->name.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              
              lv_name = shift_left( val = lr_attri_child->name
                                          sub = lv_parent_prefix ).
              lr_attri_child->name_ref = |{ lr_attri->name_ref }-{ lv_name }|.

            ENDLOOP.
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.
      DATA temp157 TYPE z2ui5_if_core_types=>ty_s_attri.
      DATA ls_attri LIKE temp157.
      DATA temp158 LIKE REF TO ls_attri.
DATA lt_init TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp159 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri_new LIKE temp159.
    DATA temp160 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp160.
          DATA lt_attri_struc TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_oref TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_dref TYPE z2ui5_if_core_types=>ty_t_attri.

    IF mt_attri->* IS INITIAL.
      
      CLEAR temp157.
      
      ls_attri = temp157.
      
      GET REFERENCE OF ls_attri INTO temp158.

lt_init = diss_oref( temp158 ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.

    
    CLEAR temp159.
    
    lt_attri_new = temp159.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.
        lr_attri->o_typedescr = attri_create_new( lr_attri->name )-o_typedescr.
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
              RAISE EXCEPTION TYPE z2ui5_cx_util_error
                EXPORTING val = `DISSOLVE_ERROR - Unexpected type_kind for reference type`.
          ENDCASE.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD main_attri_refresh.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp161 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp161.
      DATA lr_old TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    lt_attri = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL. "#EC CI_SORTSEQ
    CLEAR mt_attri->*.

    dissolve( ).

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri.
      
      READ TABLE lt_attri REFERENCE INTO lr_old WITH KEY name = lr_attri->name. "#EC CI_SORTSEQ
      IF sy-subrc = 0.
        lr_attri->bind_type   = lr_old->bind_type.
        lr_attri->name_client = lr_old->name_client.
        lr_attri->view        = lr_old->view.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_apply_to_table.
        DATA lr_ref_d TYPE REF TO data.
    FIELD-SYMBOLS <delta_tab> TYPE STANDARD TABLE.
    DATA lo_delta TYPE REF TO z2ui5_if_ajson.
    DATA lt_idx TYPE string_table.
    DATA lv_idx_str LIKE LINE OF lt_idx.
      DATA temp162 TYPE i.
      DATA lv_tabix TYPE i.
      FIELD-SYMBOLS <delta_row> TYPE any.
      DATA lo_row_d TYPE REF TO z2ui5_if_ajson.
      DATA lt_fld TYPE string_table.
      DATA lv_fld LIKE LINE OF lt_fld.
        FIELD-SYMBOLS <comp> TYPE any.

    TRY.
        
        lr_ref_d = attri_get_val_ref( iv_name ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    
    ASSIGN lr_ref_d->* TO <delta_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    
    lo_delta = io_val_front->slice( '/__delta' ).
    
    lt_idx = lo_delta->members( '/' ).
    
    LOOP AT lt_idx INTO lv_idx_str.
      
      temp162 = lv_idx_str.
      
      lv_tabix = temp162 + 1.
      
      READ TABLE <delta_tab> INDEX lv_tabix ASSIGNING <delta_row>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lo_row_d = lo_delta->slice( |/{ lv_idx_str }| ).
      
      lt_fld = lo_row_d->members( '/' ).
      
      LOOP AT lt_fld INTO lv_fld.
        
        ASSIGN COMPONENT lv_fld OF STRUCTURE <delta_row> TO <comp>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF lo_row_d->get_node_type( |/{ lv_fld }| ) = z2ui5_if_ajson_types=>node_type-boolean.
          <comp> = lo_row_d->get_boolean( |/{ lv_fld }| ).
        ELSE.
          <comp> = lo_row_d->get_string( |/{ lv_fld }| ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
