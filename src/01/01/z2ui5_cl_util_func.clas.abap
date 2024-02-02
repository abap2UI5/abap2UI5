CLASS z2ui5_cl_util_func DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.
    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH EMPTY KEY.

    TYPES ty_t_range TYPE RANGE OF string.
    TYPES ty_s_range TYPE LINE OF ty_t_range.

    TYPES:
      BEGIN OF ty_s_sql_multi,
        name    TYPE string,
        t_range TYPE ty_t_range,
        t_token TYPE ty_t_token,
      END OF ty_s_sql_multi.
    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_sql_multi WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_sql_result,
        table TYPE string,
      END OF ty_s_sql_result.

    TYPES:
      BEGIN OF ty_data_element_texts,
        header TYPE string,
        short  TYPE string,
        medium TYPE string,
        long   TYPE string,
      END OF ty_data_element_texts.

    CLASS-METHODS itab_get_itab_by_csv
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS itab_get_csv_by_itab
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS db_save
      IMPORTING
        uname         TYPE clike OPTIONAL
        handle        TYPE clike OPTIONAL
        handle2       TYPE clike OPTIONAL
        handle3       TYPE clike OPTIONAL
        data          TYPE any
        check_commit  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS db_load_by_id
      IMPORTING
        id            TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    CLASS-METHODS db_load_by_handle
      IMPORTING
        uname         TYPE clike OPTIONAL
        handle        TYPE clike OPTIONAL
        handle2       TYPE clike OPTIONAL
        handle3       TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    CLASS-METHODS source_get_method
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_get_multi_by_data
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS sql_get_by_string
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_sql_result.

    CLASS-METHODS app_get_url_source_code
      IMPORTING
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url
      IMPORTING
        !client          TYPE REF TO z2ui5_if_client
        VALUE(classname) TYPE string OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    CLASS-METHODS url_param_get
      IMPORTING
        !val          TYPE string
        !url          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        !t_params     TYPE z2ui5_if_client=>ty_t_name_value
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_set
      IMPORTING
        !url          TYPE string
        !name         TYPE string
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        !in           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS x_check_raise
      IMPORTING
        !v    TYPE clike DEFAULT `CX_SY_SUBRC`
        !when TYPE xfeld.

    CLASS-METHODS x_raise
      IMPORTING
        !v TYPE clike DEFAULT `CX_SY_SUBRC`
          PREFERRED PARAMETER v.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS user_get_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_json_by_any
      IMPORTING
        !any           TYPE any
        !pretty_mode   TYPE clike DEFAULT z2ui5_if_client=>cs_pretty_mode-none
        !compress_mode TYPE clike DEFAULT z2ui5_if_client=>cs_compress_mode-standard
      RETURNING
        VALUE(result)  TYPE string.

    CLASS-METHODS trans_xml_2_any
      IMPORTING
        !xml TYPE clike
      EXPORTING
        !any TYPE any.

    CLASS-METHODS trans_xml_by_any
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    CLASS-METHODS boolean_check_by_data
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_abap_2_json
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_replace_assign_struc
      IMPORTING
        !iv_attri       TYPE clike
      RETURNING
        VALUE(rv_attri) TYPE string.

    CLASS-METHODS trans_json_2_any
      IMPORTING
        !val  TYPE any
      CHANGING
        !data TYPE any.

    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING
        !ir_tab_from TYPE REF TO data
        pretty_name  TYPE abap_bool DEFAULT abap_false
      EXPORTING
        !t_result    TYPE STANDARD TABLE.

    CLASS-METHODS trans_ref_struc_2_struc
      IMPORTING
        !ir_struc_from TYPE REF TO data
        pretty_name    TYPE abap_bool DEFAULT abap_false
      EXPORTING
        !r_result      TYPE data.

    CLASS-METHODS c_trim_upper
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_srtti_xml_by_data
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_srtti_xml_2_data
      IMPORTING
        !rtti_data TYPE clike
      EXPORTING
        !e_data    TYPE REF TO data.

    CLASS-METHODS time_get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_substract_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS c_trim
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_trim_lower
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_get_tab
      IMPORTING
        !i_val           TYPE clike
      RETURNING
        VALUE(rt_params) TYPE z2ui5_if_client=>ty_t_name_value.

    CLASS-METHODS rtti_get_t_attri_by_object
      IMPORTING
        !val          TYPE REF TO object
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    CLASS-METHODS rtti_get_t_comp_by_data
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_type_name
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_lang_version_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_check_class_exists
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_check_type_kind_dref
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_ref_data
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_check_by_name
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS filter_get_range_t_by_token_t
      IMPORTING
        val           TYPE ty_t_token
      RETURNING
        VALUE(result) TYPE ty_t_range.

    CLASS-METHODS filter_get_range_by_token
      IMPORTING
        VALUE(value)  TYPE string
      RETURNING
        VALUE(result) TYPE ty_s_range.

    CLASS-METHODS filter_get_token_t_by_range_t
      IMPORTING
        val           TYPE ty_t_range
      RETURNING
        VALUE(result) TYPE ty_t_token.

    CLASS-METHODS filter_get_token_range_mapping
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_t_name_value.

    CLASS-METHODS itab_filter_by_val
      IMPORTING
        val TYPE clike
      CHANGING
        tab TYPE STANDARD TABLE.

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

    CLASS-METHODS time_get_time_by_stampl
      IMPORTING
        val           TYPE timestampl
      RETURNING
        VALUE(result) TYPE t.

    CLASS-METHODS time_get_date_by_stampl
      IMPORTING
        val           TYPE timestampl
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS conv_copy_ref_data
      IMPORTING
        from          TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS source_get_file_types
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS source_method_to_file
      IMPORTING
        it_source     TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        i_data_element_name TYPE string
      RETURNING
        VALUE(result)       TYPE ty_data_element_texts.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util_func IMPLEMENTATION.


  METHOD app_get_url.

    IF classname IS INITIAL.
      classname = rtti_get_classname_by_ref( client->get( )-s_draft-app ).
    ENDIF.

    DATA(lv_url) = to_lower( client->get( )-s_config-origin && client->get( )-s_config-pathname ) && `?`.
    DATA(lt_param) = url_param_get_tab( client->get( )-s_config-search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start` v = to_lower( classname ) ) INTO TABLE lt_param.

    result = lv_url && url_param_create_url( lt_param ).

  ENDMETHOD.


  METHOD app_get_url_source_code.

    DATA(ls_draft) = client->get( )-s_draft.
    DATA(ls_config) = client->get( )-s_config.

    result = ls_config-origin && `/sap/bc/adt/oo/classes/`
       && rtti_get_classname_by_ref( ls_draft-app ) && `/source/main`.

  ENDMETHOD.


  METHOD boolean_abap_2_json.

    IF boolean_check_by_data( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD boolean_check_by_data.

    TRY.
        DATA(lv_type_name) = rtti_get_type_name( val ).
        result = boolean_check_by_name( lv_type_name ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD boolean_check_by_name.

    CASE val.
      WHEN 'ABAP_BOOL'
          OR 'XSDBOOLEAN'
          OR 'FLAG'
          OR 'XFLAG'
          OR 'XFELD'
          OR 'ABAP_BOOLEAN'
          OR 'WDY_BOOLEAN'
          OR 'OS_BOOLEAN'.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD conv_copy_ref_data.

    FIELD-SYMBOLS <from> TYPE data.
    FIELD-SYMBOLS <result> TYPE data.

    IF rtti_check_ref_data( from ).
      ASSIGN from->* TO <from>.
    ELSE.
      ASSIGN from TO <from>.
    ENDIF.
    CREATE DATA result LIKE <from>.
    ASSIGN result->* TO <result>.

    <result> = <from>.

  ENDMETHOD.


  METHOD conv_decode_x_base64.

    TRY.

        CALL METHOD ('CL_WEB_HTTP_UTILITY')=>('DECODE_X_BASE64')
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

      CATCH cx_sy_dyn_call_illegal_class.

        DATA(classname) = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>('DECODE_X_BASE64')
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

    ENDTRY.

  ENDMETHOD.


  METHOD conv_encode_x_base64.

    TRY.

        CALL METHOD ('CL_WEB_HTTP_UTILITY')=>('ENCODE_X_BASE64')
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

      CATCH cx_sy_dyn_call_illegal_class.

        DATA(classname) = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>('ENCODE_X_BASE64')
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

    ENDTRY.

  ENDMETHOD.


  METHOD conv_get_string_by_xstring.

    DATA conv TYPE REF TO object.

    TRY.
        CALL METHOD ('CL_ABAP_CONV_CODEPAGE')=>create_in
          RECEIVING
            instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_IN~CONVERT')
          EXPORTING
            source = val
          RECEIVING
            result = result.
      CATCH cx_sy_dyn_call_illegal_class.

        DATA(conv_in_class) = 'CL_ABAP_CONV_IN_CE'.
        CALL METHOD (conv_in_class)=>create
          EXPORTING
            encoding = 'UTF-8'
          RECEIVING
            conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING
            input = val
          IMPORTING
            data  = result.
    ENDTRY.

  ENDMETHOD.


  METHOD conv_get_xstring_by_string.

    DATA conv TYPE REF TO object.

    TRY.
        CALL METHOD ('CL_ABAP_CONV_CODEPAGE')=>create_out
          RECEIVING
            instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_OUT~CONVERT')
          EXPORTING
            source = val
          RECEIVING
            result = result.
      CATCH cx_sy_dyn_call_illegal_class.

        DATA(conv_out_class) = 'CL_ABAP_CONV_OUT_CE'.
        CALL METHOD (conv_out_class)=>create
          EXPORTING
            encoding = 'UTF-8'
          RECEIVING
            conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING
            data   = val
          IMPORTING
            buffer = result.
    ENDTRY.

  ENDMETHOD.


  METHOD c_replace_assign_struc.

    rv_attri  = iv_attri.
    DATA(lv_length) = strlen( rv_attri ) - 2.
    DATA(lv_attri_end) = rv_attri+lv_length.

    IF lv_attri_end = `>*`.
      lv_attri_end = `>`.
      lv_length = lv_length.
    ELSE.
      lv_attri_end = `-`.
      lv_length = lv_length + 2.
    ENDIF.
    rv_attri = rv_attri(lv_length) && lv_attri_end.

  ENDMETHOD.


  METHOD c_trim.

    result = shift_left( shift_right( CONV string( val ) ) ).
    result = shift_right( val = result
                          sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result
                         sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    result = to_lower( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    result = to_upper( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD db_load_by_handle.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_fw_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_fw_02
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.

    DATA(ls_db) = lt_db[ 1 ].

    trans_xml_2_any(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_fw_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_fw_02
      WHERE id = @id
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.

    DATA(ls_db) = lt_db[ 1 ].

    trans_xml_2_any(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_save.

    DATA(ls_db) = VALUE z2ui5_t_fw_02(
        id      = uuid_get_c32( )
        uname   = uname
        handle  = handle
        handle2 = handle2
        handle3 = handle3
        data    = trans_xml_by_any( data ) ).

    MODIFY z2ui5_t_fw_02 FROM @ls_db.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.


  METHOD filter_get_multi_by_data.

    LOOP AT rtti_get_t_comp_by_data( val ) REFERENCE INTO DATA(lr_comp).
      INSERT VALUE #( name = lr_comp->name ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_range_by_token.

    DATA(lv_length) = strlen( value ) - 1.
    CASE value(1).

      WHEN `=`.
        result = VALUE #( sign = `I` option = `EQ` low = value+1 ).
      WHEN `<`.
        IF value+1(1) = `=`.
          result = VALUE #( sign = `I` option = `LE` low = value+2 ).
        ELSE.
          result = VALUE #( sign = `I` option = `LT` low = value+1 ).
        ENDIF.
      WHEN `>`.
        IF value+1(1) = `=`.
          result = VALUE #( sign = `I` option = `GE` low = value+2 ).
        ELSE.
          result = VALUE #( sign = `I` option = `GT` low = value+1 ).
        ENDIF.

      WHEN `*`.
        IF value+lv_length(1) = `*`.
          SHIFT value RIGHT DELETING TRAILING `*`.
          SHIFT value LEFT DELETING LEADING `*`.
          result = VALUE #( sign = `I` option = `CP` low = value ).
        ENDIF.

      WHEN OTHERS.
        IF value CP `...`.
          SPLIT value AT `...` INTO result-low result-high.
          result-option = `BT`.
        ELSE.
          result = VALUE #( sign = `I` option = `EQ` low = value ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD filter_get_range_t_by_token_t.

    LOOP AT val INTO DATA(ls_token).
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_token_range_mapping.

    result = VALUE #(
      (   n = `EQ`     v = `={LOW}` )
      (   n = `LT`     v = `<{LOW}` )
      (   n = `LE`     v = `<={LOW}` )
      (   n = `GT`     v = `>{LOW}` )
      (   n = `GE`     v = `>={LOW}` )
      (   n = `CP`     v = `*{LOW}*` )
      (   n = `BT`     v = `{LOW}...{HIGH}` )
      (   n = `NE`     v = `!(={LOW})` )
      (   n = `NE`     v = `!(<leer>)` )
      (   n = `<leer>` v = `<leer>` ) ).

  ENDMETHOD.


  METHOD filter_get_token_t_by_range_t.

    DATA(lt_mapping) = filter_get_token_range_mapping( ).

    LOOP AT val REFERENCE INTO DATA(lr_row).

      DATA(lv_value) = lt_mapping[ n = lr_row->option ]-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      INSERT VALUE #( key = lv_value text = lv_value visible = abap_true editable = abap_true ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_filter_by_val.

    FIELD-SYMBOLS <row> TYPE any.

    LOOP AT tab ASSIGNING <row>.
      DATA(lv_row) = ``.
      DATA(lv_index) = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_row = lv_row && <field>.
        lv_index = lv_index + 1.
      ENDDO.

      IF lv_row NS val.
        DELETE tab.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_get_csv_by_itab.

    FIELD-SYMBOLS <tab> TYPE table.

    ASSIGN val TO <tab>.



    DATA(tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <tab> ) ).

    DATA(struc) = CAST cl_abap_structdescr( tab->get_table_line_type( ) ).

    LOOP AT struc->get_components( ) REFERENCE INTO DATA(lr_comp).
      result = result && lr_comp->name && ';'.
    ENDLOOP.

    result = result && cl_abap_char_utilities=>cr_lf.

    DATA lr_row TYPE REF TO data.
    LOOP AT <tab> REFERENCE INTO lr_row.

      DATA(lv_index) = 1.
      DO.
        ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        result = result && <field> && ';'.
      ENDDO.
      result = result && cl_abap_char_utilities=>cr_lf.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_get_itab_by_csv.
    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.

    SPLIT val AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_rows).
    SPLIT lt_rows[ 1 ] AT ';' INTO TABLE DATA(lt_cols).


    LOOP AT lt_cols REFERENCE INTO DATA(lr_col).

      DATA(lv_name) = c_trim_upper( lr_col->* ).
      REPLACE ` ` IN lv_name WITH `_`.

      INSERT VALUE #( name = lv_name type = cl_abap_elemdescr=>get_c( 40 ) ) INTO TABLE lt_comp.
    ENDLOOP.

    DATA(struc) = cl_abap_structdescr=>get( lt_comp ).
    DATA(o_table_desc) = cl_abap_tabledescr=>create(
          p_line_type  = CAST #( struc )
          p_table_kind = cl_abap_tabledescr=>tablekind_std
          p_unique     = abap_false ).

    CREATE DATA result TYPE HANDLE o_table_desc.

    ASSIGN result->* TO <tab>.

    DELETE lt_rows WHERE table_line IS INITIAL.

    LOOP AT lt_rows REFERENCE INTO DATA(lr_rows) FROM 2.

      SPLIT lr_rows->* AT ';' INTO TABLE lt_cols.

      CREATE DATA lr_row TYPE HANDLE struc.

      LOOP AT lt_cols REFERENCE INTO lr_col.
        ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
        ASSIGN COMPONENT sy-tabix OF STRUCTURE <row> TO FIELD-SYMBOL(<field>).
        <field> = lr_col->*.
      ENDLOOP.

      INSERT <row> INTO TABLE <tab>.
    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_check_class_exists.

    cl_abap_classdescr=>describe_by_name(
       EXPORTING
           p_name      = val
       EXCEPTIONS
        type_not_found = 1 ).
    IF sy-subrc = 0.
      result = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_check_lang_version_cloud.

    TRY.
        cl_abap_typedescr=>describe_by_name( 'T100' ).
        result = abap_false.
      CATCH cx_root.
        result = abap_true.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_ref_data.

    TRY.
        cl_abap_typedescr=>describe_by_data_ref( val ).
        result = abap_true.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_check_type_kind_dref.

    DATA(lv_type_kind) = cl_abap_datadescr=>get_data_type_kind( val ).
    result = xsdbool( lv_type_kind = cl_abap_typedescr=>typekind_dref ).

  ENDMETHOD.


  METHOD rtti_get_classes_impl_intf.
    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    TYPES BEGIN OF ty_s_impl.
    TYPES clsname TYPE c LENGTH 30.
    TYPES refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
    TYPES BEGIN OF ty_s_key.
    TYPES intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.

    TRY.


        CALL METHOD ('XCO_CP_ABAP')=>interface
          EXPORTING
            iv_name      = val
          RECEIVING
            ro_interface = obj.


        ASSIGN obj->('IF_XCO_AO_INTERFACE~IMPLEMENTATIONS') TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        ASSIGN obj->('IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL') TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET').


        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES')
          RECEIVING
            rt_names = lt_implementation_names.

        result = lt_implementation_names.

      CATCH cx_sy_dyn_call_illegal_class.






        ls_key-intkey = val.

        DATA(lv_fm) = `SEO_INTERFACE_IMPLEM_GET_ALL`.
        CALL FUNCTION lv_fm
          EXPORTING
            intkey       = ls_key
          IMPORTING
            impkeys      = lt_impl
          EXCEPTIONS
            not_existing = 1
            OTHERS       = 2.

        LOOP AT lt_impl REFERENCE INTO DATA(lr_impl).
          INSERT CONV #( lr_impl->clsname ) INTO TABLE result.
        ENDLOOP.

    ENDTRY.

  ENDMETHOD.


  METHOD rtti_get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.

    DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).
    DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
    result  = lo_ele->get_relative_name( ).

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_object.

    DATA(lo_obj_ref) = cl_abap_objectdescr=>describe_by_object_ref( val ).
    result   = CAST cl_abap_classdescr( lo_obj_ref )->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_comp_by_data.

    TRY.
        DATA(lo_type) = cl_abap_typedescr=>describe_by_data( val ).
        DATA(lo_struct) = CAST cl_abap_structdescr( lo_type ).
      CATCH cx_root.
        TRY.
            DATA(lo_tab) = CAST cl_abap_tabledescr( lo_type ).
            lo_struct = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
          CATCH cx_root.
            TRY.
                DATA(lo_ref) = cl_abap_typedescr=>describe_by_data_ref( val ).
                lo_struct = CAST cl_abap_structdescr( lo_ref ).
              CATCH cx_root.
                lo_tab = CAST cl_abap_tabledescr( lo_ref ).
                lo_struct = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
            ENDTRY.
        ENDTRY.
    ENDTRY.

    result = lo_struct->get_components( ).

  ENDMETHOD.


  METHOD source_get_file_types.

    DATA(lv_types) = `abap, abc, actionscript, ada, apache_conf, applescript, asciidoc, assembly_x86, autohotkey, batchfile, bro, c9search, c_cpp, cirru, clojure, cobol, coffee, coldfusion, csharp, css, curly, d, dart, diff, django, dockerfile, ` &&
`dot, drools, eiffel, yaml, ejs, elixir, elm, erlang, forth, fortran, ftl, gcode, gherkin, gitignore, glsl, gobstones, golang, groovy, haml, handlebars, haskell, haskell_cabal, haxe, hjson, html, html_elixir, html_ruby, ini, io, jack, jade, java, ja` &&
      `vascri` &&
`pt, json, jsoniq, jsp, jsx, julia, kotlin, latex, lean, less, liquid, lisp, live_script, livescript, logiql, lsl, lua, luapage, lucene, makefile, markdown, mask, matlab, mavens_mate_log, maze, mel, mips_assembler, mipsassembler, mushcode, mysql, ni` &&
`x, nsis, objectivec, ocaml, pascal, perl, pgsql, php, plain_text, powershell, praat, prolog, properties, protobuf, python, r, razor, rdoc, rhtml, rst, ruby, rust, sass, scad, scala, scheme, scss, sh, sjs, smarty, snippets, soy_template, space, sql,` &&
      ` sqlserver, stylus, svg, swift, swig, tcl, tex, text, textile, toml, tsx, twig, typescript, vala, vbscript, velocity, verilog, vhdl, wollok, xml, xquery, terraform, slim, redshift, red, puppet, php_laravel_blade, mixal, jssm, fsharp, edifact,` &&
      ` csp, cssound_score, cssound_orchestra, cssound_document`.
    SPLIT lv_types AT ',' INTO TABLE result.

  ENDMETHOD.


  METHOD source_get_method.
    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_source TYPE string_table.
    DATA lt_string TYPE string_table.



    TRY.


        DATA(lv_class)  = to_upper( iv_classname ).
        DATA(lv_method) = to_upper( iv_methodname ).

        CALL METHOD ('XCO_CP_ABAP')=>('CLASS')
          EXPORTING
            iv_name  = lv_class
          RECEIVING
            ro_class = object.

        ASSIGN ('OBJECT->IF_XCO_AO_CLASS~IMPLEMENTATION') TO <any>.
        object = <any>.

        CALL METHOD object->('IF_XCO_CLAS_IMPLEMENTATION~METHOD')
          EXPORTING
            iv_name   = lv_method
          RECEIVING
            ro_method = object.

        CALL METHOD object->('IF_XCO_CLAS_I_METHOD~CONTENT')
          RECEIVING
            ro_content = object.

        CALL METHOD object->('IF_XCO_CLAS_I_METHOD_CONTENT~GET_SOURCE')
          RECEIVING
            rt_source = result.

      CATCH cx_sy_dyn_call_error.

        DATA(lv_name) = 'CL_OO_FACTORY'.
        CALL METHOD (lv_name)=>('CREATE_INSTANCE')
          RECEIVING
            result = object.

        CALL METHOD object->('IF_OO_CLIF_SOURCE_FACTORY~CREATE_CLIF_SOURCE')
          EXPORTING
            clif_name = lv_class
          RECEIVING
            result    = object.

        CALL METHOD object->('IF_OO_CLIF_SOURCE~GET_SOURCE')
          IMPORTING
            source = lt_source.

        DATA(lv_check_method) = abap_false.
        LOOP AT lt_source INTO DATA(lv_source).
          DATA(lv_source_upper) = to_upper( lv_source ).

          IF lv_source_upper CS `ENDMETHOD`.
            lv_check_method = abap_false.
          ENDIF.

          IF lv_source_upper CS `METHOD ` && lv_method.
            lv_check_method = abap_true.
            CONTINUE.
          ENDIF.

          IF lv_check_method = abap_true.
            INSERT lv_source INTO TABLE lt_string.
          ENDIF.

        ENDLOOP.

    ENDTRY.

    result = source_method_to_file( lt_string ).

  ENDMETHOD.


  METHOD source_method_to_file.

    LOOP AT it_source INTO DATA(lv_source).
      TRY.
          result = result && lv_source+1 && cl_abap_char_utilities=>newline.
        CATCH cx_root.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD sql_get_by_string.

    DATA(lv_sql) = CONV string( val ).
    REPLACE ALL OCCURRENCES OF ` ` IN lv_sql  WITH ``.
    lv_sql = to_upper( lv_sql ).
    SPLIT lv_sql AT 'SELECTFROM' INTO DATA(lv_dummy) DATA(lv_tab).
    SPLIT lv_tab AT `FIELDS` INTO lv_tab lv_dummy.

    result-table = lv_tab.

  ENDMETHOD.


  METHOD time_get_date_by_stampl.

    CONVERT TIME STAMP val TIME ZONE sy-zonlo INTO DATE result TIME DATA(lv_dummy).

  ENDMETHOD.


  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD time_get_time_by_stampl.

    CONVERT TIME STAMP val TIME ZONE sy-zonlo INTO DATE DATA(lv_dummy) TIME result.

  ENDMETHOD.


  METHOD time_substract_seconds.
    result = cl_abap_tstmp=>subtractsecs( tstmp = time
                                          secs  = seconds ).
  ENDMETHOD.


  METHOD trans_json_2_any.

*    IF z2ui5_cl_fw_controller=>cv_check_ajson = abap_true.
*      ASSERT 1 = 0.
*    ENDIF.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( val )
            assoc_arrays = abap_true
        CHANGING
            data         = data ).

  ENDMETHOD.


  METHOD trans_json_by_any.

*    IF z2ui5_cl_fw_controller=>cv_check_ajson = abap_true.
*      ASSERT 1 = 0.
*    ENDIF.

    CASE compress_mode.

      WHEN z2ui5_if_client=>cs_compress_mode-full.

        result = /ui2/cl_json=>serialize(
          data        = any
          compress    = abap_true
          pretty_name = pretty_mode ).

      WHEN z2ui5_if_client=>cs_compress_mode-none.

        result = /ui2/cl_json=>serialize(
          data        = any
          compress    = abap_false
          pretty_name = pretty_mode ).

      WHEN OTHERS.

        DATA(lo_json) = NEW z2ui5_cl_util_ui2_json(
          compress    = abap_true
          pretty_name = pretty_mode ).

        result = lo_json->serialize_int( any ).

    ENDCASE.

  ENDMETHOD.


  METHOD trans_ref_struc_2_struc.

    FIELD-SYMBOLS <ls_from> TYPE any.
    FIELD-SYMBOLS <comp_from_deref> TYPE any.

    ASSIGN ir_struc_from->* TO <ls_from>.
    x_check_raise( xsdbool( sy-subrc <> 0 ) ).
    CLEAR r_result.

    DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( r_result ) ).
    DATA(lt_components) = lo_struc->get_components( ).
    LOOP AT lt_components INTO DATA(ls_comp).

      DATA(lv_from) = ls_comp-name.
      IF pretty_name = abap_true.
        REPLACE ALL OCCURRENCES OF `_` IN lv_from WITH ``.
      ENDIF.
      ASSIGN COMPONENT lv_from OF STRUCTURE <ls_from> TO FIELD-SYMBOL(<comp_from>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE r_result TO FIELD-SYMBOL(<comp_to>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN <comp_from>->* TO <comp_from_deref>.
      DATA(lv_type_kind) = rtti_get_type_kind( <comp_to> ).

      IF <comp_from_deref> IS INITIAL.
        CONTINUE.
      ENDIF.

      CASE lv_type_kind.

        WHEN cl_abap_typedescr=>typekind_table.
          trans_ref_tab_2_tab(
            EXPORTING
             ir_tab_from = <comp_from>
             pretty_name = pretty_name
            IMPORTING
             t_result    = <comp_to> ).

        WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2.
          trans_ref_struc_2_struc(
            EXPORTING
                ir_struc_from = <comp_from>
                pretty_name   = pretty_name
            IMPORTING
                r_result      = <comp_to> ).

        WHEN OTHERS.
          <comp_to> = <comp_from_deref>.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.
    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.
    DATA lr_row TYPE REF TO data.
    FIELD-SYMBOLS <comp> TYPE data.
    FIELD-SYMBOLS <comp_ui5> TYPE data.
    DATA match TYPE i.

    ASSIGN ir_tab_from->* TO <lt_from>.
    x_check_raise( xsdbool( sy-subrc <> 0 ) ).
    CLEAR t_result.

    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( t_result ) ).
    IF lo_tab->absolute_name = `\TYPE=STRING_TABLE`.
      LOOP AT <lt_from> INTO DATA(lr_string).
        ASSIGN lr_string->* TO FIELD-SYMBOL(<row_string>).
        INSERT <row_string> INTO TABLE t_result.
      ENDLOOP.
      RETURN.
    ENDIF.
    DATA(lo_struc) = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
    DATA(lt_components) = lo_struc->get_components( ).

    LOOP AT <lt_from> INTO DATA(lr_from).


      CREATE DATA lr_row TYPE HANDLE lo_struc.
      ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      ASSIGN lr_from->* TO FIELD-SYMBOL(<row_ui5>).
      x_check_raise( xsdbool( sy-subrc <> 0 ) ).

      DATA(lt_components_dissolved) = lt_components.
      CLEAR lt_components_dissolved.

      LOOP AT lt_components INTO DATA(ls_comp).

        IF ls_comp-as_include = abap_false.
          APPEND ls_comp TO lt_components_dissolved.
        ELSE.
          DATA(struct) = CAST cl_abap_structdescr( ls_comp-type ).
          APPEND LINES OF struct->get_components( ) TO lt_components_dissolved.

        ENDIF.
      ENDLOOP.

      LOOP AT lt_components_dissolved INTO ls_comp.
        TRY.


            ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row> TO <comp>.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.


            IF pretty_name = abap_true.
              REPLACE ALL OCCURRENCES OF `_` IN ls_comp-name  WITH ``.
            ENDIF.
            ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row_ui5> TO <comp_ui5>.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            ASSIGN <comp_ui5>->* TO FIELD-SYMBOL(<ls_data_ui5>).

            IF sy-subrc = 0.
              CASE ls_comp-type->kind.
                WHEN cl_abap_typedescr=>kind_table.
                  trans_ref_tab_2_tab(
                    EXPORTING
                        ir_tab_from = <comp_ui5>
                        pretty_name = pretty_name
                    IMPORTING
                        t_result    = <comp> ).
                WHEN cl_abap_typedescr=>kind_struct.
                  trans_ref_struc_2_struc(
                    EXPORTING
                        ir_struc_from = <comp_ui5>
                        pretty_name   = pretty_name
                    IMPORTING
                        r_result      = <comp> ).
                WHEN cl_abap_typedescr=>kind_elem.
                  CASE ls_comp-type->absolute_name.
                    WHEN `\TYPE=D`.

                      " support for ISO8601 => https://en.wikipedia.org/wiki/ISO_8601
                      REPLACE FIRST OCCURRENCE OF REGEX `^(\d{4})-(\d{2})-(\d{2})` IN <ls_data_ui5> WITH `$1$2$3`
                        REPLACEMENT LENGTH match.           "#EC NOTEXT
                      <comp> = <ls_data_ui5>.

                    WHEN `\TYPE=T`.

                      " support for ISO8601 => https://en.wikipedia.org/wiki/ISO_8601
                      REPLACE FIRST OCCURRENCE OF REGEX `^(\d{2}):(\d{2}):(\d{2})` IN <ls_data_ui5> WITH `$1$2$3`
                        REPLACEMENT LENGTH match.           "#EC NOTEXT
                      <comp> = <ls_data_ui5>.

                    WHEN OTHERS.
                      <comp> = <ls_data_ui5>.
                  ENDCASE.
                WHEN OTHERS.
                  <comp> = <ls_data_ui5>.
              ENDCASE.
            ENDIF.

          CATCH cx_root.
        ENDTRY.
      ENDLOOP.

      INSERT <row> INTO TABLE t_result.
    ENDLOOP.

  ENDMETHOD.


  METHOD trans_srtti_xml_2_data.
    DATA srtti TYPE REF TO object.
    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.



    IF rtti_check_class_exists( 'ZCL_SRTTI_TYPEDESCR' ) = abap_false.

      DATA(lv_link) = `https://github.com/sandraros/S-RTTI`.
      DATA(lv_text) = `<p>Please install the open-source project S-RTTI by sandraros and try again: <a href="` &&
                       lv_link && `" style="color:blue; font-weight:600;" target="_blank">(link)</a></p>`.

      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = lv_text.

    ENDIF.


    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.


    CALL METHOD srtti->('GET_RTTI')
      RECEIVING
        rtti = rtti_type.


    lo_datadescr ?= rtti_type.

    CREATE DATA e_data TYPE HANDLE lo_datadescr.
    ASSIGN e_data->* TO FIELD-SYMBOL(<variable>).
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.



  ENDMETHOD.


  METHOD trans_srtti_xml_by_data.
    DATA srtti TYPE REF TO object.



    IF rtti_check_class_exists( 'ZCL_SRTTI_TYPEDESCR' ) = abap_false.

      DATA(lv_link) = `https://github.com/sandraros/S-RTTI`.
      DATA(lv_text) = `<p>Please install the open-source project S-RTTI by sandraros and try again: <a href="` &&
                       lv_link && `" style="color:blue; font-weight:600;" target="_blank">(link)</a></p>`.

      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = lv_text.

    ENDIF.



    CALL METHOD ('ZCL_SRTTI_TYPEDESCR')=>('CREATE_BY_DATA_OBJECT')
      EXPORTING
        data_object = data
      RECEIVING
        srtti       = srtti.

    CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.



  ENDMETHOD.


  METHOD trans_xml_2_any.

    CALL TRANSFORMATION id
        SOURCE XML xml
        RESULT data = any.

  ENDMETHOD.


  METHOD trans_xml_by_any.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD url_param_create_url.

    LOOP AT t_params INTO DATA(ls_param).
      result = result && ls_param-n && `=` && ls_param-v && `&`.
    ENDLOOP.
    result = shift_right( val = result
                          sub = `&` ).

  ENDMETHOD.


  METHOD url_param_get.

    DATA(lt_params) = url_param_get_tab( url ).
    DATA(lv_val) = c_trim_lower( val ).
    result = VALUE #( lt_params[ n = lv_val ]-v OPTIONAL ).

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA(lv_search) = replace( val  = i_val
                               sub  = `%3D`
                               with = '='
                               occ  = 0 ).
    lv_search = shift_left( val = lv_search
                            sub = `?` ).
    lv_search = c_trim_lower( lv_search ).

    DATA(lv_search2) = substring_after( val = lv_search
                                        sub = `&sap-startup-params=` ).
    lv_search = COND #( WHEN lv_search2 IS NOT INITIAL THEN lv_search2 ELSE lv_search ).

    lv_search2 = substring_after( val = c_trim_lower( lv_search )
                                  sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.

    SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).

    LOOP AT lt_param REFERENCE INTO DATA(lr_param).
      SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value).
      INSERT VALUE #( n = c_trim_lower( lv_name ) v = c_trim_lower( lv_value ) ) INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.


  METHOD url_param_set.

    DATA(lt_params) = url_param_get_tab( url ).
    DATA(lv_n) = c_trim_lower( name ).

    LOOP AT lt_params REFERENCE INTO DATA(lr_params)
        WHERE n = lv_n.
      lr_params->v = c_trim_lower( value ).
    ENDLOOP.
    IF sy-subrc <> 0.
      INSERT VALUE #( n = lv_n v = c_trim_lower( value ) ) INTO TABLE lt_params.
    ENDIF.

    result = url_param_create_url( lt_params ).

  ENDMETHOD.


  METHOD user_get_tech.
    result = sy-uname.
  ENDMETHOD.


  METHOD uuid_get_c22.
    DATA uuid TYPE c LENGTH 22.

    TRY.


        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>if_system_uuid_static~create_uuid_c22
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            DATA(lv_fm) = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_22 = uuid.

        ENDTRY.

        result = uuid.

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
    DATA uuid TYPE c LENGTH 32.

    TRY.


        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            DATA(lv_fm) = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

  ENDMETHOD.


  METHOD x_check_raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.
    ENDIF.

  ENDMETHOD.


  METHOD x_raise.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.

  ENDMETHOD.


  METHOD rtti_get_data_element_texts.

    DATA:
      data_element_name TYPE c LENGTH 30,
      ddic_ref          TYPE REF TO data,
      data_element      TYPE REF TO object,
      content           TYPE REF TO object,
      BEGIN OF ddic,
        reptext   TYPE string,
        scrtext_s TYPE string,
        scrtext_m TYPE string,
        scrtext_l TYPE string,
      END OF ddic,
      exists TYPE abap_bool.

    data_element_name = i_data_element_name.

    TRY.
        cl_abap_typedescr=>describe_by_name( 'T100' ).

        DATA(struct_desrc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( 'DFIES' ) ).

        CREATE DATA ddic_ref TYPE HANDLE struct_desrc.
        ASSIGN ddic_ref->* TO FIELD-SYMBOL(<ddic>).
        ASSERT sy-subrc = 0.

        DATA(data_descr) = CAST cl_abap_datadescr( cl_abap_elemdescr=>describe_by_name( data_element_name ) ).

        CALL METHOD data_descr->('GET_DDIC_FIELD')
          RECEIVING
            p_flddescr   = <ddic>
          EXCEPTIONS
            not_found    = 1
            no_ddic_type = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        ddic = CORRESPONDING #( <ddic> ).
        result-header = ddic-reptext.
        result-short  = ddic-scrtext_s.
        result-medium = ddic-scrtext_m.
        result-long   = ddic-scrtext_l.

      CATCH cx_root.
        CALL METHOD ('XCO_CP_ABAP_DICTIONARY')=>('DATA_ELEMENT')
          EXPORTING
            iv_name         = data_element_name
          RECEIVING
            ro_data_element = data_element.

        CALL METHOD data_element->('IF_XCO_AD_DATA_ELEMENT~EXISTS')
          RECEIVING
            rv_exists = exists.

        IF exists = abap_false.
          RETURN.
        ENDIF.

        CALL METHOD data_element->('IF_XCO_AD_DATA_ELEMENT~CONTENT')
          RECEIVING
            ro_content = content.

        CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL')
          RECEIVING
            rs_heading_field_label = result-header.

        CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL')
          RECEIVING
            rs_short_field_label = result-short.

        CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL')
          RECEIVING
            rs_medium_field_label = result-medium.

        CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL')
          RECEIVING
            rs_long_field_label = result-long.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
