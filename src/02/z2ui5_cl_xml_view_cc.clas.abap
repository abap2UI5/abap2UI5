CLASS z2ui5_cl_xml_view_cc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS smartmultiinput_ext
      IMPORTING
        multiinputid  TYPE clike OPTIONAL
        change        TYPE clike OPTIONAL
        rangedata     TYPE clike OPTIONAL
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
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        autoplay      TYPE clike OPTIONAL
        onphoto       TYPE clike OPTIONAL
        facingmode    TYPE clike OPTIONAL
        deviceid      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS camera_selector
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
        applicationfullwidth TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)        TYPE REF TO z2ui5_cl_xml_view.

    METHODS storage
      IMPORTING
        finished      TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        prefix        TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        value         TYPE any   OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
    temp4-n = `height`.
    temp4-v = height.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `width`.
    temp4-v = width.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `OnPhoto`.
    temp4-v = onphoto.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `autoplay`.
    temp4-v = z2ui5_cl_util=>boolean_abap_2_json( autoplay ).
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `facingMode`.
    temp4-v = facingmode.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `deviceId`.
    temp4-v = deviceid.
    INSERT temp4 INTO TABLE temp3.
    mo_view->_generic( name   = `CameraPicture`
                       ns     = `z2ui5`
                       t_prop = temp3 ).

  ENDMETHOD.

  METHOD camera_selector.
    DATA temp5 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp6 LIKE LINE OF temp5.

    result = mo_view.
    
    CLEAR temp5.
    
    temp6-n = `showClearIcon`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( showclearicon ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `selectedKey`.
    temp6-v = selectedkey.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `items`.
    temp6-v = items.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `id`.
    temp6-v = id.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `class`.
    temp6-v = class.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `selectionchange`.
    temp6-v = selectionchange.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `selectedItem`.
    temp6-v = selecteditem.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `selectedItemId`.
    temp6-v = selecteditemid.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `name`.
    temp6-v = name.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `value`.
    temp6-v = value.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `valueState`.
    temp6-v = valuestate.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `valueStateText`.
    temp6-v = valuestatetext.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `textAlign`.
    temp6-v = textalign.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `showSecondaryValues`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( showsecondaryvalues ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `visible`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( visible ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `showValueStateMessage`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( showvaluestatemessage ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `showButton`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( showbutton ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `required`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( required ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `editable`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( editable ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `enabled`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `filterSecondaryValues`.
    temp6-v = z2ui5_cl_util=>boolean_abap_2_json( filtersecondaryvalues ).
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `width`.
    temp6-v = width.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `placeholder`.
    temp6-v = placeholder.
    INSERT temp6 INTO TABLE temp5.
    temp6-n = `change`.
    temp6-v = change.
    INSERT temp6 INTO TABLE temp5.
    mo_view->_generic(
        name   = `CameraSelector`
        ns     = `z2ui5`
        t_prop = temp5 ).

  ENDMETHOD.

  METHOD chartjs.
    DATA temp7 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp8 LIKE LINE OF temp7.

    result = mo_view.
    
    CLEAR temp7.
    
    temp8-n = `canvas_id`.
    temp8-v = canvas_id.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `view`.
    temp8-v = view.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `config`.
    temp8-v = config.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `height`.
    temp8-v = height.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `width`.
    temp8-v = width.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `style`.
    temp8-v = style.
    INSERT temp8 INTO TABLE temp7.
    mo_view->_generic( name   = `chartjs`
                       ns     = `z2ui5`
                       t_prop = temp7 ).
  ENDMETHOD.

  METHOD constructor.

    mo_view = view.

  ENDMETHOD.

  METHOD demo_output.

    DATA lv_style TYPE string.
    DATA lv_class TYPE string.

    mo_view->_generic( ns   = `html`
                       name = `style` ).

    
    lv_class = `Z2UI5_CL_CC_DEMO_OUT`.
    CALL METHOD (lv_class)=>(`GET_STYLE`)
      RECEIVING result = lv_style.
    result = mo_view->_cc_plain_xml( lv_style )->html( val ).

  ENDMETHOD.

  METHOD favicon.
    DATA temp9 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp10 LIKE LINE OF temp9.

    result = mo_view.
    
    CLEAR temp9.
    
    temp10-n = `favicon`.
    temp10-v = favicon.
    INSERT temp10 INTO TABLE temp9.
    mo_view->_generic( name   = `Favicon`
                       ns     = `z2ui5`
                       t_prop = temp9 ).

  ENDMETHOD.

  METHOD file_uploader.
    DATA temp11 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp12 LIKE LINE OF temp11.

    result = mo_view.
    
    CLEAR temp11.
    
    temp12-n = `placeholder`.
    temp12-v = placeholder.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `upload`.
    temp12-v = upload.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `path`.
    temp12-v = path.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `value`.
    temp12-v = value.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `iconOnly`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( icononly ).
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `buttonOnly`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( buttononly ).
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `buttonText`.
    temp12-v = buttontext.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `uploadButtonText`.
    temp12-v = uploadbuttontext.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `fileType`.
    temp12-v = filetype.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `checkDirectUpload`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( checkdirectupload ).
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `icon`.
    temp12-v = icon.
    INSERT temp12 INTO TABLE temp11.
    temp12-n = `enabled`.
    temp12-v = z2ui5_cl_util=>boolean_abap_2_json( enabled ).
    INSERT temp12 INTO TABLE temp11.
    mo_view->_generic(
        name   = `FileUploader`
        ns     = `z2ui5`
        t_prop = temp11 ).

  ENDMETHOD.

  METHOD focus.
    DATA temp13 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp14 LIKE LINE OF temp13.

    result = mo_view.
    
    CLEAR temp13.
    
    temp14-n = `setUpdate`.
    temp14-v = setupdate.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `selectionStart`.
    temp14-v = selectionstart.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `selectionEnd`.
    temp14-v = selectionend.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `focusId`.
    temp14-v = focusid.
    INSERT temp14 INTO TABLE temp13.
    mo_view->_generic( name   = `Focus`
                       ns     = `z2ui5`
                       t_prop = temp13 ).

  ENDMETHOD.

  METHOD geolocation.
    DATA temp15 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp16 LIKE LINE OF temp15.

    result = mo_view.
    
    CLEAR temp15.
    
    temp16-n = `finished`.
    temp16-v = finished.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `longitude`.
    temp16-v = longitude.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `latitude`.
    temp16-v = latitude.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `altitude`.
    temp16-v = altitude.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `accuracy`.
    temp16-v = accuracy.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `altitudeAccuracy`.
    temp16-v = altitudeaccuracy.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `speed`.
    temp16-v = speed.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `heading`.
    temp16-v = heading.
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `enableHighAccuracy`.
    temp16-v = z2ui5_cl_util=>boolean_abap_2_json( enablehighaccuracy ).
    INSERT temp16 INTO TABLE temp15.
    temp16-n = `timeout`.
    temp16-v = timeout.
    INSERT temp16 INTO TABLE temp15.
    mo_view->_generic( name   = `Geolocation`
                       ns     = `z2ui5`
                       t_prop = temp15 ).

  ENDMETHOD.

  METHOD storage.
    DATA temp17 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp18 LIKE LINE OF temp17.
    result = mo_view.
    
    CLEAR temp17.
    
    temp18-n = `finished`.
    temp18-v = finished.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `type`.
    temp18-v = type.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `prefix`.
    temp18-v = prefix.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `key`.
    temp18-v = key.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `value`.
    temp18-v = value.
    INSERT temp18 INTO TABLE temp17.
    mo_view->_generic( name   = `Storage`
                       ns     = `z2ui5`
                       t_prop = temp17 ).
  ENDMETHOD.

  METHOD history.
    DATA temp19 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp20 LIKE LINE OF temp19.

    result = mo_view.
    
    CLEAR temp19.
    
    temp20-n = `search`.
    temp20-v = search.
    INSERT temp20 INTO TABLE temp19.
    mo_view->_generic( name   = `History`
                       ns     = `z2ui5`
                       t_prop = temp19 ).

  ENDMETHOD.

  METHOD info_frontend.
    DATA temp21 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp22 LIKE LINE OF temp21.

    result = mo_view.
    
    CLEAR temp21.
    
    temp22-n = `ui5_version`.
    temp22-v = ui5_version.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `ui5_gav`.
    temp22-v = ui5_gav.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `finished`.
    temp22-v = finished.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `ui5_theme`.
    temp22-v = ui5_theme.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_os`.
    temp22-v = device_os.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_systemtype`.
    temp22-v = device_systemtype.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_browser`.
    temp22-v = device_browser.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_phone`.
    temp22-v = device_phone.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_desktop`.
    temp22-v = device_desktop.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_tablet`.
    temp22-v = device_tablet.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_combi`.
    temp22-v = device_combi.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_height`.
    temp22-v = device_height.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `device_width`.
    temp22-v = device_width.
    INSERT temp22 INTO TABLE temp21.
    mo_view->_generic( name   = `Info`
                       ns     = `z2ui5`
                       t_prop = temp21 ).

  ENDMETHOD.

  METHOD message_manager.
    DATA temp23 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp24 LIKE LINE OF temp23.

    result = mo_view.
    
    CLEAR temp23.
    
    temp24-n = `items`.
    temp24-v = items.
    INSERT temp24 INTO TABLE temp23.
    mo_view->_generic( name   = `MessageManager`
                       ns     = `z2ui5`
                       t_prop = temp23 ).

  ENDMETHOD.

  METHOD messaging.
    DATA temp25 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.

    result = mo_view.
    
    CLEAR temp25.
    
    temp26-n = `items`.
    temp26-v = items.
    INSERT temp26 INTO TABLE temp25.
    mo_view->_generic( name   = `Messaging`
                       ns     = `z2ui5`
                       t_prop = temp25 ).

  ENDMETHOD.

  METHOD multiinput_ext.
    DATA temp27 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp28 LIKE LINE OF temp27.

    result = mo_view.
    
    CLEAR temp27.
    
    temp28-n = `MultiInputId`.
    temp28-v = multiinputid.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `MultiInputName`.
    temp28-v = multiinputname.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `change`.
    temp28-v = change.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `addedTokens`.
    temp28-v = addedtokens.
    INSERT temp28 INTO TABLE temp27.
    temp28-n = `removedTokens`.
    temp28-v = removedtokens.
    INSERT temp28 INTO TABLE temp27.
    mo_view->_generic( name   = `MultiInputExt`
                       ns     = `z2ui5`
                       t_prop = temp27 ).

  ENDMETHOD.

  METHOD tree.
    DATA temp29 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp30 LIKE LINE OF temp29.

    result = mo_view.
    
    CLEAR temp29.
    
    temp30-n = `tree_id`.
    temp30-v = tree_id.
    INSERT temp30 INTO TABLE temp29.
    mo_view->_generic( name   = `Tree`
                       ns     = `z2ui5`
                       t_prop = temp29 ).

  ENDMETHOD.

  METHOD scrolling.
    DATA temp31 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp32 LIKE LINE OF temp31.

    result = mo_view.
    
    CLEAR temp31.
    
    temp32-n = `setUpdate`.
    temp32-v = setupdate.
    INSERT temp32 INTO TABLE temp31.
    temp32-n = `items`.
    temp32-v = items.
    INSERT temp32 INTO TABLE temp31.
    mo_view->_generic( name   = `Scrolling`
                       ns     = `z2ui5`
                       t_prop = temp31 ).

  ENDMETHOD.

  METHOD spreadsheet_export.
    DATA temp33 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp34 LIKE LINE OF temp33.

    result = mo_view.
    
    CLEAR temp33.
    
    temp34-n = `tableId`.
    temp34-v = tableid.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `text`.
    temp34-v = text.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `icon`.
    temp34-v = icon.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `type`.
    temp34-v = type.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `tooltip`.
    temp34-v = tooltip.
    INSERT temp34 INTO TABLE temp33.
    temp34-n = `columnconfig`.
    temp34-v = columnconfig.
    INSERT temp34 INTO TABLE temp33.
    mo_view->_generic( name   = `ExportSpreadsheet`
                       ns     = `z2ui5`
                       t_prop = temp33 ).

  ENDMETHOD.

  METHOD timer.
    DATA temp35 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp36 LIKE LINE OF temp35.

    result = mo_view.
    
    CLEAR temp35.
    
    temp36-n = `delayMS`.
    temp36-v = delayms.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `finished`.
    temp36-v = finished.
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `checkActive`.
    temp36-v = z2ui5_cl_util=>boolean_abap_2_json( checkactive ).
    INSERT temp36 INTO TABLE temp35.
    temp36-n = `checkRepeat`.
    temp36-v = z2ui5_cl_util=>boolean_abap_2_json( checkrepeat ).
    INSERT temp36 INTO TABLE temp35.
    mo_view->_generic( name   = `Timer`
                       ns     = `z2ui5`
                       t_prop = temp35 ).

  ENDMETHOD.

  METHOD binding_update.
    DATA temp37 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp38 LIKE LINE OF temp37.

    result = mo_view.
    
    CLEAR temp37.
    
    temp38-n = `path`.
    temp38-v = path.
    INSERT temp38 INTO TABLE temp37.
    temp38-n = `changed`.
    temp38-v = changed.
    INSERT temp38 INTO TABLE temp37.
    mo_view->_generic( name   = `BindingUpdate`
                       ns     = `z2ui5`
                       t_prop = temp37 ).

  ENDMETHOD.

  METHOD websocket.
    DATA temp39 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp40 LIKE LINE OF temp39.

    result = mo_view.
    
    CLEAR temp39.
    
    temp40-n = `value`.
    temp40-v = value.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `path`.
    temp40-v = path.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `received`.
    temp40-v = received.
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `checkActive`.
    temp40-v = z2ui5_cl_util=>boolean_abap_2_json( checkactive ).
    INSERT temp40 INTO TABLE temp39.
    temp40-n = `checkRepeat`.
    temp40-v = z2ui5_cl_util=>boolean_abap_2_json( checkrepeat ).
    INSERT temp40 INTO TABLE temp39.
    mo_view->_generic( name   = `Websocket`
                       ns     = `z2ui5`
                       t_prop = temp39 ).

  ENDMETHOD.

  METHOD lp_title.
    DATA temp41 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp42 LIKE LINE OF temp41.

    result = mo_view.
    
    CLEAR temp41.
    
    temp42-n = `title`.
    temp42-v = title.
    INSERT temp42 INTO TABLE temp41.
    temp42-n = `ApplicationFullWidth`.
    temp42-v = z2ui5_cl_util=>boolean_abap_2_json( applicationfullwidth ).
    INSERT temp42 INTO TABLE temp41.
    mo_view->_generic(
        name   = `LPTitle`
        ns     = `z2ui5`
        t_prop = temp41 ).

  ENDMETHOD.

  METHOD title.
    DATA temp43 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp44 LIKE LINE OF temp43.

    result = mo_view.
    
    CLEAR temp43.
    
    temp44-n = `title`.
    temp44-v = title.
    INSERT temp44 INTO TABLE temp43.
    mo_view->_generic( name   = `Title`
                       ns     = `z2ui5`
                       t_prop = temp43 ).

  ENDMETHOD.

  METHOD dirty.
    DATA temp45 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp46 LIKE LINE OF temp45.

    result = mo_view.
    
    CLEAR temp45.
    
    temp46-n = `isDirty`.
    temp46-v = z2ui5_cl_util=>boolean_abap_2_json( isdirty ).
    INSERT temp46 INTO TABLE temp45.
    mo_view->_generic( name   = `Dirty`
                       ns     = `z2ui5`
                       t_prop = temp45 ).

  ENDMETHOD.

  METHOD uitableext.

    DATA temp47 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp48 LIKE LINE OF temp47.
    CLEAR temp47.
    
    temp48-n = `tableId`.
    temp48-v = tableid.
    INSERT temp48 INTO TABLE temp47.
    result = mo_view->_generic( name   = `UITableExt`
                                ns     = `z2ui5`
                                t_prop = temp47 ).

  ENDMETHOD.

  METHOD smartmultiinput_ext.
    DATA temp49 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp50 LIKE LINE OF temp49.

    result = mo_view.
    
    CLEAR temp49.
    
    temp50-n = `multiInputId`.
    temp50-v = multiinputid.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `rangeData`.
    temp50-v = rangedata.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `change`.
    temp50-v = change.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `addedTokens`.
    temp50-v = addedtokens.
    INSERT temp50 INTO TABLE temp49.
    temp50-n = `removedTokens`.
    temp50-v = removedtokens.
    INSERT temp50 INTO TABLE temp49.
    mo_view->_generic( name   = `SmartMultiInputExt`
                       ns     = `z2ui5`
                       t_prop = temp49 ).

  ENDMETHOD.

ENDCLASS.
