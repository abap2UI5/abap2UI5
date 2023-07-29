CLASS ltcl_test_app DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

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

    CONSTANTS sv_status TYPE string VALUE `test` ##NEEDED.

    CLASS-DATA sv_var TYPE string.
    CLASS-DATA ss_tab TYPE ty_row.
    CLASS-DATA st_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA mv_val TYPE string ##NEEDED.
    DATA ms_tab TYPE ty_row ##NEEDED.
    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY ##NEEDED.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.
ENDCLASS.

CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS general_get_classdescr FOR TESTING RAISING cx_static_check.
    METHODS general_get_attri      FOR TESTING RAISING cx_static_check.

    METHODS test_check_is_boolean     FOR TESTING RAISING cx_static_check.
    METHODS test_create               FOR TESTING RAISING cx_static_check.
    METHODS test_get_abap_2_json      FOR TESTING RAISING cx_static_check.
    METHODS test_get_classname_by_ref FOR TESTING RAISING cx_static_check.
    METHODS test_get_json_boolean     FOR TESTING RAISING cx_static_check.
    METHODS test_get_replace          FOR TESTING RAISING cx_static_check.
    METHODS test_get_timestampl       FOR TESTING RAISING cx_static_check.
    METHODS test_get_trim_lower       FOR TESTING RAISING cx_static_check.
    METHODS test_get_trim_upper       FOR TESTING RAISING cx_static_check.
    METHODS test_attri_by_ref         FOR TESTING RAISING cx_static_check.
    METHODS test_get_uuid             FOR TESTING RAISING cx_static_check.
    METHODS test_get_user_tech        FOR TESTING RAISING cx_static_check.
    METHODS test_raise                FOR TESTING RAISING cx_static_check.
    METHODS test_any_2_json           FOR TESTING RAISING cx_static_check.
    METHODS test_any_2_json_02        FOR TESTING RAISING cx_static_check.
    METHODS test_trans_ref_tab_2_tab  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_attri_by_ref.

    "dummy for abaplint check green
    ltcl_test_app=>sv_var = ``.
    ltcl_test_app=>ss_tab = VALUE #( ).
    ltcl_test_app=>st_tab = VALUE #( ).

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = z2ui5_cl_fw_utility=>get_t_attri_by_ref( lo_app ).

    DATA(lt_attri_result) = VALUE z2ui5_cl_fw_utility=>ty_t_attri(
( name = `MT_TAB` type_kind = `h` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MV_VAL` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `ST_TAB` type_kind = `h` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SV_STATUS` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SV_VAR` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-TITLE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-VALUE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-DESCR` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-ICON` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-INFO` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-SELECTED` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `MS_TAB-CHECKBOX` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-TITLE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-VALUE` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-DESCR` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-ICON` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-INFO` type_kind = `g` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-SELECTED` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
( name = `SS_TAB-CHECKBOX` type_kind = `C` type = `` bind_type = `` data_stringify = `` data_rtti = `` check_ref_data = '' )
 ).

    IF lt_attri_result <> lt_attri.
      cl_abap_unit_assert=>fail( msg  = 'utility - create t_attri failed'
                                 quit = 5 ).
    ENDIF.

  ENDMETHOD.


  METHOD general_get_attri.

    DATA(lo_app) = NEW ltcl_test_app( ).

    lo_app->mv_val = `ABC`.
    FIELD-SYMBOLS <any> TYPE any.
    DATA(lv_assign) = `LO_APP->` && 'MV_VAL'.
    ASSIGN (lv_assign) TO <any>.

    IF <any> <> `ABC`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD general_get_classdescr.

    DATA(lo_app) = NEW ltcl_test_app( ).

    DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( lo_app ) )->attributes.

    DATA(lt_test) = VALUE abap_attrdescr_tab(
( length = '44' decimals = '0' name = 'MS_TAB' type_kind = 'v' visibility = 'U' is_interface = '' is_inherited = '' is_class = '' is_constant = '' is_virtual = '' is_read_only = '' alias_for = '' )
( length = '8' decimals = '0' name = 'MT_TAB' type_kind = 'h' visibility = 'U' is_interface = '' is_inherited = '' is_class = '' is_constant = '' is_virtual = '' is_read_only = '' alias_for = '' )
( length = '8' decimals = '0' name = 'MV_VAL' type_kind = 'g' visibility = 'U' is_interface = '' is_inherited = '' is_class = '' is_constant = '' is_virtual = '' is_read_only = '' alias_for = '' )
( length = '44' decimals = '0' name = 'SS_TAB' type_kind = 'v' visibility = 'U' is_interface = '' is_inherited = '' is_class = 'X' is_constant = '' is_virtual = '' is_read_only = '' alias_for = '' )
( length = '8' decimals = '0' name = 'ST_TAB' type_kind = 'h' visibility = 'U' is_interface = '' is_inherited = '' is_class = 'X' is_constant = '' is_virtual = '' is_read_only = '' alias_for = '' )
( length = '8' decimals = '0' name = 'SV_STATUS' type_kind = 'g' visibility = 'U' is_interface = '' is_inherited = '' is_class = 'X' is_constant = 'X' is_virtual = '' is_read_only = '' alias_for = '' )
( length = '8' decimals = '0' name = 'SV_VAR' type_kind = 'g' visibility = 'U' is_interface = '' is_inherited = '' is_class = 'X' is_constant = '' is_virtual = '' is_read_only = '' alias_for = '' )
 ).

    IF lt_test <> lt_attri.
      cl_abap_unit_assert=>fail( msg  = 'utility - get abap_attrdescr_tab table wrong'
                                 quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_check_is_boolean.

    IF NOT z2ui5_cl_fw_utility=>check_is_boolean( xsdbool( 1 = 1 ) ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF NOT z2ui5_cl_fw_utility=>check_is_boolean( xsdbool( 1 = 2 ) ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF NOT z2ui5_cl_fw_utility=>check_is_boolean( abap_true ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF NOT z2ui5_cl_fw_utility=>check_is_boolean( abap_false ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_create.

    DATA(lo_test) = NEW z2ui5_cl_fw_utility( ) ##NEEDED.

  ENDMETHOD.

  METHOD test_get_abap_2_json.

    IF `true` <> z2ui5_cl_fw_utility=>get_abap_2_json( xsdbool( 1 = 1 ) ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF `false` <> z2ui5_cl_fw_utility=>get_abap_2_json( xsdbool( 1 = 2 ) ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF `true` <> z2ui5_cl_fw_utility=>get_abap_2_json(  abap_true ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF `false` <> z2ui5_cl_fw_utility=>get_abap_2_json(  abap_false ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_classname_by_ref.

    DATA(lo_test) = NEW z2ui5_cl_fw_utility( ).
    DATA(lv_name) = z2ui5_cl_fw_utility=>get_classname_by_ref( lo_test ).
    IF lv_name <> `Z2UI5_CL_FW_UTILITY`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    DATA(lo_test2) = NEW ltcl_test_app( ).
    DATA(lv_name2) = z2ui5_cl_fw_utility=>get_classname_by_ref( lo_test2 ).
    IF lv_name2 <> `LTCL_TEST_APP`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_json_boolean.

    IF `false` <> z2ui5_cl_fw_utility=>get_json_boolean( abap_false ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF `ABCD` <> z2ui5_cl_fw_utility=>get_json_boolean( `ABCD` ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_replace.

    DATA(lv_text) = `this is a replace text`.
    DATA(lv_result) = z2ui5_cl_fw_utility=>get_replace(
        iv_val     = lv_text
        iv_begin   = `is a `
        iv_end     = ` te`
        iv_replace = 'is a test te' ).
    IF lv_result <> `this is a test text`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_timestampl.

    DATA(lv_time) = z2ui5_cl_fw_utility=>get_timestampl( ).
    DATA(lv_time2) = z2ui5_cl_fw_utility=>get_timestampl( ).

    IF lv_time2 < lv_time.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_trim_lower.

    IF z2ui5_cl_fw_utility=>get_trim_lower( ` JsadfHHs  ` ) <> `jsadfhhs`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_trim_upper.

    IF z2ui5_cl_fw_utility=>get_trim_upper( ` JsadfHHs  ` ) <> `JSADFHHS`.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_uuid.

    DATA(lv_uuid) = z2ui5_cl_fw_utility=>get_uuid( ).

    IF lv_uuid IS INITIAL.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    IF strlen( lv_uuid ) <> 32.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_get_user_tech.

    IF sy-uname <> z2ui5_cl_fw_utility=>get_user_tech( ).
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_raise.

    TRY.
        z2ui5_cl_fw_utility=>raise( ).
        cl_abap_unit_assert=>fail( quit = 5 ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( 1 = 1 ) ).
        cl_abap_unit_assert=>fail( quit = 5 ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        z2ui5_cl_fw_utility=>raise( when = xsdbool( 1 = 3 ) ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( quit = 5 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_any_2_json.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).


    DATA(lv_tab_json) = z2ui5_cl_fw_utility=>trans_any_2_json( lt_tab ).

    DATA(lv_result) = `[{"TITLE":"Test","VALUE":"this is a description","SELECTED":true},{"TITLE":"Test2","VALUE":"this is a new descr","SELECTED":false}]`.

    IF lv_result <> lv_tab_json.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.


  METHOD test_any_2_json_02.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).
    DATA(lv_tab) = z2ui5_cl_fw_utility=>trans_any_2_json( lt_tab ).

    /ui2/cl_json=>deserialize( EXPORTING json = lv_tab
                               CHANGING  data = lt_tab2 ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_trans_ref_tab_2_tab.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        selected TYPE abap_bool,
      END OF ty_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA(lv_result) = `[{"TITLE":"Test","VALUE":"this is a description","SELECTED":true},{"TITLE":"Test2","VALUE":"this is a new descr","SELECTED":false}]`.

    DATA lo_data TYPE REF TO data.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_result
                               CHANGING  data = lo_data ).

    DATA(lt_tab2) = VALUE ty_t_tab( ).
    z2ui5_cl_fw_utility=>trans_ref_tab_2_tab(
        EXPORTING ir_tab_from = lo_data
        IMPORTING t_result    = lt_tab2 ).


    DATA(lt_tab) = VALUE ty_t_tab( ( title = 'Test'  value = 'this is a description' selected = abap_true )
                                   ( title = 'Test2' value = 'this is a new descr'   selected = abap_false ) ).

    IF lt_tab <> lt_tab2.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
