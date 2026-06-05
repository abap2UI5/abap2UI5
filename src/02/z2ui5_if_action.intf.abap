INTERFACE z2ui5_if_action
  PUBLIC.

  METHODS gen
    IMPORTING
      val   TYPE clike
      t_arg TYPE string_table OPTIONAL.

ENDINTERFACE.
