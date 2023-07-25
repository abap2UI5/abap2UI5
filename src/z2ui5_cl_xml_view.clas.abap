class Z2UI5_CL_XML_VIEW definition
  public
  final
  create protected .

public section.

  class-methods FACTORY
    importing
      !T_NS type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE optional
      !CLIENT type ref to Z2UI5_IF_CLIENT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  class-methods FACTORY_POPUP
    importing
      !T_NS type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE optional
      !CLIENT type ref to Z2UI5_IF_CLIENT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONSTRUCTOR .
  methods HLP_GET_SOURCE_CODE_URL
    returning
      value(RESULT) type STRING .
  methods HLP_GET_URL_PARAM
    importing
      !VAL type STRING
    returning
      value(RESULT) type STRING .
  methods HLP_SET_URL_PARAM
    importing
      !N type CLIKE
      !V type CLIKE .
  methods HLP_REPLACE_CONTROLLER_NAME
    importing
      !XML type STRING
    returning
      value(RESULT) type STRING .
  methods HORIZONTAL_LAYOUT
    importing
      !CLASS type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DYNAMIC_PAGE
    importing
      !HEADEREXPANDED type CLIKE optional
      !SHOWFOOTER type CLIKE optional
      !HEADERPINNED type CLIKE optional
      !TOGGLEHEADERONTITLECLICK type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DYNAMIC_PAGE_TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DYNAMIC_PAGE_HEADER
    importing
      !PINNABLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ILLUSTRATED_MESSAGE
    importing
      !ENABLEVERTICALRESPONSIVENESS type CLIKE optional
      !ENABLEFORMATTEDTEXT type CLIKE optional
      !ILLUSTRATIONTYPE type CLIKE optional
      !TITLE type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !ILLUSTRATIONSIZE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ADDITIONAL_CONTENT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FLEX_BOX
    importing
      !CLASS type CLIKE optional
      !RENDERTYPE type CLIKE optional
      !WIDTH type CLIKE optional
      !FITCONTAINER type CLIKE optional
      !HEIGHT type CLIKE optional
      !ALIGNITEMS type CLIKE optional
      !JUSTIFYCONTENT type CLIKE optional
      !WRAP type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods POPOVER
    importing
      !TITLE type CLIKE optional
      !CLASS type CLIKE optional
      !PLACEMENT type CLIKE optional
      !INITIALFOCUS type CLIKE optional
      !CONTENTWIDTH type CLIKE optional
      !CONTENTHEIGHT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LIST_ITEM
    importing
      !TEXT type CLIKE optional
      !ADDITIONALTEXT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TABLE
    importing
      !ID type CLIKE optional
      !ITEMS type CLIKE optional
      !GROWING type CLIKE optional
      !GROWINGTHRESHOLD type CLIKE optional
      !GROWINGSCROLLTOLOAD type CLIKE optional
      !HEADERTEXT type CLIKE optional
      !STICKY type CLIKE optional
      !MODE type CLIKE optional
      !WIDTH type CLIKE optional
      !SELECTIONCHANGE type CLIKE optional
      !ALTERNATEROWCOLORS type CLIKE optional
      !AUTOPOPINMODE type CLIKE optional
      !INSET type CLIKE optional
      !SHOWSEPARATORS type CLIKE optional
    preferred parameter ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_STRIP
    importing
      !TEXT type CLIKE optional
      !TYPE type CLIKE optional
      !SHOWICON type CLIKE optional
      !CLASS type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FOOTER
    importing
      !NS type STRING optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_PAGE
    importing
      !SHOW_HEADER type CLIKE optional
      !TEXT type CLIKE optional
      !ENABLEFORMATTEDTEXT type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_PAGE_LAYOUT
    importing
      !SHOWTITLEINHEADERCONTENT type CLIKE optional
      !SHOWEDITHEADERBUTTON type CLIKE optional
      !EDITHEADERBUTTONPRESS type CLIKE optional
      !UPPERCASEANCHORBAR type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_PAGE_DYN_HEADER_TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods GENERICTILE
    importing
      !CLASS     type CLIKE optional
      !mode      type CLIKE optional
      !HEADER    type CLIKE optional
      !PRESS     type CLIKE optional
      !FRAMETYPE type CLIKE optional
      !SUBHEADER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW.

  methods NUMERICCONTENT
    importing
      !VALUE type CLIKE optional
      !ICON type CLIKE optional
      !WITHMARGIN type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods IMAGECONTENT
    importing
      !SRC type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TILECONTENT
    importing
      !UNIT type CLIKE optional
      !FOOTER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods EXPANDED_HEADING
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SNAPPED_HEADING
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods EXPANDED_CONTENT
    importing
      !NS type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SNAPPED_CONTENT
    importing
      !NS type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADING
    importing
      !NS type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ACTIONS
    importing
      !NS type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SNAPPED_TITLE_ON_MOBILE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER
    importing
      !NS type CLIKE default `f`
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods NAVIGATION_ACTIONS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods AVATAR
    importing
      !SRC type CLIKE optional
      !CLASS type CLIKE optional
      !DISPLAYSIZE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER_TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SECTIONS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_PAGE_SECTION
    importing
      !TITLEUPPERCASE type CLIKE optional
      !TITLE type CLIKE optional
      !IMPORTANCE type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SUB_SECTIONS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_PAGE_SUB_SECTION
    importing
      !ID type CLIKE optional
      !TITLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SHELL
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCKS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LAYOUT_DATA
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FLEX_ITEM_DATA
    importing
      !GROWFACTOR type CLIKE optional
      !BASESIZE type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !STYLECLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CODE_EDITOR
    importing
      !VALUE type CLIKE optional
      !TYPE type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !EDITABLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SUGGESTION_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SUGGESTION_COLUMNS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SUGGESTION_ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VERTICAL_LAYOUT
    importing
      !CLASS type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MULTI_INPUT
    importing
      !SHOWCLEARICON type CLIKE optional
      !SHOWVALUEHELP type CLIKE optional
      !SUGGESTIONITEMS type CLIKE optional
      !TOKENUPDATE type CLIKE optional
      !WIDTH type CLIKE optional
      !ID type CLIKE optional
      !VALUE type CLIKE optional
      !TOKENS type CLIKE optional
      !SUBMIT type CLIKE optional
      !VALUEHELPREQUEST type CLIKE optional
      !ENABLED type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOKENS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOKEN
    importing
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
      !SELECTED type CLIKE optional
      !VISIBLE type CLIKE optional
      !EDITABLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INPUT
    importing
      !ID type CLIKE optional
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !TYPE type CLIKE optional
      !SHOWCLEARICON type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !SHOWTABLESUGGESTIONVALUEHELP type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !SUGGESTIONITEMS type CLIKE optional
      !SUGGESTIONROWS type CLIKE optional
      !SHOWSUGGESTION type CLIKE optional
      !SHOWVALUEHELP type CLIKE optional
      !VALUEHELPREQUEST type CLIKE optional
      !SUGGEST type CLIKE optional
      !CLASS type CLIKE optional
      !VISIBLE type CLIKE optional
      !SUBMIT type CLIKE optional
      !VALUELIVEUPDATE type CLIKE optional
      !AUTOCOMPLETE type CLIKE optional
      !MAXSUGGESTIONWIDTH type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DIALOG
    importing
      !TITLE type CLIKE optional
      !ICON type CLIKE optional
      !SHOWHEADER type CLIKE optional
      !STRETCH type CLIKE optional
      !CONTENTHEIGHT type CLIKE optional
      !CONTENTWIDTH type CLIKE optional
      !RESIZABLE type CLIKE optional
    preferred parameter TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CAROUSEL
    importing
      !HEIGHT type CLIKE optional
      !CLASS type CLIKE optional
      !LOOP type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BUTTONS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GET_ROOT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GET_PARENT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GET
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GET_CHILD
    importing
      !INDEX type I default 1
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COLUMNS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COLUMN
    importing
      !WIDTH type CLIKE optional
      !MINSCREENWIDTH type CLIKE optional
      !DEMANDPOPIN type CLIKE optional
      !HALIGN type CLIKE optional
    preferred parameter WIDTH
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERACT_DONUT_CHART
    importing
      !SELECTIONCHANGED type CLIKE optional
      !ERRORMESSAGE type CLIKE optional
      !ERRORMESSAGETITLE type CLIKE optional
      !SHOWERROR type CLIKE optional
      !DISPLAYEDSEGMENTS type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SEGMENTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERACT_DONUT_CHART_SEGMENT
    importing
      !LABEL type CLIKE optional
      !VALUE type CLIKE optional
      !DISPLAYEDVALUE type CLIKE optional
      !SELECTED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERACT_BAR_CHART
    importing
      !SELECTIONCHANGED type CLIKE optional
      !PRESS type CLIKE optional
      !LABELWIDTH type CLIKE optional
      !ERRORMESSAGE type CLIKE optional
      !ERRORMESSAGETITLE type CLIKE optional
      !SHOWERROR type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BARS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERACT_BAR_CHART_BAR
    importing
      !LABEL type CLIKE optional
      !VALUE type CLIKE optional
      !DISPLAYEDVALUE type CLIKE optional
      !SELECTED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERACT_LINE_CHART
    importing
      !SELECTIONCHANGED type CLIKE optional
      !PRESS type CLIKE optional
      !PRECEDINGPOINT type CLIKE optional
      !SUCCEDDINGPOINT type CLIKE optional
      !ERRORMESSAGE type CLIKE optional
      !ERRORMESSAGETITLE type CLIKE optional
      !SHOWERROR type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods POINTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERACT_LINE_CHART_POINT
    importing
      !LABEL type CLIKE optional
      !VALUE type CLIKE optional
      !SECONDARYLABEL type CLIKE optional
      !DISPLAYEDVALUE type CLIKE optional
      !SELECTED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RADIAL_MICRO_CHART
    importing
      !SICE type CLIKE optional
      !PERCENTAGE type CLIKE optional
      !PRESS type CLIKE optional
      !VALUECOLOR type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COLUMN_LIST_ITEM
    importing
      !VALIGN type CLIKE optional
      !SELECTED type CLIKE optional
      !TYPE type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CELLS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONTENT_LEFT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONTENT_MIDDLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONTENT_RIGHT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CUSTOM_HEADER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER_CONTENT
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SUB_HEADER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CUSTOM_DATA
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BADGE_CUSTOM_DATA
    importing
      !KEY type CLIKE optional
      !VALUE type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOGGLE_BUTTON
    importing
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
      !TYPE type CLIKE optional
      !ENABLED type CLIKE optional
      !PRESS type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BUTTON
    importing
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
      !TYPE type CLIKE optional
      !ENABLED type CLIKE optional
      !PRESS type CLIKE optional
      !CLASS type CLIKE optional
      !ID type CLIKE optional
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SEARCH_FIELD
    importing
      !SEARCH type CLIKE optional
      !WIDTH type CLIKE optional
      !VALUE type CLIKE optional
      !ID type CLIKE optional
      !CHANGE type CLIKE optional
      !LIVECHANGE type CLIKE optional
      !AUTOCOMPLETE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_VIEW
    importing
      !ITEMS type CLIKE optional
      !GROUPITEMS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_POPOVER
    importing
      !ITEMS type CLIKE optional
      !GROUPITEMS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_ITEM
    importing
      !TYPE type CLIKE optional
      !TITLE type CLIKE optional
      !SUBTITLE type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !GROUPNAME type CLIKE optional
      !MARKUPDESCRIPTION type ABAP_BOOL optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PAGE
    importing
      !TITLE type CLIKE optional
      !NAVBUTTONPRESS type CLIKE optional
      !SHOWNAVBUTTON type CLIKE optional
      !SHOWHEADER type CLIKE optional
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !NS type CLIKE optional
    preferred parameter TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PANEL
    importing
      !EXPANDABLE type CLIKE optional
      !EXPANDED type CLIKE optional
      !HEADERTEXT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VBOX
    importing
      !HEIGHT type CLIKE optional
      !JUSTIFYCONTENT type CLIKE optional
      !CLASS type CLIKE optional
      !RENDERTYPE type CLIKE optional
    preferred parameter CLASS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HBOX
    importing
      !CLASS type CLIKE optional
      !JUSTIFYCONTENT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SCROLL_CONTAINER
    importing
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !VERTICAL type CLIKE optional
      !HORIZONTAL type CLIKE optional
      !FOCUSABLE type CLIKE optional
    preferred parameter HEIGHT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SIMPLE_FORM
    importing
      !TITLE type CLIKE optional
      !LAYOUT type CLIKE optional
      !EDITABLE type CLIKE optional
      !COLUMNSXL type CLIKE optional
      !COLUMNSL type CLIKE optional
      !COLUMNSM type CLIKE optional
    preferred parameter TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ZZ_PLAIN
    importing
      !VAL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONTENT
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TITLE
    importing
      !NS type CLIKE optional
      !TEXT type CLIKE optional
      !WRAPPING type CLIKE optional
      !LEVEL type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TAB_CONTAINER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TAB
    importing
      !TEXT type CLIKE optional
      !SELECTED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OVERFLOW_TOOLBAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OVERFLOW_TOOLBAR_TOGGLE_BUTTON
    importing
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
      !TYPE type CLIKE optional
      !ENABLED type CLIKE optional
      !PRESS type CLIKE optional
      !TOOLTIP type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OVERFLOW_TOOLBAR_BUTTON
    importing
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
      !TYPE type CLIKE optional
      !ENABLED type CLIKE optional
      !PRESS type CLIKE optional
      !TOOLTIP type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OVERFLOW_TOOLBAR_MENU_BUTTON
    importing
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
      !BUTTONMODE type CLIKE optional
      !TYPE type CLIKE optional
      !ENABLED type CLIKE optional
      !TOOLTIP type CLIKE optional
      !DEFAULTACTION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MENU_ITEM
    importing
      !PRESS type CLIKE optional
      !TEXT type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOOLBAR_SPACER
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LABEL
    importing
      !TEXT type CLIKE optional
      !LABELFOR type CLIKE optional
      !DESIGN type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods IMAGE
    importing
      !SRC type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DATE_PICKER
    importing
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TIME_PICKER
    importing
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DATE_TIME_PICKER
    importing
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LINK
    importing
      !TEXT type CLIKE optional
      !HREF type CLIKE optional
      !TARGET type CLIKE optional
      !ENABLED type CLIKE optional
      !PRESS type CLIKE optional
      !ID type CLIKE optional
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LIST
    importing
      !HEADERTEXT type CLIKE optional
      !ITEMS type CLIKE optional
      !MODE type CLIKE optional
      !SELECTIONCHANGE type CLIKE optional
      !NODATA type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CUSTOM_LIST_ITEM
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INPUT_LIST_ITEM
    importing
      !LABEL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods STANDARD_LIST_ITEM
    importing
      !TITLE type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !ICON type CLIKE optional
      !INFO type CLIKE optional
      !PRESS type CLIKE optional
      !TYPE type CLIKE optional
      !SELECTED type CLIKE optional
      !COUNTER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ITEM
    importing
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SEGMENTED_BUTTON_ITEM
    importing
      !ICON type CLIKE optional
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COMBOBOX
    importing
      !SELECTEDKEY type CLIKE optional
      !SHOWCLEARICON type CLIKE optional
      !LABEL type CLIKE optional
      !ITEMS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GRID
    importing
      !CLASS type CLIKE optional
      !DEFAULT_SPAN type CLIKE optional
    preferred parameter DEFAULT_SPAN
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GRID_DATA
    importing
      !SPAN type CLIKE optional
    preferred parameter SPAN
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TEXT_AREA
    importing
      !VALUE type CLIKE optional
      !ROWS type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !GROWING type CLIKE optional
      !GROWINGMAXLINES type CLIKE optional
      !ID type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RANGE_SLIDER
    importing
      !MAX type CLIKE optional
      !MIN type CLIKE optional
      !STEP type CLIKE optional
      !STARTVALUE type CLIKE optional
      !ENDVALUE type CLIKE optional
      !SHOWTICKMARKS type CLIKE optional
      !LABELINTERVAL type CLIKE optional
      !WIDTH type CLIKE optional
      !CLASS type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GENERIC_TAG
    importing
      !ARIALABELLEDBY type CLIKE optional
      !TEXT type CLIKE optional
      !DESIGN type CLIKE optional
      !STATUS type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_ATTRIBUTE
    importing
      !TITLE type CLIKE optional
      !TEXT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_NUMBER
    importing
      !STATE type CLIKE optional
      !EMPHASIZED type CLIKE optional
      !NUMBER type CLIKE optional
      !UNIT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods SWITCH
    importing
      !STATE type CLIKE optional
      !CUSTOMTEXTON type CLIKE optional
      !CUSTOMTEXTOFF type CLIKE optional
      !ENABLED type CLIKE optional
      !change type CLIKE optional
      !TYPE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods STEP_INPUT
    importing
      !VALUE type CLIKE
      !MIN type CLIKE
      !MAX type CLIKE
      !STEP type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PROGRESS_INDICATOR
    importing
      !PERCENTVALUE type CLIKE optional
      !DISPLAYVALUE type CLIKE optional
      !SHOWVALUE type CLIKE optional
      !STATE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SEGMENTED_BUTTON
    importing
      !SELECTED_KEY type CLIKE
      !SELECTION_CHANGE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CHECKBOX
    importing
      !TEXT type CLIKE optional
      !SELECTED type CLIKE optional
      !ENABLED type CLIKE optional
      !SELECT type CLIKE optional
    preferred parameter SELECTED
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER_TOOLBAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOOLBAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TEXT
    importing
      !TEXT type CLIKE optional
      !CLASS type CLIKE optional
      !NS type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FORMATTED_TEXT
    importing
      !HTMLTEXT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods _GENERIC
    importing
      !NAME type CLIKE
      !NS type CLIKE optional
      !T_PROP type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CC_FILE_UPLOADER
    importing
      !VALUE type CLIKE optional
      !PATH type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !UPLOAD type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods CC_FILE_UPLOADER_GET_JS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods XML_GET
    returning
      value(RESULT) type STRING .
  methods STRINGIFY
    returning
      value(RESULT) type STRING .
  methods TREE_TABLE
    importing
      !ROWS type CLIKE
      !SELECTIONMODE type CLIKE default 'Single'
      !ENABLECOLUMNREORDERING type CLIKE default 'false'
      !EXPANDFIRSTLEVEL type CLIKE default 'false'
      !COLUMNSELECT type CLIKE optional
      !ROWSELECTIONCHANGE type CLIKE optional
      !SELECTIONBEHAVIOR type CLIKE default 'RowSelector'
      !SELECTEDINDEX type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TREE_COLUMNS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TREE_COLUMN
    importing
      !LABEL type CLIKE
      !TEMPLATE type CLIKE OPTIONAL
      !HALIGN type CLIKE default 'Begin'
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TREE_TEMPLATE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FILTER_BAR
    importing
      !USETOOLBAR type CLIKE default 'false'
      !SEARCH type CLIKE optional
      !FILTERCHANGE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FILTER_GROUP_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FILTER_GROUP_ITEM
    importing
      !NAME type CLIKE
      !LABEL type CLIKE
      !GROUPNAME type CLIKE
      !VISIBLEINFILTERBAR type CLIKE default 'true'
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FILTER_CONTROL
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FLEXIBLE_COLUMN_LAYOUT
    importing
      !LAYOUT type CLIKE
      !ID type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BEGIN_COLUMN_PAGES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MID_COLUMN_PAGES
    importing
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods END_COLUMN_PAGES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_TABLE
    importing
      !ROWS type CLIKE optional
      !COLUMNHEADERVISIBLE type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLECELLFILTER type CLIKE optional
      !ENABLEGROUPING type CLIKE optional
      !ENABLESELECTALL type CLIKE optional
      !FIRSTVISIBLEROW type CLIKE optional
      !FIXEDBOTTOMROWCOUNT type CLIKE optional
      !FIXEDCOLUMNCOUNT type CLIKE optional
      !FIXEDROWCOUNT type CLIKE optional
      !MINAUTOROWCOUNT type CLIKE optional
      !ROWACTIONCOUNT type CLIKE optional
      !ROWHEIGHT type CLIKE optional
      !SELECTIONMODE type CLIKE optional
      !SHOWCOLUMNVISIBILITYMENU type CLIKE optional
      !SHOWNODATA type CLIKE optional
      !SELECTEDINDEX type CLIKE optional
      !THRESHOLD type CLIKE optional
      !VISIBLEROWCOUNT type CLIKE optional
      !VISIBLEROWCOUNTMODE type CLIKE optional
      !ALTERNATEROWCOLORS type CLIKE optional
      !FOOTER type CLIKE optional
      !FILTER type CLIKE optional
      !SORT type CLIKE optional
      !ROWSELECTIONCHANGE type CLIKE optional
      !CUSTOMFILTER type CLIKE optional
      !ID type CLIKE optional
    preferred parameter ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_COLUMN
    importing
      !WIDTH type CLIKE optional
      !SHOWSORTMENUENTRY type CLIKE optional
      !SORTPROPERTY type CLIKE optional
      !FILTERPROPERTY type CLIKE optional
      !SHOWFILTERMENUENTRY type CLIKE optional
    preferred parameter WIDTH
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_COLUMNS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_EXTENSION
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_TEMPLATE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CURRENCY
    importing
      !VALUE type CLIKE
      !CURRENCY type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_ROW_ACTION
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_ROW_ACTION_TEMPLATE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_ROW_ACTION_ITEM
    importing
      !ICON type CLIKE optional
      !TEXT type CLIKE optional
      !TYPE type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RADIO_BUTTON
    importing
      !ACTIVEHANDLING type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !GROUPNAME type CLIKE optional
      !SELECTED type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !USEENTIREWIDTH type CLIKE optional
      !VALUESTATE type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RADIO_BUTTON_GROUP
    importing
      !ID type CLIKE optional
      !COLUMNS type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !SELECTEDINDEX type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !VALUESTATE type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PLANNINGCALENDAR
    importing
      !ROWS type CLIKE optional
      !STARTDATE type CLIKE optional
      !APPOINTMENTSVISUALIZATION type CLIKE optional
      !APPOINTMENTSELECT type CLIKE optional
      !SHOWEMPTYINTERVALHEADERS type CLIKE optional
      !SHOWWEEKNUMBERS type CLIKE optional
    preferred parameter ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PLANNINGCALENDARROW
    importing
      !APPOINTMENTS type CLIKE optional
      !INTERVALHEADERS type CLIKE optional
      !ICON type CLIKE optional
      !TITLE type CLIKE optional
      !TEXT type CLIKE optional
    preferred parameter APPOINTMENTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods APPOINTMENTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CALENDARAPPOINTMENT
    importing
      !STARTDATE type CLIKE optional
      !ENDDATE type CLIKE optional
      !ICON type CLIKE optional
      !TITLE type CLIKE optional
      !TEXT type CLIKE optional
      !TYPE type CLIKE optional
      !TENTATIVE type CLIKE optional
    preferred parameter STARTDATE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERVALHEADERS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCKLAYOUT
    importing
      !BACKGROUND type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCKLAYOUTROW
    importing
      !ROWCOLORSET type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCKLAYOUTCELL
    importing
      !BACKGROUNDCOLORSET type CLIKE optional
      !BACKGROUNDCOLORSHADE type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEALIGNMENT type CLIKE optional
      !TITLELEVEL type CLIKE optional
      !WIDTH type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_IDENTIFIER
    importing
      !EMPTYINDICATORMODE type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEACTIVE type CLIKE optional
      !VISIBLE type CLIKE optional
      !TITLEPRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_STATUS
    importing
      !ACTIVE type CLIKE optional
      !EMPTYINDICATORMODE type CLIKE optional
      !ICON type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !INVERTED type CLIKE optional
      !STATE type CLIKE optional
      !STATEANNOUNCEMENTTEXT type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !TITLE type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TREE
    importing
      !ITEMS type CLIKE optional
      !HEADERTEXT type CLIKE optional
      !FOOTERTEXT type CLIKE optional
      !MODE type CLIKE optional
      !INCLUDEITEMINSELECTION type ABAP_BOOL optional
      !INSET type ABAP_BOOL optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods STANDARD_TREE_ITEM
    importing
      !TITLE type CLIKE optional
      !ICON type CLIKE optional
      !PRESS type CLIKE optional
      !DETAILPRESS type CLIKE optional
      !TYPE type CLIKE optional
      !SELECTED type CLIKE optional
      !COUNTER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods ICONTABBAR
    importing
      !CLASS type CLIKE optional
      !SELECT type CLIKE optional
      !EXPAND type CLIKE optional
      !EXPANDABLE type ABAP_BOOL optional
      !EXPANDED type ABAP_BOOL optional
      !SELECTEDKEY type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods ICONTABFILTER
    importing
      !SHOWALL type ABAP_BOOL optional
      !ICON type CLIKE optional
      !ICONCOLOR type CLIKE optional
      !COUNT type CLIKE optional
      !TEXT type CLIKE optional
      !KEY type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods ICONTABSEPARATOR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .


  methods CC_EXPORT_SPREADSHEET_GET_JS
    importing
      !columnconfig type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods CC_EXPORT_SPREADSHEET
    importing
      !TABLEID TYPE CLIKE
      !TYPE TYPE CLIKE optional
      !TEXT TYPE CLIKE optional
      !ICON TYPE CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

   METHODS gantt_chart_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS container_toolbar
      IMPORTING
        !showsearchbutton TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .

    METHODS gantt_chart_with_table
      IMPORTING
        !id                 TYPE clike OPTIONAL
        !shapeselectionmode TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .

    METHODS axis_time_strategy
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS proportion_zoom_strategy
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS total_horizon
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS time_horizon
      IMPORTING
        !starttime    TYPE clike OPTIONAL
        !endtime      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS visible_horizon
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS row_settings_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS gantt_row_settings
      IMPORTING
        !rowid        TYPE clike OPTIONAL
        !shapes1      TYPE clike OPTIONAL
        !shapes2      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS shapes1
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS shapes2
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS task
      IMPORTING
        !type         TYPE clike OPTIONAL
        !color        TYPE clike OPTIONAL
        !endtime      TYPE clike OPTIONAL
        !time         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS gantt_table
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

  PROTECTED SECTION.

    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mt_prop  TYPE z2ui5_if_client=>ty_t_name_value.

    DATA mo_root   TYPE REF TO z2ui5_cl_xml_view.
    DATA mo_previous   TYPE REF TO z2ui5_cl_xml_view.
    DATA mo_parent TYPE REF TO z2ui5_cl_xml_view.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view WITH EMPTY KEY.

    DATA mi_client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_XML_VIEW IMPLEMENTATION.


  METHOD actions.
    result = _generic( name = `actions`
                       ns   = ns ).
  ENDMETHOD.


  METHOD additional_content.
    result = _generic( name = `additionalContent` ).
  ENDMETHOD.


  METHOD appointments.
    result = _generic( name = `appointments` ).
  ENDMETHOD.


  METHOD avatar.
    result = me.
    _generic( name   = `Avatar`
              t_prop = VALUE #( ( n = `src`         v = src )
                                ( n = `class`       v = class )
                                ( n = `displaysize` v = displaysize ) ) ).
  ENDMETHOD.


METHOD axis_time_strategy.
    result = _generic( name   = `axisTimeStrategy`
                       ns     = `gantt`
                     ).
  ENDMETHOD.


  METHOD badge_custom_data.
    result = me.
    _generic( name   = `BadgeCustomData`
              t_prop = VALUE #( ( n = `key`      v = key )
                                ( n = `value`    v = value )
                                ( n = `visible`  v = lcl_utility=>get_json_boolean( visible ) ) ) ).
  ENDMETHOD.


  METHOD bar.
    result = _generic( name = `Bar` ).
  ENDMETHOD.


  METHOD bars.
    result = _generic( name = `bars`
                       ns   = `mchart` ).
  ENDMETHOD.


  METHOD begin_column_pages.
    " todo, implement method
    result = _generic( name = `beginColumnPages`
                       ns   = `f` ).

  ENDMETHOD.


  METHOD blocklayout.
    result = _generic( name   = `BlockLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `background` v = background ) ) ).
  ENDMETHOD.


  METHOD blocklayoutcell.
    result = _generic( name   = `BlockLayoutCell`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `backgroundColorSet` v = backgroundColorSet )
                                         ( n = `backgroundColorShade` v = backgroundColorShade )
                                         ( n = `title` v = title )
                                         ( n = `titleAlignment` v = titleAlignment )
                                         ( n = `width` v = width )
                                         ( n = `class` v = class )
                                         ( n = `titleLevel` v = titleLevel ) ) ).
  ENDMETHOD.


  METHOD blocklayoutrow.
    result = _generic( name   = `BlockLayoutRow`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `rowColorSet` v = rowColorSet ) ) ).
  ENDMETHOD.


  METHOD blocks.
    result = _generic( name = `blocks`
                       ns   = `uxap` ).
  ENDMETHOD.


  METHOD button.
    result = me.
    _generic( name   = `Button`
              ns     = ns
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `id`      v = id )
                                ( n = `class`   v = class ) ) ).
  ENDMETHOD.


  METHOD buttons.
    result = _generic( `buttons` ).
  ENDMETHOD.


  METHOD calendarappointment.
    result = _generic( name   = `CalendarAppointment`
                       ns     = `u`
                       t_prop = VALUE #(
                           ( n = `startDate`                 v = startDate )
                           ( n = `endDate`                   v = endDate )
                           ( n = `icon`                      v = icon )
                           ( n = `title`                     v = title )
                           ( n = `text`                      v = text )
                           ( n = `type`                      v = type )
                           ( n = `tentative`                 v = tentative ) ) ).
  ENDMETHOD.


  METHOD carousel.

    result = _generic( name   = `Carousel`
                       t_prop = VALUE #( ( n = `loop`  v = lcl_utility=>get_json_boolean( loop ) )
                                         ( n = `class`  v = class )
                                         ( n = `height`  v = height )
               ) ).

  ENDMETHOD.


 METHOD CC_EXPORT_SPREADSHEET.
    result = _generic( name   = `ExportSpreadsheet`
                       ns     = `z2ui5`
                       t_prop = VALUE #( ( n = `tableId`  v = tableId )
                                         ( n = `text`     v = text )
                                         ( n = `icon`     v = icon )
                                         ( n = `type`     v = type )
               ) ).

  ENDMETHOD.


METHOD CC_EXPORT_SPREADSHEET_GET_JS.
  DATA(js) = ` debugger; jQuery.sap.declare("z2ui5.ExportSpreadsheet");` && |\n| &&
                        |\n| &&
                        `        sap.ui.define([` && |\n| &&
                        `            "sap/ui/core/Control",` && |\n| &&
                        `            "sap/m/Button",` && |\n| &&
                        `            "sap/ui/export/Spreadsheet"` && |\n| &&
                        `        ], function (Control, Button, Spreadsheet) {` && |\n| &&
                        `            "use strict";` && |\n| &&
                        |\n| &&
                        `            return Control.extend("z2ui5.ExportSpreadsheet", {` && |\n| &&
                        |\n| &&
                        `                metadata: {` && |\n| &&
                        `                    properties: {` && |\n| &&
                        `                        tableId: {` && |\n| &&
                        `                            type: "string",` && |\n| &&
                        `                            defaultValue: ""` && |\n| &&
                        `                        },` && |\n| &&
                        `                        type: {` && |\n| &&
                        `                            type: "string",` && |\n| &&
                        `                            defaultValue: ""` && |\n| &&
                        `                        },` && |\n| &&
                        `                        icon: {` && |\n| &&
                        `                            type: "string",` && |\n| &&
                        `                            defaultValue: ""` && |\n| &&
                        `                        },` && |\n| &&
                        `                        text: {` && |\n| &&
                        `                            type: "string",` && |\n| &&
                        `                            defaultValue: ""` && |\n| &&
                        `                        }` && |\n| &&
                        `                    },` && |\n| &&
                        |\n| &&
                        |\n| &&
                        `                    aggregations: {` && |\n| &&
                        `                    },` && |\n| &&
                        `                    events: { },` && |\n| &&
                        `                    renderer: null` && |\n| &&
                        `                },` && |\n| &&
                        |\n| &&
                        `                renderer: function (oRm, oControl) {` && |\n| &&
                        |\n| &&
                        `                    oControl.oExportButton = new Button({` && |\n| &&
                        `                        text: oControl.getProperty("text"),` && |\n| &&
                        `                        icon: oControl.getProperty("icon"), ` && |\n| &&
                        `                        type: oControl.getProperty("type"), ` && |\n| &&
                        `                        press: function (oEvent) { ` && |\n| &&
                        |\n| &&
                        `                             var aCols =` && columnconfig  && `;` && |\n| &&
                        |\n| &&
                        `                             var oBinding, oSettings, oSheet, oTable, vTableId, vViewPrefix,vPrefixTableId;` && |\n| &&
                        `                             vTableId = oControl.getProperty("tableId")` && |\n| &&
                        `                             vViewPrefix = sap.z2ui5.oView.sId;` && |\n| &&
                        `                             vPrefixTableId = vViewPrefix + "--" + vTableId;` && |\n| &&
                        `                             oTable = sap.ui.getCore().byId(vPrefixTableId);` && |\n| &&
                        `                             oBinding = oTable.getBinding("rows");` && |\n| &&
                        `                             if (oBinding == null) {` && |\n| &&
                        `                               oBinding = oTable.getBinding("items");` && |\n| &&
                        `                             };` && |\n| &&
                        `                             oSettings = {` && |\n| &&
                        `                               workbook: { columns: aCols },` && |\n| &&
                        `                               dataSource: oBinding` && |\n| &&
                        `                             };` && |\n| &&
                        `                             oSheet = new Spreadsheet(oSettings);` && |\n| &&
                        `                             oSheet.build()` && |\n| &&
                        `                               .then(function() {` && |\n| &&
                        `                               }).finally(function() {` && |\n| &&
                        `                                 oSheet.destroy();` && |\n| &&
                        `                               });` && |\n| &&
                        `                         }.bind(oControl)` && |\n| &&
                        `                  });` && |\n| &&
                        |\n| &&
                        `                    oRm.renderControl(oControl.oExportButton);` && |\n| &&
                        `                }` && |\n| &&
                        `            });` && |\n| &&
                        `        });`.

    result = zz_plain( `<html:script>` && js && `</html:script>` ).

ENDMETHOD.


  METHOD cc_file_uploader.
    result = me.
    _generic( name   = `FileUploader`
              ns     = `z2ui5`
              t_prop = VALUE #( (  n = `placeholder` v = placeholder )
                                (  n = `upload`      v = upload )
                                (  n = `path`        v = path )
                                (  n = `value`       v = value ) ) ).
  ENDMETHOD.


  METHOD cc_file_uploader_get_js.

    DATA(js) = ` debugger; jQuery.sap.declare("z2ui5.FileUploader");` && |\n| &&
                          |\n| &&
                          `        sap.ui.define([` && |\n| &&
                          `            "sap/ui/core/Control",` && |\n| &&
                          `            "sap/m/Button",` && |\n| &&
                          `            "sap/ui/unified/FileUploader"` && |\n| &&
                          `        ], function (Control, Button, FileUploader) {` && |\n| &&
                          `            "use strict";` && |\n| &&
                          |\n| &&
                          `            return Control.extend("z2ui5.FileUploader", {` && |\n| &&
                          |\n| &&
                          `                metadata: {` && |\n| &&
                          `                    properties: {` && |\n| &&
                          `                        value: {` && |\n| &&
                          `                            type: "string",` && |\n| &&
                          `                            defaultValue: ""` && |\n| &&
                          `                        },` && |\n| &&
                          `                        path: {` && |\n| &&
                          `                            type: "string",` && |\n| &&
                          `                            defaultValue: ""` && |\n| &&
                          `                        },` && |\n| &&
                          `                        tooltip: {` && |\n| &&
                          `                            type: "string",` && |\n| &&
                          `                            defaultValue: ""` && |\n| &&
                          `                        },` && |\n| &&
                          `                        fileType: {` && |\n| &&
                          `                            type: "string",` && |\n| &&
                          `                            defaultValue: ""` && |\n| &&
                          `                        },` && |\n| &&
                          `                        placeholder: {` && |\n| &&
                          `                            type: "string",` && |\n| &&
                          `                            defaultValue: ""` && |\n| &&
                          `                        },` && |\n| &&
                          `                        buttonText: {` && |\n| &&
                          `                            type: "string",` && |\n| &&
                          `                            defaultValue: "Upload"` && |\n| &&
                          `                        },` && |\n| &&
                          `                        enabled: {` && |\n| &&
                          `                            type: "boolean",` && |\n| &&
                          `                            defaultValue: true` && |\n| &&
                          `                        },` && |\n| &&
                          `                        multiple: {` && |\n| &&
                          `                            type: "boolean",` && |\n| &&
                          `                            defaultValue: false` && |\n| &&
                          `                        }` && |\n| &&
                          `                    },` && |\n| &&
                          |\n| &&
                          |\n| &&
                          `                    aggregations: {` && |\n| &&
                          `                    },` && |\n| &&
                          `                    events: {` && |\n| &&
                          `                        "upload": {` && |\n| &&
                          `                            allowPreventDefault: true,` && |\n| &&
                          `                            parameters: {}` && |\n| &&
                          `                        }` && |\n| &&
                          `                    },` && |\n| &&
                          `                    renderer: null` && |\n| &&
                          `                },` && |\n| &&
                          |\n| &&
                          `                renderer: function (oRm, oControl) {` && |\n| &&
                          |\n| &&
                          `                    oControl.oUploadButton = new Button({` && |\n| &&
                          `                        text: oControl.getProperty("buttonText"),` && |\n| &&
                          `                        enabled: oControl.getProperty("path") !== "",` && |\n| &&
                          `                        press: function (oEvent) { ` && |\n| &&
                          |\n| &&
                          `                            this.setProperty("path", this.oFileUploader.getProperty("value"));` && |\n| &&
                          |\n| &&
                          `                            var file = sap.z2ui5.oUpload.oFileUpload.files[0];` && |\n| &&
                          `                            var reader = new FileReader();` && |\n| &&
                          |\n| &&
                          `                            reader.onload = function (evt) {` && |\n| &&
                          `                                var vContent = evt.currentTarget.result;` && |\n| &&
                          `                                this.setProperty("value", vContent);` && |\n| &&
                          `                                this.fireUpload();` && |\n| &&
                          `                                //this.getView().byId('picture' ).getDomRef().src = vContent;` && |\n| &&
                          `                            }.bind(this)` && |\n| &&
                          |\n| &&
                          `                            reader.readAsDataURL(file);` && |\n| &&
                          `                        }.bind(oControl)` && |\n| &&
                          `                    });` && |\n| &&
                          |\n| &&
                          `                    oControl.oFileUploader = new FileUploader({` && |\n| &&
                          `                        icon: "sap-icon://browse-folder",` && |\n| &&
                          `                        iconOnly: true,` && |\n| &&
                          `                        value: oControl.getProperty("path"),` && |\n| &&
                          `                        placeholder: oControl.getProperty("placeholder"),` && |\n| &&
                          `                        change: function (oEvent) {` && |\n| &&
                          `                            var value = oEvent.getSource().getProperty("value");` && |\n| &&
                          `                            this.setProperty("path", value);` && |\n| &&
                          `                            if (value) {` && |\n| &&
                          `                                this.oUploadButton.setEnabled();` && |\n| &&
                          `                            } else {` && |\n| &&
                          `                                this.oUploadButton.setEnabled(false);` && |\n| &&
                          `                            }` && |\n| &&
                          `                            this.oUploadButton.rerender();` && |\n| &&
                          `                            sap.z2ui5.oUpload = oEvent.oSource;` && |\n| &&
                          `                        }.bind(oControl)` && |\n| &&
                          `                    });` && |\n| &&
                          |\n| &&
                          `                    var hbox = new sap.m.HBox();` && |\n| &&
                          `                    hbox.addItem(oControl.oFileUploader);` && |\n| &&
                          `                    hbox.addItem(oControl.oUploadButton);` && |\n| &&
                          `                    oRm.renderControl(hbox);` && |\n| &&
                          `                }` && |\n| &&
                          `            });` && |\n| &&
                          `        });`.

    result = zz_plain( `<html:script>` && js && `</html:script>` ).

  ENDMETHOD.


  METHOD cells.
    result = _generic( `cells` ).
  ENDMETHOD.


  METHOD checkbox.

    result = me.
    _generic( name   = `CheckBox`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `selected` v = selected )
                                ( n = `enabled`  v = lcl_utility=>get_json_boolean( enabled )  )
                                ( n = `select`   v = select  ) ) ).
  ENDMETHOD.


  METHOD code_editor.
    result = me.
    _generic( name   = `CodeEditor`
              ns     = `editor`
              t_prop = VALUE #( ( n = `value`   v = value )
                                ( n = `type`    v = type )
                                ( n = `editable`   v = lcl_utility=>get_json_boolean( editable ) )
                                ( n = `height` v = height )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD column.
    result = _generic( name   = `Column`
                       t_prop = VALUE #( ( n = `width` v = width )
                                         ( n = `minScreenWidth` v = minScreenWidth )
                                         ( n = `halign` v = HALIGN )
                                         ( n = `demandPopin` v = Lcl_utility=>get_json_boolean( demandPopin ) ) ) ).
  ENDMETHOD.


  METHOD columns.
    result = _generic( `columns` ).
  ENDMETHOD.


  METHOD column_list_item.
    result = _generic( name   = `ColumnListItem`
                       t_prop = VALUE #( ( n = `vAlign`   v = valign )
                                         ( n = `selected` v = selected )
                                         ( n = `type`     v = type )
                                         ( n = `press`    v = press ) ) ).
  ENDMETHOD.


  METHOD combobox.
    result = _generic( name   = `ComboBox`
                       t_prop = VALUE #( (  n = `showClearIcon` v = lcl_utility=>get_json_boolean( showclearicon ) )
                                         (  n = `selectedKey`   v = selectedkey )
                                         (  n = `items`         v = items )
                                         (  n = `label`         v = label ) ) ).
  ENDMETHOD.


  METHOD constructor.

    mt_prop = VALUE #( ( n = `xmlns`        v = `sap.m` )
                       ( n = `xmlns:z2ui5`  v = `z2ui5` )
                       ( n = `xmlns:core`   v = `sap.ui.core` )
                       ( n = `xmlns:mvc`    v = `sap.ui.core.mvc` )
                       ( n = `xmlns:layout` v = `sap.ui.layout` )
*                       ( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` )
*                       ( n = `core:require` v = `{ URLHelper: 'sap/m/library/URLHelper' }` )
                       ( n = `xmlns:table ` v = `sap.ui.table` )
                       ( n = `xmlns:f`      v = `sap.f` )
                       ( n = `xmlns:form`   v = `sap.ui.layout.form` )
                       ( n = `xmlns:editor` v = `sap.ui.codeeditor` )
                       ( n = `xmlns:mchart` v = `sap.suite.ui.microchart` )
                       ( n = `xmlns:webc`   v = `sap.ui.webc.main` )
                       ( n = `xmlns:uxap`   v = `sap.uxap` )
                       ( n = `xmlns:sap`    v = `sap` )
                       ( n = `xmlns:text`   v = `sap.ui.richtextedito` )
                       ( n = `xmlns:html`   v = `http://www.w3.org/1999/xhtml` )
                       ( n = `xmlns:fb`     v = `sap.ui.comp.filterbar` )
                       ( n = `xmlns:u`      v = `sap.ui.unified` )
                       ( n = `xmlns:gantt`     v = `sap.gantt.simple` )
                       ( n = `xmlns:axistime`  v = `sap.gantt.axistime` )
                       ( n = `xmlns:config`    v = `sap.gantt.config` )
                       ( n = `xmlns:shapes`    v = `sap.gantt.simple.shapes` ) ).

  ENDMETHOD.


METHOD container_toolbar.
    result = _generic( name   = `ContainerToolbar`
                       ns     = `gantt`
                       t_prop = VALUE #( ( n = `showSearchButton` v = showsearchbutton )
                                       ) ).
  ENDMETHOD.


  METHOD content.
    result = _generic( ns = ns name = `content` ).
  ENDMETHOD.


  METHOD content_left.
    result = _generic( name = `contentLeft` ).
  ENDMETHOD.


  METHOD content_middle.
    result = _generic( name = `contentMiddle` ).
  ENDMETHOD.


  METHOD content_right.
    result = _generic( name = `contentRight` ).
  ENDMETHOD.


  METHOD currency.
    result = _generic( name   = `Currency`
                       ns     = 'u'
                    t_prop = VALUE #(
                          ( n = `value` v = value )
                          ( n = `currency`  v = currency ) ) ).

  ENDMETHOD.


  METHOD custom_data.
    result = _generic( `customData` ).
  ENDMETHOD.


  METHOD custom_Header.
    result = _generic( name = `customHeader` ).
  ENDMETHOD.


  METHOD custom_list_item.
    result = _generic( name = `CustomListItem` ).
  ENDMETHOD.


  METHOD date_picker.
    result = me.
    _generic( name   = `DatePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder` v = placeholder ) ) ).
  ENDMETHOD.


  METHOD date_time_picker.
    result = me.
    _generic( name   = `DateTimePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder`  v = placeholder ) ) ).
  ENDMETHOD.


  METHOD dialog.

    result = _generic( name   = `Dialog`
                       t_prop = VALUE #( ( n = `title`  v = title )
                                         ( n = `icon`  v = icon )
                                         ( n = `stretch`  v = stretch )
                                         ( n = `showHeader`  v = showheader )
                                         ( n = `contentWidth`  v = contentwidth )
                                         ( n = `contentHeight`  v = contentheight )
                                         ( n = `resizable`  v = lcl_utility=>get_json_boolean( resizable ) ) ) ).

  ENDMETHOD.


  METHOD dynamic_page.
    result = _generic( name   = `DynamicPage`
                       ns     = `f`
                       t_prop = VALUE #(
                           (  n = `headerExpanded`           v = lcl_utility=>get_json_boolean( headerexpanded ) )
                           (  n = `headerPinned`           v = lcl_utility=>get_json_boolean( headerPinned ) )
                           (  n = `showFooter`           v = lcl_utility=>get_json_boolean( showFooter ) )
                           (  n = `toggleHeaderOnTitleClick` v = toggleHeaderOnTitleClick ) ) ).
  ENDMETHOD.


  METHOD dynamic_page_header.
    result = _generic(
                 name   = `DynamicPageHeader`
                 ns     = `f`
                 t_prop = VALUE #( (  n = `pinnable`           v = lcl_utility=>get_json_boolean( pinnable ) ) ) ).
  ENDMETHOD.


  METHOD dynamic_page_title.
    result = _generic( name = `DynamicPageTitle`
                       ns   = `f` ).
  ENDMETHOD.


  METHOD end_column_pages.
    " todo, implement method
    result = me.
  ENDMETHOD.


  METHOD expanded_content.
    result = _generic( name = `expandedContent`
                       ns   = ns ).
  ENDMETHOD.


  METHOD expanded_heading.
    result = _generic( name = `expandedHeading`
                       ns   = `uxap` ).
  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mi_client = client.
    result->mt_prop  = VALUE #( BASE result->mt_prop
                                (  n = 'displayBlock'   v = 'true' )
                                (  n = 'height'         v = '100%' )
                                (  n = 'controllerName' v = client->get( )-s_config-controller_name ) ).

    result->mv_name   = `View`.
    result->mv_ns     = `mvc`.
    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.


  METHOD factory_popup.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mi_client = client.
    result->mv_name   = `FragmentDefinition`.
    result->mv_ns     = `core`.
    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.


  METHOD filter_bar.
    result = _generic( name   = `FilterBar`
                       ns     = 'fb'
                       t_prop = VALUE #( ( n = 'useToolbar'    v = usetoolbar )
                                         ( n = 'search'        v = search )
                                         ( n = 'filterChange'  v = filterchange ) ) ).
  ENDMETHOD.


  METHOD filter_control.
    result = _generic( name = `control`
                       ns   = 'fb' ).
  ENDMETHOD.


  METHOD filter_group_item.
    result = _generic( name   = `FilterGroupItem`
                       ns     = 'fb'
                       t_prop = VALUE #( ( n = 'name'                v  = name )
                                         ( n = 'label'               v  = label )
                                         ( n = 'groupName'           v  = groupname )
                                         ( n = 'visibleInFilterBar'  v  = visibleinfilterbar ) ) ).
  ENDMETHOD.


  METHOD filter_group_items.
    result = _generic( name = `filterGroupItems`
                       ns   = 'fb' ).
  ENDMETHOD.


  METHOD flexible_column_layout.

    result = _generic( name   = `FlexibleColumnLayout`
                       ns     = `f`
                       t_prop = VALUE #(
                        (  n = `layout` v = layout )
                        (  n = `id` v = id )
                        ) ).

  ENDMETHOD.


  METHOD flex_box.
    result = _generic( name   = `FlexBox`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `renderType`  v = rendertype )
                                         ( n = `width`  v = width )
                                         ( n = `height`  v = height )
                                         ( n = `alignItems`  v = alignitems )
                                         ( n = `fitContainer`  v = lcl_utility=>get_json_boolean( fitcontainer ) )
                                         ( n = `justifyContent`  v = justifycontent )
                                         ( n = `wrap`  v = wrap )
                                         ( n = `visible`  v = visible ) ) ).
  ENDMETHOD.


  METHOD flex_item_data.
    result = me.

    _generic( name   = `FlexItemData`
              t_prop = VALUE #( ( n = `growFactor`  v = growfactor )
                                ( n = `baseSize`   v = basesize )
                                ( n = `backgroundDesign`   v = backgrounddesign )
                                ( n = `styleClass`   v = styleclass ) ) ).
  ENDMETHOD.


  METHOD footer.
    result = _generic( ns   = ns
                       name = `footer` ).
  ENDMETHOD.


  METHOD formatted_text.
    result = me.
    _generic( name   = `FormattedText`
              t_prop = VALUE #( ( n = `htmlText` v = htmltext ) ) ).
  ENDMETHOD.


METHOD gantt_chart_container.
    result = _generic( name   = `GanttChartContainer`
                       ns     = `gantt`
                     ).
  ENDMETHOD.


  METHOD gantt_chart_with_table.
    result = _generic( name   = `GanttChartWithTable`
                   ns     = `gantt`
                   t_prop = VALUE #( ( n = `id` v = id )
                                     ( n = `shapeSelectionMode` v = shapeselectionmode ) ) ).
  ENDMETHOD.


  METHOD gantt_row_settings.
    result = _generic( name   = `GanttRowSettings`
               ns     = `gantt`
               t_prop = VALUE #( ( n = `rowId` v = rowid )
                                 ( n = `shapes1` v = shapes1 )
                                 ( n = `shapes2` v = shapes2 ) ) ).
  ENDMETHOD.


  METHOD gantt_table.
    result = _generic( name   = `table`
                       ns     = `gantt`
                     ).
  ENDMETHOD.


  METHOD generictile.

    result = me.
    _generic(
      name   = `GenericTile`
      ns     = ``
      t_prop = VALUE #(
                ( n = `class`      v = class )
                ( n = `header`     v = header )
                ( n = `mode`     v = mode )
                ( n = `press`      v = press )
                ( n = `frameType`  v = frametype )
                ( n = `subheader`  v = subheader ) ) ).

  ENDMETHOD.


  METHOD generic_tag.
    result = _generic( name   = `GenericTag`
                       t_prop = VALUE #( ( n = `ariaLabelledBy`           v = arialabelledby )
                                         ( n = `class`        v = class )
                                         ( n = `design`          v = design )
                                         ( n = `status`  v = status )
                                         ( n = `text`   v = text ) ) ).
  ENDMETHOD.


  METHOD get.
    result = mo_root->mo_previous.
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
    result = _generic( name   = `Grid`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `defaultSpan` v = default_span )
                                         ( n = `class`       v = class ) ) ).
  ENDMETHOD.


  METHOD grid_data.
    result = me.
    _generic( name   = `GridData`
              ns     = `layout`
              t_prop = VALUE #( ( n = `span` v = span ) ) ).
  ENDMETHOD.


  METHOD hbox.
    result = _generic( name   = `HBox`
                       t_prop = VALUE #( ( n = `class` v = class )
                                         ( n = `justifyContent` v = justifycontent ) ) ).
  ENDMETHOD.


  METHOD header.
    result = _generic( name = `header`
                       ns   = ns ).
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


  METHOD hlp_get_source_code_url.

    DATA(ls_draft) = mo_root->mi_client->get( )-s_draft.
    DATA(ls_config) = mo_root->mi_client->get( )-s_config.

    result = ls_config-origin && `/sap/bc/adt/oo/classes/`
       && lcl_utility=>get_classname_by_ref( ls_draft-app ) && `/source/main`.

  ENDMETHOD.


  METHOD hlp_get_url_param.

    DATA(lt_params) = VALUE z2ui5_if_client=>ty_t_name_value( ).
    DATA(lv_search) = mi_client->get( )-s_config-search.

    REPLACE `%3D` IN lv_search WITH `=`.
    SPLIT lv_search AT `&sap-startup-params=` INTO DATA(lv_search1) DATA(lv_search2).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ELSE.
      lv_search = lv_search1.
    ENDIF.

    lv_search = lcl_utility=>get_trim_lower( lv_search ).
    SHIFT lv_search LEFT DELETING LEADING `?`.

    SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).

    LOOP AT lt_param REFERENCE INTO DATA(lr_param).

      SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value).

      INSERT VALUE #( n = lv_name v = lv_value ) INTO TABLE lt_params.
    ENDLOOP.

    DATA(lv_val) = lcl_utility=>get_trim_lower( val ).
    result = VALUE #( lt_params[ n = lv_val ]-v OPTIONAL ).

*    lv_search = lcl_utility=>get_trim_lower( lv_search ).
*    SHIFT lv_search LEFT DELETING LEADING `?`.
*
*    SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).
*
*    LOOP AT lt_param REFERENCE INTO DATA(lr_param).
*
*      SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value).
*
*      INSERT VALUE #( n = lv_name v = lv_value ) INTO TABLE lt_params.
*    ENDLOOP.
*
*    DATA(lv_val) = lcl_utility=>get_trim_lower( val ).
*    result = VALUE #( lt_params[ n = lv_val ]-v OPTIONAL ).

  ENDMETHOD.


  METHOD hlp_replace_controller_name.

    DATA(ls_config) = mo_root->mi_client->get( )-s_config.

    result = lcl_utility=>get_replace(
      iv_val     = xml
      iv_begin   = 'controllerName="'
      iv_end     = '"'
      iv_replace = `controllerName="` && ls_config-controller_name && `"` ).

  ENDMETHOD.


  METHOD hlp_set_url_param.

    DATA(lt_params) = VALUE z2ui5_if_client=>ty_t_name_value( ).
    DATA(lv_search) = mi_client->get( )-s_config-search.

    lv_search = lcl_utility=>get_trim_lower( lv_search ).
    SHIFT lv_search LEFT DELETING LEADING `?`.

    SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).

    LOOP AT lt_param REFERENCE INTO DATA(lr_param).

      SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value).

      INSERT VALUE #( n = lv_name v = lv_value ) INTO TABLE lt_params.
    ENDLOOP.

    DATA(lv_n) = lcl_utility=>get_trim_lower( n ).

    LOOP AT lt_params REFERENCE INTO DATA(lr_params)
        WHERE n = lv_n.
      lr_params->v = lcl_utility=>get_trim_lower( v ).
    ENDLOOP.
    IF sy-subrc <> 0.
      INSERT VALUE #( n = lv_n v = lcl_utility=>get_trim_lower( v ) ) INTO TABLE lt_params.
    ENDIF.

    DATA(lv_result) = `?` && lt_params[ 1 ]-n && `=` && lt_params[ 1 ]-v.

    LOOP AT lt_params REFERENCE INTO lr_params FROM 2.
      lv_result = lv_result && `&` && lr_params->n && `=` && lr_params->v.
    ENDLOOP.

    mi_client->url_param_set( lv_result ).

  ENDMETHOD.


  METHOD horizontal_layout.
    result = _generic( name   = `HorizontalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD icontabbar.

        result = _generic( name   = `IconTabBar`
                       t_prop = VALUE #( ( n = `class`       v = class )
                                         ( n = `select`      v = select )
                                         ( n = `expand`      v = expand )
                                         ( n = `expandable`  v = expandable )
                                         ( n = `expanded`    v = expanded )
                                         ( n = `selectedKey` v = selectedKey ) ) ).
  ENDMETHOD.


  METHOD icontabfilter.

        result = _generic( name   = `IconTabFilter`
                       t_prop = VALUE #( ( n = `icon`        v = icon )
                                         ( n = `iconColor`   v = iconColor )
                                         ( n = `showAll`     v = showAll )
                                         ( n = `count`       v = count )
                                         ( n = `text`        v = text )
                                         ( n = `key`         v = key ) ) ).
  ENDMETHOD.


  METHOD ICONTABSEPARATOR.

        result = _generic( name   = `IconTabSeparator` ).

  ENDMETHOD.


  METHOD illustrated_message.

    result = _generic( name   = `IllustratedMessage`
                       t_prop = VALUE #( ( n = `enableVerticalResponsiveness` v = enableVerticalResponsiveness )
                       ( n = `illustrationType`             v = illustrationType )
                       ( n = `enableFormattedText`             v = lcl_utility=>get_json_boolean( enableFormattedText ) )
                       ( n = `illustrationSize`             v = illustrationSize )
                       ( n = `description`             v = description )
                       ( n = `title`             v = title )
                       ) ).
  ENDMETHOD.


  METHOD image.
    result = me.
    _generic( name   = `Image`
              t_prop = VALUE #( ( n = `src` v = src ) ) ).
  ENDMETHOD.


  METHOD imagecontent.

    result = _generic( name   = `ImageContent`
                   t_prop = VALUE #( ( n = `src`      v = src ) ) ).


  ENDMETHOD.


  METHOD input.
    result = me.
    _generic( name   = `Input`
              t_prop = VALUE #( ( n = `id`               v = id )
                                ( n = `placeholder`      v = placeholder )
                                ( n = `type`             v = type )
                                ( n = `showClearIcon`    v = lcl_utility=>get_json_boolean( showclearicon ) )
                                ( n = `description`      v = description )
                                ( n = `editable`         v = lcl_utility=>get_json_boolean( editable ) )
                                ( n = `enabled`          v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `visible`          v = lcl_utility=>get_json_boolean( visible ) )
                                ( n = `showTableSuggestionValueHelp`          v = lcl_utility=>get_json_boolean( showTableSuggestionValueHelp ) )
                                ( n = `valueState`       v = valuestate )
                                ( n = `valueStateText`   v = valuestatetext )
                                ( n = `value`            v = value )
                                ( n = `suggest`          v = suggest )
                                ( n = `suggestionItems`  v = suggestionitems )
                                ( n = `suggestionRows`   v = suggestionrows )
                                ( n = `showSuggestion`   v = lcl_utility=>get_json_boolean( showsuggestion ) )
                                ( n = `valueHelpRequest` v = valuehelprequest )
                                ( n = `autocomplete`     v = lcl_utility=>get_json_boolean( autocomplete ) )
                                ( n = `valueLiveUpdate`  v = lcl_utility=>get_json_boolean( valueLiveUpdate ) )
                                ( n = `submit`           v = lcl_utility=>get_json_boolean( submit ) )
                                ( n = `showValueHelp`    v = lcl_utility=>get_json_boolean( showvaluehelp ) )
                                ( n = `class`            v = class )
                                ( n = `maxSuggestionWidth` v = maxsuggestionwidth ) ) ).
  ENDMETHOD.


  METHOD input_list_item.
    result = _generic( name   = `InputListItem`
                       t_prop = VALUE #( ( n = `label` v = label ) ) ).
  ENDMETHOD.


  METHOD interact_bar_chart.
    result = _generic( name   = `InteractiveBarChart`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                                         ( n = `showError`         v = showerror )
                                         ( n = `press`             v = press )
                                         ( n = `labelWidth`        v = labelwidth )
                                         ( n = `errorMessageTitle` v = errormessagetitle )
                                         ( n = `errorMessage`      v = errormessage ) ) ).
  ENDMETHOD.


  METHOD interact_bar_chart_bar.
    result = _generic( name   = `InteractiveBarChartBar`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `label`          v = label )
                                         ( n = `displayedValue` v = displayedvalue )
                                         ( n = `value`          v = value )
                                         ( n = `selected`       v = selected ) ) ).
  ENDMETHOD.


  METHOD interact_donut_chart.
    result = _generic( name   = `InteractiveDonutChart`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                                         ( n = `showError`         v = lcl_utility=>get_json_boolean( showerror ) )
                                         ( n = `errorMessageTitle` v = errormessagetitle )
                                         ( n = `errorMessage`      v = errormessage )
                                         ( n = `displayedSegments` v = displayedsegments )
                                         ( n = `press`             v = press ) ) ).
  ENDMETHOD.


  METHOD interact_donut_chart_segment.
    result = _generic( name   = `InteractiveDonutChartSegment`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `label`          v = label )
                                         ( n = `displayedValue` v = displayedvalue )
                                         ( n = `value`          v = value )
                                         ( n = `selected`       v = selected ) ) ).
  ENDMETHOD.


  METHOD interact_line_chart.
    result = _generic( name   = `InteractiveLineChart`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `selectionChanged`  v = selectionchanged )
                                         ( n = `showError`         v = lcl_utility=>get_json_boolean( showerror ) )
                                         ( n = `press`             v = press )
                                         ( n = `errorMessageTitle` v = errormessagetitle )
                                         ( n = `errorMessage`      v = errormessage )
                                         ( n = `precedingPoint`    v = precedingpoint )
                                         ( n = `succeedingPoint`   v = succeddingpoint ) ) ).
  ENDMETHOD.


  METHOD interact_line_chart_point.
    result = _generic( name   = `InteractiveLineChartPoint`
                       ns     = `mchart`
                       t_prop = VALUE #( ( n = `label`          v = label )
                                         ( n = `secondaryLabel` v = secondarylabel )
                                         ( n = `value`          v = value )
                                         ( n = `displayedValue` v = displayedvalue )
                                         ( n = `selected`       v = lcl_utility=>get_json_boolean( selected ) ) ) ).
  ENDMETHOD.


  METHOD intervalheaders.
    result = _generic( name = `intervalHeaders` ).
  ENDMETHOD.


  METHOD item.
    result = me.
    _generic( name   = `Item`
              ns     = `core`
              t_prop = VALUE #( ( n = `key`  v = key )
                                ( n = `text` v = text ) ) ).
  ENDMETHOD.


  METHOD items.
    result = _generic( `items` ).
  ENDMETHOD.


  METHOD label.
    result = me.
    _generic( name   = `Label`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `design`   v = design )
                                ( n = `labelFor` v = labelfor ) ) ).
  ENDMETHOD.


  METHOD layout_data.
    result = _generic( ns   = ns
                       name = `layoutData` ).
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
                                ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) ) ) ).
  ENDMETHOD.


  METHOD list.
    result = _generic( name   = `List`
                       t_prop = VALUE #( ( n = `headerText`      v = headertext )
                                         ( n = `items`           v = items )
                                         ( n = `mode`            v = mode )
                                         ( n = `selectionChange` v = selectionchange )
                                         ( n = `noData` v = noData ) ) ).
  ENDMETHOD.


  METHOD list_item.
    result = me.
    _generic( name   = `ListItem`
              ns     = `core`
              t_prop = VALUE #( ( n = `text` v = text )
                                ( n = `additionalText` v = additionaltext ) ) ).
  ENDMETHOD.


  METHOD menu_item.
    result = me.
    _generic( name   = `MenuItem`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `icon`    v = icon ) ) ).
  ENDMETHOD.


  METHOD message_item.
    result = _generic( name   = `MessageItem`
                       t_prop = VALUE #( ( n = `type`        v = type )
                                         ( n = `title`       v = title )
                                         ( n = `subtitle`    v = subtitle )
                                         ( n = `description` v = description )
                                         ( n = `groupName`   v = groupName )
                                         ( n = `markupDescription`   v = lcl_utility=>get_json_boolean( markupdescription ) ) ) ).
  ENDMETHOD.


  METHOD message_page.
    result = _generic( name   = `MessagePage`
                       t_prop = VALUE #(
                           ( n = `showHeader`          v = lcl_utility=>get_json_boolean( show_header ) )
                           ( n = `description`         v = description )
                           ( n = `icon`                v = icon )
                           ( n = `text`                v = text )
                           ( n = `enableFormattedText` v = lcl_utility=>get_json_boolean( enableformattedtext ) ) ) ).
  ENDMETHOD.


  METHOD message_popover.
    result = _generic( name   = `MessagePopover`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = lcl_utility=>get_json_boolean( groupItems ) ) ) ).
  ENDMETHOD.


  METHOD message_strip.
    result = me.
    _generic( name   = `MessageStrip`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `type`     v = type )
                                ( n = `showIcon` v = lcl_utility=>get_json_boolean( showicon ) )
                                ( n = `class`    v = class ) ) ).
  ENDMETHOD.


  METHOD message_view.

    result = _generic( name   = `MessageView`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = lcl_utility=>get_json_boolean( groupItems ) ) ) ).
  ENDMETHOD.


  METHOD mid_column_pages.

    result = _generic( name   = `midColumnPages`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id` v = id ) ) ).

  ENDMETHOD.


  METHOD multi_input.
    result = _generic( name   = `MultiInput`
                       t_prop = VALUE #( ( n = `tokens` v = tokens )
                                         ( n = `showClearIcon` v = lcl_utility=>get_json_boolean( showclearicon ) )
                                         ( n = `showValueHelp` v = lcl_utility=>get_json_boolean( showvaluehelp ) )
                                         ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                         ( n = `suggestionItems` v = suggestionitems )
                                         ( n = `tokenUpdate` v = tokenUpdate )
                                         ( n = `submit` v = submit )
                                         ( n = `width` v = width )
                                         ( n = `value` v = value )
                                         ( n = `id` v = id )
                                         ( n = `valueHelpRequest` v = valueHelpRequest )
                                         ( n = `class` v = class ) ) ).
  ENDMETHOD.


  METHOD navigation_actions.
    result = _generic( name = `navigationActions`
                       ns   = `f` ).
  ENDMETHOD.


  METHOD numericcontent.

    result = _generic( name   = `NumericContent`
                       t_prop = VALUE #( ( n = `value`      v = value )
                                         ( n = `icon`       v = icon  )
                                         ( n = `withMargin` v = lcl_utility=>get_json_boolean( withMargin ) ) ) ).

  ENDMETHOD.


  METHOD object_attribute.
    result = me.

    _generic( name   = `ObjectAttribute`
              t_prop = VALUE #( (  n = `title`       v = title )
                                (  n = `text`           v = text ) ) ).
  ENDMETHOD.


  METHOD object_identifier.
    result = _generic( name   = `ObjectIdentifier`
                       t_prop = VALUE #( ( n = `emptyIndicatorMode` v = emptyIndicatorMode )
                                         ( n = `text` v = text )
                                         ( n = `textDirection` v = textDirection )
                                         ( n = `title` v = title )
                                         ( n = `titleActive` v = titleActive )
                                         ( n = `visible` v = visible )
                                         ( n = `titlePress` v = titlePress ) ) ).
  ENDMETHOD.


  METHOD object_number.
    result = me.
    _generic( name   = `ObjectNumber`
              t_prop = VALUE #( ( n = `emphasized`  v = lcl_utility=>get_json_boolean( emphasized ) )
                                ( n = `number`      v = number )
                                ( n = `state`       v = state )
                                ( n = `unit`        v = unit ) ) ).
  ENDMETHOD.


  METHOD object_page_dyn_header_title.
    result = _generic( name = `ObjectPageDynamicHeaderTitle`
                       ns   = `uxap` ).
  ENDMETHOD.


  METHOD object_page_layout.
    result = _generic(
                 name   = `ObjectPageLayout`
                 ns     = `uxap`
                 t_prop = VALUE #(
                     ( n = `showTitleInHeaderContent` v = lcl_utility=>get_json_boolean( showTitleInHeaderContent ) )
                     ( n = `showEditHeaderButton`     v = lcl_utility=>get_json_boolean( showEditHeaderButton ) )
                     ( n = `editHeaderButtonPress`    v = editHeaderButtonPress )
                     ( n = `upperCaseAnchorBar`       v = upperCaseAnchorBar ) ) ).
  ENDMETHOD.


  METHOD object_page_section.
    result = _generic( name   = `ObjectPageSection`
                       ns     = `uxap`
                       t_prop = VALUE #( ( n = `titleUppercase`  v = lcl_utility=>get_json_boolean( titleUppercase ) )
                                         ( n = `title`           v = title )
                                         ( n = `id`              v = id )
                                         ( n = `importance`      v = importance ) ) ).
  ENDMETHOD.


  METHOD object_page_sub_section.
    result = _generic( name   = `ObjectPageSubSection`
                       ns     = `uxap`
                       t_prop = VALUE #( ( n = `id`    v = id )
                                         ( n = `title` v = title ) ) ).
  ENDMETHOD.


  METHOD object_status.
    result = _generic( name   = `ObjectStatus`
                       t_prop = VALUE #( ( n = `active` v = active )
                                         ( n = `emptyIndicatorMode` v = emptyIndicatorMode )
                                         ( n = `icon` v = icon )
                                         ( n = `iconDensityAware` v = iconDensityAware )
                                         ( n = `inverted` v = inverted )
                                         ( n = `state` v = state )
                                         ( n = `stateAnnouncementText` v = stateAnnouncementText )
                                         ( n = `text` v = text )
                                         ( n = `textDirection` v = textDirection )
                                         ( n = `title` v = title )
                                         ( n = `press` v = press ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar.
    result = _generic( `OverflowToolbar` ).
  ENDMETHOD.


  METHOD overflow_toolbar_button.
    result = me.
    _generic( name   = `OverflowToolbarButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_menu_button.
    result = _generic( name   = `OverflowToolbarMenuButton`
                       t_prop = VALUE #( ( n = `buttonMode` v = buttonMode )
                                         ( n = `defaultAction` v = defaultAction )
                                         ( n = `text`    v = text )
                                         ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                         ( n = `icon`    v = icon )
                                         ( n = `type`    v = type )
                                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_toggle_button.
    result = me.
    _generic( name   = `OverflowToolbarToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD page.
    result = _generic( name   = `Page`
                       ns     = ns
                       t_prop = VALUE #( ( n = `title` v = title )
                                         ( n = `showNavButton`  v = lcl_utility=>get_json_boolean( shownavbutton ) )
                                         ( n = `navButtonPress` v = navbuttonpress )
                                         ( n = `showHeader` v = lcl_utility=>get_json_boolean( showHeader ) )
                                         ( n = `class` v = class )
                                         ( n = `id` v = id ) ) ).
  ENDMETHOD.


  METHOD panel.
    result = _generic( name   = `Panel`
                       t_prop = VALUE #( ( n = `expandable` v = expandable )
                                         ( n = `expanded`   v = expanded )
                                         ( n = `headerText` v = headertext ) ) ).
  ENDMETHOD.


  METHOD planningcalendar.
    result = _generic( name   = `PlanningCalendar`
                       t_prop = VALUE #(
                           ( n = `rows`                      v = rows )
                           ( n = `startDate`                 v = startDate )
                           ( n = `appointmentsVisualization` v = appointmentsVisualization )
                           ( n = `appointmentSelect`         v = appointmentSelect )
                           ( n = `showEmptyIntervalHeaders`  v = showEmptyIntervalHeaders )
                           ( n = `showWeekNumbers`           v = showWeekNumbers ) ) ).
  ENDMETHOD.


  METHOD planningcalendarrow.
    result = _generic( name   = `PlanningCalendarRow`
                       t_prop = VALUE #(
                           ( n = `appointments`              v = appointments )
                           ( n = `intervalHeaders`           v = intervalHeaders )
                           ( n = `icon`                      v = icon )
                           ( n = `title`                     v = title )
                           ( n = `text`                      v = text ) ) ).
  ENDMETHOD.


  METHOD points.
    result = _generic( name = `points`
                       ns   = `mchart` ).
  ENDMETHOD.


  METHOD popover.
    result = _generic( name   = `Popover`
                       t_prop = VALUE #( ( n = `title`         v = title )
                                         ( n = `class`         v = class )
                                         ( n = `placement`     v = placement )
                                         ( n = `initialFocus`  v = initialFocus )
                                         ( n = `contentHeight` v = contentheight )
                                         ( n = `contentWidth`  v = contentwidth ) ) ).
  ENDMETHOD.


  METHOD progress_indicator.
    result = me.
    _generic( name   = `ProgressIndicator`
              t_prop = VALUE #( ( n = `percentValue` v = percentvalue )
                                ( n = `displayValue` v = displayvalue )
                                ( n = `showValue`    v = lcl_utility=>get_json_boolean( showvalue ) )
                                ( n = `state`        v = state ) ) ).
  ENDMETHOD.


METHOD proportion_zoom_strategy.
    result = _generic( name   = `ProportionZoomStrategy`
                       ns     = `axistime`
                      ).
  ENDMETHOD.


  METHOD radial_micro_chart.
    result = me.
    _generic( name   = `RadialMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `percentage`  v = percentage )
                                ( n = `press`       v = press )
                                ( n = `sice`        v = sice )
                                ( n = `valueColor`  v = valuecolor ) ) ).
  ENDMETHOD.


  METHOD radio_button.
    result = _generic( name   = `RadioButton`
                   t_prop = VALUE #( ( n = `activeHandling`  v = lcl_utility=>get_json_boolean( activeHandling ) )
                                     ( n = `editable`        v = lcl_utility=>get_json_boolean( editable ) )
                                     ( n = `enabled`         v = lcl_utility=>get_json_boolean( enabled ) )
                                     ( n = `selected`        v = lcl_utility=>get_json_boolean( selected ) )
                                     ( n = `useEntireWidth`  v = lcl_utility=>get_json_boolean( useEntireWidth ) )
                                     ( n = `text`            v = text )
                                     ( n = `textDirection`   v = textDirection )
                                     ( n = `textAlign`       v = textAlign )
                                     ( n = `groupName`       v = groupName )
                                     ( n = `valueState`      v = valueState )
                                     ( n = `width`           v = width )
           ) ).
  ENDMETHOD.


  METHOD radio_button_group.
    result = _generic( name   = `RadioButtonGroup`
                       t_prop = VALUE #( ( n = `id`             v = id )
                                         ( n = `columns`        v = columns )
                                         ( n = `editable`       v = lcl_utility=>get_json_boolean( editable ) )
                                         ( n = `enabled`        v = lcl_utility=>get_json_boolean( enabled ) )
                                         ( n = `selectedIndex`  v = selectedIndex )
                                         ( n = `textDirection`  v = textDirection )
                                         ( n = `valueState`     v = valueState )
                                         ( n = `width`          v = width )
                       ) ).
  ENDMETHOD.


  METHOD range_slider.
    result = me.
    _generic( name   = `RangeSlider`
              ns     = `webc`
              t_prop = VALUE #( ( n = `class`           v = class )
                                ( n = `endValue`        v = endvalue )
                                ( n = `id`          v = id )
                                ( n = `labelInterval`  v = labelinterval )
                                ( n = `max`   v = max )
                                ( n = `min`   v = min )
                                ( n = `showTickmarks`   v = lcl_utility=>get_json_boolean( showtickmarks ) )
                                ( n = `startValue`   v = startvalue )
                                ( n = `step`   v = step )
                                ( n = `width`   v = width ) ) ).
  ENDMETHOD.


  METHOD rows.
    result = _generic( name = `rows` ).
  ENDMETHOD.


 METHOD row_settings_template.
    result = _generic( name   = `rowSettingsTemplate`
                       ns     = `table`
                      ).
  ENDMETHOD.


  METHOD scroll_container.
    result = _generic( name   = `ScrollContainer`
                       t_prop = VALUE #( ( n = `height`      v = height )
                                         ( n = `width`       v = width )
                                         ( n = `vertical`    v = lcl_utility=>get_json_boolean( vertical ) )
                                         ( n = `horizontal`  v = lcl_utility=>get_json_boolean( horizontal ) )
                                         ( n = `focusable`   v = lcl_utility=>get_json_boolean( focusable ) ) ) ).
  ENDMETHOD.


  METHOD search_field.
    result = me.
    _generic( name   = `SearchField`
              t_prop = VALUE #( ( n = `width`  v = width )
                                ( n = `search` v = search )
                                ( n = `value`  v = value )
                                ( n = `id`     v = id )
                                ( n = `change` v = change )
                                ( n = `autocomplete` v = lcl_utility=>get_json_boolean( autocomplete ) )
                                ( n = `liveChange` v = liveChange ) ) ).
  ENDMETHOD.


  METHOD sections.
    result = _generic( name = `sections`
                       ns   = `uxap` ).
  ENDMETHOD.


  METHOD segmented_button.
    result = _generic( name   = `SegmentedButton`
                       t_prop = VALUE #( ( n = `selectedKey` v = selected_key )
                                         ( n = `selectionChange` v = selection_change ) ) ).
  ENDMETHOD.


  METHOD segmented_button_item.
    result = me.
    _generic( name   = `SegmentedButtonItem`
              t_prop = VALUE #( ( n = `icon`  v = icon )
                                ( n = `key`   v = key )
                                ( n = `text`  v = text ) ) ).
  ENDMETHOD.


  METHOD segments.
    result = _generic( name = `segments`
                       ns   = `mchart` ).
  ENDMETHOD.


METHOD shapes1.
    result = _generic( name   = `shapes1`
                       ns     = `gantt`
                      ).
  ENDMETHOD.


  METHOD shapes2.
    result = _generic( name   = `shapes2`
                       ns     = `gantt`
                      ).
  ENDMETHOD.


  METHOD shell.
    result = _generic( name = `Shell`
                       ns   = ns ).
  ENDMETHOD.


  METHOD simple_form.
    result = _generic( name   = `SimpleForm`
                       ns     = `form`
                       t_prop = VALUE #( ( n = `title`    v = title )
                                         ( n = `layout`   v = layout )
                                         ( n = `columnsXL`   v = columnsXL )
                                         ( n = `columnsL`   v = columnsL )
                                         ( n = `columnsM`   v = columnsm )
                                         ( n = `editable` v = lcl_utility=>get_json_boolean( editable ) ) ) ).
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


  METHOD standard_list_item.
    result = me.
    _generic( name   = `StandardListItem`
              t_prop = VALUE #( ( n = `title`       v = title )
                                ( n = `description` v = description )
                                ( n = `icon`        v = icon )
                                ( n = `info`        v = info )
                                ( n = `press`       v = press )
                                ( n = `type`        v = type )
                                ( n = `counter`     v = counter )
                                ( n = `selected`    v = selected ) ) ).
  ENDMETHOD.


  METHOD standard_tree_item.
    result = me.
    _generic( name   = `StandardTreeItem`
              t_prop = VALUE #( ( n = `title`       v = title )
                                ( n = `icon`        v = icon )
                                ( n = `press`       v = press )
                                ( n = `detailPress` v = detailPress )
                                ( n = `type`        v = type )
                                ( n = `counter`     v = counter )
                                ( n = `selected`    v = selected ) ) ).

  ENDMETHOD.


  METHOD step_input.
    result = me.
    _generic( name   = `StepInput`
              t_prop = VALUE #( ( n = `max`  v = max )
                                ( n = `min`  v = min )
                                ( n = `step` v = step )
                                ( n = `value` v = value ) ) ).
  ENDMETHOD.


  METHOD stringify.

    result = get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD sub_header.
    result = _generic( `subHeader` ).
  ENDMETHOD.


  METHOD sub_sections.
    result = me.
    result = _generic( name = `subSections`
                       ns   = `uxap` ).
  ENDMETHOD.


  METHOD suggestion_columns.
    result = _generic( `suggestionColumns` ).
  ENDMETHOD.


  METHOD suggestion_items.
    result = _generic( `suggestionItems` ).
  ENDMETHOD.


  METHOD suggestion_rows.
    result = _generic( `suggestionRows` ).
  ENDMETHOD.


  METHOD switch.
    result = me.
    _generic( name   = `Switch`
              t_prop = VALUE #( ( n = `type`           v = type )
                                ( n = `enabled`        v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `state`          v = state )
                                ( n = `change`         v = change )
                                ( n = `customTextOff`  v = customtextoff )
                                ( n = `customTextOn`   v = customtexton ) ) ).
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
                           ( n = `growing`          v = growing )
                           ( n = `growingThreshold` v = growingthreshold )
                           ( n = `growingScrollToLoad` v = growingscrolltoload )
                           ( n = `sticky`           v = sticky )
                           ( n = `showSeparators`           v = SHOWSEPARATORS )
                           ( n = `mode`             v = mode )
                           ( n = `inset`             v = inset )
                           ( n = `width`            v = width )
                           ( n = `id`            v = id )
                           ( n = `selectionChange`  v = selectionchange )
                           ( n = `alternateRowColors`  v = lcl_utility=>get_json_boolean( alternateRowColors ) )
                           ( n = `autoPopinMode`  v = lcl_utility=>get_json_boolean( autoPopinMode ) ) ) ).
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
                                         ( n = `type` v = type )
                                         ( n = `color` v = color ) ) ).
  ENDMETHOD.


  METHOD text.
    result = me.
    _generic( name   = `Text`
              ns     = ns
              t_prop = VALUE #( ( n = `text`  v = text )
                                ( n = `class` v = class ) ) ).
  ENDMETHOD.


  METHOD text_area.
    result = me.
    _generic( name   = `TextArea`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `rows` v = rows )
                                ( n = `height` v = height )
                                ( n = `width` v = width )
                                ( n = `editable` v = lcl_utility=>get_json_boolean( editable ) )
                                ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `id` v = id )
                                ( n = `growing` v = lcl_utility=>get_json_boolean( growing ) )
                                ( n = `growingMaxLines` v = growingmaxlines ) ) ).
  ENDMETHOD.


  METHOD tilecontent.

    result = _generic( name   = `TileContent`
                       ns     = ``
                       t_prop = VALUE #(
                                ( n = `unit`   v = unit )
                                ( n = `footer` v = footer ) ) ).

  ENDMETHOD.


METHOD time_horizon.
    result = _generic( name   = `TimeHorizon`
                       ns     = `config`
                       t_prop = VALUE #( ( n = `startTime` v = starttime )
                                         ( n = `endTime`   v = endtime )
                                       ) ).
  ENDMETHOD.


  METHOD time_picker.
    result = me.
    _generic( name   = `TimePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder`  v = placeholder ) ) ).
  ENDMETHOD.


  METHOD title.
    DATA(lv_name) = COND #( WHEN ns = 'f' THEN 'title' ELSE `Title` ).

    result = me.
    _generic( ns     = ns
              name   = lv_name
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `wrapping` v = lcl_utility=>get_json_boolean( wrapping ) )
                                ( n = `level` v = level ) ) ).
  ENDMETHOD.


  METHOD toggle_button.

    result = me.
    _generic( name   = `ToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `class`   v = class ) ) ).
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

    result = _generic( `tokens` ).

  ENDMETHOD.


  METHOD toolbar.

    result = _generic( `Toolbar` ).

  ENDMETHOD.


  METHOD toolbar_spacer.

    result = me.
    _generic( name = `ToolbarSpacer`
              ns   = ns ).

  ENDMETHOD.


  METHOD total_horizon.
    result = _generic( name   = `totalHorizon`
                       ns     = `axistime`
                      ).
  ENDMETHOD.


  METHOD tree.
    result = _generic( name   = `Tree`
                       t_prop = VALUE #(
                           ( n = `items`            v = items )
                           ( n = `headerText`       v = headertext )
                           ( n = `footerText`       v = footerText )
                           ( n = `mode`             v = mode )
                           ( n = `width`            v = width )
                           ( n = `includeItemInSelection`  v = lcl_utility=>get_json_boolean( includeItemInSelection ) )
                           ( n = `inset`  v = lcl_utility=>get_json_boolean( inset ) )
             ) ).
  ENDMETHOD.


  METHOD tree_column.

    result = _generic( name = `Column`
                  ns        = `table`
                  t_prop    = VALUE #(
                          ( n = `label`      v = label )
                          ( n = `template`   v = template )
                          ( n = `hAlign`     v = halign ) ) ).

  ENDMETHOD.


  METHOD tree_columns.

    result = _generic( name = `columns`
                       ns   = `table` ).

  ENDMETHOD.


  METHOD tree_table.

    result = _generic( name  = `TreeTable`
                      ns     = `table`
                      t_prop = VALUE #(
                                        ( n = `rows`                    v = rows )
                                        ( n = `selectionMode`           v = selectionmode )
                                        ( n = `enableColumnReordering`  v = enablecolumnreordering )
                                        ( n = `expandFirstLevel`        v = expandfirstlevel )
                                        ( n = `columnSelect`            v = columnselect )
                                        ( n = `rowSelectionChange`      v = rowselectionchange )
                                        ( n = `selectionBehavior`       v = selectionBehavior )
                                        ( n = `selectedIndex`           v = selectedIndex ) ) ).
  ENDMETHOD.


  METHOD tree_template.

    result = _generic( name = `template`
                       ns   = `table` ).

  ENDMETHOD.


  METHOD ui_column.
    result = _generic( name   = `Column`
                       ns     = 'table'
                       t_prop = VALUE #(
                          ( n = `width` v = width )
                          ( n = `showSortMenuEntry`    v = showSortMenuEntry  )
                          ( n = `sortProperty`         v = sortProperty  )
                          ( n = `showFilterMenuEntry`  v = showFilterMenuEntry )
                          ( n = `filterProperty`       v = filterProperty ) ) ).
  ENDMETHOD.


  METHOD ui_columns.
    result = _generic( name = `columns`
                       ns   = 'table' ).
  ENDMETHOD.


  METHOD ui_extension.

    result = _generic( name = `extension`
                       ns   = 'table' ).
  ENDMETHOD.


  METHOD ui_row_action.
    result = _generic( name = `RowAction`
                       ns   = `table` ).
  ENDMETHOD.


  METHOD ui_row_action_item.
    result = _generic( name   = `RowActionItem`
                       ns     = `table`
                       t_prop = VALUE #(
                          ( n = `icon`     v = icon )
                          ( n = `text`     v = text )
                          ( n = `type`     v = type  )
                          ( n = `press`    v = press ) ) ).
  ENDMETHOD.


  METHOD ui_row_action_template.
    result = _generic( name = `rowActionTemplate`
                       ns   = `table` ).
  ENDMETHOD.


  METHOD ui_table.

    result = _generic( name   = `Table`
                       ns     = `table`
                       t_prop = VALUE #(
                           ( n = `rows`                      v = rows )
                           ( n = `alternateRowColors`        v = lcl_utility=>get_json_boolean( alternateRowColors ) )
                           ( n = `columnHeaderVisible`       v = columnheadervisible )
                           ( n = `editable`                  v = lcl_utility=>get_json_boolean( editable ) )
                           ( n = `enableCellFilter`          v = lcl_utility=>get_json_boolean( enablecellfilter ) )
                           ( n = `enableGrouping`            v = lcl_utility=>get_json_boolean( enablegrouping ) )
                           ( n = `senableSelectAll`          v = lcl_utility=>get_json_boolean( enableselectall ) )
                           ( n = `firstVisibleRow`           v = firstvisiblerow )
                           ( n = `fixedBottomRowCount`       v = fixedbottomrowcount )
                           ( n = `fixedColumnCount`          v = fixedColumnCount )
                           ( n = `rowActionCount`            v = rowActionCount )
                           ( n = `fixedRowCount`             v = fixedRowCount )
                           ( n = `minAutoRowCount`           v = minAutoRowCount )
                           ( n = `minAutoRowCount`           v = minAutoRowCount )
                           ( n = `rowHeight`                 v = rowHeight )
                           ( n = `selectedIndex`             v = selectedIndex )
                           ( n = `selectionMode`             v = selectionMode )
                           ( n = `showColumnVisibilityMenu`  v = lcl_utility=>get_json_boolean( showColumnVisibilityMenu ) )
                           ( n = `showNoData`                v = lcl_utility=>get_json_boolean( showNoData ) )
                           ( n = `threshold`                 v = threshold )
                           ( n = `visibleRowCount`           v = visibleRowCount )
                           ( n = `visibleRowCountMode`       v = visibleRowCountMode )
                           ( n = `footer`                    v = footer )
                           ( n = `filter`                    v = filter )
                           ( n = `sort`                      v = sort )
                           ( n = `customFilter`              v = customFilter )
                           ( n = `id`              v = id )
                           ( n = `rowSelectionChange`        v = rowSelectionChange )
                            ) ).

  ENDMETHOD.


  METHOD ui_template.

    result = _generic( name = `template`
                       ns   = 'table' ).

  ENDMETHOD.


  METHOD vbox.

    result = _generic( name   = `VBox`
                       t_prop = VALUE #( ( n = `height` v = height )
                                         ( n = `justifyContent`  v = justifyContent )
                                         ( n = `renderType`  v = renderType )
                                         ( n = `class`  v = class ) ) ).
  ENDMETHOD.


  METHOD vertical_layout.

    result = _generic( name   = `VerticalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.


METHOD visible_horizon.
    result = _generic( name   = `visibleHorizon`
                       ns     = `axistime`
                      ).
  ENDMETHOD.


  METHOD xml_get.

    CASE mv_name.
      WHEN `ZZPLAIN`.
        result = mt_prop[ n = `VALUE` ]-v.
        RETURN.
    ENDCASE.

    DATA(lv_tmp2) = COND #( WHEN mv_ns <> `` THEN |{ mv_ns }:| ).
    DATA(lv_tmp3) = REDUCE #( INIT val = `` FOR row IN mt_prop WHERE ( v <> `` )
                          NEXT val = |{ val } { row-n }="{ escape(
                                                               val    = COND string( WHEN row-v = abap_true
                                                                                     THEN `true`
                                                                                     ELSE row-v )
                                                               format = cl_abap_format=>e_xml_attr ) }" \n | ).

    result = |{ result } <{ lv_tmp2 }{ mv_name } \n { lv_tmp3 }|.

    IF mt_child IS INITIAL.
      result = |{ result }/>|.
      RETURN.
    ENDIF.

    result = |{ result }>|.

    LOOP AT mt_child INTO DATA(lr_child).
      result = result && CAST z2ui5_cl_xml_view( lr_child )->xml_get( ).
    ENDLOOP.

    DATA(lv_ns) = COND #( WHEN mv_ns <> || THEN |{ mv_ns }:| ).
    result = |{ result }</{ lv_ns }{ mv_name }>|.

  ENDMETHOD.


  METHOD zz_plain.
    result = me.
    _generic( name   = `ZZPLAIN`
              t_prop = VALUE #( ( n = `VALUE` v = val ) ) ).
  ENDMETHOD.


  METHOD _generic.

    DATA(result2) = NEW z2ui5_cl_xml_view( ).
    result2->mv_name   = name.
    result2->mv_ns     = ns.
    result2->mt_prop  = t_prop.
    result2->mo_parent = me.
    result2->mo_root   = mo_root.
    INSERT result2 INTO TABLE mt_child.

    mo_root->mo_previous = result2.
    result = result2.

  ENDMETHOD.
ENDCLASS.
