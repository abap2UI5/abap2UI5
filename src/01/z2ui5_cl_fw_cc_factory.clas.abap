CLASS z2ui5_cl_fw_cc_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

    METHODS file_api
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_file_api.

    METHODS spreadsheet
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_cc_spreadsheet.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_cc_factory IMPLEMENTATION.

  METHOD file_api.

    result = NEW #( ).
    result->mo_view = mo_view.

  ENDMETHOD.

  METHOD spreadsheet.

    result = NEW #( ).
    result->mo_view = mo_view.

  ENDMETHOD.

ENDCLASS.
