CLASS z2ui5_cl_popup_layout DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_layout,
        name            TYPE string,
        visible         TYPE abap_bool,
        length          TYPE string,
        mergeduplicates TYPE abap_bool,
      END OF ty_s_layout.
    TYPES ty_t_layout TYPE STANDARD TABLE OF ty_s_layout WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        t_layout        TYPE ty_t_layout OPTIONAL
        i_tab           TYPE STANDARD TABLE OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_popup_layout.

    TYPES:
      BEGIN OF ty_s_result,
        t_layout        TYPE ty_t_layout,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.
    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS on_event.
    METHODS display.
    METHODS on_event_confirm.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_POPUP_LAYOUT IMPLEMENTATION.


  METHOD display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog(
              afterclose = client->_event( 'BUTTON_CONFIRM' )
              stretch    = abap_true
              title      = 'Layout View'
          )->content( ).

    DATA(tab) = popup->table(
       client->_bind_edit( ms_result-t_layout ) ).

    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_struc( ms_result-t_layout ).

    DATA(list) = tab->column_list_item( valign = `Top` ).
    DATA(cells) = list->cells( ).

    DATA(columns) = tab->columns( ).
    LOOP AT lt_comp INTO DATA(ls_comp2).
      DATA(col) = columns->column( '8rem' )->header( `` ).
      col->text( ls_comp2-name ).
    ENDLOOP.

    LOOP AT lt_comp INTO DATA(ls_comp).
      IF ls_comp-name = 'NAME'.
        cells->text( `{` && ls_comp-name && `}` ).
      ELSE.
        cells->checkbox( `{` && ls_comp-name && `}` ).
      ENDIF.
    ENDLOOP.

    popup->get_parent(
        )->footer( )->overflow_toolbar(
            )->toolbar_spacer(
            )->button(
                text  = 'OK'
                press = client->_event( 'BUTTON_CONFIRM' )
                type  = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD factory.

    r_result = NEW #( ).

    IF t_layout IS INITIAL.

      DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_struc( i_tab ).
      LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).
        INSERT VALUE #( name = lr_comp->name visible = abap_true mergeduplicates = abap_false )
          INTO TABLE r_result->ms_result-t_layout.
      ENDLOOP.

    ELSE.
      r_result->ms_result-t_layout = t_layout.
    ENDIF.

  ENDMETHOD.


  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'BUTTON_CONFIRM'.

        ms_result-check_confirmed = abap_true.
        on_event_confirm( ).

      WHEN 'CANCEL'.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD on_event_confirm.

    client->popup_destroy( ).
    client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

  ENDMETHOD.


  METHOD result.

    result = ms_result.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client     = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      display( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.
ENDCLASS.
