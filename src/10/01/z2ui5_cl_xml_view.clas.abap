class Z2UI5_CL_XML_VIEW definition
  public
  final
  create protected .

public section.

  class-methods FACTORY
    importing
      !T_NS type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE optional
      !CLIENT type ref to Z2UI5_IF_CLIENT optional
    preferred parameter CLIENT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

      class-methods FACTORY_plain
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  class-methods FACTORY_POPUP
    importing
      !T_NS type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE optional
      !CLIENT type ref to Z2UI5_IF_CLIENT optional
      PREFERRED PARAMETER client
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONSTRUCTOR .
  methods HORIZONTAL_LAYOUT
    importing
      !CLASS type CLIKE optional
      !VISIBLE type CLIKE optional
      !ALLOWWRAPPING type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ICON
    importing
      !SRC type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !COLOR type CLIKE optional
      !CLASS type CLIKE optional
      !ID type CLIKE optional
      !WIDTH type CLIKE optional
      !USEICONTOOLTIP type CLIKE optional
      !NOTABSTOP type CLIKE optional
      !HOVERCOLOR type CLIKE optional
      !HOVERBACKGROUNDCOLOR type CLIKE optional
      !HEIGHT type CLIKE optional
      !DECORATIVE type CLIKE optional
      !BACKGROUNDCOLOR type CLIKE optional
      !ALT type CLIKE optional
      !ACTIVECOLOR type CLIKE optional
      !ACTIVEBACKGROUNDCOLOR type CLIKE optional
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
  methods HTML
    importing
      !content type CLIKE optional
      !afterrendering type CLIKE optional
      !preferdom type CLIKE optional
      !sanitizecontent type CLIKE optional
      !visible type CLIKE optional
      !id type CLIKE optional
      PREFERRED PARAMETER content
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
      !DIRECTION type CLIKE optional
      !DISPLAYINLINE type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
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
      !SHOWHEADER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LIST_ITEM
    importing
      !TEXT type CLIKE optional
      !ADDITIONALTEXT type CLIKE optional
      !KEY type CLIKE optional
      !ICON type CLIKE optional
      !ENABLED type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
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
      !SHOWOVERLAY type CLIKE optional
      !HIDDENINPOPIN type CLIKE optional
      !POPINLAYOUT type CLIKE optional
      !FIXEDLAYOUT type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
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
      !SHOWFOOTER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_PAGE_DYN_HEADER_TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GENERIC_TILE
    importing
      !CLASS type CLIKE optional
      !ID type CLIKE optional
      !HEADER type CLIKE optional
      !MODE type CLIKE optional
      !ADDITIONALTOOLTIP type CLIKE optional
      !APPSHORTCUT type CLIKE optional
      !BACKGROUNDCOLOR type CLIKE optional
      !BACKGROUNDIMAGE type CLIKE optional
      !DROPAREAOFFSET type CLIKE optional
      !PRESS type CLIKE optional
      !FRAMETYPE type CLIKE optional
      !FAILEDTEXT type CLIKE optional
      !HEADERIMAGE type CLIKE optional
      !SCOPE type CLIKE optional
      !SIZEBEHAVIOR type CLIKE optional
      !STATE type CLIKE optional
      !SYSTEMINFO type CLIKE optional
      !TILEBADGE type CLIKE optional
      !TILEICON type CLIKE optional
      !URL type CLIKE optional
      !VALUECOLOR type CLIKE optional
      !WIDTH type CLIKE optional
      !WRAPPINGTYPE type CLIKE optional
      !IMAGEDESCRIPTION type CLIKE optional
      !NAVIGATIONBUTTONTEXT type CLIKE optional
      !VISIBLE type CLIKE optional
      !RENDERONTHEMECHANGE type CLIKE optional
      !ENABLENAVIGATIONBUTTON type CLIKE optional
      !PRESSENABLED type CLIKE optional
      !ICONLOADED type CLIKE optional
      !SUBHEADER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods NUMERIC_CONTENT
    importing
      !VALUE type CLIKE optional
      !ICON type CLIKE optional
      !WITHMARGIN type CLIKE optional
      !ADAPTIVEFONTSIZE type CLIKE optional
      !ANIMATETEXTCHANGE type CLIKE optional
      !FORMATTERVALUE type CLIKE optional
      !ICONDESCRIPTION type CLIKE optional
      !INDICATOR type CLIKE optional
      !NULLIFYVALUE type CLIKE optional
      !SCALE type CLIKE optional
      !STATE type CLIKE optional
      !TRUNCATEVALUETO type CLIKE optional
      !VALUECOLOR type CLIKE optional
      !VISIBLE type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LINK_TILE_CONTENT
    importing
      !LINKHREF type CLIKE optional
      !LINKTEXT type CLIKE optional
      !ICONSRC type CLIKE optional
      !LINKPRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods IMAGE_CONTENT
    importing
      !SRC type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TILE_CONTENT
    importing
      !UNIT type CLIKE optional
      !FOOTERCOLOR type CLIKE optional
      !blocked type CLIKE optional
      !FRAMETYPE type CLIKE optional
      !PRIORITY type CLIKE optional
      !PRIORITYTEXT type CLIKE optional
      !STATE type CLIKE optional
      !DISABLED type CLIKE optional
      !VISIBLE type CLIKE optional
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
      !ARIAHASPOPUP type CLIKE optional
      !BACKGROUNDCOLOR type CLIKE optional
      !BADGEICON type CLIKE optional
      !BADGETOOLTIP type CLIKE optional
      !BADGEVALUESTATE type CLIKE optional
      !CUSTOMDISPLAYSIZE type CLIKE optional
      !CUSTOMFONTSIZE type CLIKE optional
      !DISPLAYSHAPE type CLIKE optional
      !FALLBACKICON type CLIKE optional
      !IMAGEFITTYPE type CLIKE optional
      !INITIALS type CLIKE optional
      !SHOWBORDER type CLIKE optional
      !DECORATIVE type CLIKE optional
      !ENABLED type CLIKE optional
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
      appWidthLimited type clike optional
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
  methods SUGGESTION_ITEM
    importing
      !DESCRIPTION type CLIKE optional
      !ICON type CLIKE optional
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
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
      !ENABLED type CLIKE optional
      !VISIBLE type CLIKE optional
      !ID type CLIKE optional
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
      !CHANGE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOKENS
    importing
        ns type clike optional
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
      !REQUIRED type CLIKE optional
      !SUGGEST type CLIKE optional
      !CLASS type CLIKE optional
      !VISIBLE type CLIKE optional
      !SUBMIT type CLIKE optional
      !VALUELIVEUPDATE type CLIKE optional
      !AUTOCOMPLETE type CLIKE optional
      !MAXSUGGESTIONWIDTH type CLIKE optional
      !FIELDWIDTH type CLIKE optional
      !VALUEHELPONLY type CLIKE optional
      !WIDTH type CLIKE optional
      !CHANGE type CLIKE optional
      !VALUEHELPICONSRC type CLIKE optional
      !TEXTFORMATTER type CLIKE optional
      !TEXTFORMATMODE type CLIKE optional
      !MAXLENGTH type CLIKE optional
      !STARTSUGGESTION type CLIKE optional
      !ENABLESUGGESTIONSHIGHLIGHTING type CLIKE optional
      !ENABLETABLEAUTOPOPINMODE type CLIKE optional
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
      !HORIZONTALSCROLLING type CLIKE optional
      !VERTICALSCROLLING type CLIKE optional
      !afterclose type CLIKE optional
    preferred parameter TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CAROUSEL
    importing
      !HEIGHT type CLIKE optional
      !CLASS type CLIKE optional
      !LOOP type CLIKE optional
      !ID type CLIKE optional
      !arrowsplacement type CLIKE optional
      !backgrounddesign type CLIKE optional
      !pageindicatorbackgrounddesign type CLIKE optional
      !pageindicatorborderdesign type CLIKE optional
      !pageindicatorplacement type CLIKE optional
      !width type CLIKE optional
      !showpageindicator type CLIKE optional
      !visible type CLIKE optional
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
    importing
      !NAME type STRING optional
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
      !ID type CLIKE optional
      !MINSCREENWIDTH type CLIKE optional
      !DEMANDPOPIN type CLIKE optional
      !HALIGN type CLIKE optional
      !VISIBLE type CLIKE optional
      !VALIGN type CLIKE optional
      !STYLECLASS type CLIKE optional
      !SORTINDICATOR type CLIKE optional
      !POPINDISPLAY type CLIKE optional
      !MERGEFUNCTIONNAME type CLIKE optional
      !MERGEDUPLICATES type CLIKE optional
      !IMPORTANCE type CLIKE optional
      !AUTOPOPINWIDTH type CLIKE optional
      !class type CLIKE optional
    preferred parameter WIDTH
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ITEMS
    importing
      !NS type CLIKE optional
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
      !SIZE type CLIKE optional
      !PERCENTAGE type CLIKE optional
      !PRESS type CLIKE optional
      !VALUECOLOR type CLIKE optional
      !HEIGHT type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
      !HIDEONNODATA type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COLUMN_LIST_ITEM
    importing
      !VALIGN type CLIKE optional
      !SELECTED type CLIKE optional
      !TYPE type CLIKE optional
      !PRESS type CLIKE optional
      !counter type CLIKE optional
      !highlight type CLIKE optional
      !highlighttext type CLIKE optional
      !navigated type CLIKE optional
      !unread type CLIKE optional
      !visible type CLIKE optional
      !detailpress type CLIKE optional
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
    importing
      !NS type CLIKE optional
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
      !VISIBLE type CLIKE optional
      !PRESS type CLIKE optional
      !CLASS type CLIKE optional
      !ID type CLIKE optional
      !NS type CLIKE optional
      !TOOLTIP type CLIKE optional
      !WIDTH type CLIKE optional
      !ICONFIRST type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !ARIAHASPOPUP type CLIKE optional
      !ACTIVEICON type CLIKE optional
      !ACCESSIBLEROLE type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
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
      !SUGGEST type CLIKE optional
      !ENABLED type CLIKE optional
      !ENABLESUGGESTIONS type CLIKE optional
      !MAXLENGTH type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !SHOWREFRESHBUTTON type CLIKE optional
      !SHOWSEARCHBUTTON type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_VIEW
    importing
      !ITEMS type CLIKE optional
      !GROUPITEMS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BARCODE_SCANNER_BUTTON
    importing
      !ID type CLIKE optional
      !SCANSUCCESS type CLIKE optional
      !SCANFAIL type CLIKE optional
      !INPUTLIVEUPDATE type CLIKE optional
      !DIALOGTITLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_POPOVER
    importing
      !ITEMS type CLIKE optional
      !GROUPITEMS type CLIKE optional
      !LISTSELECT type CLIKE optional
      !ACTIVETITLEPRESS type CLIKE optional
      !PLACEMENT type CLIKE optional
      !AFTERCLOSE type CLIKE optional
      !BEFORECLOSE type CLIKE optional
      !INITIALLYEXPANDED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MESSAGE_ITEM
    importing
      !TYPE type CLIKE optional
      !TITLE type CLIKE optional
      !SUBTITLE type CLIKE optional
      !DESCRIPTION type CLIKE optional
      !GROUPNAME type CLIKE optional
      !MARKUPDESCRIPTION type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !LONGTEXTURL type CLIKE optional
      !COUNTER type CLIKE optional
      !ACTIVETITLE type CLIKE optional
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
      !BACKGROUNDDESIGN type CLIKE optional
      !CONTENTONLYBUSY type CLIKE optional
      !ENABLESCROLLING type CLIKE optional
      !NAVBUTTONTOOLTIP type CLIKE optional
      !FLOATINGFOOTER type CLIKE optional
      !SHOWFOOTER type CLIKE optional
      !SHOWSUBHEADER type CLIKE optional
      !TITLEALIGNMENT type CLIKE optional
      !TITLELEVEL type CLIKE optional
    preferred parameter TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PANEL
    importing
      !EXPANDABLE type CLIKE optional
      !EXPANDED type CLIKE optional
      !HEADERTEXT type CLIKE optional
      !STICKYHEADER type CLIKE optional
      !HEIGHT type CLIKE optional
      !class type CLIKE optional
      !id type CLIKE optional
      !width type CLIKE optional
      !backgroundDesign type CLIKE optional
      !expandAnimation type CLIKE optional
      !visible type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VBOX
    importing
      !ID type CLIKE optional
      !HEIGHT type CLIKE optional
      !JUSTIFYCONTENT type CLIKE optional
      !CLASS type CLIKE optional
      !RENDERTYPE type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
      !DIRECTION type CLIKE optional
      !ALIGNITEMS type CLIKE optional
      !WIDTH type CLIKE optional
      !WRAP type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !DISPLAYINLINE type CLIKE optional
      !FITCONTAINER type CLIKE optional
      !VISIBLE type CLIKE optional
    preferred parameter CLASS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HBOX
    importing
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !JUSTIFYCONTENT type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
      !ALIGNITEMS type CLIKE optional
      !WIDTH type CLIKE optional
      !HEIGHT type CLIKE optional
      !RENDERTYPE type CLIKE optional
      !WRAP type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !DIRECTION type CLIKE optional
      !DISPLAYINLINE type CLIKE optional
      !FITCONTAINER type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SCROLL_CONTAINER
    importing
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !VERTICAL type CLIKE optional
      !HORIZONTAL type CLIKE optional
      !ID type CLIKE optional
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
      !ID type CLIKE optional
      !ADJUSTLABELSPAN type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !BREAKPOINTL type CLIKE optional
      !BREAKPOINTM type CLIKE optional
      !BREAKPOINTXL type CLIKE optional
      !EMPTYSPANL type CLIKE optional
      !EMPTYSPANM type CLIKE optional
      !EMPTYSPANS type CLIKE optional
      !EMPTYSPANXL type CLIKE optional
      !LABELSPANS type CLIKE optional
      !LABELSPANM type CLIKE optional
      !LABELSPANL type CLIKE optional
      !LABELSPANXL type CLIKE optional
      !MAXCONTAINERCOLS type CLIKE optional
      !MINWIDTH type CLIKE optional
      !SINGLECONTAINERFULLSIZE type CLIKE optional
      !VISIBLE type CLIKE optional
      !WIDTH type CLIKE optional
    preferred parameter TITLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods _CC_PLAIN_XML
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
      !CLASS type CLIKE optional
      !ID type CLIKE optional
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
    IMPORTING
      press type CLIKE optional
      text  type CLIKE optional
      active type CLIKE optional
      visible type CLIKE optional
      asyncMode type CLIKE optional
      enabled type CLIKE optional
      design type CLIKE optional
      type type CLIKE optional
      style type CLIKE optional
      width type CLIKE optional
      height type CLIKE optional
      class type CLIKE optional
      id type CLIKE optional
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
      !DISPLAYONLY type CLIKE optional
      !REQUIRED type CLIKE optional
      !SHOWCOLON type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !VALIGN type CLIKE optional
      !WIDTH type CLIKE optional
      !WRAPPING type CLIKE optional
      !WRAPPINGTYPE type CLIKE optional
      !ID type CLIKE optional
      !CLASS type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods IMAGE
    importing
      !SRC type CLIKE optional
      !CLASS type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !USEMAP type CLIKE optional
      !MODE type CLIKE optional
      !LAZYLOADING type CLIKE optional
      !DENSITYAWARE type CLIKE optional
      !DECORATIVE type CLIKE optional
      !BACKGROUNDSIZE type CLIKE optional
      !BACKGROUNDREPEAT type CLIKE optional
      !BACKGROUNDPOSITION type CLIKE optional
      !ARIAHASPOPUP type CLIKE optional
      !ALT type CLIKE optional
      !ACTIVESRC type CLIKE optional
      !PRESS type CLIKE optional
      !LOAD type CLIKE optional
      !ERROR type CLIKE optional
      !id type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DATE_PICKER
    importing
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !DISPLAYFORMAT type CLIKE optional
      !VALUEFORMAT type CLIKE optional
      !REQUIRED type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !ENABLED type CLIKE optional
      !SHOWCURRENTDATEBUTTON type CLIKE optional
      !CHANGE type CLIKE optional
      !HIDEINPUT type CLIKE optional
      !SHOWFOOTER type CLIKE optional
      !VISIBLE type CLIKE optional
      !SHOWVALUESTATEMESSAGE type CLIKE optional
      !MINDATE type CLIKE optional
      !MAXDATE type CLIKE optional
      !EDITABLE type CLIKE optional
      !WIDTH type CLIKE optional
      !ID type CLIKE optional
      !calendarWeekNumbering type CLIKE optional
      !displayformattype type CLIKE optional
      !class type CLIKE optional
      !textDirection type CLIKE optional
      !textAlign type CLIKE optional
      !name type CLIKE optional
      !dateValue type CLIKE optional
      !initialFocusedDateValue type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TIME_PICKER
    importing
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !ENABLED type CLIKE optional
      !VALUESTATE type CLIKE optional
      !DISPLAYFORMAT type CLIKE optional
      !VALUEFORMAT type CLIKE optional
      !REQUIRED type CLIKE optional
      !WIDTH type CLIKE optional
      !dateValue type CLIKE optional
      !localeid type CLIKE optional
      !mask type CLIKE optional
      !maskMode type CLIKE optional
      !minutesStep type CLIKE optional
      !name type CLIKE optional
      !placeholderSymbol type CLIKE optional
      !secondsStep type CLIKE optional
      !textAlign type CLIKE optional
      !textDirection type CLIKE optional
      !title type CLIKE optional
      !showCurrentTimeButton type CLIKE optional
      !showValueStateMessage type CLIKE optional
      !support2400 type CLIKE optional
      !initialfocuseddatevalue type CLIKE optional
      !hideinput type CLIKE optional
      !editable type CLIKE optional
      !visible type CLIKE optional
      !valueStateText type CLIKE optional
      !liveChange type CLIKE optional
      !change type CLIKE optional
      !afterValueHelpOpen type CLIKE optional
      !afterValueHelpClose type CLIKE optional
    preferred parameter VALUE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DATE_TIME_PICKER
    importing
      !VALUE type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !ENABLED type CLIKE optional
      !VALUESTATE type CLIKE optional
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
      !WRAPPING type CLIKE optional
      !WIDTH type CLIKE optional
      !VALIDATEURL type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !SUBTLE type CLIKE optional
      !REL type CLIKE optional
      !EMPTYINDICATORMODE type CLIKE optional
      !EMPHASIZED type CLIKE optional
      !ARIAHASPOPUP type CLIKE optional
      !ACCESSIBLEROLE type CLIKE optional
      !class type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LIST
    importing
      !HEADERTEXT type CLIKE optional
      !ITEMS type CLIKE optional
      !MODE type CLIKE optional
      !SELECTIONCHANGE type CLIKE optional
      !SHOWSEPARATORS type CLIKE optional
      !FOOTERTEXT type CLIKE optional
      !GROWINGDIRECTION type CLIKE optional
      !GROWINGTHRESHOLD type CLIKE optional
      !GROWINGTRIGGERTEXT type CLIKE optional
      !HEADERLEVEL type CLIKE optional
      !MULTISELECTMODE type CLIKE optional
      !NODATATEXT type CLIKE optional
      !STICKY type CLIKE optional
      !MODEANIMATIONON type CLIKE optional
      !GROWINGSCROLLTOLOAD type CLIKE optional
      !INCLUDEITEMINSELECTION type CLIKE optional
      !GROWING type CLIKE optional
      !INSET type CLIKE optional
      !REMEMBERSELECTIONS type CLIKE optional
      !SHOWUNREAD type CLIKE optional
      !VISIBLE type CLIKE optional
      !NODATA type CLIKE optional
      !ID type CLIKE optional
      !ITEMPRESS type CLIKE optional
      !SELECT type CLIKE optional
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
      !WRAPPING type CLIKE optional
      !WRAPCHARLIMIT type CLIKE optional
      !INFOSTATEINVERTED type CLIKE optional
      !INFOSTATE type CLIKE optional
      !ICONINSET type CLIKE optional
      !ADAPTTITLESIZE type CLIKE optional
      !ACTIVEICON type CLIKE optional
      !UNREAD type CLIKE optional
      !HIGHLIGHT type CLIKE optional
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
      !WIDTH type CLIKE optional
      !VISIBLE type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !ENABLED type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COMBOBOX
    importing
      !SELECTEDKEY type CLIKE optional
      !SHOWCLEARICON type CLIKE optional
      !SELECTIONCHANGE type CLIKE optional
      !SELECTEDITEM type CLIKE optional
      !ITEMS type CLIKE optional
      !CHANGE type CLIKE optional
      !WIDTH type CLIKE optional
      !SHOWSECONDARYVALUES type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !SELECTEDITEMID type CLIKE optional
      !NAME type CLIKE optional
      !VALUE type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !VISIBLE type CLIKE optional
      !SHOWVALUESTATEMESSAGE type CLIKE optional
      !SHOWBUTTON type CLIKE optional
      !REQUIRED type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !FILTERSECONDARYVALUES type CLIKE optional
      !id type CLIKE optional
      !class type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .

  methods MULTI_COMBOBOX
    importing
      !SELECTIONCHANGE type CLIKE optional
      !SELECTEDKEYS type CLIKE optional
      !selectedItems type CLIKE optional
      !ITEMS type CLIKE optional
      !SELECTIONFINISH type CLIKE optional
      !WIDTH type CLIKE optional
      !SHOWCLEARICON type CLIKE optional
      !SHOWSECONDARYVALUES type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !SELECTEDITEMID type CLIKE optional
      !SELECTEDKEY type CLIKE optional
      !NAME type CLIKE optional
      !VALUE type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !VISIBLE type CLIKE optional
      !SHOWVALUESTATEMESSAGE type CLIKE optional
      !SHOWBUTTON type CLIKE optional
      !REQUIRED type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !FILTERSECONDARYVALUES type CLIKE optional
      !SHOWSELECTALL type CLIKE optional
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
      !COLS type CLIKE optional
      !HEIGHT type CLIKE optional
      !CLASS type CLIKE optional
      !WIDTH type CLIKE optional
      !VALUELIVEUPDATE type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !GROWING type CLIKE optional
      !GROWINGMAXLINES type CLIKE optional
      !ID type CLIKE optional
      !REQUIRED type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !WRAPPING type CLIKE optional
      !MAXLENGTH type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !SHOWVALUESTATEMESSAGE type CLIKE optional
      !SHOWEXCEEDEDTEXT type CLIKE optional
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
      !ID type CLIKE optional
      !ARIALABELLEDBY type CLIKE optional
      !TEXT type CLIKE optional
      !DESIGN type CLIKE optional
      !STATUS type CLIKE optional
      !CLASS type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_ATTRIBUTE
    importing
      !TITLE type CLIKE optional
      !TEXT type CLIKE optional
      !ACTIVE type CLIKE optional
      !ARIAHASPOPUP type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !VISIBLE type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_NUMBER
    importing
      !STATE type CLIKE optional
      !EMPHASIZED type CLIKE optional
      !NUMBER type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !NUMBERUNIT type CLIKE optional
      !INVERTED type CLIKE optional
      !EMPTYINDICATORMODE type CLIKE optional
      !ACTIVE type CLIKE optional
      !UNIT type CLIKE optional
      !VISIBLE type CLIKE optional
      !class type CLIKE optional
      !id type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SWITCH
    importing
      !STATE type CLIKE optional
      !CUSTOMTEXTON type CLIKE optional
      !CUSTOMTEXTOFF type CLIKE optional
      !ENABLED type CLIKE optional
      !CHANGE type CLIKE optional
      !TYPE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods STEP_INPUT
    importing
      !VALUE type CLIKE optional
      !MIN type CLIKE optional
      !MAX type CLIKE optional
      !STEP type CLIKE optional
      !VALUESTATE type CLIKE optional
      !ENABLED type CLIKE optional
      !DESCRIPTION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PROGRESS_INDICATOR
    importing
      !CLASS type CLIKE optional
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
      !ID type CLIKE optional
      !VISIBLE type CLIKE optional
      !ENABLED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CHECKBOX
    importing
      !TEXT type CLIKE optional
      !SELECTED type CLIKE optional
      !ENABLED type CLIKE optional
      !SELECT type CLIKE optional
      !id type CLIKE optional
      !class type CLIKE optional
      !textalign type CLIKE optional
      !textdirection type CLIKE optional
      !width type CLIKE optional
      !activehandling type CLIKE optional
      !visible type CLIKE optional
      !displayonly type CLIKE optional
      !editable type CLIKE optional
      !partiallyselected type CLIKE optional
      !useentirewidth type CLIKE optional
      !wrapping type CLIKE optional
      !name type CLIKE optional
      !valuestate type CLIKE optional
    preferred parameter SELECTED
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER_TOOLBAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOOLBAR
    importing
      !NS type CLIKE optional
      !ID type CLIKE optional
      !PRESS type CLIKE optional
      !WIDTH type CLIKE optional
      !ACTIVE type CLIKE optional
      !ARIAHASPOPUP type CLIKE optional
      !DESIGN type CLIKE optional
      !ENABLED type CLIKE optional
      !HEIGHT type CLIKE optional
      !STYLE type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TEXT
    importing
      !TEXT type CLIKE optional
      !CLASS type CLIKE optional
      !NS type CLIKE optional
      !EMPTYINDICATORMODE type CLIKE optional
      !MAXLINES type CLIKE optional
      !RENDERWHITESPACE type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !WIDTH type CLIKE optional
      !WRAPPING type CLIKE optional
      !WRAPPINGTYPE type CLIKE optional
      !ID type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FORMATTED_TEXT
    importing
      !HTMLTEXT type CLIKE optional
      !convertedlinksdefaulttarget type CLIKE optional
      !convertlinkstoanchortags type CLIKE optional
      !height type CLIKE optional
      !textalign type CLIKE optional
      !textdirection type CLIKE optional
      !visible type CLIKE optional
      !width type CLIKE optional
      !id type CLIKE optional
      !class type CLIKE optional
      !controls type CLIKE optional
    PREFERRED PARAMETER htmlText
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods _GENERIC
    importing
      !NAME type CLIKE
      !NS type CLIKE optional
      !T_PROP type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods _GENERIC_PROPERTY
    importing
      !VAL type Z2UI5_IF_CLIENT=>TY_S_NAME_VALUE optional
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
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TREE_COLUMNS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TREE_COLUMN
    importing
      !LABEL type CLIKE
      !TEMPLATE type CLIKE optional
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
      !ID type CLIKE optional
      !PERSISTENCYKEY type CLIKE optional
      !AFTERVARIANTLOAD type CLIKE optional
      !AFTERVARIANTSAVE type CLIKE optional
      !ASSIGNEDFILTERSCHANGED type CLIKE optional
      !BEFOREVARIANTFETCH type CLIKE optional
      !CANCEL type CLIKE optional
      !CLEAR type CLIKE optional
      !FILTERCHANGE type CLIKE optional
      !FILTERSDIALOGBEFOREOPEN type CLIKE optional
      !FILTERSDIALOGCANCEL type CLIKE optional
      !FILTERSDIALOGCLOSED type CLIKE optional
      !INITIALISE type CLIKE optional
      !INITIALIZED type CLIKE optional
      !RESET type CLIKE optional
      !FILTERCONTAINERWIDTH type CLIKE optional
      !HEADER type CLIKE optional
      !ADVANCEDMODE type CLIKE optional
      !ISRUNNINGINVALUEHELPDIALOG type CLIKE optional
      !SHOWALLFILTERS type CLIKE optional
      !SHOWCLEARONFB type CLIKE optional
      !SHOWFILTERCONFIGURATION type CLIKE optional
      !SHOWGOONFB type CLIKE optional
      !SHOWRESTOREBUTTON type CLIKE optional
      !SHOWRESTOREONFB type CLIKE optional
      !USESNAPSHOT type CLIKE optional
      !SEARCHENABLED type CLIKE optional
      !CONSIDERGROUPTITLE type CLIKE optional
      !DELTAVARIANTMODE type CLIKE optional
      !DISABLESEARCHMATCHESPATTERNW type CLIKE optional
      !FILTERBAREXPANDED type CLIKE optional
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
      !BACKGROUNDDESIGN type CLIKE optional
      !DEFAULTTRANSITIONNAMEBEGINCOL type CLIKE optional
      !DEFAULTTRANSITIONNAMEENDCOL type CLIKE optional
      !DEFAULTTRANSITIONNAMEMIDCOL type CLIKE optional
      !AUTOFOCUS type CLIKE optional
      !RESTOREFOCUSONBACKNAVIGATION type CLIKE optional
      !CLASS type CLIKE optional
      !AFTERBEGINCOLUMNNAVIGATE type CLIKE optional
      !AFTERENDCOLUMNNAVIGATE type CLIKE optional
      !AFTERMIDCOLUMNNAVIGATE type CLIKE optional
      !BEGINCOLUMNNAVIGATE type CLIKE optional
      !COLUMNRESIZE type CLIKE optional
      !ENDCOLUMNNAVIGATE type CLIKE optional
      !MIDCOLUMNNAVIGATE type CLIKE optional
      !STATECHANGE type CLIKE optional
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
      !FLEX type CLIKE optional
    preferred parameter ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UI_COLUMN
    importing
      !WIDTH type CLIKE optional
      !SHOWSORTMENUENTRY type CLIKE optional
      !SORTPROPERTY type CLIKE optional
      !autoresizable type CLIKE optional
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
      !SELECT type CLIKE optional
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
      !SELECT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DYNAMIC_SIDE_CONTENT
    importing
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !SIDECONTENTVISIBILITY type CLIKE optional
      !SHOWSIDECONTENT type CLIKE optional
      !CONTAINERQUERY type CLIKE optional
    preferred parameter ID
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SIDE_CONTENT
    importing
      !WIDTH type CLIKE optional
    preferred parameter WIDTH
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PLANNING_CALENDAR
    importing
      !ROWS type CLIKE optional
      !STARTDATE type CLIKE optional
      !APPOINTMENTSVISUALIZATION type CLIKE optional
      !APPOINTMENTSELECT type CLIKE optional
      !SHOWEMPTYINTERVALHEADERS type CLIKE optional
      !SHOWWEEKNUMBERS type CLIKE optional
      !SHOWDAYNAMESLINE type CLIKE optional
      !LEGEND type CLIKE optional
    preferred parameter ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PLANNING_CALENDAR_ROW
    importing
      !APPOINTMENTS type CLIKE optional
      !INTERVALHEADERS type CLIKE optional
      !ICON type CLIKE optional
      !TITLE type CLIKE optional
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
      !ENABLEAPPOINTMENTSCREATE type CLIKE optional
      !ENABLEAPPOINTMENTSDRAGANDDROP type CLIKE optional
      !ENABLEAPPOINTMENTSRESIZE type CLIKE optional
      !NONWORKINGDAYS type CLIKE optional
      !SELECTED type CLIKE optional
      !APPOINTMENTCREATE type CLIKE optional
      !APPOINTMENTDRAGENTER type CLIKE optional
      !APPOINTMENTDROP type CLIKE optional
      !APPOINTMENTRESIZE type CLIKE optional
    preferred parameter APPOINTMENTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PLANNING_CALENDAR_LEGEND
    importing
      !ITEMS type CLIKE optional
      !ID type CLIKE optional
      !APPOINTMENTITEMS type CLIKE optional
      !STANDARDITEMS type CLIKE optional
    preferred parameter ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CALENDAR_LEGEND_ITEM
    importing
      !TEXT type CLIKE optional
      !TYPE type CLIKE optional
      !TOOLTIP type CLIKE optional
      !COLOR type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods APPOINTMENT_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INFO_LABEL
    importing
      !ID type CLIKE optional
      !TEXT type CLIKE optional
      !RENDERMODE type CLIKE optional
      !COLORSCHEME type CLIKE optional
      !ICON type CLIKE optional
      !DISPLAYONLY type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !WIDTH type CLIKE optional
      !VISIBLE type CLIKE optional
      !class type CLIKE optional
    preferred parameter TEXT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ROWS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods APPOINTMENTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CALENDAR_APPOINTMENT
    importing
      !STARTDATE type CLIKE optional
      !ENDDATE type CLIKE optional
      !ICON type CLIKE optional
      !TITLE type CLIKE optional
      !TEXT type CLIKE optional
      !TYPE type CLIKE optional
      !TENTATIVE type CLIKE optional
      !KEY type CLIKE optional
    preferred parameter STARTDATE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods INTERVAL_HEADERS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCK_LAYOUT
    importing
      !BACKGROUND type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCK_LAYOUT_ROW
    importing
      !ROWCOLORSET type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BLOCK_LAYOUT_CELL
    importing
      !BACKGROUNDCOLORSET type CLIKE optional
      !BACKGROUNDCOLORSHADE type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEALIGNMENT type CLIKE optional
      !TITLELEVEL type CLIKE optional
      !WIDTH type CLIKE optional
      !CLASS type CLIKE optional
      !ID type CLIKE optional
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
      !VISIBLE type CLIKE optional
      !id type CLIKE optional
      !class type CLIKE optional
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
  methods ICON_TAB_BAR
    importing
      !CLASS type CLIKE optional
      !SELECT type CLIKE optional
      !EXPAND type CLIKE optional
      !EXPANDABLE type CLIKE optional
      !EXPANDED type CLIKE optional
      !SELECTEDKEY type CLIKE optional
      !UPPERCASE type CLIKE optional
      !TABSOVERFLOWMODE type CLIKE optional
      !TABDENSITYMODE type CLIKE optional
      !STRETCHCONTENTHEIGHT type CLIKE optional
      !MAXNESTINGLEVEL type CLIKE optional
      !HEADERMODE type CLIKE optional
      !HEADERBACKGROUNDDESIGN type CLIKE optional
      !ENABLETABREORDERING type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !APPLYCONTENTPADDING type CLIKE optional
      !ITEMS type CLIKE optional
      !CONTENT type CLIKE optional
      !id type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ICON_TAB_FILTER
    importing
      !ITEMS type CLIKE optional
      !SHOWALL type CLIKE optional
      !ICON type CLIKE optional
      !ICONCOLOR type CLIKE optional
      !COUNT type CLIKE optional
      !TEXT type CLIKE optional
      !KEY type CLIKE optional
      !DESIGN type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !VISIBLE type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !CLASS type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ICON_TAB_SEPARATOR
    importing
      !ICON type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !VISIBLE type CLIKE optional
      !ID type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods _Z2UI5
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW_CC .
  methods GANTT_CHART_CONTAINER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONTAINER_TOOLBAR
    importing
      !SHOWSEARCHBUTTON type CLIKE optional
      !ALIGNCUSTOMCONTENTTORIGHT type CLIKE optional
      !FINDMODE type CLIKE optional
      !INFOOFSELECTITEMS type CLIKE optional
      !SHOWBIRDEYEBUTTON type CLIKE optional
      !SHOWDISPLAYTYPEBUTTON type CLIKE optional
      !SHOWLEGENDBUTTON type CLIKE optional
      !SHOWSETTINGBUTTON type CLIKE optional
      !SHOWTIMEZOOMCONTROL type CLIKE optional
      !STEPCOUNTOFSLIDER type CLIKE optional
      !ZOOMCONTROLTYPE type CLIKE optional
      !ZOOMLEVEL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GANTT_CHART_WITH_TABLE
    importing
      !ID type CLIKE optional
      !SHAPESELECTIONMODE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods AXIS_TIME_STRATEGY
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PROPORTION_ZOOM_STRATEGY
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOTAL_HORIZON
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TIME_HORIZON
    importing
      !STARTTIME type CLIKE optional
      !ENDTIME type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VISIBLE_HORIZON
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ROW_SETTINGS_TEMPLATE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GANTT_ROW_SETTINGS
    importing
      !ROWID type CLIKE optional
      !SHAPES1 type CLIKE optional
      !SHAPES2 type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SHAPES1
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SHAPES2
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TASK
    importing
      !TYPE type CLIKE optional
      !COLOR type CLIKE optional
      !ENDTIME type CLIKE optional
      !TIME type CLIKE optional
      !TITLE type CLIKE optional
      !SHOWTITLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GANTT_TABLE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RATING_INDICATOR
    importing
      !MAXVALUE type CLIKE optional
      !ENABLED type CLIKE optional
      !CLASS type CLIKE optional
      !VALUE type CLIKE optional
      !ICONSIZE type CLIKE optional
      !TOOLTIP type CLIKE optional
      !DISPLAYONLY type CLIKE optional
      !CHANGE type CLIKE optional
      !ID type CLIKE optional
      !EDITABLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GANTT_TOOLBAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BASE_RECTANGLE
    importing
      !TIME type CLIKE optional
      !ENDTIME type CLIKE optional
      !SELECTABLE type CLIKE optional
      !SELECTEDFILL type CLIKE optional
      !FILL type CLIKE optional
      !HEIGHT type CLIKE optional
      !TITLE type CLIKE optional
      !ANIMATIONSETTINGS type CLIKE optional
      !ALIGNSHAPE type CLIKE optional
      !COLOR type CLIKE optional
      !FONTSIZE type CLIKE optional
      !CONNECTABLE type CLIKE optional
      !FONTFAMILY type CLIKE optional
      !FILTER type CLIKE optional
      !TRANSFORM type CLIKE optional
      !COUNTINBIRDEYE type CLIKE optional
      !FONTWEIGHT type CLIKE optional
      !SHOWTITLE type CLIKE optional
      !SELECTED type CLIKE optional
      !RESIZABLE type CLIKE optional
      !HORIZONTALTEXTALIGNMENT type CLIKE optional
      !HIGHLIGHTED type CLIKE optional
      !HIGHLIGHTABLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOOL_PAGE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TOOL_HEADER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ICON_TAB_HEADER
    importing
      !SELECTEDKEY type CLIKE optional
      !ITEMS type CLIKE optional
      !SELECT type CLIKE optional
      !MODE type CLIKE optional
      !ARIATEXTS type CLIKE optional
      !BACKGROUNDDESIGN type CLIKE optional
      !ENABLETABREORDERING type CLIKE optional
      !MAXNESTINGLEVEL type CLIKE optional
      !TABDENSITYMODE type CLIKE optional
      !TABSOVERFLOWMODE type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods NAV_CONTAINER
    importing
      !INITIALPAGE type CLIKE optional
      !ID type CLIKE optional
      !DEFAULTTRANSITIONNAME type CLIKE optional
      !autoFocus type CLIKE optional
      !height type CLIKE optional
      !width type CLIKE optional
      !visible type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PAGES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MAIN_CONTENTS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TABLE_SELECT_DIALOG
    importing
      !CONFIRMBUTTONTEXT type CLIKE optional
      !CONTENTHEIGHT type CLIKE optional
      !CONTENTWIDTH type CLIKE optional
      !DRAGGABLE type CLIKE optional
      !GROWING type CLIKE optional
      !GROWINGTHRESHOLD type CLIKE optional
      !MULTISELECT type CLIKE optional
      !NODATATEXT type CLIKE optional
      !REMEMBERSELECTIONS type CLIKE optional
      !RESIZABLE type CLIKE optional
      !SEARCHPLACEHOLDER type CLIKE optional
      !SHOWCLEARBUTTON type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEALIGNMENT type CLIKE optional
      !VISIBLE type CLIKE optional
      !ITEMS type CLIKE optional
      !LIVECHANGE type CLIKE optional
      !CANCEL type CLIKE optional
      !SEARCH type CLIKE optional
      !CONFIRM type CLIKE optional
      !SELECTIONCHANGE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PROCESS_FLOW
    importing
      !ID type CLIKE optional
      !FOLDEDCORNERS type CLIKE optional
      !SCROLLABLE type CLIKE optional
      !SHOWLABELS type CLIKE optional
      !VISIBLE type CLIKE optional
      !WHEELZOOMABLE type CLIKE optional
      !HEADERPRESS type CLIKE optional
      !LABELPRESS type CLIKE optional
      !NODEPRESS type CLIKE optional
      !ONERROR type CLIKE optional
      !LANES type CLIKE optional
      !NODES type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods NODES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LANES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PROCESS_FLOW_NODE
    importing
      !LANEID type CLIKE optional
      !NODEID type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEABBREVIATION type CLIKE optional
      !CHILDREN type CLIKE optional
      !STATE type CLIKE optional
      !STATETEXT type CLIKE optional
      !TEXTS type CLIKE optional
      !HIGHLIGHTED type CLIKE optional
      !FOCUSED type CLIKE optional
      !SELECTED type CLIKE optional
      !TAG type CLIKE optional
      !TYPE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PROCESS_FLOW_LANE_HEADER
    importing
      !ICONSRC type CLIKE optional
      !LANEID type CLIKE optional
      !POSITION type CLIKE optional
      !STATE type CLIKE optional
      !TEXT type CLIKE optional
      !ZOOMLEVEL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VIEW_SETTINGS_DIALOG
    importing
      !CONFIRM type CLIKE optional
      !CANCEL type CLIKE optional
      !FILTERDETAILPAGEOPENED type CLIKE optional
      !RESET type CLIKE optional
      !RESETFILTERS type CLIKE optional
      !FILTERSEARCHOPERATOR type CLIKE optional
      !GROUPDESCENDING type CLIKE optional
      !SORTDESCENDING type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEALIGNMENT type CLIKE optional
      !SELECTEDGROUPITEM type CLIKE optional
      !SELECTEDPRESETFILTERITEM type CLIKE optional
      !SELECTEDSORTITEM type CLIKE optional
      !FILTERITEMS type CLIKE optional
      !SORTITEMS type CLIKE optional
      !GROUPITEMS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FILTER_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SORT_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods GROUP_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VIEW_SETTINGS_FILTER_ITEM
    importing
      !ENABLED type CLIKE optional
      !KEY type CLIKE optional
      !MULTISELECT type CLIKE optional
      !SELECTED type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VIEW_SETTINGS_ITEM
    importing
      !ENABLED type CLIKE optional
      !KEY type CLIKE optional
      !SELECTED type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VARIANT_MANAGEMENT
    importing
      !DEFAULTVARIANTKEY type CLIKE optional
      !ENABLED type CLIKE optional
      !INERRORSTATE type CLIKE optional
      !INITIALSELECTIONKEY type CLIKE optional
      !LIFECYCLESUPPORT type CLIKE optional
      !SELECTIONKEY type CLIKE optional
      !SHOWCREATETILE type CLIKE optional
      !SHOWEXECUTEONSELECTION type CLIKE optional
      !SHOWSETASDEFAULT type CLIKE optional
      !SHOWSHARE type CLIKE optional
      !STANDARDITEMAUTHOR type CLIKE optional
      !STANDARDITEMTEXT type CLIKE optional
      !USEFAVORITES type CLIKE optional
      !VISIBLE type CLIKE optional
      !VARIANTITEMS type CLIKE optional
      !MANAGE type CLIKE optional
      !SAVE type CLIKE optional
      !SELECT type CLIKE optional
      !USERVARCREATE type CLIKE optional
      !ID type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VARIANT_ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VARIANT_ITEM
    importing
      !EXECUTEONSELECTION type CLIKE optional
      !GLOBAL type CLIKE optional
      !LABELREADONLY type CLIKE optional
      !LIFECYCLEPACKAGE type CLIKE optional
      !LIFECYCLETRANSPORTID type CLIKE optional
      !NAMESPACE type CLIKE optional
      !READONLY type CLIKE optional
      !EXECUTEONSELECT type CLIKE optional
      !AUTHOR type CLIKE optional
      !CHANGEABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !FAVORITE type CLIKE optional
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
      !TITLE type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !ORIGINALTITLE type CLIKE optional
      !ORIGINALEXECUTEONSELECT type CLIKE optional
      !REMOVE type CLIKE optional
      !RENAME type CLIKE optional
      !ORIGINALFAVORITE type CLIKE optional
      !SHARING type CLIKE optional
      !CHANGE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FEED_INPUT
    importing
      !BUTTONTOOLTIP type CLIKE optional
      !ENABLED type CLIKE optional
      !GROWING type CLIKE optional
      !GROWINGMAXLINES type CLIKE optional
      !ICON type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !ICONDISPLAYSHAPE type CLIKE optional
      !ICONINITIALS type CLIKE optional
      !ICONSIZE type CLIKE optional
      !MAXLENGTH type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !ROWS type CLIKE optional
      !SHOWEXCEEDEDTEXT type CLIKE optional
      !SHOWICON type CLIKE optional
      !VALUE type CLIKE optional
      !POST type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FEED_LIST_ITEM
    importing
      !ACTIVEICON type CLIKE optional
      !CONVERTEDLINKSDEFAULTTARGET type CLIKE optional
      !CONVERTLINKSTOANCHORTAGS type CLIKE optional
      !ICON type CLIKE optional
      !ICONACTIVE type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !ICONDISPLAYSHAPE type CLIKE optional
      !ICONINITIALS type CLIKE optional
      !ICONSIZE type CLIKE optional
      !INFO type CLIKE optional
      !LESSLABEL type CLIKE optional
      !MAXCHARACTERS type CLIKE optional
      !MORELABEL type CLIKE optional
      !SENDER type CLIKE optional
      !SENDERACTIVE type CLIKE optional
      !SHOWICON type CLIKE optional
      !TEXT type CLIKE optional
      !TIMESTAMP type CLIKE optional
      !ICONPRESS type CLIKE optional
      !SENDERPRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FEED_LIST_ITEM_ACTION
    importing
      !ENABLED type CLIKE optional
      !ICON type CLIKE optional
      !KEY type CLIKE optional
      !TEXT type CLIKE optional
      !VISIBLE type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MASK_INPUT
    importing
      !PLACEHOLDER type CLIKE optional
      !MASK type CLIKE optional
      !NAME type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !VALUE type CLIKE optional
      !WIDTH type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !PLACEHOLDERSYMBOL type CLIKE optional
      !REQUIRED type CLIKE optional
      !SHOWCLEARICON type CLIKE optional
      !SHOWVALUESTATEMESSAGE type CLIKE optional
      !VISIBLE type CLIKE optional
      !FIELDWIDTH type CLIKE optional
      !LIVECHANGE type CLIKE optional
      !CHANGE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RESPONSIVE_SPLITTER
    importing
      !DEFAULTPANE type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PANE_CONTAINER
    importing
      !RESIZE type CLIKE optional
      !ORIENTATION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SPLIT_PANE
    importing
      !ID type CLIKE optional
      !REQUIREDPARENTWIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SPLITTER_LAYOUT_DATA
    importing
      !SIZE type CLIKE optional
      !MINSIZE type CLIKE optional
      !RESIZABLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_HEADER
    importing
      !BACKGROUNDDESIGN type CLIKE optional
      !CONDENSED type CLIKE optional
      !FULLSCREENOPTIMIZED type CLIKE optional
      !ICON type CLIKE optional
      !ICONACTIVE type CLIKE optional
      !ICONALT type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !ICONTOOLTIP type CLIKE optional
      !IMAGESHAPE type CLIKE optional
      !INTRO type CLIKE optional
      !INTROACTIVE type CLIKE optional
      !INTROHREF type CLIKE optional
      !INTROTARGET type CLIKE optional
      !INTROTEXTDIRECTION type CLIKE optional
      !NUMBER type CLIKE optional
      !NUMBERSTATE type CLIKE optional
      !NUMBERTEXTDIRECTION type CLIKE optional
      !NUMBERUNIT type CLIKE optional
      !RESPONSIVE type CLIKE optional
      !SHOWTITLESELECTOR type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEACTIVE type CLIKE optional
      !TITLEHREF type CLIKE optional
      !TITLELEVEL type CLIKE optional
      !TITLESELECTORTOOLTIP type CLIKE optional
      !TITLETARGET type CLIKE optional
      !TITLETEXTDIRECTION type CLIKE optional
      !ICONPRESS type CLIKE optional
      !INTROPRESS type CLIKE optional
      !TITLEPRESS type CLIKE optional
      !TITLESELECTORPRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ADDITIONAL_NUMBERS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER_CONTAINER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MARKERS
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods STATUSES
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FIRST_STATUS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SECOND_STATUS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_MARKER
    importing
      !ADDITIONALINFO type CLIKE optional
      !TYPE type CLIKE optional
      !VISIBILITY type CLIKE optional
      !VISIBLE type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods OBJECT_LIST_ITEM
    importing
      !ACTIVEICON type CLIKE optional
      !ICON type CLIKE optional
      !ICONDENSITYAWARE type CLIKE optional
      !INTRO type CLIKE optional
      !INTROTEXTDIRECTION type CLIKE optional
      !NUMBER type CLIKE optional
      !NUMBERSTATE type CLIKE optional
      !NUMBERTEXTDIRECTION type CLIKE optional
      !NUMBERUNIT type CLIKE optional
      !TITLE type CLIKE optional
      !TITLETEXTDIRECTION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DETAIL_BOX
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LIGHT_BOX
    IMPORTING
      !id type CLIKE optional
      !class type CLIKE optional
      !visible type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LIGHT_BOX_ITEM
    importing
      !ALT type CLIKE optional
      !IMAGESRC type CLIKE optional
      !SUBTITLE type CLIKE optional
      !TITLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LINE_MICRO_CHART
    importing
      !COLOR type CLIKE optional
      !HEIGHT type CLIKE optional
      !LEFTBOTTOMLABEL type CLIKE optional
      !LEFTTOPLABEL type CLIKE optional
      !MAXXVALUE type CLIKE optional
      !MINXVALUE type CLIKE optional
      !MINYVALUE type CLIKE optional
      !RIGHTBOTTOMLABEL type CLIKE optional
      !RIGHTTOPLABEL type CLIKE optional
      !SIZE type CLIKE optional
      !THRESHOLD type CLIKE optional
      !THRESHOLDDISPLAYVALUE type CLIKE optional
      !WIDTH type CLIKE optional
      !PRESS type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !SHOWBOTTOMLABELS type CLIKE optional
      !SHOWPOINTS type CLIKE optional
      !SHOWTHRESHOLDLINE type CLIKE optional
      !SHOWTHRESHOLDVALUE type CLIKE optional
      !SHOWTOPLABELS type CLIKE optional
      !MAXYVALUE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods STACKED_BAR_MICRO_CHART
    importing
      !HEIGHT type CLIKE optional
      !PRESS type CLIKE optional
      !MAXVALUE type CLIKE optional
      !PRECISION type CLIKE optional
      !SIZE type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !DISPLAYZEROVALUE type CLIKE optional
      !SHOWLABELS type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COLUMN_MICRO_CHART
    importing
      !WIDTH type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !ALLOWCOLUMNLABELS type CLIKE optional
      !SHOWBOTTOMLABELS type CLIKE optional
      !SHOWTOPLABELS type CLIKE optional
      !HEIGHT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COMPARISON_MICRO_CHART
    importing
      !COLORPALETTE type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !HEIGHT type CLIKE optional
      !MAXVALUE type CLIKE optional
      !MINVALUE type CLIKE optional
      !SCALE type CLIKE optional
      !WIDTH type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !SHRINKABLE type CLIKE optional
      !VIEW type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DELTA_MICRO_CHART
    importing
      !COLOR type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !DELTADISPLAYVALUE type CLIKE optional
      !DISPLAYVALUE1 type CLIKE optional
      !DISPLAYVALUE2 type CLIKE optional
      !TITLE2 type CLIKE optional
      !VALUE1 type CLIKE optional
      !VALUE2 type CLIKE optional
      !VIEW type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !TITLE1 type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods BULLET_MICRO_CHART
    importing
      !ACTUALVALUELABEL type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !DELTAVALUELABEL type CLIKE optional
      !MAXVALUE type CLIKE optional
      !MINVALUE type CLIKE optional
      !MODE type CLIKE optional
      !SCALE type CLIKE optional
      !TARGETVALUE type CLIKE optional
      !TARGETVALUELABEL type CLIKE optional
      !SCALECOLOR type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !SHOWACTUALVALUE type CLIKE optional
      !SHOWDELTAVALUE type CLIKE optional
      !SHOWTARGETVALUE type CLIKE optional
      !SHOWTHRESHOLDS type CLIKE optional
      !SHOWVALUEMARKER type CLIKE optional
      !SMALLRANGEALLOWED type CLIKE optional
      !FORECASTVALUE type CLIKE optional
      !SAVIDM type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HARVEY_BALL_MICRO_CHART
    importing
      !COLORPALETTE type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !HEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !TOTAL type CLIKE optional
      !TOTALLABEL type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !FORMATTEDLABEL type CLIKE optional
      !SHOWFRACTIONS type CLIKE optional
      !SHOWTOTAL type CLIKE optional
      !TOTALSCALE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods AREA_MICRO_CHART
    importing
      !COLORPALETTE type CLIKE optional
      !PRESS type CLIKE optional
      !SIZE type CLIKE optional
      !HEIGHT type CLIKE optional
      !MAXXVALUE type CLIKE optional
      !MAXYVALUE type CLIKE optional
      !MINXVALUE type CLIKE optional
      !MINYVALUE type CLIKE optional
      !VIEW type CLIKE optional
      !ALIGNCONTENT type CLIKE optional
      !HIDEONNODATA type CLIKE optional
      !SHOWLABEL type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DATA
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RICH_TEXT_EDITOR
    importing
      !BUTTONGROUPS type CLIKE optional
      !CUSTOMTOOLBAR type CLIKE optional
      !EDITABLE type CLIKE optional
      !EDITORTYPE type CLIKE optional
      !HEIGHT type CLIKE optional
      !PLUGINS type CLIKE optional
      !REQUIRED type CLIKE optional
      !SANITIZEVALUE type CLIKE optional
      !SHOWGROUPCLIPBOARD type CLIKE optional
      !SHOWGROUPFONT type CLIKE optional
      !SHOWGROUPFONTSTYLE type CLIKE optional
      !SHOWGROUPINSERT type CLIKE optional
      !SHOWGROUPLINK type CLIKE optional
      !SHOWGROUPSTRUCTURE type CLIKE optional
      !SHOWGROUPTEXTALIGN type CLIKE optional
      !SHOWGROUPUNDO type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !USELEGACYTHEME type CLIKE optional
      !VALUE type CLIKE optional
      !WIDTH type CLIKE optional
      !WRAPPING type CLIKE optional
      !BEFOREEDITORINIT type CLIKE optional
      !CHANGE type CLIKE optional
      !READY type CLIKE optional
      !READYRECURRING type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UPLOAD_SET
    importing
      !ID type CLIKE optional
      !INSTANTUPLOAD type CLIKE optional
      !SHOWICONS type CLIKE optional
      !UPLOADENABLED type CLIKE optional
      !TERMINATIONENABLED type CLIKE optional
      !FILETYPES type CLIKE optional
      !MAXFILENAMELENGTH type CLIKE optional
      !MAXFILESIZE type CLIKE optional
      !MEDIATYPES type CLIKE optional
      !UPLOADURL type CLIKE optional
      !ITEMS type CLIKE optional
      !MODE type CLIKE optional
      !SELECTIONCHANGED type CLIKE optional
      !UPLOADCOMPLETED type CLIKE optional
      !AFTERITEMADDED type CLIKE optional
      !SAMEFILENAMEALLOWED type CLIKE optional
      !UPLOADBUTTONINVISIBLE type CLIKE optional
      !DIRECTORY type CLIKE optional
      !MULTIPLE type CLIKE optional
      !DRAGDROPDESCRIPTION type CLIKE optional
      !DRAGDROPTEXT type CLIKE optional
      !NODATATEXT type CLIKE optional
      !NODATADESCRIPTION type CLIKE optional
      !NODATAILLUSTRATIONTYPE type CLIKE optional
      !AFTERITEMEDITED type CLIKE optional
      !AFTERITEMREMOVED type CLIKE optional
      !BEFOREITEMADDED type CLIKE optional
      !BEFOREITEMEDITED type CLIKE optional
      !BEFOREITEMREMOVED type CLIKE optional
      !BEFOREUPLOADSTARTS type CLIKE optional
      !BEFOREUPLOADTERMINATION type CLIKE optional
      !FILENAMELENGTHEXCEEDED type CLIKE optional
      !FILERENAMED type CLIKE optional
      !FILESIZEEXCEEDED type CLIKE optional
      !FILETYPEMISMATCH type CLIKE optional
      !ITEMDRAGSTART type CLIKE optional
      !ITEMDROP type CLIKE optional
      !MEDIATYPEMISMATCH type CLIKE optional
      !UPLOADTERMINATED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UPLOAD_SET_TOOLBAR_PLACEHOLDER
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods UPLOAD_SET_ITEM
    importing
      !FILENAME type CLIKE optional
      !MEDIATYPE type CLIKE optional
      !URL type CLIKE optional
      !THUMBNAILURL type CLIKE optional
      !MARKERS type CLIKE optional
      !STATUSES type CLIKE optional
      !ENABLEDEDIT type CLIKE optional
      !ENABLEDREMOVE type CLIKE optional
      !SELECTED type CLIKE optional
      !VISIBLEEDIT type CLIKE optional
      !VISIBLEREMOVE type CLIKE optional
      !UPLOADSTATE type CLIKE optional
      !UPLOADURL type CLIKE optional
      !OPENPRESSED type CLIKE optional
      !REMOVEPRESSED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MARKERS_AS_STATUS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods RULES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MASK_INPUT_RULE
    importing
      !MASKFORMATSYMBOL type CLIKE optional
      !REGEX type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SIDE_PANEL
    importing
      !ACTIONBAREXPANDED type CLIKE optional
      !ARIALABEL type CLIKE optional
      !SIDEPANELMAXWIDTH type CLIKE optional
      !SIDEPANELMINWIDTH type CLIKE optional
      !SIDEPANELPOSITION type CLIKE optional
      !SIDEPANELRESIZABLE type CLIKE optional
      !SIDEPANELRESIZELARGERSTEP type CLIKE optional
      !SIDEPANELRESIZESTEP type CLIKE optional
      !SIDEPANELWIDTH type CLIKE optional
      !TOGGLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SIDE_PANEL_ITEM
    importing
      !ICON type CLIKE optional
      !TEXT type CLIKE optional
      !KEY type CLIKE optional
      !ENABLED type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MAIN_CONTENT
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods QUICK_VIEW
    importing
      !PLACEMENT type CLIKE optional
      !WIDTH type CLIKE optional
      !AFTERCLOSE type CLIKE optional
      !AFTEROPEN type CLIKE optional
      !BEFORECLOSE type CLIKE optional
      !BEFOREOPEN type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods QUICK_VIEW_PAGE
    importing
      !DESCRIPTION type CLIKE optional
      !HEADER type CLIKE optional
      !PAGEID type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEURL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods QUICK_VIEW_PAGE_AVATAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods QUICK_VIEW_GROUP
    importing
      !HEADING type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods QUICK_VIEW_GROUP_ELEMENT
    importing
      !EMAILSUBJECT type CLIKE optional
      !LABEL type CLIKE optional
      !PAGELINKID type CLIKE optional
      !TARGET type CLIKE optional
      !TYPE type CLIKE optional
      !URL type CLIKE optional
      !VALUE type CLIKE optional
      !VISIBLE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VARIANT_MANAGEMENT_FL
    importing
      !DISPLAYTEXTFSV type CLIKE optional
      !EDITABLE type CLIKE optional
      !EXECUTEONSELECTIONFORSTANDFLT type CLIKE optional
      !HEADERLEVEL type CLIKE optional
      !INERRORSTATE type CLIKE optional
      !MAXWIDTH type CLIKE optional
      !MODELNAME type CLIKE optional
      !RESETONCONTEXTCHANGE type CLIKE optional
      !SHOWSETASDEFAULT type CLIKE optional
      !TITLESTYLE type CLIKE optional
      !UPDATEVARIANTINURL type CLIKE optional
      !FOR type CLIKE optional
      !CANCEL type CLIKE optional
      !INITIALIZED type CLIKE optional
      !MANAGE type CLIKE optional
      !SAVE type CLIKE optional
      !SELECT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods COLUMN_ELEMENT_DATA
    importing
      !CELLSLARGE type CLIKE optional
      !CELLSSMALL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FB_CONTROL
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SMART_VARIANT_MANAGEMENT
    importing
      !ID type CLIKE optional
      !SHOWEXECUTEONSELECTION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods FORM_TOOLBAR
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods PAGING_BUTTON
    importing
      !COUNT type CLIKE optional
      !NEXTBUTTONTOOLTIP type CLIKE optional
      !PREVIOUSBUTTONTOOLTIP type CLIKE optional
      !POSITION type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TIMELINE
    importing
      !ID type CLIKE optional
      !ENABLEDOUBLESIDED type CLIKE optional
      !GROUPBY type CLIKE optional
      !GROWINGTHRESHOLD type CLIKE optional
      !FILTERTITLE type CLIKE optional
      !SORTOLDESTFIRST type CLIKE optional
      !ALIGNMENT type CLIKE optional
      !AXISORIENTATION type CLIKE optional
      !CONTENT type CLIKE optional
      !ENABLEMODELFILTER type CLIKE optional
      !ENABLESCROLL type CLIKE optional
      !FORCEGROWING type CLIKE optional
      !GROUP type CLIKE optional
      !LAZYLOADING type CLIKE optional
      !SHOWHEADERBAR type CLIKE optional
      !SHOWICONS type CLIKE optional
      !SHOWITEMFILTER type CLIKE optional
      !SHOWSEARCH type CLIKE optional
      !SHOWSORT type CLIKE optional
      !SHOWTIMEFILTER type CLIKE optional
      !SORT type CLIKE optional
      !GROUPBYTYPE type CLIKE optional
      !TEXTHEIGHT type CLIKE optional
      !WIDTH type CLIKE optional
      !HEIGHT type CLIKE optional
      !NODATATEXT type CLIKE optional
      !FILTERLIST type CLIKE optional
      !CUSTOMFILTER type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods TIMELINE_ITEM
    importing
      !ID type CLIKE optional
      !DATETIME type CLIKE optional
      !TITLE type CLIKE optional
      !USERNAMECLICKABLE type CLIKE optional
      !USEICONTOOLTIP type CLIKE optional
      !USERNAMECLICKED type CLIKE optional
      !SELECT type CLIKE optional
      !USERPICTURE type CLIKE optional
      !TEXT type CLIKE optional
      !USERNAME type CLIKE optional
      !FILTERVALUE type CLIKE optional
      !ICONDISPLAYSHAPE type CLIKE optional
      !ICONINITIALS type CLIKE optional
      !ICONSIZE type CLIKE optional
      !ICONTOOLTIP type CLIKE optional
      !MAXCHARACTERS type CLIKE optional
      !REPLYCOUNT type CLIKE optional
      !STATUS type CLIKE optional
      !CUSTOMACTIONCLICKED type CLIKE optional
      !PRESS type CLIKE optional
      !REPLYLISTOPEN type CLIKE optional
      !REPLYPOST type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SPLIT_CONTAINER
    importing
      !ID type CLIKE optional
      !INITIALDETAIL type CLIKE optional
      !INITIALMASTER type CLIKE optional
      !BACKGROUNDCOLOR type CLIKE optional
      !BACKGROUNDIMAGE type CLIKE optional
      !BACKGROUNDOPACITY type CLIKE optional
      !BACKGROUNDREPEAT type CLIKE optional
      !DEFAULTTRANSITIONNAMEDETAIL type CLIKE optional
      !DEFAULTTRANSITIONNAMEMASTER type CLIKE optional
      !MASTERBUTTONTEXT type CLIKE optional
      !MASTERBUTTONTOOLTIP type CLIKE optional
      !MODE type CLIKE optional
      !AFTERDETAILNAVIGATE type CLIKE optional
      !AFTERMASTERCLOSE type CLIKE optional
      !AFTERMASTERNAVIGATE type CLIKE optional
      !AFTERMASTEROPEN type CLIKE optional
      !BEFOREMASTERCLOSE type CLIKE optional
      !BEFOREMASTEROPEN type CLIKE optional
      !DETAILNAVIGATE type CLIKE optional
      !MASTERBUTTON type CLIKE optional
      !MASTERNAVIGATE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DETAIL_PAGES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MASTER_PAGES
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONTAINER_CONTENT
    importing
      !ID type CLIKE optional
      !TITLE type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods MAP_CONTAINER
    importing
      !ID type CLIKE optional
      !AUTOADJUSTHEIGHT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SPOT
    importing
      !ID type CLIKE optional
      !POSITION type CLIKE optional
      !CONTENTOFFSET type CLIKE optional
      !TYPE type CLIKE optional
      !SCALE type CLIKE optional
      !TOOLTIP type CLIKE optional
      !IMAGE type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ANALYTIC_MAP
    importing
      !ID type CLIKE optional
      !INITIALPOSITION type CLIKE optional
      !INITIALZOOM type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SPOTS
    importing
      !ID type CLIKE optional
      !ITEMS type CLIKE optional
    preferred parameter ITEMS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods VOS
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods ACTION_SHEET
    importing
      !ID type CLIKE optional
      !CANCELBUTTONTEXT type CLIKE optional
      !PLACEMENT type CLIKE optional
      !SHOWCANCELBUTTON type CLIKE optional
      !TITLE type CLIKE optional
      !AFTERCLOSE type CLIKE optional
      !AFTEROPEN type CLIKE optional
      !BEFORECLOSE type CLIKE optional
      !BEFOREOPEN type CLIKE optional
      !CANCELBUTTONPRESS type CLIKE optional
      !VISIBLE type CLIKE optional
      !CLASS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods EXPANDABLE_TEXT
    importing
      !ID type CLIKE optional
      !EMPTYINDICATORMODE type CLIKE optional
      !MAXCHARACTERS type CLIKE optional
      !OVERFLOWMODE type CLIKE optional
      !RENDERWHITESPACE type CLIKE optional
      !TEXT type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !VISIBLE type CLIKE optional
      !WRAPPINGTYPE type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SELECT
    importing
      !ID type CLIKE optional
      !AUTOADJUSTWIDTH type CLIKE optional
      !COLUMNRATIO type CLIKE optional
      !EDITABLE type CLIKE optional
      !ENABLED type CLIKE optional
      !FORCESELECTION type CLIKE optional
      !ICON type CLIKE optional
      !MAXWIDTH type CLIKE optional
      !NAME type CLIKE optional
      !REQUIRED type CLIKE optional
      !RESETONMISSINGKEY type CLIKE optional
      !SELECTEDITEMID type CLIKE optional
      !SELECTEDKEY type CLIKE optional
      !SHOWSECONDARYVALUES type CLIKE optional
      !TEXTALIGN type CLIKE optional
      !TEXTDIRECTION type CLIKE optional
      !TYPE type CLIKE optional
      !VALUESTATE type CLIKE optional
      !VALUESTATETEXT type CLIKE optional
      !VISIBLE type CLIKE optional
      !WIDTH type CLIKE optional
      !WRAPITEMSTEXT type CLIKE optional
      !ITEMS type CLIKE optional
      !SELECTEDITEM type CLIKE optional
      !CHANGE type CLIKE optional
      !LIVECHANGE type CLIKE optional
      !class type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods EMBEDDED_CONTROL
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods HEADER_CONTAINER_CONTROL
    importing
      !BACKGROUNDDESIGN type CLIKE optional
      !GRIDLAYOUT type CLIKE optional
      !HEIGHT type CLIKE optional
      !ORIENTATION type CLIKE optional
      !SCROLLSTEP type CLIKE optional
      !SCROLLSTEPBYITEM type CLIKE optional
      !SCROLLTIME type CLIKE optional
      !SHOWDIVIDERS type CLIKE optional
      !SHOWOVERFLOWITEM type CLIKE optional
      !VISIBLE type CLIKE optional
      !WIDTH type CLIKE optional
      !ID type CLIKE optional
      !SCROLL type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods DEPENDENTS
    importing
      !NS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CARD
    importing
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !HEADERPOSITION type CLIKE optional
      !HEIGHT type CLIKE optional
      !VISIBLE type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CARD_HEADER
    importing
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !ICONALT type CLIKE optional
      !ICONBACKGROUNDCOLOR type CLIKE optional
      !ICONDISPLAYSHAPE type CLIKE optional
      !ICONINITIALS type CLIKE optional
      !ICONSIZE type CLIKE optional
      !ICONSRC type CLIKE optional
      !ICONVISIBLE type CLIKE optional
      !STATUSTEXT type CLIKE optional
      !STATUSVISIBLE type CLIKE optional
      !SUBTITLE type CLIKE optional
      !SUBTITLEMAXLINES type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEMAXLINES type CLIKE optional
      !VISIBLE type CLIKE optional
      !DATATIMESTAMP type CLIKE optional
      !PRESS type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods NUMERIC_HEADER
    importing
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !VISIBLE type CLIKE optional
      !DATATIMESTAMP type CLIKE optional
      !PRESS type CLIKE optional
      !DETAILS type CLIKE optional
      !DETAILSMAXLINES type CLIKE optional
      !DETAILSSTATE type CLIKE optional
      !ICONALT type CLIKE optional
      !ICONBACKGROUNDCOLOR type CLIKE optional
      !ICONDISPLAYSHAPE type CLIKE optional
      !ICONINITIALS type CLIKE optional
      !ICONSIZE type CLIKE optional
      !ICONSRC type CLIKE optional
      !ICONVISIBLE type CLIKE optional
      !NUMBER type CLIKE optional
      !NUMBERSIZE type CLIKE optional
      !NUMBERVISIBLE type CLIKE optional
      !SCALE type CLIKE optional
      !SIDEINDICATORSALIGNMENT type CLIKE optional
      !STATE type CLIKE optional
      !STATUSTEXT type CLIKE optional
      !STATUSVISIBLE type CLIKE optional
      !SUBTITLE type CLIKE optional
      !SUBTITLEMAXLINES type CLIKE optional
      !TITLE type CLIKE optional
      !TITLEMAXLINES type CLIKE optional
      !TREND type CLIKE optional
      !UNITOFMEASUREMENT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods NUMERIC_SIDE_INDICATOR
    importing
      !ID type CLIKE optional
      !CLASS type CLIKE optional
      !VISIBLE type CLIKE optional
      !NUMBER type CLIKE optional
      !STATE type CLIKE optional
      !TITLE type CLIKE optional
      !UNIT type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods SLIDE_TILE
    importing
      !DISPLAYTIME type CLIKE optional
      !HEIGHT type CLIKE optional
      !VISIBLE type CLIKE optional
      !SCOPE type CLIKE optional
      !SIZEBEHAVIOR type CLIKE optional
      !TRANSITIONTIME type CLIKE optional
      !PRESS type CLIKE optional
      !WIDTH type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods busy_indicator
    importing
      !id type CLIKE optional
      !class type CLIKE optional
      !customicon type CLIKE optional
      !customiconheight type CLIKE optional
      !customiconrotationspeed type CLIKE optional
      !customiconwidth type CLIKE optional
      !size type CLIKE optional
      !text type CLIKE optional
      !textdirection type CLIKE optional
      !customicondensityaware type CLIKE optional
      !visible type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods custom_layout
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods carousel_layout
    importing
      !visiblepagescount type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods facet_filter
    importing
      !id type CLIKE optional
      !class type CLIKE optional
      !livesearch type CLIKE optional
      !showpersonalization type CLIKE optional
      !showpopoverokbutton type CLIKE optional
      !showreset type CLIKE optional
      !showsummarybar type CLIKE optional
      !type type CLIKE optional
      !visible type CLIKE optional
      !confirm type CLIKE optional
      !reset type CLIKE optional
      !lists type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods facet_filter_list
    importing
      !id type CLIKE optional
      !class type CLIKE optional
      !active type CLIKE optional
      !allCount type CLIKE optional
      !backgroundDesign type CLIKE optional
      !dataType type CLIKE optional
      !enableBusyIndicator type CLIKE optional
      !enableCaseInsensitiveSearch type CLIKE optional
      !footerText type CLIKE optional
      !growing type CLIKE optional
      !growingDirection type CLIKE optional
      !growingScrollToLoad type CLIKE optional
      !growingThreshold type CLIKE optional
      !growingTriggerText type CLIKE optional
      !headerLevel type CLIKE optional
      !headerText type CLIKE optional
      !includeItemInSelection type CLIKE optional
      !inset type CLIKE optional
      !key type CLIKE optional
      !keyboardMode type CLIKE optional
      !mode type CLIKE optional
      !modeAnimationOn type CLIKE optional
      !multiSelectMode type CLIKE optional
      !noDataText type CLIKE optional
      !rememberSelections type CLIKE optional
      !retainListSequence type CLIKE optional
      !sequence type CLIKE optional
      !showNoData type CLIKE optional
      !showRemoveFacetIcon type CLIKE optional
      !showSeparators type CLIKE optional
      !showUnread type CLIKE optional
      !sticky type CLIKE optional
      !swipeDirection type CLIKE optional
      !title type CLIKE optional
      !visible type CLIKE optional
      !width type CLIKE optional
      !wordWrap type CLIKE optional
      !listClose type CLIKE optional
      !listOpen type CLIKE optional
      !search type CLIKE optional
      !selectionChange type CLIKE optional
      !delete type CLIKE optional
      !items type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods facet_filter_item
    importing
      !id type CLIKE optional
      !class type CLIKE optional
      !count type CLIKE optional
      !counter type CLIKE optional
      !highlight type CLIKE optional
      !highlightText type CLIKE optional
      !key type CLIKE optional
      !navigated type CLIKE optional
      !selected type CLIKE optional
      !text type CLIKE optional
      !type type CLIKE optional
      !unread type CLIKE optional
      !visible type CLIKE optional
      !press type CLIKE optional
      !detailPress type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods draft_indicator
    importing
      !id type CLIKE optional
      !class type CLIKE optional
      !mindisplaytime type CLIKE optional
      !state type CLIKE optional
      !visible type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods html_map
    importing
      !id type CLIKE optional
      !class type CLIKE optional
      !name type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW.
  methods html_area
    importing
      !id type CLIKE optional
      !shape type CLIKE optional
      !coords type CLIKE optional
      !alt type CLIKE optional
      !target type CLIKE optional
      !href type CLIKE optional
      !onclick type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods html_canvas
    importing
      !id type CLIKE optional
      !width type CLIKE optional
      !height type CLIKE optional
      !style type CLIKE optional
      !class type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  PROTECTED SECTION.
    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mt_prop  TYPE SORTED TABLE OF z2ui5_if_client=>ty_s_name_value with non-UNIQUE key n.

    DATA mt_ns  TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
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


  METHOD action_sheet.
    result = _generic( name = `ActionSheet`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `cancelbuttontext`  v = cancelbuttontext )
                             ( n = `placement`         v = placement )
                             ( n = `showCancelButton`  v = showcancelbutton )
                             ( n = `title`             v = title )
                             ( n = `afterClose`        v = afterclose )
                             ( n = `afterOpen`         v = afteropen )
                             ( n = `beforeClose`       v = beforeclose )
                             ( n = `beforeOpen`        v = beforeopen )
                             ( n = `cancelButtonPress` v = cancelbuttonpress )
                             ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD additional_content.
    result = _generic( `additionalContent` ).
  ENDMETHOD.


  METHOD additional_numbers.
    result = _generic( name = `additionalNumbers` ).
  ENDMETHOD.


  METHOD analytic_map.

    result = _generic( name = `AnalyticMap`
                      ns    = `vbm`
                      t_prop = VALUE #(
                            ( n = `id`  v = id )
                            ( n = `initialPosition`  v = initialposition )
                            ( n = `initialZoom`  v = initialzoom )
                        ) ).

  ENDMETHOD.


  METHOD appointments.
    result = _generic( `appointments` ).
  ENDMETHOD.


  METHOD appointment_items.
    result = _generic( name = `appointmentItems` ).
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showLabel`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showlabel ) )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD avatar.
    result = me.
    _generic( name   = `Avatar`
              t_prop = VALUE #( ( n = `src`         v = src )
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
                                ( n = `showBorder`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showborder ) )
                                ( n = `decorative`       v = z2ui5_cl_util_func=>boolean_abap_2_json( decorative ) )
                                ( n = `enabled`       v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `displaysize` v = displaysize ) ) ).
  ENDMETHOD.


  METHOD axis_time_strategy.
    result = _generic( name = `axisTimeStrategy`
                       ns   = `gantt` ).
  ENDMETHOD.


  METHOD badge_custom_data.
    result = me.
    _generic( name   = `BadgeCustomData`
              t_prop = VALUE #( ( n = `key`      v = key )
                                ( n = `value`    v = value )
                                ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD bar.
    result = _generic( `Bar` ).
  ENDMETHOD.


  METHOD barcode_scanner_button.
    result = _generic( name   = `BarcodeScannerButton`
                       ns     = 'ndc'
                       t_prop = VALUE #(
                           ( n = `id`                              v = id )
                           ( n = `scanSuccess`                           v = scansuccess )
                           ( n = `scanFail`           v = scanfail )
                           ( n = `inputLiveUpdate`                 v = inputliveupdate )
                           ( n = `dialogTitle`                  v = dialogtitle ) ) ).

  ENDMETHOD.


  METHOD bars.
    result = _generic( name = `bars`
                       ns   = `mchart` ).
  ENDMETHOD.


  METHOD base_rectangle.

    result = _generic( name   = `BaseRectangle`
                       ns     = 'gantt'
                       t_prop = VALUE #( ( n = `time`                      v = time )
                                         ( n = `endtime`                   v = endtime )
                                         ( n = `selectable`                v = z2ui5_cl_util_func=>boolean_abap_2_json( selectable ) )
                                         ( n = `selectedFill`              v = selectedfill )
                                         ( n = `fill`                      v = fill )
                                         ( n = `height`                    v = height )
                                         ( n = `title`                     v = title )
                                         ( n = `animationSettings`         v = animationsettings )
                                         ( n = `alignShape`                v = alignshape )
                                         ( n = `color`                     v = color   )
                                         ( n = `fontSize`                  v = fontsize )
                                         ( n = `connectable`               v = z2ui5_cl_util_func=>boolean_abap_2_json( connectable ) )
                                         ( n = `fontFamily`                v = fontfamily )
                                         ( n = `filter`                    v = filter )
                                         ( n = `transform`                 v = transform )
                                         ( n = `countInBirdEye`            v = z2ui5_cl_util_func=>boolean_abap_2_json( countinbirdeye ) )
                                         ( n = `fontWeight`                v = fontweight   )
                                         ( n = `showTitle`                 v = z2ui5_cl_util_func=>boolean_abap_2_json( showtitle ) )
                                         ( n = `selected`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                         ( n = `resizable`                 v = z2ui5_cl_util_func=>boolean_abap_2_json( resizable ) )
                                         ( n = `horizontalTextAlignment`   v = horizontaltextalignment )
                                         ( n = `highlighted`               v = z2ui5_cl_util_func=>boolean_abap_2_json( highlighted ) )
                                         ( n = `highlightable`             v = z2ui5_cl_util_func=>boolean_abap_2_json( highlightable ) ) ) ).
  ENDMETHOD.


  METHOD begin_column_pages.
    " todo, implement method
    result = _generic( name = `beginColumnPages`
                       ns   = `f` ).

  ENDMETHOD.


  METHOD blocks.
    result = _generic( name = `blocks`
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
    _generic( name   = `BulletMicroChart`
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showActualValue`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showactualvalue ) )
                                ( n = `showActualValueInDeltaMode`    v = z2ui5_cl_util_func=>boolean_abap_2_json( savidm ) )
                                ( n = `showDeltaValue`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showdeltavalue ) )
                                ( n = `showTargetValue`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showtargetvalue ) )
                                ( n = `showThresholds`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showthresholds ) )
                                ( n = `showValueMarker`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluemarker ) )
                                ( n = `smallRangeAllowed`    v = z2ui5_cl_util_func=>boolean_abap_2_json( smallrangeallowed ) )
                                ( n = `forecastValue`  v = forecastvalue ) ) ).
  ENDMETHOD.


  METHOD busy_indicator.
    result = _generic( name = `BusyIndicator`
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
                         ( n = `customIconDensityAware`           v = z2ui5_cl_util_func=>boolean_abap_2_json( customicondensityaware ) )
                         ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD button.

    result = me.
    _generic( name   = `Button`
              ns     = ns
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `iconDensityAware` v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) )
                                ( n = `iconFirst` v = z2ui5_cl_util_func=>boolean_abap_2_json( iconfirst ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `id`      v = id )
                                ( n = `width`   v = width )
                                ( n = `tooltip` v = tooltip )
                                ( n = `textDirection` v = textdirection )
                                ( n = `accessibleRole` v = accessiblerole )
                                ( n = `activeIcon` v = activeicon )
                                ( n = `ariaHasPopup` v = ariahaspopup )
                                ( n = `class`   v = class ) ) ).
  ENDMETHOD.


  METHOD buttons.
    result = _generic( `buttons` ).
  ENDMETHOD.


  METHOD calendar_appointment.
    result = _generic( name   = `CalendarAppointment`
                       ns     = `u`
                       t_prop = VALUE #(
                             ( n = `startDate`                 v = startdate )
                             ( n = `endDate`                   v = enddate )
                             ( n = `icon`                      v = icon )
                             ( n = `title`                     v = title )
                             ( n = `text`                      v = text )
                             ( n = `type`                      v = type )
                             ( n = `key`                       v = key )
                             ( n = `tentative`                 v = tentative ) ) ).
  ENDMETHOD.


  METHOD calendar_legend_item.
    result = _generic( name   = `CalendarLegendItem`
                       t_prop = VALUE #(
                           ( n = `text`                   v = text )
                           ( n = `type`                   v = type )
                           ( n = `tooltip`                v = tooltip )
                           ( n = `color`                  v = color ) ) ).

  ENDMETHOD.


  METHOD card.
    result = _generic( name = `Card` ns = `f`
                   t_prop = VALUE #(
                         ( n = `id`  v = id )
                         ( n = `class`  v = class )
                         ( n = `headerPosition`  v = headerposition )
                         ( n = `height`  v = height )
                         ( n = `width`  v = width )
                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD card_header.
    result = _generic( name = `Header` ns = `f`
                   t_prop = VALUE #(
                         ( n = `id`  v = id )
                         ( n = `class`  v = class )
                         ( n = `dataTimestamp`  v = dataTimestamp )
                         ( n = `iconAlt`  v = iconAlt )
                         ( n = `iconBackgroundColor`  v = iconBackgroundColor )
                         ( n = `iconDisplayShape`  v = iconDisplayShape )
                         ( n = `iconInitials`  v = iconInitials )
                         ( n = `iconSize`  v = iconSize )
                         ( n = `iconSrc`  v = iconSrc )
                         ( n = `statusText`  v = statusText )
                         ( n = `statusVisible`  v = statusVisible )
                         ( n = `subtitle`  v = subtitle )
                         ( n = `subtitleMaxLines`  v = subtitleMaxLines )
                         ( n = `title`  v = title )
                         ( n = `press`  v = press )
                         ( n = `titleMaxLines`  v = titleMaxLines )
                         ( n = `iconVisible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( iconVisible ) )
                         ( n = `visible`    v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD carousel.

    result = _generic( name   = `Carousel`
                       t_prop = VALUE #( ( n = `loop`  v = z2ui5_cl_util_func=>boolean_abap_2_json( loop ) )
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
                                         ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
               ) ).

  ENDMETHOD.


  METHOD carousel_layout.
        result = _generic( name = `CarouselLayout`
                       t_prop = VALUE #(
                             ( n = `visiblePagesCount`  v = visiblepagescount )
                           ) ).
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
                                ( n = `activeHandling`  v = z2ui5_cl_util_func=>boolean_abap_2_json( activehandling ) )
                                ( n = `enabled`  v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `displayOnly`  v = z2ui5_cl_util_func=>boolean_abap_2_json( displayonly ) )
                                ( n = `editable`  v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                ( n = `partiallySelected`  v = z2ui5_cl_util_func=>boolean_abap_2_json( partiallyselected ) )
                                ( n = `useEntireWidth`  v = z2ui5_cl_util_func=>boolean_abap_2_json( useentirewidth ) )
                                ( n = `wrapping`  v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
                                ( n = `select`   v = select ) ) ).
  ENDMETHOD.


  METHOD code_editor.
    result = me.
    _generic( name   = `CodeEditor`
              ns     = `editor`
              t_prop = VALUE #( ( n = `value`   v = value )
                                ( n = `type`    v = type )
                                ( n = `editable`   v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                ( n = `height` v = height )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD column.
    result = _generic( name   = `Column`
                       t_prop = VALUE #( ( n = `width` v = width )
                                         ( n = `minScreenWidth` v = minscreenwidth )
                                         ( n = `hAlign` v = halign )
                                         ( n = `autoPopinWidth` v = autopopinwidth )
                                         ( n = `vAlign` v = valign )
                                         ( n = `importance` v = importance )
                                         ( n = `mergeFunctionName` v = mergefunctionname )
                                         ( n = `popinDisplay` v = popindisplay )
                                         ( n = `sortIndicator` v = sortindicator )
                                         ( n = `styleClass` v = styleclass )
                                         ( n = `id`         v = id )
                                         ( n = `class`         v = class )
                                         ( n = `mergeDuplicates` v = z2ui5_cl_util_func=>boolean_abap_2_json( mergeduplicates ) )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `demandPopin` v = z2ui5_cl_util_func=>boolean_abap_2_json( demandpopin ) ) ) ).
  ENDMETHOD.


  METHOD columns.
    result = _generic( `columns` ).
  ENDMETHOD.


  METHOD column_element_data.
    result =  _generic( name   = `ColumnElementData` ns = `form`
                        t_prop = VALUE #( ( n = `cellsLarge` v = cellslarge )
                                          ( n = `cellsSmall` v = cellssmall ) ) ).
  ENDMETHOD.


  METHOD column_list_item.
    result = _generic( name   = `ColumnListItem`
                       t_prop = VALUE #( ( n = `vAlign`   v = valign )
                                         ( n = `selected` v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                         ( n = `unread` v = z2ui5_cl_util_func=>boolean_abap_2_json( unread ) )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `type`     v = type )
                                         ( n = `counter`     v = counter )
                                         ( n = `highlight`     v = highlight )
                                         ( n = `highlightText`     v = highlighttext )
                                         ( n = `detailPress`     v = detailpress )
                                         ( n = `navigated`     v = z2ui5_cl_util_func=>boolean_abap_2_json( navigated ) )
                                         ( n = `press`    v = press ) ) ).
  ENDMETHOD.


  METHOD column_micro_chart.
    result = me.
    _generic( name   = `ColumnMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `width`  v = width )
                                ( n = `press`       v = press )
                                ( n = `size`        v = size )
                                ( n = `alignContent`      v = aligncontent )
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `allowColumnLabels`    v = z2ui5_cl_util_func=>boolean_abap_2_json( allowcolumnlabels ) )
                                ( n = `showBottomLabels`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showbottomlabels ) )
                                ( n = `showTopLabels`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showtoplabels ) )
                                ( n = `height`  v = height ) ) ).
  ENDMETHOD.


  METHOD combobox.
    result = _generic( name   = `ComboBox`
                       t_prop = VALUE #( (  n = `showClearIcon` v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearicon ) )
                                         (  n = `selectedKey`   v = selectedkey )
                                         (  n = `items`         v = items )
                                         (  n = `id`         v = id )
                                         (  n = `class`         v = class )
                                         (  n = `selectionchange`         v = selectionchange )
                                         (  n = `selectedItem`         v = selecteditem )
                                         (  n = `selectedItemId`         v = selecteditemid )
                                         (  n = `name`         v = name )
                                         (  n = `value`         v = value )
                                         (  n = `valueState`         v = valuestate )
                                         (  n = `valueStateText`         v = valuestatetext )
                                         (  n = `textAlign`         v = textalign )
                                         (  n = `showSecondaryValues`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showsecondaryvalues ) )
                                         (  n = `visible`         v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         (  n = `showValueStateMessage`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluestatemessage ) )
                                         (  n = `showButton`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showbutton ) )
                                         (  n = `required`         v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                         (  n = `editable`         v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                         (  n = `enabled`         v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         (  n = `filterSecondaryValues`         v = z2ui5_cl_util_func=>boolean_abap_2_json( filtersecondaryvalues ) )
                                         (  n = `width`         v = width )
                                         (  n = `placeholder`         v = placeholder )
                                         (  n = `change`        v = change ) ) ).

  ENDMETHOD.


  METHOD comparison_micro_chart.
    result = me.
    _generic( name   = `ComparisonMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `colorPalette`  v = colorpalette )
                                ( n = `press`       v = press )
                                ( n = `size`        v = size )
                                ( n = `height`      v = height )
                                ( n = `maxValue`      v = maxvalue )
                                ( n = `minValue`      v = minvalue )
                                ( n = `scale`      v = scale )
                                ( n = `width`      v = width )
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `shrinkable`    v = z2ui5_cl_util_func=>boolean_abap_2_json( shrinkable ) )
                                ( n = `view`  v = view ) ) ).
  ENDMETHOD.


  METHOD constructor.

*    mt_prop = VALUE #( ( n = `xmlns`           v = `sap.m` )
*                       ( n = `xmlns:z2ui5`     v = `z2ui5` )
*                       ( n = `xmlns:core`      v = `sap.ui.core` )
*                       ( n = `xmlns:mvc`       v = `sap.ui.core.mvc` )
*                       ( n = `xmlns:layout`    v = `sap.ui.layout` )
**                       ( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` )
**                       ( n = `core:require` v = `{ URLHelper: 'sap/m/library/URLHelper' }` )
*                       ( n = `xmlns:table `    v = `sap.ui.table` )
*                       ( n = `xmlns:f`         v = `sap.f` )
*                       ( n = `xmlns:form`      v = `sap.ui.layout.form` )
*                       ( n = `xmlns:editor`    v = `sap.ui.codeeditor` )
*                       ( n = `xmlns:mchart`    v = `sap.suite.ui.microchart` )
*                       ( n = `xmlns:webc`      v = `sap.ui.webc.main` )
*                       ( n = `xmlns:uxap`      v = `sap.uxap` )
*                       ( n = `xmlns:sap`       v = `sap` )
*                       ( n = `xmlns:text`      v = `sap.ui.richtexteditor` )
*                       ( n = `xmlns:html`      v = `http://www.w3.org/1999/xhtml` )
*                       ( n = `xmlns:fb`        v = `sap.ui.comp.filterbar` )
*                       ( n = `xmlns:u`         v = `sap.ui.unified` )
*                       ( n = `xmlns:gantt`     v = `sap.gantt.simple` )
*                       ( n = `xmlns:axistime`  v = `sap.gantt.axistime` )
*                       ( n = `xmlns:config`    v = `sap.gantt.config` )
*                       ( n = `xmlns:shapes`    v = `sap.gantt.simple.shapes` )
*                       ( n = `xmlns:commons`   v = `sap.suite.ui.commons` )
*                       ( n = `xmlns:vm`        v = `sap.ui.comp.variants` )
*                       ( n = `xmlns:viz`        v = `sap.viz.ui5.controls` )
*                       ( n = `xmlns:vk`        v = `sap.ui.vk` )
*                       ( n = `xmlns:vbm`        v = `sap.ui.vbm` )
*                       ( n = `xmlns:ndc`        v = `sap.ndc` )
*                       ( n = `xmlns:svm`       v = `sap.ui.comp.smartvariants` )
*                       ( n = `xmlns:flvm`      v = `sap.ui.fl.variants` )
*                       ( n = `xmlns:p13n`      v = `sap.m.p13n` )
*                       ( n = `xmlns:upload`    v = `sap.m.upload` )
*                       ( n = `xmlns:fl`        v = `sap.ui.fl` )
*                       ( n = `xmlns:tnt `      v = `sap.tnt` ) ).
  ENDMETHOD.


  METHOD container_content.

    result = _generic( name = `ContainerContent`
                      ns    = `vk`
                      t_prop = VALUE #(
                            ( n = `id`  v = id )
                            ( n = `title`  v = title )
                            ( n = `icon`  v = icon )
                        ) ).

  ENDMETHOD.


  METHOD container_toolbar.

    result = _generic( name   = `ContainerToolbar`
                       ns     = `gantt`
                       t_prop = VALUE #( ( n = `showSearchButton`          v = showsearchbutton )
                                         ( n = `alignCustomContentToRight` v = z2ui5_cl_util_func=>boolean_abap_2_json( aligncustomcontenttoright ) )
                                         ( n = `findMode`                  v = findmode )
                                         ( n = `infoOfSelectItems`         v = infoofselectitems )
                                         ( n = `showBirdEyeButton`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showbirdeyebutton ) )
                                         ( n = `showDisplayTypeButton`     v = z2ui5_cl_util_func=>boolean_abap_2_json( showdisplaytypebutton ) )
                                         ( n = `showLegendButton`          v = z2ui5_cl_util_func=>boolean_abap_2_json( showlegendbutton ) )
                                         ( n = `showSettingButton`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showsettingbutton ) )
                                         ( n = `showTimeZoomControl`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showtimezoomcontrol ) )
                                         ( n = `stepCountOfSlider`         v = stepcountofslider )
                                         ( n = `zoomControlType`           v = zoomcontroltype )
                                         ( n = `zoomLevel`                 v = zoomlevel )
                                       ) ).
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


  METHOD currency.
    result = _generic( name = `Currency`
                       ns   = 'u'
                    t_prop  = VALUE #(
                          ( n = `value` v = value )
                          ( n = `currency`  v = currency ) ) ).

  ENDMETHOD.


  METHOD custom_data.
    result = _generic( `customData` ).
  ENDMETHOD.


  METHOD custom_header.
    result = _generic( `customHeader` ).
  ENDMETHOD.


  METHOD custom_layout.
    result = _generic( name = `customLayout` ).
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
              t_prop = VALUE #( ( n = `value`                 v = value )
                                ( n = `displayFormat`         v = displayformat )
                                ( n = `displayFormatType`         v = displayFormatType )
                                ( n = `valueFormat`           v = valueformat )
                                ( n = `required`              v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                ( n = `valueState`            v = valuestate )
                                ( n = `valueStateText`        v = valuestatetext )
                                ( n = `placeholder`           v = placeholder )
                                ( n = `textAlign`                v = textAlign )
                                ( n = `textDirection`                v = textDirection )
                                ( n = `change`                v = change )
                                ( n = `maxDate`               v = maxdate )
                                ( n = `minDate`               v = mindate )
                                ( n = `width`               v = width )
                                ( n = `id`               v = id )
                                ( n = `dateValue`               v = dateValue )
                                ( n = `name`               v = name )
                                ( n = `class`               v = class )
                                ( n = `calendarWeekNumbering`               v = calendarweeknumbering )
                                ( n = `initialFocusedDateValue`               v = initialFocusedDateValue )
                                ( n = `enabled`               v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`               v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `editable`              v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                ( n = `hideInput`             v = z2ui5_cl_util_func=>boolean_abap_2_json( hideinput ) )
                                ( n = `showFooter`            v = z2ui5_cl_util_func=>boolean_abap_2_json( showfooter ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluestatemessage ) )
                                ( n = `showCurrentDateButton` v = z2ui5_cl_util_func=>boolean_abap_2_json( showcurrentdatebutton ) ) ) ).
  ENDMETHOD.


  METHOD date_time_picker.
    result = me.
    _generic( name   = `DateTimePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder`  v = placeholder )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
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
    result = _generic( name = `detailPages` ).
  ENDMETHOD.


  METHOD dialog.

    result = _generic( name   = `Dialog`
                       t_prop = VALUE #( ( n = `title`  v = title )
                                         ( n = `icon`  v = icon )
                                         ( n = `stretch`  v = stretch )
                                         ( n = `showHeader`  v = showheader )
                                         ( n = `contentWidth`  v = contentwidth )
                                         ( n = `contentHeight`  v = contentheight )
                                         ( n = `resizable`  v = z2ui5_cl_util_func=>boolean_abap_2_json( resizable ) )
                                         ( n = `horizontalScrolling`  v = z2ui5_cl_util_func=>boolean_abap_2_json( horizontalscrolling ) )
                                         ( n = `verticalScrolling`  v = z2ui5_cl_util_func=>boolean_abap_2_json( verticalscrolling ) )
                                         ( n = `afterClose` v = afterclose ) ) ).

  ENDMETHOD.


  METHOD draft_indicator.
    result = _generic( name = `DraftIndicator`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `minDisplayTime`  v = minDisplayTime )
                             ( n = `state`  v = state )
                             ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD dynamic_page.
    result = _generic( name   = `DynamicPage`
                       ns     = `f`
                       t_prop = VALUE #(
                           (  n = `headerExpanded`           v = z2ui5_cl_util_func=>boolean_abap_2_json( headerexpanded ) )
                           (  n = `headerPinned`           v = z2ui5_cl_util_func=>boolean_abap_2_json( headerpinned ) )
                           (  n = `showFooter`           v = z2ui5_cl_util_func=>boolean_abap_2_json( showfooter ) )
                           (  n = `toggleHeaderOnTitleClick` v = toggleheaderontitleclick ) ) ).
  ENDMETHOD.


  METHOD dynamic_page_header.
    result = _generic(
                 name   = `DynamicPageHeader`
                 ns     = `f`
                 t_prop = VALUE #( (  n = `pinnable`           v = z2ui5_cl_util_func=>boolean_abap_2_json( pinnable ) ) ) ).
  ENDMETHOD.


  METHOD dynamic_page_title.
    result = _generic( name = `DynamicPageTitle`
                       ns   = `f` ).
  ENDMETHOD.


  METHOD dynamic_side_content.
    result = _generic( name   = `DynamicSideContent`
                       ns     = 'layout'
                       t_prop = VALUE #(
                           ( n = `id`                              v = id )
                           ( n = `class`                           v = class )
                           ( n = `sideContentVisibility`           v = sidecontentvisibility )
                           ( n = `showSideContent`                 v = showsidecontent )
                           ( n = `containerQuery`                  v = containerquery ) ) ).

  ENDMETHOD.


  METHOD embedded_control.
    result = _generic( name = `embeddedControl`
                       ns   = `commons` ).
  ENDMETHOD.


  METHOD end_column_pages.
    " todo, implement method
    result = me.
  ENDMETHOD.


  METHOD expandable_text.
    result = _generic( name = `ExpandableText`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `emptyIndicatorMode`  v = emptyindicatormode )
                             ( n = `maxCharacters`         v = maxcharacters )
                             ( n = `overflowMode`  v = overflowmode )
                             ( n = `renderWhitespace`             v = z2ui5_cl_util_func=>boolean_abap_2_json( renderwhitespace ) )
                             ( n = `text`        v = text )
                             ( n = `textAlign`         v = textalign )
                             ( n = `textDirection`       v = textdirection )
                             ( n = `wrappingType` v = wrappingtype )
                             ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
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
    result = _generic( name = `FacetFilter`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `liveSearch`  v = z2ui5_cl_util_func=>boolean_abap_2_json( livesearch ) )
                             ( n = `showPersonalization` v = z2ui5_cl_util_func=>boolean_abap_2_json( showpersonalization ) )
                             ( n = `showPopoverOKButton`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showpopoverokbutton ) )
                             ( n = `showReset`             v = z2ui5_cl_util_func=>boolean_abap_2_json( showreset ) )
                             ( n = `showSummaryBar`        v = z2ui5_cl_util_func=>boolean_abap_2_json( showsummarybar ) )
                             ( n = `type`         v = type )
                             ( n = `confirm`        v = confirm )
                             ( n = `reset` v = reset )
                             ( n = `lists` v = lists )
                             ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD facet_filter_item.
    result = _generic( name = `FacetFilterItem`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `count`  v = count )
                             ( n = `counter` v = counter )
                             ( n = `highlight`  v = highlight )
                             ( n = `highlightText` v = highlightText )
                             ( n = `key`        v = key )
                             ( n = `navigated`  v = z2ui5_cl_util_func=>boolean_abap_2_json( navigated ) )
                             ( n = `selected`  v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                             ( n = `unread`   v = z2ui5_cl_util_func=>boolean_abap_2_json( unread ) )
                             ( n = `text`       v = text )
                             ( n = `type`        v = type )
                             ( n = `detailPress` v = detailPress )
                             ( n = `press` v = press )
                             ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD facet_filter_list.
    result = _generic( name = `FacetFilterList`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `active`  v = z2ui5_cl_util_func=>boolean_abap_2_json( active ) )
                             ( n = `allCount`  v = allCount )
                             ( n = `backgroundDesign`         v = backgroundDesign )
                             ( n = `dataType`  v = dataType )
                             ( n = `enableBusyIndicator` v = z2ui5_cl_util_func=>boolean_abap_2_json( enableBusyIndicator ) )
                             ( n = `enableCaseInsensitiveSearch` v = z2ui5_cl_util_func=>boolean_abap_2_json( enableCaseInsensitiveSearch ) )
                             ( n = `footerText`         v = footerText )
                             ( n = `growing`       v = z2ui5_cl_util_func=>boolean_abap_2_json( growing ) )
                             ( n = `growingDirection`        v = growingDirection )
                             ( n = `growingScrollToLoad` v = z2ui5_cl_util_func=>boolean_abap_2_json( growingScrollToLoad ) )
                             ( n = `growingThreshold` v = growingThreshold )
                             ( n = `growingTriggerText` v = growingTriggerText )
                             ( n = `headerLevel` v = headerLevel )
                             ( n = `includeItemInSelection` v = z2ui5_cl_util_func=>boolean_abap_2_json( includeItemInSelection ) )
                             ( n = `inset` v = z2ui5_cl_util_func=>boolean_abap_2_json( inset ) )
                             ( n = `key` v = key )
                             ( n = `swipedirection` v = swipedirection )
                             ( n = `headerText` v = headerText )
                             ( n = `keyboardMode` v = keyboardMode )
                             ( n = `mode` v = mode )
                             ( n = `modeAnimationOn` v = z2ui5_cl_util_func=>boolean_abap_2_json( modeAnimationOn ) )
                             ( n = `multiSelectMode` v = multiSelectMode )
                             ( n = `noDataText` v = noDataText )
                             ( n = `rememberSelections` v = z2ui5_cl_util_func=>boolean_abap_2_json( rememberSelections ) )
                             ( n = `retainListSequence` v = z2ui5_cl_util_func=>boolean_abap_2_json( retainListSequence ) )
                             ( n = `sequence` v = sequence )
                             ( n = `showNoData` v = z2ui5_cl_util_func=>boolean_abap_2_json( showNoData ) )
                             ( n = `showRemoveFacetIcon` v = z2ui5_cl_util_func=>boolean_abap_2_json( showRemoveFacetIcon ) )
                             ( n = `showSeparators` v = showSeparators )
                             ( n = `showUnread` v = z2ui5_cl_util_func=>boolean_abap_2_json( showUnread ) )
                             ( n = `sticky` v = sticky )
                             ( n = `title` v = title )
                             ( n = `width` v = width )
                             ( n = `wordWrap` v = z2ui5_cl_util_func=>boolean_abap_2_json( wordWrap ) )
                             ( n = `listClose` v = listClose )
                             ( n = `listOpen` v = listOpen )
                             ( n = `search` v = search )
                             ( n = `selectionChange` v = selectionChange )
                             ( n = `delete` v = delete )
                             ( n = `items` v = items )
                             ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mi_client = client.
    result->mt_prop  = VALUE #( BASE result->mt_prop
                                (  n = 'displayBlock'   v = 'true' )
                                (  n = 'height'         v = '100%' ) ).

    result->mv_name   = `View`.
    result->mv_ns     = `mvc`.
    result->mo_root   = result.
    result->mo_parent = result.

    INSERT VALUE #( n = `xmlns`           v = `sap.m` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:mvc`       v = `sap.ui.core.mvc` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:core`       v = `sap.ui.core` ) INTO TABLE result->mt_prop.

  ENDMETHOD.


METHOD factory_plain.

    result = NEW #( ).

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

    INSERT VALUE #( n = `xmlns`           v = `sap.m` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:core`       v = `sap.ui.core` ) INTO TABLE result->mt_prop.

  ENDMETHOD.


  METHOD fb_control.
    result = _generic( name = `control`
                       ns   = `fb` ).
  ENDMETHOD.


  METHOD feed_input.
    result = _generic( name   = `FeedInput`
                       t_prop = VALUE #( ( n = `buttonTooltip`    v = buttontooltip )
                                         ( n = `enabled`          v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `growing`          v = z2ui5_cl_util_func=>boolean_abap_2_json( growing ) )
                                         ( n = `growingMaxLines`  v = growingmaxlines )
                                         ( n = `icon`             v = icon )
                                         ( n = `iconDensityAware` v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `iconDisplayShape` v = icondisplayshape )
                                         ( n = `iconInitials`     v = iconinitials )
                                         ( n = `iconSize`         v = iconsize )
                                         ( n = `maxLength`        v = maxlength )
                                         ( n = `placeholder`      v = placeholder )
                                         ( n = `rows`             v = rows )
                                         ( n = `showExceededText` v = z2ui5_cl_util_func=>boolean_abap_2_json( showexceededtext ) )
                                         ( n = `showIcon`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showicon ) )
                                         ( n = `value`            v = value )
                                         ( n = `class`            v = class )
                                         ( n = `post`             v = post ) ) ).

  ENDMETHOD.


  METHOD feed_list_item.
    result = _generic( name   = `FeedListItem`
                       t_prop = VALUE #( ( n = `activeIcon`                  v = activeicon )
                                         ( n = `convertedLinksDefaultTarget` v = convertedlinksdefaulttarget )
                                         ( n = `convertLinksToAnchorTags`    v = convertlinkstoanchortags )
                                         ( n = `iconActive`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( iconactive ) )
                                         ( n = `icon`                        v = icon )
                                         ( n = `iconDensityAware`            v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `iconDisplayShape`            v = icondisplayshape )
                                         ( n = `iconInitials`                v = iconinitials )
                                         ( n = `iconSize`                    v = iconsize )
                                         ( n = `info`                        v = info )
                                         ( n = `lessLabel`                   v = lesslabel )
                                         ( n = `maxCharacters`               v = maxcharacters )
                                         ( n = `moreLabel`                   v = morelabel )
                                         ( n = `sender`                      v = sender )
                                         ( n = `senderActive`                v = z2ui5_cl_util_func=>boolean_abap_2_json( senderactive ) )
                                         ( n = `showIcon`                    v = z2ui5_cl_util_func=>boolean_abap_2_json( showicon ) )
                                         ( n = `text`                        v = text )
                                         ( n = `senderPress`                 v = senderpress )
                                         ( n = `iconPress`                   v = iconpress )
                                         ( n = `timestamp`                   v = timestamp ) ) ).
  ENDMETHOD.


  METHOD feed_list_item_action.
    result =  _generic( name   = `FeedListItemAction`
                        t_prop = VALUE #( ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                          ( n = `icon`    v = icon )
                                          ( n = `key`     v = key )
                                          ( n = `text`    v = text )
                                          ( n = `press`   v = press )
                                          ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD filter_bar.

    result = _generic( name   = `FilterBar`
                       ns     = 'fb'
                       t_prop = VALUE #( ( n = 'useToolbar'     v = z2ui5_cl_util_func=>boolean_abap_2_json( usetoolbar ) )
                                         ( n = 'search'         v = search )
                                         ( n = 'id'             v = id )
                                         ( n = 'persistencyKey' v = persistencykey )
                                         ( n = 'afterVariantLoad' v = aftervariantload )
                                         ( n = 'afterVariantSave' v = aftervariantsave )
                                         ( n = 'assignedFiltersChanged' v = assignedfilterschanged )
                                         ( n = 'beforeVariantFetch' v = beforevariantfetch )
                                         ( n = 'cancel' v = cancel )
                                         ( n = 'clear' v = clear )
                                         ( n = 'filtersDialogBeforeOpen' v = filtersdialogbeforeopen )
                                         ( n = 'filtersDialogCancel' v = filtersdialogcancel )
                                         ( n = 'filtersDialogClosed' v = filtersdialogclosed )
                                         ( n = 'initialise' v = initialise )
                                         ( n = 'initialized' v = initialized )
                                         ( n = 'reset' v = reset )
                                         ( n = 'filterContainerWidth' v = filtercontainerwidth )
                                         ( n = 'header' v = header )
                                         ( n = 'advancedMode' v = z2ui5_cl_util_func=>boolean_abap_2_json( advancedmode ) )
                                         ( n = 'isRunningInValueHelpDialog' v = z2ui5_cl_util_func=>boolean_abap_2_json( isrunninginvaluehelpdialog ) )
                                         ( n = 'showAllFilters' v = z2ui5_cl_util_func=>boolean_abap_2_json( showallfilters ) )
                                         ( n = 'showClearOnFB' v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearonfb ) )
                                         ( n = 'showFilterConfiguration' v = z2ui5_cl_util_func=>boolean_abap_2_json( showfilterconfiguration ) )
                                         ( n = 'showGoOnFB' v = z2ui5_cl_util_func=>boolean_abap_2_json( showgoonfb ) )
                                         ( n = 'showRestoreButton' v = z2ui5_cl_util_func=>boolean_abap_2_json( showrestorebutton ) )
                                         ( n = 'showRestoreOnFB' v = z2ui5_cl_util_func=>boolean_abap_2_json( showrestoreonfb ) )
                                         ( n = 'useSnapshot' v = z2ui5_cl_util_func=>boolean_abap_2_json( usesnapshot ) )
                                         ( n = 'searchEnabled' v = z2ui5_cl_util_func=>boolean_abap_2_json( searchenabled ) )
                                         ( n = 'considerGroupTitle' v = z2ui5_cl_util_func=>boolean_abap_2_json( considergrouptitle ) )
                                         ( n = 'deltaVariantMode' v = z2ui5_cl_util_func=>boolean_abap_2_json( deltavariantmode ) )
                                         ( n = 'disableSearchMatchesPatternWarning' v = z2ui5_cl_util_func=>boolean_abap_2_json( disablesearchmatchespatternw ) )
                                         ( n = 'filterBarExpanded' v = z2ui5_cl_util_func=>boolean_abap_2_json( filterbarexpanded ) )
                                         ( n = 'filterChange'   v = filterchange ) ) ).
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


  METHOD filter_items.
    result = _generic( name = `filterItems` ).
  ENDMETHOD.


  METHOD first_status.
    result = _generic( name = `firstStatus` ).
  ENDMETHOD.


  METHOD flexible_column_layout.

    result = _generic( name   = `FlexibleColumnLayout`
                       ns     = `f`
                       t_prop = VALUE #(
                        (  n = `layout` v = layout )
                        (  n = `id` v = id )
                        (  n = `class` v = class )
                        (  n = `afterBeginColumnNavigate` v = afterBeginColumnNavigate )
                        (  n = `afterEndColumnNavigate` v = afterEndColumnNavigate )
                        (  n = `afterMidColumnNavigate` v = afterMidColumnNavigate )
                        (  n = `beginColumnNavigate` v = beginColumnNavigate )
                        (  n = `columnResize` v = columnResize )
                        (  n = `endColumnNavigate` v = endColumnNavigate )
                        (  n = `midColumnNavigate` v = midColumnNavigate )
                        (  n = `stateChange` v = stateChange )
                        (  n = `backgroundDesign` v = backgroundDesign )
                        (  n = `defaultTransitionNameBeginColumn` v = defaultTransitionNameBeginCol )
                        (  n = `defaultTransitionNameEndColumn` v = defaultTransitionNameEndCol )
                        (  n = `defaultTransitionNameMidColumn` v = defaultTransitionNameMidCol )
                        (  n = `autoFocus` v = z2ui5_cl_util_func=>boolean_abap_2_json( autoFocus ) )
                        (  n = `restoreFocusOnBackNavigation` v = z2ui5_cl_util_func=>boolean_abap_2_json( restoreFocusOnBackNavigation ) )
                        ) ).

  ENDMETHOD.


  METHOD flex_box.
    result = _generic( name   = `FlexBox`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `renderType`  v = rendertype )
                                         ( n = `width`  v = width )
                                         ( n = `height`  v = height )
                                         ( n = `alignItems`  v = alignitems )
                                         ( n = `fitContainer`  v = z2ui5_cl_util_func=>boolean_abap_2_json( fitcontainer ) )
                                         ( n = `justifyContent`  v = justifycontent )
                                         ( n = `wrap`  v = wrap )
                                         ( n = `direction`  v = direction )
                                         ( n = `alignContent`  v = aligncontent )
                                         ( n = `backgroundDesign`  v = backgrounddesign )
                                         ( n = `displayInline`  v = z2ui5_cl_util_func=>boolean_abap_2_json( displayinline ) )
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
              t_prop = VALUE #( ( n = `htmlText` v = htmltext )
                                ( n = `convertedLinksDefaultTarget` v = convertedlinksdefaulttarget )
                                ( n = `convertLinksToAnchorTags` v = convertlinkstoanchortags )
                                ( n = `height` v = height )
                                ( n = `textAlign` v = textalign )
                                ( n = `textDirection` v = textdirection )
                                ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `width` v = width )
                                ( n = `class` v = class )
                                ( n = `id` v = id )
                                ( n = `controls` v = controls )
                              ) ).
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
    result = _generic( name = `table`
                       ns   = `gantt` ).
  ENDMETHOD.


  METHOD gantt_toolbar.
    result = _generic( name = `toolbar`
                       ns   = 'gantt' ).
  ENDMETHOD.


  METHOD generic_tag.

    result = _generic( name   = `GenericTag`
                       t_prop = VALUE #( ( n = `ariaLabelledBy`           v = arialabelledby )
                                         ( n = `class`        v = class )
                                         ( n = `design`          v = design )
                                         ( n = `status`  v = status )
                                         ( n = `id`  v = id )
                                         ( n = `press`  v = press )
                                         ( n = `text`   v = text ) ) ).

  ENDMETHOD.


  METHOD generic_tile.

    result = me.
    _generic(
      name   = `GenericTile`
      ns     = ``
      t_prop = VALUE #(
                ( n = `class`      v = class )
                ( n = `id`     v = id )
                ( n = `header`     v = header )
                ( n = `mode`     v = mode )
                ( n = `additionalTooltip`     v = additionalTooltip )
                ( n = `appShortcut`     v = appShortcut )
                ( n = `backgroundColor`     v = backgroundColor )
                ( n = `backgroundImage`     v = backgroundImage )
                ( n = `dropAreaOffset`     v = dropAreaOffset )
                ( n = `press`      v = press )
                ( n = `frameType`  v = frametype )
                ( n = `failedText`  v = failedText )
                ( n = `headerImage`  v = headerImage )
                ( n = `scope`  v = scope )
                ( n = `sizeBehavior`  v = sizeBehavior )
                ( n = `state`  v = state )
                ( n = `systemInfo`  v = systemInfo )
                ( n = `tileBadge`  v = tileBadge )
                ( n = `tileIcon`  v = tileIcon )
                ( n = `url`  v = url )
                ( n = `valueColor`  v = valueColor )
                ( n = `width`  v = width )
                ( n = `wrappingType`  v = wrappingType )
                ( n = `imageDescription`  v = imageDescription )
                ( n = `navigationButtonText`  v = navigationButtonText )
                ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                ( n = `renderOnThemeChange`  v = z2ui5_cl_util_func=>boolean_abap_2_json( renderOnThemeChange ) )
                ( n = `enableNavigationButton`  v = z2ui5_cl_util_func=>boolean_abap_2_json( enableNavigationButton ) )
                ( n = `pressEnabled`  v = z2ui5_cl_util_func=>boolean_abap_2_json( pressEnabled ) )
                ( n = `iconLoaded`  v = z2ui5_cl_util_func=>boolean_abap_2_json( iconLoaded ) )
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


  METHOD group_items.
    result = _generic( name = `groupItems` ).
  ENDMETHOD.


  METHOD harvey_ball_micro_chart.
    result = me.
    _generic( name   = `HarveyBallMicroChart`
              ns     = `mchart`
              t_prop = VALUE #( ( n = `colorPalette`  v = colorpalette )
                                ( n = `press`       v = press )
                                ( n = `size`        v = size )
                                ( n = `height`      v = height )
                                ( n = `width`      v = width )
                                ( n = `total`      v = total )
                                ( n = `totalLabel`      v = totallabel )
                                ( n = `alignContent`      v = aligncontent )
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `formattedLabel`    v = z2ui5_cl_util_func=>boolean_abap_2_json( formattedlabel ) )
                                ( n = `showFractions`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showfractions ) )
                                ( n = `showTotal`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showtotal ) )
                                ( n = `totalScale`  v = totalscale ) ) ).
  ENDMETHOD.


  METHOD hbox.
    result = _generic( name   = `HBox`
                       t_prop = VALUE #( ( n = `class`          v = class )
                                         ( n = `alignContent`   v = aligncontent )
                                         ( n = `alignItems`     v = alignitems )
                                         ( n = `width`          v = width )
                                         ( n = `id`          v = id )
                                         ( n = `renderType`          v = rendertype )
                                         ( n = `height`         v = height )
                                         ( n = `wrap`           v = wrap )
                                         ( n = `backgroundDesign`           v = backgroundDesign )
                                         ( n = `direction`           v = direction )
                                         ( n = `displayInline`           v = z2ui5_cl_util_func=>boolean_abap_2_json( displayInline ) )
                                         ( n = `fitContainer`           v = z2ui5_cl_util_func=>boolean_abap_2_json( fitContainer ) )
                                         ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `justifyContent` v = justifycontent ) ) ).

  ENDMETHOD.


  METHOD header.
    result = _generic( name = `header`
                       ns   = ns ).
  ENDMETHOD.


  METHOD header_container.
    result = _generic( name = `headerContainer` ).
  ENDMETHOD.


  METHOD header_container_control.
    result = _generic( name = `HeaderContainer`
                       t_prop = VALUE #( ( n = `backgroundDesign` v = backgroundDesign )
                                         ( n = `gridLayout` v = z2ui5_cl_util_func=>boolean_abap_2_json( gridLayout ) )
                                         ( n = `height` v = height )
                                         ( n = `orientation` v = orientation )
                                         ( n = `scrollStep` v = scrollStep )
                                         ( n = `scrollStepByItem` v = scrollStepByItem )
                                         ( n = `scrollTime` v = scrollTime )
                                         ( n = `showDividers` v = z2ui5_cl_util_func=>boolean_abap_2_json( showDividers ) )
                                         ( n = `showOverflowItem` v = z2ui5_cl_util_func=>boolean_abap_2_json( showOverflowItem ) )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `width` v = width )
                                         ( n = `id` v = id )
                                         ( n = `scroll` v = scroll )
) ).
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
    result = _generic( name   = `HorizontalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `allowWrapping`  v = z2ui5_cl_util_func=>boolean_abap_2_json( allowWrapping ) )
                                         ( n = `id`  v = id )
                                         ( n = `visible`  v = visible ) ) ).
  ENDMETHOD.


  METHOD html.

    result = _generic( name = `HTML`
                       ns   = `core`
                       t_prop = VALUE  #(
                          ( n = 'id' v = id )
                          ( n = 'content' v = content )
                          ( n = 'afterRendering' v = afterrendering )
                          ( n = 'preferDOM' v = z2ui5_cl_util_func=>boolean_abap_2_json( preferdom ) )
                          ( n = 'sanitizeContent' v = z2ui5_cl_util_func=>boolean_abap_2_json( sanitizecontent ) )
                          ( n = 'visible' v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                          ) ).

  ENDMETHOD.


    METHOD html_area.
    result = _generic( name = `area` ns = 'html'
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `shape`  v = shape )
                             ( n = `coords`  v = coords )
                             ( n = `alt`     v = alt )
                             ( n = `target` v = target )
                             ( n = `href`  v = href )
                             ( n = `onclick`  v = onclick )
                         ) ).
  ENDMETHOD.


METHOD html_canvas.
  result = _generic( name = `canvas`
                     ns = `html`
                     t_prop = VALUE #(
                           ( n = `id`     v = id )
                           ( n = `class`  v = class )
                           ( n = `width`  v = width )
                           ( n = `height` v = height )
                           ( n = `style`  v = style )
                       ) ).
ENDMETHOD.


  METHOD html_map.
    result = _generic( name = `map` ns = 'html'
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `name`  v = name )
                         ) ).
  ENDMETHOD.


  METHOD icon.

    result = me.
    _generic( name   = `Icon`
              ns     = `core`
              t_prop = VALUE #( ( n = `size`  v = size )
                                ( n = `color`  v = color )
                                ( n = `class`  v = class )
                                ( n = `src`  v = src )
                                ( n = `activeColor`  v = activeColor )
                                ( n = `activeBackgroundColor`  v = activeBackgroundColor )
                                ( n = `alt`  v = alt )
                                ( n = `backgroundColor`  v = backgroundColor )
                                ( n = `height`  v = height )
                                ( n = `width`  v = width )
                                ( n = `id`  v = id )
                                ( n = `press`  v = press )
                                ( n = `hoverBackgroundColor`  v = hoverBackgroundColor )
                                ( n = `hoverColor`  v = hoverColor )
                                ( n = `decorative`  v = z2ui5_cl_util_func=>boolean_abap_2_json( decorative ) )
                                ( n = `noTabStop`  v = z2ui5_cl_util_func=>boolean_abap_2_json( noTabStop ) )
                                ( n = `useIconTooltip`  v = z2ui5_cl_util_func=>boolean_abap_2_json( useIconTooltip ) )
                             ) ).

  ENDMETHOD.


  METHOD icon_tab_bar.

    result = _generic( name   = `IconTabBar`
                       t_prop = VALUE #( ( n = `class`       v = class )
                                       ( n = `select`      v = select )
                                       ( n = `expand`      v = expand )
                                       ( n = `expandable`  v = z2ui5_cl_util_func=>boolean_abap_2_json( expandable ) )
                                       ( n = `expanded`    v = z2ui5_cl_util_func=>boolean_abap_2_json( expanded ) )
                                       ( n = `applyContentPadding`    v = z2ui5_cl_util_func=>boolean_abap_2_json( applycontentpadding ) )
                                       ( n = `backgroundDesign`    v = backgrounddesign )
                                       ( n = `enableTabReordering`    v = z2ui5_cl_util_func=>boolean_abap_2_json( enabletabreordering ) )
                                       ( n = `headerBackgroundDesign`    v = headerbackgrounddesign )
                                       ( n = `stretchContentHeight`    v = z2ui5_cl_util_func=>boolean_abap_2_json( stretchcontentheight ) )
                                       ( n = `headerMode`    v = headermode )
                                       ( n = `maxNestingLevel`    v = maxnestinglevel )
                                       ( n = `tabDensityMode`    v = tabdensitymode )
                                       ( n = `tabsOverflowMode`    v = tabsoverflowmode )
                                       ( n = `items`    v = items )
                                       ( n = `id`    v = id )
                                       ( n = `content`    v = content )
                                       ( n = `upperCase`    v = z2ui5_cl_util_func=>boolean_abap_2_json( uppercase ) )
                                       ( n = `selectedKey` v = selectedkey ) ) ).
  ENDMETHOD.


  METHOD icon_tab_filter.

    result = _generic( name   = `IconTabFilter`
                       t_prop = VALUE #( ( n = `icon`        v = icon )
                                       (  n = `items`    v = items )
                                       (  n = `design`    v = design )
                                       ( n = `iconColor`   v = iconcolor )
                                       ( n = `showAll`     v = z2ui5_cl_util_func=>boolean_abap_2_json( showall ) )
                                       ( n = `iconDensityAware`     v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) )
                                       ( n = `visible`     v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                       ( n = `count`       v = count )
                                       ( n = `text`        v = text )
                                       ( n = `id`        v = id )
                                       ( n = `textDirection`        v = textDirection )
                                       ( n = `class`        v = class )
                                       ( n = `key`         v = key ) ) ).
  ENDMETHOD.


  METHOD icon_tab_header.

    result = _generic( name   = `IconTabHeader`
                       t_prop = VALUE #( (  n = `selectedKey`     v = selectedkey )
                                         (  n = `items`           v = items )
                                         (  n = `select`          v = select )
                                         (  n = `ariaTexts`          v = ariatexts )
                                         (  n = `backgroundDesign`          v = backgrounddesign )
                                         (  n = `enableTabReordering`          v = z2ui5_cl_util_func=>boolean_abap_2_json( enabletabreordering ) )
                                         (  n = `maxNestingLevel`          v = maxnestinglevel )
                                         (  n = `tabDensityMode`          v = tabdensitymode )
                                         (  n = `tabsOverflowMode`          v = tabsoverflowmode )
                                         (  n = `visible`          v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         (  n = `mode`            v = mode  ) ) ).

  ENDMETHOD.


  METHOD icon_tab_separator.

    result = _generic( name = `IconTabSeparator`
                        t_prop = VALUE #( ( n = `icon` v = icon )
                                          ( n = `iconDensityAware` v = icondensityaware )
                                          ( n = `id` v = id )
                                          ( n = `class` v = class )
                                          ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                        ) ).

  ENDMETHOD.


  METHOD illustrated_message.

    result = _generic( name   = `IllustratedMessage`
                       t_prop = VALUE #( ( n = `enableVerticalResponsiveness` v = enableverticalresponsiveness )
                       ( n = `illustrationType`             v = illustrationtype )
                       ( n = `enableFormattedText`             v = z2ui5_cl_util_func=>boolean_abap_2_json( enableformattedtext ) )
                       ( n = `illustrationSize`             v = illustrationsize )
                       ( n = `description`             v = description )
                       ( n = `title`             v = title )
                       ) ).
  ENDMETHOD.


  METHOD image.
    result = me.
    _generic( name   = `Image`
              t_prop = VALUE #(
                ( n = `id` v = id )
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
                ( n = `decorative` v =  z2ui5_cl_util_func=>boolean_abap_2_json( decorative ) )
                ( n = `densityAware` v =  z2ui5_cl_util_func=>boolean_abap_2_json( densityaware ) )
                ( n = `lazyLoading` v =  z2ui5_cl_util_func=>boolean_abap_2_json( lazyloading ) )
                 ) ).
  ENDMETHOD.


  METHOD image_content.

    result = _generic( name   = `ImageContent`
                       t_prop = VALUE #( ( n = `src` v = src )
                                         ( n = `description` v = description )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                       ) ).


  ENDMETHOD.


  METHOD info_label.
    result = _generic( name   = `InfoLabel`
                       ns     = 'tnt'
                       t_prop = VALUE #(
                           ( n = `id`               v = id )
                           ( n = `class`               v = class )
                           ( n = `text`             v = text )
                           ( n = `renderMode `      v = rendermode  )
                           ( n = `colorScheme`      v = colorscheme )
                           ( n = `displayOnly`      v = z2ui5_cl_util_func=>boolean_abap_2_json( displayonly ) )
                           ( n = `icon`             v = icon )
                           ( n = `textDirection`    v = textdirection )
                           ( n = `visible`          v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                           ( n = `width`            v = width ) ) ).

  ENDMETHOD.


  METHOD input.
    result = me.
    _generic( name   = `Input`
              t_prop = VALUE #( ( n = `id`               v = id )
                                ( n = `placeholder`      v = placeholder )
                                ( n = `type`             v = type )
                                ( n = `maxLength`        v = maxlength )
                                ( n = `showClearIcon`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearicon ) )
                                ( n = `description`      v = description )
                                ( n = `editable`         v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                ( n = `enabled`          v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`          v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `enableTableAutoPopinMode` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabletableautopopinmode ) )
                                ( n = `enableSuggestionsHighlighting`  v = z2ui5_cl_util_func=>boolean_abap_2_json( enablesuggestionshighlighting ) )
                                ( n = `showTableSuggestionValueHelp`   v = z2ui5_cl_util_func=>boolean_abap_2_json( showtablesuggestionvaluehelp ) )
                                ( n = `valueState`       v = valuestate )
                                ( n = `valueStateText`   v = valuestatetext )
                                ( n = `value`            v = value )
                                ( n = `required`          v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                ( n = `suggest`          v = suggest )
                                ( n = `suggestionItems`  v = suggestionitems )
                                ( n = `suggestionRows`   v = suggestionrows )
                                ( n = `showSuggestion`   v = z2ui5_cl_util_func=>boolean_abap_2_json( showsuggestion ) )
                                ( n = `valueHelpRequest` v = valuehelprequest )
                                ( n = `autocomplete`     v = z2ui5_cl_util_func=>boolean_abap_2_json( autocomplete ) )
                                ( n = `valueLiveUpdate`  v = z2ui5_cl_util_func=>boolean_abap_2_json( valueliveupdate ) )
                                ( n = `submit`           v = z2ui5_cl_util_func=>boolean_abap_2_json( submit ) )
                                ( n = `showValueHelp`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluehelp ) )
                                ( n = `valueHelpOnly`    v = z2ui5_cl_util_func=>boolean_abap_2_json( valuehelponly ) )
                                ( n = `class`            v = class )
                                ( n = `change`            v = change )
                                ( n = `maxSuggestionWidth` v = maxsuggestionwidth )
                                ( n = `width`             v = width )
                                ( n = `textFormatter`     v = textformatter )
                                ( n = `startSuggestion`     v = startsuggestion )
                                ( n = `valueHelpIconSrc` v = valuehelpiconsrc )
                                ( n = `textFormatMode`  v = textformatmode )
                                ( n = `fieldWidth`          v = fieldwidth ) ) ).
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
                                         ( n = `showError`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showerror ) )
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
                                         ( n = `showError`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showerror ) )
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
                                         ( n = `selected`       v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) ) ) ).
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
    result = _generic( name = `items`  ns = ns ).
  ENDMETHOD.


  METHOD label.
    result = me.
    _generic( name   = `Label`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `displayOnly`   v = z2ui5_cl_util_func=>boolean_abap_2_json( displayonly ) )
                                ( n = `required`   v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                ( n = `showColon`   v = z2ui5_cl_util_func=>boolean_abap_2_json( showcolon ) )
                                ( n = `textAlign`   v = textalign )
                                ( n = `textDirection`   v = textdirection )
                                ( n = `vAlign`   v = valign )
                                ( n = `width`   v = width )
                                ( n = `wrapping`   v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
                                ( n = `wrappingType`   v = wrappingtype )
                                ( n = `design`   v = design )
                                ( n = `id`   v = id )
                                ( n = `class`   v = class )
                                ( n = `labelFor` v = labelfor ) ) ).
  ENDMETHOD.


  METHOD lanes.
    result = _generic( name = `lanes`
                       ns   = `commons` ).
  ENDMETHOD.


  METHOD layout_data.
    result = _generic( ns   = ns
                       name = `layoutData` ).
  ENDMETHOD.


  METHOD light_box.
    result =  _generic( name   = `LightBox`
                    t_prop = VALUE #( ( n = `id`         v = id )
                                      ( n = `class`    v = class )
                                      ( n = `visible`    v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD light_box_item.
    result =  _generic( name   = `LightBoxItem`
                        t_prop = VALUE #( ( n = `alt`         v = alt )
                                          ( n = `imageSrc`    v = imagesrc )
                                          ( n = `subtitle`    v = subtitle )
                                          ( n = `title`       v = title ) ) ).
  ENDMETHOD.


  METHOD line_micro_chart.
    result = me.
    _generic( name   = `LineMicroChart`
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showBottomLabels`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showbottomlabels ) )
                                ( n = `showPoints`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showpoints ) )
                                ( n = `showThresholdLine`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showthresholdline ) )
                                ( n = `showThresholdValue`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showthresholdvalue ) )
                                ( n = `showTopLabels`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showtoplabels ) )
                                ( n = `maxYValue`  v = maxyvalue ) ) ).
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
                                ( n = `subtle`      v = z2ui5_cl_util_func=>boolean_abap_2_json( subtle ) )
                                ( n = `textAlign`      v = textalign )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `validateUrl`      v = z2ui5_cl_util_func=>boolean_abap_2_json( validateurl ) )
                                ( n = `width`      v = width )
                                ( n = `wrapping`      v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
                                ( n = `emphasized`      v = z2ui5_cl_util_func=>boolean_abap_2_json( emphasized ) )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) ) ) ).
  ENDMETHOD.


  METHOD link_tile_content.
      result = _generic( name = `LinkTileContent`
                     t_prop = VALUE #(
                           ( n = `iconSrc`  v = iconsrc )
                           ( n = `linkHref`  v = linkhref )
                           ( n = `linkText`  v = linktext )
                           ( n = `linkPress`  v = linkpress )
                       ) ).
  ENDMETHOD.


  METHOD list.
    result = _generic( name   = `List`
                       t_prop = VALUE #( ( n = `headerText`             v = headertext )
                                         ( n = `items`                  v = items )
                                         ( n = `mode`                   v = mode )
                                         ( n = `itemPress`                   v = itemPress )
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
                                         ( n = `modeAnimationOn`        v = z2ui5_cl_util_func=>boolean_abap_2_json( modeanimationon ) )
                                         ( n = `growingScrollToLoad`    v = z2ui5_cl_util_func=>boolean_abap_2_json( growingscrolltoload ) )
                                         ( n = `includeItemInSelection` v = z2ui5_cl_util_func=>boolean_abap_2_json( includeiteminselection ) )
                                         ( n = `growing`                v = z2ui5_cl_util_func=>boolean_abap_2_json( growing ) )
                                         ( n = `inset`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( inset ) )
                                         ( n = `rememberSelections`     v = z2ui5_cl_util_func=>boolean_abap_2_json( rememberselections ) )
                                         ( n = `showUnread`             v = z2ui5_cl_util_func=>boolean_abap_2_json( showunread ) )
                                         ( n = `visible`                v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
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
                                ( n = `enabled`        v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `additionalText` v = additionaltext ) ) ).
  ENDMETHOD.


  METHOD main_content.
    result = _generic( name = `mainContent`
                       ns   = `f` ).
  ENDMETHOD.


  METHOD main_contents.

    result = _generic( name   = `mainContents`
                       ns     = `tnt` ).

  ENDMETHOD.


  METHOD map_container.

    result = _generic( name = `MapContainer`
                      ns    = `vk`
                      t_prop = VALUE #(
                            ( n = `id`  v = id )
                            ( n = `autoAdjustHeight`  v = z2ui5_cl_util_func=>boolean_abap_2_json( autoadjustheight ) )
                        ) ).

  ENDMETHOD.


  METHOD markers.
    result = _generic( name = `markers` ns = ns ).
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
                                ( n = `required`              v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                ( n = `showClearIcon`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearicon ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluestatemessage ) )
                                ( n = `visible`               v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `fieldWidth`            v = fieldwidth ) ) ).
  ENDMETHOD.


  METHOD mask_input_rule.
    result = _generic( name   = `MaskInputRule`
                       t_prop = VALUE #( ( n = `maskFormatSymbol` v = maskformatsymbol )
                                         ( n = `regex`            v = regex ) ) ).
  ENDMETHOD.


  METHOD master_pages.
    result = _generic( name = `masterPages` ).
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
                       t_prop = VALUE #( ( n = `type`                v = type )
                                         ( n = `title`               v = title )
                                         ( n = `subtitle`            v = subtitle )
                                         ( n = `description`         v = description )
                                         ( n = `longtextUrl`         v = longtexturl )
                                         ( n = `textDirection`       v = textdirection )
                                         ( n = `groupName`           v = groupname )
                                         ( n = `activeTitle`         v = z2ui5_cl_util_func=>boolean_abap_2_json( activetitle ) )
                                         ( n = `counter`             v = counter )
                                         ( n = `markupDescription`   v = z2ui5_cl_util_func=>boolean_abap_2_json( markupdescription ) ) ) ).
  ENDMETHOD.


  METHOD message_page.
    result = _generic( name   = `MessagePage`
                       t_prop = VALUE #(
                           ( n = `showHeader`          v = z2ui5_cl_util_func=>boolean_abap_2_json( show_header ) )
                           ( n = `description`         v = description )
                           ( n = `icon`                v = icon )
                           ( n = `text`                v = text )
                           ( n = `enableFormattedText` v = z2ui5_cl_util_func=>boolean_abap_2_json( enableformattedtext ) )
                            ) ).
  ENDMETHOD.


  METHOD message_popover.
    result = _generic( name   = `MessagePopover`
                       t_prop = VALUE #( ( n = `items`             v = items )
                                         ( n = `activeTitlePress`  v = activetitlepress )
                                         ( n = `placement`         v = placement )
                                         ( n = `listSelect`        v = listselect )
                                         ( n = `afterClose`        v = afterclose )
                                         ( n = `beforeClose`       v = beforeclose )
                                         ( n = `initiallyExpanded` v = z2ui5_cl_util_func=>boolean_abap_2_json( initiallyexpanded ) )
                                         ( n = `groupItems`        v = z2ui5_cl_util_func=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.


  METHOD message_strip.
    result = me.
    _generic( name   = `MessageStrip`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `type`     v = type )
                                ( n = `showIcon` v = z2ui5_cl_util_func=>boolean_abap_2_json( showicon ) )
                                ( n = `class`    v = class ) ) ).
  ENDMETHOD.


  METHOD message_view.

    result = _generic( name   = `MessageView`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = z2ui5_cl_util_func=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.


  METHOD mid_column_pages.

    result = _generic( name   = `midColumnPages`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id` v = id ) ) ).

  ENDMETHOD.


  METHOD multi_combobox.
    result = _generic( name   = `MultiComboBox`
                       t_prop = VALUE #( (  n = `selectionChange`     v = selectionchange )
                                         (  n = `selectedKeys`        v = selectedkeys )
                                         (  n = `selectedItems`        v = selectedItems )
                                         (  n = `items`               v = items )
                                         (  n = `selectionFinish`     v = selectionfinish )
                                         (  n = `width`               v = width )
                                         (  n = `showSecondaryValues` v = z2ui5_cl_util_func=>boolean_abap_2_json( showsecondaryvalues ) )
                                         (  n = `placeholder`         v = placeholder )
                                         (  n = `selectedItemId`         v = selecteditemid )
                                         (  n = `selectedKey`         v = selectedkey )
                                         (  n = `name`                v = name )
                                         (  n = `value`                v = value )
                                         (  n = `valueState`                v = valuestate )
                                         (  n = `valueStateText`                v = valuestatetext )
                                         (  n = `textAlign`                v = textalign )
                                         (  n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         (  n = `showValueStateMessage`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluestatemessage ) )
                                         (  n = `showClearIcon`        v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearicon ) )
                                         (  n = `showButton`            v = z2ui5_cl_util_func=>boolean_abap_2_json( showbutton ) )
                                         (  n = `required`            v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                         (  n = `editable`            v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                         (  n = `enabled`             v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         (  n = `filterSecondaryValues`             v = z2ui5_cl_util_func=>boolean_abap_2_json( filtersecondaryvalues ) )
                                         (  n = `showSelectAll`       v = showselectall ) ) ).
  ENDMETHOD.


  METHOD multi_input.
    result = _generic( name   = `MultiInput`
                       t_prop = VALUE #( ( n = `tokens` v = tokens )
                                         ( n = `showClearIcon` v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearicon ) )
                                         ( n = `showValueHelp` v = z2ui5_cl_util_func=>boolean_abap_2_json( showvaluehelp ) )
                                         ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `suggestionItems` v = suggestionitems )
                                         ( n = `tokenUpdate` v = tokenupdate )
                                         ( n = `submit` v = submit )
                                         ( n = `width` v = width )
                                         ( n = `value` v = value )
                                         ( n = `id` v = id )
                                         ( n = `change` v = change )
                                         ( n = `valueHelpRequest` v = valuehelprequest )
                                         ( n = `class` v = class ) ) ).
  ENDMETHOD.


  METHOD navigation_actions.
    result = _generic( name = `navigationActions`
                       ns   = `f` ).
  ENDMETHOD.


  METHOD nav_container.

    result = _generic( name   = `NavContainer`
                       t_prop = VALUE #(
                        ( n = `initialPage`  v = initialpage  )
                        ( n = `id`           v = id  )
                        ( n = `height`           v = height  )
                        ( n = `width`           v = width  )
                        ( n = `autoFocus` v = z2ui5_cl_util_func=>boolean_abap_2_json( autoFocus ) )
                        ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                        ( n = `defaultTransitionName`   v = defaulttransitionname  )
                        )  ).

  ENDMETHOD.


  METHOD nodes.
    result = _generic( name = `nodes`
                       ns   = `commons` ).
  ENDMETHOD.


  METHOD numeric_content.

    result = _generic( name   = `NumericContent`
                       t_prop = VALUE #( ( n = `value`      v = value )
                                         ( n = `icon`       v = icon )
                                         ( n = `width`       v = width )
                                         ( n = `valueColor`       v = valueColor )
                                         ( n = `truncateValueTo`       v = truncateValueTo )
                                         ( n = `state`       v = state )
                                         ( n = `scale`       v = scale )
                                         ( n = `indicator`       v = indicator )
                                         ( n = `iconDescription`       v = iconDescription )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `nullifyValue` v = z2ui5_cl_util_func=>boolean_abap_2_json( nullifyValue ) )
                                         ( n = `formatterValue` v = z2ui5_cl_util_func=>boolean_abap_2_json( formatterValue ) )
                                         ( n = `animateTextChange` v = z2ui5_cl_util_func=>boolean_abap_2_json( animateTextChange ) )
                                         ( n = `adaptiveFontSize` v = z2ui5_cl_util_func=>boolean_abap_2_json( adaptivefontsize ) )
                                         ( n = `withMargin` v = z2ui5_cl_util_func=>boolean_abap_2_json( withmargin ) ) ) ).

  ENDMETHOD.


  METHOD numeric_header.

      result = _generic( name = `NumericHeader` ns = `f`
                     t_prop = VALUE #(
                           ( n = `id`  v = id )
                           ( n = `class`  v = class )
                           ( n = `datatimestamp`  v = datatimestamp )
                           ( n = `press`  v = press )
                           ( n = `details`  v = details )
                           ( n = `detailsMaxLines`  v = detailsMaxLines )
                           ( n = `detailsState`  v = detailsState )
                           ( n = `iconAlt`  v = iconAlt )
                           ( n = `iconBackgroundColor`  v = iconBackgroundColor )
                           ( n = `iconDisplayShape`  v = iconDisplayShape )
                           ( n = `iconSize`  v = iconSize )
                           ( n = `iconSrc`  v = iconSrc )
                           ( n = `iconInitials`  v = iconInitials )
                           ( n = `number`  v = number )
                           ( n = `numberSize`  v = numberSize )
                           ( n = `scale`  v = scale )
                           ( n = `sideIndicatorsAlignment`  v = sideIndicatorsAlignment )
                           ( n = `state`  v = state )
                           ( n = `statusText`  v = statusText )
                           ( n = `subtitle`  v = subtitle )
                           ( n = `subtitleMaxLines`  v = subtitleMaxLines )
                           ( n = `title`  v = title )
                           ( n = `titleMaxLines`  v = titleMaxLines )
                           ( n = `trend`  v = trend )
                           ( n = `unitOfMeasurement`  v = unitOfMeasurement )
                           ( n = `statusVisible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( statusVisible ) )
                           ( n = `numberVisible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( numberVisible ) )
                           ( n = `iconVisible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( iconVisible ) )
                           ( n = `visible`           v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                       ) ).
  ENDMETHOD.


  METHOD numeric_side_indicator.
    result = _generic( name = `NumericSideIndicator`  ns = `f`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `unit`  v = unit )
                             ( n = `title`  v = title )
                             ( n = `state`  v = state )
                             ( n = `number`  v = number )
                             ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD object_attribute.
    result = me.

    _generic( name   = `ObjectAttribute`
              t_prop = VALUE #( ( n = `title`          v = title )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `ariaHasPopup`   v = ariahaspopup )
                                ( n = `press`          v = press )
                                ( n = `active`         v = z2ui5_cl_util_func=>boolean_abap_2_json( active ) )
                                ( n = `visible`        v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `text`           v = text ) ) ).
  ENDMETHOD.


  METHOD object_header.

    result = _generic( name   = `ObjectHeader`
                       t_prop = VALUE #( ( n = `backgrounddesign`     v = backgrounddesign )
                                         ( n = `condensed`            v = z2ui5_cl_util_func=>boolean_abap_2_json( condensed ) )
                                         ( n = `fullscreenoptimized`  v = z2ui5_cl_util_func=>boolean_abap_2_json( fullscreenoptimized ) )
                                         ( n = `icon`                 v = icon )
                                         ( n = `iconactive`           v = z2ui5_cl_util_func=>boolean_abap_2_json( iconactive ) )
                                         ( n = `iconalt`              v = iconalt )
                                         ( n = `icondensityaware`     v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `icontooltip`          v = icontooltip )
                                         ( n = `imageshape`           v = imageshape )
                                         ( n = `intro`                v = intro )
                                         ( n = `introactive`          v = z2ui5_cl_util_func=>boolean_abap_2_json( introactive ) )
                                         ( n = `introhref`            v = introhref )
                                         ( n = `introtarget`          v = introtarget )
                                         ( n = `introtextdirection`   v = introtextdirection )
                                         ( n = `number`               v = number )
                                         ( n = `numberstate`          v = numberstate )
                                         ( n = `numbertextdirection`  v = numbertextdirection )
                                         ( n = `numberunit`           v = numberunit )
                                         ( n = `responsive`           v = z2ui5_cl_util_func=>boolean_abap_2_json( responsive ) )
                                         ( n = `showtitleselector`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showtitleselector ) )
                                         ( n = `title`                v = title )
                                         ( n = `titleactive`          v = z2ui5_cl_util_func=>boolean_abap_2_json( titleactive ) )
                                         ( n = `titlehref`            v = titlehref )
                                         ( n = `titlelevel`           v = titlelevel )
                                         ( n = `titleselectortooltip` v = titleselectortooltip )
                                         ( n = `titletarget`          v = titletarget )
                                         ( n = `titletextdirection`   v = titletextdirection )
                                         ( n = `iconpress`            v = iconpress )
                                         ( n = `intropress`           v = intropress )
                                         ( n = `titlepress`           v = titlepress )
                                         ( n = `titleselectorpress`   v = titleselectorpress ) ) ).
  ENDMETHOD.


  METHOD object_identifier.
    result = _generic( name   = `ObjectIdentifier`
                       t_prop = VALUE #( ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                         ( n = `text` v = text )
                                         ( n = `textDirection` v = textdirection )
                                         ( n = `title` v = title )
                                         ( n = `titleActive` v = titleactive )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `titlePress` v = titlepress ) ) ).
  ENDMETHOD.


  METHOD object_list_item.
    result = _generic( name   = `ObjectListItem`
                       t_prop = VALUE #( ( n = `activeIcon`          v = activeicon )
                                         ( n = `icon`                v = icon )
                                         ( n = `intro`               v = intro )
                                         ( n = `introTextDirection`  v = introtextdirection )
                                         ( n = `number`              v = number )
                                         ( n = `numberState`         v = numberstate )
                                         ( n = `numberTextDirection` v = numbertextdirection )
                                         ( n = `numberUnit`          v = numberunit )
                                         ( n = `title`               v = title )
                                         ( n = `titleTextDirection`  v = titletextdirection )
                                         ( n = `iconDensityAware`    v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) ) ) ).
  ENDMETHOD.


  METHOD object_marker.
    result = _generic( name = `ObjectMarker`
                       t_prop = VALUE #( ( n = `additionalInfo` v = additionalinfo )
                                         ( n = `type`           v = type )
                                         ( n = `visible`        v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `press`          v = press )
                                         ( n = `visibility`     v = visibility ) ) ).
  ENDMETHOD.


  METHOD object_number.
    result = me.
    _generic( name   = `ObjectNumber`
              t_prop = VALUE #( ( n = `emphasized`         v = z2ui5_cl_util_func=>boolean_abap_2_json( emphasized ) )
                                ( n = `number`             v = number )
                                ( n = `state`              v = state )
                                ( n = `id`          v = id )
                                ( n = `class`          v = class )
                                ( n = `textAlign`          v = textalign )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                ( n = `numberunit`         v = numberunit )
                                ( n = `active`             v = z2ui5_cl_util_func=>boolean_abap_2_json( active ) )
                                ( n = `inverted`           v = z2ui5_cl_util_func=>boolean_abap_2_json( inverted ) )
                                ( n = `visible`            v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `unit`               v = unit ) ) ).
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
                     ( n = `showTitleInHeaderContent` v = z2ui5_cl_util_func=>boolean_abap_2_json( showtitleinheadercontent ) )
                     ( n = `showEditHeaderButton`     v = z2ui5_cl_util_func=>boolean_abap_2_json( showeditheaderbutton ) )
                     ( n = `editHeaderButtonPress`    v = editheaderbuttonpress )
                     ( n = `upperCaseAnchorBar`       v = uppercaseanchorbar )
                     ( n = `showFooter`               v = z2ui5_cl_util_func=>boolean_abap_2_json( showfooter ) ) ) ).
  ENDMETHOD.


  METHOD object_page_section.
    result = _generic( name   = `ObjectPageSection`
                       ns     = `uxap`
                       t_prop = VALUE #( ( n = `titleUppercase`  v = z2ui5_cl_util_func=>boolean_abap_2_json( titleuppercase ) )
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
                       t_prop = VALUE #( ( n = `active`                v = z2ui5_cl_util_func=>boolean_abap_2_json( active ) )
                                         ( n = `emptyIndicatorMode`    v = emptyindicatormode )
                                         ( n = `icon`                  v = icon )
                                         ( n = `iconDensityAware`      v = z2ui5_cl_util_func=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `inverted`              v = z2ui5_cl_util_func=>boolean_abap_2_json( inverted ) )
                                         ( n = `state`                 v = state )
                                         ( n = `stateAnnouncementText` v = stateannouncementtext )
                                         ( n = `text`                  v = text )
                                         ( n = `id`                  v = id )
                                         ( n = `class`                  v = class )
                                         ( n = `textDirection`         v = textdirection )
                                         ( n = `title`                 v = title )
                                         ( n = `visible`               v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `press`                 v = press ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar.
    result = _generic( name   = `OverflowToolbar`
                       t_prop = VALUE #( ( n = `press`   v = press )
                                         ( n = `text`    v = text )
                                         ( n = `active` v = z2ui5_cl_util_func=>boolean_abap_2_json( active ) )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `asyncMode` v = z2ui5_cl_util_func=>boolean_abap_2_json( asyncMode ) )
                                         ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
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
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_menu_button.
    result = _generic( name   = `OverflowToolbarMenuButton`
                       t_prop = VALUE #( ( n = `buttonMode` v = buttonmode )
                                         ( n = `defaultAction` v = defaultaction )
                                         ( n = `text`    v = text )
                                         ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `icon`    v = icon )
                                         ( n = `type`    v = type )
                                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_toggle_button.
    result = me.
    _generic( name   = `OverflowToolbarToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD page.
    result = _generic( name   = `Page`
                       ns     = ns
                       t_prop = VALUE #( ( n = `title` v = title )
                                         ( n = `showNavButton`  v = z2ui5_cl_util_func=>boolean_abap_2_json( shownavbutton ) )
                                         ( n = `navButtonPress` v = navbuttonpress )
                                         ( n = `showHeader` v = z2ui5_cl_util_func=>boolean_abap_2_json( showheader ) )
                                         ( n = `class` v = class )
                                         ( n = `backgroundDesign` v = backgrounddesign )
                                         ( n = `navButtonTooltip` v = navbuttontooltip )
                                         ( n = `titleAlignment` v = titlealignment )
                                         ( n = `titleLevel` v = titlelevel )
                                         ( n = `contentOnlyBusy` v = z2ui5_cl_util_func=>boolean_abap_2_json( contentonlybusy ) )
                                         ( n = `enableScrolling` v = z2ui5_cl_util_func=>boolean_abap_2_json( enablescrolling ) )
                                         ( n = `floatingFooter` v = z2ui5_cl_util_func=>boolean_abap_2_json( floatingfooter ) )
                                         ( n = `showFooter` v = z2ui5_cl_util_func=>boolean_abap_2_json( showfooter ) )
                                         ( n = `showSubHeader` v = z2ui5_cl_util_func=>boolean_abap_2_json( showsubheader ) )
                                         ( n = `id` v = id ) ) ).
  ENDMETHOD.


  METHOD pages.
    result = _generic( name   = `pages`  ).

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

    result = _generic( name   = `Panel`
                       t_prop = VALUE #( ( n = `expandable` v = z2ui5_cl_util_func=>boolean_abap_2_json( expandable ) )
                                         ( n = `expanded`   v = z2ui5_cl_util_func=>boolean_abap_2_json( expanded ) )
                                         ( n = `stickyHeader`   v = z2ui5_cl_util_func=>boolean_abap_2_json( stickyheader ) )
                                         ( n = `expandAnimation`   v = z2ui5_cl_util_func=>boolean_abap_2_json( expandAnimation ) )
                                         ( n = `visible`   v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `height`   v = height )
                                         ( n = `backgroundDesign`   v = backgroundDesign )
                                         ( n = `width`   v = width )
                                         ( n = `id`   v = id )
                                         ( n = `class`   v = class )
                                         ( n = `headerText` v = headertext ) ) ).

  ENDMETHOD.


  METHOD pane_container.
    result = _generic( name   = `PaneContainer` ns = `layout`
                       t_prop = VALUE #( ( n = `resize`       v = resize )
                                         ( n = `orientation`  v = orientation  ) ) ).
  ENDMETHOD.


  METHOD planning_calendar.
    result = _generic( name   = `PlanningCalendar`
                       t_prop = VALUE #(
                           ( n = `rows`                      v = rows )
                           ( n = `startDate`                 v = startdate )
                           ( n = `appointmentsVisualization` v = appointmentsvisualization )
                           ( n = `appointmentSelect`         v = appointmentselect )
                           ( n = `showEmptyIntervalHeaders`  v = showemptyintervalheaders )
                           ( n = `showWeekNumbers`           v = showweeknumbers )
                           ( n = `legend`                    v = legend )
                           ( n = `showDayNamesLine`          v = showdaynamesline ) ) ).
  ENDMETHOD.


  METHOD planning_calendar_legend.
    result = _generic( name   = `PlanningCalendarLegend`
                       t_prop = VALUE #(
                           ( n = `id`                              v = id )
                           ( n = `items`                           v = items )
                           ( n = `appointmentItems`                v = appointmentitems )
                           ( n = `standardItems`                   v = standarditems ) ) ).

  ENDMETHOD.


  METHOD planning_calendar_row.
    result = _generic( name   = `PlanningCalendarRow`
                       t_prop = VALUE #(
                           ( n = `appointments`                    v = appointments )
                           ( n = `intervalHeaders`                 v = intervalheaders )
                           ( n = `icon`                            v = icon )
                           ( n = `title`                           v = title )
                           ( n = `key`                             v = key )
                           ( n = `enableAppointmentsCreate`        v = enableappointmentscreate )
                           ( n = `appointmentResize`               v = appointmentresize )
                           ( n = `appointmentDrop`                 v = appointmentdrop )
                           ( n = `appointmentDragEnter`            v = appointmentdragenter )
                           ( n = `appointmentCreate`               v = appointmentcreate )
                           ( n = `selected`                        v = selected )
                           ( n = `nonWorkingDays`                  v = nonworkingdays )
                           ( n = `enableAppointmentsResize`        v = enableappointmentsresize )
                           ( n = `enableAppointmentsDragAndDrop`   v = enableappointmentsdraganddrop )
                           ( n = `text`                            v = text ) ) ).

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
                                         ( n = `initialFocus`  v = initialfocus )
                                         ( n = `contentHeight` v = contentheight )
                                         ( n = `showheader`    v = showheader )
                                         ( n = `contentWidth`  v = contentwidth ) ) ).
  ENDMETHOD.


  METHOD process_flow.
    result = _generic( name   = `ProcessFlow`
                   ns     = 'commons'
                   t_prop = VALUE #( ( n = `id`               v = id )
                                     ( n = `foldedCorners`    v = z2ui5_cl_util_func=>boolean_abap_2_json( foldedcorners ) )
                                     ( n = `scrollable`       v = z2ui5_cl_util_func=>boolean_abap_2_json( scrollable ) )
                                     ( n = `showLabels`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showlabels ) )
                                     ( n = `visible`          v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                     ( n = `wheelZoomable`    v = z2ui5_cl_util_func=>boolean_abap_2_json( wheelzoomable ) )
                                     ( n = `headerPress`      v = headerpress )
                                     ( n = `labelPress`       v = labelpress )
                                     ( n = `nodePress`        v = nodepress )
                                     ( n = `onError`          v = onerror )
                                     ( n = `lanes`            v = lanes )
                                     ( n = `nodes`            v = nodes ) ) ).
  ENDMETHOD.


  METHOD process_flow_lane_header.

    result = _generic( name   = `ProcessFlowLaneHeader`
                   ns     = 'commons'
                   t_prop = VALUE #( ( n = `iconSrc`          v = iconsrc )
                                     ( n = `laneId`           v = laneid )
                                     ( n = `position`         v = position )
                                     ( n = `state`            v = state )
                                     ( n = `text`             v = text )
                                     ( n = `zoomLevel`        v = zoomlevel ) ) ).
  ENDMETHOD.


  METHOD process_flow_node.
    result = _generic( name   = `ProcessFlowNode`
                   ns     = 'commons'
                   t_prop = VALUE #( ( n = `laneId`               v = laneid )
                                     ( n = `nodeId`               v = nodeid )
                                     ( n = `title`                v = title )
                                     ( n = `titleAbbreviation`    v = titleabbreviation )
                                     ( n = `children`             v = children )
                                     ( n = `state`                v = state )
                                     ( n = `stateText`            v = statetext )
                                     ( n = `texts`                v = texts )
                                     ( n = `highlighted`          v = z2ui5_cl_util_func=>boolean_abap_2_json( highlighted )  )
                                     ( n = `focused`              v = z2ui5_cl_util_func=>boolean_abap_2_json( focused ) )
                                     ( n = `selected`             v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                     ( n = `tag`                  v = tag )
                                     ( n = `texts`                v = texts )
                                     ( n = `type`                 v = type ) ) ).
  ENDMETHOD.


  METHOD progress_indicator.
    result = me.
    _generic( name   = `ProgressIndicator`
              t_prop = VALUE #( ( n = `class`        v = class )
                                ( n = `percentValue` v = percentvalue )
                                ( n = `displayValue` v = displayvalue )
                                ( n = `showValue`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showvalue ) )
                                ( n = `state`        v = state ) ) ).
  ENDMETHOD.


  METHOD proportion_zoom_strategy.
    result = _generic( name = `ProportionZoomStrategy`
                       ns   = `axistime` ).
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
    result = _generic( name = `QuickViewGroup`
                       t_prop   = VALUE #( ( n = `heading` v = heading )
                                           ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD quick_view_group_element.
    result =  _generic( name   = `QuickViewGroupElement`
                        t_prop = VALUE #( ( n = `emailSubject`  v = emailsubject )
                                          ( n = `label`       v = label )
                                          ( n = `pageLinkId`  v = pagelinkid )
                                          ( n = `target`      v = target )
                                          ( n = `type`      v = type )
                                          ( n = `url`      v = url )
                                          ( n = `value`      v = value )
                                          ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).
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
    result = _generic( name = `avatar` ).
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `valueColor`  v = valuecolor ) ) ).
  ENDMETHOD.


  METHOD radio_button.
    result = _generic( name = `RadioButton`
                   t_prop   = VALUE #( ( n = `activeHandling`  v = z2ui5_cl_util_func=>boolean_abap_2_json( activehandling ) )
                                     ( n = `editable`        v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                     ( n = `enabled`         v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                     ( n = `selected`        v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                     ( n = `useEntireWidth`  v = z2ui5_cl_util_func=>boolean_abap_2_json( useentirewidth ) )
                                     ( n = `text`            v = text )
                                     ( n = `textDirection`   v = textdirection )
                                     ( n = `textAlign`       v = textalign )
                                     ( n = `groupName`       v = groupname )
                                     ( n = `valueState`      v = valuestate )
                                     ( n = `width`           v = width )
                                     ( n = `select`          v = select )
           ) ).
  ENDMETHOD.


  METHOD radio_button_group.
    result = _generic( name   = `RadioButtonGroup`
                       t_prop = VALUE #( ( n = `id`             v = id )
                                         ( n = `columns`        v = columns )
                                         ( n = `editable`       v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                         ( n = `enabled`        v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `selectedIndex`  v = selectedindex )
                                         ( n = `textDirection`  v = textdirection )
                                         ( n = `valueState`     v = valuestate )
                                         ( n = `select`         v = select )
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
                                ( n = `showTickmarks`   v = z2ui5_cl_util_func=>boolean_abap_2_json( showtickmarks ) )
                                ( n = `startValue`   v = startvalue )
                                ( n = `step`   v = step )
                                ( n = `width`   v = width ) ) ).
  ENDMETHOD.


  METHOD rating_indicator.

    result = _generic( name   = `RatingIndicator`
                       t_prop = VALUE #( ( n = `class`        v = class )
                                         ( n = `maxValue`     v = maxvalue )
                                         ( n = `displayOnly`  v = displayonly )
                                         ( n = `editable`     v = editable )
                                         ( n = `iconSize`     v = iconsize )
                                         ( n = `value`        v = value )
                                         ( n = `id`           v = id )
                                         ( n = `change`       v = change )
                                         ( n = `enabled`      v = enabled )
                                         ( n = `tooltip`      v = tooltip ) ) ).

  ENDMETHOD.


  METHOD responsive_splitter.
    result = _generic( name   = `ResponsiveSplitter` ns = `layout`
                       t_prop = VALUE #( ( n = `defaultPane`  v = defaultpane )
                                         ( n = `height`       v = height )
                                         ( n = `width`        v = width  ) ) ).
  ENDMETHOD.


  METHOD rich_text_editor.
    result = _generic( name   = `RichTextEditor`
                       ns     = `text`
                       t_prop = VALUE #( ( n = `buttonGroups`        v = buttongroups )
                                         ( n = `customToolbar`       v = z2ui5_cl_util_func=>boolean_abap_2_json( customtoolbar ) )
                                         ( n = `editable`            v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                         ( n = `height`              v = height )
                                         ( n = `editorType`          v = editortype )
                                         ( n = `plugins`             v = plugins )
                                         ( n = `textDirection`       v = textdirection )
                                         ( n = `value`               v = value )
                                         ( n = `beforeEditorInit`    v = beforeeditorinit )
                                         ( n = `change`              v = change )
                                         ( n = `ready`               v = ready )
                                         ( n = `readyRecurring`      v = readyrecurring )
                                         ( n = `required`            v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                         ( n = `sanitizeValue`       v = z2ui5_cl_util_func=>boolean_abap_2_json( sanitizevalue ) )
                                         ( n = `showGroupClipboard`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showgroupclipboard ) )
                                         ( n = `showGroupFont`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showgroupfont ) )
                                         ( n = `showGroupFontStyle`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showgroupfontstyle ) )
                                         ( n = `showGroupInsert`     v = z2ui5_cl_util_func=>boolean_abap_2_json( showgroupinsert ) )
                                         ( n = `showGroupLink`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showgrouplink ) )
                                         ( n = `showGroupStructure`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showgroupstructure ) )
                                         ( n = `showGroupTextAlign`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showgrouptextalign ) )
                                         ( n = `showGroupUndo`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showgroupundo ) )
                                         ( n = `useLegacyTheme`      v = z2ui5_cl_util_func=>boolean_abap_2_json( uselegacytheme ) )
                                         ( n = `wrapping`            v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
                                         ( n = `width`               v = width ) ) ).

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
                                         ( n = `id`       v = id )
                                         ( n = `vertical`    v = z2ui5_cl_util_func=>boolean_abap_2_json( vertical ) )
                                         ( n = `horizontal`  v = z2ui5_cl_util_func=>boolean_abap_2_json( horizontal ) )
                                         ( n = `focusable`   v = z2ui5_cl_util_func=>boolean_abap_2_json( focusable ) ) ) ).
  ENDMETHOD.


  METHOD search_field.
    result = me.
    _generic( name   = `SearchField`
              t_prop = VALUE #( ( n = `width`  v = width )
                                ( n = `search` v = search )
                                ( n = `value`  v = value )
                                ( n = `id`     v = id )
                                ( n = `change` v = change )
                                ( n = `maxLength` v = maxlength )
                                ( n = `placeholder` v = placeholder )
                                ( n = `suggest` v = suggest )
                                ( n = `enableSuggestions` v = z2ui5_cl_util_func=>boolean_abap_2_json( enablesuggestions ) )
                                ( n = `showRefreshButton` v = z2ui5_cl_util_func=>boolean_abap_2_json( showrefreshbutton ) )
                                ( n = `showSearchButton` v = z2ui5_cl_util_func=>boolean_abap_2_json( showsearchbutton ) )
                                ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `liveChange` v = livechange ) ) ).
  ENDMETHOD.


  METHOD second_status.
    result = _generic( name = `secondStatus` ).
  ENDMETHOD.


  METHOD sections.
    result = _generic( name = `sections`
                       ns   = `uxap` ).
  ENDMETHOD.


  METHOD segmented_button.
    result = _generic( name   = `SegmentedButton`
                       t_prop = VALUE #( ( n = `id` v = id )
                                         ( n = `selectedKey` v = selected_key )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `selectionChange` v = selection_change ) ) ).
  ENDMETHOD.


  METHOD segmented_button_item.
    result = me.
    _generic( name   = `SegmentedButtonItem`
              t_prop = VALUE #( ( n = `icon`  v = icon )
                                ( n = `press`   v = press )
                                ( n = `width`   v = width )
                                ( n = `key`   v = key )
                                ( n = `textDirection`   v = textDirection )
                                ( n = `enabled`   v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`   v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `text`  v = text ) ) ).
  ENDMETHOD.


  METHOD segments.
    result = _generic( name = `segments`
                       ns   = `mchart` ).
  ENDMETHOD.


  METHOD select.
    result = _generic( name = `Select`
                       t_prop = VALUE #(
                             ( n = `id`                  v = id )
                             ( n = `class`                  v = class )
                             ( n = `autoAdjustWidth`     v = z2ui5_cl_util_func=>boolean_abap_2_json( autoAdjustWidth ) )
                             ( n = `columnRatio`         v = columnRatio )
                             ( n = `editable`            v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                             ( n = `enabled`             v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                             ( n = `forceSelection`      v = z2ui5_cl_util_func=>boolean_abap_2_json( forceSelection ) )
                             ( n = `icon`                v = icon )
                             ( n = `maxWidth`            v = maxWidth )
                             ( n = `name`                v = name )
                             ( n = `required`            v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                             ( n = `resetOnMissingKey`   v = z2ui5_cl_util_func=>boolean_abap_2_json( resetOnMissingKey ) )
                             ( n = `selectedItemId`      v = selectedItemId )
                             ( n = `selectedKey`         v = selectedKey )
                             ( n = `showSecondaryValues` v = z2ui5_cl_util_func=>boolean_abap_2_json( showSecondaryValues ) )
                             ( n = `textAlign`           v = textAlign )
                             ( n = `textDirection`       v = textDirection )
                             ( n = `type`                v = type )
                             ( n = `valueState`          v = valueState )
                             ( n = `valueStateText`      v = valueStateText )
                             ( n = `width`               v = width )
                             ( n = `wrapItemsText`       v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapItemsText ) )
                             ( n = `items`               v = items )
                             ( n = `selectedItem`        v = selectedItem )
                             ( n = `change`              v = change )
                             ( n = `liveChange`          v = liveChange )
                             ( n = `visible`             v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD shapes1.
    result = _generic( name = `shapes1`
                       ns   = `gantt` ).
  ENDMETHOD.


  METHOD shapes2.
    result = _generic( name = `shapes2`
                       ns   = `gantt` ).
  ENDMETHOD.


  METHOD shell.
    result = _generic( name = `Shell`
                       ns   = ns
                              t_prop = VALUE #( ( n = `appWidthLimited`  v = z2ui5_cl_util_func=>boolean_abap_2_json( appWidthLimited ) ) )
                    ).
  ENDMETHOD.


  METHOD side_content.
    result = _generic( name   = `sideContent`
                       ns     = 'layout'
                       t_prop = VALUE #(
                           ( n = `width`                           v = width ) ) ).

  ENDMETHOD.


  METHOD side_panel.
    result = _generic( name   = `SidePanel`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `sidePanelWidth`  v = sidepanelwidth )
                                         ( n = `sidePanelResizeStep`      v = sidepanelresizestep )
                                         ( n = `sidePanelResizeLargerStep`      v = sidepanelresizelargerstep )
                                         ( n = `sidePanelPosition`      v = sidepanelposition )
                                         ( n = `sidePanelMinWidth`      v = sidepanelminwidth )
                                         ( n = `sidePanelMaxWidth`      v = sidepanelmaxwidth )
                                         ( n = `sidePanelResizable`    v = z2ui5_cl_util_func=>boolean_abap_2_json( sidepanelresizable ) )
                                         ( n = `actionBarExpanded`    v = z2ui5_cl_util_func=>boolean_abap_2_json( actionbarexpanded ) )
                                         ( n = `toggle`    v = toggle )
                                         ( n = `ariaLabel`  v = arialabel ) ) ).
  ENDMETHOD.


  METHOD side_panel_item.
    result = _generic( name   = `SidePanelItem`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `icon` v = icon )
                                         ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `key` v = key )
                                         ( n = `text` v = text ) ) ).
  ENDMETHOD.


  METHOD simple_form.
    result = _generic( name   = `SimpleForm`
                       ns     = `form`
                       t_prop = VALUE #( ( n = `title`    v = title )
                                         ( n = `layout`   v = layout )
                                         ( n = `adjustLabelSpan`   v = adjustLabelSpan )
                                         ( n = `backgroundDesign`   v = backgroundDesign )
                                         ( n = `breakpointL`   v = breakpointL )
                                         ( n = `breakpointM`   v = breakpointM )
                                         ( n = `breakpointXL`   v = breakpointXL )
                                         ( n = `emptySpanL`   v = emptySpanL )
                                         ( n = `emptySpanM`   v = emptySpanM )
                                         ( n = `emptySpanS`   v = emptySpanS )
                                         ( n = `emptySpanXL`   v = emptySpanXL )
                                         ( n = `labelSpanL`   v = labelSpanL )
                                         ( n = `labelSpanM`   v = labelSpanM )
                                         ( n = `labelSpanS`   v = labelSpanS )
                                         ( n = `labelSpanXL`   v = labelSpanXL )
                                         ( n = `maxContainerCols`   v = maxContainerCols )
                                         ( n = `minWidth`   v = minWidth )
                                         ( n = `singleContainerFullSize`   v = z2ui5_cl_util_func=>boolean_abap_2_json( singleContainerFullSize ) )
                                         ( n = `visible`   v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `width`       v = width )
                                         ( n = `id`       v = id )
                                         ( n = `columnsXL`   v = columnsxl )
                                         ( n = `columnsL`   v = columnsl )
                                         ( n = `columnsM`   v = columnsm )
                                         ( n = `editable` v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) ) ) ).
  ENDMETHOD.


  METHOD slide_tile.

    result = _generic( name   = `SlideTile`
                       t_prop = VALUE #( ( n = `displayTime` v = displayTime )
                                         ( n = `height` v = height )
                                         ( n = `scope` v = scope )
                                         ( n = `sizeBehavior` v = sizeBehavior )
                                         ( n = `transitionTime` v = transitionTime )
                                         ( n = `width` v = width )
                                         ( n = `press` v = press )
                                         ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                       ) ).
  ENDMETHOD.


  METHOD smart_variant_management.
    result = _generic( name   = `SmartVariantManagement` ns = `svm`
                       t_prop = VALUE #( ( n = `id`      v = id )
                                         ( n = `showExecuteOnSelection`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showexecuteonselection ) ) ) ).
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
    result = _generic( name = `sortItems` ).
  ENDMETHOD.


  METHOD splitter_layout_data.
    result = _generic( name   = `SplitterLayoutData` ns = `layout`
                       t_prop = VALUE #( ( n = `size`         v = size )
                                         ( n = `minSize`      v = minsize )
                                         ( n = `resizable`    v = z2ui5_cl_util_func=>boolean_abap_2_json( resizable ) ) ) ).
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
    result = _generic( name   = `SplitPane` ns = `layout`
                       t_prop = VALUE #( ( n = `id`                   v = id )
                                         ( n = `requiredParentWidth`  v = requiredparentwidth )  ) ).
  ENDMETHOD.


  METHOD spot.

    result = me.
    _generic( name = `Spot`
                      ns    = `vbm`
                      t_prop = VALUE #(
                            ( n = `id`  v = id )
                            ( n = `position`  v = position )
                            ( n = `contentOffset`  v = contentoffset )
                            ( n = `type`  v = type )
                            ( n = `scale`  v = scale )
                            ( n = `tooltip`  v = tooltip )
                            ( n = `image`  v = image )
                            ( n = `icon`  v = icon )
                        ) ).

  ENDMETHOD.


  METHOD spots.

    result = _generic( name = `Spots`
                      ns    = `vbm`
                      t_prop = VALUE #(
                            ( n = `id`  v = id )
                            ( n = `items`  v = items )
                        ) ).

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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util_func=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `displayZeroValue`    v = z2ui5_cl_util_func=>boolean_abap_2_json( displayzerovalue ) )
                                ( n = `showLabels`    v = z2ui5_cl_util_func=>boolean_abap_2_json( showlabels ) )
                                ( n = `width`  v = width ) ) ).
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
                                ( n = `activeIcon`     v = activeicon )
                                ( n = `adaptTitleSize`     v = z2ui5_cl_util_func=>boolean_abap_2_json( adapttitlesize ) )
                                ( n = `unread`     v = z2ui5_cl_util_func=>boolean_abap_2_json( unread ) )
                                ( n = `iconInset`     v = z2ui5_cl_util_func=>boolean_abap_2_json( iconinset ) )
                                ( n = `infoStateInverted`     v = z2ui5_cl_util_func=>boolean_abap_2_json( infostateinverted ) )
                                ( n = `wrapping`     v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
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
                                ( n = `selected`    v = selected ) ) ).

  ENDMETHOD.


  METHOD statuses.
    result = _generic( name = `statuses` ns = ns ).
  ENDMETHOD.


  METHOD step_input.
    result = me.
    _generic( name   = `StepInput`
              t_prop = VALUE #( ( n = `max`  v = max )
                                ( n = `min`  v = min )
                                ( n = `step` v = step )
                                ( n = `value` v = value )
                                ( n = `valueState` v = valuestate )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `description` v = description ) ) ).
  ENDMETHOD.


  METHOD stringify.

    result = get_root( )->xml_get( ).

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


  METHOD switch.
    result = me.
    _generic( name   = `Switch`
              t_prop = VALUE #( ( n = `type`           v = type )
                                ( n = `enabled`        v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
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
                           ( n = `showSeparators`           v = showseparators )
                           ( n = `mode`             v = mode )
                           ( n = `inset`             v = inset )
                           ( n = `width`            v = width )
                           ( n = `id`            v = id )
                           ( n = `hiddenInPopin`            v = hiddeninpopin )
                           ( n = `popinLayout`            v = popinlayout )
                           ( n = `selectionChange`  v = selectionchange )
                           ( n = `backgroundDesign`  v = backgrounddesign )
                           ( n = `alternateRowColors`  v = z2ui5_cl_util_func=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `fixedLayout`  v = z2ui5_cl_util_func=>boolean_abap_2_json( fixedlayout ) )
                           ( n = `showOverlay`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showoverlay ) )
                           ( n = `autoPopinMode`  v = z2ui5_cl_util_func=>boolean_abap_2_json( autopopinmode ) ) ) ).
  ENDMETHOD.


  METHOD table_select_dialog.

    result = _generic( name   = `TableSelectDialog`
               t_prop = VALUE #( ( n = `confirmButtonText`    v = confirmbuttontext )
                                 ( n = `contentHeight`        v = contentheight )
                                 ( n = `contentWidth`         v = contentwidth )
                                 ( n = `draggable`            v = z2ui5_cl_util_func=>boolean_abap_2_json( draggable ) )
                                 ( n = `growing`              v = z2ui5_cl_util_func=>boolean_abap_2_json( growing ) )
                                 ( n = `growingThreshold`     v = growingthreshold )
                                 ( n = `multiSelect`          v = z2ui5_cl_util_func=>boolean_abap_2_json( multiselect ) )
                                 ( n = `noDataText`           v = nodatatext )
                                 ( n = `rememberSelections`   v = z2ui5_cl_util_func=>boolean_abap_2_json( rememberselections ) )
                                 ( n = `resizable`            v = z2ui5_cl_util_func=>boolean_abap_2_json( resizable ) )
                                 ( n = `searchPlaceholder`    v = searchplaceholder )
                                 ( n = `showClearButton`      v = z2ui5_cl_util_func=>boolean_abap_2_json( showclearbutton ) )
                                 ( n = `title`                v = title )
                                 ( n = `titleAlignment`       v = titlealignment )
                                 ( n = `items`                v = items )
                                 ( n = `search`               v = search )
                                 ( n = `confirm`              v = confirm )
                                 ( n = `cancel`               v = cancel )
                                 ( n = `liveChange`           v = livechange )
                                 ( n = `selectionChange`      v = selectionchange )
                                 ( n = `visible`              v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).
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
                                         ( n = `title` v = title )
                                         ( n = `showTitle` v = z2ui5_cl_util_func=>boolean_abap_2_json( showtitle ) )
                                         ( n = `color` v = color ) ) ).
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
                                ( n = `textDirection`  v = textdirection )
                                ( n = `width`  v = width )
                                ( n = `id`  v = id )
                                ( n = `wrapping`  v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
                                ( n = `wrappingType`  v = wrappingtype )
                                ( n = `class` v = class ) ) ).
  ENDMETHOD.


  METHOD text_area.
    result = me.
    _generic( name   = `TextArea`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `rows` v = rows )
                                ( n = `cols` v = cols )
                                ( n = `height` v = height )
                                ( n = `width` v = width )
                                ( n = `wrapping` v = wrapping )
                                ( n = `maxLength` v = maxLength )
                                ( n = `textAlign` v = textAlign )
                                ( n = `textDirection` v = textDirection )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util_func=>boolean_abap_2_json( showValueStateMessage ) )
                                ( n = `showExceededText` v = z2ui5_cl_util_func=>boolean_abap_2_json( showExceededText ) )
                                ( n = `valueLiveUpdate` v = z2ui5_cl_util_func=>boolean_abap_2_json( valueliveupdate ) )
                                ( n = `editable` v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                ( n = `class` v = class )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `id` v = id )
                                ( n = `growing` v = z2ui5_cl_util_func=>boolean_abap_2_json( growing ) )
                                ( n = `growingMaxLines` v = growingmaxlines )
                                ( n = `required`        v = required )
                                ( n = `valueState`      v = valuestate )
                                ( n = `placeholder`      v = placeholder )
                                ( n = `valueStateText`  v = valuestatetext ) ) ).
  ENDMETHOD.


  METHOD tile_content.

    result = _generic( name   = `TileContent`
                       ns     = ``
                       t_prop = VALUE #(
                                ( n = `unit`   v = unit )
                                ( n = `footerColor`   v = footerColor )
                                ( n = `blocked`   v = z2ui5_cl_util_func=>boolean_abap_2_json( blocked ) )
                                ( n = `frameType`   v = frameType )
                                ( n = `priority`   v = priority )
                                ( n = `priorityText`   v = priorityText )
                                ( n = `state`   v = state )
                                ( n = `disabled`   v = z2ui5_cl_util_func=>boolean_abap_2_json( disabled ) )
                                ( n = `visible`   v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `footer` v = footer ) ) ).

  ENDMETHOD.


  METHOD timeline.

    result = _generic( name   = `Timeline`
                       ns     = 'commons'
                       t_prop = VALUE #( ( n = 'id'                 v = id )
                                         ( n = 'enableDoubleSided'  v = z2ui5_cl_util_func=>boolean_abap_2_json( enabledoublesided ) )
                                         ( n = 'groupBy'            v = groupby )
                                         ( n = 'growingThreshold'   v = growingthreshold )
                                         ( n = 'filterTitle'        v = filtertitle )
                                         ( n = 'sortOldestFirst'    v = z2ui5_cl_util_func=>boolean_abap_2_json( sortoldestfirst ) )
                                         ( n = 'enableModelFilter'  v = z2ui5_cl_util_func=>boolean_abap_2_json( enableModelFilter ) )
                                         ( n = 'enableScroll'       v = z2ui5_cl_util_func=>boolean_abap_2_json( enableScroll ) )
                                         ( n = 'forceGrowing'       v = z2ui5_cl_util_func=>boolean_abap_2_json( forceGrowing ) )
                                         ( n = 'group'              v = z2ui5_cl_util_func=>boolean_abap_2_json( group ) )
                                         ( n = 'lazyLoading'        v = z2ui5_cl_util_func=>boolean_abap_2_json( lazyLoading ) )
                                         ( n = 'showHeaderBar'      v = z2ui5_cl_util_func=>boolean_abap_2_json( showHeaderBar ) )
                                         ( n = 'showIcons'          v = z2ui5_cl_util_func=>boolean_abap_2_json( showIcons ) )
                                         ( n = 'showItemFilter'     v = z2ui5_cl_util_func=>boolean_abap_2_json( showItemFilter ) )
                                         ( n = 'showSearch'         v = z2ui5_cl_util_func=>boolean_abap_2_json( showSearch ) )
                                         ( n = 'showSort'           v = z2ui5_cl_util_func=>boolean_abap_2_json( showSort ) )
                                         ( n = 'showTimeFilter'     v = z2ui5_cl_util_func=>boolean_abap_2_json( showTimeFilter ) )
                                         ( n = 'sort'               v = z2ui5_cl_util_func=>boolean_abap_2_json( sort ) )
                                         ( n = 'groupByType'        v = groupByType )
                                         ( n = 'textHeight'         v = textHeight )
                                         ( n = 'width'              v = width )
                                         ( n = 'height'             v = height )
                                         ( n = 'noDataText'         v = noDataText )
                                         ( n = 'alignment'          v = alignment )
                                         ( n = 'axisOrientation'    v = axisorientation )
                                         ( n = 'filterList'         v = filterList )
                                         ( n = 'customFilter'       v = customFilter )
                                         ( n = 'content'            v = content ) ) ).
  ENDMETHOD.


  METHOD timeline_item.

    result = _generic( name   = `TimelineItem`
                       ns     = 'commons'
                       t_prop = VALUE #( ( n = 'id'                     v = id )
                                         ( n = 'dateTime'               v = datetime )
                                         ( n = 'title'                  v = title )
                                         ( n = 'userNameClickable'      v = z2ui5_cl_util_func=>boolean_abap_2_json( usernameclickable ) )
                                         ( n = 'useIconTooltip'         v = z2ui5_cl_util_func=>boolean_abap_2_json( useIconTooltip ) )
                                         ( n = 'userNameClicked'        v = usernameclicked )
                                         ( n = 'userPicture'            v = userPicture )
                                         ( n = 'select'                 v = select )
                                         ( n = 'text'                   v = text )
                                         ( n = 'userName'               v = username )
                                         ( n = 'filterValue'            v = filtervalue )
                                         ( n = 'iconDisplayShape'       v = iconDisplayShape )
                                         ( n = 'iconInitials'           v = iconInitials )
                                         ( n = 'iconSize'               v = iconSize )
                                         ( n = 'iconTooltip'            v = iconTooltip )
                                         ( n = 'maxCharacters'          v = maxCharacters )
                                         ( n = 'replyCount'             v = replyCount )
                                         ( n = 'status'                 v = status )
                                         ( n = 'customActionClicked'    v = customActionClicked )
                                         ( n = 'press'                  v = press )
                                         ( n = 'replyListOpen'          v = replyListOpen )
                                         ( n = 'replyPost'              v = replyPost )
                                         ( n = 'icon'                   v = icon ) ) ).
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
                                ( n = `dateValue`  v = datevalue )
                                ( n = `localeId`  v = localeid )
                                ( n = `placeholder`  v = placeholder )
                                ( n = `mask`  v = mask )
                                ( n = `maskMode`  v = maskMode )
                                ( n = `minutesStep`  v = minutesStep )
                                ( n = `name`  v = name )
                                ( n = `placeholderSymbol`  v = placeholderSymbol )
                                ( n = `secondsStep`  v = secondsStep )
                                ( n = `textAlign`  v = textAlign )
                                ( n = `textDirection`  v = textDirection )
                                ( n = `title`  v = title )
                                ( n = `showCurrentTimeButton` v = z2ui5_cl_util_func=>boolean_abap_2_json( showCurrentTimeButton ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util_func=>boolean_abap_2_json( showValueStateMessage ) )
                                ( n = `support2400` v = z2ui5_cl_util_func=>boolean_abap_2_json( support2400 ) )
                                ( n = `initialFocusedDateValue` v = z2ui5_cl_util_func=>boolean_abap_2_json( initialfocuseddatevalue ) )
                                ( n = `hideInput` v = z2ui5_cl_util_func=>boolean_abap_2_json( hideinput ) )
                                ( n = `editable` v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                ( n = `required` v = z2ui5_cl_util_func=>boolean_abap_2_json( required ) )
                                ( n = `visible` v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                ( n = `width` v = width )
                                ( n = `valueState` v = valuestate )
                                ( n = `valueStateText` v = valueStateText )
                                ( n = `displayFormat` v = displayformat )
                                ( n = `afterValueHelpClose` v = afterValueHelpClose )
                                ( n = `afterValueHelpOpen` v = afterValueHelpOpen )
                                ( n = `change` v = change )
                                ( n = `liveChange` v = liveChange )
                                ( n = `valueFormat` v = valueformat ) ) ).
  ENDMETHOD.


  METHOD title.
    DATA(lv_name) = COND #( WHEN ns = 'f' THEN 'title' ELSE `Title` ).


    result = me.
    _generic( ns     = COND #( WHEN level IS NOT INITIAL THEN `webc` ELSE ns )
              name   = lv_name
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `class`     v = class )
                                ( n = `id`     v = id )
                                ( n = `wrapping` v = z2ui5_cl_util_func=>boolean_abap_2_json( wrapping ) )
                                ( n = `level` v = level ) ) ).
  ENDMETHOD.


  METHOD toggle_button.

    result = me.
    _generic( name   = `ToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
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

    result = _generic( name = `tokens` ns = ns ).

  ENDMETHOD.


  METHOD toolbar.

    result = _generic( name = `Toolbar`
                       ns = ns
                       t_prop = VALUE #( ( n = `active`  v = z2ui5_cl_util_func=>boolean_abap_2_json( active ) )
                                         ( n = `ariaHasPopup`  v = ariaHasPopup )
                                         ( n = `design`  v = design )
                                         ( n = `enabled`  v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `height`  v = height )
                                         ( n = `style`  v = style )
                                         ( n = `width`  v = width )
                                         ( n = `id`  v = id )
                                         ( n = `press`  v = press ) ) ).

  ENDMETHOD.


  METHOD toolbar_spacer.

    result = me.
    _generic( name = `ToolbarSpacer`
              ns   = ns ).

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
    result = _generic( name   = `Tree`
                       t_prop = VALUE #(
                           ( n = `items`            v = items )
                           ( n = `headerText`       v = headertext )
                           ( n = `footerText`       v = footertext )
                           ( n = `mode`             v = mode )
                           ( n = `width`            v = width )
                           ( n = `includeItemInSelection`  v = z2ui5_cl_util_func=>boolean_abap_2_json( includeiteminselection ) )
                           ( n = `inset`  v = z2ui5_cl_util_func=>boolean_abap_2_json( inset ) )
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
                                        ( n = `selectionBehavior`       v = selectionbehavior )
                                        ( n = `id`                      v = id )
                                        ( n = `selectedIndex`           v = selectedindex ) ) ).
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
                          ( n = `showSortMenuEntry`    v = showsortmenuentry )
                          ( n = `sortProperty`         v = sortproperty )
                          ( n = `showFilterMenuEntry`  v = showfiltermenuentry )
                          ( n = `autoresizable`  v =  z2ui5_cl_util_func=>boolean_abap_2_json( autoresizable ) )
                          ( n = `filterProperty`       v = filterproperty ) ) ).
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
                          ( n = `type`     v = type )
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
                           ( n = `alternateRowColors`        v = z2ui5_cl_util_func=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `columnHeaderVisible`       v = columnheadervisible )
                           ( n = `editable`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( editable ) )
                           ( n = `enableCellFilter`          v = z2ui5_cl_util_func=>boolean_abap_2_json( enablecellfilter ) )
                           ( n = `enableGrouping`            v = z2ui5_cl_util_func=>boolean_abap_2_json( enablegrouping ) )
                           ( n = `senableSelectAll`          v = z2ui5_cl_util_func=>boolean_abap_2_json( enableselectall ) )
                           ( n = `firstVisibleRow`           v = firstvisiblerow )
                           ( n = `fixedBottomRowCount`       v = fixedbottomrowcount )
                           ( n = `fixedColumnCount`          v = fixedcolumncount )
                           ( n = `rowActionCount`            v = rowactioncount )
                           ( n = `fixedRowCount`             v = fixedrowcount )
                           ( n = `minAutoRowCount`           v = minautorowcount )
                           ( n = `minAutoRowCount`           v = minautorowcount )
                           ( n = `rowHeight`                 v = rowheight )
                           ( n = `selectedIndex`             v = selectedindex )
                           ( n = `selectionMode`             v = selectionmode )
                           ( n = `showColumnVisibilityMenu`  v = z2ui5_cl_util_func=>boolean_abap_2_json( showcolumnvisibilitymenu ) )
                           ( n = `showNoData`                v = z2ui5_cl_util_func=>boolean_abap_2_json( shownodata ) )
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
                            ) ).

  ENDMETHOD.


  METHOD ui_template.

    result = _generic( name = `template`
                       ns   = 'table' ).

  ENDMETHOD.


  METHOD upload_set.
    result = _generic( name   = `UploadSet`
                       ns     = 'upload'
                       t_prop = VALUE #( ( n = `id`                       v = id )
                                         ( n = `instantUpload`            v = z2ui5_cl_util_func=>boolean_abap_2_json( instantupload ) )
                                         ( n = `showIcons`                v = z2ui5_cl_util_func=>boolean_abap_2_json( showicons ) )
                                         ( n = `uploadEnabled`            v = z2ui5_cl_util_func=>boolean_abap_2_json( uploadenabled ) )
                                         ( n = `terminationEnabled`       v = z2ui5_cl_util_func=>boolean_abap_2_json( terminationenabled ) )
                                         ( n = `uploadButtonInvisible`    v = z2ui5_cl_util_func=>boolean_abap_2_json( uploadbuttoninvisible ) )
                                         ( n = `fileTypes`                v = filetypes )
                                         ( n = `maxFileNameLength`        v = maxfilenamelength )
                                         ( n = `maxFileSize`              v = maxfilesize )
                                         ( n = `mediaTypes`               v = mediatypes )
                                         ( n = `items`                    v = items )
                                         ( n = `uploadUrl`                v = uploadurl )
                                         ( n = `mode`                     v = mode )
                                         ( n = `fileRenamed`              v = filerenamed )
                                         ( n = `directory`                v = z2ui5_cl_util_func=>boolean_abap_2_json( directory ) )
                                         ( n = `multiple`                 v = z2ui5_cl_util_func=>boolean_abap_2_json( multiple ) )
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
                                         ( n = `sameFilenameAllowed`      v = z2ui5_cl_util_func=>boolean_abap_2_json( samefilenameallowed ) )
                                         ( n = `selectionChanged`         v = selectionchanged ) ) ).
  ENDMETHOD.


  METHOD upload_set_item.
    result = _generic( name   = `UploadSetItem`
                   ns     = 'upload'
                   t_prop = VALUE #( ( n = `fileName`      v = filename )
                                     ( n = `mediaType`     v = mediatype )
                                     ( n = `url`           v = url )
                                     ( n = `thumbnailUrl`  v = thumbnailurl )
                                     ( n = `markers`       v = markers )
                                     ( n = `enabledEdit`   v = z2ui5_cl_util_func=>boolean_abap_2_json( enablededit ) )
                                     ( n = `enabledRemove` v = z2ui5_cl_util_func=>boolean_abap_2_json( enabledremove ) )
                                     ( n = `selected`      v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                     ( n = `visibleEdit`   v = z2ui5_cl_util_func=>boolean_abap_2_json( visibleedit ) )
                                     ( n = `visibleRemove` v = z2ui5_cl_util_func=>boolean_abap_2_json( visibleremove ) )
                                     ( n = `uploadState`   v = uploadstate )
                                     ( n = `uploadUrl`     v = uploadurl )
                                     ( n = `openPressed`   v = openpressed )
                                     ( n = `removePressed` v = removepressed )
                                     ( n = `statuses`      v = statuses ) ) ).
  ENDMETHOD.


  METHOD upload_set_toolbar_placeholder.
    result = _generic( name = `UploadSetToolbarPlaceholder` ns = `upload` ).
  ENDMETHOD.


  METHOD variant_item.

    result = _generic( name   = `VariantItem`
                         ns     = `vm`
                         t_prop = VALUE #( ( n = `executeOnSelection`      v = z2ui5_cl_util_func=>boolean_abap_2_json( executeonselection ) )
                                           ( n = `global`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( global ) )
                                           ( n = `labelReadOnly`           v = z2ui5_cl_util_func=>boolean_abap_2_json( labelreadonly ) )
                                           ( n = `lifecyclePackage`        v = lifecyclepackage )
                                           ( n = `lifecycleTransportId`    v = lifecycletransportid )
                                           ( n = `namespace`               v = namespace )
                                           ( n = `readOnly`                v = readonly )
                                           ( n = `executeOnSelect`         v = z2ui5_cl_util_func=>boolean_abap_2_json( executeonselect ) )
                                           ( n = `author`                  v = author )
                                           ( n = `changeable`              v = z2ui5_cl_util_func=>boolean_abap_2_json( changeable ) )
                                           ( n = `enabled`                 v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                           ( n = `favorite`                v = z2ui5_cl_util_func=>boolean_abap_2_json( favorite ) )
                                           ( n = `key`                     v = key )
                                           ( n = `text`                    v = text )
                                           ( n = `title`                   v = title )
                                           ( n = `textDirection`           v = textdirection )
                                           ( n = `originalTitle`           v = originaltitle )
                                           ( n = `originalExecuteOnSelect` v = z2ui5_cl_util_func=>boolean_abap_2_json( originalexecuteonselect ) )
                                           ( n = `remove`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( remove ) )
                                           ( n = `rename`                  v = z2ui5_cl_util_func=>boolean_abap_2_json( rename ) )
                                           ( n = `originalFavorite`        v = z2ui5_cl_util_func=>boolean_abap_2_json( originalfavorite ) )
                                           ( n = `sharing`                 v = z2ui5_cl_util_func=>boolean_abap_2_json( sharing ) )
                                           ( n = `change`                  v = change ) ) ).

  ENDMETHOD.


  METHOD variant_items.

    result = _generic( name   = `variantItems`
                         ns     = `vm` ).

  ENDMETHOD.


  METHOD variant_management.

    result = _generic( name   = `VariantManagement`
                       ns     = `vm`
                       t_prop = VALUE #( ( n = `defaultVariantKey`      v = defaultvariantkey )
                                         ( n = `enabled`                v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `inErrorState`           v = z2ui5_cl_util_func=>boolean_abap_2_json( inerrorstate ) )
                                         ( n = `initialSelectionKey`    v = initialselectionkey )
                                         ( n = `lifecycleSupport`       v = z2ui5_cl_util_func=>boolean_abap_2_json( lifecyclesupport ) )
                                         ( n = `selectionKey`           v = selectionkey )
                                         ( n = `showCreateTile`         v = z2ui5_cl_util_func=>boolean_abap_2_json( showcreatetile ) )
                                         ( n = `showExecuteOnSelection` v = z2ui5_cl_util_func=>boolean_abap_2_json( showexecuteonselection ) )
                                         ( n = `showSetAsDefault`       v = z2ui5_cl_util_func=>boolean_abap_2_json( showsetasdefault ) )
                                         ( n = `showShare`              v = z2ui5_cl_util_func=>boolean_abap_2_json( showshare ) )
                                         ( n = `standardItemAuthor`     v = standarditemauthor )
                                         ( n = `standardItemText`       v = standarditemtext )
                                         ( n = `useFavorites`           v = z2ui5_cl_util_func=>boolean_abap_2_json( usefavorites ) )
                                         ( n = `variantItems`           v = variantitems )
                                         ( n = `manage`                 v = manage )
                                         ( n = `save`                   v = save )
                                         ( n = `select`                 v = select )
                                         ( n = `id`                     v = id )
                                         ( n = `variantCreationByUserAllowed` v = uservarcreate )
                                         ( n = `visible`                v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.


  METHOD variant_management_fl.
    result = _generic( name   = `VariantManagement`
                       ns     = `flvm`
                       t_prop = VALUE #( ( n = `displayTextForExecuteOnSelectionForStandardVariant`  v = displaytextfsv )
                                         ( n = `editable`       v = z2ui5_cl_util_func=>boolean_abap_2_json( editable )  )
                                         ( n = `executeOnSelectionForStandardDefault`        v = z2ui5_cl_util_func=>boolean_abap_2_json( executeonselectionforstandflt ) )
                                         ( n = `headerLevel`      v = headerlevel )
                                         ( n = `inErrorState`      v = z2ui5_cl_util_func=>boolean_abap_2_json( inerrorstate ) )
                                         ( n = `maxWidth`      v = maxwidth )
                                         ( n = `modelName`      v = modelname )
                                         ( n = `resetOnContextChange`      v = z2ui5_cl_util_func=>boolean_abap_2_json( resetoncontextchange ) )
                                         ( n = `showSetAsDefault`      v = z2ui5_cl_util_func=>boolean_abap_2_json( showsetasdefault ) )
                                         ( n = `titleStyle`      v = titlestyle )
                                         ( n = `updateVariantInURL`    v = z2ui5_cl_util_func=>boolean_abap_2_json( updatevariantinurl ) )
                                         ( n = `cancel`    v = cancel )
                                         ( n = `initialized`    v = initialized )
                                         ( n = `manage`    v = manage )
                                         ( n = `save`    v = save )
                                         ( n = `select`    v = select )
                                         ( n = `for`  v = for ) ) ).
  ENDMETHOD.


  METHOD vbox.

    result = _generic( name   = `VBox`
                       t_prop = VALUE #( ( n = `height`          v = height )
                                         ( n = `id`  v = id )
                                         ( n = `justifyContent`  v = justifycontent )
                                         ( n = `renderType`      v = rendertype )
                                         ( n = `alignContent`    v = aligncontent )
                                         ( n = `alignItems`      v = alignitems )
                                         ( n = `width`           v = width )
                                         ( n = `wrap`            v = wrap )
                                         ( n = `backgroundDesign`            v = backgroundDesign )
                                         ( n = `direction`            v = direction )
                                         ( n = `displayInline`            v = z2ui5_cl_util_func=>boolean_abap_2_json( displayInline ) )
                                         ( n = `visible`            v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `fitContainer`            v = z2ui5_cl_util_func=>boolean_abap_2_json( fitContainer ) )
                                         ( n = `class`           v = class ) ) ).

  ENDMETHOD.


  METHOD vertical_layout.

    result = _generic( name   = `VerticalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `visible`  v = z2ui5_cl_util_func=>boolean_abap_2_json( visible ) )
                                         ( n = `enabled`  v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                         ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD view_settings_dialog.

    result = _generic( name   = `ViewSettingsDialog`
              t_prop = VALUE #( ( n = `confirm`                  v = confirm )
                                ( n = `cancel`                   v = cancel )
                                ( n = `filterDetailPageOpened`   v = filterdetailpageopened )
                                ( n = `reset`                    v = reset )
                                ( n = `resetFilters`             v = resetfilters )
                                ( n = `filterSearchOperator`     v = filtersearchoperator )
                                ( n = `groupDescending`          v = z2ui5_cl_util_func=>boolean_abap_2_json( groupdescending ) )
                                ( n = `sortDescending`           v = z2ui5_cl_util_func=>boolean_abap_2_json( sortdescending ) )
                                ( n = `title`                    v = title )
                                ( n = `selectedGroupItem`        v = selectedgroupitem )
                                ( n = `selectedPresetFilterItem` v = selectedpresetfilteritem )
                                ( n = `selectedSortItem`         v = selectedsortitem )
                                ( n = `selectedSortItem`         v = selectedsortitem )
                                ( n = `filterItems`              v = filteritems )
                                ( n = `sortItems`                v = sortitems )
                                ( n = `groupItems`               v = groupitems )
                                ( n = `titleAlignment`           v = titlealignment ) ) ).

  ENDMETHOD.


  METHOD view_settings_filter_item.
    result = _generic( name   = `ViewSettingsFilterItem`
                  t_prop = VALUE #( ( n = `enabled`         v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                    ( n = `key`             v = key )
                                    ( n = `selected`        v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                    ( n = `text`            v = text )
                                    ( n = `textDirection`   v = textdirection )
                                    ( n = `multiSelect`     v = z2ui5_cl_util_func=>boolean_abap_2_json( multiselect ) ) ) ).
  ENDMETHOD.


  METHOD view_settings_item.
    result = _generic( name   = `ViewSettingsItem`
                  t_prop = VALUE #( ( n = `enabled`         v = z2ui5_cl_util_func=>boolean_abap_2_json( enabled ) )
                                    ( n = `key`             v = key )
                                    ( n = `selected`        v = z2ui5_cl_util_func=>boolean_abap_2_json( selected ) )
                                    ( n = `text`            v = text )
                                    ( n = `textDirection`   v = textdirection ) ) ).

  ENDMETHOD.


  METHOD visible_horizon.
    result = _generic( name = `visibleHorizon`
                       ns   = `axistime` ).
  ENDMETHOD.


  METHOD vos.

    result = _generic( name = `vos`
                      ns    = `vbm`
                  ).

  ENDMETHOD.


  METHOD xml_get.

    CASE mv_name.
      WHEN `ZZPLAIN`.
        result = mt_prop[ n = `VALUE` ]-v.
        RETURN.
    ENDCASE.

    IF me = mo_root.
      DATA lt_prop TYPE z2ui5_if_client=>ty_t_name_value.



      lt_prop = VALUE #(
*                      ( n = `xmlns`           v = `sap.m` )
                      ( n = `xmlns:z2ui5`     v = `z2ui5` )
*                      ( n = `xmlns:core`      v = `sap.ui.core` )
*                      ( n = `xmlns:mvc`       v = `sap.ui.core.mvc` )
                      ( n = `xmlns:layout`    v = `sap.ui.layout` )
*                       ( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` )
*                       ( n = `core:require` v = `{ URLHelper: 'sap/m/library/URLHelper' }` )
                      ( n = `xmlns:table`    v = `sap.ui.table` )
                      ( n = `xmlns:f`         v = `sap.f` )
                      ( n = `xmlns:form`      v = `sap.ui.layout.form` )
                      ( n = `xmlns:editor`    v = `sap.ui.codeeditor` )
                      ( n = `xmlns:mchart`    v = `sap.suite.ui.microchart` )
                      ( n = `xmlns:webc`      v = `sap.ui.webc.main` )
                      ( n = `xmlns:uxap`      v = `sap.uxap` )
                      ( n = `xmlns:sap`       v = `sap` )
                      ( n = `xmlns:text`      v = `sap.ui.richtexteditor` )
                      ( n = `xmlns:html`      v = `http://www.w3.org/1999/xhtml` )
                      ( n = `xmlns:fb`        v = `sap.ui.comp.filterbar` )
                      ( n = `xmlns:u`         v = `sap.ui.unified` )
                      ( n = `xmlns:gantt`     v = `sap.gantt.simple` )
                      ( n = `xmlns:axistime`  v = `sap.gantt.axistime` )
                      ( n = `xmlns:config`    v = `sap.gantt.config` )
                      ( n = `xmlns:shapes`    v = `sap.gantt.simple.shapes` )
                      ( n = `xmlns:commons`   v = `sap.suite.ui.commons` )
                      ( n = `xmlns:vm`        v = `sap.ui.comp.variants` )
                      ( n = `xmlns:viz`        v = `sap.viz.ui5.controls` )
                      ( n = `xmlns:vk`        v = `sap.ui.vk` )
                      ( n = `xmlns:vbm`        v = `sap.ui.vbm` )
                      ( n = `xmlns:ndc`        v = `sap.ndc` )
                      ( n = `xmlns:svm`       v = `sap.ui.comp.smartvariants` )
                      ( n = `xmlns:flvm`      v = `sap.ui.fl.variants` )
                      ( n = `xmlns:p13n`      v = `sap.m.p13n` )
                      ( n = `xmlns:upload`    v = `sap.m.upload` )
                      ( n = `xmlns:fl`        v = `sap.ui.fl` )
                      ( n = `xmlns:tnt`      v = `sap.tnt` ) ).

      LOOP AT mt_ns REFERENCE INTO DATA(lr_ns).

        LOOP AT lt_prop REFERENCE INTO DATA(lr_prop).

          DATA(ns) = lr_prop->n+6.
          IF ns = lr_ns->*.
          try.
            INSERT lr_prop->* INTO TABLE mt_prop.
            catch cx_root.
            endtry.
            DELETE lt_prop.
            EXIT.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM mt_prop COMPARING n.
    ENDIF.

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


  METHOD _cc_plain_xml.

    result = me.
    _generic( name   = `ZZPLAIN`
              t_prop = VALUE #( ( n = `VALUE` v = val ) ) ).

  ENDMETHOD.


  METHOD _generic.

    TRY.
        INSERT CONV #( ns ) INTO TABLE mo_root->mt_ns.
      CATCH cx_root.
    ENDTRY.

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


  METHOD _generic_property.

    INSERT val INTO TABLE mt_prop.
    result = me.

  ENDMETHOD.


  METHOD _Z2UI5.

    result = new #( me ).

  ENDMETHOD.
ENDCLASS.
