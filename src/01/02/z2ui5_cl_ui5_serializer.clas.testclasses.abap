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
    DATA temp1 TYPE REF TO cl_abap_structdescr.
    DATA lo_line LIKE temp1.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp2 TYPE abap_componentdescr.
    DATA temp3 TYPE REF TO cl_abap_datadescr.
    DATA lo_tab TYPE REF TO cl_abap_tabledescr.

    mv_text = `text`.


    temp1 ?= cl_abap_typedescr=>describe_by_data( ls_row ).

    lo_line = temp1.

    lt_comp = lo_line->get_components( ).

    CLEAR temp2.
    temp2-name = `RUNTIME_ONLY`.

    temp3 ?= cl_abap_datadescr=>describe_by_data( lv_flag ).
    temp2-type = temp3.
    INSERT temp2 INTO TABLE lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
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
    TYPES ty_t_item TYPE STANDARD TABLE OF ty_s_item WITH DEFAULT KEY.
    TYPES:
      BEGIN OF ty_s_head,
        id      TYPE string,
        amount  TYPE p LENGTH 10 DECIMALS 2,
        t_items TYPE ty_t_item,
      END OF ty_s_head.
    TYPES ty_t_head TYPE STANDARD TABLE OF ty_s_head WITH DEFAULT KEY.

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

    DATA temp3 TYPE ltcl_ser_app_deep=>ty_t_head.
    DATA temp4 LIKE LINE OF temp3.
    DATA temp6 TYPE ltcl_ser_app_deep=>ty_t_item.
    DATA temp7 LIKE LINE OF temp6.
    DATA temp8 TYPE ltcl_ser_app_deep=>ty_t_item.
    DATA temp5 TYPE string_table.
    CLEAR temp3.

    temp4-id = `H1`.
    temp4-amount = '12.50'.

    CLEAR temp6.

    temp7-pos = 1.
    temp7-txt = `first`.
    INSERT temp7 INTO TABLE temp6.
    temp7-pos = 2.
    temp7-txt = `second`.
    INSERT temp7 INTO TABLE temp6.
    temp4-t_items = temp6.
    INSERT temp4 INTO TABLE temp3.
    temp4-id = `H2`.
    temp4-amount = '-3.75'.

    CLEAR temp8.
    temp4-t_items = temp8.
    INSERT temp4 INTO TABLE temp3.
    mt_head = temp3.
    CREATE OBJECT mo_child.
    mo_child->mv_name = `child`.

    CLEAR temp5.
    INSERT `a` INTO TABLE temp5.
    INSERT `b` INTO TABLE temp5.
    mo_child->mt_tags = temp5.
    " CREATE DATA, not NEW #( `typed` ): the downport turns a NEW of a data
    " reference into a CREATE OBJECT that does not parse
    CREATE DATA mr_typed.
    mr_typed->* = `typed`.
    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `generic`.
    GET REFERENCE OF mt_head INTO mr_alias_tab.

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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

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

    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
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

    CREATE OBJECT mo_app.
    mo_app->fill( ).
    CREATE OBJECT mo_cont.
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
    DATA temp7 LIKE LINE OF mo_cont->mt_attri->*.
    DATA lr_attri LIKE REF TO temp7.

    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_tab
                                       msg = `the generic reference was not reattached` ).
    ASSIGN mo_app->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).


    LOOP AT mo_cont->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL OR srtti_type IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |a payload stayed on the live row { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD roundtrip_default.

    DATA lo_serializer TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lv_xml TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    DATA temp8 TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_parsed LIKE temp8.
    DATA temp9 TYPE REF TO ltcl_ser_app.
    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.


    lv_xml = lo_serializer->z2ui5_if_ui5_serializer~stringify( mo_cont ).


    temp1 = boolc( lv_xml CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp1 ).

    temp2 = boolc( lv_xml CS `text` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp2 ).
    check_reattached( ).


    temp8 ?= lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ).

    lo_parsed = temp8.
    cl_abap_unit_assert=>assert_equals( exp = mo_cont->ms_draft-id
                                        act = lo_parsed->ms_draft-id ).

    temp9 ?= lo_parsed->mo_app.
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = temp9->mv_text ).

  ENDMETHOD.

  METHOD failure_chains_first_cause.

    DATA lo_failing TYPE REF TO ltcl_ser_failing.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp3 TYPE xsdboolean.
        DATA lv_cause TYPE string.
        DATA temp4 TYPE xsdboolean.
        DATA temp5 TYPE xsdboolean.
    CREATE OBJECT lo_failing TYPE ltcl_ser_failing.
    lo_failing->mv_fail_count = 2.

    TRY.
        lo_failing->z2ui5_if_ui5_serializer~stringify( mo_cont ).
        cl_abap_unit_assert=>fail( `a container that cannot be serialized must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        temp3 = boolc( lx->get_text_own( ) CS `APP_SERIALIZATION_ERROR` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp3 ).
        " the first attempt's failure names the cause; the retry's is the
        " follow-up of the same root and must not replace it
        cl_abap_unit_assert=>assert_bound( act = lx->previous
                                           msg = `the serialization failure was not chained` ).

        lv_cause = lx->previous->get_text( ).

        temp4 = boolc( lv_cause CS `TRANSFORMATION_FAILURE_1` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp4 ).

        temp5 = boolc( lv_cause CS `TRANSFORMATION_FAILURE_2` ).
        cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp5 ).
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

    DATA lo_failing TYPE REF TO ltcl_ser_failing.
    DATA lv_xml TYPE string.
    DATA temp6 TYPE xsdboolean.
    CREATE OBJECT lo_failing TYPE ltcl_ser_failing.
    lo_failing->mv_fail_count = 1.


    lv_xml = lo_failing->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_failing->mv_calls ).

    temp6 = boolc( lv_xml CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp6 ).
    check_reattached( ).

  ENDMETHOD.

  METHOD load.

    " what z2ui5_cl_ui5_app_cont=>db_load does with the string: parse it,
    " then restore the attributes against the app the parse produced
    DATA temp10 TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA temp11 TYPE REF TO z2ui5_cl_ui5_srv_model.
    CREATE OBJECT temp10 TYPE z2ui5_cl_ui5_serializer.
    result ?= temp10->z2ui5_if_ui5_serializer~parse( iv_xml ).

    CREATE OBJECT temp11 TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = result->mt_attri app = result->mo_app.
    temp11->main_attri_db_load( ).

  ENDMETHOD.

  METHOD parse_empty_unbound.

    DATA lo_serializer TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lv_empty TYPE c LENGTH 10.
    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.

    cl_abap_unit_assert=>assert_not_bound( lo_serializer->z2ui5_if_ui5_serializer~parse( `` ) ).

    cl_abap_unit_assert=>assert_not_bound( lo_serializer->z2ui5_if_ui5_serializer~parse( lv_empty ) ).

  ENDMETHOD.

  METHOD roundtrip_restores_dref.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <col> TYPE any.

    DATA lv_xml TYPE string.
    DATA temp9 TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp12 TYPE REF TO ltcl_ser_app.
    DATA lo_app LIKE temp12.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    DATA temp13 LIKE LINE OF lo_loaded->mt_attri->*.
    DATA lr_attri LIKE REF TO temp13.
    CREATE OBJECT temp9 TYPE z2ui5_cl_ui5_serializer.
    lv_xml = temp9->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    lo_loaded = load( lv_xml ).


    temp12 ?= lo_loaded->mo_app.

    lo_app = temp12.

    temp7 = boolc( lo_app = mo_app ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false act = temp7
                                       msg = `the parse must build a new instance` ).
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_tab
                                       msg = `the generic reference did not come back` ).
    ASSIGN lo_app->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    READ TABLE <tab> INDEX 1 ASSIGNING <row>.

    temp8 = boolc( <row> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp8 ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `handle`
                                        act = <col> ).
    ASSIGN COMPONENT `RUNTIME_ONLY` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( msg = `the runtime-built line type lost its component` ).
    " the payload is consumed by the load, not carried on into the next save


    LOOP AT lo_loaded->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL OR srtti_type IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |a payload stayed on the loaded row { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD roundtrip_deep_app.

    FIELD-SYMBOLS <elem>  TYPE any.
    FIELD-SYMBOLS <alias> TYPE ltcl_ser_app_deep=>ty_t_head.

    DATA lo_deep TYPE REF TO ltcl_ser_app_deep.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lv_xml TYPE string.
    DATA temp10 TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA temp14 TYPE REF TO ltcl_ser_app_deep.
    DATA lo_app LIKE temp14.
    FIELD-SYMBOLS <temp15> LIKE LINE OF lo_app->mt_head.
    DATA temp16 LIKE sy-tabix.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lo_app->mt_head.
    DATA temp18 LIKE sy-tabix.
    DATA temp19 TYPE decfloat34.
    DATA temp11 TYPE decfloat34.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lo_app->mt_head.
    DATA temp2 LIKE sy-tabix.
    DATA temp20 TYPE ltcl_ser_app_deep=>ty_s_head.
    CREATE OBJECT lo_deep TYPE ltcl_ser_app_deep.
    lo_deep->fill( ).

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app      = lo_deep.
    lo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).



    CREATE OBJECT temp10 TYPE z2ui5_cl_ui5_serializer.
    lv_xml = temp10->z2ui5_if_ui5_serializer~stringify( lo_cont ).

    temp14 ?= load( lv_xml )->mo_app.

    lo_app = temp14.

    " the nested table, row by row, the empty inner table included
    cl_abap_unit_assert=>assert_equals( exp = lo_deep->mt_head
                                        act = lo_app->mt_head ).


    temp16 = sy-tabix.
    READ TABLE lo_app->mt_head INDEX 1 ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <temp15>-t_items ) ).


    temp18 = sy-tabix.
    READ TABLE lo_app->mt_head INDEX 2 ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp17>-t_items ).

    temp19 = '-3.75'.



    temp2 = sy-tabix.
    READ TABLE lo_app->mt_head INDEX 2 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    temp11 = <temp1>-amount.
    cl_abap_unit_assert=>assert_equals( exp = temp19
                                        act = temp11 ).
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

    CLEAR temp20.
    temp20-id = `H3`.
    INSERT temp20 INTO TABLE <alias>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_head ) ).

  ENDMETHOD.

  METHOD live_instance_untouched.

    DATA lo_deep TYPE REF TO ltcl_ser_app_deep.
    DATA lo_child LIKE lo_deep->mo_child.
    DATA lr_typed LIKE lo_deep->mr_typed.
    DATA lr_alias LIKE lo_deep->mr_alias_tab.
    DATA lt_head LIKE lo_deep->mt_head.
    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp21 TYPE REF TO z2ui5_cl_ui5_serializer.
    CREATE OBJECT lo_deep TYPE ltcl_ser_app_deep.
    lo_deep->fill( ).

    lo_child = lo_deep->mo_child.

    lr_typed = lo_deep->mr_typed.

    lr_alias = lo_deep->mr_alias_tab.

    lt_head = lo_deep->mt_head.

    CREATE OBJECT lo_cont TYPE z2ui5_cl_ui5_app_cont.
    lo_cont->mo_app = lo_deep.


    CREATE OBJECT temp21 TYPE z2ui5_cl_ui5_serializer.
    temp21->z2ui5_if_ui5_serializer~stringify( lo_cont ).

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

    DATA lo_app TYPE REF TO ltcl_ser_app_win.
    DATA temp22 TYPE ltcl_ser_app_win=>ty_t_row.
    DATA temp23 LIKE LINE OF temp22.
    DATA temp24 TYPE REF TO z2ui5_cl_ui5_srv_model.
    FIELD-SYMBOLS <attri> TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp9 TYPE xsdboolean.
    DATA lr_attri LIKE REF TO <attri>.
    CREATE OBJECT lo_app TYPE ltcl_ser_app_win.
    lo_app->mv_text = `text`.

    CLEAR temp22.

    temp23-id = 1.
    temp23-name = `first`.
    INSERT temp23 INTO TABLE temp22.
    temp23-id = 2.
    temp23-name = `second`.
    INSERT temp23 INTO TABLE temp22.
    temp23-id = 3.
    temp23-name = `third`.
    INSERT temp23 INTO TABLE temp22.
    lo_app->mt_rows = temp22.
    CREATE OBJECT result.
    result->mo_app      = lo_app.
    result->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    " the rows of the attributes, and MT_ROWS made a window - what
    " window_bind_tab( ) leaves on the row

    CREATE OBJECT temp24 TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = result->mt_attri app = result->mo_app.
    temp24->main_attri_refresh( ).

    READ TABLE result->mt_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <attri>.

    temp9 = boolc( <attri> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp9
                                      msg = `no row for MT_ROWS` ).

    GET REFERENCE OF <attri> INTO lr_attri.
    lr_attri->bind         = abap_true.
    lr_attri->window_size  = 2.
    lr_attri->window_total = 5000.
    lr_attri->window_event = `ROWS`.

  ENDMETHOD.

  METHOD window_roundtrip.

    DATA lo_cont TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp25 TYPE REF TO ltcl_ser_app_win.
    DATA lo_app LIKE temp25.
    DATA lo_serializer TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lv_xml TYPE string.
    DATA temp26 TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_parsed LIKE temp26.
    DATA temp27 TYPE REF TO ltcl_ser_app_win.
    DATA lo_back LIKE temp27.
    FIELD-SYMBOLS <attri> TYPE z2ui5_if_ui5_types=>ty_s_attri.
    DATA temp10 TYPE xsdboolean.
    lo_cont = win_cont( ).

    temp25 ?= lo_cont->mo_app.

    lo_app = temp25.

    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.


    lv_xml = lo_serializer->z2ui5_if_ui5_serializer~stringify( lo_cont ).

    " the live instance goes on with its rows
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_rows ) ).


    temp26 ?= lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ).

    lo_parsed = temp26.

    temp27 ?= lo_parsed->mo_app.

    lo_back = temp27.
    cl_abap_unit_assert=>assert_equals( exp = lo_app->mt_rows
                                        act = lo_back->mt_rows ).
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_back->mv_text ).

    READ TABLE lo_parsed->mt_attri->* WITH KEY name = `MT_ROWS` ASSIGNING <attri>.

    temp10 = boolc( <attri> IS ASSIGNED ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp10
                                      msg = `no row for MT_ROWS after the parse` ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = <attri>-window_size ).
    cl_abap_unit_assert=>assert_equals( exp = 5000
                                        act = <attri>-window_total ).
    cl_abap_unit_assert=>assert_equals( exp = `ROWS`
                                        act = <attri>-window_event ).

  ENDMETHOD.

  METHOD set_serializer_honoured.

    DATA temp28 TYPE REF TO ltcl_ser_double.
    DATA lo_parsed TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA li_none TYPE REF TO z2ui5_if_ui5_serializer.
    DATA temp11 TYPE xsdboolean.
    CREATE OBJECT temp28 TYPE ltcl_ser_double.
    z2ui5_cl_ui5_app_cont=>set_serializer( temp28 ).

    cl_abap_unit_assert=>assert_equals( exp = `DOUBLE`
                                        act = mo_cont->all_xml_stringify( ) ).

    lo_parsed = z2ui5_cl_ui5_app_cont=>all_xml_parse( `FROM_DOUBLE` ).
    cl_abap_unit_assert=>assert_equals( exp = `FROM_DOUBLE`
                                        act = lo_parsed->ms_draft-id ).
    " the double did not touch the live instance
    cl_abap_unit_assert=>assert_bound( mo_app->mr_tab ).

    " an unbound reference restores the shipped serializer

    z2ui5_cl_ui5_app_cont=>set_serializer( li_none ).
    cl_abap_unit_assert=>assert_equals(
        exp = `Z2UI5_CL_UI5_SERIALIZER`
        act = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( z2ui5_cl_ui5_app_cont=>get_serializer( ) ) ).

    temp11 = boolc( mo_cont->all_xml_stringify( ) CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp11 ).

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
    TYPES ty_t_item TYPE STANDARD TABLE OF ty_s_item WITH DEFAULT KEY.

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
    DATA temp29 TYPE ltcl_ser_app_rows=>ty_t_item.
    DATA temp30 LIKE LINE OF temp29.

    mv_name  = `name`.
    mv_note  = `note`.
    mv_total = 500.
    ms_big-f01 = `big`.
    ms_big-f05 = 5.
    ms_big2-f03 = `big2`.

    CLEAR temp29.

    temp30-id = 1.
    temp30-txt = `one`.
    INSERT temp30 INTO TABLE temp29.
    temp30-id = 2.
    temp30-txt = `two`.
    INSERT temp30 INTO TABLE temp29.
    mt_items = temp29.
    GET REFERENCE OF mt_items INTO mr_alias.
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

    CREATE OBJECT mo_app.
    mo_app->fill( ).
    CREATE OBJECT mo_cont.
    mo_cont->mo_app      = mo_app.
    mo_cont->ms_draft-id = z2ui5_cl_ui5_util_context=>uuid_get_c32( ).
    bind_view( mo_cont ).

  ENDMETHOD.

  METHOD bind.

    DATA ls_config LIKE is_config.
    DATA temp31 TYPE REF TO z2ui5_cl_ui5_srv_bind.
    ls_config = is_config.
    ls_config-path_only = abap_true.

    CREATE OBJECT temp31 TYPE z2ui5_cl_ui5_srv_bind EXPORTING APP = io_cont.
    result = temp31->main( val    = ir_val
                                                         config = ls_config ).

  ENDMETHOD.

  METHOD bind_view.

    FIELD-SYMBOLS <elem> TYPE any.

    DATA temp32 TYPE REF TO ltcl_ser_app_rows.
    DATA lo_app LIKE temp32.
    DATA temp33 LIKE REF TO lo_app->mv_name.
    DATA temp34 LIKE REF TO lo_app->mv_total.
DATA temp12 LIKE REF TO lo_app->mt_items.
DATA temp3 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    DATA temp35 LIKE REF TO lo_app->lif_ser_state~mv_state.
    DATA temp36 TYPE REF TO data.
    temp32 ?= io_cont->mo_app.

    lo_app = temp32.

    GET REFERENCE OF lo_app->mv_name INTO temp33.
bind( io_cont = io_cont
          ir_val  = temp33 ).

    GET REFERENCE OF lo_app->mv_total INTO temp34.

GET REFERENCE OF lo_app->mt_items INTO temp12.

CLEAR temp3.
temp3-window = 10.
temp3-window_total = lo_app->mv_total.
temp3-window_total_ref = temp34.
temp3-window_event = `ROWS`.
bind( io_cont   = io_cont
          ir_val    = temp12
          is_config = temp3 ).

    GET REFERENCE OF lo_app->lif_ser_state~mv_state INTO temp35.
bind( io_cont = io_cont
          ir_val  = temp35 ).
    ASSIGN lo_app->mr_elem->* TO <elem>.

GET REFERENCE OF <elem> INTO temp36.
bind( io_cont = io_cont
          ir_val  = temp36 ).

  ENDMETHOD.

  METHOD roundtrip.

    DATA lo_serializer TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lv_xml TYPE string.
    DATA temp37 TYPE REF TO z2ui5_cl_ui5_srv_model.
    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.

    lv_xml = lo_serializer->z2ui5_if_ui5_serializer~stringify( io_cont ).
    result ?= lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ).

    CREATE OBJECT temp37 TYPE z2ui5_cl_ui5_srv_model EXPORTING attri = result->mt_attri app = result->mo_app.
    temp37->main_attri_db_load( ).

  ENDMETHOD.

  METHOD stored_names.

    DATA temp38 LIKE LINE OF io_cont->mt_attri->*.
    DATA lr_attri LIKE REF TO temp38.
    LOOP AT io_cont->mt_attri->* REFERENCE INTO lr_attri.
      INSERT lr_attri->name INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD stored_rows_lean.

    DATA lv_live TYPE i.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp39 TYPE string_table.
    DATA temp12 TYPE xsdboolean.
    lv_live = lines( mo_cont->mt_attri->* ).

    lo_loaded = roundtrip( mo_cont ).

    " forty rows of components and the interface rows nobody binds stay
    " out; what stays is bound, owns or aliases data, sits below a data
    " reference or is the total of a window

    CLEAR temp39.
    INSERT `LIF_SER_STATE~MV_STATE` INTO TABLE temp39.
    INSERT `MR_ALIAS` INTO TABLE temp39.
    INSERT `MR_ALIAS->*` INTO TABLE temp39.
    INSERT `MR_ELEM` INTO TABLE temp39.
    INSERT `MR_ELEM->*` INTO TABLE temp39.
    INSERT `MS_BIG` INTO TABLE temp39.
    INSERT `MS_BIG2` INTO TABLE temp39.
    INSERT `MT_ITEMS` INTO TABLE temp39.
    INSERT `MV_NAME` INTO TABLE temp39.
    INSERT `MV_TOTAL` INTO TABLE temp39.
    cl_abap_unit_assert=>assert_equals(
        exp = temp39
        act = stored_names( lo_loaded ) ).

    temp12 = boolc( lv_live > 50 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp12 ).

  ENDMETHOD.

  METHOD no_type_descriptor_stored.

    DATA lo_serializer TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lv_xml TYPE string.
    DATA temp13 TYPE xsdboolean.
    DATA temp41 TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_parsed LIKE temp41.
    DATA temp42 LIKE LINE OF lo_parsed->mt_attri->*.
    DATA lr_attri LIKE REF TO temp42.
    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.

    lv_xml = lo_serializer->z2ui5_if_ui5_serializer~stringify( mo_cont ).


    temp13 = boolc( lv_xml NS `CL_ABAP_` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp13
                                      msg = `a type descriptor went into the draft` ).

    temp41 ?= lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ).

    lo_parsed = temp41.


    LOOP AT lo_parsed->mt_attri->* REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE o_typedescr IS BOUND.
      cl_abap_unit_assert=>fail( |the row { lr_attri->name } came back with a descriptor| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD model_json_identical.

    DATA lv_before TYPE string.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    lv_before = mo_cont->model_json_stringify( ).

    lo_loaded = roundtrip( mo_cont ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_loaded->model_json_stringify( ) ).

    temp14 = boolc( lv_before CS `payload` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp14 ).

    temp15 = boolc( lv_before CS `state` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp15 ).

  ENDMETHOD.

  METHOD alias_identity_kept.

    FIELD-SYMBOLS <alias> TYPE ltcl_ser_app_rows=>ty_t_item.

    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp43 TYPE REF TO ltcl_ser_app_rows.
    DATA lo_app LIKE temp43.
    DATA temp44 TYPE ltcl_ser_app_rows=>ty_s_item.
    FIELD-SYMBOLS <temp45> LIKE LINE OF lo_loaded->mt_attri->*.
    DATA temp46 LIKE sy-tabix.
    lo_loaded = roundtrip( roundtrip( mo_cont ) ).

    temp43 ?= lo_loaded->mo_app.

    lo_app = temp43.

    " the reference points at the restored table, not at a copy of it
    ASSIGN lo_app->mr_alias->* TO <alias>.
    cl_abap_unit_assert=>assert_subrc( ).

    CLEAR temp44.
    temp44-id = 3.
    INSERT temp44 INTO TABLE <alias>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_app->mt_items ) ).


    temp46 = sy-tabix.
    READ TABLE lo_loaded->mt_attri->* WITH KEY name = `MR_ALIAS->*` ASSIGNING <temp45>.
    sy-tabix = temp46.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MT_ITEMS`
                                        act = <temp45>-name_ref ).

  ENDMETHOD.

  METHOD draft_stable.

    " a draft restored and written again does not grow - nothing the
    " left-out rows held comes back as a copy of an alias. The length, not
    " the text: the payload names the anonymous type of the restored data
    " object, which the runtime numbers anew
    DATA lo_serializer TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lv_first TYPE string.
    DATA lo_again TYPE REF TO z2ui5_cl_ui5_app_cont.
    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.

    lo_loaded = roundtrip( mo_cont ).

    lv_first = lo_serializer->z2ui5_if_ui5_serializer~stringify( lo_loaded ).

    lo_again = roundtrip( lo_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = strlen( lv_first )
                                        act = strlen( lo_serializer->z2ui5_if_ui5_serializer~stringify( lo_again ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = stored_names( lo_loaded )
                                        act = stored_names( lo_again ) ).

  ENDMETHOD.

  METHOD rebind_without_rebuild.

    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lv_rows TYPE i.
    lo_loaded = roundtrip( mo_cont ).

    lv_rows = lines( lo_loaded->mt_attri->* ).

    " the next render binds the same view: every row is in the draft, the
    " search answers without rebuilding the table
    bind_view( lo_loaded ).

    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( lo_loaded->mt_attri->* ) ).

  ENDMETHOD.

  METHOD bind_new_rebuilds.

    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp47 TYPE REF TO ltcl_ser_app_rows.
    DATA lo_app LIKE temp47.
    DATA lv_rows TYPE i.
    DATA temp48 LIKE REF TO lo_app->mv_note.
    DATA temp16 TYPE xsdboolean.
    DATA temp49 LIKE REF TO lo_app->ms_big-f05.
    FIELD-SYMBOLS <temp50> LIKE LINE OF lo_loaded->mt_attri->*.
    DATA temp51 LIKE sy-tabix.
    FIELD-SYMBOLS <temp52> LIKE LINE OF lo_loaded->mt_attri->*.
    DATA temp53 LIKE sy-tabix.
    DATA lv_json TYPE string.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    lo_loaded = roundtrip( mo_cont ).

    temp47 ?= lo_loaded->mo_app.

    lo_app = temp47.

    lv_rows = lines( lo_loaded->mt_attri->* ).

    " left out of the draft - found by the rebuild

    GET REFERENCE OF lo_app->mv_note INTO temp48.
cl_abap_unit_assert=>assert_equals( exp = `/MV_NOTE`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = temp48 ) ).

    temp16 = boolc( lines( lo_loaded->mt_attri->* ) > lv_rows ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp16 ).

    GET REFERENCE OF lo_app->ms_big-f05 INTO temp49.
cl_abap_unit_assert=>assert_equals( exp = `/MS_BIG/F05`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = temp49 ) ).
    " the rebuild kept what was bound


    temp51 = sy-tabix.
    READ TABLE lo_loaded->mt_attri->* WITH KEY name = `MV_NAME` ASSIGNING <temp50>.
    sy-tabix = temp51.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = <temp50>-bind ).


    temp53 = sy-tabix.
    READ TABLE lo_loaded->mt_attri->* WITH KEY name = `MT_ITEMS` ASSIGNING <temp52>.
    sy-tabix = temp53.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_TOTAL`
                                        act = <temp52>-window_total_name ).


    lv_json = roundtrip( lo_loaded )->model_json_stringify( ).

    temp17 = boolc( lv_json CS `note` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp17 ).

    temp18 = boolc( lv_json CS `"F05":5` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp18 ).

  ENDMETHOD.

  METHOD window_total_kept.

    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp54 TYPE REF TO ltcl_ser_app_rows.
    DATA lo_app LIKE temp54.
    DATA lv_rows TYPE i.
    DATA temp55 LIKE REF TO lo_app->mv_total.
DATA temp13 LIKE REF TO lo_app->mt_items.
DATA temp4 TYPE z2ui5_if_ui5_types=>ty_s_bind_config.
    FIELD-SYMBOLS <temp56> LIKE LINE OF lo_loaded->mt_attri->*.
    DATA temp57 LIKE sy-tabix.
    lo_loaded = roundtrip( mo_cont ).

    temp54 ?= lo_loaded->mo_app.

    lo_app = temp54.

    lv_rows = lines( lo_loaded->mt_attri->* ).

    " window_adopt asks for the total without a rebuild (main_attri_find):
    " its row has to be in the draft, or the total froze at this render

    GET REFERENCE OF lo_app->mv_total INTO temp55.

GET REFERENCE OF lo_app->mt_items INTO temp13.

CLEAR temp4.
temp4-window = 10.
temp4-window_total = lo_app->mv_total.
temp4-window_total_ref = temp55.
temp4-window_event = `ROWS`.
bind( io_cont   = lo_loaded
          ir_val    = temp13
          is_config = temp4 ).



    temp57 = sy-tabix.
    READ TABLE lo_loaded->mt_attri->* WITH KEY name = `MT_ITEMS` ASSIGNING <temp56>.
    sy-tabix = temp57.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `MV_TOTAL`
                                        act = <temp56>-window_total_name ).
    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( lo_loaded->mt_attri->* ) ).

  ENDMETHOD.

  METHOD intf_binding_roundtrips.

    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp58 TYPE REF TO ltcl_ser_app_rows.
    DATA lo_app LIKE temp58.
    DATA temp59 LIKE REF TO lo_app->lif_ser_state~mv_state.
    DATA temp60 LIKE REF TO lo_app->lif_ser_state~mv_other.
    DATA lv_json TYPE string.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    lo_loaded = roundtrip( roundtrip( mo_cont ) ).

    temp58 ?= lo_loaded->mo_app.

    lo_app = temp58.


    GET REFERENCE OF lo_app->lif_ser_state~mv_state INTO temp59.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_SER_STATE~MV_STATE`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = temp59 ) ).
    " an interface attribute the draft left out: the rebuild turns the
    " interface rows on again for the bound `~` row

    GET REFERENCE OF lo_app->lif_ser_state~mv_other INTO temp60.
cl_abap_unit_assert=>assert_equals( exp = `/LIF_SER_STATE~MV_OTHER`
                                        act = bind( io_cont = lo_loaded
                                                    ir_val  = temp60 ) ).


    lv_json = roundtrip( lo_loaded )->model_json_stringify( ).

    temp19 = boolc( lv_json CS `state` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp19 ).

    temp20 = boolc( lv_json CS `other` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp20 ).

  ENDMETHOD.

  METHOD dref_payload_unchanged.

    FIELD-SYMBOLS <elem> TYPE any.

    DATA lo_loaded TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA temp61 TYPE REF TO ltcl_ser_app_rows.
    DATA lo_app LIKE temp61.
    lo_loaded = roundtrip( roundtrip( mo_cont ) ).

    temp61 ?= lo_loaded->mo_app.

    lo_app = temp61.

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

    DATA lr_live LIKE mo_cont->mt_attri.
    DATA lv_rows TYPE i.
    DATA temp62 TYPE REF TO z2ui5_cl_ui5_serializer.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    DATA temp1 LIKE sy-subrc.
    DATA temp2 LIKE sy-subrc.
    DATA temp3 LIKE sy-tabix.
    FIELD-SYMBOLS <temp63> LIKE LINE OF mo_cont->mt_attri->*.
    DATA temp64 LIKE sy-tabix.
    DATA lo_failing TYPE REF TO ltcl_ser_failing.
    DATA temp23 TYPE xsdboolean.
    lr_live = mo_cont->mt_attri.

    lv_rows = lines( mo_cont->mt_attri->* ).


    CREATE OBJECT temp62 TYPE z2ui5_cl_ui5_serializer.
    temp62->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    " the live container goes on with its own table, every row in it and
    " the descriptors with them - only the draft is lean

    temp21 = boolc( mo_cont->mt_attri = lr_live ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp21 ).
    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( mo_cont->mt_attri->* ) ).




    temp2 = sy-subrc.
    temp3 = sy-tabix.
    READ TABLE mo_cont->mt_attri->* WITH KEY name = `MS_BIG-F01` TRANSPORTING NO FIELDS.
    temp1 = sy-subrc.
    sy-subrc = temp2.
    sy-tabix = temp3.
    temp22 = boolc( temp1 = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp22 ).


    temp64 = sy-tabix.
    READ TABLE mo_cont->mt_attri->* WITH KEY name = `MV_NOTE` ASSIGNING <temp63>.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_bound( <temp63>-o_typedescr ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_elem ).

    " ...and a failing transformation hands it back as well

    CREATE OBJECT lo_failing TYPE ltcl_ser_failing.
    lo_failing->mv_fail_count = 2.
    TRY.
        lo_failing->z2ui5_if_ui5_serializer~stringify( mo_cont ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

    temp23 = boolc( mo_cont->mt_attri = lr_live ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = temp23 ).

  ENDMETHOD.

ENDCLASS.
