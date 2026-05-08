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
      RETURNING
        VALUE(result) TYPE ty_s_msg.

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
        val  TYPE clike
      CHANGING
        !tab TYPE STANDARD TABLE.

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

    CLASS-METHODS source_get_file_types
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS rtti_tab_get_relative_name
      IMPORTING
        !table        TYPE any
      RETURNING
        VALUE(result) TYPE string.

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

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_bool_cache,
        absolute_name TYPE string,
        is_bool       TYPE abap_bool,
      END OF ty_s_bool_cache.

    CLASS-DATA mt_bool_cache TYPE HASHED TABLE OF ty_s_bool_cache WITH UNIQUE KEY absolute_name.

ENDCLASS.



CLASS z2ui5_cl_util IMPLEMENTATION.


  METHOD boolean_abap_2_json.
      DATA temp90 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.
      
      IF val = abap_true.
        temp90 = `true`.
      ELSE.
        temp90 = `false`.
      ENDIF.
      result = temp90.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD boolean_check_by_data.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp91 TYPE string.
        DATA lv_abs_name LIKE temp91.
        DATA temp92 LIKE sy-subrc.
          DATA temp93 LIKE LINE OF mt_bool_cache.
          DATA temp94 LIKE sy-tabix.
        DATA temp95 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp95.
        DATA temp96 TYPE z2ui5_cl_util=>ty_s_bool_cache.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        
        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).
        
        temp91 = lo_descr->absolute_name.
        
        lv_abs_name = temp91.

        
        READ TABLE mt_bool_cache WITH KEY absolute_name = lv_abs_name TRANSPORTING NO FIELDS.
        temp92 = sy-subrc.
        IF temp92 = 0.
          
          
          temp94 = sy-tabix.
          READ TABLE mt_bool_cache WITH KEY absolute_name = lv_abs_name INTO temp93.
          sy-tabix = temp94.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          result = temp93-is_bool.
          RETURN.
        ENDIF.

        
        temp95 ?= lo_descr.
        
        lo_ele = temp95.
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).

        
        CLEAR temp96.
        temp96-absolute_name = lv_abs_name.
        temp96-is_bool = result.
        INSERT temp96 INTO TABLE mt_bool_cache.

        
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


  METHOD c_trim.

    DATA temp97 TYPE string.
    temp97 = val.
    result = shift_left( shift_right( temp97 ) ).
    result = shift_right( val = result
                          sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result
                         sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    DATA temp98 TYPE string.
    temp98 = val.
    result = to_lower( c_trim( temp98 ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    DATA temp99 TYPE string.
    temp99 = val.
    result = to_upper( c_trim( temp99 ) ).

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

    DATA temp100 TYPE abap_component_tab.
    DATA temp5 LIKE LINE OF temp100.
    DATA lr_comp LIKE REF TO temp5.
      DATA temp101 TYPE z2ui5_cl_util=>ty_s_filter_multi.
    temp100 = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT temp100 REFERENCE INTO lr_comp.
      
      CLEAR temp101.
      temp101-name = lr_comp->name.
      INSERT temp101 INTO TABLE result.
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
    FIELD-SYMBOLS <temp102> TYPE z2ui5_cl_util=>ty_s_filter_multi.
DATA lr_filter LIKE REF TO <temp102>.
    DATA ls_token LIKE LINE OF lr_filter->t_token_removed.
      DATA temp103 TYPE z2ui5_cl_util=>ty_s_token.
    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp6 LIKE LINE OF result.
    DATA temp7 LIKE sy-tabix.

    result = val.
    
    READ TABLE result WITH KEY name = name ASSIGNING <temp102>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp102> INTO lr_filter.
    
    LOOP AT lr_filter->t_token_removed INTO ls_token.
      DELETE lr_filter->t_token WHERE key = ls_token-key.
    ENDLOOP.

    LOOP AT lr_filter->t_token_added INTO ls_token.
      
      CLEAR temp103.
      temp103-key = ls_token-key.
      temp103-text = ls_token-text.
      temp103-visible = abap_true.
      temp103-editable = abap_true.
      INSERT temp103 INTO TABLE lr_filter->t_token.
    ENDLOOP.

    CLEAR lr_filter->t_token_removed.
    CLEAR lr_filter->t_token_added.

    
    
    
    temp7 = sy-tabix.
    READ TABLE result WITH KEY name = name INTO temp6.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_range = z2ui5_cl_util=>filter_get_range_t_by_token_t( temp6-t_token ).
    lr_filter->t_range = lt_range.

  ENDMETHOD.


  METHOD filter_get_range_t_by_token_t.

    DATA ls_token LIKE LINE OF val.
    LOOP AT val INTO ls_token.
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_token_range_mapping.

    DATA temp104 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp105 LIKE LINE OF temp104.
    CLEAR temp104.
    
    temp105-n = `EQ`.
    temp105-v = `={LOW}`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `LT`.
    temp105-v = `<{LOW}`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `LE`.
    temp105-v = `<={LOW}`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `GT`.
    temp105-v = `>{LOW}`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `GE`.
    temp105-v = `>={LOW}`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `CP`.
    temp105-v = `*{LOW}*`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `BT`.
    temp105-v = `{LOW}...{HIGH}`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `NB`.
    temp105-v = `!({LOW}...{HIGH})`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `NE`.
    temp105-v = `!(={LOW})`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `NP`.
    temp105-v = `!(*{LOW}*)`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `!<leer>`.
    temp105-v = `!(<leer>)`.
    INSERT temp105 INTO TABLE temp104.
    temp105-n = `<leer>`.
    temp105-v = `<leer>`.
    INSERT temp105 INTO TABLE temp104.
    result = temp104.

  ENDMETHOD.


  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp106 TYPE ty_t_range.
    DATA lt_tab LIKE temp106.
    DATA temp107 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp107.
      DATA lv_value TYPE z2ui5_cl_util=>ty_s_name_value-v.
      DATA temp8 LIKE LINE OF lt_mapping.
      DATA temp9 LIKE sy-tabix.
      DATA temp108 TYPE z2ui5_cl_util=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).

    
    CLEAR temp106.
    
    lt_tab = temp106.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab
    ).

    
    
    LOOP AT lt_tab REFERENCE INTO lr_row.

      
      
      
      temp9 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option INTO temp8.
      sy-tabix = temp9.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = temp8-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      
      CLEAR temp108.
      temp108-key = lv_value.
      temp108-text = lv_value.
      temp108-visible = abap_true.
      temp108-editable = abap_true.
      INSERT temp108 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD itab_filter_by_val.

    FIELD-SYMBOLS <row> TYPE any.
      DATA lv_row TYPE string.
      DATA lv_index TYPE i.
        FIELD-SYMBOLS <field> TYPE any.

    LOOP AT tab ASSIGNING <row>.
      
      lv_row = ``.
      
      lv_index = 1.
      DO.
        
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
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
    DATA lt_lines TYPE string_table.
    DATA lv_line TYPE string.
    DATA temp109 TYPE REF TO cl_abap_tabledescr.
    DATA tab LIKE temp109.
    DATA temp110 TYPE REF TO cl_abap_structdescr.
    DATA struc LIKE temp110.
    DATA temp111 TYPE abap_component_tab.
    DATA temp10 LIKE LINE OF temp111.
    DATA lr_comp LIKE REF TO temp10.
    DATA lr_row TYPE REF TO data.
      DATA lv_index TYPE i.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.

    ASSIGN val TO <tab>.
    
    temp109 ?= cl_abap_typedescr=>describe_by_data( <tab> ).
    
    tab = temp109.

    
    temp110 ?= tab->get_table_line_type( ).
    
    struc = temp110.

    CLEAR lv_line.
    
    temp111 = struc->get_components( ).
    
    
    LOOP AT temp111 REFERENCE INTO lr_comp.
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
    DATA temp11 LIKE LINE OF lt_rows.
    DATA temp12 LIKE sy-tabix.
    DATA temp112 LIKE LINE OF lt_cols.
    DATA lr_col LIKE REF TO temp112.
      DATA lv_name TYPE string.
      DATA temp113 TYPE abap_componentdescr.
    DATA struc TYPE REF TO cl_abap_structdescr.
    DATA temp114 TYPE REF TO cl_abap_datadescr.
    DATA data LIKE temp114.
    DATA o_table_desc TYPE REF TO cl_abap_tabledescr.
    DATA temp115 LIKE LINE OF lt_rows.
    DATA lr_rows LIKE REF TO temp115.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
    SPLIT val AT cl_abap_char_utilities=>newline INTO TABLE lt_rows.
    

    
    
    temp12 = sy-tabix.
    READ TABLE lt_rows INDEX 1 INTO temp11.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    SPLIT temp11 AT `;` INTO TABLE lt_cols.

    
    
    LOOP AT lt_cols REFERENCE INTO lr_col.

      
      lv_name = c_trim_upper( lr_col->* ).
      REPLACE ` ` IN lv_name WITH `_`.

      
      CLEAR temp113.
      temp113-name = lv_name.
      temp113-type = cl_abap_elemdescr=>get_c( 40 ).
      INSERT temp113 INTO TABLE lt_comp.
    ENDLOOP.

    
    struc = cl_abap_structdescr=>get( lt_comp ).
    
    temp114 ?= struc.
    
    data = temp114.
    
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
        DATA temp116 TYPE REF TO z2ui5_if_ajson.
        DATA li_ajson LIKE temp116.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp116 ?= z2ui5_cl_ajson=>create_empty( ).
        
        li_ajson = temp116.
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
        DATA temp117 TYPE REF TO cl_abap_refdescr.
        DATA lo_ref LIKE temp117.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        
        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).
        
        temp117 ?= lo_typdescr.
        
        lo_ref = temp117.
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
    DATA temp118 TYPE REF TO cl_abap_refdescr.
    DATA ref LIKE temp118.
    DATA name TYPE abap_abstypename.
    rtti = cl_abap_typedescr=>describe_by_data( in  ).
    
    temp118 ?= rtti.
    
    ref = temp118.
    
    name = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp119 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp119.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.
    TRY.

        
        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).
        
        temp119 ?= lo_descr.
        
        lo_ele = temp119.
        result = lo_ele->get_relative_name( ).

        
      CATCH cx_root INTO x.
        
        lv_error = x->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_get_t_attri_by_include.
        DATA type_desc TYPE REF TO cl_abap_typedescr.
        DATA x TYPE REF TO cx_root.
    DATA temp120 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp120.
    DATA comps TYPE abap_component_tab.
    DATA temp121 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp121.
        DATA incl_comps TYPE abap_component_tab.
        DATA temp122 LIKE LINE OF incl_comps.
        DATA lr_incl_comp LIKE REF TO temp122.

    TRY.

        
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                             RECEIVING  p_descr_ref    = type_desc
                                             EXCEPTIONS type_not_found = 1 ).

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.
    
    temp120 ?= type_desc.
    
    sdescr = temp120.
    
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
    DATA temp123 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).
    
    temp123 ?= lo_obj_ref.
    result = temp123->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct TYPE REF TO cl_abap_structdescr.
    DATA lo_type   TYPE REF TO cl_abap_typedescr.
        DATA temp124 TYPE REF TO cl_abap_structdescr.
        DATA temp125 TYPE REF TO cl_abap_structdescr.
        DATA temp13 TYPE REF TO cl_abap_tabledescr.
    DATA comps TYPE abap_component_tab.
    DATA temp126 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp126.
        DATA lt_attri TYPE abap_component_tab.

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
        
        temp124 ?= lo_type.
        lo_struct = temp124.
      WHEN cl_abap_typedescr=>kind_table.
        
        
        temp13 ?= lo_type.
        temp125 ?= temp13->get_table_line_type( ).
        lo_struct = temp125.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    
    comps = lo_struct->get_components( ).

    
    
    LOOP AT comps REFERENCE INTO lr_comp.

      IF lr_comp->as_include = abap_false.
        APPEND lr_comp->* TO result.
      ELSE.
        
        lt_attri = rtti_get_t_attri_by_include( lr_comp->type ).
        APPEND LINES OF lt_attri TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_get_t_ddic_fixed_values.
        DATA temp127 TYPE string.
        DATA typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp128 TYPE REF TO cl_abap_elemdescr.
        DATA elemdescr LIKE temp128.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    IF rollname IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        
        temp127 = rollname.
        
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp127
                                             RECEIVING  p_descr_ref    = typedescr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        
        temp128 ?= typedescr.
        
        elemdescr = temp128.

        result = rtti_get_t_fixvalues( elemdescr = elemdescr
                                       langu     = langu ).

        
      CATCH cx_root INTO x.
        
        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_tab_get_relative_name.

    FIELD-SYMBOLS <table> TYPE any.
        DATA typedesc TYPE REF TO cl_abap_typedescr.
            DATA temp129 TYPE REF TO cl_abap_tabledescr.
            DATA tabledesc LIKE temp129.
            DATA temp130 TYPE REF TO cl_abap_structdescr.
            DATA structdesc LIKE temp130.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        
        typedesc = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.
            
            temp129 ?= typedesc.
            
            tabledesc = temp129.
            
            temp130 ?= tabledesc->get_table_line_type( ).
            
            structdesc = temp130.
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

    DATA temp131 TYPE string.
    DATA lv_sql LIKE temp131.
    DATA lv_dummy TYPE string.
    DATA lv_tab TYPE string.
    temp131 = val.
    
    lv_sql = temp131.
    REPLACE ALL OCCURRENCES OF ` ` IN lv_sql WITH ``.
    lv_sql = to_upper( lv_sql ).
    
    
    SPLIT lv_sql AT `SELECTFROM` INTO lv_dummy lv_tab.
    SPLIT lv_tab AT `FIELDS` INTO lv_tab lv_dummy.

    result-tabname = lv_tab.

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
    DATA temp132 TYPE string.
    DATA temp133 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).
    
    lv_val = c_trim_lower( val ).
    
    CLEAR temp132.
    
    READ TABLE lt_params INTO temp133 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp132 = temp133-v.
    ENDIF.
    result = temp132.

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA lv_search TYPE string.
    DATA lv_search2 TYPE string.
    DATA temp134 TYPE string.
    TYPES temp3 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp3.
    DATA temp135 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp135.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp136 TYPE z2ui5_cl_util=>ty_s_name_value.
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
      temp134 = lv_search2.
    ELSE.
      temp134 = lv_search.
    ENDIF.
    lv_search = temp134.

    lv_search2 = substring_after( val = c_trim_lower( lv_search )
                                  sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.

    

    SPLIT lv_search AT `&` INTO TABLE lt_param.

    
    
    LOOP AT lt_param REFERENCE INTO lr_param.
      
      
      SPLIT lr_param->* AT `=` INTO lv_name lv_value.
      
      CLEAR temp136.
      temp136-n = lv_name.
      temp136-v = lv_value.
      INSERT temp136 INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.


  METHOD url_param_set.

    DATA lt_params TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lv_n TYPE string.
    DATA temp137 LIKE LINE OF lt_params.
    DATA lr_params LIKE REF TO temp137.
      DATA temp138 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).
    
    lv_n = c_trim_lower( name ).

    
    
    LOOP AT lt_params REFERENCE INTO lr_params
         WHERE n = lv_n.
      lr_params->v = c_trim_lower( value ).
    ENDLOOP.
    IF sy-subrc <> 0.
      
      CLEAR temp138.
      temp138-n = lv_n.
      temp138-v = c_trim_lower( value ).
      INSERT temp138 INTO TABLE lt_params.
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
        DATA temp139 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp139.
            DATA temp140 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp140.
            DATA temp141 TYPE REF TO cl_abap_structdescr.
    DATA temp142 LIKE LINE OF result.
    DATA lr_comp LIKE REF TO temp142.
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
        
        temp139 ?= lo_obj.
        
        lo_struct = temp139.

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

            
            temp140 ?= lo_obj.
            
            lo_tab = temp140.
            
            temp141 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp141.
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
    DATA temp143 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp143.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp144 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri.

      
      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE z2ui5_cl_util=>rtti_get_type_kind( <component> ).

        WHEN cl_abap_typedescr=>typekind_table.

        WHEN OTHERS.
          
          CLEAR temp144.
          temp144-n = lr_attri->name.
          temp144-v = <component>.
          INSERT temp144 INTO TABLE result.
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
TYPES BEGIN OF ty_rscedst.
TYPES fnam TYPE c LENGTH 30.
TYPES sign TYPE c LENGTH 1.
TYPES option TYPE c LENGTH 2.
TYPES low TYPE c LENGTH 45.
TYPES high TYPE c LENGTH 45.
TYPES END OF ty_rscedst.
      TYPES temp4 TYPE STANDARD TABLE OF ty_rscedst.
DATA lt_range TYPE temp4.
      DATA ls_filter LIKE LINE OF val.
        DATA ls_range LIKE LINE OF ls_filter-t_range.
          DATA temp145 TYPE ty_rscedst.
      DATA lv_fm TYPE string.


    IF context_check_abap_cloud( ) IS NOT INITIAL.


    ELSE.

      

      


      
      LOOP AT val INTO ls_filter.
        
        LOOP AT ls_filter-t_range INTO ls_range.

          
          CLEAR temp145.
          temp145-fnam = ls_filter-name.
          temp145-sign = ls_range-sign.
          temp145-option = ls_range-option.
          temp145-low = ls_range-low.
          temp145-high = ls_range-high.
          INSERT temp145 INTO TABLE lt_range.

        ENDLOOP.
      ENDLOOP.

      
      lv_fm = `RSDS_RANGE_TO_WHERE`.
      CALL FUNCTION lv_fm
        EXPORTING
          i_t_range      = lt_range
*         i_th_range     =
*         i_r_renderer   =
        IMPORTING
          e_where        = result
*         e_t_where      = lt_where
        EXCEPTIONS
          internal_error = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = z2ui5_cl_util=>context_get_sy( ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD msg_get_t.

    result = z2ui5_cl_util_msg=>msg_get( val ).

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

    DATA temp146 TYPE string.
    CASE val.
      WHEN `E`.
        temp146 = cs_ui5_msg_type-e.
      WHEN `S`.
        temp146 = cs_ui5_msg_type-s.
      WHEN `W`.
        temp146 = cs_ui5_msg_type-w.
      WHEN OTHERS.
        temp146 = cs_ui5_msg_type-i.
    ENDCASE.
    result = temp146.

  ENDMETHOD.


  METHOD rtti_create_tab_by_name.

    DATA struct_desc TYPE REF TO cl_abap_typedescr.
    DATA temp147 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp147.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    struct_desc = cl_abap_structdescr=>describe_by_name( val ).
    
    temp147 ?= struct_desc.
    
    data_desc = temp147.
    
    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.


  METHOD msg_get.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp148 LIKE LINE OF lt_msg.
    DATA temp149 LIKE sy-tabix.
    lt_msg = msg_get_t( val ).
    
    
    temp149 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp148.
    sy-tabix = temp149.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp148.

  ENDMETHOD.


  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.


  METHOD msg_get_by_msg.

    DATA temp150 TYPE ty_s_msg.
    DATA ls_msg LIKE temp150.
    CLEAR temp150.
    temp150-id = id.
    temp150-no = no.
    temp150-v1 = v1.
    temp150-v2 = v2.
    temp150-v3 = v3.
    temp150-v4 = v4.
    
    ls_msg = temp150.
    result = msg_get( ls_msg ).

  ENDMETHOD.


  METHOD c_contains.

    DATA temp151 TYPE string.
    DATA temp4 TYPE xsdboolean.
    temp151 = val.
    
    temp4 = boolc( temp151 CS sub ).
    result = temp4.

  ENDMETHOD.


  METHOD c_starts_with.

    DATA temp152 TYPE string.
    DATA lv_val LIKE temp152.
    DATA temp153 TYPE string.
    DATA lv_prefix LIKE temp153.
    DATA lv_len TYPE i.
    DATA temp5 TYPE xsdboolean.
    temp152 = val.
    
    lv_val = temp152.
    
    temp153 = prefix.
    
    lv_prefix = temp153.
    
    lv_len = strlen( lv_prefix ).

    IF strlen( lv_val ) < lv_len.
      result = abap_false.
      RETURN.
    ENDIF.

    
    temp5 = boolc( lv_val(lv_len) = lv_prefix ).
    result = temp5.

  ENDMETHOD.


  METHOD c_ends_with.

    DATA temp154 TYPE string.
    DATA lv_val LIKE temp154.
    DATA temp155 TYPE string.
    DATA lv_suffix LIKE temp155.
    DATA lv_len_suffix TYPE i.
    DATA lv_len_val TYPE i.
    DATA lv_off TYPE i.
    DATA temp6 TYPE xsdboolean.
    temp154 = val.
    
    lv_val = temp154.
    
    temp155 = suffix.
    
    lv_suffix = temp155.
    
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

    DATA temp156 TYPE string.
    DATA lv_val LIKE temp156.
    DATA temp157 TYPE string.
    DATA lv_fmt LIKE temp157.
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
    temp156 = val.
    
    lv_val = temp156.
    
    temp157 = format.
    
    lv_fmt = temp157.
    
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

    DATA temp158 TYPE string.
    DATA lv_fmt LIKE temp158.
    DATA temp159 TYPE string.
    DATA lv_date LIKE temp159.
    DATA lv_year TYPE string.
    DATA lv_month TYPE string.
    DATA lv_day TYPE string.
    temp158 = format.
    
    lv_fmt = temp158.
    
    temp159 = val.
    
    lv_date = temp159.

    
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
      DATA temp160 LIKE LINE OF lt_msg.
      DATA temp161 LIKE sy-tabix.
      DATA temp162 LIKE LINE OF lt_msg.
      DATA temp163 LIKE sy-tabix.
      DATA temp164 LIKE LINE OF lt_msg.
      DATA temp165 LIKE sy-tabix.
      DATA lt_detail_items TYPE string_table.
      DATA temp166 LIKE LINE OF lt_msg.
      DATA lr_msg LIKE REF TO temp166.
        DATA temp167 LIKE LINE OF lt_detail_items.
      DATA temp168 LIKE LINE OF lt_msg.
      DATA temp169 LIKE sy-tabix.
      DATA temp170 LIKE LINE OF lt_msg.
      DATA temp171 LIKE sy-tabix.
    lt_msg = msg_get_t( val ).

    IF lines( lt_msg ) = 1.
      
      
      temp161 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp160.
      sy-tabix = temp161.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-text  = temp160-text.
      
      
      temp163 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp162.
      sy-tabix = temp163.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type  = to_lower( ui5_get_msg_type( temp162-type ) ).
      
      
      temp165 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp164.
      sy-tabix = temp165.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title = ui5_get_msg_type( temp164-type ).

    ELSEIF lines( lt_msg ) > 1.
      result-text = | { lines( lt_msg ) } Messages found: |.
      
      
      
      LOOP AT lt_msg REFERENCE INTO lr_msg.
        
        temp167 = |<li>{ lr_msg->text }</li>|.
        INSERT temp167 INTO TABLE lt_detail_items.
      ENDLOOP.
      result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.
      
      
      temp169 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp168.
      sy-tabix = temp169.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-title   = ui5_get_msg_type( temp168-type ).
      
      
      temp171 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp170.
      sy-tabix = temp171.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-type    = ui5_get_msg_type( temp170-type ).

    ELSE.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_check_serializable.
        DATA temp172 TYPE REF TO if_serializable_object.
        DATA lo_dummy LIKE temp172.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.
        
        temp172 ?= val.
        
        lo_dummy = temp172.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD app_get_url.

    DATA lt_param TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp173 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_param = url_param_get_tab( search ).
    DELETE lt_param WHERE n = `app_start`.
    
    CLEAR temp173.
    temp173-n = `app_start`.
    temp173-v = to_lower( classname ).
    INSERT temp173 INTO TABLE lt_param.

    result = |{ origin }{ pathname }?| && url_param_create_url( lt_param ) && hash.

  ENDMETHOD.


  METHOD app_get_url_source_code.

    result = |{ origin }/sap/bc/adt/oo/classes/{ classname }/source/main|.

  ENDMETHOD.
ENDCLASS.
