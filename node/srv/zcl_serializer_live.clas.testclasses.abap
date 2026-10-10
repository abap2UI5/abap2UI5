CLASS ltcl_app DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mv_value TYPE string.

ENDCLASS.


CLASS ltcl_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_serializer TYPE REF TO z2ui5_if_ui5_serializer.

    METHODS setup.
    METHODS teardown.

    " a container with an app and a value
    METHODS container
      IMPORTING
        iv_value      TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_cont.

    " parse( stringify( container ) ) answers the SAME container, with its
    " app and its state - the identity is the whole point
    METHODS test_roundtrip_identity   FOR TESTING RAISING cx_static_check.
    " every stringify hands out an id of its own, also for the same object
    METHODS test_id_per_stringify     FOR TESTING RAISING cx_static_check.
    " an empty input is a first roundtrip - unbound, like the shipped one
    METHODS test_parse_empty          FOR TESTING RAISING cx_static_check.
    " an unknown id is a missing draft, with the draft store's error text
    METHODS test_parse_unknown        FOR TESTING RAISING cx_static_check.
    " an unbound container is refused rather than kept as an empty draft
    METHODS test_stringify_unbound    FOR TESTING RAISING cx_static_check.
    " sweep drops what is older than the exit's expiry and keeps the rest
    METHODS test_sweep_expiry         FOR TESTING RAISING cx_static_check.
    " installed through the seam, the container goes through this class
    METHODS test_through_the_seam     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    zcl_serializer_live=>clear( ).
    mo_serializer = NEW zcl_serializer_live( ).

  ENDMETHOD.

  METHOD teardown.

    zcl_serializer_live=>clear( ).
    z2ui5_cl_ui5_app_cont=>set_serializer( VALUE #( ) ).

  ENDMETHOD.

  METHOD container.

    DATA(lo_app) = NEW ltcl_app( ).
    lo_app->mv_value = iv_value.
    result = NEW #( ).
    result->mo_app = lo_app.
    result->ms_draft-id = `DRAFT-` && iv_value.

  ENDMETHOD.

  METHOD test_roundtrip_identity.

    DATA(lo_cont) = container( `one` ).
    DATA(lv_id) = mo_serializer->stringify( lo_cont ).

    cl_abap_unit_assert=>assert_not_initial( lv_id ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = zcl_serializer_live=>count_entries( ) ).

    DATA lo_back TYPE REF TO z2ui5_cl_ui5_app_cont.
    lo_back ?= mo_serializer->parse( lv_id ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back = lo_cont ) ).
    cl_abap_unit_assert=>assert_equals( exp = `one`
                                        act = CAST ltcl_app( lo_back->mo_app )->mv_value ).
    cl_abap_unit_assert=>assert_equals( exp = `DRAFT-one`
                                        act = lo_back->ms_draft-id ).

    " ... and as often as asked - the id is not consumed by a parse
    lo_back ?= mo_serializer->parse( lv_id ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back = lo_cont ) ).

  ENDMETHOD.

  METHOD test_id_per_stringify.

    DATA(lo_cont) = container( `one` ).
    DATA(lv_first)  = mo_serializer->stringify( lo_cont ).
    DATA(lv_second) = mo_serializer->stringify( lo_cont ).

    cl_abap_unit_assert=>assert_differs( exp = lv_first
                                         act = lv_second ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = zcl_serializer_live=>count_entries( ) ).
    " both ids name the one object - the state it HAS, not a copy
    DATA lo_app TYPE REF TO ltcl_app.
    lo_app ?= lo_cont->mo_app.
    lo_app->mv_value = `changed`.
    DATA lo_back TYPE REF TO z2ui5_cl_ui5_app_cont.
    lo_back ?= mo_serializer->parse( lv_first ).
    cl_abap_unit_assert=>assert_equals( exp = `changed`
                                        act = CAST ltcl_app( lo_back->mo_app )->mv_value ).

  ENDMETHOD.

  METHOD test_parse_empty.

    cl_abap_unit_assert=>assert_not_bound( mo_serializer->parse( `` ) ).

  ENDMETHOD.

  METHOD test_parse_unknown.

    TRY.
        mo_serializer->parse( `NOT-A-KNOWN-ID` ).
        cl_abap_unit_assert=>fail( `an unknown id must answer like a missing draft row` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `NO_DRAFT_ENTRY_OF_PREVIOUS_REQUEST_FOUND` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_stringify_unbound.

    DATA lo_none TYPE REF TO object.
    TRY.
        mo_serializer->stringify( lo_none ).
        cl_abap_unit_assert=>fail( `an unbound container must be refused` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = zcl_serializer_live=>count_entries( ) ).

  ENDMETHOD.

  METHOD test_sweep_expiry.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.
    z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).

    DATA(lv_id) = mo_serializer->stringify( container( `one` ) ).

    " a clock one hour before the expiry: nothing goes
    DATA(lv_now) = z2ui5_cl_ui5_util_context=>time_get_timestampl( ).
    DATA(lv_later) = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                         time    = lv_now
                         seconds = ( ls_config-draft_exp_time_in_hours - 1 ) * 3600 * -1 ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = zcl_serializer_live=>sweep( lv_later ) ).
    cl_abap_unit_assert=>assert_bound( mo_serializer->parse( lv_id ) ).

    " a clock one hour past the expiry: the entry goes, and the id is a
    " missing draft from then on
    lv_later = z2ui5_cl_ui5_util_context=>time_subtract_seconds(
                   time    = lv_now
                   seconds = ( ls_config-draft_exp_time_in_hours + 1 ) * 3600 * -1 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = zcl_serializer_live=>sweep( lv_later ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = zcl_serializer_live=>count_entries( ) ).
    TRY.
        mo_serializer->parse( lv_id ).
        cl_abap_unit_assert=>fail( `a swept id must answer like a missing draft row` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD test_through_the_seam.

    z2ui5_cl_ui5_app_cont=>set_serializer( mo_serializer ).

    DATA(lo_cont) = container( `seam` ).
    DATA(lv_id) = lo_cont->all_xml_stringify( ).

    " no asXML - an id, and the one object behind it
    cl_abap_unit_assert=>assert_false( xsdbool( lv_id CS `<` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = zcl_serializer_live=>count_entries( ) ).
    DATA(lo_back) = z2ui5_cl_ui5_app_cont=>all_xml_parse( lv_id ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_back = lo_cont ) ).

  ENDMETHOD.

ENDCLASS.
