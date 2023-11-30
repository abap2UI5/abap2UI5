class Z2UI5_CL_FW_APP_ERROR definition
  public
  final
  create protected .

public section.

  interfaces Z2UI5_IF_APP .
  interfaces IF_SERIALIZABLE_OBJECT .

  data CLIENT type ref to Z2UI5_IF_CLIENT .
  data MV_CHECK_INITIALIZED type ABAP_BOOL .
  data MV_CHECK_DEMO type ABAP_BOOL .
  data MX_ERROR type ref to CX_ROOT .

  class-methods FACTORY_ERROR
    importing
      !ERROR type ref to CX_ROOT
    returning
      value(RESULT) type ref to Z2UI5_CL_FW_APP_ERROR .
  methods Z2UI5_ON_INIT .
  methods Z2UI5_ON_EVENT .
  methods VIEW_DISPLAY_ERROR .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_APP_ERROR IMPLEMENTATION.


  METHOD factory_error.

    result = NEW #( ).
    result->mx_error = error.

  ENDMETHOD.


  METHOD view_display_error.

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


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    z2ui5_on_event( ).

    IF mx_error IS BOUND.
      view_display_error( ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN `DEMOS`.

        DATA li_app TYPE REF TO z2ui5_if_app.
        TRY.
            CREATE OBJECT li_app TYPE (`Z2UI5_CL_DEMO_APP_000`).
            mv_check_demo = abap_true.
            client->nav_app_call( li_app ).
          CATCH cx_root.
            mv_check_demo = abap_false.
        ENDTRY.

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    mv_check_demo = abap_true.

  ENDMETHOD.
ENDCLASS.
