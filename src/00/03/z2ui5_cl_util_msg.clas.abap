CLASS z2ui5_cl_util_msg DEFINITION PUBLIC
  FINAL CREATE PUBLIC.
  PUBLIC SECTION.

    CLASS-METHODS msg_get_text
      IMPORTING
        val           TYPE any
        val2          TYPE any OPTIONAL
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
        val2          TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS msg_get_by_sy
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS msg_get_collect
      IMPORTING
        val           TYPE any
        val2          TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    CLASS-METHODS msg_get_internal
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

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
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_name_value.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_util_msg IMPLEMENTATION.

  METHOD msg_get_text.

    DATA lt_msg TYPE z2ui5_cl_util=>ty_t_msg.
      DATA temp74 LIKE LINE OF lt_msg.
      DATA temp75 LIKE sy-tabix.
    lt_msg = msg_get( val = val val2 = val2 ).
    IF lt_msg IS NOT INITIAL.


      temp75 = sy-tabix.
      READ TABLE lt_msg INDEX 1 INTO temp74.
      sy-tabix = temp75.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result = temp74-text.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get.

    result = msg_get_internal( val ).
    IF result IS INITIAL AND val2 IS NOT INITIAL.
      result = msg_get_internal( val2 ).
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_internal.

    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        FIELD-SYMBOLS <row> TYPE ANY.
          DATA lt_tab TYPE z2ui5_cl_util=>ty_t_msg.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp76 TYPE z2ui5_cl_util=>ty_s_msg.
        DATA ls_result LIKE temp76.
        DATA temp77 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp77.
          FIELD-SYMBOLS <comp> TYPE any.
            DATA temp78 TYPE REF TO cx_root.
            DATA lx LIKE temp78.
            DATA lt_attri_o TYPE abap_attrdescr_tab.
            DATA temp79 LIKE LINE OF lt_attri_o.
            DATA ls_attri_o LIKE REF TO temp79.
              DATA lv_name LIKE ls_attri_o->name.
            DATA obj TYPE REF TO object.
                DATA lr_tab TYPE REF TO data.
                FIELD-SYMBOLS <tab2> TYPE data.
                DATA lt_tab2 TYPE z2ui5_cl_util=>ty_t_msg.
                    DATA lx2 TYPE REF TO cx_root.
          DATA temp80 TYPE z2ui5_cl_util=>ty_s_msg.
    lv_kind = z2ui5_cl_util=>rtti_get_type_kind( val ).
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


        lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


        CLEAR temp76.

        ls_result = temp76.


        LOOP AT lt_attri REFERENCE INTO ls_attri.

          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.

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
        TRY.

            temp78 ?= val.

            lx = temp78.
            CLEAR ls_result.
            ls_result-type = `E`.
            ls_result-text = lx->get_text( ).

            lt_attri_o = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).


            LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                 WHERE visibility = `U`.

              lv_name = ls_attri_o->name.
              ASSIGN val->(lv_name) TO <comp>.
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


                  CATCH cx_root INTO lx2.

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

        IF z2ui5_cl_util=>rtti_check_clike( val ) IS NOT INITIAL.

          CLEAR temp80.
          temp80-text = val.
          INSERT temp80 INTO TABLE result.
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

    DATA temp81 TYPE string_table.
    DATA temp5 TYPE z2ui5_cl_util=>ty_t_msg.
    FIELD-SYMBOLS <r> LIKE LINE OF temp5.
      DATA temp6 LIKE LINE OF temp81.
    CLEAR temp81.

    temp5 = msg_get( val = val val2 = val2 ).

    LOOP AT temp5 ASSIGNING <r>.

      temp6 = |- { <r>-text }|.
      INSERT temp6 INTO TABLE temp81.
    ENDLOOP.
    result = concat_lines_of(
      table = temp81
      sep   = cl_abap_char_utilities=>newline ).

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp83 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp83.
      FIELD-SYMBOLS <tab> TYPE any.
          DATA temp84 TYPE REF TO cl_abap_tabledescr.
          DATA lo_tab LIKE temp84.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp85 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp86 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp86.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).



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
      CHECK z2ui5_cl_util=>rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      TRY.

          temp84 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

          lo_tab = temp84.

          lo_line = lo_tab->get_table_line_type( ).
          CHECK lo_line->kind = cl_abap_typedescr=>kind_struct.

          temp85 ?= lo_line.

          lt_comps = temp85->get_components( ).


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
    DATA lt_meta TYPE z2ui5_cl_util=>ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE z2ui5_cl_util=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp87 TYPE z2ui5_cl_util=>ty_s_msg.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp88 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp88.
      FIELD-SYMBOLS <tab> TYPE any.
      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      FIELD-SYMBOLS <row> TYPE ANY.
    lv_kind = z2ui5_cl_util=>rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.




    lt_meta = msg_get_rap_meta( val ).


    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO <msg>.
    IF sy-subrc = 0.
      lv_is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        TRY.

            lt_one = msg_get( <msg> ).

            LOOP AT lt_one ASSIGNING <m>.
              <m>-t_meta = lt_meta.
            ENDLOOP.
            INSERT LINES OF lt_one INTO TABLE result.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO <fail>.
    IF sy-subrc = 0.
      lv_is_row = abap_true.

      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
      IF sy-subrc = 0.

        lv_cause = <cause>.

        lv_text = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.

        CLEAR temp87.
        temp87-type = `E`.
        temp87-text = lv_text.
        temp87-t_meta = lt_meta.
        INSERT temp87 INTO TABLE result.
      ENDIF.
    ENDIF.

    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.


    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK z2ui5_cl_util=>rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.


      ASSIGN <tab> TO <ftab>.


      LOOP AT <ftab> ASSIGNING <row>.
        IF z2ui5_cl_util=>rtti_get_type_kind( <row> ) = cl_abap_datadescr=>typekind_oref.
          IF <row> IS NOT INITIAL.
            TRY.
                INSERT LINES OF msg_get( <row> ) INTO TABLE result.
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

  METHOD msg_get_rap_element.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp89 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp89.
      FIELD-SYMBOLS <flag> TYPE any.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


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
    DATA temp90 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp90.
      FIELD-SYMBOLS <flag> TYPE any.
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


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
    DATA temp91 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp91.
      FIELD-SYMBOLS <comp> TYPE any.
      DATA lv_sub_kind TYPE string.
        DATA lv_sub TYPE string.
              DATA lv_str TYPE string.
    lv_kind = z2ui5_cl_util=>rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
       AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
      CHECK sy-subrc = 0.


      lv_sub_kind = z2ui5_cl_util=>rtti_get_type_kind( <comp> ).
      IF lv_sub_kind = cl_abap_datadescr=>typekind_struct1
         OR lv_sub_kind = cl_abap_datadescr=>typekind_struct2.

        lv_sub = msg_get_rap_flatten( <comp> ).
        IF lv_sub IS NOT INITIAL.
          IF result IS NOT INITIAL.
            result = |{ result }, |.
          ENDIF.
          result = |{ result }{ lv_sub }|.
        ENDIF.
      ELSE.
        IF <comp> IS NOT INITIAL.
          TRY.

              lv_str = <comp>.
              IF result IS NOT INITIAL.
                result = |{ result }, |.
              ENDIF.
              result = |{ result }{ ls_attri->name }={ lv_str }|.
            CATCH cx_root ##NO_HANDLER.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_meta.

    DATA lv TYPE string.
      DATA temp92 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp93 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp94 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp95 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp96 TYPE z2ui5_cl_util=>ty_s_name_value.
      DATA temp97 TYPE z2ui5_cl_util=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp92.
      temp92-n = `element`.
      temp92-v = lv.
      INSERT temp92 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp93.
      temp93-n = `state_area`.
      temp93-v = lv.
      INSERT temp93 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp94.
      temp94-n = `action`.
      temp94-v = lv.
      INSERT temp94 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp95.
      temp95-n = `pid`.
      temp95-v = lv.
      INSERT temp95 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp96.
      temp96-n = `cid`.
      temp96-v = lv.
      INSERT temp96 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp97.
      temp97-n = `tky`.
      temp97-v = lv.
      INSERT temp97 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.

    DATA temp98 TYPE string.
    CASE cause.
      WHEN 0.
        temp98 = `Operation failed`.
      WHEN 1.
        temp98 = `Entity not found`.
      WHEN 2.
        temp98 = `Entity is locked`.
      WHEN 3.
        temp98 = `Authorization failure`.
      WHEN 4.
        temp98 = `Concurrent modification`.
      WHEN 5.
        temp98 = `Concurrent modification`.
      WHEN 6.
        temp98 = `Operation disabled`.
      WHEN 7.
        temp98 = `Operation forbidden`.
      WHEN 8.
        temp98 = `Semantic error`.
      WHEN 9.
        temp98 = `Determination failed`.
      WHEN 10.
        temp98 = `Permission denied`.
      WHEN 11.
        temp98 = `Validation failed`.
      WHEN OTHERS.
        temp98 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp98.

  ENDMETHOD.

ENDCLASS.
