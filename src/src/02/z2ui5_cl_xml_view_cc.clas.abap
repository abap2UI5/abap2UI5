CLASS z2ui5_cl_xml_view_cc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS smartmultiinput_ext
      IMPORTING
        multiinputid  TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        rangeData     TYPE clike OPTIONAL
        addedtokens   TYPE clike OPTIONAL
        removedtokens TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS multiinput_ext
      IMPORTING
        multiinputid   TYPE clike OPTIONAL
        multiinputname TYPE clike OPTIONAL
        change         TYPE clike OPTIONAL
        addedtokens    TYPE clike OPTIONAL
        removedtokens  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS uitableext
      IMPORTING
        tableid       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS camera_picture
      IMPORTING
        id            TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        autoplay      TYPE clike OPTIONAL
        onphoto       TYPE clike OPTIONAL
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
          PREFERRED PARAMETER focusid
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS geolocation
      IMPORTING
        finished           TYPE clike OPTIONAL
        longitude          TYPE any   OPTIONAL
        latitude           TYPE any   OPTIONAL
        altitude           TYPE any   OPTIONAL
        accuracy           TYPE any   OPTIONAL
        altitudeaccuracy   TYPE any   OPTIONAL
        speed              TYPE any   OPTIONAL
        heading            TYPE any   OPTIONAL
        enablehighaccuracy TYPE any   OPTIONAL
        timeout            TYPE any   OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

    METHODS info_frontend
      IMPORTING
        finished          TYPE clike OPTIONAL
        ui5_version       TYPE clike OPTIONAL
        device_height     TYPE clike OPTIONAL
        device_width      TYPE clike OPTIONAL
        device_phone      TYPE clike OPTIONAL
        device_desktop    TYPE clike OPTIONAL
        device_tablet     TYPE clike OPTIONAL
        device_combi      TYPE clike OPTIONAL
        ui5_gav           TYPE clike OPTIONAL
        ui5_theme         TYPE clike OPTIONAL
        device_os         TYPE clike OPTIONAL
        device_systemtype TYPE clike OPTIONAL
        device_browser    TYPE clike OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    METHODS spreadsheet_export
      IMPORTING
        tableid       TYPE clike
        type          TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
        columnconfig  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS file_uploader
      IMPORTING
        value             TYPE clike OPTIONAL
        path              TYPE clike OPTIONAL
        placeholder       TYPE clike OPTIONAL
        upload            TYPE clike OPTIONAL
        icononly          TYPE clike OPTIONAL
        buttononly        TYPE clike OPTIONAL
        buttontext        TYPE clike OPTIONAL
        uploadbuttontext  TYPE clike OPTIONAL
        checkdirectupload TYPE clike OPTIONAL
        filetype          TYPE clike OPTIONAL
        icon              TYPE clike OPTIONAL
        enabled           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    METHODS messaging
      IMPORTING
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_manager
      IMPORTING
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS title
      IMPORTING
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS dirty
      IMPORTING
        isdirty       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS lp_title
      IMPORTING
        title                TYPE clike OPTIONAL
        ApplicationFullWidth TYPE clike OPTIONAL
        PREFERRED PARAMETER title
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS history
      IMPORTING
        search        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS scrolling
      IMPORTING
        setupdate     TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS tree
      IMPORTING
        tree_id       TYPE clike OPTIONAL
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

    METHODS websocket
      IMPORTING
        value         TYPE clike OPTIONAL
        received      TYPE clike OPTIONAL
        path          TYPE clike OPTIONAL
        checkrepeat   TYPE clike OPTIONAL
        checkactive   TYPE clike OPTIONAL
          PREFERRED PARAMETER received
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS binding_update
      IMPORTING
        changed       TYPE clike OPTIONAL
        path          TYPE clike OPTIONAL
          PREFERRED PARAMETER changed
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS chartjs
      IMPORTING
        canvas_id     TYPE clike OPTIONAL
        view          TYPE clike OPTIONAL
        config        TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        style         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS favicon
      IMPORTING
        favicon       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS approve_popover
      IMPORTING
        placement     TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        btn_txt       TYPE clike OPTIONAL
        btn_type      TYPE clike OPTIONAL
        btn_icon      TYPE clike OPTIONAL
        btn_event     TYPE clike OPTIONAL
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

  METHOD approve_popover.

    result = mo_view.

    mo_view->popover( showheader = abap_false
                      placement  = placement
                      class      = class )->hbox( justifycontent = `Center`
      )->vbox( justifycontent = `Center`
               alignitems     = `Center`
        )->text( text
        )->button( type  = btn_type
                   text  = btn_txt
                   icon  = btn_icon
                   press = btn_event ).

  ENDMETHOD.

  METHOD bwip_js.
    DATA temp1 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.

    result = mo_view.
    
    CLEAR temp1.
    
    temp2-n = `bcid`.
    temp2-v = bcid.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `text`.
    temp2-v = text.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `scale`.
    temp2-v = scale.
    INSERT temp2 INTO TABLE temp1.
    temp2-n = `height`.
    temp2-v = height.
    INSERT temp2 INTO TABLE temp1.
    mo_view->_generic( name   = `bwipjs`
                       ns     = `z2ui5`
                       t_prop = temp1 ).

  ENDMETHOD.

  METHOD camera_picture.
    DATA temp3 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp4 LIKE LINE OF temp3.

    result = mo_view.
    
    CLEAR temp3.
    
    temp4-n = `id`.
    temp4-v = id.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `value`.
    temp4-v = value.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `press`.
    temp4-v = press.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `OnPhoto`.
    temp4-v = onphoto.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `autoplay`.
    temp4-v = z2ui5_cl_util=>boolean_abap_2_json( autoplay ).
    INSERT temp4 INTO TABLE temp3.
    mo_view->_generic( name   = `CameraPicture`
                       ns     = `z2ui5`
                       t_prop = temp3 ).

  ENDMETHOD.

  METHOD chartjs.
    DATA temp5 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp6 LIKE LINE OF temp5.

    result = mo_view.
    
    CLEAR temp5.
    
    temp6-n = `canvas_id`.
    temp6-v = canvas_id.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `view`.
    temp6-v = view.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `config`.
    temp6-v = config.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `height`.
    temp6-v = height.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `width`.
    temp6-v = width.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `style`.
    temp6-v = style.
    INSERT temp6 INTO TABLE temp5.
    mo_view->_generic( name   = `chartjs`
                       ns     = `z2ui5`
                       t_prop = temp5 ).
  ENDMETHOD.

  METHOD constructor.

    mo_view = view.

  ENDMETHOD.

  METHOD demo_output.

    DATA lv_style TYPE string.
    DATA lv_class TYPE c LENGTH 20.

    mo_view->_generic( ns   = `html`
                       name = `style` ).

    
    lv_class = 'Z2UI5_CL_CC_DEMO_OUT'.
    CALL METHOD (lv_class)=>('GET_STYLE')
      RECEIVING
        result = lv_style.
    result = mo_view->_cc_plain_xml( lv_style )->html( val ).

  ENDMETHOD.

  METHOD favicon.
    DATA temp7 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp8 LIKE LINE OF temp7.

    result = mo_view.
    
    CLEAR temp7.
    
    temp8-n = `favicon`.
    temp8-v = favicon.
    INSERT temp8 INTO TABLE temp7.
    mo_view->_generic( name   = `Favicon`
                       ns     = `z2ui5`
                       t_prop = temp7 ).

  ENDMETHOD.

  METHOD file_uploader.
    DATA temp9 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp10 LIKE LINE OF temp9.

    result = mo_view.
    
    CLEAR temp9.
    
    temp10-n = `placeholder`.
    temp10-v = placeholder.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `upload`.
    temp10-v = upload.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `path`.
    temp10-v = path.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `value`.
    temp10-v = value.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `iconOnly`.
    temp10-v = z2ui5_cl_util=>boolean_abap_2_json( icononly ).
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `buttonOnly`.
    temp10-v = z2ui5_cl_util=>boolean_abap_2_json( buttononly ).
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `buttonText`.
    temp10-v = buttontext.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `uploadButtonText`.
    temp10-v = uploadbuttontext.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `fileType`.
    temp10-v = filetype.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `checkDirectUpload`.
    temp10-v = z2ui5_cl_util=>boolean_abap_2_json( checkdirectupload ).
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `icon`.
    temp10-v = icon.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `enabled`.
    temp10-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp10 INTO TABLE temp9.
    mo_view->_generic(
        name   = `FileUploader`
        ns     = `z2ui5`
        t_prop = temp9 ).

  ENDMETHOD.

  METHOD focus.
    DATA temp11 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp12 LIKE LINE OF temp11.

    result = mo_view.
    
    CLEAR temp11.
    
    temp12-n = `setUpdate`.
    temp12-v = setupdate.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `selectionStart`.
    temp12-v = selectionstart.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `selectionEnd`.
    temp12-v = selectionend.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `focusId`.
    temp12-v = focusid.
    INSERT temp12 INTO TABLE temp11.
    mo_view->_generic( name   = `Focus`
                       ns     = `z2ui5`
                       t_prop = temp11 ).

  ENDMETHOD.

  METHOD geolocation.
    DATA temp13 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp14 LIKE LINE OF temp13.

    result = mo_view.
    
    CLEAR temp13.
    
    temp14-n = `finished`.
    temp14-v = finished.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `longitude`.
    temp14-v = longitude.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `latitude`.
    temp14-v = latitude.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `altitude`.
    temp14-v = altitude.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `accuracy`.
    temp14-v = accuracy.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `altitudeAccuracy`.
    temp14-v = altitudeaccuracy.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `speed`.
    temp14-v = speed.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `heading`.
    temp14-v = heading.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `enableHighAccuracy`.
    temp14-v = z2ui5_cl_util=>boolean_abap_2_json( enablehighaccuracy ).
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `timeout`.
    temp14-v = timeout.
    INSERT temp14 INTO TABLE temp13.
    mo_view->_generic( name   = `Geolocation`
                       ns     = `z2ui5`
                       t_prop = temp13 ).

  ENDMETHOD.

  METHOD history.
    DATA temp15 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp16 LIKE LINE OF temp15.

    result = mo_view.
    
    CLEAR temp15.
    
    temp16-n = `search`.
    temp16-v = search.
    INSERT temp16 INTO TABLE temp15.
    mo_view->_generic( name   = `History`
                       ns     = `z2ui5`
                       t_prop = temp15 ).

  ENDMETHOD.

  METHOD info_frontend.
    DATA temp17 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp18 LIKE LINE OF temp17.

    result = mo_view.
    
    CLEAR temp17.
    
    temp18-n = `ui5_version`.
    temp18-v = ui5_version.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `ui5_gav`.
    temp18-v = ui5_gav.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `finished`.
    temp18-v = finished.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `ui5_theme`.
    temp18-v = ui5_theme.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_os`.
    temp18-v = device_os.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_systemtype`.
    temp18-v = device_systemtype.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_browser`.
    temp18-v = device_browser.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_phone`.
    temp18-v = device_phone.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_desktop`.
    temp18-v = device_desktop.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_tablet`.
    temp18-v = device_tablet.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_combi`.
    temp18-v = device_combi.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_height`.
    temp18-v = device_height.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `device_width`.
    temp18-v = device_width.
    INSERT temp18 INTO TABLE temp17.
    mo_view->_generic( name   = `Info`
                       ns     = `z2ui5`
                       t_prop = temp17
               ).

  ENDMETHOD.

  METHOD message_manager.
    DATA temp19 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp20 LIKE LINE OF temp19.

    result = mo_view.
    
    CLEAR temp19.
    
    temp20-n = `items`.
    temp20-v = items.
    INSERT temp20 INTO TABLE temp19.
    mo_view->_generic( name   = `MessageManager`
                       ns     = `z2ui5`
                       t_prop = temp19 ).

  ENDMETHOD.

  METHOD messaging.
    DATA temp21 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp22 LIKE LINE OF temp21.

    result = mo_view.
    
    CLEAR temp21.
    
    temp22-n = `items`.
    temp22-v = items.
    INSERT temp22 INTO TABLE temp21.
    mo_view->_generic( name   = `Messaging`
                       ns     = `z2ui5`
                       t_prop = temp21 ).

  ENDMETHOD.

  METHOD multiinput_ext.
    DATA temp23 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp24 LIKE LINE OF temp23.

    result = mo_view.
    
    CLEAR temp23.
    
    temp24-n = `MultiInputId`.
    temp24-v = multiinputid.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `MultiInputName`.
    temp24-v = multiinputname.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `change`.
    temp24-v = change.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `addedTokens`.
    temp24-v = addedtokens.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `removedTokens`.
    temp24-v = removedtokens.
    INSERT temp24 INTO TABLE temp23.
    mo_view->_generic( name   = `MultiInputExt`
                       ns     = `z2ui5`
                       t_prop = temp23 ).

  ENDMETHOD.

  METHOD tree.
    DATA temp25 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.

    result = mo_view.
    
    CLEAR temp25.
    
    temp26-n = `tree_id`.
    temp26-v = tree_id.
    INSERT temp26 INTO TABLE temp25.
    mo_view->_generic( name   = `Tree`
                       ns     = `z2ui5`
                       t_prop = temp25 ).

  ENDMETHOD.

  METHOD scrolling.
    DATA temp27 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp28 LIKE LINE OF temp27.

    result = mo_view.
    
    CLEAR temp27.
    
    temp28-n = `setUpdate`.
    temp28-v = setupdate.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `items`.
    temp28-v = items.
    INSERT temp28 INTO TABLE temp27.
    mo_view->_generic( name   = `Scrolling`
                       ns     = `z2ui5`
                       t_prop = temp27 ).

  ENDMETHOD.

  METHOD spreadsheet_export.
    DATA temp29 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp30 LIKE LINE OF temp29.

    result = mo_view.
    
    CLEAR temp29.
    
    temp30-n = `tableId`.
    temp30-v = tableid.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `text`.
    temp30-v = text.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `icon`.
    temp30-v = icon.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `type`.
    temp30-v = type.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `tooltip`.
    temp30-v = tooltip.
    INSERT temp30 INTO TABLE temp29.
    temp30-n = `columnconfig`.
    temp30-v = columnconfig.
    INSERT temp30 INTO TABLE temp29.
    mo_view->_generic( name   = `ExportSpreadsheet`
                       ns     = `z2ui5`
                       t_prop = temp29 ).

  ENDMETHOD.

  METHOD timer.
    DATA temp31 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp32 LIKE LINE OF temp31.

    result = mo_view.
    
    CLEAR temp31.
    
    temp32-n = `delayMS`.
    temp32-v = delayms.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `finished`.
    temp32-v = finished.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `checkActive`.
    temp32-v = z2ui5_cl_util=>boolean_abap_2_json( checkactive ).
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `checkRepeat`.
    temp32-v = z2ui5_cl_util=>boolean_abap_2_json( checkrepeat ).
    INSERT temp32 INTO TABLE temp31.
    mo_view->_generic( name   = `Timer`
                       ns     = `z2ui5`
                       t_prop = temp31 ).

  ENDMETHOD.

  METHOD binding_update.
    DATA temp33 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp34 LIKE LINE OF temp33.

    result = mo_view.
    
    CLEAR temp33.
    
    temp34-n = `path`.
    temp34-v = path.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `changed`.
    temp34-v = changed.
    INSERT temp34 INTO TABLE temp33.
    mo_view->_generic( name   = `BindingUpdate`
                       ns     = `z2ui5`
                       t_prop = temp33 ).

  ENDMETHOD.

  METHOD websocket.
    DATA temp35 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp36 LIKE LINE OF temp35.

    result = mo_view.
    
    CLEAR temp35.
    
    temp36-n = `value`.
    temp36-v = value.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `path`.
    temp36-v = path.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `received`.
    temp36-v = received.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `checkActive`.
    temp36-v = z2ui5_cl_util=>boolean_abap_2_json( checkactive ).
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `checkRepeat`.
    temp36-v = z2ui5_cl_util=>boolean_abap_2_json( checkrepeat ).
    INSERT temp36 INTO TABLE temp35.
    mo_view->_generic( name   = `Websocket`
                       ns     = `z2ui5`
                       t_prop = temp35 ).

  ENDMETHOD.

  METHOD lp_title.
    DATA temp37 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp38 LIKE LINE OF temp37.

    result = mo_view.
    
    CLEAR temp37.
    
    temp38-n = `title`.
    temp38-v = title.
    INSERT temp38 INTO TABLE temp37.
    temp38-n = `ApplicationFullWidth`.
    temp38-v = z2ui5_cl_util=>boolean_abap_2_json( ApplicationFullWidth ).
    INSERT temp38 INTO TABLE temp37.
    mo_view->_generic( name   = `LPTitle`
                       ns     = `z2ui5`
                       t_prop = temp37
                         ).

  ENDMETHOD.

  METHOD title.
    DATA temp39 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp40 LIKE LINE OF temp39.

    result = mo_view.
    
    CLEAR temp39.
    
    temp40-n = `title`.
    temp40-v = title.
    INSERT temp40 INTO TABLE temp39.
    mo_view->_generic( name   = `Title`
                       ns     = `z2ui5`
                       t_prop = temp39 ).

  ENDMETHOD.

  METHOD dirty.
    DATA temp41 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp42 LIKE LINE OF temp41.

    result = mo_view.
    
    CLEAR temp41.
    
    temp42-n = `isDirty`.
    temp42-v = z2ui5_cl_util=>boolean_abap_2_json( isdirty ).
    INSERT temp42 INTO TABLE temp41.
    mo_view->_generic( name   = `Dirty`
                       ns     = `z2ui5`
                       t_prop = temp41 ).

  ENDMETHOD.

  METHOD uitableext.

    DATA temp43 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp44 LIKE LINE OF temp43.
    CLEAR temp43.
    
    temp44-n = `tableId`.
    temp44-v = tableid.
    INSERT temp44 INTO TABLE temp43.
    result = mo_view->_generic( name   = `UITableExt`
                                ns     = `z2ui5`
                                t_prop = temp43 ).

  ENDMETHOD.

  METHOD smartmultiinput_ext.
    DATA temp45 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp46 LIKE LINE OF temp45.

    result = mo_view.
    
    CLEAR temp45.
    
    temp46-n = `multiInputId`.
    temp46-v = multiInputId.
    INSERT temp46 INTO TABLE temp45.
    temp46-n = `rangeData`.
    temp46-v = rangeData.
    INSERT temp46 INTO TABLE temp45.
    temp46-n = `change`.
    temp46-v = change.
    INSERT temp46 INTO TABLE temp45.
    temp46-n = `addedTokens`.
    temp46-v = addedTokens.
    INSERT temp46 INTO TABLE temp45.
    temp46-n = `removedTokens`.
    temp46-v = removedTokens.
    INSERT temp46 INTO TABLE temp45.
    mo_view->_generic( name   = `SmartMultiInputExt`
                       ns     = `z2ui5`
                       t_prop = temp45 ).

  ENDMETHOD.

ENDCLASS.
