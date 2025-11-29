CLASS z2ui5_cl_pop_data DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

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
        DATA lt_result TYPE z2ui5_cl_util=>ty_t_name_value.

    ASSIGN mr_data->* TO <data>.

    CASE z2ui5_cl_util=>rtti_get_type_kind( <data> ).

      WHEN cl_abap_typedescr=>typekind_table.

        client->nav_app_call( z2ui5_cl_pop_table=>factory( <data> ) ).

      WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2.
        
        lt_result = z2ui5_cl_util=>itab_get_by_struc( <data> ).
        client->nav_app_call( z2ui5_cl_pop_table=>factory( lt_result ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD factory.

    FIELD-SYMBOLS <data> TYPE any.

    CREATE OBJECT r_result.
    IF title IS NOT INITIAL.
      r_result->title = title.
    ENDIF.
    CREATE DATA r_result->mr_data LIKE val.

    ASSIGN r_result->mr_data->* TO <data>.
    <data> = val.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.
    IF client->check_on_init( ) IS NOT INITIAL.
      display( ).
      RETURN.
    ENDIF.
    client->nav_app_leave( ).

  ENDMETHOD.

ENDCLASS.
