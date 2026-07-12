CLASS z2ui5_cl_pop_data DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        val             TYPE any
        title           TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_data.

    DATA mr_data TYPE REF TO data.

  PROTECTED SECTION.
    DATA title  TYPE string VALUE `Table View`.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_data IMPLEMENTATION.

  METHOD display.

    FIELD-SYMBOLS <data> TYPE any.

    ASSIGN mr_data->* TO <data>.

    IF z2ui5_cl_a2ui5_context=>rtti_check_table( <data> ).

      client->nav_app_call( z2ui5_cl_pop_table=>factory( i_tab   = <data>
                                                         i_title = title ) ).

    ELSEIF z2ui5_cl_a2ui5_context=>rtti_check_structure( <data> ).

      DATA(lt_result) = z2ui5_cl_a2ui5_context=>itab_get_by_struc( <data> ).
      client->nav_app_call( z2ui5_cl_pop_table=>factory( i_tab   = lt_result
                                                         i_title = title ) ).

    ENDIF.

  ENDMETHOD.

  METHOD factory.

    FIELD-SYMBOLS <data> TYPE any.

    r_result = NEW #( ).
    IF title IS NOT INITIAL.
      r_result->title = title.
    ENDIF.
    CREATE DATA r_result->mr_data LIKE val.

    ASSIGN r_result->mr_data->* TO <data>.
    <data> = val.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.
    IF client->check_on_init( ).
      display( ).
      RETURN.
    ENDIF.
    client->nav_app_leave( ).

  ENDMETHOD.

ENDCLASS.
