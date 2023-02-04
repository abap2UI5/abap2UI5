INTERFACE Z2UI5_IF_SELSCREEN PUBLIC.

METHODS begin_of_block
    IMPORTING
      title           TYPE string DEFAULT 'block_title'
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_block.

METHODS begin_of_footer
    IMPORTING
      label           TYPE string DEFAULT 'line_label'
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_footer.

METHODS message_strip
    IMPORTING
      text            TYPE string DEFAULT 'line_label'
      type            TYPE string OPTIONAL
      PREFERRED PARAMETER text
    RETURNING
      VALUE(r_result) TYPE REF TO Z2UI5_IF_SELSCREEN.

METHODS end_of_screen
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_view.

ENDINTERFACE.
