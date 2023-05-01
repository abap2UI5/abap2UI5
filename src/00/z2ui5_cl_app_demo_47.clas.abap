CLASS z2ui5_cl_app_demo_47 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA int1    TYPE i.
    DATA int2    TYPE i.
    DATA int_sum TYPE i.

    DATA dec1    TYPE p LENGTH 10 DECIMALS 4.
    DATA dec2    TYPE p LENGTH 10 DECIMALS 4.
    DATA dec_sum TYPE p LENGTH 10 DECIMALS 4.

    DATA boolean TYPE abap_bool.
    DATA date    TYPE d.
    DATA date2    TYPE d.
    DATA time    TYPE t.
    DATA time2    TYPE t.

    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_47 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      date = sy-datum.
      time = sy-uzeit.
      dec1 = -1 / 3.

*      /ui2/cl_json=>serialize(
*        EXPORTING
*          data             = time
**          compress         =
**          name             =
**          pretty_name      =
**          type_descr       =
**          assoc_arrays     =
**          ts_as_iso8601    =
**          expand_includes  =
**          assoc_arrays_opt =
**          numc_as_string   =
**          name_mappings    =
**          conversion_exits =
**          format_output    =
**          hex_as_base64    =
*       RECEIVING
*         r_json           = data(lv_json)
*      ).
*
*      data(lv_test) = conv string( lv_json ).
*      lv_test = lv_test+1.
*      lv_test = shift_right( val = lv_test sub = `"` ).
*
*       /ui2/cl_json=>deserialize(
*            EXPORTING
*              json             = lv_test
**              jsonx            =
**              pretty_name      =
**              assoc_arrays     =
**              assoc_arrays_opt =
**              name_mappings    =
*              conversion_exits = abap_true
**              hex_as_base64    =
*            CHANGING
*              data             = time2
*          ).

    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_INT'.
        int_sum = int1 + int2.
      WHEN 'BUTTON_DEC'.
        dec_sum = dec1 + dec2.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack  ) ).
    ENDCASE.

    client->set_next( VALUE #( xml_main = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
                title          = 'abap2UI5 - Integer and Decimals'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'
                    href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
                    target = '_blank'
            )->get_parent(
            )->simple_form( title = 'Integer and Decimals' editable = abap_true
                )->content( 'form'
                    )->title( 'Input'
*                    )->label( 'integer'
*                    )->input( value = client->_bind( int1 )
*                    )->input( value = client->_bind( int2 )
*                    )->input( enabled = abap_false value = client->_bind( int_sum )
                    )->button( text  = 'calc sum' press = client->_event( 'BUTTON_INT' )
*                    )->label( 'decimals'
*                    )->input( client->_bind( dec1 )
*                    )->input( client->_bind( dec2 )
*                    )->input( enabled = abap_false value = client->_bind( dec_sum )
*                    )->button( text  = 'calc sum' press = client->_event( 'BUTTON_DEC' )
*                    )->label( 'date'
*                    )->input( client->_bind( date )
*                    )->label( 'time'
*                    )->input( client->_bind( time )
                    )->label( 'boolean'
                    )->input( client->_bind( boolean )
         )->get_root( )->xml_get( ) ) ).


  ENDMETHOD.
ENDCLASS.
