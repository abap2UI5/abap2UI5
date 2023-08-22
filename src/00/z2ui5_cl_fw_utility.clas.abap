CLASS z2ui5_cl_fw_utility DEFINITION PUBLIC
    CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS url_param_get
      IMPORTING
        val           TYPE string
        url           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        t_params      TYPE z2ui5_if_client=>ty_t_name_value
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_set
      IMPORTING
        url           TYPE string
        name          TYPE string
        value         TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_classname_by_ref
      IMPORTING
        in            TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS raise
      IMPORTING
        v    TYPE clike     DEFAULT `CX_SY_SUBRC`
        when TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER v.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_uuid_22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_user_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_any_2_json
      IMPORTING
        any           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_xml_2_object
      IMPORTING
        xml  TYPE clike
      EXPORTING
        data TYPE data.


    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    CLASS-METHODS get_abap_2_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS check_is_boolean
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS get_json_boolean
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING
        ir_tab_from TYPE REF TO data
      EXPORTING
        t_result    TYPE STANDARD TABLE.

    CLASS-METHODS get_trim_upper
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get
      IMPORTING
        data          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_set
      IMPORTING
        rtti_data TYPE string
      EXPORTING
        e_data    TYPE REF TO data.

    CLASS-METHODS get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS get_replace
      IMPORTING
        iv_val        TYPE clike
        iv_begin      TYPE clike
        iv_end        TYPE clike
        iv_replace    TYPE clike DEFAULT ''
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_trim_lower
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_get_tab
      IMPORTING
        i_val            TYPE string
      RETURNING
        VALUE(rt_params) TYPE z2ui5_if_client=>ty_t_name_value.

    CLASS-METHODS get_t_attri_by_struc
      IMPORTING
        io_app        TYPE REF TO object
        iv_attri      TYPE csequence
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.


  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_fw_utility IMPLEMENTATION.


  METHOD check_is_boolean.

    TRY.
        DATA(lo_ele) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( val ) ).
        CASE lo_ele->get_relative_name( ).
          WHEN `ABAP_BOOL` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD get_json_boolean.

    IF check_is_boolean( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD url_param_get.

    DATA(lt_params) = url_param_get_tab( url ).
    DATA(lv_val) = get_trim_lower( val ).
    result = VALUE #( lt_params[ n = lv_val ]-v OPTIONAL ).

  ENDMETHOD.

  METHOD url_param_set.

    DATA(lt_params) = url_param_get_tab( url ).

    DATA(lv_n) = get_trim_lower( name ).

    LOOP AT lt_params REFERENCE INTO DATA(lr_params)
        WHERE n = lv_n.
      lr_params->v = get_trim_lower( value ).
    ENDLOOP.
    IF sy-subrc <> 0.
      INSERT VALUE #( n = lv_n v = get_trim_lower( value ) ) INTO TABLE lt_params.
    ENDIF.

    result = url_param_create_url( lt_params ).

  ENDMETHOD.


  METHOD get_user_tech.
    result = sy-uname.
  ENDMETHOD.

  METHOD get_uuid_22.

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

  ENDMETHOD.

  METHOD get_uuid.

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


  METHOD raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cl_fw_error EXPORTING val = v.
    ENDIF.

  ENDMETHOD.


  METHOD rtti_get.

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

        RAISE EXCEPTION TYPE z2ui5_cl_fw_error
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.


  METHOD rtti_set.

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

        RAISE EXCEPTION TYPE z2ui5_cl_fw_error
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.


  METHOD trans_any_2_json.

    result = /ui2/cl_json=>serialize( any ).

  ENDMETHOD.


  METHOD trans_object_2_xml.

    FIELD-SYMBOLS <object> TYPE any.
    ASSIGN object->* TO <object>.
    raise( when = xsdbool( sy-subrc <> 0 ) ).

    CALL TRANSFORMATION id
         SOURCE data = <object>
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.
    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.

    ASSIGN ir_tab_from->* TO <lt_from>.
    raise( when = xsdbool( sy-subrc <> 0 ) ).
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
      raise( when = xsdbool( sy-subrc <> 0 ) ).

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


  METHOD trans_xml_2_object.

    CALL TRANSFORMATION id
        SOURCE XML xml
        RESULT data = data.

  ENDMETHOD.



  METHOD get_t_attri_by_struc.

    FIELD-SYMBOLS <attribute> TYPE any.

    DATA(lv_name) = `IO_APP->` && to_upper( iv_attri ).
    ASSIGN (lv_name) TO <attribute>.
    raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_type ).

    DATA(lv_attri) = iv_attri.
    DATA(lv_length) = strlen( lv_attri ) - 2.
    DATA(lv_attri_end) = lv_attri+lv_length.

    IF lv_attri_end = `>*`.
      lv_attri_end = `>`.
      lv_length = lv_length.
    ELSE.
      lv_attri_end = `-`.
      lv_length = lv_length + 2.
    ENDIF.
    lv_attri = lv_attri(lv_length) && lv_attri_end.


    LOOP AT lo_struct->get_components( ) REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = lv_attri && lr_comp->name.

      IF lr_comp->as_include = abap_true OR
         lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct2 OR
         lr_comp->type->type_kind = cl_abap_classdescr=>typekind_struct1.

        INSERT LINES OF get_t_attri_by_struc( io_app   = io_app
                                               iv_attri = lv_element ) INTO TABLE result.

      ELSE.

        INSERT VALUE #( name      = lv_element
                        type_kind = lr_comp->type->type_kind ) INTO TABLE result.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_replace.

    result = iv_val.

    DATA(lv_1) = substring_before( val = result
                                   sub = iv_begin ).
    DATA(lv_2) = substring_after( val = result
                                  sub = iv_end ).
    result = COND #( WHEN lv_2 IS NOT INITIAL THEN lv_1 && iv_replace && lv_2 ).

  ENDMETHOD.


  METHOD get_trim.

    result = shift_left( shift_right( CONV string( val ) ) ).
    result = shift_right( val = result sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD get_trim_lower.

    result = to_lower( get_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD get_abap_2_json.

    IF check_is_boolean( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = |"{ escape( val    = val
                           format = cl_abap_format=>e_json_string ) }"|.
    ENDIF.

  ENDMETHOD.


  METHOD get_trim_upper.

    result = to_upper( get_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD url_param_create_url.

    LOOP AT t_params INTO DATA(ls_param).
      result = result && ls_param-n && `=` && ls_param-v && `&`.
    ENDLOOP.
    result = shift_right( val = result
                          sub = `&` ).

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA(lv_search) = replace( val  = i_val sub  = `%3D` with = '=' occ  = 0 ).
    lv_search = shift_left( val = lv_search sub = `?` ).
    lv_search = get_trim_lower( lv_search ).

    DATA(lv_search2) = substring_after( val = lv_search
                                        sub = `&sap-startup-params=` ).
    lv_search = COND #( WHEN lv_search2 IS NOT INITIAL THEN lv_search2 ELSE lv_search ).

    lv_search2 = substring_after( val = get_trim_lower( lv_search ) sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.

    SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).

    LOOP AT lt_param REFERENCE INTO DATA(lr_param).
      SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value).
      INSERT VALUE #( n = get_trim_lower( lv_name ) v = get_trim_lower( lv_value ) ) INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
