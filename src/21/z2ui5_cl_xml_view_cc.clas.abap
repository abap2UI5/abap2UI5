CLASS z2ui5_cl_xml_view_cc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS camera_picture
      IMPORTING
        id            TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        autoplay      TYPE clike OPTIONAL
        OnPhoto       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS bwip_js
      IMPORTING
        bcid          TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        scale         TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS demo_output
      IMPORTING
        val           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS focus
      IMPORTING
        focusid        TYPE clike OPTIONAL
        selectionstart TYPE clike OPTIONAL
        selectionend   TYPE clike OPTIONAL
        setupdate      TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS geolocation
      IMPORTING
        finished           TYPE clike OPTIONAL
        longitude          TYPE any OPTIONAL
        latitude           TYPE any OPTIONAL
        altitude           TYPE any OPTIONAL
        accuracy           TYPE any OPTIONAL
        altitudeaccuracy   TYPE any OPTIONAL
        speed              TYPE any OPTIONAL
        heading            TYPE any OPTIONAL
        enablehighaccuracy TYPE any OPTIONAL
        timeout            TYPE any OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    METHODS info_frontend
      IMPORTING
        finished          TYPE clike OPTIONAL
        ui5_version       TYPE any OPTIONAL
        ui5_gav           TYPE any OPTIONAL
        ui5_theme         TYPE any OPTIONAL
        device_os         TYPE any OPTIONAL
        device_systemtype TYPE any OPTIONAL
        device_browser    TYPE any OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    METHODS spreadsheet_export
      IMPORTING
        tableid       TYPE clike
        type          TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
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
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    METHODS messaging
      IMPORTING
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS title
      IMPORTING
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS scroll
      IMPORTING
        setupdate     TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS timer
      IMPORTING
        finished      TYPE clike OPTIONAL
        delayms       TYPE clike OPTIONAL
        checkrepeat   TYPE clike OPTIONAL
        checkactive   TYPE clike OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_xml_view_cc IMPLEMENTATION.

method bwip_js.

    result = mo_view.
    mo_view->_generic( name   = `bwipjs`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `bcid`   v = bcid )
                                ( n = `text`   v = text )
                                ( n = `scale`  v = scale )
                                ( n = `height` v = height )
              ) ).

endmethod.

  METHOD spreadsheet_export.

    result = mo_view.
    mo_view->_generic( name   = `ExportSpreadsheet`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `tableId`  v = tableid )
                                ( n = `text`     v = text )
                                ( n = `icon`     v = icon )
                                ( n = `type`     v = type )
              ) ).

  ENDMETHOD.

  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD file_uploader.

    result = mo_view.
    mo_view->_generic( name   = `FileUploader`
              ns     = `z2ui5`
              t_prop = VALUE #( (  n = `placeholder`        v = placeholder )
                                (  n = `upload`             v = upload )
                                (  n = `path`               v = path )
                                (  n = `value`              v = value )
                                (  n = `iconOnly`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( icononly ) )
                                (  n = `buttonOnly`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( buttononly ) )
                                (  n = `buttonText`         v = buttontext )
                                (  n = `uploadButtonText`   v = uploadbuttontext )
                                (  n = `fileType`           v = filetype )
                                (  n = `checkDirectUpload`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkdirectupload ) ) ) ).


  ENDMETHOD.


  METHOD scroll.

    result = mo_view.
    mo_view->_generic( name   = `Scroll`
              ns     = `z2ui5`
              t_prop = VALUE #(
                ( n = `setUpdate`   v = setupdate )
                ( n = `items`       v = items )
       ) ).

  ENDMETHOD.


  METHOD timer.

    result = mo_view.
    mo_view->_generic( name   = `Timer`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `delayMS`  v = delayms )
                                ( n = `finished`  v = finished )
                                ( n = `checkActive`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkactive ) )
                                ( n = `checkRepeat`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkrepeat ) )
              ) ).

  ENDMETHOD.


  METHOD title.

    result = mo_view.
    mo_view->_generic( name   = `Title`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `title`  v = title ) ) ).

  ENDMETHOD.

  METHOD messaging.

    result = mo_view.
    mo_view->_generic( name   = `Messaging`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `items`  v = items )
              ) ).

  ENDMETHOD.

  METHOD info_frontend.

    result = mo_view.
    mo_view->_generic( name   = `Info`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `ui5_version`  v = ui5_version )
                                ( n = `ui5_gav`  v = ui5_gav )
                                ( n = `finished`  v = finished )
                                ( n = `ui5_theme`  v = ui5_theme )
                                ( n = `device_os`  v = device_os )
                                ( n = `device_systemtype`  v = device_systemtype )
                                ( n = `device_browser`  v = device_browser )
              ) ).

  ENDMETHOD.

  METHOD geolocation.

    result = mo_view.
    mo_view->_generic( name   = `Geolocation`
              ns     = `z2ui5`
              t_prop = VALUE #(
                    ( n = `finished`  v = finished )
                    ( n = `longitude`  v = longitude )
                    ( n = `latitude`  v = latitude )
                    ( n = `altitude`  v = altitude )
                    ( n = `accuracy`  v = accuracy )
                    ( n = `altitudeAccuracy`  v = altitudeaccuracy )
                    ( n = `speed`  v = speed )
                    ( n = `heading`  v = heading )
                    ( n = `enableHighAccuracy`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( enablehighaccuracy ) )
                    ( n = `timeout`  v = timeout )
              ) ).

  ENDMETHOD.

  METHOD focus.

    result = mo_view.
    mo_view->_generic( name   = `Focus`
              ns     = `z2ui5`
              t_prop = VALUE #(
                ( n = `setUpdate`       v = setupdate )
                ( n = `selectionStart`  v = selectionstart )
                ( n = `selectionEnd`    v = selectionend )
                ( n = `focusId`         v = focusid )
       ) ).

  ENDMETHOD.

  METHOD demo_output.

   result = mo_view->_cc_plain_xml( z2ui5_cl_cc_demo_output=>get_style( ) )->html( val ).

  ENDMETHOD.

  METHOD camera_picture.

    result = mo_view.
    mo_view->_generic( name   = `CameraPicture`
              ns     = `z2ui5`
              t_prop = VALUE #(
                ( n = `id`       v = id )
                ( n = `value`    v = value )
                ( n = `press`    v = press )
                ( n = `OnPhoto`    v = OnPhoto )
                ( n = `autoplay` v = z2ui5_cl_fw_utility=>boolean_abap_2_json( autoplay ) )
       ) ).

  ENDMETHOD.

ENDCLASS.
