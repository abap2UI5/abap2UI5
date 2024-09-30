CLASS z2ui5_cl_app_view_App_xml DEFINITION
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


CLASS z2ui5_cl_app_view_App_xml IMPLEMENTATION.

  METHOD get.

    result =              `<mvc:View controllerName="z2ui5.controller.App"` && |\n|  &&
             `    xmlns:html="http://www.w3.org/1999/xhtml"` && |\n|  &&
             `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` && |\n|  &&
             `    xmlns="sap.m">` && |\n|  &&
             `    <App id="app">` && |\n|  &&
             `    </App>` && |\n|  &&
             `</mvc:View>` && |\n|  &&
             `` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.