CLASS z2ui5_cl_ui5_srv_monitor DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.

    "! The roundtrip monitor the framework calls - the class implementing
    "! z2ui5_if_ui5_monitor, looked up and instantiated once per roll area
    "! like the user exit - or unbound when there is none, or when the user
    "! exit has not switched it on (check_monitor_active, asked on every
    "! call). Never raises: a monitor is diagnostics, and a failing lookup or
    "! constructor costs its log entries, never the request (see get_monitor).
    CLASS-METHODS get_monitor
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_monitor.

    "! Install a monitor without the class lookup - for a host that is not an
    "! SAP system (no class repository to look in) and for tests. The host
    "! chose it, so the user exit's switch is not asked for it. Passing an
    "! unbound reference restores the default: the next get_monitor( ) asks
    "! the switch and the repository again.
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
    CLASS-DATA gi_monitor   TYPE REF TO z2ui5_if_ui5_monitor.
    CLASS-DATA gv_known     TYPE abap_bool.
    " installed by set_monitor( ) - the host's choice, not the lookup's
    CLASS-DATA gv_installed TYPE abap_bool.

    " the user exit's check_monitor_active - abap_false when the exit says
    " nothing, and when asking it raises
    CLASS-METHODS check_switched_on
      RETURNING
        VALUE(result) TYPE abap_bool.

    " the repository lookup itself, raising whatever the repository raises
    CLASS-METHODS monitor_class_lookup
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_monitor IMPLEMENTATION.

  METHOD get_monitor.
        DATA lv_class_name TYPE string.

    IF gv_installed = abap_true.
      result = gi_monitor.
      RETURN.
    ENDIF.

    " OPT-IN, before anything else. A monitor is code of another package
    " that runs inside every roundtrip of every app. The fail-open below
    " catches what it raises, but not a syntax error in it or in any class it
    " uses: that is the runtime error SYNTAX_ERROR, a short dump no CATCH
    " stops - an addon pulled half-activated took abap2UI5 down with a 500 on
    " every request (abap2UI5-addons/admin-cockpit, 2026-10-06). Only code
    " that is never called cannot do that, so without the switch the
    " repository is not even asked. Asked on every call, so switching it off
    " takes effect on the next roundtrip of a running sticky session too.
    IF check_switched_on( ) = abap_false.
      RETURN.
    ENDIF.

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

        lv_class_name = monitor_class_lookup( ).
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
    DATA temp1 TYPE xsdboolean.

    gi_monitor = monitor.

    temp1 = boolc( monitor IS BOUND ).
    gv_installed = temp1.
    gv_known = gv_installed.

  ENDMETHOD.

  METHOD check_switched_on.

    DATA ls_config TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.

    TRY.
        z2ui5_cl_ui5_user_exit=>get_instance( )->set_config_http_post( CHANGING cs_config = ls_config ).
        result = ls_config-check_monitor_active.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD monitor_class_lookup.

    " One repository read (SEO_INTERFACE_IMPLEM_GET_ALL on standard ABAP,
    " XCO on cloud), paid once per roll area like the exit's. The interface
    " is named through a typed reference, never a literal: a namespace
    " rename rewrites the reference and left a literal behind, so a renamed
    " installation looked up the original interface and found no monitor
    " (.github/scripts/rename-literal-gate.mjs)
    DATA li_monitor TYPE REF TO z2ui5_if_ui5_monitor.
    DATA lv_intf TYPE string.
    DATA lt_classes TYPE z2ui5_cl_ui5_util_context=>ty_t_classes.
    DATA temp2 TYPE string.
    DATA temp3 TYPE z2ui5_cl_ui5_util_context=>ty_s_class_descr.
    lv_intf = z2ui5_cl_ui5_util_context=>rtti_get_ref_type_name( li_monitor ).

    lt_classes = z2ui5_cl_ui5_util_context=>rtti_get_classes_impl_intf( lv_intf ).

    " only one monitor is called, so the pick must not depend on the order
    " the lookup happens to return - the same reasoning as the exit's: a
    " system with two implementing classes would otherwise run a different
    " one after a transport or a system copy
    SORT lt_classes BY classname.


    CLEAR temp2.

    READ TABLE lt_classes INTO temp3 INDEX 1.
    IF sy-subrc = 0.
      temp2 = temp3-classname.
    ENDIF.
    result = temp2.

  ENDMETHOD.

ENDCLASS.
