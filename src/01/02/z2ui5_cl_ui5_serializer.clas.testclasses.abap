" ---------------------------------------------------------------------------
" The shipped serializer: the asXML round trip with the S-RTTI detach of the
" generic references, the one retry after main_attri_refresh, the reattach
" on every path out, and the chain of the FIRST failure. Plus the seam it
" implements: set_serializer( ) on the container is honoured by both
" directions.
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
    APPEND temp2 TO lt_comp.

    lo_tab = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mr_tab TYPE HANDLE lo_tab.
    ASSIGN mr_tab->* TO <tab>.
    ls_row-col1 = `handle`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
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
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = boolc( lv_xml CS `text` ).
    cl_abap_unit_assert=>assert_true( temp2 ).
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
        cl_abap_unit_assert=>assert_true( temp3 ).
        " the first attempt's failure names the cause; the retry's is the
        " follow-up of the same root and must not replace it
        cl_abap_unit_assert=>assert_bound( act = lx->previous
                                           msg = `the serialization failure was not chained` ).

        lv_cause = lx->previous->get_text( ).

        temp4 = boolc( lv_cause CS `TRANSFORMATION_FAILURE_1` ).
        cl_abap_unit_assert=>assert_true( temp4 ).

        temp5 = boolc( lv_cause CS `TRANSFORMATION_FAILURE_2` ).
        cl_abap_unit_assert=>assert_false( temp5 ).
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
    cl_abap_unit_assert=>assert_true( temp6 ).
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
    DATA temp13 LIKE LINE OF lo_loaded->mt_attri->*.
    DATA lr_attri LIKE REF TO temp13.
    CREATE OBJECT temp9 TYPE z2ui5_cl_ui5_serializer.
    lv_xml = temp9->z2ui5_if_ui5_serializer~stringify( mo_cont ).

    lo_loaded = load( lv_xml ).


    temp12 ?= lo_loaded->mo_app.

    lo_app = temp12.

    temp7 = boolc( lo_app = mo_app ).
    cl_abap_unit_assert=>assert_false( act = temp7
                                       msg = `the parse must build a new instance` ).
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_tab
                                       msg = `the generic reference did not come back` ).
    ASSIGN lo_app->mr_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    READ TABLE <tab> INDEX 1 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).
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
    APPEND temp20 TO <alias>.
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

  METHOD set_serializer_honoured.

    DATA temp22 TYPE REF TO ltcl_ser_double.
    DATA lo_parsed TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA li_none TYPE REF TO z2ui5_if_ui5_serializer.
    DATA temp8 TYPE xsdboolean.
    CREATE OBJECT temp22 TYPE ltcl_ser_double.
    z2ui5_cl_ui5_app_cont=>set_serializer( temp22 ).

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

    temp8 = boolc( mo_cont->all_xml_stringify( ) CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

  ENDMETHOD.

ENDCLASS.
