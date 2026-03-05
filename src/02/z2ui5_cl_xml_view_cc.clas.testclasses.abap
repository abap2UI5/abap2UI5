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
    METHODS test_z2ui5_namespace   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_cc IMPLEMENTATION.

  METHOD test_constructor.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.

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
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->timer( finished          = `onTimerFinished`
                                    delayms     = `2000`
                                    checkrepeat = abap_true ).

    cl_abap_unit_assert=>assert_bound( lo_result ).


    lv_xml = lo_result->stringify( ).

    
    temp4 = boolc( lv_xml CS `Timer` ).
    temp1 = temp4.
    cl_abap_unit_assert=>assert_true( temp1 ).

    
    temp5 = boolc( lv_xml CS `z2ui5` ).
    temp2 = temp5.
    cl_abap_unit_assert=>assert_true( temp2 ).

    
    temp6 = boolc( lv_xml CS `2000` ).
    temp3 = temp6.
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_focus.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->focus( `myInput` ).


    lv_xml = lo_result->stringify( ).

    
    temp7 = boolc( lv_xml CS `Focus` ).
    temp4 = temp7.
    cl_abap_unit_assert=>assert_true( temp4 ).

    
    temp8 = boolc( lv_xml CS `myInput` ).
    temp5 = temp8.
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_camera_picture.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->camera_picture( id             = `cam1`
                                             press    = `onSnap`
                                             autoplay = abap_true ).


    lv_xml = lo_result->stringify( ).

    
    temp9 = boolc( lv_xml CS `CameraPicture` ).
    temp6 = temp9.
    cl_abap_unit_assert=>assert_true( temp6 ).

    
    temp10 = boolc( lv_xml CS `cam1` ).
    temp7 = temp10.
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD test_bwip_js.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->bwip_js( bcid         = `qrcode`
                                      text   = `Hello`
                                      scale  = `3`
                                      height = `10` ).


    lv_xml = lo_result->stringify( ).

    
    temp11 = boolc( lv_xml CS `bwipjs` ).
    temp8 = temp11.
    cl_abap_unit_assert=>assert_true( temp8 ).

    
    temp12 = boolc( lv_xml CS `qrcode` ).
    temp9 = temp12.
    cl_abap_unit_assert=>assert_true( temp9 ).

  ENDMETHOD.

  METHOD test_geolocation.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->geolocation( finished        = `onGeoFinished`
                                          longitude = `{/LON}`
                                          latitude  = `{/LAT}` ).


    lv_xml = lo_result->stringify( ).

    
    temp13 = boolc( lv_xml CS `Geolocation` ).
    temp10 = temp13.
    cl_abap_unit_assert=>assert_true( temp10 ).

    
    temp14 = boolc( lv_xml CS `{/LON}` ).
    temp11 = temp14.
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD test_file_uploader.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->file_uploader( placeholder      = `Choose file`
                                            upload     = `onUpload`
                                            buttontext = `Browse` ).


    lv_xml = lo_result->stringify( ).

    
    temp15 = boolc( lv_xml CS `FileUploader` ).
    temp12 = temp15.
    cl_abap_unit_assert=>assert_true( temp12 ).

    
    temp16 = boolc( lv_xml CS `Choose file` ).
    temp13 = temp16.
    cl_abap_unit_assert=>assert_true( temp13 ).

  ENDMETHOD.

  METHOD test_favicon.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->favicon( `icon.png` ).


    lv_xml = lo_result->stringify( ).

    
    temp17 = boolc( lv_xml CS `Favicon` ).
    temp14 = temp17.
    cl_abap_unit_assert=>assert_true( temp14 ).

    
    temp18 = boolc( lv_xml CS `icon.png` ).
    temp15 = temp18.
    cl_abap_unit_assert=>assert_true( temp15 ).

  ENDMETHOD.

  METHOD test_title.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->title( `My App` ).


    lv_xml = lo_result->stringify( ).

    
    temp19 = boolc( lv_xml CS `Title` ).
    temp16 = temp19.
    cl_abap_unit_assert=>assert_true( temp16 ).

    
    temp20 = boolc( lv_xml CS `My App` ).
    temp17 = temp20.
    cl_abap_unit_assert=>assert_true( temp17 ).

  ENDMETHOD.

  METHOD test_dirty.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp18 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->dirty( abap_true ).


    lv_xml = lo_result->stringify( ).

    
    temp21 = boolc( lv_xml CS `Dirty` ).
    temp18 = temp21.
    cl_abap_unit_assert=>assert_true( temp18 ).

  ENDMETHOD.

  METHOD test_history.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp19 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->history( `{/SEARCH}` ).


    lv_xml = lo_result->stringify( ).

    
    temp22 = boolc( lv_xml CS `History` ).
    temp19 = temp22.
    cl_abap_unit_assert=>assert_true( temp19 ).

  ENDMETHOD.

  METHOD test_messaging.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp20 TYPE xsdboolean.
    DATA temp23 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->messaging( `{/MESSAGES}` ).


    lv_xml = lo_result->stringify( ).

    
    temp23 = boolc( lv_xml CS `Messaging` ).
    temp20 = temp23.
    cl_abap_unit_assert=>assert_true( temp20 ).

  ENDMETHOD.

  METHOD test_storage.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->storage( finished    = `onStorageDone`
                                      type  = `local`
                                      key   = `myKey`
                                      value = `myVal` ).


    lv_xml = lo_result->stringify( ).

    
    temp24 = boolc( lv_xml CS `Storage` ).
    temp21 = temp24.
    cl_abap_unit_assert=>assert_true( temp21 ).

    
    temp25 = boolc( lv_xml CS `myKey` ).
    temp22 = temp25.
    cl_abap_unit_assert=>assert_true( temp22 ).

  ENDMETHOD.

  METHOD test_info_frontend.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->info_frontend( `onInfoDone` ).


    lv_xml = lo_result->stringify( ).

    
    temp26 = boolc( lv_xml CS `Info` ).
    temp23 = temp26.
    cl_abap_unit_assert=>assert_true( temp23 ).

    
    temp27 = boolc( lv_xml CS `onInfoDone` ).
    temp24 = temp27.
    cl_abap_unit_assert=>assert_true( temp24 ).

  ENDMETHOD.

  METHOD test_lp_title.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lo_result TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp25 TYPE xsdboolean.
    DATA temp26 TYPE xsdboolean.
    DATA temp28 TYPE xsdboolean.
    DATA temp29 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.


    lo_result = lo_cc->lp_title( `Launchpad Title` ).


    lv_xml = lo_result->stringify( ).

    
    temp28 = boolc( lv_xml CS `LPTitle` ).
    temp25 = temp28.
    cl_abap_unit_assert=>assert_true( temp25 ).

    
    temp29 = boolc( lv_xml CS `Launchpad Title` ).
    temp26 = temp29.
    cl_abap_unit_assert=>assert_true( temp26 ).

  ENDMETHOD.

  METHOD test_z2ui5_namespace.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_cc TYPE REF TO z2ui5_cl_xml_view_cc.
    DATA lv_xml TYPE string.
    DATA temp27 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( )->page( `Test` ).

    CREATE OBJECT lo_cc EXPORTING view = lo_view.

    lo_cc->timer( `onDone` ).
    lo_cc->focus( `id1` ).


    lv_xml = lo_view->stringify( ).

    
    temp30 = boolc( lv_xml CS `z2ui5` ).
    temp27 = temp30.
    cl_abap_unit_assert=>assert_true( temp27 ).

  ENDMETHOD.

ENDCLASS.
