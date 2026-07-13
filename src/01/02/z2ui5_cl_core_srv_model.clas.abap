CLASS z2ui5_cl_core_srv_model DEFINITION PUBLIC FINAL.

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
        iv_name      TYPE string
      RAISING
        z2ui5_cx_ajson_error.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS delta_apply_nodes
      IMPORTING
        io_delta TYPE REF TO z2ui5_if_ajson
      CHANGING
        ct_tab   TYPE STANDARD TABLE
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_core_srv_model IMPLEMENTATION.

  METHOD main_json_to_attri.

    DATA(lv_view) = COND #( WHEN line_exists( mt_attri->*[ view = view ] ) "#EC CI_SORTSEQ
                            THEN view
                            ELSE z2ui5_if_client=>cs_view-main ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE bind_type = z2ui5_if_core_types=>cs_bind_type-two_way "#EC CI_SORTSEQ
               AND view      = lv_view.
      TRY.

          DATA(lo_val_front) = model->slice( lr_attri->name_client ).
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
              DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).

          lo_val_front->to_abap( EXPORTING iv_corresponding = abap_true
                                 IMPORTING ev_container     = <val> ).

        CATCH cx_root INTO DATA(x).
          RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
            EXPORTING
              val = |JSON_PARSING_ERROR: { x->get_text( ) }|.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_json_stringify.
    TRY.

        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        DATA(ajson_default) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                       ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

        TYPES: BEGIN OF ty_s_mapper_cache,
                 mapper TYPE REF TO z2ui5_if_ajson_mapping,
                 ajson  TYPE REF TO z2ui5_if_ajson,
               END OF ty_s_mapper_cache.
        DATA lt_mapper_cache TYPE STANDARD TABLE OF ty_s_mapper_cache WITH EMPTY KEY.

        LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
             WHERE bind_type <> ``
                   AND type_kind <> z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref
                   AND type_kind <> z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.

          IF lr_attri->custom_mapper IS BOUND.
            READ TABLE lt_mapper_cache REFERENCE INTO DATA(lr_mapper_cache)
                 WITH KEY mapper = lr_attri->custom_mapper. "#EC CI_SORTSEQ
            IF sy-subrc = 0.
              DATA(ajson) = lr_mapper_cache->ajson.
            ELSE.
              ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                                   ii_custom_mapping = lr_attri->custom_mapper ) ).
              INSERT VALUE #( mapper = lr_attri->custom_mapper
                              ajson  = ajson ) INTO TABLE lt_mapper_cache.
            ENDIF.
          ELSE.
            ajson = ajson_default.
          ENDIF.

          TRY.
              DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).

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
          result = `{}`.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD main_attri_db_load.

    main_attri_db_load_resolve( ).

    DATA lt_child_idx TYPE ty_t_child_idx.
    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_pre)     "#EC CI_SORTSEQ
         WHERE name_parent IS NOT INITIAL.
      INSERT VALUE #( name_parent = lr_pre->name_parent
                      name        = lr_pre->name ) INTO TABLE lt_child_idx.
    ENDLOOP.

    DATA(lr_child_idx) = REF #( lt_child_idx ).
    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref IS NOT INITIAL.
      CASE lr_attri->type_kind.
        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.
          main_attri_db_load_table( lr_attri ).
        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.
          main_attri_db_load_dref( ir_attri     = lr_attri
                                   ir_child_idx = lr_child_idx ).
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_load_resolve.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref IS INITIAL.
      TRY.
          DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref ).
          IF lr_attri->srtti_data IS NOT INITIAL.
            ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).
            <val> = z2ui5_cl_a2ui5_context=>xml_srtti_parse( lr_attri->srtti_data ).
            CLEAR lr_attri->srtti_data.
          ENDIF.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_load_table.

    DATA(lr_ref_source) = attri_get_val_ref( ir_attri->name_ref ).
    ir_attri->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref_source ).

    READ TABLE mt_attri->* REFERENCE INTO DATA(lr_attri_parent)
         WITH KEY name = ir_attri->name_parent.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lv_parent_path) = |MO_APP->{ lr_attri_parent->name }|.
    ASSIGN (lv_parent_path) TO FIELD-SYMBOL(<parent_ref>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ASSIGN lr_ref_source->* TO FIELD-SYMBOL(<source_value>).
    GET REFERENCE OF <source_value> INTO <parent_ref>.

    DATA(lr_ref_parent) = REF #( <parent_ref> ).
    lr_attri_parent->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref_parent ).

  ENDMETHOD.

  METHOD main_attri_db_load_dref.

    DATA(lv_source_path) = |MO_APP->{ ir_attri->name_ref }|.
    ASSIGN (lv_source_path) TO FIELD-SYMBOL(<source_ref>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lv_target_path) = |MO_APP->{ ir_attri->name }|.
    ASSIGN (lv_target_path) TO FIELD-SYMBOL(<parent_ref>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    GET REFERENCE OF <source_ref> INTO <parent_ref>.
    ir_attri->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( <parent_ref> ).

    LOOP AT ir_child_idx->* REFERENCE INTO DATA(lr_child_idx)
         WHERE name_parent = ir_attri->name.
      READ TABLE mt_attri->* REFERENCE INTO DATA(lr_child)
           WITH KEY name = lr_child_idx->name.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lr_child_ref) = attri_get_val_ref( lr_child->name ).
      lr_child->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_child_ref ).
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.

    dissolve( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.

      DATA(lv_name5) = |MO_APP->{ lr_attri->name }|.
      ASSIGN (lv_name5) TO FIELD-SYMBOL(<ref>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lv_name) = |MO_APP->{ lr_attri->name }->*|.
      ASSIGN (lv_name) TO FIELD-SYMBOL(<val1>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lo_descr) = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data( <val1> ).

      CASE lo_descr->type_kind.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.

          LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_child) "#EC CI_SORTSEQ
               WHERE name_ref    IS INITIAL
                     AND type_kind    = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table
                     AND name_parent  = lr_attri->name.

            DATA(lv_name6) = |MO_APP->{ lr_attri_child->name }|.
            ASSIGN (lv_name6) TO FIELD-SYMBOL(<val_ref>).
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            lr_attri->srtti_data = z2ui5_cl_a2ui5_context=>xml_srtti_stringify( <val_ref> ).
            CLEAR <val_ref>.
            CLEAR <val1>.
            CLEAR <ref>.
            EXIT.
          ENDLOOP.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct1 OR z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct2.
          lr_attri->srtti_data = z2ui5_cl_a2ui5_context=>xml_srtti_stringify( <val1> ).

      ENDCASE.

    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri2)  "#EC CI_SORTSEQ
         WHERE type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.

      DATA(lv_name8) = |MO_APP->{ lr_attri2->name }|.
      ASSIGN (lv_name8) TO FIELD-SYMBOL(<ref2>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <ref2>.

      IF lr_attri2->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_name10) = |MO_APP->{ lr_attri2->name }->*|.
      ASSIGN (lv_name10) TO FIELD-SYMBOL(<val8>).
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

    RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the bound values are public attributes of your class`.

  ENDMETHOD.

  METHOD attri_get_val_ref.

    FIELD-SYMBOLS <attri> TYPE any.

    IF iv_path IS INITIAL.
      ASSIGN mo_app TO <attri>.
    ELSE.
      DATA(lv_name) = |MO_APP->{ iv_path }|.
      ASSIGN (lv_name) TO <attri>.
    ENDIF.

    IF <attri> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

    GET REFERENCE OF <attri> INTO result.
    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    DATA(lo_datadescr) = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( val ).

    IF lo_datadescr->type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref
        OR lo_datadescr->type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `NO DATA REFERENCES FOR BINDING ALLOWED: DEREFERENCE YOUR DATA FIRST`.
    ENDIF.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = lo_datadescr->type_kind
               AND kind       = lo_datadescr->kind.

      " compare by name - descriptor instances are not stable in the
      " abaplint transpiler runtime; the data reference check below is
      " the definitive match, this is only a prefilter. Generated names
      " of anonymous types (containing %) are not comparable either
      DATA(lv_name_attri) = lr_attri->o_typedescr->absolute_name.
      DATA(lv_name_val) = lo_datadescr->absolute_name.
      IF lv_name_attri <> lv_name_val
          AND lv_name_attri NS `%`
          AND lv_name_val NS `%`.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
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

    DATA(lo_descr) = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( attri_get_val_ref( name ) ).
    result = VALUE z2ui5_if_core_types=>ty_s_attri( name         = name
                                                     o_typedescr = lo_descr
                                                     type_kind   = lo_descr->type_kind
                                                     kind        = lo_descr->kind ).

  ENDMETHOD.

  METHOD diss_dref.

    DATA(lr_ref_tmp) = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_a2ui5_context=>check_unassign_initial( lr_ref_tmp ).
      RETURN.
    ENDIF.

    DATA(lr_ref) = z2ui5_cl_a2ui5_context=>unassign_data( lr_ref_tmp ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_attri2) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
    ls_attri2-o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref ).

    CASE ls_attri2-o_typedescr->kind.

      WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_kind_struct.
        DATA(lt_attri) = diss_struc( ir_attri ).
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

    DATA(lr_val) = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_a2ui5_context=>check_unassign_initial( lr_val ).
      RETURN.
    ENDIF.

    DATA(lr_ref) = z2ui5_cl_a2ui5_context=>unassign_object( lr_val ).
    DATA(lt_attri) = z2ui5_cl_a2ui5_context=>rtti_get_t_attri_by_oref( lr_ref ).

    DATA(lv_prefix) = COND string( WHEN ir_attri->name IS NOT INITIAL THEN |{ ir_attri->name }->| ).

    LOOP AT lt_attri REFERENCE INTO DATA(lr_attri)
         WHERE visibility   = z2ui5_cl_a2ui5_context=>cv_objectdescr_public
               AND is_interface = abap_false
               AND is_class     = abap_false
               AND is_constant  = abap_false.
      TRY.
          DATA(ls_new) = attri_create_new( lv_prefix && lr_attri->name ).
          ls_new-name_parent = ir_attri->name.
          INSERT ls_new INTO TABLE result.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD diss_struc.

    DATA(lr_val) = attri_get_val_ref( ir_attri->name ).

    IF ir_attri->o_typedescr->kind = z2ui5_cl_a2ui5_context=>cv_typedescr_kind_ref.
      DATA(lv_name) = |{ ir_attri->name }->|.
      DATA(lr_ref) = z2ui5_cl_a2ui5_context=>unassign_data( lr_val ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = lr_val.
    ENDIF.

    IF lr_ref IS BOUND.
      DATA(lt_attri) = z2ui5_cl_a2ui5_context=>rtti_get_t_attri_by_any( lr_ref ).

      LOOP AT lt_attri INTO DATA(ls_attri).
        DATA(ls_new) = attri_create_new( lv_name && ls_attri-name ).
        ls_new-name_parent = ir_attri->name.
        INSERT ls_new INTO TABLE result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD dissolve.

    DATA lv_depth TYPE i.

    WHILE line_exists( mt_attri->*[ check_dissolved = abap_false ] ) OR mt_attri->* IS INITIAL. "#EC CI_SORTSEQ

      lv_depth = lv_depth + 1.
      IF lv_depth >= max_dissolve_depth.
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

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE check_dissolved  = abap_true
               AND name_ref        IS INITIAL.

      TRY.
          DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.

      CASE lr_attri->type_kind.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.

          LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_ref) "#EC CI_SORTSEQ
               WHERE check_dissolved  = abap_true
                     AND name            <> lr_attri->name
                     AND name_ref        IS INITIAL
                     AND type_kind        = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.

            TRY.
                DATA(lr_attri_ref_ref) = attri_get_val_ref( lr_attri_ref->name ).
              CATCH cx_root.
                CONTINUE.
            ENDTRY.

            IF lr_ref <> lr_attri_ref_ref.
              CONTINUE.
            ENDIF.

            lr_attri->name_ref = lr_attri_ref->name.
          ENDLOOP.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.

          ASSIGN lr_ref->* TO FIELD-SYMBOL(<ref>).

          LOOP AT mt_attri->* REFERENCE INTO lr_attri_ref "#EC CI_SORTSEQ
               WHERE check_dissolved  = abap_true
                     AND name            <> lr_attri->name
                     AND name_ref        IS INITIAL
                     AND (    type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct1
                           OR type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct2 ).

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

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_child) "#EC CI_SORTSEQ
         WHERE name_parent = ir_attri->name.
      DATA(lv_name) = shift_left( val = lr_attri_child->name
                                  sub = |{ ir_attri->name }->| ).
      lr_attri_child->name_ref = |{ ir_attri->name_ref }-{ lv_name }|.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.

    IF mt_attri->* IS INITIAL.
      DATA(ls_attri) = VALUE z2ui5_if_core_types=>ty_s_attri( ).
      DATA(lt_init) = diss_oref( REF #( ls_attri ) ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.

    DATA(lt_attri_new) = VALUE z2ui5_if_core_types=>ty_t_attri( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.
        DATA(ls_entry) = attri_create_new( lr_attri->name ).
        lr_attri->o_typedescr = ls_entry-o_typedescr.
      ENDIF.

      CASE lr_attri->o_typedescr->kind.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_kind_struct.
          DATA(lt_attri_struc) = diss_struc( lr_attri ).
          INSERT LINES OF lt_attri_struc INTO TABLE lt_attri_new.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_kind_ref.

          CASE lr_attri->o_typedescr->type_kind.

            WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.
              DATA(lt_attri_oref) = diss_oref( lr_attri ).
              INSERT LINES OF lt_attri_oref INTO TABLE lt_attri_new.
            WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.
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
    DELETE lt_attri WHERE bind_type IS INITIAL.         "#EC CI_SORTSEQ
    CLEAR mt_attri->*.

    dissolve( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).
      READ TABLE lt_attri REFERENCE INTO DATA(lr_old) WITH KEY name = lr_attri->name. "#EC CI_SORTSEQ
      IF sy-subrc = 0.
        lr_attri->bind_type   = lr_old->bind_type.
        lr_attri->name_client = lr_old->name_client.
        lr_attri->view        = lr_old->view.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_apply_to_table.

    TRY.
        DATA(lr_ref_d) = attri_get_val_ref( iv_name ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    FIELD-SYMBOLS <delta_tab> TYPE STANDARD TABLE.
    ASSIGN lr_ref_d->* TO <delta_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    delta_apply_nodes( EXPORTING io_delta = io_val_front->slice( `/__delta` )
                       CHANGING  ct_tab   = <delta_tab> ).

  ENDMETHOD.

  METHOD delta_apply_nodes.

    DATA(lt_idx) = io_delta->members( `/` ).
    LOOP AT lt_idx INTO DATA(lv_idx_str).
      DATA(lv_tabix) = CONV i( lv_idx_str ) + 1.
      FIELD-SYMBOLS <delta_row> TYPE any.
      READ TABLE ct_tab INDEX lv_tabix ASSIGNING <delta_row>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lo_row_d) = io_delta->slice( |/{ lv_idx_str }| ).
      DATA(lt_fld) = lo_row_d->members( `/` ).
      LOOP AT lt_fld INTO DATA(lv_fld).
        FIELD-SYMBOLS <comp> TYPE any.
        ASSIGN COMPONENT lv_fld OF STRUCTURE <delta_row> TO <comp>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        DATA(lv_fld_path) = |/{ lv_fld }|.

        CASE lo_row_d->get_node_type( lv_fld_path ).

          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            <comp> = lo_row_d->get_boolean( lv_fld_path ).

          WHEN z2ui5_if_ajson_types=>node_type-object.
            " either a nested table delta (marked by __delta) or a
            " structure component shipped as a whole value
            DATA(lo_sub) = lo_row_d->slice( lv_fld_path ).
            IF lo_sub->exists( `/__delta` ) = abap_true.
              DATA lr_sub TYPE REF TO data.
              GET REFERENCE OF <comp> INTO lr_sub.
              FIELD-SYMBOLS <sub_tab> TYPE STANDARD TABLE.
              ASSIGN lr_sub->* TO <sub_tab>.
              IF sy-subrc = 0.
                delta_apply_nodes( EXPORTING io_delta = lo_sub->slice( `/__delta` )
                                   CHANGING  ct_tab   = <sub_tab> ).
              ENDIF.
            ELSE.
              lo_sub->to_abap( EXPORTING iv_corresponding = abap_true
                               IMPORTING ev_container     = <comp> ).
            ENDIF.

          WHEN z2ui5_if_ajson_types=>node_type-array.
            " a whole sub-table value replaced a nested delta on the client
            lo_row_d->slice( lv_fld_path )->to_abap( EXPORTING iv_corresponding = abap_true
                                                     IMPORTING ev_container     = <comp> ).

          WHEN OTHERS.
            " numbers intentionally go through get_string: the raw JSON text
            " converts losslessly into any numeric target type, while
            " get_number would round through a binary float first
            <comp> = lo_row_d->get_string( lv_fld_path ).
        ENDCASE.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
