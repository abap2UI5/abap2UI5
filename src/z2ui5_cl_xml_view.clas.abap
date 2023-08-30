 CLASS z2ui5_cl_xml_view DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.

    CLASS-METHODS factory
      IMPORTING
        !t_ns         TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
        !client       TYPE REF TO z2ui5_if_client OPTIONAL
          PREFERRED PARAMETER client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS factory_popup
      IMPORTING
        !t_ns         TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS constructor.

    METHODS hlp_get_source_code_url
      RETURNING
        VALUE(result) TYPE string.

    METHODS hlp_get_app_url
      IMPORTING
        VALUE(classname) TYPE string OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    METHODS hlp_get_url_param
      IMPORTING
        !val          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS hlp_set_url_param
      IMPORTING
        !n TYPE clike
        !v TYPE clike.

    METHODS horizontal_layout
      IMPORTING
        !class        TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.



    METHODS dynamic_page
      IMPORTING
        !headerexpanded           TYPE clike OPTIONAL
        !showfooter               TYPE clike OPTIONAL
        !headerpinned             TYPE clike OPTIONAL
        !toggleheaderontitleclick TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    METHODS dynamic_page_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS dynamic_page_header
      IMPORTING
        !pinnable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS flex_box
      IMPORTING
        !class          TYPE clike OPTIONAL
        !rendertype     TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
        !fitcontainer   TYPE clike OPTIONAL
        !height         TYPE clike OPTIONAL
        !alignitems     TYPE clike OPTIONAL
        !justifycontent TYPE clike OPTIONAL
        !wrap           TYPE clike OPTIONAL
        !visible        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    METHODS popover
      IMPORTING
        !title         TYPE clike OPTIONAL
        !class         TYPE clike OPTIONAL
        !placement     TYPE clike OPTIONAL
        !initialfocus  TYPE clike OPTIONAL
        !contentwidth  TYPE clike OPTIONAL
        !contentheight TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS list_item
      IMPORTING
        !text           TYPE clike OPTIONAL
        !additionaltext TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

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
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_strip
      IMPORTING
        !text         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !showicon     TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS footer
      IMPORTING
        !ns           TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_page
      IMPORTING
        !show_header         TYPE clike OPTIONAL
        !text                TYPE clike OPTIONAL
        !enableformattedtext TYPE clike OPTIONAL
        !description         TYPE clike OPTIONAL
        !icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS object_page_layout
      IMPORTING
        !showtitleinheadercontent TYPE clike OPTIONAL
        !showeditheaderbutton     TYPE clike OPTIONAL
        !editheaderbuttonpress    TYPE clike OPTIONAL
        !uppercaseanchorbar       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view.

    METHODS object_page_dyn_header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS generic_tile
      IMPORTING
        !class        TYPE clike OPTIONAL
        !mode         TYPE clike OPTIONAL
        !header       TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !frametype    TYPE clike OPTIONAL
        !subheader    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS numeric_content
      IMPORTING
        !value        TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !withmargin   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS image_content
      IMPORTING
        !src          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS tile_content
      IMPORTING
        !unit         TYPE clike OPTIONAL
        !footer       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS expanded_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS snapped_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        !src          TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !displaysize  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS tokens
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
        !id                           TYPE clike OPTIONAL
        !value                        TYPE clike OPTIONAL
        !placeholder                  TYPE clike OPTIONAL
        !type                         TYPE clike OPTIONAL
        !showclearicon                TYPE clike OPTIONAL
        !valuestate                   TYPE clike OPTIONAL
        !valuestatetext               TYPE clike OPTIONAL
        !showtablesuggestionvaluehelp TYPE clike OPTIONAL
        !description                  TYPE clike OPTIONAL
        !editable                     TYPE clike OPTIONAL
        !enabled                      TYPE clike OPTIONAL
        !suggestionitems              TYPE clike OPTIONAL
        !suggestionrows               TYPE clike OPTIONAL
        !showsuggestion               TYPE clike OPTIONAL
        !showvaluehelp                TYPE clike OPTIONAL
        !valuehelprequest             TYPE clike OPTIONAL
        !required                     TYPE clike OPTIONAL
        !suggest                      TYPE clike OPTIONAL
        !class                        TYPE clike OPTIONAL
        !visible                      TYPE clike OPTIONAL
        !submit                       TYPE clike OPTIONAL
        !valueliveupdate              TYPE clike OPTIONAL
        !autocomplete                 TYPE clike OPTIONAL
        !maxsuggestionwidth           TYPE clike OPTIONAL
        !fieldwidth                   TYPE clike OPTIONAL
        !valuehelponly                TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_xml_view .
    METHODS dialog
      IMPORTING
        !title         TYPE clike OPTIONAL
        !icon          TYPE clike OPTIONAL
        !showheader    TYPE clike OPTIONAL
        !stretch       TYPE clike OPTIONAL
        !contentheight TYPE clike OPTIONAL
        !contentwidth  TYPE clike OPTIONAL
        !resizable     TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS carousel
      IMPORTING
        !height       TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !loop         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
        name          TYPE string OPTIONAL
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
        !width          TYPE clike OPTIONAL
        !minscreenwidth TYPE clike OPTIONAL
        !demandpopin    TYPE clike OPTIONAL
        !halign         TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS items
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
        !sice         TYPE clike OPTIONAL
        !percentage   TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !valuecolor   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS column_list_item
      IMPORTING
        !valign       TYPE clike OPTIONAL
        !selected     TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !visible      TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
        !ns           TYPE clike OPTIONAL
        !tooltip      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS search_field
      IMPORTING
        !search       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !value        TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
        !change       TYPE clike OPTIONAL
        !livechange   TYPE clike OPTIONAL
        !autocomplete TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_view
      IMPORTING
        !items        TYPE clike OPTIONAL
        !groupitems   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_popover
      IMPORTING
        !items        TYPE clike OPTIONAL
        !groupitems   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS message_item
      IMPORTING
        !type              TYPE clike OPTIONAL
        !title             TYPE clike OPTIONAL
        !subtitle          TYPE clike OPTIONAL
        !description       TYPE clike OPTIONAL
        !groupname         TYPE clike OPTIONAL
        !markupdescription TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .
    METHODS page
      IMPORTING
        !title          TYPE clike OPTIONAL
        !navbuttonpress TYPE clike OPTIONAL
        !shownavbutton  TYPE clike OPTIONAL
        !showheader     TYPE clike OPTIONAL
        !id             TYPE clike OPTIONAL
        !class          TYPE clike OPTIONAL
        !ns             TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS panel
      IMPORTING
        !expandable   TYPE clike OPTIONAL
        !expanded     TYPE clike OPTIONAL
        !headertext   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS vbox
      IMPORTING
        !height         TYPE clike OPTIONAL
        !justifycontent TYPE clike OPTIONAL
        !class          TYPE clike OPTIONAL
        !rendertype     TYPE clike OPTIONAL
        !aligncontent   TYPE clike OPTIONAL
        !alignitems     TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
        !wrap           TYPE clike OPTIONAL
          PREFERRED PARAMETER class
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS hbox
      IMPORTING
        !class          TYPE clike OPTIONAL
        !justifycontent TYPE clike OPTIONAL
        !aligncontent   TYPE clike OPTIONAL
        !alignitems     TYPE clike OPTIONAL
        !width          TYPE clike OPTIONAL
        !height         TYPE clike OPTIONAL
        !wrap           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS scroll_container
      IMPORTING
        !height       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !vertical     TYPE clike OPTIONAL
        !horizontal   TYPE clike OPTIONAL
        !focusable    TYPE clike OPTIONAL
          PREFERRED PARAMETER height
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS simple_form
      IMPORTING
        !title        TYPE clike OPTIONAL
        !layout       TYPE clike OPTIONAL
        !editable     TYPE clike OPTIONAL
        !columnsxl    TYPE clike OPTIONAL
        !columnsl     TYPE clike OPTIONAL
        !columnsm     TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS zz_plain
      IMPORTING
        !val          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS content
      IMPORTING
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS title
      IMPORTING
        !ns           TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !wrapping     TYPE clike OPTIONAL
        !level        TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
        !text         TYPE clike OPTIONAL
        !labelfor     TYPE clike OPTIONAL
        !design       TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS image
      IMPORTING
        !src          TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS date_picker
      IMPORTING
        !value                 TYPE clike OPTIONAL
        !placeholder           TYPE clike OPTIONAL
        !displayformat         TYPE clike OPTIONAL
        !valueformat           TYPE clike OPTIONAL
        !required              TYPE clike OPTIONAL
        !valuestate            TYPE clike OPTIONAL
        !valuestatetext        TYPE clike OPTIONAL
        !enabled               TYPE clike OPTIONAL
        !showcurrentdatebutton TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view .
    METHODS time_picker
      IMPORTING
        !value         TYPE clike OPTIONAL
        !placeholder   TYPE clike OPTIONAL
        !enabled       TYPE clike OPTIONAL
        !valuestate    TYPE clike OPTIONAL
        !displayformat TYPE clike OPTIONAL
        !valueformat   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
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
        !text         TYPE clike OPTIONAL
        !href         TYPE clike OPTIONAL
        !target       TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
        !ns           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS list
      IMPORTING
        !headertext      TYPE clike OPTIONAL
        !items           TYPE clike OPTIONAL
        !mode            TYPE clike OPTIONAL
        !selectionchange TYPE clike OPTIONAL
        !nodata          TYPE clike OPTIONAL
        !showSeparators  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view .
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
        !title        TYPE clike OPTIONAL
        !description  TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
        !info         TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !selected     TYPE clike OPTIONAL
        !counter      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS item
      IMPORTING
        !key          TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS segmented_button_item
      IMPORTING
        !icon         TYPE clike OPTIONAL
        !key          TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS combobox
      IMPORTING
        !selectedkey   TYPE clike OPTIONAL
        !showclearicon TYPE clike OPTIONAL
        !label         TYPE clike OPTIONAL
        !items         TYPE clike OPTIONAL
        !change        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .
    METHODS multi_combobox
      IMPORTING
        !selectionchange     TYPE clike OPTIONAL
        !selectionfinish     TYPE clike OPTIONAL
        !width               TYPE clike OPTIONAL
        !showclearicon       TYPE clike OPTIONAL
        !showsecondaryvalues TYPE clike OPTIONAL
        !showselectall       TYPE clike OPTIONAL
        !selectedkeys        TYPE clike OPTIONAL
        !items               TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view .
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
        !value           TYPE clike OPTIONAL
        !rows            TYPE clike OPTIONAL
        !height          TYPE clike OPTIONAL
        !width           TYPE clike OPTIONAL
        valueLiveUpdate  TYPE clike OPTIONAL
        !editable        TYPE clike OPTIONAL
        !enabled         TYPE clike OPTIONAL
        !growing         TYPE clike OPTIONAL
        !growingmaxlines TYPE clike OPTIONAL
        !id              TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS generic_tag
      IMPORTING
        !arialabelledby TYPE clike OPTIONAL
        !text           TYPE clike OPTIONAL
        !design         TYPE clike OPTIONAL
        !status         TYPE clike OPTIONAL
        !class          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS object_attribute
      IMPORTING
        !title        TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS object_number
      IMPORTING
        !state        TYPE clike OPTIONAL
        !emphasized   TYPE clike OPTIONAL
        !number       TYPE clike OPTIONAL
        !unit         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

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
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .
    METHODS checkbox
      IMPORTING
        !text         TYPE clike OPTIONAL
        !selected     TYPE clike OPTIONAL
        !enabled      TYPE clike OPTIONAL
        !select       TYPE clike OPTIONAL
          PREFERRED PARAMETER selected
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS header_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS text
      IMPORTING
        !text         TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
        !ns           TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS formatted_text
      IMPORTING
        !htmltext     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS _generic
      IMPORTING
        !name         TYPE clike
        !ns           TYPE clike OPTIONAL
        !t_prop       TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS _generic_property
      IMPORTING
        !val          TYPE z2ui5_if_client=>ty_s_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS cc_file_uploader
      IMPORTING
        !value        TYPE clike OPTIONAL
        !path         TYPE clike OPTIONAL
        !placeholder  TYPE clike OPTIONAL
        !upload       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS cc_file_uploader_get_js
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
        !usetoolbar   TYPE clike DEFAULT 'false'
        !search       TYPE clike OPTIONAL
        !filterchange TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
        !layout       TYPE clike
        !id           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
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
          PREFERRED PARAMETER rows
      RETURNING
        VALUE(result)             TYPE REF TO z2ui5_cl_xml_view .
    METHODS ui_column
      IMPORTING
        !width               TYPE clike OPTIONAL
        !showsortmenuentry   TYPE clike OPTIONAL
        !sortproperty        TYPE clike OPTIONAL
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
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    METHODS side_content
      IMPORTING
        !width        TYPE clike OPTIONAL
          PREFERRED PARAMETER width
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)                  TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS appointment_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS block_layout_row
      IMPORTING
        !rowcolorset  TYPE clike OPTIONAL
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
        !class        TYPE clike OPTIONAL
        !select       TYPE clike OPTIONAL
        !expand       TYPE clike OPTIONAL
        !expandable   TYPE abap_bool OPTIONAL
        !expanded     TYPE abap_bool OPTIONAL
        !selectedkey  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS icon_tab_filter
      IMPORTING
        !items        TYPE clike OPTIONAL
        !showall      TYPE abap_bool OPTIONAL
        !icon         TYPE clike OPTIONAL
        !iconcolor    TYPE clike OPTIONAL
        !count        TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !key          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS icon_tab_separator
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .


    METHODS cc_export_spreadsheet_get_js
      IMPORTING
        !columnconfig TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS cc_export_spreadsheet
      IMPORTING
        !tableid      TYPE clike
        !type         TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS gantt_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view.

    METHODS tool_page
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.
    METHODS tool_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.
    METHODS subheader
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS icon_tab_header
      IMPORTING
        !selectedkey  TYPE clike OPTIONAL
        !items        TYPE clike OPTIONAL
        !select       TYPE clike OPTIONAL
        !mode         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS nav_container
      IMPORTING
        !initialpage           TYPE clike OPTIONAL
        !id                    TYPE clike OPTIONAL
        !defaulttransitionname TYPE clike OPTIONAL
      RETURNING
        VALUE(result)          TYPE REF TO z2ui5_cl_xml_view.

    METHODS pages
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.


    METHODS main_contents
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS nodes
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS lanes
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    METHODS process_flow_lane_header
      IMPORTING
        !iconsrc      TYPE clike OPTIONAL
        !laneid       TYPE clike OPTIONAL
        !position     TYPE clike OPTIONAL
        !state        TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !zoomlevel    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.


    METHODS view_settings_dialog
      IMPORTING
          !confirm                   TYPE clike OPTIONAL
          !cancel                    TYPE clike OPTIONAL
          !filterDetailPageOpened    TYPE clike OPTIONAL
          !reset                     TYPE clike OPTIONAL
          !resetFilters              TYPE clike OPTIONAL
          !filterSearchOperator      TYPE clike OPTIONAL
          !groupDescending           TYPE clike OPTIONAL
          !sortDescending            TYPE clike OPTIONAL
          !title                     TYPE clike OPTIONAL
          !titleAlignment            TYPE clike OPTIONAL
          !selectedGroupItem         TYPE clike OPTIONAL
          !selectedPresetFilterItem  TYPE clike OPTIONAL
          !selectedSortItem          TYPE clike OPTIONAL
          !filterItems               TYPE clike OPTIONAL
          !sortItems                 TYPE clike OPTIONAL
          !groupItems                TYPE clike OPTIONAL
        RETURNING
          VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS filter_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS sort_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS group_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS view_settings_filter_item
      IMPORTING
            !enabled         TYPE clike OPTIONAL
            !key             TYPE clike OPTIONAL
            !multiSelect     TYPE clike OPTIONAL
            !selected        TYPE clike OPTIONAL
            !text            TYPE clike OPTIONAL
            !textDirection   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS view_settings_item
      IMPORTING
            !enabled         TYPE clike OPTIONAL
            !key             TYPE clike OPTIONAL
            !selected        TYPE clike OPTIONAL
            !text            TYPE clike OPTIONAL
            !textDirection   TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS variant_management
      IMPORTING
        !defaultVariantKey      TYPE clike OPTIONAL
        !enabled                TYPE clike OPTIONAL
        !inErrorState           TYPE clike OPTIONAL
        !initialSelectionKey    TYPE clike OPTIONAL
        !lifecycleSupport       TYPE clike OPTIONAL
        !selectionKey           TYPE clike OPTIONAL
        !showCreateTile         TYPE clike OPTIONAL
        !showExecuteOnSelection TYPE clike OPTIONAL
        !showSetAsDefault       TYPE clike OPTIONAL
        !showShare              TYPE clike OPTIONAL
        !standardItemAuthor     TYPE clike OPTIONAL
        !standardItemText       TYPE clike OPTIONAL
        !useFavorites           TYPE clike OPTIONAL
        !visible                TYPE clike OPTIONAL
        !variantItems           TYPE clike OPTIONAL
        !manage                 TYPE clike OPTIONAL
        !save                   TYPE clike OPTIONAL
        !select                 TYPE clike OPTIONAL
        !uservarcreate          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS variant_items
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    METHODS variant_item
      IMPORTING
        !executeOnSelection      TYPE clike OPTIONAL
        !global                  TYPE clike OPTIONAL
        !labelReadOnly           TYPE clike OPTIONAL
        !lifecyclePackage        TYPE clike OPTIONAL
        !lifecycleTransportId    TYPE clike OPTIONAL
        !namespace               TYPE clike OPTIONAL
        !readOnly                TYPE clike OPTIONAL
        !executeOnSelect         TYPE clike OPTIONAL
        !author                  TYPE clike OPTIONAL
        !changeable              TYPE clike OPTIONAL
        !enabled                 TYPE clike OPTIONAL
        !favorite                TYPE clike OPTIONAL
        !key                     TYPE clike OPTIONAL
        !text                    TYPE clike OPTIONAL
        !title                   TYPE clike OPTIONAL
        !textDirection           TYPE clike OPTIONAL
        !originalTitle           TYPE clike OPTIONAL
        !originalExecuteOnSelect TYPE clike OPTIONAL
        !remove                  TYPE clike OPTIONAL
        !rename                  TYPE clike OPTIONAL
        !originalFavorite        TYPE clike OPTIONAL
        !sharing                 TYPE clike OPTIONAL
        !change                  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS feed_input
      IMPORTING
            !buttonTooltip    TYPE clike OPTIONAL
            !enabled          TYPE clike OPTIONAL
            !growing          TYPE clike OPTIONAL
            !growingMaxLines  TYPE clike OPTIONAL
            !icon             TYPE clike OPTIONAL
            !iconDensityAware TYPE clike OPTIONAL
            !iconDisplayShape TYPE clike OPTIONAL
            !iconInitials     TYPE clike OPTIONAL
            !iconSize         TYPE clike OPTIONAL
            !maxLength        TYPE clike OPTIONAL
            !placeholder      TYPE clike OPTIONAL
            !rows             TYPE clike OPTIONAL
            !showExceededText TYPE clike OPTIONAL
            !showIcon         TYPE clike OPTIONAL
            !value            TYPE clike OPTIONAL
            !post             TYPE clike OPTIONAL
            !class            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS feed_list_item
      IMPORTING
            !activeIcon                  TYPE clike OPTIONAL
            !convertedLinksDefaultTarget TYPE clike OPTIONAL
            !convertLinksToAnchorTags    TYPE clike OPTIONAL
            !icon                        TYPE clike OPTIONAL
            !iconActive                  TYPE clike OPTIONAL
            !iconDensityAware            TYPE clike OPTIONAL
            !iconDisplayShape            TYPE clike OPTIONAL
            !iconInitials                TYPE clike OPTIONAL
            !iconSize                    TYPE clike OPTIONAL
            !info                        TYPE clike OPTIONAL
            !lessLabel                   TYPE clike OPTIONAL
            !maxCharacters               TYPE clike OPTIONAL
            !moreLabel                   TYPE clike OPTIONAL
            !sender                      TYPE clike OPTIONAL
            !senderActive                TYPE clike OPTIONAL
            !showIcon                    TYPE clike OPTIONAL
            !text                        TYPE clike OPTIONAL
            !timestamp                   TYPE clike OPTIONAL
            !iconPress                   TYPE clike OPTIONAL
            !senderPress                 TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS feed_list_item_action
      IMPORTING
            !enabled   TYPE clike OPTIONAL
            !icon      TYPE clike OPTIONAL
            !key       TYPE clike OPTIONAL
            !text      TYPE clike OPTIONAL
            !visible   TYPE clike OPTIONAL
            !press     TYPE clike OPTIONAL
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

  METHODS mask_input
    IMPORTING
      !placeholder           TYPE clike OPTIONAL
      !mask                  TYPE clike OPTIONAL
      !name                  TYPE clike OPTIONAL
      !textAlign             TYPE clike OPTIONAL
      !textDirection         TYPE clike OPTIONAL
      !value                 TYPE clike OPTIONAL
      !width                 TYPE clike OPTIONAL
      !valueState            TYPE clike OPTIONAL
      !valueStateText        TYPE clike OPTIONAL
      !placeholderSymbol     TYPE clike OPTIONAL
      !required              TYPE clike OPTIONAL
      !showClearIcon         TYPE clike OPTIONAL
      !showValueStateMessage TYPE clike OPTIONAL
      !visible               TYPE clike OPTIONAL
      !fieldWidth            TYPE clike OPTIONAL
    RETURNING
      VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

  METHODS responsive_splitter
    IMPORTING
      !defaultPane        TYPE clike OPTIONAL
      !height             TYPE clike OPTIONAL
      !width              TYPE clike OPTIONAL
    RETURNING
      VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

  METHODS pane_container
    IMPORTING
      !resize             TYPE clike OPTIONAL
      !orientation        TYPE clike OPTIONAL
    RETURNING
      VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

  METHODS split_pane
    IMPORTING
      !id                  TYPE clike OPTIONAL
      !requiredParentWidth TYPE clike OPTIONAL
    RETURNING
      VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

  METHODS splitter_layout_data
    IMPORTING
      !size               TYPE clike OPTIONAL
      !minSize            TYPE clike OPTIONAL
      !resizable          TYPE clike OPTIONAL
    RETURNING
      VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

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
    result = _generic( `additionalContent` ).
  ENDMETHOD.


  METHOD appointments.
    result = _generic( `appointments` ).
  ENDMETHOD.


  METHOD appointment_items.
    result = _generic( name = `appointmentItems` ).
  ENDMETHOD.


  METHOD avatar.
    result = me.
    _generic( name   = `Avatar`
              t_prop = VALUE #( ( n = `src`         v = src )
                                ( n = `class`       v = class )
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
                                ( n = `visible`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) ) ) ).
  ENDMETHOD.


  METHOD bar.
    result = _generic( `Bar` ).
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
                                         ( n = `selectable`                v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selectable ) )
                                         ( n = `selectedFill`              v = selectedfill )
                                         ( n = `fill`                      v = fill )
                                         ( n = `height`                    v = height )
                                         ( n = `title`                     v = title )
                                         ( n = `animationSettings`         v = animationsettings )
                                         ( n = `alignShape`                v = alignshape )
                                         ( n = `color`                     v = color   )
                                         ( n = `fontSize`                  v = fontsize )
                                         ( n = `connectable`               v = z2ui5_cl_fw_utility=>boolean_abap_2_json( connectable ) )
                                         ( n = `fontFamily`                v = fontfamily )
                                         ( n = `filter`                    v = filter )
                                         ( n = `transform`                 v = transform )
                                         ( n = `countInBirdEye`            v = z2ui5_cl_fw_utility=>boolean_abap_2_json( countinbirdeye ) )
                                         ( n = `fontWeight`                v = fontweight   )
                                         ( n = `showTitle`                 v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showtitle ) )
                                         ( n = `selected`                  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selected ) )
                                         ( n = `resizable`                 v = z2ui5_cl_fw_utility=>boolean_abap_2_json( resizable ) )
                                         ( n = `horizontalTextAlignment`   v = horizontaltextalignment )
                                         ( n = `highlighted`               v = z2ui5_cl_fw_utility=>boolean_abap_2_json( highlighted ) )
                                         ( n = `highlightable`             v = z2ui5_cl_fw_utility=>boolean_abap_2_json( highlightable ) ) ) ).
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
                       t_prop = VALUE #( ( n = `background` v = background ) ) ).
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
                                         ( n = `titleLevel` v = titlelevel ) ) ).
  ENDMETHOD.


  METHOD block_layout_row.
    result = _generic( name   = `BlockLayoutRow`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `rowColorSet` v = rowcolorset ) ) ).
  ENDMETHOD.


  METHOD button.

    result = me.
    _generic( name   = `Button`
              ns     = ns
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `visible` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `id`      v = id )
                                ( n = `tooltip` v = tooltip )
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


  METHOD carousel.

    result = _generic( name   = `Carousel`
                       t_prop = VALUE #( ( n = `loop`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( loop ) )
                                         ( n = `class`  v = class )
                                         ( n = `height`  v = height )
               ) ).

  ENDMETHOD.


  METHOD cc_export_spreadsheet.

    result = me.
    _generic( name   = `ExportSpreadsheet`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `tableId`  v = tableid )
                                ( n = `text`     v = text )
                                ( n = `icon`     v = icon )
                                ( n = `type`     v = type )
              ) ).

  ENDMETHOD.


  METHOD cc_export_spreadsheet_get_js.

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
                          `                          //   vViewPrefix = sap.z2ui5.oView.sId;` && |\n| &&
                          `                           //  vPrefixTableId = vViewPrefix + "--" + vTableId;` && |\n| &&
                          `                             vPrefixTableId = sap.z2ui5.oView.createId( vTableId );` && |\n| &&
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
                                ( n = `enabled`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `select`   v = select ) ) ).
  ENDMETHOD.


  METHOD code_editor.
    result = me.
    _generic( name   = `CodeEditor`
              ns     = `editor`
              t_prop = VALUE #( ( n = `value`   v = value )
                                ( n = `type`    v = type )
                                ( n = `editable`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) )
                                ( n = `height` v = height )
                                ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD column.
    result = _generic( name   = `Column`
                       t_prop = VALUE #( ( n = `width` v = width )
                                         ( n = `minScreenWidth` v = minscreenwidth )
                                         ( n = `halign` v = halign )
                                         ( n = `demandPopin` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( demandpopin ) ) ) ).
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
                       t_prop = VALUE #( (  n = `showClearIcon` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showclearicon ) )
                                         (  n = `selectedKey`   v = selectedkey )
                                         (  n = `items`         v = items )
                                         (  n = `label`         v = label )
                                         (  n = `change`        v = change ) ) ).
  ENDMETHOD.


  METHOD constructor.

    mt_prop = VALUE #( ( n = `xmlns`           v = `sap.m` )
                       ( n = `xmlns:z2ui5`     v = `z2ui5` )
                       ( n = `xmlns:core`      v = `sap.ui.core` )
                       ( n = `xmlns:mvc`       v = `sap.ui.core.mvc` )
                       ( n = `xmlns:layout`    v = `sap.ui.layout` )
*                       ( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` )
*                       ( n = `core:require` v = `{ URLHelper: 'sap/m/library/URLHelper' }` )
                       ( n = `xmlns:table `    v = `sap.ui.table` )
                       ( n = `xmlns:f`         v = `sap.f` )
                       ( n = `xmlns:form`      v = `sap.ui.layout.form` )
                       ( n = `xmlns:editor`    v = `sap.ui.codeeditor` )
                       ( n = `xmlns:mchart`    v = `sap.suite.ui.microchart` )
                       ( n = `xmlns:webc`      v = `sap.ui.webc.main` )
                       ( n = `xmlns:uxap`      v = `sap.uxap` )
                       ( n = `xmlns:sap`       v = `sap` )
                       ( n = `xmlns:text`      v = `sap.ui.richtextedito` )
                       ( n = `xmlns:html`      v = `http://www.w3.org/1999/xhtml` )
                       ( n = `xmlns:fb`        v = `sap.ui.comp.filterbar` )
                       ( n = `xmlns:u`         v = `sap.ui.unified` )
                       ( n = `xmlns:gantt`     v = `sap.gantt.simple` )
                       ( n = `xmlns:axistime`  v = `sap.gantt.axistime` )
                       ( n = `xmlns:config`    v = `sap.gantt.config` )
                       ( n = `xmlns:shapes`    v = `sap.gantt.simple.shapes` )
                       ( n = `xmlns:commons`   v = `sap.suite.ui.commons` )
                       ( n = `xmlns:vm`        v = `sap.ui.comp.variants` )
                       ( n = `xmlns:tnt `      v = `sap.tnt` ) ).

  ENDMETHOD.


  METHOD container_toolbar.
    result = _generic( name   = `ContainerToolbar`
                       ns     = `gantt`
                       t_prop = VALUE #( ( n = `showSearchButton`          v = showsearchbutton )
                                         ( n = `alignCustomContentToRight` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( aligncustomcontenttoright ) )
                                         ( n = `findMode`                  v = findmode )
                                         ( n = `infoOfSelectItems`         v = infoofselectitems )
                                         ( n = `showBirdEyeButton`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showbirdeyebutton ) )
                                         ( n = `showDisplayTypeButton`     v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showdisplaytypebutton ) )
                                         ( n = `showLegendButton`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showlegendbutton ) )
                                         ( n = `showSettingButton`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showsettingbutton ) )
                                         ( n = `showTimeZoomControl`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showtimezoomcontrol ) )
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


  METHOD custom_list_item.
    result = _generic( `CustomListItem` ).
  ENDMETHOD.


  METHOD date_picker.
    result = me.
    _generic( name   = `DatePicker`
              t_prop = VALUE #( ( n = `value`                 v = value )
                                ( n = `displayFormat`         v = displayformat )
                                ( n = `valueFormat`           v = valueformat )
                                ( n = `required`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( required ) )
                                ( n = `valueState`            v = valuestate )
                                ( n = `valueStateText`        v = valuestatetext )
                                ( n = `placeholder`           v = placeholder )
                                ( n = `enabled`               v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `showCurrentDateButton` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showcurrentdatebutton ) ) ) ).
  ENDMETHOD.


  METHOD date_time_picker.
    result = me.
    _generic( name   = `DateTimePicker`
              t_prop = VALUE #( ( n = `value` v = value )
                                ( n = `placeholder`  v = placeholder )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `valueState` v = valuestate ) ) ).
  ENDMETHOD.


  METHOD dialog.

    result = _generic( name   = `Dialog`
                       t_prop = VALUE #( ( n = `title`  v = title )
                                         ( n = `icon`  v = icon )
                                         ( n = `stretch`  v = stretch )
                                         ( n = `showHeader`  v = showheader )
                                         ( n = `contentWidth`  v = contentwidth )
                                         ( n = `contentHeight`  v = contentheight )
                                         ( n = `resizable`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( resizable ) ) ) ).

  ENDMETHOD.


  METHOD dynamic_page.
    result = _generic( name   = `DynamicPage`
                       ns     = `f`
                       t_prop = VALUE #(
                           (  n = `headerExpanded`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( headerexpanded ) )
                           (  n = `headerPinned`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( headerpinned ) )
                           (  n = `showFooter`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showfooter ) )
                           (  n = `toggleHeaderOnTitleClick` v = toggleheaderontitleclick ) ) ).
  ENDMETHOD.


  METHOD dynamic_page_header.
    result = _generic(
                 name   = `DynamicPageHeader`
                 ns     = `f`
                 t_prop = VALUE #( (  n = `pinnable`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( pinnable ) ) ) ).
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
                                (  n = 'height'         v = '100%' ) ).

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


  METHOD feed_input.
    result = _generic( name   = `FeedInput`
                       t_prop = VALUE #( ( n = `buttonTooltip`    v = buttonTooltip )
                                         ( n = `enabled`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                         ( n = `growing`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( growing ) )
                                         ( n = `growingMaxLines`  v = growingMaxLines )
                                         ( n = `icon`             v = icon )
                                         ( n = `iconDensityAware` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( iconDensityAware ) )
                                         ( n = `iconDisplayShape` v = iconDisplayShape )
                                         ( n = `iconInitials`     v = iconInitials )
                                         ( n = `iconSize`         v = iconSize )
                                         ( n = `maxLength`        v = maxLength )
                                         ( n = `placeholder`      v = placeholder )
                                         ( n = `rows`             v = rows )
                                         ( n = `showExceededText` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showExceededText ) )
                                         ( n = `showIcon`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showIcon ) )
                                         ( n = `value`            v = value )
                                         ( n = `class`            v = class )
                                         ( n = `post`             v = post ) ) ).

    ENDMETHOD.


  METHOD feed_list_item.
    result = _generic( name   = `FeedListItem`
                       t_prop = VALUE #( ( n = `activeIcon`                  v = activeIcon )
                                         ( n = `convertedLinksDefaultTarget` v = convertedLinksDefaultTarget )
                                         ( n = `convertLinksToAnchorTags`    v = convertLinksToAnchorTags )
                                         ( n = `iconActive`                  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( iconActive ) )
                                         ( n = `icon`                        v = icon )
                                         ( n = `iconDensityAware`            v = z2ui5_cl_fw_utility=>boolean_abap_2_json( iconDensityAware ) )
                                         ( n = `iconDisplayShape`            v = iconDisplayShape )
                                         ( n = `iconInitials`                v = iconInitials )
                                         ( n = `iconSize`                    v = iconSize )
                                         ( n = `info`                        v = info )
                                         ( n = `lessLabel`                   v = lessLabel )
                                         ( n = `maxCharacters`               v = maxCharacters )
                                         ( n = `moreLabel`                   v = moreLabel )
                                         ( n = `sender`                      v = sender )
                                         ( n = `senderActive`                v = z2ui5_cl_fw_utility=>boolean_abap_2_json( senderActive ) )
                                         ( n = `showIcon`                    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showIcon ) )
                                         ( n = `text`                        v = text )
                                         ( n = `senderPress`                 v = senderPress )
                                         ( n = `iconPress`                   v = iconPress )
                                         ( n = `timestamp`                   v = timestamp ) ) ).
  ENDMETHOD.


  METHOD feed_list_item_action.
    result =  _generic( name   = `FeedListItemAction`
                        t_prop = VALUE #( ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                          ( n = `icon`    v = icon )
                                          ( n = `key`     v = key )
                                          ( n = `text`    v = text )
                                          ( n = `press`   v = press )
                                          ( n = `visible` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) ) ) ).
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


  METHOD filter_items.
    result = _generic( name = `filterItems` ).
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
                                         ( n = `fitContainer`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( fitcontainer ) )
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
                                         ( n = `text`   v = text ) ) ).

  ENDMETHOD.


  METHOD generic_tile.

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


  METHOD hbox.
    result = _generic( name   = `HBox`
                       t_prop = VALUE #( ( n = `class`          v = class )
                                         ( n = `alignContent`   v = aligncontent )
                                         ( n = `alignItems`     v = alignitems )
                                         ( n = `width`          v = width )
                                         ( n = `height`         v = height )
                                         ( n = `wrap`           v = wrap )
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


  METHOD hlp_get_app_url.

    IF classname IS NOT SUPPLIED.
      classname = z2ui5_cl_fw_utility=>rtti_get_classname_by_ref( mi_client->get( )-s_draft-app ).
    ENDIF.

    DATA(lv_url) = to_lower( mi_client->get( )-s_config-origin && mi_client->get( )-s_config-pathname ) && `?`.
    DATA(lt_param) = z2ui5_cl_fw_utility=>url_param_get_tab( mi_client->get( )-s_config-search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start` v = to_lower( classname ) ) INTO TABLE lt_param.

    result = lv_url && z2ui5_cl_fw_utility=>url_param_create_url( lt_param ).

  ENDMETHOD.


  METHOD hlp_get_source_code_url.

    DATA(ls_draft) = mo_root->mi_client->get( )-s_draft.
    DATA(ls_config) = mo_root->mi_client->get( )-s_config.

    result = ls_config-origin && `/sap/bc/adt/oo/classes/`
       && z2ui5_cl_fw_utility=>rtti_get_classname_by_ref( ls_draft-app ) && `/source/main`.

  ENDMETHOD.


  METHOD hlp_get_url_param.

    result = z2ui5_cl_fw_utility=>url_param_get(
      val = val
      url = mi_client->get( )-s_config-search ).

  ENDMETHOD.


  METHOD hlp_set_url_param.

    DATA(result) = z2ui5_cl_fw_utility=>url_param_set(
      url   = mi_client->get( )-s_config-search
      name  = n
      value = v ).

    mi_client->url_param_set( result ).

  ENDMETHOD.


  METHOD horizontal_layout.
    result = _generic( name   = `HorizontalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD icon_tab_bar.

    result = _generic( name   = `IconTabBar`
                       t_prop = VALUE #( ( n = `class`       v = class )
                                       ( n = `select`      v = select )
                                       ( n = `expand`      v = expand )
                                       ( n = `expandable`  v = expandable )
                                       ( n = `expanded`    v = expanded )
                                       ( n = `selectedKey` v = selectedkey ) ) ).
  ENDMETHOD.


  METHOD icon_tab_filter.

    result = _generic( name   = `IconTabFilter`
                       t_prop = VALUE #( ( n = `icon`        v = icon )
                                       (  n = `items`    v = items )
                                       ( n = `iconColor`   v = iconcolor )
                                       ( n = `showAll`     v = showall )
                                       ( n = `count`       v = count )
                                       ( n = `text`        v = text )
                                       ( n = `key`         v = key ) ) ).
  ENDMETHOD.


  METHOD icon_tab_header.

    result = _generic( name   = `IconTabHeader`
                       t_prop = VALUE #( (  n = `selectedKey`     v = selectedkey )
                                         (  n = `items`           v = items )
                                         (  n = `select`          v = select )
                                         (  n = `mode`            v = mode  ) ) ).

  ENDMETHOD.


  METHOD icon_tab_separator.

    result = _generic( `IconTabSeparator` ).

  ENDMETHOD.


  METHOD illustrated_message.

    result = _generic( name   = `IllustratedMessage`
                       t_prop = VALUE #( ( n = `enableVerticalResponsiveness` v = enableverticalresponsiveness )
                       ( n = `illustrationType`             v = illustrationtype )
                       ( n = `enableFormattedText`             v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enableformattedtext ) )
                       ( n = `illustrationSize`             v = illustrationsize )
                       ( n = `description`             v = description )
                       ( n = `title`             v = title )
                       ) ).
  ENDMETHOD.


  METHOD image.
    result = me.
    _generic( name   = `Image`
              t_prop = VALUE #(
                ( n = `src` v = src )
                ( n = class v = class )
                ( n = `height` v = height )
                 ) ).
  ENDMETHOD.


  METHOD image_content.

    result = _generic( name   = `ImageContent`
                       t_prop = VALUE #( ( n = `src` v = src ) ) ).


  ENDMETHOD.


  METHOD info_label.
    result = _generic( name   = `InfoLabel`
                       ns     = 'tnt'
                       t_prop = VALUE #(
                           ( n = `id`                   v = id )
                           ( n = `text`                 v = text )
                           ( n = `renderMode `          v = rendermode  )
                           ( n = `colorScheme`          v = colorscheme )
                           ( n = `displayOnly`          v = displayonly )
                           ( n = `icon`                 v = icon )
                           ( n = `textDirection`        v = textdirection )
                           ( n = `width`                v = width ) ) ).

  ENDMETHOD.


  METHOD input.
    result = me.
    _generic( name   = `Input`
              t_prop = VALUE #( ( n = `id`               v = id )
                                ( n = `placeholder`      v = placeholder )
                                ( n = `type`             v = type )
                                ( n = `showClearIcon`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showclearicon ) )
                                ( n = `description`      v = description )
                                ( n = `editable`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) )
                                ( n = `enabled`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `visible`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) )
                                ( n = `showTableSuggestionValueHelp`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showtablesuggestionvaluehelp ) )
                                ( n = `valueState`       v = valuestate )
                                ( n = `valueStateText`   v = valuestatetext )
                                ( n = `value`            v = value )
                                ( n = `required`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( required ) )
                                ( n = `suggest`          v = suggest )
                                ( n = `suggestionItems`  v = suggestionitems )
                                ( n = `suggestionRows`   v = suggestionrows )
                                ( n = `showSuggestion`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showsuggestion ) )
                                ( n = `valueHelpRequest` v = valuehelprequest )
                                ( n = `autocomplete`     v = z2ui5_cl_fw_utility=>boolean_abap_2_json( autocomplete ) )
                                ( n = `valueLiveUpdate`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( valueliveupdate ) )
                                ( n = `submit`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( submit ) )
                                ( n = `showValueHelp`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showvaluehelp ) )
                                ( n = `valueHelpOnly`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( valuehelponly ) )
                                ( n = `class`            v = class )
                                ( n = `maxSuggestionWidth` v = maxsuggestionwidth )
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
                                         ( n = `showError`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showerror ) )
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
                                         ( n = `showError`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showerror ) )
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
                                         ( n = `selected`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selected ) ) ) ).
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
    result = _generic( `items` ).
  ENDMETHOD.


  METHOD label.
    result = me.
    _generic( name   = `Label`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `design`   v = design )
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


  METHOD link.
    result = me.
    _generic( name   = `Link`
              ns     = ns
              t_prop = VALUE #( ( n = `text`    v = text )
                                ( n = `target`  v = target )
                                ( n = `href`    v = href )
                                ( n = `press`   v = press )
                                ( n = `id`      v = id )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) ) ) ).
  ENDMETHOD.


  METHOD list.
    result = _generic( name   = `List`
                       t_prop = VALUE #( ( n = `headerText`      v = headertext )
                                         ( n = `items`           v = items )
                                         ( n = `mode`            v = mode )
                                         ( n = `selectionChange` v = selectionchange )
                                         ( n = `showSeparators ` v = showSeparators )
                                         ( n = `noData` v = nodata ) ) ).
  ENDMETHOD.


  METHOD list_item.
    result = me.
    _generic( name   = `ListItem`
              ns     = `core`
              t_prop = VALUE #( ( n = `text` v = text )
                                ( n = `additionalText` v = additionaltext ) ) ).
  ENDMETHOD.


  METHOD main_contents.
    result = _generic( name   = `mainContents`
                       ns     = `tnt` ).

  ENDMETHOD.


  METHOD mask_input.
    result = me.
    _generic( name   = `MaskInput`
              t_prop = VALUE #(
                                ( n = `placeholder`           v = placeholder )
                                ( n = `mask`                  v = mask )
                                ( n = `name`                  v = name )
                                ( n = `textAlign`             v = textAlign )
                                ( n = `textDirection`         v = textDirection )
                                ( n = `value`                 v = value )
                                ( n = `width`                 v = width )
                                ( n = `valueState`            v = valueState )
                                ( n = `valueStateText`        v = valueStateText )
                                ( n = `placeholderSymbol`     v = placeholderSymbol )
                                ( n = `required`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( required ) )
                                ( n = `showClearIcon`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showClearIcon ) )
                                ( n = `showValueStateMessage` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showValueStateMessage ) )
                                ( n = `visible`               v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) )
                                ( n = `fieldWidth`            v = fieldwidth ) ) ).
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
                                         ( n = `groupName`   v = groupname )
                                         ( n = `markupDescription`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( markupdescription ) ) ) ).
  ENDMETHOD.


  METHOD message_page.
    result = _generic( name   = `MessagePage`
                       t_prop = VALUE #(
                           ( n = `showHeader`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( show_header ) )
                           ( n = `description`         v = description )
                           ( n = `icon`                v = icon )
                           ( n = `text`                v = text )
                           ( n = `enableFormattedText` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enableformattedtext ) )
                            ) ).
  ENDMETHOD.


  METHOD message_popover.
    result = _generic( name   = `MessagePopover`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.


  METHOD message_strip.
    result = me.
    _generic( name   = `MessageStrip`
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `type`     v = type )
                                ( n = `showIcon` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showicon ) )
                                ( n = `class`    v = class ) ) ).
  ENDMETHOD.


  METHOD message_view.

    result = _generic( name   = `MessageView`
                       t_prop = VALUE #( ( n = `items`      v = items )
                                         ( n = `groupItems` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( groupitems ) ) ) ).
  ENDMETHOD.


  METHOD mid_column_pages.

    result = _generic( name   = `midColumnPages`
                       ns     = `f`
                       t_prop = VALUE #( ( n = `id` v = id ) ) ).

  ENDMETHOD.


  METHOD multi_combobox.
    result = _generic( name   = `ComboBox`
                       t_prop = VALUE #( (  n = `selectionChange`     v = selectionchange )
                                         (  n = `selectedKeys`        v = selectedkeys )
                                         (  n = `items`               v = items )
                                         (  n = `selectionFinish`     v = selectionfinish )
                                         (  n = `width`               v = width )
                                         (  n = `showClearIcon`       v = showclearicon )
                                         (  n = `showSecondaryValues` v = showsecondaryvalues )
                                         (  n = `showSelectAll`       v = showselectall ) ) ).
  ENDMETHOD.


  METHOD multi_input.
    result = _generic( name   = `MultiInput`
                       t_prop = VALUE #( ( n = `tokens` v = tokens )
                                         ( n = `showClearIcon` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showclearicon ) )
                                         ( n = `showValueHelp` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showvaluehelp ) )
                                         ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                         ( n = `suggestionItems` v = suggestionitems )
                                         ( n = `tokenUpdate` v = tokenupdate )
                                         ( n = `submit` v = submit )
                                         ( n = `width` v = width )
                                         ( n = `value` v = value )
                                         ( n = `id` v = id )
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
                        (  n = `initialPage`  v = initialpage  )
                        (  n = `id`           v = id  )
                        (  n = `defaultTransitionName`   v = defaulttransitionname  )
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
                                         ( n = `withMargin` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( withmargin ) ) ) ).

  ENDMETHOD.


  METHOD object_attribute.
    result = me.

    _generic( name   = `ObjectAttribute`
              t_prop = VALUE #( (  n = `title`       v = title )
                                (  n = `text`           v = text ) ) ).
  ENDMETHOD.


  METHOD object_identifier.
    result = _generic( name   = `ObjectIdentifier`
                       t_prop = VALUE #( ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                         ( n = `text` v = text )
                                         ( n = `textDirection` v = textdirection )
                                         ( n = `title` v = title )
                                         ( n = `titleActive` v = titleactive )
                                         ( n = `visible` v = visible )
                                         ( n = `titlePress` v = titlepress ) ) ).
  ENDMETHOD.


  METHOD object_number.
    result = me.
    _generic( name   = `ObjectNumber`
              t_prop = VALUE #( ( n = `emphasized`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( emphasized ) )
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
                     ( n = `showTitleInHeaderContent` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showtitleinheadercontent ) )
                     ( n = `showEditHeaderButton`     v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showeditheaderbutton ) )
                     ( n = `editHeaderButtonPress`    v = editheaderbuttonpress )
                     ( n = `upperCaseAnchorBar`       v = uppercaseanchorbar ) ) ).
  ENDMETHOD.


  METHOD object_page_section.
    result = _generic( name   = `ObjectPageSection`
                       ns     = `uxap`
                       t_prop = VALUE #( ( n = `titleUppercase`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( titleuppercase ) )
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
                                         ( n = `emptyIndicatorMode` v = emptyindicatormode )
                                         ( n = `icon` v = icon )
                                         ( n = `iconDensityAware` v = icondensityaware )
                                         ( n = `inverted` v = inverted )
                                         ( n = `state` v = state )
                                         ( n = `stateAnnouncementText` v = stateannouncementtext )
                                         ( n = `text` v = text )
                                         ( n = `textDirection` v = textdirection )
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
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_menu_button.
    result = _generic( name   = `OverflowToolbarMenuButton`
                       t_prop = VALUE #( ( n = `buttonMode` v = buttonmode )
                                         ( n = `defaultAction` v = defaultaction )
                                         ( n = `text`    v = text )
                                         ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                         ( n = `icon`    v = icon )
                                         ( n = `type`    v = type )
                                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD overflow_toolbar_toggle_button.
    result = me.
    _generic( name   = `OverflowToolbarToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `icon`    v = icon )
                                ( n = `type`    v = type )
                                ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.


  METHOD page.
    result = _generic( name   = `Page`
                       ns     = ns
                       t_prop = VALUE #( ( n = `title` v = title )
                                         ( n = `showNavButton`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( shownavbutton ) )
                                         ( n = `navButtonPress` v = navbuttonpress )
                                         ( n = `showHeader` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showheader ) )
                                         ( n = `class` v = class )
                                         ( n = `id` v = id ) ) ).
  ENDMETHOD.


  METHOD pages.
    result = _generic( name   = `pages`  ).

  ENDMETHOD.


  METHOD panel.
    result = _generic( name   = `Panel`
                       t_prop = VALUE #( ( n = `expandable` v = expandable )
                                         ( n = `expanded`   v = expanded )
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
                                         ( n = `contentWidth`  v = contentwidth ) ) ).
  ENDMETHOD.


  METHOD process_flow.
    result = _generic( name   = `ProcessFlow`
                   ns     = 'commons'
                   t_prop = VALUE #( ( n = `id`               v = id )
                                     ( n = `foldedCorners`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( foldedcorners ) )
                                     ( n = `scrollable`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( scrollable ) )
                                     ( n = `showLabels`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showlabels ) )
                                     ( n = `visible`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) )
                                     ( n = `wheelZoomable`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( wheelzoomable ) )
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
                                     ( n = `highlighted`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( highlighted )  )
                                     ( n = `focused`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( focused ) )
                                     ( n = `selected`             v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selected ) )
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
                                ( n = `showValue`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showvalue ) )
                                ( n = `state`        v = state ) ) ).
  ENDMETHOD.


  METHOD proportion_zoom_strategy.
    result = _generic( name = `ProportionZoomStrategy`
                       ns   = `axistime` ).
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
    result = _generic( name = `RadioButton`
                   t_prop   = VALUE #( ( n = `activeHandling`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( activehandling ) )
                                     ( n = `editable`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) )
                                     ( n = `enabled`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                     ( n = `selected`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selected ) )
                                     ( n = `useEntireWidth`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( useentirewidth ) )
                                     ( n = `text`            v = text )
                                     ( n = `textDirection`   v = textdirection )
                                     ( n = `textAlign`       v = textalign )
                                     ( n = `groupName`       v = groupname )
                                     ( n = `valueState`      v = valuestate )
                                     ( n = `width`           v = width )
           ) ).
  ENDMETHOD.


  METHOD radio_button_group.
    result = _generic( name   = `RadioButtonGroup`
                       t_prop = VALUE #( ( n = `id`             v = id )
                                         ( n = `columns`        v = columns )
                                         ( n = `editable`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) )
                                         ( n = `enabled`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                         ( n = `selectedIndex`  v = selectedindex )
                                         ( n = `textDirection`  v = textdirection )
                                         ( n = `valueState`     v = valuestate )
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
                                ( n = `showTickmarks`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showtickmarks ) )
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
                       t_prop = VALUE #( ( n = `defaultPane`  v = defaultPane )
                                         ( n = `height`       v = height )
                                         ( n = `width`        v = width  ) ) ).
  ENDMETHOD.


  METHOD rows.
    result = _generic( `rows` ).
  ENDMETHOD.


  METHOD row_settings_template.
    result = _generic( name = `rowSettingsTemplate`
                       ns   = `table` ).
  ENDMETHOD.


  METHOD scroll_container.
    result = _generic( name   = `ScrollContainer`
                       t_prop = VALUE #( ( n = `height`      v = height )
                                         ( n = `width`       v = width )
                                         ( n = `vertical`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( vertical ) )
                                         ( n = `horizontal`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( horizontal ) )
                                         ( n = `focusable`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( focusable ) ) ) ).
  ENDMETHOD.


  METHOD search_field.
    result = me.
    _generic( name   = `SearchField`
              t_prop = VALUE #( ( n = `width`  v = width )
                                ( n = `search` v = search )
                                ( n = `value`  v = value )
                                ( n = `id`     v = id )
                                ( n = `change` v = change )
                                ( n = `autocomplete` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( autocomplete ) )
                                ( n = `liveChange` v = livechange ) ) ).
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
    result = _generic( name = `shapes1`
                       ns   = `gantt` ).
  ENDMETHOD.


  METHOD shapes2.
    result = _generic( name = `shapes2`
                       ns   = `gantt` ).
  ENDMETHOD.


  METHOD shell.
    result = _generic( name = `Shell`
                       ns   = ns ).
  ENDMETHOD.


  METHOD side_content.
    result = _generic( name   = `sideContent`
                       ns     = 'layout'
                       t_prop = VALUE #(
                           ( n = `width`                           v = width ) ) ).

  ENDMETHOD.


  METHOD simple_form.
    result = _generic( name   = `SimpleForm`
                       ns     = `form`
                       t_prop = VALUE #( ( n = `title`    v = title )
                                         ( n = `layout`   v = layout )
                                         ( n = `columnsXL`   v = columnsxl )
                                         ( n = `columnsL`   v = columnsl )
                                         ( n = `columnsM`   v = columnsm )
                                         ( n = `editable` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) ) ) ).
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
                                         ( n = `minSize`      v = minSize )
                                         ( n = `resizable`    v = z2ui5_cl_fw_utility=>boolean_abap_2_json( resizable ) ) ) ).
  ENDMETHOD.


  METHOD split_pane.
    result = _generic( name   = `SplitPane` ns = `layout`
                       t_prop = VALUE #( ( n = `id`                   v = id )
                                         ( n = `requiredParentWidth`  v = requiredParentWidth )  ) ).
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
                                ( n = `detailPress` v = detailpress )
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
                                ( n = `value` v = value )
                                ( n = `valueState` v = valuestate )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `description` v = description ) ) ).
  ENDMETHOD.


  METHOD stringify.

    result = get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD subheader.
    result = _generic( name = `subHeader`
                       ns   = `tnt` ).
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
                                ( n = `enabled`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
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
                           ( n = `selectionChange`  v = selectionchange )
                           ( n = `alternateRowColors`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `autoPopinMode`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( autopopinmode ) ) ) ).
  ENDMETHOD.


  METHOD table_select_dialog.

    result = _generic( name   = `TableSelectDialog`
               t_prop = VALUE #( ( n = `confirmButtonText`    v = confirmbuttontext )
                                 ( n = `contentHeight`        v = contentheight )
                                 ( n = `contentWidth`         v = contentwidth )
                                 ( n = `draggable`            v = z2ui5_cl_fw_utility=>boolean_abap_2_json( draggable ) )
                                 ( n = `growing`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( growing ) )
                                 ( n = `growingThreshold`     v = growingthreshold )
                                 ( n = `multiSelect`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( multiselect ) )
                                 ( n = `noDataText`           v = nodatatext )
                                 ( n = `rememberSelections`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( rememberselections ) )
                                 ( n = `resizable`            v = z2ui5_cl_fw_utility=>boolean_abap_2_json( resizable ) )
                                 ( n = `searchPlaceholder`    v = searchplaceholder )
                                 ( n = `showClearButton`      v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showclearbutton ) )
                                 ( n = `title`                v = title )
                                 ( n = `titleAlignment`       v = titlealignment )
                                 ( n = `items`                v = items )
                                 ( n = `search`               v = search )
                                 ( n = `confirm`              v = confirm )
                                 ( n = `cancel`               v = cancel )
                                 ( n = `liveChange`           v = livechange )
                                 ( n = `selectionChange`      v = selectionchange )
                                 ( n = `visible`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) ) ) ).
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
                                         ( n = `showTitle` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showtitle ) )
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
                                ( n = `valueLiveUpdate` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( valueLiveUpdate ) )
                                ( n = `editable` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `id` v = id )
                                ( n = `growing` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( growing ) )
                                ( n = `growingMaxLines` v = growingmaxlines ) ) ).
  ENDMETHOD.


  METHOD tile_content.

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
                                ( n = `placeholder`  v = placeholder )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                ( n = `valueState` v = valuestate )
                                ( n = `displayFormat` v = displayformat )
                                ( n = `valueFormat` v = valueformat ) ) ).
  ENDMETHOD.


  METHOD title.
    DATA(lv_name) = COND #( WHEN ns = 'f' THEN 'title' ELSE `Title` ).

    result = me.
    _generic( ns     = ns
              name   = lv_name
              t_prop = VALUE #( ( n = `text`     v = text )
                                ( n = `wrapping` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( wrapping ) )
                                ( n = `level` v = level ) ) ).
  ENDMETHOD.


  METHOD toggle_button.

    result = me.
    _generic( name   = `ToggleButton`
              t_prop = VALUE #( ( n = `press`   v = press )
                                ( n = `text`    v = text )
                                ( n = `enabled` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
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
                           ( n = `includeItemInSelection`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( includeiteminselection ) )
                           ( n = `inset`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( inset ) )
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
                           ( n = `alternateRowColors`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( alternaterowcolors ) )
                           ( n = `columnHeaderVisible`       v = columnheadervisible )
                           ( n = `editable`                  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( editable ) )
                           ( n = `enableCellFilter`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enablecellfilter ) )
                           ( n = `enableGrouping`            v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enablegrouping ) )
                           ( n = `senableSelectAll`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enableselectall ) )
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
                           ( n = `showColumnVisibilityMenu`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showcolumnvisibilitymenu ) )
                           ( n = `showNoData`                v = z2ui5_cl_fw_utility=>boolean_abap_2_json( shownodata ) )
                           ( n = `threshold`                 v = threshold )
                           ( n = `visibleRowCount`           v = visiblerowcount )
                           ( n = `visibleRowCountMode`       v = visiblerowcountmode )
                           ( n = `footer`                    v = footer )
                           ( n = `filter`                    v = filter )
                           ( n = `sort`                      v = sort )
                           ( n = `customFilter`              v = customfilter )
                           ( n = `id`              v = id )
                           ( n = `rowSelectionChange`        v = rowselectionchange )
                            ) ).

  ENDMETHOD.


  METHOD ui_template.

    result = _generic( name = `template`
                       ns   = 'table' ).

  ENDMETHOD.


  METHOD variant_item.

    result = _generic( name   = `VariantItem`
                         ns     = `vm`
                         t_prop = VALUE #( ( n = `executeOnSelection`      v = z2ui5_cl_fw_utility=>boolean_abap_2_json( executeOnSelection ) )
                                           ( n = `global`                  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( global ) )
                                           ( n = `labelReadOnly`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( labelReadOnly ) )
                                           ( n = `lifecyclePackage`        v = lifecyclePackage )
                                           ( n = `lifecycleTransportId`    v = lifecycleTransportId )
                                           ( n = `namespace`               v = namespace )
                                           ( n = `readOnly`                v = readOnly )
                                           ( n = `executeOnSelect`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( executeOnSelect ) )
                                           ( n = `author`                  v = author )
                                           ( n = `changeable`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( changeable ) )
                                           ( n = `enabled`                 v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                           ( n = `favorite`                v = z2ui5_cl_fw_utility=>boolean_abap_2_json( favorite ) )
                                           ( n = `key`                     v = key )
                                           ( n = `text`                    v = text )
                                           ( n = `title`                   v = title )
                                           ( n = `textDirection`           v = textDirection )
                                           ( n = `originalTitle`           v = originalTitle )
                                           ( n = `originalExecuteOnSelect` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( originalExecuteOnSelect ) )
                                           ( n = `remove`                  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( remove ) )
                                           ( n = `rename`                  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( rename ) )
                                           ( n = `originalFavorite`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( originalFavorite ) )
                                           ( n = `sharing`                 v = z2ui5_cl_fw_utility=>boolean_abap_2_json( sharing ) )
                                           ( n = `change`                  v = change ) ) ).

  ENDMETHOD.


  METHOD variant_items.

    result = _generic( name   = `variantItems`
                         ns     = `vm` ).

  ENDMETHOD.


  METHOD variant_management.

      result = _generic( name   = `VariantManagement`
                         ns     = `vm`
                         t_prop = VALUE #( ( n = `defaultVariantKey`      v = defaultVariantKey )
                                           ( n = `enabled`                v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                           ( n = `inErrorState`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( inErrorState ) )
                                           ( n = `initialSelectionKey`    v = initialSelectionKey )
                                           ( n = `lifecycleSupport`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( lifecycleSupport ) )
                                           ( n = `selectionKey`           v = selectionKey )
                                           ( n = `showCreateTile`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showCreateTile ) )
                                           ( n = `showExecuteOnSelection` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showExecuteOnSelection ) )
                                           ( n = `showSetAsDefault`       v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showSetAsDefault ) )
                                           ( n = `showShare`              v = z2ui5_cl_fw_utility=>boolean_abap_2_json( showShare ) )
                                           ( n = `standardItemAuthor`     v = standardItemAuthor )
                                           ( n = `standardItemText`       v = standardItemText )
                                           ( n = `useFavorites`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( useFavorites ) )
                                           ( n = `variantItems`           v = variantItems )
                                           ( n = `manage`                 v = manage )
                                           ( n = `save`                   v = save )
                                           ( n = `select`                 v = select )
                                           ( n = `variantCreationByUserAllowed` v = uservarcreate )
                                           ( n = `visible`                v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) ) ) ).

  ENDMETHOD.


  METHOD vbox.

    result = _generic( name   = `VBox`
                       t_prop = VALUE #( ( n = `height`          v = height )
                                         ( n = `justifyContent`  v = justifycontent )
                                         ( n = `renderType`      v = rendertype )
                                         ( n = `alignContent`    v = aligncontent )
                                         ( n = `alignItems`      v = alignitems )
                                         ( n = `width`           v = width )
                                         ( n = `wrap`            v = wrap )
                                         ( n = `class`           v = class ) ) ).

  ENDMETHOD.


  METHOD vertical_layout.

    result = _generic( name   = `VerticalLayout`
                       ns     = `layout`
                       t_prop = VALUE #( ( n = `class`  v = class )
                                         ( n = `width`  v = width ) ) ).
  ENDMETHOD.


  METHOD view_settings_dialog.

    result = _generic( name   = `ViewSettingsDialog`
              t_prop = VALUE #( ( n = `confirm`                  v = confirm )
                                ( n = `cancel`                   v = cancel )
                                ( n = `filterDetailPageOpened`   v = filterDetailPageOpened )
                                ( n = `reset`                    v = reset )
                                ( n = `resetFilters`             v = resetFilters )
                                ( n = `filterSearchOperator`     v = filterSearchOperator )
                                ( n = `groupDescending`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( groupDescending ) )
                                ( n = `sortDescending`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( sortDescending ) )
                                ( n = `title`                    v = title )
                                ( n = `selectedGroupItem`        v = selectedGroupItem )
                                ( n = `selectedPresetFilterItem` v = selectedPresetFilterItem )
                                ( n = `selectedSortItem`         v = selectedSortItem )
                                ( n = `selectedSortItem`         v = selectedSortItem )
                                ( n = `filterItems`              v = filterItems )
                                ( n = `sortItems`                v = sortItems )
                                ( n = `groupItems`               v = groupItems )
                                ( n = `titleAlignment`           v = titleAlignment ) ) ).

  ENDMETHOD.


  METHOD view_settings_filter_item.
    result = _generic( name   = `ViewSettingsFilterItem`
                  t_prop = VALUE #( ( n = `enabled`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                    ( n = `key`             v = key )
                                    ( n = `selected`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selected ) )
                                    ( n = `text`            v = text )
                                    ( n = `textDirection`   v = textDirection )
                                    ( n = `multiSelect`     v = z2ui5_cl_fw_utility=>boolean_abap_2_json( multiSelect ) ) ) ).
  ENDMETHOD.


  METHOD view_settings_item.
    result = _generic( name   = `ViewSettingsItem`
                  t_prop = VALUE #( ( n = `enabled`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enabled ) )
                                    ( n = `key`             v = key )
                                    ( n = `selected`        v = z2ui5_cl_fw_utility=>boolean_abap_2_json( selected ) )
                                    ( n = `text`            v = text )
                                    ( n = `textDirection`   v = textDirection ) ) ).

  ENDMETHOD.


  METHOD visible_horizon.
    result = _generic( name = `visibleHorizon`
                       ns   = `axistime` ).
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


  METHOD _generic_property.

    INSERT val INTO TABLE mt_prop.
    result = me.

  ENDMETHOD.
ENDCLASS.
