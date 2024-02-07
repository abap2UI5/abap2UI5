CLASS z2ui5_cl_ui5_suite DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

  PUBLIC SECTION.
    METHODS interactdonutchart
      IMPORTING selectionchanged  TYPE clike OPTIONAL
                errormessage      TYPE clike OPTIONAL
                errormessagetitle TYPE clike OPTIONAL
                showerror         TYPE clike OPTIONAL
                displayedsegments TYPE clike OPTIONAL
                press             TYPE clike OPTIONAL
      RETURNING VALUE(result)     TYPE REF TO z2ui5_cl_ui5_suite.

    METHODS segments
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_suite.

    METHODS interactdonutchartsegment
      IMPORTING label          TYPE clike OPTIONAL
                value          TYPE clike OPTIONAL
                displayedvalue TYPE clike OPTIONAL
                selected       TYPE clike OPTIONAL
      RETURNING VALUE(result)  TYPE REF TO z2ui5_cl_ui5_suite.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_suite IMPLEMENTATION.
  METHOD interactdonutchartsegment.
    result = _add( n   = `InteractiveDonutChartSegment`
                   ns  = `sap.suite.ui.microchart`
                   t_p = VALUE #( ( n = `label`          v = label )
                                  ( n = `displayedValue` v = displayedvalue )
                                  ( n = `value`          v = value )
                                  ( n = `selected`       v = selected ) ) )->_ns_suite( ).
  ENDMETHOD.

  METHOD segments.
    result = _add( n  = `segments`
                   ns = `sap.suite.ui.microchart` )->_ns_suite( ).
  ENDMETHOD.

  METHOD interactdonutchart.
    result = _add( n   = `InteractiveDonutChart`
                   ns  = `sap.suite.ui.microchart`
                   t_p = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                                  ( n = `showError`         v = z2ui5_cl_util=>boolean_abap_2_json( showerror ) )
                                  ( n = `errorMessageTitle` v = errormessagetitle )
                                  ( n = `errorMessage`      v = errormessage )
                                  ( n = `displayedSegments` v = displayedsegments )
                                  ( n = `press`             v = press ) ) )->_ns_suite( ).
  ENDMETHOD.
ENDCLASS.
