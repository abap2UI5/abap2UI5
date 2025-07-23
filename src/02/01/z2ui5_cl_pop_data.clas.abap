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
    DATA title             TYPE string VALUE 'Table View'.
    DATA client            TYPE REF TO z2ui5_if_client.
    METHODS display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_data IMPLEMENTATION.

  METHOD display.

    FIELD-SYMBOLS <data> TYPE any.
    ASSIGN mr_data->* TO <data>.

    CASE z2ui5_cl_util=>rtti_get_type_kind( <data> ).

      WHEN cl_abap_typedescr=>typekind_table.

        client->nav_app_call( z2ui5_cl_pop_table=>factory( <data> ) ).

      WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2.

        DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( <data> ).
        DATA(lt_result) = VALUE z2ui5_cl_util=>ty_t_name_value( ).
        LOOP AT lt_attri REFERENCE INTO DATA(lr_attri).

          ASSIGN COMPONENT lr_attri->name OF STRUCTURE <data> TO FIELD-SYMBOL(<component>).

          CASE z2ui5_cl_util=>rtti_get_type_kind( <component> ).

            WHEN  cl_abap_typedescr=>typekind_table.

            WHEN OTHERS.
              INSERT VALUE #(
                n = lr_attri->name
                v = <component>
                ) INTO TABLE lt_result.
          ENDCASE.

        ENDLOOP.
        client->nav_app_call( z2ui5_cl_pop_table=>factory( lt_result ) ).

    ENDCASE.


  ENDMETHOD.

  METHOD factory.

    r_result = NEW #( ).
    IF title IS NOT INITIAL.
      r_result->title = title.
    ENDIF.
    CREATE DATA r_result->mr_data LIKE val.

    FIELD-SYMBOLS <data> TYPE any.
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
