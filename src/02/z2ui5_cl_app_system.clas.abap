CLASS z2ui5_cl_app_system DEFINITION PUBLIC.
  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory_error
      IMPORTING
        error           TYPE REF TO cx_root
        app             TYPE REF TO z2ui5_if_app OPTIONAL
        kind            TYPE string OPTIONAL
        "  server          TYPE REF TO z2ui5_lcl_runtime
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_app_system.
    DATA:
      BEGIN OF ms_error,
        x_error   TYPE REF TO cx_root,
        app       TYPE REF TO z2ui5_if_app,
        classname TYPE string,
        kind      TYPE string,
      END OF ms_error.

    DATA:
      BEGIN OF ms_home,
        is_initialized         TYPE abap_bool,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.
  PROTECTED SECTION.

    METHODS on_event_error
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS on_event_home
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS on_event_demos
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
  PRIVATE SECTION.
ENDCLASS.

CLASS z2ui5_cl_app_system IMPLEMENTATION.
  METHOD factory_error.


    r_result = NEW #( ).

    r_result->ms_error-x_error = error.
    r_result->ms_error-app     = app.
    r_result->ms_error-kind    = kind.


  ENDMETHOD.
  METHOD z2ui5_if_app~on_event.


    IF ms_error-x_error IS BOUND.
      on_event_error( client ).
    ELSE.
      CASE client->controller( )->get_active_page( ).
        WHEN 'DEMOS'.
          on_event_demos( client ).
        WHEN OTHERS.
          on_event_home( client ).

      ENDCASE.
    ENDIF.


  ENDMETHOD.
  METHOD z2ui5_if_app~set_view.


    IF ms_error-x_error IS NOT BOUND.

      DATA(view2) = view->factory_selscreen_page( name = 'START' title = 'ABAP2UI5 - Home'
            )->begin_of_block( 'Welcome to ABAP2UI5!'
          )->begin_of_group( 'Quick Start:'
                 )->label( 'Step 1'
                 )->text( 'Create a new global class in the abap system'
                 )->label( 'Step 2'
                 )->text( 'Implement the interface Z2UI5_IF_APP'
                 )->label( 'Step 3'
                 )->text( 'Define the views in the method set_view and the behaviour in the method on_event '
                 )->label( 'Step 4' ).

      IF ms_home-class_editable = abap_true.
        view2->input(
                       value          = ms_home-classname
                       placeholder    = 'fill in the classname and press check'
                       value_state      = ms_home-class_value_state
                       value_state_text = ms_home-class_value_state_text
                       editable         = ms_home-class_editable
                  ).
      ELSE.
        view2->text( ms_home-classname ).
      ENDIF.
      view2->button( text = ms_home-btn_text on_press_id = ms_home-btn_event_id  icon = ms_home-btn_icon   "type = view->cs-button-type-
                )->label( 'Step 5' ).

      IF ms_home-class_editable = abap_false.
        view2->link( text = 'Link to the Application'
                href = _=>get_server_info(  app = ms_home-classname )-url_app " 'https://' && lv_url && '' && '?sap-client=' && lv_tenant && '&amp;app=' && ms_home-classname
             ).
      ENDIF.
      view2->end_of_group(
     )->begin_of_group( 'More Information & Support'
      )->label( 'Try it out'
       )->button( text = 'Demos & Code Examples' on_press_id = 'BUTTON_DEMO'
         )->label( 'Repository'
        )->link( text = '@github' href = 'https://github.com/oblomov-dev/abap2ui5'
         )->label( 'News, Contact and Feedback'
        )->link( text = '@twitter' href = 'https://twitter.com/OblomovDev'
*        )->label( 'Example 1'
*        )->link( text = 'Z2UI5_CL_APP_DEMO_01' href = get_app_url( i_view = view app = 'z2ui5_cl_app_demo_01' )
*        )->label( 'Example 2'
*        )->link( text = 'Z2UI5_CL_APP_DEMO_02' href = get_app_url( i_view = view app = 'z2ui5_cl_app_demo_02' )
    )->end_of_group(
  )->end_of_block(
  )->end_of_screen( ).


      DATA(view3) = view->factory_selscreen_page(
                      name              = 'DEMOS'
                      title             = 'ABAP2UI5 - Demos & Code Examples'
                      event_nav_back_id = 'BUTTON_BACK'
            )->begin_of_block( 'Demos & Code Examples'
          )->begin_of_group( 'Selection-Screen'
                 )->label( 'Demo 01'
                 )->button( text = 'Basic Example' on_press_id = 'BTN_SELSCREEN_BASIC'
                 )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_SELSCREEN_BASIC_CODE'
                  )->link( enabled = abap_false text = 'ADT' href = ''
                  )->label( 'Demo 02'
                 )->button( text = 'Detailed Example' on_press_id = 'BTN_SELSCREEN_COMPLEX'
                  )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_SELSCREEN_COMPLEX_CODE'
                  )->link( enabled = abap_false text = 'ADT' href = ''
              )->end_of_group(
          )->begin_of_group( 'Write (HTML Output)'
                 )->label( 'Demo 01'
                 )->button( text = 'Basic Example' on_press_id = 'BTN_HTML_BASIC'
                 )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_HTML_BASIC_CODE'
                 )->link( text = 'ADT' href = '' enabled = abap_false
                  )->label( 'Demo 02'
                 )->button( text = 'CL_DEMO_OUTPUT (OnPrem)' on_press_id = 'BTN_HTML_DEMO_OUTPUT' enabled = abap_false
                 )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_HTML_DEMO_OUTPUT_CODE' enabled = abap_true
                 )->link( text = 'ADT' href = '' enabled = abap_false
                )->end_of_group( ).

           return.

*                   )->begin_of_group( 'ALV'
*                 )->label( 'Demo 01'
*                 )->button( text = 'Basic Example' on_press_id = 'BTN_SELSCREEN_COMPLEX' enabled = abap_false
*                  )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_HTML_DETAILED_CODE' enabled = abap_false
*                 )->link( text = 'ADT' href = '' enabled = abap_false
*                  )->label( 'Demo 02'
*                 )->button( text = 'Toolbar & Editable' on_press_id = 'BTN_HTML_BASIC' enabled = abap_false
*                  )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_HTML_DETAILED_CODE' enabled = abap_false
*                 )->link( text = 'ADT' href = '' enabled = abap_false
*                )->end_of_group(
**                    )->begin_of_group( 'Event Handling'
**                 )->label( 'Demo 01'
**                 )->button( text = 'Switch between Views & Apps' on_press_id = 'BTN_SELSCREEN_COMPLEX'
**                 )->link( text = 'Code Snippet' href = 'https://twitter.com/OblomovDev'
**                  )->label( 'Demo 02'
**                 )->button( text = 'Popups' on_press_id = 'BTN_HTML_BASIC'
**                 )->link( text = 'Code Snippet' href = 'https://twitter.com/OblomovDev'
**                )->end_of_group(
*                    )->begin_of_group( 'Tools'
**                 )->label( 'Demo 01'
**                 )->button( text = 'Browser (iframe)' on_press_id = 'BTN_TOOLS_BROWSER'
**                          )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_TOOLS_BROWSER_CODE'
**                 )->link( text = 'ADT' href = '' enabled = abap_false
*                 )->label( 'Demo 01'
*                 )->button( text = 'Code Editor (XML,JSON,ABAP...)' on_press_id = 'BTN_TOOLS_EDITOR'
*                 )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_TOOLS_EDITOR_CODE'
*                  )->link( text = 'ADT' href = '' enabled = abap_false
*                    )->label( 'Demo 02'
*                 )->button( text = 'Text (Upload,Download)' on_press_id = 'BTN_TOOLS_TEXT'
*                 )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_TOOLS_TEXT_CODE'
*                  )->link( text = 'ADT' href = '' enabled = abap_false
*                    )->label( 'Demo 03'
*                 )->button( text = 'Table Maintenance' on_press_id = 'BTN_TOOLS_TABLE_EDIT'
*                 )->button( icon = 'sap-icon://source-code' on_press_id = 'BTN_TOOLS_TABLE_EDIT_CODE'
*                  )->link( text = 'ADT' href = '' enabled = abap_false
*                )->end_of_group(
*        )->end_of_block(
*        )->end_of_screen( ).

    ELSE.

      view->factory_selscreen_page( name = 'ERROR' title = 'abap2ui5 - error'
          )->begin_of_block( SWITCH #(  ms_error-kind
                  WHEN 'USER' THEN 'Application Error - check your code'
                  WHEN 'CUSTOMIZING' THEN 'Customizing Error - check your code in method set_screen'
                  ELSE 'System Error - please restart the framework')
             )->begin_of_group( ms_error-x_error->get_text( )
             )->label( 'Classname'
             )->text( ms_error-classname
            )->end_of_group(
           )->end_of_block(
           )->begin_of_footer(
             )->Begin_of_overflow_toolbar(
             )->button( text = 'Home'    on_press_id = 'BUTTON_HOME'     type = 'Reject'
             )->Toolbar_spacer(
             )->button( text = 'Neustart' on_press_id = 'BUTTON_RESTART' type = 'Accept'
           )->end_of_footer(
         )->end_of_screen( ).


    ENDIF.


  ENDMETHOD.
  METHOD on_event_error.


    ms_error-classname = _=>get_classname_by_ref( ms_error-app ).

    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_RESTART'.
        DATA li_app TYPE REF TO z2ui5_if_app.
        CREATE OBJECT li_app TYPE (ms_error-classname).
        client->controller( )->nav_to_app( li_app  ).

      WHEN 'BUTTON_HOME'.
        client->controller( )->exit_to_home( ).

    ENDCASE.


  ENDMETHOD.
  METHOD on_event_home.


    DATA li_app TYPE REF TO z2ui5_if_app.

    IF ms_home-is_initialized = abap_false.
      ms_home-is_initialized = abaP_true.
      ms_home-btn_text = 'check'.
      ms_home-btn_event_id = 'BUTTON_CHECK'.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = 'sap-icon://validate'.
    ENDIF.

    ms_home-class_value_state_text = ''.
    ms_home-class_value_state = ''.

    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_GO'.
        li_app = NEW z2ui5_cl_app_demo_01( ).
        client->popup( )->message_box( type = 'warning' text = 'App wird gestartet' ).
        client->controller( )->nav_to_app( li_app  ).


      WHEN 'BUTTON_CHANGE'.
        ms_home-btn_text = 'check'.
        ms_home-btn_event_id = 'BUTTON_CHECK'.
        ms_home-btn_icon = 'sap-icon://validate'.
        ms_home-class_editable = abap_true.

      WHEN 'BUTTON_CHECK'.

        TRY.
            DATA li_app_test TYPE REF TO z2ui5_if_app.
            ms_home-classname = to_upper( ms_home-classname ).
            CREATE OBJECT li_app_test TYPE (ms_home-classname).

            client->popup( )->message_toast( 'App is ready to start!' ).
            ms_home-btn_text = 'edit'.
            ms_home-btn_event_id = 'BUTTON_CHANGE'.
            ms_home-btn_icon = 'sap-icon://edit'.
            ms_home-class_value_state = z2ui5_if_view=>cs-input-value_state-success.
            ms_home-class_editable = abap_false.

          CATCH cx_root INTO DATA(lx).
            ms_home-class_value_state_text = lx->get_text( ).
            ms_home-class_value_state = z2ui5_if_view=>cs-input-value_state-warning.
            client->popup( )->message_box(
                text = ms_home-class_value_state_text
                type = z2ui5_if_view=>cs-message_box-type-error
                 ).
        ENDTRY.

      WHEN 'BUTTON_DEMO'.
        client->controller( )->nav_to_page( name = 'DEMOS' ).


    ENDCASE.


  ENDMETHOD.

  METHOD on_event_demos.


    CASE client->event( )->get_id( ).

      WHEN 'BUTTON_BACK'.
        client->controller( )->nav_to_page( 'START' ).

      WHEN 'BTN_SELSCREEN_BASIC'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_01( ) ).

      WHEN 'BTN_SELSCREEN_BASIC_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_01' )-url_abap ) ).

      WHEN 'BTN_SELSCREEN_COMPLEX'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_02( ) ).

      WHEN 'BTN_SELSCREEN_COMPLEX_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_02' )-url_abap ) ).

      WHEN 'BTN_TOOLS_BROWSER'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_04( ) ).

      WHEN 'BTN_TOOLS_BROWSER_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_04' )-url_abap ) ).

      WHEN 'BTN_TOOLS_EDITOR'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_05( ) ).

      WHEN 'BTN_TOOLS_EDITOR_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_05' )-url_abap  ) ).

      WHEN 'BTN_TOOLS_TEXT'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_06( ) ).

      WHEN 'BTN_TOOLS_TEXT_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_06' )-url_abap ) ).

      WHEN 'BTN_TOOLS_TABLE_EDIT'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_08( ) ).

      WHEN 'BTN_TOOLS_TABLE_EDIT_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_08' )-url_abap ) ).

      WHEN 'BTN_HTML_DEMO_OUTPUT'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_07( ) ).

      WHEN 'BTN_HTML_DEMO_OUTPUT_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_07' )-url_abap ) ).

      WHEN 'BTN_HTML_BASIC'.
        client->controller( )->nav_to_app( NEW z2ui5_cl_app_demo_03( ) ).

      WHEN 'BTN_HTML_BASIC_CODE'.
        client->controller( )->nav_to_app(
            z2ui5_cl_app_demo_04=>create( _=>get_server_info( 'Z2UI5_CL_APP_DEMO_03' )-url_abap ) ).

      WHEN OTHERS.
        client->controller( )->nav_to_page( 'DEMOS' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
