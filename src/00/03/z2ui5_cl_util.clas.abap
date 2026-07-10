CLASS z2ui5_cl_util DEFINITION
  PUBLIC
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

    " Environment-abstracted character/format constants. Callers must read
    " these from z2ui5_cl_util instead of referencing cl_abap_char_utilities /
    " cl_abap_format directly, so the dependency on those SAP standard classes
    " lives in exactly one place (this class' class_constructor) and can be
    " ported once for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-DATA cv_char_utilities_newline        TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_utilities_cr_lf          TYPE c LENGTH 2 READ-ONLY.
    CLASS-DATA cv_char_utilities_horizontal_tab TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_utilities_charsize       TYPE i          READ-ONLY.
    CLASS-DATA cv_format_e_xml_attr             TYPE i          READ-ONLY.

    " RTTI type-kind / kind / visibility constants, so callers can branch on
    " stored type_kind/kind fields without referencing cl_abap_typedescr /
    " cl_abap_objectdescr directly.
    CLASS-DATA cv_typedescr_typekind_table   TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_dref    TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_oref    TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_struct1 TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_typekind_struct2 TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_kind_struct      TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_typedescr_kind_ref         TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_objectdescr_public         TYPE c LENGTH 1 READ-ONLY.

    CLASS-METHODS class_constructor.

    " Wraps the ABAP `ROLLBACK WORK` statement so the dependency on the
    " database transaction control lives in one place and can be ported once
    " for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-METHODS db_rollback.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.
    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.
    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.
    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH EMPTY KEY.

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
      ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH EMPTY KEY.

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
    TYPES ty_t_zip_file TYPE STANDARD TABLE OF ty_s_zip_file WITH EMPTY KEY.

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

    " Extracts the DDIC data element name (`\TYPE=...` part of the absolute
    " name) from a component's elementary type, so callers do not reference
    " cl_abap_elemdescr directly.
    CLASS-METHODS rtti_get_ddic_type_name
      IMPORTING
        type          TYPE REF TO cl_abap_datadescr
      RETURNING
        VALUE(result) TYPE string.

    " Thin wrappers around cl_abap_typedescr=>describe_by_data(_ref), so the
    " RTTI describe calls live in one place. Return cl_abap_typedescr, which
    " already carries type_kind / kind / absolute_name.
    CLASS-METHODS rtti_get_typedescr_by_data_ref
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_typedescr.

    CLASS-METHODS rtti_get_typedescr_by_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_typedescr.

    TYPES:
      BEGIN OF ty_s_sel_tab_type,
        tabledescr       TYPE REF TO cl_abap_tabledescr,
        check_table_line TYPE abap_bool,
      END OF ty_s_sel_tab_type.

    " Builds a working table type from the line type of the source table. If
    " the source line is elementary it is wrapped into a `TAB_LINE` component
    " (check_table_line reports whether that happened). By default no extra
    " column is added; when add_sel_field = abap_true an additional boolean
    " flag column named sel_field_name (default `ZZSELKZ`) is inserted.
    " Keeps the dynamic RTTI type construction (describe_by_data / create) in
    " one place so it can be ported once for non-ABAP runtimes.
    CLASS-METHODS rtti_create_sel_tab_type
      IMPORTING
        ir_tab         TYPE REF TO data
        add_sel_field  TYPE abap_bool DEFAULT abap_false
        sel_field_name TYPE clike     DEFAULT `ZZSELKZ`
      RETURNING
        VALUE(result)  TYPE ty_s_sel_tab_type.

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
        VALUE(result) TYPE ty_t_fix_val ##NEEDED.

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

    " ========== String Extras ==========

    CLASS-METHODS c_pad_left
      IMPORTING
        val           TYPE clike
        len           TYPE i
        pad           TYPE c DEFAULT '0'
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_pad_right
      IMPORTING
        val           TYPE clike
        len           TYPE i
        pad           TYPE c DEFAULT ' '
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_truncate
      IMPORTING
        val           TYPE clike
        max           TYPE i
        ellipsis      TYPE string DEFAULT `...`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_substring_safe
      IMPORTING
        val           TYPE clike
        off           TYPE i DEFAULT 0
        len           TYPE i DEFAULT -1
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_replace_all
      IMPORTING
        val           TYPE clike
        sub           TYPE clike
        new_val       TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_is_blank
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== Number Formatting ==========

    CLASS-METHODS conv_number_to_string
      IMPORTING
        val           TYPE numeric
        decimals      TYPE i DEFAULT -1
        sep_thousands TYPE c DEFAULT ''
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_string_to_number
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE decfloat34.

    " ========== i18n / Text Resolution ==========

    CLASS-METHODS text_get
      IMPORTING
        msgid         TYPE clike
        msgno         TYPE clike
        v1            TYPE clike OPTIONAL
        v2            TYPE clike OPTIONAL
        v3            TYPE clike OPTIONAL
        v4            TYPE clike OPTIONAL
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE string.

    " ========== Itab Extras ==========

    CLASS-METHODS itab_sort_by
      IMPORTING
        fieldname  TYPE clike
        descending TYPE abap_bool DEFAULT abap_false
      CHANGING
        tab        TYPE STANDARD TABLE.

    CLASS-METHODS itab_slice
      IMPORTING
        tab           TYPE STANDARD TABLE
        !from         TYPE i DEFAULT 1
        !to           TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS itab_paginate
      IMPORTING
        tab           TYPE STANDARD TABLE
        page          TYPE i DEFAULT 1
        page_size     TYPE i DEFAULT 20
      EXPORTING
        VALUE(result) TYPE REF TO data
        total_count   TYPE i
        total_pages   TYPE i.

    CLASS-METHODS itab_to_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS itab_from_json
      IMPORTING
        val  TYPE clike
      CHANGING
        data TYPE any.

    CLASS-METHODS itab_count_by
      IMPORTING
        tab           TYPE STANDARD TABLE
        fieldname     TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    " ========== Validation Helpers ==========

    CLASS-METHODS check_is_email
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_is_numeric_string
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_is_date_valid
      IMPORTING
        val           TYPE clike
        format        TYPE clike DEFAULT `YYYY-MM-DD`
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_is_guid
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_max_length
      IMPORTING
        val           TYPE clike
        max           TYPE i
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== Deep Comparison ==========

    CLASS-METHODS data_equals
      IMPORTING
        a             TYPE any
        b             TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_field_diff,
        fieldname TYPE string,
        old_value TYPE string,
        new_value TYPE string,
      END OF ty_s_field_diff.
    TYPES ty_t_field_diff TYPE STANDARD TABLE OF ty_s_field_diff WITH EMPTY KEY.

    CLASS-METHODS data_diff
      IMPORTING
        old           TYPE any
        new           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_field_diff.

    " ========== Stopwatch ==========

    CLASS-METHODS time_measure_start
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_measure_stop
      IMPORTING
        start_time    TYPE timestampl
      RETURNING
        VALUE(result) TYPE i.

    " ========== Authorization Check ==========

    CLASS-METHODS auth_check
      IMPORTING
        object        TYPE clike
        field         TYPE clike
        !value        TYPE clike
        activity      TYPE clike DEFAULT '03'
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== Enum/Domain Helpers ==========

    CLASS-METHODS enum_to_text
      IMPORTING
        domain        TYPE clike
        !value        TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS enum_get_all
      IMPORTING
        domain        TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    " ========== Deep Field Access ==========

    CLASS-METHODS data_get_by_path
      IMPORTING
        data          TYPE any
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_set_by_path
      IMPORTING
        path  TYPE clike
        !value TYPE clike
      CHANGING
        data  TYPE any.

    " ========== BAL Extensions ==========

    TYPES:
      BEGIN OF ty_s_bal_header,
        log_handle  TYPE string,
        object      TYPE string,
        subobject   TYPE string,
        external_id TYPE string,
        log_date    TYPE d,
        log_time    TYPE t,
        user        TYPE string,
        msg_count   TYPE i,
      END OF ty_s_bal_header.
    TYPES ty_t_bal_header TYPE STANDARD TABLE OF ty_s_bal_header WITH EMPTY KEY.

    CLASS-METHODS bal_search
      IMPORTING
        object        TYPE clike OPTIONAL
        subobject     TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        date_from     TYPE d OPTIONAL
        date_to       TYPE d OPTIONAL
        !user         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_bal_header.

    CLASS-METHODS bal_read_latest
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS bal_delete_before
      IMPORTING
        object    TYPE clike
        subobject TYPE clike OPTIONAL
        !days     TYPE i DEFAULT 30.

    CLASS-METHODS bal_read_by_type
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
        msg_type      TYPE clike DEFAULT `E`
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS bal_count
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE i.

    " ========== Transport Extensions ==========

    TYPES:
      BEGIN OF ty_s_tr_object,
        pgmid    TYPE string,
        object   TYPE string,
        obj_name TYPE string,
      END OF ty_s_tr_object.
    TYPES ty_t_tr_object TYPE STANDARD TABLE OF ty_s_tr_object WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_tr_request,
        trkorr      TYPE string,
        description TYPE string,
        owner       TYPE string,
        status      TYPE string,
        type        TYPE string,
      END OF ty_s_tr_request.
    TYPES ty_t_tr_request TYPE STANDARD TABLE OF ty_s_tr_request WITH EMPTY KEY.

    CLASS-METHODS tr_get_objects
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_tr_object.

    CLASS-METHODS tr_get_user_requests
      IMPORTING
        !user         TYPE clike DEFAULT sy-uname
        request_type  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_tr_request.

    CLASS-METHODS tr_get_description
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS tr_is_released
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS tr_add_object
      IMPORTING
        trkorr  TYPE clike
        pgmid   TYPE clike DEFAULT 'R3TR'
        object  TYPE clike
        obj_name TYPE clike.

    " ========== Lock Extensions ==========

    CLASS-METHODS lock_is_locked
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_get_owner
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lock_set_wait
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
        retries       TYPE i DEFAULT 5
        delay_ms      TYPE i DEFAULT 500
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== Number Range ==========

    CLASS-METHODS numrange_get_next
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike DEFAULT `01`
      RETURNING
        VALUE(result) TYPE string.

    " ========== Change Documents ==========

    TYPES:
      BEGIN OF ty_s_changdoc,
        changenr  TYPE string,
        username  TYPE string,
        udate     TYPE d,
        utime     TYPE t,
        tcode     TYPE string,
        fieldname TYPE string,
        old_value TYPE string,
        new_value TYPE string,
        tabname   TYPE string,
        chngind   TYPE string,
      END OF ty_s_changdoc.
    TYPES ty_t_changdoc TYPE STANDARD TABLE OF ty_s_changdoc WITH EMPTY KEY.

    CLASS-METHODS changdoc_read
      IMPORTING
        objectclass   TYPE clike
        objectid      TYPE clike
        date_from     TYPE d DEFAULT '19000101'
        date_to       TYPE d DEFAULT '99991231'
      RETURNING
        VALUE(result) TYPE ty_t_changdoc.

    " ========== Background Job ==========

    CLASS-METHODS job_submit_report
      IMPORTING
        report          TYPE clike
        variant         TYPE clike OPTIONAL
        start_immediate TYPE abap_bool DEFAULT abap_true
        job_name        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE string.

    " ========== Email ==========

    CLASS-METHODS mail_send
      IMPORTING
        !to      TYPE string
        subject  TYPE string
        body     TYPE string
        html     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE abap_bool.


    TYPES:
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_syst,
        index TYPE i,
        pagno TYPE i,
        tabix TYPE i,
        tfill TYPE i,
        tlopc TYPE i,
        tmaxl TYPE i,
        toccu TYPE i,
        ttabc TYPE i,
        tstis TYPE i,
        ttabi TYPE i,
        dbcnt TYPE i,
        fdpos TYPE i,
        colno TYPE i,
        linct TYPE i,
        linno TYPE i,
        linsz TYPE i,
        pagct TYPE i,
        macol TYPE i,
        marow TYPE i,
        tleng TYPE i,
        sfoff TYPE i,
        willi TYPE i,
        lilli TYPE i,
        subrc TYPE i,
        fleng TYPE i,
        cucol TYPE i,
        curow TYPE i,
        lsind TYPE i,
        listi TYPE i,
        stepl TYPE i,
        tpagi TYPE i,
        winx1 TYPE i,
        winy1 TYPE i,
        winx2 TYPE i,
        winy2 TYPE i,
        winco TYPE i,
        winro TYPE i,
        windi TYPE i,
        srows TYPE i,
        scols TYPE i,
        loopc TYPE i,
        folen TYPE i,
        fodec TYPE i,
        tzone TYPE i,
        dayst TYPE c LENGTH 1,
        ftype TYPE c LENGTH 1,
        appli TYPE x LENGTH 2,
        fdayw TYPE int1,
        ccurs TYPE p LENGTH 9 DECIMALS 0,
        ccurt TYPE p LENGTH 9 DECIMALS 0,
        debug TYPE c LENGTH 1,
        ctype TYPE c LENGTH 1,
        input TYPE c LENGTH 1,
        langu TYPE c LENGTH 1,
        modno TYPE i,
        batch TYPE c LENGTH 1,
        binpt TYPE c LENGTH 1,
        calld TYPE c LENGTH 1,
        dynnr TYPE c LENGTH 4,
        dyngr TYPE c LENGTH 4,
        newpa TYPE c LENGTH 1,
        pri40 TYPE c LENGTH 1,
        rstrt TYPE c LENGTH 1,
        wtitl TYPE c LENGTH 1,
        cpage TYPE i,
        dbnam TYPE c LENGTH 20,
        mandt TYPE c LENGTH 3,
        prefx TYPE c LENGTH 3,
        fmkey TYPE c LENGTH 3,
        pexpi TYPE n LENGTH 1,
        prini TYPE n LENGTH 1,
        primm TYPE c LENGTH 1,
        prrel TYPE c LENGTH 1,
        playo TYPE c LENGTH 5,
        prbig TYPE c LENGTH 1,
        playp TYPE c LENGTH 1,
        prnew TYPE c LENGTH 1,
        prlog TYPE c LENGTH 1,
        pdest TYPE c LENGTH 4,
        plist TYPE c LENGTH 12,
        pauth TYPE n LENGTH 2,
        prdsn TYPE c LENGTH 6,
        pnwpa TYPE c LENGTH 1,
        callr TYPE c LENGTH 8,
        repi2 TYPE c LENGTH 40,
        rtitl TYPE c LENGTH 70,
        prrec TYPE c LENGTH 12,
        prtxt TYPE c LENGTH 68,
        prabt TYPE c LENGTH 12,
        lpass TYPE c LENGTH 4,
        nrpag TYPE c LENGTH 1,
        paart TYPE c LENGTH 16,
        prcop TYPE n LENGTH 3,
        batzs TYPE c LENGTH 1,
        bspld TYPE c LENGTH 1,
        brep4 TYPE c LENGTH 4,
        batzo TYPE c LENGTH 1,
        batzd TYPE c LENGTH 1,
        batzw TYPE c LENGTH 1,
        batzm TYPE c LENGTH 1,
        ctabl TYPE c LENGTH 4,
        dbsys TYPE c LENGTH 10,
        dcsys TYPE c LENGTH 4,
        macdb TYPE c LENGTH 4,
        sysid TYPE c LENGTH 8,
        opsys TYPE c LENGTH 10,
        pfkey TYPE c LENGTH 20,
        saprl TYPE c LENGTH 4,
        tcode TYPE c LENGTH 20,
        ucomm TYPE c LENGTH 70,
        cfwae TYPE c LENGTH 5,
        chwae TYPE c LENGTH 5,
        spono TYPE n LENGTH 10,
        sponr TYPE n LENGTH 10,
        waers TYPE c LENGTH 5,
        cdate TYPE d,
        datum TYPE d,
        slset TYPE c LENGTH 14,
        subty TYPE x LENGTH 1,
        subcs TYPE c LENGTH 1,
        group TYPE c LENGTH 1,
        ffile TYPE c LENGTH 8,
        uzeit TYPE t,
        dsnam TYPE c LENGTH 8,
        tabid TYPE c LENGTH 8,
        tfdsn TYPE c LENGTH 8,
        uname TYPE c LENGTH 12,
        lstat TYPE c LENGTH 16,
        abcde TYPE c LENGTH 26,
        marky TYPE c LENGTH 1,
        sfnam TYPE c LENGTH 30,
        tname TYPE c LENGTH 30,
        msgli TYPE c LENGTH 60,
        title TYPE c LENGTH 70,
        entry TYPE c LENGTH 72,
        lisel TYPE c LENGTH 255,
        uline TYPE c LENGTH 255,
        xcode TYPE c LENGTH 70,
        cprog TYPE c LENGTH 40,
        xprog TYPE c LENGTH 40,
        xform TYPE c LENGTH 30,
        ldbpg TYPE c LENGTH 40,
        tvar0 TYPE c LENGTH 20,
        tvar1 TYPE c LENGTH 20,
        tvar2 TYPE c LENGTH 20,
        tvar3 TYPE c LENGTH 20,
        tvar4 TYPE c LENGTH 20,
        tvar5 TYPE c LENGTH 20,
        tvar6 TYPE c LENGTH 20,
        tvar7 TYPE c LENGTH 20,
        tvar8 TYPE c LENGTH 20,
        tvar9 TYPE c LENGTH 20,
        msgid TYPE c LENGTH 20,
        msgty TYPE c LENGTH 1,
        msgno TYPE n LENGTH 3,
        msgv1 TYPE c LENGTH 50,
        msgv2 TYPE c LENGTH 50,
        msgv3 TYPE c LENGTH 50,
        msgv4 TYPE c LENGTH 50,
        oncom TYPE c LENGTH 1,
        vline TYPE c LENGTH 1,
        winsl TYPE c LENGTH 79,
        staco TYPE i,
        staro TYPE i,
        datar TYPE c LENGTH 1,
        host  TYPE c LENGTH 32,
        locdb TYPE c LENGTH 1,
        locop TYPE c LENGTH 1,
        datlo TYPE d,
        timlo TYPE t,
        zonlo TYPE c LENGTH 6,
      END OF ty_syst.

    TYPES:
      BEGIN OF ty_s_data_element_text,
        header TYPE string,
        short  TYPE string,
        medium TYPE string,
        long   TYPE string,
      END OF ty_s_data_element_text.

    TYPES:
      BEGIN OF ty_s_class_descr,
        classname   TYPE string,
        description TYPE string,
      END OF ty_s_class_descr.
    TYPES ty_t_classes TYPE STANDARD TABLE OF ty_s_class_descr WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_stack,
        class   TYPE string,
        include TYPE string,
        method  TYPE string,
        line    TYPE string,
      END OF ty_s_stack.
    TYPES ty_t_stack TYPE STANDARD TABLE OF ty_s_stack WITH DEFAULT KEY.

    CLASS-METHODS bal_read
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS bal_create
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE ty_t_msg.

    CLASS-METHODS bal_update
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE ty_t_msg.

    CLASS-METHODS bal_delete
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike.

    CLASS-METHODS context_get_callstack
      RETURNING
        VALUE(result) TYPE ty_t_stack.

    CLASS-METHODS context_get_tenant
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS context_get_sy
      RETURNING
        VALUE(result) TYPE ty_syst.

    CLASS-METHODS context_check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

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
        VALUE(result) TYPE ty_s_data_element_text.

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
        VALUE(result) TYPE ty_t_classes.

    CLASS-METHODS rtti_get_t_fixvalues
      IMPORTING
        elemdescr     TYPE REF TO cl_abap_elemdescr
        langu         TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_fix_val.

    CLASS-METHODS rtti_get_table_desrc
      IMPORTING
        tabname       TYPE clike
        langu         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

    CLASS-METHODS tr_create
      IMPORTING
        text          TYPE clike
        target        TYPE clike
        type          TYPE clike DEFAULT `T`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS tr_release
      IMPORTING
        trkorr       TYPE clike
        ignore_locks TYPE abap_bool DEFAULT abap_true.

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


    CLASS-DATA gv_check_cloud TYPE abap_bool.
    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

    CLASS-METHODS bal_cloud_add_items
      IMPORTING
        log   TYPE REF TO object
        t_log TYPE ty_t_msg.

    CLASS-METHODS bal_cloud_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS bal_std_msg_add
      IMPORTING
        handle TYPE any
        t_log  TYPE ty_t_msg.

    CLASS-METHODS bal_std_load_handles
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_std_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_std_filter_add
      IMPORTING
        comp   TYPE clike
        value  TYPE clike
      CHANGING
        filter TYPE any.

    CLASS-METHODS bal_std_map_msg
      IMPORTING
        msg           TYPE any
      RETURNING
        VALUE(result) TYPE ty_s_msg.

ENDCLASS.



CLASS z2ui5_cl_util IMPLEMENTATION.


  METHOD class_constructor.

    cv_char_utilities_newline        = cl_abap_char_utilities=>newline.
    cv_char_utilities_cr_lf          = cl_abap_char_utilities=>cr_lf.
    cv_char_utilities_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.
    cv_char_utilities_charsize       = cl_abap_char_utilities=>charsize.
    cv_format_e_xml_attr             = cl_abap_format=>e_xml_attr.

    cv_typedescr_typekind_table      = cl_abap_typedescr=>typekind_table.
    cv_typedescr_typekind_dref       = cl_abap_typedescr=>typekind_dref.
    cv_typedescr_typekind_oref       = cl_abap_typedescr=>typekind_oref.
    cv_typedescr_typekind_struct1    = cl_abap_typedescr=>typekind_struct1.
    cv_typedescr_typekind_struct2    = cl_abap_typedescr=>typekind_struct2.
    cv_typedescr_kind_struct         = cl_abap_typedescr=>kind_struct.
    cv_typedescr_kind_ref            = cl_abap_typedescr=>kind_ref.
    cv_objectdescr_public            = cl_abap_objectdescr=>public.

  ENDMETHOD.


  METHOD db_rollback.

    ROLLBACK WORK.

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
        DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).

        " all supported boolean types are character-like flags, this check
        " filters out every other type before the name based cache lookup
        IF lo_descr->type_kind <> cl_abap_typedescr=>typekind_char.
          RETURN.
        ENDIF.

        DATA(lv_abs_name) = CONV string( lo_descr->absolute_name ).

        READ TABLE mt_bool_cache REFERENCE INTO DATA(lr_cache)
             WITH TABLE KEY absolute_name = lv_abs_name.
        IF sy-subrc = 0.
          result = lr_cache->is_bool.
          RETURN.
        ENDIF.

        DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).

        INSERT VALUE #( absolute_name = lv_abs_name is_bool = result ) INTO TABLE mt_bool_cache.

      CATCH cx_root ##NO_HANDLER.
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

    IF val IS NOT BOUND.
      result = abap_false.
      RETURN.
    ENDIF.
    result = xsdbool( check_unassign_initial( val ) = abap_false ).

  ENDMETHOD.


  METHOD check_unassign_initial.

    IF val IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.

    FIELD-SYMBOLS <any> TYPE data.
    ASSIGN val->* TO <any>.

    result = xsdbool( <any> IS INITIAL ).

  ENDMETHOD.


  METHOD conv_copy_ref_data.

    FIELD-SYMBOLS <from>   TYPE data.
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

    result = shift_left( shift_right( CONV string( val ) ) ).
    result = shift_right( val = result
                          sub = cv_char_utilities_horizontal_tab ).
    result = shift_left( val = result
                         sub = cv_char_utilities_horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    result = to_lower( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    result = to_upper( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD filter_itab.

    DATA ref TYPE REF TO data.

    LOOP AT val REFERENCE INTO ref.

      LOOP AT filter INTO DATA(ls_filter).

        ASSIGN ref->(ls_filter-name) TO FIELD-SYMBOL(<field>).
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

    LOOP AT rtti_get_t_attri_by_any( val ) REFERENCE INTO DATA(lr_comp).
      INSERT VALUE #( name = lr_comp->name ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_range_by_token.

    DATA(lv_value) = val.
    DATA(lv_length) = strlen( lv_value ) - 1.

    CASE lv_value(1).

      WHEN `=`.
        result = VALUE #( sign   = `I`
                          option = `EQ`
                          low    = lv_value+1 ).
      WHEN `<`.
        IF lv_value+1(1) = `=`.
          result = VALUE #( sign   = `I`
                            option = `LE`
                            low    = lv_value+2 ).
        ELSE.
          result = VALUE #( sign   = `I`
                            option = `LT`
                            low    = lv_value+1 ).
        ENDIF.
      WHEN `>`.
        IF lv_value+1(1) = `=`.
          result = VALUE #( sign   = `I`
                            option = `GE`
                            low    = lv_value+2 ).
        ELSE.
          result = VALUE #( sign   = `I`
                            option = `GT`
                            low    = lv_value+1 ).
        ENDIF.

      WHEN `*`.
        IF lv_value+lv_length(1) = `*`.
          lv_value = substring( val = lv_value off = 1 len = lv_length - 1 ).
          result = VALUE #( sign   = `I`
                            option = `CP`
                            low    = lv_value ).
        ENDIF.

      WHEN OTHERS.
        IF lv_value CS `...`.
          SPLIT lv_value AT `...` INTO result-low result-high.
          result-sign   = `I`.
          result-option = `BT`.
        ELSE.
          result = VALUE #( sign   = `I`
                            option = `EQ`
                            low    = lv_value ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD filter_update_tokens.

    result = val.
    DATA(lr_filter) = REF #( result[ name = name ] ).
    LOOP AT lr_filter->t_token_removed INTO DATA(ls_token).
      DELETE lr_filter->t_token WHERE key = ls_token-key.
    ENDLOOP.

    LOOP AT lr_filter->t_token_added INTO ls_token.
      INSERT VALUE #( key      = ls_token-key
                      text     = ls_token-text
                      visible  = abap_true
                      editable = abap_true ) INTO TABLE lr_filter->t_token.
    ENDLOOP.

    CLEAR lr_filter->t_token_removed.
    CLEAR lr_filter->t_token_added.

    DATA(lt_range) = z2ui5_cl_util=>filter_get_range_t_by_token_t( result[ name = name ]-t_token ).
    lr_filter->t_range = lt_range.

  ENDMETHOD.


  METHOD filter_get_range_t_by_token_t.

    LOOP AT val INTO DATA(ls_token).
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_token_range_mapping.

    result = VALUE #( (   n = `EQ`      v = `={LOW}` )
                      (   n = `LT`      v = `<{LOW}` )
                      (   n = `LE`      v = `<={LOW}` )
                      (   n = `GT`      v = `>{LOW}` )
                      (   n = `GE`      v = `>={LOW}` )
                      (   n = `CP`      v = `*{LOW}*` )
                      (   n = `BT`      v = `{LOW}...{HIGH}` )
                      (   n = `NB`      v = `!({LOW}...{HIGH})` )
                      (   n = `NE`      v = `!(={LOW})` )
                      (   n = `NP`      v = `!(*{LOW}*)` )
                      (   n = `!<leer>` v = `!(<leer>)` )
                      (   n = `<leer>`  v = `<leer>` ) ).

  ENDMETHOD.


  METHOD filter_get_token_t_by_range_t.

    DATA(lt_mapping) = filter_get_token_range_mapping( ).

    DATA(lt_tab) = VALUE ty_t_range( ).

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab
    ).

    LOOP AT lt_tab REFERENCE INTO DATA(lr_row).

      DATA(lv_value) = lt_mapping[ n = lr_row->option ]-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      INSERT VALUE #( key      = lv_value
                      text     = lv_value
                      visible  = abap_true
                      editable = abap_true ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_filter_by_val.

    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    DATA(lv_search) = COND string( WHEN ignore_case = abap_true
                                   THEN to_upper( val )
                                   ELSE val ).

    LOOP AT tab ASSIGNING <row>.

      DATA(lv_check_found) = abap_false.
      DATA(lv_index) = 1.
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
          DATA(lv_name) = fields[ lv_index ].
          ASSIGN COMPONENT lv_name OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            lv_index = lv_index + 1.
            CONTINUE.
          ENDIF.
        ENDIF.

        DATA(lv_value) = |{ <field> }|.
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

    ASSIGN val TO <tab>.
    DATA(tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <tab> ) ).

    DATA(struc) = CAST cl_abap_structdescr( tab->get_table_line_type( ) ).

    CLEAR lv_line.
    LOOP AT struc->get_components( ) REFERENCE INTO DATA(lr_comp).
      lv_line = |{ lv_line }{ lr_comp->name };|.
    ENDLOOP.
    INSERT lv_line INTO TABLE lt_lines.

    DATA lr_row TYPE REF TO data.
    LOOP AT <tab> REFERENCE INTO lr_row.

      CLEAR lv_line.
      DATA(lv_index) = 1.
      DO.
        ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        DATA(lv_field_val) = |{ <field> }|.
        REPLACE ALL OCCURRENCES OF `;` IN lv_field_val WITH `,`.
        lv_line = |{ lv_line }{ lv_field_val };|.
      ENDDO.
      INSERT lv_line INTO TABLE lt_lines.
    ENDLOOP.

    result = concat_lines_of( table = lt_lines sep = cv_char_utilities_cr_lf ).

  ENDMETHOD.




  METHOD itab_get_itab_by_csv.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.

    SPLIT val AT cv_char_utilities_newline INTO TABLE DATA(lt_rows).
    SPLIT lt_rows[ 1 ] AT `;` INTO TABLE DATA(lt_cols).

    LOOP AT lt_cols REFERENCE INTO DATA(lr_col).

      DATA(lv_name) = c_trim_upper( lr_col->* ).
      REPLACE ALL OCCURRENCES OF ` ` IN lv_name WITH `_`.

      INSERT VALUE #( name = lv_name
                      type = cl_abap_elemdescr=>get_c( 40 ) ) INTO TABLE lt_comp.
    ENDLOOP.

    DATA(struc) = cl_abap_structdescr=>get( lt_comp ).
    DATA(data) = CAST cl_abap_datadescr( struc ).
    DATA(o_table_desc) = cl_abap_tabledescr=>create( p_line_type  = data
                                                     p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                     p_unique     = abap_false ).

    CREATE DATA result TYPE HANDLE o_table_desc.
    ASSIGN result->* TO <tab>.
    DELETE lt_rows WHERE table_line IS INITIAL.

    LOOP AT lt_rows REFERENCE INTO DATA(lr_rows) FROM 2.

      SPLIT lr_rows->* AT `;` INTO TABLE lt_cols.
      CREATE DATA lr_row TYPE HANDLE struc.

      LOOP AT lt_cols REFERENCE INTO lr_col.
        ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
        ASSIGN COMPONENT sy-tabix OF STRUCTURE <row> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        <field> = lr_col->*.
      ENDLOOP.

      INSERT <row> INTO TABLE <tab>.
    ENDLOOP.

  ENDMETHOD.


  METHOD json_parse.
    TRY.

        z2ui5_cl_ajson=>parse( val )->to_abap( EXPORTING iv_corresponding = abap_true
                                               IMPORTING ev_container     = data ).

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.


  METHOD json_stringify.
    TRY.

        DATA(li_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        result = li_ajson->set( iv_path = `/`
                                iv_val  = any )->stringify( ).

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_check_class_exists.

    TRY.
        cl_abap_classdescr=>describe_by_name( EXPORTING  p_name         = val
                                              EXCEPTIONS type_not_found = 1 ).
        IF sy-subrc = 0.
          result = abap_true.
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_ref_data.

    TRY.
        DATA(lo_typdescr) = cl_abap_typedescr=>describe_by_data( val ).
        DATA(lo_ref) = CAST cl_abap_refdescr( lo_typdescr ) ##NEEDED.
        result = abap_true.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_type_kind_dref.

    DATA(lv_type_kind) = cl_abap_datadescr=>get_data_type_kind( val ).
    result = xsdbool( lv_type_kind = cl_abap_typedescr=>typekind_dref ).

  ENDMETHOD.


  METHOD rtti_get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD rtti_get_intfname_by_ref.

    DATA(rtti) = cl_abap_typedescr=>describe_by_data( in  ).
    DATA(ref) = CAST cl_abap_refdescr( rtti ).
    DATA(name) = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.
    TRY.

        DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).
        DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
        result = lo_ele->get_relative_name( ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_get_t_attri_by_include.

    TRY.

        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                             RECEIVING  p_descr_ref    = DATA(type_desc)
                                             EXCEPTIONS type_not_found = 1 ).

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.
    DATA(sdescr) = CAST cl_abap_structdescr( type_desc ).
    DATA(comps) = sdescr->get_components( ).

    LOOP AT comps REFERENCE INTO DATA(lr_comp).

      IF lr_comp->as_include = abap_true.

        DATA(incl_comps) = rtti_get_t_attri_by_include( lr_comp->type ).

        LOOP AT incl_comps REFERENCE INTO DATA(lr_incl_comp).
          APPEND lr_incl_comp->* TO result.
        ENDLOOP.

      ELSE.

        APPEND lr_comp->* TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_oref.

    DATA(lo_obj_ref) = cl_abap_objectdescr=>describe_by_object_ref( val ).
    result = CAST cl_abap_classdescr( lo_obj_ref )->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_type   TYPE REF TO cl_abap_typedescr.

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
        lo_struct = CAST #( lo_type ).
      WHEN cl_abap_typedescr=>kind_table.
        lo_struct = CAST #( CAST cl_abap_tabledescr( lo_type )->get_table_line_type( ) ).
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types
    DATA(lv_absolute_name) = CONV string( lo_struct->absolute_name ).
    READ TABLE mt_attri_cache REFERENCE INTO DATA(lr_cache)
         WITH TABLE KEY absolute_name = lv_absolute_name.
    IF sy-subrc = 0 AND lr_cache->o_struct = lo_struct.
      result = lr_cache->t_attri.
      RETURN.
    ENDIF.

    DATA(comps) = lo_struct->get_components( ).

    LOOP AT comps REFERENCE INTO DATA(lr_comp).

      IF lr_comp->as_include = abap_false.
        APPEND lr_comp->* TO result.
      ELSE.
        DATA(lt_attri) = rtti_get_t_attri_by_include( lr_comp->type ).
        APPEND LINES OF lt_attri TO result.
      ENDIF.
    ENDLOOP.

    IF lr_cache IS BOUND.
      lr_cache->o_struct = lo_struct.
      lr_cache->t_attri  = result.
    ELSE.
      INSERT VALUE #( absolute_name = lv_absolute_name
                      o_struct      = lo_struct
                      t_attri       = result ) INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_get_t_ddic_fixed_values.

    IF rollname IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = CONV string( rollname )
                                             RECEIVING  p_descr_ref    = DATA(typedescr)
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        DATA(elemdescr) = CAST cl_abap_elemdescr( typedescr ).

        result = rtti_get_t_fixvalues( elemdescr = elemdescr
                                       langu     = langu ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_tab_get_relative_name.

    FIELD-SYMBOLS <table> TYPE any.

    TRY.
        DATA(typedesc) = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.
            DATA(tabledesc) = CAST cl_abap_tabledescr( typedesc ).
            DATA(structdesc) = CAST cl_abap_structdescr( tabledesc->get_table_line_type( ) ).
            result = structdesc->get_relative_name( ).
            RETURN.

          WHEN typedesc->kind_ref.

            ASSIGN table->* TO <table>.
            result = rtti_tab_get_relative_name( <table> ).

        ENDCASE.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD conv_exit.

    DATA(conex) = COND string( WHEN output = abap_true
                               THEN |CONVERSION_EXIT_{ convexit }_OUTPUT|
                               ELSE |CONVERSION_EXIT_{ convexit }_INPUT| ).

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

    DATA(lv_types) = |abap, abc, actionscript, ada, apache_conf, applescript, asciidoc, assembly_x86, autohotkey, batchfile, bro, c9search, c_cpp, cirru, clojure, cobol, coffee, coldfusion, csharp, css, curly, d, dart, diff, django, dockerfile, | &&
|dot, drools, eiffel, yaml, ejs, elixir, elm, erlang, forth, fortran, ftl, gcode, gherkin, gitignore, glsl, gobstones, golang, groovy, haml, handlebars, haskell, haskell_cabal, haxe, hjson, html, html_elixir, html_ruby, ini, io, jack, jade, java, ja| &&
      |vascri| &&
|pt, json, jsoniq, jsp, jsx, julia, kotlin, latex, lean, less, liquid, lisp, live_script, livescript, logiql, lsl, lua, luapage, lucene, makefile, markdown, mask, matlab, mavens_mate_log, maze, mel, mips_assembler, mipsassembler, mushcode, mysql, ni| &&
|x, nsis, objectivec, ocaml, pascal, perl, pgsql, php, plain_text, powershell, praat, prolog, properties, protobuf, python, r, razor, rdoc, rhtml, rst, ruby, rust, sass, scad, scala, scheme, scss, sh, sjs, smarty, snippets, soy_template, space, sql,| &&
      | sqlserver, stylus, svg, swift, swig, tcl, tex, text, textile, toml, tsx, twig, typescript, vala, vbscript, velocity, verilog, vhdl, wollok, xml, xquery, terraform, slim, redshift, red, puppet, php_laravel_blade, mixal, jssm, fsharp, edifact,| &&
      | csp, cssound_score, cssound_orchestra, cssound_document| ##NO_TEXT.
    SPLIT lv_types AT `,` INTO TABLE result.

  ENDMETHOD.


  METHOD source_get_method2.

    DATA(lt_source) = source_get_method( iv_classname  = iv_classname
                                         iv_methodname = iv_methodname ).

    result = source_method_to_file( lt_source ).

  ENDMETHOD.


  METHOD source_method_to_file.

    LOOP AT it_source INTO DATA(lv_source).
      IF strlen( lv_source ) > 1.
        result = result && lv_source+1 && cv_char_utilities_newline.
      ELSE.
        result = result && cv_char_utilities_newline.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_sql_by_sql_string.

    DATA(lv_sql) = CONV string( val ).

    DATA(lv_squished) = lv_sql.
    REPLACE ALL OCCURRENCES OF ` ` IN lv_squished WITH ``.
    lv_squished = to_upper( lv_squished ).
    SPLIT lv_squished AT `SELECTFROM` INTO DATA(lv_dummy) DATA(lv_tab).
    SPLIT lv_tab AT `FIELDS` INTO lv_tab lv_dummy.
    SPLIT lv_tab AT `WHERE` INTO lv_tab lv_dummy.

    result-tabname = lv_tab.

    DATA(lv_upper) = to_upper( lv_sql ).
    IF lv_upper CS ` WHERE `.
      DATA(lv_pos) = sy-fdpos + 7.
      result-where = c_trim( substring( val = lv_sql
                                        off = lv_pos ) ).
      result-t_filter = filter_get_multi_by_sql_where( result-where ).
    ENDIF.

  ENDMETHOD.


  METHOD time_get_date_by_stampl.
    DATA(ls_sy) = z2ui5_cl_util=>context_get_sy( ).
    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE result TIME DATA(lv_dummy).
  ENDMETHOD.


  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD time_get_time_by_stampl.
    DATA(ls_sy) = z2ui5_cl_util=>context_get_sy( ).
    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE DATA(lv_dummy) TIME result.
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

    LOOP AT t_params INTO DATA(ls_param).
      result = |{ result }{ ls_param-n }={ ls_param-v }&|.
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
                               with = `=`
                               occ  = 0 ).

    lv_search = replace( val  = lv_search
                         sub  = `%26`
                         with = `&`
                         occ  = 0 ).

    lv_search = shift_left( val = lv_search
                            sub = `?` ).

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
      INSERT VALUE #( n = lv_name
                      v = lv_value ) INTO TABLE rt_params.
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
      INSERT VALUE #( n = lv_n
                      v = c_trim_lower( value ) ) INTO TABLE lt_params.
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
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.

    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    CALL METHOD srtti->(`GET_RTTI`)
      RECEIVING
        rtti = rtti_type.

    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
    lo_datadescr ?= rtti_type.

    CREATE DATA result TYPE HANDLE lo_datadescr.
    ASSIGN result->* TO FIELD-SYMBOL(<variable>).
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.

  ENDMETHOD.


  METHOD xml_srtti_stringify.

    IF rtti_check_class_exists( `ZCL_SRTTI_TYPEDESCR` ) = abap_true.

      DATA srtti TYPE REF TO object.
      DATA(lv_classname) = `ZCL_SRTTI_TYPEDESCR`.
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

          DATA(lv_text) = `UNSUPPORTED_FEATURE`.
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

    DATA(x) = val.
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

    IF table_name IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `TABLE_NAME_INITIAL_ERROR`.
    ENDIF.

    TRY.
        cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                               RECEIVING  p_descr_ref    = DATA(lo_obj)
                                               EXCEPTIONS type_not_found = 1
                                                          OTHERS         = 2
            ).

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = |TABLE_NOT_FOUD_NAME___{ table_name }|.
        ENDIF.
        DATA(lo_struct) = CAST cl_abap_structdescr( lo_obj ).

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

            DATA(lo_tab) = CAST cl_abap_tabledescr( lo_obj ).
            lo_struct = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
          CATCH cx_root.
            RETURN.
        ENDTRY.

    ENDTRY.

    DATA(lt_comps) = lo_struct->get_components( ).

    LOOP AT lt_comps REFERENCE INTO DATA(lr_comp).
      IF lr_comp->as_include = abap_true.
        DATA(lt_attri) = rtti_get_t_attri_by_include( lr_comp->type ).
        INSERT LINES OF lt_attri INTO TABLE result.
      ELSE.
        INSERT lr_comp->* INTO TABLE result.
      ENDIF.
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

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).
    LOOP AT lt_attri REFERENCE INTO DATA(lr_attri).

      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO FIELD-SYMBOL(<component>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE z2ui5_cl_util=>rtti_get_type_kind( <component> ).

        WHEN cl_abap_typedescr=>typekind_table.

        WHEN OTHERS.
          INSERT VALUE #(
            n = lr_attri->name
            v = <component>
            ) INTO TABLE result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_t_range.

    DATA ref TYPE REF TO data.

    LOOP AT tab REFERENCE INTO ref.
      LOOP AT val INTO DATA(ls_filter).

        IF ls_filter-t_range IS INITIAL.
          CONTINUE.
        ENDIF.

        ASSIGN ref->(ls_filter-name) TO FIELD-SYMBOL(<field>).
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

    LOOP AT val INTO DATA(ls_filter).
      IF lines( ls_filter-t_range ) > 0
        OR lines( ls_filter-t_token ) > 0.
        INSERT ls_filter INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_sql_where.

    LOOP AT val INTO DATA(ls_filter).

      IF ls_filter-t_range IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_field_where) = ``.
      LOOP AT ls_filter-t_range INTO DATA(ls_range).
        DATA(lv_cond) = filter_get_sql_cond_by_range( fieldname = ls_filter-name
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

    DATA(lv_low) = replace( val  = range-low
                            sub  = `'`
                            with = `''`
                            occ  = 0 ).
    DATA(lv_high) = replace( val  = range-high
                             sub  = `'`
                             with = `''`
                             occ  = 0 ).
    DATA(lv_option) = range-option.

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

    DATA(lv_like) = ``.
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

    DATA(lv_where) = c_trim( CONV string( val ) ).
    IF lv_where IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_groups) = filter_sql_split_top_level( val = lv_where
                                                  sep = ` AND ` ).

    LOOP AT lt_groups INTO DATA(lv_group).

      lv_group = c_trim( lv_group ).
      DATA(lv_len) = strlen( lv_group ).

      IF lv_len >= 2
         AND lv_group(1) = `(`
         AND substring( val = lv_group
                        off = lv_len - 1
                        len = 1 ) = `)`.
        lv_group = c_trim( substring( val = lv_group
                                      off = 1
                                      len = lv_len - 2 ) ).
      ENDIF.

      DATA(lt_conds) = filter_sql_split_top_level( val = lv_group
                                                   sep = ` OR ` ).

      DATA ls_filter TYPE ty_s_filter_multi.
      CLEAR ls_filter.

      LOOP AT lt_conds INTO DATA(lv_cond).

        DATA ls_range TYPE ty_s_range.
        DATA lv_fieldname TYPE string.
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

    CLEAR range.
    CLEAR fieldname.

    DATA(lv_cond) = CONV string( val ).
    range-sign = `I`.

    DATA lv_rest TYPE string.
    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_like TYPE string.

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

    DATA(lv_val) = CONV string( val ).
    DATA(lv_sep) = CONV string( sep ).
    DATA(lv_len) = strlen( lv_val ).
    DATA(lv_sep_len) = strlen( lv_sep ).
    DATA(lv_depth) = 0.
    DATA(lv_start) = 0.
    DATA(lv_pos) = 0.
    DATA(lv_in_quote) = abap_false.

    IF lv_val IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_sep_len = 0.
      INSERT lv_val INTO TABLE result.
      RETURN.
    ENDIF.

    WHILE lv_pos < lv_len.

      DATA(lv_char) = lv_val+lv_pos(1).

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

    result = c_trim( val ).
    DATA(lv_len) = strlen( result ).

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

    DATA(lv_type) = rtti_get_type_kind( val ).
    CASE lv_type.
      WHEN cl_abap_datadescr=>typekind_char OR
          cl_abap_datadescr=>typekind_clike OR
          cl_abap_datadescr=>typekind_csequence OR
          cl_abap_datadescr=>typekind_string.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD ui5_get_msg_type.

    result = SWITCH #( val
                       WHEN `E` THEN cs_ui5_msg_type-e
                       WHEN `S` THEN cs_ui5_msg_type-s
                       WHEN `W` THEN cs_ui5_msg_type-w
                       ELSE cs_ui5_msg_type-i ).

  ENDMETHOD.


  METHOD rtti_create_tab_by_name.

    DATA(struct_desc) = cl_abap_structdescr=>describe_by_name( val ).
    DATA(data_desc) = CAST cl_abap_datadescr( struct_desc ).
    DATA(gr_dyntable_typ) = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.


  METHOD msg_get.

    DATA(lt_msg) = msg_get_t( val = val val2 = val2 ).
    result = lt_msg[ 1 ].

  ENDMETHOD.


  METHOD msg_get_collect.

    result = z2ui5_cl_util_msg=>msg_get_collect( val = val val2 = val2 ).

  ENDMETHOD.


  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.


  METHOD rtti_get_ddic_type_name.

    result = substring_after( val = CAST cl_abap_elemdescr( type )->absolute_name
                              sub = `\TYPE=` ).

  ENDMETHOD.


  METHOD rtti_get_typedescr_by_data_ref.

    result = cl_abap_typedescr=>describe_by_data_ref( val ).

  ENDMETHOD.


  METHOD rtti_get_typedescr_by_data.

    result = cl_abap_typedescr=>describe_by_data( val ).

  ENDMETHOD.


  METHOD rtti_create_sel_tab_type.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
    ASSIGN ir_tab->* TO <tab>.

    DATA(lo_table) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <tab> ) ).
    TRY.
        DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
        lt_comp = lo_struct->get_components( ).
      CATCH cx_root.
        result-check_table_line = abap_true.
        DATA(lo_elem) = CAST cl_abap_elemdescr( lo_table->get_table_line_type( ) ).
        INSERT VALUE #( name = `TAB_LINE`
                        type = lo_elem ) INTO TABLE lt_comp.
    ENDTRY.

    IF add_sel_field = abap_true
        AND NOT line_exists( lt_comp[ name = sel_field_name ] ).
      DATA(lo_type_bool) = cl_abap_typedescr=>describe_by_name( `ABAP_BOOL` ).
      INSERT VALUE #( name = sel_field_name
                      type = CAST #( lo_type_bool ) ) INTO TABLE lt_comp.
    ENDIF.

    DATA(lo_line_type) = cl_abap_structdescr=>create( lt_comp ).
    result-tabledescr = cl_abap_tabledescr=>create( lo_line_type ).

  ENDMETHOD.


  METHOD msg_get_by_msg.

    DATA(ls_msg) = VALUE ty_s_msg(
      id         = id
      no         = no
      v1         = v1
      v2         = v2
      v3         = v3
      v4         = v4 ).
    result = msg_get( ls_msg ).

  ENDMETHOD.


  METHOD c_contains.

    result = xsdbool( CONV string( val ) CS sub ).

  ENDMETHOD.


  METHOD c_starts_with.

    DATA(lv_val) = CONV string( val ).
    DATA(lv_prefix) = CONV string( prefix ).
    DATA(lv_len) = strlen( lv_prefix ).

    IF strlen( lv_val ) < lv_len.
      result = abap_false.
      RETURN.
    ENDIF.

    result = xsdbool( lv_val(lv_len) = lv_prefix ).

  ENDMETHOD.


  METHOD c_ends_with.

    DATA(lv_val) = CONV string( val ).
    DATA(lv_suffix) = CONV string( suffix ).
    DATA(lv_len_suffix) = strlen( lv_suffix ).
    DATA(lv_len_val) = strlen( lv_val ).

    IF lv_len_val < lv_len_suffix.
      result = abap_false.
      RETURN.
    ENDIF.

    DATA(lv_off) = lv_len_val - lv_len_suffix.
    result = xsdbool( lv_val+lv_off(lv_len_suffix) = lv_suffix ).

  ENDMETHOD.


  METHOD c_split.

    SPLIT val AT sep INTO TABLE result.

  ENDMETHOD.


  METHOD c_join.

    LOOP AT tab INTO DATA(lv_line).
      IF sy-tabix > 1.
        result = result && sep.
      ENDIF.
      result = result && lv_line.
    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_check_table.

    DATA(lv_type_kind) = cl_abap_datadescr=>get_data_type_kind( val ).
    result = xsdbool( lv_type_kind = cl_abap_typedescr=>typekind_table ).

  ENDMETHOD.


  METHOD rtti_check_structure.

    TRY.
        DATA(lo_type) = cl_abap_typedescr=>describe_by_data( val ).
        result = xsdbool( lo_type->kind = cl_abap_typedescr=>kind_struct ).
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_numeric.

    DATA(lv_type_kind) = cl_abap_datadescr=>get_data_type_kind( val ).
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

    DATA(ls_sy) = z2ui5_cl_util=>context_get_sy( ).
    CONVERT DATE date TIME time INTO TIME STAMP result TIME ZONE ls_sy-zonlo.

  ENDMETHOD.


  METHOD time_diff_seconds.

    DATA(lv_diff) = cl_abap_tstmp=>subtract( tstmp1 = time_to
                                              tstmp2 = time_from ).
    result = lv_diff.

  ENDMETHOD.


  METHOD conv_string_to_date.

    DATA(lv_val) = CONV string( val ).
    DATA(lv_fmt) = CONV string( format ).
    DATA(lv_yyyy_off) = find( val = lv_fmt sub = `YYYY` ).
    DATA(lv_mm_off)   = find( val = lv_fmt sub = `MM` ).
    DATA(lv_dd_off)   = find( val = lv_fmt sub = `DD` ).

    DATA(lv_clean) = ``.
    DATA(lv_i) = 0.
    WHILE lv_i < strlen( lv_val ).
      DATA(lv_c) = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        lv_clean = lv_clean && lv_c.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    DATA(lv_fmt_clean) = ``.
    lv_i = 0.
    WHILE lv_i < strlen( lv_fmt ).
      lv_c = lv_fmt+lv_i(1).
      IF lv_c = `Y` OR lv_c = `M` OR lv_c = `D`.
        lv_fmt_clean = lv_fmt_clean && lv_c.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    DATA(lv_year)  = ``.
    DATA(lv_month) = ``.
    DATA(lv_day)   = ``.

    DATA(lv_pos) = 0.
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

    DATA(lv_fmt) = CONV string( format ).
    DATA(lv_date) = CONV string( val ).

    DATA(lv_year)  = lv_date(4).
    DATA(lv_month) = lv_date+4(2).
    DATA(lv_day)   = lv_date+6(2).

    result = lv_fmt.
    REPLACE `YYYY` IN result WITH lv_year.
    REPLACE `MM`   IN result WITH lv_month.
    REPLACE `DD`   IN result WITH lv_day.

  ENDMETHOD.


  METHOD ui5_msg_box_format.

    DATA(lt_msg) = msg_get_t( val ).

    IF lines( lt_msg ) = 1.
      result-text  = lt_msg[ 1 ]-text.
      result-type  = to_lower( ui5_get_msg_type( lt_msg[ 1 ]-type ) ).
      result-title = ui5_get_msg_type( lt_msg[ 1 ]-type ).

    ELSEIF lines( lt_msg ) > 1.
      result-text = | { lines( lt_msg ) } Messages found: |.
      DATA lt_detail_items TYPE string_table.
      LOOP AT lt_msg REFERENCE INTO DATA(lr_msg).
        INSERT |<li>{ lr_msg->text }</li>| INTO TABLE lt_detail_items.
      ENDLOOP.
      result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.
      result-title   = ui5_get_msg_type( lt_msg[ 1 ]-type ).
      result-type    = ui5_get_msg_type( lt_msg[ 1 ]-type ).

    ELSE.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_check_serializable.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.
        DATA(lo_dummy) = CAST if_serializable_object( val ) ##NEEDED.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD app_get_url.

    DATA(lt_param) = url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start`
                    v = to_lower( classname ) ) INTO TABLE lt_param.

    result = |{ origin }{ pathname }?| && url_param_create_url( lt_param ) && hash.

  ENDMETHOD.


  METHOD app_get_url_source_code.

    result = |{ origin }/sap/bc/adt/oo/classes/{ classname }/source/main|.

  ENDMETHOD.


  METHOD cal_get_weekday.

    " 1900-01-01 was a Monday, so the day distance modulo 7 yields the weekday
    DATA(lv_days) = date - CONV d( `19000101` ).
    result = lv_days MOD 7 + 1.

  ENDMETHOD.


  METHOD cal_is_weekend.

    result = xsdbool( cal_get_weekday( date ) >= 6 ).

  ENDMETHOD.


  METHOD cal_is_workday.

    IF calendar_id IS NOT INITIAL.
      z2ui5_cl_util=>x_raise( `cal_is_workday: factory calendar support is not yet implemented` ).
    ENDIF.

    result = xsdbool( cal_is_weekend( date ) = abap_false ).

  ENDMETHOD.


  METHOD cal_add_workdays.

    DATA(lv_remaining) = abs( days ).
    DATA(lv_step) = COND i( WHEN days < 0 THEN -1 ELSE 1 ).

    result = date.
    WHILE lv_remaining > 0.
      result = result + lv_step.
      IF cal_is_workday( date = result calendar_id = calendar_id ) = abap_true.
        lv_remaining = lv_remaining - 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD cal_count_workdays.

    DATA(lv_date) = date_from.
    DATA(lv_step) = COND i( WHEN date_to < date_from THEN -1 ELSE 1 ).

    WHILE lv_date <> date_to.
      lv_date = lv_date + lv_step.
      IF cal_is_workday( date = lv_date calendar_id = calendar_id ) = abap_true.
        result = result + 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD zip_pack.

    DATA lo_zip TYPE REF TO object.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').
        LOOP AT files INTO DATA(ls_file).
          CALL METHOD lo_zip->('ADD')
            EXPORTING
              name    = ls_file-name
              content = ls_file-content.
        ENDLOOP.
        CALL METHOD lo_zip->('SAVE')
          RECEIVING
            zip = result.

      CATCH cx_root INTO DATA(x).
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

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').
        CALL METHOD lo_zip->('LOAD')
          EXPORTING
            zip = val.

        ASSIGN lo_zip->('FILES') TO <files>.
        LOOP AT <files> ASSIGNING <file>.
          ASSIGN COMPONENT `NAME` OF STRUCTURE <file> TO <name>.
          lv_name = <name>.

          ls_result = VALUE #( name = lv_name ).
          CALL METHOD lo_zip->('GET')
            EXPORTING
              name    = lv_name
            IMPORTING
              content = ls_result-content.
          INSERT ls_result INTO TABLE result.
        ENDLOOP.

      CATCH cx_root INTO DATA(x).
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

        result = xsdbool( sy-subrc = 0 ).

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

      CATCH z2ui5_cx_util_error INTO DATA(lx_error).
        RAISE EXCEPTION lx_error.
      CATCH cx_root INTO DATA(lx_root).
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

        result = xsdbool( sy-subrc = 0 AND lv_subrc = 0 ).

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  " ========== String Extras ==========

  METHOD c_pad_left.

    result = val.
    WHILE strlen( result ) < len.
      result = pad && result.
    ENDWHILE.

  ENDMETHOD.


  METHOD c_pad_right.

    result = val.
    WHILE strlen( result ) < len.
      result = result && pad.
    ENDWHILE.

  ENDMETHOD.


  METHOD c_truncate.

    DATA(lv_val) = CONV string( val ).
    IF strlen( lv_val ) <= max.
      result = lv_val.
    ELSE.
      DATA(lv_ellipsis_len) = strlen( ellipsis ).
      IF max > lv_ellipsis_len.
        DATA(lv_cut) = max - lv_ellipsis_len.
        result = substring( val = lv_val off = 0 len = lv_cut ) && ellipsis.
      ELSE.
        result = substring( val = lv_val off = 0 len = max ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD c_substring_safe.

    DATA(lv_val) = CONV string( val ).
    DATA(lv_strlen) = strlen( lv_val ).

    DATA(lv_off) = off.
    IF lv_off < 0.
      lv_off = 0.
    ENDIF.
    IF lv_off >= lv_strlen.
      result = ``.
      RETURN.
    ENDIF.

    DATA(lv_len) = len.
    IF lv_len < 0 OR lv_off + lv_len > lv_strlen.
      lv_len = lv_strlen - lv_off.
    ENDIF.

    result = substring( val = lv_val off = lv_off len = lv_len ).

  ENDMETHOD.


  METHOD c_replace_all.

    result = val.
    REPLACE ALL OCCURRENCES OF sub IN result WITH new_val.

  ENDMETHOD.


  METHOD c_is_blank.

    DATA(lv_val) = CONV string( val ).
    result = xsdbool( c_trim( lv_val ) IS INITIAL ).

  ENDMETHOD.


  " ========== Number Formatting ==========

  METHOD conv_number_to_string.

    DATA lv_str TYPE string.

    IF decimals >= 0.
      DATA(lv_fmt) = |{ val }|.
      DATA(lv_dot_pos) = find( val = lv_fmt sub = `.` ).
      IF lv_dot_pos < 0.
        lv_str = lv_fmt.
        IF decimals > 0.
          lv_str = lv_str && `.` && repeat( val = `0` occ = decimals ).
        ENDIF.
      ELSE.
        DATA(lv_int_part) = lv_fmt(lv_dot_pos).
        DATA(lv_dec_part) = substring( val = lv_fmt off = lv_dot_pos + 1 ).
        IF strlen( lv_dec_part ) > decimals.
          lv_dec_part = lv_dec_part(decimals).
        ELSEIF strlen( lv_dec_part ) < decimals.
          lv_dec_part = lv_dec_part && repeat( val = `0` occ = decimals - strlen( lv_dec_part ) ).
        ENDIF.
        lv_str = COND #( WHEN decimals > 0 THEN lv_int_part && `.` && lv_dec_part
                                           ELSE lv_int_part ).
      ENDIF.
    ELSE.
      lv_str = |{ val }|.
    ENDIF.

    IF sep_thousands IS NOT INITIAL.
      DATA(lv_dot) = find( val = lv_str sub = `.` ).
      DATA(lv_integer) = COND string( WHEN lv_dot >= 0 THEN lv_str(lv_dot)
                                                       ELSE lv_str ).
      DATA(lv_decimal) = COND string( WHEN lv_dot >= 0 THEN substring( val = lv_str off = lv_dot ) ).
      DATA(lv_negative) = ``.
      IF strlen( lv_integer ) > 0 AND lv_integer(1) = `-`.
        lv_negative = `-`.
        lv_integer = substring( val = lv_integer off = 1 ).
      ENDIF.
      DATA(lv_result) = ``.
      DATA(lv_count) = 0.
      DATA(lv_i) = strlen( lv_integer ) - 1.
      WHILE lv_i >= 0.
        IF lv_count > 0 AND lv_count MOD 3 = 0.
          lv_result = sep_thousands && lv_result.
        ENDIF.
        lv_result = lv_integer+lv_i(1) && lv_result.
        lv_count = lv_count + 1.
        lv_i = lv_i - 1.
      ENDWHILE.
      lv_str = lv_negative && lv_result && lv_decimal.
    ENDIF.

    result = lv_str.

  ENDMETHOD.


  METHOD conv_string_to_number.

    DATA(lv_val) = c_trim( CONV string( val ) ).

    " Remove thousands separators (comma or period depending on format)
    " Normalize: keep only digits, minus, and decimal point
    DATA(lv_clean) = ``.
    DATA(lv_i) = 0.
    WHILE lv_i < strlen( lv_val ).
      DATA(lv_c) = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `-` AND lv_i = 0.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `.`.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `,`.
        " Check if comma is decimal separator (last separator in string)
        DATA(lv_rest) = substring( val = lv_val off = lv_i + 1 ).
        IF lv_rest NA `,` AND lv_rest NA `.`.
          lv_clean = lv_clean && `.`.
        ENDIF.
        " Otherwise it's a thousands separator — skip it
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    TRY.
        result = lv_clean.
      CATCH cx_root.
        result = 0.
    ENDTRY.

  ENDMETHOD.


  " ========== i18n / Text Resolution ==========

  METHOD text_get.

    DATA lv_msgid TYPE c LENGTH 20.
    DATA lv_msgno TYPE n LENGTH 3.
    DATA lv_msgv1 TYPE c LENGTH 50.
    DATA lv_msgv2 TYPE c LENGTH 50.
    DATA lv_msgv3 TYPE c LENGTH 50.
    DATA lv_msgv4 TYPE c LENGTH 50.
    DATA lv_text  TYPE c LENGTH 200.

    lv_msgid = msgid.
    lv_msgno = msgno.
    lv_msgv1 = v1.
    lv_msgv2 = v2.
    lv_msgv3 = v3.
    lv_msgv4 = v4.

    TRY.
        DATA(lv_fm) = `MESSAGE_TEXT_BUILD`.
        CALL FUNCTION lv_fm
          EXPORTING
            msgid               = lv_msgid
            msgnr               = lv_msgno
            msgv1               = lv_msgv1
            msgv2               = lv_msgv2
            msgv3               = lv_msgv3
            msgv4               = lv_msgv4
          IMPORTING
            message_text_output = lv_text.
        result = lv_text.
      CATCH cx_root.
        result = |{ lv_msgid } { lv_msgno }: { lv_msgv1 } { lv_msgv2 } { lv_msgv3 } { lv_msgv4 }|.
    ENDTRY.

  ENDMETHOD.


  " ========== Itab Extras ==========

  METHOD itab_sort_by.

    DATA(lv_field) = CONV string( fieldname ).
    IF descending = abap_true.
      SORT tab BY (lv_field) DESCENDING.
    ELSE.
      SORT tab BY (lv_field) ASCENDING.
    ENDIF.

  ENDMETHOD.


  METHOD itab_slice.

    " Create a copy of the source table (same type) and return the slice.
    DATA(lo_tabledescr) = CAST cl_abap_tabledescr(
      cl_abap_typedescr=>describe_by_data( tab ) ).
    CREATE DATA result TYPE HANDLE lo_tabledescr.

    FIELD-SYMBOLS <result> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>    TYPE any.
    ASSIGN result->* TO <result>.

    DATA(lv_lines) = lines( tab ).
    DATA(lv_to) = COND i( WHEN to <= 0 OR to > lv_lines THEN lv_lines ELSE to ).
    DATA(lv_from) = COND i( WHEN from < 1 THEN 1 ELSE from ).

    LOOP AT tab ASSIGNING <row> FROM lv_from TO lv_to.
      INSERT <row> INTO TABLE <result>.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_paginate.

    total_count = lines( tab ).
    total_pages = COND #( WHEN page_size <= 0 THEN 1
                          ELSE ( total_count + page_size - 1 ) / page_size ).

    DATA(lv_from) = ( page - 1 ) * page_size + 1.
    DATA(lv_to)   = page * page_size.

    result = itab_slice( tab  = tab
                         from = lv_from
                         to   = lv_to ).

  ENDMETHOD.


  METHOD itab_to_json.

    result = json_stringify( val ).

  ENDMETHOD.


  METHOD itab_from_json.

    json_parse( EXPORTING val = val
                CHANGING data = data ).

  ENDMETHOD.


  METHOD itab_count_by.

    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    LOOP AT tab ASSIGNING <row>.
      ASSIGN COMPONENT fieldname OF STRUCTURE <row> TO <field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA(lv_val) = |{ <field> }|.
      READ TABLE result ASSIGNING FIELD-SYMBOL(<entry>) WITH KEY n = lv_val.
      IF sy-subrc = 0.
        DATA(lv_count) = CONV i( <entry>-v ) + 1.
        <entry>-v = |{ lv_count }|.
      ELSE.
        INSERT VALUE #( n = lv_val v = `1` ) INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  " ========== Validation Helpers ==========

  METHOD check_is_email.

    DATA(lv_val) = c_trim( CONV string( val ) ).

    IF lv_val IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    " Basic email validation: contains exactly one @, has text before and after,
    " domain part contains at least one dot
    SPLIT lv_val AT `@` INTO DATA(lv_local) DATA(lv_domain) DATA(lv_extra).
    IF lv_extra IS NOT INITIAL OR lv_local IS INITIAL OR lv_domain IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    IF lv_domain NA `.`.
      result = abap_false.
      RETURN.
    ENDIF.

    result = abap_true.

  ENDMETHOD.


  METHOD check_is_numeric_string.

    DATA(lv_val) = c_trim( CONV string( val ) ).

    IF lv_val IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    DATA(lv_i) = 0.
    DATA(lv_has_dot) = abap_false.
    WHILE lv_i < strlen( lv_val ).
      DATA(lv_c) = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        " digit ok
      ELSEIF lv_c = `-` AND lv_i = 0.
        " leading minus ok
      ELSEIF lv_c = `+` AND lv_i = 0.
        " leading plus ok
      ELSEIF ( lv_c = `.` OR lv_c = `,` ) AND lv_has_dot = abap_false.
        lv_has_dot = abap_true.
      ELSE.
        result = abap_false.
        RETURN.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = abap_true.

  ENDMETHOD.


  METHOD check_is_date_valid.

    TRY.
        DATA(lv_date) = conv_string_to_date( val = val format = format ).
        " Check the date is actually valid (not 00000000 and not invalid like Feb 30)
        IF lv_date IS INITIAL.
          result = abap_false.
          RETURN.
        ENDIF.
        " ABAP validates dates on assignment — if it passed conv_string_to_date it's valid
        DATA(lv_check) = CONV string( lv_date ).
        result = xsdbool( lv_check <> `00000000` ).
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD check_is_guid.

    DATA(lv_val) = c_trim( CONV string( val ) ).
    DATA(lv_clean) = c_replace_all( val = lv_val sub = `-` new_val = `` ).
    DATA(lv_len) = strlen( lv_clean ).

    " Accept 32 chars (raw) or 36 chars (with dashes)
    IF lv_len <> 32.
      result = abap_false.
      RETURN.
    ENDIF.

    " All characters must be hex digits
    DATA(lv_upper) = to_upper( lv_clean ).
    DATA(lv_i) = 0.
    WHILE lv_i < 32.
      DATA(lv_c) = lv_upper+lv_i(1).
      IF NOT ( ( lv_c >= `0` AND lv_c <= `9` ) OR ( lv_c >= `A` AND lv_c <= `F` ) ).
        result = abap_false.
        RETURN.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = abap_true.

  ENDMETHOD.


  METHOD check_max_length.

    DATA(lv_val) = CONV string( val ).
    result = xsdbool( strlen( lv_val ) <= max ).

  ENDMETHOD.


  " ========== Deep Comparison ==========

  METHOD data_equals.

    TRY.
        result = xsdbool( a = b ).
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD data_diff.

    FIELD-SYMBOLS <old_field> TYPE any.
    FIELD-SYMBOLS <new_field> TYPE any.

    DATA(lt_comps) = rtti_get_t_attri_by_any( old ).

    LOOP AT lt_comps REFERENCE INTO DATA(lr_comp).
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE old TO <old_field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE new TO <new_field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF <old_field> <> <new_field>.
        INSERT VALUE #( fieldname = lr_comp->name
                        old_value = |{ <old_field> }|
                        new_value = |{ <new_field> }| ) INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  " ========== Stopwatch ==========

  METHOD time_measure_start.

    GET TIME STAMP FIELD result.

  ENDMETHOD.


  METHOD time_measure_stop.

    DATA(lv_now) = time_get_timestampl( ).
    DATA(lv_diff) = cl_abap_tstmp=>subtract( tstmp1 = lv_now
                                              tstmp2 = start_time ).
    result = lv_diff * 1000.  " convert seconds to milliseconds

  ENDMETHOD.


  " ========== Authorization Check ==========

  METHOD auth_check.

    DATA lv_object   TYPE c LENGTH 10.
    DATA lv_field    TYPE c LENGTH 10.
    DATA lv_value    TYPE c LENGTH 40.
    DATA lv_activity TYPE c LENGTH 2.

    lv_object   = object.
    lv_field    = field.
    lv_value    = value.
    lv_activity = activity.

    AUTHORITY-CHECK OBJECT lv_object
      ID lv_field FIELD lv_value
      ID 'ACTVT' FIELD lv_activity.

    result = xsdbool( sy-subrc = 0 ).

  ENDMETHOD.


  " ========== Enum/Domain Helpers ==========

  METHOD enum_to_text.

    DATA(lt_all) = enum_get_all( domain = domain langu = langu ).
    DATA(lv_val) = CONV string( value ).
    result = VALUE #( lt_all[ n = lv_val ]-v OPTIONAL ).

  ENDMETHOD.


  METHOD enum_get_all.

    TRY.
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = CONV string( domain )
                                             RECEIVING  p_descr_ref    = DATA(lo_type)
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        DATA(lo_elem) = CAST cl_abap_elemdescr( lo_type ).
        DATA(lt_fix) = rtti_get_t_fixvalues( elemdescr = lo_elem
                                              langu     = langu ).

        LOOP AT lt_fix INTO DATA(ls_fix).
          INSERT VALUE #( n = ls_fix-low
                          v = ls_fix-descr ) INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  " ========== Deep Field Access ==========

  METHOD data_get_by_path.

    FIELD-SYMBOLS <current> TYPE any.
    FIELD-SYMBOLS <field>   TYPE any.

    ASSIGN data TO <current>.

    SPLIT path AT `-` INTO TABLE DATA(lt_segments).

    LOOP AT lt_segments INTO DATA(lv_segment).
      DATA(lv_seg) = c_trim_upper( lv_segment ).
      IF lv_seg IS INITIAL.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lv_seg OF STRUCTURE <current> TO <field>.
      IF sy-subrc <> 0.
        result = ``.
        RETURN.
      ENDIF.
      ASSIGN <field> TO <current>.
    ENDLOOP.

    result = |{ <current> }|.

  ENDMETHOD.


  METHOD data_set_by_path.

    FIELD-SYMBOLS <current> TYPE any.
    FIELD-SYMBOLS <field>   TYPE any.

    ASSIGN data TO <current>.

    SPLIT path AT `-` INTO TABLE DATA(lt_segments).
    DATA(lv_last_idx) = lines( lt_segments ).

    LOOP AT lt_segments INTO DATA(lv_segment).
      DATA(lv_seg) = c_trim_upper( lv_segment ).
      IF lv_seg IS INITIAL.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lv_seg OF STRUCTURE <current> TO <field>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      IF sy-tabix = lv_last_idx.
        <field> = value.
      ELSE.
        ASSIGN <field> TO <current>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  " ========== BAL Extensions ==========

  METHOD bal_search.

    IF context_check_abap_cloud( ).
      " Cloud: use CL_BALI_LOG_FILTER + CL_BALI_LOG_DB
      DATA lo_filter TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lt_logs   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_class  TYPE string.

      TRY.
          lv_class = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              filter = lo_filter.

          DATA(lv_obj_f) = COND string( WHEN object IS NOT INITIAL THEN object ELSE `` ).
          DATA(lv_sub_f) = COND string( WHEN subobject IS NOT INITIAL THEN subobject ELSE `` ).
          DATA(lv_id_f)  = COND string( WHEN id IS NOT INITIAL THEN id ELSE `` ).
          CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = lv_obj_f
              subobject   = lv_sub_f
              external_id = lv_id_f.

          IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.
            DATA(lv_from) = COND d( WHEN date_from IS NOT INITIAL THEN date_from ELSE '19000101' ).
            DATA(lv_to)   = COND d( WHEN date_to IS NOT INITIAL THEN date_to ELSE sy-datum ).
            CALL METHOD lo_filter->(`SET_CREATE_DATE`)
              EXPORTING
                from_date = lv_from
                to_date   = lv_to.
          ENDIF.

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter           = lo_filter
              read_only_header = abap_true
            RECEIVING
              log_table        = lt_logs.

          LOOP AT lt_logs INTO DATA(lo_log).
            DATA(ls_hdr_c) = VALUE ty_s_bal_header( ).
            TRY.
                DATA lo_header TYPE REF TO object.
                CALL METHOD lo_log->(`GET_HEADER`)
                  RECEIVING
                    header = lo_header.
                CALL METHOD lo_header->(`GET_OBJECT`)
                  RECEIVING
                    object = ls_hdr_c-object.
                CALL METHOD lo_header->(`GET_SUBOBJECT`)
                  RECEIVING
                    subobject = ls_hdr_c-subobject.
                CALL METHOD lo_header->(`GET_EXTERNAL_ID`)
                  RECEIVING
                    external_id = ls_hdr_c-external_id.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            INSERT ls_hdr_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use BAL_DB_SEARCH
    DATA lv_fm      TYPE string.
    DATA lr_filter  TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter>  TYPE any.
    FIELD-SYMBOLS <headers> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <header>  TYPE any.
    FIELD-SYMBOLS <comp>    TYPE any.
    FIELD-SYMBOLS <range>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline>   TYPE any.
    DATA lr_rline TYPE REF TO data.

    TRY.
        CREATE DATA lr_filter TYPE ('BAL_S_LFIL').
        ASSIGN lr_filter->* TO <filter>.

        IF object IS NOT INITIAL.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = object.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF subobject IS NOT INITIAL.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = subobject.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF id IS NOT INITIAL.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = id.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.
          ASSIGN COMPONENT `ALDATE` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `BT`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>.
          <comp> = COND d( WHEN date_from IS NOT INITIAL THEN date_from ELSE '19000101' ).
          ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>.
          <comp> = COND d( WHEN date_to IS NOT INITIAL THEN date_to ELSE sy-datum ).
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF user IS NOT INITIAL.
          ASSIGN COMPONENT `ALUSER` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = user.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

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
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <headers> ASSIGNING <header>.
          DATA(ls_hdr) = VALUE ty_s_bal_header( ).
          ASSIGN COMPONENT `LOG_HANDLE` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_handle = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-object = <comp>. ENDIF.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-subobject = <comp>. ENDIF.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-external_id = <comp>. ENDIF.
          ASSIGN COMPONENT `ALDATE` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_date = <comp>. ENDIF.
          ASSIGN COMPONENT `ALTIME` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_time = <comp>. ENDIF.
          ASSIGN COMPONENT `ALUSER` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-user = <comp>. ENDIF.
          INSERT ls_hdr INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD bal_read_latest.

    DATA(lt_msgs) = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    IF lt_msgs IS NOT INITIAL.
      result = lt_msgs[ lines( lt_msgs ) ].
    ENDIF.

  ENDMETHOD.


  METHOD bal_delete_before.

    DATA(lv_cutoff) = CONV d( sy-datum - days ).

    IF context_check_abap_cloud( ).
      " Cloud: use CL_BALI_LOG_DB to delete via filter
      DATA lo_filter_c TYPE REF TO object.
      DATA lo_db_c     TYPE REF TO object.
      DATA lt_logs_c   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_cls      TYPE string.

      TRY.
          lv_cls = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_cls)=>(`CREATE`)
            RECEIVING
              filter = lo_filter_c.

          DATA(lv_sub_c) = COND string( WHEN subobject IS NOT INITIAL THEN subobject ELSE `` ).
          CALL METHOD lo_filter_c->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = object
              subobject   = lv_sub_c
              external_id = ``.

          CALL METHOD lo_filter_c->(`SET_CREATE_DATE`)
            EXPORTING
              from_date = CONV d( '19000101' )
              to_date   = lv_cutoff.

          lv_cls = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_cls)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db_c.

          CALL METHOD lo_db_c->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter_c
            RECEIVING
              log_table = lt_logs_c.

          LOOP AT lt_logs_c INTO DATA(lo_log_c).
            CALL METHOD lo_db_c->(`DELETE_LOG`)
              EXPORTING
                log = lo_log_c.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use BAL_DB_DELETE
    DATA lv_fm     TYPE string.
    DATA lr_filter TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.
    FIELD-SYMBOLS <range>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline>  TYPE any.
    FIELD-SYMBOLS <comp>   TYPE any.
    DATA lr_rline TYPE REF TO data.

    TRY.
        CREATE DATA lr_filter TYPE ('BAL_S_LFIL').
        ASSIGN lr_filter->* TO <filter>.

        ASSIGN COMPONENT `OBJECT` OF STRUCTURE <filter> TO <range>.
        CREATE DATA lr_rline LIKE LINE OF <range>.
        ASSIGN lr_rline->* TO <rline>.
        ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
        ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = object.
        INSERT <rline> INTO TABLE <range>.

        IF subobject IS NOT INITIAL.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = subobject.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        ASSIGN COMPONENT `ALDATE` OF STRUCTURE <filter> TO <range>.
        CREATE DATA lr_rline LIKE LINE OF <range>.
        ASSIGN lr_rline->* TO <rline>.
        ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
        ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `BT`.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = '19000101'.
        ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>. <comp> = lv_cutoff.
        INSERT <rline> INTO TABLE <range>.

        lv_fm = `BAL_DB_DELETE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log_filter = <filter>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD bal_read_by_type.

    DATA(lt_all) = bal_read( object    = object
                             subobject = subobject
                             id        = id ).

    LOOP AT lt_all INTO DATA(ls_msg)
         WHERE type = msg_type.
      INSERT ls_msg INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD bal_count.

    DATA(lt_msgs) = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    result = lines( lt_msgs ).

  ENDMETHOD.


  " ========== Transport Extensions ==========

  METHOD tr_get_objects.

    IF context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS
      TRY.
          DATA lo_transport TYPE REF TO object.
          DATA lt_objects_c TYPE STANDARD TABLE OF REF TO object.
          DATA(lv_xco) = `XCO_CP_CTS`.
          DATA(lv_trkorr_c) = CONV string( trkorr ).

          CALL METHOD (lv_xco)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = lv_trkorr_c
            RECEIVING
              ro_transport = lo_transport.

          DATA lo_objects_api TYPE REF TO object.
          CALL METHOD lo_transport->(`OBJECTS`)
            RECEIVING
              ro_objects = lo_objects_api.

          DATA lo_all TYPE REF TO object.
          CALL METHOD lo_objects_api->(`ALL`)
            RECEIVING
              ro_all = lo_all.

          CALL METHOD lo_all->(`GET`)
            RECEIVING
              rt_objects = lt_objects_c.

          LOOP AT lt_objects_c INTO DATA(lo_obj).
            DATA ls_obj_c TYPE ty_s_tr_object.
            CLEAR ls_obj_c.
            TRY.
                CALL METHOD lo_obj->(`GET_PGMID`)
                  RECEIVING
                    rv_pgmid = ls_obj_c-pgmid.
                CALL METHOD lo_obj->(`GET_TYPE`)
                  RECEIVING
                    rv_type = ls_obj_c-object.
                CALL METHOD lo_obj->(`GET_NAME`)
                  RECEIVING
                    rv_name = ls_obj_c-obj_name.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            INSERT ls_obj_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use TR_GET_OBJECTS_OF_REQ_AN_TASKS
    DATA lr_objects TYPE REF TO data.
    DATA lr_header  TYPE REF TO data.
    FIELD-SYMBOLS <objects> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <object>  TYPE any.
    FIELD-SYMBOLS <header>  TYPE any.
    FIELD-SYMBOLS <comp>    TYPE any.
    DATA lv_fm TYPE string.

    TRY.
        CREATE DATA lr_objects TYPE STANDARD TABLE OF (`E071`).
        ASSIGN lr_objects->* TO <objects>.

        CREATE DATA lr_header TYPE (`TRWBO_REQUEST_HEADER`).
        ASSIGN lr_header->* TO <header>.
        ASSIGN COMPONENT `TRKORR` OF STRUCTURE <header> TO <comp>.
        <comp> = trkorr.

        lv_fm = `TR_GET_OBJECTS_OF_REQ_AN_TASKS`.
        CALL FUNCTION lv_fm
          EXPORTING
            is_request_header = <header>
          IMPORTING
            et_objects        = <objects>
          EXCEPTIONS
            OTHERS            = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <objects> ASSIGNING <object>.
          DATA(ls_obj) = VALUE ty_s_tr_object( ).
          ASSIGN COMPONENT `PGMID` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-pgmid = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-object = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJ_NAME` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-obj_name = <comp>. ENDIF.
          INSERT ls_obj INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD tr_get_user_requests.

    IF context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS transport filter
      TRY.
          DATA(lv_xco) = `XCO_CP_CTS`.
          DATA lo_filter_tr  TYPE REF TO object.
          DATA lo_status_f   TYPE REF TO object.
          DATA lo_owner_f    TYPE REF TO object.
          DATA lt_transports TYPE STANDARD TABLE OF REF TO object.

          DATA(lv_user_c) = CONV string( COND #( WHEN user IS NOT INITIAL THEN user ELSE sy-uname ) ).

          " Get modifiable transports for user
          CALL METHOD (lv_xco)=>(`TRANSPORTS`)
            RECEIVING
              ro_transports = lo_filter_tr.

          DATA lo_where TYPE REF TO object.
          CALL METHOD lo_filter_tr->(`ALL`)
            RECEIVING
              ro_all = lo_where.

          CALL METHOD lo_where->(`GET`)
            RECEIVING
              rt_transports = lt_transports.

          LOOP AT lt_transports INTO DATA(lo_tr).
            DATA ls_req_c TYPE ty_s_tr_request.
            CLEAR ls_req_c.
            TRY.
                DATA lo_props TYPE REF TO object.
                CALL METHOD lo_tr->(`PROPERTIES`)
                  RECEIVING
                    ro_properties = lo_props.
                DATA ls_prop TYPE REF TO data.
                CALL METHOD lo_props->(`GET`)
                  RECEIVING
                    rs_properties = ls_prop.
                FIELD-SYMBOLS <prop> TYPE any.
                FIELD-SYMBOLS <pcomp> TYPE any.
                ASSIGN ls_prop->* TO <prop>.
                ASSIGN COMPONENT `OWNER` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-owner = <pcomp>. ENDIF.
                IF ls_req_c-owner <> lv_user_c.
                  CONTINUE.
                ENDIF.
                ASSIGN COMPONENT `SHORT_DESCRIPTION` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-description = <pcomp>. ENDIF.
                ASSIGN COMPONENT `STATUS` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-status = <pcomp>. ENDIF.
                ASSIGN COMPONENT `TYPE` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-type = <pcomp>. ENDIF.

                DATA lv_tr_value TYPE string.
                CALL METHOD lo_tr->(`GET_VALUE`)
                  RECEIVING
                    rv_value = lv_tr_value.
                ls_req_c-trkorr = lv_tr_value.

              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            IF ls_req_c-trkorr IS NOT INITIAL.
              INSERT ls_req_c INTO TABLE result.
            ENDIF.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use dynamic SELECT from E070/E07T
    DATA lv_user  TYPE c LENGTH 12.
    DATA lv_type  TYPE c LENGTH 1.
    DATA lr_data  TYPE REF TO data.
    FIELD-SYMBOLS <tab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <comp>  TYPE any.

    TRY.
        lv_user = user.
        lv_type = request_type.

        DATA(lv_tab1) = `E070`.
        DATA(lv_tab2) = `E07T`.
        DATA(lv_where) = |AS4USER = '{ lv_user }' AND TRSTATUS IN ('D','L')|.

        " First read transports from E070
        DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( lv_tab1 ).
        DATA(lo_struct) = cl_abap_structdescr=>create( lt_comp ).
        DATA(lo_table) = cl_abap_tabledescr=>create( lo_struct ).
        CREATE DATA lr_data TYPE HANDLE lo_table.
        ASSIGN lr_data->* TO <tab>.

        SELECT trkorr, as4user, trstatus, trfunction
          FROM (lv_tab1)
          WHERE (lv_where)
          INTO CORRESPONDING FIELDS OF TABLE @<tab>.

        LOOP AT <tab> ASSIGNING <row>.
          DATA(ls_req) = VALUE ty_s_tr_request( ).
          ASSIGN COMPONENT `TRKORR` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-trkorr = <comp>. ENDIF.
          ASSIGN COMPONENT `AS4USER` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-owner = <comp>. ENDIF.
          ASSIGN COMPONENT `TRSTATUS` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-status = <comp>. ENDIF.
          ASSIGN COMPONENT `TRFUNCTION` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-type = <comp>. ENDIF.

          IF lv_type IS NOT INITIAL AND ls_req-type <> lv_type.
            CONTINUE.
          ENDIF.

          " Get description from E07T
          ls_req-description = tr_get_description( ls_req-trkorr ).
          INSERT ls_req INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD tr_get_description.

    IF context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS
      TRY.
          DATA lo_tr_d TYPE REF TO object.
          DATA(lv_xco_d) = `XCO_CP_CTS`.
          CALL METHOD (lv_xco_d)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = CONV string( trkorr )
            RECEIVING
              ro_transport = lo_tr_d.
          DATA lo_props_d TYPE REF TO object.
          CALL METHOD lo_tr_d->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_d.
          CALL METHOD lo_props_d->(`GET_SHORT_DESCRIPTION`)
            RECEIVING
              rv_short_description = result.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E07T
    DATA lv_trkorr TYPE c LENGTH 20.
    lv_trkorr = trkorr.

    TRY.
        DATA(lv_tab) = `E07T`.
        DATA(lv_where) = |TRKORR = '{ lv_trkorr }' AND LANGU = '{ sy-langu }'|.

        SELECT SINGLE as4text
          FROM (lv_tab)
          WHERE (lv_where)
          INTO @result.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD tr_is_released.

    IF context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS
      TRY.
          DATA lo_tr_r TYPE REF TO object.
          DATA(lv_xco_r) = `XCO_CP_CTS`.
          CALL METHOD (lv_xco_r)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = CONV string( trkorr )
            RECEIVING
              ro_transport = lo_tr_r.
          DATA lo_props_r TYPE REF TO object.
          CALL METHOD lo_tr_r->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_r.
          DATA lv_status_c TYPE string.
          CALL METHOD lo_props_r->(`GET_STATUS`)
            RECEIVING
              rv_status = lv_status_c.
          result = xsdbool( lv_status_c = `RELEASED` OR lv_status_c = `R` ).
        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E070
    DATA lv_trkorr TYPE c LENGTH 20.
    DATA lv_status TYPE c LENGTH 1.
    lv_trkorr = trkorr.

    TRY.
        DATA(lv_tab) = `E070`.
        DATA(lv_where) = |TRKORR = '{ lv_trkorr }'|.

        SELECT SINGLE trstatus
          FROM (lv_tab)
          WHERE (lv_where)
          INTO @lv_status.
        result = xsdbool( lv_status = `R` ).
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD tr_add_object.

    DATA lv_fm       TYPE string.
    DATA lv_trkorr   TYPE c LENGTH 20.
    DATA lv_pgmid    TYPE c LENGTH 4.
    DATA lv_object   TYPE c LENGTH 4.
    DATA lv_obj_name TYPE c LENGTH 120.

    lv_trkorr   = trkorr.
    lv_pgmid    = pgmid.
    lv_object   = object.
    lv_obj_name = obj_name.

    TRY.
        lv_fm = `TR_ORDER_CHOICE_CORRECTION`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_category    = lv_pgmid
            iv_object      = lv_object
            iv_obj_name    = lv_obj_name
            iv_order       = lv_trkorr
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TR_ADD_OBJECT failed`.
        ENDIF.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        RAISE EXCEPTION lx.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.


  " ========== Lock Extensions ==========

  METHOD lock_is_locked.

    " Try to set the lock — if it fails, the object is locked.
    DATA(lv_locked) = lock_set( val     = val
                                 t_param = t_param ).
    IF lv_locked = abap_true.
      " We got it — release immediately
      lock_delete( val     = val
                   t_param = t_param ).
      result = abap_false.
    ELSE.
      result = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD lock_get_owner.

    TRY.
        DATA(lt_locks) = lock_read( ).

        " Build the lock argument from params for matching
        DATA(lv_arg) = ``.
        LOOP AT t_param INTO DATA(ls_param).
          lv_arg = lv_arg && ls_param-value.
        ENDLOOP.

        DATA(lv_name) = c_trim_upper( val ).
        REPLACE `ENQUEUE_` IN lv_name WITH ``.

        LOOP AT lt_locks INTO DATA(ls_lock)
             WHERE lock_object CS lv_name.
          IF lv_arg IS INITIAL OR ls_lock-argument CS lv_arg.
            result = ls_lock-user.
            RETURN.
          ENDIF.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD lock_set_wait.

    DATA(lv_remaining) = retries.

    WHILE lv_remaining > 0.
      result = lock_set( val     = val
                          t_param = t_param ).
      IF result = abap_true.
        RETURN.
      ENDIF.
      lv_remaining = lv_remaining - 1.
      IF lv_remaining > 0.
        WAIT UP TO delay_ms / 1000 SECONDS.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  " ========== Number Range ==========

  METHOD numrange_get_next.

    DATA lv_object  TYPE c LENGTH 10.
    DATA lv_nr_sub  TYPE c LENGTH 2.
    DATA lv_number  TYPE c LENGTH 20.

    lv_object = object.
    lv_nr_sub = subobject.

    TRY.
        IF context_check_abap_cloud( ).
          " Cloud: use CL_NUMBERRANGE_RUNTIME
          DATA(lv_cls) = `CL_NUMBERRANGE_RUNTIME`.
          CALL METHOD (lv_cls)=>(`NUMBER_GET`)
            EXPORTING
              nr_range_nr = lv_nr_sub
              object      = lv_object
            IMPORTING
              number      = lv_number.
        ELSE.
          " Standard: use NUMBER_GET_NEXT FM
          DATA(lv_fm) = `NUMBER_GET_NEXT`.
          CALL FUNCTION lv_fm
            EXPORTING
              nr_range_nr = lv_nr_sub
              object      = lv_object
            IMPORTING
              number      = lv_number
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING
                val = |NUMBER_GET_NEXT failed for { lv_object }/{ lv_nr_sub }|.
          ENDIF.
        ENDIF.

        result = lv_number.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        RAISE EXCEPTION lx.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.


  " ========== Change Documents ==========

  METHOD changdoc_read.

    IF context_check_abap_cloud( ).
      " Cloud: use released CDS view I_ChangeDocument
      TRY.
          DATA(lv_cds) = `I_CHANGEDOCUMENTITEM`.
          DATA(lv_where_c) = |OBJECTCLASS = '{ objectclass }' AND OBJECTID = '{ objectid }'|.
          IF date_from IS NOT INITIAL.
            lv_where_c = |{ lv_where_c } AND CREATIONDATE >= '{ date_from }'|.
          ENDIF.
          IF date_to IS NOT INITIAL AND date_to <> '99991231'.
            lv_where_c = |{ lv_where_c } AND CREATIONDATE <= '{ date_to }'|.
          ENDIF.

          FIELD-SYMBOLS <cds_tab> TYPE STANDARD TABLE.
          FIELD-SYMBOLS <cds_row> TYPE any.
          FIELD-SYMBOLS <cds_fld> TYPE any.
          DATA lr_cds_tab TYPE REF TO data.

          DATA(lt_comp_c) = rtti_get_t_attri_by_table_name( lv_cds ).
          DATA(lo_struct_c) = cl_abap_structdescr=>create( lt_comp_c ).
          DATA(lo_table_c) = cl_abap_tabledescr=>create( lo_struct_c ).
          CREATE DATA lr_cds_tab TYPE HANDLE lo_table_c.
          ASSIGN lr_cds_tab->* TO <cds_tab>.

          SELECT *
            FROM (lv_cds)
            WHERE (lv_where_c)
            INTO CORRESPONDING FIELDS OF TABLE @<cds_tab>.

          LOOP AT <cds_tab> ASSIGNING <cds_row>.
            DATA(ls_doc_c) = VALUE ty_s_changdoc( ).
            ASSIGN COMPONENT `CHANGEDOCOBJECTCLASS` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc <> 0.
              ASSIGN COMPONENT `OBJECTCLASS` OF STRUCTURE <cds_row> TO <cds_fld>.
            ENDIF.
            ASSIGN COMPONENT `CHANGEDOCUMENT` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-changenr = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATEDBYUSER` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-username = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATIONDATE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-udate = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATIONTIME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-utime = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `TRANSACTIONCODE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-tcode = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMFIELDNAME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-fieldname = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMNEWVALUE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-new_value = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMOLDVALUE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-old_value = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHANGEDOCITEMTABLENAME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-tabname = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMCHNGIND` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-chngind = <cds_fld>. ENDIF.
            INSERT ls_doc_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use CHANGEDOCUMENT_READ_HEADERS/POSITIONS FMs
    DATA lv_fm         TYPE string.
    DATA lv_objectclas TYPE c LENGTH 15.
    DATA lv_objectid   TYPE c LENGTH 90.
    DATA lr_headers    TYPE REF TO data.
    DATA lr_positions  TYPE REF TO data.
    FIELD-SYMBOLS <headers>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <positions> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <hdr>       TYPE any.
    FIELD-SYMBOLS <pos>       TYPE any.
    FIELD-SYMBOLS <comp>      TYPE any.

    lv_objectclas = objectclass.
    lv_objectid   = objectid.

    TRY.
        CREATE DATA lr_headers TYPE STANDARD TABLE OF (`CDHDR`).
        CREATE DATA lr_positions TYPE STANDARD TABLE OF (`CDPOS`).
        ASSIGN lr_headers->* TO <headers>.
        ASSIGN lr_positions->* TO <positions>.

        lv_fm = `CHANGEDOCUMENT_READ_HEADERS`.
        CALL FUNCTION lv_fm
          EXPORTING
            objectclass = lv_objectclas
            objectid    = lv_objectid
            date_of_change = date_from
          TABLES
            i_cdhdr     = <headers>
          EXCEPTIONS
            OTHERS      = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <headers> ASSIGNING <hdr>.

          DATA(ls_doc) = VALUE ty_s_changdoc( ).
          ASSIGN COMPONENT `CHANGENR` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-changenr = <comp>. ENDIF.
          ASSIGN COMPONENT `USERNAME` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-username = <comp>. ENDIF.
          ASSIGN COMPONENT `UDATE` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-udate = <comp>. ENDIF.
          ASSIGN COMPONENT `UTIME` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-utime = <comp>. ENDIF.
          ASSIGN COMPONENT `TCODE` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-tcode = <comp>. ENDIF.

          " Read positions for this change number
          CLEAR <positions>.
          lv_fm = `CHANGEDOCUMENT_READ_POSITIONS`.
          CALL FUNCTION lv_fm
            EXPORTING
              changenumber = ls_doc-changenr
            TABLES
              editpos      = <positions>
            EXCEPTIONS
              OTHERS       = 1.

          IF <positions> IS INITIAL.
            INSERT ls_doc INTO TABLE result.
          ELSE.
            LOOP AT <positions> ASSIGNING <pos>.
              DATA(ls_pos) = ls_doc.
              ASSIGN COMPONENT `FNAME` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-fieldname = <comp>. ENDIF.
              ASSIGN COMPONENT `VALUE_OLD` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-old_value = <comp>. ENDIF.
              ASSIGN COMPONENT `VALUE_NEW` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-new_value = <comp>. ENDIF.
              ASSIGN COMPONENT `TABNAME` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-tabname = <comp>. ENDIF.
              ASSIGN COMPONENT `CHNGIND` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-chngind = <comp>. ENDIF.
              INSERT ls_pos INTO TABLE result.
            ENDLOOP.
          ENDIF.

        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  " ========== Background Job ==========

  METHOD job_submit_report.

    IF context_check_abap_cloud( ).
      " Cloud: Application Jobs have a different architecture (job catalog + templates).
      " Direct report submission is not available. Raise informative exception.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `job_submit_report: On ABAP Cloud use CL_APJ_RT_API with a registered job catalog entry instead`.
    ENDIF.

    " Standard ABAP: JOB_OPEN / JOB_SUBMIT / JOB_CLOSE
    DATA lv_fm       TYPE string.
    DATA lv_jobname  TYPE c LENGTH 32.
    DATA lv_jobcount TYPE c LENGTH 8.
    DATA lv_report   TYPE c LENGTH 40.
    DATA lv_variant  TYPE c LENGTH 14.

    lv_report = report.
    lv_variant = variant.
    lv_jobname = COND #( WHEN job_name IS NOT INITIAL THEN job_name
                         ELSE |Z2UI5_{ sy-datum }{ sy-uzeit }| ).

    TRY.
        lv_fm = `JOB_OPEN`.
        CALL FUNCTION lv_fm
          EXPORTING
            jobname  = lv_jobname
          IMPORTING
            jobcount = lv_jobcount
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `JOB_OPEN failed`.
        ENDIF.

        lv_fm = `JOB_SUBMIT`.
        CALL FUNCTION lv_fm
          EXPORTING
            authcknam = sy-uname
            jobcount  = lv_jobcount
            jobname   = lv_jobname
            report    = lv_report
            variant   = lv_variant
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `JOB_SUBMIT failed`.
        ENDIF.

        lv_fm = `JOB_CLOSE`.
        IF start_immediate = abap_true.
          CALL FUNCTION lv_fm
            EXPORTING
              jobcount  = lv_jobcount
              jobname   = lv_jobname
              strtimmed = abap_true
            EXCEPTIONS
              OTHERS    = 1.
        ELSE.
          CALL FUNCTION lv_fm
            EXPORTING
              jobcount  = lv_jobcount
              jobname   = lv_jobname
            EXCEPTIONS
              OTHERS    = 1.
        ENDIF.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `JOB_CLOSE failed`.
        ENDIF.

        result = lv_jobname.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        RAISE EXCEPTION lx.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.


  " ========== Email ==========

  METHOD mail_send.

    IF context_check_abap_cloud( ).
      " Cloud: use CL_BCS_MAIL_MESSAGE (released cloud mail API)
      DATA lo_mail_c TYPE REF TO object.
      DATA lv_cls_c  TYPE string.

      TRY.
          lv_cls_c = `CL_BCS_MAIL_MESSAGE`.
          CALL METHOD (lv_cls_c)=>(`CREATE_INSTANCE`)
            RECEIVING
              result = lo_mail_c.

          CALL METHOD lo_mail_c->(`SET_SENDER`)
            EXPORTING
              iv_address = context_get_user_tech( ) && `@placeholder.local`.

          CALL METHOD lo_mail_c->(`ADD_RECIPIENT`)
            EXPORTING
              iv_address = to.

          CALL METHOD lo_mail_c->(`SET_SUBJECT`)
            EXPORTING
              iv_subject = subject.

          IF html = abap_true.
            CALL METHOD lo_mail_c->(`SET_MAIN`)
              EXPORTING
                iv_content_type = `text/html`
                iv_content_text = body.
          ELSE.
            CALL METHOD lo_mail_c->(`SET_MAIN`)
              EXPORTING
                iv_content_type = `text/plain`
                iv_content_text = body.
          ENDIF.

          CALL METHOD lo_mail_c->(`SEND`)
            RECEIVING
              result = result.

        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use CL_BCS
    DATA lo_mail      TYPE REF TO object.
    DATA lo_sender    TYPE REF TO object.
    DATA lo_recipient TYPE REF TO object.
    DATA lo_doc       TYPE REF TO object.
    DATA lr_body      TYPE REF TO data.
    DATA lr_line      TYPE REF TO data.
    DATA lv_class     TYPE string.
    DATA lv_subject   TYPE c LENGTH 50.
    DATA lv_type      TYPE c LENGTH 3.
    DATA lv_address   TYPE c LENGTH 241.
    FIELD-SYMBOLS <body>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    lv_subject = subject.
    lv_address = to.
    lv_type    = COND #( WHEN html = abap_true THEN `HTM` ELSE `RAW` ).

    TRY.
        " Create BCS instance
        lv_class = `CL_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_PERSISTENT`)
          RECEIVING
            result = lo_mail.

        " Sender
        lv_class = `CL_SAPUSER_BCS`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            i_user = sy-uname
          RECEIVING
            result = lo_sender.
        CALL METHOD lo_mail->(`SET_SENDER`)
          EXPORTING
            i_sender = lo_sender.

        " Recipient
        lv_class = `CL_CAM_ADDRESS_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_INTERNET_ADDRESS`)
          EXPORTING
            i_address_string = lv_address
          RECEIVING
            result           = lo_recipient.
        CALL METHOD lo_mail->(`ADD_RECIPIENT`)
          EXPORTING
            i_recipient = lo_recipient.

        " Build body text table
        CREATE DATA lr_body TYPE (`BCSY_TEXT`).
        ASSIGN lr_body->* TO <body>.
        CREATE DATA lr_line TYPE (`SOLI`).
        ASSIGN lr_line->* TO <line>.

        DATA(lt_lines) = c_split( val = body sep = cv_char_utilities_newline ).
        LOOP AT lt_lines INTO DATA(lv_body_line).
          ASSIGN COMPONENT `LINE` OF STRUCTURE <line> TO <field>.
          <field> = lv_body_line.
          INSERT <line> INTO TABLE <body>.
        ENDLOOP.

        " Create document
        lv_class = `CL_DOCUMENT_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_DOCUMENT`)
          EXPORTING
            i_type    = lv_type
            i_text    = <body>
            i_subject = lv_subject
          RECEIVING
            result    = lo_doc.

        CALL METHOD lo_mail->(`SET_DOCUMENT`)
          EXPORTING
            i_document = lo_doc.
        CALL METHOD lo_mail->(`SET_SEND_IMMEDIATELY`)
          EXPORTING
            i_send_immediately = abap_true.

        CALL METHOD lo_mail->(`SEND`)
          RECEIVING
            result = result.
        COMMIT WORK AND WAIT.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD context_get_user_tech.

    TRY.

        DATA(lv_result) = VALUE string( ).
        DATA(lv_class) = `CL_ABAP_CONTEXT_INFO`.

        IF context_check_abap_cloud( ).
          CALL METHOD (lv_class)=>(`GET_USER_TECHNICAL_NAME`)
            RECEIVING
              rv_technical_name = lv_result.
        ELSE.
          CALL METHOD (lv_class)=>(`GET_USER_BUSINESS_PARTNER_ID`)
            RECEIVING
              rv_business_partner_id = lv_result.
        ENDIF.

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
    DATA temp2     TYPE ty_s_fix_val.

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

        result = lt_string.

    ENDTRY.

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
    DATA temp3               TYPE ty_t_classes.
    DATA implementation_name LIKE LINE OF lt_implementation_names.
    DATA temp4               LIKE LINE OF temp3.

    DATA type                TYPE c LENGTH 12.
    FIELD-SYMBOLS <class> TYPE data.
    DATA temp5   LIKE LINE OF lt_impl.
    DATA lr_impl LIKE REF TO temp5.
    FIELD-SYMBOLS <description> TYPE any.
    DATA temp6 TYPE ty_s_class_descr.

    IF context_check_abap_cloud( ).

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

    ELSE.

      ls_key-intkey = val.

      DATA lv_fm               TYPE string.
      lv_fm = `SEO_INTERFACE_IMPLEM_GET_ALL`.
      CALL FUNCTION lv_fm
        EXPORTING
          intkey        = ls_key
        IMPORTING
          impkeys       = lt_impl
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      type = `SEOC_CLASS_R`.
      CREATE DATA class TYPE (type).

      ASSIGN class->* TO <class>.

      LOOP AT lt_impl REFERENCE INTO lr_impl.

        CLEAR <class>.

        ls_clskey-clsname = lr_impl->clsname.

        lv_fm = `SEO_CLASS_READ`.
        CALL FUNCTION lv_fm
          EXPORTING
            clskey        = ls_clskey
          IMPORTING
            class         = <class>
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error.
        ENDIF.

        ASSIGN
          COMPONENT `DESCRIPT`
          OF STRUCTURE <class>
          TO <description>.
        ASSERT sy-subrc = 0.

        CLEAR temp6.
        temp6-classname   = lr_impl->clsname.
        temp6-description = <description>.
        INSERT
          temp6
          INTO TABLE result.
      ENDLOOP.

    ENDIF.

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
        DATA(lv_error) = x->get_text( ).
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

    IF context_check_abap_cloud( ).

      DATA current_obj TYPE REF TO object.
      DATA stack TYPE REF TO object.
      DATA full_stack TYPE REF TO object.
      DATA format_source TYPE REF TO object.
      DATA format_obj2 TYPE REF TO object.
      DATA format_obj3 TYPE REF TO object.
      DATA text_obj TYPE REF TO object.
      DATA lv_xco_cp TYPE c LENGTH 6.
      DATA ro_lines TYPE REF TO object.
      FIELD-SYMBOLS <current> TYPE any.
      FIELD-SYMBOLS <any> TYPE any.
      FIELD-SYMBOLS <call_stack> TYPE any.
      FIELD-SYMBOLS <format> TYPE any.
      FIELD-SYMBOLS <format2> TYPE any.

      "1 format source
      DATA(lv_assign) = `XCO_CP_CALL_STACK=>LINE_NUMBER_FLAVOR->SOURCE`.
      ASSIGN (lv_assign) TO <format>.

      lv_assign = `XCO_CP_CALL_STACK=>FORMAT`.
      ASSIGN (lv_assign) TO <format2>.
      format_obj2 = <format2>.

      CALL METHOD format_obj2->(`IF_XCO_CP_CS_FORMAT_FACTORY~ADT`)
        RECEIVING
          ro_adt = format_obj3.

      CALL METHOD format_obj3->(`WITH_LINE_NUMBER_FLAVOR`)
        EXPORTING
          io_line_number_flavor = <format>
        RECEIVING
          ro_me                 = format_source.

      lv_xco_cp = `XCO_CP`.
      ASSIGN (lv_xco_cp)=>(`CURRENT`) TO <current>.
      current_obj = <current>.

      ASSIGN current_obj->(`IF_XCO_CP_STD_CURRENT~CALL_STACK`) TO <call_stack>.
      stack = <call_stack>.

      CALL METHOD stack->(`IF_XCO_CP_STD_CUR_API_CLL_STCK~FULL`)
        RECEIVING
          ro_full = full_stack.

      DATA r TYPE REF TO data.
      CREATE DATA r TYPE REF TO (`IF_XCO_CS_FORMAT`).
      ASSIGN r->* TO <any>.
      <any> ?= format_source.

      CALL METHOD full_stack->(`IF_XCO_CP_CALL_STACK~AS_TEXT`)
        EXPORTING
          io_format = <any>
        RECEIVING
          ro_text   = text_obj.

      CALL METHOD text_obj->(`IF_XCO_TEXT~GET_LINES`)
        RECEIVING
          ro_lines = ro_lines.

      FIELD-SYMBOLS <lt_lines> TYPE string_table.
      ASSIGN ro_lines->(`IF_XCO_STRINGS~VALUE`) TO <lt_lines>.

      LOOP AT <lt_lines> INTO DATA(text).
        DATA(ls_stack) = VALUE ty_s_stack( ).
        SPLIT text AT ` ` INTO ls_stack-class ls_stack-include ls_stack-method.
        INSERT ls_stack INTO TABLE result.
      ENDLOOP.

      DELETE result INDEX 1.

    ENDIF.

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

    IF context_check_abap_cloud( ).

      " ABAP Cloud: released Business Application Log API (cl_bali_*).
      " All access is dynamic so this class still compiles on lower releases.
      " The class names are kept in variables - a string literal inside the
      " dynamic component selector ( '...' )=>( '...' ) is not valid ABAP.
      " Returning parameter names follow the released API (header/log/db_handler).
      DATA lo_header TYPE REF TO object.
      DATA lo_log    TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lv_class  TYPE string.

      TRY.
          lv_class = `CL_BALI_HEADER_SETTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            EXPORTING
              object      = object
              subobject   = subobject
              external_id = id
            RECEIVING
              header      = lo_header.

          lv_class = `CL_BALI_LOG`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              log = lo_log.

          CALL METHOD lo_log->(`SET_HEADER`)
            EXPORTING
              header = lo_header.

          bal_cloud_add_items( log   = lo_log
                               t_log = t_log ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`SAVE_LOG`)
            EXPORTING
              log = lo_log.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

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

          bal_std_msg_add( handle = <handle>
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

    ENDIF.

  ENDMETHOD.

  METHOD bal_read.

    IF context_check_abap_cloud( ).

      " Load the persisted logs (incl. items) via the released filter API and map
      " each item back to the framework's ty_s_msg structure with full metadata.
      TYPES:
        BEGIN OF ty_item,
          log_item_number TYPE i,
          item            TYPE REF TO object,
        END OF ty_item.
      DATA lt_items    TYPE STANDARD TABLE OF ty_item.
      DATA lo_filter   TYPE REF TO object.
      DATA lo_db       TYPE REF TO object.
      DATA lt_logs     TYPE STANDARD TABLE OF REF TO object.
      DATA lv_text     TYPE string.
      DATA lv_class    TYPE string.
      DATA lv_severity TYPE c LENGTH 1.
      DATA lv_msgid    TYPE string.
      DATA lv_msgno    TYPE string.
      DATA lv_msgv1    TYPE string.
      DATA lv_msgv2    TYPE string.
      DATA lv_msgv3    TYPE string.
      DATA lv_msgv4    TYPE string.

      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          LOOP AT lt_logs INTO DATA(lo_log).

            lt_items = VALUE #( ).
            CALL METHOD lo_log->(`GET_ALL_ITEMS`)
              RECEIVING
                item_table = lt_items.

            LOOP AT lt_items INTO DATA(ls_item).
              IF ls_item-item IS NOT BOUND.
                CONTINUE.
              ENDIF.

              DATA(ls_msg) = VALUE ty_s_msg( ).

              lv_text = ``.
              CALL METHOD ls_item-item->(`GET_MESSAGE_TEXT`)
                RECEIVING
                  message_text = lv_text.
              ls_msg-text = lv_text.

              TRY.
                  CALL METHOD ls_item-item->(`GET_SEVERITY`)
                    RECEIVING
                      severity = lv_severity.
                  ls_msg-type = lv_severity.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_ID`)
                    RECEIVING
                      id = lv_msgid.
                  ls_msg-id = lv_msgid.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_NUMBER`)
                    RECEIVING
                      number = lv_msgno.
                  ls_msg-no = lv_msgno.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_1`)
                    RECEIVING
                      variable_1 = lv_msgv1.
                  ls_msg-v1 = lv_msgv1.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_2`)
                    RECEIVING
                      variable_2 = lv_msgv2.
                  ls_msg-v2 = lv_msgv2.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_3`)
                    RECEIVING
                      variable_3 = lv_msgv3.
                  ls_msg-v3 = lv_msgv3.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_4`)
                    RECEIVING
                      variable_4 = lv_msgv4.
                  ls_msg-v4 = lv_msgv4.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              INSERT ls_msg INTO TABLE result.
            ENDLOOP.

          ENDLOOP.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

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
          lr_handles = bal_std_load_handles( object    = object
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
                INSERT bal_std_map_msg( <msg> ) INTO TABLE result.
              ENDIF.
            ENDLOOP.

          ENDLOOP.

        CATCH cx_root INTO DATA(lx_read).
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_read.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_update.

    IF context_check_abap_cloud( ).

      " Load the existing log and append items. If no log exists, create a new one.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lt_logs   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_class  TYPE string.

      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          IF lt_logs IS INITIAL.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          " Append to the first (most recent) log
          DATA(lo_log) = lt_logs[ 1 ].
          bal_cloud_add_items( log   = lo_log
                               t_log = t_log ).

          CALL METHOD lo_db->(`SAVE_LOG`)
            EXPORTING
              log = lo_log.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          " Fallback: create new log if update fails
          bal_create( object    = object
                      subobject = subobject
                      id        = id
                      t_log     = t_log ).
      ENDTRY.

    ELSE.

      " Append the given messages to an already persisted log; create a new one if none exists.
      DATA lv_fm      TYPE string.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle>  TYPE any.

      TRY.
          lr_handles = bal_std_load_handles( object    = object
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
          bal_std_msg_add( handle = <handle>
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

    ENDIF.

  ENDMETHOD.

  METHOD bal_delete.

    IF context_check_abap_cloud( ).

      DATA lo_filter TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lt_logs   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_class  TYPE string.

      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          LOOP AT lt_logs INTO DATA(lo_log).
            CALL METHOD lo_db->(`DELETE_LOG`)
              EXPORTING
                log = lo_log.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

      DATA lv_fm     TYPE string.
      DATA lr_filter TYPE REF TO data.
      FIELD-SYMBOLS <filter> TYPE any.

      TRY.
          lr_filter = bal_std_build_filter( object    = object
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

    ENDIF.

  ENDMETHOD.

  METHOD context_get_sy.

    result = CORRESPONDING #( sy ).

  ENDMETHOD.

  METHOD tr_create.

    " Create an empty transport request (default type `T` = transport of copies).
    " Uses the released class CL_ADT_CTS_MANAGEMENT, available on standard ABAP
    " (>= 7.51) and ABAP Cloud. Called dynamically so the source stays compilable
    " on all targets - on releases where the class is missing a clean
    " z2ui5_cx_util_error is raised instead of a short dump.
    TRY.

        DATA lr_header TYPE REF TO data.
        FIELD-SYMBOLS <header> TYPE any.
        FIELD-SYMBOLS <trkorr> TYPE any.
        DATA lv_class TYPE string.

        CREATE DATA lr_header TYPE (`TRWBO_REQUEST_HEADER`).
        ASSIGN lr_header->* TO <header>.

        lv_class = `CL_ADT_CTS_MANAGEMENT`.
        CALL METHOD (lv_class)=>(`CREATE_EMPTY_REQUEST`)
          EXPORTING
            iv_type           = type
            iv_text           = text
            iv_target         = target
          IMPORTING
            es_request_header = <header>.

        ASSIGN COMPONENT `TRKORR` OF STRUCTURE <header> TO <trkorr>.
        result = <trkorr>.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_release.

    " Release a transport request via the released CTS REST API
    " (CL_CTS_REST_API_FACTORY). Works on standard ABAP and ABAP Cloud.
    TRY.

        DATA lo_api   TYPE REF TO object.
        DATA lv_class TYPE string.

        lv_class = `CL_CTS_REST_API_FACTORY`.
        CALL METHOD (lv_class)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = lo_api.

        CALL METHOD lo_api->(`RELEASE`)
          EXPORTING
            iv_trkorr       = trkorr
            iv_ignore_locks = ignore_locks.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_copy_objects.

    " Copying objects between requests relies on the classic transport
    " functions (TR_COPY_COMM) which are not released on ABAP Cloud.
    IF context_check_abap_cloud( ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_copy_objects is not supported on ABAP Cloud`.
    ENDIF.

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

    " Importing transports via TMS (TMS_MGR_*) is not available on ABAP Cloud.
    IF context_check_abap_cloud( ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_import is not supported on ABAP Cloud`.
    ENDIF.

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

    " Reading the transport log (TR_READ_GLOBAL_INFO_OF_REQUEST) is not
    " available on ABAP Cloud.
    IF context_check_abap_cloud( ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_check_status is not supported on ABAP Cloud`.
    ENDIF.

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

  METHOD bal_cloud_add_items.

    DATA lo_item  TYPE REF TO object.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_class TYPE string.

    LOOP AT t_log INTO DATA(ls_log).

      lv_msgty = ls_log-type.

      IF ls_log-id IS NOT INITIAL AND ls_log-no IS NOT INITIAL.
        lv_class = `CL_BALI_MESSAGE_SETTER`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            severity   = lv_msgty
            id         = ls_log-id
            number     = ls_log-no
            variable_1 = ls_log-v1
            variable_2 = ls_log-v2
            variable_3 = ls_log-v3
            variable_4 = ls_log-v4
          RECEIVING
            message    = lo_item.
      ELSE.
        lv_class = `CL_BALI_FREE_TEXT_SETTER`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            severity  = lv_msgty
            text      = ls_log-text
          RECEIVING
            free_text = lo_item.
      ENDIF.

      CALL METHOD log->(`ADD_ITEM`)
        EXPORTING
          item = lo_item.

    ENDLOOP.

  ENDMETHOD.

  METHOD bal_cloud_build_filter.

    DATA lo_filter TYPE REF TO object.
    DATA lv_class  TYPE string.

    lv_class = `CL_BALI_LOG_FILTER`.
    CALL METHOD (lv_class)=>(`CREATE`)
      RECEIVING
        filter = lo_filter.

    CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
      EXPORTING
        object      = object
        subobject   = subobject
        external_id = id.

    result = lo_filter.

  ENDMETHOD.

  METHOD bal_std_msg_add.

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

  METHOD bal_std_load_handles.

    DATA lv_fm      TYPE string.
    DATA lr_filter  TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter>  TYPE any.
    FIELD-SYMBOLS <headers> TYPE SORTED TABLE.
    FIELD-SYMBOLS <handles> TYPE SORTED TABLE.

    lr_filter = bal_std_build_filter( object    = object
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

  METHOD bal_std_build_filter.

    FIELD-SYMBOLS <filter> TYPE any.

    CREATE DATA result TYPE ('BAL_S_LFIL').
    ASSIGN result->* TO <filter>.

    bal_std_filter_add( EXPORTING comp   = `OBJECT`
                                  value  = object
                        CHANGING  filter = <filter> ).
    bal_std_filter_add( EXPORTING comp   = `SUBOBJECT`
                                  value  = subobject
                        CHANGING  filter = <filter> ).
    bal_std_filter_add( EXPORTING comp   = `EXTNUMBER`
                                  value  = id
                        CHANGING  filter = <filter> ).

  ENDMETHOD.

  METHOD bal_std_filter_add.

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

  METHOD bal_std_map_msg.

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

ENDCLASS.
