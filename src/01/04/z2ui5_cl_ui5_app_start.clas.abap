CLASS z2ui5_cl_ui5_app_start DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_app_start.

    CONSTANTS:
      BEGIN OF cs_event,
        button_check  TYPE string VALUE `BUTTON_CHECK`,
        button_change TYPE string VALUE `BUTTON_CHANGE`,
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
      IMPORTING page TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_quickstart
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_whats_next
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.

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
    METHODS header_icon
      IMPORTING
        toolbar TYPE REF TO z2ui5_cl_ui5_view_builder
        icon    TYPE string
        tooltip TYPE string
        press   TYPE string
        class   TYPE string DEFAULT `sapUiTinyMarginBeginEnd`.

    " Building blocks of the SimpleForm rows above. Private on purpose: this
    " class lives in the public src/02 package, so everything added to its
    " public section joins the framework's stable API contract (rule 5).

    " the events of this class that no app has ever been given a name for.
    " They stay private on purpose: cs_event is part of the public contract
    " (rule 5), and what a start page does with its own popup is not
    CONSTANTS c_event_system TYPE string VALUE `OPEN_SYSTEM`.
    CONSTANTS c_event_close  TYPE string VALUE `CLOSE_POPUP`.

    " the class name input of step 4 - the only control on the page that is
    " addressed from the outside, because the cursor is put into it on start
    CONSTANTS c_id_input TYPE string VALUE `INPUT_CLASSNAME`.

    " put the cursor where the page expects the first keystroke
    METHODS set_focus_input.

    " the documentation, one section below the samples: whoever came for the
    " apps is exactly who wants the guides next
    METHODS render_docs_link
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.

    " what this backend runs on - a popup, because it answers a question that is
    " asked once and then not again. Backend facts only; everything the
    " frontend knows about itself lives in the developer tools (Ctrl+F12)
    METHODS render_system_popup.

    " the section headline every render_* method opens with
    METHODS render_section
      IMPORTING
        form  TYPE REF TO z2ui5_cl_ui5_view_builder
        title TYPE string.

    " an empty row - a Label with nothing after it is how a SimpleForm gets
    " one, and the only way to put air between two blocks of the same form
    METHODS render_spacer
      IMPORTING form TYPE REF TO z2ui5_cl_ui5_view_builder.

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

    " the column the link occupies in an icon row, so what follows it starts at
    " the same place in every row - the alignment the samples app has
    CONSTANTS c_link_width TYPE string VALUE `12rem`.

    " the two icons the page names twice - once in the title row, once in the
    " "Learn more" section - so the header and the section cannot drift apart
    CONSTANTS c_icon_docs TYPE string VALUE `sap-icon://learning-assistant`.
    CONSTANTS c_icon_repo TYPE string VALUE `sap-icon://globe`.

    " the icon of a row belongs to the link behind it, so it carries the link's
    " colour rather than the near-black an Icon renders in by default. A literal
    " CSSColor, because the property takes a colour or one of the semantic
    " IconColor values - and none of those is "like a link"; this is the Fiori
    " link blue of the light themes
    CONSTANTS c_icon_color TYPE string VALUE `#0a6ed1`.

    " the samples overview renders its header icons at this size; a stock
    " core:Icon is 1rem and looks undersized next to the page title
    CONSTANTS c_icon_size_header TYPE string VALUE `1.125rem`.

    " What sets the outbound icons apart from the system ones: a gap, not a
    " rule. A sap.m.ToolbarSeparator would draw the rule, but it renders a
    " <div> and only lays out as expected inside a flex container - see
    " render_header_toolbar( ), which is where that matters.
    CONSTANTS c_icon_class_group TYPE string VALUE `sapUiMediumMarginBegin sapUiTinyMarginEnd`.

    " a form row of Label + [ icon, link ] - the shape the sample rows and the
    " documentation row share. Returns the HBox, so the caller can append
    " whatever else its own row has to say behind the link
    METHODS render_icon_row
      IMPORTING
        form          TYPE REF TO z2ui5_cl_ui5_view_builder
        label         TYPE string OPTIONAL
        icon          TYPE string
        text          TYPE string
        href          TYPE string
        new_tab       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    " one form row per sample repository: icon, repository name and what is in
    " it. The name is the link - to the overview app when the repository is
    " installed on this system, to GitHub when it is not, and in that case the
    " row says so
    METHODS render_samples
      IMPORTING
        form      TYPE REF TO z2ui5_cl_ui5_view_builder
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


CLASS z2ui5_cl_ui5_app_start IMPLEMENTATION.

  METHOD factory.

    result = NEW #( ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      on_init( ).
      render_start( ).
      set_focus_input( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_init.

    reset_button_state( ).
    ms_home-classname = z2ui5_cl_ui5_util_context=>rtti_get_classname_by_ref( NEW z2ui5_cl_ui5_app_hi_world( ) ).

  ENDMETHOD.

  METHOD on_event.

    DATA li_app_config TYPE REF TO z2ui5_if_app.

    CASE client->get_event( ).

      WHEN cs_event-set_config.
        CREATE OBJECT li_app_config TYPE (`Z2UI5_CL_APP_ICF_CONFIG`).
        client->nav_app_call( li_app_config ).

      WHEN c_event_system.
        render_system_popup( ).

      WHEN c_event_close.
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
        ms_home-classname = z2ui5_cl_ui5_util_context=>c_trim_upper( ms_home-classname ).
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

  METHOD set_focus_input.

    " SET_FOCUS as a statement, not in a view attribute: it is scheduled for
    " after the response, which is when the freshly built view is rendered and
    " the input exists in the DOM. Its arguments are the control id and the
    " selection, and both ends of the selection are the length of what stands
    " in the field - a caret behind the last character, nothing selected, so
    " the proposal can be typed over or completed
    DATA(lv_end) = |{ strlen( ms_home-classname ) }|.
    client->follow_up_action( val   = client->cs_event-set_focus
                              t_arg = VALUE #( ( c_id_input )
                                               ( lv_end )
                                               ( lv_end ) ) ).

  ENDMETHOD.

  METHOD render_start.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    DATA(page) = view->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`         v = `sap.m`
        )->a( n = `xmlns:mvc`     v = `sap.ui.core.mvc`
        )->a( n = `xmlns:form`    v = `sap.ui.layout.form`
        )->a( n = `xmlns:core`    v = `sap.ui.core`
        )->a( n = `displayBlock`  v = `true`
        )->a( n = `height`        v = `100%`

        )->ele( `Shell`
        )->ele( `Page` ).

    " no title on the Page: the title row is built as a Bar in its custom
    " header, which is what render_header_toolbar( ) does - see there
    render_header_toolbar( page ).

    DATA(form) = create_layout_form( page ).
    render_quickstart( form ).
    render_whats_next( form ).
    render_docs_link( form ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD render_header_toolbar.

    " The title row, built the way the three overview apps of the family build
    " theirs (z2ui5_cl_smp_app_000=>render_header): a sap.m.Bar in the page's
    " customHeader rather than the Page's own title and headerContent. Same
    " controls either way - a Page renders its stock header as a Bar too - but
    " the title becomes a Title control in contentLeft, and a Bar child carries
    " the margin that sets it off from the window edge. The stock Page title
    " sits flush against it, which reads as if the heading belonged to the
    " browser rather than to the page.
    DATA(bar) = page->ele( `customHeader` )->ele( `Bar` ).

    bar->ele( `contentLeft`
        )->tag( `Title`
            )->a( n = `text`   v = `abap2UI5 - Build UI5 Apps Purely in ABAP`
            )->a( n = `level`  v = `H2` ).

    " right: icons only, the way the samples app carries them - the title row
    " is not the place for labels, and what each one does is in its tooltip.
    "
    " ONLY INLINE CONTROLS BELONG IN HERE. A sap.m.Bar's content containers
    " became flex boxes only after 1.71: on the oldest release abap2UI5
    " supports, .sapMBarRight is a plain absolutely positioned block that lays
    " its children out in normal flow. A block-level child - and both
    " ToolbarSpacer and ToolbarSeparator render a <div> - therefore starts a
    " new line, and everything from that line on is cut away by the
    " overflow:hidden the container carries at the bar's height of 3rem. On
    " 1.71 that silently swallowed the documentation and repository icons,
    " while newer releases showed all of them.
    " No ToolbarSpacer either: contentRight is right-aligned on its own.
    DATA(toolbar) = bar->ele( `contentRight` ).

    " first what this system is: the information popup, and the configuration
    " when it is installed. Sliders rather than a monitor on the first one -
    " what opens there is the backend side of the installation, user exit and
    " drafts included, and that reads as settings. The gear next to it stays
    " with the ICF configuration, so the two are still told apart at a glance
    header_icon( toolbar = toolbar
                 icon    = `sap-icon://action-settings`
                 tooltip = `System information - backend settings, user exit, drafts (frontend info: Ctrl+F12)`
                 press   = client->_event( c_event_system ) ).

    IF z2ui5_cl_ui5_util_context=>rtti_check_class_exists( `z2ui5_cl_app_icf_config` ).
      header_icon( toolbar = toolbar
                   icon    = `sap-icon://settings`
                   tooltip = `Configuration`
                   press   = client->_event( cs_event-set_config ) ).
    ENDIF.

    " ... then, set apart by a wider gap, the entries that leave the system:
    " the icons above open something in this system, these two open a site.
    " The gap rides on the first of them (c_icon_class_group) instead of on a
    " separator control of its own - see the note above on what a block-level
    " child does to this bar on 1.71
    header_icon( toolbar = toolbar
                 icon    = c_icon_docs
                 tooltip = `Documentation - guides, tutorials and the API reference on abap2UI5.org`
                 press   = open_url( `https://abap2UI5.org` )
                 class   = c_icon_class_group ).

    header_icon( toolbar = toolbar
                 icon    = c_icon_repo
                 tooltip = `The abap2UI5 repository on GitHub - source code, issues, releases and the abapGit installation`
                 press   = open_url( `https://github.com/abap2UI5/abap2UI5` ) ).

  ENDMETHOD.

  METHOD header_icon.

    " a core:Icon, not a Button - the same choice the samples overview makes.
    " A Button wraps its icon in button chrome that caps how large it renders;
    " a bare icon takes the size it is given, and 1.125rem is what makes the
    " title row read as icons rather than as shrunken buttons.
    toolbar->tag( n = `Icon` ns = `core`
        )->a( n = `src`      v = icon
        )->a( n = `size`     v = c_icon_size_header
        )->a( n = `class`    v = class
        )->a( n = `color`    v = c_icon_color
        )->a( n = `tooltip`  v = tooltip
        )->a( n = `press`    v = press ).

  ENDMETHOD.

  METHOD render_docs_link.

    " its own section, so the samples above get their separator back and where
    " to read on is what the page says right after them - same row shape as a
    " sample repository, and the same two icons the title row carries
    render_section( form  = form
                    title = `Learn more` ).

    render_icon_row( form    = form
                     label   = `GitHub`
                     icon    = c_icon_repo
                     text    = `abap2UI5`
                     href    = `https://github.com/abap2UI5/abap2UI5`
                     new_tab = abap_true
      )->tag( `Text`
          )->a( n = `text`   v = `The repository itself - source code, issues, releases, and what abapGit installs from`
          )->a( n = `class`  v = `sapUiSmallMarginBegin` ).

    render_icon_row( form    = form
                     label   = `Docs`
                     icon    = c_icon_docs
                     text    = `abap2UI5.org`
                     href    = `https://abap2UI5.org`
                     new_tab = abap_true
      )->tag( `Text`
          )->a( n = `text`   v = `Guides, tutorials and the API reference - from your first app to the full client API`
          )->a( n = `class`  v = `sapUiSmallMarginBegin` ).

  ENDMETHOD.

  METHOD render_quickstart.

    render_section( form  = form
                    title = `Quickstart - your first app in 5 steps` ).

    form->tag( `Label` )->a( n = `text`  v = `Step 1`
      )->tag( `Text` )->a( n = `text`   v = `Create a new class in your ABAP system`
      )->tag( `Label` )->a( n = `text`  v = `Step 2`
      )->tag( `Text` )->a( n = `text`   v = `Add the interface Z2UI5_IF_APP - that is all it takes`
      )->tag( `Label` )->a( n = `text`  v = `Step 3`
      )->tag( `Text` )->a( n = `text`   v = `Define the view and implement the behavior - in pure ABAP` ).

    render_link( form = form
                 text = `See a complete example: Hello World`
                 href = `https://github.com/abap2UI5/abap2UI5/blob/main/src/01/04/z2ui5_cl_ui5_app_hi_world.clas.abap` ).

    form->tag( `Label` )->a( n = `text`  v = `Step 4` ).

    IF ms_home-class_editable = abap_true.
      form->tag( `Input`
          )->a( n = `id`              v = c_id_input
          )->a( n = `placeholder`     v = `Enter your class name and press 'Check'`
          )->a( n = `enabled`         v = client->_bind( ms_home-class_editable )
          )->a( n = `value`           v = client->_bind( ms_home-classname )
          )->a( n = `valueState`      v = client->_bind( ms_home-class_value_state )
          )->a( n = `valueStateText`  v = client->_bind( ms_home-class_value_state_text )
          )->a( n = `submit`          v = client->_event( ms_home-btn_event_id )
          )->a( n = `width`           v = `70%` ).
    ELSE.
      form->tag( `Text` )->a( n = `text`  v = ms_home-classname ).
    ENDIF.

    form->tag( `Label` ).
    form->tag( `Button`
        )->a( n = `press`  v = client->_event( ms_home-btn_event_id )
        )->a( n = `text`   v = client->_bind( ms_home-btn_text )
        )->a( n = `icon`   v = client->_bind( ms_home-btn_icon )
        )->a( n = `width`  v = `70%` ).

    " not render_link: this one is bound and additionally disabled until the
    " class name was checked
    form->tag( `Label` )->a( n = `text`  v = `Step 5`
      )->tag( `Link`
          )->a( n = `text`     v = `Open your application in a new tab`
          )->a( n = `target`   v = `_blank`
          )->a( n = `href`     v = client->_bind( ms_home-url )
          )->a( n = `enabled`  v = client->_bind( ms_home-link_enabled ) ).

    " the five steps are one thought - let it end before the next headline.
    " Four rows, not one: this is the break between doing something and reading
    " on, the widest the page has, and two rows were not enough to read as a
    " break next to the row spacing the steps themselves already have
    render_spacer( form ).
    render_spacer( form ).
    render_spacer( form ).
    render_spacer( form ).

  ENDMETHOD.

  METHOD render_whats_next.

    render_section( form  = form
                    title = `What's next?` ).

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
        label     = `Basics`
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

    form->tag( `Label` ).
    IF label IS NOT INITIAL.
      form->a( n = `text`  v = label ).
    ENDIF.

    result = form->ele( `HBox`
        )->a( n = `alignItems`  v = `Center`
        )->a( n = `wrap`        v = `Wrap` ).

    " no slot of its own for the icon: every glyph of the icon font renders the
    " same width, so the links line up on the icon alone - a fixed slot only
    " tore a hole between the icon and the name it belongs to
    result->tag( n = `Icon` ns = `core`
        )->a( n = `src`    v = icon
        )->a( n = `color`  v = c_icon_color
        )->a( n = `class`  v = `sapUiTinyMarginEnd` ).

    result->tag( `Link`
        )->a( n = `text`   v = text
        )->a( n = `href`   v = href
        )->a( n = `width`  v = c_link_width ).

    " the Link is still the last child, so this attribute lands on it
    IF new_tab = abap_true.
      result->a( n = `target`  v = `_blank` ).
    ENDIF.

  ENDMETHOD.

  METHOD render_samples.

    DATA lv_class TYPE string.
    DATA lv_href  TYPE string.

    IF z2ui5_cl_ui5_util_context=>rtti_check_class_exists( class ).
      lv_class = class.
    ELSEIF class_old IS NOT INITIAL AND z2ui5_cl_ui5_util_context=>rtti_check_class_exists( class_old ).
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

    " Installed or not, the row says so in the SAME slot right behind the name -
    " one ObjectStatus either way, so the status column lines up across rows and
    " the eye can scan it. It also tells the reader where the link goes before
    " they follow it: into an app on this system, or out to GitHub. `state` is
    " what colours icon and text with it - Success green, Warning orange.
    IF lv_class IS INITIAL.
      row->tag( `ObjectStatus`
          )->a( n = `text`     v = `not installed`
          )->a( n = `icon`     v = `sap-icon://download`
          )->a( n = `state`    v = `Warning`
          )->a( n = `tooltip`  v = `Not installed on this system - the link opens the repository on GitHub, ready to pull with abapGit` ).
    ELSE.
      row->tag( `ObjectStatus`
          )->a( n = `text`     v = `installed`
          )->a( n = `icon`     v = `sap-icon://accept`
          )->a( n = `state`    v = `Success`
          )->a( n = `tooltip`  v = `Installed on this system - the link opens its overview app in a new tab` ).
    ENDIF.

    row->tag( `Text`
        )->a( n = `text`   v = descr
        )->a( n = `class`  v = `sapUiSmallMarginBegin` ).

  ENDMETHOD.

  METHOD open_url.

    " REDIRECT takes a { URL, NEW_WINDOW } object literal - NEW_WINDOW true is
    " what target="_blank" does on a Link
    result = client->follow_up_action(
                 val   = client->cs_event-urlhelper
                 t_arg = VALUE #( ( `REDIRECT` )
                                  ( |\{ URL: '{ href }', NEW_WINDOW: true \}| ) ) ).

  ENDMETHOD.

  METHOD render_system_popup.

    " the system facts are read once and then not again, so they are a popup
    " rather than a block of the page - reached from the icon at the right end
    " of the closing line. The one part that is not free is the draft count at
    " the bottom: two COUNT( * ), the own rows and the whole table, which
    " together say whether cleanup( ) is keeping up. In a popup they run when
    " the popup is opened, which is exactly when somebody asks
    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory( ).

    DATA(dialog) = popup->ele( n = `FragmentDefinition` ns = `core`
        )->a( n = `xmlns`       v = `sap.m`
        )->a( n = `xmlns:core`  v = `sap.ui.core`
        )->a( n = `xmlns:form`  v = `sap.ui.layout.form`

        )->ele( `Dialog`
            )->a( n = `title`       v = `abap2UI5 - System Information`
            )->a( n = `afterClose`  v = client->_event( c_event_close ) ).

    DATA(content) = dialog->ele( `content` ).

    " the popup answers what the backend is, and nothing else - the UI5
    " version, the theme, the device and the requests are the frontend's
    " answer to the same question, and the developer tools already show all of
    " it. Naming the shortcut here is what makes that split usable: Ctrl+F12
    " is not guessable, and a popup that stayed silent about it would read as
    " if the frontend facts were simply gone
    content->tag( `MessageStrip`
        )->a( n = `text`      v = `Frontend information - UI5 version, theme, device, requests and logs - is in the developer tools: Ctrl+F12`
        )->a( n = `type`      v = `Information`
        )->a( n = `showIcon`  v = `true`
        )->a( n = `class`     v = `sapUiSmallMarginBeginEnd sapUiTinyMarginTop` ).

    DATA(form) = create_layout_form( content ).
    DATA(ls_client) = client->get( ).

    form->tag( `Label` )->a( n = `text`  v = `Launchpad active` ).
    form->tag( `CheckBox`
        )->a( n = `selected`  b = ls_client-check_launchpad_active
        )->a( n = `enabled`   v = `false` ).

    form->tag( `Label` )->a( n = `text`  v = `ABAP for Cloud` ).
    form->tag( `CheckBox`
        )->a( n = `selected`  b = z2ui5_cl_ui5_util_context=>check_abap_cloud( )
        )->a( n = `enabled`   v = `false` ).
    render_text( form  = form
                 label = `User Exit`
                 text  = z2ui5_cl_ui5_user_exit=>get_user_exit_class( ) ).

    render_text( form  = form
                 label = `abap2UI5 Version`
                 text  = z2ui5_if_app=>version ).
    DATA(lo_draft) = NEW z2ui5_cl_ui5_srv_draft( ).
    render_text( form  = form
                 label = `Draft Entries (own/total)`
                 text  = |{ lo_draft->count_entries( ) } / { lo_draft->count_entries_total( ) }| ).

    dialog->ele( `endButton`

        )->tag( `Button`
            )->a( n = `text`   v = `Close`
            )->a( n = `press`  v = client->_event( c_event_close )
            )->a( n = `type`   v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_section.

    " The heading is indented and spaced the way the samples overview does it
    " (z2ui5_cl_smp_app_000=>render_start): a Title in a bare Toolbar sits flush
    " against the form edge, left of everything under it, which reads as if the
    " heading belonged to the page rather than to its rows. sapUiSmallMarginBegin
    " pulls it over the rows it introduces; the top/bottom pair is what sets one
    " section apart from the one above without a separator line.
    form->ele( `Toolbar`

        )->tag( `Title`
            )->a( n = `text`   v = title
            )->a( n = `level`  v = `H3`
            )->a( n = `class`  v = `sapUiSmallMarginBegin sapUiSmallMarginTop sapUiTinyMarginBottom`

      )->end( ).

  ENDMETHOD.

  METHOD render_spacer.

    form->tag( `Label` ).

  ENDMETHOD.

  METHOD render_link.

    form->tag( `Label` ).
    IF label IS NOT INITIAL.
      form->a( n = `text`  v = label ).
    ENDIF.

    form->tag( `Link`
        )->a( n = `text`    v = text
        )->a( n = `target`  v = `_blank`
        )->a( n = `href`    v = href ).

  ENDMETHOD.

  METHOD render_text.

    form->tag( `Label` )->a( n = `text`  v = label
      )->tag( `Text` )->a( n = `text`  v = text ).

  ENDMETHOD.

  METHOD create_layout_form.

    result = view->ele( n = `SimpleForm` ns = `form`
        )->a( n = `editable`                 v = `true`
        )->a( n = `layout`                   v = `ResponsiveGridLayout`
        )->a( n = `labelSpanXL`              v = `4`
        )->a( n = `labelSpanL`               v = `3`
        )->a( n = `labelSpanM`               v = `4`
        )->a( n = `labelSpanS`               v = `12`
        )->a( n = `adjustLabelSpan`          v = `false`
        )->a( n = `emptySpanXL`              v = `0`
        )->a( n = `emptySpanL`               v = `4`
        )->a( n = `emptySpanM`               v = `0`
        )->a( n = `emptySpanS`               v = `0`
        )->a( n = `columnsXL`                v = `1`
        )->a( n = `columnsL`                 v = `1`
        )->a( n = `columnsM`                 v = `1`
        )->a( n = `singleContainerFullSize`  v = `false`
        )->ele( n = `content` ns = `form` ).

  ENDMETHOD.

  METHOD get_app_url.

    DATA(ls_config) = client->get( )-s_config.
    result = z2ui5_cl_ui5_util_context=>app_get_url( classname = classname
                                                  origin       = ls_config-origin
                                                  pathname     = ls_config-pathname
                                                  search       = ls_config-search
                                                  hash         = ls_config-hash ).

  ENDMETHOD.

ENDCLASS.
