INTERFACE z2ui5_if_view PUBLIC.
  CONSTANTS:
    BEGIN OF cs,
      BEGIN OF input,
        BEGIN OF type,
          password TYPE string VALUE 'Password',
          email    TYPE string VALUE 'Email',
          telefon  TYPE string VALUE 'Tel',
          number   TYPE string VALUE 'Number',
          url      TYPE string VALUE 'Url',
        END OF type,
        BEGIN OF value_state,
          warning     TYPE string VALUE 'Warning',
          success     TYPE string VALUE 'Success',
          error       TYPE string VALUE 'Error',
          information TYPE string VALUE 'Information',
        END OF value_state,
      END OF input,
      BEGIN OF button,
        BEGIN OF type,
          reject     TYPE string VALUE 'Reject',
          success    TYPE string VALUE 'Success',
          emphasized TYPE string VALUE 'Emphasized',
        END OF type,
      END OF button,
      BEGIN OF message_box,
        BEGIN OF type,
          error TYPE string VALUE 'error',
          show  TYPE string VALUE 'show',
        END OF type,
      END OF message_box,
    END OF cs.
  METHODS factory_selscreen
    IMPORTING
      name            TYPE string OPTIONAL
      title           TYPE string DEFAULT 'screen_title'
        PREFERRED PARAMETER name
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen.
ENDINTERFACE.
