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

    mv_text = `text`.

    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_row ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    APPEND VALUE #( name = `RUNTIME_ONLY`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_flag ) ) ) TO lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
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
    " an IF, not xsdbool( a = b ): with two plain names that parses as a
    " call with a named parameter in the downported tree
    IF lo_app = mo_app.
      cl_abap_unit_assert=>fail( `the parse must build a new instance` ).
    ENDIF.
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
    APPEND VALUE #( id = `H3` ) TO <alias>.
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
