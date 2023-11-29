class Z2UI5_CL_CC_DEMO_OUTPUT definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !VIEW type ref to Z2UI5_CL_XML_VIEW .
  methods CONTROL
    importing
      !VAL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  class-methods GET_STYLE
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.
      DATA mo_view TYPE REF TO z2ui5_cl_xml_view.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_DEMO_OUTPUT IMPLEMENTATION.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD control.

     result = mo_view->_cc_plain_xml( get_style( ) )->html( val ).

  ENDMETHOD.


method get_style.
result = `<html:style type="text/css">body {` && |\n|  &&
                              `     font-family: Arial;` && |\n|  &&
                              `     font-size: 90%;` && |\n|  &&
                              `}` && |\n|  &&
                              `table {` && |\n|  &&
                              `     font-family: Arial;` && |\n|  &&
                              `     font-size: 90%;` && |\n|  &&
                              `}` && |\n|  &&
                              `caption {` && |\n|  &&
                              `     font-family: Arial;` && |\n|  &&
                              `     font-size: 90%;` && |\n|  &&
                              `     font-weight:bold;` && |\n|  &&
                              `     text-align:left;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.heading1 {` && |\n|  &&
                              `    font-size: 150%;` && |\n|  &&
                              `     color:#000080;` && |\n|  &&
                              `     font-weight:bold;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.heading2 {` && |\n|  &&
                              `    font-size: 135%;` && |\n|  &&
                              `     color:#000080;` && |\n|  &&
                              `     font-weight:bold;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.heading3 {` && |\n|  &&
                              `    font-size: 120%;` && |\n|  &&
                              `     color:#000080;` && |\n|  &&
                              `     font-weight:bold;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.heading4 {` && |\n|  &&
                              `    font-size: 105%;` && |\n|  &&
                              `     color:#000080;` && |\n|  &&
                              `     font-weight:bold;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.normal {` && |\n|  &&
                              `    font-size: 100%;` && |\n|  &&
                              `     color:#000000;` && |\n|  &&
                              `     font-weight:normal;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.nonprop {` && |\n|  &&
                              `    font-family: Courier New;` && |\n|  &&
                              `     font-size: 100%;` && |\n|  &&
                              `     color:#000000;` && |\n|  &&
                              `     font-weight:400;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.nowrap {` && |\n|  &&
                              `    white-space:nowrap;` && |\n|  &&
                              `}` && |\n|  &&
                              `span.nprpnwrp {` && |\n|  &&
                              `    font-family: Courier New;` && |\n|  &&
                              `     font-size: 100%;` && |\n|  &&
                              `     color:#000000;` && |\n|  &&
                              `     font-weight:400;` && |\n|  &&
                              `     white-space:nowrap;` && |\n|  &&
                              `}` && |\n|  &&
                              `tr.header {` && |\n|  &&
                              `    background-color:#D3D3D3;` && |\n|  &&
                              `}` && |\n|  &&
                              `tr.body {` && |\n|  &&
                              `    background-color:#EFEFEF;` && |\n|  &&
                              `}` && |\n|  &&
                              `</html:style>`.
endmethod.
ENDCLASS.
