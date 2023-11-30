class Z2UI5_CL_UTIL_FUNC definition
  public
  create public .

public section.

  class-methods APP_GET_URL_SOURCE_CODE
    importing
      !CLIENT type ref to Z2UI5_IF_CLIENT
    returning
      value(RESULT) type STRING .
  class-methods APP_GET_URL
    importing
      !CLIENT type ref to Z2UI5_IF_CLIENT
      value(CLASSNAME) type STRING optional
    returning
      value(RESULT) type STRING .
  class-methods URL_PARAM_GET
    importing
      !VAL type STRING
      !URL type STRING
    returning
      value(RESULT) type STRING .
  class-methods URL_PARAM_CREATE_URL
    importing
      !T_PARAMS type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE
    returning
      value(RESULT) type STRING .
  class-methods URL_PARAM_SET
    importing
      !URL type STRING
      !NAME type STRING
      !VALUE type STRING
    returning
      value(RESULT) type STRING .
  class-methods RTTI_GET_CLASSNAME_BY_REF
    importing
      !IN type ref to OBJECT
    returning
      value(RESULT) type STRING .
  class-methods X_CHECK_RAISE
    importing
      !V type CLIKE default `CX_SY_SUBRC`
      !WHEN type ABAP_BOOL .
  class-methods X_RAISE
    importing
      !V type CLIKE default `CX_SY_SUBRC`
    preferred parameter V .
  class-methods FUNC_GET_UUID_32
    returning
      value(RESULT) type STRING .
  class-methods FUNC_GET_UUID_22
    returning
      value(RESULT) type STRING .
  class-methods FUNC_GET_USER_TECH
    returning
      value(RESULT) type STRING .
  class-methods TRANS_JSON_ANY_2
    importing
      !ANY type ANY
      !PRETTY_NAME type CLIKE default /UI2/CL_JSON=>PRETTY_MODE-NONE
    returning
      value(RESULT) type STRING .
  class-methods TRANS_XML_2_ANY
    importing
      !XML type CLIKE
    exporting
      !ANY type ANY .
  class-methods TRANS_XML_ANY_2
    importing
      !ANY type ANY
    returning
      value(RESULT) type STRING
    raising
      CX_XSLT_SERIALIZATION_ERROR .
  class-methods BOOLEAN_CHECK
    importing
      !VAL type ANY
    returning
      value(RESULT) type ABAP_BOOL .
  class-methods BOOLEAN_ABAP_2_JSON
    importing
      !VAL type ANY
    returning
      value(RESULT) type STRING .
  class-methods C_REPLACE_ASSIGN_STRUC
    importing
      !IV_ATTRI type CLIKE
    returning
      value(RV_ATTRI) type STRING .
  class-methods TRANS_JSON_2_ANY
    importing
      !VAL type ANY
    changing
      !DATA type ANY .
  class-methods TRANS_REF_TAB_2_TAB
    importing
      !IR_TAB_FROM type ref to DATA
    exporting
      !T_RESULT type STANDARD TABLE .
  class-methods C_TRIM_UPPER
    importing
      !VAL type CLIKE
    returning
      value(RESULT) type STRING .
  class-methods RTTI_XML_GET_BY_DATA
    importing
      !DATA type ANY
    returning
      value(RESULT) type STRING .
  class-methods RTTI_XML_SET_TO_DATA
    importing
      !RTTI_DATA type CLIKE
    exporting
      !E_DATA type ref to DATA .
  class-methods TIME_GET_TIMESTAMPL
    returning
      value(RESULT) type TIMESTAMPL .
  class-methods TIME_SUBSTRACT_SECONDS
    importing
      !TIME type TIMESTAMPL
      !SECONDS type I
    returning
      value(RESULT) type TIMESTAMPL .
  class-methods C_TRIM
    importing
      !VAL type CLIKE
    returning
      value(RESULT) type STRING .
  class-methods C_TRIM_LOWER
    importing
      !VAL type CLIKE
    returning
      value(RESULT) type STRING .
  class-methods URL_PARAM_GET_TAB
    importing
      !I_VAL type CLIKE
    returning
      value(RT_PARAMS) type Z2UI5_IF_CLIENT=>TY_T_NAME_VALUE .
  class-methods RTTI_GET_T_ATTRI_BY_OBJECT
    importing
      !VAL type ref to OBJECT
    returning
      value(RESULT) type ABAP_ATTRDESCR_TAB .
  class-methods RTTI_GET_T_COMP_BY_STRUC
    importing
      !VAL type ANY
    returning
      value(RESULT) type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE .
  class-methods RTTI_GET_TYPE_NAME
    importing
      !VAL type ANY
    returning
      value(RESULT) type STRING .
  class-methods RTTI_CHECK_TYPE_KIND_DREF
    importing
      !VAL type ANY
    returning
      value(RESULT) type ABAP_BOOL .
  class-methods RTTI_GET_TYPE_KIND
    importing
      !VAL type ANY
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_UTIL_FUNC IMPLEMENTATION.


  METHOD app_get_url.

    if classname is INITIAL.
    classname = rtti_get_classname_by_ref( client->get( )-s_draft-app ).
    endif.

    DATA(lv_url) = to_lower( client->get( )-s_config-origin && client->get( )-s_config-pathname ) && `?`.
    DATA(lt_param) = url_param_get_tab( client->get( )-s_config-search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start` v = to_lower( classname ) ) INTO TABLE lt_param.

    result = lv_url && url_param_create_url( lt_param ).

  ENDMETHOD.


  METHOD app_get_url_source_code.

    DATA(ls_draft) = client->get( )-s_draft.
    DATA(ls_config) = client->get( )-s_config.

    result = ls_config-origin && `/sap/bc/adt/oo/classes/`
       && rtti_get_classname_by_ref( ls_draft-app ) && `/source/main`.

  ENDMETHOD.


  METHOD boolean_abap_2_json.

    IF boolean_check( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD boolean_check.

    TRY.
        DATA(lv_type_name) = rtti_get_type_name( val ).
        CASE lv_type_name.
          WHEN `ABAP_BOOL` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD c_replace_assign_struc.

    rv_attri  = iv_attri.
    DATA(lv_length) = strlen( rv_attri ) - 2.
    DATA(lv_attri_end) = rv_attri+lv_length.

    IF lv_attri_end = `>*`.
      lv_attri_end = `>`.
      lv_length = lv_length.
    ELSE.
      lv_attri_end = `-`.
      lv_length = lv_length + 2.
    ENDIF.
    rv_attri = rv_attri(lv_length) && lv_attri_end.

  ENDMETHOD.


  METHOD c_trim.

    result = shift_left( shift_right( CONV string( val ) ) ).
    result = shift_right( val = result sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    result = to_lower( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    result = to_upper( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD func_get_user_tech.
    result = sy-uname.
  ENDMETHOD.


  METHOD func_get_uuid_22.

    TRY.
        DATA uuid TYPE c LENGTH 22.

        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>if_system_uuid_static~create_uuid_c22
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            DATA(lv_fm) = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_22 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

    result = replace( val = result sub = `}` with = `0` occ = 0 ).
    result = replace( val = result sub = `{` with = `0` occ = 0 ).
    result = replace( val = result sub = `"` with = `0` occ = 0 ).
    result = replace( val = result sub = `'` with = `0` occ = 0 ).

  ENDMETHOD.


  METHOD func_get_uuid_32.

    TRY.
        DATA uuid TYPE c LENGTH 32.

        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            DATA(lv_fm) = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
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


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.

    DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).
    DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
    result  = lo_ele->get_relative_name( ).

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_object.

    DATA(lo_obj_ref) = cl_abap_objectdescr=>describe_by_object_ref( val ).
    result   = CAST cl_abap_classdescr( lo_obj_ref )->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_comp_by_struc.

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( val ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_type ).
    result   = lo_struct->get_components( ).

  ENDMETHOD.


  METHOD rtti_xml_get_by_data.

    TRY.

        DATA srtti TYPE REF TO object.

        CALL METHOD ('ZCL_SRTTI_TYPEDESCR')=>('CREATE_BY_DATA_OBJECT')
          EXPORTING
            data_object = data
          RECEIVING
            srtti       = srtti.

        CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

      CATCH cx_root.
        DATA(lv_link) = `https://github.com/sandraros/S-RTTI`.
        DATA(lv_text) = `<p>Please install the open-source project S-RTTI by sandraros and try again: <a href="` &&
                         lv_link && `" style="color:blue; font-weight:600;">(link)</a></p>`.

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.


  METHOD rtti_xml_set_to_data.

    TRY.
        DATA srtti TYPE REF TO object.
        CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.

        DATA rtti_type TYPE REF TO cl_abap_typedescr.
        CALL METHOD srtti->('GET_RTTI')
          RECEIVING
            rtti = rtti_type.

        DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
        lo_datadescr ?= rtti_type.

        CREATE DATA e_data TYPE HANDLE lo_datadescr.
        ASSIGN e_data->* TO FIELD-SYMBOL(<variable>).
        CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.

      CATCH cx_root.

        DATA(lv_link) = `https://github.com/sandraros/S-RTTI`.
        DATA(lv_text) = `<p>Please install the open-source project S-RTTI by sandraros and try again: <a href="` && lv_link && `" style="color:blue; font-weight:600;">(link)</a></p>`.

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.


  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD time_substract_seconds.
    result = cl_abap_tstmp=>subtractsecs( tstmp = time secs  = seconds ).
  ENDMETHOD.


  METHOD trans_json_2_any.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( val )
            assoc_arrays = abap_true
        CHANGING
            data = data ).

  ENDMETHOD.


  METHOD trans_json_any_2.

    result = /ui2/cl_json=>serialize( data = any pretty_name = CONV #( pretty_name ) ).

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.
    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.

    ASSIGN ir_tab_from->* TO <lt_from>.
    x_check_raise( xsdbool( sy-subrc <> 0 ) ).
    CLEAR t_result.

    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( t_result ) ).
    DATA(lo_struc) = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
    DATA(lt_components) = lo_struc->get_components( ).

    LOOP AT <lt_from> INTO DATA(lr_from).

      DATA lr_row TYPE REF TO data.
      CREATE DATA lr_row TYPE HANDLE lo_struc.
      ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      ASSIGN lr_from->* TO FIELD-SYMBOL(<row_ui5>).
      x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).

      DATA(lt_components_dissolved) = lt_components.
      CLEAR lt_components_dissolved.

      LOOP AT lt_components INTO DATA(ls_comp).

        IF ls_comp-as_include = abap_false.
          APPEND ls_comp TO lt_components_dissolved.
        ELSE.
          DATA(struct) = CAST cl_abap_structdescr( ls_comp-type ).
          APPEND LINES OF struct->get_components( ) TO lt_components_dissolved.

        ENDIF.
      ENDLOOP.

      LOOP AT lt_components_dissolved INTO ls_comp.
        TRY.

            FIELD-SYMBOLS <comp> TYPE data.
            ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row> TO <comp>.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            FIELD-SYMBOLS <comp_ui5> TYPE data.
            ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row_ui5> TO <comp_ui5>.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            ASSIGN <comp_ui5>->* TO FIELD-SYMBOL(<ls_data_ui5>).

            IF sy-subrc = 0.
              CASE ls_comp-type->kind.
                WHEN cl_abap_typedescr=>kind_table.
                  trans_ref_tab_2_tab( EXPORTING ir_tab_from = <comp_ui5>
                                       IMPORTING t_result    = <comp> ).
                WHEN OTHERS.
                  <comp> = <ls_data_ui5>.
              ENDCASE.
            ENDIF.

          CATCH cx_root.
        ENDTRY.
      ENDLOOP.

      INSERT <row> INTO TABLE t_result.
    ENDLOOP.


  ENDMETHOD.


  METHOD trans_xml_2_any.

    CALL TRANSFORMATION id
        SOURCE XML xml
        RESULT data = any.

  ENDMETHOD.


  METHOD trans_xml_any_2.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD url_param_create_url.

    LOOP AT t_params INTO DATA(ls_param).
      result = result && ls_param-n && `=` && ls_param-v && `&`.
    ENDLOOP.
    result = shift_right( val = result  sub = `&` ).

  ENDMETHOD.


  METHOD url_param_get.

    DATA(lt_params) = url_param_get_tab( url ).
    DATA(lv_val) = c_trim_lower( val ).
    result = VALUE #( lt_params[ n = lv_val ]-v OPTIONAL ).

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA(lv_search) = replace( val  = i_val sub  = `%3D` with = '=' occ  = 0 ).
    lv_search = shift_left( val = lv_search sub = `?` ).
    lv_search = c_trim_lower( lv_search ).

    DATA(lv_search2) = substring_after( val = lv_search
                                        sub = `&sap-startup-params=` ).
    lv_search = COND #( WHEN lv_search2 IS NOT INITIAL THEN lv_search2 ELSE lv_search ).

    lv_search2 = substring_after( val = c_trim_lower( lv_search ) sub = `?` ).
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


  METHOD x_check_raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.
    ENDIF.

  ENDMETHOD.


  METHOD x_raise.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.

  ENDMETHOD.
ENDCLASS.
