INTERFACE Z2UI5_IF_SELSCREEN_FOOTER PUBLIC.
METHODS spacer
    RETURNING
      VALUE(r_result) TYPE REF TO Z2UI5_IF_SELSCREEN_FOOTER.
METHODS button
    IMPORTING
      text            TYPE string
      on_press_id     TYPE string DEFAULT 'block_title'
      type            TYPE clike OPTIONAL
      enabled         TYPE abap_bool OPTIONAL
      icon            TYPE clike OPTIONAL
    RETURNING
      VALUE(r_result) TYPE REF TO Z2UI5_IF_SELSCREEN_FOOTER.
METHODS end_of_footer
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen.
ENDINTERFACE.
