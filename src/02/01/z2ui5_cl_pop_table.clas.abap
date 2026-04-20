CLASS z2ui5_cl_pop_table DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_tab           TYPE STANDARD TABLE
        i_title         TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_table.

    TYPES:
      BEGIN OF ty_s_result,
        row             TYPE REF TO data,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mr_tab TYPE REF TO data.

  PROTECTED SECTION.
    DATA title  TYPE string VALUE `Table View`.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS on_event.
    METHODS display.
    METHODS on_event_confirm.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_table IMPLEMENTATION.

  METHOD display.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.

    ASSIGN mr_tab->* TO <tab_out>.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( afterclose = client->_event( `CANCEL` )
                                                               stretch    = abap_true
                                                               title      = title
          )->content( ).

    DATA(tab) = popup->table( client->_bind( <tab_out> ) ).

    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_any( <tab_out> ).

    DATA(list) = tab->column_list_item( valign = `Top` ).
    DATA(cells) = list->cells( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      cells->text( |\{{ ls_comp-name }\}| ).
    ENDLOOP.

    DATA(columns) = tab->columns( ).

    DATA: lr_elem             TYPE REF TO cl_abap_elemdescr,
          lv_ddic_field_label TYPE string.

    LOOP AT lt_comp INTO ls_comp.
      IF ls_comp-type IS BOUND AND
          ls_comp-type->is_ddic_type( ) = abap_true.
        CLEAR: lv_ddic_field_label, lr_elem.

        DATA(lv_name) = substring_after( val = CAST cl_abap_elemdescr( ls_comp-type )->absolute_name
                                         sub = `\TYPE=` ).
        lv_ddic_field_label = z2ui5_cl_util=>rtti_get_data_element_text_l( lv_name ).

*        lr_elem ?= ls_comp-type.
*        lv_ddic_field_label = lr_elem->get_ddic_field( )-scrtext_l.

        IF lv_ddic_field_label IS NOT INITIAL.
          columns->column( '8rem' )->header( `` )->text( lv_ddic_field_label ).
          CONTINUE.
        ENDIF.
      ENDIF.

      columns->column( `8rem` )->header( `` )->text( ls_comp-name ).
    ENDLOOP.

    popup->get_parent(
        )->buttons(
            )->button( text  = `OK`
                       press = client->_event( `BUTTON_CONFIRM` )
                       type  = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD factory.
    FIELD-SYMBOLS <tab> TYPE any.

    r_result = NEW #( ).
    IF i_title IS NOT INITIAL.
      r_result->title = i_title.
    ENDIF.
    CREATE DATA r_result->mr_tab LIKE i_tab.
    CREATE DATA r_result->ms_result-row LIKE LINE OF i_tab.

    ASSIGN r_result->mr_tab->* TO <tab>.
    <tab> = i_tab.

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        on_event_confirm( ).

      WHEN `CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_event_confirm.

    client->popup_destroy( ).
    client->nav_app_leave( ).

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      display( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

ENDCLASS.
