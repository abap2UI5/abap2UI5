CLASS ltcl_test_app DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    CLASS-DATA t_tab     TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    CLASS-DATA sv_status TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      t_tab = VALUE #( title = 'Peter'
                       descr = 'this is a description'
                       icon  = 'sap-icon://account'
                       ( info = 'completed' )
                       ( info = 'incompleted' ) ).

    ENDIF.

    CASE sv_status.

      WHEN `CHANGE`.

        client->view_display( z2ui5_cl_xml_view=>factory( client )->shell(
            )->page( title          = 'abap2UI5 - First Example'
                     navbuttonpress = client->_event( 'BACK' )
                     shownavbutton  = abap_true
            )->list(
                     " TODO: check spelling: Ouput (typo) -> Output (ABAP cleaner)
                     headertext      = 'List Ouput'
                     items           = client->_bind_edit( t_tab )
                     mode            = `SingleSelectMaster`
                     selectionchange = client->_event( 'SELCHANGE' )
            )->standard_list_item( title       = '{TITLE}'
                                   description = '{DESCR}'
                                   icon        = '{ICON}'
                                   info        = '{INFO}'
                                   press       = client->_event( 'TEST' )
                                   type        = `Navigation`
                                   selected    = `{SELECTED}`
             )->stringify( ) ).

      WHEN OTHERS.

        client->view_display(  z2ui5_cl_xml_view=>factory( client )->shell(
            )->page( title          = 'abap2UI5 - First Example'
                     navbuttonpress = client->_event( 'BACK' )
                     shownavbutton  = abap_true
            )->list(
                     " TODO: check spelling: Ouput (typo) -> Output (ABAP cleaner)
                     headertext      = 'List Ouput'
                     items           = client->_bind( t_tab )
                     mode            = `SingleSelectMaster`
                     selectionchange = client->_event( 'SELCHANGE' )
            )->standard_list_item( title       = '{TITLE}'
                                   description = '{DESCR}'
                                   icon        = '{ICON}'
                                   info        = '{INFO}'
                                   press       = client->_event( 'TEST' )
                                   type        = `Navigation`
                                   selected    = `{SELECTED}`
             )->stringify( ) ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_util_uuid_session       FOR TESTING RAISING cx_static_check.
    METHODS test_util_04_attri_by_ref    FOR TESTING RAISING cx_static_check.
    METHODS test_util_01_get_classdescr  FOR TESTING RAISING cx_static_check.
    METHODS test_util_02_get_attri       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_util_04_attri_by_ref.

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = z2ui5_cl_fw_utility=>get_t_attri_by_ref( lo_app ).

    DATA(lt_attri_result) = VALUE z2ui5_cl_fw_utility=>ty_t_attri(
  ( name = `Z2UI5_IF_APP~ID` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `CHECK_INITIALIZED` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `SV_STATUS` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ( name = `T_TAB` type_kind = `h` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
  ).

    IF lt_attri_result <> lt_attri.
      cl_abap_unit_assert=>fail( msg = 'utility - create t_attri failed' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_util_uuid_session.
*    DATA(lv_one) = z2ui5_lcl_utility=>get_uuid_session( ).
*    DATA(lv_two) = z2ui5_lcl_utility=>get_uuid_session( ).
*
*    IF lv_one <> `1`.
*      cl_abap_unit_assert=>fail( msg = 'utility - create session id' quit = 5 ).
*    ENDIF.
*
*    IF lv_two <> `2`.
*      cl_abap_unit_assert=>fail( msg = 'utility - create session id' quit = 5 ).
*    ENDIF.
  ENDMETHOD.

  METHOD test_util_02_get_attri.

    DATA(lo_app) = NEW ltcl_test_app( ).

    lo_app->sv_status = `ABC`.
    FIELD-SYMBOLS <any> TYPE any.
    DATA(lv_assign) = `LO_APP->` && 'SV_STATUS'.
    ASSIGN (lv_assign) TO <any>.

    IF <any> <> `ABC`.
      cl_abap_unit_assert=>fail( msg = 'utility - assign of attribute from outside not working' quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_util_01_get_classdescr.

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( lo_app ) )->attributes.

    DATA(lt_test) = VALUE abap_attrdescr_tab(
        decimals     = '0'
        visibility   = 'U'
        is_inherited = ''
        is_constant  = ''
        is_virtual   = ''
        is_read_only = ''
        alias_for    = ''
        ( length = '8' name = 'Z2UI5_IF_APP~ID' type_kind = 'g' is_interface = 'X' is_class = '' )
        ( length = '2' name = 'CHECK_INITIALIZED' type_kind = 'C' is_interface = '' is_class = '' )
        ( length = '8' name = 'SV_STATUS' type_kind = 'g' is_interface = '' is_class = 'X' )
        ( length = '8' name = 'T_TAB' type_kind = 'h' is_interface = '' is_class = 'X' ) ).

    IF lt_test <> lt_attri.
      cl_abap_unit_assert=>fail( msg = 'utility - get abap_attrdescr_tab table wrong' quit = 5 ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
