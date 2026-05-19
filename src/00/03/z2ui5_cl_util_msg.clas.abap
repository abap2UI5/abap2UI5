CLASS z2ui5_cl_util_msg DEFINITION PUBLIC
  FINAL CREATE PUBLIC.
  PUBLIC SECTION.

    CLASS-METHODS msg_get_text
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

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

    CLASS-METHODS msg_get_by_sy
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS msg_get_collect
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

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
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_util_msg IMPLEMENTATION.

  METHOD msg_get_text.

    DATA(lt_msg) = msg_get( val ).
    IF lt_msg IS NOT INITIAL.
      result = lt_msg[ 1 ]-text.
    ENDIF.

  ENDMETHOD.

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

        IF check_is_rap_struct( val ) = abap_true.
          result = msg_get_rap( val ).
          RETURN.
        ENDIF.

        DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).

        DATA(ls_result) = VALUE z2ui5_cl_util=>ty_s_msg( ).
        LOOP AT lt_attri REFERENCE INTO DATA(ls_attri).
          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO FIELD-SYMBOL(<comp>).

          IF ls_attri->name = `ITEM`.
            lt_tab = msg_get( <comp> ).
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
        TRY.
            DATA(lx) = CAST cx_root( val ).
            ls_result = VALUE #( type = `E` text = lx->get_text( ) ).
            DATA(lt_attri_o) = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
            LOOP AT lt_attri_o REFERENCE INTO DATA(ls_attri_o)
                 WHERE visibility = `U`.
              DATA(lv_name) = ls_attri_o->name.
              ASSIGN val->(lv_name) TO <comp>.
              ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
            ENDLOOP.
            INSERT ls_result INTO TABLE result.
          CATCH cx_root.

            DATA obj TYPE REF TO object.
            obj = val.

            TRY.

                DATA lr_tab TYPE REF TO data.
                CREATE DATA lr_tab TYPE (`if_bali_log=>ty_item_table`).
                ASSIGN lr_tab->* TO FIELD-SYMBOL(<tab2>).

                CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
                  RECEIVING
                    item_table = <tab2>.

                DATA(lt_tab2) = msg_get( <tab2> ).
                INSERT LINES OF lt_tab2 INTO TABLE result.

              CATCH cx_root.

                TRY.

                    CREATE DATA lr_tab TYPE (`BAPIRETTAB`).
                    ASSIGN lr_tab->* TO <tab2>.

                    CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
                      RECEIVING
                        rt_bapiret = <tab2>.

                    lt_tab2 = msg_get( <tab2> ).
                    INSERT LINES OF lt_tab2 INTO TABLE result.

                  CATCH cx_root INTO DATA(lx2).

                    lt_attri_o = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
                    LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                         WHERE visibility = `U`.
                      lv_name = ls_attri_o->name.
                      ASSIGN obj->(lv_name) TO <comp>.
                      ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
                    ENDLOOP.
                    INSERT ls_result INTO TABLE result.

                ENDTRY.
            ENDTRY.
        ENDTRY.

      WHEN OTHERS.

        IF z2ui5_cl_util=>rtti_check_clike( val ).
          INSERT VALUE #( text = val ) INTO TABLE result.
        ENDIF.
    ENDCASE.

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

  METHOD msg_get_by_sy.

    result = msg_get( z2ui5_cl_util=>context_get_sy( ) ).

  ENDMETHOD.

  METHOD msg_get_collect.

    result = concat_lines_of(
      table = VALUE string_table( FOR <r> IN msg_get( val ) ( |- { <r>-text }| ) )
      sep   = cl_abap_char_utilities=>newline ).

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).

    LOOP AT lt_attri REFERENCE INTO DATA(ls_attri).
      IF ls_attri->name = `%MSG` OR ls_attri->name = `%FAIL`.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_attri REFERENCE INTO ls_attri.
      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO FIELD-SYMBOL(<tab>).
      CHECK sy-subrc = 0.
      CHECK z2ui5_cl_util=>rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      TRY.
          DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <tab> ) ).
          DATA(lo_line) = lo_tab->get_table_line_type( ).
          CHECK lo_line->kind = cl_abap_typedescr=>kind_struct.
          DATA(lt_comps) = CAST cl_abap_structdescr( lo_line )->get_components( ).
          LOOP AT lt_comps REFERENCE INTO DATA(ls_comp).
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

    DATA(lv_kind) = z2ui5_cl_util=>rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.

    DATA lv_is_row TYPE abap_bool.

    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO FIELD-SYMBOL(<msg>).
    IF sy-subrc = 0.
      lv_is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        TRY.
            INSERT LINES OF msg_get( <msg> ) INTO TABLE result.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO FIELD-SYMBOL(<fail>).
    IF sy-subrc = 0.
      lv_is_row = abap_true.
      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO FIELD-SYMBOL(<cause>).
      IF sy-subrc = 0.
        DATA lv_cause TYPE i.
        lv_cause = <cause>.
        DATA(lv_text) = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.
        INSERT VALUE #( type = `E` text = lv_text ) INTO TABLE result.
      ENDIF.
    ENDIF.

    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).
    LOOP AT lt_attri REFERENCE INTO DATA(ls_attri).
      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO FIELD-SYMBOL(<tab>).
      CHECK sy-subrc = 0.
      CHECK z2ui5_cl_util=>rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      ASSIGN <tab> TO <ftab>.

      LOOP AT <ftab> ASSIGNING FIELD-SYMBOL(<row>).
        INSERT LINES OF msg_get_rap( val         = <row>
                                     entity_name = ls_attri->name ) INTO TABLE result.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.

    result = SWITCH string( cause
      WHEN 0  THEN `Operation failed`
      WHEN 1  THEN `Entity not found`
      WHEN 2  THEN `Entity is locked`
      WHEN 3  THEN `Authorization failure`
      WHEN 4  THEN `Concurrent modification`
      WHEN 5  THEN `Concurrent modification`
      WHEN 6  THEN `Operation disabled`
      WHEN 7  THEN `Operation forbidden`
      WHEN 8  THEN `Semantic error`
      WHEN 9  THEN `Determination failed`
      WHEN 10 THEN `Permission denied`
      WHEN 11 THEN `Validation failed`
      ELSE         |Operation failed (cause code { cause })| ).

  ENDMETHOD.

ENDCLASS.
