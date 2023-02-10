INTERFACE zz2ui5_if_ui5_library
  PUBLIC .


  METHODS code_editor
    IMPORTING
      value         TYPE string OPTIONAL
      type          TYPE string
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_cl_control_library.

ENDINTERFACE.
