CLASS ltcl_test_cc DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_constructor       FOR TESTING RAISING cx_static_check.
    METHODS test_timer             FOR TESTING RAISING cx_static_check.
    METHODS test_focus             FOR TESTING RAISING cx_static_check.
    METHODS test_camera_picture    FOR TESTING RAISING cx_static_check.
    METHODS test_bwip_js           FOR TESTING RAISING cx_static_check.
    METHODS test_geolocation       FOR TESTING RAISING cx_static_check.
    METHODS test_file_uploader     FOR TESTING RAISING cx_static_check.
    METHODS test_favicon           FOR TESTING RAISING cx_static_check.
    METHODS test_title             FOR TESTING RAISING cx_static_check.
    METHODS test_dirty             FOR TESTING RAISING cx_static_check.
    METHODS test_history           FOR TESTING RAISING cx_static_check.
    METHODS test_messaging         FOR TESTING RAISING cx_static_check.
    METHODS test_storage           FOR TESTING RAISING cx_static_check.
    METHODS test_info_frontend     FOR TESTING RAISING cx_static_check.
    METHODS test_lp_title          FOR TESTING RAISING cx_static_check.
    METHODS test_z2ui5_namespace     FOR TESTING RAISING cx_static_check.
    METHODS test_smartmultiinput_ext FOR TESTING RAISING cx_static_check.
    METHODS test_multiinput_ext      FOR TESTING RAISING cx_static_check.
    METHODS test_uitableext          FOR TESTING RAISING cx_static_check.
    METHODS test_camera_selector     FOR TESTING RAISING cx_static_check.
    METHODS test_spreadsheet_export  FOR TESTING RAISING cx_static_check.
    METHODS test_message_manager     FOR TESTING RAISING cx_static_check.
    METHODS test_scrolling           FOR TESTING RAISING cx_static_check.
    METHODS test_tree                FOR TESTING RAISING cx_static_check.
    METHODS test_websocket           FOR TESTING RAISING cx_static_check.
    METHODS test_binding_update      FOR TESTING RAISING cx_static_check.
    METHODS test_chartjs             FOR TESTING RAISING cx_static_check.
    METHODS test_approve_popover     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_cc IMPLEMENTATION.

  METHOD test_constructor.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    cl_abap_unit_assert=>assert_bound( lo_cc ).

  ENDMETHOD.

  METHOD test_timer.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->timer( finished          = `onTimerFinished`
                                    delayms     = `2000`
                                    checkrepeat = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_result ).


    lv_xml = lo_result->stringify( ).

    temp1 = xsdbool( lv_xml CS `Timer` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = xsdbool( lv_xml CS `z2ui5` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = xsdbool( lv_xml CS `2000` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_focus.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->focus( `myInput` ).


    lv_xml = lo_result->stringify( ).

    temp4 = xsdbool( lv_xml CS `Focus` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

    temp5 = xsdbool( lv_xml CS `myInput` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_camera_picture.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->camera_picture( id             = `cam1`
                                             press    = `onSnap`
                                             autoplay = abap_true ).


    lv_xml = lo_result->stringify( ).

    temp6 = xsdbool( lv_xml CS `CameraPicture` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

    temp7 = xsdbool( lv_xml CS `cam1` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD test_bwip_js.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->bwip_js( bcid         = `qrcode`
                                      text   = `Hello`
                                      scale  = `3`
                                      height = `10` ).


    lv_xml = lo_result->stringify( ).

    temp8 = xsdbool( lv_xml CS `bwipjs` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

    temp9 = xsdbool( lv_xml CS `qrcode` ).
    cl_abap_unit_assert=>assert_true( temp9 ).

  ENDMETHOD.

  METHOD test_geolocation.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->geolocation( finished        = `onGeoFinished`
                                          longitude = `{/LON}`
                                          latitude  = `{/LAT}` ).


    lv_xml = lo_result->stringify( ).

    temp10 = xsdbool( lv_xml CS `Geolocation` ).
    cl_abap_unit_assert=>assert_true( temp10 ).

    temp11 = xsdbool( lv_xml CS `{/LON}` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD test_file_uploader.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->file_uploader( placeholder      = `Choose file`
                                            upload     = `onUpload`
                                            buttontext = `Browse` ).


    lv_xml = lo_result->stringify( ).

    temp12 = xsdbool( lv_xml CS `FileUploader` ).
    cl_abap_unit_assert=>assert_true( temp12 ).

    temp13 = xsdbool( lv_xml CS `Choose file` ).
    cl_abap_unit_assert=>assert_true( temp13 ).

  ENDMETHOD.

  METHOD test_favicon.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->favicon( `icon.png` ).


    lv_xml = lo_result->stringify( ).

    temp14 = xsdbool( lv_xml CS `Favicon` ).
    cl_abap_unit_assert=>assert_true( temp14 ).

    temp15 = xsdbool( lv_xml CS `icon.png` ).
    cl_abap_unit_assert=>assert_true( temp15 ).

  ENDMETHOD.

  METHOD test_title.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->title( `My App` ).


    lv_xml = lo_result->stringify( ).

    temp16 = xsdbool( lv_xml CS `Title` ).
    cl_abap_unit_assert=>assert_true( temp16 ).

    temp17 = xsdbool( lv_xml CS `My App` ).
    cl_abap_unit_assert=>assert_true( temp17 ).

  ENDMETHOD.

  METHOD test_dirty.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp18 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->dirty( abap_true ).


    lv_xml = lo_result->stringify( ).

    temp18 = xsdbool( lv_xml CS `Dirty` ).
    cl_abap_unit_assert=>assert_true( temp18 ).

  ENDMETHOD.

  METHOD test_history.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp19 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->history( `{/SEARCH}` ).


    lv_xml = lo_result->stringify( ).

    temp19 = xsdbool( lv_xml CS `History` ).
    cl_abap_unit_assert=>assert_true( temp19 ).

  ENDMETHOD.

  METHOD test_messaging.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp20 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->messaging( `{/MESSAGES}` ).


    lv_xml = lo_result->stringify( ).

    temp20 = xsdbool( lv_xml CS `Messaging` ).
    cl_abap_unit_assert=>assert_true( temp20 ).

  ENDMETHOD.

  METHOD test_storage.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->storage( finished    = `onStorageDone`
                                      type  = `local`
                                      key   = `myKey`
                                      value = `myVal` ).


    lv_xml = lo_result->stringify( ).

    temp21 = xsdbool( lv_xml CS `Storage` ).
    cl_abap_unit_assert=>assert_true( temp21 ).

    temp22 = xsdbool( lv_xml CS `myKey` ).
    cl_abap_unit_assert=>assert_true( temp22 ).

  ENDMETHOD.

  METHOD test_info_frontend.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->info_frontend( `onInfoDone` ).


    lv_xml = lo_result->stringify( ).

    temp23 = xsdbool( lv_xml CS `Info` ).
    cl_abap_unit_assert=>assert_true( temp23 ).

    temp24 = xsdbool( lv_xml CS `onInfoDone` ).
    cl_abap_unit_assert=>assert_true( temp24 ).

  ENDMETHOD.

  METHOD test_lp_title.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp25 TYPE xsdboolean.
    DATA temp26 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).


    lo_result = lo_cc->lp_title( `Launchpad Title` ).


    lv_xml = lo_result->stringify( ).

    temp25 = xsdbool( lv_xml CS `LPTitle` ).
    cl_abap_unit_assert=>assert_true( temp25 ).

    temp26 = xsdbool( lv_xml CS `Launchpad Title` ).
    cl_abap_unit_assert=>assert_true( temp26 ).

  ENDMETHOD.

  METHOD test_z2ui5_namespace.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lv_xml TYPE string.
    DATA temp27 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_cc->timer( `onDone` ).
    lo_cc->focus( `id1` ).


    lv_xml = lo_view->stringify( ).

    temp27 = xsdbool( lv_xml CS `z2ui5` ).
    cl_abap_unit_assert=>assert_true( temp27 ).

  ENDMETHOD.

  METHOD test_smartmultiinput_ext.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp1 TYPE xsdboolean.
    DATA temp2 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->smartmultiinput_ext( multiinputid = `input1`
                                            rangedata    = `{/RANGE}` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp1 = xsdbool( lv_xml CS `SmartMultiInputExt` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

    temp2 = xsdbool( lv_xml CS `input1` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

  ENDMETHOD.

  METHOD test_multiinput_ext.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->multiinput_ext( multiinputid   = `myInput`
                                       multiinputname = `tokens`
                                       change         = `onChanged` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp3 = xsdbool( lv_xml CS `MultiInputExt` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

    temp4 = xsdbool( lv_xml CS `myInput` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

  ENDMETHOD.

  METHOD test_uitableext.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->uitableext( `myTable` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp5 = xsdbool( lv_xml CS `UITableExt` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

    temp6 = xsdbool( lv_xml CS `myTable` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

  ENDMETHOD.

  METHOD test_camera_selector.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->camera_selector( selectedkey = `{/CAMERA}`
                                        placeholder = `Select camera` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp7 = xsdbool( lv_xml CS `CameraSelector` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

    temp8 = xsdbool( lv_xml CS `Select camera` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

  ENDMETHOD.

  METHOD test_spreadsheet_export.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->spreadsheet_export( tableid = `exportTable`
                                           text    = `Export`
                                           icon    = `sap-icon://excel-attachment` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp9 = xsdbool( lv_xml CS `ExportSpreadsheet` ).
    cl_abap_unit_assert=>assert_true( temp9 ).

    temp10 = xsdbool( lv_xml CS `exportTable` ).
    cl_abap_unit_assert=>assert_true( temp10 ).

  ENDMETHOD.

  METHOD test_message_manager.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp11 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->message_manager( `{/MESSAGES}` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp11 = xsdbool( lv_xml CS `MessageManager` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

    temp12 = xsdbool( lv_xml CS `{/MESSAGES}` ).
    cl_abap_unit_assert=>assert_true( temp12 ).

  ENDMETHOD.

  METHOD test_scrolling.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->scrolling( setupdate = `onScroll`
                                  items     = `{/ITEMS}` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp13 = xsdbool( lv_xml CS `Scrolling` ).
    cl_abap_unit_assert=>assert_true( temp13 ).

    temp14 = xsdbool( lv_xml CS `onScroll` ).
    cl_abap_unit_assert=>assert_true( temp14 ).

  ENDMETHOD.

  METHOD test_tree.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp15 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->tree( `myTree` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp15 = xsdbool( lv_xml CS `Tree` ).
    cl_abap_unit_assert=>assert_true( temp15 ).

    temp16 = xsdbool( lv_xml CS `myTree` ).
    cl_abap_unit_assert=>assert_true( temp16 ).

  ENDMETHOD.

  METHOD test_websocket.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->websocket( received    = `onReceived`
                                  path        = `/ws/mypath`
                                  checkrepeat = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp17 = xsdbool( lv_xml CS `Websocket` ).
    cl_abap_unit_assert=>assert_true( temp17 ).

    temp18 = xsdbool( lv_xml CS `/ws/mypath` ).
    cl_abap_unit_assert=>assert_true( temp18 ).

  ENDMETHOD.

  METHOD test_binding_update.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->binding_update( changed = `onChanged`
                                       path    = `/XX/name` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp19 = xsdbool( lv_xml CS `BindingUpdate` ).
    cl_abap_unit_assert=>assert_true( temp19 ).

    temp20 = xsdbool( lv_xml CS `onChanged` ).
    cl_abap_unit_assert=>assert_true( temp20 ).

  ENDMETHOD.

  METHOD test_chartjs.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->chartjs( canvas_id = `chart1`
                                height    = `300`
                                width     = `400` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp21 = xsdbool( lv_xml CS `chartjs` ).
    cl_abap_unit_assert=>assert_true( temp21 ).

    temp22 = xsdbool( lv_xml CS `chart1` ).
    cl_abap_unit_assert=>assert_true( temp22 ).

  ENDMETHOD.

  METHOD test_approve_popover.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    lo_cc = NEW #( view = lo_view ).

    lo_result = lo_cc->approve_popover( text      = `Are you sure?`
                                        btn_txt   = `Confirm`
                                        btn_type  = `Emphasized`
                                        btn_event = `onConfirm` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

    lv_xml = lo_result->stringify( ).

    temp23 = xsdbool( lv_xml CS `Popover` ).
    cl_abap_unit_assert=>assert_true( temp23 ).

    temp24 = xsdbool( lv_xml CS `Are you sure?` ).
    cl_abap_unit_assert=>assert_true( temp24 ).

    temp25 = xsdbool( lv_xml CS `onConfirm` ).
    cl_abap_unit_assert=>assert_true( temp25 ).

  ENDMETHOD.

ENDCLASS.
