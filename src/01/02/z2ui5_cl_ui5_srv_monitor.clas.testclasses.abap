" The statics the latch lives in are PRIVATE - the switch, the lookup and
" the fail-open are what the tests below assert on, so the test class needs
" friendship (checked by npm run check_visibility; the transpiler and the
" unit runner would let the access through unnoticed).
CLASS ltcl_test DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_monitor DEFINITION LOCAL FRIENDS ltcl_test.

" a monitor that does nothing - what the lookup could have found
CLASS ltcl_monitor_noop DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_monitor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_monitor_noop IMPLEMENTATION.

  METHOD z2ui5_if_ui5_monitor~on_roundtrip.
    " records nothing - the tests only ask which instance is installed
  ENDMETHOD.

ENDCLASS.


" An exit that decides the monitor switch - what check_switched_on( ) asks
" on every call. The flag is class-wide so a test can flip it between two
" get_monitor( ) calls on the same installed instance.
CLASS ltcl_exit_switch DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_exit.
    CLASS-DATA gv_active TYPE abap_bool.
    CLASS-DATA gv_raise  TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_exit_switch IMPLEMENTATION.

  METHOD z2ui5_if_ui5_exit~set_config_http_get.
    " the GET side is not the monitor's business
  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_post.
    IF gv_raise = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `the exit raised`.
    ENDIF.
    cs_config-check_monitor_active = gv_active.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " whatever monitor the SYSTEM has installed, parked for the test's
    " duration and put back in teardown - the latch is class-wide
    DATA mi_installed TYPE REF TO z2ui5_if_ui5_monitor.

    METHODS setup.
    METHODS teardown.

    METHODS installed_monitor_answers FOR TESTING RAISING cx_static_check.
    METHODS latched_per_roll_area     FOR TESTING RAISING cx_static_check.
    METHODS switch_off_answers_nothing FOR TESTING RAISING cx_static_check.
    METHODS switch_asked_on_every_call FOR TESTING RAISING cx_static_check.
    METHODS switch_raising_is_off      FOR TESTING RAISING cx_static_check.
    METHODS installed_skips_the_switch FOR TESTING RAISING cx_static_check.
    METHODS lookup_answer_is_latched   FOR TESTING RAISING cx_static_check.
    METHODS unbound_resets_the_latch   FOR TESTING RAISING cx_static_check.
    METHODS lookup_names_a_class       FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mi_installed = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).
    ltcl_exit_switch=>gv_active = abap_false.
    ltcl_exit_switch=>gv_raise  = abap_false.

  ENDMETHOD.

  METHOD teardown.
    DATA temp1 TYPE REF TO z2ui5_if_ui5_exit.

    z2ui5_cl_ui5_srv_monitor=>set_monitor( mi_installed ).
    " the exit double goes, the lookup decides again - the same reset
    " z2ui5_cl_ui5_user_exit's own tests use

    CLEAR temp1.
    z2ui5_cl_ui5_user_exit=>set_instance( temp1 ).

  ENDMETHOD.

  METHOD installed_monitor_answers.

    DATA lo_monitor TYPE REF TO ltcl_monitor_noop.
    DATA temp1 TYPE xsdboolean.
    CREATE OBJECT lo_monitor TYPE ltcl_monitor_noop.

    z2ui5_cl_ui5_srv_monitor=>set_monitor( lo_monitor ).


    temp1 = boolc( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) = lo_monitor ).
    cl_abap_unit_assert=>assert_true(
        temp1 ).

  ENDMETHOD.

  METHOD latched_per_roll_area.

    " asked twice, answered with the same instance - the lookup and the
    " instantiation run once per roll area, not per call (whatever the
    " system has installed, the answer must not change between the two)
    DATA li_first TYPE REF TO z2ui5_if_ui5_monitor.
    DATA li_second TYPE REF TO z2ui5_if_ui5_monitor.
    DATA temp3 TYPE xsdboolean.
    DATA lo_double TYPE REF TO ltcl_monitor_noop.
    DATA temp2 TYPE REF TO z2ui5_if_ui5_monitor.
    DATA temp4 TYPE xsdboolean.
    li_first  = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).

    li_second = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).


    temp3 = boolc( li_first = li_second ).
    cl_abap_unit_assert=>assert_true( temp3 ).

    " an unbound reference restores the lookup: the installed double is gone
    " again, whatever the system answers in its place

    CREATE OBJECT lo_double TYPE ltcl_monitor_noop.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( lo_double ).

    CLEAR temp2.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp2 ).

    temp4 = boolc( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) = lo_double ).
    cl_abap_unit_assert=>assert_false( temp4 ).

  ENDMETHOD.

  METHOD switch_off_answers_nothing.

    " OPT-IN: with the exit saying nothing (the shipped default is off) the
    " repository is not even asked - no monitor, and nothing latched, so an
    " exit that switches it on later is honoured without a new roll area
    DATA temp3 TYPE REF TO ltcl_exit_switch.
    DATA temp4 TYPE REF TO z2ui5_if_ui5_monitor.
    CREATE OBJECT temp3 TYPE ltcl_exit_switch.
    z2ui5_cl_ui5_user_exit=>set_instance( temp3 ).

    CLEAR temp4.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp4 ).

    cl_abap_unit_assert=>assert_not_bound( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = z2ui5_cl_ui5_srv_monitor=>gv_known ).

  ENDMETHOD.

  METHOD switch_asked_on_every_call.

    " switching the monitor off takes effect on the next roundtrip of a
    " running sticky session too: a latched answer is not returned while
    " the switch is off, whatever the lookup found while it was on
    DATA temp5 TYPE REF TO ltcl_exit_switch.
    DATA temp6 TYPE REF TO z2ui5_if_ui5_monitor.
    DATA li_on TYPE REF TO z2ui5_if_ui5_monitor.
    DATA temp7 TYPE xsdboolean.
    CREATE OBJECT temp5 TYPE ltcl_exit_switch.
    z2ui5_cl_ui5_user_exit=>set_instance( temp5 ).

    CLEAR temp6.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp6 ).

    ltcl_exit_switch=>gv_active = abap_true.

    li_on = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).

    ltcl_exit_switch=>gv_active = abap_false.
    cl_abap_unit_assert=>assert_not_bound( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) ).

    " and on again: the same answer as before, from the latch or the lookup
    ltcl_exit_switch=>gv_active = abap_true.

    temp7 = boolc( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) = li_on ).
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD switch_raising_is_off.

    " an exit whose POST config raises is "off" for the monitor - the same
    " CATCH that keeps a broken exit from deciding anything here
    DATA temp7 TYPE REF TO ltcl_exit_switch.
    DATA temp8 TYPE REF TO z2ui5_if_ui5_monitor.
    CREATE OBJECT temp7 TYPE ltcl_exit_switch.
    z2ui5_cl_ui5_user_exit=>set_instance( temp7 ).

    CLEAR temp8.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp8 ).
    ltcl_exit_switch=>gv_active = abap_true.
    ltcl_exit_switch=>gv_raise  = abap_true.

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = z2ui5_cl_ui5_srv_monitor=>check_switched_on( ) ).
    cl_abap_unit_assert=>assert_not_bound( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) ).

    ltcl_exit_switch=>gv_raise = abap_false.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = z2ui5_cl_ui5_srv_monitor=>check_switched_on( ) ).

  ENDMETHOD.

  METHOD installed_skips_the_switch.

    " a host that installs the monitor chose it - the exit's switch is not
    " asked, off or not
    DATA temp9 TYPE REF TO ltcl_exit_switch.
    DATA lo_monitor TYPE REF TO ltcl_monitor_noop.
    DATA temp8 TYPE xsdboolean.
    CREATE OBJECT temp9 TYPE ltcl_exit_switch.
    z2ui5_cl_ui5_user_exit=>set_instance( temp9 ).

    CREATE OBJECT lo_monitor TYPE ltcl_monitor_noop.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( lo_monitor ).


    temp8 = boolc( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) = lo_monitor ).
    cl_abap_unit_assert=>assert_true( temp8 ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = z2ui5_cl_ui5_srv_monitor=>gv_installed ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = z2ui5_cl_ui5_srv_monitor=>gv_known ).

  ENDMETHOD.

  METHOD lookup_answer_is_latched.

    " with the switch on, the first call asks the repository and the latch
    " remembers that an answer came back - bound or not - so the second call
    " does not ask again. The lookup that came back is the one asserted on;
    " a repository that raised (not latched, by design) would leave gv_known
    " off, and then the two answers are simply both unbound
    DATA temp10 TYPE REF TO ltcl_exit_switch.
    DATA temp11 TYPE REF TO z2ui5_if_ui5_monitor.
    DATA li_first TYPE REF TO z2ui5_if_ui5_monitor.
    DATA lv_known LIKE z2ui5_cl_ui5_srv_monitor=>gv_known.
    DATA li_second TYPE REF TO z2ui5_if_ui5_monitor.
    DATA temp9 TYPE xsdboolean.
    CREATE OBJECT temp10 TYPE ltcl_exit_switch.
    z2ui5_cl_ui5_user_exit=>set_instance( temp10 ).

    CLEAR temp11.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp11 ).
    ltcl_exit_switch=>gv_active = abap_true.


    li_first = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).

    lv_known = z2ui5_cl_ui5_srv_monitor=>gv_known.

    li_second = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).


    temp9 = boolc( li_first = li_second ).
    cl_abap_unit_assert=>assert_true( temp9 ).
    IF li_first IS BOUND.
      cl_abap_unit_assert=>assert_equals( exp = abap_true
                                          act = lv_known ).
    ENDIF.

  ENDMETHOD.

  METHOD unbound_resets_the_latch.

    " set_monitor( unbound ) is the way back to the lookup: neither
    " "installed" nor "known" survives it
    DATA temp12 TYPE REF TO ltcl_monitor_noop.
    DATA temp13 TYPE REF TO z2ui5_if_ui5_monitor.
    CREATE OBJECT temp12 TYPE ltcl_monitor_noop.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp12 ).

    CLEAR temp13.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp13 ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = z2ui5_cl_ui5_srv_monitor=>gv_installed ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = z2ui5_cl_ui5_srv_monitor=>gv_known ).
    cl_abap_unit_assert=>assert_not_bound( z2ui5_cl_ui5_srv_monitor=>gi_monitor ).

  ENDMETHOD.

  METHOD lookup_names_a_class.

    " the repository read itself. It answers a class name or nothing, or it
    " raises where there is no repository to read (the transpiled runtime
    " has no SEO_INTERFACE_IMPLEM_GET_ALL) - and each of the three is a
    " different answer of get_monitor( ): a name is instantiated, nothing
    " is latched as "no monitor", a raise is neither (fail open, asked
    " again next time)
    DATA lv_class TYPE string.
    DATA lo_monitor TYPE REF TO object.

    DATA temp14 TYPE REF TO ltcl_exit_switch.
    DATA temp15 TYPE REF TO z2ui5_if_ui5_monitor.
    DATA li_monitor TYPE REF TO z2ui5_if_ui5_monitor.
    CREATE OBJECT temp14 TYPE ltcl_exit_switch.
    z2ui5_cl_ui5_user_exit=>set_instance( temp14 ).

    CLEAR temp15.
    z2ui5_cl_ui5_srv_monitor=>set_monitor( temp15 ).
    ltcl_exit_switch=>gv_active = abap_true.

    TRY.
        lv_class = z2ui5_cl_ui5_srv_monitor=>monitor_class_lookup( ).
      CATCH cx_root.
        cl_abap_unit_assert=>assert_not_bound( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) ).
        cl_abap_unit_assert=>assert_equals( exp = abap_false
                                            act = z2ui5_cl_ui5_srv_monitor=>gv_known ).
        RETURN.
    ENDTRY.


    li_monitor = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = z2ui5_cl_ui5_srv_monitor=>gv_known ).
    IF lv_class IS INITIAL.
      cl_abap_unit_assert=>assert_not_bound( li_monitor ).
      RETURN.
    ENDIF.
    " the local double above is no global class and must not be what the
    " repository found; what it found instantiates
    CREATE OBJECT lo_monitor TYPE (lv_class).
    cl_abap_unit_assert=>assert_bound( lo_monitor ).
    cl_abap_unit_assert=>assert_bound( li_monitor ).

  ENDMETHOD.

ENDCLASS.
