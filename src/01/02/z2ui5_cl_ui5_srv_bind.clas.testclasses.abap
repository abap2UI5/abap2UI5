" A filter for the adopt tests. It declares if_serializable_object for the
" same reason the framework's own filters do (see lcl_empty_filter_keep_rows
" in z2ui5_cl_ui5_client.clas.locals_imp): z2ui5_if_ajson_filter does not
" compose it, and check_serializable( ) refuses a filter that cannot be
" written into the draft.
CLASS ltcl_test_filter DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
    INTERFACES if_serializable_object.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_filter IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_bnd_helper DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_s_row,
        name TYPE string,
        job  TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_struc,
        input TYPE string,
      END OF ty_s_struc.

    DATA mv_value TYPE string.
    DATA ms_struc TYPE ty_s_struc.
    DATA mt_tab   TYPE ty_t_row.
ENDCLASS.

CLASS ltcl_bnd_helper IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_bnd_app DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_deep,
        input TYPE string,
        BEGIN OF s_02,
          input TYPE string,
          BEGIN OF s_03,
            input TYPE string,
            BEGIN OF s_04,
              input TYPE string,
            END OF s_04,
          END OF s_03,
        END OF s_02,
      END OF ty_s_deep.

    " B01 a root value, B02 one named like the old reserved node
    DATA mv_value TYPE string.
    DATA xx       TYPE string.
    " B03 four structure levels
    DATA ms_deep  TYPE ty_s_deep.
    " B04 a table of structures, B05 one of strings
    DATA mt_tab     TYPE ltcl_bnd_helper=>ty_t_row.
    DATA mt_strings TYPE string_table.
    " B06 typed and generic references, B07 a runtime-built table
    DATA mr_value TYPE REF TO string.
    DATA mr_any   TYPE REF TO data.
    DATA mr_tab   TYPE REF TO data.
    " B08 a helper instance with values, a structure and a table of its own
    DATA mo_obj   TYPE REF TO ltcl_bnd_helper.
    " a value that looks like a cell and is none
    DATA mv_other TYPE string.

    METHODS fill.
ENDCLASS.


CLASS ltcl_bnd_app IMPLEMENTATION.

  METHOD fill.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    mv_value = `value`.
    xx       = `xx`.
    ms_deep-input                = `l1`.
    ms_deep-s_02-input           = `l2`.
    ms_deep-s_02-s_03-input      = `l3`.
    ms_deep-s_02-s_03-s_04-input = `l4`.
    mt_tab = VALUE #( ( name = `Michael Adams` job = `Scrum Master` )
                      ( name = `John Miller`   job = `Product Owner` ) ).
    mt_strings = VALUE #( ( `one` ) ( `two` ) ).

    CREATE DATA mr_value.
    mr_value->* = `typed-ref`.
    CREATE DATA mr_any TYPE string.
    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( mt_tab ) ).
    CREATE DATA mr_tab TYPE HANDLE lo_tab.
    ASSIGN mr_tab->* TO <tab>.
    <tab> = mt_tab.

    mo_obj = NEW #( ).
    mo_obj->mv_value       = `helper`.
    mo_obj->ms_struc-input = `helper-struc`.
    mo_obj->mt_tab         = mt_tab.

    mv_other = mt_tab[ 1 ]-name.

  ENDMETHOD.

ENDCLASS.


" a filter WITHOUT if_serializable_object - the one thing a bind refuses
CLASS ltcl_bnd_filter_dead DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
ENDCLASS.

CLASS ltcl_bnd_filter_dead IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.
    rv_keep = abap_true.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_path DEFINITION DEFERRED.
CLASS ltcl_02_cell DEFINITION DEFERRED.
CLASS ltcl_03_options DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_bind DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_path ltcl_02_cell ltcl_03_options.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PROTECTED SECTION.
    DATA mo_app  TYPE REF TO ltcl_bnd_app.
    DATA mo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA mo_bind TYPE REF TO z2ui5_cl_ui5_srv_bind.

    " main( ) on the same service - what one render's _bind( ) calls do
    METHODS bind
      IMPORTING
        ir_val        TYPE REF TO data
        is_config     TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    " the cell of one row of mo_app->mt_tab, as a reference INTO the table
    " (not the way bind_tab_cell( ) builds its own, so the reference match
    " is exercised rather than satisfied by construction)
    METHODS cell_name
      IMPORTING
        iv_index      TYPE i
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS expect_bind_error
      IMPORTING
        ir_val    TYPE REF TO data
        is_config TYPE z2ui5_if_ui5_types=>ty_s_bind_config
        iv_text   TYPE string.

  PRIVATE SECTION.
    METHODS setup.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->fill( ).
    mo_cont = NEW #( ).
    mo_cont->mo_app = mo_app.
    mo_bind = NEW #( mo_cont ).

  ENDMETHOD.

  METHOD bind.

    result = mo_bind->main( val    = ir_val
                            config = is_config ).

  ENDMETHOD.

  METHOD cell_name.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    DATA(lr_row) = REF #( mo_app->mt_tab[ iv_index ] ).
    ASSIGN lr_row->* TO <row>.
    result = REF #( <row>-name ).

  ENDMETHOD.

  METHOD expect_bind_error.

    TRY.
        bind( ir_val    = ir_val
              is_config = is_config ).
        cl_abap_unit_assert=>fail( |expected a binding error with '{ iv_text }'| ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( act = xsdbool( lx->get_text( ) CS iv_text )
                                          msg = |wrong error: { lx->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 01 - the path: for every form, main( ) answers the client path of the
" attribute the value lives in, braces around it
" ---------------------------------------------------------------------------
CLASS ltcl_01_path DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " B01/B02 root values - XX binds like any other name
    METHODS root_value             FOR TESTING RAISING cx_static_check.
    " B03 one path per structure level, the segments as in ABAP
    METHODS structure_levels       FOR TESTING RAISING cx_static_check.
    " B04/B05 a table as a whole, whatever its line
    METHODS whole_table            FOR TESTING RAISING cx_static_check.
    " B06/B07 a dereferenced reference: the deref segment is `*`
    METHODS reference_deref        FOR TESTING RAISING cx_static_check.
    " B08 values inside a helper instance
    METHODS helper_attribute       FOR TESTING RAISING cx_static_check.
    " the same value bound twice gets the same path, and stays bound once
    METHODS bind_idempotent        FOR TESTING RAISING cx_static_check.
    " path_only and switch_default_model decorate the same path
    METHODS path_decorations       FOR TESTING RAISING cx_static_check.
    " a value that is no attribute of the app - the model's error
    METHODS foreign_value_refused  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_01_path IMPLEMENTATION.

  METHOD root_value.

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = bind( REF #( mo_app->mv_value ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/XX}`
                                        act = bind( REF #( mo_app->xx ) ) ).

  ENDMETHOD.

  METHOD structure_levels.

    cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP}`
                                        act = bind( REF #( mo_app->ms_deep ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/INPUT}`
                                        act = bind( REF #( mo_app->ms_deep-input ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/S_02/INPUT}`
                                        act = bind( REF #( mo_app->ms_deep-s_02-input ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/S_02/S_03/INPUT}`
                                        act = bind( REF #( mo_app->ms_deep-s_02-s_03-input ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MS_DEEP/S_02/S_03/S_04/INPUT}`
                                        act = bind( REF #( mo_app->ms_deep-s_02-s_03-s_04-input ) ) ).

  ENDMETHOD.

  METHOD whole_table.

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB}`
                                        act = bind( REF #( mo_app->mt_tab ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_STRINGS}`
                                        act = bind( REF #( mo_app->mt_strings ) ) ).

  ENDMETHOD.

  METHOD reference_deref.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    " the app hands over the dereferenced data - _bind( <fs> ), not the
    " reference; the row is `MR_VALUE->*`, `>` dropped and `-` a slash
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_VALUE/*}`
                                        act = bind( mo_app->mr_value ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_ANY/*}`
                                        act = bind( mo_app->mr_any ) ).
    ASSIGN mo_app->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*}`
                                        act = bind( REF #( <tab> ) ) ).

  ENDMETHOD.

  METHOD helper_attribute.

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MV_VALUE}`
                                        act = bind( REF #( mo_app->mo_obj->mv_value ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MS_STRUC/INPUT}`
                                        act = bind( REF #( mo_app->mo_obj->ms_struc-input ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MT_TAB}`
                                        act = bind( REF #( mo_app->mo_obj->mt_tab ) ) ).

  ENDMETHOD.

  METHOD bind_idempotent.

    DATA(lv_first)  = bind( REF #( mo_app->mv_value ) ).
    DATA(lv_second) = bind( REF #( mo_app->mv_value ) ).

    cl_abap_unit_assert=>assert_equals( exp = lv_first
                                        act = lv_second ).
    cl_abap_unit_assert=>assert_not_initial( lv_first ).
    " one row, bound once
    DATA(lv_count) = 0.
    LOOP AT mo_cont->mt_attri->* TRANSPORTING NO FIELDS WHERE name = `MV_VALUE` AND bind = abap_true. "#EC CI_SORTSEQ
      lv_count = lv_count + 1.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lv_count ).

  ENDMETHOD.

  METHOD path_decorations.

    cl_abap_unit_assert=>assert_equals( exp = `/MS_DEEP/INPUT`
                                        act = bind( ir_val    = REF #( mo_app->ms_deep-input )
                                                    is_config = VALUE #( path_only = abap_true ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{http>/MV_VALUE}`
                                        act = bind( ir_val    = REF #( mo_app->mv_value )
                                                    is_config = VALUE #( switch_default_model = abap_true ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `http>/MV_VALUE`
                                        act = bind( ir_val    = REF #( mo_app->mv_value )
                                                    is_config = VALUE #( switch_default_model = abap_true
                                                                         path_only            = abap_true ) ) ).

  ENDMETHOD.

  METHOD foreign_value_refused.

    DATA lv_local TYPE string VALUE `not an attribute`.

    expect_bind_error( ir_val    = REF #( lv_local )
                       is_config = VALUE #( )
                       iv_text   = `BINDING_ERROR` ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 02 - the cell: a value addressed as one row of a table (config-tab and
" tab_index). ABAP counts rows from 1, the client path from 0; the cell is
" identified by REFERENCE, and the two refusals of bind_tab_cell( ) are the
" only places a wrong call is caught at all
" ---------------------------------------------------------------------------
CLASS ltcl_02_cell DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " row 1 and row 2 - the index resolved and shifted, not assumed
    METHODS row_index_shifted       FOR TESTING RAISING cx_static_check.
    " the second component of the same row
    METHODS other_column            FOR TESTING RAISING cx_static_check.
    " the decorations apply to a cell path too
    METHODS cell_decorations        FOR TESTING RAISING cx_static_check.
    " a cell of the helper's table and of the runtime-built table
    METHODS cell_in_helper_table    FOR TESTING RAISING cx_static_check.
    METHODS cell_in_runtime_table   FOR TESTING RAISING cx_static_check.
    " an index past the last row
    METHODS index_out_of_range      FOR TESTING RAISING cx_static_check.
    " a value that is not a component of that row, however equal it looks
    METHODS foreign_value_refused   FOR TESTING RAISING cx_static_check.
    " a table of strings has no component to bind a cell of
    METHODS elementary_row_refused  FOR TESTING RAISING cx_static_check.
    " one render, one service: cells of two tables in turn, and a cell of
    " the runtime-built table after main( ) created that table again
    METHODS cells_of_two_tables     FOR TESTING RAISING cx_static_check.
    METHODS cell_after_recreate     FOR TESTING RAISING cx_static_check.
    " the mapper and the filter of a cell bind land on the TABLE, and a
    " second cell with a different mapper is refused like a second _bind( )
    " of the table would be
    METHODS cell_carries_options    FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_cell IMPLEMENTATION.

  METHOD cell_carries_options.

    DATA(lo_filter) = NEW ltcl_test_filter( ).
    DATA(lo_mapper) = z2ui5_cl_ajson_mapping=>create_upper_case( ).

    bind( ir_val    = cell_name( 1 )
          is_config = VALUE #( tab           = REF #( mo_app->mt_tab )
                               tab_index     = 1
                               custom_filter = lo_filter
                               custom_mapper = lo_mapper ) ).

    " stored on the table's row - the one the serializer applies them to
    DATA(lr_tab) = mo_bind->get_model( )->main_attri_search( REF #( mo_app->mt_tab ) ).
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_tab->custom_filter ).
    cl_abap_unit_assert=>assert_equals( exp = lo_mapper
                                        act = lr_tab->custom_mapper ).

    " the same options again, for another cell: no conflict
    bind( ir_val    = cell_name( 2 )
          is_config = VALUE #( tab           = REF #( mo_app->mt_tab )
                               tab_index     = 2
                               custom_filter = lo_filter
                               custom_mapper = lo_mapper ) ).

    " a different mapper for a cell of the same table: refused, as the
    " table's own second bind would be - it used to be dropped silently
    expect_bind_error( ir_val    = cell_name( 1 )
                       is_config = VALUE #( tab           = REF #( mo_app->mt_tab )
                                            tab_index     = 1
                                            custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ) )
                       iv_text   = `Two different mappers` ).

  ENDMETHOD.

  METHOD row_index_shifted.

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                                                         tab_index = 1 ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/NAME}`
                                        act = bind( ir_val    = cell_name( 2 )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                                                         tab_index = 2 ) ) ).

  ENDMETHOD.

  METHOD other_column.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    DATA(lr_row) = REF #( mo_app->mt_tab[ 2 ] ).
    ASSIGN lr_row->* TO <row>.

    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/JOB}`
                                        act = bind( ir_val    = REF #( <row>-job )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                                                         tab_index = 2 ) ) ).

  ENDMETHOD.

  METHOD cell_decorations.

    cl_abap_unit_assert=>assert_equals( exp = `/MT_TAB/0/NAME`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                                                         tab_index = 1
                                                                         path_only = abap_true ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{http>/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = VALUE #( tab                  = REF #( mo_app->mt_tab )
                                                                         tab_index            = 1
                                                                         switch_default_model = abap_true ) ) ).

  ENDMETHOD.

  METHOD cell_in_helper_table.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    DATA(lr_row) = REF #( mo_app->mo_obj->mt_tab[ 1 ] ).
    ASSIGN lr_row->* TO <row>.

    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = REF #( <row>-name )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mo_obj->mt_tab )
                                                                         tab_index = 1 ) ) ).

  ENDMETHOD.

  METHOD cell_in_runtime_table.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <name> TYPE any.

    ASSIGN mo_app->mr_tab->* TO <tab>.
    ASSIGN <tab>[ 2 ] TO <row>.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
    cl_abap_unit_assert=>assert_subrc( ).

    " the table behind a generic reference: the cell path carries the
    " deref segment of the table's own path
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*/1/NAME}`
                                        act = bind( ir_val    = REF #( <name> )
                                                    is_config = VALUE #( tab       = mo_app->mr_tab
                                                                         tab_index = 2 ) ) ).

  ENDMETHOD.

  METHOD index_out_of_range.

    expect_bind_error( ir_val    = cell_name( 1 )
                       is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                            tab_index = 3 )
                       iv_text   = `BINDING_ERROR_TAB_CELL_LEVEL` ).

  ENDMETHOD.

  METHOD foreign_value_refused.

    " mv_other holds the same text as the cell - a value, not the cell
    expect_bind_error( ir_val    = REF #( mo_app->mv_other )
                       is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                            tab_index = 1 )
                       iv_text   = `BINDING_ERROR_TAB_CELL_LEVEL` ).

  ENDMETHOD.

  METHOD elementary_row_refused.

    expect_bind_error( ir_val    = REF #( mo_app->mt_strings[ 1 ] )
                       is_config = VALUE #( tab       = REF #( mo_app->mt_strings )
                                            tab_index = 1 )
                       iv_text   = `not a structure` ).

  ENDMETHOD.


  METHOD cells_of_two_tables.

    FIELD-SYMBOLS <row> TYPE ltcl_bnd_helper=>ty_s_row.

    DATA(lr_helper_row) = REF #( mo_app->mo_obj->mt_tab[ 1 ] ).
    ASSIGN lr_helper_row->* TO <row>.

    " app table, helper table, app table again - each answer names ITS table
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = cell_name( 1 )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                                                         tab_index = 1 ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_OBJ/MT_TAB/0/NAME}`
                                        act = bind( ir_val    = REF #( <row>-name )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mo_obj->mt_tab )
                                                                         tab_index = 1 ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MT_TAB/1/NAME}`
                                        act = bind( ir_val    = cell_name( 2 )
                                                    is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                                                         tab_index = 2 ) ) ).
    " the two tables hold equal rows (fill copies the one into the other):
    " the helper's cell handed in with the APP's table is a foreign value,
    " not a match by content
    expect_bind_error( ir_val    = REF #( <row>-name )
                       is_config = VALUE #( tab       = REF #( mo_app->mt_tab )
                                            tab_index = 1 )
                       iv_text   = `BINDING_ERROR_TAB_CELL_LEVEL` ).

  ENDMETHOD.

  METHOD cell_after_recreate.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <name> TYPE any.

    " a cell of the runtime-built table, as it is
    ASSIGN mo_app->mr_tab->* TO <tab>.
    ASSIGN <tab>[ 2 ] TO <row>.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*/1/NAME}`
                                        act = bind( ir_val    = REF #( <name> )
                                                    is_config = VALUE #( tab       = mo_app->mr_tab
                                                                         tab_index = 2 ) ) ).
    DATA lr_old_cell TYPE REF TO data.
    DATA(lr_old) = mo_app->mr_tab.
    " a typed target for the REF of a generic field symbol - REF #( ) into
    " an inline declaration has no type to infer (see abap-check)
    lr_old_cell = REF #( <name> ).

    " main( ) creates the table again - a new object under the same name,
    " one row - and binds a cell of it on the SAME service
    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( mo_app->mt_tab ) ).
    CREATE DATA mo_app->mr_tab TYPE HANDLE lo_tab.
    ASSIGN mo_app->mr_tab->* TO <tab>.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    ASSIGN COMPONENT `NAME` OF STRUCTURE <row> TO <name>.
    cl_abap_unit_assert=>assert_subrc( ).
    <name> = `re-created`.

    cl_abap_unit_assert=>assert_equals( exp = `{/MR_TAB/*/0/NAME}`
                                        act = bind( ir_val    = REF #( <name> )
                                                    is_config = VALUE #( tab       = mo_app->mr_tab
                                                                         tab_index = 1 ) ) ).
    " ...and a cell of the old table object is nobody's attribute
    expect_bind_error( ir_val    = lr_old_cell
                       is_config = VALUE #( tab       = lr_old
                                            tab_index = 2 )
                       iv_text   = `BINDING_ERROR` ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 03 - the options: mapper, filter and the json flag are stored on the
" attribute row and travel with the draft. A later bind adopts what the row
" does not carry yet, keeps what it has, and refuses a different
" implementation or one that cannot be serialized
" ---------------------------------------------------------------------------
CLASS ltcl_03_options DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " the first bind stores all three
    METHODS options_stored          FOR TESTING RAISING cx_static_check.
    " a plain first bind invents nothing
    METHODS plain_bind_stores_none  FOR TESTING RAISING cx_static_check.
    " a later bind with a filter, a mapper or json adopts it
    METHODS later_bind_adopts       FOR TESTING RAISING cx_static_check.
    " a later plain bind keeps them - json only ever turns on
    METHODS later_plain_bind_keeps  FOR TESTING RAISING cx_static_check.
    " the same implementation again is no conflict
    METHODS same_impl_accepted      FOR TESTING RAISING cx_static_check.
    " a different mapper or filter for the same attribute is refused
    METHODS different_mapper_refused FOR TESTING RAISING cx_static_check.
    METHODS different_filter_refused FOR TESTING RAISING cx_static_check.
    " a filter that cannot be serialized is refused at bind time - on the
    " first bind and when a later bind would adopt it
    METHODS dead_filter_refused     FOR TESTING RAISING cx_static_check.
    " options are per attribute - a second attribute starts clean
    METHODS options_per_attribute   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_options IMPLEMENTATION.

  METHOD options_stored.

    DATA(lo_filter) = NEW ltcl_test_filter( ).
    DATA(lo_mapper) = z2ui5_cl_ajson_mapping=>create_upper_case( ).

    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_filter = lo_filter
                               custom_mapper = lo_mapper
                               check_json    = abap_true ) ).

    DATA(lr_attri) = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_equals( exp = lo_mapper
                                        act = lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD plain_bind_stores_none.

    bind( REF #( mo_app->mv_value ) ).

    DATA(lr_attri) = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_not_bound( lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_not_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD later_bind_adopts.

    " a filter handed to a LATER _bind( ) of an already-bound attribute used
    " to be dropped without a word - and because mt_attri is serialized into
    " the draft, the order of the two calls in the first render decided the
    " behaviour for the rest of the session
    bind( REF #( mo_app->mv_value ) ).

    DATA(lo_filter) = NEW ltcl_test_filter( ).
    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_filter = lo_filter ) ).
    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( check_json = abap_true ) ).

    DATA(lr_attri) = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD later_plain_bind_keeps.

    DATA(lo_filter) = NEW ltcl_test_filter( ).
    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_filter = lo_filter
                               custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( )
                               check_json    = abap_true ) ).

    bind( REF #( mo_app->mv_value ) ).

    DATA(lr_attri) = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = lo_filter
                                        act = lr_attri->custom_filter ).
    cl_abap_unit_assert=>assert_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->check_json ).

  ENDMETHOD.

  METHOD same_impl_accepted.

    " a second INSTANCE of the same class - what every render creates anew
    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_filter = NEW ltcl_test_filter( )
                               custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
    DATA(lv_path) = bind( ir_val    = REF #( mo_app->mv_value )
                          is_config = VALUE #( custom_filter = NEW ltcl_test_filter( )
                                               custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `{/MV_VALUE}`
                                        act = lv_path ).

  ENDMETHOD.

  METHOD different_mapper_refused.

    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).

    expect_bind_error( ir_val    = REF #( mo_app->mv_value )
                       is_config = VALUE #( custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ) )
                       iv_text   = `Two different mappers` ).

  ENDMETHOD.

  METHOD different_filter_refused.

    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_filter = NEW ltcl_test_filter( ) ) ).

    " the framework's own row filter is another implementation
    expect_bind_error( ir_val    = REF #( mo_app->mv_value )
                       is_config = VALUE #( custom_filter = z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) )
                       iv_text   = `Two different filters` ).

  ENDMETHOD.

  METHOD dead_filter_refused.

    expect_bind_error( ir_val    = REF #( mo_app->mv_value )
                       is_config = VALUE #( custom_filter = NEW ltcl_bnd_filter_dead( ) )
                       iv_text   = `not serializable` ).

    " ...and the row stays unbound after the refusal, so the next bind is
    " a first one again
    bind( REF #( mo_app->mv_value ) ).
    expect_bind_error( ir_val    = REF #( mo_app->mv_value )
                       is_config = VALUE #( custom_filter = NEW ltcl_bnd_filter_dead( ) )
                       iv_text   = `not serializable` ).

  ENDMETHOD.

  METHOD options_per_attribute.

    bind( ir_val    = REF #( mo_app->mv_value )
          is_config = VALUE #( custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( )
                               check_json    = abap_true ) ).
    bind( REF #( mo_app->xx ) ).

    DATA(lr_attri) = mo_bind->mr_attri.
    cl_abap_unit_assert=>assert_equals( exp = `XX`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_not_bound( lr_attri->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lr_attri->check_json ).

  ENDMETHOD.

ENDCLASS.
