CLASS z2ui5_cl_util_msg DEFINITION PUBLIC
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

CLASS z2ui5_cl_util_msg IMPLEMENTATION.
  METHOD msg_get.


    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        FIELD-SYMBOLS <row> TYPE ANY.
          DATA lt_tab TYPE z2ui5_cl_util=>ty_t_msg.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp1 TYPE z2ui5_cl_util=>ty_s_msg.
        DATA ls_result LIKE temp1.
        DATA temp2 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp2.
          DATA lv_name TYPE string.
          FIELD-SYMBOLS <comp> TYPE any.
            DATA temp3 TYPE REF TO cx_root.
            DATA lx LIKE temp3.
            DATA lt_attri_o TYPE abap_attrdescr_tab.
            DATA temp4 LIKE LINE OF lt_attri_o.
            DATA ls_attri_o LIKE REF TO temp4.
            DATA obj TYPE REF TO object.
                DATA lr_tab TYPE REF TO data.
                FIELD-SYMBOLS <tab2> TYPE data.
                DATA lt_tab2 TYPE z2ui5_cl_util=>ty_t_msg.
                    DATA lx2 TYPE REF TO cx_root.
          DATA temp5 TYPE z2ui5_cl_util=>ty_s_msg.
    lv_kind = z2ui5_cl_util=>rtti_get_type_kind( val ).
    CASE lv_kind.

      WHEN cl_abap_datadescr=>typekind_table.
        
        ASSIGN val TO <tab>.
        
        LOOP AT <tab> ASSIGNING <row>.
          
          lt_tab = msg_get( <row> ).
          INSERT LINES OF lt_tab INTO TABLE result.
        ENDLOOP.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        
        lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( val ).

        
        CLEAR temp1.
        
        ls_result = temp1.
        
        
        LOOP AT lt_attri REFERENCE INTO ls_attri.
          
          lv_name = |VAL-{ ls_attri->name }|.
          
          ASSIGN (lv_name) TO <comp>.

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
            
            temp3 ?= val.
            
            lx = temp3.
            CLEAR ls_result.
            ls_result-type = 'E'.
            ls_result-text = lx->get_text( ).
            
            lt_attri_o = z2ui5_cl_util=>rtti_get_t_attri_by_oref( val ).
            
            
            LOOP AT lt_attri_o REFERENCE INTO ls_attri_o
                 WHERE visibility = 'U'.
              lv_name = |VAL->{ ls_attri_o->name }|.
              ASSIGN (lv_name) TO <comp>.
              ls_result = msg_map( name = ls_attri_o->name val = <comp> is_msg = ls_result ).
            ENDLOOP.
            INSERT ls_result INTO TABLE result.
          CATCH cx_root.

            
            obj = val.

            TRY.

                
                CREATE DATA lr_tab TYPE ('if_bali_log=>ty_item_table').
                
                ASSIGN lr_tab->* TO <tab2>.

                CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
                  RECEIVING
                    item_table = <tab2>.

                
                lt_tab2 = msg_get( <tab2> ).
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

                    
                  CATCH cx_root INTO lx2.


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

        IF z2ui5_cl_util=>rtti_check_clike( val ) IS NOT INITIAL.
          
          CLEAR temp5.
          temp5-text = val.
          INSERT temp5
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
