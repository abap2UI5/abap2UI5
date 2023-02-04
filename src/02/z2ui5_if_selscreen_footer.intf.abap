INTERFACE z2ui5_if_selscreen_footer PUBLIC.

  METHODS Toolbar_spacer
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_footer.

  METHODS Begin_of_overflow_toolbar
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_footer.

  METHODS end_of_overflow_toolbar
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_footer.

  METHODS button
    IMPORTING
      text            TYPE string
      on_press_id     TYPE string DEFAULT 'block_title'
      type            TYPE clike OPTIONAL
      enabled         TYPE abap_bool OPTIONAL
      icon            TYPE clike OPTIONAL
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_footer.

  METHODS end_of_footer
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen.

ENDINTERFACE.
