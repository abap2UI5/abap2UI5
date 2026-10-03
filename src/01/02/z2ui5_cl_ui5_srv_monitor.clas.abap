CLASS z2ui5_cl_ui5_srv_monitor DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.

    "! The roundtrip monitor the framework calls - the class implementing
    "! z2ui5_if_ui5_monitor, looked up and instantiated once per roll area
    "! like the user exit - or unbound when there is none. Never raises: a
    "! monitor is diagnostics, and a failing lookup or constructor costs its
    "! log entries, never the request (see get_monitor).
    CLASS-METHODS get_monitor
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_monitor.

    "! Install a monitor without the class lookup - for a host that is not an
    "! SAP system (no class repository to look in) and for tests. Passing an
    "! unbound reference restores the default: the next get_monitor( ) asks
    "! the repository again.
    "! @parameter monitor | the implementation to use from now on
    CLASS-METHODS set_monitor
      IMPORTING
        monitor TYPE REF TO z2ui5_if_ui5_monitor.

  PROTECTED SECTION.
  PRIVATE SECTION.
    " the instance and whether the lookup has ANSWERED in this roll area -
    " the answer may be "no monitor installed", which is why the reference
    " alone cannot say it. Latched exactly like z2ui5_cl_ui5_user_exit
    " latches the exit class: only a lookup that came back is remembered, so
    " a repository read that raised is asked again on the next request
    CLASS-DATA gi_monitor TYPE REF TO z2ui5_if_ui5_monitor.
    CLASS-DATA gv_known   TYPE abap_bool.

    " the repository lookup itself, raising whatever the repository raises
    CLASS-METHODS monitor_class_lookup
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_monitor IMPLEMENTATION.

  METHOD get_monitor.

    IF gv_known = abap_true.
      result = gi_monitor.
      RETURN.
    ENDIF.

    " FAIL OPEN, the opposite of the user exit. The exit is a hardening
    " control - CSP, CSRF, hidden error details - and an exit class that
    " cannot be instantiated must not silently leave every request on the
    " defaults, so z2ui5_cl_ui5_user_exit turns that into a visible 500. A
    " monitor only watches: failing closed would turn a broken log class
    " into a broken app for every user of the system, which is exactly the
    " outage the monitor exists to report. So a lookup that raises, or a
    " class that cannot be instantiated (a raising constructor, an abstract
    " or CREATE PRIVATE class, an inactive one), means "no monitor" for this
    " request - and is not latched, so the next request asks again instead
    " of remembering the failure for the rest of a sticky session.
    TRY.
        DATA(lv_class_name) = monitor_class_lookup( ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    IF lv_class_name IS NOT INITIAL.
      TRY.
          CREATE OBJECT gi_monitor TYPE (lv_class_name).
        CATCH cx_root.
          CLEAR gi_monitor.
          RETURN.
      ENDTRY.
    ENDIF.

    gv_known = abap_true.
    result = gi_monitor.

  ENDMETHOD.

  METHOD set_monitor.

    gi_monitor = monitor.
    gv_known = xsdbool( monitor IS BOUND ).

  ENDMETHOD.

  METHOD monitor_class_lookup.

    " One repository read (SEO_INTERFACE_IMPLEM_GET_ALL on standard ABAP,
    " XCO on cloud), paid once per roll area like the exit's. A dynamic name
    " is not a reference the compiler checks - the literal is held by
    " .github/scripts/dynamic-name-gate.mjs
    DATA(lt_classes) = z2ui5_cl_ui5_util_context=>rtti_get_classes_impl_intf( `Z2UI5_IF_UI5_MONITOR` ).

    " only one monitor is called, so the pick must not depend on the order
    " the lookup happens to return - the same reasoning as the exit's: a
    " system with two implementing classes would otherwise run a different
    " one after a transport or a system copy
    SORT lt_classes BY classname.

    result = VALUE #( lt_classes[ 1 ]-classname OPTIONAL ).

  ENDMETHOD.

ENDCLASS.
