CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
      END OF ty_attri.

    types ty_T_attri TYPE STANDARD TABLE OF ty_attri WITH DEFAULT KEY.

    TYPES ty_tt_string TYPE STANDARD TABLE OF string_table WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.

    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

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
    DATA temp5 TYPE string.
    temp5 = val.
    result = temp5.
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

    IF check_is_boolean( val ) IS NOT INITIAL.
      DATA temp6 TYPE string.
      IF val = abap_true.
        temp6 = `true`.
      ELSE.
        temp6 = `false`.
      ENDIF.
      result = temp6.
    ELSE.
      result = |"{ escape( val = val  format = cl_abap_format=>e_json_string ) }"|.
    ENDIF.

  ENDMETHOD.

  METHOD check_is_boolean.

    TRY.
        DATA temp7 TYPE REF TO cl_abap_elemdescr.
        temp7 ?= cl_abap_elemdescr=>describe_by_data( val ).
        DATA lo_ele LIKE temp7.
        lo_ele = temp7.
        CASE lo_ele->get_relative_name( ).
          WHEN `ABAP_BOOL` OR `ABAP_BOOLEAN` OR `XSDBOOLEAN`.
            result = abap_true.
        ENDCASE.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD get_json_boolean.

    IF check_is_boolean( val ) IS NOT INITIAL.
      DATA temp8 TYPE string.
      IF val = abap_true.
        temp8 = `true`.
      ELSE.
        temp8 = `false`.
      ENDIF.
      result = temp8.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.

  METHOD get_classname_by_ref.

    DATA lv_classname TYPE abap_abstypename.
    lv_classname = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD get_params_by_url.

    DATA url_segments TYPE string.
    url_segments = segment( val = get_trim_upper( url ) index = 2 sep = `?` ).
    DATA lt_params TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    SPLIT url_segments AT `&` INTO TABLE lt_params.

    DATA lt_url_params TYPE z2ui5_if_client=>ty_t_name_value.

    DATA lv_param LIKE LINE OF lt_params.
    LOOP AT lt_params INTO lv_param.

      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA lv_dummy TYPE string.
      SPLIT lv_param AT `=` INTO lv_name lv_value lv_dummy.

      DATA temp9 TYPE z2ui5_if_client=>ty_s_name_value.
      CLEAR temp9.
      temp9-name = lv_name.
      temp9-value = lv_value.
      INSERT temp9 INTO TABLE lt_url_params.

    ENDLOOP.

    DATA temp10 LIKE LINE OF lt_url_params.
    DATA temp11 LIKE sy-tabix.
    temp11 = sy-tabix.
    READ TABLE lt_url_params WITH KEY name = get_trim_upper( name ) INTO temp10.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    result = temp10-value.

  ENDMETHOD.


  METHOD get_prev_when_no_handler.

    TRY.
        DATA temp12 TYPE REF TO cx_sy_no_handler.
        temp12 ?= val.
        result = temp12->previous.
      CATCH cx_root.
    ENDTRY.

    IF result IS NOT BOUND.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_ref_data.

    FIELD-SYMBOLS <field> TYPE data.

    ASSIGN o->(n) TO <field>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    GET REFERENCE OF <field> INTO result.

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

            DATA lv_fm TYPE string.
            lv_fm = `GUID_CREATE`.
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

    DATA temp7 LIKE LINE OF t_attri.
    DATA lr_attri LIKE REF TO temp7.
    LOOP AT t_attri REFERENCE INTO lr_attri.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      raise( when = boolc( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).

      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF <attribute> INTO lr_ref.

      IF lr_in = lr_ref.
        result = to_upper( lr_attri->name ).
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_t_attri_by_ref.

    DATA temp13 TYPE REF TO cl_abap_classdescr.
    temp13 ?= cl_abap_objectdescr=>describe_by_object_ref( io_app ).
    DATA lt_attri LIKE temp13->attributes.
    lt_attri = temp13->attributes.

    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public.

    DATA ls_attri LIKE LINE OF lt_attri.
    LOOP AT lt_attri INTO ls_attri
      WHERE type_kind = cl_abap_classdescr=>typekind_struct2
         OR type_kind = cl_abap_classdescr=>typekind_struct1.

      DELETE lt_attri INDEX sy-tabix.

      INSERT LINES OF _get_t_attri(
        io_app = io_app
        iv_attri = ls_attri-name ) INTO TABLE lt_attri.

    ENDLOOP.

    LOOP AT lt_attri INTO ls_attri.
      DATA temp14 LIKE LINE OF result.
      MOVE-CORRESPONDING ls_attri TO temp14.
      APPEND temp14 TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD _get_t_attri.

    CONSTANTS c_prefix TYPE string VALUE `IO_APP->`.
    FIELD-SYMBOLS <attribute> TYPE any.

    DATA lv_name TYPE string.
    lv_name = c_prefix && to_upper( iv_attri ).
    ASSIGN (lv_name) TO <attribute>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    DATA lo_type TYPE REF TO cl_abap_typedescr.
    lo_type = cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA temp8 TYPE REF TO cl_abap_structdescr.
    temp8 ?= lo_type.
    DATA lo_struct LIKE temp8.
    lo_struct = temp8.

    DATA temp9 TYPE abap_component_tab.
    temp9 = lo_struct->get_components( ).
    DATA temp1 LIKE LINE OF temp9.
    DATA lr_comp LIKE REF TO temp1.
    LOOP AT temp9 REFERENCE INTO lr_comp.

      DATA lv_element TYPE string.
      lv_element = iv_attri && `-` && lr_comp->name.

      IF lr_comp->as_include = abap_true.
        INSERT LINES OF _get_t_attri( io_app   = io_app
                                      iv_attri = lv_element ) INTO TABLE result.

      ELSE.
        DATA temp10 TYPE abap_attrdescr.
        CLEAR temp10.
        temp10-name = lv_element.
        temp10-type_kind = lr_comp->type->type_kind.
        INSERT temp10 INTO TABLE result.
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

    DATA temp15 TYPE string.
    temp15 = iv_json.
    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = temp15
            assoc_arrays = abap_true
        CHANGING
            data         = ev_result
        ).

  ENDMETHOD.


  METHOD trans_object_2_xml.

    FIELD-SYMBOLS <object> TYPE any.
    ASSIGN object->* TO <object>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    CALL TRANSFORMATION id
       SOURCE data = <object>
       RESULT XML result
        OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.

    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.
    ASSIGN ir_tab_from->* TO <lt_from>.
    raise( when = boolc( sy-subrc <> 0 ) ).

    FIELD-SYMBOLS <back> TYPE any.
    READ TABLE ct_to INDEX 1 ASSIGNING <back>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA temp1 TYPE REF TO cl_abap_structdescr.
    temp1 ?= cl_abap_structdescr=>describe_by_data( <back> ).
    DATA lt_components TYPE abap_component_tab.
    lt_components = temp1->get_components( ).

    DATA lr_from LIKE LINE OF <lt_from>.
    LOOP AT <lt_from> INTO lr_from.

      READ TABLE ct_to INDEX sy-tabix ASSIGNING <back>.
      raise( when = boolc( sy-subrc <> 0 ) ).

      FIELD-SYMBOLS <row_ui5> TYPE any.
      ASSIGN lr_from->* TO <row_ui5>.
      raise( when = boolc( sy-subrc <> 0 ) ).

      DATA ls_comp LIKE LINE OF lt_components.
      LOOP AT lt_components INTO ls_comp.

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

        FIELD-SYMBOLS <ls_data_ui5> TYPE any.
        ASSIGN <comp_ui5>->* TO <ls_data_ui5>.
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
      DATA error LIKE abap_true.
      error = abap_true.
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

CLASS z2ui5_lcl_utility_tree_json DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_name,
        n       TYPE string,
        v       TYPE string,
        no_apos TYPE abap_bool,
      END OF ty_s_name.

    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name.

    DATA mo_root TYPE REF TO z2ui5_lcl_utility_tree_json.
    DATA mo_parent TYPE REF TO z2ui5_lcl_utility_tree_json.
    DATA mv_name   TYPE string.
    DATA mv_value  TYPE string.
    DATA mt_values TYPE STANDARD TABLE OF REF TO z2ui5_lcl_utility_tree_json WITH DEFAULT KEY.
    DATA mv_check_list TYPE abap_bool.
    DATA mr_actual TYPE REF TO data.
    DATA mv_apost_active TYPE abap_bool.

    CLASS-METHODS new
      IMPORTING
        io_root       TYPE REF TO z2ui5_lcl_utility_tree_json
        iv_name       TYPE simple
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    CLASS-METHODS factory
      IMPORTING
        iv_json       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS constructor.

    METHODS get_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS get_attribute
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS get_val
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_parent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_list_val
      IMPORTING
        v             TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute
      IMPORTING
        n             TYPE clike
        v             TYPE clike
        apos_active   TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attributes_name_value_tab
      IMPORTING
        it_name_value TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_object
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_list_object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_list_list
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_list
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_instance
      IMPORTING
        val           TYPE REF TO z2ui5_lcl_utility_tree_json
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS write_result
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_name
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS wrap_json
      IMPORTING
        iv_text       TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS quote_json
      IMPORTING
        iv_text       TYPE string
        iv_cond       TYPE abap_bool
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.



CLASS z2ui5_lcl_utility_tree_json IMPLEMENTATION.


  METHOD add_attribute.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = n ).

    IF apos_active = abap_false.
      lo_attri->mv_value = v.
    ELSE.
      lo_attri->mv_value = escape( val = v format = cl_abap_format=>e_json_string ).
    ENDIF.
    lo_attri->mv_apost_active = apos_active.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.
    result = me.

  ENDMETHOD.


  METHOD add_attributes_name_value_tab.

    DATA ls_value LIKE LINE OF it_name_value.
    LOOP AT it_name_value INTO ls_value.
      add_attribute(
           n           = ls_value-n
           v           = ls_value-v
           apos_active = boolc( ls_value-no_apos = abap_false ) ).
    ENDLOOP.

    result = me.

  ENDMETHOD.


  METHOD add_attribute_instance.

    val->mo_root = mo_root.
    val->mo_parent = me.
    INSERT val INTO TABLE mt_values.
    result = val.

  ENDMETHOD.


  METHOD add_attribute_list.

    result = add_attribute_object( name ).
    result->mv_check_list = abap_true.

  ENDMETHOD.


  METHOD add_attribute_object.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = name ).
    DATA temp16 LIKE mt_values.
    CLEAR temp16.
    temp16 = mt_values.
    APPEND lo_attri TO temp16.
    mt_values = temp16.
    lo_attri->mo_parent = me.
    result = lo_attri.

  ENDMETHOD.


  METHOD add_list_list.

    DATA temp18 TYPE string.
    temp18 = lines( mt_values ).
    result = add_attribute_list( temp18 ).

  ENDMETHOD.


  METHOD add_list_object.

    DATA temp19 TYPE string.
    temp19 = lines( mt_values ).
    result = add_attribute_object( temp19 ).

  ENDMETHOD.


  METHOD add_list_val.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = lines( mt_values ) ).
    lo_attri->mv_value = v.
    lo_attri->mv_apost_active = abap_true.

    DATA temp20 LIKE mt_values.
    CLEAR temp20.
    temp20 = mt_values.
    APPEND lo_attri TO temp20.
    mt_values = temp20.
    lo_attri->mo_parent = me.
    result = lo_attri.
    result = me.

  ENDMETHOD.


  METHOD constructor.

    mo_root = me.

  ENDMETHOD.


  METHOD factory.

    CREATE OBJECT result.
    result->mo_root = result.

    DATA temp22 TYPE string.
    temp22 = iv_json.
    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = temp22
            assoc_arrays = abap_true
        CHANGING
         data            = result->mr_actual
        ).

  ENDMETHOD.

  METHOD new.

    CREATE OBJECT result.
    result->mo_root = io_root.
    DATA temp23 TYPE string.
    temp23 = iv_name.
    result->mv_name = temp23.

  ENDMETHOD.

  METHOD get_attribute.

    CONSTANTS c_prefix TYPE string VALUE `MR_ACTUAL->`.

    _=>raise( when = boolc( mr_actual IS INITIAL ) ).

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_attri = new( io_root = mo_root iv_name = name ).

    FIELD-SYMBOLS <attribute> TYPE any.
    DATA lv_name TYPE string.
    lv_name = c_prefix && replace( val = name sub = `-` with = `_` occ = 0 ).
    ASSIGN (lv_name) TO <attribute>.
    _=>raise( when = boolc( sy-subrc <> 0 ) ).

    lo_attri->mr_actual = <attribute>.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    result = lo_attri.

  ENDMETHOD.

  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    _=>raise( when = boolc( sy-subrc <> 0 ) v = `Value of Attribute in JSON not found` ).

    result = <attribute>.

  ENDMETHOD.

  METHOD get_name.

    result = mv_name.

  ENDMETHOD.


  METHOD get_parent.

    DATA temp24 LIKE result.
    IF mo_parent IS NOT BOUND.
      temp24 = me.
    ELSE.
      temp24 = mo_parent.
    ENDIF.
    result = temp24.

  ENDMETHOD.


  METHOD get_root.

    result = mo_root.

  ENDMETHOD.


  METHOD wrap_json.

    DATA temp25 TYPE string.
    CASE mv_check_list.
      WHEN abap_true.
        temp25 = |[ { iv_text }]|.
      WHEN OTHERS.
        temp25 = `{` && iv_text && `}`.
    ENDCASE.
    result = temp25.

  ENDMETHOD.

  METHOD quote_json.

    DATA temp26 TYPE string.
    CASE iv_cond.
      WHEN abap_true.
        temp26 = `"` && iv_text && `"`.
      WHEN OTHERS.
        temp26 = iv_text.
    ENDCASE.
    result = temp26.

  ENDMETHOD.

  METHOD write_result.

    DATA lo_attri LIKE LINE OF mt_values.
    LOOP AT mt_values INTO lo_attri.

      IF sy-tabix > 1.
        result = result && |,|.
      ENDIF.

      IF mv_check_list = abap_false.
        result = |{ result }"{ lo_attri->mv_name }":|.
      ENDIF.


      IF lo_attri->mt_values IS NOT INITIAL.
        result = result && lo_attri->write_result( ).
      ELSE.
        result = result &&
           quote_json( iv_cond = boolc( lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL )
                       iv_text = lo_attri->mv_value ).
      ENDIF.

    ENDLOOP.

    result = wrap_json( result ).
  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_system_runtime DEFINITION DEFERRED.

CLASS z2ui5_lcl_if_view DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_view.

    CONSTANTS:
      BEGIN OF cs_config,
        letterboxing TYPE abap_bool VALUE abap_true,
      END OF cs_config.

    TYPES:
      BEGIN OF ty_s_view,
        xml     TYPE string,
        o_model TYPE REF TO z2ui5_lcl_utility_tree_json,
        t_attri TYPE _=>ty_t_attri,
      END OF ty_s_view.

    DATA m_name TYPE string.
    DATA m_ns   TYPE string.
    DATA mt_prop TYPE z2ui5_if_client=>ty_t_name_value.

    DATA m_root    TYPE REF TO z2ui5_lcl_if_view.
    DATA m_last    TYPE REF TO z2ui5_lcl_if_view.
    DATA m_parent  TYPE REF TO z2ui5_lcl_if_view.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_lcl_if_view WITH DEFAULT KEY.

    DATA mo_runtime TYPE REF TO z2ui5_lcl_system_runtime.

    CLASS-METHODS factory
      IMPORTING
        runtime       TYPE REF TO z2ui5_lcl_system_runtime
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_if_view.

    METHODS _generic
      IMPORTING
        name          TYPE clike
        ns            TYPE clike OPTIONAL
        t_prop        TYPE _=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_view.

    METHODS get_view
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE ty_s_view.

  PROTECTED SECTION.

    METHODS xml_get
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE string.

    METHODS xml_get_begin
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE string.

    METHODS xml_get_end
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE string.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_lcl_system_runtime DEFINITION.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF cs_bind_type.

    CLASS-DATA:
      BEGIN OF ss_client,
        o_body   TYPE REF TO z2ui5_lcl_utility_tree_json,
        t_header TYPE z2ui5_if_client=>ty_t_name_value,
        t_param  TYPE z2ui5_if_client=>ty_t_name_value,
      END OF ss_client.

    TYPES:
      BEGIN OF ty_s_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,

        view_active       TYPE string,
        t_attri           TYPE _=>ty_t_attri,
        o_app             TYPE REF TO object,
        app_classname     TYPE string,
      END OF ty_s_db.

    DATA ms_db TYPE ty_s_db.

    TYPES:
      BEGIN OF s_view,
        name     TYPE string,
        o_parser TYPE REF TO z2ui5_lcl_if_view,
      END OF s_view.

    TYPES:
      BEGIN OF ty_s_next,
        lifecycle_method    TYPE string,

        event               TYPE string,
        nav_app_leave_to_id TYPE string,
        s_nav_app_call_new  TYPE ty_s_db,

        t_after             TYPE _=>ty_tt_string,
        page_scroll_pos     TYPE i,

        view                TYPE string,
        view_popup          TYPE string,

        check_set_prev_view TYPE abap_bool,

        t_scroll_pos        TYPE z2ui5_if_client=>ty_t_name_value,
        s_cursor_pos        TYPE z2ui5_if_client=>ty_s_cursor,

        t_view              TYPE STANDARD TABLE OF s_view WITH DEFAULT KEY,
      END OF ty_s_next.

    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    CLASS-METHODS request_begin
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS app_before_rendering
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_client.

    METHODS app_before_event
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_client.

    METHODS request_end
      RETURNING
        VALUE(result) TYPE string.

    METHODS _create_binding
      IMPORTING
        value         TYPE data
        type          TYPE string DEFAULT cs_bind_type-two_way
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS set_app_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_runtime.

    CLASS-METHODS set_app_update_by_client
      IMPORTING
        id_prev       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS set_app_leave_to_id
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS set_app_call_new
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS set_app_system_error
      IMPORTING
        ix            TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_runtime.


  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_lcl_db DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        id TYPE string
        db TYPE z2ui5_lcl_system_runtime=>ty_s_db.

    CLASS-METHODS load_app
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_lcl_system_runtime=>ty_s_db.

    CLASS-METHODS read
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_t_draft.

    CLASS-METHODS cleanup.

ENDCLASS.

CLASS z2ui5_lcl_if_view IMPLEMENTATION.

  METHOD xml_get_begin.

    DATA temp27 TYPE string.
    IF check_popup_active = abap_true.
      temp27 = `<core:FragmentDefinition`.
    ELSE.
      temp27 = `<mvc:View controllerName="MyController"`.
    ENDIF.
    result = temp27.

    result = result && ` displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml"` &&
              ` xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mvc" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" ` &&
                     `xmlns="sap.m" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > `.

    DATA temp28 TYPE string.
    IF cs_config-letterboxing = abap_true AND check_popup_active = abap_false.
      temp28 = `<Shell>`.
    ELSE.
      CLEAR temp28.
    ENDIF.
    result = result && temp28.

  ENDMETHOD.

  METHOD xml_get_end.

    DATA temp29 TYPE string.
    IF check_popup_active = abap_false.
      DATA temp11 TYPE string.
      IF cs_config-letterboxing = abap_true.
        temp11 = `</Shell>`.
      ELSE.
        CLEAR temp11.
      ENDIF.
      temp29 = temp11 && `</mvc:View>`.
    ELSE.
      temp29 = `</core:FragmentDefinition>`.
    ENDIF.
    result = result && temp29.

  ENDMETHOD.

  METHOD xml_get.

    "case - root
    IF me = m_root.
      result = xml_get_begin( check_popup_active ).

      DATA lr_child LIKE LINE OF t_child.
      LOOP AT t_child INTO lr_child.
        result = result && lr_child->xml_get( ).
      ENDLOOP.

      result = result && xml_get_end( check_popup_active ).
      RETURN.
    ENDIF.

    "case - normal
    CASE m_name.
      WHEN `ZZHTML`.
        DATA temp30 LIKE LINE OF mt_prop.
        DATA temp31 LIKE sy-tabix.
        temp31 = sy-tabix.
        READ TABLE mt_prop WITH KEY name = `VALUE` INTO temp30.
        sy-tabix = temp31.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
        ENDIF.
        result = temp30-value.
        RETURN.
    ENDCASE.

    DATA temp32 TYPE string.
    IF m_ns <> ``.
      temp32 = |{ m_ns }:|.
    ELSE.
      CLEAR temp32.
    ENDIF.
    DATA lv_tmp2 LIKE temp32.
    lv_tmp2 = temp32.
    DATA temp33 TYPE string.
    DATA val TYPE string.
    val = ``.
    DATA row LIKE LINE OF mt_prop.
    LOOP AT mt_prop INTO row WHERE value <> ``.
      DATA temp12 TYPE string.
      IF row-value = abap_true.
        temp12 = `true`.
      ELSE.
        temp12 = row-value.
      ENDIF.
      val = |{ val } { row-name }="{ escape( val = temp12 format = cl_abap_format=>e_xml_attr ) }" \n |.
    ENDLOOP.
    temp33 = val.
    DATA lv_tmp3 LIKE temp33.
    lv_tmp3 = temp33.

    result = |{ result } <{ lv_tmp2 }{ m_name } \n { lv_tmp3 }|.

    IF t_child IS INITIAL.
      result = |{ result }/>|.
      RETURN.
    ENDIF.

    result = |{ result }>|.

    LOOP AT t_child INTO lr_child.
      result = result && lr_child->xml_get( ).
    ENDLOOP.

    DATA temp34 TYPE string.
    IF m_ns <> ||.
      temp34 = |{ m_ns }:|.
    ELSE.
      CLEAR temp34.
    ENDIF.
    DATA lv_ns LIKE temp34.
    lv_ns = temp34.
    result = |{ result }</{ lv_ns }{ m_name }>|.

  ENDMETHOD.

  METHOD _generic.

    DATA result2 TYPE REF TO z2ui5_lcl_if_view.
    CREATE OBJECT result2 TYPE z2ui5_lcl_if_view.
    result2->m_name = name.
    result2->m_ns = ns.
    result2->mt_prop = t_prop.
    result2->m_parent = me.
    result2->m_root   = m_root.
    INSERT result2 INTO TABLE t_child.

    m_root->m_last = result2.
    result = result2.

  ENDMETHOD.

  METHOD z2ui5_if_view~_generic.

    result = _generic(
       name   = name
       ns     = ns
       t_prop = t_prop ).

  ENDMETHOD.

  METHOD factory.

    CREATE OBJECT result.
    result->m_root = result.
    result->m_parent = result.
    result->mo_runtime = runtime.

  ENDMETHOD.

  METHOD z2ui5_if_view~overflow_toolbar_button.

    result = me.
    DATA temp35 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp35.
    DATA temp36 LIKE LINE OF temp35.
    temp36-n = `press`.
    temp36-v = press.
    APPEND temp36 TO temp35.
    temp36-n = `text`.
    temp36-v = text.
    APPEND temp36 TO temp35.
    temp36-n = `enabled`.
    temp36-v = _=>get_json_boolean( enabled ).
    APPEND temp36 TO temp35.
    temp36-n = `icon`.
    temp36-v = icon.
    APPEND temp36 TO temp35.
    temp36-n = `type`.
    temp36-v = type.
    APPEND temp36 TO temp35.
    _generic(
       name   = `OverflowToolbarButton`
       t_prop = temp35 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~custom_data.

    result = _generic(
       `customData`
        ).

  ENDMETHOD.

  METHOD z2ui5_if_view~formatted_text.

    result = me.
    DATA temp37 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp37.
    DATA temp38 LIKE LINE OF temp37.
    temp38-n = `htmlText`.
    temp38-v = htmltext.
    APPEND temp38 TO temp37.
    _generic(
       name   = `FormattedText`
       t_prop = temp37 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~badge_custom_data.

    result = me.
    DATA temp39 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp39.
    DATA temp40 LIKE LINE OF temp39.
    temp40-n = `key`.
    temp40-v = key.
    APPEND temp40 TO temp39.
    temp40-n = `value`.
    temp40-v = value.
    APPEND temp40 TO temp39.
    temp40-n = `visible`.
    temp40-v = _=>get_abap_2_json( visible ).
    APPEND temp40 TO temp39.
    _generic(
       name   = `BadgeCustomData`
       t_prop = temp39 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~toggle_button.

    result = me.
    DATA temp41 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp41.
    DATA temp42 LIKE LINE OF temp41.
    temp42-n = `press`.
    temp42-v = press.
    APPEND temp42 TO temp41.
    temp42-n = `text`.
    temp42-v = text.
    APPEND temp42 TO temp41.
    temp42-n = `enabled`.
    temp42-v = _=>get_json_boolean( enabled ).
    APPEND temp42 TO temp41.
    temp42-n = `icon`.
    temp42-v = icon.
    APPEND temp42 TO temp41.
    temp42-n = `type`.
    temp42-v = type.
    APPEND temp42 TO temp41.
    temp42-n = `class`.
    temp42-v = class.
    APPEND temp42 TO temp41.
    _generic(
       name   = `ToggleButton`
       t_prop = temp41 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~button.

    result = me.
    DATA temp43 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp43.
    DATA temp44 LIKE LINE OF temp43.
    temp44-n = `press`.
    temp44-v = press.
    APPEND temp44 TO temp43.
    temp44-n = `text`.
    temp44-v = text.
    APPEND temp44 TO temp43.
    temp44-n = `enabled`.
    temp44-v = _=>get_json_boolean( enabled ).
    APPEND temp44 TO temp43.
    temp44-n = `icon`.
    temp44-v = icon.
    APPEND temp44 TO temp43.
    temp44-n = `type`.
    temp44-v = type.
    APPEND temp44 TO temp43.
    temp44-n = `class`.
    temp44-v = class.
    APPEND temp44 TO temp43.
    _generic(
       name   = `Button`
       t_prop = temp43 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~input.

    result = me.
    DATA temp45 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp45.
    DATA temp46 LIKE LINE OF temp45.
    temp46-n = `id`.
    temp46-v = id.
    APPEND temp46 TO temp45.
    temp46-n = `placeholder`.
    temp46-v = placeholder.
    APPEND temp46 TO temp45.
    temp46-n = `type`.
    temp46-v = type.
    APPEND temp46 TO temp45.
    temp46-n = `showClearIcon`.
    temp46-v = _=>get_json_boolean( showclearicon ).
    APPEND temp46 TO temp45.
    temp46-n = `description`.
    temp46-v = description.
    APPEND temp46 TO temp45.
    temp46-n = `editable`.
    temp46-v = _=>get_json_boolean( editable ).
    APPEND temp46 TO temp45.
    temp46-n = `enabled`.
    temp46-v = _=>get_json_boolean( enabled ).
    APPEND temp46 TO temp45.
    temp46-n = `valueState`.
    temp46-v = valuestate.
    APPEND temp46 TO temp45.
    temp46-n = `valueStateText`.
    temp46-v = valuestatetext.
    APPEND temp46 TO temp45.
    temp46-n = `value`.
    temp46-v = value.
    APPEND temp46 TO temp45.
    temp46-n = `suggestionItems`.
    temp46-v = suggestionitems.
    APPEND temp46 TO temp45.
    temp46-n = `showSuggestion`.
    temp46-v = _=>get_json_boolean( showsuggestion ).
    APPEND temp46 TO temp45.
    temp46-n = `valueHelpRequest`.
    temp46-v = valuehelprequest.
    APPEND temp46 TO temp45.
    temp46-n = `showValueHelp`.
    temp46-v = _=>get_json_boolean( showvaluehelp ).
    APPEND temp46 TO temp45.
    _generic(
       name   = `Input`
       t_prop = temp45 ).

  ENDMETHOD.

  METHOD get_view.

    CONSTANTS c_prefix TYPE string VALUE `M_ROOT->MO_RUNTIME->MS_DB-O_APP->`.

    result-xml = m_root->xml_get( check_popup_active ).

    DATA m_view_model TYPE REF TO z2ui5_lcl_utility_tree_json.
    m_view_model = z2ui5_lcl_utility_tree_json=>factory( ).
    DATA lo_update TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_update = m_view_model->add_attribute_object( `oUpdate` ).

    DATA temp13 LIKE LINE OF mo_runtime->ms_db-t_attri.
    DATA lr_attri LIKE REF TO temp13.
    LOOP AT mo_runtime->ms_db-t_attri REFERENCE INTO lr_attri WHERE bind_type <> ``.

      IF lr_attri->bind_type = z2ui5_lcl_system_runtime=>cs_bind_type-one_time.

        m_view_model->add_attribute(
              n = lr_attri->name
              v = lr_attri->data_stringify
              apos_active = abap_false ).

        CONTINUE.
      ENDIF.

      DATA temp14 TYPE REF TO z2ui5_lcl_utility_tree_json.
      IF lr_attri->bind_type = z2ui5_lcl_system_runtime=>cs_bind_type-one_way.
        temp14 = m_view_model.
      ELSE.
        temp14 = lo_update.
      ENDIF.
      DATA lo_actual LIKE temp14.
      lo_actual = temp14.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      _=>raise( when = boolc( sy-subrc <> 0 ) ).

      CASE lr_attri->type_kind.

        WHEN `g` OR `D` OR `P` OR `T` OR `C`.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = _=>get_abap_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN `I`.
          DATA temp15 TYPE string.
          temp15 = <attribute>.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = temp15
                                    apos_active = abap_false ).

        WHEN `h`.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = _=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

      ENDCASE.
    ENDLOOP.

    IF lo_update->mt_values IS INITIAL.
      lo_update->mv_value = `{}`.
      lo_update->mv_apost_active = abap_false.
    ENDIF.

    result-o_model = m_view_model.
    DELETE m_root->mo_runtime->ms_db-t_attri WHERE bind_type = z2ui5_lcl_system_runtime=>cs_bind_type-one_time.
    result-t_attri = m_root->mo_runtime->ms_db-t_attri.

  ENDMETHOD.

  METHOD z2ui5_if_view~page.

    DATA temp47 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp47.
    DATA temp48 LIKE LINE OF temp47.
    temp48-n = `title`.
    temp48-v = title.
    APPEND temp48 TO temp47.
    temp48-n = `showNavButton`.
    DATA temp16 TYPE z2ui5_lcl_utility=>ty_s_name_value-v.
    IF navbuttonpress = ``.
      temp16 = `false`.
    ELSE.
      temp16 = `true`.
    ENDIF.
    temp48-v = temp16.
    APPEND temp48 TO temp47.
    temp48-n = `navButtonPress`.
    temp48-v = navbuttonpress.
    APPEND temp48 TO temp47.
    temp48-n = `class`.
    temp48-v = class.
    APPEND temp48 TO temp47.
    temp48-n = `id`.
    temp48-v = id.
    APPEND temp48 TO temp47.
    result = _generic(
        name   = `Page`
         t_prop = temp47 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~vbox.

    DATA temp49 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp49.
    DATA temp50 LIKE LINE OF temp49.
    temp50-n = `height`.
    temp50-v = height.
    APPEND temp50 TO temp49.
    temp50-n = `class`.
    temp50-v = class.
    APPEND temp50 TO temp49.
    result = _generic(
         name   = `VBox`
         t_prop = temp49 ).

  ENDMETHOD.


  METHOD z2ui5_if_view~hbox.

    DATA temp51 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp51.
    DATA temp52 LIKE LINE OF temp51.
    temp52-n = `class`.
    temp52-v = `sapUiSmallMargin`.
    APPEND temp52 TO temp51.
    result = _generic(
          name   = `HBox`
          t_prop = temp51 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~simple_form.

    DATA temp53 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp53.
    DATA temp54 LIKE LINE OF temp53.
    temp54-n = `title`.
    temp54-v = title.
    APPEND temp54 TO temp53.
    temp54-n = `editable`.
    temp54-v = `true`.
    APPEND temp54 TO temp53.
    temp54-n = `layout`.
    temp54-v = `ResponsiveGridLayout`.
    APPEND temp54 TO temp53.
    result = _generic(
      name   = `SimpleForm`
      ns     = `f`
      t_prop = temp53 ).

  ENDMETHOD.


  METHOD z2ui5_if_view~content.

    result = _generic( ns = ns name = `content` ).

  ENDMETHOD.


  METHOD z2ui5_if_view~title.

    result = me.
    DATA temp55 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp55.
    DATA temp56 LIKE LINE OF temp55.
    temp56-n = `text`.
    temp56-v = title.
    APPEND temp56 TO temp55.
    _generic(
         name  = `Title`
         t_prop = temp55
      ).

  ENDMETHOD.

  METHOD z2ui5_if_view~code_editor.

    result = me.
    DATA temp57 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp57.
    DATA temp58 LIKE LINE OF temp57.
    temp58-n = `value`.
    temp58-v = value.
    APPEND temp58 TO temp57.
    temp58-n = `type`.
    temp58-v = type.
    APPEND temp58 TO temp57.
    temp58-n = `editable`.
    temp58-v = _=>get_json_boolean( editable ).
    APPEND temp58 TO temp57.
    temp58-n = `height`.
    temp58-v = height.
    APPEND temp58 TO temp57.
    temp58-n = `width`.
    temp58-v = width.
    APPEND temp58 TO temp57.
    _generic(
        name  = `CodeEditor`
        ns = `editor`
        t_prop = temp57 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~zz_file_uploader.

    result = me.
    DATA temp59 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp59.
    DATA temp60 LIKE LINE OF temp59.
    temp60-n = `placeholder`.
    temp60-v = placeholder.
    APPEND temp60 TO temp59.
    temp60-n = `upload`.
    temp60-v = upload.
    APPEND temp60 TO temp59.
    temp60-n = `path`.
    temp60-v = path.
    APPEND temp60 TO temp59.
    temp60-n = `value`.
    temp60-v = value.
    APPEND temp60 TO temp59.
    _generic(
      name   = `FileUploader`
      ns     = `z2ui5`
      t_prop = temp59 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~zz_html.

    DATA lt_table TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    SPLIT val AT `<` INTO TABLE lt_table.

    DATA lv_html TYPE string.
    lv_html = ``.
    DATA temp61 TYPE string.
    CLEAR temp61.
    DATA temp62 TYPE string.
    READ TABLE lt_table INTO temp62 INDEX 1.
    IF sy-subrc = 0.
      temp61 = temp62.
    ENDIF.
    lv_html = temp61.

    DATA temp63 LIKE LINE OF lt_table.
    DATA lr_line LIKE REF TO temp63.
    LOOP AT lt_table REFERENCE INTO lr_line FROM 2.
      IF lr_line->*(1) = `/`.
        lv_html = `</html:` && lr_line->*.
      ELSE.
        lv_html = `<html:` && lr_line->*.
      ENDIF.
    ENDLOOP.

    result = me.
    DATA temp64 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp64.
    DATA temp65 LIKE LINE OF temp64.
    temp65-n = `VALUE`.
    temp65-v = lv_html.
    APPEND temp65 TO temp64.
    _generic(
         name  = `ZZHTML`
         t_prop = temp64
    ).

  ENDMETHOD.

  METHOD z2ui5_if_view~overflow_toolbar.

    result = _generic( `OverflowToolbar` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~toolbar_spacer.

    result = me.
    _generic( `ToolbarSpacer` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~combobox.

    DATA temp66 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp66.
    DATA temp67 LIKE LINE OF temp66.
    temp67-n = `showClearIcon`.
    temp67-v = _=>get_json_boolean( showclearicon ).
    APPEND temp67 TO temp66.
    temp67-n = `selectedKey`.
    temp67-v = selectedkey.
    APPEND temp67 TO temp66.
    temp67-n = `items`.
    temp67-v = items.
    APPEND temp67 TO temp66.
    result = _generic(
       name  = `ComboBox`
       t_prop = temp66 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~date_picker.

    result = me.
    DATA temp68 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp68.
    DATA temp69 LIKE LINE OF temp68.
    temp69-n = `value`.
    temp69-v = value.
    APPEND temp69 TO temp68.
    temp69-n = `placeholder`.
    temp69-v = placeholder.
    APPEND temp69 TO temp68.
    _generic(
      name       = `DatePicker`
      t_prop = temp68 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~date_time_picker.

    result = me.
    DATA temp70 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp70.
    DATA temp71 LIKE LINE OF temp70.
    temp71-n = `value`.
    temp71-v = value.
    APPEND temp71 TO temp70.
    temp71-n = `placeholder`.
    temp71-v = placeholder.
    APPEND temp71 TO temp70.
    _generic(
        name  = `DateTimePicker`
        t_prop = temp70 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~label.

    result = me.
    DATA temp72 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp72.
    DATA temp73 LIKE LINE OF temp72.
    temp73-n = `text`.
    temp73-v = text.
    APPEND temp73 TO temp72.
    _generic(
       name  = `Label`
       t_prop = temp72 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~link.

    result = me.
    DATA temp74 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp74.
    DATA temp75 LIKE LINE OF temp74.
    temp75-n = `text`.
    temp75-v = text.
    APPEND temp75 TO temp74.
    temp75-n = `target`.
    temp75-v = `_blank`.
    APPEND temp75 TO temp74.
    temp75-n = `href`.
    temp75-v = href.
    APPEND temp75 TO temp74.
    temp75-n = `enabled`.
    temp75-v = _=>get_json_boolean( enabled ).
    APPEND temp75 TO temp74.
    _generic(
     name  = `Link`
       t_prop = temp74 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segmented_button.

    DATA temp76 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp76.
    DATA temp77 LIKE LINE OF temp76.
    temp77-n = `selectedKey`.
    temp77-v = selected_key.
    APPEND temp77 TO temp76.
    temp77-n = `selectionChange`.
    temp77-v = selection_change.
    APPEND temp77 TO temp76.
    result = _generic(
       name  = `SegmentedButton`
       t_prop = temp76 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~step_input.

    result = me.
    DATA temp78 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp78.
    DATA temp79 LIKE LINE OF temp78.
    temp79-n = `max`.
    temp79-v = max.
    APPEND temp79 TO temp78.
    temp79-n = `min`.
    temp79-v = min.
    APPEND temp79 TO temp78.
    temp79-n = `step`.
    temp79-v = step.
    APPEND temp79 TO temp78.
    temp79-n = `value`.
    temp79-v = value.
    APPEND temp79 TO temp78.
    _generic(
         name  = `StepInput`
         t_prop = temp78 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~switch.

    result = me.
    DATA temp80 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp80.
    DATA temp81 LIKE LINE OF temp80.
    temp81-n = `type`.
    temp81-v = type.
    APPEND temp81 TO temp80.
    temp81-n = `enabled`.
    temp81-v = _=>get_json_boolean( enabled ).
    APPEND temp81 TO temp80.
    temp81-n = `state`.
    temp81-v = state.
    APPEND temp81 TO temp80.
    temp81-n = `customTextOff`.
    temp81-v = customtextoff.
    APPEND temp81 TO temp80.
    temp81-n = `customTextOn`.
    temp81-v = customtexton.
    APPEND temp81 TO temp80.
    _generic(
          name  = `Switch`
          t_prop = temp80 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~range_slider.

    result = me.
    DATA temp82 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp82.
    DATA temp83 LIKE LINE OF temp82.
    temp83-n = `class`.
    temp83-v = class.
    APPEND temp83 TO temp82.
    temp83-n = `endValue`.
    temp83-v = endvalue.
    APPEND temp83 TO temp82.
    temp83-n = `id`.
    temp83-v = id.
    APPEND temp83 TO temp82.
    temp83-n = `labelInterval`.
    temp83-v = labelinterval.
    APPEND temp83 TO temp82.
    temp83-n = `max`.
    temp83-v = max.
    APPEND temp83 TO temp82.
    temp83-n = `min`.
    temp83-v = min.
    APPEND temp83 TO temp82.
    temp83-n = `showTickmarks`.
    temp83-v = _=>get_json_boolean( showtickmarks ).
    APPEND temp83 TO temp82.
    temp83-n = `startValue`.
    temp83-v = startvalue.
    APPEND temp83 TO temp82.
    temp83-n = `step`.
    temp83-v = step.
    APPEND temp83 TO temp82.
    temp83-n = `width`.
    temp83-v = width.
    APPEND temp83 TO temp82.
    _generic(
          name  = `RangeSlider`
          ns    = `webc`
          t_prop = temp82 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~generic_tag.

    DATA temp84 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp84.
    DATA temp85 LIKE LINE OF temp84.
    temp85-n = `ariaLabelledBy`.
    temp85-v = arialabelledby.
    APPEND temp85 TO temp84.
    temp85-n = `class`.
    temp85-v = class.
    APPEND temp85 TO temp84.
    temp85-n = `design`.
    temp85-v = design.
    APPEND temp85 TO temp84.
    temp85-n = `status`.
    temp85-v = status.
    APPEND temp85 TO temp84.
    temp85-n = `text`.
    temp85-v = text.
    APPEND temp85 TO temp84.
    result = _generic(
           name  = `GenericTag`
           t_prop = temp84 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~object_number.

    result = me.
    DATA temp86 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp86.
    DATA temp87 LIKE LINE OF temp86.
    temp87-n = `emphasized`.
    temp87-v = _=>get_json_boolean( emphasized ).
    APPEND temp87 TO temp86.
    temp87-n = `number`.
    temp87-v = number.
    APPEND temp87 TO temp86.
    temp87-n = `state`.
    temp87-v = state.
    APPEND temp87 TO temp86.
    temp87-n = `unit`.
    temp87-v = unit.
    APPEND temp87 TO temp86.
    _generic(
        name  = `ObjectNumber`
        t_prop = temp86 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~text_area.

    result = me.
    DATA temp88 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp88.
    DATA temp89 LIKE LINE OF temp88.
    temp89-n = `value`.
    temp89-v = value.
    APPEND temp89 TO temp88.
    temp89-n = `rows`.
    temp89-v = rows.
    APPEND temp89 TO temp88.
    temp89-n = `height`.
    temp89-v = height.
    APPEND temp89 TO temp88.
    temp89-n = `width`.
    temp89-v = width.
    APPEND temp89 TO temp88.
    temp89-n = `editable`.
    temp89-v = _=>get_json_boolean( editable ).
    APPEND temp89 TO temp88.
    temp89-n = `enabled`.
    temp89-v = _=>get_json_boolean( enabled ).
    APPEND temp89 TO temp88.
    temp89-n = `id`.
    temp89-v = id.
    APPEND temp89 TO temp88.
    temp89-n = `growing`.
    temp89-v = _=>get_json_boolean( growing ).
    APPEND temp89 TO temp88.
    temp89-n = `growingMaxLines`.
    temp89-v = growingmaxlines.
    APPEND temp89 TO temp88.
    _generic(
          name  = `TextArea`
            t_prop = temp88 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~time_picker.

    result = me.
    DATA temp90 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp90.
    DATA temp91 LIKE LINE OF temp90.
    temp91-n = `value`.
    temp91-v = value.
    APPEND temp91 TO temp90.
    temp91-n = `placeholder`.
    temp91-v = placeholder.
    APPEND temp91 TO temp90.
    _generic(
     name   = `TimePicker`
     t_prop = temp90 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~checkbox.

    result = me.
    DATA temp92 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp92.
    DATA temp93 LIKE LINE OF temp92.
    temp93-n = `text`.
    temp93-v = text.
    APPEND temp93 TO temp92.
    temp93-n = `selected`.
    temp93-v = selected.
    APPEND temp93 TO temp92.
    temp93-n = `enabled`.
    temp93-v = _=>get_json_boolean( enabled ).
    APPEND temp93 TO temp92.
    _generic(
       name  = `CheckBox`
       t_prop = temp92 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~progress_indicator.

    result = me.
    DATA temp94 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp94.
    DATA temp95 LIKE LINE OF temp94.
    temp95-n = `percentValue`.
    temp95-v = percentvalue.
    APPEND temp95 TO temp94.
    temp95-n = `displayValue`.
    temp95-v = displayvalue.
    APPEND temp95 TO temp94.
    temp95-n = `showValue`.
    temp95-v = _=>get_json_boolean( showvalue ).
    APPEND temp95 TO temp94.
    temp95-n = `state`.
    temp95-v = state.
    APPEND temp95 TO temp94.
    _generic(
         name  = `ProgressIndicator`
         t_prop = temp94 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~text.

    result = me.
    DATA temp96 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp96.
    DATA temp97 LIKE LINE OF temp96.
    temp97-n = `text`.
    temp97-v = text.
    APPEND temp97 TO temp96.
    temp97-n = `class`.
    temp97-v = class.
    APPEND temp97 TO temp96.
    _generic(
      name  = `Text`
      t_prop = temp96 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~table.

    DATA temp98 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp98.
    DATA temp99 LIKE LINE OF temp98.
    temp99-n = `items`.
    temp99-v = items.
    APPEND temp99 TO temp98.
    temp99-n = `headerText`.
    temp99-v = headertext.
    APPEND temp99 TO temp98.
    temp99-n = `growing`.
    temp99-v = growing.
    APPEND temp99 TO temp98.
    temp99-n = `growingThreshold`.
    temp99-v = growingthreshold.
    APPEND temp99 TO temp98.
    temp99-n = `growingScrollToLoad`.
    temp99-v = growingscrolltoload.
    APPEND temp99 TO temp98.
    temp99-n = `sticky`.
    temp99-v = sticky.
    APPEND temp99 TO temp98.
    temp99-n = `mode`.
    temp99-v = mode.
    APPEND temp99 TO temp98.
    temp99-n = `width`.
    temp99-v = width.
    APPEND temp99 TO temp98.
    result = _generic(
        name  = `Table`
        t_prop = temp98 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~cells.

    result = _generic( `cells` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~column.

    DATA temp100 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp100.
    DATA temp101 LIKE LINE OF temp100.
    temp101-n = `width`.
    temp101-v = width.
    APPEND temp101 TO temp100.
    result = _generic(
        name  = `Column`
          t_prop = temp100
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~columns.

    result = _generic( `columns` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~column_list_item.

    DATA temp102 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp102.
    DATA temp103 LIKE LINE OF temp102.
    temp103-n = `vAlign`.
    temp103-v = valign.
    APPEND temp103 TO temp102.
    temp103-n = `selected`.
    temp103-v = selected.
    APPEND temp103 TO temp102.
    result = _generic(
        name = `ColumnListItem`
        t_prop = temp102 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~items.

    result = _generic( `items` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~grid.

    DATA temp104 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp104.
    DATA temp105 LIKE LINE OF temp104.
    temp105-n = `defaultSpan`.
    temp105-v = default_span.
    APPEND temp105 TO temp104.
    temp105-n = `class`.
    temp105-v = class.
    APPEND temp105 TO temp104.
    result = _generic(
        name = `Grid`
        ns   = `l`
        t_prop = temp104 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~header_toolbar.

    result = _generic( `headerToolbar` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~scroll_container.

    DATA temp106 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp106.
    DATA temp107 LIKE LINE OF temp106.
    temp107-n = `height`.
    temp107-v = height.
    APPEND temp107 TO temp106.
    temp107-n = `width`.
    temp107-v = width.
    APPEND temp107 TO temp106.
    temp107-n = `vertical`.
    temp107-v = _=>get_json_boolean( vertical ).
    APPEND temp107 TO temp106.
    temp107-n = `horizontal`.
    temp107-v = _=>get_json_boolean( horizontal ).
    APPEND temp107 TO temp106.
    temp107-n = `focusable`.
    temp107-v = _=>get_json_boolean( focusable ).
    APPEND temp107 TO temp106.
    result = _generic(
        name = `ScrollContainer`
        t_prop = temp106 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~header_content.

    result = _generic( `headerContent` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~sub_header.

    result = _generic( `subHeader` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~footer.

    result = _generic( `footer` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~dialog.

    DATA temp108 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp108.
    DATA temp109 LIKE LINE OF temp108.
    temp109-n = `title`.
    temp109-v = title.
    APPEND temp109 TO temp108.
    temp109-n = `icon`.
    temp109-v = icon.
    APPEND temp109 TO temp108.
    temp109-n = `stretch`.
    temp109-v = stretch.
    APPEND temp109 TO temp108.
    temp109-n = `showHeader`.
    temp109-v = showheader.
    APPEND temp109 TO temp108.
    temp109-n = `contentWidth`.
    temp109-v = contentwidth.
    APPEND temp109 TO temp108.
    temp109-n = `contentHeight`.
    temp109-v = contentheight.
    APPEND temp109 TO temp108.
    result = _generic(
         name = `Dialog`
        t_prop = temp108 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~list.

    DATA temp110 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp110.
    DATA temp111 LIKE LINE OF temp110.
    temp111-n = `headerText`.
    temp111-v = headertext.
    APPEND temp111 TO temp110.
    temp111-n = `items`.
    temp111-v = items.
    APPEND temp111 TO temp110.
    result = _generic(
        name = `List`
        t_prop = temp110 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~standard_list_item.

    result = me.
    DATA temp112 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp112.
    DATA temp113 LIKE LINE OF temp112.
    temp113-n = `title`.
    temp113-v = title.
    APPEND temp113 TO temp112.
    temp113-n = `description`.
    temp113-v = description.
    APPEND temp113 TO temp112.
    temp113-n = `icon`.
    temp113-v = icon.
    APPEND temp113 TO temp112.
    temp113-n = `info`.
    temp113-v = info.
    APPEND temp113 TO temp112.
    temp113-n = `press`.
    temp113-v = press.
    APPEND temp113 TO temp112.
    _generic(
        name = `StandardListItem`
        t_prop = temp112 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~message_page.

    DATA temp114 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp114.
    DATA temp115 LIKE LINE OF temp114.
    temp115-n = `showHeader`.
    temp115-v = _=>get_json_boolean( show_header ).
    APPEND temp115 TO temp114.
    temp115-n = `description`.
    temp115-v = description.
    APPEND temp115 TO temp114.
    temp115-n = `icon`.
    temp115-v = icon.
    APPEND temp115 TO temp114.
    temp115-n = `text`.
    temp115-v = text.
    APPEND temp115 TO temp114.
    temp115-n = `enableFormattedText`.
    temp115-v = _=>get_json_boolean( enableformattedtext ).
    APPEND temp115 TO temp114.
    result = _generic(
        name   = `MessagePage`
        t_prop = temp114 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~buttons.

    result = _generic( `buttons` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~get_parent.
    result = m_parent.
  ENDMETHOD.

  METHOD z2ui5_if_view~message_strip.

    result = me.
    DATA temp116 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp116.
    DATA temp117 LIKE LINE OF temp116.
    temp117-n = `text`.
    temp117-v = text.
    APPEND temp117 TO temp116.
    temp117-n = `type`.
    temp117-v = type.
    APPEND temp117 TO temp116.
    temp117-n = `showIcon`.
    temp117-v = _=>get_json_boolean( showicon ).
    APPEND temp117 TO temp116.
    temp117-n = `class`.
    temp117-v = class.
    APPEND temp117 TO temp116.
    _generic(
        name   = `MessageStrip`
        t_prop = temp116 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~list_item.

    result = me.
    DATA temp118 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp118.
    DATA temp119 LIKE LINE OF temp118.
    temp119-n = `text`.
    temp119-v = text.
    APPEND temp119 TO temp118.
    temp119-n = `additionalText`.
    temp119-v = additionaltext.
    APPEND temp119 TO temp118.
    _generic(
        name   = `ListItem`
        ns     = `core`
        t_prop = temp118 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~suggestion_items.

    result = _generic( `suggestionItems` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~item.

    result = me.
    DATA temp120 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp120.
    DATA temp121 LIKE LINE OF temp120.
    temp121-n = `key`.
    temp121-v = key.
    APPEND temp121 TO temp120.
    temp121-n = `text`.
    temp121-v = text.
    APPEND temp121 TO temp120.
    _generic(
       name = `Item`
       ns = `core`
       t_prop = temp120 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segmented_button_item.

    result = me.
    DATA temp122 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp122.
    DATA temp123 LIKE LINE OF temp122.
    temp123-n = `icon`.
    temp123-v = icon.
    APPEND temp123 TO temp122.
    temp123-n = `key`.
    temp123-v = key.
    APPEND temp123 TO temp122.
    temp123-n = `text`.
    temp123-v = text.
    APPEND temp123 TO temp122.
    _generic(
        name = `SegmentedButtonItem`
        t_prop = temp122 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~get_child.

    DATA temp124 LIKE LINE OF t_child.
    DATA temp125 LIKE sy-tabix.
    temp125 = sy-tabix.
    READ TABLE t_child INDEX index INTO temp124.
    sy-tabix = temp125.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    result = temp124.

  ENDMETHOD.

  METHOD z2ui5_if_view~get.

    result = m_root->m_last.

  ENDMETHOD.

  METHOD z2ui5_if_view~flex_box.


    DATA temp126 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp126.
    DATA temp127 LIKE LINE OF temp126.
    temp127-n = `class`.
    temp127-v = class.
    APPEND temp127 TO temp126.
    temp127-n = `renderType`.
    temp127-v = rendertype.
    APPEND temp127 TO temp126.
    temp127-n = `width`.
    temp127-v = width.
    APPEND temp127 TO temp126.
    temp127-n = `height`.
    temp127-v = height.
    APPEND temp127 TO temp126.
    temp127-n = `alignItems`.
    temp127-v = alignitems.
    APPEND temp127 TO temp126.
    temp127-n = `justifyContent`.
    temp127-v = justifycontent.
    APPEND temp127 TO temp126.
    result = _generic(
          name   = `FlexBox`
          t_prop = temp126 ).


  ENDMETHOD.

  METHOD z2ui5_if_view~horizontal_layout.

    DATA temp128 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp128.
    DATA temp129 LIKE LINE OF temp128.
    temp129-n = `class`.
    temp129-v = class.
    APPEND temp129 TO temp128.
    temp129-n = `width`.
    temp129-v = width.
    APPEND temp129 TO temp128.
    result = _generic(
        name   = `HorizontalLayout`
        ns     = `l`
        t_prop = temp128 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~vertical_layout.

    DATA temp130 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp130.
    DATA temp131 LIKE LINE OF temp130.
    temp131-n = `class`.
    temp131-v = class.
    APPEND temp131 TO temp130.
    temp131-n = `width`.
    temp131-v = width.
    APPEND temp131 TO temp130.
    result = _generic(
        name   = `VerticalLayout`
        ns     = `l`
        t_prop = temp130 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~flex_item_data.

    result = me.

    DATA temp132 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp132.
    DATA temp133 LIKE LINE OF temp132.
    temp133-n = `growFactor`.
    temp133-v = growfactor.
    APPEND temp133 TO temp132.
    temp133-n = `baseSize`.
    temp133-v = basesize.
    APPEND temp133 TO temp132.
    temp133-n = `backgroundDesign`.
    temp133-v = backgrounddesign.
    APPEND temp133 TO temp132.
    temp133-n = `styleClass`.
    temp133-v = styleclass.
    APPEND temp133 TO temp132.
    _generic(
          name = `FlexItemData`
        t_prop = temp132 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~grid_data.

    result = me.
    DATA temp134 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp134.
    DATA temp135 LIKE LINE OF temp134.
    temp135-n = `span`.
    temp135-v = span.
    APPEND temp135 TO temp134.
    _generic(
           name = `GridData`
           ns = `l`
        t_prop = temp134 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~layout_data.

    result = _generic(
            ns = ns
           name = `layoutData`
       ).

  ENDMETHOD.

  METHOD z2ui5_if_view~tab.

    DATA temp136 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp136.
    DATA temp137 LIKE LINE OF temp136.
    temp137-n = `text`.
    temp137-v = text.
    APPEND temp137 TO temp136.
    temp137-n = `selected`.
    temp137-v = selected.
    APPEND temp137 TO temp136.
    result = _generic(
         name = `Tab`
         ns = `webc`
         t_prop = temp136 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~tab_container.

    result = _generic(
        name = `TabContainer`
        ns   = `webc` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~bars.

    result = _generic(
        name = `bars`
        ns   = `mchart` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_bar_chart.

    DATA temp138 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp138.
    DATA temp139 LIKE LINE OF temp138.
    temp139-n = `selectionChanged`.
    temp139-v = selectionchanged.
    APPEND temp139 TO temp138.
    temp139-n = `showError`.
    temp139-v = showerror.
    APPEND temp139 TO temp138.
    temp139-n = `press`.
    temp139-v = press.
    APPEND temp139 TO temp138.
    temp139-n = `labelWidth`.
    temp139-v = labelwidth.
    APPEND temp139 TO temp138.
    temp139-n = `errorMessageTitle`.
    temp139-v = errormessagetitle.
    APPEND temp139 TO temp138.
    temp139-n = `errorMessage`.
    temp139-v = errormessage.
    APPEND temp139 TO temp138.
    result = _generic(
        name = `InteractiveBarChart`
        ns   = `mchart`
        t_prop = temp138 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_bar_chart_bar.

    DATA temp140 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp140.
    DATA temp141 LIKE LINE OF temp140.
    temp141-n = `label`.
    temp141-v = label.
    APPEND temp141 TO temp140.
    temp141-n = `displayedValue`.
    temp141-v = displayedvalue.
    APPEND temp141 TO temp140.
    temp141-n = `value`.
    temp141-v = value.
    APPEND temp141 TO temp140.
    temp141-n = `selected`.
    temp141-v = selected.
    APPEND temp141 TO temp140.
    result = _generic(
         name = `InteractiveBarChartBar`
         ns = `mchart`
         t_prop = temp140 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_donut_chart.

    DATA temp142 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp142.
    DATA temp143 LIKE LINE OF temp142.
    temp143-n = `selectionChanged`.
    temp143-v = selectionchanged.
    APPEND temp143 TO temp142.
    temp143-n = `showError`.
    temp143-v = _=>get_json_boolean( showerror ).
    APPEND temp143 TO temp142.
    temp143-n = `errorMessageTitle`.
    temp143-v = errormessagetitle.
    APPEND temp143 TO temp142.
    temp143-n = `errorMessage`.
    temp143-v = errormessage.
    APPEND temp143 TO temp142.
    temp143-n = `displayedSegments`.
    temp143-v = displayedsegments.
    APPEND temp143 TO temp142.
    temp143-n = `press`.
    temp143-v = press.
    APPEND temp143 TO temp142.
    result = _generic(
         name = `InteractiveDonutChart`
         ns   = `mchart`
         t_prop = temp142 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_donut_chart_segment.

    DATA temp144 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp144.
    DATA temp145 LIKE LINE OF temp144.
    temp145-n = `label`.
    temp145-v = label.
    APPEND temp145 TO temp144.
    temp145-n = `displayedValue`.
    temp145-v = displayedvalue.
    APPEND temp145 TO temp144.
    temp145-n = `value`.
    temp145-v = value.
    APPEND temp145 TO temp144.
    temp145-n = `selected`.
    temp145-v = selected.
    APPEND temp145 TO temp144.
    result = _generic(
         name = `InteractiveDonutChartSegment`
         ns   = `mchart`
         t_prop = temp144 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_line_chart.

    DATA temp146 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp146.
    DATA temp147 LIKE LINE OF temp146.
    temp147-n = `selectionChanged`.
    temp147-v = selectionchanged.
    APPEND temp147 TO temp146.
    temp147-n = `showError`.
    temp147-v = _=>get_json_boolean( showerror ).
    APPEND temp147 TO temp146.
    temp147-n = `press`.
    temp147-v = press.
    APPEND temp147 TO temp146.
    temp147-n = `errorMessageTitle`.
    temp147-v = errormessagetitle.
    APPEND temp147 TO temp146.
    temp147-n = `errorMessage`.
    temp147-v = errormessage.
    APPEND temp147 TO temp146.
    temp147-n = `precedingPoint`.
    temp147-v = precedingpoint.
    APPEND temp147 TO temp146.
    temp147-n = `succeedingPoint`.
    temp147-v = succeddingpoint.
    APPEND temp147 TO temp146.
    result = _generic(
         name = `InteractiveLineChart`
         ns = `mchart`
         t_prop = temp146 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_line_chart_point.

    DATA temp148 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp148.
    DATA temp149 LIKE LINE OF temp148.
    temp149-n = `label`.
    temp149-v = label.
    APPEND temp149 TO temp148.
    temp149-n = `secondaryLabel`.
    temp149-v = secondarylabel.
    APPEND temp149 TO temp148.
    temp149-n = `value`.
    temp149-v = value.
    APPEND temp149 TO temp148.
    temp149-n = `displayedValue`.
    temp149-v = displayedvalue.
    APPEND temp149 TO temp148.
    temp149-n = `selected`.
    temp149-v = _=>get_json_boolean( selected ).
    APPEND temp149 TO temp148.
    result = _generic(
         name   = `InteractiveLineChartPoint`
         ns     = `mchart`
         t_prop = temp148 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~points.

    result = _generic(
         name = `points`
         ns   = `mchart` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~radial_micro_chart.

    result = me.
    DATA temp150 TYPE z2ui5_lcl_utility=>ty_t_name_value.
    CLEAR temp150.
    DATA temp151 LIKE LINE OF temp150.
    temp151-n = `percentage`.
    temp151-v = percentage.
    APPEND temp151 TO temp150.
    temp151-n = `press`.
    temp151-v = press.
    APPEND temp151 TO temp150.
    temp151-n = `sice`.
    temp151-v = sice.
    APPEND temp151 TO temp150.
    temp151-n = `valueColor`.
    temp151-v = valuecolor.
    APPEND temp151 TO temp150.
    _generic(
        name   = `RadialMicroChart`
        ns     = `mchart`
        t_prop = temp150 ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segments.

    result = _generic(
        name = `segments`
        ns   = `mchart` ).

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_system_app DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF ms_error,
        x_error   TYPE REF TO cx_root,
        app       TYPE REF TO z2ui5_if_app,
        classname TYPE string,
        kind      TYPE string,
      END OF ms_error.

    DATA:
      BEGIN OF ms_home,
        is_initialized         TYPE abap_bool,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.

    CLASS-METHODS factory_error
      IMPORTING
        error         TYPE REF TO cx_root
        app           TYPE REF TO object OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_system_app.

  PROTECTED SECTION.

    DATA mv_is_initialized TYPE abap_bool.

    METHODS z2ui5_on_init
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_rendering
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

ENDCLASS.

CLASS z2ui5_lcl_system_app IMPLEMENTATION.

  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.
      WHEN client->cs-lifecycle_method-on_event.
        IF mv_is_initialized = abap_false.
          mv_is_initialized = abap_true.
          z2ui5_on_init( client ).
        ENDIF.

        z2ui5_on_event( client ).
      WHEN client->cs-lifecycle_method-on_rendering.
        z2ui5_on_rendering( client ).
    ENDCASE.

  ENDMETHOD.

  METHOD factory_error.

    CREATE OBJECT result.
    result->ms_error-x_error = error.
    DATA temp152 TYPE REF TO z2ui5_if_app.
    temp152 ?= app.
    result->ms_error-app     = temp152.

  ENDMETHOD.


  METHOD z2ui5_on_init.
    IF ms_error-x_error IS NOT BOUND.
      client->show_view( `HOME` ).
      ms_home-is_initialized = abap_true.
      ms_home-btn_text = `check`.
      ms_home-btn_event_id = `BUTTON_CHECK`.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = `sap-icon://validate`.
    ELSE.
      client->show_view( `ERROR` ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-view_active.

      WHEN `HOME`.
        CASE client->get( )-event.

          WHEN `BUTTON_CHANGE`.
            ms_home-btn_text = `check`.
            ms_home-btn_event_id = `BUTTON_CHECK`.
            ms_home-btn_icon = `sap-icon://validate`.
            ms_home-class_editable = abap_true.

          WHEN `BUTTON_CHECK`.
            TRY.
                DATA li_app_test TYPE REF TO z2ui5_if_app.
                ms_home-classname = _=>get_trim_upper( ms_home-classname ).
                CREATE OBJECT li_app_test TYPE (ms_home-classname).

                client->popup_message_toast( `App is ready to start!` ).
                ms_home-btn_text = `edit`.
                ms_home-btn_event_id = `BUTTON_CHANGE`.
                ms_home-btn_icon = `sap-icon://edit`.
                ms_home-class_value_state = `Success`.
                ms_home-class_editable = abap_false.

                DATA lx TYPE REF TO cx_root.
              CATCH cx_root INTO lx.
                ms_home-class_value_state_text = lx->get_text( ).
                ms_home-class_value_state = `Warning`.
                client->popup_message_box( text = ms_home-class_value_state_text type = `error` ).
            ENDTRY.

          WHEN `DEMOS`.
            DATA li_app TYPE REF TO z2ui5_if_app.
            TRY.
                CREATE OBJECT li_app TYPE (`Z2UI5_CL_APP_DEMO_00`).
                client->nav_app_call( li_app ).
              CATCH cx_root.
                client->popup_message_box( `Demos not available. Check the demo folder or you release is lower v750` ).
            ENDTRY.
        ENDCASE.

      WHEN `ERROR`.
        CASE client->get( )-event.

          WHEN `BUTTON_HOME`.
            client->nav_app_home( ).

          WHEN `BUTTON_BACK`.
            client->nav_app_leave( client->get( )-id_prev_app ).

        ENDCASE.
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    IF ms_error-x_error IS BOUND.

      DATA lv_prog TYPE syrepid.
      DATA lv_incl TYPE syrepid.
      DATA lv_line TYPE i.
      ms_error-x_error->get_source_position(
        IMPORTING
          program_name = lv_prog
          include_name = lv_incl
          source_line  = lv_line
      ).

      DATA view TYPE REF TO z2ui5_if_view.
      view = client->factory_view( `ERROR` ).
      view->message_page(
          text = `500 Internal Server Error`
          enableformattedtext = abap_true
          description = ms_error-x_error->get_text( ) &&
            ` -------------------------------------------------------------------------------------------- Source Code Position: ` &&
            lv_prog && ` / ` && lv_incl && ` / ` && lv_line && ` `
          icon = `sap-icon://message-error`
        )->buttons(
        )->button(
              text  = `HOME`
              press = client->_event( `BUTTON_HOME` )
        )->button(
              text = `BACK`
              press = client->_event( `BUTTON_BACK` )
              type = `Emphasized`
        ).

      RETURN.
    ENDIF.

    view = client->factory_view( `HOME` ).
    DATA page TYPE REF TO z2ui5_if_view.
    page = view->page(
        class = `sapUiContentPadding sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer`
        ).
    page->header_content(
      )->title( ``
      )->title( `abap2UI5 - Development of UI5 Apps in pure ABAP`
      )->toolbar_spacer(
        )->link( text = `SCN` href = `https://blogs.sap.com/tag/abap2ui5/`
        )->link( text = `Twitter` href = `https://twitter.com/OblomovDev`
        )->link( text = `GitHub` href = `https://github.com/oblomov-dev/abap2ui5` ).

    DATA grid TYPE REF TO z2ui5_if_view.
    grid = page->grid( `XL7 L7 M12 S12` )->content( `l` ).
    DATA form TYPE REF TO z2ui5_if_view.
    form = grid->simple_form( `Quick Start` )->content( `f` ).

    form->label( `Step 1`
       )->text( `Create a global class in your abap system`
       )->label( `Step 2`
       )->text( `Add the interface: Z2UI5_IF_APP`
       )->label( `Step 3`
       )->text( `Define view, implement behaviour`
       )->link( text = `(Example)` href = `https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/00/z2ui5_cl_app_demo_01.clas.abap`
       )->label( `Step 4`
    ).

    IF ms_home-class_editable = abap_true.
      form->input(
           value          = client->_bind( ms_home-classname )
           placeholder    = `fill in the class name and press 'check' `
           valuestate     = ms_home-class_value_state
           valuestatetext = ms_home-class_value_state_text
           editable       = ms_home-class_editable
       ).
    ELSE.
      form->text( ms_home-classname ).
    ENDIF.

    form->button( text = ms_home-btn_text press = client->_event( ms_home-btn_event_id ) icon = ms_home-btn_icon
       )->label( `Step 5` ).

    DATA lv_link TYPE string.
    lv_link = client->get( )-s_request-url_app_gen && ms_home-classname.
    form->link( text = `Link to the Application` href = lv_link enabled = boolc( ms_home-class_editable = abap_false ) ).

    grid->simple_form( `Applications and Examples` )->content( `f`
                )->button( text = `Continue...` press = client->_event( `DEMOS` ) ).

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_db IMPLEMENTATION.

  METHOD load_app.

    DATA ls_db TYPE z2ui5_t_draft.
    ls_db = read( id ).

    _=>trans_xml_2_object(
      EXPORTING
        xml    = ls_db-data
      IMPORTING
        data   = result ).

  ENDMETHOD.

  METHOD create.

    DATA temp17 LIKE REF TO db.
    GET REFERENCE OF db INTO temp17.
DATA temp2 TYPE z2ui5_t_draft.
CLEAR temp2.
temp2-uuid = id.
temp2-uname = _=>get_user_tech( ).
temp2-timestampl = _=>get_timestampl( ).
temp2-data = _=>trans_object_2_xml( temp17 ).
DATA ls_db LIKE temp2.
ls_db = temp2.

    MODIFY z2ui5_t_draft FROM ls_db.
    _=>raise( when = boolc( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

    SELECT SINGLE *
      FROM z2ui5_t_draft
    INTO result
    WHERE uuid = id.
    _=>raise( when = boolc( sy-subrc <> 0 ) ).

  ENDMETHOD.

  METHOD cleanup.

    DATA lv_timestampl TYPE timestampl.

    DATA lv_time LIKE sy-uzeit.
    lv_time = sy-uzeit.
    lv_time = lv_time - ( 60 * 60 * 4 ).

    CONVERT DATE sy-datum TIME lv_time
       INTO TIME STAMP lv_timestampl TIME ZONE sy-zonlo.

    DELETE FROM z2ui5_t_draft WHERE timestampl < lv_timestampl.
    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_if_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_runtime TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS constructor
      IMPORTING
        runtime TYPE REF TO z2ui5_lcl_system_runtime.

ENDCLASS.

CLASS z2ui5_lcl_system_runtime IMPLEMENTATION.

  METHOD request_begin.

    CLEAR ss_client.
    ss_client-t_header = z2ui5_cl_http_handler=>client-t_header.
    ss_client-t_param = z2ui5_cl_http_handler=>client-t_param.
    ss_client-o_body = z2ui5_lcl_utility_tree_json=>factory( z2ui5_cl_http_handler=>client-body ).

    TRY.
        DATA lv_id_prev TYPE string.
        lv_id_prev = ss_client-o_body->get_attribute( `OSYSTEM` )->get_attribute( `ID` )->get_val( ).
      CATCH cx_root.
        result = set_app_start( ).
        RETURN.
    ENDTRY.

    result = set_app_update_by_client( lv_id_prev ).

  ENDMETHOD.


  METHOD request_end.

    _=>raise( when = boolc( lines( ms_next-t_view ) = 0 ) ).

    IF ms_next-view IS NOT INITIAL.
      IF ms_next-check_set_prev_view = abap_true.
        _=>raise( `New view_show called and set_prev_view active - both not possible` ).
      ENDIF.
      TRY.
          FIELD-SYMBOLS <temp18> TYPE s_view.
          READ TABLE ms_next-t_view WITH KEY name = ms_next-view ASSIGNING <temp18>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
DATA lr_view LIKE REF TO <temp18>.
GET REFERENCE OF <temp18> INTO lr_view.
        CATCH cx_root.
          _=>raise( `View with the name ` && ms_next-view && ` not found - check the rendering` ).
      ENDTRY.
    ELSEIF ms_actual-view_active IS NOT INITIAL AND ms_next-view_popup IS INITIAL.
      TRY.
          FIELD-SYMBOLS <temp19> TYPE s_view.
          READ TABLE ms_next-t_view WITH KEY name = ms_actual-view_active ASSIGNING <temp19>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
GET REFERENCE OF <temp19> INTO lr_view.
          ms_next-view = ms_actual-view_active.
        CATCH cx_root.
          _=>raise( `View with the name ` && ms_actual-view_active && ` not found - check the rendering` ).
      ENDTRY.
    ELSEIF ms_next-view_popup IS INITIAL.
      FIELD-SYMBOLS <temp20> TYPE s_view.
      READ TABLE ms_next-t_view INDEX 1 ASSIGNING <temp20>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
GET REFERENCE OF <temp20> INTO lr_view.
      ms_next-view = lr_view->name.
    ENDIF.

    DATA lo_ui5_model TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_ui5_model = z2ui5_lcl_utility_tree_json=>factory( ).

    IF lr_view IS BOUND.
      ms_db-view_active = lr_view->name.

      DATA ls_view TYPE z2ui5_lcl_if_view=>ty_s_view.
      ls_view = lr_view->o_parser->get_view( ).
      ls_view-o_model->mv_name = `oViewModel`.
      lo_ui5_model->add_attribute( n = `vView` v = ls_view-xml ).
      lo_ui5_model->add_attribute_instance( ls_view-o_model ).
    ENDIF.

    IF ms_next-view_popup IS NOT INITIAL.
      TRY.
          FIELD-SYMBOLS <temp21> TYPE s_view.
          READ TABLE ms_next-t_view WITH KEY name = ms_next-view_popup ASSIGNING <temp21>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
DATA lr_view_popup LIKE REF TO <temp21>.
GET REFERENCE OF <temp21> INTO lr_view_popup.
        CATCH cx_root.
          _=>raise( `Popup with the name ` && ms_next-view_popup && ` not found` ).
      ENDTRY.

      DATA ls_view_popup TYPE z2ui5_lcl_if_view=>ty_s_view.
      ls_view_popup = lr_view_popup->o_parser->get_view( abap_true ).
      ls_view_popup-o_model->mv_name = `oViewModelPopup`.
      lo_ui5_model->add_attribute( n = `vViewPopup` v = ls_view_popup-xml ).
      lo_ui5_model->add_attribute_instance( ls_view_popup-o_model ).
    ENDIF.

    lo_ui5_model->add_attribute_object( `oSystem`
        )->add_attribute( n = `ID`                 v = ms_db-id
        )->add_attribute( n = `CHECK_DEBUG_ACTIVE` v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-check_debug_mode ) apos_active = abap_false ).

    IF ms_next-t_after IS NOT INITIAL.
      DATA lo_list TYPE REF TO z2ui5_lcl_utility_tree_json.
      lo_list = lo_ui5_model->add_attribute_list( `oAfter` ).
      DATA temp22 LIKE LINE OF ms_next-t_after.
      DATA lr_after LIKE REF TO temp22.
      LOOP AT ms_next-t_after REFERENCE INTO lr_after.
        DATA lo_list2 TYPE REF TO z2ui5_lcl_utility_tree_json.
        lo_list2 = lo_list->add_list_list( ).
        DATA temp23 LIKE LINE OF lr_after->*.
        DATA lr_con LIKE REF TO temp23.
        LOOP AT lr_after->* REFERENCE INTO lr_con.
          lo_list2->add_list_val( lr_con->* ).
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    lo_list = lo_ui5_model->add_attribute_list( `oScroll` ).
    DATA temp24 LIKE LINE OF ms_next-t_scroll_pos.
    DATA lr_focus LIKE REF TO temp24.
    LOOP AT ms_next-t_scroll_pos REFERENCE INTO lr_focus.
      lo_list->add_list_object( )->add_attribute( n = lr_focus->name v = lr_focus->value apos_active = abap_false ).
    ENDLOOP.

    IF ms_next-s_cursor_pos IS NOT INITIAL.
      lo_ui5_model->add_attribute_object( `oCursor`
          )->add_attribute( n = `cursorPos`       v = ms_next-s_cursor_pos-cursorpos apos_active = abap_false
          )->add_attribute( n = `id`              v = ms_next-s_cursor_pos-id
          )->add_attribute( n = `selectionEnd`    v = ms_next-s_cursor_pos-selectionend apos_active = abap_false
          )->add_attribute( n = `selectionStart`  v = ms_next-s_cursor_pos-selectionstart apos_active = abap_false ).
    ENDIF.

    IF ms_next-check_set_prev_view = abap_true.
      lo_ui5_model->add_attribute( n = `SET_PREV_VIEW` v = `true` apos_active = abap_false ).
    ENDIF.
    result = lo_ui5_model->get_root( )->write_result( ).

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.


  METHOD set_app_update_by_client.

    CONSTANTS c_prefix TYPE string VALUE `result->MS_DB-O_APP->`.

    CREATE OBJECT result.
    result->ms_db-id = _=>get_uuid( ).
    DATA lv_id LIKE result->ms_db-id.
    lv_id = result->ms_db-id.
    result->ms_db = z2ui5_lcl_db=>load_app( id_prev ).
    result->ms_db-id = lv_id.
    result->ms_db-id_prev = id_prev.

    TRY.
        DATA lo_model TYPE REF TO z2ui5_lcl_utility_tree_json.
        lo_model = ss_client-o_body->get_attribute( `OPOPUP` ).
      CATCH cx_root.
        lo_model = ss_client-o_body.
    ENDTRY.

    DATA temp25 LIKE LINE OF result->ms_db-t_attri.
    DATA lr_attri LIKE REF TO temp25.
    LOOP AT result->ms_db-t_attri REFERENCE INTO lr_attri
        WHERE bind_type = cs_bind_type-two_way.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      _=>raise( when = boolc( sy-subrc <> 0 ) ).

      CASE lr_attri->type_kind.

        WHEN `g` OR `I` OR `C`.
          DATA lv_value TYPE string.
          lv_value = lo_model->get_attribute( lr_attri->name )->get_val( ).
          <attribute> = lv_value.

        WHEN `h`.
          _=>trans_ref_tab_2_tab(
               EXPORTING ir_tab_from = lo_model->get_attribute( lr_attri->name )->mr_actual
               CHANGING ct_to   = <attribute> ).

      ENDCASE.
    ENDLOOP.

    TRY.
        result->ms_next-event = ss_client-o_body->get_attribute( `OEVENT` )->get_attribute( `EVENT` )->get_val( ).
      CATCH cx_root.
    ENDTRY.

    result->ms_next-view = result->ms_db-view_active.
    CLEAR result->ms_db-view_active.

    result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.

  ENDMETHOD.


  METHOD set_app_start.

    CREATE OBJECT result.
    result->ms_db-id = _=>get_uuid( ).
    DO.
      TRY.
          DATA temp153 LIKE LINE OF ss_client-t_param.
          DATA temp154 LIKE sy-tabix.
          temp154 = sy-tabix.
          READ TABLE ss_client-t_param WITH KEY name = `app` INTO temp153.
          sy-tabix = temp154.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
          ENDIF.
          result->ms_db-app_classname = to_upper( temp153-value ).

        CATCH cx_root ##CATCH_ALL.
          CREATE OBJECT result->ms_db-o_app TYPE z2ui5_lcl_system_app.
          EXIT.
      ENDTRY.

      TRY.
          CREATE OBJECT result->ms_db-o_app TYPE (result->ms_db-app_classname).
          EXIT.

        CATCH cx_root ##CATCH_ALL.
          DATA lo_error TYPE REF TO z2ui5_lcl_system_app.
          CREATE OBJECT lo_error TYPE z2ui5_lcl_system_app.
          CREATE OBJECT lo_error->ms_error-x_error TYPE z2ui5_lcl_utility EXPORTING val = `class with name ` && result->ms_db-app_classname && ` not found, app call not possible`.
          result->ms_db-o_app = lo_error.
          EXIT.
      ENDTRY.
    ENDDO.

    result->ms_db-app_classname      = _=>get_classname_by_ref( result->ms_db-o_app ).
    result->ms_db-t_attri            = _=>get_t_attri_by_ref( result->ms_db-o_app ).
    result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.

  ENDMETHOD.

  METHOD set_app_leave_to_id.

    CREATE OBJECT result.
    result->ms_db-id = _=>get_uuid( ).
    result->ms_db = z2ui5_lcl_db=>load_app( ms_next-nav_app_leave_to_id ).

    result->ms_next = ms_next.
    result->ms_next-view = ``.
    result->ms_next-view_popup = ``.
    result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.
    CLEAR ms_next.

    result->ms_db-id_prev_app = ms_db-id.
    result->ms_db-id_prev     = ms_db-id.

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.

  METHOD set_app_call_new.

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).

    CREATE OBJECT result.
    result->ms_db-id = _=>get_uuid( ).
    result->ms_db-o_app = ms_next-s_nav_app_call_new-o_app.
    result->ms_db-app_classname = _=>get_classname_by_ref( result->ms_db-o_app ).

    result->ms_db-id_prev_app = ms_db-id.
    result->ms_db-id_prev_app_stack = ms_db-id.

    result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.
    result->ms_next-t_after = ms_next-t_after.
    result->ms_next-view    = ms_next-view.
    result->ms_next-event   = ms_next-event.

    result->ms_db-t_attri = _=>get_t_attri_by_ref( result->ms_db-o_app ).

  ENDMETHOD.

  METHOD _create_binding.

    CONSTANTS c_prefix TYPE string VALUE `MS_DB-O_APP->`.

    IF type = cs_bind_type-one_time.
      DATA lv_id TYPE string.
      lv_id = _=>get_uuid_session( ).
      DATA temp26 TYPE z2ui5_lcl_utility=>ty_attri.
      CLEAR temp26.
      temp26-name = lv_id.
      temp26-data_stringify = _=>trans_any_2_json( value ).
      temp26-bind_type = type.
      INSERT temp26 INTO TABLE ms_db-t_attri.
      result = |/{ lv_id }|.
      RETURN.
    ENDIF.

    DATA lr_in TYPE REF TO DATA.
    GET REFERENCE OF value INTO lr_in.

    DATA temp27 LIKE LINE OF ms_db-t_attri.
    DATA lr_attri LIKE REF TO temp27.
    LOOP AT ms_db-t_attri REFERENCE INTO lr_attri.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      _=>raise( when = boolc( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).

      DATA lr_ref TYPE REF TO DATA.
      GET REFERENCE OF <attribute> INTO lr_ref.

      IF lr_in = lr_ref.
        lr_attri->bind_type = type.
        DATA temp28 TYPE string.
        IF type = cs_bind_type-two_way.
          temp28 = `/oUpdate/`.
        ELSE.
          temp28 = `/`.
        ENDIF.
        result = temp28 && lr_attri->name.
        RETURN.
      ENDIF.

    ENDLOOP.

    "one time when not global class attribute
    lv_id = _=>get_uuid_session( ).
    DATA temp29 TYPE z2ui5_lcl_utility=>ty_attri.
    CLEAR temp29.
    temp29-name = lv_id.
    temp29-data_stringify = _=>trans_any_2_json( value ).
    temp29-bind_type = cs_bind_type-one_time.
    INSERT temp29 INTO TABLE ms_db-t_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.


  METHOD set_app_system_error.

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).
    CREATE OBJECT result.
    result->ms_db-id = _=>get_uuid( ).
    result->ms_db-o_app = z2ui5_lcl_system_app=>factory_error( error = ix app = ms_db-o_app ).
    result->ms_db-app_classname = _=>get_classname_by_ref( result->ms_db-o_app ).

    result->ms_db-id_prev_app = ms_db-id.
    result->ms_db-id_prev_app_stack = ms_db-id.

    result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.

    result->ms_next-t_after = ms_next-t_after.
    result->ms_db-t_attri = _=>get_t_attri_by_ref( result->ms_db-o_app ).

    result->ms_db-id_prev_app = ms_db-id.

  ENDMETHOD.

  METHOD app_before_rendering.

    CREATE OBJECT result TYPE z2ui5_lcl_if_client EXPORTING RUNTIME = me.
    ms_actual-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_rendering.

  ENDMETHOD.

  METHOD app_before_event.

    CREATE OBJECT result TYPE z2ui5_lcl_if_client EXPORTING RUNTIME = me.

    DATA lv_url TYPE z2ui5_if_client=>ty_s_name_value-value.
    DATA temp30 LIKE LINE OF ss_client-t_header.
    DATA temp31 LIKE sy-tabix.
    temp31 = sy-tabix.
    READ TABLE ss_client-t_header WITH KEY name = `referer` INTO temp30.
    sy-tabix = temp31.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    lv_url = temp30-value.
    DATA lv_dummy TYPE string.
    SPLIT lv_url AT '?' INTO lv_url lv_dummy.

    CLEAR ms_actual.
    ms_actual-lifecycle_method = ms_next-lifecycle_method.
    ms_actual-id = ms_db-id.
    ms_actual-id_prev_app = ms_db-id_prev_app.
    ms_actual-id_prev_app_stack = ms_db-id_prev_app_stack.
    ms_actual-event = ms_next-event.
    ms_actual-view_active = ms_next-view.
    ms_actual-popup_active = ms_next-view_popup.
    ms_actual-page_scroll_pos = ms_next-page_scroll_pos.
    CLEAR ms_actual-s_request.
    ms_actual-s_request-tenant = sy-mandt.
    ms_actual-s_request-url_app = lv_url && `?sap-client=` && ms_actual-s_request-tenant && `&app=` && ms_db-app_classname.
    ms_actual-s_request-url_app_gen = lv_url && `?sap-client=` && ms_actual-s_request-tenant && `&app=`.
    DATA temp3 LIKE LINE OF ss_client-t_header.
    DATA temp4 LIKE sy-tabix.
    temp4 = sy-tabix.
    READ TABLE ss_client-t_header WITH KEY name = `origin` INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    ms_actual-s_request-origin = temp3-value.
    ms_actual-s_request-url_source_code = ms_actual-s_request-origin && `/sap/bc/adt/oo/classes/` && ms_db-app_classname && `/source/main`.

    CLEAR ms_next.

  ENDMETHOD.


ENDCLASS.

CLASS z2ui5_lcl_if_client IMPLEMENTATION.

  METHOD constructor.

    mo_runtime = runtime.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_message_toast.

    DATA temp155 TYPE string_table.
    CLEAR temp155.
    APPEND `MessageToast` TO temp155.
    APPEND `show` TO temp155.
    APPEND text TO temp155.
    INSERT temp155 INTO TABLE mo_runtime->ms_next-t_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_message_box.

    DATA temp157 TYPE string_table.
    CLEAR temp157.
    APPEND `MessageBox` TO temp157.
    APPEND type TO temp157.
    APPEND text TO temp157.
    INSERT temp157 INTO TABLE mo_runtime->ms_next-t_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~show_view.

    mo_runtime->ms_next-view = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~factory_view.

    result = z2ui5_lcl_if_view=>factory( mo_runtime ).
    DATA temp159 TYPE z2ui5_lcl_system_runtime=>s_view.
    CLEAR temp159.
    temp159-name = name.
    DATA temp32 TYPE REF TO z2ui5_lcl_if_view.
    temp32 ?= result.
    temp159-o_parser = temp32.
    INSERT temp159 INTO TABLE mo_runtime->ms_next-t_view.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_home.

    DATA temp160 TYPE REF TO z2ui5_lcl_system_app.
    CREATE OBJECT temp160 TYPE z2ui5_lcl_system_app.
    z2ui5_if_client~nav_app_call( temp160 ).

  ENDMETHOD.

  METHOD z2ui5_if_client~get.

    result = mo_runtime->ms_actual.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.

    CLEAR mo_runtime->ms_next-s_nav_app_call_new.
    mo_runtime->ms_next-s_nav_app_call_new-o_app = app.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_view.

    mo_runtime->ms_next-view_popup = name.

  ENDMETHOD.

  METHOD z2ui5_if_client~set.

*    IF page_scroll_pos IS SUPPLIED.
*      _=>raise( when = xsdbool( page_scroll_pos < 0 ) v = `scroll position ` && page_scroll_pos && ` / values lower 0 not allowed` ).
*      mo_runtime->ms_next-page_scroll_pos = page_scroll_pos.
*    ENDIF.

    IF event IS SUPPLIED.
      mo_runtime->ms_next-event = event.
    ENDIF.

    IF set_prev_view IS SUPPLIED.
      mo_runtime->ms_next-check_set_prev_view = set_prev_view.
    ENDIF.

    IF t_scroll_pos IS SUPPLIED.
      mo_runtime->ms_next-t_scroll_pos = t_scroll_pos.
    ENDIF.

    IF s_cursor_pos IS SUPPLIED.
      mo_runtime->ms_next-s_cursor_pos = s_cursor_pos.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.

    result = `{` && mo_runtime->_create_binding( value = val type = z2ui5_lcl_system_runtime=>cs_bind_type-two_way ) && `}`.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_one_way.

    result = `{` && mo_runtime->_create_binding( value = val type = z2ui5_lcl_system_runtime=>cs_bind_type-one_way ) && `}`.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' } )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_close_popup.

    result = `onEventFrontend( 'POPUP_CLOSE' )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.

    _=>raise( when = boolc( id = `` ) v = `app not found, please check if calling app exists, pervious app_id is empty` ).
    mo_runtime->ms_next-nav_app_leave_to_id = id.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app_by_id.

    DATA temp161 TYPE REF TO z2ui5_if_app.
    temp161 ?= z2ui5_lcl_db=>load_app( id )-o_app.
    result = temp161.

  ENDMETHOD.

ENDCLASS.