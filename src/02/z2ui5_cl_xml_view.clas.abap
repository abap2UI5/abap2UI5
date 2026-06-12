"! <p class="shorttext synchronized" lang="en">abap2UI5 - view parser</p>
"!
"! Builder for SAPUI5 XML views. See CLAUDE.md and the project README for usage.
"! Note: AI assistants should use the generic builder `z2ui5_cl_util_xml` instead - see project guidelines.
CLASS z2ui5_cl_xml_view DEFINITION PUBLIC.

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">factory - rooted in View</p>
    "!
    "! Use this when building a top-level view returned via `client->view_display( )`.
    "!
    "! @parameter t_ns   | (ty_t_name_value) Additional XML namespaces to include in the root element.
    "! @parameter result | New builder instance positioned at the View root.
    CLASS-METHODS factory
      IMPORTING
        t_ns          TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Create a builder without any pre-set root</p>
    "!
    "! @parameter result | New empty builder instance.
    CLASS-METHODS factory_plain
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">factory_popup - rooted in FragmentDefinition</p>
    "!
    "! Use this when building dialogs / popovers passed via `client->popup_display( )`.
    "!
    "! @parameter t_ns   | (ty_t_name_value) Additional XML namespaces.
    "! @parameter result | New builder instance positioned at the FragmentDefinition root.
    CLASS-METHODS factory_popup
      IMPORTING
        t_ns          TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Constructor</p>
    METHODS constructor.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.HorizontalLayout</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.HorizontalLayout.
    "!
    "! @parameter class         | (string) CSS class names.
    "! @parameter visible       | (boolean) Whether the layout is visible. Default: true.
    "! @parameter allowwrapping | (boolean) Wrap children to a new line when horizontal space runs out. Default: false.
    METHODS horizontal_layout
      IMPORTING
        class         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        allowwrapping TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.Icon</p>
    "!
    "! Renders an icon from one of the SAPUI5 icon fonts. See https://ui5.sap.com/#/api/sap.ui.core.Icon
    "!
    "! @parameter src                   | (sap.ui.core.URI) Icon URI, e.g. `sap-icon://accept`. Required for visible icons.
    "! @parameter press                 | (event) Fired when the icon is clicked.
    "! @parameter size                  | (sap.ui.core.CSSSize) Font size of the icon, e.g. `1rem`, `2em`, `32px`.
    "! @parameter color                 | (string | sap.ui.core.IconColor) Icon color. CSS color or enum:
    "!                                     Default | Positive | Negative | Critical | Neutral | Contrast | Non_Interactive | Tile | Marker.
    "! @parameter class                 | (string) CSS class names.
    "! @parameter width                 | (sap.ui.core.CSSSize) Outer width.
    "! @parameter useicontooltip        | (boolean) Whether the symbolic name is used as tooltip when no `tooltip` is set. Default: true.
    "! @parameter notabstop             | (boolean) If true the icon is not part of the tab chain. Default: false.
    "! @parameter hovercolor            | (string | sap.ui.core.IconColor) Color while hovered.
    "! @parameter hoverbackgroundcolor  | (string | sap.ui.core.IconColor) Background color while hovered.
    "! @parameter height                | (sap.ui.core.CSSSize) Outer height.
    "! @parameter decorative            | (boolean) If true the icon is hidden from screen readers and is not focusable. Default: true.
    "! @parameter backgroundcolor       | (string | sap.ui.core.IconColor) Background color.
    "! @parameter alt                   | (string) Alternative text for screen readers (used only when `decorative=false`).
    "! @parameter activecolor           | (string | sap.ui.core.IconColor) Color while pressed.
    "! @parameter activebackgroundcolor | (string | sap.ui.core.IconColor) Background color while pressed.
    "! @parameter visible               | (boolean) Whether the icon is visible. Default: true.
    METHODS icon
      IMPORTING
        src                   TYPE clike OPTIONAL
        press                 TYPE clike OPTIONAL
        size                  TYPE clike OPTIONAL
        color                 TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
        id                    TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        useicontooltip        TYPE clike OPTIONAL
        notabstop             TYPE clike OPTIONAL
        hovercolor            TYPE clike OPTIONAL
        hoverbackgroundcolor  TYPE clike OPTIONAL
        height                TYPE clike OPTIONAL
        decorative            TYPE clike OPTIONAL
        backgroundcolor       TYPE clike OPTIONAL
        alt                   TYPE clike OPTIONAL
        activecolor           TYPE clike OPTIONAL
        activebackgroundcolor TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.DynamicPage</p>
    "!
    "! Page with title, snappable header, content and footer. See https://ui5.sap.com/#/api/sap.f.DynamicPage.
    "!
    "! @parameter headerexpanded           | (boolean) Initial state of the header (true=expanded). Default: true.
    "! @parameter showfooter               | (boolean) Whether the footer is shown. Default: false.
    "! @parameter headerpinned             | (boolean) Header initially pinned (only when pinnable). Default: false. Since 1.93.
    "! @parameter toggleheaderontitleclick | (boolean) Click on title toggles header expand state. Default: true.
    "! @parameter class                    | (string) CSS class names.
    METHODS dynamic_page
      IMPORTING
        headerexpanded           TYPE clike OPTIONAL
        showfooter               TYPE clike OPTIONAL
        headerpinned             TYPE clike OPTIONAL
        toggleheaderontitleclick TYPE clike OPTIONAL
        class                    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.DynamicPageTitle</p>
    "!
    "! Container for heading, content, actions, navigationActions, breadcrumbs and snapped/expanded slots.
    "! See https://ui5.sap.com/#/api/sap.f.DynamicPageTitle. Children are added via the matching aggregation methods.
    METHODS dynamic_page_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.DynamicPageHeader</p>
    "!
    "! Snappable/expandable header. See https://ui5.sap.com/#/api/sap.f.DynamicPageHeader.
    "!
    "! @parameter pinnable | (boolean) Whether the user can pin the header (renders pin button). Default: true.
    METHODS dynamic_page_header
      IMPORTING
        pinnable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.HTML</p>
    "!
    "! Embeds a string of HTML inside a UI5 view. See https://ui5.sap.com/#/api/sap.ui.core.HTML.
    "!
    "! @parameter content         | (string) HTML markup. Must be enclosed in tags. Script tags execute but do not appear in the DOM.
    "! @parameter afterrendering  | (event) Fired after rendering. Param `isPreservedDOM` indicates whether existing DOM was preserved.
    "! @parameter preferdom       | (boolean) Prefer existing DOM over the content string when re-rendering. Default: true.
    "! @parameter sanitizecontent | (boolean) Run the HTML sanitizer on the content string. Default: false.
    "! @parameter visible         | (boolean) Whether the control is visible. Default: true.
    METHODS html
      IMPORTING
        content         TYPE clike OPTIONAL
        afterrendering  TYPE clike OPTIONAL
        preferdom       TYPE clike OPTIONAL
        sanitizecontent TYPE clike OPTIONAL
        visible         TYPE clike OPTIONAL
        id              TYPE clike OPTIONAL
          PREFERRED PARAMETER content
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.IllustratedMessage</p>
    "!
    "! Empty-state / error / success message with illustration, title and description.
    "! See https://ui5.sap.com/#/api/sap.m.IllustratedMessage.
    "!
    "! @parameter enableverticalresponsiveness | (boolean) Resize illustration based on container height when `illustrationSize=Auto`. Default: false.
    "! @parameter enableformattedtext          | (boolean) Render description as formatted text (HTML subset). Default: false.
    "! @parameter illustrationtype             | (string) Illustration key, e.g. `sapIllus-NoSearchResults`, `sapIllus-NoData`,
    "!                                            `sapIllus-UnableToLoad`, `sapIllus-SuccessScreen`, `sapIllus-NoEntries`, `sapIllus-NoActivities`,
    "!                                            `sapIllus-BeforeSearch`. See `sap.m.IllustratedMessageType` for the full list.
    "! @parameter title                        | (string) Title text shown below the illustration.
    "! @parameter description                  | (string) Description text shown beneath the title.
    "! @parameter illustrationsize             | (sap.m.IllustratedMessageSize) Auto | Base | Dot | Spot | Dialog | Scene. Default: Auto.
    METHODS illustrated_message
      IMPORTING
        enableverticalresponsiveness TYPE clike OPTIONAL
        enableformattedtext          TYPE clike OPTIONAL
        illustrationtype             TYPE clike OPTIONAL
        title                        TYPE clike OPTIONAL
        description                  TYPE clike OPTIONAL
        illustrationsize             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.plugins.CellSelector</p>
    "!
    "! Plugin enabling Excel-like keyboard cell selection. See https://ui5.sap.com/#/api/sap.m.plugins.CellSelector.
    METHODS p_cell_selector
      IMPORTING
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.plugins.CopyProvider</p>
    "!
    "! Plugin that copies selected rows / cells to the clipboard. See https://ui5.sap.com/#/api/sap.m.plugins.CopyProvider.
    "!
    "! @parameter extract_data | (function) Mandatory callback returning the copied data per cell. Set via formatter binding.
    "! @parameter copy         | (event) Fired when the user triggers the copy action; allows preventDefault.
    METHODS p_copy_provider
      IMPORTING
        id            TYPE clike OPTIONAL
        extract_data  TYPE clike OPTIONAL
        copy          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `additionalContent`</p>
    METHODS additional_content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FlexBox</p>
    "!
    "! CSS flexbox layout container. See https://ui5.sap.com/#/api/sap.m.FlexBox.
    "!
    "! @parameter class            | (string) CSS class names.
    "! @parameter rendertype       | (sap.m.FlexRendertype) Div | List | Bare. Default: Div.
    "! @parameter width            | (sap.ui.core.CSSSize) Width. Container width must be defined when using percentages.
    "! @parameter fitcontainer     | (boolean) Stretch to fill container. Default: false.
    "! @parameter height           | (sap.ui.core.CSSSize) Height. Container height must be defined when using percentages.
    "! @parameter alignitems       | (sap.m.FlexAlignItems) Cross-axis alignment: Start | Center | End | Stretch | Baseline | Inherit. Default: Stretch.
    "! @parameter justifycontent   | (sap.m.FlexJustifyContent) Main-axis alignment: Start | Center | End | SpaceBetween | SpaceAround | Inherit. Default: Start.
    "! @parameter wrap             | (sap.m.FlexWrap) NoWrap | Wrap | WrapReverse. Default: NoWrap.
    "! @parameter visible          | (boolean) Whether the box is visible. Default: true.
    "! @parameter direction        | (sap.m.FlexDirection) Row | RowReverse | Column | ColumnReverse | Inherit. Default: Row.
    "! @parameter displayinline    | (boolean) Inline-flex (true) vs flex (false). Default: false.
    "! @parameter backgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Transparent.
    "! @parameter aligncontent     | (sap.m.FlexAlignContent) Start | Center | End | SpaceBetween | SpaceAround | Stretch | Inherit. Default: Stretch.
    "! @parameter items            | (binding path) Default aggregation of items.
    METHODS flex_box
      IMPORTING
        class            TYPE clike OPTIONAL
        rendertype       TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        fitcontainer     TYPE clike OPTIONAL
        height           TYPE clike OPTIONAL
        alignitems       TYPE clike OPTIONAL
        justifycontent   TYPE clike OPTIONAL
        wrap             TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        direction        TYPE clike OPTIONAL
        displayinline    TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        aligncontent     TYPE clike OPTIONAL
        items            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Popover</p>
    "!
    "! Pop-up panel anchored to an opener control. See https://ui5.sap.com/#/api/sap.m.Popover.
    "!
    "! @parameter title               | (string) Header title.
    "! @parameter class               | (string) CSS class names.
    "! @parameter placement           | (sap.m.PlacementType) Top | Right | Bottom | Left | Vertical | Horizontal | Auto |
    "!                                   VerticalPreferredTop | VerticalPreferredBottom | HorizontalPreferredLeft | HorizontalPreferredRight |
    "!                                   PreferredTopOrFlip | PreferredBottomOrFlip | PreferredLeftOrFlip | PreferredRightOrFlip. Default: Right.
    "!                                   Note: the older `*Prefered*` (single 'r') variants are deprecated misspellings.
    "! @parameter initialfocus        | (sap.ui.core.ID) Id of the control that receives focus when opened.
    "! @parameter contentwidth        | (sap.ui.core.CSSSize) Width of the content area.
    "! @parameter contentheight       | (sap.ui.core.CSSSize) Height of the content area.
    "! @parameter showheader          | (boolean) Whether the header is rendered. Default: true.
    "! @parameter showarrow           | (boolean) Whether the arrow indicator is shown. Default: true.
    "! @parameter resizable           | (boolean) User-resizable (desktop only). Default: false.
    "! @parameter modal               | (boolean) Prevents closing on outside click. Default: false.
    "! @parameter horizontalscrolling | (boolean) Allow horizontal scrolling. Default: true.
    "! @parameter verticalscrolling   | (boolean) Allow vertical scrolling. Default: true.
    "! @parameter visible             | (boolean) Whether the popover is visible. Default: true.
    "! @parameter offsetx             | (int) Horizontal offset in pixels. Default: 0.
    "! @parameter offsety             | (int) Vertical offset in pixels. Default: 0.
    "! @parameter contentminwidth     | (sap.ui.core.CSSSize) Minimum content width.
    "! @parameter titlealignment      | (sap.m.TitleAlignment) Auto | Start | Center. Default: Auto.
    "! @parameter beforeopen          | (event) Fired before the popover opens. Provides `openBy`.
    "! @parameter beforeclose         | (event) Fired before the popover closes. Provides `openBy`.
    "! @parameter afteropen           | (event) Fired after the popover opens.
    "! @parameter afterclose          | (event) Fired after the popover closes.
    METHODS popover
      IMPORTING
        id                  TYPE clike OPTIONAL
        title               TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        placement           TYPE clike OPTIONAL
        initialfocus        TYPE clike OPTIONAL
        contentwidth        TYPE clike OPTIONAL
        contentheight       TYPE clike OPTIONAL
        showheader          TYPE clike OPTIONAL
        showarrow           TYPE clike OPTIONAL
        resizable           TYPE clike OPTIONAL
        modal               TYPE clike OPTIONAL
        horizontalscrolling TYPE clike OPTIONAL
        verticalscrolling   TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        offsetx             TYPE clike OPTIONAL
        offsety             TYPE clike OPTIONAL
        contentminwidth     TYPE clike OPTIONAL
        titlealignment      TYPE clike OPTIONAL
        beforeopen          TYPE clike OPTIONAL
        beforeclose         TYPE clike OPTIONAL
        afteropen           TYPE clike OPTIONAL
        afterclose          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.ListItem</p>
    "!
    "! Lightweight item used in ComboBox/Select/etc. See https://ui5.sap.com/#/api/sap.ui.core.ListItem.
    "!
    "! @parameter text           | (string, Item) Display text.
    "! @parameter additionaltext | (string) Optional secondary text shown next to the main text.
    "! @parameter key            | (string, Item) Key value of the item.
    "! @parameter icon           | (string) URI to an image or icon font URI.
    "! @parameter enabled        | (boolean, Item) Whether the item is selectable. Default: true.
    "! @parameter textdirection  | (sap.ui.core.TextDirection, Item) Inherit | LTR | RTL. Default: Inherit.
    METHODS list_item
      IMPORTING
        text           TYPE clike OPTIONAL
        additionaltext TYPE clike OPTIONAL
        key            TYPE clike OPTIONAL
        icon           TYPE clike OPTIONAL
        enabled        TYPE clike OPTIONAL
        textdirection  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.OverflowToolbarLayoutData</p>
    "!
    "! Layout data attached to children of OverflowToolbar. See https://ui5.sap.com/#/api/sap.m.OverflowToolbarLayoutData.
    "!
    "! @parameter priority                   | (sap.m.OverflowToolbarPriority) NeverOverflow | High | Low | Disappear | AlwaysOverflow. Default: High.
    "! @parameter group                      | (int) Items with the same group number overflow together. Default: 0. Group items cannot use AlwaysOverflow / NeverOverflow.
    "! @parameter closeoverflowoninteraction | (boolean) Close overflow area after interacting with the control. Default: true.
    METHODS overflow_toolbar_layout_data
      IMPORTING
        priority                   TYPE clike OPTIONAL
        group                      TYPE clike OPTIONAL
        closeoverflowoninteraction TYPE clike OPTIONAL
      RETURNING
        VALUE(result)              TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Table</p>
    "!
    "! Responsive list-style table. See https://ui5.sap.com/#/api/sap.m.Table
    "! Many parameters are inherited from sap.m.ListBase (https://ui5.sap.com/#/api/sap.m.ListBase).
    "!
    "! @parameter items               | (binding path) Aggregation of `sap.m.ColumnListItem` rows. Use `client->_bind_edit( itab )`.
    "! @parameter class               | (string) CSS class names.
    "! @parameter growing             | (boolean, ListBase) Enables progressive loading via "More" button. Default: false.
    "! @parameter growingthreshold    | (int, ListBase) Items per growing chunk. Default: 20.
    "! @parameter growingscrolltoload | (boolean, ListBase) If true growing is triggered by scroll instead of button. Default: false.
    "! @parameter headertext          | (string, ListBase) Header text rendered as default header.
    "! @parameter sticky              | (sap.m.Sticky[], ListBase) Comma-separated list of sticky areas: HeaderToolbar | InfoToolbar | ColumnHeaders | GroupHeaders.
    "! @parameter mode                | (sap.m.ListMode, ListBase) Selection mode: None | SingleSelectMaster | SingleSelectLeft | MultiSelect | Delete.
    "!                                   `SingleSelect` is deprecated since 1.143 (use SingleSelectLeft). Default: None.
    "! @parameter width               | (sap.ui.core.CSSSize, ListBase) Width of the control. Default: 100%.
    "! @parameter selectionchange     | (event, ListBase) Fired when selection changes. Provides listItem, listItems, selected, selectAll.
    "! @parameter alternaterowcolors  | (boolean) Alternating row background colors (zebra stripes). Default: false. Since 1.52.
    "! @parameter autopopinmode       | (boolean) Auto pop-in behavior; overrides `demandPopin`/`minScreenWidth` on columns. Default: false. Since 1.76.
    "! @parameter inset               | (boolean, ListBase) Indents the container. Default: false.
    "! @parameter showseparators      | (sap.m.ListSeparators, ListBase) Item separators: All | Inner | None. Default: All.
    "! @parameter showoverlay         | (boolean) Renders an overlay that blocks interaction. Default: false. Since 1.22.1.
    "! @parameter hiddeninpopin       | (sap.ui.core.Priority[]) Column priorities to hide instead of pop-in: None | Low | Medium | High. Since 1.77.
    "! @parameter popinlayout         | (sap.m.PopinLayout) Layout for pop-in rows: Block | GridSmall | GridLarge. Default: Block. Since 1.52.
    "! @parameter fixedlayout         | (any) Layout algorithm for cells: true | false | "Strict". Default: true. Since 1.22.
    "! @parameter backgrounddesign    | (sap.m.BackgroundDesign) Background style: Solid | Translucent | Transparent. Default: Translucent.
    "! @parameter visible             | (boolean) Whether the table is visible. Default: true.
    METHODS table
      IMPORTING
        id                  TYPE clike OPTIONAL
        items               TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        growing             TYPE clike OPTIONAL
        growingthreshold    TYPE clike OPTIONAL
        growingscrolltoload TYPE clike OPTIONAL
        headertext          TYPE clike OPTIONAL
        sticky              TYPE clike OPTIONAL
        mode                TYPE clike OPTIONAL
        width               TYPE clike OPTIONAL
        selectionchange     TYPE clike OPTIONAL
        alternaterowcolors  TYPE clike OPTIONAL
        autopopinmode       TYPE clike OPTIONAL
        inset               TYPE clike OPTIONAL
        showseparators      TYPE clike OPTIONAL
        showoverlay         TYPE clike OPTIONAL
        hiddeninpopin       TYPE clike OPTIONAL
        popinlayout         TYPE clike OPTIONAL
        fixedlayout         TYPE clike OPTIONAL
        backgrounddesign    TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.AnalyticalTable</p>
    "!
    "! Grid table with built-in OData v2 grouping and aggregation. See https://ui5.sap.com/#/api/sap.ui.table.AnalyticalTable.
    "! Most properties (selectionMode, rowMode, toolbar, columns) are inherited from sap.ui.table.Table.
    "!
    "! @parameter ns            | (string) XML namespace prefix (typically `t` for sap.ui.table).
    "! @parameter selectionmode | (sap.ui.table.SelectionMode) None | Single | MultiToggle. `Multi` is deprecated since 1.38 (use MultiToggle). Default: MultiToggle.
    "! @parameter rowmode       | (sap.ui.table.rowmodes.RowMode) Aggregation - use the `auto`, `fixed` or `interactive` builder methods.
    "! @parameter toolbar       | (binding path) Aggregation slot for the table toolbar.
    "! @parameter columns       | (binding path) Aggregation slot for `sap.ui.table.AnalyticalColumn` definitions.
    METHODS analytical_table
      IMPORTING
        ns            TYPE clike OPTIONAL
        selectionmode TYPE clike OPTIONAL
        rowmode       TYPE clike OPTIONAL
        toolbar       TYPE clike OPTIONAL
        columns       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `rowMode`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix (typically `t` for sap.ui.table).
    METHODS rowmode
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Breadcrumbs</p>
    "!
    "! Breadcrumb-style navigation path. See https://ui5.sap.com/#/api/sap.m.Breadcrumbs.
    "!
    "! @parameter ns                  | (string) XML namespace prefix.
    "! @parameter link                | (binding path) Aggregation of `sap.m.Link` ancestors of the current location.
    "! @parameter class               | (string) CSS class names.
    "! @parameter currentlocationtext | (string) Text of the current/last element.
    "! @parameter separatorstyle      | (sap.m.BreadcrumbsSeparatorStyle) Slash | BackSlash | DoubleSlash | DoubleBackSlash | GreaterThan | DoubleGreaterThan. Default: Slash.
    "! @parameter visible             | (boolean) Whether the control is visible. Default: true.
    METHODS breadcrumbs
      IMPORTING
        ns                  TYPE clike OPTIONAL
        link                TYPE clike OPTIONAL
        id                  TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        currentlocationtext TYPE clike OPTIONAL
        separatorstyle      TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `currentLocation`</p>
    "!
    "! @parameter ns   | (string) XML namespace prefix.
    "! @parameter link | (binding path) `sap.m.Link` placed in the current location slot.
    METHODS current_location
      IMPORTING
        ns            TYPE clike OPTIONAL
        link          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ColorPalette</p>
    "!
    "! Picker for predefined colors. See https://ui5.sap.com/#/api/sap.m.ColorPalette.
    "!
    "! @parameter ns          | (string) XML namespace prefix.
    "! @parameter colorselect | (event) Fired when a color is selected. Provides `value` (hex/CSS color) and `defaultAction` flag.
    METHODS color_palette
      IMPORTING
        ns            TYPE clike OPTIONAL
        colorselect   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.rowmodes.Auto</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.rowmodes.Auto. Used inside `rowMode` of sap.ui.table.Table / AnalyticalTable.
    "!
    "! @parameter ns               | (string) XML namespace prefix (typically `t`).
    "! @parameter rowcontentheight | (int) Row content height in pixels. 0 = theme-based default. Default: 0.
    METHODS auto
      IMPORTING
        ns               TYPE clike OPTIONAL
        rowcontentheight TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MessageStrip</p>
    "!
    "! Inline coloured notification strip. See https://ui5.sap.com/#/api/sap.m.MessageStrip.
    "!
    "! @parameter text                | (string) Message text. Default: empty.
    "! @parameter type                | (sap.ui.core.message.MessageType) Information | Success | Warning | Error. Default: Information.
    "! @parameter showicon            | (boolean) Whether the icon is shown. Default: false.
    "! @parameter customicon          | (sap.ui.core.URI) Custom icon. Falls back to default icon for the type when empty.
    "! @parameter class               | (string) CSS class names.
    "! @parameter visible             | (boolean) Whether the strip is visible. Default: true.
    "! @parameter showclosebutton     | (boolean) Render a close button. Default: false.
    "! @parameter enableformattedtext | (boolean) Allow a limited HTML subset in the text. Default: false.
    METHODS message_strip
      IMPORTING
        text                TYPE clike OPTIONAL
        type                TYPE clike OPTIONAL
        showicon            TYPE clike OPTIONAL
        customicon          TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        showclosebutton     TYPE clike OPTIONAL
        enableformattedtext TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `footer`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS footer
      IMPORTING
        ns            TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MessagePage</p>
    "!
    "! DEPRECATED since 1.112 - replace with `sap.m.IllustratedMessage` (see method `illustrated_message`).
    "! See https://ui5.sap.com/#/api/sap.m.MessagePage.
    "!
    "! @parameter show_header         | (boolean) Whether the header is shown. Default: true.
    "! @parameter text                | (string) Main text. Default: "No matching items found.".
    "! @parameter enableformattedtext | (boolean) Allow formatted-text HTML subset in the description. Default: false.
    "! @parameter description         | (string) Description text. Default: "Check the filter settings.".
    "! @parameter icon                | (sap.ui.core.URI) Icon. Default: `sap-icon://documents`.
    METHODS message_page
      IMPORTING
        show_header         TYPE clike OPTIONAL
        text                TYPE clike OPTIONAL
        enableformattedtext TYPE clike OPTIONAL
        description         TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.uxap.ObjectPageLayout</p>
    "!
    "! Object page layout with snappable header, anchor bar and sections/sub-sections. See https://ui5.sap.com/#/api/sap.uxap.ObjectPageLayout.
    "!
    "! @parameter showtitleinheadercontent       | (boolean) Show title also inside the header content area. Default: false.
    "! @parameter showeditheaderbutton           | (boolean) Render an edit-header button. Default: false. Since 1.34.
    "! @parameter editheaderbuttonpress          | (event) Fired when the edit-header button is pressed.
    "! @parameter uppercaseanchorbar             | (boolean) Uppercase the anchor bar labels. Default: true.
    "! @parameter showfooter                     | (boolean) Show floating footer. Default: false. Since 1.40.
    "! @parameter alwaysshowcontentheader        | (boolean) Always show the content header. Default: false. Since 1.34.
    "! @parameter enablelazyloading              | (boolean) Lazy-render sub-sections. Default: false.
    "! @parameter flexenabled                    | (boolean) Page is configured for SAPUI5 flex changes. Default: false. Since 1.34.
    "! @parameter headercontentpinnable          | (boolean) Render a pin button on the header. Default: true. Since 1.52.
    "! @parameter headercontentpinned            | (boolean) Initial pinned state. Default: false. Since 1.93.
    "! @parameter ischildpage                    | (boolean) Mark page as embedded child. Default: false. Since 1.34.
    "! @parameter preserveheaderstateonscroll    | (boolean) Keep header expanded while scrolling. Default: false. Since 1.52.
    "! @parameter showanchorbar                  | (boolean) Show the anchor bar. Default: true.
    "! @parameter showanchorbarpopover           | (boolean) Show sub-section popover on anchor button hover. Default: true.
    "! @parameter showheadercontent              | (boolean) Show the header content area. Default: true.
    "! @parameter showonlyhighimportance         | (boolean) Render only high-importance sub-sections. Default: false. Since 1.32.
    "! @parameter subsectionlayout               | (sap.uxap.ObjectPageSubSectionLayout) TitleOnTop | TitleOnLeft. Default: TitleOnTop.
    "! @parameter toggleheaderontitleclick       | (boolean) Click on title toggles header expand state. Default: true. Since 1.52.
    "! @parameter useicontabbar                  | (boolean) Render anchor bar as IconTabBar. Default: false.
    "! @parameter usetwocolumnsforlargescreen    | (boolean) Use 2-column layout on large screens. Default: false.
    "! @parameter visible                        | (boolean) Whether the layout is visible. Default: true.
    "! @parameter backgrounddesignanchorbar      | (sap.m.BackgroundDesign) Background of the anchor bar: Solid | Translucent | Transparent. Since 1.58.
    "! @parameter height                         | (sap.ui.core.CSSSize) Height of the layout. Default: 100%.
    "! @parameter sectiontitlelevel              | (sap.ui.core.TitleLevel) Auto | H1 | H2 | H3 | H4 | H5 | H6. Default: Auto. Since 1.44.
    "! @parameter beforenavigate                 | (event) Fired before navigation; supports preventDefault. Provides section, subSection. Since 1.118.
    "! @parameter headercontentpinnedstatechange | (event) Fired when the pinned state changes via user interaction. Since 1.93.
    "! @parameter navigate                       | (event) Fired after section selection changes. Since 1.40.
    "! @parameter sectionchange                  | (event) Fired on section change via scrolling. Since 1.73.
    "! @parameter subsectionvisibilitychange     | (event) Fired when sub-section visibility changes. Since 1.77.
    "! @parameter toggleanchorbar                | (event) Fired when the anchor bar transitions between fixed/moving.
    "! @parameter class                          | (string) CSS class names.
    METHODS object_page_layout
      IMPORTING
        showtitleinheadercontent       TYPE clike OPTIONAL
        showeditheaderbutton           TYPE clike OPTIONAL
        editheaderbuttonpress          TYPE clike OPTIONAL
        uppercaseanchorbar             TYPE clike OPTIONAL
        showfooter                     TYPE clike OPTIONAL
        alwaysshowcontentheader        TYPE clike OPTIONAL
        enablelazyloading              TYPE clike OPTIONAL
        flexenabled                    TYPE clike OPTIONAL
        headercontentpinnable          TYPE clike OPTIONAL
        headercontentpinned            TYPE clike OPTIONAL
        ischildpage                    TYPE clike OPTIONAL
        preserveheaderstateonscroll    TYPE clike OPTIONAL
        showanchorbar                  TYPE clike OPTIONAL
        showanchorbarpopover           TYPE clike OPTIONAL
        showheadercontent              TYPE clike OPTIONAL
        showonlyhighimportance         TYPE clike OPTIONAL
        subsectionlayout               TYPE clike OPTIONAL
        toggleheaderontitleclick       TYPE clike OPTIONAL
        useicontabbar                  TYPE clike OPTIONAL
        usetwocolumnsforlargescreen    TYPE clike OPTIONAL
        visible                        TYPE clike OPTIONAL
        backgrounddesignanchorbar      TYPE clike OPTIONAL
        height                         TYPE clike OPTIONAL
        sectiontitlelevel              TYPE clike OPTIONAL
        beforenavigate                 TYPE clike OPTIONAL
        headercontentpinnedstatechange TYPE clike OPTIONAL
        navigate                       TYPE clike OPTIONAL
        sectionchange                  TYPE clike OPTIONAL
        subsectionvisibilitychange     TYPE clike OPTIONAL
        toggleanchorbar                TYPE clike OPTIONAL
        class                          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.uxap.ObjectPageHeader</p>
    "!
    "! Classic (snappable) header title for ObjectPageLayout. See https://ui5.sap.com/#/api/sap.uxap.ObjectPageHeader.
    "! For dynamic-page-style headers use `object_page_dyn_header_title` (sap.uxap.ObjectPageDynamicHeaderTitle).
    "!
    "! @parameter isactionareaalwaysvisible     | (boolean) Show actions when header is snapped. Default: true.
    "! @parameter isobjecticonalwaysvisible     | (boolean) Show object icon when header is snapped. Default: false.
    "! @parameter isobjectsubtitlealwaysvisible | (boolean) Show subtitle when snapped. Default: true.
    "! @parameter isobjecttitlealwaysvisible    | (boolean) Show title when snapped. Default: true.
    "! @parameter markchanges                   | (boolean) Indicates unsaved changes (requires showMarkers=true). Default: false. Since 1.34.
    "! @parameter markfavorite                  | (boolean) Favorite state (requires showMarkers=true). Default: false.
    "! @parameter markflagged                   | (boolean) Flagged state (requires showMarkers=true). Default: false.
    "! @parameter marklocked                    | (boolean) Locked state indicator. Default: false.
    "! @parameter objectimagealt                | (string) Alt text / tooltip for the object image. Default: empty.
    "! @parameter objectimagebackgroundcolor    | (sap.m.AvatarColor) Accent1..Accent10 | Placeholder | TileIcon | Random. Default: Accent6. Since 1.73.
    "! @parameter objectimagedensityaware       | (boolean) Density-aware image. Default: false.
    "! @parameter objectimageshape              | (sap.m.AvatarShape) Square | Circle. Default: Square.
    "! @parameter objectimageuri                | (sap.ui.core.URI) Image URI for the object.
    "! @parameter objectsubtitle                | (string) Subtitle text.
    "! @parameter objecttitle                   | (string) Title text.
    "! @parameter showmarkers                   | (boolean) Render favorite/flagged markers. Default: false.
    "! @parameter showplaceholder               | (boolean) Show placeholder when image unavailable. Default: false.
    "! @parameter showtitleselector             | (boolean) Render selector arrow next to title. Default: false.
    "! @parameter visible                       | (boolean) Whether the header is visible. Default: true.
    "! @parameter markchangespress              | (event) Fired when the unsaved-changes button is pressed. Since 1.34.
    "! @parameter marklockedpress               | (event) Fired when the locked button is pressed.
    "! @parameter titleselectorpress            | (event) Fired when the title selector arrow is pressed.
    "!
    "! `headerDesign` (sap.uxap.ObjectPageHeaderDesign) is deprecated since 1.40.1 and not exposed by this wrapper.
    METHODS object_page_header
      IMPORTING
        isactionareaalwaysvisible     TYPE clike OPTIONAL
        isobjecticonalwaysvisible     TYPE clike OPTIONAL
        isobjectsubtitlealwaysvisible TYPE clike OPTIONAL
        isobjecttitlealwaysvisible    TYPE clike OPTIONAL
        markchanges                   TYPE clike OPTIONAL
        markfavorite                  TYPE clike OPTIONAL
        markflagged                   TYPE clike OPTIONAL
        marklocked                    TYPE clike OPTIONAL
        objectimagealt                TYPE clike OPTIONAL
        objectimagebackgroundcolor    TYPE clike OPTIONAL
        objectimagedensityaware       TYPE clike OPTIONAL
        objectimageshape              TYPE clike OPTIONAL
        objectimageuri                TYPE clike OPTIONAL
        objectsubtitle                TYPE clike OPTIONAL
        objecttitle                   TYPE clike OPTIONAL
        showmarkers                   TYPE clike OPTIONAL
        showplaceholder               TYPE clike OPTIONAL
        showtitleselector             TYPE clike OPTIONAL
        visible                       TYPE clike OPTIONAL
        markchangespress              TYPE clike OPTIONAL
        marklockedpress               TYPE clike OPTIONAL
        titleselectorpress            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.uxap.ObjectPageHeaderActionButton</p>
    "!
    "! Action button in the classic ObjectPageHeader actions area. Extends sap.m.Button.
    "! See https://ui5.sap.com/#/api/sap.uxap.ObjectPageHeaderActionButton.
    "!
    "! @parameter activeicon       | (sap.ui.core.URI, Button) Icon shown while pressed.
    "! @parameter ariahaspopup     | (sap.ui.core.aria.HasPopup, Button) None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter enabled          | (boolean, Button) Whether the button is enabled. Default: true.
    "! @parameter hideicon         | (boolean) Hide the icon when overflowing into the action sheet. Default: false.
    "! @parameter hidetext         | (boolean) Hide the text on the action area button (icon only). Default: true.
    "! @parameter icon             | (sap.ui.core.URI, Button) Icon URI.
    "! @parameter icondensityaware | (boolean, Button) Density-aware icon. Default: true.
    "! @parameter iconfirst        | (boolean, Button) Render icon before the text. Default: true.
    "! @parameter importance       | (sap.uxap.Importance) Low | Medium | High. Default: High.
    "! @parameter text             | (string, Button) Button label.
    "! @parameter textdirection    | (sap.ui.core.TextDirection, Button) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter visible          | (boolean, Button) Whether the button is visible. Default: true.
    "! @parameter width            | (sap.ui.core.CSSSize, Button) Width of the button.
    "! @parameter type             | (sap.m.ButtonType, Button) Default | Accept | Reject | Transparent | Ghost | Back | Up | Unstyled |
    "!                                Emphasized | Critical | Negative | Success | Neutral | Attention. Default: Default.
    "! @parameter press            | (event, Button) Fired when the button is pressed.
    METHODS object_page_header_action_btn
      IMPORTING
        activeicon       TYPE clike OPTIONAL
        ariahaspopup     TYPE clike OPTIONAL
        enabled          TYPE clike OPTIONAL
        hideicon         TYPE clike OPTIONAL
        hidetext         TYPE clike OPTIONAL
        icon             TYPE clike OPTIONAL
        icondensityaware TYPE clike OPTIONAL
        iconfirst        TYPE clike OPTIONAL
        importance       TYPE clike OPTIONAL
        text             TYPE clike OPTIONAL
        textdirection    TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        type             TYPE clike OPTIONAL
        press            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.uxap.ObjectPageDynamicHeaderTitle</p>
    "!
    "! Modern dynamic-style header title for ObjectPageLayout. See https://ui5.sap.com/#/api/sap.uxap.ObjectPageDynamicHeaderTitle.
    "! Children are added through `heading`, `expanded_heading`, `snapped_heading`, `actions`, `navigation_actions`, `breadcrumbs`, `expanded_content`, `snapped_content` and `snapped_title_on_mobile`.
    METHODS object_page_dyn_header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.GenericTile</p>
    "!
    "! Generic tile container (used in launchpads / dashboards). See https://ui5.sap.com/#/api/sap.m.GenericTile.
    "!
    "! @parameter class                  | (string) CSS class names.
    "! @parameter header                 | (string) Header text.
    "! @parameter mode                   | (sap.m.GenericTileMode) ContentMode | HeaderMode | LineMode | IconMode | ActionMode | ArticleMode. Default: ContentMode.
    "! @parameter additionaltooltip      | (string) Extra text added to the auto-generated tooltip. Since 1.82.
    "! @parameter appshortcut            | (string) Application shortcut/ID text. Since 1.92.
    "! @parameter backgroundcolor        | (string) Background color (IconMode only). Since 1.96.
    "! @parameter backgroundimage        | (sap.ui.core.URI) Background image URI.
    "! @parameter dropareaoffset         | (int) Drop area offset for drag-and-drop. Default: 0. Since 1.118.
    "! @parameter press                  | (event) Fired when the tile is pressed.
    "! @parameter frametype              | (sap.m.FrameType) OneByOne | TwoByOne | OneByHalf | TwoByHalf. Default: OneByOne.
    "! @parameter failedtext             | (string) Message shown in Failed state.
    "! @parameter headerimage            | (sap.ui.core.URI) Image rendered inside the header.
    "! @parameter scope                  | (sap.m.GenericTileScope) Display | Actions | ActionMore | ActionRemove. Default: Display. Since 1.46.
    "! @parameter sizebehavior           | (sap.m.TileSizeBehavior) Responsive | Small. Default: Responsive. Since 1.44.
    "! @parameter state                  | (sap.m.LoadState) Loaded | Loading | Failed | Disabled. Default: Loaded.
    "! @parameter systeminfo             | (string) Backend system context information. Since 1.92.
    "! @parameter tilebadge              | (string) Badge text (max 3 chars). Since 1.113.
    "! @parameter tileicon               | (sap.ui.core.URI) Icon (IconMode only). Since 1.96.
    "! @parameter url                    | (sap.ui.core.URI) Renders the tile linking to this URL. Since 1.76.
    "! @parameter valuecolor             | (sap.m.ValueColor) None | Good | Error | Critical | Neutral. Default: None. Since 1.95.
    "! @parameter width                  | (sap.ui.core.CSSSize) Width. Since 1.72.
    "! @parameter wrappingtype           | (sap.m.WrappingType) Normal | Hyphenated. Default: Normal. Since 1.60.
    "! @parameter imagedescription       | (string) Accessibility description for the header image.
    "! @parameter navigationbuttontext   | (string) Navigation button text (ArticleMode only). Since 1.96.
    "! @parameter visible                | (boolean) Whether the tile is visible. Default: true.
    "! @parameter renderonthemechange    | (boolean) Re-render the tile on theme change. Default: false. Since 1.106.
    "! @parameter enablenavigationbutton | (boolean) Render link as button (ArticleMode). Default: false. Since 1.96.
    "! @parameter pressenabled           | (boolean) Whether the press event is enabled. Default: true. Since 1.96.
    "! @parameter iconloaded             | (event) Fired when the tile icon finishes loading. Since 1.103.
    "! @parameter subheader              | (string) Subheader text.
    METHODS generic_tile
      IMPORTING
        class                  TYPE clike OPTIONAL
        id                     TYPE clike OPTIONAL
        header                 TYPE clike OPTIONAL
        mode                   TYPE clike OPTIONAL
        additionaltooltip      TYPE clike OPTIONAL
        appshortcut            TYPE clike OPTIONAL
        backgroundcolor        TYPE clike OPTIONAL
        backgroundimage        TYPE clike OPTIONAL
        dropareaoffset         TYPE clike OPTIONAL
        press                  TYPE clike OPTIONAL
        frametype              TYPE clike OPTIONAL
        failedtext             TYPE clike OPTIONAL
        headerimage            TYPE clike OPTIONAL
        scope                  TYPE clike OPTIONAL
        sizebehavior           TYPE clike OPTIONAL
        state                  TYPE clike OPTIONAL
        systeminfo             TYPE clike OPTIONAL
        tilebadge              TYPE clike OPTIONAL
        tileicon               TYPE clike OPTIONAL
        url                    TYPE clike OPTIONAL
        valuecolor             TYPE clike OPTIONAL
        width                  TYPE clike OPTIONAL
        wrappingtype           TYPE clike OPTIONAL
        imagedescription       TYPE clike OPTIONAL
        navigationbuttontext   TYPE clike OPTIONAL
        visible                TYPE clike OPTIONAL
        renderonthemechange    TYPE clike OPTIONAL
        enablenavigationbutton TYPE clike OPTIONAL
        pressenabled           TYPE clike OPTIONAL
        iconloaded             TYPE clike OPTIONAL
        subheader              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.NumericContent</p>
    "!
    "! Numeric content rendered inside `TileContent` of `GenericTile`. See https://ui5.sap.com/#/api/sap.m.NumericContent.
    "!
    "! @parameter value             | (string) The numeric value as text.
    "! @parameter icon              | (sap.ui.core.URI) Icon (alternative to a numeric value).
    "! @parameter withmargin        | (boolean) Apply default margin. Default: true.
    "! @parameter adaptivefontsize  | (boolean) Language-adaptive font scaling. Default: true.
    "! @parameter animatetextchange | (boolean) Animate value transitions. Default: true.
    "! @parameter formattervalue    | (boolean) Indicates the value already includes its scale. Default: false.
    "! @parameter icondescription   | (string) Accessibility tooltip for the icon.
    "! @parameter indicator         | (sap.m.DeviationIndicator) None | Up | Down. Default: None.
    "! @parameter nullifyvalue      | (boolean) Render zero when value is empty. Default: true.
    "! @parameter scale             | (string) Scale prefix (currency / SI unit, max 3 chars).
    "! @parameter state             | (sap.m.LoadState) Loaded | Loading | Failed | Disabled. Default: Loaded.
    "! @parameter truncatevalueto   | (int) Maximum displayed character count.
    "! @parameter valuecolor        | (sap.m.ValueColor) None | Good | Error | Critical | Neutral. Default: Neutral.
    "! @parameter visible           | (boolean) Whether the content is visible. Default: true.
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter class             | (string) CSS class names.
    "! @parameter press             | (event) Fired when the content is pressed.
    "!
    "! `size` is deprecated since 1.38.0 (now device-dependent) and not exposed by this wrapper.
    METHODS numeric_content
      IMPORTING
        value             TYPE clike OPTIONAL
        icon              TYPE clike OPTIONAL
        withmargin        TYPE clike OPTIONAL
        adaptivefontsize  TYPE clike OPTIONAL
        animatetextchange TYPE clike OPTIONAL
        formattervalue    TYPE clike OPTIONAL
        icondescription   TYPE clike OPTIONAL
        indicator         TYPE clike OPTIONAL
        nullifyvalue      TYPE clike OPTIONAL
        scale             TYPE clike OPTIONAL
        state             TYPE clike OPTIONAL
        truncatevalueto   TYPE clike OPTIONAL
        valuecolor        TYPE clike OPTIONAL
        visible           TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.LinkTileContent</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.LinkTileContent.
    "!
    "! @parameter linkhref  | (sap.ui.core.URI) Target href of the link.
    "! @parameter linktext  | (string) Link text.
    "! @parameter iconsrc   | (sap.ui.core.URI) Icon URI.
    "! @parameter linkpress | (event) Fired when the link is pressed.
    METHODS link_tile_content
      IMPORTING
        linkhref      TYPE clike OPTIONAL
        linktext      TYPE clike OPTIONAL
        iconsrc       TYPE clike OPTIONAL
        linkpress     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ImageContent</p>
    "!
    "! Image rendered inside `TileContent` of `GenericTile`. See https://ui5.sap.com/#/api/sap.m.ImageContent.
    "!
    "! @parameter src         | (sap.ui.core.URI) Image URI.
    "! @parameter description | (string) Accessibility description.
    "! @parameter visible     | (boolean) Whether the content is visible. Default: true.
    "! @parameter class       | (string) CSS class names.
    "! @parameter press       | (event) Fired when the image is pressed.
    METHODS image_content
      IMPORTING
        src           TYPE clike OPTIONAL
        description   TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.TileContent</p>
    "!
    "! Container for tile body content. See https://ui5.sap.com/#/api/sap.m.TileContent.
    "!
    "! @parameter unit         | (string) Percent sign / currency symbol / unit of measure.
    "! @parameter footercolor  | (sap.m.ValueColor) None | Good | Error | Critical | Neutral. Default: Neutral. Since 1.44.
    "! @parameter blocked      | (boolean) Inherited block-state property (sap.ui.core.Control). Default: false.
    "! @parameter frametype    | (sap.m.FrameType) Auto | OneByOne | TwoByOne. Default: Auto.
    "! @parameter priority     | (sap.m.Priority) None | VeryHigh | High | Medium | Low. Default: None. Since 1.96.
    "! @parameter prioritytext | (string) Text inside the priority badge. Since 1.103.
    "! @parameter state        | (sap.m.LoadState) Loaded | Loading | Failed | Disabled. Default: Loaded. Since 1.100.
    "! @parameter disabled     | (boolean) Inherited - mark control as disabled. Default: false.
    "! @parameter visible      | (boolean) Whether the content is visible. Default: true.
    "! @parameter footer       | (string) Footer text.
    "! @parameter class        | (string) CSS class names.
    METHODS tile_content
      IMPORTING
        unit          TYPE clike OPTIONAL
        footercolor   TYPE clike OPTIONAL
        blocked       TYPE clike OPTIONAL
        frametype     TYPE clike OPTIONAL
        priority      TYPE clike OPTIONAL
        prioritytext  TYPE clike OPTIONAL
        state         TYPE clike OPTIONAL
        disabled      TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        footer        TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `expandedHeading`</p>
    METHODS expanded_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `snappedHeading`</p>
    METHODS snapped_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `expandedContent`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix (e.g. `f` for sap.f, `uxap` for sap.uxap).
    METHODS expanded_content
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `snappedContent`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS snapped_content
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `heading`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS heading
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `actions`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS actions
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `snappedTitleOnMobile`</p>
    METHODS snapped_title_on_mobile
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `header`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix. Default: `f` (sap.f).
    METHODS header
      IMPORTING
        ns            TYPE clike DEFAULT `f`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `navigationActions`</p>
    METHODS navigation_actions
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Avatar</p>
    "!
    "! Avatar control. See https://ui5.sap.com/#/api/sap.m.Avatar.
    "!
    "! IMPORTANT: leave `ns` empty (or default) to emit `Avatar` resolving to sap.m.Avatar via the View's xmlns.
    "! Never pass `ns = 'f'` - that produces the deprecated `sap.f.Avatar` (deprecated since 1.73, replaced by sap.m.Avatar).
    "!
    "! @parameter ns                | (string) XML namespace prefix. Leave empty for sap.m.Avatar.
    "! @parameter src               | (sap.ui.core.URI) Image URI or icon font URI. Since 1.73.
    "! @parameter class             | (string) CSS class names.
    "! @parameter displaysize       | (sap.m.AvatarSize) XS | S | M | L | XL | Custom. Default: S. Since 1.73.
    "! @parameter ariahaspopup      | (sap.ui.core.aria.HasPopup) None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter backgroundcolor   | (sap.m.AvatarColor) Accent1..Accent10 | Placeholder | TileIcon | Random | Transparent. Default: Accent6.
    "! @parameter badgeicon         | (sap.ui.core.URI) Icon shown as badge. Since 1.77.
    "! @parameter badgetooltip      | (string) Custom badge tooltip. Since 1.77.
    "! @parameter badgevaluestate   | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None. Since 1.116.
    "! @parameter customdisplaysize | (sap.ui.core.CSSSize) Used when displaySize=Custom. Default: 3rem.
    "! @parameter customfontsize    | (sap.ui.core.CSSSize) Font size when displaySize=Custom. Default: 1.125rem.
    "! @parameter displayshape      | (sap.m.AvatarShape) Circle | Square. Default: Circle.
    "! @parameter fallbackicon      | (string) Fallback icon when image fails to load (SAP icon font only).
    "! @parameter imagefittype      | (sap.m.AvatarImageFitType) Cover | Contain. Default: Cover.
    "! @parameter initials          | (string) 1-3 Latin letters shown when no image is available.
    "! @parameter showborder        | (boolean) Render a border. Default: false.
    "! @parameter decorative        | (boolean) Hide from accessibility tools. Default: false. Since 1.97.
    "! @parameter enabled           | (boolean) Whether the control is enabled. Default: true. Since 1.117.
    "! @parameter press             | (event) Fired when the avatar is pressed.
    METHODS avatar
      IMPORTING
        ns                TYPE clike OPTIONAL
        id                TYPE clike OPTIONAL
        src               TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
        displaysize       TYPE clike OPTIONAL
        ariahaspopup      TYPE clike OPTIONAL
        backgroundcolor   TYPE clike OPTIONAL
        badgeicon         TYPE clike OPTIONAL
        badgetooltip      TYPE clike OPTIONAL
        badgevaluestate   TYPE clike OPTIONAL
        customdisplaysize TYPE clike OPTIONAL
        customfontsize    TYPE clike OPTIONAL
        displayshape      TYPE clike OPTIONAL
        fallbackicon      TYPE clike OPTIONAL
        imagefittype      TYPE clike OPTIONAL
        initials          TYPE clike OPTIONAL
        showborder        TYPE clike OPTIONAL
        decorative        TYPE clike OPTIONAL
        enabled           TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.AvatarGroup</p>
    "!
    "! Avatar group rendered with `ns='f'`. See https://ui5.sap.com/#/api/sap.f.AvatarGroup.
    "!
    "! @parameter avatarcustomdisplaysize | (sap.ui.core.AbsoluteCSSSize) Custom avatar size (with avatarDisplaySize=Custom). Default: 3rem.
    "! @parameter avatarcustomfontsize    | (sap.ui.core.AbsoluteCSSSize) Custom avatar font size. Default: 1.125rem.
    "! @parameter avatardisplaysize       | (sap.m.AvatarSize) XS | S | M | L | XL | Custom. Default: S.
    "! @parameter blocked                 | (boolean) Inherited control block state.
    "! @parameter busy                    | (boolean) Inherited busy state.
    "! @parameter busyindicatordelay      | (int) Inherited - delay before busy indicator shows. Default: 1000.
    "! @parameter busyindicatorsize       | (sap.ui.core.BusyIndicatorSize) Small | Medium | Large | Auto. Default: Medium.
    "! @parameter fieldgroupids           | (string[]) Inherited - field group ids.
    "! @parameter grouptype               | (sap.f.AvatarGroupType) Group | Individual. Default: Group.
    "! @parameter visible                 | (boolean) Whether the group is visible. Default: true.
    "! @parameter tooltip                 | (string) Tooltip.
    "! @parameter items                   | (binding path) Aggregation of `sap.f.AvatarGroupItem`.
    "! @parameter press                   | (event) Fired on click. Provides `groupType`, `overflowButtonPressed`, `avatarsDisplayed`.
    METHODS avatar_group
      IMPORTING
        id                      TYPE clike     OPTIONAL
        avatarcustomdisplaysize TYPE clike     OPTIONAL
        avatarcustomfontsize    TYPE clike     OPTIONAL
        avatardisplaysize       TYPE clike     OPTIONAL
        blocked                 TYPE abap_bool OPTIONAL
        busy                    TYPE abap_bool OPTIONAL
        busyindicatordelay      TYPE clike     OPTIONAL
        busyindicatorsize       TYPE clike     OPTIONAL
        fieldgroupids           TYPE clike     OPTIONAL
        grouptype               TYPE clike     OPTIONAL
        visible                 TYPE abap_bool DEFAULT abap_true
        tooltip                 TYPE clike     OPTIONAL
        items                   TYPE clike     OPTIONAL
        press                   TYPE clike     OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.AvatarGroupItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.AvatarGroupItem.
    "!
    "! @parameter busy               | (boolean, Control) Inherited busy state. Default: false.
    "! @parameter busyindicatordelay | (int, Control) Delay before busy indicator shows. Default: 1000.
    "! @parameter busyindicatorsize  | (sap.ui.core.BusyIndicatorSize) Small | Medium | Large | Auto. Default: Medium.
    "! @parameter fallbackicon       | (string) Fallback icon when image fails to load.
    "! @parameter fieldgroupids      | (string[]) Field group ids.
    "! @parameter initials           | (string) 1-3 Latin letters shown when no image is available.
    "! @parameter src                | (sap.ui.core.URI) Image URI or icon URI.
    "! @parameter visible            | (boolean) Whether the item is visible. Default: true.
    "! @parameter tooltip            | (string) Tooltip.
    METHODS avatar_group_item
      IMPORTING
        id                 TYPE clike OPTIONAL
        busy               TYPE clike DEFAULT `false`
        busyindicatordelay TYPE clike OPTIONAL
        busyindicatorsize  TYPE clike OPTIONAL
        fallbackicon       TYPE clike OPTIONAL
        fieldgroupids      TYPE clike OPTIONAL
        initials           TYPE clike OPTIONAL
        src                TYPE clike OPTIONAL
        visible            TYPE clike DEFAULT `true`
        tooltip            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `headerTitle`</p>
    METHODS header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `sections`</p>
    METHODS sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.uxap.ObjectPageSection</p>
    "!
    "! Section grouping sub-sections inside ObjectPageLayout. Inherits from sap.uxap.ObjectPageSectionBase.
    "! See https://ui5.sap.com/#/api/sap.uxap.ObjectPageSection.
    "!
    "! @parameter titleuppercase       | (boolean) Display the section title in uppercase. Default: true.
    "! @parameter title                | (string, ObjectPageSectionBase) Section title.
    "! @parameter importance           | (sap.uxap.Importance, ObjectPageSectionBase) Low | Medium | High. Default: High.
    "! @parameter titlelevel           | (sap.ui.core.TitleLevel, ObjectPageSectionBase) Auto | H1 | H2 | H3 | H4 | H5 | H6. Default: Auto.
    "! @parameter showtitle            | (boolean) Display the section title. Default: true.
    "! @parameter visible              | (boolean, ObjectPageSectionBase) Whether the section is visible. Default: true.
    "! @parameter wraptitle            | (boolean) Wrap the title across multiple lines. Default: false.
    "! @parameter anchorbarbuttoncolor | (sap.ui.core.IconColor) Default | Positive | Negative | Critical | Neutral | Contrast | NonInteractive | Tile | Marker. Default: Default.
    "! @parameter titlevisible         | (boolean, ObjectPageSectionBase) Computed - read-only effective title visibility.
    METHODS object_page_section
      IMPORTING
        titleuppercase       TYPE clike OPTIONAL
        title                TYPE clike OPTIONAL
        importance           TYPE clike OPTIONAL
        id                   TYPE clike OPTIONAL
        titlelevel           TYPE clike OPTIONAL
        showtitle            TYPE clike OPTIONAL
        visible              TYPE clike OPTIONAL
        wraptitle            TYPE clike OPTIONAL
        anchorbarbuttoncolor TYPE clike OPTIONAL
        titlevisible         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `subSections`</p>
    METHODS sub_sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.uxap.ObjectPageSubSection</p>
    "!
    "! Sub-section containing actual content blocks. See https://ui5.sap.com/#/api/sap.uxap.ObjectPageSubSection.
    "!
    "! @parameter title          | (string) Sub-section title.
    "! @parameter mode           | (sap.uxap.ObjectPageSubSectionMode) Collapsed | Expanded. Default: Collapsed. Collapsed shows only blocks (moreBlocks behind a "See more" toggle).
    "! @parameter importance     | (sap.uxap.Importance) Low | Medium | High. Default: High.
    "! @parameter titlelevel     | (sap.ui.core.TitleLevel) Auto | H1 | H2 | H3 | H4 | H5 | H6. Default: Auto.
    "! @parameter showtitle      | (boolean) Display the sub-section title. Default: true. Overridden when only one sub-section is visible.
    "! @parameter titleuppercase | (boolean) Render title in uppercase. Default: false.
    "! @parameter visible        | (boolean) Whether the sub-section is visible. Default: true.
    "! @parameter titlevisible   | (boolean) Computed - read-only effective title visibility.
    METHODS object_page_sub_section
      IMPORTING
        id             TYPE clike OPTIONAL
        title          TYPE clike OPTIONAL
        mode           TYPE clike OPTIONAL
        importance     TYPE clike OPTIONAL
        titlelevel     TYPE clike OPTIONAL
        showtitle      TYPE clike OPTIONAL
        titleuppercase TYPE clike OPTIONAL
        visible        TYPE clike OPTIONAL
        titlevisible   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Shell</p>
    "!
    "! Shell wrapper that provides background, branding and optional width limitation. See https://ui5.sap.com/#/api/sap.m.Shell.
    "!
    "! @parameter ns              | (string) XML namespace prefix.
    "! @parameter appwidthlimited | (boolean) Limit app width to a maximum (true) or use full screen width (false). Default: true.
    METHODS shell
      IMPORTING
        ns              TYPE clike OPTIONAL
        appwidthlimited TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.ShellBar</p>
    "!
    "! Top-level shell/navigation bar. See https://ui5.sap.com/#/api/sap.f.ShellBar.
    "!
    "! @parameter homeicon               | (sap.ui.core.URI) Home icon (company/product logo).
    "! @parameter homeicontooltip        | (string) Custom tooltip for the home icon.
    "! @parameter notificationsnumber    | (string) Notification count badge text.
    "! @parameter secondtitle            | (string) Secondary title.
    "! @parameter showcopilot            | (boolean) Show CoPilot icon. Default: false. NOTE: SAP CoPilot is being phased out; consider not using.
    "! @parameter showmenubutton         | (boolean) Show menu (hamburger) button. Default: false.
    "! @parameter shownavbutton          | (boolean) Show back/navigation button. Default: false.
    "! @parameter shownotifications      | (boolean) Show notifications button. Default: false.
    "! @parameter showproductswitcher    | (boolean) Show product switcher button. Default: false.
    "! @parameter showsearch             | (boolean) Show search button. Default: false.
    "! @parameter title                  | (string) Main title.
    "! @parameter avatarpressed          | (event) Fired when the profile avatar is pressed.
    "! @parameter copilotpressed         | (event) Fired when the CoPilot icon is pressed.
    "! @parameter homeiconpressed        | (event) Fired when the home icon is pressed.
    "! @parameter menubuttonpressed      | (event) Fired when the menu button is pressed.
    "! @parameter navbuttonpressed       | (event) Fired when the back/nav button is pressed.
    "! @parameter notificationspressed   | (event) Fired when the notifications button is pressed.
    "! @parameter productswitcherpressed | (event) Fired when the product switcher button is pressed.
    "! @parameter searchbuttonpressed    | (event) Fired when the search button is pressed.
    METHODS shell_bar
      IMPORTING
        homeicon               TYPE clike     OPTIONAL
        homeicontooltip        TYPE clike     OPTIONAL
        notificationsnumber    TYPE clike     OPTIONAL
        secondtitle            TYPE clike     OPTIONAL
        showcopilot            TYPE abap_bool OPTIONAL
        showmenubutton         TYPE abap_bool OPTIONAL
        shownavbutton          TYPE abap_bool OPTIONAL
        shownotifications      TYPE abap_bool OPTIONAL
        showproductswitcher    TYPE abap_bool OPTIONAL
        showsearch             TYPE abap_bool OPTIONAL
        title                  TYPE clike     OPTIONAL
        avatarpressed          TYPE clike     OPTIONAL
        copilotpressed         TYPE clike     OPTIONAL
        homeiconpressed        TYPE clike     OPTIONAL
        menubuttonpressed      TYPE clike     OPTIONAL
        navbuttonpressed       TYPE clike     OPTIONAL
        notificationspressed   TYPE clike     OPTIONAL
        productswitcherpressed TYPE clike     OPTIONAL
        searchbuttonpressed    TYPE clike     OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `blocks`</p>
    METHODS blocks
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `moreBlocks`</p>
    METHODS more_blocks
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `layoutData`</p>
    "!
    "! Wrap the actual layout-data control (e.g. FlexItemData, GridData, OverflowToolbarLayoutData).
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS layout_data
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FlexItemData</p>
    "!
    "! Layout data for children of `sap.m.FlexBox`. See https://ui5.sap.com/#/api/sap.m.FlexItemData.
    "!
    "! @parameter growfactor       | (float) flex-grow factor. Default: 0.
    "! @parameter basesize         | (sap.ui.core.CSSSize) flex-basis (initial main-axis size). Default: auto.
    "! @parameter backgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Transparent.
    "! @parameter styleclass       | (string) CSS class applied to the flex item.
    "! @parameter order            | (int) Display order independent of source order. Default: 0.
    "! @parameter shrinkfactor     | (float) flex-shrink factor. Default: 1.
    METHODS flex_item_data
      IMPORTING
        growfactor       TYPE clike OPTIONAL
        basesize         TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        styleclass       TYPE clike OPTIONAL
        order            TYPE clike OPTIONAL
        shrinkfactor     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.codeeditor.CodeEditor</p>
    "!
    "! ACE-based code editor with syntax highlighting. See https://ui5.sap.com/#/api/sap.ui.codeeditor.CodeEditor.
    "!
    "! @parameter value    | (string) Source code content.
    "! @parameter type     | (string) Syntax highlighting mode (ACE mode), e.g. abap | javascript | json | xml | html | css | sql | markdown | python | java | yaml. Default: javascript.
    "! @parameter height   | (sap.ui.core.CSSSize) Editor height. Default: 100%.
    "! @parameter width    | (sap.ui.core.CSSSize) Editor width. Default: 100%.
    "! @parameter editable | (boolean) Allow user edits. Default: true.
    METHODS code_editor
      IMPORTING
        value         TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `suggestionItems`</p>
    METHODS suggestion_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">UI5 sap.ui.core.Item / sap.ui.core.ListItem</p>
    "!
    "! Lightweight item used inside `Input.suggestionItems`. See https://ui5.sap.com/#/api/sap.ui.core.ListItem.
    "!
    "! @parameter description   | (string) Optional secondary text shown next to the main text.
    "! @parameter icon          | (string) Icon URI.
    "! @parameter key           | (string) Item key.
    "! @parameter text          | (string) Display text.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    METHODS suggestion_item
      IMPORTING
        description   TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `suggestionColumns`</p>
    METHODS suggestion_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `suggestionRows`</p>
    METHODS suggestion_rows
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.VerticalLayout</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.VerticalLayout.
    "!
    "! @parameter class   | (string) CSS class names.
    "! @parameter width   | (sap.ui.core.CSSSize) Width. If unset, the content's natural width is used.
    "! @parameter enabled | (boolean) When false all controls inside are disabled. Default: true.
    "! @parameter visible | (boolean) Whether the layout is visible. Default: true.
    METHODS vertical_layout
      IMPORTING
        class         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MultiInput</p>
    "!
    "! Input that displays accepted values as tokens. See https://ui5.sap.com/#/api/sap.m.MultiInput.
    "! Most properties are inherited from sap.m.Input / sap.m.InputBase.
    "!
    "! @parameter showclearicon    | (boolean, Input) Show a clear icon. Default: false. Since 1.94.
    "! @parameter showvaluehelp    | (boolean, Input) Render value help icon. Default: false.
    "! @parameter valuehelponly    | (boolean, Input) DEPRECATED since 1.119 - typing is no longer suppressed. Default: false.
    "! @parameter name             | (string) HTML form name.
    "! @parameter suggestionitems  | (binding path, Input) Aggregation of suggestion items.
    "! @parameter tokenupdate      | (event) Fired when tokens are added or removed. Provides type, addedTokens, removedTokens. Since 1.46.
    "! @parameter width            | (sap.ui.core.CSSSize, InputBase) Width of the control.
    "! @parameter value            | (string, InputBase) Two-way bound value. Use `client->_bind_edit( var )`.
    "! @parameter tokens           | (binding path) Aggregation of `sap.m.Token`.
    "! @parameter submit           | (event, Input) Fired when the user presses Enter.
    "! @parameter valuehelprequest | (event, Input) Fired when the value help icon is pressed.
    "! @parameter enabled          | (boolean, InputBase) Whether the input is enabled. Default: true.
    "! @parameter class            | (string) CSS class names.
    "! @parameter change           | (event, InputBase) Fired when the value is committed.
    "! @parameter required         | (boolean, InputBase) Marks the field as required. Default: false.
    "! @parameter valuestate       | (sap.ui.core.ValueState, InputBase) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext   | (string, InputBase) Text shown in the value state message popup.
    "! @parameter placeholder      | (string, InputBase) Placeholder shown while empty.
    "! @parameter showsuggestion   | (boolean, Input) Enable suggestion popover. Default for MultiInput: true (note: Input's default is false).
    "! @parameter visible          | (boolean) Whether the input is visible. Default: true.
    "!
    "! Note: `tokenChange` event is deprecated since 1.46 - use `tokenUpdate`.
    METHODS multi_input
      IMPORTING
        showclearicon    TYPE clike OPTIONAL
        showvaluehelp    TYPE clike OPTIONAL
        valuehelponly    TYPE clike OPTIONAL
        name             TYPE clike OPTIONAL
        suggestionitems  TYPE clike OPTIONAL
        tokenupdate      TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        value            TYPE clike OPTIONAL
        tokens           TYPE clike OPTIONAL
        submit           TYPE clike OPTIONAL
        valuehelprequest TYPE clike OPTIONAL
        enabled          TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        change           TYPE clike OPTIONAL
        required         TYPE clike OPTIONAL
        valuestate       TYPE clike OPTIONAL
        valuestatetext   TYPE clike OPTIONAL
        placeholder      TYPE clike OPTIONAL
        showsuggestion   TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `tokens`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS tokens
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Token</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Token.
    "!
    "! @parameter key      | (string) Key value of the token.
    "! @parameter text     | (string) Displayed token text.
    "! @parameter selected | (boolean) Selected state. Default: false.
    "! @parameter visible  | (boolean) Whether the token is visible. Default: true.
    "! @parameter editable | (boolean) When true the token shows a delete icon. Default: true.
    METHODS token
      IMPORTING
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Input</p>
    "!
    "! Single-line input control with optional value help, suggestions and validation states.
    "! See https://ui5.sap.com/#/api/sap.m.Input. Inherits properties from sap.m.InputBase.
    "!
    "! @parameter value                         | (string, InputBase) Two-way bound value. Use `client->_bind_edit( var )`.
    "! @parameter placeholder                   | (string, InputBase) Placeholder shown while empty.
    "! @parameter type                          | (sap.m.InputType) Text | Email | Number | Password | Tel | Url. Default: Text.
    "!                                            Old types Date, Time, Datetime, DatetimeLocale, Month, Week and Passport are
    "!                                            deprecated/removed - use sap.m.DatePicker / TimePicker instead.
    "! @parameter showclearicon                 | (boolean) Shows a clear icon to remove the entered value. Default: false. Since 1.94.
    "! @parameter valuestate                    | (sap.ui.core.ValueState, InputBase) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext                | (string, InputBase) Text shown in the value state message popup.
    "! @parameter showtablesuggestionvaluehelp  | (boolean) Renders a value help button below tabular suggestions. Default: true. Since 1.22.1.
    "! @parameter description                   | (string) Short description rendered after the input (e.g. unit).
    "! @parameter editable                      | (boolean, InputBase) Whether the input is editable. Default: true.
    "! @parameter enabled                       | (boolean, InputBase) Whether the input is enabled. Default: true.
    "! @parameter suggestionitems               | (binding path) Aggregation of `sap.ui.core.Item` for plain suggestions.
    "! @parameter suggestionrows                | (binding path) Aggregation of rows for tabular suggestions.
    "! @parameter showsuggestion                | (boolean) Enables suggestion popover; raises the `suggest` event. Default: false. Since 1.16.1.
    "! @parameter showvaluehelp                 | (boolean) Renders a value help icon. Default: false. Since 1.16.
    "! @parameter valuehelprequest              | (event) Fired when the value help icon is pressed.
    "! @parameter required                      | (boolean, InputBase) Marks the field as required. Default: false.
    "! @parameter suggest                       | (event) Fired when the user types and `showSuggestion=true`.
    "! @parameter class                         | (string) CSS class names.
    "! @parameter visible                       | (boolean) Whether the input is visible. Default: true.
    "! @parameter submit                        | (event) Fired when the user presses Enter.
    "! @parameter valueliveupdate               | (boolean) Updates the value model on every keystroke. Default: false. Since 1.24.
    "! @parameter autocomplete                  | (boolean) Browser autocomplete. Default: true. Since 1.61.
    "! @parameter maxsuggestionwidth            | (sap.ui.core.CSSSize) Maximum width of the suggestion list. Since 1.21.1.
    "! @parameter fieldwidth                    | (sap.ui.core.CSSSize) Width share of the input field versus the description. Default: 50%.
    "! @parameter valuehelponly                 | (boolean) DEPRECATED since 1.119 - typing is no longer suppressed. Restricts input to value help only. Default: false.
    "! @parameter width                         | (sap.ui.core.CSSSize, InputBase) Width of the control.
    "! @parameter change                        | (event, InputBase) Fired when the value is committed (focus loss / Enter).
    "! @parameter valuehelpiconsrc              | (sap.ui.core.URI) Custom value help icon. Default: `sap-icon://value-help`. Since 1.84.
    "! @parameter textformatter                 | (function) Custom display formatter for selected suggestion. Since 1.44.
    "! @parameter textformatmode                | (sap.m.InputTextFormatMode) Display format of selected suggestion: Value | Key | KeyValue | ValueKey. Default: Value. Since 1.44.
    "! @parameter maxlength                     | (int, InputBase) Maximum number of characters. 0 = no limit. Default: 0. Not effective when `type=Number`.
    "! @parameter startsuggestion               | (int) Minimum number of characters before suggestions trigger. Default: 1. Since 1.21.2.
    "! @parameter enablesuggestionshighlighting | (boolean) Highlight matching characters in suggestions. Default: true. Since 1.46.
    "! @parameter enabletableautopopinmode      | (boolean) Auto pop-in for table suggestions. Default: false. Since 1.89.
    "! @parameter arialabelledby                | (sap.ui.core.ID[]) Ids of labelling controls (ARIA).
    "! @parameter ariadescribedby               | (sap.ui.core.ID[]) Ids of describing controls (ARIA).
    METHODS input
      IMPORTING
        id                            TYPE clike OPTIONAL
        value                         TYPE clike OPTIONAL
        placeholder                   TYPE clike OPTIONAL
        type                          TYPE clike OPTIONAL
        showclearicon                 TYPE clike OPTIONAL
        valuestate                    TYPE clike OPTIONAL
        valuestatetext                TYPE clike OPTIONAL
        showtablesuggestionvaluehelp  TYPE clike OPTIONAL
        description                   TYPE clike OPTIONAL
        editable                      TYPE clike OPTIONAL
        enabled                       TYPE clike OPTIONAL
        suggestionitems               TYPE clike OPTIONAL
        suggestionrows                TYPE clike OPTIONAL
        showsuggestion                TYPE clike OPTIONAL
        showvaluehelp                 TYPE clike OPTIONAL
        valuehelprequest              TYPE clike OPTIONAL
        required                      TYPE clike OPTIONAL
        suggest                       TYPE clike OPTIONAL
        class                         TYPE clike OPTIONAL
        visible                       TYPE clike OPTIONAL
        submit                        TYPE clike OPTIONAL
        valueliveupdate               TYPE clike OPTIONAL
        autocomplete                  TYPE clike OPTIONAL
        maxsuggestionwidth            TYPE clike OPTIONAL
        fieldwidth                    TYPE clike OPTIONAL
        valuehelponly                 TYPE clike OPTIONAL
        width                         TYPE clike OPTIONAL
        change                        TYPE clike OPTIONAL
        valuehelpiconsrc              TYPE clike OPTIONAL
        textformatter                 TYPE clike OPTIONAL
        textformatmode                TYPE clike OPTIONAL
        maxlength                     TYPE clike OPTIONAL
        startsuggestion               TYPE clike OPTIONAL
        enablesuggestionshighlighting TYPE clike OPTIONAL
        enabletableautopopinmode      TYPE clike OPTIONAL
        arialabelledby                TYPE clike OPTIONAL
        ariadescribedby               TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Dialog</p>
    "!
    "! Modal dialog with header, content and buttons. See https://ui5.sap.com/#/api/sap.m.Dialog.
    "!
    "! @parameter title               | (string) Header title text.
    "! @parameter icon                | (sap.ui.core.URI) Header icon (density-aware).
    "! @parameter showheader          | (boolean) Display header section. Default: true.
    "! @parameter stretch             | (boolean) Stretch to full screen on mobile. Default: false.
    "! @parameter contentheight       | (sap.ui.core.CSSSize) Preferred content height.
    "! @parameter contentwidth        | (sap.ui.core.CSSSize) Preferred content width.
    "! @parameter resizable           | (boolean) Whether the dialog is resizable. Default: false.
    "! @parameter horizontalscrolling | (boolean) Allow horizontal scrolling. Default: true.
    "! @parameter verticalscrolling   | (boolean) Allow vertical scrolling. Default: true.
    "! @parameter afterclose          | (event) Fired after the dialog has closed.
    "! @parameter beforeopen          | (event) Fired before the dialog opens.
    "! @parameter beforeclose         | (event) Fired before the dialog closes.
    "! @parameter afteropen           | (event) Fired after the dialog has opened.
    "! @parameter draggable           | (boolean) Whether the dialog is draggable. Default: false.
    "! @parameter closeonnavigation   | (boolean) Auto-close on routing navigation. Default: true.
    "! @parameter escapehandler       | (function) Custom escape key handler.
    "! @parameter type                | (sap.m.DialogType) Standard | Message. Default: Standard.
    "! @parameter titlealignment      | (sap.m.TitleAlignment) Auto | Start | Center. Default: Auto.
    "! @parameter state               | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    METHODS dialog
      IMPORTING
        title               TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
        showheader          TYPE clike OPTIONAL
        stretch             TYPE clike OPTIONAL
        contentheight       TYPE clike OPTIONAL
        contentwidth        TYPE clike OPTIONAL
        resizable           TYPE clike OPTIONAL
        horizontalscrolling TYPE clike OPTIONAL
        verticalscrolling   TYPE clike OPTIONAL
        afterclose          TYPE clike OPTIONAL
        beforeopen          TYPE clike OPTIONAL
        beforeclose         TYPE clike OPTIONAL
        afteropen           TYPE clike OPTIONAL
        draggable           TYPE clike OPTIONAL
        closeonnavigation   TYPE clike OPTIONAL
        escapehandler       TYPE clike OPTIONAL
        type                TYPE clike OPTIONAL
        titlealignment      TYPE clike OPTIONAL
        state               TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Carousel</p>
    "!
    "! Paged carousel. See https://ui5.sap.com/#/api/sap.m.Carousel.
    "!
    "! @parameter height                        | (sap.ui.core.CSSSize) Carousel height. Default: 100%.
    "! @parameter class                         | (string) CSS class names.
    "! @parameter loop                          | (boolean) Cycle from last page back to first. Default: false.
    "! @parameter arrowsplacement               | (sap.m.CarouselArrowsPlacement) Content | PageIndicator. Default: Content.
    "! @parameter backgrounddesign              | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Translucent. Since 1.110.
    "! @parameter pageindicatorbackgrounddesign | (sap.m.BackgroundDesign) Background of page indicator. Default: Solid. Since 1.115.
    "! @parameter pageindicatorborderdesign     | (sap.m.BorderDesign) Solid | None. Default: Solid. Since 1.115.
    "! @parameter pageindicatorplacement        | (sap.m.PlacementType) Top | Bottom | OverContentTop | OverContentBottom. Default: Bottom.
    "! @parameter width                         | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter showpageindicator             | (boolean) Show the page indicator. Default: true.
    "! @parameter visible                       | (boolean) Whether the carousel is visible. Default: true.
    "! @parameter pages                         | (binding path) Aggregation of pages.
    METHODS carousel
      IMPORTING
        height                        TYPE clike OPTIONAL
        class                         TYPE clike OPTIONAL
        loop                          TYPE clike OPTIONAL
        id                            TYPE clike OPTIONAL
        arrowsplacement               TYPE clike OPTIONAL
        backgrounddesign              TYPE clike OPTIONAL
        pageindicatorbackgrounddesign TYPE clike OPTIONAL
        pageindicatorborderdesign     TYPE clike OPTIONAL
        pageindicatorplacement        TYPE clike OPTIONAL
        width                         TYPE clike OPTIONAL
        showpageindicator             TYPE clike OPTIONAL
        visible                       TYPE clike OPTIONAL
        pages                         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `buttons`</p>
    METHODS buttons
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Builder helper</p>
    METHODS get_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Builder helper</p>
    METHODS get_parent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Builder helper - jump to a named ancestor / sibling element</p>
    "!
    "! @parameter name | (string) Element name to navigate to.
    METHODS get
      IMPORTING
        name          TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Builder helper - jump to the n-th child of the current node</p>
    "!
    "! @parameter index | (i) 1-based child index. Default: 1.
    METHODS get_child
      IMPORTING
        index         TYPE i DEFAULT 1
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `columns`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS columns
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.AnalyticalColumn</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.AnalyticalColumn. Use the `column` builder for sap.m and `analytical_column` for AnalyticalTable.
    "!
    "! @parameter ns | (string) XML namespace prefix (typically `t`).
    METHODS analytical_column
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Column</p>
    "!
    "! Responsive table column. See https://ui5.sap.com/#/api/sap.m.Column.
    "!
    "! @parameter width             | (sap.ui.core.CSSSize) Column width. Empty = remaining space.
    "! @parameter minscreenwidth    | (string) Hide column below this screen width (e.g. `Small`, `Medium`, `Large`, `30em`).
    "! @parameter demandpopin       | (boolean) Show as pop-in instead of hiding when below minScreenWidth. Default: false.
    "! @parameter halign            | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Begin.
    "! @parameter visible           | (boolean) Whether the column is visible. Default: true.
    "! @parameter valign            | (sap.ui.core.VerticalAlign) Bottom | Inherit | Middle | Top. Default: Inherit.
    "! @parameter styleclass        | (string) CSS class for the column and its pop-in rows.
    "! @parameter sortindicator     | (sap.ui.core.SortOrder) None | Ascending | Descending. Default: None. Since 1.61.
    "! @parameter popindisplay      | (sap.m.PopinDisplay) Block | Inline | WithoutHeader. Default: Block. Since 1.13.2.
    "! @parameter mergefunctionname | (string) Function used when merging duplicate cells. Default: `getText`. Since 1.16.
    "! @parameter mergeduplicates   | (boolean) Merge repeating cells. Default: false. Since 1.16.
    "! @parameter importance        | (sap.ui.core.Priority) None | Low | Medium | High. Default: None. Used by `autoPopinMode`. Since 1.76.
    "! @parameter autopopinwidth    | (float) Auto-pop-in column width in rem. Default: 8. Since 1.76.
    "! @parameter class             | (string) CSS class names.
    "! @parameter headermenu        | (sap.ui.core.ID) Id of an `IColumnHeaderMenu` association. Since 1.98.
    METHODS column
      IMPORTING
        width             TYPE clike OPTIONAL
        id                TYPE clike OPTIONAL
        minscreenwidth    TYPE clike OPTIONAL
        demandpopin       TYPE clike OPTIONAL
        halign            TYPE clike OPTIONAL
        visible           TYPE clike OPTIONAL
        valign            TYPE clike OPTIONAL
        styleclass        TYPE clike OPTIONAL
        sortindicator     TYPE clike OPTIONAL
        popindisplay      TYPE clike OPTIONAL
        mergefunctionname TYPE clike OPTIONAL
        mergeduplicates   TYPE clike OPTIONAL
        importance        TYPE clike OPTIONAL
        autopopinwidth    TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
        headermenu        TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `items`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS items
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.InteractiveDonutChart</p>
    "!
    "! Donut microchart with selectable segments. See https://ui5.sap.com/#/api/sap.suite.ui.microchart.InteractiveDonutChart.
    "!
    "! @parameter selectionchanged  | (event) Fired when segment selection changes. Provides `selectedSegments`, `allSelectedSegments`, `segment`, `selected`.
    "! @parameter errormessage      | (string) Error/empty-state message text.
    "! @parameter errormessagetitle | (string) Error/empty-state message title.
    "! @parameter showerror         | (boolean) Render the error/empty state. Default: false.
    "! @parameter displayedsegments | (int) Number of segments rendered (max 4). Default: 3.
    "! @parameter press             | (event) Fired when the chart is pressed.
    "! @parameter segments          | (binding path) Aggregation of `InteractiveDonutChartSegment`.
    "! @parameter selectionenabled  | (boolean) Whether segments can be selected. Default: true.
    METHODS interact_donut_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
        displayedsegments TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        segments          TYPE clike OPTIONAL
        selectionenabled  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `segments`</p>
    METHODS segments
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.InteractiveDonutChartSegment</p>
    "!
    "! @parameter label          | (string) Segment label.
    "! @parameter value          | (float) Numeric value (sum of all segments = 100% of donut).
    "! @parameter displayedvalue | (string) Pre-formatted value text shown in the tooltip.
    "! @parameter selected       | (boolean) Selected state. Default: false.
    "! @parameter color          | (sap.m.ValueCSSColor) Good | Error | Critical | Neutral | CSS color string. Default: Neutral.
    METHODS interact_donut_chart_segment
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
        color          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.InteractiveBarChart</p>
    "!
    "! Horizontal bar microchart with selectable bars. See https://ui5.sap.com/#/api/sap.suite.ui.microchart.InteractiveBarChart.
    "!
    "! @parameter selectionchanged  | (event) Fired when bar selection changes.
    "! @parameter selectionenabled  | (boolean) Whether bars can be selected. Default: true.
    "! @parameter press             | (event) Fired when the chart is pressed.
    "! @parameter labelwidth        | (sap.ui.core.CSSSize) Width of the label area as a percentage. Default: 40%.
    "! @parameter errormessage      | (string) Error/empty-state message text.
    "! @parameter errormessagetitle | (string) Error/empty-state message title.
    "! @parameter showerror         | (boolean) Render the error/empty state. Default: false.
    "! @parameter displayedbars     | (int) Number of bars rendered (max 10). Default: 3.
    "! @parameter bars              | (binding path) Aggregation of `InteractiveBarChartBar`.
    "! @parameter max               | (float) Maximum value for the value scale (auto when undefined).
    "! @parameter min               | (float) Minimum value for the value scale (auto when undefined).
    METHODS interact_bar_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        selectionenabled  TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        labelwidth        TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
        displayedbars     TYPE clike OPTIONAL
        bars              TYPE clike OPTIONAL
        max               TYPE clike OPTIONAL
        min               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `bars`</p>
    METHODS bars
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.InteractiveBarChartBar</p>
    "!
    "! @parameter label          | (string) Bar label.
    "! @parameter value          | (float) Numeric value.
    "! @parameter displayedvalue | (string) Pre-formatted value text.
    "! @parameter selected       | (boolean) Selected state. Default: false.
    "! @parameter color          | (sap.m.ValueCSSColor) Good | Error | Critical | Neutral | CSS color string. Default: Neutral.
    METHODS interact_bar_chart_bar
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
        color          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.InteractiveLineChart</p>
    "!
    "! Line microchart with selectable points. See https://ui5.sap.com/#/api/sap.suite.ui.microchart.InteractiveLineChart.
    "!
    "! @parameter selectionchanged  | (event) Fired when point selection changes.
    "! @parameter press             | (event) Fired when the chart is pressed.
    "! @parameter precedingpoint    | (float) Value preceding the first displayed point (drawn as a dashed continuation).
    "! @parameter succeedingpoint   | (float) Value succeeding the last displayed point.
    "! @parameter errormessage      | (string) Error/empty-state message text.
    "! @parameter errormessagetitle | (string) Error/empty-state message title.
    "! @parameter showerror         | (boolean) Render the error/empty state. Default: false.
    "! @parameter displayedpoints   | (int) Number of points rendered. Default: 6.
    "! @parameter selectionenabled  | (boolean) Whether points can be selected. Default: true.
    "! @parameter points            | (binding path) Aggregation of `InteractiveLineChartPoint`.
    METHODS interact_line_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        precedingpoint    TYPE clike OPTIONAL
        succeedingpoint   TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
        displayedpoints   TYPE clike OPTIONAL
        selectionenabled  TYPE clike OPTIONAL
        points            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `points`</p>
    METHODS points
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.InteractiveLineChartPoint</p>
    "!
    "! @parameter label          | (string) Primary label.
    "! @parameter value          | (float) Numeric value.
    "! @parameter secondarylabel | (string) Secondary label (e.g. shown beneath the primary).
    "! @parameter displayedvalue | (string) Pre-formatted value text.
    "! @parameter selected       | (boolean) Selected state. Default: false.
    METHODS interact_line_chart_point
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        secondarylabel TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.RadialMicroChart</p>
    "!
    "! Radial / circular percentage micro chart. See https://ui5.sap.com/#/api/sap.suite.ui.microchart.RadialMicroChart.
    "!
    "! @parameter size         | (sap.m.Size) S | M | L | Auto | Responsive. Default: Auto.
    "! @parameter percentage   | (float) Percentage value (0 to 100).
    "! @parameter press        | (event) Fired when the chart is pressed.
    "! @parameter valuecolor   | (sap.m.ValueColor) None | Good | Error | Critical | Neutral. Default: Neutral.
    "! @parameter height       | (sap.ui.core.CSSSize) Chart height.
    "! @parameter aligncontent | (sap.m.microchart.HorizontalAlignmentType) Left | Center | Right. Default: Left.
    "! @parameter hideonnodata | (boolean) Hide the chart when no data is available. Default: false.
    METHODS radial_micro_chart
      IMPORTING
        size          TYPE clike OPTIONAL
        percentage    TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        valuecolor    TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        aligncontent  TYPE clike OPTIONAL
        hideonnodata  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ColumnListItem</p>
    "!
    "! Row of a responsive table. See https://ui5.sap.com/#/api/sap.m.ColumnListItem.
    "! Most properties are inherited from sap.m.ListItemBase.
    "!
    "! @parameter valign        | (sap.ui.core.VerticalAlign) Bottom | Inherit | Middle | Top. Default: Inherit.
    "! @parameter selected      | (boolean, ListItemBase) Selected state. Default: false.
    "! @parameter type          | (sap.m.ListType, ListItemBase) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter press         | (event, ListItemBase) Fired when the row is activated.
    "! @parameter counter       | (int, ListItemBase) Counter badge value (note: not supported on ColumnListItem).
    "! @parameter highlight     | (sap.ui.core.MessageType | sap.ui.core.IndicationColor) None | Information | Warning | Error | Success | Indication01..Indication10. Default: None.
    "! @parameter highlighttext | (string, ListItemBase) Custom accessibility text for the highlight indicator.
    "! @parameter navigated     | (boolean, ListItemBase) Whether the row is marked as navigated. Default: false.
    "! @parameter unread        | (boolean, ListItemBase) Bold formatting indicating unread state. Default: false.
    "! @parameter visible       | (boolean, ListItemBase) Whether the row is visible. Default: true.
    "! @parameter detailpress   | (event, ListItemBase) Fired when the detail icon (`type=Detail`) is pressed.
    METHODS column_list_item
      IMPORTING
        id            TYPE clike OPTIONAL
        valign        TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        counter       TYPE clike OPTIONAL
        highlight     TYPE clike OPTIONAL
        highlighttext TYPE clike OPTIONAL
        navigated     TYPE clike OPTIONAL
        unread        TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        detailpress   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ActionListItem</p>
    "!
    "! Active list item rendering only a text. See https://ui5.sap.com/#/api/sap.m.ActionListItem.
    "!
    "! @parameter text | (string) Action text.
    METHODS action_list_item
      IMPORTING
        id            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `cells`</p>
    METHODS cells
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `bar`</p>
    METHODS bar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `contentLeft`</p>
    METHODS content_left
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `contentMiddle`</p>
    METHODS content_middle
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `contentRight`</p>
    METHODS content_right
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `contentAreas`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS content_areas
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.mdc.Field</p>
    "!
    "! Smart field that combines display / edit modes for a value. See https://ui5.sap.com/#/api/sap.ui.mdc.Field.
    "!
    "! @parameter ns                 | (string) XML namespace prefix (typically `mdc`).
    "! @parameter value              | (any) Value (use `client->_bind_edit( var )`).
    "! @parameter editmode           | (sap.ui.mdc.enums.FieldEditMode) Editable | Display | EditableReadOnly | EditableDisplay. Default: Editable.
    "! @parameter showemptyindicator | (boolean) Show "-" for empty values in display mode. Default: false.
    METHODS field
      IMPORTING
        ns                 TYPE clike OPTIONAL
        id                 TYPE clike OPTIONAL
        value              TYPE clike OPTIONAL
        editmode           TYPE clike OPTIONAL
        showemptyindicator TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `customHeader`</p>
    METHODS custom_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `headerContent`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS header_content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `subHeader`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS sub_header
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `customData`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS custom_data
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.CustomData</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.core.CustomData.
    "!
    "! @parameter key        | (string) Data key.
    "! @parameter value      | (any) Data value.
    "! @parameter writetodom | (boolean) When true the value is rendered as `data-{key}` HTML attribute. Default: false.
    METHODS core_custom_data
      IMPORTING
        key           TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        writetodom    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.BadgeCustomData</p>
    "!
    "! Adds a numeric badge (e.g. notifications count) to compatible controls. See https://ui5.sap.com/#/api/sap.m.BadgeCustomData.
    "!
    "! @parameter key     | (string) Data key. Default: `sap-ui-custom-badge`.
    "! @parameter value   | (string) Badge text/value. Default: empty.
    "! @parameter visible | (boolean) Whether the badge is visible. Default: true.
    METHODS badge_custom_data
      IMPORTING
        key           TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ToggleButton</p>
    "!
    "! Push button that toggles between pressed and unpressed states. Extends sap.m.Button.
    "! See https://ui5.sap.com/#/api/sap.m.ToggleButton.
    "!
    "! @parameter text    | (string, Button) Button label.
    "! @parameter icon    | (sap.ui.core.URI, Button) Icon URI.
    "! @parameter type    | (sap.m.ButtonType, Button) Default | Accept | Reject | Transparent | Ghost | Back | Up | Unstyled |
    "!                      Emphasized | Critical | Negative | Success | Neutral | Attention. Default: Default.
    "! @parameter enabled | (boolean, Button) Whether the button is enabled. Default: true.
    "! @parameter press   | (event, Button) Fired when the button is pressed.
    "! @parameter class   | (string) CSS class names.
    "! @parameter pressed | (boolean) Pressed state. Default: false.
    METHODS toggle_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        pressed       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Button</p>
    "!
    "! Standard push button. See https://ui5.sap.com/#/api/sap.m.Button.
    "!
    "! @parameter text             | (string) Button label. Default: empty.
    "! @parameter icon             | (sap.ui.core.URI) Icon URI, e.g. `sap-icon://accept`.
    "! @parameter type             | (sap.m.ButtonType) Visual style: Default | Back | Accept | Reject | Transparent | Ghost | Up | Unstyled |
    "!                                Emphasized | Critical | Negative | Success | Neutral | Attention. Default: Default.
    "! @parameter enabled          | (boolean) Whether the button is enabled. Default: true.
    "! @parameter visible          | (boolean) Whether the button is visible. Default: true.
    "! @parameter press            | (event) Fired when the button is clicked or activated by keyboard.
    "! @parameter class            | (string) CSS class names.
    "! @parameter ns               | (string) XML namespace prefix when emitting the element (framework-internal).
    "! @parameter tooltip          | (string) Tooltip shown on hover.
    "! @parameter width            | (sap.ui.core.CSSSize) Width of the button.
    "! @parameter iconfirst        | (boolean) If true the icon is rendered before the text. Default: true.
    "! @parameter icondensityaware | (boolean) Density-aware icon (1x / 1.5x). Default: true.
    "! @parameter ariahaspopup     | (sap.ui.core.aria.HasPopup) ARIA aria-haspopup: None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter activeicon       | (sap.ui.core.URI) Alternative icon shown while the button is pressed.
    "! @parameter accessiblerole   | (sap.m.ButtonAccessibleRole) ARIA role: Default | Link. Default: Default.
    "! @parameter textdirection    | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter arialabelledby   | (sap.ui.core.ID[]) Ids of labelling controls (ARIA).
    "! @parameter ariadescribedby  | (sap.ui.core.ID[]) Ids of describing controls (ARIA).
    "!
    "! Note: the `tap` event is deprecated in UI5 - use `press`.
    METHODS button
      IMPORTING
        text             TYPE clike OPTIONAL
        icon             TYPE clike OPTIONAL
        type             TYPE clike OPTIONAL
        enabled          TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        press            TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        ns               TYPE clike OPTIONAL
        tooltip          TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        iconfirst        TYPE clike OPTIONAL
        icondensityaware TYPE clike OPTIONAL
        ariahaspopup     TYPE clike OPTIONAL
        activeicon       TYPE clike OPTIONAL
        accessiblerole   TYPE clike OPTIONAL
        textdirection    TYPE clike OPTIONAL
        arialabelledby   TYPE clike OPTIONAL
        ariadescribedby  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `beginButton`</p>
    METHODS begin_button
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `endButton`</p>
    METHODS end_button
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.SearchField</p>
    "!
    "! Single-line search input. See https://ui5.sap.com/#/api/sap.m.SearchField.
    "!
    "! @parameter search            | (event) Fired when search is triggered (Enter, search button, refresh button).
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter value             | (string) Two-way bound value. Use `client->_bind_edit( var )`.
    "! @parameter class             | (string) CSS class names.
    "! @parameter change            | (event) Fired when the value changes (e.g. on focus loss).
    "! @parameter livechange        | (event) Fired on every keystroke.
    "! @parameter suggest            | (event) Fired when a suggestion is requested.
    "! @parameter enabled           | (boolean) Whether the field is enabled. Default: true.
    "! @parameter enablesuggestions | (boolean) Enable the suggestion list. Default: false.
    "! @parameter maxlength         | (int) Maximum number of characters. 0 = unlimited. Default: 0.
    "! @parameter placeholder       | (string) Placeholder shown while empty.
    "! @parameter showrefreshbutton | (boolean) Show refresh button instead of search icon. Default: false.
    "! @parameter showsearchbutton  | (boolean) Show the search button. Default: true.
    "! @parameter visible           | (boolean) Whether the field is visible. Default: true.
    METHODS search_field
      IMPORTING
        search            TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        value             TYPE clike OPTIONAL
        id                TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
        change            TYPE clike OPTIONAL
        livechange        TYPE clike OPTIONAL
        suggest           TYPE clike OPTIONAL
        enabled           TYPE clike OPTIONAL
        enablesuggestions TYPE clike OPTIONAL
        maxlength         TYPE clike OPTIONAL
        placeholder       TYPE clike OPTIONAL
        showrefreshbutton TYPE clike OPTIONAL
        showsearchbutton  TYPE clike OPTIONAL
        visible           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MessageView</p>
    "!
    "! Reusable message viewer (used inside MessagePopover). See https://ui5.sap.com/#/api/sap.m.MessageView.
    "!
    "! @parameter items      | (binding path) Aggregation of `sap.m.MessageItem`.
    "! @parameter groupitems | (boolean) Group items by `groupName`. Default: false.
    METHODS message_view
      IMPORTING
        items         TYPE clike OPTIONAL
        groupitems    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ndc.BarcodeScannerButton</p>
    "!
    "! Button that opens a camera-based barcode scanner. Requires the sap.ndc library and a camera-enabled device.
    "! See https://ui5.sap.com/#/api/sap.ndc.BarcodeScannerButton.
    "!
    "! @parameter scansuccess               | (event) Fired with the scanned text. Provides `text`, `format`.
    "! @parameter scanfail                  | (event) Fired when the scan fails.
    "! @parameter inputliveupdate           | (event) Fired during manual input typing.
    "! @parameter dialogtitle               | (string) Title of the scanning dialog.
    "! @parameter disablebarcodeinputdialog | (boolean) Disable the manual-input fallback dialog. Default: false.
    "! @parameter framerate                 | (int) Camera framerate in fps.
    "! @parameter keepcamerascan            | (boolean) Keep the scanner open after a successful scan. Default: false.
    "! @parameter preferfrontcamera         | (boolean) Prefer the front camera when available. Default: false.
    "! @parameter providefallback           | (boolean) Provide a manual-input fallback. Default: false.
    "! @parameter width                     | (sap.ui.core.CSSSize) Width.
    "! @parameter zoom                      | (float) Camera zoom factor.
    METHODS barcode_scanner_button
      IMPORTING
        id                        TYPE clike OPTIONAL
        scansuccess               TYPE clike OPTIONAL
        scanfail                  TYPE clike OPTIONAL
        inputliveupdate           TYPE clike OPTIONAL
        dialogtitle               TYPE clike OPTIONAL
        disablebarcodeinputdialog TYPE clike OPTIONAL
        framerate                 TYPE clike OPTIONAL
        keepcamerascan            TYPE clike OPTIONAL
        preferfrontcamera         TYPE clike OPTIONAL
        providefallback           TYPE clike OPTIONAL
        width                     TYPE clike OPTIONAL
        zoom                      TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MessagePopover</p>
    "!
    "! Popover with messages categorised by type. See https://ui5.sap.com/#/api/sap.m.MessagePopover.
    "!
    "! @parameter items             | (binding path) Aggregation of `sap.m.MessageItem`.
    "! @parameter groupitems        | (boolean) Group items by `groupName`. Default: false.
    "! @parameter listselect        | (event) Fired when a message is selected.
    "! @parameter activetitlepress  | (event) Fired when an active title is pressed.
    "! @parameter placement         | (sap.m.VerticalPlacementType) Top | Bottom | Vertical. Default: Vertical.
    "! @parameter afterclose        | (event) Fired after the popover closes.
    "! @parameter beforeclose       | (event) Fired before the popover closes.
    "! @parameter initiallyexpanded | (boolean) Show the details view initially when there is exactly one message. Default: true.
    METHODS message_popover
      IMPORTING
        items             TYPE clike OPTIONAL
        groupitems        TYPE clike OPTIONAL
        listselect        TYPE clike OPTIONAL
        activetitlepress  TYPE clike OPTIONAL
        placement         TYPE clike OPTIONAL
        afterclose        TYPE clike OPTIONAL
        beforeclose       TYPE clike OPTIONAL
        initiallyexpanded TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MessageItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.MessageItem.
    "!
    "! @parameter type              | (sap.ui.core.MessageType) None | Information | Warning | Error | Success. Default: Error.
    "! @parameter title             | (string) Message title.
    "! @parameter subtitle          | (string) Subtitle. Since 1.44.
    "! @parameter description       | (string) Detail description.
    "! @parameter groupname         | (string) Group name (used when `groupItems=true` on the parent).
    "! @parameter markupdescription | (boolean) Treat the description as markup. Default: false.
    "! @parameter textdirection     | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter longtexturl       | (sap.ui.core.URI) URL pointing to a long text describing the message.
    "! @parameter counter           | (int) Counter shown next to the message.
    "! @parameter activetitle       | (boolean) Render the title as an active link firing `activeTitlePress`. Default: false.
    METHODS message_item
      IMPORTING
        type              TYPE clike OPTIONAL
        title             TYPE clike OPTIONAL
        subtitle          TYPE clike OPTIONAL
        description       TYPE clike OPTIONAL
        groupname         TYPE clike OPTIONAL
        markupdescription TYPE clike OPTIONAL
        textdirection     TYPE clike OPTIONAL
        longtexturl       TYPE clike OPTIONAL
        counter           TYPE clike OPTIONAL
        activetitle       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Page</p>
    "!
    "! Page container with optional header, sub-header, content and footer areas.
    "! See https://ui5.sap.com/#/api/sap.m.Page.
    "!
    "! @parameter title            | (string) Title text shown in the header bar.
    "! @parameter navbuttonpress   | (event) Fired when the back/nav button is pressed (since 1.12.2).
    "! @parameter shownavbutton    | (boolean) Renders a back/nav button on the left of the header. Default: false.
    "! @parameter showheader       | (boolean) Whether the header is shown. Default: true.
    "! @parameter class            | (string) CSS class names.
    "! @parameter ns               | (string) XML namespace prefix (framework-internal).
    "! @parameter backgrounddesign | (sap.m.PageBackgroundDesign) Standard | Solid | Transparent | List. Default: Standard.
    "! @parameter contentonlybusy  | (boolean) If true the busy indicator covers the content area only. Default: false.
    "! @parameter enablescrolling  | (boolean) Vertical scrolling of content. Default: true.
    "! @parameter navbuttontooltip | (string) Tooltip of the nav button.
    "! @parameter floatingfooter   | (boolean) Footer floats above the content with offset. Default: false.
    "! @parameter showfooter       | (boolean) Whether the footer is shown. Default: true.
    "! @parameter showsubheader    | (boolean) Whether the sub-header is shown. Default: true.
    "! @parameter titlealignment   | (sap.m.TitleAlignment) Auto | Start | Center. Default: Auto.
    "! @parameter titlelevel       | (sap.ui.core.TitleLevel) Semantic title level: Auto | H1 | H2 | H3 | H4 | H5 | H6. Default: Auto.
    "!
    "! Deprecated UI5 properties not exposed by this wrapper: `navButtonText`, `navButtonType`, `icon`
    "! (all MVI-theme only, deprecated since 1.20). Event `navButtonTap` is deprecated - use `navButtonPress`.
    METHODS page
      IMPORTING
        title            TYPE clike OPTIONAL
        navbuttonpress   TYPE clike OPTIONAL
        shownavbutton    TYPE clike OPTIONAL
        showheader       TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        ns               TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        contentonlybusy  TYPE clike OPTIONAL
        enablescrolling  TYPE clike OPTIONAL
        navbuttontooltip TYPE clike OPTIONAL
        floatingfooter   TYPE clike OPTIONAL
        showfooter       TYPE clike OPTIONAL
        showsubheader    TYPE clike OPTIONAL
        titlealignment   TYPE clike OPTIONAL
        titlelevel       TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MenuButton</p>
    "!
    "! Button that opens a menu on click. See https://ui5.sap.com/#/api/sap.m.MenuButton.
    "!
    "! @parameter text          | (string) Button label.
    "! @parameter activeicon    | (sap.ui.core.URI) Icon shown while pressed.
    "! @parameter buttonmode    | (sap.m.MenuButtonMode) Regular | Split. Default: Regular.
    "! @parameter type          | (sap.m.ButtonType) Default | Accept | Reject | Transparent | Ghost | Back | Up | Unstyled |
    "!                            Emphasized | Critical | Negative | Success | Neutral | Attention. Default: Default.
    "! @parameter enabled       | (boolean) Whether the button is enabled. Default: true.
    "! @parameter defaultaction | (event) Fired when the default action button (split mode) is pressed.
    METHODS menu_button
      IMPORTING
        text          TYPE clike OPTIONAL
        activeicon    TYPE clike OPTIONAL
        buttonmode    TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        defaultaction TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Panel</p>
    "!
    "! Container with optional header and expand/collapse. See https://ui5.sap.com/#/api/sap.m.Panel.
    "!
    "! @parameter expandable       | (boolean) Render the expand/collapse arrow. Default: false.
    "! @parameter expanded         | (boolean) Initial expanded state (only with expandable=true). Default: false.
    "! @parameter headertext       | (string) Header text shown when no `headerToolbar` aggregation is set.
    "! @parameter stickyheader     | (boolean) Make the header stick during scrolling. Default: true.
    "! @parameter height           | (sap.ui.core.CSSSize) Height. Default: auto.
    "! @parameter class            | (string) CSS class names.
    "! @parameter width            | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter backgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Translucent.
    "! @parameter expandanimation  | (boolean) Enable animation when expand state changes. Default: true.
    "! @parameter visible          | (boolean) Whether the panel is visible. Default: true.
    "! @parameter expand           | (event) Fired when expand state changes.
    METHODS panel
      IMPORTING
        expandable       TYPE clike OPTIONAL
        expanded         TYPE clike OPTIONAL
        headertext       TYPE clike OPTIONAL
        stickyheader     TYPE clike OPTIONAL
        height           TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        expandanimation  TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        expand           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.VBox</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.VBox. All FlexBox properties are available.
    "!
    "! @parameter height           | (sap.ui.core.CSSSize) Height.
    "! @parameter justifycontent   | (sap.m.FlexJustifyContent) Start | Center | End | SpaceBetween | SpaceAround | Inherit. Default: Start.
    "! @parameter class            | (string) CSS class names.
    "! @parameter rendertype       | (sap.m.FlexRendertype) Div | List | Bare. Default: Div.
    "! @parameter aligncontent     | (sap.m.FlexAlignContent) Start | Center | End | SpaceBetween | SpaceAround | Stretch | Inherit. Default: Stretch.
    "! @parameter direction        | (sap.m.FlexDirection) Column | ColumnReverse | Row | RowReverse | Inherit. Default: Column for VBox.
    "! @parameter alignitems       | (sap.m.FlexAlignItems) Start | Center | End | Stretch | Baseline | Inherit. Default: Stretch.
    "! @parameter width            | (sap.ui.core.CSSSize) Width.
    "! @parameter wrap             | (sap.m.FlexWrap) NoWrap | Wrap | WrapReverse. Default: NoWrap.
    "! @parameter backgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Transparent.
    "! @parameter displayinline    | (boolean) Inline-flex (true) vs flex (false). Default: false.
    "! @parameter fitcontainer     | (boolean) Stretch to fill container. Default: false.
    "! @parameter visible          | (boolean) Whether the box is visible. Default: true.
    METHODS vbox
      IMPORTING
        id               TYPE clike OPTIONAL
        height           TYPE clike OPTIONAL
        justifycontent   TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        rendertype       TYPE clike OPTIONAL
        aligncontent     TYPE clike OPTIONAL
        direction        TYPE clike OPTIONAL
        alignitems       TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        wrap             TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        displayinline    TYPE clike OPTIONAL
        fitcontainer     TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
          PREFERRED PARAMETER class
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.HBox</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.HBox. All FlexBox properties are available.
    "!
    "! @parameter class            | (string) CSS class names.
    "! @parameter justifycontent   | (sap.m.FlexJustifyContent) Main-axis alignment. Default: Start.
    "! @parameter aligncontent     | (sap.m.FlexAlignContent) Stretch | Start | Center | End | SpaceBetween | SpaceAround | Inherit. Default: Stretch.
    "! @parameter alignitems       | (sap.m.FlexAlignItems) Cross-axis alignment. Default: Stretch.
    "! @parameter width            | (sap.ui.core.CSSSize) Width.
    "! @parameter height           | (sap.ui.core.CSSSize) Height.
    "! @parameter rendertype       | (sap.m.FlexRendertype) Div | List | Bare. Default: Div.
    "! @parameter wrap             | (sap.m.FlexWrap) NoWrap | Wrap | WrapReverse. Default: NoWrap.
    "! @parameter backgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Transparent.
    "! @parameter direction        | (sap.m.FlexDirection) Row | RowReverse | Column | ColumnReverse | Inherit. Default: Row for HBox.
    "! @parameter displayinline    | (boolean) Inline-flex vs flex. Default: false.
    "! @parameter fitcontainer     | (boolean) Stretch to fill container. Default: false.
    "! @parameter visible          | (boolean) Whether the box is visible. Default: true.
    METHODS hbox
      IMPORTING
        id               TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        justifycontent   TYPE clike OPTIONAL
        aligncontent     TYPE clike OPTIONAL
        alignitems       TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        height           TYPE clike OPTIONAL
        rendertype       TYPE clike OPTIONAL
        wrap             TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        direction        TYPE clike OPTIONAL
        displayinline    TYPE clike OPTIONAL
        fitcontainer     TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ScrollContainer</p>
    "!
    "! Container that scrolls its content. See https://ui5.sap.com/#/api/sap.m.ScrollContainer.
    "!
    "! @parameter height     | (sap.ui.core.CSSSize) Height.
    "! @parameter width      | (sap.ui.core.CSSSize) Width.
    "! @parameter vertical   | (boolean) Allow vertical scrolling. Default: false.
    "! @parameter horizontal | (boolean) Allow horizontal scrolling. Default: true.
    "! @parameter focusable  | (boolean) Make the container focusable. Default: false.
    "! @parameter visible    | (boolean) Whether the container is visible. Default: true.
    METHODS scroll_container
      IMPORTING
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        vertical      TYPE clike OPTIONAL
        horizontal    TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        focusable     TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
          PREFERRED PARAMETER height
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.form.SimpleForm</p>
    "!
    "! Form layout that arranges labels and fields with responsive layout. See https://ui5.sap.com/#/api/sap.ui.layout.form.SimpleForm.
    "!
    "! @parameter title                   | (string) Form title.
    "! @parameter layout                  | (sap.ui.layout.form.SimpleFormLayout) ColumnLayout (recommended) | ResponsiveGridLayout. Note: ResponsiveLayout / GridLayout are deprecated.
    "! @parameter class                   | (string) CSS class names.
    "! @parameter editable                | (boolean) Render fields as editable inputs. Default: false.
    "! @parameter columnsxl               | (int) Number of columns on XL screens. Default: -1 (use columnsL).
    "! @parameter columnsl                | (int) Number of columns on L screens. Default: 2.
    "! @parameter columnsm                | (int) Number of columns on M screens. Default: 1.
    "! @parameter adjustlabelspan         | (boolean) Recompute labelSpan based on actual columns. Default: true.
    "! @parameter backgrounddesign        | (sap.ui.layout.BackgroundDesign) Solid | Translucent | Transparent. Default: Translucent.
    "! @parameter breakpointl             | (int) Breakpoint between M and L (px). Default: 1024.
    "! @parameter breakpointm             | (int) Breakpoint between S and M (px). Default: 600.
    "! @parameter breakpointxl            | (int) Breakpoint between L and XL (px). Default: 1440.
    "! @parameter emptyspanl              | (int) Trailing empty grid span on L. Default: 0.
    "! @parameter emptyspanm              | (int) Trailing empty grid span on M. Default: 0.
    "! @parameter emptyspans              | (int) Trailing empty grid span on S. Default: 0.
    "! @parameter emptyspanxl             | (int) Trailing empty grid span on XL. Default: -1.
    "! @parameter labelspans              | (int) Label grid span on S. Default: 12.
    "! @parameter labelspanm              | (int) Label grid span on M. Default: 2.
    "! @parameter labelspanl              | (int) Label grid span on L. Default: 4.
    "! @parameter labelspanxl             | (int) Label grid span on XL. Default: -1.
    "! @parameter maxcontainercols        | (int) DEPRECATED since 1.16 - use `columnsL` / `columnsM`. Default: 2.
    "! @parameter minwidth                | (int) DEPRECATED since 1.16 - use `breakpointM`. Default: -1.
    "! @parameter singlecontainerfullsize | (boolean) When true a single container spans the full width. Default: true.
    "! @parameter visible                 | (boolean) Whether the form is visible. Default: true.
    "! @parameter width                   | (sap.ui.core.CSSSize) Width.
    METHODS simple_form
      IMPORTING
        title                   TYPE clike OPTIONAL
        layout                  TYPE clike OPTIONAL
        class                   TYPE clike OPTIONAL
        editable                TYPE clike OPTIONAL
        columnsxl               TYPE clike OPTIONAL
        columnsl                TYPE clike OPTIONAL
        columnsm                TYPE clike OPTIONAL
        id                      TYPE clike OPTIONAL
        adjustlabelspan         TYPE clike OPTIONAL
        backgrounddesign        TYPE clike OPTIONAL
        breakpointl             TYPE clike OPTIONAL
        breakpointm             TYPE clike OPTIONAL
        breakpointxl            TYPE clike OPTIONAL
        emptyspanl              TYPE clike OPTIONAL
        emptyspanm              TYPE clike OPTIONAL
        emptyspans              TYPE clike OPTIONAL
        emptyspanxl             TYPE clike OPTIONAL
        labelspans              TYPE clike OPTIONAL
        labelspanm              TYPE clike OPTIONAL
        labelspanl              TYPE clike OPTIONAL
        labelspanxl             TYPE clike OPTIONAL
        maxcontainercols        TYPE clike OPTIONAL
        minwidth                TYPE clike OPTIONAL
        singlecontainerfullsize TYPE clike OPTIONAL
        visible                 TYPE clike OPTIONAL
        width                   TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Framework helper</p>
    "!
    "! @parameter val | (string) Raw XML content.
    METHODS _cc_plain_xml
      IMPORTING
        val           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `content`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Title</p>
    "!
    "! Stand-alone heading text. See https://ui5.sap.com/#/api/sap.m.Title.
    "!
    "! @parameter ns            | (string) XML namespace prefix. When empty resolves to sap.m.Title.
    "! @parameter text          | (string) Title text.
    "! @parameter wrapping      | (boolean) Wrap text. Default: false.
    "! @parameter level         | (sap.ui.core.TitleLevel) Auto | H1 | H2 | H3 | H4 | H5 | H6. Default: Auto.
    "! @parameter class         | (string) CSS class names.
    "! @parameter textalign     | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter titlestyle    | (sap.ui.core.TitleLevel) Visual style of the title; defaults to `level`.
    "! @parameter width         | (sap.ui.core.CSSSize) Width.
    "! @parameter wrappingtype  | (sap.m.WrappingType) Normal | Hyphenated. Default: Normal. Since 1.60.
    "! @parameter visible       | (boolean) Whether the title is visible. Default: true.
    METHODS title
      IMPORTING
        ns            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        wrapping      TYPE clike OPTIONAL
        level         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        textalign     TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
        titlestyle    TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        wrappingtype  TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.TabContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.TabContainer. Children are added through `tab`.
    METHODS tab_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.TabContainerItem</p>
    "!
    "! @parameter text     | (string) Tab title.
    "! @parameter selected | (boolean) Whether the tab is initially selected. Default: false.
    METHODS tab
      IMPORTING
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.OverflowToolbar</p>
    "!
    "! Toolbar that automatically moves overflowing items into an overflow menu. See https://ui5.sap.com/#/api/sap.m.OverflowToolbar.
    "! Inherits most properties from sap.m.Toolbar.
    "!
    "! @parameter press     | (event, Toolbar) Fired when the toolbar is clicked (only when `active=true`).
    "! @parameter active    | (boolean, Toolbar) Make the toolbar clickable. Default: false.
    "! @parameter visible   | (boolean) Whether the toolbar is visible. Default: true.
    "! @parameter asyncmode | (boolean) Calculate overflow asynchronously. Default: false.
    "! @parameter enabled   | (boolean, Toolbar) Whether the toolbar is enabled. Default: true.
    "! @parameter design    | (sap.m.ToolbarDesign) Auto | Solid | Transparent | Info. Default: Auto.
    "! @parameter style     | (sap.m.ToolbarStyle) Standard | Clear. Default: Standard.
    "! @parameter width     | (sap.ui.core.CSSSize) Width.
    "! @parameter height    | (sap.ui.core.CSSSize) Height.
    "! @parameter class     | (string) CSS class names.
    "! @parameter text      | (string) Reserved for inherited toolbar metadata; not commonly used.
    "! @parameter type      | (string) Reserved; not commonly used.
    METHODS overflow_toolbar
      IMPORTING
        press         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        active        TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        asyncmode     TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        design        TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        style         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.OverflowToolbarToggleButton</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.OverflowToolbarToggleButton. Inherits from sap.m.ToggleButton.
    "!
    "! @parameter text    | (string, Button) Button label.
    "! @parameter icon    | (sap.ui.core.URI, Button) Icon URI.
    "! @parameter type    | (sap.m.ButtonType, Button) Visual style.
    "! @parameter enabled | (boolean, Button) Whether the button is enabled. Default: true.
    "! @parameter press   | (event, Button) Fired on press.
    "! @parameter tooltip | (string) Tooltip.
    METHODS overflow_toolbar_toggle_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.OverflowToolbarButton</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.OverflowToolbarButton. Inherits from sap.m.Button.
    "!
    "! @parameter text    | (string, Button) Button label.
    "! @parameter icon    | (sap.ui.core.URI, Button) Icon URI.
    "! @parameter type    | (sap.m.ButtonType, Button) Visual style.
    "! @parameter enabled | (boolean, Button) Whether the button is enabled. Default: true.
    "! @parameter press   | (event, Button) Fired on press.
    "! @parameter tooltip | (string) Tooltip.
    METHODS overflow_toolbar_button
      IMPORTING
        id            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.OverflowToolbarMenuButton</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.OverflowToolbarMenuButton. Inherits from sap.m.MenuButton.
    "!
    "! @parameter text          | (string) Button label.
    "! @parameter icon          | (sap.ui.core.URI) Icon URI.
    "! @parameter buttonmode    | (sap.m.MenuButtonMode) Regular | Split. Default: Regular.
    "! @parameter type          | (sap.m.ButtonType) Visual style.
    "! @parameter enabled       | (boolean) Whether the button is enabled. Default: true.
    "! @parameter tooltip       | (string) Tooltip.
    "! @parameter defaultaction | (event) Fired when the default action button (split mode) is pressed.
    METHODS overflow_toolbar_menu_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        buttonmode    TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
        defaultaction TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MenuItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.MenuItem.
    "!
    "! @parameter press | (event) Fired when the item is selected.
    "! @parameter text  | (string) Item label.
    "! @parameter icon  | (sap.ui.core.URI) Icon URI.
    METHODS menu_item
      IMPORTING
        press         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ToolbarSpacer</p>
    "!
    "! Insert between toolbar items to create space. See https://ui5.sap.com/#/api/sap.m.ToolbarSpacer.
    "!
    "! @parameter ns    | (string) XML namespace prefix.
    "! @parameter width | (sap.ui.core.CSSSize) Fixed width. When empty the spacer is greedy and takes all remaining space.
    METHODS toolbar_spacer
      IMPORTING
        ns            TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Label</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Label.
    "!
    "! @parameter text          | (string) Label text.
    "! @parameter labelfor      | (sap.ui.core.ID) Id of the labelled control.
    "! @parameter design        | (sap.m.LabelDesign) Standard | Bold. Default: Standard.
    "! @parameter displayonly   | (boolean) Display-only mode (different default styling). Default: false.
    "! @parameter required      | (boolean) Show required marker. Default: false.
    "! @parameter showcolon     | (boolean) Append a colon to the text. Default: false.
    "! @parameter textalign     | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter valign        | (sap.ui.core.VerticalAlign) Bottom | Inherit | Middle | Top. Default: Inherit.
    "! @parameter width         | (sap.ui.core.CSSSize) Width.
    "! @parameter wrapping      | (boolean) Wrap text. Default: false.
    "! @parameter wrappingtype  | (sap.m.WrappingType) Normal | Hyphenated. Default: Normal. Since 1.60.
    "! @parameter class         | (string) CSS class names.
    "! @parameter visible       | (boolean) Whether the label is visible. Default: true.
    METHODS label
      IMPORTING
        text          TYPE clike OPTIONAL
        labelfor      TYPE clike OPTIONAL
        design        TYPE clike OPTIONAL
        displayonly   TYPE clike OPTIONAL
        required      TYPE clike OPTIONAL
        showcolon     TYPE clike OPTIONAL
        textalign     TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
        valign        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        wrapping      TYPE clike OPTIONAL
        wrappingtype  TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Image</p>
    "!
    "! Image with active/hover support, lazy loading and background-mode rendering. See https://ui5.sap.com/#/api/sap.m.Image.
    "!
    "! @parameter src                | (sap.ui.core.URI) Image URI.
    "! @parameter class              | (string) CSS class names.
    "! @parameter height             | (sap.ui.core.CSSSize) Image height.
    "! @parameter width              | (sap.ui.core.CSSSize) Image width.
    "! @parameter usemap             | (string) Name of the HTML image-map.
    "! @parameter mode               | (sap.m.ImageMode) Image | Background. Default: Image.
    "! @parameter lazyloading        | (boolean) Native lazy loading (`loading="lazy"`). Default: false.
    "! @parameter densityaware       | (boolean) Density-aware variants (1.5x / 2x). Default: false.
    "! @parameter decorative         | (boolean) Hide from screen readers. Default: true.
    "! @parameter backgroundsize     | (string) CSS background-size (Background mode only). Default: cover.
    "! @parameter backgroundrepeat   | (string) CSS background-repeat (Background mode only). Default: no-repeat.
    "! @parameter backgroundposition | (string) CSS background-position (Background mode only). Default: center.
    "! @parameter ariahaspopup       | (sap.ui.core.aria.HasPopup) None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter alt                | (string) Alternative text (used only when `decorative=false`).
    "! @parameter activesrc          | (sap.ui.core.URI) Image shown while pressed.
    "! @parameter press              | (event) Fired when the image is clicked.
    "! @parameter load               | (event) Fired when the image has finished loading.
    "! @parameter error              | (event) Fired when the image fails to load.
    METHODS image
      IMPORTING
        src                TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        height             TYPE clike OPTIONAL
        width              TYPE clike OPTIONAL
        usemap             TYPE clike OPTIONAL
        mode               TYPE clike OPTIONAL
        lazyloading        TYPE clike OPTIONAL
        densityaware       TYPE clike OPTIONAL
        decorative         TYPE clike OPTIONAL
        backgroundsize     TYPE clike OPTIONAL
        backgroundrepeat   TYPE clike OPTIONAL
        backgroundposition TYPE clike OPTIONAL
        ariahaspopup       TYPE clike OPTIONAL
        alt                TYPE clike OPTIONAL
        activesrc          TYPE clike OPTIONAL
        press              TYPE clike OPTIONAL
        load               TYPE clike OPTIONAL
        error              TYPE clike OPTIONAL
        id                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.DatePicker</p>
    "!
    "! Date input with calendar popover. See https://ui5.sap.com/#/api/sap.m.DatePicker.
    "!
    "! @parameter value                   | (string) Two-way bound formatted value. Use `client->_bind_edit( var )`.
    "! @parameter placeholder             | (string) Placeholder text.
    "! @parameter displayformat           | (string) Display format pattern (e.g. `dd.MM.yyyy` or `medium`).
    "! @parameter valueformat             | (string) Internal `value` format (e.g. `yyyy-MM-dd`).
    "! @parameter required                | (boolean) Required field marker. Default: false.
    "! @parameter valuestate              | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext          | (string) Value state message text.
    "! @parameter enabled                 | (boolean) Whether the field is enabled. Default: true.
    "! @parameter showcurrentdatebutton   | (boolean) Show "Today" button. Default: false. Since 1.95.
    "! @parameter change                  | (event) Fired when the value is committed.
    "! @parameter hideinput               | (boolean) Hide the input field, keeping only the calendar icon. Default: false.
    "! @parameter showfooter              | (boolean) Show calendar footer with OK/Cancel. Default: false.
    "! @parameter visible                 | (boolean) Whether the field is visible. Default: true.
    "! @parameter showvaluestatemessage   | (boolean) Show value state message. Default: true.
    "! @parameter mindate                 | (object) Minimum selectable date.
    "! @parameter maxdate                 | (object) Maximum selectable date.
    "! @parameter editable                | (boolean) Whether the field is editable. Default: true.
    "! @parameter width                   | (sap.ui.core.CSSSize) Width.
    "! @parameter calendarweeknumbering   | (sap.ui.core.date.CalendarWeekNumbering) Default | ISO_8601 | MiddleEastern | WesternTraditional. Default: Default. Since 1.108.
    "! @parameter displayformattype       | (string) Calendar type for the display format: Gregorian | Islamic | Japanese | Persian | Buddhist.
    "! @parameter class                   | (string) CSS class names.
    "! @parameter textdirection           | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter textalign               | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter name                    | (string) HTML form name.
    "! @parameter datevalue               | (object) JavaScript Date value (alternative to formatted `value`).
    "! @parameter initialfocuseddatevalue | (object) Date initially focused in the calendar. Since 1.54.
    METHODS date_picker
      IMPORTING
        value                   TYPE clike OPTIONAL
        placeholder             TYPE clike OPTIONAL
        displayformat           TYPE clike OPTIONAL
        valueformat             TYPE clike OPTIONAL
        required                TYPE clike OPTIONAL
        valuestate              TYPE clike OPTIONAL
        valuestatetext          TYPE clike OPTIONAL
        enabled                 TYPE clike OPTIONAL
        showcurrentdatebutton   TYPE clike OPTIONAL
        change                  TYPE clike OPTIONAL
        hideinput               TYPE clike OPTIONAL
        showfooter              TYPE clike OPTIONAL
        visible                 TYPE clike OPTIONAL
        showvaluestatemessage   TYPE clike OPTIONAL
        mindate                 TYPE clike OPTIONAL
        maxdate                 TYPE clike OPTIONAL
        editable                TYPE clike OPTIONAL
        width                   TYPE clike OPTIONAL
        id                      TYPE clike OPTIONAL
        calendarweeknumbering   TYPE clike OPTIONAL
        displayformattype       TYPE clike OPTIONAL
        class                   TYPE clike OPTIONAL
        textdirection           TYPE clike OPTIONAL
        textalign               TYPE clike OPTIONAL
        name                    TYPE clike OPTIONAL
        datevalue               TYPE clike OPTIONAL
        initialfocuseddatevalue TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.TimePicker</p>
    "!
    "! Time input with clock popover. See https://ui5.sap.com/#/api/sap.m.TimePicker.
    "!
    "! @parameter value                   | (string) Two-way bound formatted value.
    "! @parameter placeholder             | (string) Placeholder text.
    "! @parameter enabled                 | (boolean) Whether the field is enabled. Default: true.
    "! @parameter valuestate              | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter displayformat           | (string) Display format pattern.
    "! @parameter valueformat             | (string) Internal `value` format.
    "! @parameter required                | (boolean) Required field marker. Default: false.
    "! @parameter width                   | (sap.ui.core.CSSSize) Width.
    "! @parameter datevalue               | (object) JavaScript Date value.
    "! @parameter localeid                | (string) Locale id (e.g. `en_US`).
    "! @parameter mask                    | (string) Input mask. Default derived from displayFormat.
    "! @parameter maskmode                | (sap.m.MaskMode) On | Off. Default: On.
    "! @parameter minutesstep             | (int) Minutes step in the picker. Default: 1.
    "! @parameter name                    | (string) HTML form name.
    "! @parameter placeholdersymbol       | (string) Mask placeholder symbol. Default: `_`.
    "! @parameter secondsstep             | (int) Seconds step in the picker. Default: 1.
    "! @parameter textalign               | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection           | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter title                   | (string) Title shown in the popover.
    "! @parameter showcurrenttimebutton   | (boolean) Show "Now" button. Default: false.
    "! @parameter showvaluestatemessage   | (boolean) Show value state message. Default: true.
    "! @parameter support2400             | (boolean) Support 24:00 as a valid time. Default: false. Since 1.54.
    "! @parameter initialfocuseddatevalue | (object) Time initially focused in the picker.
    "! @parameter hideinput               | (boolean) Hide the input field. Default: false.
    "! @parameter editable                | (boolean) Whether the field is editable. Default: true.
    "! @parameter visible                 | (boolean) Whether the field is visible. Default: true.
    "! @parameter valuestatetext          | (string) Value state message text.
    "! @parameter livechange              | (event) Fired during typing.
    "! @parameter change                  | (event) Fired when the value is committed.
    "! @parameter aftervaluehelpopen      | (event) Fired after the picker popover opens.
    "! @parameter aftervaluehelpclose     | (event) Fired after the picker popover closes.
    METHODS time_picker
      IMPORTING
        value                   TYPE clike OPTIONAL
        placeholder             TYPE clike OPTIONAL
        enabled                 TYPE clike OPTIONAL
        valuestate              TYPE clike OPTIONAL
        displayformat           TYPE clike OPTIONAL
        valueformat             TYPE clike OPTIONAL
        required                TYPE clike OPTIONAL
        width                   TYPE clike OPTIONAL
        datevalue               TYPE clike OPTIONAL
        localeid                TYPE clike OPTIONAL
        mask                    TYPE clike OPTIONAL
        maskmode                TYPE clike OPTIONAL
        minutesstep             TYPE clike OPTIONAL
        name                    TYPE clike OPTIONAL
        placeholdersymbol       TYPE clike OPTIONAL
        secondsstep             TYPE clike OPTIONAL
        textalign               TYPE clike OPTIONAL
        textdirection           TYPE clike OPTIONAL
        title                   TYPE clike OPTIONAL
        showcurrenttimebutton   TYPE clike OPTIONAL
        showvaluestatemessage   TYPE clike OPTIONAL
        support2400             TYPE clike OPTIONAL
        initialfocuseddatevalue TYPE clike OPTIONAL
        hideinput               TYPE clike OPTIONAL
        editable                TYPE clike OPTIONAL
        visible                 TYPE clike OPTIONAL
        valuestatetext          TYPE clike OPTIONAL
        livechange              TYPE clike OPTIONAL
        change                  TYPE clike OPTIONAL
        aftervaluehelpopen      TYPE clike OPTIONAL
        aftervaluehelpclose     TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.DateTimePicker</p>
    "!
    "! Combined date and time input. See https://ui5.sap.com/#/api/sap.m.DateTimePicker. Inherits from sap.m.DatePicker.
    "!
    "! @parameter value       | (string) Two-way bound formatted value.
    "! @parameter placeholder | (string) Placeholder text.
    "! @parameter enabled     | (boolean) Whether the field is enabled. Default: true.
    "! @parameter valuestate  | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    METHODS date_time_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        valuestate    TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Link</p>
    "!
    "! Standard hyperlink. See https://ui5.sap.com/#/api/sap.m.Link.
    "!
    "! @parameter text               | (string) Link text.
    "! @parameter href               | (sap.ui.core.URI) Target URL.
    "! @parameter target             | (string) HTML target attribute (e.g. `_blank`, `_self`).
    "! @parameter enabled            | (boolean) Whether the link is enabled. Default: true.
    "! @parameter press              | (event) Fired when the link is pressed.
    "! @parameter ns                 | (string) XML namespace prefix.
    "! @parameter wrapping           | (boolean) Wrap text. Default: true.
    "! @parameter width              | (sap.ui.core.CSSSize) Width.
    "! @parameter validateurl        | (boolean) Validate the href URL via URLListValidator. Default: false.
    "! @parameter textdirection      | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter textalign          | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter subtle             | (boolean) Render with reduced visual emphasis. Default: false.
    "! @parameter rel                | (string) HTML rel attribute. When unset and `target=_blank`, `noopener noreferrer` is added.
    "! @parameter emptyindicatormode | (sap.m.EmptyIndicatorMode) On | Off | Auto. Default: Off. Since 1.87.
    "! @parameter emphasized         | (boolean) Render with emphasized styling. Default: false.
    "! @parameter ariahaspopup       | (sap.ui.core.aria.HasPopup) None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter accessiblerole     | (sap.m.LinkAccessibleRole) Default | Button. Default: Default.
    "! @parameter class              | (string) CSS class names.
    "! @parameter endicon            | (sap.ui.core.URI) Icon shown at the end of the text.
    "! @parameter icon               | (sap.ui.core.URI) Icon shown at the beginning of the text.
    METHODS link
      IMPORTING
        text               TYPE clike OPTIONAL
        href               TYPE clike OPTIONAL
        target             TYPE clike OPTIONAL
        enabled            TYPE clike OPTIONAL
        press              TYPE clike OPTIONAL
        id                 TYPE clike OPTIONAL
        ns                 TYPE clike OPTIONAL
        wrapping           TYPE clike OPTIONAL
        width              TYPE clike OPTIONAL
        validateurl        TYPE clike OPTIONAL
        textdirection      TYPE clike OPTIONAL
        textalign          TYPE clike OPTIONAL
        subtle             TYPE clike OPTIONAL
        rel                TYPE clike OPTIONAL
        emptyindicatormode TYPE clike OPTIONAL
        emphasized         TYPE clike OPTIONAL
        ariahaspopup       TYPE clike OPTIONAL
        accessiblerole     TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        endicon            TYPE clike OPTIONAL
        icon               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.List</p>
    "!
    "! Generic list. See https://ui5.sap.com/#/api/sap.m.List. Most properties inherited from sap.m.ListBase.
    "!
    "! @parameter headertext             | (string, ListBase) Header text.
    "! @parameter items                  | (binding path) List items.
    "! @parameter mode                   | (sap.m.ListMode) None | SingleSelectMaster | SingleSelectLeft | MultiSelect | Delete. `SingleSelect` deprecated since 1.143. Default: None.
    "! @parameter selectionchange        | (event) Fired when selection changes.
    "! @parameter showseparators         | (sap.m.ListSeparators) All | Inner | None. Default: All.
    "! @parameter footertext             | (string) Footer text.
    "! @parameter growingdirection       | (sap.m.ListGrowingDirection) Downwards | Upwards. Default: Downwards.
    "! @parameter growingthreshold       | (int) Items per growing chunk. Default: 20.
    "! @parameter growingtriggertext     | (string) Custom "More" button text.
    "! @parameter headerlevel            | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter multiselectmode        | (sap.m.MultiSelectMode) Default | ClearAll | SelectAll. Default: Default.
    "! @parameter nodatatext             | (string) Empty-state text.
    "! @parameter sticky                 | (sap.m.Sticky[]) HeaderToolbar | InfoToolbar | ColumnHeaders | GroupHeaders.
    "! @parameter modeanimationon        | (boolean) Animate mode change. Default: true.
    "! @parameter growingscrolltoload    | (boolean) Trigger growing on scroll. Default: false.
    "! @parameter includeiteminselection | (boolean) Click item to select. Default: false.
    "! @parameter growing                | (boolean) Enable growing. Default: false.
    "! @parameter inset                  | (boolean) Indent the container. Default: false.
    "! @parameter backgrounddesign       | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Solid.
    "! @parameter rememberselections     | (boolean) Persist selections after binding update. Default: true.
    "! @parameter showunread             | (boolean) Activate unread indicator. Default: false.
    "! @parameter visible                | (boolean) Whether the list is visible. Default: true.
    "! @parameter nodata                 | (binding path) Aggregation `noData` for a custom empty-state control.
    "! @parameter itempress              | (event) Fired when an item is pressed.
    "! @parameter select                 | (event) DEPRECATED since 1.16 - use `selectionChange`.
    "! @parameter delete                 | (event) Fired when the delete button on an item is pressed.
    "! @parameter class                  | (string) CSS class names.
    METHODS list
      IMPORTING
        headertext             TYPE clike OPTIONAL
        items                  TYPE clike OPTIONAL
        mode                   TYPE clike OPTIONAL
        selectionchange        TYPE clike OPTIONAL
        showseparators         TYPE clike OPTIONAL
        footertext             TYPE clike OPTIONAL
        growingdirection       TYPE clike OPTIONAL
        growingthreshold       TYPE clike OPTIONAL
        growingtriggertext     TYPE clike OPTIONAL
        headerlevel            TYPE clike OPTIONAL
        multiselectmode        TYPE clike OPTIONAL
        nodatatext             TYPE clike OPTIONAL
        sticky                 TYPE clike OPTIONAL
        modeanimationon        TYPE clike OPTIONAL
        growingscrolltoload    TYPE clike OPTIONAL
        includeiteminselection TYPE clike OPTIONAL
        growing                TYPE clike OPTIONAL
        inset                  TYPE clike OPTIONAL
        backgrounddesign       TYPE clike OPTIONAL
        rememberselections     TYPE clike OPTIONAL
        showunread             TYPE clike OPTIONAL
        visible                TYPE clike OPTIONAL
        nodata                 TYPE clike OPTIONAL
        id                     TYPE clike OPTIONAL
        itempress              TYPE clike OPTIONAL
        select                 TYPE clike OPTIONAL
        delete                 TYPE clike OPTIONAL
        class                  TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.CustomListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.CustomListItem. Inherits all ListItemBase properties.
    METHODS custom_list_item
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.InputListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.InputListItem.
    "!
    "! @parameter label | (string) Label rendered in front of the input control.
    METHODS input_list_item
      IMPORTING
        label         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.StandardListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.StandardListItem. Inherits from sap.m.ListItemBase.
    "!
    "! @parameter title             | (string) Main title text.
    "! @parameter description       | (string) Description text.
    "! @parameter icon              | (sap.ui.core.URI) Icon URI.
    "! @parameter info              | (string) Status/info text shown on the right side.
    "! @parameter press             | (event, ListItemBase) Fired when the row is activated.
    "! @parameter type              | (sap.m.ListType, ListItemBase) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter selected          | (boolean, ListItemBase) Selected state. Default: false.
    "! @parameter counter           | (int, ListItemBase) Counter badge value.
    "! @parameter wrapping          | (boolean) Wrap text. Default: false. Since 1.67.
    "! @parameter wrapcharlimit     | (int) Character limit for wrapping. Since 1.67.
    "! @parameter infostateinverted | (boolean) Invert the colors of the `info` state badge. Default: false. Since 1.74.
    "! @parameter infostate         | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter iconinset         | (boolean) Indent the icon. Default: true.
    "! @parameter adapttitlesize    | (boolean) Increase title font when no description is set. Default: true.
    "! @parameter activeicon        | (sap.ui.core.URI) Icon shown when the item is pressed.
    "! @parameter unread            | (boolean, ListItemBase) Bold formatting for unread state. Default: false.
    "! @parameter highlight         | (sap.ui.core.MessageType | sap.ui.core.IndicationColor, ListItemBase) Default: None.
    METHODS standard_list_item
      IMPORTING
        title             TYPE clike OPTIONAL
        description       TYPE clike OPTIONAL
        icon              TYPE clike OPTIONAL
        info              TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        type              TYPE clike OPTIONAL
        selected          TYPE clike OPTIONAL
        counter           TYPE clike OPTIONAL
        wrapping          TYPE clike OPTIONAL
        wrapcharlimit     TYPE clike OPTIONAL
        infostateinverted TYPE clike OPTIONAL
        infostate         TYPE clike OPTIONAL
        iconinset         TYPE clike OPTIONAL
        adapttitlesize    TYPE clike OPTIONAL
        activeicon        TYPE clike OPTIONAL
        unread            TYPE clike OPTIONAL
        highlight         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.Item</p>
    "!
    "! Lightweight item used inside Select / ComboBox / etc. See https://ui5.sap.com/#/api/sap.ui.core.Item.
    "!
    "! @parameter key  | (string) Item key.
    "! @parameter text | (string) Display text.
    METHODS item
      IMPORTING
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.SegmentedButtonItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.SegmentedButtonItem.
    "!
    "! @parameter icon          | (sap.ui.core.URI) Segment icon.
    "! @parameter key           | (string) Segment key (used by SegmentedButton.selectedKey).
    "! @parameter text          | (string) Segment label.
    "! @parameter width         | (sap.ui.core.CSSSize) Segment width.
    "! @parameter visible       | (boolean) Whether the segment is visible. Default: true.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter enabled       | (boolean) Whether the segment is enabled. Default: true.
    "! @parameter press         | (event) Fired when the segment is pressed.
    METHODS segmented_button_item
      IMPORTING
        icon          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ComboBox</p>
    "!
    "! Dropdown with autocomplete and value-help button. See https://ui5.sap.com/#/api/sap.m.ComboBox.
    "!
    "! @parameter selectedkey           | (string) Two-way bound selected key.
    "! @parameter showclearicon         | (boolean) Show a clear icon. Default: false. Since 1.96.
    "! @parameter selectionchange       | (event) Fired when the selected item changes.
    "! @parameter selecteditem          | (sap.ui.core.ID) Id of the selected item.
    "! @parameter items                 | (binding path) Aggregation of `sap.ui.core.Item`.
    "! @parameter change                | (event) Fired when the value is committed.
    "! @parameter width                 | (sap.ui.core.CSSSize) Width.
    "! @parameter showsecondaryvalues   | (boolean) Render `additionalText` as a second column. Default: false.
    "! @parameter placeholder           | (string) Placeholder shown while empty.
    "! @parameter selecteditemid        | (string) Id of the selected item.
    "! @parameter name                  | (string) HTML form name.
    "! @parameter value                 | (string) Two-way bound value.
    "! @parameter valuestate            | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext        | (string) Value state message.
    "! @parameter textalign             | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter visible               | (boolean) Whether the control is visible. Default: true.
    "! @parameter showvaluestatemessage | (boolean) Show the value state message popup. Default: true.
    "! @parameter showbutton            | (boolean) Show the dropdown button. Default: true.
    "! @parameter required              | (boolean) Required field marker. Default: false.
    "! @parameter editable              | (boolean) Whether the control is editable. Default: true.
    "! @parameter enabled               | (boolean) Whether the control is enabled. Default: true.
    "! @parameter filtersecondaryvalues | (boolean) Filter on `additionalText` too. Default: false.
    "! @parameter class                 | (string) CSS class names.
    METHODS combobox
      IMPORTING
        selectedkey           TYPE clike OPTIONAL
        showclearicon         TYPE clike OPTIONAL
        selectionchange       TYPE clike OPTIONAL
        selecteditem          TYPE clike OPTIONAL
        items                 TYPE clike OPTIONAL
        change                TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        showsecondaryvalues   TYPE clike OPTIONAL
        placeholder           TYPE clike OPTIONAL
        selecteditemid        TYPE clike OPTIONAL
        name                  TYPE clike OPTIONAL
        value                 TYPE clike OPTIONAL
        valuestate            TYPE clike OPTIONAL
        valuestatetext        TYPE clike OPTIONAL
        textalign             TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
        showvaluestatemessage TYPE clike OPTIONAL
        showbutton            TYPE clike OPTIONAL
        required              TYPE clike OPTIONAL
        editable              TYPE clike OPTIONAL
        enabled               TYPE clike OPTIONAL
        filtersecondaryvalues TYPE clike OPTIONAL
        id                    TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MultiComboBox</p>
    "!
    "! Dropdown with multi-select. See https://ui5.sap.com/#/api/sap.m.MultiComboBox.
    "!
    "! @parameter selectionchange       | (event) Fired when the selection changes.
    "! @parameter selectedkeys          | (string[]) Two-way bound array of selected keys.
    "! @parameter selecteditems         | (sap.ui.core.ID[]) Ids of selected items.
    "! @parameter items                 | (binding path) Aggregation of `sap.ui.core.Item`.
    "! @parameter selectionfinish       | (event) Fired when selection is finished (popover closes).
    "! @parameter width                 | (sap.ui.core.CSSSize) Width.
    "! @parameter showclearicon         | (boolean) Show a clear icon. Default: false.
    "! @parameter showsecondaryvalues   | (boolean) Render `additionalText` as a second column. Default: false.
    "! @parameter placeholder           | (string) Placeholder shown while empty.
    "! @parameter selecteditemid        | (string) Id of one selected item.
    "! @parameter selectedkey           | (string) Single selected key (rarely used here; prefer selectedKeys).
    "! @parameter name                  | (string) HTML form name.
    "! @parameter value                 | (string) Current input text.
    "! @parameter valuestate            | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext        | (string) Value state message.
    "! @parameter textalign             | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter visible               | (boolean) Whether the control is visible. Default: true.
    "! @parameter showvaluestatemessage | (boolean) Show the value state message popup. Default: true.
    "! @parameter showbutton            | (boolean) Show the dropdown button. Default: true.
    "! @parameter required              | (boolean) Required field marker. Default: false.
    "! @parameter editable              | (boolean) Whether the control is editable. Default: true.
    "! @parameter enabled               | (boolean) Whether the control is enabled. Default: true.
    "! @parameter filtersecondaryvalues | (boolean) Filter on `additionalText` too. Default: false.
    "! @parameter showselectall         | (boolean) Render a "Select All" entry. Default: false. Since 1.116.
    "! @parameter class                 | (string) CSS class names.
    METHODS multi_combobox
      IMPORTING
        selectionchange       TYPE clike OPTIONAL
        selectedkeys          TYPE clike OPTIONAL
        selecteditems         TYPE clike OPTIONAL
        items                 TYPE clike OPTIONAL
        selectionfinish       TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        showclearicon         TYPE clike OPTIONAL
        showsecondaryvalues   TYPE clike OPTIONAL
        placeholder           TYPE clike OPTIONAL
        selecteditemid        TYPE clike OPTIONAL
        selectedkey           TYPE clike OPTIONAL
        name                  TYPE clike OPTIONAL
        value                 TYPE clike OPTIONAL
        valuestate            TYPE clike OPTIONAL
        valuestatetext        TYPE clike OPTIONAL
        textalign             TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
        showvaluestatemessage TYPE clike OPTIONAL
        showbutton            TYPE clike OPTIONAL
        required              TYPE clike OPTIONAL
        editable              TYPE clike OPTIONAL
        enabled               TYPE clike OPTIONAL
        filtersecondaryvalues TYPE clike OPTIONAL
        showselectall         TYPE clike OPTIONAL
        id                    TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.Grid</p>
    "!
    "! 12-column grid layout. See https://ui5.sap.com/#/api/sap.ui.layout.Grid.
    "!
    "! @parameter class          | (string) CSS class names.
    "! @parameter default_span   | (sap.ui.layout.GridSpan) Default span (e.g. `XL3 L4 M6 S12`). Default: XL3 L3 M6 S12.
    "! @parameter containerquery | (boolean) Use container width instead of viewport for breakpoints. Default: false.
    "! @parameter hspacing       | (float) Horizontal spacing in rem. Default: 1.
    "! @parameter vspacing       | (float) Vertical spacing in rem. Default: 1.
    "! @parameter width          | (sap.ui.core.CSSSize) Width.
    "! @parameter content        | (binding path) Aggregation of grid content controls.
    METHODS grid
      IMPORTING
        class          TYPE clike OPTIONAL
        default_span   TYPE clike OPTIONAL
        containerquery TYPE clike OPTIONAL
        hspacing       TYPE clike OPTIONAL
        vspacing       TYPE clike OPTIONAL
        width          TYPE clike OPTIONAL
        content        TYPE clike OPTIONAL
          PREFERRED PARAMETER default_span
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridContainerSettings</p>
    "!
    "! Layout for fixed-width box arrangement. See https://ui5.sap.com/#/api/sap.ui.layout.cssgrid.GridBoxLayout.
    "!
    "! @parameter boxesperrowconfig | (sap.ui.layout.BoxesPerRowConfig) Boxes per row at each breakpoint, e.g. `XL7 L6 M4 S2`. Default: XL7 L6 M4 S2.
    "! @parameter boxminwidth       | (sap.ui.core.CSSSize) Minimum box width.
    "! @parameter boxwidth          | (sap.ui.core.CSSSize) Fixed box width.
    METHODS grid_box_layout
      IMPORTING
        boxesperrowconfig TYPE clike OPTIONAL
        boxminwidth       TYPE clike OPTIONAL
        boxwidth          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.GridData</p>
    "!
    "! Per-child grid layout data. See https://ui5.sap.com/#/api/sap.ui.layout.GridData.
    "!
    "! @parameter span      | (sap.ui.layout.GridSpan) Span string (e.g. `XL3 L4 M6 S12`).
    "! @parameter linebreak | (boolean) Force a line break before this child. Default: false.
    "! @parameter indentl   | (int) Indent on L screens (0..11).
    "! @parameter indentm   | (int) Indent on M screens (0..11).
    METHODS grid_data
      IMPORTING
        span          TYPE clike OPTIONAL
        linebreak     TYPE clike OPTIONAL
        indentl       TYPE clike OPTIONAL
        indentm       TYPE clike OPTIONAL
          PREFERRED PARAMETER span
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridDropInfo</p>
    "!
    "! Drag-and-drop configuration for grid layouts. See https://ui5.sap.com/#/api/sap.f.dnd.GridDropInfo.
    "!
    "! @parameter targetaggregation | (string) Name of the target aggregation.
    "! @parameter dropposition      | (sap.ui.core.dnd.DropPosition) On | Between | OnOrBetween. Default: On.
    "! @parameter droplayout        | (sap.ui.core.dnd.DropLayout) Default | Vertical | Horizontal. Default: Default.
    "! @parameter drop              | (event) Fired when a drag operation completes.
    "! @parameter dragenter         | (event) Fired when a drag enters the target.
    "! @parameter dragover          | (event) Fired while dragging over the target.
    METHODS grid_drop_info
      IMPORTING
        targetaggregation TYPE clike OPTIONAL
        dropposition      TYPE clike OPTIONAL
        droplayout        TYPE clike OPTIONAL
        drop              TYPE clike OPTIONAL
        dragenter         TYPE clike OPTIONAL
        dragover          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridList</p>
    "!
    "! Grid-arranged list. See https://ui5.sap.com/#/api/sap.f.GridList.
    "!
    "! @parameter busy                   | (boolean) Inherited busy state.
    "! @parameter busyindicatordelay     | (int) Inherited busy indicator delay in ms. Default: 1000.
    "! @parameter busyindicatorsize      | (sap.ui.core.BusyIndicatorSize) Small | Medium | Large | Auto. Default: Medium.
    "! @parameter enablebusyindicator    | (boolean) Auto-show busy during binding load. Default: true.
    "! @parameter fieldgroupids          | (string[]) Field group ids.
    "! @parameter footertext             | (string) Footer text.
    "! @parameter growing                | (boolean) Enable growing. Default: false.
    "! @parameter growingdirection       | (sap.m.ListGrowingDirection) Downwards | Upwards. Default: Downwards.
    "! @parameter growingscrolltoload    | (boolean) Trigger growing on scroll. Default: false.
    "! @parameter growingthreshold       | (int) Items per growing chunk. Default: 20.
    "! @parameter growingtriggertext     | (string) Custom "More" button text.
    "! @parameter headerlevel            | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter headertext             | (string) Header text.
    "! @parameter includeiteminselection | (boolean) Click item to select. Default: false.
    "! @parameter inset                  | (boolean) Indent the container. Default: false.
    "! @parameter keyboardmode           | (sap.m.ListKeyboardMode) Navigation | Edit. Default: Navigation.
    "! @parameter mode                   | (sap.m.ListMode) Selection mode. Default: None.
    "! @parameter modeanimationon        | (boolean) Animate mode change. Default: true.
    "! @parameter multiselectmode        | (sap.m.MultiSelectMode) Default | ClearAll | SelectAll. Default: Default.
    "! @parameter nodatatext             | (string) Empty-state text.
    "! @parameter rememberselections     | (boolean) Persist selections. Default: true.
    "! @parameter shownodata             | (boolean) Show empty-state text. Default: true.
    "! @parameter showseparators         | (sap.m.ListSeparators) All | Inner | None. Default: All.
    "! @parameter showunread             | (boolean) Activate unread indicator. Default: false.
    "! @parameter sticky                 | (sap.m.Sticky[]) Sticky areas.
    "! @parameter swipedirection         | (sap.m.SwipeDirection) Both | RightToLeft | LeftToRight. Default: Both.
    "! @parameter visible                | (boolean) Whether the list is visible. Default: true.
    "! @parameter width                  | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter items                  | (binding path) Aggregation of `sap.f.GridListItem`.
    METHODS grid_list
      IMPORTING
        id                     TYPE clike     OPTIONAL
        busy                   TYPE abap_bool OPTIONAL
        busyindicatordelay     TYPE clike     OPTIONAL
        busyindicatorsize      TYPE clike     OPTIONAL
        enablebusyindicator    TYPE abap_bool OPTIONAL
        fieldgroupids          TYPE clike     OPTIONAL
        footertext             TYPE clike     OPTIONAL
        growing                TYPE abap_bool OPTIONAL
        growingdirection       TYPE clike     OPTIONAL
        growingscrolltoload    TYPE abap_bool OPTIONAL
        growingthreshold       TYPE clike     OPTIONAL
        growingtriggertext     TYPE clike     OPTIONAL
        headerlevel            TYPE clike     OPTIONAL
        headertext             TYPE clike     OPTIONAL
        includeiteminselection TYPE abap_bool OPTIONAL
        inset                  TYPE abap_bool OPTIONAL
        keyboardmode           TYPE clike     OPTIONAL
        mode                   TYPE clike     OPTIONAL
        modeanimationon        TYPE abap_bool OPTIONAL
        multiselectmode        TYPE clike     OPTIONAL
        nodatatext             TYPE clike     OPTIONAL
        rememberselections     TYPE abap_bool OPTIONAL
        shownodata             TYPE abap_bool OPTIONAL
        showseparators         TYPE clike     OPTIONAL
        showunread             TYPE abap_bool OPTIONAL
        sticky                 TYPE clike     OPTIONAL
        swipedirection         TYPE clike     OPTIONAL
        visible                TYPE abap_bool DEFAULT abap_true
        width                  TYPE clike     OPTIONAL
        items                  TYPE clike     OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.GridListItem. Inherits ListItemBase.
    "!
    "! @parameter busy               | (boolean) Inherited busy state.
    "! @parameter busyindicatordelay | (int) Busy indicator delay in ms.
    "! @parameter busyindicatorsize  | (sap.ui.core.BusyIndicatorSize) Small | Medium | Large | Auto.
    "! @parameter counter            | (int, ListItemBase) Counter badge.
    "! @parameter fieldgroupids      | (string[]) Field group ids.
    "! @parameter highlight          | (sap.ui.core.MessageType | sap.ui.core.IndicationColor) Default: None.
    "! @parameter highlighttext      | (string) Custom accessibility text for the highlight.
    "! @parameter navigated          | (boolean) Marked as navigated. Default: false.
    "! @parameter selected           | (boolean) Selected state. Default: false.
    "! @parameter type               | (sap.m.ListType) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter unread             | (boolean) Unread state. Default: false.
    "! @parameter visible            | (boolean) Whether the item is visible. Default: true.
    "! @parameter detailpress        | (event) Fired when the detail icon is pressed.
    "! @parameter detailtap          | (event) DEPRECATED - use `detailPress`.
    "! @parameter press              | (event) Fired when the item is activated.
    "! @parameter tap                | (event) DEPRECATED - use `press`.
    METHODS grid_list_item
      IMPORTING
        busy               TYPE clike OPTIONAL
        busyindicatordelay TYPE clike OPTIONAL
        busyindicatorsize  TYPE clike OPTIONAL
        counter            TYPE clike OPTIONAL
        fieldgroupids      TYPE clike OPTIONAL
        highlight          TYPE clike OPTIONAL
        highlighttext      TYPE clike OPTIONAL
        navigated          TYPE clike OPTIONAL
        selected           TYPE clike OPTIONAL
        type               TYPE clike OPTIONAL
        unread             TYPE clike OPTIONAL
        visible            TYPE clike DEFAULT `true`
        detailpress        TYPE clike OPTIONAL
        detailtap          TYPE clike OPTIONAL
        press              TYPE clike OPTIONAL
        tap                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.TextArea</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.TextArea. Inherits sap.m.InputBase.
    "!
    "! @parameter value                 | (string) Two-way bound value.
    "! @parameter rows                  | (int) Number of visible rows. Default: 2.
    "! @parameter cols                  | (int) Number of visible columns. Default: 20.
    "! @parameter height                | (sap.ui.core.CSSSize) Height (overrides rows).
    "! @parameter class                 | (string) CSS class names.
    "! @parameter width                 | (sap.ui.core.CSSSize) Width.
    "! @parameter valueliveupdate       | (boolean) Update the model on every keystroke. Default: false.
    "! @parameter editable              | (boolean) Whether editable. Default: true.
    "! @parameter enabled               | (boolean) Whether enabled. Default: true.
    "! @parameter growing               | (boolean) Auto-grow height with content. Default: false.
    "! @parameter growingmaxlines       | (int) Max lines when growing.
    "! @parameter required              | (boolean) Required field marker. Default: false.
    "! @parameter placeholder           | (string) Placeholder shown while empty.
    "! @parameter valuestate            | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext        | (string) Value state message.
    "! @parameter wrapping              | (sap.ui.core.Wrapping) None | Soft | Hard | Off. Default: None.
    "! @parameter maxlength             | (int) Maximum number of characters. 0 = unlimited. Default: 0.
    "! @parameter textalign             | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection         | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter showvaluestatemessage | (boolean) Show value state message. Default: true.
    "! @parameter showexceededtext      | (boolean) Show character counter when maxLength is set. Default: false. Since 1.48.
    METHODS text_area
      IMPORTING
        value                 TYPE clike OPTIONAL
        rows                  TYPE clike OPTIONAL
        cols                  TYPE clike OPTIONAL
        height                TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        valueliveupdate       TYPE clike OPTIONAL
        editable              TYPE clike OPTIONAL
        enabled               TYPE clike OPTIONAL
        growing               TYPE clike OPTIONAL
        growingmaxlines       TYPE clike OPTIONAL
        id                    TYPE clike OPTIONAL
        required              TYPE clike OPTIONAL
        placeholder           TYPE clike OPTIONAL
        valuestate            TYPE clike OPTIONAL
        valuestatetext        TYPE clike OPTIONAL
        wrapping              TYPE clike OPTIONAL
        maxlength             TYPE clike OPTIONAL
        textalign             TYPE clike OPTIONAL
        textdirection         TYPE clike OPTIONAL
        showvaluestatemessage TYPE clike OPTIONAL
        showexceededtext      TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.RangeSlider</p>
    "!
    "! Slider with two thumbs for selecting a range. See https://ui5.sap.com/#/api/sap.m.RangeSlider.
    "!
    "! @parameter max           | (float) Maximum value. Default: 100.
    "! @parameter min           | (float) Minimum value. Default: 0.
    "! @parameter step          | (float) Step size. Default: 1.
    "! @parameter startvalue    | (float) Lower thumb value. Default: 0.
    "! @parameter endvalue      | (float) Upper thumb value. Default: 100.
    "! @parameter showtickmarks | (boolean) Show tick marks at each step. Default: false.
    "! @parameter labelinterval | (int) Step interval at which labels are rendered. Default: 1.
    "! @parameter width         | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter class         | (string) CSS class names.
    "! @parameter value         | (float) Lower thumb value (alias for startValue).
    "! @parameter value2        | (float) Upper thumb value (alias for endValue).
    "! @parameter change        | (event) Fired when the value changes.
    METHODS range_slider
      IMPORTING
        max           TYPE clike OPTIONAL
        min           TYPE clike OPTIONAL
        step          TYPE clike OPTIONAL
        startvalue    TYPE clike OPTIONAL
        endvalue      TYPE clike OPTIONAL
        showtickmarks TYPE clike OPTIONAL
        labelinterval TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        value2        TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.GenericTag</p>
    "!
    "! Badge-style status tag. See https://ui5.sap.com/#/api/sap.m.GenericTag.
    "!
    "! @parameter arialabelledby | (sap.ui.core.ID[]) Ids of labelling controls (ARIA).
    "! @parameter text           | (string) Tag text.
    "! @parameter design         | (sap.m.GenericTagDesign) Full | StatusIconHidden. Default: Full.
    "! @parameter status         | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter class          | (string) CSS class names.
    "! @parameter press          | (event) Fired when the tag is pressed.
    "! @parameter valuestate     | (sap.m.GenericTagValueState) None | Error. Default: None.
    METHODS generic_tag
      IMPORTING
        id             TYPE clike OPTIONAL
        arialabelledby TYPE clike OPTIONAL
        text           TYPE clike OPTIONAL
        design         TYPE clike OPTIONAL
        status         TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
        press          TYPE clike OPTIONAL
        valuestate     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectAttribute</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectAttribute.
    "!
    "! @parameter title         | (string) Attribute title (label part).
    "! @parameter text          | (string) Attribute value text.
    "! @parameter active        | (boolean) Render the value as a clickable link. Default: false.
    "! @parameter ariahaspopup  | (sap.ui.core.aria.HasPopup) None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter visible       | (boolean) Whether the attribute is visible. Default: true.
    "! @parameter press         | (event) Fired when an active attribute is pressed.
    METHODS object_attribute
      IMPORTING
        title         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        active        TYPE clike OPTIONAL
        ariahaspopup  TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectNumber</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectNumber.
    "!
    "! @parameter state              | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter emphasized         | (boolean) Bold formatting. Default: true.
    "! @parameter number             | (string) Number value.
    "! @parameter textdirection      | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter textalign          | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter numberunit         | (string) DEPRECATED since 1.16.1 - use `unit`.
    "! @parameter inverted           | (boolean) Inverted state coloring. Default: false. Since 1.86.
    "! @parameter emptyindicatormode | (sap.m.EmptyIndicatorMode) On | Off | Auto. Default: Off. Since 1.89.
    "! @parameter active             | (boolean) Render as clickable. Default: false. Since 1.86.
    "! @parameter unit               | (string) Unit text shown after the number.
    "! @parameter visible            | (boolean) Whether the control is visible. Default: true.
    "! @parameter class              | (string) CSS class names.
    METHODS object_number
      IMPORTING
        state              TYPE clike OPTIONAL
        emphasized         TYPE clike OPTIONAL
        number             TYPE clike OPTIONAL
        textdirection      TYPE clike OPTIONAL
        textalign          TYPE clike OPTIONAL
        numberunit         TYPE clike OPTIONAL
        inverted           TYPE clike OPTIONAL
        emptyindicatormode TYPE clike OPTIONAL
        active             TYPE clike OPTIONAL
        unit               TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        id                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Switch</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Switch.
    "!
    "! @parameter state         | (boolean) On/off state. Default: false.
    "! @parameter customtexton  | (string) Custom "on" text (Standard type only).
    "! @parameter customtextoff | (string) Custom "off" text.
    "! @parameter enabled       | (boolean) Whether the switch is enabled. Default: true.
    "! @parameter change        | (event) Fired when the state changes.
    "! @parameter type          | (sap.m.SwitchType) Default | AcceptReject. Default: Default.
    METHODS switch
      IMPORTING
        state         TYPE clike OPTIONAL
        customtexton  TYPE clike OPTIONAL
        customtextoff TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.HarveyBallMicroChartItem</p>
    "!
    "! @parameter color         | (sap.m.ValueCSSColor) Good | Error | Critical | Neutral | CSS color string. Default: Neutral.
    "! @parameter fraction      | (float) Numeric fraction value.
    "! @parameter fractionscale | (string) Pre-formatted text for the fraction value.
    "! @parameter class         | (string) CSS class names.
    METHODS harveyballmicrochartitem
      IMPORTING
        id            TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
        fraction      TYPE clike OPTIONAL
        fractionscale TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.StepInput</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.StepInput.
    "!
    "! @parameter value                 | (float) Current value.
    "! @parameter min                   | (float) Minimum allowed value.
    "! @parameter max                   | (float) Maximum allowed value.
    "! @parameter step                  | (float) Step size. Default: 1.
    "! @parameter width                 | (sap.ui.core.CSSSize) Width.
    "! @parameter valuestate            | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter enabled               | (boolean) Whether enabled. Default: true.
    "! @parameter description           | (string) Short description after the input.
    "! @parameter displayvalueprecision | (int) Number of decimal places shown. Default: 0.
    "! @parameter largerstep            | (float) Step size for Page Up / Page Down. Default: 2.
    "! @parameter stepmode              | (sap.m.StepInputStepModeType) AdditionAndSubtraction | Multiple. Default: AdditionAndSubtraction.
    "! @parameter editable              | (boolean) Whether editable. Default: true.
    "! @parameter fieldwidth            | (sap.ui.core.CSSSize) Width of the input field portion.
    "! @parameter textalign             | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: End.
    "! @parameter validationmode        | (sap.m.StepInputValidationMode) FocusOut | LiveChange. Default: FocusOut.
    "! @parameter change                | (event) Fired when the value changes.
    METHODS step_input
      IMPORTING
        id                    TYPE clike OPTIONAL
        value                 TYPE clike OPTIONAL
        min                   TYPE clike OPTIONAL
        max                   TYPE clike OPTIONAL
        step                  TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        valuestate            TYPE clike OPTIONAL
        enabled               TYPE clike OPTIONAL
        description           TYPE clike OPTIONAL
        displayvalueprecision TYPE clike OPTIONAL
        largerstep            TYPE clike OPTIONAL
        stepmode              TYPE clike OPTIONAL
        editable              TYPE clike OPTIONAL
        fieldwidth            TYPE clike OPTIONAL
        textalign             TYPE clike OPTIONAL
        validationmode        TYPE clike OPTIONAL
        change                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ProgressIndicator</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ProgressIndicator.
    "!
    "! @parameter class        | (string) CSS class names.
    "! @parameter percentvalue | (float) Percentage filled (0..100). Default: 0.
    "! @parameter displayvalue | (string) Text displayed inside the bar.
    "! @parameter showvalue    | (boolean) Show the displayValue inside the bar. Default: true.
    "! @parameter state        | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter visible      | (boolean) Whether the indicator is visible. Default: true.
    METHODS progress_indicator
      IMPORTING
        class         TYPE clike OPTIONAL
        percentvalue  TYPE clike OPTIONAL
        displayvalue  TYPE clike OPTIONAL
        showvalue     TYPE clike OPTIONAL
        state         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.SegmentedButton</p>
    "!
    "! Group of mutually exclusive buttons. See https://ui5.sap.com/#/api/sap.m.SegmentedButton.
    "!
    "! @parameter selected_key     | (string) Two-way bound selected segment key.
    "! @parameter selection_change | (event) Fired when the selected segment changes.
    "! @parameter visible          | (boolean) Whether the control is visible. Default: true.
    "! @parameter enabled          | (boolean) Whether the control is enabled. Default: true.
    METHODS segmented_button
      IMPORTING
        selected_key     TYPE clike OPTIONAL
        selection_change TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        enabled          TYPE clike OPTIONAL
          PREFERRED PARAMETER selected_key
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.CheckBox</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.CheckBox.
    "!
    "! @parameter text              | (string) Label text.
    "! @parameter selected          | (boolean) Two-way bound checked state. Default: false.
    "! @parameter enabled           | (boolean) Whether enabled. Default: true.
    "! @parameter select            | (event) Fired when the state changes.
    "! @parameter class             | (string) CSS class names.
    "! @parameter textalign         | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection     | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter activehandling    | (boolean) Whether activate styling is rendered while pressed. Default: true.
    "! @parameter visible           | (boolean) Whether visible. Default: true.
    "! @parameter displayonly       | (boolean) Display-only mode (no interaction). Default: false. Since 1.54.
    "! @parameter editable          | (boolean) Whether editable. Default: true.
    "! @parameter partiallyselected | (boolean) Render in partially-selected (indeterminate) state. Default: false.
    "! @parameter useentirewidth    | (boolean) Stretch checkbox to entire width. Default: false. Since 1.93.
    "! @parameter wrapping          | (boolean) Wrap label text. Default: false. Since 1.92.
    "! @parameter name              | (string) HTML form name.
    "! @parameter valuestate        | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None. Since 1.85.
    "! @parameter required          | (boolean) Required field marker. Default: false. Since 1.85.
    METHODS checkbox
      IMPORTING
        text              TYPE clike OPTIONAL
        selected          TYPE clike OPTIONAL
        enabled           TYPE clike OPTIONAL
        select            TYPE clike OPTIONAL
        id                TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
        textalign         TYPE clike OPTIONAL
        textdirection     TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        activehandling    TYPE clike OPTIONAL
        visible           TYPE clike OPTIONAL
        displayonly       TYPE clike OPTIONAL
        editable          TYPE clike OPTIONAL
        partiallyselected TYPE clike OPTIONAL
        useentirewidth    TYPE clike OPTIONAL
        wrapping          TYPE clike OPTIONAL
        name              TYPE clike OPTIONAL
        valuestate        TYPE clike OPTIONAL
        required          TYPE clike OPTIONAL
          PREFERRED PARAMETER selected
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `headerToolbar`</p>
    METHODS header_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Toolbar</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Toolbar.
    "!
    "! @parameter ns           | (string) XML namespace prefix.
    "! @parameter press        | (event) Fired when the toolbar is clicked (only when `active=true`).
    "! @parameter width        | (sap.ui.core.CSSSize) Width.
    "! @parameter active       | (boolean) Make the toolbar clickable. Default: false.
    "! @parameter ariahaspopup | (sap.ui.core.aria.HasPopup) None | Menu | ListBox | Tree | Grid | Dialog. Default: None.
    "! @parameter design       | (sap.m.ToolbarDesign) Auto | Solid | Transparent | Info. Default: Auto.
    "! @parameter enabled      | (boolean) Whether the toolbar is enabled. Default: true.
    "! @parameter height       | (sap.ui.core.CSSSize) Height.
    "! @parameter style        | (sap.m.ToolbarStyle) Standard | Clear. Default: Standard.
    "! @parameter visible      | (boolean) Whether the toolbar is visible. Default: true.
    METHODS toolbar
      IMPORTING
        ns            TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        active        TYPE clike OPTIONAL
        ariahaspopup  TYPE clike OPTIONAL
        design        TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        style         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Text</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Text.
    "!
    "! @parameter text               | (string) Text content.
    "! @parameter class              | (string) CSS class names.
    "! @parameter ns                 | (string) XML namespace prefix.
    "! @parameter emptyindicatormode | (sap.m.EmptyIndicatorMode) On | Off | Auto. Default: Off. Since 1.87.
    "! @parameter maxlines           | (int) Maximum lines (text is truncated with ellipsis). Default: 0 (unlimited).
    "! @parameter renderwhitespace   | (boolean) Render leading/trailing whitespace as `&nbsp;`. Default: false.
    "! @parameter textalign          | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Begin.
    "! @parameter textdirection      | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter width              | (sap.ui.core.CSSSize) Width.
    "! @parameter wrapping           | (boolean) Wrap text. Default: true.
    "! @parameter wrappingtype       | (sap.m.WrappingType) Normal | Hyphenated. Default: Normal. Since 1.60.
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    METHODS text
      IMPORTING
        text               TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        ns                 TYPE clike OPTIONAL
        emptyindicatormode TYPE clike OPTIONAL
        maxlines           TYPE clike OPTIONAL
        renderwhitespace   TYPE clike OPTIONAL
        textalign          TYPE clike OPTIONAL
        textdirection      TYPE clike OPTIONAL
        width              TYPE clike OPTIONAL
        wrapping           TYPE clike OPTIONAL
        wrappingtype       TYPE clike OPTIONAL
        id                 TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FormattedText</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.FormattedText.
    "!
    "! @parameter htmltext                    | (string) HTML markup (sanitised set of tags allowed).
    "! @parameter convertedlinksdefaulttarget | (string) Default target for converted links. Default: `_blank`.
    "! @parameter convertlinkstoanchortags    | (sap.m.LinkConversion) None | All | ProtocolOnly. Default: None.
    "! @parameter height                      | (sap.ui.core.CSSSize) Height.
    "! @parameter textalign                   | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Begin.
    "! @parameter textdirection               | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter visible                     | (boolean) Whether visible. Default: true.
    "! @parameter width                       | (sap.ui.core.CSSSize) Width.
    "! @parameter class                       | (string) CSS class names.
    "! @parameter controls                    | (sap.ui.core.ID[]) Ids of controls referenced from inside the markup.
    METHODS formatted_text
      IMPORTING
        htmltext                    TYPE clike OPTIONAL
        convertedlinksdefaulttarget TYPE clike OPTIONAL
        convertlinkstoanchortags    TYPE clike OPTIONAL
        height                      TYPE clike OPTIONAL
        textalign                   TYPE clike OPTIONAL
        textdirection               TYPE clike OPTIONAL
        visible                     TYPE clike OPTIONAL
        width                       TYPE clike OPTIONAL
        id                          TYPE clike OPTIONAL
        class                       TYPE clike OPTIONAL
        controls                    TYPE clike OPTIONAL
          PREFERRED PARAMETER htmltext
      RETURNING
        VALUE(result)               TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Generic builder helper</p>
    "!
    "! @parameter name   | (string) UI5 element name.
    "! @parameter ns     | (string) XML namespace prefix.
    "! @parameter t_prop | (z2ui5_if_types=>ty_t_name_value) Table of property name/value pairs.
    METHODS _generic
      IMPORTING
        name          TYPE clike
        ns            TYPE clike                           OPTIONAL
        t_prop        TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Generic builder helper</p>
    "!
    "! @parameter val | (z2ui5_if_types=>ty_s_name_value) Property name and value.
    METHODS _generic_property
      IMPORTING
        val           TYPE z2ui5_if_types=>ty_s_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Builder helper - return the current XML tree as a string</p>
    METHODS xml_get
      RETURNING
        VALUE(result) TYPE string.

    "! <p class="shorttext synchronized" lang="en">Builder helper</p>
    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.TreeTable</p>
    "!
    "! Tree-style grid table. See https://ui5.sap.com/#/api/sap.ui.table.TreeTable. Inherits sap.ui.table.Table.
    "!
    "! @parameter rows                   | (binding path) Aggregation of rows.
    "! @parameter selectionmode          | (sap.ui.table.SelectionMode) None | Single | MultiToggle. `Multi` deprecated since 1.38.
    "! @parameter enablecolumnreordering | (boolean) Allow column drag-and-drop reordering. Default: true.
    "! @parameter expandfirstlevel       | (boolean) Initially expand first level. Default: false.
    "! @parameter columnselect           | (event) Fired when a column header is selected.
    "! @parameter rowselectionchange     | (event) Fired when row selection changes.
    "! @parameter selectionbehavior      | (sap.ui.table.SelectionBehavior) Row | RowOnly | RowSelector. Default: RowSelector.
    "! @parameter alternaterowcolors     | (boolean) Alternating row background colours. Default: false.
    "! @parameter columnheadervisible    | (boolean) Show column headers. Default: true.
    "! @parameter enablecellfilter       | (boolean) Enable cell context-menu filter. Default: false.
    "! @parameter enablecolumnfreeze     | (boolean) Allow user to freeze columns. Default: false.
    "! @parameter enablecustomfilter     | (boolean) Render Filter menu entry. Default: false.
    "! @parameter enableselectall        | (boolean) Render select-all checkbox. Default: true.
    "! @parameter shownodata             | (boolean) Show empty-state message. Default: true.
    "! @parameter showoverlay            | (boolean) Render an overlay blocking interaction. Default: false.
    "! @parameter visible                | (boolean) Whether the control is visible. Default: true.
    "! @parameter columnheaderheight     | (sap.ui.core.CSSSize) Column header row height.
    "! @parameter firstvisiblerow        | (int) Index of first visible row. Default: 0.
    "! @parameter fixedcolumncount       | (int) Number of fixed (frozen) columns from the start. Default: 0.
    "! @parameter threshold              | (int) Row scrolling threshold. Default: 100.
    "! @parameter width                  | (sap.ui.core.CSSSize) Width.
    "! @parameter usegroupmode           | (boolean) Render as group rows instead of indented tree. Default: false. Since 1.42.
    "! @parameter groupheaderproperty    | (string) Property used as group header text. Since 1.42.
    "! @parameter rowactioncount         | (int) Number of row action cells. Default: 0. Since 1.45.
    "! @parameter selectedindex          | (int) DEPRECATED since 1.69 - use `getSelectedIndices()`.
    "! @parameter visiblerowcount        | (int) DEPRECATED since 1.119 - use `rowMode`. Default: 10.
    "! @parameter visiblerowcountmode    | (sap.ui.table.VisibleRowCountMode) DEPRECATED since 1.119 - use `rowMode`. Fixed | Interactive | Auto. Default: Fixed.
    "! @parameter minautorowcount        | (int) Minimum row count when `visibleRowCountMode=Auto`. Default: 5.
    "! @parameter fixedbottomrowcount    | (int) Number of fixed rows at the bottom. Default: 0.
    "! @parameter fixedrowcount          | (int) Number of fixed rows at the top. Default: 0.
    "! @parameter rowheight              | (int) Row content height in px. Default: theme-dependent.
    "! @parameter toggleopenstate        | (event) Fired when a node is expanded/collapsed.
    METHODS tree_table
      IMPORTING
        rows                   TYPE clike OPTIONAL
        selectionmode          TYPE clike OPTIONAL
        enablecolumnreordering TYPE clike OPTIONAL
        expandfirstlevel       TYPE clike OPTIONAL
        columnselect           TYPE clike OPTIONAL
        rowselectionchange     TYPE clike OPTIONAL
        selectionbehavior      TYPE clike OPTIONAL
        id                     TYPE clike OPTIONAL
        alternaterowcolors     TYPE clike OPTIONAL
        columnheadervisible    TYPE clike OPTIONAL
        enablecellfilter       TYPE clike OPTIONAL
        enablecolumnfreeze     TYPE clike OPTIONAL
        enablecustomfilter     TYPE clike OPTIONAL
        enableselectall        TYPE clike OPTIONAL
        shownodata             TYPE clike OPTIONAL
        showoverlay            TYPE clike OPTIONAL
        visible                TYPE clike OPTIONAL
        columnheaderheight     TYPE clike OPTIONAL
        firstvisiblerow        TYPE clike OPTIONAL
        fixedcolumncount       TYPE clike OPTIONAL
        threshold              TYPE clike OPTIONAL
        width                  TYPE clike OPTIONAL
        usegroupmode           TYPE clike OPTIONAL
        groupheaderproperty    TYPE clike OPTIONAL
        rowactioncount         TYPE clike OPTIONAL
        selectedindex          TYPE clike OPTIONAL
        visiblerowcount        TYPE clike OPTIONAL
        visiblerowcountmode    TYPE clike OPTIONAL
        minautorowcount        TYPE clike OPTIONAL
        fixedbottomrowcount    TYPE clike OPTIONAL
        fixedrowcount          TYPE clike OPTIONAL
        rowheight              TYPE clike OPTIONAL
        toggleopenstate        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `columns`</p>
    METHODS tree_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.Column</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.Column.
    "!
    "! @parameter label    | (string) Header label.
    "! @parameter template | (string) Cell template (column content control).
    "! @parameter halign   | (sap.ui.core.HorizontalAlign) Begin | End | Left | Right | Center. Default: Begin.
    "! @parameter width    | (sap.ui.core.CSSSize) Column width.
    METHODS tree_column
      IMPORTING
        label         TYPE clike
        template      TYPE clike OPTIONAL
        halign        TYPE clike DEFAULT `Begin`
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `template`</p>
    METHODS tree_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `extension`</p>
    METHODS tree_extension
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.filterbar.FilterBar</p>
    "!
    "! Filter bar with variant management. Used together with SmartTable / SmartFilterBar.
    "! See https://ui5.sap.com/#/api/sap.ui.comp.filterbar.FilterBar.
    "!
    "! @parameter usetoolbar                   | (boolean) Render the toolbar in the bar's title area. Default: false.
    "! @parameter search                       | (event) Fired when the search button is pressed.
    "! @parameter persistencykey               | (string) Key used to persist variants/filter state.
    "! @parameter aftervariantload             | (event) Fired after a variant has been loaded.
    "! @parameter aftervariantsave             | (event) Fired after a variant has been saved.
    "! @parameter assignedfilterschanged       | (event) Fired when the assigned filters change.
    "! @parameter beforevariantfetch           | (event) Fired before fetching variants.
    "! @parameter cancel                       | (event) Fired when the user cancels the filter dialog.
    "! @parameter clear                        | (event) Fired when filter values are cleared.
    "! @parameter filterchange                 | (event) Fired when a filter value changes.
    "! @parameter filtersdialogbeforeopen      | (event) Fired before the filters dialog opens.
    "! @parameter filtersdialogcancel          | (event) Fired when the filters dialog is cancelled.
    "! @parameter filtersdialogclosed          | (event) Fired after the filters dialog closes.
    "! @parameter initialise                   | (event) Fired during initialisation (legacy spelling).
    "! @parameter initialized                  | (event) Fired after the filter bar is fully initialised.
    "! @parameter reset                        | (event) Fired when filter values are reset.
    "! @parameter filtercontainerwidth         | (sap.ui.core.CSSSize) Width of an individual filter input container.
    "! @parameter header                       | (string) Header text shown in the filter dialog.
    "! @parameter advancedmode                 | (boolean) Show the advanced filter dialog. Default: false.
    "! @parameter isrunninginvaluehelpdialog   | (boolean) Used internally when the FilterBar runs inside a value-help dialog.
    "! @parameter showallfilters               | (boolean) Show all filters in the dialog by default. Default: false.
    "! @parameter showclearonfb                | (boolean) Show "Clear" button in the bar. Default: false.
    "! @parameter showfilterconfiguration      | (boolean) Show the filter-configuration button. Default: true.
    "! @parameter showgoonfb                   | (boolean) Show "Go" button in the bar. Default: true.
    "! @parameter showrestorebutton            | (boolean) Show "Restore" button in the dialog. Default: true.
    "! @parameter showrestoreonfb              | (boolean) Show "Restore" button in the bar. Default: false.
    "! @parameter usesnapshot                  | (boolean) Use snapshot variant. Default: false.
    "! @parameter searchenabled                | (boolean) Whether the search/Go button is enabled. Default: true.
    "! @parameter considergrouptitle           | (boolean) Consider group title for variants. Default: false.
    "! @parameter deltavariantmode             | (boolean) Persist only the delta when saving variants. Default: true.
    "! @parameter disablesearchmatchespatternw | (boolean) Disable a default search-pattern warning. Default: false.
    "! @parameter filterbarexpanded            | (boolean) Initial expanded state. Default: true.
    METHODS filter_bar
      IMPORTING
        usetoolbar                   TYPE clike DEFAULT `false`
        search                       TYPE clike OPTIONAL
        id                           TYPE clike OPTIONAL
        persistencykey               TYPE clike OPTIONAL
        aftervariantload             TYPE clike OPTIONAL
        aftervariantsave             TYPE clike OPTIONAL
        assignedfilterschanged       TYPE clike OPTIONAL
        beforevariantfetch           TYPE clike OPTIONAL
        cancel                       TYPE clike OPTIONAL
        clear                        TYPE clike OPTIONAL
        filterchange                 TYPE clike OPTIONAL
        filtersdialogbeforeopen      TYPE clike OPTIONAL
        filtersdialogcancel          TYPE clike OPTIONAL
        filtersdialogclosed          TYPE clike OPTIONAL
        initialise                   TYPE clike OPTIONAL
        initialized                  TYPE clike OPTIONAL
        reset                        TYPE clike OPTIONAL
        filtercontainerwidth         TYPE clike OPTIONAL
        header                       TYPE clike OPTIONAL
        advancedmode                 TYPE clike OPTIONAL
        isrunninginvaluehelpdialog   TYPE clike OPTIONAL
        showallfilters               TYPE clike OPTIONAL
        showclearonfb                TYPE clike OPTIONAL
        showfilterconfiguration      TYPE clike OPTIONAL
        showgoonfb                   TYPE clike OPTIONAL
        showrestorebutton            TYPE clike OPTIONAL
        showrestoreonfb              TYPE clike OPTIONAL
        usesnapshot                  TYPE clike OPTIONAL
        searchenabled                TYPE clike OPTIONAL
        considergrouptitle           TYPE clike OPTIONAL
        deltavariantmode             TYPE clike OPTIONAL
        disablesearchmatchespatternw TYPE clike OPTIONAL
        filterbarexpanded            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `filterGroupItems`</p>
    METHODS filter_group_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.filterbar.FilterGroupItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.comp.filterbar.FilterGroupItem.
    "!
    "! @parameter name               | (string) Filter property name.
    "! @parameter label              | (string) Filter label.
    "! @parameter groupname          | (string) Filter group name (`__BASIC` is default).
    "! @parameter visibleinfilterbar | (boolean) Show the filter in the bar (not only the dialog). Default: false.
    "! @parameter mandatory          | (boolean) Required filter marker. Default: false.
    "! @parameter controltooltip     | (string) Tooltip for the filter control.
    "! @parameter entitysetname      | (string) OData entity set used for value help.
    "! @parameter entitytypename     | (string) OData entity type used for value help.
    "! @parameter grouptitle         | (string) Visible group title.
    "! @parameter hiddenfilter       | (boolean) Hide the filter completely. Default: false.
    "! @parameter labeltooltip       | (string) Tooltip for the label.
    "! @parameter visible            | (boolean) Whether the filter is visible. Default: true.
    "! @parameter change             | (event) Fired when the filter value changes.
    METHODS filter_group_item
      IMPORTING
        name               TYPE clike OPTIONAL
        label              TYPE clike OPTIONAL
        groupname          TYPE clike OPTIONAL
        visibleinfilterbar TYPE clike OPTIONAL
        mandatory          TYPE clike OPTIONAL
        controltooltip     TYPE clike OPTIONAL
        entitysetname      TYPE clike OPTIONAL
        entitytypename     TYPE clike OPTIONAL
        grouptitle         TYPE clike OPTIONAL
        hiddenfilter       TYPE clike OPTIONAL
        labeltooltip       TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        change             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `control`</p>
    METHODS filter_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.FlexibleColumnLayout</p>
    "!
    "! Flexible 1/2/3-column layout. See https://ui5.sap.com/#/api/sap.f.FlexibleColumnLayout.
    "!
    "! @parameter layout                        | (sap.f.LayoutType) OneColumn | TwoColumnsBeginExpanded | TwoColumnsMidExpanded |
    "!                                            MidColumnFullScreen | EndColumnFullScreen | ThreeColumnsMidExpanded | ThreeColumnsEndExpanded |
    "!                                            ThreeColumnsMidExpandedEndHidden | ThreeColumnsBeginExpandedEndHidden. Default: OneColumn.
    "! @parameter backgrounddesign              | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Transparent.
    "! @parameter defaulttransitionnamebegincol | (string) Default transition for the begin column.
    "! @parameter defaulttransitionnameendcol   | (string) Default transition for the end column.
    "! @parameter defaulttransitionnamemidcol   | (string) Default transition for the mid column.
    "! @parameter autofocus                     | (boolean) Auto-focus active column on navigation. Default: true.
    "! @parameter restorefocusonbacknavigation  | (boolean) Restore focus on back navigation. Default: false. Since 1.77.
    "! @parameter class                         | (string) CSS class names.
    "! @parameter afterbegincolumnnavigate      | (event) Fired after the begin column has navigated.
    "! @parameter afterendcolumnnavigate        | (event) Fired after the end column has navigated.
    "! @parameter aftermidcolumnnavigate        | (event) Fired after the mid column has navigated.
    "! @parameter begincolumnnavigate           | (event) Fired before the begin column navigates.
    "! @parameter columnresize                  | (event) Fired when a column is resized.
    "! @parameter endcolumnnavigate             | (event) Fired before the end column navigates.
    "! @parameter midcolumnnavigate             | (event) Fired before the mid column navigates.
    "! @parameter statechange                   | (event) Fired when the layout state changes.
    METHODS flexible_column_layout
      IMPORTING
        layout                        TYPE clike
        id                            TYPE clike
        backgrounddesign              TYPE clike OPTIONAL
        defaulttransitionnamebegincol TYPE clike OPTIONAL
        defaulttransitionnameendcol   TYPE clike OPTIONAL
        defaulttransitionnamemidcol   TYPE clike OPTIONAL
        autofocus                     TYPE clike OPTIONAL
        restorefocusonbacknavigation  TYPE clike OPTIONAL
        class                         TYPE clike OPTIONAL
        afterbegincolumnnavigate      TYPE clike OPTIONAL
        afterendcolumnnavigate        TYPE clike OPTIONAL
        aftermidcolumnnavigate        TYPE clike OPTIONAL
        begincolumnnavigate           TYPE clike OPTIONAL
        columnresize                  TYPE clike OPTIONAL
        endcolumnnavigate             TYPE clike OPTIONAL
        midcolumnnavigate             TYPE clike OPTIONAL
        statechange                   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `beginColumnPages`</p>
    METHODS begin_column_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `midColumnPages`</p>
    METHODS mid_column_pages
      IMPORTING
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `endColumnPages`</p>
    METHODS end_column_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.Table</p>
    "!
    "! Grid (non-responsive) table. See https://ui5.sap.com/#/api/sap.ui.table.Table. Renders as `t:Table` in XML views.
    "!
    "! @parameter rows                     | (binding path) Aggregation of rows.
    "! @parameter columnheadervisible      | (boolean) Show column headers. Default: true.
    "! @parameter editable                 | (boolean) Whether cells are editable. Default: true.
    "! @parameter class                    | (string) CSS class names.
    "! @parameter enablecellfilter         | (boolean) Enable cell context-menu filter. Default: false.
    "! @parameter enablegrouping           | (boolean) DEPRECATED since 1.110 - use AnalyticalTable. Default: false.
    "! @parameter enableselectall          | (boolean) Render select-all checkbox. Default: true.
    "! @parameter firstvisiblerow          | (int) Index of first visible row. Default: 0.
    "! @parameter fixedbottomrowcount      | (int) Number of fixed rows at the bottom. Default: 0.
    "! @parameter fixedcolumncount         | (int) Number of fixed columns from the start. Default: 0.
    "! @parameter fixedrowcount            | (int) Number of fixed rows at the top. Default: 0.
    "! @parameter minautorowcount          | (int) Minimum row count when `visibleRowCountMode=Auto`. Default: 5.
    "! @parameter rowactioncount           | (int) Number of row action cells. Default: 0. Since 1.45.
    "! @parameter rowheight                | (int) Row content height in px.
    "! @parameter selectionmode            | (sap.ui.table.SelectionMode) None | Single | MultiToggle. `Multi` deprecated since 1.38. Default: MultiToggle.
    "! @parameter showcolumnvisibilitymenu | (boolean) Show column visibility menu. Default: false.
    "! @parameter shownodata               | (boolean) Show empty-state message. Default: true.
    "! @parameter selectedindex            | (int) DEPRECATED since 1.69 - use `getSelectedIndices()`.
    "! @parameter threshold                | (int) Row scrolling threshold. Default: 100.
    "! @parameter visiblerowcount          | (int) DEPRECATED since 1.119 - use `rowMode`.
    "! @parameter visiblerowcountmode      | (sap.ui.table.VisibleRowCountMode) DEPRECATED since 1.119 - use `rowMode`. Fixed | Interactive | Auto. Default: Fixed.
    "! @parameter alternaterowcolors       | (boolean) Alternating row background colours. Default: false.
    "! @parameter footer                   | (string) Footer text shown below the table.
    "! @parameter filter                   | (event) Fired when a filter operation is applied.
    "! @parameter sort                     | (event) Fired when a sort operation is applied.
    "! @parameter rowselectionchange       | (event) Fired when row selection changes.
    "! @parameter customfilter             | (event) Fired when a custom filter operation is requested.
    "! @parameter flex                     | (boolean, framework helper) Render the table to fit its container.
    "! @parameter selectionbehavior        | (sap.ui.table.SelectionBehavior) Row | RowOnly | RowSelector. Default: RowSelector.
    "! @parameter rowmode                  | (sap.ui.table.rowmodes.RowMode) Aggregation - use `auto`, `fixed` or `interactive` builders.
    METHODS ui_table
      IMPORTING
        rows                     TYPE clike OPTIONAL
        columnheadervisible      TYPE clike OPTIONAL
        editable                 TYPE clike OPTIONAL
        class                    TYPE clike OPTIONAL
        enablecellfilter         TYPE clike OPTIONAL
        enablegrouping           TYPE clike OPTIONAL
        enableselectall          TYPE clike OPTIONAL
        firstvisiblerow          TYPE clike OPTIONAL
        fixedbottomrowcount      TYPE clike OPTIONAL
        fixedcolumncount         TYPE clike OPTIONAL
        fixedrowcount            TYPE clike OPTIONAL
        minautorowcount          TYPE clike OPTIONAL
        rowactioncount           TYPE clike OPTIONAL
        rowheight                TYPE clike OPTIONAL
        selectionmode            TYPE clike OPTIONAL
        showcolumnvisibilitymenu TYPE clike OPTIONAL
        shownodata               TYPE clike OPTIONAL
        selectedindex            TYPE clike OPTIONAL
        threshold                TYPE clike OPTIONAL
        visiblerowcount          TYPE clike OPTIONAL
        visiblerowcountmode      TYPE clike OPTIONAL
        alternaterowcolors       TYPE clike OPTIONAL
        footer                   TYPE clike OPTIONAL
        filter                   TYPE clike OPTIONAL
        sort                     TYPE clike OPTIONAL
        rowselectionchange       TYPE clike OPTIONAL
        customfilter             TYPE clike OPTIONAL
        id                       TYPE clike OPTIONAL
        flex                     TYPE clike OPTIONAL
        selectionbehavior        TYPE clike OPTIONAL
        rowmode                  TYPE clike OPTIONAL
          PREFERRED PARAMETER rows
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.Column</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.Column.
    "!
    "! @parameter width                 | (sap.ui.core.CSSSize) Column width. Default: auto.
    "! @parameter showsortmenuentry     | (boolean) Show "Sort" entry in column menu. Default: true.
    "! @parameter sortproperty          | (string) Property name used for sorting.
    "! @parameter autoresizable         | (boolean) Allow auto-resize on double-click. Default: false.
    "! @parameter filterproperty        | (string) Property name used for filtering.
    "! @parameter showfiltermenuentry   | (boolean) Show "Filter" entry in column menu. Default: true.
    "! @parameter defaultfilteroperator | (string) Default filter operator (e.g. `EQ`, `Contains`).
    "! @parameter filtertype            | (string) Filter value parser type.
    "! @parameter halign                | (sap.ui.core.HorizontalAlign) Begin | End | Left | Right | Center. Default: Begin.
    "! @parameter minwidth              | (int) Minimum column width in px. Default: 0.
    "! @parameter resizable             | (boolean) Allow column resizing. Default: true.
    "! @parameter visible               | (boolean) Whether the column is visible. Default: true.
    METHODS ui_column
      IMPORTING
        id                    TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        showsortmenuentry     TYPE clike OPTIONAL
        sortproperty          TYPE clike OPTIONAL
        autoresizable         TYPE clike OPTIONAL
        filterproperty        TYPE clike OPTIONAL
        showfiltermenuentry   TYPE clike OPTIONAL
        defaultfilteroperator TYPE clike OPTIONAL
        filtertype            TYPE clike OPTIONAL
        halign                TYPE clike OPTIONAL
        minwidth              TYPE clike OPTIONAL
        resizable             TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `columns`</p>
    METHODS ui_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `customData`</p>
    METHODS ui_custom_data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `extension`</p>
    METHODS ui_extension
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `template`</p>
    METHODS ui_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.unified.Currency</p>
    "!
    "! Renders amount and currency aligned for tables. See https://ui5.sap.com/#/api/sap.ui.unified.Currency.
    "!
    "! @parameter value        | (float) Amount value.
    "! @parameter currency     | (string) ISO currency code (e.g. `EUR`).
    "! @parameter usesymbol    | (boolean) Show currency symbol instead of code. Default: false.
    "! @parameter maxprecision | (int) Maximum number of decimals. Default: 3.
    "! @parameter stringvalue  | (string) DEPRECATED - read-only formatted value.
    METHODS currency
      IMPORTING
        value         TYPE clike OPTIONAL
        currency      TYPE clike OPTIONAL
        usesymbol     TYPE clike OPTIONAL
        maxprecision  TYPE clike OPTIONAL
        stringvalue   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `rowActions`</p>
    METHODS ui_row_action
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `template`</p>
    METHODS ui_row_action_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.RowActionItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.RowActionItem.
    "!
    "! @parameter icon    | (sap.ui.core.URI) Icon URI.
    "! @parameter text    | (string) Action text.
    "! @parameter type    | (sap.ui.table.RowActionType) Custom | Navigation | Delete. Default: Custom.
    "! @parameter press   | (event) Fired when the action is pressed.
    "! @parameter visible | (boolean) Whether the action is visible. Default: true.
    METHODS ui_row_action_item
      IMPORTING
        icon          TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.RadioButton</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.RadioButton.
    "!
    "! @parameter activehandling | (boolean) Apply pressed-state styling. Default: true.
    "! @parameter editable       | (boolean) Whether editable. Default: true.
    "! @parameter enabled        | (boolean) Whether enabled. Default: true.
    "! @parameter groupname      | (string) Group name (radio buttons with the same `groupName` are mutually exclusive). Default: `sapMRbDefaultGroup`.
    "! @parameter selected       | (boolean) Selected state. Default: false.
    "! @parameter text           | (string) Label text.
    "! @parameter textalign      | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection  | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter useentirewidth | (boolean) Stretch the radio button to entire width. Default: false. Since 1.93.
    "! @parameter valuestate     | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter width          | (sap.ui.core.CSSSize) Width.
    "! @parameter select         | (event) Fired when the state changes.
    "! @parameter visible        | (boolean) Whether visible. Default: true.
    METHODS radio_button
      IMPORTING
        id             TYPE clike OPTIONAL
        activehandling TYPE clike OPTIONAL
        editable       TYPE clike OPTIONAL
        enabled        TYPE clike OPTIONAL
        groupname      TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
        text           TYPE clike OPTIONAL
        textalign      TYPE clike OPTIONAL
        textdirection  TYPE clike OPTIONAL
        useentirewidth TYPE clike OPTIONAL
        valuestate     TYPE clike OPTIONAL
        width          TYPE clike OPTIONAL
        select         TYPE clike OPTIONAL
        visible        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.RadioButtonGroup</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.RadioButtonGroup.
    "!
    "! @parameter columns       | (int) Number of columns. Default: 1.
    "! @parameter editable      | (boolean) Whether editable. Default: true.
    "! @parameter enabled       | (boolean) Whether enabled. Default: true.
    "! @parameter selectedindex | (int) Two-way bound selected index. Default: 0.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter valuestate    | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter width         | (sap.ui.core.CSSSize) Width.
    "! @parameter select        | (event) Fired when the selected button changes.
    "! @parameter class         | (string) CSS class names.
    METHODS radio_button_group
      IMPORTING
        id            TYPE clike OPTIONAL
        columns       TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        selectedindex TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
        valuestate    TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        select        TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.DynamicSideContent</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.DynamicSideContent.
    "!
    "! @parameter class                 | (string) CSS class names.
    "! @parameter sidecontentvisibility | (sap.ui.layout.SideContentVisibility) AlwaysShow | ShowAboveL | ShowAboveM | ShowAboveS | NeverShow. Default: ShowAboveS.
    "! @parameter showsidecontent       | (boolean) Whether the side content is shown. Default: true.
    "! @parameter containerquery        | (boolean) Use container width instead of viewport. Default: false.
    METHODS dynamic_side_content
      IMPORTING
        id                    TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
        sidecontentvisibility TYPE clike OPTIONAL
        showsidecontent       TYPE clike OPTIONAL
        containerquery        TYPE clike OPTIONAL
          PREFERRED PARAMETER id
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `sideContent`</p>
    "!
    "! @parameter width | (sap.ui.core.CSSSize) Width hint for the side content area.
    METHODS side_content
      IMPORTING
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.PlanningCalendar</p>
    "!
    "! Multi-row planning calendar (Gantt-style). See https://ui5.sap.com/#/api/sap.m.PlanningCalendar.
    "!
    "! @parameter rows                          | (binding path) Aggregation of `PlanningCalendarRow`.
    "! @parameter class                         | (string) CSS class names.
    "! @parameter startdate                     | (object) Start date displayed.
    "! @parameter appointmentsvisualization     | (sap.ui.unified.CalendarAppointmentVisualization) Standard | Filled. Default: Standard.
    "! @parameter appointmentselect             | (event) Fired when an appointment is selected.
    "! @parameter showemptyintervalheaders      | (boolean) Render empty interval header cells. Default: true.
    "! @parameter showweeknumbers               | (boolean) Show week numbers. Default: false.
    "! @parameter showdaynamesline              | (boolean) Show day-names line. Default: true.
    "! @parameter legend                        | (sap.ui.core.ID) Id of the associated legend.
    "! @parameter appointmentheight             | (sap.ui.unified.CalendarAppointmentHeight) HalfSize | Regular | Large | Automatic. Default: Regular.
    "! @parameter appointmentroundwidth         | (sap.ui.unified.CalendarAppointmentRoundWidth) HalfColumn | None. Default: None.
    "! @parameter builtinviews                  | (sap.m.PlanningCalendarBuiltInView[]) Built-in views to render: Hour | Day | Month | Week | OneMonth.
    "! @parameter calendarweeknumbering         | (sap.ui.core.date.CalendarWeekNumbering) Default | ISO_8601 | MiddleEastern | WesternTraditional. Default: Default.
    "! @parameter firstdayofweek                | (int) First day of the week (0=Sunday). Default: -1 (locale-default).
    "! @parameter height                        | (sap.ui.core.CSSSize) Height.
    "! @parameter groupappointmentsmode         | (sap.ui.unified.GroupAppointmentsMode) Collapsed | Expanded. Default: Collapsed.
    "! @parameter iconshape                     | (sap.m.AvatarShape) Square | Circle. Default: Circle.
    "! @parameter maxdate                       | (object) Maximum selectable date.
    "! @parameter mindate                       | (object) Minimum selectable date.
    "! @parameter nodatatext                    | (string) Empty-state text.
    "! @parameter primarycalendartype           | (sap.ui.core.CalendarType) Gregorian | Islamic | Japanese | Persian | Buddhist.
    "! @parameter secondarycalendartype         | (sap.ui.core.CalendarType) Secondary calendar type.
    "! @parameter intervalselect                | (event) Fired when an interval is selected.
    "! @parameter rowheaderpress                | (event) Fired when a row header is pressed.
    "! @parameter rowselectionchange            | (event) Fired when row selection changes.
    "! @parameter startdatechange               | (event) Fired when the start date changes (user navigation).
    "! @parameter viewchange                    | (event) Fired when the active view changes.
    "! @parameter stickyheader                  | (boolean) Make the toolbar header sticky. Default: false.
    "! @parameter viewkey                       | (string) Currently selected view key.
    "! @parameter width                         | (sap.ui.core.CSSSize) Width.
    "! @parameter singleselection               | (boolean) Single-row selection. Default: true.
    "! @parameter showrowheaders                | (boolean) Show row headers. Default: true.
    "! @parameter multipleappointmentsselection | (boolean) Allow multiple appointment selection. Default: false.
    "! @parameter showintervalheaders           | (boolean) Show interval headers. Default: true.
    METHODS planning_calendar
      IMPORTING
        rows                          TYPE clike OPTIONAL
        id                            TYPE clike OPTIONAL
        class                         TYPE clike OPTIONAL
        startdate                     TYPE clike OPTIONAL
        appointmentsvisualization     TYPE clike OPTIONAL
        appointmentselect             TYPE clike OPTIONAL
        showemptyintervalheaders      TYPE clike OPTIONAL
        showweeknumbers               TYPE clike OPTIONAL
        showdaynamesline              TYPE clike OPTIONAL
        legend                        TYPE clike OPTIONAL
        appointmentheight             TYPE clike OPTIONAL
        appointmentroundwidth         TYPE clike OPTIONAL
        builtinviews                  TYPE clike OPTIONAL
        calendarweeknumbering         TYPE clike OPTIONAL
        firstdayofweek                TYPE clike OPTIONAL
        height                        TYPE clike OPTIONAL
        groupappointmentsmode         TYPE clike OPTIONAL
        iconshape                     TYPE clike OPTIONAL
        maxdate                       TYPE clike OPTIONAL
        mindate                       TYPE clike OPTIONAL
        nodatatext                    TYPE clike OPTIONAL
        primarycalendartype           TYPE clike OPTIONAL
        secondarycalendartype         TYPE clike OPTIONAL
        intervalselect                TYPE clike OPTIONAL
        rowheaderpress                TYPE clike OPTIONAL
        rowselectionchange            TYPE clike OPTIONAL
        startdatechange               TYPE clike OPTIONAL
        viewchange                    TYPE clike OPTIONAL
        stickyheader                  TYPE clike OPTIONAL
        viewkey                       TYPE clike OPTIONAL
        width                         TYPE clike OPTIONAL
        singleselection               TYPE clike OPTIONAL
        showrowheaders                TYPE clike OPTIONAL
        multipleappointmentsselection TYPE clike OPTIONAL
        showintervalheaders           TYPE clike OPTIONAL
          PREFERRED PARAMETER rows
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.PlanningCalendarView</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.PlanningCalendarView.
    "!
    "! @parameter appointmentheight      | (sap.ui.unified.CalendarAppointmentHeight) HalfSize | Regular | Large | Automatic.
    "! @parameter description            | (string) Visible description.
    "! @parameter intervallabelformatter | (function) Custom interval label formatter.
    "! @parameter intervalsize           | (int) Size of one interval (e.g. days/hours). Default: 1.
    "! @parameter intervalsl             | (int) Number of intervals on L screens. Default: 12.
    "! @parameter intervalsm             | (int) Number of intervals on M screens. Default: 8.
    "! @parameter intervalss             | (int) Number of intervals on S screens. Default: 6.
    "! @parameter intervaltype           | (sap.ui.unified.CalendarIntervalType) Hour | Day | Month | Week | OneMonth. Default: Hour.
    "! @parameter key                    | (string) View key.
    "! @parameter relative               | (boolean) Use relative numeric labels. Default: false.
    "! @parameter showsubintervals       | (boolean) Show sub-intervals. Default: false.
    METHODS planning_calendar_view
      IMPORTING
        appointmentheight      TYPE clike OPTIONAL
        description            TYPE clike OPTIONAL
        intervallabelformatter TYPE clike OPTIONAL
        intervalsize           TYPE clike OPTIONAL
        intervalsl             TYPE clike OPTIONAL
        intervalsm             TYPE clike OPTIONAL
        intervalss             TYPE clike OPTIONAL
        intervaltype           TYPE clike OPTIONAL
        key                    TYPE clike OPTIONAL
        relative               TYPE clike OPTIONAL
        showsubintervals       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.PlanningCalendarRow</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.PlanningCalendarRow.
    "!
    "! @parameter appointments                  | (binding path) Aggregation of appointments.
    "! @parameter intervalheaders               | (binding path) Aggregation of interval header appointments.
    "! @parameter icon                          | (sap.ui.core.URI) Row icon.
    "! @parameter title                         | (string) Row title.
    "! @parameter key                           | (string) Row key.
    "! @parameter text                          | (string) Row description text.
    "! @parameter enableappointmentscreate      | (boolean) Allow creating appointments by selection. Default: false. Since 1.56.
    "! @parameter enableappointmentsdraganddrop | (boolean) Allow drag-and-drop. Default: false.
    "! @parameter enableappointmentsresize      | (boolean) Allow resizing. Default: false.
    "! @parameter noappointmentstext            | (string) Custom empty-state text.
    "! @parameter nonworkinghours               | (int[]) Non-working hours array.
    "! @parameter rowheaderdescription          | (string) Accessibility description for the row header.
    "! @parameter nonworkingdays                | (int[]) Non-working days array (0=Sunday).
    "! @parameter selected                      | (boolean) Whether the row is selected. Default: false.
    "! @parameter appointmentcreate             | (event) Fired when an appointment is created via selection.
    "! @parameter appointmentdragenter          | (event) Fired when a drag enters the row.
    "! @parameter appointmentdrop               | (event) Fired when an appointment is dropped.
    "! @parameter appointmentresize             | (event) Fired when an appointment is resized.
    "! @parameter class                         | (string) CSS class names.
    METHODS planning_calendar_row
      IMPORTING
        appointments                  TYPE clike OPTIONAL
        intervalheaders               TYPE clike OPTIONAL
        icon                          TYPE clike OPTIONAL
        title                         TYPE clike OPTIONAL
        key                           TYPE clike OPTIONAL
        text                          TYPE clike OPTIONAL
        enableappointmentscreate      TYPE clike OPTIONAL
        enableappointmentsdraganddrop TYPE clike OPTIONAL
        enableappointmentsresize      TYPE clike OPTIONAL
        noappointmentstext            TYPE clike OPTIONAL
        nonworkinghours               TYPE clike OPTIONAL
        rowheaderdescription          TYPE clike OPTIONAL
        nonworkingdays                TYPE clike OPTIONAL
        selected                      TYPE clike OPTIONAL
        appointmentcreate             TYPE clike OPTIONAL
        appointmentdragenter          TYPE clike OPTIONAL
        appointmentdrop               TYPE clike OPTIONAL
        appointmentresize             TYPE clike OPTIONAL
        id                            TYPE clike OPTIONAL
        class                         TYPE clike OPTIONAL
          PREFERRED PARAMETER appointments
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.PlanningCalendarLegend</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.PlanningCalendarLegend.
    "!
    "! @parameter items            | (binding path) Inherited `items` aggregation (regular calendar items).
    "! @parameter appointmentitems | (binding path) Aggregation of appointment legend items.
    "! @parameter standarditems    | (sap.ui.unified.StandardCalendarLegendItem[]) Built-in standard items: Today | WorkingDay | NonWorkingDay | Selected.
    "! @parameter columnwidth      | (sap.ui.core.CSSSize) Column width. Default: auto.
    "! @parameter visible          | (boolean) Whether the legend is visible. Default: true.
    METHODS planning_calendar_legend
      IMPORTING
        items            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        appointmentitems TYPE clike OPTIONAL
        standarditems    TYPE clike OPTIONAL
        columnwidth      TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.unified.CalendarLegendItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.unified.CalendarLegendItem.
    "!
    "! @parameter text    | (string) Item text.
    "! @parameter type    | (sap.ui.unified.CalendarDayType) None | NonWorking | Type01..Type20. Default: None.
    "! @parameter tooltip | (string) Tooltip.
    "! @parameter color   | (sap.ui.core.CSSColor) Custom CSS colour. Since 1.46.
    METHODS calendar_legend_item
      IMPORTING
        text          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `appointmentItems`</p>
    METHODS appointment_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.tnt.InfoLabel</p>
    "!
    "! Coloured status label / chip with numeric or icon variants. See https://ui5.sap.com/#/api/sap.tnt.InfoLabel.
    "!
    "! @parameter text          | (string) Label text.
    "! @parameter rendermode    | (sap.tnt.RenderMode) Loose | Narrow. Default: Loose.
    "! @parameter colorscheme   | (int) Predefined colour scheme (1..10). Default: 7.
    "! @parameter icon          | (sap.ui.core.URI) Optional icon URI. Since 1.74.
    "! @parameter displayonly   | (boolean) Display-only mode (no interaction). Default: false.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter width         | (sap.ui.core.CSSSize) Width.
    "! @parameter visible       | (boolean) Whether visible. Default: true.
    "! @parameter class         | (string) CSS class names.
    METHODS info_label
      IMPORTING
        id            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        rendermode    TYPE clike OPTIONAL
        colorscheme   TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        displayonly   TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `rows`</p>
    METHODS rows
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `appointments`</p>
    METHODS appointments
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.unified.CalendarAppointment</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.unified.CalendarAppointment.
    "!
    "! @parameter startdate | (object) Start date.
    "! @parameter enddate   | (object) End date.
    "! @parameter icon      | (sap.ui.core.URI) Icon URI.
    "! @parameter title     | (string) Title.
    "! @parameter text      | (string) Subtitle/description text.
    "! @parameter type      | (sap.ui.unified.CalendarDayType) None | NonWorking | Type01..Type20. Default: None.
    "! @parameter tentative | (boolean) Render as tentative (striped). Default: false.
    "! @parameter key       | (string) Item key.
    "! @parameter selected  | (boolean) Selected state. Default: false.
    METHODS calendar_appointment
      IMPORTING
        startdate     TYPE clike OPTIONAL
        enddate       TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        tentative     TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
          PREFERRED PARAMETER startdate
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `intervalHeaders`</p>
    METHODS interval_headers
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.BlockLayout</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.BlockLayout.
    "!
    "! @parameter background | (sap.ui.layout.BlockBackgroundType) Default | Light | ColorMix | Dashboard | Accent. `Mixed` is deprecated since 1.50. Default: Default.
    METHODS block_layout
      IMPORTING
        background    TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.BlockLayoutRow</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.BlockLayoutRow.
    "!
    "! @parameter rowcolorset | (sap.ui.layout.BlockRowColorSets) ColorSet1..ColorSet11. Default: ColorSet1.
    METHODS block_layout_row
      IMPORTING
        rowcolorset   TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.BlockLayoutCell</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.BlockLayoutCell.
    "!
    "! @parameter backgroundcolorset   | (sap.ui.layout.BlockLayoutCellColorSet) ColorSet1..ColorSet11.
    "! @parameter backgroundcolorshade | (sap.ui.layout.BlockLayoutCellColorShade) ShadeA | ShadeB | ShadeC | ShadeD. Default: ShadeA.
    "! @parameter title                | (string) Cell title.
    "! @parameter titlealignment       | (sap.ui.core.HorizontalAlign) Begin | End | Left | Right | Center. Default: Begin.
    "! @parameter titlelevel           | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter width                | (int) Width hint as integer ratio.
    "! @parameter class                | (string) CSS class names.
    METHODS block_layout_cell
      IMPORTING
        backgroundcolorset   TYPE clike OPTIONAL
        backgroundcolorshade TYPE clike OPTIONAL
        title                TYPE clike OPTIONAL
        titlealignment       TYPE clike OPTIONAL
        titlelevel           TYPE clike OPTIONAL
        width                TYPE clike OPTIONAL
        class                TYPE clike OPTIONAL
        id                   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectIdentifier</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectIdentifier.
    "!
    "! @parameter emptyindicatormode | (sap.m.EmptyIndicatorMode) On | Off | Auto. Default: Off. Since 1.89.
    "! @parameter text               | (string) Description text.
    "! @parameter textdirection      | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter title              | (string) Title text.
    "! @parameter titleactive        | (boolean) Render title as a clickable link. Default: false.
    "! @parameter visible            | (boolean) Whether the control is visible. Default: true.
    "! @parameter titlepress         | (event) Fired when an active title is pressed.
    METHODS object_identifier
      IMPORTING
        emptyindicatormode TYPE clike OPTIONAL
        text               TYPE clike OPTIONAL
        textdirection      TYPE clike OPTIONAL
        title              TYPE clike OPTIONAL
        titleactive        TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        titlepress         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectStatus</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectStatus.
    "!
    "! @parameter active                | (boolean) Render as a clickable link. Default: false.
    "! @parameter emptyindicatormode    | (sap.m.EmptyIndicatorMode) On | Off | Auto. Default: Off. Since 1.89.
    "! @parameter icon                  | (sap.ui.core.URI) Icon URI.
    "! @parameter icondensityaware      | (boolean) Density-aware icon. Default: true.
    "! @parameter inverted              | (boolean) Inverted state colouring. Default: false. Since 1.74.
    "! @parameter state                 | (sap.ui.core.ValueState | sap.ui.core.IndicationColor) None | Success | Warning | Error | Information | Indication01..Indication10. Default: None.
    "! @parameter stateannouncementtext | (string) Custom accessibility announcement for the state.
    "! @parameter text                  | (string) Status text.
    "! @parameter textdirection         | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter title                 | (string) Status title (label).
    "! @parameter press                 | (event) Fired when an active status is pressed.
    "! @parameter visible               | (boolean) Whether visible. Default: true.
    "! @parameter class                 | (string) CSS class names.
    METHODS object_status
      IMPORTING
        active                TYPE clike OPTIONAL
        emptyindicatormode    TYPE clike OPTIONAL
        icon                  TYPE clike OPTIONAL
        icondensityaware      TYPE clike OPTIONAL
        inverted              TYPE clike OPTIONAL
        state                 TYPE clike OPTIONAL
        stateannouncementtext TYPE clike OPTIONAL
        text                  TYPE clike OPTIONAL
        textdirection         TYPE clike OPTIONAL
        title                 TYPE clike OPTIONAL
        press                 TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
        id                    TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Tree</p>
    "!
    "! Hierarchical list. See https://ui5.sap.com/#/api/sap.m.Tree.
    "!
    "! @parameter items                  | (binding path) Aggregation of `sap.m.StandardTreeItem` (or custom item).
    "! @parameter headertext             | (string, ListBase) Header text.
    "! @parameter headerlevel            | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter footertext             | (string, ListBase) Footer text.
    "! @parameter mode                   | (sap.m.ListMode, ListBase) Selection mode. Default: None.
    "! @parameter includeiteminselection | (boolean, ListBase) Click item to select. Default: false.
    "! @parameter inset                  | (boolean, ListBase) Indent the container. Default: false.
    "! @parameter width                  | (sap.ui.core.CSSSize, ListBase) Width.
    "! @parameter toggleopenstate        | (event) Fired when a node is expanded/collapsed.
    "! @parameter selectionchange        | (event) Fired when selection changes.
    "! @parameter itempress              | (event) Fired when an item is pressed.
    "! @parameter select                 | (event) DEPRECATED since 1.16 - use `selectionChange`.
    "! @parameter multiselectmode        | (sap.m.MultiSelectMode) Default | ClearAll | SelectAll. Default: Default.
    "! @parameter nodatatext             | (string) Empty-state text.
    "! @parameter shownodata             | (boolean) Show empty-state text. Default: true.
    METHODS tree
      IMPORTING
        id                     TYPE clike     OPTIONAL
        items                  TYPE clike     OPTIONAL
        headertext             TYPE clike     OPTIONAL
        headerlevel            TYPE clike     OPTIONAL
        footertext             TYPE clike     OPTIONAL
        mode                   TYPE clike     OPTIONAL
        includeiteminselection TYPE abap_bool OPTIONAL
        inset                  TYPE abap_bool OPTIONAL
        width                  TYPE clike     OPTIONAL
        toggleopenstate        TYPE clike     OPTIONAL
        selectionchange        TYPE clike     OPTIONAL
        itempress              TYPE clike     OPTIONAL
        select                 TYPE clike     OPTIONAL
        multiselectmode        TYPE clike     OPTIONAL
        nodatatext             TYPE clike     OPTIONAL
        shownodata             TYPE clike     OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.StandardTreeItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.StandardTreeItem.
    "!
    "! @parameter title       | (string) Item title.
    "! @parameter icon        | (sap.ui.core.URI) Icon URI.
    "! @parameter press       | (event, ListItemBase) Fired when the item is activated.
    "! @parameter detailpress | (event, ListItemBase) Fired when the detail icon is pressed.
    "! @parameter type        | (sap.m.ListType, ListItemBase) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter selected    | (boolean, ListItemBase) Selected state. Default: false.
    "! @parameter counter     | (int, ListItemBase) Counter badge.
    "! @parameter tooltip     | (string) Tooltip.
    METHODS standard_tree_item
      IMPORTING
        title         TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        detailpress   TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        counter       TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.IconTabBar</p>
    "!
    "! Tab bar where tabs can show icons. See https://ui5.sap.com/#/api/sap.m.IconTabBar.
    "!
    "! @parameter class                  | (string) CSS class names.
    "! @parameter select                 | (event) Fired when a tab is selected.
    "! @parameter expand                 | (event) Fired when the bar is expanded/collapsed.
    "! @parameter expandable             | (boolean) Allow collapsing the content. Default: true.
    "! @parameter expanded               | (boolean) Initial expanded state. Default: true.
    "! @parameter selectedkey            | (string) Two-way bound selected tab key.
    "! @parameter uppercase              | (boolean) Uppercase tab text. Default: false.
    "! @parameter tabsoverflowmode       | (sap.m.TabsOverflowMode) End | StartAndEnd. Default: End.
    "! @parameter tabdensitymode         | (sap.m.IconTabDensityMode) Cozy | Compact | Inherit. Default: Cozy.
    "! @parameter stretchcontentheight   | (boolean) Stretch the content height to fill the parent. Default: false.
    "! @parameter maxnestinglevel        | (int) Max nesting level for sub-tabs. Default: 3.
    "! @parameter headermode             | (sap.m.IconTabHeaderMode) Standard | Inline. Default: Standard.
    "! @parameter headerbackgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Solid.
    "! @parameter enabletabreordering    | (boolean) Allow tab drag-and-drop reordering. Default: false.
    "! @parameter backgrounddesign       | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Solid.
    "! @parameter applycontentpadding    | (boolean) Apply default padding to the content area. Default: true.
    "! @parameter items                  | (binding path) Aggregation of `IconTabFilter` / `IconTabSeparator`.
    "! @parameter content                | (binding path) Default content shown for each filter.
    METHODS icon_tab_bar
      IMPORTING
        class                  TYPE clike OPTIONAL
        select                 TYPE clike OPTIONAL
        expand                 TYPE clike OPTIONAL
        expandable             TYPE clike OPTIONAL
        expanded               TYPE clike OPTIONAL
        selectedkey            TYPE clike OPTIONAL
        uppercase              TYPE clike OPTIONAL
        tabsoverflowmode       TYPE clike OPTIONAL
        tabdensitymode         TYPE clike OPTIONAL
        stretchcontentheight   TYPE clike OPTIONAL
        maxnestinglevel        TYPE clike OPTIONAL
        headermode             TYPE clike OPTIONAL
        headerbackgrounddesign TYPE clike OPTIONAL
        enabletabreordering    TYPE clike OPTIONAL
        backgrounddesign       TYPE clike OPTIONAL
        applycontentpadding    TYPE clike OPTIONAL
        items                  TYPE clike OPTIONAL
        content                TYPE clike OPTIONAL
        id                     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.IconTabFilter</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.IconTabFilter.
    "!
    "! @parameter items            | (binding path) Aggregation of nested filters / sub-tabs.
    "! @parameter showall          | (boolean) Show "All" tab. Default: false.
    "! @parameter icon             | (sap.ui.core.URI) Tab icon URI.
    "! @parameter iconcolor        | (sap.ui.core.IconColor) Default | Positive | Negative | Critical | Neutral. Default: Default.
    "! @parameter count            | (string) Counter shown in the tab.
    "! @parameter text             | (string) Tab label.
    "! @parameter key              | (string) Tab key (matches `selectedKey` on IconTabBar).
    "! @parameter design           | (sap.m.IconTabFilterDesign) Vertical | Horizontal. Default: Vertical.
    "! @parameter icondensityaware | (boolean) Density-aware icon. Default: true.
    "! @parameter visible          | (boolean) Whether the tab is visible. Default: true.
    "! @parameter textdirection    | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter class            | (string) CSS class names.
    METHODS icon_tab_filter
      IMPORTING
        items            TYPE clike OPTIONAL
        showall          TYPE clike OPTIONAL
        icon             TYPE clike OPTIONAL
        iconcolor        TYPE clike OPTIONAL
        count            TYPE clike OPTIONAL
        text             TYPE clike OPTIONAL
        key              TYPE clike OPTIONAL
        design           TYPE clike OPTIONAL
        icondensityaware TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        textdirection    TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.IconTabSeparator</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.IconTabSeparator.
    "!
    "! @parameter icon             | (sap.ui.core.URI) Optional separator icon.
    "! @parameter icondensityaware | (boolean) Density-aware icon. Default: true.
    "! @parameter visible          | (boolean) Whether visible. Default: true.
    "! @parameter class            | (string) CSS class names.
    METHODS icon_tab_separator
      IMPORTING
        icon             TYPE clike OPTIONAL
        icondensityaware TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Builder helper</p>
    METHODS _z2ui5
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_cc.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.GanttChartContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.gantt.GanttChartContainer.
    METHODS gantt_chart_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.config.ContainerToolbar</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.gantt.config.ContainerToolbar.
    "!
    "! @parameter showsearchbutton          | (boolean) Show search button. Default: true.
    "! @parameter aligncustomcontenttoright | (boolean) Align custom toolbar content to right. Default: false.
    "! @parameter findmode                  | (string) Find mode behaviour.
    "! @parameter findbuttonpress           | (event) Fired when the find button is pressed.
    "! @parameter infoofselectitems         | (string) Custom info text for selected items.
    "! @parameter showbirdeyebutton         | (boolean) Show birds-eye-view button. Default: true.
    "! @parameter showdisplaytypebutton     | (boolean) Show display-type button. Default: true.
    "! @parameter showlegendbutton          | (boolean) Show legend button. Default: true.
    "! @parameter showsettingbutton         | (boolean) Show settings button. Default: true.
    "! @parameter showtimezoomcontrol       | (boolean) Show time zoom slider. Default: true.
    "! @parameter stepcountofslider         | (int) Number of steps in zoom slider.
    "! @parameter zoomcontroltype           | (sap.gantt.config.ZoomControlType) Slider | Select | None.
    "! @parameter zoomlevel                 | (int) Initial zoom level.
    METHODS container_toolbar
      IMPORTING
        showsearchbutton          TYPE clike OPTIONAL
        aligncustomcontenttoright TYPE clike OPTIONAL
        findmode                  TYPE clike OPTIONAL
        findbuttonpress           TYPE clike OPTIONAL
        infoofselectitems         TYPE clike OPTIONAL
        showbirdeyebutton         TYPE clike OPTIONAL
        showdisplaytypebutton     TYPE clike OPTIONAL
        showlegendbutton          TYPE clike OPTIONAL
        showsettingbutton         TYPE clike OPTIONAL
        showtimezoomcontrol       TYPE clike OPTIONAL
        stepcountofslider         TYPE clike OPTIONAL
        zoomcontroltype           TYPE clike OPTIONAL
        zoomlevel                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.simple.GanttChartWithTable</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.gantt.simple.GanttChartWithTable.
    "!
    "! @parameter shapeselectionmode        | (sap.gantt.SelectionMode) None | Single | MultiWithKeyboard | Multiple. Default: Multiple.
    "! @parameter isconnectordetailsvisible | (boolean) Show connector details. Default: false.
    METHODS gantt_chart_with_table
      IMPORTING
        id                        TYPE clike OPTIONAL
        shapeselectionmode        TYPE clike OPTIONAL
        isconnectordetailsvisible TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `axisTimeStrategy`</p>
    METHODS axis_time_strategy
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.axistime.ProportionZoomStrategy</p>
    "!
    "! @parameter zoomlevel | (int) Zoom level (0..N).
    METHODS proportion_zoom_strategy
      IMPORTING
        zoomlevel     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `totalHorizon`</p>
    METHODS total_horizon
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.config.TimeHorizon</p>
    "!
    "! @parameter starttime | (string) Start timestamp.
    "! @parameter endtime   | (string) End timestamp.
    METHODS time_horizon
      IMPORTING
        starttime     TYPE clike OPTIONAL
        endtime       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `visibleHorizon`</p>
    METHODS visible_horizon
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `rowSettingsTemplate`</p>
    METHODS row_settings_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.simple.GanttRowSettings</p>
    "!
    "! @parameter rowid         | (string) Row id.
    "! @parameter shapes1       | (binding path) Aggregation of primary shapes.
    "! @parameter relationships | (binding path) Aggregation of relationships.
    "! @parameter shapes2       | (binding path) Aggregation of secondary shapes.
    METHODS gantt_row_settings
      IMPORTING
        rowid         TYPE clike OPTIONAL
        shapes1       TYPE clike OPTIONAL
        relationships TYPE clike OPTIONAL
        shapes2       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `shapes1`</p>
    METHODS shapes1
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `shapes2`</p>
    METHODS shapes2
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.simple.Task</p>
    "!
    "! @parameter type        | (sap.gantt.simple.shapes.TaskType) Normal | Error | Warning | Success.
    "! @parameter color       | (sap.ui.core.CSSColor) Custom CSS colour.
    "! @parameter endtime     | (string) End timestamp.
    "! @parameter time        | (string) Start timestamp.
    "! @parameter title       | (string) Task title.
    "! @parameter showtitle   | (boolean) Show title inside the task. Default: true.
    "! @parameter connectable | (boolean) Allow connections to/from this task. Default: false.
    METHODS task
      IMPORTING
        id            TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
        endtime       TYPE clike OPTIONAL
        time          TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        showtitle     TYPE clike OPTIONAL
        connectable   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `table`</p>
    METHODS gantt_table
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.RatingIndicator</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.RatingIndicator.
    "!
    "! @parameter maxvalue    | (int) Maximum rating value. Default: 5.
    "! @parameter enabled     | (boolean) Whether the rating is enabled. Default: true.
    "! @parameter class       | (string) CSS class names.
    "! @parameter value       | (float) Two-way bound rating value.
    "! @parameter iconsize    | (sap.ui.core.CSSSize) Icon size.
    "! @parameter tooltip     | (string) Tooltip.
    "! @parameter displayonly | (boolean) Display-only mode. Default: false. Since 1.50.
    "! @parameter change      | (event) Fired when the value changes.
    "! @parameter editable    | (boolean) Whether the rating is editable. Default: true.
    METHODS rating_indicator
      IMPORTING
        maxvalue      TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        iconsize      TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
        displayonly   TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `toolbar`</p>
    METHODS gantt_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.simple.BaseRectangle</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.gantt.simple.BaseRectangle.
    "!
    "! @parameter time                    | (string) Start timestamp.
    "! @parameter shapeid                 | (string) Shape id.
    "! @parameter endtime                 | (string) End timestamp.
    "! @parameter selectable              | (boolean) Allow selection. Default: true.
    "! @parameter selectedfill            | (sap.ui.core.CSSColor) Fill while selected.
    "! @parameter fill                    | (sap.ui.core.CSSColor) Default fill colour.
    "! @parameter height                  | (sap.ui.core.CSSSize) Shape height.
    "! @parameter title                   | (string) Title displayed inside the shape.
    "! @parameter animationsettings       | (object) Animation settings object.
    "! @parameter alignshape              | (sap.gantt.simple.shapes.ShapeAlignment) Top | Middle | Bottom. Default: Middle.
    "! @parameter color                   | (sap.ui.core.CSSColor) Stroke colour.
    "! @parameter fontsize                | (int) Title font size.
    "! @parameter connectable             | (boolean) Allow connections. Default: false.
    "! @parameter fontfamily              | (string) Title font family.
    "! @parameter filter                  | (string) SVG filter reference.
    "! @parameter transform               | (string) SVG transform.
    "! @parameter countinbirdeye          | (boolean) Include in birds-eye-view scaling. Default: true.
    "! @parameter fontweight              | (string) Title font weight.
    "! @parameter showtitle               | (boolean) Show the title. Default: true.
    "! @parameter selected                | (boolean) Selected state. Default: false.
    "! @parameter resizable               | (boolean) Allow resizing. Default: false.
    "! @parameter horizontaltextalignment | (sap.gantt.simple.shapes.HorizontalTextAlignment) Start | Middle | End.
    "! @parameter highlighted             | (boolean) Highlighted state. Default: false.
    "! @parameter highlightable           | (boolean) Whether the shape can be highlighted. Default: true.
    METHODS base_rectangle
      IMPORTING
        time                    TYPE clike OPTIONAL
        shapeid                 TYPE clike OPTIONAL
        endtime                 TYPE clike OPTIONAL
        selectable              TYPE clike OPTIONAL
        selectedfill            TYPE clike OPTIONAL
        fill                    TYPE clike OPTIONAL
        height                  TYPE clike OPTIONAL
        title                   TYPE clike OPTIONAL
        animationsettings       TYPE clike OPTIONAL
        alignshape              TYPE clike OPTIONAL
        color                   TYPE clike OPTIONAL
        fontsize                TYPE clike OPTIONAL
        connectable             TYPE clike OPTIONAL
        fontfamily              TYPE clike OPTIONAL
        filter                  TYPE clike OPTIONAL
        transform               TYPE clike OPTIONAL
        countinbirdeye          TYPE clike OPTIONAL
        fontweight              TYPE clike OPTIONAL
        showtitle               TYPE clike OPTIONAL
        selected                TYPE clike OPTIONAL
        resizable               TYPE clike OPTIONAL
        horizontaltextalignment TYPE clike OPTIONAL
        highlighted             TYPE clike OPTIONAL
        highlightable           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.tnt.ToolPage</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.tnt.ToolPage. Children: header (`tool_header`), sideContent, mainContents.
    METHODS tool_page
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.tnt.ToolHeader</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.tnt.ToolHeader.
    METHODS tool_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.IconTabHeader</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.IconTabHeader.
    "!
    "! @parameter selectedkey         | (string) Two-way bound selected tab key.
    "! @parameter items               | (binding path) Aggregation of `IconTabFilter` / `IconTabSeparator`.
    "! @parameter select              | (event) Fired when a tab is selected.
    "! @parameter mode                | (sap.m.IconTabHeaderMode) Standard | Inline. Default: Standard.
    "! @parameter ariatexts           | (object) Custom ARIA texts.
    "! @parameter backgrounddesign    | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Solid.
    "! @parameter enabletabreordering | (boolean) Allow drag-and-drop reordering. Default: false.
    "! @parameter maxnestinglevel     | (int) Max nesting level. Default: 3.
    "! @parameter tabdensitymode      | (sap.m.IconTabDensityMode) Cozy | Compact | Inherit. Default: Cozy.
    "! @parameter tabsoverflowmode    | (sap.m.TabsOverflowMode) End | StartAndEnd. Default: End.
    "! @parameter visible             | (boolean) Whether visible. Default: true.
    METHODS icon_tab_header
      IMPORTING
        selectedkey         TYPE clike OPTIONAL
        items               TYPE clike OPTIONAL
        select              TYPE clike OPTIONAL
        mode                TYPE clike OPTIONAL
        ariatexts           TYPE clike OPTIONAL
        backgrounddesign    TYPE clike OPTIONAL
        enabletabreordering TYPE clike OPTIONAL
        maxnestinglevel     TYPE clike OPTIONAL
        tabdensitymode      TYPE clike OPTIONAL
        tabsoverflowmode    TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        id                  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.NavContainer</p>
    "!
    "! Container that switches between pages with transitions. See https://ui5.sap.com/#/api/sap.m.NavContainer.
    "!
    "! @parameter initialpage           | (sap.ui.core.ID) Id of the page initially shown.
    "! @parameter defaulttransitionname | (string) Default transition: slide | fade | flip | show. Default: slide.
    "! @parameter autofocus             | (boolean) Auto-focus on page change. Default: true.
    "! @parameter height                | (sap.ui.core.CSSSize) Height. Default: 100%.
    "! @parameter width                 | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter visible               | (boolean) Whether visible. Default: true.
    METHODS nav_container
      IMPORTING
        initialpage           TYPE clike OPTIONAL
        id                    TYPE clike OPTIONAL
        defaulttransitionname TYPE clike OPTIONAL
        autofocus             TYPE clike OPTIONAL
        height                TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `pages`</p>
    METHODS pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `mainContents`</p>
    METHODS main_contents
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.TableSelectDialog</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.TableSelectDialog.
    "!
    "! @parameter confirmbuttontext  | (string) Custom OK button text.
    "! @parameter contentheight      | (sap.ui.core.CSSSize) Content area height.
    "! @parameter contentwidth       | (sap.ui.core.CSSSize) Content area width.
    "! @parameter draggable          | (boolean) Whether the dialog is draggable. Default: false.
    "! @parameter growing            | (boolean) Enable growing on the underlying table. Default: true.
    "! @parameter growingthreshold   | (int) Items per growing chunk.
    "! @parameter multiselect        | (boolean) Allow multiple selection. Default: false.
    "! @parameter nodatatext         | (string) Empty-state text.
    "! @parameter rememberselections | (boolean) Persist selections across openings. Default: false.
    "! @parameter resizable          | (boolean) Whether the dialog is resizable. Default: false.
    "! @parameter searchplaceholder  | (string) Search field placeholder.
    "! @parameter showclearbutton    | (boolean) Show "Clear" button. Default: false.
    "! @parameter title              | (string) Dialog title.
    "! @parameter titlealignment     | (sap.m.TitleAlignment) Auto | Start | Center. Default: Auto.
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    "! @parameter items              | (binding path) Aggregation of `sap.m.ColumnListItem` rows.
    "! @parameter livechange         | (event) Fired during typing in the search field.
    "! @parameter cancel             | (event) Fired when the user cancels the dialog.
    "! @parameter search             | (event) Fired when a search is triggered.
    "! @parameter confirm            | (event) Fired when OK is pressed. Provides selected items.
    "! @parameter selectionchange    | (event) Fired when row selection changes.
    METHODS table_select_dialog
      IMPORTING
        confirmbuttontext  TYPE clike OPTIONAL
        contentheight      TYPE clike OPTIONAL
        contentwidth       TYPE clike OPTIONAL
        draggable          TYPE clike OPTIONAL
        growing            TYPE clike OPTIONAL
        growingthreshold   TYPE clike OPTIONAL
        multiselect        TYPE clike OPTIONAL
        nodatatext         TYPE clike OPTIONAL
        rememberselections TYPE clike OPTIONAL
        resizable          TYPE clike OPTIONAL
        searchplaceholder  TYPE clike OPTIONAL
        showclearbutton    TYPE clike OPTIONAL
        title              TYPE clike OPTIONAL
        titlealignment     TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        items              TYPE clike OPTIONAL
        livechange         TYPE clike OPTIONAL
        cancel             TYPE clike OPTIONAL
        search             TYPE clike OPTIONAL
        confirm            TYPE clike OPTIONAL
        selectionchange    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.Graph</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.networkgraph.Graph (legacy: sap.suite.ui.commons.ProcessFlow).
    "!
    "! @parameter foldedcorners | (boolean) Render folded corners on nodes. Default: false.
    "! @parameter scrollable    | (boolean) Allow scrolling. Default: true.
    "! @parameter showlabels    | (boolean) Show node labels. Default: false.
    "! @parameter visible       | (boolean) Whether visible. Default: true.
    "! @parameter wheelzoomable | (boolean) Allow mouse-wheel zoom. Default: false.
    "! @parameter headerpress   | (event) Fired when a lane header is pressed.
    "! @parameter labelpress    | (event) Fired when a node label is pressed.
    "! @parameter nodepress     | (event) Fired when a node is pressed.
    "! @parameter onerror       | (event) Fired on graph error.
    "! @parameter lanes         | (binding path) Aggregation of lanes (process flow legacy).
    "! @parameter nodes         | (binding path) Aggregation of nodes.
    METHODS process_flow
      IMPORTING
        id            TYPE clike OPTIONAL
        foldedcorners TYPE clike OPTIONAL
        scrollable    TYPE clike OPTIONAL
        showlabels    TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        wheelzoomable TYPE clike OPTIONAL
        headerpress   TYPE clike OPTIONAL
        labelpress    TYPE clike OPTIONAL
        nodepress     TYPE clike OPTIONAL
        onerror       TYPE clike OPTIONAL
        lanes         TYPE clike OPTIONAL
        nodes         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `nodes`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS nodes
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.Node</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.networkgraph.Node.
    "!
    "! @parameter alttext               | (string) Alternative text for screen readers.
    "! @parameter collapsed             | (boolean) Collapsed state. Default: false.
    "! @parameter corenodesize          | (sap.ui.core.CSSSize) Core (icon) area size.
    "! @parameter description           | (string) Description text.
    "! @parameter descriptionlinesize   | (int) Maximum lines for description.
    "! @parameter group                 | (string) Group key for layered layouts.
    "! @parameter headercheckboxstate   | (boolean) Header checkbox state.
    "! @parameter height                | (int) Node height in px.
    "! @parameter title                 | (string) Node title.
    "! @parameter icon                  | (sap.ui.core.URI) Icon URI.
    "! @parameter iconsize              | (sap.ui.core.CSSSize) Icon size.
    "! @parameter key                   | (string) Unique key.
    "! @parameter maxwidth              | (int) Maximum width in px.
    "! @parameter selected              | (boolean) Selected state. Default: false.
    "! @parameter shape                 | (sap.suite.ui.commons.networkgraph.NodeShape) Box | Circle. Default: Box.
    "! @parameter showactionlinksbutton | (boolean) Show action-links button. Default: true.
    "! @parameter showdetailbutton      | (boolean) Show detail button. Default: true.
    "! @parameter showexpandbutton      | (boolean) Show expand/collapse button. Default: true.
    "! @parameter statusicon            | (sap.ui.core.URI) Status icon URI.
    "! @parameter titlelinesize         | (int) Maximum lines for title.
    "! @parameter visible               | (boolean) Whether visible. Default: true.
    "! @parameter width                 | (int) Node width in px.
    "! @parameter x                     | (int) X position (only for noopLayout).
    "! @parameter y                     | (int) Y position (only for noopLayout).
    "! @parameter collapseexpand        | (event) Fired when the expand state changes.
    "! @parameter headercheckboxpress   | (event) Fired when the header checkbox is pressed.
    "! @parameter hover                 | (event) Fired on hover.
    "! @parameter press                 | (event) Fired on click.
    "! @parameter attributes            | (binding path) Aggregation of `ElementAttribute`.
    "! @parameter actionbuttons         | (binding path) Aggregation of action buttons.
    METHODS node
      IMPORTING
        id                    TYPE clike OPTIONAL
        class                 TYPE clike OPTIONAL
        alttext               TYPE clike OPTIONAL
        collapsed             TYPE clike OPTIONAL
        corenodesize          TYPE clike OPTIONAL
        description           TYPE clike OPTIONAL
        descriptionlinesize   TYPE clike OPTIONAL
        group                 TYPE clike OPTIONAL
        headercheckboxstate   TYPE clike OPTIONAL
        height                TYPE clike OPTIONAL
        title                 TYPE clike OPTIONAL
        icon                  TYPE clike OPTIONAL
        iconsize              TYPE clike OPTIONAL
        key                   TYPE clike OPTIONAL
        maxwidth              TYPE clike OPTIONAL
        selected              TYPE clike OPTIONAL
        shape                 TYPE clike OPTIONAL
        showactionlinksbutton TYPE clike OPTIONAL
        showdetailbutton      TYPE clike OPTIONAL
        showexpandbutton      TYPE clike OPTIONAL
        statusicon            TYPE clike OPTIONAL
        titlelinesize         TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        x                     TYPE clike OPTIONAL
        y                     TYPE clike OPTIONAL
        collapseexpand        TYPE clike OPTIONAL
        headercheckboxpress   TYPE clike OPTIONAL
        hover                 TYPE clike OPTIONAL
        press                 TYPE clike OPTIONAL
        attributes            TYPE clike OPTIONAL
        actionbuttons         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.NodeImage</p>
    "!
    "! @parameter height | (sap.ui.core.CSSSize) Image height.
    "! @parameter src    | (sap.ui.core.URI) Image URI.
    "! @parameter width  | (sap.ui.core.CSSSize) Image width.
    METHODS node_image
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        src           TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `lanes`</p>
    METHODS lanes
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.ProcessFlowNode</p>
    "!
    "! @parameter laneid            | (string) Lane id this node belongs to.
    "! @parameter nodeid            | (string) Node id.
    "! @parameter title             | (string) Title text.
    "! @parameter titleabbreviation | (string) Abbreviation shown when collapsed.
    "! @parameter children          | (string[]) Ids of child nodes.
    "! @parameter state             | (sap.suite.ui.commons.ProcessFlowNodeState | array) Positive | Negative | Neutral | Planned | PlannedNegative.
    "! @parameter statetext         | (string) State announcement text.
    "! @parameter texts             | (string[]) Additional texts shown in the node.
    "! @parameter highlighted       | (boolean) Highlighted state. Default: false.
    "! @parameter focused           | (boolean) Focused state. Default: false.
    "! @parameter selected          | (boolean) Selected state. Default: false.
    "! @parameter tag               | (string) Tag string.
    "! @parameter type              | (sap.suite.ui.commons.ProcessFlowNodeType) Single | Aggregated. Default: Single.
    METHODS process_flow_node
      IMPORTING
        laneid            TYPE clike OPTIONAL
        nodeid            TYPE clike OPTIONAL
        title             TYPE clike OPTIONAL
        titleabbreviation TYPE clike OPTIONAL
        children          TYPE clike OPTIONAL
        state             TYPE clike OPTIONAL
        statetext         TYPE clike OPTIONAL
        texts             TYPE clike OPTIONAL
        highlighted       TYPE clike OPTIONAL
        focused           TYPE clike OPTIONAL
        selected          TYPE clike OPTIONAL
        tag               TYPE clike OPTIONAL
        type              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.ProcessFlowLaneHeader</p>
    "!
    "! @parameter iconsrc   | (sap.ui.core.URI) Icon URI.
    "! @parameter laneid    | (string) Lane id.
    "! @parameter position  | (int) Lane position.
    "! @parameter state     | (sap.suite.ui.commons.ProcessFlowLaneState) Initial values for state.
    "! @parameter text      | (string) Header text.
    "! @parameter zoomlevel | (sap.suite.ui.commons.ProcessFlowZoomLevel) One | Two | Three | Four. Default: Two.
    METHODS process_flow_lane_header
      IMPORTING
        iconsrc       TYPE clike OPTIONAL
        laneid        TYPE clike OPTIONAL
        position      TYPE clike OPTIONAL
        state         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        zoomlevel     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ViewSettingsDialog</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ViewSettingsDialog.
    "!
    "! @parameter confirm                  | (event) Fired when OK is pressed. Provides selected sort / group / filter settings.
    "! @parameter cancel                   | (event) Fired when the user cancels the dialog.
    "! @parameter filterdetailpageopened   | (event) Fired when a filter detail page is opened.
    "! @parameter reset                    | (event) Fired when "Reset" is pressed.
    "! @parameter resetfilters             | (event) Fired when filter values are reset.
    "! @parameter filtersearchoperator    | (sap.m.StringFilterOperator) Contains | StartsWith | Equals | AnyWordStartsWith. Default: StartsWith.
    "! @parameter groupdescending          | (boolean) Initial group direction (descending). Default: false.
    "! @parameter sortdescending           | (boolean) Initial sort direction (descending). Default: false.
    "! @parameter title                    | (string) Dialog title.
    "! @parameter titlealignment           | (sap.m.TitleAlignment) Auto | Start | Center. Default: Auto.
    "! @parameter selectedgroupitem        | (sap.ui.core.ID) Initially selected group item id.
    "! @parameter selectedpresetfilteritem | (sap.ui.core.ID) Initially selected preset-filter item id.
    "! @parameter selectedsortitem         | (sap.ui.core.ID) Initially selected sort item id.
    "! @parameter filteritems              | (binding path) Aggregation of filter items.
    "! @parameter sortitems                | (binding path) Aggregation of sort items.
    "! @parameter groupitems               | (binding path) Aggregation of group items.
    METHODS view_settings_dialog
      IMPORTING
        confirm                  TYPE clike OPTIONAL
        cancel                   TYPE clike OPTIONAL
        filterdetailpageopened   TYPE clike OPTIONAL
        reset                    TYPE clike OPTIONAL
        resetfilters             TYPE clike OPTIONAL
        filtersearchoperator     TYPE clike OPTIONAL
        groupdescending          TYPE clike OPTIONAL
        sortdescending           TYPE clike OPTIONAL
        title                    TYPE clike OPTIONAL
        titlealignment           TYPE clike OPTIONAL
        selectedgroupitem        TYPE clike OPTIONAL
        selectedpresetfilteritem TYPE clike OPTIONAL
        selectedsortitem         TYPE clike OPTIONAL
        filteritems              TYPE clike OPTIONAL
        sortitems                TYPE clike OPTIONAL
        groupitems               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `filterItems`</p>
    METHODS filter_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `sortItems`</p>
    METHODS sort_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `groupItems`</p>
    METHODS group_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ViewSettingsFilterItem</p>
    "!
    "! @parameter enabled       | (boolean) Whether the filter is enabled. Default: true.
    "! @parameter key           | (string) Filter key.
    "! @parameter multiselect   | (boolean) Allow multi-selection. Default: true.
    "! @parameter selected      | (boolean) Selected state. Default: false.
    "! @parameter text          | (string) Filter text.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    METHODS view_settings_filter_item
      IMPORTING
        enabled       TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        multiselect   TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ViewSettingsItem</p>
    "!
    "! @parameter enabled       | (boolean) Whether the item is enabled. Default: true.
    "! @parameter key           | (string) Item key.
    "! @parameter selected      | (boolean) Selected state. Default: false.
    "! @parameter text          | (string) Item text.
    "! @parameter textdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    METHODS view_settings_item
      IMPORTING
        enabled       TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        textdirection TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.variants.VariantManagement</p>
    "!
    "! Variant management for smart controls. See https://ui5.sap.com/#/api/sap.ui.comp.variants.VariantManagement.
    "! For modern SmartFilterBar/SmartTable use `variant_management_sapm` (sap.ui.fl.variants.VariantManagement) or `smart_variant_management` instead.
    "!
    "! @parameter defaultvariantkey      | (string) Key of the default variant.
    "! @parameter enabled                | (boolean) Whether enabled. Default: true.
    "! @parameter inerrorstate           | (boolean) Render in error state. Default: false.
    "! @parameter initialselectionkey    | (string) Initially selected variant key.
    "! @parameter lifecyclesupport       | (boolean) Show transport / package fields. Default: false.
    "! @parameter selectionkey           | (string) Currently selected variant key.
    "! @parameter showcreatetile         | (boolean) Show "Create Tile" entry. Default: false.
    "! @parameter showexecuteonselection | (boolean) Show "Apply Automatically" checkbox. Default: false.
    "! @parameter showsetasdefault       | (boolean) Show "Set as Default" checkbox. Default: true.
    "! @parameter showshare              | (boolean) Show "Public" checkbox. Default: false.
    "! @parameter standarditemauthor     | (string) Author shown for the standard item.
    "! @parameter standarditemtext       | (string) Text of the standard item.
    "! @parameter usefavorites           | (boolean) Enable favourites. Default: false.
    "! @parameter visible                | (boolean) Whether visible. Default: true.
    "! @parameter variantitems           | (binding path) Aggregation of variant items.
    "! @parameter manage                 | (event) Fired when the user opens the management dialog.
    "! @parameter save                   | (event) Fired when a variant is saved.
    "! @parameter select                 | (event) Fired when a variant is selected.
    "! @parameter uservarcreate          | (event) Fired when a new variant is created by the user.
    METHODS variant_management
      IMPORTING
        defaultvariantkey      TYPE clike OPTIONAL
        enabled                TYPE clike OPTIONAL
        inerrorstate           TYPE clike OPTIONAL
        initialselectionkey    TYPE clike OPTIONAL
        lifecyclesupport       TYPE clike OPTIONAL
        selectionkey           TYPE clike OPTIONAL
        showcreatetile         TYPE clike OPTIONAL
        showexecuteonselection TYPE clike OPTIONAL
        showsetasdefault       TYPE clike OPTIONAL
        showshare              TYPE clike OPTIONAL
        standarditemauthor     TYPE clike OPTIONAL
        standarditemtext       TYPE clike OPTIONAL
        usefavorites           TYPE clike OPTIONAL
        visible                TYPE clike OPTIONAL
        variantitems           TYPE clike OPTIONAL
        manage                 TYPE clike OPTIONAL
        save                   TYPE clike OPTIONAL
        select                 TYPE clike OPTIONAL
        uservarcreate          TYPE clike OPTIONAL
        id                     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `variantItems`</p>
    METHODS variant_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.variants.VariantItem</p>
    "!
    "! @parameter executeonselection      | (boolean) Apply automatically on selection. Default: false.
    "! @parameter global                  | (boolean) Public/global variant. Default: false.
    "! @parameter labelreadonly           | (boolean) Whether the label is read-only. Default: false.
    "! @parameter lifecyclepackage        | (string) Transport package.
    "! @parameter lifecycletransportid    | (string) Transport id.
    "! @parameter namespace               | (string) Variant namespace.
    "! @parameter readonly                | (boolean) Whether the variant is read-only. Default: false.
    "! @parameter executeonselect         | (boolean) Apply automatically on select. Default: false.
    "! @parameter author                  | (string) Variant author.
    "! @parameter changeable              | (boolean) Whether changeable. Default: false.
    "! @parameter enabled                 | (boolean, Item) Whether selectable. Default: true.
    "! @parameter favorite                | (boolean) Favourite state. Default: false.
    "! @parameter key                     | (string, Item) Item key.
    "! @parameter text                    | (string, Item) Display text.
    "! @parameter title                   | (string) Display title.
    "! @parameter textdirection           | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter originaltitle           | (string) Original title (used for change detection).
    "! @parameter originalexecuteonselect | (boolean) Original `executeOnSelect` value.
    "! @parameter remove                  | (boolean) Mark for removal.
    "! @parameter rename                  | (boolean) Mark as renamed.
    "! @parameter originalfavorite        | (boolean) Original favourite value.
    "! @parameter sharing                 | (sap.ui.comp.variants.SharingOption) Sharing option.
    "! @parameter change                  | (event) Fired when item details change.
    METHODS variant_item
      IMPORTING
        executeonselection      TYPE clike OPTIONAL
        global                  TYPE clike OPTIONAL
        labelreadonly           TYPE clike OPTIONAL
        lifecyclepackage        TYPE clike OPTIONAL
        lifecycletransportid    TYPE clike OPTIONAL
        namespace               TYPE clike OPTIONAL
        readonly                TYPE clike OPTIONAL
        executeonselect         TYPE clike OPTIONAL
        author                  TYPE clike OPTIONAL
        changeable              TYPE clike OPTIONAL
        enabled                 TYPE clike OPTIONAL
        favorite                TYPE clike OPTIONAL
        key                     TYPE clike OPTIONAL
        text                    TYPE clike OPTIONAL
        title                   TYPE clike OPTIONAL
        textdirection           TYPE clike OPTIONAL
        originaltitle           TYPE clike OPTIONAL
        originalexecuteonselect TYPE clike OPTIONAL
        remove                  TYPE clike OPTIONAL
        rename                  TYPE clike OPTIONAL
        originalfavorite        TYPE clike OPTIONAL
        sharing                 TYPE clike OPTIONAL
        change                  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.VariantManagement</p>
    "!
    "! Modern variant management. See https://ui5.sap.com/#/api/sap.m.VariantManagement.
    "!
    "! @parameter creationallowed           | (boolean) Allow creating new variants. Default: true.
    "! @parameter defaultkey                | (string) Key of the default variant.
    "! @parameter inerrorstate              | (boolean) Render in error state. Default: false.
    "! @parameter level                     | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter maxwidth                  | (sap.ui.core.CSSSize) Maximum text width.
    "! @parameter modified                  | (boolean) Marks the variant as modified. Default: false.
    "! @parameter popovertitle              | (string) Custom popover title.
    "! @parameter selectedkey               | (string) Selected variant key.
    "! @parameter showfooter                | (boolean) Show footer with Save/Save As. Default: true.
    "! @parameter showsaveas                | (boolean) Show "Save As" button. Default: true.
    "! @parameter supportapplyautomatically | (boolean) Show "Apply Automatically" option. Default: true.
    "! @parameter supportcontexts           | (boolean) Support context-based filtering. Default: false.
    "! @parameter supportdefault            | (boolean) Support setting a default variant. Default: true.
    "! @parameter supportfavorites          | (boolean) Support favourites. Default: true.
    "! @parameter supportpublic             | (boolean) Support sharing variants publicly. Default: true.
    "! @parameter titlestyle                | (sap.ui.core.TitleLevel) Style for the title.
    "! @parameter visible                   | (boolean) Whether visible. Default: true.
    "! @parameter items                     | (binding path) Aggregation of variant items.
    "! @parameter cancel                    | (event) Fired when management dialog is cancelled.
    "! @parameter manage                    | (event) Fired when management is confirmed.
    "! @parameter managecancel              | (event) Fired when management dialog is closed without saving.
    "! @parameter save                      | (event) Fired when a variant is saved.
    "! @parameter select                    | (event) Fired when a variant is selected.
    METHODS variant_management_sapm
      IMPORTING
        creationallowed           TYPE clike OPTIONAL
        defaultkey                TYPE clike OPTIONAL
        inerrorstate              TYPE clike OPTIONAL
        level                     TYPE clike OPTIONAL
        maxwidth                  TYPE clike OPTIONAL
        modified                  TYPE clike OPTIONAL
        popovertitle              TYPE clike OPTIONAL
        selectedkey               TYPE clike OPTIONAL
        showfooter                TYPE clike OPTIONAL
        showsaveas                TYPE clike OPTIONAL
        supportapplyautomatically TYPE clike OPTIONAL
        supportcontexts           TYPE clike OPTIONAL
        supportdefault            TYPE clike OPTIONAL
        supportfavorites          TYPE clike OPTIONAL
        supportpublic             TYPE clike OPTIONAL
        titlestyle                TYPE clike OPTIONAL
        visible                   TYPE clike OPTIONAL
        items                     TYPE clike OPTIONAL
        cancel                    TYPE clike OPTIONAL
        manage                    TYPE clike OPTIONAL
        managecancel              TYPE clike OPTIONAL
        save                      TYPE clike OPTIONAL
        select                    TYPE clike OPTIONAL
        id                        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.VariantItem</p>
    "!
    "! @parameter author          | (string) Author name.
    "! @parameter changeable      | (boolean) Whether changeable. Default: false.
    "! @parameter contexts        | (object) Context conditions.
    "! @parameter executeonselect | (boolean) Apply automatically on select. Default: false.
    "! @parameter favorite        | (boolean) Favourite state. Default: false.
    "! @parameter key             | (string) Variant key.
    "! @parameter remove          | (boolean) Mark for removal.
    "! @parameter rename          | (boolean) Mark as renamed.
    "! @parameter sharing         | (sap.m.VariantSharing) Public | Private. Default: Public.
    "! @parameter title           | (string) Display title.
    "! @parameter visible         | (boolean) Whether visible. Default: true.
    "! @parameter textdirection   | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter text            | (string) Display text.
    "! @parameter enabled         | (boolean) Whether enabled. Default: true.
    METHODS variant_item_sapm
      IMPORTING
        author          TYPE clike OPTIONAL
        changeable      TYPE clike OPTIONAL
        contexts        TYPE clike OPTIONAL
        executeonselect TYPE clike OPTIONAL
        favorite        TYPE clike OPTIONAL
        key             TYPE clike OPTIONAL
        remove          TYPE clike OPTIONAL
        rename          TYPE clike OPTIONAL
        sharing         TYPE clike OPTIONAL
        title           TYPE clike OPTIONAL
        visible         TYPE clike OPTIONAL
        id              TYPE clike OPTIONAL
        textdirection   TYPE clike OPTIONAL
        text            TYPE clike OPTIONAL
        enabled         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FeedInput</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.FeedInput.
    "!
    "! @parameter buttontooltip    | (string) Tooltip for the post button.
    "! @parameter enabled          | (boolean) Whether enabled. Default: true.
    "! @parameter growing          | (boolean) Auto-grow with content. Default: false.
    "! @parameter growingmaxlines  | (int) Max lines when growing.
    "! @parameter icon             | (sap.ui.core.URI) Icon URI.
    "! @parameter icondensityaware | (boolean) Density-aware icon. Default: true.
    "! @parameter icondisplayshape | (sap.m.AvatarShape) Circle | Square. Default: Circle.
    "! @parameter iconinitials     | (string) Initials shown when no icon is set.
    "! @parameter iconsize         | (sap.m.AvatarSize) XS | S | M | L | XL | Custom. Default: M.
    "! @parameter maxlength        | (int) Maximum number of characters. 0 = unlimited.
    "! @parameter placeholder      | (string) Placeholder shown while empty.
    "! @parameter rows             | (int) Number of visible rows. Default: 2.
    "! @parameter showexceededtext | (boolean) Show character counter. Default: false.
    "! @parameter showicon         | (boolean) Show the icon. Default: true.
    "! @parameter value            | (string) Two-way bound value.
    "! @parameter post             | (event) Fired when the user posts the feed entry.
    "! @parameter class            | (string) CSS class names.
    METHODS feed_input
      IMPORTING
        buttontooltip    TYPE clike OPTIONAL
        enabled          TYPE clike OPTIONAL
        growing          TYPE clike OPTIONAL
        growingmaxlines  TYPE clike OPTIONAL
        icon             TYPE clike OPTIONAL
        icondensityaware TYPE clike OPTIONAL
        icondisplayshape TYPE clike OPTIONAL
        iconinitials     TYPE clike OPTIONAL
        iconsize         TYPE clike OPTIONAL
        maxlength        TYPE clike OPTIONAL
        placeholder      TYPE clike OPTIONAL
        rows             TYPE clike OPTIONAL
        showexceededtext TYPE clike OPTIONAL
        showicon         TYPE clike OPTIONAL
        value            TYPE clike OPTIONAL
        post             TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FeedListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.FeedListItem.
    "!
    "! @parameter activeicon                  | (sap.ui.core.URI) Icon shown while pressed.
    "! @parameter convertedlinksdefaulttarget | (string) Default target for auto-converted links. Default: _blank.
    "! @parameter convertlinkstoanchortags    | (sap.m.LinkConversion) None | All | ProtocolOnly. Default: None.
    "! @parameter icon                        | (sap.ui.core.URI) Icon URI.
    "! @parameter iconactive                  | (boolean) Render icon as clickable. Default: true.
    "! @parameter icondensityaware            | (boolean) Density-aware icon. Default: true.
    "! @parameter icondisplayshape            | (sap.m.AvatarShape) Circle | Square. Default: Circle.
    "! @parameter iconinitials                | (string) Initials when no icon is set.
    "! @parameter iconsize                    | (sap.m.AvatarSize) XS | S | M | L | XL | Custom. Default: M.
    "! @parameter info                        | (string) Info text shown on the right.
    "! @parameter lesslabel                   | (string) Custom "Less" label for collapsed state.
    "! @parameter maxcharacters               | (int) Truncate text after N characters. 0 = unlimited.
    "! @parameter morelabel                   | (string) Custom "More" label.
    "! @parameter sender                      | (string) Sender name shown above the text.
    "! @parameter senderactive                | (boolean) Render sender as clickable. Default: true.
    "! @parameter showicon                    | (boolean) Show the icon. Default: true.
    "! @parameter text                        | (string) Feed text.
    "! @parameter timestamp                   | (string) Timestamp text.
    "! @parameter iconpress                   | (event) Fired when the icon is pressed.
    "! @parameter senderpress                 | (event) Fired when the sender link is pressed.
    METHODS feed_list_item
      IMPORTING
        activeicon                  TYPE clike OPTIONAL
        convertedlinksdefaulttarget TYPE clike OPTIONAL
        convertlinkstoanchortags    TYPE clike OPTIONAL
        icon                        TYPE clike OPTIONAL
        iconactive                  TYPE clike OPTIONAL
        icondensityaware            TYPE clike OPTIONAL
        icondisplayshape            TYPE clike OPTIONAL
        iconinitials                TYPE clike OPTIONAL
        iconsize                    TYPE clike OPTIONAL
        info                        TYPE clike OPTIONAL
        lesslabel                   TYPE clike OPTIONAL
        maxcharacters               TYPE clike OPTIONAL
        morelabel                   TYPE clike OPTIONAL
        sender                      TYPE clike OPTIONAL
        senderactive                TYPE clike OPTIONAL
        showicon                    TYPE clike OPTIONAL
        text                        TYPE clike OPTIONAL
        timestamp                   TYPE clike OPTIONAL
        iconpress                   TYPE clike OPTIONAL
        senderpress                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)               TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FeedListItemAction</p>
    "!
    "! @parameter enabled | (boolean) Whether enabled. Default: true.
    "! @parameter icon    | (sap.ui.core.URI) Icon URI.
    "! @parameter key     | (string) Action key.
    "! @parameter text    | (string) Action text.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    "! @parameter press   | (event) Fired when the action is pressed.
    METHODS feed_list_item_action
      IMPORTING
        enabled       TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FeedContent</p>
    "!
    "! @parameter contenttext | (string) Content text.
    "! @parameter subheader   | (string) Subheader text.
    "! @parameter value       | (string) Value text.
    "! @parameter class       | (string) CSS class names.
    "! @parameter press       | (event) Fired when the content is pressed.
    METHODS feed_content
      IMPORTING
        contenttext   TYPE clike OPTIONAL
        subheader     TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.NewsContent</p>
    "!
    "! @parameter contenttext | (string) Headline text.
    "! @parameter subheader   | (string) Subheader text.
    "! @parameter press       | (event) Fired when the content is pressed.
    METHODS news_content
      IMPORTING
        contenttext   TYPE clike OPTIONAL
        subheader     TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.unified.ColorPicker</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.unified.ColorPicker.
    "!
    "! @parameter colorstring | (sap.ui.core.CSSColor) Two-way bound colour string. Required.
    "! @parameter displaymode | (sap.ui.unified.ColorPickerDisplayMode) Default | Large | Simplified. Default: Default.
    "! @parameter change      | (event) Fired when the colour is committed.
    "! @parameter livechange  | (event) Fired during interactive selection.
    METHODS color_picker
      IMPORTING
        colorstring   TYPE clike
        displaymode   TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        livechange    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MaskInput</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.MaskInput.
    "!
    "! @parameter placeholder           | (string) Placeholder shown while empty.
    "! @parameter mask                  | (string) Mask pattern (e.g. `9999-99-99`).
    "! @parameter name                  | (string) HTML form name.
    "! @parameter textalign             | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection         | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter value                 | (string) Two-way bound value.
    "! @parameter width                 | (sap.ui.core.CSSSize) Width.
    "! @parameter valuestate            | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext        | (string) Value state message.
    "! @parameter placeholdersymbol     | (string) Mask placeholder symbol. Default: `_`.
    "! @parameter required              | (boolean) Required field marker. Default: false.
    "! @parameter showclearicon         | (boolean) Show a clear icon. Default: false.
    "! @parameter showvaluestatemessage | (boolean) Show value state message. Default: true.
    "! @parameter visible               | (boolean) Whether visible. Default: true.
    "! @parameter fieldwidth            | (sap.ui.core.CSSSize) Width of the input portion vs description.
    "! @parameter livechange            | (event) Fired during typing.
    "! @parameter change                | (event) Fired when the value is committed.
    METHODS mask_input
      IMPORTING
        placeholder           TYPE clike OPTIONAL
        mask                  TYPE clike OPTIONAL
        name                  TYPE clike OPTIONAL
        textalign             TYPE clike OPTIONAL
        textdirection         TYPE clike OPTIONAL
        value                 TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        valuestate            TYPE clike OPTIONAL
        valuestatetext        TYPE clike OPTIONAL
        placeholdersymbol     TYPE clike OPTIONAL
        required              TYPE clike OPTIONAL
        showclearicon         TYPE clike OPTIONAL
        showvaluestatemessage TYPE clike OPTIONAL
        visible               TYPE clike OPTIONAL
        fieldwidth            TYPE clike OPTIONAL
        livechange            TYPE clike OPTIONAL
        change                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.ResponsiveSplitter</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.ResponsiveSplitter.
    "!
    "! @parameter defaultpane | (sap.ui.core.ID) Id of the default pane.
    "! @parameter height      | (sap.ui.core.CSSSize) Height. Default: 100%.
    "! @parameter width       | (sap.ui.core.CSSSize) Width. Default: 100%.
    METHODS responsive_splitter
      IMPORTING
        defaultpane   TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.Splitter</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.Splitter.
    "!
    "! @parameter height      | (sap.ui.core.CSSSize) Height. Default: 100%.
    "! @parameter orientation | (sap.ui.core.Orientation) Horizontal | Vertical. Default: Horizontal.
    "! @parameter width       | (sap.ui.core.CSSSize) Width. Default: 100%.
    METHODS splitter
      IMPORTING
        height        TYPE clike OPTIONAL
        orientation   TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.InvisibleText</p>
    "!
    "! @parameter ns   | (string) XML namespace prefix.
    "! @parameter text | (string) Text content (announced by screen readers).
    METHODS invisible_text
      IMPORTING
        ns            TYPE clike
        id            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.FixFlex</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.layout.FixFlex.
    "!
    "! @parameter ns             | (string) XML namespace prefix.
    "! @parameter class          | (string) CSS class names.
    "! @parameter fixcontentsize | (sap.ui.core.CSSSize) Size of the fix area. Default: auto.
    METHODS fix_flex
      IMPORTING
        ns             TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
        fixcontentsize TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `fixContent`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS fix_content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `flexContent`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS flex_content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.PaneContainer</p>
    "!
    "! @parameter resize      | (event) Fired when a pane is resized.
    "! @parameter orientation | (sap.ui.core.Orientation) Horizontal | Vertical. Default: Horizontal.
    METHODS pane_container
      IMPORTING
        resize        TYPE clike OPTIONAL
        orientation   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.SplitPane</p>
    "!
    "! @parameter requiredparentwidth | (int) Minimum parent width (in px) required to render this pane. Default: 800.
    METHODS split_pane
      IMPORTING
        id                  TYPE clike OPTIONAL
        requiredparentwidth TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.SplitterLayoutData</p>
    "!
    "! @parameter size      | (sap.ui.core.CSSSize) Initial size (e.g. `200px`, `30%` or `auto`). Default: auto.
    "! @parameter minsize   | (int) Minimum size in px. Default: 0.
    "! @parameter resizable | (boolean) Whether the pane is resizable. Default: true.
    METHODS splitter_layout_data
      IMPORTING
        size          TYPE clike OPTIONAL
        minsize       TYPE clike OPTIONAL
        resizable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ToolbarLayoutData</p>
    "!
    "! @parameter maxwidth   | (sap.ui.core.CSSSize) Maximum width.
    "! @parameter minwidth   | (sap.ui.core.CSSSize) Minimum width.
    "! @parameter shrinkable | (boolean) Allow the child to shrink. Default: false.
    METHODS toolbar_layout_data
      IMPORTING
        id            TYPE clike OPTIONAL
        maxwidth      TYPE clike OPTIONAL
        minwidth      TYPE clike OPTIONAL
        shrinkable    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectHeader</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectHeader.
    "!
    "! @parameter backgrounddesign     | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Transparent.
    "! @parameter condensed            | (boolean) Condensed rendering. Default: false.
    "! @parameter fullscreenoptimized  | (boolean) Optimised for full-screen layouts. Default: false.
    "! @parameter icon                 | (sap.ui.core.URI) Icon URI.
    "! @parameter iconactive           | (boolean) Render icon as clickable. Default: false.
    "! @parameter iconalt              | (string) Alt text for the icon.
    "! @parameter icondensityaware     | (boolean) Density-aware icon. Default: true.
    "! @parameter icontooltip          | (string) Icon tooltip.
    "! @parameter imageshape           | (sap.m.ObjectHeaderPictureShape) Square | Circle. Default: Square.
    "! @parameter intro                | (string) Intro text.
    "! @parameter introactive          | (boolean) Render intro as clickable. Default: false.
    "! @parameter introhref            | (string) Intro link href.
    "! @parameter introtarget          | (string) Intro link target.
    "! @parameter introtextdirection   | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter number               | (string) Numeric value.
    "! @parameter numberstate          | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter numbertextdirection  | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter numberunit           | (string) DEPRECATED - use `unit` aggregation slot.
    "! @parameter responsive           | (boolean) Use responsive layout. Default: false.
    "! @parameter showtitleselector    | (boolean) Show selector arrow next to title. Default: false.
    "! @parameter title                | (string) Title text.
    "! @parameter titleactive          | (boolean) Render title as clickable. Default: false.
    "! @parameter titlehref            | (string) Title link href.
    "! @parameter titlelevel           | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: H1.
    "! @parameter titleselectortooltip | (string) Tooltip for the title selector.
    "! @parameter titletarget          | (string) Title link target.
    "! @parameter titletextdirection   | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter iconpress            | (event) Fired when an active icon is pressed.
    "! @parameter intropress           | (event) Fired when an active intro is pressed.
    "! @parameter titlepress           | (event) Fired when an active title is pressed.
    "! @parameter titleselectorpress   | (event) Fired when the title selector arrow is pressed.
    METHODS object_header
      IMPORTING
        backgrounddesign     TYPE clike OPTIONAL
        condensed            TYPE clike OPTIONAL
        fullscreenoptimized  TYPE clike OPTIONAL
        icon                 TYPE clike OPTIONAL
        iconactive           TYPE clike OPTIONAL
        iconalt              TYPE clike OPTIONAL
        icondensityaware     TYPE clike OPTIONAL
        icontooltip          TYPE clike OPTIONAL
        imageshape           TYPE clike OPTIONAL
        intro                TYPE clike OPTIONAL
        introactive          TYPE clike OPTIONAL
        introhref            TYPE clike OPTIONAL
        introtarget          TYPE clike OPTIONAL
        introtextdirection   TYPE clike OPTIONAL
        number               TYPE clike OPTIONAL
        numberstate          TYPE clike OPTIONAL
        numbertextdirection  TYPE clike OPTIONAL
        numberunit           TYPE clike OPTIONAL
        responsive           TYPE clike OPTIONAL
        showtitleselector    TYPE clike OPTIONAL
        title                TYPE clike OPTIONAL
        titleactive          TYPE clike OPTIONAL
        titlehref            TYPE clike OPTIONAL
        titlelevel           TYPE clike OPTIONAL
        titleselectortooltip TYPE clike OPTIONAL
        titletarget          TYPE clike OPTIONAL
        titletextdirection   TYPE clike OPTIONAL
        iconpress            TYPE clike OPTIONAL
        intropress           TYPE clike OPTIONAL
        titlepress           TYPE clike OPTIONAL
        titleselectorpress   TYPE clike OPTIONAL
        class                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `additionalNumbers`</p>
    METHODS additional_numbers
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.HeaderContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.HeaderContainer.
    "!
    "! @parameter scrollstep  | (int) Pixels scrolled per arrow click.
    "! @parameter scrolltime  | (int) Scroll animation duration in ms. Default: 500.
    "! @parameter orientation | (sap.ui.core.Orientation) Horizontal | Vertical. Default: Horizontal.
    "! @parameter height      | (sap.ui.core.CSSSize) Height.
    METHODS header_container
      IMPORTING
        scrollstep    TYPE clike OPTIONAL
        scrolltime    TYPE clike OPTIONAL
        orientation   TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `markers`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS markers
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `statuses`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS statuses
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.statusindicator.PropertyThreshold</p>
    "!
    "! Generic status entry with custom colours. Used by sap.ndc / status indicator and similar.
    "!
    "! @parameter backgroundcolor             | (sap.ui.core.CSSColor) Background colour.
    "! @parameter bordercolor                 | (sap.ui.core.CSSColor) Border colour.
    "! @parameter borderstyle                 | (string) CSS border style.
    "! @parameter borderwidth                 | (string) CSS border width.
    "! @parameter contentcolor                | (sap.ui.core.CSSColor) Foreground colour.
    "! @parameter headercontentcolor          | (sap.ui.core.CSSColor) Header foreground colour.
    "! @parameter hoverbackgroundcolor        | (sap.ui.core.CSSColor) Background colour on hover.
    "! @parameter hoverbordercolor            | (sap.ui.core.CSSColor) Border colour on hover.
    "! @parameter hovercontentcolor           | (sap.ui.core.CSSColor) Foreground colour on hover.
    "! @parameter key                         | (string) Status key.
    "! @parameter legendcolor                 | (sap.ui.core.CSSColor) Legend colour.
    "! @parameter selectedbackgroundcolor     | (sap.ui.core.CSSColor) Background while selected.
    "! @parameter selectedbordercolor         | (sap.ui.core.CSSColor) Border while selected.
    "! @parameter selectedcontentcolor        | (sap.ui.core.CSSColor) Foreground while selected.
    "! @parameter title                       | (string) Status title.
    "! @parameter usefocuscolorascontentcolor | (boolean) Use focus colour as content colour. Default: false.
    "! @parameter visible                     | (boolean) Whether visible. Default: true.
    METHODS status
      IMPORTING
        id                          TYPE clike OPTIONAL
        class                       TYPE clike OPTIONAL
        backgroundcolor             TYPE clike OPTIONAL
        bordercolor                 TYPE clike OPTIONAL
        borderstyle                 TYPE clike OPTIONAL
        borderwidth                 TYPE clike OPTIONAL
        contentcolor                TYPE clike OPTIONAL
        headercontentcolor          TYPE clike OPTIONAL
        hoverbackgroundcolor        TYPE clike OPTIONAL
        hoverbordercolor            TYPE clike OPTIONAL
        hovercontentcolor           TYPE clike OPTIONAL
        key                         TYPE clike OPTIONAL
        legendcolor                 TYPE clike OPTIONAL
        selectedbackgroundcolor     TYPE clike OPTIONAL
        selectedbordercolor         TYPE clike OPTIONAL
        selectedcontentcolor        TYPE clike OPTIONAL
        title                       TYPE clike OPTIONAL
        usefocuscolorascontentcolor TYPE clike OPTIONAL
        visible                     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)               TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `firstStatus`</p>
    METHODS first_status
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `secondStatus`</p>
    METHODS second_status
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectMarker</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectMarker.
    "!
    "! @parameter additionalinfo | (string) Additional accessibility info.
    "! @parameter type           | (sap.m.ObjectMarkerType) Flagged | Favorite | Draft | Locked | LockedBy | Unsaved | UnsavedBy.
    "! @parameter visibility     | (sap.m.ObjectMarkerVisibility) IconAndText | IconOnly | TextOnly.
    "! @parameter visible        | (boolean) Whether visible. Default: true.
    "! @parameter press          | (event) Fired when the marker is pressed.
    METHODS object_marker
      IMPORTING
        additionalinfo TYPE clike OPTIONAL
        type           TYPE clike OPTIONAL
        visibility     TYPE clike OPTIONAL
        visible        TYPE clike OPTIONAL
        press          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ObjectListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ObjectListItem.
    "!
    "! @parameter activeicon          | (sap.ui.core.URI) Icon shown while pressed.
    "! @parameter icon                | (sap.ui.core.URI) Icon URI.
    "! @parameter icondensityaware    | (boolean) Density-aware icon. Default: true.
    "! @parameter intro               | (string) Intro text shown above the title.
    "! @parameter introtextdirection  | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter number              | (string) Numeric value shown on the right.
    "! @parameter numberstate         | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter numbertextdirection | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter numberunit          | (string) DEPRECATED - use `unit` aggregation slot.
    "! @parameter title               | (string) Title text.
    "! @parameter titletextdirection  | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter press               | (event, ListItemBase) Fired when the row is activated.
    "! @parameter selected            | (boolean, ListItemBase) Selected state. Default: false.
    "! @parameter type                | (sap.m.ListType, ListItemBase) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    METHODS object_list_item
      IMPORTING
        activeicon          TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
        icondensityaware    TYPE clike OPTIONAL
        intro               TYPE clike OPTIONAL
        introtextdirection  TYPE clike OPTIONAL
        number              TYPE clike OPTIONAL
        numberstate         TYPE clike OPTIONAL
        numbertextdirection TYPE clike OPTIONAL
        numberunit          TYPE clike OPTIONAL
        title               TYPE clike OPTIONAL
        titletextdirection  TYPE clike OPTIONAL
        press               TYPE clike OPTIONAL
        selected            TYPE clike OPTIONAL
        type                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `detailBox`</p>
    METHODS detail_box
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.LightBox</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.LightBox.
    "!
    "! @parameter visible | (boolean) Whether the lightbox is visible. Default: true.
    METHODS light_box
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.LightBoxItem</p>
    "!
    "! @parameter alt      | (string) Image alt text.
    "! @parameter imagesrc | (sap.ui.core.URI) Image URI.
    "! @parameter subtitle | (string) Subtitle text.
    "! @parameter title    | (string) Title text.
    METHODS light_box_item
      IMPORTING
        alt           TYPE clike OPTIONAL
        imagesrc      TYPE clike OPTIONAL
        subtitle      TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.LineMicroChart</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.microchart.LineMicroChart.
    "! Common micro-chart properties: `size` (sap.m.Size: S | M | L | Auto | Responsive), `hideOnNoData`, `press` event.
    "!
    "! @parameter color                 | (sap.m.ValueCSSColor) Default line colour: Good | Error | Critical | Neutral or CSS colour.
    "! @parameter leftbottomlabel       | (string) Bottom-left label.
    "! @parameter lefttoplabel          | (string) Top-left label.
    "! @parameter maxxvalue             | (float) Maximum X scale.
    "! @parameter minxvalue             | (float) Minimum X scale.
    "! @parameter minyvalue             | (float) Minimum Y scale.
    "! @parameter rightbottomlabel      | (string) Bottom-right label.
    "! @parameter righttoplabel         | (string) Top-right label.
    "! @parameter size                  | (sap.m.Size) S | M | L | Auto | Responsive. Default: Auto.
    "! @parameter threshold             | (float) Threshold value.
    "! @parameter thresholddisplayvalue | (string) Pre-formatted threshold text.
    "! @parameter width                 | (sap.ui.core.CSSSize) Width.
    "! @parameter height                | (sap.ui.core.CSSSize) Height.
    "! @parameter press                 | (event) Fired when the chart is pressed.
    "! @parameter hideonnodata          | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter showbottomlabels      | (boolean) Show bottom labels. Default: true.
    "! @parameter showpoints            | (sap.suite.ui.microchart.LineMicroChartEmphasizedPointsType | boolean) Show data points.
    "! @parameter showthresholdline     | (boolean) Render the threshold line. Default: true.
    "! @parameter showthresholdvalue    | (boolean) Render the threshold value text. Default: false.
    "! @parameter showtoplabels         | (boolean) Show top labels. Default: true.
    "! @parameter maxyvalue             | (float) Maximum Y scale.
    METHODS line_micro_chart
      IMPORTING
        color                 TYPE clike OPTIONAL
        height                TYPE clike OPTIONAL
        leftbottomlabel       TYPE clike OPTIONAL
        lefttoplabel          TYPE clike OPTIONAL
        maxxvalue             TYPE clike OPTIONAL
        minxvalue             TYPE clike OPTIONAL
        minyvalue             TYPE clike OPTIONAL
        rightbottomlabel      TYPE clike OPTIONAL
        righttoplabel         TYPE clike OPTIONAL
        size                  TYPE clike OPTIONAL
        threshold             TYPE clike OPTIONAL
        thresholddisplayvalue TYPE clike OPTIONAL
        width                 TYPE clike OPTIONAL
        press                 TYPE clike OPTIONAL
        hideonnodata          TYPE clike OPTIONAL
        showbottomlabels      TYPE clike OPTIONAL
        showpoints            TYPE clike OPTIONAL
        showthresholdline     TYPE clike OPTIONAL
        showthresholdvalue    TYPE clike OPTIONAL
        showtoplabels         TYPE clike OPTIONAL
        maxyvalue             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.LineMicroChartLine</p>
    "!
    "! @parameter points | (binding path) Aggregation of points.
    "! @parameter color  | (sap.m.ValueCSSColor) Line colour. Default: Neutral.
    "! @parameter type   | (sap.suite.ui.microchart.LineType) Solid | Dotted. Default: Solid.
    METHODS line_micro_chart_line
      IMPORTING
        points        TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.LineMicroChartPoint</p>
    "!
    "! @parameter x | (float) X value.
    "! @parameter y | (float) Y value.
    METHODS line_micro_chart_point
      IMPORTING
        x             TYPE clike OPTIONAL
        y             TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.LineMicroChartEmphasizedPoint</p>
    "!
    "! @parameter x     | (float) X value.
    "! @parameter y     | (float) Y value.
    "! @parameter color | (sap.m.ValueCSSColor) Point colour. Default: Neutral.
    "! @parameter show  | (boolean) Whether the emphasised marker is shown. Default: true.
    METHODS line_micro_chart_empszd_point
      IMPORTING
        x             TYPE clike OPTIONAL
        y             TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
        show          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.StackedBarMicroChart</p>
    "!
    "! @parameter height           | (sap.ui.core.CSSSize) Height.
    "! @parameter press            | (event) Fired when the chart is pressed.
    "! @parameter maxvalue         | (float) Maximum value (auto when undefined).
    "! @parameter precision        | (int) Number of digits for displayed values. Default: 1.
    "! @parameter size             | (sap.m.Size) S | M | L | Auto | Responsive. Default: Auto.
    "! @parameter hideonnodata     | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter displayzerovalue | (boolean) Display zero values. Default: true.
    "! @parameter showlabels       | (boolean) Show labels. Default: true.
    "! @parameter width            | (sap.ui.core.CSSSize) Width.
    METHODS stacked_bar_micro_chart
      IMPORTING
        height           TYPE clike OPTIONAL
        press            TYPE clike OPTIONAL
        maxvalue         TYPE clike OPTIONAL
        precision        TYPE clike OPTIONAL
        size             TYPE clike OPTIONAL
        hideonnodata     TYPE clike OPTIONAL
        displayzerovalue TYPE clike OPTIONAL
        showlabels       TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.ColumnMicroChart</p>
    "!
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter press             | (event) Fired when the chart is pressed.
    "! @parameter size              | (sap.m.Size) S | M | L | Auto | Responsive. Default: Auto.
    "! @parameter aligncontent      | (sap.m.microchart.HorizontalAlignmentType) Left | Center | Right. Default: Left.
    "! @parameter hideonnodata      | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter allowcolumnlabels | (boolean) Allow column labels. Default: false.
    "! @parameter showbottomlabels  | (boolean) Show bottom labels. Default: true.
    "! @parameter showtoplabels     | (boolean) Show top labels. Default: true.
    "! @parameter height            | (sap.ui.core.CSSSize) Height.
    METHODS column_micro_chart
      IMPORTING
        width             TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        size              TYPE clike OPTIONAL
        aligncontent      TYPE clike OPTIONAL
        hideonnodata      TYPE clike OPTIONAL
        allowcolumnlabels TYPE clike OPTIONAL
        showbottomlabels  TYPE clike OPTIONAL
        showtoplabels     TYPE clike OPTIONAL
        height            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.ColumnMicroChartData</p>
    "!
    "! @parameter value        | (float) Numeric value.
    "! @parameter label        | (string) Column label.
    "! @parameter displayvalue | (string) Pre-formatted value text.
    "! @parameter color        | (sap.m.ValueCSSColor) Column colour. Default: Neutral.
    "! @parameter press        | (event) Fired when the column is pressed.
    METHODS column_micro_chart_data
      IMPORTING
        value         TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        displayvalue  TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.ComparisonMicroChart</p>
    "!
    "! @parameter colorpalette | (string) CSS-colour list applied cyclically.
    "! @parameter press        | (event) Fired when the chart is pressed.
    "! @parameter size         | (sap.m.Size) S | M | L | Auto | Responsive. Default: Auto.
    "! @parameter height       | (sap.ui.core.CSSSize) Height.
    "! @parameter maxvalue     | (float) Maximum value (auto when undefined).
    "! @parameter minvalue     | (float) Minimum value (auto when undefined).
    "! @parameter scale        | (string) Scaling text shown next to the value.
    "! @parameter width        | (sap.ui.core.CSSSize) Width.
    "! @parameter hideonnodata | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter shrinkable   | (boolean) Allow chart to shrink. Default: false.
    "! @parameter visible      | (boolean) Whether the chart is visible. Default: true.
    "! @parameter view         | (sap.suite.ui.microchart.ComparisonMicroChartViewType) Normal | Wide. Default: Normal.
    METHODS comparison_micro_chart
      IMPORTING
        colorpalette  TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        size          TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        maxvalue      TYPE clike OPTIONAL
        minvalue      TYPE clike OPTIONAL
        scale         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        hideonnodata  TYPE clike OPTIONAL
        shrinkable    TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        view          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.ComparisonMicroChartData</p>
    "!
    "! @parameter color        | (sap.m.ValueCSSColor) Bar colour. Default: Neutral.
    "! @parameter press        | (event) Fired when the row is pressed.
    "! @parameter displayvalue | (string) Pre-formatted value text.
    "! @parameter title        | (string) Row title.
    "! @parameter value        | (float) Numeric value.
    METHODS comparison_micro_chart_data
      IMPORTING
        color         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        displayvalue  TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.DeltaMicroChart</p>
    "!
    "! @parameter color             | (sap.m.ValueCSSColor) Delta colour. Default: Neutral.
    "! @parameter press             | (event) Fired when the chart is pressed.
    "! @parameter size              | (sap.m.Size) Default: Auto.
    "! @parameter height            | (sap.ui.core.CSSSize) Height.
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter deltadisplayvalue | (string) Pre-formatted delta text.
    "! @parameter displayvalue1     | (string) Pre-formatted value 1 text.
    "! @parameter displayvalue2     | (string) Pre-formatted value 2 text.
    "! @parameter title2            | (string) Title for value 2.
    "! @parameter value1            | (float) First value.
    "! @parameter value2            | (float) Second value.
    "! @parameter view              | (sap.suite.ui.microchart.DeltaMicroChartViewType) Normal | Wide. Default: Normal.
    "! @parameter hideonnodata      | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter title1            | (string) Title for value 1.
    METHODS delta_micro_chart
      IMPORTING
        color             TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        size              TYPE clike OPTIONAL
        height            TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        deltadisplayvalue TYPE clike OPTIONAL
        displayvalue1     TYPE clike OPTIONAL
        displayvalue2     TYPE clike OPTIONAL
        title2            TYPE clike OPTIONAL
        value1            TYPE clike OPTIONAL
        value2            TYPE clike OPTIONAL
        view              TYPE clike OPTIONAL
        hideonnodata      TYPE clike OPTIONAL
        title1            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.BulletMicroChart</p>
    "!
    "! @parameter actualvaluelabel  | (string) Pre-formatted actual value text.
    "! @parameter press             | (event) Fired when the chart is pressed.
    "! @parameter size              | (sap.m.Size) Default: Auto.
    "! @parameter height            | (sap.ui.core.CSSSize) Height.
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter deltavaluelabel   | (string) Pre-formatted delta text.
    "! @parameter maxvalue          | (float) Maximum scale value.
    "! @parameter minvalue          | (float) Minimum scale value.
    "! @parameter mode              | (sap.suite.ui.microchart.BulletMicroChartModeType) Actual | Delta. Default: Actual.
    "! @parameter scale             | (string) Scale text shown next to the value.
    "! @parameter targetvalue       | (float) Target value.
    "! @parameter targetvaluelabel  | (string) Pre-formatted target value text.
    "! @parameter scalecolor        | (sap.suite.ui.microchart.CommonBackgroundType) Default | Light | LightDark | Dark | DarkDark. Default: Default.
    "! @parameter hideonnodata      | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter showactualvalue   | (boolean) Show the actual value bar. Default: true.
    "! @parameter showdeltavalue    | (boolean) Show the delta value bar. Default: true.
    "! @parameter showtargetvalue   | (boolean) Show the target value indicator. Default: true.
    "! @parameter showthresholds    | (boolean) Show threshold lines. Default: true.
    "! @parameter showvaluemarker   | (boolean) Show value markers. Default: false.
    "! @parameter smallrangeallowed | (boolean) Allow small ranges. Default: false.
    "! @parameter forecastvalue     | (float) Forecast value (rendered semi-transparent).
    "! @parameter savidm            | (string) Custom internal id (rarely used).
    METHODS bullet_micro_chart
      IMPORTING
        actualvaluelabel  TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        size              TYPE clike OPTIONAL
        height            TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        deltavaluelabel   TYPE clike OPTIONAL
        maxvalue          TYPE clike OPTIONAL
        minvalue          TYPE clike OPTIONAL
        mode              TYPE clike OPTIONAL
        scale             TYPE clike OPTIONAL
        targetvalue       TYPE clike OPTIONAL
        targetvaluelabel  TYPE clike OPTIONAL
        scalecolor        TYPE clike OPTIONAL
        hideonnodata      TYPE clike OPTIONAL
        showactualvalue   TYPE clike OPTIONAL
        showdeltavalue    TYPE clike OPTIONAL
        showtargetvalue   TYPE clike OPTIONAL
        showthresholds    TYPE clike OPTIONAL
        showvaluemarker   TYPE clike OPTIONAL
        smallrangeallowed TYPE clike OPTIONAL
        forecastvalue     TYPE clike OPTIONAL
        savidm            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.HarveyBallMicroChart</p>
    "!
    "! @parameter colorpalette   | (string) CSS-colour list applied cyclically.
    "! @parameter press          | (event) Fired when the chart is pressed.
    "! @parameter size           | (sap.m.Size) Default: Auto.
    "! @parameter height         | (sap.ui.core.CSSSize) Height.
    "! @parameter width          | (sap.ui.core.CSSSize) Width.
    "! @parameter total          | (float) Total value (denominator).
    "! @parameter totallabel     | (string) Pre-formatted total text.
    "! @parameter aligncontent   | (sap.m.microchart.HorizontalAlignmentType) Left | Center | Right. Default: Left.
    "! @parameter hideonnodata   | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter formattedlabel | (boolean) Render label as formatted text. Default: false.
    "! @parameter showfractions  | (boolean) Show fraction values. Default: true.
    "! @parameter showtotal      | (boolean) Show total. Default: true.
    "! @parameter totalscale     | (string) Scale text for the total.
    METHODS harvey_ball_micro_chart
      IMPORTING
        colorpalette   TYPE clike OPTIONAL
        press          TYPE clike OPTIONAL
        size           TYPE clike OPTIONAL
        height         TYPE clike OPTIONAL
        width          TYPE clike OPTIONAL
        total          TYPE clike OPTIONAL
        totallabel     TYPE clike OPTIONAL
        aligncontent   TYPE clike OPTIONAL
        hideonnodata   TYPE clike OPTIONAL
        formattedlabel TYPE clike OPTIONAL
        showfractions  TYPE clike OPTIONAL
        showtotal      TYPE clike OPTIONAL
        totalscale     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.microchart.AreaMicroChart</p>
    "!
    "! @parameter colorpalette | (string) CSS-colour list applied cyclically.
    "! @parameter press        | (event) Fired when the chart is pressed.
    "! @parameter size         | (sap.m.Size) Default: Auto.
    "! @parameter height       | (sap.ui.core.CSSSize) Height.
    "! @parameter maxxvalue    | (float) Maximum X scale.
    "! @parameter maxyvalue    | (float) Maximum Y scale.
    "! @parameter minxvalue    | (float) Minimum X scale.
    "! @parameter minyvalue    | (float) Minimum Y scale.
    "! @parameter view         | (sap.suite.ui.microchart.AreaMicroChartViewType) Normal | Wide. Default: Normal.
    "! @parameter aligncontent | (sap.m.microchart.HorizontalAlignmentType) Left | Center | Right. Default: Left.
    "! @parameter hideonnodata | (boolean) Hide chart when there is no data. Default: false.
    "! @parameter showlabel    | (boolean) Show labels. Default: true.
    "! @parameter width        | (sap.ui.core.CSSSize) Width.
    METHODS area_micro_chart
      IMPORTING
        colorpalette  TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        size          TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        maxxvalue     TYPE clike OPTIONAL
        maxyvalue     TYPE clike OPTIONAL
        minxvalue     TYPE clike OPTIONAL
        minyvalue     TYPE clike OPTIONAL
        view          TYPE clike OPTIONAL
        aligncontent  TYPE clike OPTIONAL
        hideonnodata  TYPE clike OPTIONAL
        showlabel     TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `data`</p>
    METHODS data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.richtexteditor.RichTextEditor</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.richtexteditor.RichTextEditor.
    "!
    "! @parameter buttongroups       | (object[]) Custom toolbar button groups.
    "! @parameter customtoolbar      | (boolean) Whether to render a custom toolbar. Default: false.
    "! @parameter editable           | (boolean) Whether the content is editable. Default: true.
    "! @parameter editortype         | (sap.ui.richtexteditor.EditorType) TinyMCE | TinyMCE6. Default: TinyMCE6.
    "! @parameter height             | (sap.ui.core.CSSSize) Editor height.
    "! @parameter plugins            | (object[]) TinyMCE plugin configuration.
    "! @parameter required           | (boolean) Required field marker. Default: false.
    "! @parameter sanitizevalue      | (boolean) Sanitize the value via URLListValidator. Default: false.
    "! @parameter showgroupclipboard | (boolean) Show clipboard button group. Default: true.
    "! @parameter showgroupfont      | (boolean) Show font button group. Default: false.
    "! @parameter showgroupfontstyle | (boolean) Show font-style button group. Default: true.
    "! @parameter showgroupinsert    | (boolean) Show insert button group. Default: false.
    "! @parameter showgrouplink      | (boolean) Show link button group. Default: true.
    "! @parameter showgroupstructure | (boolean) Show structure button group. Default: true.
    "! @parameter showgrouptextalign | (boolean) Show text-align button group. Default: true.
    "! @parameter showgroupundo      | (boolean) Show undo/redo group. Default: false.
    "! @parameter textdirection      | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter uselegacytheme     | (boolean) Use the legacy theme. Default: true.
    "! @parameter value              | (string) Two-way bound HTML content.
    "! @parameter width              | (sap.ui.core.CSSSize) Editor width.
    "! @parameter wrapping           | (boolean) Wrap text. Default: true.
    "! @parameter beforeeditorinit   | (event) Fired before TinyMCE is initialised.
    "! @parameter change             | (event) Fired when the value changes.
    "! @parameter ready              | (event) Fired when the editor is ready.
    "! @parameter readyrecurring     | (event) Fired on every re-initialisation.
    METHODS rich_text_editor
      IMPORTING
        buttongroups       TYPE clike OPTIONAL
        customtoolbar      TYPE clike OPTIONAL
        editable           TYPE clike OPTIONAL
        editortype         TYPE clike OPTIONAL
        height             TYPE clike OPTIONAL
        plugins            TYPE clike OPTIONAL
        required           TYPE clike OPTIONAL
        sanitizevalue      TYPE clike OPTIONAL
        showgroupclipboard TYPE clike OPTIONAL
        showgroupfont      TYPE clike OPTIONAL
        showgroupfontstyle TYPE clike OPTIONAL
        showgroupinsert    TYPE clike OPTIONAL
        showgrouplink      TYPE clike OPTIONAL
        showgroupstructure TYPE clike OPTIONAL
        showgrouptextalign TYPE clike OPTIONAL
        showgroupundo      TYPE clike OPTIONAL
        textdirection      TYPE clike OPTIONAL
        uselegacytheme     TYPE clike OPTIONAL
        value              TYPE clike OPTIONAL
        width              TYPE clike OPTIONAL
        wrapping           TYPE clike OPTIONAL
        beforeeditorinit   TYPE clike OPTIONAL
        change             TYPE clike OPTIONAL
        ready              TYPE clike OPTIONAL
        readyrecurring     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Slider</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Slider.
    "!
    "! @parameter max                 | (float) Maximum value. Default: 100.
    "! @parameter min                 | (float) Minimum value. Default: 0.
    "! @parameter step                | (float) Step size. Default: 1.
    "! @parameter value               | (float) Two-way bound value.
    "! @parameter enabletickmarks     | (boolean) Show tick marks. Default: false.
    "! @parameter width               | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter class               | (string) CSS class names.
    "! @parameter enabled             | (boolean) Whether enabled. Default: true.
    "! @parameter change              | (event) Fired when the value is committed.
    "! @parameter inputsastooltips    | (boolean) Render the tooltip as a numeric input. Default: false.
    "! @parameter showadvancedtooltip | (boolean) Use advanced tooltip rendering. Default: false.
    "! @parameter showhandletooltip   | (boolean) Show handle tooltip. Default: true.
    "! @parameter livechange          | (event) Fired during dragging.
    METHODS slider
      IMPORTING
        max                 TYPE clike OPTIONAL
        min                 TYPE clike OPTIONAL
        step                TYPE clike OPTIONAL
        value               TYPE clike OPTIONAL
        enabletickmarks     TYPE clike OPTIONAL
        width               TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        id                  TYPE clike OPTIONAL
        enabled             TYPE clike OPTIONAL
        change              TYPE clike OPTIONAL
        inputsastooltips    TYPE clike OPTIONAL
        showadvancedtooltip TYPE clike OPTIONAL
        showhandletooltip   TYPE clike OPTIONAL
        livechange          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.upload.UploadSet</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.upload.UploadSet.
    "!
    "! @parameter instantupload          | (boolean) Upload as soon as a file is selected. Default: true.
    "! @parameter showicons              | (boolean) Show file-type icons. Default: true.
    "! @parameter uploadenabled          | (boolean) Whether file selection / upload is enabled. Default: true.
    "! @parameter terminationenabled     | (boolean) Allow terminating uploads in progress. Default: true.
    "! @parameter filetypes              | (string[]) Allowed file extensions.
    "! @parameter maxfilenamelength      | (int) Max filename length. Default: 0 = unlimited.
    "! @parameter maxfilesize            | (float) Max file size in MB. Default: 0 = unlimited.
    "! @parameter mediatypes             | (string[]) Allowed MIME types.
    "! @parameter uploadurl              | (sap.ui.core.URI) Upload target URL.
    "! @parameter items                  | (binding path) Aggregation of `UploadSetItem`.
    "! @parameter mode                   | (sap.m.ListMode) None | SingleSelectMaster | SingleSelectLeft | MultiSelect | Delete. Default: MultiSelect.
    "! @parameter selectionchanged       | (event) Fired when item selection changes.
    "! @parameter uploadcompleted        | (event) Fired when an upload completes.
    "! @parameter afteritemadded         | (event) Fired after an item is added.
    "! @parameter samefilenameallowed    | (boolean) Allow uploading files with the same name. Default: false.
    "! @parameter uploadbuttoninvisible  | (boolean) Hide the upload button. Default: false.
    "! @parameter directory              | (boolean) Allow uploading entire directories. Default: false.
    "! @parameter multiple               | (boolean) Allow selecting multiple files. Default: false.
    "! @parameter dragdropdescription    | (string) Drag-and-drop area description.
    "! @parameter dragdroptext           | (string) Drag-and-drop area text.
    "! @parameter nodatatext             | (string) Empty-state text.
    "! @parameter nodatadescription      | (string) Empty-state description.
    "! @parameter nodataillustrationtype | (sap.m.IllustratedMessageType) Empty-state illustration. Default: NoData.
    "! @parameter afteritemedited        | (event) Fired after an item is renamed.
    "! @parameter afteritemremoved       | (event) Fired after an item is removed.
    "! @parameter beforeitemadded        | (event) Fired before an item is added.
    "! @parameter beforeitemedited       | (event) Fired before an item is edited.
    "! @parameter beforeitemremoved      | (event) Fired before an item is removed.
    "! @parameter beforeuploadstarts     | (event) Fired before the upload starts.
    "! @parameter beforeuploadtermination | (event) Fired before an upload is terminated.
    "! @parameter filenamelengthexceeded | (event) Fired when the filename length exceeds the limit.
    "! @parameter filerenamed            | (event) Fired when a file is renamed.
    "! @parameter filesizeexceeded       | (event) Fired when the file size exceeds the limit.
    "! @parameter filetypemismatch       | (event) Fired when the file type is not allowed.
    "! @parameter itemdragstart          | (event) Fired when item dragging starts.
    "! @parameter itemdrop               | (event) Fired when an item is dropped.
    "! @parameter mediatypemismatch      | (event) Fired when the media type is not allowed.
    "! @parameter uploadterminated       | (event) Fired when an upload is terminated.
    METHODS upload_set
      IMPORTING
        id                      TYPE clike OPTIONAL
        instantupload           TYPE clike OPTIONAL
        showicons               TYPE clike OPTIONAL
        uploadenabled           TYPE clike OPTIONAL
        terminationenabled      TYPE clike OPTIONAL
        filetypes               TYPE clike OPTIONAL
        maxfilenamelength       TYPE clike OPTIONAL
        maxfilesize             TYPE clike OPTIONAL
        mediatypes              TYPE clike OPTIONAL
        uploadurl               TYPE clike OPTIONAL
        items                   TYPE clike OPTIONAL
        mode                    TYPE clike OPTIONAL
        selectionchanged        TYPE clike OPTIONAL
        uploadcompleted         TYPE clike OPTIONAL
        afteritemadded          TYPE clike OPTIONAL
        samefilenameallowed     TYPE clike OPTIONAL
        uploadbuttoninvisible   TYPE clike OPTIONAL
        directory               TYPE clike OPTIONAL
        multiple                TYPE clike OPTIONAL
        dragdropdescription     TYPE clike OPTIONAL
        dragdroptext            TYPE clike OPTIONAL
        nodatatext              TYPE clike OPTIONAL
        nodatadescription       TYPE clike OPTIONAL
        nodataillustrationtype  TYPE clike OPTIONAL
        afteritemedited         TYPE clike OPTIONAL
        afteritemremoved        TYPE clike OPTIONAL
        beforeitemadded         TYPE clike OPTIONAL
        beforeitemedited        TYPE clike OPTIONAL
        beforeitemremoved       TYPE clike OPTIONAL
        beforeuploadstarts      TYPE clike OPTIONAL
        beforeuploadtermination TYPE clike OPTIONAL
        filenamelengthexceeded  TYPE clike OPTIONAL
        filerenamed             TYPE clike OPTIONAL
        filesizeexceeded        TYPE clike OPTIONAL
        filetypemismatch        TYPE clike OPTIONAL
        itemdragstart           TYPE clike OPTIONAL
        itemdrop                TYPE clike OPTIONAL
        mediatypemismatch       TYPE clike OPTIONAL
        uploadterminated        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.upload.UploadSetToolbarPlaceholder</p>
    METHODS upload_set_toolbar_placeholder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.upload.UploadSetItem</p>
    "!
    "! @parameter filename      | (string) File name.
    "! @parameter mediatype     | (string) MIME type.
    "! @parameter url           | (sap.ui.core.URI) URL of the uploaded file.
    "! @parameter thumbnailurl  | (sap.ui.core.URI) Thumbnail URL.
    "! @parameter markers       | (binding path) Aggregation of `ObjectMarker`.
    "! @parameter statuses      | (binding path) Aggregation of `ObjectStatus`.
    "! @parameter enablededit   | (boolean) Allow renaming. Default: true.
    "! @parameter enabledremove | (boolean) Allow removal. Default: true.
    "! @parameter selected      | (boolean) Selected state. Default: false.
    "! @parameter visibleedit   | (boolean) Show the edit button. Default: true.
    "! @parameter visibleremove | (boolean) Show the remove button. Default: true.
    "! @parameter uploadstate   | (sap.m.UploadState) Ready | Uploading | Error | Complete.
    "! @parameter uploadurl     | (sap.ui.core.URI) Upload URL override.
    "! @parameter openpressed   | (event) Fired when the open button is pressed.
    "! @parameter removepressed | (event) Fired when the remove button is pressed.
    METHODS upload_set_item
      IMPORTING
        filename      TYPE clike OPTIONAL
        mediatype     TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
        thumbnailurl  TYPE clike OPTIONAL
        markers       TYPE clike OPTIONAL
        statuses      TYPE clike OPTIONAL
        enablededit   TYPE clike OPTIONAL
        enabledremove TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        visibleedit   TYPE clike OPTIONAL
        visibleremove TYPE clike OPTIONAL
        uploadstate   TYPE clike OPTIONAL
        uploadurl     TYPE clike OPTIONAL
        openpressed   TYPE clike OPTIONAL
        removepressed TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `markersAsStatus`</p>
    METHODS markers_as_status
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `rules`</p>
    METHODS rules
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.MaskInputRule</p>
    "!
    "! @parameter maskformatsymbol | (string) Mask symbol the rule applies to. Default: `*`.
    "! @parameter regex            | (string) Regular expression for the rule. Default: `[a-zA-Z0-9]`.
    METHODS mask_input_rule
      IMPORTING
        maskformatsymbol TYPE clike OPTIONAL
        regex            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.SidePanel</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.SidePanel.
    "!
    "! @parameter actionbarexpanded         | (boolean) Initial action bar state. Default: false.
    "! @parameter arialabel                 | (string) ARIA label.
    "! @parameter sidepanelmaxwidth         | (sap.ui.core.CSSSize) Maximum side panel width. Default: 600px.
    "! @parameter sidepanelminwidth         | (sap.ui.core.CSSSize) Minimum side panel width. Default: 320px.
    "! @parameter sidepanelposition         | (sap.f.SidePanelPosition) Left | Right. Default: Right.
    "! @parameter sidepanelresizable        | (boolean) Allow resizing. Default: false.
    "! @parameter sidepanelresizelargerstep | (int) Larger resize step (Page Up/Down) in px. Default: 50.
    "! @parameter sidepanelresizestep       | (int) Resize step in px. Default: 10.
    "! @parameter sidepanelwidth            | (sap.ui.core.CSSSize) Initial side panel width. Default: 320px.
    "! @parameter toggle                    | (event) Fired when the side panel is toggled.
    METHODS side_panel
      IMPORTING
        actionbarexpanded         TYPE clike OPTIONAL
        arialabel                 TYPE clike OPTIONAL
        sidepanelmaxwidth         TYPE clike OPTIONAL
        sidepanelminwidth         TYPE clike OPTIONAL
        sidepanelposition         TYPE clike OPTIONAL
        sidepanelresizable        TYPE clike OPTIONAL
        sidepanelresizelargerstep TYPE clike OPTIONAL
        sidepanelresizestep       TYPE clike OPTIONAL
        sidepanelwidth            TYPE clike OPTIONAL
        toggle                    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.SidePanelItem</p>
    "!
    "! @parameter icon    | (sap.ui.core.URI) Action icon.
    "! @parameter text    | (string) Action text.
    "! @parameter key     | (string) Item key.
    "! @parameter enabled | (boolean) Whether enabled. Default: true.
    METHODS side_panel_item
      IMPORTING
        icon          TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `mainContent`</p>
    METHODS main_content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.QuickView</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.QuickView.
    "!
    "! @parameter placement   | (sap.m.PlacementType) Auto | Top | Bottom | Left | Right (etc.). Default: Right.
    "! @parameter width       | (sap.ui.core.CSSSize) Popover width. Default: 320px.
    "! @parameter afterclose  | (event) Fired after the popover closes.
    "! @parameter afteropen   | (event) Fired after the popover opens.
    "! @parameter beforeclose | (event) Fired before the popover closes.
    "! @parameter beforeopen  | (event) Fired before the popover opens.
    METHODS quick_view
      IMPORTING
        placement     TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        afterclose    TYPE clike OPTIONAL
        afteropen     TYPE clike OPTIONAL
        beforeclose   TYPE clike OPTIONAL
        beforeopen    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.QuickViewPage</p>
    "!
    "! @parameter description | (string) Subtitle/description.
    "! @parameter header      | (string) Header text.
    "! @parameter pageid      | (string) Unique page id used for navigation.
    "! @parameter title       | (string) Title text.
    "! @parameter titleurl    | (sap.ui.core.URI) Title link URL.
    METHODS quick_view_page
      IMPORTING
        description   TYPE clike OPTIONAL
        header        TYPE clike OPTIONAL
        pageid        TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        titleurl      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `avatar`</p>
    METHODS quick_view_page_avatar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.QuickViewGroup</p>
    "!
    "! @parameter heading | (string) Group heading.
    "! @parameter visible | (boolean) Whether the group is visible. Default: true.
    METHODS quick_view_group
      IMPORTING
        heading       TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.QuickViewGroupElement</p>
    "!
    "! @parameter emailsubject | (string) Subject for `mailto:` links.
    "! @parameter label        | (string) Label text.
    "! @parameter pagelinkid   | (string) Target page id within the QuickView (when type=pageLink).
    "! @parameter target       | (string) Link target attribute.
    "! @parameter type         | (sap.m.QuickViewGroupElementType) text | email | phone | mobile | link | pageLink. Default: text.
    "! @parameter url          | (string) URL for link types.
    "! @parameter value        | (string) Value text.
    "! @parameter visible      | (boolean) Whether visible. Default: true.
    METHODS quick_view_group_element
      IMPORTING
        emailsubject  TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        pagelinkid    TYPE clike OPTIONAL
        target        TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.DateRangeSelection</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.DateRangeSelection. All DatePicker properties apply.
    "!
    "! @parameter value                   | (string) Two-way bound formatted value.
    "! @parameter delimiter               | (string) Range delimiter. Default: ` - `.
    "! @parameter datevalue               | (object) Range start date.
    "! @parameter seconddatevalue         | (object) Range end date.
    "! @parameter mindate                 | (object) Minimum selectable date.
    "! @parameter maxdate                 | (object) Maximum selectable date.
    "! @parameter calendarweeknumbering   | (sap.ui.core.date.CalendarWeekNumbering) Default | ISO_8601 | MiddleEastern | WesternTraditional. Default: Default.
    "! @parameter displayformat           | (string) Display format pattern.
    "! @parameter valueformat             | (string) Internal `value` format.
    "! @parameter displayformattype       | (string) Calendar type for the display format.
    "! @parameter enabled                 | (boolean) Whether enabled. Default: true.
    "! @parameter editable                | (boolean) Whether editable. Default: true.
    "! @parameter required                | (boolean) Required field marker. Default: false.
    "! @parameter visible                 | (boolean) Whether visible. Default: true.
    "! @parameter width                   | (sap.ui.core.CSSSize) Width.
    "! @parameter showcurrentdatebutton   | (boolean) Show "Today" button. Default: false.
    "! @parameter showfooter              | (boolean) Show calendar footer. Default: false.
    "! @parameter hideinput               | (boolean) Hide the input field. Default: false.
    "! @parameter placeholder             | (string) Placeholder text.
    "! @parameter valuestate              | (sap.ui.core.ValueState) None | Success | Warning | Error | Information.
    "! @parameter valuestatetext          | (string) Value state message.
    "! @parameter showvaluestatemessage   | (boolean) Show value state message. Default: true.
    "! @parameter textdirection           | (sap.ui.core.TextDirection) Inherit | LTR | RTL.
    "! @parameter textalign               | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial.
    "! @parameter name                    | (string) HTML form name.
    "! @parameter initialfocuseddatevalue | (object) Date initially focused.
    "! @parameter class                   | (string) CSS class names.
    "! @parameter change                  | (event) Fired when the range is committed.
    METHODS date_range_selection
      IMPORTING
        value                   TYPE clike OPTIONAL
        placeholder             TYPE clike OPTIONAL
        displayformat           TYPE clike OPTIONAL
        valueformat             TYPE clike OPTIONAL
        required                TYPE clike OPTIONAL
        valuestate              TYPE clike OPTIONAL
        valuestatetext          TYPE clike OPTIONAL
        enabled                 TYPE clike OPTIONAL
        showcurrentdatebutton   TYPE clike OPTIONAL
        change                  TYPE clike OPTIONAL
        hideinput               TYPE clike OPTIONAL
        showfooter              TYPE clike OPTIONAL
        visible                 TYPE clike OPTIONAL
        showvaluestatemessage   TYPE clike OPTIONAL
        mindate                 TYPE clike OPTIONAL
        maxdate                 TYPE clike OPTIONAL
        editable                TYPE clike OPTIONAL
        width                   TYPE clike OPTIONAL
        id                      TYPE clike OPTIONAL
        calendarweeknumbering   TYPE clike OPTIONAL
        displayformattype       TYPE clike OPTIONAL
        class                   TYPE clike OPTIONAL
        textdirection           TYPE clike OPTIONAL
        textalign               TYPE clike OPTIONAL
        name                    TYPE clike OPTIONAL
        datevalue               TYPE clike OPTIONAL
        seconddatevalue         TYPE clike OPTIONAL
        initialfocuseddatevalue TYPE clike OPTIONAL
        delimiter               TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.fl.variants.VariantManagement</p>
    "!
    "! Variant management provided by SAPUI5 flexibility services. See https://ui5.sap.com/#/api/sap.ui.fl.variants.VariantManagement.
    "!
    "! @parameter displaytextfsv                | (string) Custom standard variant text.
    "! @parameter editable                      | (boolean) Whether the control is editable. Default: true.
    "! @parameter executeonselectionforstandflt | (boolean) Apply automatically also for the standard variant. Default: false.
    "! @parameter headerlevel                   | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter inerrorstate                  | (boolean) Render in error state. Default: false.
    "! @parameter maxwidth                      | (sap.ui.core.CSSSize) Maximum width.
    "! @parameter modelname                     | (string) Custom flex model name. Default: $FlexVariants.
    "! @parameter resetoncontextchange          | (boolean) Reset on context change. Default: true.
    "! @parameter showsetasdefault              | (boolean) Show set-as-default option. Default: true.
    "! @parameter titlestyle                    | (sap.ui.core.TitleLevel) Style for the title.
    "! @parameter updatevariantinurl            | (boolean) Update URL when variant changes. Default: false.
    "! @parameter for                           | (sap.ui.core.ID[]) Ids of the controls under variant management.
    "! @parameter cancel                        | (event) Fired when management dialog is cancelled.
    "! @parameter initialized                   | (event) Fired when initialised.
    "! @parameter manage                        | (event) Fired on manage.
    "! @parameter save                          | (event) Fired on save.
    "! @parameter select                        | (event) Fired on select.
    METHODS variant_management_fl
      IMPORTING
        displaytextfsv                TYPE clike OPTIONAL
        editable                      TYPE clike OPTIONAL
        executeonselectionforstandflt TYPE clike OPTIONAL
        headerlevel                   TYPE clike OPTIONAL
        inerrorstate                  TYPE clike OPTIONAL
        maxwidth                      TYPE clike OPTIONAL
        modelname                     TYPE clike OPTIONAL
        resetoncontextchange          TYPE clike OPTIONAL
        showsetasdefault              TYPE clike OPTIONAL
        titlestyle                    TYPE clike OPTIONAL
        updatevariantinurl            TYPE clike OPTIONAL
        for                           TYPE clike OPTIONAL
        cancel                        TYPE clike OPTIONAL
        initialized                   TYPE clike OPTIONAL
        manage                        TYPE clike OPTIONAL
        save                          TYPE clike OPTIONAL
        select                        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.layout.form.ColumnElementData</p>
    "!
    "! @parameter cellslarge | (int) Cell span on large screens (1..12). Default: 8.
    "! @parameter cellssmall | (int) Cell span on small screens (1..12). Default: 12.
    METHODS column_element_data
      IMPORTING
        cellslarge    TYPE clike OPTIONAL
        cellssmall    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `customControl`</p>
    METHODS fb_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.smartvariants.SmartVariantManagement</p>
    "!
    "! Variant management for smart controls. See https://ui5.sap.com/#/api/sap.ui.comp.smartvariants.SmartVariantManagement.
    "!
    "! @parameter showexecuteonselection | (boolean) Show "Apply Automatically" option. Default: false.
    "! @parameter persistencykey         | (string) Key under which variants are persisted.
    METHODS smart_variant_management
      IMPORTING
        id                     TYPE clike OPTIONAL
        showexecuteonselection TYPE clike OPTIONAL
        persistencykey         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.smartfilterbar.SmartFilterBar</p>
    "!
    "! Smart filter bar with auto-generated controls based on OData metadata.
    "! See https://ui5.sap.com/#/api/sap.ui.comp.smartfilterbar.SmartFilterBar.
    "!
    "! @parameter persistencykey | (string) Key for storing user variants.
    "! @parameter entityset      | (string) OData entity set.
    METHODS smart_filter_bar
      IMPORTING
        id             TYPE clike OPTIONAL
        persistencykey TYPE clike OPTIONAL
        entityset      TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.smartfilterbar.ControlConfiguration</p>
    "!
    "! Per-field configuration for SmartFilterBar. See https://ui5.sap.com/#/api/sap.ui.comp.smartfilterbar.ControlConfiguration.
    "!
    "! @parameter previnitdatafetchinvalhelpdia | (boolean) Prevent initial data fetch in value-help dialog. Default: false.
    "! @parameter visibleinadvancedarea         | (boolean) Show in the advanced area. Default: false.
    "! @parameter key                           | (string) Property name the configuration applies to.
    METHODS control_configuration
      IMPORTING
        id                            TYPE clike OPTIONAL
        previnitdatafetchinvalhelpdia TYPE clike OPTIONAL
        visibleinadvancedarea         TYPE clike OPTIONAL
        key                           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `controlConfiguration`</p>
    METHODS _control_configuration
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.smarttable.SmartTable</p>
    "!
    "! Smart table that auto-creates columns from OData metadata. See https://ui5.sap.com/#/api/sap.ui.comp.smarttable.SmartTable.
    "!
    "! @parameter smartfilterid           | (sap.ui.core.ID) Id of an associated SmartFilterBar.
    "! @parameter tabletype               | (sap.ui.comp.smarttable.TableType) ResponsiveTable | Table | TreeTable | AnalyticalTable. Default: ResponsiveTable.
    "! @parameter editable                | (boolean) Whether cells are editable. Default: false.
    "! @parameter initiallyvisiblefields  | (string) Comma-separated list of initially visible field names.
    "! @parameter entityset               | (string) OData entity set.
    "! @parameter usevariantmanagement    | (boolean) Show variant management toolbar. Default: true.
    "! @parameter useexporttoexcel        | (boolean) Show "Export to Excel" button. Default: true.
    "! @parameter usetablepersonalisation | (boolean) Show personalisation button. Default: true.
    "! @parameter header                  | (string) Header text.
    "! @parameter showrowcount            | (boolean) Show row count in header. Default: true.
    "! @parameter enableexport            | (boolean) Enable export button. Default: true.
    "! @parameter enableautobinding       | (boolean) Bind table automatically. Default: false.
    METHODS smart_table
      IMPORTING
        id                      TYPE clike OPTIONAL
        smartfilterid           TYPE clike OPTIONAL
        tabletype               TYPE clike OPTIONAL
        editable                TYPE clike OPTIONAL
        initiallyvisiblefields  TYPE clike OPTIONAL
        entityset               TYPE clike OPTIONAL
        usevariantmanagement    TYPE clike OPTIONAL
        useexporttoexcel        TYPE clike OPTIONAL
        usetablepersonalisation TYPE clike OPTIONAL
        header                  TYPE clike OPTIONAL
        showrowcount            TYPE clike OPTIONAL
        enableexport            TYPE clike OPTIONAL
        enableautobinding       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `formToolbar`</p>
    METHODS form_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.PagingButton</p>
    "!
    "! @parameter count                 | (int) Total number of pages. Default: 1.
    "! @parameter nextbuttontooltip     | (string) Tooltip for the next button.
    "! @parameter previousbuttontooltip | (string) Tooltip for the previous button.
    "! @parameter position              | (int) Current 1-based position.
    METHODS paging_button
      IMPORTING
        count                 TYPE clike OPTIONAL
        nextbuttontooltip     TYPE clike OPTIONAL
        previousbuttontooltip TYPE clike OPTIONAL
        position              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.Timeline</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.Timeline.
    "!
    "! @parameter enabledoublesided | (boolean) Render entries on both sides of the axis. Default: false.
    "! @parameter groupby           | (string) Property used for automatic grouping.
    "! @parameter growingthreshold  | (int) Items per growing chunk. Default: 5.
    "! @parameter filtertitle       | (string) Title shown above the filter.
    "! @parameter sortoldestfirst   | (boolean) Sort oldest entries first. Default: false.
    "! @parameter alignment         | (sap.suite.ui.commons.TimelineAlignment) Right | Left. Default: Right.
    "! @parameter axisorientation   | (sap.suite.ui.commons.TimelineAxisOrientation) Vertical | Horizontal. Default: Vertical.
    "! @parameter content           | (binding path) Default content aggregation.
    "! @parameter enablemodelfilter | (boolean) Apply filter at the model level. Default: true.
    "! @parameter enablescroll      | (boolean) Enable scrolling. Default: true.
    "! @parameter forcegrowing      | (boolean) Force growing even if all items fit. Default: false.
    "! @parameter group             | (boolean) Enable grouping. Default: false.
    "! @parameter lazyloading       | (boolean) Enable lazy loading. Default: false.
    "! @parameter showheaderbar     | (boolean) Show the header bar. Default: true.
    "! @parameter showicons         | (boolean) Show icons. Default: true.
    "! @parameter showitemfilter    | (boolean) Show item filter. Default: true.
    "! @parameter showsearch        | (boolean) Show search. Default: true.
    "! @parameter showsort          | (boolean) Show sort dropdown. Default: true.
    "! @parameter showtimefilter    | (boolean) Show time filter. Default: false.
    "! @parameter sort              | (boolean) Sort items by date. Default: true.
    "! @parameter groupbytype       | (sap.suite.ui.commons.TimelineGroupType) Year | Month | Quarter | Week | Day. Default: None.
    "! @parameter textheight        | (sap.ui.core.CSSSize) Default text height.
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter height            | (sap.ui.core.CSSSize) Height.
    "! @parameter nodatatext        | (string) Empty-state text.
    "! @parameter filterlist        | (binding path) Aggregation of filter list items.
    "! @parameter customfilter      | (binding path) Custom filter aggregation.
    METHODS timeline
      IMPORTING
        id                TYPE clike OPTIONAL
        enabledoublesided TYPE clike OPTIONAL
        groupby           TYPE clike OPTIONAL
        growingthreshold  TYPE clike OPTIONAL
        filtertitle       TYPE clike OPTIONAL
        sortoldestfirst   TYPE clike OPTIONAL
        alignment         TYPE clike OPTIONAL
        axisorientation   TYPE clike OPTIONAL
        content           TYPE clike OPTIONAL
        enablemodelfilter TYPE clike OPTIONAL
        enablescroll      TYPE clike OPTIONAL
        forcegrowing      TYPE clike OPTIONAL
        group             TYPE clike OPTIONAL
        lazyloading       TYPE clike OPTIONAL
        showheaderbar     TYPE clike OPTIONAL
        showicons         TYPE clike OPTIONAL
        showitemfilter    TYPE clike OPTIONAL
        showsearch        TYPE clike OPTIONAL
        showsort          TYPE clike OPTIONAL
        showtimefilter    TYPE clike OPTIONAL
        sort              TYPE clike OPTIONAL
        groupbytype       TYPE clike OPTIONAL
        textheight        TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        height            TYPE clike OPTIONAL
        nodatatext        TYPE clike OPTIONAL
        filterlist        TYPE clike OPTIONAL
        customfilter      TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.TimelineItem</p>
    "!
    "! @parameter datetime            | (string) Entry timestamp.
    "! @parameter title               | (string) Entry title.
    "! @parameter usernameclickable   | (boolean) Render the user name as a link. Default: false.
    "! @parameter useicontooltip      | (boolean) Use icon symbolic name as tooltip. Default: true.
    "! @parameter usernameclicked     | (event) Fired when the user name link is pressed.
    "! @parameter select              | (event) Fired when the entry is selected.
    "! @parameter userpicture         | (sap.ui.core.URI) Profile picture URI.
    "! @parameter text                | (string) Entry body text.
    "! @parameter username            | (string) User name.
    "! @parameter filtervalue         | (string) Value used by the filter.
    "! @parameter icondisplayshape    | (sap.m.AvatarShape) Circle | Square. Default: Circle.
    "! @parameter iconinitials        | (string) Initials shown when no icon is set.
    "! @parameter iconsize            | (sap.m.AvatarSize) Size of the icon.
    "! @parameter icontooltip         | (string) Custom icon tooltip.
    "! @parameter maxcharacters       | (int) Truncate text after N characters. 0 = unlimited.
    "! @parameter replycount          | (int) Number of replies displayed.
    "! @parameter status              | (string) Item status text.
    "! @parameter customactionclicked | (event) Fired when a custom action is clicked.
    "! @parameter press               | (event) Fired when the entry is pressed.
    "! @parameter replylistopen       | (event) Fired when the reply list opens.
    "! @parameter replypost           | (event) Fired when a reply is posted.
    "! @parameter icon                | (sap.ui.core.URI) Icon URI.
    METHODS timeline_item
      IMPORTING
        id                  TYPE clike OPTIONAL
        datetime            TYPE clike OPTIONAL
        title               TYPE clike OPTIONAL
        usernameclickable   TYPE clike OPTIONAL
        useicontooltip      TYPE clike OPTIONAL
        usernameclicked     TYPE clike OPTIONAL
        select              TYPE clike OPTIONAL
        userpicture         TYPE clike OPTIONAL
        text                TYPE clike OPTIONAL
        username            TYPE clike OPTIONAL
        filtervalue         TYPE clike OPTIONAL
        icondisplayshape    TYPE clike OPTIONAL
        iconinitials        TYPE clike OPTIONAL
        iconsize            TYPE clike OPTIONAL
        icontooltip         TYPE clike OPTIONAL
        maxcharacters       TYPE clike OPTIONAL
        replycount          TYPE clike OPTIONAL
        status              TYPE clike OPTIONAL
        customactionclicked TYPE clike OPTIONAL
        press               TYPE clike OPTIONAL
        replylistopen       TYPE clike OPTIONAL
        replypost           TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.SplitContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.SplitContainer.
    "!
    "! @parameter initialdetail               | (sap.ui.core.ID) Id of the initially shown detail page.
    "! @parameter initialmaster               | (sap.ui.core.ID) Id of the initially shown master page.
    "! @parameter backgroundcolor             | (sap.ui.core.CSSColor) Background colour.
    "! @parameter backgroundimage             | (sap.ui.core.URI) Background image URI.
    "! @parameter backgroundopacity           | (float) Background image opacity (0..1). Default: 1.
    "! @parameter backgroundrepeat            | (boolean) Tile the background image. Default: false.
    "! @parameter defaulttransitionnamedetail | (string) Default detail-page transition.
    "! @parameter defaulttransitionnamemaster | (string) Default master-page transition.
    "! @parameter masterbuttontext            | (string) Master button text on phone.
    "! @parameter masterbuttontooltip         | (string) Master button tooltip.
    "! @parameter mode                        | (sap.m.SplitAppMode) ShowHideMode | StretchCompressMode | PopoverMode | HideMode. Default: ShowHideMode.
    "! @parameter afterdetailnavigate         | (event) Fired after detail navigation.
    "! @parameter aftermasterclose            | (event) Fired after the master closes.
    "! @parameter aftermasternavigate         | (event) Fired after master navigation.
    "! @parameter aftermasteropen             | (event) Fired after the master opens.
    "! @parameter beforemasterclose           | (event) Fired before the master closes.
    "! @parameter beforemasteropen            | (event) Fired before the master opens.
    "! @parameter detailnavigate              | (event) Fired during detail navigation.
    "! @parameter masterbutton                | (event) Fired when the master button is pressed.
    "! @parameter masternavigate              | (event) Fired during master navigation.
    METHODS split_container
      IMPORTING
        id                          TYPE clike OPTIONAL
        initialdetail               TYPE clike OPTIONAL
        initialmaster               TYPE clike OPTIONAL
        backgroundcolor             TYPE clike OPTIONAL
        backgroundimage             TYPE clike OPTIONAL
        backgroundopacity           TYPE clike OPTIONAL
        backgroundrepeat            TYPE clike OPTIONAL
        defaulttransitionnamedetail TYPE clike OPTIONAL
        defaulttransitionnamemaster TYPE clike OPTIONAL
        masterbuttontext            TYPE clike OPTIONAL
        masterbuttontooltip         TYPE clike OPTIONAL
        mode                        TYPE clike OPTIONAL
        afterdetailnavigate         TYPE clike OPTIONAL
        aftermasterclose            TYPE clike OPTIONAL
        aftermasternavigate         TYPE clike OPTIONAL
        aftermasteropen             TYPE clike OPTIONAL
        beforemasterclose           TYPE clike OPTIONAL
        beforemasteropen            TYPE clike OPTIONAL
        detailnavigate              TYPE clike OPTIONAL
        masterbutton                TYPE clike OPTIONAL
        masternavigate              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)               TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `detailPages`</p>
    METHODS detail_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `masterPages`</p>
    METHODS master_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vk.ContainerContent</p>
    "!
    "! @parameter title | (string) Tab/content title.
    "! @parameter icon  | (sap.ui.core.URI) Tab icon URI.
    METHODS container_content
      IMPORTING
        id            TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.MapContainer</p>
    "!
    "! @parameter autoadjustheight | (boolean) Auto-adjust height. Default: false.
    "! @parameter showhome         | (boolean) Show "Home" button. Default: true.
    METHODS map_container
      IMPORTING
        id               TYPE clike OPTIONAL
        autoadjustheight TYPE clike OPTIONAL
        showhome         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.Spot</p>
    "!
    "! @parameter position      | (string) Geo position (lon;lat;alt).
    "! @parameter contentoffset | (string) Content offset (x;y).
    "! @parameter type          | (sap.ui.vbm.SemanticType) None | Success | Error | Warning | Default | Inactive | Hidden. Default: None.
    "! @parameter scale         | (string) Scale factor (sx;sy;sz).
    "! @parameter tooltip       | (string) Tooltip.
    "! @parameter image         | (sap.ui.core.URI) Image URI.
    "! @parameter icon          | (sap.ui.core.URI) Icon URI.
    "! @parameter click         | (event) Fired when the spot is clicked.
    "! @parameter text          | (string) Label text.
    METHODS spot
      IMPORTING
        id            TYPE clike OPTIONAL
        position      TYPE clike OPTIONAL
        contentoffset TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        scale         TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
        image         TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        click         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.AnalyticMap</p>
    "!
    "! @parameter initialposition | (string) Initial centre position (lon;lat).
    "! @parameter height          | (sap.ui.core.CSSSize) Height.
    "! @parameter lassoselection  | (boolean) Enable lasso selection. Default: true.
    "! @parameter visible         | (boolean) Whether visible. Default: true.
    "! @parameter width           | (sap.ui.core.CSSSize) Width.
    "! @parameter initialzoom     | (string) Initial zoom level.
    METHODS analytic_map
      IMPORTING
        id              TYPE clike OPTIONAL
        initialposition TYPE clike OPTIONAL
        height          TYPE clike OPTIONAL
        lassoselection  TYPE clike OPTIONAL
        visible         TYPE clike OPTIONAL
        width           TYPE clike OPTIONAL
        initialzoom     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.Spots</p>
    "!
    "! @parameter items | (binding path) Aggregation of `Spot`.
    METHODS spots
      IMPORTING
        id            TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `vos`</p>
    METHODS vos
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ActionSheet</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ActionSheet.
    "!
    "! @parameter cancelbuttontext  | (string) Custom cancel button text.
    "! @parameter placement         | (sap.m.PlacementType) Top | Bottom | Vertical | Auto | Right | Left | Horizontal. Default: Bottom.
    "! @parameter showcancelbutton  | (boolean) Show the cancel button (mobile only). Default: true.
    "! @parameter title              | (string) Title shown on top.
    "! @parameter afterclose        | (event) Fired after the sheet has closed.
    "! @parameter afteropen         | (event) Fired after the sheet has opened.
    "! @parameter beforeclose       | (event) Fired before the sheet closes.
    "! @parameter beforeopen        | (event) Fired before the sheet opens.
    "! @parameter cancelbuttonpress | (event) Fired when the cancel button is pressed.
    "! @parameter visible           | (boolean) Whether the sheet is visible. Default: true.
    "! @parameter class             | (string) CSS class names.
    METHODS action_sheet
      IMPORTING
        id                TYPE clike OPTIONAL
        cancelbuttontext  TYPE clike OPTIONAL
        placement         TYPE clike OPTIONAL
        showcancelbutton  TYPE clike OPTIONAL
        title             TYPE clike OPTIONAL
        afterclose        TYPE clike OPTIONAL
        afteropen         TYPE clike OPTIONAL
        beforeclose       TYPE clike OPTIONAL
        beforeopen        TYPE clike OPTIONAL
        cancelbuttonpress TYPE clike OPTIONAL
        visible           TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.ExpandableText</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.ExpandableText. Since 1.87.
    "!
    "! @parameter emptyindicatormode | (sap.m.EmptyIndicatorMode) On | Off | Auto. Default: Off.
    "! @parameter maxcharacters      | (int) Character limit before "show more". Default: 100.
    "! @parameter overflowmode       | (sap.m.ExpandableTextOverflowMode) InPlace | Popover. Default: InPlace.
    "! @parameter renderwhitespace   | (boolean) Render whitespace as `&nbsp;`. Default: false.
    "! @parameter text               | (string) Text content.
    "! @parameter textalign          | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Begin.
    "! @parameter textdirection      | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    "! @parameter wrappingtype       | (sap.m.WrappingType) Normal | Hyphenated. Default: Normal.
    "! @parameter class              | (string) CSS class names.
    METHODS expandable_text
      IMPORTING
        id                 TYPE clike OPTIONAL
        emptyindicatormode TYPE clike OPTIONAL
        maxcharacters      TYPE clike OPTIONAL
        overflowmode       TYPE clike OPTIONAL
        renderwhitespace   TYPE clike OPTIONAL
        text               TYPE clike OPTIONAL
        textalign          TYPE clike OPTIONAL
        textdirection      TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        wrappingtype       TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Select</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Select.
    "!
    "! @parameter autoadjustwidth     | (boolean) Adjust width based on selected text. Default: false.
    "! @parameter columnratio         | (string) Column-ratio for IconOnly types (e.g. `3:5`).
    "! @parameter editable            | (boolean) Whether editable. Default: true.
    "! @parameter enabled             | (boolean) Whether enabled. Default: true.
    "! @parameter forceselection      | (boolean) Force a value to always be selected. Default: true.
    "! @parameter icon                | (sap.ui.core.URI) Icon URI (for IconOnly type).
    "! @parameter maxwidth            | (sap.ui.core.CSSSize) Maximum width.
    "! @parameter name                | (string) HTML form name.
    "! @parameter required            | (boolean) Required field marker. Default: false.
    "! @parameter resetonmissingkey   | (boolean) Reset selection when key is missing. Default: false.
    "! @parameter selecteditemid      | (string) Id of the selected item.
    "! @parameter selectedkey         | (string) Two-way bound selected key.
    "! @parameter showsecondaryvalues | (boolean) Render `additionalText` as a second column. Default: false.
    "! @parameter textalign           | (sap.ui.core.TextAlign) Begin | End | Left | Right | Center | Initial. Default: Initial.
    "! @parameter textdirection       | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter type                | (sap.m.SelectType) Default | IconOnly. Default: Default.
    "! @parameter valuestate          | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter valuestatetext      | (string) Value state message.
    "! @parameter visible             | (boolean) Whether visible. Default: true.
    "! @parameter width               | (sap.ui.core.CSSSize) Width. Default: auto.
    "! @parameter wrapitemstext       | (boolean) Wrap item text. Default: false.
    "! @parameter items               | (binding path) Aggregation of `sap.ui.core.Item`.
    "! @parameter selecteditem        | (sap.ui.core.ID) Id of the selected item.
    "! @parameter change              | (event) Fired when the selected item changes.
    "! @parameter livechange          | (event) Fired during typing in search-enabled mode.
    "! @parameter class               | (string) CSS class names.
    METHODS select
      IMPORTING
        id                  TYPE clike OPTIONAL
        autoadjustwidth     TYPE clike OPTIONAL
        columnratio         TYPE clike OPTIONAL
        editable            TYPE clike OPTIONAL
        enabled             TYPE clike OPTIONAL
        forceselection      TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
        maxwidth            TYPE clike OPTIONAL
        name                TYPE clike OPTIONAL
        required            TYPE clike OPTIONAL
        resetonmissingkey   TYPE clike OPTIONAL
        selecteditemid      TYPE clike OPTIONAL
        selectedkey         TYPE clike OPTIONAL
        showsecondaryvalues TYPE clike OPTIONAL
        textalign           TYPE clike OPTIONAL
        textdirection       TYPE clike OPTIONAL
        type                TYPE clike OPTIONAL
        valuestate          TYPE clike OPTIONAL
        valuestatetext      TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        width               TYPE clike OPTIONAL
        wrapitemstext       TYPE clike OPTIONAL
        items               TYPE clike OPTIONAL
        selecteditem        TYPE clike OPTIONAL
        change              TYPE clike OPTIONAL
        livechange          TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `_embeddedControl`</p>
    METHODS embedded_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.HeaderContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.HeaderContainer.
    "!
    "! @parameter backgrounddesign | (sap.m.BackgroundDesign) Solid | Translucent | Transparent. Default: Solid.
    "! @parameter gridlayout       | (boolean) Use grid layout. Default: false. Since 1.99.
    "! @parameter height           | (sap.ui.core.CSSSize) Height.
    "! @parameter orientation      | (sap.ui.core.Orientation) Horizontal | Vertical. Default: Horizontal.
    "! @parameter scrollstep       | (int) Scroll step in px.
    "! @parameter scrollstepbyitem | (int) Scroll step in items. Default: 1.
    "! @parameter scrolltime       | (int) Scroll animation duration in ms.
    "! @parameter showdividers     | (boolean) Show dividers between items. Default: true.
    "! @parameter showoverflowitem | (boolean) Show overflow indicator. Default: true.
    "! @parameter visible          | (boolean) Whether visible. Default: true.
    "! @parameter width            | (sap.ui.core.CSSSize) Width.
    "! @parameter scroll           | (event) Fired on scroll.
    "! @parameter snaptorow        | (boolean) Snap to row when scrolling. Default: false.
    METHODS header_container_control
      IMPORTING
        backgrounddesign TYPE clike OPTIONAL
        gridlayout       TYPE clike OPTIONAL
        height           TYPE clike OPTIONAL
        orientation      TYPE clike OPTIONAL
        scrollstep       TYPE clike OPTIONAL
        scrollstepbyitem TYPE clike OPTIONAL
        scrolltime       TYPE clike OPTIONAL
        showdividers     TYPE clike OPTIONAL
        showoverflowitem TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        id               TYPE clike OPTIONAL
        scroll           TYPE clike OPTIONAL
        snaptorow        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `dependents`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS dependents
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.Card</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.Card.
    "!
    "! @parameter headerposition | (sap.f.cards.HeaderPosition) Top | Bottom. Default: Top.
    "! @parameter height         | (sap.ui.core.CSSSize) Card height.
    "! @parameter visible        | (boolean) Whether visible. Default: true.
    "! @parameter width          | (sap.ui.core.CSSSize) Card width. Default: 100%.
    METHODS card
      IMPORTING
        id             TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
        headerposition TYPE clike OPTIONAL
        height         TYPE clike OPTIONAL
        visible        TYPE clike OPTIONAL
        width          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.cards.Header</p>
    "!
    "! @parameter iconalt             | (string) Alt text for the icon.
    "! @parameter iconbackgroundcolor | (sap.m.AvatarColor) Accent1..Accent10 | Placeholder | TileIcon | Random. Default: Accent6.
    "! @parameter icondisplayshape    | (sap.m.AvatarShape) Circle | Square. Default: Circle.
    "! @parameter iconinitials        | (string) Initials when no icon is set.
    "! @parameter iconsize            | (sap.m.AvatarSize) Size of the icon.
    "! @parameter iconsrc             | (sap.ui.core.URI) Icon URI.
    "! @parameter iconvisible         | (boolean) Show the icon. Default: true.
    "! @parameter statustext          | (string) Status text shown next to the title.
    "! @parameter statusvisible       | (boolean) Show status text. Default: true.
    "! @parameter subtitle            | (string) Subtitle text.
    "! @parameter subtitlemaxlines    | (int) Max subtitle lines. Default: 2.
    "! @parameter title               | (string) Title text.
    "! @parameter titlemaxlines       | (int) Max title lines. Default: 3.
    "! @parameter visible             | (boolean) Whether visible. Default: true.
    "! @parameter datatimestamp       | (string) Last data update timestamp.
    "! @parameter press               | (event) Fired when the header is pressed.
    METHODS card_header
      IMPORTING
        id                  TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        iconalt             TYPE clike OPTIONAL
        iconbackgroundcolor TYPE clike OPTIONAL
        icondisplayshape    TYPE clike OPTIONAL
        iconinitials        TYPE clike OPTIONAL
        iconsize            TYPE clike OPTIONAL
        iconsrc             TYPE clike OPTIONAL
        iconvisible         TYPE clike OPTIONAL
        statustext          TYPE clike OPTIONAL
        statusvisible       TYPE clike OPTIONAL
        subtitle            TYPE clike OPTIONAL
        subtitlemaxlines    TYPE clike OPTIONAL
        title               TYPE clike OPTIONAL
        titlemaxlines       TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        datatimestamp       TYPE clike OPTIONAL
        press               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.cards.NumericHeader</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.cards.NumericHeader.
    "!
    "! @parameter visible                 | (boolean) Whether visible. Default: true.
    "! @parameter datatimestamp           | (string) Last data update timestamp.
    "! @parameter press                   | (event) Fired when the header is pressed.
    "! @parameter details                 | (string) Details text shown below the value.
    "! @parameter detailsmaxlines         | (int) Max details lines.
    "! @parameter detailsstate            | (sap.ui.core.ValueState) None | Success | Warning | Error | Information. Default: None.
    "! @parameter iconalt                 | (string) Alt text for the icon.
    "! @parameter iconbackgroundcolor     | (sap.m.AvatarColor) Background colour for the icon.
    "! @parameter icondisplayshape        | (sap.m.AvatarShape) Circle | Square.
    "! @parameter iconinitials            | (string) Initials when no icon is set.
    "! @parameter iconsize                | (sap.m.AvatarSize) Size of the icon.
    "! @parameter iconsrc                 | (sap.ui.core.URI) Icon URI.
    "! @parameter iconvisible             | (boolean) Show the icon. Default: true.
    "! @parameter number                  | (string) The numeric value.
    "! @parameter numbersize              | (sap.m.cards.NumericHeaderSideIndicatorAlignment) S | M | L. Default: L.
    "! @parameter numbervisible           | (boolean) Show the number. Default: true.
    "! @parameter scale                   | (string) Scale text shown next to the number.
    "! @parameter sideindicatorsalignment | (sap.f.cards.NumericHeaderSideIndicatorsAlignment) Begin | End. Default: Begin.
    "! @parameter state                   | (sap.m.ValueColor) None | Good | Error | Critical | Neutral. Default: Neutral.
    "! @parameter statustext              | (string) Status text shown next to the title.
    "! @parameter statusvisible           | (boolean) Show status text. Default: true.
    "! @parameter subtitle                | (string) Subtitle text.
    "! @parameter subtitlemaxlines        | (int) Max subtitle lines.
    "! @parameter title                   | (string) Title text.
    "! @parameter titlemaxlines           | (int) Max title lines.
    "! @parameter trend                   | (sap.m.DeviationIndicator) None | Up | Down. Default: None.
    "! @parameter unitofmeasurement       | (string) Unit text.
    METHODS numeric_header
      IMPORTING
        id                      TYPE clike OPTIONAL
        class                   TYPE clike OPTIONAL
        visible                 TYPE clike OPTIONAL
        datatimestamp           TYPE clike OPTIONAL
        press                   TYPE clike OPTIONAL
        details                 TYPE clike OPTIONAL
        detailsmaxlines         TYPE clike OPTIONAL
        detailsstate            TYPE clike OPTIONAL
        iconalt                 TYPE clike OPTIONAL
        iconbackgroundcolor     TYPE clike OPTIONAL
        icondisplayshape        TYPE clike OPTIONAL
        iconinitials            TYPE clike OPTIONAL
        iconsize                TYPE clike OPTIONAL
        iconsrc                 TYPE clike OPTIONAL
        iconvisible             TYPE clike OPTIONAL
        number                  TYPE clike OPTIONAL
        numbersize              TYPE clike OPTIONAL
        numbervisible           TYPE clike OPTIONAL
        scale                   TYPE clike OPTIONAL
        sideindicatorsalignment TYPE clike OPTIONAL
        state                   TYPE clike OPTIONAL
        statustext              TYPE clike OPTIONAL
        statusvisible           TYPE clike OPTIONAL
        subtitle                TYPE clike OPTIONAL
        subtitlemaxlines        TYPE clike OPTIONAL
        title                   TYPE clike OPTIONAL
        titlemaxlines           TYPE clike OPTIONAL
        trend                   TYPE clike OPTIONAL
        unitofmeasurement       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.cards.NumericSideIndicator</p>
    "!
    "! @parameter number | (string) Numeric value.
    "! @parameter state  | (sap.m.ValueColor) None | Good | Error | Critical | Neutral. Default: Neutral.
    "! @parameter title  | (string) Indicator title.
    "! @parameter unit   | (string) Unit text.
    METHODS numeric_side_indicator
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        number        TYPE clike OPTIONAL
        state         TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        unit          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.SlideTile</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.SlideTile.
    "!
    "! @parameter displaytime    | (int) Display time per tile in ms. Default: 5000.
    "! @parameter height         | (sap.ui.core.CSSSize) Height.
    "! @parameter scope          | (sap.m.GenericTileScope) Display | Actions | ActionMore | ActionRemove. Default: Display.
    "! @parameter sizebehavior   | (sap.m.TileSizeBehavior) Responsive | Small. Default: Responsive.
    "! @parameter transitiontime | (int) Transition animation time in ms. Default: 500.
    "! @parameter press          | (event) Fired when the tile is pressed.
    "! @parameter width          | (sap.ui.core.CSSSize) Width.
    METHODS slide_tile
      IMPORTING
        displaytime    TYPE clike OPTIONAL
        height         TYPE clike OPTIONAL
        visible        TYPE clike OPTIONAL
        scope          TYPE clike OPTIONAL
        sizebehavior   TYPE clike OPTIONAL
        transitiontime TYPE clike OPTIONAL
        press          TYPE clike OPTIONAL
        width          TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `tiles`</p>
    METHODS tiles
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.BusyIndicator</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.BusyIndicator.
    "!
    "! @parameter customicon              | (sap.ui.core.URI) Custom icon URI.
    "! @parameter customiconheight        | (sap.ui.core.CSSSize) Custom icon height. Default: 44px.
    "! @parameter customiconrotationspeed | (int) Rotation speed in ms. Default: 1000.
    "! @parameter customiconwidth         | (sap.ui.core.CSSSize) Custom icon width. Default: 44px.
    "! @parameter size                    | (sap.ui.core.CSSSize) Indicator size.
    "! @parameter text                    | (string) Text shown next to the indicator.
    "! @parameter textdirection           | (sap.ui.core.TextDirection) Inherit | LTR | RTL. Default: Inherit.
    "! @parameter customicondensityaware  | (boolean) Density-aware custom icon. Default: true.
    "! @parameter visible                 | (boolean) Whether visible. Default: true.
    METHODS busy_indicator
      IMPORTING
        id                      TYPE clike OPTIONAL
        class                   TYPE clike OPTIONAL
        customicon              TYPE clike OPTIONAL
        customiconheight        TYPE clike OPTIONAL
        customiconrotationspeed TYPE clike OPTIONAL
        customiconwidth         TYPE clike OPTIONAL
        size                    TYPE clike OPTIONAL
        text                    TYPE clike OPTIONAL
        textdirection           TYPE clike OPTIONAL
        customicondensityaware  TYPE clike OPTIONAL
        visible                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `customLayout`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS custom_layout
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridContainerCarouselLayout</p>
    "!
    "! @parameter visiblepagescount | (int) Number of visible pages.
    METHODS carousel_layout
      IMPORTING
        visiblepagescount TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FacetFilter</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.FacetFilter.
    "!
    "! @parameter livesearch          | (boolean) Live search inside facet popovers. Default: true.
    "! @parameter showpersonalization | (boolean) Show personalisation button. Default: false.
    "! @parameter showpopoverokbutton | (boolean) Show OK button in popover. Default: false.
    "! @parameter showreset           | (boolean) Show "Reset" button. Default: false.
    "! @parameter showsummarybar      | (boolean) Show summary bar. Default: false.
    "! @parameter type                | (sap.m.FacetFilterType) Simple | Light. Default: Simple.
    "! @parameter visible             | (boolean) Whether visible. Default: true.
    "! @parameter confirm             | (event) Fired when filters are confirmed.
    "! @parameter reset               | (event) Fired when filters are reset.
    "! @parameter lists               | (binding path) Aggregation of `FacetFilterList`.
    METHODS facet_filter
      IMPORTING
        id                  TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        livesearch          TYPE clike OPTIONAL
        showpersonalization TYPE clike OPTIONAL
        showpopoverokbutton TYPE clike OPTIONAL
        showreset           TYPE clike OPTIONAL
        showsummarybar      TYPE clike OPTIONAL
        type                TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        confirm             TYPE clike OPTIONAL
        reset               TYPE clike OPTIONAL
        lists               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FacetFilterList</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.FacetFilterList. Inherits sap.m.List.
    "!
    "! @parameter active                      | (boolean) Whether the list is active. Default: true.
    "! @parameter allcount                    | (int) Total number of items including not currently loaded.
    "! @parameter backgrounddesign            | (sap.m.BackgroundDesign) Solid | Translucent | Transparent.
    "! @parameter datatype                    | (sap.m.FacetFilterListDataType) String | Date | Time | DateTime | Boolean | Integer | Float. Default: String.
    "! @parameter enablebusyindicator         | (boolean) Auto-show busy during data load. Default: true.
    "! @parameter enablecaseinsensitivesearch | (boolean) Case-insensitive search. Default: false.
    "! @parameter footertext                  | (string) Footer text.
    "! @parameter growing                     | (boolean) Enable growing. Default: true.
    "! @parameter growingdirection            | (sap.m.ListGrowingDirection) Downwards | Upwards. Default: Downwards.
    "! @parameter growingscrolltoload         | (boolean) Trigger growing on scroll. Default: false.
    "! @parameter growingthreshold            | (int) Items per growing chunk. Default: 50.
    "! @parameter growingtriggertext          | (string) Custom "More" button text.
    "! @parameter headerlevel                 | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter headertext                  | (string) Header text.
    "! @parameter includeiteminselection      | (boolean) Click item to select. Default: false.
    "! @parameter inset                       | (boolean) Indent the container. Default: false.
    "! @parameter key                         | (string) List key.
    "! @parameter keyboardmode                | (sap.m.ListKeyboardMode) Navigation | Edit. Default: Navigation.
    "! @parameter mode                        | (sap.m.ListMode) Selection mode. Default: MultiSelect.
    "! @parameter modeanimationon             | (boolean) Animate mode change. Default: true.
    "! @parameter multiselectmode             | (sap.m.MultiSelectMode) Default | ClearAll | SelectAll. Default: Default.
    "! @parameter nodatatext                  | (string) Empty-state text.
    "! @parameter rememberselections          | (boolean) Persist selections. Default: true.
    "! @parameter retainlistsequence          | (boolean) Retain the list order on the bar. Default: false.
    "! @parameter sequence                    | (int) Position of the list on the bar. Default: -1.
    "! @parameter shownodata                  | (boolean) Show empty-state text. Default: true.
    "! @parameter showremovefaceticon         | (boolean) Show "Remove Filter" icon in popover. Default: true.
    "! @parameter showseparators              | (sap.m.ListSeparators) All | Inner | None. Default: All.
    "! @parameter showunread                  | (boolean) Activate unread indicator. Default: false.
    "! @parameter sticky                      | (sap.m.Sticky[]) Sticky areas.
    "! @parameter swipedirection              | (sap.m.SwipeDirection) Both | RightToLeft | LeftToRight. Default: Both.
    "! @parameter title                       | (string) List title shown on the bar.
    "! @parameter visible                     | (boolean) Whether visible. Default: true.
    "! @parameter width                       | (sap.ui.core.CSSSize) Width.
    "! @parameter wordwrap                    | (boolean) Wrap item text. Default: false.
    "! @parameter listclose                   | (event) Fired when the popover closes.
    "! @parameter listopen                    | (event) Fired when the popover opens.
    "! @parameter search                      | (event) Fired during search.
    "! @parameter selectionchange             | (event) Fired when selection changes.
    "! @parameter delete                      | (event) Fired when an item is deleted.
    "! @parameter items                       | (binding path) Aggregation of `FacetFilterItem`.
    METHODS facet_filter_list
      IMPORTING
        id                          TYPE clike OPTIONAL
        class                       TYPE clike OPTIONAL
        active                      TYPE clike OPTIONAL
        allcount                    TYPE clike OPTIONAL
        backgrounddesign            TYPE clike OPTIONAL
        datatype                    TYPE clike OPTIONAL
        enablebusyindicator         TYPE clike OPTIONAL
        enablecaseinsensitivesearch TYPE clike OPTIONAL
        footertext                  TYPE clike OPTIONAL
        growing                     TYPE clike OPTIONAL
        growingdirection            TYPE clike OPTIONAL
        growingscrolltoload         TYPE clike OPTIONAL
        growingthreshold            TYPE clike OPTIONAL
        growingtriggertext          TYPE clike OPTIONAL
        headerlevel                 TYPE clike OPTIONAL
        headertext                  TYPE clike OPTIONAL
        includeiteminselection      TYPE clike OPTIONAL
        inset                       TYPE clike OPTIONAL
        key                         TYPE clike OPTIONAL
        keyboardmode                TYPE clike OPTIONAL
        mode                        TYPE clike OPTIONAL
        modeanimationon             TYPE clike OPTIONAL
        multiselectmode             TYPE clike OPTIONAL
        nodatatext                  TYPE clike OPTIONAL
        rememberselections          TYPE clike OPTIONAL
        retainlistsequence          TYPE clike OPTIONAL
        sequence                    TYPE clike OPTIONAL
        shownodata                  TYPE clike OPTIONAL
        showremovefaceticon         TYPE clike OPTIONAL
        showseparators              TYPE clike OPTIONAL
        showunread                  TYPE clike OPTIONAL
        sticky                      TYPE clike OPTIONAL
        swipedirection              TYPE clike OPTIONAL
        title                       TYPE clike OPTIONAL
        visible                     TYPE clike OPTIONAL
        width                       TYPE clike OPTIONAL
        wordwrap                    TYPE clike OPTIONAL
        listclose                   TYPE clike OPTIONAL
        listopen                    TYPE clike OPTIONAL
        search                      TYPE clike OPTIONAL
        selectionchange             TYPE clike OPTIONAL
        delete                      TYPE clike OPTIONAL
        items                       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)               TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.FacetFilterItem</p>
    "!
    "! @parameter count         | (int) Item count.
    "! @parameter counter       | (int, ListItemBase) Counter badge.
    "! @parameter highlight     | (sap.ui.core.MessageType | IndicationColor, ListItemBase) Default: None.
    "! @parameter highlighttext | (string, ListItemBase) Custom accessibility text for highlight.
    "! @parameter key           | (string) Item key.
    "! @parameter navigated     | (boolean, ListItemBase) Marked as navigated. Default: false.
    "! @parameter selected      | (boolean, ListItemBase) Selected state. Default: false.
    "! @parameter text          | (string) Item text.
    "! @parameter type          | (sap.m.ListType, ListItemBase) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter unread        | (boolean, ListItemBase) Unread state. Default: false.
    "! @parameter visible       | (boolean, ListItemBase) Whether visible. Default: true.
    "! @parameter press         | (event, ListItemBase) Fired when the item is activated.
    "! @parameter detailpress   | (event, ListItemBase) Fired when the detail icon is pressed.
    METHODS facet_filter_item
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        count         TYPE clike OPTIONAL
        counter       TYPE clike OPTIONAL
        highlight     TYPE clike OPTIONAL
        highlighttext TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        navigated     TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        unread        TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        detailpress   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.DraftIndicator</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.DraftIndicator.
    "!
    "! @parameter mindisplaytime | (int) Minimum display time in ms. Default: 1500.
    "! @parameter state          | (sap.m.DraftIndicatorState) Clear | Saving | Saved. Default: Clear.
    "! @parameter visible        | (boolean) Whether visible. Default: true.
    METHODS draft_indicator
      IMPORTING
        id             TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
        mindisplaytime TYPE clike OPTIONAL
        state          TYPE clike OPTIONAL
        visible        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.dnd.DragInfo</p>
    "!
    "! @parameter sourceaggregation | (string) Source aggregation name.
    METHODS drag_info
      IMPORTING
        sourceaggregation TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.core.dnd.DragDropInfo</p>
    "!
    "! @parameter sourceaggregation | (string) Source aggregation name.
    "! @parameter targetaggregation | (string) Target aggregation name.
    "! @parameter dragstart         | (event) Fired when dragging starts.
    "! @parameter drop              | (event) Fired when an item is dropped.
    METHODS drag_drop_info
      IMPORTING
        sourceaggregation TYPE clike OPTIONAL
        targetaggregation TYPE clike OPTIONAL
        dragstart         TYPE clike OPTIONAL
        drop              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `dragDropConfig`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix. Default: `f`.
    METHODS drag_drop_config
      IMPORTING
        ns            TYPE clike DEFAULT `f`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">UI5 raw HTML `map` element</p>
    "!
    "! @parameter name | (string) Map name (referenced by `usemap`).
    METHODS html_map
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        name          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">UI5 raw HTML area element (image-map area)</p>
    "!
    "! @parameter shape   | (string) HTML area shape (rect | circle | poly | default).
    "! @parameter coords  | (string) Coordinates string.
    "! @parameter alt     | (string) Alt text.
    "! @parameter target  | (string) HTML target attribute.
    "! @parameter href    | (sap.ui.core.URI) Link target.
    "! @parameter onclick | (string) Inline JS click handler.
    METHODS html_area
      IMPORTING
        id            TYPE clike OPTIONAL
        shape         TYPE clike OPTIONAL
        coords        TYPE clike OPTIONAL
        alt           TYPE clike OPTIONAL
        target        TYPE clike OPTIONAL
        href          TYPE clike OPTIONAL
        onclick       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">UI5 raw HTML `canvas` element</p>
    "!
    "! @parameter width  | (sap.ui.core.CSSSize) Canvas width.
    "! @parameter height | (sap.ui.core.CSSSize) Canvas height.
    "! @parameter style  | (string) Inline CSS style.
    METHODS html_canvas
      IMPORTING
        id            TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        style         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.NotificationList</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.NotificationList. Inherits sap.m.List.
    "!
    "! @parameter footertext             | (string) Footer text.
    "! @parameter growing                | (boolean) Enable growing. Default: false.
    "! @parameter growingdirection       | (sap.m.ListGrowingDirection) Downwards | Upwards. Default: Downwards.
    "! @parameter growingscrolltoload    | (boolean) Trigger growing on scroll. Default: false.
    "! @parameter growingthreshold       | (int) Items per growing chunk. Default: 20.
    "! @parameter growingtriggertext     | (string) Custom "More" button text.
    "! @parameter headerlevel            | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: Auto.
    "! @parameter headertext             | (string) Header text.
    "! @parameter includeiteminselection | (boolean) Click item to select. Default: false.
    "! @parameter inset                  | (boolean) Indent the container. Default: false.
    "! @parameter keyboardmode           | (sap.m.ListKeyboardMode) Navigation | Edit. Default: Navigation.
    "! @parameter mode                   | (sap.m.ListMode) Selection mode. Default: None.
    "! @parameter modeanimationon        | (boolean) Animate mode change. Default: true.
    "! @parameter multiselectmode        | (sap.m.MultiSelectMode) Default | ClearAll | SelectAll. Default: Default.
    "! @parameter nodatatext             | (string) Empty-state text.
    "! @parameter rememberselections     | (boolean) Persist selections. Default: true.
    "! @parameter shownodata             | (boolean) Show empty-state text. Default: true.
    "! @parameter showseparators         | (sap.m.ListSeparators) All | Inner | None. Default: All.
    "! @parameter showunread             | (boolean) Activate unread indicator. Default: false.
    "! @parameter sticky                 | (sap.m.Sticky[]) Sticky areas.
    "! @parameter swipedirection         | (sap.m.SwipeDirection) Both | RightToLeft | LeftToRight. Default: Both.
    "! @parameter visible                | (boolean) Whether visible. Default: true.
    "! @parameter width                  | (sap.ui.core.CSSSize) Width.
    "! @parameter beforeopencontextmenu  | (event) Fired before the context menu opens.
    "! @parameter delete                 | (event) Fired when an item is deleted.
    "! @parameter growingfinished        | (event) DEPRECATED since 1.16.3 - use `updateFinished`.
    "! @parameter growingstarted         | (event) DEPRECATED since 1.16.3 - use `updateStarted`.
    "! @parameter itempress              | (event) Fired when an item is pressed.
    "! @parameter select                 | (event) DEPRECATED since 1.16 - use `selectionChange`.
    "! @parameter selectionchange        | (event) Fired when selection changes.
    "! @parameter swipe                  | (event) Fired on swipe.
    "! @parameter updatefinished         | (event) Fired when the data update finished.
    "! @parameter updatestarted          | (event) Fired when the data update started.
    METHODS notification_list
      IMPORTING
        id                     TYPE clike OPTIONAL
        class                  TYPE clike OPTIONAL
        footertext             TYPE clike OPTIONAL
        growing                TYPE clike OPTIONAL
        growingdirection       TYPE clike OPTIONAL
        growingscrolltoload    TYPE clike OPTIONAL
        growingthreshold       TYPE clike OPTIONAL
        growingtriggertext     TYPE clike OPTIONAL
        headerlevel            TYPE clike OPTIONAL
        headertext             TYPE clike OPTIONAL
        includeiteminselection TYPE clike OPTIONAL
        inset                  TYPE clike OPTIONAL
        keyboardmode           TYPE clike OPTIONAL
        mode                   TYPE clike OPTIONAL
        modeanimationon        TYPE clike OPTIONAL
        multiselectmode        TYPE clike OPTIONAL
        nodatatext             TYPE clike OPTIONAL
        rememberselections     TYPE clike OPTIONAL
        shownodata             TYPE clike OPTIONAL
        showseparators         TYPE clike OPTIONAL
        showunread             TYPE clike OPTIONAL
        sticky                 TYPE clike OPTIONAL
        swipedirection         TYPE clike OPTIONAL
        visible                TYPE clike OPTIONAL
        width                  TYPE clike OPTIONAL
        beforeopencontextmenu  TYPE clike OPTIONAL
        delete                 TYPE clike OPTIONAL
        growingfinished        TYPE clike OPTIONAL
        growingstarted         TYPE clike OPTIONAL
        itempress              TYPE clike OPTIONAL
        select                 TYPE clike OPTIONAL
        selectionchange        TYPE clike OPTIONAL
        swipe                  TYPE clike OPTIONAL
        updatefinished         TYPE clike OPTIONAL
        updatestarted          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.NotificationListGroup</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.NotificationListGroup.
    "!
    "! @parameter autopriority                  | (boolean) Auto-derive priority from items. Default: true.
    "! @parameter collapsed                     | (boolean) Whether the group is collapsed. Default: false.
    "! @parameter enablecollapsebuttonwhenempty | (boolean) Render collapse button even when empty. Default: false.
    "! @parameter highlight                     | (sap.ui.core.MessageType | IndicationColor) Default: None.
    "! @parameter highlighttext                 | (string) Custom accessibility text for highlight.
    "! @parameter navigated                     | (boolean) Marked as navigated. Default: false.
    "! @parameter priority                      | (sap.ui.core.Priority) None | Low | Medium | High. Default: None.
    "! @parameter selected                      | (boolean) Selected state. Default: false.
    "! @parameter showbuttons                   | (boolean) Show action buttons. Default: true.
    "! @parameter showclosebutton               | (boolean) Show close button. Default: true.
    "! @parameter showemptygroup                | (boolean) Render group when empty. Default: false.
    "! @parameter showitemscounter              | (boolean) Show items counter. Default: true.
    "! @parameter title                         | (string) Group title.
    "! @parameter type                          | (sap.m.ListType) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter unread                        | (boolean) Unread state. Default: false.
    "! @parameter visible                       | (boolean) Whether visible. Default: true.
    "! @parameter oncollapse                    | (event) Fired when the collapsed state changes.
    METHODS notification_list_group
      IMPORTING
        id                            TYPE clike OPTIONAL
        autopriority                  TYPE clike OPTIONAL
        collapsed                     TYPE clike OPTIONAL
        enablecollapsebuttonwhenempty TYPE clike OPTIONAL
        highlight                     TYPE clike OPTIONAL
        highlighttext                 TYPE clike OPTIONAL
        navigated                     TYPE clike OPTIONAL
        priority                      TYPE clike OPTIONAL
        selected                      TYPE clike OPTIONAL
        showbuttons                   TYPE clike OPTIONAL
        showclosebutton               TYPE clike OPTIONAL
        showemptygroup                TYPE clike OPTIONAL
        showitemscounter              TYPE clike OPTIONAL
        title                         TYPE clike OPTIONAL
        type                          TYPE clike OPTIONAL
        unread                        TYPE clike OPTIONAL
        visible                       TYPE clike OPTIONAL
        class                         TYPE clike OPTIONAL
        oncollapse                    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.NotificationListItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.NotificationListItem.
    "!
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    "! @parameter authoravatarcolor  | (sap.m.AvatarColor) Avatar background colour. Default: Accent6.
    "! @parameter authorinitials     | (string) Initials when no picture is set.
    "! @parameter description        | (string) Description text.
    "! @parameter hideshowmorebutton | (boolean) Hide the "Show More" button. Default: false.
    "! @parameter truncate           | (boolean) Truncate the text. Default: true.
    "! @parameter authorname         | (string) Author name.
    "! @parameter authorpicture      | (sap.ui.core.URI) Author picture URI.
    "! @parameter counter            | (int) Counter badge value.
    "! @parameter datetime           | (string) Timestamp text.
    "! @parameter highlight          | (sap.ui.core.MessageType | IndicationColor) Default: None.
    "! @parameter highlighttext      | (string) Custom accessibility text for highlight.
    "! @parameter navigated          | (boolean) Marked as navigated. Default: false.
    "! @parameter priority           | (sap.ui.core.Priority) None | Low | Medium | High. Default: None.
    "! @parameter selected           | (boolean) Selected state. Default: false.
    "! @parameter showbuttons        | (boolean) Show action buttons. Default: true.
    "! @parameter showclosebutton    | (boolean) Show close button. Default: true.
    "! @parameter title              | (string) Title text.
    "! @parameter type               | (sap.m.ListType) Inactive | Active | Detail | Navigation | DetailAndActive. Default: Inactive.
    "! @parameter unread             | (boolean) Unread state. Default: false.
    "! @parameter close              | (event) Fired when the close button is pressed.
    "! @parameter detailpress        | (event, ListItemBase) Fired when the detail icon is pressed.
    "! @parameter press              | (event, ListItemBase) Fired when the item is activated.
    METHODS notification_list_item
      IMPORTING
        id                 TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        authoravatarcolor  TYPE clike OPTIONAL
        authorinitials     TYPE clike OPTIONAL
        description        TYPE clike OPTIONAL
        hideshowmorebutton TYPE clike OPTIONAL
        truncate           TYPE clike OPTIONAL
        authorname         TYPE clike OPTIONAL
        authorpicture      TYPE clike OPTIONAL
        counter            TYPE clike OPTIONAL
        datetime           TYPE clike OPTIONAL
        highlight          TYPE clike OPTIONAL
        highlighttext      TYPE clike OPTIONAL
        navigated          TYPE clike OPTIONAL
        priority           TYPE clike OPTIONAL
        selected           TYPE clike OPTIONAL
        showbuttons        TYPE clike OPTIONAL
        showclosebutton    TYPE clike OPTIONAL
        title              TYPE clike OPTIONAL
        type               TYPE clike OPTIONAL
        unread             TYPE clike OPTIONAL
        close              TYPE clike OPTIONAL
        detailpress        TYPE clike OPTIONAL
        press              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.Wizard</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Wizard.
    "!
    "! @parameter backgrounddesign   | (sap.m.PageBackgroundDesign) Standard | Solid | Transparent | List. Default: Standard.
    "! @parameter busy               | (boolean) Busy state. Default: false.
    "! @parameter busyindicatordelay | (int) Busy indicator delay in ms. Default: 1000.
    "! @parameter busyindicatorsize  | (sap.ui.core.BusyIndicatorSize) Small | Medium | Large | Auto.
    "! @parameter enablebranching    | (boolean) Enable branching wizard. Default: false. Since 1.32.
    "! @parameter fieldgroupids      | (string[]) Field group ids.
    "! @parameter finishbuttontext   | (string) Text on the "Review" / finish button. Default: "Review".
    "! @parameter height             | (sap.ui.core.CSSSize) Height. Default: 100%.
    "! @parameter rendermode         | (sap.m.WizardRenderMode) Scroll | Page. Default: Scroll. Since 1.105.
    "! @parameter shownextbutton     | (boolean) Show "Next" button. Default: true. Since 1.110.
    "! @parameter steptitlelevel     | (sap.ui.core.TitleLevel) Auto | H1..H6. Default: H3.
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    "! @parameter width              | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter complete           | (event) Fired when the wizard is completed.
    "! @parameter navigationchange   | (event) Fired when the user navigates between steps.
    "! @parameter stepactivate       | (event) Fired when a step is activated.
    METHODS wizard
      IMPORTING
        id                 TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        backgrounddesign   TYPE clike OPTIONAL
        busy               TYPE clike OPTIONAL
        busyindicatordelay TYPE clike OPTIONAL
        busyindicatorsize  TYPE clike OPTIONAL
        enablebranching    TYPE clike OPTIONAL
        fieldgroupids      TYPE clike OPTIONAL
        finishbuttontext   TYPE clike OPTIONAL
        height             TYPE clike OPTIONAL
        rendermode         TYPE clike OPTIONAL
        shownextbutton     TYPE clike OPTIONAL
        steptitlelevel     TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        width              TYPE clike OPTIONAL
        complete           TYPE clike OPTIONAL
        navigationchange   TYPE clike OPTIONAL
        stepactivate       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.WizardStep</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.WizardStep.
    "!
    "! @parameter busy               | (boolean) Busy state. Default: false.
    "! @parameter busyindicatordelay | (int) Busy indicator delay in ms. Default: 1000.
    "! @parameter busyindicatorsize  | (sap.ui.core.BusyIndicatorSize) Size of busy indicator.
    "! @parameter fieldgroupids      | (string[]) Field group ids.
    "! @parameter icon               | (sap.ui.core.URI) Step icon.
    "! @parameter optional           | (boolean) Mark step as optional. Default: false. Since 1.54. (ABAP keyword - prefix `!`).
    "! @parameter title              | (string) Step title.
    "! @parameter validated          | (boolean) Whether the step is validated. Default: true.
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    "! @parameter activate           | (event) Fired when the step is activated.
    "! @parameter subsequentsteps    | (sap.ui.core.ID[]) Possible next steps (branching mode).
    "! @parameter nextstep           | (sap.ui.core.ID) Id of the next step.
    "! @parameter complete           | (event) Fired when the step is completed.
    METHODS wizard_step
      IMPORTING
        id                 TYPE clike OPTIONAL
        busy               TYPE clike OPTIONAL
        busyindicatordelay TYPE clike OPTIONAL
        busyindicatorsize  TYPE clike OPTIONAL
        fieldgroupids      TYPE clike OPTIONAL
        icon               TYPE clike OPTIONAL
        !optional          TYPE clike OPTIONAL
        title              TYPE clike OPTIONAL
        validated          TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        activate           TYPE clike OPTIONAL
        subsequentsteps    TYPE clike OPTIONAL
        nextstep           TYPE clike OPTIONAL
        complete           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">template:repeat directive</p>
    "!
    "! @parameter list | (string) Binding path of the list to iterate over.
    "! @parameter var  | (string) Variable name for the current item.
    METHODS template_repeat
      IMPORTING
        list          TYPE clike OPTIONAL
        var           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">XMLPreprocessor template-with directive</p>
    "!
    "! @parameter path   | (string) Binding path scoped under `var`.
    "! @parameter helper | (string) Optional helper module name.
    "! @parameter var    | (string) Variable name introduced.
    METHODS template_with
      IMPORTING
        path          TYPE clike OPTIONAL
        helper        TYPE clike OPTIONAL
        var           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">XMLPreprocessor template-if directive</p>
    "!
    "! @parameter test | (string) Boolean condition expression.
    METHODS template_if
      IMPORTING
        test          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">XMLPreprocessor template-then directive</p>
    METHODS template_then
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">XMLPreprocessor template-else directive</p>
    METHODS template_else
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">template:elseif directive</p>
    "!
    "! @parameter test | (string) Boolean condition expression.
    METHODS template_elseif
      IMPORTING
        test          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.gantt.simple.Relationship</p>
    "!
    "! @parameter shapeid     | (string) Relationship shape id.
    "! @parameter type        | (sap.gantt.simple.RelationshipType) FinishToStart | FinishToFinish | StartToStart | StartToFinish. Default: FinishToStart.
    "! @parameter successor   | (string) Successor shape id.
    "! @parameter predecessor | (string) Predecessor shape id.
    METHODS relationship
      IMPORTING
        shapeid       TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        successor     TYPE clike OPTIONAL
        predecessor   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `relationships`</p>
    METHODS relationships
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `noData`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS no_data
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `lines`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS lines
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.Line</p>
    "!
    "! @parameter arroworientation | (sap.suite.ui.commons.networkgraph.LineArrowOrientation) ToStart | ToEnd | None. Default: ToEnd.
    "! @parameter arrowposition    | (sap.suite.ui.commons.networkgraph.LineArrowPosition) Start | Middle | End. Default: End.
    "! @parameter description      | (string) Hover description.
    "! @parameter from             | (string) Source node key.
    "! @parameter linetype         | (sap.suite.ui.commons.networkgraph.LineType) Solid | Dashed | Dotted. Default: Solid.
    "! @parameter selected         | (boolean) Selected state. Default: false.
    "! @parameter status           | (string) Status colour token.
    "! @parameter stretchtocenter  | (boolean) Stretch line to centre. Default: false.
    "! @parameter title            | (string) Title shown next to the line.
    "! @parameter to               | (string) Target node key.
    "! @parameter visible          | (boolean) Whether visible. Default: true.
    "! @parameter press            | (event) Fired on click.
    "! @parameter hover            | (event) Fired on hover.
    METHODS line
      IMPORTING
        id               TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        arroworientation TYPE clike OPTIONAL
        arrowposition    TYPE clike OPTIONAL
        description      TYPE clike OPTIONAL
        from             TYPE clike OPTIONAL
        linetype         TYPE clike OPTIONAL
        selected         TYPE clike OPTIONAL
        status           TYPE clike OPTIONAL
        stretchtocenter  TYPE clike OPTIONAL
        title            TYPE clike OPTIONAL
        to               TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        press            TYPE clike OPTIONAL
        hover            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `groups`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS groups
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.Group</p>
    "!
    "! @parameter collapsed           | (boolean) Collapsed state. Default: false.
    "! @parameter description         | (string) Group description.
    "! @parameter headercheckboxstate | (boolean) Header checkbox state.
    "! @parameter icon                | (sap.ui.core.URI) Icon URI.
    "! @parameter key                 | (string) Group key.
    "! @parameter minwidth            | (int) Minimum width in px.
    "! @parameter parentgroupkey      | (string) Parent group key (for nested groups).
    "! @parameter status              | (string) Status colour token.
    "! @parameter title               | (string) Group title.
    "! @parameter visible             | (boolean) Whether visible. Default: true.
    "! @parameter collapseexpand      | (event) Fired when expand state changes.
    "! @parameter headercheckboxpress | (event) Fired when the header checkbox is pressed.
    "! @parameter showdetail          | (event) Fired when the detail button is pressed.
    METHODS group
      IMPORTING
        id                  TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        collapsed           TYPE clike OPTIONAL
        description         TYPE clike OPTIONAL
        headercheckboxstate TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
        key                 TYPE clike OPTIONAL
        minwidth            TYPE clike OPTIONAL
        parentgroupkey      TYPE clike OPTIONAL
        status              TYPE clike OPTIONAL
        title               TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        collapseexpand      TYPE clike OPTIONAL
        headercheckboxpress TYPE clike OPTIONAL
        showdetail          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.Graph</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.networkgraph.Graph.
    "!
    "! @parameter layout          | (string) Layout algorithm aggregation - use one of the layout builder methods.
    "! @parameter height          | (sap.ui.core.CSSSize) Height. Default: 100%.
    "! @parameter width           | (sap.ui.core.CSSSize) Width. Default: 100%.
    "! @parameter nodes           | (binding path) Aggregation of `Node`.
    "! @parameter lines           | (binding path) Aggregation of `Line`.
    "! @parameter groups          | (binding path) Aggregation of `Group`.
    "! @parameter backgroundcolor | (sap.ui.core.CSSColor) Background colour.
    "! @parameter backgroundimage | (sap.ui.core.URI) Background image URI.
    "! @parameter nodatatext      | (string) Empty-state text.
    "! @parameter orientation     | (sap.suite.ui.commons.networkgraph.Orientation) LeftRight | TopBottom. Default: LeftRight.
    "! @parameter rendertype      | (sap.suite.ui.commons.networkgraph.RenderType) Html | Svg. Default: Html.
    "! @parameter enablewheelzoom | (boolean) Enable zoom via mouse wheel. Default: true.
    "! @parameter enablezoom      | (boolean) Enable zooming. Default: true.
    "! @parameter nodata          | (binding path) Aggregation `noData` for a custom empty-state control.
    "! @parameter visible         | (boolean) Whether visible. Default: true.
    "! @parameter afterlayouting  | (event) Fired after layouting completes.
    "! @parameter beforelayouting | (event) Fired before layouting starts.
    "! @parameter failure         | (event) Fired on error.
    "! @parameter graphready      | (event) Fired when the graph is ready.
    "! @parameter search          | (event) Fired when search is triggered.
    "! @parameter searchsuggest   | (event) Fired during search-suggestion typing.
    "! @parameter selectionchange | (event) Fired when selection changes.
    "! @parameter zoomchanged     | (event) Fired when the zoom level changes.
    METHODS network_graph
      IMPORTING
        id              TYPE clike OPTIONAL
        class           TYPE clike OPTIONAL
        layout          TYPE clike OPTIONAL
        height          TYPE clike OPTIONAL
        width           TYPE clike OPTIONAL
        nodes           TYPE clike OPTIONAL
        lines           TYPE clike OPTIONAL
        groups          TYPE clike OPTIONAL
        backgroundcolor TYPE clike OPTIONAL
        backgroundimage TYPE clike OPTIONAL
        nodatatext      TYPE clike OPTIONAL
        orientation     TYPE clike OPTIONAL
        rendertype      TYPE clike OPTIONAL
        enablewheelzoom TYPE clike OPTIONAL
        enablezoom      TYPE clike OPTIONAL
        nodata          TYPE clike OPTIONAL
        visible         TYPE clike OPTIONAL
        afterlayouting  TYPE clike OPTIONAL
        beforelayouting TYPE clike OPTIONAL
        failure         TYPE clike OPTIONAL
        graphready      TYPE clike OPTIONAL
        search          TYPE clike OPTIONAL
        searchsuggest   TYPE clike OPTIONAL
        selectionchange TYPE clike OPTIONAL
        zoomchanged     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `layoutAlgorithm`</p>
    METHODS layout_algorithm
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.layout.LayeredLayout</p>
    "!
    "! @parameter linespacingfactor | (float) Line-spacing factor. Default: 1.
    "! @parameter mergeedges        | (boolean) Merge parallel edges. Default: false.
    "! @parameter nodeplacement     | (sap.suite.ui.commons.networkgraph.NodePlacement) BrandesKoepf | LinearSegments | Simple | NetworkSimplex. Default: BrandesKoepf.
    "! @parameter nodespacing       | (int) Spacing between nodes in px. Default: 100.
    METHODS layered_layout
      IMPORTING
        id                TYPE clike OPTIONAL
        class             TYPE clike OPTIONAL
        linespacingfactor TYPE clike OPTIONAL
        mergeedges        TYPE clike OPTIONAL
        nodeplacement     TYPE clike OPTIONAL
        nodespacing       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.layout.ForceBasedLayout</p>
    "!
    "! @parameter alpha           | (float) Initial alpha. Default: 0.1.
    "! @parameter charge           | (int) Charge strength. Default: -120.
    "! @parameter friction         | (float) Friction factor. Default: 0.9.
    "! @parameter maximumduration  | (int) Maximum layout duration in ms.
    METHODS force_based_layout
      IMPORTING
        id              TYPE clike OPTIONAL
        class           TYPE clike OPTIONAL
        alpha           TYPE clike OPTIONAL
        charge          TYPE clike OPTIONAL
        friction        TYPE clike OPTIONAL
        maximumduration TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.layout.ForceDirectedLayout</p>
    "!
    "! @parameter cooldownstep            | (float) Cooldown step factor.
    "! @parameter initialtemperature      | (float) Initial simulation temperature.
    "! @parameter maxiterations           | (int) Maximum simulation iterations.
    "! @parameter maxtime                 | (int) Maximum simulation time in ms.
    "! @parameter optimaldistanceconstant | (float) Optimal-distance constant.
    "! @parameter staticnodes             | (string[]) Keys of nodes that must remain at fixed positions.
    METHODS force_directed_layout
      IMPORTING
        id                      TYPE clike OPTIONAL
        class                   TYPE clike OPTIONAL
        cooldownstep            TYPE clike OPTIONAL
        initialtemperature      TYPE clike OPTIONAL
        maxiterations           TYPE clike OPTIONAL
        maxtime                 TYPE clike OPTIONAL
        optimaldistanceconstant TYPE clike OPTIONAL
        staticnodes             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.layout.NoopLayout</p>
    METHODS noop_layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.layout.SwimLaneChainLayout</p>
    METHODS swim_lane_chain_layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.layout.TwoColumnsLayout</p>
    METHODS two_columns_layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `attributes`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS attributes
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.ElementAttribute</p>
    "!
    "! @parameter label | (string) Attribute label.
    "! @parameter value | (string) Attribute value.
    METHODS element_attribute
      IMPORTING
        ns            TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `actionButtons`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS action_buttons
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.networkgraph.ActionButton</p>
    "!
    "! @parameter enabled  | (boolean) Whether enabled. Default: true.
    "! @parameter icon     | (sap.ui.core.URI) Icon URI.
    "! @parameter position | (sap.suite.ui.commons.networkgraph.ActionButtonPosition) Top | Right | Bottom | Left.
    "! @parameter title    | (string) Title text.
    "! @parameter press    | (event) Fired when pressed.
    METHODS action_button
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        position      TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.Routes</p>
    "!
    "! @parameter items | (binding path) Aggregation of `Route`.
    METHODS routes
      IMPORTING
        id            TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `legendArea`</p>
    METHODS legend_area
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.Legend.LegendItem</p>
    "!
    "! @parameter text  | (string) Item text.
    "! @parameter color | (sap.ui.core.CSSColor) Item colour.
    METHODS legenditem
      IMPORTING
        id            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.Legend</p>
    "!
    "! @parameter items   | (binding path) Aggregation of `legenditem`.
    "! @parameter caption | (string) Legend caption.
    METHODS legend
      IMPORTING
        id            TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
        caption       TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.vbm.Route</p>
    "!
    "! @parameter position    | (string) Geo coordinates list.
    "! @parameter routetype   | (sap.ui.vbm.RouteType) Solid | Dashed | Dotted.
    "! @parameter linedash    | (string) SVG dash pattern.
    "! @parameter color       | (sap.ui.core.CSSColor) Stroke colour.
    "! @parameter colorborder | (sap.ui.core.CSSColor) Border colour.
    "! @parameter linewidth   | (string) Stroke width.
    METHODS route
      IMPORTING
        id            TYPE clike OPTIONAL
        position      TYPE clike OPTIONAL
        routetype     TYPE clike OPTIONAL
        linedash      TYPE clike OPTIONAL
        color         TYPE clike OPTIONAL
        colorborder   TYPE clike OPTIONAL
        linewidth     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.Menu</p>
    "!
    "! @parameter visible    | (boolean) Whether visible. Default: true.
    "! @parameter afterclose | (event) Fired after the menu has closed.
    "! @parameter beforeopen | (event) Fired before the menu opens.
    METHODS column_menu
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        afterclose    TYPE clike OPTIONAL
        beforeopen    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.Item</p>
    "!
    "! @parameter icon               | (sap.ui.core.URI) Icon URI.
    "! @parameter label              | (string) Item label.
    "! @parameter resetbuttonenabled | (boolean) Enable the "Reset" button. Default: true.
    "! @parameter showcancelbutton   | (boolean) Show the "Cancel" button. Default: true.
    "! @parameter showconfirmbutton  | (boolean) Show the "Confirm" button. Default: true.
    "! @parameter showresetbutton    | (boolean) Show the "Reset" button. Default: true.
    "! @parameter visible            | (boolean) Whether visible. Default: true.
    "! @parameter cancel             | (event) Fired when the cancel button is pressed.
    "! @parameter confirm            | (event) Fired when the confirm button is pressed.
    "! @parameter reset              | (event) Fired when the reset button is pressed.
    METHODS column_menu_item
      IMPORTING
        id                 TYPE clike OPTIONAL
        class              TYPE clike OPTIONAL
        icon               TYPE clike OPTIONAL
        label              TYPE clike OPTIONAL
        resetbuttonenabled TYPE clike OPTIONAL
        showcancelbutton   TYPE clike OPTIONAL
        showconfirmbutton  TYPE clike OPTIONAL
        showresetbutton    TYPE clike OPTIONAL
        visible            TYPE clike OPTIONAL
        cancel             TYPE clike OPTIONAL
        confirm            TYPE clike OPTIONAL
        reset              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.ActionItem</p>
    "!
    "! @parameter icon    | (sap.ui.core.URI) Icon URI.
    "! @parameter label   | (string) Item label.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    "! @parameter press   | (event) Fired when pressed.
    METHODS column_menu_action_item
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickAction</p>
    "!
    "! @parameter category | (sap.m.table.columnmenu.Category) Generic | Sort | Filter | Group | Aggregate.
    "! @parameter label    | (string) Action label.
    "! @parameter visible  | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_action
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        category      TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickActionItem</p>
    "!
    "! @parameter key     | (string) Item key.
    "! @parameter label   | (string) Item label.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_action_item
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickGroup</p>
    "!
    "! @parameter change  | (event) Fired when the grouping changes.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_group
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickGroupItem</p>
    "!
    "! @parameter grouped | (boolean) Whether the column is grouped. Default: false.
    "! @parameter key     | (string) Item key.
    "! @parameter label   | (string) Item label.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_group_item
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        grouped       TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickSort</p>
    "!
    "! @parameter change  | (event) Fired when the sort changes.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_sort
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickSortItem</p>
    "!
    "! @parameter sortorder | (sap.ui.core.SortOrder) None | Ascending | Descending. Default: None.
    "! @parameter key       | (string) Item key.
    "! @parameter label     | (string) Item label.
    "! @parameter visible   | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_sort_item
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        sortorder     TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickTotal</p>
    "!
    "! @parameter change  | (event) Fired when the total changes.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_total
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.table.columnmenu.QuickTotalItem</p>
    "!
    "! @parameter totaled | (boolean) Whether the column is totalled. Default: false.
    "! @parameter key     | (string) Item key.
    "! @parameter label   | (string) Item label.
    "! @parameter visible | (boolean) Whether visible. Default: true.
    METHODS column_menu_quick_total_item
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        totaled       TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.MicroProcessFlow</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.MicroProcessFlow.
    "!
    "! @parameter arialabel  | (string) ARIA label.
    "! @parameter width      | (sap.ui.core.CSSSize) Width.
    "! @parameter rendertype | (sap.suite.ui.commons.MicroProcessFlowRenderType) Standard | Wider. Default: Standard.
    METHODS micro_process_flow
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        arialabel     TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        rendertype    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.MicroProcessFlowItem</p>
    "!
    "! @parameter icon             | (sap.ui.core.URI) Step icon.
    "! @parameter key              | (string) Step key.
    "! @parameter showintermediary | (boolean) Render intermediary indicator. Default: false.
    "! @parameter showseparator    | (boolean) Render separator after the item. Default: true.
    "! @parameter state            | (sap.suite.ui.commons.LoadState | sap.m.ValueColor) Step state.
    "! @parameter stepwidth        | (sap.ui.core.CSSSize) Step width.
    "! @parameter title            | (string) Step title.
    "! @parameter press            | (event) Fired when the step is pressed.
    METHODS micro_process_flow_item
      IMPORTING
        id               TYPE clike OPTIONAL
        class            TYPE clike OPTIONAL
        icon             TYPE clike OPTIONAL
        key              TYPE clike OPTIONAL
        showintermediary TYPE clike OPTIONAL
        showseparator    TYPE clike OPTIONAL
        state            TYPE clike OPTIONAL
        stepwidth        TYPE clike OPTIONAL
        title            TYPE clike OPTIONAL
        press            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `intermediary`</p>
    METHODS intermediary
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `customControl`</p>
    METHODS custom_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.statusindicator.ResponsiveScale</p>
    "!
    "! @parameter tickmarksbetweenlabels | (int) Number of tick marks between labels. Default: 5.
    METHODS responsive_scale
      IMPORTING
        id                     TYPE clike OPTIONAL
        class                  TYPE clike OPTIONAL
        tickmarksbetweenlabels TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.statusindicator.StatusIndicator</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.statusindicator.StatusIndicator.
    "!
    "! @parameter height        | (sap.ui.core.CSSSize) Height.
    "! @parameter labelposition | (sap.suite.ui.commons.statusindicator.LabelPositionType) Top | Right | Bottom | Left | None. Default: Right.
    "! @parameter showlabel     | (boolean) Show the label. Default: false.
    "! @parameter size          | (sap.suite.ui.commons.statusindicator.SizeType) None | XS | S | M | L | XL. Default: None.
    "! @parameter value         | (float) Status value (0..100).
    "! @parameter viewbox       | (string) Custom SVG viewBox.
    "! @parameter width         | (sap.ui.core.CSSSize) Width.
    "! @parameter visible       | (boolean) Whether visible. Default: true.
    "! @parameter press         | (event) Fired when pressed.
    METHODS status_indicator
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        labelposition TYPE clike OPTIONAL
        showlabel     TYPE clike OPTIONAL
        size          TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        viewbox       TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `propertyThresholds`</p>
    METHODS property_thresholds
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.statusindicator.PropertyThreshold</p>
    "!
    "! @parameter fillcolor | (sap.ui.core.CSSColor) Fill colour for this threshold band.
    "! @parameter tovalue   | (float) Upper bound of this band.
    "! @parameter arialabel | (string) ARIA label.
    "! @parameter visible   | (boolean) Whether visible. Default: true.
    METHODS property_threshold
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        fillcolor     TYPE clike OPTIONAL
        tovalue       TYPE clike OPTIONAL
        arialabel     TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.statusindicator.ShapeGroup</p>
    METHODS shape_group
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.statusindicator.LibraryShape</p>
    "!
    "! @parameter animationonchange   | (boolean) Animate value transitions. Default: true.
    "! @parameter definition          | (string) Shape definition reference.
    "! @parameter fillcolor           | (sap.ui.core.CSSColor) Fill colour.
    "! @parameter fillingangle        | (int) Fill angle in degrees.
    "! @parameter fillingdirection    | (sap.suite.ui.commons.statusindicator.FillingDirectionType) Left | Right | Up | Down.
    "! @parameter fillingtype         | (sap.suite.ui.commons.statusindicator.FillingType) Linear | Radial.
    "! @parameter height              | (sap.ui.core.CSSSize) Shape height.
    "! @parameter horizontalalignment | (sap.ui.core.HorizontalAlign) Begin | End | Left | Right | Center.
    "! @parameter shapeid             | (string) Library shape id.
    "! @parameter strokecolor         | (sap.ui.core.CSSColor) Stroke colour.
    "! @parameter strokewidth         | (string) Stroke width.
    "! @parameter verticalalignment   | (sap.ui.core.VerticalAlign) Bottom | Inherit | Middle | Top.
    "! @parameter visible             | (boolean) Whether visible. Default: true.
    "! @parameter width               | (sap.ui.core.CSSSize) Shape width.
    "! @parameter x                   | (int) X position.
    "! @parameter y                   | (int) Y position.
    "! @parameter aftershapeloaded    | (event) Fired after the shape SVG has loaded.
    METHODS library_shape
      IMPORTING
        id                  TYPE clike OPTIONAL
        class               TYPE clike OPTIONAL
        animationonchange   TYPE clike OPTIONAL
        definition          TYPE clike OPTIONAL
        fillcolor           TYPE clike OPTIONAL
        fillingangle        TYPE clike OPTIONAL
        fillingdirection    TYPE clike OPTIONAL
        fillingtype         TYPE clike OPTIONAL
        height              TYPE clike OPTIONAL
        horizontalalignment TYPE clike OPTIONAL
        shapeid             TYPE clike OPTIONAL
        strokecolor         TYPE clike OPTIONAL
        strokewidth         TYPE clike OPTIONAL
        verticalalignment   TYPE clike OPTIONAL
        visible             TYPE clike OPTIONAL
        width               TYPE clike OPTIONAL
        x                   TYPE clike OPTIONAL
        y                   TYPE clike OPTIONAL
        aftershapeloaded    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.TileInfo</p>
    "!
    "! @parameter backgroundcolor | (sap.ui.core.CSSColor) Background colour.
    "! @parameter bordercolor     | (sap.ui.core.CSSColor) Border colour.
    "! @parameter src             | (sap.ui.core.URI) Image URI.
    "! @parameter text            | (string) Tile text.
    "! @parameter textcolor       | (sap.ui.core.CSSColor) Text colour.
    METHODS tile_info
      IMPORTING
        id              TYPE clike OPTIONAL
        class           TYPE clike OPTIONAL
        backgroundcolor TYPE clike OPTIONAL
        bordercolor     TYPE clike OPTIONAL
        src             TYPE clike OPTIONAL
        text            TYPE clike OPTIONAL
        textcolor       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `badge`</p>
    METHODS badge
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.tnt.SideNavigation</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.tnt.SideNavigation.
    "!
    "! @parameter selectedkey | (string) Two-way bound selected item key.
    METHODS side_navigation
      IMPORTING
        id            TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        selectedkey   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.tnt.NavigationList</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.tnt.NavigationList.
    METHODS navigation_list
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.tnt.NavigationListItem</p>
    "!
    "! @parameter text   | (string) Item text.
    "! @parameter icon   | (sap.ui.core.URI) Icon URI.
    "! @parameter select | (event) Fired when the item is selected.
    "! @parameter href   | (sap.ui.core.URI) Link href (renders item as `a`).
    "! @parameter key    | (string) Item key.
    METHODS navigation_list_item
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        select        TYPE clike OPTIONAL
        href          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `fixedItem`</p>
    METHODS fixed_item
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.viz.ui5.controls.VizFrame</p>
    "!
    "! Modern charting frame. See https://ui5.sap.com/#/api/sap.viz.ui5.controls.VizFrame.
    "! Note: legacy `sap.viz.ui5.*` charts (Bar, Bubble, Pie, Line, ...) are deprecated since 1.32 - use VizFrame.
    "!
    "! @parameter legendvisible     | (boolean) Show the legend. Default: true.
    "! @parameter vizcustomizations | (object) Custom viz options.
    "! @parameter vizproperties     | (object) Custom viz properties.
    "! @parameter vizscales         | (object[]) Custom viz scales.
    "! @parameter viztype           | (string) Chart type, e.g. `column` | `line` | `pie` | `bar` | `area` | `scatter` | `combination`.
    "! @parameter height            | (sap.ui.core.CSSSize) Height.
    "! @parameter width             | (sap.ui.core.CSSSize) Width.
    "! @parameter uiconfig          | (object) UI configuration. Default: `{applicationSet:'fiori'}`.
    "! @parameter visible           | (boolean) Whether visible. Default: true.
    "! @parameter selectdata        | (event) Fired when data points are selected.
    METHODS viz_frame
      IMPORTING
        id                TYPE clike OPTIONAL
        legendvisible     TYPE clike OPTIONAL
        vizcustomizations TYPE clike OPTIONAL
        vizproperties     TYPE clike OPTIONAL
        vizscales         TYPE clike OPTIONAL
        viztype           TYPE clike OPTIONAL
        height            TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        uiconfig          TYPE clike DEFAULT `{applicationSet:'fiori'}`
        visible           TYPE clike OPTIONAL
        selectdata        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `dataset`</p>
    METHODS viz_dataset
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.viz.ui5.data.FlattenedDataset</p>
    "!
    "! @parameter data | (binding path) Data binding path.
    METHODS viz_flattened_dataset
      IMPORTING
        data          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `dimensions`</p>
    METHODS viz_dimensions
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.viz.ui5.data.DimensionDefinition</p>
    "!
    "! @parameter axis         | (int) Axis index (1, 2 or 3).
    "! @parameter datatype     | (string) Data type, e.g. `string`, `number`, `date`.
    "! @parameter displayvalue | (string) Display value path.
    "! @parameter identity     | (string) Identity path.
    "! @parameter name         | (string) Dimension name.
    "! @parameter sorter       | (object) Custom sorter.
    "! @parameter value        | (string) Value binding path (e.g. `{Country}`).
    METHODS viz_dimension_definition
      IMPORTING
        axis          TYPE clike OPTIONAL
        datatype      TYPE clike OPTIONAL
        displayvalue  TYPE clike OPTIONAL
        identity      TYPE clike OPTIONAL
        name          TYPE clike OPTIONAL
        sorter        TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `measures`</p>
    METHODS viz_measures
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.viz.ui5.data.MeasureDefinition</p>
    "!
    "! @parameter format   | (string) Number format pattern.
    "! @parameter group    | (int) Measure group index.
    "! @parameter identity | (string) Identity path.
    "! @parameter name     | (string) Measure name.
    "! @parameter range    | (object) Value range.
    "! @parameter unit     | (string) Unit binding path.
    "! @parameter value    | (string) Value binding path (e.g. `{Sales}`).
    METHODS viz_measure_definition
      IMPORTING
        format        TYPE clike OPTIONAL
        group         TYPE clike OPTIONAL
        identity      TYPE clike OPTIONAL
        name          TYPE clike OPTIONAL
        range         TYPE clike OPTIONAL
        unit          TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `feeds`</p>
    METHODS viz_feeds
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.viz.ui5.controls.common.feeds.FeedItem</p>
    "!
    "! @parameter uid    | (string) Feed identifier (e.g. `categoryAxis`, `valueAxis`, `color`).
    "! @parameter type   | (string) Feed type (Dimension | Measure).
    "! @parameter values | (string[]) Names of dimensions/measures bound to this feed.
    METHODS viz_feed_item
      IMPORTING
        id            TYPE clike OPTIONAL
        uid           TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        values        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.comp.smartmultiinput.SmartMultiInput</p>
    "!
    "! Smart multi-input that derives suggestions / value help from OData.
    "! See https://ui5.sap.com/#/api/sap.ui.comp.smartmultiinput.SmartMultiInput.
    "!
    "! @parameter entityset            | (string) OData entity set.
    "! @parameter value                | (string) Two-way bound value.
    "! @parameter supportranges        | (boolean) Allow ranges in tokens. Default: false.
    "! @parameter enableodataselect    | (boolean) Enable OData $select optimisation. Default: false.
    "! @parameter requestatleastfields | (string) Comma-separated list of fields to always request.
    "! @parameter singletokenmode      | (boolean) Allow only one token. Default: false.
    "! @parameter supportmultiselect   | (boolean) Allow multi-selection. Default: true.
    "! @parameter textseparator        | (string) Token text separator.
    "! @parameter textlabel            | (string) Custom text label.
    "! @parameter tooltiplabel         | (string) Custom tooltip label.
    "! @parameter textineditmodesource | (sap.ui.comp.smartfield.TextInEditModeSource) None | NavigationProperty | ValueList. Default: None.
    "! @parameter mandatory            | (boolean) Required field marker. Default: false.
    "! @parameter maxlength            | (int) Maximum number of characters. Default: 0 = unlimited.
    METHODS smart_multi_input
      IMPORTING
        id                   TYPE clike OPTIONAL
        entityset            TYPE clike OPTIONAL
        value                TYPE clike OPTIONAL
        supportranges        TYPE clike DEFAULT `false`
        enableodataselect    TYPE clike DEFAULT `false`
        requestatleastfields TYPE clike OPTIONAL
        singletokenmode      TYPE clike DEFAULT `false`
        supportmultiselect   TYPE clike DEFAULT `true`
        textseparator        TYPE clike OPTIONAL
        textlabel            TYPE clike OPTIONAL
        tooltiplabel         TYPE clike OPTIONAL
        textineditmodesource TYPE clike DEFAULT `None`
        mandatory            TYPE clike DEFAULT `false`
        maxlength            TYPE clike DEFAULT `0`
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.RowSettings</p>
    "!
    "! @parameter highlight     | (sap.ui.core.MessageType | sap.ui.core.IndicationColor) Default: None.
    "! @parameter highlighttext | (string) Custom accessibility text for highlight.
    "! @parameter navigated     | (boolean) Navigated state. Default: false.
    METHODS row_settings
      IMPORTING
        highlight     TYPE clike OPTIONAL
        highlighttext TYPE clike OPTIONAL
        navigated     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.imageeditor.ImageEditor</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.imageeditor.ImageEditor.
    "!
    "! @parameter customshapesrc        | (sap.ui.core.URI) Custom crop shape SVG URI.
    "! @parameter keepcropaspectratio   | (boolean) Lock crop aspect ratio. Default: false.
    "! @parameter keepresizeaspectratio | (boolean) Lock resize aspect ratio. Default: false.
    "! @parameter scalecroparea         | (boolean) Scale crop area when resizing. Default: false.
    "! @parameter customshapesrctype    | (sap.suite.ui.commons.imageeditor.CustomShapeSrcType) Svg | Url. Default: Svg.
    "! @parameter src                   | (sap.ui.core.URI) Image URI to edit.
    METHODS image_editor
      IMPORTING
        id                    TYPE clike OPTIONAL
        customshapesrc        TYPE clike OPTIONAL
        keepcropaspectratio   TYPE clike OPTIONAL
        keepresizeaspectratio TYPE clike OPTIONAL
        scalecroparea         TYPE clike OPTIONAL
        customshapesrctype    TYPE clike OPTIONAL
        src                   TYPE clike OPTIONAL
          PREFERRED PARAMETER src
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.suite.ui.commons.imageeditor.ImageEditorContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.suite.ui.commons.imageeditor.ImageEditorContainer.
    "!
    "! @parameter enabledbuttons | (sap.suite.ui.commons.imageeditor.ImageEditorContainerButton[]) Buttons to render.
    "! @parameter mode           | (sap.suite.ui.commons.imageeditor.ImageEditorMode) Default | Crop | Resize.
    METHODS image_editor_container
      IMPORTING
        id             TYPE clike OPTIONAL
        enabledbuttons TYPE clike OPTIONAL
        mode           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

  PROTECTED SECTION.
    DATA mv_name     TYPE string.
    DATA mv_ns       TYPE string.
    DATA mt_prop     TYPE SORTED TABLE OF z2ui5_if_types=>ty_s_name_value WITH NON-UNIQUE KEY n.

    DATA mt_ns       TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
    DATA mo_root     TYPE REF TO z2ui5_cl_xml_view.
    DATA mo_previous TYPE REF TO z2ui5_cl_xml_view.
    DATA mo_parent   TYPE REF TO z2ui5_cl_xml_view.
    DATA mt_child    TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view WITH DEFAULT KEY.

    "! <p class="shorttext synchronized" lang="en">Internal recursion that flattens the XML tree into a stri...</p>
    "!
    "! @parameter ct_parts | Output - serialised XML fragments.
    METHODS xml_get_parts
      CHANGING
        ct_parts TYPE string_table.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_xml_view IMPLEMENTATION.

  METHOD actions.
    result = _generic( name = `actions`
                       ns   = ns ).
  ENDMETHOD.

  METHOD action_button.
    DATA temp1 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-n = `id`.
    temp2-v = id.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `class`.
    temp2-v = class.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `icon`.
    temp2-v = icon.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `position`.
    temp2-v = position.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `title`.
    temp2-v = title.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `press`.
    temp2-v = press.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `enabled`.
    temp2-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp2 INTO TABLE temp1.
    result = _generic( name   = `ActionButton`
                       ns     = `networkgraph`
                       t_prop = temp1 ).
  ENDMETHOD.

  METHOD action_buttons.
    DATA temp3 TYPE string.
    CASE ns.
      WHEN ``.
        temp3 = `networkgraph`.
      WHEN OTHERS.
        temp3 = ns.
    ENDCASE.
    result = _generic( name = `actionButtons`
                       ns   = temp3 ).
  ENDMETHOD.

  METHOD action_sheet.
    DATA temp4 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp5 LIKE LINE OF temp4.
    CLEAR temp4.

    temp5-n = `id`.
    temp5-v = id.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `class`.
    temp5-v = class.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `cancelbuttontext`.
    temp5-v = cancelbuttontext.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `placement`.
    temp5-v = placement.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `showCancelButton`.
    temp5-v = showcancelbutton.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `title`.
    temp5-v = title.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `afterClose`.
    temp5-v = afterclose.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `afterOpen`.
    temp5-v = afteropen.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `beforeClose`.
    temp5-v = beforeclose.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `beforeOpen`.
    temp5-v = beforeopen.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `cancelButtonPress`.
    temp5-v = cancelbuttonpress.
    INSERT temp5 INTO TABLE temp4.
    temp5-n = `visible`.
    temp5-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp5 INTO TABLE temp4.
    result = _generic(
                 name   = `ActionSheet`
                 t_prop = temp4 ).
  ENDMETHOD.

  METHOD additional_content.
    result = _generic( `additionalContent` ).
  ENDMETHOD.

  METHOD additional_numbers.
    result = _generic( `additionalNumbers` ).
  ENDMETHOD.

  METHOD analytic_map.

    DATA temp6 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp7 LIKE LINE OF temp6.
    CLEAR temp6.

    temp7-n = `id`.
    temp7-v = id.
    INSERT temp7 INTO TABLE temp6.
    temp7-n = `initialPosition`.
    temp7-v = initialposition.
    INSERT temp7 INTO TABLE temp6.
    temp7-n = `lassoSelection`.
    temp7-v = lassoselection.
    INSERT temp7 INTO TABLE temp6.
    temp7-n = `height`.
    temp7-v = height.
    INSERT temp7 INTO TABLE temp6.
    temp7-n = `visible`.
    temp7-v = visible.
    INSERT temp7 INTO TABLE temp6.
    temp7-n = `width`.
    temp7-v = width.
    INSERT temp7 INTO TABLE temp6.
    temp7-n = `initialZoom`.
    temp7-v = initialzoom.
    INSERT temp7 INTO TABLE temp6.
    result = _generic( name   = `AnalyticMap`
                       ns     = `vbm`
                       t_prop = temp6 ).

  ENDMETHOD.

  METHOD appointments.
    result = _generic( `appointments` ).
  ENDMETHOD.

  METHOD appointment_items.
    result = _generic( `appointmentItems` ).
  ENDMETHOD.

  METHOD area_micro_chart.
    DATA temp8 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp9 LIKE LINE OF temp8.
    result = me.

    CLEAR temp8.

    temp9-n = `colorPalette`.
    temp9-v = colorpalette.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `press`.
    temp9-v = press.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `size`.
    temp9-v = size.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `height`.
    temp9-v = height.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `maxXValue`.
    temp9-v = maxxvalue.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `maxYValue`.
    temp9-v = maxyvalue.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `minXValue`.
    temp9-v = minxvalue.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `minYValue`.
    temp9-v = minyvalue.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `view`.
    temp9-v = view.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `alignContent`.
    temp9-v = aligncontent.
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `hideOnNoData`.
    temp9-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `showLabel`.
    temp9-v = z2ui5_cl_util=>boolean_abap_2_json( showlabel ).
    INSERT temp9 INTO TABLE temp8.
    temp9-n = `width`.
    temp9-v = width.
    INSERT temp9 INTO TABLE temp8.
    _generic( name   = `AreaMicroChart`
              ns     = `mchart`
              t_prop = temp8 ).
  ENDMETHOD.

  METHOD attributes.
    DATA temp10 TYPE string.
    CASE ns.
      WHEN ``.
        temp10 = `networkgraph`.
      WHEN OTHERS.
        temp10 = ns.
    ENDCASE.
    result = _generic( name = `attributes`
                       ns   = temp10 ).
  ENDMETHOD.

  METHOD avatar.
    DATA temp11 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp12 LIKE LINE OF temp11.
    result = me.

    CLEAR temp11.

    temp12-n = `id`.
    temp12-v = id.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `src`.
    temp12-v = src.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `class`.
    temp12-v = class.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `ariaHasPopup`.
    temp12-v = ariahaspopup.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `backgroundColor`.
    temp12-v = backgroundcolor.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `badgeIcon`.
    temp12-v = badgeicon.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `badgeTooltip`.
    temp12-v = badgetooltip.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `badgeValueState`.
    temp12-v = badgevaluestate.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `customDisplaySize`.
    temp12-v = customdisplaysize.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `customFontSize`.
    temp12-v = customfontsize.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `displayShape`.
    temp12-v = displayshape.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `fallbackIcon`.
    temp12-v = fallbackicon.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `imageFitType`.
    temp12-v = imagefittype.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `initials`.
    temp12-v = initials.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `showBorder`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( showborder ).
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `decorative`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( decorative ).
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `enabled`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `displaySize`.
    temp12-v = displaysize.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `press`.
    temp12-v = press.
    INSERT temp12 INTO TABLE temp11.
    _generic( name   = `Avatar`
              ns     = ns
              t_prop = temp11 ).
  ENDMETHOD.

  METHOD avatar_group.
    DATA temp13 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp14 LIKE LINE OF temp13.
    CLEAR temp13.

    temp14-n = `id`.
    temp14-v = id.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `avatarCustomDisplaySize`.
    temp14-v = avatarcustomdisplaysize.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `avatarCustomDispavatarCustomFontSizelaySize`.
    temp14-v = avatarcustomfontsize.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `avatarDisplaySize`.
    temp14-v = avatardisplaysize.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `blocked`.
    temp14-v = z2ui5_cl_util=>boolean_abap_2_json( blocked ).
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `busy`.
    temp14-v = z2ui5_cl_util=>boolean_abap_2_json( busy ).
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `busyIndicatorDelay`.
    temp14-v = busyindicatordelay.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `busyIndicatorSize`.
    temp14-v = busyindicatorsize.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `fieldGroupIds`.
    temp14-v = fieldgroupids.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `groupType`.
    temp14-v = grouptype.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `visible`.
    temp14-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `tooltip`.
    temp14-v = tooltip.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `items`.
    temp14-v = items.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `press`.
    temp14-v = press.
    INSERT temp14 INTO TABLE temp13.
    result = _generic( name   = `AvatarGroup`
                       ns     = `f`
                       t_prop = temp13 ).
  ENDMETHOD.

  METHOD avatar_group_item.
    DATA temp15 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp16 LIKE LINE OF temp15.
    result = me.

    CLEAR temp15.

    temp16-n = `id`.
    temp16-v = id.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `busy`.
    temp16-v = busy.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `busyIndicatorDelay`.
    temp16-v = busyindicatordelay.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `busyIndicatorSize`.
    temp16-v = busyindicatorsize.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `fallbackIcon`.
    temp16-v = fallbackicon.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `fieldGroupIds`.
    temp16-v = fieldgroupids.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `initials`.
    temp16-v = initials.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `src`.
    temp16-v = src.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `visible`.
    temp16-v = visible.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `tooltip`.
    temp16-v = tooltip.
    INSERT temp16 INTO TABLE temp15.
    _generic( name   = `AvatarGroupItem`
              ns     = `f`
              t_prop = temp15 ).
  ENDMETHOD.

  METHOD axis_time_strategy.
    result = _generic( name = `axisTimeStrategy`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD badge.
    result = _generic( `badge` ).
  ENDMETHOD.

  METHOD badge_custom_data.
    DATA temp17 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp18 LIKE LINE OF temp17.
    result = me.

    CLEAR temp17.

    temp18-n = `key`.
    temp18-v = key.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `value`.
    temp18-v = value.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `visible`.
    temp18-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp18 INTO TABLE temp17.
    _generic( name   = `BadgeCustomData`
              t_prop = temp17 ).
  ENDMETHOD.

  METHOD bar.
    result = _generic( `Bar` ).
  ENDMETHOD.

  METHOD barcode_scanner_button.
    DATA temp19 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp20 LIKE LINE OF temp19.
    CLEAR temp19.

    temp20-n = `id`.
    temp20-v = id.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `scanSuccess`.
    temp20-v = scansuccess.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `scanFail`.
    temp20-v = scanfail.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `inputLiveUpdate`.
    temp20-v = inputliveupdate.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `dialogTitle`.
    temp20-v = dialogtitle.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `disableBarcodeInputDialog`.
    temp20-v = disablebarcodeinputdialog.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `frameRate`.
    temp20-v = framerate.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `keepCameraScan`.
    temp20-v = keepcamerascan.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `preferFrontCamera`.
    temp20-v = preferfrontcamera.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `provideFallback`.
    temp20-v = providefallback.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `width`.
    temp20-v = width.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `zoom`.
    temp20-v = zoom.
    INSERT temp20 INTO TABLE temp19.
    result = _generic( name   = `BarcodeScannerButton`
                       ns     = `ndc`
                       t_prop = temp19 ).
  ENDMETHOD.

  METHOD bars.
    result = _generic( name = `bars`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD base_rectangle.

    DATA temp21 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp22 LIKE LINE OF temp21.
    CLEAR temp21.

    temp22-n = `time`.
    temp22-v = time.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `endTime`.
    temp22-v = endtime.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `selectable`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( selectable ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `selectedFill`.
    temp22-v = selectedfill.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `fill`.
    temp22-v = fill.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `height`.
    temp22-v = height.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `title`.
    temp22-v = title.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `animationSettings`.
    temp22-v = animationsettings.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `alignShape`.
    temp22-v = alignshape.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `color`.
    temp22-v = color.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `fontSize`.
    temp22-v = fontsize.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `connectable`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( connectable ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `fontFamily`.
    temp22-v = fontfamily.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `filter`.
    temp22-v = filter.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `transform`.
    temp22-v = transform.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `countInBirdEye`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( countinbirdeye ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `fontWeight`.
    temp22-v = fontweight.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `showTitle`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( showtitle ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `selected`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `resizable`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( resizable ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `horizontalTextAlignment`.
    temp22-v = horizontaltextalignment.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `shapeId`.
    temp22-v = shapeid.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `highlighted`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( highlighted ).
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `highlightable`.
    temp22-v = z2ui5_cl_util=>boolean_abap_2_json( highlightable ).
    INSERT temp22 INTO TABLE temp21.
    result = _generic(
        name   = `BaseRectangle`
        ns     = `gantt`
        t_prop = temp21 ).
  ENDMETHOD.

  METHOD begin_button.

    result = _generic( `beginButton` ).

  ENDMETHOD.

  METHOD begin_column_pages.

    result = _generic( name = `beginColumnPages`
                       ns   = `f` ).

  ENDMETHOD.

  METHOD blocks.
    result = _generic( name = `blocks`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD more_blocks.
    result = _generic( name = `moreBlocks`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD block_layout.
    DATA temp23 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp24 LIKE LINE OF temp23.
    CLEAR temp23.

    temp24-n = `background`.
    temp24-v = background.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `id`.
    temp24-v = id.
    INSERT temp24 INTO TABLE temp23.
    result = _generic( name   = `BlockLayout`
                       ns     = `layout`
                       t_prop = temp23 ).
  ENDMETHOD.

  METHOD block_layout_cell.
    DATA temp25 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.
    CLEAR temp25.

    temp26-n = `backgroundColorSet`.
    temp26-v = backgroundcolorset.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `backgroundColorShade`.
    temp26-v = backgroundcolorshade.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `title`.
    temp26-v = title.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `titleAlignment`.
    temp26-v = titlealignment.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `width`.
    temp26-v = width.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `class`.
    temp26-v = class.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `id`.
    temp26-v = id.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `titleLevel`.
    temp26-v = titlelevel.
    INSERT temp26 INTO TABLE temp25.
    result = _generic( name   = `BlockLayoutCell`
                       ns     = `layout`
                       t_prop = temp25 ).
  ENDMETHOD.

  METHOD block_layout_row.
    DATA temp27 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp28 LIKE LINE OF temp27.
    CLEAR temp27.

    temp28-n = `rowColorSet`.
    temp28-v = rowcolorset.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `id`.
    temp28-v = id.
    INSERT temp28 INTO TABLE temp27.
    result = _generic( name   = `BlockLayoutRow`
                       ns     = `layout`
                       t_prop = temp27 ).
  ENDMETHOD.

  METHOD bullet_micro_chart.
    DATA temp29 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp30 LIKE LINE OF temp29.
    result = me.

    CLEAR temp29.

    temp30-n = `actualValueLabel`.
    temp30-v = actualvaluelabel.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `press`.
    temp30-v = press.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `size`.
    temp30-v = size.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `height`.
    temp30-v = height.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `width`.
    temp30-v = width.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `deltaValueLabel`.
    temp30-v = deltavaluelabel.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `maxValue`.
    temp30-v = maxvalue.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `minValue`.
    temp30-v = minvalue.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `mode`.
    temp30-v = mode.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `scale`.
    temp30-v = scale.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `targetValue`.
    temp30-v = targetvalue.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `targetValueLabel`.
    temp30-v = targetvaluelabel.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `scaleColor`.
    temp30-v = scalecolor.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `hideOnNoData`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `showActualValue`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( showactualvalue ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `showActualValueInDeltaMode`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( savidm ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `showDeltaValue`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( showdeltavalue ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `showTargetValue`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( showtargetvalue ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `showThresholds`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( showthresholds ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `showValueMarker`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluemarker ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `smallRangeAllowed`.
    temp30-v = z2ui5_cl_util=>boolean_abap_2_json( smallrangeallowed ).
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `forecastValue`.
    temp30-v = forecastvalue.
    INSERT temp30 INTO TABLE temp29.
    _generic(
        name   = `BulletMicroChart`
        ns     = `mchart`
        t_prop = temp29 ).
  ENDMETHOD.

  METHOD busy_indicator.
    DATA temp31 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp32 LIKE LINE OF temp31.
    CLEAR temp31.

    temp32-n = `id`.
    temp32-v = id.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `class`.
    temp32-v = class.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `customIcon`.
    temp32-v = customicon.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `customIconHeight`.
    temp32-v = customiconheight.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `customIconRotationSpeed`.
    temp32-v = customiconrotationspeed.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `customIconWidth`.
    temp32-v = customiconwidth.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `size`.
    temp32-v = size.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `text`.
    temp32-v = text.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `textDirection`.
    temp32-v = textdirection.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `customIconDensityAware`.
    temp32-v = z2ui5_cl_util=>boolean_abap_2_json( customicondensityaware ).
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `visible`.
    temp32-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp32 INTO TABLE temp31.
    result = _generic(
        name   = `BusyIndicator`
        t_prop = temp31 ).
  ENDMETHOD.

  METHOD button.
    DATA temp33 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp34 LIKE LINE OF temp33.

    result = me.

    CLEAR temp33.

    temp34-n = `press`.
    temp34-v = press.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `text`.
    temp34-v = text.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `enabled`.
    temp34-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `visible`.
    temp34-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `iconDensityAware`.
    temp34-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `iconFirst`.
    temp34-v = z2ui5_cl_util=>boolean_abap_2_json( iconfirst ).
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `icon`.
    temp34-v = icon.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `type`.
    temp34-v = type.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `id`.
    temp34-v = id.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `width`.
    temp34-v = width.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `tooltip`.
    temp34-v = tooltip.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `textDirection`.
    temp34-v = textdirection.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `accessibleRole`.
    temp34-v = accessiblerole.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `activeIcon`.
    temp34-v = activeicon.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `ariaHasPopup`.
    temp34-v = ariahaspopup.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `class`.
    temp34-v = class.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `ariaLabelledBy`.
    temp34-v = arialabelledby.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `ariaDescribedBy`.
    temp34-v = ariadescribedby.
    INSERT temp34 INTO TABLE temp33.
    _generic( name   = `Button`
              ns     = ns
              t_prop = temp33 ).
  ENDMETHOD.

  METHOD buttons.
    result = _generic( `buttons` ).
  ENDMETHOD.

  METHOD calendar_appointment.
    DATA temp35 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp36 LIKE LINE OF temp35.
    CLEAR temp35.

    temp36-n = `startDate`.
    temp36-v = startdate.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `endDate`.
    temp36-v = enddate.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `icon`.
    temp36-v = icon.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `title`.
    temp36-v = title.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `text`.
    temp36-v = text.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `type`.
    temp36-v = type.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `key`.
    temp36-v = key.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `selected`.
    temp36-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `tentative`.
    temp36-v = z2ui5_cl_util=>boolean_abap_2_json( tentative ).
    INSERT temp36 INTO TABLE temp35.
    result = _generic(
        name   = `CalendarAppointment`
        ns     = `u`
        t_prop = temp35 ).
  ENDMETHOD.

  METHOD calendar_legend_item.
    DATA temp37 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp38 LIKE LINE OF temp37.
    CLEAR temp37.

    temp38-n = `text`.
    temp38-v = text.
    INSERT temp38 INTO TABLE temp37.
    temp38-n = `type`.
    temp38-v = type.
    INSERT temp38 INTO TABLE temp37.
    temp38-n = `tooltip`.
    temp38-v = tooltip.
    INSERT temp38 INTO TABLE temp37.
    temp38-n = `color`.
    temp38-v = color.
    INSERT temp38 INTO TABLE temp37.
    result = _generic( name   = `CalendarLegendItem`
                       t_prop = temp37 ).

  ENDMETHOD.

  METHOD card.
    DATA temp39 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp40 LIKE LINE OF temp39.
    CLEAR temp39.

    temp40-n = `id`.
    temp40-v = id.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `class`.
    temp40-v = class.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `headerPosition`.
    temp40-v = headerposition.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `height`.
    temp40-v = height.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `width`.
    temp40-v = width.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `visible`.
    temp40-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp40 INTO TABLE temp39.
    result = _generic( name   = `Card`
                       ns     = `f`
                       t_prop = temp39 ).
  ENDMETHOD.

  METHOD card_header.
    DATA temp41 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp42 LIKE LINE OF temp41.
    CLEAR temp41.

    temp42-n = `id`.
    temp42-v = id.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `class`.
    temp42-v = class.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `dataTimestamp`.
    temp42-v = datatimestamp.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconAlt`.
    temp42-v = iconalt.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconBackgroundColor`.
    temp42-v = iconbackgroundcolor.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconDisplayShape`.
    temp42-v = icondisplayshape.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconInitials`.
    temp42-v = iconinitials.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconSize`.
    temp42-v = iconsize.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconSrc`.
    temp42-v = iconsrc.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `statusText`.
    temp42-v = statustext.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `statusVisible`.
    temp42-v = statusvisible.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `subtitle`.
    temp42-v = subtitle.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `subtitleMaxLines`.
    temp42-v = subtitlemaxlines.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `title`.
    temp42-v = title.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `press`.
    temp42-v = press.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `titleMaxLines`.
    temp42-v = titlemaxlines.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `iconVisible`.
    temp42-v = z2ui5_cl_util=>boolean_abap_2_json( iconvisible ).
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `visible`.
    temp42-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp42 INTO TABLE temp41.
    result = _generic( name   = `Header`
                       ns     = `card`
                       t_prop = temp41 ).
  ENDMETHOD.

  METHOD carousel.

    DATA temp43 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp44 LIKE LINE OF temp43.
    CLEAR temp43.

    temp44-n = `loop`.
    temp44-v = z2ui5_cl_util=>boolean_abap_2_json( loop ).
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `class`.
    temp44-v = class.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `height`.
    temp44-v = height.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `id`.
    temp44-v = id.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `arrowsPlacement`.
    temp44-v = arrowsplacement.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `backgroundDesign`.
    temp44-v = backgrounddesign.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `pageIndicatorBackgroundDesign`.
    temp44-v = pageindicatorbackgrounddesign.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `pageIndicatorBorderDesign`.
    temp44-v = pageindicatorborderdesign.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `pageIndicatorPlacement`.
    temp44-v = pageindicatorplacement.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `width`.
    temp44-v = width.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `showPageIndicator`.
    temp44-v = showpageindicator.
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `visible`.
    temp44-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp44 INTO TABLE temp43.
    temp44-n = `pages`.
    temp44-v = pages.
    INSERT temp44 INTO TABLE temp43.
    result = _generic( name   = `Carousel`
                       t_prop = temp43 ).

  ENDMETHOD.

  METHOD carousel_layout.
    DATA temp45 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp46 LIKE LINE OF temp45.
    CLEAR temp45.

    temp46-n = `visiblePagesCount`.
    temp46-v = visiblepagescount.
    INSERT temp46 INTO TABLE temp45.
    result = _generic( name   = `CarouselLayout`
                       t_prop = temp45 ).
  ENDMETHOD.

  METHOD cells.
    result = _generic( `cells` ).
  ENDMETHOD.

  METHOD checkbox.
    DATA temp47 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp48 LIKE LINE OF temp47.

    result = me.

    CLEAR temp47.

    temp48-n = `text`.
    temp48-v = text.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `id`.
    temp48-v = id.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `class`.
    temp48-v = class.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `name`.
    temp48-v = name.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `selected`.
    temp48-v = selected.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `textAlign`.
    temp48-v = textalign.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `textDirection`.
    temp48-v = textdirection.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `valueState`.
    temp48-v = valuestate.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `width`.
    temp48-v = width.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `activeHandling`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( activehandling ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `enabled`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `visible`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `displayOnly`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `editable`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `partiallySelected`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( partiallyselected ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `useEntireWidth`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( useentirewidth ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `wrapping`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `select`.
    temp48-v = select.
    INSERT temp48 INTO TABLE temp47.
    temp48-n = `required`.
    temp48-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp48 INTO TABLE temp47.
    _generic( name   = `CheckBox`
              t_prop = temp47 ).
  ENDMETHOD.

  METHOD code_editor.
    DATA temp49 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp50 LIKE LINE OF temp49.
    result = me.

    CLEAR temp49.

    temp50-n = `value`.
    temp50-v = value.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `type`.
    temp50-v = type.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `editable`.
    temp50-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `height`.
    temp50-v = height.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `width`.
    temp50-v = width.
    INSERT temp50 INTO TABLE temp49.
    _generic( name   = `CodeEditor`
              ns     = `editor`
              t_prop = temp49 ).
  ENDMETHOD.

  METHOD column.
    DATA temp51 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp52 LIKE LINE OF temp51.
    CLEAR temp51.

    temp52-n = `width`.
    temp52-v = width.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `minScreenWidth`.
    temp52-v = minscreenwidth.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `hAlign`.
    temp52-v = halign.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `headerMenu`.
    temp52-v = headermenu.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `autoPopinWidth`.
    temp52-v = autopopinwidth.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `vAlign`.
    temp52-v = valign.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `importance`.
    temp52-v = importance.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `mergeFunctionName`.
    temp52-v = mergefunctionname.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `popinDisplay`.
    temp52-v = popindisplay.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `sortIndicator`.
    temp52-v = sortindicator.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `styleClass`.
    temp52-v = styleclass.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `id`.
    temp52-v = id.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `class`.
    temp52-v = class.
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `mergeDuplicates`.
    temp52-v = z2ui5_cl_util=>boolean_abap_2_json( mergeduplicates ).
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `visible`.
    temp52-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp52 INTO TABLE temp51.
    temp52-n = `demandPopin`.
    temp52-v = z2ui5_cl_util=>boolean_abap_2_json( demandpopin ).
    INSERT temp52 INTO TABLE temp51.
    result = _generic(
                 name   = `Column`
                 t_prop = temp51 ).
  ENDMETHOD.

  METHOD columns.
    result = _generic( ns   = ns
                       name = `columns` ).
  ENDMETHOD.

  METHOD column_element_data.
    DATA temp53 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp54 LIKE LINE OF temp53.
    CLEAR temp53.

    temp54-n = `cellsLarge`.
    temp54-v = cellslarge.
    INSERT temp54 INTO TABLE temp53.
    temp54-n = `cellsSmall`.
    temp54-v = cellssmall.
    INSERT temp54 INTO TABLE temp53.
    result = _generic( name   = `ColumnElementData`
                       ns     = `form`
                       t_prop = temp53 ).
  ENDMETHOD.

  METHOD column_list_item.
    DATA temp55 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp56 LIKE LINE OF temp55.
    CLEAR temp55.

    temp56-n = `vAlign`.
    temp56-v = valign.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `id`.
    temp56-v = id.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `selected`.
    temp56-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `unread`.
    temp56-v = z2ui5_cl_util=>boolean_abap_2_json( unread ).
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `visible`.
    temp56-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `type`.
    temp56-v = type.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `counter`.
    temp56-v = counter.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `highlight`.
    temp56-v = highlight.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `highlightText`.
    temp56-v = highlighttext.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `detailPress`.
    temp56-v = detailpress.
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `navigated`.
    temp56-v = z2ui5_cl_util=>boolean_abap_2_json( navigated ).
    INSERT temp56 INTO TABLE temp55.
    temp56-n = `press`.
    temp56-v = press.
    INSERT temp56 INTO TABLE temp55.
    result = _generic( name   = `ColumnListItem`
                       t_prop = temp55 ).
  ENDMETHOD.

  METHOD action_list_item.
    DATA temp57 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp58 LIKE LINE OF temp57.
    CLEAR temp57.

    temp58-n = `id`.
    temp58-v = id.
    INSERT temp58 INTO TABLE temp57.
    temp58-n = `text`.
    temp58-v = text.
    INSERT temp58 INTO TABLE temp57.
    result = _generic( name   = `ActionListItem`
                       t_prop = temp57 ).
  ENDMETHOD.

  METHOD column_menu.
    DATA temp59 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp60 LIKE LINE OF temp59.
    CLEAR temp59.

    temp60-n = `id`.
    temp60-v = id.
    INSERT temp60 INTO TABLE temp59.
    temp60-n = `class`.
    temp60-v = class.
    INSERT temp60 INTO TABLE temp59.
    temp60-n = `afterClose`.
    temp60-v = afterclose.
    INSERT temp60 INTO TABLE temp59.
    temp60-n = `beforeOpen`.
    temp60-v = beforeopen.
    INSERT temp60 INTO TABLE temp59.
    temp60-n = `visible`.
    temp60-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp60 INTO TABLE temp59.
    result = _generic( name   = `Menu`
                       ns     = `columnmenu`
                       t_prop = temp59 ).
  ENDMETHOD.

  METHOD column_menu_action_item.
    DATA temp61 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp62 LIKE LINE OF temp61.
    CLEAR temp61.

    temp62-n = `id`.
    temp62-v = id.
    INSERT temp62 INTO TABLE temp61.
    temp62-n = `class`.
    temp62-v = class.
    INSERT temp62 INTO TABLE temp61.
    temp62-n = `icon`.
    temp62-v = icon.
    INSERT temp62 INTO TABLE temp61.
    temp62-n = `label`.
    temp62-v = label.
    INSERT temp62 INTO TABLE temp61.
    temp62-n = `press`.
    temp62-v = press.
    INSERT temp62 INTO TABLE temp61.
    temp62-n = `visible`.
    temp62-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp62 INTO TABLE temp61.
    result = _generic( name   = `ActionItem`
                       ns     = `columnmenu`
                       t_prop = temp61 ).
  ENDMETHOD.

  METHOD column_menu_item.
    DATA temp63 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp64 LIKE LINE OF temp63.
    CLEAR temp63.

    temp64-n = `id`.
    temp64-v = id.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `class`.
    temp64-v = class.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `icon`.
    temp64-v = icon.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `label`.
    temp64-v = label.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `cancel`.
    temp64-v = cancel.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `confirm`.
    temp64-v = confirm.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `reset`.
    temp64-v = reset.
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `resetButtonEnabled`.
    temp64-v = z2ui5_cl_util=>boolean_abap_2_json( resetbuttonenabled ).
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `showCancelButton`.
    temp64-v = z2ui5_cl_util=>boolean_abap_2_json( showcancelbutton ).
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `showConfirmButton`.
    temp64-v = z2ui5_cl_util=>boolean_abap_2_json( showconfirmbutton ).
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `showResetButton`.
    temp64-v = z2ui5_cl_util=>boolean_abap_2_json( showresetbutton ).
    INSERT temp64 INTO TABLE temp63.
    temp64-n = `visible`.
    temp64-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp64 INTO TABLE temp63.
    result = _generic( name   = `Item`
                       ns     = `columnmenu`
                       t_prop = temp63 ).
  ENDMETHOD.

  METHOD column_menu_quick_action.
    DATA temp65 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp66 LIKE LINE OF temp65.
    CLEAR temp65.

    temp66-n = `id`.
    temp66-v = id.
    INSERT temp66 INTO TABLE temp65.
    temp66-n = `class`.
    temp66-v = class.
    INSERT temp66 INTO TABLE temp65.
    temp66-n = `category`.
    temp66-v = category.
    INSERT temp66 INTO TABLE temp65.
    temp66-n = `label`.
    temp66-v = label.
    INSERT temp66 INTO TABLE temp65.
    temp66-n = `visible`.
    temp66-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp66 INTO TABLE temp65.
    result = _generic( name   = `QuickAction`
                       ns     = `columnmenu`
                       t_prop = temp65 ).
  ENDMETHOD.

  METHOD column_menu_quick_action_item.
    DATA temp67 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp68 LIKE LINE OF temp67.
    CLEAR temp67.

    temp68-n = `id`.
    temp68-v = id.
    INSERT temp68 INTO TABLE temp67.
    temp68-n = `class`.
    temp68-v = class.
    INSERT temp68 INTO TABLE temp67.
    temp68-n = `key`.
    temp68-v = key.
    INSERT temp68 INTO TABLE temp67.
    temp68-n = `label`.
    temp68-v = label.
    INSERT temp68 INTO TABLE temp67.
    temp68-n = `visible`.
    temp68-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp68 INTO TABLE temp67.
    result = _generic( name   = `QuickActionItem`
                       ns     = `columnmenu`
                       t_prop = temp67 ).
  ENDMETHOD.

  METHOD column_menu_quick_group.
    DATA temp69 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp70 LIKE LINE OF temp69.
    CLEAR temp69.

    temp70-n = `id`.
    temp70-v = id.
    INSERT temp70 INTO TABLE temp69.
    temp70-n = `class`.
    temp70-v = class.
    INSERT temp70 INTO TABLE temp69.
    temp70-n = `change`.
    temp70-v = change.
    INSERT temp70 INTO TABLE temp69.
    temp70-n = `visible`.
    temp70-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp70 INTO TABLE temp69.
    result = _generic( name   = `QuickGroup`
                       ns     = `columnmenu`
                       t_prop = temp69 ).
  ENDMETHOD.

  METHOD column_menu_quick_group_item.
    DATA temp71 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp72 LIKE LINE OF temp71.
    CLEAR temp71.

    temp72-n = `id`.
    temp72-v = id.
    INSERT temp72 INTO TABLE temp71.
    temp72-n = `class`.
    temp72-v = class.
    INSERT temp72 INTO TABLE temp71.
    temp72-n = `key`.
    temp72-v = key.
    INSERT temp72 INTO TABLE temp71.
    temp72-n = `label`.
    temp72-v = label.
    INSERT temp72 INTO TABLE temp71.
    temp72-n = `grouped`.
    temp72-v = z2ui5_cl_util=>boolean_abap_2_json( grouped ).
    INSERT temp72 INTO TABLE temp71.
    temp72-n = `visible`.
    temp72-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp72 INTO TABLE temp71.
    result = _generic( name   = `QuickGroupItem`
                       ns     = `columnmenu`
                       t_prop = temp71 ).
  ENDMETHOD.

  METHOD column_menu_quick_sort.
    DATA temp73 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp74 LIKE LINE OF temp73.
    CLEAR temp73.

    temp74-n = `id`.
    temp74-v = id.
    INSERT temp74 INTO TABLE temp73.
    temp74-n = `class`.
    temp74-v = class.
    INSERT temp74 INTO TABLE temp73.
    temp74-n = `change`.
    temp74-v = change.
    INSERT temp74 INTO TABLE temp73.
    temp74-n = `visible`.
    temp74-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp74 INTO TABLE temp73.
    result = _generic( name   = `QuickSort`
                       ns     = `columnmenu`
                       t_prop = temp73 ).
  ENDMETHOD.

  METHOD column_menu_quick_sort_item.
    DATA temp75 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp76 LIKE LINE OF temp75.
    CLEAR temp75.

    temp76-n = `id`.
    temp76-v = id.
    INSERT temp76 INTO TABLE temp75.
    temp76-n = `class`.
    temp76-v = class.
    INSERT temp76 INTO TABLE temp75.
    temp76-n = `key`.
    temp76-v = key.
    INSERT temp76 INTO TABLE temp75.
    temp76-n = `label`.
    temp76-v = label.
    INSERT temp76 INTO TABLE temp75.
    temp76-n = `sortOrder`.
    temp76-v = sortorder.
    INSERT temp76 INTO TABLE temp75.
    temp76-n = `visible`.
    temp76-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp76 INTO TABLE temp75.
    result = _generic( name   = `QuickSortItem`
                       ns     = `columnmenu`
                       t_prop = temp75 ).
  ENDMETHOD.

  METHOD column_menu_quick_total.
    DATA temp77 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp78 LIKE LINE OF temp77.
    CLEAR temp77.

    temp78-n = `id`.
    temp78-v = id.
    INSERT temp78 INTO TABLE temp77.
    temp78-n = `class`.
    temp78-v = class.
    INSERT temp78 INTO TABLE temp77.
    temp78-n = `change`.
    temp78-v = change.
    INSERT temp78 INTO TABLE temp77.
    temp78-n = `visible`.
    temp78-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp78 INTO TABLE temp77.
    result = _generic( name   = `QuickTotal`
                       ns     = `columnmenu`
                       t_prop = temp77 ).
  ENDMETHOD.

  METHOD column_menu_quick_total_item.
    DATA temp79 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp80 LIKE LINE OF temp79.
    CLEAR temp79.

    temp80-n = `id`.
    temp80-v = id.
    INSERT temp80 INTO TABLE temp79.
    temp80-n = `class`.
    temp80-v = class.
    INSERT temp80 INTO TABLE temp79.
    temp80-n = `key`.
    temp80-v = key.
    INSERT temp80 INTO TABLE temp79.
    temp80-n = `label`.
    temp80-v = label.
    INSERT temp80 INTO TABLE temp79.
    temp80-n = `totaled`.
    temp80-v = z2ui5_cl_util=>boolean_abap_2_json( totaled ).
    INSERT temp80 INTO TABLE temp79.
    temp80-n = `visible`.
    temp80-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp80 INTO TABLE temp79.
    result = _generic( name   = `QuickTotalItem`
                       ns     = `columnmenu`
                       t_prop = temp79 ).
  ENDMETHOD.

  METHOD column_micro_chart.
    DATA temp81 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp82 LIKE LINE OF temp81.
    result = me.

    CLEAR temp81.

    temp82-n = `width`.
    temp82-v = width.
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `press`.
    temp82-v = press.
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `size`.
    temp82-v = size.
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `alignContent`.
    temp82-v = aligncontent.
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `hideOnNoData`.
    temp82-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `allowColumnLabels`.
    temp82-v = z2ui5_cl_util=>boolean_abap_2_json( allowcolumnlabels ).
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `showBottomLabels`.
    temp82-v = z2ui5_cl_util=>boolean_abap_2_json( showbottomlabels ).
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `showTopLabels`.
    temp82-v = z2ui5_cl_util=>boolean_abap_2_json( showtoplabels ).
    INSERT temp82 INTO TABLE temp81.
    temp82-n = `height`.
    temp82-v = height.
    INSERT temp82 INTO TABLE temp81.
    _generic(
        name   = `ColumnMicroChart`
        ns     = `mchart`
        t_prop = temp81 ).
  ENDMETHOD.

  METHOD column_micro_chart_data.
    DATA temp83 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp84 LIKE LINE OF temp83.
    result = me.

    CLEAR temp83.

    temp84-n = `color`.
    temp84-v = color.
    INSERT temp84 INTO TABLE temp83.
    temp84-n = `displayValue`.
    temp84-v = displayvalue.
    INSERT temp84 INTO TABLE temp83.
    temp84-n = `label`.
    temp84-v = label.
    INSERT temp84 INTO TABLE temp83.
    temp84-n = `value`.
    temp84-v = value.
    INSERT temp84 INTO TABLE temp83.
    temp84-n = `press`.
    temp84-v = press.
    INSERT temp84 INTO TABLE temp83.
    _generic( name   = `ColumnMicroChartData`
              ns     = `mchart`
              t_prop = temp83 ).
  ENDMETHOD.

  METHOD combobox.
    DATA temp85 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp86 LIKE LINE OF temp85.
    CLEAR temp85.

    temp86-n = `showClearIcon`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `selectedKey`.
    temp86-v = selectedkey.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `items`.
    temp86-v = items.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `id`.
    temp86-v = id.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `class`.
    temp86-v = class.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `selectionchange`.
    temp86-v = selectionchange.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `selectedItem`.
    temp86-v = selecteditem.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `selectedItemId`.
    temp86-v = selecteditemid.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `name`.
    temp86-v = name.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `value`.
    temp86-v = value.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `valueState`.
    temp86-v = valuestate.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `valueStateText`.
    temp86-v = valuestatetext.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `textAlign`.
    temp86-v = textalign.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `showSecondaryValues`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `visible`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `showValueStateMessage`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `showButton`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( showbutton ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `required`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `editable`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `enabled`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `filterSecondaryValues`.
    temp86-v = z2ui5_cl_util=>boolean_abap_2_json( filtersecondaryvalues ).
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `width`.
    temp86-v = width.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `placeholder`.
    temp86-v = placeholder.
    INSERT temp86 INTO TABLE temp85.
    temp86-n = `change`.
    temp86-v = change.
    INSERT temp86 INTO TABLE temp85.
    result = _generic(
        name   = `ComboBox`
        t_prop = temp85 ).

  ENDMETHOD.

  METHOD comparison_micro_chart.
    DATA temp87 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp88 LIKE LINE OF temp87.
    CLEAR temp87.

    temp88-n = `colorPalette`.
    temp88-v = colorpalette.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `press`.
    temp88-v = press.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `size`.
    temp88-v = size.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `height`.
    temp88-v = height.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `maxValue`.
    temp88-v = maxvalue.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `minValue`.
    temp88-v = minvalue.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `scale`.
    temp88-v = scale.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `width`.
    temp88-v = width.
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `hideOnNoData`.
    temp88-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `shrinkable`.
    temp88-v = z2ui5_cl_util=>boolean_abap_2_json( shrinkable ).
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `visible`.
    temp88-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp88 INTO TABLE temp87.
    temp88-n = `view`.
    temp88-v = view.
    INSERT temp88 INTO TABLE temp87.
    result = _generic(
                 name   = `ComparisonMicroChart`
                 ns     = `mchart`
                 t_prop = temp87 ).
  ENDMETHOD.

  METHOD comparison_micro_chart_data.
    DATA temp89 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp90 LIKE LINE OF temp89.
    CLEAR temp89.

    temp90-n = `color`.
    temp90-v = color.
    INSERT temp90 INTO TABLE temp89.
    temp90-n = `press`.
    temp90-v = press.
    INSERT temp90 INTO TABLE temp89.
    temp90-n = `displayValue`.
    temp90-v = displayvalue.
    INSERT temp90 INTO TABLE temp89.
    temp90-n = `title`.
    temp90-v = title.
    INSERT temp90 INTO TABLE temp89.
    temp90-n = `value`.
    temp90-v = value.
    INSERT temp90 INTO TABLE temp89.
    result = _generic( name   = `ComparisonMicroChartData`
                       ns     = `mchart`
                       t_prop = temp89 ).
  ENDMETHOD.

  METHOD constructor.

  ENDMETHOD.

  METHOD container_content.

    DATA temp91 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp92 LIKE LINE OF temp91.
    CLEAR temp91.

    temp92-n = `id`.
    temp92-v = id.
    INSERT temp92 INTO TABLE temp91.
    temp92-n = `title`.
    temp92-v = title.
    INSERT temp92 INTO TABLE temp91.
    temp92-n = `icon`.
    temp92-v = icon.
    INSERT temp92 INTO TABLE temp91.
    result = _generic( name   = `ContainerContent`
                       ns     = `vk`
                       t_prop = temp91 ).

  ENDMETHOD.

  METHOD container_toolbar.

    DATA temp93 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp94 LIKE LINE OF temp93.
    CLEAR temp93.

    temp94-n = `showSearchButton`.
    temp94-v = showsearchbutton.
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `alignCustomContentToRight`.
    temp94-v = z2ui5_cl_util=>boolean_abap_2_json( aligncustomcontenttoright ).
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `findMode`.
    temp94-v = findmode.
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `infoOfSelectItems`.
    temp94-v = infoofselectitems.
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `findbuttonpress`.
    temp94-v = findbuttonpress.
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `showBirdEyeButton`.
    temp94-v = z2ui5_cl_util=>boolean_abap_2_json( showbirdeyebutton ).
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `showDisplayTypeButton`.
    temp94-v = z2ui5_cl_util=>boolean_abap_2_json( showdisplaytypebutton ).
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `showLegendButton`.
    temp94-v = z2ui5_cl_util=>boolean_abap_2_json( showlegendbutton ).
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `showSettingButton`.
    temp94-v = z2ui5_cl_util=>boolean_abap_2_json( showsettingbutton ).
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `showTimeZoomControl`.
    temp94-v = z2ui5_cl_util=>boolean_abap_2_json( showtimezoomcontrol ).
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `stepCountOfSlider`.
    temp94-v = stepcountofslider.
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `zoomControlType`.
    temp94-v = zoomcontroltype.
    INSERT temp94 INTO TABLE temp93.
    temp94-n = `zoomLevel`.
    temp94-v = zoomlevel.
    INSERT temp94 INTO TABLE temp93.
    result = _generic(
        name   = `ContainerToolbar`
        ns     = `gantt`
        t_prop = temp93 ).
  ENDMETHOD.

  METHOD content.

    result = _generic( ns   = ns
                       name = `content` ).

  ENDMETHOD.

  METHOD content_left.
    result = _generic( `contentLeft` ).
  ENDMETHOD.

  METHOD content_middle.
    result = _generic( `contentMiddle` ).
  ENDMETHOD.

  METHOD content_right.
    result = _generic( `contentRight` ).
  ENDMETHOD.

  METHOD core_custom_data.
    DATA temp95 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp96 LIKE LINE OF temp95.
    result = me.

    CLEAR temp95.

    temp96-n = `value`.
    temp96-v = value.
    INSERT temp96 INTO TABLE temp95.
    temp96-n = `key`.
    temp96-v = key.
    INSERT temp96 INTO TABLE temp95.
    temp96-n = `writeToDom`.
    temp96-v = z2ui5_cl_util=>boolean_abap_2_json( writetodom ).
    INSERT temp96 INTO TABLE temp95.
    _generic( name   = `CustomData`
              ns     = `core`
              t_prop = temp95 ).

  ENDMETHOD.

  METHOD currency.
    DATA temp97 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp98 LIKE LINE OF temp97.
    CLEAR temp97.

    temp98-n = `value`.
    temp98-v = value.
    INSERT temp98 INTO TABLE temp97.
    temp98-n = `currency`.
    temp98-v = currency.
    INSERT temp98 INTO TABLE temp97.
    temp98-n = `useSymbol`.
    temp98-v = z2ui5_cl_util=>boolean_abap_2_json( usesymbol ).
    INSERT temp98 INTO TABLE temp97.
    temp98-n = `maxPrecision`.
    temp98-v = maxprecision.
    INSERT temp98 INTO TABLE temp97.
    temp98-n = `stringValue`.
    temp98-v = stringvalue.
    INSERT temp98 INTO TABLE temp97.
    result = _generic( name   = `Currency`
                       ns     = `u`
                       t_prop = temp97 ).

  ENDMETHOD.

  METHOD custom_control.
    result = _generic( name = `customControl`
                       ns   = `commons` ).
  ENDMETHOD.

  METHOD custom_data.
    result = _generic( name = `customData`
                       ns   = ns ).
  ENDMETHOD.

  METHOD custom_header.
    result = _generic( `customHeader` ).
  ENDMETHOD.

  METHOD custom_layout.
    result = _generic( name = `customLayout`
                       ns   = ns ).
  ENDMETHOD.

  METHOD custom_list_item.
    result = _generic( `CustomListItem` ).
  ENDMETHOD.

  METHOD data.
    result = _generic( name = `data`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD date_picker.
    DATA temp99 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp100 LIKE LINE OF temp99.
    result = me.

    CLEAR temp99.

    temp100-n = `value`.
    temp100-v = value.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `displayFormat`.
    temp100-v = displayformat.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `displayFormatType`.
    temp100-v = displayformattype.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `valueFormat`.
    temp100-v = valueformat.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `required`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `valueState`.
    temp100-v = valuestate.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `valueStateText`.
    temp100-v = valuestatetext.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `placeholder`.
    temp100-v = placeholder.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `textAlign`.
    temp100-v = textalign.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `textDirection`.
    temp100-v = textdirection.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `change`.
    temp100-v = change.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `maxDate`.
    temp100-v = maxdate.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `minDate`.
    temp100-v = mindate.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `width`.
    temp100-v = width.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `id`.
    temp100-v = id.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `dateValue`.
    temp100-v = datevalue.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `name`.
    temp100-v = name.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `class`.
    temp100-v = class.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `calendarWeekNumbering`.
    temp100-v = calendarweeknumbering.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `initialFocusedDateValue`.
    temp100-v = initialfocuseddatevalue.
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `enabled`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `visible`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `editable`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `hideInput`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( hideinput ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `showFooter`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `showValueStateMessage`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp100 INTO TABLE temp99.
    temp100-n = `showCurrentDateButton`.
    temp100-v = z2ui5_cl_util=>boolean_abap_2_json( showcurrentdatebutton ).
    INSERT temp100 INTO TABLE temp99.
    _generic( name   = `DatePicker`
              t_prop = temp99 ).
  ENDMETHOD.

  METHOD date_time_picker.
    DATA temp101 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp102 LIKE LINE OF temp101.
    result = me.

    CLEAR temp101.

    temp102-n = `value`.
    temp102-v = value.
    INSERT temp102 INTO TABLE temp101.
    temp102-n = `placeholder`.
    temp102-v = placeholder.
    INSERT temp102 INTO TABLE temp101.
    temp102-n = `enabled`.
    temp102-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp102 INTO TABLE temp101.
    temp102-n = `valueState`.
    temp102-v = valuestate.
    INSERT temp102 INTO TABLE temp101.
    _generic( name   = `DateTimePicker`
              t_prop = temp101 ).
  ENDMETHOD.

  METHOD delta_micro_chart.
    DATA temp103 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp104 LIKE LINE OF temp103.
    result = me.

    CLEAR temp103.

    temp104-n = `color`.
    temp104-v = color.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `press`.
    temp104-v = press.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `size`.
    temp104-v = size.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `height`.
    temp104-v = height.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `width`.
    temp104-v = width.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `deltaDisplayValue`.
    temp104-v = deltadisplayvalue.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `displayValue1`.
    temp104-v = displayvalue1.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `displayValue2`.
    temp104-v = displayvalue2.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `title2`.
    temp104-v = title2.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `value1`.
    temp104-v = value1.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `value2`.
    temp104-v = value2.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `view`.
    temp104-v = view.
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `hideOnNoData`.
    temp104-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp104 INTO TABLE temp103.
    temp104-n = `title1`.
    temp104-v = title1.
    INSERT temp104 INTO TABLE temp103.
    _generic( name   = `DeltaMicroChart`
              ns     = `mchart`
              t_prop = temp103 ).
  ENDMETHOD.

  METHOD dependents.
    result = _generic( name = `dependents`
                       ns   = ns ).
  ENDMETHOD.

  METHOD detail_box.
    result = _generic( `detailBox` ).
  ENDMETHOD.

  METHOD detail_pages.
    result = _generic( `detailPages` ).
  ENDMETHOD.

  METHOD dialog.

    DATA temp105 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp106 LIKE LINE OF temp105.
    CLEAR temp105.

    temp106-n = `title`.
    temp106-v = title.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `icon`.
    temp106-v = icon.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `stretch`.
    temp106-v = stretch.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `state`.
    temp106-v = state.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `titleAlignment`.
    temp106-v = titlealignment.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `type`.
    temp106-v = type.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `showHeader`.
    temp106-v = showheader.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `contentWidth`.
    temp106-v = contentwidth.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `contentHeight`.
    temp106-v = contentheight.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `escapeHandler`.
    temp106-v = escapehandler.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `closeOnNavigation`.
    temp106-v = z2ui5_cl_util=>boolean_abap_2_json( closeonnavigation ).
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `draggable`.
    temp106-v = z2ui5_cl_util=>boolean_abap_2_json( draggable ).
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `resizable`.
    temp106-v = z2ui5_cl_util=>boolean_abap_2_json( resizable ).
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `horizontalScrolling`.
    temp106-v = z2ui5_cl_util=>boolean_abap_2_json( horizontalscrolling ).
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `verticalScrolling`.
    temp106-v = z2ui5_cl_util=>boolean_abap_2_json( verticalscrolling ).
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `afterOpen`.
    temp106-v = afteropen.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `beforeClose`.
    temp106-v = beforeclose.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `beforeOpen`.
    temp106-v = beforeopen.
    INSERT temp106 INTO TABLE temp105.
    temp106-n = `afterClose`.
    temp106-v = afterclose.
    INSERT temp106 INTO TABLE temp105.
    result = _generic(
        name   = `Dialog`
        t_prop = temp105 ).
  ENDMETHOD.

  METHOD draft_indicator.
    DATA temp107 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp108 LIKE LINE OF temp107.
    CLEAR temp107.

    temp108-n = `id`.
    temp108-v = id.
    INSERT temp108 INTO TABLE temp107.
    temp108-n = `class`.
    temp108-v = class.
    INSERT temp108 INTO TABLE temp107.
    temp108-n = `minDisplayTime`.
    temp108-v = mindisplaytime.
    INSERT temp108 INTO TABLE temp107.
    temp108-n = `state`.
    temp108-v = state.
    INSERT temp108 INTO TABLE temp107.
    temp108-n = `visible`.
    temp108-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp108 INTO TABLE temp107.
    result = _generic( name   = `DraftIndicator`
                       t_prop = temp107 ).
  ENDMETHOD.

  METHOD drag_drop_info.
    DATA temp109 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp110 LIKE LINE OF temp109.
    result = me.

    CLEAR temp109.

    temp110-n = `sourceAggregation`.
    temp110-v = sourceaggregation.
    INSERT temp110 INTO TABLE temp109.
    temp110-n = `targetAggregation`.
    temp110-v = targetaggregation.
    INSERT temp110 INTO TABLE temp109.
    temp110-n = `dragStart`.
    temp110-v = dragstart.
    INSERT temp110 INTO TABLE temp109.
    temp110-n = `drop`.
    temp110-v = drop.
    INSERT temp110 INTO TABLE temp109.
    _generic( name   = `DragDropInfo`
              ns     = `dnd`
              t_prop = temp109 ).
  ENDMETHOD.

  METHOD drag_info.
    DATA temp111 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp112 LIKE LINE OF temp111.
    result = me.

    CLEAR temp111.

    temp112-n = `sourceAggregation`.
    temp112-v = sourceaggregation.
    INSERT temp112 INTO TABLE temp111.
    _generic( name   = `DragInfo`
              ns     = `dnd`
              t_prop = temp111 ).
  ENDMETHOD.

  METHOD drag_drop_config.
    result = _generic( name = `dragDropConfig`
                       ns   = ns ).
  ENDMETHOD.

  METHOD dynamic_page.
    DATA temp113 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp114 LIKE LINE OF temp113.
    CLEAR temp113.

    temp114-n = `headerExpanded`.
    temp114-v = z2ui5_cl_util=>boolean_abap_2_json( headerexpanded ).
    INSERT temp114 INTO TABLE temp113.
    temp114-n = `headerPinned`.
    temp114-v = z2ui5_cl_util=>boolean_abap_2_json( headerpinned ).
    INSERT temp114 INTO TABLE temp113.
    temp114-n = `showFooter`.
    temp114-v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ).
    INSERT temp114 INTO TABLE temp113.
    temp114-n = `toggleHeaderOnTitleClick`.
    temp114-v = toggleheaderontitleclick.
    INSERT temp114 INTO TABLE temp113.
    temp114-n = `class`.
    temp114-v = class.
    INSERT temp114 INTO TABLE temp113.
    result = _generic( name   = `DynamicPage`
                       ns     = `f`
                       t_prop = temp113 ).
  ENDMETHOD.

  METHOD dynamic_page_header.
    DATA temp115 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp116 LIKE LINE OF temp115.
    CLEAR temp115.

    temp116-n = `pinnable`.
    temp116-v = z2ui5_cl_util=>boolean_abap_2_json( pinnable ).
    INSERT temp116 INTO TABLE temp115.
    result = _generic(
                 name   = `DynamicPageHeader`
                 ns     = `f`
                 t_prop = temp115 ).
  ENDMETHOD.

  METHOD dynamic_page_title.
    result = _generic( name = `DynamicPageTitle`
                       ns   = `f` ).
  ENDMETHOD.

  METHOD dynamic_side_content.
    DATA temp117 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp118 LIKE LINE OF temp117.
    CLEAR temp117.

    temp118-n = `id`.
    temp118-v = id.
    INSERT temp118 INTO TABLE temp117.
    temp118-n = `class`.
    temp118-v = class.
    INSERT temp118 INTO TABLE temp117.
    temp118-n = `sideContentVisibility`.
    temp118-v = sidecontentvisibility.
    INSERT temp118 INTO TABLE temp117.
    temp118-n = `showSideContent`.
    temp118-v = showsidecontent.
    INSERT temp118 INTO TABLE temp117.
    temp118-n = `containerQuery`.
    temp118-v = containerquery.
    INSERT temp118 INTO TABLE temp117.
    result = _generic( name   = `DynamicSideContent`
                       ns     = `layout`
                       t_prop = temp117 ).

  ENDMETHOD.

  METHOD element_attribute.
    DATA temp119 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp120 LIKE LINE OF temp119.
    DATA temp80 TYPE string.
    CLEAR temp119.

    temp120-n = `label`.
    temp120-v = label.
    INSERT temp120 INTO TABLE temp119.
    temp120-n = `value`.
    temp120-v = value.
    INSERT temp120 INTO TABLE temp119.

    CASE ns.
      WHEN ``.
        temp80 = `networkgraph`.
      WHEN OTHERS.
        temp80 = ns.
    ENDCASE.
    result = _generic( name   = `ElementAttribute`
                       ns     = temp80
                       t_prop = temp119 ).
  ENDMETHOD.

  METHOD embedded_control.
    result = _generic( name = `embeddedControl`
                       ns   = `commons` ).
  ENDMETHOD.

  METHOD end_button.

    result = _generic( `endButton` ).

  ENDMETHOD.

  METHOD end_column_pages.
    result = me.
  ENDMETHOD.

  METHOD expandable_text.
    DATA temp121 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp122 LIKE LINE OF temp121.
    CLEAR temp121.

    temp122-n = `id`.
    temp122-v = id.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `emptyIndicatorMode`.
    temp122-v = emptyindicatormode.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `maxCharacters`.
    temp122-v = maxcharacters.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `overflowMode`.
    temp122-v = overflowmode.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `renderWhitespace`.
    temp122-v = z2ui5_cl_util=>boolean_abap_2_json( renderwhitespace ).
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `text`.
    temp122-v = text.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `textAlign`.
    temp122-v = textalign.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `textDirection`.
    temp122-v = textdirection.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `wrappingType`.
    temp122-v = wrappingtype.
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `visible`.
    temp122-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp122 INTO TABLE temp121.
    temp122-n = `class`.
    temp122-v = class.
    INSERT temp122 INTO TABLE temp121.
    result = _generic(
                 name   = `ExpandableText`
                 t_prop = temp121 ).
  ENDMETHOD.

  METHOD expanded_content.
    result = _generic( name = `expandedContent`
                       ns   = ns ).
  ENDMETHOD.

  METHOD expanded_heading.
    result = _generic( name = `expandedHeading`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD facet_filter.
    DATA temp123 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp124 LIKE LINE OF temp123.
    CLEAR temp123.

    temp124-n = `id`.
    temp124-v = id.
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `class`.
    temp124-v = class.
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `liveSearch`.
    temp124-v = z2ui5_cl_util=>boolean_abap_2_json( livesearch ).
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `showPersonalization`.
    temp124-v = z2ui5_cl_util=>boolean_abap_2_json( showpersonalization ).
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `showPopoverOKButton`.
    temp124-v = z2ui5_cl_util=>boolean_abap_2_json( showpopoverokbutton ).
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `showReset`.
    temp124-v = z2ui5_cl_util=>boolean_abap_2_json( showreset ).
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `showSummaryBar`.
    temp124-v = z2ui5_cl_util=>boolean_abap_2_json( showsummarybar ).
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `type`.
    temp124-v = type.
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `confirm`.
    temp124-v = confirm.
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `reset`.
    temp124-v = reset.
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `lists`.
    temp124-v = lists.
    INSERT temp124 INTO TABLE temp123.
    temp124-n = `visible`.
    temp124-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp124 INTO TABLE temp123.
    result = _generic( name   = `FacetFilter`
                       t_prop = temp123 ).
  ENDMETHOD.

  METHOD facet_filter_item.
    DATA temp125 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp126 LIKE LINE OF temp125.
    CLEAR temp125.

    temp126-n = `id`.
    temp126-v = id.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `class`.
    temp126-v = class.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `count`.
    temp126-v = count.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `counter`.
    temp126-v = counter.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `highlight`.
    temp126-v = highlight.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `highlightText`.
    temp126-v = highlighttext.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `key`.
    temp126-v = key.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `navigated`.
    temp126-v = z2ui5_cl_util=>boolean_abap_2_json( navigated ).
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `selected`.
    temp126-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `unread`.
    temp126-v = z2ui5_cl_util=>boolean_abap_2_json( unread ).
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `text`.
    temp126-v = text.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `type`.
    temp126-v = type.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `detailPress`.
    temp126-v = detailpress.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `press`.
    temp126-v = press.
    INSERT temp126 INTO TABLE temp125.
    temp126-n = `visible`.
    temp126-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp126 INTO TABLE temp125.
    result = _generic(
                 name   = `FacetFilterItem`
                 t_prop = temp125 ).
  ENDMETHOD.

  METHOD facet_filter_list.
    DATA temp127 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp128 LIKE LINE OF temp127.
    CLEAR temp127.

    temp128-n = `id`.
    temp128-v = id.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `class`.
    temp128-v = class.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `active`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( active ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `allCount`.
    temp128-v = allcount.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `backgroundDesign`.
    temp128-v = backgrounddesign.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `dataType`.
    temp128-v = datatype.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `enableBusyIndicator`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( enablebusyindicator ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `enableCaseInsensitiveSearch`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( enablecaseinsensitivesearch ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `footerText`.
    temp128-v = footertext.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `growing`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `growingDirection`.
    temp128-v = growingdirection.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `growingScrollToLoad`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `growingThreshold`.
    temp128-v = growingthreshold.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `growingTriggerText`.
    temp128-v = growingtriggertext.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `headerLevel`.
    temp128-v = headerlevel.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `includeItemInSelection`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `inset`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( inset ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `key`.
    temp128-v = key.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `swipedirection`.
    temp128-v = swipedirection.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `headerText`.
    temp128-v = headertext.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `keyboardMode`.
    temp128-v = keyboardmode.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `mode`.
    temp128-v = mode.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `modeAnimationOn`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( modeanimationon ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `multiSelectMode`.
    temp128-v = multiselectmode.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `noDataText`.
    temp128-v = nodatatext.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `rememberSelections`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `retainListSequence`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( retainlistsequence ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `sequence`.
    temp128-v = sequence.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `showNoData`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `showRemoveFacetIcon`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( showremovefaceticon ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `showSeparators`.
    temp128-v = showseparators.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `showUnread`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( showunread ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `sticky`.
    temp128-v = sticky.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `title`.
    temp128-v = title.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `width`.
    temp128-v = width.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `wordWrap`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( wordwrap ).
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `listClose`.
    temp128-v = listclose.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `listOpen`.
    temp128-v = listopen.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `search`.
    temp128-v = search.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `selectionChange`.
    temp128-v = selectionchange.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `delete`.
    temp128-v = delete.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `items`.
    temp128-v = items.
    INSERT temp128 INTO TABLE temp127.
    temp128-n = `visible`.
    temp128-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp128 INTO TABLE temp127.
    result = _generic(
        name   = `FacetFilterList`
        t_prop = temp127 ).
  ENDMETHOD.

  METHOD factory.
    DATA temp129 LIKE result->mt_prop.
    DATA temp130 LIKE LINE OF temp129.
    DATA temp131 TYPE z2ui5_if_types=>ty_s_name_value.
    DATA temp132 TYPE z2ui5_if_types=>ty_s_name_value.
    DATA temp133 TYPE z2ui5_if_types=>ty_s_name_value.

    CREATE OBJECT result.

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.


    CLEAR temp129.
    temp129 = result->mt_prop.

    temp130-n = `displayBlock`.
    temp130-v = `true`.
    INSERT temp130 INTO TABLE temp129.
    temp130-n = `height`.
    temp130-v = `100%`.
    INSERT temp130 INTO TABLE temp129.
    result->mt_prop   = temp129.

    result->mv_name   = `View`.
    result->mv_ns     = `mvc`.
    result->mo_root   = result.
    result->mo_parent = result.


    CLEAR temp131.
    temp131-n = `xmlns`.
    temp131-v = `sap.m`.
    INSERT temp131 INTO TABLE result->mt_prop.

    CLEAR temp132.
    temp132-n = `xmlns:mvc`.
    temp132-v = `sap.ui.core.mvc`.
    INSERT temp132 INTO TABLE result->mt_prop.

    CLEAR temp133.
    temp133-n = `xmlns:core`.
    temp133-v = `sap.ui.core`.
    INSERT temp133 INTO TABLE result->mt_prop.

  ENDMETHOD.

  METHOD factory_plain.

    CREATE OBJECT result.

    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.

  METHOD factory_popup.
    DATA temp134 TYPE z2ui5_if_types=>ty_s_name_value.
    DATA temp135 TYPE z2ui5_if_types=>ty_s_name_value.

    CREATE OBJECT result.

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mv_name   = `FragmentDefinition`.
    result->mv_ns     = `core`.
    result->mo_root   = result.
    result->mo_parent = result.


    CLEAR temp134.
    temp134-n = `xmlns`.
    temp134-v = `sap.m`.
    INSERT temp134 INTO TABLE result->mt_prop.

    CLEAR temp135.
    temp135-n = `xmlns:core`.
    temp135-v = `sap.ui.core`.
    INSERT temp135 INTO TABLE result->mt_prop.

  ENDMETHOD.

  METHOD fb_control.
    result = _generic( name = `control`
                       ns   = `fb` ).
  ENDMETHOD.

  METHOD feed_input.
    DATA temp136 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp137 LIKE LINE OF temp136.
    CLEAR temp136.

    temp137-n = `buttonTooltip`.
    temp137-v = buttontooltip.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `enabled`.
    temp137-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `growing`.
    temp137-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `growingMaxLines`.
    temp137-v = growingmaxlines.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `icon`.
    temp137-v = icon.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `iconDensityAware`.
    temp137-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `iconDisplayShape`.
    temp137-v = icondisplayshape.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `iconInitials`.
    temp137-v = iconinitials.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `iconSize`.
    temp137-v = iconsize.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `maxLength`.
    temp137-v = maxlength.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `placeholder`.
    temp137-v = placeholder.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `rows`.
    temp137-v = rows.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `showExceededText`.
    temp137-v = z2ui5_cl_util=>boolean_abap_2_json( showexceededtext ).
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `showIcon`.
    temp137-v = z2ui5_cl_util=>boolean_abap_2_json( showicon ).
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `value`.
    temp137-v = value.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `class`.
    temp137-v = class.
    INSERT temp137 INTO TABLE temp136.
    temp137-n = `post`.
    temp137-v = post.
    INSERT temp137 INTO TABLE temp136.
    result = _generic(
                 name   = `FeedInput`
                 t_prop = temp136 ).

  ENDMETHOD.

  METHOD feed_list_item.
    DATA temp138 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp139 LIKE LINE OF temp138.
    CLEAR temp138.

    temp139-n = `activeIcon`.
    temp139-v = activeicon.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `convertedLinksDefaultTarget`.
    temp139-v = convertedlinksdefaulttarget.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `convertLinksToAnchorTags`.
    temp139-v = convertlinkstoanchortags.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `iconActive`.
    temp139-v = z2ui5_cl_util=>boolean_abap_2_json( iconactive ).
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `icon`.
    temp139-v = icon.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `iconDensityAware`.
    temp139-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `iconDisplayShape`.
    temp139-v = icondisplayshape.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `iconInitials`.
    temp139-v = iconinitials.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `iconSize`.
    temp139-v = iconsize.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `info`.
    temp139-v = info.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `lessLabel`.
    temp139-v = lesslabel.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `maxCharacters`.
    temp139-v = maxcharacters.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `moreLabel`.
    temp139-v = morelabel.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `sender`.
    temp139-v = sender.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `senderActive`.
    temp139-v = z2ui5_cl_util=>boolean_abap_2_json( senderactive ).
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `showIcon`.
    temp139-v = z2ui5_cl_util=>boolean_abap_2_json( showicon ).
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `text`.
    temp139-v = text.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `senderPress`.
    temp139-v = senderpress.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `iconPress`.
    temp139-v = iconpress.
    INSERT temp139 INTO TABLE temp138.
    temp139-n = `timestamp`.
    temp139-v = timestamp.
    INSERT temp139 INTO TABLE temp138.
    result = _generic(
                 name   = `FeedListItem`
                 t_prop = temp138 ).
  ENDMETHOD.

  METHOD feed_list_item_action.
    DATA temp140 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp141 LIKE LINE OF temp140.
    CLEAR temp140.

    temp141-n = `enabled`.
    temp141-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp141 INTO TABLE temp140.
    temp141-n = `icon`.
    temp141-v = icon.
    INSERT temp141 INTO TABLE temp140.
    temp141-n = `key`.
    temp141-v = key.
    INSERT temp141 INTO TABLE temp140.
    temp141-n = `text`.
    temp141-v = text.
    INSERT temp141 INTO TABLE temp140.
    temp141-n = `press`.
    temp141-v = press.
    INSERT temp141 INTO TABLE temp140.
    temp141-n = `visible`.
    temp141-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp141 INTO TABLE temp140.
    result = _generic( name   = `FeedListItemAction`
                       t_prop = temp140 ).
  ENDMETHOD.

  METHOD filter_bar.

    DATA temp142 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp143 LIKE LINE OF temp142.
    CLEAR temp142.

    temp143-n = `useToolbar`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( usetoolbar ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `search`.
    temp143-v = search.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `id`.
    temp143-v = id.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `persistencyKey`.
    temp143-v = persistencykey.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `afterVariantLoad`.
    temp143-v = aftervariantload.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `afterVariantSave`.
    temp143-v = aftervariantsave.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `assignedFiltersChanged`.
    temp143-v = assignedfilterschanged.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `beforeVariantFetch`.
    temp143-v = beforevariantfetch.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `cancel`.
    temp143-v = cancel.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `clear`.
    temp143-v = clear.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `filtersDialogBeforeOpen`.
    temp143-v = filtersdialogbeforeopen.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `filtersDialogCancel`.
    temp143-v = filtersdialogcancel.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `filtersDialogClosed`.
    temp143-v = filtersdialogclosed.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `initialise`.
    temp143-v = initialise.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `initialized`.
    temp143-v = initialized.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `reset`.
    temp143-v = reset.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `filterContainerWidth`.
    temp143-v = filtercontainerwidth.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `header`.
    temp143-v = header.
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `advancedMode`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( advancedmode ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `isRunningInValueHelpDialog`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( isrunninginvaluehelpdialog ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `showAllFilters`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( showallfilters ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `showClearOnFB`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( showclearonfb ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `showFilterConfiguration`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( showfilterconfiguration ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `showGoOnFB`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( showgoonfb ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `showRestoreButton`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( showrestorebutton ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `showRestoreOnFB`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( showrestoreonfb ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `useSnapshot`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( usesnapshot ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `searchEnabled`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( searchenabled ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `considerGroupTitle`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( considergrouptitle ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `deltaVariantMode`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( deltavariantmode ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `disableSearchMatchesPatternWarning`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( disablesearchmatchespatternw ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `filterBarExpanded`.
    temp143-v = z2ui5_cl_util=>boolean_abap_2_json( filterbarexpanded ).
    INSERT temp143 INTO TABLE temp142.
    temp143-n = `filterChange`.
    temp143-v = filterchange.
    INSERT temp143 INTO TABLE temp142.
    result = _generic(
        name   = `FilterBar`
        ns     = `fb`
        t_prop = temp142 ).
  ENDMETHOD.

  METHOD filter_control.
    result = _generic( name = `control`
                       ns   = `fb` ).
  ENDMETHOD.

  METHOD filter_group_item.
    DATA temp144 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp145 LIKE LINE OF temp144.
    CLEAR temp144.

    temp145-n = `name`.
    temp145-v = name.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `label`.
    temp145-v = label.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `groupName`.
    temp145-v = groupname.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `controlTooltip`.
    temp145-v = controltooltip.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `entitySetName`.
    temp145-v = entitysetname.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `entityTypeName`.
    temp145-v = entitytypename.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `groupTitle`.
    temp145-v = grouptitle.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `labelTooltip`.
    temp145-v = labeltooltip.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `change`.
    temp145-v = change.
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `visibleInFilterBar`.
    temp145-v = z2ui5_cl_util=>boolean_abap_2_json( visibleinfilterbar ).
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `mandatory`.
    temp145-v = z2ui5_cl_util=>boolean_abap_2_json( mandatory ).
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `hiddenFilter`.
    temp145-v = z2ui5_cl_util=>boolean_abap_2_json( hiddenfilter ).
    INSERT temp145 INTO TABLE temp144.
    temp145-n = `visible`.
    temp145-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp145 INTO TABLE temp144.
    result = _generic(
        name   = `FilterGroupItem`
        ns     = `fb`
        t_prop = temp144 ).

  ENDMETHOD.

  METHOD filter_group_items.
    result = _generic( name = `filterGroupItems`
                       ns   = `fb` ).
  ENDMETHOD.

  METHOD filter_items.
    result = _generic( `filterItems` ).
  ENDMETHOD.

  METHOD first_status.
    result = _generic( `firstStatus` ).
  ENDMETHOD.

  METHOD flexible_column_layout.

    DATA temp146 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp147 LIKE LINE OF temp146.
    CLEAR temp146.

    temp147-n = `layout`.
    temp147-v = layout.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `id`.
    temp147-v = id.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `class`.
    temp147-v = class.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `afterBeginColumnNavigate`.
    temp147-v = afterbegincolumnnavigate.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `afterEndColumnNavigate`.
    temp147-v = afterendcolumnnavigate.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `afterMidColumnNavigate`.
    temp147-v = aftermidcolumnnavigate.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `beginColumnNavigate`.
    temp147-v = begincolumnnavigate.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `columnResize`.
    temp147-v = columnresize.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `endColumnNavigate`.
    temp147-v = endcolumnnavigate.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `midColumnNavigate`.
    temp147-v = midcolumnnavigate.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `stateChange`.
    temp147-v = statechange.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `backgroundDesign`.
    temp147-v = backgrounddesign.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `defaultTransitionNameBeginColumn`.
    temp147-v = defaulttransitionnamebegincol.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `defaultTransitionNameEndColumn`.
    temp147-v = defaulttransitionnameendcol.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `defaultTransitionNameMidColumn`.
    temp147-v = defaulttransitionnamemidcol.
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `autoFocus`.
    temp147-v = z2ui5_cl_util=>boolean_abap_2_json( autofocus ).
    INSERT temp147 INTO TABLE temp146.
    temp147-n = `restoreFocusOnBackNavigation`.
    temp147-v = z2ui5_cl_util=>boolean_abap_2_json( restorefocusonbacknavigation ).
    INSERT temp147 INTO TABLE temp146.
    result = _generic(
        name   = `FlexibleColumnLayout`
        ns     = `f`
        t_prop = temp146 ).

  ENDMETHOD.

  METHOD flex_box.
    DATA temp148 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp149 LIKE LINE OF temp148.
    CLEAR temp148.

    temp149-n = `class`.
    temp149-v = class.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `id`.
    temp149-v = id.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `renderType`.
    temp149-v = rendertype.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `width`.
    temp149-v = width.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `height`.
    temp149-v = height.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `alignItems`.
    temp149-v = alignitems.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `fitContainer`.
    temp149-v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ).
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `justifyContent`.
    temp149-v = justifycontent.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `wrap`.
    temp149-v = wrap.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `items`.
    temp149-v = items.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `direction`.
    temp149-v = direction.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `alignContent`.
    temp149-v = aligncontent.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `backgroundDesign`.
    temp149-v = backgrounddesign.
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `displayInline`.
    temp149-v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ).
    INSERT temp149 INTO TABLE temp148.
    temp149-n = `visible`.
    temp149-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp149 INTO TABLE temp148.
    result = _generic(
                 name   = `FlexBox`
                 t_prop = temp148 ).
  ENDMETHOD.

  METHOD flex_item_data.
    DATA temp150 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp151 LIKE LINE OF temp150.
    result = me.


    CLEAR temp150.

    temp151-n = `growFactor`.
    temp151-v = growfactor.
    INSERT temp151 INTO TABLE temp150.
    temp151-n = `baseSize`.
    temp151-v = basesize.
    INSERT temp151 INTO TABLE temp150.
    temp151-n = `backgroundDesign`.
    temp151-v = backgrounddesign.
    INSERT temp151 INTO TABLE temp150.
    temp151-n = `styleClass`.
    temp151-v = styleclass.
    INSERT temp151 INTO TABLE temp150.
    temp151-n = `order`.
    temp151-v = order.
    INSERT temp151 INTO TABLE temp150.
    temp151-n = `shrinkFactor`.
    temp151-v = shrinkfactor.
    INSERT temp151 INTO TABLE temp150.
    _generic( name   = `FlexItemData`
              t_prop = temp150 ).
  ENDMETHOD.

  METHOD footer.
    result = _generic( ns   = ns
                       name = `footer` ).
  ENDMETHOD.

  METHOD force_based_layout.
    DATA temp152 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp153 LIKE LINE OF temp152.
    CLEAR temp152.

    temp153-n = `id`.
    temp153-v = id.
    INSERT temp153 INTO TABLE temp152.
    temp153-n = `class`.
    temp153-v = class.
    INSERT temp153 INTO TABLE temp152.
    temp153-n = `alpha`.
    temp153-v = alpha.
    INSERT temp153 INTO TABLE temp152.
    temp153-n = `charge`.
    temp153-v = charge.
    INSERT temp153 INTO TABLE temp152.
    temp153-n = `friction`.
    temp153-v = friction.
    INSERT temp153 INTO TABLE temp152.
    temp153-n = `maximumDuration`.
    temp153-v = maximumduration.
    INSERT temp153 INTO TABLE temp152.
    result = _generic( name   = `ForceBasedLayout`
                       ns     = `nglayout`
                       t_prop = temp152 ).
  ENDMETHOD.

  METHOD force_directed_layout.
    DATA temp154 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp155 LIKE LINE OF temp154.
    CLEAR temp154.

    temp155-n = `id`.
    temp155-v = id.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `class`.
    temp155-v = class.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `coolDownStep`.
    temp155-v = cooldownstep.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `initialTemperature`.
    temp155-v = initialtemperature.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `maxIterations`.
    temp155-v = maxiterations.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `maxTime`.
    temp155-v = maxtime.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `optimalDistanceConstant`.
    temp155-v = optimaldistanceconstant.
    INSERT temp155 INTO TABLE temp154.
    temp155-n = `staticNodes`.
    temp155-v = staticnodes.
    INSERT temp155 INTO TABLE temp154.
    result = _generic( name   = `ForceDirectedLayout`
                       ns     = `nglayout`
                       t_prop = temp154 ).
  ENDMETHOD.

  METHOD formatted_text.
    DATA temp156 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp157 LIKE LINE OF temp156.
    result = me.

    CLEAR temp156.

    temp157-n = `htmlText`.
    temp157-v = htmltext.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `convertedLinksDefaultTarget`.
    temp157-v = convertedlinksdefaulttarget.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `convertLinksToAnchorTags`.
    temp157-v = convertlinkstoanchortags.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `height`.
    temp157-v = height.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `textAlign`.
    temp157-v = textalign.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `textDirection`.
    temp157-v = textdirection.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `visible`.
    temp157-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `width`.
    temp157-v = width.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `class`.
    temp157-v = class.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `id`.
    temp157-v = id.
    INSERT temp157 INTO TABLE temp156.
    temp157-n = `controls`.
    temp157-v = controls.
    INSERT temp157 INTO TABLE temp156.
    _generic( name   = `FormattedText`
              t_prop = temp156 ).
  ENDMETHOD.

  METHOD form_toolbar.
    result = _generic( name = `toolbar`
                       ns   = `form` ).
  ENDMETHOD.

  METHOD gantt_chart_container.
    result = _generic( name = `GanttChartContainer`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD gantt_chart_with_table.
    DATA temp158 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp159 LIKE LINE OF temp158.
    CLEAR temp158.

    temp159-n = `id`.
    temp159-v = id.
    INSERT temp159 INTO TABLE temp158.
    temp159-n = `shapeSelectionMode`.
    temp159-v = shapeselectionmode.
    INSERT temp159 INTO TABLE temp158.
    temp159-n = `isConnectorDetailsVisible`.
    temp159-v = z2ui5_cl_util=>boolean_abap_2_json( isconnectordetailsvisible ).
    INSERT temp159 INTO TABLE temp158.
    result = _generic(
        name   = `GanttChartWithTable`
        ns     = `gantt`
        t_prop = temp158 ).
  ENDMETHOD.

  METHOD gantt_row_settings.
    DATA temp160 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp161 LIKE LINE OF temp160.
    CLEAR temp160.

    temp161-n = `rowId`.
    temp161-v = rowid.
    INSERT temp161 INTO TABLE temp160.
    temp161-n = `shapes1`.
    temp161-v = shapes1.
    INSERT temp161 INTO TABLE temp160.
    temp161-n = `shapes2`.
    temp161-v = shapes2.
    INSERT temp161 INTO TABLE temp160.
    temp161-n = `relationships`.
    temp161-v = relationships.
    INSERT temp161 INTO TABLE temp160.
    result = _generic( name   = `GanttRowSettings`
                       ns     = `gantt`
                       t_prop = temp160 ).
  ENDMETHOD.

  METHOD gantt_table.
    result = _generic( name = `table`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD gantt_toolbar.
    result = _generic( name = `toolbar`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD generic_tag.

    DATA temp162 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp163 LIKE LINE OF temp162.
    CLEAR temp162.

    temp163-n = `ariaLabelledBy`.
    temp163-v = arialabelledby.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `class`.
    temp163-v = class.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `design`.
    temp163-v = design.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `status`.
    temp163-v = status.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `id`.
    temp163-v = id.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `press`.
    temp163-v = press.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `text`.
    temp163-v = text.
    INSERT temp163 INTO TABLE temp162.
    temp163-n = `valueState`.
    temp163-v = valuestate.
    INSERT temp163 INTO TABLE temp162.
    result = _generic( name   = `GenericTag`
                       t_prop = temp162 ).

  ENDMETHOD.

  METHOD generic_tile.

    DATA temp164 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp165 LIKE LINE OF temp164.
    CLEAR temp164.

    temp165-n = `class`.
    temp165-v = class.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `id`.
    temp165-v = id.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `header`.
    temp165-v = header.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `mode`.
    temp165-v = mode.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `additionalTooltip`.
    temp165-v = additionaltooltip.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `appShortcut`.
    temp165-v = appshortcut.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `backgroundColor`.
    temp165-v = backgroundcolor.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `backgroundImage`.
    temp165-v = backgroundimage.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `dropAreaOffset`.
    temp165-v = dropareaoffset.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `press`.
    temp165-v = press.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `frameType`.
    temp165-v = frametype.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `failedText`.
    temp165-v = failedtext.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `headerImage`.
    temp165-v = headerimage.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `scope`.
    temp165-v = scope.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `sizeBehavior`.
    temp165-v = sizebehavior.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `state`.
    temp165-v = state.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `systemInfo`.
    temp165-v = systeminfo.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `tileBadge`.
    temp165-v = tilebadge.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `tileIcon`.
    temp165-v = tileicon.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `url`.
    temp165-v = url.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `valueColor`.
    temp165-v = valuecolor.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `width`.
    temp165-v = width.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `wrappingType`.
    temp165-v = wrappingtype.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `imageDescription`.
    temp165-v = imagedescription.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `navigationButtonText`.
    temp165-v = navigationbuttontext.
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `visible`.
    temp165-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `renderOnThemeChange`.
    temp165-v = z2ui5_cl_util=>boolean_abap_2_json( renderonthemechange ).
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `enableNavigationButton`.
    temp165-v = z2ui5_cl_util=>boolean_abap_2_json( enablenavigationbutton ).
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `pressEnabled`.
    temp165-v = z2ui5_cl_util=>boolean_abap_2_json( pressenabled ).
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `iconLoaded`.
    temp165-v = z2ui5_cl_util=>boolean_abap_2_json( iconloaded ).
    INSERT temp165 INTO TABLE temp164.
    temp165-n = `subheader`.
    temp165-v = subheader.
    INSERT temp165 INTO TABLE temp164.
    result = _generic(
                 name   = `GenericTile`
                 ns     = ``
                 t_prop = temp164 ).

  ENDMETHOD.

  METHOD get.

    IF name IS INITIAL.
      result = mo_root->mo_previous.
      RETURN.
    ENDIF.

    IF mo_parent->mv_name = name.
      result = mo_parent.
    ELSE.
      result = mo_parent->get( name ).
    ENDIF.

  ENDMETHOD.

  METHOD get_child.
    DATA temp166 LIKE LINE OF mt_child.
    DATA temp167 LIKE sy-tabix.
    temp167 = sy-tabix.
    READ TABLE mt_child INDEX index INTO temp166.
    sy-tabix = temp167.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp166.
  ENDMETHOD.

  METHOD get_parent.
    result = mo_parent.
  ENDMETHOD.

  METHOD get_root.
    result = mo_root.
  ENDMETHOD.

  METHOD grid.

    DATA temp168 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp169 LIKE LINE OF temp168.
    CLEAR temp168.

    temp169-n = `defaultSpan`.
    temp169-v = default_span.
    INSERT temp169 INTO TABLE temp168.
    temp169-n = `class`.
    temp169-v = class.
    INSERT temp169 INTO TABLE temp168.
    temp169-n = `containerQuery`.
    temp169-v = z2ui5_cl_util=>boolean_abap_2_json( containerquery ).
    INSERT temp169 INTO TABLE temp168.
    temp169-n = `hSpacing`.
    temp169-v = hspacing.
    INSERT temp169 INTO TABLE temp168.
    temp169-n = `vSpacing`.
    temp169-v = vspacing.
    INSERT temp169 INTO TABLE temp168.
    temp169-n = `width`.
    temp169-v = width.
    INSERT temp169 INTO TABLE temp168.
    temp169-n = `content`.
    temp169-v = content.
    INSERT temp169 INTO TABLE temp168.
    result = _generic(
                 name   = `Grid`
                 ns     = `layout`
                 t_prop = temp168 ).
  ENDMETHOD.

  METHOD grid_box_layout.
    DATA temp170 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp171 LIKE LINE OF temp170.
    result = me.

    CLEAR temp170.

    temp171-n = `boxesPerRowConfig`.
    temp171-v = boxesperrowconfig.
    INSERT temp171 INTO TABLE temp170.
    temp171-n = `boxMinWidth`.
    temp171-v = boxminwidth.
    INSERT temp171 INTO TABLE temp170.
    temp171-n = `boxWidth`.
    temp171-v = boxwidth.
    INSERT temp171 INTO TABLE temp170.
    _generic( name   = `GridBoxLayout`
              ns     = `grid`
              t_prop = temp170 ).
  ENDMETHOD.

  METHOD grid_data.
    DATA temp172 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp173 LIKE LINE OF temp172.
    result = me.

    CLEAR temp172.

    temp173-n = `span`.
    temp173-v = span.
    INSERT temp173 INTO TABLE temp172.
    temp173-n = `linebreak`.
    temp173-v = z2ui5_cl_util=>boolean_abap_2_json( linebreak ).
    INSERT temp173 INTO TABLE temp172.
    temp173-n = `indentL`.
    temp173-v = indentl.
    INSERT temp173 INTO TABLE temp172.
    temp173-n = `indentM`.
    temp173-v = indentm.
    INSERT temp173 INTO TABLE temp172.
    _generic( name   = `GridData`
              ns     = `layout`
              t_prop = temp172 ).
  ENDMETHOD.

  METHOD grid_drop_info.
    DATA temp174 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp175 LIKE LINE OF temp174.
    result = me.

    CLEAR temp174.

    temp175-n = `targetAggregation`.
    temp175-v = targetaggregation.
    INSERT temp175 INTO TABLE temp174.
    temp175-n = `dropPosition`.
    temp175-v = dropposition.
    INSERT temp175 INTO TABLE temp174.
    temp175-n = `dropLayout`.
    temp175-v = droplayout.
    INSERT temp175 INTO TABLE temp174.
    temp175-n = `drop`.
    temp175-v = drop.
    INSERT temp175 INTO TABLE temp174.
    temp175-n = `dragEnter`.
    temp175-v = dragenter.
    INSERT temp175 INTO TABLE temp174.
    temp175-n = `dragOver`.
    temp175-v = dragover.
    INSERT temp175 INTO TABLE temp174.
    _generic( name   = `GridDropInfo`
              ns     = `dnd-grid`
              t_prop = temp174 ).
  ENDMETHOD.

  METHOD grid_list.
    DATA temp176 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp177 LIKE LINE OF temp176.
    CLEAR temp176.

    temp177-n = `id`.
    temp177-v = id.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `busy`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( busy ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `busyIndicatorDelay`.
    temp177-v = busyindicatordelay.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `busyIndicatorSize`.
    temp177-v = busyindicatorsize.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `enableBusyIndicator`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( enablebusyindicator ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `fieldGroupIds`.
    temp177-v = fieldgroupids.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `footerText`.
    temp177-v = footertext.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `growing`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `growingDirection`.
    temp177-v = growingdirection.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `growingScrollToLoad`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `growingThreshold`.
    temp177-v = growingthreshold.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `growingTriggerText`.
    temp177-v = growingtriggertext.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `headerLevel`.
    temp177-v = headerlevel.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `headerText`.
    temp177-v = headertext.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `includeItemInSelection`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `inset`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( inset ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `keyboardMode`.
    temp177-v = keyboardmode.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `mode`.
    temp177-v = mode.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `modeAnimationOn`.
    temp177-v = modeanimationon.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `multiSelectMode`.
    temp177-v = multiselectmode.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `noDataText`.
    temp177-v = nodatatext.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `rememberSelections`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `showNoData`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `showSeparators`.
    temp177-v = showseparators.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `showUnread`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( showunread ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `sticky`.
    temp177-v = sticky.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `swipeDirection`.
    temp177-v = swipedirection.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `visible`.
    temp177-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `width`.
    temp177-v = width.
    INSERT temp177 INTO TABLE temp176.
    temp177-n = `items`.
    temp177-v = items.
    INSERT temp177 INTO TABLE temp176.
    result = _generic(
                 name   = `GridList`
                 ns     = `f`
                 t_prop = temp176 ).
  ENDMETHOD.

  METHOD grid_list_item.
    DATA temp178 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp179 LIKE LINE OF temp178.
    CLEAR temp178.

    temp179-n = `busy`.
    temp179-v = busy.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `busyIndicatorDelay`.
    temp179-v = busyindicatordelay.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `busyIndicatorSize`.
    temp179-v = busyindicatorsize.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `counter`.
    temp179-v = counter.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `fieldGroupIds`.
    temp179-v = fieldgroupids.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `highlight`.
    temp179-v = highlight.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `highlightText`.
    temp179-v = highlighttext.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `navigated`.
    temp179-v = navigated.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `selected`.
    temp179-v = selected.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `type`.
    temp179-v = type.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `unread`.
    temp179-v = unread.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `visible`.
    temp179-v = visible.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `detailPress`.
    temp179-v = detailpress.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `detailTap`.
    temp179-v = detailtap.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `press`.
    temp179-v = press.
    INSERT temp179 INTO TABLE temp178.
    temp179-n = `tap`.
    temp179-v = tap.
    INSERT temp179 INTO TABLE temp178.
    result = _generic( name   = `GridListItem`
                       ns     = `f`
                       t_prop = temp178 ).
  ENDMETHOD.

  METHOD group.
    DATA temp180 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp181 LIKE LINE OF temp180.
    CLEAR temp180.

    temp181-n = `collapsed`.
    temp181-v = z2ui5_cl_util=>boolean_abap_2_json( collapsed ).
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `id`.
    temp181-v = id.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `class`.
    temp181-v = class.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `description`.
    temp181-v = description.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `headerCheckBoxState`.
    temp181-v = headercheckboxstate.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `icon`.
    temp181-v = icon.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `key`.
    temp181-v = key.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `minWidth`.
    temp181-v = minwidth.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `parentGroupKey`.
    temp181-v = parentgroupkey.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `status`.
    temp181-v = status.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `title`.
    temp181-v = title.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `collapseExpand`.
    temp181-v = collapseexpand.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `showDetail`.
    temp181-v = showdetail.
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `visible`.
    temp181-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp181 INTO TABLE temp180.
    temp181-n = `headerCheckBoxPress`.
    temp181-v = headercheckboxpress.
    INSERT temp181 INTO TABLE temp180.
    result = _generic( name   = `group`
                       ns     = `networkgraph`
                       t_prop = temp180 ).
  ENDMETHOD.

  METHOD groups.
    DATA temp182 TYPE string.
    CASE ns.
      WHEN ``.
        temp182 = `networkgraph`.
      WHEN OTHERS.
        temp182 = ns.
    ENDCASE.
    result = _generic( name = `groups`
                       ns   = temp182 ).
  ENDMETHOD.

  METHOD group_items.
    result = _generic( `groupItems` ).
  ENDMETHOD.

  METHOD harvey_ball_micro_chart.

    DATA temp183 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp184 LIKE LINE OF temp183.
    CLEAR temp183.

    temp184-n = `colorPalette`.
    temp184-v = colorpalette.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `press`.
    temp184-v = press.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `size`.
    temp184-v = size.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `height`.
    temp184-v = height.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `width`.
    temp184-v = width.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `total`.
    temp184-v = total.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `totalLabel`.
    temp184-v = totallabel.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `alignContent`.
    temp184-v = aligncontent.
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `hideOnNoData`.
    temp184-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `formattedLabel`.
    temp184-v = z2ui5_cl_util=>boolean_abap_2_json( formattedlabel ).
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `showFractions`.
    temp184-v = z2ui5_cl_util=>boolean_abap_2_json( showfractions ).
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `showTotal`.
    temp184-v = z2ui5_cl_util=>boolean_abap_2_json( showtotal ).
    INSERT temp184 INTO TABLE temp183.
    temp184-n = `totalScale`.
    temp184-v = totalscale.
    INSERT temp184 INTO TABLE temp183.
    result = _generic( name   = `HarveyBallMicroChart`
                       ns     = `mchart`
                       t_prop = temp183 ).
  ENDMETHOD.

  METHOD hbox.
    DATA temp185 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp186 LIKE LINE OF temp185.
    CLEAR temp185.

    temp186-n = `class`.
    temp186-v = class.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `alignContent`.
    temp186-v = aligncontent.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `alignItems`.
    temp186-v = alignitems.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `width`.
    temp186-v = width.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `id`.
    temp186-v = id.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `renderType`.
    temp186-v = rendertype.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `height`.
    temp186-v = height.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `wrap`.
    temp186-v = wrap.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `backgroundDesign`.
    temp186-v = backgrounddesign.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `direction`.
    temp186-v = direction.
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `displayInline`.
    temp186-v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ).
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `fitContainer`.
    temp186-v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ).
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `visible`.
    temp186-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp186 INTO TABLE temp185.
    temp186-n = `justifyContent`.
    temp186-v = justifycontent.
    INSERT temp186 INTO TABLE temp185.
    result = _generic(
        name   = `HBox`
        t_prop = temp185 ).

  ENDMETHOD.

  METHOD header.
    result = _generic( name = `header`
                       ns   = ns ).
  ENDMETHOD.

  METHOD header_container.
    DATA temp187 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp188 LIKE LINE OF temp187.
    CLEAR temp187.

    temp188-n = `scrollStep`.
    temp188-v = scrollstep.
    INSERT temp188 INTO TABLE temp187.
    temp188-n = `scrollTime`.
    temp188-v = scrolltime.
    INSERT temp188 INTO TABLE temp187.
    temp188-n = `orientation`.
    temp188-v = orientation.
    INSERT temp188 INTO TABLE temp187.
    temp188-n = `height`.
    temp188-v = height.
    INSERT temp188 INTO TABLE temp187.
    result = _generic( name   = `HeaderContainer`
                       t_prop = temp187 ).
  ENDMETHOD.

  METHOD header_container_control.
    DATA temp189 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp190 LIKE LINE OF temp189.
    CLEAR temp189.

    temp190-n = `backgroundDesign`.
    temp190-v = backgrounddesign.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `gridLayout`.
    temp190-v = z2ui5_cl_util=>boolean_abap_2_json( gridlayout ).
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `height`.
    temp190-v = height.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `orientation`.
    temp190-v = orientation.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `scrollStep`.
    temp190-v = scrollstep.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `scrollStepByItem`.
    temp190-v = scrollstepbyitem.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `scrollTime`.
    temp190-v = scrolltime.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `showDividers`.
    temp190-v = z2ui5_cl_util=>boolean_abap_2_json( showdividers ).
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `showOverflowItem`.
    temp190-v = z2ui5_cl_util=>boolean_abap_2_json( showoverflowitem ).
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `visible`.
    temp190-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `snapToRow`.
    temp190-v = z2ui5_cl_util=>boolean_abap_2_json( snaptorow ).
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `width`.
    temp190-v = width.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `id`.
    temp190-v = id.
    INSERT temp190 INTO TABLE temp189.
    temp190-n = `scroll`.
    temp190-v = scroll.
    INSERT temp190 INTO TABLE temp189.
    result = _generic(
                 name   = `HeaderContainer`
                 t_prop = temp189 ).
  ENDMETHOD.

  METHOD header_content.

    result = _generic( name = `headerContent`
                       ns   = ns ).

  ENDMETHOD.

  METHOD header_title.

    result = _generic( name = `headerTitle`
                       ns   = `uxap` ).

  ENDMETHOD.

  METHOD header_toolbar.

    result = _generic( `headerToolbar` ).

  ENDMETHOD.

  METHOD heading.

    result = me.
    result = _generic( name = `heading`
                       ns   = ns ).

  ENDMETHOD.

  METHOD horizontal_layout.
    DATA temp191 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp192 LIKE LINE OF temp191.
    CLEAR temp191.

    temp192-n = `class`.
    temp192-v = class.
    INSERT temp192 INTO TABLE temp191.
    temp192-n = `allowWrapping`.
    temp192-v = z2ui5_cl_util=>boolean_abap_2_json( allowwrapping ).
    INSERT temp192 INTO TABLE temp191.
    temp192-n = `id`.
    temp192-v = id.
    INSERT temp192 INTO TABLE temp191.
    temp192-n = `visible`.
    temp192-v = visible.
    INSERT temp192 INTO TABLE temp191.
    result = _generic(
                 name   = `HorizontalLayout`
                 ns     = `layout`
                 t_prop = temp191 ).
  ENDMETHOD.

  METHOD html.

    DATA temp193 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp194 LIKE LINE OF temp193.
    CLEAR temp193.

    temp194-n = `id`.
    temp194-v = id.
    INSERT temp194 INTO TABLE temp193.
    temp194-n = `content`.
    temp194-v = content.
    INSERT temp194 INTO TABLE temp193.
    temp194-n = `afterRendering`.
    temp194-v = afterrendering.
    INSERT temp194 INTO TABLE temp193.
    temp194-n = `preferDOM`.
    temp194-v = z2ui5_cl_util=>boolean_abap_2_json( preferdom ).
    INSERT temp194 INTO TABLE temp193.
    temp194-n = `sanitizeContent`.
    temp194-v = z2ui5_cl_util=>boolean_abap_2_json( sanitizecontent ).
    INSERT temp194 INTO TABLE temp193.
    temp194-n = `visible`.
    temp194-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp194 INTO TABLE temp193.
    result = _generic( name   = `HTML`
                       ns     = `core`
                       t_prop = temp193 ).

  ENDMETHOD.

  METHOD html_area.
    DATA temp195 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp196 LIKE LINE OF temp195.
    CLEAR temp195.

    temp196-n = `id`.
    temp196-v = id.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `shape`.
    temp196-v = shape.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `coords`.
    temp196-v = coords.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `alt`.
    temp196-v = alt.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `target`.
    temp196-v = target.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `href`.
    temp196-v = href.
    INSERT temp196 INTO TABLE temp195.
    temp196-n = `onclick`.
    temp196-v = onclick.
    INSERT temp196 INTO TABLE temp195.
    result = _generic( name   = `area`
                       ns     = `html`
                       t_prop = temp195 ).
  ENDMETHOD.

  METHOD html_canvas.
    DATA temp197 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp198 LIKE LINE OF temp197.
    CLEAR temp197.

    temp198-n = `id`.
    temp198-v = id.
    INSERT temp198 INTO TABLE temp197.
    temp198-n = `class`.
    temp198-v = class.
    INSERT temp198 INTO TABLE temp197.
    temp198-n = `width`.
    temp198-v = width.
    INSERT temp198 INTO TABLE temp197.
    temp198-n = `height`.
    temp198-v = height.
    INSERT temp198 INTO TABLE temp197.
    temp198-n = `style`.
    temp198-v = style.
    INSERT temp198 INTO TABLE temp197.
    result = _generic( name   = `canvas`
                       ns     = `html`
                       t_prop = temp197 ).
  ENDMETHOD.

  METHOD html_map.
    DATA temp199 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp200 LIKE LINE OF temp199.
    CLEAR temp199.

    temp200-n = `id`.
    temp200-v = id.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `class`.
    temp200-v = class.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `name`.
    temp200-v = name.
    INSERT temp200 INTO TABLE temp199.
    result = _generic( name   = `map`
                       ns     = `html`
                       t_prop = temp199 ).
  ENDMETHOD.

  METHOD icon.
    DATA temp201 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp202 LIKE LINE OF temp201.

    result = me.

    CLEAR temp201.

    temp202-n = `size`.
    temp202-v = size.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `color`.
    temp202-v = color.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `class`.
    temp202-v = class.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `src`.
    temp202-v = src.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `activeColor`.
    temp202-v = activecolor.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `activeBackgroundColor`.
    temp202-v = activebackgroundcolor.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `alt`.
    temp202-v = alt.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `backgroundColor`.
    temp202-v = backgroundcolor.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `height`.
    temp202-v = height.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `width`.
    temp202-v = width.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `id`.
    temp202-v = id.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `press`.
    temp202-v = press.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `hoverBackgroundColor`.
    temp202-v = hoverbackgroundcolor.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `hoverColor`.
    temp202-v = hovercolor.
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `visible`.
    temp202-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `decorative`.
    temp202-v = z2ui5_cl_util=>boolean_abap_2_json( decorative ).
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `noTabStop`.
    temp202-v = z2ui5_cl_util=>boolean_abap_2_json( notabstop ).
    INSERT temp202 INTO TABLE temp201.
    temp202-n = `useIconTooltip`.
    temp202-v = z2ui5_cl_util=>boolean_abap_2_json( useicontooltip ).
    INSERT temp202 INTO TABLE temp201.
    _generic( name   = `Icon`
              ns     = `core`
              t_prop = temp201 ).

  ENDMETHOD.

  METHOD icon_tab_bar.

    DATA temp203 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp204 LIKE LINE OF temp203.
    CLEAR temp203.

    temp204-n = `class`.
    temp204-v = class.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `select`.
    temp204-v = select.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `expand`.
    temp204-v = expand.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `expandable`.
    temp204-v = z2ui5_cl_util=>boolean_abap_2_json( expandable ).
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `expanded`.
    temp204-v = z2ui5_cl_util=>boolean_abap_2_json( expanded ).
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `applyContentPadding`.
    temp204-v = z2ui5_cl_util=>boolean_abap_2_json( applycontentpadding ).
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `backgroundDesign`.
    temp204-v = backgrounddesign.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `enableTabReordering`.
    temp204-v = z2ui5_cl_util=>boolean_abap_2_json( enabletabreordering ).
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `headerBackgroundDesign`.
    temp204-v = headerbackgrounddesign.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `stretchContentHeight`.
    temp204-v = z2ui5_cl_util=>boolean_abap_2_json( stretchcontentheight ).
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `headerMode`.
    temp204-v = headermode.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `maxNestingLevel`.
    temp204-v = maxnestinglevel.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `tabDensityMode`.
    temp204-v = tabdensitymode.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `tabsOverflowMode`.
    temp204-v = tabsoverflowmode.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `items`.
    temp204-v = items.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `id`.
    temp204-v = id.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `content`.
    temp204-v = content.
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `upperCase`.
    temp204-v = z2ui5_cl_util=>boolean_abap_2_json( uppercase ).
    INSERT temp204 INTO TABLE temp203.
    temp204-n = `selectedKey`.
    temp204-v = selectedkey.
    INSERT temp204 INTO TABLE temp203.
    result = _generic(
                 name   = `IconTabBar`
                 t_prop = temp203 ).
  ENDMETHOD.

  METHOD icon_tab_filter.

    DATA temp205 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp206 LIKE LINE OF temp205.
    CLEAR temp205.

    temp206-n = `icon`.
    temp206-v = icon.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `items`.
    temp206-v = items.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `design`.
    temp206-v = design.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `iconColor`.
    temp206-v = iconcolor.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `showAll`.
    temp206-v = z2ui5_cl_util=>boolean_abap_2_json( showall ).
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `iconDensityAware`.
    temp206-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `visible`.
    temp206-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `count`.
    temp206-v = count.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `text`.
    temp206-v = text.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `id`.
    temp206-v = id.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `textDirection`.
    temp206-v = textdirection.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `class`.
    temp206-v = class.
    INSERT temp206 INTO TABLE temp205.
    temp206-n = `key`.
    temp206-v = key.
    INSERT temp206 INTO TABLE temp205.
    result = _generic(
        name   = `IconTabFilter`
        t_prop = temp205 ).
  ENDMETHOD.

  METHOD icon_tab_header.

    DATA temp207 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp208 LIKE LINE OF temp207.
    CLEAR temp207.

    temp208-n = `selectedKey`.
    temp208-v = selectedkey.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `items`.
    temp208-v = items.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `select`.
    temp208-v = select.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `ariaTexts`.
    temp208-v = ariatexts.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `backgroundDesign`.
    temp208-v = backgrounddesign.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `enableTabReordering`.
    temp208-v = z2ui5_cl_util=>boolean_abap_2_json( enabletabreordering ).
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `maxNestingLevel`.
    temp208-v = maxnestinglevel.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `tabDensityMode`.
    temp208-v = tabdensitymode.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `tabsOverflowMode`.
    temp208-v = tabsoverflowmode.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `id`.
    temp208-v = id.
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `visible`.
    temp208-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp208 INTO TABLE temp207.
    temp208-n = `mode`.
    temp208-v = mode.
    INSERT temp208 INTO TABLE temp207.
    result = _generic(
        name   = `IconTabHeader`
        t_prop = temp207 ).

  ENDMETHOD.

  METHOD icon_tab_separator.

    DATA temp209 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp210 LIKE LINE OF temp209.
    CLEAR temp209.

    temp210-n = `icon`.
    temp210-v = icon.
    INSERT temp210 INTO TABLE temp209.
    temp210-n = `iconDensityAware`.
    temp210-v = icondensityaware.
    INSERT temp210 INTO TABLE temp209.
    temp210-n = `id`.
    temp210-v = id.
    INSERT temp210 INTO TABLE temp209.
    temp210-n = `class`.
    temp210-v = class.
    INSERT temp210 INTO TABLE temp209.
    temp210-n = `visible`.
    temp210-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp210 INTO TABLE temp209.
    result = _generic( name   = `IconTabSeparator`
                       t_prop = temp209 ).

  ENDMETHOD.

  METHOD illustrated_message.

    DATA temp211 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp212 LIKE LINE OF temp211.
    CLEAR temp211.

    temp212-n = `enableVerticalResponsiveness`.
    temp212-v = enableverticalresponsiveness.
    INSERT temp212 INTO TABLE temp211.
    temp212-n = `illustrationType`.
    temp212-v = illustrationtype.
    INSERT temp212 INTO TABLE temp211.
    temp212-n = `enableFormattedText`.
    temp212-v = z2ui5_cl_util=>boolean_abap_2_json( enableformattedtext ).
    INSERT temp212 INTO TABLE temp211.
    temp212-n = `illustrationSize`.
    temp212-v = illustrationsize.
    INSERT temp212 INTO TABLE temp211.
    temp212-n = `description`.
    temp212-v = description.
    INSERT temp212 INTO TABLE temp211.
    temp212-n = `title`.
    temp212-v = title.
    INSERT temp212 INTO TABLE temp211.
    result = _generic(
        name   = `IllustratedMessage`
        t_prop = temp211 ).
  ENDMETHOD.

  METHOD image.
    DATA temp213 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp214 LIKE LINE OF temp213.
    result = me.

    CLEAR temp213.

    temp214-n = `id`.
    temp214-v = id.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `src`.
    temp214-v = src.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `class`.
    temp214-v = class.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `height`.
    temp214-v = height.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `alt`.
    temp214-v = alt.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `activeSrc`.
    temp214-v = activesrc.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `ariaHasPopup`.
    temp214-v = ariahaspopup.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `backgroundPosition`.
    temp214-v = backgroundposition.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `backgroundRepeat`.
    temp214-v = backgroundrepeat.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `backgroundSize`.
    temp214-v = backgroundsize.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `mode`.
    temp214-v = mode.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `useMap`.
    temp214-v = usemap.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `width`.
    temp214-v = width.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `error`.
    temp214-v = error.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `press`.
    temp214-v = press.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `load`.
    temp214-v = load.
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `decorative`.
    temp214-v = z2ui5_cl_util=>boolean_abap_2_json( decorative ).
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `densityAware`.
    temp214-v = z2ui5_cl_util=>boolean_abap_2_json( densityaware ).
    INSERT temp214 INTO TABLE temp213.
    temp214-n = `lazyLoading`.
    temp214-v = z2ui5_cl_util=>boolean_abap_2_json( lazyloading ).
    INSERT temp214 INTO TABLE temp213.
    _generic( name   = `Image`
              t_prop = temp213 ).
  ENDMETHOD.

  METHOD image_content.

    DATA temp215 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp216 LIKE LINE OF temp215.
    CLEAR temp215.

    temp216-n = `src`.
    temp216-v = src.
    INSERT temp216 INTO TABLE temp215.
    temp216-n = `description`.
    temp216-v = description.
    INSERT temp216 INTO TABLE temp215.
    temp216-n = `visible`.
    temp216-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp216 INTO TABLE temp215.
    temp216-n = `class`.
    temp216-v = class.
    INSERT temp216 INTO TABLE temp215.
    temp216-n = `press`.
    temp216-v = press.
    INSERT temp216 INTO TABLE temp215.
    result = _generic( name   = `ImageContent`
                       t_prop = temp215 ).

  ENDMETHOD.

  METHOD info_label.
    DATA temp217 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp218 LIKE LINE OF temp217.
    CLEAR temp217.

    temp218-n = `id`.
    temp218-v = id.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `class`.
    temp218-v = class.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `text`.
    temp218-v = text.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `renderMode `.
    temp218-v = rendermode.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `colorScheme`.
    temp218-v = colorscheme.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `displayOnly`.
    temp218-v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ).
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `icon`.
    temp218-v = icon.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `textDirection`.
    temp218-v = textdirection.
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `visible`.
    temp218-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp218 INTO TABLE temp217.
    temp218-n = `width`.
    temp218-v = width.
    INSERT temp218 INTO TABLE temp217.
    result = _generic( name   = `InfoLabel`
                       ns     = `tnt`
                       t_prop = temp217 ).

  ENDMETHOD.

  METHOD input.
    DATA temp219 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp220 LIKE LINE OF temp219.
    result = me.

    CLEAR temp219.

    temp220-n = `id`.
    temp220-v = id.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `placeholder`.
    temp220-v = placeholder.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `type`.
    temp220-v = type.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `maxLength`.
    temp220-v = maxlength.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `showClearIcon`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `description`.
    temp220-v = description.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `editable`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `enabled`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `visible`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `enableTableAutoPopinMode`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( enabletableautopopinmode ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `enableSuggestionsHighlighting`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( enablesuggestionshighlighting ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `showTableSuggestionValueHelp`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( showtablesuggestionvaluehelp ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `valueState`.
    temp220-v = valuestate.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `valueStateText`.
    temp220-v = valuestatetext.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `value`.
    temp220-v = value.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `required`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `suggest`.
    temp220-v = suggest.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `suggestionItems`.
    temp220-v = suggestionitems.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `suggestionRows`.
    temp220-v = suggestionrows.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `showSuggestion`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( showsuggestion ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `valueHelpRequest`.
    temp220-v = valuehelprequest.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `autocomplete`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( autocomplete ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `valueLiveUpdate`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( valueliveupdate ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `submit`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( submit ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `showValueHelp`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluehelp ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `valueHelpOnly`.
    temp220-v = z2ui5_cl_util=>boolean_abap_2_json( valuehelponly ).
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `class`.
    temp220-v = class.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `change`.
    temp220-v = change.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `maxSuggestionWidth`.
    temp220-v = maxsuggestionwidth.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `width`.
    temp220-v = width.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `textFormatter`.
    temp220-v = textformatter.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `startSuggestion`.
    temp220-v = startsuggestion.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `valueHelpIconSrc`.
    temp220-v = valuehelpiconsrc.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `textFormatMode`.
    temp220-v = textformatmode.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `fieldWidth`.
    temp220-v = fieldwidth.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `ariaLabelledBy`.
    temp220-v = arialabelledby.
    INSERT temp220 INTO TABLE temp219.
    temp220-n = `ariaDescribedBy`.
    temp220-v = ariadescribedby.
    INSERT temp220 INTO TABLE temp219.
    _generic(
        name   = `Input`
        t_prop = temp219 ).
  ENDMETHOD.

  METHOD input_list_item.
    DATA temp221 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp222 LIKE LINE OF temp221.
    CLEAR temp221.

    temp222-n = `label`.
    temp222-v = label.
    INSERT temp222 INTO TABLE temp221.
    result = _generic( name   = `InputListItem`
                       t_prop = temp221 ).
  ENDMETHOD.

  METHOD interact_bar_chart.
    DATA temp223 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp224 LIKE LINE OF temp223.
    CLEAR temp223.

    temp224-n = `selectionChanged`.
    temp224-v = selectionchanged.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `selectionEnabled`.
    temp224-v = z2ui5_cl_util=>boolean_abap_2_json( selectionenabled ).
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `showError`.
    temp224-v = z2ui5_cl_util=>boolean_abap_2_json( showerror ).
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `press`.
    temp224-v = press.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `labelWidth`.
    temp224-v = labelwidth.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `bars`.
    temp224-v = bars.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `errorMessageTitle`.
    temp224-v = errormessagetitle.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `displayedBars`.
    temp224-v = displayedbars.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `min`.
    temp224-v = min.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `max`.
    temp224-v = max.
    INSERT temp224 INTO TABLE temp223.
    temp224-n = `errorMessage`.
    temp224-v = errormessage.
    INSERT temp224 INTO TABLE temp223.
    result = _generic(
        name   = `InteractiveBarChart`
        ns     = `mchart`
        t_prop = temp223 ).
  ENDMETHOD.

  METHOD interact_bar_chart_bar.
    DATA temp225 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp226 LIKE LINE OF temp225.
    CLEAR temp225.

    temp226-n = `label`.
    temp226-v = label.
    INSERT temp226 INTO TABLE temp225.
    temp226-n = `displayedValue`.
    temp226-v = displayedvalue.
    INSERT temp226 INTO TABLE temp225.
    temp226-n = `value`.
    temp226-v = value.
    INSERT temp226 INTO TABLE temp225.
    temp226-n = `selected`.
    temp226-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp226 INTO TABLE temp225.
    temp226-n = `color`.
    temp226-v = color.
    INSERT temp226 INTO TABLE temp225.
    result = _generic( name   = `InteractiveBarChartBar`
                       ns     = `mchart`
                       t_prop = temp225 ).
  ENDMETHOD.

  METHOD interact_donut_chart.
    DATA temp227 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp228 LIKE LINE OF temp227.
    CLEAR temp227.

    temp228-n = `selectionChanged`.
    temp228-v = selectionchanged.
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `selectionEnabled`.
    temp228-v = z2ui5_cl_util=>boolean_abap_2_json( selectionenabled ).
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `showError`.
    temp228-v = z2ui5_cl_util=>boolean_abap_2_json( showerror ).
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `errorMessageTitle`.
    temp228-v = errormessagetitle.
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `errorMessage`.
    temp228-v = errormessage.
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `displayedSegments`.
    temp228-v = displayedsegments.
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `segments`.
    temp228-v = segments.
    INSERT temp228 INTO TABLE temp227.
    temp228-n = `press`.
    temp228-v = press.
    INSERT temp228 INTO TABLE temp227.
    result = _generic(
        name   = `InteractiveDonutChart`
        ns     = `mchart`
        t_prop = temp227 ).
  ENDMETHOD.

  METHOD interact_donut_chart_segment.
    DATA temp229 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp230 LIKE LINE OF temp229.
    CLEAR temp229.

    temp230-n = `label`.
    temp230-v = label.
    INSERT temp230 INTO TABLE temp229.
    temp230-n = `displayedValue`.
    temp230-v = displayedvalue.
    INSERT temp230 INTO TABLE temp229.
    temp230-n = `value`.
    temp230-v = value.
    INSERT temp230 INTO TABLE temp229.
    temp230-n = `selected`.
    temp230-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp230 INTO TABLE temp229.
    temp230-n = `color`.
    temp230-v = color.
    INSERT temp230 INTO TABLE temp229.
    result = _generic( name   = `InteractiveDonutChartSegment`
                       ns     = `mchart`
                       t_prop = temp229 ).
  ENDMETHOD.

  METHOD interact_line_chart.
    DATA temp231 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp232 LIKE LINE OF temp231.
    CLEAR temp231.

    temp232-n = `selectionChanged`.
    temp232-v = selectionchanged.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `showError`.
    temp232-v = z2ui5_cl_util=>boolean_abap_2_json( showerror ).
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `press`.
    temp232-v = press.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `errorMessageTitle`.
    temp232-v = errormessagetitle.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `errorMessage`.
    temp232-v = errormessage.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `precedingPoint`.
    temp232-v = precedingpoint.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `points`.
    temp232-v = points.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `succeedingPoint`.
    temp232-v = succeedingpoint.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `displayedPoints`.
    temp232-v = displayedpoints.
    INSERT temp232 INTO TABLE temp231.
    temp232-n = `selectionEnabled`.
    temp232-v = selectionenabled.
    INSERT temp232 INTO TABLE temp231.
    result = _generic( name   = `InteractiveLineChart`
                       ns     = `mchart`
                       t_prop = temp231 ).
  ENDMETHOD.

  METHOD interact_line_chart_point.
    DATA temp233 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp234 LIKE LINE OF temp233.
    CLEAR temp233.

    temp234-n = `label`.
    temp234-v = label.
    INSERT temp234 INTO TABLE temp233.
    temp234-n = `secondaryLabel`.
    temp234-v = secondarylabel.
    INSERT temp234 INTO TABLE temp233.
    temp234-n = `value`.
    temp234-v = value.
    INSERT temp234 INTO TABLE temp233.
    temp234-n = `displayedValue`.
    temp234-v = displayedvalue.
    INSERT temp234 INTO TABLE temp233.
    temp234-n = `selected`.
    temp234-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp234 INTO TABLE temp233.
    result = _generic(
                 name   = `InteractiveLineChartPoint`
                 ns     = `mchart`
                 t_prop = temp233 ).
  ENDMETHOD.

  METHOD intermediary.
    result = _generic( name = `intermediary`
                       ns   = `commons` ).
  ENDMETHOD.

  METHOD interval_headers.
    result = _generic( `intervalHeaders` ).
  ENDMETHOD.

  METHOD item.
    DATA temp235 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp236 LIKE LINE OF temp235.
    result = me.

    CLEAR temp235.

    temp236-n = `key`.
    temp236-v = key.
    INSERT temp236 INTO TABLE temp235.
    temp236-n = `text`.
    temp236-v = text.
    INSERT temp236 INTO TABLE temp235.
    _generic( name   = `Item`
              ns     = `core`
              t_prop = temp235 ).
  ENDMETHOD.

  METHOD items.
    result = _generic( name = `items`
                       ns   = ns ).
  ENDMETHOD.

  METHOD label.
    DATA temp237 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp238 LIKE LINE OF temp237.
    result = me.

    CLEAR temp237.

    temp238-n = `text`.
    temp238-v = text.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `displayOnly`.
    temp238-v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ).
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `required`.
    temp238-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `showColon`.
    temp238-v = z2ui5_cl_util=>boolean_abap_2_json( showcolon ).
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `textAlign`.
    temp238-v = textalign.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `textDirection`.
    temp238-v = textdirection.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `vAlign`.
    temp238-v = valign.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `width`.
    temp238-v = width.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `wrapping`.
    temp238-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `wrappingType`.
    temp238-v = wrappingtype.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `design`.
    temp238-v = design.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `id`.
    temp238-v = id.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `class`.
    temp238-v = class.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `labelFor`.
    temp238-v = labelfor.
    INSERT temp238 INTO TABLE temp237.
    temp238-n = `visible`.
    temp238-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp238 INTO TABLE temp237.
    _generic( name   = `Label`
              t_prop = temp237 ).
  ENDMETHOD.

  METHOD lanes.
    result = _generic( name = `lanes`
                       ns   = `commons` ).
  ENDMETHOD.

  METHOD layered_layout.
    DATA temp239 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp240 LIKE LINE OF temp239.
    CLEAR temp239.

    temp240-n = `id`.
    temp240-v = id.
    INSERT temp240 INTO TABLE temp239.
    temp240-n = `class`.
    temp240-v = class.
    INSERT temp240 INTO TABLE temp239.
    temp240-n = `lineSpacingFactor`.
    temp240-v = linespacingfactor.
    INSERT temp240 INTO TABLE temp239.
    temp240-n = `nodePlacement`.
    temp240-v = nodeplacement.
    INSERT temp240 INTO TABLE temp239.
    temp240-n = `nodeSpacing`.
    temp240-v = nodespacing.
    INSERT temp240 INTO TABLE temp239.
    temp240-n = `mergeEdges`.
    temp240-v = z2ui5_cl_util=>boolean_abap_2_json( mergeedges ).
    INSERT temp240 INTO TABLE temp239.
    result = _generic( name   = `LayeredLayout`
                       ns     = `nglayout`
                       t_prop = temp239 ).
  ENDMETHOD.

  METHOD layout_algorithm.
    result = _generic( name = `layoutAlgorithm`
                       ns   = `networkgraph` ).
  ENDMETHOD.

  METHOD layout_data.
    result = _generic( ns   = ns
                       name = `layoutData` ).
  ENDMETHOD.

  METHOD legend.

    DATA temp241 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp242 LIKE LINE OF temp241.
    CLEAR temp241.

    temp242-n = `id`.
    temp242-v = id.
    INSERT temp242 INTO TABLE temp241.
    temp242-n = `caption`.
    temp242-v = caption.
    INSERT temp242 INTO TABLE temp241.
    temp242-n = `items`.
    temp242-v = items.
    INSERT temp242 INTO TABLE temp241.
    result = _generic( name   = `Legend`
                       ns     = `vbm`
                       t_prop = temp241 ).

  ENDMETHOD.

  METHOD legenditem.

    DATA temp243 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp244 LIKE LINE OF temp243.
    CLEAR temp243.

    temp244-n = `id`.
    temp244-v = id.
    INSERT temp244 INTO TABLE temp243.
    temp244-n = `text`.
    temp244-v = text.
    INSERT temp244 INTO TABLE temp243.
    temp244-n = `color`.
    temp244-v = color.
    INSERT temp244 INTO TABLE temp243.
    result = _generic( name   = `LegendItem`
                       ns     = `vbm`
                       t_prop = temp243 ).

  ENDMETHOD.

  METHOD legend_area.

    result = _generic( name = `legend`
                       ns   = `vbm` ).

  ENDMETHOD.

  METHOD library_shape.
    DATA temp245 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp246 LIKE LINE OF temp245.
    CLEAR temp245.

    temp246-n = `id`.
    temp246-v = id.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `class`.
    temp246-v = class.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `animationOnChange`.
    temp246-v = z2ui5_cl_util=>boolean_abap_2_json( animationonchange ).
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `definition`.
    temp246-v = definition.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `fillColor`.
    temp246-v = fillcolor.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `fillingAngle`.
    temp246-v = fillingangle.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `fillingDirection`.
    temp246-v = fillingdirection.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `fillingType`.
    temp246-v = fillingtype.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `height`.
    temp246-v = height.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `horizontalAlignment`.
    temp246-v = horizontalalignment.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `shapeId`.
    temp246-v = shapeid.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `strokeColor`.
    temp246-v = strokecolor.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `strokeWidth`.
    temp246-v = strokewidth.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `verticalAlignment`.
    temp246-v = verticalalignment.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `width`.
    temp246-v = width.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `x`.
    temp246-v = x.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `y`.
    temp246-v = y.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `afterShapeLoaded`.
    temp246-v = aftershapeloaded.
    INSERT temp246 INTO TABLE temp245.
    temp246-n = `visible`.
    temp246-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp246 INTO TABLE temp245.
    result = _generic(
        name   = `LibraryShape`
        ns     = `si`
        t_prop = temp245 ).
  ENDMETHOD.

  METHOD light_box.
    DATA temp247 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp248 LIKE LINE OF temp247.
    CLEAR temp247.

    temp248-n = `id`.
    temp248-v = id.
    INSERT temp248 INTO TABLE temp247.
    temp248-n = `class`.
    temp248-v = class.
    INSERT temp248 INTO TABLE temp247.
    temp248-n = `visible`.
    temp248-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp248 INTO TABLE temp247.
    result = _generic( name   = `LightBox`
                       t_prop = temp247 ).
  ENDMETHOD.

  METHOD light_box_item.
    DATA temp249 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp250 LIKE LINE OF temp249.
    CLEAR temp249.

    temp250-n = `alt`.
    temp250-v = alt.
    INSERT temp250 INTO TABLE temp249.
    temp250-n = `imageSrc`.
    temp250-v = imagesrc.
    INSERT temp250 INTO TABLE temp249.
    temp250-n = `subtitle`.
    temp250-v = subtitle.
    INSERT temp250 INTO TABLE temp249.
    temp250-n = `title`.
    temp250-v = title.
    INSERT temp250 INTO TABLE temp249.
    result = _generic( name   = `LightBoxItem`
                       t_prop = temp249 ).
  ENDMETHOD.

  METHOD line.

    DATA temp251 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp252 LIKE LINE OF temp251.
    CLEAR temp251.

    temp252-n = `id`.
    temp252-v = id.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `class`.
    temp252-v = class.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `arrowOrientation`.
    temp252-v = arroworientation.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `arrowPosition`.
    temp252-v = arrowposition.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `description`.
    temp252-v = description.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `from`.
    temp252-v = from.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `lineType`.
    temp252-v = linetype.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `status`.
    temp252-v = status.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `title`.
    temp252-v = title.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `to`.
    temp252-v = to.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `hover`.
    temp252-v = hover.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `press`.
    temp252-v = press.
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `stretchToCenter`.
    temp252-v = z2ui5_cl_util=>boolean_abap_2_json( stretchtocenter ).
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `selected`.
    temp252-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp252 INTO TABLE temp251.
    temp252-n = `visible`.
    temp252-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp252 INTO TABLE temp251.
    result = _generic( name   = `Line`
                       ns     = `networkgraph`
                       t_prop = temp251 ).

  ENDMETHOD.

  METHOD lines.
    DATA temp253 TYPE string.
    CASE ns.
      WHEN ``.
        temp253 = `networkgraph`.
      WHEN OTHERS.
        temp253 = ns.
    ENDCASE.
    result = _generic( name = `lines`
                       ns   = temp253 ).
  ENDMETHOD.

  METHOD line_micro_chart.
    DATA temp254 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp255 LIKE LINE OF temp254.
    result = me.

    CLEAR temp254.

    temp255-n = `color`.
    temp255-v = color.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `height`.
    temp255-v = height.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `leftBottomLabel`.
    temp255-v = leftbottomlabel.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `leftTopLabel`.
    temp255-v = lefttoplabel.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `maxXValue`.
    temp255-v = maxxvalue.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `minXValue`.
    temp255-v = minxvalue.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `minYValue`.
    temp255-v = minyvalue.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `rightBottomLabel`.
    temp255-v = rightbottomlabel.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `rightTopLabel`.
    temp255-v = righttoplabel.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `size`.
    temp255-v = size.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `threshold`.
    temp255-v = threshold.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `thresholdDisplayValue`.
    temp255-v = thresholddisplayvalue.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `width`.
    temp255-v = width.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `press`.
    temp255-v = press.
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `hideOnNoData`.
    temp255-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `showBottomLabels`.
    temp255-v = z2ui5_cl_util=>boolean_abap_2_json( showbottomlabels ).
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `showPoints`.
    temp255-v = z2ui5_cl_util=>boolean_abap_2_json( showpoints ).
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `showThresholdLine`.
    temp255-v = z2ui5_cl_util=>boolean_abap_2_json( showthresholdline ).
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `showThresholdValue`.
    temp255-v = z2ui5_cl_util=>boolean_abap_2_json( showthresholdvalue ).
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `showTopLabels`.
    temp255-v = z2ui5_cl_util=>boolean_abap_2_json( showtoplabels ).
    INSERT temp255 INTO TABLE temp254.
    temp255-n = `maxYValue`.
    temp255-v = maxyvalue.
    INSERT temp255 INTO TABLE temp254.
    _generic(
        name   = `LineMicroChart`
        ns     = `mchart`
        t_prop = temp254 ).
  ENDMETHOD.

  METHOD line_micro_chart_empszd_point.
    DATA temp256 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp257 LIKE LINE OF temp256.
    CLEAR temp256.

    temp257-n = `x`.
    temp257-v = x.
    INSERT temp257 INTO TABLE temp256.
    temp257-n = `y`.
    temp257-v = y.
    INSERT temp257 INTO TABLE temp256.
    temp257-n = `color`.
    temp257-v = color.
    INSERT temp257 INTO TABLE temp256.
    temp257-n = `show`.
    temp257-v = z2ui5_cl_util=>boolean_abap_2_json( show ).
    INSERT temp257 INTO TABLE temp256.
    result = _generic( name   = `LineMicroChartEmphasizedPoint`
                       ns     = `mchart`
                       t_prop = temp256 ).
  ENDMETHOD.

  METHOD line_micro_chart_line.
    DATA temp258 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp259 LIKE LINE OF temp258.
    CLEAR temp258.

    temp259-n = `points`.
    temp259-v = points.
    INSERT temp259 INTO TABLE temp258.
    temp259-n = `color`.
    temp259-v = color.
    INSERT temp259 INTO TABLE temp258.
    temp259-n = `type`.
    temp259-v = type.
    INSERT temp259 INTO TABLE temp258.
    result = _generic( name   = `LineMicroChartLine`
                       ns     = `mchart`
                       t_prop = temp258 ).
  ENDMETHOD.

  METHOD line_micro_chart_point.
    DATA temp260 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp261 LIKE LINE OF temp260.
    CLEAR temp260.

    temp261-n = `x`.
    temp261-v = x.
    INSERT temp261 INTO TABLE temp260.
    temp261-n = `y`.
    temp261-v = y.
    INSERT temp261 INTO TABLE temp260.
    result = _generic( name   = `LineMicroChartPoint`
                       ns     = `mchart`
                       t_prop = temp260 ).
  ENDMETHOD.

  METHOD link.
    DATA temp262 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp263 LIKE LINE OF temp262.
    result = me.

    CLEAR temp262.

    temp263-n = `text`.
    temp263-v = text.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `target`.
    temp263-v = target.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `href`.
    temp263-v = href.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `press`.
    temp263-v = press.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `id`.
    temp263-v = id.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `class`.
    temp263-v = class.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `accessibleRole`.
    temp263-v = accessiblerole.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `ariaHasPopup`.
    temp263-v = ariahaspopup.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `emptyIndicatorMode`.
    temp263-v = emptyindicatormode.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `rel`.
    temp263-v = rel.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `subtle`.
    temp263-v = z2ui5_cl_util=>boolean_abap_2_json( subtle ).
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `textAlign`.
    temp263-v = textalign.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `textDirection`.
    temp263-v = textdirection.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `validateUrl`.
    temp263-v = z2ui5_cl_util=>boolean_abap_2_json( validateurl ).
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `width`.
    temp263-v = width.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `wrapping`.
    temp263-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `emphasized`.
    temp263-v = z2ui5_cl_util=>boolean_abap_2_json( emphasized ).
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `enabled`.
    temp263-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `endIcon`.
    temp263-v = endicon.
    INSERT temp263 INTO TABLE temp262.
    temp263-n = `icon`.
    temp263-v = icon.
    INSERT temp263 INTO TABLE temp262.
    _generic( name   = `Link`
              ns     = ns
              t_prop = temp262 ).
  ENDMETHOD.

  METHOD link_tile_content.
    DATA temp264 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp265 LIKE LINE OF temp264.
    CLEAR temp264.

    temp265-n = `iconSrc`.
    temp265-v = iconsrc.
    INSERT temp265 INTO TABLE temp264.
    temp265-n = `linkHref`.
    temp265-v = linkhref.
    INSERT temp265 INTO TABLE temp264.
    temp265-n = `linkText`.
    temp265-v = linktext.
    INSERT temp265 INTO TABLE temp264.
    temp265-n = `linkPress`.
    temp265-v = linkpress.
    INSERT temp265 INTO TABLE temp264.
    result = _generic( name   = `LinkTileContent`
                       t_prop = temp264 ).
  ENDMETHOD.

  METHOD list.
    DATA temp266 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp267 LIKE LINE OF temp266.
    CLEAR temp266.

    temp267-n = `headerText`.
    temp267-v = headertext.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `items`.
    temp267-v = items.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `mode`.
    temp267-v = mode.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `class`.
    temp267-v = class.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `itemPress`.
    temp267-v = itempress.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `select`.
    temp267-v = select.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `selectionChange`.
    temp267-v = selectionchange.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `showSeparators`.
    temp267-v = showseparators.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `footerText`.
    temp267-v = footertext.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `growingDirection`.
    temp267-v = growingdirection.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `growingThreshold`.
    temp267-v = growingthreshold.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `growingTriggerText`.
    temp267-v = growingtriggertext.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `headerLevel`.
    temp267-v = headerlevel.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `multiSelectMode`.
    temp267-v = multiselectmode.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `noDataText`.
    temp267-v = nodatatext.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `id`.
    temp267-v = id.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `sticky`.
    temp267-v = sticky.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `delete`.
    temp267-v = delete.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `backgroundDesign`.
    temp267-v = backgrounddesign.
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `modeAnimationOn`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( modeanimationon ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `growingScrollToLoad`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `includeItemInSelection`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `growing`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `inset`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( inset ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `rememberSelections`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `showUnread`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( showunread ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `visible`.
    temp267-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp267 INTO TABLE temp266.
    temp267-n = `noData`.
    temp267-v = nodata.
    INSERT temp267 INTO TABLE temp266.
    result = _generic(
                 name   = `List`
                 t_prop = temp266 ).
  ENDMETHOD.

  METHOD list_item.
    DATA temp268 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp269 LIKE LINE OF temp268.
    result = me.

    CLEAR temp268.

    temp269-n = `text`.
    temp269-v = text.
    INSERT temp269 INTO TABLE temp268.
    temp269-n = `icon`.
    temp269-v = icon.
    INSERT temp269 INTO TABLE temp268.
    temp269-n = `key`.
    temp269-v = key.
    INSERT temp269 INTO TABLE temp268.
    temp269-n = `textDirection`.
    temp269-v = textdirection.
    INSERT temp269 INTO TABLE temp268.
    temp269-n = `enabled`.
    temp269-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp269 INTO TABLE temp268.
    temp269-n = `additionalText`.
    temp269-v = additionaltext.
    INSERT temp269 INTO TABLE temp268.
    _generic( name   = `ListItem`
              ns     = `core`
              t_prop = temp268 ).
  ENDMETHOD.

  METHOD main_content.
    result = _generic( name = `mainContent`
                       ns   = `f` ).
  ENDMETHOD.

  METHOD main_contents.

    result = _generic( name = `mainContents`
                       ns   = `tnt` ).

  ENDMETHOD.

  METHOD map_container.

    DATA temp270 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp271 LIKE LINE OF temp270.
    CLEAR temp270.

    temp271-n = `id`.
    temp271-v = id.
    INSERT temp271 INTO TABLE temp270.
    temp271-n = `autoAdjustHeight`.
    temp271-v = z2ui5_cl_util=>boolean_abap_2_json( autoadjustheight ).
    INSERT temp271 INTO TABLE temp270.
    temp271-n = `showHome`.
    temp271-v = z2ui5_cl_util=>boolean_abap_2_json( showhome ).
    INSERT temp271 INTO TABLE temp270.
    result = _generic( name   = `MapContainer`
                       ns     = `vk`
                       t_prop = temp270 ).

  ENDMETHOD.

  METHOD markers.
    result = _generic( name = `markers`
                       ns   = ns ).
  ENDMETHOD.

  METHOD markers_as_status.
    result = _generic( name = `markersAsStatus`
                       ns   = `upload` ).
  ENDMETHOD.

  METHOD mask_input.
    DATA temp272 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp273 LIKE LINE OF temp272.
    result = me.

    CLEAR temp272.

    temp273-n = `placeholder`.
    temp273-v = placeholder.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `mask`.
    temp273-v = mask.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `name`.
    temp273-v = name.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `textAlign`.
    temp273-v = textalign.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `textDirection`.
    temp273-v = textdirection.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `value`.
    temp273-v = value.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `width`.
    temp273-v = width.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `liveChange`.
    temp273-v = livechange.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `change`.
    temp273-v = change.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `valueState`.
    temp273-v = valuestate.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `valueStateText`.
    temp273-v = valuestatetext.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `placeholderSymbol`.
    temp273-v = placeholdersymbol.
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `required`.
    temp273-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `showClearIcon`.
    temp273-v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ).
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `showValueStateMessage`.
    temp273-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `visible`.
    temp273-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp273 INTO TABLE temp272.
    temp273-n = `fieldWidth`.
    temp273-v = fieldwidth.
    INSERT temp273 INTO TABLE temp272.
    _generic( name   = `MaskInput`
              t_prop = temp272 ).
  ENDMETHOD.

  METHOD mask_input_rule.
    DATA temp274 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp275 LIKE LINE OF temp274.
    CLEAR temp274.

    temp275-n = `maskFormatSymbol`.
    temp275-v = maskformatsymbol.
    INSERT temp275 INTO TABLE temp274.
    temp275-n = `regex`.
    temp275-v = regex.
    INSERT temp275 INTO TABLE temp274.
    result = _generic( name   = `MaskInputRule`
                       t_prop = temp274 ).
  ENDMETHOD.

  METHOD master_pages.
    result = _generic( `masterPages` ).
  ENDMETHOD.

  METHOD menu_button.
    DATA temp276 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp277 LIKE LINE OF temp276.
    CLEAR temp276.

    temp277-n = `buttonMode`.
    temp277-v = buttonmode.
    INSERT temp277 INTO TABLE temp276.
    temp277-n = `defaultAction`.
    temp277-v = defaultaction.
    INSERT temp277 INTO TABLE temp276.
    temp277-n = `text`.
    temp277-v = text.
    INSERT temp277 INTO TABLE temp276.
    temp277-n = `enabled`.
    temp277-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp277 INTO TABLE temp276.
    temp277-n = `activeIcon`.
    temp277-v = activeicon.
    INSERT temp277 INTO TABLE temp276.
    temp277-n = `type`.
    temp277-v = type.
    INSERT temp277 INTO TABLE temp276.
    result = _generic( name   = `MenuButton`
                       t_prop = temp276 ).
  ENDMETHOD.

  METHOD menu_item.
    DATA temp278 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp279 LIKE LINE OF temp278.
    result = me.

    CLEAR temp278.

    temp279-n = `press`.
    temp279-v = press.
    INSERT temp279 INTO TABLE temp278.
    temp279-n = `text`.
    temp279-v = text.
    INSERT temp279 INTO TABLE temp278.
    temp279-n = `icon`.
    temp279-v = icon.
    INSERT temp279 INTO TABLE temp278.
    _generic( name   = `MenuItem`
              t_prop = temp278 ).
  ENDMETHOD.

  METHOD message_item.
    DATA temp280 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp281 LIKE LINE OF temp280.
    CLEAR temp280.

    temp281-n = `type`.
    temp281-v = type.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `title`.
    temp281-v = title.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `subtitle`.
    temp281-v = subtitle.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `description`.
    temp281-v = description.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `longtextUrl`.
    temp281-v = longtexturl.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `textDirection`.
    temp281-v = textdirection.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `groupName`.
    temp281-v = groupname.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `activeTitle`.
    temp281-v = z2ui5_cl_util=>boolean_abap_2_json( activetitle ).
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `counter`.
    temp281-v = counter.
    INSERT temp281 INTO TABLE temp280.
    temp281-n = `markupDescription`.
    temp281-v = z2ui5_cl_util=>boolean_abap_2_json( markupdescription ).
    INSERT temp281 INTO TABLE temp280.
    result = _generic(
        name   = `MessageItem`
        t_prop = temp280 ).
  ENDMETHOD.

  METHOD message_page.
    DATA temp282 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp283 LIKE LINE OF temp282.
    CLEAR temp282.

    temp283-n = `showHeader`.
    temp283-v = z2ui5_cl_util=>boolean_abap_2_json( show_header ).
    INSERT temp283 INTO TABLE temp282.
    temp283-n = `description`.
    temp283-v = description.
    INSERT temp283 INTO TABLE temp282.
    temp283-n = `icon`.
    temp283-v = icon.
    INSERT temp283 INTO TABLE temp282.
    temp283-n = `text`.
    temp283-v = text.
    INSERT temp283 INTO TABLE temp282.
    temp283-n = `enableFormattedText`.
    temp283-v = z2ui5_cl_util=>boolean_abap_2_json( enableformattedtext ).
    INSERT temp283 INTO TABLE temp282.
    result = _generic(
                 name   = `MessagePage`
                 t_prop = temp282 ).
  ENDMETHOD.

  METHOD message_popover.
    DATA temp284 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp285 LIKE LINE OF temp284.
    CLEAR temp284.

    temp285-n = `items`.
    temp285-v = items.
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `activeTitlePress`.
    temp285-v = activetitlepress.
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `placement`.
    temp285-v = placement.
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `listSelect`.
    temp285-v = listselect.
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `afterClose`.
    temp285-v = afterclose.
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `beforeClose`.
    temp285-v = beforeclose.
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `initiallyExpanded`.
    temp285-v = z2ui5_cl_util=>boolean_abap_2_json( initiallyexpanded ).
    INSERT temp285 INTO TABLE temp284.
    temp285-n = `groupItems`.
    temp285-v = z2ui5_cl_util=>boolean_abap_2_json( groupitems ).
    INSERT temp285 INTO TABLE temp284.
    result = _generic(
        name   = `MessagePopover`
        t_prop = temp284 ).
  ENDMETHOD.

  METHOD message_strip.
    DATA temp286 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp287 LIKE LINE OF temp286.
    result = me.

    CLEAR temp286.

    temp287-n = `text`.
    temp287-v = text.
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `type`.
    temp287-v = type.
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `showIcon`.
    temp287-v = z2ui5_cl_util=>boolean_abap_2_json( showicon ).
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `customIcon`.
    temp287-v = customicon.
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `visible`.
    temp287-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `showCloseButton`.
    temp287-v = z2ui5_cl_util=>boolean_abap_2_json( showclosebutton ).
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `class`.
    temp287-v = class.
    INSERT temp287 INTO TABLE temp286.
    temp287-n = `enableFormattedText`.
    temp287-v = z2ui5_cl_util=>boolean_abap_2_json( enableformattedtext ).
    INSERT temp287 INTO TABLE temp286.
    _generic(
        name   = `MessageStrip`
        t_prop = temp286 ).
  ENDMETHOD.

  METHOD message_view.

    DATA temp288 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp289 LIKE LINE OF temp288.
    CLEAR temp288.

    temp289-n = `items`.
    temp289-v = items.
    INSERT temp289 INTO TABLE temp288.
    temp289-n = `groupItems`.
    temp289-v = z2ui5_cl_util=>boolean_abap_2_json( groupitems ).
    INSERT temp289 INTO TABLE temp288.
    result = _generic( name   = `MessageView`
                       t_prop = temp288 ).
  ENDMETHOD.

  METHOD micro_process_flow.
    DATA temp290 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp291 LIKE LINE OF temp290.
    CLEAR temp290.

    temp291-n = `id`.
    temp291-v = id.
    INSERT temp291 INTO TABLE temp290.
    temp291-n = `class`.
    temp291-v = class.
    INSERT temp291 INTO TABLE temp290.
    temp291-n = `renderType`.
    temp291-v = rendertype.
    INSERT temp291 INTO TABLE temp290.
    temp291-n = `width`.
    temp291-v = width.
    INSERT temp291 INTO TABLE temp290.
    temp291-n = `ariaLabel`.
    temp291-v = arialabel.
    INSERT temp291 INTO TABLE temp290.
    result = _generic( name   = `MicroProcessFlow`
                       ns     = `commons`
                       t_prop = temp290 ).
  ENDMETHOD.

  METHOD micro_process_flow_item.
    DATA temp292 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp293 LIKE LINE OF temp292.
    CLEAR temp292.

    temp293-n = `id`.
    temp293-v = id.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `class`.
    temp293-v = class.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `press`.
    temp293-v = press.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `title`.
    temp293-v = title.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `stepWidth`.
    temp293-v = stepwidth.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `state`.
    temp293-v = state.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `key`.
    temp293-v = key.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `icon`.
    temp293-v = icon.
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `showSeparator`.
    temp293-v = z2ui5_cl_util=>boolean_abap_2_json( showseparator ).
    INSERT temp293 INTO TABLE temp292.
    temp293-n = `showIntermediary`.
    temp293-v = z2ui5_cl_util=>boolean_abap_2_json( showintermediary ).
    INSERT temp293 INTO TABLE temp292.
    result = _generic(
        name   = `MicroProcessFlowItem`
        ns     = `commons`
        t_prop = temp292 ).
  ENDMETHOD.

  METHOD mid_column_pages.

    DATA temp294 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp295 LIKE LINE OF temp294.
    CLEAR temp294.

    temp295-n = `id`.
    temp295-v = id.
    INSERT temp295 INTO TABLE temp294.
    result = _generic( name   = `midColumnPages`
                       ns     = `f`
                       t_prop = temp294 ).

  ENDMETHOD.

  METHOD multi_combobox.
    DATA temp296 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp297 LIKE LINE OF temp296.
    CLEAR temp296.

    temp297-n = `selectionChange`.
    temp297-v = selectionchange.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `selectedKeys`.
    temp297-v = selectedkeys.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `selectedItems`.
    temp297-v = selecteditems.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `items`.
    temp297-v = items.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `id`.
    temp297-v = id.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `class`.
    temp297-v = class.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `selectionFinish`.
    temp297-v = selectionfinish.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `width`.
    temp297-v = width.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `showSecondaryValues`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `placeholder`.
    temp297-v = placeholder.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `selectedItemId`.
    temp297-v = selecteditemid.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `selectedKey`.
    temp297-v = selectedkey.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `name`.
    temp297-v = name.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `value`.
    temp297-v = value.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `valueState`.
    temp297-v = valuestate.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `valueStateText`.
    temp297-v = valuestatetext.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `textAlign`.
    temp297-v = textalign.
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `visible`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `showValueStateMessage`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `showClearIcon`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `showButton`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( showbutton ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `required`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `editable`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `enabled`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `filterSecondaryValues`.
    temp297-v = z2ui5_cl_util=>boolean_abap_2_json( filtersecondaryvalues ).
    INSERT temp297 INTO TABLE temp296.
    temp297-n = `showSelectAll`.
    temp297-v = showselectall.
    INSERT temp297 INTO TABLE temp296.
    result = _generic(
        name   = `MultiComboBox`
        t_prop = temp296 ).
  ENDMETHOD.

  METHOD multi_input.
    DATA temp298 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp299 LIKE LINE OF temp298.
    CLEAR temp298.

    temp299-n = `tokens`.
    temp299-v = tokens.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `showClearIcon`.
    temp299-v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ).
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `name`.
    temp299-v = name.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `valueHelpOnly`.
    temp299-v = z2ui5_cl_util=>boolean_abap_2_json( valuehelponly ).
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `showValueHelp`.
    temp299-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluehelp ).
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `enabled`.
    temp299-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `suggestionItems`.
    temp299-v = suggestionitems.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `tokenUpdate`.
    temp299-v = tokenupdate.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `submit`.
    temp299-v = submit.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `width`.
    temp299-v = width.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `value`.
    temp299-v = value.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `id`.
    temp299-v = id.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `change`.
    temp299-v = change.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `valueHelpRequest`.
    temp299-v = valuehelprequest.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `class`.
    temp299-v = class.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `visible`.
    temp299-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `required`.
    temp299-v = required.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `valueState`.
    temp299-v = valuestate.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `valueStateText`.
    temp299-v = valuestatetext.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `placeholder`.
    temp299-v = placeholder.
    INSERT temp299 INTO TABLE temp298.
    temp299-n = `showSuggestion`.
    temp299-v = z2ui5_cl_util=>boolean_abap_2_json( showsuggestion ).
    INSERT temp299 INTO TABLE temp298.
    result = _generic(
        name   = `MultiInput`
        t_prop = temp298 ).
  ENDMETHOD.

  METHOD navigation_actions.
    result = _generic( name = `navigationActions`
                       ns   = `f` ).
  ENDMETHOD.

  METHOD nav_container.

    DATA temp300 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp301 LIKE LINE OF temp300.
    CLEAR temp300.

    temp301-n = `initialPage`.
    temp301-v = initialpage.
    INSERT temp301 INTO TABLE temp300.
    temp301-n = `id`.
    temp301-v = id.
    INSERT temp301 INTO TABLE temp300.
    temp301-n = `height`.
    temp301-v = height.
    INSERT temp301 INTO TABLE temp300.
    temp301-n = `width`.
    temp301-v = width.
    INSERT temp301 INTO TABLE temp300.
    temp301-n = `autoFocus`.
    temp301-v = z2ui5_cl_util=>boolean_abap_2_json( autofocus ).
    INSERT temp301 INTO TABLE temp300.
    temp301-n = `visible`.
    temp301-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp301 INTO TABLE temp300.
    temp301-n = `defaultTransitionName`.
    temp301-v = defaulttransitionname.
    INSERT temp301 INTO TABLE temp300.
    result = _generic( name   = `NavContainer`
                       t_prop = temp300 ).

  ENDMETHOD.

  METHOD network_graph.
    DATA temp302 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp303 LIKE LINE OF temp302.
    CLEAR temp302.

    temp303-n = `id`.
    temp303-v = id.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `class`.
    temp303-v = class.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `layout`.
    temp303-v = layout.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `height`.
    temp303-v = height.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `width`.
    temp303-v = width.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `nodes`.
    temp303-v = nodes.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `lines`.
    temp303-v = lines.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `groups`.
    temp303-v = groups.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `backgroundColor`.
    temp303-v = backgroundcolor.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `backgroundImage`.
    temp303-v = backgroundimage.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `noDataText`.
    temp303-v = nodatatext.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `orientation`.
    temp303-v = orientation.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `renderType`.
    temp303-v = rendertype.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `afterLayouting`.
    temp303-v = afterlayouting.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `beforeLayouting`.
    temp303-v = beforelayouting.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `failure`.
    temp303-v = failure.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `graphReady`.
    temp303-v = graphready.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `search`.
    temp303-v = search.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `searchSuggest`.
    temp303-v = searchsuggest.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `selectionChange`.
    temp303-v = selectionchange.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `zoomChanged`.
    temp303-v = zoomchanged.
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `enableWheelZoom`.
    temp303-v = z2ui5_cl_util=>boolean_abap_2_json( enablewheelzoom ).
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `enableZoom`.
    temp303-v = z2ui5_cl_util=>boolean_abap_2_json( enablezoom ).
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `noData`.
    temp303-v = z2ui5_cl_util=>boolean_abap_2_json( nodata ).
    INSERT temp303 INTO TABLE temp302.
    temp303-n = `visible`.
    temp303-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp303 INTO TABLE temp302.
    result = _generic( name   = `Graph`
                       ns     = `networkgraph`
                       t_prop = temp302 ).

  ENDMETHOD.

  METHOD node.
    DATA temp304 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp305 LIKE LINE OF temp304.
    CLEAR temp304.

    temp305-n = `id`.
    temp305-v = id.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `class`.
    temp305-v = class.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `altText`.
    temp305-v = alttext.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `coreNodeSize`.
    temp305-v = corenodesize.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `description`.
    temp305-v = description.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `descriptionLineSize`.
    temp305-v = descriptionlinesize.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `group`.
    temp305-v = group.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `headerCheckBoxState`.
    temp305-v = headercheckboxstate.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `height`.
    temp305-v = height.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `icon`.
    temp305-v = icon.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `iconSize`.
    temp305-v = iconsize.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `iconSize`.
    temp305-v = iconsize.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `key`.
    temp305-v = key.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `maxWidth`.
    temp305-v = maxwidth.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `title`.
    temp305-v = title.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `shape`.
    temp305-v = shape.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `statusIcon`.
    temp305-v = statusicon.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `titleLineSize`.
    temp305-v = titlelinesize.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `width`.
    temp305-v = width.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `x`.
    temp305-v = x.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `y`.
    temp305-v = y.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `attributes`.
    temp305-v = attributes.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `actionButtons`.
    temp305-v = actionbuttons.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `collapseExpand`.
    temp305-v = collapseexpand.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `headerCheckBoxPress`.
    temp305-v = headercheckboxpress.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `hover`.
    temp305-v = hover.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `press`.
    temp305-v = press.
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `collapsed`.
    temp305-v = z2ui5_cl_util=>boolean_abap_2_json( collapsed ).
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `selected`.
    temp305-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `showActionLinksButton`.
    temp305-v = z2ui5_cl_util=>boolean_abap_2_json( showactionlinksbutton ).
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `showDetailButton`.
    temp305-v = z2ui5_cl_util=>boolean_abap_2_json( showdetailbutton ).
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `showExpandButton`.
    temp305-v = z2ui5_cl_util=>boolean_abap_2_json( showexpandbutton ).
    INSERT temp305 INTO TABLE temp304.
    temp305-n = `visible`.
    temp305-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp305 INTO TABLE temp304.
    result = _generic(
        name   = `Node`
        ns     = `networkgraph`
        t_prop = temp304 ).

  ENDMETHOD.

  METHOD nodes.
    result = _generic( name = `nodes`
                       ns   = ns ).
  ENDMETHOD.

  METHOD node_image.
    DATA temp306 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp307 LIKE LINE OF temp306.
    CLEAR temp306.

    temp307-n = `id`.
    temp307-v = id.
    INSERT temp307 INTO TABLE temp306.
    temp307-n = `class`.
    temp307-v = class.
    INSERT temp307 INTO TABLE temp306.
    temp307-n = `height`.
    temp307-v = height.
    INSERT temp307 INTO TABLE temp306.
    temp307-n = `width`.
    temp307-v = width.
    INSERT temp307 INTO TABLE temp306.
    temp307-n = `src`.
    temp307-v = src.
    INSERT temp307 INTO TABLE temp306.
    result = _generic( name   = `NodeImage`
                       ns     = `networkgraph`
                       t_prop = temp306 ).
  ENDMETHOD.

  METHOD noop_layout.
    result = _generic( name = `NoopLayout`
                       ns   = `nglayout` ).
  ENDMETHOD.

  METHOD notification_list.
    DATA temp308 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp309 LIKE LINE OF temp308.
    CLEAR temp308.

    temp309-n = `id`.
    temp309-v = id.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `class`.
    temp309-v = class.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `footerText`.
    temp309-v = footertext.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growingDirection`.
    temp309-v = growingdirection.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growingThreshold`.
    temp309-v = growingthreshold.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growingTriggerText`.
    temp309-v = growingtriggertext.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `headerLevel`.
    temp309-v = headerlevel.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `headerText`.
    temp309-v = headertext.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `keyboardMode`.
    temp309-v = keyboardmode.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `mode`.
    temp309-v = mode.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `multiSelectMode`.
    temp309-v = multiselectmode.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `noDataText`.
    temp309-v = nodatatext.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `sticky`.
    temp309-v = sticky.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `swipeDirection`.
    temp309-v = swipedirection.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `width`.
    temp309-v = width.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `showSeparators`.
    temp309-v = showseparators.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `beforeOpenContextMenu`.
    temp309-v = beforeopencontextmenu.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `delete`.
    temp309-v = delete.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growingFinished`.
    temp309-v = growingfinished.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growingStarted`.
    temp309-v = growingstarted.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `itemPress`.
    temp309-v = itempress.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `select`.
    temp309-v = select.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `selectionChange`.
    temp309-v = selectionchange.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `swipe`.
    temp309-v = swipe.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `updateFinished`.
    temp309-v = updatefinished.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `updateStarted`.
    temp309-v = updatestarted.
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growingScrollToLoad`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `visible`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `growing`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `includeItemInSelection`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `inset`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( inset ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `modeAnimationOn`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( modeanimationon ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `rememberSelections`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `showNoData`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ).
    INSERT temp309 INTO TABLE temp308.
    temp309-n = `showUnread`.
    temp309-v = z2ui5_cl_util=>boolean_abap_2_json( showunread ).
    INSERT temp309 INTO TABLE temp308.
    result = _generic(
        name   = `NotificationList`
        t_prop = temp308 ).
  ENDMETHOD.

  METHOD notification_list_group.
    DATA temp310 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp311 LIKE LINE OF temp310.
    CLEAR temp310.

    temp311-n = `id`.
    temp311-v = id.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `class`.
    temp311-v = class.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `highlight`.
    temp311-v = highlight.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `highlightText`.
    temp311-v = highlighttext.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `priority`.
    temp311-v = priority.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `title`.
    temp311-v = title.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `type`.
    temp311-v = type.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `onCollapse`.
    temp311-v = oncollapse.
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `visible`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `autoPriority`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( autopriority ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `collapsed`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( collapsed ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `enableCollapseButtonWhenEmpty`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( enablecollapsebuttonwhenempty ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `navigated`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( navigated ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `selected`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `showButtons`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( showbuttons ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `showCloseButton`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( showclosebutton ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `showEmptyGroup`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( showemptygroup ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `showItemsCounter`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( showitemscounter ).
    INSERT temp311 INTO TABLE temp310.
    temp311-n = `unread`.
    temp311-v = z2ui5_cl_util=>boolean_abap_2_json( unread ).
    INSERT temp311 INTO TABLE temp310.
    result = _generic(
                 name   = `NotificationListGroup`
                 t_prop = temp310 ).
  ENDMETHOD.

  METHOD notification_list_item.
    DATA temp312 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp313 LIKE LINE OF temp312.
    CLEAR temp312.

    temp313-n = `id`.
    temp313-v = id.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `class`.
    temp313-v = class.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `authorAvatarColor`.
    temp313-v = authoravatarcolor.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `authorInitials`.
    temp313-v = authorinitials.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `description`.
    temp313-v = description.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `authorName`.
    temp313-v = authorname.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `authorPicture`.
    temp313-v = authorpicture.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `datetime`.
    temp313-v = datetime.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `counter`.
    temp313-v = counter.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `highlightText`.
    temp313-v = highlighttext.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `priority`.
    temp313-v = priority.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `title`.
    temp313-v = title.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `type`.
    temp313-v = type.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `close`.
    temp313-v = close.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `detailPress`.
    temp313-v = detailpress.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `press`.
    temp313-v = press.
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `visible`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `hideShowMoreButton`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( hideshowmorebutton ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `truncate`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( truncate ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `highlight`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( highlight ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `navigated`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( navigated ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `selected`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `showButtons`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( showbuttons ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `showCloseButton`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( showclosebutton ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `truncate`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( truncate ).
    INSERT temp313 INTO TABLE temp312.
    temp313-n = `unread`.
    temp313-v = z2ui5_cl_util=>boolean_abap_2_json( unread ).
    INSERT temp313 INTO TABLE temp312.
    result = _generic(
                 name   = `NotificationListItem`
                 t_prop = temp312 ).
  ENDMETHOD.

  METHOD no_data.
    result = _generic( name = `noData`
                       ns   = ns ).
  ENDMETHOD.

  METHOD numeric_content.

    DATA temp314 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp315 LIKE LINE OF temp314.
    CLEAR temp314.

    temp315-n = `value`.
    temp315-v = value.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `icon`.
    temp315-v = icon.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `width`.
    temp315-v = width.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `valueColor`.
    temp315-v = valuecolor.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `truncateValueTo`.
    temp315-v = truncatevalueto.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `state`.
    temp315-v = state.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `scale`.
    temp315-v = scale.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `indicator`.
    temp315-v = indicator.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `iconDescription`.
    temp315-v = icondescription.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `visible`.
    temp315-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `nullifyValue`.
    temp315-v = z2ui5_cl_util=>boolean_abap_2_json( nullifyvalue ).
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `formatterValue`.
    temp315-v = z2ui5_cl_util=>boolean_abap_2_json( formattervalue ).
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `animateTextChange`.
    temp315-v = z2ui5_cl_util=>boolean_abap_2_json( animatetextchange ).
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `adaptiveFontSize`.
    temp315-v = z2ui5_cl_util=>boolean_abap_2_json( adaptivefontsize ).
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `withMargin`.
    temp315-v = z2ui5_cl_util=>boolean_abap_2_json( withmargin ).
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `class`.
    temp315-v = class.
    INSERT temp315 INTO TABLE temp314.
    temp315-n = `press`.
    temp315-v = press.
    INSERT temp315 INTO TABLE temp314.
    result = _generic(
        name   = `NumericContent`
        t_prop = temp314 ).

  ENDMETHOD.

  METHOD numeric_header.

    DATA temp316 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp317 LIKE LINE OF temp316.
    CLEAR temp316.

    temp317-n = `id`.
    temp317-v = id.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `class`.
    temp317-v = class.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `datatimestamp`.
    temp317-v = datatimestamp.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `press`.
    temp317-v = press.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `details`.
    temp317-v = details.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `detailsMaxLines`.
    temp317-v = detailsmaxlines.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `detailsState`.
    temp317-v = detailsstate.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconAlt`.
    temp317-v = iconalt.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconBackgroundColor`.
    temp317-v = iconbackgroundcolor.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconDisplayShape`.
    temp317-v = icondisplayshape.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconSize`.
    temp317-v = iconsize.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconSrc`.
    temp317-v = iconsrc.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconInitials`.
    temp317-v = iconinitials.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `number`.
    temp317-v = number.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `numberSize`.
    temp317-v = numbersize.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `scale`.
    temp317-v = scale.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `sideIndicatorsAlignment`.
    temp317-v = sideindicatorsalignment.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `state`.
    temp317-v = state.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `statusText`.
    temp317-v = statustext.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `subtitle`.
    temp317-v = subtitle.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `subtitleMaxLines`.
    temp317-v = subtitlemaxlines.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `title`.
    temp317-v = title.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `titleMaxLines`.
    temp317-v = titlemaxlines.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `trend`.
    temp317-v = trend.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `unitOfMeasurement`.
    temp317-v = unitofmeasurement.
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `statusVisible`.
    temp317-v = z2ui5_cl_util=>boolean_abap_2_json( statusvisible ).
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `numberVisible`.
    temp317-v = z2ui5_cl_util=>boolean_abap_2_json( numbervisible ).
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `iconVisible`.
    temp317-v = z2ui5_cl_util=>boolean_abap_2_json( iconvisible ).
    INSERT temp317 INTO TABLE temp316.
    temp317-n = `visible`.
    temp317-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp317 INTO TABLE temp316.
    result = _generic( name   = `NumericHeader`
                       ns     = `f`
                       t_prop = temp316 ).
  ENDMETHOD.

  METHOD numeric_side_indicator.
    DATA temp318 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp319 LIKE LINE OF temp318.
    CLEAR temp318.

    temp319-n = `id`.
    temp319-v = id.
    INSERT temp319 INTO TABLE temp318.
    temp319-n = `class`.
    temp319-v = class.
    INSERT temp319 INTO TABLE temp318.
    temp319-n = `unit`.
    temp319-v = unit.
    INSERT temp319 INTO TABLE temp318.
    temp319-n = `title`.
    temp319-v = title.
    INSERT temp319 INTO TABLE temp318.
    temp319-n = `state`.
    temp319-v = state.
    INSERT temp319 INTO TABLE temp318.
    temp319-n = `number`.
    temp319-v = number.
    INSERT temp319 INTO TABLE temp318.
    temp319-n = `visible`.
    temp319-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp319 INTO TABLE temp318.
    result = _generic( name   = `NumericSideIndicator`
                       ns     = `f`
                       t_prop = temp318 ).
  ENDMETHOD.

  METHOD object_attribute.
    DATA temp320 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp321 LIKE LINE OF temp320.
    result = me.


    CLEAR temp320.

    temp321-n = `title`.
    temp321-v = title.
    INSERT temp321 INTO TABLE temp320.
    temp321-n = `textDirection`.
    temp321-v = textdirection.
    INSERT temp321 INTO TABLE temp320.
    temp321-n = `ariaHasPopup`.
    temp321-v = ariahaspopup.
    INSERT temp321 INTO TABLE temp320.
    temp321-n = `press`.
    temp321-v = press.
    INSERT temp321 INTO TABLE temp320.
    temp321-n = `active`.
    temp321-v = z2ui5_cl_util=>boolean_abap_2_json( active ).
    INSERT temp321 INTO TABLE temp320.
    temp321-n = `visible`.
    temp321-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp321 INTO TABLE temp320.
    temp321-n = `text`.
    temp321-v = text.
    INSERT temp321 INTO TABLE temp320.
    _generic( name   = `ObjectAttribute`
              t_prop = temp320 ).
  ENDMETHOD.

  METHOD object_header.

    DATA temp322 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp323 LIKE LINE OF temp322.
    CLEAR temp322.

    temp323-n = `backgrounddesign`.
    temp323-v = backgrounddesign.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `condensed`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( condensed ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `fullscreenoptimized`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( fullscreenoptimized ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `icon`.
    temp323-v = icon.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `iconactive`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( iconactive ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `iconalt`.
    temp323-v = iconalt.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `icondensityaware`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `icontooltip`.
    temp323-v = icontooltip.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `imageShape`.
    temp323-v = imageshape.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `intro`.
    temp323-v = intro.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `introactive`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( introactive ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `introhref`.
    temp323-v = introhref.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `introtarget`.
    temp323-v = introtarget.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `introtextdirection`.
    temp323-v = introtextdirection.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `number`.
    temp323-v = number.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `numberstate`.
    temp323-v = numberstate.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `numbertextdirection`.
    temp323-v = numbertextdirection.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `numberunit`.
    temp323-v = numberunit.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `responsive`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( responsive ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `showtitleselector`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( showtitleselector ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `title`.
    temp323-v = title.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titleactive`.
    temp323-v = z2ui5_cl_util=>boolean_abap_2_json( titleactive ).
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titlehref`.
    temp323-v = titlehref.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titlelevel`.
    temp323-v = titlelevel.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titleselectortooltip`.
    temp323-v = titleselectortooltip.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titletarget`.
    temp323-v = titletarget.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titletextdirection`.
    temp323-v = titletextdirection.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `iconpress`.
    temp323-v = iconpress.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `intropress`.
    temp323-v = intropress.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titlepress`.
    temp323-v = titlepress.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `titleselectorpress`.
    temp323-v = titleselectorpress.
    INSERT temp323 INTO TABLE temp322.
    temp323-n = `class`.
    temp323-v = class.
    INSERT temp323 INTO TABLE temp322.
    result = _generic(
        name   = `ObjectHeader`
        t_prop = temp322 ).
  ENDMETHOD.

  METHOD object_identifier.
    DATA temp324 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp325 LIKE LINE OF temp324.
    CLEAR temp324.

    temp325-n = `emptyIndicatorMode`.
    temp325-v = emptyindicatormode.
    INSERT temp325 INTO TABLE temp324.
    temp325-n = `text`.
    temp325-v = text.
    INSERT temp325 INTO TABLE temp324.
    temp325-n = `textDirection`.
    temp325-v = textdirection.
    INSERT temp325 INTO TABLE temp324.
    temp325-n = `title`.
    temp325-v = title.
    INSERT temp325 INTO TABLE temp324.
    temp325-n = `titleActive`.
    temp325-v = titleactive.
    INSERT temp325 INTO TABLE temp324.
    temp325-n = `visible`.
    temp325-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp325 INTO TABLE temp324.
    temp325-n = `titlePress`.
    temp325-v = titlepress.
    INSERT temp325 INTO TABLE temp324.
    result = _generic( name   = `ObjectIdentifier`
                       t_prop = temp324 ).
  ENDMETHOD.

  METHOD object_list_item.
    DATA temp326 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp327 LIKE LINE OF temp326.
    CLEAR temp326.

    temp327-n = `activeIcon`.
    temp327-v = activeicon.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `icon`.
    temp327-v = icon.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `intro`.
    temp327-v = intro.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `introTextDirection`.
    temp327-v = introtextdirection.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `number`.
    temp327-v = number.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `numberState`.
    temp327-v = numberstate.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `numberTextDirection`.
    temp327-v = numbertextdirection.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `numberUnit`.
    temp327-v = numberunit.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `title`.
    temp327-v = title.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `titleTextDirection`.
    temp327-v = titletextdirection.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `iconDensityAware`.
    temp327-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `press`.
    temp327-v = press.
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `selected`.
    temp327-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp327 INTO TABLE temp326.
    temp327-n = `type`.
    temp327-v = type.
    INSERT temp327 INTO TABLE temp326.
    result = _generic(
        name   = `ObjectListItem`
        t_prop = temp326 ).
  ENDMETHOD.

  METHOD object_marker.
    DATA temp328 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp329 LIKE LINE OF temp328.
    CLEAR temp328.

    temp329-n = `additionalInfo`.
    temp329-v = additionalinfo.
    INSERT temp329 INTO TABLE temp328.
    temp329-n = `type`.
    temp329-v = type.
    INSERT temp329 INTO TABLE temp328.
    temp329-n = `visible`.
    temp329-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp329 INTO TABLE temp328.
    temp329-n = `press`.
    temp329-v = press.
    INSERT temp329 INTO TABLE temp328.
    temp329-n = `visibility`.
    temp329-v = visibility.
    INSERT temp329 INTO TABLE temp328.
    result = _generic( name   = `ObjectMarker`
                       t_prop = temp328 ).
  ENDMETHOD.

  METHOD object_number.
    DATA temp330 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp331 LIKE LINE OF temp330.
    result = me.

    CLEAR temp330.

    temp331-n = `emphasized`.
    temp331-v = z2ui5_cl_util=>boolean_abap_2_json( emphasized ).
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `number`.
    temp331-v = number.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `state`.
    temp331-v = state.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `id`.
    temp331-v = id.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `class`.
    temp331-v = class.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `textAlign`.
    temp331-v = textalign.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `textDirection`.
    temp331-v = textdirection.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `emptyIndicatorMode`.
    temp331-v = emptyindicatormode.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `numberunit`.
    temp331-v = numberunit.
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `active`.
    temp331-v = z2ui5_cl_util=>boolean_abap_2_json( active ).
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `inverted`.
    temp331-v = z2ui5_cl_util=>boolean_abap_2_json( inverted ).
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `visible`.
    temp331-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp331 INTO TABLE temp330.
    temp331-n = `unit`.
    temp331-v = unit.
    INSERT temp331 INTO TABLE temp330.
    _generic( name   = `ObjectNumber`
              t_prop = temp330 ).
  ENDMETHOD.

  METHOD object_page_dyn_header_title.
    result = _generic( name = `ObjectPageDynamicHeaderTitle`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD object_page_header.
    DATA temp332 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp333 LIKE LINE OF temp332.
    result = me.

    CLEAR temp332.

    temp333-n = `isActionAreaAlwaysVisible`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( isactionareaalwaysvisible ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `isObjectIconAlwaysVisible`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( isobjecticonalwaysvisible ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `isObjectSubtitleAlwaysVisible`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( isobjectsubtitlealwaysvisible ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `isObjectTitleAlwaysVisible`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( isobjecttitlealwaysvisible ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `markChanges`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( markchanges ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `markFavorite`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( markfavorite ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `markFlagged`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( markflagged ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `markLocked`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( marklocked ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectImageDensityAware`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( objectimagedensityaware ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `showMarkers`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( showmarkers ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `showPlaceholder`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( showplaceholder ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `showTitleSelector`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( showtitleselector ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `visible`.
    temp333-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectImageAlt`.
    temp333-v = objectimagealt.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectImageBackgroundColor`.
    temp333-v = objectimagebackgroundcolor.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectImageURI`.
    temp333-v = objectimageuri.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectSubtitle`.
    temp333-v = objectsubtitle.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectTitle`.
    temp333-v = objecttitle.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `markChangesPress`.
    temp333-v = markchangespress.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `markLockedPress`.
    temp333-v = marklockedpress.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `titleSelectorPress`.
    temp333-v = titleselectorpress.
    INSERT temp333 INTO TABLE temp332.
    temp333-n = `objectImageShape`.
    temp333-v = objectimageshape.
    INSERT temp333 INTO TABLE temp332.
    _generic(
        name   = `ObjectPageHeader`
        ns     = `uxap`
        t_prop = temp332 ).
  ENDMETHOD.

  METHOD object_page_header_action_btn.
    DATA temp334 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp335 LIKE LINE OF temp334.
    result = me.

    CLEAR temp334.

    temp335-n = `activeIcon`.
    temp335-v = activeicon.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `ariaHasPopup`.
    temp335-v = ariahaspopup.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `icon`.
    temp335-v = icon.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `importance`.
    temp335-v = importance.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `text`.
    temp335-v = text.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `textDirection`.
    temp335-v = textdirection.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `type`.
    temp335-v = type.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `width`.
    temp335-v = width.
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `enabled`.
    temp335-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `hideIcon`.
    temp335-v = z2ui5_cl_util=>boolean_abap_2_json( hideicon ).
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `hideText`.
    temp335-v = z2ui5_cl_util=>boolean_abap_2_json( hidetext ).
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `iconDensityAware`.
    temp335-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `iconFirst`.
    temp335-v = z2ui5_cl_util=>boolean_abap_2_json( iconfirst ).
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `visible`.
    temp335-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp335 INTO TABLE temp334.
    temp335-n = `press`.
    temp335-v = press.
    INSERT temp335 INTO TABLE temp334.
    _generic( name   = `ObjectPageHeaderActionButton`
              ns     = `uxap`
              t_prop = temp334 ).
  ENDMETHOD.

  METHOD object_page_layout.
    DATA temp336 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp337 LIKE LINE OF temp336.
    CLEAR temp336.

    temp337-n = `showTitleInHeaderContent`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showtitleinheadercontent ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `showEditHeaderButton`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showeditheaderbutton ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `alwaysShowContentHeader`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( alwaysshowcontentheader ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `enableLazyLoading`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( enablelazyloading ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `flexEnabled`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( flexenabled ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `headerContentPinnable`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( headercontentpinnable ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `headerContentPinned`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( headercontentpinned ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `isChildPage`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( ischildpage ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `preserveHeaderStateOnScroll`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( preserveheaderstateonscroll ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `showAnchorBar`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showanchorbar ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `showAnchorBarPopover`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showanchorbarpopover ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `showHeaderContent`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showheadercontent ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `showOnlyHighImportance`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showonlyhighimportance ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `subSectionLayout`.
    temp337-v = subsectionlayout.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `toggleHeaderOnTitleClick`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( toggleheaderontitleclick ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `useIconTabBar`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( useicontabbar ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `useTwoColumnsForLargeScreen`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( usetwocolumnsforlargescreen ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `visible`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `backgroundDesignAnchorBar`.
    temp337-v = backgrounddesignanchorbar.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `height`.
    temp337-v = height.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `sectionTitleLevel`.
    temp337-v = sectiontitlelevel.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `editHeaderButtonPress`.
    temp337-v = editheaderbuttonpress.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `upperCaseAnchorBar`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( uppercaseanchorbar ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `beforeNavigate`.
    temp337-v = beforenavigate.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `headerContentPinnedStateChange`.
    temp337-v = headercontentpinnedstatechange.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `navigate`.
    temp337-v = navigate.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `sectionChange`.
    temp337-v = sectionchange.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `subSectionVisibilityChange`.
    temp337-v = subsectionvisibilitychange.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `toggleAnchorBar`.
    temp337-v = toggleanchorbar.
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `showFooter`.
    temp337-v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ).
    INSERT temp337 INTO TABLE temp336.
    temp337-n = `class`.
    temp337-v = class.
    INSERT temp337 INTO TABLE temp336.
    result = _generic(
        name   = `ObjectPageLayout`
        ns     = `uxap`
        t_prop = temp336 ).
  ENDMETHOD.

  METHOD object_page_section.
    DATA temp338 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp339 LIKE LINE OF temp338.
    CLEAR temp338.

    temp339-n = `titleUppercase`.
    temp339-v = z2ui5_cl_util=>boolean_abap_2_json( titleuppercase ).
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `title`.
    temp339-v = title.
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `id`.
    temp339-v = id.
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `anchorBarButtonColor`.
    temp339-v = anchorbarbuttoncolor.
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `titleLevel`.
    temp339-v = titlelevel.
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `titleVisible`.
    temp339-v = z2ui5_cl_util=>boolean_abap_2_json( titlevisible ).
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `showTitle`.
    temp339-v = z2ui5_cl_util=>boolean_abap_2_json( showtitle ).
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `visible`.
    temp339-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `wrapTitle`.
    temp339-v = z2ui5_cl_util=>boolean_abap_2_json( wraptitle ).
    INSERT temp339 INTO TABLE temp338.
    temp339-n = `importance`.
    temp339-v = importance.
    INSERT temp339 INTO TABLE temp338.
    result = _generic(
                 name   = `ObjectPageSection`
                 ns     = `uxap`
                 t_prop = temp338 ).
  ENDMETHOD.

  METHOD object_page_sub_section.
    DATA temp340 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp341 LIKE LINE OF temp340.
    CLEAR temp340.

    temp341-n = `id`.
    temp341-v = id.
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `mode`.
    temp341-v = mode.
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `importance`.
    temp341-v = importance.
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `titleLevel`.
    temp341-v = titlelevel.
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `titleVisible`.
    temp341-v = z2ui5_cl_util=>boolean_abap_2_json( titlevisible ).
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `showTitle`.
    temp341-v = z2ui5_cl_util=>boolean_abap_2_json( showtitle ).
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `titleUppercase`.
    temp341-v = z2ui5_cl_util=>boolean_abap_2_json( titleuppercase ).
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `visible`.
    temp341-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp341 INTO TABLE temp340.
    temp341-n = `title`.
    temp341-v = title.
    INSERT temp341 INTO TABLE temp340.
    result = _generic(
                 name   = `ObjectPageSubSection`
                 ns     = `uxap`
                 t_prop = temp340 ).
  ENDMETHOD.

  METHOD object_status.
    DATA temp342 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp343 LIKE LINE OF temp342.
    CLEAR temp342.

    temp343-n = `active`.
    temp343-v = z2ui5_cl_util=>boolean_abap_2_json( active ).
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `emptyIndicatorMode`.
    temp343-v = emptyindicatormode.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `icon`.
    temp343-v = icon.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `iconDensityAware`.
    temp343-v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ).
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `inverted`.
    temp343-v = z2ui5_cl_util=>boolean_abap_2_json( inverted ).
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `state`.
    temp343-v = state.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `stateAnnouncementText`.
    temp343-v = stateannouncementtext.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `text`.
    temp343-v = text.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `id`.
    temp343-v = id.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `class`.
    temp343-v = class.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `textDirection`.
    temp343-v = textdirection.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `title`.
    temp343-v = title.
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `visible`.
    temp343-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp343 INTO TABLE temp342.
    temp343-n = `press`.
    temp343-v = press.
    INSERT temp343 INTO TABLE temp342.
    result = _generic(
        name   = `ObjectStatus`
        t_prop = temp342 ).
  ENDMETHOD.

  METHOD overflow_toolbar.
    DATA temp344 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp345 LIKE LINE OF temp344.
    CLEAR temp344.

    temp345-n = `press`.
    temp345-v = press.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `text`.
    temp345-v = text.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `active`.
    temp345-v = z2ui5_cl_util=>boolean_abap_2_json( active ).
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `visible`.
    temp345-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `asyncMode`.
    temp345-v = z2ui5_cl_util=>boolean_abap_2_json( asyncmode ).
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `enabled`.
    temp345-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `design`.
    temp345-v = design.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `type`.
    temp345-v = type.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `style`.
    temp345-v = style.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `id`.
    temp345-v = id.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `class`.
    temp345-v = class.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `width`.
    temp345-v = width.
    INSERT temp345 INTO TABLE temp344.
    temp345-n = `height`.
    temp345-v = height.
    INSERT temp345 INTO TABLE temp344.
    result = _generic( name   = `OverflowToolbar`
                       t_prop = temp344 ).
  ENDMETHOD.

  METHOD overflow_toolbar_button.
    DATA temp346 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp347 LIKE LINE OF temp346.
    result = me.

    CLEAR temp346.

    temp347-n = `id`.
    temp347-v = id.
    INSERT temp347 INTO TABLE temp346.
    temp347-n = `press`.
    temp347-v = press.
    INSERT temp347 INTO TABLE temp346.
    temp347-n = `text`.
    temp347-v = text.
    INSERT temp347 INTO TABLE temp346.
    temp347-n = `enabled`.
    temp347-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp347 INTO TABLE temp346.
    temp347-n = `icon`.
    temp347-v = icon.
    INSERT temp347 INTO TABLE temp346.
    temp347-n = `type`.
    temp347-v = type.
    INSERT temp347 INTO TABLE temp346.
    temp347-n = `tooltip`.
    temp347-v = tooltip.
    INSERT temp347 INTO TABLE temp346.
    _generic( name   = `OverflowToolbarButton`
              t_prop = temp346 ).
  ENDMETHOD.

  METHOD overflow_toolbar_menu_button.
    DATA temp348 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp349 LIKE LINE OF temp348.
    CLEAR temp348.

    temp349-n = `buttonMode`.
    temp349-v = buttonmode.
    INSERT temp349 INTO TABLE temp348.
    temp349-n = `defaultAction`.
    temp349-v = defaultaction.
    INSERT temp349 INTO TABLE temp348.
    temp349-n = `text`.
    temp349-v = text.
    INSERT temp349 INTO TABLE temp348.
    temp349-n = `enabled`.
    temp349-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp349 INTO TABLE temp348.
    temp349-n = `icon`.
    temp349-v = icon.
    INSERT temp349 INTO TABLE temp348.
    temp349-n = `type`.
    temp349-v = type.
    INSERT temp349 INTO TABLE temp348.
    temp349-n = `tooltip`.
    temp349-v = tooltip.
    INSERT temp349 INTO TABLE temp348.
    result = _generic( name   = `OverflowToolbarMenuButton`
                       t_prop = temp348 ).
  ENDMETHOD.

  METHOD overflow_toolbar_toggle_button.
    DATA temp350 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp351 LIKE LINE OF temp350.
    result = me.

    CLEAR temp350.

    temp351-n = `press`.
    temp351-v = press.
    INSERT temp351 INTO TABLE temp350.
    temp351-n = `text`.
    temp351-v = text.
    INSERT temp351 INTO TABLE temp350.
    temp351-n = `enabled`.
    temp351-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp351 INTO TABLE temp350.
    temp351-n = `icon`.
    temp351-v = icon.
    INSERT temp351 INTO TABLE temp350.
    temp351-n = `type`.
    temp351-v = type.
    INSERT temp351 INTO TABLE temp350.
    temp351-n = `tooltip`.
    temp351-v = tooltip.
    INSERT temp351 INTO TABLE temp350.
    _generic( name   = `OverflowToolbarToggleButton`
              t_prop = temp350 ).
  ENDMETHOD.

  METHOD page.
    DATA temp352 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp353 LIKE LINE OF temp352.
    CLEAR temp352.

    temp353-n = `title`.
    temp353-v = title.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `showNavButton`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( shownavbutton ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `navButtonPress`.
    temp353-v = navbuttonpress.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `showHeader`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( showheader ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `class`.
    temp353-v = class.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `backgroundDesign`.
    temp353-v = backgrounddesign.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `navButtonTooltip`.
    temp353-v = navbuttontooltip.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `titleAlignment`.
    temp353-v = titlealignment.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `titleLevel`.
    temp353-v = titlelevel.
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `contentOnlyBusy`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( contentonlybusy ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `enableScrolling`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( enablescrolling ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `floatingFooter`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( floatingfooter ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `showFooter`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `showSubHeader`.
    temp353-v = z2ui5_cl_util=>boolean_abap_2_json( showsubheader ).
    INSERT temp353 INTO TABLE temp352.
    temp353-n = `id`.
    temp353-v = id.
    INSERT temp353 INTO TABLE temp352.
    result = _generic(
                 name   = `Page`
                 ns     = ns
                 t_prop = temp352 ).
  ENDMETHOD.

  METHOD pages.
    result = _generic( `pages` ).

  ENDMETHOD.

  METHOD paging_button.
    DATA temp354 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp355 LIKE LINE OF temp354.
    result = me.

    CLEAR temp354.

    temp355-n = `count`.
    temp355-v = count.
    INSERT temp355 INTO TABLE temp354.
    temp355-n = `nextButtonTooltip`.
    temp355-v = nextbuttontooltip.
    INSERT temp355 INTO TABLE temp354.
    temp355-n = `position`.
    temp355-v = position.
    INSERT temp355 INTO TABLE temp354.
    temp355-n = `previousButtonTooltip`.
    temp355-v = previousbuttontooltip.
    INSERT temp355 INTO TABLE temp354.
    _generic( name   = `PagingButton`
              t_prop = temp354 ).
  ENDMETHOD.

  METHOD panel.

    DATA temp356 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp357 LIKE LINE OF temp356.
    CLEAR temp356.

    temp357-n = `expandable`.
    temp357-v = z2ui5_cl_util=>boolean_abap_2_json( expandable ).
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `expanded`.
    temp357-v = z2ui5_cl_util=>boolean_abap_2_json( expanded ).
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `stickyHeader`.
    temp357-v = z2ui5_cl_util=>boolean_abap_2_json( stickyheader ).
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `expandAnimation`.
    temp357-v = z2ui5_cl_util=>boolean_abap_2_json( expandanimation ).
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `visible`.
    temp357-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `height`.
    temp357-v = height.
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `backgroundDesign`.
    temp357-v = backgrounddesign.
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `width`.
    temp357-v = width.
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `id`.
    temp357-v = id.
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `class`.
    temp357-v = class.
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `expand`.
    temp357-v = expand.
    INSERT temp357 INTO TABLE temp356.
    temp357-n = `headerText`.
    temp357-v = headertext.
    INSERT temp357 INTO TABLE temp356.
    result = _generic(
                 name   = `Panel`
                 t_prop = temp356 ).

  ENDMETHOD.

  METHOD pane_container.
    DATA temp358 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp359 LIKE LINE OF temp358.
    CLEAR temp358.

    temp359-n = `resize`.
    temp359-v = resize.
    INSERT temp359 INTO TABLE temp358.
    temp359-n = `orientation`.
    temp359-v = orientation.
    INSERT temp359 INTO TABLE temp358.
    result = _generic( name   = `PaneContainer`
                       ns     = `layout`
                       t_prop = temp358 ).
  ENDMETHOD.

  METHOD planning_calendar.
    DATA temp360 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp361 LIKE LINE OF temp360.
    CLEAR temp360.

    temp361-n = `rows`.
    temp361-v = rows.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `startDate`.
    temp361-v = startdate.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `id`.
    temp361-v = id.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `class`.
    temp361-v = class.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `appointmentHeight`.
    temp361-v = appointmentheight.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `appointmentRoundWidth`.
    temp361-v = appointmentroundwidth.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `builtInViews`.
    temp361-v = builtinviews.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `calendarWeekNumbering`.
    temp361-v = calendarweeknumbering.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `firstDayOfWeek`.
    temp361-v = firstdayofweek.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `groupAppointmentsMode`.
    temp361-v = groupappointmentsmode.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `height`.
    temp361-v = height.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `iconShape`.
    temp361-v = iconshape.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `maxDate`.
    temp361-v = maxdate.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `minDate`.
    temp361-v = mindate.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `noDataText`.
    temp361-v = nodatatext.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `primaryCalendarType`.
    temp361-v = primarycalendartype.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `secondaryCalendarType`.
    temp361-v = secondarycalendartype.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `appointmentsVisualization`.
    temp361-v = appointmentsvisualization.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `appointmentSelect`.
    temp361-v = appointmentselect.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `intervalSelect`.
    temp361-v = intervalselect.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `rowHeaderPress`.
    temp361-v = rowheaderpress.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `rowSelectionChange`.
    temp361-v = rowselectionchange.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `startDateChange`.
    temp361-v = startdatechange.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `viewChange`.
    temp361-v = viewchange.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `stickyHeader`.
    temp361-v = stickyheader.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `viewKey`.
    temp361-v = viewkey.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `width`.
    temp361-v = width.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `singleSelection`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( singleselection ).
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `showRowHeaders`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( showrowheaders ).
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `multipleAppointmentsSelection`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( multipleappointmentsselection ).
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `showIntervalHeaders`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( showintervalheaders ).
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `showEmptyIntervalHeaders`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( showemptyintervalheaders ).
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `showWeekNumbers`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( showweeknumbers ).
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `legend`.
    temp361-v = legend.
    INSERT temp361 INTO TABLE temp360.
    temp361-n = `showDayNamesLine`.
    temp361-v = z2ui5_cl_util=>boolean_abap_2_json( showdaynamesline ).
    INSERT temp361 INTO TABLE temp360.
    result = _generic(
        name   = `PlanningCalendar`
        t_prop = temp360 ).
  ENDMETHOD.

  METHOD planning_calendar_legend.
    DATA temp362 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp363 LIKE LINE OF temp362.
    CLEAR temp362.

    temp363-n = `id`.
    temp363-v = id.
    INSERT temp363 INTO TABLE temp362.
    temp363-n = `items`.
    temp363-v = items.
    INSERT temp363 INTO TABLE temp362.
    temp363-n = `appointmentItems`.
    temp363-v = appointmentitems.
    INSERT temp363 INTO TABLE temp362.
    temp363-n = `columnWidth`.
    temp363-v = columnwidth.
    INSERT temp363 INTO TABLE temp362.
    temp363-n = `visible`.
    temp363-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp363 INTO TABLE temp362.
    temp363-n = `standardItems`.
    temp363-v = standarditems.
    INSERT temp363 INTO TABLE temp362.
    result = _generic(
                 name   = `PlanningCalendarLegend`
                 t_prop = temp362 ).

  ENDMETHOD.

  METHOD planning_calendar_row.
    DATA temp364 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp365 LIKE LINE OF temp364.
    CLEAR temp364.

    temp365-n = `appointments`.
    temp365-v = appointments.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `intervalHeaders`.
    temp365-v = intervalheaders.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `id`.
    temp365-v = id.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `class`.
    temp365-v = class.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `icon`.
    temp365-v = icon.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `title`.
    temp365-v = title.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `key`.
    temp365-v = key.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `noAppointmentsText`.
    temp365-v = noappointmentstext.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `nonWorkingHours`.
    temp365-v = nonworkinghours.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `rowHeaderDescription`.
    temp365-v = rowheaderdescription.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `nonworkingdays`.
    temp365-v = nonworkingdays.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `enableAppointmentsCreate`.
    temp365-v = z2ui5_cl_util=>boolean_abap_2_json( enableappointmentscreate ).
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `appointmentResize`.
    temp365-v = appointmentresize.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `appointmentDrop`.
    temp365-v = appointmentdrop.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `appointmentDragEnter`.
    temp365-v = appointmentdragenter.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `appointmentCreate`.
    temp365-v = appointmentcreate.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `selected`.
    temp365-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `nonWorkingDays`.
    temp365-v = nonworkingdays.
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `enableAppointmentsResize`.
    temp365-v = z2ui5_cl_util=>boolean_abap_2_json( enableappointmentsresize ).
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `enableAppointmentsDragAndDrop`.
    temp365-v = z2ui5_cl_util=>boolean_abap_2_json( enableappointmentsdraganddrop ).
    INSERT temp365 INTO TABLE temp364.
    temp365-n = `text`.
    temp365-v = text.
    INSERT temp365 INTO TABLE temp364.
    result = _generic(
        name   = `PlanningCalendarRow`
        t_prop = temp364 ).

  ENDMETHOD.

  METHOD planning_calendar_view.
    DATA temp366 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp367 LIKE LINE OF temp366.
    CLEAR temp366.

    temp367-n = `appointmentHeight`.
    temp367-v = appointmentheight.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `description`.
    temp367-v = description.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `intervalLabelFormatter`.
    temp367-v = intervallabelformatter.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `intervalSize`.
    temp367-v = intervalsize.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `intervalsL`.
    temp367-v = intervalsl.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `intervalsM`.
    temp367-v = intervalsm.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `intervalsS`.
    temp367-v = intervalss.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `intervalType`.
    temp367-v = intervaltype.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `key`.
    temp367-v = key.
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `relative`.
    temp367-v = z2ui5_cl_util=>boolean_abap_2_json( relative ).
    INSERT temp367 INTO TABLE temp366.
    temp367-n = `showSubIntervals`.
    temp367-v = z2ui5_cl_util=>boolean_abap_2_json( showsubintervals ).
    INSERT temp367 INTO TABLE temp366.
    result = _generic(
        name   = `PlanningCalendarView`
        t_prop = temp366 ).
  ENDMETHOD.

  METHOD points.
    result = _generic( name = `points`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD popover.
    DATA temp368 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp369 LIKE LINE OF temp368.
    CLEAR temp368.

    temp369-n = `id`.
    temp369-v = id.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `title`.
    temp369-v = title.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `class`.
    temp369-v = class.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `placement`.
    temp369-v = placement.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `initialFocus`.
    temp369-v = initialfocus.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `contentHeight`.
    temp369-v = contentheight.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `showHeader`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( showheader ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `showArrow`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( showarrow ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `resizable`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( resizable ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `modal`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( modal ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `horizontalScrolling`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( horizontalscrolling ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `verticalScrolling`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( verticalscrolling ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `visible`.
    temp369-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `offsetX`.
    temp369-v = offsetx.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `offsetY`.
    temp369-v = offsety.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `contentMinWidth`.
    temp369-v = contentminwidth.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `titleAlignment`.
    temp369-v = titlealignment.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `contentWidth`.
    temp369-v = contentwidth.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `afterClose`.
    temp369-v = afterclose.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `afterOpen`.
    temp369-v = afteropen.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `beforeClose`.
    temp369-v = beforeclose.
    INSERT temp369 INTO TABLE temp368.
    temp369-n = `beforeOpen`.
    temp369-v = beforeopen.
    INSERT temp369 INTO TABLE temp368.
    result = _generic(
        name   = `Popover`
        t_prop = temp368 ).
  ENDMETHOD.

  METHOD process_flow.
    DATA temp370 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp371 LIKE LINE OF temp370.
    CLEAR temp370.

    temp371-n = `id`.
    temp371-v = id.
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `foldedCorners`.
    temp371-v = z2ui5_cl_util=>boolean_abap_2_json( foldedcorners ).
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `scrollable`.
    temp371-v = z2ui5_cl_util=>boolean_abap_2_json( scrollable ).
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `showLabels`.
    temp371-v = z2ui5_cl_util=>boolean_abap_2_json( showlabels ).
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `visible`.
    temp371-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `wheelZoomable`.
    temp371-v = z2ui5_cl_util=>boolean_abap_2_json( wheelzoomable ).
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `headerPress`.
    temp371-v = headerpress.
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `labelPress`.
    temp371-v = labelpress.
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `nodePress`.
    temp371-v = nodepress.
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `onError`.
    temp371-v = onerror.
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `lanes`.
    temp371-v = lanes.
    INSERT temp371 INTO TABLE temp370.
    temp371-n = `nodes`.
    temp371-v = nodes.
    INSERT temp371 INTO TABLE temp370.
    result = _generic(
                 name   = `ProcessFlow`
                 ns     = `commons`
                 t_prop = temp370 ).
  ENDMETHOD.

  METHOD process_flow_lane_header.

    DATA temp372 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp373 LIKE LINE OF temp372.
    CLEAR temp372.

    temp373-n = `iconSrc`.
    temp373-v = iconsrc.
    INSERT temp373 INTO TABLE temp372.
    temp373-n = `laneId`.
    temp373-v = laneid.
    INSERT temp373 INTO TABLE temp372.
    temp373-n = `position`.
    temp373-v = position.
    INSERT temp373 INTO TABLE temp372.
    temp373-n = `state`.
    temp373-v = state.
    INSERT temp373 INTO TABLE temp372.
    temp373-n = `text`.
    temp373-v = text.
    INSERT temp373 INTO TABLE temp372.
    temp373-n = `zoomLevel`.
    temp373-v = zoomlevel.
    INSERT temp373 INTO TABLE temp372.
    result = _generic( name   = `ProcessFlowLaneHeader`
                       ns     = `commons`
                       t_prop = temp372 ).
  ENDMETHOD.

  METHOD process_flow_node.
    DATA temp374 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp375 LIKE LINE OF temp374.
    CLEAR temp374.

    temp375-n = `laneId`.
    temp375-v = laneid.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `nodeId`.
    temp375-v = nodeid.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `title`.
    temp375-v = title.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `titleAbbreviation`.
    temp375-v = titleabbreviation.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `children`.
    temp375-v = children.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `state`.
    temp375-v = state.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `stateText`.
    temp375-v = statetext.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `texts`.
    temp375-v = texts.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `highlighted`.
    temp375-v = z2ui5_cl_util=>boolean_abap_2_json( highlighted ).
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `focused`.
    temp375-v = z2ui5_cl_util=>boolean_abap_2_json( focused ).
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `selected`.
    temp375-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `tag`.
    temp375-v = tag.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `texts`.
    temp375-v = texts.
    INSERT temp375 INTO TABLE temp374.
    temp375-n = `type`.
    temp375-v = type.
    INSERT temp375 INTO TABLE temp374.
    result = _generic(
                 name   = `ProcessFlowNode`
                 ns     = `commons`
                 t_prop = temp374 ).
  ENDMETHOD.

  METHOD progress_indicator.
    DATA temp376 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp377 LIKE LINE OF temp376.
    result = me.

    CLEAR temp376.

    temp377-n = `class`.
    temp377-v = class.
    INSERT temp377 INTO TABLE temp376.
    temp377-n = `percentValue`.
    temp377-v = percentvalue.
    INSERT temp377 INTO TABLE temp376.
    temp377-n = `displayValue`.
    temp377-v = displayvalue.
    INSERT temp377 INTO TABLE temp376.
    temp377-n = `showValue`.
    temp377-v = z2ui5_cl_util=>boolean_abap_2_json( showvalue ).
    INSERT temp377 INTO TABLE temp376.
    temp377-n = `visible`.
    temp377-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp377 INTO TABLE temp376.
    temp377-n = `state`.
    temp377-v = state.
    INSERT temp377 INTO TABLE temp376.
    _generic( name   = `ProgressIndicator`
              t_prop = temp376 ).
  ENDMETHOD.

  METHOD property_threshold.
    DATA temp378 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp379 LIKE LINE OF temp378.
    CLEAR temp378.

    temp379-n = `id`.
    temp379-v = id.
    INSERT temp379 INTO TABLE temp378.
    temp379-n = `class`.
    temp379-v = class.
    INSERT temp379 INTO TABLE temp378.
    temp379-n = `ariaLabel`.
    temp379-v = arialabel.
    INSERT temp379 INTO TABLE temp378.
    temp379-n = `fillColor`.
    temp379-v = fillcolor.
    INSERT temp379 INTO TABLE temp378.
    temp379-n = `toValue`.
    temp379-v = tovalue.
    INSERT temp379 INTO TABLE temp378.
    temp379-n = `visible`.
    temp379-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp379 INTO TABLE temp378.
    result = _generic( name   = `PropertyThreshold`
                       ns     = `si`
                       t_prop = temp378 ).
  ENDMETHOD.

  METHOD property_thresholds.
    result = _generic( name = `propertyThresholds`
                       ns   = `si` ).
  ENDMETHOD.

  METHOD proportion_zoom_strategy.
    DATA temp380 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp381 LIKE LINE OF temp380.
    CLEAR temp380.

    temp381-n = `zoomLevel`.
    temp381-v = zoomlevel.
    INSERT temp381 INTO TABLE temp380.
    result = _generic( name   = `ProportionZoomStrategy`
                       ns     = `axistime`
                       t_prop = temp380 ).
  ENDMETHOD.

  METHOD quick_view.
    DATA temp382 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp383 LIKE LINE OF temp382.
    CLEAR temp382.

    temp383-n = `placement`.
    temp383-v = placement.
    INSERT temp383 INTO TABLE temp382.
    temp383-n = `width`.
    temp383-v = width.
    INSERT temp383 INTO TABLE temp382.
    temp383-n = `afterClose`.
    temp383-v = afterclose.
    INSERT temp383 INTO TABLE temp382.
    temp383-n = `afterOpen`.
    temp383-v = afteropen.
    INSERT temp383 INTO TABLE temp382.
    temp383-n = `beforeClose`.
    temp383-v = beforeclose.
    INSERT temp383 INTO TABLE temp382.
    temp383-n = `beforeOpen`.
    temp383-v = beforeopen.
    INSERT temp383 INTO TABLE temp382.
    result = _generic( name   = `QuickView`
                       t_prop = temp382 ).
  ENDMETHOD.

  METHOD quick_view_group.
    DATA temp384 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp385 LIKE LINE OF temp384.
    CLEAR temp384.

    temp385-n = `heading`.
    temp385-v = heading.
    INSERT temp385 INTO TABLE temp384.
    temp385-n = `visible`.
    temp385-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp385 INTO TABLE temp384.
    result = _generic( name   = `QuickViewGroup`
                       t_prop = temp384 ).
  ENDMETHOD.

  METHOD quick_view_group_element.
    DATA temp386 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp387 LIKE LINE OF temp386.
    CLEAR temp386.

    temp387-n = `emailSubject`.
    temp387-v = emailsubject.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `label`.
    temp387-v = label.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `pageLinkId`.
    temp387-v = pagelinkid.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `target`.
    temp387-v = target.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `type`.
    temp387-v = type.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `url`.
    temp387-v = url.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `value`.
    temp387-v = value.
    INSERT temp387 INTO TABLE temp386.
    temp387-n = `visible`.
    temp387-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp387 INTO TABLE temp386.
    result = _generic( name   = `QuickViewGroupElement`
                       t_prop = temp386 ).
  ENDMETHOD.

  METHOD quick_view_page.
    DATA temp388 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp389 LIKE LINE OF temp388.
    CLEAR temp388.

    temp389-n = `description`.
    temp389-v = description.
    INSERT temp389 INTO TABLE temp388.
    temp389-n = `header`.
    temp389-v = header.
    INSERT temp389 INTO TABLE temp388.
    temp389-n = `pageId`.
    temp389-v = pageid.
    INSERT temp389 INTO TABLE temp388.
    temp389-n = `title`.
    temp389-v = title.
    INSERT temp389 INTO TABLE temp388.
    temp389-n = `titleUrl`.
    temp389-v = titleurl.
    INSERT temp389 INTO TABLE temp388.
    result = _generic( name   = `QuickViewPage`
                       t_prop = temp388 ).
  ENDMETHOD.

  METHOD quick_view_page_avatar.
    result = _generic( `avatar` ).
  ENDMETHOD.

  METHOD radial_micro_chart.
    DATA temp390 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp391 LIKE LINE OF temp390.
    result = me.

    CLEAR temp390.

    temp391-n = `percentage`.
    temp391-v = percentage.
    INSERT temp391 INTO TABLE temp390.
    temp391-n = `press`.
    temp391-v = press.
    INSERT temp391 INTO TABLE temp390.
    temp391-n = `size`.
    temp391-v = size.
    INSERT temp391 INTO TABLE temp390.
    temp391-n = `height`.
    temp391-v = height.
    INSERT temp391 INTO TABLE temp390.
    temp391-n = `alignContent`.
    temp391-v = aligncontent.
    INSERT temp391 INTO TABLE temp390.
    temp391-n = `hideOnNoData`.
    temp391-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp391 INTO TABLE temp390.
    temp391-n = `valueColor`.
    temp391-v = valuecolor.
    INSERT temp391 INTO TABLE temp390.
    _generic( name   = `RadialMicroChart`
              ns     = `mchart`
              t_prop = temp390 ).
  ENDMETHOD.

  METHOD radio_button.
    DATA temp392 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp393 LIKE LINE OF temp392.
    CLEAR temp392.

    temp393-n = `id`.
    temp393-v = id.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `activeHandling`.
    temp393-v = z2ui5_cl_util=>boolean_abap_2_json( activehandling ).
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `editable`.
    temp393-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `enabled`.
    temp393-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `selected`.
    temp393-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `useEntireWidth`.
    temp393-v = z2ui5_cl_util=>boolean_abap_2_json( useentirewidth ).
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `text`.
    temp393-v = text.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `textDirection`.
    temp393-v = textdirection.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `textAlign`.
    temp393-v = textalign.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `groupName`.
    temp393-v = groupname.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `valueState`.
    temp393-v = valuestate.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `width`.
    temp393-v = width.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `select`.
    temp393-v = select.
    INSERT temp393 INTO TABLE temp392.
    temp393-n = `visible`.
    temp393-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp393 INTO TABLE temp392.
    result = _generic(
                 name   = `RadioButton`
                 t_prop = temp392 ).
  ENDMETHOD.

  METHOD radio_button_group.
    DATA temp394 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp395 LIKE LINE OF temp394.
    CLEAR temp394.

    temp395-n = `id`.
    temp395-v = id.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `columns`.
    temp395-v = columns.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `editable`.
    temp395-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `enabled`.
    temp395-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `selectedIndex`.
    temp395-v = selectedindex.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `textDirection`.
    temp395-v = textdirection.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `valueState`.
    temp395-v = valuestate.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `select`.
    temp395-v = select.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `width`.
    temp395-v = width.
    INSERT temp395 INTO TABLE temp394.
    temp395-n = `class`.
    temp395-v = class.
    INSERT temp395 INTO TABLE temp394.
    result = _generic( name   = `RadioButtonGroup`
                       t_prop = temp394 ).
  ENDMETHOD.

  METHOD range_slider.
    DATA temp396 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp397 LIKE LINE OF temp396.
    result = me.

    CLEAR temp396.

    temp397-n = `class`.
    temp397-v = class.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `endValue`.
    temp397-v = endvalue.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `id`.
    temp397-v = id.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `labelInterval`.
    temp397-v = labelinterval.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `max`.
    temp397-v = max.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `min`.
    temp397-v = min.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `showTickmarks`.
    temp397-v = z2ui5_cl_util=>boolean_abap_2_json( showtickmarks ).
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `startValue`.
    temp397-v = startvalue.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `step`.
    temp397-v = step.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `width`.
    temp397-v = width.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `value`.
    temp397-v = value.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `value2`.
    temp397-v = value2.
    INSERT temp397 INTO TABLE temp396.
    temp397-n = `change`.
    temp397-v = change.
    INSERT temp397 INTO TABLE temp396.
    _generic( name   = `RangeSlider`
              t_prop = temp396 ).
  ENDMETHOD.

  METHOD rating_indicator.

    DATA temp398 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp399 LIKE LINE OF temp398.
    CLEAR temp398.

    temp399-n = `class`.
    temp399-v = class.
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `maxValue`.
    temp399-v = maxvalue.
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `displayOnly`.
    temp399-v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ).
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `editable`.
    temp399-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `iconSize`.
    temp399-v = iconsize.
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `value`.
    temp399-v = value.
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `id`.
    temp399-v = id.
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `change`.
    temp399-v = change.
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `enabled`.
    temp399-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp399 INTO TABLE temp398.
    temp399-n = `tooltip`.
    temp399-v = tooltip.
    INSERT temp399 INTO TABLE temp398.
    result = _generic( name   = `RatingIndicator`
                       t_prop = temp398 ).

  ENDMETHOD.

  METHOD relationship.

    DATA temp400 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp401 LIKE LINE OF temp400.
    CLEAR temp400.

    temp401-n = `shapeId`.
    temp401-v = shapeid.
    INSERT temp401 INTO TABLE temp400.
    temp401-n = `type`.
    temp401-v = type.
    INSERT temp401 INTO TABLE temp400.
    temp401-n = `successor`.
    temp401-v = successor.
    INSERT temp401 INTO TABLE temp400.
    temp401-n = `predecessor`.
    temp401-v = predecessor.
    INSERT temp401 INTO TABLE temp400.
    result = _generic( name   = `Relationship`
                       ns     = `gantt`
                       t_prop = temp400 ).

  ENDMETHOD.

  METHOD relationships.
    result = _generic( name = `relationships`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD responsive_scale.
    DATA temp402 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp403 LIKE LINE OF temp402.
    CLEAR temp402.

    temp403-n = `id`.
    temp403-v = id.
    INSERT temp403 INTO TABLE temp402.
    temp403-n = `class`.
    temp403-v = class.
    INSERT temp403 INTO TABLE temp402.
    temp403-n = `tickmarksBetweenLabels`.
    temp403-v = tickmarksbetweenlabels.
    INSERT temp403 INTO TABLE temp402.
    result = _generic( name   = `ResponsiveScale`
                       t_prop = temp402 ).
  ENDMETHOD.

  METHOD responsive_splitter.
    DATA temp404 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp405 LIKE LINE OF temp404.
    CLEAR temp404.

    temp405-n = `defaultPane`.
    temp405-v = defaultpane.
    INSERT temp405 INTO TABLE temp404.
    temp405-n = `height`.
    temp405-v = height.
    INSERT temp405 INTO TABLE temp404.
    temp405-n = `width`.
    temp405-v = width.
    INSERT temp405 INTO TABLE temp404.
    result = _generic( name   = `ResponsiveSplitter`
                       ns     = `layout`
                       t_prop = temp404 ).
  ENDMETHOD.

  METHOD rich_text_editor.
    DATA temp406 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp407 LIKE LINE OF temp406.
    CLEAR temp406.

    temp407-n = `buttonGroups`.
    temp407-v = buttongroups.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `customToolbar`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( customtoolbar ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `editable`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `height`.
    temp407-v = height.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `editorType`.
    temp407-v = editortype.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `plugins`.
    temp407-v = plugins.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `textDirection`.
    temp407-v = textdirection.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `value`.
    temp407-v = value.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `beforeEditorInit`.
    temp407-v = beforeeditorinit.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `change`.
    temp407-v = change.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `ready`.
    temp407-v = ready.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `readyRecurring`.
    temp407-v = readyrecurring.
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `required`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `sanitizeValue`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( sanitizevalue ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupClipboard`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgroupclipboard ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupFont`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgroupfont ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupFontStyle`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgroupfontstyle ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupInsert`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgroupinsert ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupLink`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgrouplink ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupStructure`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgroupstructure ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupTextAlign`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgrouptextalign ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `showGroupUndo`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( showgroupundo ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `useLegacyTheme`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( uselegacytheme ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `wrapping`.
    temp407-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp407 INTO TABLE temp406.
    temp407-n = `width`.
    temp407-v = width.
    INSERT temp407 INTO TABLE temp406.
    result = _generic(
        name   = `RichTextEditor`
        ns     = `text`
        t_prop = temp406 ).

  ENDMETHOD.

  METHOD route.
    DATA temp408 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp409 LIKE LINE OF temp408.

    result = me.

    CLEAR temp408.

    temp409-n = `id`.
    temp409-v = id.
    INSERT temp409 INTO TABLE temp408.
    temp409-n = `position`.
    temp409-v = position.
    INSERT temp409 INTO TABLE temp408.
    temp409-n = `routetype`.
    temp409-v = routetype.
    INSERT temp409 INTO TABLE temp408.
    temp409-n = `lineDash`.
    temp409-v = linedash.
    INSERT temp409 INTO TABLE temp408.
    temp409-n = `linewidth`.
    temp409-v = linewidth.
    INSERT temp409 INTO TABLE temp408.
    temp409-n = `color`.
    temp409-v = color.
    INSERT temp409 INTO TABLE temp408.
    temp409-n = `colorBorder`.
    temp409-v = colorborder.
    INSERT temp409 INTO TABLE temp408.
    _generic( name   = `Route`
              ns     = `vbm`
              t_prop = temp408 ).

  ENDMETHOD.

  METHOD routes.

    DATA temp410 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp411 LIKE LINE OF temp410.
    CLEAR temp410.

    temp411-n = `id`.
    temp411-v = id.
    INSERT temp411 INTO TABLE temp410.
    temp411-n = `items`.
    temp411-v = items.
    INSERT temp411 INTO TABLE temp410.
    result = _generic( name   = `Routes`
                       ns     = `vbm`
                       t_prop = temp410 ).

  ENDMETHOD.

  METHOD rows.
    result = _generic( `rows` ).
  ENDMETHOD.

  METHOD row_settings_template.
    result = _generic( name = `rowSettingsTemplate`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD rules.
    result = _generic( `rules` ).
  ENDMETHOD.

  METHOD scroll_container.
    DATA temp412 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp413 LIKE LINE OF temp412.
    CLEAR temp412.

    temp413-n = `height`.
    temp413-v = height.
    INSERT temp413 INTO TABLE temp412.
    temp413-n = `width`.
    temp413-v = width.
    INSERT temp413 INTO TABLE temp412.
    temp413-n = `id`.
    temp413-v = id.
    INSERT temp413 INTO TABLE temp412.
    temp413-n = `visible`.
    temp413-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp413 INTO TABLE temp412.
    temp413-n = `vertical`.
    temp413-v = z2ui5_cl_util=>boolean_abap_2_json( vertical ).
    INSERT temp413 INTO TABLE temp412.
    temp413-n = `horizontal`.
    temp413-v = z2ui5_cl_util=>boolean_abap_2_json( horizontal ).
    INSERT temp413 INTO TABLE temp412.
    temp413-n = `focusable`.
    temp413-v = z2ui5_cl_util=>boolean_abap_2_json( focusable ).
    INSERT temp413 INTO TABLE temp412.
    result = _generic( name   = `ScrollContainer`
                       t_prop = temp412 ).
  ENDMETHOD.

  METHOD search_field.
    DATA temp414 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp415 LIKE LINE OF temp414.
    result = me.

    CLEAR temp414.

    temp415-n = `width`.
    temp415-v = width.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `search`.
    temp415-v = search.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `value`.
    temp415-v = value.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `id`.
    temp415-v = id.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `class`.
    temp415-v = class.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `change`.
    temp415-v = change.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `maxLength`.
    temp415-v = maxlength.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `placeholder`.
    temp415-v = placeholder.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `suggest`.
    temp415-v = suggest.
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `enableSuggestions`.
    temp415-v = z2ui5_cl_util=>boolean_abap_2_json( enablesuggestions ).
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `showRefreshButton`.
    temp415-v = z2ui5_cl_util=>boolean_abap_2_json( showrefreshbutton ).
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `showSearchButton`.
    temp415-v = z2ui5_cl_util=>boolean_abap_2_json( showsearchbutton ).
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `visible`.
    temp415-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `enabled`.
    temp415-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp415 INTO TABLE temp414.
    temp415-n = `liveChange`.
    temp415-v = livechange.
    INSERT temp415 INTO TABLE temp414.
    _generic( name   = `SearchField`
              t_prop = temp414 ).
  ENDMETHOD.

  METHOD second_status.
    result = _generic( `secondStatus` ).
  ENDMETHOD.

  METHOD sections.
    result = _generic( name = `sections`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD segmented_button.
    DATA temp416 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp417 LIKE LINE OF temp416.
    CLEAR temp416.

    temp417-n = `id`.
    temp417-v = id.
    INSERT temp417 INTO TABLE temp416.
    temp417-n = `selectedKey`.
    temp417-v = selected_key.
    INSERT temp417 INTO TABLE temp416.
    temp417-n = `visible`.
    temp417-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp417 INTO TABLE temp416.
    temp417-n = `enabled`.
    temp417-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp417 INTO TABLE temp416.
    temp417-n = `selectionChange`.
    temp417-v = selection_change.
    INSERT temp417 INTO TABLE temp416.
    result = _generic( name   = `SegmentedButton`
                       t_prop = temp416 ).
  ENDMETHOD.

  METHOD segmented_button_item.
    DATA temp418 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp419 LIKE LINE OF temp418.
    result = me.

    CLEAR temp418.

    temp419-n = `icon`.
    temp419-v = icon.
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `press`.
    temp419-v = press.
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `width`.
    temp419-v = width.
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `key`.
    temp419-v = key.
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `textDirection`.
    temp419-v = textdirection.
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `enabled`.
    temp419-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `visible`.
    temp419-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp419 INTO TABLE temp418.
    temp419-n = `text`.
    temp419-v = text.
    INSERT temp419 INTO TABLE temp418.
    _generic( name   = `SegmentedButtonItem`
              t_prop = temp418 ).
  ENDMETHOD.

  METHOD segments.
    result = _generic( name = `segments`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD select.
    DATA temp420 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp421 LIKE LINE OF temp420.
    CLEAR temp420.

    temp421-n = `id`.
    temp421-v = id.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `class`.
    temp421-v = class.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `autoAdjustWidth`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( autoadjustwidth ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `columnRatio`.
    temp421-v = columnratio.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `editable`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `enabled`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `forceSelection`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( forceselection ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `icon`.
    temp421-v = icon.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `maxWidth`.
    temp421-v = maxwidth.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `name`.
    temp421-v = name.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `required`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `resetOnMissingKey`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( resetonmissingkey ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `selectedItemId`.
    temp421-v = selecteditemid.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `selectedKey`.
    temp421-v = selectedkey.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `showSecondaryValues`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `textAlign`.
    temp421-v = textalign.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `textDirection`.
    temp421-v = textdirection.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `type`.
    temp421-v = type.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `valueState`.
    temp421-v = valuestate.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `valueStateText`.
    temp421-v = valuestatetext.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `width`.
    temp421-v = width.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `wrapItemsText`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( wrapitemstext ).
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `items`.
    temp421-v = items.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `selectedItem`.
    temp421-v = selecteditem.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `change`.
    temp421-v = change.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `liveChange`.
    temp421-v = livechange.
    INSERT temp421 INTO TABLE temp420.
    temp421-n = `visible`.
    temp421-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp421 INTO TABLE temp420.
    result = _generic( name   = `Select`
                       t_prop = temp420 ).
  ENDMETHOD.

  METHOD shapes1.
    result = _generic( name = `shapes1`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD shapes2.
    result = _generic( name = `shapes2`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD shape_group.
    result = _generic( name = `ShapeGroup`
                       ns   = `si` ).
  ENDMETHOD.

  METHOD shell.
    DATA temp422 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp423 LIKE LINE OF temp422.
    CLEAR temp422.

    temp423-n = `appWidthLimited`.
    temp423-v = z2ui5_cl_util=>boolean_abap_2_json( appwidthlimited ).
    INSERT temp423 INTO TABLE temp422.
    result = _generic(
        name   = `Shell`
        ns     = ns
        t_prop = temp422 ).
  ENDMETHOD.

  METHOD shell_bar.
    DATA temp424 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp425 LIKE LINE OF temp424.
    CLEAR temp424.

    temp425-n = `homeIcon`.
    temp425-v = homeicon.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `homeIconTooltip`.
    temp425-v = homeicontooltip.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `title`.
    temp425-v = title.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `secondTitle`.
    temp425-v = secondtitle.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `showCopilot`.
    temp425-v = z2ui5_cl_util=>boolean_abap_2_json( showcopilot ).
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `showMenuButton`.
    temp425-v = z2ui5_cl_util=>boolean_abap_2_json( showmenubutton ).
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `showNavButton`.
    temp425-v = z2ui5_cl_util=>boolean_abap_2_json( shownavbutton ).
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `showNotifications`.
    temp425-v = z2ui5_cl_util=>boolean_abap_2_json( shownotifications ).
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `showProductSwitcher`.
    temp425-v = z2ui5_cl_util=>boolean_abap_2_json( showproductswitcher ).
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `showSearch`.
    temp425-v = z2ui5_cl_util=>boolean_abap_2_json( showsearch ).
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `notificationsNumber`.
    temp425-v = notificationsnumber.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `avatarPressed`.
    temp425-v = avatarpressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `copilotPressed`.
    temp425-v = copilotpressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `homeIconPressed`.
    temp425-v = homeiconpressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `menuButtonPressed`.
    temp425-v = menubuttonpressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `navButtonPressed`.
    temp425-v = navbuttonpressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `notificationsPressed`.
    temp425-v = notificationspressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `productSwitcherPressed`.
    temp425-v = productswitcherpressed.
    INSERT temp425 INTO TABLE temp424.
    temp425-n = `searchButtonPressed`.
    temp425-v = searchbuttonpressed.
    INSERT temp425 INTO TABLE temp424.
    result = _generic( name   = `ShellBar`
                       ns     = `f`
                       t_prop = temp424 ).

  ENDMETHOD.

  METHOD side_content.
    DATA temp426 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp427 LIKE LINE OF temp426.
    CLEAR temp426.

    temp427-n = `width`.
    temp427-v = width.
    INSERT temp427 INTO TABLE temp426.
    result = _generic( name   = `sideContent`
                       ns     = `layout`
                       t_prop = temp426 ).

  ENDMETHOD.

  METHOD side_panel.
    DATA temp428 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp429 LIKE LINE OF temp428.
    CLEAR temp428.

    temp429-n = `sidePanelWidth`.
    temp429-v = sidepanelwidth.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `sidePanelResizeStep`.
    temp429-v = sidepanelresizestep.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `sidePanelResizeLargerStep`.
    temp429-v = sidepanelresizelargerstep.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `sidePanelPosition`.
    temp429-v = sidepanelposition.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `sidePanelMinWidth`.
    temp429-v = sidepanelminwidth.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `sidePanelMaxWidth`.
    temp429-v = sidepanelmaxwidth.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `sidePanelResizable`.
    temp429-v = z2ui5_cl_util=>boolean_abap_2_json( sidepanelresizable ).
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `actionBarExpanded`.
    temp429-v = z2ui5_cl_util=>boolean_abap_2_json( actionbarexpanded ).
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `toggle`.
    temp429-v = toggle.
    INSERT temp429 INTO TABLE temp428.
    temp429-n = `ariaLabel`.
    temp429-v = arialabel.
    INSERT temp429 INTO TABLE temp428.
    result = _generic(
        name   = `SidePanel`
        ns     = `f`
        t_prop = temp428 ).
  ENDMETHOD.

  METHOD side_panel_item.
    DATA temp430 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp431 LIKE LINE OF temp430.
    CLEAR temp430.

    temp431-n = `icon`.
    temp431-v = icon.
    INSERT temp431 INTO TABLE temp430.
    temp431-n = `enabled`.
    temp431-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp431 INTO TABLE temp430.
    temp431-n = `key`.
    temp431-v = key.
    INSERT temp431 INTO TABLE temp430.
    temp431-n = `text`.
    temp431-v = text.
    INSERT temp431 INTO TABLE temp430.
    result = _generic( name   = `SidePanelItem`
                       ns     = `f`
                       t_prop = temp430 ).
  ENDMETHOD.

  METHOD simple_form.
    DATA temp432 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp433 LIKE LINE OF temp432.
    CLEAR temp432.

    temp433-n = `title`.
    temp433-v = title.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `layout`.
    temp433-v = layout.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `class`.
    temp433-v = class.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `adjustLabelSpan`.
    temp433-v = adjustlabelspan.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `backgroundDesign`.
    temp433-v = backgrounddesign.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `breakpointL`.
    temp433-v = breakpointl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `breakpointM`.
    temp433-v = breakpointm.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `breakpointXL`.
    temp433-v = breakpointxl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `emptySpanL`.
    temp433-v = emptyspanl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `emptySpanM`.
    temp433-v = emptyspanm.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `emptySpanS`.
    temp433-v = emptyspans.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `emptySpanXL`.
    temp433-v = emptyspanxl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `labelSpanL`.
    temp433-v = labelspanl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `labelSpanM`.
    temp433-v = labelspanm.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `labelSpanS`.
    temp433-v = labelspans.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `labelSpanXL`.
    temp433-v = labelspanxl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `maxContainerCols`.
    temp433-v = maxcontainercols.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `minWidth`.
    temp433-v = minwidth.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `singleContainerFullSize`.
    temp433-v = z2ui5_cl_util=>boolean_abap_2_json( singlecontainerfullsize ).
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `visible`.
    temp433-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `width`.
    temp433-v = width.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `id`.
    temp433-v = id.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `columnsXL`.
    temp433-v = columnsxl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `columnsL`.
    temp433-v = columnsl.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `columnsM`.
    temp433-v = columnsm.
    INSERT temp433 INTO TABLE temp432.
    temp433-n = `editable`.
    temp433-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp433 INTO TABLE temp432.
    result = _generic(
        name   = `SimpleForm`
        ns     = `form`
        t_prop = temp432 ).
  ENDMETHOD.

  METHOD slider.
    DATA temp434 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp435 LIKE LINE OF temp434.
    result = me.

    CLEAR temp434.

    temp435-n = `class`.
    temp435-v = class.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `id`.
    temp435-v = id.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `max`.
    temp435-v = max.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `min`.
    temp435-v = min.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `enableTickmarks`.
    temp435-v = z2ui5_cl_util=>boolean_abap_2_json( enabletickmarks ).
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `enabled`.
    temp435-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `value`.
    temp435-v = value.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `step`.
    temp435-v = step.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `change`.
    temp435-v = change.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `width`.
    temp435-v = width.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `inputsAsTooltips`.
    temp435-v = inputsastooltips.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `showAdvancedTooltip`.
    temp435-v = showadvancedtooltip.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `showHandleTooltip`.
    temp435-v = showhandletooltip.
    INSERT temp435 INTO TABLE temp434.
    temp435-n = `liveChange`.
    temp435-v = livechange.
    INSERT temp435 INTO TABLE temp434.
    _generic( name   = `Slider`
              t_prop = temp434 ).
  ENDMETHOD.

  METHOD slide_tile.

    DATA temp436 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp437 LIKE LINE OF temp436.
    CLEAR temp436.

    temp437-n = `displayTime`.
    temp437-v = displaytime.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `height`.
    temp437-v = height.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `scope`.
    temp437-v = scope.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `sizeBehavior`.
    temp437-v = sizebehavior.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `transitionTime`.
    temp437-v = transitiontime.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `width`.
    temp437-v = width.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `press`.
    temp437-v = press.
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `visible`.
    temp437-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp437 INTO TABLE temp436.
    temp437-n = `class`.
    temp437-v = class.
    INSERT temp437 INTO TABLE temp436.
    result = _generic( name   = `SlideTile`
                       t_prop = temp436 ).
  ENDMETHOD.

  METHOD smart_variant_management.
    DATA temp438 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp439 LIKE LINE OF temp438.
    result = me.

    CLEAR temp438.

    temp439-n = `id`.
    temp439-v = id.
    INSERT temp439 INTO TABLE temp438.
    temp439-n = `showExecuteOnSelection`.
    temp439-v = z2ui5_cl_util=>boolean_abap_2_json( showexecuteonselection ).
    INSERT temp439 INTO TABLE temp438.
    temp439-n = `persistencyKey`.
    temp439-v = persistencykey.
    INSERT temp439 INTO TABLE temp438.
    _generic( name   = `SmartVariantManagement`
              ns     = `smartVariantManagement`
              t_prop = temp438 ).

  ENDMETHOD.

  METHOD snapped_content.
    result = _generic( name = `snappedContent`
                       ns   = ns ).
  ENDMETHOD.

  METHOD snapped_heading.
    result = me.
    result = _generic( name = `snappedHeading`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD snapped_title_on_mobile.
    result = _generic( name = `snappedTitleOnMobile`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD sort_items.
    result = _generic( `sortItems` ).
  ENDMETHOD.

  METHOD splitter_layout_data.
    DATA temp440 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp441 LIKE LINE OF temp440.
    CLEAR temp440.

    temp441-n = `size`.
    temp441-v = size.
    INSERT temp441 INTO TABLE temp440.
    temp441-n = `minSize`.
    temp441-v = minsize.
    INSERT temp441 INTO TABLE temp440.
    temp441-n = `resizable`.
    temp441-v = z2ui5_cl_util=>boolean_abap_2_json( resizable ).
    INSERT temp441 INTO TABLE temp440.
    result = _generic( name   = `SplitterLayoutData`
                       ns     = `layout`
                       t_prop = temp440 ).
  ENDMETHOD.

  METHOD split_container.
    DATA temp442 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp443 LIKE LINE OF temp442.

    result = me.

    CLEAR temp442.

    temp443-n = `id`.
    temp443-v = id.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `initialDetail`.
    temp443-v = initialdetail.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `initialMaster`.
    temp443-v = initialmaster.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `backgroundColor`.
    temp443-v = backgroundcolor.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `backgroundImage`.
    temp443-v = backgroundimage.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `backgroundOpacity`.
    temp443-v = backgroundopacity.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `backgroundRepeat`.
    temp443-v = backgroundrepeat.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `defaultTransitionNameDetail`.
    temp443-v = defaulttransitionnamedetail.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `defaultTransitionNameMaster`.
    temp443-v = defaulttransitionnamemaster.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `masterButtonText`.
    temp443-v = masterbuttontext.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `masterButtonTooltip`.
    temp443-v = masterbuttontooltip.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `afterDetailNavigate`.
    temp443-v = afterdetailnavigate.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `afterMasterClose`.
    temp443-v = aftermasterclose.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `afterMasterNavigate`.
    temp443-v = aftermasternavigate.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `afterMasterOpen`.
    temp443-v = aftermasteropen.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `beforeMasterClose`.
    temp443-v = beforemasterclose.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `beforeMasterOpen`.
    temp443-v = beforemasteropen.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `detailNavigate`.
    temp443-v = detailnavigate.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `masterButton`.
    temp443-v = masterbutton.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `masterNavigate`.
    temp443-v = masternavigate.
    INSERT temp443 INTO TABLE temp442.
    temp443-n = `mode`.
    temp443-v = mode.
    INSERT temp443 INTO TABLE temp442.
    _generic( name   = `SplitContainer`
              t_prop = temp442 ).

  ENDMETHOD.

  METHOD split_pane.
    DATA temp444 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp445 LIKE LINE OF temp444.
    CLEAR temp444.

    temp445-n = `id`.
    temp445-v = id.
    INSERT temp445 INTO TABLE temp444.
    temp445-n = `requiredParentWidth`.
    temp445-v = requiredparentwidth.
    INSERT temp445 INTO TABLE temp444.
    result = _generic( name   = `SplitPane`
                       ns     = `layout`
                       t_prop = temp444 ).
  ENDMETHOD.

  METHOD spot.
    DATA temp446 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp447 LIKE LINE OF temp446.

    result = me.

    CLEAR temp446.

    temp447-n = `id`.
    temp447-v = id.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `position`.
    temp447-v = position.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `contentOffset`.
    temp447-v = contentoffset.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `type`.
    temp447-v = type.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `scale`.
    temp447-v = scale.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `tooltip`.
    temp447-v = tooltip.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `image`.
    temp447-v = image.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `icon`.
    temp447-v = icon.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `text`.
    temp447-v = text.
    INSERT temp447 INTO TABLE temp446.
    temp447-n = `click`.
    temp447-v = click.
    INSERT temp447 INTO TABLE temp446.
    _generic( name   = `Spot`
              ns     = `vbm`
              t_prop = temp446 ).

  ENDMETHOD.

  METHOD spots.

    DATA temp448 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp449 LIKE LINE OF temp448.
    CLEAR temp448.

    temp449-n = `id`.
    temp449-v = id.
    INSERT temp449 INTO TABLE temp448.
    temp449-n = `items`.
    temp449-v = items.
    INSERT temp449 INTO TABLE temp448.
    result = _generic( name   = `Spots`
                       ns     = `vbm`
                       t_prop = temp448 ).

  ENDMETHOD.

  METHOD stacked_bar_micro_chart.
    DATA temp450 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp451 LIKE LINE OF temp450.

    result = me.

    CLEAR temp450.

    temp451-n = `height`.
    temp451-v = height.
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `press`.
    temp451-v = press.
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `maxValue`.
    temp451-v = maxvalue.
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `precision`.
    temp451-v = precision.
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `size`.
    temp451-v = size.
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `hideOnNoData`.
    temp451-v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ).
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `displayZeroValue`.
    temp451-v = z2ui5_cl_util=>boolean_abap_2_json( displayzerovalue ).
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `showLabels`.
    temp451-v = z2ui5_cl_util=>boolean_abap_2_json( showlabels ).
    INSERT temp451 INTO TABLE temp450.
    temp451-n = `width`.
    temp451-v = width.
    INSERT temp451 INTO TABLE temp450.
    _generic( name   = `StackedBarMicroChart`
              ns     = `mchart`
              t_prop = temp450 ).
  ENDMETHOD.

  METHOD standard_list_item.
    DATA temp452 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp453 LIKE LINE OF temp452.
    result = me.

    CLEAR temp452.

    temp453-n = `title`.
    temp453-v = title.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `description`.
    temp453-v = description.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `icon`.
    temp453-v = icon.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `info`.
    temp453-v = info.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `press`.
    temp453-v = press.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `type`.
    temp453-v = type.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `counter`.
    temp453-v = counter.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `activeIcon`.
    temp453-v = activeicon.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `adaptTitleSize`.
    temp453-v = z2ui5_cl_util=>boolean_abap_2_json( adapttitlesize ).
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `unread`.
    temp453-v = z2ui5_cl_util=>boolean_abap_2_json( unread ).
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `iconInset`.
    temp453-v = z2ui5_cl_util=>boolean_abap_2_json( iconinset ).
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `infoStateInverted`.
    temp453-v = z2ui5_cl_util=>boolean_abap_2_json( infostateinverted ).
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `wrapping`.
    temp453-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `infoState`.
    temp453-v = infostate.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `highlight`.
    temp453-v = highlight.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `wrapCharLimit`.
    temp453-v = wrapcharlimit.
    INSERT temp453 INTO TABLE temp452.
    temp453-n = `selected`.
    temp453-v = selected.
    INSERT temp453 INTO TABLE temp452.
    _generic(
        name   = `StandardListItem`
        t_prop = temp452 ).
  ENDMETHOD.

  METHOD standard_tree_item.
    DATA temp454 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp455 LIKE LINE OF temp454.
    result = me.

    CLEAR temp454.

    temp455-n = `title`.
    temp455-v = title.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `icon`.
    temp455-v = icon.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `press`.
    temp455-v = press.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `detailPress`.
    temp455-v = detailpress.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `type`.
    temp455-v = type.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `counter`.
    temp455-v = counter.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `selected`.
    temp455-v = selected.
    INSERT temp455 INTO TABLE temp454.
    temp455-n = `tooltip`.
    temp455-v = tooltip.
    INSERT temp455 INTO TABLE temp454.
    _generic( name   = `StandardTreeItem`
              t_prop = temp454 ).

  ENDMETHOD.

  METHOD status.

    DATA temp456 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp457 LIKE LINE OF temp456.
    CLEAR temp456.

    temp457-n = `id`.
    temp457-v = id.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `class`.
    temp457-v = class.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `backgroundColor`.
    temp457-v = backgroundcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `borderColor`.
    temp457-v = bordercolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `borderStyle`.
    temp457-v = borderstyle.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `borderWidth`.
    temp457-v = borderwidth.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `contentColor`.
    temp457-v = contentcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `headerContentColor`.
    temp457-v = headercontentcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `hoverBackgroundColor`.
    temp457-v = hoverbackgroundcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `hoverBorderColor`.
    temp457-v = hoverbordercolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `hoverContentColor`.
    temp457-v = hovercontentcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `key`.
    temp457-v = key.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `legendColor`.
    temp457-v = legendcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `selectedBackgroundColor`.
    temp457-v = selectedbackgroundcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `selectedBorderColor`.
    temp457-v = selectedbordercolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `selectedContentColor`.
    temp457-v = selectedcontentcolor.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `title`.
    temp457-v = title.
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `useFocusColorAsContentColor`.
    temp457-v = z2ui5_cl_util=>boolean_abap_2_json( usefocuscolorascontentcolor ).
    INSERT temp457 INTO TABLE temp456.
    temp457-n = `visible`.
    temp457-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp457 INTO TABLE temp456.
    result = _generic(
                 name   = `Status`
                 ns     = `networkgraph`
                 t_prop = temp456 ).

  ENDMETHOD.

  METHOD statuses.
    DATA temp458 TYPE string.
    CASE ns.
      WHEN ``.
        temp458 = `networkgraph`.
      WHEN OTHERS.
        temp458 = ns.
    ENDCASE.
    result = _generic( name = `statuses`
                       ns   = temp458 ).
  ENDMETHOD.

  METHOD status_indicator.
    DATA temp459 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp460 LIKE LINE OF temp459.
    CLEAR temp459.

    temp460-n = `id`.
    temp460-v = id.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `class`.
    temp460-v = class.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `height`.
    temp460-v = height.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `labelPosition`.
    temp460-v = labelposition.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `showLabel`.
    temp460-v = z2ui5_cl_util=>boolean_abap_2_json( showlabel ).
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `size`.
    temp460-v = size.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `value`.
    temp460-v = value.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `viewBox`.
    temp460-v = viewbox.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `width`.
    temp460-v = width.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `press`.
    temp460-v = press.
    INSERT temp460 INTO TABLE temp459.
    temp460-n = `visible`.
    temp460-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp460 INTO TABLE temp459.
    result = _generic( name   = `StatusIndicator`
                       ns     = `si`
                       t_prop = temp459 ).
  ENDMETHOD.

  METHOD step_input.
    DATA temp461 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp462 LIKE LINE OF temp461.
    result = me.

    CLEAR temp461.

    temp462-n = `id`.
    temp462-v = id.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `max`.
    temp462-v = max.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `min`.
    temp462-v = min.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `step`.
    temp462-v = step.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `width`.
    temp462-v = width.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `value`.
    temp462-v = value.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `valueState`.
    temp462-v = valuestate.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `enabled`.
    temp462-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `description`.
    temp462-v = description.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `displayValuePrecision`.
    temp462-v = displayvalueprecision.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `largerStep`.
    temp462-v = largerstep.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `stepMode`.
    temp462-v = stepmode.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `editable`.
    temp462-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `fieldWidth`.
    temp462-v = fieldwidth.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `textalign`.
    temp462-v = textalign.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `validationMode`.
    temp462-v = validationmode.
    INSERT temp462 INTO TABLE temp461.
    temp462-n = `change`.
    temp462-v = change.
    INSERT temp462 INTO TABLE temp461.
    _generic( name   = `StepInput`
              t_prop = temp461 ).
  ENDMETHOD.

  METHOD stringify.

    DATA lt_parts TYPE string_table.
    get_root( )->xml_get_parts( CHANGING ct_parts = lt_parts ).
    result = concat_lines_of( lt_parts ).

  ENDMETHOD.

  METHOD sub_header.

    result = _generic( name = `subHeader`
                       ns   = ns ).

  ENDMETHOD.

  METHOD sub_sections.
    result = me.
    result = _generic( name = `subSections`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD suggestion_columns.
    result = _generic( `suggestionColumns` ).
  ENDMETHOD.

  METHOD suggestion_item.
    DATA temp463 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp464 LIKE LINE OF temp463.
    result = me.

    CLEAR temp463.

    temp464-n = `description`.
    temp464-v = description.
    INSERT temp464 INTO TABLE temp463.
    temp464-n = `icon`.
    temp464-v = icon.
    INSERT temp464 INTO TABLE temp463.
    temp464-n = `key`.
    temp464-v = key.
    INSERT temp464 INTO TABLE temp463.
    temp464-n = `text`.
    temp464-v = text.
    INSERT temp464 INTO TABLE temp463.
    temp464-n = `textDirection`.
    temp464-v = textdirection.
    INSERT temp464 INTO TABLE temp463.
    _generic( name   = `SuggestionItem`
              t_prop = temp463 ).
  ENDMETHOD.

  METHOD suggestion_items.
    result = _generic( `suggestionItems` ).
  ENDMETHOD.

  METHOD suggestion_rows.
    result = _generic( `suggestionRows` ).
  ENDMETHOD.

  METHOD swim_lane_chain_layout.
    result = _generic( name = `SwimLaneChainLayout`
                       ns   = `nglayout` ).
  ENDMETHOD.

  METHOD switch.
    DATA temp465 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp466 LIKE LINE OF temp465.
    result = me.

    CLEAR temp465.

    temp466-n = `type`.
    temp466-v = type.
    INSERT temp466 INTO TABLE temp465.
    temp466-n = `enabled`.
    temp466-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp466 INTO TABLE temp465.
    temp466-n = `state`.
    temp466-v = state.
    INSERT temp466 INTO TABLE temp465.
    temp466-n = `change`.
    temp466-v = change.
    INSERT temp466 INTO TABLE temp465.
    temp466-n = `customTextOff`.
    temp466-v = customtextoff.
    INSERT temp466 INTO TABLE temp465.
    temp466-n = `customTextOn`.
    temp466-v = customtexton.
    INSERT temp466 INTO TABLE temp465.
    _generic( name   = `Switch`
              t_prop = temp465 ).
  ENDMETHOD.

  METHOD tab.
    DATA temp467 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp468 LIKE LINE OF temp467.
    CLEAR temp467.

    temp468-n = `text`.
    temp468-v = text.
    INSERT temp468 INTO TABLE temp467.
    temp468-n = `selected`.
    temp468-v = selected.
    INSERT temp468 INTO TABLE temp467.
    result = _generic( name   = `Tab`
                       ns     = `webc`
                       t_prop = temp467 ).
  ENDMETHOD.

  METHOD table.
    DATA temp469 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp470 LIKE LINE OF temp469.
    CLEAR temp469.

    temp470-n = `items`.
    temp470-v = items.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `headerText`.
    temp470-v = headertext.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `class`.
    temp470-v = class.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `growing`.
    temp470-v = growing.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `growingThreshold`.
    temp470-v = growingthreshold.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `growingScrollToLoad`.
    temp470-v = growingscrolltoload.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `sticky`.
    temp470-v = sticky.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `showSeparators`.
    temp470-v = showseparators.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `mode`.
    temp470-v = mode.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `inset`.
    temp470-v = inset.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `width`.
    temp470-v = width.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `id`.
    temp470-v = id.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `hiddenInPopin`.
    temp470-v = hiddeninpopin.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `popinLayout`.
    temp470-v = popinlayout.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `selectionChange`.
    temp470-v = selectionchange.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `backgroundDesign`.
    temp470-v = backgrounddesign.
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `visible`.
    temp470-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `alternateRowColors`.
    temp470-v = z2ui5_cl_util=>boolean_abap_2_json( alternaterowcolors ).
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `fixedLayout`.
    temp470-v = z2ui5_cl_util=>boolean_abap_2_json( fixedlayout ).
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `showOverlay`.
    temp470-v = z2ui5_cl_util=>boolean_abap_2_json( showoverlay ).
    INSERT temp470 INTO TABLE temp469.
    temp470-n = `autoPopinMode`.
    temp470-v = z2ui5_cl_util=>boolean_abap_2_json( autopopinmode ).
    INSERT temp470 INTO TABLE temp469.
    result = _generic( name   = `Table`
                       t_prop = temp469 ).
  ENDMETHOD.

  METHOD table_select_dialog.

    DATA temp471 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp472 LIKE LINE OF temp471.
    CLEAR temp471.

    temp472-n = `confirmButtonText`.
    temp472-v = confirmbuttontext.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `contentHeight`.
    temp472-v = contentheight.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `contentWidth`.
    temp472-v = contentwidth.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `draggable`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( draggable ).
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `growing`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `growingThreshold`.
    temp472-v = growingthreshold.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `multiSelect`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( multiselect ).
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `noDataText`.
    temp472-v = nodatatext.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `rememberSelections`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ).
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `resizable`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( resizable ).
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `searchPlaceholder`.
    temp472-v = searchplaceholder.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `showClearButton`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( showclearbutton ).
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `title`.
    temp472-v = title.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `titleAlignment`.
    temp472-v = titlealignment.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `items`.
    temp472-v = items.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `search`.
    temp472-v = search.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `confirm`.
    temp472-v = confirm.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `cancel`.
    temp472-v = cancel.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `liveChange`.
    temp472-v = livechange.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `selectionChange`.
    temp472-v = selectionchange.
    INSERT temp472 INTO TABLE temp471.
    temp472-n = `visible`.
    temp472-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp472 INTO TABLE temp471.
    result = _generic( name   = `TableSelectDialog`
                       t_prop = temp471 ).
  ENDMETHOD.

  METHOD tab_container.
    result = _generic( name = `TabContainer`
                       ns   = `webc` ).
  ENDMETHOD.

  METHOD task.
    DATA temp473 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp474 LIKE LINE OF temp473.
    CLEAR temp473.

    temp474-n = `time`.
    temp474-v = time.
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `endTime`.
    temp474-v = endtime.
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `id`.
    temp474-v = id.
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `type`.
    temp474-v = type.
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `connectable`.
    temp474-v = connectable.
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `title`.
    temp474-v = title.
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `showTitle`.
    temp474-v = z2ui5_cl_util=>boolean_abap_2_json( showtitle ).
    INSERT temp474 INTO TABLE temp473.
    temp474-n = `color`.
    temp474-v = color.
    INSERT temp474 INTO TABLE temp473.
    result = _generic( name   = `Task`
                       ns     = `shapes`
                       t_prop = temp473 ).
  ENDMETHOD.

  METHOD template_else.

    result = _generic( name = `else`
                       ns   = `template` ).

  ENDMETHOD.

  METHOD template_elseif.

    DATA temp475 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp476 LIKE LINE OF temp475.
    CLEAR temp475.

    temp476-n = `test`.
    temp476-v = test.
    INSERT temp476 INTO TABLE temp475.
    result = _generic( name   = `elseif`
                       ns     = `template`
                       t_prop = temp475 ).

  ENDMETHOD.

  METHOD template_if.

    DATA temp477 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp478 LIKE LINE OF temp477.
    CLEAR temp477.

    temp478-n = `test`.
    temp478-v = test.
    INSERT temp478 INTO TABLE temp477.
    result = _generic( name   = `if`
                       ns     = `template`
                       t_prop = temp477 ).

  ENDMETHOD.

  METHOD template_repeat.

    DATA temp479 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp480 LIKE LINE OF temp479.
    CLEAR temp479.

    temp480-n = `list`.
    temp480-v = list.
    INSERT temp480 INTO TABLE temp479.
    temp480-n = `var`.
    temp480-v = var.
    INSERT temp480 INTO TABLE temp479.
    result = _generic( name   = `repeat`
                       ns     = `template`
                       t_prop = temp479 ).

  ENDMETHOD.

  METHOD template_then.

    result = _generic( name = `then`
                       ns   = `template` ).

  ENDMETHOD.

  METHOD template_with.

    DATA temp481 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp482 LIKE LINE OF temp481.
    CLEAR temp481.

    temp482-n = `path`.
    temp482-v = path.
    INSERT temp482 INTO TABLE temp481.
    temp482-n = `helper`.
    temp482-v = helper.
    INSERT temp482 INTO TABLE temp481.
    temp482-n = `var`.
    temp482-v = var.
    INSERT temp482 INTO TABLE temp481.
    result = _generic( name   = `with`
                       ns     = `template`
                       t_prop = temp481 ).

  ENDMETHOD.

  METHOD text.
    DATA temp483 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp484 LIKE LINE OF temp483.
    result = me.

    CLEAR temp483.

    temp484-n = `text`.
    temp484-v = text.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `emptyIndicatorMode`.
    temp484-v = emptyindicatormode.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `maxLines`.
    temp484-v = maxlines.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `renderWhitespace`.
    temp484-v = renderwhitespace.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `textAlign`.
    temp484-v = textalign.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `visible`.
    temp484-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `textDirection`.
    temp484-v = textdirection.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `width`.
    temp484-v = width.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `id`.
    temp484-v = id.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `wrapping`.
    temp484-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `wrappingType`.
    temp484-v = wrappingtype.
    INSERT temp484 INTO TABLE temp483.
    temp484-n = `class`.
    temp484-v = class.
    INSERT temp484 INTO TABLE temp483.
    _generic( name   = `Text`
              ns     = ns
              t_prop = temp483 ).
  ENDMETHOD.

  METHOD text_area.
    DATA temp485 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp486 LIKE LINE OF temp485.
    result = me.

    CLEAR temp485.

    temp486-n = `value`.
    temp486-v = value.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `rows`.
    temp486-v = rows.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `cols`.
    temp486-v = cols.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `height`.
    temp486-v = height.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `width`.
    temp486-v = width.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `wrapping`.
    temp486-v = wrapping.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `maxLength`.
    temp486-v = maxlength.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `textAlign`.
    temp486-v = textalign.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `textDirection`.
    temp486-v = textdirection.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `showValueStateMessage`.
    temp486-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `showExceededText`.
    temp486-v = z2ui5_cl_util=>boolean_abap_2_json( showexceededtext ).
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `valueLiveUpdate`.
    temp486-v = z2ui5_cl_util=>boolean_abap_2_json( valueliveupdate ).
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `editable`.
    temp486-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `class`.
    temp486-v = class.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `enabled`.
    temp486-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `id`.
    temp486-v = id.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `growing`.
    temp486-v = z2ui5_cl_util=>boolean_abap_2_json( growing ).
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `growingMaxLines`.
    temp486-v = growingmaxlines.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `required`.
    temp486-v = required.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `valueState`.
    temp486-v = valuestate.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `placeholder`.
    temp486-v = placeholder.
    INSERT temp486 INTO TABLE temp485.
    temp486-n = `valueStateText`.
    temp486-v = valuestatetext.
    INSERT temp486 INTO TABLE temp485.
    _generic( name   = `TextArea`
              t_prop = temp485 ).
  ENDMETHOD.

  METHOD tile_content.

    DATA temp487 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp488 LIKE LINE OF temp487.
    CLEAR temp487.

    temp488-n = `unit`.
    temp488-v = unit.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `footerColor`.
    temp488-v = footercolor.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `blocked`.
    temp488-v = z2ui5_cl_util=>boolean_abap_2_json( blocked ).
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `frameType`.
    temp488-v = frametype.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `priority`.
    temp488-v = priority.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `priorityText`.
    temp488-v = prioritytext.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `state`.
    temp488-v = state.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `disabled`.
    temp488-v = z2ui5_cl_util=>boolean_abap_2_json( disabled ).
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `visible`.
    temp488-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `footer`.
    temp488-v = footer.
    INSERT temp488 INTO TABLE temp487.
    temp488-n = `class`.
    temp488-v = class.
    INSERT temp488 INTO TABLE temp487.
    result = _generic( name   = `TileContent`
                       ns     = ``
                       t_prop = temp487 ).

  ENDMETHOD.

  METHOD tile_info.
    DATA temp489 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp490 LIKE LINE OF temp489.
    CLEAR temp489.

    temp490-n = `id`.
    temp490-v = id.
    INSERT temp490 INTO TABLE temp489.
    temp490-n = `class`.
    temp490-v = class.
    INSERT temp490 INTO TABLE temp489.
    temp490-n = `backgroundColor`.
    temp490-v = backgroundcolor.
    INSERT temp490 INTO TABLE temp489.
    temp490-n = `borderColor`.
    temp490-v = bordercolor.
    INSERT temp490 INTO TABLE temp489.
    temp490-n = `src`.
    temp490-v = src.
    INSERT temp490 INTO TABLE temp489.
    temp490-n = `text`.
    temp490-v = text.
    INSERT temp490 INTO TABLE temp489.
    temp490-n = `textColor`.
    temp490-v = textcolor.
    INSERT temp490 INTO TABLE temp489.
    result = _generic( name   = `TileInfo`
                       t_prop = temp489 ).

  ENDMETHOD.

  METHOD timeline.

    DATA temp491 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp492 LIKE LINE OF temp491.
    CLEAR temp491.

    temp492-n = `id`.
    temp492-v = id.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `enableDoubleSided`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( enabledoublesided ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `groupBy`.
    temp492-v = groupby.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `growingThreshold`.
    temp492-v = growingthreshold.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `filterTitle`.
    temp492-v = filtertitle.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `sortOldestFirst`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( sortoldestfirst ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `enableModelFilter`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( enablemodelfilter ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `enableScroll`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( enablescroll ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `forceGrowing`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( forcegrowing ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `group`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( group ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `lazyLoading`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( lazyloading ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `showHeaderBar`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( showheaderbar ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `showIcons`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( showicons ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `showItemFilter`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( showitemfilter ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `showSearch`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( showsearch ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `showSort`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( showsort ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `showTimeFilter`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( showtimefilter ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `sort`.
    temp492-v = z2ui5_cl_util=>boolean_abap_2_json( sort ).
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `groupByType`.
    temp492-v = groupbytype.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `textHeight`.
    temp492-v = textheight.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `width`.
    temp492-v = width.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `height`.
    temp492-v = height.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `noDataText`.
    temp492-v = nodatatext.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `alignment`.
    temp492-v = alignment.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `axisOrientation`.
    temp492-v = axisorientation.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `filterList`.
    temp492-v = filterlist.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `customFilter`.
    temp492-v = customfilter.
    INSERT temp492 INTO TABLE temp491.
    temp492-n = `content`.
    temp492-v = content.
    INSERT temp492 INTO TABLE temp491.
    result = _generic(
        name   = `Timeline`
        ns     = `commons`
        t_prop = temp491 ).
  ENDMETHOD.

  METHOD timeline_item.

    DATA temp493 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp494 LIKE LINE OF temp493.
    CLEAR temp493.

    temp494-n = `id`.
    temp494-v = id.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `dateTime`.
    temp494-v = datetime.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `title`.
    temp494-v = title.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `userNameClickable`.
    temp494-v = z2ui5_cl_util=>boolean_abap_2_json( usernameclickable ).
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `useIconTooltip`.
    temp494-v = z2ui5_cl_util=>boolean_abap_2_json( useicontooltip ).
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `userNameClicked`.
    temp494-v = usernameclicked.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `userPicture`.
    temp494-v = userpicture.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `select`.
    temp494-v = select.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `text`.
    temp494-v = text.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `userName`.
    temp494-v = username.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `filterValue`.
    temp494-v = filtervalue.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `iconDisplayShape`.
    temp494-v = icondisplayshape.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `iconInitials`.
    temp494-v = iconinitials.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `iconSize`.
    temp494-v = iconsize.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `iconTooltip`.
    temp494-v = icontooltip.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `maxCharacters`.
    temp494-v = maxcharacters.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `replyCount`.
    temp494-v = replycount.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `status`.
    temp494-v = status.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `customActionClicked`.
    temp494-v = customactionclicked.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `press`.
    temp494-v = press.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `replyListOpen`.
    temp494-v = replylistopen.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `replyPost`.
    temp494-v = replypost.
    INSERT temp494 INTO TABLE temp493.
    temp494-n = `icon`.
    temp494-v = icon.
    INSERT temp494 INTO TABLE temp493.
    result = _generic(
        name   = `TimelineItem`
        ns     = `commons`
        t_prop = temp493 ).
  ENDMETHOD.

  METHOD time_horizon.
    DATA temp495 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp496 LIKE LINE OF temp495.
    CLEAR temp495.

    temp496-n = `startTime`.
    temp496-v = starttime.
    INSERT temp496 INTO TABLE temp495.
    temp496-n = `endTime`.
    temp496-v = endtime.
    INSERT temp496 INTO TABLE temp495.
    result = _generic( name   = `TimeHorizon`
                       ns     = `config`
                       t_prop = temp495 ).
  ENDMETHOD.

  METHOD time_picker.
    DATA temp497 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp498 LIKE LINE OF temp497.
    result = me.

    CLEAR temp497.

    temp498-n = `value`.
    temp498-v = value.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `dateValue`.
    temp498-v = datevalue.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `localeId`.
    temp498-v = localeid.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `placeholder`.
    temp498-v = placeholder.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `mask`.
    temp498-v = mask.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `maskMode`.
    temp498-v = maskmode.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `minutesStep`.
    temp498-v = minutesstep.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `name`.
    temp498-v = name.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `placeholderSymbol`.
    temp498-v = placeholdersymbol.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `secondsStep`.
    temp498-v = secondsstep.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `textAlign`.
    temp498-v = textalign.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `textDirection`.
    temp498-v = textdirection.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `title`.
    temp498-v = title.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `showCurrentTimeButton`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( showcurrenttimebutton ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `showValueStateMessage`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `support2400`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( support2400 ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `initialFocusedDateValue`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( initialfocuseddatevalue ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `hideInput`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( hideinput ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `editable`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `enabled`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `required`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `visible`.
    temp498-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `width`.
    temp498-v = width.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `valueState`.
    temp498-v = valuestate.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `valueStateText`.
    temp498-v = valuestatetext.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `displayFormat`.
    temp498-v = displayformat.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `afterValueHelpClose`.
    temp498-v = aftervaluehelpclose.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `afterValueHelpOpen`.
    temp498-v = aftervaluehelpopen.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `change`.
    temp498-v = change.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `liveChange`.
    temp498-v = livechange.
    INSERT temp498 INTO TABLE temp497.
    temp498-n = `valueFormat`.
    temp498-v = valueformat.
    INSERT temp498 INTO TABLE temp497.
    _generic( name   = `TimePicker`
              t_prop = temp497 ).
  ENDMETHOD.

  METHOD title.
    DATA temp499 TYPE string.
    DATA lv_name LIKE temp499.
    DATA temp500 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp501 LIKE LINE OF temp500.
    IF ns = `f`.
      temp499 = `title`.
    ELSE.
      temp499 = `Title`.
    ENDIF.

    lv_name = temp499.

    result = me.

    CLEAR temp500.

    temp501-n = `text`.
    temp501-v = text.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `class`.
    temp501-v = class.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `id`.
    temp501-v = id.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `wrappingType`.
    temp501-v = wrappingtype.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `textAlign`.
    temp501-v = textalign.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `textDirection`.
    temp501-v = textdirection.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `titleStyle`.
    temp501-v = titlestyle.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `width`.
    temp501-v = width.
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `wrapping`.
    temp501-v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ).
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `visible`.
    temp501-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp501 INTO TABLE temp500.
    temp501-n = `level`.
    temp501-v = level.
    INSERT temp501 INTO TABLE temp500.
    _generic( ns     = ns
              name   = lv_name
              t_prop = temp500 ).
  ENDMETHOD.

  METHOD toggle_button.
    DATA temp502 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp503 LIKE LINE OF temp502.

    result = me.

    CLEAR temp502.

    temp503-n = `press`.
    temp503-v = press.
    INSERT temp503 INTO TABLE temp502.
    temp503-n = `text`.
    temp503-v = text.
    INSERT temp503 INTO TABLE temp502.
    temp503-n = `enabled`.
    temp503-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp503 INTO TABLE temp502.
    temp503-n = `icon`.
    temp503-v = icon.
    INSERT temp503 INTO TABLE temp502.
    temp503-n = `type`.
    temp503-v = type.
    INSERT temp503 INTO TABLE temp502.
    temp503-n = `class`.
    temp503-v = class.
    INSERT temp503 INTO TABLE temp502.
    temp503-n = `pressed`.
    temp503-v = z2ui5_cl_util=>boolean_abap_2_json( pressed ).
    INSERT temp503 INTO TABLE temp502.
    _generic( name   = `ToggleButton`
              t_prop = temp502 ).
  ENDMETHOD.

  METHOD token.
    DATA temp504 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp505 LIKE LINE OF temp504.

    result = me.

    CLEAR temp504.

    temp505-n = `key`.
    temp505-v = key.
    INSERT temp505 INTO TABLE temp504.
    temp505-n = `text`.
    temp505-v = text.
    INSERT temp505 INTO TABLE temp504.
    temp505-n = `selected`.
    temp505-v = selected.
    INSERT temp505 INTO TABLE temp504.
    temp505-n = `visible`.
    temp505-v = visible.
    INSERT temp505 INTO TABLE temp504.
    temp505-n = `editable`.
    temp505-v = editable.
    INSERT temp505 INTO TABLE temp504.
    _generic( name   = `Token`
              t_prop = temp504 ).
  ENDMETHOD.

  METHOD tokens.

    result = _generic( name = `tokens`
                       ns   = ns ).

  ENDMETHOD.

  METHOD toolbar.
    DATA temp506 TYPE string.
    DATA lv_name LIKE temp506.
    DATA temp507 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp508 LIKE LINE OF temp507.
    IF ns = `table`.
      temp506 = `toolbar`.
    ELSEIF ns = `form`.
      temp506 = `toolbar`.
    ELSE.
      temp506 = `Toolbar`.
    ENDIF.

    lv_name = temp506.

    CLEAR temp507.

    temp508-n = `active`.
    temp508-v = z2ui5_cl_util=>boolean_abap_2_json( active ).
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `ariaHasPopup`.
    temp508-v = ariahaspopup.
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `design`.
    temp508-v = design.
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `enabled`.
    temp508-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `visible`.
    temp508-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `height`.
    temp508-v = height.
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `style`.
    temp508-v = style.
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `width`.
    temp508-v = width.
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `id`.
    temp508-v = id.
    INSERT temp508 INTO TABLE temp507.
    temp508-n = `press`.
    temp508-v = press.
    INSERT temp508 INTO TABLE temp507.
    result = _generic( name   = lv_name
                       ns     = ns
                       t_prop = temp507 ).

  ENDMETHOD.

  METHOD toolbar_spacer.
    DATA temp509 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp510 LIKE LINE OF temp509.

    result = me.

    CLEAR temp509.

    temp510-n = `width`.
    temp510-v = width.
    INSERT temp510 INTO TABLE temp509.
    _generic( name   = `ToolbarSpacer`
              ns     = ns
              t_prop = temp509 ).
  ENDMETHOD.

  METHOD tool_header.

    result = _generic( name = `ToolHeader`
                       ns   = `tnt` ).

  ENDMETHOD.

  METHOD tool_page.
    result = _generic( name = `ToolPage`
                       ns   = `tnt` ).
  ENDMETHOD.

  METHOD total_horizon.
    result = _generic( name = `totalHorizon`
                       ns   = `axistime` ).
  ENDMETHOD.

  METHOD tree.
    DATA temp511 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp512 LIKE LINE OF temp511.
    CLEAR temp511.

    temp512-n = `id`.
    temp512-v = id.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `items`.
    temp512-v = items.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `headerText`.
    temp512-v = headertext.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `footerText`.
    temp512-v = footertext.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `mode`.
    temp512-v = mode.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `toggleOpenState`.
    temp512-v = toggleopenstate.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `width`.
    temp512-v = width.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `selectionChange`.
    temp512-v = selectionchange.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `itemPress`.
    temp512-v = itempress.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `select`.
    temp512-v = select.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `multiSelectMode`.
    temp512-v = multiselectmode.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `noDataText`.
    temp512-v = nodatatext.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `headerLevel`.
    temp512-v = headerlevel.
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `includeItemInSelection`.
    temp512-v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ).
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `showNoData`.
    temp512-v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ).
    INSERT temp512 INTO TABLE temp511.
    temp512-n = `inset`.
    temp512-v = z2ui5_cl_util=>boolean_abap_2_json( inset ).
    INSERT temp512 INTO TABLE temp511.
    result = _generic(
                 name   = `Tree`
                 t_prop = temp511 ).

  ENDMETHOD.

  METHOD tree_column.

    DATA temp513 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp514 LIKE LINE OF temp513.
    CLEAR temp513.

    temp514-n = `label`.
    temp514-v = label.
    INSERT temp514 INTO TABLE temp513.
    temp514-n = `template`.
    temp514-v = template.
    INSERT temp514 INTO TABLE temp513.
    temp514-n = `hAlign`.
    temp514-v = halign.
    INSERT temp514 INTO TABLE temp513.
    temp514-n = `width`.
    temp514-v = width.
    INSERT temp514 INTO TABLE temp513.
    result = _generic( name   = `Column`
                       ns     = `table`
                       t_prop = temp513 ).

  ENDMETHOD.

  METHOD tree_columns.

    result = _generic( name = `columns`
                       ns   = `table` ).

  ENDMETHOD.

  METHOD tree_table.

    DATA temp515 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp516 LIKE LINE OF temp515.
    CLEAR temp515.

    temp516-n = `rows`.
    temp516-v = rows.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `selectionMode`.
    temp516-v = selectionmode.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `enableColumnReordering`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( enablecolumnreordering ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `expandFirstLevel`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( expandfirstlevel ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `columnSelect`.
    temp516-v = columnselect.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `rowSelectionChange`.
    temp516-v = rowselectionchange.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `selectionBehavior`.
    temp516-v = selectionbehavior.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `id`.
    temp516-v = id.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `alternateRowColors`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( alternaterowcolors ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `columnHeaderVisible`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( columnheadervisible ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `enableCellFilter`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( enablecellfilter ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `enableColumnFreeze`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( enablecolumnfreeze ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `enableCustomFilter`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( enablecustomfilter ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `enableSelectAll`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( enableselectall ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `showNoData`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `showOverlay`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( showoverlay ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `visible`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `columnHeaderHeight`.
    temp516-v = columnheaderheight.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `firstVisibleRow`.
    temp516-v = firstvisiblerow.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `fixedColumnCount`.
    temp516-v = fixedcolumncount.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `threshold`.
    temp516-v = threshold.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `width`.
    temp516-v = width.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `useGroupMode`.
    temp516-v = z2ui5_cl_util=>boolean_abap_2_json( usegroupmode ).
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `groupHeaderProperty`.
    temp516-v = groupheaderproperty.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `rowActionCount`.
    temp516-v = rowactioncount.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `selectedIndex`.
    temp516-v = selectedindex.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `rowHeight`.
    temp516-v = rowheight.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `fixedRowCount`.
    temp516-v = fixedrowcount.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `fixedBottomRowCount`.
    temp516-v = fixedbottomrowcount.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `minAutoRowCount`.
    temp516-v = minautorowcount.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `visibleRowCount`.
    temp516-v = visiblerowcount.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `toggleOpenState`.
    temp516-v = toggleopenstate.
    INSERT temp516 INTO TABLE temp515.
    temp516-n = `visibleRowCountMode`.
    temp516-v = visiblerowcountmode.
    INSERT temp516 INTO TABLE temp515.
    result = _generic(
                 name   = `TreeTable`
                 ns     = `table`
                 t_prop = temp515 ).

  ENDMETHOD.

  METHOD tree_template.

    result = _generic( name = `template`
                       ns   = `table` ).

  ENDMETHOD.

  METHOD tree_extension.
    result = _generic( ns   = `table`
                       name = `extension` ).
  ENDMETHOD.

  METHOD two_columns_layout.
    result = _generic( name = `TwoColumnsLayout`
                       ns   = `nglayout` ).
  ENDMETHOD.

  METHOD ui_column.
    DATA temp517 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp518 LIKE LINE OF temp517.
    CLEAR temp517.

    temp518-n = `id`.
    temp518-v = id.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `width`.
    temp518-v = width.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `showSortMenuEntry`.
    temp518-v = showsortmenuentry.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `sortProperty`.
    temp518-v = sortproperty.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `showFilterMenuEntry`.
    temp518-v = showfiltermenuentry.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `autoresizable`.
    temp518-v = z2ui5_cl_util=>boolean_abap_2_json( autoresizable ).
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `defaultFilterOperator`.
    temp518-v = defaultfilteroperator.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `filterProperty`.
    temp518-v = filterproperty.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `filterType`.
    temp518-v = filtertype.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `hAlign`.
    temp518-v = halign.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `minWidth`.
    temp518-v = minwidth.
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `resizable`.
    temp518-v = z2ui5_cl_util=>boolean_abap_2_json( resizable ).
    INSERT temp518 INTO TABLE temp517.
    temp518-n = `visible`.
    temp518-v = visible.
    INSERT temp518 INTO TABLE temp517.
    result = _generic( name   = `Column`
                       ns     = `table`
                       t_prop = temp517 ).
  ENDMETHOD.

  METHOD ui_columns.
    result = _generic( name = `columns`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD ui_custom_data.
    result = _generic( name = `customData`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD ui_extension.

    result = _generic( name = `extension`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD ui_row_action.
    result = _generic( name = `RowAction`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD ui_row_action_item.
    DATA temp519 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp520 LIKE LINE OF temp519.
    CLEAR temp519.

    temp520-n = `icon`.
    temp520-v = icon.
    INSERT temp520 INTO TABLE temp519.
    temp520-n = `text`.
    temp520-v = text.
    INSERT temp520 INTO TABLE temp519.
    temp520-n = `type`.
    temp520-v = type.
    INSERT temp520 INTO TABLE temp519.
    temp520-n = `press`.
    temp520-v = press.
    INSERT temp520 INTO TABLE temp519.
    temp520-n = `visible`.
    temp520-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp520 INTO TABLE temp519.
    result = _generic( name   = `RowActionItem`
                       ns     = `table`
                       t_prop = temp519 ).
  ENDMETHOD.

  METHOD ui_row_action_template.
    result = _generic( name = `rowActionTemplate`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD ui_table.

    DATA temp521 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp522 LIKE LINE OF temp521.
    CLEAR temp521.

    temp522-n = `rows`.
    temp522-v = rows.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `alternateRowColors`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( alternaterowcolors ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `columnHeaderVisible`.
    temp522-v = columnheadervisible.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `editable`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `class`.
    temp522-v = class.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `enableCellFilter`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( enablecellfilter ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `enableGrouping`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( enablegrouping ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `enableSelectAll`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( enableselectall ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `firstVisibleRow`.
    temp522-v = firstvisiblerow.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `fixedBottomRowCount`.
    temp522-v = fixedbottomrowcount.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `fixedColumnCount`.
    temp522-v = fixedcolumncount.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `rowActionCount`.
    temp522-v = rowactioncount.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `fixedRowCount`.
    temp522-v = fixedrowcount.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `minAutoRowCount`.
    temp522-v = minautorowcount.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `rowHeight`.
    temp522-v = rowheight.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `selectedIndex`.
    temp522-v = selectedindex.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `selectionMode`.
    temp522-v = selectionmode.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `selectionBehavior`.
    temp522-v = selectionbehavior.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `showColumnVisibilityMenu`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( showcolumnvisibilitymenu ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `showNoData`.
    temp522-v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ).
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `threshold`.
    temp522-v = threshold.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `visibleRowCount`.
    temp522-v = visiblerowcount.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `visibleRowCountMode`.
    temp522-v = visiblerowcountmode.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `footer`.
    temp522-v = footer.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `filter`.
    temp522-v = filter.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `sort`.
    temp522-v = sort.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `customFilter`.
    temp522-v = customfilter.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `id`.
    temp522-v = id.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `fl:flexibility`.
    temp522-v = flex.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `rowSelectionChange`.
    temp522-v = rowselectionchange.
    INSERT temp522 INTO TABLE temp521.
    temp522-n = `rowMode`.
    temp522-v = rowmode.
    INSERT temp522 INTO TABLE temp521.
    result = _generic(
        name   = `Table`
        ns     = `table`
        t_prop = temp521 ).

  ENDMETHOD.

  METHOD ui_template.

    result = _generic( name = `template`
                       ns   = `table` ).

  ENDMETHOD.

  METHOD upload_set.
    DATA temp523 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp524 LIKE LINE OF temp523.
    CLEAR temp523.

    temp524-n = `id`.
    temp524-v = id.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `instantUpload`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( instantupload ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `showIcons`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( showicons ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `uploadEnabled`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( uploadenabled ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `terminationEnabled`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( terminationenabled ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `uploadButtonInvisible`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( uploadbuttoninvisible ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `fileTypes`.
    temp524-v = filetypes.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `maxFileNameLength`.
    temp524-v = maxfilenamelength.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `maxFileSize`.
    temp524-v = maxfilesize.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `mediaTypes`.
    temp524-v = mediatypes.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `items`.
    temp524-v = items.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `uploadUrl`.
    temp524-v = uploadurl.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `mode`.
    temp524-v = mode.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `fileRenamed`.
    temp524-v = filerenamed.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `directory`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( directory ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `multiple`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( multiple ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `dragDropDescription`.
    temp524-v = dragdropdescription.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `dragDropText`.
    temp524-v = dragdroptext.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `noDataText`.
    temp524-v = nodatatext.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `noDataDescription`.
    temp524-v = nodatadescription.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `noDataIllustrationType`.
    temp524-v = nodataillustrationtype.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `afterItemEdited`.
    temp524-v = afteritemedited.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `afterItemRemoved`.
    temp524-v = afteritemremoved.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `beforeItemAdded`.
    temp524-v = beforeitemadded.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `beforeItemEdited`.
    temp524-v = beforeitemedited.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `beforeItemRemoved`.
    temp524-v = beforeitemremoved.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `beforeUploadStarts`.
    temp524-v = beforeuploadstarts.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `beforeUploadTermination`.
    temp524-v = beforeuploadtermination.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `fileNameLengthExceeded`.
    temp524-v = filenamelengthexceeded.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `fileSizeExceeded`.
    temp524-v = filesizeexceeded.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `fileTypeMismatch`.
    temp524-v = filetypemismatch.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `itemDragStart`.
    temp524-v = itemdragstart.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `itemDrop`.
    temp524-v = itemdrop.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `mediaTypeMismatch`.
    temp524-v = mediatypemismatch.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `uploadTerminated`.
    temp524-v = uploadterminated.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `uploadCompleted`.
    temp524-v = uploadcompleted.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `afterItemAdded`.
    temp524-v = afteritemadded.
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `sameFilenameAllowed`.
    temp524-v = z2ui5_cl_util=>boolean_abap_2_json( samefilenameallowed ).
    INSERT temp524 INTO TABLE temp523.
    temp524-n = `selectionChanged`.
    temp524-v = selectionchanged.
    INSERT temp524 INTO TABLE temp523.
    result = _generic(
                 name   = `UploadSet`
                 ns     = `upload`
                 t_prop = temp523 ).
  ENDMETHOD.

  METHOD upload_set_item.
    DATA temp525 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp526 LIKE LINE OF temp525.
    CLEAR temp525.

    temp526-n = `fileName`.
    temp526-v = filename.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `mediaType`.
    temp526-v = mediatype.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `url`.
    temp526-v = url.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `thumbnailUrl`.
    temp526-v = thumbnailurl.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `markers`.
    temp526-v = markers.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `enabledEdit`.
    temp526-v = z2ui5_cl_util=>boolean_abap_2_json( enablededit ).
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `enabledRemove`.
    temp526-v = z2ui5_cl_util=>boolean_abap_2_json( enabledremove ).
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `selected`.
    temp526-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `visibleEdit`.
    temp526-v = z2ui5_cl_util=>boolean_abap_2_json( visibleedit ).
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `visibleRemove`.
    temp526-v = z2ui5_cl_util=>boolean_abap_2_json( visibleremove ).
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `uploadState`.
    temp526-v = uploadstate.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `uploadUrl`.
    temp526-v = uploadurl.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `openPressed`.
    temp526-v = openpressed.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `removePressed`.
    temp526-v = removepressed.
    INSERT temp526 INTO TABLE temp525.
    temp526-n = `statuses`.
    temp526-v = statuses.
    INSERT temp526 INTO TABLE temp525.
    result = _generic( name   = `UploadSetItem`
                       ns     = `upload`
                       t_prop = temp525 ).
  ENDMETHOD.

  METHOD upload_set_toolbar_placeholder.
    result = _generic( name = `UploadSetToolbarPlaceholder`
                       ns   = `upload` ).
  ENDMETHOD.

  METHOD variant_item.

    DATA temp527 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp528 LIKE LINE OF temp527.
    CLEAR temp527.

    temp528-n = `executeOnSelection`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( executeonselection ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `global`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( global ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `labelReadOnly`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( labelreadonly ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `lifecyclePackage`.
    temp528-v = lifecyclepackage.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `lifecycleTransportId`.
    temp528-v = lifecycletransportid.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `namespace`.
    temp528-v = namespace.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `readOnly`.
    temp528-v = readonly.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `executeOnSelect`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( executeonselect ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `author`.
    temp528-v = author.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `changeable`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( changeable ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `enabled`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `favorite`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( favorite ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `key`.
    temp528-v = key.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `text`.
    temp528-v = text.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `title`.
    temp528-v = title.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `textDirection`.
    temp528-v = textdirection.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `originalTitle`.
    temp528-v = originaltitle.
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `originalExecuteOnSelect`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( originalexecuteonselect ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `remove`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( remove ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `rename`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( rename ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `originalFavorite`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( originalfavorite ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `sharing`.
    temp528-v = z2ui5_cl_util=>boolean_abap_2_json( sharing ).
    INSERT temp528 INTO TABLE temp527.
    temp528-n = `change`.
    temp528-v = change.
    INSERT temp528 INTO TABLE temp527.
    result = _generic(
                 name   = `VariantItem`
                 ns     = `vm`
                 t_prop = temp527 ).

  ENDMETHOD.

  METHOD variant_items.

    result = _generic( name = `variantItems`
                       ns   = `vm` ).

  ENDMETHOD.

  METHOD variant_item_sapm.
    DATA temp529 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp530 LIKE LINE OF temp529.
    CLEAR temp529.

    temp530-n = `id`.
    temp530-v = id.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `author`.
    temp530-v = author.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `changeable`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( changeable ).
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `enabled`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `favorite`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( favorite ).
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `remove`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( remove ).
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `rename`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( rename ).
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `visible`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `contexts`.
    temp530-v = contexts.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `key`.
    temp530-v = key.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `sharing`.
    temp530-v = sharing.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `text`.
    temp530-v = text.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `textDirection`.
    temp530-v = textdirection.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `title`.
    temp530-v = title.
    INSERT temp530 INTO TABLE temp529.
    temp530-n = `executeOnSelect`.
    temp530-v = z2ui5_cl_util=>boolean_abap_2_json( executeonselect ).
    INSERT temp530 INTO TABLE temp529.
    result = _generic(
        name   = `VariantItem`
        t_prop = temp529 ).
  ENDMETHOD.

  METHOD variant_management.

    DATA temp531 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp532 LIKE LINE OF temp531.
    CLEAR temp531.

    temp532-n = `defaultVariantKey`.
    temp532-v = defaultvariantkey.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `enabled`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `inErrorState`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( inerrorstate ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `initialSelectionKey`.
    temp532-v = initialselectionkey.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `lifecycleSupport`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( lifecyclesupport ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `selectionKey`.
    temp532-v = selectionkey.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `showCreateTile`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( showcreatetile ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `showExecuteOnSelection`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( showexecuteonselection ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `showSetAsDefault`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( showsetasdefault ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `showShare`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( showshare ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `standardItemAuthor`.
    temp532-v = standarditemauthor.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `standardItemText`.
    temp532-v = standarditemtext.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `useFavorites`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( usefavorites ).
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `variantItems`.
    temp532-v = variantitems.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `manage`.
    temp532-v = manage.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `save`.
    temp532-v = save.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `select`.
    temp532-v = select.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `id`.
    temp532-v = id.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `variantCreationByUserAllowed`.
    temp532-v = uservarcreate.
    INSERT temp532 INTO TABLE temp531.
    temp532-n = `visible`.
    temp532-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp532 INTO TABLE temp531.
    result = _generic(
                 name   = `VariantManagement`
                 ns     = `vm`
                 t_prop = temp531 ).

  ENDMETHOD.

  METHOD variant_management_fl.
    DATA temp533 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp534 LIKE LINE OF temp533.
    CLEAR temp533.

    temp534-n = `displayTextForExecuteOnSelectionForStandardVariant`.
    temp534-v = displaytextfsv.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `editable`.
    temp534-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `executeOnSelectionForStandardDefault`.
    temp534-v = z2ui5_cl_util=>boolean_abap_2_json( executeonselectionforstandflt ).
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `headerLevel`.
    temp534-v = headerlevel.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `inErrorState`.
    temp534-v = z2ui5_cl_util=>boolean_abap_2_json( inerrorstate ).
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `maxWidth`.
    temp534-v = maxwidth.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `modelName`.
    temp534-v = modelname.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `resetOnContextChange`.
    temp534-v = z2ui5_cl_util=>boolean_abap_2_json( resetoncontextchange ).
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `showSetAsDefault`.
    temp534-v = z2ui5_cl_util=>boolean_abap_2_json( showsetasdefault ).
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `titleStyle`.
    temp534-v = titlestyle.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `updateVariantInURL`.
    temp534-v = z2ui5_cl_util=>boolean_abap_2_json( updatevariantinurl ).
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `cancel`.
    temp534-v = cancel.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `initialized`.
    temp534-v = initialized.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `manage`.
    temp534-v = manage.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `save`.
    temp534-v = save.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `select`.
    temp534-v = select.
    INSERT temp534 INTO TABLE temp533.
    temp534-n = `for`.
    temp534-v = for.
    INSERT temp534 INTO TABLE temp533.
    result = _generic(
                 name   = `VariantManagement`
                 ns     = `flvm`
                 t_prop = temp533 ).
  ENDMETHOD.

  METHOD variant_management_sapm.
    DATA temp535 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp536 LIKE LINE OF temp535.
    CLEAR temp535.

    temp536-n = `id`.
    temp536-v = id.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `defaultKey`.
    temp536-v = defaultkey.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `level`.
    temp536-v = level.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `maxWidth`.
    temp536-v = maxwidth.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `popoverTitle`.
    temp536-v = popovertitle.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `selectedKey`.
    temp536-v = selectedkey.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `titleStyle`.
    temp536-v = titlestyle.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `cancel`.
    temp536-v = cancel.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `manage`.
    temp536-v = manage.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `manageCancel`.
    temp536-v = managecancel.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `save`.
    temp536-v = save.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `select`.
    temp536-v = select.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `items`.
    temp536-v = items.
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `creationAllowed`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( creationallowed ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `inErrorState`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( inerrorstate ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `modified`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( modified ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `showFooter`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `showSaveAs`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( showsaveas ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `supportApplyAutomatically`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( supportapplyautomatically ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `supportContexts`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( supportcontexts ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `supportDefault`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( supportdefault ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `supportFavorites`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( supportfavorites ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `supportPublic`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( supportpublic ).
    INSERT temp536 INTO TABLE temp535.
    temp536-n = `visible`.
    temp536-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp536 INTO TABLE temp535.
    result = _generic(
        name   = `VariantManagement`
        t_prop = temp535 ).

  ENDMETHOD.

  METHOD vbox.

    DATA temp537 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp538 LIKE LINE OF temp537.
    CLEAR temp537.

    temp538-n = `height`.
    temp538-v = height.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `id`.
    temp538-v = id.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `justifyContent`.
    temp538-v = justifycontent.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `renderType`.
    temp538-v = rendertype.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `alignContent`.
    temp538-v = aligncontent.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `alignItems`.
    temp538-v = alignitems.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `width`.
    temp538-v = width.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `wrap`.
    temp538-v = wrap.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `backgroundDesign`.
    temp538-v = backgrounddesign.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `direction`.
    temp538-v = direction.
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `displayInline`.
    temp538-v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ).
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `visible`.
    temp538-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `fitContainer`.
    temp538-v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ).
    INSERT temp538 INTO TABLE temp537.
    temp538-n = `class`.
    temp538-v = class.
    INSERT temp538 INTO TABLE temp537.
    result = _generic(
        name   = `VBox`
        t_prop = temp537 ).

  ENDMETHOD.

  METHOD vertical_layout.

    DATA temp539 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp540 LIKE LINE OF temp539.
    CLEAR temp539.

    temp540-n = `id`.
    temp540-v = id.
    INSERT temp540 INTO TABLE temp539.
    temp540-n = `visible`.
    temp540-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp540 INTO TABLE temp539.
    temp540-n = `enabled`.
    temp540-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp540 INTO TABLE temp539.
    temp540-n = `class`.
    temp540-v = class.
    INSERT temp540 INTO TABLE temp539.
    temp540-n = `width`.
    temp540-v = width.
    INSERT temp540 INTO TABLE temp539.
    result = _generic( name   = `VerticalLayout`
                       ns     = `layout`
                       t_prop = temp539 ).
  ENDMETHOD.

  METHOD view_settings_dialog.

    DATA temp541 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp542 LIKE LINE OF temp541.
    CLEAR temp541.

    temp542-n = `confirm`.
    temp542-v = confirm.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `cancel`.
    temp542-v = cancel.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `filterDetailPageOpened`.
    temp542-v = filterdetailpageopened.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `reset`.
    temp542-v = reset.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `resetFilters`.
    temp542-v = resetfilters.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `filterSearchOperator`.
    temp542-v = filtersearchoperator.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `groupDescending`.
    temp542-v = z2ui5_cl_util=>boolean_abap_2_json( groupdescending ).
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `sortDescending`.
    temp542-v = z2ui5_cl_util=>boolean_abap_2_json( sortdescending ).
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `title`.
    temp542-v = title.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `selectedGroupItem`.
    temp542-v = selectedgroupitem.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `selectedPresetFilterItem`.
    temp542-v = selectedpresetfilteritem.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `selectedSortItem`.
    temp542-v = selectedsortitem.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `selectedSortItem`.
    temp542-v = selectedsortitem.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `filterItems`.
    temp542-v = filteritems.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `sortItems`.
    temp542-v = sortitems.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `groupItems`.
    temp542-v = groupitems.
    INSERT temp542 INTO TABLE temp541.
    temp542-n = `titleAlignment`.
    temp542-v = titlealignment.
    INSERT temp542 INTO TABLE temp541.
    result = _generic( name   = `ViewSettingsDialog`
                       t_prop = temp541 ).

  ENDMETHOD.

  METHOD view_settings_filter_item.
    DATA temp543 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp544 LIKE LINE OF temp543.
    CLEAR temp543.

    temp544-n = `enabled`.
    temp544-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp544 INTO TABLE temp543.
    temp544-n = `key`.
    temp544-v = key.
    INSERT temp544 INTO TABLE temp543.
    temp544-n = `selected`.
    temp544-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp544 INTO TABLE temp543.
    temp544-n = `text`.
    temp544-v = text.
    INSERT temp544 INTO TABLE temp543.
    temp544-n = `textDirection`.
    temp544-v = textdirection.
    INSERT temp544 INTO TABLE temp543.
    temp544-n = `multiSelect`.
    temp544-v = z2ui5_cl_util=>boolean_abap_2_json( multiselect ).
    INSERT temp544 INTO TABLE temp543.
    result = _generic(
                 name   = `ViewSettingsFilterItem`
                 t_prop = temp543 ).
  ENDMETHOD.

  METHOD view_settings_item.
    DATA temp545 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp546 LIKE LINE OF temp545.
    CLEAR temp545.

    temp546-n = `enabled`.
    temp546-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp546 INTO TABLE temp545.
    temp546-n = `key`.
    temp546-v = key.
    INSERT temp546 INTO TABLE temp545.
    temp546-n = `selected`.
    temp546-v = z2ui5_cl_util=>boolean_abap_2_json( selected ).
    INSERT temp546 INTO TABLE temp545.
    temp546-n = `text`.
    temp546-v = text.
    INSERT temp546 INTO TABLE temp545.
    temp546-n = `textDirection`.
    temp546-v = textdirection.
    INSERT temp546 INTO TABLE temp545.
    result = _generic( name   = `ViewSettingsItem`
                       t_prop = temp545 ).

  ENDMETHOD.

  METHOD visible_horizon.
    result = _generic( name = `visibleHorizon`
                       ns   = `axistime` ).
  ENDMETHOD.

  METHOD vos.

    result = _generic( name = `vos`
                       ns   = `vbm` ).

  ENDMETHOD.

  METHOD wizard.
    DATA temp547 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp548 LIKE LINE OF temp547.
    CLEAR temp547.

    temp548-n = `id`.
    temp548-v = id.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `class`.
    temp548-v = class.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `backgroundDesign`.
    temp548-v = backgrounddesign.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `busy`.
    temp548-v = z2ui5_cl_util=>boolean_abap_2_json( busy ).
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `busyIndicatorDelay`.
    temp548-v = busyindicatordelay.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `busyIndicatorSize`.
    temp548-v = busyindicatorsize.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `enableBranching`.
    temp548-v = z2ui5_cl_util=>boolean_abap_2_json( enablebranching ).
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `fieldGroupIds`.
    temp548-v = fieldgroupids.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `finishButtonText`.
    temp548-v = finishbuttontext.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `height`.
    temp548-v = height.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `renderMode`.
    temp548-v = rendermode.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `showNextButton`.
    temp548-v = z2ui5_cl_util=>boolean_abap_2_json( shownextbutton ).
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `stepTitleLevel`.
    temp548-v = steptitlelevel.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `visible`.
    temp548-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `width`.
    temp548-v = width.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `complete`.
    temp548-v = complete.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `navigationChange`.
    temp548-v = navigationchange.
    INSERT temp548 INTO TABLE temp547.
    temp548-n = `stepActivate`.
    temp548-v = stepactivate.
    INSERT temp548 INTO TABLE temp547.
    result = _generic( name   = `Wizard`
                       t_prop = temp547 ).

  ENDMETHOD.

  METHOD wizard_step.

    DATA temp549 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp550 LIKE LINE OF temp549.
    CLEAR temp549.

    temp550-n = `id`.
    temp550-v = id.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `busy`.
    temp550-v = z2ui5_cl_util=>boolean_abap_2_json( busy ).
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `busyIndicatorDelay`.
    temp550-v = busyindicatordelay.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `busyIndicatorSize`.
    temp550-v = busyindicatorsize.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `fieldGroupIds`.
    temp550-v = fieldgroupids.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `icon`.
    temp550-v = icon.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `optional`.
    temp550-v = z2ui5_cl_util=>boolean_abap_2_json( optional ).
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `title`.
    temp550-v = title.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `validated`.
    temp550-v = z2ui5_cl_util=>boolean_abap_2_json( validated ).
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `visible`.
    temp550-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `activate`.
    temp550-v = activate.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `complete`.
    temp550-v = complete.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `nextStep`.
    temp550-v = nextstep.
    INSERT temp550 INTO TABLE temp549.
    temp550-n = `subsequentSteps`.
    temp550-v = subsequentsteps.
    INSERT temp550 INTO TABLE temp549.
    result = _generic( name   = `WizardStep`
                       t_prop = temp549 ).
  ENDMETHOD.

  METHOD xml_get.

    DATA lt_parts TYPE string_table.
    xml_get_parts( CHANGING ct_parts = lt_parts ).
    result = concat_lines_of( lt_parts ).

  ENDMETHOD.


  METHOD xml_get_parts.

    DATA lt_prop TYPE HASHED TABLE OF z2ui5_if_types=>ty_s_name_value WITH UNIQUE KEY n.
        DATA temp551 LIKE LINE OF mt_prop.
        DATA temp552 LIKE sy-tabix.
      DATA temp553 LIKE lt_prop.
      DATA temp554 LIKE LINE OF temp553.
      DATA temp555 LIKE LINE OF mt_ns.
      DATA lr_ns LIKE REF TO temp555.
            DATA ls_prop LIKE LINE OF lt_prop.
            DATA temp81 LIKE LINE OF lt_prop.
            DATA temp82 LIKE sy-tabix.
            DATA temp556 TYPE z2ui5_if_types=>ty_s_name_value.
    DATA temp557 TYPE string.
    DATA lv_tmp2 LIKE temp557.
    DATA temp558 TYPE string.
    DATA val TYPE string.
    DATA row LIKE LINE OF mt_prop.
      DATA temp83 TYPE string.
    DATA lv_tmp3 LIKE temp558.
      DATA temp559 LIKE LINE OF ct_parts.
    DATA temp560 LIKE LINE OF ct_parts.
    DATA lr_child LIKE LINE OF mt_child.
      DATA temp561 TYPE REF TO z2ui5_cl_xml_view.
    DATA temp562 LIKE LINE OF ct_parts.

    CASE mv_name.
      WHEN `ZZPLAIN`.


        temp552 = sy-tabix.
        READ TABLE mt_prop WITH KEY n = `VALUE` INTO temp551.
        sy-tabix = temp552.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        APPEND temp551-v TO ct_parts.
        RETURN.
      WHEN OTHERS.
    ENDCASE.

    IF me = mo_root.


      CLEAR temp553.

      temp554-n = `z2ui5`.
      temp554-v = `z2ui5.cc`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `layout`.
      temp554-v = `sap.ui.layout`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `networkgraph`.
      temp554-v = `sap.suite.ui.commons.networkgraph`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `nglayout`.
      temp554-v = `sap.suite.ui.commons.networkgraph.layout`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `ngcustom`.
      temp554-v = `sap.suite.ui.commons.sample.NetworkGraphCustomRendering`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `table`.
      temp554-v = `sap.ui.table`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `template`.
      temp554-v = `http://schemas.sap.com/sapui5/extension/sap.ui.core.template/1`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `customData`.
      temp554-v = `http://schemas.sap.com/sapui5/extension/sap.ui.core.CustomData/1`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `f`.
      temp554-v = `sap.f`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `columnmenu`.
      temp554-v = `sap.m.table.columnmenu`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `card`.
      temp554-v = `sap.f.cards`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `dnd`.
      temp554-v = `sap.ui.core.dnd`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `dnd-grid`.
      temp554-v = `sap.f.dnd`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `grid`.
      temp554-v = `sap.ui.layout.cssgrid`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `form`.
      temp554-v = `sap.ui.layout.form`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `editor`.
      temp554-v = `sap.ui.codeeditor`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `mchart`.
      temp554-v = `sap.suite.ui.microchart`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `smartFilterBar`.
      temp554-v = `sap.ui.comp.smartfilterbar`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `smartVariantManagement`.
      temp554-v = `sap.ui.comp.smartvariants`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `smartTable`.
      temp554-v = `sap.ui.comp.smarttable`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `webc`.
      temp554-v = `sap.ui.webc.main`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `uxap`.
      temp554-v = `sap.uxap`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `sap`.
      temp554-v = `sap`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `text`.
      temp554-v = `sap.ui.richtexteditor`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `html`.
      temp554-v = `http://www.w3.org/1999/xhtml`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `fb`.
      temp554-v = `sap.ui.comp.filterbar`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `u`.
      temp554-v = `sap.ui.unified`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `gantt`.
      temp554-v = `sap.gantt.simple`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `axistime`.
      temp554-v = `sap.gantt.axistime`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `config`.
      temp554-v = `sap.gantt.config`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `shapes`.
      temp554-v = `sap.gantt.simple.shapes`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `commons`.
      temp554-v = `sap.suite.ui.commons`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `si`.
      temp554-v = `sap.suite.ui.commons.statusindicator`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `vm`.
      temp554-v = `sap.ui.comp.variants`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `viz`.
      temp554-v = `sap.viz.ui5.controls`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `viz.data`.
      temp554-v = `sap.viz.ui5.data`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `viz.feeds`.
      temp554-v = `sap.viz.ui5.controls.common.feeds`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `vk`.
      temp554-v = `sap.ui.vk`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `vbm`.
      temp554-v = `sap.ui.vbm`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `ndc`.
      temp554-v = `sap.ndc`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `svm`.
      temp554-v = `sap.ui.comp.smartvariants`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `flvm`.
      temp554-v = `sap.ui.fl.variants`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `p13n`.
      temp554-v = `sap.m.p13n`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `upload`.
      temp554-v = `sap.m.upload`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `fl`.
      temp554-v = `sap.ui.fl`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `plugins`.
      temp554-v = `sap.m.plugins`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `tnt`.
      temp554-v = `sap.tnt`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `mdc`.
      temp554-v = `sap.ui.mdc`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `trm`.
      temp554-v = `sap.ui.table.rowmodes`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `smi`.
      temp554-v = `sap.ui.comp.smartmultiinput`.
      INSERT temp554 INTO TABLE temp553.
      temp554-n = `ie`.
      temp554-v = `sap.suite.ui.commons.imageeditor`.
      INSERT temp554 INTO TABLE temp553.
      lt_prop = temp553.



      LOOP AT mt_ns REFERENCE INTO lr_ns WHERE table_line IS NOT INITIAL  "#EC CI_SORTSEQ
                                                     AND table_line <> `mvc`
                                                     AND table_line <> `core`.
        TRY.



            temp82 = sy-tabix.
            READ TABLE lt_prop WITH KEY n = lr_ns->* INTO temp81.
            sy-tabix = temp82.
            IF sy-subrc <> 0.
              ASSERT 1 = 0.
            ENDIF.
            ls_prop = temp81.

            CLEAR temp556.
            temp556-n = |xmlns:{ ls_prop-n }|.
            temp556-v = ls_prop-v.
            INSERT temp556 INTO TABLE mt_prop.
          CATCH cx_root.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING val = |XML_VIEW_ERROR_NO_NAMESPACE_FOUND_FOR:  { lr_ns->* }|.
        ENDTRY.
      ENDLOOP.

    ENDIF.


    IF mv_ns <> ``.
      temp557 = |{ mv_ns }:|.
    ELSE.
      CLEAR temp557.
    ENDIF.

    lv_tmp2 = temp557.


    val = ``.

    LOOP AT mt_prop INTO row WHERE v <> ``.

      IF row-v = abap_true.
        temp83 = `true`.
      ELSE.
        temp83 = row-v.
      ENDIF.
      val = |{ val } { row-n }="{ escape( val = temp83 format = cl_abap_format=>e_xml_attr ) }"|.
    ENDLOOP.
    temp558 = val.

    lv_tmp3 = temp558.

    IF mt_child IS INITIAL.

      temp559 = | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }/>|.
      APPEND temp559 TO ct_parts.
      RETURN.
    ENDIF.


    temp560 = | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }>|.
    APPEND temp560 TO ct_parts.


    LOOP AT mt_child INTO lr_child.

      temp561 ?= lr_child.
      temp561->xml_get_parts( CHANGING ct_parts = ct_parts ).
    ENDLOOP.


    temp562 = |</{ lv_tmp2 }{ mv_name }>|.
    APPEND temp562 TO ct_parts.

  ENDMETHOD.

  METHOD _cc_plain_xml.
    DATA temp563 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp564 LIKE LINE OF temp563.

    result = me.

    CLEAR temp563.

    temp564-n = `VALUE`.
    temp564-v = val.
    INSERT temp564 INTO TABLE temp563.
    _generic( name   = `ZZPLAIN`
                ns   = 'html'
              t_prop = temp563 ).

  ENDMETHOD.

  METHOD _generic.
        DATA temp565 TYPE string.
    DATA result2 TYPE REF TO z2ui5_cl_xml_view.

    TRY.

        temp565 = ns.
        INSERT temp565 INTO TABLE mo_root->mt_ns.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    CREATE OBJECT result2 TYPE z2ui5_cl_xml_view.
    result2->mv_name   = name.
    result2->mv_ns     = ns.
    result2->mt_prop   = t_prop.
    result2->mo_parent = me.
    result2->mo_root   = mo_root.
    INSERT result2 INTO TABLE mt_child.

    mo_root->mo_previous = result2.
    result = result2.

  ENDMETHOD.

  METHOD _generic_property.

    INSERT val INTO TABLE mt_prop.
    result = me.

  ENDMETHOD.

  METHOD _z2ui5.

    CREATE OBJECT result EXPORTING VIEW = me.

  ENDMETHOD.

  METHOD p_cell_selector.
    DATA temp566 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp567 LIKE LINE OF temp566.

    result = me.

    CLEAR temp566.

    temp567-n = `id`.
    temp567-v = id.
    INSERT temp567 INTO TABLE temp566.
    _generic( name   = `CellSelector`
              ns     = `plugins`
              t_prop = temp566 ).

  ENDMETHOD.

  METHOD p_copy_provider.
    DATA temp568 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp569 LIKE LINE OF temp568.

    result = me.

    CLEAR temp568.

    temp569-n = `id`.
    temp569-v = id.
    INSERT temp569 INTO TABLE temp568.
    temp569-n = `copy`.
    temp569-v = copy.
    INSERT temp569 INTO TABLE temp568.
    temp569-n = `extractData`.
    temp569-v = extract_data.
    INSERT temp569 INTO TABLE temp568.
    _generic( name   = `CopyProvider`
              ns     = `plugins`
              t_prop = temp568 ).

  ENDMETHOD.

  METHOD date_range_selection.
    DATA temp570 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp571 LIKE LINE OF temp570.
    result = me.

    CLEAR temp570.

    temp571-n = `value`.
    temp571-v = value.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `displayFormat`.
    temp571-v = displayformat.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `displayFormatType`.
    temp571-v = displayformattype.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `valueFormat`.
    temp571-v = valueformat.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `required`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `valueState`.
    temp571-v = valuestate.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `valueStateText`.
    temp571-v = valuestatetext.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `placeholder`.
    temp571-v = placeholder.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `textAlign`.
    temp571-v = textalign.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `textDirection`.
    temp571-v = textdirection.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `change`.
    temp571-v = change.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `maxDate`.
    temp571-v = maxdate.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `minDate`.
    temp571-v = mindate.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `width`.
    temp571-v = width.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `id`.
    temp571-v = id.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `dateValue`.
    temp571-v = datevalue.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `secondDateValue`.
    temp571-v = seconddatevalue.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `name`.
    temp571-v = name.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `class`.
    temp571-v = class.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `calendarWeekNumbering`.
    temp571-v = calendarweeknumbering.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `initialFocusedDateValue`.
    temp571-v = initialfocuseddatevalue.
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `enabled`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `visible`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `editable`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `hideInput`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( hideinput ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `showFooter`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `showValueStateMessage`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `showCurrentDateButton`.
    temp571-v = z2ui5_cl_util=>boolean_abap_2_json( showcurrentdatebutton ).
    INSERT temp571 INTO TABLE temp570.
    temp571-n = `delimiter`.
    temp571-v = delimiter.
    INSERT temp571 INTO TABLE temp570.
    _generic( name   = `DateRangeSelection`
              t_prop = temp570 ).
  ENDMETHOD.

  METHOD toolbar_layout_data.
    DATA temp572 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp573 LIKE LINE OF temp572.
    CLEAR temp572.

    temp573-n = `id`.
    temp573-v = id.
    INSERT temp573 INTO TABLE temp572.
    temp573-n = `maxWidth`.
    temp573-v = maxwidth.
    INSERT temp573 INTO TABLE temp572.
    temp573-n = `minWidth`.
    temp573-v = minwidth.
    INSERT temp573 INTO TABLE temp572.
    temp573-n = `shrinkable`.
    temp573-v = z2ui5_cl_util=>boolean_abap_2_json( shrinkable ).
    INSERT temp573 INTO TABLE temp572.
    result = _generic(
                 name   = `ToolbarLayoutData`
                 t_prop = temp572 ).
  ENDMETHOD.

  METHOD feed_content.
    DATA temp574 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp575 LIKE LINE OF temp574.
    CLEAR temp574.

    temp575-n = `contentText`.
    temp575-v = contenttext.
    INSERT temp575 INTO TABLE temp574.
    temp575-n = `subheader`.
    temp575-v = subheader.
    INSERT temp575 INTO TABLE temp574.
    temp575-n = `value`.
    temp575-v = value.
    INSERT temp575 INTO TABLE temp574.
    temp575-n = `class`.
    temp575-v = class.
    INSERT temp575 INTO TABLE temp574.
    temp575-n = `press`.
    temp575-v = press.
    INSERT temp575 INTO TABLE temp574.
    result = _generic( name   = `FeedContent`
                       t_prop = temp574 ).

  ENDMETHOD.

  METHOD news_content.
    DATA temp576 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp577 LIKE LINE OF temp576.
    CLEAR temp576.

    temp577-n = `contentText`.
    temp577-v = contenttext.
    INSERT temp577 INTO TABLE temp576.
    temp577-n = `subheader`.
    temp577-v = subheader.
    INSERT temp577 INTO TABLE temp576.
    temp577-n = `press`.
    temp577-v = press.
    INSERT temp577 INTO TABLE temp576.
    result = _generic( name   = `NewsContent`
                       t_prop = temp576 ).

  ENDMETHOD.

  METHOD splitter.
    DATA temp578 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp579 LIKE LINE OF temp578.
    CLEAR temp578.

    temp579-n = `height`.
    temp579-v = height.
    INSERT temp579 INTO TABLE temp578.
    temp579-n = `orientation`.
    temp579-v = orientation.
    INSERT temp579 INTO TABLE temp578.
    temp579-n = `width`.
    temp579-v = width.
    INSERT temp579 INTO TABLE temp578.
    result = _generic( name   = `Splitter`
                       ns     = `layout`
                       t_prop = temp578 ).
  ENDMETHOD.

  METHOD invisible_text.
    DATA temp580 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp581 LIKE LINE OF temp580.
    CLEAR temp580.

    temp581-n = `id`.
    temp581-v = id.
    INSERT temp581 INTO TABLE temp580.
    temp581-n = `text`.
    temp581-v = text.
    INSERT temp581 INTO TABLE temp580.
    result = _generic( ns     = ns
                       name   = `InvisibleText`
                       t_prop = temp580 ).
  ENDMETHOD.

  METHOD fix_content.
    result = _generic( ns   = ns
                       name = `fixContent` ).
  ENDMETHOD.

  METHOD fix_flex.

    DATA temp582 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp583 LIKE LINE OF temp582.
    CLEAR temp582.

    temp583-n = `class`.
    temp583-v = class.
    INSERT temp583 INTO TABLE temp582.
    temp583-n = `fixContentSize`.
    temp583-v = fixcontentsize.
    INSERT temp583 INTO TABLE temp582.
    result = _generic( ns     = ns
                       name   = `FixFlex`
                       t_prop = temp582 ).
  ENDMETHOD.

  METHOD flex_content.
    result = _generic( ns   = ns
                       name = `flexContent` ).
  ENDMETHOD.

  METHOD side_navigation.

    DATA temp584 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp585 LIKE LINE OF temp584.
    CLEAR temp584.

    temp585-n = `id`.
    temp585-v = id.
    INSERT temp585 INTO TABLE temp584.
    temp585-n = `class`.
    temp585-v = class.
    INSERT temp585 INTO TABLE temp584.
    temp585-n = `selectedKey`.
    temp585-v = selectedkey.
    INSERT temp585 INTO TABLE temp584.
    result = _generic( name   = `SideNavigation`
                       ns     = `tnt`
                       t_prop = temp584 ).

  ENDMETHOD.

  METHOD navigation_list.

    result = _generic( name = `NavigationList`
                       ns   = `tnt` ).

  ENDMETHOD.

  METHOD navigation_list_item.
    DATA temp586 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp587 LIKE LINE OF temp586.

    result = me.

    CLEAR temp586.

    temp587-n = `text`.
    temp587-v = text.
    INSERT temp587 INTO TABLE temp586.
    temp587-n = `icon`.
    temp587-v = icon.
    INSERT temp587 INTO TABLE temp586.
    temp587-n = `href`.
    temp587-v = href.
    INSERT temp587 INTO TABLE temp586.
    temp587-n = `key`.
    temp587-v = key.
    INSERT temp587 INTO TABLE temp586.
    temp587-n = `select`.
    temp587-v = select.
    INSERT temp587 INTO TABLE temp586.
    _generic( name   = `NavigationListItem`
              ns     = `tnt`
              t_prop = temp586 ).

  ENDMETHOD.

  METHOD fixed_item.

    result = _generic( name = `fixedItem`
                       ns   = `tnt` ).

  ENDMETHOD.

  METHOD content_areas.
    result = _generic( name = `contentAreas`
                       ns   = ns ).
  ENDMETHOD.

  METHOD field.
    DATA temp588 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp589 LIKE LINE OF temp588.
    CLEAR temp588.

    temp589-n = `id`.
    temp589-v = id.
    INSERT temp589 INTO TABLE temp588.
    temp589-n = `value`.
    temp589-v = value.
    INSERT temp589 INTO TABLE temp588.
    temp589-n = `editMode`.
    temp589-v = editmode.
    INSERT temp589 INTO TABLE temp588.
    temp589-n = `showEmptyIndicator`.
    temp589-v = z2ui5_cl_util=>boolean_abap_2_json( showemptyindicator ).
    INSERT temp589 INTO TABLE temp588.
    result = _generic(
        name   = `Field`
        ns     = ns
        t_prop = temp588 ).
  ENDMETHOD.

  METHOD color_picker.
    DATA temp590 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp591 LIKE LINE OF temp590.

    result = me.

    CLEAR temp590.

    temp591-n = `colorString`.
    temp591-v = colorstring.
    INSERT temp591 INTO TABLE temp590.
    temp591-n = `displayMode`.
    temp591-v = displaymode.
    INSERT temp591 INTO TABLE temp590.
    temp591-n = `change`.
    temp591-v = change.
    INSERT temp591 INTO TABLE temp590.
    temp591-n = `liveChange`.
    temp591-v = livechange.
    INSERT temp591 INTO TABLE temp590.
    _generic( ns     = `u`
              name   = `ColorPicker`
              t_prop = temp590 ).

  ENDMETHOD.

  METHOD tiles.
    result = _generic( `tiles` ).
  ENDMETHOD.

  METHOD analytical_column.
    result = _generic( ns   = ns
                       name = `AnalyticalColumn` ).
  ENDMETHOD.

  METHOD analytical_table.
    DATA temp592 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp593 LIKE LINE OF temp592.
    CLEAR temp592.

    temp593-n = `selectionMode`.
    temp593-v = selectionmode.
    INSERT temp593 INTO TABLE temp592.
    temp593-n = `rowMode`.
    temp593-v = rowmode.
    INSERT temp593 INTO TABLE temp592.
    temp593-n = `toolbar`.
    temp593-v = toolbar.
    INSERT temp593 INTO TABLE temp592.
    temp593-n = `columns`.
    temp593-v = columns.
    INSERT temp593 INTO TABLE temp592.
    result = _generic( name   = `AnalyticalTable`
                       ns     = ns
                       t_prop = temp592 ).
  ENDMETHOD.

  METHOD auto.
    DATA temp594 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp595 LIKE LINE OF temp594.
    CLEAR temp594.

    temp595-n = `rowContentHeight`.
    temp595-v = rowcontentheight.
    INSERT temp595 INTO TABLE temp594.
    result = _generic( ns     = ns
                       name   = `Auto`
                       t_prop = temp594 ).
  ENDMETHOD.

  METHOD rowmode.
    result = _generic( name = `rowMode`
                       ns   = ns ).
  ENDMETHOD.

  METHOD breadcrumbs.
    DATA temp596 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp597 LIKE LINE OF temp596.
    CLEAR temp596.

    temp597-n = `link`.
    temp597-v = link.
    INSERT temp597 INTO TABLE temp596.
    temp597-n = `id`.
    temp597-v = id.
    INSERT temp597 INTO TABLE temp596.
    temp597-n = `class`.
    temp597-v = class.
    INSERT temp597 INTO TABLE temp596.
    temp597-n = `currentLocationText`.
    temp597-v = currentlocationtext.
    INSERT temp597 INTO TABLE temp596.
    temp597-n = `separatorStyle`.
    temp597-v = separatorstyle.
    INSERT temp597 INTO TABLE temp596.
    temp597-n = `visible`.
    temp597-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp597 INTO TABLE temp596.
    result = _generic(
        ns     = ns
        name   = `Breadcrumbs`
        t_prop = temp596 ).
  ENDMETHOD.

  METHOD current_location.
    DATA temp598 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp599 LIKE LINE OF temp598.
    CLEAR temp598.

    temp599-n = `link`.
    temp599-v = link.
    INSERT temp599 INTO TABLE temp598.
    result = _generic( ns     = ns
                       name   = `currentLocation`
                       t_prop = temp598 ).
  ENDMETHOD.

  METHOD color_palette.
    DATA temp600 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp601 LIKE LINE OF temp600.
    CLEAR temp600.

    temp601-n = `colorSelect`.
    temp601-v = colorselect.
    INSERT temp601 INTO TABLE temp600.
    result = _generic( ns     = ns
                       name   = `ColorPalette`
                       t_prop = temp600 ).
  ENDMETHOD.

  METHOD harveyballmicrochartitem.

    DATA temp602 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp603 LIKE LINE OF temp602.
    CLEAR temp602.

    temp603-n = `id`.
    temp603-v = id.
    INSERT temp603 INTO TABLE temp602.
    temp603-n = `class`.
    temp603-v = class.
    INSERT temp603 INTO TABLE temp602.
    temp603-n = `fraction`.
    temp603-v = fraction.
    INSERT temp603 INTO TABLE temp602.
    temp603-n = `color`.
    temp603-v = color.
    INSERT temp603 INTO TABLE temp602.
    temp603-n = `fractionScale`.
    temp603-v = fractionscale.
    INSERT temp603 INTO TABLE temp602.
    result = _generic( name   = `HarveyBallMicroChartItem`
                       ns     = `mchart`
                       t_prop = temp602 ).
  ENDMETHOD.

  METHOD smart_filter_bar.

    DATA temp604 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp605 LIKE LINE OF temp604.
    CLEAR temp604.

    temp605-n = `id`.
    temp605-v = id.
    INSERT temp605 INTO TABLE temp604.
    temp605-n = `entitySet`.
    temp605-v = entityset.
    INSERT temp605 INTO TABLE temp604.
    temp605-n = `persistencyKey`.
    temp605-v = persistencykey.
    INSERT temp605 INTO TABLE temp604.
    result = _generic( name   = `SmartFilterBar`
                       ns     = `smartFilterBar`
                       t_prop = temp604 ).

  ENDMETHOD.

  METHOD control_configuration.
    DATA temp606 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp607 LIKE LINE OF temp606.

    result = me.

    CLEAR temp606.

    temp607-n = `id`.
    temp607-v = id.
    INSERT temp607 INTO TABLE temp606.
    temp607-n = `key`.
    temp607-v = key.
    INSERT temp607 INTO TABLE temp606.
    temp607-n = `visibleInAdvancedArea`.
    temp607-v = z2ui5_cl_util=>boolean_abap_2_json( visibleinadvancedarea ).
    INSERT temp607 INTO TABLE temp606.
    temp607-n = `preventInitialDataFetchInValueHelpDialog`.
    temp607-v = z2ui5_cl_util=>boolean_abap_2_json( previnitdatafetchinvalhelpdia ).
    INSERT temp607 INTO TABLE temp606.
    _generic( name   = `ControlConfiguration`
              ns     = `smartFilterBar`
              t_prop = temp606 ).

  ENDMETHOD.

  METHOD smart_table.

    DATA temp608 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp609 LIKE LINE OF temp608.
    CLEAR temp608.

    temp609-n = `id`.
    temp609-v = id.
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `smartFilterId`.
    temp609-v = smartfilterid.
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `tableType`.
    temp609-v = tabletype.
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `editable`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `initiallyVisibleFields`.
    temp609-v = initiallyvisiblefields.
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `entitySet`.
    temp609-v = entityset.
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `useVariantManagement`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( usevariantmanagement ).
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `useExportToExcel`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( useexporttoexcel ).
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `useTablePersonalisation`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( usetablepersonalisation ).
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `header`.
    temp609-v = header.
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `showRowCount`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( showrowcount ).
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `enableExport`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( enableexport ).
    INSERT temp609 INTO TABLE temp608.
    temp609-n = `enableAutoBinding`.
    temp609-v = z2ui5_cl_util=>boolean_abap_2_json( enableautobinding ).
    INSERT temp609 INTO TABLE temp608.
    result = _generic(
        name   = `SmartTable`
        ns     = `smartTable`
        t_prop = temp608 ).

  ENDMETHOD.

  METHOD _control_configuration.

    result = _generic( name = `controlConfiguration`
                       ns   = `smartFilterBar` ).

  ENDMETHOD.

  METHOD viz_dataset.
    result = _generic( name = `dataset`
                       ns   = `viz` ).
  ENDMETHOD.

  METHOD viz_dimensions.
    result = _generic( name = `dimensions`
                       ns   = `viz.data` ).
  ENDMETHOD.

  METHOD viz_dimension_definition.
    DATA temp610 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp611 LIKE LINE OF temp610.
    CLEAR temp610.

    temp611-n = `axis`.
    temp611-v = axis.
    INSERT temp611 INTO TABLE temp610.
    temp611-n = `dataType`.
    temp611-v = datatype.
    INSERT temp611 INTO TABLE temp610.
    temp611-n = `displayValue`.
    temp611-v = displayvalue.
    INSERT temp611 INTO TABLE temp610.
    temp611-n = `identity`.
    temp611-v = identity.
    INSERT temp611 INTO TABLE temp610.
    temp611-n = `name`.
    temp611-v = name.
    INSERT temp611 INTO TABLE temp610.
    temp611-n = `sorter`.
    temp611-v = sorter.
    INSERT temp611 INTO TABLE temp610.
    temp611-n = `value`.
    temp611-v = value.
    INSERT temp611 INTO TABLE temp610.
    result = _generic( name   = `DimensionDefinition`
                       ns     = `viz.data`
                       t_prop = temp610 ).
  ENDMETHOD.

  METHOD viz_feeds.
    result = _generic( name = `feeds`
                       ns   = `viz` ).
  ENDMETHOD.

  METHOD viz_feed_item.
    DATA temp612 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp613 LIKE LINE OF temp612.
    CLEAR temp612.

    temp613-n = `id`.
    temp613-v = id.
    INSERT temp613 INTO TABLE temp612.
    temp613-n = `uid`.
    temp613-v = uid.
    INSERT temp613 INTO TABLE temp612.
    temp613-n = `type`.
    temp613-v = type.
    INSERT temp613 INTO TABLE temp612.
    temp613-n = `values`.
    temp613-v = values.
    INSERT temp613 INTO TABLE temp612.
    result = _generic( name   = `FeedItem`
                       ns     = `viz.feeds`
                       t_prop = temp612 ).
  ENDMETHOD.

  METHOD viz_flattened_dataset.
    DATA temp614 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp615 LIKE LINE OF temp614.
    CLEAR temp614.

    temp615-n = `data`.
    temp615-v = data.
    INSERT temp615 INTO TABLE temp614.
    result = _generic( name   = `FlattenedDataset`
                       ns     = `viz.data`
                       t_prop = temp614 ).
  ENDMETHOD.

  METHOD viz_frame.
    DATA lv_vizproperties TYPE string.
    DATA temp616 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp617 LIKE LINE OF temp616.
    lv_vizproperties = ``.
    IF vizproperties IS INITIAL.
      lv_vizproperties = |\{| && |\n| &&
        |"plotArea": \{| && |\n| &&
          |"dataLabel": \{| && |\n| &&
              |"formatString": "",| && |\n| &&
              |"visible": false| && |\n| &&
          |\}| && |\n| &&
        |\},| && |\n| &&
        |"valueAxis": \{| && |\n| &&
          |"label": \{| && |\n| &&
              |"formatString": ""| && |\n| &&
          |\},| && |\n| &&
          |"title": \{| && |\n| &&
              |"visible": false| && |\n| &&
          |\}| && |\n| &&
        |\},| && |\n| &&
        |"categoryAxis": \{| && |\n| &&
          |"title": \{| && |\n| &&
              |"visible": false| && |\n| &&
          |\}| && |\n| &&
        |\},| && |\n| &&
        |"title": \{| && |\n| &&
          |"visible": false,| && |\n| &&
          |"text": ""| && |\n| &&
        |\}| && |\n| &&
        |\}|.
    ELSE.
      lv_vizproperties = vizproperties.
    ENDIF.


    CLEAR temp616.

    temp617-n = `id`.
    temp617-v = id.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `legendVisible`.
    temp617-v = legendvisible.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `vizCustomizations`.
    temp617-v = vizcustomizations.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `vizProperties`.
    temp617-v = lv_vizproperties.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `vizScales`.
    temp617-v = vizscales.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `vizType`.
    temp617-v = viztype.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `height`.
    temp617-v = height.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `width`.
    temp617-v = width.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `uiConfig`.
    temp617-v = uiconfig.
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `visible`.
    temp617-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp617 INTO TABLE temp616.
    temp617-n = `selectData`.
    temp617-v = selectdata.
    INSERT temp617 INTO TABLE temp616.
    result = _generic( name   = `VizFrame`
                       ns     = `viz`
                       t_prop = temp616 ).

  ENDMETHOD.

  METHOD viz_measures.
    result = _generic( name = `measures`
                       ns   = `viz.data` ).
  ENDMETHOD.

  METHOD viz_measure_definition.
    DATA temp618 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp619 LIKE LINE OF temp618.
    CLEAR temp618.

    temp619-n = `format`.
    temp619-v = format.
    INSERT temp619 INTO TABLE temp618.
    temp619-n = `group`.
    temp619-v = group.
    INSERT temp619 INTO TABLE temp618.
    temp619-n = `identity`.
    temp619-v = identity.
    INSERT temp619 INTO TABLE temp618.
    temp619-n = `name`.
    temp619-v = name.
    INSERT temp619 INTO TABLE temp618.
    temp619-n = `range`.
    temp619-v = range.
    INSERT temp619 INTO TABLE temp618.
    temp619-n = `unit`.
    temp619-v = unit.
    INSERT temp619 INTO TABLE temp618.
    temp619-n = `value`.
    temp619-v = value.
    INSERT temp619 INTO TABLE temp618.
    result = _generic( name   = `MeasureDefinition`
                       ns     = `viz.data`
                       t_prop = temp618 ).
  ENDMETHOD.

  METHOD smart_multi_input.

    DATA temp620 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp621 LIKE LINE OF temp620.
    CLEAR temp620.

    temp621-n = `id`.
    temp621-v = id.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `value`.
    temp621-v = value.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `entitySet`.
    temp621-v = entityset.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `supportRanges`.
    temp621-v = supportranges.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `enableODataSelect`.
    temp621-v = enableodataselect.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `requestAtLeastFields`.
    temp621-v = requestatleastfields.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `singleTokenMode`.
    temp621-v = singletokenmode.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `supportMultiSelect`.
    temp621-v = supportmultiselect.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `textSeparator`.
    temp621-v = textseparator.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `textLabel`.
    temp621-v = textlabel.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `tooltipLabel`.
    temp621-v = tooltiplabel.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `textInEditModeSource`.
    temp621-v = textineditmodesource.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `mandatory`.
    temp621-v = mandatory.
    INSERT temp621 INTO TABLE temp620.
    temp621-n = `maxLength`.
    temp621-v = maxlength.
    INSERT temp621 INTO TABLE temp620.
    result = _generic( name   = `SmartMultiInput`
                       ns     = `smi`
                       t_prop = temp620 ).

  ENDMETHOD.

  METHOD overflow_toolbar_layout_data.

    DATA temp622 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp623 LIKE LINE OF temp622.
    CLEAR temp622.

    temp623-n = `closeOverflowOnInteraction`.
    temp623-v = z2ui5_cl_util=>boolean_abap_2_json( closeoverflowoninteraction ).
    INSERT temp623 INTO TABLE temp622.
    temp623-n = `group`.
    temp623-v = group.
    INSERT temp623 INTO TABLE temp622.
    temp623-n = `priority`.
    temp623-v = priority.
    INSERT temp623 INTO TABLE temp622.
    result = _generic(
        name   = `OverflowToolbarLayoutData`
        t_prop = temp622 ).

  ENDMETHOD.

  METHOD row_settings.
    DATA temp624 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp625 LIKE LINE OF temp624.
    CLEAR temp624.

    temp625-n = `highlight`.
    temp625-v = highlight.
    INSERT temp625 INTO TABLE temp624.
    temp625-n = `highlightText`.
    temp625-v = highlighttext.
    INSERT temp625 INTO TABLE temp624.
    temp625-n = `navigated`.
    temp625-v = z2ui5_cl_util=>boolean_abap_2_json( navigated ).
    INSERT temp625 INTO TABLE temp624.
    result = _generic(
                 name   = `RowSettings`
                 ns     = `table`
                 t_prop = temp624 ).
  ENDMETHOD.

  METHOD image_editor.
    DATA temp626 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp627 LIKE LINE OF temp626.
    CLEAR temp626.

    temp627-n = `id`.
    temp627-v = id.
    INSERT temp627 INTO TABLE temp626.
    temp627-n = `customShapeSrc`.
    temp627-v = customshapesrc.
    INSERT temp627 INTO TABLE temp626.
    temp627-n = `keepCropAspectRatio`.
    temp627-v = z2ui5_cl_util=>boolean_abap_2_json( keepcropaspectratio ).
    INSERT temp627 INTO TABLE temp626.
    temp627-n = `keepResizeAspectRatio`.
    temp627-v = z2ui5_cl_util=>boolean_abap_2_json( keepresizeaspectratio ).
    INSERT temp627 INTO TABLE temp626.
    temp627-n = `scaleCropArea`.
    temp627-v = scalecroparea.
    INSERT temp627 INTO TABLE temp626.
    temp627-n = `customShapeSrcType`.
    temp627-v = customshapesrctype.
    INSERT temp627 INTO TABLE temp626.
    temp627-n = `src`.
    temp627-v = src.
    INSERT temp627 INTO TABLE temp626.
    result = _generic(
                 name   = `ImageEditor`
                 ns     = `ie`
                 t_prop = temp626 ).
  ENDMETHOD.

  METHOD image_editor_container.
    DATA temp628 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp629 LIKE LINE OF temp628.
    CLEAR temp628.

    temp629-n = `id`.
    temp629-v = id.
    INSERT temp629 INTO TABLE temp628.
    temp629-n = `enabledButtons`.
    temp629-v = enabledbuttons.
    INSERT temp629 INTO TABLE temp628.
    temp629-n = `mode`.
    temp629-v = mode.
    INSERT temp629 INTO TABLE temp628.
    result = _generic( name   = `ImageEditorContainer`
                       ns     = `ie`
                       t_prop = temp628 ).
  ENDMETHOD.

ENDCLASS.
