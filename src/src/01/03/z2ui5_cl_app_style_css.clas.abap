CLASS z2ui5_cl_app_style_css DEFINITION
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


CLASS z2ui5_cl_app_style_css IMPLEMENTATION.

  METHOD get.

    result =              `/* Enter your custom styles here */` &&
              ``.

  ENDMETHOD.

ENDCLASS.
