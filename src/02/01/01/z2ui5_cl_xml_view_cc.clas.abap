CLASS z2ui5_cl_xml_view_cc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS multiinput_ext
      IMPORTING
        !multiinputid  TYPE clike OPTIONAL
        !change        TYPE clike OPTIONAL
        !addedtokens   TYPE clike OPTIONAL
        !removedtokens TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view .

    METHODS multiinput
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
        !addedtokens      TYPE clike OPTIONAL
        !removedtokens    TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view .

    METHODS uitableext
      IMPORTING
        !tableid      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS camera_picture
      IMPORTING
        !id           TYPE clike OPTIONAL
        !value        TYPE clike OPTIONAL
        !press        TYPE clike OPTIONAL
        !autoplay     TYPE clike OPTIONAL
        !onphoto      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .
    METHODS bwip_js
      IMPORTING
        !bcid         TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !scale        TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS demo_output
      IMPORTING
        !val          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS focus
      IMPORTING
        !focusid        TYPE clike OPTIONAL
        !selectionstart TYPE clike OPTIONAL
        !selectionend   TYPE clike OPTIONAL
        !setupdate      TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view .
    METHODS geolocation
      IMPORTING
        !finished           TYPE clike OPTIONAL
        !longitude          TYPE any OPTIONAL
        !latitude           TYPE any OPTIONAL
        !altitude           TYPE any OPTIONAL
        !accuracy           TYPE any OPTIONAL
        !altitudeaccuracy   TYPE any OPTIONAL
        !speed              TYPE any OPTIONAL
        !heading            TYPE any OPTIONAL
        !enablehighaccuracy TYPE any OPTIONAL
        !timeout            TYPE any OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view .

    METHODS info_frontend
      IMPORTING
        !finished          TYPE clike OPTIONAL
        !ui5_version       TYPE any OPTIONAL
        !ui5_gav           TYPE any OPTIONAL
        !ui5_theme         TYPE any OPTIONAL
        !device_os         TYPE any OPTIONAL
        !device_systemtype TYPE any OPTIONAL
        !device_browser    TYPE any OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .

    METHODS spreadsheet_export
      IMPORTING
        !tableid      TYPE clike
        !type         TYPE clike OPTIONAL
        !text         TYPE clike OPTIONAL
        !icon         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS file_uploader
      IMPORTING
        !value             TYPE clike OPTIONAL
        !path              TYPE clike OPTIONAL
        !placeholder       TYPE clike OPTIONAL
        !upload            TYPE clike OPTIONAL
        !icononly          TYPE clike OPTIONAL
        !buttononly        TYPE clike OPTIONAL
        !buttontext        TYPE clike OPTIONAL
        !uploadbuttontext  TYPE clike OPTIONAL
        !checkdirectupload TYPE clike OPTIONAL
        !filetype          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view .

    METHODS messaging
      IMPORTING
        !items        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS title
      IMPORTING
        !title        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS history
      IMPORTING
        !search       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS scrolling
      IMPORTING
        !setupdate    TYPE clike OPTIONAL
        !items        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS timer
      IMPORTING
        !finished     TYPE clike OPTIONAL
        !delayms      TYPE clike OPTIONAL
        !checkrepeat  TYPE clike OPTIONAL
        !checkactive  TYPE clike OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS chartjs
      IMPORTING
        !canvas_id    TYPE clike OPTIONAL
        !view         TYPE clike OPTIONAL
        !config       TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !style        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS favicon
      IMPORTING
        !favicon      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view .

    METHODS constructor
      IMPORTING
        !view TYPE REF TO z2ui5_cl_xml_view .
  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_XML_VIEW_CC IMPLEMENTATION.


  METHOD bwip_js.

    result = mo_view.
    mo_view->_generic( name = `bwipjs`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `bcid`   v = bcid )
                                ( n = `text`   v = text )
                                ( n = `scale`  v = scale )
                                ( n = `height` v = height )
              ) ).

  ENDMETHOD.


  METHOD camera_picture.

    result = mo_view.
    mo_view->_generic( name = `CameraPicture`
              ns            = `z2ui5`
              t_prop        = VALUE #(
                ( n = `id`       v = id )
                ( n = `value`    v = value )
                ( n = `press`    v = press )
                ( n = `OnPhoto`    v = onphoto )
                ( n = `autoplay` v = z2ui5_cl_util=>boolean_abap_2_json( autoplay ) )
       ) ).

  ENDMETHOD.


  METHOD chartjs.
    result = mo_view.
    mo_view->_generic( name   = `chartjs`
                       ns     = `z2ui5`
                       t_prop = VALUE #( ( n = `canvas_id`  v = canvas_id )
                                         ( n = `view`       v = view )
                                         ( n = `config`     v = config )
                                         ( n = `height`     v = height )
                                         ( n = `width`      v = width )
                                         ( n = `style`      v = style )
                                       ) ).
  ENDMETHOD.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD demo_output.
    DATA lv_style TYPE string.

    "make it run without syntax error also when CC are deleted (for example for downports))
    mo_view->_generic( ns   = `html`
                       name = `style` ).

    CALL METHOD ('Z2UI5_CL_CC_DEMO_OUTPUT')=>('GET_STYLE')
      RECEIVING
        result = lv_style.
    result = mo_view->_cc_plain_xml( lv_style )->html( val ).

  ENDMETHOD.


  METHOD favicon.

    result = mo_view.
    mo_view->_generic( name = `Favicon`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `favicon`  v = favicon ) ) ).

  ENDMETHOD.


  METHOD file_uploader.

    result = mo_view.
    mo_view->_generic( name = `FileUploader`
              ns            = `z2ui5`
              t_prop        = VALUE #( (  n = `placeholder`        v = placeholder )
                                (  n = `upload`             v = upload )
                                (  n = `path`               v = path )
                                (  n = `value`              v = value )
                                (  n = `iconOnly`           v = z2ui5_cl_util=>boolean_abap_2_json( icononly ) )
                                (  n = `buttonOnly`         v = z2ui5_cl_util=>boolean_abap_2_json( buttononly ) )
                                (  n = `buttonText`         v = buttontext )
                                (  n = `uploadButtonText`   v = uploadbuttontext )
                                (  n = `fileType`           v = filetype )
                                (  n = `checkDirectUpload`  v = z2ui5_cl_util=>boolean_abap_2_json( checkdirectupload ) ) ) ).


  ENDMETHOD.


  METHOD focus.

    result = mo_view.
    mo_view->_generic( name = `Focus`
              ns            = `z2ui5`
              t_prop        = VALUE #(
                ( n = `setUpdate`       v = setupdate )
                ( n = `selectionStart`  v = selectionstart )
                ( n = `selectionEnd`    v = selectionend )
                ( n = `focusId`         v = focusid )
       ) ).

  ENDMETHOD.


  METHOD geolocation.

    result = mo_view.
    mo_view->_generic( name = `Geolocation`
              ns            = `z2ui5`
              t_prop        = VALUE #(
                    ( n = `finished`  v = finished )
                    ( n = `longitude`  v = longitude )
                    ( n = `latitude`  v = latitude )
                    ( n = `altitude`  v = altitude )
                    ( n = `accuracy`  v = accuracy )
                    ( n = `altitudeAccuracy`  v = altitudeaccuracy )
                    ( n = `speed`  v = speed )
                    ( n = `heading`  v = heading )
                    ( n = `enableHighAccuracy`  v = z2ui5_cl_util=>boolean_abap_2_json( enablehighaccuracy ) )
                    ( n = `timeout`  v = timeout )
              ) ).

  ENDMETHOD.


  METHOD history.

    result = mo_view.
    mo_view->_generic( name = `History`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `search`  v = search ) ) ).

  ENDMETHOD.


  METHOD info_frontend.

    result = mo_view.
    mo_view->_generic( name = `Info`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `ui5_version`  v = ui5_version )
                                ( n = `ui5_gav`  v = ui5_gav )
                                ( n = `finished`  v = finished )
                                ( n = `ui5_theme`  v = ui5_theme )
                                ( n = `device_os`  v = device_os )
                                ( n = `device_systemtype`  v = device_systemtype )
                                ( n = `device_browser`  v = device_browser )
              ) ).

  ENDMETHOD.


  METHOD messaging.

    result = mo_view.
    mo_view->_generic( name = `Messaging`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `items`  v = items )
              ) ).

  ENDMETHOD.


  METHOD multiinput.

    result = mo_view.
    mo_view->_generic( name   = `MultiInput`
                       ns     = `z2ui5`
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
                                         ( n = `addedTokens` v = addedtokens )
                                         ( n = `removedTokens` v = removedtokens )
                                         ( n = `class` v = class ) ) ).
  ENDMETHOD.


  METHOD multiinput_ext.

    result = mo_view.
    mo_view->_generic( name   = `MultiInputExt`
                       ns     = `z2ui5`
                       t_prop = VALUE #( ( n = `MultiInputId` v = multiinputid )
                                         ( n = `change` v = change )
                                         ( n = `addedTokens` v = addedtokens )
                                         ( n = `removedTokens` v = removedtokens ) ) ).

  ENDMETHOD.


  METHOD scrolling.

    result = mo_view.
    mo_view->_generic( name = `Scrolling`
              ns            = `z2ui5`
              t_prop        = VALUE #(
                ( n = `setUpdate`   v = setupdate )
                ( n = `items`       v = items )
       ) ).

  ENDMETHOD.


  METHOD spreadsheet_export.

    result = mo_view.
    mo_view->_generic( name = `ExportSpreadsheet`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `tableId`  v = tableid )
                                ( n = `text`     v = text )
                                ( n = `icon`     v = icon )
                                ( n = `type`     v = type )
              ) ).

  ENDMETHOD.


  METHOD timer.

    result = mo_view.
    mo_view->_generic( name = `Timer`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `delayMS`  v = delayms )
                                ( n = `finished`  v = finished )
                                ( n = `checkActive`  v = z2ui5_cl_util=>boolean_abap_2_json( checkactive ) )
                                ( n = `checkRepeat`  v = z2ui5_cl_util=>boolean_abap_2_json( checkrepeat ) )
              ) ).

  ENDMETHOD.


  METHOD title.

    result = mo_view.
    mo_view->_generic( name = `Title`
              ns            = `z2ui5`
              t_prop        = VALUE #( ( n = `title`  v = title ) ) ).

  ENDMETHOD.


  METHOD uitableext.

    result = mo_view->_generic( name = `UITableExt`
                                ns   = `z2ui5`
                       t_prop        = VALUE #( ( n = `tableId` v = tableid )
                        ) ).

  ENDMETHOD.
ENDCLASS.
