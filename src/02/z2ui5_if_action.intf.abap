"! Obsolete - the action->gen( ) mechanism has been superseded by
"! z2ui5_if_client~follow_up_action( ). Kept only for backward compatibility.
INTERFACE z2ui5_if_action
  PUBLIC.

  "! Obsolete - use z2ui5_if_client~follow_up_action( ) instead.
  METHODS gen
    IMPORTING
      val   TYPE clike
      t_arg TYPE string_table OPTIONAL.

ENDINTERFACE.
