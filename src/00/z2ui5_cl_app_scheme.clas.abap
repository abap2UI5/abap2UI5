CLASS z2ui5_cl_app_scheme DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

    DATA:
      BEGIN OF screen,
        check_initialized TYPE abap_bool,
        check_is_active   TYPE abap_bool,
        code_area         TYPE string,
        input_area        TYPE string,
        console_area      TYPE string,
        output_area       TYPE string,

        path TYPE string,

        log TYPE string,
        output TYPE string,

        port TYPE REF TO object,
        interpreter TYPE REF TO if_serializable_object,
        environment TYPE REF TO if_serializable_object,
      END OF screen.
  PROTECTED SECTION.
    METHODS init.
    METHODS refresh_scheme.
    METHODS format_all.

  PRIVATE SECTION.

    METHODS formatter IMPORTING iv_text       TYPE string
                      RETURNING VALUE(result) TYPE string.
    METHODS reset.
    METHODS refresh.
    METHODS init_console.
    METHODS repl IMPORTING code TYPE string
                 RETURNING VALUE(response) TYPE string.
ENDCLASS.



CLASS Z2UI5_CL_APP_SCHEME IMPLEMENTATION.


  METHOD formatter.
    result = escape( val    = iv_text
                     format = cl_abap_format=>e_json_string ).
  ENDMETHOD.


  METHOD format_all.
    screen-console_area = formatter( screen-log ).
    screen-output_area = formatter( screen-output ).
  ENDMETHOD.


  METHOD init.
    IF screen IS INITIAL.
      init_console( ).
    ENDIF.
  ENDMETHOD.


  METHOD init_console.
    CLEAR screen.
    screen-check_is_active = abap_true.
    refresh_scheme( ).
    screen-code_area = `(+ 1 3 4 4)`.
  ENDMETHOD.


  METHOD refresh.
    DATA lo_port TYPE REF TO lcl_lisp_buffered_port.
    DATA lo_int TYPE REF TO lcl_lisp_profiler.
    lo_port ?= lcl_lisp_new=>port( iv_port_type = textual
                                   iv_input     = abap_true
                                   iv_output    = abap_true
                                   iv_error     = abap_true
                                   iv_buffered  = abap_true ).
    screen-port = lo_port.
    lo_int = lcl_lisp_profiler=>new_profiler( io_port = lo_port
                                              ii_log = lo_port
                                              io_env = screen-environment ).
    screen-interpreter ?= lo_int.
    screen-environment ?= lo_int->env.
  ENDMETHOD.


  METHOD refresh_scheme.
    refresh( ).
    reset( ).
    screen-output = |==> Welcome to ABAP List Processing!\n|.
    screen-log = |==> ABAP Lisp -- Console { sy-uname } -- { sy-datlo DATE = ENVIRONMENT } { sy-uzeit TIME = ENVIRONMENT }\n|.
    format_all( ).
  ENDMETHOD.


  METHOD repl.
    DATA output TYPE string.
    DATA lo_int TYPE REF TO lcl_lisp_profiler. "The Lisp interpreter.
    DATA lo_port TYPE REF TO lcl_lisp_buffered_port.

    TRY.
        lo_port ?= screen-port.
        lo_int = lcl_lisp_profiler=>new_profiler( io_port = lo_port
                                                  ii_log = lo_port
                                                  io_env = screen-environment ).
        response = lo_int->eval_repl( EXPORTING code = code
                                      IMPORTING output = output ).
        response = |[ { lo_int->runtime } µs ] { response }|.

      CATCH cx_root INTO DATA(lx_root).
        response = lx_root->get_text( ).

    ENDTRY.

    screen-output &&= output.
    screen-log &&= |{ code }\n=> { response }\n|.
  ENDMETHOD.


  METHOD reset.
    CLEAR screen-code_area.
  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        init( ).

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'DB_LOAD'.
            " screen-code_area
            client->display_message_toast( 'Download successfull' ).

          WHEN 'DB_SAVE'.
            "lcl_mime_api=>save_data( ).
            client->display_message_box( text = 'Upload successfull. File saved!' type = 'success' ).

          WHEN 'BUTTON_RESET'.
            refresh_scheme( ).

          WHEN 'BUTTON_TRACE'.

          WHEN 'BUTTON_SEXP'.

          WHEN 'BUTTON_EVAL'.
            DATA(response) = repl( screen-code_area ).
            format_all( ).
            reset( ).

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_previous( ) ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'SCHEME_INPUT' ).
        DATA(page) = view->page( title = 'abapScheme - UI5 Workbench'
                                 nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        page->header_content( )->overflow_toolbar(
            )->button(
                text  = 'Evaluate'
                press = view->_event( 'BUTTON_EVAL' )
                icon = 'sap-icon://simulate'
            )->toolbar_spacer(
            )->button( text = 'Trace' press = view->_event( 'BUTTON_TRACE' )
                        "icon = 'sap-icon://save'
            )->button( text = 'S-Expression' press = view->_event( 'BUTTON_SEXP' )
                       icon = 'sap-icon://tree'
            )->link( text = 'Help' href = 'https://github.com/nomssi/abap_scheme/wiki'
            )->button(
                 text = 'Refresh'
                 press = view->_event( 'BUTTON_RESET' )
                 icon  = 'sap-icon://delete'
            )->button(
                text  = 'Upload'
                press = view->_event( 'DB_SAVE' )
                type  = 'Emphasized'
                icon = 'sap-icon://save'
                enabled = abap_true ).

        DATA(grid) = page->grid( 'L12 M12 S12' )->content( 'l' ).

        grid->simple_form(  'Scheme Editor' )->content( 'f'
            )->code_editor( value = view->_bind( screen-code_area )
                            type = 'scheme'
                            editable = abap_true
                            height = '200px'
            ")->label( text = 'Output'
            )->text_area( value = view->_bind( screen-output_area )
                          height = '200px' ).

        grid->simple_form( 'Input' )->content( 'f'
          )->input( view->_bind( screen-input_area )  ).
        grid->simple_form( 'Console' )->content( 'f'
          )->text_area( value = view->_bind( screen-console_area )
                        height = '200px' ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
