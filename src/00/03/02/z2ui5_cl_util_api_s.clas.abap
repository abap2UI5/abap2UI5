CLASS z2ui5_cl_util_api_s DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS bal_read
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_create
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_update
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_delete
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike.

    CLASS-METHODS context_get_callstack
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_stack.

    CLASS-METHODS context_check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS context_get_tenant
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS context_get_user_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS source_get_method
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_s_data_element_text.

    CLASS-METHODS conv_decode_x_base64
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_encode_x_base64
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_string_by_xstring
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_xstring_by_string
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_get_xlsx_by_itab
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_get_itab_by_xlsx
      IMPORTING
        val    TYPE xstring
      EXPORTING
        result TYPE REF TO data.

    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_classes.

    CLASS-METHODS rtti_get_t_fixvalues
      IMPORTING
        elemdescr     TYPE REF TO cl_abap_elemdescr
        langu         TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_fix_val.

    CLASS-METHODS rtti_get_table_desrc
      IMPORTING
        tabname       TYPE clike
        langu         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

    CLASS-METHODS tr_copy_objects
      IMPORTING
        source      TYPE clike
        destination TYPE clike.

    CLASS-METHODS tr_import
      IMPORTING
        trkorr         TYPE clike
        target_system  TYPE clike
        client         TYPE clike OPTIONAL
        ignore_version TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE i.

    CLASS-METHODS tr_check_status
      IMPORTING
        trkorr   TYPE clike
        system   TYPE clike
      EXPORTING
        imported TYPE abap_bool
        rc       TYPE i.


  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        i_classname   TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    CLASS-DATA gv_check_cloud TYPE abap_bool.
    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

    CLASS-METHODS bal_msg_add
      IMPORTING
        handle TYPE any
        t_log  TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_load_handles
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_filter_add
      IMPORTING
        comp   TYPE clike
        value  TYPE clike
      CHANGING
        filter TYPE any.

    CLASS-METHODS bal_map_msg
      IMPORTING
        msg           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_s_msg.

ENDCLASS.


CLASS z2ui5_cl_util_api_s IMPLEMENTATION.

  METHOD context_get_user_tech.
    TRY.

        DATA(lv_result) = VALUE string( ).
        DATA(lv_class) = `CL_ABAP_CONTEXT_INFO`.
        CALL METHOD (lv_class)=>(`GET_USER_BUSINESS_PARTNER_ID`)
          RECEIVING
            rv_business_partner_id = lv_result.

        result = lv_result.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.


  ENDMETHOD.


  METHOD context_check_abap_cloud.

    IF gv_check_cloud_cached = abap_true.
      result = gv_check_cloud.
      RETURN.
    ENDIF.

    TRY.
        cl_abap_typedescr=>describe_by_name( `T100` ).
        gv_check_cloud = abap_false.
      CATCH cx_root.
        gv_check_cloud = abap_true.
    ENDTRY.
    gv_check_cloud_cached = abap_true.
    result = gv_check_cloud.

  ENDMETHOD.


  METHOD rtti_get_t_fixvalues.

    TYPES:
      BEGIN OF fixvalue,
        low        TYPE c LENGTH 10,
        high       TYPE c LENGTH 10,
        option     TYPE c LENGTH 2,
        ddlanguage TYPE c LENGTH 1,
        ddtext     TYPE c LENGTH 60,
      END OF fixvalue.
    TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH DEFAULT KEY.
    DATA lt_values TYPE fixvalues.

    DATA lv_langu  TYPE c LENGTH 1.
    DATA temp1     LIKE LINE OF lt_values.
    DATA lr_fix    LIKE REF TO temp1.
    DATA temp2     TYPE z2ui5_cl_util_api=>ty_s_fix_val.

    lv_langu = ` `.
    lv_langu = langu.

    CALL METHOD elemdescr->(`GET_DDIC_FIXED_VALUES`)
      EXPORTING
        p_langu        = lv_langu
      RECEIVING
        p_fixed_values = lt_values
      EXCEPTIONS
        not_found      = 1
        no_ddic_type   = 2
        OTHERS         = 3.

    LOOP AT lt_values REFERENCE INTO lr_fix.

      CLEAR temp2.
      temp2-low   = lr_fix->low.
      temp2-high  = lr_fix->high.
      temp2-descr = lr_fix->ddtext.
      INSERT temp2
             INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD conv_decode_x_base64.
    DATA lv_web_http_name TYPE c LENGTH 19.
    DATA classname        TYPE c LENGTH 15.

    TRY.

        lv_web_http_name = `CL_WEB_HTTP_UTILITY`.
        CALL METHOD (lv_web_http_name)=>(`DECODE_X_BASE64`)
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

      CATCH cx_root.

        classname = `CL_HTTP_UTILITY`.
        CALL METHOD (classname)=>(`DECODE_X_BASE64`)
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_encode_x_base64.
    DATA lv_web_http_name TYPE c LENGTH 19.
    DATA classname        TYPE c LENGTH 15.

    TRY.

        lv_web_http_name = `CL_WEB_HTTP_UTILITY`.
        CALL METHOD (lv_web_http_name)=>(`ENCODE_X_BASE64`)
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

      CATCH cx_root.

        classname = `CL_HTTP_UTILITY`.
        CALL METHOD (classname)=>(`ENCODE_X_BASE64`)
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_string_by_xstring.

    DATA conv          TYPE REF TO object.
    DATA conv_codepage TYPE c LENGTH 21.
    DATA conv_in_class TYPE c LENGTH 18.

    TRY.

        conv_codepage = `CL_ABAP_CONV_CODEPAGE`.
        CALL METHOD (conv_codepage)=>create_in
          RECEIVING
            instance = conv.

        CALL METHOD conv->(`IF_ABAP_CONV_IN~CONVERT`)
          EXPORTING
            source = val
          RECEIVING
            result = result.

      CATCH cx_root.

        conv_in_class = `CL_ABAP_CONV_IN_CE`.
        CALL METHOD (conv_in_class)=>create
          EXPORTING
            encoding = `UTF-8`
          RECEIVING
            conv     = conv.

        CALL METHOD conv->(`CONVERT`)
          EXPORTING
            input = val
          IMPORTING
            data  = result.
    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_xstring_by_string.

    DATA conv           TYPE REF TO object.
    DATA conv_codepage  TYPE c LENGTH 21.
    DATA conv_out_class TYPE c LENGTH 19.

    TRY.

        conv_codepage = `CL_ABAP_CONV_CODEPAGE`.
        CALL METHOD (conv_codepage)=>create_out
          RECEIVING
            instance = conv.

        CALL METHOD conv->(`IF_ABAP_CONV_OUT~CONVERT`)
          EXPORTING
            source = val
          RECEIVING
            result = result.

      CATCH cx_root.

        conv_out_class = `CL_ABAP_CONV_OUT_CE`.
        CALL METHOD (conv_out_class)=>create
          EXPORTING
            encoding = `UTF-8`
          RECEIVING
            conv     = conv.

        CALL METHOD conv->(`CONVERT`)
          EXPORTING
            data   = val
          IMPORTING
            buffer = result.
    ENDTRY.

  ENDMETHOD.

  METHOD source_get_method.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_source       TYPE string_table.
    DATA lt_string       TYPE string_table.
    DATA lv_class        TYPE string.
    DATA lv_method       TYPE string.
    DATA xco_cp_abap     TYPE c LENGTH 11.
    DATA lv_name         TYPE c LENGTH 13.
    DATA lv_check_method LIKE abap_false.
    DATA lv_source       LIKE LINE OF lt_source.
    DATA lv_source_upper TYPE string.

    TRY.

        lv_class  = to_upper( iv_classname ).
        lv_method = to_upper( iv_methodname ).

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_class
          RECEIVING
            ro_class = object.

        ASSIGN object->(`IF_XCO_AO_CLASS~IMPLEMENTATION`) TO <any>.
        ASSERT sy-subrc = 0.
        object = <any>.

        CALL METHOD object->(`IF_XCO_CLAS_IMPLEMENTATION~METHOD`)
          EXPORTING
            iv_name   = lv_method
          RECEIVING
            ro_method = object.

        CALL METHOD object->(`IF_XCO_CLAS_I_METHOD~CONTENT`)
          RECEIVING
            ro_content = object.

        CALL METHOD object->(`IF_XCO_CLAS_I_METHOD_CONTENT~GET_SOURCE`)
          RECEIVING
            rt_source = result.

      CATCH cx_root.

        lv_name = `CL_OO_FACTORY`.
        CALL METHOD (lv_name)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = object.

        CALL METHOD object->(`IF_OO_CLIF_SOURCE_FACTORY~CREATE_CLIF_SOURCE`)
          EXPORTING
            clif_name = lv_class
          RECEIVING
            result    = object.

        CALL METHOD object->(`IF_OO_CLIF_SOURCE~GET_SOURCE`)
          IMPORTING
            source = lt_source.

        lv_check_method = abap_false.

        LOOP AT lt_source INTO lv_source.

          lv_source_upper = to_upper( lv_source ).

          IF lv_source_upper CS `ENDMETHOD`.
            lv_check_method = abap_false.
          ENDIF.

          IF lv_source_upper CS |METHOD { lv_method }|.
            lv_check_method = abap_true.
            CONTINUE.
          ENDIF.

          IF lv_check_method = abap_true.
            INSERT lv_source INTO TABLE lt_string.
          ENDIF.

        ENDLOOP.

    ENDTRY.

    result = lt_string.

  ENDMETHOD.

  METHOD rtti_get_classes_impl_intf.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    TYPES BEGIN OF ty_s_impl.
    TYPES   clsname    TYPE c LENGTH 30.
    TYPES   refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
    TYPES BEGIN OF ty_s_key.
    TYPES   intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
    DATA BEGIN OF ls_clskey.
    DATA   clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA class               TYPE REF TO data.
    DATA xco_cp_abap         TYPE c LENGTH 11.
    DATA temp3               TYPE z2ui5_cl_util_api=>ty_t_classes.
    DATA implementation_name LIKE LINE OF lt_implementation_names.
    DATA temp4               LIKE LINE OF temp3.
    DATA lv_fm               TYPE string.
    DATA type                TYPE c LENGTH 12.
    FIELD-SYMBOLS <class> TYPE data.
    DATA temp5   LIKE LINE OF lt_impl.
    DATA lr_impl LIKE REF TO temp5.
    FIELD-SYMBOLS <description> TYPE any.
    DATA temp6 TYPE z2ui5_cl_util_api=>ty_s_class_descr.

    TRY.

        ls_clskey-clsname = val.

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>interface
          EXPORTING
            iv_name      = ls_clskey-clsname
          RECEIVING
            ro_interface = obj.

        ASSIGN obj->(`IF_XCO_AO_INTERFACE~IMPLEMENTATIONS`) TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        ASSIGN obj->(`IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL`) TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        CALL METHOD obj->(`IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES`)
          RECEIVING
            rt_names = lt_implementation_names.

        CLEAR temp3.

        LOOP AT lt_implementation_names INTO implementation_name.

          temp4-classname   = implementation_name.
          temp4-description = rtti_get_class_descr_on_cloud( implementation_name ).
          INSERT temp4 INTO TABLE temp3.
        ENDLOOP.
        result = temp3.

      CATCH cx_root INTO DATA(x).
        DATA(lv_dummy) = x->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    DATA ddic_ref     TYPE REF TO data.
    DATA data_element TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA: BEGIN OF ddic,
            reptext   TYPE string,
            scrtext_s TYPE string,
            scrtext_m TYPE string,
            scrtext_l TYPE string,
          END OF ddic.
    DATA exists            TYPE abap_bool.

    DATA data_element_name TYPE string.
    DATA temp7             TYPE REF TO cl_abap_structdescr.
    DATA struct_desrc      LIKE temp7.
    FIELD-SYMBOLS <ddic> TYPE data.
    DATA lo_typedescr           TYPE REF TO cl_abap_typedescr.
    DATA temp8                  TYPE REF TO cl_abap_datadescr.
    DATA data_descr             LIKE temp8.

    data_element_name = val.

    TRY.
        cl_abap_typedescr=>describe_by_name( `T100` ).

        temp7 ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

        struct_desrc = temp7.

        CREATE DATA ddic_ref TYPE HANDLE struct_desrc.

        ASSIGN ddic_ref->* TO <ddic>.
        ASSERT sy-subrc = 0.

        cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name      = data_element_name
                                             RECEIVING  p_descr_ref = lo_typedescr
                                             EXCEPTIONS OTHERS      = 1 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        temp8 ?= lo_typedescr.

        data_descr = temp8.

        CALL METHOD data_descr->(`GET_DDIC_FIELD`)
          RECEIVING
            p_flddescr   = <ddic>
          EXCEPTIONS
            not_found    = 1
            no_ddic_type = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        MOVE-CORRESPONDING <ddic> TO ddic.
        result-header = ddic-reptext.
        result-short  = ddic-scrtext_s.
        result-medium = ddic-scrtext_m.
        result-long   = ddic-scrtext_l.

      CATCH cx_root.
        TRY.
            DATA lv_xco_cp_abap_dictionary TYPE string.
            lv_xco_cp_abap_dictionary = `XCO_CP_ABAP_DICTIONARY`.
            CALL METHOD (lv_xco_cp_abap_dictionary)=>(`DATA_ELEMENT`)
              EXPORTING
                iv_name         = data_element_name
              RECEIVING
                ro_data_element = data_element.

            CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~EXISTS`)
              RECEIVING
                rv_exists = exists.

            IF exists = abap_false.
              RETURN.
            ENDIF.

            CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~CONTENT`)
              RECEIVING
                ro_content = content.

            CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL`)
              RECEIVING
                rs_heading_field_label = result-header.

            CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL`)
              RECEIVING
                rs_short_field_label = result-short.

            CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL`)
              RECEIVING
                rs_medium_field_label = result-medium.

            CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL`)
              RECEIVING
                rs_long_field_label = result-long.

          CATCH cx_root INTO DATA(x).
            DATA(error) = x->get_text( ).
        ENDTRY.
    ENDTRY.

    IF result IS INITIAL.
      result-header = val.
      result-long = val.
      result-medium = val.
      result-short = val.
    ENDIF.

  ENDMETHOD.

  METHOD uuid_get_c22.

    DATA lv_uuid      TYPE c LENGTH 22.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c22
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_22 = lv_uuid.

        ENDTRY.

        result = lv_uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

    result = replace( val  = result
                      sub  = `}`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `{`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `'`
                      with = `0`
                      occ  = 0 ).

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid      TYPE c LENGTH 32.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_root.

            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = lv_uuid.

        ENDTRY.

        result = lv_uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_class_descr_on_cloud.

    TRY.

        DATA obj          TYPE REF TO object.
        DATA content      TYPE REF TO object.
        DATA lv_classname TYPE c LENGTH 30.
        DATA xco_cp_abap  TYPE c LENGTH 11.

        lv_classname = i_classname.

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_classname
          RECEIVING
            ro_class = obj.

        CALL METHOD obj->(`IF_XCO_AO_CLASS~CONTENT`)
          RECEIVING
            ro_content = content.

        CALL METHOD content->(`IF_XCO_CLAS_CONTENT~GET_SHORT_DESCRIPTION`)
          RECEIVING
            rv_short_description = result.

      CATCH cx_root INTO DATA(x).
        DATA(lv_dummy) = x->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_table_desrc.

    DATA ddtext TYPE c LENGTH 60.

    IF langu IS NOT SUPPLIED.
      DATA(lan) = sy-langu.
    ELSE.
      lan = langu.
    ENDIF.

    IF context_check_abap_cloud( ).

      ddtext = tabname.

    ELSE.

      DATA(lv_tabname) = `dd02t`.
      SELECT SINGLE ddtext
        FROM (lv_tabname)
        WHERE tabname    = @tabname
          AND ddlanguage = @lan
        INTO @ddtext.

    ENDIF.

    IF ddtext IS NOT INITIAL.
      result = ddtext.
    ELSE.
      result = tabname.
    ENDIF.

  ENDMETHOD.

  METHOD context_get_tenant.

    "DATA(tenant_info) = xco_cp=>current->tenant( ).
    "DATA(account_id) = tenant_info->get_global_account_id( ).

  ENDMETHOD.

  METHOD context_get_callstack.

*
*    TRY.
*
*        DATA current_obj TYPE REF TO object.
*        DATA stack TYPE REF TO object.
*        DATA full_stack TYPE REF TO object.
*        DATA format_source TYPE REF TO object.
*        DATA format_obj2 TYPE REF TO object.
*        DATA format_obj3 TYPE REF TO object.
*        DATA text_obj TYPE REF TO object.
*        DATA lv_xco_cp TYPE c LENGTH 6.
*        DATA ro_lines TYPE REF TO object.
*        FIELD-SYMBOLS <current> TYPE any.
*        FIELD-SYMBOLS <any> TYPE any.
*        FIELD-SYMBOLS <call_stack> TYPE any.
*        FIELD-SYMBOLS <format> TYPE any.
*        FIELD-SYMBOLS <format2> TYPE any.
*
*        "1 format source
*        DATA(lv_assign) = `XCO_CP_CALL_STACK=>LINE_NUMBER_FLAVOR->SOURCE`.
*        ASSIGN (lv_assign) TO <format>.
*
*        lv_assign = `XCO_CP_CALL_STACK=>FORMAT`.
*        ASSIGN (lv_assign) TO <format2>.
*        format_obj2 = <format2>.
*
*        CALL METHOD format_obj2->(`IF_XCO_CP_CS_FORMAT_FACTORY~ADT`)
*          RECEIVING
*            ro_adt = format_obj3.
*
*        CALL METHOD format_obj3->(`WITH_LINE_NUMBER_FLAVOR`)
*          EXPORTING
*            io_line_number_flavor = <format>
*          RECEIVING
*            ro_me                 = format_source.
*
*        lv_xco_cp = `XCO_CP`.
*        ASSIGN (lv_xco_cp)=>(`CURRENT`) TO <current>.
*        current_obj = <current>.
*
*        ASSIGN current_obj->(`IF_XCO_CP_STD_CURRENT~CALL_STACK`) TO <call_stack>.
*        stack = <call_stack>.
*
*        CALL METHOD stack->(`IF_XCO_CP_STD_CUR_API_CLL_STCK~FULL`)
*          RECEIVING
*            ro_full = full_stack.
*
*        DATA r TYPE REF TO data.
*        CREATE DATA r TYPE REF TO (`IF_XCO_CS_FORMAT`).
*        ASSIGN r->* TO <any>.
*        <any> ?= format_source.
*
*        CALL METHOD full_stack->(`IF_XCO_CP_CALL_STACK~AS_TEXT`)
*          EXPORTING
*            io_format = <any>
*          RECEIVING
*            ro_text   = text_obj.
*
*        CALL METHOD text_obj->(`IF_XCO_TEXT~GET_LINES`)
*          RECEIVING
*            ro_lines = ro_lines.
*
*        FIELD-SYMBOLS <lt_lines> TYPE string_table.
*        ASSIGN ro_lines->(`IF_XCO_STRINGS~VALUE`) TO <lt_lines>.
*
*      CATCH cx_root INTO DATA(x).
*        "TODO ABAP Standard
*    ENDTRY.
*
*    DELETE <lt_lines> INDEX 1.
*
*    LOOP AT <lt_lines> INTO DATA(text).
*      DATA(ls_stack) = VALUE z2ui5_cl_util_abap=>ty_S_stack( ).
*      SPLIT text AT ` ` INTO ls_stack-class ls_stack-include ls_stack-method.
*      INSERT ls_stack INTO TABLE result.
*    ENDLOOP.

  ENDMETHOD.

  METHOD conv_get_xlsx_by_itab.

*    DATA(write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
*    DATA(worksheet) = write_access->get_workbook( )->worksheet->at_position( 1 ).
*    DATA(selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*    worksheet->select( selection_pattern
*               )->row_stream(
*               )->operation->write_from( REF #( val )
*               )->execute( ).
*    result = write_access->get_file_content( ).

  ENDMETHOD.

  METHOD conv_get_itab_by_xlsx.

*    CLEAR result.
*    DATA(document) = xco_cp_xlsx=>document->for_file_content( val )->read_access( ).
*    DATA(sheet) = document->get_workbook( )->worksheet->at_position( 1 ).
*    DATA(pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*    sheet->select( pattern
*            )->row_stream(
*            )->operation->write_to( REF #( result )
*            )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
*            )->execute( ).

  ENDMETHOD.

  METHOD bal_create.

    " Standard ABAP / on-premise: classic Business Application Log function modules.
    DATA lv_fm      TYPE string.
    DATA lr_log     TYPE REF TO data.
    DATA lr_handle  TYPE REF TO data.
    DATA lr_handles TYPE REF TO data.
    FIELD-SYMBOLS <log>     TYPE any.
    FIELD-SYMBOLS <handle>  TYPE any.
    FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <comp>    TYPE any.

    TRY.
        CREATE DATA lr_log TYPE ('BAL_S_LOG').
        ASSIGN lr_log->* TO <log>.
        ASSIGN COMPONENT `OBJECT` OF STRUCTURE <log> TO <comp>.
        <comp> = object.
        ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <log> TO <comp>.
        <comp> = subobject.
        ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <log> TO <comp>.
        <comp> = id.

        CREATE DATA lr_handle TYPE ('BALLOGHNDL').
        ASSIGN lr_handle->* TO <handle>.

        lv_fm = `BAL_LOG_CREATE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log      = <log>
          IMPORTING
            e_log_handle = <handle>
          EXCEPTIONS
            OTHERS       = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        bal_msg_add( handle = <handle>
                     t_log  = t_log ).

        CREATE DATA lr_handles TYPE ('BAL_T_LOGH').
        ASSIGN lr_handles->* TO <handles>.
        INSERT <handle> INTO TABLE <handles>.

        lv_fm = `BAL_DB_SAVE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_t_log_handle = <handles>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_root INTO DATA(lx_create).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lx_create.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_read.

    DATA lv_fm      TYPE string.
    DATA lr_handles TYPE REF TO data.
    DATA lr_single  TYPE REF TO data.
    DATA lr_msgh    TYPE REF TO data.
    DATA lr_msg     TYPE REF TO data.
    FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <handle>  TYPE any.
    FIELD-SYMBOLS <single>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <msgh>    TYPE STANDARD TABLE.
    FIELD-SYMBOLS <mh>      TYPE any.
    FIELD-SYMBOLS <msg>     TYPE any.

    TRY.
        lr_handles = bal_load_handles( object    = object
                                       subobject = subobject
                                       id        = id ).
        IF lr_handles IS NOT BOUND.
          RETURN.
        ENDIF.
        ASSIGN lr_handles->* TO <handles>.

        CREATE DATA lr_single TYPE ('BAL_T_LOGH').
        ASSIGN lr_single->* TO <single>.
        CREATE DATA lr_msgh TYPE ('BAL_T_MSGH').
        ASSIGN lr_msgh->* TO <msgh>.
        CREATE DATA lr_msg TYPE ('BAL_S_MSG').
        ASSIGN lr_msg->* TO <msg>.

        LOOP AT <handles> ASSIGNING <handle>.

          CLEAR <single>.
          INSERT <handle> INTO TABLE <single>.

          CLEAR <msgh>.
          lv_fm = `BAL_GLB_SEARCH_MSG`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_t_log_handle = <single>
            IMPORTING
              e_t_msg_handle = <msgh>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          LOOP AT <msgh> ASSIGNING <mh>.
            CLEAR <msg>.
            lv_fm = `BAL_LOG_MSG_READ`.
            CALL FUNCTION lv_fm
              EXPORTING
                i_s_msg_handle = <mh>
              IMPORTING
                e_s_msg        = <msg>
              EXCEPTIONS
                OTHERS         = 1.
            IF sy-subrc = 0.
              INSERT bal_map_msg( <msg> ) INTO TABLE result.
            ENDIF.
          ENDLOOP.

        ENDLOOP.

      CATCH cx_root INTO DATA(lx_read).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lx_read.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_update.

    " Append the given messages to an already persisted log; create a new one if none exists.
    DATA lv_fm      TYPE string.
    DATA lr_handles TYPE REF TO data.
    FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <handle>  TYPE any.

    TRY.
        lr_handles = bal_load_handles( object    = object
                                       subobject = subobject
                                       id        = id ).
        IF lr_handles IS NOT BOUND.
          bal_create( object    = object
                      subobject = subobject
                      id        = id
                      t_log     = t_log ).
          RETURN.
        ENDIF.

        ASSIGN lr_handles->* TO <handles>.
        IF <handles> IS INITIAL.
          bal_create( object    = object
                      subobject = subobject
                      id        = id
                      t_log     = t_log ).
          RETURN.
        ENDIF.

        ASSIGN <handles>[ 1 ] TO <handle>.
        bal_msg_add( handle = <handle>
                     t_log  = t_log ).

        lv_fm = `BAL_DB_SAVE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_t_log_handle = <handles>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_root INTO DATA(lx_update).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lx_update.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_delete.

    DATA lv_fm     TYPE string.
    DATA lr_filter TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.

    TRY.
        lr_filter = bal_build_filter( object    = object
                                      subobject = subobject
                                      id        = id ).
        ASSIGN lr_filter->* TO <filter>.

        lv_fm = `BAL_DB_DELETE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log_filter = <filter>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_root INTO DATA(lx_delete).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lx_delete.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_msg_add.

    DATA lv_fm    TYPE string.
    DATA lr_msg   TYPE REF TO data.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_text  TYPE c LENGTH 200.
    FIELD-SYMBOLS <msg>  TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.

    LOOP AT t_log INTO DATA(ls_log).

      IF ls_log-id IS NOT INITIAL AND ls_log-no IS NOT INITIAL.

        CREATE DATA lr_msg TYPE ('BAL_S_MSG').
        ASSIGN lr_msg->* TO <msg>.
        ASSIGN COMPONENT `MSGTY` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-type.
        ASSIGN COMPONENT `MSGID` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-id.
        ASSIGN COMPONENT `MSGNO` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-no.
        ASSIGN COMPONENT `MSGV1` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v1.
        ASSIGN COMPONENT `MSGV2` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v2.
        ASSIGN COMPONENT `MSGV3` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v3.
        ASSIGN COMPONENT `MSGV4` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v4.

        lv_fm = `BAL_LOG_MSG_ADD`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_log_handle = handle
            i_s_msg      = <msg>
          EXCEPTIONS
            OTHERS       = 1.

      ELSE.

        lv_msgty = ls_log-type.
        lv_text  = ls_log-text.
        lv_fm    = `BAL_LOG_MSG_ADD_FREE_TEXT`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_log_handle = handle
            i_msgty      = lv_msgty
            i_text       = lv_text
          EXCEPTIONS
            OTHERS       = 1.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD bal_load_handles.

    DATA lv_fm      TYPE string.
    DATA lr_filter  TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter>  TYPE any.
    FIELD-SYMBOLS <headers> TYPE SORTED TABLE.
    FIELD-SYMBOLS <handles> TYPE SORTED TABLE.

    lr_filter = bal_build_filter( object    = object
                                  subobject = subobject
                                  id        = id ).
    ASSIGN lr_filter->* TO <filter>.

    CREATE DATA lr_headers TYPE ('BALHDR_T').
    ASSIGN lr_headers->* TO <headers>.

    lv_fm = `BAL_DB_SEARCH`.
    CALL FUNCTION lv_fm
      EXPORTING
        i_s_log_filter = <filter>
      IMPORTING
        e_t_log_header = <headers>
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0 OR <headers> IS INITIAL.
      RETURN.
    ENDIF.

    CREATE DATA result TYPE ('BAL_T_LOGH').
    ASSIGN result->* TO <handles>.

    lv_fm = `BAL_DB_LOAD`.
    CALL FUNCTION lv_fm
      EXPORTING
        i_t_log_header = <headers>
      IMPORTING
        e_t_log_handle = <handles>
      EXCEPTIONS
        OTHERS         = 1.

  ENDMETHOD.

  METHOD bal_build_filter.

    FIELD-SYMBOLS <filter> TYPE any.

    CREATE DATA result TYPE ('BAL_S_LFIL').
    ASSIGN result->* TO <filter>.

    bal_filter_add( EXPORTING comp   = `OBJECT`
                              value  = object
                    CHANGING  filter = <filter> ).
    bal_filter_add( EXPORTING comp   = `SUBOBJECT`
                              value  = subobject
                    CHANGING  filter = <filter> ).
    bal_filter_add( EXPORTING comp   = `EXTNUMBER`
                              value  = id
                    CHANGING  filter = <filter> ).

  ENDMETHOD.

  METHOD bal_filter_add.

    DATA lr_line TYPE REF TO data.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <comp>  TYPE any.

    IF value IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT comp OF STRUCTURE filter TO <range>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CREATE DATA lr_line LIKE LINE OF <range>.
    ASSIGN lr_line->* TO <line>.
    ASSIGN COMPONENT `SIGN` OF STRUCTURE <line> TO <comp>.
    <comp> = `I`.
    ASSIGN COMPONENT `OPTION` OF STRUCTURE <line> TO <comp>.
    <comp> = `EQ`.
    ASSIGN COMPONENT `LOW` OF STRUCTURE <line> TO <comp>.
    <comp> = value.
    INSERT <line> INTO TABLE <range>.

  ENDMETHOD.

  METHOD bal_map_msg.

    DATA lv_fm   TYPE string.
    DATA lv_text TYPE c LENGTH 200.
    FIELD-SYMBOLS <comp> TYPE any.

    ASSIGN COMPONENT `MSGTY` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-type = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGID` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-id = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGNO` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-no = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV1` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v1 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV2` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v2 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV3` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v3 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV4` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v4 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `TIME_STMP` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-timestampl = <comp>.
    ENDIF.

    TRY.
        lv_fm = `MESSAGE_TEXT_BUILD`.
        CALL FUNCTION lv_fm
          EXPORTING
            msgid               = result-id
            msgnr               = result-no
            msgv1               = result-v1
            msgv2               = result-v2
            msgv3               = result-v3
            msgv4               = result-v4
          IMPORTING
            message_text_output = lv_text.
        result-text = lv_text.
      CATCH cx_root.
        result-text = result-v1.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_copy_objects.

    " Copy all objects/commands of a source request (and its tasks) into a
    " target request via the classic transport functions. Called dynamically
    " so the statement stays compilable on ABAP Cloud as well, even though the
    " function modules only exist on-premise.
    TRY.

        DATA lr_headers TYPE REF TO data.
        FIELD-SYMBOLS <headers> TYPE ANY TABLE.
        FIELD-SYMBOLS <header>  TYPE any.
        FIELD-SYMBOLS <trkorr>  TYPE any.
        FIELD-SYMBOLS <strkorr> TYPE any.
        DATA lv_fm TYPE string.

        CREATE DATA lr_headers TYPE (`TRWBO_REQUEST_HEADERS`).
        ASSIGN lr_headers->* TO <headers>.

        lv_fm = `TR_READ_REQUEST_WITH_TASKS`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_trkorr          = source
          IMPORTING
            et_request_headers = <headers>
          EXCEPTIONS
            invalid_input      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TR_READ_REQUEST_WITH_TASKS failed`.
        ENDIF.

        LOOP AT <headers> ASSIGNING <header>.

          ASSIGN COMPONENT `TRKORR`  OF STRUCTURE <header> TO <trkorr>.
          ASSIGN COMPONENT `STRKORR` OF STRUCTURE <header> TO <strkorr>.
          IF <trkorr> <> source AND <strkorr> <> source.
            CONTINUE.
          ENDIF.

          lv_fm = `TR_COPY_COMM`.
          CALL FUNCTION lv_fm
            EXPORTING
              wi_dialog                = abap_false
              wi_trkorr_from           = <trkorr>
              wi_trkorr_to             = destination
              wi_without_documentation = abap_false
            EXCEPTIONS
              OTHERS                   = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING
                val = `TR_COPY_COMM failed`.
          ENDIF.

        ENDLOOP.

      CATCH z2ui5_cx_util_error INTO DATA(lx_known).
        RAISE EXCEPTION lx_known.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_import.

    " Import a transport request into a target system via TMS. The target
    " system may be given as `SYSTEM` or `SYSTEM.CLIENT`; an explicit client
    " parameter takes precedence, otherwise the current client is used.
    TRY.

        DATA lv_system  TYPE c LENGTH 8.
        DATA lv_client  TYPE c LENGTH 3.
        DATA lv_retcode TYPE c LENGTH 4.
        DATA lr_exc     TYPE REF TO data.
        FIELD-SYMBOLS <exc> TYPE any.
        DATA lv_fm TYPE string.

        SPLIT target_system AT `.` INTO lv_system lv_client.
        IF lv_client IS INITIAL.
          IF client IS NOT INITIAL.
            lv_client = client.
          ELSE.
            lv_client = sy-mandt.
          ENDIF.
        ENDIF.

        CREATE DATA lr_exc TYPE (`STMSCALERT`).
        ASSIGN lr_exc->* TO <exc>.

        lv_fm = `TMS_MGR_REFRESH_IMPORT_QUEUES`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_system    = lv_system
            iv_monitor   = abap_true
            iv_verbose   = abap_true
          IMPORTING
            es_exception = <exc>
          EXCEPTIONS
            OTHERS       = 99.
        IF sy-subrc = 99.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TMS_MGR_REFRESH_IMPORT_QUEUES failed`.
        ENDIF.

        lv_fm = `TMS_MGR_IMPORT_TR_REQUEST`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_system                  = lv_system
            iv_request                 = trkorr
            iv_client                  = lv_client
            iv_ignore_cvers            = ignore_version
          IMPORTING
            ev_tp_ret_code             = lv_retcode
          EXCEPTIONS
            read_config_failed         = 1
            table_of_requests_is_empty = 2
            OTHERS                     = 3.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TMS_MGR_IMPORT_TR_REQUEST failed`.
        ENDIF.

        result = lv_retcode.

      CATCH z2ui5_cx_util_error INTO DATA(lx_known).
        RAISE EXCEPTION lx_known.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_check_status.

    " Read the import status (imported flag + return code) of a request in a
    " given system via the classic transport log API.
    TRY.

        DATA lr_settings TYPE REF TO data.
        DATA lr_cofile   TYPE REF TO data.
        DATA lr_sysline  TYPE REF TO data.
        FIELD-SYMBOLS <settings> TYPE any.
        FIELD-SYMBOLS <systems>  TYPE ANY TABLE.
        FIELD-SYMBOLS <sysline>  TYPE any.
        FIELD-SYMBOLS <cofile>   TYPE any.
        FIELD-SYMBOLS <comp>     TYPE any.
        DATA lv_fm TYPE string.

        CREATE DATA lr_settings TYPE (`CTSLG_SETTINGS`).
        ASSIGN lr_settings->* TO <settings>.
        ASSIGN COMPONENT `SYSTEMS` OF STRUCTURE <settings> TO <systems>.

        CREATE DATA lr_sysline LIKE LINE OF <systems>.
        ASSIGN lr_sysline->* TO <sysline>.
        <sysline> = system.
        INSERT <sysline> INTO TABLE <systems>.

        CREATE DATA lr_cofile TYPE (`CTSLG_COFILE`).
        ASSIGN lr_cofile->* TO <cofile>.

        lv_fm = `TR_READ_GLOBAL_INFO_OF_REQUEST`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_trkorr   = trkorr
            is_settings = <settings>
          IMPORTING
            es_cofile   = <cofile>.

        ASSIGN COMPONENT `EXISTS` OF STRUCTURE <cofile> TO <comp>.
        IF <comp> = abap_false.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `request does not exist in target system`.
        ENDIF.

        ASSIGN COMPONENT `IMPORTED` OF STRUCTURE <cofile> TO <comp>.
        imported = <comp>.
        ASSIGN COMPONENT `RC` OF STRUCTURE <cofile> TO <comp>.
        rc = <comp>.

      CATCH z2ui5_cx_util_error INTO DATA(lx_known).
        RAISE EXCEPTION lx_known.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
