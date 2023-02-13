CLASS zz2ui5_cl_app_demo_08 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS factory
      IMPORTING
        i_app TYPE REF TO z2ui5_if_app
        i_name_attri TYPE string
      RETURNING
        value(r_result) TYPE REF TO zz2ui5_cl_app_demo_08.


    DATA mo_app type ref to z2ui5_if_app.
    data mv_name_attri type string.


ENDCLASS.

CLASS zz2ui5_cl_app_demo_08 IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    r_result->mo_app = i_app.
    r_result->mv_name_attri = i_name_attri.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

*    CASE client->get( )-lifecycle_method.

*
*      WHEN client->lifecycle_method-on_init.
*        client->display_view( 'POPUP_BAL' ).
*
*
*
*      WHEN client->lifecycle_method-on_event.
*        CASE client->get( )-event_id.
*
*          WHEN 'BUTTON_BACK'.
*            client->nav_to_app( client->get_app_called( ) ).
*
*        ENDCASE.
*
*
*
*      WHEN client->lifecycle_method-on_rendering.
*
*        client->factory_view( 'POPUP_BAL' )->add_page(
*            event_nav_back_id = COND #( WHEN client->get( )-check_call_satck = abap_true THEN 'BUTTON_BACK' )
*            title  = 'BAL Ausgabe'
*         " )->add_list(
*        "     header_text = 'Log Ausgabe'
*          "   items       = mt_log
*          )->add_standard_list_item(
*             title       =  '{TYPE}'
*             description = '{MESSAGE}'
*         ).


*    ENDCASE.

  ENDMETHOD.

ENDCLASS.
