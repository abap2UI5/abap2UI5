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
        console_area      TYPE string,
        output_area       TYPE string,

        log TYPE string,
        output TYPE string,
      END OF screen.
    CLASS-METHODS class_constructor.
  PRIVATE SECTION.
    CLASS-DATA port TYPE REF TO object.
    CLASS-DATA interpreter TYPE REF TO object.

    METHODS formatter IMPORTING iv_text       TYPE string
                      RETURNING VALUE(result) TYPE string.
    METHODS reset.
    METHODS init_console.
    METHODS repl IMPORTING code TYPE string
                 RETURNING VALUE(response) TYPE string.
ENDCLASS.



CLASS Z2UI5_CL_APP_SCHEME IMPLEMENTATION.


  METHOD class_constructor.
    DATA lo_port TYPE REF TO lcl_lisp_buffered_port.
    DATA lo_int TYPE REF TO lcl_lisp_profiler.
    lo_port ?= lcl_lisp_new=>port( iv_port_type = textual
                                iv_input     = abap_true
                                iv_output    = abap_true
                                iv_error     = abap_true
                                iv_buffered  = abap_true ).
    port ?= lo_port.
    lo_int = NEW lcl_lisp_profiler( io_port = lo_port
                                    ii_log = lo_port ).
    interpreter = lo_int.
  ENDMETHOD.


  METHOD formatter.
    result = escape( val    = iv_text
                     format = cl_abap_format=>e_json_string ).
  ENDMETHOD.


  METHOD init_console.
    CLEAR screen.
    screen-code_area = `(+ 1 3 4 4)`.
    screen-log =
      |==> Welcome to ABAP List Processing!\n| &&
      |==> ABAP Lisp -- Console { sy-uname } -- { sy-datlo DATE = ENVIRONMENT } { sy-uzeit TIME = ENVIRONMENT }\n|.

  ENDMETHOD.


  METHOD repl.
    DATA output TYPE string.
    DATA lo_int TYPE REF TO lcl_lisp_profiler. "The Lisp interpreter.

    CHECK interpreter IS BOUND.
    TRY.
        lo_int ?= interpreter.
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
        IF screen IS INITIAL.
          init_console( ).
        ELSE.
          reset( ).
        ENDIF.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_EVAL'.
            DATA(response) = repl( screen-code_area ).
            screen-console_area = formatter( screen-output ).
            screen-output_area = formatter( screen-log ).
            CLEAR screen-code_area.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_previous( ) ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).

        DATA(page) = view->page( title = 'abapScheme - UI5 Workbench'
                                 nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        page->simple_form('Scheme Interpreter' )->content( 'f'
             )->title( 'REPL'
             )->label( 'Scheme Editor'
             )->code_editor( value = view->_bind( screen-code_area )
                             type = 'scheme'
                             editable = abap_true
                             height = '200px'
                             width = '600px'
             )->label( 'Eval Output'
             )->text_area( value = view->_bind( screen-output_area )
                           height = '200px'
                            width = '600px'
             )->button( text = 'Eval' press = view->_event( 'BUTTON_EVAL' )
 ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
