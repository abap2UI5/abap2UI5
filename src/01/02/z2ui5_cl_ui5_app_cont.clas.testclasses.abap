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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

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

    DATA temp1 TYPE REF TO cl_abap_structdescr.
    DATA lo_line LIKE temp1.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp2 TYPE abap_componentdescr.
    DATA temp3 TYPE REF TO cl_abap_datadescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
    temp1 ?= cl_abap_typedescr=>describe_by_data( ls_row ).

    lo_line = temp1.

    lt_comp = lo_line->get_components( ).

    CLEAR temp2.
    temp2-name = `RUNTIME_ONLY`.

    temp3 ?= cl_abap_datadescr=>describe_by_data( lv_flag ).
    temp2-type = temp3.
    APPEND temp2 TO lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA result TYPE HANDLE lo_tab.
    ASSIGN result->* TO <tab>.
    ls_row-col1 = iv_col1.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.

  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <elem> TYPE any.
    DATA temp3 TYPE ltcl_cont_app=>ty_t_row.
    DATA temp4 LIKE LINE OF temp3.

    mv_string = `text`.

    CLEAR temp3.

    temp4-col1 = `a`.
    temp4-col2 = 1.
    INSERT temp4 INTO TABLE temp3.
    mt_std    = temp3.

    mr_handle_tab = table_create( `handle` ).
    mr_shared     = mr_handle_tab.

    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `elem`.

    CREATE OBJECT mo_inner.
    mo_inner->mv_inner  = `inner`.
    mo_inner->mr_shared = mr_handle_tab.

    CREATE OBJECT mo_dead.
    mo_dead->mv_text = `dead`.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_xml DEFINITION DEFERRED.
CLASS ltcl_02_db DEFINITION DEFERRED.
CLASS ltcl_03_errors DEFINITION DEFERRED.
CLASS ltcl_04_model DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_app_cont DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_xml ltcl_02_db ltcl_03_errors ltcl_04_model.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PROTECTED SECTION.
    DATA mo_user TYPE REF TO ltcl_cont_app.
    DATA mo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.

    " binds and answers the name of the row the search chose - for three
    " references to one data object that is the canonical row
    METHODS bind
      IMPORTING
        ir_val        TYPE REF TO data
        iv_path       TYPE string
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    " every bindable form of the fixture, the model before as the result
    METHODS bind_all
      RETURNING
        VALUE(result) TYPE string.

    " a fresh container from the draft table, the buffer cleared first
    METHODS load_fresh
      IMPORTING
        iv_id         TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS app_of
      IMPORTING
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE REF TO ltcl_cont_app.

    " the identity of the three references and the values, on any instance
    METHODS check_restored
      IMPORTING
        io_app TYPE REF TO ltcl_cont_app.

  PRIVATE SECTION.
    METHODS setup.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT mo_user.
    mo_user->fill( ).
    CREATE OBJECT mo_cont.
    mo_cont->mo_app      = mo_user.
    mo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

  ENDMETHOD.

  METHOD bind.

    DATA temp5 TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_cont LIKE temp5.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    IF io_cont IS BOUND.
      temp5 = io_cont.
    ELSE.
      temp5 = mo_cont.
    ENDIF.

    lo_cont = temp5.

    lr_attri = lo_cont->create_model( )->main_attri_search( ir_val ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = iv_path.
    result = lr_attri->name.

  ENDMETHOD.

  METHOD bind_all.

    DATA temp6 LIKE REF TO mo_user->mv_string.
    DATA temp7 LIKE REF TO mo_user->mt_std.
    DATA temp8 LIKE REF TO mo_user->mo_inner->mv_inner.
    DATA temp1 TYPE xsdboolean.
    GET REFERENCE OF mo_user->mv_string INTO temp6.
bind( ir_val  = temp6
          iv_path = `/MV_STRING` ).

    GET REFERENCE OF mo_user->mt_std INTO temp7.
bind( ir_val  = temp7
          iv_path = `/MT_STD` ).
    bind( ir_val  = mo_user->mr_handle_tab
          iv_path = `/MR_HANDLE_TAB` ).
    bind( ir_val  = mo_user->mr_elem
          iv_path = `/MR_ELEM` ).

    GET REFERENCE OF mo_user->mo_inner->mv_inner INTO temp8.
bind( ir_val  = temp8
          iv_path = `/MO_INNER_MV_INNER` ).
    result = mo_cont->model_json_stringify( ).

    temp1 = boolc( result CS `"handle"` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

  ENDMETHOD.

  METHOD load_fresh.

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    result = z2ui5_cl_ui5_app_cont=>db_load( iv_id ).

  ENDMETHOD.

  METHOD app_of.

    result ?= io_cont->mo_app.

  ENDMETHOD.

  METHOD check_restored.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = io_app->mv_string ).
    cl_abap_unit_assert=>assert_bound( act = io_app->mr_handle_tab
                                       msg = `the runtime-built table was lost` ).
    ASSIGN io_app->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).

    temp2 = boolc( io_app->mr_handle_tab = io_app->mr_shared ).
    cl_abap_unit_assert=>assert_true( act = temp2
                                      msg = `mr_shared is a copy` ).

    temp3 = boolc( io_app->mr_handle_tab = io_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( act = temp3
                                      msg = `the helper's reference is a copy` ).
    cl_abap_unit_assert=>assert_bound( act = io_app->mr_elem
                                       msg = `the elementary reference was lost` ).
    cl_abap_unit_assert=>assert_equals( exp = `inner`
                                        act = io_app->mo_inner->mv_inner ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 01 - the app as a document: all_xml_stringify( ) hands out the container,
" its app and its attribute table as one asXML, and leaves the live
" instance as it was; all_xml_parse( ) gives a new container whose
" attribute table still carries the S-RTTI payloads until they are loaded
" ---------------------------------------------------------------------------
CLASS ltcl_01_xml DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    " the live instance goes on rendering after the stringify
    METHODS stringify_leaves_live_alone FOR TESTING RAISING cx_static_check.
    " the document parses into a new container: app, draft, attribute rows
    METHODS parse_gives_new_container   FOR TESTING RAISING cx_static_check.
    " the payloads sit on the parsed rows until the load clears them
    METHODS payload_until_loaded        FOR TESTING RAISING cx_static_check.
    " a helper that is not serializable is dropped, quietly
    METHODS dead_object_dropped         FOR TESTING RAISING cx_static_check.
    " the document is one string of markup, nothing else
    METHODS document_is_asxml           FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_01_xml IMPLEMENTATION.

  METHOD stringify_leaves_live_alone.

    DATA lv_before TYPE string.
    lv_before = bind_all( ).

    mo_cont->all_xml_stringify( ).

    check_restored( mo_user ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_cont->model_json_stringify( ) ).
    " ...and a second time, the same
    mo_cont->all_xml_stringify( ).
    check_restored( mo_user ).

  ENDMETHOD.

  METHOD parse_gives_new_container.

    DATA lv_before TYPE string.
    DATA lo_parsed TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    FIELD-SYMBOLS <temp9> LIKE LINE OF lo_parsed->mt_attri->*.
    DATA temp10 LIKE sy-tabix.
    lv_before = bind_all( ).
    mo_cont->ms_draft-id_prev     = `PREV`.
    mo_cont->ms_draft-id_prev_app = `PREV_APP`.


    lo_parsed = z2ui5_cl_ui5_app_cont=>all_xml_parse( mo_cont->all_xml_stringify( ) ).
    lo_parsed->create_model( )->main_attri_db_load( ).


    temp4 = boolc( lo_parsed = mo_cont ).
    cl_abap_unit_assert=>assert_false( temp4 ).

    temp5 = boolc( lo_parsed->mo_app = mo_user ).
    cl_abap_unit_assert=>assert_false( temp5 ).
    cl_abap_unit_assert=>assert_equals( exp = mo_cont->ms_draft
                                        act = lo_parsed->ms_draft ).
    check_restored( app_of( lo_parsed ) ).
    " the bound rows came along, with their client names


    temp10 = sy-tabix.
    READ TABLE lo_parsed->mt_attri->* WITH KEY name = `MV_STRING` ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `/MV_STRING`
                                        act = <temp9>-name_client ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_parsed->model_json_stringify( ) ).

  ENDMETHOD.

  METHOD payload_until_loaded.
    DATA lo_parsed TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app TYPE REF TO ltcl_cont_app.
    DATA lv_payloads TYPE i.

    bind_all( ).


    lo_parsed = z2ui5_cl_ui5_app_cont=>all_xml_parse( mo_cont->all_xml_stringify( ) ).

    " before the load: the generic references are initial, their payload
    " on the row

    lo_app = app_of( lo_parsed ).
    cl_abap_unit_assert=>assert_not_bound( lo_app->mr_handle_tab ).
    cl_abap_unit_assert=>assert_not_bound( lo_app->mr_elem ).

    lv_payloads = 0.
    LOOP AT lo_parsed->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      lv_payloads = lv_payloads + 1.
    ENDLOOP.
    " one for the shared table, one for the elementary reference
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lv_payloads ).

    lo_parsed->create_model( )->main_attri_db_load( ).

    check_restored( lo_app ).
    LOOP AT lo_parsed->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      cl_abap_unit_assert=>fail( `a payload survived the load` ).
    ENDLOOP.

  ENDMETHOD.

  METHOD dead_object_dropped.
    DATA lo_parsed TYPE REF TO z2ui5_cl_ui5_app_cont.

    bind_all( ).
    cl_abap_unit_assert=>assert_bound( mo_user->mo_dead ).


    lo_parsed = z2ui5_cl_ui5_app_cont=>all_xml_parse( mo_cont->all_xml_stringify( ) ).
    lo_parsed->create_model( )->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_not_bound( app_of( lo_parsed )->mo_dead ).
    " the live one still has it
    cl_abap_unit_assert=>assert_bound( mo_user->mo_dead ).

  ENDMETHOD.

  METHOD document_is_asxml.
    DATA lv_xml TYPE string.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.

    bind_all( ).


    lv_xml = mo_cont->all_xml_stringify( ).


    temp6 = boolc( lv_xml CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

    temp7 = boolc( lv_xml CS `MT_ATTRI` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

    temp8 = boolc( lv_xml CS `text` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 02 - the draft table: db_save( ) writes the document under the draft id
" and marks the app, db_load( ) reads it into a new container (once per
" request - the buffer), db_load_by_app( ) restores against a live instance
" ---------------------------------------------------------------------------
CLASS ltcl_02_db DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    " save, load into a new container: values, references, identity, model
    METHODS save_then_load             FOR TESTING RAISING cx_static_check.
    " the save marks the app initialized and stamps the draft id on it
    METHODS save_marks_app             FOR TESTING RAISING cx_static_check.
    " the draft's own fields (id_prev, id_prev_app) come back
    METHODS draft_fields_survive       FOR TESTING RAISING cx_static_check.
    " one container per draft and request - the buffer
    METHODS load_buffered_per_request  FOR TESTING RAISING cx_static_check.
    " the loaded container binds the same rows again and saves as cleanly
    METHODS second_roundtrip_clean     FOR TESTING RAISING cx_static_check.
    " sample 335: a change through the helper's reference between drafts
    METHODS change_between_drafts      FOR TESTING RAISING cx_static_check.
    " db_load_by_app restores against the LIVE instance handed in
    METHODS load_by_app_live_instance  FOR TESTING RAISING cx_static_check.
    " sample 338: the live host swapped its sub-app's class meanwhile
    METHODS load_by_app_after_swap     FOR TESTING RAISING cx_static_check.
    " a container loaded by app is what a later db_load of the id answers
    METHODS load_by_app_fills_buffer   FOR TESTING RAISING cx_static_check.
    " two saves of one live instance, nothing ran in between: two drafts
    " that load to the same state, and the instance keeps its references
    METHODS two_drafts_one_instance   FOR TESTING RAISING cx_static_check.
    " what a callee wrote through the caller's reference after the caller's
    " save is what the way back keeps - the live object, not the payload
    METHODS load_by_app_keeps_live_data FOR TESTING RAISING cx_static_check.
    " the container this request built for the draft is what a load by
    " ITS app answers - no second parse; another instance of the same id
    " is still restored on its own
    METHODS load_by_app_same_instance  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_db IMPLEMENTATION.

  METHOD save_then_load.

    DATA lv_before TYPE string.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp9 TYPE xsdboolean.
    lv_before = bind_all( ).

    mo_cont->db_save( ).
    " the save restores in place: the same instance goes on rendering
    check_restored( mo_user ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_cont->model_json_stringify( ) ).


    lo_loaded = load_fresh( mo_cont->ms_draft-id ).


    temp9 = boolc( lo_loaded->mo_app = mo_user ).
    cl_abap_unit_assert=>assert_false( temp9 ).
    check_restored( app_of( lo_loaded ) ).
    cl_abap_unit_assert=>assert_not_bound( app_of( lo_loaded )->mo_dead ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_loaded->model_json_stringify( ) ).

  ENDMETHOD.

  METHOD save_marks_app.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app TYPE REF TO ltcl_cont_app.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_cont->mv_check_initialized ).

    mo_cont->db_save( ).

    " the lifecycle latch lives on the container, not on z2ui5_if_app
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = mo_cont->mv_check_initialized ).
    " and the draft id is on the app - what db_load_by_app( ) resolves by
    cl_abap_unit_assert=>assert_equals( exp = mo_cont->ms_draft-id
                                        act = mo_user->z2ui5_if_app~id_draft ).

    lo_loaded = load_fresh( mo_cont->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_loaded->mv_check_initialized ).

    lo_app = app_of( lo_loaded ).
    cl_abap_unit_assert=>assert_equals( exp = mo_cont->ms_draft-id
                                        act = lo_app->z2ui5_if_app~id_draft ).

  ENDMETHOD.

  METHOD draft_fields_survive.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.

    mo_cont->ms_draft-id_prev     = `PREV_ID`.
    mo_cont->ms_draft-id_prev_app = `PREV_APP`.
    mo_cont->db_save( ).


    lo_loaded = load_fresh( mo_cont->ms_draft-id ).

    cl_abap_unit_assert=>assert_equals( exp = `PREV_ID`
                                        act = lo_loaded->ms_draft-id_prev ).
    cl_abap_unit_assert=>assert_equals( exp = `PREV_APP`
                                        act = lo_loaded->ms_draft-id_prev_app ).

  ENDMETHOD.

  METHOD load_buffered_per_request.
    DATA lo_first TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_second TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp10 TYPE xsdboolean.
    DATA lo_third TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp11 TYPE xsdboolean.

    mo_cont->db_save( ).


    lo_first  = load_fresh( mo_cont->ms_draft-id ).

    lo_second = z2ui5_cl_ui5_app_cont=>db_load( mo_cont->ms_draft-id ).

    temp10 = boolc( lo_first = lo_second ).
    cl_abap_unit_assert=>assert_true( act = temp10
                                      msg = `two containers for one draft in one request` ).

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    cl_abap_unit_assert=>assert_initial( z2ui5_cl_ui5_app_cont=>mt_buffer ).

    lo_third = z2ui5_cl_ui5_app_cont=>db_load( mo_cont->ms_draft-id ).

    temp11 = boolc( lo_first = lo_third ).
    cl_abap_unit_assert=>assert_false( temp11 ).

  ENDMETHOD.

  METHOD second_roundtrip_clean.
    DATA lv_table_row TYPE string.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app TYPE REF TO ltcl_cont_app.
    DATA lv_model TYPE string.
    DATA lo_third TYPE REF TO z2ui5_cl_ui5_app_cont.

    bind_all( ).

    lv_table_row = bind( ir_val  = mo_user->mr_handle_tab
                               iv_path = `/MR_HANDLE_TAB` ).
    mo_cont->db_save( ).

    lo_loaded = load_fresh( mo_cont->ms_draft-id ).

    lo_app = app_of( lo_loaded ).

    " the next render binds the same rows
    cl_abap_unit_assert=>assert_equals( exp = lv_table_row
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = lo_app->mr_handle_tab
                                                    iv_path = `/MR_HANDLE_TAB` ) ).

    lv_model = lo_loaded->model_json_stringify( ).

    lo_loaded->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_loaded->db_save( ).
    check_restored( lo_app ).

    lo_third = load_fresh( lo_loaded->ms_draft-id ).
    check_restored( app_of( lo_third ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_model
                                        act = lo_third->model_json_stringify( ) ).

  ENDMETHOD.

  METHOD change_between_drafts.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_row TYPE ltcl_cont_app=>ty_s_row.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app TYPE REF TO ltcl_cont_app.
    DATA lv_changed TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA lo_second TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app_2 TYPE REF TO ltcl_cont_app.
    DATA temp13 TYPE xsdboolean.

    bind_all( ).
    mo_cont->db_save( ).

    lo_loaded = load_fresh( mo_cont->ms_draft-id ).

    lo_app = app_of( lo_loaded ).

    " the restored instance changes its data - through the HELPER's
    " reference; the change has to reach the model of the next roundtrip
    ASSIGN lo_app->mo_inner->mr_shared->* TO <tab>.
    ls_row-col1 = `appended after the restore`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.

    lv_changed = lo_loaded->model_json_stringify( ).

    temp12 = boolc( lv_changed CS `"appended after the restore"` ).
    cl_abap_unit_assert=>assert_true( temp12 ).

    lo_loaded->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_loaded->db_save( ).

    lo_second = load_fresh( lo_loaded->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = lv_changed
                                        act = lo_second->model_json_stringify( ) ).

    lo_app_2 = app_of( lo_second ).
    ASSIGN lo_app_2->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

    temp13 = boolc( lo_app_2->mr_handle_tab = lo_app_2->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp13 ).

  ENDMETHOD.

  METHOD load_by_app_same_instance.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_by_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp14 TYPE xsdboolean.
    DATA lo_other TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp15 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.

    bind_all( ).
    mo_cont->db_save( ).
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    " what nav_app_leave( ) does without a target: get_app( ) parses the
    " draft into a container, and the stack hop then loads BY that app

    lo_loaded = z2ui5_cl_ui5_app_cont=>db_load( mo_cont->ms_draft-id ).

    lo_by_app = z2ui5_cl_ui5_app_cont=>db_load_by_app( app_of( lo_loaded ) ).

    temp14 = boolc( lo_by_app = lo_loaded ).
    cl_abap_unit_assert=>assert_true( act = temp14
                                      msg = `the hop parsed the draft a second time` ).

    " the live instance carries the same id but is not the buffered app

    lo_other = z2ui5_cl_ui5_app_cont=>db_load_by_app( mo_user ).

    temp15 = boolc( lo_other = lo_loaded ).
    cl_abap_unit_assert=>assert_false( temp15 ).

    temp16 = boolc( lo_other->mo_app = mo_user ).
    cl_abap_unit_assert=>assert_true( temp16 ).
    check_restored( mo_user ).

  ENDMETHOD.

  METHOD load_by_app_live_instance.

    DATA lv_before TYPE string.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    lv_before = bind_all( ).
    mo_cont->db_save( ).

    " the live instance changed a plain value after the save - what the
    " stack navigates back to is THIS instance, not the draft's copy
    mo_user->mv_string = `changed live`.
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_loaded = z2ui5_cl_ui5_app_cont=>db_load_by_app( mo_user ).


    temp17 = boolc( lo_loaded->mo_app = mo_user ).
    cl_abap_unit_assert=>assert_true( temp17 ).

    temp18 = boolc( lo_loaded = mo_cont ).
    cl_abap_unit_assert=>assert_false( temp18 ).
    cl_abap_unit_assert=>assert_equals( exp = `changed live`
                                        act = mo_user->mv_string ).
    " the references were restored against the live instance
    cl_abap_unit_assert=>assert_bound( mo_user->mr_handle_tab ).

    temp19 = boolc( mo_user->mr_handle_tab = mo_user->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp19 ).

    temp20 = boolc( lo_loaded->model_json_stringify( ) CS `"changed live"` ).
    cl_abap_unit_assert=>assert_true( temp20 ).

    temp21 = boolc( lo_loaded->model_json_stringify( ) = lv_before ).
    cl_abap_unit_assert=>assert_false( temp21 ).

  ENDMETHOD.

  METHOD load_by_app_after_swap.

    " roundtrip 1: the host renders sub-app A and saves
    DATA lo_a TYPE REF TO ltcl_cont_sub_a.
    DATA temp11 LIKE REF TO mo_user->mv_string.
    DATA lo_b TYPE REF TO ltcl_cont_sub_b.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp22 TYPE xsdboolean.
    FIELD-SYMBOLS <temp12> LIKE LINE OF lo_loaded->mt_attri->*.
    DATA temp13 LIKE sy-tabix.
    DATA temp14 LIKE REF TO mo_user->mv_string.
    DATA temp23 TYPE xsdboolean.
    DATA temp1 LIKE sy-subrc.
    DATA lv_before TYPE string.
    DATA temp24 TYPE xsdboolean.
    DATA lo_second TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_b_2 TYPE REF TO ltcl_cont_sub_b.
    DATA temp25 TYPE xsdboolean.
    CREATE OBJECT lo_a TYPE ltcl_cont_sub_a.
    lo_a->mt_table  = ltcl_cont_app=>table_create( `a` ).
    CREATE OBJECT lo_a->mo_layout.
    lo_a->mo_layout->mr_shared = lo_a->mt_table.
    mo_user->mo_any    = lo_a.
    mo_user->mv_string = `1`.

    GET REFERENCE OF mo_user->mv_string INTO temp11.
bind( ir_val  = temp11
          iv_path = `/MV_STRING` ).
    bind( ir_val  = lo_a->mt_table
          iv_path = `/MO_ANY_MT_TABLE` ).
    mo_cont->db_save( ).

    " between the roundtrips the host switched its tab: the LIVE instance
    " the stack navigates back to holds an instance of class B now

    CREATE OBJECT lo_b TYPE ltcl_cont_sub_b.
    lo_b->mt_data = ltcl_cont_app=>table_create( `b` ).
    CREATE OBJECT lo_b->mo_lay.
    lo_b->mo_lay->mr_shared = lo_b->mt_data.
    mo_user->mo_any = lo_b.

    " the restore against it must not raise - A's rows resolve to nothing
    " and keep no descriptor
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_loaded = z2ui5_cl_ui5_app_cont=>db_load_by_app( mo_user ).

    temp22 = boolc( lo_loaded->mo_app = mo_user ).
    cl_abap_unit_assert=>assert_true( temp22 ).


    temp13 = sy-tabix.
    READ TABLE lo_loaded->mt_attri->* WITH KEY name = `MO_ANY->MT_TABLE->*` ASSIGNING <temp12>.
    sy-tabix = temp13.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_not_bound( <temp12>-o_typedescr ).

    " the next render binds the host's own attribute (walks A's rows) and
    " B's table (not in mt_attri yet) - neither dumps, both are found

    GET REFERENCE OF mo_user->mv_string INTO temp14.
cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = temp14
                                                    iv_path = `/MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_ANY->MT_DATA->*`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = lo_b->mt_data
                                                    iv_path = `/MO_ANY_MT_DATA` ) ).


    READ TABLE lo_loaded->mt_attri->* WITH KEY name = `MO_ANY->MT_TABLE->*` TRANSPORTING NO FIELDS.
    temp1 = sy-subrc.
    temp23 = boolc( temp1 = 0 ).
    cl_abap_unit_assert=>assert_false( temp23 ).

    " ...and the draft of THIS roundtrip carries B, restored with identity

    lv_before = lo_loaded->model_json_stringify( ).

    temp24 = boolc( lv_before CS `"b"` ).
    cl_abap_unit_assert=>assert_true( temp24 ).
    lo_loaded->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    lo_loaded->db_save( ).

    lo_second = load_fresh( lo_loaded->ms_draft-id ).

    lo_b_2 ?= app_of( lo_second )->mo_any.
    cl_abap_unit_assert=>assert_bound( lo_b_2->mt_data ).

    temp25 = boolc( lo_b_2->mt_data = lo_b_2->mo_lay->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp25 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_second->model_json_stringify( ) ).

  ENDMETHOD.

  METHOD load_by_app_fills_buffer.
    DATA lo_by_app TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_by_id TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.

    bind_all( ).
    mo_cont->db_save( ).

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_by_app = z2ui5_cl_ui5_app_cont=>db_load_by_app( mo_user ).

    lo_by_id  = z2ui5_cl_ui5_app_cont=>db_load( mo_cont->ms_draft-id ).

    " the same object - whoever reaches the draft in this request mutates
    " the state everybody else sees

    temp26 = boolc( lo_by_app = lo_by_id ).
    cl_abap_unit_assert=>assert_true( temp26 ).

    temp27 = boolc( lo_by_id->mo_app = mo_user ).
    cl_abap_unit_assert=>assert_true( temp27 ).

  ENDMETHOD.


  METHOD two_drafts_one_instance.

    DATA lv_before TYPE string.
    DATA lr_tab_before LIKE mo_user->mr_handle_tab.
    DATA lv_id_1 LIKE mo_cont->ms_draft-id.
    DATA lv_id_2 LIKE mo_cont->ms_draft-id.
    DATA temp28 TYPE xsdboolean.
    DATA lo_first TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_second TYPE REF TO z2ui5_cl_ui5_app_cont.
    lv_before = bind_all( ).

    lr_tab_before = mo_user->mr_handle_tab.

    mo_cont->db_save( ).

    lv_id_1 = mo_cont->ms_draft-id.
    " the next draft id, no main( ) in between - the shape of a navigation
    " hop, which saves the caller and lets the callee read it right after
    mo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    mo_cont->db_save( ).

    lv_id_2 = mo_cont->ms_draft-id.

    " the live instance: its references back - the SAME objects, not a
    " parsed copy - no payload left on the rows, the model as before
    check_restored( mo_user ).

    temp28 = boolc( mo_user->mr_handle_tab = lr_tab_before ).
    cl_abap_unit_assert=>assert_true( act = temp28
                                      msg = `the save replaced the live table by a copy` ).
    LOOP AT mo_cont->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      cl_abap_unit_assert=>fail( `a payload stayed on the live rows` ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_cont->model_json_stringify( ) ).

    " both drafts load to that state

    lo_first  = load_fresh( lv_id_1 ).

    lo_second = load_fresh( lv_id_2 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_first->model_json_stringify( ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_second->model_json_stringify( ) ).
    check_restored( app_of( lo_first ) ).
    check_restored( app_of( lo_second ) ).

  ENDMETHOD.

  METHOD load_by_app_keeps_live_data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_row TYPE ltcl_cont_app=>ty_s_row.
    DATA lr_live LIKE mo_user->mr_handle_tab.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp29 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    DATA temp31 TYPE xsdboolean.
    DATA temp32 TYPE xsdboolean.

    bind_all( ).
    mo_cont->db_save( ).

    " after the save - the caller is on the stack - the callee appends a
    " row through the helper's reference to the shared table

    lr_live = mo_user->mr_handle_tab.
    ASSIGN mo_user->mo_inner->mr_shared->* TO <tab>.
    ls_row-col1 = `appended by the callee`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.

    " the way back restores the draft against the live instance: the
    " table is the live object with two rows, not the payload's copy with
    " one, and the rows carry no payload any more
    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).

    lo_loaded = z2ui5_cl_ui5_app_cont=>db_load_by_app( mo_user ).

    temp29 = boolc( mo_user->mr_handle_tab = lr_live ).
    cl_abap_unit_assert=>assert_true( act = temp29
                                      msg = `the payload replaced the live table` ).
    ASSIGN mo_user->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

    temp30 = boolc( mo_user->mr_handle_tab = mo_user->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp30 ).

    temp31 = boolc( mo_user->mr_handle_tab = mo_user->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_true( temp31 ).

    temp32 = boolc( lo_loaded->model_json_stringify( ) CS `"appended by the callee"` ).
    cl_abap_unit_assert=>assert_true( temp32 ).
    LOOP AT lo_loaded->mt_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      cl_abap_unit_assert=>fail( `a payload stayed on the rows` ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 03 - the errors: a draft whose payload cannot be read back is a named
" error when the data is bound, and a quiet initial reference when it is
" not; a draft that does not exist is an error of the draft service
" ---------------------------------------------------------------------------
CLASS ltcl_03_errors DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    METHODS broken_payload_bound_loud  FOR TESTING RAISING cx_static_check.
    METHODS broken_payload_unbound_ok  FOR TESTING RAISING cx_static_check.
    METHODS unknown_draft_raises       FOR TESTING RAISING cx_static_check.

    " a draft as db_save writes it, except that the payload of every
    " generic reference is not what S-RTTI wrote - answers the row names
    METHODS save_with_broken_payloads
      RETURNING
        VALUE(result) TYPE string_table.
ENDCLASS.


CLASS ltcl_03_errors IMPLEMENTATION.

  METHOD save_with_broken_payloads.

    DATA lo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA temp15 LIKE LINE OF mo_cont->mt_attri->*.
    DATA lr_attri LIKE REF TO temp15.
    DATA lv_xml TYPE string.
    DATA temp16 TYPE REF TO z2ui5_cl_ui5_srv_draft.
    lo_model = mo_cont->create_model( ).
    lo_model->main_attri_db_save_srtti( ).


    LOOP AT mo_cont->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL.
      " plain text, not malformed markup: a system answers either with a
      " catchable exception, the NodeJS parser ASSERTs on broken markup
      lr_attri->srtti_data = `this is not the serialized type`.
      APPEND lr_attri->name TO result.
    ENDLOOP.
    cl_abap_unit_assert=>assert_not_initial( result ).

    lv_xml = z2ui5_cl_ui5_util_context=>xml_stringify( mo_cont ).

    CREATE OBJECT temp16 TYPE z2ui5_cl_ui5_srv_draft.
    temp16->create( draft     = mo_cont->ms_draft
                                           model_xml = lv_xml ).

  ENDMETHOD.

  METHOD broken_payload_bound_loud.
    DATA lt_broken TYPE string_table.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp33 TYPE xsdboolean.
        DATA lv_named LIKE abap_false.
        DATA lv_name LIKE LINE OF lt_broken.

    " the shape of a draft a system upgrade or a type change left behind:
    " the load says so - the alternative was an app running on a cleared
    " reference and a view that comes back empty
    bind( ir_val  = mo_user->mr_handle_tab
          iv_path = `/MR_HANDLE_TAB` ).

    lt_broken = save_with_broken_payloads( ).

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    TRY.
        z2ui5_cl_ui5_app_cont=>db_load( mo_cont->ms_draft-id ).
        cl_abap_unit_assert=>fail( `a draft whose bound data cannot be restored must not load silently` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp33 = boolc( lx->get_text( ) CS `APP_STATE_RESTORE_ERROR` ).
        cl_abap_unit_assert=>assert_true( temp33 ).
        " the error names a broken row - the canonical one of the shared
        " table, whichever of its references sorts last

        lv_named = abap_false.

        LOOP AT lt_broken INTO lv_name.
          IF lx->get_text( ) CS lv_name.
            lv_named = abap_true.
          ENDIF.
        ENDLOOP.
        cl_abap_unit_assert=>assert_true( act = lv_named
                                          msg = |the error names no row: { lx->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

  METHOD broken_payload_unbound_ok.

    " nothing bound reads the references: the load passes, the references
    " stay initial, everything else is restored
    DATA temp17 LIKE REF TO mo_user->mv_string.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_app TYPE REF TO ltcl_cont_app.
    DATA temp34 TYPE xsdboolean.
    GET REFERENCE OF mo_user->mv_string INTO temp17.
bind( ir_val  = temp17
          iv_path = `/MV_STRING` ).
    save_with_broken_payloads( ).


    lo_loaded = load_fresh( mo_cont->ms_draft-id ).


    lo_app = app_of( lo_loaded ).
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_app->mv_string ).
    cl_abap_unit_assert=>assert_not_bound( lo_app->mr_handle_tab ).
    cl_abap_unit_assert=>assert_not_bound( lo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `inner`
                                        act = lo_app->mo_inner->mv_inner ).

    temp34 = boolc( lo_loaded->model_json_stringify( ) CS `"text"` ).
    cl_abap_unit_assert=>assert_true( temp34 ).

  ENDMETHOD.

  METHOD unknown_draft_raises.

    z2ui5_cl_ui5_app_cont=>db_load_buffer_clear( ).
    TRY.
        z2ui5_cl_ui5_app_cont=>db_load( `NO_SUCH_DRAFT_` && z2ui5_cl_ui5_util_context=>uuid_get_c32( ) ).
        cl_abap_unit_assert=>fail( `a draft that does not exist must not load` ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 04 - the model through the container: what model_json_stringify( ) ships
" and what model_json_parse( ) writes back, with the refused cells as its
" answer. The rules per form are with z2ui5_cl_ui5_srv_model; this is the
" container's contract on top of them
" ---------------------------------------------------------------------------
CLASS ltcl_04_model DEFINITION FINAL INHERITING FROM ltcl_00_base
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    METHODS stringify_bound_rows_only FOR TESTING RAISING cx_static_check.
    METHODS parse_writes_back         FOR TESTING RAISING cx_static_check.
    METHODS parse_answers_refused     FOR TESTING RAISING cx_static_check.
    METHODS nothing_bound_is_empty    FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_04_model IMPLEMENTATION.

  METHOD stringify_bound_rows_only.

    DATA temp18 LIKE REF TO mo_user->mv_string.
    DATA lo_json TYPE REF TO z2ui5_cl_ajson.
    GET REFERENCE OF mo_user->mv_string INTO temp18.
bind( ir_val  = temp18
          iv_path = `/MV_STRING` ).
    bind( ir_val  = mo_user->mr_handle_tab
          iv_path = `/MR_HANDLE_TAB` ).


    lo_json = z2ui5_cl_ajson=>parse( mo_cont->model_json_stringify( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_json->get_string( `/MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `handle`
                                        act = lo_json->get_string( `/MR_HANDLE_TAB/1/COL1` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->exists( `/MT_STD` ) ).
    cl_abap_unit_assert=>assert_false( lo_json->exists( `/MO_INNER_MV_INNER` ) ).

  ENDMETHOD.

  METHOD parse_writes_back.
    DATA temp19 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp19.
    DATA lt_skipped TYPE z2ui5_if_client=>ty_t_model_skip.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <col> TYPE any.

    bind_all( ).
    " a whole value for the scalars, a cell edit (the __delta form) for
    " the runtime-built table

    temp19 ?= z2ui5_cl_ajson=>parse( `{"MV_STRING":"written","MO_INNER_MV_INNER":"inner-written",` && `"MR_HANDLE_TAB":{"__delta":{"0":{"COL1":"handle-written"}}}}` ).

    lo_front = temp19.


    lt_skipped = mo_cont->model_json_parse( lo_front ).




    cl_abap_unit_assert=>assert_initial( lt_skipped ).
    cl_abap_unit_assert=>assert_equals( exp = `written`
                                        act = mo_user->mv_string ).
    cl_abap_unit_assert=>assert_equals( exp = `inner-written`
                                        act = mo_user->mo_inner->mv_inner ).
    ASSIGN mo_user->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 1 ASSIGNING <row>.
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `handle-written`
                                        act = <col> ).

  ENDMETHOD.

  METHOD parse_answers_refused.

    DATA temp20 LIKE REF TO mo_user->mt_std.
    DATA temp21 TYPE REF TO z2ui5_if_ajson.
    DATA lo_front LIKE temp21.
    DATA lt_skipped TYPE z2ui5_if_client=>ty_t_model_skip.
    FIELD-SYMBOLS <temp22> LIKE LINE OF lt_skipped.
    DATA temp23 LIKE sy-tabix.
    FIELD-SYMBOLS <temp24> LIKE LINE OF lt_skipped.
    DATA temp25 LIKE sy-tabix.
    FIELD-SYMBOLS <temp26> LIKE LINE OF lt_skipped.
    DATA temp27 LIKE sy-tabix.
    FIELD-SYMBOLS <temp28> LIKE LINE OF mo_user->mt_std.
    DATA temp29 LIKE sy-tabix.
    FIELD-SYMBOLS <temp30> LIKE LINE OF mo_user->mt_std.
    DATA temp31 LIKE sy-tabix.
    GET REFERENCE OF mo_user->mt_std INTO temp20.
bind( ir_val  = temp20
          iv_path = `/MT_STD` ).
    " a cell edit whose number is no number: refused, kept, and reported -
    " the other cell of the same edit is written

    temp21 ?= z2ui5_cl_ajson=>parse( `{"MT_STD":{"__delta":{"0":{"COL1":"still fine","COL2":"not a number"}}}}` ).

    lo_front = temp21.


    lt_skipped = mo_cont->model_json_parse( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_skipped ) ).


    temp23 = sy-tabix.
    READ TABLE lt_skipped INDEX 1 ASSIGNING <temp22>.
    sy-tabix = temp23.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = <temp22>-name ).


    temp25 = sy-tabix.
    READ TABLE lt_skipped INDEX 1 ASSIGNING <temp24>.
    sy-tabix = temp25.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `COL2`
                                        act = <temp24>-field ).


    temp27 = sy-tabix.
    READ TABLE lt_skipped INDEX 1 ASSIGNING <temp26>.
    sy-tabix = temp27.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `not a number`
                                        act = <temp26>-value ).


    temp29 = sy-tabix.
    READ TABLE mo_user->mt_std INDEX 1 ASSIGNING <temp28>.
    sy-tabix = temp29.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = <temp28>-col2 ).


    temp31 = sy-tabix.
    READ TABLE mo_user->mt_std INDEX 1 ASSIGNING <temp30>.
    sy-tabix = temp31.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `still fine`
                                        act = <temp30>-col1 ).

  ENDMETHOD.

  METHOD nothing_bound_is_empty.

    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = mo_cont->model_json_stringify( ) ).

  ENDMETHOD.

ENDCLASS.
