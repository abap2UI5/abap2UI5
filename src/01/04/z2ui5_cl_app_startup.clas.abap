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

    DATA client TYPE REF TO z2ui5_if_ui5_client.

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
      IMPORTING page TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_quickstart
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_whats_next
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_contribution
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_documentation
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_system_popup.

    " helpers
    METHODS create_layout_form
      IMPORTING
        view          TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.
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
        form  TYPE REF TO z2ui5_cl_ui5_view_builder
        title TYPE string.

    " a form row of Label + external Link; an empty label renders a blank one,
    " which is how the SimpleForm keeps the link in the value column
    METHODS render_link
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ui5_view_builder
        label TYPE string OPTIONAL
        text  TYPE string
        href  TYPE string.

    " a form row of Label + read-only Text
    METHODS render_text
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ui5_view_builder
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

    CASE client->get( )-event.

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

    DATA(view) = z2ui5_cl_ui5_view_builder=>new( ).

    DATA(page) = view->ele( n  = `View`
                            ns = `mvc`
        )->att( n = `xmlns`
                v = `sap.m`
        )->att( n = `xmlns:mvc`
                v = `sap.ui.core.mvc`
        )->att( n = `xmlns:form`
                v = `sap.ui.layout.form`
        )->att( n = `displayBlock`
                v = `true`
        )->att( n = `height`
                v = `100%`
        )->ele( `Shell`
        )->ele( `Page`
            )->att( n = `title`
                    v = `abap2UI5 - Building UI5 Apps Purely in ABAP`
            )->att( n = `showNavButton`
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

    DATA(toolbar) = page->ele( `headerContent` ).

    " the spacer carries no attributes at all, so add( ) is enough - the two
    " buttons bind an event, so they are opened with ele( ) and closed again
    toolbar->add( `ToolbarSpacer`
      )->ele( `Button`
          )->att( n = `text`
                  v = `Developer Tools`
          )->att( n = `icon`
                  v = `sap-icon://enablement`
          )->att( n = `press`
                  v = client->_event( cs_event-open_debug )
      )->end(
      )->ele( `Button`
          )->att( n = `text`
                  v = `System`
          )->att( n = `icon`
                  v = `sap-icon://information`
          )->att( n = `press`
                  v = client->_event( cs_event-open_info ) ).

    IF z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_app_icf_config` ).
      toolbar->ele( `Button`
          )->att( n = `text`
                  v = `Config`
          )->att( n = `icon`
                  v = `sap-icon://settings`
          )->att( n = `press`
                  v = client->_event( cs_event-set_config ) ).
    ENDIF.

  ENDMETHOD.

  METHOD render_quickstart.

    render_section( form  = form
                    title = `Quickstart` ).

    " every row of steps 1-3 is a leaf with literal attributes only, so it is
    " one add( ) each and the chain never leaves the form
    form->add( n     = `Label`
               t_att = VALUE #( ( `text=Step 1` ) )
      )->add( n     = `Text`
              t_att = VALUE #( ( `text=Create a new class in your ABAP system` ) )
      )->add( n     = `Label`
              t_att = VALUE #( ( `text=Step 2` ) )
      )->add( n     = `Text`
              t_att = VALUE #( ( `text=Add the interface: Z2UI5_IF_APP` ) )
      )->add( n     = `Label`
              t_att = VALUE #( ( `text=Step 3` ) )
      )->add( n     = `Text`
              t_att = VALUE #( ( `text=Define the view, implement behavior` ) ) ).

    render_link( form = form
                 text = `(Example)`
                 href = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/z2ui5_cl_app_hello_world.clas.abap` ).

    form->add( n     = `Label`
               t_att = VALUE #( ( `text=Step 4` ) ) ).

    IF ms_home-class_editable = abap_true.
      form->ele( `Input`
          )->att( n = `placeholder`
                  v = `Fill in the class name and press 'Check'`
          )->att( n = `enabled`
                  v = client->_bind( ms_home-class_editable )
          )->att( n = `value`
                  v = client->_bind( ms_home-classname )
          )->att( n = `valueState`
                  v = client->_bind( ms_home-class_value_state )
          )->att( n = `valueStateText`
                  v = client->_bind( ms_home-class_value_state_text )
          )->att( n = `submit`
                  v = client->_event( ms_home-btn_event_id )
          )->att( n = `width`
                  v = `70%` ).
    ELSE.
      form->ele( `Text` )->att( n = `text`
                                v = ms_home-classname ).
    ENDIF.

    form->add( `Label` ).
    form->ele( `Button`
        )->att( n = `press`
                v = client->_event( ms_home-btn_event_id )
        )->att( n = `text`
                v = client->_bind( ms_home-btn_text )
        )->att( n = `icon`
                v = client->_bind( ms_home-btn_icon )
        )->att( n = `width`
                v = `70%` ).

    " not render_link: this one is bound and additionally disabled until the
    " class name was checked
    form->add( n     = `Label`
               t_att = VALUE #( ( `text=Step 5` ) ) ).
    form->ele( `Link`
        )->att( n = `text`
                v = `Link to the Application`
        )->att( n = `target`
                v = `_blank`
        )->att( n = `href`
                v = client->_bind( ms_home-url )
        )->att( n = `enabled`
                v = client->_bind( ms_home-link_enabled ) ).

  ENDMETHOD.

  METHOD render_whats_next.

    render_section( form  = form
                    title = `What's next?` ).

    DATA(lv_class_samples) = COND string(
      WHEN z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_demo_app_g00` ) THEN `z2ui5_cl_demo_app_g00` ).

    IF lv_class_samples IS NOT INITIAL.
      form->add( n     = `Label`
                 t_att = VALUE #( ( `text=Start Developing` ) ) ).
      form->ele( `Button`
          )->att( n = `text`
                  v = `Explore Code Samples`
          )->att( n = `press`
                  v = client->_event_client( val   = client->cs_event-open_new_tab
                                             t_arg = VALUE #( ( get_app_url( lv_class_samples ) ) ) )
          )->att( n = `width`
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

    DATA(popup) = z2ui5_cl_ui5_view_builder=>new( ).

    DATA(dialog) = popup->ele( n  = `FragmentDefinition`
                               ns = `core`
        )->att( n = `xmlns`
                v = `sap.m`
        )->att( n = `xmlns:core`
                v = `sap.ui.core`
        )->att( n = `xmlns:form`
                v = `sap.ui.layout.form`
        )->ele( `Dialog`
            )->att( n = `title`
                    v = `abap2UI5 - System Information`
            )->att( n = `afterClose`
                    v = client->_event( cs_event-close ) ).

    DATA(form) = create_layout_form( dialog->ele( `content` ) ).
    DATA(ls_client) = client->get( ).

    render_section( form  = form
                    title = `Frontend` ).
    render_text( form  = form
                 label = `UI5 Version`
                 text  = ls_client-s_ui5-version ).
    form->add( n     = `Label`
               t_att = VALUE #( ( `text=Launchpad active` ) ) ).
    " an ABAP boolean goes in as b - the predecessor needed as_bool( ) here
    form->ele( `CheckBox`
        )->att( n = `selected`
                b = ls_client-check_launchpad_active
        )->att( n = `enabled`
                v = `false` ).

    render_section( form  = form
                    title = `Backend` ).
    form->add( n     = `Label`
               t_att = VALUE #( ( `text=ABAP for Cloud` ) ) ).
    form->ele( `CheckBox`
        )->att( n = `selected`
                b = z2ui5_cl_a2ui5_context=>check_abap_cloud( )
        )->att( n = `enabled`
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

    dialog->ele( `endButton`
        )->ele( `Button`
            )->att( n = `text`
                    v = `Close`
            )->att( n = `press`
                    v = client->_event( cs_event-close )
            )->att( n = `type`
                    v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_section.

    " no trailing end( ) - `form` still points at the form content, so the
    " chain may simply stop on the Title
    form->ele( `Toolbar`
        )->ele( `Title`
            )->att( n = `text`
                    v = title ).

  ENDMETHOD.

  METHOD render_link.

    " the label is optional, so its element is kept in a variable and the
    " attribute is set on it - att( ) always lands on the element it is
    " called on, never on whatever was added last
    DATA(row_label) = form->ele( `Label` ).
    IF label IS NOT INITIAL.
      row_label->att( n = `text`
                      v = label ).
    ENDIF.

    form->ele( `Link`
        )->att( n = `text`
                v = text
        )->att( n = `target`
                v = `_blank`
        )->att( n = `href`
                v = href ).

  ENDMETHOD.

  METHOD render_text.

    form->ele( `Label`
        )->att( n = `text`
                v = label
      )->end(
      )->ele( `Text`
          )->att( n = `text`
                  v = text ).

  ENDMETHOD.

  METHOD create_layout_form.

    result = view->ele( n  = `SimpleForm`
                        ns = `form`
        )->att( n = `editable`
                v = `true`
        )->att( n = `layout`
                v = `ResponsiveGridLayout`
        )->att( n = `labelSpanXL`
                v = `4`
        )->att( n = `labelSpanL`
                v = `3`
        )->att( n = `labelSpanM`
                v = `4`
        )->att( n = `labelSpanS`
                v = `12`
        )->att( n = `adjustLabelSpan`
                v = `false`
        )->att( n = `emptySpanXL`
                v = `0`
        )->att( n = `emptySpanL`
                v = `4`
        )->att( n = `emptySpanM`
                v = `0`
        )->att( n = `emptySpanS`
                v = `0`
        )->att( n = `columnsXL`
                v = `1`
        )->att( n = `columnsL`
                v = `1`
        )->att( n = `columnsM`
                v = `1`
        )->att( n = `singleContainerFullSize`
                v = `false`
        )->ele( n  = `content`
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
