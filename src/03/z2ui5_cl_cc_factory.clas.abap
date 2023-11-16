CLASS z2ui5_cl_cc_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS ui5_file_uploader
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_file_uploader.

    METHODS ui5_spreadsheet
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_spreadsheet.

    METHODS gui_demo_output
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_demo_output.

    METHODS font_awesome
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_font_awesome_icons.

    METHODS constructor
      IMPORTING
        i_view TYPE REF TO z2ui5_cl_xml_view.

    METHODS bwip_js
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_bwipjs.

    METHODS driver_js
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_driver_js.

    METHODS timer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_timer.

    METHODS title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_title.

    METHODS info
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_info.

    METHODS geolocation
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_cc_geolocation.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_FACTORY IMPLEMENTATION.

 METHOD info.

    result = NEW #( mo_view ).

  ENDMETHOD.

  METHOD timer.

    result = NEW #( mo_view ).

  ENDMETHOD.

  METHOD title.

    result = NEW #( mo_view ).

  ENDMETHOD.

  METHOD bwip_js.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD constructor.

    me->mo_view = i_view.

  ENDMETHOD.


  METHOD driver_js.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD gui_demo_output.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD font_awesome.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD ui5_file_uploader.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD ui5_spreadsheet.

    result = NEW #( mo_view ).

  ENDMETHOD.

  METHOD GEOLOCATION.

result = NEW #( mo_view ).

  ENDMETHOD.

ENDCLASS.
