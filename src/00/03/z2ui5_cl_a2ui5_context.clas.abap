CLASS z2ui5_cl_a2ui5_context DEFINITION
  PUBLIC FINAL
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
    " these from z2ui5_cl_a2ui5_context instead of referencing cl_abap_char_utilities /
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

    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH DEFAULT KEY ##NEEDED.

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
        !val          TYPE any
        !val2         TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS rtti_get_data_element_text_l
      IMPORTING
        !val          TYPE any
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
        !val          TYPE any
        !val2         TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
      RETURNING
        VALUE(result) TYPE abap_component_tab.

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

    CLASS-METHODS rtti_check_class_exists
      IMPORTING
        val           TYPE clike
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
        VALUE(result) TYPE ty_t_name_value.

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

    CLASS-METHODS rtti_check_clike
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

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

    CLASS-METHODS app_get_url
      IMPORTING
        !classname    TYPE clike
        !origin       TYPE clike
        !pathname     TYPE clike
        !search       TYPE clike
        !hash         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

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

    CLASS-METHODS context_check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS uuid_get_c32
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

  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        i_classname   TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_bool_cache,
        typedescr TYPE REF TO cl_abap_typedescr,
        is_bool   TYPE abap_bool,
      END OF ty_s_bool_cache.

    CLASS-DATA mt_bool_cache TYPE HASHED TABLE OF ty_s_bool_cache WITH UNIQUE KEY typedescr.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    CLASS-DATA gv_check_cloud TYPE abap_bool.

    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

    CLASS-METHODS rtti_get_classes_intf_cloud
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_classes.

    CLASS-METHODS rtti_get_classes_intf_std
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_classes.

    CLASS-METHODS rtti_get_dtel_texts_by_ddic
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.

    CLASS-METHODS rtti_get_dtel_texts_by_xco
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.


    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        is_msg        TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

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

ENDCLASS.


CLASS z2ui5_cl_a2ui5_context IMPLEMENTATION.

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
      DATA temp1 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.

      IF val = abap_true.
        temp1 = `true`.
      ELSE.
        temp1 = `false`.
      ENDIF.
      result = temp1.
    ELSE.
      result = val.
    ENDIF.

*    result = COND #(
*      WHEN val = abap_true THEN `true`
*      WHEN val = abap_false THEN ``
*      ELSE val ).

  ENDMETHOD.

  METHOD boolean_check_by_data.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA lr_cache TYPE REF TO z2ui5_cl_a2ui5_context=>ty_s_bool_cache.
        DATA temp2 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp2.
        DATA temp3 TYPE z2ui5_cl_a2ui5_context=>ty_s_bool_cache.

    TRY.

        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        " all supported boolean types are character-like flags, this check
        " filters out every other type before the cache lookup
        IF lo_descr->type_kind <> cl_abap_typedescr=>typekind_char.
          RETURN.
        ENDIF.

        " type descriptors are singletons, so the reference identifies the
        " type without converting/hashing the absolute name on every call

        READ TABLE mt_bool_cache REFERENCE INTO lr_cache
             WITH TABLE KEY typedescr = lo_descr.
        IF sy-subrc = 0.
          result = lr_cache->is_bool.
          RETURN.
        ENDIF.


        temp2 ?= lo_descr.

        lo_ele = temp2.
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).


        CLEAR temp3.
        temp3-typedescr = lo_descr.
        temp3-is_bool = result.
        INSERT temp3 INTO TABLE mt_bool_cache.

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
      IF <from> IS NOT ASSIGNED.
        " unbound data reference - nothing to copy, return an initial reference
        RETURN.
      ENDIF.
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

    DATA temp4 TYPE string.
    temp4 = val.
    result = shift_left( shift_right( temp4 ) ).
    result = shift_right( val = result
                          sub = cv_char_util_horizontal_tab ).
    result = shift_left( val = result
                         sub = cv_char_util_horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.

  METHOD c_trim_lower.

    DATA temp5 TYPE string.
    temp5 = val.
    result = to_lower( c_trim( temp5 ) ).

  ENDMETHOD.

  METHOD c_trim_upper.

    DATA temp6 TYPE string.
    temp6 = val.
    result = to_upper( c_trim( temp6 ) ).

  ENDMETHOD.

  METHOD filter_get_token_range_mapping.

    DATA temp7 TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.
    DATA temp8 LIKE LINE OF temp7.
    CLEAR temp7.

    temp8-n = `EQ`.
    temp8-v = `={LOW}`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `LT`.
    temp8-v = `<{LOW}`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `LE`.
    temp8-v = `<={LOW}`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `GT`.
    temp8-v = `>{LOW}`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `GE`.
    temp8-v = `>={LOW}`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `CP`.
    temp8-v = `*{LOW}*`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `BT`.
    temp8-v = `{LOW}...{HIGH}`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `NB`.
    temp8-v = `!({LOW}...{HIGH})`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `NE`.
    temp8-v = `!(={LOW})`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `NP`.
    temp8-v = `!(*{LOW}*)`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `!<leer>`.
    temp8-v = `!(<leer>)`.
    INSERT temp8 INTO TABLE temp7.
    temp8-n = `<leer>`.
    temp8-v = `<leer>`.
    INSERT temp8 INTO TABLE temp7.
    result = temp7.

  ENDMETHOD.

  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.
    DATA temp9 TYPE ty_t_range.
    DATA lt_tab LIKE temp9.
    DATA temp10 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp10.
      DATA lv_value TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value-v.
      DATA temp1 LIKE LINE OF lt_mapping.
      DATA temp2 LIKE sy-tabix.
      DATA temp11 TYPE z2ui5_cl_a2ui5_context=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).


    CLEAR temp9.

    lt_tab = temp9.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab ).



    LOOP AT lt_tab REFERENCE INTO lr_row.




      temp2 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option INTO temp1.
      sy-tabix = temp2.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = temp1-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.


      CLEAR temp11.
      temp11-key = lv_value.
      temp11-text = lv_value.
      temp11-visible = abap_true.
      temp11-editable = abap_true.
      INSERT temp11 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_val.
    " TRANSPILER NOTE: ABAP CS operator is ALWAYS case-insensitive regardless
    " of the ignore_case flag. The flag only pre-converts to uppercase for
    " consistency, but CS itself never does case-sensitive matching.
    " JS equivalent: always use toLowerCase().includes(toLowerCase()).
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    DATA temp12 TYPE string.
    DATA lv_search LIKE temp12.
    DATA lv_field_count TYPE i.
      DATA lv_tabix LIKE sy-tabix.
      DATA lv_check_found LIKE abap_false.
      DATA lv_index TYPE i.
          DATA lv_name LIKE LINE OF fields.
          DATA temp3 LIKE LINE OF fields.
          DATA temp4 LIKE sy-tabix.
        DATA lv_value TYPE string.
    IF ignore_case = abap_true.
      temp12 = to_upper( val ).
    ELSE.
      temp12 = val.
    ENDIF.

    lv_search = temp12.

    lv_field_count = lines( fields ).

    LOOP AT tab ASSIGNING <row>.


      lv_tabix = sy-tabix.

      lv_check_found = abap_false.

      lv_index = 1.
      DO.
        IF fields IS INITIAL.
          ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
        ELSE.
          IF lv_index > lv_field_count.
            EXIT.
          ENDIF.



          temp4 = sy-tabix.
          READ TABLE fields INDEX lv_index INTO temp3.
          sy-tabix = temp4.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lv_name = temp3.
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
        ELSEIF find( val = lv_value
                     sub = lv_search ) >= 0.
          " Case-sensitive: use find() because CS is always case-insensitive
          lv_check_found = abap_true.
          EXIT.
        ENDIF.

        lv_index = lv_index + 1.
      ENDDO.

      IF lv_check_found = abap_false.
        DELETE tab INDEX lv_tabix.
      ENDIF.

    ENDLOOP.

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
        DATA temp13 TYPE REF TO cl_abap_refdescr.
        DATA lo_ref LIKE temp13.

    TRY.

        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).

        temp13 ?= lo_typdescr.

        lo_ref = temp13.
        result = abap_true.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_classname_by_ref.

    DATA lv_classname TYPE abap_abstypename.
    lv_classname = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.

  METHOD rtti_get_intfname_by_ref.

    DATA rtti TYPE REF TO cl_abap_typedescr.
    DATA temp14 TYPE REF TO cl_abap_refdescr.
    DATA ref LIKE temp14.
    DATA name TYPE abap_abstypename.
    rtti = cl_abap_typedescr=>describe_by_data( in ).

    temp14 ?= rtti.

    ref = temp14.

    name = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.
        DATA type_desc TYPE REF TO cl_abap_typedescr.
        DATA x TYPE REF TO cx_root.
    DATA temp15 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp15.
    DATA comps TYPE abap_component_tab.
    DATA temp16 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp16.
        DATA incl_comps TYPE abap_component_tab.
        DATA temp17 LIKE LINE OF incl_comps.
        DATA lr_incl_comp LIKE REF TO temp17.

    TRY.


        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                             RECEIVING p_descr_ref     = type_desc
                                             EXCEPTIONS type_not_found = 1 ).


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            previous = x.
    ENDTRY.

    temp15 ?= type_desc.

    sdescr = temp15.

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
    DATA temp18 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).

    temp18 ?= lo_obj_ref.
    result = temp18->attributes.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_type   TYPE REF TO cl_abap_typedescr.
        DATA temp19 TYPE REF TO cl_abap_structdescr.
        DATA temp20 TYPE REF TO cl_abap_structdescr.
        DATA temp5 TYPE REF TO cl_abap_tabledescr.
    DATA temp21 TYPE string.
    DATA lv_absolute_name LIKE temp21.
    DATA lr_cache TYPE REF TO z2ui5_cl_a2ui5_context=>ty_s_attri_cache.
    DATA comps TYPE abap_component_tab.
    DATA temp22 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp22.
        DATA lt_attri TYPE abap_component_tab.
      DATA temp23 TYPE z2ui5_cl_a2ui5_context=>ty_s_attri_cache.

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

        temp19 ?= lo_type.
        lo_struct = temp19.
      WHEN cl_abap_typedescr=>kind_table.


        temp5 ?= lo_type.
        temp20 ?= temp5->get_table_line_type( ).
        lo_struct = temp20.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types

    temp21 = lo_struct->absolute_name.

    lv_absolute_name = temp21.

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

      CLEAR temp23.
      temp23-absolute_name = lv_absolute_name.
      temp23-o_struct = lo_struct.
      temp23-t_attri = result.
      INSERT temp23 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
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

    DATA lt_params TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.
    DATA lv_val TYPE string.
    DATA temp24 TYPE string.
    DATA temp25 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).

    lv_val = c_trim_lower( val ).

    CLEAR temp24.

    READ TABLE lt_params INTO temp25 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp24 = temp25-v.
    ENDIF.
    result = temp24.

  ENDMETHOD.

  METHOD url_param_get_tab.

    DATA lv_search TYPE string.
    DATA lv_search2 TYPE string.
    DATA temp26 TYPE string.
    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp1.
    DATA temp27 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp27.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp28 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
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
      temp26 = lv_search2.
    ELSE.
      temp26 = lv_search.
    ENDIF.
    lv_search = temp26.

    lv_search2 = substring_after( val = c_trim_lower( lv_search )
                                  sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.



    SPLIT lv_search AT `&` INTO TABLE lt_param.



    LOOP AT lt_param REFERENCE INTO lr_param.


      SPLIT lr_param->* AT `=` INTO lv_name lv_value.

      CLEAR temp28.
      temp28-n = lv_name.
      temp28-v = lv_value.
      INSERT temp28 INTO TABLE rt_params.
    ENDLOOP.

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
          RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
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
    DATA temp29 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp29.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp30 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO lr_attri.


      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE rtti_get_type_kind( <component> ).

        WHEN cl_abap_typedescr=>typekind_table.

        WHEN OTHERS.

          CLEAR temp30.
          temp30-n = lr_attri->name.
          temp30-v = <component>.
          INSERT temp30 INTO TABLE result.
      ENDCASE.

    ENDLOOP.

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

    CASE val.
      WHEN `E`.
        result = cs_ui5_msg_type-e.
      WHEN `S`.
        result = cs_ui5_msg_type-s.
      WHEN `W`.
        result = cs_ui5_msg_type-w.
      WHEN OTHERS.
        result = cs_ui5_msg_type-i.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get.

    DATA lt_msg TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.
    DATA temp31 LIKE LINE OF lt_msg.
    DATA temp32 LIKE sy-tabix.
    lt_msg = msg_get_t( val  = val
                              val2 = val2 ).


    temp32 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp31.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp31.

  ENDMETHOD.

  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.

  METHOD rtti_get_ddic_type_name.

    DATA temp33 TYPE REF TO cl_abap_elemdescr.
    temp33 ?= type.
    result = substring_after( val = temp33->absolute_name
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
    DATA temp34 TYPE REF TO cl_abap_tabledescr.
    DATA lo_table LIKE temp34.
        DATA temp35 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp35.
        DATA temp36 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp36.
        DATA temp37 TYPE abap_componentdescr.
    DATA temp38 LIKE sy-subrc.
      DATA lo_type_bool TYPE REF TO cl_abap_typedescr.
      DATA temp39 TYPE abap_componentdescr.
      DATA temp6 TYPE REF TO cl_abap_datadescr.
    DATA lo_line_type TYPE REF TO cl_abap_structdescr.
    ASSIGN ir_tab->* TO <tab>.


    temp34 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

    lo_table = temp34.
    TRY.

        temp35 ?= lo_table->get_table_line_type( ).

        lo_struct = temp35.
        lt_comp = lo_struct->get_components( ).
      CATCH cx_root.
        result-check_table_line = abap_true.

        temp36 ?= lo_table->get_table_line_type( ).

        lo_elem = temp36.

        CLEAR temp37.
        temp37-name = `TAB_LINE`.
        temp37-type = lo_elem.
        INSERT temp37 INTO TABLE lt_comp.
    ENDTRY.


    READ TABLE lt_comp WITH KEY name = sel_field_name TRANSPORTING NO FIELDS.
    temp38 = sy-subrc.
    IF add_sel_field = abap_true
        AND NOT temp38 = 0.

      lo_type_bool = cl_abap_typedescr=>describe_by_name( `ABAP_BOOL` ).

      CLEAR temp39.
      temp39-name = sel_field_name.

      temp6 ?= lo_type_bool.
      temp39-type = temp6.
      INSERT temp39 INTO TABLE lt_comp.
    ENDIF.


    lo_line_type = cl_abap_structdescr=>create( lt_comp ).
    result-tabledescr = cl_abap_tabledescr=>create( lo_line_type ).

  ENDMETHOD.

  METHOD rtti_check_table.

    DATA lv_type_kind TYPE abap_typekind.
    DATA temp3 TYPE xsdboolean.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).

    temp3 = boolc( lv_type_kind = cl_abap_typedescr=>typekind_table ).
    result = temp3.

  ENDMETHOD.

  METHOD rtti_check_structure.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp4 TYPE xsdboolean.

    TRY.

        lo_type = cl_abap_typedescr=>describe_by_data( val ).

        temp4 = boolc( lo_type->kind = cl_abap_typedescr=>kind_struct ).
        result = temp4.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD ui5_msg_box_format.

    DATA lt_msg TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.
      DATA temp40 LIKE LINE OF lt_msg.
      DATA temp41 LIKE sy-tabix.
      DATA temp42 LIKE LINE OF lt_msg.
      DATA temp43 LIKE sy-tabix.
      DATA temp44 LIKE LINE OF lt_msg.
      DATA temp45 LIKE sy-tabix.
      DATA lt_detail_items TYPE string_table.
      DATA temp46 LIKE LINE OF lt_msg.
      DATA lr_msg LIKE REF TO temp46.
        DATA temp47 LIKE LINE OF lt_detail_items.
      DATA temp48 LIKE LINE OF lt_msg.
      DATA temp49 LIKE sy-tabix.
      DATA temp50 LIKE LINE OF lt_msg.
      DATA temp51 LIKE sy-tabix.
    lt_msg = msg_get_t( val ).

    IF lines( lt_msg ) = 1.


      temp41 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp40.
      sy-tabix = temp41.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-text  = temp40-text.


      temp43 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp42.
      sy-tabix = temp43.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type  = to_lower( ui5_get_msg_type( temp42-type ) ).


      temp45 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp44.
      sy-tabix = temp45.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title = ui5_get_msg_type( temp44-type ).

    ELSEIF lines( lt_msg ) > 1.
      result-text = | { lines( lt_msg ) } Messages found: |.



      LOOP AT lt_msg REFERENCE INTO lr_msg.

        temp47 = |<li>{ lr_msg->text }</li>|.
        INSERT temp47 INTO TABLE lt_detail_items.
      ENDLOOP.
      result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.


      temp49 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp48.
      sy-tabix = temp49.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title   = ui5_get_msg_type( temp48-type ).


      temp51 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp50.
      sy-tabix = temp51.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type    = ui5_get_msg_type( temp50-type ).

    ELSE.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_serializable.
        DATA temp52 TYPE REF TO if_serializable_object.
        DATA lo_dummy LIKE temp52.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.

        temp52 ?= val.

        lo_dummy = temp52.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD app_get_url.

    DATA lt_param TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.
    DATA temp53 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
    lt_param = url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.

    CLEAR temp53.
    temp53-n = `app_start`.
    temp53-v = to_lower( classname ).
    INSERT temp53 INTO TABLE lt_param.

    result = |{ origin }{ pathname }?| && url_param_create_url( lt_param ) && hash.

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

    IF context_check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_classes_intf_cloud( val ).
    ELSE.
      result = rtti_get_classes_intf_std( val ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_cloud.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA xco_cp_abap         TYPE c LENGTH 11.
    DATA implementation_name LIKE LINE OF lt_implementation_names.
    DATA ls_class            LIKE LINE OF result.

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

    LOOP AT lt_implementation_names INTO implementation_name.

      ls_class-classname   = implementation_name.
      ls_class-description = rtti_get_class_descr_on_cloud( implementation_name ).
      INSERT ls_class INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_std.

    TYPES BEGIN OF ty_s_impl.
    TYPES clsname    TYPE c LENGTH 30.
    TYPES refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    " DEFAULT KEY on purpose: this table is passed to the classic function
    " module SEO_INTERFACE_IMPLEM_GET_ALL (impkeys), whose formal parameter is
    " a STANDARD TABLE WITH DEFAULT KEY. WITH EMPTY KEY makes the table type
    " incompatible, so the CALL FUNCTION fails and no implementers are returned
    " (silently breaking user-exit discovery). Never change this key type.
    TYPES temp2 TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
DATA lt_impl TYPE temp2.
    TYPES BEGIN OF ty_s_key.
    TYPES intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA class    TYPE REF TO data.
    DATA type     TYPE c LENGTH 12.
    FIELD-SYMBOLS <class> TYPE data.
    DATA lr_impl  TYPE REF TO ty_s_impl.
    FIELD-SYMBOLS <description> TYPE any.
    DATA ls_class TYPE ty_s_class_descr.
    DATA lv_fm    TYPE string.

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
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error.
      ENDIF.

      ASSIGN
        COMPONENT `DESCRIPT`
        OF STRUCTURE <class>
        TO <description>.
      ASSERT sy-subrc = 0.

      CLEAR ls_class.
      ls_class-classname   = lr_impl->clsname.
      ls_class-description = <description>.
      INSERT
        ls_class
        INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    DATA data_element_name TYPE string.
    DATA lv_do_fallback    TYPE abap_bool.

    data_element_name = val.

    TRY.
        rtti_get_dtel_texts_by_ddic( EXPORTING name        = data_element_name
                                     IMPORTING texts       = result
                                               do_fallback = lv_do_fallback ).
      CATCH cx_root.
        rtti_get_dtel_texts_by_xco( EXPORTING name        = data_element_name
                                    IMPORTING texts       = result
                                              do_fallback = lv_do_fallback ).
    ENDTRY.

    IF lv_do_fallback = abap_true AND result IS INITIAL.
      result-header = val.
      result-long = val.
      result-medium = val.
      result-short = val.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_ddic.

    DATA ddic_ref TYPE REF TO data.
    DATA: BEGIN OF ddic,
            reptext   TYPE string,
            scrtext_s TYPE string,
            scrtext_m TYPE string,
            scrtext_l TYPE string,
          END OF ddic.
    DATA struct_desrc TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <ddic> TYPE data.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
    DATA data_descr   TYPE REF TO cl_abap_datadescr.

    CLEAR texts.
    do_fallback = abap_false.

    cl_abap_typedescr=>describe_by_name( `T100` ).

    struct_desrc ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

    CREATE DATA ddic_ref TYPE HANDLE struct_desrc.

    ASSIGN ddic_ref->* TO <ddic>.
    ASSERT sy-subrc = 0.

    cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name     = name
                                         RECEIVING p_descr_ref = lo_typedescr
                                         EXCEPTIONS OTHERS     = 1 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    data_descr ?= lo_typedescr.

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
    texts-header = ddic-reptext.
    texts-short  = ddic-scrtext_s.
    texts-medium = ddic-scrtext_m.
    texts-long   = ddic-scrtext_l.
    do_fallback  = abap_true.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_xco.

    DATA data_element TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA exists       TYPE abap_bool.
    DATA lv_xco_cp_abap_dictionary TYPE string.

    CLEAR texts.
    do_fallback = abap_false.

    TRY.
        lv_xco_cp_abap_dictionary = `XCO_CP_ABAP_DICTIONARY`.
        CALL METHOD (lv_xco_cp_abap_dictionary)=>(`DATA_ELEMENT`)
          EXPORTING
            iv_name         = name
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
            rs_heading_field_label = texts-header.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL`)
          RECEIVING
            rs_short_field_label = texts-short.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL`)
          RECEIVING
            rs_medium_field_label = texts-medium.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL`)
          RECEIVING
            rs_long_field_label = texts-long.

        do_fallback = abap_true.

      CATCH cx_root.
        do_fallback = abap_true.
    ENDTRY.

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

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


  METHOD msg_get_internal.

    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        FIELD-SYMBOLS <row> TYPE ANY.
          DATA lt_tab TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp54 TYPE ty_s_msg.
        DATA ls_result LIKE temp54.
        DATA temp55 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp55.
          FIELD-SYMBOLS <comp> TYPE any.
          DATA temp56 TYPE z2ui5_cl_a2ui5_context=>ty_s_msg.
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


        CLEAR temp54.

        ls_result = temp54.


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
            ls_result = msg_map( name   = ls_attri->name
                                 val    = <comp>
                                 is_msg = ls_result ).
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

          CLEAR temp56.
          temp56-text = val.
          INSERT temp56 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get_by_oref.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA temp57 TYPE REF TO cx_root.
        DATA lx LIKE temp57.
        DATA temp58 TYPE ty_s_msg.
        DATA ls_result LIKE temp58.
        DATA lt_attri_o TYPE abap_attrdescr_tab.
        DATA temp59 LIKE LINE OF lt_attri_o.
        DATA ls_attri_o LIKE REF TO temp59.
          DATA lv_name LIKE ls_attri_o->name.
        DATA obj TYPE REF TO object.
            DATA lr_tab TYPE REF TO data.
            FIELD-SYMBOLS <tab2> TYPE data.
            DATA lt_tab2 TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.

    TRY.

        temp57 ?= val.

        lx = temp57.

        CLEAR temp58.
        temp58-type = `E`.
        temp58-text = lx->get_text( ).

        ls_result = temp58.

        lt_attri_o = rtti_get_t_attri_by_oref( val ).


        LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
             WHERE visibility = `U`.

          lv_name = ls_attri_o->name.
          ASSIGN lx->(lv_name) TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          ls_result = msg_map( name   = ls_attri_o->name
                               val    = <comp>
                               is_msg = ls_result ).
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
                  ls_result = msg_map( name   = ls_attri_o->name
                                       val    = <comp>
                                       is_msg = ls_result ).
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
    DATA temp60 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp60.
      FIELD-SYMBOLS <tab> TYPE any.
          DATA temp61 TYPE REF TO cl_abap_tabledescr.
          DATA lo_tab LIKE temp61.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp62 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp63 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp63.
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

          temp61 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

          lo_tab = temp61.

          lo_line = lo_tab->get_table_line_type( ).
          CHECK lo_line->kind = cl_abap_typedescr=>kind_struct.

          temp62 ?= lo_line.

          lt_comps = temp62->get_components( ).


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
    DATA temp64 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp64.
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
    DATA lt_meta TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE z2ui5_cl_a2ui5_context=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp65 TYPE z2ui5_cl_a2ui5_context=>ty_s_msg.

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

        CLEAR temp65.
        temp65-type = `E`.
        temp65-text = lv_text.
        temp65-t_meta = lt_meta.
        INSERT temp65 INTO TABLE messages.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_element.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp66 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp66.
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
    DATA temp67 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp67.
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
    DATA temp68 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp68.
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
      DATA temp69 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
      DATA temp70 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
      DATA temp71 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
      DATA temp72 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
      DATA temp73 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.
      DATA temp74 TYPE z2ui5_cl_a2ui5_context=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp69.
      temp69-n = `element`.
      temp69-v = lv.
      INSERT temp69 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp70.
      temp70-n = `state_area`.
      temp70-v = lv.
      INSERT temp70 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp71.
      temp71-n = `action`.
      temp71-v = lv.
      INSERT temp71 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp72.
      temp72-n = `pid`.
      temp72-v = lv.
      INSERT temp72 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp73.
      temp73-n = `cid`.
      temp73-v = lv.
      INSERT temp73 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp74.
      temp74-n = `tky`.
      temp74-v = lv.
      INSERT temp74 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.

    DATA temp75 TYPE string.
    CASE cause.
      WHEN 0.
        temp75 = `Operation failed`.
      WHEN 1.
        temp75 = `Entity not found`.
      WHEN 2.
        temp75 = `Entity is locked`.
      WHEN 3.
        temp75 = `Authorization failure`.
      WHEN 4.
        temp75 = `Concurrent modification`.
      WHEN 5.
        temp75 = `Concurrent modification`.
      WHEN 6.
        temp75 = `Operation disabled`.
      WHEN 7.
        temp75 = `Operation forbidden`.
      WHEN 8.
        temp75 = `Semantic error`.
      WHEN 9.
        temp75 = `Determination failed`.
      WHEN 10.
        temp75 = `Permission denied`.
      WHEN 11.
        temp75 = `Validation failed`.
      WHEN OTHERS.
        temp75 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp75.

  ENDMETHOD.

ENDCLASS.
