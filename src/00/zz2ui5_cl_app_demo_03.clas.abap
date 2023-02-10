CLASS zz2ui5_cl_app_demo_03 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES zz2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_log           TYPE bapirettab
      RETURNING
        VALUE(r_result) TYPE REF TO zz2ui5_cl_app_demo_03.

    DATA mt_log TYPE bapirettab.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_03 IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->mt_log = i_log.

  ENDMETHOD.


  METHOD zz2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.


      WHEN client->lifecycle_method-on_init.
        client->display_view( 'POPUP_BAL' ).



      WHEN client->lifecycle_method-on_event.
        CASE client->get( )-event_id.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

        ENDCASE.



      WHEN client->lifecycle_method-on_rendering.

        client->factory_view( 'POPUP_BAL' )->add_page(
            event_nav_back_id = COND #( WHEN client->get( )-check_call_satck = abap_true THEN 'BUTTON_BACK' )
            title  = 'BAL Ausgabe'
          )->add_list(
             header_text = 'Log Ausgabe'
             items       = mt_log
          )->add_standard_list_item(
             title       =  '{TYPE}'
             description = '{MESSAGE}'
         ).


    ENDCASE.

  ENDMETHOD.

ENDCLASS.
