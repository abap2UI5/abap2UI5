CLASS z2ui5_lcl_system_runtime DEFINITION DEFERRED.

CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        kind           TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
      END OF ty_attri.

   " TYPES ty_t_string TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    TYPES ty_tt_string TYPE STANDARD TABLE OF string_table WITH DEFAULT KEY.

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
          attri      TYPE STANDARD TABLE OF ty_attri WITH DEFAULT KEY,
          name_value TYPE STANDARD TABLE OF ty_name_value WITH DEFAULT KEY,
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

    CLASS-METHODS get_classname_by_ref
      IMPORTING
        in              TYPE REF TO object
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(r_result) TYPE string.

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

    CLASS-METHODS get_t_attri_by_ref
      IMPORTING
        VALUE(io_app)   TYPE REF TO object
      RETURNING
        VALUE(r_result) TYPE ty-t-attri.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_params_by_url
      IMPORTING
        VALUE(url)      TYPE string
        VALUE(name)     TYPE string
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
      IMPORTING
        ir_tab_from TYPE REF TO data
      CHANGING
        ct_to       TYPE STANDARD TABLE.

    CLASS-METHODS get_trim_upper
      IMPORTING
        val             TYPE clike
      RETURNING
        VALUE(r_result) TYPE string.

  PROTECTED SECTION.

    CLASS-DATA mv_counter TYPE i.

    CLASS-METHODS _get_t_attri
      IMPORTING
        io_app          TYPE REF TO object
        ir_attri        TYPE clike
      RETURNING
        VALUE(r_result) TYPE abap_attrdescr_tab.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_lcl_utility IMPLEMENTATION.

  METHOD get_trim_upper.
    r_result = val.
    SHIFT r_result RIGHT DELETING TRAILING ' '.
    SHIFT r_result LEFT DELETING LEADING ' '.
    r_result = to_upper( r_result ).
  ENDMETHOD.

  METHOD constructor.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root.
        ms_error-s_msg-message = val.
    ENDTRY.

    ms_error-kind = kind.

    TRY.
        ms_error-uuid = get_uuid( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD get_abap_2_json.

    DATA lo_ele TYPE REF TO cl_abap_elemdescr.
    lo_ele ?= cl_abap_elemdescr=>describe_by_data( val ).
    IF lo_ele->get_relative_name( ) = 'ABAP_BOOL'.
      DATA temp4 TYPE string.
      IF val = abap_true.
        temp4 = 'true'.
      ELSE.
        temp4 = 'false'.
      ENDIF.
      r_result = temp4.
    ELSE.
      DATA temp5 TYPE string.
      temp5 = val.
      r_result = |"{ temp5 }"|.
    ENDIF.

  ENDMETHOD.


  METHOD get_classname_by_ref.

    DATA lv_classname TYPE abap_abstypename.
    lv_classname = cl_abap_classdescr=>get_class_name( in ).
    r_result = substring_after( val = lv_classname sub = '\CLASS=' ).

  ENDMETHOD.

  METHOD get_params_by_url.

    url = get_trim_upper( url ).
    name = get_trim_upper( name ).

    url = segment( val = url index = 2 sep = `?` ).
    DATA lt_href TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    SPLIT url AT `&` INTO TABLE lt_href.
    DATA lt_url_params TYPE ty-t-name_value.

    DATA lr_href TYPE REF TO string.
    LOOP AT lt_href REFERENCE INTO lr_href.
      DATA lt_param TYPE string_table.
      CLEAR lt_param.
      SPLIT lr_href->* AT `=` INTO TABLE lt_param.
      DATA temp6 TYPE ty_name_value.
      CLEAR temp6.
      DATA temp9 LIKE LINE OF lt_param.
      DATA temp10 LIKE sy-tabix.
      temp10 = sy-tabix.
      READ TABLE lt_param INDEX 1 INTO temp9.
      sy-tabix = temp10.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
      ENDIF.
      temp6-name = to_upper( temp9 ).
      DATA temp11 LIKE LINE OF lt_param.
      DATA temp12 LIKE sy-tabix.
      temp12 = sy-tabix.
      READ TABLE lt_param INDEX 2 INTO temp11.
      sy-tabix = temp12.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
      ENDIF.
      temp6-value = to_upper( temp11 ).
      INSERT temp6 INTO TABLE lt_url_params.
    ENDLOOP.

    DATA temp7 LIKE LINE OF lt_url_params.
    DATA temp8 LIKE sy-tabix.
    temp8 = sy-tabix.
    READ TABLE lt_url_params WITH KEY name = name INTO temp7.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    r_result = temp7-value.

  ENDMETHOD.


  METHOD get_prev_when_no_handler.

    DATA lx_no_handler TYPE REF TO cx_sy_no_handler.
    TRY.
        lx_no_handler ?= val.
        TRY.
            lx_no_handler ?= val.
            r_result = lx_no_handler->previous.
          CATCH cx_root.
        ENDTRY.
      CATCH cx_root.
    ENDTRY.
    IF r_result IS NOT BOUND.
      r_result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_ref_data.

    FIELD-SYMBOLS <field> TYPE data.

    ASSIGN o->(n) TO <field>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.
    GET REFERENCE OF <field> INTO result.

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

        DATA lv_fm TYPE c LENGTH 11.
        lv_fm = 'GUID_CREATE'.
        CALL FUNCTION lv_fm
          IMPORTING
            ev_guid_32 = uuid.

    ENDTRY.

    r_result = uuid.

  ENDMETHOD.

  METHOD get_uuid_session.

    mv_counter = mv_counter + 1.
    DATA temp9 TYPE string.
    temp9 = mv_counter.
    r_result = shift_left( shift_right( temp9 ) ).

  ENDMETHOD.

  METHOD get_t_attri_by_ref.

    io_app ?= io_app.

    DATA temp10 TYPE REF TO cl_abap_classdescr.
    temp10 ?= cl_abap_objectdescr=>describe_by_object_ref( io_app ).
    DATA lo_descr LIKE temp10.
    lo_descr = temp10.
    DATA rt_attri LIKE lo_descr->attributes.
    rt_attri = lo_descr->attributes.
    DELETE rt_attri WHERE visibility <> cl_abap_classdescr=>public.

    DATA lr_attri TYPE REF TO abap_attrdescr.
    LOOP AT rt_attri REFERENCE INTO lr_attri.

      CASE lr_attri->type_kind.

        WHEN cl_abap_classdescr=>typekind_struct2 OR cl_abap_classdescr=>typekind_struct1.

          DATA lt_attri_tmp TYPE abap_attrdescr_tab.
          lt_attri_tmp = _get_t_attri(
              io_app = io_app
              ir_attri = lr_attri->name
               ).

          DELETE rt_attri.
          INSERT LINES OF lt_attri_tmp INTO TABLE rt_attri.

      ENDCASE.

    ENDLOOP.


    LOOP AT rt_attri REFERENCE INTO lr_attri.

      DATA ls_row TYPE ty_attri.
      CLEAR ls_row.
      ls_row-name = lr_attri->name.
      ls_row-kind = lr_attri->type_kind.

      INSERT ls_row INTO TABLE r_result.

    ENDLOOP.

  ENDMETHOD.

  METHOD trans_any_2_json.

    result = /ui2/cl_json=>serialize( any ).

  ENDMETHOD.

  METHOD trans_json_2_data.

    IF iv_json IS INITIAL.
      RETURN.
    ENDIF.

    DATA temp11 TYPE string.
    temp11 = iv_json.
    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = temp11
            assoc_arrays = abap_true
        CHANGING
         data            = ev_result
        ).

  ENDMETHOD.


  METHOD trans_object_2_xml.

    FIELD-SYMBOLS <object> TYPE any.
    ASSIGN object->* TO <object>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    CALL TRANSFORMATION id
       SOURCE data = <object>
       RESULT XML result
        OPTIONS data_refs = 'heap-or-create'.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.
    TYPES ty_T_ref TYPE STANDARD TABLE OF REF TO data.

    FIELD-SYMBOLS <tab_ui5> TYPE ty_T_ref.
    FIELD-SYMBOLS <comp> TYPE data.
    FIELD-SYMBOLS <comp_ui5> TYPE REF TO data.

    ASSIGN ir_tab_from->* TO <tab_ui5>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    FIELD-SYMBOLS <back> TYPE any.
    READ TABLE ct_to INDEX 1 ASSIGNING <back>.
    IF sy-subrc = 0.
      DATA temp12 TYPE REF TO cl_abap_structdescr.
      temp12 ?= cl_abap_structdescr=>describe_by_data( <back> ).
      DATA lo_struct LIKE temp12.
      lo_struct = temp12.
      DATA lt_components TYPE abap_component_tab.
      lt_components = lo_struct->get_components( ).
    ENDIF.

    LOOP AT ct_to ASSIGNING <back>.

      DATA lr_row_ui5 TYPE LINE OF ty_t_ref.
      DATA temp13 LIKE LINE OF <tab_ui5>.
      DATA temp14 LIKE sy-tabix.
      temp14 = sy-tabix.
      READ TABLE <tab_ui5> INDEX sy-tabix INTO temp13.
      sy-tabix = temp14.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
      ENDIF.
      lr_row_ui5 = temp13.
      FIELD-SYMBOLS <ui5_row> TYPE any.
      ASSIGN lr_row_ui5->* TO <ui5_row>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_lcl_utility
          EXPORTING
            val = 'CX_SY_SUBRC'.
      ENDIF.

      DATA ls_comp TYPE REF TO abap_componentdescr.
      LOOP AT lt_components REFERENCE INTO ls_comp.

        ASSIGN COMPONENT ls_comp->name OF STRUCTURE <back> TO <comp>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        ASSIGN COMPONENT ls_comp->name OF STRUCTURE <ui5_row> TO <comp_ui5>.
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

  METHOD _get_t_attri.

    FIELD-SYMBOLS <attribute> TYPE any.

    DATA lv_name TYPE string.
    lv_name = |IO_APP->{ to_upper( ir_attri ) }|.
    ASSIGN (lv_name) TO <attribute>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    DATA temp15 TYPE REF TO cl_abap_structdescr.
    temp15 ?= cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA lo_struct LIKE temp15.
    lo_struct = temp15.
    DATA lt_comp2 TYPE abap_component_tab.
    lt_comp2 = lo_struct->get_components( ).

    DATA lr_comp TYPE REF TO abap_componentdescr.
    LOOP AT lt_comp2 REFERENCE INTO lr_comp.

      DATA temp16 TYPE string.
      temp16 = ir_attri.
      DATA lv_element LIKE temp16.
      lv_element = temp16.
      lv_element = lv_element && '-' && lr_comp->name.

      TRY.
          lv_name = |IO_APP->{ to_upper( lv_element ) }|.
          ASSIGN (lv_name) TO <attribute>.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_lcl_utility
              EXPORTING
                val = 'CX_SY_SUBRC'.
          ENDIF.
          lo_struct ?= cl_abap_structdescr=>describe_by_data( <attribute> ).

          DATA lt_comp3 TYPE abap_component_tab.
          lt_comp3 = lo_struct->get_components( ).

          DATA lr_comp2 TYPE REF TO abap_componentdescr.
          LOOP AT lt_comp3 REFERENCE INTO lr_comp2.
            DATA lt_tmp TYPE abap_attrdescr_tab.
            CLEAR lt_tmp.
            lt_tmp = _get_t_attri(
                  io_app   = io_app
                  ir_attri = lr_comp2->name ).

            INSERT LINES OF lt_tmp INTO TABLE r_result.
          ENDLOOP.

        CATCH cx_root.
          DATA ls_row TYPE abap_attrdescr.
          ls_row-name = lv_element.
          ls_row-type_kind = lr_comp->type->type_kind.
          INSERT ls_row INTO TABLE r_result.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_text.

    IF ms_error-x_root IS NOT INITIAL.
      result = ms_error-x_root->get_text( ).
      DATA temp17 TYPE string.
      IF result IS INITIAL.
        temp17 = 'unknown error'.
      ELSE.
        temp17 = result.
      ENDIF.
      result = temp17.
      RETURN.
    ENDIF.

    IF ms_error-s_msg-message IS NOT INITIAL.
      result = ms_error-s_msg-message.
      DATA temp18 TYPE string.
      IF result IS INITIAL.
        temp18 = 'unknown error'.
      ELSE.
        temp18 = result.
      ENDIF.
      result = temp18.
      RETURN.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS _ DEFINITION INHERITING FROM z2ui5_lcl_utility.
ENDCLASS.

CLASS z2ui5_lcl_utility_tree_json DEFINITION.

  PUBLIC SECTION.

    TYPES ty_o_me TYPE REF TO z2ui5_lcl_utility_tree_json.
    TYPES ty_T_me TYPE STANDARD TABLE OF ty_o_me WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_S_name,
        n          TYPE string,
        v          TYPE string,
        apos_deact TYPE abap_bool,
      END OF ty_S_name.

    TYPES ty_T_name_value TYPE STANDARD TABLE OF ty_S_name.

    CLASS-METHODS factory
      IMPORTING
        iv_json         TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS constructor.

    METHODS get_root
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS get_attribute
      IMPORTING
        name            TYPE string
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS get_data
      RETURNING VALUE(r_result) TYPE REF TO data.

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
        VALUE(r_result) TYPE  ty_o_me.

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

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_lcl_utility_tree_json IMPLEMENTATION.


  METHOD add_attribute.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    CREATE OBJECT lo_attri TYPE z2ui5_lcl_utility_tree_json.

    lo_attri->mo_root = mo_root.
    lo_attri->mv_name = n.

    IF apos_active = abap_false.
      lo_attri->mv_value = v.
    ELSE.
      lo_attri->mv_value = escape( val = v format = cl_abap_format=>e_json_string ).
    ENDIF.
    lo_attri->mv_apost_active = apos_active.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    r_result = me.

  ENDMETHOD.


  METHOD add_attributes_name_value_tab.

    DATA lr_value TYPE REF TO ty_S_name.
    LOOP AT it_name_value REFERENCE INTO lr_value.

      add_attribute(
           n           = lr_value->n
           v           = lr_value->v
           apos_active = boolc( lr_value->apos_deact = abap_false )
       ).

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

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    CREATE OBJECT lo_attri TYPE z2ui5_lcl_utility_tree_json.
    lo_attri->mv_name = name.

    DATA temp19 TYPE ty_t_me.
    CLEAR temp19.
    temp19 = mt_values.
    APPEND lo_attri TO temp19.
    mt_values = temp19.

    lo_attri->mo_root = mo_root.
    lo_attri->mo_parent = me.

    r_result = lo_attri.

  ENDMETHOD.


  METHOD add_list_list.

    DATA temp21 TYPE string.
    temp21 = lines( mt_values ).
    r_result = add_attribute_list( name = temp21 ).

  ENDMETHOD.


  METHOD add_list_object.

    DATA temp22 TYPE string.
    temp22 = lines( mt_values ).
    r_result = add_attribute_object( name = temp22 ).

  ENDMETHOD.


  METHOD add_list_val.

    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    CREATE OBJECT lo_attri TYPE z2ui5_lcl_utility_tree_json.

    lo_attri->mv_name = lines( mt_values ).
    lo_attri->mv_value = v.

    lo_attri->mv_apost_active = abap_true.

    DATA temp23 TYPE ty_t_me.
    CLEAR temp23.
    temp23 = mt_values.
    APPEND lo_attri TO temp23.
    mt_values = temp23.

    lo_attri->mo_root = mo_root.
    lo_attri->mo_parent = me.

    r_result = lo_attri.

    r_result = me.

  ENDMETHOD.


  METHOD constructor.

    mo_root = me.

  ENDMETHOD.


  METHOD factory.

    CREATE OBJECT r_result.
    r_result->mo_root = r_result.

    DATA temp25 TYPE string.
    temp25 = iv_json.
    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = temp25
            assoc_arrays = abap_true
        CHANGING
         data            = r_result->mr_actual
        ).

  ENDMETHOD.


  METHOD get_attribute.

    IF mr_actual IS INITIAL.
      RAISE EXCEPTION TYPE _.
    ENDIF.


    DATA lo_attri TYPE REF TO z2ui5_lcl_utility_tree_json.
    CREATE OBJECT lo_attri TYPE z2ui5_lcl_utility_tree_json.
    lo_attri->mo_root = mo_root.
    lo_attri->mv_name = name.

    DATA lv_test TYPE string.
    lv_test = replace( val = name sub = '-' with = '_' occ = 0 ).

    FIELD-SYMBOLS <attribute> TYPE any.
    DATA lv_name TYPE string.
    lv_name = 'MR_ACTUAL->' && lv_test.
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

    "IF mv_check_attr_all_read = abap_false.
    "todo
    "ENDIF.
    r_result = mt_values.

  ENDMETHOD.


  METHOD get_data.

    FIELD-SYMBOLS <attribute> TYPE any.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    r_result = <attribute>.

  ENDMETHOD.


  METHOD get_name.

    r_result = mv_name.

  ENDMETHOD.


  METHOD get_parent.

    DATA temp26 LIKE r_result.
    IF mo_parent IS NOT BOUND.
      temp26 = me.
    ELSE.
      temp26 = mo_parent.
    ENDIF.
    r_result = temp26.

  ENDMETHOD.


  METHOD get_root.

    r_result = mo_root.

  ENDMETHOD.


  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    r_result = <attribute>.

  ENDMETHOD.

  METHOD wrap_json.

    r_result = iv_text.

    CASE mv_check_list.
      WHEN abap_true.
        DATA open_char TYPE c LENGTH 1.
        open_char = '['.
        DATA close_char TYPE c LENGTH 1.
        close_char = ']'.
      WHEN abap_false.
        open_char = '{'.
        close_char = '}'.
      WHEN OTHERS.
        RETURN.
    ENDCASE.
    r_result = open_char && r_result && close_char.
  ENDMETHOD.

  METHOD quote_json.
    IF iv_cond = abap_true.
      r_result = `"` && iv_text && `"`.
    ELSE.
      r_result = iv_text.
    ENDIF.
  ENDMETHOD.

  METHOD write_result.

    DATA lo_attri LIKE LINE OF mt_values.
    LOOP AT mt_values INTO lo_attri.

      IF sy-tabix > 1.
        r_result = r_result && |,|.
      ENDIF.

      IF mv_check_list = abap_false.
        r_result = r_result && |"{ lo_attri->mv_name }":|.
      ENDIF.
      " r_result = r_result && COND #( WHEN mv_check_list = abap_false THEN |"{ lo_attri->mv_name }":| ).

      IF lo_attri->mt_values IS NOT INITIAL.

        r_result = r_result && lo_attri->write_result( ).

      ELSE.

        r_result = r_result &&
           quote_json( iv_cond = boolc( lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL )
                       iv_text = lo_attri->mv_value ).
        " escape( val = lo_attri->mv_value  format = cl_abap_format=>e_json_string )
      ENDIF.

    ENDLOOP.

    r_result = wrap_json( r_result ).
  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_if_ui5_library DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_library.

    CONSTANTS cs LIKE z2ui5_if_ui5_library=>cs VALUE z2ui5_if_ui5_library=>cs.

    TYPES:
      BEGIN OF ty_S_view,
        xml     TYPE string,
        o_model TYPE REF TO z2ui5_lcl_utility_tree_json,
        t_attri TYPE _=>ty-t-attri,
      END OF ty_S_view.

    DATA m_name TYPE string.
    DATA m_ns   TYPE string.
    DATA mt_prop TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    DATA mt_attri  TYPE _=>ty-t-attri.
    DATA mo_app TYPE REF TO object.

    DATA m_root    TYPE REF TO z2ui5_lcl_if_ui5_library.
    DATA m_last    TYPE REF TO z2ui5_lcl_if_ui5_library.
    DATA m_parent  TYPE REF TO z2ui5_lcl_if_ui5_library.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_lcl_if_ui5_library WITH DEFAULT KEY.

    CLASS-METHODS factory
      IMPORTING
        t_attri       TYPE _=>ty-t-attri
        o_app         TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_if_ui5_library.

    METHODS get_view
      IMPORTING
        check_popup_active TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE ty_S_view.

    METHODS _generic
      IMPORTING
        name          TYPE string
        ns            TYPE string OPTIONAL
        t_prop        TYPE z2ui5_if_ui5_library=>ty_t_name_value optional
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_if_ui5_library.

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


CLASS z2ui5_lcl_if_ui5_library IMPLEMENTATION.

  METHOD _get_name_by_ref.

    IF type = cs-bind_type-one_time.
      DATA lv_id TYPE string.
      lv_id = _=>get_uuid_session( ).
      DATA temp27 TYPE z2ui5_lcl_utility=>ty_attri.
      CLEAR temp27.
      temp27-name = lv_id.
      temp27-data_stringify = _=>trans_any_2_json( value ).
      temp27-bind_type = type.
      INSERT temp27 INTO TABLE m_root->mt_attri.
      r_result = '/' && lv_id && ''.
      RETURN.
    ENDIF.

    "DATA lr_in TYPE REF TO data.
    DATA lr_in TYPE REF TO data.
    GET REFERENCE OF value INTO lr_in.

    DATA lr_attri TYPE REF TO z2ui5_lcl_utility=>ty_attri.
    LOOP AT m_root->mt_attri REFERENCE INTO lr_attri.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = |M_ROOT->MO_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_lcl_utility
          EXPORTING
            val = 'CX_SY_SUBRC'.
      ENDIF.

      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF <attribute> INTO lr_ref.

      IF lr_in = lr_ref.
        lr_attri->bind_type = type.
          DATA temp28 TYPE string.
          IF type = cs-bind_type-two_way.
            temp28 = '/oUpdate/'.
          ELSE.
            temp28 = '/'.
          ENDIF.
          r_result = temp28 && lr_attri->name.

        "  DATA temp25 TYPE string.
      "  IF type = cs-bind_type-two_way.
       "   r_result = '/oUpdate/' && lr_attri->name.
      "  ELSE.
      "    r_result = '/' && lr_attri->name.
      "  ENDIF.
        RETURN.
      ENDIF.

    ENDLOOP.

    "one time when not global class attribute
    lv_id = _=>get_uuid_session( ).
    DATA temp29 TYPE z2ui5_lcl_utility=>ty_attri.
    CLEAR temp29.
    temp29-name = lv_id.
    temp29-data_stringify = _=>trans_any_2_json( value ).
    temp29-bind_type = cs-bind_type-one_time.
    INSERT temp29 INTO TABLE m_root->mt_attri.
    r_result = '/' && lv_id && ''.

  ENDMETHOD.

  METHOD xml_get_begin.

    DATA temp30 TYPE string.
    IF check_popup_active = abap_false.
      DATA temp13 TYPE string.
      IF z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true.
        temp13 = `<Shell>`.
      ELSE.
        CLEAR temp13.
      ENDIF.
      temp30 = `<mvc:View controllerName="MyController"     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n| && `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n| && ` xmlns:editor="sap.ui.codeeditor"   xmlns:ui="sap.ui.table"  xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` && temp13.
    ELSE.
      temp30 = `<core:FragmentDefinition   xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n| && `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n| && ` xmlns:editor="sap.ui.codeeditor"  xmlns:ui="sap.ui.table"  xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > `.
    ENDIF.
    result = temp30.

  ENDMETHOD.

  METHOD xml_get_end.

   DATA temp31 TYPE string.
   IF check_popup_active = abap_false.
     DATA temp14 TYPE string.
     IF z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true.
       temp14 = `</Shell>`.
     ELSE.
       CLEAR temp14.
     ENDIF.
     temp31 = temp14 && `</mvc:View>`.
   ELSE.
     temp31 = `</core:FragmentDefinition>`.
   ENDIF.
   result = result && temp31.

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

      WHEN 'ZZHTML'.
        DATA temp32 LIKE LINE OF mt_prop.
        DATA temp33 LIKE sy-tabix.
        temp33 = sy-tabix.
        READ TABLE mt_prop WITH KEY n = 'VALUE' INTO temp32.
        sy-tabix = temp33.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
        ENDIF.
        result = temp32-v.
        RETURN.
    ENDCASE.

    DATA lv_tmp2 TYPE string.
    DATA temp15 TYPE string.
    IF m_ns <> ''.
      temp15 = |{ m_ns }:|.
    ELSE.
      CLEAR temp15.
    ENDIF.
    lv_tmp2 = temp15.
    DATA temp35 TYPE string.
    DATA val TYPE string.
    val = ``.
    DATA row LIKE LINE OF mt_prop.
    LOOP AT mt_prop INTO row WHERE v <> ''.
      val = |{ val } { row-n }="{ escape( val = row-v format = cl_abap_format=>e_xml_attr ) }" \n |.
    ENDLOOP.
    temp35 = val.
    DATA lv_tmp3 LIKE temp35.
    lv_tmp3 = temp35.
    result = |{ result } <{ lv_tmp2 }{ m_name } \n { lv_tmp3 }|.

    IF t_child IS INITIAL.
      result = result && '/>'.
      RETURN.
    ENDIF.

    result = result && '>'.

    LOOP AT t_child INTO lr_child.
      result = result && lr_child->xml_get( ).
    ENDLOOP.

    DATA lv_tmp TYPE string.
    DATA temp16 TYPE string.
    IF m_ns <> ''.
      temp16 = |{ m_ns }:|.
    ELSE.
      CLEAR temp16.
    ENDIF.
    lv_tmp = temp16.
    result = result && |</{ lv_tmp }{ m_name }>|.

  ENDMETHOD.

  METHOD _generic.

    CREATE OBJECT result.
    result->m_name = name.
    result->m_ns = ns.
    result->mt_prop = t_prop.
    result->m_parent = me.
    result->m_root   = m_root.
    INSERT result INTO TABLE t_child.

    m_root->m_last = result.

  ENDMETHOD.

  METHOD factory.

    CREATE OBJECT result.
    result->m_root = result.
    result->m_parent = result.
    result->mt_attri = t_attri.
    result->mo_app = o_app.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~button.

    result = me.

    DATA temp37 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp37.
    DATA temp38 LIKE LINE OF temp37.
    temp38-n = 'press'.
    temp38-v = press.
    APPEND temp38 TO temp37.
    temp38-n = 'text'.
    temp38-v = text.
    APPEND temp38 TO temp37.
    temp38-n = 'enabled'.
    temp38-v = _=>get_abap_2_json( enabled ).
    APPEND temp38 TO temp37.
    temp38-n = 'icon'.
    temp38-v = icon.
    APPEND temp38 TO temp37.
    DATA temp17 TYPE z2ui5_if_ui5_library=>ty_s_name_value.
    IF type IS NOT INITIAL.
      CLEAR temp17.
      temp17-n = 'type'.
      temp17-v = type.
    ELSE.
      CLEAR temp17.
    ENDIF.
    APPEND temp17 TO temp37.
    _generic(
       name   = 'Button'
       t_prop = temp37 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~input.

    result = me.

    DATA temp39 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp39.
    DATA temp40 LIKE LINE OF temp39.
    temp40-n = 'placeholder'.
    temp40-v = placeholder.
    APPEND temp40 TO temp39.
    temp40-n = 'type'.
    temp40-v = type.
    APPEND temp40 TO temp39.
    temp40-n = 'showClearIcon'.
    temp40-v = _=>get_abap_2_json( show_clear_icon ).
    APPEND temp40 TO temp39.
    temp40-n = 'description'.
    temp40-v = description.
    APPEND temp40 TO temp39.
    temp40-n = 'editable'.
    temp40-v = _=>get_abap_2_json( editable ).
    APPEND temp40 TO temp39.
    temp40-n = 'valueState'.
    temp40-v = value_state.
    APPEND temp40 TO temp39.
    temp40-n = 'valueStateText'.
    temp40-v = value_state_text.
    APPEND temp40 TO temp39.
    temp40-n = 'value'.
    temp40-v = value.
    APPEND temp40 TO temp39.
    temp40-n = 'suggestionItems'.
    temp40-v = suggestion_items.
    APPEND temp40 TO temp39.
    temp40-n = 'showSuggestion'.
    temp40-v = _=>get_abap_2_json( showsuggestion ).
    APPEND temp40 TO temp39.
    _generic(
       name   = 'Input'
       t_prop = temp39 ).


  ENDMETHOD.

  METHOD get_view.

    result-xml = m_root->xml_get( check_popup_active ).

    DATA m_view_model TYPE REF TO z2ui5_lcl_utility_tree_json.
    m_view_model = z2ui5_lcl_utility_tree_json=>factory( ).
    DATA lo_update TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_update = m_view_model->add_attribute_object( 'oUpdate' ).

    DATA lr_attri TYPE REF TO z2ui5_lcl_utility=>ty_attri.
    LOOP AT mt_attri REFERENCE INTO lr_attri WHERE bind_type <> ''.

      IF lr_attri->bind_type = cs-bind_type-one_time.

        m_view_model->add_attribute(
              n = lr_attri->name
              v = lr_attri->data_stringify
              apos_active = abap_false ).

        CONTINUE.
      ENDIF.

      DATA lo_actual TYPE REF TO z2ui5_lcl_utility_tree_json.
      DATA temp41 LIKE lo_actual.
      IF lr_attri->bind_type = cs-bind_type-one_way.
        temp41 = m_view_model.
      ELSE.
        temp41 = lo_update.
      ENDIF.
      lo_actual = temp41.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = |M_PARENT->MO_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_lcl_utility
          EXPORTING
            val = 'CX_SY_SUBRC'.
      ENDIF.

      CASE lr_attri->kind.

        WHEN 'g' OR 'D' OR 'P' OR 'T' OR 'C'.

          lo_actual->add_attribute( n = lr_attri->name
                                    v = _=>get_abap_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN 'I'.
          DATA temp42 TYPE string.
          temp42 = <attribute>.
          lo_actual->add_attribute( n = lr_attri->name
                                      v = temp42
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
    DELETE m_root->mt_attri WHERE bind_type = cs-bind_type-one_time.
    result-t_attri = m_root->mt_attri.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~page.

    DATA temp43 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp43.
    DATA temp44 LIKE LINE OF temp43.
    temp44-n = 'title'.
    temp44-v = title.
    APPEND temp44 TO temp43.
    temp44-n = 'showNavButton'.
    DATA temp18 TYPE z2ui5_if_ui5_library=>ty_s_name_value-v.
    IF nav_button_tap = ''.
      temp18 = 'false'.
    ELSE.
      temp18 = 'true'.
    ENDIF.
    temp44-v = temp18.
    APPEND temp44 TO temp43.
    temp44-n = 'navButtonTap'.
    temp44-v = nav_button_tap.
    APPEND temp44 TO temp43.
    result = _generic(
        name   = 'Page'
         t_prop = temp43 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~vbox.

    DATA temp45 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp45.
    DATA temp46 LIKE LINE OF temp45.
    temp46-n = 'class'.
    temp46-v = 'sapUiSmallMargin'.
    APPEND temp46 TO temp45.
    result = _generic(
         name   = 'VBox'
         t_prop = temp45 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~hbox.

    DATA temp47 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp47.
    DATA temp48 LIKE LINE OF temp47.
    temp48-n = 'class'.
    temp48-v = 'sapUiSmallMargin'.
    APPEND temp48 TO temp47.
    result = _generic(
          name   = 'HBox'
          t_prop = temp47 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~simple_form.

    DATA temp49 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp49.
    DATA temp50 LIKE LINE OF temp49.
    temp50-n = 'title'.
    temp50-v = title.
    APPEND temp50 TO temp49.
    temp50-n = 'editable'.
    temp50-v = 'true'.
    APPEND temp50 TO temp49.
    temp50-n = 'layout'.
    temp50-v = 'ResponsiveGridLayout'.
    APPEND temp50 TO temp49.
    temp50-n = 'labelSpanXL'.
    temp50-v = '4'.
    APPEND temp50 TO temp49.
    temp50-n = 'labelSpanL'.
    temp50-v = '3'.
    APPEND temp50 TO temp49.
    temp50-n = 'labelSpanM'.
    temp50-v = '4'.
    APPEND temp50 TO temp49.
    temp50-n = 'labelSpanS'.
    temp50-v = '12'.
    APPEND temp50 TO temp49.
    temp50-n = 'emptySpanXL'.
    temp50-v = '0'.
    APPEND temp50 TO temp49.
    temp50-n = 'emptySpanL'.
    temp50-v = '4'.
    APPEND temp50 TO temp49.
    temp50-n = 'emptySpanM'.
    temp50-v = '0'.
    APPEND temp50 TO temp49.
    temp50-n = 'emptySpanS'.
    temp50-v = '0'.
    APPEND temp50 TO temp49.
    temp50-n = 'columnsL'.
    temp50-v = '1'.
    APPEND temp50 TO temp49.
    temp50-n = 'columnsM'.
    temp50-v = '1'.
    APPEND temp50 TO temp49.
    temp50-n = 'singleContainerFullSize'.
    temp50-v = 'false'.
    APPEND temp50 TO temp49.
    temp50-n = 'adjustLabelSpan'.
    temp50-v = 'false'.
    APPEND temp50 TO temp49.
    result = _generic(
      name   = 'SimpleForm'
      ns     = 'f'
      t_prop = temp49 ).

  ENDMETHOD.


  METHOD z2ui5_if_ui5_library~content.

    result = _generic( ns = ns name = 'content' ).

  ENDMETHOD.


  METHOD z2ui5_if_ui5_library~title.

    result = me.

    DATA temp51 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp51.
    DATA temp52 LIKE LINE OF temp51.
    temp52-n = 'text'.
    temp52-v = title.
    APPEND temp52 TO temp51.
    _generic(
         name  = 'Title'
         t_prop = temp51
        ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~code_editor.

    result = me.

    DATA temp53 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp53.
    DATA temp54 LIKE LINE OF temp53.
    temp54-n = 'value'.
    temp54-v = value.
    APPEND temp54 TO temp53.
    temp54-n = 'type'.
    temp54-v = type.
    APPEND temp54 TO temp53.
    temp54-n = 'editable'.
    temp54-v = _=>get_abap_2_json( editable ).
    APPEND temp54 TO temp53.
    temp54-n = 'height'.
    temp54-v = height.
    APPEND temp54 TO temp53.
    temp54-n = 'width'.
    temp54-v = width.
    APPEND temp54 TO temp53.
    _generic(
        name  = 'CodeEditor'
        ns = 'editor'
        t_prop = temp53 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~zz_html.

    DATA lt_table TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    SPLIT val AT '<' INTO TABLE lt_table.

    DATA lv_html TYPE string.
    lv_html = ``.
    DATA lr_line TYPE REF TO string.
    LOOP AT lt_table REFERENCE INTO lr_line.

      IF lr_line->*(1) = '/'.
        lv_html = '</html:' && lr_line->*.
      ELSE.
        lv_html = '<html:' && lr_line->*.
      ENDIF.

    ENDLOOP.

    result = me.

    DATA temp55 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp55.
    DATA temp56 LIKE LINE OF temp55.
    temp56-n = 'VALUE'.
    temp56-v = lv_html.
    APPEND temp56 TO temp55.
    _generic(
         name  = 'ZZHTML'
         t_prop = temp55
    ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~overflow_toolbar.

    result = _generic( 'OverflowToolbar' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~toolbar_spacer.

    result = me.
    _generic( 'ToolbarSpacer' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~combobox.

    result = me.

    DATA temp57 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp57.
    DATA temp58 LIKE LINE OF temp57.
    temp58-n = 'showClearIcon'.
    temp58-v = _=>get_abap_2_json( show_clear_icon ).
    APPEND temp58 TO temp57.
    temp58-n = 'selectedKey'.
    temp58-v = selectedkey.
    APPEND temp58 TO temp57.
    temp58-n = 'items'.
    temp58-v = items.
    APPEND temp58 TO temp57.
    _generic(
       name  = 'ComboBox'
       t_prop = temp57 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~date_picker.

    result = me.

    DATA temp59 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp59.
    DATA temp60 LIKE LINE OF temp59.
    temp60-n = 'value'.
    temp60-v = value.
    APPEND temp60 TO temp59.
    temp60-n = 'placeholder'.
    temp60-v = placeholder.
    APPEND temp60 TO temp59.
    _generic(
      name       = 'DatePicker'
      t_prop = temp59 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~date_time_picker.

    result = me.

    DATA temp61 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp61.
    DATA temp62 LIKE LINE OF temp61.
    temp62-n = 'value'.
    temp62-v = value.
    APPEND temp62 TO temp61.
    temp62-n = 'placeholder'.
    temp62-v = placeholder.
    APPEND temp62 TO temp61.
    _generic(
        name  = 'DateTimePicker'
        t_prop = temp61 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~label.

    result = me.

    DATA temp63 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp63.
    DATA temp64 LIKE LINE OF temp63.
    temp64-n = 'text'.
    temp64-v = text.
    APPEND temp64 TO temp63.
    _generic(
       name  = 'Label'
       t_prop = temp63 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~link.

    result = me.

    DATA temp65 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp65.
    DATA temp66 LIKE LINE OF temp65.
    temp66-n = 'text'.
    temp66-v = text.
    APPEND temp66 TO temp65.
    temp66-n = 'target'.
    temp66-v = '_blank'.
    APPEND temp66 TO temp65.
    temp66-n = 'href'.
    temp66-v = href.
    APPEND temp66 TO temp65.
    temp66-n = 'enabled'.
    temp66-v = _=>get_abap_2_json( enabled ).
    APPEND temp66 TO temp65.
    _generic(
     name  = 'Link'
       t_prop = temp65 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~segmented_button.

    result = me.

    DATA temp67 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp67.
    DATA temp68 LIKE LINE OF temp67.
    temp68-n = 'selectedKey'.
    temp68-v = selected_key.
    APPEND temp68 TO temp67.
    _generic(
       name  = 'SegmentedButton'
       t_prop = temp67 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~step_input.

    result = me.

    DATA temp69 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp69.
    DATA temp70 LIKE LINE OF temp69.
    temp70-n = 'max'.
    temp70-v = max.
    APPEND temp70 TO temp69.
    temp70-n = 'min'.
    temp70-v = min.
    APPEND temp70 TO temp69.
    temp70-n = 'step'.
    temp70-v = step.
    APPEND temp70 TO temp69.
    temp70-n = 'value'.
    temp70-v = value.
    APPEND temp70 TO temp69.
    _generic(
         name  = 'StepInput'
         t_prop = temp69 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~switch.

    result = me.

    DATA temp71 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp71.
    DATA temp72 LIKE LINE OF temp71.
    temp72-n = 'type'.
    temp72-v = type.
    APPEND temp72 TO temp71.
    temp72-n = 'enabled'.
    temp72-v = _=>get_abap_2_json( enabled ).
    APPEND temp72 TO temp71.
    temp72-n = 'state'.
    temp72-v = state.
    APPEND temp72 TO temp71.
    temp72-n = 'customTextOff'.
    temp72-v = customtextoff.
    APPEND temp72 TO temp71.
    temp72-n = 'customTextOn'.
    temp72-v = customtexton.
    APPEND temp72 TO temp71.
    _generic(
          name  = 'Switch'
          t_prop = temp71 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~text_area.

    result = me.

    DATA temp73 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp73.
    DATA temp74 LIKE LINE OF temp73.
    temp74-n = 'value'.
    temp74-v = value.
    APPEND temp74 TO temp73.
    temp74-n = 'rows'.
    temp74-v = rows.
    APPEND temp74 TO temp73.
    temp74-n = 'height'.
    temp74-v = height.
    APPEND temp74 TO temp73.
    temp74-n = 'width'.
    temp74-v = width.
    APPEND temp74 TO temp73.
    _generic(
          name  = 'TextArea'
            t_prop = temp73 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~time_picker.

    result = me.

    DATA temp75 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp75.
    DATA temp76 LIKE LINE OF temp75.
    temp76-n = 'value'.
    temp76-v = value.
    APPEND temp76 TO temp75.
    temp76-n = 'placeholder'.
    temp76-v = placeholder.
    APPEND temp76 TO temp75.
    _generic(
     name   = 'TimePicker'
     t_prop = temp75 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~checkbox.

    result = me.

    DATA temp77 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp77.
    DATA temp78 LIKE LINE OF temp77.
    temp78-n = 'text'.
    temp78-v = text.
    APPEND temp78 TO temp77.
    temp78-n = 'selected'.
    temp78-v = selected.
    APPEND temp78 TO temp77.
    temp78-n = 'enabled'.
    temp78-v = _=>get_abap_2_json( enabled ).
    APPEND temp78 TO temp77.
    _generic(
       name  = 'CheckBox'
       t_prop = temp77 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~progress_indicator.

    result = me.

    DATA temp79 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp79.
    DATA temp80 LIKE LINE OF temp79.
    temp80-n = 'percentValue'.
    temp80-v = _get_name_by_ref( percent_value ).
    APPEND temp80 TO temp79.
    temp80-n = 'displayValue'.
    temp80-v = display_value.
    APPEND temp80 TO temp79.
    temp80-n = 'showValue'.
    temp80-v = _=>get_abap_2_json( show_value ).
    APPEND temp80 TO temp79.
    temp80-n = 'state'.
    temp80-v = state.
    APPEND temp80 TO temp79.
    _generic(
         name  = 'ProgressIndicator'
         t_prop = temp79 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~text.

    result = me.

    DATA temp81 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp81.
    DATA temp82 LIKE LINE OF temp81.
    temp82-n = 'text'.
    temp82-v = text.
    APPEND temp82 TO temp81.
    _generic(
      name  = 'Text'
      t_prop = temp81
     ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~table.

    DATA temp83 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp83.
    DATA temp84 LIKE LINE OF temp83.
    temp84-n = 'items'.
    temp84-v = items.
    APPEND temp84 TO temp83.
    temp84-n = 'headerText'.
    temp84-v = header_text.
    APPEND temp84 TO temp83.
    temp84-n = 'growing'.
    temp84-v = _=>get_abap_2_json( growing ).
    APPEND temp84 TO temp83.
    temp84-n = 'growingThreshold'.
    temp84-v = growing_threshold.
    APPEND temp84 TO temp83.
    temp84-n = 'sticky'.
    temp84-v = sticky.
    APPEND temp84 TO temp83.
    result = _generic(
        name  = 'Table'
        t_prop = temp83 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~cells.

    result = _generic( 'cells' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~column.

    DATA temp85 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp85.
    DATA temp86 LIKE LINE OF temp85.
    temp86-n = 'width'.
    temp86-v = width.
    APPEND temp86 TO temp85.
    result = _generic(
        name  = 'Column'
          t_prop = temp85
     ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~columns.

    result = _generic( 'columns' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~column_list_item.

    DATA temp87 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp87.
    DATA temp88 LIKE LINE OF temp87.
    temp88-n = 'vAlign'.
    temp88-v = valign.
    APPEND temp88 TO temp87.
    result = _generic(
        name = 'ColumnListItem'
        t_prop = temp87
         ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~items.

    result = _generic( 'items' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~grid.

    DATA temp89 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp89.
    DATA temp90 LIKE LINE OF temp89.
    temp90-n = 'defaultSpan'.
    temp90-v = default_span.
    APPEND temp90 TO temp89.
    temp90-n = 'class'.
    temp90-v = class.
    APPEND temp90 TO temp89.
    result = _generic(
        name = 'Grid'
        ns   = 'l'
        t_prop = temp89 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~header_toolbar.

    result = _generic( 'headerToolbar' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~scroll_container.

    DATA temp91 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp91.
    DATA temp92 LIKE LINE OF temp91.
    temp92-n = 'height'.
    temp92-v = height.
    APPEND temp92 TO temp91.
    temp92-n = 'width'.
    temp92-v = width.
    APPEND temp92 TO temp91.
    temp92-n = 'vertical'.
    temp92-v = 'true'.
    APPEND temp92 TO temp91.
    temp92-n = 'focusable'.
    temp92-v = 'true'.
    APPEND temp92 TO temp91.
    result = _generic(
        name = 'ScrollContainer'
        t_prop = temp91 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~header_content.

    result = _generic( 'headerContent' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~sub_header.

    result = _generic( 'subHeader' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~footer.

    result = _generic( 'footer' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~dialog.

    DATA temp93 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp93.
    DATA temp94 LIKE LINE OF temp93.
    temp94-n = 'title'.
    temp94-v = title.
    APPEND temp94 TO temp93.
    result = _generic(
         name = 'Dialog'
        t_prop = temp93 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~table_select_dialog.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~list.

    DATA temp95 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp95.
    DATA temp96 LIKE LINE OF temp95.
    temp96-n = 'headerText'.
    temp96-v = header_text.
    APPEND temp96 TO temp95.
    temp96-n = 'items'.
    temp96-v = items.
    APPEND temp96 TO temp95.
    result = _generic(
        name = 'List'
        t_prop = temp95 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~standard_list_item.

    result = me.

    DATA temp97 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp97.
    DATA temp98 LIKE LINE OF temp97.
    temp98-n = 'title'.
    temp98-v = title.
    APPEND temp98 TO temp97.
    temp98-n = 'description'.
    temp98-v = description.
    APPEND temp98 TO temp97.
    temp98-n = 'icon'.
    temp98-v = icon.
    APPEND temp98 TO temp97.
    temp98-n = 'info'.
    temp98-v = info.
    APPEND temp98 TO temp97.
    temp98-n = 'press'.
    temp98-v = press.
    APPEND temp98 TO temp97.
    _generic(
        name = 'StandardListItem'
        t_prop = temp97 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~message_page.

    DATA temp99 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp99.
    DATA temp100 LIKE LINE OF temp99.
    temp100-n = 'showHeader'.
    temp100-v = _=>get_abap_2_json( show_header ).
    APPEND temp100 TO temp99.
    temp100-n = 'description'.
    temp100-v = description.
    APPEND temp100 TO temp99.
    temp100-n = 'icon'.
    temp100-v = icon.
    APPEND temp100 TO temp99.
    temp100-n = 'text'.
    temp100-v = text.
    APPEND temp100 TO temp99.
    temp100-n = 'enableFormattedText'.
    temp100-v = _=>get_abap_2_json( enable_formatted_text ).
    APPEND temp100 TO temp99.
    result = _generic(
        name   = 'MessagePage'
        t_prop = temp99 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~buttons.

    result = _generic( 'buttons' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~_bind.

    result = '{' && _get_name_by_ref( value = val  type = cs-bind_type-two_way ) && '}'.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~_bind_one_way.

    result = '{' && _get_name_by_ref( value = val  type = cs-bind_type-one_way ) && '}'.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~get_parent.
    result = m_parent.
  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~message_strip.

    result = me.

    DATA temp101 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp101.
    DATA temp102 LIKE LINE OF temp101.
    temp102-n = 'text'.
    temp102-v = text.
    APPEND temp102 TO temp101.
    temp102-n = 'type'.
    temp102-v = type.
    APPEND temp102 TO temp101.
    temp102-n = 'class'.
    temp102-v = class.
    APPEND temp102 TO temp101.
    _generic(
      name = 'MessageStrip'
     t_prop = temp101 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' } )`.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~_event_display_id.

    result = `onEvent( { 'ID' : '` && val && `', 'METHOD' : 'DISPLAY_ID' } )`.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~list_item.

    result = me.

    DATA temp103 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp103.
    DATA temp104 LIKE LINE OF temp103.
    temp104-n = 'text'.
    temp104-v = text.
    APPEND temp104 TO temp103.
    temp104-n = 'additionalText'.
    temp104-v = additional_text.
    APPEND temp104 TO temp103.
    _generic(
               name   = 'ListItem'
               ns     = 'core'
               t_prop = temp103 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~suggestion_items.

    result = _generic( 'suggestionItems' ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~item.

    result = me.

    DATA temp105 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp105.
    DATA temp106 LIKE LINE OF temp105.
    temp106-n = 'key'.
    temp106-v = key.
    APPEND temp106 TO temp105.
    temp106-n = 'text'.
    temp106-v = text.
    APPEND temp106 TO temp105.
    _generic(
       name = 'Item'
       ns = 'core'
       t_prop = temp105 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~segmented_button_item.

    result = me.

    DATA temp107 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp107.
    DATA temp108 LIKE LINE OF temp107.
    temp108-n = 'icon'.
    temp108-v = icon.
    APPEND temp108 TO temp107.
    temp108-n = 'key'.
    temp108-v = key.
    APPEND temp108 TO temp107.
    temp108-n = 'text'.
    temp108-v = text.
    APPEND temp108 TO temp107.
    _generic(
        name = 'SegmentedButtonItem'
        t_prop = temp107 ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~get_child.

    DATA temp109 LIKE LINE OF t_child.
    DATA temp110 LIKE sy-tabix.
    temp110 = sy-tabix.
    READ TABLE t_child INDEX index INTO temp109.
    sy-tabix = temp110.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    result = temp109.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~get.

    result = m_root->m_last.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~ui_column.

    DATA temp111 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp111.
    DATA temp112 LIKE LINE OF temp111.
    temp112-n = 'width'.
    temp112-v = width.
    APPEND temp112 TO temp111.
    result = _generic(
          name = 'Column'
          ns   = 'ui'
         t_prop = temp111
          ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~ui_columns.

    result = _generic(
          name = 'columns'
          ns   = 'ui'
     ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~ui_extension.

    result = _generic(
          name = 'extension'
          ns   = 'ui'
     ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~ui_table.

    DATA temp113 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp113.
    DATA temp114 LIKE LINE OF temp113.
    temp114-n = 'rows'.
    temp114-v = rows.
    APPEND temp114 TO temp113.
    temp114-n = 'selectionMode'.
    temp114-v = selectionMode.
    APPEND temp114 TO temp113.
    temp114-n = 'visibleRowCount'.
    temp114-v = visibleRowCount.
    APPEND temp114 TO temp113.
    temp114-n = 'selectedIndex'.
    temp114-v = selectedIndex.
    APPEND temp114 TO temp113.
    result = _generic(
          name = 'Table'
          ns   = 'ui'
          t_prop = temp113
          ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~ui_template.

    result = _generic(
          name = 'template'
          ns   = 'ui'
     ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~flex_box.


    DATA temp115 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp115.
    DATA temp116 LIKE LINE OF temp115.
    temp116-n = 'class'.
    temp116-v = class.
    APPEND temp116 TO temp115.
    temp116-n = 'renderType'.
    temp116-v = render_type.
    APPEND temp116 TO temp115.
    result = _generic(
          name = 'FlexBox'
        t_prop = temp115
     ).


  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~vertical_layout.

    DATA temp117 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp117.
    DATA temp118 LIKE LINE OF temp117.
    temp118-n = 'class'.
    temp118-v = class.
    APPEND temp118 TO temp117.
    temp118-n = 'width'.
    temp118-v = width.
    APPEND temp118 TO temp117.
    result = _generic(
          name = 'VerticalLayout'
           ns   = 'l'
        t_prop = temp117
          ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~flex_item_data.

    result = me.

    DATA temp119 TYPE z2ui5_if_ui5_library=>ty_t_name_value.
    CLEAR temp119.
    DATA temp120 LIKE LINE OF temp119.
    temp120-n = 'growFactor'.
    temp120-v = grow_Factor.
    APPEND temp120 TO temp119.
    temp120-n = 'baseSize'.
    temp120-v = base_Size.
    APPEND temp120 TO temp119.
    temp120-n = 'backgroundDesign'.
    temp120-v = background_Design.
    APPEND temp120 TO temp119.
    temp120-n = 'styleClass'.
    temp120-v = style_Class.
    APPEND temp120 TO temp119.
    _generic(
          name = 'FlexItemData'
        t_prop = temp119
          ).

  ENDMETHOD.

  METHOD z2ui5_if_ui5_library~layout_data.

    result = _generic(
           name = 'layoutData'
       ).

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

    CREATE OBJECT r_result.

    r_result->ms_error-x_error = error.
    r_result->ms_error-app     ?= app.
    r_result->ms_error-kind    = kind.

  ENDMETHOD.


  METHOD z2ui5_on_init.
    IF ms_error-x_error IS NOT BOUND.
      client->display_view( 'HOME' ).
      ms_home-is_initialized = abap_true.
      ms_home-btn_text = 'check'.
      ms_home-btn_event_id = 'BUTTON_CHECK'.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = 'sap-icon://validate'.
    ELSE.
      client->display_view( 'ERROR' ).
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

                client->display_message_toast( 'App is ready to start!' ).
                ms_home-btn_text = 'edit'.
                ms_home-btn_event_id = 'BUTTON_CHANGE'.
                ms_home-btn_icon = 'sap-icon://edit'.
                ms_home-class_value_state = 'Success'.
                ms_home-class_editable = abap_false.

                DATA lx TYPE REF TO cx_root.
              CATCH cx_root INTO lx.
                ms_home-class_value_state_text = lx->get_text( ).
                ms_home-class_value_state = 'Warning'.
                client->display_message_box(
                    text = ms_home-class_value_state_text
                    type = 'error'
                     ).
            ENDTRY.

          WHEN 'DEMOS'.
            DATA li_app TYPE REF TO z2ui5_if_app.
            CREATE OBJECT li_app TYPE ('Z2UI5_CL_APP_DEMO_00').
            client->nav_to_app( li_app ).

        ENDCASE.

      WHEN 'ERROR'.
        CASE client->get( )-event.

          WHEN 'BUTTON_HOME'.
            DATA temp121 TYPE REF TO z2ui5_lcl_system_app.
            CREATE OBJECT temp121 TYPE z2ui5_lcl_system_app.
            client->nav_to_app( temp121 ).
        ENDCASE.
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    DATA view TYPE REF TO z2ui5_if_ui5_library.
    view = client->factory_view( 'HOME' ).
    DATA page TYPE REF TO z2ui5_if_ui5_library.
    page = view->page( 'ABAP2UI5 - Development of UI5 Apps in pure ABAP' ).
    page->header_content(
        )->link( text = 'SCN' href = 'https://blogs.sap.com/tag/abap2ui5/'
        )->link( text = 'Twitter' href = 'https://twitter.com/OblomovDev'
        )->link( text = 'GitHub' href = 'https://github.com/oblomov-dev/abap2ui5' ).

    DATA grid TYPE REF TO z2ui5_if_ui5_library.
    grid = page->grid( 'L12 M12 S12' )->content( 'l' ).
    DATA form TYPE REF TO z2ui5_if_ui5_library.
    form = grid->simple_form( 'Quick Start' )->content( 'f' ).

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

    DATA lv_link TYPE string.
    lv_link = client->get( )-s_request-url_app_gen && ms_home-classname.
    form->link( text = 'Link to the Application'
            href = lv_link
             enabled = boolc( ms_home-class_editable = abap_false )
        ).
    TRY.
        DATA li_app TYPE REF TO z2ui5_if_app.
        CREATE OBJECT li_app TYPE ('Z2UI5_CL_APP_DEMO_00').
        client->nav_to_app( li_app ).
        DATA lv_check_demo_active LIKE abap_true.
        lv_check_demo_active = abap_true.
        DATA lv_text TYPE string.
        lv_text = `Press to continue..`.
      CATCH cx_root.
        lv_check_demo_active = abap_false.
        lv_text = `Press to continue..(release too low, only available from abap v750)`.
    ENDTRY.
    grid = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).
    grid->simple_form( 'Applications and Examples' )->content( 'f'
      )->button( text = lv_text press = view->_event( 'DEMOS' ) enabled = lv_check_demo_active ).

    IF ms_error-x_error IS BOUND.
      view = client->factory_view( 'ERROR' ).
      view->message_page(
          text = ms_error-classname
          description = ms_error-x_error->get_text( )
        )->buttons(
        )->button( text = 'HOME' press = view->_event( 'BUTTON_HOME' )
        )->button(
              text = 'BACK'
              press = view->_event_display_id( client->get( )-id_prev_app )
              type = 'Emphasized' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_db DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_S_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        app               TYPE string,
        screen            TYPE string,
        check_no_rerender TYPE abap_bool,
        screen_popup      TYPE string,
        t_attri           TYPE _=>ty-t-attri,
        o_app             TYPE REF TO object,
      END OF ty_S_db.

    CLASS-METHODS db_save
      IMPORTING
        id       TYPE string
        response TYPE string OPTIONAL
        db       TYPE ty_s_db.

    CLASS-METHODS db_load
      IMPORTING
        id              TYPE string
      RETURNING
        VALUE(r_result) TYPE ty_S_db.

ENDCLASS.

CLASS z2ui5_lcl_db IMPLEMENTATION.

  METHOD db_load.

    DATA lv_data TYPE z2ui5_t_draft-data.
    SELECT SINGLE data
      FROM z2ui5_t_draft
      INTO lv_data
     WHERE uuid = id.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    _=>trans_xml_2_object(
      EXPORTING
        xml    = lv_data
       IMPORTING
        data   = r_result
    ).

  ENDMETHOD.

  METHOD db_save.

    DATA ls_db TYPE z2ui5_t_draft.

    CLEAR ls_db.
    ls_db-uuid = id.
    ls_db-uname = _=>get_user_tech( ).
    ls_db-timestampl = _=>get_timestampl( ).
    ls_db-response = response.
    DATA temp19 LIKE REF TO db.
    GET REFERENCE OF db INTO temp19.
ls_db-data = _=>trans_object_2_xml( temp19 ).

    MODIFY z2ui5_t_draft FROM ls_db.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.

    COMMIT WORK AND WAIT.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_if_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_server TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS constructor
      IMPORTING
        i_server TYPE REF TO z2ui5_lcl_system_runtime.

ENDCLASS.


CLASS z2ui5_lcl_system_runtime DEFINITION.

  PUBLIC SECTION.

    CLASS-DATA:
      BEGIN OF client,
        o_body   TYPE REF TO z2ui5_lcl_utility_tree_json,
        t_header TYPE z2ui5_cl_http_handler=>ty_t_name_value,
        t_param  TYPE z2ui5_cl_http_handler=>ty_t_name_value,
      END OF client.

    TYPES:
      BEGIN OF s_screen,
        name          TYPE string,
        check_binding TYPE abap_bool,
        o_parser      TYPE REF TO z2ui5_lcl_if_ui5_library,
      END OF s_screen.

    DATA:
      BEGIN OF ms_control,
        event_type TYPE string,
      END OF ms_control.

    DATA ms_db TYPE z2ui5_lcl_db=>ty_S_Db.

  "  types

    DATA mt_after TYPE _=>ty_tt_string.
    DATA mt_screen TYPE STANDARD TABLE OF s_screen.
    DATA ms_leave_to_app LIKE ms_db.

    METHODS constructor.

    METHODS execute_init
      RETURNING
        VALUE(result) TYPE string.

    METHODS execute_finish
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS init_app_prev.

    METHODS init_app_new.

    METHODS factory_new_error
      IMPORTING
        kind            TYPE string
        ix              TYPE REF TO cx_root
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

    METHODS factory_new
      IMPORTING
        i_app           TYPE REF TO z2ui5_if_app
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_lcl_system_runtime.

  PRIVATE SECTION.

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

    TRY.
        " ms_db-id_prev = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'ID')->get_val( ).
        ms_db-id_prev = client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'ID' )->get_val( ).
      CATCH cx_root.
        init_app_new( ).
        RETURN.
    ENDTRY.

    DATA li_app TYPE REF TO z2ui5_if_app.

    TRY.
        "  DATA(lv_method_event) = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'METHOD' )->get_val( ).
        DATA lv_method_event TYPE string.
        lv_method_event = client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'METHOD' )->get_val( ).
        IF lv_method_event = 'DISPLAY_ID'.
          " DATA ls_db TYPE z2ui5_t_draft.
          DATA lv_uuid TYPE string.
          lv_uuid = client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'ID' )->get_val( ).
          DATA ls_db TYPE z2ui5_t_draft.
          SELECT SINGLE * FROM z2ui5_t_draft
          INTO ls_db
             WHERE uuid = lv_uuid.
          IF sy-subrc = 0.
            IF ls_db-response IS NOT INITIAL.
              result = ls_db-response.
              RETURN.
            ENDIF.

            _=>trans_xml_2_object(
                EXPORTING
                    xml    = ls_db-data
                IMPORTING
                    data   = ms_db
                ).

            ROLLBACK WORK.
            ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_rendering.
            li_app ?= ms_db-o_app.

            DATA temp122 TYPE REF TO z2ui5_lcl_if_client.
            CREATE OBJECT temp122 TYPE z2ui5_lcl_if_client EXPORTING I_SERVER = me.
            li_app->controller( temp122 ).
            ROLLBACK WORK.

            result = execute_finish( ).
            RETURN.
          ENDIF.
        ENDIF.
      CATCH cx_root.
    ENDTRY.

    init_app_prev( ).

  ENDMETHOD.


  METHOD execute_finish.
    " DATA(x) = COND i( WHEN lines( mt_screen ) = 0 THEN THROW _( 'no view defined in method set_view' ) ).
    IF lines( mt_screen ) = 0.
      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_SY_SUBRC'.
    ENDIF.
    IF ms_db-screen IS INITIAL.
      DATA lr_screen TYPE REF TO s_screen.
      FIELD-SYMBOLS <temp123> TYPE s_screen.
      READ TABLE mt_screen INDEX 1 ASSIGNING <temp123>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
GET REFERENCE OF <temp123> INTO lr_screen.
      ms_db-screen = lr_screen->name.
    ELSE.
      FIELD-SYMBOLS <temp124> TYPE s_screen.
      READ TABLE mt_screen WITH KEY name = ms_db-screen ASSIGNING <temp124>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
GET REFERENCE OF <temp124> INTO lr_screen.
    ENDIF.

    DATA lo_ui5_model TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_ui5_model = z2ui5_lcl_utility_tree_json=>factory( ).

    DATA ls_view TYPE z2ui5_lcl_if_ui5_library=>ty_s_view.
    ls_view = lr_screen->o_parser->get_view( ).
    ms_db-t_attri = ls_view-t_attri.
    lo_ui5_model->add_attribute( n = `vView` v = ls_view-xml ).
    ls_view-o_model->mv_name = 'oViewModel'.
    lo_ui5_model->add_attribute_instance( ls_view-o_model ).

    DATA lo_system TYPE REF TO z2ui5_lcl_utility_tree_json.
    lo_system = lo_ui5_model->add_attribute_object( 'oSystem' ).
    lo_system->add_attribute( n = 'ID' v = ms_db-id ).
    " lo_system->add_attribute( n = 'ID_PREV' v = ms_db-id_prev ).
    " lo_system->add_attribute( n = 'ID_PREV_APP' v = ms_db-id_prev_app ).
    "    lo_ui5_model->add_attribute( n = 'CHECK_POPUP_ACTIVE' v = ''  apos_active = abap_false ).
    lo_system->add_attribute( n = 'CHECK_DEBUG_ACTIVE' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-check_debug_mode )  apos_active = abap_false ).


    IF mt_after IS NOT INITIAL.
      DATA lo_list TYPE REF TO z2ui5_lcl_utility_tree_json.
      lo_list = lo_ui5_model->add_attribute_list( 'oAfter' ).
      data lr_after type ref to string_table.
      LOOP AT mt_after REFERENCE INTO lr_after.
        DATA lo_list2 TYPE REF TO z2ui5_lcl_utility_tree_json.
        CLEAR lo_list2.
        lo_list2 = lo_list->add_list_list( ).
        DATA lr_con TYPE REF TO string.
        LOOP AT lr_after->* REFERENCE INTO lr_con.
          lo_list2->add_list_val( lr_con->* ).
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    r_result = lo_ui5_model->get_root( )->write_result( ).

  ENDMETHOD.


  METHOD init_app_prev.

    " ms_db = CORRESPONDING #( BASE ( ms_db ) db_load( ms_db-id_prev ) EXCEPT id id_prev ).
    " MOVE-CORRESPONDING  db_load( ms_db-id_prev ) TO ms_db.
    " CLEAR: ms_db-id, ms_db-id_prev.
    DATA ls_db_tmp LIKE ms_db.
    ls_db_tmp = ms_db.
    ms_db = z2ui5_lcl_db=>db_load( ms_db-id_prev ).
    ms_db-id = ls_db_tmp-id.
    ms_db-id_prev = ls_db_tmp-id_prev.

    DATA lr_attri TYPE REF TO z2ui5_lcl_utility=>ty_attri.
    LOOP AT ms_db-t_attri REFERENCE INTO lr_attri
        WHERE bind_type = z2ui5_if_ui5_library=>cs-bind_type-two_way.

      " lr_attri->bind_type = ''.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA lv_name TYPE string.
      lv_name = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
      ASSIGN (lv_name) TO <attribute>.

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_lcl_utility
          EXPORTING
            val = 'CX_SY_SUBRC'.
      ENDIF.

      CASE lr_attri->kind.

        WHEN 'g' OR 'I' OR 'C'.
          DATA lv_value TYPE string.
          lv_value = client-o_body->get_attribute( lr_attri->name )->get_val( ).
          <attribute> = lv_value.

        WHEN 'h'.
          _=>trans_ref_tab_2_tab(
                     EXPORTING
                       ir_tab_from = client-o_body->get_attribute( lr_attri->name )->mr_actual
                     CHANGING
                       ct_to   = <attribute> ).

      ENDCASE.

    ENDLOOP.

    ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_event.
  ENDMETHOD.


  METHOD init_app_new.
    DO.
      TRY.

          DATA temp125 TYPE z2ui5_cl_http_handler=>ty_t_name_value.
          CLEAR temp125.
          DATA tab TYPE z2ui5_cl_http_handler=>ty_t_name_value.
          tab = client-t_param.
          DATA row LIKE LINE OF tab.
          LOOP AT tab INTO row.
            DATA temp126 LIKE LINE OF temp125.
            temp126-name = to_upper( row-name ).
            temp126-value = to_upper( row-value ).
            APPEND temp126 TO temp125.
          ENDLOOP.
          client-t_param = temp125.

          TRY.
              DATA temp127 LIKE LINE OF client-t_param.
              DATA temp128 LIKE sy-tabix.
              temp128 = sy-tabix.
              READ TABLE client-t_param WITH KEY name = 'APP' INTO temp127.
              sy-tabix = temp128.
              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
              ENDIF.
              ms_db-app = temp127-value.
            CATCH cx_root.
              CREATE OBJECT ms_db-o_app TYPE z2ui5_lcl_system_app.
              EXIT.
          ENDTRY.

          CREATE OBJECT ms_db-o_app TYPE (ms_db-app).
          EXIT.

        CATCH cx_root.
          DATA lo_error TYPE REF TO z2ui5_lcl_system_app.
          CREATE OBJECT lo_error TYPE z2ui5_lcl_system_app.
          DATA lo_error2 TYPE REF TO z2ui5_lcl_utility.
          CREATE OBJECT lo_error2 TYPE z2ui5_lcl_utility EXPORTING VAL = `Class with name ` && ms_db-app && ` not found. Please check your repository.`.
          lo_error->ms_error-x_error = lo_error2.
          ms_db-o_app ?= lo_error.
          EXIT.
      ENDTRY.
    ENDDO.

    ms_db-app     = _=>get_classname_by_ref( ms_db-o_app ).
    ms_db-t_attri = _=>get_t_attri_by_ref( ms_db-o_app ).

    ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_init.

  ENDMETHOD.

  METHOD factory_new.

    CREATE OBJECT r_result.
    r_result->ms_db-o_app = i_app.
    r_result->ms_db-app = _=>get_classname_by_ref( i_app ).

    CLEAR client-o_body.
    r_result->mt_after = mt_after.
    r_result->ms_db-t_attri = _=>get_t_attri_by_ref( r_result->ms_db-o_app ).

  ENDMETHOD.

  METHOD factory_new_error.

    r_result = factory_new(
             z2ui5_lcl_system_app=>factory_error(
                error = ix app = ms_db-o_app
                kind = kind ) ).

    r_result->ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_init.
  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_if_client IMPLEMENTATION.

  METHOD constructor.

    mo_server = i_server.

  ENDMETHOD.


  METHOD z2ui5_if_client~display_message_toast.

    DATA temp129 TYPE string_table.
    CLEAR temp129.
    APPEND `MessageToast` TO temp129.
    APPEND `show` TO temp129.
    APPEND text TO temp129.
    INSERT temp129
         INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~display_message_box.

    DATA temp133 TYPE string_table.
    CLEAR temp133.
    APPEND `MessageBox` TO temp133.
    APPEND type TO temp133.
    APPEND text TO temp133.
    INSERT temp133
      INTO TABLE mo_server->mt_after.

  ENDMETHOD.

  METHOD z2ui5_if_client~display_view.

    mo_server->ms_db-screen = val.
    mo_server->ms_db-check_no_rerender = check_no_rerender.

  ENDMETHOD.

  METHOD z2ui5_if_client~factory_view.

    result = z2ui5_lcl_if_ui5_library=>factory(
        t_attri = mo_server->ms_db-t_attri
        o_app   = mo_server->ms_db-o_app
         ).

    DATA lo_parser TYPE REF TO z2ui5_lcl_if_ui5_library.
    lo_parser ?= result.
    DATA temp137 TYPE z2ui5_lcl_system_runtime=>s_screen.
    CLEAR temp137.
    temp137-name = name.
    temp137-o_parser = lo_parser.
    INSERT temp137 INTO TABLE mo_server->mt_screen.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_to_home.

    DATA temp138 TYPE REF TO z2ui5_lcl_system_app.
    CREATE OBJECT temp138 TYPE z2ui5_lcl_system_app.
    z2ui5_if_client~nav_to_app( temp138 ).

  ENDMETHOD.

  METHOD z2ui5_if_client~get.

    CLEAR result.
    result-lifecycle_method = mo_server->ms_control-event_type.
    result-check_previous_app = boolc( mo_server->ms_db-id_prev_app IS NOT INITIAL ).
    result-view_active = mo_server->ms_db-screen.
    result-id = mo_server->ms_db-id.
    result-id_prev = mo_server->ms_db-id_prev.
    result-id_prev_app = mo_server->ms_db-id_prev_app.
    DATA lt_head LIKE z2ui5_lcl_system_runtime=>client-t_header.
    lt_head = z2ui5_lcl_system_runtime=>client-t_header.
    DATA lv_url TYPE z2ui5_cl_http_handler=>ty_s_name_value-value.
    DATA temp1 LIKE LINE OF lt_head.
    DATA temp2 LIKE sy-tabix.
    temp2 = sy-tabix.
    READ TABLE lt_head WITH KEY name = 'referer' INTO temp1.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    lv_url = temp1-value.

    result-s_request-tenant = sy-mandt.
    result-s_request-url_app = lv_url && '?sap-client=' && result-s_request-tenant && '&app=' && mo_server->ms_db-app.
    result-s_request-url_app_gen = lv_url && '?sap-client=' && result-s_request-tenant && '&app='.
    DATA temp3 LIKE LINE OF lt_head.
    DATA temp4 LIKE sy-tabix.
    temp4 = sy-tabix.
    READ TABLE lt_head WITH KEY name = 'origin' INTO temp3.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
    result-s_request-origin = temp3-value.
    result-s_request-url_source_code = result-s_request-origin && `/sap/bc/adt/oo/classes/` && mo_server->ms_db-app && `/source/main`.

    TRY.
        "  result-event = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'EVENT' )->get_val( ).
        result-event = z2ui5_lcl_system_runtime=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'EVENT' )->get_val( ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app_previous.

    " DATA(x) = COND i( WHEN mo_server->ms_db-id_prev_app IS INITIAL THEN THROW _('CX_STACK_EMPTY - NO CALLING APP FOUND') ).

    IF mo_server->ms_db-id_prev_app IS INITIAL.

      RAISE EXCEPTION TYPE z2ui5_lcl_utility
        EXPORTING
          val = 'CX_STACK_EMPTY - NO CALLING APP FOUND'.

    ENDIF.

    result ?= z2ui5_lcl_db=>db_load( mo_server->ms_db-id_prev_app )-o_app.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_to_app.

    CLEAR mo_server->ms_leave_to_app.
    mo_server->ms_leave_to_app-o_app = app.

  ENDMETHOD.

  METHOD z2ui5_if_client~display_popup.

    "coming soon
    "mo_server->ms_db-screen_popup = name.



  ENDMETHOD.

ENDCLASS.
