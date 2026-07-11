"! <p class="shorttext synchronized" lang="en">abap2UI5 - view parser</p>
"!
"! Builder for SAPUI5 XML views. See CLAUDE.md and the project README for usage.
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
    "! See https://ui5.sap.com/#/api/sap.m.IllustratedMessage. Since 1.98.
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
        footertext          TYPE clike OPTIONAL
        multiselectmode     TYPE clike OPTIONAL
        rememberselections  TYPE clike OPTIONAL
        keyboardmode        TYPE clike OPTIONAL
        contextualwidth     TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.AnalyticalTable</p>
    "!
    "! Grid table with built-in OData v2 grouping and aggregation. See https://ui5.sap.com/#/api/sap.ui.table.AnalyticalTable. DEPRECATED as of 2.0 - replaced by the OData V4 Table Building Block.
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
    "! See https://ui5.sap.com/#/api/sap.ui.table.rowmodes.Auto. Used inside `rowMode` of sap.ui.table.Table / AnalyticalTable. Since 1.119.
    "!
    "! @parameter ns                  | (string) XML namespace prefix (typically `t`).
    "! @parameter rowcontentheight    | (int) Row content height in pixels. 0 = theme-based default. Default: 0.
    "! @parameter minrowcount         | (int) Minimum number of displayed rows. Default: 5.
    "! @parameter maxrowcount         | (int) Maximum number of displayed rows (-1 = no limit). Default: -1.
    "! @parameter fixedtoprowcount    | (int) Number of fixed rows at the top. Default: 0.
    "! @parameter fixedbottomrowcount | (int) Number of fixed rows at the bottom. Default: 0.
    METHODS auto
      IMPORTING
        ns                  TYPE clike OPTIONAL
        rowcontentheight    TYPE clike OPTIONAL
        minrowcount         TYPE clike OPTIONAL
        maxrowcount         TYPE clike OPTIONAL
        fixedtoprowcount    TYPE clike OPTIONAL
        fixedbottomrowcount TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.rowmodes.Fixed</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.rowmodes.Fixed. Used inside `rowMode` of sap.ui.table.Table / AnalyticalTable. Since 1.119.
    "!
    "! @parameter ns                  | (string) XML namespace prefix (typically `t`).
    "! @parameter rowcount            | (int) Number of displayed rows. Default: 10.
    "! @parameter rowcontentheight    | (int) Row content height in pixels. 0 = theme-based default. Default: 0.
    "! @parameter fixedtoprowcount    | (int) Number of fixed rows at the top. Default: 0.
    "! @parameter fixedbottomrowcount | (int) Number of fixed rows at the bottom. Default: 0.
    METHODS fixed
      IMPORTING
        ns                  TYPE clike OPTIONAL
        rowcount            TYPE clike OPTIONAL
        rowcontentheight    TYPE clike OPTIONAL
        fixedtoprowcount    TYPE clike OPTIONAL
        fixedbottomrowcount TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.ui.table.rowmodes.Interactive</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.ui.table.rowmodes.Interactive. Used inside `rowMode` of sap.ui.table.Table / AnalyticalTable. Since 1.119.
    "!
    "! @parameter ns                  | (string) XML namespace prefix (typically `t`).
    "! @parameter rowcount            | (int) Initial number of displayed rows. Default: 10.
    "! @parameter minrowcount         | (int) Minimum number of displayed rows. Default: 5.
    "! @parameter maxrowcount         | (int) Maximum number of displayed rows (-1 = no limit). Default: -1.
    "! @parameter rowcontentheight    | (int) Row content height in pixels. 0 = theme-based default. Default: 0.
    "! @parameter fixedtoprowcount    | (int) Number of fixed rows at the top. Default: 0.
    "! @parameter fixedbottomrowcount | (int) Number of fixed rows at the bottom. Default: 0.
    METHODS interactive
      IMPORTING
        ns                  TYPE clike OPTIONAL
        rowcount            TYPE clike OPTIONAL
        minrowcount         TYPE clike OPTIONAL
        maxrowcount         TYPE clike OPTIONAL
        rowcontentheight    TYPE clike OPTIONAL
        fixedtoprowcount    TYPE clike OPTIONAL
        fixedbottomrowcount TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.ProductSwitch</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.ProductSwitch. Since 1.72. Rendered with `ns='f'`.
    "!
    "! @parameter id     | (string) Stable control id.
    "! @parameter change | (event) Fired when an item is selected.
    METHODS product_switch
      IMPORTING
        id            TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.ProductSwitchItem</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.ProductSwitchItem. Since 1.72. Rendered with `ns='f'`.
    "!
    "! @parameter id        | (string) Stable control id.
    "! @parameter src       | (sap.ui.core.URI) Icon/image source.
    "! @parameter imagesrc  | (sap.ui.core.URI) Image source; takes precedence over `src`. Since 1.140.
    "! @parameter title     | (string) Title text.
    "! @parameter subtitle  | (string) Subtitle text.
    "! @parameter target    | (string) Browsing context of the link.
    "! @parameter targetsrc | (sap.ui.core.URI) Link target URI.
    METHODS product_switch_item
      IMPORTING
        id            TYPE clike OPTIONAL
        src           TYPE clike OPTIONAL
        imagesrc      TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        subtitle      TYPE clike OPTIONAL
        target        TYPE clike OPTIONAL
        targetsrc     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridContainer</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.GridContainer. Since 1.65. Rendered with `ns='f'`. Items are added to the default `items` aggregation; column sizing goes into the `layout` aggregation via `grid_container_settings`.
    "!
    "! @parameter id                | (string) Stable control id.
    "! @parameter width             | (sap.ui.core.CSSSize) Width of the control.
    "! @parameter minheight         | (sap.ui.core.CSSSize) Minimum height. Default: 2rem.
    "! @parameter containerquery    | (boolean) Base breakpoints on the container width instead of the device. Default: false.
    "! @parameter snaptorow         | (boolean) Snap items to rows. Default: false.
    "! @parameter allowdensefill    | (boolean) Increase item density by reordering. Default: false.
    "! @parameter inlineblocklayout | (boolean) One-dimensional layout with fixed row height. Default: false.
    "! @parameter layoutchange      | (event) Fired when the currently active layout changes.
    "! @parameter columnschange     | (event) Fired when the number of columns changes.
    "! @parameter borderreached     | (event) Fired when keyboard navigation reaches a border.
    METHODS grid_container
      IMPORTING
        id                TYPE clike OPTIONAL
        width             TYPE clike OPTIONAL
        minheight         TYPE clike OPTIONAL
        containerquery    TYPE clike OPTIONAL
        snaptorow         TYPE clike OPTIONAL
        allowdensefill    TYPE clike OPTIONAL
        inlineblocklayout TYPE clike OPTIONAL
        layoutchange      TYPE clike OPTIONAL
        columnschange     TYPE clike OPTIONAL
        borderreached     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.f.GridContainerSettings</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.f.GridContainerSettings. Since 1.65. Rendered with `ns='f'`, used inside the `layout` aggregation of `grid_container`. Use only `px` or `rem`.
    "!
    "! @parameter columns       | (int) Number of columns.
    "! @parameter columnsize    | (sap.ui.core.CSSSize) Width of the columns. Default: 80px.
    "! @parameter mincolumnsize | (sap.ui.core.CSSSize) Minimum column width.
    "! @parameter maxcolumnsize | (sap.ui.core.CSSSize) Maximum column width.
    "! @parameter rowsize       | (sap.ui.core.CSSSize) Height of the rows. Default: 80px.
    "! @parameter gap           | (sap.ui.core.CSSSize) Gap between rows and columns. Default: 16px.
    METHODS grid_container_settings
      IMPORTING
        columns       TYPE clike OPTIONAL
        columnsize    TYPE clike OPTIONAL
        mincolumnsize TYPE clike OPTIONAL
        maxcolumnsize TYPE clike OPTIONAL
        rowsize       TYPE clike OPTIONAL
        gap           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">Aggregation `layout`</p>
    "!
    "! @parameter ns | (string) XML namespace prefix.
    METHODS layout
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    "! <p class="shorttext synchronized" lang="en">sap.m.DynamicDateRange</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.DynamicDateRange. Since 1.92.
    "!
    "! @parameter id                 | (string) Stable control id.
    "! @parameter value              | (object) Current value; typically set via data binding.
    "! @parameter width              | (sap.ui.core.CSSSize) Width of the control.
    "! @parameter enabled            | (boolean) Whether the control is enabled. Default: true.
    "! @parameter editable           | (boolean) Whether the control is editable. Default: true.
    "! @parameter required           | (boolean) Whether the field is required. Default: false.
    "! @parameter name               | (string) Form submit name.
    "! @parameter placeholder        | (string) Placeholder text.
    "! @parameter valuestate         | (sap.ui.core.ValueState) None | Error | Warning | Success | Information. Default: None.
    "! @parameter valuestatetext     | (string) Text shown for the value state.
    "! @parameter enablegroupheaders | (boolean) Group the options in the value help. Default: true.
    "! @parameter hideinput          | (boolean) Hide the input field (icon-only). Default: false.
    "! @parameter showclearicon      | (boolean) Show the clear icon. Default: false. Since 1.97.
    "! @parameter change             | (event) Fired when the value changes.
    METHODS dynamic_date_range
      IMPORTING
        id                 TYPE clike OPTIONAL
        value              TYPE clike OPTIONAL
        width              TYPE clike OPTIONAL
        enabled            TYPE clike OPTIONAL
        editable           TYPE clike OPTIONAL
        required           TYPE clike OPTIONAL
        name               TYPE clike OPTIONAL
        placeholder        TYPE clike OPTIONAL
        valuestate         TYPE clike OPTIONAL
        valuestatetext     TYPE clike OPTIONAL
        enablegroupheaders TYPE clike OPTIONAL
        hideinput          TYPE clike OPTIONAL
        showclearicon      TYPE clike OPTIONAL
        change             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

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
    "! Avatar control. See https://ui5.sap.com/#/api/sap.m.Avatar. Since 1.73.
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
    "! Avatar group rendered with `ns='f'`. See https://ui5.sap.com/#/api/sap.f.AvatarGroup. Since 1.73.
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
    "! See https://ui5.sap.com/#/api/sap.f.AvatarGroupItem. Since 1.73.
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
    "! Top-level shell/navigation bar. See https://ui5.sap.com/#/api/sap.f.ShellBar. Since 1.63.
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
        name                          TYPE clike OPTIONAL
        textalign                     TYPE clike OPTIONAL
        textdirection                 TYPE clike OPTIONAL
        showvaluestatemessage         TYPE clike OPTIONAL
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
    "! See https://ui5.sap.com/#/api/sap.ui.table.AnalyticalColumn. Use the `column` builder for sap.m and `analytical_column` for AnalyticalTable. DEPRECATED as of 2.0 - replaced by the OData V4 Table Building Block.
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
    "! See https://ui5.sap.com/#/api/sap.ndc.BarcodeScannerButton. Since 1.102.
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

    "! <p class="shorttext synchronized" lang="en">sap.m.Menu</p>
    "!
    "! See https://ui5.sap.com/#/api/sap.m.Menu. Since 1.38. Hierarchical menu; the items are `sap.m.MenuItem`. Opened as a popover via `client->popover_display( by_id = ... )`.
    "!
    "! @parameter id           | (string) Stable control id.
    "! @parameter title        | (string) Menu title.
    "! @parameter itemselected | (event) Fired when a `MenuItem` is selected.
    "! @parameter closed       | (event) Fired when the menu is closed.
    METHODS menu
      IMPORTING
        id            TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        itemselected  TYPE clike OPTIONAL
        closed        TYPE clike OPTIONAL
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
    "! Badge-style status tag. See https://ui5.sap.com/#/api/sap.m.GenericTag. Since 1.62.
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
        name          TYPE clike OPTIONAL
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
        class            TYPE clike OPTIONAL
        percentvalue     TYPE clike OPTIONAL
        displayvalue     TYPE clike OPTIONAL
        showvalue        TYPE clike OPTIONAL
        state            TYPE clike OPTIONAL
        visible          TYPE clike OPTIONAL
        width            TYPE clike OPTIONAL
        height           TYPE clike OPTIONAL
        enabled          TYPE clike OPTIONAL
        displayonly      TYPE clike OPTIONAL
        displayanimation TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

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
    "! Note: sap.ui.comp is superseded by sap.ui.mdc, which SAP recommends for new developments (this wrapper remains fully supported).
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
    "! Note: sap.ui.comp is superseded by sap.ui.mdc, which SAP recommends for new developments (this wrapper remains fully supported).
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
        unit                TYPE clike OPTIONAL
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
    "! See https://ui5.sap.com/#/api/sap.f.SidePanel. Since 1.107.
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
    "! See https://ui5.sap.com/#/api/sap.f.SidePanelItem. Since 1.107.
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
    "! @parameter showcurrentdatebutton   | (boolean) Show "Today" button. Default: false. Since 1.95.
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
    "! Note: sap.ui.comp is superseded by sap.ui.mdc, which SAP recommends for new developments (this wrapper remains fully supported).
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
    "! Note: sap.ui.comp is superseded by sap.ui.mdc, which SAP recommends for new developments (this wrapper remains fully supported).
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
    "! Note: sap.ui.comp is superseded by sap.ui.mdc, which SAP recommends for new developments (this wrapper remains fully supported).
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
    "! See https://ui5.sap.com/#/api/sap.m.ActionSheet. DEPRECATED as of 1.149 - use sap.m.Menu / sap.m.MenuItem instead.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.Menu. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.Item. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.ActionItem. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickAction. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickActionItem. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickGroup. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickGroupItem. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickSort. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickSortItem. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickTotal. Since 1.110.
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
    "! See https://ui5.sap.com/#/api/sap.m.table.columnmenu.QuickTotalItem. Since 1.110.
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
    "! Note: sap.ui.comp is superseded by sap.ui.mdc, which SAP recommends for new developments (this wrapper remains fully supported).
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
    DATA mt_child    TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view WITH EMPTY KEY.

    "! <p class="shorttext synchronized" lang="en">Internal recursion that flattens the XML tree into a stri...</p>
    "!
    "! @parameter ct_parts | Output - serialised XML fragments.
    METHODS xml_get_parts
      CHANGING
        ct_parts TYPE string_table.

  PRIVATE SECTION.
    CLASS-DATA st_ns_map TYPE HASHED TABLE OF z2ui5_if_types=>ty_s_name_value WITH UNIQUE KEY n.
ENDCLASS.


CLASS z2ui5_cl_xml_view IMPLEMENTATION.

  METHOD actions.
    result = _generic( name = `actions`
                       ns   = ns ).
  ENDMETHOD.

  METHOD action_button.
    result = _generic( name   = `ActionButton`
                       ns     = `networkgraph`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `icon`     v = icon )
                                         ( n = `position` v = position )
                                         ( n = `title`    v = title )
                                         ( n = `press`    v = press )
                                         ( n = `enabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) ) ) ).
  ENDMETHOD.

  METHOD action_buttons.
    result = _generic( name = `actionButtons`
                       ns   = SWITCH #( ns WHEN `` THEN `networkgraph` ELSE ns ) ).
  ENDMETHOD.

  METHOD action_sheet.
    result = _generic(
                 name   = `ActionSheet`
                 t_prop = VALUE #( ( n = `id`  v = id )
                                   ( n = `class`  v = class )
                                   ( n = `cancelButtonText`  v = cancelbuttontext )
                                   ( n = `placement`         v = placement )
                                   ( n = `showCancelButton`  v = showcancelbutton )
                                   ( n = `title`             v = title )
                                   ( n = `afterClose`        v = afterclose )
                                   ( n = `afterOpen`         v = afteropen )
                                   ( n = `beforeClose`       v = beforeclose )
                                   ( n = `beforeOpen`        v = beforeopen )
                                   ( n = `cancelButtonPress` v = cancelbuttonpress )
                                   ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD additional_content.
    result = _generic( `additionalContent` ).
  ENDMETHOD.

  METHOD additional_numbers.
    result = _generic( `additionalNumbers` ).
  ENDMETHOD.

  METHOD analytic_map.

    result = _generic( name   = `AnalyticMap`
                       ns     = `vbm`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `initialPosition`  v = initialposition )
                                         ( n = `lassoSelection`  v = lassoselection )
                                         ( n = `height`  v = height )
                                         ( n = `visible`  v = visible )
                                         ( n = `width`  v = width )
                                         ( n = `initialZoom`  v = initialzoom ) ) ).

  ENDMETHOD.

  METHOD appointments.
    result = _generic( `appointments` ).
  ENDMETHOD.

  METHOD appointment_items.
    result = _generic( `appointmentItems` ).
  ENDMETHOD.

  METHOD area_micro_chart.
    result = me.
    _generic( name   = `AreaMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `colorPalette`  v = colorpalette )
                                ( n = `press`       v = press )
                                ( n = `size`        v = size )
                                ( n = `height`      v = height )
                                ( n = `maxXValue`      v = maxxvalue )
                                ( n = `maxYValue`      v = maxyvalue )
                                ( n = `minXValue`      v = minxvalue )
                                ( n = `minYValue`      v = minyvalue )
                                ( n = `view`      v = view )
                                ( n = `alignContent`      v = aligncontent )
                                ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showLabel`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showlabel ) )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.

  METHOD attributes.
    result = _generic( name = `attributes`
                       ns   = SWITCH #( ns WHEN `` THEN `networkgraph` ELSE ns ) ).
  ENDMETHOD.

  METHOD avatar.
    result = me.
    _generic( name   = `Avatar`
              ns     = ns
              t_prop = VALUE #( ( n = `id` v = id )
                                ( n = `src`         v = src )
                                ( n = `class`       v = class )
                                ( n = `ariaHasPopup`       v = ariahaspopup )
                                ( n = `backgroundColor`       v = backgroundcolor )
                                ( n = `badgeIcon`       v = badgeicon )
                                ( n = `badgeTooltip`       v = badgetooltip )
                                ( n = `badgeValueState`       v = badgevaluestate )
                                ( n = `customDisplaySize`       v = customdisplaysize )
                                ( n = `customFontSize`       v = customfontsize )
                                ( n = `displayShape`       v = displayshape )
                                ( n = `fallbackIcon`       v = fallbackicon )
                                ( n = `imageFitType`       v = imagefittype )
                                ( n = `initials`       v = initials )
                                ( n = `showBorder`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showborder ) )
                                ( n = `decorative`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( decorative ) )
                                ( n = `enabled`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `displaySize` v = displaysize )
                                ( n = `press` v = press ) ) ).
  ENDMETHOD.

  METHOD avatar_group.
    result = _generic( name   = `AvatarGroup`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id` v = id )
                                         ( n = `avatarCustomDisplaySize` v = avatarcustomdisplaysize )
                                         ( n = `avatarCustomFontSize` v = avatarcustomfontsize )
                                         ( n = `avatarDisplaySize` v = avatardisplaysize )
                                         ( n = `blocked` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( blocked ) )
                                         ( n = `busy` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( busy ) )
                                         ( n = `busyIndicatorDelay` v = busyindicatordelay )
                                         ( n = `busyIndicatorSize` v = busyindicatorsize )
                                         ( n = `fieldGroupIds` v = fieldgroupids )
                                         ( n = `groupType` v = grouptype )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `tooltip` v = tooltip )
                                         ( n = `items` v = items )
                                         ( n = `press` v = press ) ) ).
  ENDMETHOD.

  METHOD avatar_group_item.
    result = me.
    _generic( name   = `AvatarGroupItem`
              ns     = `f`
              t_prop = VALUE #( ( n = `id` v = id )
                                ( n = `busy` v = busy )
                                ( n = `busyIndicatorDelay` v = busyindicatordelay )
                                ( n = `busyIndicatorSize` v = busyindicatorsize )
                                ( n = `fallbackIcon` v = fallbackicon )
                                ( n = `fieldGroupIds` v = fieldgroupids )
                                ( n = `initials` v = initials )
                                ( n = `src` v = src )
                                ( n = `visible` v = visible )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.

  METHOD axis_time_strategy.
    result = _generic( name = `axisTimeStrategy`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD badge.
    result = _generic( `badge` ).
  ENDMETHOD.

  METHOD badge_custom_data.
    result = me.
    _generic( name   = `BadgeCustomData`
              t_prop = VALUE #( ( n = `key`      v = key )
                                ( n = `value`    v = value )
                                ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD bar.
    result = _generic( `Bar` ).
  ENDMETHOD.

  METHOD barcode_scanner_button.
    result = _generic( name   = `BarcodeScannerButton`
                       ns     = `ndc`
                       t_prop = VALUE #( ( n = `id`                        v = id )
                                         ( n = `scanSuccess`               v = scansuccess )
                                         ( n = `scanFail`                  v = scanfail )
                                         ( n = `inputLiveUpdate`           v = inputliveupdate )
                                         ( n = `dialogTitle`               v = dialogtitle )
                                         ( n = `disableBarcodeInputDialog` v = disablebarcodeinputdialog )
                                         ( n = `frameRate`                 v = framerate )
                                         ( n = `keepCameraScan`            v = keepcamerascan )
                                         ( n = `preferFrontCamera`         v = preferfrontcamera )
                                         ( n = `provideFallback`           v = providefallback )
                                         ( n = `width`                     v = width )
                                         ( n = `zoom`                      v = zoom ) ) ).
  ENDMETHOD.

  METHOD bars.
    result = _generic( name = `bars`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD base_rectangle.

    result = _generic(
        name   = `BaseRectangle`
        ns     = `gantt`
        t_prop = VALUE #( ( n = `time`                      v = time )
                          ( n = `endTime`                   v = endtime )
                          ( n = `selectable`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selectable ) )
                          ( n = `selectedFill`              v = selectedfill )
                          ( n = `fill`                      v = fill )
                          ( n = `height`                    v = height )
                          ( n = `title`                     v = title )
                          ( n = `animationSettings`         v = animationsettings )
                          ( n = `alignShape`                v = alignshape )
                          ( n = `color`                     v = color )
                          ( n = `fontSize`                  v = fontsize )
                          ( n = `connectable`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( connectable ) )
                          ( n = `fontFamily`                v = fontfamily )
                          ( n = `filter`                    v = filter )
                          ( n = `transform`                 v = transform )
                          ( n = `countInBirdEye`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( countinbirdeye ) )
                          ( n = `fontWeight`                v = fontweight )
                          ( n = `showTitle`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitle ) )
                          ( n = `selected`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                          ( n = `resizable`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resizable ) )
                          ( n = `horizontalTextAlignment`   v = horizontaltextalignment )
                          ( n = `shapeId`                   v = shapeid )
                          ( n = `highlighted`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( highlighted ) )
                          ( n = `highlightable`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( highlightable ) ) ) ).
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
    result = _generic( name   = `BlockLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `background` v = background )
                                         ( n = `id` v = id ) ) ).
  ENDMETHOD.

  METHOD block_layout_cell.
    result = _generic( name   = `BlockLayoutCell`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `backgroundColorSet` v = backgroundcolorset )
                                         ( n = `backgroundColorShade` v = backgroundcolorshade )
                                         ( n = `title` v = title )
                                         ( n = `titleAlignment` v = titlealignment )
                                         ( n = `width` v = width )
                                         ( n = `class` v = class )
                                         ( n = `id` v = id )
                                         ( n = `titleLevel` v = titlelevel ) ) ).
  ENDMETHOD.

  METHOD block_layout_row.
    result = _generic( name   = `BlockLayoutRow`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `rowColorSet` v = rowcolorset )
                                         ( n = `id` v = id ) ) ).
  ENDMETHOD.

  METHOD bullet_micro_chart.
    result = me.
    _generic(
        name   = `BulletMicroChart`
        ns     = `mchart`
        t_prop = VALUE #( ( n = `actualValueLabel`  v = actualvaluelabel )
                          ( n = `press`       v = press )
                          ( n = `size`        v = size )
                          ( n = `height`      v = height )
                          ( n = `width`      v = width )
                          ( n = `deltaValueLabel`      v = deltavaluelabel )
                          ( n = `maxValue`      v = maxvalue )
                          ( n = `minValue`      v = minvalue )
                          ( n = `mode`      v = mode )
                          ( n = `scale`      v = scale )
                          ( n = `targetValue`      v = targetvalue )
                          ( n = `targetValueLabel`      v = targetvaluelabel )
                          ( n = `scaleColor`      v = scalecolor )
                          ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                          ( n = `showActualValue`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showactualvalue ) )
                          ( n = `showActualValueInDeltaMode`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( savidm ) )
                          ( n = `showDeltaValue`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showdeltavalue ) )
                          ( n = `showTargetValue`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtargetvalue ) )
                          ( n = `showThresholds`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showthresholds ) )
                          ( n = `showValueMarker`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluemarker ) )
                          ( n = `smallRangeAllowed`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( smallrangeallowed ) )
                          ( n = `forecastValue`  v = forecastvalue ) ) ).
  ENDMETHOD.

  METHOD busy_indicator.
    result = _generic(
        name   = `BusyIndicator`
        t_prop = VALUE #(
            ( n = `id`  v = id )
            ( n = `class`  v = class )
            ( n = `customIcon`  v = customicon )
            ( n = `customIconHeight`         v = customiconheight )
            ( n = `customIconRotationSpeed`  v = customiconrotationspeed )
            ( n = `customIconWidth`             v = customiconwidth )
            ( n = `size`        v = size )
            ( n = `text`         v = text )
            ( n = `textDirection`       v = textdirection )
            ( n = `customIconDensityAware`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( customicondensityaware ) )
            ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD button.

    result = me.
    _generic( name   = `Button`
              ns     = ns
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `iconDensityAware` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                                ( n = `iconFirst` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconfirst ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `id`      v = id )
                                ( n = `width`   v = width )
                                ( n = `tooltip` v = tooltip )
                                ( n = `textDirection` v = textdirection )
                                ( n = `accessibleRole` v = accessiblerole )
                                ( n = `activeIcon` v = activeicon )
                                ( n = `ariaHasPopup` v = ariahaspopup )
                                ( n = `class`   v = class )
                                ( n = `ariaLabelledBy`  v = arialabelledby )
                                ( n = `ariaDescribedBy` v = ariadescribedby ) ) ).
  ENDMETHOD.

  METHOD buttons.
    result = _generic( `buttons` ).
  ENDMETHOD.

  METHOD calendar_appointment.
    result = _generic(
        name   = `CalendarAppointment`
        ns     = `u`
        t_prop = VALUE #( ( n = `startDate`                 v = startdate )
                          ( n = `endDate`                   v = enddate )
                          ( n = `icon`                      v = icon )
                          ( n = `title`                     v = title )
                          ( n = `text`                      v = text )
                          ( n = `type`                      v = type )
                          ( n = `key`                       v = key )
                          ( n = `selected`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                          ( n = `tentative`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( tentative ) )
                        ) ).
  ENDMETHOD.

  METHOD calendar_legend_item.
    result = _generic( name   = `CalendarLegendItem`
                       t_prop = VALUE #( ( n = `text`                   v = text )
                                         ( n = `type`                   v = type )
                                         ( n = `tooltip`                v = tooltip )
                                         ( n = `color`                  v = color ) ) ).

  ENDMETHOD.

  METHOD card.
    result = _generic( name   = `Card`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `headerPosition`  v = headerposition )
                                         ( n = `height`  v = height )
                                         ( n = `width`  v = width )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD card_header.
    result = _generic( name   = `Header`
                       ns     = `card`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `dataTimestamp`  v = datatimestamp )
                                         ( n = `iconAlt`  v = iconalt )
                                         ( n = `iconBackgroundColor`  v = iconbackgroundcolor )
                                         ( n = `iconDisplayShape`  v = icondisplayshape )
                                         ( n = `iconInitials`  v = iconinitials )
                                         ( n = `iconSize`  v = iconsize )
                                         ( n = `iconSrc`  v = iconsrc )
                                         ( n = `statusText`  v = statustext )
                                         ( n = `statusVisible`  v = statusvisible )
                                         ( n = `subtitle`  v = subtitle )
                                         ( n = `subtitleMaxLines`  v = subtitlemaxlines )
                                         ( n = `title`  v = title )
                                         ( n = `press`  v = press )
                                         ( n = `titleMaxLines`  v = titlemaxlines )
                                         ( n = `iconVisible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconvisible ) )
                                         ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD carousel.

    result = _generic( name   = `Carousel`
                       t_prop = VALUE #( ( n = `loop`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( loop ) )
                                         ( n = `class`  v = class )
                                         ( n = `height`  v = height )
                                         ( n = `id`  v = id )
                                         ( n = `arrowsPlacement`  v = arrowsplacement )
                                         ( n = `backgroundDesign`  v = backgrounddesign )
                                         ( n = `pageIndicatorBackgroundDesign`  v = pageindicatorbackgrounddesign )
                                         ( n = `pageIndicatorBorderDesign`  v = pageindicatorborderdesign )
                                         ( n = `pageIndicatorPlacement`  v = pageindicatorplacement )
                                         ( n = `width`  v = width )
                                         ( n = `showPageIndicator`  v = showpageindicator )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `pages`  v = pages ) ) ).

  ENDMETHOD.

  METHOD carousel_layout.
    result = _generic( name   = `CarouselLayout`
                       t_prop = VALUE #( ( n = `visiblePagesCount`  v = visiblepagescount ) ) ).
  ENDMETHOD.

  METHOD cells.
    result = _generic( `cells` ).
  ENDMETHOD.

  METHOD checkbox.

    result = me.
    _generic( name   = `CheckBox`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `id` v = id )
                                ( n = `class` v = class )
                                ( n = `name` v = name )
                                ( n = `selected` v = selected )
                                ( n = `textAlign` v = textalign )
                                ( n = `textDirection` v = textdirection )
                                ( n = `valueState` v = valuestate )
                                ( n = `width` v = width )
                                ( n = `activeHandling`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( activehandling ) )
                                ( n = `enabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `displayOnly`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayonly ) )
                                ( n = `editable`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                ( n = `partiallySelected`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( partiallyselected ) )
                                ( n = `useEntireWidth`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( useentirewidth ) )
                                ( n = `wrapping`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                                ( n = `select`   v = select )
                                ( n = `required`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) ) ) ).
  ENDMETHOD.

  METHOD code_editor.
    result = me.
    _generic( name   = `CodeEditor`
              ns     = `editor`
              t_prop = VALUE #( ( n = `value`   v = value )
                                ( n = `type`    v = type )
                                ( n = `editable`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                ( n = `height` v = height )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.

  METHOD column.
    result = _generic(
                 name   = `Column`
                 t_prop = VALUE #( ( n = `width` v = width )
                                   ( n = `minScreenWidth` v = minscreenwidth )
                                   ( n = `hAlign` v = halign )
                                   ( n = `headerMenu` v = headermenu )
                                   ( n = `autoPopinWidth` v = autopopinwidth )
                                   ( n = `vAlign` v = valign )
                                   ( n = `importance` v = importance )
                                   ( n = `mergeFunctionName` v = mergefunctionname )
                                   ( n = `popinDisplay` v = popindisplay )
                                   ( n = `sortIndicator` v = sortindicator )
                                   ( n = `styleClass` v = styleclass )
                                   ( n = `id`         v = id )
                                   ( n = `class`         v = class )
                                   ( n = `mergeDuplicates` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( mergeduplicates ) )
                                   ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `demandPopin` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( demandpopin ) ) ) ).
  ENDMETHOD.

  METHOD columns.
    result = _generic( ns   = ns
                       name = `columns` ).
  ENDMETHOD.

  METHOD column_element_data.
    result = _generic( name   = `ColumnElementData`
                       ns     = `form`
                       t_prop = VALUE #( ( n = `cellsLarge` v = cellslarge )
                                         ( n = `cellsSmall` v = cellssmall ) ) ).
  ENDMETHOD.

  METHOD column_list_item.
    result = _generic( name   = `ColumnListItem`
                       t_prop = VALUE #( ( n = `vAlign`   v = valign )
                                         ( n = `id` v = id )
                                         ( n = `selected` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                         ( n = `unread` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( unread ) )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `type`     v = type )
                                         ( n = `counter`     v = counter )
                                         ( n = `highlight`     v = highlight )
                                         ( n = `highlightText`     v = highlighttext )
                                         ( n = `detailPress`     v = detailpress )
                                         ( n = `navigated`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( navigated ) )
                                         ( n = `press`    v = press ) ) ).
  ENDMETHOD.

  METHOD action_list_item.
    result = _generic( name   = `ActionListItem`
                       t_prop = VALUE #( ( n = `id`     v = id )
                                         ( n = `text`   v = text ) ) ).
  ENDMETHOD.

  METHOD column_menu.
    result = _generic( name   = `Menu`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `afterClose`     v = afterclose )
                                         ( n = `beforeOpen` v = beforeopen )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_action_item.
    result = _generic( name   = `ActionItem`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `icon`     v = icon )
                                         ( n = `label`    v = label )
                                         ( n = `press`    v = press )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_item.
    result = _generic( name   = `Item`
                       ns     = `columnmenu`
                       t_prop = VALUE #(
                           ( n = `id`       v = id )
                           ( n = `class`    v = class )
                           ( n = `icon`     v = icon )
                           ( n = `label`    v = label )
                           ( n = `cancel`    v = cancel )
                           ( n = `confirm`    v = confirm )
                           ( n = `reset`    v = reset )
                           ( n = `resetButtonEnabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resetbuttonenabled ) )
                           ( n = `showCancelButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcancelbutton ) )
                           ( n = `showConfirmButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showconfirmbutton ) )
                           ( n = `showResetButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showresetbutton ) )
                           ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_action.
    result = _generic( name   = `QuickAction`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `category`     v = category )
                                         ( n = `label`     v = label )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_action_item.
    result = _generic( name   = `QuickActionItem`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `key`    v = key )
                                         ( n = `label`    v = label )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_group.
    result = _generic( name   = `QuickGroup`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `change`     v = change )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_group_item.
    result = _generic( name   = `QuickGroupItem`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `key`    v = key )
                                         ( n = `label`    v = label )
                                         ( n = `grouped`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( grouped ) )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_sort.
    result = _generic( name   = `QuickSort`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `change`     v = change )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_sort_item.
    result = _generic( name   = `QuickSortItem`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `key`    v = key )
                                         ( n = `label`    v = label )
                                         ( n = `sortOrder`  v = sortorder )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_total.
    result = _generic( name   = `QuickTotal`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `change`     v = change )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_menu_quick_total_item.
    result = _generic( name   = `QuickTotalItem`
                       ns     = `columnmenu`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `key`    v = key )
                                         ( n = `label`    v = label )
                                         ( n = `totaled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( totaled ) )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD column_micro_chart.
    result = me.
    _generic(
        name   = `ColumnMicroChart`
        ns     = `mchart`
        t_prop = VALUE #( ( n = `width`  v = width )
                          ( n = `press`       v = press )
                          ( n = `size`        v = size )
                          ( n = `alignContent`      v = aligncontent )
                          ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                          ( n = `allowColumnLabels`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( allowcolumnlabels ) )
                          ( n = `showBottomLabels`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbottomlabels ) )
                          ( n = `showTopLabels`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtoplabels ) )
                          ( n = `height`  v = height ) ) ).
  ENDMETHOD.

  METHOD column_micro_chart_data.
    result = me.
    _generic( name   = `ColumnMicroChartData`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `color`  v = color )
                                ( n = `displayValue`       v = displayvalue )
                                ( n = `label`        v = label )
                                ( n = `value`      v = value )
                                ( n = `press`      v = press )
                               ) ).
  ENDMETHOD.

  METHOD combobox.
    result = _generic(
        name   = `ComboBox`
        t_prop = VALUE #(
            (  n = `showClearIcon` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearicon ) )
            (  n = `selectedKey`   v = selectedkey )
            (  n = `items`         v = items )
            (  n = `id`         v = id )
            (  n = `class`         v = class )
            (  n = `selectionChange`         v = selectionchange )
            (  n = `selectedItem`         v = selecteditem )
            (  n = `selectedItemId`         v = selecteditemid )
            (  n = `name`         v = name )
            (  n = `value`         v = value )
            (  n = `valueState`         v = valuestate )
            (  n = `valueStateText`         v = valuestatetext )
            (  n = `textAlign`         v = textalign )
            (  n = `showSecondaryValues`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsecondaryvalues ) )
            (  n = `visible`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            (  n = `showValueStateMessage`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
            (  n = `showButton`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbutton ) )
            (  n = `required`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
            (  n = `editable`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
            (  n = `enabled`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
            (  n = `filterSecondaryValues`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( filtersecondaryvalues ) )
            (  n = `width`         v = width )
            (  n = `placeholder`         v = placeholder )
            (  n = `change`        v = change ) ) ).

  ENDMETHOD.

  METHOD comparison_micro_chart.
    result = _generic(
                 name   = `ComparisonMicroChart`
                 ns     = `mchart`
                 t_prop = VALUE #( ( n = `colorPalette`  v = colorpalette )
                                   ( n = `press`       v = press )
                                   ( n = `size`        v = size )
                                   ( n = `height`      v = height )
                                   ( n = `maxValue`      v = maxvalue )
                                   ( n = `minValue`      v = minvalue )
                                   ( n = `scale`      v = scale )
                                   ( n = `width`      v = width )
                                   ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                                   ( n = `shrinkable`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shrinkable ) )
                                   ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `view`  v = view ) ) ).
  ENDMETHOD.

  METHOD comparison_micro_chart_data.
    result = _generic( name   = `ComparisonMicroChartData`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `color`  v = color )
                                         ( n = `press`       v = press )
                                         ( n = `displayValue`        v = displayvalue )
                                         ( n = `title`      v = title )
                                         ( n = `value`      v = value ) ) ).
  ENDMETHOD.

  METHOD constructor.

  ENDMETHOD.

  METHOD container_content.

    result = _generic( name   = `ContainerContent`
                       ns     = `vk`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `title`  v = title )
                                         ( n = `icon`  v = icon ) ) ).

  ENDMETHOD.

  METHOD container_toolbar.

    result = _generic(
        name   = `ContainerToolbar`
        ns     = `gantt`
        t_prop = VALUE #(
            ( n = `showSearchButton`          v = showsearchbutton )
            ( n = `alignCustomContentToRight` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( aligncustomcontenttoright ) )
            ( n = `findMode`                  v = findmode )
            ( n = `infoOfSelectItems`         v = infoofselectitems )
            ( n = `findButtonPress`           v = findbuttonpress )
            ( n = `showBirdEyeButton`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbirdeyebutton ) )
            ( n = `showDisplayTypeButton`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showdisplaytypebutton ) )
            ( n = `showLegendButton`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showlegendbutton ) )
            ( n = `showSettingButton`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsettingbutton ) )
            ( n = `showTimeZoomControl`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtimezoomcontrol ) )
            ( n = `stepCountOfSlider`         v = stepcountofslider )
            ( n = `zoomControlType`           v = zoomcontroltype )
            ( n = `zoomLevel`                 v = zoomlevel ) ) ).
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
    result = me.
    _generic( name   = `CustomData`
              ns     = `core`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `key` v = key )
                                ( n = `writeToDom` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( writetodom ) ) ) ).

  ENDMETHOD.

  METHOD currency.
    result = _generic( name   = `Currency`
                       ns     = `u`
                       t_prop = VALUE #( ( n = `value`        v = value )
                                         ( n = `currency`     v = currency )
                                         ( n = `useSymbol`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usesymbol ) )
                                         ( n = `maxPrecision` v = maxprecision )
                                         ( n = `stringValue`  v = stringvalue ) ) ).

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
    result = me.
    _generic( name   = `DatePicker`
              t_prop = VALUE #(
                  ( n = `value`                 v = value )
                  ( n = `displayFormat`         v = displayformat )
                  ( n = `displayFormatType`         v = displayformattype )
                  ( n = `valueFormat`           v = valueformat )
                  ( n = `required`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                  ( n = `valueState`            v = valuestate )
                  ( n = `valueStateText`        v = valuestatetext )
                  ( n = `placeholder`           v = placeholder )
                  ( n = `textAlign`                v = textalign )
                  ( n = `textDirection`                v = textdirection )
                  ( n = `change`                v = change )
                  ( n = `maxDate`               v = maxdate )
                  ( n = `minDate`               v = mindate )
                  ( n = `width`               v = width )
                  ( n = `id`               v = id )
                  ( n = `dateValue`               v = datevalue )
                  ( n = `name`               v = name )
                  ( n = `class`               v = class )
                  ( n = `calendarWeekNumbering`               v = calendarweeknumbering )
                  ( n = `initialFocusedDateValue`               v = initialfocuseddatevalue )
                  ( n = `enabled`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                  ( n = `visible`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                  ( n = `editable`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                  ( n = `hideInput`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideinput ) )
                  ( n = `showFooter`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfooter ) )
                  ( n = `showValueStateMessage` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
                  ( n = `showCurrentDateButton` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcurrentdatebutton ) ) ) ).
  ENDMETHOD.

  METHOD date_time_picker.
    result = me.
    _generic( name   = `DateTimePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder`  v = placeholder )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `valueState` v = valuestate ) ) ).
  ENDMETHOD.

  METHOD delta_micro_chart.
    result = me.
    _generic( name   = `DeltaMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `color`  v = color )
                                ( n = `press`       v = press )
                                ( n = `size`        v = size )
                                ( n = `height`      v = height )
                                ( n = `width`      v = width )
                                ( n = `deltaDisplayValue`      v = deltadisplayvalue )
                                ( n = `displayValue1`      v = displayvalue1 )
                                ( n = `displayValue2`      v = displayvalue2 )
                                ( n = `title2`      v = title2 )
                                ( n = `value1`      v = value1 )
                                ( n = `value2`      v = value2 )
                                ( n = `view`      v = view )
                                ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `title1`  v = title1 ) ) ).
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

    result = _generic(
        name   = `Dialog`
        t_prop = VALUE #( ( n = `title`  v = title )
                          ( n = `icon`  v = icon )
                          ( n = `stretch`  v = stretch )
                          ( n = `state`  v = state )
                          ( n = `titleAlignment`  v = titlealignment )
                          ( n = `type`  v = type )
                          ( n = `showHeader`  v = showheader )
                          ( n = `contentWidth`  v = contentwidth )
                          ( n = `contentHeight`  v = contentheight )
                          ( n = `escapeHandler`  v = escapehandler )
                          ( n = `closeOnNavigation`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( closeonnavigation ) )
                          ( n = `draggable`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( draggable ) )
                          ( n = `resizable`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resizable ) )
                          ( n = `horizontalScrolling`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( horizontalscrolling ) )
                          ( n = `verticalScrolling`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( verticalscrolling ) )
                          ( n = `afterOpen`  v = afteropen )
                          ( n = `beforeClose`  v = beforeclose )
                          ( n = `beforeOpen`  v = beforeopen )
                          ( n = `afterClose` v = afterclose ) ) ).
  ENDMETHOD.

  METHOD draft_indicator.
    result = _generic( name   = `DraftIndicator`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `minDisplayTime`  v = mindisplaytime )
                                         ( n = `state`  v = state )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD drag_drop_info.
    result = me.
    _generic( name   = `DragDropInfo`
              ns     = `dnd`
              t_prop = VALUE #( ( n = `sourceAggregation`  v = sourceaggregation )
                                ( n = `targetAggregation`  v = targetaggregation )
                                ( n = `dragStart`          v = dragstart )
                                ( n = `drop`               v = drop )
                 ) ).
  ENDMETHOD.

  METHOD drag_info.
    result = me.
    _generic( name   = `DragInfo`
              ns     = `dnd`
              t_prop = VALUE #( ( n = `sourceAggregation`  v = sourceaggregation ) ) ).
  ENDMETHOD.

  METHOD drag_drop_config.
    result = _generic( name = `dragDropConfig`
                       ns   = ns ).
  ENDMETHOD.

  METHOD dynamic_page.
    result = _generic( name   = `DynamicPage`
                       ns     = `f`
                       t_prop = VALUE #(
                           (  n = `headerExpanded`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( headerexpanded ) )
                           (  n = `headerPinned`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( headerpinned ) )
                           (  n = `showFooter`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfooter ) )
                           (  n = `toggleHeaderOnTitleClick` v = toggleheaderontitleclick )
                           (  n = `class`  v = class ) ) ).
  ENDMETHOD.

  METHOD dynamic_page_header.
    result = _generic(
                 name   = `DynamicPageHeader`
                 ns     = `f`
                 t_prop = VALUE #( (  n = `pinnable`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( pinnable ) ) ) ).
  ENDMETHOD.

  METHOD dynamic_page_title.
    result = _generic( name = `DynamicPageTitle`
                       ns   = `f` ).
  ENDMETHOD.

  METHOD dynamic_side_content.
    result = _generic( name   = `DynamicSideContent`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `id`                              v = id )
                                         ( n = `class`                           v = class )
                                         ( n = `sideContentVisibility`           v = sidecontentvisibility )
                                         ( n = `showSideContent`                 v = showsidecontent )
                                         ( n = `containerQuery`                  v = containerquery ) ) ).

  ENDMETHOD.

  METHOD element_attribute.
    result = _generic( name   = `ElementAttribute`
                       ns     = SWITCH #( ns WHEN `` THEN `networkgraph` ELSE ns )
                       t_prop = VALUE #( ( n = `label`  v = label )
                                         ( n = `value`  v = value ) ) ).
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
    result = _generic(
                 name   = `ExpandableText`
                 t_prop = VALUE #(
                     ( n = `id`  v = id )
                     ( n = `emptyIndicatorMode`  v = emptyindicatormode )
                     ( n = `maxCharacters`         v = maxcharacters )
                     ( n = `overflowMode`  v = overflowmode )
                     ( n = `renderWhitespace`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( renderwhitespace ) )
                     ( n = `text`        v = text )
                     ( n = `textAlign`         v = textalign )
                     ( n = `textDirection`       v = textdirection )
                     ( n = `wrappingType` v = wrappingtype )
                     ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `class`  v = class ) ) ).
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
    result = _generic( name   = `FacetFilter`
                       t_prop = VALUE #(
                           ( n = `id`  v = id )
                           ( n = `class`  v = class )
                           ( n = `liveSearch`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( livesearch ) )
                           ( n = `showPersonalization` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showpersonalization ) )
                           ( n = `showPopoverOKButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showpopoverokbutton ) )
                           ( n = `showReset`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showreset ) )
                           ( n = `showSummaryBar`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsummarybar ) )
                           ( n = `type`         v = type )
                           ( n = `confirm`        v = confirm )
                           ( n = `reset` v = reset )
                           ( n = `lists` v = lists )
                           ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD facet_filter_item.
    result = _generic(
                 name   = `FacetFilterItem`
                 t_prop = VALUE #( ( n = `id`  v = id )
                                   ( n = `class`  v = class )
                                   ( n = `count`  v = count )
                                   ( n = `counter` v = counter )
                                   ( n = `highlight`  v = highlight )
                                   ( n = `highlightText` v = highlighttext )
                                   ( n = `key`        v = key )
                                   ( n = `navigated`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( navigated ) )
                                   ( n = `selected`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                   ( n = `unread`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( unread ) )
                                   ( n = `text`       v = text )
                                   ( n = `type`        v = type )
                                   ( n = `detailPress` v = detailpress )
                                   ( n = `press` v = press )
                                   ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD facet_filter_list.
    result = _generic(
        name   = `FacetFilterList`
        t_prop = VALUE #(
            ( n = `id`  v = id )
            ( n = `class`  v = class )
            ( n = `active`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( active ) )
            ( n = `allCount`  v = allcount )
            ( n = `backgroundDesign`         v = backgrounddesign )
            ( n = `dataType`  v = datatype )
            ( n = `enableBusyIndicator` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablebusyindicator ) )
            ( n = `enableCaseInsensitiveSearch` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecaseinsensitivesearch ) )
            ( n = `footerText`         v = footertext )
            ( n = `growing`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
            ( n = `growingDirection`        v = growingdirection )
            ( n = `growingScrollToLoad` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growingscrolltoload ) )
            ( n = `growingThreshold` v = growingthreshold )
            ( n = `growingTriggerText` v = growingtriggertext )
            ( n = `headerLevel` v = headerlevel )
            ( n = `includeItemInSelection` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( includeiteminselection ) )
            ( n = `inset` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inset ) )
            ( n = `key` v = key )
            ( n = `swipeDirection` v = swipedirection )
            ( n = `headerText` v = headertext )
            ( n = `keyboardMode` v = keyboardmode )
            ( n = `mode` v = mode )
            ( n = `modeAnimationOn` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( modeanimationon ) )
            ( n = `multiSelectMode` v = multiselectmode )
            ( n = `noDataText` v = nodatatext )
            ( n = `rememberSelections` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rememberselections ) )
            ( n = `retainListSequence` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( retainlistsequence ) )
            ( n = `sequence` v = sequence )
            ( n = `showNoData` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownodata ) )
            ( n = `showRemoveFacetIcon` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showremovefaceticon ) )
            ( n = `showSeparators` v = showseparators )
            ( n = `showUnread` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showunread ) )
            ( n = `sticky` v = sticky )
            ( n = `title` v = title )
            ( n = `width` v = width )
            ( n = `wordWrap` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wordwrap ) )
            ( n = `listClose` v = listclose )
            ( n = `listOpen` v = listopen )
            ( n = `search` v = search )
            ( n = `selectionChange` v = selectionchange )
            ( n = `delete` v = delete )
            ( n = `items` v = items )
            ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    result->mt_prop = t_ns.

    result->mt_prop   = VALUE #( BASE result->mt_prop
                                 (  n = `displayBlock`   v = `true` )
                                 (  n = `height`         v = `100%` ) ).

    result->mv_name   = `View`.
    result->mv_ns     = `mvc`.
    result->mo_root   = result.
    result->mo_parent = result.

    INSERT VALUE #( n = `xmlns`
                    v = `sap.m` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:mvc`
                    v = `sap.ui.core.mvc` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:core`
                    v = `sap.ui.core` ) INTO TABLE result->mt_prop.

  ENDMETHOD.

  METHOD factory_plain.

    result = NEW #( ).

    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.

  METHOD factory_popup.

    result = NEW #( ).

    result->mt_prop = t_ns.

    result->mv_name   = `FragmentDefinition`.
    result->mv_ns     = `core`.
    result->mo_root   = result.
    result->mo_parent = result.

    INSERT VALUE #( n = `xmlns`
                    v = `sap.m` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:core`
                    v = `sap.ui.core` ) INTO TABLE result->mt_prop.

  ENDMETHOD.

  METHOD fb_control.
    result = _generic( name = `control`
                       ns   = `fb` ).
  ENDMETHOD.

  METHOD feed_input.
    result = _generic(
                 name   = `FeedInput`
                 t_prop = VALUE #( ( n = `buttonTooltip`    v = buttontooltip )
                                   ( n = `enabled`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                   ( n = `growing`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
                                   ( n = `growingMaxLines`  v = growingmaxlines )
                                   ( n = `icon`             v = icon )
                                   ( n = `iconDensityAware` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                                   ( n = `iconDisplayShape` v = icondisplayshape )
                                   ( n = `iconInitials`     v = iconinitials )
                                   ( n = `iconSize`         v = iconsize )
                                   ( n = `maxLength`        v = maxlength )
                                   ( n = `placeholder`      v = placeholder )
                                   ( n = `rows`             v = rows )
                                   ( n = `showExceededText` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showexceededtext ) )
                                   ( n = `showIcon`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showicon ) )
                                   ( n = `value`            v = value )
                                   ( n = `class`            v = class )
                                   ( n = `post`             v = post ) ) ).

  ENDMETHOD.

  METHOD feed_list_item.
    result = _generic(
                 name   = `FeedListItem`
                 t_prop = VALUE #(
                     ( n = `activeIcon`                  v = activeicon )
                     ( n = `convertedLinksDefaultTarget` v = convertedlinksdefaulttarget )
                     ( n = `convertLinksToAnchorTags`    v = convertlinkstoanchortags )
                     ( n = `iconActive`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconactive ) )
                     ( n = `icon`                        v = icon )
                     ( n = `iconDensityAware`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                     ( n = `iconDisplayShape`            v = icondisplayshape )
                     ( n = `iconInitials`                v = iconinitials )
                     ( n = `iconSize`                    v = iconsize )
                     ( n = `info`                        v = info )
                     ( n = `lessLabel`                   v = lesslabel )
                     ( n = `maxCharacters`               v = maxcharacters )
                     ( n = `moreLabel`                   v = morelabel )
                     ( n = `sender`                      v = sender )
                     ( n = `senderActive`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( senderactive ) )
                     ( n = `showIcon`                    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showicon ) )
                     ( n = `text`                        v = text )
                     ( n = `senderPress`                 v = senderpress )
                     ( n = `iconPress`                   v = iconpress )
                     ( n = `timestamp`                   v = timestamp ) ) ).
  ENDMETHOD.

  METHOD feed_list_item_action.
    result = _generic( name   = `FeedListItemAction`
                       t_prop = VALUE #( ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `icon`    v = icon )
                                         ( n = `key`     v = key )
                                         ( n = `text`    v = text )
                                         ( n = `press`   v = press )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD filter_bar.

    result = _generic(
        name   = `FilterBar`
        ns     = `fb`
        t_prop = VALUE #(
            ( n = `useToolbar`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usetoolbar ) )
            ( n = `search`         v = search )
            ( n = `id`             v = id )
            ( n = `persistencyKey` v = persistencykey )
            ( n = `afterVariantLoad` v = aftervariantload )
            ( n = `afterVariantSave` v = aftervariantsave )
            ( n = `assignedFiltersChanged` v = assignedfilterschanged )
            ( n = `beforeVariantFetch` v = beforevariantfetch )
            ( n = `cancel` v = cancel )
            ( n = `clear` v = clear )
            ( n = `filtersDialogBeforeOpen` v = filtersdialogbeforeopen )
            ( n = `filtersDialogCancel` v = filtersdialogcancel )
            ( n = `filtersDialogClosed` v = filtersdialogclosed )
            ( n = `initialise` v = initialise )
            ( n = `initialized` v = initialized )
            ( n = `reset` v = reset )
            ( n = `filterContainerWidth` v = filtercontainerwidth )
            ( n = `header` v = header )
            ( n = `advancedMode` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( advancedmode ) )
            ( n = `isRunningInValueHelpDialog` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( isrunninginvaluehelpdialog ) )
            ( n = `showAllFilters` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showallfilters ) )
            ( n = `showClearOnFB` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearonfb ) )
            ( n = `showFilterConfiguration` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfilterconfiguration ) )
            ( n = `showGoOnFB` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgoonfb ) )
            ( n = `showRestoreButton` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showrestorebutton ) )
            ( n = `showRestoreOnFB` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showrestoreonfb ) )
            ( n = `useSnapshot` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usesnapshot ) )
            ( n = `searchEnabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( searchenabled ) )
            ( n = `considerGroupTitle` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( considergrouptitle ) )
            ( n = `deltaVariantMode` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( deltavariantmode ) )
            ( n = `disableSearchMatchesPatternWarning`
              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( disablesearchmatchespatternw ) )
            ( n = `filterBarExpanded` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( filterbarexpanded ) )
            ( n = `filterChange`   v = filterchange ) ) ).
  ENDMETHOD.

  METHOD filter_control.
    result = _generic( name = `control`
                       ns   = `fb` ).
  ENDMETHOD.

  METHOD filter_group_item.
    result = _generic(
        name   = `FilterGroupItem`
        ns     = `fb`
        t_prop = VALUE #( ( n = `name`                v  = name )
                          ( n = `label`               v  = label )
                          ( n = `groupName`           v  = groupname )
                          ( n = `controlTooltip`           v  = controltooltip )
                          ( n = `entitySetName`           v  = entitysetname )
                          ( n = `entityTypeName`           v  = entitytypename )
                          ( n = `groupTitle`           v  = grouptitle )
                          ( n = `labelTooltip`           v  = labeltooltip )
                          ( n = `change`           v  = change )
                          ( n = `visibleInFilterBar`  v  = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visibleinfilterbar ) )
                          ( n = `mandatory`  v  = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( mandatory ) )
                          ( n = `hiddenFilter`  v  = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hiddenfilter ) )
                          ( n = `visible`  v  = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                        ) ).

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

    result = _generic(
        name   = `FlexibleColumnLayout`
        ns     = `f`
        t_prop = VALUE #(
            (  n = `layout` v = layout )
            (  n = `id` v = id )
            (  n = `class` v = class )
            (  n = `afterBeginColumnNavigate` v = afterbegincolumnnavigate )
            (  n = `afterEndColumnNavigate` v = afterendcolumnnavigate )
            (  n = `afterMidColumnNavigate` v = aftermidcolumnnavigate )
            (  n = `beginColumnNavigate` v = begincolumnnavigate )
            (  n = `columnResize` v = columnresize )
            (  n = `endColumnNavigate` v = endcolumnnavigate )
            (  n = `midColumnNavigate` v = midcolumnnavigate )
            (  n = `stateChange` v = statechange )
            (  n = `backgroundDesign` v = backgrounddesign )
            (  n = `defaultTransitionNameBeginColumn` v = defaulttransitionnamebegincol )
            (  n = `defaultTransitionNameEndColumn` v = defaulttransitionnameendcol )
            (  n = `defaultTransitionNameMidColumn` v = defaulttransitionnamemidcol )
            (  n = `autoFocus` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autofocus ) )
            (  n = `restoreFocusOnBackNavigation` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( restorefocusonbacknavigation ) ) ) ).

  ENDMETHOD.

  METHOD flex_box.
    result = _generic(
                 name   = `FlexBox`
                 t_prop = VALUE #( ( n = `class`  v = class )
                                   ( n = `id` v = id )
                                   ( n = `renderType`  v = rendertype )
                                   ( n = `width`  v = width )
                                   ( n = `height`  v = height )
                                   ( n = `alignItems`  v = alignitems )
                                   ( n = `fitContainer`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( fitcontainer ) )
                                   ( n = `justifyContent`  v = justifycontent )
                                   ( n = `wrap`  v = wrap )
                                   ( n = `items`  v = items )
                                   ( n = `direction`  v = direction )
                                   ( n = `alignContent`  v = aligncontent )
                                   ( n = `backgroundDesign`  v = backgrounddesign )
                                   ( n = `displayInline`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayinline ) )
                                   ( n = `visible`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD flex_item_data.
    result = me.

    _generic( name   = `FlexItemData`
              t_prop = VALUE #( ( n = `growFactor`  v = growfactor )
                                ( n = `baseSize`   v = basesize )
                                ( n = `backgroundDesign`   v = backgrounddesign )
                                ( n = `styleClass`   v = styleclass )
                                ( n = `order`        v = order )
                                ( n = `shrinkFactor` v = shrinkfactor ) ) ).
  ENDMETHOD.

  METHOD footer.
    result = _generic( ns   = ns
                       name = `footer` ).
  ENDMETHOD.

  METHOD force_based_layout.
    result = _generic( name   = `ForceBasedLayout`
                       ns     = `nglayout`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `alpha`  v = alpha )
                                         ( n = `charge`  v = charge )
                                         ( n = `friction`  v = friction )
                                         ( n = `maximumDuration`  v = maximumduration ) ) ).
  ENDMETHOD.

  METHOD force_directed_layout.
    result = _generic( name   = `ForceDirectedLayout`
                       ns     = `nglayout`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `coolDownStep`  v = cooldownstep )
                                         ( n = `initialTemperature`  v = initialtemperature )
                                         ( n = `maxIterations`  v = maxiterations )
                                         ( n = `maxTime`  v = maxtime )
                                         ( n = `optimalDistanceConstant`  v = optimaldistanceconstant )
                                         ( n = `staticNodes`  v = staticnodes ) ) ).
  ENDMETHOD.

  METHOD formatted_text.
    result = me.
    _generic( name   = `FormattedText`
              t_prop = VALUE #( ( n = `htmlText` v = htmltext )
                                ( n = `convertedLinksDefaultTarget` v = convertedlinksdefaulttarget )
                                ( n = `convertLinksToAnchorTags` v = convertlinkstoanchortags )
                                ( n = `height` v = height )
                                ( n = `textAlign` v = textalign )
                                ( n = `textDirection` v = textdirection )
                                ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `width` v = width )
                                ( n = `class` v = class )
                                ( n = `id` v = id )
                                ( n = `controls` v = controls ) ) ).
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
    result = _generic(
        name   = `GanttChartWithTable`
        ns     = `gantt`
        t_prop = VALUE #(
            ( n = `id` v = id )
            ( n = `shapeSelectionMode` v = shapeselectionmode )
            ( n = `isConnectorDetailsVisible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( isconnectordetailsvisible ) ) ) ).
  ENDMETHOD.

  METHOD gantt_row_settings.
    result = _generic( name   = `GanttRowSettings`
                       ns     = `gantt`
                       t_prop = VALUE #( ( n = `rowId` v = rowid )
                                         ( n = `shapes1` v = shapes1 )
                                         ( n = `shapes2` v = shapes2 )
                                         ( n = `relationships` v = relationships ) ) ).
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

    result = _generic( name   = `GenericTag`
                       t_prop = VALUE #( ( n = `ariaLabelledBy`           v = arialabelledby )
                                         ( n = `class`        v = class )
                                         ( n = `design`          v = design )
                                         ( n = `status`  v = status )
                                         ( n = `id`  v = id )
                                         ( n = `press`  v = press )
                                         ( n = `text`   v = text )
                                         ( n = `valueState`   v = valuestate ) ) ).

  ENDMETHOD.

  METHOD generic_tile.

    result = _generic(
                 name   = `GenericTile`
                 ns     = ``
                 t_prop = VALUE #(
                     ( n = `class`      v = class )
                     ( n = `id`     v = id )
                     ( n = `header`     v = header )
                     ( n = `mode`     v = mode )
                     ( n = `additionalTooltip`     v = additionaltooltip )
                     ( n = `appShortcut`     v = appshortcut )
                     ( n = `backgroundColor`     v = backgroundcolor )
                     ( n = `backgroundImage`     v = backgroundimage )
                     ( n = `dropAreaOffset`     v = dropareaoffset )
                     ( n = `press`      v = press )
                     ( n = `frameType`  v = frametype )
                     ( n = `failedText`  v = failedtext )
                     ( n = `headerImage`  v = headerimage )
                     ( n = `scope`  v = scope )
                     ( n = `sizeBehavior`  v = sizebehavior )
                     ( n = `state`  v = state )
                     ( n = `systemInfo`  v = systeminfo )
                     ( n = `tileBadge`  v = tilebadge )
                     ( n = `tileIcon`  v = tileicon )
                     ( n = `url`  v = url )
                     ( n = `valueColor`  v = valuecolor )
                     ( n = `width`  v = width )
                     ( n = `wrappingType`  v = wrappingtype )
                     ( n = `imageDescription`  v = imagedescription )
                     ( n = `navigationButtonText`  v = navigationbuttontext )
                     ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `renderOnThemeChange`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( renderonthemechange ) )
                     ( n = `enableNavigationButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablenavigationbutton ) )
                     ( n = `pressEnabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( pressenabled ) )
                     ( n = `iconLoaded`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconloaded ) )
                     ( n = `subheader`  v = subheader ) ) ).

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
    result = mt_child[ index ].
  ENDMETHOD.

  METHOD get_parent.
    result = mo_parent.
  ENDMETHOD.

  METHOD get_root.
    result = mo_root.
  ENDMETHOD.

  METHOD grid.

    result = _generic(
                 name   = `Grid`
                 ns     = `layout`
                 t_prop = VALUE #( ( n = `defaultSpan`    v = default_span )
                                   ( n = `class`          v = class )
                                   ( n = `containerQuery` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( containerquery ) )
                                   ( n = `hSpacing`       v = hspacing )
                                   ( n = `vSpacing`       v = vspacing )
                                   ( n = `width`          v = width )
                                   ( n = `content`        v = content ) ) ).
  ENDMETHOD.

  METHOD grid_box_layout.
    result = me.
    _generic( name   = `GridBoxLayout`
              ns     = `grid`
              t_prop = VALUE #( ( n = `boxesPerRowConfig`   v = boxesperrowconfig )
                                ( n = `boxMinWidth`   v = boxminwidth )
                                ( n = `boxWidth`   v = boxwidth ) ) ).
  ENDMETHOD.

  METHOD grid_data.
    result = me.
    _generic( name   = `GridData`
              ns     = `layout`
              t_prop = VALUE #( ( n = `span`      v = span )
                                ( n = `linebreak` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( linebreak ) )
                                ( n = `indentL`   v = indentl )
                                ( n = `indentM`   v = indentm ) ) ).
  ENDMETHOD.

  METHOD grid_drop_info.
    result = me.
    _generic( name   = `GridDropInfo`
              ns     = `dnd-grid`
              t_prop = VALUE #( ( n = `targetAggregation`      v = targetaggregation )
                                ( n = `dropPosition` v = dropposition )
                                ( n = `dropLayout` v = droplayout )
                                ( n = `drop`   v = drop )
                                ( n = `dragEnter`   v = dragenter )
                                ( n = `dragOver`   v = dragover ) ) ).
  ENDMETHOD.

  METHOD grid_list.
    result = _generic(
                 name   = `GridList`
                 ns     = `f`
                 t_prop = VALUE #(
                     ( n = `id`      v = id )
                     ( n = `busy` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( busy ) )
                     ( n = `busyIndicatorDelay` v = busyindicatordelay )
                     ( n = `busyIndicatorSize` v = busyindicatorsize )
                     ( n = `enableBusyIndicator` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablebusyindicator ) )
                     ( n = `fieldGroupIds` v = fieldgroupids )
                     ( n = `footerText` v = footertext )
                     ( n = `growing` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
                     ( n = `growingDirection` v = growingdirection )
                     ( n = `growingScrollToLoad` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growingscrolltoload ) )
                     ( n = `growingThreshold` v = growingthreshold )
                     ( n = `growingTriggerText` v = growingtriggertext )
                     ( n = `headerLevel` v = headerlevel )
                     ( n = `headerText` v = headertext )
                     ( n = `includeItemInSelection` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( includeiteminselection ) )
                     ( n = `inset` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inset ) )
                     ( n = `keyboardMode` v = keyboardmode )
                     ( n = `mode` v = mode )
                     ( n = `modeAnimationOn` v = modeanimationon )
                     ( n = `multiSelectMode` v = multiselectmode )
                     ( n = `noDataText` v = nodatatext )
                     ( n = `rememberSelections` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rememberselections ) )
                     ( n = `showNoData` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownodata ) )
                     ( n = `showSeparators` v = showseparators )
                     ( n = `showUnread` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showunread ) )
                     ( n = `sticky` v = sticky )
                     ( n = `swipeDirection` v = swipedirection )
                     ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `width` v = width )
                     ( n = `items`   v = items ) ) ).
  ENDMETHOD.

  METHOD grid_list_item.
    result = _generic( name   = `GridListItem`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `busy`      v = busy )
                                         ( n = `busyIndicatorDelay` v = busyindicatordelay )
                                         ( n = `busyIndicatorSize` v = busyindicatorsize )
                                         ( n = `counter` v = counter )
                                         ( n = `fieldGroupIds` v = fieldgroupids )
                                         ( n = `highlight` v = highlight )
                                         ( n = `highlightText` v = highlighttext )
                                         ( n = `navigated` v = navigated )
                                         ( n = `selected` v = selected )
                                         ( n = `type` v = type )
                                         ( n = `unread` v = unread )
                                         ( n = `visible`   v = visible )
                                         ( n = `detailPress` v = detailpress )
                                         ( n = `detailTap` v = detailtap )
                                         ( n = `press` v = press )
                                         ( n = `tap` v = tap ) ) ).
  ENDMETHOD.

  METHOD group.
    result = _generic( name   = `group`
                       ns     = `networkgraph`
                       t_prop = VALUE #( ( n = `collapsed`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( collapsed ) )
                                         ( n = `id`       v = id )
                                         ( n = `class`       v = class )
                                         ( n = `description`       v = description )
                                         ( n = `headerCheckBoxState`        v = headercheckboxstate )
                                         ( n = `icon`      v = icon )
                                         ( n = `key`      v = key )
                                         ( n = `minWidth`      v = minwidth )
                                         ( n = `parentGroupKey`      v = parentgroupkey )
                                         ( n = `status`      v = status )
                                         ( n = `title`    v = title )
                                         ( n = `collapseExpand`    v = collapseexpand )
                                         ( n = `showDetail`    v = showdetail )
                                         ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `headerCheckBoxPress`  v = headercheckboxpress ) ) ).
  ENDMETHOD.

  METHOD groups.
    result = _generic( name = `groups`
                       ns   = SWITCH #( ns WHEN `` THEN `networkgraph` ELSE ns ) ).
  ENDMETHOD.

  METHOD group_items.
    result = _generic( `groupItems` ).
  ENDMETHOD.

  METHOD harvey_ball_micro_chart.

    result = _generic( name   = `HarveyBallMicroChart`
                       ns     = `mchart`
                       t_prop = VALUE #(
                           ( n = `colorPalette`  v = colorpalette )
                           ( n = `press`       v = press )
                           ( n = `size`        v = size )
                           ( n = `height`      v = height )
                           ( n = `width`      v = width )
                           ( n = `total`      v = total )
                           ( n = `totalLabel`      v = totallabel )
                           ( n = `alignContent`      v = aligncontent )
                           ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                           ( n = `formattedLabel`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( formattedlabel ) )
                           ( n = `showFractions`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfractions ) )
                           ( n = `showTotal`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtotal ) )
                           ( n = `totalScale`  v = totalscale ) ) ).
  ENDMETHOD.

  METHOD hbox.
    result = _generic(
        name   = `HBox`
        t_prop = VALUE #( ( n = `class`          v = class )
                          ( n = `alignContent`   v = aligncontent )
                          ( n = `alignItems`     v = alignitems )
                          ( n = `width`          v = width )
                          ( n = `id`          v = id )
                          ( n = `renderType`          v = rendertype )
                          ( n = `height`         v = height )
                          ( n = `wrap`           v = wrap )
                          ( n = `backgroundDesign`           v = backgrounddesign )
                          ( n = `direction`           v = direction )
                          ( n = `displayInline`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayinline ) )
                          ( n = `fitContainer`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( fitcontainer ) )
                          ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `justifyContent` v = justifycontent ) ) ).

  ENDMETHOD.

  METHOD header.
    result = _generic( name = `header`
                       ns   = ns ).
  ENDMETHOD.

  METHOD header_container.
    result = _generic( name   = `HeaderContainer`
                       t_prop = VALUE #( ( n = `scrollStep`     v = scrollstep )
                                         ( n = `scrollTime`     v = scrolltime )
                                         ( n = `orientation`    v = orientation )
                                         ( n = `height`         v = height ) ) ).
  ENDMETHOD.

  METHOD header_container_control.
    result = _generic(
                 name   = `HeaderContainer`
                 t_prop = VALUE #( ( n = `backgroundDesign` v = backgrounddesign )
                                   ( n = `gridLayout` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( gridlayout ) )
                                   ( n = `height` v = height )
                                   ( n = `orientation` v = orientation )
                                   ( n = `scrollStep` v = scrollstep )
                                   ( n = `scrollStepByItem` v = scrollstepbyitem )
                                   ( n = `scrollTime` v = scrolltime )
                                   ( n = `showDividers` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showdividers ) )
                                   ( n = `showOverflowItem` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showoverflowitem ) )
                                   ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `snapToRow` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( snaptorow ) )
                                   ( n = `width` v = width )
                                   ( n = `id` v = id )
                                   ( n = `scroll` v = scroll ) ) ).
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

    result = _generic( name = `heading`
                       ns   = ns ).

  ENDMETHOD.

  METHOD horizontal_layout.
    result = _generic(
                 name   = `HorizontalLayout`
                 ns     = `layout`
                 t_prop = VALUE #( ( n = `class`  v = class )
                                   ( n = `allowWrapping`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( allowwrapping ) )
                                   ( n = `id`  v = id )
                                   ( n = `visible`  v = visible ) ) ).
  ENDMETHOD.

  METHOD html.

    result = _generic( name   = `HTML`
                       ns     = `core`
                       t_prop = VALUE #(
                           ( n = `id` v = id )
                           ( n = `content` v = content )
                           ( n = `afterRendering` v = afterrendering )
                           ( n = `preferDOM` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( preferdom ) )
                           ( n = `sanitizeContent` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sanitizecontent ) )
                           ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD html_area.
    result = _generic( name   = `area`
                       ns     = `html`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `shape`  v = shape )
                                         ( n = `coords`  v = coords )
                                         ( n = `alt`     v = alt )
                                         ( n = `target` v = target )
                                         ( n = `href`  v = href )
                                         ( n = `onclick`  v = onclick ) ) ).
  ENDMETHOD.

  METHOD html_canvas.
    result = _generic( name   = `canvas`
                       ns     = `html`
                       t_prop = VALUE #( ( n = `id`     v = id )
                                         ( n = `class`  v = class )
                                         ( n = `width`  v = width )
                                         ( n = `height` v = height )
                                         ( n = `style`  v = style ) ) ).
  ENDMETHOD.

  METHOD html_map.
    result = _generic( name   = `map`
                       ns     = `html`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `name`  v = name ) ) ).
  ENDMETHOD.

  METHOD icon.

    result = me.
    _generic( name   = `Icon`
              ns     = `core`
              t_prop = VALUE #( ( n = `size`  v = size )
                                ( n = `color`  v = color )
                                ( n = `class`  v = class )
                                ( n = `src`  v = src )
                                ( n = `activeColor`  v = activecolor )
                                ( n = `activeBackgroundColor`  v = activebackgroundcolor )
                                ( n = `alt`  v = alt )
                                ( n = `backgroundColor`  v = backgroundcolor )
                                ( n = `height`  v = height )
                                ( n = `width`  v = width )
                                ( n = `id`  v = id )
                                ( n = `press`  v = press )
                                ( n = `hoverBackgroundColor`  v = hoverbackgroundcolor )
                                ( n = `hoverColor`  v = hovercolor )
                                ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `decorative`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( decorative ) )
                                ( n = `noTabStop`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( notabstop ) )
                                ( n = `useIconTooltip`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( useicontooltip ) ) ) ).

  ENDMETHOD.

  METHOD icon_tab_bar.

    result = _generic(
                 name   = `IconTabBar`
                 t_prop = VALUE #(
                     ( n = `class`       v = class )
                     ( n = `select`      v = select )
                     ( n = `expand`      v = expand )
                     ( n = `expandable`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( expandable ) )
                     ( n = `expanded`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( expanded ) )
                     ( n = `applyContentPadding`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( applycontentpadding ) )
                     ( n = `backgroundDesign`    v = backgrounddesign )
                     ( n = `enableTabReordering`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabletabreordering ) )
                     ( n = `headerBackgroundDesign`    v = headerbackgrounddesign )
                     ( n = `stretchContentHeight`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( stretchcontentheight ) )
                     ( n = `headerMode`    v = headermode )
                     ( n = `maxNestingLevel`    v = maxnestinglevel )
                     ( n = `tabDensityMode`    v = tabdensitymode )
                     ( n = `tabsOverflowMode`    v = tabsoverflowmode )
                     ( n = `items`    v = items )
                     ( n = `id`    v = id )
                     ( n = `content`    v = content )
                     ( n = `upperCase`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( uppercase ) )
                     ( n = `selectedKey` v = selectedkey ) ) ).
  ENDMETHOD.

  METHOD icon_tab_filter.

    result = _generic(
        name   = `IconTabFilter`
        t_prop = VALUE #( ( n = `icon`        v = icon )
                          (  n = `items`    v = items )
                          (  n = `design`    v = design )
                          ( n = `iconColor`   v = iconcolor )
                          ( n = `showAll`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showall ) )
                          ( n = `iconDensityAware`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                          ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `count`       v = count )
                          ( n = `text`        v = text )
                          ( n = `id`        v = id )
                          ( n = `textDirection`        v = textdirection )
                          ( n = `class`        v = class )
                          ( n = `key`         v = key ) ) ).
  ENDMETHOD.

  METHOD icon_tab_header.

    result = _generic(
        name   = `IconTabHeader`
        t_prop = VALUE #(
            (  n = `selectedKey`     v = selectedkey )
            (  n = `items`           v = items )
            (  n = `select`          v = select )
            (  n = `ariaTexts`          v = ariatexts )
            (  n = `backgroundDesign`          v = backgrounddesign )
            (  n = `enableTabReordering`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabletabreordering ) )
            (  n = `maxNestingLevel`          v = maxnestinglevel )
            (  n = `tabDensityMode`          v = tabdensitymode )
            (  n = `tabsOverflowMode`          v = tabsoverflowmode )
            (  n = `id`          v = id )
            (  n = `visible`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            (  n = `mode`            v = mode ) ) ).

  ENDMETHOD.

  METHOD icon_tab_separator.

    result = _generic( name   = `IconTabSeparator`
                       t_prop = VALUE #( ( n = `icon` v = icon )
                                         ( n = `iconDensityAware` v = icondensityaware )
                                         ( n = `id` v = id )
                                         ( n = `class` v = class )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD illustrated_message.

    result = _generic(
        name   = `IllustratedMessage`
        t_prop = VALUE #(
            ( n = `enableVerticalResponsiveness` v = enableverticalresponsiveness )
            ( n = `illustrationType`             v = illustrationtype )
            ( n = `enableFormattedText`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableformattedtext ) )
            ( n = `illustrationSize`             v = illustrationsize )
            ( n = `description`             v = description )
            ( n = `title`             v = title ) ) ).
  ENDMETHOD.

  METHOD image.
    result = me.
    _generic( name   = `Image`
              t_prop = VALUE #( ( n = `id` v = id )
                                ( n = `src` v = src )
                                ( n = `class` v = class )
                                ( n = `height` v = height )
                                ( n = `alt` v = alt )
                                ( n = `activeSrc` v = activesrc )
                                ( n = `ariaHasPopup` v = ariahaspopup )
                                ( n = `backgroundPosition` v = backgroundposition )
                                ( n = `backgroundRepeat` v = backgroundrepeat )
                                ( n = `backgroundSize` v = backgroundsize )
                                ( n = `mode` v = mode )
                                ( n = `useMap` v = usemap )
                                ( n = `width` v = width )
                                ( n = `error` v = error )
                                ( n = `press` v = press )
                                ( n = `load` v = load )
                                ( n = `decorative` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( decorative ) )
                                ( n = `densityAware` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( densityaware ) )
                                ( n = `lazyLoading` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( lazyloading ) ) ) ).
  ENDMETHOD.

  METHOD image_content.

    result = _generic( name   = `ImageContent`
                       t_prop = VALUE #( ( n = `src` v = src )
                                         ( n = `description` v = description )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `class` v = class )
                                         ( n = `press` v = press ) ) ).

  ENDMETHOD.

  METHOD info_label.
    result = _generic( name   = `InfoLabel`
                       ns     = `tnt`
                       t_prop = VALUE #(
                           ( n = `id`               v = id )
                           ( n = `class`               v = class )
                           ( n = `text`             v = text )
                           ( n = `renderMode `      v = rendermode )
                           ( n = `colorScheme`      v = colorscheme )
                           ( n = `displayOnly`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayonly ) )
                           ( n = `icon`             v = icon )
                           ( n = `textDirection`    v = textdirection )
                           ( n = `visible`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                           ( n = `width`            v = width ) ) ).

  ENDMETHOD.

  METHOD input.
    result = me.
    _generic(
        name   = `Input`
        t_prop = VALUE #(
            ( n = `id`               v = id )
            ( n = `placeholder`      v = placeholder )
            ( n = `type`             v = type )
            ( n = `maxLength`        v = maxlength )
            ( n = `showClearIcon`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearicon ) )
            ( n = `description`      v = description )
            ( n = `editable`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
            ( n = `enabled`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
            ( n = `visible`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            ( n = `enableTableAutoPopinMode` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabletableautopopinmode ) )
            ( n = `enableSuggestionsHighlighting`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablesuggestionshighlighting ) )
            ( n = `showTableSuggestionValueHelp`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtablesuggestionvaluehelp ) )
            ( n = `valueState`       v = valuestate )
            ( n = `valueStateText`   v = valuestatetext )
            ( n = `value`            v = value )
            ( n = `required`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
            ( n = `suggest`          v = suggest )
            ( n = `suggestionItems`  v = suggestionitems )
            ( n = `suggestionRows`   v = suggestionrows )
            ( n = `showSuggestion`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsuggestion ) )
            ( n = `valueHelpRequest` v = valuehelprequest )
            ( n = `autocomplete`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autocomplete ) )
            ( n = `valueLiveUpdate`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( valueliveupdate ) )
            ( n = `submit`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( submit ) )
            ( n = `showValueHelp`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluehelp ) )
            ( n = `valueHelpOnly`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( valuehelponly ) )
            ( n = `class`            v = class )
            ( n = `change`            v = change )
            ( n = `maxSuggestionWidth` v = maxsuggestionwidth )
            ( n = `width`             v = width )
            ( n = `textFormatter`     v = textformatter )
            ( n = `startSuggestion`     v = startsuggestion )
            ( n = `valueHelpIconSrc` v = valuehelpiconsrc )
            ( n = `textFormatMode`  v = textformatmode )
            ( n = `fieldWidth`          v = fieldwidth )
            ( n = `ariaLabelledBy`      v = arialabelledby )
            ( n = `ariaDescribedBy`     v = ariadescribedby )
            ( n = `name`                 v = name )
            ( n = `textAlign`            v = textalign )
            ( n = `textDirection`        v = textdirection )
            ( n = `showValueStateMessage` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) ) ) ).
  ENDMETHOD.

  METHOD input_list_item.
    result = _generic( name   = `InputListItem`
                       t_prop = VALUE #( ( n = `label` v = label ) ) ).
  ENDMETHOD.

  METHOD interact_bar_chart.
    result = _generic(
        name   = `InteractiveBarChart`
        ns     = `mchart`
        t_prop = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                          ( n = `selectionEnabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selectionenabled ) )
                          ( n = `showError`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showerror ) )
                          ( n = `press`             v = press )
                          ( n = `labelWidth`        v = labelwidth )
                          ( n = `bars`              v = bars )
                          ( n = `errorMessageTitle` v = errormessagetitle )
                          ( n = `displayedBars`     v = displayedbars )
                          ( n = `min`     v = min )
                          ( n = `max`     v = max )
                          ( n = `errorMessage`      v = errormessage ) ) ).
  ENDMETHOD.

  METHOD interact_bar_chart_bar.
    result = _generic( name   = `InteractiveBarChartBar`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `label`          v = label )
                                         ( n = `displayedValue` v = displayedvalue )
                                         ( n = `value`          v = value )
                                         ( n = `selected`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                         ( n = `color`          v = color ) ) ).
  ENDMETHOD.

  METHOD interact_donut_chart.
    result = _generic(
        name   = `InteractiveDonutChart`
        ns     = `mchart`
        t_prop = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                          ( n = `selectionEnabled`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selectionenabled ) )
                          ( n = `showError`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showerror ) )
                          ( n = `errorMessageTitle` v = errormessagetitle )
                          ( n = `errorMessage`      v = errormessage )
                          ( n = `displayedSegments` v = displayedsegments )
                          ( n = `segments` v = segments )
                          ( n = `press`             v = press ) ) ).
  ENDMETHOD.

  METHOD interact_donut_chart_segment.
    result = _generic( name   = `InteractiveDonutChartSegment`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `label`          v = label )
                                         ( n = `displayedValue` v = displayedvalue )
                                         ( n = `value`          v = value )
                                         ( n = `selected`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                         ( n = `color`          v = color ) ) ).
  ENDMETHOD.

  METHOD interact_line_chart.
    result = _generic( name   = `InteractiveLineChart`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                                         ( n = `showError`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showerror ) )
                                         ( n = `press`             v = press )
                                         ( n = `errorMessageTitle` v = errormessagetitle )
                                         ( n = `errorMessage`      v = errormessage )
                                         ( n = `precedingPoint`    v = precedingpoint )
                                         ( n = `points`            v = points )
                                         ( n = `succeedingPoint`   v = succeedingpoint )
                                         ( n = `displayedPoints`   v = displayedpoints )
                                         ( n = `selectionEnabled`  v = selectionenabled ) ) ).
  ENDMETHOD.

  METHOD interact_line_chart_point.
    result = _generic(
                 name   = `InteractiveLineChartPoint`
                 ns     = `mchart`
                 t_prop = VALUE #( ( n = `label`          v = label )
                                   ( n = `secondaryLabel` v = secondarylabel )
                                   ( n = `value`          v = value )
                                   ( n = `displayedValue` v = displayedvalue )
                                   ( n = `selected`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) ) ) ).
  ENDMETHOD.

  METHOD intermediary.
    result = _generic( name = `intermediary`
                       ns   = `commons` ).
  ENDMETHOD.

  METHOD interval_headers.
    result = _generic( `intervalHeaders` ).
  ENDMETHOD.

  METHOD item.
    result = me.
    _generic( name   = `Item`
              ns     = `core`
              t_prop = VALUE #( ( n = `key`  v = key )
                                ( n = `text` v = text ) ) ).
  ENDMETHOD.

  METHOD items.
    result = _generic( name = `items`
                       ns   = ns ).
  ENDMETHOD.

  METHOD label.
    result = me.
    _generic( name   = `Label`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `displayOnly`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayonly ) )
                                ( n = `required`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                                ( n = `showColon`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcolon ) )
                                ( n = `textAlign`   v = textalign )
                                ( n = `textDirection`   v = textdirection )
                                ( n = `vAlign`   v = valign )
                                ( n = `width`   v = width )
                                ( n = `wrapping`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                                ( n = `wrappingType`   v = wrappingtype )
                                ( n = `design`   v = design )
                                ( n = `id`   v = id )
                                ( n = `class`   v = class )
                                ( n = `labelFor` v = labelfor )
                                ( n = `visible`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD lanes.
    result = _generic( name = `lanes`
                       ns   = `commons` ).
  ENDMETHOD.

  METHOD layered_layout.
    result = _generic( name   = `LayeredLayout`
                       ns     = `nglayout`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `lineSpacingFactor`  v = linespacingfactor )
                                         ( n = `nodePlacement`  v = nodeplacement )
                                         ( n = `nodeSpacing`  v = nodespacing )
                                         ( n = `mergeEdges`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( mergeedges ) ) ) ).
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

    result = _generic( name   = `Legend`
                       ns     = `vbm`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `caption`  v = caption )
                                         ( n = `items`  v = items ) ) ).

  ENDMETHOD.

  METHOD legenditem.

    result = _generic( name   = `LegendItem`
                       ns     = `vbm`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `text`  v = text )
                                         ( n = `color`  v = color ) ) ).

  ENDMETHOD.

  METHOD legend_area.

    result = _generic( name = `legend`
                       ns   = `vbm` ).

  ENDMETHOD.

  METHOD library_shape.
    result = _generic(
        name   = `LibraryShape`
        ns     = `si`
        t_prop = VALUE #( ( n = `id`       v = id )
                          ( n = `class`    v = class )
                          ( n = `animationOnChange`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( animationonchange ) )
                          ( n = `definition`     v = definition )
                          ( n = `fillColor`     v = fillcolor )
                          ( n = `fillingAngle`     v = fillingangle )
                          ( n = `fillingDirection`     v = fillingdirection )
                          ( n = `fillingType`     v = fillingtype )
                          ( n = `height`     v = height )
                          ( n = `horizontalAlignment`     v = horizontalalignment )
                          ( n = `shapeId`     v = shapeid )
                          ( n = `strokeColor`     v = strokecolor )
                          ( n = `strokeWidth`     v = strokewidth )
                          ( n = `verticalAlignment`     v = verticalalignment )
                          ( n = `width`     v = width )
                          ( n = `x`     v = x )
                          ( n = `y`     v = y )
                          ( n = `afterShapeLoaded`     v = aftershapeloaded )
                          ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.

  METHOD light_box.
    result = _generic( name   = `LightBox`
                       t_prop = VALUE #( ( n = `id`         v = id )
                                         ( n = `class`    v = class )
                                         ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD light_box_item.
    result = _generic( name   = `LightBoxItem`
                       t_prop = VALUE #( ( n = `alt`         v = alt )
                                         ( n = `imageSrc`    v = imagesrc )
                                         ( n = `subtitle`    v = subtitle )
                                         ( n = `title`       v = title ) ) ).
  ENDMETHOD.

  METHOD line.

    result = _generic( name   = `Line`
                       ns     = `networkgraph`
                       t_prop = VALUE #(
                           ( n = `id`  v = id )
                           ( n = `class`  v = class )
                           ( n = `arrowOrientation`  v = arroworientation )
                           ( n = `arrowPosition`         v = arrowposition )
                           ( n = `description`  v = description )
                           ( n = `from`             v = from )
                           ( n = `lineType`        v = linetype )
                           ( n = `status`         v = status )
                           ( n = `title`       v = title )
                           ( n = `to`        v = to )
                           ( n = `hover`        v = hover )
                           ( n = `press`        v = press )
                           ( n = `stretchToCenter`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( stretchtocenter ) )
                           ( n = `selected`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                           ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD lines.
    result = _generic( name = `lines`
                       ns   = SWITCH #( ns WHEN `` THEN `networkgraph` ELSE ns ) ).
  ENDMETHOD.

  METHOD line_micro_chart.
    result = me.
    _generic(
        name   = `LineMicroChart`
        ns     = `mchart`
        t_prop = VALUE #( ( n = `color`  v = color )
                          ( n = `height`       v = height )
                          ( n = `leftBottomLabel`        v = leftbottomlabel )
                          ( n = `leftTopLabel`      v = lefttoplabel )
                          ( n = `maxXValue`      v = maxxvalue )
                          ( n = `minXValue`      v = minxvalue )
                          ( n = `minYValue`      v = minyvalue )
                          ( n = `rightBottomLabel`      v = rightbottomlabel )
                          ( n = `rightTopLabel`      v = righttoplabel )
                          ( n = `size`      v = size )
                          ( n = `threshold`      v = threshold )
                          ( n = `thresholdDisplayValue`      v = thresholddisplayvalue )
                          ( n = `width`      v = width )
                          ( n = `press`      v = press )
                          ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                          ( n = `showBottomLabels`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbottomlabels ) )
                          ( n = `showPoints`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showpoints ) )
                          ( n = `showThresholdLine`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showthresholdline ) )
                          ( n = `showThresholdValue`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showthresholdvalue ) )
                          ( n = `showTopLabels`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtoplabels ) )
                          ( n = `maxYValue`  v = maxyvalue ) ) ).
  ENDMETHOD.

  METHOD line_micro_chart_empszd_point.
    result = _generic( name   = `LineMicroChartEmphasizedPoint`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `x`       v = x )
                                         ( n = `y`       v = y )
                                         ( n = `color`       v = color )
                                         ( n = `show`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( show ) )
                                       ) ).
  ENDMETHOD.

  METHOD line_micro_chart_line.
    result = _generic( name   = `LineMicroChartLine`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `points`       v = points )
                                         ( n = `color`    v = color )
                                         ( n = `type`  v = type )
                                        ) ).
  ENDMETHOD.

  METHOD line_micro_chart_point.
    result = _generic( name   = `LineMicroChartPoint`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `x`       v = x )
                                         ( n = `y`       v = y )
                                       ) ).
  ENDMETHOD.

  METHOD link.
    result = me.
    _generic( name   = `Link`
              ns     = ns
              t_prop = VALUE #( ( n = `text`    v = text )
                                ( n = `target`  v = target )
                                ( n = `href`    v = href )
                                ( n = `press`   v = press )
                                ( n = `id`      v = id )
                                ( n = `class`      v = class )
                                ( n = `accessibleRole`      v = accessiblerole )
                                ( n = `ariaHasPopup`      v = ariahaspopup )
                                ( n = `emptyIndicatorMode`      v = emptyindicatormode )
                                ( n = `rel`      v = rel )
                                ( n = `subtle`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( subtle ) )
                                ( n = `textAlign`      v = textalign )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `validateUrl`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( validateurl ) )
                                ( n = `width`      v = width )
                                ( n = `wrapping`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                                ( n = `emphasized`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( emphasized ) )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `endIcon` v = endicon )
                                ( n = `icon`    v = icon ) ) ).
  ENDMETHOD.

  METHOD link_tile_content.
    result = _generic( name   = `LinkTileContent`
                       t_prop = VALUE #( ( n = `iconSrc`  v = iconsrc )
                                         ( n = `linkHref`  v = linkhref )
                                         ( n = `linkText`  v = linktext )
                                         ( n = `linkPress`  v = linkpress ) ) ).
  ENDMETHOD.

  METHOD list.
    result = _generic(
                 name   = `List`
                 t_prop = VALUE #(
                     ( n = `headerText`             v = headertext )
                     ( n = `items`                  v = items )
                     ( n = `mode`                   v = mode )
                     ( n = `class`                   v = class )
                     ( n = `itemPress`                   v = itempress )
                     ( n = `select`                   v = select )
                     ( n = `selectionChange`        v = selectionchange )
                     ( n = `showSeparators`         v = showseparators )
                     ( n = `footerText`             v = footertext )
                     ( n = `growingDirection`       v = growingdirection )
                     ( n = `growingThreshold`       v = growingthreshold )
                     ( n = `growingTriggerText`     v = growingtriggertext )
                     ( n = `headerLevel`            v = headerlevel )
                     ( n = `multiSelectMode`        v = multiselectmode )
                     ( n = `noDataText`             v = nodatatext )
                     ( n = `id`                     v = id )
                     ( n = `sticky`                 v = sticky )
                     ( n = `delete`                 v = delete )
                     ( n = `backgroundDesign`                 v = backgrounddesign )
                     ( n = `modeAnimationOn`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( modeanimationon ) )
                     ( n = `growingScrollToLoad`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growingscrolltoload ) )
                     ( n = `includeItemInSelection` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( includeiteminselection ) )
                     ( n = `growing`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
                     ( n = `inset`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inset ) )
                     ( n = `rememberSelections`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rememberselections ) )
                     ( n = `showUnread`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showunread ) )
                     ( n = `visible`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `noData`                 v = nodata ) ) ).
  ENDMETHOD.

  METHOD list_item.
    result = me.
    _generic( name   = `ListItem`
              ns     = `core`
              t_prop = VALUE #( ( n = `text` v = text )
                                ( n = `icon` v = icon )
                                ( n = `key`  v = key )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `enabled`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `additionalText` v = additionaltext ) ) ).
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

    result = _generic( name   = `MapContainer`
                       ns     = `vk`
                       t_prop = VALUE #(
                           ( n = `id`  v = id )
                           ( n = `autoAdjustHeight`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autoadjustheight ) )
                           ( n = `showHome`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showhome ) ) ) ).

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
    result = me.
    _generic( name   = `MaskInput`
              t_prop = VALUE #(
                  ( n = `placeholder`           v = placeholder )
                  ( n = `mask`                  v = mask )
                  ( n = `name`                  v = name )
                  ( n = `textAlign`             v = textalign )
                  ( n = `textDirection`         v = textdirection )
                  ( n = `value`                 v = value )
                  ( n = `width`                 v = width )
                  ( n = `liveChange`            v = livechange )
                  ( n = `change`                v = change )
                  ( n = `valueState`            v = valuestate )
                  ( n = `valueStateText`        v = valuestatetext )
                  ( n = `placeholderSymbol`     v = placeholdersymbol )
                  ( n = `required`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                  ( n = `showClearIcon`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearicon ) )
                  ( n = `showValueStateMessage` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
                  ( n = `visible`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                  ( n = `fieldWidth`            v = fieldwidth ) ) ).
  ENDMETHOD.

  METHOD mask_input_rule.
    result = _generic( name   = `MaskInputRule`
                       t_prop = VALUE #( ( n = `maskFormatSymbol` v = maskformatsymbol )
                                         ( n = `regex`            v = regex ) ) ).
  ENDMETHOD.

  METHOD master_pages.
    result = _generic( `masterPages` ).
  ENDMETHOD.

  METHOD menu_button.
    result = _generic( name   = `MenuButton`
                       t_prop = VALUE #( ( n = `buttonMode`    v = buttonmode )
                                         ( n = `defaultAction` v = defaultaction )
                                         ( n = `text`          v = text )
                                         ( n = `enabled`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `activeIcon`    v = activeicon )
                                         ( n = `type`          v = type ) ) ).
  ENDMETHOD.

  METHOD menu.
    result = _generic( name   = `Menu`
                       t_prop = VALUE #( ( n = `id`           v = id )
                                         ( n = `title`        v = title )
                                         ( n = `itemSelected` v = itemselected )
                                         ( n = `closed`       v = closed ) ) ).
  ENDMETHOD.

  METHOD menu_item.
    result = me.
    _generic( name   = `MenuItem`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `icon`    v = icon ) ) ).
  ENDMETHOD.

  METHOD message_item.
    result = _generic(
        name   = `MessageItem`
        t_prop = VALUE #( ( n = `type`                v = type )
                          ( n = `title`               v = title )
                          ( n = `subtitle`            v = subtitle )
                          ( n = `description`         v = description )
                          ( n = `longtextUrl`         v = longtexturl )
                          ( n = `textDirection`       v = textdirection )
                          ( n = `groupName`           v = groupname )
                          ( n = `activeTitle`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( activetitle ) )
                          ( n = `counter`             v = counter )
                          ( n = `markupDescription`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( markupdescription ) ) ) ).
  ENDMETHOD.

  METHOD message_page.
    result = _generic(
                 name   = `MessagePage`
                 t_prop = VALUE #(
                     ( n = `showHeader`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( show_header ) )
                     ( n = `description`         v = description )
                     ( n = `icon`                v = icon )
                     ( n = `text`                v = text )
                     ( n = `enableFormattedText` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableformattedtext ) ) ) ).
  ENDMETHOD.

  METHOD message_popover.
    result = _generic(
        name   = `MessagePopover`
        t_prop = VALUE #( ( n = `items`             v = items )
                          ( n = `activeTitlePress`  v = activetitlepress )
                          ( n = `placement`         v = placement )
                          ( n = `listSelect`        v = listselect )
                          ( n = `afterClose`        v = afterclose )
                          ( n = `beforeClose`       v = beforeclose )
                          ( n = `initiallyExpanded` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( initiallyexpanded ) )
                          ( n = `groupItems`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.

  METHOD message_strip.
    result = me.
    _generic(
        name   = `MessageStrip`
        t_prop = VALUE #( ( n = `text`     v = text )
                          ( n = `type`     v = type )
                          ( n = `showIcon` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showicon ) )
                          ( n = `customIcon`       v = customicon )
                          ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `showCloseButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclosebutton ) )
                          ( n = `class`    v = class )
                          ( n = `enableFormattedText`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableformattedtext ) ) ) ).
  ENDMETHOD.

  METHOD message_view.

    result = _generic( name   = `MessageView`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.

  METHOD micro_process_flow.
    result = _generic( name   = `MicroProcessFlow`
                       ns     = `commons`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `renderType`    v = rendertype )
                                         ( n = `width`    v = width )
                                         ( n = `ariaLabel`    v = arialabel )
                                      ) ).
  ENDMETHOD.

  METHOD micro_process_flow_item.
    result = _generic(
        name   = `MicroProcessFlowItem`
        ns     = `commons`
        t_prop = VALUE #( ( n = `id`       v = id )
                          ( n = `class`    v = class )
                          ( n = `press`    v = press )
                          ( n = `title`    v = title )
                          ( n = `stepWidth`    v = stepwidth )
                          ( n = `state`    v = state )
                          ( n = `key`    v = key )
                          ( n = `icon`    v = icon )
                          ( n = `showSeparator`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showseparator ) )
                          ( n = `showIntermediary`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showintermediary ) )
                       ) ).
  ENDMETHOD.

  METHOD mid_column_pages.

    result = _generic( name   = `midColumnPages`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id` v = id ) ) ).

  ENDMETHOD.

  METHOD multi_combobox.
    result = _generic(
        name   = `MultiComboBox`
        t_prop = VALUE #(
            (  n = `selectionChange`     v = selectionchange )
            (  n = `selectedKeys`        v = selectedkeys )
            (  n = `selectedItems`        v = selecteditems )
            (  n = `items`               v = items )
            (  n = `id`                  v = id )
            (  n = `class`               v = class )
            (  n = `selectionFinish`     v = selectionfinish )
            (  n = `width`               v = width )
            (  n = `showSecondaryValues` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsecondaryvalues ) )
            (  n = `placeholder`         v = placeholder )
            (  n = `selectedItemId`         v = selecteditemid )
            (  n = `selectedKey`         v = selectedkey )
            (  n = `name`                v = name )
            (  n = `value`                v = value )
            (  n = `valueState`                v = valuestate )
            (  n = `valueStateText`                v = valuestatetext )
            (  n = `textAlign`                v = textalign )
            (  n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            (  n = `showValueStateMessage`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
            (  n = `showClearIcon`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearicon ) )
            (  n = `showButton`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbutton ) )
            (  n = `required`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
            (  n = `editable`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
            (  n = `enabled`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
            (  n = `filterSecondaryValues`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( filtersecondaryvalues ) )
            (  n = `showSelectAll`       v = showselectall ) ) ).
  ENDMETHOD.

  METHOD multi_input.
    result = _generic(
        name   = `MultiInput`
        t_prop = VALUE #( ( n = `tokens` v = tokens )
                          ( n = `showClearIcon` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearicon ) )
                          ( n = `name` v = name )
                          ( n = `valueHelpOnly` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( valuehelponly ) )
                          ( n = `showValueHelp` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluehelp ) )
                          ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                          ( n = `suggestionItems` v = suggestionitems )
                          ( n = `tokenUpdate` v = tokenupdate )
                          ( n = `submit` v = submit )
                          ( n = `width` v = width )
                          ( n = `value` v = value )
                          ( n = `id` v = id )
                          ( n = `change` v = change )
                          ( n = `valueHelpRequest` v = valuehelprequest )
                          ( n = `class` v = class )
                          ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `required` v = required )
                          ( n = `valueState` v = valuestate )
                          ( n = `valueStateText` v = valuestatetext )
                          ( n = `placeholder` v = placeholder )
                          ( n = `showSuggestion` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsuggestion ) ) ) ).
  ENDMETHOD.

  METHOD navigation_actions.
    result = _generic( name = `navigationActions`
                       ns   = `f` ).
  ENDMETHOD.

  METHOD nav_container.

    result = _generic( name   = `NavContainer`
                       t_prop = VALUE #( ( n = `initialPage`  v = initialpage )
                                         ( n = `id`           v = id )
                                         ( n = `height`           v = height )
                                         ( n = `width`           v = width )
                                         ( n = `autoFocus` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autofocus ) )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `defaultTransitionName`   v = defaulttransitionname ) ) ).

  ENDMETHOD.

  METHOD network_graph.
    result = _generic( name   = `Graph`
                       ns     = `networkgraph`
                       t_prop = VALUE #(
                           ( n = `id`  v = id )
                           ( n = `class`  v = class )
                           ( n = `layout`  v = layout )
                           ( n = `height`  v = height )
                           ( n = `width`  v = width )
                           ( n = `nodes`  v = nodes )
                           ( n = `lines`  v = lines )
                           ( n = `groups`  v = groups )
                           ( n = `backgroundColor`  v = backgroundcolor )
                           ( n = `backgroundImage`  v = backgroundimage )
                           ( n = `noDataText`  v = nodatatext )
                           ( n = `orientation`  v = orientation )
                           ( n = `renderType`  v = rendertype )
                           ( n = `afterLayouting`  v = afterlayouting )
                           ( n = `beforeLayouting`  v = beforelayouting )
                           ( n = `failure`  v = failure )
                           ( n = `graphReady`  v = graphready )
                           ( n = `search`  v = search )
                           ( n = `searchSuggest`  v = searchsuggest )
                           ( n = `selectionChange`  v = selectionchange )
                           ( n = `zoomChanged`  v = zoomchanged )
                           ( n = `enableWheelZoom`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablewheelzoom ) )
                           ( n = `enableZoom`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablezoom ) )
                           ( n = `noData`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( nodata ) )
                           ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD node.
    result = _generic(
        name   = `Node`
        ns     = `networkgraph`
        t_prop = VALUE #(
            ( n = `id`  v = id )
            ( n = `class`  v = class )
            ( n = `altText`  v = alttext )
            ( n = `coreNodeSize`         v = corenodesize )
            ( n = `description`  v = description )
            ( n = `descriptionLineSize`  v = descriptionlinesize )
            ( n = `group`             v = group )
            ( n = `headerCheckBoxState`        v = headercheckboxstate )
            ( n = `height`         v = height )
            ( n = `icon`       v = icon )
            ( n = `iconSize`        v = iconsize )
            ( n = `key` v = key )
            ( n = `maxWidth` v = maxwidth )
            ( n = `title` v = title )
            ( n = `shape` v = shape )
            ( n = `statusIcon` v = statusicon )
            ( n = `titleLineSize` v = titlelinesize )
            ( n = `width` v = width )
            ( n = `x` v = x )
            ( n = `y` v = y )
            ( n = `attributes` v = attributes )
            ( n = `actionButtons` v = actionbuttons )
            ( n = `collapseExpand` v = collapseexpand )
            ( n = `headerCheckBoxPress` v = headercheckboxpress )
            ( n = `hover` v = hover )
            ( n = `press` v = press )
            ( n = `collapsed`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( collapsed ) )
            ( n = `selected`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
            ( n = `showActionLinksButton`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showactionlinksbutton ) )
            ( n = `showDetailButton`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showdetailbutton ) )
            ( n = `showExpandButton`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showexpandbutton ) )
            ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD nodes.
    result = _generic( name = `nodes`
                       ns   = ns ).
  ENDMETHOD.

  METHOD node_image.
    result = _generic( name   = `NodeImage`
                       ns     = `networkgraph`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `height`  v = height )
                                         ( n = `width`  v = width )
                                         ( n = `src`  v = src ) ) ).
  ENDMETHOD.

  METHOD noop_layout.
    result = _generic( name = `NoopLayout`
                       ns   = `nglayout` ).
  ENDMETHOD.

  METHOD notification_list.
    result = _generic(
        name   = `NotificationList`
        t_prop = VALUE #(
            ( n = `id`  v = id )
            ( n = `class`  v = class )
            ( n = `footerText`  v = footertext )
            ( n = `growingDirection`  v = growingdirection )
            ( n = `growingThreshold`  v = growingthreshold )
            ( n = `growingTriggerText`  v = growingtriggertext )
            ( n = `headerLevel`  v = headerlevel )
            ( n = `headerText`  v = headertext )
            ( n = `keyboardMode`  v = keyboardmode )
            ( n = `mode`  v = mode )
            ( n = `multiSelectMode`  v = multiselectmode )
            ( n = `noDataText`  v = nodatatext )
            ( n = `sticky`  v = sticky )
            ( n = `swipeDirection`  v = swipedirection )
            ( n = `width`  v = width )
            ( n = `showSeparators`  v = showseparators )
            ( n = `beforeOpenContextMenu`  v = beforeopencontextmenu )
            ( n = `delete`  v = delete )
            ( n = `growingFinished`  v = growingfinished )
            ( n = `growingStarted`  v = growingstarted )
            ( n = `itemPress`  v = itempress )
            ( n = `select`  v = select )
            ( n = `selectionChange`  v = selectionchange )
            ( n = `swipe`  v = swipe )
            ( n = `updateFinished`  v = updatefinished )
            ( n = `updateStarted`  v = updatestarted )
            ( n = `growingScrollToLoad`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growingscrolltoload ) )
            ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            ( n = `growing`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
            ( n = `includeItemInSelection`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( includeiteminselection ) )
            ( n = `inset`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inset ) )
            ( n = `modeAnimationOn`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( modeanimationon ) )
            ( n = `rememberSelections`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rememberselections ) )
            ( n = `showNoData`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownodata ) )
            ( n = `showUnread`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showunread ) ) ) ).
  ENDMETHOD.

  METHOD notification_list_group.
    result = _generic(
                 name   = `NotificationListGroup`
                 t_prop = VALUE #(
                     ( n = `id`  v = id )
                     ( n = `class`  v = class )
                     ( n = `highlight`  v = highlight )
                     ( n = `highlightText`  v = highlighttext )
                     ( n = `priority`  v = priority )
                     ( n = `title`  v = title )
                     ( n = `type`  v = type )
                     ( n = `onCollapse`  v = oncollapse )
                     ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `autoPriority`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autopriority ) )
                     ( n = `collapsed`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( collapsed ) )
                     ( n = `enableCollapseButtonWhenEmpty`
                       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecollapsebuttonwhenempty ) )
                     ( n = `navigated`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( navigated ) )
                     ( n = `selected`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                     ( n = `showButtons`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbuttons ) )
                     ( n = `showCloseButton`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclosebutton ) )
                     ( n = `showEmptyGroup`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showemptygroup ) )
                     ( n = `showItemsCounter`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showitemscounter ) )
                     ( n = `unread`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( unread ) ) ) ).
  ENDMETHOD.

  METHOD notification_list_item.
    result = _generic(
                 name   = `NotificationListItem`
                 t_prop = VALUE #(
                     ( n = `id`  v = id )
                     ( n = `class`  v = class )
                     ( n = `authorAvatarColor`  v = authoravatarcolor )
                     ( n = `authorInitials`  v = authorinitials )
                     ( n = `description`  v = description )
                     ( n = `authorName`  v = authorname )
                     ( n = `authorPicture`  v = authorpicture )
                     ( n = `datetime`  v = datetime )
                     ( n = `counter`  v = counter )
                     ( n = `highlightText`  v = highlighttext )
                     ( n = `priority`  v = priority )
                     ( n = `title`  v = title )
                     ( n = `type`  v = type )
                     ( n = `close`  v = close )
                     ( n = `detailPress`  v = detailpress )
                     ( n = `press`  v = press )
                     ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `hideShowMoreButton`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideshowmorebutton ) )
                     ( n = `truncate`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( truncate ) )
                     ( n = `highlight`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( highlight ) )
                     ( n = `navigated`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( navigated ) )
                     ( n = `selected`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                     ( n = `showButtons`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showbuttons ) )
                     ( n = `showCloseButton`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclosebutton ) )
                     ( n = `unread`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( unread ) ) ) ).
  ENDMETHOD.

  METHOD no_data.
    result = _generic( name = `noData`
                       ns   = ns ).
  ENDMETHOD.

  METHOD numeric_content.

    result = _generic(
        name   = `NumericContent`
        t_prop = VALUE #( ( n = `value`      v = value )
                          ( n = `icon`       v = icon )
                          ( n = `width`       v = width )
                          ( n = `valueColor`       v = valuecolor )
                          ( n = `truncateValueTo`       v = truncatevalueto )
                          ( n = `state`       v = state )
                          ( n = `scale`       v = scale )
                          ( n = `indicator`       v = indicator )
                          ( n = `iconDescription`       v = icondescription )
                          ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `nullifyValue` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( nullifyvalue ) )
                          ( n = `formatterValue` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( formattervalue ) )
                          ( n = `animateTextChange` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( animatetextchange ) )
                          ( n = `adaptiveFontSize` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( adaptivefontsize ) )
                          ( n = `withMargin` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( withmargin ) )
                          ( n = `class`      v = class )
                          ( n = `press`      v = press ) ) ).

  ENDMETHOD.

  METHOD numeric_header.

    result = _generic( name   = `NumericHeader`
                       ns     = `f`
                       t_prop = VALUE #(
                           ( n = `id`  v = id )
                           ( n = `class`  v = class )
                           ( n = `dataTimestamp`  v = datatimestamp )
                           ( n = `press`  v = press )
                           ( n = `details`  v = details )
                           ( n = `detailsMaxLines`  v = detailsmaxlines )
                           ( n = `detailsState`  v = detailsstate )
                           ( n = `iconAlt`  v = iconalt )
                           ( n = `iconBackgroundColor`  v = iconbackgroundcolor )
                           ( n = `iconDisplayShape`  v = icondisplayshape )
                           ( n = `iconSize`  v = iconsize )
                           ( n = `iconSrc`  v = iconsrc )
                           ( n = `iconInitials`  v = iconinitials )
                           ( n = `number`  v = number )
                           ( n = `numberSize`  v = numbersize )
                           ( n = `scale`  v = scale )
                           ( n = `sideIndicatorsAlignment`  v = sideindicatorsalignment )
                           ( n = `state`  v = state )
                           ( n = `statusText`  v = statustext )
                           ( n = `subtitle`  v = subtitle )
                           ( n = `subtitleMaxLines`  v = subtitlemaxlines )
                           ( n = `title`  v = title )
                           ( n = `titleMaxLines`  v = titlemaxlines )
                           ( n = `trend`  v = trend )
                           ( n = `unitOfMeasurement`  v = unitofmeasurement )
                           ( n = `statusVisible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( statusvisible ) )
                           ( n = `numberVisible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( numbervisible ) )
                           ( n = `iconVisible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconvisible ) )
                           ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD numeric_side_indicator.
    result = _generic( name   = `NumericSideIndicator`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `unit`  v = unit )
                                         ( n = `title`  v = title )
                                         ( n = `state`  v = state )
                                         ( n = `number`  v = number )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD object_attribute.
    result = me.

    _generic( name   = `ObjectAttribute`
              t_prop = VALUE #( ( n = `title`          v = title )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `ariaHasPopup`   v = ariahaspopup )
                                ( n = `press`          v = press )
                                ( n = `active`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( active ) )
                                ( n = `visible`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `text`           v = text ) ) ).
  ENDMETHOD.

  METHOD object_header.

    result = _generic(
        name   = `ObjectHeader`
        t_prop = VALUE #( ( n = `backgroundDesign`     v = backgrounddesign )
                          ( n = `condensed`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( condensed ) )
                          ( n = `fullScreenOptimized`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( fullscreenoptimized ) )
                          ( n = `icon`                 v = icon )
                          ( n = `iconActive`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconactive ) )
                          ( n = `iconAlt`              v = iconalt )
                          ( n = `iconDensityAware`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                          ( n = `iconTooltip`          v = icontooltip )
                          ( n = `imageShape`           v = imageshape )
                          ( n = `intro`                v = intro )
                          ( n = `introActive`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( introactive ) )
                          ( n = `introHref`            v = introhref )
                          ( n = `introTarget`          v = introtarget )
                          ( n = `introTextDirection`   v = introtextdirection )
                          ( n = `number`               v = number )
                          ( n = `numberState`          v = numberstate )
                          ( n = `numberTextDirection`  v = numbertextdirection )
                          ( n = `numberUnit`           v = numberunit )
                          ( n = `responsive`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( responsive ) )
                          ( n = `showTitleSelector`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitleselector ) )
                          ( n = `title`                v = title )
                          ( n = `titleActive`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( titleactive ) )
                          ( n = `titleHref`            v = titlehref )
                          ( n = `titleLevel`           v = titlelevel )
                          ( n = `titleSelectorTooltip` v = titleselectortooltip )
                          ( n = `titleTarget`          v = titletarget )
                          ( n = `titleTextDirection`   v = titletextdirection )
                          ( n = `iconPress`            v = iconpress )
                          ( n = `introPress`           v = intropress )
                          ( n = `titlePress`           v = titlepress )
                          ( n = `titleSelectorPress`   v = titleselectorpress )
                          ( n = `class`                v = class ) ) ).
  ENDMETHOD.

  METHOD object_identifier.
    result = _generic( name   = `ObjectIdentifier`
                       t_prop = VALUE #( ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                         ( n = `text` v = text )
                                         ( n = `textDirection` v = textdirection )
                                         ( n = `title` v = title )
                                         ( n = `titleActive` v = titleactive )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `titlePress` v = titlepress ) ) ).
  ENDMETHOD.

  METHOD object_list_item.
    result = _generic(
        name   = `ObjectListItem`
        t_prop = VALUE #( ( n = `activeIcon`          v = activeicon )
                          ( n = `icon`                v = icon )
                          ( n = `intro`               v = intro )
                          ( n = `introTextDirection`  v = introtextdirection )
                          ( n = `number`              v = number )
                          ( n = `numberState`         v = numberstate )
                          ( n = `numberTextDirection` v = numbertextdirection )
                          ( n = `numberUnit`          v = numberunit )
                          ( n = `unit`                v = unit )
                          ( n = `title`               v = title )
                          ( n = `titleTextDirection`  v = titletextdirection )
                          ( n = `iconDensityAware`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                          ( n = `press`               v = press )
                          ( n = `selected`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                          ( n = `type`                v = type ) ) ).
  ENDMETHOD.

  METHOD object_marker.
    result = _generic( name   = `ObjectMarker`
                       t_prop = VALUE #( ( n = `additionalInfo` v = additionalinfo )
                                         ( n = `type`           v = type )
                                         ( n = `visible`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `press`          v = press )
                                         ( n = `visibility`     v = visibility ) ) ).
  ENDMETHOD.

  METHOD object_number.
    result = me.
    _generic( name   = `ObjectNumber`
              t_prop = VALUE #( ( n = `emphasized`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( emphasized ) )
                                ( n = `number`             v = number )
                                ( n = `state`              v = state )
                                ( n = `id`          v = id )
                                ( n = `class`          v = class )
                                ( n = `textAlign`          v = textalign )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                ( n = `numberUnit`         v = numberunit )
                                ( n = `active`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( active ) )
                                ( n = `inverted`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inverted ) )
                                ( n = `visible`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `unit`               v = unit ) ) ).
  ENDMETHOD.

  METHOD object_page_dyn_header_title.
    result = _generic( name = `ObjectPageDynamicHeaderTitle`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD object_page_header.
    result = me.
    _generic(
        name   = `ObjectPageHeader`
        ns     = `uxap`
        t_prop = VALUE #(
            ( n = `isActionAreaAlwaysVisible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( isactionareaalwaysvisible ) )
            ( n = `isObjectIconAlwaysVisible`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( isobjecticonalwaysvisible ) )
            ( n = `isObjectSubtitleAlwaysVisible`
              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( isobjectsubtitlealwaysvisible ) )
            ( n = `isObjectTitleAlwaysVisible`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( isobjecttitlealwaysvisible ) )
            ( n = `markChanges`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( markchanges ) )
            ( n = `markFavorite`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( markfavorite ) )
            ( n = `markFlagged`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( markflagged ) )
            ( n = `markLocked`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( marklocked ) )
            ( n = `objectImageDensityAware`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( objectimagedensityaware ) )
            ( n = `showMarkers`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showmarkers ) )
            ( n = `showPlaceholder`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showplaceholder ) )
            ( n = `showTitleSelector`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitleselector ) )
            ( n = `visible`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            ( n = `objectImageAlt`        v = objectimagealt )
            ( n = `objectImageBackgroundColor`      v = objectimagebackgroundcolor )
            ( n = `objectImageURI`      v = objectimageuri )
            ( n = `objectSubtitle`      v = objectsubtitle )
            ( n = `objectTitle`      v = objecttitle )
            ( n = `markChangesPress`      v = markchangespress )
            ( n = `markLockedPress`      v = marklockedpress )
            ( n = `titleSelectorPress`      v = titleselectorpress )
            ( n = `objectImageShape`  v = objectimageshape ) ) ).
  ENDMETHOD.

  METHOD object_page_header_action_btn.
    result = me.
    _generic( name   = `ObjectPageHeaderActionButton`
              ns     = `uxap`
              t_prop = VALUE #( ( n = `activeIcon`  v = activeicon )
                                ( n = `ariaHasPopup`       v = ariahaspopup )
                                ( n = `icon`        v = icon )
                                ( n = `importance`      v = importance )
                                ( n = `text`      v = text )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `type`      v = type )
                                ( n = `width`      v = width )
                                ( n = `enabled`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `hideIcon`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideicon ) )
                                ( n = `hideText`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hidetext ) )
                                ( n = `iconDensityAware`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                                ( n = `iconFirst`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconfirst ) )
                                ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `press`  v = press ) ) ).
  ENDMETHOD.

  METHOD object_page_layout.
    result = _generic(
        name   = `ObjectPageLayout`
        ns     = `uxap`
        t_prop = VALUE #(
            ( n = `showTitleInHeaderContent` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitleinheadercontent ) )
            ( n = `showEditHeaderButton`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showeditheaderbutton ) )
            ( n = `alwaysShowContentHeader`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( alwaysshowcontentheader ) )
            ( n = `enableLazyLoading`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablelazyloading ) )
            ( n = `flexEnabled`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( flexenabled ) )
            ( n = `headerContentPinnable`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( headercontentpinnable ) )
            ( n = `headerContentPinned`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( headercontentpinned ) )
            ( n = `isChildPage`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( ischildpage ) )
            ( n = `preserveHeaderStateOnScroll`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( preserveheaderstateonscroll ) )
            ( n = `showAnchorBar`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showanchorbar ) )
            ( n = `showAnchorBarPopover`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showanchorbarpopover ) )
            ( n = `showHeaderContent`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showheadercontent ) )
            ( n = `showOnlyHighImportance`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showonlyhighimportance ) )
            ( n = `subSectionLayout`     v = subsectionlayout )
            ( n = `toggleHeaderOnTitleClick`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( toggleheaderontitleclick ) )
            ( n = `useIconTabBar`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( useicontabbar ) )
            ( n = `useTwoColumnsForLargeScreen`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usetwocolumnsforlargescreen ) )
            ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            ( n = `backgroundDesignAnchorBar`    v = backgrounddesignanchorbar )
            ( n = `height`                     v = height )
            ( n = `sectionTitleLevel`                     v = sectiontitlelevel )
            ( n = `editHeaderButtonPress`    v = editheaderbuttonpress )
            ( n = `upperCaseAnchorBar`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( uppercaseanchorbar ) )
            ( n = `beforeNavigate`       v = beforenavigate )
            ( n = `headerContentPinnedStateChange`       v = headercontentpinnedstatechange )
            ( n = `navigate`       v = navigate )
            ( n = `sectionChange`       v = sectionchange )
            ( n = `subSectionVisibilityChange`       v = subsectionvisibilitychange )
            ( n = `toggleAnchorBar`       v = toggleanchorbar )
            ( n = `showFooter`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfooter ) )
            ( n = `class`                  v = class ) ) ).
  ENDMETHOD.

  METHOD object_page_section.
    result = _generic(
                 name   = `ObjectPageSection`
                 ns     = `uxap`
                 t_prop = VALUE #( ( n = `titleUppercase`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( titleuppercase ) )
                                   ( n = `title`           v = title )
                                   ( n = `id`              v = id )
                                   ( n = `anchorBarButtonColor`              v = anchorbarbuttoncolor )
                                   ( n = `titleLevel`      v = titlelevel )
                                   ( n = `titleVisible`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( titlevisible ) )
                                   ( n = `showTitle`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitle ) )
                                   ( n = `visible`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `wrapTitle`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wraptitle ) )
                                   ( n = `importance`      v = importance ) ) ).
  ENDMETHOD.

  METHOD object_page_sub_section.
    result = _generic(
                 name   = `ObjectPageSubSection`
                 ns     = `uxap`
                 t_prop = VALUE #( ( n = `id`    v = id )
                                   ( n = `mode`    v = mode )
                                   ( n = `importance`    v = importance )
                                   ( n = `titleLevel`    v = titlelevel )
                                   ( n = `titleVisible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( titlevisible ) )
                                   ( n = `showTitle`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitle ) )
                                   ( n = `titleUppercase`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( titleuppercase ) )
                                   ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `title` v = title ) ) ).
  ENDMETHOD.

  METHOD object_status.
    result = _generic(
        name   = `ObjectStatus`
        t_prop = VALUE #( ( n = `active`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( active ) )
                          ( n = `emptyIndicatorMode`    v = emptyindicatormode )
                          ( n = `icon`                  v = icon )
                          ( n = `iconDensityAware`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( icondensityaware ) )
                          ( n = `inverted`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inverted ) )
                          ( n = `state`                 v = state )
                          ( n = `stateAnnouncementText` v = stateannouncementtext )
                          ( n = `text`                  v = text )
                          ( n = `id`                  v = id )
                          ( n = `class`                  v = class )
                          ( n = `textDirection`         v = textdirection )
                          ( n = `title`                 v = title )
                          ( n = `visible`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `press`                 v = press ) ) ).
  ENDMETHOD.

  METHOD overflow_toolbar.
    result = _generic( name   = `OverflowToolbar`
                       t_prop = VALUE #( ( n = `press`   v = press )
                                         ( n = `text`    v = text )
                                         ( n = `active` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( active ) )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `asyncMode` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( asyncmode ) )
                                         ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `design`    v = design )
                                         ( n = `type`    v = type )
                                         ( n = `style`    v = style )
                                         ( n = `id`    v = id )
                                         ( n = `class`    v = class )
                                         ( n = `width`    v = width )
                                         ( n = `height` v = height ) ) ).
  ENDMETHOD.

  METHOD overflow_toolbar_button.
    result = me.
    _generic( name   = `OverflowToolbarButton`
              t_prop = VALUE #( ( n = `id`      v = id )
                                ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.

  METHOD overflow_toolbar_menu_button.
    result = _generic( name   = `OverflowToolbarMenuButton`
                       t_prop = VALUE #( ( n = `buttonMode` v = buttonmode )
                                         ( n = `defaultAction` v = defaultaction )
                                         ( n = `text`    v = text )
                                         ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `icon`    v = icon )
                                         ( n = `type`    v = type )
                                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.

  METHOD overflow_toolbar_toggle_button.
    result = me.
    _generic( name   = `OverflowToolbarToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.

  METHOD page.
    result = _generic(
                 name   = `Page`
                 ns     = ns
                 t_prop = VALUE #( ( n = `title` v = title )
                                   ( n = `showNavButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownavbutton ) )
                                   ( n = `navButtonPress` v = navbuttonpress )
                                   ( n = `showHeader` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showheader ) )
                                   ( n = `class` v = class )
                                   ( n = `backgroundDesign` v = backgrounddesign )
                                   ( n = `navButtonTooltip` v = navbuttontooltip )
                                   ( n = `titleAlignment` v = titlealignment )
                                   ( n = `titleLevel` v = titlelevel )
                                   ( n = `contentOnlyBusy` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( contentonlybusy ) )
                                   ( n = `enableScrolling` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablescrolling ) )
                                   ( n = `floatingFooter` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( floatingfooter ) )
                                   ( n = `showFooter` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfooter ) )
                                   ( n = `showSubHeader` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsubheader ) )
                                   ( n = `id` v = id ) ) ).
  ENDMETHOD.

  METHOD pages.
    result = _generic( `pages` ).

  ENDMETHOD.

  METHOD paging_button.
    result = me.
    _generic( name   = `PagingButton`
              t_prop = VALUE #( ( n = `count`  v = count )
                                ( n = `nextButtonTooltip`    v = nextbuttontooltip )
                                ( n = `position`    v = position )
                                ( n = `previousButtonTooltip`  v = previousbuttontooltip ) ) ).
  ENDMETHOD.

  METHOD panel.

    result = _generic(
                 name   = `Panel`
                 t_prop = VALUE #( ( n = `expandable` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( expandable ) )
                                   ( n = `expanded`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( expanded ) )
                                   ( n = `stickyHeader`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( stickyheader ) )
                                   ( n = `expandAnimation`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( expandanimation ) )
                                   ( n = `visible`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `height`   v = height )
                                   ( n = `backgroundDesign`   v = backgrounddesign )
                                   ( n = `width`   v = width )
                                   ( n = `id`   v = id )
                                   ( n = `class`   v = class )
                                   ( n = `expand`   v = expand )
                                   ( n = `headerText` v = headertext )
                                 ) ).

  ENDMETHOD.

  METHOD pane_container.
    result = _generic( name   = `PaneContainer`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `resize`       v = resize )
                                         ( n = `orientation`  v = orientation ) ) ).
  ENDMETHOD.

  METHOD planning_calendar.
    result = _generic(
        name   = `PlanningCalendar`
        t_prop = VALUE #(
            ( n = `rows`                      v = rows )
            ( n = `startDate`                 v = startdate )
            ( n = `id`                 v = id )
            ( n = `class`                 v = class )
            ( n = `appointmentHeight` v = appointmentheight )
            ( n = `appointmentRoundWidth` v = appointmentroundwidth )
            ( n = `builtInViews` v = builtinviews )
            ( n = `calendarWeekNumbering` v = calendarweeknumbering )
            ( n = `firstDayOfWeek` v = firstdayofweek )
            ( n = `groupAppointmentsMode` v = groupappointmentsmode )
            ( n = `height` v = height )
            ( n = `iconShape` v = iconshape )
            ( n = `maxDate` v = maxdate )
            ( n = `minDate` v = mindate )
            ( n = `noDataText` v = nodatatext )
            ( n = `primaryCalendarType` v = primarycalendartype )
            ( n = `secondaryCalendarType` v = secondarycalendartype )
            ( n = `appointmentsVisualization` v = appointmentsvisualization )
            ( n = `appointmentSelect`         v = appointmentselect )
            ( n = `intervalSelect`         v = intervalselect )
            ( n = `rowHeaderPress`         v = rowheaderpress )
            ( n = `rowSelectionChange`         v = rowselectionchange )
            ( n = `startDateChange`         v = startdatechange )
            ( n = `viewChange`         v = viewchange )
            ( n = `stickyHeader`         v = stickyheader )
            ( n = `viewKey`         v = viewkey )
            ( n = `width`         v = width )
            ( n = `singleSelection`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( singleselection ) )
            ( n = `showRowHeaders`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showrowheaders ) )
            ( n = `multipleAppointmentsSelection`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( multipleappointmentsselection ) )
            ( n = `showIntervalHeaders`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showintervalheaders ) )
            ( n = `showEmptyIntervalHeaders`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showemptyintervalheaders ) )
            ( n = `showWeekNumbers`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showweeknumbers ) )
            ( n = `legend`                    v = legend )
            ( n = `showDayNamesLine`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showdaynamesline ) ) ) ).
  ENDMETHOD.

  METHOD planning_calendar_legend.
    result = _generic(
                 name   = `PlanningCalendarLegend`
                 t_prop = VALUE #( ( n = `id`                              v = id )
                                   ( n = `items`                           v = items )
                                   ( n = `appointmentItems`                v = appointmentitems )
                                   ( n = `columnWidth`                v = columnwidth )
                                   ( n = `visible`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `standardItems`                   v = standarditems ) ) ).

  ENDMETHOD.

  METHOD planning_calendar_row.
    result = _generic(
        name   = `PlanningCalendarRow`
        t_prop = VALUE #(
            ( n = `appointments`                    v = appointments )
            ( n = `intervalHeaders`                 v = intervalheaders )
            ( n = `id`                            v = id )
            ( n = `class`                            v = class )
            ( n = `icon`                            v = icon )
            ( n = `title`                           v = title )
            ( n = `key`                             v = key )
            ( n = `noAppointmentsText`                             v = noappointmentstext )
            ( n = `nonWorkingHours`                             v = nonworkinghours )
            ( n = `rowHeaderDescription`                             v = rowheaderdescription )
            ( n = `enableAppointmentsCreate`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableappointmentscreate ) )
            ( n = `appointmentResize`               v = appointmentresize )
            ( n = `appointmentDrop`                 v = appointmentdrop )
            ( n = `appointmentDragEnter`            v = appointmentdragenter )
            ( n = `appointmentCreate`               v = appointmentcreate )
            ( n = `selected`                        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
            ( n = `nonWorkingDays`                  v = nonworkingdays )
            ( n = `enableAppointmentsResize`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableappointmentsresize ) )
            ( n = `enableAppointmentsDragAndDrop`
              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableappointmentsdraganddrop ) )
            ( n = `text`                            v = text )
                        ) ).

  ENDMETHOD.

  METHOD planning_calendar_view.
    result = _generic(
        name   = `PlanningCalendarView`
        t_prop = VALUE #( ( n = `appointmentHeight`                      v = appointmentheight )
                          ( n = `description`                 v = description )
                          ( n = `intervalLabelFormatter`                 v = intervallabelformatter )
                          ( n = `intervalSize`  v = intervalsize )
                          ( n = `intervalsL`  v = intervalsl )
                          ( n = `intervalsM`  v = intervalsm )
                          ( n = `intervalsS`  v = intervalss )
                          ( n = `intervalType`  v = intervaltype )
                          ( n = `key`  v = key )
                          ( n = `relative`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( relative ) )
                          ( n = `showSubIntervals`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsubintervals ) )
                        ) ).
  ENDMETHOD.

  METHOD points.
    result = _generic( name = `points`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD popover.
    result = _generic(
        name   = `Popover`
        t_prop = VALUE #( ( n = `id`         v = id )
                          ( n = `title`         v = title )
                          ( n = `class`         v = class )
                          ( n = `placement`     v = placement )
                          ( n = `initialFocus`  v = initialfocus )
                          ( n = `contentHeight` v = contentheight )
                          ( n = `showHeader`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showheader ) )
                          ( n = `showArrow`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showarrow ) )
                          ( n = `resizable`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resizable ) )
                          ( n = `modal`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( modal ) )
                          ( n = `horizontalScrolling`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( horizontalscrolling ) )
                          ( n = `verticalScrolling`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( verticalscrolling ) )
                          ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `offsetX`    v = offsetx )
                          ( n = `offsetY`    v = offsety )
                          ( n = `contentMinWidth`    v = contentminwidth )
                          ( n = `titleAlignment`    v = titlealignment )
                          ( n = `contentWidth`  v = contentwidth )
                          ( n = `afterClose`  v = afterclose )
                          ( n = `afterOpen`  v = afteropen )
                          ( n = `beforeClose`  v = beforeclose )
                          ( n = `beforeOpen`  v = beforeopen ) ) ).
  ENDMETHOD.

  METHOD process_flow.
    result = _generic(
                 name   = `ProcessFlow`
                 ns     = `commons`
                 t_prop = VALUE #( ( n = `id`               v = id )
                                   ( n = `foldedCorners`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( foldedcorners ) )
                                   ( n = `scrollable`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( scrollable ) )
                                   ( n = `showLabels`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showlabels ) )
                                   ( n = `visible`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                   ( n = `wheelZoomable`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wheelzoomable ) )
                                   ( n = `headerPress`      v = headerpress )
                                   ( n = `labelPress`       v = labelpress )
                                   ( n = `nodePress`        v = nodepress )
                                   ( n = `onError`          v = onerror )
                                   ( n = `lanes`            v = lanes )
                                   ( n = `nodes`            v = nodes ) ) ).
  ENDMETHOD.

  METHOD process_flow_lane_header.

    result = _generic( name   = `ProcessFlowLaneHeader`
                       ns     = `commons`
                       t_prop = VALUE #( ( n = `iconSrc`          v = iconsrc )
                                         ( n = `laneId`           v = laneid )
                                         ( n = `position`         v = position )
                                         ( n = `state`            v = state )
                                         ( n = `text`             v = text )
                                         ( n = `zoomLevel`        v = zoomlevel ) ) ).
  ENDMETHOD.

  METHOD process_flow_node.
    result = _generic(
                 name   = `ProcessFlowNode`
                 ns     = `commons`
                 t_prop = VALUE #( ( n = `laneId`               v = laneid )
                                   ( n = `nodeId`               v = nodeid )
                                   ( n = `title`                v = title )
                                   ( n = `titleAbbreviation`    v = titleabbreviation )
                                   ( n = `children`             v = children )
                                   ( n = `state`                v = state )
                                   ( n = `stateText`            v = statetext )
                                   ( n = `texts`                v = texts )
                                   ( n = `highlighted`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( highlighted ) )
                                   ( n = `focused`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( focused ) )
                                   ( n = `selected`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                   ( n = `tag`                  v = tag )
                                   ( n = `type`                 v = type ) ) ).
  ENDMETHOD.

  METHOD progress_indicator.
    result = me.
    _generic( name   = `ProgressIndicator`
              t_prop = VALUE #( ( n = `class`        v = class )
                                ( n = `percentValue` v = percentvalue )
                                ( n = `displayValue` v = displayvalue )
                                ( n = `showValue`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvalue ) )
                                ( n = `visible`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `state`        v = state )
                                ( n = `width`        v = width )
                                ( n = `height`       v = height )
                                ( n = `enabled`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `displayOnly`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayonly ) )
                                ( n = `displayAnimation` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayanimation ) ) ) ).
  ENDMETHOD.

  METHOD property_threshold.
    result = _generic( name   = `PropertyThreshold`
                       ns     = `si`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `ariaLabel`     v = arialabel )
                                         ( n = `fillColor`     v = fillcolor )
                                         ( n = `toValue`     v = tovalue )
                                         ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                        ) ).
  ENDMETHOD.

  METHOD property_thresholds.
    result = _generic( name = `propertyThresholds`
                       ns   = `si` ).
  ENDMETHOD.

  METHOD proportion_zoom_strategy.
    result = _generic( name   = `ProportionZoomStrategy`
                       ns     = `axistime`
                       t_prop = VALUE #( ( n = `zoomLevel` v = zoomlevel ) ) ).
  ENDMETHOD.

  METHOD quick_view.
    result = _generic( name   = `QuickView`
                       t_prop = VALUE #( ( n = `placement`      v = placement )
                                         ( n = `width`    v = width )
                                         ( n = `afterClose`    v = afterclose )
                                         ( n = `afterOpen`    v = afteropen )
                                         ( n = `beforeClose`    v = beforeclose )
                                         ( n = `beforeOpen`  v = beforeopen ) ) ).
  ENDMETHOD.

  METHOD quick_view_group.
    result = _generic( name   = `QuickViewGroup`
                       t_prop = VALUE #( ( n = `heading` v = heading )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD quick_view_group_element.
    result = _generic( name   = `QuickViewGroupElement`
                       t_prop = VALUE #( ( n = `emailSubject`  v = emailsubject )
                                         ( n = `label`       v = label )
                                         ( n = `pageLinkId`  v = pagelinkid )
                                         ( n = `target`      v = target )
                                         ( n = `type`      v = type )
                                         ( n = `url`      v = url )
                                         ( n = `value`      v = value )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD quick_view_page.
    result = _generic( name   = `QuickViewPage`
                       t_prop = VALUE #( ( n = `description`   v = description )
                                         ( n = `header`       v = header )
                                         ( n = `pageId`       v = pageid )
                                         ( n = `title`       v = title )
                                         ( n = `titleUrl` v = titleurl ) ) ).
  ENDMETHOD.

  METHOD quick_view_page_avatar.
    result = _generic( `avatar` ).
  ENDMETHOD.

  METHOD radial_micro_chart.
    result = me.
    _generic( name   = `RadialMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `percentage`  v = percentage )
                                ( n = `press`       v = press )
                                ( n = `size`        v = size )
                                ( n = `height`      v = height )
                                ( n = `alignContent`      v = aligncontent )
                                ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `valueColor`  v = valuecolor ) ) ).
  ENDMETHOD.

  METHOD radio_button.
    result = _generic(
                 name   = `RadioButton`
                 t_prop = VALUE #( ( n = `id`             v = id )
                                   ( n = `activeHandling`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( activehandling ) )
                                   ( n = `editable`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                   ( n = `enabled`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                   ( n = `selected`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                   ( n = `useEntireWidth`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( useentirewidth ) )
                                   ( n = `text`            v = text )
                                   ( n = `textDirection`   v = textdirection )
                                   ( n = `textAlign`       v = textalign )
                                   ( n = `groupName`       v = groupname )
                                   ( n = `valueState`      v = valuestate )
                                   ( n = `width`           v = width )
                                   ( n = `select`          v = select )
                                   ( n = `visible`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD radio_button_group.
    result = _generic( name   = `RadioButtonGroup`
                       t_prop = VALUE #( ( n = `id`             v = id )
                                         ( n = `columns`        v = columns )
                                         ( n = `editable`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                         ( n = `enabled`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `selectedIndex`  v = selectedindex )
                                         ( n = `textDirection`  v = textdirection )
                                         ( n = `valueState`     v = valuestate )
                                         ( n = `select`         v = select )
                                         ( n = `width`          v = width )
                                         ( n = `class`          v = class ) ) ).
  ENDMETHOD.

  METHOD range_slider.
    result = me.
    _generic( name   = `RangeSlider`
              t_prop = VALUE #( ( n = `class`           v = class )
                                ( n = `id`          v = id )
                                ( n = `labelInterval`  v = labelinterval )
                                ( n = `max`   v = max )
                                ( n = `min`   v = min )
                                ( n = `enableTickmarks`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtickmarks ) )
                                ( n = `step`   v = step )
                                ( n = `width`   v = width )
                                ( n = `value`   v = COND #( WHEN value IS NOT INITIAL THEN value ELSE startvalue ) )
                                ( n = `value2`   v = COND #( WHEN value2 IS NOT INITIAL THEN value2 ELSE endvalue ) )
                                ( n = `change`   v = change ) ) ).
  ENDMETHOD.

  METHOD rating_indicator.

    result = _generic( name   = `RatingIndicator`
                       t_prop = VALUE #( ( n = `class`        v = class )
                                         ( n = `maxValue`     v = maxvalue )
                                         ( n = `displayOnly`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayonly ) )
                                         ( n = `editable`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                         ( n = `iconSize`     v = iconsize )
                                         ( n = `value`        v = value )
                                         ( n = `id`           v = id )
                                         ( n = `change`       v = change )
                                         ( n = `enabled`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `tooltip`      v = tooltip ) ) ).

  ENDMETHOD.

  METHOD relationship.

    result = _generic( name   = `Relationship`
                       ns     = `gantt`
                       t_prop = VALUE #( ( n = `shapeId`    v = shapeid )
                                         ( n = `type`        v = type )
                                         ( n = `successor`   v = successor )
                                         ( n = `predecessor` v = predecessor ) ) ).

  ENDMETHOD.

  METHOD relationships.
    result = _generic( name = `relationships`
                       ns   = `gantt` ).
  ENDMETHOD.

  METHOD responsive_scale.
    result = _generic( name   = `ResponsiveScale`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `tickmarksBetweenLabels`     v = tickmarksbetweenlabels )
                                        ) ).
  ENDMETHOD.

  METHOD responsive_splitter.
    result = _generic( name   = `ResponsiveSplitter`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `defaultPane`  v = defaultpane )
                                         ( n = `height`       v = height )
                                         ( n = `width`        v = width ) ) ).
  ENDMETHOD.

  METHOD rich_text_editor.
    result = _generic(
        name   = `RichTextEditor`
        ns     = `text`
        t_prop = VALUE #( ( n = `buttonGroups`        v = buttongroups )
                          ( n = `customToolbar`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( customtoolbar ) )
                          ( n = `editable`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                          ( n = `height`              v = height )
                          ( n = `editorType`          v = editortype )
                          ( n = `plugins`             v = plugins )
                          ( n = `textDirection`       v = textdirection )
                          ( n = `value`               v = value )
                          ( n = `beforeEditorInit`    v = beforeeditorinit )
                          ( n = `change`              v = change )
                          ( n = `ready`               v = ready )
                          ( n = `readyRecurring`      v = readyrecurring )
                          ( n = `required`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                          ( n = `sanitizeValue`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sanitizevalue ) )
                          ( n = `showGroupClipboard`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgroupclipboard ) )
                          ( n = `showGroupFont`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgroupfont ) )
                          ( n = `showGroupFontStyle`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgroupfontstyle ) )
                          ( n = `showGroupInsert`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgroupinsert ) )
                          ( n = `showGroupLink`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgrouplink ) )
                          ( n = `showGroupStructure`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgroupstructure ) )
                          ( n = `showGroupTextAlign`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgrouptextalign ) )
                          ( n = `showGroupUndo`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showgroupundo ) )
                          ( n = `useLegacyTheme`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( uselegacytheme ) )
                          ( n = `wrapping`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                          ( n = `width`               v = width ) ) ).

  ENDMETHOD.

  METHOD route.

    result = me.
    _generic( name   = `Route`
              ns     = `vbm`
              t_prop = VALUE #( ( n = `id`  v = id )
                                ( n = `position`  v = position )
                                ( n = `routetype`  v = routetype )
                                ( n = `lineDash`  v = linedash )
                                ( n = `linewidth`  v = linewidth )
                                ( n = `color`  v = color )
                                ( n = `colorBorder`  v = colorborder ) ) ).

  ENDMETHOD.

  METHOD routes.

    result = _generic( name   = `Routes`
                       ns     = `vbm`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `items`  v = items ) ) ).

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
    result = _generic( name   = `ScrollContainer`
                       t_prop = VALUE #( ( n = `height`      v = height )
                                         ( n = `width`       v = width )
                                         ( n = `id`          v = id )
                                         ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `vertical`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( vertical ) )
                                         ( n = `horizontal`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( horizontal ) )
                                         ( n = `focusable`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( focusable ) ) ) ).
  ENDMETHOD.

  METHOD search_field.
    result = me.
    _generic( name   = `SearchField`
              t_prop = VALUE #( ( n = `width`  v = width )
                                ( n = `search` v = search )
                                ( n = `value`  v = value )
                                ( n = `id`     v = id )
                                ( n = `class`  v = class )
                                ( n = `change` v = change )
                                ( n = `maxLength` v = maxlength )
                                ( n = `placeholder` v = placeholder )
                                ( n = `suggest` v = suggest )
                                ( n = `enableSuggestions` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablesuggestions ) )
                                ( n = `showRefreshButton` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showrefreshbutton ) )
                                ( n = `showSearchButton` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsearchbutton ) )
                                ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `liveChange` v = livechange ) ) ).
  ENDMETHOD.

  METHOD second_status.
    result = _generic( `secondStatus` ).
  ENDMETHOD.

  METHOD sections.
    result = _generic( name = `sections`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD segmented_button.
    result = _generic( name   = `SegmentedButton`
                       t_prop = VALUE #( ( n = `id` v = id )
                                         ( n = `selectedKey` v = selected_key )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `selectionChange` v = selection_change ) ) ).
  ENDMETHOD.

  METHOD segmented_button_item.
    result = me.
    _generic( name   = `SegmentedButtonItem`
              t_prop = VALUE #( ( n = `icon`  v = icon )
                                ( n = `press`   v = press )
                                ( n = `width`   v = width )
                                ( n = `key`   v = key )
                                ( n = `textDirection`   v = textdirection )
                                ( n = `enabled`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `text`  v = text ) ) ).
  ENDMETHOD.

  METHOD segments.
    result = _generic( name = `segments`
                       ns   = `mchart` ).
  ENDMETHOD.

  METHOD select.
    result = _generic( name   = `Select`
                       t_prop = VALUE #(
                           ( n = `id`                  v = id )
                           ( n = `class`                  v = class )
                           ( n = `autoAdjustWidth`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autoadjustwidth ) )
                           ( n = `columnRatio`         v = columnratio )
                           ( n = `editable`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                           ( n = `enabled`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                           ( n = `forceSelection`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( forceselection ) )
                           ( n = `icon`                v = icon )
                           ( n = `maxWidth`            v = maxwidth )
                           ( n = `name`                v = name )
                           ( n = `required`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                           ( n = `resetOnMissingKey`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resetonmissingkey ) )
                           ( n = `selectedItemId`      v = selecteditemid )
                           ( n = `selectedKey`         v = selectedkey )
                           ( n = `showSecondaryValues` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsecondaryvalues ) )
                           ( n = `textAlign`           v = textalign )
                           ( n = `textDirection`       v = textdirection )
                           ( n = `type`                v = type )
                           ( n = `valueState`          v = valuestate )
                           ( n = `valueStateText`      v = valuestatetext )
                           ( n = `width`               v = width )
                           ( n = `wrapItemsText`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapitemstext ) )
                           ( n = `items`               v = items )
                           ( n = `selectedItem`        v = selecteditem )
                           ( n = `change`              v = change )
                           ( n = `liveChange`          v = livechange )
                           ( n = `visible`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
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
    result = _generic(
        name   = `Shell`
        ns     = ns
        t_prop = VALUE #( ( n = `appWidthLimited`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( appwidthlimited ) ) ) ).
  ENDMETHOD.

  METHOD shell_bar.
    result = _generic( name   = `ShellBar`
                       ns     = `f`
                       t_prop = VALUE #(
                           ( n = `homeIcon`  v = homeicon )
                           ( n = `homeIconTooltip`  v = homeicontooltip )
                           ( n = `title`  v = title )
                           ( n = `secondTitle`  v = secondtitle )
                           ( n = `showCopilot`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcopilot ) )
                           ( n = `showMenuButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showmenubutton ) )
                           ( n = `showNavButton`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownavbutton ) )
                           ( n = `showNotifications`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownotifications ) )
                           ( n = `showProductSwitcher`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showproductswitcher ) )
                           ( n = `showSearch`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsearch ) )
                           ( n = `notificationsNumber`  v = notificationsnumber )
                           ( n = `avatarPressed` v = avatarpressed )
                           ( n = `copilotPressed` v = copilotpressed )
                           ( n = `homeIconPressed` v = homeiconpressed )
                           ( n = `menuButtonPressed` v = menubuttonpressed )
                           ( n = `navButtonPressed` v = navbuttonpressed )
                           ( n = `notificationsPressed` v = notificationspressed )
                           ( n = `productSwitcherPressed` v = productswitcherpressed )
                           ( n = `searchButtonPressed` v = searchbuttonpressed ) ) ).

  ENDMETHOD.

  METHOD side_content.
    result = _generic( name   = `sideContent`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `width`                           v = width ) ) ).

  ENDMETHOD.

  METHOD side_panel.
    result = _generic(
        name   = `SidePanel`
        ns     = `f`
        t_prop = VALUE #( ( n = `sidePanelWidth`  v = sidepanelwidth )
                          ( n = `sidePanelResizeStep`      v = sidepanelresizestep )
                          ( n = `sidePanelResizeLargerStep`      v = sidepanelresizelargerstep )
                          ( n = `sidePanelPosition`      v = sidepanelposition )
                          ( n = `sidePanelMinWidth`      v = sidepanelminwidth )
                          ( n = `sidePanelMaxWidth`      v = sidepanelmaxwidth )
                          ( n = `sidePanelResizable`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sidepanelresizable ) )
                          ( n = `actionBarExpanded`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( actionbarexpanded ) )
                          ( n = `toggle`    v = toggle )
                          ( n = `ariaLabel`  v = arialabel ) ) ).
  ENDMETHOD.

  METHOD side_panel_item.
    result = _generic( name   = `SidePanelItem`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `icon` v = icon )
                                         ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `key` v = key )
                                         ( n = `text` v = text ) ) ).
  ENDMETHOD.

  METHOD simple_form.
    result = _generic(
        name   = `SimpleForm`
        ns     = `form`
        t_prop = VALUE #(
            ( n = `title`    v = title )
            ( n = `layout`   v = layout )
            ( n = `class`           v = class )
            ( n = `adjustLabelSpan`   v = adjustlabelspan )
            ( n = `backgroundDesign`   v = backgrounddesign )
            ( n = `breakpointL`   v = breakpointl )
            ( n = `breakpointM`   v = breakpointm )
            ( n = `breakpointXL`   v = breakpointxl )
            ( n = `emptySpanL`   v = emptyspanl )
            ( n = `emptySpanM`   v = emptyspanm )
            ( n = `emptySpanS`   v = emptyspans )
            ( n = `emptySpanXL`   v = emptyspanxl )
            ( n = `labelSpanL`   v = labelspanl )
            ( n = `labelSpanM`   v = labelspanm )
            ( n = `labelSpanS`   v = labelspans )
            ( n = `labelSpanXL`   v = labelspanxl )
            ( n = `maxContainerCols`   v = maxcontainercols )
            ( n = `minWidth`   v = minwidth )
            ( n = `singleContainerFullSize`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( singlecontainerfullsize ) )
            ( n = `visible`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
            ( n = `width`       v = width )
            ( n = `id`       v = id )
            ( n = `columnsXL`   v = columnsxl )
            ( n = `columnsL`   v = columnsl )
            ( n = `columnsM`   v = columnsm )
            ( n = `editable` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) ) ) ).
  ENDMETHOD.

  METHOD slider.
    result = me.
    _generic( name   = `Slider`
              t_prop = VALUE #( ( n = `class`           v = class )
                                ( n = `id`          v = id )
                                ( n = `max`   v = max )
                                ( n = `min`   v = min )
                                ( n = `enableTickmarks`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabletickmarks ) )
                                ( n = `enabled`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `value`   v = value )
                                ( n = `step`   v = step )
                                ( n = `change`   v = change )
                                ( n = `width`   v = width )
                                ( n = `inputsAsTooltips`   v = inputsastooltips )
                                ( n = `showAdvancedTooltip`   v = showadvancedtooltip )
                                ( n = `showHandleTooltip`   v = showhandletooltip )
                                ( n = `liveChange` v = livechange ) ) ).
  ENDMETHOD.

  METHOD slide_tile.

    result = _generic( name   = `SlideTile`
                       t_prop = VALUE #( ( n = `displayTime` v = displaytime )
                                         ( n = `height` v = height )
                                         ( n = `scope` v = scope )
                                         ( n = `sizeBehavior` v = sizebehavior )
                                         ( n = `transitionTime` v = transitiontime )
                                         ( n = `width` v = width )
                                         ( n = `press` v = press )
                                         ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `class`   v = class ) ) ).
  ENDMETHOD.

  METHOD smart_variant_management.
    result = me.
    _generic( name   = `SmartVariantManagement`
              ns     = `smartVariantManagement`
              t_prop = VALUE #(
                  ( n = `id`      v = id )
                  ( n = `showExecuteOnSelection`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showexecuteonselection ) )
                  ( n = `persistencyKey`  v = persistencykey )
                   ) ).

  ENDMETHOD.

  METHOD snapped_content.
    result = _generic( name = `snappedContent`
                       ns   = ns ).
  ENDMETHOD.

  METHOD snapped_heading.
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
    result = _generic( name   = `SplitterLayoutData`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `size`         v = size )
                                         ( n = `minSize`      v = minsize )
                                         ( n = `resizable`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resizable ) ) ) ).
  ENDMETHOD.

  METHOD split_container.

    result = me.
    _generic( name   = `SplitContainer`
              t_prop = VALUE #( ( n = `id`                          v = id )
                                ( n = `initialDetail`               v = initialdetail )
                                ( n = `initialMaster`               v = initialmaster )
                                ( n = `backgroundColor`             v = backgroundcolor )
                                ( n = `backgroundImage`             v = backgroundimage )
                                ( n = `backgroundOpacity`           v = backgroundopacity )
                                ( n = `backgroundRepeat`            v = backgroundrepeat )
                                ( n = `defaultTransitionNameDetail` v = defaulttransitionnamedetail )
                                ( n = `defaultTransitionNameMaster` v = defaulttransitionnamemaster )
                                ( n = `masterButtonText`            v = masterbuttontext )
                                ( n = `masterButtonTooltip`         v = masterbuttontooltip )
                                ( n = `afterDetailNavigate`         v = afterdetailnavigate )
                                ( n = `afterMasterClose`            v = aftermasterclose )
                                ( n = `afterMasterNavigate`         v = aftermasternavigate )
                                ( n = `afterMasterOpen`             v = aftermasteropen )
                                ( n = `beforeMasterClose`           v = beforemasterclose )
                                ( n = `beforeMasterOpen`            v = beforemasteropen )
                                ( n = `detailNavigate`              v = detailnavigate )
                                ( n = `masterButton`                v = masterbutton )
                                ( n = `masterNavigate`              v = masternavigate )
                                ( n = `mode`                        v = mode ) ) ).

  ENDMETHOD.

  METHOD split_pane.
    result = _generic( name   = `SplitPane`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `id`                   v = id )
                                         ( n = `requiredParentWidth`  v = requiredparentwidth ) ) ).
  ENDMETHOD.

  METHOD spot.

    result = me.
    _generic( name   = `Spot`
              ns     = `vbm`
              t_prop = VALUE #( ( n = `id`  v = id )
                                ( n = `position`  v = position )
                                ( n = `contentOffset`  v = contentoffset )
                                ( n = `type`  v = type )
                                ( n = `scale`  v = scale )
                                ( n = `tooltip`  v = tooltip )
                                ( n = `image`  v = image )
                                ( n = `icon`  v = icon )
                                ( n = `text`  v = text )
                                ( n = `click`  v = click ) ) ).

  ENDMETHOD.

  METHOD spots.

    result = _generic( name   = `Spots`
                       ns     = `vbm`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `items`  v = items ) ) ).

  ENDMETHOD.

  METHOD stacked_bar_micro_chart.

    result = me.
    _generic( name   = `StackedBarMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `height`  v = height )
                                ( n = `press`       v = press )
                                ( n = `maxValue`        v = maxvalue )
                                ( n = `precision`      v = precision )
                                ( n = `size`      v = size )
                                ( n = `hideOnNoData`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `displayZeroValue`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayzerovalue ) )
                                ( n = `showLabels`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showlabels ) )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.

  METHOD standard_list_item.
    result = me.
    _generic(
        name   = `StandardListItem`
        t_prop = VALUE #( ( n = `title`       v = title )
                          ( n = `description` v = description )
                          ( n = `icon`        v = icon )
                          ( n = `info`        v = info )
                          ( n = `press`       v = press )
                          ( n = `type`        v = type )
                          ( n = `counter`     v = counter )
                          ( n = `activeIcon`     v = activeicon )
                          ( n = `adaptTitleSize`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( adapttitlesize ) )
                          ( n = `unread`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( unread ) )
                          ( n = `iconInset`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( iconinset ) )
                          ( n = `infoStateInverted`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( infostateinverted ) )
                          ( n = `wrapping`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                          ( n = `infoState`     v = infostate )
                          ( n = `highlight`     v = highlight )
                          ( n = `wrapCharLimit`     v = wrapcharlimit )
                          ( n = `selected`    v = selected ) ) ).
  ENDMETHOD.

  METHOD standard_tree_item.
    result = me.
    _generic( name   = `StandardTreeItem`
              t_prop = VALUE #( ( n = `title`       v = title )
                                ( n = `icon`        v = icon )
                                ( n = `press`       v = press )
                                ( n = `detailPress` v = detailpress )
                                ( n = `type`        v = type )
                                ( n = `counter`     v = counter )
                                ( n = `selected`    v = selected )
                                ( n = `tooltip`    v = tooltip ) ) ).

  ENDMETHOD.

  METHOD status.

    result = _generic(
                 name   = `Status`
                 ns     = `networkgraph`
                 t_prop = VALUE #( ( n = `id`  v = id )
                                   ( n = `class`  v = class )
                                   ( n = `backgroundColor`  v = backgroundcolor )
                                   ( n = `borderColor`         v = bordercolor )
                                   ( n = `borderStyle`         v = borderstyle )
                                   ( n = `borderWidth`         v = borderwidth )
                                   ( n = `contentColor`         v = contentcolor )
                                   ( n = `headerContentColor`         v = headercontentcolor )
                                   ( n = `hoverBackgroundColor`         v = hoverbackgroundcolor )
                                   ( n = `hoverBorderColor`         v = hoverbordercolor )
                                   ( n = `hoverContentColor`         v = hovercontentcolor )
                                   ( n = `key`         v = key )
                                   ( n = `legendColor`         v = legendcolor )
                                   ( n = `selectedBackgroundColor`         v = selectedbackgroundcolor )
                                   ( n = `selectedBorderColor`         v = selectedbordercolor )
                                   ( n = `selectedContentColor`         v = selectedcontentcolor )
                                   ( n = `title`         v = title )
                                   ( n = `useFocusColorAsContentColor`
                                     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usefocuscolorascontentcolor ) )
                                   ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD statuses.
    result = _generic( name = `statuses`
                       ns   = SWITCH #( ns WHEN `` THEN `networkgraph` ELSE ns ) ).
  ENDMETHOD.

  METHOD status_indicator.
    result = _generic( name   = `StatusIndicator`
                       ns     = `si`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `class`    v = class )
                                         ( n = `height`     v = height )
                                         ( n = `labelPosition` v = labelposition )
                                         ( n = `showLabel`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showlabel ) )
                                         ( n = `size`    v = size )
                                         ( n = `value`    v = value )
                                         ( n = `viewBox`    v = viewbox )
                                         ( n = `width`    v = width )
                                         ( n = `press`    v = press )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                        ) ).
  ENDMETHOD.

  METHOD step_input.
    result = me.
    _generic( name   = `StepInput`
              t_prop = VALUE #( ( n = `id`                    v = id )
                                ( n = `max`                   v = max )
                                ( n = `min`                   v = min )
                                ( n = `step`                  v = step )
                                ( n = `width`                 v = width )
                                ( n = `value`                 v = value )
                                ( n = `valueState`            v = valuestate )
                                ( n = `enabled`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `description`           v = description )
                                ( n = `displayValuePrecision` v = displayvalueprecision )
                                ( n = `largerStep`            v = largerstep )
                                ( n = `stepMode`              v = stepmode )
                                ( n = `editable`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                ( n = `fieldWidth`            v = fieldwidth )
                                ( n = `textAlign`             v = textalign )
                                ( n = `validationMode`        v = validationmode )
                                ( n = `change`                v = change ) ) ).
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
    result = _generic( name = `subSections`
                       ns   = `uxap` ).
  ENDMETHOD.

  METHOD suggestion_columns.
    result = _generic( `suggestionColumns` ).
  ENDMETHOD.

  METHOD suggestion_item.
    result = me.
    _generic( name   = `SuggestionItem`
              t_prop = VALUE #( ( n = `description`   v = description )
                                ( n = `icon`          v = icon )
                                ( n = `key`           v = key )
                                ( n = `text`          v = text )
                                ( n = `textDirection` v = textdirection ) ) ).
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
    result = me.
    _generic( name   = `Switch`
              t_prop = VALUE #( ( n = `type`           v = type )
                                ( n = `enabled`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `state`          v = state )
                                ( n = `change`         v = change )
                                ( n = `customTextOff`  v = customtextoff )
                                ( n = `customTextOn`   v = customtexton )
                                ( n = `name`           v = name ) ) ).
  ENDMETHOD.

  METHOD tab.
    result = _generic( name   = `Tab`
                       ns     = `webc`
                       t_prop = VALUE #( ( n = `text`     v = text )
                                         ( n = `selected` v = selected ) ) ).
  ENDMETHOD.

  METHOD table.
    result = _generic( name   = `Table`
                       t_prop = VALUE #(
                           ( n = `items`            v = items )
                           ( n = `headerText`       v = headertext )
                           ( n = `class`            v = class )
                           ( n = `growing`          v = growing )
                           ( n = `growingThreshold` v = growingthreshold )
                           ( n = `growingScrollToLoad` v = growingscrolltoload )
                           ( n = `sticky`           v = sticky )
                           ( n = `showSeparators`           v = showseparators )
                           ( n = `mode`             v = mode )
                           ( n = `inset`             v = inset )
                           ( n = `width`            v = width )
                           ( n = `id`            v = id )
                           ( n = `hiddenInPopin`            v = hiddeninpopin )
                           ( n = `popinLayout`            v = popinlayout )
                           ( n = `selectionChange`  v = selectionchange )
                           ( n = `backgroundDesign`  v = backgrounddesign )
                           ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                           ( n = `alternateRowColors`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `fixedLayout`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( fixedlayout ) )
                           ( n = `showOverlay`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showoverlay ) )
                           ( n = `autoPopinMode`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autopopinmode ) )
                           ( n = `footerText`  v = footertext )
                           ( n = `multiSelectMode`  v = multiselectmode )
                           ( n = `keyboardMode`  v = keyboardmode )
                           ( n = `contextualWidth`  v = contextualwidth )
                           ( n = `rememberSelections`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rememberselections ) ) ) ).
  ENDMETHOD.

  METHOD table_select_dialog.

    result = _generic( name   = `TableSelectDialog`
                       t_prop = VALUE #(
                           ( n = `confirmButtonText`    v = confirmbuttontext )
                           ( n = `contentHeight`        v = contentheight )
                           ( n = `contentWidth`         v = contentwidth )
                           ( n = `draggable`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( draggable ) )
                           ( n = `growing`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
                           ( n = `growingThreshold`     v = growingthreshold )
                           ( n = `multiSelect`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( multiselect ) )
                           ( n = `noDataText`           v = nodatatext )
                           ( n = `rememberSelections`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rememberselections ) )
                           ( n = `resizable`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resizable ) )
                           ( n = `searchPlaceholder`    v = searchplaceholder )
                           ( n = `showClearButton`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearbutton ) )
                           ( n = `title`                v = title )
                           ( n = `titleAlignment`       v = titlealignment )
                           ( n = `items`                v = items )
                           ( n = `search`               v = search )
                           ( n = `confirm`              v = confirm )
                           ( n = `cancel`               v = cancel )
                           ( n = `liveChange`           v = livechange )
                           ( n = `selectionChange`      v = selectionchange )
                           ( n = `visible`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD tab_container.
    result = _generic( name = `TabContainer`
                       ns   = `webc` ).
  ENDMETHOD.

  METHOD task.
    result = _generic( name   = `Task`
                       ns     = `shapes`
                       t_prop = VALUE #( ( n = `time` v = time )
                                         ( n = `endTime` v = endtime )
                                         ( n = `id` v = id )
                                         ( n = `type` v = type )
                                         ( n = `connectable` v = connectable )
                                         ( n = `title` v = title )
                                         ( n = `showTitle` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtitle ) )
                                         ( n = `color` v = color ) ) ).
  ENDMETHOD.

  METHOD template_else.

    result = _generic( name = `else`
                       ns   = `template` ).

  ENDMETHOD.

  METHOD template_elseif.

    result = _generic( name   = `elseif`
                       ns     = `template`
                       t_prop = VALUE #( ( n = `test`  v = test ) ) ).

  ENDMETHOD.

  METHOD template_if.

    result = _generic( name   = `if`
                       ns     = `template`
                       t_prop = VALUE #( ( n = `test`  v = test ) ) ).

  ENDMETHOD.

  METHOD template_repeat.

    result = _generic( name   = `repeat`
                       ns     = `template`
                       t_prop = VALUE #( ( n = `list`  v = list )
                                         ( n = `var`  v = var ) ) ).

  ENDMETHOD.

  METHOD template_then.

    result = _generic( name = `then`
                       ns   = `template` ).

  ENDMETHOD.

  METHOD template_with.

    result = _generic( name   = `with`
                       ns     = `template`
                       t_prop = VALUE #( ( n = `path`  v = path )
                                         ( n = `helper`  v = helper )
                                         ( n = `var`  v = var ) ) ).

  ENDMETHOD.

  METHOD text.
    result = me.
    _generic( name   = `Text`
              ns     = ns
              t_prop = VALUE #( ( n = `text`  v = text )
                                ( n = `emptyIndicatorMode`  v = emptyindicatormode )
                                ( n = `maxLines`  v = maxlines )
                                ( n = `renderWhitespace`  v = renderwhitespace )
                                ( n = `textAlign`  v = textalign )
                                ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `width`  v = width )
                                ( n = `id`  v = id )
                                ( n = `wrapping`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                                ( n = `wrappingType`  v = wrappingtype )
                                ( n = `class` v = class ) ) ).
  ENDMETHOD.

  METHOD text_area.
    result = me.
    _generic( name   = `TextArea`
              t_prop = VALUE #(
                  ( n = `value` v = value )
                  ( n = `rows` v = rows )
                  ( n = `cols` v = cols )
                  ( n = `height` v = height )
                  ( n = `width` v = width )
                  ( n = `wrapping` v = wrapping )
                  ( n = `maxLength` v = maxlength )
                  ( n = `textAlign` v = textalign )
                  ( n = `textDirection` v = textdirection )
                  ( n = `showValueStateMessage` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
                  ( n = `showExceededText` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showexceededtext ) )
                  ( n = `valueLiveUpdate` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( valueliveupdate ) )
                  ( n = `editable` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                  ( n = `class` v = class )
                  ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                  ( n = `id` v = id )
                  ( n = `growing` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( growing ) )
                  ( n = `growingMaxLines` v = growingmaxlines )
                  ( n = `required`        v = required )
                  ( n = `valueState`      v = valuestate )
                  ( n = `placeholder`      v = placeholder )
                  ( n = `valueStateText`  v = valuestatetext ) ) ).
  ENDMETHOD.

  METHOD tile_content.

    result = _generic( name   = `TileContent`
                       ns     = ``
                       t_prop = VALUE #( ( n = `unit`   v = unit )
                                         ( n = `footerColor`   v = footercolor )
                                         ( n = `blocked`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( blocked ) )
                                         ( n = `frameType`   v = frametype )
                                         ( n = `priority`   v = priority )
                                         ( n = `priorityText`   v = prioritytext )
                                         ( n = `state`   v = state )
                                         ( n = `disabled`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( disabled ) )
                                         ( n = `visible`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `footer` v = footer )
                                         ( n = `class` v = class ) ) ).

  ENDMETHOD.

  METHOD tile_info.
    result = _generic( name   = `TileInfo`
                       t_prop = VALUE #( ( n = `id`               v = id )
                                         ( n = `class`               v = class )
                                         ( n = `backgroundColor`            v = backgroundcolor )
                                         ( n = `borderColor`       v = bordercolor )
                                         ( n = `src`       v = src )
                                         ( n = `text`             v = text )
                                         ( n = `textColor`  v = textcolor )
                         ) ).

  ENDMETHOD.

  METHOD timeline.

    result = _generic(
        name   = `Timeline`
        ns     = `commons`
        t_prop = VALUE #( ( n = `id`                 v = id )
                          ( n = `enableDoubleSided`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabledoublesided ) )
                          ( n = `groupBy`            v = groupby )
                          ( n = `growingThreshold`   v = growingthreshold )
                          ( n = `filterTitle`        v = filtertitle )
                          ( n = `sortOldestFirst`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sortoldestfirst ) )
                          ( n = `enableModelFilter`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablemodelfilter ) )
                          ( n = `enableScroll`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablescroll ) )
                          ( n = `forceGrowing`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( forcegrowing ) )
                          ( n = `group`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( group ) )
                          ( n = `lazyLoading`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( lazyloading ) )
                          ( n = `showHeaderBar`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showheaderbar ) )
                          ( n = `showIcons`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showicons ) )
                          ( n = `showItemFilter`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showitemfilter ) )
                          ( n = `showSearch`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsearch ) )
                          ( n = `showSort`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsort ) )
                          ( n = `showTimeFilter`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showtimefilter ) )
                          ( n = `sort`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sort ) )
                          ( n = `groupByType`        v = groupbytype )
                          ( n = `textHeight`         v = textheight )
                          ( n = `width`              v = width )
                          ( n = `height`             v = height )
                          ( n = `noDataText`         v = nodatatext )
                          ( n = `alignment`          v = alignment )
                          ( n = `axisOrientation`    v = axisorientation )
                          ( n = `filterList`         v = filterlist )
                          ( n = `customFilter`       v = customfilter )
                          ( n = `content`            v = content ) ) ).
  ENDMETHOD.

  METHOD timeline_item.

    result = _generic(
        name   = `TimelineItem`
        ns     = `commons`
        t_prop = VALUE #( ( n = `id`                     v = id )
                          ( n = `dateTime`               v = datetime )
                          ( n = `title`                  v = title )
                          ( n = `userNameClickable`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usernameclickable ) )
                          ( n = `useIconTooltip`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( useicontooltip ) )
                          ( n = `userNameClicked`        v = usernameclicked )
                          ( n = `userPicture`            v = userpicture )
                          ( n = `select`                 v = select )
                          ( n = `text`                   v = text )
                          ( n = `userName`               v = username )
                          ( n = `filterValue`            v = filtervalue )
                          ( n = `iconDisplayShape`       v = icondisplayshape )
                          ( n = `iconInitials`           v = iconinitials )
                          ( n = `iconSize`               v = iconsize )
                          ( n = `iconTooltip`            v = icontooltip )
                          ( n = `maxCharacters`          v = maxcharacters )
                          ( n = `replyCount`             v = replycount )
                          ( n = `status`                 v = status )
                          ( n = `customActionClicked`    v = customactionclicked )
                          ( n = `press`                  v = press )
                          ( n = `replyListOpen`          v = replylistopen )
                          ( n = `replyPost`              v = replypost )
                          ( n = `icon`                   v = icon ) ) ).
  ENDMETHOD.

  METHOD time_horizon.
    result = _generic( name   = `TimeHorizon`
                       ns     = `config`
                       t_prop = VALUE #( ( n = `startTime` v = starttime )
                                         ( n = `endTime`   v = endtime ) ) ).
  ENDMETHOD.

  METHOD time_picker.
    result = me.
    _generic( name   = `TimePicker`
              t_prop = VALUE #(
                  ( n = `value` v = value )
                  ( n = `dateValue`  v = datevalue )
                  ( n = `localeId`  v = localeid )
                  ( n = `placeholder`  v = placeholder )
                  ( n = `mask`  v = mask )
                  ( n = `maskMode`  v = maskmode )
                  ( n = `minutesStep`  v = minutesstep )
                  ( n = `name`  v = name )
                  ( n = `placeholderSymbol`  v = placeholdersymbol )
                  ( n = `secondsStep`  v = secondsstep )
                  ( n = `textAlign`  v = textalign )
                  ( n = `textDirection`  v = textdirection )
                  ( n = `title`  v = title )
                  ( n = `showCurrentTimeButton` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcurrenttimebutton ) )
                  ( n = `showValueStateMessage` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
                  ( n = `support2400` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( support2400 ) )
                  ( n = `initialFocusedDateValue` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( initialfocuseddatevalue ) )
                  ( n = `hideInput` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideinput ) )
                  ( n = `editable` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                  ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                  ( n = `required` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                  ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                  ( n = `width` v = width )
                  ( n = `valueState` v = valuestate )
                  ( n = `valueStateText` v = valuestatetext )
                  ( n = `displayFormat` v = displayformat )
                  ( n = `afterValueHelpClose` v = aftervaluehelpclose )
                  ( n = `afterValueHelpOpen` v = aftervaluehelpopen )
                  ( n = `change` v = change )
                  ( n = `liveChange` v = livechange )
                  ( n = `valueFormat` v = valueformat ) ) ).
  ENDMETHOD.

  METHOD title.
    DATA(lv_name) = COND #( WHEN ns = `f` THEN `title` ELSE `Title` ).

    result = me.
    _generic( ns     = ns
              name   = lv_name
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `class`     v = class )
                                ( n = `id`     v = id )
                                ( n = `wrappingType`     v = wrappingtype )
                                ( n = `textAlign`     v = textalign )
                                ( n = `textDirection`     v = textdirection )
                                ( n = `titleStyle`     v = titlestyle )
                                ( n = `width`     v = width )
                                ( n = `wrapping` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( wrapping ) )
                                ( n = `visible` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                ( n = `level` v = level ) ) ).
  ENDMETHOD.

  METHOD toggle_button.

    result = me.
    _generic( name   = `ToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `class`   v = class )
                                ( n = `pressed` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( pressed ) ) ) ).
  ENDMETHOD.

  METHOD token.

    result = me.
    _generic( name   = `Token`
              t_prop = VALUE #( ( n = `key`      v = key )
                                ( n = `text`     v = text )
                                ( n = `selected` v = selected )
                                ( n = `visible`  v = visible )
                                ( n = `editable`  v = editable ) ) ).
  ENDMETHOD.

  METHOD tokens.

    result = _generic( name = `tokens`
                       ns   = ns ).

  ENDMETHOD.

  METHOD toolbar.
    DATA(lv_name) = COND #(
        WHEN ns = `table` THEN `toolbar`
        WHEN ns = `form`  THEN `toolbar`
        ELSE `Toolbar` ).
    result = _generic( name   = lv_name
                       ns     = ns
                       t_prop = VALUE #( ( n = `active`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( active ) )
                                         ( n = `ariaHasPopup`  v = ariahaspopup )
                                         ( n = `design`  v = design )
                                         ( n = `enabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `height`  v = height )
                                         ( n = `style`  v = style )
                                         ( n = `width`  v = width )
                                         ( n = `id`  v = id )
                                         ( n = `press`  v = press ) ) ).

  ENDMETHOD.

  METHOD toolbar_spacer.

    result = me.
    _generic( name   = `ToolbarSpacer`
              ns     = ns
              t_prop = VALUE #( ( n = `width`     v = width ) ) ).
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
    result = _generic(
                 name   = `Tree`
                 t_prop = VALUE #(
                     ( n = `id`               v = id )
                     ( n = `items`            v = items )
                     ( n = `headerText`       v = headertext )
                     ( n = `footerText`       v = footertext )
                     ( n = `mode`             v = mode )
                     ( n = `toggleOpenState`  v = toggleopenstate )
                     ( n = `width`            v = width )
                     ( n = `selectionChange`            v = selectionchange )
                     ( n = `itemPress`            v = itempress )
                     ( n = `select`            v = select )
                     ( n = `multiSelectMode`            v = multiselectmode )
                     ( n = `noDataText`            v = nodatatext )
                     ( n = `headerLevel`            v = headerlevel )
                     ( n = `includeItemInSelection`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( includeiteminselection ) )
                     ( n = `showNoData`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownodata ) )
                     ( n = `inset`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inset ) )
                   ) ).

  ENDMETHOD.

  METHOD tree_column.

    result = _generic( name   = `Column`
                       ns     = `table`
                       t_prop = VALUE #( ( n = `label`      v = label )
                                         ( n = `template`   v = template )
                                         ( n = `hAlign`     v = halign )
                                         ( n = `width`      v = width ) ) ).

  ENDMETHOD.

  METHOD tree_columns.

    result = _generic( name = `columns`
                       ns   = `table` ).

  ENDMETHOD.

  METHOD tree_table.

    result = _generic(
                 name   = `TreeTable`
                 ns     = `table`
                 t_prop = VALUE #(
                     ( n = `rows`                    v = rows )
                     ( n = `selectionMode`           v = selectionmode )
                     ( n = `enableColumnReordering`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecolumnreordering ) )
                     ( n = `expandFirstLevel`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( expandfirstlevel ) )
                     ( n = `columnSelect`            v = columnselect )
                     ( n = `rowSelectionChange`      v = rowselectionchange )
                     ( n = `selectionBehavior`       v = selectionbehavior )
                     ( n = `id`                      v = id )
                     ( n = `alternateRowColors`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( alternaterowcolors ) )
                     ( n = `columnHeaderVisible`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( columnheadervisible ) )
                     ( n = `enableCellFilter`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecellfilter ) )
                     ( n = `enableColumnFreeze`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecolumnfreeze ) )
                     ( n = `enableCustomFilter`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecustomfilter ) )
                     ( n = `enableSelectAll`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableselectall ) )
                     ( n = `showNoData`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownodata ) )
                     ( n = `showOverlay`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showoverlay ) )
                     ( n = `visible`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                     ( n = `columnHeaderHeight`           v = columnheaderheight )
                     ( n = `firstVisibleRow`           v = firstvisiblerow )
                     ( n = `fixedColumnCount`           v = fixedcolumncount )
                     ( n = `threshold`           v = threshold )
                     ( n = `width`           v = width )
                     ( n = `useGroupMode`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usegroupmode ) )
                     ( n = `groupHeaderProperty`           v = groupheaderproperty )
                     ( n = `rowActionCount`           v = rowactioncount )
                     ( n = `selectedIndex`           v = selectedindex )
                     ( n = `rowHeight`           v = rowheight )
                     ( n = `fixedRowCount`           v = fixedrowcount )
                     ( n = `fixedBottomRowCount`           v = fixedbottomrowcount )
                     ( n = `minAutoRowCount`           v = minautorowcount )
                     ( n = `visibleRowCount`         v = visiblerowcount )
                     ( n = `toggleOpenState`         v = toggleopenstate )
                     ( n = `visibleRowCountMode`     v = visiblerowcountmode ) ) ).

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
    result = _generic( name   = `Column`
                       ns     = `table`
                       t_prop = VALUE #(
                           ( n = `id` v = id )
                           ( n = `width` v = width )
                           ( n = `showSortMenuEntry`    v = showsortmenuentry )
                           ( n = `sortProperty`         v = sortproperty )
                           ( n = `showFilterMenuEntry`  v = showfiltermenuentry )
                           ( n = `autoResizable`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( autoresizable ) )
                           ( n = `defaultFilterOperator` v = defaultfilteroperator )
                           ( n = `filterProperty` v = filterproperty )
                           ( n = `filterType` v = filtertype )
                           ( n = `hAlign` v = halign )
                           ( n = `minWidth` v = minwidth )
                           ( n = `resizable` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resizable ) )
                           ( n = `visible` v = visible ) ) ).
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
    result = _generic( name   = `RowActionItem`
                       ns     = `table`
                       t_prop = VALUE #( ( n = `icon`     v = icon )
                                         ( n = `text`     v = text )
                                         ( n = `type`     v = type )
                                         ( n = `press`    v = press )
                                         ( n = `visible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD ui_row_action_template.
    result = _generic( name = `rowActionTemplate`
                       ns   = `table` ).
  ENDMETHOD.

  METHOD ui_table.

    result = _generic(
        name   = `Table`
        ns     = `table`
        t_prop = VALUE #(
            ( n = `rows`                      v = rows )
            ( n = `alternateRowColors`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( alternaterowcolors ) )
            ( n = `columnHeaderVisible`       v = columnheadervisible )
            ( n = `editable`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
            ( n = `class`                     v = class )
            ( n = `enableCellFilter`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablecellfilter ) )
            ( n = `enableGrouping`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablegrouping ) )
            ( n = `enableSelectAll`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableselectall ) )
            ( n = `firstVisibleRow`           v = firstvisiblerow )
            ( n = `fixedBottomRowCount`       v = fixedbottomrowcount )
            ( n = `fixedColumnCount`          v = fixedcolumncount )
            ( n = `rowActionCount`            v = rowactioncount )
            ( n = `fixedRowCount`             v = fixedrowcount )
            ( n = `minAutoRowCount`           v = minautorowcount )
            ( n = `rowHeight`                 v = rowheight )
            ( n = `selectedIndex`             v = selectedindex )
            ( n = `selectionMode`             v = selectionmode )
            ( n = `selectionBehavior`         v = selectionbehavior )
            ( n = `showColumnVisibilityMenu`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcolumnvisibilitymenu ) )
            ( n = `showNoData`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownodata ) )
            ( n = `threshold`                 v = threshold )
            ( n = `visibleRowCount`           v = visiblerowcount )
            ( n = `visibleRowCountMode`       v = visiblerowcountmode )
            ( n = `footer`                    v = footer )
            ( n = `filter`                    v = filter )
            ( n = `sort`                      v = sort )
            ( n = `customFilter`              v = customfilter )
            ( n = `id`                        v = id )
            ( n = `fl:flexibility`            v = flex )
            ( n = `rowSelectionChange`        v = rowselectionchange )
            ( n = `rowMode`                   v = rowmode ) ) ).

  ENDMETHOD.

  METHOD ui_template.

    result = _generic( name = `template`
                       ns   = `table` ).

  ENDMETHOD.

  METHOD upload_set.
    result = _generic(
                 name   = `UploadSet`
                 ns     = `upload`
                 t_prop = VALUE #(
                     ( n = `id`                       v = id )
                     ( n = `instantUpload`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( instantupload ) )
                     ( n = `showIcons`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showicons ) )
                     ( n = `uploadEnabled`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( uploadenabled ) )
                     ( n = `terminationEnabled`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( terminationenabled ) )
                     ( n = `uploadButtonInvisible`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( uploadbuttoninvisible ) )
                     ( n = `fileTypes`                v = filetypes )
                     ( n = `maxFileNameLength`        v = maxfilenamelength )
                     ( n = `maxFileSize`              v = maxfilesize )
                     ( n = `mediaTypes`               v = mediatypes )
                     ( n = `items`                    v = items )
                     ( n = `uploadUrl`                v = uploadurl )
                     ( n = `mode`                     v = mode )
                     ( n = `fileRenamed`              v = filerenamed )
                     ( n = `directory`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( directory ) )
                     ( n = `multiple`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( multiple ) )
                     ( n = `dragDropDescription`      v = dragdropdescription )
                     ( n = `dragDropText`             v = dragdroptext )
                     ( n = `noDataText`               v = nodatatext )
                     ( n = `noDataDescription`        v = nodatadescription )
                     ( n = `noDataIllustrationType`   v = nodataillustrationtype )
                     ( n = `afterItemEdited`          v = afteritemedited )
                     ( n = `afterItemRemoved`         v = afteritemremoved )
                     ( n = `beforeItemAdded`          v = beforeitemadded )
                     ( n = `beforeItemEdited`         v = beforeitemedited )
                     ( n = `beforeItemRemoved`        v = beforeitemremoved )
                     ( n = `beforeUploadStarts`       v = beforeuploadstarts )
                     ( n = `beforeUploadTermination`  v = beforeuploadtermination )
                     ( n = `fileNameLengthExceeded`   v = filenamelengthexceeded )
                     ( n = `fileSizeExceeded`         v = filesizeexceeded )
                     ( n = `fileTypeMismatch`         v = filetypemismatch )
                     ( n = `itemDragStart`            v = itemdragstart )
                     ( n = `itemDrop`                 v = itemdrop )
                     ( n = `mediaTypeMismatch`        v = mediatypemismatch )
                     ( n = `uploadTerminated`         v = uploadterminated )
                     ( n = `uploadCompleted`          v = uploadcompleted )
                     ( n = `afterItemAdded`           v = afteritemadded )
                     ( n = `sameFilenameAllowed`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( samefilenameallowed ) )
                     ( n = `selectionChanged`         v = selectionchanged ) ) ).
  ENDMETHOD.

  METHOD upload_set_item.
    result = _generic( name   = `UploadSetItem`
                       ns     = `upload`
                       t_prop = VALUE #( ( n = `fileName`      v = filename )
                                         ( n = `mediaType`     v = mediatype )
                                         ( n = `url`           v = url )
                                         ( n = `thumbnailUrl`  v = thumbnailurl )
                                         ( n = `markers`       v = markers )
                                         ( n = `enabledEdit`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablededit ) )
                                         ( n = `enabledRemove` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabledremove ) )
                                         ( n = `selected`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                         ( n = `visibleEdit`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visibleedit ) )
                                         ( n = `visibleRemove` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visibleremove ) )
                                         ( n = `uploadState`   v = uploadstate )
                                         ( n = `uploadUrl`     v = uploadurl )
                                         ( n = `openPressed`   v = openpressed )
                                         ( n = `removePressed` v = removepressed )
                                         ( n = `statuses`      v = statuses ) ) ).
  ENDMETHOD.

  METHOD upload_set_toolbar_placeholder.
    result = _generic( name = `UploadSetToolbarPlaceholder`
                       ns   = `upload` ).
  ENDMETHOD.

  METHOD variant_item.

    result = _generic(
                 name   = `VariantItem`
                 ns     = `vm`
                 t_prop = VALUE #(
                     ( n = `executeOnSelection`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( executeonselection ) )
                     ( n = `global`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( global ) )
                     ( n = `labelReadOnly`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( labelreadonly ) )
                     ( n = `lifecyclePackage`        v = lifecyclepackage )
                     ( n = `lifecycleTransportId`    v = lifecycletransportid )
                     ( n = `namespace`               v = namespace )
                     ( n = `readOnly`                v = readonly )
                     ( n = `executeOnSelect`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( executeonselect ) )
                     ( n = `author`                  v = author )
                     ( n = `changeable`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( changeable ) )
                     ( n = `enabled`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                     ( n = `favorite`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( favorite ) )
                     ( n = `key`                     v = key )
                     ( n = `text`                    v = text )
                     ( n = `title`                   v = title )
                     ( n = `textDirection`           v = textdirection )
                     ( n = `originalTitle`           v = originaltitle )
                     ( n = `originalExecuteOnSelect` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( originalexecuteonselect ) )
                     ( n = `remove`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( remove ) )
                     ( n = `rename`                  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rename ) )
                     ( n = `originalFavorite`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( originalfavorite ) )
                     ( n = `sharing`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sharing ) )
                     ( n = `change`                  v = change ) ) ).

  ENDMETHOD.

  METHOD variant_items.

    result = _generic( name = `variantItems`
                       ns   = `vm` ).

  ENDMETHOD.

  METHOD variant_item_sapm.
    result = _generic(
        name   = `VariantItem`
        t_prop = VALUE #( ( n = `id`       v = id )
                          ( n = `author`    v = author )
                          ( n = `changeable`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( changeable ) )
                          ( n = `enabled`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                          ( n = `favorite`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( favorite ) )
                          ( n = `remove`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( remove ) )
                          ( n = `rename`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( rename ) )
                          ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `contexts` v = contexts )
                          ( n = `key`    v = key )
                          ( n = `sharing`    v = sharing )
                          ( n = `text`    v = text )
                          ( n = `textDirection`    v = textdirection )
                          ( n = `title`    v = title )
                          ( n = `executeOnSelect`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( executeonselect ) ) ) ).
  ENDMETHOD.

  METHOD variant_management.

    result = _generic(
                 name   = `VariantManagement`
                 ns     = `vm`
                 t_prop = VALUE #(
                     ( n = `defaultVariantKey`      v = defaultvariantkey )
                     ( n = `enabled`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                     ( n = `inErrorState`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inerrorstate ) )
                     ( n = `initialSelectionKey`    v = initialselectionkey )
                     ( n = `lifecycleSupport`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( lifecyclesupport ) )
                     ( n = `selectionKey`           v = selectionkey )
                     ( n = `showCreateTile`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcreatetile ) )
                     ( n = `showExecuteOnSelection` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showexecuteonselection ) )
                     ( n = `showSetAsDefault`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsetasdefault ) )
                     ( n = `showShare`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showshare ) )
                     ( n = `standardItemAuthor`     v = standarditemauthor )
                     ( n = `standardItemText`       v = standarditemtext )
                     ( n = `useFavorites`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usefavorites ) )
                     ( n = `variantItems`           v = variantitems )
                     ( n = `manage`                 v = manage )
                     ( n = `save`                   v = save )
                     ( n = `select`                 v = select )
                     ( n = `id`                     v = id )
                     ( n = `variantCreationByUserAllowed` v = uservarcreate )
                     ( n = `visible`                v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.

  METHOD variant_management_fl.
    result = _generic(
                 name   = `VariantManagement`
                 ns     = `flvm`
                 t_prop = VALUE #(
                     ( n = `displayTextForExecuteOnSelectionForStandardVariant`  v = displaytextfsv )
                     ( n = `editable`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                     ( n = `executeOnSelectionForStandardDefault`
                       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( executeonselectionforstandflt ) )
                     ( n = `headerLevel`      v = headerlevel )
                     ( n = `inErrorState`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inerrorstate ) )
                     ( n = `maxWidth`      v = maxwidth )
                     ( n = `modelName`      v = modelname )
                     ( n = `resetOnContextChange`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( resetoncontextchange ) )
                     ( n = `showSetAsDefault`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsetasdefault ) )
                     ( n = `titleStyle`      v = titlestyle )
                     ( n = `updateVariantInURL`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( updatevariantinurl ) )
                     ( n = `cancel`    v = cancel )
                     ( n = `initialized`    v = initialized )
                     ( n = `manage`    v = manage )
                     ( n = `save`    v = save )
                     ( n = `select`    v = select )
                     ( n = `for`  v = for ) ) ).
  ENDMETHOD.

  METHOD variant_management_sapm.
    result = _generic(
        name   = `VariantManagement`
        t_prop = VALUE #(
            ( n = `id`       v = id )
            ( n = `defaultKey`    v = defaultkey )
            ( n = `level`    v = level )
            ( n = `maxWidth`    v = maxwidth )
            ( n = `popoverTitle`    v = popovertitle )
            ( n = `selectedKey`    v = selectedkey )
            ( n = `titleStyle`    v = titlestyle )
            ( n = `cancel`    v = cancel )
            ( n = `manage`    v = manage )
            ( n = `manageCancel`    v = managecancel )
            ( n = `save`    v = save )
            ( n = `select`    v = select )
            ( n = `items`    v = items )
            ( n = `creationAllowed`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( creationallowed ) )
            ( n = `inErrorState`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inerrorstate ) )
            ( n = `modified`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( modified ) )
            ( n = `showFooter`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfooter ) )
            ( n = `showSaveAs`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showsaveas ) )
            ( n = `supportApplyAutomatically`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( supportapplyautomatically ) )
            ( n = `supportContexts`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( supportcontexts ) )
            ( n = `supportDefault`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( supportdefault ) )
            ( n = `supportFavorites`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( supportfavorites ) )
            ( n = `supportPublic`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( supportpublic ) )
            ( n = `visible`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                        ) ).

  ENDMETHOD.

  METHOD vbox.

    result = _generic(
        name   = `VBox`
        t_prop = VALUE #( ( n = `height`          v = height )
                          ( n = `id`  v = id )
                          ( n = `justifyContent`  v = justifycontent )
                          ( n = `renderType`      v = rendertype )
                          ( n = `alignContent`    v = aligncontent )
                          ( n = `alignItems`      v = alignitems )
                          ( n = `width`           v = width )
                          ( n = `wrap`            v = wrap )
                          ( n = `backgroundDesign`            v = backgrounddesign )
                          ( n = `direction`            v = direction )
                          ( n = `displayInline`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( displayinline ) )
                          ( n = `visible`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                          ( n = `fitContainer`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( fitcontainer ) )
                          ( n = `class`           v = class ) ) ).

  ENDMETHOD.

  METHOD vertical_layout.

    result = _generic( name   = `VerticalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `visible`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `enabled`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.

  METHOD view_settings_dialog.

    result = _generic( name   = `ViewSettingsDialog`
                       t_prop = VALUE #(
                           ( n = `confirm`                  v = confirm )
                           ( n = `cancel`                   v = cancel )
                           ( n = `filterDetailPageOpened`   v = filterdetailpageopened )
                           ( n = `reset`                    v = reset )
                           ( n = `resetFilters`             v = resetfilters )
                           ( n = `filterSearchOperator`     v = filtersearchoperator )
                           ( n = `groupDescending`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( groupdescending ) )
                           ( n = `sortDescending`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( sortdescending ) )
                           ( n = `title`                    v = title )
                           ( n = `selectedGroupItem`        v = selectedgroupitem )
                           ( n = `selectedPresetFilterItem` v = selectedpresetfilteritem )
                           ( n = `selectedSortItem`         v = selectedsortitem )
                           ( n = `filterItems`              v = filteritems )
                           ( n = `sortItems`                v = sortitems )
                           ( n = `groupItems`               v = groupitems )
                           ( n = `titleAlignment`           v = titlealignment ) ) ).

  ENDMETHOD.

  METHOD view_settings_filter_item.
    result = _generic(
                 name   = `ViewSettingsFilterItem`
                 t_prop = VALUE #( ( n = `enabled`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                   ( n = `key`             v = key )
                                   ( n = `selected`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                   ( n = `text`            v = text )
                                   ( n = `textDirection`   v = textdirection )
                                   ( n = `multiSelect`     v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( multiselect ) ) ) ).
  ENDMETHOD.

  METHOD view_settings_item.
    result = _generic( name   = `ViewSettingsItem`
                       t_prop = VALUE #( ( n = `enabled`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `key`             v = key )
                                         ( n = `selected`        v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( selected ) )
                                         ( n = `text`            v = text )
                                         ( n = `textDirection`   v = textdirection ) ) ).

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
    result = _generic( name   = `Wizard`
                       t_prop = VALUE #(
                           ( n = `id`                   v = id )
                           ( n = `class`                v = class )
                           ( n = `backgroundDesign`     v = backgrounddesign )
                           ( n = `busy`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( busy ) )
                           ( n = `busyIndicatorDelay`   v = busyindicatordelay )
                           ( n = `busyIndicatorSize`    v = busyindicatorsize )
                           ( n = `enableBranching`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablebranching ) )
                           ( n = `fieldGroupIds`        v = fieldgroupids )
                           ( n = `finishButtonText`     v = finishbuttontext )
                           ( n = `height`               v = height )
                           ( n = `renderMode`           v = rendermode )
                           ( n = `showNextButton`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shownextbutton ) )
                           ( n = `stepTitleLevel`       v = steptitlelevel )
                           ( n = `visible`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                           ( n = `width`                v = width )
                           ( n = `complete`             v = complete )
                           ( n = `navigationChange`     v = navigationchange )
                           ( n = `stepActivate`         v = stepactivate ) ) ).

  ENDMETHOD.

  METHOD wizard_step.

    result = _generic( name   = `WizardStep`
                       t_prop = VALUE #(
                           (  n = `id`                   v = id )
                           (  n = `busy`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( busy ) )
                           (  n = `busyIndicatorDelay`   v = busyindicatordelay )
                           (  n = `busyIndicatorSize`    v = busyindicatorsize )
                           (  n = `fieldGroupIds`        v = fieldgroupids )
                           (  n = `icon`                 v = icon )
                           (  n = `optional`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( optional ) )
                           (  n = `title`                v = title )
                           (  n = `validated`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( validated ) )
                           (  n = `visible`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                           (  n = `activate`             v = activate )
                           (  n = `complete`             v = complete )
                           (  n = `nextStep`             v = nextstep )
                           (  n = `subsequentSteps`      v = subsequentsteps ) ) ).
  ENDMETHOD.

  METHOD xml_get.

    DATA lt_parts TYPE string_table.
    xml_get_parts( CHANGING ct_parts = lt_parts ).
    result = concat_lines_of( lt_parts ).

  ENDMETHOD.


  METHOD xml_get_parts.

    IF mv_name = `ZZPLAIN`.
      APPEND mt_prop[ n = `VALUE` ]-v TO ct_parts.
      RETURN.
    ENDIF.

    IF me = mo_root.

      IF st_ns_map IS INITIAL.

        st_ns_map = VALUE #(
          ( n = `z2ui5`             v = `z2ui5.cc` )
          ( n = `layout`            v = `sap.ui.layout` )
          ( n = `networkgraph`      v = `sap.suite.ui.commons.networkgraph` )
          ( n = `nglayout`          v = `sap.suite.ui.commons.networkgraph.layout` )
          ( n = `ngcustom`          v = `sap.suite.ui.commons.sample.NetworkGraphCustomRendering` )
          ( n = `table`             v = `sap.ui.table` )
          ( n = `template`          v = `http://schemas.sap.com/sapui5/extension/sap.ui.core.template/1` )
          ( n = `customData`        v = `http://schemas.sap.com/sapui5/extension/sap.ui.core.CustomData/1` )
          ( n = `f`                 v = `sap.f` )
          ( n = `columnmenu`        v = `sap.m.table.columnmenu` )
          ( n = `card`              v = `sap.f.cards` )
          ( n = `dnd`               v = `sap.ui.core.dnd` )
          ( n = `dnd-grid`          v = `sap.f.dnd` )
          ( n = `grid`              v = `sap.ui.layout.cssgrid` )
          ( n = `form`              v = `sap.ui.layout.form` )
          ( n = `editor`            v = `sap.ui.codeeditor` )
          ( n = `mchart`            v = `sap.suite.ui.microchart` )
          ( n = `smartFilterBar`    v = `sap.ui.comp.smartfilterbar` )
          ( n = `smartVariantManagement`    v = `sap.ui.comp.smartvariants` )
          ( n = `smartTable`        v = `sap.ui.comp.smarttable` )
          ( n = `webc`              v = `sap.ui.webc.main` )
          ( n = `uxap`              v = `sap.uxap` )
          ( n = `sap`               v = `sap` )
          ( n = `text`              v = `sap.ui.richtexteditor` )
          ( n = `html`              v = `http://www.w3.org/1999/xhtml` )
          ( n = `fb`                v = `sap.ui.comp.filterbar` )
          ( n = `u`                 v = `sap.ui.unified` )
          ( n = `gantt`             v = `sap.gantt.simple` )
          ( n = `axistime`          v = `sap.gantt.axistime` )
          ( n = `config`            v = `sap.gantt.config` )
          ( n = `shapes`            v = `sap.gantt.simple.shapes` )
          ( n = `commons`           v = `sap.suite.ui.commons` )
          ( n = `si`                v = `sap.suite.ui.commons.statusindicator` )
          ( n = `vm`                v = `sap.ui.comp.variants` )
          ( n = `viz`               v = `sap.viz.ui5.controls` )
          ( n = `viz.data`          v = `sap.viz.ui5.data` )
          ( n = `viz.feeds`         v = `sap.viz.ui5.controls.common.feeds` )
          ( n = `vk`                v = `sap.ui.vk` )
          ( n = `vbm`               v = `sap.ui.vbm` )
          ( n = `ndc`               v = `sap.ndc` )
          ( n = `svm`               v = `sap.ui.comp.smartvariants` )
          ( n = `flvm`              v = `sap.ui.fl.variants` )
          ( n = `p13n`              v = `sap.m.p13n` )
          ( n = `upload`            v = `sap.m.upload` )
          ( n = `fl`                v = `sap.ui.fl` )
          ( n = `plugins`           v = `sap.m.plugins` )
          ( n = `tnt`               v = `sap.tnt` )
          ( n = `mdc`               v = `sap.ui.mdc` )
          ( n = `trm`               v = `sap.ui.table.rowmodes` )
          ( n = `smi`               v = `sap.ui.comp.smartmultiinput` )
          ( n = `ie`                v = `sap.suite.ui.commons.imageeditor` ) ).

      ENDIF.

      LOOP AT mt_ns REFERENCE INTO DATA(lr_ns) WHERE table_line IS NOT INITIAL  "#EC CI_SORTSEQ
                                                     AND table_line <> `mvc`
                                                     AND table_line <> `core`.
        TRY.
            DATA(ls_prop) = st_ns_map[ n = lr_ns->* ].
            INSERT VALUE #( n = |xmlns:{ ls_prop-n }|
                            v = ls_prop-v ) INTO TABLE mt_prop.
          CATCH cx_root.
            RAISE EXCEPTION TYPE z2ui5_cx_abap2ui5_error
              EXPORTING val = |XML_VIEW_ERROR_NO_NAMESPACE_FOUND_FOR:  { lr_ns->* }|.
        ENDTRY.
      ENDLOOP.

    ENDIF.

    DATA(lv_tmp2) = COND #( WHEN mv_ns <> `` THEN |{ mv_ns }:| ).
    DATA(lv_tmp3) = REDUCE string( INIT val = `` FOR row IN mt_prop WHERE ( v <> `` ) "#EC CI_SORTSEQ
                          NEXT val = |{ val } { row-n }="{ escape( val    = COND string( WHEN row-v = abap_true
                                                                                         THEN `true`
                                                                                         ELSE row-v )
                                                                   format = z2ui5_cl_abap2ui5_context=>cv_format_e_xml_attr ) }"| ).

    IF mt_child IS INITIAL.
      APPEND | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }/>| TO ct_parts.
      RETURN.
    ENDIF.

    APPEND | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }>| TO ct_parts.

    LOOP AT mt_child INTO DATA(lr_child).
      CAST z2ui5_cl_xml_view( lr_child )->xml_get_parts( CHANGING ct_parts = ct_parts ).
    ENDLOOP.

    APPEND |</{ lv_tmp2 }{ mv_name }>| TO ct_parts.

  ENDMETHOD.

  METHOD _cc_plain_xml.

    result = me.
    _generic( name   = `ZZPLAIN`
              ns     = `html`
              t_prop = VALUE #( ( n = `VALUE` v = val ) ) ).

  ENDMETHOD.

  METHOD _generic.

    TRY.
        INSERT CONV #( ns ) INTO TABLE mo_root->mt_ns.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    DATA(result2) = NEW z2ui5_cl_xml_view( ).
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

    result = NEW #( me ).

  ENDMETHOD.

  METHOD p_cell_selector.

    result = me.
    _generic( name   = `CellSelector`
              ns     = `plugins`
              t_prop = VALUE #( ( n = `id` v = id ) ) ).

  ENDMETHOD.

  METHOD p_copy_provider.

    result = me.
    _generic( name   = `CopyProvider`
              ns     = `plugins`
              t_prop = VALUE #( ( n = `id` v = id )
                                ( n = `copy` v = copy )
                                ( n = `extractData` v = extract_data )
                ) ).

  ENDMETHOD.

  METHOD date_range_selection.
    result = me.
    _generic( name   = `DateRangeSelection`
              t_prop = VALUE #(
                  ( n = `value`                 v = value )
                  ( n = `displayFormat`         v = displayformat )
                  ( n = `displayFormatType`         v = displayformattype )
                  ( n = `valueFormat`           v = valueformat )
                  ( n = `required`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                  ( n = `valueState`            v = valuestate )
                  ( n = `valueStateText`        v = valuestatetext )
                  ( n = `placeholder`           v = placeholder )
                  ( n = `textAlign`                v = textalign )
                  ( n = `textDirection`                v = textdirection )
                  ( n = `change`                v = change )
                  ( n = `maxDate`               v = maxdate )
                  ( n = `minDate`               v = mindate )
                  ( n = `width`               v = width )
                  ( n = `id`               v = id )
                  ( n = `dateValue`               v = datevalue )
                  ( n = `secondDateValue`         v = seconddatevalue )
                  ( n = `name`               v = name )
                  ( n = `class`               v = class )
                  ( n = `calendarWeekNumbering`               v = calendarweeknumbering )
                  ( n = `initialFocusedDateValue`               v = initialfocuseddatevalue )
                  ( n = `enabled`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                  ( n = `visible`               v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                  ( n = `editable`              v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                  ( n = `hideInput`             v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideinput ) )
                  ( n = `showFooter`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showfooter ) )
                  ( n = `showValueStateMessage` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showvaluestatemessage ) )
                  ( n = `showCurrentDateButton` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showcurrentdatebutton ) )
                  ( n = `delimiter` v = delimiter ) ) ).
  ENDMETHOD.

  METHOD toolbar_layout_data.
    result = _generic(
                 name   = `ToolbarLayoutData`
                 t_prop = VALUE #( ( n = `id`            v = id )
                                   ( n = `maxWidth`      v = maxwidth )
                                   ( n = `minWidth`      v = minwidth )
                                   ( n = `shrinkable`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( shrinkable ) ) ) ).
  ENDMETHOD.

  METHOD feed_content.
    result = _generic( name   = `FeedContent`
                       t_prop = VALUE #( ( n = `contentText`    v = contenttext )
                                         ( n = `subheader`      v = subheader )
                                         ( n = `value`          v = value )
                                         ( n = `class`          v = class )
                                         ( n = `press`          v = press ) ) ).

  ENDMETHOD.

  METHOD news_content.
    result = _generic( name   = `NewsContent`
                       t_prop = VALUE #( ( n = `contentText`    v = contenttext )
                                         ( n = `subheader`      v = subheader )
                                         ( n = `press`          v = press ) ) ).

  ENDMETHOD.

  METHOD splitter.
    result = _generic( name   = `Splitter`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `height`       v = height )
                                         ( n = `orientation`  v = orientation )
                                         ( n = `width`        v = width ) ) ).
  ENDMETHOD.

  METHOD invisible_text.
    result = _generic( ns     = ns
                       name   = `InvisibleText`
                       t_prop = VALUE #( ( n = `id`       v = id )
                                         ( n = `text`        v = text ) ) ).
  ENDMETHOD.

  METHOD fix_content.
    result = _generic( ns   = ns
                       name = `fixContent` ).
  ENDMETHOD.

  METHOD fix_flex.

    result = _generic( ns     = ns
                       name   = `FixFlex`
                       t_prop = VALUE #( ( n = `class`           v = class )
                                         ( n = `fixContentSize`  v = fixcontentsize ) ) ).
  ENDMETHOD.

  METHOD flex_content.
    result = _generic( ns   = ns
                       name = `flexContent` ).
  ENDMETHOD.

  METHOD side_navigation.

    result = _generic( name   = `SideNavigation`
                       ns     = `tnt`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class` v = class )
                                         ( n = `selectedKey`  v = selectedkey ) ) ).

  ENDMETHOD.

  METHOD navigation_list.

    result = _generic( name = `NavigationList`
                       ns   = `tnt` ).

  ENDMETHOD.

  METHOD navigation_list_item.

    result = me.
    _generic( name   = `NavigationListItem`
              ns     = `tnt`
              t_prop = VALUE #( ( n = `text`  v = text )
                                ( n = `icon`  v = icon )
                                ( n = `href`  v = href )
                                ( n = `key`   v = key )
                                ( n = `select`  v = select ) ) ).

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
    result = _generic(
        name   = `Field`
        ns     = ns
        t_prop = VALUE #( ( n = `id`        v = id )
                          ( n = `value`     v = value )
                          ( n = `editMode`  v = editmode )
                          ( n = `showEmptyIndicator`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showemptyindicator ) ) ) ).
  ENDMETHOD.

  METHOD color_picker.

    result = me.
    _generic( ns     = `u`
              name   = `ColorPicker`
              t_prop = VALUE #( ( n = `colorString`       v = colorstring )
                                ( n = `displayMode`        v = displaymode )
                                ( n = `change`             v = change )
                                ( n = `liveChange`        v = livechange ) ) ).

  ENDMETHOD.

  METHOD tiles.
    result = _generic( `tiles` ).
  ENDMETHOD.

  METHOD analytical_column.
    result = _generic( ns   = ns
                       name = `AnalyticalColumn` ).
  ENDMETHOD.

  METHOD analytical_table.
    result = _generic( name   = `AnalyticalTable`
                       ns     = ns
                       t_prop = VALUE #( ( n = `selectionMode`              v = selectionmode )
                                         ( n = `rowMode`                    v = rowmode )
                                         ( n = `toolbar`                    v = toolbar )
                                         ( n = `columns`                    v = columns ) ) ).
  ENDMETHOD.

  METHOD auto.
    result = _generic( ns     = ns
                       name   = `Auto`
                       t_prop = VALUE #( ( n = `rowContentHeight`    v = rowcontentheight )
                                         ( n = `minRowCount`         v = minrowcount )
                                         ( n = `maxRowCount`         v = maxrowcount )
                                         ( n = `fixedTopRowCount`    v = fixedtoprowcount )
                                         ( n = `fixedBottomRowCount` v = fixedbottomrowcount ) ) ).
  ENDMETHOD.

  METHOD fixed.
    result = _generic( ns     = ns
                       name   = `Fixed`
                       t_prop = VALUE #( ( n = `rowCount`            v = rowcount )
                                         ( n = `rowContentHeight`    v = rowcontentheight )
                                         ( n = `fixedTopRowCount`    v = fixedtoprowcount )
                                         ( n = `fixedBottomRowCount` v = fixedbottomrowcount ) ) ).
  ENDMETHOD.

  METHOD interactive.
    result = _generic( ns     = ns
                       name   = `Interactive`
                       t_prop = VALUE #( ( n = `rowCount`            v = rowcount )
                                         ( n = `minRowCount`         v = minrowcount )
                                         ( n = `maxRowCount`         v = maxrowcount )
                                         ( n = `rowContentHeight`    v = rowcontentheight )
                                         ( n = `fixedTopRowCount`    v = fixedtoprowcount )
                                         ( n = `fixedBottomRowCount` v = fixedbottomrowcount ) ) ).
  ENDMETHOD.

  METHOD product_switch.
    result = _generic( ns     = `f`
                       name   = `ProductSwitch`
                       t_prop = VALUE #( ( n = `id`     v = id )
                                         ( n = `change` v = change ) ) ).
  ENDMETHOD.

  METHOD product_switch_item.
    result = _generic( ns     = `f`
                       name   = `ProductSwitchItem`
                       t_prop = VALUE #( ( n = `id`        v = id )
                                         ( n = `src`       v = src )
                                         ( n = `imageSrc`  v = imagesrc )
                                         ( n = `title`     v = title )
                                         ( n = `subTitle`  v = subtitle )
                                         ( n = `target`    v = target )
                                         ( n = `targetSrc` v = targetsrc ) ) ).
  ENDMETHOD.

  METHOD grid_container.
    result = _generic( ns     = `f`
                       name   = `GridContainer`
                       t_prop = VALUE #( ( n = `id`                v = id )
                                         ( n = `width`             v = width )
                                         ( n = `minHeight`         v = minheight )
                                         ( n = `containerQuery`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( containerquery ) )
                                         ( n = `snapToRow`         v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( snaptorow ) )
                                         ( n = `allowDenseFill`    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( allowdensefill ) )
                                         ( n = `inlineBlockLayout` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( inlineblocklayout ) )
                                         ( n = `layoutChange`      v = layoutchange )
                                         ( n = `columnsChange`     v = columnschange )
                                         ( n = `borderReached`     v = borderreached ) ) ).
  ENDMETHOD.

  METHOD grid_container_settings.
    result = _generic( ns     = `f`
                       name   = `GridContainerSettings`
                       t_prop = VALUE #( ( n = `columns`       v = columns )
                                         ( n = `columnSize`    v = columnsize )
                                         ( n = `minColumnSize` v = mincolumnsize )
                                         ( n = `maxColumnSize` v = maxcolumnsize )
                                         ( n = `rowSize`       v = rowsize )
                                         ( n = `gap`           v = gap ) ) ).
  ENDMETHOD.

  METHOD layout.
    result = _generic( name = `layout`
                       ns   = ns ).
  ENDMETHOD.

  METHOD dynamic_date_range.
    result = _generic( name   = `DynamicDateRange`
                       t_prop = VALUE #( ( n = `id`                 v = id )
                                         ( n = `value`              v = value )
                                         ( n = `width`              v = width )
                                         ( n = `enabled`            v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enabled ) )
                                         ( n = `editable`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
                                         ( n = `required`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( required ) )
                                         ( n = `name`               v = name )
                                         ( n = `placeholder`        v = placeholder )
                                         ( n = `valueState`         v = valuestate )
                                         ( n = `valueStateText`     v = valuestatetext )
                                         ( n = `enableGroupHeaders` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enablegroupheaders ) )
                                         ( n = `hideInput`          v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( hideinput ) )
                                         ( n = `showClearIcon`      v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showclearicon ) )
                                         ( n = `change`             v = change ) ) ).
  ENDMETHOD.

  METHOD rowmode.
    result = _generic( name = `rowMode`
                       ns   = ns ).
  ENDMETHOD.

  METHOD breadcrumbs.
    result = _generic(
        ns     = ns
        name   = `Breadcrumbs`
        t_prop = VALUE #( ( n = `links`                   v = link )
                          ( n = `id`                      v = id )
                          ( n = `class`                   v = class )
                          ( n = `currentLocationText`     v = currentlocationtext )
                          ( n = `separatorStyle`          v = separatorstyle )
                          ( n = `visible`                 v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.

  METHOD current_location.
    result = _generic( ns     = ns
                       name   = `currentLocation`
                       t_prop = VALUE #( ( n = `link`           v = link ) ) ).
  ENDMETHOD.

  METHOD color_palette.
    result = _generic( ns     = ns
                       name   = `ColorPalette`
                       t_prop = VALUE #( ( n = `colorSelect`           v = colorselect ) ) ).
  ENDMETHOD.

  METHOD harveyballmicrochartitem.

    result = _generic( name   = `HarveyBallMicroChartItem`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `class`  v = class )
                                         ( n = `fraction`  v = fraction )
                                         ( n = `color`  v = color )
                                         ( n = `fractionScale` v = fractionscale ) ) ).
  ENDMETHOD.

  METHOD smart_filter_bar.

    result = _generic( name   = `SmartFilterBar`
                       ns     = `smartFilterBar`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `entitySet`  v = entityset )
                                         ( n = `persistencyKey`  v = persistencykey ) ) ).

  ENDMETHOD.

  METHOD control_configuration.

    result = me.
    _generic( name   = `ControlConfiguration`
              ns     = `smartFilterBar`
              t_prop = VALUE #(
                  ( n = `id`  v = id )
                  ( n = `key`  v = key )
                  ( n = `visibleInAdvancedArea`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visibleinadvancedarea ) )
                  ( n = `preventInitialDataFetchInValueHelpDialog`
                    v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( previnitdatafetchinvalhelpdia ) )
                                ) ).

  ENDMETHOD.

  METHOD smart_table.

    result = _generic(
        name   = `SmartTable`
        ns     = `smartTable`
        t_prop = VALUE #(
            ( n = `id`  v = id )
            ( n = `smartFilterId`  v = smartfilterid )
            ( n = `tableType`  v = tabletype )
            ( n = `editable`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( editable ) )
            ( n = `initiallyVisibleFields`  v = initiallyvisiblefields )
            ( n = `entitySet`  v = entityset )
            ( n = `useVariantManagement`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usevariantmanagement ) )
            ( n = `useExportToExcel`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( useexporttoexcel ) )
            ( n = `useTablePersonalisation`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( usetablepersonalisation ) )
            ( n = `header`  v = header )
            ( n = `showRowCount`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( showrowcount ) )
            ( n = `enableExport`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableexport ) )
            ( n = `enableAutoBinding`  v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( enableautobinding ) )
                          ) ).

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
    result = _generic( name   = `DimensionDefinition`
                       ns     = `viz.data`
                       t_prop = VALUE #( ( n = `axis`          v = axis )
                                         ( n = `dataType`      v = datatype )
                                         ( n = `displayValue`  v = displayvalue )
                                         ( n = `identity`      v = identity )
                                         ( n = `name`          v = name )
                                         ( n = `sorter`        v = sorter )
                                         ( n = `value`         v = value ) ) ).
  ENDMETHOD.

  METHOD viz_feeds.
    result = _generic( name = `feeds`
                       ns   = `viz` ).
  ENDMETHOD.

  METHOD viz_feed_item.
    result = _generic( name   = `FeedItem`
                       ns     = `viz.feeds`
                       t_prop = VALUE #( ( n = `id`      v = id )
                                         ( n = `uid`     v = uid )
                                         ( n = `type`    v = type )
                                         ( n = `values` v = values ) ) ).
  ENDMETHOD.

  METHOD viz_flattened_dataset.
    result = _generic( name   = `FlattenedDataset`
                       ns     = `viz.data`
                       t_prop = VALUE #( ( n = `data` v = data ) ) ).
  ENDMETHOD.

  METHOD viz_frame.
    DATA(lv_vizproperties) = ``.
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

    result = _generic( name   = `VizFrame`
                       ns     = `viz`
                       t_prop = VALUE #( ( n = `id`                v = id )
                                         ( n = `legendVisible`     v = legendvisible )
                                         ( n = `vizCustomizations` v = vizcustomizations )
                                         ( n = `vizProperties`     v = lv_vizproperties )
                                         ( n = `vizScales`         v = vizscales )
                                         ( n = `vizType`           v = viztype )
                                         ( n = `height`            v = height )
                                         ( n = `width`             v = width )
                                         ( n = `uiConfig`          v = uiconfig )
                                         ( n = `visible`           v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( visible ) )
                                         ( n = `selectData`        v = selectdata ) ) ).

  ENDMETHOD.

  METHOD viz_measures.
    result = _generic( name = `measures`
                       ns   = `viz.data` ).
  ENDMETHOD.

  METHOD viz_measure_definition.
    result = _generic( name   = `MeasureDefinition`
                       ns     = `viz.data`
                       t_prop = VALUE #( ( n = `format`    v = format )
                                         ( n = `group`     v = group )
                                         ( n = `identity`  v = identity )
                                         ( n = `name`      v = name )
                                         ( n = `range`     v = range )
                                         ( n = `unit`      v = unit )
                                         ( n = `value`     v = value ) ) ).
  ENDMETHOD.

  METHOD smart_multi_input.

    result = _generic( name   = `SmartMultiInput`
                       ns     = `smi`
                       t_prop = VALUE #( ( n = `id`                   v = id )
                                         ( n = `value`                v = value )
                                         ( n = `entitySet`            v = entityset )
                                         ( n = `supportRanges`        v = supportranges )
                                         ( n = `enableODataSelect`    v = enableodataselect )
                                         ( n = `requestAtLeastFields` v = requestatleastfields )
                                         ( n = `singleTokenMode`      v = singletokenmode )
                                         ( n = `supportMultiSelect`   v = supportmultiselect )
                                         ( n = `textSeparator`        v = textseparator )
                                         ( n = `textLabel`            v = textlabel )
                                         ( n = `tooltipLabel`         v = tooltiplabel )
                                         ( n = `textInEditModeSource` v = textineditmodesource )
                                         ( n = `mandatory`         v = mandatory )
                                         ( n = `maxLength`         v = maxlength ) ) ).

  ENDMETHOD.

  METHOD overflow_toolbar_layout_data.

    result = _generic(
        name   = `OverflowToolbarLayoutData`
        t_prop = VALUE #(
            ( n = `closeOverflowOnInteraction` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( closeoverflowoninteraction ) )
            ( n = `group`                      v = group )
            ( n = `priority`                   v = priority ) ) ).

  ENDMETHOD.

  METHOD row_settings.
    result = _generic(
                 name   = `RowSettings`
                 ns     = `table`
                 t_prop = VALUE #( ( n = `highlight`       v = highlight )
                                   ( n = `highlightText`   v = highlighttext )
                                   ( n = `navigated`       v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( navigated ) ) ) ).
  ENDMETHOD.

  METHOD image_editor.
    result = _generic(
                 name   = `ImageEditor`
                 ns     = `ie`
                 t_prop = VALUE #(
                     ( n = `id`                    v = id )
                     ( n = `customShapeSrc`        v = customshapesrc )
                     ( n = `keepCropAspectRatio`   v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( keepcropaspectratio ) )
                     ( n = `keepResizeAspectRatio` v = z2ui5_cl_abap2ui5_context=>boolean_abap_2_json( keepresizeaspectratio ) )
                     ( n = `scaleCropArea`         v = scalecroparea )
                     ( n = `customShapeSrcType`    v = customshapesrctype )
                     ( n = `src`                   v = src ) ) ).
  ENDMETHOD.

  METHOD image_editor_container.
    result = _generic( name   = `ImageEditorContainer`
                       ns     = `ie`
                       t_prop = VALUE #( ( n = `id`             v = id )
                                         ( n = `enabledButtons` v = enabledbuttons )
                                         ( n = `mode`           v = mode ) ) ).
  ENDMETHOD.

ENDCLASS.
