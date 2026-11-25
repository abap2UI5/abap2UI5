" ---------------------------------------------------------------------------
" The shipped serializer: the asXML round trip with the S-RTTI detach of the
" generic references, the one retry after main_attri_refresh, the reattach
" on every path out, and the chain of the FIRST failure. Plus the seam it
" implements: set_serializer( ) on the container is honoured by both
" directions. And the rows the draft stores of the attribute table
" (ltcl_stored_rows).
" ---------------------------------------------------------------------------

" an app with the two shapes the serializer treats differently: a typed
" attribute that travels in the asXML, and a generic reference to a
" runtime-built table that S-RTTI detaches and the reattach has to bring back
CLASS ltcl_ser_app DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.

    DATA mv_text TYPE string.
    DATA mr_tab  TYPE REF TO data.

    METHODS fill.
ENDCLASS.


CLASS ltcl_ser_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_row  TYPE ty_s_row.
    " c LENGTH 1, not abap_bool - the NodeJS runtime cannot resolve a
    " type-pool type by its absolute name when S-RTTI rebuilds the line
    DATA lv_flag TYPE c LENGTH 1.

    mv_text = `text`.

    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_row ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    INSERT VALUE #( name = `RUNTIME_ONLY`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_flag ) ) ) INTO TABLE lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mr_tab TYPE HANDLE lo_tab.
    ASSIGN mr_tab->* TO <tab>.
    ls_row-col1 = `handle`.
    INSERT INITIAL LINE INTO TABLE <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_row TO <row>.

  ENDMETHOD.

ENDCLASS.


" a serializable helper an app keeps in an attribute
CLASS ltcl_ser_child DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    DATA mv_name TYPE string.
    DATA mt_tags TYPE string_table.
ENDCLASS.


CLASS ltcl_ser_child IMPLEMENTATION.
ENDCLASS.


" the shapes a real app keeps besides the two above: a table of rows that
" carry a table, a helper object, a typed and a generic reference to an
" elementary value, and a generic reference that points INTO another
" attribute of the same app
CLASS ltcl_ser_app_deep DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_item,
        pos TYPE i,
        txt TYPE string,
      END OF ty_s_item.
    TYPES ty_t_item TYPE STANDARD TABLE OF ty_s_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_s_head,
        id      TYPE string,
        amount  TYPE p LENGTH 10 DECIMALS 2,
        t_items TYPE ty_t_item,
      END OF ty_s_head.
    TYPES ty_t_head TYPE STANDARD TABLE OF ty_s_head WITH EMPTY KEY.

    DATA mt_head      TYPE ty_t_head.
    DATA mo_child     TYPE REF TO ltcl_ser_child.
    DATA mr_typed     TYPE REF TO string.
    DATA mr_elem      TYPE REF TO data.
    DATA mr_alias_tab TYPE REF TO data.

    METHODS fill.
ENDCLASS.


CLASS ltcl_ser_app_deep IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <elem> TYPE any.

    mt_head = VALUE #( ( id      = `H1`
                         amount  = '12.50'
                         t_items = VALUE #( ( pos = 1 txt = `first` )
                                            ( pos = 2 txt = `second` ) ) )
                       ( id      = `H2`
                         amount  = '-3.75'
                         t_items = VALUE #( ) ) ).
    mo_child = NEW #( ).
    mo_child->mv_name = `child`.
    mo_child->mt_tags = VALUE #( ( `a` ) ( `b` ) ).
    " CREATE DATA, not NEW #( `typed` ): the downport turns a NEW of a data
    " reference into a CREATE OBJECT that does not parse
    CREATE DATA mr_typed.
    mr_typed->* = `typed`.
    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `generic`.
    mr_alias_tab = REF #( mt_head ).

  ENDMETHOD.

ENDCLASS.


" an app with a windowed table (window_bind_tab( )): the rows travel next to
" the container's asXML, in the frame of the draft, not inside it
CLASS ltcl_ser_app_win DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id   TYPE i,
        name TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mt_rows TYPE ty_t_row.
    DATA mv_text TYPE string.
ENDCLASS.


CLASS ltcl_ser_app_win IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

ENDCLASS.


" the shipped serializer whose transformation fails the first N times -
" the seam the class is not FINAL for (see its class comment)
CLASS ltcl_ser_failing DEFINITION INHERITING FROM z2ui5_cl_ui5_serializer
  FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_fail_count TYPE i.
    DATA mv_calls      TYPE i.

  PROTECTED SECTION.
    METHODS xml_of REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_ser_failing IMPLEMENTATION.

  METHOD xml_of.

    mv_calls = mv_calls + 1.
    IF mv_calls <= mv_fail_count.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = |TRANSFORMATION_FAILURE_{ mv_calls }|.
    ENDIF.
    result = super->xml_of( container ).

  ENDMETHOD.

ENDCLASS.


" a host's own serializer: what set_serializer( ) installs
CLASS ltcl_ser_double DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_serializer.
ENDCLASS.


CLASS ltcl_ser_double IMPLEMENTATION.

  METHOD z2ui5_if_ui5_serializer~stringify.

    result = `DOUBLE`.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_serializer~parse.

    DATA(lo_cont) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_cont->ms_draft-id = val.
    result = lo_cont.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    DATA mo_app  TYPE REF TO ltcl_ser_app.
    DATA mo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS setup.
    METHODS teardown.

    " the reference the save detaches is back on the live instance and the
    " payload the rows carried for the draft is gone - on every path out
    METHODS check_reattached.

    " the round trip as a system runs it, and the live instance after it
    METHODS roundtrip_default          FOR TESTING RAISING cx_static_check.
    " every attempt fails: the FIRST cause is chained, the retry ran, the
    " live instance has its references back
    METHODS failure_chains_first_cause FOR TESTING RAISING cx_static_check.
    " the first attempt fails, the retry answers - and reattaches too
    METHODS retry_answers              FOR TESTING RAISING cx_static_check.
    " set_serializer( ) is what both container methods go through, and an
    " unbound reference restores the shipped one
    METHODS set_serializer_honoured    FOR TESTING RAISING cx_static_check.
    " the contract of parse( ): an empty string is a first roundtrip and
    " answers an unbound reference, not an empty container
    METHODS parse_empty_unbound        FOR TESTING RAISING cx_static_check.
    " parse( stringify( ) ) is a container the framework goes on with: the
    " generic reference comes back through the attribute load, with the
    " component only the runtime-built line type has
    METHODS roundtrip_restores_dref    FOR TESTING RAISING cx_static_check.
    " nested tables, a helper object, typed and generic references and an
    " alias into another attribute - all back, the alias still an alias
    METHODS roundtrip_deep_app         FOR TESTING RAISING cx_static_check.
    " the live instance after a stringify is the same instance with the
    " same data - nothing parsed, nothing copied
    METHODS live_instance_untouched    FOR TESTING RAISING cx_static_check.
    " a windowed table travels in the container like every other
    " attribute - the rows the app loaded, and its window state with it
    METHODS window_roundtrip           FOR TESTING RAISING cx_static_check.

    "! a container around an app with three rows in a windowed MT_ROWS
    METHODS win_cont
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS load
      IMPORTING
        iv_xml        TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->fill( ).
    mo_cont = NEW #( ).
    mo_cont->mo_app      = mo_app.
    mo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

  ENDMETHOD.

  METHOD teardown.

    " whatever a test installed, the next one starts on the shipped one
    DATA li_none TYPE REF TO z2ui5_if_ui5_serializer.
    z2ui5_cl_ui5_app_cont=>set_serializer( li_none ).

  ENDMETHOD.

  METHOD check_reattached.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_tab
                                       msg = `the generic reference was not reattached` ).
    ASSIGN mo_app->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    LOOP AT mo_cont->mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL OR srtti_type IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |a payload stayed on the live row { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD roundtrip_default.

    DATA(lo_serializer) = NEW z2ui5_cl_ui5_serializer( ).

    DATA(lv_xml) = lo_serializer->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `<asx:abap` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `text` ) ).
    check_reattached( ).

    DATA(lo_parsed) = CAST z2ui5_cl_ui5_app_cont( lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ) ).
    cl_abap_unit_assert=>assert_equals( exp = mo_cont->ms_draft-id
                                        act = lo_parsed->ms_draft-id ).
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = CAST ltcl_ser_app( lo_parsed->mo_app )->mv_text ).

  ENDMETHOD.

  METHOD failure_chains_first_cause.

    DATA(lo_failing) = NEW ltcl_ser_failing( ).
    lo_failing->mv_fail_count = 2.

    TRY.
        lo_failing->z2ui5_if_ui5_serializer~stringify( mo_cont ).
        cl_abap_unit_assert=>fail( `a container that cannot be serialized must raise` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text_own( ) CS `APP_SERIALIZATION_ERROR` ) ).
        " the first attempt's failure names the cause; the retry's is the
        " follow-up of the same root and must not replace it
        cl_abap_unit_assert=>assert_bound( act = lx->previous
                                           msg = `the serialization failure was not chained` ).
        DATA(lv_cause) = lx->previous->get_text( ).
        cl_abap_unit_assert=>assert_true( xsdbool( lv_cause CS `TRANSFORMATION_FAILURE_1` ) ).
        cl_abap_unit_assert=>assert_false( xsdbool( lv_cause CS `TRANSFORMATION_FAILURE_2` ) ).
    ENDTRY.

    " both attempts ran - the retry rebuilt the rows and tried again
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_failing->mv_calls ).
    " ...and the live instance goes on with its references, whichever
    " attempt detached them last (a sticky session serves the next request
    " on this very instance)
    check_reattached( ).

  ENDMETHOD.

  METHOD retry_answers.

    DATA(lo_failing) = NEW ltcl_ser_failing( ).
    lo_failing->mv_fail_count = 1.

    DATA(lv_xml) = lo_failing->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_failing->mv_calls ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `<asx:abap` ) ).
    check_reattached( ).

  ENDMETHOD.

  METHOD load.

    " what z2ui5_cl_ui5_app_cont=>db_load does with the string: parse it,
    " then restore the attributes against the app the parse produced
    result ?= NEW z2ui5_cl_ui5_serializer( )->z2ui5_if_ui5_serializer~parse( iv_xml ).
    NEW z2ui5_cl_ui5_srv_model( attri = result->mt_attri
                                app   = result->mo_app )->main_attri_db_load( ).

  ENDMETHOD.

  METHOD parse_empty_unbound.

    DATA(lo_serializer) = NEW z2ui5_cl_ui5_serializer( ).

    cl_abap_unit_assert=>assert_not_bound( lo_serializer->z2ui5_if_ui5_serializer~parse( `` ) ).
    DATA lv_empty TYPE c LENGTH 10.
    cl_abap_unit_assert=>assert_not_bound( lo_serializer->z2ui5_if_ui5_serializer~parse( lv_empty ) ).

  ENDMETHOD.

  METHOD roundtrip_restores_dref.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <col> TYPE any.

    DATA(lv_xml) = NEW z2ui5_cl_ui5_serializer( )->z2ui5_if_ui5_serializer~stringify( mo_cont ).
    DATA(lo_loaded) = load( lv_xml ).

    DATA(lo_app) = CAST ltcl_ser_app( lo_loaded->mo_app ).
    cl_abap_unit_assert=>assert_false( act = xsdbool( lo_app = mo_app )
                                       msg = `the parse must build a new instance` ).
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_tab
                                       msg = `the generic reference did not come back` ).
    ASSIGN lo_app->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    ASSIGN <tab>[ 1 ] TO <row>.
    cl_abap_unit_assert=>assert_true( xsdbool( <row> IS ASSIGNED ) ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `handle`
                                        act = <col> ).
    ASSIGN COMPONENT `RUNTIME_ONLY` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( msg = `the runtime-built line type lost its component` ).
    " the payload is consumed by the load, not carried on into the next save
    LOOP AT lo_loaded->mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL OR srtti_type IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |a payload stayed on the loaded row { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD roundtrip_deep_app.

    FIELD-SYMBOLS <elem>  TYPE any.
    FIELD-SYMBOLS <alias> TYPE ltcl_ser_app_deep=>ty_t_head.

    DATA(lo_deep) = NEW ltcl_ser_app_deep( ).
    lo_deep->fill( ).
    DATA(lo_cont) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_cont->mo_app      = lo_deep.
    lo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).

    DATA(lv_xml) = NEW z2ui5_cl_ui5_serializer( )->z2ui5_if_ui5_serializer~stringify( lo_cont ).
    DATA(lo_app) = CAST ltcl_ser_app_deep( load( lv_xml )->mo_app ).

    " the nested table, row by row, the empty inner table included
    cl_abap_unit_assert=>assert_equals( exp = lo_deep->mt_head
                                        act = lo_app->mt_head ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_app->mt_head[ 1 ]-t_items ) ).
    cl_abap_unit_assert=>assert_initial( lo_app->mt_head[ 2 ]-t_items ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '-3.75' )
                                        act = CONV decfloat34( lo_app->mt_head[ 2 ]-amount ) ).
    " the helper object, with its own table
    cl_abap_unit_assert=>assert_bound( lo_app->mo_child ).
    cl_abap_unit_assert=>assert_equals( exp = `child`
                                        act = lo_app->mo_child->mv_name ).
    cl_abap_unit_assert=>assert_equals( exp = lo_deep->mo_child->mt_tags
                                        act = lo_app->mo_child->mt_tags ).
    " the typed and the generic reference to an elementary value
    cl_abap_unit_assert=>assert_bound( lo_app->mr_typed ).
    cl_abap_unit_assert=>assert_equals( exp = `typed`
                                        act = lo_app->mr_typed->* ).
    cl_abap_unit_assert=>assert_bound( lo_app->mr_elem ).
    ASSIGN lo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `generic`
                                        act = <elem> ).
    " the alias points at the RESTORED attribute, not at a copy of it: a
    " row appended through it is a row of mt_head
    cl_abap_unit_assert=>assert_bound( lo_app->mr_alias_tab ).
    ASSIGN lo_app->mr_alias_tab->* TO <alias>.
    cl_abap_unit_assert=>assert_subrc( ).
    INSERT VALUE #( id = `H3` ) INTO TABLE <alias>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_head ) ).

  ENDMETHOD.

  METHOD live_instance_untouched.

    DATA(lo_deep) = NEW ltcl_ser_app_deep( ).
    lo_deep->fill( ).
    DATA(lo_child) = lo_deep->mo_child.
    DATA(lr_typed) = lo_deep->mr_typed.
    DATA(lr_alias) = lo_deep->mr_alias_tab.
    DATA(lt_head)  = lo_deep->mt_head.
    DATA(lo_cont) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_cont->mo_app = lo_deep.

    NEW z2ui5_cl_ui5_serializer( )->z2ui5_if_ui5_serializer~stringify( lo_cont ).

    " the save detached the references and the reattach put the SAME ones
    " back - a sticky session goes on with this very instance
    cl_abap_unit_assert=>assert_equals( exp = lo_child
                                        act = lo_deep->mo_child ).
    cl_abap_unit_assert=>assert_equals( exp = lr_typed
                                        act = lo_deep->mr_typed ).
    cl_abap_unit_assert=>assert_equals( exp = lr_alias
                                        act = lo_deep->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = lt_head
                                        act = lo_deep->mt_head ).

  ENDMETHOD.

  METHOD win_cont.

    DATA(lo_app) = NEW ltcl_ser_app_win( ).
    lo_app->mv_text = `text`.
    lo_app->mt_rows = VALUE #( ( id = 1 name = `first` )
                               ( id = 2 name = `second` )
                               ( id = 3 name = `third` ) ).
    result = NEW #( ).
    result->mo_app      = lo_app.
    result->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    " the rows of the attributes, and MT_ROWS made a window - what
    " window_bind_tab( ) leaves on the row
    NEW z2ui5_cl_ui5_srv_model( attri = result->mt_attri
                                app   = result->mo_app )->main_attri_refresh( ).
    ASSIGN result->mt_attri->*[ name = `MT_ROWS` ] TO FIELD-SYMBOL(<attri>).
    cl_abap_unit_assert=>assert_true( act = xsdbool( <attri> IS ASSIGNED )
                                      msg = `no row for MT_ROWS` ).
    DATA(lr_attri) = REF #( <attri> ).
    lr_attri->bind         = abap_true.
    lr_attri->window_size  = 2.
    lr_attri->window_total = 5000.
    lr_attri->window_event = `ROWS`.

  ENDMETHOD.

  METHOD window_roundtrip.

    DATA(lo_cont) = win_cont( ).
    DATA(lo_app) = CAST ltcl_ser_app_win( lo_cont->mo_app ).
    DATA(lo_serializer) = NEW z2ui5_cl_ui5_serializer( ).

    DATA(lv_xml) = lo_serializer->z2ui5_if_ui5_serializer~stringify( lo_cont ).

    " the live instance goes on with its rows
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_rows ) ).

    DATA(lo_parsed) = CAST z2ui5_cl_ui5_app_cont( lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ) ).
    DATA(lo_back) = CAST ltcl_ser_app_win( lo_parsed->mo_app ).
    cl_abap_unit_assert=>assert_equals( exp = lo_app->mt_rows
                                        act = lo_back->mt_rows ).
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_back->mv_text ).
    ASSIGN lo_parsed->mt_attri->*[ name = `MT_ROWS` ] TO FIELD-SYMBOL(<attri>).
    cl_abap_unit_assert=>assert_true( act = xsdbool( <attri> IS ASSIGNED )
                                      msg = `no row for MT_ROWS after the parse` ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <attri>-window_size ).
    cl_abap_unit_assert=>assert_equals( exp = 5000
                                        act = <attri>-window_total ).
    cl_abap_unit_assert=>assert_equals( exp = `ROWS`
                                        act = <attri>-window_event ).

  ENDMETHOD.

  METHOD set_serializer_honoured.

    z2ui5_cl_ui5_app_cont=>set_serializer( NEW ltcl_ser_double( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `DOUBLE`
                                        act = mo_cont->all_xml_stringify( ) ).
    DATA(lo_parsed) = z2ui5_cl_ui5_app_cont=>all_xml_parse( `FROM_DOUBLE` ).
    cl_abap_unit_assert=>assert_equals( exp = `FROM_DOUBLE`
                                        act = lo_parsed->ms_draft-id ).
    " the double did not touch the live instance
    cl_abap_unit_assert=>assert_bound( mo_app->mr_tab ).

    " an unbound reference restores the shipped serializer
    DATA li_none TYPE REF TO z2ui5_if_ui5_serializer.
    z2ui5_cl_ui5_app_cont=>set_serializer( li_none ).
    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5_CL_UI5_SERIALIZER`
        act = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( z2ui5_cl_ui5_app_cont=>get_serializer( ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_cont->all_xml_stringify( ) CS `<asx:abap` ) ).

  ENDMETHOD.

ENDCLASS.


" what the stored rows have to carry for the N4 lazy interface rows: an
" attribute an interface declares, bound, and one that is not
INTERFACE lif_ser_state.
  DATA mv_state TYPE string.
  DATA mv_other TYPE string.
ENDINTERFACE.


" an app shaped like the ones whose drafts the attribute table used to
" swell: a big public structure nothing binds, a few bound values, a
" windowed table whose total is an attribute, an alias onto that table,
" a generic reference with a payload and an interface attribute
CLASS ltcl_ser_app_rows DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    INTERFACES lif_ser_state.

    TYPES:
      BEGIN OF ty_s_big,
        f01 TYPE string,
        f02 TYPE i,
        f03 TYPE c LENGTH 10,
        f04 TYPE string,
        f05 TYPE i,
        f06 TYPE c LENGTH 10,
        f07 TYPE string,
        f08 TYPE i,
        f09 TYPE c LENGTH 10,
        f10 TYPE string,
        f11 TYPE i,
        f12 TYPE c LENGTH 10,
        f13 TYPE string,
        f14 TYPE i,
        f15 TYPE c LENGTH 10,
        f16 TYPE string,
        f17 TYPE i,
        f18 TYPE c LENGTH 10,
        f19 TYPE string,
        f20 TYPE i,
      END OF ty_s_big.
    TYPES:
      BEGIN OF ty_s_item,
        id  TYPE i,
        txt TYPE string,
      END OF ty_s_item.
    TYPES ty_t_item TYPE STANDARD TABLE OF ty_s_item WITH EMPTY KEY.

    DATA mv_name  TYPE string.
    DATA mv_note  TYPE string.
    DATA mv_total TYPE i.
    DATA ms_big   TYPE ty_s_big.
    DATA ms_big2  TYPE ty_s_big.
    DATA mt_items TYPE ty_t_item.
    DATA mr_alias TYPE REF TO data.
    DATA mr_elem  TYPE REF TO data.

    METHODS fill.
ENDCLASS.


CLASS ltcl_ser_app_rows IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <elem> TYPE any.

    mv_name  = `name`.
    mv_note  = `note`.
    mv_total = 500.
    ms_big-f01 = `big`.
    ms_big-f05 = 5.
    ms_big2-f03 = `big2`.
    mt_items = VALUE #( ( id = 1 txt = `one` )
                        ( id = 2 txt = `two` ) ).
    mr_alias = REF #( mt_items ).
    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `payload`.
    lif_ser_state~mv_state = `state`.
    lif_ser_state~mv_other = `other`.

  ENDMETHOD.

ENDCLASS.


" The draft stores the bound rows and what the alias pass and the restore
" need, not every row the dissolve wrote (z2ui5_cl_ui5_srv_model=>
" main_attri_db_rows) - and never a type descriptor. What a left-out row
" costs is one rebuild when a later _bind( ) asks for it; what the draft
" carries has to come back exactly as before
CLASS ltcl_stored_rows DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_app  TYPE REF TO ltcl_ser_app_rows.
    DATA mo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS setup.

    "! the bindings of the app's view, as _bind( ) makes them - on the
    "! container handed in, against the app it holds
    METHODS bind_view
      IMPORTING
        io_cont TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS bind
      IMPORTING
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
        ir_val        TYPE REF TO data
        is_config     TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    "! stringify, parse, restore - what db_save and db_load do with it
    METHODS roundtrip
      IMPORTING
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    METHODS stored_names
      IMPORTING
        io_cont       TYPE REF TO z2ui5_cl_ui5_app_cont
      RETURNING
        VALUE(result) TYPE string_table.

    " the size assertion: the rows of the big structures stay out
    METHODS stored_rows_lean           FOR TESTING RAISING cx_static_check.
    METHODS no_type_descriptor_stored  FOR TESTING RAISING cx_static_check.
    METHODS model_json_identical       FOR TESTING RAISING cx_static_check.
    METHODS alias_identity_kept        FOR TESTING RAISING cx_static_check.
    METHODS draft_stable               FOR TESTING RAISING cx_static_check.
    METHODS rebind_without_rebuild     FOR TESTING RAISING cx_static_check.
    METHODS bind_new_rebuilds          FOR TESTING RAISING cx_static_check.
    METHODS window_total_kept          FOR TESTING RAISING cx_static_check.
    METHODS intf_binding_roundtrips    FOR TESTING RAISING cx_static_check.
    METHODS dref_payload_unchanged     FOR TESTING RAISING cx_static_check.
    METHODS sticky_live_table_kept     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_stored_rows IMPLEMENTATION.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->fill( ).
    mo_cont = NEW #( ).
    mo_cont->mo_app      = mo_app.
    mo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    bind_view( mo_cont ).

  ENDMETHOD.

  METHOD bind.

    DATA(ls_config) = is_config.
    ls_config-path_only = abap_true.
    result = NEW z2ui5_cl_ui5_srv_bind( io_cont )->main( val    = ir_val
                                                         config = ls_config ).

  ENDMETHOD.

  METHOD bind_view.

    FIELD-SYMBOLS <elem> TYPE any.

    DATA(lo_app) = CAST ltcl_ser_app_rows( io_cont->mo_app ).
    bind( io_cont = io_cont
          ir_val  = REF #( lo_app->mv_name ) ).
    bind( io_cont   = io_cont
          ir_val    = REF #( lo_app->mt_items )
          is_config = VALUE #( window           = 10
                               window_total     = lo_app->mv_total
                               window_total_ref = REF #( lo_app->mv_total )
                               window_event     = `ROWS` ) ).
    bind( io_cont = io_cont
          ir_val  = REF #( lo_app->lif_ser_state~mv_state ) ).
    ASSIGN lo_app->mr_elem->* TO <elem>.
    bind( io_cont = io_cont
          ir_val  = REF #( <elem> ) ).

  ENDMETHOD.

  METHOD roundtrip.

    DATA(lo_serializer) = NEW z2ui5_cl_ui5_serializer( ).
    DATA(lv_xml) = lo_serializer->z2ui5_if_ui5_serializer~stringify( io_cont ).
    result ?= lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ).
    NEW z2ui5_cl_ui5_srv_model( attri = result->mt_attri
                                app   = result->mo_app )->main_attri_db_load( ).

  ENDMETHOD.

  METHOD stored_names.

    LOOP AT io_cont->mt_attri->* REFERENCE INTO DATA(lr_attri).
      INSERT lr_attri->name INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD stored_rows_lean.

    DATA(lv_live) = lines( mo_cont->mt_attri->* ).
    DATA(lo_loaded) = roundtrip( mo_cont ).

    " forty rows of components and the interface rows nobody binds stay
    " out; what stays is bound, owns or aliases data, sits below a data
    " reference or is the total of a window
    cl_abap_unit_assert=>assert_equals(
        exp = VALUE string_table( ( `LIF_SER_STATE~MV_STATE` )
                                  ( `MR_ALIAS` )
                                  ( `MR_ALIAS->*` )
                                  ( `MR_ELEM` )
                                  ( `MR_ELEM->*` )
                                  ( `MS_BIG` )
                                  ( `MS_BIG2` )
                                  ( `MT_ITEMS` )
                                  ( `MV_NAME` )
                                  ( `MV_TOTAL` ) )
        act = stored_names( lo_loaded ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_live > 50 ) ).

  ENDMETHOD.

  METHOD no_type_descriptor_stored.

    DATA(lo_serializer) = NEW z2ui5_cl_ui5_serializer( ).
    DATA(lv_xml) = lo_serializer->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_xml NS `CL_ABAP_` )
                                      msg = `a type descriptor went into the draft` ).
    DATA(lo_parsed) = CAST z2ui5_cl_ui5_app_cont( lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ) ).
    LOOP AT lo_parsed->mt_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE o_typedescr IS BOUND.
      cl_abap_unit_assert=>fail( |the row { lr_attri->name } came back with a descriptor| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD model_json_identical.

    DATA(lv_before) = mo_cont->model_json_stringify( ).
    DATA(lo_loaded) = roundtrip( mo_cont ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_loaded->model_json_stringify( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `payload` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `state` ) ).

  ENDMETHOD.

  METHOD alias_identity_kept.

    FIELD-SYMBOLS <alias> TYPE ltcl_ser_app_rows=>ty_t_item.

    DATA(lo_loaded) = roundtrip( roundtrip( mo_cont ) ).
    DATA(lo_app) = CAST ltcl_ser_app_rows( lo_loaded->mo_app ).

    " the reference points at the restored table, not at a copy of it
    ASSIGN lo_app->mr_alias->* TO <alias>.
    cl_abap_unit_assert=>assert_subrc( ).
    INSERT VALUE #( id = 3 ) INTO TABLE <alias>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_items ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_ITEMS`
                                        act = lo_loaded->mt_attri->*[ name = `MR_ALIAS->*` ]-name_ref ).

  ENDMETHOD.

  METHOD draft_stable.

    " a draft restored and written again does not grow - nothing the
    " left-out rows held comes back as a copy of an alias. The length, not
    " the text: the payload names the anonymous type of the restored data
    " object, which the runtime numbers anew
    DATA(lo_serializer) = NEW z2ui5_cl_ui5_serializer( ).
    DATA(lo_loaded) = roundtrip( mo_cont ).
    DATA(lv_first) = lo_serializer->z2ui5_if_ui5_serializer~stringify( lo_loaded ).
    DATA(lo_again) = roundtrip( lo_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = strlen( lv_first )
                                        act = strlen( lo_serializer->z2ui5_if_ui5_serializer~stringify( lo_again ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = stored_names( lo_loaded )
                                        act = stored_names( lo_again ) ).

  ENDMETHOD.

  METHOD rebind_without_rebuild.

    DATA(lo_loaded) = roundtrip( mo_cont ).
    DATA(lv_rows) = lines( lo_loaded->mt_attri->* ).

    " the next render binds the same view: every row is in the draft, the
    " search answers without rebuilding the table
    bind_view( lo_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( lo_loaded->mt_attri->* ) ).

  ENDMETHOD.

  METHOD bind_new_rebuilds.

    DATA(lo_loaded) = roundtrip( mo_cont ).
    DATA(lo_app) = CAST ltcl_ser_app_rows( lo_loaded->mo_app ).
    DATA(lv_rows) = lines( lo_loaded->mt_attri->* ).

    " left out of the draft - found by the rebuild
    cl_abap_unit_assert=>assert_equals( exp = `/MV_NOTE`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = REF #( lo_app->mv_note ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lines( lo_loaded->mt_attri->* ) > lv_rows ) ).
    cl_abap_unit_assert=>assert_equals( exp = `/MS_BIG/F05`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = REF #( lo_app->ms_big-f05 ) ) ).
    " the rebuild kept what was bound
    cl_abap_unit_assert=>assert_true( lo_loaded->mt_attri->*[ name = `MV_NAME` ]-bind ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_TOTAL`
                                        act = lo_loaded->mt_attri->*[ name = `MT_ITEMS` ]-window_total_name ).

    DATA(lv_json) = roundtrip( lo_loaded )->model_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `note` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"F05":5` ) ).

  ENDMETHOD.

  METHOD window_total_kept.

    DATA(lo_loaded) = roundtrip( mo_cont ).
    DATA(lo_app) = CAST ltcl_ser_app_rows( lo_loaded->mo_app ).
    DATA(lv_rows) = lines( lo_loaded->mt_attri->* ).

    " window_adopt asks for the total without a rebuild (main_attri_find):
    " its row has to be in the draft, or the total froze at this render
    bind( io_cont   = lo_loaded
          ir_val    = REF #( lo_app->mt_items )
          is_config = VALUE #( window           = 10
                               window_total     = lo_app->mv_total
                               window_total_ref = REF #( lo_app->mv_total )
                               window_event     = `ROWS` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `MV_TOTAL`
                                        act = lo_loaded->mt_attri->*[ name = `MT_ITEMS` ]-window_total_name ).
    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( lo_loaded->mt_attri->* ) ).

  ENDMETHOD.

  METHOD intf_binding_roundtrips.

    DATA(lo_loaded) = roundtrip( roundtrip( mo_cont ) ).
    DATA(lo_app) = CAST ltcl_ser_app_rows( lo_loaded->mo_app ).

    cl_abap_unit_assert=>assert_equals( exp = `/LIF_SER_STATE~MV_STATE`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = REF #( lo_app->lif_ser_state~mv_state ) ) ).
    " an interface attribute the draft left out: the rebuild turns the
    " interface rows on again for the bound `~` row
    cl_abap_unit_assert=>assert_equals( exp = `/LIF_SER_STATE~MV_OTHER`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = REF #( lo_app->lif_ser_state~mv_other ) ) ).

    DATA(lv_json) = roundtrip( lo_loaded )->model_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `state` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `other` ) ).

  ENDMETHOD.

  METHOD dref_payload_unchanged.

    FIELD-SYMBOLS <elem> TYPE any.

    DATA(lo_loaded) = roundtrip( roundtrip( mo_cont ) ).
    DATA(lo_app) = CAST ltcl_ser_app_rows( lo_loaded->mo_app ).

    cl_abap_unit_assert=>assert_bound( lo_app->mr_elem ).
    ASSIGN lo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `payload`
                                        act = <elem> ).
    cl_abap_unit_assert=>assert_equals( exp = mo_app->mt_items
                                        act = lo_app->mt_items ).
    cl_abap_unit_assert=>assert_equals( exp = mo_app->ms_big
                                        act = lo_app->ms_big ).

  ENDMETHOD.

  METHOD sticky_live_table_kept.

    DATA(lr_live) = mo_cont->mt_attri.
    DATA(lv_rows) = lines( mo_cont->mt_attri->* ).

    NEW z2ui5_cl_ui5_serializer( )->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    " the live container goes on with its own table, every row in it and
    " the descriptors with them - only the draft is lean
    cl_abap_unit_assert=>assert_true( xsdbool( mo_cont->mt_attri = lr_live ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( mo_cont->mt_attri->* ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( mo_cont->mt_attri->*[ name = `MS_BIG-F01` ] ) ) ).
    cl_abap_unit_assert=>assert_bound( mo_cont->mt_attri->*[ name = `MV_NOTE` ]-o_typedescr ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_elem ).

    " ...and a failing transformation hands it back as well
    DATA(lo_failing) = NEW ltcl_ser_failing( ).
    lo_failing->mv_fail_count = 2.
    TRY.
        lo_failing->z2ui5_if_ui5_serializer~stringify( mo_cont ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( xsdbool( mo_cont->mt_attri = lr_live ) ).

  ENDMETHOD.

ENDCLASS.
