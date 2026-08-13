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
        set_config    TYPE string VALUE `SET_CONFIG`,
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

    " home page - one method per section. These are public because they were
    " shipped that way; new sections go into the private section below, which
    " is where a page internal belongs (rule 5).
    METHODS render_start.
    METHODS render_header_toolbar
      IMPORTING page TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_quickstart
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_whats_next
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.
    METHODS render_contribution
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.

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

    " the documentation, one section below the samples: whoever came for the
    " apps is exactly who wants the guides next
    METHODS render_docs_link
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.

    " the closing block of the page: what this system runs on
    METHODS render_system_info
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.

    " the section headline every render_* method opens with. small = a level
    " below the others, for a block that closes the page rather than asking
    " for something
    METHODS render_section
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ai_xml
        title TYPE string
        small TYPE abap_bool DEFAULT abap_false.

    " an empty row - a Label with nothing after it is how a SimpleForm gets
    " one, and the only way to put air between two blocks of the same form
    METHODS render_spacer
      IMPORTING form TYPE REF TO z2ui5_cl_ai_xml.

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

    " the column the link occupies in an icon row, so what follows it starts at
    " the same place in every row - the alignment the samples app has
    CONSTANTS c_link_width TYPE string VALUE `12rem`.

    " the two icons the page names twice - once in the title row, once in the
    " Documentation section - so the header and the section cannot drift apart
    CONSTANTS c_icon_docs TYPE string VALUE `sap-icon://learning-assistant`.
    CONSTANTS c_icon_repo TYPE string VALUE `sap-icon://globe`.

    " a form row of Label + [ icon, link ] - the shape the sample rows and the
    " documentation row share. Returns the HBox, so the caller can append
    " whatever else its own row has to say behind the link
    METHODS render_icon_row
      IMPORTING
        form          TYPE REF TO z2ui5_cl_ai_xml
        label         TYPE string OPTIONAL
        icon          TYPE string
        text          TYPE string
        href          TYPE string
        new_tab       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    " one form row per sample repository: icon, repository name and what is in
    " it. The name is the link - to the overview app when the repository is
    " installed on this system, to GitHub when it is not, and in that case the
    " row says so
    METHODS render_samples
      IMPORTING
        form      TYPE REF TO z2ui5_cl_ai_xml
        label     TYPE string
        icon      TYPE string
        name      TYPE string
        descr     TYPE string
        href      TYPE string
        class     TYPE string
        class_old TYPE string OPTIONAL.

    " the press wire of a button whose target is EXTERNAL: a Button carries no
    " href, and cs_event-open_new_tab is same-origin only (isValidRedirectURL),
    " so the new tab is opened by the URLHELPER frontend action - client-side,
    " inside the click handler, which is what keeps the popup blocker quiet
    METHODS open_url
      IMPORTING
        href          TYPE string
      RETURNING
        VALUE(result) TYPE string.
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

        client->message_toast_display( `Your app is ready - open it with the link in step 5!` ).
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
        )->a( n = `xmlns:core`
              v = `sap.ui.core`
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
    render_docs_link( form ).
    render_contribution( form ).
    render_system_info( form ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD render_header_toolbar.

    " icons only, the way the samples app carries them - the title row is not
    " the place for four labels, and what each one does is in its tooltip
    DATA(toolbar) = page->open( `headerContent` ).
    toolbar->leaf( `ToolbarSpacer`
      )->leaf( `Button`
          )->a( n = `icon`
                v = c_icon_docs
          )->a( n = `tooltip`
                v = `Documentation - guides, tutorials and the API reference on abap2UI5.org`
          )->a( n = `press`
                v = open_url( `https://abap2UI5.org` )
      )->leaf( `Button`
          )->a( n = `icon`
                v = c_icon_repo
          )->a( n = `tooltip`
                v = `The abap2UI5 repository on GitHub - source code, issues, releases and the abapGit installation`
          )->a( n = `press`
                v = open_url( `https://github.com/abap2UI5/abap2UI5` )
      )->leaf( `Button`
          )->a( n = `icon`
                v = `sap-icon://enablement`
          )->a( n = `tooltip`
                v = `Developer Tools`
          )->a( n = `press`
                v = client->_event( cs_event-open_debug ) ).

    IF z2ui5_cl_a2ui5_context=>rtti_check_class_exists( `z2ui5_cl_app_icf_config` ).
      toolbar->leaf( `Button`
          )->a( n = `icon`
                v = `sap-icon://settings`
          )->a( n = `tooltip`
                v = `Configuration`
          )->a( n = `press`
                v = client->_event( cs_event-set_config ) ).
    ENDIF.

  ENDMETHOD.

  METHOD render_docs_link.

    " its own section, so the samples above get their separator back and the
    " documentation is what the page says right after them - same row shape as
    " a sample repository, and the same two icons the title row carries
    render_section( form  = form
                    title = `Documentation` ).

    render_icon_row( form    = form
                     label   = `Docs`
                     icon    = c_icon_docs
                     text    = `abap2UI5.org`
                     href    = `https://abap2UI5.org`
                     new_tab = abap_true
      )->leaf( `Text`
          )->a( n = `text`
                v = `Guides, tutorials and the API reference - from your first app to the full client API`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).

    render_icon_row( form    = form
                     label   = `GitHub`
                     icon    = c_icon_repo
                     text    = `abap2UI5/abap2UI5`
                     href    = `https://github.com/abap2UI5/abap2UI5`
                     new_tab = abap_true
      )->leaf( `Text`
          )->a( n = `text`
                v = `The repository itself - source code, issues, releases, and what abapGit installs from`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).

  ENDMETHOD.

  METHOD render_quickstart.

    render_section( form  = form
                    title = `Quickstart - your first app in 5 steps` ).

    form->leaf( `Label` )->a( n = `text`
                              v = `Step 1`
      )->leaf( `Text` )->a( n = `text`
                            v = `Create a new class in your ABAP system`
      )->leaf( `Label` )->a( n = `text`
                             v = `Step 2`
      )->leaf( `Text` )->a( n = `text`
                            v = `Add the interface Z2UI5_IF_APP - that is all it takes`
      )->leaf( `Label` )->a( n = `text`
                             v = `Step 3`
      )->leaf( `Text` )->a( n = `text`
                            v = `Define the view and implement the behavior - in pure ABAP` ).

    render_link( form = form
                 text = `See a complete example: Hello World`
                 href = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/z2ui5_cl_app_hello_world.clas.abap` ).

    form->leaf( `Label` )->a( n = `text`
                              v = `Step 4` ).

    IF ms_home-class_editable = abap_true.
      form->leaf( `Input`
          )->a( n = `placeholder`
                v = `Enter your class name and press 'Check'`
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
                v = `Open your application in a new tab`
          )->a( n = `target`
                v = `_blank`
          )->a( n = `href`
                v = client->_bind( ms_home-url )
          )->a( n = `enabled`
                v = client->_bind( ms_home-link_enabled ) ).

    " the five steps are one thought - let it end before the next headline
    render_spacer( form ).

  ENDMETHOD.

  METHOD render_whats_next.

    render_section( form  = form
                    title = `What's next? - 580+ Apps to Explore` ).

    " one row per sample repository. Each repository is installed separately
    " with abapGit, so every row answers the same question on its own: is the
    " overview app of that repository on THIS system? Then the name links to
    " it - otherwise to the repository on GitHub, where the installation
    " starts, and the row is marked as not installed. All three of them renamed
    " their overview app (z2ui5_cl_demo_app_g00 -> z2ui5_cl_smp_app_000,
    " z2ui5_cl_dmo_app_overview -> z2ui5_cl_smpc_app_overview and
    " z2ui5_cl_smpe_app_00 -> z2ui5_cl_smps_app_00), so they pass the old name
    " as a fallback: an installation that predates the rename still links to
    " its app.
    " The descriptions are the GitHub "About" text of each repository word for
    " word, so the page and the repository say the same thing - with the em
    " dash written as a hyphen, because ABAP source here is 7-bit ASCII.
    render_samples(
        form      = form
        label     = `Samples`
        icon      = `sap-icon://lightbulb`
        name      = `samples`
        descr     = `Learn the abap2UI5 basics - 340+ ready-to-run apps, from a two-line Hello World to complete applications`
        href      = `https://github.com/abap2UI5/samples`
        class     = `z2ui5_cl_smp_app_000`
        class_old = `z2ui5_cl_demo_app_g00` ).

    render_samples(
        form      = form
        label     = `Controls`
        icon      = `sap-icon://palette`
        name      = `samples-controls`
        descr     = `Learn how to use every UI5 control in ABAP - the UI5 Demo Kit rebuilt with abap2UI5`
        href      = `https://github.com/abap2UI5/samples-controls`
        class     = `z2ui5_cl_smpc_app_overview`
        class_old = `z2ui5_cl_dmo_app_overview` ).

    render_samples(
        form      = form
        label     = `Stack`
        icon      = `sap-icon://database`
        name      = `samples-stack`
        descr     = `Learn how abap2UI5 plays with your stack - OData, RAP, WebSockets, the Fiori Launchpad and more`
        href      = `https://github.com/abap2UI5/samples-stack`
        class     = `z2ui5_cl_smps_app_00`
        class_old = `z2ui5_cl_smpe_app_00` ).

  ENDMETHOD.

  METHOD render_icon_row.

    form->leaf( `Label` ).
    IF label IS NOT INITIAL.
      form->a( n = `text`
               v = label ).
    ENDIF.

    result = form->open( `HBox`
        )->a( n = `alignItems`
              v = `Center`
        )->a( n = `wrap`
              v = `Wrap` ).

    result->leaf( n  = `Icon`
                  ns = `core`
        )->a( n = `src`
              v = icon
        )->a( n = `class`
              v = `sapUiTinyMarginEnd`
      )->leaf( `Link`
        )->a( n = `text`
              v = text
        )->a( n = `href`
              v = href
        )->a( n = `width`
              v = c_link_width ).

    " the Link is still the last child, so this attribute lands on it
    IF new_tab = abap_true.
      result->a( n = `target`
                 v = `_blank` ).
    ENDIF.

  ENDMETHOD.

  METHOD render_samples.

    DATA lv_class TYPE string.
    DATA lv_href  TYPE string.

    IF z2ui5_cl_a2ui5_context=>rtti_check_class_exists( class ).
      lv_class = class.
    ELSEIF class_old IS NOT INITIAL AND z2ui5_cl_a2ui5_context=>rtti_check_class_exists( class_old ).
      lv_class = class_old.
    ENDIF.

    IF lv_class IS NOT INITIAL.
      " the overview app is on this system: a plain same-origin href, no
      " frontend action needed - and target="_blank", so this start page stays
      " where it is and several sample repositories can run side by side
      lv_href = get_app_url( lv_class ).
    ELSE.
      lv_href = href.
    ENDIF.

    DATA(row) = render_icon_row( form    = form
                                 label   = label
                                 icon    = icon
                                 text    = name
                                 href    = lv_href
                                 new_tab = abap_true ).

    " the description comes before the state, so it starts in the same column
    " in all three rows - the marker would push it out of line otherwise
    row->leaf( `Text`
        )->a( n = `text`
              v = descr
        )->a( n = `class`
              v = `sapUiSmallMarginBegin` ).

    " not installed: say so in the row, so it is readable without following the
    " link - that one leads to GitHub then, not into an app
    IF lv_class IS INITIAL.
      row->leaf( `ObjectStatus`
          )->a( n = `text`
                v = `not installed`
          )->a( n = `state`
                v = `Warning`
          )->a( n = `icon`
                v = `sap-icon://download`
          )->a( n = `tooltip`
                v = `Not on this system yet - the link opens the repository on GitHub, ready to pull with abapGit`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).
    ENDIF.

  ENDMETHOD.

  METHOD render_contribution.

    " the last thing to do on the page, so it is the last section - and in the
    " same row shape as the samples and the documentation above: every way in
    " gets its own icon, which is what makes four links four invitations
    render_section( form  = form
                    title = `Join in` ).

    render_icon_row( form    = form
                     label   = `Issues`
                     icon    = `sap-icon://alert`
                     text    = `report a bug`
                     href    = `https://github.com/abap2UI5/abap2UI5/issues`
                     new_tab = abap_true
      )->leaf( `Text`
          )->a( n = `text`
                v = `Found a bug or missing a feature? Tell us - every report helps`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).

    render_icon_row( form    = form
                     label   = `Pull Requests`
                     icon    = `sap-icon://source-code`
                     text    = `send a change`
                     href    = `https://github.com/abap2UI5/abap2UI5/pulls`
                     new_tab = abap_true
      )->leaf( `Text`
          )->a( n = `text`
                v = `Built something great? Contributions of any size are welcome`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).

    render_icon_row( form    = form
                     label   = `Community`
                     icon    = `sap-icon://discussion`
                     text    = `join #abap2UI5`
                     href    = `https://join.slack.com/t/abapgit/shared_invite/zt-46tqufaht-QlrxTzlDqlx85CWbeUnOqg`
                     new_tab = abap_true
      )->leaf( `Text`
          )->a( n = `text`
                v = `Meet the community in the Slack channel - questions welcome`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).

    render_icon_row( form    = form
                     label   = `Sponsor`
                     icon    = `sap-icon://favorite`
                     text    = `support us`
                     href    = `https://abap2ui5.github.io/docs/resources/sponsor.html`
                     new_tab = abap_true
      )->leaf( `Text`
          )->a( n = `text`
                v = `abap2UI5 is free and open source - and stays that way through its sponsors`
          )->a( n = `class`
                v = `sapUiSmallMarginBegin` ).

  ENDMETHOD.

  METHOD open_url.

    " REDIRECT takes a { URL, NEW_WINDOW } object literal - NEW_WINDOW true is
    " what target="_blank" does on a Link
    result = client->follow_up_action(
                 val   = client->cs_event-urlhelper
                 t_arg = VALUE #( ( `REDIRECT` )
                                  ( |\{ URL: '{ href }', NEW_WINDOW: true \}| ) ) ).

  ENDMETHOD.

  METHOD render_system_info.

    " the system facts close the page: they are read, not operated, so they
    " belong after everything that asks the reader for something - part of the
    " same form, not a box of their own, just held apart by an empty row and a
    " headline one level down. The one part that is not free is the draft count
    " at the bottom: two COUNT( * ) - the own rows and the whole table, which
    " together say whether cleanup( ) is keeping up - and they run per render
    " instead of per dialog open, which this page can afford: it renders on
    " start and on the Check / Edit events, nowhere else
    render_spacer( form ).
    render_section( form  = form
                    title = `System Information`
                    small = abap_true ).

    DATA(ls_client) = client->get( ).
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

    render_text( form  = form
                 label = `abap2UI5 Version`
                 text  = z2ui5_if_app=>version ).
    DATA(lo_draft) = NEW z2ui5_cl_core_srv_draft( ).
    render_text( form  = form
                 label = `Draft Entries (own/total)`
                 text  = |{ lo_draft->count_entries( ) } / { lo_draft->count_entries_total( ) }| ).

  ENDMETHOD.

  METHOD render_section.

    DATA(toolbar) = form->open( `Toolbar` ).
    toolbar->leaf( `Title` )->a( n = `text`
                                 v = title ).
    IF small = abap_true.
      toolbar->a( n = `titleStyle`
                  v = `H5` ).
    ENDIF.
    toolbar->shut( ).

  ENDMETHOD.

  METHOD render_spacer.

    form->leaf( `Label` ).

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
