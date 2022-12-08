INTERFACE Z2UI5_IF_SELSCREEN_BLOCK PUBLIC.
METHODS begin_of_group
    IMPORTING
      title           TYPE string DEFAULT 'block_title'
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
METHODS end_of_block
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen.
ENDINTERFACE.
