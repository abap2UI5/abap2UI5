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
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mi_installed = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).

  ENDMETHOD.

  METHOD teardown.

    z2ui5_cl_ui5_srv_monitor=>set_monitor( mi_installed ).

  ENDMETHOD.

  METHOD installed_monitor_answers.

    DATA(lo_monitor) = NEW ltcl_monitor_noop( ).

    z2ui5_cl_ui5_srv_monitor=>set_monitor( lo_monitor ).

    cl_abap_unit_assert=>assert_true(
        xsdbool( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) = lo_monitor ) ).

  ENDMETHOD.

  METHOD latched_per_roll_area.

    " asked twice, answered with the same instance - the lookup and the
    " instantiation run once per roll area, not per call (whatever the
    " system has installed, the answer must not change between the two)
    DATA(li_first)  = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).
    DATA(li_second) = z2ui5_cl_ui5_srv_monitor=>get_monitor( ).

    cl_abap_unit_assert=>assert_true( xsdbool( li_first = li_second ) ).

    " an unbound reference restores the lookup: the installed double is gone
    " again, whatever the system answers in its place
    DATA(lo_double) = NEW ltcl_monitor_noop( ).
    z2ui5_cl_ui5_srv_monitor=>set_monitor( lo_double ).
    z2ui5_cl_ui5_srv_monitor=>set_monitor( VALUE #( ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( z2ui5_cl_ui5_srv_monitor=>get_monitor( ) = lo_double ) ).

  ENDMETHOD.

ENDCLASS.
