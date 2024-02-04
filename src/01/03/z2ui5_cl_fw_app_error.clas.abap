class Z2UI5_CL_FW_APP_ERROR definition
  public
  final
  create protected .

public section.

  interfaces Z2UI5_IF_APP .
  interfaces IF_SERIALIZABLE_OBJECT .

  data MX_ERROR type ref to CX_ROOT .

  class-methods FACTORY
    importing
      !ERROR type ref to CX_ROOT
    returning
      value(RESULT) type ref to Z2UI5_CL_FW_APP_ERROR .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_APP_ERROR IMPLEMENTATION.


  METHOD factory.

    result = NEW #( ).
    result->mx_error = error.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    DATA(lv_url) = shift_left( val = client->get( )-s_config-origin && client->get( )-s_config-pathname
                               sub = ` ` ).
    DATA(lv_url_app) = lv_url && client->get( )-s_config-search.

    DATA(lv_text) = ``.
    DATA(lx_error) = mx_error.
    WHILE lx_error IS BOUND.
      lv_text = lv_text && `<p>` && lx_error->get_text( ) && `</p>`.
      lx_error = lx_error->previous.
    ENDWHILE.

    DATA(view) = z2ui5_cl_ui5=>_factory( )->_ns_m( )->shell( )->illustratedmessage(
        enableformattedtext = abap_true
        illustrationtype    = `sapIllus-ErrorScreen`
        title               = `500 Internal Server Error`
        description         = lv_text
      )->additionalcontent(
        )->button(
            text  = `Home`
            type  = `Emphasized`
            press = client->_event_client( val = client->cs_event-location_reload t_arg  = VALUE #( ( lv_url ) ) )
        )->button(
            text  = `Restart`
            press = client->_event_client( val = client->cs_event-location_reload t_arg  = VALUE #( ( lv_url_app ) ) ) ).

    client->view_display( view->_stringify( ) ).

  ENDMETHOD.
ENDCLASS.
