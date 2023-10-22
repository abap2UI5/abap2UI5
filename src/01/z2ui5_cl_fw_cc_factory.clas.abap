CLASS z2ui5_cl_fw_cc_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

    METHODS ui5_file_uploader
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_file_uploader.

    METHODS ui5_spreadsheet
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_spreadsheet.

    METHODS bwip_js
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_bwipjs.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_cc_factory IMPLEMENTATION.

  METHOD ui5_file_uploader.

    result = NEW #( ).
    result->mo_view = mo_view.

  ENDMETHOD.

  METHOD ui5_spreadsheet.

    result = NEW #( ).
    result->mo_view = mo_view.

  ENDMETHOD.

  METHOD bwip_js.

    result = NEW #( ).
    result->mo_view = mo_view.

  ENDMETHOD.

ENDCLASS.
