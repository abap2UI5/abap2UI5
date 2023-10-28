CLASS z2ui5_cl_fw_cc_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS ui5_file_uploader
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_file_uploader.

    METHODS ui5_spreadsheet
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_spreadsheet.

    METHODS gui_demo_output
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_demo_output.

    METHODS load_font_awsome
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_font_awsome_icons.

    METHODS constructor
      IMPORTING
        i_view TYPE REF TO z2ui5_cl_xml_view.
    METHODS bwip_js
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_bwipjs.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_CC_FACTORY IMPLEMENTATION.


  METHOD bwip_js.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD constructor.

    me->mo_view = i_view.

  ENDMETHOD.


  METHOD gui_demo_output.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD load_font_awsome.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD ui5_file_uploader.

    result = NEW #( mo_view ).

  ENDMETHOD.


  METHOD ui5_spreadsheet.

    result = NEW #( mo_view ).

  ENDMETHOD.
ENDCLASS.
