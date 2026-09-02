CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_instantiation     FOR TESTING RAISING cx_static_check.
    METHODS test_attri_initialized FOR TESTING RAISING cx_static_check.
    METHODS test_buffer_clear      FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_ui5_app_cont DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.
  METHOD test_instantiation.

    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    lo_app = NEW #( ).

    cl_abap_unit_assert=>assert_bound( lo_app ).
    cl_abap_unit_assert=>assert_bound( lo_app->mt_attri ).

  ENDMETHOD.

  METHOD test_attri_initialized.

    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    lo_app = NEW #( ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( lo_app->mt_attri->* ) ).

  ENDMETHOD.

  METHOD test_buffer_clear.

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( z2ui5_cl_ui5_app_cont=>mt_buffer ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_db DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    DATA mv_value TYPE string.
    DATA mv_name  TYPE string.
    DATA mv_count TYPE i.

    INTERFACES z2ui5_if_app.

    METHODS test_db_save            FOR TESTING.
    METHODS test_db_roundtrip       FOR TESTING.
    METHODS test_db_save_complex    FOR TESTING.
    METHODS test_model_stringify    FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_db IMPLEMENTATION.
  METHOD test_db_save.
    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app_db TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp1 TYPE REF TO ltcl_test_db.
    DATA lo_app_user_db LIKE temp1.

    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `my value`.


    lo_app = NEW #( ).
    lo_app->ms_draft-id = `TEST_ID`.
    lo_app->mo_app = lo_app_user.

    lo_app->db_save( ).

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_app_db = z2ui5_cl_ui5_app_cont=>db_load( `TEST_ID` ).

    temp1 ?= lo_app_db->mo_app.

    lo_app_user_db = temp1.

    cl_abap_unit_assert=>assert_equals( exp = lo_app_user->mv_value
                                        act = lo_app_user_db->mv_value ).

  ENDMETHOD.

  METHOD test_db_roundtrip.
    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp2 TYPE REF TO ltcl_test_db.
    DATA lo_restored LIKE temp2.

    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `roundtrip value`.
    lo_app_user->mv_name  = `test name`.
    lo_app_user->mv_count = 42.


    lo_app = NEW #( ).
    lo_app->ms_draft-id = `TEST_ROUNDTRIP`.
    lo_app->mo_app = lo_app_user.

    lo_app->db_save( ).

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_loaded = z2ui5_cl_ui5_app_cont=>db_load( `TEST_ROUNDTRIP` ).

    temp2 ?= lo_loaded->mo_app.

    lo_restored = temp2.

    cl_abap_unit_assert=>assert_equals( exp = `roundtrip value`
                                        act = lo_restored->mv_value ).
    cl_abap_unit_assert=>assert_equals( exp = `test name`
                                        act = lo_restored->mv_name ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = lo_restored->mv_count ).

  ENDMETHOD.

  METHOD test_db_save_complex.
    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp3 TYPE REF TO z2ui5_if_app.

    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `complex`.


    lo_app = NEW #( ).
    lo_app->ms_draft-id = `TEST_COMPLEX`.
    lo_app->mo_app = lo_app_user.
    lo_app->ms_draft-id_prev = `PREV_ID`.
    lo_app->ms_draft-id_prev_app = `PREV_APP`.

    lo_app->db_save( ).


    " the lifecycle latch lives on the wrapper, not on z2ui5_if_app
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mv_check_initialized ).

    " and db_save refreshes the draft handle on the app before serializing it,
    " which is what db_load_by_app( ) resolves an app reference by
    temp3 ?= lo_app->mo_app.
    cl_abap_unit_assert=>assert_equals( exp = `TEST_COMPLEX`
                                        act = temp3->id_draft ).

  ENDMETHOD.

  METHOD test_model_stringify.

    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lv_json TYPE string.
    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `json test`.


    lo_app = NEW #( ).
    lo_app->mo_app = lo_app_user.


    lv_json = lo_app->model_json_stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_json ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" The draft roundtrip as the framework runs it - db_save( ) with the real
" transformation and the draft table, db_load( ) into a fresh container,
" db_load_by_app( ) against a live instance - over the attribute forms that
" broke in the samples: a runtime-built table behind a generic reference,
" the same table referenced three times (once from inside a helper object),
" an elementary reference, a helper that is not serializable, and a sub-app
" held in a REF TO object that changes its class between two roundtrips.
" The per-form catalogue and the invariants live with z2ui5_cl_ui5_srv_model;
" this is the container's contract on top of them.
" ---------------------------------------------------------------------------

CLASS ltcl_cont_dead DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_text TYPE string.
ENDCLASS.

CLASS ltcl_cont_dead IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_cont_inner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    DATA mv_inner  TYPE string.
    DATA mr_shared TYPE REF TO data.
ENDCLASS.

CLASS ltcl_cont_inner IMPLEMENTATION.
ENDCLASS.


" the sub-apps of a host (sample 338): different classes, different
" attribute names, each with a runtime-built table and a helper pointing at it
CLASS ltcl_cont_sub_a DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_table  TYPE REF TO data.
    DATA mo_layout TYPE REF TO ltcl_cont_inner.
ENDCLASS.

CLASS ltcl_cont_sub_a IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_cont_sub_b DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_data TYPE REF TO data.
    DATA mo_lay  TYPE REF TO ltcl_cont_inner.
ENDCLASS.

CLASS ltcl_cont_sub_b IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_cont_app DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1  TYPE string,
        col2  TYPE i,
        selkz TYPE abap_bool,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mv_string     TYPE string.
    DATA mt_std        TYPE ty_t_row.
    DATA mr_handle_tab TYPE REF TO data.
    DATA mr_shared     TYPE REF TO data.
    DATA mr_elem       TYPE REF TO data.
    DATA mo_inner      TYPE REF TO ltcl_cont_inner.
    DATA mo_dead       TYPE REF TO ltcl_cont_dead.
    DATA mo_any        TYPE REF TO object.

    METHODS fill.

    " a runtime-built table of ONE row - the line type carries a field no
    " dictionary knows, so only S-RTTI can serialize it
    CLASS-METHODS table_create
      IMPORTING
        iv_col1       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.
ENDCLASS.


CLASS ltcl_cont_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD table_create.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_row  TYPE ty_s_row.
    " c LENGTH 1, not abap_bool: the NodeJS runtime cannot resolve a
    " type-pool type by its absolute name when S-RTTI rebuilds the line
    DATA lv_flag TYPE c LENGTH 1.

    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_row ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    APPEND VALUE #( name = `RUNTIME_ONLY`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_flag ) ) ) TO lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA result TYPE HANDLE lo_tab.
    ASSIGN result->* TO <tab>.
    ls_row-col1 = iv_col1.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.

  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <elem> TYPE any.

    mv_string = `text`.
    mt_std    = VALUE #( ( col1 = `a` col2 = 1 ) ).

    mr_handle_tab = table_create( `handle` ).
    mr_shared     = mr_handle_tab.

    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `elem`.

    mo_inner = NEW #( ).
    mo_inner->mv_inner  = `inner`.
    mo_inner->mr_shared = mr_handle_tab.

    mo_dead = NEW #( ).
    mo_dead->mv_text = `dead`.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_db_shapes DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_app_cont DEFINITION LOCAL FRIENDS ltcl_test_db_shapes.


CLASS ltcl_test_db_shapes DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    " L5 + L6 + L8: save in place, load into a new container, save again
    METHODS draft_roundtrip_shapes   FOR TESTING RAISING cx_static_check.
    " L7 + L9: the draft is restored against a LIVE host whose sub-app is
    " now an instance of another class
    METHODS load_by_app_after_swap   FOR TESTING RAISING cx_static_check.
    " L10: a draft whose payload cannot be read back is a named error, not
    " an empty view
    METHODS load_broken_payload_loud FOR TESTING RAISING cx_static_check.

    METHODS container_with
      IMPORTING
        io_app        TYPE REF TO object
        iv_id         TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    " binds and answers the name of the row the search chose - for three
    " references to one data object that is the canonical row, not
    " necessarily the one named after the reference handed in
    METHODS bind
      IMPORTING
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
        ir_val        TYPE REF TO data
        iv_path       TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_test_db_shapes IMPLEMENTATION.

  METHOD container_with.

    result = NEW #( ).
    result->ms_draft-id = iv_id.
    result->mo_app = io_app.

  ENDMETHOD.

  METHOD bind.

    DATA(lo_model) = io_cont->create_model( ).
    DATA(lr_attri) = lo_model->main_attri_search( ir_val ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = iv_path.
    result = lr_attri->name.

  ENDMETHOD.

  METHOD draft_roundtrip_shapes.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    DATA(lo_user) = NEW ltcl_cont_app( ).
    lo_user->fill( ).
    DATA(lo_cont) = container_with( io_app = lo_user
                                    iv_id  = `TEST_SHAPES` ).

    bind( io_cont = lo_cont
          ir_val  = REF #( lo_user->mv_string )
          iv_path = `/MV_STRING` ).
    bind( io_cont = lo_cont
          ir_val  = REF #( lo_user->mt_std )
          iv_path = `/MT_STD` ).
    DATA(lv_table_row) = bind( io_cont = lo_cont
                               ir_val  = lo_user->mr_handle_tab
                               iv_path = `/MR_HANDLE_TAB` ).
    bind( io_cont = lo_cont
          ir_val  = lo_user->mr_elem
          iv_path = `/MR_ELEM` ).
    bind( io_cont = lo_cont
          ir_val  = REF #( lo_user->mo_inner->mv_inner )
          iv_path = `/MO_INNER_MV_INNER` ).
    DATA(lv_before) = lo_cont->model_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `"handle"` ) ).

    " L5 - the save restores in place: the same instance goes on rendering
    lo_cont->db_save( ).
    cl_abap_unit_assert=>assert_bound( lo_user->mr_handle_tab ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_user->mr_handle_tab = lo_user->mr_shared ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_user->mr_handle_tab = lo_user->mo_inner->mr_shared ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_cont->model_json_stringify( ) ).

    " L6 - a new container from the draft table
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    DATA(lo_loaded) = z2ui5_cl_ui5_app_cont=>db_load( `TEST_SHAPES` ).
    DATA lo_restored TYPE REF TO ltcl_cont_app.
    lo_restored ?= lo_loaded->mo_app.

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_restored->mv_string ).
    cl_abap_unit_assert=>assert_bound( act = lo_restored->mr_handle_tab
                                       msg = `the runtime-built table was lost` ).
    ASSIGN lo_restored->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_restored->mr_handle_tab = lo_restored->mr_shared )
                                      msg = `mr_shared is a copy` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_restored->mr_handle_tab = lo_restored->mo_inner->mr_shared )
                                      msg = `the helper's reference is a copy` ).
    cl_abap_unit_assert=>assert_bound( act = lo_restored->mr_elem
                                       msg = `the elementary reference was lost` ).
    cl_abap_unit_assert=>assert_equals( exp = `inner`
                                        act = lo_restored->mo_inner->mv_inner ).
    " the dead helper is gone, quietly
    cl_abap_unit_assert=>assert_not_bound( lo_restored->mo_dead ).
    " and the model the next render ships is the one before the draft
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_loaded->model_json_stringify( ) ).

    " L8 - the next roundtrip binds the same rows and saves as cleanly
    DATA(lo_model) = lo_loaded->create_model( ).
    DATA(lr_attri) = lo_model->main_attri_search( lo_restored->mr_handle_tab ).
    cl_abap_unit_assert=>assert_equals( exp = lv_table_row
                                        act = lr_attri->name ).
    lo_loaded->ms_draft-id = `TEST_SHAPES_2`.
    lo_loaded->db_save( ).
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    DATA(lo_second) = z2ui5_cl_ui5_app_cont=>db_load( `TEST_SHAPES_2` ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_second->model_json_stringify( ) ).

  ENDMETHOD.

  METHOD load_by_app_after_swap.

    " roundtrip 1: the host renders sub-app A and saves
    DATA(lo_host) = NEW ltcl_cont_app( ).
    DATA(lo_a) = NEW ltcl_cont_sub_a( ).
    lo_a->mt_table  = ltcl_cont_app=>table_create( `a` ).
    lo_a->mo_layout = NEW #( ).
    lo_a->mo_layout->mr_shared = lo_a->mt_table.
    lo_host->mo_any    = lo_a.
    lo_host->mv_string = `1`.

    DATA(lo_cont) = container_with( io_app = lo_host
                                    iv_id  = `TEST_SWAP` ).
    bind( io_cont = lo_cont
          ir_val  = REF #( lo_host->mv_string )
          iv_path = `/MV_STRING` ).
    bind( io_cont = lo_cont
          ir_val  = lo_a->mt_table
          iv_path = `/MO_ANY_MT_TABLE` ).
    lo_cont->db_save( ).

    " between the roundtrips the host switched its tab: the LIVE instance
    " the stack navigates back to holds an instance of class B now
    DATA(lo_b) = NEW ltcl_cont_sub_b( ).
    lo_b->mt_data = ltcl_cont_app=>table_create( `b` ).
    lo_b->mo_lay  = NEW #( ).
    lo_b->mo_lay->mr_shared = lo_b->mt_data.
    lo_host->mo_any = lo_b.

    " the restore against it must not raise - A's rows resolve to nothing
    " and keep no descriptor
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    DATA(lo_loaded) = z2ui5_cl_ui5_app_cont=>db_load_by_app( lo_host ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_loaded->mo_app = lo_host ) ).
    cl_abap_unit_assert=>assert_not_bound( lo_loaded->mt_attri->*[ name = `MO_ANY->MT_TABLE->*` ]-o_typedescr ).

    " the next render binds the host's own attribute (walks A's rows) and
    " B's table (not in mt_attri yet) - neither dumps, both are found
    DATA(lo_model) = lo_loaded->create_model( ).
    DATA(lr_attri) = lo_model->main_attri_search( REF #( lo_host->mv_string ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).
    lr_attri = lo_model->main_attri_search( lo_b->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_ANY->MT_DATA->*`
                                        act = lr_attri->name ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MO_ANY_MT_DATA`.
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lo_loaded->mt_attri->*[ name = `MO_ANY->MT_TABLE->*` ] ) ) ).

    " ...and the draft of THIS roundtrip carries B, restored with identity
    DATA(lv_before) = lo_loaded->model_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `"b"` ) ).
    lo_loaded->ms_draft-id = `TEST_SWAP_2`.
    lo_loaded->db_save( ).
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    DATA(lo_second) = z2ui5_cl_ui5_app_cont=>db_load( `TEST_SWAP_2` ).
    DATA lo_host_2 TYPE REF TO ltcl_cont_app.
    DATA lo_b_2    TYPE REF TO ltcl_cont_sub_b.
    lo_host_2 ?= lo_second->mo_app.
    lo_b_2 ?= lo_host_2->mo_any.
    cl_abap_unit_assert=>assert_bound( lo_b_2->mt_data ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_b_2->mt_data = lo_b_2->mo_lay->mr_shared ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_second->model_json_stringify( ) ).

  ENDMETHOD.

  METHOD load_broken_payload_loud.

    DATA(lo_user) = NEW ltcl_cont_app( ).
    lo_user->fill( ).
    DATA(lo_cont) = container_with( io_app = lo_user
                                    iv_id  = `TEST_BROKEN` ).
    bind( io_cont = lo_cont
          ir_val  = lo_user->mr_handle_tab
          iv_path = `/MR_HANDLE_TAB` ).

    " a draft as db_save writes it, except that the payload of the bound
    " table is not what S-RTTI wrote - the shape of a draft a system upgrade
    " or a type change left behind
    DATA(lo_model) = lo_cont->create_model( ).
    lo_model->main_attri_db_save_srtti( ).
    LOOP AT lo_cont->mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL.
      " plain text, not malformed markup: a system answers either with a
      " catchable exception, the NodeJS parser ASSERTs on broken markup
      lr_attri->srtti_data = `this is not the serialized type`.
    ENDLOOP.
    DATA(lv_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lo_cont ).
    DATA(lo_db) = NEW z2ui5_cl_ui5_srv_draft( ).
    lo_db->create( draft     = lo_cont->ms_draft
                   model_xml = lv_xml ).

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    TRY.
        z2ui5_cl_ui5_app_cont=>db_load( `TEST_BROKEN` ).
        cl_abap_unit_assert=>fail( `a draft whose bound data cannot be restored must not load silently` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `APP_STATE_RESTORE_ERROR` ) ).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `MR_HANDLE_TAB` ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
