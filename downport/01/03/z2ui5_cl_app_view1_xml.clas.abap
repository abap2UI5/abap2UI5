CLASS z2ui5_cl_app_view1_xml DEFINITION
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


CLASS z2ui5_cl_app_view1_xml IMPLEMENTATION.

  METHOD get.

    result =              `<mvc:View controllerName="z2ui5.controller.View1"` &&
             `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` &&
             `    xmlns="sap.m">` &&
             `</mvc:View>` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
