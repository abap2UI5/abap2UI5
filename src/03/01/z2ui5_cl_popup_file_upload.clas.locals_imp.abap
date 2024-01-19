CLASS lcl_utility DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS factory
      IMPORTING
        client          TYPE REF TO z2ui5_if_client optional
      RETURNING
        VALUE(r_result) TYPE REF TO lcl_utility.

    METHODS app_get_url_source_code
      RETURNING
        VALUE(result) TYPE string.

    METHODS app_get_url
      IMPORTING
        classname TYPE string OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    METHODS url_param_get
      IMPORTING
        !val          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_xml_2_object
      IMPORTING
        xml  TYPE clike
      EXPORTING
        data TYPE data.

    CLASS-METHODS trans_data_2_xml
      IMPORTING
        data          TYPE data
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_table_by_json
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS get_table_by_xml
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS get_table_by_csv
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS get_csv_by_table
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_xml_by_table
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_json_by_table
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_fieldlist_by_table
      IMPORTING
        it_table      TYPE any
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS decode_x_base64
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS encode_x_base64
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_string_by_xstring
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_xstring_by_string
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trim_upper
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS boolean_check
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

            CLASS-METHODS rtti_get_type_name
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    DATA mi_client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.
ENDCLASS.



CLASS lcl_utility IMPLEMENTATION.

  METHOD rtti_get_type_name.

    DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).
    DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
    result  = lo_ele->get_relative_name( ).

  ENDMETHOD.

 METHOD boolean_check.

    TRY.
        DATA(lv_type_name) = rtti_get_type_name( val ).
        CASE lv_type_name.
          WHEN `ABAP_BOOL` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD factory.

    r_result = new #( ).
    r_result->mi_client = client.

  ENDMETHOD.

  METHOD app_get_url.

    result = z2ui5_cl_util_func=>app_get_url( classname = classname client = mi_client ).

  ENDMETHOD.


  METHOD app_get_url_source_code.

    result = z2ui5_cl_util_func=>app_get_url_source_code( mi_client ).

  ENDMETHOD.

  METHOD url_param_get.

    result = z2ui5_cl_util_func=>url_param_get(
      val = val
      url = mi_client->get( )-s_config-search ).

  ENDMETHOD.


  METHOD get_uuid.
    TRY.

        DATA uuid TYPE c LENGTH 32.

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

  METHOD get_table_by_json.

*    DATA lt_tab TYPE ty_t_table.
*

    DATA lt_tab TYPE REF TO data.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = val
*        jsonx            =
*        pretty_name      =
*        assoc_arrays     =
*        assoc_arrays_opt =
*        name_mappings    =
*        conversion_exits =
*        hex_as_base64    =
      CHANGING
        data             = lt_tab
    ).

    result = lt_tab.

  ENDMETHOD.


  METHOD trans_data_2_xml.

    " FIELD-SYMBOLS <object> TYPE any.
    "  ASSIGN object->* TO <object>.
    "  raise( when = xsdbool( sy-subrc <> 0 ) ).

    CALL TRANSFORMATION id
       SOURCE data = data
       RESULT XML result
        OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.

  METHOD trans_xml_2_object.

    CALL TRANSFORMATION id
       SOURCE XML xml
       RESULT data = data.

  ENDMETHOD.

  METHOD get_table_by_xml.

*    DATA lt_tab TYPE ty_t_table.
*
    CALL TRANSFORMATION id SOURCE xml = val RESULT data = result.
*
*    result = lt_tab.

  ENDMETHOD.

  METHOD get_table_by_csv.

    SPLIT val AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_rows).
    SPLIT lt_rows[ 1 ] AT ';' INTO TABLE DATA(lt_cols).

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    LOOP AT lt_cols REFERENCE INTO DATA(lr_col).

      DATA(lv_name) =  trim_upper( lr_col->* ).
      REPLACE ` ` IN lv_name WITH `_`.

      INSERT VALUE #( name = lv_name type = cl_abap_elemdescr=>get_c( 40 ) ) INTO TABLE lt_comp.
    ENDLOOP.

    DATA(struc) = cl_abap_structdescr=>get( lt_comp ).
    DATA(o_table_desc) = cl_abap_tabledescr=>create(
          p_line_type  = CAST #( struc )
          p_table_kind = cl_abap_tabledescr=>tablekind_std
          p_unique     = abap_false ).

    CREATE DATA result TYPE HANDLE o_table_desc.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN result->* TO <tab>.

    DELETE lt_rows WHERE table_line IS INITIAL.

    LOOP AT lt_rows REFERENCE INTO DATA(lr_rows) FROM 2.

      SPLIT lr_rows->* AT ';' INTO TABLE lt_cols.
      DATA lr_row TYPE REF TO data.
      CREATE DATA lr_row TYPE HANDLE struc.

      LOOP AT lt_cols REFERENCE INTO lr_col.
        ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
        ASSIGN COMPONENT sy-tabix OF STRUCTURE <row> TO FIELD-SYMBOL(<field>).
        <field> = lr_col->*.
      ENDLOOP.

      INSERT <row> INTO TABLE <tab>.
    ENDLOOP.

  ENDMETHOD.


  METHOD decode_x_base64.

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


  METHOD encode_x_base64.

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

  METHOD get_csv_by_table.

    FIELD-SYMBOLS <tab> TYPE table.
    ASSIGN val TO <tab>.

    DATA lr_row TYPE REF TO data.

    DATA(tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <tab> ) ).

    DATA(struc) = CAST cl_abap_structdescr( tab->get_table_line_type( ) ).

    LOOP AT struc->get_components( ) REFERENCE INTO DATA(lr_comp).
      result = result && lr_comp->name && ';'.
    ENDLOOP.

    result = result && cl_abap_char_utilities=>cr_lf.

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

  METHOD get_json_by_table.

    result = /ui2/cl_json=>serialize(
               val
*               compress         =
*               name             =
*               pretty_name      =
*               type_descr       =
*               assoc_arrays     =
*               ts_as_iso8601    =
*               expand_includes  =
*               assoc_arrays_opt =
*               numc_as_string   =
*               name_mappings    =
*               conversion_exits =
           "   format_output    = abap_true
*               hex_as_base64    =
             ).


  ENDMETHOD.

  METHOD get_xml_by_table.

    CALL TRANSFORMATION id SOURCE values = val RESULT XML result.

  ENDMETHOD.

  METHOD get_fieldlist_by_table.

    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( it_table ) ).
    DATA(lo_struc) = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).

    DATA(lt_comp) = lo_struc->get_components( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      INSERT ls_comp-name INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_string_by_xstring.

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

  METHOD get_xstring_by_string.

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



*    result = cl_abap_conv_codepage=>create_out( )->convert( val ).

  ENDMETHOD.


  METHOD trim_upper.
    result = to_upper( shift_left( shift_right( val ) ) ).
  ENDMETHOD.

ENDCLASS.
