CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
      END OF ty_attri.

    TYPES ty_T_attri TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY.

    TYPES ty_tt_string TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.

    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        s_msg  TYPE LINE OF bapirettab,
      END OF ms_error.

    METHODS constructor
      IMPORTING
        val      TYPE any OPTIONAL
        previous LIKE previous OPTIONAL
          PREFERRED PARAMETER val.

    METHODS get_text REDEFINITION.

    CLASS-METHODS raise
      IMPORTING
        v    TYPE clike     DEFAULT `CX_SY_SUBRC`
        when TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER v.

    CLASS-METHODS get_classname_by_ref
      IMPORTING
        in            TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_uuid_session
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_user_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS trans_json_2_data
      IMPORTING
        iv_json   TYPE clike
      EXPORTING
        ev_result TYPE REF TO data.

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

    CLASS-METHODS get_attri_name_by_ref
      IMPORTING
        i_focus       TYPE data
        io_app        TYPE REF TO object
        t_attri       TYPE ty_t_attri
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

    CLASS-METHODS get_t_attri_by_ref
      IMPORTING
        io_app        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE ty_t_attri ##NEEDED.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_params_by_url
      IMPORTING
        url           TYPE string
        name          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_prev_when_no_handler
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO cx_root.

    CLASS-METHODS get_ref_data
      IMPORTING
        n             TYPE clike
        o             TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO data.

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
      CHANGING
        ct_to       TYPE STANDARD TABLE.

    CLASS-METHODS get_trim_upper
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    CLASS-DATA mv_counter TYPE i.

    CLASS-METHODS _get_t_attri
      IMPORTING
        io_app        TYPE REF TO object
        iv_attri      TYPE csequence
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

  PRIVATE SECTION.

ENDCLASS.

CLASS z2ui5_lcl_utility IMPLEMENTATION.

  METHOD get_trim_upper.
    result = CONV #( val ).
    result = to_upper( shift_left( shift_right( result ) ) ).
  ENDMETHOD.


  METHOD constructor.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root ##CATCH_ALL.
        ms_error-s_msg-message = val.
    ENDTRY.

    TRY.
        ms_error-uuid = get_uuid( ).
      CATCH cx_root ##CATCH_ALL.
    ENDTRY.
  ENDMETHOD.

  METHOD get_abap_2_json.

    IF check_is_boolean( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = |"{ escape( val = val  format = cl_abap_format=>e_json_string ) }"|.
    ENDIF.

  ENDMETHOD.

  METHOD check_is_boolean.

    TRY.
        DATA(lo_ele) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( val ) ).
        CASE lo_ele->get_relative_name( ).
          WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD get_json_boolean.

    IF check_is_boolean( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.

  METHOD get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD get_params_by_url.

    DATA(url_segments) = segment( val = get_trim_upper( url ) index = 2 sep = `?` ).
    SPLIT url_segments AT `&` INTO TABLE DATA(lt_params).

    DATA lt_url_params TYPE z2ui5_if_client=>ty_t_name_value.

    LOOP AT lt_params INTO DATA(lv_param).

      SPLIT lv_param AT `=` INTO DATA(lv_name) DATA(lv_value) DATA(lv_dummy).

      INSERT VALUE #( name  = lv_name
                      value = lv_value ) INTO TABLE lt_url_params.

    ENDLOOP.

    result = lt_url_params[ name = get_trim_upper( name ) ]-value.

  ENDMETHOD.


  METHOD get_prev_when_no_handler.

    TRY.
        result = CAST cx_sy_no_handler( val )->previous.
      CATCH cx_root.
    ENDTRY.

    IF result IS NOT BOUND.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_ref_data.

    FIELD-SYMBOLS <field> TYPE data.

    ASSIGN o->(n) TO <field>.
    raise( when = xsdbool( sy-subrc <> 0 ) ).

    result = REF #( <field> ).

  ENDMETHOD.


  METHOD get_timestampl.

    GET TIME STAMP FIELD result.

  ENDMETHOD.


  METHOD get_user_tech.

    result = sy-uname.

  ENDMETHOD.


  METHOD get_uuid.
    TRY.

        DATA uuid TYPE c LENGTH 32.

        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>create_uuid_c32_static
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

  METHOD get_uuid_session.

    mv_counter = mv_counter + 1.
    result = get_trim_upper( mv_counter ).

  ENDMETHOD.

  METHOD get_attri_name_by_ref.

    CONSTANTS c_prefix TYPE string VALUE `IO_APP->`.

    DATA lr_in TYPE REF TO data.
    GET REFERENCE OF i_focus INTO lr_in.

    LOOP AT t_attri REFERENCE INTO DATA(lr_attri).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      raise( when = xsdbool( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).

      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF <attribute> INTO lr_ref.

      IF lr_in = lr_ref.
        result = to_upper( lr_attri->name ).
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_t_attri_by_ref.

    DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( io_app ) )->attributes.

    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public.

    LOOP AT lt_attri INTO DATA(ls_attri)
      WHERE type_kind = cl_abap_classdescr=>typekind_struct2
         OR type_kind = cl_abap_classdescr=>typekind_struct1.

      DELETE lt_attri INDEX sy-tabix.

      INSERT LINES OF _get_t_attri(
        io_app = io_app
        iv_attri = ls_attri-name ) INTO TABLE lt_attri.

    ENDLOOP.

    LOOP AT lt_attri INTO ls_attri.
      APPEND CORRESPONDING #( ls_attri ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD _get_t_attri.

    CONSTANTS c_prefix TYPE string VALUE `IO_APP->`.
    FIELD-SYMBOLS <attribute> TYPE any.

    DATA(lv_name) = c_prefix && to_upper( iv_attri ).
    ASSIGN (lv_name) TO <attribute>.
    raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_type ).

    LOOP AT lo_struct->get_components( ) REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = iv_attri && `-` && lr_comp->name.

      IF lr_comp->as_include = abap_true.
        INSERT LINES OF _get_t_attri( io_app   = io_app
                                      iv_attri = lv_element ) INTO TABLE result.

      ELSE.
        INSERT VALUE #( name = lv_element
                        type_kind = lr_comp->type->type_kind ) INTO TABLE result.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD trans_any_2_json.

    result = /ui2/cl_json=>serialize( any ).

  ENDMETHOD.

  METHOD trans_json_2_data.

    CLEAR ev_result.
    IF iv_json IS INITIAL.
      RETURN.
    ENDIF.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( iv_json )
            assoc_arrays = abap_true
        CHANGING
            data         = ev_result
        ).

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

    READ TABLE ct_to INDEX 1 ASSIGNING FIELD-SYMBOL(<back>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lt_components) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( <back> ) )->get_components( ).

    LOOP AT <lt_from> INTO DATA(lr_from).

      ASSIGN ct_to[ sy-tabix ] TO <back>.
      raise( when = xsdbool( sy-subrc <> 0 ) ).

      ASSIGN lr_from->* TO FIELD-SYMBOL(<row_ui5>).
      raise( when = xsdbool( sy-subrc <> 0 ) ).

      LOOP AT lt_components INTO DATA(ls_comp).

        FIELD-SYMBOLS <comp> TYPE data.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <back> TO <comp>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        FIELD-SYMBOLS <comp_ui5> TYPE data.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row_ui5> TO <comp_ui5>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        ASSIGN <comp_ui5>->* TO FIELD-SYMBOL(<ls_data_ui5>).
        IF sy-subrc = 0.
          <comp> = <ls_data_ui5>.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD trans_xml_2_object.

    CALL TRANSFORMATION id
       SOURCE XML xml
       RESULT data = data.

  ENDMETHOD.

  METHOD get_text.

    IF ms_error-x_root IS NOT INITIAL.
      result = ms_error-x_root->get_text( ).
      DATA(error) = abap_true.
    ELSEIF ms_error-s_msg-message IS NOT INITIAL.
      result = ms_error-s_msg-message.
      error = abap_true.
    ENDIF.

    IF error = abap_true AND result IS INITIAL.
      result = `unknown error`.
    ENDIF.

  ENDMETHOD.

  METHOD raise.

    IF when = abap_false.
      RETURN.
    ENDIF.
    RAISE EXCEPTION TYPE z2ui5_lcl_utility EXPORTING val = v.

  ENDMETHOD.
ENDCLASS.

CLASS _ DEFINITION INHERITING FROM z2ui5_lcl_utility.
ENDCLASS.
