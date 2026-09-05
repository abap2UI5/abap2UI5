CLASS z2ui5_cl_ui5_srv_bind DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_app    TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS constructor
      IMPORTING
        app TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS main
      IMPORTING
        val           TYPE REF TO data
        config        TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_client_name
      RETURNING
        VALUE(result) TYPE string.

    METHODS update_model_attri.
    METHODS check_raise_existing.
    METHODS check_raise_new.

    " Take over the ms_config options an ALREADY-bound attribute does not
    " carry yet. See the method body for what used to be dropped.
    METHODS adopt_new_options.

    DATA mr_attri  TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA ms_config TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    " one model service for the life of this bind service - the client
    " keeps one bind service per render, so the search index the model
    " builds on the first _bind( ) serves every _bind( ) of that render
    DATA mo_model  TYPE REF TO z2ui5_cl_ui5_srv_model.

    " the component names of the table the last cell bind addressed - a
    " memo for bind_tab_cell, which used to describe the row type and copy
    " the component table out of the RTTI cache for EVERY cell of the same
    " table (six panels over /Employee/0..5 are dozens of cells per render).
    " Keyed on the table reference: a bind against another table replaces
    " it, and the service lives one render, so it cannot go stale
    DATA mr_cell_tab   TYPE REF TO data.
    DATA mt_cell_names TYPE string_table.

    METHODS get_model
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.

    METHODS main_cell
      IMPORTING
        val           TYPE REF TO data
        config        TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    " The attribute half of main( ): the row the value lives in, its
    " binding recorded or adopted, the path decorated by config. main_cell
    " calls it for the table before it addresses the cell
    METHODS bind_attri
      IMPORTING
        val           TYPE REF TO data
        config        TYPE z2ui5_if_ui5_types=>ty_s_bind_config
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind_tab_cell
      IMPORTING
        iv_name       TYPE string
        iv_val        TYPE REF TO data
      RETURNING
        VALUE(result) TYPE string.

    " Raise when the same attribute is rebound with a different mapper/filter
    " implementation. iv_label names the kind for the error text.
    METHODS check_same_impl
      IMPORTING
        ir_existing TYPE REF TO object
        ir_new      TYPE REF TO object
        iv_label    TYPE string.

    " Raise when a mapper/filter used for a new binding is not serializable.
    " iv_label names the kind for the error text.
    METHODS check_serializable
      IMPORTING
        ir_ref   TYPE REF TO object
        iv_label TYPE string.

    " Apply the ms_config decorations to a finished binding path: the http>
    " model prefix (switch_default_model) and the surrounding curly braces
    " (unless path_only). Shared tail of main( ) and main_cell( ).
    METHODS finalize_path
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_bind IMPLEMENTATION.

  METHOD bind_tab_cell.

    DATA lr_ref_in TYPE REF TO data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <ele> TYPE any.

    ASSIGN ms_config-tab->* TO <tab>.
    ASSIGN <tab>[ ms_config-tab_index ] TO <row>.
    " an out-of-range tab_index leaves <row> unassigned; raise the intended
    " binding error instead of dumping GETWA_NOT_ASSIGNED on the ASSIGN
    " COMPONENT below
    IF <row> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `BINDING_ERROR_TAB_CELL_LEVEL - Row index out of range`.
    ENDIF.

    " a table of an elementary line type (string_table) has no components
    " to bind a cell of; rtti_get_t_attri_by_any would answer that with a
    " raw CX_SY_MOVE_CAST_ERROR instead of the binding error it is
    DATA(lv_kind) = z2ui5_cl_ui5_util_context=>rtti_get_type_kind( <row> ).
    IF lv_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_struct1
        AND lv_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_struct2.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `BINDING_ERROR_TAB_CELL_LEVEL - the row of the bound table is not a structure`.
    ENDIF.

    IF mr_cell_tab <> ms_config-tab OR mt_cell_names IS INITIAL.
      CLEAR mt_cell_names.
      DATA(lt_attri) = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( ms_config-tab ).
      LOOP AT lt_attri ASSIGNING FIELD-SYMBOL(<comp>).
        APPEND <comp>-name TO mt_cell_names.
      ENDLOOP.
      mr_cell_tab = ms_config-tab.
    ENDIF.

    LOOP AT mt_cell_names INTO DATA(lv_comp_name).

      ASSIGN COMPONENT lv_comp_name OF STRUCTURE <row> TO <ele>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = |Binding Error - component '{ lv_comp_name }' not found in the bound row|.
      ENDIF.
      lr_ref_in = REF #( <ele> ).

      IF iv_val = lr_ref_in.
        result = |{ iv_name }/{ ms_config-tab_index - 1 }/{ lv_comp_name }|.
        RETURN.
      ENDIF.

    ENDLOOP.

    RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
      EXPORTING
        val = `BINDING_ERROR_TAB_CELL_LEVEL - No class attribute for binding found - Please check if the bound values are public attributes of your class`.

  ENDMETHOD.

  METHOD check_same_impl.

    IF ir_existing IS BOUND AND ir_new IS BOUND
        AND z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( ir_existing )
         <> z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( ir_new ).
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = |<p>Binding Error - Two different { iv_label } used for the same attribute ({ mr_attri->name }).|.
    ENDIF.

  ENDMETHOD.

  METHOD check_raise_existing.

    check_same_impl( ir_existing = mr_attri->custom_mapper
                     ir_new      = ms_config-custom_mapper
                     iv_label    = `mappers` ).

    check_same_impl( ir_existing = mr_attri->custom_filter
                     ir_new      = ms_config-custom_filter
                     iv_label    = `filters` ).

  ENDMETHOD.

  METHOD check_serializable.

    IF z2ui5_cl_ui5_util_context=>rtti_check_serializable( ir_ref ) = abap_false.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING val = |<p>{ iv_label } used but it is not serializable - please use if_serializable_object|.
    ENDIF.

  ENDMETHOD.

  METHOD check_raise_new.

    " check the incoming config - mr_attri->custom_* is only filled
    " afterwards by update_model_attri and is still initial here.
    " These are the refs that update_model_attri stores on mt_attri, which
    " db_save serializes with the rest of the app state
    " (main_attri_db_save_srtti clears only DATA references) - so a
    " non-serializable implementation has to be refused here, at bind time
    " and with a readable message, instead of surfacing later as an
    " APP_SERIALIZATION_ERROR. z2ui5_if_ajson_mapping composes
    " if_serializable_object, so the mapper check cannot fire today;
    " z2ui5_if_ajson_filter does not, which makes the filter check the
    " load-bearing one. This used to check the custom_*_back refs instead -
    " refs nothing can set since _bind stopped evaluating them.
    check_serializable( ir_ref   = ms_config-custom_filter
                        iv_label = `custom_filter` ).

    check_serializable( ir_ref   = ms_config-custom_mapper
                        iv_label = `custom_mapper` ).

  ENDMETHOD.

  METHOD constructor.

    mo_app = app.

  ENDMETHOD.

  METHOD get_model.

    IF mo_model IS NOT BOUND.
      mo_model = NEW z2ui5_cl_ui5_srv_model( attri = mo_app->mt_attri
                                             app   = mo_app->mo_app ).
    ENDIF.
    result = mo_model.

  ENDMETHOD.

  METHOD get_client_name.

    result = replace( val  = replace( val  = mr_attri->name
                                      sub  = `-`
                                      with = `/`
                                      occ  = 0 )
                      sub  = `>`
                      with = ``
                      occ  = 0 ).
    result = |/{ result }|.

  ENDMETHOD.

  METHOD main.

    IF z2ui5_cl_ui5_util_context=>check_bound_a_not_initial( config-tab ).
      result = main_cell( val    = val
                          config = config ).
    ELSE.
      result = bind_attri( val    = val
                           config = config ).
    ENDIF.

  ENDMETHOD.

  METHOD bind_attri.

    ms_config = config.

    mr_attri = get_model( )->main_attri_search( val ).

    IF mr_attri->name_ref IS NOT INITIAL.
      " name_ref may be a synthetic child name that no longer maps to a row
      " (e.g. dissolve stopped at max depth); raise the binding error rather
      " than dumping CX_SY_ITAB_LINE_NOT_FOUND while rendering the field.
      " name is the table's unique primary key - a keyed read, spelled as
      " one (a free-key table expression reads as a sequential access)
      READ TABLE mo_app->mt_attri->* REFERENCE INTO DATA(lr_ref_attri)
           WITH TABLE KEY name = mr_attri->name_ref.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = |Binding Error - referenced attribute '{ mr_attri->name_ref }' not found|.
      ENDIF.
      mr_attri = lr_ref_attri.
    ENDIF.

    IF mr_attri->bind = abap_true.
      check_raise_existing( ).
      adopt_new_options( ).
    ELSE.
      check_raise_new( ).
      update_model_attri( ).
    ENDIF.
    result = finalize_path( mr_attri->name_client ).

  ENDMETHOD.

  METHOD main_cell.

    " the table first, as a bare path - bind_attri sets ms_config to that
    " call's config, so THIS call's config (switch_default_model,
    " path_only) is put in place afterwards for the cell and its
    " decoration. The mapper and the filter (omit_initial arrives as one)
    " belong to the TABLE, which is what the serializer applies them to:
    " passed on, they are stored on a first bind, adopted on a later one and
    " refused when they differ from what is there - exactly as a _bind( ) of
    " the table itself treats them. The cell bind used to hand the table an
    " empty config, so the options were dropped without a word while the
    " _bind( ) doc promised none of that. check_json stays with the cell
    " and has no effect there - a property of the table's rows, see the doc
    result = bind_attri( val    = config-tab
                         config = VALUE #( path_only     = abap_true
                                           custom_mapper = config-custom_mapper
                                           custom_filter = config-custom_filter ) ).
    ms_config = config.

    result = bind_tab_cell( iv_name = result
                            iv_val  = val ).

    " same model-switch handling as in main( ) - otherwise a cell bind with
    " switch_default_model = abap_true silently targets the default model
    result = finalize_path( result ).

  ENDMETHOD.

  METHOD finalize_path.

    result = val.

    IF ms_config-switch_default_model = abap_true.
      result = |http>{ result }|.
    ENDIF.

    IF ms_config-path_only = abap_false.
      result = |\{{ result }\}|.
    ENDIF.

  ENDMETHOD.

  METHOD adopt_new_options.

    " A second _bind( ) on an attribute that is ALREADY bound used to be a
    " no-op for everything but the path: update_model_attri( ) - the only place
    " custom_filter, custom_mapper and check_json are stored - runs on the
    " new-binding branch alone. check_raise_existing( ) does not cover it
    " either: it refuses two DIFFERENT implementations, and an option the
    " stored attribute does not carry yet is not a conflict. So
    "
    "   client->_bind( mv_x ).
    "   client->_bind( val = mv_x custom_filter = lo_filter ).
    "
    " dropped the filter silently - and because mt_attri is serialized into
    " the draft, the order of the two calls in the first render decided the
    " behaviour for the rest of the session. Adopt instead: an option that is
    " not there yet is taken over, one that is there and differs was already
    " refused above. Serializability is re-checked here for the same reason
    " check_raise_new( ) checks it - these refs end up in the draft.
    IF ms_config-custom_filter IS BOUND AND mr_attri->custom_filter IS NOT BOUND.
      check_serializable( ir_ref   = ms_config-custom_filter
                          iv_label = `custom_filter` ).
      mr_attri->custom_filter = ms_config-custom_filter.
    ENDIF.

    IF ms_config-custom_mapper IS BOUND AND mr_attri->custom_mapper IS NOT BOUND.
      check_serializable( ir_ref   = ms_config-custom_mapper
                          iv_label = `custom_mapper` ).
      mr_attri->custom_mapper = ms_config-custom_mapper.
    ENDIF.

    " check_json only ever turns ON: whether a value carries JSON is a property
    " of the value, so one caller asking for it is enough and a later plain
    " _bind( ) of the same attribute must not silently turn it off again
    IF ms_config-check_json = abap_true.
      mr_attri->check_json = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD update_model_attri.

    mr_attri->bind          = abap_true.
    mr_attri->custom_filter = ms_config-custom_filter.
    mr_attri->custom_mapper = ms_config-custom_mapper.
    mr_attri->check_json    = ms_config-check_json.
    mr_attri->name_client   = get_client_name( ).

  ENDMETHOD.

ENDCLASS.
