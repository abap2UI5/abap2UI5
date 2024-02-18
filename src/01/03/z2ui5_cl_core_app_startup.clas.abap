CLASS z2ui5_cl_core_app_startup DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

    DATA:
      BEGIN OF ms_home,
        url                    TYPE string,
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

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app_startup.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_start.
    METHODS on_event_check.
  PROTECTED SECTION.
    DATA mt_classes TYPE string_table.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_app_startup IMPLEMENTATION.


  METHOD factory.

    result = NEW #( ).

  ENDMETHOD.


  METHOD on_event_check.
    DATA li_app_test TYPE REF TO z2ui5_if_app.

    TRY.
        ms_home-classname = z2ui5_cl_util=>c_trim_upper( ms_home-classname ).
        CREATE OBJECT li_app_test TYPE (ms_home-classname).

        client->message_toast_display( `App is ready to start!` ).
        ms_home-btn_text          = `edit`.
        ms_home-btn_event_id      = `BUTTON_CHANGE`.
        ms_home-btn_icon          = `sap-icon://edit`.
        ms_home-class_value_state = `Success`.
        ms_home-class_editable    = abap_false.

        ms_home-url = z2ui5_cl_util=>app_get_url(
                   client    = client
                   classname = ms_home-classname ).

      CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
        ms_home-class_value_state_text = lx->get_text( ).
        ms_home-class_value_state      = `Warning`.
        client->message_box_display( text = ms_home-class_value_state_text
                                     type = `error` ).
    ENDTRY.

  ENDMETHOD.


  METHOD view_display_start.

    DATA(page2) = z2ui5_cl_xml_view=>factory( )->shell( )->page(
         shownavbutton = abap_false ).

    page2->header_content(
      )->text(
      )->title( `abap2UI5 - Developing UI5 Apps Purely in ABAP`
      )->toolbar_spacer(
      )->button( text = `System` icon = `sap-icon://information`
        press = client->_event( `OPEN_INFO` ) ).

    DATA(simple_form2) = page2->simple_form(
        editable                = abap_true
        layout                  = `ResponsiveGridLayout`
        labelspanxl             = `4`
        labelspanl              = `3`
        labelspanm              = `4`
        labelspans              = `12`
        adjustlabelspan         = abap_false
        emptyspanxl             = `0`
        emptyspanl              = `4`
        emptyspanm              = `0`
        emptyspans              = `0`
        columnsxl               = `1`
        columnsl                = `1`
        columnsm                = `1`
        singlecontainerfullsize = abap_false
      )->content( `form` ).

    simple_form2->toolbar( )->title( `Quickstart` ).
    simple_form2->label( `Step 1`
      )->text( `Create a new class in your ABAP system`
      )->label( `Step 2`
      )->text( `Add the interface: Z2UI5_IF_APP`
      )->label( `Step 3`
      )->text( `Define the view, implement behaviour`
      )->label(
      )->link( text = `(Example)`
             target = `_blank`
             href   = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/02/z2ui5_cl_app_hello_world.clas.abap`
      )->label( `Step 4` ).

    IF ms_home-class_editable = abap_true.

      simple_form2->input( placeholder = `fill in the class name and press 'check'`
                      enabled          = client->_bind( ms_home-class_editable )
                      value            = client->_bind_edit( ms_home-classname )
                      submit           = client->_event( ms_home-btn_event_id )
                      valuehelprequest = client->_event( 'VALUE_HELP' )
                      showvaluehelp    = abap_true ).

    ELSE.
      simple_form2->text( ms_home-classname ).
    ENDIF.

    simple_form2->label( ).
    simple_form2->button( press = client->_event( ms_home-btn_event_id )
                     text       = client->_bind( ms_home-btn_text )
                     icon       = client->_bind( ms_home-btn_icon )
                     width      = `70%` ).
    simple_form2->label( `Step 5`
      )->link( text  = `Link to the Application`
             target  = `_blank`
             href    = client->_bind( ms_home-url )
             enabled = `{= $` && client->_bind( val = ms_home-class_editable ) && ` === false }` ).


    DATA(lv_url_samples2) = z2ui5_cl_util=>app_get_url(
                  client    = client
                  classname = 'z2ui5_cl_demo_app_000' ).

    DATA(lv_url_samples3) = z2ui5_cl_util=>app_get_url(
                    client    = client
                    classname = 'z2ui5_cl_app_search_apps' ).

    simple_form2->toolbar( )->title( `What's next?` ).

    IF z2ui5_cl_util=>rtti_check_class_exists( `z2ui5_cl_demo_app_000` ).
      simple_form2->label( `Start Developing` ).
      simple_form2->button(
        text      = `Check Out the Samples`
        press     = client->_event_client( val   = client->cs_event-open_new_tab
                                           t_arg = VALUE #( ( lv_url_samples2 ) ) )
            width = `70%` ).

    ELSE.
      simple_form2->label( `Install the sample repository` ).
      simple_form2->link( text = `And explore more than 100 demo apps...`
              target           = `_blank`
              href             = `https://github.com/abap2UI5/abap2UI5-samples` ).
    ENDIF.

    simple_form2->label( `App Finder` ).
    simple_form2->button(
        text      = `Start & Install App`
        press     = client->_event_client( val   = client->cs_event-open_new_tab
                                           t_arg = VALUE #( ( lv_url_samples3 ) ) )
            width = `70%` ).

    simple_form2->label( `` ).
    simple_form2->text( `` ).
    simple_form2->label( `Open an issue` ).
    simple_form2->link( text = `You have problems, comments or wishes?`
                 target      = `_blank`
                 href        = `https://github.com/abap2UI5/abap2UI5/issues` ).

    simple_form2->label( `Open a Pull Request` ).
    simple_form2->link( text = `You added a new feature or fixed a bug?`
               target        = `_blank`
               href          = `https://github.com/abap2UI5/abap2UI5/pulls` ).

    simple_form2->label( `` ).
    simple_form2->text( `` ).

*    simple_form2->toolbar( )->title( `Links & More` ).
    simple_form2->label( `Links & More` ).
    simple_form2->link( text   = `Repository on GitHub`
                        target = `_blank`
                        href   = `https://github.com/abap2UI5/abap2UI5` ).
    simple_form2->label( ).
    simple_form2->link( text   = `News on Twitter`
                        target = `_blank`
                        href   = `https://twitter.com/abap2UI5` ).
    simple_form2->label( ).
    simple_form2->link( text   = `Blog Series on SAP Community`
                        target = `_blank`
                        href   = `https://community.sap.com/t5/technology-blogs-by-members/abap2ui5-1-introduction-developing-ui5-apps-purely-in-abap/ba-p/13567635` ).

    client->view_display( page2->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      z2ui5_on_init( ).
      view_display_start( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      TRY.
          DATA(lo_f4) = CAST z2ui5_cl_popup_to_select( client->get_app( client->get( )-s_draft-id_prev_app ) ).
          DATA(ls_result) = lo_f4->result( ).
          IF ls_result-check_confirmed = abap_true.

            ASSIGN ls_result-row->* TO FIELD-SYMBOL(<class>).
            ms_home-classname = <class>.
            view_display_start( ).
            RETURN.
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    z2ui5_on_event( ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN `OPEN_INFO`.
        client->nav_app_call( z2ui5_cl_core_app_info=>factory( ) ).
        RETURN.

      WHEN `BUTTON_CHECK`.
        IF ms_home-class_editable = abap_false.
          ms_home-btn_text       = `check`.
          ms_home-btn_event_id   = `BUTTON_CHECK`.
          ms_home-btn_icon       = `sap-icon://validate`.
          ms_home-class_editable = abap_true.

        ELSE.
          on_event_check( ).
        ENDIF.
        client->view_model_update( ).

      WHEN 'VALUE_HELP'.
        mt_classes = z2ui5_cl_util=>rtti_get_classes_impl_intf( `Z2UI5_IF_APP` ).
        client->nav_app_call( z2ui5_cl_popup_to_select=>factory( mt_classes ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    ms_home-btn_text       = `check`.
    ms_home-btn_event_id   = `BUTTON_CHECK`.
    ms_home-class_editable = abap_true.
    ms_home-btn_icon       = `sap-icon://validate`.
    ms_home-classname      = `Z2UI5_CL_APP_HELLO_WORLD`.

  ENDMETHOD.
ENDCLASS.
