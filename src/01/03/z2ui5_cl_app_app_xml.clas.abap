CLASS z2ui5_cl_app_app_xml DEFINITION
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


CLASS z2ui5_cl_app_app_xml IMPLEMENTATION.

  METHOD get.

    result =              `<mvc:View controllerName="z2ui5.controller.App"` &&
             `    xmlns:html="http://www.w3.org/1999/xhtml"` &&
             `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` &&
             `    xmlns="sap.m">` &&
             `    <App id="app">` &&
             `    </App>` &&
             `</mvc:View>` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
