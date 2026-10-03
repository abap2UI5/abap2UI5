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
    DATA temp3 LIKE LINE OF mo_cont->mt_attri->*.
    DATA lr_attri LIKE REF TO temp3.

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
    DATA temp4 TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA lo_parsed LIKE temp4.
    DATA temp5 TYPE REF TO ltcl_ser_app.
    CREATE OBJECT lo_serializer TYPE z2ui5_cl_ui5_serializer.


    lv_xml = lo_serializer->z2ui5_if_ui5_serializer~stringify( mo_cont ).


    temp1 = boolc( lv_xml CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = boolc( lv_xml CS `text` ).
    cl_abap_unit_assert=>assert_true( temp2 ).
    check_reattached( ).


    temp4 ?= lo_serializer->z2ui5_if_ui5_serializer~parse( lv_xml ).

    lo_parsed = temp4.
    cl_abap_unit_assert=>assert_equals( exp = mo_cont->ms_draft-id
                                        act = lo_parsed->ms_draft-id ).

    temp5 ?= lo_parsed->mo_app.
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = temp5->mv_text ).

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

  METHOD set_serializer_honoured.

    DATA temp6 TYPE REF TO ltcl_ser_double.
    DATA lo_parsed TYPE REF TO z2ui5_cl_ui5_app_cont.
    DATA li_none TYPE REF TO z2ui5_if_ui5_serializer.
    DATA temp7 TYPE xsdboolean.
    CREATE OBJECT temp6 TYPE ltcl_ser_double.
    z2ui5_cl_ui5_app_cont=>set_serializer( temp6 ).

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

    temp7 = boolc( mo_cont->all_xml_stringify( ) CS `<asx:abap` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

ENDCLASS.
