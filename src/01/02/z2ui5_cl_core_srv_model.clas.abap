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
        model TYPE REF TO z2ui5_if_ajson.

    METHODS main_json_stringify
      RETURNING
        VALUE(result) TYPE string.



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

    "! Apply one delta field value into the referenced row component. A
    "! single malformed cell (e.g. text into a numeric target) is skipped
    "! here so it cannot abort the whole model batch.
    METHODS delta_apply_field
      IMPORTING
        io_row_d TYPE REF TO z2ui5_if_ajson
        iv_path  TYPE string
        ir_comp  TYPE REF TO data
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_core_srv_model IMPLEMENTATION.

  METHOD main_json_to_attri.

    DATA temp237 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp237.
          DATA lo_val_front TYPE REF TO z2ui5_if_ajson.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
          DATA x TYPE REF TO cx_root.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri
         WHERE bind = abap_true.                        "#EC CI_SORTSEQ
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
          RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
            EXPORTING
              val = |JSON_PARSING_ERROR: { x->get_text( ) }|.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_json_stringify.
        DATA temp238 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_result LIKE temp238.
        DATA temp239 TYPE REF TO z2ui5_if_ajson.
        DATA ajson_default LIKE temp239.
TYPES BEGIN OF ty_s_mapper_cache.
TYPES mapper TYPE REF TO z2ui5_if_ajson_mapping.
TYPES ajson TYPE REF TO z2ui5_if_ajson.
TYPES END OF ty_s_mapper_cache.
        DATA lt_mapper_cache TYPE STANDARD TABLE OF ty_s_mapper_cache WITH DEFAULT KEY.
        DATA temp240 LIKE LINE OF mt_attri->*.
        DATA lr_attri LIKE REF TO temp240.
            DATA lr_mapper_cache TYPE REF TO ty_s_mapper_cache.
              DATA ajson LIKE lr_mapper_cache->ajson.
              DATA temp241 TYPE REF TO z2ui5_if_ajson.
              DATA temp242 TYPE ty_s_mapper_cache.
              DATA lr_ref TYPE REF TO data.
          FIELD-SYMBOLS <val> TYPE data.
        DATA x TYPE REF TO cx_root.
    TRY.


        temp238 ?= z2ui5_cl_ajson=>create_empty( ).

        ajson_result = temp238.

        temp239 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ).

        ajson_default = temp239.






        LOOP AT mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
             WHERE bind = abap_true
                   AND type_kind <> z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref
                   AND type_kind <> z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.

          IF lr_attri->custom_mapper IS BOUND.

            READ TABLE lt_mapper_cache REFERENCE INTO lr_mapper_cache
                 WITH KEY mapper = lr_attri->custom_mapper. "#EC CI_SORTSEQ
            IF sy-subrc = 0.

              ajson = lr_mapper_cache->ajson.
            ELSE.

              temp241 ?= z2ui5_cl_ajson=>create_empty( ii_custom_mapping = lr_attri->custom_mapper ).
              ajson = temp241.

              CLEAR temp242.
              temp242-mapper = lr_attri->custom_mapper.
              temp242-ajson = ajson.
              INSERT temp242 INTO TABLE lt_mapper_cache.
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
          result = `{}`.
        ENDIF.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD main_attri_db_load.
    DATA lt_child_idx TYPE ty_t_child_idx.
    DATA temp243 LIKE LINE OF mt_attri->*.
    DATA lr_pre LIKE REF TO temp243.
      DATA temp244 TYPE z2ui5_cl_core_srv_model=>ty_s_child_idx.
    DATA lr_child_idx LIKE REF TO lt_child_idx.
    DATA temp245 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp245.

    main_attri_db_load_resolve( ).




    LOOP AT mt_attri->* REFERENCE INTO lr_pre     "#EC CI_SORTSEQ
         WHERE name_parent IS NOT INITIAL.

      CLEAR temp244.
      temp244-name_parent = lr_pre->name_parent.
      temp244-name = lr_pre->name.
      INSERT temp244 INTO TABLE lt_child_idx.
    ENDLOOP.


    GET REFERENCE OF lt_child_idx INTO lr_child_idx.


    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
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

    DATA temp246 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp246.
          DATA lr_ref TYPE REF TO data.
            FIELD-SYMBOLS <val> TYPE data.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
         WHERE name_ref IS INITIAL.
      TRY.

          lr_ref = attri_get_val_ref( lr_attri->name ).
          lr_attri->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref ).
          IF lr_attri->srtti_data IS NOT INITIAL.

            ASSIGN lr_ref->* TO <val>.
            <val> = z2ui5_cl_a2ui5_context=>xml_srtti_parse( lr_attri->srtti_data ).
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
    ir_attri->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref_source ).


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
    lr_attri_parent->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref_parent ).

  ENDMETHOD.

  METHOD main_attri_db_load_dref.

    DATA lv_source_path TYPE string.
    FIELD-SYMBOLS <source_ref> TYPE any.
    DATA lv_target_path TYPE string.
    FIELD-SYMBOLS <parent_ref> TYPE any.
    DATA temp247 LIKE LINE OF ir_child_idx->*.
    DATA lr_child_idx LIKE REF TO temp247.
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
    ir_attri->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( <parent_ref> ).



    LOOP AT ir_child_idx->* REFERENCE INTO lr_child_idx
         WHERE name_parent = ir_attri->name.

      READ TABLE mt_attri->* REFERENCE INTO lr_child
           WITH KEY name = lr_child_idx->name.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lr_child_ref = attri_get_val_ref( lr_child->name ).
      lr_child->o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_child_ref ).
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.
    DATA temp248 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp248.
      DATA lv_path_ref TYPE string.
      FIELD-SYMBOLS <ref> TYPE any.
      DATA lv_path_deref TYPE string.
      FIELD-SYMBOLS <val_deref> TYPE any.
      DATA lo_descr TYPE REF TO cl_abap_typedescr.
          DATA temp249 LIKE LINE OF mt_attri->*.
          DATA lr_attri_child LIKE REF TO temp249.
            DATA lv_path_child TYPE string.
            FIELD-SYMBOLS <val_ref> TYPE any.
    DATA temp250 LIKE LINE OF mt_attri->*.
    DATA lr_attri2 LIKE REF TO temp250.
      DATA lv_path_dref TYPE string.
      FIELD-SYMBOLS <dref> TYPE any.
      DATA lv_path_dref_deref TYPE string.
      FIELD-SYMBOLS <dref_deref> TYPE any.

    dissolve( ).



    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.


      lv_path_ref = |MO_APP->{ lr_attri->name }|.

      ASSIGN (lv_path_ref) TO <ref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lv_path_deref = |MO_APP->{ lr_attri->name }->*|.

      ASSIGN (lv_path_deref) TO <val_deref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lo_descr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data( <val_deref> ).

      CASE lo_descr->type_kind.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.



          LOOP AT mt_attri->* REFERENCE INTO lr_attri_child "#EC CI_SORTSEQ
               WHERE name_ref    IS INITIAL
                     AND type_kind    = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table
                     AND name_parent  = lr_attri->name.


            lv_path_child = |MO_APP->{ lr_attri_child->name }|.

            ASSIGN (lv_path_child) TO <val_ref>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
            lr_attri->srtti_data = z2ui5_cl_a2ui5_context=>xml_srtti_stringify( <val_ref> ).
            CLEAR <val_ref>.
            CLEAR <val_deref>.
            CLEAR <ref>.
            EXIT.
          ENDLOOP.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct1 OR z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct2.
          lr_attri->srtti_data = z2ui5_cl_a2ui5_context=>xml_srtti_stringify( <val_deref> ).

      ENDCASE.

    ENDLOOP.



    LOOP AT mt_attri->* REFERENCE INTO lr_attri2  "#EC CI_SORTSEQ
         WHERE type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.


      lv_path_dref = |MO_APP->{ lr_attri2->name }|.

      ASSIGN (lv_path_dref) TO <dref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <dref>.

      IF lr_attri2->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.


      lv_path_dref_deref = |MO_APP->{ lr_attri2->name }->*|.

      ASSIGN (lv_path_dref_deref) TO <dref_deref>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CLEAR <dref_deref>.
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
      DATA lv_name TYPE string.

    IF iv_path IS INITIAL.
      ASSIGN mo_app TO <attri>.
    ELSE.

      lv_name = |MO_APP->{ iv_path }|.
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

    DATA lo_datadescr TYPE REF TO cl_abap_typedescr.
    DATA temp251 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp251.
      DATA lv_name_attri LIKE lr_attri->o_typedescr->absolute_name.
      DATA lv_name_val LIKE lo_datadescr->absolute_name.
          DATA lr_ref TYPE REF TO data.
    lo_datadescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( val ).

    IF lo_datadescr->type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref
        OR lo_datadescr->type_kind = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `NO DATA REFERENCES FOR BINDING ALLOWED: DEREFERENCE YOUR DATA FIRST`.
    ENDIF.



    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
         WHERE name_ref  IS INITIAL
               AND type_kind  = lo_datadescr->type_kind
               AND kind       = lo_datadescr->kind.

      " compare by name - descriptor instances are not stable in the
      " abaplint transpiler runtime; the data reference check below is
      " the definitive match, this is only a prefilter. Generated names
      " of anonymous types (containing %) are not comparable either

      lv_name_attri = lr_attri->o_typedescr->absolute_name.

      lv_name_val = lo_datadescr->absolute_name.
      IF lv_name_attri <> lv_name_val
          AND lv_name_attri NS `%`
          AND lv_name_val NS `%`.
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
    DATA temp252 TYPE z2ui5_if_core_types=>ty_s_attri.
    lo_descr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( attri_get_val_ref( name ) ).

    CLEAR temp252.
    temp252-name = name.
    temp252-o_typedescr = lo_descr.
    temp252-type_kind = lo_descr->type_kind.
    temp252-kind = lo_descr->kind.
    result = temp252.

  ENDMETHOD.

  METHOD diss_dref.

    DATA lr_ref_tmp TYPE REF TO data.
    DATA lr_ref TYPE REF TO data.
    DATA temp253 TYPE z2ui5_if_core_types=>ty_s_attri.
    DATA ls_attri2 LIKE temp253.
        DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    lr_ref_tmp = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_a2ui5_context=>check_unassign_initial( lr_ref_tmp ) IS NOT INITIAL.
      RETURN.
    ENDIF.


    lr_ref = z2ui5_cl_a2ui5_context=>unassign_data( lr_ref_tmp ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.


    CLEAR temp253.

    ls_attri2 = temp253.
    ls_attri2-o_typedescr = z2ui5_cl_a2ui5_context=>rtti_get_typedescr_by_data_ref( lr_ref ).

    CASE ls_attri2-o_typedescr->kind.

      WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_kind_struct.

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
    DATA temp254 TYPE string.
    DATA lv_prefix LIKE temp254.
    DATA temp255 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp255.
          DATA ls_new TYPE z2ui5_if_core_types=>ty_s_attri.
    lr_val = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_a2ui5_context=>check_unassign_initial( lr_val ) IS NOT INITIAL.
      RETURN.
    ENDIF.


    lr_ref = z2ui5_cl_a2ui5_context=>unassign_object( lr_val ).

    lt_attri = z2ui5_cl_a2ui5_context=>rtti_get_t_attri_by_oref( lr_ref ).


    IF ir_attri->name IS NOT INITIAL.
      temp254 = |{ ir_attri->name }->|.
    ELSE.
      CLEAR temp254.
    ENDIF.

    lv_prefix = temp254.



    LOOP AT lt_attri REFERENCE INTO lr_attri
         WHERE visibility   = z2ui5_cl_a2ui5_context=>cv_objectdescr_public
               AND is_interface = abap_false
               AND is_class     = abap_false
               AND is_constant  = abap_false.
      TRY.

          ls_new = attri_create_new( lv_prefix && lr_attri->name ).
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

    IF ir_attri->o_typedescr->kind = z2ui5_cl_a2ui5_context=>cv_typedescr_kind_ref.

      lv_name = |{ ir_attri->name }->|.

      lr_ref = z2ui5_cl_a2ui5_context=>unassign_data( lr_val ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = lr_val.
    ENDIF.

    IF lr_ref IS BOUND.

      lt_attri = z2ui5_cl_a2ui5_context=>rtti_get_t_attri_by_any( lr_ref ).


      LOOP AT lt_attri INTO ls_attri.

        ls_new = attri_create_new( lv_name && ls_attri-name ).
        ls_new-name_parent = ir_attri->name.
        INSERT ls_new INTO TABLE result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD dissolve.

    DATA lv_depth TYPE i.

    DATA temp256 LIKE sy-subrc.
    READ TABLE mt_attri->* WITH KEY check_dissolved = abap_false TRANSPORTING NO FIELDS.
    temp256 = sy-subrc.
    WHILE temp256 = 0 OR mt_attri->* IS INITIAL. "#EC CI_SORTSEQ

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

    " Declared once at method level: both CASE branches below fill and read
    " these, so an inline DATA(...) in only the first branch would read as if
    " they belonged to that branch alone.
    DATA lr_attri_ref     TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA lr_attri_ref_ref TYPE REF TO data.

    DATA temp257 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp257.
          DATA lr_ref TYPE REF TO data.
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

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.

          LOOP AT mt_attri->* REFERENCE INTO lr_attri_ref "#EC CI_SORTSEQ
               WHERE check_dissolved  = abap_true
                     AND name            <> lr_attri->name
                     AND name_ref        IS INITIAL
                     AND type_kind        = z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table.

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

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.


          ASSIGN lr_ref->* TO <ref>.

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

    DATA temp258 LIKE LINE OF mt_attri->*.
    DATA lr_attri_child LIKE REF TO temp258.
      DATA lv_name TYPE string.
    LOOP AT mt_attri->* REFERENCE INTO lr_attri_child "#EC CI_SORTSEQ
         WHERE name_parent = ir_attri->name.

      lv_name = shift_left( val = lr_attri_child->name
                                  sub = |{ ir_attri->name }->| ).
      lr_attri_child->name_ref = |{ ir_attri->name_ref }-{ lv_name }|.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.
      DATA temp259 TYPE z2ui5_if_core_types=>ty_s_attri.
      DATA ls_attri LIKE temp259.
      DATA temp260 LIKE REF TO ls_attri.
DATA lt_init TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp261 TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA lt_attri_new LIKE temp261.
    DATA temp262 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp262.
        DATA ls_entry TYPE z2ui5_if_core_types=>ty_s_attri.
          DATA lt_attri_struc TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_oref TYPE z2ui5_if_core_types=>ty_t_attri.
              DATA lt_attri_dref TYPE z2ui5_if_core_types=>ty_t_attri.

    IF mt_attri->* IS INITIAL.

      CLEAR temp259.

      ls_attri = temp259.

      GET REFERENCE OF ls_attri INTO temp260.

lt_init = diss_oref( temp260 ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.


    CLEAR temp261.

    lt_attri_new = temp261.



    LOOP AT mt_attri->* REFERENCE INTO lr_attri   "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.

        ls_entry = attri_create_new( lr_attri->name ).
        lr_attri->o_typedescr = ls_entry-o_typedescr.
      ENDIF.

      CASE lr_attri->o_typedescr->kind.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_kind_struct.

          lt_attri_struc = diss_struc( lr_attri ).
          INSERT LINES OF lt_attri_struc INTO TABLE lt_attri_new.

        WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_kind_ref.

          CASE lr_attri->o_typedescr->type_kind.

            WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.

              lt_attri_oref = diss_oref( lr_attri ).
              INSERT LINES OF lt_attri_oref INTO TABLE lt_attri_new.
            WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref.

              lt_attri_dref = diss_dref( lr_attri ).
              INSERT LINES OF lt_attri_dref INTO TABLE lt_attri_new.
            WHEN OTHERS.
              " an unexpected ref type_kind is left as a non-dissolvable leaf
              " (like the unknown-kind WHEN OTHERS below) - an ASSERT here
              " would raise the uncatchable ASSERTION_FAILED and defeat the
              " TRY/CATCH around dissolve_run, dumping the whole request
          ENDCASE.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD main_attri_refresh.

    DATA lt_attri TYPE z2ui5_if_core_types=>ty_t_attri.
    DATA temp263 LIKE LINE OF mt_attri->*.
    DATA lr_attri LIKE REF TO temp263.
      DATA lr_old TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    lt_attri = mt_attri->*.
    DELETE lt_attri WHERE bind = abap_false.            "#EC CI_SORTSEQ
    CLEAR mt_attri->*.

    dissolve( ).



    LOOP AT mt_attri->* REFERENCE INTO lr_attri.

      READ TABLE lt_attri REFERENCE INTO lr_old WITH KEY name = lr_attri->name. "#EC CI_SORTSEQ
      IF sy-subrc = 0.
        lr_attri->bind        = lr_old->bind.
        lr_attri->name_client = lr_old->name_client.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_apply_to_table.
        DATA lr_ref_d TYPE REF TO data.
    FIELD-SYMBOLS <delta_tab> TYPE STANDARD TABLE.

    TRY.

        lr_ref_d = attri_get_val_ref( iv_name ).
      CATCH cx_root.
        RETURN.
    ENDTRY.


    ASSIGN lr_ref_d->* TO <delta_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    delta_apply_nodes( EXPORTING io_delta = io_val_front->slice( `/__delta` )
                       CHANGING  ct_tab   = <delta_tab> ).

  ENDMETHOD.

  METHOD delta_apply_nodes.

    DATA lt_idx TYPE string_table.
    DATA lv_idx_str LIKE LINE OF lt_idx.
      DATA lv_tabix TYPE i.
          DATA temp264 TYPE i.
      FIELD-SYMBOLS <delta_row> TYPE any.
      DATA lo_row_d TYPE REF TO z2ui5_if_ajson.
      DATA lt_fld TYPE string_table.
      DATA lv_fld LIKE LINE OF lt_fld.
        FIELD-SYMBOLS <comp> TYPE any.
        DATA temp265 TYPE REF TO data.
    lt_idx = io_delta->members( `/` ).

    LOOP AT lt_idx INTO lv_idx_str.

      TRY.
          " the delta key is a client-supplied row index; a garbled
          " (non-numeric) key must skip that row, not dump the request

          temp264 = lv_idx_str.
          lv_tabix = temp264 + 1.
        CATCH cx_root.
          CONTINUE.
      ENDTRY.

      READ TABLE ct_tab INDEX lv_tabix ASSIGNING <delta_row>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lo_row_d = io_delta->slice( |/{ lv_idx_str }| ).

      lt_fld = lo_row_d->members( `/` ).

      LOOP AT lt_fld INTO lv_fld.

        ASSIGN COMPONENT lv_fld OF STRUCTURE <delta_row> TO <comp>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

GET REFERENCE OF <comp> INTO temp265.
delta_apply_field( io_row_d = lo_row_d
                           iv_path  = |/{ lv_fld }|
                           ir_comp  = temp265 ).
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_apply_field.

    FIELD-SYMBOLS <comp> TYPE any.
            DATA lo_sub TYPE REF TO z2ui5_if_ajson.
              FIELD-SYMBOLS <sub_tab> TYPE STANDARD TABLE.
    ASSIGN ir_comp->* TO <comp>.

    TRY.
        CASE io_row_d->get_node_type( iv_path ).

          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            <comp> = io_row_d->get_boolean( iv_path ).

          WHEN z2ui5_if_ajson_types=>node_type-object.
            " either a nested table delta (marked by __delta) or a
            " structure component shipped as a whole value

            lo_sub = io_row_d->slice( iv_path ).
            IF lo_sub->exists( `/__delta` ) = abap_true.

              ASSIGN ir_comp->* TO <sub_tab>.
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
            io_row_d->slice( iv_path )->to_abap( EXPORTING iv_corresponding = abap_true
                                                 IMPORTING ev_container     = <comp> ).

          WHEN OTHERS.
            " numbers intentionally go through get_string: the raw JSON text
            " converts losslessly into any numeric target type, while
            " get_number would round through a binary float first
            <comp> = io_row_d->get_string( iv_path ).
        ENDCASE.

      CATCH cx_root.
        " a single malformed cell (e.g. text sent into a numeric target)
        " must not discard every other edit in this batch - skip just it
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
