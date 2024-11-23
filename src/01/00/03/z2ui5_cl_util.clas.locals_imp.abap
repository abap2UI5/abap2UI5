CLASS lcl_range_to_sql DEFINITION
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS: BEGIN OF signs,
                 including TYPE string VALUE 'I',
                 excluding TYPE string VALUE 'E',
               END OF signs.

    CONSTANTS: BEGIN OF options,
                 equal                TYPE string VALUE 'EQ',
                 not_equal            TYPE string VALUE 'NE',
                 between              TYPE string VALUE 'BT',
                 not_between          TYPE string VALUE 'NB',
                 contains_pattern     TYPE string VALUE 'CP',
                 not_contains_pattern TYPE string VALUE 'NP',
                 greater_than         TYPE string VALUE 'GT',
                 greater_equal        TYPE string VALUE 'GE',
                 less_equal           TYPE string VALUE 'LE',
                 less_than            TYPE string VALUE 'LT',
               END OF options.

    METHODS constructor
      IMPORTING
        iv_fieldname TYPE clike
        ir_range     TYPE REF TO data.

    METHODS get_sql
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA mv_fieldname TYPE string.
    DATA mr_range     TYPE REF TO data.

    CLASS-METHODS quote
      IMPORTING
        val        TYPE clike
      RETURNING
        VALUE(out) TYPE string.

ENDCLASS.


CLASS lcl_range_to_sql IMPLEMENTATION.
  METHOD constructor.

    mr_range = ir_range.
    mv_fieldname = |{ to_upper( iv_fieldname ) }|.

  ENDMETHOD.

  METHOD get_sql.

    FIELD-SYMBOLS <lt_range> TYPE STANDARD TABLE.

    ASSIGN me->mr_range->* TO <lt_range>.

    IF xsdbool( <lt_range> IS INITIAL ) = abap_true.
      RETURN.
    ENDIF.

    result = `(`.

    LOOP AT <lt_range> ASSIGNING FIELD-SYMBOL(<ls_range_item>).

      ASSIGN COMPONENT 'SIGN' OF STRUCTURE <ls_range_item> TO FIELD-SYMBOL(<lv_sign>).
      ASSIGN COMPONENT 'OPTION' OF STRUCTURE <ls_range_item> TO FIELD-SYMBOL(<lv_option>).
      ASSIGN COMPONENT 'LOW' OF STRUCTURE <ls_range_item> TO FIELD-SYMBOL(<lv_low>).
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <ls_range_item> TO FIELD-SYMBOL(<lv_high>).

      IF sy-tabix <> 1.
        result = |{ result } OR|.
      ENDIF.

      IF <lv_sign> = signs-excluding.
        result = |{ result } NOT|.
      ENDIF.

      result = |{ result } { me->mv_fieldname }|.

      CASE <lv_option>.
        WHEN options-equal OR
             options-not_equal OR
             options-greater_than OR
             options-greater_equal OR
             options-less_equal OR
             options-less_than.
          result = |{ result } { <lv_option> } { quote( <lv_low> ) }|.

        WHEN options-between.
          result = |{ result } BETWEEN { quote( <lv_low> ) } AND { quote( <lv_high> ) }|.

        WHEN options-not_between.
          result = |{ result } NOT BETWEEN { quote( <lv_low> ) } AND { quote( <lv_high> ) }|.

        WHEN options-contains_pattern.
          TRANSLATE <lv_low> USING '*%'.
          result = |{ result } LIKE { quote( <lv_low> ) }|.

        WHEN options-not_contains_pattern.
          TRANSLATE <lv_low> USING '*%'.
          result = |{ result } NOT LIKE { quote( <lv_low> ) }|.
      ENDCASE.
    ENDLOOP.

    result = |{ result } )|.

  ENDMETHOD.

  METHOD quote.
    out = |'{ replace( val  = val
                       sub  = `'`
                       with = `''`
                       occ  = 0 ) }'|.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_msp_mapper DEFINITION
  FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        is_msg        TYPE z2ui5_cl_util=>ty_s_msg
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_s_msg.

    CLASS-METHODS msg_get
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

ENDCLASS.

CLASS lcl_msp_mapper IMPLEMENTATION.

  METHOD msg_get.

    DATA(lv_kind) = z2ui5_cl_util=>rtti_get_type_kind( val ).
    CASE lv_kind.

      WHEN cl_abap_datadescr=>typekind_table.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        ASSIGN val TO <tab>.
        LOOP AT <tab> ASSIGNING FIELD-SYMBOL(<row>).
          DATA(lt_tab) = msg_get( <row> ).
          INSERT LINES OF lt_tab INTO TABLE result.
        ENDLOOP.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).

        DATA(ls_result) = VALUE z2ui5_cl_util=>ty_s_msg( ).
        LOOP AT lt_attri REFERENCE INTO DATA(ls_attri).
          DATA(lv_name) = |VAL-{ ls_attri->name }|.
          ASSIGN (lv_name) TO FIELD-SYMBOL(<comp>).

          IF ls_attri->name = 'ITEM'.
            lt_tab = msg_get( <comp> ).
            INSERT LINES OF lt_tab INTO TABLE result.
            RETURN.
          ELSE.
            ls_result = msg_map( name = ls_attri->name val = <comp> is_msg = ls_result ).
          ENDIF.

        ENDLOOP.
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL.
          MESSAGE ID ls_result-id TYPE 'I' NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        TRY.
            DATA(lx) = CAST cx_root( val ).
            ls_result = VALUE #( type = 'E' text = lx->get_text( ) ).
            DATA(lt_attri_o) = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
            LOOP AT lt_attri_o REFERENCE INTO DATA(ls_attri_o)
                 WHERE visibility = 'U'.
              lv_name = |VAL->{ ls_attri_o->name }|.
              ASSIGN (lv_name) TO <comp>.
              ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
            ENDLOOP.
            INSERT ls_result INTO TABLE result.
          CATCH cx_root.

            DATA obj TYPE REF TO object.
            obj = val.

            TRY.

                DATA lr_tab TYPE REF TO data.
                CREATE DATA lr_tab TYPE ('if_bali_log=>ty_item_table').
                ASSIGN lr_tab->* TO FIELD-SYMBOL(<tab2>).

                CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
                  RECEIVING
                    item_table = <tab2>.

                DATA(lt_tab2) = msg_get( <tab2> ).
                INSERT LINES OF lt_tab2 INTO TABLE result.

              CATCH cx_root.

                TRY.

                    CREATE DATA lr_tab TYPE ('BAPIRETTAB').
                    ASSIGN lr_tab->* TO <tab2>.

                    CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
                      RECEIVING
                        rt_bapiret = <tab2>.

                    lt_tab2 = msg_get( <tab2> ).
                    INSERT LINES OF lt_tab2 INTO TABLE result.

                  CATCH cx_root INTO DATA(lx2).


                    lt_attri_o = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
                    LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                         WHERE visibility = 'U'.
                      lv_name = |OBJ->{ ls_attri_o->name }|.
                      ASSIGN (lv_name) TO <comp>.
                      ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
                    ENDLOOP.
                    INSERT ls_result INTO TABLE result.

                ENDTRY.
            ENDTRY.
        ENDTRY.

      WHEN OTHERS.

        IF z2ui5_cl_util=>rtti_check_clike( val ).
          INSERT VALUE #( text = val
          )
                 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_map.

    result = is_msg.
    CASE name.
      WHEN 'ID' OR 'MSGID'.
        result-id = val.
      WHEN 'NO' OR 'NUMBER' OR 'MSGNO'.
        result-no = val.
      WHEN 'MESSAGE' OR 'TEXT'.
        result-text = val.
      WHEN 'TYPE' OR 'MSGTY'.
        result-type = val.
      WHEN 'MESSAGE_V1' OR 'MSGV1' OR 'V1'.
        result-v1 = val.
      WHEN 'MESSAGE_V2' OR 'MSGV2' OR 'V2'.
        result-v2 = val.
      WHEN 'MESSAGE_V3' OR 'MSGV3' OR 'V3'.
        result-v3 = val.
      WHEN 'MESSAGE_V4' OR 'MSGV4' OR 'V4'.
        result-v4 = val.
      WHEN 'TIME_STMP'.
        result-timestampl = val.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
