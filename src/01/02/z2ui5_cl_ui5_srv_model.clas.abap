CLASS z2ui5_cl_ui5_srv_model DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri
        app   TYPE REF TO object.

    METHODS main_attri_search
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS main_attri_db_save_srtti.
    METHODS main_attri_db_load.
    METHODS main_attri_refresh.

    "! Put the data references main_attri_db_save_srtti detached back onto
    "! the live instance - the SAME references, no parse. The counterpart of
    "! main_attri_db_load for the instance that goes on rendering after its
    "! draft was written: identity is kept by construction (the objects never
    "! changed hands), and the S-RTTI payloads on the rows are cleared as a
    "! load clears them. Only valid on the instance the save ran on.
    METHODS main_attri_reattach.

    METHODS main_json_to_attri
      IMPORTING
        model TYPE REF TO z2ui5_if_ajson.

    METHODS main_json_stringify
      RETURNING
        VALUE(result) TYPE string.

    DATA mt_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    DATA mo_app   TYPE REF TO object.

    "! The table cells this parse could not apply - one entry per delta cell
    "! whose value arrived and would not convert (see delta_apply_field). The
    "! instance is created per roundtrip (z2ui5_cl_ui5_app_cont=>create_model),
    "! so the list covers exactly one model parse; the caller hands it to the
    "! app as client->get( )-t_model_skipped.
    DATA mt_skipped TYPE z2ui5_if_client=>ty_t_model_skip.

  PROTECTED SECTION.
  PRIVATE SECTION.

    " how many REFERENCE hops (`->`) a dissolved name may carry - the bound
    " that ends a cyclic object graph (an attribute pointing back at its
    " owner). Structure nesting (`-`) is finite by itself and not counted
    CONSTANTS max_dissolve_depth TYPE i VALUE 5.
    " how many passes one dissolve( ) makes at most - one pass per level, so
    " this only has to exceed the deepest structure an app nests plus the
    " reference hops above; sample 138 binds a leaf eight components down
    CONSTANTS max_dissolve_passes TYPE i VALUE 25.

    METHODS main_attri_db_load_resolve.

    " Is anything the VIEW reads stored under this attribute - the attribute
    " itself, or one of its dissolved children? Decides how loud a failed
    " restore is (main_attri_db_load_resolve).
    METHODS check_attri_bound
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    " Re-create the cleared outer reference of a dref-to-dref chain so the
    " child row's payload has somewhere to go (main_attri_db_load_resolve).
    " Answers the reference to the parent attribute; raises when the parent
    " cannot be reached or cannot take a generic data object.
    METHODS dref_parent_recreate
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS main_attri_db_load_table
      IMPORTING
        ir_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS main_attri_db_load_dref
      IMPORTING
        ir_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS attri_update_entry_refs.
    METHODS attri_update_refs_children
      IMPORTING
        ir_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS attri_get_val_ref
      IMPORTING
        iv_path       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS attri_search
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS dissolve.
    METHODS dissolve_run.

    METHODS diss_struc
      IMPORTING
        ir_attri      TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_attri.

    METHODS diss_dref
      IMPORTING
        ir_attri      TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_attri.

    METHODS diss_oref
      IMPORTING
        ir_attri      TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_t_attri.

    METHODS attri_create_new
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_s_attri.

    "! Apply the row delta under iv_path/__delta of io_val_front to the
    "! table attribute iv_name. iv_path is the attribute's node in the
    "! request model (name_client); left initial when io_val_front IS that
    "! node - the shape the tests hand in
    METHODS delta_apply_to_table
      IMPORTING
        io_val_front TYPE REF TO z2ui5_if_ajson
        iv_name      TYPE string
        iv_path      TYPE string OPTIONAL
      RAISING
        z2ui5_cx_ajson_error.

    "! iv_row_parent carries the 1-based row index of the IMMEDIATE parent
    "! into a nested-table recursion, so a skipped inner cell can name the
    "! record that owns it (ty_s_model_skip-row_parent); 0 at the top level.
    "! iv_base is the __delta node inside io_delta - the rows are its
    "! members, addressed by their full path. No sub-tree is sliced off
    METHODS delta_apply_nodes
      IMPORTING
        io_delta      TYPE REF TO z2ui5_if_ajson
        iv_base       TYPE string
        iv_table      TYPE string
        iv_row_parent TYPE i OPTIONAL
      CHANGING
        ct_tab        TYPE STANDARD TABLE
      RAISING
        z2ui5_cx_ajson_error.

    "! Apply one delta field value into the referenced row component. A
    "! single malformed cell (e.g. text into a numeric target) is skipped
    "! here so it cannot abort the whole model batch - and the skip is
    "! recorded in mt_skipped, because a cell that vanishes without a word is
    "! what made a typed price disappear while the browser kept showing it.
    "! is_cell IS the trace entry: it names the cell the caller resolved
    "! (table path, 1-based row, component), so nothing has to be derived
    "! again in the handler. Only a value that ARRIVED can be recorded here -
    "! the caller reaches this method per member of the delta row, so an
    "! absent field never becomes an entry.
    " what delta_apply_field learnt about a COLUMN of the table it is
    " writing: whether a nested table there is a standard one. Decided by
    " the component's type, so once per column per delta, not per cell
    TYPES:
      BEGIN OF ty_s_col_kind,
        field    TYPE string,
        standard TYPE abap_bool,
      END OF ty_s_col_kind.
    TYPES ty_t_col_kind TYPE SORTED TABLE OF ty_s_col_kind WITH UNIQUE KEY field.

    "! ir_before is a scratch component of the SAME type as ir_comp, owned
    "! by the caller's work row - the old value is kept there while the
    "! write may still be refused. ct_col_kind is the caller's memory of
    "! the table kinds per column (see ty_t_col_kind)
    METHODS delta_apply_field
      IMPORTING
        io_delta    TYPE REF TO z2ui5_if_ajson
        iv_path     TYPE string
        is_cell     TYPE z2ui5_if_client=>ty_s_model_skip
        ir_comp     TYPE REF TO data
        ir_before   TYPE REF TO data
      CHANGING
        ct_col_kind TYPE ty_t_col_kind
      RAISING
        z2ui5_cx_ajson_error.

    "! Every cell of a delta the table shape refuses lands in mt_skipped -
    "! the counterpart of delta_apply_nodes for a table that cannot be
    "! addressed by index (see delta_apply_to_table)
    METHODS delta_skip_nodes
      IMPORTING
        io_delta      TYPE REF TO z2ui5_if_ajson
        iv_base       TYPE string
        iv_table      TYPE string
        iv_row_parent TYPE i DEFAULT 0.

    "! The 1-based row index a delta key names, 0 for a key that names no
    "! row: the key is client-supplied, so a garbled (non-numeric) one must
    "! skip that row rather than dump the request, and a negative one
    "! converts fine but READ TABLE INDEX -1 is an uncatchable runtime
    "! error - the same skip
    METHODS delta_row_index
      IMPORTING
        iv_key        TYPE string
      RETURNING
        VALUE(result) TYPE i.

    " re-entrancy latch of dissolve( ) - see the CATCH there
    DATA mv_dissolve_refreshing TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_ref_idx,
        name TYPE string,
        ref  TYPE REF TO data,
      END OF ty_s_ref_idx.
    TYPES ty_t_ref_idx TYPE SORTED TABLE OF ty_s_ref_idx WITH UNIQUE KEY name.

    " name -> data reference, as resolved the last time this INSTANCE walked
    " the row (dissolve, the alias pass). A prefilter for the binding search
    " and nothing else: every answer it suggests is confirmed by a fresh
    " dynamic ASSIGN before it is returned, and a miss falls back to the
    " full fresh scan - so a stale entry (an app that re-pointed a reference
    " between two binds) costs one extra ASSIGN, never a wrong row. Lives as
    " long as the instance: one render for the bind service, one save or
    " load for the container
    DATA mt_ref_idx TYPE ty_t_ref_idx.

    " the references main_attri_db_save_srtti cleared, by attribute path -
    " what main_attri_reattach puts back
    DATA mt_detached TYPE ty_t_ref_idx.

    METHODS ref_idx_put
      IMPORTING
        iv_name TYPE string
        ir_ref  TYPE REF TO data.

    " one dissolved row with its reference resolved - the alias pass pairs
    " these instead of resolving on every compare
    TYPES:
      BEGIN OF ty_s_resolved,
        name      TYPE string,
        type_kind TYPE string,
        attri     TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri,
        ref       TYPE REF TO data,
        deref     TYPE REF TO data,
      END OF ty_s_resolved.
    TYPES ty_t_resolved TYPE SORTED TABLE OF ty_s_resolved WITH UNIQUE KEY name.

    METHODS entry_refs_pair_table
      IMPORTING
        ir_res      TYPE REF TO ty_s_resolved
        it_resolved TYPE ty_t_resolved.

    " Does the alias a row carries still hold - its owner reachable and
    " pointing at the same data object? If not, the alias is dropped (with
    " the children rewritten from it), and the pairing below finds the new
    " owner, or none. An app that pointed a reference at ANOTHER attribute
    " between two roundtrips used to keep the old name_ref forever: the
    " restore of the next draft re-pointed the reference at the old owner,
    " and the change was undone without a word
    METHODS entry_refs_recheck
      IMPORTING
        ir_res      TYPE REF TO ty_s_resolved
        it_resolved TYPE ty_t_resolved.

    " Can this row be an ALIAS - a row that names another as its owner and
    " is pointed at the owner's data object on the restore? Only the deref
    " of a data reference (`<name>->*`) can: a reference can be re-pointed,
    " a typed attribute cannot. Pairing a typed table as the alias of a
    " reference (whichever sorts last used to win) left the restore trying
    " to write a data reference into the typed attribute's parent
    METHODS check_alias_capable
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS entry_refs_pair_dref
      IMPORTING
        ir_res      TYPE REF TO ty_s_resolved
        it_resolved TYPE ty_t_resolved.

    "! Is the table behind the reference a STANDARD table - the only kind a
    "! row delta can be written into by index. Asked BEFORE any ASSIGN to a
    "! TYPE STANDARD TABLE field symbol: on a system that ASSIGN is the
    "! runtime error ASSIGN_TYPE_CONFLICT for a sorted or hashed table.
    METHODS check_table_standard
      IMPORTING
        ir_ref        TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    " the upper-case mapper every model serialization attaches: it holds
    " no state of its own (an empty field mapping), so one instance serves
    " every call instead of two objects per serialization. Created on the
    " first call, not in a class constructor - see z2ui5_cl_ui5_frontend's
    " box_resolve for why a static constructor is avoided here
    CLASS-DATA gi_mapper_upper TYPE REF TO z2ui5_if_ajson_mapping.
    CLASS-METHODS mapper_upper
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson_mapping.

    METHODS delta_apply_scalar
      IMPORTING
        io_delta TYPE REF TO z2ui5_if_ajson
        iv_path  TYPE string
        ir_comp  TYPE REF TO data
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_ui5_srv_model IMPLEMENTATION.

  METHOD main_json_to_attri.

    DATA lo_val_front TYPE REF TO z2ui5_if_ajson.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)
         WHERE bind = abap_true.                        "#EC CI_SORTSEQ
      CLEAR lo_val_front.
      TRY.

          " _bind( json = abap_true ) is outbound only: the attribute holds
          " configuration the client renders but never edits, and reading the
          " node back would mean writing an object into a string field. Skip it
          " rather than mangle it - the ABAP side stays the single author
          IF lr_attri->check_json = abap_true.
            CONTINUE.
          ENDIF.

          " the frontend sends only the DELTA, so most bound attributes have
          " no node in the request model at all. slice( ) walks and copies
          " the whole node tree per call (CP compare on every node); the
          " keyed exists( ) lookup answers "nothing there" first, so the
          " walk only runs for attributes the request actually carries -
          " the same reasoning as the /value unwrap in
          " z2ui5_cl_ui5_handler=>request_parse_body
          IF model->exists( lr_attri->name_client ) = abap_false.
            CONTINUE.
          ENDIF.

          " a row delta is applied on the request model itself, the rows
          " addressed by path under the attribute's node - no copy of the
          " attribute's sub-tree and no second copy of its __delta node.
          " Only a WHOLE value below is sliced, because to_abap( ) takes a
          " tree of its own
          IF model->exists( |{ lr_attri->name_client }/__delta| ) = abap_true.
            delta_apply_to_table( io_val_front = model
                                  iv_path      = lr_attri->name_client
                                  iv_name      = lr_attri->name ).
            CONTINUE.
          ENDIF.

          lo_val_front = model->slice( lr_attri->name_client ).
          IF lo_val_front IS NOT BOUND.
            CONTINUE.
          ENDIF.

          TRY.
              DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).

          " to_abap clears the target before it fills it, so a refused value
          " would leave the attribute initial - the trace below promises the
          " OLD value stays. Kept aside for the one path that can refuse;
          " only attributes the request actually carries get this far
          DATA lr_before TYPE REF TO data.
          CREATE DATA lr_before LIKE <val>.
          FIELD-SYMBOLS <before> TYPE any.
          ASSIGN lr_before->* TO <before>.
          <before> = <val>.

          TRY.
              lo_val_front->to_abap( EXPORTING iv_corresponding = abap_true
                                     IMPORTING ev_container     = <val> ).
            CATCH cx_root INTO DATA(lx_refused).
              <val> = <before>.
              RAISE EXCEPTION lx_refused.
          ENDTRY.

        CATCH cx_root.
          " A bound SCALAR (or a whole structure/table shipped as one value)
          " the client sent in a form the ABAP type refuses - `1,250.00`
          " typed into an Input bound to a packed field. This used to raise
          " JSON_PARSING_ERROR and fail the whole roundtrip with the fatal
          " overlay, while the same value in a table CELL was traced in
          " t_model_skipped and the roundtrip went on. Same treatment now:
          " the attribute is recorded (name = the attribute, row 0, no
          " field), its old value stays, and the app decides what to tell
          " the user - the reason the trace exists (see delta_apply_field)
          DATA(ls_skip) = VALUE z2ui5_if_client=>ty_s_model_skip( name = lr_attri->name ).
          " the delta path has no tree of its own to quote from - the entry
          " then names the attribute alone, as a refused structure does
          IF lo_val_front IS BOUND.
            TRY.
                ls_skip-value = lo_val_front->get_string( `` ).
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
          APPEND ls_skip TO mt_skipped.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_json_stringify.
    TRY.

        " the result instance itself carries the upper-case mapping, so the
        " common path below can convert an attribute straight into it - one
        " ABAP->node conversion instead of a conversion into a scratch
        " instance plus a node-by-node copy with per-node path rebasing
        " (lcl_abap_to_json=>convert_ajson). Component names come out the
        " same either way; the path leaf (name_client) is upper case by
        " construction (attribute names come from RTTI), so the mapping is
        " a no-op on it
        DATA(ajson_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                       ii_custom_mapping = mapper_upper( ) ) ).
        " the scratch instance for a filtered attribute without a mapper
        " of its own - created when the first such attribute asks for it
        DATA ajson_default TYPE REF TO z2ui5_if_ajson.

        TYPES: BEGIN OF ty_s_mapper_cache,
                 mapper TYPE REF TO z2ui5_if_ajson_mapping,
                 ajson  TYPE REF TO z2ui5_if_ajson,
               END OF ty_s_mapper_cache.
        DATA lt_mapper_cache TYPE STANDARD TABLE OF ty_s_mapper_cache WITH EMPTY KEY.

        LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
             WHERE bind = abap_true
                   AND type_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref
                   AND type_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_oref.

          TRY.
              DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).

          " _bind( json = abap_true ): the ABAP string already CONTAINS JSON, so
          " it is parsed and spliced in as a node. Serialized as a value it
          " would arrive quoted, which is a different thing for a control
          " property that must receive an OBJECT - and no typed ABAP value can
          " be that object (a sap.ui.integration Card manifest has keys like
          " `sap.app`, which are not valid ABAP field names). The parse also
          " decides the failure mode: an unparseable string raises here instead
          " of emitting broken JSON the frontend would choke on. No mapper runs
          " over it - the keys are the payload's own and must survive verbatim
          " (an ajson value is copied node for node, the result's mapping does
          " not touch it)
          IF lr_attri->check_json = abap_true.
            ajson_result->set( iv_path = lr_attri->name_client
                               iv_val  = z2ui5_cl_ajson=>parse( <val> ) ).
            CONTINUE.
          ENDIF.

          " a mapper or filter is attached to an ajson INSTANCE, so those
          " attributes keep the scratch-instance detour the direct set cannot
          " express: convert into the scratch, filter, copy into the result
          IF lr_attri->custom_mapper IS BOUND OR lr_attri->custom_filter IS BOUND.
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
              IF ajson_default IS NOT BOUND.
                ajson_default = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty(
                                          ii_custom_mapping = mapper_upper( ) ) ).
              ENDIF.
              ajson = ajson_default.
            ENDIF.

            ajson->set( iv_ignore_empty = abap_false
                        iv_path         = `/`
                        iv_val          = <val> ).

            IF lr_attri->custom_filter IS BOUND.
              ajson = ajson->filter( lr_attri->custom_filter ).
            ENDIF.

            ajson_result->set( iv_path = lr_attri->name_client
                               iv_val  = ajson ).
            CONTINUE.
          ENDIF.

          ajson_result->set( iv_ignore_empty = abap_false
                             iv_path         = lr_attri->name_client
                             iv_val          = <val> ).
        ENDLOOP.

        result = ajson_result->stringify( ).
        IF result IS INITIAL.
          result = `{}`.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD main_attri_db_load.

    main_attri_db_load_resolve( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref IS NOT INITIAL.
      CASE lr_attri->type_kind.
        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table.
          main_attri_db_load_table( lr_attri ).
        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
          main_attri_db_load_dref( lr_attri ).
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_load_resolve.

    " Only the rows that CARRY a payload are touched: everything the search
    " needs from the other rows travels with them (type_name, type_kind,
    " kind), and a row is resolved fresh whenever it is read or written
    " (attri_get_val_ref). This loop used to visit every row without an
    " owner - a dynamic ASSIGN and an RTTI call each - only to rebuild the
    " descriptor the prefilter no longer reads.
    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref IS INITIAL
               AND srtti_data IS NOT INITIAL.

      " Resolving the attribute is allowed to fail quietly: a draft outlives
      " the class it was taken from, so an attribute that was renamed or
      " deleted since simply has no address any more.
      TRY.
          DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
        CATCH cx_root.
          " ...with one exception: a row that sits behind a reference the
          " save cleared - a dref whose target is itself a dref (`MR_REF->*`
          " holds the payload, `MR_REF` was cleared, so `MO_APP->MR_REF->*`
          " has no address). The outer reference is re-created here so the
          " inner one can be put back below; only a generic REF TO data
          " parent can take the new object, a typed one fails the
          " assignment and keeps the lenient treatment
          IF lr_attri->name_parent IS INITIAL.
            CONTINUE.
          ENDIF.
          TRY.
              lr_ref = dref_parent_recreate( lr_attri->name_parent ).
              lr_ref = attri_get_val_ref( lr_attri->name ).
            CATCH cx_root.
              CONTINUE.
          ENDTRY.
      ENDTRY.
      TRY.
          lr_attri->o_typedescr = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( lr_ref ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
      " a row from a draft written before the name travelled with it gets
      " the name here, since the descriptor is at hand anyway; every other
      " legacy row keeps none until a refresh creates the rows again, and
      " the search works without it (attri_search)
      IF lr_attri->type_name IS INITIAL.
        lr_attri->type_name = lr_attri->o_typedescr->absolute_name.
      ENDIF.

      " A reference that is BOUND on the instance the draft is restored
      " against is newer than the payload, and keeps its object: the draft
      " was written when this app went onto the stack, the live instance
      " came back through the callee's draft after the callee ran - and
      " whatever the callee wrote through that reference is in the object,
      " not in the payload (db_load_by_app). A fresh instance from the
      " draft has every reference detached, so it always takes the payload;
      " and the way back through get_app( id ) used to parse the same
      " payload a second time into the object the first parse had built
      ASSIGN lr_ref->* TO FIELD-SYMBOL(<live>).
      IF <live> IS NOT INITIAL.
        CLEAR lr_attri->srtti_data.
        CONTINUE.
      ENDIF.

      " Bringing the data BACK is a different matter, and it must not fail
      " quietly. main_attri_db_save_srtti has just CLEARED the live reference
      " (the data lives in srtti_data until this line puts it back), so a
      " swallowed failure here leaves the running app holding an unbound
      " reference and an empty table - with nothing raised, nothing logged
      " and nothing to search for. The app renders the round-trip it is in
      " correctly (main_end serializes the model BEFORE db_save) and comes
      " back EMPTY on the next one, which reads as "the view lost its
      " binding" rather than as the state failure it is.
      "
      " Where it surfaces: db_load restores a draft with no TRY of its own, so
      " the round-trip that reads a draft it cannot bring back now answers with
      " the framework's own 500 and the full exception chain - naming the
      " attribute instead of rendering an empty view. all_xml_stringify, which
      " restores in place right after saving, keeps its own recovery: it is
      " written for a main_attri_db_load( ) that can raise and only takes its
      " bare retry when the restore worked (`lv_restored`) - a branch that was
      " unreachable while every failure was caught here.
      "
      " Scoped to attributes the VIEW is bound to - the attribute itself or
      " one of its dissolved children (the data of a dref that dereferences
      " to a table is stored on the PARENT, while the bind flag sits on the
      " `<name>->*` child). Data no view reads keeps the lenient treatment:
      " a scratch reference of an exotic type is no reason to end a session.
      TRY.
          ASSIGN lr_ref->* TO FIELD-SYMBOL(<val>).
          <val> = z2ui5_cl_ui5_util_context=>xml_srtti_parse( lr_attri->srtti_data ).
          CLEAR lr_attri->srtti_data.
        CATCH cx_root INTO DATA(x).
          IF check_attri_bound( lr_attri->name ) = abap_false.
            CONTINUE.
          ENDIF.
          RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
            EXPORTING
              val      = |APP_STATE_RESTORE_ERROR - the data of attribute '{ lr_attri->name }' | &&
                         |could not be restored from the draft|
              previous = x.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD dref_parent_recreate.

    FIELD-SYMBOLS <parent> TYPE any.
    DATA lr_new TYPE REF TO data.

    result = attri_get_val_ref( iv_name ).
    ASSIGN result->* TO <parent>.
    IF <parent> IS NOT INITIAL.
      RETURN.
    ENDIF.
    " a data object of type REF TO data - the outer reference points at it,
    " the restore of the child row fills it
    CREATE DATA lr_new TYPE REF TO data.
    <parent> = lr_new.

  ENDMETHOD.

  METHOD check_attri_bound.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE bind = abap_true.
      IF lr_attri->name = iv_name OR lr_attri->name_parent = iv_name.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_db_load_table.

    " a row whose owner cannot be reached is skipped, like an unreachable
    " row in main_attri_db_load_resolve: the draft outlives the class it was
    " taken from, and a host that holds its sub-app in a REF TO object can
    " have swapped it for an instance of another class (sample 338) - the
    " rows of the old class name attributes the new one does not have
    DATA lr_ref_source TYPE REF TO data.
    TRY.
        lr_ref_source = attri_get_val_ref( ir_attri->name_ref ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    READ TABLE mt_attri->* REFERENCE INTO DATA(lr_attri_parent)
         WITH TABLE KEY name = ir_attri->name_parent.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    " only a data reference can be pointed at the owner's object - the
    " alias pass pairs no other row as an alias (check_alias_capable), and
    " a draft that says otherwise is not followed into a typed attribute
    IF lr_attri_parent->type_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
      RETURN.
    ENDIF.

    DATA(lv_parent_path) = |MO_APP->{ lr_attri_parent->name }|.
    ASSIGN (lv_parent_path) TO FIELD-SYMBOL(<parent_ref>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ASSIGN lr_ref_source->* TO FIELD-SYMBOL(<source_value>).
    GET REFERENCE OF <source_value> INTO <parent_ref>.

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

  ENDMETHOD.

  METHOD main_attri_db_save_srtti.

    " what an earlier save on this instance detached is gone: put back by
    " main_attri_reattach, or replaced by the parse of main_attri_db_load.
    " Kept, it would be what a later reattach hands out - the objects of
    " a previous roundtrip, silently, because the INSERT below cannot
    " replace an entry of the same name (found by live_recreated_same_type)
    CLEAR mt_detached.

    dissolve( ).

    " every data reference of the instance, resolved ONCE: the address of
    " the reference variable is kept for the detach below, the target it
    " points at is described and stored here. Two passes on purpose: a
    " reference whose target is itself a reference (`MR_REF->*` holds the
    " payload) is reached through its parent, which has to stay bound
    " until every payload is taken
    DATA lt_dref TYPE ty_t_ref_idx.
    FIELD-SYMBOLS <dref>      TYPE any.
    FIELD-SYMBOLS <val_deref> TYPE any.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.

      DATA(lv_path_dref) = |MO_APP->{ lr_attri->name }|.
      " UNASSIGN + IS ASSIGNED, not sy-subrc - see main_attri_reattach
      UNASSIGN <dref>.
      ASSIGN (lv_path_dref) TO <dref>.
      IF <dref> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      INSERT VALUE #( name = lr_attri->name
                      ref  = REF #( <dref> ) ) INTO TABLE lt_dref.

      " a payload only for a reference that OWNS its target - an alias
      " (name_ref) is pointed at its owner again on the load - and that
      " points at something
      IF lr_attri->name_ref IS NOT INITIAL OR <dref> IS INITIAL.
        CONTINUE.
      ENDIF.
      UNASSIGN <val_deref>.
      ASSIGN <dref>->* TO <val_deref>.
      IF <val_deref> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      DATA(lo_descr) = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data( <val_deref> ).

      CASE lo_descr->type_kind.

        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table.

          " a dref whose deref is a TABLE has exactly ONE dissolved child:
          " diss_dref's non-struct branch creates the single `<name>->*` row
          " (only a struct deref fans out into several children, and that
          " case is the struct branch below). The child row IS the deref
          " resolved above; the loop exists to pair the WHERE filter with a
          " no-match fallthrough, so the unconditional EXIT states that it
          " can never have a second row to visit. Only the REFERENCE is
          " detached (below) - the table itself stays as it is, and
          " main_attri_reattach hands it back to the live instance untouched
          LOOP AT mt_attri->* TRANSPORTING NO FIELDS USING KEY parent
               WHERE name_parent = lr_attri->name
                     AND name_ref IS INITIAL
                     AND type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table.
            lr_attri->srtti_data = z2ui5_cl_ui5_util_context=>xml_srtti_stringify( <val_deref> ).
            EXIT.
          ENDLOOP.

        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_struct1 OR z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_struct2.
          lr_attri->srtti_data = z2ui5_cl_ui5_util_context=>xml_srtti_stringify( <val_deref> ).

        WHEN OTHERS.
          " an ELEMENTARY deref (CREATE DATA mr TYPE string / i / ...) is
          " neither a table (one dissolved child, above) nor a structure and
          " used to fall through this CASE: the detach below then cleared the
          " reference and nothing ever restored it, so a bound `mr->*` was
          " gone after the first roundtrip - in memory and in the draft.
          " Same stringify as the struct branch, restored the same way by
          " main_attri_db_load_resolve. A deref that is itself a reference
          " is left alone: S-RTTI cannot serialize it, and clearing it is
          " what happened before
          IF lo_descr->kind = z2ui5_cl_ui5_util_context=>cv_typedescr_kind_elem.
            lr_attri->srtti_data = z2ui5_cl_ui5_util_context=>xml_srtti_stringify( <val_deref> ).
          ENDIF.

      ENDCASE.

    ENDLOOP.

    " the detach, over the addresses resolved above. Clearing the ref
    " detaches the target data object from serialization; dereferencing
    " and clearing the target itself is unnecessary. The reference is kept
    " aside for main_attri_reattach - the live instance gets the same
    " object back instead of a parsed copy
    LOOP AT lt_dref REFERENCE INTO DATA(lr_dref).
      ASSIGN lr_dref->ref->* TO <dref>.
      IF <dref> IS BOUND.
        INSERT VALUE #( name = lr_dref->name
                        ref  = <dref> ) INTO TABLE mt_detached.
      ENDIF.
      CLEAR <dref>.
    ENDLOOP.

  ENDMETHOD.

  METHOD main_attri_reattach.

    FIELD-SYMBOLS <dref> TYPE any.

    LOOP AT mt_detached REFERENCE INTO DATA(lr_detached).
      DATA(lv_path) = |MO_APP->{ lr_detached->name }|.
      " IS ASSIGNED after an UNASSIGN, not sy-subrc: a successful dynamic
      " ASSIGN does not reset sy-subrc on every release (#1937), and inside
      " this loop the symbol still points at the previous row's reference
      " when the ASSIGN fails - see attri_get_val_ref
      UNASSIGN <dref>.
      ASSIGN (lv_path) TO <dref>.
      IF <dref> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      <dref> = lr_detached->ref.
    ENDLOOP.
    CLEAR mt_detached.

    " the payloads served their purpose in the draft; on the live rows they
    " would only be stale by the next save, which writes them again
    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL.
      CLEAR lr_attri->srtti_data.
    ENDLOOP.

  ENDMETHOD.

  METHOD ref_idx_put.

    READ TABLE mt_ref_idx REFERENCE INTO DATA(lr_idx) WITH TABLE KEY name = iv_name.
    IF sy-subrc = 0.
      lr_idx->ref = ir_ref.
    ELSE.
      INSERT VALUE #( name = iv_name
                      ref  = ir_ref ) INTO TABLE mt_ref_idx.
    ENDIF.

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

    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the bound values are public attributes of your class`.

  ENDMETHOD.

  METHOD attri_get_val_ref.

    " The dynamic ASSIGN below is resolved FRESH on every call. The rule
    " used to be "no cache at all" (maintainer decision, 2026-08); it was
    " revised in 2026-09 to "a cache is a prefilter, never an answer", and
    " the paragraph below is why the answer half must stay. The name->ref
    " mapping is not stable enough to be an answer by itself: apps create and
    " re-point REF TO data attributes at runtime, dissolve( ) rebuilds
    " mt_attri, and app code in main( ) may swap a dref target between any
    " two calls. A reference taken from a cache then points at the old,
    " detached data object and fails SILENTLY - the bind reads or writes a
    " copy, values go stale without an exception, and that class of defect
    " has only ever been found by users on real systems (see #1937 for how
    " differently ASSIGN behaves across releases). So every read and write
    " of a value goes through this method, and the one index the instance
    " keeps (mt_ref_idx) is a PREFILTER for the binding search whose every
    " hit is confirmed here before it counts - see attri_search.
    FIELD-SYMBOLS <attri> TYPE any.

    IF iv_path IS INITIAL.
      ASSIGN mo_app TO <attri>.
    ELSE.
      DATA(lv_name) = |MO_APP->{ iv_path }|.
      ASSIGN (lv_name) TO <attri>.
    ENDIF.

    IF <attri> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

    GET REFERENCE OF <attri> INTO result.
    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `ATTRI_GET_VAL_REF_ERROR`.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    mt_attri = attri.
    mo_app = app.

  ENDMETHOD.

  METHOD attri_search.

    DATA(lo_datadescr) = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( val ).

    IF lo_datadescr->type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref
        OR lo_datadescr->type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_oref.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `NO DATA REFERENCES FOR BINDING ALLOWED: DEREFERENCE YOUR DATA FIRST`.
    ENDIF.

    " first the index: a row this instance resolved before that pointed at
    " exactly this data object. The hit is confirmed by a fresh ASSIGN - an
    " app that re-pointed the reference since is caught here, and the scan
    " below then decides as if there had been no index
    LOOP AT mt_ref_idx REFERENCE INTO DATA(lr_idx) WHERE ref = val. "#EC CI_SORTSEQ
      READ TABLE mt_attri->* REFERENCE INTO DATA(lr_hit)
           WITH TABLE KEY name = lr_idx->name.
      IF sy-subrc <> 0 OR lr_hit->name_ref IS NOT INITIAL
          OR lr_hit->type_kind <> lo_datadescr->type_kind
          OR lr_hit->kind <> lo_datadescr->kind.
        CONTINUE.
      ENDIF.
      TRY.
          DATA(lr_fresh) = attri_get_val_ref( lr_hit->name ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
      lr_idx->ref = lr_fresh.
      IF lr_fresh = val.
        result = lr_hit.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE name_ref IS INITIAL
               AND type_kind = lo_datadescr->type_kind
               AND kind = lo_datadescr->kind.

      " compare by name - descriptor instances are not stable in the
      " abaplint transpiler runtime; the data reference check below is
      " the definitive match, this is only a prefilter. Generated names
      " of anonymous types (containing %) are not comparable either.
      " The name is the row's own STRING (type_name), written when the row
      " was created: the descriptor it came from is an object reference
      " that does not survive the draft, and re-resolving it for every row
      " of a restored draft cost one dynamic ASSIGN and one RTTI call per
      " row on every load - for a prefilter. A row without a name (a draft
      " written before the component existed) skips the prefilter, not the
      " row: the data-reference compare below still decides
      IF lr_attri->type_name IS NOT INITIAL.
        DATA(lv_name_val) = lo_datadescr->absolute_name.
        IF lr_attri->type_name <> lv_name_val
            AND lr_attri->type_name NS `%`
            AND lv_name_val NS `%`.
          CONTINUE.
        ENDIF.
      ENDIF.

      TRY.
          DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
      ref_idx_put( iv_name = lr_attri->name
                   ir_ref  = lr_ref ).

      IF lr_ref = val.
        result = lr_attri.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD attri_create_new.

    DATA(lr_ref) = attri_get_val_ref( name ).
    ref_idx_put( iv_name = name
                 ir_ref  = lr_ref ).
    DATA(lo_descr) = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( lr_ref ).
    result = VALUE z2ui5_if_ui5_types=>ty_s_attri( name         = name
                                                    o_typedescr = lo_descr
                                                    type_name   = lo_descr->absolute_name
                                                    type_kind   = lo_descr->type_kind
                                                    kind        = lo_descr->kind ).

  ENDMETHOD.

  METHOD diss_dref.

    DATA(lr_ref_tmp) = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_ui5_util_context=>check_unassign_initial( lr_ref_tmp ).
      RETURN.
    ENDIF.

    DATA(lr_ref) = z2ui5_cl_ui5_util_context=>unassign_data( lr_ref_tmp ).
    IF lr_ref IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_attri2) = VALUE z2ui5_if_ui5_types=>ty_s_attri( ).
    ls_attri2-o_typedescr = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( lr_ref ).

    CASE ls_attri2-o_typedescr->kind.

      WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_kind_struct.
        DATA(lt_attri) = diss_struc( ir_attri ).
        INSERT LINES OF lt_attri INTO TABLE result.

      WHEN OTHERS.

        ls_attri2-name        = |{ ir_attri->name }->*|.
        ls_attri2-name_parent = ir_attri->name.
        ls_attri2-type_name   = ls_attri2-o_typedescr->absolute_name.
        ls_attri2-type_kind   = ls_attri2-o_typedescr->type_kind.
        ls_attri2-kind        = ls_attri2-o_typedescr->kind.
        INSERT ls_attri2 INTO TABLE result.

    ENDCASE.

  ENDMETHOD.

  METHOD diss_oref.

    DATA(lr_val) = attri_get_val_ref( ir_attri->name ).

    IF z2ui5_cl_ui5_util_context=>check_unassign_initial( lr_val ).
      RETURN.
    ENDIF.

    DATA(lr_ref) = z2ui5_cl_ui5_util_context=>unassign_object( lr_val ).
    DATA(lt_attri) = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_oref( lr_ref ).

    DATA(lv_prefix) = COND string( WHEN ir_attri->name IS NOT INITIAL THEN |{ ir_attri->name }->| ).

    LOOP AT lt_attri REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE visibility   = z2ui5_cl_ui5_util_context=>cv_objectdescr_public
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

    IF ir_attri->o_typedescr->kind = z2ui5_cl_ui5_util_context=>cv_typedescr_kind_ref.
      DATA(lv_name) = |{ ir_attri->name }->|.
      DATA(lr_ref) = z2ui5_cl_ui5_util_context=>unassign_data( lr_val ).
    ELSE.
      lv_name = |{ ir_attri->name }-|.
      lr_ref = lr_val.
    ENDIF.

    IF lr_ref IS BOUND.
      DATA(lt_attri) = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( lr_ref ).

      LOOP AT lt_attri INTO DATA(ls_attri).
        DATA(ls_new) = attri_create_new( lv_name && ls_attri-name ).
        ls_new-name_parent = ir_attri->name.
        INSERT ls_new INTO TABLE result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD dissolve.

    " DO ... TIMES with the pending check inside the body, not
    " WHILE line_exists( ... ): the v702 downport of the transpiled browser
    " build hoists the LINE_EXISTS read out of a WHILE condition and
    " evaluates it once, before the loop. With an initially empty table that
    " single evaluation says "nothing pending" forever, so only the first
    " pass ran and nested components (MS_NESTED-INNER-DEEP1) were never
    " resolved. The pass count is NOT the cycle guard - that is the hop
    " count per name in dissolve_run - it only has to be large enough for
    " the deepest structure an app nests (five passes were not: a leaf
    " eight components down, sample 138, was never reached and answered
    " with BINDING_ERROR)
    DO max_dissolve_passes TIMES.

      " EXIT, not RETURN - attri_update_entry_refs must still run for the
      " already dissolved rows, otherwise name_ref stays empty and the
      " serialize/deserialize ref de-duplication silently breaks
      IF mt_attri->* IS NOT INITIAL
          AND NOT line_exists( mt_attri->*[ check_dissolved = abap_false ] ). "#EC CI_SORTSEQ
        EXIT.
      ENDIF.

      TRY.
          dissolve_run( ).
        CATCH cx_root.
          " main_attri_refresh dissolves again - a dissolve_run that keeps
          " raising would recurse without end. One refresh per dissolve;
          " the second failure ends the pass with what was resolved so far
          IF mv_dissolve_refreshing = abap_true.
            EXIT.
          ENDIF.
          mv_dissolve_refreshing = abap_true.
          main_attri_refresh( ).
          mv_dissolve_refreshing = abap_false.
      ENDTRY.

    ENDDO.

    attri_update_entry_refs( ).

  ENDMETHOD.

  METHOD attri_update_entry_refs.

    " Every dissolved row is resolved ONCE here - one dynamic ASSIGN per
    " row, fresh (see attri_get_val_ref for why a stored reference is no
    " answer) - and the pairing runs over the resolved list: the same
    " O(n^2) compare as before, on references instead of on ASSIGNs.
    DATA lt_resolved TYPE ty_t_resolved.
    FIELD-SYMBOLS <ref> TYPE any.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_true.
      TRY.
          DATA(lr_ref) = attri_get_val_ref( lr_attri->name ).
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
      ref_idx_put( iv_name = lr_attri->name
                   ir_ref  = lr_ref ).
      DATA(ls_resolved) = VALUE ty_s_resolved( name      = lr_attri->name
                                               type_kind = lr_attri->type_kind
                                               attri     = lr_attri
                                               ref       = lr_ref ).
      IF lr_attri->type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
        ASSIGN lr_ref->* TO <ref>.
        ls_resolved-deref = <ref>.
      ENDIF.
      INSERT ls_resolved INTO TABLE lt_resolved.
    ENDLOOP.

    " the aliases already known come first: one that no longer holds is
    " dropped here and paired again below
    LOOP AT lt_resolved REFERENCE INTO DATA(lr_res).
      IF lr_res->attri->name_ref IS NOT INITIAL.
        entry_refs_recheck( ir_res      = lr_res
                            it_resolved = lt_resolved ).
      ENDIF.
    ENDLOOP.

    LOOP AT lt_resolved REFERENCE INTO lr_res.
      IF lr_res->attri->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      CASE lr_res->type_kind.
        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table.
          entry_refs_pair_table( ir_res      = lr_res
                                 it_resolved = lt_resolved ).
        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
          entry_refs_pair_dref( ir_res      = lr_res
                                it_resolved = lt_resolved ).
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD entry_refs_pair_table.

    IF check_alias_capable( ir_res->name ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT it_resolved REFERENCE INTO DATA(lr_other) "#EC CI_SORTSEQ
         WHERE type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table
               AND ref = ir_res->ref
               AND name <> ir_res->name.
      IF lr_other->attri->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      ir_res->attri->name_ref = lr_other->name.
    ENDLOOP.

  ENDMETHOD.

  METHOD entry_refs_recheck.

    DATA lv_holds TYPE abap_bool.

    READ TABLE it_resolved REFERENCE INTO DATA(lr_owner)
         WITH TABLE KEY name = ir_res->attri->name_ref.
    IF sy-subrc = 0.
      " a table row points at the owner's object; a data reference (the
      " struct alias) dereferences to it
      IF ir_res->type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
        lv_holds = xsdbool( ir_res->deref IS BOUND AND ir_res->deref = lr_owner->ref ).
      ELSE.
        lv_holds = xsdbool( ir_res->ref = lr_owner->ref ).
      ENDIF.
    ENDIF.
    IF lv_holds = abap_true.
      RETURN.
    ENDIF.

    CLEAR ir_res->attri->name_ref.
    " the children of a struct alias carry `<owner>-<component>` - gone
    " with the owner; a new owner rewrites them (attri_update_refs_children)
    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_child) USING KEY parent
         WHERE name_parent = ir_res->name.
      CLEAR lr_child->name_ref.
    ENDLOOP.

  ENDMETHOD.

  METHOD check_alias_capable.

    DATA(lv_len) = strlen( iv_name ).
    IF lv_len < 3.
      RETURN.
    ENDIF.
    DATA(lv_off) = lv_len - 3.
    result = xsdbool( iv_name+lv_off(3) = `->*` ).

  ENDMETHOD.

  METHOD entry_refs_pair_dref.

    IF ir_res->deref IS NOT BOUND.
      RETURN.
    ENDIF.

    LOOP AT it_resolved REFERENCE INTO DATA(lr_other) "#EC CI_SORTSEQ
         WHERE (    type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_struct1
                 OR type_kind = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_struct2 )
               AND ref = ir_res->deref
               AND name <> ir_res->name.
      IF lr_other->attri->name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      " several dissolved struct attributes can address the SAME data
      " object (a nested component and the ref target pointing at it).
      " Of those candidates keep the one with the SHORTEST name - the
      " outermost, least-nested spelling of the owner - as the
      " canonical name_ref: a candidate replaces an already-set
      " name_ref only when its own name is strictly shorter, so the
      " children rewritten from it (attri_update_refs_children,
      " `<name_ref>-<component>`) get the shortest stable paths too
      IF ir_res->attri->name_ref IS NOT INITIAL
          AND strlen( ir_res->attri->name_ref ) <= strlen( lr_other->name ).
        CONTINUE.
      ENDIF.

      ir_res->attri->name_ref = lr_other->name.
      attri_update_refs_children( ir_res->attri ).
    ENDLOOP.

  ENDMETHOD.

  METHOD attri_update_refs_children.

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri_child) USING KEY parent
         WHERE name_parent = ir_attri->name.
      DATA(lv_name) = shift_left( val = lr_attri_child->name
                                  sub = |{ ir_attri->name }->| ).
      lr_attri_child->name_ref = |{ ir_attri->name_ref }-{ lv_name }|.
    ENDLOOP.

  ENDMETHOD.

  METHOD dissolve_run.

    IF mt_attri->* IS INITIAL.
      DATA(ls_attri) = VALUE z2ui5_if_ui5_types=>ty_s_attri( ).
      DATA(lt_init) = diss_oref( REF #( ls_attri ) ).
      INSERT LINES OF lt_init INTO TABLE mt_attri->*.
    ENDIF.

    DATA(lt_attri_new) = VALUE z2ui5_if_ui5_types=>ty_t_attri( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri)   "#EC CI_SORTSEQ
         WHERE check_dissolved = abap_false.

      lr_attri->check_dissolved = abap_true.

      IF lr_attri->o_typedescr IS NOT BOUND.
        DATA(ls_entry) = attri_create_new( lr_attri->name ).
        lr_attri->o_typedescr = ls_entry-o_typedescr.
      ENDIF.

      " a reference more than max_dissolve_depth hops down stays a leaf: an
      " object graph can be cyclic (an attribute pointing back at its owner,
      " a helper holding the app), and every hop is another `->` in the name
      IF lr_attri->o_typedescr->kind = z2ui5_cl_ui5_util_context=>cv_typedescr_kind_ref
          AND count( val = lr_attri->name
                     sub = `->` ) >= max_dissolve_depth.
        CONTINUE.
      ENDIF.

      CASE lr_attri->o_typedescr->kind.

        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_kind_struct.
          DATA(lt_attri_struc) = diss_struc( lr_attri ).
          INSERT LINES OF lt_attri_struc INTO TABLE lt_attri_new.

        WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_kind_ref.

          CASE lr_attri->o_typedescr->type_kind.

            WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_oref.
              DATA(lt_attri_oref) = diss_oref( lr_attri ).
              INSERT LINES OF lt_attri_oref INTO TABLE lt_attri_new.
            WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
              DATA(lt_attri_dref) = diss_dref( lr_attri ).
              INSERT LINES OF lt_attri_dref INTO TABLE lt_attri_new.
            WHEN OTHERS.
              " an unexpected ref type_kind is left as a non-dissolvable leaf -
              " an ASSERT here would raise the uncatchable ASSERTION_FAILED and
              " defeat the TRY/CATCH around dissolve_run, dumping the whole request
          ENDCASE.
        WHEN OTHERS.
          " same as above: an unknown typedescr kind stays a non-dissolvable leaf
      ENDCASE.

    ENDLOOP.

    INSERT LINES OF lt_attri_new INTO TABLE mt_attri->*.

  ENDMETHOD.

  METHOD main_attri_refresh.

    DATA(lt_attri) = mt_attri->*.
    DELETE lt_attri WHERE bind = abap_false.            "#EC CI_SORTSEQ
    CLEAR mt_attri->*.

    dissolve( ).

    LOOP AT mt_attri->* REFERENCE INTO DATA(lr_attri).
      READ TABLE lt_attri REFERENCE INTO DATA(lr_old) WITH KEY name = lr_attri->name. "#EC CI_SORTSEQ
      IF sy-subrc = 0.
        " restore everything update_model_attri stored on the bound attribute -
        " dropping the mapper/filter refs here would silently serialize the
        " attribute unmapped after a refresh
        lr_attri->bind          = lr_old->bind.
        lr_attri->name_client   = lr_old->name_client.
        lr_attri->custom_mapper = lr_old->custom_mapper.
        lr_attri->custom_filter = lr_old->custom_filter.
        lr_attri->check_json    = lr_old->check_json.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_apply_to_table.

    TRY.
        DATA(lr_ref_d) = attri_get_val_ref( iv_name ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    " a SORTED or HASHED table: the frontend has no notion of the table
    " kind and ships the same 0-based row delta, but a row edit through an
    " index is not a write this shape allows (a key write on a sorted
    " table is a runtime error, a hashed table has no index at all). The
    " edit used to vanish here with a bare RETURN - the browser kept
    " showing what the user typed and nothing recorded that the backend
    " had refused it. Now every cell lands in t_model_skipped, so the app
    " can react (or bind a standard table, which the whole-table path
    " always wrote back).
    " Decided by RTTI, not by the ASSIGN below: on a system an ASSIGN of a
    " sorted table to a TYPE STANDARD TABLE field symbol is the runtime
    " error ASSIGN_TYPE_CONFLICT, not sy-subrc 4 - the transpiler answers
    " with the subrc, which is how that version passed the suite (found by a
    " user's system, 2026-09-02)
    " no slice( ) of the __delta node: slicing walks and copies every node
    " of the tree it is called on (a CP compare per node), and the rows are
    " reachable by path just as well - members( ) and the typed get_* calls
    " are keyed reads on the sorted node table
    DATA(lv_delta) = |{ iv_path }/__delta|.

    IF check_table_standard( lr_ref_d ) = abap_false.
      delta_skip_nodes( io_delta = io_val_front
                        iv_base  = lv_delta
                        iv_table = iv_name ).
      RETURN.
    ENDIF.

    FIELD-SYMBOLS <delta_tab> TYPE STANDARD TABLE.
    ASSIGN lr_ref_d->* TO <delta_tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    delta_apply_nodes( EXPORTING io_delta = io_val_front
                                 iv_base  = lv_delta
                                 iv_table = iv_name
                       CHANGING  ct_tab   = <delta_tab> ).

  ENDMETHOD.

  METHOD delta_apply_nodes.

    FIELD-SYMBOLS <work_row> TYPE any.
    FIELD-SYMBOLS <before>   TYPE any.
    DATA lr_work_row TYPE REF TO data.
    DATA lt_col_kind TYPE ty_t_col_kind.

    " ONE work row per table for the old values delta_apply_field keeps
    " aside - a select-all toggle over a thousand rows used to allocate a
    " data object per cell for that copy
    CREATE DATA lr_work_row LIKE LINE OF ct_tab.
    ASSIGN lr_work_row->* TO <work_row>.

    DATA(lt_idx) = io_delta->members( iv_base ).
    LOOP AT lt_idx INTO DATA(lv_idx_str).
      DATA(lv_tabix) = delta_row_index( lv_idx_str ).
      IF lv_tabix = 0.
        CONTINUE.
      ENDIF.
      FIELD-SYMBOLS <delta_row> TYPE any.
      READ TABLE ct_tab INDEX lv_tabix ASSIGNING <delta_row>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      " no slice( ) per row: slicing walks and copies the WHOLE delta tree
      " for every changed row (O(rows^2) on a mass edit such as a
      " select-all toggle). members( ) and the typed get_* calls below are
      " keyed reads on the sorted node table, so the row is addressed by
      " its full path instead
      DATA(lv_row_path) = |{ iv_base }/{ lv_idx_str }|.
      DATA(lt_fld) = io_delta->members( lv_row_path ).
      LOOP AT lt_fld INTO DATA(lv_fld).
        FIELD-SYMBOLS <comp> TYPE any.
        ASSIGN COMPONENT lv_fld OF STRUCTURE <delta_row> TO <comp>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        ASSIGN COMPONENT lv_fld OF STRUCTURE <work_row> TO <before>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        delta_apply_field( EXPORTING io_delta    = io_delta
                                     iv_path     = |{ lv_row_path }/{ lv_fld }|
                                     is_cell     = VALUE #( name       = iv_table
                                                            row        = lv_tabix
                                                            field      = lv_fld
                                                            row_parent = iv_row_parent )
                                     ir_comp     = REF #( <comp> )
                                     ir_before   = REF #( <before> )
                           CHANGING  ct_col_kind = lt_col_kind ).
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_skip_nodes.

    DATA(lt_idx) = io_delta->members( iv_base ).
    LOOP AT lt_idx INTO DATA(lv_idx_str).
      DATA(lv_tabix) = delta_row_index( lv_idx_str ).
      IF lv_tabix = 0.
        CONTINUE.
      ENDIF.
      DATA(lv_row_path) = |{ iv_base }/{ lv_idx_str }|.
      DATA(lt_fld) = io_delta->members( lv_row_path ).
      LOOP AT lt_fld INTO DATA(lv_fld).
        DATA(ls_skip) = VALUE z2ui5_if_client=>ty_s_model_skip( name        = iv_table
                                                                 row        = lv_tabix
                                                                 field      = lv_fld
                                                                 row_parent = iv_row_parent ).
        TRY.
            ls_skip-value = io_delta->get_string( |{ lv_row_path }/{ lv_fld }| ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
        APPEND ls_skip TO mt_skipped.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD delta_row_index.

    TRY.
        result = CONV i( iv_key ) + 1.
      CATCH cx_root.
        result = 0.
    ENDTRY.
    IF result < 1.
      result = 0.
    ENDIF.

  ENDMETHOD.

  METHOD check_table_standard.

    result = z2ui5_cl_ui5_util_context=>rtti_check_table_standard( ir_ref ).

  ENDMETHOD.

  METHOD mapper_upper.

    IF gi_mapper_upper IS NOT BOUND.
      gi_mapper_upper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
    ENDIF.
    result = gi_mapper_upper.

  ENDMETHOD.

  METHOD delta_apply_scalar.

    FIELD-SYMBOLS <comp> TYPE any.
    ASSIGN ir_comp->* TO <comp>.

    " numbers intentionally go through get_string: the raw JSON text
    " converts losslessly into any numeric target type, while get_number
    " would round through a binary float first
    DATA(lv_value) = io_delta->get_string( iv_path ).

    " Outbound, ajson writes a d as `2024-01-15`, a t as `12:30:00` and a
    " timestamp as `2024-01-15T12:30:00Z` (its own format_date/_time/
    " _timestamp), and the whole-attribute path (to_abap) parses those
    " forms back. A delta cell assigned the raw text instead: the c->d
    " conversion copies the first eight characters WITHOUT validation, so
    " `2024-01-15` silently became `2024-01-` - no exception, no
    " t_model_skipped entry, and the next serialization shipped garbage.
    " Only the ISO spelling is unpacked here; any other text (a plain
    " `20240115`, an empty cleared value) keeps the direct assignment, so a
    " cell that never went through ajson's formatting stays as it was.
    CASE z2ui5_cl_ui5_util_context=>rtti_get_type_kind( <comp> ).

      WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_date.
        IF strlen( lv_value ) >= 10 AND lv_value+4(1) = `-` AND lv_value+7(1) = `-`.
          lv_value = lv_value(4) && lv_value+5(2) && lv_value+8(2).
        ENDIF.

      WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_time.
        IF strlen( lv_value ) >= 8 AND lv_value+2(1) = `:` AND lv_value+5(1) = `:`.
          lv_value = lv_value(2) && lv_value+3(2) && lv_value+6(2).
        ENDIF.

      WHEN z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_packed.
        " a TIMESTAMP/TIMESTAMPL is a packed number on the ABAP side and an
        " ISO instant on the wire; the `T` at offset 10 is what tells it
        " from a price. get_timestampl parses both spellings (Z, +hh:mm),
        " and the p-to-p assignment drops the fraction a short timestamp
        " does not carry
        IF strlen( lv_value ) >= 19 AND lv_value+10(1) = `T`.
          <comp> = io_delta->get_timestampl( iv_path ).
          RETURN.
        ENDIF.

    ENDCASE.

    <comp> = lv_value.

  ENDMETHOD.

  METHOD delta_apply_field.

    FIELD-SYMBOLS <comp>   TYPE any.
    FIELD-SYMBOLS <before> TYPE any.
    ASSIGN ir_comp->* TO <comp>.

    " the OLD value, kept aside: on a system a conversion that fails (`abc`
    " into a packed field, `seven` into an integer) clears the target before
    " it raises, and to_abap clears it before it fills - so "the cell is
    " skipped and the old value stands" was only true in the transpiled
    " suite, where the target survives a failed conversion. A user's system
    " showed the refused cells at zero (2026-09-02); the copy below is what
    " the trace entry promises. It lands in the caller's work row (one per
    " table), not in a data object allocated per cell
    ASSIGN ir_before->* TO <before>.
    <before> = <comp>.

    " iv_path addresses the cell in the caller's delta tree directly - the
    " scalar branches below are keyed reads, so no per-row sub-tree has to
    " be sliced off first. Only the two rare whole-value branches still
    " slice, and only the one component they need
    TRY.
        CASE io_delta->get_node_type( iv_path ).

          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            <comp> = io_delta->get_boolean( iv_path ).

          WHEN z2ui5_if_ajson_types=>node_type-object.
            " either a nested table delta (marked by __delta) or a
            " structure component shipped as a whole value
            DATA(lv_sub_delta) = |{ iv_path }/__delta|.
            IF io_delta->exists( lv_sub_delta ) = abap_true.
              FIELD-SYMBOLS <sub_tab> TYPE STANDARD TABLE.
              " the table kind first, the ASSIGN second - see
              " delta_apply_to_table. Asked once per COLUMN: the kind is a
              " property of the component's type, the same in every row.
              " That holds because a REF TO data column is not followed
              " here (check_table_standard sees the reference itself and
              " answers no) - a delta through such a column would have to
              " ask per cell again
              READ TABLE ct_col_kind REFERENCE INTO DATA(lr_col_kind)
                   WITH TABLE KEY field = is_cell-field.
              IF sy-subrc <> 0.
                INSERT VALUE #( field    = is_cell-field
                                standard = check_table_standard( ir_comp ) )
                       INTO TABLE ct_col_kind REFERENCE INTO lr_col_kind.
              ENDIF.
              IF lr_col_kind->standard = abap_true.
                ASSIGN ir_comp->* TO <sub_tab>.
              ENDIF.
              IF <sub_tab> IS ASSIGNED.
                " a nested row cell traces under the path to its own table,
                " parent first - MT_TREE-NODES, not MT_TREE - and carries
                " this row's index as its row_parent, so the skipped entry
                " can name the record the inner table belongs to
                delta_apply_nodes( EXPORTING io_delta      = io_delta
                                             iv_base       = lv_sub_delta
                                             iv_table      = |{ is_cell-name }-{ is_cell-field }|
                                             iv_row_parent = is_cell-row
                                   CHANGING  ct_tab        = <sub_tab> ).
              ELSE.
                " a nested SORTED/HASHED table - same refusal, same trace
                " (see delta_apply_to_table)
                delta_skip_nodes( io_delta      = io_delta
                                  iv_base       = lv_sub_delta
                                  iv_table      = |{ is_cell-name }-{ is_cell-field }|
                                  iv_row_parent = is_cell-row ).
              ENDIF.
            ELSE.
              io_delta->slice( iv_path )->to_abap( EXPORTING iv_corresponding = abap_true
                                                   IMPORTING ev_container     = <comp> ).
            ENDIF.

          WHEN z2ui5_if_ajson_types=>node_type-array.
            " a whole sub-table value replaced a nested delta on the client
            io_delta->slice( iv_path )->to_abap( EXPORTING iv_corresponding = abap_true
                                                 IMPORTING ev_container     = <comp> ).

          WHEN OTHERS.
            delta_apply_scalar( io_delta = io_delta
                                iv_path  = iv_path
                                ir_comp  = ir_comp ).
        ENDCASE.

      CATCH cx_root.
        " Skip just this cell - see the method comment - but never silently:
        " the value arrived and did not fit, and without this entry the old
        " value stays in the model while the browser goes on showing what the
        " user typed. Recording it is deliberately ALL that happens here;
        " raising would let one bad cell kill a delta full of good ones,
        " which is the whole reason the skip exists
        <comp> = <before>.
        DATA(ls_skip) = is_cell.
        " quote the refused raw value in the entry - it is one keyed read
        " away, and it is the half a user message actually needs (`'1,250.00'
        " is not a valid price`). Guarded: this RUNS INSIDE A CATCH, and a
        " node get_string cannot read (a structured value) must degrade to
        " an empty value, never replace the trace with a dump
        TRY.
            ls_skip-value = io_delta->get_string( iv_path ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
        APPEND ls_skip TO mt_skipped.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
