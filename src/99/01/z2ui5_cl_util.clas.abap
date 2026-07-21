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
    CLASS-DATA cv_char_util_newline        TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_util_cr_lf          TYPE c LENGTH 2 READ-ONLY.
    CLASS-DATA cv_char_util_horizontal_tab TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_util_charsize       TYPE i          READ-ONLY.
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

    TYPES:
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY.

    CLASS-METHODS rtti_get_t_ddic_fixed_values
      IMPORTING
        rollname      TYPE clike
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE ty_t_fix_val ##NEEDED.

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
    TYPES ty_t_field_diff TYPE STANDARD TABLE OF ty_s_field_diff WITH DEFAULT KEY.

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

    " ========== Lock Extensions ==========

    " ========== Number Range ==========

    " ========== Change Documents ==========

    " ========== Background Job ==========

    " ========== Email ==========

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


    CLASS-METHODS msg_get_text
      IMPORTING
        val           TYPE any
        val2          TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_by_sy
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        is_msg        TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        i_classname   TYPE clike
      RETURNING
        VALUE(result) TYPE string.


    CLASS-METHODS msg_get_internal
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS check_is_rap_struct
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_rap
      IMPORTING
        val           TYPE any
        entity_name   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_rap_row
      IMPORTING
        val         TYPE any
        entity_name TYPE string OPTIONAL
      EXPORTING
        messages    TYPE ty_t_msg
        is_row      TYPE abap_bool.

    CLASS-METHODS msg_get_rap_element
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_state_area
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_action
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_pid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_cid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_tky
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_flatten
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_meta
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
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

    CLASS-DATA gv_check_cloud TYPE abap_bool.
    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

ENDCLASS.

CLASS z2ui5_cl_util IMPLEMENTATION.

  METHOD class_constructor.

    cv_char_util_newline        = cl_abap_char_utilities=>newline.
    cv_char_util_cr_lf          = cl_abap_char_utilities=>cr_lf.
    cv_char_util_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.
    cv_char_util_charsize       = cl_abap_char_utilities=>charsize.
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
      DATA temp188 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.

      IF val = abap_true.
        temp188 = `true`.
      ELSE.
        temp188 = `false`.
      ENDIF.
      result = temp188.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.

  METHOD boolean_check_by_data.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp189 TYPE string.
        DATA lv_abs_name LIKE temp189.
        DATA lr_cache TYPE REF TO z2ui5_cl_util=>ty_s_bool_cache.
        DATA temp190 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp190.
        DATA temp191 TYPE z2ui5_cl_util=>ty_s_bool_cache.

    TRY.

        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        " all supported boolean types are character-like flags, this check
        " filters out every other type before the name based cache lookup
        IF lo_descr->type_kind <> cl_abap_typedescr=>typekind_char.
          RETURN.
        ENDIF.


        temp189 = lo_descr->absolute_name.

        lv_abs_name = temp189.


        READ TABLE mt_bool_cache REFERENCE INTO lr_cache
             WITH TABLE KEY absolute_name = lv_abs_name.
        IF sy-subrc = 0.
          result = lr_cache->is_bool.
          RETURN.
        ENDIF.


        temp190 ?= lo_descr.

        lo_ele = temp190.
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).


        CLEAR temp191.
        temp191-absolute_name = lv_abs_name.
        temp191-is_bool = result.
        INSERT temp191 INTO TABLE mt_bool_cache.

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

    DATA temp192 TYPE string.
    temp192 = val.
    result = shift_left( shift_right( temp192 ) ).
    result = shift_right( val = result
                          sub = cv_char_util_horizontal_tab ).
    result = shift_left( val = result
                         sub = cv_char_util_horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.

  METHOD c_trim_lower.

    DATA temp193 TYPE string.
    temp193 = val.
    result = to_lower( c_trim( temp193 ) ).

  ENDMETHOD.

  METHOD c_trim_upper.

    DATA temp194 TYPE string.
    temp194 = val.
    result = to_upper( c_trim( temp194 ) ).

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

    DATA temp195 TYPE abap_component_tab.
    DATA temp30 LIKE LINE OF temp195.
    DATA lr_comp LIKE REF TO temp30.
      DATA temp196 TYPE z2ui5_cl_util=>ty_s_filter_multi.
    temp195 = rtti_get_t_attri_by_any( val ).


    LOOP AT temp195 REFERENCE INTO lr_comp.

      CLEAR temp196.
      temp196-name = lr_comp->name.
      INSERT temp196 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_range_by_token.

    DATA lv_value LIKE val.
    DATA lv_length TYPE i.
    lv_value = val.
    IF lv_value IS INITIAL.
      RETURN.
    ENDIF.

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
        IF lv_length > 0 AND lv_value+lv_length(1) = `*`.
          lv_value = substring( val = lv_value off = 1 len = lv_length - 1 ).
          CLEAR result.
          result-sign = `I`.
          result-option = `CP`.
          result-low = lv_value.
        ELSEIF lv_length = 0.
          " Single '*' means contains-pattern with empty value
          CLEAR result.
          result-sign = `I`.
          result-option = `CP`.
          result-low = ``.
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
    FIELD-SYMBOLS <temp197> TYPE z2ui5_cl_util=>ty_s_filter_multi.
DATA lr_filter LIKE REF TO <temp197>.
    DATA ls_token LIKE LINE OF lr_filter->t_token_removed.
      DATA temp198 TYPE z2ui5_cl_util=>ty_s_token.
    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp31 LIKE LINE OF result.
    DATA temp32 LIKE sy-tabix.

    result = val.

    READ TABLE result WITH KEY name = name ASSIGNING <temp197>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp197> INTO lr_filter.

    LOOP AT lr_filter->t_token_removed INTO ls_token.
      DELETE lr_filter->t_token WHERE key = ls_token-key.
    ENDLOOP.

    LOOP AT lr_filter->t_token_added INTO ls_token.

      CLEAR temp198.
      temp198-key = ls_token-key.
      temp198-text = ls_token-text.
      temp198-visible = abap_true.
      temp198-editable = abap_true.
      INSERT temp198 INTO TABLE lr_filter->t_token.
    ENDLOOP.

    CLEAR lr_filter->t_token_removed.
    CLEAR lr_filter->t_token_added.




    temp32 = sy-tabix.
    READ TABLE result WITH KEY name = name INTO temp31.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_range = z2ui5_cl_util=>filter_get_range_t_by_token_t( temp31-t_token ).
    lr_filter->t_range = lt_range.

  ENDMETHOD.

  METHOD filter_get_range_t_by_token_t.

    DATA ls_token LIKE LINE OF val.
    LOOP AT val INTO ls_token.
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_token_range_mapping.

    DATA temp199 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp200 LIKE LINE OF temp199.
    CLEAR temp199.

    temp200-n = `EQ`.
    temp200-v = `={LOW}`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `LT`.
    temp200-v = `<{LOW}`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `LE`.
    temp200-v = `<={LOW}`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `GT`.
    temp200-v = `>{LOW}`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `GE`.
    temp200-v = `>={LOW}`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `CP`.
    temp200-v = `*{LOW}*`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `BT`.
    temp200-v = `{LOW}...{HIGH}`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `NB`.
    temp200-v = `!({LOW}...{HIGH})`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `NE`.
    temp200-v = `!(={LOW})`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `NP`.
    temp200-v = `!(*{LOW}*)`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `!<leer>`.
    temp200-v = `!(<leer>)`.
    INSERT temp200 INTO TABLE temp199.
    temp200-n = `<leer>`.
    temp200-v = `<leer>`.
    INSERT temp200 INTO TABLE temp199.
    result = temp199.

  ENDMETHOD.

  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp201 TYPE ty_t_range.
    DATA lt_tab LIKE temp201.
    DATA temp202 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp202.
      DATA lv_value TYPE z2ui5_cl_util=>ty_s_name_value-v.
      DATA temp33 LIKE LINE OF lt_mapping.
      DATA temp34 LIKE sy-tabix.
      DATA temp203 TYPE z2ui5_cl_util=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).


    CLEAR temp201.

    lt_tab = temp201.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab
    ).



    LOOP AT lt_tab REFERENCE INTO lr_row.




      temp34 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option INTO temp33.
      sy-tabix = temp34.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = temp33-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.


      CLEAR temp203.
      temp203-key = lv_value.
      temp203-text = lv_value.
      temp203-visible = abap_true.
      temp203-editable = abap_true.
      INSERT temp203 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_val.
    " TRANSPILER NOTE: ABAP CS operator is ALWAYS case-insensitive regardless
    " of the ignore_case flag. The flag only pre-converts to uppercase for
    " consistency, but CS itself never does case-sensitive matching.
    " JS equivalent: always use toLowerCase().includes(toLowerCase()).
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    DATA temp204 TYPE string.
    DATA lv_search LIKE temp204.
      DATA lv_check_found LIKE abap_false.
      DATA lv_index TYPE i.
          DATA lv_name LIKE LINE OF fields.
          DATA temp35 LIKE LINE OF fields.
          DATA temp36 LIKE sy-tabix.
        DATA lv_value TYPE string.
    IF ignore_case = abap_true.
      temp204 = to_upper( val ).
    ELSE.
      temp204 = val.
    ENDIF.

    lv_search = temp204.

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



          temp36 = sy-tabix.
          READ TABLE fields INDEX lv_index INTO temp35.
          sy-tabix = temp36.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lv_name = temp35.
          ASSIGN COMPONENT lv_name OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            lv_index = lv_index + 1.
            CONTINUE.
          ENDIF.
        ENDIF.


        lv_value = |{ <field> }|.
        IF ignore_case = abap_true.
          lv_value = to_upper( lv_value ).
          IF lv_value CS lv_search.
            lv_check_found = abap_true.
            EXIT.
          ENDIF.
        ELSE.
          " Case-sensitive: use find() because CS is always case-insensitive
          IF find( val = lv_value sub = lv_search ) >= 0.
            lv_check_found = abap_true.
            EXIT.
          ENDIF.
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
    DATA temp205 TYPE REF TO cl_abap_tabledescr.
    DATA tab LIKE temp205.
    DATA temp206 TYPE REF TO cl_abap_structdescr.
    DATA struc LIKE temp206.
    DATA temp207 TYPE abap_component_tab.
    DATA temp37 LIKE LINE OF temp207.
    DATA lr_comp LIKE REF TO temp37.
    DATA lr_row TYPE REF TO data.
      DATA lv_index TYPE i.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
        DATA lv_field_val TYPE string.

    ASSIGN val TO <tab>.

    temp205 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

    tab = temp205.


    temp206 ?= tab->get_table_line_type( ).

    struc = temp206.

    CLEAR lv_line.

    temp207 = struc->get_components( ).


    LOOP AT temp207 REFERENCE INTO lr_comp.
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

        lv_field_val = |{ <field> }|.
        REPLACE ALL OCCURRENCES OF `;` IN lv_field_val WITH `,`.
        lv_line = |{ lv_line }{ lv_field_val };|.
      ENDDO.
      INSERT lv_line INTO TABLE lt_lines.
    ENDLOOP.

    result = concat_lines_of( table = lt_lines sep = cv_char_util_cr_lf ).

  ENDMETHOD.

  METHOD itab_get_itab_by_csv.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.

    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_rows TYPE temp1.
    TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_cols TYPE temp2.
    DATA temp38 LIKE LINE OF lt_rows.
    DATA temp39 LIKE sy-tabix.
    DATA temp208 LIKE LINE OF lt_cols.
    DATA lr_col LIKE REF TO temp208.
      DATA lv_name TYPE string.
      DATA temp209 TYPE abap_componentdescr.
    DATA struc TYPE REF TO cl_abap_structdescr.
    DATA temp210 TYPE REF TO cl_abap_datadescr.
    DATA data LIKE temp210.
    DATA o_table_desc TYPE REF TO cl_abap_tabledescr.
    DATA temp211 LIKE LINE OF lt_rows.
    DATA lr_rows LIKE REF TO temp211.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
    SPLIT val AT cv_char_util_newline INTO TABLE lt_rows.




    temp39 = sy-tabix.
    READ TABLE lt_rows INDEX 1 INTO temp38.
    sy-tabix = temp39.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    SPLIT temp38 AT `;` INTO TABLE lt_cols.



    LOOP AT lt_cols REFERENCE INTO lr_col.


      lv_name = c_trim_upper( lr_col->* ).
      REPLACE ALL OCCURRENCES OF ` ` IN lv_name WITH `_`.


      CLEAR temp209.
      temp209-name = lv_name.
      temp209-type = cl_abap_elemdescr=>get_c( 40 ).
      INSERT temp209 INTO TABLE lt_comp.
    ENDLOOP.


    struc = cl_abap_structdescr=>get( lt_comp ).

    temp210 ?= struc.

    data = temp210.

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
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
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
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.
  ENDMETHOD.

  METHOD json_stringify.
        DATA temp212 TYPE REF TO z2ui5_if_ajson.
        DATA li_ajson LIKE temp212.
        DATA x TYPE REF TO cx_root.
    TRY.


        temp212 ?= z2ui5_cl_ajson=>create_empty( ).

        li_ajson = temp212.
        result = li_ajson->set( iv_path = `/`
                                iv_val  = any )->stringify( ).


      CATCH cx_root INTO x.
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
        DATA lo_typdescr TYPE REF TO cl_abap_typedescr.
        DATA temp213 TYPE REF TO cl_abap_refdescr.
        DATA lo_ref LIKE temp213.

    TRY.

        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).

        temp213 ?= lo_typdescr.

        lo_ref = temp213.
        result = abap_true.
      CATCH cx_root ##NO_HANDLER.
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
    DATA temp214 TYPE REF TO cl_abap_refdescr.
    DATA ref LIKE temp214.
    DATA name TYPE abap_abstypename.
    rtti = cl_abap_typedescr=>describe_by_data( in  ).

    temp214 ?= rtti.

    ref = temp214.

    name = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_get_type_name.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp215 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp215.
    TRY.


        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        temp215 ?= lo_descr.

        lo_ele = temp215.
        result = lo_ele->get_relative_name( ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.
        DATA type_desc TYPE REF TO cl_abap_typedescr.
        DATA x TYPE REF TO cx_root.
    DATA temp216 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp216.
    DATA comps TYPE abap_component_tab.
    DATA temp217 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp217.
        DATA incl_comps TYPE abap_component_tab.
        DATA temp218 LIKE LINE OF incl_comps.
        DATA lr_incl_comp LIKE REF TO temp218.

    TRY.


        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                             RECEIVING  p_descr_ref    = type_desc
                                             EXCEPTIONS type_not_found = 1 ).


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

    temp216 ?= type_desc.

    sdescr = temp216.

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
    DATA temp219 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).

    temp219 ?= lo_obj_ref.
    result = temp219->attributes.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_type   TYPE REF TO cl_abap_typedescr.
        DATA temp220 TYPE REF TO cl_abap_structdescr.
        DATA temp221 TYPE REF TO cl_abap_structdescr.
        DATA temp40 TYPE REF TO cl_abap_tabledescr.
    DATA temp222 TYPE string.
    DATA lv_absolute_name LIKE temp222.
    DATA lr_cache TYPE REF TO z2ui5_cl_util=>ty_s_attri_cache.
    DATA comps TYPE abap_component_tab.
    DATA temp223 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp223.
        DATA lt_attri TYPE abap_component_tab.
      DATA temp224 TYPE z2ui5_cl_util=>ty_s_attri_cache.

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

        temp220 ?= lo_type.
        lo_struct = temp220.
      WHEN cl_abap_typedescr=>kind_table.


        temp40 ?= lo_type.
        temp221 ?= temp40->get_table_line_type( ).
        lo_struct = temp221.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types

    temp222 = lo_struct->absolute_name.

    lv_absolute_name = temp222.

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

      CLEAR temp224.
      temp224-absolute_name = lv_absolute_name.
      temp224-o_struct = lo_struct.
      temp224-t_attri = result.
      INSERT temp224 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_t_ddic_fixed_values.
        DATA temp225 TYPE string.
        DATA typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp226 TYPE REF TO cl_abap_elemdescr.
        DATA elemdescr LIKE temp226.

    IF rollname IS INITIAL.
      RETURN.
    ENDIF.

    TRY.


        temp225 = rollname.

        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp225
                                             RECEIVING  p_descr_ref    = typedescr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        temp226 ?= typedescr.

        elemdescr = temp226.

        result = rtti_get_t_fixvalues( elemdescr = elemdescr
                                       langu     = langu ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_tab_get_relative_name.

    FIELD-SYMBOLS <table> TYPE any.
        DATA typedesc TYPE REF TO cl_abap_typedescr.
            DATA temp227 TYPE REF TO cl_abap_tabledescr.
            DATA tabledesc LIKE temp227.
            DATA temp228 TYPE REF TO cl_abap_structdescr.
            DATA structdesc LIKE temp228.

    TRY.

        typedesc = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.

            temp227 ?= typedesc.

            tabledesc = temp227.

            temp228 ?= tabledesc->get_table_line_type( ).

            structdesc = temp228.
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

    DATA temp229 TYPE string.
    DATA conex LIKE temp229.
    IF output = abap_true.
      temp229 = |CONVERSION_EXIT_{ convexit }_OUTPUT|.
    ELSE.
      temp229 = |CONVERSION_EXIT_{ convexit }_INPUT|.
    ENDIF.

    conex = temp229.

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

  METHOD filter_get_sql_by_sql_string.

    DATA temp230 TYPE string.
    DATA lv_sql LIKE temp230.
    DATA lv_squished LIKE lv_sql.
    DATA lv_dummy TYPE string.
    DATA lv_tab TYPE string.
    DATA lv_upper TYPE string.
      DATA lv_pos TYPE i.
    temp230 = val.

    lv_sql = temp230.


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
    DATA ls_sy TYPE z2ui5_cl_util=>ty_syst.
    DATA lv_dummy TYPE t.
    ls_sy = z2ui5_cl_util=>context_get_sy( ).

    CONVERT TIME STAMP val TIME ZONE ls_sy-zonlo INTO DATE result TIME lv_dummy.
  ENDMETHOD.

  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.

  METHOD time_get_time_by_stampl.
    DATA ls_sy TYPE z2ui5_cl_util=>ty_syst.
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
    DATA temp231 TYPE string.
    DATA temp232 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).

    lv_val = c_trim_lower( val ).

    CLEAR temp231.

    READ TABLE lt_params INTO temp232 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp231 = temp232-v.
    ENDIF.
    result = temp231.

  ENDMETHOD.

  METHOD url_param_get_tab.

    DATA lv_search TYPE string.
    DATA lv_search2 TYPE string.
    DATA temp233 TYPE string.
    TYPES temp3 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp3.
    DATA temp234 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp234.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp235 TYPE z2ui5_cl_util=>ty_s_name_value.
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
      temp233 = lv_search2.
    ELSE.
      temp233 = lv_search.
    ENDIF.
    lv_search = temp233.

    lv_search2 = substring_after( val = c_trim_lower( lv_search )
                                  sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.



    SPLIT lv_search AT `&` INTO TABLE lt_param.



    LOOP AT lt_param REFERENCE INTO lr_param.


      SPLIT lr_param->* AT `=` INTO lv_name lv_value.

      CLEAR temp235.
      temp235-n = lv_name.
      temp235-v = lv_value.
      INSERT temp235 INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.

  METHOD url_param_set.

    DATA lt_params TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lv_n TYPE string.
    DATA lv_v TYPE string.
    DATA temp236 LIKE LINE OF lt_params.
    DATA lr_params LIKE REF TO temp236.
      DATA temp237 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).

    lv_n = c_trim_lower( name ).

    lv_v = c_trim( value ).



    LOOP AT lt_params REFERENCE INTO lr_params
         WHERE n = lv_n.
      lr_params->v = lv_v.
    ENDLOOP.
    IF sy-subrc <> 0.

      CLEAR temp237.
      temp237-n = lv_n.
      temp237-v = lv_v.
      INSERT temp237 INTO TABLE lt_params.
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
        DATA temp238 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp238.
            DATA temp239 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp239.
            DATA temp240 TYPE REF TO cl_abap_structdescr.
    DATA lt_comps TYPE abap_component_tab.
    DATA temp241 LIKE LINE OF lt_comps.
    DATA lr_comp LIKE REF TO temp241.
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

        temp238 ?= lo_obj.

        lo_struct = temp238.

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


            temp239 ?= lo_obj.

            lo_tab = temp239.

            temp240 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp240.
          CATCH cx_root.
            RETURN.
        ENDTRY.

    ENDTRY.


    lt_comps = lo_struct->get_components( ).



    LOOP AT lt_comps REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.

        lt_attri = rtti_get_t_attri_by_include( lr_comp->type ).
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

    DATA lt_attri TYPE abap_component_tab.
    DATA temp242 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp242.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp243 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO lr_attri.


      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE z2ui5_cl_util=>rtti_get_type_kind( <component> ).

        WHEN cl_abap_typedescr=>typekind_table.

        WHEN OTHERS.

          CLEAR temp243.
          temp243-n = lr_attri->name.
          temp243-v = <component>.
          INSERT temp243 INTO TABLE result.
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

    DATA temp244 TYPE string.
    DATA lv_where TYPE string.
    DATA lt_groups TYPE string_table.
    DATA lv_group LIKE LINE OF lt_groups.
      DATA lv_len TYPE i.
      DATA lt_conds TYPE string_table.
      DATA ls_filter TYPE ty_s_filter_multi.
      DATA lv_cond LIKE LINE OF lt_conds.
        DATA ls_range TYPE ty_s_range.
        DATA lv_fieldname TYPE string.
    temp244 = val.

    lv_where = c_trim( temp244 ).
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
    DATA temp245 TYPE string.
    DATA lv_cond LIKE temp245.
    DATA lv_rest TYPE string.
    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_like TYPE string.

    CLEAR range.
    CLEAR fieldname.


    temp245 = val.

    lv_cond = temp245.
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

    DATA temp246 TYPE string.
    DATA lv_val LIKE temp246.
    DATA temp247 TYPE string.
    DATA lv_sep LIKE temp247.
    DATA lv_len TYPE i.
    DATA lv_sep_len TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_start TYPE i.
    DATA lv_pos TYPE i.
    DATA lv_in_quote LIKE abap_false.
    DATA lv_in_between LIKE abap_false.
      DATA lv_char TYPE string.
    temp246 = val.

    lv_val = temp246.

    temp247 = sep.

    lv_sep = temp247.

    lv_len = strlen( lv_val ).

    lv_sep_len = strlen( lv_sep ).

    lv_depth = 0.

    lv_start = 0.

    lv_pos = 0.

    lv_in_quote = abap_false.

    lv_in_between = abap_false.

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

      " Track BETWEEN ... AND to avoid splitting at the AND inside BETWEEN
      " Only check when current char is B or b (performance: skip to_upper on every pos)
      IF lv_depth = 0 AND lv_in_between = abap_false
         AND ( lv_char = `B` OR lv_char = `b` )
         AND lv_pos + 8 <= lv_len
         AND to_upper( lv_val+lv_pos(8) ) = `BETWEEN `.
        lv_in_between = abap_true.
        lv_pos = lv_pos + 8.
        CONTINUE.
      ENDIF.

      " The first AND after BETWEEN is the range AND, not a logical AND
      " Only check when current char is space (the ` AND ` pattern starts with space)
      IF lv_in_between = abap_true
         AND lv_char = ` `
         AND lv_pos + 5 <= lv_len
         AND to_upper( lv_val+lv_pos(5) ) = ` AND `.
        lv_in_between = abap_false.
        lv_pos = lv_pos + 5.
        CONTINUE.
      ENDIF.

      IF lv_depth = 0
         AND lv_in_between = abap_false
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

    result = msg_get_internal( val ).
    IF result IS INITIAL AND val2 IS NOT INITIAL.
      result = msg_get_internal( val2 ).
    ENDIF.

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

    DATA temp248 TYPE string.
    CASE val.
      WHEN `E`.
        temp248 = cs_ui5_msg_type-e.
      WHEN `S`.
        temp248 = cs_ui5_msg_type-s.
      WHEN `W`.
        temp248 = cs_ui5_msg_type-w.
      WHEN OTHERS.
        temp248 = cs_ui5_msg_type-i.
    ENDCASE.
    result = temp248.

  ENDMETHOD.

  METHOD rtti_create_tab_by_name.

    DATA struct_desc TYPE REF TO cl_abap_typedescr.
    DATA temp249 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp249.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    struct_desc = cl_abap_structdescr=>describe_by_name( val ).

    temp249 ?= struct_desc.

    data_desc = temp249.

    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.

  METHOD msg_get.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp250 LIKE LINE OF lt_msg.
    DATA temp251 LIKE sy-tabix.
    lt_msg = msg_get_t( val = val val2 = val2 ).


    temp251 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp250.
    sy-tabix = temp251.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp250.

  ENDMETHOD.

  METHOD msg_get_collect.

    DATA temp252 TYPE string_table.
    DATA temp41 TYPE z2ui5_cl_util=>ty_t_msg.
    FIELD-SYMBOLS <r> LIKE LINE OF temp41.
      DATA temp42 LIKE LINE OF temp252.
    CLEAR temp252.

    temp41 = msg_get_t( val = val val2 = val2 ).

    LOOP AT temp41 ASSIGNING <r>.

      temp42 = |- { <r>-text }|.
      INSERT temp42 INTO TABLE temp252.
    ENDLOOP.
    result = concat_lines_of(
      table = temp252
      sep   = cv_char_util_newline ).

  ENDMETHOD.

  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.

  METHOD rtti_get_ddic_type_name.

    DATA temp254 TYPE REF TO cl_abap_elemdescr.
    temp254 ?= type.
    result = substring_after( val = temp254->absolute_name
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
    DATA temp255 TYPE REF TO cl_abap_tabledescr.
    DATA lo_table LIKE temp255.
        DATA temp256 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp256.
        DATA temp257 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp257.
        DATA temp258 TYPE abap_componentdescr.
    DATA temp259 LIKE sy-subrc.
      DATA lo_type_bool TYPE REF TO cl_abap_typedescr.
      DATA temp260 TYPE abap_componentdescr.
      DATA temp43 TYPE REF TO cl_abap_datadescr.
    DATA lo_line_type TYPE REF TO cl_abap_structdescr.
    ASSIGN ir_tab->* TO <tab>.


    temp255 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

    lo_table = temp255.
    TRY.

        temp256 ?= lo_table->get_table_line_type( ).

        lo_struct = temp256.
        lt_comp = lo_struct->get_components( ).
      CATCH cx_root.
        result-check_table_line = abap_true.

        temp257 ?= lo_table->get_table_line_type( ).

        lo_elem = temp257.

        CLEAR temp258.
        temp258-name = `TAB_LINE`.
        temp258-type = lo_elem.
        INSERT temp258 INTO TABLE lt_comp.
    ENDTRY.


    READ TABLE lt_comp WITH KEY name = sel_field_name TRANSPORTING NO FIELDS.
    temp259 = sy-subrc.
    IF add_sel_field = abap_true
        AND NOT temp259 = 0.

      lo_type_bool = cl_abap_typedescr=>describe_by_name( `ABAP_BOOL` ).

      CLEAR temp260.
      temp260-name = sel_field_name.

      temp43 ?= lo_type_bool.
      temp260-type = temp43.
      INSERT temp260 INTO TABLE lt_comp.
    ENDIF.


    lo_line_type = cl_abap_structdescr=>create( lt_comp ).
    result-tabledescr = cl_abap_tabledescr=>create( lo_line_type ).

  ENDMETHOD.

  METHOD msg_get_by_msg.

    DATA temp261 TYPE ty_s_msg.
    DATA ls_msg LIKE temp261.
    CLEAR temp261.
    temp261-id = id.
    temp261-no = no.
    temp261-v1 = v1.
    temp261-v2 = v2.
    temp261-v3 = v3.
    temp261-v4 = v4.

    ls_msg = temp261.
    result = msg_get( ls_msg ).

  ENDMETHOD.

  METHOD c_contains.
    " Note: ABAP CS operator is CASE-INSENSITIVE.
    " JS transpilation must use a case-insensitive comparison
    " (e.g. val.toLowerCase().includes(sub.toLowerCase())).
    DATA temp262 TYPE string.
    DATA temp4 TYPE xsdboolean.
    temp262 = val.

    temp4 = boolc( temp262 CS sub ).
    result = temp4.

  ENDMETHOD.

  METHOD c_starts_with.

    DATA temp263 TYPE string.
    DATA lv_val LIKE temp263.
    DATA temp264 TYPE string.
    DATA lv_prefix LIKE temp264.
    DATA lv_len TYPE i.
    DATA temp5 TYPE xsdboolean.
    temp263 = val.

    lv_val = temp263.

    temp264 = prefix.

    lv_prefix = temp264.

    lv_len = strlen( lv_prefix ).

    IF strlen( lv_val ) < lv_len.
      result = abap_false.
      RETURN.
    ENDIF.


    temp5 = boolc( lv_val(lv_len) = lv_prefix ).
    result = temp5.

  ENDMETHOD.

  METHOD c_ends_with.

    DATA temp265 TYPE string.
    DATA lv_val LIKE temp265.
    DATA temp266 TYPE string.
    DATA lv_suffix LIKE temp266.
    DATA lv_len_suffix TYPE i.
    DATA lv_len_val TYPE i.
    DATA lv_off TYPE i.
    DATA temp6 TYPE xsdboolean.
    temp265 = val.

    lv_val = temp265.

    temp266 = suffix.

    lv_suffix = temp266.

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

    DATA ls_sy TYPE z2ui5_cl_util=>ty_syst.
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

    DATA temp267 TYPE string.
    DATA lv_val LIKE temp267.
    DATA temp268 TYPE string.
    DATA lv_fmt LIKE temp268.
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
    temp267 = val.

    lv_val = temp267.

    temp268 = format.

    lv_fmt = temp268.

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

    DATA temp269 TYPE string.
    DATA lv_fmt LIKE temp269.
    DATA temp270 TYPE string.
    DATA lv_date LIKE temp270.
    DATA lv_year TYPE string.
    DATA lv_month TYPE string.
    DATA lv_day TYPE string.
    temp269 = format.

    lv_fmt = temp269.

    temp270 = val.

    lv_date = temp270.


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
      DATA temp271 LIKE LINE OF lt_msg.
      DATA temp272 LIKE sy-tabix.
      DATA temp273 LIKE LINE OF lt_msg.
      DATA temp274 LIKE sy-tabix.
      DATA temp275 LIKE LINE OF lt_msg.
      DATA temp276 LIKE sy-tabix.
      DATA lt_detail_items TYPE string_table.
      DATA temp277 LIKE LINE OF lt_msg.
      DATA lr_msg LIKE REF TO temp277.
        DATA temp278 LIKE LINE OF lt_detail_items.
      DATA temp279 LIKE LINE OF lt_msg.
      DATA temp280 LIKE sy-tabix.
      DATA temp281 LIKE LINE OF lt_msg.
      DATA temp282 LIKE sy-tabix.
    lt_msg = msg_get_t( val ).

    IF lines( lt_msg ) = 1.


      temp272 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp271.
      sy-tabix = temp272.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-text  = temp271-text.


      temp274 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp273.
      sy-tabix = temp274.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type  = to_lower( ui5_get_msg_type( temp273-type ) ).


      temp276 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp275.
      sy-tabix = temp276.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title = ui5_get_msg_type( temp275-type ).

    ELSEIF lines( lt_msg ) > 1.
      result-text = | { lines( lt_msg ) } Messages found: |.



      LOOP AT lt_msg REFERENCE INTO lr_msg.

        temp278 = |<li>{ lr_msg->text }</li>|.
        INSERT temp278 INTO TABLE lt_detail_items.
      ENDLOOP.
      result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.


      temp280 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp279.
      sy-tabix = temp280.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title   = ui5_get_msg_type( temp279-type ).


      temp282 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp281.
      sy-tabix = temp282.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type    = to_lower( ui5_get_msg_type( temp281-type ) ).

    ELSE.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_serializable.
        DATA temp283 TYPE REF TO if_serializable_object.
        DATA lo_dummy LIKE temp283.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.

        temp283 ?= val.

        lo_dummy = temp283.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD app_get_url.

    DATA lt_param TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp284 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_param = url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.

    CLEAR temp284.
    temp284-n = `app_start`.
    temp284-v = to_lower( classname ).
    INSERT temp284 INTO TABLE lt_param.

    result = |{ origin }{ pathname }?| && url_param_create_url( lt_param ) && hash.

  ENDMETHOD.

  METHOD app_get_url_source_code.

    result = |{ origin }/sap/bc/adt/oo/classes/{ classname }/source/main|.

  ENDMETHOD.

  " ========== String Extras ==========

  METHOD c_pad_left.
    DATA temp285 TYPE string.
    DATA temp44 TYPE string.
    DATA lv_pad LIKE temp44.

    result = val.
    " pad is TYPE c - space value would be trimmed by && (same as c_pad_right fix)

    temp285 = pad.

    IF pad IS INITIAL.
      temp44 = ` `.
    ELSE.
      temp44 = temp285.
    ENDIF.

    lv_pad = temp44.
    WHILE strlen( result ) < len.
      result = lv_pad && result.
    ENDWHILE.

  ENDMETHOD.

  METHOD c_pad_right.
    DATA temp286 TYPE string.
    DATA temp45 TYPE string.
    DATA lv_pad LIKE temp45.

    result = val.
    " pad is TYPE c - a space value IS INITIAL in ABAP and CONV string trims it.
    " Preserve the space explicitly via COND.

    temp286 = pad.

    IF pad IS INITIAL.
      temp45 = ` `.
    ELSE.
      temp45 = temp286.
    ENDIF.

    lv_pad = temp45.
    WHILE strlen( result ) < len.
      result = result && lv_pad.
    ENDWHILE.

  ENDMETHOD.

  METHOD c_truncate.

    DATA temp287 TYPE string.
    DATA lv_val LIKE temp287.
      DATA lv_ellipsis_len TYPE i.
        DATA lv_cut TYPE i.
    temp287 = val.

    lv_val = temp287.
    IF strlen( lv_val ) <= max.
      result = lv_val.
    ELSE.

      lv_ellipsis_len = strlen( ellipsis ).
      IF max > lv_ellipsis_len.

        lv_cut = max - lv_ellipsis_len.
        result = substring( val = lv_val off = 0 len = lv_cut ) && ellipsis.
      ELSE.
        result = substring( val = lv_val off = 0 len = max ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD c_substring_safe.

    DATA temp288 TYPE string.
    DATA lv_val LIKE temp288.
    DATA lv_strlen TYPE i.
    DATA lv_off LIKE off.
    DATA lv_len LIKE len.
    temp288 = val.

    lv_val = temp288.

    lv_strlen = strlen( lv_val ).


    lv_off = off.
    IF lv_off < 0.
      lv_off = 0.
    ENDIF.
    IF lv_off >= lv_strlen.
      result = ``.
      RETURN.
    ENDIF.


    lv_len = len.
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

    DATA temp289 TYPE string.
    DATA lv_val LIKE temp289.
    DATA temp9 TYPE xsdboolean.
    temp289 = val.

    lv_val = temp289.

    temp9 = boolc( c_trim( lv_val ) IS INITIAL ).
    result = temp9.

  ENDMETHOD.

  " ========== Number Formatting ==========

  METHOD conv_number_to_string.

    DATA lv_str TYPE string.
      DATA lv_fmt TYPE string.
      DATA lv_dot_pos TYPE i.
        DATA lv_int_part TYPE string.
        DATA lv_dec_part TYPE string.
        DATA temp290 TYPE string.
      DATA lv_dot TYPE i.
      DATA temp291 TYPE string.
      DATA lv_integer LIKE temp291.
      DATA temp292 TYPE string.
      DATA lv_decimal LIKE temp292.
      DATA lv_negative TYPE string.
      DATA lv_result TYPE string.
      DATA lv_count TYPE i.
      DATA lv_i TYPE i.

    IF decimals >= 0.

      lv_fmt = |{ val }|.

      lv_dot_pos = find( val = lv_fmt sub = `.` ).
      IF lv_dot_pos < 0.
        lv_str = lv_fmt.
        IF decimals > 0.
          lv_str = lv_str && `.` && repeat( val = `0` occ = decimals ).
        ENDIF.
      ELSE.

        lv_int_part = lv_fmt(lv_dot_pos).

        lv_dec_part = substring( val = lv_fmt off = lv_dot_pos + 1 ).
        IF strlen( lv_dec_part ) > decimals.
          lv_dec_part = lv_dec_part(decimals).
        ELSEIF strlen( lv_dec_part ) < decimals.
          lv_dec_part = lv_dec_part && repeat( val = `0` occ = decimals - strlen( lv_dec_part ) ).
        ENDIF.

        IF decimals > 0.
          temp290 = lv_int_part && `.` && lv_dec_part.
        ELSE.
          temp290 = lv_int_part.
        ENDIF.
        lv_str = temp290.
      ENDIF.
    ELSE.
      lv_str = |{ val }|.
    ENDIF.

    IF sep_thousands IS NOT INITIAL.

      lv_dot = find( val = lv_str sub = `.` ).

      IF lv_dot >= 0.
        temp291 = lv_str(lv_dot).
      ELSE.
        temp291 = lv_str.
      ENDIF.

      lv_integer = temp291.

      IF lv_dot >= 0.
        temp292 = substring( val = lv_str off = lv_dot ).
      ELSE.
        CLEAR temp292.
      ENDIF.

      lv_decimal = temp292.

      lv_negative = ``.
      IF strlen( lv_integer ) > 0 AND lv_integer(1) = `-`.
        lv_negative = `-`.
        lv_integer = substring( val = lv_integer off = 1 ).
      ENDIF.

      lv_result = ``.

      lv_count = 0.

      lv_i = strlen( lv_integer ) - 1.
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

    DATA temp293 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_clean TYPE string.
    DATA lv_i TYPE i.
      DATA lv_c TYPE string.
        DATA lv_rest TYPE string.
    DATA lv_dot_count TYPE i.
    temp293 = val.

    lv_val = c_trim( temp293 ).

    " Heuristic: A comma is treated as DECIMAL separator when it is the
    " LAST separator in the string (no further comma or dot follows).
    " Otherwise it is treated as THOUSANDS separator and skipped.
    " Edge case: '1,000' (no dot) is interpreted as 1.000 (decimal), NOT 1000.
    " This matches European number formatting conventions.
    " Normalize: keep only digits, minus, and decimal point

    lv_clean = ``.

    lv_i = 0.
    WHILE lv_i < strlen( lv_val ).

      lv_c = lv_val+lv_i(1).
      IF lv_c >= `0` AND lv_c <= `9`.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `-` AND lv_i = 0.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `.`.
        lv_clean = lv_clean && lv_c.
      ELSEIF lv_c = `,`.
        " Check if comma is decimal separator (last separator in string)

        lv_rest = substring( val = lv_val off = lv_i + 1 ).
        IF lv_rest NA `,` AND lv_rest NA `.`.
          lv_clean = lv_clean && `.`.
        ENDIF.
        " Otherwise it's a thousands separator — skip it
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    " Validate the normalized value explicitly: it needs at least one
    " digit and at most one decimal point (e.g. European format `1.234,56`
    " normalizes to the invalid `1.234.56`). Return 0 for invalid input -
    " the JS transpiler converts such strings leniently instead of raising

    FIND ALL OCCURRENCES OF `.` IN lv_clean MATCH COUNT lv_dot_count.
    IF lv_dot_count > 1 OR lv_clean NA `0123456789`.
      result = 0.
      RETURN.
    ENDIF.

    TRY.
        result = lv_clean.
      CATCH cx_root.
        result = 0.
    ENDTRY.

  ENDMETHOD.

  " ========== i18n / Text Resolution ==========

  " ========== Itab Extras ==========

  METHOD itab_sort_by.

    " SORT itab BY (dynamic) is not supported by the JS transpiler used
    " for the Node unit tests - extract the sort key per row into a
    " helper table, sort that statically and rebuild the table
    TYPES: BEGIN OF ty_s_sort_key,
             key_str TYPE string,
             key_num TYPE decfloat34,
             idx     TYPE i,
           END OF ty_s_sort_key.
    TYPES temp4 TYPE STANDARD TABLE OF ty_s_sort_key WITH DEFAULT KEY.
DATA lt_key TYPE temp4.
    DATA lv_numeric TYPE abap_bool.

    DATA lv_field TYPE string.
    FIELD-SYMBOLS <row> TYPE ANY.
      DATA lv_tabix LIKE sy-tabix.
      FIELD-SYMBOLS <val> TYPE any.
      FIELD-SYMBOLS <key> LIKE LINE OF lt_key.
    DATA lr_copy TYPE REF TO data.
    FIELD-SYMBOLS <tab_copy> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <src> TYPE any.
    lv_field = to_upper( fieldname ).


    LOOP AT tab ASSIGNING <row>.

      lv_tabix = sy-tabix.

      ASSIGN COMPONENT lv_field OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      IF lv_tabix = 1.
        lv_numeric = rtti_check_numeric( <val> ).
      ENDIF.

      APPEND INITIAL LINE TO lt_key ASSIGNING <key>.
      IF lv_numeric = abap_true.
        <key>-key_num = <val>.
      ELSE.
        <key>-key_str = <val>.
      ENDIF.
      <key>-idx = lv_tabix.
    ENDLOOP.

    IF descending = abap_true.
      SORT lt_key BY key_num DESCENDING key_str DESCENDING.
    ELSE.
      SORT lt_key BY key_num ASCENDING key_str ASCENDING.
    ENDIF.


    CREATE DATA lr_copy LIKE tab.

    ASSIGN lr_copy->* TO <tab_copy>.
    <tab_copy> = tab.

    CLEAR tab.
    LOOP AT lt_key ASSIGNING <key>.

      READ TABLE <tab_copy> INDEX <key>-idx ASSIGNING <src>.
      IF sy-subrc = 0.
        APPEND <src> TO tab.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_slice.

    " Create a copy of the source table (same type) and return the slice.
    DATA temp294 TYPE REF TO cl_abap_tabledescr.
    DATA lo_tabledescr LIKE temp294.
    FIELD-SYMBOLS <result> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA lv_lines TYPE i.
    DATA temp295 TYPE i.
    DATA lv_to LIKE temp295.
    DATA temp296 TYPE i.
    DATA lv_from LIKE temp296.
    temp294 ?= cl_abap_typedescr=>describe_by_data( tab ).

    lo_tabledescr = temp294.
    CREATE DATA result TYPE HANDLE lo_tabledescr.



    ASSIGN result->* TO <result>.


    lv_lines = lines( tab ).

    IF to <= 0 OR to > lv_lines.
      temp295 = lv_lines.
    ELSE.
      temp295 = to.
    ENDIF.

    lv_to = temp295.

    IF from < 1.
      temp296 = 1.
    ELSE.
      temp296 = from.
    ENDIF.

    lv_from = temp296.

    LOOP AT tab ASSIGNING <row> FROM lv_from TO lv_to.
      INSERT <row> INTO TABLE <result>.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_paginate.
    DATA temp297 TYPE i.
    DATA lv_from TYPE i.
    DATA lv_to TYPE i.

    total_count = lines( tab ).

    IF page_size <= 0.
      temp297 = 1.
    ELSE.
      temp297 = ( total_count + page_size - 1 ) / page_size.
    ENDIF.
    total_pages = temp297.


    lv_from = ( page - 1 ) * page_size + 1.

    lv_to   = page * page_size.

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
      DATA lv_val TYPE string.
      FIELD-SYMBOLS <entry> TYPE z2ui5_cl_util=>ty_s_name_value.
        DATA temp298 TYPE i.
        DATA lv_count TYPE i.
        DATA temp299 TYPE z2ui5_cl_util=>ty_s_name_value.

    LOOP AT tab ASSIGNING <row>.
      ASSIGN COMPONENT fieldname OF STRUCTURE <row> TO <field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lv_val = |{ <field> }|.

      READ TABLE result ASSIGNING <entry> WITH KEY n = lv_val.
      IF sy-subrc = 0.

        temp298 = <entry>-v.

        lv_count = temp298 + 1.
        <entry>-v = |{ lv_count }|.
      ELSE.

        CLEAR temp299.
        temp299-n = lv_val.
        temp299-v = `1`.
        INSERT temp299 INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  " ========== Validation Helpers ==========

  METHOD check_is_email.

    DATA temp300 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_local TYPE string.
    DATA lv_domain TYPE string.
    DATA lv_extra TYPE string.
    temp300 = val.

    lv_val = c_trim( temp300 ).

    IF lv_val IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    " Basic email validation: contains exactly one @, has text before and after,
    " domain part contains at least one dot



    SPLIT lv_val AT `@` INTO lv_local lv_domain lv_extra.
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

    DATA temp301 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_i TYPE i.
    DATA lv_has_dot LIKE abap_false.
      DATA lv_c TYPE string.
    temp301 = val.

    lv_val = c_trim( temp301 ).

    IF lv_val IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.


    lv_i = 0.

    lv_has_dot = abap_false.
    WHILE lv_i < strlen( lv_val ).

      lv_c = lv_val+lv_i(1).
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
        DATA lv_date TYPE d.
        DATA temp302 TYPE string.
        DATA lv_check LIKE temp302.
        DATA temp10 TYPE xsdboolean.

    TRY.

        lv_date = conv_string_to_date( val = val format = format ).
        " Check the date is actually valid (not 00000000 and not invalid like Feb 30)
        IF lv_date IS INITIAL.
          result = abap_false.
          RETURN.
        ENDIF.
        " ABAP validates dates on assignment — if it passed conv_string_to_date it's valid

        temp302 = lv_date.

        lv_check = temp302.

        temp10 = boolc( lv_check <> `00000000` ).
        result = temp10.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD check_is_guid.

    DATA temp303 TYPE string.
    DATA lv_val TYPE string.
    DATA lv_clean TYPE string.
    DATA lv_len TYPE i.
    DATA lv_upper TYPE string.
    DATA lv_i TYPE i.
      DATA lv_c TYPE string.
    temp303 = val.

    lv_val = c_trim( temp303 ).

    lv_clean = c_replace_all( val = lv_val sub = `-` new_val = `` ).

    lv_len = strlen( lv_clean ).

    " Accept 32 chars (raw) or 36 chars (with dashes)
    IF lv_len <> 32.
      result = abap_false.
      RETURN.
    ENDIF.

    " All characters must be hex digits

    lv_upper = to_upper( lv_clean ).

    lv_i = 0.
    WHILE lv_i < 32.

      lv_c = lv_upper+lv_i(1).
      IF NOT ( ( lv_c >= `0` AND lv_c <= `9` ) OR ( lv_c >= `A` AND lv_c <= `F` ) ).
        result = abap_false.
        RETURN.
      ENDIF.
      lv_i = lv_i + 1.
    ENDWHILE.

    result = abap_true.

  ENDMETHOD.

  METHOD check_max_length.

    DATA temp304 TYPE string.
    DATA lv_val LIKE temp304.
    DATA temp11 TYPE xsdboolean.
    temp304 = val.

    lv_val = temp304.

    temp11 = boolc( strlen( lv_val ) <= max ).
    result = temp11.

  ENDMETHOD.

  " ========== Deep Comparison ==========

  METHOD data_equals.
        DATA temp12 TYPE xsdboolean.

    TRY.

        temp12 = boolc( a = b ).
        result = temp12.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD data_diff.

    FIELD-SYMBOLS <old_field> TYPE any.
    FIELD-SYMBOLS <new_field> TYPE any.

    DATA lt_comps TYPE abap_component_tab.
    DATA temp305 LIKE LINE OF lt_comps.
    DATA lr_comp LIKE REF TO temp305.
        DATA temp306 TYPE z2ui5_cl_util=>ty_s_field_diff.
    lt_comps = rtti_get_t_attri_by_any( old ).



    LOOP AT lt_comps REFERENCE INTO lr_comp.
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE old TO <old_field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE new TO <new_field>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF <old_field> <> <new_field>.

        CLEAR temp306.
        temp306-fieldname = lr_comp->name.
        temp306-old_value = |{ <old_field> }|.
        temp306-new_value = |{ <new_field> }|.
        INSERT temp306 INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  " ========== Stopwatch ==========

  METHOD time_measure_start.

    GET TIME STAMP FIELD result.

  ENDMETHOD.

  METHOD time_measure_stop.

    DATA lv_now TYPE timestampl.
    DATA lv_diff TYPE i.
    lv_now = time_get_timestampl( ).

    lv_diff = cl_abap_tstmp=>subtract( tstmp1 = lv_now
                                              tstmp2 = start_time ).
    result = lv_diff * 1000.  " convert seconds to milliseconds

  ENDMETHOD.

  " ========== Authorization Check ==========

  " ========== Enum/Domain Helpers ==========

  METHOD enum_to_text.

    DATA lt_all TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp307 TYPE string.
    DATA lv_val LIKE temp307.
    DATA temp308 TYPE string.
    DATA temp309 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_all = enum_get_all( domain = domain langu = langu ).

    temp307 = value.

    lv_val = temp307.

    CLEAR temp308.

    READ TABLE lt_all INTO temp309 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp308 = temp309-v.
    ENDIF.
    result = temp308.

  ENDMETHOD.

  METHOD enum_get_all.
        DATA temp310 TYPE string.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp311 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp311.
        DATA lt_fix TYPE z2ui5_cl_util=>ty_t_fix_val.
        DATA ls_fix LIKE LINE OF lt_fix.
          DATA temp312 TYPE z2ui5_cl_util=>ty_s_name_value.

    TRY.

        temp310 = domain.

        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp310
                                             RECEIVING  p_descr_ref    = lo_type
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        temp311 ?= lo_type.

        lo_elem = temp311.

        lt_fix = rtti_get_t_fixvalues( elemdescr = lo_elem
                                              langu     = langu ).


        LOOP AT lt_fix INTO ls_fix.

          CLEAR temp312.
          temp312-n = ls_fix-low.
          temp312-v = ls_fix-descr.
          INSERT temp312 INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  " ========== Deep Field Access ==========

  METHOD data_get_by_path.

    FIELD-SYMBOLS <current> TYPE any.
    FIELD-SYMBOLS <field>   TYPE any.
    TYPES temp5 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_segments TYPE temp5.
    DATA lv_segment LIKE LINE OF lt_segments.
      DATA lv_seg TYPE string.

    ASSIGN data TO <current>.



    SPLIT path AT `-` INTO TABLE lt_segments.


    LOOP AT lt_segments INTO lv_segment.

      lv_seg = c_trim_upper( lv_segment ).
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
    TYPES temp6 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_segments TYPE temp6.
    DATA lv_last_idx TYPE i.
    DATA lv_segment LIKE LINE OF lt_segments.
      DATA lv_seg TYPE string.

    ASSIGN data TO <current>.



    SPLIT path AT `-` INTO TABLE lt_segments.

    lv_last_idx = lines( lt_segments ).


    LOOP AT lt_segments INTO lv_segment.

      lv_seg = c_trim_upper( lv_segment ).
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

  " ========== Transport Extensions ==========

  " ========== Lock Extensions ==========

  " ========== Number Range ==========

  " ========== Change Documents ==========

  " ========== Background Job ==========

  " ========== Email ==========

  METHOD context_get_user_tech.
        DATA temp313 TYPE string.
        DATA lv_result LIKE temp313.
        DATA lv_class TYPE string.
        DATA x TYPE REF TO cx_root.

    TRY.


        CLEAR temp313.

        lv_result = temp313.

        lv_class = `CL_ABAP_CONTEXT_INFO`.

        IF context_check_abap_cloud( ) IS NOT INITIAL.
          CALL METHOD (lv_class)=>(`GET_USER_TECHNICAL_NAME`)
            RECEIVING
              rv_technical_name = lv_result.
        ELSE.
          CALL METHOD (lv_class)=>(`GET_USER_BUSINESS_PARTNER_ID`)
            RECEIVING
              rv_business_partner_id = lv_result.
        ENDIF.

        result = lv_result.


      CATCH cx_root INTO x.
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

  METHOD rtti_get_classes_impl_intf.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    TYPES BEGIN OF ty_s_impl.
    TYPES   clsname    TYPE c LENGTH 30.
    TYPES   refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    TYPES temp7 TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
DATA lt_impl TYPE temp7.
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
      DATA lv_fm TYPE string.

    IF context_check_abap_cloud( ) IS NOT INITIAL.

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
            DATA lv_xco_cp_abap_dictionary TYPE string.
            DATA x TYPE REF TO cx_root.
            DATA error TYPE string.

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


          CATCH cx_root INTO x.

            error = x->get_text( ).
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
        DATA obj TYPE REF TO object.
        DATA content TYPE REF TO object.
        DATA lv_classname TYPE c LENGTH 30.
        DATA xco_cp_abap TYPE c LENGTH 11.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.
    TRY.






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


      CATCH cx_root INTO x.

        lv_error = x->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_table_desrc.

    DATA ddtext TYPE c LENGTH 60.
      DATA lan LIKE sy-langu.
      DATA lv_tabname TYPE string.

    IF langu IS NOT SUPPLIED.

      lan = sy-langu.
    ELSE.
      lan = langu.
    ENDIF.

    IF context_check_abap_cloud( ) IS NOT INITIAL.

      ddtext = tabname.

    ELSE.


      lv_tabname = `dd02t`.
      SELECT SINGLE ddtext
        FROM (lv_tabname) INTO ddtext
        WHERE tabname    = tabname
          AND ddlanguage = lan
        .

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
      DATA lv_assign TYPE string.
      DATA r TYPE REF TO data.
      FIELD-SYMBOLS <lt_lines> TYPE string_table.
      DATA text LIKE LINE OF <lt_lines>.
        DATA temp314 TYPE ty_s_stack.
        DATA ls_stack LIKE temp314.

    IF context_check_abap_cloud( ) IS NOT INITIAL.
















      "1 format source

      lv_assign = `XCO_CP_CALL_STACK=>LINE_NUMBER_FLAVOR->SOURCE`.
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


      ASSIGN ro_lines->(`IF_XCO_STRINGS~VALUE`) TO <lt_lines>.


      LOOP AT <lt_lines> INTO text.

        CLEAR temp314.

        ls_stack = temp314.
        SPLIT text AT ` ` INTO ls_stack-class ls_stack-include ls_stack-method.
        INSERT ls_stack INTO TABLE result.
      ENDLOOP.

      DELETE result INDEX 1.

    ENDIF.

  ENDMETHOD.

  METHOD context_get_sy.

    MOVE-CORRESPONDING sy TO result.

  ENDMETHOD.


  METHOD msg_get_text.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
      DATA temp315 LIKE LINE OF lt_msg.
      DATA temp316 LIKE sy-tabix.
    lt_msg = msg_get_t( val = val val2 = val2 ).
    IF lt_msg IS NOT INITIAL.


      temp316 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp315.
      sy-tabix = temp316.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result = temp315-text.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_by_sy.

    result = msg_get_t( context_get_sy( ) ).

  ENDMETHOD.

  METHOD msg_get_internal.

    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        FIELD-SYMBOLS <row> TYPE ANY.
          DATA lt_tab TYPE z2ui5_cl_util=>ty_t_msg.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp317 TYPE ty_s_msg.
        DATA ls_result LIKE temp317.
        DATA temp318 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp318.
          FIELD-SYMBOLS <comp> TYPE any.
          DATA temp319 TYPE z2ui5_cl_util=>ty_s_msg.
    lv_kind = rtti_get_type_kind( val ).
    CASE lv_kind.

      WHEN cl_abap_datadescr=>typekind_table.

        ASSIGN val TO <tab>.

        LOOP AT <tab> ASSIGNING <row>.

          lt_tab = msg_get_internal( <row> ).
          INSERT LINES OF lt_tab INTO TABLE result.
        ENDLOOP.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        IF check_is_rap_struct( val ) = abap_true.
          result = msg_get_rap( val ).
          RETURN.
        ENDIF.


        lt_attri = rtti_get_t_attri_by_any( val ).


        CLEAR temp317.

        ls_result = temp317.


        LOOP AT lt_attri REFERENCE INTO ls_attri.

          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          IF ls_attri->name = `ITEM`.
            lt_tab = msg_get_internal( <comp> ).
            INSERT LINES OF lt_tab INTO TABLE result.
            RETURN.
          ELSE.
            ls_result = msg_map( name = ls_attri->name val = <comp> is_msg = ls_result ).
          ENDIF.

        ENDLOOP.
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL.
          ls_result-id = to_upper( ls_result-id ).
          MESSAGE ID ls_result-id TYPE `I` NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        result = msg_get_by_oref( val ).

      WHEN OTHERS.

        IF rtti_check_clike( val ) IS NOT INITIAL.

          CLEAR temp319.
          temp319-text = val.
          INSERT temp319 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get_by_oref.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA temp320 TYPE REF TO cx_root.
        DATA lx LIKE temp320.
        DATA temp321 TYPE ty_s_msg.
        DATA ls_result LIKE temp321.
        DATA lt_attri_o TYPE abap_attrdescr_tab.
        DATA temp322 LIKE LINE OF lt_attri_o.
        DATA ls_attri_o LIKE REF TO temp322.
          DATA lv_name LIKE ls_attri_o->name.
        DATA obj TYPE REF TO object.
            DATA lr_tab TYPE REF TO data.
            FIELD-SYMBOLS <tab2> TYPE data.
            DATA lt_tab2 TYPE z2ui5_cl_util=>ty_t_msg.

    TRY.

        temp320 ?= val.

        lx = temp320.

        CLEAR temp321.
        temp321-type = `E`.
        temp321-text = lx->get_text( ).

        ls_result = temp321.

        lt_attri_o = rtti_get_t_attri_by_oref( val ).


        LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
             WHERE visibility = `U`.

          lv_name = ls_attri_o->name.
          ASSIGN lx->(lv_name) TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
        ENDLOOP.
        INSERT ls_result INTO TABLE result.
      CATCH cx_root.


        obj = val.

        TRY.


            CREATE DATA lr_tab TYPE (`if_bali_log=>ty_item_table`).

            ASSIGN lr_tab->* TO <tab2>.

            CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
              RECEIVING
                item_table = <tab2>.


            lt_tab2 = msg_get_internal( <tab2> ).
            INSERT LINES OF lt_tab2 INTO TABLE result.

          CATCH cx_root.

            TRY.

                CREATE DATA lr_tab TYPE (`BAPIRETTAB`).
                ASSIGN lr_tab->* TO <tab2>.

                CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
                  RECEIVING
                    rt_bapiret = <tab2>.

                lt_tab2 = msg_get_internal( <tab2> ).
                INSERT LINES OF lt_tab2 INTO TABLE result.

              CATCH cx_root.

                lt_attri_o = rtti_get_t_attri_by_oref( val ).
                LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                     WHERE visibility = `U`.
                  lv_name = ls_attri_o->name.
                  ASSIGN obj->(lv_name) TO <comp>.
                  IF sy-subrc <> 0.
                    CONTINUE.
                  ENDIF.
                  ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
                ENDLOOP.
                INSERT ls_result INTO TABLE result.

            ENDTRY.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD msg_map.

    result = is_msg.
    CASE name.
      WHEN `ID` OR `MSGID`.
        result-id = val.
      WHEN `NO` OR `NUMBER` OR `MSGNO`.
        result-no = val.
      WHEN `MESSAGE` OR `TEXT`.
        result-text = val.
      WHEN `TYPE` OR `MSGTY` OR `M_SEVERITY`.
        result-type = val.
      WHEN `MESSAGE_V1` OR `MSGV1` OR `V1`.
        result-v1 = val.
      WHEN `MESSAGE_V2` OR `MSGV2` OR `V2`.
        result-v2 = val.
      WHEN `MESSAGE_V3` OR `MSGV3` OR `V3`.
        result-v3 = val.
      WHEN `MESSAGE_V4` OR `MSGV4` OR `V4`.
        result-v4 = val.
      WHEN `TIME_STMP`.
        result-timestampl = val.
    ENDCASE.

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp323 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp323.
      FIELD-SYMBOLS <tab> TYPE any.
          DATA temp324 TYPE REF TO cl_abap_tabledescr.
          DATA lo_tab LIKE temp324.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp325 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp326 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp326.
    lt_attri = rtti_get_t_attri_by_any( val ).



    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CASE ls_attri->name.
        WHEN `%MSG` OR `%FAIL` OR `%OTHER`.
          result = abap_true.
          RETURN.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      TRY.

          temp324 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

          lo_tab = temp324.

          lo_line = lo_tab->get_table_line_type( ).
          CHECK lo_line->kind = cl_abap_typedescr=>kind_struct.

          temp325 ?= lo_line.

          lt_comps = temp325->get_components( ).


          LOOP AT lt_comps REFERENCE INTO ls_comp.
            IF ls_comp->name = `%MSG` OR ls_comp->name = `%FAIL`.
              result = abap_true.
              RETURN.
            ENDIF.
          ENDLOOP.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap.

    DATA lv_kind TYPE string.
    DATA lv_is_row TYPE abap_bool.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp327 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp327.
      FIELD-SYMBOLS <tab> TYPE any.
      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      FIELD-SYMBOLS <row> TYPE ANY.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    msg_get_rap_row( EXPORTING val         = val
                               entity_name = entity_name
                     IMPORTING messages    = result
                               is_row      = lv_is_row ).
    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.


      ASSIGN <tab> TO <ftab>.


      LOOP AT <ftab> ASSIGNING <row>.
        IF rtti_get_type_kind( <row> ) = cl_abap_datadescr=>typekind_oref.
          IF <row> IS NOT INITIAL.
            TRY.
                INSERT LINES OF msg_get_t( <row> ) INTO TABLE result.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
        ELSE.
          INSERT LINES OF msg_get_rap( val         = <row>
                                       entity_name = ls_attri->name ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_row.
    DATA lt_meta TYPE z2ui5_cl_util=>ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE z2ui5_cl_util=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp328 TYPE z2ui5_cl_util=>ty_s_msg.

    CLEAR messages.
    is_row = abap_false.


    lt_meta = msg_get_rap_meta( val ).


    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO <msg>.
    IF sy-subrc = 0.
      is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        TRY.

            lt_one = msg_get_t( <msg> ).

            LOOP AT lt_one ASSIGNING <m>.
              <m>-t_meta = lt_meta.
            ENDLOOP.
            INSERT LINES OF lt_one INTO TABLE messages.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO <fail>.
    IF sy-subrc = 0.
      is_row = abap_true.

      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
      IF sy-subrc = 0.

        lv_cause = <cause>.

        lv_text = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.

        CLEAR temp328.
        temp328-type = `E`.
        temp328-text = lv_text.
        temp328-t_meta = lt_meta.
        INSERT temp328 INTO TABLE messages.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_element.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp329 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp329.
      FIELD-SYMBOLS <flag> TYPE any.
    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CHECK strlen( ls_attri->name ) > 9.
      CHECK ls_attri->name(9) = `%ELEMENT-`.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <flag>.
      CHECK sy-subrc = 0.
      CHECK <flag> IS NOT INITIAL.

      IF result IS INITIAL.
        result = ls_attri->name+9.
      ELSE.
        result = |{ result }, { ls_attri->name+9 }|.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_state_area.

    FIELD-SYMBOLS <sa> TYPE any.
    ASSIGN COMPONENT `%STATE_AREA` OF STRUCTURE val TO <sa>.
    IF sy-subrc = 0.
      result = <sa>.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_action.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp330 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp330.
      FIELD-SYMBOLS <flag> TYPE any.
    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CHECK strlen( ls_attri->name ) > 12.
      CHECK ls_attri->name(12) = `%OP-%ACTION-`.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <flag>.
      CHECK sy-subrc = 0.
      CHECK <flag> IS NOT INITIAL.
      result = ls_attri->name+12.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_pid.

    FIELD-SYMBOLS <pid> TYPE any.
    ASSIGN COMPONENT `%PID` OF STRUCTURE val TO <pid>.
    IF sy-subrc = 0.
      result = <pid>.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_cid.

    FIELD-SYMBOLS <cid> TYPE any.
    ASSIGN COMPONENT `%CID` OF STRUCTURE val TO <cid>.
    IF sy-subrc = 0.
      result = <cid>.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_tky.

    FIELD-SYMBOLS <tky> TYPE any.
    ASSIGN COMPONENT `%TKY` OF STRUCTURE val TO <tky>.
    IF sy-subrc <> 0 OR <tky> IS INITIAL.
      RETURN.
    ENDIF.
    result = msg_get_rap_flatten( <tky> ).

  ENDMETHOD.

  METHOD msg_get_rap_flatten.

    DATA lv_kind TYPE string.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp331 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp331.
      FIELD-SYMBOLS <comp> TYPE any.
      DATA lv_sub_kind TYPE string.
        DATA lv_sub TYPE string.
            DATA lv_str TYPE string.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
      CHECK sy-subrc = 0.


      lv_sub_kind = rtti_get_type_kind( <comp> ).
      IF lv_sub_kind = cl_abap_datadescr=>typekind_struct1
         OR lv_sub_kind = cl_abap_datadescr=>typekind_struct2.

        lv_sub = msg_get_rap_flatten( <comp> ).
        IF lv_sub IS NOT INITIAL.
          IF result IS NOT INITIAL.
            result = |{ result }, |.
          ENDIF.
          result = |{ result }{ lv_sub }|.
        ENDIF.
      ELSEIF <comp> IS NOT INITIAL.
        TRY.

            lv_str = <comp>.
            IF result IS NOT INITIAL.
              result = |{ result }, |.
            ENDIF.
            result = |{ result }{ ls_attri->name }={ lv_str }|.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_meta.

    DATA lv TYPE string.
      DATA temp332 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp333 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp334 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp335 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp336 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp337 TYPE z2ui5_cl_util=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp332.
      temp332-n = `element`.
      temp332-v = lv.
      INSERT temp332 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp333.
      temp333-n = `state_area`.
      temp333-v = lv.
      INSERT temp333 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp334.
      temp334-n = `action`.
      temp334-v = lv.
      INSERT temp334 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp335.
      temp335-n = `pid`.
      temp335-v = lv.
      INSERT temp335 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp336.
      temp336-n = `cid`.
      temp336-v = lv.
      INSERT temp336 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp337.
      temp337-n = `tky`.
      temp337-v = lv.
      INSERT temp337 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.

    DATA temp338 TYPE string.
    CASE cause.
      WHEN 0.
        temp338 = `Operation failed`.
      WHEN 1.
        temp338 = `Entity not found`.
      WHEN 2.
        temp338 = `Entity is locked`.
      WHEN 3.
        temp338 = `Authorization failure`.
      WHEN 4.
        temp338 = `Concurrent modification`.
      WHEN 5.
        temp338 = `Concurrent modification`.
      WHEN 6.
        temp338 = `Operation disabled`.
      WHEN 7.
        temp338 = `Operation forbidden`.
      WHEN 8.
        temp338 = `Semantic error`.
      WHEN 9.
        temp338 = `Determination failed`.
      WHEN 10.
        temp338 = `Permission denied`.
      WHEN 11.
        temp338 = `Validation failed`.
      WHEN OTHERS.
        temp338 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp338.

  ENDMETHOD.

ENDCLASS.
