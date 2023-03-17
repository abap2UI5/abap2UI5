CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
      END OF ty_attri.

    TYPES ty_tt_string TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_name_value,
        name  TYPE string,
        value TYPE string,
      END OF ty_name_value.

    TYPES:
      BEGIN OF ty,
        BEGIN OF s,
          BEGIN OF msg,
            id TYPE string,
            ty TYPE string,
            no TYPE string,
            v1 TYPE string,
            v2 TYPE string,
            v3 TYPE string,
            v4 TYPE string,
          END OF msg,
          BEGIN OF msg_result,
            message  TYPE string,
            is_error TYPE abap_bool,
            type     TYPE abap_bool,
            t_bapi   TYPE bapirettab,
            s_bapi   TYPE LINE OF bapirettab,
          END OF msg_result,
        END OF s,
        BEGIN OF t,
          attri      TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY,
          name_value TYPE STANDARD TABLE OF ty_name_value WITH EMPTY KEY,
        END OF t,
        BEGIN OF o,
          me TYPE REF TO z2ui5_lcl_utility,
        END OF o,
      END OF ty.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        kind   TYPE string,
        text   TYPE string,
        s_msg  TYPE ty-s-msg_result,
        o_log  TYPE ty-o-me,
      END OF ms_error.

    METHODS constructor
      IMPORTING
        val      TYPE any OPTIONAL
        kind     TYPE string OPTIONAL
        previous LIKE previous OPTIONAL
          PREFERRED PARAMETER val.

    METHODS get_text REDEFINITION.

    CLASS-METHODS raise
      IMPORTING
        v    TYPE clike DEFAULT 'CX_SY_SUBRC'
        when TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER v.

    CLASS-METHODS get_classname_by_ref
      IMPORTING
        in              TYPE REF TO object
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(r_result) TYPE string
      RAISING
        cx_uuid_error.

    CLASS-METHODS get_uuid_session
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_user_tech
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_timestampl
      RETURNING
        VALUE(r_result) TYPE timestampl.

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
        i_focus         TYPE data
        io_app          TYPE REF TO object
        t_attri         TYPE ty-t-attri
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_t_attri_by_ref
      IMPORTING
        io_app          TYPE REF TO object
      RETURNING
        VALUE(r_result) TYPE ty-t-attri.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_params_by_url
      IMPORTING
        url             TYPE string
        name            TYPE string
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_prev_when_no_handler
      IMPORTING
        val             TYPE REF TO cx_root
      RETURNING
        VALUE(r_result) TYPE REF TO cx_root.

    CLASS-METHODS get_ref_data
      IMPORTING
        n             TYPE clike
        o             TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS get_abap_2_json
      IMPORTING
        val             TYPE any
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING ir_tab_from TYPE REF TO data
      CHANGING  ct_to       TYPE STANDARD TABLE.

    CLASS-METHODS get_trim_upper
      IMPORTING
        val             TYPE clike
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS escape_json
      IMPORTING
        iv_text         TYPE string
      RETURNING
        VALUE(r_result) TYPE string.

  PROTECTED SECTION.

    CLASS-DATA mv_counter TYPE i.

    CLASS-METHODS _get_t_attri
      IMPORTING
        io_app          TYPE REF TO object
        iv_attri        TYPE csequence
      RETURNING
        VALUE(r_result) TYPE abap_attrdescr_tab.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_lcl_utility IMPLEMENTATION.

  METHOD get_trim_upper.
    r_result = val.
    r_result = to_upper( shift_left( shift_right( r_result ) ) ).
  ENDMETHOD.

  METHOD escape_json.
    r_result = escape( val = iv_text
                       format = cl_abap_format=>e_json_string ).
  ENDMETHOD.

  METHOD constructor.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root ##CATCH_ALL.
        ms_error-s_msg-message = val.
    ENDTRY.

    ms_error-kind = kind.

    TRY.
        ms_error-uuid = get_uuid( ).
      CATCH cx_root ##CATCH_ALL.
    ENDTRY.
  ENDMETHOD.

  METHOD get_abap_2_json.

    DATA lo_ele TYPE REF TO cl_abap_elemdescr.
    lo_ele ?= cl_abap_elemdescr=>describe_by_data( val ).
    CASE lo_ele->get_relative_name( ).
      WHEN 'ABAP_BOOL' OR 'ABAP_BOOLEAN'.
        r_result = COND #( WHEN val = abap_true THEN 'true' ELSE 'false' ).
      WHEN OTHERS.
        r_result = |"{ CONV string( escape_json( val ) ) }"|.
    ENDCASE.

  ENDMETHOD.


  METHOD get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    r_result = substring_after( val = lv_classname sub = '\CLASS=' ).

  ENDMETHOD.


  METHOD get_params_by_url.
    " assumes that
    " - the URL parameters are always in the format name=value,
    " - that there are no nested or duplicate parameters, and
    " - the input URL is well-formed and contains at most one `?` symbol
    DATA lt_url_params TYPE ty-t-name_value.

    DATA(url_segments) = segment( val = get_trim_upper( url ) index = 2 sep = `?` ).
    SPLIT url_segments AT `&` INTO TABLE DATA(lt_params).

    LOOP AT lt_params INTO DATA(lv_param).
      SPLIT lv_param AT `=` INTO DATA(lv_name) DATA(lv_value) DATA(lv_dummy).
      INSERT VALUE #( name = lv_name
                      value = lv_value ) INTO TABLE lt_url_params.
    ENDLOOP.

    r_result = lt_url_params[ name = get_trim_upper( name ) ]-value.

  ENDMETHOD.


  METHOD get_prev_when_no_handler.

    TRY.
        r_result = CAST cx_sy_no_handler( val )->previous.
      CATCH cx_root.
    ENDTRY.

    IF r_result IS NOT BOUND.
      r_result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_ref_data.

    FIELD-SYMBOLS <field> TYPE data.

    ASSIGN o->(n) TO <field>.
    raise( when = xsdbool( sy-subrc <> 0 ) v = 'CX_SY_SUBRC' ).

    result = REF #( <field> ).

  ENDMETHOD.


  METHOD get_timestampl.

    GET TIME STAMP FIELD r_result.

  ENDMETHOD.


  METHOD get_user_tech.

    r_result = sy-uname.

  ENDMETHOD.


  METHOD get_uuid.

    DATA uuid TYPE c LENGTH 32.

    TRY.
        CALL METHOD ('CL_SYSTEM_UUID')=>create_uuid_c32_static
          RECEIVING
            uuid = uuid.

      CATCH cx_sy_dyn_call_illegal_class.

        DATA(lv_fm) = 'GUID_CREATE'.
        CALL FUNCTION lv_fm
          IMPORTING
            ev_guid_32 = uuid.

    ENDTRY.

    r_result = uuid.

  ENDMETHOD.

  METHOD get_uuid_session.

    mv_counter = mv_counter + 1.
    r_result = shift_left( shift_right( CONV string( mv_counter ) ) ).

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
        r_result = to_upper( lr_attri->name ).
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_t_attri_by_ref.
    " retrieves public attributes of a class instance referred to by io_app,
    " including any nested structures,
    " and returns them as an internal table of line type TY_ATTRI.

    DATA(lo_descr) = cl_abap_objectdescr=>describe_by_object_ref( io_app ).
    DATA(lt_attri) = CAST cl_abap_classdescr( lo_descr )->attributes.

    " Filter out non-public attributes
    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public.

    " Recursively get nested attributes of public nested structure and add them to main list
    LOOP AT lt_attri INTO DATA(ls_attri)
      WHERE ( type_kind = cl_abap_classdescr=>typekind_struct2
           OR type_kind = cl_abap_classdescr=>typekind_struct1 )
        AND visibility = cl_abap_classdescr=>public.
      DELETE lt_attri INDEX sy-tabix.
      INSERT LINES OF _get_t_attri( io_app = io_app
                                    iv_attri = ls_attri-name ) INTO TABLE lt_attri.

    ENDLOOP.

    r_result = CORRESPONDING #( lt_attri ).

  ENDMETHOD.

  METHOD _get_t_attri.

    CONSTANTS c_prefix TYPE string VALUE `IO_APP->`.
    FIELD-SYMBOLS <attribute> TYPE any.

    DATA(lv_name) = c_prefix && to_upper( iv_attri ).
    ASSIGN (lv_name) TO <attribute>.
    raise( when = xsdbool( sy-subrc <> 0 ) v = 'CX_SY_SUBRC' ).

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_type ).

    LOOP AT lo_struct->get_components( ) REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = iv_attri && '-' && lr_comp->name.

      IF lr_comp->as_include = abap_true.

        INSERT LINES OF _get_t_attri( io_app   = io_app
                                      iv_attri = lv_element ) INTO TABLE r_result.

      ELSE.
        INSERT VALUE #( name = lv_element
                        type_kind = lr_comp->type->type_kind ) INTO TABLE r_result.
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
    raise( when = xsdbool( sy-subrc <> 0 ) v = 'CX_SY_SUBRC' ).

    CALL TRANSFORMATION id
       SOURCE data = <object>
       RESULT XML result
        OPTIONS data_refs = 'heap-or-create'.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.
    " transfers the contents of a reference table ir_tab_from with UI5 data
    " to a target internal table ct_to with a corresponding structure.
    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.

    FIELD-SYMBOLS <comp> TYPE data.
    FIELD-SYMBOLS <comp_ui5> TYPE data.
    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.

    ASSIGN ir_tab_from->* TO <lt_from>.
    raise( when = xsdbool( sy-subrc <> 0 ) v = 'CX_SY_SUBRC' ).

    READ TABLE ct_to INDEX 1 ASSIGNING FIELD-SYMBOL(<back>).
    IF sy-subrc = 0.
      DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( <back> ) ).
      DATA(lt_components) = lo_struct->get_components( ).
    ENDIF.

    LOOP AT <lt_from> INTO DATA(lr_from).

      ASSIGN ct_to[ sy-tabix ] TO <back>.
      raise( when = xsdbool( sy-subrc <> 0 ) v = 'CX_SY_SUBRC' ).

      ASSIGN lr_from->* TO FIELD-SYMBOL(<row_ui5>).
      raise( when = xsdbool( sy-subrc <> 0 ) v = 'CX_SY_SUBRC' ).

      LOOP AT lt_components INTO DATA(ls_comp).

        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <back> TO <comp>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
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
      result = 'unknown error'.
    ENDIF.

  ENDMETHOD.

  METHOD raise.

    IF when = abap_false.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE z2ui5_lcl_utility
      EXPORTING
        val = v.

  ENDMETHOD.
ENDCLASS.

CLASS _ DEFINITION INHERITING FROM z2ui5_lcl_utility.
ENDCLASS.

CLASS z2ui5_lcl_utility_tree_json DEFINITION.

  PUBLIC SECTION.

    TYPES ty_o_me TYPE REF TO z2ui5_lcl_utility_tree_json.
    TYPES ty_T_me TYPE STANDARD TABLE OF ty_o_me WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_S_name,
        n          TYPE string,
        v          TYPE string,
        apos_deact TYPE abap_bool,
      END OF ty_S_name.

    TYPES ty_T_name_value TYPE STANDARD TABLE OF ty_S_name.

    CLASS-METHODS new
      IMPORTING
        io_root         TYPE ty_o_me
        iv_name         TYPE simple
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    CLASS-METHODS factory
      IMPORTING
        iv_json         TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS constructor.

    METHODS get_root
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS get_attribute
      IMPORTING
        name            TYPE string
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS get_val
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS get_attribute_all
      RETURNING
        VALUE(r_result) TYPE ty_T_me.

    METHODS get_parent
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_list_val
      IMPORTING
        v               TYPE string
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_attribute
      IMPORTING
        n               TYPE clike
        v               TYPE clike
        apos_active     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_attributes_name_value_tab
      IMPORTING
        it_name_value   TYPE ty_T_name_value
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_attribute_object
      IMPORTING
        name            TYPE clike
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_list_object
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_list_list
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_attribute_list
      IMPORTING
        name            TYPE clike
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_attribute_instance
      IMPORTING
        val             TYPE ty_o_me
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS write_result
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS get_name
      RETURNING
        VALUE(r_result) TYPE string.

    DATA mo_root TYPE ty_o_me.
    DATA mo_parent TYPE ty_o_me.
    DATA mv_name   TYPE string.
    DATA mv_value  TYPE string.
    DATA mt_values TYPE ty_t_me.
    DATA mv_check_list TYPE abap_bool.
    DATA mr_actual TYPE REF TO data.
    DATA mv_apost_active TYPE abap_bool.

  PROTECTED SECTION.

    METHODS wrap_json
      IMPORTING
        iv_text         TYPE string
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS quote_json
      IMPORTING
        iv_text         TYPE string
        iv_cond         TYPE abap_bool
      RETURNING
        VALUE(r_result) TYPE string.

ENDCLASS.



CLASS z2ui5_lcl_utility_tree_json IMPLEMENTATION.


  METHOD add_attribute.

    DATA(lo_attri) = new( io_root = mo_root iv_name = n ).

    IF apos_active = abap_false.
      lo_attri->mv_value = v.
    ELSE.
      lo_attri->mv_value = _=>escape_json( v ).
    ENDIF.
    lo_attri->mv_apost_active = apos_active.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.
    r_result = me.

  ENDMETHOD.


  METHOD add_attributes_name_value_tab.

    LOOP AT it_name_value INTO DATA(ls_value).
      add_attribute(
           n           = ls_value-n
           v           = ls_value-v
           apos_active = xsdbool( ls_value-apos_deact = abap_false ) ).
    ENDLOOP.

    r_result = me.

  ENDMETHOD.


  METHOD add_attribute_instance.

    val->mo_root = mo_root.
    val->mo_parent = me.
    INSERT val INTO TABLE mt_values.
    r_result = val.

  ENDMETHOD.


  METHOD add_attribute_list.

    r_result = add_attribute_object( name = name ).
    r_result->mv_check_list = abap_true.

  ENDMETHOD.


  METHOD add_attribute_object.

    DATA(lo_attri) = new( io_root = mo_root iv_name = name ).
    mt_values = VALUE #( BASE mt_values ( lo_attri ) ).
    lo_attri->mo_parent = me.
    r_result = lo_attri.

  ENDMETHOD.


  METHOD add_list_list.

    r_result = add_attribute_list( name = CONV string( lines( mt_values ) ) ).

  ENDMETHOD.


  METHOD add_list_object.

    r_result = add_attribute_object( name = CONV string( lines( mt_values ) ) ).

  ENDMETHOD.


  METHOD add_list_val.

    DATA(lo_attri) = new( io_root = mo_root iv_name = lines( mt_values ) ).
    lo_attri->mv_value = v.
    lo_attri->mv_apost_active = abap_true.

    mt_values = VALUE #( BASE mt_values ( lo_attri ) ).
    lo_attri->mo_parent = me.
    r_result = lo_attri.
    r_result = me.

  ENDMETHOD.


  METHOD constructor.

    mo_root = me.

  ENDMETHOD.


  METHOD factory.

    r_result = NEW #( ).
    r_result->mo_root = r_result.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( iv_json )
            assoc_arrays = abap_true
        CHANGING
         data            = r_result->mr_actual
        ).

  ENDMETHOD.

  METHOD new.

    r_result = NEW #( ).
    r_result->mo_root = io_root.
    r_result->mv_name = CONV string( iv_name ).

  ENDMETHOD.

  METHOD get_attribute.

    CONSTANTS c_prefix TYPE string VALUE `MR_ACTUAL->`.

    _=>raise( when = xsdbool( mr_actual IS INITIAL ) ).

    DATA(lo_attri) = new( io_root = mo_root iv_name = name ).

    FIELD-SYMBOLS <attribute> TYPE any.
    DATA(lv_name) = c_prefix && replace( val = name sub = '-' with = '_' occ = 0 ).
    ASSIGN (lv_name) TO <attribute>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lo_attri->mr_actual = <attribute>.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    r_result = lo_attri.

  ENDMETHOD.


  METHOD get_attribute_all.

    r_result = mt_values.

  ENDMETHOD.


  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    _=>raise( when = xsdbool( sy-subrc <> 0 ) v = `Value of Attribute in JSON not found` ).

    r_result = <attribute>.

  ENDMETHOD.

  METHOD get_name.

    r_result = mv_name.

  ENDMETHOD.


  METHOD get_parent.

    r_result = COND #( WHEN mo_parent IS NOT BOUND THEN me ELSE mo_parent ).

  ENDMETHOD.


  METHOD get_root.

    r_result = mo_root.

  ENDMETHOD.


  METHOD wrap_json.
    " Wrap the input text string with the opening and closing characters
    " and assign the result to r_result
    r_result = iv_text.

    CASE mv_check_list.
      WHEN abap_true.
        DATA(open_char) = '['.
        DATA(close_char) = ']'.
      WHEN abap_false.
        open_char = '{'.
        close_char = '}'.
      WHEN OTHERS.
        RETURN.
    ENDCASE.
    r_result = open_char && r_result && close_char.

  ENDMETHOD.

  METHOD quote_json.

    r_result = COND #( WHEN iv_cond = abap_true THEN `"` && iv_text && `"` ELSE iv_text ).

  ENDMETHOD.

  METHOD write_result.

    LOOP AT mt_values INTO DATA(lo_attri).

      IF sy-tabix > 1.
        r_result = r_result && |,|.
      ENDIF.

      IF mv_check_list = abap_false.
        r_result = r_result && |"{ lo_attri->mv_name }":|.
      ENDIF.


      IF lo_attri->mt_values IS NOT INITIAL.

        r_result = r_result && lo_attri->write_result( ).

      ELSE.

        r_result = r_result &&
           quote_json( iv_cond = xsdbool( lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL )
                       iv_text = lo_attri->mv_value ).
      ENDIF.

    ENDLOOP.

    r_result = wrap_json( r_result ).
  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_system_runtime DEFINITION DEFERRED.

CLASS z2ui5_lcl_if_view DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_view.
    ALIASES _generic FOR z2ui5_if_view~_generic.

    CONSTANTS cs LIKE z2ui5_if_view=>cs VALUE z2ui5_if_view=>cs.

    TYPES:
      BEGIN OF ty_S_view,
        xml     TYPE string,
        o_model TYPE REF TO z2ui5_lcl_utility_tree_json,
        t_attri TYPE _=>ty-t-attri,
      END OF ty_S_view.

    DATA m_name TYPE string.
    DATA m_ns   TYPE string.
    DATA mt_prop TYPE z2ui5_if_view=>ty_t_name_value.

    DATA mo_runtime TYPE REF TO z2ui5_lcl_system_runtime.

    DATA m_root    TYPE REF TO z2ui5_lcl_if_view.
    DATA m_last    TYPE REF TO z2ui5_lcl_if_view.
    DATA m_parent  TYPE REF TO z2ui5_lcl_if_view.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_lcl_if_view WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        runtime       TYPE REF TO z2ui5_lcl_system_runtime
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_if_view.

    METHODS get_view
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE ty_S_view.

    METHODS _get_name_by_ref
      IMPORTING
        value           TYPE data
        type            TYPE string DEFAULT cs-bind_type-two_way
      RETURNING
        VALUE(r_result) TYPE string.

  PROTECTED SECTION.

    METHODS xml_get
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE string.

    METHODS xml_get_focus
      CHANGING
        ct_prop TYPE z2ui5_if_view=>ty_t_name_value.

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

    CLASS-DATA:
      BEGIN OF ss_client,
        o_body   TYPE REF TO z2ui5_lcl_utility_tree_json,
        t_header TYPE z2ui5_cl_http_handler=>ty_t_name_value,
        t_param  TYPE z2ui5_cl_http_handler=>ty_t_name_value,
      END OF ss_client.

    TYPES:
      BEGIN OF ty_S_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,

        t_attri           TYPE _=>ty-t-attri,
        o_app             TYPE REF TO object,
        app_classname     TYPE string,
      END OF ty_S_db.

    DATA ms_db TYPE ty_S_Db.

    TYPES:
      BEGIN OF s_screen,
        name     TYPE string,
        o_parser TYPE REF TO z2ui5_lcl_if_view,
      END OF s_screen.

    TYPES:
      BEGIN OF ty_s_next,
        lifecycle_method    TYPE string,

        event               TYPE string,
        nav_app_leave_to_id TYPE string,
        s_nav_app_call_new  TYPE ty_S_db,

        t_after             TYPE _=>ty_tt_string,
        page_scroll_pos     TYPE i,

        view                TYPE string,
        view_popup          TYPE string,

        check_set_prev_view TYPE abap_bool,

        focus               TYPE string,
        focus_cursor_pos    TYPE i,
        focus_sel_start     TYPE i,
        focus_sel_end       TYPE i,

        t_screen            TYPE STANDARD TABLE OF s_screen WITH EMPTY KEY,
      END OF ty_s_next.

    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    METHODS constructor.

    CLASS-METHODS execute_init
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS execute_before_app
      IMPORTING
        event         TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_client.

    METHODS execute_finish
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS set_app_start
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

    CLASS-METHODS set_app_client_update
      IMPORTING
        id_prev         TYPE clike
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS set_app_leave_to_id
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS set_app_call_new
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS set_app_system_error
      IMPORTING
        kind            TYPE string
        ix              TYPE REF TO cx_root
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_lcl_db DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        id       TYPE string
        response TYPE clike OPTIONAL
        db       TYPE z2ui5_lcl_system_runtime=>ty_S_db.

    CLASS-METHODS load_app
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_lcl_system_runtime=>ty_S_db.

    CLASS-METHODS read
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_t_draft.

    CLASS-METHODS cleanup.

ENDCLASS.

CLASS z2ui5_lcl_if_view IMPLEMENTATION.

  METHOD _get_name_by_ref.

    CONSTANTS c_prefix TYPE string VALUE `M_ROOT->MO_RUNTIME->MS_DB-O_APP->`.

    IF type = cs-bind_type-one_time.
      DATA(lv_id) = _=>get_uuid_session( ).
      INSERT VALUE #(
        name = lv_id
        data_stringify = _=>trans_any_2_json( value )
        bind_type = type
       ) INTO TABLE m_root->mo_runtime->ms_db-t_attri.
      r_result = '/' && lv_id && ''.
      RETURN.
    ENDIF.

    DATA(lr_in) = REF #( value ).

    LOOP AT m_root->mo_runtime->ms_db-t_attri REFERENCE INTO DATA(lr_attri).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      _=>raise( when = xsdbool( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).

      DATA(lr_ref) = REF #( <attribute> ).

      IF lr_in = lr_ref.
        lr_attri->bind_type = type.
        r_result = COND #( WHEN type = cs-bind_type-two_way THEN '/oUpdate/' ELSE '/' ) && lr_attri->name.
        RETURN.
      ENDIF.

    ENDLOOP.

    "one time when not global class attribute
    lv_id = _=>get_uuid_session( ).
    INSERT VALUE #(
      name = lv_id
      data_stringify = _=>trans_any_2_json( value )
      bind_type = cs-bind_type-one_time
     ) INTO TABLE m_root->mo_runtime->ms_db-t_attri.
    r_result = '/' && lv_id && ''.

  ENDMETHOD.

  METHOD xml_get_begin.

    result = COND #( WHEN check_popup_active = abap_true THEN `<core:FragmentDefinition` ELSE `<mvc:View controllerName="MyController"` ).

    result = result && ` xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml"` &&
              ` xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mvc" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" ` &&
                     `xmlns="sap.m" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > `.

    result = result && COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true AND check_popup_active = abap_false THEN `<Shell>` ).

  ENDMETHOD.

  METHOD xml_get_end.

    result = result && COND #( WHEN check_popup_active = abap_false
              THEN COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN `</Shell>` ) && `</mvc:View>`
              ELSE `</core:FragmentDefinition>` ).

  ENDMETHOD.

  METHOD xml_get_focus.

    LOOP AT ct_prop REFERENCE INTO DATA(lr_row)
      WHERE n = 'value'.

      DATA(lv_field) = 'oUpdate/' && m_root->mo_runtime->ms_next-focus.
      IF lr_row->v CS lv_field.
        INSERT VALUE #( n = 'id' v = 'focus' ) INTO TABLE ct_prop.
        RETURN.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD xml_get.

    "case - root
    IF me = m_root.
      result = xml_get_begin( check_popup_active ).

      LOOP AT t_child INTO DATA(lr_child).
        result = result && lr_child->xml_get( ).
      ENDLOOP.

      result = result && xml_get_end( check_popup_active ).
      RETURN.
    ENDIF.

    "case - normal
    CASE m_name.

      WHEN 'ZZHTML'.
        result = mt_prop[ n = 'VALUE' ]-v.
        RETURN.

      WHEN 'Input' OR 'TextArea'.
        IF m_root->mo_runtime->ms_next-focus IS NOT INITIAL.
          xml_get_focus( CHANGING ct_prop = mt_prop ).
        ENDIF.

    ENDCASE.

    DATA(lv_tmp2) = COND #( WHEN m_ns <> '' THEN |{ m_ns }:| ).
    DATA(lv_tmp3) = REDUCE #( INIT val = `` FOR row IN mt_prop WHERE ( v <> '' )
                          NEXT val = |{ val } { row-n }="{ escape(
                                        val = cond string( when row-v = abap_true then 'true' else row-v )
                                      "  val = row-v
                                        format = cl_abap_format=>e_xml_attr ) }" \n | ).
    result = |{ result } <{ lv_tmp2 }{ m_name } \n { lv_tmp3 }|.

    IF t_child IS INITIAL.
      result = result && '/>'.
      RETURN.
    ENDIF.

    result = result && '>'.

    LOOP AT t_child INTO lr_child.
      result = result && lr_child->xml_get( ).
    ENDLOOP.

    result = result && |</{ COND #( WHEN m_ns <> '' THEN |{ m_ns }:| ) }{ m_name }>|.

  ENDMETHOD.

  METHOD z2ui5_if_view~_generic.

    DATA(result2) = NEW z2ui5_lcl_if_view( ).
    result2->m_name = name.
    result2->m_ns = ns.
    result2->mt_prop = t_prop.
    result2->m_parent = me.
    result2->m_root   = m_root.
    INSERT result2 INTO TABLE t_child.

    m_root->m_last = result2.
    result = result2.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).
    result->m_root = result.
    result->m_parent = result.
    result->mo_runtime = runtime.

  ENDMETHOD.

  METHOD z2ui5_if_view~Overflow_Toolbar_Button.

    result = me.

    _generic(
       name   = 'OverflowToolbarButton'
       t_prop = VALUE #(
          ( n = 'press'   v = press )
          ( n = 'text'    v = text )
          ( n = 'enabled' v = _=>get_abap_2_json( enabled ) )
          ( n = 'icon'    v = icon )
          ( n = 'type'    v = type )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~button.

    result = me.

    _generic(
       name   = 'Button'
       t_prop = VALUE #(
          ( n = 'press'   v = press )
          ( n = 'text'    v = text )
          ( n = 'enabled' v = _=>get_abap_2_json( enabled ) )
          ( n = 'icon'    v = icon )
          ( n = 'type'    v = type )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~input.

    result = me.

    _generic(
       name   = 'Input'
       t_prop = VALUE #(
           ( n = 'placeholder'     v = placeholder )
           ( n = 'type'            v = type )
           ( n = 'showClearIcon'   v = _=>get_abap_2_json( show_clear_icon ) )
           ( n = 'description'     v = description )
           ( n = 'editable'        v = _=>get_abap_2_json( editable ) )
           ( n = 'valueState'      v = value_state )
           ( n = 'valueStateText'  v = value_state_text )
           ( n = 'value'           v = value )
           ( n = 'suggestionItems' v = suggestion_items )
           ( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )
           ( n = 'valueHelpRequest'  v = valueHelpRequest )
           ( n = 'showValueHelp'     v = _=>get_abap_2_json( showValueHelp ) )
        ) ).


  ENDMETHOD.

  METHOD get_view.

    CONSTANTS c_prefix TYPE string VALUE `M_ROOT->MO_RUNTIME->MS_DB-O_APP->`.

    result-xml = m_root->xml_get( check_popup_active = check_popup_active ).

    DATA(m_view_model) = z2ui5_lcl_utility_tree_json=>factory( ).
    DATA(lo_update) = m_view_model->add_attribute_object( 'oUpdate' ).

    LOOP AT mo_runtime->ms_db-t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ''.

      IF lr_attri->bind_type = cs-bind_type-one_time.

        m_view_model->add_attribute(
              n = lr_attri->name
              v = lr_attri->data_stringify
              apos_active = abap_false ).

        CONTINUE.
      ENDIF.

      DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs-bind_type-one_way THEN m_view_model
                                 ELSE lo_update ).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      _=>raise( when = xsdbool( sy-subrc <> 0 ) ).

      CASE lr_attri->type_kind.

        WHEN 'g' OR 'D' OR 'P' OR 'T' OR 'C'.

          lo_actual->add_attribute( n = lr_attri->name
                                    v = _=>get_abap_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN 'I'.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = CONV string( <attribute> )
                                    apos_active = abap_false ).

        WHEN 'h'.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = _=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

      ENDCASE.
    ENDLOOP.

    IF lo_update->mt_values IS INITIAL.
      lo_update->mv_value = '{}'.
      lo_update->mv_apost_active = abap_false.
    ENDIF.

    result-o_model = m_view_model.
    DELETE m_root->mo_runtime->ms_db-t_attri WHERE bind_type = cs-bind_type-one_time.
    result-t_attri = m_root->mo_runtime->ms_db-t_attri.

  ENDMETHOD.

  METHOD z2ui5_if_view~page.

    result = _generic(
        name   = 'Page'
         t_prop = VALUE #(
             ( n = 'title' v = title )
             ( n = 'showNavButton' v = COND #( WHEN nav_button_tap = '' THEN 'false' ELSE 'true' ) )
             ( n = 'navButtonTap' v = nav_button_tap )
             ( n = 'id' v = id )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~vbox.

    result = _generic(
         name   = 'VBox'
         t_prop = VALUE #(
            ( n = 'class' v = 'sapUiSmallMargin' )
         ) ).

  ENDMETHOD.


  METHOD z2ui5_if_view~hbox.

    result = _generic(
          name   = 'HBox'
          t_prop = VALUE #(
             ( n = 'class' v = 'sapUiSmallMargin' )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~simple_form.

    result = _generic(
      name   = 'SimpleForm'
      ns     = 'f'
      t_prop = VALUE #(
        ( n = 'title' v = title )
        ( n = 'editable' v = 'true' )
        ( n = 'layout' v = 'ResponsiveGridLayout' )
        ( n = 'labelSpanXL' v = '4' )
        ( n = 'labelSpanL' v = '3' )
        ( n = 'labelSpanM' v = '4' )
        ( n = 'labelSpanS' v = '12' )
        ( n = 'emptySpanXL' v = '0' )
        ( n = 'emptySpanL' v = '4' )
        ( n = 'emptySpanM' v = '0' )
        ( n = 'emptySpanS' v = '0' )
        ( n = 'columnsL' v = '1' )
        ( n = 'columnsM' v = '1' )
        ( n = 'singleContainerFullSize' v = 'false' )
        ( n = 'adjustLabelSpan' v = 'false' )
      ) ).

  ENDMETHOD.


  METHOD z2ui5_if_view~content.

    result = _generic( ns = ns name = 'content' ).

  ENDMETHOD.


  METHOD z2ui5_if_view~title.

    result = me.

    _generic(
         name  = 'Title'
         t_prop = VALUE #(
             ( n = 'text' v = title ) )
      ).

  ENDMETHOD.

  METHOD z2ui5_if_view~code_editor.

    result = me.

    _generic(
        name  = 'CodeEditor'
        ns = 'editor'
        t_prop = VALUE #(
            ( n = 'value'   v = value )
            ( n = 'type'    v = type )
            ( n = 'editable'   v = _=>get_abap_2_json( editable ) )
            ( n = 'height' v = height )
            ( n = 'width'  v = width )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~zz_file_uploader.

    result = me.

    _generic(
      name   = 'FileUploader'
      ns     = 'z2ui5'
      t_prop = VALUE #(
         (  n = 'placeholder' v = placeholder )
         (  n = 'upload' v = upload )
         (  n = 'path'   v = path )
         (  n = 'value'  v = value )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~zz_html.

    SPLIT val AT '<' INTO TABLE DATA(lt_table).

    DATA(lv_html) = ``.
    lv_html = VALUE #( lt_table[ 1 ] OPTIONAL ).

    LOOP AT lt_table REFERENCE INTO DATA(lr_line) FROM 2.
      IF lr_line->*(1) = '/'.
        lv_html = '</html:' && lr_line->*.
      ELSE.
        lv_html = '<html:' && lr_line->*.
      ENDIF.
    ENDLOOP.

    result = me.

    _generic(
         name  = 'ZZHTML'
         t_prop = VALUE #( ( n = 'VALUE' v = lv_html ) )
    ).

  ENDMETHOD.

  METHOD z2ui5_if_view~overflow_toolbar.

    result = _generic( 'OverflowToolbar' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~toolbar_spacer.

    result = me.
    _generic( 'ToolbarSpacer' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~combobox.

    result = me.

    _generic(
       name  = 'ComboBox'
       t_prop = VALUE #(
          (  n = 'showClearIcon' v = _=>get_abap_2_json( show_clear_icon ) )
          (  n = 'selectedKey'   v = selectedkey )
          (  n = 'items'         v = items )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~date_picker.

    result = me.

    _generic(
      name       = 'DatePicker'
      t_prop = VALUE #(
          ( n = 'value' v = value )
          ( n = 'placeholder' v = placeholder )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~date_time_picker.

    result = me.

    _generic(
        name  = 'DateTimePicker'
        t_prop = VALUE #(
            ( n = 'value' v = value )
            ( n = 'placeholder'  v = placeholder )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~label.

    result = me.

    _generic(
       name  = 'Label'
       t_prop = VALUE #(
           ( n = 'text' v = text )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~link.

    result = me.

    _generic(
     name  = 'Link'
       t_prop = VALUE #(
         ( n = 'text'   v = text )
         ( n = 'target' v = '_blank' )
         ( n = 'href'   v = href )
         ( n = 'enabled'   v = _=>get_abap_2_json( enabled ) )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segmented_button.

    result = me.

    _generic(
       name  = 'SegmentedButton'
       t_prop = VALUE #(
        ( n = 'selectedKey' v = selected_key )
        ( n = 'selectionChange' v = selection_Change )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~step_input.

    result = me.

    _generic(
         name  = 'StepInput'
         t_prop = VALUE #(
            ( n = 'max'  v = max )
            ( n = 'min'  v = min )
            ( n = 'step' v = step )
            ( n = 'value' v = value )
     ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~switch.

    result = me.

    _generic(
          name  = 'Switch'
          t_prop = VALUE #(
             ( n = 'type'           v = type )
             ( n = 'enabled'        v = _=>get_abap_2_json( enabled ) )
             ( n = 'state'          v = state )
             ( n = 'customTextOff'  v = customtextoff )
             ( n = 'customTextOn'   v = customtexton )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~text_area.

    result = me.

    _generic(
          name  = 'TextArea'
            t_prop = VALUE #(
              ( n = 'value' v = value )
              ( n = 'rows' v = rows )
              ( n = 'height' v = height )
              ( n = 'width' v = width )
              ( n = 'id' v = id )
              ( n = 'growing' v = _=>get_abap_2_json( growing ) )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~time_picker.

    result = me.

    _generic(
     name   = 'TimePicker'
     t_prop = VALUE #(
          ( n = 'value' v = value )
          ( n = 'placeholder'  v = placeholder )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~checkbox.

    result = me.

    _generic(
       name  = 'CheckBox'
       t_prop = VALUE #(
          ( n = 'text'     v = text )
          ( n = 'selected' v = selected )
          ( n = 'enabled'  v = _=>get_abap_2_json( enabled ) )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~progress_indicator.

    result = me.

    _generic(
         name  = 'ProgressIndicator'
         t_prop = VALUE #(
            ( n = 'percentValue' v = _get_name_by_ref( percent_value ) )
            ( n = 'displayValue' v = display_value )
            ( n = 'showValue'    v = _=>get_abap_2_json( show_value ) )
            ( n = 'state'        v = state )
     ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~text.

    result = me.

    _generic(
      name  = 'Text'
      t_prop = VALUE #(
        ( n = 'text'  v = text )
        ( n = 'class' v = class )
        )  ).

  ENDMETHOD.

  METHOD z2ui5_if_view~table.

    result = _generic(
        name  = 'Table'
        t_prop = VALUE #(
           ( n = 'items'            v = items )
           ( n = 'headerText'       v = header_text )
           ( n = 'growing'          v = _=>get_abap_2_json( growing ) )
           ( n = 'growingThreshold' v = growing_threshold )
           ( n = 'sticky'           v = sticky )
           ( n = 'mode'             v = mode )
     ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~cells.

    result = _generic( 'cells' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~column.

    result = _generic(
        name  = 'Column'
          t_prop = VALUE #( ( n = 'width' v = width ) )
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~columns.

    result = _generic( 'columns' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~column_list_item.

    result = _generic(
        name = 'ColumnListItem'
        t_prop = VALUE #( ( n = 'vAlign'   v = valign )
                          ( n = 'selected' v = selected )
                         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~items.

    result = _generic( 'items' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~grid.

    result = _generic(
        name = 'Grid'
        ns   = 'l'
        t_prop = VALUE #(
            ( n = 'defaultSpan' v = default_span )
            ( n = 'class'       v = class )
            ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~header_toolbar.

    result = _generic( 'headerToolbar' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~scroll_container.

    result = _generic(
        name = 'ScrollContainer'
        t_prop = VALUE #(
          ( n = 'height' v = height )
          ( n = 'width'       v = width )
          ( n = 'vertical'       v = 'true' )
          ( n = 'focusable'       v = 'true' )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~header_content.

    result = _generic( 'headerContent' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~sub_header.

    result = _generic( 'subHeader' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~footer.

    result = _generic( 'footer' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~dialog.

    result = _generic(
         name = 'Dialog'
        t_prop = VALUE #(
          ( n = 'title'  v = title )
          ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~table_select_dialog.

*    result = _generic(
*         name = 'TableSelectDialog'
*        t_prop = VALUE #(
*          ( n = 'title' v = title )
*          ( n = 'confirm'      v = _get_event_method( ` $event , { 'ID' : '` && event_id_confirm && `' } )` ) )
*          ( n = 'cancel'       v = _get_event_method( `{ 'ID' : '` && event_id_cancel && `' }` ) )
*          ( n = 'items' v = '{' && _get_name_by_ref( value = items ) && '}' )
*          ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~list.

    result = _generic(
        name = 'List'
        t_prop = VALUE #(
          ( n = 'headerText' v = header_text )
          ( n = 'items' v = items )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~standard_list_item.

    result = me.

    _generic(
        name = 'StandardListItem'
        t_prop = VALUE #(
            ( n = 'title'       v = title )
            ( n = 'description' v = description )
            ( n = 'icon'        v = icon )
            ( n = 'info'        v = info )
            ( n = 'press'       v = press )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~message_page.

    result = _generic(
        name   = 'MessagePage'
        t_prop = VALUE #(
           ( n = 'showHeader' v = _=>get_abap_2_json( show_header ) )
           ( n = 'description' v = description )
           ( n = 'icon' v = icon )
           ( n = 'text' v = text )
           ( n = 'enableFormattedText' v = _=>get_abap_2_json( enable_formatted_text ) )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~buttons.

    result = _generic( 'buttons' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~_bind.

    result = '{' && _get_name_by_ref( value = val  type = cs-bind_type-two_way ) && '}'.

  ENDMETHOD.

  METHOD z2ui5_if_view~_bind_one_way.

    result = '{' && _get_name_by_ref( value = val  type = cs-bind_type-one_way ) && '}'.

  ENDMETHOD.

  METHOD z2ui5_if_view~get_parent.
    result = m_parent.
  ENDMETHOD.

  METHOD z2ui5_if_view~message_strip.

    result = me.

    _generic(
      name = 'MessageStrip'
     t_prop = VALUE #(
       ( n = 'text' v = text )
       ( n = 'type' v = type )
       ( n = 'class' v = class )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' } )`.

  ENDMETHOD.

  METHOD z2ui5_if_view~_event_frontend_close_popup.

    result = `onEventFrontend( 'POPUP_CLOSE' )`.

  ENDMETHOD.


  METHOD z2ui5_if_view~list_item.

    result = me.

    _generic(
               name   = 'ListItem'
               ns     = 'core'
               t_prop = VALUE #(
                      ( n = 'text' v = text )
                      ( n = 'additionalText' v = additional_text ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~suggestion_items.

    result = _generic( 'suggestionItems' ).

  ENDMETHOD.

  METHOD z2ui5_if_view~item.

    result = me.

    _generic(
       name = 'Item'
       ns = 'core'
       t_prop = VALUE #(
           ( n = 'key'  v = key )
           ( n = 'text' v = text )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segmented_button_item.

    result = me.

    _generic(
        name = 'SegmentedButtonItem'
        t_prop = VALUE #(
            ( n = 'icon'  v = icon )
            ( n = 'key'   v = key )
            ( n = 'text'  v = text )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~get_child.

    result = t_child[ index ].

  ENDMETHOD.

  METHOD z2ui5_if_view~get.

    result = m_root->m_last.

  ENDMETHOD.


  METHOD z2ui5_if_view~ui_column.

    result = _generic(
          name = 'Column'
          ns   = 'ui'
          t_prop = VALUE #(
              ( n = 'width'  v = width )
          ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~ui_columns.

    result = _generic(
          name = 'columns'
          ns   = 'ui'
          ).

  ENDMETHOD.

  METHOD z2ui5_if_view~ui_extension.

    result = _generic(
          name = 'extension'
          ns   = 'ui'
       ).

  ENDMETHOD.

  METHOD z2ui5_if_view~ui_table.

    result = _generic(
          name = 'Table'
          ns   = 'ui'
          t_prop = VALUE #(
              ( n = 'rows'  v = rows )
              ( n = 'selectionMode'   v = selectionmode )
              ( n = 'visibleRowCount' v = visiblerowcount )
              ( n = 'selectedIndex'   v = selectedindex )
          ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~ui_template.

    result = _generic(
          name = 'template'
          ns   = 'ui'
       ).

  ENDMETHOD.

  METHOD z2ui5_if_view~flex_box.


    result = _generic(
          name = 'FlexBox'
        t_prop = VALUE #(
            ( n = 'class'  v = class )
            ( n = 'renderType'  v = render_type )
            ( n = 'width'  v = width )
            ( n = 'height'  v = height )
            ( n = 'alignItems'  v = alignItems )
            ( n = 'justifyContent'  v = justifyContent )
        ) ).


  ENDMETHOD.

  METHOD z2ui5_if_view~vertical_layout.

    result = _generic(
          name = 'VerticalLayout'
           ns   = 'l'
        t_prop = VALUE #(
            ( n = 'class'  v = class )
            ( n = 'width'  v = width )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~flex_item_data.

    result = me.

    _generic(
          name = 'FlexItemData'
        t_prop = VALUE #(
            ( n = 'growFactor'  v = grow_factor )
            ( n = 'baseSize'   v = base_size )
            ( n = 'backgroundDesign'   v = background_design )
            ( n = 'styleClass'   v = style_class )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~grid_data.

    result = _generic(
           name = 'GridData'
           ns = 'l'
        t_prop = VALUE #(
            ( n = 'span'  v = span )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~layout_data.

    result = _generic(
            ns = ns
           name = 'layoutData'
       ).

  ENDMETHOD.

  METHOD z2ui5_if_view~tab.

    result = _generic(
         name = 'Tab'
         ns = 'webc'
         t_prop = VALUE #(
             ( n = 'text'     v = text )
             ( n = 'selected' v = selected )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~tab_container.

    result = _generic(
           name = 'TabContainer'
           ns = 'webc'
       ).

  ENDMETHOD.

  METHOD z2ui5_if_view~bars.

    result = _generic(
         name = 'bars'
         ns = 'mchart'
         t_prop = VALUE #(
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_bar_chart.

    result = _generic(
         name = 'InteractiveBarChart'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'selectionChanged'  v = selectionchanged )
             ( n = 'showError'  v = showerror )
             ( n = 'press'  v = press )
             ( n = 'labelWidth'  v = labelwidth )
             ( n = 'errorMessageTitle'  v = errormessagetitle )
             ( n = 'errorMessage'  v = errormessage )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_bar_chart_bar.

    result = _generic(
         name = 'InteractiveBarChartBar'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'label'    v = label )
             ( n = 'displayedValue' v = displayedvalue )
             ( n = 'value'    v = value )
             ( n = 'selected' v = selected )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_donut_chart.

    result = _generic(
         name = 'InteractiveDonutChart'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'selectionChanged'  v = selectionChanged )
             ( n = 'showError' v = _=>get_abap_2_json( showerror ) )
             ( n = 'errorMessageTitle'  v = errormessagetitle )
             ( n = 'errorMessage'  v = errormessage )
             ( n = 'displayedSegments'  v = displayedsegments )
             ( n = 'press'  v = press )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_donut_chart_segment.

    result = _generic(
         name = 'InteractiveDonutChartSegment'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'label'  v = label )
             ( n = 'displayedValue'  v = displayedvalue )
             ( n = 'value'     v = value )
             ( n = 'selected'  v = selected )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_line_chart.

    result = _generic(
         name = 'InteractiveLineChart'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'selectionChanged'  v = selectionChanged )
             ( n = 'showError'  v = _=>get_abap_2_json( showerror ) )
             ( n = 'press'  v = press )
             ( n = 'errorMessageTitle'  v = errormessagetitle )
             ( n = 'errorMessage'  v = errormessage )
             ( n = 'precedingPoint'  v = precedingpoint )
             ( n = 'succeedingPoint'  v = succeddingpoint )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_line_chart_point.

    result = _generic(
         name = 'InteractiveLineChartPoint'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'label'  v = label )
             ( n = 'secondaryLabel'  v = secondarylabel )
             ( n = 'value'  v = value )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~points.

    result = _generic(
         name = 'Points'
         ns = 'mchart'
         t_prop = VALUE #(
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~radial_micro_chart.

    result = _generic(
         name = 'RadialMicorChart'
         ns = 'mchart'
         t_prop = VALUE #(
             ( n = 'percentage'  v = percentage )
             ( n = 'press'  v = press )
             ( n = 'sice'  v = sice )
             ( n = 'valueColor'  v = valuecolor )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segments.

    result = _generic(
         name = 'segments'
         ns = 'mchart'
         t_prop = VALUE #(
       ) ).

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
        error           TYPE REF TO cx_root
        app             TYPE REF TO object OPTIONAL
        kind            TYPE string OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO  z2ui5_lcl_system_app.

  PROTECTED SECTION.

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

      WHEN client->cs-lifecycle_method-on_init.
        z2ui5_on_init( client ).
      WHEN client->cs-lifecycle_method-on_event.
        z2ui5_on_event( client ).
      WHEN client->cs-lifecycle_method-on_rendering.
        z2ui5_on_rendering( client ).
    ENDCASE.
  ENDMETHOD.

  METHOD factory_error.

    r_result = NEW #( ).

    r_result->ms_error-x_error = error.
    r_result->ms_error-app     ?= app.
    r_result->ms_error-kind    = kind.

  ENDMETHOD.


  METHOD z2ui5_on_init.
    IF ms_error-x_error IS NOT BOUND.
      client->view_show( 'HOME' ).
      ms_home-is_initialized = abap_true.
      ms_home-btn_text = 'check'.
      ms_home-btn_event_id = 'BUTTON_CHECK'.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = 'sap-icon://validate'.
    ELSE.
      client->view_show( 'ERROR' ).
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-view_active.

      WHEN 'HOME'.
        CASE client->get( )-event.

          WHEN 'BUTTON_CHANGE'.
            ms_home-btn_text = 'check'.
            ms_home-btn_event_id = 'BUTTON_CHECK'.
            ms_home-btn_icon = 'sap-icon://validate'.
            ms_home-class_editable = abap_true.

          WHEN 'BUTTON_CHECK'.
            TRY.
                DATA li_app_test TYPE REF TO z2ui5_if_app.
                ms_home-classname = _=>get_trim_upper( ms_home-classname ).
                CREATE OBJECT li_app_test TYPE (ms_home-classname).

                client->popup_message_toast( 'App is ready to start!' ).
                ms_home-btn_text = 'edit'.
                ms_home-btn_event_id = 'BUTTON_CHANGE'.
                ms_home-btn_icon = 'sap-icon://edit'.
                ms_home-class_value_state = 'Success'.
                ms_home-class_editable = abap_false.

              CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
                ms_home-class_value_state_text = lx->get_text( ).
                ms_home-class_value_state = 'Warning'.
                client->popup_message_box(
                    text = ms_home-class_value_state_text
                    type = 'error'
                     ).
            ENDTRY.

          WHEN 'DEMOS'.
            DATA li_app TYPE REF TO z2ui5_if_app.
            TRY.
                CREATE OBJECT li_app TYPE ('Z2UI5_CL_APP_DEMO_00').
                client->nav_app_call( li_app ).
              CATCH cx_root.
                client->popup_message_box( `Demos not available. Check the demo folder or you release is lower v750` ).
            ENDTRY.
        ENDCASE.

      WHEN 'ERROR'.
        CASE client->get( )-event.

          WHEN 'BUTTON_HOME'.
            client->nav_app_home( ).

          WHEN 'BUTTON_BACK'.
            client->nav_app_leave( client->get( )-id_prev_app ).

        ENDCASE.
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    IF ms_error-x_error IS BOUND.
      DATA(view) = client->factory_view( 'ERROR' ).
      view->message_page(
          text = '500 Internal Server Error'
          enable_formatted_text = abap_true
          description = ms_error-x_error->get_text( )
          icon = 'sap-icon://message-error'
        )->buttons(
        )->button(
              text  = 'HOME'
              press = view->_event( 'BUTTON_HOME' )
        )->button(
              text = 'BACK'
              press = view->_event( 'BUTTON_BACK' )
              type = 'Emphasized'
        ).

      RETURN.
    ENDIF.

    view = client->factory_view( 'HOME' ).
    DATA(page) = view->page( 'abap2UI5 - Development of UI5 Apps in pure ABAP' ).
    page->header_content(
        )->link( text = 'SCN' href = 'https://blogs.sap.com/tag/abap2ui5/'
        )->link( text = 'Twitter' href = 'https://twitter.com/OblomovDev'
        )->link( text = 'GitHub' href = 'https://github.com/oblomov-dev/abap2ui5' ).

    DATA(grid) = page->grid( 'L12 M12 S12' )->content( 'l' ).
    DATA(form) = grid->simple_form( 'Quick Start' )->content( 'f' ).

    form->label( 'Step 1'
       )->text( 'Create a new global class in the abap system'
       )->label( 'Step 2'
       )->text( 'Add the interface Z2UI5_IF_APP'
       )->label( 'Step 3'
       )->text( 'Implement the view and the behaviour'
       )->link( text = '(Example)' href = 'https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/00/z2ui5_cl_app_demo_01.clas.abap'
       )->label( 'Step 4'
    ).

    IF ms_home-class_editable = abap_true.
      form->input(
           value            = form->_bind( ms_home-classname )
           placeholder      = 'fill in the classname and press check'
           value_state      = ms_home-class_value_state
           value_state_text = ms_home-class_value_state_text
           editable         = ms_home-class_editable
       ).
    ELSE.
      form->text( ms_home-classname ).
    ENDIF.

    form->button( text = ms_home-btn_text press = view->_event( ms_home-btn_event_id ) icon = ms_home-btn_icon
       )->label( 'Step 5' ).

    DATA(lv_link) = client->get( )-s_request-url_app_gen && ms_home-classname.
    form->link( text = 'Link to the Application'
            href = lv_link
             enabled = xsdbool( ms_home-class_editable = abap_false )
        ).

    grid = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).
    grid->simple_form( 'Applications and Examples' )->content( 'f'
      )->button( text = `Press to continue..` press = view->_event( 'DEMOS' ) ).



  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_db IMPLEMENTATION.

  METHOD load_app.

    DATA(ls_db) = read( id ).

    _=>trans_xml_2_object(
      EXPORTING
        xml    = ls_db-data
      IMPORTING
        data   = result ).

  ENDMETHOD.

  METHOD create.

    DATA ls_db TYPE z2ui5_t_draft.

    ls_db = VALUE #(
      uuid  = id
      uname = _=>get_user_tech( )
      timestampl = _=>get_timestampl( )
      response = response
      data  = _=>trans_object_2_xml( REF #( db ) ) ).

    MODIFY z2ui5_t_draft FROM @ls_db.
    _=>raise( when = xsdbool( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

    SELECT SINGLE *
      FROM z2ui5_t_draft
     WHERE uuid = @id
    INTO @result.

    _=>raise( when = xsdbool( sy-subrc <> 0 ) ).

  ENDMETHOD.

  METHOD cleanup.

    DATA lv_timestampl TYPE timestampl.

    DATA(lv_time) = sy-uzeit.
    lv_time = lv_time - ( 60 * 60 * 4 ).

    CONVERT DATE sy-datum TIME lv_time
       INTO TIME STAMP lv_timestampl TIME ZONE sy-zonlo.

    DELETE FROM z2ui5_t_draft WHERE timestampl < @lv_timestampl.
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

  METHOD constructor.
    TRY.
        ms_db-id = _=>get_uuid( ).
      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.

  METHOD execute_init.

    ss_client = VALUE #( t_header = z2ui5_cl_http_handler=>client-t_header
                         t_param  = z2ui5_cl_http_handler=>client-t_param
                         o_body   = z2ui5_lcl_utility_tree_json=>factory( z2ui5_cl_http_handler=>client-body ) ).

    TRY.
        DATA(lv_id_prev) = ss_client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'ID' )->get_val( ).
      CATCH cx_root.
        r_result = set_app_start( ).
        RETURN.
    ENDTRY.

    r_result = set_app_client_update( lv_id_prev ).

  ENDMETHOD.


  METHOD execute_finish.

    _=>raise( when = xsdbool( lines( ms_next-t_screen ) = 0 ) ).

    IF ms_next-view IS NOT INITIAL.
      IF ms_next-check_set_prev_view = abap_true.
        _=>raise( `New view_show called and set_prev_view active - both not possible` ).
      ENDIF.
      TRY.
          DATA(lr_screen) = REF #( ms_next-t_screen[ name = ms_next-view ] ).
        CATCH cx_root.
          _=>raise( `View with the name ` && ms_next-view && ` not found - check the rendering` ).
      ENDTRY.
    ELSEIF ms_next-view_popup IS INITIAL.
      lr_screen = REF #( ms_next-t_screen[ 1 ] ).
      ms_next-view = lr_screen->name.
    ENDIF.

    DATA(lo_ui5_model) = z2ui5_lcl_utility_tree_json=>factory( ).

    IF lr_screen IS BOUND.
      DATA(ls_view) = lr_screen->o_parser->get_view( ).
      lo_ui5_model->add_attribute( n = `vView` v = ls_view-xml ).
      ls_view-o_model->mv_name = 'oViewModel'.
      lo_ui5_model->add_attribute_instance( ls_view-o_model ).
    ENDIF.

    IF ms_next-view_popup IS NOT INITIAL.
      TRY.
          DATA(lr_screen_popup) = REF #( ms_next-t_screen[ name = ms_next-view_popup ] ).
        CATCH cx_root.
          _=>raise( `Popup with the name ` && ms_next-view_popup && ` not found` ).
      ENDTRY.

      DATA(ls_view_popup) = lr_screen_popup->o_parser->get_view( check_popup_active = abap_true ).

      lo_ui5_model->add_attribute( n = `vViewPopup` v = ls_view_popup-xml ).
      ls_view_popup-o_model->mv_name = 'oViewModelPopup'.
      lo_ui5_model->add_attribute_instance( ls_view_popup-o_model ).
    ENDIF.


    DATA(lo_system) = lo_ui5_model->add_attribute_object( 'oSystem' ).
    lo_system->add_attribute( n = 'ID' v = ms_db-id ).
    IF lr_screen IS BOUND.
      lo_system->add_attribute( n = 'VIEW' v = lr_screen->name ).
    ENDIF.
    IF lr_screen_popup IS BOUND.
      lo_system->add_attribute( n = 'VIEW_POPUP' v = lr_screen_popup->name ).
    ENDIF.

    lo_system->add_attribute( n = 'CHECK_DEBUG_ACTIVE' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-check_debug_mode )  apos_active = abap_false ).

    IF ms_next-t_after IS NOT INITIAL.
      DATA(lo_list) = lo_ui5_model->add_attribute_list( 'oAfter' ).
      LOOP AT ms_next-t_after REFERENCE INTO DATA(lr_after).
        DATA(lo_list2) = lo_list->add_list_list( ).

        LOOP AT lr_after->* REFERENCE INTO DATA(lr_con).
          lo_list2->add_list_val( lr_con->* ).
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF ms_next-page_scroll_pos IS NOT INITIAL.
      lo_ui5_model->add_attribute( n = 'PAGE_SCROLL_POS' v = CONV string( ms_next-page_scroll_pos ) apos_active = abap_false ).
    ENDIF.

    lo_list = lo_ui5_model->add_attribute_list( 'oFocus' ).
    lo_list->add_list_object( )->add_attribute(  n = 'test' v = '500' ).
    lo_list->add_list_object( )->add_attribute(  n = 'test2' v = '500' ).

    IF ms_next-focus_cursor_pos IS NOT INITIAL.
      lo_ui5_model->add_attribute( n = 'FOCUS_POS' v = CONV string( ms_next-focus_cursor_pos ) apos_active = abap_false ).
    ENDIF.
    IF ms_next-check_set_prev_view = abap_true.
      lo_ui5_model->add_attribute( n = 'SET_PREV_VIEW' v = 'true' apos_active = abap_false ).
    ENDIF.
    r_result = lo_ui5_model->get_root( )->write_result( ).

    z2ui5_lcl_db=>create(
        id = ms_db-id
        response = r_result
        db = ms_db ).

  ENDMETHOD.


  METHOD set_app_client_update.

    CONSTANTS c_prefix TYPE string VALUE `R_RESULT->MS_DB-O_APP->`.

    r_result = NEW #( ).
    DATA(lv_id) = r_result->ms_db-id.
    r_result->ms_db = z2ui5_lcl_db=>load_app( id_prev ).
    r_result->ms_db-id = lv_id.
    r_result->ms_db-id_prev = id_prev.

    TRY.
        r_result->ms_next-view_popup = ss_client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'VIEW_POPUP' )->get_val( ).
        DATA(lo_popup_model) = ss_client-o_body->get_attribute( 'OPOPUP' ).

        LOOP AT r_result->ms_db-t_attri REFERENCE INTO DATA(lr_attri)
        WHERE bind_type = z2ui5_if_view=>cs-bind_type-two_way.

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
          ASSIGN (lv_name) TO <attribute>.
          _=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          CASE lr_attri->type_kind.

            WHEN 'g' OR 'I' OR 'C'.
              DATA(lv_value) = lo_popup_model->get_attribute( lr_attri->name )->get_val( ).
              <attribute> = lv_value.

            WHEN 'h'.
              _=>trans_ref_tab_2_tab(
                   EXPORTING ir_tab_from = lo_popup_model->get_attribute( lr_attri->name )->mr_actual
                   CHANGING ct_to   = <attribute> ).

          ENDCASE.
        ENDLOOP.

      CATCH cx_root.

        LOOP AT r_result->ms_db-t_attri REFERENCE INTO lr_attri
      WHERE bind_type = z2ui5_if_view=>cs-bind_type-two_way.

          lv_name = c_prefix && to_upper( lr_attri->name ).
          ASSIGN (lv_name) TO <attribute>.
          _=>raise( when = xsdbool( sy-subrc <> 0 ) ).

          CASE lr_attri->type_kind.

            WHEN 'g' OR 'I' OR 'C'.
              lv_value = ss_client-o_body->get_attribute( lr_attri->name )->get_val( ).
              <attribute> = lv_value.

            WHEN 'h'.
              _=>trans_ref_tab_2_tab(
                   EXPORTING ir_tab_from = ss_client-o_body->get_attribute( lr_attri->name )->mr_actual
                   CHANGING ct_to   = <attribute> ).

          ENDCASE.
        ENDLOOP.
    ENDTRY.


    TRY.
        r_result->ms_next-event = ss_client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'EVENT' )->get_val( ).
      CATCH cx_root.
    ENDTRY.
    TRY.
        r_result->ms_next-page_scroll_pos = ss_client-o_body->get_attribute( 'scrollPos' )->get_val( ).
      CATCH cx_root.
    ENDTRY.
    TRY.
        r_result->ms_next-view = ss_client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'VIEW' )->get_val( ).
      CATCH cx_root.
    ENDTRY.

    r_result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.

  ENDMETHOD.


  METHOD set_app_start.

    r_result = NEW #( ).
    DO.
      TRY.
          r_result->ms_db-app_classname = to_upper( ss_client-t_param[ name = 'app' ]-value ).

        CATCH cx_root ##CATCH_ALL.
          r_result->ms_db-o_app = NEW z2ui5_lcl_system_app( ).
          EXIT.
      ENDTRY.

      TRY.
          CREATE OBJECT r_result->ms_db-o_app TYPE (r_result->ms_db-app_classname).
          EXIT.

        CATCH cx_root ##CATCH_ALL.
          DATA(lo_error) = NEW z2ui5_lcl_system_app( ).
          lo_error->ms_error-x_error = NEW z2ui5_lcl_utility(
            val = `Class with name ` && r_result->ms_db-app_classname && ` not found. Please check your repository.` ).
          r_result->ms_db-o_app = lo_error.
          EXIT.
      ENDTRY.
    ENDDO.

    r_result->ms_db-app_classname      = _=>get_classname_by_ref( r_result->ms_db-o_app ).
    r_result->ms_db-t_attri            = _=>get_t_attri_by_ref( r_result->ms_db-o_app ).
    r_result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_init.

  ENDMETHOD.

  METHOD set_app_leave_to_id.

    r_result = NEW z2ui5_lcl_system_runtime( ).
    r_result->ms_db = z2ui5_lcl_db=>load_app( ms_next-nav_app_leave_to_id ).
    ms_next-nav_app_leave_to_id = ''.
    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_db-id_prev     = ms_db-id.
    r_result->ms_next = ms_next.
    r_result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_event.
    CLEAR ms_next.

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.

  METHOD set_app_call_new.

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).

    r_result = NEW #( ).
    r_result->ms_db-o_app = ms_next-s_nav_app_call_new-o_app.
    r_result->ms_db-app_classname = _=>get_classname_by_ref( r_result->ms_db-o_app ).

    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_db-id_prev_app_stack = ms_db-id.

    r_result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_init.
    r_result->ms_next-t_after = ms_next-t_after.
    r_result->ms_next-view    = ms_next-view.
    r_result->ms_next-event   = ms_next-event.

    r_result->ms_db-t_attri = _=>get_t_attri_by_ref( r_result->ms_db-o_app ).

  ENDMETHOD.

  METHOD set_app_system_error.

    z2ui5_lcl_db=>create( id = ms_db-id db = ms_db ).
    r_result = NEW #( ).
    r_result->ms_db-o_app = z2ui5_lcl_system_app=>factory_error(
                error = ix app = ms_db-o_app
                kind = kind ).
    r_result->ms_db-app_classname = _=>get_classname_by_ref( r_result->ms_db-o_app ).

    r_result->ms_db-id_prev_app = ms_db-id.
    r_result->ms_db-id_prev_app_stack = ms_db-id.
    "   r_result->ms_db-screen = ms_next-s_nav_app_call_new-screen.
    r_result->ms_next-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_init.

    r_result->ms_next-t_after = ms_next-t_after.
    r_result->ms_db-t_attri = _=>get_t_attri_by_ref( r_result->ms_db-o_app ).

    r_result->ms_db-id_prev_app = ms_db-id.
    ms_actual-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_init.

  ENDMETHOD.

  METHOD execute_before_app.

    result = NEW z2ui5_lcl_if_client( me ).

    IF event = z2ui5_if_client=>cs-lifecycle_method-on_rendering.
      ms_actual-lifecycle_method = event.
      RETURN.
    ENDIF.

    CLEAR ms_actual.
    DATA(lv_url) = ss_client-t_header[ name = 'referer' ]-value.

    ms_actual = VALUE #(
        lifecycle_method = ms_next-lifecycle_method

        id                = ms_db-id
        id_prev_app       = ms_db-id_prev_app
        id_prev_app_stack = ms_db-id_prev_app_stack

        event           = ms_next-event

        view_active     = ms_next-view
        popup_active    = ms_next-view_popup

        page_scroll_pos = ms_next-page_scroll_pos

        s_request = VALUE #(
             tenant = sy-mandt
             url_app = lv_url && '?sap-client=' && ms_actual-s_request-tenant && '&app=' && ms_db-app_classname
             url_app_gen = lv_url && '?sap-client=' && ms_actual-s_request-tenant && '&app='
             origin = ss_client-t_header[ name = 'origin' ]-value
             url_source_code = ms_actual-s_request-origin && `/sap/bc/adt/oo/classes/` && ms_db-app_classname && `/source/main`
        )
    ).

    CLEAR ms_next.

    IF ms_actual-lifecycle_method = z2ui5_if_client=>cs-lifecycle_method-on_init.
      "call new app with view
      ms_next-view = ms_actual-view_active.
    ENDIF.

  ENDMETHOD.


ENDCLASS.

CLASS z2ui5_lcl_if_client IMPLEMENTATION.

  METHOD constructor.

    mo_runtime = runtime.

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_message_toast.

    INSERT VALUE #( ( `MessageToast` ) ( `show` ) ( text ) )
         INTO TABLE mo_runtime->ms_next-t_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_message_box.

    INSERT VALUE #( ( `MessageBox` ) ( type ) ( text ) )
      INTO TABLE mo_runtime->ms_next-t_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~view_show.

    mo_runtime->ms_next-view = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~factory_view.

    result = z2ui5_lcl_if_view=>factory( mo_runtime ).
    INSERT VALUE #( name = name o_parser = CAST #( result ) ) INTO TABLE mo_runtime->ms_next-t_screen.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_home.

    z2ui5_if_client~nav_app_call( NEW z2ui5_lcl_system_app( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_client~get.

    result = mo_runtime->ms_actual.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.

    mo_runtime->ms_next-s_nav_app_call_new = VALUE #( o_app = app ).

  ENDMETHOD.

  METHOD z2ui5_if_client~view_popup.

    mo_runtime->ms_next-view_popup = name.

  ENDMETHOD.

  METHOD z2ui5_if_client~set.

    IF page_scroll_pos IS SUPPLIED.
      _=>raise( when = xsdbool( page_scroll_pos < 0 ) v = `Scroll position ` && page_scroll_pos && ` / values lower 0 not allowed` ).
      mo_runtime->ms_next-page_scroll_pos = page_scroll_pos.
    ENDIF.

    IF event IS SUPPLIED.
      mo_runtime->ms_next-event = event.
    ENDIF.

    IF focus IS SUPPLIED.

      mo_runtime->ms_next-focus = _=>get_attri_name_by_ref(
           i_focus  = focus
           io_app   = mo_runtime->ms_db-o_app
           t_attri  = mo_runtime->ms_db-t_attri
       ).

    ENDIF.

    IF set_prev_view IS SUPPLIED.
      mo_runtime->ms_next-check_set_prev_view = set_prev_view.
    ENDIF.

    IF focus_pos IS SUPPLIED.
      mo_runtime->ms_next-focus_cursor_pos = focus_pos.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.

    _=>raise( when = xsdbool( id = '' ) v = 'NAV_APP_LEAVE_ID_EMPTY' ).
    mo_runtime->ms_next-nav_app_leave_to_id = id.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app_by_id.

    result = CAST #( z2ui5_lcl_db=>load_app( id )-o_app ).

  ENDMETHOD.

ENDCLASS.
