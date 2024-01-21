CLASS z2ui5_cl_fw_app_startup DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

    DATA:
      BEGIN OF ms_home,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home .
    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_check_initialized TYPE abap_bool.
    DATA mv_check_demo TYPE abap_bool.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app_startup.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_start.
    METHODS on_event_check.
  PROTECTED SECTION.
    DATA mt_classes TYPE string_table.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_app_startup IMPLEMENTATION.


  METHOD factory.

    result = NEW #( ).

  ENDMETHOD.

  METHOD view_display_start.

    DATA(lv_url) = z2ui5_cl_util_func=>app_get_url(
                     client    = client
                     classname = ms_home-classname ).

    DATA(page) = z2ui5_cl_ui5=>_factory( )->_ns_m( )->shell(
      )->page( shownavbutton = abap_false ).

    page->headercontent(
            )->title( `abap2UI5 - Developing UI5 Apps Purely in ABAP`
            )->toolbarspacer(
            )->text( `v.` && z2ui5_cl_fw_http_handler=>c_abap_version
            )->link( text   = `SCN`
                     target = `_blank`
                     href   = `https://blogs.sap.com/tag/abap2ui5/`
            )->link( text   = `Twitter`
                     target = `_blank`
                     href   = `https://twitter.com/abap2UI5`
            )->link( text   = `GitHub`
                     target = `_blank`
                     href   = `https://github.com/abap2ui5/abap2ui5` ).

    DATA(grid) = page->_ns_ui( )->grid( `XL7 L7 M12 S12`
         )->content( `sap.ui.layout` ).
    DATA(content) = grid->simpleform( title    = `Quickstart`
                                       layout   = `ResponsiveGridLayout`
                                       editable = `true`
           )->content(  )->_ns_m( ).

    content->label( `Step 1`
        )->text( `Create a new class in your abap system`
        )->label( `Step 2`
        )->text( `Add the interface: Z2UI5_IF_APP`
        )->label( `Step 3`
        )->text( `Define view, implement behaviour`
        )->link( text   = `(Example)`
                 target = `_blank`
                 href   = `https://github.com/abap2UI5/abap2UI5/blob/main/src/03/02/z2ui5_cl_app_hello_world.clas.abap`
        )->label( `Step 4` ).

    IF ms_home-class_editable = abap_true.

      content->input( placeholder = `fill in the class name and press 'check'`
                      editable    = z2ui5_cl_util_func=>boolean_abap_2_json( ms_home-class_editable )
                      value       = client->_bind_edit( ms_home-classname )
                      submit      = client->_event( ms_home-btn_event_id )
                      valuehelprequest = client->_event( 'VALUE_HELP' )
                      showvaluehelp = abap_true
                       ).

    ELSE.
      content->text( ms_home-classname ).
    ENDIF.

    content->button( press = client->_event( ms_home-btn_event_id )
                     text  = ms_home-btn_text
                     icon  = ms_home-btn_icon
        )->label( `Step 5`
        )->link( text    = `Link to the Application`
                 target  = `_blank`
                 href    = lv_url
                 enabled = z2ui5_cl_util_func=>boolean_abap_2_json( xsdbool( ms_home-class_editable = abap_false ) ) ).

    DATA(form) = grid->simpleform( title    = `Samples`
                                    editable = abap_true
                                    layout   = `ResponsiveGridLayout` ).

    IF mv_check_demo = abap_false.
      form->_ns_m( )->messagestrip( text = `Oops! You need to install abap2UI5 demos before continuing...`
                           type = `Warning`
          )->_go_new( )->_add( n = `link` ns = `sap.m` )->_ns_m( )->link( text   = `(HERE)`
                                               target = `_blank`
                                               href   = `https://github.com/abap2UI5/abap2UI5-samples` ).
    ENDIF.

    DATA(cont) = form->content(  )->_ns_m( ).
    cont->label( ).
    cont->button(
       text    = `Continue...`
       press   = client->_event( val = `DEMOS` check_view_destroy = abap_true )
       enabled = xsdbool( mv_check_demo = abap_true ) )->_go_new( ).
    cont->button( visible = abap_false )->link( text   = `More on GitHub...`
                                               target = `_blank`
                                               href   = `https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/links.md` ).

    client->view_display( form->_stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      TRY.
          DATA(lo_f4) = CAST z2ui5_cl_popup_to_select( client->get_app( client->get( )-s_draft-id_prev_app ) ).
          DATA(ls_result) = lo_f4->result( ).
          IF ls_result-check_cancel = abap_false.
            FIELD-SYMBOLS <class> TYPE string.
            ASSIGN ls_result-row->* TO <class>.
            ms_home-classname = <class>.
            on_event_check( ).
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    z2ui5_on_event( ).
    view_display_start( ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN `BUTTON_CHANGE`.
        ms_home-btn_text       = `check`.
        ms_home-btn_event_id   = `BUTTON_CHECK`.
        ms_home-btn_icon       = `sap-icon://validate`.
        ms_home-class_editable = abap_true.

      WHEN `BUTTON_CHECK`.
        on_event_check( ).

      WHEN 'VALUE_HELP'.
        mt_classes = z2ui5_cl_util_func=>rtti_get_classes_impl_intf( `Z2UI5_IF_APP` ).
        client->nav_app_call( z2ui5_cl_popup_to_select=>factory( mt_classes ) ).

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

    ms_home-btn_text       = `check`.
    ms_home-btn_event_id   = `BUTTON_CHECK`.
    ms_home-class_editable = abap_true.
    ms_home-btn_icon       = `sap-icon://validate`.
    ms_home-classname      = `Z2UI5_CL_APP_HELLO_WORLD`.
    mv_check_demo          = abap_true.

  ENDMETHOD.

  METHOD on_event_check.

    TRY.
        DATA li_app_test TYPE REF TO z2ui5_if_app.
        ms_home-classname = z2ui5_cl_util_func=>c_trim_upper( ms_home-classname ).
        CREATE OBJECT li_app_test TYPE (ms_home-classname).

        client->message_toast_display( `App is ready to start!` ).
        ms_home-btn_text          = `edit`.
        ms_home-btn_event_id      = `BUTTON_CHANGE`.
        ms_home-btn_icon          = `sap-icon://edit`.
        ms_home-class_value_state = `Success`.
        ms_home-class_editable    = abap_false.

      CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
        ms_home-class_value_state_text = lx->get_text( ).
        ms_home-class_value_state      = `Warning`.
        client->message_box_display( text = ms_home-class_value_state_text
                                     type = `error` ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
