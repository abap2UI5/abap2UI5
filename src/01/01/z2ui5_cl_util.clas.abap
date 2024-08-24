CLASS z2ui5_cl_util DEFINITION
  PUBLIC
  CREATE PUBLIC
  INHERITING FROM z2ui5_cl_stmpncfctn_api.

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
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH EMPTY KEY.

    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        type          TYPE REF TO cl_abap_datadescr
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

    CLASS-METHODS url_param_get
      IMPORTING
        !val          TYPE string
        !url          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        !t_params     TYPE z2ui5_if_types=>ty_t_name_value
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
        !v    TYPE clike DEFAULT `CX_SY_SUBRC`
        !when TYPE xfeld.

    CLASS-METHODS x_raise
      IMPORTING
        !v TYPE clike DEFAULT `CX_SY_SUBRC`
          PREFERRED PARAMETER v.

    CLASS-METHODS user_get_tech
      RETURNING
        VALUE(result) TYPE string.

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
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_abap_2_json
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS json_parse
      IMPORTING
        !val  TYPE any
      CHANGING
        !data TYPE any.

    CLASS-METHODS c_trim_upper
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_stringify
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_parse
      IMPORTING
        !rtti_data    TYPE clike
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
        VALUE(rt_params) TYPE z2ui5_if_types=>ty_t_name_value.

    CLASS-METHODS rtti_get_t_attri_by_oref
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_t_attri_by_table_name
      IMPORTING
        table_name    TYPE any
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
        VALUE(result) TYPE z2ui5_if_types=>ty_t_name_value.

    CLASS-METHODS itab_filter_by_val
      IMPORTING
        val TYPE clike
      CHANGING
        tab TYPE STANDARD TABLE.

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

    CLASS-METHODS rtti_tab_get_relative_name
      IMPORTING
        !table        TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS check_raise_srtti_installed.

    CLASS-METHODS get_comps_by_data
      IMPORTING !data         TYPE REF TO data
      RETURNING VALUE(result) TYPE abap_component_tab ##NEEDED.

    CLASS-METHODS get_comp_by_struc
      IMPORTING !type         TYPE REF TO cl_abap_datadescr
      RETURNING VALUE(result) TYPE abap_component_tab ##NEEDED.

    CLASS-METHODS db_delete_by_handle
      IMPORTING
        !uname        TYPE clike OPTIONAL
        !handle       TYPE clike OPTIONAL
        !handle2      TYPE clike OPTIONAL
        !handle3      TYPE clike OPTIONAL
        !check_commit TYPE abap_bool DEFAULT abap_true.

    CLASS-METHODS db_save
      IMPORTING
        !uname        TYPE clike OPTIONAL
        !handle       TYPE clike OPTIONAL
        !handle2      TYPE clike OPTIONAL
        !handle3      TYPE clike OPTIONAL
        !data         TYPE any
        !check_commit TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS db_load_by_id
      IMPORTING
        !id           TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    CLASS-METHODS db_load_by_handle
      IMPORTING
        !uname        TYPE clike OPTIONAL
        !handle       TYPE clike OPTIONAL
        !handle2      TYPE clike OPTIONAL
        !handle3      TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

  PROTECTED SECTION.

  PRIVATE SECTION.


ENDCLASS.



CLASS z2ui5_cl_util IMPLEMENTATION.


  METHOD db_delete_by_handle.

    DELETE FROM z2ui5_t_02
        WHERE
           uname = @uname
            AND handle = @handle
            AND handle2 = @handle2
            AND handle3 = @handle3.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD db_load_by_handle.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_02
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `No entry for handle exists`.
    ENDIF.

    DATA(ls_db) = lt_db[ 1 ].

    xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_02
      WHERE id = @id
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.
    ASSERT sy-subrc = 0.

    DATA(ls_db) = lt_db[ 1 ].

    xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_save.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_02 WITH EMPTY KEY.
    SELECT id
      FROM z2ui5_t_02
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db ##SUBRC_OK.

    DATA(ls_db) = VALUE z2ui5_t_02(
        uname   = uname
        handle  = handle
        handle2 = handle2
        handle3 = handle3
        data    = xml_stringify( data ) ).

    TRY.
        ls_db-id = lt_db[ 1 ]-id.
      CATCH cx_root.
        ls_db-id = uuid_get_c32( ).
    ENDTRY.

    MODIFY z2ui5_t_02 FROM @ls_db.
    ASSERT sy-subrc = 0.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

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
          OR 'BOOLE_D'
          OR 'OS_BOOLEAN'.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD check_bound_a_not_inital.

    IF val IS NOT BOUND.
      result = abap_false.
      RETURN.
    ENDIF.
    result = xsdbool( check_unassign_inital( val ) = abap_false ).

  ENDMETHOD.


  METHOD check_unassign_inital.

    IF val IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.

    FIELD-SYMBOLS <any> TYPE data.
    ASSIGN val->* TO <any>.

    result = xsdbool( <any> IS INITIAL ).

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


  METHOD conv_get_as_data_ref.

    GET REFERENCE OF val INTO result.

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


  METHOD filter_get_multi_by_data.

    LOOP AT rtti_get_t_attri_by_any( val ) REFERENCE INTO DATA(lr_comp).
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
        ASSERT sy-subrc = 0.
        <field> = lr_col->*.
      ENDLOOP.

      INSERT <row> INTO TABLE <tab>.
    ENDLOOP.

  ENDMETHOD.


  METHOD json_parse.
    TRY.

        z2ui5_cl_ajson=>parse( val )->to_abap(
          EXPORTING
          iv_corresponding = abap_true
          IMPORTING
            ev_container = data ).

      CATCH z2ui5_cx_ajson_error INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD json_stringify.
    TRY.

        DATA(li_ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
        result = li_ajson->set( iv_path = `/` iv_val = any )->stringify( ).

      CATCH z2ui5_cx_ajson_error INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD rtti_check_class_exists.

    TRY.
        cl_abap_classdescr=>describe_by_name(
          EXPORTING
            p_name        = val
          EXCEPTIONS
           type_not_found = 1 ).
        IF sy-subrc = 0.
          result = abap_true.
        ENDIF.

      CATCH cx_root.
        " cx_sy_rtti_syntax_error
    ENDTRY.

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
        DATA(lo_typdescr) = cl_abap_typedescr=>describe_by_data( val ).
        DATA(lo_ref) = CAST cl_abap_refdescr( lo_typdescr ) ##NEEDED.
        result = abap_true.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD rtti_check_type_kind_dref.

    DATA(lv_type_kind) = cl_abap_datadescr=>get_data_type_kind( val ).
    result = xsdbool( lv_type_kind = cl_abap_typedescr=>typekind_dref ).

  ENDMETHOD.


  METHOD rtti_get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD rtti_get_intfname_by_ref.

    DATA(rtti) = cl_abap_typedescr=>describe_by_data(  in  ).
    DATA(ref) = CAST cl_abap_refdescr( rtti ).
    DATA(name) = ref->get_referenced_type( )->absolute_name.
    result = substring_after( val = name sub = `\INTERFACE=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.

    DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).
    DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
    result  = lo_ele->get_relative_name( ).

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_include.

    DATA(sdescr) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( type->absolute_name ) ).

    DATA(comps) = sdescr->get_components( ).

    LOOP AT comps REFERENCE INTO DATA(lr_comp).

      IF lr_comp->as_include = abap_true.

        DATA(incl_comps) = rtti_get_t_attri_by_include( lr_comp->type ).

        LOOP AT incl_comps REFERENCE INTO DATA(lr_incl_comp).

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

    DATA(lo_obj_ref) = cl_abap_objectdescr=>describe_by_object_ref( val ).
    result = CAST cl_abap_classdescr( lo_obj_ref )->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_any.

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

    LOOP AT result REFERENCE INTO DATA(lr_comp)
        WHERE as_include = abap_true.

      DATA(lt_attri) = rtti_get_t_attri_by_include( lr_comp->type ).

      DELETE result.
      INSERT LINES OF lt_attri INTO TABLE result.
    ENDLOOP.

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

        DATA(elemdescr) = CAST cl_abap_elemdescr( typedescr ) ##NEEDED.


        TYPES:
          BEGIN OF fixvalue,
            low        TYPE c LENGTH 10,
            high       TYPE c LENGTH 10,
            option     TYPE c LENGTH 2,
            ddlanguage TYPE c LENGTH 1,
            ddtext     TYPE c LENGTH 60,
          END OF fixvalue.
        TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH EMPTY KEY.
        DATA lt_values TYPE fixvalues.

        CALL METHOD ELEMDESCR->('GET_DDIC_FIXED_VALUES')
          EXPORTING
            p_langu        = langu
          RECEIVING
            p_fixed_values = lt_values
          EXCEPTIONS
            not_found      = 1
            no_ddic_type   = 2
            OTHERS         = 3.

*        elemdescr->get_ddic_fixed_values( EXPORTING  p_langu        = langu
*                                          RECEIVING  p_fixed_values = DATA(lt_values)
*                                          EXCEPTIONS not_found      = 1
*                                                     no_ddic_type   = 2
*                                                     OTHERS         = 3 ).


        LOOP AT lt_values REFERENCE INTO DATA(lr_fix).

          INSERT VALUE #( low   = lr_fix->low
                          high  = lr_fix->high
                          descr = lr_fix->ddtext )
                 INTO TABLE result.

        ENDLOOP.

      CATCH cx_root.
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
      CATCH cx_root.
    ENDTRY.

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


  METHOD source_get_method2.

    DATA(lt_source) = source_get_method(
         iv_classname  = iv_classname
         iv_methodname = iv_methodname ).

    result = source_method_to_file( lt_source ).

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

    lv_search = replace( val  = lv_search
                               sub  = `%26`
                               with = '&'
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


  METHOD xml_parse.

    CALL TRANSFORMATION id
        SOURCE XML xml
        RESULT data = any.

  ENDMETHOD.


  METHOD xml_srtti_parse.

    check_raise_srtti_installed( ).

    DATA srtti TYPE REF TO object.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.

    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    CALL METHOD srtti->('GET_RTTI')
      RECEIVING
        rtti = rtti_type.

    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
    lo_datadescr ?= rtti_type.

    CREATE DATA result TYPE HANDLE lo_datadescr.
    ASSIGN result->* TO FIELD-SYMBOL(<variable>).
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.

  ENDMETHOD.


  METHOD xml_srtti_stringify.

    check_raise_srtti_installed( ).

    DATA srtti TYPE REF TO object.
    DATA(lv_classname) = 'ZCL_SRTTI_TYPEDESCR'.
    CALL METHOD (lv_classname)=>('CREATE_BY_DATA_OBJECT')
      EXPORTING
        data_object = data
      RECEIVING
        srtti       = srtti.

    CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

  ENDMETHOD.


  METHOD xml_stringify.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD x_check_raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.
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

    RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.

  ENDMETHOD.

  METHOD check_raise_srtti_installed.

    IF rtti_check_class_exists( 'ZCL_SRTTI_TYPEDESCR' ) = abap_false.

      DATA(lv_link) = `https://github.com/sandraros/S-RTTI`.
      DATA(lv_text) = `<p>Please install the open-source project S-RTTI by sandraros and try again: <a href="` &&
                       lv_link && `" style="color:blue; font-weight:600;" target="_blank">(link)</a></p>`.

      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = lv_text.

    ENDIF.

  ENDMETHOD.


  METHOD get_comps_by_data.

*    TRY.
*        FIELD-SYMBOLS <any> type any.
*        ASSign data->* to <any>.
*        DATA(typedesc) = cl_abap_typedescr=>describe_by_data( data->* ).
*
*        CASE typedesc->kind.
*
*          WHEN cl_abap_typedescr=>kind_table.
*
*            DATA(tabledesc) = CAST cl_abap_tabledescr( typedesc ).
*            DATA(structdesc) = CAST cl_abap_structdescr( tabledesc->get_table_line_type( ) ).
*
*          WHEN cl_abap_typedescr=>kind_struct.
*
*            structdesc = CAST cl_abap_structdescr( typedesc ).
*
*          WHEN OTHERS.
*        ENDCASE.
*
*        DATA(comp) = structdesc->get_components( ).
*
*        LOOP AT comp INTO DATA(com).
*
*          IF com-as_include = abap_true.
*            APPEND LINES OF get_comp_by_struc( com-type ) TO result.
*          ELSE.
*            APPEND com TO result.
*          ENDIF.
*
*        ENDLOOP.
*
*      CATCH cx_root.
*    ENDTRY.

  ENDMETHOD.


  METHOD get_comp_by_struc.

*    DATA struc TYPE REF TO cl_abap_structdescr.
*    struc ?= type.
*    DATA(comp) = struc->get_components( ).
*    LOOP AT comp INTO DATA(com).
*
*      IF com-as_include = abap_true.
*        APPEND LINES OF get_comp_by_struc( com-type ) TO result.
*      ELSE.
*        APPEND com TO result.
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_table_name.

    TRY.
        DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( table_name ) ).
      CATCH cx_root.

        TRY.
            DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_structdescr=>describe_by_name( table_name ) ).
            lo_struct = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
          CATCH cx_root.
            RETURN.
        ENDTRY.

    ENDTRY.

    result = lo_struct->get_components( ).

    LOOP AT result REFERENCE INTO DATA(lr_comp)
         WHERE as_include = abap_true.

      DATA(lt_attri) = rtti_get_t_attri_by_include( lr_comp->type ).

      DELETE result.
      INSERT LINES OF lt_attri INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
