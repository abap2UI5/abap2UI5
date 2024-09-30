CLASS z2ui5_cl_app_view_View1_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_view_View1_xml IMPLEMENTATION.

  METHOD get.

    result =              `<mvc:View controllerName="z2ui5.controller.View1"` && |\n|  &&
             `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` && |\n|  &&
             `    xmlns="sap.m">` && |\n|  &&
             `</mvc:View>` && |\n|  &&
             `` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.