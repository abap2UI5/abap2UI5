CLASS z2ui5_cl_core_srv_model DEFINITION PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_s_child_idx,
             name_parent TYPE string,
             name        TYPE string,
           END OF ty_s_child_idx.
    TYPES ty_t_child_idx TYPE SORTED TABLE OF ty_s_child_idx WITH NON-UNIQUE KEY name_parent.

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
    METHODS main_attri_db_load_resolve.

    METHODS main_attri_db_load_table
      IMPORTING
        ir_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

    METHODS main_attri_db_load_dref
      IMPORTING
        ir_attri     TYPE REF TO z2ui5_if_core_types=>ty_s_attri
        ir_child_idx TYPE REF TO ty_t_child_idx.
    METHODS main_attri_refresh.

    METHODS main_json_to_attri
      IMPORTING
        view  TYPE string
        model TYPE REF TO z2ui5_if_ajson.

    METHODS main_json_stringify
      RETURNING
        VALUE(result) TYPE string ##NEEDED.



    CONSTANTS max_dissolve_depth TYPE i VALUE 5.

    DATA mt_attri TYPE REF TO z2ui5_if_core_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    METHODS attri_update_entry_refs.
    METHODS attri_update_refs_children
      IMPORTING
        ir_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri.

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

    METHODS delta_apply_to_table
      IMPORTING
        io_val_front TYPE REF TO z2ui5_if_ajson
        iv_name      TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_core_srv_model IMPLEMENTATION.

  METHOD main_json_to_attri.

    DATA temp202 LIKE sy-subrc.
      DATA lv_view LIKE view.
    DATA temp203 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp203.
          DATA lo_val_front TYPE REF TO z2ui5_if_ajson.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
          DATA x TYPE REF TO cx_root.
    READ TABLE mt_attri->* WITH KEY view = view TRANSPORTING NO FIELDS.
    temp202 = sy-subrc.
    IF temp202 = 0.       "#EC CI_SORTSEQ
      
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

          IF lo_val_front->exists( `/__delta` ) = abap_true.
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
            EXPORTING
              val = |JSON_PARSING_ERROR: { x->get_text( ) } |.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_json_stringify.
        DATA temp204 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp204.
        DATA lo_upper_mapper TYPE REF TO z2ui5_if_ajson_mapping.
        DATA temp205 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_default LIKE temp205.
TYPES BEGIN OF ty_s_mapper_cache.
TYPES mapper TYPE REF TO z2ui5_if_ajson_mapping.
TYPES ajson TYPE REF TO z2ui5_if_ajson.
TYPES END OF ty_s_mapper_cache.
        DATA lt_mapper_cache TYPE STANDARD TABLE OF ty_s_mapper_cache WITH DEFAULT KEY.
        DATA temp206 LIKE LINE OF mt_attri->*.
        DATA lr_attri LIKE REF TO temp206.
            DATA lr_mapper_cache TYPE REF TO ty_s_mapper_cache.
              DATA ajson LIKE lr_mapper_cache->ajson.
              DATA temp207 TYPE REF TO z2ui5_if_ajson.
              DATA temp208 TYPE ty_s_mapper_cache.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
        DATA temp209 TYPE string.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp204 ?= z2ui5_cl_ajson=>create_empty( ).
        
        ajson_result = temp204.
        
        lo_upper_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
        
        temp205 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lo_upper_mapper ).
        
        ajson_default = temp205.

        
        

        
        
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
              
              temp207 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lr_attri->custom_mapper ).
              ajson = temp207.
              
              CLEAR temp208.
              temp208-mapper = lr_attri->custom_mapper.
              temp208-ajson = ajson.
              INSERT temp208 INTO TABLE lt_mapper_cache.
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
          temp209 = `{}`.
        ELSE.
          temp209 = result.
        ENDIF.
        result = temp209.

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD main_attri_db_load.
    DATA lt_child_idx TYPE ty_t_child_idx.
    DATA temp210 LIKE LINE OF mt_attri->*.
    DATA lr_pre LIKE REF TO temp210.
      DATA temp211 TYPE z2ui5_cl_core_srv_model=>ty_s_child_idx.
    DATA temp212 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp212.
          DATA temp213 LIKE REF TO lt_child_idx.

    main_attri_db_load_resolve( ).

    
    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_pre     "#EC CI_SORTSEQ
         WHERE name_parent IS NOT INITIAL.
      
      CLEAR temp211.
      temp211-name_parent = lr_pre->name_parent.
      temp211-name = lr_pre->name.
      INSERT temp211 INTO TABLE lt_child_idx.
    ENDLOOP.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
         WHERE name_ref IS NOT INITIAL.
      CASE lr_attri->type_kind.
        WHEN cl_abap_datadescr=>typekind_table.
          main_attri_db_load_table( lr_attri ).
        WHEN cl_abap_datadescr=>typekind_dref.
          
          GET REFERENCE OF lt_child_idx INTO temp213.
main_attri_db_load_dref( ir_attri     = lr_attri
                                   ir_child_idx = temp213 ).
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_load_resolve.

    DATA temp214 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp214.
          DATA lr_ref TYPE REF TO data.
            FIELD-SYMBOLS <val> TYPE data.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
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

  ENDMETHOD.

  METHOD main_attri_db_load_table.

    DATA lr_ref_source TYPE REF TO data.
    DATA lr_attri_parent TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lv_parent_path TYPE string.
    FIELD-SYMBOLS <parent_ref> TYPE any.
    FIELD-SYMBOLS <source_value> TYPE data.
    DATA lr_ref_parent TYPE REF TO data.
    lr_ref_source = attri_get_val_ref( ir_attri->name_ref ).
    ir_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref_source ).

    
    READ TABLE mt_attri->* REFERENCE INTO lr_attri_parent
         WITH KEY name = ir_attri->name_parent.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    
    lv_parent_path = |MO_APP->{ lr_attri_parent->name }|.
    
    ASSIGN (lv_parent_path) TO <parent_ref>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    
    ASSIGN lr_ref_source->* TO <source_value>.
    GET REFERENCE OF <source_value> INTO <parent_ref>.

    
GET REFERENCE OF <parent_ref> INTO lr_ref_parent.
    lr_attri_parent->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_ref_parent ).

  ENDMETHOD.

  METHOD main_attri_db_load_dref.

    DATA lv_source_path TYPE string.
    FIELD-SYMBOLS <source_ref> TYPE any.
    DATA lv_target_path TYPE string.
    FIELD-SYMBOLS <parent_ref> TYPE any.
    DATA temp215 LIKE LINE OF ir_child_idx->*.
    DATA lr_child_idx LIKE REF TO temp215.
      DATA lr_child TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
      DATA lr_child_ref TYPE REF TO data.
    lv_source_path = |MO_APP->{ ir_attri->name_ref }|.
    
    ASSIGN (lv_source_path) TO <source_ref>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    
    lv_target_path = |MO_APP->{ ir_attri->name }|.
    
    ASSIGN (lv_target_path) TO <parent_ref>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    GET REFERENCE OF <source_ref> INTO <parent_ref>.
    ir_attri->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( <parent_ref> ).

    
    
    LOOP AT ir_child_idx->* REFERENCE INTO lr_child_idx
         WHERE name_parent = ir_attri->name.
      
      READ TABLE mt_attri->* REFERENCE INTO lr_child
           WITH KEY name = lr_child_idx->name.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lr_child_ref = attri_get_val_ref( lr_child->name ).
      lr_child->o_typedescr = cl_abap_datadescr=>describe_by_data_ref( lr_child_ref ).
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.
    DATA temp216 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp216.
      DATA lv_name5 TYPE string.
      FIELD-SYMBOLS <ref> TYPE any.
      DATA lv_name TYPE string.
      FIELD-SYMBOLS <val1> TYPE any.
      DATA lo_descr TYPE REF TO cl_abap_typedescr.
          DATA temp217 LIKE LINE OF mt_attri->*.
          DATA lr_attri_child LIKE REF TO temp217.
            DATA lv_name6 TYPE string.
            FIELD-SYMBOLS <val_ref> TYPE any.
    DATA temp218 LIKE LINE OF mt_attri->*.
    DATA lr_attri2 LIKE REF TO temp218.
      DATA lv_name8 TYPE string.
      FIELD-SYMBOLS <ref2> TYPE any.
      DATA lv_name10 TYPE string.
      FIELD-SYMBOLS <val8> TYPE any.

    dissolve( ).

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
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

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri2  "#EC CI_SORTSEQ
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
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the bound values are public attributes of your class`.

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
        EXPORTING
          val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

    GET REFERENCE OF <attri> INTO result.
    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    DATA lo_datadescr TYPE REF TO cl_abap_typedescr.
    DATA temp219 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp219.
          DATA lr_ref TYPE REF TO data.
    lo_datadescr = cl_abap_datadescr=>describe_by_data_ref( val ).

    IF lo_datadescr->type_kind = cl_abap_typedescr=>typekind_dref
        OR lo_datadescr->type_kind = cl_abap_typedescr=>typekind_oref.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = |NO DATA REFERENCES FOR BINDING ALLOWED: DEREFERENCE YOUR DATA FIRST|.
    ENDIF.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
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
    DATA temp220 TYPE z2ui5_if_core_types=>ty_s_attri.
    lo_descr = cl_abap_datadescr=>describe_by_data_ref( attri_get_val_ref( name ) ).
    
    CLEAR temp220.
    temp220-name = name.
    temp220-o_typedescr = lo_descr.
    temp220-type_kind = lo_descr->type_kind.
    temp220-kind = lo_descr->kind.
    result = temp220.

  ENDMETHOD.

  METHOD diss_dref.

    DATA lr_ref_tmp TYPE REF TO data.
    DATA lr_ref TYPE REF TO data.
    DATA temp221 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_attri2 LIKE temp221.
        DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    lr_ref_tmp = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_util=>check_unassign_initial( lr_ref_tmp ) IS NOT INITIAL.
      RETURN.
    ENDIF.

    
    lr_ref = z2ui5_cl_util=>unassign_data( lr_ref_tmp ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    
    CLEAR temp221.
    
    ls_attri2 = temp221.
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

    DATA lr_val TYPE REF TO data.
    DATA lr_ref TYPE REF TO object.
    DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp222 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp222.
          DATA temp223 TYPE string.
          DATA lv_name TYPE string.
          DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_val = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_util=>check_unassign_initial( lr_val ) IS NOT INITIAL.
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
            temp223 = |{ ir_attri->name }->|.
          ELSE.
            CLEAR temp223.
          ENDIF.
          
          lv_name = temp223 && lr_attri->name.
          
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

    DATA temp224 LIKE sy-subrc.
    READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp224 = sy-subrc.
    WHILE temp224 = 0 OR mt_attri->* IS INITIAL. "#EC CI_SORTSEQ

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

    DATA temp225 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp225.
          DATA lr_ref TYPE REF TO data.
          DATA temp226 LIKE LINE OF mt_attri->*.
          DATA lr_attri_ref LIKE REF TO temp226.
                DATA lr_attri_ref_ref TYPE REF TO data.
          FIELD-SYMBOLS <ref> TYPE data.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
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

            IF lr_attri->name_ref IS NOT INITIAL AND strlen( lr_attri->name_ref ) <= strlen( lr_attri_ref->name ).
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_attri_ref->name.
            attri_update_refs_children( lr_attri ).
          ENDLOOP.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD attri_update_refs_children.

    DATA temp227 LIKE LINE OF mt_attri->*.
    DATA lr_attri_child LIKE REF TO temp227.
      DATA lv_name TYPE string.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri_child "#EC CI_SORTSEQ
         WHERE name_parent = ir_attri->name.
      
      lv_name = shift_left( val = lr_attri_child->name
                                  sub = |{ ir_attri->name }->| ).
      lr_attri_child->name_ref = |{ ir_attri->name_ref }-{ lv_name }|.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.
      DATA temp228 TYPE z2ui5_if_core_types=>ty_s_attri.
      DATA ls_attri LIKE temp228.
      DATA temp229 LIKE REF TO ls_attri.
DATA lt_init TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp230 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri_new LIKE temp230.
    DATA temp231 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp231.
        DATA ls_entry TYPE z2ui5_if_core_types=>ty_s_attri.
          DATA lt_attri_struc TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_oref TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_dref TYPE z2ui5_if_core_types=>ty_t_attri.

    IF mt_attri->* IS INITIAL.
      
      CLEAR temp228.
      
      ls_attri = temp228.
      
      GET REFERENCE OF ls_attri INTO temp229.

lt_init = diss_oref( temp229 ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.

    
    CLEAR temp230.
    
    lt_attri_new = temp230.

    
    
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
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
    DATA temp232 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp232.
      DATA lr_old TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    lt_attri = mt_attri->*.
    DELETE lt_attri WHERE bind_type IS INITIAL.         "#EC CI_SORTSEQ
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
      DATA temp233 TYPE i.
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

    
    lo_delta = io_val_front->slice( `/__delta` ).
    
    lt_idx = lo_delta->members( `/` ).
    
    LOOP AT lt_idx INTO lv_idx_str.
      
      temp233 = lv_idx_str.
      
      lv_tabix = temp233 + 1.
      
      READ TABLE <delta_tab> INDEX lv_tabix ASSIGNING <delta_row>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      
      lo_row_d = lo_delta->slice( |/{ lv_idx_str }| ).
      
      lt_fld = lo_row_d->members( `/` ).
      
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
