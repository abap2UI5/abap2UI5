CLASS z2ui5_cl_util DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_util_api
  CREATE PUBLIC.

  PUBLIC SECTION.

    " abap-toolkit - Utility Functions for ABAP Cloud & Standard ABAP
    " version: `0.0.1`.
    " origin: https://github.com/oblomov-dev/abap-toolkit
    " author: https://github.com/oblomov-dev
    " license: MIT.

    CONSTANTS:
      BEGIN OF cs_ui5_msg_type,
        e TYPE string VALUE `Error` ##NO_TEXT,
        s TYPE string VALUE `Success` ##NO_TEXT,
        w TYPE string VALUE `Warning` ##NO_TEXT,
        i TYPE string VALUE `Information` ##NO_TEXT,
      END OF cs_ui5_msg_type.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.
    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.
    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.
    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_sql,
        tabname        TYPE string,
        check_autoload TYPE abap_bool,
        layout_name    TYPE string,
        layout_id      TYPE string,
        count          TYPE i,
        t_ref          TYPE REF TO data,
        where          TYPE string,
        t_filter       TYPE ty_t_filter_multi,
      END OF ty_s_sql.

    TYPES:
      BEGIN OF ty_s_msg,
        text       TYPE string,
        id         TYPE string,
        no         TYPE string,
        type       TYPE string,
        v1         TYPE string,
        v2         TYPE string,
        v3         TYPE string,
        v4         TYPE string,
        timestampl TYPE timestampl,
        t_meta     TYPE ty_t_name_value,
      END OF ty_s_msg,
      ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_msg_box,
        text    TYPE string,
        type    TYPE string,
        title   TYPE string,
        details TYPE string,
        skip    TYPE abap_bool,
      END OF ty_s_msg_box.

    TYPES:
      BEGIN OF ty_s_zip_file,
        name    TYPE string,
        content TYPE xstring,
      END OF ty_s_zip_file.
    TYPES ty_t_zip_file TYPE STANDARD TABLE OF ty_s_zip_file WITH DEFAULT KEY.

    CLASS-METHODS ui5_get_msg_type
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS ui5_msg_box_format
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_s_msg_box.

    CLASS-METHODS rtti_check_serializable
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_t
      IMPORTING
        VALUE(val)    TYPE any
        VALUE(val2)   TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS rtti_get_data_element_text_l
      IMPORTING
        VALUE(val)    TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get
      IMPORTING
        VALUE(val)    TYPE any
        VALUE(val2)   TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS msg_get_collect
      IMPORTING
        VALUE(val)    TYPE any
        VALUE(val2)   TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_by_msg
      IMPORTING
        id            TYPE any
        no            TYPE any
        v1            TYPE any OPTIONAL
        v2            TYPE any OPTIONAL
        v3            TYPE any OPTIONAL
        v4            TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS rtti_get_t_ddic_fixed_values
      IMPORTING
        rollname      TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util_api=>ty_t_fix_val ##NEEDED.

    CLASS-METHODS source_get_method2
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS check_bound_a_not_initial
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_unassign_initial
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS unassign_object
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS unassign_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS conv_get_as_data_ref
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS source_method_to_file
      IMPORTING
        it_source     TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

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

    CLASS-METHODS filter_itab
      IMPORTING
        filter TYPE ty_t_filter_multi
      CHANGING
        val     TYPE STANDARD TABLE.

    CLASS-METHODS filter_get_multi_by_data
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_data_by_multi
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_sql_where
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_get_multi_by_sql_where
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_sql_by_sql_string
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_sql.

    CLASS-METHODS url_param_get
      IMPORTING
        val           TYPE string
        url           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        t_params      TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_set
      IMPORTING
        url           TYPE string
        !name         TYPE string
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        !in           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_intfname_by_ref
      IMPORTING
        !in           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS x_get_last_t100
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS x_check_raise
      IMPORTING
        v     TYPE clike DEFAULT `CX_SY_SUBRC`
        !when TYPE abap_bool.

    CLASS-METHODS x_raise
      IMPORTING
        v TYPE clike DEFAULT `CX_SY_SUBRC`.

    CLASS-METHODS json_stringify
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_parse
      IMPORTING
        !xml TYPE clike
      EXPORTING
        !any TYPE any.

    CLASS-METHODS xml_stringify
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    CLASS-METHODS boolean_check_by_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_abap_2_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS json_parse
      IMPORTING
        val   TYPE any
      CHANGING
        !data TYPE any.

    CLASS-METHODS c_trim_upper
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_stringify
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_parse
      IMPORTING
        rtti_data     TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS time_get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_subtract_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS c_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_trim_lower
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_get_tab
      IMPORTING
        i_val            TYPE clike
      RETURNING
        VALUE(rt_params) TYPE ty_t_name_value.

    CLASS-METHODS rtti_get_t_attri_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_t_attri_by_table_name
      IMPORTING
        table_name    TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_type_name
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_class_exists
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_create_tab_by_name
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS rtti_check_type_kind_dref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_ref_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_check_by_name
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS filter_update_tokens
      IMPORTING
        val           TYPE ty_t_filter_multi
        !name         TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_filter_multi.

    CLASS-METHODS filter_get_range_t_by_token_t
      IMPORTING
        val           TYPE ty_t_token
      RETURNING
        VALUE(result) TYPE ty_t_range.

    CLASS-METHODS filter_get_range_by_token
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_s_range.

    CLASS-METHODS filter_get_token_t_by_range_t
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_token ##NEEDED.

    CLASS-METHODS filter_get_token_range_mapping
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS itab_corresponding
      IMPORTING
        val  TYPE STANDARD TABLE
      CHANGING
        !tab TYPE STANDARD TABLE.

    CLASS-METHODS itab_filter_by_val
      IMPORTING
        val         TYPE clike
        fields      TYPE string_table OPTIONAL
        ignore_case TYPE abap_bool DEFAULT abap_false
      CHANGING
        !tab        TYPE STANDARD TABLE.

    CLASS-METHODS itab_get_by_struc
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_name_value.

    CLASS-METHODS itab_filter_by_t_range
      IMPORTING
        val  TYPE ty_t_filter_multi
      CHANGING
        !tab TYPE STANDARD TABLE.

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
        !from         TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS conv_get_xstring_by_data_uri
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS source_get_file_types
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS rtti_tab_get_relative_name
      IMPORTING
        !table        TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_exit
      IMPORTING
        convexit TYPE clike
        output   TYPE abap_bool DEFAULT abap_false
      CHANGING
        value    TYPE data.

    CLASS-METHODS rtti_check_clike
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_contains
      IMPORTING
        val           TYPE clike
        sub           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_starts_with
      IMPORTING
        val           TYPE clike
        prefix        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_ends_with
      IMPORTING
        val           TYPE clike
        suffix        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS c_split
      IMPORTING
        val           TYPE clike
        sep           TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS c_join
      IMPORTING
        tab           TYPE string_table
        sep           TYPE clike DEFAULT ``
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_table
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_check_structure
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_check_numeric
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS time_add_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_get_stampl_by_date_time
      IMPORTING
        !date         TYPE d
        !time         TYPE t
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_diff_seconds
      IMPORTING
        !time_from    TYPE timestampl
        !time_to      TYPE timestampl
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS conv_string_to_date
      IMPORTING
        val           TYPE clike
        format        TYPE clike DEFAULT `YYYY-MM-DD`
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS conv_date_to_string
      IMPORTING
        val           TYPE d
        format        TYPE clike DEFAULT `YYYY-MM-DD`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url
      IMPORTING
        VALUE(classname) TYPE clike
        !origin          TYPE clike
        !pathname        TYPE clike
        !search          TYPE clike
        !hash            TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    CLASS-METHODS app_get_url_source_code
      IMPORTING
        !classname    TYPE clike
        !origin       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS cal_get_weekday
      IMPORTING
        !date         TYPE d
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS cal_is_weekend
      IMPORTING
        !date         TYPE d
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cal_is_workday
      IMPORTING
        !date         TYPE d
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cal_add_workdays
      IMPORTING
        !date         TYPE d
        !days         TYPE i
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS cal_count_workdays
      IMPORTING
        !date_from    TYPE d
        !date_to      TYPE d
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS zip_pack
      IMPORTING
        !files        TYPE ty_t_zip_file
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS zip_unpack
      IMPORTING
        !val          TYPE xstring
      RETURNING
        VALUE(result) TYPE ty_t_zip_file.

    TYPES:
      BEGIN OF ty_s_lock_param,
        name  TYPE c LENGTH 30,
        value TYPE string,
      END OF ty_s_lock_param.
    TYPES ty_t_lock_param TYPE STANDARD TABLE OF ty_s_lock_param WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_lock,
        lock_object TYPE string,
        argument    TYPE string,
        user        TYPE string,
        mode        TYPE string,
        client      TYPE string,
        date        TYPE d,
        time        TYPE t,
        owner       TYPE string,
        owner_vb    TYPE string,
      END OF ty_s_lock.
    TYPES ty_t_lock TYPE STANDARD TABLE OF ty_s_lock WITH DEFAULT KEY.

    CLASS-METHODS lock_set
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_delete
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_read
      IMPORTING
        lock_object   TYPE clike OPTIONAL
        !user         TYPE clike OPTIONAL
        client        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_lock.

    CLASS-METHODS lock_delete_entries
      IMPORTING
        t_lock        TYPE ty_t_lock
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_get_dequeue_by_enqueue
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_bool_cache,
        absolute_name TYPE string,
        is_bool       TYPE abap_bool,
      END OF ty_s_bool_cache.

    CLASS-DATA mt_bool_cache TYPE HASHED TABLE OF ty_s_bool_cache WITH UNIQUE KEY absolute_name.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    CLASS-METHODS filter_get_sql_cond_by_range
      IMPORTING
        fieldname     TYPE clike
        range         TYPE ty_s_range
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS filter_get_range_by_sql_cond
      IMPORTING
        val       TYPE clike
      EXPORTING
        fieldname TYPE string
        range     TYPE ty_s_range.

    CLASS-METHODS filter_sql_split_top_level
      IMPORTING
        val           TYPE clike
        sep           TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS filter_sql_strip_quotes
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lock_call_function
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.



CLASS z2ui5_cl_util IMPLEMENTATION.


  METHOD boolean_abap_2_json.
      DATA temp253 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.

      IF val = abap_true.
        temp253 = `true`.
      ELSE.
        temp253 = `false`.
      ENDIF.
      result = temp253.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD boolean_check_by_data.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp254 TYPE string.
        DATA lv_abs_name LIKE temp254.
        DATA temp255 LIKE sy-subrc.
          DATA temp256 LIKE LINE OF mt_bool_cache.
          DATA temp257 LIKE sy-tabix.
        DATA temp258 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp258.
        DATA temp259 TYPE z2ui5_cl_util=>ty_s_bool_cache.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.

        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        temp254 = lo_descr->absolute_name.

        lv_abs_name = temp254.


        READ TABLE mt_bool_cache WITH KEY absolute_name = lv_abs_name TRANSPORTING NO FIELDS.
        temp255 = sy-subrc.
        IF temp255 = 0.


          temp257 = sy-tabix.
          READ TABLE mt_bool_cache WITH KEY absolute_name = lv_abs_name INTO temp256.
          sy-tabix = temp257.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          result = temp256-is_bool.
          RETURN.
        ENDIF.


        temp258 ?= lo_descr.

        lo_ele = temp258.
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).


        CLEAR temp259.
        temp259-absolute_name = lv_abs_name.
        temp259-is_bool = result.
        INSERT temp259 INTO TABLE mt_bool_cache.


      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD boolean_check_by_name.

    CASE val.
      WHEN `ABAP_BOOL`
          OR `XSDBOOLEAN`
          OR `FLAG`
          OR `XFLAG`
          OR `XFELD`
          OR `ABAP_BOOLEAN`
          OR `WDY_BOOLEAN`
          OR `BOOLE_D`
          OR `OS_BOOLEAN`.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD check_bound_a_not_initial.
    DATA temp1 TYPE xsdboolean.

    IF val IS NOT BOUND.
      result = abap_false.
      RETURN.
    ENDIF.

    temp1 = boolc( check_unassign_initial( val ) = abap_false ).
    result = temp1.

  ENDMETHOD.


  METHOD check_unassign_initial.
    FIELD-SYMBOLS <any> TYPE data.
    DATA temp2 TYPE xsdboolean.

    IF val IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.


    ASSIGN val->* TO <any>.


    temp2 = boolc( <any> IS INITIAL ).
    result = temp2.

  ENDMETHOD.


  METHOD conv_copy_ref_data.

    FIELD-SYMBOLS <from>   TYPE data.
    FIELD-SYMBOLS <result> TYPE data.

    IF rtti_check_ref_data( from ) IS NOT INITIAL.
      ASSIGN from->* TO <from>.
    ELSE.
      ASSIGN from TO <from>.
    ENDIF.
    CREATE DATA result LIKE <from>.
    ASSIGN result->* TO <result>.

    <result> = <from>.

  ENDMETHOD.


  METHOD conv_get_as_data_ref.

    GET REFERENCE OF val INTO result.

  ENDMETHOD.


  METHOD conv_get_xstring_by_data_uri.

    DATA lv_metadata TYPE string ##NEEDED.
    DATA lv_base64   TYPE string.

    SPLIT val AT `,` INTO lv_metadata lv_base64.
    result = conv_decode_x_base64( lv_base64 ).

  ENDMETHOD.


  METHOD c_trim.

    DATA temp260 TYPE string.
    temp260 = val.
    result = shift_left( shift_right( temp260 ) ).
    result = shift_right( val = result
                          sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result
                         sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    DATA temp261 TYPE string.
    temp261 = val.
    result = to_lower( c_trim( temp261 ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    DATA temp262 TYPE string.
    temp262 = val.
    result = to_upper( c_trim( temp262 ) ).

  ENDMETHOD.


  METHOD filter_itab.

    DATA ref TYPE REF TO data.
      DATA ls_filter LIKE LINE OF filter.
        FIELD-SYMBOLS <field> TYPE any.

    LOOP AT val REFERENCE INTO ref.


      LOOP AT filter INTO ls_filter.


        ASSIGN ref->(ls_filter-name) TO <field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF <field> NOT IN ls_filter-t_range.
          DELETE val.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_multi_by_data.

    DATA temp263 TYPE abap_component_tab.
    DATA temp113 LIKE LINE OF temp263.
    DATA lr_comp LIKE REF TO temp113.
      DATA temp264 TYPE z2ui5_cl_util=>ty_s_filter_multi.
    temp263 = rtti_get_t_attri_by_any( val ).


    LOOP AT temp263 REFERENCE INTO lr_comp.

      CLEAR temp264.
      temp264-name = lr_comp->name.
      INSERT temp264 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_range_by_token.

    DATA lv_value LIKE val.
    DATA lv_length TYPE i.
    lv_value = val.

    lv_length = strlen( lv_value ) - 1.

    CASE lv_value(1).

      WHEN `=`.
        CLEAR result.
        result-sign = `I`.
        result-option = `EQ`.
        result-low = lv_value+1.
      WHEN `<`.
        IF lv_value+1(1) = `=`.
          CLEAR result.
          result-sign = `I`.
          result-option = `LE`.
          result-low = lv_value+2.
        ELSE.
          CLEAR result.
          result-sign = `I`.
          result-option = `LT`.
          result-low = lv_value+1.
        ENDIF.
      WHEN `>`.
        IF lv_value+1(1) = `=`.
          CLEAR result.
          result-sign = `I`.
          result-option = `GE`.
          result-low = lv_value+2.
        ELSE.
          CLEAR result.
          result-sign = `I`.
          result-option = `GT`.
          result-low = lv_value+1.
        ENDIF.

      WHEN `*`.
        IF lv_value+lv_length(1) = `*`.
          lv_value = substring( val = lv_value off = 1 len = lv_length - 1 ).
          CLEAR result.
          result-sign = `I`.
          result-option = `CP`.
          result-low = lv_value.
        ENDIF.

      WHEN OTHERS.
        IF lv_value CS `...`.
          SPLIT lv_value AT `...` INTO result-low result-high.
          result-sign   = `I`.
          result-option = `BT`.
        ELSE.
          CLEAR result.
          result-sign = `I`.
          result-option = `EQ`.
          result-low = lv_value.
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD filter_update_tokens.
    FIELD-SYMBOLS <temp265> TYPE z2ui5_cl_util=>ty_s_filter_multi.
DATA lr_filter LIKE REF TO <temp265>.
    DATA ls_token LIKE LINE OF lr_filter->t_token_removed.
      DATA temp266 TYPE z2ui5_cl_util=>ty_s_token.
    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp114 LIKE LINE OF result.
    DATA temp115 LIKE sy-tabix.

    result = val.

    READ TABLE result WITH KEY name = name ASSIGNING <temp265>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp265> INTO lr_filter.

    LOOP AT lr_filter->t_token_removed INTO ls_token.
      DELETE lr_filter->t_token WHERE key = ls_token-key.
    ENDLOOP.

    LOOP AT lr_filter->t_token_added INTO ls_token.

      CLEAR temp266.
      temp266-key = ls_token-key.
      temp266-text = ls_token-text.
      temp266-visible = abap_true.
      temp266-editable = abap_true.
      INSERT temp266 INTO TABLE lr_filter->t_token.
    ENDLOOP.

    CLEAR lr_filter->t_token_removed.
    CLEAR lr_filter->t_token_added.




    temp115 = sy-tabix.
    READ TABLE result WITH KEY name = name INTO temp114.
    sy-tabix = temp115.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_range = z2ui5_cl_util=>filter_get_range_t_by_token_t( temp114-t_token ).
    lr_filter->t_range = lt_range.

  ENDMETHOD.


  METHOD filter_get_range_t_by_token_t.

    DATA ls_token LIKE LINE OF val.
    LOOP AT val INTO ls_token.
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_token_range_mapping.

    DATA temp267 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp268 LIKE LINE OF temp267.
    CLEAR temp267.

    temp268-n = `EQ`.
    temp268-v = `={LOW}`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `LT`.
    temp268-v = `<{LOW}`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `LE`.
    temp268-v = `<={LOW}`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `GT`.
    temp268-v = `>{LOW}`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `GE`.
    temp268-v = `>={LOW}`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `CP`.
    temp268-v = `*{LOW}*`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `BT`.
    temp268-v = `{LOW}...{HIGH}`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `NB`.
    temp268-v = `!({LOW}...{HIGH})`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `NE`.
    temp268-v = `!(={LOW})`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `NP`.
    temp268-v = `!(*{LOW}*)`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `!<leer>`.
    temp268-v = `!(<leer>)`.
    INSERT temp268 INTO TABLE temp267.
    temp268-n = `<leer>`.
    temp268-v = `<leer>`.
    INSERT temp268 INTO TABLE temp267.
    result = temp267.

  ENDMETHOD.


  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp269 TYPE ty_t_range.
    DATA lt_tab LIKE temp269.
    DATA temp270 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp270.
      DATA lv_value TYPE z2ui5_cl_util=>ty_s_name_value-v.
      DATA temp116 LIKE LINE OF lt_mapping.
      DATA temp117 LIKE sy-tabix.
      DATA temp271 TYPE z2ui5_cl_util=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).


    CLEAR temp269.

    lt_tab = temp269.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab
    ).



    LOOP AT lt_tab REFERENCE INTO lr_row.




      temp117 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option INTO temp116.
      sy-tabix = temp117.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = temp116-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.


      CLEAR temp271.
      temp271-key = lv_value.
      temp271-text = lv_value.
      temp271-visible = abap_true.
      temp271-editable = abap_true.
      INSERT temp271 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_filter_by_val.

    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    DATA temp272 TYPE string.
    DATA lv_search LIKE temp272.
      DATA lv_check_found LIKE abap_false.
      DATA lv_index TYPE i.
          DATA lv_name LIKE LINE OF fields.
          DATA temp118 LIKE LINE OF fields.
          DATA temp119 LIKE sy-tabix.
        DATA lv_value TYPE string.
    IF ignore_case = abap_true.
      temp272 = to_upper( val ).
    ELSE.
      temp272 = val.
    ENDIF.

    lv_search = temp272.

    LOOP AT tab ASSIGNING <row>.


      lv_check_found = abap_false.

      lv_index = 1.
      DO.
        IF fields IS INITIAL.
          ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
        ELSE.
          IF lv_index > lines( fields ).
            EXIT.
          ENDIF.



          temp119 = sy-tabix.
          READ TABLE fields INDEX lv_index INTO temp118.
          sy-tabix = temp119.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lv_name = temp118.
          ASSIGN COMPONENT lv_name OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            lv_index = lv_index + 1.
            CONTINUE.
          ENDIF.
        ENDIF.


        lv_value = |{ <field> }|.
        IF ignore_case = abap_true.
          lv_value = to_upper( lv_value ).
        ENDIF.
        IF lv_value CS lv_search.
          lv_check_found = abap_true.
          EXIT.
        ENDIF.

        lv_index = lv_index + 1.
      ENDDO.

      IF lv_check_found = abap_false.
        DELETE tab.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD itab_get_csv_by_itab.

    FIELD-SYMBOLS <tab> TYPE table.
    DATA lt_lines TYPE string_table.
    DATA lv_line TYPE string.
    DATA temp273 TYPE REF TO cl_abap_tabledescr.
    DATA tab LIKE temp273.
    DATA temp274 TYPE REF TO cl_abap_structdescr.
    DATA struc LIKE temp274.
    DATA temp275 TYPE abap_component_tab.
    DATA temp120 LIKE LINE OF temp275.
    DATA lr_comp LIKE REF TO temp120.
    DATA lr_row TYPE REF TO data.
      DATA lv_index TYPE i.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.

    ASSIGN val TO <tab>.

    temp273 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

    tab = temp273.


    temp274 ?= tab->get_table_line_type( ).

    struc = temp274.

    CLEAR lv_line.

    temp275 = struc->get_components( ).


    LOOP AT temp275 REFERENCE INTO lr_comp.
      lv_line = |{ lv_line }{ lr_comp->name };|.
    ENDLOOP.
    INSERT lv_line INTO TABLE lt_lines.


    LOOP AT <tab> REFERENCE INTO lr_row.

      CLEAR lv_line.

      lv_index = 1.
      DO.

        ASSIGN lr_row->* TO <row>.

        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        lv_line = |{ lv_line }{ <field> };|.
      ENDDO.
      INSERT lv_line INTO TABLE lt_lines.
    ENDLOOP.

    result = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>cr_lf ).

  ENDMETHOD.




  METHOD itab_get_itab_by_csv.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.

    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_rows TYPE temp1.
    TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_cols TYPE temp2.
    DATA temp121 LIKE LINE OF lt_rows.
    DATA temp122 LIKE sy-tabix.
    DATA temp276 LIKE LINE OF lt_cols.
    DATA lr_col LIKE REF TO temp276.
      DATA lv_name TYPE string.
      DATA temp277 TYPE abap_componentdescr.
    DATA struc TYPE REF TO cl_abap_structdescr.
    DATA temp278 TYPE REF TO cl_abap_datadescr.
    DATA data LIKE temp278.
    DATA o_table_desc TYPE REF TO cl_abap_tabledescr.
    DATA temp279 LIKE LINE OF lt_rows.
    DATA lr_rows LIKE REF TO temp279.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
    SPLIT val AT cl_abap_char_utilities=>newline INTO TABLE lt_rows.




    temp122 = sy-tabix.
    READ TABLE lt_rows INDEX 1 INTO temp121.
    sy-tabix = temp122.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    SPLIT temp121 AT `;` INTO TABLE lt_cols.



    LOOP AT lt_cols REFERENCE INTO lr_col.


      lv_name = c_trim_upper( lr_col->* ).
      REPLACE ` ` IN lv_name WITH `_`.


      CLEAR temp277.
      temp277-name = lv_name.
      temp277-type = cl_abap_elemdescr=>get_c( 40 ).
      INSERT temp277 INTO TABLE lt_comp.
    ENDLOOP.


    struc = cl_abap_structdescr=>get( lt_comp ).

    temp278 ?= struc.

    data = temp278.

    o_table_desc = cl_abap_tabledescr=>create( p_line_type  = data
                                                     p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                     p_unique     = abap_false ).

    CREATE DATA result TYPE HANDLE o_table_desc.
    ASSIGN result->* TO <tab>.
    DELETE lt_rows WHERE table_line IS INITIAL.



    LOOP AT lt_rows REFERENCE INTO lr_rows FROM 2.

      SPLIT lr_rows->* AT `;` INTO TABLE lt_cols.
      CREATE DATA lr_row TYPE HANDLE struc.

      LOOP AT lt_cols REFERENCE INTO lr_col.

        ASSIGN lr_row->* TO <row>.

        ASSIGN COMPONENT sy-tabix OF STRUCTURE <row> TO <field>.
        ASSERT sy-subrc = 0.
        <field> = lr_col->*.
      ENDLOOP.

      INSERT <row> INTO TABLE <tab>.
    ENDLOOP.

  ENDMETHOD.


  METHOD json_parse.
        DATA x TYPE REF TO cx_root.
    TRY.

        z2ui5_cl_ajson=>parse( val )->to_abap( EXPORTING iv_corresponding = abap_true
                                               IMPORTING ev_container     = data ).


      CATCH cx_root INTO x.
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD json_stringify.
        DATA temp280 TYPE REF TO z2ui5_if_ajson.
        DATA li_ajson LIKE temp280.
        DATA x TYPE REF TO cx_root.
    TRY.


        temp280 ?= z2ui5_cl_ajson=>create_empty( ).

        li_ajson = temp280.
        result = li_ajson->set( iv_path = `/`
                                iv_val  = any )->stringify( ).


      CATCH cx_root INTO x.
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_check_class_exists.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        cl_abap_classdescr=>describe_by_name( EXPORTING  p_name         = val
                                              EXCEPTIONS type_not_found = 1 ).
        IF sy-subrc = 0.
          result = abap_true.
        ENDIF.


      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_ref_data.
        DATA lo_typdescr TYPE REF TO cl_abap_typedescr.
        DATA temp281 TYPE REF TO cl_abap_refdescr.
        DATA lo_ref LIKE temp281.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.

        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).

        temp281 ?= lo_typdescr.

        lo_ref = temp281.
        result = abap_true.

      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_type_kind_dref.

    DATA lv_type_kind TYPE abap_typekind.
    DATA temp3 TYPE xsdboolean.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).

    temp3 = boolc( lv_type_kind = cl_abap_typedescr=>typekind_dref ).
    result = temp3.

  ENDMETHOD.


  METHOD rtti_get_classname_by_ref.

    DATA lv_classname TYPE abap_abstypename.
    lv_classname = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD rtti_get_intfname_by_ref.

    DATA rtti TYPE REF TO cl_abap_typedescr.
    DATA temp282 TYPE REF TO cl_abap_refdescr.
    DATA ref LIKE temp282.
    DATA name TYPE abap_abstypename.
    rtti = cl_abap_typedescr=>describe_by_data( in  ).

    temp282 ?= rtti.

    ref = temp282.

    name = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp283 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp283.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.
    TRY.


        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        temp283 ?= lo_descr.

        lo_ele = temp283.
        result = lo_ele->get_relative_name( ).


      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_get_t_attri_by_include.
        DATA type_desc TYPE REF TO cl_abap_typedescr.
        DATA x TYPE REF TO cx_root.
    DATA temp284 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp284.
    DATA comps TYPE abap_component_tab.
    DATA temp285 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp285.
        DATA incl_comps TYPE abap_component_tab.
        DATA temp286 LIKE LINE OF incl_comps.
        DATA lr_incl_comp LIKE REF TO temp286.

    TRY.


        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                             RECEIVING  p_descr_ref    = type_desc
                                             EXCEPTIONS type_not_found = 1 ).


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

    temp284 ?= type_desc.

    sdescr = temp284.

    comps = sdescr->get_components( ).



    LOOP AT comps REFERENCE INTO lr_comp.

      IF lr_comp->as_include = abap_true.


        incl_comps = rtti_get_t_attri_by_include( lr_comp->type ).



        LOOP AT incl_comps REFERENCE INTO lr_incl_comp.
          APPEND lr_incl_comp->* TO result.
        ENDLOOP.

      ELSE.

        APPEND lr_comp->* TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_oref.

    DATA lo_obj_ref TYPE REF TO cl_abap_typedescr.
    DATA temp287 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).

    temp287 ?= lo_obj_ref.
    result = temp287->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_type   TYPE REF TO cl_abap_typedescr.
        DATA temp288 TYPE REF TO cl_abap_structdescr.
        DATA temp289 TYPE REF TO cl_abap_structdescr.
        DATA temp123 TYPE REF TO cl_abap_tabledescr.
    DATA temp290 TYPE string.
    DATA lv_absolute_name LIKE temp290.
    DATA lr_cache TYPE REF TO z2ui5_cl_util=>ty_s_attri_cache.
    DATA comps TYPE abap_component_tab.
    DATA temp291 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp291.
        DATA lt_attri TYPE abap_component_tab.
      DATA temp292 TYPE z2ui5_cl_util=>ty_s_attri_cache.

    TRY.
        lo_type = cl_abap_typedescr=>describe_by_data( val ).
        IF lo_type->kind = cl_abap_typedescr=>kind_ref.
          lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
        ENDIF.
      CATCH cx_root.
        TRY.
            lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
          CATCH cx_root.
            lo_type = cl_abap_structdescr=>describe_by_name( val ).
        ENDTRY.
    ENDTRY.

    CASE lo_type->kind.
      WHEN cl_abap_typedescr=>kind_struct.

        temp288 ?= lo_type.
        lo_struct = temp288.
      WHEN cl_abap_typedescr=>kind_table.


        temp123 ?= lo_type.
        temp289 ?= temp123->get_table_line_type( ).
        lo_struct = temp289.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types

    temp290 = lo_struct->absolute_name.

    lv_absolute_name = temp290.

    READ TABLE mt_attri_cache REFERENCE INTO lr_cache
         WITH TABLE KEY absolute_name = lv_absolute_name.
    IF sy-subrc = 0 AND lr_cache->o_struct = lo_struct.
      result = lr_cache->t_attri.
      RETURN.
    ENDIF.


    comps = lo_struct->get_components( ).



    LOOP AT comps REFERENCE INTO lr_comp.

      IF lr_comp->as_include = abap_false.
        APPEND lr_comp->* TO result.
      ELSE.

        lt_attri = rtti_get_t_attri_by_include( lr_comp->type ).
        APPEND LINES OF lt_attri TO result.
      ENDIF.
    ENDLOOP.

    IF lr_cache IS BOUND.
      lr_cache->o_struct = lo_struct.
      lr_cache->t_attri  = result.
    ELSE.

      CLEAR temp292.
      temp292-absolute_name = lv_absolute_name.
      temp292-o_struct = lo_struct.
      temp292-t_attri = result.
      INSERT temp292 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_get_t_ddic_fixed_values.
        DATA temp293 TYPE string.
        DATA typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp294 TYPE REF TO cl_abap_elemdescr.
        DATA elemdescr LIKE temp294.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    IF rollname IS INITIAL.
      RETURN.
    ENDIF.

    TRY.


        temp293 = rollname.

        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp293
                                             RECEIVING  p_descr_ref    = typedescr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        temp294 ?= typedescr.

        elemdescr = temp294.

        result = rtti_get_t_fixvalues( elemdescr = elemdescr
                                       langu     = langu ).


      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_tab_get_relative_name.

    FIELD-SYMBOLS <table> TYPE any.
        DATA typedesc TYPE REF TO cl_abap_typedescr.
            DATA temp295 TYPE REF TO cl_abap_tabledescr.
            DATA tabledesc LIKE temp295.
            DATA temp296 TYPE REF TO cl_abap_structdescr.
            DATA structdesc LIKE temp296.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.

        typedesc = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.

            temp295 ?= typedesc.

            tabledesc = temp295.

            temp296 ?= tabledesc->get_table_line_type( ).

            structdesc = temp296.
            result = structdesc->get_relative_name( ).
            RETURN.

          WHEN typedesc->kind_ref.

            ASSIGN table->* TO <table>.
            result = rtti_tab_get_relative_name( <table> ).

        ENDCASE.

      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD conv_exit.

    DATA temp297 TYPE string.
    DATA conex LIKE temp297.
    IF output = abap_true.
      temp297 = |CONVERSION_EXIT_{ convexit }_OUTPUT|.
    ELSE.
      temp297 = |CONVERSION_EXIT_{ convexit }_INPUT|.
    ENDIF.

    conex = temp297.

    TRY.
        IF convexit = `CUNIT`.

          CALL FUNCTION conex
            EXPORTING
              input    = value
              language = sy-langu
            IMPORTING
              output   = value
            EXCEPTIONS
              OTHERS   = 99.

        ELSE.

          CALL FUNCTION conex
            EXPORTING
              input  = value
            IMPORTING
              output = value
            EXCEPTIONS
              OTHERS = 99.

        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD source_get_file_types.

    DATA lv_types TYPE string.
    lv_types = |abap, abc, actionscript, ada, apache_conf, applescript, asciidoc, assembly_x86, autohotkey, batchfile, bro, c9search, c_cpp, cirru, clojure, cobol, coffee, coldfusion, csharp, css, curly, d, dart, diff, django, dockerfile, | &&
|dot, drools, eiffel, yaml, ejs, elixir, elm, erlang, forth, fortran, ftl, gcode, gherkin, gitignore, glsl, gobstones, golang, groovy, haml, handlebars, haskell, haskell_cabal, haxe, hjson, html, html_elixir, html_ruby, ini, io, jack, jade, java, ja| &&
      |vascri| &&
|pt, json, jsoniq, jsp, jsx, julia, kotlin, latex, lean, less, liquid, lisp, live_script, livescript, logiql, lsl, lua, luapage, lucene, makefile, markdown, mask, matlab, mavens_mate_log, maze, mel, mips_assembler, mipsassembler, mushcode, mysql, ni| &&
|x, nsis, objectivec, ocaml, pascal, perl, pgsql, php, plain_text, powershell, praat, prolog, properties, protobuf, python, r, razor, rdoc, rhtml, rst, ruby, rust, sass, scad, scala, scheme, scss, sh, sjs, smarty, snippets, soy_template, space, sql,| &&
      | sqlserver, stylus, svg, swift, swig, tcl, tex, text, textile, toml, tsx, twig, typescript, vala, vbscript, velocity, verilog, vhdl, wollok, xml, xquery, terraform, slim, redshift, red, puppet, php_laravel_blade, mixal, jssm, fsharp, edifact,| &&
      | csp, cssound_score, cssound_orchestra, cssound_document| ##NO_TEXT.
    SPLIT lv_types AT `,` INTO TABLE result.

  ENDMETHOD.


  METHOD source_get_method2.

    DATA lt_source TYPE string_table.
    lt_source = source_get_method( iv_classname  = iv_classname
                                         iv_methodname = iv_methodname ).

    result = source_method_to_file( lt_source ).

  ENDMETHOD.


  METHOD source_method_to_file.

    DATA lv_source LIKE LINE OF it_source.
          DATA x TYPE REF TO cx_root.
          DATA lv_error TYPE string.
    LOOP AT it_source INTO lv_source.
      TRY.
          result = result && lv_source+1 && cl_abap_char_utilities=>newline.

        CATCH cx_root INTO x.

          lv_error = x->get_text( ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_sql_by_sql_string.

    DATA temp298 TYPE string.
    DATA lv_sql LIKE temp298.
    DATA lv_squished LIKE lv_sql.
    DATA lv_dummy TYPE string.
    DATA lv_tab TYPE string.
    DATA lv_upper TYPE string.
      DATA lv_pos TYPE i.
    temp298 = val.

    lv_sql = temp298.


    lv_squished = lv_sql.
    REPLACE ALL OCCURRENCES OF ` ` IN lv_squished WITH ``.
    lv_squished = to_upper( lv_squished ).


    SPLIT lv_squished AT `SELECTFROM` INTO lv_dummy lv_tab.
    SPLIT lv_tab AT `FIELDS` INTO lv_tab lv_dummy.
    SPLIT lv_tab AT `WHERE` INTO lv_tab lv_dummy.

    result-tabname = lv_tab.


    lv_upper = to_upper( lv_sql ).
    IF lv_upper CS ` WHERE `.

      lv_pos = sy-fdpos + 7.
      result-where = c_trim( substring( val = lv_sql
                                        off = lv_pos ) ).
      result-t_filter = filter_get_multi_by_sql_where( result-where ).
    ENDIF.

  ENDMETHOD.


  METHOD time_get_date_by_stampl.
    DATA ls_sy TYPE z2ui5_cl_util_api=>ty_syst.
    DATA lv_dummy TYPE t.
    ls_sy = z2ui5_cl_util=>context_get_sy( ).

    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE result TIME lv_dummy.
  ENDMETHOD.


  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD time_get_time_by_stampl.
    DATA ls_sy TYPE z2ui5_cl_util_api=>ty_syst.
    DATA lv_dummy TYPE d.
    ls_sy = z2ui5_cl_util=>context_get_sy( ).

    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE lv_dummy TIME result.
  ENDMETHOD.


  METHOD time_subtract_seconds.

    result = cl_abap_tstmp=>subtractsecs( tstmp = time
                                          secs  = seconds ).

  ENDMETHOD.


  METHOD unassign_data.

    FIELD-SYMBOLS <unassign> TYPE any.

    ASSIGN val->* TO <unassign>.
    result = <unassign>.

  ENDMETHOD.


  METHOD unassign_object.

    FIELD-SYMBOLS <unassign> TYPE any.

    ASSIGN val->* TO <unassign>.
    result = <unassign>.

  ENDMETHOD.


  METHOD url_param_create_url.

    DATA ls_param LIKE LINE OF t_params.
    LOOP AT t_params INTO ls_param.
      result = |{ result }{ ls_param-n }={ ls_param-v }&|.
    ENDLOOP.
    result = shift_right( val = result
                          sub = `&` ).

  ENDMETHOD.


  METHOD url_param_get.

    DATA lt_params TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lv_val TYPE string.
    DATA temp299 TYPE string.
    DATA temp300 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).

    lv_val = c_trim_lower( val ).

    CLEAR temp299.

    READ TABLE lt_params INTO temp300 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp299 = temp300-v.
    ENDIF.
    result = temp299.

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA lv_search TYPE string.
    DATA lv_search2 TYPE string.
    DATA temp301 TYPE string.
    TYPES temp3 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp3.
    DATA temp302 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp302.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp303 TYPE z2ui5_cl_util=>ty_s_name_value.
    lv_search = replace( val  = i_val
                               sub  = `%3D`
                               with = `=`
                               occ  = 0 ).

    lv_search = replace( val  = lv_search
                         sub  = `%26`
                         with = `&`
                         occ  = 0 ).

    lv_search = shift_left( val = lv_search
                            sub = `?` ).


    lv_search2 = substring_after( val = lv_search
                                        sub = `&sap-startup-params=` ).

    IF lv_search2 IS NOT INITIAL.
      temp301 = lv_search2.
    ELSE.
      temp301 = lv_search.
    ENDIF.
    lv_search = temp301.

    lv_search2 = substring_after( val = c_trim_lower( lv_search )
                                  sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.



    SPLIT lv_search AT `&` INTO TABLE lt_param.



    LOOP AT lt_param REFERENCE INTO lr_param.


      SPLIT lr_param->* AT `=` INTO lv_name lv_value.

      CLEAR temp303.
      temp303-n = lv_name.
      temp303-v = lv_value.
      INSERT temp303 INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.


  METHOD url_param_set.

    DATA lt_params TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lv_n TYPE string.
    DATA temp304 LIKE LINE OF lt_params.
    DATA lr_params LIKE REF TO temp304.
      DATA temp305 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).

    lv_n = c_trim_lower( name ).



    LOOP AT lt_params REFERENCE INTO lr_params
         WHERE n = lv_n.
      lr_params->v = c_trim_lower( value ).
    ENDLOOP.
    IF sy-subrc <> 0.

      CLEAR temp305.
      temp305-n = lv_n.
      temp305-v = c_trim_lower( value ).
      INSERT temp305 INTO TABLE lt_params.
    ENDIF.

    result = url_param_create_url( lt_params ).

  ENDMETHOD.


  METHOD xml_parse.

    IF xml IS INITIAL.
      CLEAR any.
      RETURN.
    ENDIF.

    CALL TRANSFORMATION id
         SOURCE XML xml
         RESULT data = any.

  ENDMETHOD.


  METHOD xml_srtti_parse.

    DATA srtti TYPE REF TO object.
    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
    FIELD-SYMBOLS <variable> TYPE data.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.


    CALL METHOD srtti->(`GET_RTTI`)
      RECEIVING
        rtti = rtti_type.


    lo_datadescr ?= rtti_type.

    CREATE DATA result TYPE HANDLE lo_datadescr.

    ASSIGN result->* TO <variable>.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.

  ENDMETHOD.


  METHOD xml_srtti_stringify.
      DATA srtti TYPE REF TO object.
      DATA lv_classname TYPE string.
          DATA lv_text TYPE string.

    IF rtti_check_class_exists( `ZCL_SRTTI_TYPEDESCR` ) = abap_true.



      lv_classname = `ZCL_SRTTI_TYPEDESCR`.
      CALL METHOD (lv_classname)=>(`CREATE_BY_DATA_OBJECT`)
        EXPORTING
          data_object = data
        RECEIVING
          srtti       = srtti.
      CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

    ELSE.

      TRY.
          CALL METHOD z2ui5_cl_srt_typedescr=>(`CREATE_BY_DATA_OBJECT`)
            EXPORTING
              data_object = data
            RECEIVING
              srtti       = srtti.
          CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

        CATCH cx_root.


          lv_text = `UNSUPPORTED_FEATURE`.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lv_text.

      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD xml_stringify.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD x_check_raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = v.
    ENDIF.

  ENDMETHOD.


  METHOD x_get_last_t100.

    DATA x LIKE val.
    x = val.
    DO.

      IF x->previous IS BOUND.
        x = x->previous.
        CONTINUE.
      ENDIF.

      EXIT.
    ENDDO.

    result = x->get_text( ).

  ENDMETHOD.


  METHOD x_raise.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = v.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_table_name.
        DATA lo_obj TYPE REF TO cl_abap_typedescr.
        DATA temp306 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp306.
            DATA temp307 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp307.
            DATA temp308 TYPE REF TO cl_abap_structdescr.
    DATA temp309 LIKE LINE OF result.
    DATA lr_comp LIKE REF TO temp309.
      DATA lt_attri TYPE abap_component_tab.

    IF table_name IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `TABLE_NAME_INITIAL_ERROR`.
    ENDIF.

    TRY.

        cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                               RECEIVING  p_descr_ref    = lo_obj
                                               EXCEPTIONS type_not_found = 1
                                                          OTHERS         = 2
            ).

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = |TABLE_NOT_FOUD_NAME___{ table_name }|.
        ENDIF.

        temp306 ?= lo_obj.

        lo_struct = temp306.

      CATCH cx_root.

        TRY.
            cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                                   RECEIVING  p_descr_ref    = lo_obj
                                                   EXCEPTIONS type_not_found = 1
                                                              OTHERS         = 2
            ).
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE z2ui5_cx_util_error
                EXPORTING
                  val = |TABLE_NOT_FOUD_NAME___{ table_name }|.
            ENDIF.


            temp307 ?= lo_obj.

            lo_tab = temp307.

            temp308 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp308.
          CATCH cx_root.
            RETURN.
        ENDTRY.

    ENDTRY.

    result = lo_struct->get_components( ).



    LOOP AT result REFERENCE INTO lr_comp
         WHERE as_include = abap_true.


      lt_attri = rtti_get_t_attri_by_include( lr_comp->type ).

      DELETE result.
      INSERT LINES OF lt_attri INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_corresponding.

    FIELD-SYMBOLS <row_in>  TYPE any.
    FIELD-SYMBOLS <row_out> TYPE any.

    LOOP AT val ASSIGNING <row_in>.
      APPEND INITIAL LINE TO tab ASSIGNING <row_out>.
      MOVE-CORRESPONDING <row_in> TO <row_out>.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_get_by_struc.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp310 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp310.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp311 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO lr_attri.


      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE z2ui5_cl_util=>rtti_get_type_kind( <component> ).

        WHEN cl_abap_typedescr=>typekind_table.

        WHEN OTHERS.

          CLEAR temp311.
          temp311-n = lr_attri->name.
          temp311-v = <component>.
          INSERT temp311 INTO TABLE result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_t_range.

    DATA ref TYPE REF TO data.
      DATA ls_filter LIKE LINE OF val.
        FIELD-SYMBOLS <field> TYPE any.

    LOOP AT tab REFERENCE INTO ref.

      LOOP AT val INTO ls_filter.

        IF ls_filter-t_range IS INITIAL.
          CONTINUE.
        ENDIF.


        ASSIGN ref->(ls_filter-name) TO <field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF <field> NOT IN ls_filter-t_range.
          DELETE tab.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_data_by_multi.

    DATA ls_filter LIKE LINE OF val.
    LOOP AT val INTO ls_filter.
      IF lines( ls_filter-t_range ) > 0
        OR lines( ls_filter-t_token ) > 0.
        INSERT ls_filter INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_sql_where.

    DATA ls_filter LIKE LINE OF val.
      DATA lv_field_where TYPE string.
      DATA ls_range LIKE LINE OF ls_filter-t_range.
        DATA lv_cond TYPE string.
    LOOP AT val INTO ls_filter.

      IF ls_filter-t_range IS INITIAL.
        CONTINUE.
      ENDIF.


      lv_field_where = ``.

      LOOP AT ls_filter-t_range INTO ls_range.

        lv_cond = filter_get_sql_cond_by_range( fieldname = ls_filter-name
                                                      range     = ls_range ).
        IF lv_cond IS INITIAL.
          CONTINUE.
        ENDIF.
        IF lv_field_where IS INITIAL.
          lv_field_where = lv_cond.
        ELSE.
          lv_field_where = |{ lv_field_where } OR { lv_cond }|.
        ENDIF.
      ENDLOOP.

      IF lv_field_where IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS INITIAL.
        result = |( { lv_field_where } )|.
      ELSE.
        result = |{ result } AND ( { lv_field_where } )|.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_sql_cond_by_range.

    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_option LIKE range-option.
    DATA lv_like TYPE string.
    lv_low = replace( val  = range-low
                            sub  = `'`
                            with = `''`
                            occ  = 0 ).

    lv_high = replace( val  = range-high
                             sub  = `'`
                             with = `''`
                             occ  = 0 ).

    lv_option = range-option.

    IF range-sign = `E`.
      CASE lv_option.
        WHEN `EQ`. lv_option = `NE`.
        WHEN `NE`. lv_option = `EQ`.
        WHEN `LT`. lv_option = `GE`.
        WHEN `LE`. lv_option = `GT`.
        WHEN `GT`. lv_option = `LE`.
        WHEN `GE`. lv_option = `LT`.
        WHEN `CP`. lv_option = `NP`.
        WHEN `NP`. lv_option = `CP`.
        WHEN `BT`. lv_option = `NB`.
        WHEN `NB`. lv_option = `BT`.
      ENDCASE.
    ENDIF.


    lv_like = ``.
    CASE lv_option.
      WHEN `EQ`.
        result = |{ fieldname } = '{ lv_low }'|.
      WHEN `NE`.
        result = |{ fieldname } <> '{ lv_low }'|.
      WHEN `LT`.
        result = |{ fieldname } < '{ lv_low }'|.
      WHEN `LE`.
        result = |{ fieldname } <= '{ lv_low }'|.
      WHEN `GT`.
        result = |{ fieldname } > '{ lv_low }'|.
      WHEN `GE`.
        result = |{ fieldname } >= '{ lv_low }'|.
      WHEN `CP`.
        lv_like = lv_low.
        REPLACE ALL OCCURRENCES OF `*` IN lv_like WITH `%`.
        REPLACE ALL OCCURRENCES OF `+` IN lv_like WITH `_`.
        result = |{ fieldname } LIKE '{ lv_like }'|.
      WHEN `NP`.
        lv_like = lv_low.
        REPLACE ALL OCCURRENCES OF `*` IN lv_like WITH `%`.
        REPLACE ALL OCCURRENCES OF `+` IN lv_like WITH `_`.
        result = |{ fieldname } NOT LIKE '{ lv_like }'|.
      WHEN `BT`.
        result = |{ fieldname } BETWEEN '{ lv_low }' AND '{ lv_high }'|.
      WHEN `NB`.
        result = |{ fieldname } NOT BETWEEN '{ lv_low }' AND '{ lv_high }'|.
    ENDCASE.

  ENDMETHOD.


  METHOD filter_get_multi_by_sql_where.

    DATA temp312 TYPE string.
    DATA lv_where TYPE string.
    DATA lt_groups TYPE string_table.
    DATA lv_group LIKE LINE OF lt_groups.
      DATA lv_len TYPE i.
      DATA lt_conds TYPE string_table.
      DATA ls_filter TYPE ty_s_filter_multi.
      DATA lv_cond LIKE LINE OF lt_conds.
        DATA ls_range TYPE ty_s_range.
        DATA lv_fieldname TYPE string.
    temp312 = val.

    lv_where = c_trim( temp312 ).
    IF lv_where IS INITIAL.
      RETURN.
    ENDIF.


    lt_groups = filter_sql_split_top_level( val = lv_where
                                                  sep = ` AND ` ).


    LOOP AT lt_groups INTO lv_group.

      lv_group = c_trim( lv_group ).

      lv_len = strlen( lv_group ).

      IF lv_len >= 2
         AND lv_group(1) = `(`
         AND substring( val = lv_group
                        off = lv_len - 1
                        len = 1 ) = `)`.
        lv_group = c_trim( substring( val = lv_group
                                      off = 1
                                      len = lv_len - 2 ) ).
      ENDIF.


      lt_conds = filter_sql_split_top_level( val = lv_group
                                                   sep = ` OR ` ).


      CLEAR ls_filter.


      LOOP AT lt_conds INTO lv_cond.



        CLEAR ls_range.
        CLEAR lv_fieldname.

        filter_get_range_by_sql_cond(
          EXPORTING val       = c_trim( lv_cond )
          IMPORTING fieldname = lv_fieldname
                    range     = ls_range ).

        IF ls_range-option IS INITIAL.
          CONTINUE.
        ENDIF.

        IF ls_filter-name IS INITIAL.
          ls_filter-name = lv_fieldname.
        ENDIF.
        INSERT ls_range INTO TABLE ls_filter-t_range.

      ENDLOOP.

      IF ls_filter-name IS NOT INITIAL.
        INSERT ls_filter INTO TABLE result.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_range_by_sql_cond.
    DATA temp313 TYPE string.
    DATA lv_cond LIKE temp313.
    DATA lv_rest TYPE string.
    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_like TYPE string.

    CLEAR range.
    CLEAR fieldname.


    temp313 = val.

    lv_cond = temp313.
    range-sign = `I`.






    IF lv_cond CS ` NOT BETWEEN `.
      SPLIT lv_cond AT ` NOT BETWEEN ` INTO fieldname lv_rest.
      SPLIT lv_rest AT ` AND ` INTO lv_low lv_high.
      range-option = `NB`.
      range-low    = filter_sql_strip_quotes( lv_low ).
      range-high   = filter_sql_strip_quotes( lv_high ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` BETWEEN `.
      SPLIT lv_cond AT ` BETWEEN ` INTO fieldname lv_rest.
      SPLIT lv_rest AT ` AND ` INTO lv_low lv_high.
      range-option = `BT`.
      range-low    = filter_sql_strip_quotes( lv_low ).
      range-high   = filter_sql_strip_quotes( lv_high ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` NOT LIKE `.
      SPLIT lv_cond AT ` NOT LIKE ` INTO fieldname lv_rest.
      lv_like = filter_sql_strip_quotes( lv_rest ).
      REPLACE ALL OCCURRENCES OF `%` IN lv_like WITH `*`.
      REPLACE ALL OCCURRENCES OF `_` IN lv_like WITH `+`.
      range-option = `NP`.
      range-low    = lv_like.
      RETURN.
    ENDIF.

    IF lv_cond CS ` LIKE `.
      SPLIT lv_cond AT ` LIKE ` INTO fieldname lv_rest.
      lv_like = filter_sql_strip_quotes( lv_rest ).
      REPLACE ALL OCCURRENCES OF `%` IN lv_like WITH `*`.
      REPLACE ALL OCCURRENCES OF `_` IN lv_like WITH `+`.
      range-option = `CP`.
      range-low    = lv_like.
      RETURN.
    ENDIF.

    IF lv_cond CS ` <> `.
      SPLIT lv_cond AT ` <> ` INTO fieldname lv_rest.
      range-option = `NE`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` <= `.
      SPLIT lv_cond AT ` <= ` INTO fieldname lv_rest.
      range-option = `LE`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` >= `.
      SPLIT lv_cond AT ` >= ` INTO fieldname lv_rest.
      range-option = `GE`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` < `.
      SPLIT lv_cond AT ` < ` INTO fieldname lv_rest.
      range-option = `LT`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` > `.
      SPLIT lv_cond AT ` > ` INTO fieldname lv_rest.
      range-option = `GT`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

    IF lv_cond CS ` = `.
      SPLIT lv_cond AT ` = ` INTO fieldname lv_rest.
      range-option = `EQ`.
      range-low    = filter_sql_strip_quotes( lv_rest ).
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD filter_sql_split_top_level.

    DATA temp314 TYPE string.
    DATA lv_val LIKE temp314.
    DATA temp315 TYPE string.
    DATA lv_sep LIKE temp315.
    DATA lv_len TYPE i.
    DATA lv_sep_len TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_start TYPE i.
    DATA lv_pos TYPE i.
    DATA lv_in_quote LIKE abap_false.
      DATA lv_char TYPE string.
    temp314 = val.

    lv_val = temp314.

    temp315 = sep.

    lv_sep = temp315.

    lv_len = strlen( lv_val ).

    lv_sep_len = strlen( lv_sep ).

    lv_depth = 0.

    lv_start = 0.

    lv_pos = 0.

    lv_in_quote = abap_false.

    IF lv_val IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_sep_len = 0.
      INSERT lv_val INTO TABLE result.
      RETURN.
    ENDIF.

    WHILE lv_pos < lv_len.


      lv_char = lv_val+lv_pos(1).

      IF lv_char = `'`.
        IF lv_in_quote = abap_false.
          lv_in_quote = abap_true.
        ELSE.
          lv_in_quote = abap_false.
        ENDIF.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_in_quote = abap_true.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_char = `(`.
        lv_depth = lv_depth + 1.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_char = `)`.
        lv_depth = lv_depth - 1.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.

      IF lv_depth = 0
         AND lv_pos + lv_sep_len <= lv_len
         AND lv_val+lv_pos(lv_sep_len) = lv_sep.
        INSERT substring( val = lv_val
                          off = lv_start
                          len = lv_pos - lv_start ) INTO TABLE result.
        lv_pos = lv_pos + lv_sep_len.
        lv_start = lv_pos.
        CONTINUE.
      ENDIF.

      lv_pos = lv_pos + 1.

    ENDWHILE.

    INSERT substring( val = lv_val
                      off = lv_start ) INTO TABLE result.

  ENDMETHOD.


  METHOD filter_sql_strip_quotes.
    DATA lv_len TYPE i.

    result = c_trim( val ).

    lv_len = strlen( result ).

    IF lv_len >= 2
       AND result(1) = `'`
       AND substring( val = result
                      off = lv_len - 1
                      len = 1 ) = `'`.
      result = substring( val = result
                          off = 1
                          len = lv_len - 2 ).
      result = replace( val  = result
                        sub  = `''`
                        with = `'`
                        occ  = 0 ).
    ENDIF.

  ENDMETHOD.


  METHOD msg_get_t.

    result = z2ui5_cl_util_msg=>msg_get( val = val val2 = val2 ).

  ENDMETHOD.


  METHOD rtti_check_clike.

    DATA lv_type TYPE string.
    lv_type = rtti_get_type_kind( val ).
    CASE lv_type.
      WHEN cl_abap_datadescr=>typekind_char OR
          cl_abap_datadescr=>typekind_clike OR
          cl_abap_datadescr=>typekind_csequence OR
          cl_abap_datadescr=>typekind_string.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD ui5_get_msg_type.

    DATA temp316 TYPE string.
    CASE val.
      WHEN `E`.
        temp316 = cs_ui5_msg_type-e.
      WHEN `S`.
        temp316 = cs_ui5_msg_type-s.
      WHEN `W`.
        temp316 = cs_ui5_msg_type-w.
      WHEN OTHERS.
        temp316 = cs_ui5_msg_type-i.
    ENDCASE.
    result = temp316.

  ENDMETHOD.


  METHOD rtti_create_tab_by_name.

    DATA struct_desc TYPE REF TO cl_abap_typedescr.
    DATA temp317 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp317.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    struct_desc = cl_abap_structdescr=>describe_by_name( val ).

    temp317 ?= struct_desc.

    data_desc = temp317.

    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.


  METHOD msg_get.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp318 LIKE LINE OF lt_msg.
    DATA temp319 LIKE sy-tabix.
    lt_msg = msg_get_t( val = val val2 = val2 ).


    temp319 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp318.
    sy-tabix = temp319.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp318.

  ENDMETHOD.


  METHOD msg_get_collect.

    result = z2ui5_cl_util_msg=>msg_get_collect( val = val val2 = val2 ).

  ENDMETHOD.


  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.


  METHOD msg_get_by_msg.

    DATA temp320 TYPE ty_s_msg.
    DATA ls_msg LIKE temp320.
    CLEAR temp320.
    temp320-id = id.
    temp320-no = no.
    temp320-v1 = v1.
    temp320-v2 = v2.
    temp320-v3 = v3.
    temp320-v4 = v4.

    ls_msg = temp320.
    result = msg_get( ls_msg ).

  ENDMETHOD.


  METHOD c_contains.

    DATA temp321 TYPE string.
    DATA temp4 TYPE xsdboolean.
    temp321 = val.

    temp4 = boolc( temp321 CS sub ).
    result = temp4.

  ENDMETHOD.


  METHOD c_starts_with.

    DATA temp322 TYPE string.
    DATA lv_val LIKE temp322.
    DATA temp323 TYPE string.
    DATA lv_prefix LIKE temp323.
    DATA lv_len TYPE i.
    DATA temp5 TYPE xsdboolean.
    temp322 = val.

    lv_val = temp322.

    temp323 = prefix.

    lv_prefix = temp323.

    lv_len = strlen( lv_prefix ).

    IF strlen( lv_val ) < lv_len.
      result = abap_false.
      RETURN.
    ENDIF.


    temp5 = boolc( lv_val(lv_len) = lv_prefix ).
    result = temp5.

  ENDMETHOD.


  METHOD c_ends_with.

    DATA temp324 TYPE string.
    DATA lv_val LIKE temp324.
    DATA temp325 TYPE string.
    DATA lv_suffix LIKE temp325.
    DATA lv_len_suffix TYPE i.
    DATA lv_len_val TYPE i.
    DATA lv_off TYPE i.
    DATA temp6 TYPE xsdboolean.
    temp324 = val.

    lv_val = temp324.

    temp325 = suffix.

    lv_suffix = temp325.

    lv_len_suffix = strlen( lv_suffix ).

    lv_len_val = strlen( lv_val ).

    IF lv_len_val < lv_len_suffix.
      result = abap_false.
      RETURN.
    ENDIF.


    lv_off = lv_len_val - lv_len_suffix.

    temp6 = boolc( lv_val+lv_off(lv_len_suffix) = lv_suffix ).
    result = temp6.

  ENDMETHOD.


  METHOD c_split.

    SPLIT val AT sep INTO TABLE result.

  ENDMETHOD.


  METHOD c_join.

    DATA lv_line LIKE LINE OF tab.
    LOOP AT tab INTO lv_line.
      IF sy-tabix > 1.
        result = result && sep.
      ENDIF.
      result = result && lv_line.
    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_check_table.

    DATA lv_type_kind TYPE abap_typekind.
    DATA temp7 TYPE xsdboolean.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).

    temp7 = boolc( lv_type_kind = cl_abap_typedescr=>typekind_table ).
    result = temp7.

  ENDMETHOD.


  METHOD rtti_check_structure.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp8 TYPE xsdboolean.

    TRY.

        lo_type = cl_abap_typedescr=>describe_by_data( val ).

        temp8 = boolc( lo_type->kind = cl_abap_typedescr=>kind_struct ).
        result = temp8.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_numeric.

    DATA lv_type_kind TYPE abap_typekind.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).
    CASE lv_type_kind.
      WHEN cl_abap_typedescr=>typekind_int
          OR cl_abap_typedescr=>typekind_int1
          OR cl_abap_typedescr=>typekind_int2
          OR cl_abap_typedescr=>typekind_packed
          OR cl_abap_typedescr=>typekind_float
          OR cl_abap_typedescr=>typekind_decfloat
          OR cl_abap_typedescr=>typekind_decfloat16
          OR cl_abap_typedescr=>typekind_decfloat34
          OR cl_abap_typedescr=>typekind_num.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD time_add_seconds.

    result = cl_abap_tstmp=>add( tstmp = time
                                 secs  = seconds ).

  ENDMETHOD.


  METHOD time_get_stampl_by_date_time.

    DATA ls_sy TYPE z2ui5_cl_util_api=>ty_syst.
    ls_sy = z2ui5_cl_util=>context_get_sy( ).
    CONVERT DATE date TIME time INTO TIME STAMP result TIME ZONE ls_sy-zonlo.

  ENDMETHOD.


  METHOD time_diff_seconds.

    DATA lv_diff TYPE i.
    lv_diff = cl_abap_tstmp=>subtract( tstmp1 = time_to
                                              tstmp2 = time_from ).
    result = lv_diff.

  ENDMETHOD.


  METHOD conv_string_to_date.

    DATA temp326 TYPE string.
    DATA lv_val LIKE temp326.
    DATA temp327 TYPE string.
    DATA lv_fmt LIKE temp327.
    DATA lv_yyyy_off TYPE i.
    DATA lv_mm_off TYPE i.
    DATA lv_dd_off TYPE i.
    DATA lv_clean TYPE string.
    DATA lv_i TYPE i.
      DATA lv_c TYPE string.
    DATA lv_fmt_clean TYPE string.
    DATA lv_year TYPE string.
    DATA lv_month TYPE string.
    DATA lv_day TYPE string.
    DATA lv_pos TYPE i.
    temp326 = val.

    lv_val = temp326.

    temp327 = format.

    lv_fmt = temp327.

    lv_yyyy_off = find( val = lv_fmt sub = `YYYY` ).

    lv_mm_off   = find( val = lv_fmt sub = `MM` ).

    lv_dd_off   = find( val = lv_fmt sub = `DD` ).


    lv_clean = ``.

    lv_i = 0.
    WHILE lv_i < strlen( lv_val ).

      lv_c = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        lv_clean = lv_clean && lv_c.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.


    lv_fmt_clean = ``.
    lv_i = 0.
    WHILE lv_i < strlen( lv_fmt ).
      lv_c = lv_fmt+lv_i(1).
      IF lv_c = `Y` OR lv_c = `M` OR lv_c = `D`.
        lv_fmt_clean = lv_fmt_clean && lv_c.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.


    lv_year  = ``.

    lv_month = ``.

    lv_day   = ``.


    lv_pos = 0.
    lv_i = 0.
    WHILE lv_i < strlen( lv_fmt_clean ).
      lv_c = lv_fmt_clean+lv_i(1).
      CASE lv_c.
        WHEN `Y`.
          lv_year = lv_year && lv_clean+lv_pos(1).
        WHEN `M`.
          lv_month = lv_month && lv_clean+lv_pos(1).
        WHEN `D`.
          lv_day = lv_day && lv_clean+lv_pos(1).
      ENDCASE.
      lv_pos = lv_pos + 1.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = lv_year && lv_month && lv_day.

  ENDMETHOD.


  METHOD conv_date_to_string.

    DATA temp328 TYPE string.
    DATA lv_fmt LIKE temp328.
    DATA temp329 TYPE string.
    DATA lv_date LIKE temp329.
    DATA lv_year TYPE string.
    DATA lv_month TYPE string.
    DATA lv_day TYPE string.
    temp328 = format.

    lv_fmt = temp328.

    temp329 = val.

    lv_date = temp329.


    lv_year  = lv_date(4).

    lv_month = lv_date+4(2).

    lv_day   = lv_date+6(2).

    result = lv_fmt.
    REPLACE `YYYY` IN result WITH lv_year.
    REPLACE `MM`   IN result WITH lv_month.
    REPLACE `DD`   IN result WITH lv_day.

  ENDMETHOD.


  METHOD ui5_msg_box_format.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
      DATA temp330 LIKE LINE OF lt_msg.
      DATA temp331 LIKE sy-tabix.
      DATA temp332 LIKE LINE OF lt_msg.
      DATA temp333 LIKE sy-tabix.
      DATA temp334 LIKE LINE OF lt_msg.
      DATA temp335 LIKE sy-tabix.
      DATA lt_detail_items TYPE string_table.
      DATA temp336 LIKE LINE OF lt_msg.
      DATA lr_msg LIKE REF TO temp336.
        DATA temp337 LIKE LINE OF lt_detail_items.
      DATA temp338 LIKE LINE OF lt_msg.
      DATA temp339 LIKE sy-tabix.
      DATA temp340 LIKE LINE OF lt_msg.
      DATA temp341 LIKE sy-tabix.
    lt_msg = msg_get_t( val ).

    IF lines( lt_msg ) = 1.


      temp331 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp330.
      sy-tabix = temp331.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-text  = temp330-text.


      temp333 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp332.
      sy-tabix = temp333.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type  = to_lower( ui5_get_msg_type( temp332-type ) ).


      temp335 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp334.
      sy-tabix = temp335.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title = ui5_get_msg_type( temp334-type ).

    ELSEIF lines( lt_msg ) > 1.
      result-text = | { lines( lt_msg ) } Messages found: |.



      LOOP AT lt_msg REFERENCE INTO lr_msg.

        temp337 = |<li>{ lr_msg->text }</li>|.
        INSERT temp337 INTO TABLE lt_detail_items.
      ENDLOOP.
      result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.


      temp339 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp338.
      sy-tabix = temp339.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title   = ui5_get_msg_type( temp338-type ).


      temp341 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp340.
      sy-tabix = temp341.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type    = ui5_get_msg_type( temp340-type ).

    ELSE.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_check_serializable.
        DATA temp342 TYPE REF TO if_serializable_object.
        DATA lo_dummy LIKE temp342.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.

        temp342 ?= val.

        lo_dummy = temp342.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD app_get_url.

    DATA lt_param TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp343 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_param = url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.

    CLEAR temp343.
    temp343-n = `app_start`.
    temp343-v = to_lower( classname ).
    INSERT temp343 INTO TABLE lt_param.

    result = |{ origin }{ pathname }?| && url_param_create_url( lt_param ) && hash.

  ENDMETHOD.


  METHOD app_get_url_source_code.

    result = |{ origin }/sap/bc/adt/oo/classes/{ classname }/source/main|.

  ENDMETHOD.


  METHOD cal_get_weekday.

    " 1900-01-01 was a Monday, so the day distance modulo 7 yields the weekday
    DATA temp344 TYPE d.
    DATA lv_days TYPE d.
    temp344 = `19000101`.

    lv_days = date - temp344.
    result = lv_days MOD 7 + 1.

  ENDMETHOD.


  METHOD cal_is_weekend.

    DATA temp9 TYPE xsdboolean.
    temp9 = boolc( cal_get_weekday( date ) >= 6 ).
    result = temp9.

  ENDMETHOD.


  METHOD cal_is_workday.
    DATA temp10 TYPE xsdboolean.

    IF calendar_id IS NOT INITIAL.
      z2ui5_cl_util=>x_raise( `cal_is_workday: factory calendar support is not yet implemented` ).
    ENDIF.


    temp10 = boolc( cal_is_weekend( date ) = abap_false ).
    result = temp10.

  ENDMETHOD.


  METHOD cal_add_workdays.

    DATA lv_remaining TYPE i.
    DATA temp345 TYPE i.
    DATA lv_step LIKE temp345.
    lv_remaining = abs( days ).

    IF days < 0.
      temp345 = -1.
    ELSE.
      temp345 = 1.
    ENDIF.

    lv_step = temp345.

    result = date.
    WHILE lv_remaining > 0.
      result = result + lv_step.
      IF cal_is_workday( date = result calendar_id = calendar_id ) = abap_true.
        lv_remaining = lv_remaining - 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD cal_count_workdays.

    DATA lv_date LIKE date_from.
    DATA temp346 TYPE i.
    DATA lv_step LIKE temp346.
    lv_date = date_from.

    IF date_to < date_from.
      temp346 = -1.
    ELSE.
      temp346 = 1.
    ENDIF.

    lv_step = temp346.

    WHILE lv_date <> date_to.
      lv_date = lv_date + lv_step.
      IF cal_is_workday( date = lv_date calendar_id = calendar_id ) = abap_true.
        result = result + 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD zip_pack.

    DATA lo_zip TYPE REF TO object.
        DATA ls_file LIKE LINE OF files.
        DATA x TYPE REF TO cx_root.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').

        LOOP AT files INTO ls_file.
          CALL METHOD lo_zip->('ADD')
            EXPORTING
              name    = ls_file-name
              content = ls_file-content.
        ENDLOOP.
        CALL METHOD lo_zip->('SAVE')
          RECEIVING
            zip = result.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.


  METHOD zip_unpack.

    DATA lo_zip    TYPE REF TO object.
    DATA lv_name   TYPE string.
    DATA ls_result LIKE LINE OF result.

    FIELD-SYMBOLS <files> TYPE ANY TABLE.
    FIELD-SYMBOLS <file>  TYPE any.
    FIELD-SYMBOLS <name>  TYPE any.
        DATA x TYPE REF TO cx_root.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').
        CALL METHOD lo_zip->('LOAD')
          EXPORTING
            zip = val.

        ASSIGN lo_zip->('FILES') TO <files>.
        LOOP AT <files> ASSIGNING <file>.
          ASSIGN COMPONENT `NAME` OF STRUCTURE <file> TO <name>.
          lv_name = <name>.

          CLEAR ls_result.
          ls_result-name = lv_name.
          CALL METHOD lo_zip->('GET')
            EXPORTING
              name    = lv_name
            IMPORTING
              content = ls_result-content.
          INSERT ls_result INTO TABLE result.
        ENDLOOP.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.


  METHOD lock_set.

    result = lock_call_function( val     = val
                                 t_param = t_param ).

  ENDMETHOD.


  METHOD lock_delete.

    result = lock_call_function( val     = lock_get_dequeue_by_enqueue( val )
                                 t_param = t_param ).

  ENDMETHOD.


  METHOD lock_get_dequeue_by_enqueue.

    result = replace( val  = c_trim_upper( val )
                      sub  = `ENQUEUE_`
                      with = `DEQUEUE_` ).

  ENDMETHOD.


  METHOD lock_call_function.

    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA ls_lock_param TYPE ty_s_lock_param.
    DATA lr_value      TYPE REF TO string.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
        DATA temp11 TYPE xsdboolean.

    TRY.
        LOOP AT t_param INTO ls_lock_param.
          ls_param-name = ls_lock_param-name.
          ls_param-kind = abap_func_exporting.
          CREATE DATA lr_value.
          lr_value->* = ls_lock_param-value.
          ls_param-value = lr_value.
          INSERT ls_param INTO TABLE lt_param.
        ENDLOOP.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = c_trim_upper( val ).
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.


        temp11 = boolc( sy-subrc = 0 ).
        result = temp11.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD lock_read.

    DATA lr_enq TYPE REF TO data.
    FIELD-SYMBOLS <lt_enq>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_enq>   TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    DATA lv_client     TYPE c LENGTH 3.
    DATA lv_name       TYPE c LENGTH 30.
    DATA lv_uname      TYPE c LENGTH 12.
    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
    DATA ls_lock       TYPE ty_s_lock.
        DATA lx_error TYPE REF TO z2ui5_cx_util_error.
        DATA lx_root TYPE REF TO cx_root.

    TRY.
        CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`).
        ASSIGN lr_enq->* TO <lt_enq>.

        IF client IS INITIAL.
          lv_client = context_get_sy( )-mandt.
        ELSE.
          lv_client = client.
        ENDIF.
        lv_name  = lock_object.
        lv_uname = user.

        ls_param-name = `GCLIENT`.
        ls_param-kind = abap_func_exporting.
        GET REFERENCE OF lv_client INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `GNAME`.
        GET REFERENCE OF lv_name INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `GUNAME`.
        GET REFERENCE OF lv_uname INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `ENQ`.
        ls_param-kind = abap_func_tables.
        GET REFERENCE OF <lt_enq> INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = `ENQUEUE_READ`.
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = `LOCK_READ_FAILED`.
        ENDIF.

        LOOP AT <lt_enq> ASSIGNING <ls_enq>.
          CLEAR ls_lock.
          ASSIGN COMPONENT `GNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-lock_object = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GARG` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-argument = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-user = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GMODE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-mode = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GCLIENT` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-client = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GTDATE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-date = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GTTIME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-time = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUSR` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-owner = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUSRVB` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-owner_vb = <lv_value>.
          ENDIF.
          INSERT ls_lock INTO TABLE result.
        ENDLOOP.


      CATCH z2ui5_cx_util_error INTO lx_error.
        RAISE EXCEPTION lx_error.

      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = lx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD lock_delete_entries.

    DATA lr_enq TYPE REF TO data.
    FIELD-SYMBOLS <lt_enq>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_enq>   TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    DATA lr_row        TYPE REF TO data.
    DATA ls_lock       TYPE ty_s_lock.
    DATA lv_check_upd  TYPE i.
    DATA lv_subrc      TYPE sy-subrc.
    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
        DATA temp12 TYPE xsdboolean.

    TRY.
        CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`).
        ASSIGN lr_enq->* TO <lt_enq>.
        CREATE DATA lr_row TYPE (`SEQG3`).
        ASSIGN lr_row->* TO <ls_enq>.

        LOOP AT t_lock INTO ls_lock.
          CLEAR <ls_enq>.
          ASSIGN COMPONENT `GNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-lock_object.
          ENDIF.
          ASSIGN COMPONENT `GARG` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-argument.
          ENDIF.
          ASSIGN COMPONENT `GUNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-user.
          ENDIF.
          ASSIGN COMPONENT `GMODE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-mode.
          ENDIF.
          ASSIGN COMPONENT `GCLIENT` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-client.
          ENDIF.
          ASSIGN COMPONENT `GUSR` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-owner.
          ENDIF.
          ASSIGN COMPONENT `GUSRVB` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-owner_vb.
          ENDIF.
          INSERT <ls_enq> INTO TABLE <lt_enq>.
        ENDLOOP.

        IF <lt_enq> IS INITIAL.
          result = abap_true.
          RETURN.
        ENDIF.

        ls_param-name = `CHECK_UPD_REQUESTS`.
        ls_param-kind = abap_func_exporting.
        GET REFERENCE OF lv_check_upd INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `SUBRC`.
        ls_param-kind = abap_func_importing.
        GET REFERENCE OF lv_subrc INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `ENQ`.
        ls_param-kind = abap_func_tables.
        GET REFERENCE OF <lt_enq> INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = `ENQUE_DELETE`.
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.


        temp12 = boolc( sy-subrc = 0 AND lv_subrc = 0 ).
        result = temp12.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
