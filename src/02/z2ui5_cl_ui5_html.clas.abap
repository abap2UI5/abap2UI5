CLASS z2ui5_cl_ui5_html DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

  PUBLIC SECTION.
    METHODS script
      IMPORTING src           TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_html.

    METHODS style
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_html.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_html IMPLEMENTATION.
  METHOD script.
    result = me.
    _add( n  = `script`
          ns = `http://www.w3.org/1999/xhtml` ).
  ENDMETHOD.

  METHOD style.
    result = me.
    _add( n  = `style`
          ns = `http://www.w3.org/1999/xhtml` ).
  ENDMETHOD.
ENDCLASS.
