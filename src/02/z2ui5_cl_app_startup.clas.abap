CLASS z2ui5_cl_app_startup DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_app_startup.

    CONSTANTS:
      BEGIN OF cs_event,
        button_check  TYPE string VALUE `BUTTON_CHECK`,
        button_change TYPE string VALUE `BUTTON_CHANGE`,
        open_debug    TYPE string VALUE `OPEN_DEBUG`,
        open_info     TYPE string VALUE `OPEN_INFO`,
        set_config    TYPE string VALUE `SET_CONFIG`,
        close         TYPE string VALUE `CLOSE`,
      END OF cs_event.

    DATA client TYPE REF TO z2ui5_if_client.

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
        " Inverse of class_editable, bound as a plain value to the step-5 link.
        " It exists as its own field on purpose: deriving it in the view with a
        " UI5 expression binding ( {= ... } ) would make the view eval-compiled
        " and break it under a Content-Security-Policy without 'unsafe-eval'.
        link_enabled           TYPE abap_bool,
      END OF ms_home.

    " request handling
    METHODS on_init.
    METHODS on_event.
    METHODS on_event_check.
    METHODS reset_button_state.

    " home page - one method per section
    METHODS render_start.
    METHODS render_header_toolbar
      IMPORTING page TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_quickstart
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_whats_next
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_contribution
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_documentation
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_system_popup.

    " helpers
    METHODS create_layout_form
      IMPORTING
        view          TYPE REF TO z2ui5_cl_ai_xml
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.
    METHODS get_app_url
      IMPORTING
        classname     TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    " Building blocks of the SimpleForm rows above. Private on purpose: this
    " class lives in the public src/02 package, so everything added to its
    " public section joins the framework's stable API contract (rule 5).

    " the section headline every render_* method opens with
    METHODS render_section
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ai_xml
        title TYPE string.

    " a form row of Label + external Link; an empty label renders a blank one,
    " which is how the SimpleForm keeps the link in the value column
    METHODS render_link
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ai_xml
        label TYPE string OPTIONAL
        text  TYPE string
        href  TYPE string.

    " a form row of Label + read-only Text
    METHODS render_text
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ai_xml
        label TYPE string
        text  TYPE string.
ENDCLASS.


CLASS z2ui5_cl_app_startup IMPLEMENTATION.

  METHOD factory.

    result = NEW #( ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      on_init( ).
      render_start( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_init.

    reset_button_state( ).
    ms_home-classname = z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( NEW z2ui5_cl_app_hello_world( ) ).

  ENDMETHOD.

  METHOD on_event.

    DATA li_app_config TYPE REF TO z2ui5_if_app.

    CASE client->get_event( ).

      WHEN cs_event-set_config.
        CREATE OBJECT li_app_config TYPE (`Z2UI5_CL_APP_ICF_CONFIG`).
        client->nav_app_call( li_app_config ).

      WHEN cs_event-open_debug.
        client->message_box_display( `Press CTRL+F12 to open the developer tools` ).

      WHEN cs_event-open_info.
        render_system_popup( ).

      WHEN cs_event-close.
        client->popup_destroy( ).

      WHEN cs_event-button_check.
        on_event_check( ).
        render_start( ).

      WHEN cs_event-button_change.
        reset_button_state( ).
        render_start( ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_event_check.

    DATA li_app_test TYPE REF TO z2ui5_if_app.

    TRY.
        ms_home-classname = z2ui5_cl_a2ui5_context=>c_trim_upper( ms_home-classname ).
        CREATE OBJECT li_app_test TYPE (ms_home-classname).

        client->message_toast_display( `App is ready to start!` ).
        ms_home-btn_text          = `Edit`.
        ms_home-btn_event_id      = cs_event-button_change.
        ms_home-btn_icon          = `sap-icon://edit`.
        ms_home-class_value_state = `Success`.
        ms_home-class_editable    = abap_false.
        ms_home-link_enabled      = abap_true.
        ms_home-url               = get_app_url( ms_home-classname ).

      CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
        ms_home-class_value_state_text = lx->get_text( ).
        ms_home-class_value_state      = `Warning`.
        client->message_box_display( text = ms_home-class_value_state_text
                                     type = `error` ).
    ENDTRY.

  ENDMETHOD.

  METHOD reset_button_state.

    ms_home-btn_text       = `Check`.
    ms_home-btn_event_id   = cs_event-button_check.
    ms_home-btn_icon       = `sap-icon://validate`.
    ms_home-class_editable = abap_true.
    ms_home-link_enabled   = abap_false.
    " drop the previous check's outcome, otherwise the re-opened input
    " still shows the old value state and a stale step-5 link ( `None`
    " rather than CLEAR - the bound value must stay a valid ValueState )
    ms_home-class_value_state = `None`.
    CLEAR: ms_home-url,
           ms_home-class_value_state_text.

  ENDMETHOD.

  METHOD render_start.

    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    DATA(page) = view->open( n  = `View`
                             ns = `mvc`
        )->a( n = `xmlns`
              v = `sap.m`
        )->a( n = `xmlns:mvc`
              v = `sap.ui.core.mvc`
        )->a( n = `xmlns:form`
              v = `sap.ui.layout.form`
        )->a( n = `displayBlock`
              v = `true`
        )->a( n = `height`
              v = `100%`
        )->open( `Shell`
        )->open( `Page`
            )->a( n = `title`
                  v = `abap2UI5 - Building UI5 Apps Purely in ABAP`
            )->a( n = `showNavButton`
                  v = `false` ).

    render_header_toolbar( page ).

    DATA(form) = create_layout_form( page ).
    render_quickstart( form ).
    render_whats_next( form ).
    render_contribution( form ).
    render_documentation( form ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD render_header_toolbar.

    DATA(toolbar) = page->open( `headerContent` ).
    toolbar->leaf( `ToolbarSpacer`
      )->leaf( `Button`
          )->a( n = `text`
                v = `Developer Tools`
          )->a( n = `icon`
                v = `sap-icon://enablement`
          )->a( n = `press`
                v = client->_event( cs_event-open_debug )
      )->leaf( `Button`
          )->a( n = `text`
                v = `System`
          )->a( n = `icon`
                v = `sap-icon://information`
          )->a( n = `press`
                v = client->_event( cs_event-open_info ) ).

    IF z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_app_icf_config` ).
      toolbar->leaf( `Button`
          )->a( n = `text`
                v = `Config`
          )->a( n = `icon`
                v = `sap-icon://settings`
          )->a( n = `press`
                v = client->_event( cs_event-set_config ) ).
    ENDIF.

  ENDMETHOD.

  METHOD render_quickstart.

    render_section( form  = form
                    title = `Quickstart` ).

    form->leaf( `Label` )->a( n = `text`
                              v = `Step 1`
      )->leaf( `Text` )->a( n = `text`
                            v = `Create a new class in your ABAP system`
      )->leaf( `Label` )->a( n = `text`
                             v = `Step 2`
      )->leaf( `Text` )->a( n = `text`
                            v = `Add the interface: Z2UI5_IF_APP`
      )->leaf( `Label` )->a( n = `text`
                             v = `Step 3`
      )->leaf( `Text` )->a( n = `text`
                            v = `Define the view, implement behavior` ).

    render_link( form = form
                 text = `(Example)`
                 href = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/z2ui5_cl_app_hello_world.clas.abap` ).

    form->leaf( `Label` )->a( n = `text`
                              v = `Step 4` ).

    IF ms_home-class_editable = abap_true.
      form->leaf( `Input`
          )->a( n = `placeholder`
                v = `Fill in the class name and press 'Check'`
          )->a( n = `enabled`
                v = client->_bind( ms_home-class_editable )
          )->a( n = `value`
                v = client->_bind( ms_home-classname )
          )->a( n = `valueState`
                v = client->_bind( ms_home-class_value_state )
          )->a( n = `valueStateText`
                v = client->_bind( ms_home-class_value_state_text )
          )->a( n = `submit`
                v = client->_event( ms_home-btn_event_id )
          )->a( n = `width`
                v = `70%` ).
    ELSE.
      form->leaf( `Text` )->a( n = `text`
                               v = ms_home-classname ).
    ENDIF.

    form->leaf( `Label` ).
    form->leaf( `Button`
        )->a( n = `press`
              v = client->_event( ms_home-btn_event_id )
        )->a( n = `text`
              v = client->_bind( ms_home-btn_text )
        )->a( n = `icon`
              v = client->_bind( ms_home-btn_icon )
        )->a( n = `width`
              v = `70%` ).

    " not render_link: this one is bound and additionally disabled until the
    " class name was checked
    form->leaf( `Label` )->a( n = `text`
                              v = `Step 5`
      )->leaf( `Link`
          )->a( n = `text`
                v = `Link to the Application`
          )->a( n = `target`
                v = `_blank`
          )->a( n = `href`
                v = client->_bind( ms_home-url )
          )->a( n = `enabled`
                v = client->_bind( ms_home-link_enabled ) ).

  ENDMETHOD.

  METHOD render_whats_next.

    render_section( form  = form
                    title = `What's next?` ).

    " the samples repository renamed its overview app from z2ui5_cl_demo_app_g00
    " to z2ui5_cl_smp_app_000 - check the current name first, keep the old one as
    " a fallback so an older samples installation still gets the button
    DATA(lv_class_samples) = COND string(
      WHEN z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_smp_app_000` ) THEN `z2ui5_cl_smp_app_000`
      WHEN z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_demo_app_g00` ) THEN `z2ui5_cl_demo_app_g00` ).

    IF lv_class_samples IS NOT INITIAL.
      form->leaf( `Label` )->a( n = `text`
                                v = `Start Developing` ).
      form->leaf( `Button`
          )->a( n = `text`
                v = `Explore Code Samples`
          )->a( n = `press`
                v = client->follow_up_action( val   = client->cs_event-open_new_tab
                                              t_arg = VALUE #( ( get_app_url( lv_class_samples ) ) ) )
          )->a( n = `width`
                v = `70%` ).
    ELSE.
      render_link( form  = form
                   label = `Install the sample repository`
                   text  = `And explore more than 250 sample apps...`
                   href  = `https://github.com/abap2UI5/samples` ).
    ENDIF.

  ENDMETHOD.

  METHOD render_contribution.

    render_section( form  = form
                    title = `Contribution` ).

    render_link( form  = form
                 label = `Open an issue`
                 text  = `You have problems, comments or wishes?`
                 href  = `https://github.com/abap2UI5/abap2UI5/issues` ).

    render_link( form  = form
                 label = `Open a Pull Request`
                 text  = `You added a new feature or fixed a bug?`
                 href  = `https://github.com/abap2UI5/abap2UI5/pulls` ).

  ENDMETHOD.

  METHOD render_documentation.

    render_section( form  = form
                    title = `Documentation` ).

    render_link( form = form
                 text = `abap2UI5.org`
                 href = `https://abap2UI5.org` ).

  ENDMETHOD.

  METHOD render_system_popup.

    DATA(popup) = z2ui5_cl_ai_xml=>factory( ).

    DATA(dialog) = popup->open( n  = `FragmentDefinition`
                                ns = `core`
        )->a( n = `xmlns`
              v = `sap.m`
        )->a( n = `xmlns:core`
              v = `sap.ui.core`
        )->a( n = `xmlns:form`
              v = `sap.ui.layout.form`
        )->open( `Dialog`
            )->a( n = `title`
                  v = `abap2UI5 - System Information`
            )->a( n = `afterClose`
                  v = client->_event( cs_event-close ) ).

    DATA(form) = create_layout_form( dialog->open( `content` ) ).
    DATA(ls_client) = client->get( ).

    render_section( form  = form
                    title = `Frontend` ).
    render_text( form  = form
                 label = `UI5 Version`
                 text  = ls_client-s_ui5-version ).
    form->leaf( `Label` )->a( n = `text`
                              v = `Launchpad active` ).
    form->leaf( `CheckBox`
        )->a( n = `selected`
              v = z2ui5_cl_ai_xml=>as_bool( ls_client-check_launchpad_active )
        )->a( n = `enabled`
              v = `false` ).

    render_section( form  = form
                    title = `Backend` ).
    form->leaf( `Label` )->a( n = `text`
                              v = `ABAP for Cloud` ).
    form->leaf( `CheckBox`
        )->a( n = `selected`
              v = z2ui5_cl_ai_xml=>as_bool( z2ui5_cl_a2ui5_context=>check_abap_cloud( ) )
        )->a( n = `enabled`
              v = `false` ).
    render_text( form  = form
                 label = `User Exit`
                 text  = z2ui5_cl_exit=>get_user_exit_class( ) ).

    render_section( form  = form
                    title = `abap2UI5` ).
    render_text( form  = form
                 label = `Version`
                 text  = z2ui5_if_app=>version ).
    render_text( form  = form
                 label = `Draft Entries (own)`
                 text  = CONV string( NEW z2ui5_cl_core_srv_draft( )->count_entries( ) ) ).

    dialog->open( `endButton`
        )->leaf( `Button`
            )->a( n = `text`
                  v = `Close`
            )->a( n = `press`
                  v = client->_event( cs_event-close )
            )->a( n = `type`
                  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_section.

    form->open( `Toolbar`
        )->leaf( `Title` )->a( n = `text`
                               v = title
      )->shut( ).

  ENDMETHOD.

  METHOD render_link.

    form->leaf( `Label` ).
    IF label IS NOT INITIAL.
      form->a( n = `text`
               v = label ).
    ENDIF.

    form->leaf( `Link`
        )->a( n = `text`
              v = text
        )->a( n = `target`
              v = `_blank`
        )->a( n = `href`
              v = href ).

  ENDMETHOD.

  METHOD render_text.

    form->leaf( `Label` )->a( n = `text`
                              v = label
      )->leaf( `Text` )->a( n = `text`
                            v = text ).

  ENDMETHOD.

  METHOD create_layout_form.

    result = view->open( n  = `SimpleForm`
                         ns = `form`
        )->a( n = `editable`
              v = `true`
        )->a( n = `layout`
              v = `ResponsiveGridLayout`
        )->a( n = `labelSpanXL`
              v = `4`
        )->a( n = `labelSpanL`
              v = `3`
        )->a( n = `labelSpanM`
              v = `4`
        )->a( n = `labelSpanS`
              v = `12`
        )->a( n = `adjustLabelSpan`
              v = `false`
        )->a( n = `emptySpanXL`
              v = `0`
        )->a( n = `emptySpanL`
              v = `4`
        )->a( n = `emptySpanM`
              v = `0`
        )->a( n = `emptySpanS`
              v = `0`
        )->a( n = `columnsXL`
              v = `1`
        )->a( n = `columnsL`
              v = `1`
        )->a( n = `columnsM`
              v = `1`
        )->a( n = `singleContainerFullSize`
              v = `false`
        )->open( n  = `content`
                 ns = `form` ).

  ENDMETHOD.

  METHOD get_app_url.

    DATA(ls_config) = client->get( )-s_config.
    result = z2ui5_cl_a2ui5_context=>app_get_url( classname = classname
                                                  origin    = ls_config-origin
                                                  pathname  = ls_config-pathname
                                                  search    = ls_config-search
                                                  hash      = ls_config-hash ).

  ENDMETHOD.

ENDCLASS.
