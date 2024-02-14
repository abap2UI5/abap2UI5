CLASS z2ui5_cl_xml_view DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED .

  PUBLIC SECTION.

    CLASS-METHODS factory
      IMPORTING
        !t_ns         TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS factory_plain
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS factory_popup
      IMPORTING
        !t_ns         TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS constructor.

    METHODS horizontal_layout
      IMPORTING
        !class         TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !allowwrapping TYPE clike OPTIONAL
        !id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS icon
      IMPORTING
        !src                   TYPE clike OPTIONAL
        !press                 TYPE clike OPTIONAL
        !size                  TYPE clike OPTIONAL
        !color                 TYPE clike OPTIONAL
        !class                 TYPE clike OPTIONAL
        !id                    TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !useicontooltip        TYPE clike OPTIONAL
        !notabstop             TYPE clike OPTIONAL
        !hovercolor            TYPE clike OPTIONAL
        !hoverbackgroundcolor  TYPE clike OPTIONAL
        !height                TYPE clike OPTIONAL
        !decorative            TYPE clike OPTIONAL
        !backgroundcolor       TYPE clike OPTIONAL
        !alt                   TYPE clike OPTIONAL
        !activecolor           TYPE clike OPTIONAL
        !activebackgroundcolor TYPE clike OPTIONAL
        !visible               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS dynamic_page
      IMPORTING
        !headerexpanded           TYPE clike OPTIONAL
        !showfooter               TYPE clike OPTIONAL
        !headerpinned             TYPE clike OPTIONAL
        !toggleheaderontitleclick TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view .
    METHODS dynamic_page_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS dynamic_page_header
      IMPORTING
        !pinnable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS html
      IMPORTING
        !content         TYPE clike OPTIONAL
        !afterrendering  TYPE clike OPTIONAL
        !preferdom       TYPE clike OPTIONAL
        !sanitizecontent TYPE clike OPTIONAL
        !visible         TYPE clike OPTIONAL
        !id              TYPE clike OPTIONAL
          PREFERRED PARAMETER content
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.
    METHODS illustrated_message
      IMPORTING
        !enableverticalresponsiveness TYPE clike OPTIONAL
        !enableformattedtext          TYPE clike OPTIONAL
        !illustrationtype             TYPE clike OPTIONAL
        !title                        TYPE clike OPTIONAL
        !description                  TYPE clike OPTIONAL
        !illustrationsize             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view.

    METHODS additional_content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS flex_box
      IMPORTING
        !class            TYPE clike OPTIONAL
        !rendertype       TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !fitcontainer     TYPE clike OPTIONAL
        !height           TYPE clike OPTIONAL
        !alignitems       TYPE clike OPTIONAL
        !justifycontent   TYPE clike OPTIONAL
        !wrap             TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
        !direction        TYPE clike OPTIONAL
        !displayinline    TYPE clike OPTIONAL
        !backgrounddesign TYPE clike OPTIONAL
        !aligncontent     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS popover
      IMPORTING
        !title         TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
        !placement     TYPE clike OPTIONAL
        !initialfocus  TYPE clike OPTIONAL
        !contentwidth  TYPE clike OPTIONAL
        !contentheight TYPE clike OPTIONAL
        !showheader    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS list_item
      IMPORTING
        !text           TYPE clike OPTIONAL
        !additionaltext TYPE clike OPTIONAL
        !key            TYPE clike OPTIONAL
        !icon           TYPE clike OPTIONAL
        !enabled        TYPE clike OPTIONAL
        !textdirection  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS table
      IMPORTING
        !id                  TYPE clike OPTIONAL
        !items               TYPE clike OPTIONAL
        !growing             TYPE clike OPTIONAL
        !growingthreshold    TYPE clike OPTIONAL
        !growingscrolltoload TYPE clike OPTIONAL
        !headertext          TYPE clike OPTIONAL
        !sticky              TYPE clike OPTIONAL
        !mode                TYPE clike OPTIONAL
        !width               TYPE clike OPTIONAL
        !selectionchange     TYPE clike OPTIONAL
        !alternaterowcolors  TYPE clike OPTIONAL
        !autopopinmode       TYPE clike OPTIONAL
        !inset               TYPE clike OPTIONAL
        !showseparators      TYPE clike OPTIONAL
        !showoverlay         TYPE clike OPTIONAL
        !hiddeninpopin       TYPE clike OPTIONAL
        !popinlayout         TYPE clike OPTIONAL
        !fixedlayout         TYPE clike OPTIONAL
        !backgrounddesign    TYPE clike OPTIONAL
        !visible             TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_strip
      IMPORTING
        !text         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !showicon     TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS footer
      IMPORTING
        !ns           TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_page
      IMPORTING
        !show_header         TYPE clike OPTIONAL
        !text                TYPE clike OPTIONAL
        !enableformattedtext TYPE clike OPTIONAL
        !description         TYPE clike OPTIONAL
        !icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_page_layout
      IMPORTING
        !showtitleinheadercontent TYPE clike OPTIONAL
        !showeditheaderbutton     TYPE clike OPTIONAL
        !editheaderbuttonpress    TYPE clike OPTIONAL
        !uppercaseanchorbar       TYPE clike OPTIONAL
        !showfooter               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_page_dyn_header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS generic_tile
      IMPORTING
        !class                  TYPE clike OPTIONAL
        !id                     TYPE clike OPTIONAL
        !header                 TYPE clike OPTIONAL
        !mode                   TYPE clike OPTIONAL
        !additionaltooltip      TYPE clike OPTIONAL
        !appshortcut            TYPE clike OPTIONAL
        !backgroundcolor        TYPE clike OPTIONAL
        !backgroundimage        TYPE clike OPTIONAL
        !dropareaoffset         TYPE clike OPTIONAL
        !press                  TYPE clike OPTIONAL
        !frametype              TYPE clike OPTIONAL
        !failedtext             TYPE clike OPTIONAL
        !headerimage            TYPE clike OPTIONAL
        !scope                  TYPE clike OPTIONAL
        !sizebehavior           TYPE clike OPTIONAL
        !state                  TYPE clike OPTIONAL
        !systeminfo             TYPE clike OPTIONAL
        !tilebadge              TYPE clike OPTIONAL
        !tileicon               TYPE clike OPTIONAL
        !url                    TYPE clike OPTIONAL
        !valuecolor             TYPE clike OPTIONAL
        !width                  TYPE clike OPTIONAL
        !wrappingtype           TYPE clike OPTIONAL
        !imagedescription       TYPE clike OPTIONAL
        !navigationbuttontext   TYPE clike OPTIONAL
        !visible                TYPE clike OPTIONAL
        !renderonthemechange    TYPE clike OPTIONAL
        !enablenavigationbutton TYPE clike OPTIONAL
        !pressenabled           TYPE clike OPTIONAL
        !iconloaded             TYPE clike OPTIONAL
        !subheader              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS numeric_content
      IMPORTING
        !value             TYPE clike OPTIONAL
        !icon              TYPE clike OPTIONAL
        !withmargin        TYPE clike OPTIONAL
        !adaptivefontsize  TYPE clike OPTIONAL
        !animatetextchange TYPE clike OPTIONAL
        !formattervalue    TYPE clike OPTIONAL
        !icondescription   TYPE clike OPTIONAL
        !indicator         TYPE clike OPTIONAL
        !nullifyvalue      TYPE clike OPTIONAL
        !scale             TYPE clike OPTIONAL
        !state             TYPE clike OPTIONAL
        !truncatevalueto   TYPE clike OPTIONAL
        !valuecolor        TYPE clike OPTIONAL
        !visible           TYPE clike OPTIONAL
        !width             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS link_tile_content
      IMPORTING
        !linkhref     TYPE clike OPTIONAL
        !linktext     TYPE clike OPTIONAL
        !iconsrc      TYPE clike OPTIONAL
        !linkpress    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS image_content
      IMPORTING
        !src          TYPE clike OPTIONAL
        !description  TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS tile_content
      IMPORTING
        !unit         TYPE clike OPTIONAL
        !footercolor  TYPE clike OPTIONAL
        !blocked      TYPE clike OPTIONAL
        !frametype    TYPE clike OPTIONAL
        !priority     TYPE clike OPTIONAL
        !prioritytext TYPE clike OPTIONAL
        !state        TYPE clike OPTIONAL
        !disabled     TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
        !footer       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS expanded_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS snapped_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS expanded_content
      IMPORTING
        !ns           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS snapped_content
      IMPORTING
        !ns           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS heading
      IMPORTING
        !ns           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS actions
      IMPORTING
        !ns           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS snapped_title_on_mobile
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS header
      IMPORTING
        !ns           TYPE clike DEFAULT `f`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS navigation_actions
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS avatar
      IMPORTING
        !src               TYPE clike OPTIONAL
        !class             TYPE clike OPTIONAL
        !displaysize       TYPE clike OPTIONAL
        !ariahaspopup      TYPE clike OPTIONAL
        !backgroundcolor   TYPE clike OPTIONAL
        !badgeicon         TYPE clike OPTIONAL
        !badgetooltip      TYPE clike OPTIONAL
        !badgevaluestate   TYPE clike OPTIONAL
        !customdisplaysize TYPE clike OPTIONAL
        !customfontsize    TYPE clike OPTIONAL
        !displayshape      TYPE clike OPTIONAL
        !fallbackicon      TYPE clike OPTIONAL
        !imagefittype      TYPE clike OPTIONAL
        !initials          TYPE clike OPTIONAL
        !showborder        TYPE clike OPTIONAL
        !decorative        TYPE clike OPTIONAL
        !enabled           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_page_section
      IMPORTING
        !titleuppercase TYPE clike OPTIONAL
        !title          TYPE clike OPTIONAL
        !importance     TYPE clike OPTIONAL
        !id             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS sub_sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_page_sub_section
      IMPORTING
        !id           TYPE clike OPTIONAL
        !title        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS shell
      IMPORTING
        !ns             TYPE clike OPTIONAL
        appwidthlimited TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS blocks
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS layout_data
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS flex_item_data
      IMPORTING
        !growfactor       TYPE clike OPTIONAL
        !basesize         TYPE clike OPTIONAL
        !backgrounddesign TYPE clike OPTIONAL
        !styleclass       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS code_editor
      IMPORTING
        !value        TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !editable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS suggestion_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS suggestion_item
      IMPORTING
        !description   TYPE clike OPTIONAL
        !icon          TYPE clike OPTIONAL
        !key           TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS suggestion_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS suggestion_rows
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS vertical_layout
      IMPORTING
        !class        TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS multi_input
      IMPORTING
        !showclearicon    TYPE clike OPTIONAL
        !showvaluehelp    TYPE clike OPTIONAL
        !suggestionitems  TYPE clike OPTIONAL
        !tokenupdate      TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !value            TYPE clike OPTIONAL
        !tokens           TYPE clike OPTIONAL
        !submit           TYPE clike OPTIONAL
        !valuehelprequest TYPE clike OPTIONAL
        !enabled          TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !change           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS tokens
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS token
      IMPORTING
        !key          TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !selected     TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
        !editable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS input
      IMPORTING
        !id                            TYPE clike OPTIONAL
        !value                         TYPE clike OPTIONAL
        !placeholder                   TYPE clike OPTIONAL
        !type                          TYPE clike OPTIONAL
        !showclearicon                 TYPE clike OPTIONAL
        !valuestate                    TYPE clike OPTIONAL
        !valuestatetext                TYPE clike OPTIONAL
        !showtablesuggestionvaluehelp  TYPE clike OPTIONAL
        !description                   TYPE clike OPTIONAL
        !editable                      TYPE clike OPTIONAL
        !enabled                       TYPE clike OPTIONAL
        !suggestionitems               TYPE clike OPTIONAL
        !suggestionrows                TYPE clike OPTIONAL
        !showsuggestion                TYPE clike OPTIONAL
        !showvaluehelp                 TYPE clike OPTIONAL
        !valuehelprequest              TYPE clike OPTIONAL
        !required                      TYPE clike OPTIONAL
        !suggest                       TYPE clike OPTIONAL
        !class                         TYPE clike OPTIONAL
        !visible                       TYPE clike OPTIONAL
        !submit                        TYPE clike OPTIONAL
        !valueliveupdate               TYPE clike OPTIONAL
        !autocomplete                  TYPE clike OPTIONAL
        !maxsuggestionwidth            TYPE clike OPTIONAL
        !fieldwidth                    TYPE clike OPTIONAL
        !valuehelponly                 TYPE clike OPTIONAL
        !width                         TYPE clike OPTIONAL
        !change                        TYPE clike OPTIONAL
        !valuehelpiconsrc              TYPE clike OPTIONAL
        !textformatter                 TYPE clike OPTIONAL
        !textformatmode                TYPE clike OPTIONAL
        !maxlength                     TYPE clike OPTIONAL
        !startsuggestion               TYPE clike OPTIONAL
        !enablesuggestionshighlighting TYPE clike OPTIONAL
        !enabletableautopopinmode      TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view .
    METHODS dialog
      IMPORTING
        !title               TYPE clike OPTIONAL
        !icon                TYPE clike OPTIONAL
        !showheader          TYPE clike OPTIONAL
        !stretch             TYPE clike OPTIONAL
        !contentheight       TYPE clike OPTIONAL
        !contentwidth        TYPE clike OPTIONAL
        !resizable           TYPE clike OPTIONAL
        !horizontalscrolling TYPE clike OPTIONAL
        !verticalscrolling   TYPE clike OPTIONAL
        !afterclose          TYPE clike OPTIONAL
        !beforeopen          TYPE clike OPTIONAL
        !beforeclose         TYPE clike OPTIONAL
        !afteropen           TYPE clike OPTIONAL
        !draggable           TYPE clike OPTIONAL
        !closeonnavigation   TYPE clike OPTIONAL
        !escapehandler       TYPE clike OPTIONAL
        !type                TYPE clike OPTIONAL
        !titlealignment      TYPE clike OPTIONAL
        !state               TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS carousel
      IMPORTING
        !height                        TYPE clike OPTIONAL
        !class                         TYPE clike OPTIONAL
        !loop                          TYPE clike OPTIONAL
        !id                            TYPE clike OPTIONAL
        !arrowsplacement               TYPE clike OPTIONAL
        !backgrounddesign              TYPE clike OPTIONAL
        !pageindicatorbackgrounddesign TYPE clike OPTIONAL
        !pageindicatorborderdesign     TYPE clike OPTIONAL
        !pageindicatorplacement        TYPE clike OPTIONAL
        !width                         TYPE clike OPTIONAL
        !showpageindicator             TYPE clike OPTIONAL
        !visible                       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view .
    METHODS buttons
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS get_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS get_parent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS get
      IMPORTING
        !name         TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS get_child
      IMPORTING
        !index        TYPE i DEFAULT 1
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS column
      IMPORTING
        !width             TYPE clike OPTIONAL
        !id                TYPE clike OPTIONAL
        !minscreenwidth    TYPE clike OPTIONAL
        !demandpopin       TYPE clike OPTIONAL
        !halign            TYPE clike OPTIONAL
        !visible           TYPE clike OPTIONAL
        !valign            TYPE clike OPTIONAL
        !styleclass        TYPE clike OPTIONAL
        !sortindicator     TYPE clike OPTIONAL
        !popindisplay      TYPE clike OPTIONAL
        !mergefunctionname TYPE clike OPTIONAL
        !mergeduplicates   TYPE clike OPTIONAL
        !importance        TYPE clike OPTIONAL
        !autopopinwidth    TYPE clike OPTIONAL
        !class             TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS items
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS interact_donut_chart
      IMPORTING
        !selectionchanged  TYPE clike OPTIONAL
        !errormessage      TYPE clike OPTIONAL
        !errormessagetitle TYPE clike OPTIONAL
        !showerror         TYPE clike OPTIONAL
        !displayedsegments TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS segments
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS interact_donut_chart_segment
      IMPORTING
        !label          TYPE clike OPTIONAL
        !value          TYPE clike OPTIONAL
        !displayedvalue TYPE clike OPTIONAL
        !selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS interact_bar_chart
      IMPORTING
        !selectionchanged  TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
        !labelwidth        TYPE clike OPTIONAL
        !errormessage      TYPE clike OPTIONAL
        !errormessagetitle TYPE clike OPTIONAL
        !showerror         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS bars
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS interact_bar_chart_bar
      IMPORTING
        !label          TYPE clike OPTIONAL
        !value          TYPE clike OPTIONAL
        !displayedvalue TYPE clike OPTIONAL
        !selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS interact_line_chart
      IMPORTING
        !selectionchanged  TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
        !precedingpoint    TYPE clike OPTIONAL
        !succeddingpoint   TYPE clike OPTIONAL
        !errormessage      TYPE clike OPTIONAL
        !errormessagetitle TYPE clike OPTIONAL
        !showerror         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS points
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS interact_line_chart_point
      IMPORTING
        !label          TYPE clike OPTIONAL
        !value          TYPE clike OPTIONAL
        !secondarylabel TYPE clike OPTIONAL
        !displayedvalue TYPE clike OPTIONAL
        !selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS radial_micro_chart
      IMPORTING
        !size         TYPE clike OPTIONAL
        !percentage   TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !valuecolor   TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !aligncontent TYPE clike OPTIONAL
        !hideonnodata TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS column_list_item
      IMPORTING
        !id            TYPE clike OPTIONAL
        !valign        TYPE clike OPTIONAL
        !selected      TYPE clike OPTIONAL
        !type          TYPE clike OPTIONAL
        !press         TYPE clike OPTIONAL
        !counter       TYPE clike OPTIONAL
        !highlight     TYPE clike OPTIONAL
        !highlighttext TYPE clike OPTIONAL
        !navigated     TYPE clike OPTIONAL
        !unread        TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !detailpress   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS cells
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS bar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS content_left
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS content_middle
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS content_right
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS custom_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS header_content
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS sub_header
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS custom_data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS badge_custom_data
      IMPORTING
        !key          TYPE clike OPTIONAL
        !value        TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS toggle_button
      IMPORTING
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS button
      IMPORTING
        !text             TYPE clike OPTIONAL
        !icon             TYPE clike OPTIONAL
        !type             TYPE clike OPTIONAL
        !enabled          TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
        !press            TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !ns               TYPE clike OPTIONAL
        !tooltip          TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !iconfirst        TYPE clike OPTIONAL
        !icondensityaware TYPE clike OPTIONAL
        !ariahaspopup     TYPE clike OPTIONAL
        !activeicon       TYPE clike OPTIONAL
        !accessiblerole   TYPE clike OPTIONAL
        !textdirection    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS search_field
      IMPORTING
        !search            TYPE clike OPTIONAL
        !width             TYPE clike OPTIONAL
        !value             TYPE clike OPTIONAL
        !id                TYPE clike OPTIONAL
        !change            TYPE clike OPTIONAL
        !livechange        TYPE clike OPTIONAL
        !suggest           TYPE clike OPTIONAL
        !enabled           TYPE clike OPTIONAL
        !enablesuggestions TYPE clike OPTIONAL
        !maxlength         TYPE clike OPTIONAL
        !placeholder       TYPE clike OPTIONAL
        !showrefreshbutton TYPE clike OPTIONAL
        !showsearchbutton  TYPE clike OPTIONAL
        !visible           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_view
      IMPORTING
        !items        TYPE clike OPTIONAL
        !groupitems   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS barcode_scanner_button
      IMPORTING
        !id              TYPE clike OPTIONAL
        !scansuccess     TYPE clike OPTIONAL
        !scanfail        TYPE clike OPTIONAL
        !inputliveupdate TYPE clike OPTIONAL
        !dialogtitle     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_popover
      IMPORTING
        !items             TYPE clike OPTIONAL
        !groupitems        TYPE clike OPTIONAL
        !listselect        TYPE clike OPTIONAL
        !activetitlepress  TYPE clike OPTIONAL
        !placement         TYPE clike OPTIONAL
        !afterclose        TYPE clike OPTIONAL
        !beforeclose       TYPE clike OPTIONAL
        !initiallyexpanded TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_item
      IMPORTING
        !type              TYPE clike OPTIONAL
        !title             TYPE clike OPTIONAL
        !subtitle          TYPE clike OPTIONAL
        !description       TYPE clike OPTIONAL
        !groupname         TYPE clike OPTIONAL
        !markupdescription TYPE clike OPTIONAL
        !textdirection     TYPE clike OPTIONAL
        !longtexturl       TYPE clike OPTIONAL
        !counter           TYPE clike OPTIONAL
        !activetitle       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS page
      IMPORTING
        !title            TYPE clike OPTIONAL
        !navbuttonpress   TYPE clike OPTIONAL
        !shownavbutton    TYPE clike OPTIONAL
        !showheader       TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !ns               TYPE clike OPTIONAL
        !backgrounddesign TYPE clike OPTIONAL
        !contentonlybusy  TYPE clike OPTIONAL
        !enablescrolling  TYPE clike OPTIONAL
        !navbuttontooltip TYPE clike OPTIONAL
        !floatingfooter   TYPE clike OPTIONAL
        !showfooter       TYPE clike OPTIONAL
        !showsubheader    TYPE clike OPTIONAL
        !titlealignment   TYPE clike OPTIONAL
        !titlelevel       TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS panel
      IMPORTING
        !expandable       TYPE clike OPTIONAL
        !expanded         TYPE clike OPTIONAL
        !headertext       TYPE clike OPTIONAL
        !stickyheader     TYPE clike OPTIONAL
        !height           TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !backgrounddesign TYPE clike OPTIONAL
        !expandanimation  TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS vbox
      IMPORTING
        !id               TYPE clike OPTIONAL
        !height           TYPE clike OPTIONAL
        !justifycontent   TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !rendertype       TYPE clike OPTIONAL
        !aligncontent     TYPE clike OPTIONAL
        !direction        TYPE clike OPTIONAL
        !alignitems       TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !wrap             TYPE clike OPTIONAL
        !backgrounddesign TYPE clike OPTIONAL
        !displayinline    TYPE clike OPTIONAL
        !fitcontainer     TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
          PREFERRED PARAMETER class
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS hbox
      IMPORTING
        !id               TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !justifycontent   TYPE clike OPTIONAL
        !aligncontent     TYPE clike OPTIONAL
        !alignitems       TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !height           TYPE clike OPTIONAL
        !rendertype       TYPE clike OPTIONAL
        !wrap             TYPE clike OPTIONAL
        !backgrounddesign TYPE clike OPTIONAL
        !direction        TYPE clike OPTIONAL
        !displayinline    TYPE clike OPTIONAL
        !fitcontainer     TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS scroll_container
      IMPORTING
        !height       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !vertical     TYPE clike OPTIONAL
        !horizontal   TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
        !focusable    TYPE clike OPTIONAL
          PREFERRED PARAMETER height
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS simple_form
      IMPORTING
        !title                   TYPE clike OPTIONAL
        !layout                  TYPE clike OPTIONAL
        !editable                TYPE clike OPTIONAL
        !columnsxl               TYPE clike OPTIONAL
        !columnsl                TYPE clike OPTIONAL
        !columnsm                TYPE clike OPTIONAL
        !id                      TYPE clike OPTIONAL
        !adjustlabelspan         TYPE clike OPTIONAL
        !backgrounddesign        TYPE clike OPTIONAL
        !breakpointl             TYPE clike OPTIONAL
        !breakpointm             TYPE clike OPTIONAL
        !breakpointxl            TYPE clike OPTIONAL
        !emptyspanl              TYPE clike OPTIONAL
        !emptyspanm              TYPE clike OPTIONAL
        !emptyspans              TYPE clike OPTIONAL
        !emptyspanxl             TYPE clike OPTIONAL
        !labelspans              TYPE clike OPTIONAL
        !labelspanm              TYPE clike OPTIONAL
        !labelspanl              TYPE clike OPTIONAL
        !labelspanxl             TYPE clike OPTIONAL
        !maxcontainercols        TYPE clike OPTIONAL
        !minwidth                TYPE clike OPTIONAL
        !singlecontainerfullsize TYPE clike OPTIONAL
        !visible                 TYPE clike OPTIONAL
        !width                   TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS _cc_plain_xml
      IMPORTING
        !val          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS content
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS title
      IMPORTING
        !ns            TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !wrapping      TYPE clike OPTIONAL
        !level         TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
        !id            TYPE clike OPTIONAL
        !textalign     TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
        !titlestyle    TYPE clike OPTIONAL
        !width         TYPE clike OPTIONAL
        !wrappingtype  TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS tab_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS tab
      IMPORTING
        !text         TYPE clike OPTIONAL
        !selected     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS overflow_toolbar_toggle_button
      IMPORTING
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !tooltip      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS overflow_toolbar_button
      IMPORTING
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !tooltip      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS overflow_toolbar_menu_button
      IMPORTING
        !text          TYPE clike OPTIONAL
        !icon          TYPE clike OPTIONAL
        !buttonmode    TYPE clike OPTIONAL
        !type          TYPE clike OPTIONAL
        !enabled       TYPE clike OPTIONAL
        !tooltip       TYPE clike OPTIONAL
        !defaultaction TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS menu_item
      IMPORTING
        !press        TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS toolbar_spacer
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS label
      IMPORTING
        !text          TYPE clike OPTIONAL
        !labelfor      TYPE clike OPTIONAL
        !design        TYPE clike OPTIONAL
        !displayonly   TYPE clike OPTIONAL
        !required      TYPE clike OPTIONAL
        !showcolon     TYPE clike OPTIONAL
        !textalign     TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
        !valign        TYPE clike OPTIONAL
        !width         TYPE clike OPTIONAL
        !wrapping      TYPE clike OPTIONAL
        !wrappingtype  TYPE clike OPTIONAL
        !id            TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS image
      IMPORTING
        !src                TYPE clike OPTIONAL
        !class              TYPE clike OPTIONAL
        !height             TYPE clike OPTIONAL
        !width              TYPE clike OPTIONAL
        !usemap             TYPE clike OPTIONAL
        !mode               TYPE clike OPTIONAL
        !lazyloading        TYPE clike OPTIONAL
        !densityaware       TYPE clike OPTIONAL
        !decorative         TYPE clike OPTIONAL
        !backgroundsize     TYPE clike OPTIONAL
        !backgroundrepeat   TYPE clike OPTIONAL
        !backgroundposition TYPE clike OPTIONAL
        !ariahaspopup       TYPE clike OPTIONAL
        !alt                TYPE clike OPTIONAL
        !activesrc          TYPE clike OPTIONAL
        !press              TYPE clike OPTIONAL
        !load               TYPE clike OPTIONAL
        !error              TYPE clike OPTIONAL
        !id                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS date_picker
      IMPORTING
        !value                   TYPE clike OPTIONAL
        !placeholder             TYPE clike OPTIONAL
        !displayformat           TYPE clike OPTIONAL
        !valueformat             TYPE clike OPTIONAL
        !required                TYPE clike OPTIONAL
        !valuestate              TYPE clike OPTIONAL
        !valuestatetext          TYPE clike OPTIONAL
        !enabled                 TYPE clike OPTIONAL
        !showcurrentdatebutton   TYPE clike OPTIONAL
        !change                  TYPE clike OPTIONAL
        !hideinput               TYPE clike OPTIONAL
        !showfooter              TYPE clike OPTIONAL
        !visible                 TYPE clike OPTIONAL
        !showvaluestatemessage   TYPE clike OPTIONAL
        !mindate                 TYPE clike OPTIONAL
        !maxdate                 TYPE clike OPTIONAL
        !editable                TYPE clike OPTIONAL
        !width                   TYPE clike OPTIONAL
        !id                      TYPE clike OPTIONAL
        !calendarweeknumbering   TYPE clike OPTIONAL
        !displayformattype       TYPE clike OPTIONAL
        !class                   TYPE clike OPTIONAL
        !textdirection           TYPE clike OPTIONAL
        !textalign               TYPE clike OPTIONAL
        !name                    TYPE clike OPTIONAL
        !datevalue               TYPE clike OPTIONAL
        !initialfocuseddatevalue TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS time_picker
      IMPORTING
        !value                   TYPE clike OPTIONAL
        !placeholder             TYPE clike OPTIONAL
        !enabled                 TYPE clike OPTIONAL
        !valuestate              TYPE clike OPTIONAL
        !displayformat           TYPE clike OPTIONAL
        !valueformat             TYPE clike OPTIONAL
        !required                TYPE clike OPTIONAL
        !width                   TYPE clike OPTIONAL
        !datevalue               TYPE clike OPTIONAL
        !localeid                TYPE clike OPTIONAL
        !mask                    TYPE clike OPTIONAL
        !maskmode                TYPE clike OPTIONAL
        !minutesstep             TYPE clike OPTIONAL
        !name                    TYPE clike OPTIONAL
        !placeholdersymbol       TYPE clike OPTIONAL
        !secondsstep             TYPE clike OPTIONAL
        !textalign               TYPE clike OPTIONAL
        !textdirection           TYPE clike OPTIONAL
        !title                   TYPE clike OPTIONAL
        !showcurrenttimebutton   TYPE clike OPTIONAL
        !showvaluestatemessage   TYPE clike OPTIONAL
        !support2400             TYPE clike OPTIONAL
        !initialfocuseddatevalue TYPE clike OPTIONAL
        !hideinput               TYPE clike OPTIONAL
        !editable                TYPE clike OPTIONAL
        !visible                 TYPE clike OPTIONAL
        !valuestatetext          TYPE clike OPTIONAL
        !livechange              TYPE clike OPTIONAL
        !change                  TYPE clike OPTIONAL
        !aftervaluehelpopen      TYPE clike OPTIONAL
        !aftervaluehelpclose     TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS date_time_picker
      IMPORTING
        !value        TYPE clike OPTIONAL
        !placeholder  TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !valuestate   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS link
      IMPORTING
        !text               TYPE clike OPTIONAL
        !href               TYPE clike OPTIONAL
        !target             TYPE clike OPTIONAL
        !enabled            TYPE clike OPTIONAL
        !press              TYPE clike OPTIONAL
        !id                 TYPE clike OPTIONAL
        !ns                 TYPE clike OPTIONAL
        !wrapping           TYPE clike OPTIONAL
        !width              TYPE clike OPTIONAL
        !validateurl        TYPE clike OPTIONAL
        !textdirection      TYPE clike OPTIONAL
        !textalign          TYPE clike OPTIONAL
        !subtle             TYPE clike OPTIONAL
        !rel                TYPE clike OPTIONAL
        !emptyindicatormode TYPE clike OPTIONAL
        !emphasized         TYPE clike OPTIONAL
        !ariahaspopup       TYPE clike OPTIONAL
        !accessiblerole     TYPE clike OPTIONAL
        !class              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS list
      IMPORTING
        !headertext             TYPE clike OPTIONAL
        !items                  TYPE clike OPTIONAL
        !mode                   TYPE clike OPTIONAL
        !selectionchange        TYPE clike OPTIONAL
        !showseparators         TYPE clike OPTIONAL
        !footertext             TYPE clike OPTIONAL
        !growingdirection       TYPE clike OPTIONAL
        !growingthreshold       TYPE clike OPTIONAL
        !growingtriggertext     TYPE clike OPTIONAL
        !headerlevel            TYPE clike OPTIONAL
        !multiselectmode        TYPE clike OPTIONAL
        !nodatatext             TYPE clike OPTIONAL
        !sticky                 TYPE clike OPTIONAL
        !modeanimationon        TYPE clike OPTIONAL
        !growingscrolltoload    TYPE clike OPTIONAL
        !includeiteminselection TYPE clike OPTIONAL
        !growing                TYPE clike OPTIONAL
        !inset                  TYPE clike OPTIONAL
        !backgrounddesign       TYPE clike OPTIONAL
        !rememberselections     TYPE clike OPTIONAL
        !showunread             TYPE clike OPTIONAL
        !visible                TYPE clike OPTIONAL
        !nodata                 TYPE clike OPTIONAL
        !id                     TYPE clike OPTIONAL
        !itempress              TYPE clike OPTIONAL
        !select                 TYPE clike OPTIONAL
        !delete                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS custom_list_item
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS input_list_item
      IMPORTING
        !label        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS standard_list_item
      IMPORTING
        !title             TYPE clike OPTIONAL
        !description       TYPE clike OPTIONAL
        !icon              TYPE clike OPTIONAL
        !info              TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
        !type              TYPE clike OPTIONAL
        !selected          TYPE clike OPTIONAL
        !counter           TYPE clike OPTIONAL
        !wrapping          TYPE clike OPTIONAL
        !wrapcharlimit     TYPE clike OPTIONAL
        !infostateinverted TYPE clike OPTIONAL
        !infostate         TYPE clike OPTIONAL
        !iconinset         TYPE clike OPTIONAL
        !adapttitlesize    TYPE clike OPTIONAL
        !activeicon        TYPE clike OPTIONAL
        !unread            TYPE clike OPTIONAL
        !highlight         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS item
      IMPORTING
        !key          TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS segmented_button_item
      IMPORTING
        !icon          TYPE clike OPTIONAL
        !key           TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !width         TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
        !enabled       TYPE clike OPTIONAL
        !press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS combobox
      IMPORTING
        !selectedkey           TYPE clike OPTIONAL
        !showclearicon         TYPE clike OPTIONAL
        !selectionchange       TYPE clike OPTIONAL
        !selecteditem          TYPE clike OPTIONAL
        !items                 TYPE clike OPTIONAL
        !change                TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !showsecondaryvalues   TYPE clike OPTIONAL
        !placeholder           TYPE clike OPTIONAL
        !selecteditemid        TYPE clike OPTIONAL
        !name                  TYPE clike OPTIONAL
        !value                 TYPE clike OPTIONAL
        !valuestate            TYPE clike OPTIONAL
        !valuestatetext        TYPE clike OPTIONAL
        !textalign             TYPE clike OPTIONAL
        !visible               TYPE clike OPTIONAL
        !showvaluestatemessage TYPE clike OPTIONAL
        !showbutton            TYPE clike OPTIONAL
        !required              TYPE clike OPTIONAL
        !editable              TYPE clike OPTIONAL
        !enabled               TYPE clike OPTIONAL
        !filtersecondaryvalues TYPE clike OPTIONAL
        !id                    TYPE clike OPTIONAL
        !class                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .

    METHODS multi_combobox
      IMPORTING
        !selectionchange       TYPE clike OPTIONAL
        !selectedkeys          TYPE clike OPTIONAL
        !selecteditems         TYPE clike OPTIONAL
        !items                 TYPE clike OPTIONAL
        !selectionfinish       TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !showclearicon         TYPE clike OPTIONAL
        !showsecondaryvalues   TYPE clike OPTIONAL
        !placeholder           TYPE clike OPTIONAL
        !selecteditemid        TYPE clike OPTIONAL
        !selectedkey           TYPE clike OPTIONAL
        !name                  TYPE clike OPTIONAL
        !value                 TYPE clike OPTIONAL
        !valuestate            TYPE clike OPTIONAL
        !valuestatetext        TYPE clike OPTIONAL
        !textalign             TYPE clike OPTIONAL
        !visible               TYPE clike OPTIONAL
        !showvaluestatemessage TYPE clike OPTIONAL
        !showbutton            TYPE clike OPTIONAL
        !required              TYPE clike OPTIONAL
        !editable              TYPE clike OPTIONAL
        !enabled               TYPE clike OPTIONAL
        !filtersecondaryvalues TYPE clike OPTIONAL
        !showselectall         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS grid
      IMPORTING
        !class        TYPE clike OPTIONAL
        !default_span TYPE clike OPTIONAL
          PREFERRED PARAMETER default_span
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS grid_data
      IMPORTING
        !span         TYPE clike OPTIONAL
          PREFERRED PARAMETER span
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS text_area
      IMPORTING
        !value                 TYPE clike OPTIONAL
        !rows                  TYPE clike OPTIONAL
        !cols                  TYPE clike OPTIONAL
        !height                TYPE clike OPTIONAL
        !class                 TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !valueliveupdate       TYPE clike OPTIONAL
        !editable              TYPE clike OPTIONAL
        !enabled               TYPE clike OPTIONAL
        !growing               TYPE clike OPTIONAL
        !growingmaxlines       TYPE clike OPTIONAL
        !id                    TYPE clike OPTIONAL
        !required              TYPE clike OPTIONAL
        !placeholder           TYPE clike OPTIONAL
        !valuestate            TYPE clike OPTIONAL
        !valuestatetext        TYPE clike OPTIONAL
        !wrapping              TYPE clike OPTIONAL
        !maxlength             TYPE clike OPTIONAL
        !textalign             TYPE clike OPTIONAL
        !textdirection         TYPE clike OPTIONAL
        !showvaluestatemessage TYPE clike OPTIONAL
        !showexceededtext      TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS range_slider
      IMPORTING
        !max           TYPE clike OPTIONAL
        !min           TYPE clike OPTIONAL
        !step          TYPE clike OPTIONAL
        !startvalue    TYPE clike OPTIONAL
        !endvalue      TYPE clike OPTIONAL
        !showtickmarks TYPE clike OPTIONAL
        !labelinterval TYPE clike OPTIONAL
        !width         TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
        !id            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS generic_tag
      IMPORTING
        !id             TYPE clike OPTIONAL
        !arialabelledby TYPE clike OPTIONAL
        !text           TYPE clike OPTIONAL
        !design         TYPE clike OPTIONAL
        !status         TYPE clike OPTIONAL
        !class          TYPE clike OPTIONAL
        !press          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_attribute
      IMPORTING
        !title         TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !active        TYPE clike OPTIONAL
        !ariahaspopup  TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_number
      IMPORTING
        !state              TYPE clike OPTIONAL
        !emphasized         TYPE clike OPTIONAL
        !number             TYPE clike OPTIONAL
        !textdirection      TYPE clike OPTIONAL
        !textalign          TYPE clike OPTIONAL
        !numberunit         TYPE clike OPTIONAL
        !inverted           TYPE clike OPTIONAL
        !emptyindicatormode TYPE clike OPTIONAL
        !active             TYPE clike OPTIONAL
        !unit               TYPE clike OPTIONAL
        !visible            TYPE clike OPTIONAL
        !class              TYPE clike OPTIONAL
        !id                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS switch
      IMPORTING
        !state         TYPE clike OPTIONAL
        !customtexton  TYPE clike OPTIONAL
        !customtextoff TYPE clike OPTIONAL
        !enabled       TYPE clike OPTIONAL
        !change        TYPE clike OPTIONAL
        !type          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS step_input
      IMPORTING
        !value        TYPE clike OPTIONAL
        !min          TYPE clike OPTIONAL
        !max          TYPE clike OPTIONAL
        !step         TYPE clike OPTIONAL
        !valuestate   TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !description  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS progress_indicator
      IMPORTING
        !class        TYPE clike OPTIONAL
        !percentvalue TYPE clike OPTIONAL
        !displayvalue TYPE clike OPTIONAL
        !showvalue    TYPE clike OPTIONAL
        !state        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS segmented_button
      IMPORTING
        !selected_key     TYPE clike
        !selection_change TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
        !enabled          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS checkbox
      IMPORTING
        !text              TYPE clike OPTIONAL
        !selected          TYPE clike OPTIONAL
        !enabled           TYPE clike OPTIONAL
        !select            TYPE clike OPTIONAL
        !id                TYPE clike OPTIONAL
        !class             TYPE clike OPTIONAL
        !textalign         TYPE clike OPTIONAL
        !textdirection     TYPE clike OPTIONAL
        !width             TYPE clike OPTIONAL
        !activehandling    TYPE clike OPTIONAL
        !visible           TYPE clike OPTIONAL
        !displayonly       TYPE clike OPTIONAL
        !editable          TYPE clike OPTIONAL
        !partiallyselected TYPE clike OPTIONAL
        !useentirewidth    TYPE clike OPTIONAL
        !wrapping          TYPE clike OPTIONAL
        !name              TYPE clike OPTIONAL
        !valuestate        TYPE clike OPTIONAL
          PREFERRED PARAMETER selected
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS header_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS toolbar
      IMPORTING
        !ns           TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !active       TYPE clike OPTIONAL
        !ariahaspopup TYPE clike OPTIONAL
        !design       TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !style        TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS text
      IMPORTING
        !text               TYPE clike OPTIONAL
        !class              TYPE clike OPTIONAL
        !ns                 TYPE clike OPTIONAL
        !emptyindicatormode TYPE clike OPTIONAL
        !maxlines           TYPE clike OPTIONAL
        !renderwhitespace   TYPE clike OPTIONAL
        !textalign          TYPE clike OPTIONAL
        !textdirection      TYPE clike OPTIONAL
        !width              TYPE clike OPTIONAL
        !wrapping           TYPE clike OPTIONAL
        !wrappingtype       TYPE clike OPTIONAL
        !id                 TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS formatted_text
      IMPORTING
        !htmltext                    TYPE clike OPTIONAL
        !convertedlinksdefaulttarget TYPE clike OPTIONAL
        !convertlinkstoanchortags    TYPE clike OPTIONAL
        !height                      TYPE clike OPTIONAL
        !textalign                   TYPE clike OPTIONAL
        !textdirection               TYPE clike OPTIONAL
        !visible                     TYPE clike OPTIONAL
        !width                       TYPE clike OPTIONAL
        !id                          TYPE clike OPTIONAL
        !class                       TYPE clike OPTIONAL
        !controls                    TYPE clike OPTIONAL
          PREFERRED PARAMETER htmltext
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view .
    METHODS _generic
      IMPORTING
        !name         TYPE clike
        !ns           TYPE clike OPTIONAL
        !t_prop       TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS _generic_property
      IMPORTING
        !val          TYPE z2ui5_if_types=>ty_s_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS xml_get
      RETURNING
        VALUE(result) TYPE string .
    METHODS stringify
      RETURNING
        VALUE(result) TYPE string .
    METHODS tree_table
      IMPORTING
        !rows                   TYPE clike
        !selectionmode          TYPE clike DEFAULT 'Single'
        !enablecolumnreordering TYPE clike DEFAULT 'false'
        !expandfirstlevel       TYPE clike DEFAULT 'false'
        !columnselect           TYPE clike OPTIONAL
        !rowselectionchange     TYPE clike OPTIONAL
        !selectionbehavior      TYPE clike DEFAULT 'RowSelector'
        !selectedindex          TYPE clike OPTIONAL
        !id                     TYPE clike OPTIONAL
        !visiblerowcount        TYPE clike OPTIONAL
        !visiblerowcountmode    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS tree_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS tree_column
      IMPORTING
        !label        TYPE clike
        !template     TYPE clike OPTIONAL
        !halign       TYPE clike DEFAULT 'Begin'
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS tree_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS filter_bar
      IMPORTING
        !usetoolbar                   TYPE clike DEFAULT 'false'
        !search                       TYPE clike OPTIONAL
        !id                           TYPE clike OPTIONAL
        !persistencykey               TYPE clike OPTIONAL
        !aftervariantload             TYPE clike OPTIONAL
        !aftervariantsave             TYPE clike OPTIONAL
        !assignedfilterschanged       TYPE clike OPTIONAL
        !beforevariantfetch           TYPE clike OPTIONAL
        !cancel                       TYPE clike OPTIONAL
        !clear                        TYPE clike OPTIONAL
        !filterchange                 TYPE clike OPTIONAL
        !filtersdialogbeforeopen      TYPE clike OPTIONAL
        !filtersdialogcancel          TYPE clike OPTIONAL
        !filtersdialogclosed          TYPE clike OPTIONAL
        !initialise                   TYPE clike OPTIONAL
        !initialized                  TYPE clike OPTIONAL
        !reset                        TYPE clike OPTIONAL
        !filtercontainerwidth         TYPE clike OPTIONAL
        !header                       TYPE clike OPTIONAL
        !advancedmode                 TYPE clike OPTIONAL
        !isrunninginvaluehelpdialog   TYPE clike OPTIONAL
        !showallfilters               TYPE clike OPTIONAL
        !showclearonfb                TYPE clike OPTIONAL
        !showfilterconfiguration      TYPE clike OPTIONAL
        !showgoonfb                   TYPE clike OPTIONAL
        !showrestorebutton            TYPE clike OPTIONAL
        !showrestoreonfb              TYPE clike OPTIONAL
        !usesnapshot                  TYPE clike OPTIONAL
        !searchenabled                TYPE clike OPTIONAL
        !considergrouptitle           TYPE clike OPTIONAL
        !deltavariantmode             TYPE clike OPTIONAL
        !disablesearchmatchespatternw TYPE clike OPTIONAL
        !filterbarexpanded            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view .
    METHODS filter_group_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS filter_group_item
      IMPORTING
        !name               TYPE clike
        !label              TYPE clike
        !groupname          TYPE clike
        !visibleinfilterbar TYPE clike DEFAULT 'true'
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS filter_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS flexible_column_layout
      IMPORTING
        !layout                        TYPE clike
        !id                            TYPE clike
        !backgrounddesign              TYPE clike OPTIONAL
        !defaulttransitionnamebegincol TYPE clike OPTIONAL
        !defaulttransitionnameendcol   TYPE clike OPTIONAL
        !defaulttransitionnamemidcol   TYPE clike OPTIONAL
        !autofocus                     TYPE clike OPTIONAL
        !restorefocusonbacknavigation  TYPE clike OPTIONAL
        !class                         TYPE clike OPTIONAL
        !afterbegincolumnnavigate      TYPE clike OPTIONAL
        !afterendcolumnnavigate        TYPE clike OPTIONAL
        !aftermidcolumnnavigate        TYPE clike OPTIONAL
        !begincolumnnavigate           TYPE clike OPTIONAL
        !columnresize                  TYPE clike OPTIONAL
        !endcolumnnavigate             TYPE clike OPTIONAL
        !midcolumnnavigate             TYPE clike OPTIONAL
        !statechange                   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view .
    METHODS begin_column_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS mid_column_pages
      IMPORTING
        !id           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS end_column_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_table
      IMPORTING
        !rows                     TYPE clike OPTIONAL
        !columnheadervisible      TYPE clike OPTIONAL
        !editable                 TYPE clike OPTIONAL
        !enablecellfilter         TYPE clike OPTIONAL
        !enablegrouping           TYPE clike OPTIONAL
        !enableselectall          TYPE clike OPTIONAL
        !firstvisiblerow          TYPE clike OPTIONAL
        !fixedbottomrowcount      TYPE clike OPTIONAL
        !fixedcolumncount         TYPE clike OPTIONAL
        !fixedrowcount            TYPE clike OPTIONAL
        !minautorowcount          TYPE clike OPTIONAL
        !rowactioncount           TYPE clike OPTIONAL
        !rowheight                TYPE clike OPTIONAL
        !selectionmode            TYPE clike OPTIONAL
        !showcolumnvisibilitymenu TYPE clike OPTIONAL
        !shownodata               TYPE clike OPTIONAL
        !selectedindex            TYPE clike OPTIONAL
        !threshold                TYPE clike OPTIONAL
        !visiblerowcount          TYPE clike OPTIONAL
        !visiblerowcountmode      TYPE clike OPTIONAL
        !alternaterowcolors       TYPE clike OPTIONAL
        !footer                   TYPE clike OPTIONAL
        !filter                   TYPE clike OPTIONAL
        !sort                     TYPE clike OPTIONAL
        !rowselectionchange       TYPE clike OPTIONAL
        !customfilter             TYPE clike OPTIONAL
        !id                       TYPE clike OPTIONAL
        !flex                     TYPE clike OPTIONAL
          PREFERRED PARAMETER rows
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_column
      IMPORTING
        !width               TYPE clike OPTIONAL
        !showsortmenuentry   TYPE clike OPTIONAL
        !sortproperty        TYPE clike OPTIONAL
        !autoresizable       TYPE clike OPTIONAL
        !filterproperty      TYPE clike OPTIONAL
        !showfiltermenuentry TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_extension
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS currency
      IMPORTING
        !value        TYPE clike
        !currency     TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_row_action
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_row_action_template
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_row_action_item
      IMPORTING
        !icon         TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS radio_button
      IMPORTING
        !activehandling TYPE clike OPTIONAL
        !editable       TYPE clike OPTIONAL
        !enabled        TYPE clike OPTIONAL
        !groupname      TYPE clike OPTIONAL
        !selected       TYPE clike OPTIONAL
        !text           TYPE clike OPTIONAL
        !textalign      TYPE clike OPTIONAL
        !textdirection  TYPE clike OPTIONAL
        !useentirewidth TYPE clike OPTIONAL
        !valuestate     TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
        !select         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS radio_button_group
      IMPORTING
        !id            TYPE clike OPTIONAL
        !columns       TYPE clike OPTIONAL
        !editable      TYPE clike OPTIONAL
        !enabled       TYPE clike OPTIONAL
        !selectedindex TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
        !valuestate    TYPE clike OPTIONAL
        !width         TYPE clike OPTIONAL
        !select        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS dynamic_side_content
      IMPORTING
        !id                    TYPE clike OPTIONAL
        !class                 TYPE clike OPTIONAL
        !sidecontentvisibility TYPE clike OPTIONAL
        !showsidecontent       TYPE clike OPTIONAL
        !containerquery        TYPE clike OPTIONAL
          PREFERRED PARAMETER id
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS side_content
      IMPORTING
        !width        TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS planning_calendar
      IMPORTING
        !rows                      TYPE clike OPTIONAL
        !startdate                 TYPE clike OPTIONAL
        !appointmentsvisualization TYPE clike OPTIONAL
        !appointmentselect         TYPE clike OPTIONAL
        !showemptyintervalheaders  TYPE clike OPTIONAL
        !showweeknumbers           TYPE clike OPTIONAL
        !showdaynamesline          TYPE clike OPTIONAL
        !legend                    TYPE clike OPTIONAL
          PREFERRED PARAMETER rows
      RETURNING
        VALUE(result)              TYPE REF TO z2ui5_cl_xml_view .
    METHODS planning_calendar_row
      IMPORTING
        !appointments                  TYPE clike OPTIONAL
        !intervalheaders               TYPE clike OPTIONAL
        !icon                          TYPE clike OPTIONAL
        !title                         TYPE clike OPTIONAL
        !key                           TYPE clike OPTIONAL
        !text                          TYPE clike OPTIONAL
        !enableappointmentscreate      TYPE clike OPTIONAL
        !enableappointmentsdraganddrop TYPE clike OPTIONAL
        !enableappointmentsresize      TYPE clike OPTIONAL
        !nonworkingdays                TYPE clike OPTIONAL
        !selected                      TYPE clike OPTIONAL
        !appointmentcreate             TYPE clike OPTIONAL
        !appointmentdragenter          TYPE clike OPTIONAL
        !appointmentdrop               TYPE clike OPTIONAL
        !appointmentresize             TYPE clike OPTIONAL
          PREFERRED PARAMETER appointments
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view .
    METHODS planning_calendar_legend
      IMPORTING
        !items            TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !appointmentitems TYPE clike OPTIONAL
        !standarditems    TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS calendar_legend_item
      IMPORTING
        !text         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !tooltip      TYPE clike OPTIONAL
        !color        TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS appointment_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS info_label
      IMPORTING
        !id            TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !rendermode    TYPE clike OPTIONAL
        !colorscheme   TYPE clike OPTIONAL
        !icon          TYPE clike OPTIONAL
        !displayonly   TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
        !width         TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS rows
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS appointments
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS calendar_appointment
      IMPORTING
        !startdate    TYPE clike OPTIONAL
        !enddate      TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !title        TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !tentative    TYPE clike OPTIONAL
        !key          TYPE clike OPTIONAL
          PREFERRED PARAMETER startdate
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS interval_headers
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS block_layout
      IMPORTING
        !background   TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS block_layout_row
      IMPORTING
        !rowcolorset  TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS block_layout_cell
      IMPORTING
        !backgroundcolorset   TYPE clike OPTIONAL
        !backgroundcolorshade TYPE clike OPTIONAL
        !title                TYPE clike OPTIONAL
        !titlealignment       TYPE clike OPTIONAL
        !titlelevel           TYPE clike OPTIONAL
        !width                TYPE clike OPTIONAL
        !class                TYPE clike OPTIONAL
        !id                   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_identifier
      IMPORTING
        !emptyindicatormode TYPE clike OPTIONAL
        !text               TYPE clike OPTIONAL
        !textdirection      TYPE clike OPTIONAL
        !title              TYPE clike OPTIONAL
        !titleactive        TYPE clike OPTIONAL
        !visible            TYPE clike OPTIONAL
        !titlepress         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_status
      IMPORTING
        !active                TYPE clike OPTIONAL
        !emptyindicatormode    TYPE clike OPTIONAL
        !icon                  TYPE clike OPTIONAL
        !icondensityaware      TYPE clike OPTIONAL
        !inverted              TYPE clike OPTIONAL
        !state                 TYPE clike OPTIONAL
        !stateannouncementtext TYPE clike OPTIONAL
        !text                  TYPE clike OPTIONAL
        !textdirection         TYPE clike OPTIONAL
        !title                 TYPE clike OPTIONAL
        !press                 TYPE clike OPTIONAL
        !visible               TYPE clike OPTIONAL
        !id                    TYPE clike OPTIONAL
        !class                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS tree
      IMPORTING
        !items                  TYPE clike OPTIONAL
        !headertext             TYPE clike OPTIONAL
        !footertext             TYPE clike OPTIONAL
        !mode                   TYPE clike OPTIONAL
        !includeiteminselection TYPE abap_bool OPTIONAL
        !inset                  TYPE abap_bool OPTIONAL
        !width                  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS standard_tree_item
      IMPORTING
        !title        TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !detailpress  TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !selected     TYPE clike OPTIONAL
        !counter      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS icon_tab_bar
      IMPORTING
        !class                  TYPE clike OPTIONAL
        !select                 TYPE clike OPTIONAL
        !expand                 TYPE clike OPTIONAL
        !expandable             TYPE clike OPTIONAL
        !expanded               TYPE clike OPTIONAL
        !selectedkey            TYPE clike OPTIONAL
        !uppercase              TYPE clike OPTIONAL
        !tabsoverflowmode       TYPE clike OPTIONAL
        !tabdensitymode         TYPE clike OPTIONAL
        !stretchcontentheight   TYPE clike OPTIONAL
        !maxnestinglevel        TYPE clike OPTIONAL
        !headermode             TYPE clike OPTIONAL
        !headerbackgrounddesign TYPE clike OPTIONAL
        !enabletabreordering    TYPE clike OPTIONAL
        !backgrounddesign       TYPE clike OPTIONAL
        !applycontentpadding    TYPE clike OPTIONAL
        !items                  TYPE clike OPTIONAL
        !content                TYPE clike OPTIONAL
        !id                     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS icon_tab_filter
      IMPORTING
        !items            TYPE clike OPTIONAL
        !showall          TYPE clike OPTIONAL
        !icon             TYPE clike OPTIONAL
        !iconcolor        TYPE clike OPTIONAL
        !count            TYPE clike OPTIONAL
        !text             TYPE clike OPTIONAL
        !key              TYPE clike OPTIONAL
        !design           TYPE clike OPTIONAL
        !icondensityaware TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
        !textdirection    TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS icon_tab_separator
      IMPORTING
        !icon             TYPE clike OPTIONAL
        !icondensityaware TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS _z2ui5
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_cc .
    METHODS gantt_chart_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS container_toolbar
      IMPORTING
        !showsearchbutton          TYPE clike OPTIONAL
        !aligncustomcontenttoright TYPE clike OPTIONAL
        !findmode                  TYPE clike OPTIONAL
        !infoofselectitems         TYPE clike OPTIONAL
        !showbirdeyebutton         TYPE clike OPTIONAL
        !showdisplaytypebutton     TYPE clike OPTIONAL
        !showlegendbutton          TYPE clike OPTIONAL
        !showsettingbutton         TYPE clike OPTIONAL
        !showtimezoomcontrol       TYPE clike OPTIONAL
        !stepcountofslider         TYPE clike OPTIONAL
        !zoomcontroltype           TYPE clike OPTIONAL
        !zoomlevel                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)              TYPE REF TO z2ui5_cl_xml_view .
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
        !title        TYPE clike OPTIONAL
        !showtitle    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS gantt_table
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS rating_indicator
      IMPORTING
        !maxvalue     TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !value        TYPE clike OPTIONAL
        !iconsize     TYPE clike OPTIONAL
        !tooltip      TYPE clike OPTIONAL
        !displayonly  TYPE clike OPTIONAL
        !change       TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
        !editable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS gantt_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS base_rectangle
      IMPORTING
        !time                    TYPE clike OPTIONAL
        !endtime                 TYPE clike OPTIONAL
        !selectable              TYPE clike OPTIONAL
        !selectedfill            TYPE clike OPTIONAL
        !fill                    TYPE clike OPTIONAL
        !height                  TYPE clike OPTIONAL
        !title                   TYPE clike OPTIONAL
        !animationsettings       TYPE clike OPTIONAL
        !alignshape              TYPE clike OPTIONAL
        !color                   TYPE clike OPTIONAL
        !fontsize                TYPE clike OPTIONAL
        !connectable             TYPE clike OPTIONAL
        !fontfamily              TYPE clike OPTIONAL
        !filter                  TYPE clike OPTIONAL
        !transform               TYPE clike OPTIONAL
        !countinbirdeye          TYPE clike OPTIONAL
        !fontweight              TYPE clike OPTIONAL
        !showtitle               TYPE clike OPTIONAL
        !selected                TYPE clike OPTIONAL
        !resizable               TYPE clike OPTIONAL
        !horizontaltextalignment TYPE clike OPTIONAL
        !highlighted             TYPE clike OPTIONAL
        !highlightable           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS tool_page
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS tool_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS icon_tab_header
      IMPORTING
        !selectedkey         TYPE clike OPTIONAL
        !items               TYPE clike OPTIONAL
        !select              TYPE clike OPTIONAL
        !mode                TYPE clike OPTIONAL
        !ariatexts           TYPE clike OPTIONAL
        !backgrounddesign    TYPE clike OPTIONAL
        !enabletabreordering TYPE clike OPTIONAL
        !maxnestinglevel     TYPE clike OPTIONAL
        !tabdensitymode      TYPE clike OPTIONAL
        !tabsoverflowmode    TYPE clike OPTIONAL
        !visible             TYPE clike OPTIONAL
        !id                  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS nav_container
      IMPORTING
        !initialpage           TYPE clike OPTIONAL
        !id                    TYPE clike OPTIONAL
        !defaulttransitionname TYPE clike OPTIONAL
        !autofocus             TYPE clike OPTIONAL
        !height                TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !visible               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS main_contents
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS table_select_dialog
      IMPORTING
        !confirmbuttontext  TYPE clike OPTIONAL
        !contentheight      TYPE clike OPTIONAL
        !contentwidth       TYPE clike OPTIONAL
        !draggable          TYPE clike OPTIONAL
        !growing            TYPE clike OPTIONAL
        !growingthreshold   TYPE clike OPTIONAL
        !multiselect        TYPE clike OPTIONAL
        !nodatatext         TYPE clike OPTIONAL
        !rememberselections TYPE clike OPTIONAL
        !resizable          TYPE clike OPTIONAL
        !searchplaceholder  TYPE clike OPTIONAL
        !showclearbutton    TYPE clike OPTIONAL
        !title              TYPE clike OPTIONAL
        !titlealignment     TYPE clike OPTIONAL
        !visible            TYPE clike OPTIONAL
        !items              TYPE clike OPTIONAL
        !livechange         TYPE clike OPTIONAL
        !cancel             TYPE clike OPTIONAL
        !search             TYPE clike OPTIONAL
        !confirm            TYPE clike OPTIONAL
        !selectionchange    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS process_flow
      IMPORTING
        !id            TYPE clike OPTIONAL
        !foldedcorners TYPE clike OPTIONAL
        !scrollable    TYPE clike OPTIONAL
        !showlabels    TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !wheelzoomable TYPE clike OPTIONAL
        !headerpress   TYPE clike OPTIONAL
        !labelpress    TYPE clike OPTIONAL
        !nodepress     TYPE clike OPTIONAL
        !onerror       TYPE clike OPTIONAL
        !lanes         TYPE clike OPTIONAL
        !nodes         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS nodes
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS lanes
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS process_flow_node
      IMPORTING
        !laneid            TYPE clike OPTIONAL
        !nodeid            TYPE clike OPTIONAL
        !title             TYPE clike OPTIONAL
        !titleabbreviation TYPE clike OPTIONAL
        !children          TYPE clike OPTIONAL
        !state             TYPE clike OPTIONAL
        !statetext         TYPE clike OPTIONAL
        !texts             TYPE clike OPTIONAL
        !highlighted       TYPE clike OPTIONAL
        !focused           TYPE clike OPTIONAL
        !selected          TYPE clike OPTIONAL
        !tag               TYPE clike OPTIONAL
        !type              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS process_flow_lane_header
      IMPORTING
        !iconsrc      TYPE clike OPTIONAL
        !laneid       TYPE clike OPTIONAL
        !position     TYPE clike OPTIONAL
        !state        TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !zoomlevel    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS view_settings_dialog
      IMPORTING
        !confirm                  TYPE clike OPTIONAL
        !cancel                   TYPE clike OPTIONAL
        !filterdetailpageopened   TYPE clike OPTIONAL
        !reset                    TYPE clike OPTIONAL
        !resetfilters             TYPE clike OPTIONAL
        !filtersearchoperator     TYPE clike OPTIONAL
        !groupdescending          TYPE clike OPTIONAL
        !sortdescending           TYPE clike OPTIONAL
        !title                    TYPE clike OPTIONAL
        !titlealignment           TYPE clike OPTIONAL
        !selectedgroupitem        TYPE clike OPTIONAL
        !selectedpresetfilteritem TYPE clike OPTIONAL
        !selectedsortitem         TYPE clike OPTIONAL
        !filteritems              TYPE clike OPTIONAL
        !sortitems                TYPE clike OPTIONAL
        !groupitems               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view .
    METHODS filter_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS sort_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS group_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS view_settings_filter_item
      IMPORTING
        !enabled       TYPE clike OPTIONAL
        !key           TYPE clike OPTIONAL
        !multiselect   TYPE clike OPTIONAL
        !selected      TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS view_settings_item
      IMPORTING
        !enabled       TYPE clike OPTIONAL
        !key           TYPE clike OPTIONAL
        !selected      TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !textdirection TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS variant_management
      IMPORTING
        !defaultvariantkey      TYPE clike OPTIONAL
        !enabled                TYPE clike OPTIONAL
        !inerrorstate           TYPE clike OPTIONAL
        !initialselectionkey    TYPE clike OPTIONAL
        !lifecyclesupport       TYPE clike OPTIONAL
        !selectionkey           TYPE clike OPTIONAL
        !showcreatetile         TYPE clike OPTIONAL
        !showexecuteonselection TYPE clike OPTIONAL
        !showsetasdefault       TYPE clike OPTIONAL
        !showshare              TYPE clike OPTIONAL
        !standarditemauthor     TYPE clike OPTIONAL
        !standarditemtext       TYPE clike OPTIONAL
        !usefavorites           TYPE clike OPTIONAL
        !visible                TYPE clike OPTIONAL
        !variantitems           TYPE clike OPTIONAL
        !manage                 TYPE clike OPTIONAL
        !save                   TYPE clike OPTIONAL
        !select                 TYPE clike OPTIONAL
        !uservarcreate          TYPE clike OPTIONAL
        !id                     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS variant_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS variant_item
      IMPORTING
        !executeonselection      TYPE clike OPTIONAL
        !global                  TYPE clike OPTIONAL
        !labelreadonly           TYPE clike OPTIONAL
        !lifecyclepackage        TYPE clike OPTIONAL
        !lifecycletransportid    TYPE clike OPTIONAL
        !namespace               TYPE clike OPTIONAL
        !readonly                TYPE clike OPTIONAL
        !executeonselect         TYPE clike OPTIONAL
        !author                  TYPE clike OPTIONAL
        !changeable              TYPE clike OPTIONAL
        !enabled                 TYPE clike OPTIONAL
        !favorite                TYPE clike OPTIONAL
        !key                     TYPE clike OPTIONAL
        !text                    TYPE clike OPTIONAL
        !title                   TYPE clike OPTIONAL
        !textdirection           TYPE clike OPTIONAL
        !originaltitle           TYPE clike OPTIONAL
        !originalexecuteonselect TYPE clike OPTIONAL
        !remove                  TYPE clike OPTIONAL
        !rename                  TYPE clike OPTIONAL
        !originalfavorite        TYPE clike OPTIONAL
        !sharing                 TYPE clike OPTIONAL
        !change                  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS feed_input
      IMPORTING
        !buttontooltip    TYPE clike OPTIONAL
        !enabled          TYPE clike OPTIONAL
        !growing          TYPE clike OPTIONAL
        !growingmaxlines  TYPE clike OPTIONAL
        !icon             TYPE clike OPTIONAL
        !icondensityaware TYPE clike OPTIONAL
        !icondisplayshape TYPE clike OPTIONAL
        !iconinitials     TYPE clike OPTIONAL
        !iconsize         TYPE clike OPTIONAL
        !maxlength        TYPE clike OPTIONAL
        !placeholder      TYPE clike OPTIONAL
        !rows             TYPE clike OPTIONAL
        !showexceededtext TYPE clike OPTIONAL
        !showicon         TYPE clike OPTIONAL
        !value            TYPE clike OPTIONAL
        !post             TYPE clike OPTIONAL
        !class            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS feed_list_item
      IMPORTING
        !activeicon                  TYPE clike OPTIONAL
        !convertedlinksdefaulttarget TYPE clike OPTIONAL
        !convertlinkstoanchortags    TYPE clike OPTIONAL
        !icon                        TYPE clike OPTIONAL
        !iconactive                  TYPE clike OPTIONAL
        !icondensityaware            TYPE clike OPTIONAL
        !icondisplayshape            TYPE clike OPTIONAL
        !iconinitials                TYPE clike OPTIONAL
        !iconsize                    TYPE clike OPTIONAL
        !info                        TYPE clike OPTIONAL
        !lesslabel                   TYPE clike OPTIONAL
        !maxcharacters               TYPE clike OPTIONAL
        !morelabel                   TYPE clike OPTIONAL
        !sender                      TYPE clike OPTIONAL
        !senderactive                TYPE clike OPTIONAL
        !showicon                    TYPE clike OPTIONAL
        !text                        TYPE clike OPTIONAL
        !timestamp                   TYPE clike OPTIONAL
        !iconpress                   TYPE clike OPTIONAL
        !senderpress                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view .
    METHODS feed_list_item_action
      IMPORTING
        !enabled      TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !key          TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS mask_input
      IMPORTING
        !placeholder           TYPE clike OPTIONAL
        !mask                  TYPE clike OPTIONAL
        !name                  TYPE clike OPTIONAL
        !textalign             TYPE clike OPTIONAL
        !textdirection         TYPE clike OPTIONAL
        !value                 TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !valuestate            TYPE clike OPTIONAL
        !valuestatetext        TYPE clike OPTIONAL
        !placeholdersymbol     TYPE clike OPTIONAL
        !required              TYPE clike OPTIONAL
        !showclearicon         TYPE clike OPTIONAL
        !showvaluestatemessage TYPE clike OPTIONAL
        !visible               TYPE clike OPTIONAL
        !fieldwidth            TYPE clike OPTIONAL
        !livechange            TYPE clike OPTIONAL
        !change                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS responsive_splitter
      IMPORTING
        !defaultpane  TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS pane_container
      IMPORTING
        !resize       TYPE clike OPTIONAL
        !orientation  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS split_pane
      IMPORTING
        !id                  TYPE clike OPTIONAL
        !requiredparentwidth TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS splitter_layout_data
      IMPORTING
        !size         TYPE clike OPTIONAL
        !minsize      TYPE clike OPTIONAL
        !resizable    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_header
      IMPORTING
        !backgrounddesign     TYPE clike OPTIONAL
        !condensed            TYPE clike OPTIONAL
        !fullscreenoptimized  TYPE clike OPTIONAL
        !icon                 TYPE clike OPTIONAL
        !iconactive           TYPE clike OPTIONAL
        !iconalt              TYPE clike OPTIONAL
        !icondensityaware     TYPE clike OPTIONAL
        !icontooltip          TYPE clike OPTIONAL
        !imageshape           TYPE clike OPTIONAL
        !intro                TYPE clike OPTIONAL
        !introactive          TYPE clike OPTIONAL
        !introhref            TYPE clike OPTIONAL
        !introtarget          TYPE clike OPTIONAL
        !introtextdirection   TYPE clike OPTIONAL
        !number               TYPE clike OPTIONAL
        !numberstate          TYPE clike OPTIONAL
        !numbertextdirection  TYPE clike OPTIONAL
        !numberunit           TYPE clike OPTIONAL
        !responsive           TYPE clike OPTIONAL
        !showtitleselector    TYPE clike OPTIONAL
        !title                TYPE clike OPTIONAL
        !titleactive          TYPE clike OPTIONAL
        !titlehref            TYPE clike OPTIONAL
        !titlelevel           TYPE clike OPTIONAL
        !titleselectortooltip TYPE clike OPTIONAL
        !titletarget          TYPE clike OPTIONAL
        !titletextdirection   TYPE clike OPTIONAL
        !iconpress            TYPE clike OPTIONAL
        !intropress           TYPE clike OPTIONAL
        !titlepress           TYPE clike OPTIONAL
        !titleselectorpress   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_xml_view .
    METHODS additional_numbers
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS header_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS markers
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS statuses
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS first_status
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS second_status
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_marker
      IMPORTING
        !additionalinfo TYPE clike OPTIONAL
        !type           TYPE clike OPTIONAL
        !visibility     TYPE clike OPTIONAL
        !visible        TYPE clike OPTIONAL
        !press          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_list_item
      IMPORTING
        !activeicon          TYPE clike OPTIONAL
        !icon                TYPE clike OPTIONAL
        !icondensityaware    TYPE clike OPTIONAL
        !intro               TYPE clike OPTIONAL
        !introtextdirection  TYPE clike OPTIONAL
        !number              TYPE clike OPTIONAL
        !numberstate         TYPE clike OPTIONAL
        !numbertextdirection TYPE clike OPTIONAL
        !numberunit          TYPE clike OPTIONAL
        !title               TYPE clike OPTIONAL
        !titletextdirection  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS detail_box
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS light_box
      IMPORTING
        !id           TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS light_box_item
      IMPORTING
        !alt          TYPE clike OPTIONAL
        !imagesrc     TYPE clike OPTIONAL
        !subtitle     TYPE clike OPTIONAL
        !title        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS line_micro_chart
      IMPORTING
        !color                 TYPE clike OPTIONAL
        !height                TYPE clike OPTIONAL
        !leftbottomlabel       TYPE clike OPTIONAL
        !lefttoplabel          TYPE clike OPTIONAL
        !maxxvalue             TYPE clike OPTIONAL
        !minxvalue             TYPE clike OPTIONAL
        !minyvalue             TYPE clike OPTIONAL
        !rightbottomlabel      TYPE clike OPTIONAL
        !righttoplabel         TYPE clike OPTIONAL
        !size                  TYPE clike OPTIONAL
        !threshold             TYPE clike OPTIONAL
        !thresholddisplayvalue TYPE clike OPTIONAL
        !width                 TYPE clike OPTIONAL
        !press                 TYPE clike OPTIONAL
        !hideonnodata          TYPE clike OPTIONAL
        !showbottomlabels      TYPE clike OPTIONAL
        !showpoints            TYPE clike OPTIONAL
        !showthresholdline     TYPE clike OPTIONAL
        !showthresholdvalue    TYPE clike OPTIONAL
        !showtoplabels         TYPE clike OPTIONAL
        !maxyvalue             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS stacked_bar_micro_chart
      IMPORTING
        !height           TYPE clike OPTIONAL
        !press            TYPE clike OPTIONAL
        !maxvalue         TYPE clike OPTIONAL
        !precision        TYPE clike OPTIONAL
        !size             TYPE clike OPTIONAL
        !hideonnodata     TYPE clike OPTIONAL
        !displayzerovalue TYPE clike OPTIONAL
        !showlabels       TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS column_micro_chart
      IMPORTING
        !width             TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
        !size              TYPE clike OPTIONAL
        !aligncontent      TYPE clike OPTIONAL
        !hideonnodata      TYPE clike OPTIONAL
        !allowcolumnlabels TYPE clike OPTIONAL
        !showbottomlabels  TYPE clike OPTIONAL
        !showtoplabels     TYPE clike OPTIONAL
        !height            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS comparison_micro_chart
      IMPORTING
        !colorpalette TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !size         TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !maxvalue     TYPE clike OPTIONAL
        !minvalue     TYPE clike OPTIONAL
        !scale        TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !hideonnodata TYPE clike OPTIONAL
        !shrinkable   TYPE clike OPTIONAL
        !view         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS delta_micro_chart
      IMPORTING
        !color             TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
        !size              TYPE clike OPTIONAL
        !height            TYPE clike OPTIONAL
        !width             TYPE clike OPTIONAL
        !deltadisplayvalue TYPE clike OPTIONAL
        !displayvalue1     TYPE clike OPTIONAL
        !displayvalue2     TYPE clike OPTIONAL
        !title2            TYPE clike OPTIONAL
        !value1            TYPE clike OPTIONAL
        !value2            TYPE clike OPTIONAL
        !view              TYPE clike OPTIONAL
        !hideonnodata      TYPE clike OPTIONAL
        !title1            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS bullet_micro_chart
      IMPORTING
        !actualvaluelabel  TYPE clike OPTIONAL
        !press             TYPE clike OPTIONAL
        !size              TYPE clike OPTIONAL
        !height            TYPE clike OPTIONAL
        !width             TYPE clike OPTIONAL
        !deltavaluelabel   TYPE clike OPTIONAL
        !maxvalue          TYPE clike OPTIONAL
        !minvalue          TYPE clike OPTIONAL
        !mode              TYPE clike OPTIONAL
        !scale             TYPE clike OPTIONAL
        !targetvalue       TYPE clike OPTIONAL
        !targetvaluelabel  TYPE clike OPTIONAL
        !scalecolor        TYPE clike OPTIONAL
        !hideonnodata      TYPE clike OPTIONAL
        !showactualvalue   TYPE clike OPTIONAL
        !showdeltavalue    TYPE clike OPTIONAL
        !showtargetvalue   TYPE clike OPTIONAL
        !showthresholds    TYPE clike OPTIONAL
        !showvaluemarker   TYPE clike OPTIONAL
        !smallrangeallowed TYPE clike OPTIONAL
        !forecastvalue     TYPE clike OPTIONAL
        !savidm            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS harvey_ball_micro_chart
      IMPORTING
        !colorpalette   TYPE clike OPTIONAL
        !press          TYPE clike OPTIONAL
        !size           TYPE clike OPTIONAL
        !height         TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
        !total          TYPE clike OPTIONAL
        !totallabel     TYPE clike OPTIONAL
        !aligncontent   TYPE clike OPTIONAL
        !hideonnodata   TYPE clike OPTIONAL
        !formattedlabel TYPE clike OPTIONAL
        !showfractions  TYPE clike OPTIONAL
        !showtotal      TYPE clike OPTIONAL
        !totalscale     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS area_micro_chart
      IMPORTING
        !colorpalette TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !size         TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !maxxvalue    TYPE clike OPTIONAL
        !maxyvalue    TYPE clike OPTIONAL
        !minxvalue    TYPE clike OPTIONAL
        !minyvalue    TYPE clike OPTIONAL
        !view         TYPE clike OPTIONAL
        !aligncontent TYPE clike OPTIONAL
        !hideonnodata TYPE clike OPTIONAL
        !showlabel    TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS rich_text_editor
      IMPORTING
        !buttongroups       TYPE clike OPTIONAL
        !customtoolbar      TYPE clike OPTIONAL
        !editable           TYPE clike OPTIONAL
        !editortype         TYPE clike OPTIONAL
        !height             TYPE clike OPTIONAL
        !plugins            TYPE clike OPTIONAL
        !required           TYPE clike OPTIONAL
        !sanitizevalue      TYPE clike OPTIONAL
        !showgroupclipboard TYPE clike OPTIONAL
        !showgroupfont      TYPE clike OPTIONAL
        !showgroupfontstyle TYPE clike OPTIONAL
        !showgroupinsert    TYPE clike OPTIONAL
        !showgrouplink      TYPE clike OPTIONAL
        !showgroupstructure TYPE clike OPTIONAL
        !showgrouptextalign TYPE clike OPTIONAL
        !showgroupundo      TYPE clike OPTIONAL
        !textdirection      TYPE clike OPTIONAL
        !uselegacytheme     TYPE clike OPTIONAL
        !value              TYPE clike OPTIONAL
        !width              TYPE clike OPTIONAL
        !wrapping           TYPE clike OPTIONAL
        !beforeeditorinit   TYPE clike OPTIONAL
        !change             TYPE clike OPTIONAL
        !ready              TYPE clike OPTIONAL
        !readyrecurring     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS upload_set
      IMPORTING
        !id                      TYPE clike OPTIONAL
        !instantupload           TYPE clike OPTIONAL
        !showicons               TYPE clike OPTIONAL
        !uploadenabled           TYPE clike OPTIONAL
        !terminationenabled      TYPE clike OPTIONAL
        !filetypes               TYPE clike OPTIONAL
        !maxfilenamelength       TYPE clike OPTIONAL
        !maxfilesize             TYPE clike OPTIONAL
        !mediatypes              TYPE clike OPTIONAL
        !uploadurl               TYPE clike OPTIONAL
        !items                   TYPE clike OPTIONAL
        !mode                    TYPE clike OPTIONAL
        !selectionchanged        TYPE clike OPTIONAL
        !uploadcompleted         TYPE clike OPTIONAL
        !afteritemadded          TYPE clike OPTIONAL
        !samefilenameallowed     TYPE clike OPTIONAL
        !uploadbuttoninvisible   TYPE clike OPTIONAL
        !directory               TYPE clike OPTIONAL
        !multiple                TYPE clike OPTIONAL
        !dragdropdescription     TYPE clike OPTIONAL
        !dragdroptext            TYPE clike OPTIONAL
        !nodatatext              TYPE clike OPTIONAL
        !nodatadescription       TYPE clike OPTIONAL
        !nodataillustrationtype  TYPE clike OPTIONAL
        !afteritemedited         TYPE clike OPTIONAL
        !afteritemremoved        TYPE clike OPTIONAL
        !beforeitemadded         TYPE clike OPTIONAL
        !beforeitemedited        TYPE clike OPTIONAL
        !beforeitemremoved       TYPE clike OPTIONAL
        !beforeuploadstarts      TYPE clike OPTIONAL
        !beforeuploadtermination TYPE clike OPTIONAL
        !filenamelengthexceeded  TYPE clike OPTIONAL
        !filerenamed             TYPE clike OPTIONAL
        !filesizeexceeded        TYPE clike OPTIONAL
        !filetypemismatch        TYPE clike OPTIONAL
        !itemdragstart           TYPE clike OPTIONAL
        !itemdrop                TYPE clike OPTIONAL
        !mediatypemismatch       TYPE clike OPTIONAL
        !uploadterminated        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS upload_set_toolbar_placeholder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS upload_set_item
      IMPORTING
        !filename      TYPE clike OPTIONAL
        !mediatype     TYPE clike OPTIONAL
        !url           TYPE clike OPTIONAL
        !thumbnailurl  TYPE clike OPTIONAL
        !markers       TYPE clike OPTIONAL
        !statuses      TYPE clike OPTIONAL
        !enablededit   TYPE clike OPTIONAL
        !enabledremove TYPE clike OPTIONAL
        !selected      TYPE clike OPTIONAL
        !visibleedit   TYPE clike OPTIONAL
        !visibleremove TYPE clike OPTIONAL
        !uploadstate   TYPE clike OPTIONAL
        !uploadurl     TYPE clike OPTIONAL
        !openpressed   TYPE clike OPTIONAL
        !removepressed TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS markers_as_status
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS rules
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS mask_input_rule
      IMPORTING
        !maskformatsymbol TYPE clike OPTIONAL
        !regex            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS side_panel
      IMPORTING
        !actionbarexpanded         TYPE clike OPTIONAL
        !arialabel                 TYPE clike OPTIONAL
        !sidepanelmaxwidth         TYPE clike OPTIONAL
        !sidepanelminwidth         TYPE clike OPTIONAL
        !sidepanelposition         TYPE clike OPTIONAL
        !sidepanelresizable        TYPE clike OPTIONAL
        !sidepanelresizelargerstep TYPE clike OPTIONAL
        !sidepanelresizestep       TYPE clike OPTIONAL
        !sidepanelwidth            TYPE clike OPTIONAL
        !toggle                    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)              TYPE REF TO z2ui5_cl_xml_view .
    METHODS side_panel_item
      IMPORTING
        !icon         TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !key          TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS main_content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS quick_view
      IMPORTING
        !placement    TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !afterclose   TYPE clike OPTIONAL
        !afteropen    TYPE clike OPTIONAL
        !beforeclose  TYPE clike OPTIONAL
        !beforeopen   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS quick_view_page
      IMPORTING
        !description  TYPE clike OPTIONAL
        !header       TYPE clike OPTIONAL
        !pageid       TYPE clike OPTIONAL
        !title        TYPE clike OPTIONAL
        !titleurl     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS quick_view_page_avatar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS quick_view_group
      IMPORTING
        !heading      TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS quick_view_group_element
      IMPORTING
        !emailsubject TYPE clike OPTIONAL
        !label        TYPE clike OPTIONAL
        !pagelinkid   TYPE clike OPTIONAL
        !target       TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !url          TYPE clike OPTIONAL
        !value        TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS variant_management_fl
      IMPORTING
        !displaytextfsv                TYPE clike OPTIONAL
        !editable                      TYPE clike OPTIONAL
        !executeonselectionforstandflt TYPE clike OPTIONAL
        !headerlevel                   TYPE clike OPTIONAL
        !inerrorstate                  TYPE clike OPTIONAL
        !maxwidth                      TYPE clike OPTIONAL
        !modelname                     TYPE clike OPTIONAL
        !resetoncontextchange          TYPE clike OPTIONAL
        !showsetasdefault              TYPE clike OPTIONAL
        !titlestyle                    TYPE clike OPTIONAL
        !updatevariantinurl            TYPE clike OPTIONAL
        !for                           TYPE clike OPTIONAL
        !cancel                        TYPE clike OPTIONAL
        !initialized                   TYPE clike OPTIONAL
        !manage                        TYPE clike OPTIONAL
        !save                          TYPE clike OPTIONAL
        !select                        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view .
    METHODS column_element_data
      IMPORTING
        !cellslarge   TYPE clike OPTIONAL
        !cellssmall   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS fb_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS smart_variant_management
      IMPORTING
        !id                     TYPE clike OPTIONAL
        !showexecuteonselection TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS form_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS paging_button
      IMPORTING
        !count                 TYPE clike OPTIONAL
        !nextbuttontooltip     TYPE clike OPTIONAL
        !previousbuttontooltip TYPE clike OPTIONAL
        !position              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS timeline
      IMPORTING
        !id                TYPE clike OPTIONAL
        !enabledoublesided TYPE clike OPTIONAL
        !groupby           TYPE clike OPTIONAL
        !growingthreshold  TYPE clike OPTIONAL
        !filtertitle       TYPE clike OPTIONAL
        !sortoldestfirst   TYPE clike OPTIONAL
        !alignment         TYPE clike OPTIONAL
        !axisorientation   TYPE clike OPTIONAL
        !content           TYPE clike OPTIONAL
        !enablemodelfilter TYPE clike OPTIONAL
        !enablescroll      TYPE clike OPTIONAL
        !forcegrowing      TYPE clike OPTIONAL
        !group             TYPE clike OPTIONAL
        !lazyloading       TYPE clike OPTIONAL
        !showheaderbar     TYPE clike OPTIONAL
        !showicons         TYPE clike OPTIONAL
        !showitemfilter    TYPE clike OPTIONAL
        !showsearch        TYPE clike OPTIONAL
        !showsort          TYPE clike OPTIONAL
        !showtimefilter    TYPE clike OPTIONAL
        !sort              TYPE clike OPTIONAL
        !groupbytype       TYPE clike OPTIONAL
        !textheight        TYPE clike OPTIONAL
        !width             TYPE clike OPTIONAL
        !height            TYPE clike OPTIONAL
        !nodatatext        TYPE clike OPTIONAL
        !filterlist        TYPE clike OPTIONAL
        !customfilter      TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS timeline_item
      IMPORTING
        !id                  TYPE clike OPTIONAL
        !datetime            TYPE clike OPTIONAL
        !title               TYPE clike OPTIONAL
        !usernameclickable   TYPE clike OPTIONAL
        !useicontooltip      TYPE clike OPTIONAL
        !usernameclicked     TYPE clike OPTIONAL
        !select              TYPE clike OPTIONAL
        !userpicture         TYPE clike OPTIONAL
        !text                TYPE clike OPTIONAL
        !username            TYPE clike OPTIONAL
        !filtervalue         TYPE clike OPTIONAL
        !icondisplayshape    TYPE clike OPTIONAL
        !iconinitials        TYPE clike OPTIONAL
        !iconsize            TYPE clike OPTIONAL
        !icontooltip         TYPE clike OPTIONAL
        !maxcharacters       TYPE clike OPTIONAL
        !replycount          TYPE clike OPTIONAL
        !status              TYPE clike OPTIONAL
        !customactionclicked TYPE clike OPTIONAL
        !press               TYPE clike OPTIONAL
        !replylistopen       TYPE clike OPTIONAL
        !replypost           TYPE clike OPTIONAL
        !icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS split_container
      IMPORTING
        !id                          TYPE clike OPTIONAL
        !initialdetail               TYPE clike OPTIONAL
        !initialmaster               TYPE clike OPTIONAL
        !backgroundcolor             TYPE clike OPTIONAL
        !backgroundimage             TYPE clike OPTIONAL
        !backgroundopacity           TYPE clike OPTIONAL
        !backgroundrepeat            TYPE clike OPTIONAL
        !defaulttransitionnamedetail TYPE clike OPTIONAL
        !defaulttransitionnamemaster TYPE clike OPTIONAL
        !masterbuttontext            TYPE clike OPTIONAL
        !masterbuttontooltip         TYPE clike OPTIONAL
        !mode                        TYPE clike OPTIONAL
        !afterdetailnavigate         TYPE clike OPTIONAL
        !aftermasterclose            TYPE clike OPTIONAL
        !aftermasternavigate         TYPE clike OPTIONAL
        !aftermasteropen             TYPE clike OPTIONAL
        !beforemasterclose           TYPE clike OPTIONAL
        !beforemasteropen            TYPE clike OPTIONAL
        !detailnavigate              TYPE clike OPTIONAL
        !masterbutton                TYPE clike OPTIONAL
        !masternavigate              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view .
    METHODS detail_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS master_pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS container_content
      IMPORTING
        !id           TYPE clike OPTIONAL
        !title        TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS map_container
      IMPORTING
        !id               TYPE clike OPTIONAL
        !autoadjustheight TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS spot
      IMPORTING
        !id            TYPE clike OPTIONAL
        !position      TYPE clike OPTIONAL
        !contentoffset TYPE clike OPTIONAL
        !type          TYPE clike OPTIONAL
        !scale         TYPE clike OPTIONAL
        !tooltip       TYPE clike OPTIONAL
        !image         TYPE clike OPTIONAL
        !icon          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS analytic_map
      IMPORTING
        !id              TYPE clike OPTIONAL
        !initialposition TYPE clike OPTIONAL
        !initialzoom     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view .
    METHODS spots
      IMPORTING
        !id           TYPE clike OPTIONAL
        !items        TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS vos
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS action_sheet
      IMPORTING
        !id                TYPE clike OPTIONAL
        !cancelbuttontext  TYPE clike OPTIONAL
        !placement         TYPE clike OPTIONAL
        !showcancelbutton  TYPE clike OPTIONAL
        !title             TYPE clike OPTIONAL
        !afterclose        TYPE clike OPTIONAL
        !afteropen         TYPE clike OPTIONAL
        !beforeclose       TYPE clike OPTIONAL
        !beforeopen        TYPE clike OPTIONAL
        !cancelbuttonpress TYPE clike OPTIONAL
        !visible           TYPE clike OPTIONAL
        !class             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS expandable_text
      IMPORTING
        !id                 TYPE clike OPTIONAL
        !emptyindicatormode TYPE clike OPTIONAL
        !maxcharacters      TYPE clike OPTIONAL
        !overflowmode       TYPE clike OPTIONAL
        !renderwhitespace   TYPE clike OPTIONAL
        !text               TYPE clike OPTIONAL
        !textalign          TYPE clike OPTIONAL
        !textdirection      TYPE clike OPTIONAL
        !visible            TYPE clike OPTIONAL
        !wrappingtype       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .
    METHODS select
      IMPORTING
        !id                  TYPE clike OPTIONAL
        !autoadjustwidth     TYPE clike OPTIONAL
        !columnratio         TYPE clike OPTIONAL
        !editable            TYPE clike OPTIONAL
        !enabled             TYPE clike OPTIONAL
        !forceselection      TYPE clike OPTIONAL
        !icon                TYPE clike OPTIONAL
        !maxwidth            TYPE clike OPTIONAL
        !name                TYPE clike OPTIONAL
        !required            TYPE clike OPTIONAL
        !resetonmissingkey   TYPE clike OPTIONAL
        !selecteditemid      TYPE clike OPTIONAL
        !selectedkey         TYPE clike OPTIONAL
        !showsecondaryvalues TYPE clike OPTIONAL
        !textalign           TYPE clike OPTIONAL
        !textdirection       TYPE clike OPTIONAL
        !type                TYPE clike OPTIONAL
        !valuestate          TYPE clike OPTIONAL
        !valuestatetext      TYPE clike OPTIONAL
        !visible             TYPE clike OPTIONAL
        !width               TYPE clike OPTIONAL
        !wrapitemstext       TYPE clike OPTIONAL
        !items               TYPE clike OPTIONAL
        !selecteditem        TYPE clike OPTIONAL
        !change              TYPE clike OPTIONAL
        !livechange          TYPE clike OPTIONAL
        !class               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS embedded_control
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS header_container_control
      IMPORTING
        !backgrounddesign TYPE clike OPTIONAL
        !gridlayout       TYPE clike OPTIONAL
        !height           TYPE clike OPTIONAL
        !orientation      TYPE clike OPTIONAL
        !scrollstep       TYPE clike OPTIONAL
        !scrollstepbyitem TYPE clike OPTIONAL
        !scrolltime       TYPE clike OPTIONAL
        !showdividers     TYPE clike OPTIONAL
        !showoverflowitem TYPE clike OPTIONAL
        !visible          TYPE clike OPTIONAL
        !width            TYPE clike OPTIONAL
        !id               TYPE clike OPTIONAL
        !scroll           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS dependents
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS card
      IMPORTING
        !id             TYPE clike OPTIONAL
        !class          TYPE clike OPTIONAL
        !headerposition TYPE clike OPTIONAL
        !height         TYPE clike OPTIONAL
        !visible        TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS card_header
      IMPORTING
        !id                  TYPE clike OPTIONAL
        !class               TYPE clike OPTIONAL
        !iconalt             TYPE clike OPTIONAL
        !iconbackgroundcolor TYPE clike OPTIONAL
        !icondisplayshape    TYPE clike OPTIONAL
        !iconinitials        TYPE clike OPTIONAL
        !iconsize            TYPE clike OPTIONAL
        !iconsrc             TYPE clike OPTIONAL
        !iconvisible         TYPE clike OPTIONAL
        !statustext          TYPE clike OPTIONAL
        !statusvisible       TYPE clike OPTIONAL
        !subtitle            TYPE clike OPTIONAL
        !subtitlemaxlines    TYPE clike OPTIONAL
        !title               TYPE clike OPTIONAL
        !titlemaxlines       TYPE clike OPTIONAL
        !visible             TYPE clike OPTIONAL
        !datatimestamp       TYPE clike OPTIONAL
        !press               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS numeric_header
      IMPORTING
        !id                      TYPE clike OPTIONAL
        !class                   TYPE clike OPTIONAL
        !visible                 TYPE clike OPTIONAL
        !datatimestamp           TYPE clike OPTIONAL
        !press                   TYPE clike OPTIONAL
        !details                 TYPE clike OPTIONAL
        !detailsmaxlines         TYPE clike OPTIONAL
        !detailsstate            TYPE clike OPTIONAL
        !iconalt                 TYPE clike OPTIONAL
        !iconbackgroundcolor     TYPE clike OPTIONAL
        !icondisplayshape        TYPE clike OPTIONAL
        !iconinitials            TYPE clike OPTIONAL
        !iconsize                TYPE clike OPTIONAL
        !iconsrc                 TYPE clike OPTIONAL
        !iconvisible             TYPE clike OPTIONAL
        !number                  TYPE clike OPTIONAL
        !numbersize              TYPE clike OPTIONAL
        !numbervisible           TYPE clike OPTIONAL
        !scale                   TYPE clike OPTIONAL
        !sideindicatorsalignment TYPE clike OPTIONAL
        !state                   TYPE clike OPTIONAL
        !statustext              TYPE clike OPTIONAL
        !statusvisible           TYPE clike OPTIONAL
        !subtitle                TYPE clike OPTIONAL
        !subtitlemaxlines        TYPE clike OPTIONAL
        !title                   TYPE clike OPTIONAL
        !titlemaxlines           TYPE clike OPTIONAL
        !trend                   TYPE clike OPTIONAL
        !unitofmeasurement       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS numeric_side_indicator
      IMPORTING
        !id           TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
        !number       TYPE clike OPTIONAL
        !state        TYPE clike OPTIONAL
        !title        TYPE clike OPTIONAL
        !unit         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS slide_tile
      IMPORTING
        !displaytime    TYPE clike OPTIONAL
        !height         TYPE clike OPTIONAL
        !visible        TYPE clike OPTIONAL
        !scope          TYPE clike OPTIONAL
        !sizebehavior   TYPE clike OPTIONAL
        !transitiontime TYPE clike OPTIONAL
        !press          TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS busy_indicator
      IMPORTING
        !id                      TYPE clike OPTIONAL
        !class                   TYPE clike OPTIONAL
        !customicon              TYPE clike OPTIONAL
        !customiconheight        TYPE clike OPTIONAL
        !customiconrotationspeed TYPE clike OPTIONAL
        !customiconwidth         TYPE clike OPTIONAL
        !size                    TYPE clike OPTIONAL
        !text                    TYPE clike OPTIONAL
        !textdirection           TYPE clike OPTIONAL
        !customicondensityaware  TYPE clike OPTIONAL
        !visible                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view .
    METHODS custom_layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS carousel_layout
      IMPORTING
        !visiblepagescount TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS facet_filter
      IMPORTING
        !id                  TYPE clike OPTIONAL
        !class               TYPE clike OPTIONAL
        !livesearch          TYPE clike OPTIONAL
        !showpersonalization TYPE clike OPTIONAL
        !showpopoverokbutton TYPE clike OPTIONAL
        !showreset           TYPE clike OPTIONAL
        !showsummarybar      TYPE clike OPTIONAL
        !type                TYPE clike OPTIONAL
        !visible             TYPE clike OPTIONAL
        !confirm             TYPE clike OPTIONAL
        !reset               TYPE clike OPTIONAL
        !lists               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
    METHODS facet_filter_list
      IMPORTING
        !id                          TYPE clike OPTIONAL
        !class                       TYPE clike OPTIONAL
        !active                      TYPE clike OPTIONAL
        !allcount                    TYPE clike OPTIONAL
        !backgrounddesign            TYPE clike OPTIONAL
        !datatype                    TYPE clike OPTIONAL
        !enablebusyindicator         TYPE clike OPTIONAL
        !enablecaseinsensitivesearch TYPE clike OPTIONAL
        !footertext                  TYPE clike OPTIONAL
        !growing                     TYPE clike OPTIONAL
        !growingdirection            TYPE clike OPTIONAL
        !growingscrolltoload         TYPE clike OPTIONAL
        !growingthreshold            TYPE clike OPTIONAL
        !growingtriggertext          TYPE clike OPTIONAL
        !headerlevel                 TYPE clike OPTIONAL
        !headertext                  TYPE clike OPTIONAL
        !includeiteminselection      TYPE clike OPTIONAL
        !inset                       TYPE clike OPTIONAL
        !key                         TYPE clike OPTIONAL
        !keyboardmode                TYPE clike OPTIONAL
        !mode                        TYPE clike OPTIONAL
        !modeanimationon             TYPE clike OPTIONAL
        !multiselectmode             TYPE clike OPTIONAL
        !nodatatext                  TYPE clike OPTIONAL
        !rememberselections          TYPE clike OPTIONAL
        !retainlistsequence          TYPE clike OPTIONAL
        !sequence                    TYPE clike OPTIONAL
        !shownodata                  TYPE clike OPTIONAL
        !showremovefaceticon         TYPE clike OPTIONAL
        !showseparators              TYPE clike OPTIONAL
        !showunread                  TYPE clike OPTIONAL
        !sticky                      TYPE clike OPTIONAL
        !swipedirection              TYPE clike OPTIONAL
        !title                       TYPE clike OPTIONAL
        !visible                     TYPE clike OPTIONAL
        !width                       TYPE clike OPTIONAL
        !wordwrap                    TYPE clike OPTIONAL
        !listclose                   TYPE clike OPTIONAL
        !listopen                    TYPE clike OPTIONAL
        !search                      TYPE clike OPTIONAL
        !selectionchange             TYPE clike OPTIONAL
        !delete                      TYPE clike OPTIONAL
        !items                       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view .
    METHODS facet_filter_item
      IMPORTING
        !id            TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
        !count         TYPE clike OPTIONAL
        !counter       TYPE clike OPTIONAL
        !highlight     TYPE clike OPTIONAL
        !highlighttext TYPE clike OPTIONAL
        !key           TYPE clike OPTIONAL
        !navigated     TYPE clike OPTIONAL
        !selected      TYPE clike OPTIONAL
        !text          TYPE clike OPTIONAL
        !type          TYPE clike OPTIONAL
        !unread        TYPE clike OPTIONAL
        !visible       TYPE clike OPTIONAL
        !press         TYPE clike OPTIONAL
        !detailpress   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS draft_indicator
      IMPORTING
        !id             TYPE clike OPTIONAL
        !class          TYPE clike OPTIONAL
        !mindisplaytime TYPE clike OPTIONAL
        !state          TYPE clike OPTIONAL
        !visible        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS html_map
      IMPORTING
        !id           TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !name         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.
    METHODS html_area
      IMPORTING
        !id           TYPE clike OPTIONAL
        !shape        TYPE clike OPTIONAL
        !coords       TYPE clike OPTIONAL
        !alt          TYPE clike OPTIONAL
        !target       TYPE clike OPTIONAL
        !href         TYPE clike OPTIONAL
        !onclick      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS html_canvas
      IMPORTING
        !id           TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !style        TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS notification_list
      IMPORTING
        !id                     TYPE clike OPTIONAL
        !class                  TYPE clike OPTIONAL
        !footertext             TYPE clike OPTIONAL
        !growing                TYPE clike OPTIONAL
        !growingdirection       TYPE clike OPTIONAL
        !growingscrolltoload    TYPE clike OPTIONAL
        !growingthreshold       TYPE clike OPTIONAL
        !growingtriggertext     TYPE clike OPTIONAL
        !headerlevel            TYPE clike OPTIONAL
        !headertext             TYPE clike OPTIONAL
        !includeiteminselection TYPE clike OPTIONAL
        !inset                  TYPE clike OPTIONAL
        !keyboardmode           TYPE clike OPTIONAL
        !mode                   TYPE clike OPTIONAL
        !modeanimationon        TYPE clike OPTIONAL
        !multiselectmode        TYPE clike OPTIONAL
        !nodatatext             TYPE clike OPTIONAL
        !rememberselections     TYPE clike OPTIONAL
        !shownodata             TYPE clike OPTIONAL
        !showseparators         TYPE clike OPTIONAL
        !showunread             TYPE clike OPTIONAL
        !sticky                 TYPE clike OPTIONAL
        !swipedirection         TYPE clike OPTIONAL
        !visible                TYPE clike OPTIONAL
        !width                  TYPE clike OPTIONAL
        !beforeopencontextmenu  TYPE clike OPTIONAL
        !delete                 TYPE clike OPTIONAL
        !growingfinished        TYPE clike OPTIONAL
        !growingstarted         TYPE clike OPTIONAL
        !itempress              TYPE clike OPTIONAL
        !select                 TYPE clike OPTIONAL
        !selectionchange        TYPE clike OPTIONAL
        !swipe                  TYPE clike OPTIONAL
        !updatefinished         TYPE clike OPTIONAL
        !updatestarted          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)           TYPE REF TO z2ui5_cl_xml_view .
    METHODS notification_list_group
      IMPORTING
        !id                            TYPE clike OPTIONAL
        !autopriority                  TYPE clike OPTIONAL
        !collapsed                     TYPE clike OPTIONAL
        !enablecollapsebuttonwhenempty TYPE clike OPTIONAL
        !highlight                     TYPE clike OPTIONAL
        !highlighttext                 TYPE clike OPTIONAL
        !navigated                     TYPE clike OPTIONAL
        !priority                      TYPE clike OPTIONAL
        !selected                      TYPE clike OPTIONAL
        !showbuttons                   TYPE clike OPTIONAL
        !showclosebutton               TYPE clike OPTIONAL
        !showemptygroup                TYPE clike OPTIONAL
        !showitemscounter              TYPE clike OPTIONAL
        !title                         TYPE clike OPTIONAL
        !type                          TYPE clike OPTIONAL
        !unread                        TYPE clike OPTIONAL
        !visible                       TYPE clike OPTIONAL
        !class                         TYPE clike OPTIONAL
        !oncollapse                    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view .
    METHODS notification_list_item
      IMPORTING
        !id                 TYPE clike OPTIONAL
        !visible            TYPE clike OPTIONAL
        !class              TYPE clike OPTIONAL
        !authoravatarcolor  TYPE clike OPTIONAL
        !authorinitials     TYPE clike OPTIONAL
        !description        TYPE clike OPTIONAL
        !hideshowmorebutton TYPE clike OPTIONAL
        !truncate           TYPE clike OPTIONAL
        !authorname         TYPE clike OPTIONAL
        !authorpicture      TYPE clike OPTIONAL
        !counter            TYPE clike OPTIONAL
        !datetime           TYPE clike OPTIONAL
        !highlight          TYPE clike OPTIONAL
        !highlighttext      TYPE clike OPTIONAL
        !navigated          TYPE clike OPTIONAL
        !priority           TYPE clike OPTIONAL
        !selected           TYPE clike OPTIONAL
        !showbuttons        TYPE clike OPTIONAL
        !showclosebutton    TYPE clike OPTIONAL
        !title              TYPE clike OPTIONAL
        !type               TYPE clike OPTIONAL
        !unread             TYPE clike OPTIONAL
        !close              TYPE clike OPTIONAL
        !detailpress        TYPE clike OPTIONAL
        !press              TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .

  PROTECTED SECTION.
    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mt_prop  TYPE SORTED TABLE OF z2ui5_if_types=>ty_s_name_value WITH NON-UNIQUE KEY n.

    DATA mt_ns  TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
    DATA mo_root   TYPE REF TO z2ui5_cl_xml_view.
    DATA mo_previous   TYPE REF TO z2ui5_cl_xml_view.
    DATA mo_parent TYPE REF TO z2ui5_cl_xml_view.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view WITH EMPTY KEY.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_xml_view IMPLEMENTATION.


  METHOD actions.
    result = _generic( name = `actions`
                       ns   = ns ).
  ENDMETHOD.


  METHOD action_sheet.
    result = _generic( name   = `ActionSheet`
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
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD additional_content.
    result = _generic( `additionalContent` ).
  ENDMETHOD.


  METHOD additional_numbers.
    result = _generic( `additionalNumbers` ).
  ENDMETHOD.


  METHOD analytic_map.

    result = _generic( name  = `AnalyticMap`
                      ns     = `vbm`
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showLabel`    v = z2ui5_cl_util=>boolean_abap_2_json( showlabel ) )
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
                                ( n = `showBorder`       v = z2ui5_cl_util=>boolean_abap_2_json( showborder ) )
                                ( n = `decorative`       v = z2ui5_cl_util=>boolean_abap_2_json( decorative ) )
                                ( n = `enabled`       v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                                ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).
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
                                         ( n = `selectable`                v = z2ui5_cl_util=>boolean_abap_2_json( selectable ) )
                                         ( n = `selectedFill`              v = selectedfill )
                                         ( n = `fill`                      v = fill )
                                         ( n = `height`                    v = height )
                                         ( n = `title`                     v = title )
                                         ( n = `animationSettings`         v = animationsettings )
                                         ( n = `alignShape`                v = alignshape )
                                         ( n = `color`                     v = color )
                                         ( n = `fontSize`                  v = fontsize )
                                         ( n = `connectable`               v = z2ui5_cl_util=>boolean_abap_2_json( connectable ) )
                                         ( n = `fontFamily`                v = fontfamily )
                                         ( n = `filter`                    v = filter )
                                         ( n = `transform`                 v = transform )
                                         ( n = `countInBirdEye`            v = z2ui5_cl_util=>boolean_abap_2_json( countinbirdeye ) )
                                         ( n = `fontWeight`                v = fontweight )
                                         ( n = `showTitle`                 v = z2ui5_cl_util=>boolean_abap_2_json( showtitle ) )
                                         ( n = `selected`                  v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                                         ( n = `resizable`                 v = z2ui5_cl_util=>boolean_abap_2_json( resizable ) )
                                         ( n = `horizontalTextAlignment`   v = horizontaltextalignment )
                                         ( n = `highlighted`               v = z2ui5_cl_util=>boolean_abap_2_json( highlighted ) )
                                         ( n = `highlightable`             v = z2ui5_cl_util=>boolean_abap_2_json( highlightable ) ) ) ).
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showActualValue`    v = z2ui5_cl_util=>boolean_abap_2_json( showactualvalue ) )
                                ( n = `showActualValueInDeltaMode`    v = z2ui5_cl_util=>boolean_abap_2_json( savidm ) )
                                ( n = `showDeltaValue`    v = z2ui5_cl_util=>boolean_abap_2_json( showdeltavalue ) )
                                ( n = `showTargetValue`    v = z2ui5_cl_util=>boolean_abap_2_json( showtargetvalue ) )
                                ( n = `showThresholds`    v = z2ui5_cl_util=>boolean_abap_2_json( showthresholds ) )
                                ( n = `showValueMarker`    v = z2ui5_cl_util=>boolean_abap_2_json( showvaluemarker ) )
                                ( n = `smallRangeAllowed`    v = z2ui5_cl_util=>boolean_abap_2_json( smallrangeallowed ) )
                                ( n = `forecastValue`  v = forecastvalue ) ) ).
  ENDMETHOD.


  METHOD busy_indicator.
    result = _generic( name = `BusyIndicator`
                   t_prop   = VALUE #(
                         ( n = `id`  v = id )
                         ( n = `class`  v = class )
                         ( n = `customIcon`  v = customicon )
                         ( n = `customIconHeight`         v = customiconheight )
                         ( n = `customIconRotationSpeed`  v = customiconrotationspeed )
                         ( n = `customIconWidth`             v = customiconwidth )
                         ( n = `size`        v = size )
                         ( n = `text`         v = text )
                         ( n = `textDirection`       v = textdirection )
                         ( n = `customIconDensityAware`           v = z2ui5_cl_util=>boolean_abap_2_json( customicondensityaware ) )
                         ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD button.

    result = me.
    _generic( name   = `Button`
              ns     = ns
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `iconDensityAware` v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) )
                                ( n = `iconFirst` v = z2ui5_cl_util=>boolean_abap_2_json( iconfirst ) )
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
    result = _generic( name = `Card`
                       ns   = `f`
                   t_prop   = VALUE #(
                         ( n = `id`  v = id )
                         ( n = `class`  v = class )
                         ( n = `headerPosition`  v = headerposition )
                         ( n = `height`  v = height )
                         ( n = `width`  v = width )
                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD card_header.
    result = _generic( name = `Header`
                       ns   = `f`
                   t_prop   = VALUE #(
                         ( n = `id`  v = id )
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
                         ( n = `iconVisible`  v = z2ui5_cl_util=>boolean_abap_2_json( iconvisible ) )
                         ( n = `visible`    v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD carousel.

    result = _generic( name   = `Carousel`
                       t_prop = VALUE #( ( n = `loop`  v = z2ui5_cl_util=>boolean_abap_2_json( loop ) )
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
                                         ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
               ) ).

  ENDMETHOD.


  METHOD carousel_layout.
    result = _generic( name = `CarouselLayout`
                   t_prop   = VALUE #(
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
                                ( n = `activeHandling`  v = z2ui5_cl_util=>boolean_abap_2_json( activehandling ) )
                                ( n = `enabled`  v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `displayOnly`  v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ) )
                                ( n = `editable`  v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                ( n = `partiallySelected`  v = z2ui5_cl_util=>boolean_abap_2_json( partiallyselected ) )
                                ( n = `useEntireWidth`  v = z2ui5_cl_util=>boolean_abap_2_json( useentirewidth ) )
                                ( n = `wrapping`  v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
                                ( n = `select`   v = select ) ) ).
  ENDMETHOD.


  METHOD code_editor.
    result = me.
    _generic( name   = `CodeEditor`
              ns     = `editor`
              t_prop = VALUE #( ( n = `value`   v = value )
                                ( n = `type`    v = type )
                                ( n = `editable`   v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
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
                                         ( n = `mergeDuplicates` v = z2ui5_cl_util=>boolean_abap_2_json( mergeduplicates ) )
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `demandPopin` v = z2ui5_cl_util=>boolean_abap_2_json( demandpopin ) ) ) ).
  ENDMETHOD.


  METHOD columns.
    result = _generic( `columns` ).
  ENDMETHOD.


  METHOD column_element_data.
    result = _generic( name    = `ColumnElementData`
                       ns      = `form`
                        t_prop = VALUE #( ( n = `cellsLarge` v = cellslarge )
                                          ( n = `cellsSmall` v = cellssmall ) ) ).
  ENDMETHOD.


  METHOD column_list_item.
    result = _generic( name   = `ColumnListItem`
                       t_prop = VALUE #( ( n = `vAlign`   v = valign )
                                         ( n = `id` v = id )
                                         ( n = `selected` v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                                         ( n = `unread` v = z2ui5_cl_util=>boolean_abap_2_json( unread ) )
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `type`     v = type )
                                         ( n = `counter`     v = counter )
                                         ( n = `highlight`     v = highlight )
                                         ( n = `highlightText`     v = highlighttext )
                                         ( n = `detailPress`     v = detailpress )
                                         ( n = `navigated`     v = z2ui5_cl_util=>boolean_abap_2_json( navigated ) )
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `allowColumnLabels`    v = z2ui5_cl_util=>boolean_abap_2_json( allowcolumnlabels ) )
                                ( n = `showBottomLabels`    v = z2ui5_cl_util=>boolean_abap_2_json( showbottomlabels ) )
                                ( n = `showTopLabels`    v = z2ui5_cl_util=>boolean_abap_2_json( showtoplabels ) )
                                ( n = `height`  v = height ) ) ).
  ENDMETHOD.


  METHOD combobox.
    result = _generic( name   = `ComboBox`
                       t_prop = VALUE #( (  n = `showClearIcon` v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ) )
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
                                         (  n = `showSecondaryValues`         v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ) )
                                         (  n = `visible`         v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         (  n = `showValueStateMessage`         v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ) )
                                         (  n = `showButton`         v = z2ui5_cl_util=>boolean_abap_2_json( showbutton ) )
                                         (  n = `required`         v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                         (  n = `editable`         v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                         (  n = `enabled`         v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         (  n = `filterSecondaryValues`         v = z2ui5_cl_util=>boolean_abap_2_json( filtersecondaryvalues ) )
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `shrinkable`    v = z2ui5_cl_util=>boolean_abap_2_json( shrinkable ) )
                                ( n = `view`  v = view ) ) ).
  ENDMETHOD.


  METHOD constructor.


  ENDMETHOD.


  METHOD container_content.

    result = _generic( name  = `ContainerContent`
                      ns     = `vk`
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
                                         ( n = `alignCustomContentToRight` v = z2ui5_cl_util=>boolean_abap_2_json( aligncustomcontenttoright ) )
                                         ( n = `findMode`                  v = findmode )
                                         ( n = `infoOfSelectItems`         v = infoofselectitems )
                                         ( n = `showBirdEyeButton`         v = z2ui5_cl_util=>boolean_abap_2_json( showbirdeyebutton ) )
                                         ( n = `showDisplayTypeButton`     v = z2ui5_cl_util=>boolean_abap_2_json( showdisplaytypebutton ) )
                                         ( n = `showLegendButton`          v = z2ui5_cl_util=>boolean_abap_2_json( showlegendbutton ) )
                                         ( n = `showSettingButton`         v = z2ui5_cl_util=>boolean_abap_2_json( showsettingbutton ) )
                                         ( n = `showTimeZoomControl`       v = z2ui5_cl_util=>boolean_abap_2_json( showtimezoomcontrol ) )
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
    result = _generic( `customLayout` ).
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
                                ( n = `displayFormatType`         v = displayformattype )
                                ( n = `valueFormat`           v = valueformat )
                                ( n = `required`              v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
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
                                ( n = `enabled`               v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`               v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `editable`              v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                ( n = `hideInput`             v = z2ui5_cl_util=>boolean_abap_2_json( hideinput ) )
                                ( n = `showFooter`            v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ) )
                                ( n = `showCurrentDateButton` v = z2ui5_cl_util=>boolean_abap_2_json( showcurrentdatebutton ) ) ) ).
  ENDMETHOD.


  METHOD date_time_picker.
    result = me.
    _generic( name   = `DateTimePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder`  v = placeholder )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
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

    result = _generic( name   = `Dialog`
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
                                         ( n = `closeOnNavigation`  v = z2ui5_cl_util=>boolean_abap_2_json( closeonnavigation ) )
                                         ( n = `draggable`  v = z2ui5_cl_util=>boolean_abap_2_json( draggable ) )
                                         ( n = `resizable`  v = z2ui5_cl_util=>boolean_abap_2_json( resizable ) )
                                         ( n = `horizontalScrolling`  v = z2ui5_cl_util=>boolean_abap_2_json( horizontalscrolling ) )
                                         ( n = `verticalScrolling`  v = z2ui5_cl_util=>boolean_abap_2_json( verticalscrolling ) )
                                         ( n = `afterOpen`  v = afteropen )
                                         ( n = `beforeClose`  v = beforeclose )
                                         ( n = `beforeOpen`  v = beforeopen )
                                         ( n = `afterClose` v = afterclose ) ) ).
  ENDMETHOD.


  METHOD draft_indicator.
    result = _generic( name   = `DraftIndicator`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `minDisplayTime`  v = mindisplaytime )
                             ( n = `state`  v = state )
                             ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD dynamic_page.
    result = _generic( name   = `DynamicPage`
                       ns     = `f`
                       t_prop = VALUE #(
                           (  n = `headerExpanded`           v = z2ui5_cl_util=>boolean_abap_2_json( headerexpanded ) )
                           (  n = `headerPinned`           v = z2ui5_cl_util=>boolean_abap_2_json( headerpinned ) )
                           (  n = `showFooter`           v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ) )
                           (  n = `toggleHeaderOnTitleClick` v = toggleheaderontitleclick ) ) ).
  ENDMETHOD.


  METHOD dynamic_page_header.
    result = _generic(
                 name   = `DynamicPageHeader`
                 ns     = `f`
                 t_prop = VALUE #( (  n = `pinnable`           v = z2ui5_cl_util=>boolean_abap_2_json( pinnable ) ) ) ).
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
    result = _generic( name   = `ExpandableText`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `emptyIndicatorMode`  v = emptyindicatormode )
                             ( n = `maxCharacters`         v = maxcharacters )
                             ( n = `overflowMode`  v = overflowmode )
                             ( n = `renderWhitespace`             v = z2ui5_cl_util=>boolean_abap_2_json( renderwhitespace ) )
                             ( n = `text`        v = text )
                             ( n = `textAlign`         v = textalign )
                             ( n = `textDirection`       v = textdirection )
                             ( n = `wrappingType` v = wrappingtype )
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
    result = _generic( name   = `FacetFilter`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `liveSearch`  v = z2ui5_cl_util=>boolean_abap_2_json( livesearch ) )
                             ( n = `showPersonalization` v = z2ui5_cl_util=>boolean_abap_2_json( showpersonalization ) )
                             ( n = `showPopoverOKButton`  v = z2ui5_cl_util=>boolean_abap_2_json( showpopoverokbutton ) )
                             ( n = `showReset`             v = z2ui5_cl_util=>boolean_abap_2_json( showreset ) )
                             ( n = `showSummaryBar`        v = z2ui5_cl_util=>boolean_abap_2_json( showsummarybar ) )
                             ( n = `type`         v = type )
                             ( n = `confirm`        v = confirm )
                             ( n = `reset` v = reset )
                             ( n = `lists` v = lists )
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD facet_filter_item.
    result = _generic( name   = `FacetFilterItem`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `count`  v = count )
                             ( n = `counter` v = counter )
                             ( n = `highlight`  v = highlight )
                             ( n = `highlightText` v = highlighttext )
                             ( n = `key`        v = key )
                             ( n = `navigated`  v = z2ui5_cl_util=>boolean_abap_2_json( navigated ) )
                             ( n = `selected`  v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                             ( n = `unread`   v = z2ui5_cl_util=>boolean_abap_2_json( unread ) )
                             ( n = `text`       v = text )
                             ( n = `type`        v = type )
                             ( n = `detailPress` v = detailpress )
                             ( n = `press` v = press )
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD facet_filter_list.
    result = _generic( name   = `FacetFilterList`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `active`  v = z2ui5_cl_util=>boolean_abap_2_json( active ) )
                             ( n = `allCount`  v = allcount )
                             ( n = `backgroundDesign`         v = backgrounddesign )
                             ( n = `dataType`  v = datatype )
                             ( n = `enableBusyIndicator` v = z2ui5_cl_util=>boolean_abap_2_json( enablebusyindicator ) )
                             ( n = `enableCaseInsensitiveSearch` v = z2ui5_cl_util=>boolean_abap_2_json( enablecaseinsensitivesearch ) )
                             ( n = `footerText`         v = footertext )
                             ( n = `growing`       v = z2ui5_cl_util=>boolean_abap_2_json( growing ) )
                             ( n = `growingDirection`        v = growingdirection )
                             ( n = `growingScrollToLoad` v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ) )
                             ( n = `growingThreshold` v = growingthreshold )
                             ( n = `growingTriggerText` v = growingtriggertext )
                             ( n = `headerLevel` v = headerlevel )
                             ( n = `includeItemInSelection` v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ) )
                             ( n = `inset` v = z2ui5_cl_util=>boolean_abap_2_json( inset ) )
                             ( n = `key` v = key )
                             ( n = `swipedirection` v = swipedirection )
                             ( n = `headerText` v = headertext )
                             ( n = `keyboardMode` v = keyboardmode )
                             ( n = `mode` v = mode )
                             ( n = `modeAnimationOn` v = z2ui5_cl_util=>boolean_abap_2_json( modeanimationon ) )
                             ( n = `multiSelectMode` v = multiselectmode )
                             ( n = `noDataText` v = nodatatext )
                             ( n = `rememberSelections` v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ) )
                             ( n = `retainListSequence` v = z2ui5_cl_util=>boolean_abap_2_json( retainlistsequence ) )
                             ( n = `sequence` v = sequence )
                             ( n = `showNoData` v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ) )
                             ( n = `showRemoveFacetIcon` v = z2ui5_cl_util=>boolean_abap_2_json( showremovefaceticon ) )
                             ( n = `showSeparators` v = showseparators )
                             ( n = `showUnread` v = z2ui5_cl_util=>boolean_abap_2_json( showunread ) )
                             ( n = `sticky` v = sticky )
                             ( n = `title` v = title )
                             ( n = `width` v = width )
                             ( n = `wordWrap` v = z2ui5_cl_util=>boolean_abap_2_json( wordwrap ) )
                             ( n = `listClose` v = listclose )
                             ( n = `listOpen` v = listopen )
                             ( n = `search` v = search )
                             ( n = `selectionChange` v = selectionchange )
                             ( n = `delete` v = delete )
                             ( n = `items` v = items )
                             ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

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
                                         ( n = `enabled`          v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         ( n = `growing`          v = z2ui5_cl_util=>boolean_abap_2_json( growing ) )
                                         ( n = `growingMaxLines`  v = growingmaxlines )
                                         ( n = `icon`             v = icon )
                                         ( n = `iconDensityAware` v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `iconDisplayShape` v = icondisplayshape )
                                         ( n = `iconInitials`     v = iconinitials )
                                         ( n = `iconSize`         v = iconsize )
                                         ( n = `maxLength`        v = maxlength )
                                         ( n = `placeholder`      v = placeholder )
                                         ( n = `rows`             v = rows )
                                         ( n = `showExceededText` v = z2ui5_cl_util=>boolean_abap_2_json( showexceededtext ) )
                                         ( n = `showIcon`         v = z2ui5_cl_util=>boolean_abap_2_json( showicon ) )
                                         ( n = `value`            v = value )
                                         ( n = `class`            v = class )
                                         ( n = `post`             v = post ) ) ).

  ENDMETHOD.


  METHOD feed_list_item.
    result = _generic( name   = `FeedListItem`
                       t_prop = VALUE #( ( n = `activeIcon`                  v = activeicon )
                                         ( n = `convertedLinksDefaultTarget` v = convertedlinksdefaulttarget )
                                         ( n = `convertLinksToAnchorTags`    v = convertlinkstoanchortags )
                                         ( n = `iconActive`                  v = z2ui5_cl_util=>boolean_abap_2_json( iconactive ) )
                                         ( n = `icon`                        v = icon )
                                         ( n = `iconDensityAware`            v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `iconDisplayShape`            v = icondisplayshape )
                                         ( n = `iconInitials`                v = iconinitials )
                                         ( n = `iconSize`                    v = iconsize )
                                         ( n = `info`                        v = info )
                                         ( n = `lessLabel`                   v = lesslabel )
                                         ( n = `maxCharacters`               v = maxcharacters )
                                         ( n = `moreLabel`                   v = morelabel )
                                         ( n = `sender`                      v = sender )
                                         ( n = `senderActive`                v = z2ui5_cl_util=>boolean_abap_2_json( senderactive ) )
                                         ( n = `showIcon`                    v = z2ui5_cl_util=>boolean_abap_2_json( showicon ) )
                                         ( n = `text`                        v = text )
                                         ( n = `senderPress`                 v = senderpress )
                                         ( n = `iconPress`                   v = iconpress )
                                         ( n = `timestamp`                   v = timestamp ) ) ).
  ENDMETHOD.


  METHOD feed_list_item_action.
    result = _generic( name    = `FeedListItemAction`
                        t_prop = VALUE #( ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                          ( n = `icon`    v = icon )
                                          ( n = `key`     v = key )
                                          ( n = `text`    v = text )
                                          ( n = `press`   v = press )
                                          ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD filter_bar.

    result = _generic( name   = `FilterBar`
                       ns     = 'fb'
                       t_prop = VALUE #( ( n = 'useToolbar'     v = z2ui5_cl_util=>boolean_abap_2_json( usetoolbar ) )
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
                                         ( n = 'advancedMode' v = z2ui5_cl_util=>boolean_abap_2_json( advancedmode ) )
                                         ( n = 'isRunningInValueHelpDialog' v = z2ui5_cl_util=>boolean_abap_2_json( isrunninginvaluehelpdialog ) )
                                         ( n = 'showAllFilters' v = z2ui5_cl_util=>boolean_abap_2_json( showallfilters ) )
                                         ( n = 'showClearOnFB' v = z2ui5_cl_util=>boolean_abap_2_json( showclearonfb ) )
                                         ( n = 'showFilterConfiguration' v = z2ui5_cl_util=>boolean_abap_2_json( showfilterconfiguration ) )
                                         ( n = 'showGoOnFB' v = z2ui5_cl_util=>boolean_abap_2_json( showgoonfb ) )
                                         ( n = 'showRestoreButton' v = z2ui5_cl_util=>boolean_abap_2_json( showrestorebutton ) )
                                         ( n = 'showRestoreOnFB' v = z2ui5_cl_util=>boolean_abap_2_json( showrestoreonfb ) )
                                         ( n = 'useSnapshot' v = z2ui5_cl_util=>boolean_abap_2_json( usesnapshot ) )
                                         ( n = 'searchEnabled' v = z2ui5_cl_util=>boolean_abap_2_json( searchenabled ) )
                                         ( n = 'considerGroupTitle' v = z2ui5_cl_util=>boolean_abap_2_json( considergrouptitle ) )
                                         ( n = 'deltaVariantMode' v = z2ui5_cl_util=>boolean_abap_2_json( deltavariantmode ) )
                                         ( n = 'disableSearchMatchesPatternWarning' v = z2ui5_cl_util=>boolean_abap_2_json( disablesearchmatchespatternw ) )
                                         ( n = 'filterBarExpanded' v = z2ui5_cl_util=>boolean_abap_2_json( filterbarexpanded ) )
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
    result = _generic( `filterItems` ).
  ENDMETHOD.


  METHOD first_status.
    result = _generic( `firstStatus` ).
  ENDMETHOD.


  METHOD flexible_column_layout.

    result = _generic( name   = `FlexibleColumnLayout`
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
                        (  n = `autoFocus` v = z2ui5_cl_util=>boolean_abap_2_json( autofocus ) )
                        (  n = `restoreFocusOnBackNavigation` v = z2ui5_cl_util=>boolean_abap_2_json( restorefocusonbacknavigation ) )
                        ) ).

  ENDMETHOD.


  METHOD flex_box.
    result = _generic( name   = `FlexBox`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `renderType`  v = rendertype )
                                         ( n = `width`  v = width )
                                         ( n = `height`  v = height )
                                         ( n = `alignItems`  v = alignitems )
                                         ( n = `fitContainer`  v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ) )
                                         ( n = `justifyContent`  v = justifycontent )
                                         ( n = `wrap`  v = wrap )
                                         ( n = `direction`  v = direction )
                                         ( n = `alignContent`  v = aligncontent )
                                         ( n = `backgroundDesign`  v = backgrounddesign )
                                         ( n = `displayInline`  v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ) )
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
                                ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                ( n = `renderOnThemeChange`  v = z2ui5_cl_util=>boolean_abap_2_json( renderonthemechange ) )
                ( n = `enableNavigationButton`  v = z2ui5_cl_util=>boolean_abap_2_json( enablenavigationbutton ) )
                ( n = `pressEnabled`  v = z2ui5_cl_util=>boolean_abap_2_json( pressenabled ) )
                ( n = `iconLoaded`  v = z2ui5_cl_util=>boolean_abap_2_json( iconloaded ) )
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
    result = _generic( `groupItems` ).
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `formattedLabel`    v = z2ui5_cl_util=>boolean_abap_2_json( formattedlabel ) )
                                ( n = `showFractions`    v = z2ui5_cl_util=>boolean_abap_2_json( showfractions ) )
                                ( n = `showTotal`    v = z2ui5_cl_util=>boolean_abap_2_json( showtotal ) )
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
                                         ( n = `backgroundDesign`           v = backgrounddesign )
                                         ( n = `direction`           v = direction )
                                         ( n = `displayInline`           v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ) )
                                         ( n = `fitContainer`           v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ) )
                                         ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `justifyContent` v = justifycontent ) ) ).

  ENDMETHOD.


  METHOD header.
    result = _generic( name = `header`
                       ns   = ns ).
  ENDMETHOD.


  METHOD header_container.
    result = _generic( `headerContainer` ).
  ENDMETHOD.


  METHOD header_container_control.
    result = _generic( name   = `HeaderContainer`
                       t_prop = VALUE #( ( n = `backgroundDesign` v = backgrounddesign )
                                         ( n = `gridLayout` v = z2ui5_cl_util=>boolean_abap_2_json( gridlayout ) )
                                         ( n = `height` v = height )
                                         ( n = `orientation` v = orientation )
                                         ( n = `scrollStep` v = scrollstep )
                                         ( n = `scrollStepByItem` v = scrollstepbyitem )
                                         ( n = `scrollTime` v = scrolltime )
                                         ( n = `showDividers` v = z2ui5_cl_util=>boolean_abap_2_json( showdividers ) )
                                         ( n = `showOverflowItem` v = z2ui5_cl_util=>boolean_abap_2_json( showoverflowitem ) )
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                                         ( n = `allowWrapping`  v = z2ui5_cl_util=>boolean_abap_2_json( allowwrapping ) )
                                         ( n = `id`  v = id )
                                         ( n = `visible`  v = visible ) ) ).
  ENDMETHOD.


  METHOD html.

    result = _generic( name   = `HTML`
                       ns     = `core`
                       t_prop = VALUE #(
                          ( n = 'id' v = id )
                          ( n = 'content' v = content )
                          ( n = 'afterRendering' v = afterrendering )
                          ( n = 'preferDOM' v = z2ui5_cl_util=>boolean_abap_2_json( preferdom ) )
                          ( n = 'sanitizeContent' v = z2ui5_cl_util=>boolean_abap_2_json( sanitizecontent ) )
                          ( n = 'visible' v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                          ) ).

  ENDMETHOD.


  METHOD html_area.
    result = _generic( name   = `area`
                       ns     = 'html'
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
    result = _generic( name   = `canvas`
                       ns     = `html`
                       t_prop = VALUE #(
                             ( n = `id`     v = id )
                             ( n = `class`  v = class )
                             ( n = `width`  v = width )
                             ( n = `height` v = height )
                             ( n = `style`  v = style )
                         ) ).
  ENDMETHOD.


  METHOD html_map.
    result = _generic( name   = `map`
                       ns     = 'html'
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
                                ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `decorative`  v = z2ui5_cl_util=>boolean_abap_2_json( decorative ) )
                                ( n = `noTabStop`  v = z2ui5_cl_util=>boolean_abap_2_json( notabstop ) )
                                ( n = `useIconTooltip`  v = z2ui5_cl_util=>boolean_abap_2_json( useicontooltip ) )
                             ) ).

  ENDMETHOD.


  METHOD icon_tab_bar.

    result = _generic( name   = `IconTabBar`
                       t_prop = VALUE #( ( n = `class`       v = class )
                                       ( n = `select`      v = select )
                                       ( n = `expand`      v = expand )
                                       ( n = `expandable`  v = z2ui5_cl_util=>boolean_abap_2_json( expandable ) )
                                       ( n = `expanded`    v = z2ui5_cl_util=>boolean_abap_2_json( expanded ) )
                                       ( n = `applyContentPadding`    v = z2ui5_cl_util=>boolean_abap_2_json( applycontentpadding ) )
                                       ( n = `backgroundDesign`    v = backgrounddesign )
                                       ( n = `enableTabReordering`    v = z2ui5_cl_util=>boolean_abap_2_json( enabletabreordering ) )
                                       ( n = `headerBackgroundDesign`    v = headerbackgrounddesign )
                                       ( n = `stretchContentHeight`    v = z2ui5_cl_util=>boolean_abap_2_json( stretchcontentheight ) )
                                       ( n = `headerMode`    v = headermode )
                                       ( n = `maxNestingLevel`    v = maxnestinglevel )
                                       ( n = `tabDensityMode`    v = tabdensitymode )
                                       ( n = `tabsOverflowMode`    v = tabsoverflowmode )
                                       ( n = `items`    v = items )
                                       ( n = `id`    v = id )
                                       ( n = `content`    v = content )
                                       ( n = `upperCase`    v = z2ui5_cl_util=>boolean_abap_2_json( uppercase ) )
                                       ( n = `selectedKey` v = selectedkey ) ) ).
  ENDMETHOD.


  METHOD icon_tab_filter.

    result = _generic( name   = `IconTabFilter`
                       t_prop = VALUE #( ( n = `icon`        v = icon )
                                       (  n = `items`    v = items )
                                       (  n = `design`    v = design )
                                       ( n = `iconColor`   v = iconcolor )
                                       ( n = `showAll`     v = z2ui5_cl_util=>boolean_abap_2_json( showall ) )
                                       ( n = `iconDensityAware`     v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) )
                                       ( n = `visible`     v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                       ( n = `count`       v = count )
                                       ( n = `text`        v = text )
                                       ( n = `id`        v = id )
                                       ( n = `textDirection`        v = textdirection )
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
                                         (  n = `enableTabReordering`          v = z2ui5_cl_util=>boolean_abap_2_json( enabletabreordering ) )
                                         (  n = `maxNestingLevel`          v = maxnestinglevel )
                                         (  n = `tabDensityMode`          v = tabdensitymode )
                                         (  n = `tabsOverflowMode`          v = tabsoverflowmode )
                                         (  n = `id`          v = id )
                                         (  n = `visible`          v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         (  n = `mode`            v = mode ) ) ).

  ENDMETHOD.


  METHOD icon_tab_separator.

    result = _generic( name    = `IconTabSeparator`
                        t_prop = VALUE #( ( n = `icon` v = icon )
                                          ( n = `iconDensityAware` v = icondensityaware )
                                          ( n = `id` v = id )
                                          ( n = `class` v = class )
                                          ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                        ) ).

  ENDMETHOD.


  METHOD illustrated_message.

    result = _generic( name   = `IllustratedMessage`
                       t_prop = VALUE #( ( n = `enableVerticalResponsiveness` v = enableverticalresponsiveness )
                       ( n = `illustrationType`             v = illustrationtype )
                       ( n = `enableFormattedText`             v = z2ui5_cl_util=>boolean_abap_2_json( enableformattedtext ) )
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
                ( n = `decorative` v = z2ui5_cl_util=>boolean_abap_2_json( decorative ) )
                ( n = `densityAware` v = z2ui5_cl_util=>boolean_abap_2_json( densityaware ) )
                ( n = `lazyLoading` v = z2ui5_cl_util=>boolean_abap_2_json( lazyloading ) )
                 ) ).
  ENDMETHOD.


  METHOD image_content.

    result = _generic( name   = `ImageContent`
                       t_prop = VALUE #( ( n = `src` v = src )
                                         ( n = `description` v = description )
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                       ) ).


  ENDMETHOD.


  METHOD info_label.
    result = _generic( name   = `InfoLabel`
                       ns     = 'tnt'
                       t_prop = VALUE #(
                           ( n = `id`               v = id )
                           ( n = `class`               v = class )
                           ( n = `text`             v = text )
                           ( n = `renderMode `      v = rendermode )
                           ( n = `colorScheme`      v = colorscheme )
                           ( n = `displayOnly`      v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ) )
                           ( n = `icon`             v = icon )
                           ( n = `textDirection`    v = textdirection )
                           ( n = `visible`          v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                           ( n = `width`            v = width ) ) ).

  ENDMETHOD.


  METHOD input.
    result = me.
    _generic( name   = `Input`
              t_prop = VALUE #( ( n = `id`               v = id )
                                ( n = `placeholder`      v = placeholder )
                                ( n = `type`             v = type )
                                ( n = `maxLength`        v = maxlength )
                                ( n = `showClearIcon`    v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ) )
                                ( n = `description`      v = description )
                                ( n = `editable`         v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                ( n = `enabled`          v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`          v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `enableTableAutoPopinMode` v = z2ui5_cl_util=>boolean_abap_2_json( enabletableautopopinmode ) )
                                ( n = `enableSuggestionsHighlighting`  v = z2ui5_cl_util=>boolean_abap_2_json( enablesuggestionshighlighting ) )
                                ( n = `showTableSuggestionValueHelp`   v = z2ui5_cl_util=>boolean_abap_2_json( showtablesuggestionvaluehelp ) )
                                ( n = `valueState`       v = valuestate )
                                ( n = `valueStateText`   v = valuestatetext )
                                ( n = `value`            v = value )
                                ( n = `required`          v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                ( n = `suggest`          v = suggest )
                                ( n = `suggestionItems`  v = suggestionitems )
                                ( n = `suggestionRows`   v = suggestionrows )
                                ( n = `showSuggestion`   v = z2ui5_cl_util=>boolean_abap_2_json( showsuggestion ) )
                                ( n = `valueHelpRequest` v = valuehelprequest )
                                ( n = `autocomplete`     v = z2ui5_cl_util=>boolean_abap_2_json( autocomplete ) )
                                ( n = `valueLiveUpdate`  v = z2ui5_cl_util=>boolean_abap_2_json( valueliveupdate ) )
                                ( n = `submit`           v = z2ui5_cl_util=>boolean_abap_2_json( submit ) )
                                ( n = `showValueHelp`    v = z2ui5_cl_util=>boolean_abap_2_json( showvaluehelp ) )
                                ( n = `valueHelpOnly`    v = z2ui5_cl_util=>boolean_abap_2_json( valuehelponly ) )
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
                                         ( n = `showError`         v = z2ui5_cl_util=>boolean_abap_2_json( showerror ) )
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
                                         ( n = `showError`         v = z2ui5_cl_util=>boolean_abap_2_json( showerror ) )
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
                                         ( n = `selected`       v = z2ui5_cl_util=>boolean_abap_2_json( selected ) ) ) ).
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
                                ( n = `displayOnly`   v = z2ui5_cl_util=>boolean_abap_2_json( displayonly ) )
                                ( n = `required`   v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                ( n = `showColon`   v = z2ui5_cl_util=>boolean_abap_2_json( showcolon ) )
                                ( n = `textAlign`   v = textalign )
                                ( n = `textDirection`   v = textdirection )
                                ( n = `vAlign`   v = valign )
                                ( n = `width`   v = width )
                                ( n = `wrapping`   v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
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
    result = _generic( name = `LightBox`
                    t_prop  = VALUE #( ( n = `id`         v = id )
                                      ( n = `class`    v = class )
                                      ( n = `visible`    v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD light_box_item.
    result = _generic( name    = `LightBoxItem`
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `showBottomLabels`    v = z2ui5_cl_util=>boolean_abap_2_json( showbottomlabels ) )
                                ( n = `showPoints`    v = z2ui5_cl_util=>boolean_abap_2_json( showpoints ) )
                                ( n = `showThresholdLine`    v = z2ui5_cl_util=>boolean_abap_2_json( showthresholdline ) )
                                ( n = `showThresholdValue`    v = z2ui5_cl_util=>boolean_abap_2_json( showthresholdvalue ) )
                                ( n = `showTopLabels`    v = z2ui5_cl_util=>boolean_abap_2_json( showtoplabels ) )
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
                                ( n = `subtle`      v = z2ui5_cl_util=>boolean_abap_2_json( subtle ) )
                                ( n = `textAlign`      v = textalign )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `validateUrl`      v = z2ui5_cl_util=>boolean_abap_2_json( validateurl ) )
                                ( n = `width`      v = width )
                                ( n = `wrapping`      v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
                                ( n = `emphasized`      v = z2ui5_cl_util=>boolean_abap_2_json( emphasized ) )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) ) ) ).
  ENDMETHOD.


  METHOD link_tile_content.
    result = _generic( name = `LinkTileContent`
                   t_prop   = VALUE #(
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
                                         ( n = `modeAnimationOn`        v = z2ui5_cl_util=>boolean_abap_2_json( modeanimationon ) )
                                         ( n = `growingScrollToLoad`    v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ) )
                                         ( n = `includeItemInSelection` v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ) )
                                         ( n = `growing`                v = z2ui5_cl_util=>boolean_abap_2_json( growing ) )
                                         ( n = `inset`                  v = z2ui5_cl_util=>boolean_abap_2_json( inset ) )
                                         ( n = `rememberSelections`     v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ) )
                                         ( n = `showUnread`             v = z2ui5_cl_util=>boolean_abap_2_json( showunread ) )
                                         ( n = `visible`                v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                                ( n = `enabled`        v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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

    result = _generic( name  = `MapContainer`
                      ns     = `vk`
                      t_prop = VALUE #(
                            ( n = `id`  v = id )
                            ( n = `autoAdjustHeight`  v = z2ui5_cl_util=>boolean_abap_2_json( autoadjustheight ) )
                        ) ).

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
                                ( n = `required`              v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                ( n = `showClearIcon`         v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ) )
                                ( n = `visible`               v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                                         ( n = `activeTitle`         v = z2ui5_cl_util=>boolean_abap_2_json( activetitle ) )
                                         ( n = `counter`             v = counter )
                                         ( n = `markupDescription`   v = z2ui5_cl_util=>boolean_abap_2_json( markupdescription ) ) ) ).
  ENDMETHOD.


  METHOD message_page.
    result = _generic( name   = `MessagePage`
                       t_prop = VALUE #(
                           ( n = `showHeader`          v = z2ui5_cl_util=>boolean_abap_2_json( show_header ) )
                           ( n = `description`         v = description )
                           ( n = `icon`                v = icon )
                           ( n = `text`                v = text )
                           ( n = `enableFormattedText` v = z2ui5_cl_util=>boolean_abap_2_json( enableformattedtext ) )
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
                                         ( n = `initiallyExpanded` v = z2ui5_cl_util=>boolean_abap_2_json( initiallyexpanded ) )
                                         ( n = `groupItems`        v = z2ui5_cl_util=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.


  METHOD message_strip.
    result = me.
    _generic( name   = `MessageStrip`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `type`     v = type )
                                ( n = `showIcon` v = z2ui5_cl_util=>boolean_abap_2_json( showicon ) )
                                ( n = `class`    v = class ) ) ).
  ENDMETHOD.


  METHOD message_view.

    result = _generic( name   = `MessageView`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = z2ui5_cl_util=>boolean_abap_2_json( groupitems ) ) ) ).
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
                                         (  n = `selectedItems`        v = selecteditems )
                                         (  n = `items`               v = items )
                                         (  n = `selectionFinish`     v = selectionfinish )
                                         (  n = `width`               v = width )
                                         (  n = `showSecondaryValues` v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ) )
                                         (  n = `placeholder`         v = placeholder )
                                         (  n = `selectedItemId`         v = selecteditemid )
                                         (  n = `selectedKey`         v = selectedkey )
                                         (  n = `name`                v = name )
                                         (  n = `value`                v = value )
                                         (  n = `valueState`                v = valuestate )
                                         (  n = `valueStateText`                v = valuestatetext )
                                         (  n = `textAlign`                v = textalign )
                                         (  n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         (  n = `showValueStateMessage`  v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ) )
                                         (  n = `showClearIcon`        v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ) )
                                         (  n = `showButton`            v = z2ui5_cl_util=>boolean_abap_2_json( showbutton ) )
                                         (  n = `required`            v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                         (  n = `editable`            v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                         (  n = `enabled`             v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         (  n = `filterSecondaryValues`             v = z2ui5_cl_util=>boolean_abap_2_json( filtersecondaryvalues ) )
                                         (  n = `showSelectAll`       v = showselectall ) ) ).
  ENDMETHOD.


  METHOD multi_input.
    result = _generic( name   = `MultiInput`
                       t_prop = VALUE #( ( n = `tokens` v = tokens )
                                         ( n = `showClearIcon` v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ) )
                                         ( n = `showValueHelp` v = z2ui5_cl_util=>boolean_abap_2_json( showvaluehelp ) )
                                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                        ( n = `initialPage`  v = initialpage )
                        ( n = `id`           v = id )
                        ( n = `height`           v = height )
                        ( n = `width`           v = width )
                        ( n = `autoFocus` v = z2ui5_cl_util=>boolean_abap_2_json( autofocus ) )
                        ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                        ( n = `defaultTransitionName`   v = defaulttransitionname )
                        ) ).

  ENDMETHOD.


  METHOD nodes.
    result = _generic( name = `nodes`
                       ns   = `commons` ).
  ENDMETHOD.


  METHOD notification_list.
    result = _generic( name   = `NotificationList`
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
                             ( n = `growingScrollToLoad`           v = z2ui5_cl_util=>boolean_abap_2_json( growingscrolltoload ) )
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                             ( n = `growing`           v = z2ui5_cl_util=>boolean_abap_2_json( growing ) )
                             ( n = `includeItemInSelection`           v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ) )
                             ( n = `inset`           v = z2ui5_cl_util=>boolean_abap_2_json( inset ) )
                             ( n = `modeAnimationOn`           v = z2ui5_cl_util=>boolean_abap_2_json( modeanimationon ) )
                             ( n = `rememberSelections`           v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ) )
                             ( n = `showNoData`           v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ) )
                             ( n = `showUnread`           v = z2ui5_cl_util=>boolean_abap_2_json( showunread ) )
                         ) ).
  ENDMETHOD.


  METHOD notification_list_group.
    result = _generic( name   = `NotificationListGroup`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `highlight`  v = highlight )
                             ( n = `highlightText`  v = highlighttext )
                             ( n = `priority`  v = priority )
                             ( n = `title`  v = title )
                             ( n = `type`  v = type )
                             ( n = `onCollapse`  v = oncollapse )
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                             ( n = `autoPriority`           v = z2ui5_cl_util=>boolean_abap_2_json( autopriority ) )
                             ( n = `collapsed`           v = z2ui5_cl_util=>boolean_abap_2_json( collapsed ) )
                             ( n = `enableCollapseButtonWhenEmpty`           v = z2ui5_cl_util=>boolean_abap_2_json( enablecollapsebuttonwhenempty ) )
                             ( n = `navigated`           v = z2ui5_cl_util=>boolean_abap_2_json( navigated ) )
                             ( n = `selected`           v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                             ( n = `showButtons`           v = z2ui5_cl_util=>boolean_abap_2_json( showbuttons ) )
                             ( n = `showCloseButton`           v = z2ui5_cl_util=>boolean_abap_2_json( showclosebutton ) )
                             ( n = `showEmptyGroup`           v = z2ui5_cl_util=>boolean_abap_2_json( showemptygroup ) )
                             ( n = `showItemsCounter`           v = z2ui5_cl_util=>boolean_abap_2_json( showitemscounter ) )
                             ( n = `unread`           v = z2ui5_cl_util=>boolean_abap_2_json( unread ) )
                         ) ).
  ENDMETHOD.


  METHOD notification_list_item.
    result = _generic( name   = `NotificationListItem`
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
                             ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                             ( n = `hideShowMoreButton`           v = z2ui5_cl_util=>boolean_abap_2_json( hideshowmorebutton ) )
                             ( n = `truncate`           v = z2ui5_cl_util=>boolean_abap_2_json( truncate ) )
                             ( n = `highlight`           v = z2ui5_cl_util=>boolean_abap_2_json( highlight ) )
                             ( n = `navigated`           v = z2ui5_cl_util=>boolean_abap_2_json( navigated ) )
                             ( n = `selected`           v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                             ( n = `showButtons`           v = z2ui5_cl_util=>boolean_abap_2_json( showbuttons ) )
                             ( n = `showCloseButton`           v = z2ui5_cl_util=>boolean_abap_2_json( showclosebutton ) )
                             ( n = `truncate`           v = z2ui5_cl_util=>boolean_abap_2_json( truncate ) )
                             ( n = `unread`           v = z2ui5_cl_util=>boolean_abap_2_json( unread ) )
                         ) ).
  ENDMETHOD.


  METHOD numeric_content.

    result = _generic( name   = `NumericContent`
                       t_prop = VALUE #( ( n = `value`      v = value )
                                         ( n = `icon`       v = icon )
                                         ( n = `width`       v = width )
                                         ( n = `valueColor`       v = valuecolor )
                                         ( n = `truncateValueTo`       v = truncatevalueto )
                                         ( n = `state`       v = state )
                                         ( n = `scale`       v = scale )
                                         ( n = `indicator`       v = indicator )
                                         ( n = `iconDescription`       v = icondescription )
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `nullifyValue` v = z2ui5_cl_util=>boolean_abap_2_json( nullifyvalue ) )
                                         ( n = `formatterValue` v = z2ui5_cl_util=>boolean_abap_2_json( formattervalue ) )
                                         ( n = `animateTextChange` v = z2ui5_cl_util=>boolean_abap_2_json( animatetextchange ) )
                                         ( n = `adaptiveFontSize` v = z2ui5_cl_util=>boolean_abap_2_json( adaptivefontsize ) )
                                         ( n = `withMargin` v = z2ui5_cl_util=>boolean_abap_2_json( withmargin ) ) ) ).

  ENDMETHOD.


  METHOD numeric_header.

    result = _generic( name = `NumericHeader`
                       ns   = `f`
                   t_prop   = VALUE #(
                         ( n = `id`  v = id )
                         ( n = `class`  v = class )
                         ( n = `datatimestamp`  v = datatimestamp )
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
                         ( n = `statusVisible`           v = z2ui5_cl_util=>boolean_abap_2_json( statusvisible ) )
                         ( n = `numberVisible`           v = z2ui5_cl_util=>boolean_abap_2_json( numbervisible ) )
                         ( n = `iconVisible`           v = z2ui5_cl_util=>boolean_abap_2_json( iconvisible ) )
                         ( n = `visible`           v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                     ) ).
  ENDMETHOD.


  METHOD numeric_side_indicator.
    result = _generic( name   = `NumericSideIndicator`
                       ns     = `f`
                       t_prop = VALUE #(
                             ( n = `id`  v = id )
                             ( n = `class`  v = class )
                             ( n = `unit`  v = unit )
                             ( n = `title`  v = title )
                             ( n = `state`  v = state )
                             ( n = `number`  v = number )
                             ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                         ) ).
  ENDMETHOD.


  METHOD object_attribute.
    result = me.

    _generic( name   = `ObjectAttribute`
              t_prop = VALUE #( ( n = `title`          v = title )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `ariaHasPopup`   v = ariahaspopup )
                                ( n = `press`          v = press )
                                ( n = `active`         v = z2ui5_cl_util=>boolean_abap_2_json( active ) )
                                ( n = `visible`        v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `text`           v = text ) ) ).
  ENDMETHOD.


  METHOD object_header.

    result = _generic( name   = `ObjectHeader`
                       t_prop = VALUE #( ( n = `backgrounddesign`     v = backgrounddesign )
                                         ( n = `condensed`            v = z2ui5_cl_util=>boolean_abap_2_json( condensed ) )
                                         ( n = `fullscreenoptimized`  v = z2ui5_cl_util=>boolean_abap_2_json( fullscreenoptimized ) )
                                         ( n = `icon`                 v = icon )
                                         ( n = `iconactive`           v = z2ui5_cl_util=>boolean_abap_2_json( iconactive ) )
                                         ( n = `iconalt`              v = iconalt )
                                         ( n = `icondensityaware`     v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `icontooltip`          v = icontooltip )
                                         ( n = `imageshape`           v = imageshape )
                                         ( n = `intro`                v = intro )
                                         ( n = `introactive`          v = z2ui5_cl_util=>boolean_abap_2_json( introactive ) )
                                         ( n = `introhref`            v = introhref )
                                         ( n = `introtarget`          v = introtarget )
                                         ( n = `introtextdirection`   v = introtextdirection )
                                         ( n = `number`               v = number )
                                         ( n = `numberstate`          v = numberstate )
                                         ( n = `numbertextdirection`  v = numbertextdirection )
                                         ( n = `numberunit`           v = numberunit )
                                         ( n = `responsive`           v = z2ui5_cl_util=>boolean_abap_2_json( responsive ) )
                                         ( n = `showtitleselector`    v = z2ui5_cl_util=>boolean_abap_2_json( showtitleselector ) )
                                         ( n = `title`                v = title )
                                         ( n = `titleactive`          v = z2ui5_cl_util=>boolean_abap_2_json( titleactive ) )
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
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                                         ( n = `iconDensityAware`    v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) ) ) ).
  ENDMETHOD.


  METHOD object_marker.
    result = _generic( name   = `ObjectMarker`
                       t_prop = VALUE #( ( n = `additionalInfo` v = additionalinfo )
                                         ( n = `type`           v = type )
                                         ( n = `visible`        v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `press`          v = press )
                                         ( n = `visibility`     v = visibility ) ) ).
  ENDMETHOD.


  METHOD object_number.
    result = me.
    _generic( name   = `ObjectNumber`
              t_prop = VALUE #( ( n = `emphasized`         v = z2ui5_cl_util=>boolean_abap_2_json( emphasized ) )
                                ( n = `number`             v = number )
                                ( n = `state`              v = state )
                                ( n = `id`          v = id )
                                ( n = `class`          v = class )
                                ( n = `textAlign`          v = textalign )
                                ( n = `textDirection`      v = textdirection )
                                ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                ( n = `numberunit`         v = numberunit )
                                ( n = `active`             v = z2ui5_cl_util=>boolean_abap_2_json( active ) )
                                ( n = `inverted`           v = z2ui5_cl_util=>boolean_abap_2_json( inverted ) )
                                ( n = `visible`            v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                     ( n = `showTitleInHeaderContent` v = z2ui5_cl_util=>boolean_abap_2_json( showtitleinheadercontent ) )
                     ( n = `showEditHeaderButton`     v = z2ui5_cl_util=>boolean_abap_2_json( showeditheaderbutton ) )
                     ( n = `editHeaderButtonPress`    v = editheaderbuttonpress )
                     ( n = `upperCaseAnchorBar`       v = uppercaseanchorbar )
                     ( n = `showFooter`               v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ) ) ) ).
  ENDMETHOD.


  METHOD object_page_section.
    result = _generic( name   = `ObjectPageSection`
                       ns     = `uxap`
                       t_prop = VALUE #( ( n = `titleUppercase`  v = z2ui5_cl_util=>boolean_abap_2_json( titleuppercase ) )
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
                       t_prop = VALUE #( ( n = `active`                v = z2ui5_cl_util=>boolean_abap_2_json( active ) )
                                         ( n = `emptyIndicatorMode`    v = emptyindicatormode )
                                         ( n = `icon`                  v = icon )
                                         ( n = `iconDensityAware`      v = z2ui5_cl_util=>boolean_abap_2_json( icondensityaware ) )
                                         ( n = `inverted`              v = z2ui5_cl_util=>boolean_abap_2_json( inverted ) )
                                         ( n = `state`                 v = state )
                                         ( n = `stateAnnouncementText` v = stateannouncementtext )
                                         ( n = `text`                  v = text )
                                         ( n = `id`                  v = id )
                                         ( n = `class`                  v = class )
                                         ( n = `textDirection`         v = textdirection )
                                         ( n = `title`                 v = title )
                                         ( n = `visible`               v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `press`                 v = press ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar.
    result = _generic( name   = `OverflowToolbar`
                       t_prop = VALUE #( ( n = `press`   v = press )
                                         ( n = `text`    v = text )
                                         ( n = `active` v = z2ui5_cl_util=>boolean_abap_2_json( active ) )
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `asyncMode` v = z2ui5_cl_util=>boolean_abap_2_json( asyncmode ) )
                                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_menu_button.
    result = _generic( name   = `OverflowToolbarMenuButton`
                       t_prop = VALUE #( ( n = `buttonMode` v = buttonmode )
                                         ( n = `defaultAction` v = defaultaction )
                                         ( n = `text`    v = text )
                                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         ( n = `icon`    v = icon )
                                         ( n = `type`    v = type )
                                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_toggle_button.
    result = me.
    _generic( name   = `OverflowToolbarToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD page.
    result = _generic( name   = `Page`
                       ns     = ns
                       t_prop = VALUE #( ( n = `title` v = title )
                                         ( n = `showNavButton`  v = z2ui5_cl_util=>boolean_abap_2_json( shownavbutton ) )
                                         ( n = `navButtonPress` v = navbuttonpress )
                                         ( n = `showHeader` v = z2ui5_cl_util=>boolean_abap_2_json( showheader ) )
                                         ( n = `class` v = class )
                                         ( n = `backgroundDesign` v = backgrounddesign )
                                         ( n = `navButtonTooltip` v = navbuttontooltip )
                                         ( n = `titleAlignment` v = titlealignment )
                                         ( n = `titleLevel` v = titlelevel )
                                         ( n = `contentOnlyBusy` v = z2ui5_cl_util=>boolean_abap_2_json( contentonlybusy ) )
                                         ( n = `enableScrolling` v = z2ui5_cl_util=>boolean_abap_2_json( enablescrolling ) )
                                         ( n = `floatingFooter` v = z2ui5_cl_util=>boolean_abap_2_json( floatingfooter ) )
                                         ( n = `showFooter` v = z2ui5_cl_util=>boolean_abap_2_json( showfooter ) )
                                         ( n = `showSubHeader` v = z2ui5_cl_util=>boolean_abap_2_json( showsubheader ) )
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

    result = _generic( name   = `Panel`
                       t_prop = VALUE #( ( n = `expandable` v = z2ui5_cl_util=>boolean_abap_2_json( expandable ) )
                                         ( n = `expanded`   v = z2ui5_cl_util=>boolean_abap_2_json( expanded ) )
                                         ( n = `stickyHeader`   v = z2ui5_cl_util=>boolean_abap_2_json( stickyheader ) )
                                         ( n = `expandAnimation`   v = z2ui5_cl_util=>boolean_abap_2_json( expandanimation ) )
                                         ( n = `visible`   v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `height`   v = height )
                                         ( n = `backgroundDesign`   v = backgrounddesign )
                                         ( n = `width`   v = width )
                                         ( n = `id`   v = id )
                                         ( n = `class`   v = class )
                                         ( n = `headerText` v = headertext ) ) ).

  ENDMETHOD.


  METHOD pane_container.
    result = _generic( name   = `PaneContainer`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `resize`       v = resize )
                                         ( n = `orientation`  v = orientation ) ) ).
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
    result = _generic( name = `ProcessFlow`
                   ns       = 'commons'
                   t_prop   = VALUE #( ( n = `id`               v = id )
                                     ( n = `foldedCorners`    v = z2ui5_cl_util=>boolean_abap_2_json( foldedcorners ) )
                                     ( n = `scrollable`       v = z2ui5_cl_util=>boolean_abap_2_json( scrollable ) )
                                     ( n = `showLabels`       v = z2ui5_cl_util=>boolean_abap_2_json( showlabels ) )
                                     ( n = `visible`          v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                     ( n = `wheelZoomable`    v = z2ui5_cl_util=>boolean_abap_2_json( wheelzoomable ) )
                                     ( n = `headerPress`      v = headerpress )
                                     ( n = `labelPress`       v = labelpress )
                                     ( n = `nodePress`        v = nodepress )
                                     ( n = `onError`          v = onerror )
                                     ( n = `lanes`            v = lanes )
                                     ( n = `nodes`            v = nodes ) ) ).
  ENDMETHOD.


  METHOD process_flow_lane_header.

    result = _generic( name = `ProcessFlowLaneHeader`
                   ns       = 'commons'
                   t_prop   = VALUE #( ( n = `iconSrc`          v = iconsrc )
                                     ( n = `laneId`           v = laneid )
                                     ( n = `position`         v = position )
                                     ( n = `state`            v = state )
                                     ( n = `text`             v = text )
                                     ( n = `zoomLevel`        v = zoomlevel ) ) ).
  ENDMETHOD.


  METHOD process_flow_node.
    result = _generic( name = `ProcessFlowNode`
                   ns       = 'commons'
                   t_prop   = VALUE #( ( n = `laneId`               v = laneid )
                                     ( n = `nodeId`               v = nodeid )
                                     ( n = `title`                v = title )
                                     ( n = `titleAbbreviation`    v = titleabbreviation )
                                     ( n = `children`             v = children )
                                     ( n = `state`                v = state )
                                     ( n = `stateText`            v = statetext )
                                     ( n = `texts`                v = texts )
                                     ( n = `highlighted`          v = z2ui5_cl_util=>boolean_abap_2_json( highlighted ) )
                                     ( n = `focused`              v = z2ui5_cl_util=>boolean_abap_2_json( focused ) )
                                     ( n = `selected`             v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
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
                                ( n = `showValue`    v = z2ui5_cl_util=>boolean_abap_2_json( showvalue ) )
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
    result = _generic( name   = `QuickViewGroup`
                       t_prop = VALUE #( ( n = `heading` v = heading )
                                           ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD quick_view_group_element.
    result = _generic( name    = `QuickViewGroupElement`
                        t_prop = VALUE #( ( n = `emailSubject`  v = emailsubject )
                                          ( n = `label`       v = label )
                                          ( n = `pageLinkId`  v = pagelinkid )
                                          ( n = `target`      v = target )
                                          ( n = `type`      v = type )
                                          ( n = `url`      v = url )
                                          ( n = `value`      v = value )
                                          ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `valueColor`  v = valuecolor ) ) ).
  ENDMETHOD.


  METHOD radio_button.
    result = _generic( name = `RadioButton`
                   t_prop   = VALUE #( ( n = `activeHandling`  v = z2ui5_cl_util=>boolean_abap_2_json( activehandling ) )
                                     ( n = `editable`        v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                     ( n = `enabled`         v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                     ( n = `selected`        v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                                     ( n = `useEntireWidth`  v = z2ui5_cl_util=>boolean_abap_2_json( useentirewidth ) )
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
                                         ( n = `editable`       v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                         ( n = `enabled`        v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                                ( n = `showTickmarks`   v = z2ui5_cl_util=>boolean_abap_2_json( showtickmarks ) )
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
    result = _generic( name   = `ResponsiveSplitter`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `defaultPane`  v = defaultpane )
                                         ( n = `height`       v = height )
                                         ( n = `width`        v = width ) ) ).
  ENDMETHOD.


  METHOD rich_text_editor.
    result = _generic( name   = `RichTextEditor`
                       ns     = `text`
                       t_prop = VALUE #( ( n = `buttonGroups`        v = buttongroups )
                                         ( n = `customToolbar`       v = z2ui5_cl_util=>boolean_abap_2_json( customtoolbar ) )
                                         ( n = `editable`            v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                         ( n = `height`              v = height )
                                         ( n = `editorType`          v = editortype )
                                         ( n = `plugins`             v = plugins )
                                         ( n = `textDirection`       v = textdirection )
                                         ( n = `value`               v = value )
                                         ( n = `beforeEditorInit`    v = beforeeditorinit )
                                         ( n = `change`              v = change )
                                         ( n = `ready`               v = ready )
                                         ( n = `readyRecurring`      v = readyrecurring )
                                         ( n = `required`            v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                         ( n = `sanitizeValue`       v = z2ui5_cl_util=>boolean_abap_2_json( sanitizevalue ) )
                                         ( n = `showGroupClipboard`  v = z2ui5_cl_util=>boolean_abap_2_json( showgroupclipboard ) )
                                         ( n = `showGroupFont`       v = z2ui5_cl_util=>boolean_abap_2_json( showgroupfont ) )
                                         ( n = `showGroupFontStyle`  v = z2ui5_cl_util=>boolean_abap_2_json( showgroupfontstyle ) )
                                         ( n = `showGroupInsert`     v = z2ui5_cl_util=>boolean_abap_2_json( showgroupinsert ) )
                                         ( n = `showGroupLink`       v = z2ui5_cl_util=>boolean_abap_2_json( showgrouplink ) )
                                         ( n = `showGroupStructure`  v = z2ui5_cl_util=>boolean_abap_2_json( showgroupstructure ) )
                                         ( n = `showGroupTextAlign`  v = z2ui5_cl_util=>boolean_abap_2_json( showgrouptextalign ) )
                                         ( n = `showGroupUndo`       v = z2ui5_cl_util=>boolean_abap_2_json( showgroupundo ) )
                                         ( n = `useLegacyTheme`      v = z2ui5_cl_util=>boolean_abap_2_json( uselegacytheme ) )
                                         ( n = `wrapping`            v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
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
                                         ( n = `vertical`    v = z2ui5_cl_util=>boolean_abap_2_json( vertical ) )
                                         ( n = `horizontal`  v = z2ui5_cl_util=>boolean_abap_2_json( horizontal ) )
                                         ( n = `focusable`   v = z2ui5_cl_util=>boolean_abap_2_json( focusable ) ) ) ).
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
                                ( n = `enableSuggestions` v = z2ui5_cl_util=>boolean_abap_2_json( enablesuggestions ) )
                                ( n = `showRefreshButton` v = z2ui5_cl_util=>boolean_abap_2_json( showrefreshbutton ) )
                                ( n = `showSearchButton` v = z2ui5_cl_util=>boolean_abap_2_json( showsearchbutton ) )
                                ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                                ( n = `enabled`   v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`   v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                             ( n = `autoAdjustWidth`     v = z2ui5_cl_util=>boolean_abap_2_json( autoadjustwidth ) )
                             ( n = `columnRatio`         v = columnratio )
                             ( n = `editable`            v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                             ( n = `enabled`             v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                             ( n = `forceSelection`      v = z2ui5_cl_util=>boolean_abap_2_json( forceselection ) )
                             ( n = `icon`                v = icon )
                             ( n = `maxWidth`            v = maxwidth )
                             ( n = `name`                v = name )
                             ( n = `required`            v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                             ( n = `resetOnMissingKey`   v = z2ui5_cl_util=>boolean_abap_2_json( resetonmissingkey ) )
                             ( n = `selectedItemId`      v = selecteditemid )
                             ( n = `selectedKey`         v = selectedkey )
                             ( n = `showSecondaryValues` v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ) )
                             ( n = `textAlign`           v = textalign )
                             ( n = `textDirection`       v = textdirection )
                             ( n = `type`                v = type )
                             ( n = `valueState`          v = valuestate )
                             ( n = `valueStateText`      v = valuestatetext )
                             ( n = `width`               v = width )
                             ( n = `wrapItemsText`       v = z2ui5_cl_util=>boolean_abap_2_json( wrapitemstext ) )
                             ( n = `items`               v = items )
                             ( n = `selectedItem`        v = selecteditem )
                             ( n = `change`              v = change )
                             ( n = `liveChange`          v = livechange )
                             ( n = `visible`             v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
    result = _generic( name          = `Shell`
                       ns            = ns
                              t_prop = VALUE #( ( n = `appWidthLimited`  v = z2ui5_cl_util=>boolean_abap_2_json( appwidthlimited ) ) ) ).
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
                                         ( n = `sidePanelResizable`    v = z2ui5_cl_util=>boolean_abap_2_json( sidepanelresizable ) )
                                         ( n = `actionBarExpanded`    v = z2ui5_cl_util=>boolean_abap_2_json( actionbarexpanded ) )
                                         ( n = `toggle`    v = toggle )
                                         ( n = `ariaLabel`  v = arialabel ) ) ).
  ENDMETHOD.


  METHOD side_panel_item.
    result = _generic( name   = `SidePanelItem`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `icon` v = icon )
                                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         ( n = `key` v = key )
                                         ( n = `text` v = text ) ) ).
  ENDMETHOD.


  METHOD simple_form.
    result = _generic( name   = `SimpleForm`
                       ns     = `form`
                       t_prop = VALUE #( ( n = `title`    v = title )
                                         ( n = `layout`   v = layout )
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
                                         ( n = `singleContainerFullSize`   v = z2ui5_cl_util=>boolean_abap_2_json( singlecontainerfullsize ) )
                                         ( n = `visible`   v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `width`       v = width )
                                         ( n = `id`       v = id )
                                         ( n = `columnsXL`   v = columnsxl )
                                         ( n = `columnsL`   v = columnsl )
                                         ( n = `columnsM`   v = columnsm )
                                         ( n = `editable` v = z2ui5_cl_util=>boolean_abap_2_json( editable ) ) ) ).
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
                                         ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                       ) ).
  ENDMETHOD.


  METHOD smart_variant_management.
    result = _generic( name   = `SmartVariantManagement`
                       ns     = `svm`
                       t_prop = VALUE #( ( n = `id`      v = id )
                                         ( n = `showExecuteOnSelection`  v = z2ui5_cl_util=>boolean_abap_2_json( showexecuteonselection ) ) ) ).
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
    result = _generic( name   = `SplitterLayoutData`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `size`         v = size )
                                         ( n = `minSize`      v = minsize )
                                         ( n = `resizable`    v = z2ui5_cl_util=>boolean_abap_2_json( resizable ) ) ) ).
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
    _generic( name           = `Spot`
                      ns     = `vbm`
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

    result = _generic( name  = `Spots`
                      ns     = `vbm`
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
                                ( n = `hideOnNoData`    v = z2ui5_cl_util=>boolean_abap_2_json( hideonnodata ) )
                                ( n = `displayZeroValue`    v = z2ui5_cl_util=>boolean_abap_2_json( displayzerovalue ) )
                                ( n = `showLabels`    v = z2ui5_cl_util=>boolean_abap_2_json( showlabels ) )
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
                                ( n = `adaptTitleSize`     v = z2ui5_cl_util=>boolean_abap_2_json( adapttitlesize ) )
                                ( n = `unread`     v = z2ui5_cl_util=>boolean_abap_2_json( unread ) )
                                ( n = `iconInset`     v = z2ui5_cl_util=>boolean_abap_2_json( iconinset ) )
                                ( n = `infoStateInverted`     v = z2ui5_cl_util=>boolean_abap_2_json( infostateinverted ) )
                                ( n = `wrapping`     v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
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
    result = _generic( name = `statuses`
                       ns   = ns ).
  ENDMETHOD.


  METHOD step_input.
    result = me.
    _generic( name   = `StepInput`
              t_prop = VALUE #( ( n = `max`  v = max )
                                ( n = `min`  v = min )
                                ( n = `step` v = step )
                                ( n = `value` v = value )
                                ( n = `valueState` v = valuestate )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `description` v = description ) ) ).
  ENDMETHOD.


  METHOD stringify.

    result = get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD sub_header.

    result = _generic( name = `subHeader`
                      ns    = ns ).

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
                                ( n = `enabled`        v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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
                           ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                           ( n = `alternateRowColors`  v = z2ui5_cl_util=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `fixedLayout`  v = z2ui5_cl_util=>boolean_abap_2_json( fixedlayout ) )
                           ( n = `showOverlay`  v = z2ui5_cl_util=>boolean_abap_2_json( showoverlay ) )
                           ( n = `autoPopinMode`  v = z2ui5_cl_util=>boolean_abap_2_json( autopopinmode ) ) ) ).
  ENDMETHOD.


  METHOD table_select_dialog.

    result = _generic( name = `TableSelectDialog`
               t_prop       = VALUE #( ( n = `confirmButtonText`    v = confirmbuttontext )
                                 ( n = `contentHeight`        v = contentheight )
                                 ( n = `contentWidth`         v = contentwidth )
                                 ( n = `draggable`            v = z2ui5_cl_util=>boolean_abap_2_json( draggable ) )
                                 ( n = `growing`              v = z2ui5_cl_util=>boolean_abap_2_json( growing ) )
                                 ( n = `growingThreshold`     v = growingthreshold )
                                 ( n = `multiSelect`          v = z2ui5_cl_util=>boolean_abap_2_json( multiselect ) )
                                 ( n = `noDataText`           v = nodatatext )
                                 ( n = `rememberSelections`   v = z2ui5_cl_util=>boolean_abap_2_json( rememberselections ) )
                                 ( n = `resizable`            v = z2ui5_cl_util=>boolean_abap_2_json( resizable ) )
                                 ( n = `searchPlaceholder`    v = searchplaceholder )
                                 ( n = `showClearButton`      v = z2ui5_cl_util=>boolean_abap_2_json( showclearbutton ) )
                                 ( n = `title`                v = title )
                                 ( n = `titleAlignment`       v = titlealignment )
                                 ( n = `items`                v = items )
                                 ( n = `search`               v = search )
                                 ( n = `confirm`              v = confirm )
                                 ( n = `cancel`               v = cancel )
                                 ( n = `liveChange`           v = livechange )
                                 ( n = `selectionChange`      v = selectionchange )
                                 ( n = `visible`              v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).
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
                                         ( n = `showTitle` v = z2ui5_cl_util=>boolean_abap_2_json( showtitle ) )
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
                                ( n = `wrapping`  v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
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
                                ( n = `maxLength` v = maxlength )
                                ( n = `textAlign` v = textalign )
                                ( n = `textDirection` v = textdirection )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ) )
                                ( n = `showExceededText` v = z2ui5_cl_util=>boolean_abap_2_json( showexceededtext ) )
                                ( n = `valueLiveUpdate` v = z2ui5_cl_util=>boolean_abap_2_json( valueliveupdate ) )
                                ( n = `editable` v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                ( n = `class` v = class )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `id` v = id )
                                ( n = `growing` v = z2ui5_cl_util=>boolean_abap_2_json( growing ) )
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
                                ( n = `footerColor`   v = footercolor )
                                ( n = `blocked`   v = z2ui5_cl_util=>boolean_abap_2_json( blocked ) )
                                ( n = `frameType`   v = frametype )
                                ( n = `priority`   v = priority )
                                ( n = `priorityText`   v = prioritytext )
                                ( n = `state`   v = state )
                                ( n = `disabled`   v = z2ui5_cl_util=>boolean_abap_2_json( disabled ) )
                                ( n = `visible`   v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `footer` v = footer ) ) ).

  ENDMETHOD.


  METHOD timeline.

    result = _generic( name   = `Timeline`
                       ns     = 'commons'
                       t_prop = VALUE #( ( n = 'id'                 v = id )
                                         ( n = 'enableDoubleSided'  v = z2ui5_cl_util=>boolean_abap_2_json( enabledoublesided ) )
                                         ( n = 'groupBy'            v = groupby )
                                         ( n = 'growingThreshold'   v = growingthreshold )
                                         ( n = 'filterTitle'        v = filtertitle )
                                         ( n = 'sortOldestFirst'    v = z2ui5_cl_util=>boolean_abap_2_json( sortoldestfirst ) )
                                         ( n = 'enableModelFilter'  v = z2ui5_cl_util=>boolean_abap_2_json( enablemodelfilter ) )
                                         ( n = 'enableScroll'       v = z2ui5_cl_util=>boolean_abap_2_json( enablescroll ) )
                                         ( n = 'forceGrowing'       v = z2ui5_cl_util=>boolean_abap_2_json( forcegrowing ) )
                                         ( n = 'group'              v = z2ui5_cl_util=>boolean_abap_2_json( group ) )
                                         ( n = 'lazyLoading'        v = z2ui5_cl_util=>boolean_abap_2_json( lazyloading ) )
                                         ( n = 'showHeaderBar'      v = z2ui5_cl_util=>boolean_abap_2_json( showheaderbar ) )
                                         ( n = 'showIcons'          v = z2ui5_cl_util=>boolean_abap_2_json( showicons ) )
                                         ( n = 'showItemFilter'     v = z2ui5_cl_util=>boolean_abap_2_json( showitemfilter ) )
                                         ( n = 'showSearch'         v = z2ui5_cl_util=>boolean_abap_2_json( showsearch ) )
                                         ( n = 'showSort'           v = z2ui5_cl_util=>boolean_abap_2_json( showsort ) )
                                         ( n = 'showTimeFilter'     v = z2ui5_cl_util=>boolean_abap_2_json( showtimefilter ) )
                                         ( n = 'sort'               v = z2ui5_cl_util=>boolean_abap_2_json( sort ) )
                                         ( n = 'groupByType'        v = groupbytype )
                                         ( n = 'textHeight'         v = textheight )
                                         ( n = 'width'              v = width )
                                         ( n = 'height'             v = height )
                                         ( n = 'noDataText'         v = nodatatext )
                                         ( n = 'alignment'          v = alignment )
                                         ( n = 'axisOrientation'    v = axisorientation )
                                         ( n = 'filterList'         v = filterlist )
                                         ( n = 'customFilter'       v = customfilter )
                                         ( n = 'content'            v = content ) ) ).
  ENDMETHOD.


  METHOD timeline_item.

    result = _generic( name   = `TimelineItem`
                       ns     = 'commons'
                       t_prop = VALUE #( ( n = 'id'                     v = id )
                                         ( n = 'dateTime'               v = datetime )
                                         ( n = 'title'                  v = title )
                                         ( n = 'userNameClickable'      v = z2ui5_cl_util=>boolean_abap_2_json( usernameclickable ) )
                                         ( n = 'useIconTooltip'         v = z2ui5_cl_util=>boolean_abap_2_json( useicontooltip ) )
                                         ( n = 'userNameClicked'        v = usernameclicked )
                                         ( n = 'userPicture'            v = userpicture )
                                         ( n = 'select'                 v = select )
                                         ( n = 'text'                   v = text )
                                         ( n = 'userName'               v = username )
                                         ( n = 'filterValue'            v = filtervalue )
                                         ( n = 'iconDisplayShape'       v = icondisplayshape )
                                         ( n = 'iconInitials'           v = iconinitials )
                                         ( n = 'iconSize'               v = iconsize )
                                         ( n = 'iconTooltip'            v = icontooltip )
                                         ( n = 'maxCharacters'          v = maxcharacters )
                                         ( n = 'replyCount'             v = replycount )
                                         ( n = 'status'                 v = status )
                                         ( n = 'customActionClicked'    v = customactionclicked )
                                         ( n = 'press'                  v = press )
                                         ( n = 'replyListOpen'          v = replylistopen )
                                         ( n = 'replyPost'              v = replypost )
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
                                ( n = `maskMode`  v = maskmode )
                                ( n = `minutesStep`  v = minutesstep )
                                ( n = `name`  v = name )
                                ( n = `placeholderSymbol`  v = placeholdersymbol )
                                ( n = `secondsStep`  v = secondsstep )
                                ( n = `textAlign`  v = textalign )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `title`  v = title )
                                ( n = `showCurrentTimeButton` v = z2ui5_cl_util=>boolean_abap_2_json( showcurrenttimebutton ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ) )
                                ( n = `support2400` v = z2ui5_cl_util=>boolean_abap_2_json( support2400 ) )
                                ( n = `initialFocusedDateValue` v = z2ui5_cl_util=>boolean_abap_2_json( initialfocuseddatevalue ) )
                                ( n = `hideInput` v = z2ui5_cl_util=>boolean_abap_2_json( hideinput ) )
                                ( n = `editable` v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                ( n = `required` v = z2ui5_cl_util=>boolean_abap_2_json( required ) )
                                ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
    DATA(lv_name) = COND #( WHEN ns = 'f' THEN 'title' ELSE `Title` ).


    result = me.
    _generic( ns     = COND #( WHEN level IS NOT INITIAL THEN `webc` ELSE ns )
              name   = lv_name
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `class`     v = class )
                                ( n = `id`     v = id )
                                ( n = `wrappingType`     v = wrappingtype )
                                ( n = `textAlign`     v = textalign )
                                ( n = `textDirection`     v = textdirection )
                                ( n = `titleStyle`     v = titlestyle )
                                ( n = `width`     v = width )
                                ( n = `wrapping` v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
                                ( n = `visible` v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                ( n = `level` v = level ) ) ).
  ENDMETHOD.


  METHOD toggle_button.

    result = me.
    _generic( name   = `ToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
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

    result = _generic( name = `tokens`
                       ns   = ns ).

  ENDMETHOD.


  METHOD toolbar.

    result = _generic( name   = `Toolbar`
                       ns     = ns
                       t_prop = VALUE #( ( n = `active`  v = z2ui5_cl_util=>boolean_abap_2_json( active ) )
                                         ( n = `ariaHasPopup`  v = ariahaspopup )
                                         ( n = `design`  v = design )
                                         ( n = `enabled`  v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
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
                           ( n = `includeItemInSelection`  v = z2ui5_cl_util=>boolean_abap_2_json( includeiteminselection ) )
                           ( n = `inset`  v = z2ui5_cl_util=>boolean_abap_2_json( inset ) )
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
                                        ( n = `selectedIndex`           v = selectedindex )
                                        ( n = `visibleRowCount`         v = visiblerowcount )
                                        ( n = `visibleRowCountMode`     v = visiblerowcountmode ) ) ).
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
                          ( n = `autoresizable`  v = z2ui5_cl_util=>boolean_abap_2_json( autoresizable ) )
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
                           ( n = `alternateRowColors`        v = z2ui5_cl_util=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `columnHeaderVisible`       v = columnheadervisible )
                           ( n = `editable`                  v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                           ( n = `enableCellFilter`          v = z2ui5_cl_util=>boolean_abap_2_json( enablecellfilter ) )
                           ( n = `enableGrouping`            v = z2ui5_cl_util=>boolean_abap_2_json( enablegrouping ) )
                           ( n = `senableSelectAll`          v = z2ui5_cl_util=>boolean_abap_2_json( enableselectall ) )
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
                           ( n = `showColumnVisibilityMenu`  v = z2ui5_cl_util=>boolean_abap_2_json( showcolumnvisibilitymenu ) )
                           ( n = `showNoData`                v = z2ui5_cl_util=>boolean_abap_2_json( shownodata ) )
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
                                         ( n = `instantUpload`            v = z2ui5_cl_util=>boolean_abap_2_json( instantupload ) )
                                         ( n = `showIcons`                v = z2ui5_cl_util=>boolean_abap_2_json( showicons ) )
                                         ( n = `uploadEnabled`            v = z2ui5_cl_util=>boolean_abap_2_json( uploadenabled ) )
                                         ( n = `terminationEnabled`       v = z2ui5_cl_util=>boolean_abap_2_json( terminationenabled ) )
                                         ( n = `uploadButtonInvisible`    v = z2ui5_cl_util=>boolean_abap_2_json( uploadbuttoninvisible ) )
                                         ( n = `fileTypes`                v = filetypes )
                                         ( n = `maxFileNameLength`        v = maxfilenamelength )
                                         ( n = `maxFileSize`              v = maxfilesize )
                                         ( n = `mediaTypes`               v = mediatypes )
                                         ( n = `items`                    v = items )
                                         ( n = `uploadUrl`                v = uploadurl )
                                         ( n = `mode`                     v = mode )
                                         ( n = `fileRenamed`              v = filerenamed )
                                         ( n = `directory`                v = z2ui5_cl_util=>boolean_abap_2_json( directory ) )
                                         ( n = `multiple`                 v = z2ui5_cl_util=>boolean_abap_2_json( multiple ) )
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
                                         ( n = `sameFilenameAllowed`      v = z2ui5_cl_util=>boolean_abap_2_json( samefilenameallowed ) )
                                         ( n = `selectionChanged`         v = selectionchanged ) ) ).
  ENDMETHOD.


  METHOD upload_set_item.
    result = _generic( name = `UploadSetItem`
                   ns       = 'upload'
                   t_prop   = VALUE #( ( n = `fileName`      v = filename )
                                     ( n = `mediaType`     v = mediatype )
                                     ( n = `url`           v = url )
                                     ( n = `thumbnailUrl`  v = thumbnailurl )
                                     ( n = `markers`       v = markers )
                                     ( n = `enabledEdit`   v = z2ui5_cl_util=>boolean_abap_2_json( enablededit ) )
                                     ( n = `enabledRemove` v = z2ui5_cl_util=>boolean_abap_2_json( enabledremove ) )
                                     ( n = `selected`      v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                                     ( n = `visibleEdit`   v = z2ui5_cl_util=>boolean_abap_2_json( visibleedit ) )
                                     ( n = `visibleRemove` v = z2ui5_cl_util=>boolean_abap_2_json( visibleremove ) )
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

    result = _generic( name     = `VariantItem`
                         ns     = `vm`
                         t_prop = VALUE #( ( n = `executeOnSelection`      v = z2ui5_cl_util=>boolean_abap_2_json( executeonselection ) )
                                           ( n = `global`                  v = z2ui5_cl_util=>boolean_abap_2_json( global ) )
                                           ( n = `labelReadOnly`           v = z2ui5_cl_util=>boolean_abap_2_json( labelreadonly ) )
                                           ( n = `lifecyclePackage`        v = lifecyclepackage )
                                           ( n = `lifecycleTransportId`    v = lifecycletransportid )
                                           ( n = `namespace`               v = namespace )
                                           ( n = `readOnly`                v = readonly )
                                           ( n = `executeOnSelect`         v = z2ui5_cl_util=>boolean_abap_2_json( executeonselect ) )
                                           ( n = `author`                  v = author )
                                           ( n = `changeable`              v = z2ui5_cl_util=>boolean_abap_2_json( changeable ) )
                                           ( n = `enabled`                 v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                           ( n = `favorite`                v = z2ui5_cl_util=>boolean_abap_2_json( favorite ) )
                                           ( n = `key`                     v = key )
                                           ( n = `text`                    v = text )
                                           ( n = `title`                   v = title )
                                           ( n = `textDirection`           v = textdirection )
                                           ( n = `originalTitle`           v = originaltitle )
                                           ( n = `originalExecuteOnSelect` v = z2ui5_cl_util=>boolean_abap_2_json( originalexecuteonselect ) )
                                           ( n = `remove`                  v = z2ui5_cl_util=>boolean_abap_2_json( remove ) )
                                           ( n = `rename`                  v = z2ui5_cl_util=>boolean_abap_2_json( rename ) )
                                           ( n = `originalFavorite`        v = z2ui5_cl_util=>boolean_abap_2_json( originalfavorite ) )
                                           ( n = `sharing`                 v = z2ui5_cl_util=>boolean_abap_2_json( sharing ) )
                                           ( n = `change`                  v = change ) ) ).

  ENDMETHOD.


  METHOD variant_items.

    result = _generic( name = `variantItems`
                         ns = `vm` ).

  ENDMETHOD.


  METHOD variant_management.

    result = _generic( name   = `VariantManagement`
                       ns     = `vm`
                       t_prop = VALUE #( ( n = `defaultVariantKey`      v = defaultvariantkey )
                                         ( n = `enabled`                v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         ( n = `inErrorState`           v = z2ui5_cl_util=>boolean_abap_2_json( inerrorstate ) )
                                         ( n = `initialSelectionKey`    v = initialselectionkey )
                                         ( n = `lifecycleSupport`       v = z2ui5_cl_util=>boolean_abap_2_json( lifecyclesupport ) )
                                         ( n = `selectionKey`           v = selectionkey )
                                         ( n = `showCreateTile`         v = z2ui5_cl_util=>boolean_abap_2_json( showcreatetile ) )
                                         ( n = `showExecuteOnSelection` v = z2ui5_cl_util=>boolean_abap_2_json( showexecuteonselection ) )
                                         ( n = `showSetAsDefault`       v = z2ui5_cl_util=>boolean_abap_2_json( showsetasdefault ) )
                                         ( n = `showShare`              v = z2ui5_cl_util=>boolean_abap_2_json( showshare ) )
                                         ( n = `standardItemAuthor`     v = standarditemauthor )
                                         ( n = `standardItemText`       v = standarditemtext )
                                         ( n = `useFavorites`           v = z2ui5_cl_util=>boolean_abap_2_json( usefavorites ) )
                                         ( n = `variantItems`           v = variantitems )
                                         ( n = `manage`                 v = manage )
                                         ( n = `save`                   v = save )
                                         ( n = `select`                 v = select )
                                         ( n = `id`                     v = id )
                                         ( n = `variantCreationByUserAllowed` v = uservarcreate )
                                         ( n = `visible`                v = z2ui5_cl_util=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.


  METHOD variant_management_fl.
    result = _generic( name   = `VariantManagement`
                       ns     = `flvm`
                       t_prop = VALUE #( ( n = `displayTextForExecuteOnSelectionForStandardVariant`  v = displaytextfsv )
                                         ( n = `editable`       v = z2ui5_cl_util=>boolean_abap_2_json( editable ) )
                                         ( n = `executeOnSelectionForStandardDefault`        v = z2ui5_cl_util=>boolean_abap_2_json( executeonselectionforstandflt ) )
                                         ( n = `headerLevel`      v = headerlevel )
                                         ( n = `inErrorState`      v = z2ui5_cl_util=>boolean_abap_2_json( inerrorstate ) )
                                         ( n = `maxWidth`      v = maxwidth )
                                         ( n = `modelName`      v = modelname )
                                         ( n = `resetOnContextChange`      v = z2ui5_cl_util=>boolean_abap_2_json( resetoncontextchange ) )
                                         ( n = `showSetAsDefault`      v = z2ui5_cl_util=>boolean_abap_2_json( showsetasdefault ) )
                                         ( n = `titleStyle`      v = titlestyle )
                                         ( n = `updateVariantInURL`    v = z2ui5_cl_util=>boolean_abap_2_json( updatevariantinurl ) )
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
                                         ( n = `backgroundDesign`            v = backgrounddesign )
                                         ( n = `direction`            v = direction )
                                         ( n = `displayInline`            v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ) )
                                         ( n = `visible`            v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `fitContainer`            v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ) )
                                         ( n = `class`           v = class ) ) ).

  ENDMETHOD.


  METHOD vertical_layout.

    result = _generic( name   = `VerticalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `id`  v = id )
                                         ( n = `visible`  v = z2ui5_cl_util=>boolean_abap_2_json( visible ) )
                                         ( n = `enabled`  v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                         ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD view_settings_dialog.

    result = _generic( name = `ViewSettingsDialog`
              t_prop        = VALUE #( ( n = `confirm`                  v = confirm )
                                ( n = `cancel`                   v = cancel )
                                ( n = `filterDetailPageOpened`   v = filterdetailpageopened )
                                ( n = `reset`                    v = reset )
                                ( n = `resetFilters`             v = resetfilters )
                                ( n = `filterSearchOperator`     v = filtersearchoperator )
                                ( n = `groupDescending`          v = z2ui5_cl_util=>boolean_abap_2_json( groupdescending ) )
                                ( n = `sortDescending`           v = z2ui5_cl_util=>boolean_abap_2_json( sortdescending ) )
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
    result = _generic( name = `ViewSettingsFilterItem`
                  t_prop    = VALUE #( ( n = `enabled`         v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                    ( n = `key`             v = key )
                                    ( n = `selected`        v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                                    ( n = `text`            v = text )
                                    ( n = `textDirection`   v = textdirection )
                                    ( n = `multiSelect`     v = z2ui5_cl_util=>boolean_abap_2_json( multiselect ) ) ) ).
  ENDMETHOD.


  METHOD view_settings_item.
    result = _generic( name = `ViewSettingsItem`
                  t_prop    = VALUE #( ( n = `enabled`         v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                    ( n = `key`             v = key )
                                    ( n = `selected`        v = z2ui5_cl_util=>boolean_abap_2_json( selected ) )
                                    ( n = `text`            v = text )
                                    ( n = `textDirection`   v = textdirection ) ) ).

  ENDMETHOD.


  METHOD visible_horizon.
    result = _generic( name = `visibleHorizon`
                       ns   = `axistime` ).
  ENDMETHOD.


  METHOD vos.

    result = _generic( name = `vos`
                      ns    = `vbm` ).

  ENDMETHOD.


  METHOD xml_get.
    DATA lt_prop TYPE z2ui5_if_types=>ty_t_name_value.

    CASE mv_name.
      WHEN `ZZPLAIN`.
        result = mt_prop[ n = `VALUE` ]-v.
        RETURN.
      WHEN OTHERS.
    ENDCASE.

    IF me = mo_root.

      lt_prop = VALUE #(
                      ( n = `xmlns:z2ui5`     v = `z2ui5` )
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
            TRY.
                INSERT lr_prop->* INTO TABLE mt_prop.
              CATCH cx_root.
            ENDTRY.
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
                                                               format = cl_abap_format=>e_xml_attr ) }"| ).

    result = |{ result } <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }|.

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


  METHOD _z2ui5.

    result = NEW #( me ).

  ENDMETHOD.
ENDCLASS.
