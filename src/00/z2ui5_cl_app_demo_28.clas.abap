CLASS z2ui5_cl_app_demo_28 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE i.

    DATA input21 TYPE string.
    DATA input22 TYPE string.
    DATA input41 TYPE string.
  PROTECTED SECTION.

    DATA:
      BEGIN OF app,
        client            TYPE REF TO z2ui5_if_client,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        s_get             TYPE z2ui5_if_client=>ty_s_get,
        s_next            TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_28 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    app-client     = client.
    app-s_get      = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-s_get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-s_next ).
    CLEAR app-s_get.
    CLEAR app-s_next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BUTTON_POST'.
        app-client->popup_message_toast( |{ product } { quantity } - send to the server| ).
        app-view_popup = 'POPUP_CONFIRM'.

      WHEN 'BUTTON_CONFIRM'.
        app-client->popup_message_toast( |confirm| ).
        app-view_popup = ''.

      WHEN 'BUTTON_CANCEL'.
        app-client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        app-client->nav_app_leave( app-client->get_app( app-s_get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.
    input41 = 'faasdfdfsaVIp'.

    input21 = '40'.
    input22 = '40'.

  ENDMETHOD.


  METHOD z2ui5_on_render.

*
*    app-s_next-xml_main = z2ui5_cl_xml_view_helper=>factory(
*      )->page(
*              title          = 'abap2UI5 - Binding Syntax'
*              navbuttonpress = app-client->_event( 'BACK' )
*              shownavbutton  = abap_true
*          )->header_content(
*              )->link(
*                  text = 'Source_Code'
*                  href = app-client->get( )-url_source_code
*          )->get_parent(
*          )->simple_form( title = 'Binding Syntax' editable = abap_true
*              )->content( 'f'
*                )->title( 'Templating'
*                  )->label( 'Documentation'
*                )->link(
*                  text = 'Templating'
*                  href = 'https://sapui5.hana.ondemand.com/#/entity/sap.ui.core.mvc.XMLView'
*                )->label( 'when both values are equal second form is displayed'
*                )->input( app-client->_bind( input21 )
*                )->input( app-client->_bind( input22 )
*
*         )->get_parent( )->get_parent(
*      "   )->template_if(  test = '{= $' && app-client->_bind( input21 ) && ` === $` && app-client->_bind( input22 ) && `  } `
*         )->template_if(  test = '{= ${meta>/oUpdate/INPUT21} === ${meta>/oUpdate/INPUT22}   } '
*         )->simple_form( title = 'Binding Syntax' editable = abap_true
*              )->content( 'f'
*                )->title( 'Expression Binding'
*                )->label( 'templating'
*                )->input( app-client->_bind( input21 )
*                )->input( app-client->_bind( input22 )
*
*       )->get_root( )->xml_get( ).


  ENDMETHOD.
ENDCLASS.
