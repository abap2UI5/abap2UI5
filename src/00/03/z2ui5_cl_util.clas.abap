CLASS z2ui5_cl_util DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_util_abap
  CREATE PUBLIC.

  PUBLIC SECTION.

    " abap-toolkit - Utility Functions for ABAP Cloud & Standard ABAP
    " version: '0.0.1'.
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

    CLASS-METHODS ui5_get_msg_type
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

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
        VALUE(result) TYPE z2ui5_cl_util_abap=>ty_t_fix_val ##NEEDED.

    CLASS-METHODS source_get_method2
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS check_bound_a_not_inital
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_unassign_inital
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
        !filter TYPE ty_t_filter_multi
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
        val           TYPE  z2ui5_cl_util=>ty_t_filter_multi
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
        v TYPE clike DEFAULT `CX_SY_SUBRC`
          PREFERRED PARAMETER v.

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

    CLASS-METHODS time_substract_seconds
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

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_util IMPLEMENTATION.


  METHOD boolean_abap_2_json.
      DATA temp42 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.
      
      IF val = abap_true.
        temp42 = `true`.
      ELSE.
        temp42 = `false`.
      ENDIF.
      result = temp42.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD boolean_check_by_data.
        DATA lv_type_name TYPE string.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        
        lv_type_name = rtti_get_type_name( val ).
        result = boolean_check_by_name( lv_type_name ).
        
      CATCH cx_root INTO x.
        
        lv_error = x->get_text( ).
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
          OR 'BOOLE_D'
          OR 'OS_BOOLEAN'.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD check_bound_a_not_inital.
    DATA temp1 TYPE xsdboolean.

    IF val IS NOT BOUND.
      result = abap_false.
      RETURN.
    ENDIF.
    
    temp1 = boolc( check_unassign_inital( val ) = abap_false ).
    result = temp1.

  ENDMETHOD.


  METHOD check_unassign_inital.
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

*    GET REFERENCE OF val INTO result.
    GET REFERENCE OF val INTO result.

  ENDMETHOD.


  METHOD c_trim.

    DATA temp43 TYPE string.
    temp43 = val.
    result = shift_left( shift_right( temp43 ) ).
    result = shift_right( val = result
                          sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result
                         sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    DATA temp44 TYPE string.
    temp44 = val.
    result = to_lower( c_trim( temp44 ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    DATA temp45 TYPE string.
    temp45 = val.
    result = to_upper( c_trim( temp45 ) ).

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

    DATA temp46 TYPE abap_component_tab.
    DATA temp5 LIKE LINE OF temp46.
    DATA lr_comp LIKE REF TO temp5.
      DATA temp47 TYPE z2ui5_cl_util=>ty_s_filter_multi.
    temp46 = rtti_get_t_attri_by_any( val ).
    
    
    LOOP AT temp46 REFERENCE INTO lr_comp.
      
      CLEAR temp47.
      temp47-name = lr_comp->name.
      INSERT temp47 INTO TABLE result.
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
          SHIFT lv_value RIGHT DELETING TRAILING `*`.
          SHIFT lv_value LEFT DELETING LEADING `*`.
          CLEAR result.
          result-sign = `I`.
          result-option = `CP`.
          result-low = lv_value.
        ENDIF.

      WHEN OTHERS.
        IF lv_value CP `...`.
          SPLIT lv_value AT `...` INTO result-low result-high.
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
    FIELD-SYMBOLS <temp48> TYPE z2ui5_cl_util=>ty_s_filter_multi.
DATA lr_filter LIKE REF TO <temp48>.
    DATA ls_token LIKE LINE OF lr_filter->t_token_removed.
      DATA temp49 TYPE z2ui5_cl_util=>ty_s_token.
    DATA lt_token TYPE z2ui5_cl_util=>ty_t_token.
    DATA temp6 LIKE LINE OF result.
    DATA temp7 LIKE sy-tabix.
    DATA lt_range TYPE z2ui5_cl_util=>ty_t_range.
    DATA temp8 LIKE LINE OF result.
    DATA temp9 LIKE sy-tabix.

    result = val.
    
    READ TABLE result WITH KEY name = name ASSIGNING <temp48>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp48> INTO lr_filter.
    
    LOOP AT lr_filter->t_token_removed INTO ls_token.
      DELETE lr_filter->t_token WHERE key = ls_token-key.
    ENDLOOP.

    LOOP AT lr_filter->t_token_added INTO ls_token.
      
      CLEAR temp49.
      temp49-key = ls_token-key.
      temp49-text = ls_token-text.
      temp49-visible = abap_true.
      temp49-editable = abap_true.
      INSERT temp49 INTO TABLE lr_filter->t_token.
    ENDLOOP.

    CLEAR lr_filter->t_token_removed.
    CLEAR lr_filter->t_token_added.

    " TODO: variable is assigned but never used (ABAP cleaner)
    
    
    
    temp7 = sy-tabix.
    READ TABLE result WITH KEY name = name INTO temp6.
    sy-tabix = temp7.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_token = temp6-t_token.
    
    
    
    temp9 = sy-tabix.
    READ TABLE result WITH KEY name = name INTO temp8.
    sy-tabix = temp9.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lt_range = z2ui5_cl_util=>filter_get_range_t_by_token_t( temp8-t_token ).
    lr_filter->t_range = lt_range.

  ENDMETHOD.


  METHOD filter_get_range_t_by_token_t.

    DATA ls_token LIKE LINE OF val.
    LOOP AT val INTO ls_token.
      INSERT filter_get_range_by_token( ls_token-text ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_get_token_range_mapping.

    DATA temp50 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp51 LIKE LINE OF temp50.
    CLEAR temp50.
    
    temp51-n = `EQ`.
    temp51-v = `={LOW}`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `LT`.
    temp51-v = `<{LOW}`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `LE`.
    temp51-v = `<={LOW}`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `GT`.
    temp51-v = `>{LOW}`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `GE`.
    temp51-v = `>={LOW}`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `CP`.
    temp51-v = `*{LOW}*`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `BT`.
    temp51-v = `{LOW}...{HIGH}`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `NE`.
    temp51-v = `!(={LOW})`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `NE`.
    temp51-v = `!(<leer>)`.
    INSERT temp51 INTO TABLE temp50.
    temp51-n = `<leer>`.
    temp51-v = `<leer>`.
    INSERT temp51 INTO TABLE temp50.
    result = temp50.

  ENDMETHOD.


  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp52 TYPE ty_t_range.
    DATA lt_tab LIKE temp52.
    DATA temp53 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp53.
      DATA lv_value TYPE z2ui5_cl_util=>ty_s_name_value-v.
      DATA temp10 LIKE LINE OF lt_mapping.
      DATA temp11 LIKE sy-tabix.
      DATA temp54 TYPE z2ui5_cl_util=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).

    
    CLEAR temp52.
    
    lt_tab = temp52.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab
    ).

    
    
    LOOP AT lt_tab REFERENCE INTO lr_row.

      
      
      
      temp11 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option INTO temp10.
      sy-tabix = temp11.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = temp10-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      
      CLEAR temp54.
      temp54-key = lv_value.
      temp54-text = lv_value.
      temp54-visible = abap_true.
      temp54-editable = abap_true.
      INSERT temp54 INTO TABLE result.
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
    DATA temp55 TYPE REF TO cl_abap_tabledescr.
    DATA tab LIKE temp55.
    DATA temp56 TYPE REF TO cl_abap_structdescr.
    DATA struc LIKE temp56.
    DATA temp57 TYPE abap_component_tab.
    DATA temp12 LIKE LINE OF temp57.
    DATA lr_comp LIKE REF TO temp12.
    DATA lr_row TYPE REF TO data.
      DATA lv_index TYPE i.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.

    ASSIGN val TO <tab>.
    
    temp55 ?= cl_abap_typedescr=>describe_by_data( <tab> ).
    
    tab = temp55.

    
    temp56 ?= tab->get_table_line_type( ).
    
    struc = temp56.

    
    temp57 = struc->get_components( ).
    
    
    LOOP AT temp57 REFERENCE INTO lr_comp.
      result = |{ result }{ lr_comp->name };|.
    ENDLOOP.

    result = result && cl_abap_char_utilities=>cr_lf.

    
    LOOP AT <tab> REFERENCE INTO lr_row.

      
      lv_index = 1.
      DO.
        
        ASSIGN lr_row->* TO <row>.
        
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        result = |{ result }{ <field> };|.
      ENDDO.
      result = result && cl_abap_char_utilities=>cr_lf.
    ENDLOOP.

  ENDMETHOD.




  METHOD itab_get_itab_by_csv.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA lr_row TYPE REF TO data.

    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_rows TYPE temp1.
    TYPES temp2 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_cols TYPE temp2.
    DATA temp13 LIKE LINE OF lt_rows.
    DATA temp14 LIKE sy-tabix.
    DATA temp58 LIKE LINE OF lt_cols.
    DATA lr_col LIKE REF TO temp58.
      DATA lv_name TYPE string.
      DATA temp59 TYPE abap_componentdescr.
    DATA struc TYPE REF TO cl_abap_structdescr.
    DATA temp60 TYPE REF TO cl_abap_datadescr.
    DATA data LIKE temp60.
    DATA o_table_desc TYPE REF TO cl_abap_tabledescr.
    DATA temp61 LIKE LINE OF lt_rows.
    DATA lr_rows LIKE REF TO temp61.
        FIELD-SYMBOLS <row> TYPE data.
        FIELD-SYMBOLS <field> TYPE any.
    SPLIT val AT cl_abap_char_utilities=>newline INTO TABLE lt_rows.
    

    
    
    temp14 = sy-tabix.
    READ TABLE lt_rows INDEX 1 INTO temp13.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    SPLIT temp13 AT ';' INTO TABLE lt_cols.

    
    
    LOOP AT lt_cols REFERENCE INTO lr_col.

      
      lv_name = c_trim_upper( lr_col->* ).
      REPLACE ` ` IN lv_name WITH `_`.

      
      CLEAR temp59.
      temp59-name = lv_name.
      temp59-type = cl_abap_elemdescr=>get_c( 40 ).
      INSERT temp59 INTO TABLE lt_comp.
    ENDLOOP.

    
    struc = cl_abap_structdescr=>get( lt_comp ).
    
    temp60 ?= struc.
    
    data = temp60.
    
    o_table_desc = cl_abap_tabledescr=>create( p_line_type  = data
                                                     p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                     p_unique     = abap_false ).

    CREATE DATA result TYPE HANDLE o_table_desc.
    ASSIGN result->* TO <tab>.
    DELETE lt_rows WHERE table_line IS INITIAL.

    
    
    LOOP AT lt_rows REFERENCE INTO lr_rows FROM 2.

      SPLIT lr_rows->* AT ';' INTO TABLE lt_cols.
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
        DATA temp62 TYPE REF TO z2ui5_if_ajson.
        DATA li_ajson LIKE temp62.
        DATA x TYPE REF TO cx_root.
    TRY.

        
        temp62 ?= z2ui5_cl_ajson=>create_empty( ).
        
        li_ajson = temp62.
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
        DATA temp63 TYPE REF TO cl_abap_refdescr.
        DATA lo_ref LIKE temp63.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        
        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).
        
        temp63 ?= lo_typdescr.
        
        lo_ref = temp63.
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
    DATA temp64 TYPE REF TO cl_abap_refdescr.
    DATA ref LIKE temp64.
    DATA name TYPE abap_abstypename.
    rtti = cl_abap_typedescr=>describe_by_data( in  ).
    
    temp64 ?= rtti.
    
    ref = temp64.
    
    name = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name
                              sub = `\INTERFACE=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA temp65 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp65.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.
    TRY.

        
        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).
        
        temp65 ?= lo_descr.
        
        lo_ele = temp65.
        result = lo_ele->get_relative_name( ).

        
      CATCH cx_root INTO x.
        
        lv_error = x->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_get_t_attri_by_include.
        DATA type_desc TYPE REF TO cl_abap_typedescr.
        DATA x TYPE REF TO cx_root.
    DATA temp66 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp66.
    DATA comps TYPE abap_component_tab.
    DATA temp67 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp67.
        DATA incl_comps TYPE abap_component_tab.
        DATA temp68 LIKE LINE OF incl_comps.
        DATA lr_incl_comp LIKE REF TO temp68.

    TRY.

        
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                             RECEIVING  p_descr_ref    = type_desc
                                             EXCEPTIONS type_not_found = 1 ).

        
      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.
    
    temp66 ?= type_desc.
    
    sdescr = temp66.
    
    comps = sdescr->get_components( ).

    
    
    LOOP AT comps REFERENCE INTO lr_comp.

      IF lr_comp->as_include = abap_true.

        
        incl_comps = rtti_get_t_attri_by_include( lr_comp->type ).

        
        
        LOOP AT incl_comps REFERENCE INTO lr_incl_comp.
          lr_incl_comp->name = lr_incl_comp->name.
          APPEND lr_incl_comp->* TO result.
        ENDLOOP.

      ELSE.

        lr_comp->name = lr_comp->name.
        APPEND lr_comp->* TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_oref.

    DATA lo_obj_ref TYPE REF TO cl_abap_typedescr.
    DATA temp69 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).
    
    temp69 ?= lo_obj_ref.
    result = temp69->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_any.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp70 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp70.
            DATA temp71 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp71.
            DATA temp72 TYPE REF TO cl_abap_structdescr.
                DATA lo_ref TYPE REF TO cl_abap_typedescr.
                DATA temp73 TYPE REF TO cl_abap_structdescr.
                    DATA temp74 TYPE REF TO cl_abap_tabledescr.
                    DATA temp75 TYPE REF TO cl_abap_structdescr.
    DATA comps TYPE abap_component_tab.
    DATA temp76 LIKE LINE OF comps.
    DATA lr_comp LIKE REF TO temp76.
        DATA lt_attri TYPE abap_component_tab.

    TRY.
        
        lo_type = cl_abap_typedescr=>describe_by_data( val ).
        
        temp70 ?= lo_type.
        
        lo_struct = temp70.
      CATCH cx_root.
        TRY.
            
            temp71 ?= lo_type.
            
            lo_tab = temp71.
            
            temp72 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp72.
          CATCH cx_root.
            TRY.
                
                lo_ref = cl_abap_typedescr=>describe_by_data_ref( val ).
                
                temp73 ?= lo_ref.
                lo_struct = temp73.
              CATCH cx_root.
                TRY.
                    
                    temp74 ?= lo_ref.
                    lo_tab = temp74.
                    
                    temp75 ?= lo_tab->get_table_line_type( ).
                    lo_struct = temp75.
                  CATCH cx_root.
                    lo_struct ?= cl_abap_structdescr=>describe_by_name( val ).
                ENDTRY.
            ENDTRY.
        ENDTRY.
    ENDTRY.

    
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
        DATA temp77 TYPE string.
        DATA typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp78 TYPE REF TO cl_abap_elemdescr.
        DATA elemdescr LIKE temp78.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    IF rollname IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        
        temp77 = rollname.
        
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = temp77
                                             RECEIVING  p_descr_ref    = typedescr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        
        temp78 ?= typedescr.
        
        elemdescr = temp78.

        result = rtti_get_t_fixvalues( elemdescr = elemdescr
                                       langu     = langu ).

        
      CATCH cx_root INTO x.
        
        lv_error = x->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_tab_get_relative_name.

    FIELD-SYMBOLS <table> TYPE any.
        DATA typedesc TYPE REF TO cl_abap_typedescr.
            DATA temp79 TYPE REF TO cl_abap_tabledescr.
            DATA tabledesc LIKE temp79.
            DATA temp80 TYPE REF TO cl_abap_structdescr.
            DATA structdesc LIKE temp80.
        DATA x TYPE REF TO cx_root.
        DATA lv_error TYPE string.

    TRY.
        
        typedesc = cl_abap_typedescr=>describe_by_data( table ).

        CASE typedesc->kind.

          WHEN cl_abap_typedescr=>kind_table.
            
            temp79 ?= typedesc.
            
            tabledesc = temp79.
            
            temp80 ?= tabledesc->get_table_line_type( ).
            
            structdesc = temp80.
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
    SPLIT lv_types AT ',' INTO TABLE result.

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

    DATA temp81 TYPE string.
    DATA lv_sql LIKE temp81.
    DATA lv_dummy TYPE string.
    DATA lv_tab TYPE string.
    temp81 = val.
    
    lv_sql = temp81.
    REPLACE ALL OCCURRENCES OF ` ` IN lv_sql WITH ``.
    lv_sql = to_upper( lv_sql ).
    
    
    SPLIT lv_sql AT 'SELECTFROM' INTO lv_dummy lv_tab.
    SPLIT lv_tab AT `FIELDS` INTO lv_tab lv_dummy.

    result-tabname = lv_tab.

  ENDMETHOD.


  METHOD time_get_date_by_stampl.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_dummy TYPE t.
    CONVERT TIME STAMP val TIME ZONE sy-zonlo INTO DATE result TIME lv_dummy.
  ENDMETHOD.


  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD time_get_time_by_stampl.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_dummy TYPE d.
    CONVERT TIME STAMP val TIME ZONE sy-zonlo INTO DATE lv_dummy TIME result.
  ENDMETHOD.


  METHOD time_substract_seconds.

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
    DATA temp82 TYPE string.
    DATA temp83 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).
    
    lv_val = c_trim_lower( val ).
    
    CLEAR temp82.
    
    READ TABLE lt_params INTO temp83 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp82 = temp83-v.
    ENDIF.
    result = temp82.

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA lv_search TYPE string.
    DATA lv_search2 TYPE string.
    DATA temp84 TYPE string.
    TYPES temp3 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp3.
    DATA temp85 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp85.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp86 TYPE z2ui5_cl_util=>ty_s_name_value.
    lv_search = replace( val  = i_val
                               sub  = `%3D`
                               with = '='
                               occ  = 0 ).

    lv_search = replace( val  = lv_search
                         sub  = `%26`
                         with = '&'
                         occ  = 0 ).

    lv_search = shift_left( val = lv_search
                            sub = `?` ).
*    lv_search = c_trim_lower( lv_search ).

    
    lv_search2 = substring_after( val = lv_search
                                        sub = `&sap-startup-params=` ).
    
    IF lv_search2 IS NOT INITIAL.
      temp84 = lv_search2.
    ELSE.
      temp84 = lv_search.
    ENDIF.
    lv_search = temp84.

    lv_search2 = substring_after( val = c_trim_lower( lv_search )
                                  sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.

    

    SPLIT lv_search AT `&` INTO TABLE lt_param.

    
    
    LOOP AT lt_param REFERENCE INTO lr_param.
      
      
      SPLIT lr_param->* AT `=` INTO lv_name lv_value.
*      INSERT VALUE #( n = c_trim_lower( lv_name )
*                      v = c_trim_lower( lv_value ) ) INTO TABLE rt_params.
      
      CLEAR temp86.
      temp86-n = lv_name.
      temp86-v = lv_value.
      INSERT temp86 INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.


  METHOD url_param_set.

    DATA lt_params TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA lv_n TYPE string.
    DATA temp87 LIKE LINE OF lt_params.
    DATA lr_params LIKE REF TO temp87.
      DATA temp88 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).
    
    lv_n = c_trim_lower( name ).

    
    
    LOOP AT lt_params REFERENCE INTO lr_params
         WHERE n = lv_n.
      lr_params->v = c_trim_lower( value ).
    ENDLOOP.
    IF sy-subrc <> 0.
      
      CLEAR temp88.
      temp88-n = lv_n.
      temp88-v = c_trim_lower( value ).
      INSERT temp88 INTO TABLE lt_params.
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

    
    CALL METHOD srtti->('GET_RTTI')
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

    IF rtti_check_class_exists( 'ZCL_SRTTI_TYPEDESCR' ) = abap_true.

      
      
      lv_classname = `ZCL_SRTTI_TYPEDESCR`.
      CALL METHOD (lv_classname)=>('CREATE_BY_DATA_OBJECT')
        EXPORTING
          data_object = data
        RECEIVING
          srtti       = srtti.
      CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

    ELSE.

      TRY.
          CALL METHOD z2ui5_cl_srt_typedescr=>('CREATE_BY_DATA_OBJECT')
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
        DATA temp89 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp89.
            DATA temp90 TYPE REF TO cl_abap_tabledescr.
            DATA lo_tab LIKE temp90.
            DATA temp91 TYPE REF TO cl_abap_structdescr.
    DATA temp92 LIKE LINE OF result.
    DATA lr_comp LIKE REF TO temp92.
      DATA lt_attri TYPE abap_component_tab.

    IF table_name IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = 'TABLE_NAME_INITIAL_ERROR'.
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
        
        temp89 ?= lo_obj.
        
        lo_struct = temp89.

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

            
            temp90 ?= lo_obj.
            
            lo_tab = temp90.
            
            temp91 ?= lo_tab->get_table_line_type( ).
            lo_struct = temp91.
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
        DATA lv_lines TYPE i.

    LOOP AT val ASSIGNING <row_in>.

      IF lines( tab ) = 0.
        
        lv_lines = 1.
      ELSE.
        lv_lines = lines( tab ).
      ENDIF.

      INSERT INITIAL LINE INTO tab ASSIGNING <row_out> INDEX lv_lines.
      CLEAR: <row_out>.
      MOVE-CORRESPONDING <row_in> TO <row_out>.

    ENDLOOP.

  ENDMETHOD.


  METHOD itab_get_by_struc.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp93 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp93.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp94 TYPE z2ui5_cl_util=>ty_s_name_value.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).
*    result  = VALUE z2ui5_cl_util=>ty_t_name_value( ).
    
    
    LOOP AT lt_attri REFERENCE INTO lr_attri.

      
      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE z2ui5_cl_util=>rtti_get_type_kind( <component> ).

        WHEN cl_abap_typedescr=>typekind_table.

        WHEN OTHERS.
          
          CLEAR temp94.
          temp94-n = lr_attri->name.
          temp94-v = <component>.
          INSERT temp94 INTO TABLE result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_t_range.

  ENDMETHOD.


  METHOD filter_get_data_by_multi.

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
          DATA temp95 TYPE ty_rscedst.
      DATA lv_fm TYPE c LENGTH 19.


    IF context_check_abap_cloud( ) IS NOT INITIAL.


    ELSE.

      

      


      
      LOOP AT val INTO ls_filter.
        
        LOOP AT ls_filter-t_range INTO ls_range.

          
          CLEAR temp95.
          temp95-fnam = ls_filter-name.
          temp95-sign = ls_range-sign.
          temp95-option = ls_range-option.
          temp95-low = ls_range-low.
          temp95-high = ls_range-high.
          INSERT temp95 INTO TABLE lt_range.

        ENDLOOP.
      ENDLOOP.

*      DATA result TYPE string.
*    DATA lt_where TYPE rsdmd_t_where.
      
      lv_fm = 'RSDS_RANGE_TO_WHERE'.
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

    DATA temp96 TYPE string.
    CASE val.
      WHEN 'E'.
        temp96 = cs_ui5_msg_type-e.
      WHEN 'S'.
        temp96 = cs_ui5_msg_type-s.
      WHEN `W`.
        temp96 = cs_ui5_msg_type-w.
      WHEN OTHERS.
        temp96 = cs_ui5_msg_type-i.
    ENDCASE.
    result = temp96.

  ENDMETHOD.


  METHOD rtti_create_tab_by_name.

    DATA struct_desc TYPE REF TO cl_abap_typedescr.
    DATA temp97 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp97.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    struct_desc = cl_abap_structdescr=>describe_by_name( val ).
    
    temp97 ?= struct_desc.
    
    data_desc = temp97.
    
    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.


  METHOD msg_get.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
    DATA temp98 LIKE LINE OF lt_msg.
    DATA temp99 LIKE sy-tabix.
    lt_msg = msg_get_t( val ).
    
    
    temp99 = sy-tabix.
    READ TABLE lt_msg INDEX 1 INTO temp98.
    sy-tabix = temp99.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    result = temp98.

  ENDMETHOD.


  METHOD rtti_get_data_element_text_l.

    result = z2ui5_cl_util=>rtti_get_data_element_texts( val )-long.

  ENDMETHOD.


  METHOD msg_get_by_msg.

    DATA temp100 TYPE z2ui5_cl_util=>ty_s_msg.
    DATA ls_msg LIKE temp100.
    CLEAR temp100.
    temp100-id = id.
    temp100-no = no.
    temp100-v1 = v1.
    temp100-v2 = v2.
    temp100-v3 = v3.
    temp100-v4 = v4.
    
    ls_msg = temp100.
    result = msg_get( ls_msg ).

  ENDMETHOD.
ENDCLASS.
