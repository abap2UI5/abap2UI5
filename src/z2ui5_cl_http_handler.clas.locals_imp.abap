CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
        gen_type_kind  TYPE string,
        gen_type       TYPE string,
        gen_kind       TYPE string,
      END OF ty_attri.
    TYPES ty_T_attri TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        s_msg  TYPE LINE OF bapirettab,
      END OF ms_error.

    METHODS constructor
      IMPORTING
        val      TYPE any OPTIONAL
        previous TYPE REF TO cx_root OPTIONAL
          PREFERRED PARAMETER val.

    METHODS get_text REDEFINITION.

    CLASS-METHODS raise
      IMPORTING
        v    TYPE clike     DEFAULT `CX_SY_SUBRC`
        when TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER v.

    CLASS-METHODS get_header_val
      IMPORTING
        v             TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_s_name_value-value.

    CLASS-METHODS get_param_val
      IMPORTING
        v             TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_s_name_value-value.

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
        io_app        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE ty_t_attri ##NEEDED.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string.

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


  METHOD get_uuid_session.

    mv_counter = mv_counter + 1.
    result = get_trim_upper( mv_counter ).

  ENDMETHOD.


  METHOD get_header_val.

    result  = z2ui5_cl_http_handler=>client-t_header[ name = v ]-value.

  ENDMETHOD.


  METHOD get_param_val.

    DATA(lt_param) = VALUE z2ui5_if_client=>ty_t_name_value( LET tab = z2ui5_cl_http_handler=>client-t_param IN FOR row IN tab
                                 ( name = to_upper( row-name ) value = to_upper( row-value ) ) ).
    TRY.
        result = lt_param[ name = get_trim_upper( v ) ]-value.
      CATCH cx_root.
    ENDTRY.

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

    DATA lr_row TYPE REF TO data.
    CREATE DATA lr_row LIKE LINE OF t_result.
    ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

    DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <row> ).
    DATA(lo_struc) = CAST cl_abap_structdescr( lo_descr ).
    DATA(lt_components) = lo_struc->get_components( ).

    LOOP AT <lt_from> INTO DATA(lr_from).

      CLEAR <row>.

      ASSIGN lr_from->* TO FIELD-SYMBOL(<row_ui5>).
      raise( when = xsdbool( sy-subrc <> 0 ) ).

      LOOP AT lt_components INTO DATA(ls_comp).

        FIELD-SYMBOLS <comp> TYPE data.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row> TO <comp>.
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

      INSERT <row> INTO TABLE t_result.
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


CLASS z2ui5_lcl_utility_tree_json DEFINITION.

  PUBLIC SECTION.

    DATA mo_root TYPE REF TO z2ui5_lcl_utility_tree_json.
    DATA mo_parent TYPE REF TO z2ui5_lcl_utility_tree_json.
    DATA mv_name   TYPE string.
    DATA mv_value  TYPE string.
    DATA mt_values TYPE STANDARD TABLE OF REF TO z2ui5_lcl_utility_tree_json WITH EMPTY KEY.
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

    METHODS add_attribute_object
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_utility_tree_json.

    METHODS add_attribute_struc
      IMPORTING
        val           TYPE data
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

    METHODS stringify
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

    DATA(lo_attri) = new( io_root = mo_root iv_name = n ).

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


  METHOD add_attribute_struc.

    FIELD-SYMBOLS <value> TYPE any.
    DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( val ) ).
    DATA(lt_comp) = lo_struc->get_components( ).

    LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE val TO <value>.
      add_attribute( n = lr_comp->name v = <value> ).
    ENDLOOP.

    result = me.

  ENDMETHOD.

  METHOD add_attribute_object.

    DATA(lo_attri) = new( io_root = mo_root iv_name = name ).
    mt_values = VALUE #( BASE mt_values ( lo_attri ) ).
    lo_attri->mo_parent = me.
    result = lo_attri.

  ENDMETHOD.


  METHOD add_list_list.

    result = add_attribute_list( CONV string( lines( mt_values ) ) ).

  ENDMETHOD.


  METHOD add_list_object.

    result = add_attribute_object( CONV string( lines( mt_values ) ) ).

  ENDMETHOD.


  METHOD add_list_val.

    DATA(lo_attri) = new( io_root = mo_root iv_name = lines( mt_values ) ).
    lo_attri->mv_value = v.
    lo_attri->mv_apost_active = abap_true.

    mt_values = VALUE #( BASE mt_values ( lo_attri ) ).
    lo_attri->mo_parent = me.
    result = lo_attri.
    result = me.

  ENDMETHOD.


  METHOD constructor.

    mo_root = me.

  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).
    result->mo_root = result.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( iv_json )
            assoc_arrays = abap_true
        CHANGING
         data            = result->mr_actual
        ).

  ENDMETHOD.

  METHOD new.

    result = NEW #( ).
    result->mo_root = io_root.
    result->mv_name = CONV string( iv_name ).

  ENDMETHOD.

  METHOD get_attribute.

    CONSTANTS c_prefix TYPE string VALUE `MR_ACTUAL->`.

    z2ui5_lcl_utility=>raise( when = xsdbool( mr_actual IS INITIAL ) ).

    DATA(lo_attri) = new( io_root = mo_root iv_name = name ).

    FIELD-SYMBOLS <attribute> TYPE any.
    DATA(lv_name) = c_prefix && replace( val = name sub = `-` with = `_` occ = 0 ).
    ASSIGN (lv_name) TO <attribute>.
    z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

    lo_attri->mr_actual = <attribute>.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    result = lo_attri.

  ENDMETHOD.

  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) v = `Value of Attribute in JSON not found` ).

    result = <attribute>.

  ENDMETHOD.


  METHOD get_root.

    result = mo_root.

  ENDMETHOD.


  METHOD wrap_json.

    result = SWITCH #( mv_check_list WHEN abap_true  THEN |[ { iv_text }]| ELSE `{` && iv_text && `}` ).

  ENDMETHOD.

  METHOD quote_json.

    result = SWITCH #( iv_cond WHEN abap_true THEN `"` && iv_text && `"` ELSE iv_text ).

  ENDMETHOD.

  METHOD stringify.

    LOOP AT mt_values INTO DATA(lo_attri).

      IF sy-tabix > 1.
        result = result && |,|.
      ENDIF.

      IF mv_check_list = abap_false.
        result = |{ result }"{ lo_attri->mv_name }":|.
      ENDIF.


      IF lo_attri->mt_values IS NOT INITIAL.
        result = result && lo_attri->stringify( ).
      ELSE.
        result = result &&
           quote_json( iv_cond = xsdbool( lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL )
                       iv_text = lo_attri->mv_value ).
      ENDIF.

    ENDLOOP.

    result = wrap_json( result ).
  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_handler DEFINITION DEFERRED.

CLASS z2ui5_lcl_fw_handler DEFINITION.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cs_bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF cs_bind_type.

    TYPES:
      BEGIN OF ty_s_db,
        id                TYPE string,
        id_prev           TYPE string,
        id_prev_app       TYPE string,
        id_prev_app_stack TYPE string,

        t_attri           TYPE z2ui5_lcl_utility=>ty_t_attri,
        o_app             TYPE REF TO z2ui5_if_app,
      END OF ty_s_db.
    DATA ms_db TYPE ty_s_db.

    TYPES:
      BEGIN OF ty_s_next,
        check_app_leave TYPE abap_bool,
        o_call_app      TYPE REF TO z2ui5_if_app,
        s_set           TYPE z2ui5_if_client=>ty_S_next,
        BEGIN OF s_msg,
          control TYPE string,
          type    TYPE string,
          text    TYPE string,
        END OF s_msg,
      END OF ty_s_next.

    DATA ms_actual TYPE z2ui5_if_client=>ty_s_get.
    DATA ms_next   TYPE ty_s_next.

    CLASS-DATA mo_body TYPE REF TO z2ui5_lcl_utility_tree_json.

    CLASS-METHODS request_begin
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS request_end
      RETURNING
        VALUE(result) TYPE string.

    METHODS _create_binding
      IMPORTING
        value          TYPE data
        type           TYPE string DEFAULT cs_bind_type-two_way
        check_gen_data TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result)  TYPE string.

    CLASS-METHODS set_app_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    CLASS-METHODS set_app_client
      IMPORTING
        id_prev       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_leave
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_call
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS set_app_system
      IMPORTING
        VALUE(ix)     TYPE REF TO cx_root OPTIONAL
        error_text    TYPE string OPTIONAL
          PREFERRED PARAMETER ix
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS request_end_model
      RETURNING
        VALUE(r_view_model) TYPE REF TO z2ui5_lcl_utility_tree_json.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_lcl_fw_db DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        id TYPE string
        db TYPE z2ui5_lcl_fw_handler=>ty_s_db.

    CLASS-METHODS load_app
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_lcl_fw_handler=>ty_s_db.

    CLASS-METHODS read
      IMPORTING
        id             TYPE clike
        check_load_app TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE z2ui5_t_draft.

    CLASS-METHODS cleanup.

ENDCLASS.

CLASS z2ui5_lcl_fw_app DEFINITION.

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
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_app.

    DATA mv_is_initialized TYPE abap_bool.
    DATA mv_view_name TYPE string.

    METHODS z2ui5_on_init.

    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_rendering
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

ENDCLASS.

CLASS z2ui5_lcl_fw_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF mv_is_initialized = abap_false.
      mv_is_initialized = abap_true.
      z2ui5_on_init(  ).
    ENDIF.

    z2ui5_on_event( client ).
    z2ui5_on_rendering( client ).

  ENDMETHOD.

  METHOD factory_error.

    result = NEW #( ).
    result->ms_error-x_error = error.
    result->ms_error-app     = CAST #( app ).

  ENDMETHOD.


  METHOD z2ui5_on_init.
    IF ms_error-x_error IS NOT BOUND.
      mv_view_name = 'HOME'.
      ms_home-is_initialized = abap_true.
      ms_home-btn_text = `check`.
      ms_home-btn_event_id = `BUTTON_CHECK`.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon = `sap-icon://validate`.
    ELSE.
      mv_view_name = 'ERROR'.
    ENDIF.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE mv_view_name.

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
                ms_home-classname = z2ui5_lcl_utility=>get_trim_upper( ms_home-classname ).
                CREATE OBJECT li_app_test TYPE (ms_home-classname).

                client->popup_message_toast( `App is ready to start!` ).
                ms_home-btn_text = `edit`.
                ms_home-btn_event_id = `BUTTON_CHANGE`.
                ms_home-btn_icon = `sap-icon://edit`.
                ms_home-class_value_state = `Success`.
                ms_home-class_editable = abap_false.

              CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
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
            client->nav_app_leave( client->get_app( client->get( )-id_prev_app ) ).

        ENDCASE.
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_rendering.

    IF ms_error-x_error IS BOUND.

      ms_error-x_error->get_source_position(
        IMPORTING
          program_name = DATA(lv_prog)
          include_name = DATA(lv_incl)
          source_line  = DATA(lv_line)
      ).

      DATA(lv_descr) = ms_error-x_error->get_text( ) &&
            ` -------------------------------------------------------------------------------------------- Source Code Position: ` &&
            lv_prog && ` / ` && lv_incl && ` / ` && lv_line && ` `.

      DATA(lv_xml_error) = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mv` &&
  `c" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <MessagePage ` && |\n|
  &&
                           `  description="` &&  lv_descr && `" ` && |\n|  &&
                           `  icon="sap-icon://message-error" ` && |\n|  &&
                           `  text="500 Internal Server Error" ` && |\n|  &&
                           `  enableFormattedText="true" ` && |\n|  &&
                           ` > <buttons ` && |\n|  &&
                           ` > <Button ` && |\n|  &&
                           `  press="` &&  client->_event( `BUTTON_HOME` ) && `" ` && |\n|  &&
                           `  text="HOME" ` && |\n|  &&
                           ` /> <Button ` && |\n|  &&
                           `  press="` &&  client->_event( `BUTTON_BACK` ) && `" ` && |\n|  &&
                           `  text="BACK" ` && |\n|  &&
                           `  type="Emphasized" ` && |\n|  &&
                           ` /></buttons></MessagePage></Shell></mvc:View>`.

      client->set_next( VALUE #( xml_main = lv_xml_error ) ).
      RETURN.
    ENDIF.

    DATA(lv_url) = z2ui5_cl_http_handler=>client-t_header[ name = `referer` ]-value.
    SPLIT lv_url AT '?' INTO lv_url DATA(lv_dummy).

    DATA(lv_link) = lv_url && `?sap-client=` &&  sy-mandt && `&app=` && ms_home-classname.

    DATA(lv_xml_main) = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mvc` &&
`" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n|  &&
                        `  showNavButton="false" ` && |\n|  &&
                        `  class="sapUiContentPadding sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" ` && |\n|  &&
                        ` > <headerContent ` && |\n|  &&
                        ` > <Title ` && |\n|  &&
                        ` /> <Title ` && |\n|  &&
                        `  text="abap2UI5 - Development of UI5 Apps in pure ABAP" ` && |\n|  &&
                        ` /> <ToolbarSpacer ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="SCN" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://blogs.sap.com/tag/abap2ui5/" ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="Twitter" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://twitter.com/OblomovDev" ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="GitHub" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://github.com/oblomov-dev/abap2ui5" ` && |\n|  &&
                        ` /></headerContent> <l:Grid ` && |\n|  &&
                        `  defaultSpan="XL7 L7 M12 S12" ` && |\n|  &&
                        ` > <l:content ` && |\n|  &&
                        ` > <f:SimpleForm ` && |\n|  &&
                        `  title="Quick Start" ` && |\n|  &&
                        `  layout="ResponsiveGridLayout" ` && |\n|  &&
                        `  editable="true" ` && |\n|  &&
                        ` > <f:content ` && |\n|  &&
                        ` > <Label ` && |\n|  &&
                        `  text="Step 1" ` && |\n|  &&
                        ` /> <Text ` && |\n|  &&
                        `  text="Create a global class in your abap system" ` && |\n|  &&
                        ` /> <Label ` && |\n|  &&
                        `  text="Step 2" ` && |\n|  &&
                        ` /> <Text ` && |\n|  &&
                        `  text="Add the interface: Z2UI5_IF_APP" ` && |\n|  &&
                        ` /> <Label ` && |\n|  &&
                        `  text="Step 3" ` && |\n|  &&
                        ` /> <Text ` && |\n|  &&
                        `  text="Define view, implement behaviour" ` && |\n|  &&
                        ` /> <Link ` && |\n|  &&
                        `  text="(Example)" ` && |\n|  &&
                        `  target="_blank" ` && |\n|  &&
                        `  href="https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/00/z2ui5_cl_app_demo_01.clas.abap" ` && |\n|  &&
                        ` /> <Label ` && |\n|  &&
                        `  text="Step 4" ` && |\n|  &&
                        ` /> `.

    IF ms_home-class_editable = abap_true.
      lv_xml_main = lv_xml_main &&   `<Input ` && |\n|  &&
     `  placeholder="` && `fill in the class name and press 'check' ` && `" ` && |\n|  &&
     `  editable="` && z2ui5_lcl_utility=>get_json_boolean( ms_home-class_editable ) && `" ` && |\n|  &&
     `  value="` && client->_bind( ms_home-classname ) && `" ` && |\n|  &&
     ` /> `.
    ELSE.
      lv_xml_main = lv_xml_main &&   `<Text ` && |\n|  &&
      `  text=" ` && ms_home-classname && `" /> `.

    ENDIF.

    lv_xml_main = lv_xml_main &&  `<Button ` && |\n|  &&
       `  press="`  && client->_event( ms_home-btn_event_id ) && `" ` && |\n|  &&
       `  text="` && ms_home-btn_text && `" ` && |\n|  &&
       `  icon="` &&  ms_home-btn_icon && `" ` && |\n|  &&
       ` /> <Label ` && |\n|  &&
       `  text="Step 5" ` && |\n|  &&
       ` /> <Link ` && |\n|  &&
       `  text="Link to the Application" ` && |\n|  &&
       `  target="_blank" ` && |\n|  &&
       `  href="` && escape( val = lv_link format = cl_abap_format=>e_xml_attr ) && `" ` && |\n|  &&
       `  enabled="` && z2ui5_lcl_utility=>get_json_boolean( xsdbool( ms_home-class_editable = abap_false ) ) && `" ` && |\n|  &&
       ` /></f:content></f:SimpleForm> <f:SimpleForm ` && |\n|  &&
       `  title="Demo Section" ` && |\n|  &&
       `  layout="ResponsiveGridLayout" ` && |\n|  &&
       ` > <f:content ` && |\n|  &&
       ` > <Button ` && |\n|  &&
       `  press="` && client->_event( `DEMOS` ) && `" ` && |\n|  &&
       `  text="Continue..." ` && |\n|  &&
       ` /></f:content></f:SimpleForm></l:content></l:Grid></Page></Shell></mvc:View>`.

    client->set_next( VALUE #( xml_main = lv_xml_main ) ).

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_db IMPLEMENTATION.

  METHOD load_app.

    DATA(ls_db) = read( id ).

    z2ui5_lcl_utility=>trans_xml_2_object(
      EXPORTING
        xml    = ls_db-data
      IMPORTING
        data   = result ).

  ENDMETHOD.

  METHOD create.

    DATA(lo_app) = CAST object( db-o_app ) ##NEEDED.

    LOOP AT db-t_attri REFERENCE INTO DATA(lr_attri) WHERE gen_type IS NOT INITIAL.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = 'LO_APP->' && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      CLEAR <attribute>.

    ENDLOOP.

    DATA(ls_db) = VALUE z2ui5_t_draft(
        uuid       = id
        uuid_prev     = db-id_prev
        uuid_prev_app = db-id_prev_app
        uuid_prev_app_stack = db-id_prev_app_stack
        uname      = z2ui5_lcl_utility=>get_user_tech( )
        timestampl = z2ui5_lcl_utility=>get_timestampl( )
        data       = z2ui5_lcl_utility=>trans_object_2_xml( REF #( db ) ) ).

    MODIFY z2ui5_t_draft FROM @ls_db.
    z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD read.

    IF check_load_app = abap_true.

      SELECT SINGLE *
        FROM z2ui5_t_draft
        WHERE uuid = @id
      INTO @result.
      z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

    ELSE.

      SELECT SINGLE uuid, uuid_prev, uuid_prev_app, uuid_prev_app_stack
        FROM z2ui5_t_draft
        WHERE uuid = @id
      INTO CORRESPONDING FIELDS OF @result.
      z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

    ENDIF.

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

CLASS z2ui5_lcl_fw_client DEFINITION.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_client.

    DATA mo_handler TYPE REF TO z2ui5_lcl_fw_handler.

    METHODS constructor
      IMPORTING
        handler TYPE REF TO z2ui5_lcl_fw_handler.

ENDCLASS.

CLASS z2ui5_lcl_fw_handler IMPLEMENTATION.

  METHOD request_begin.

    mo_body = z2ui5_lcl_utility_tree_json=>factory( z2ui5_cl_http_handler=>client-body ).

    TRY.
        DATA(lv_id_prev) = mo_body->get_attribute( `OSYSTEM` )->get_attribute( `ID` )->get_val( ).
      CATCH cx_root.
        result = set_app_start( ).
        RETURN.
    ENDTRY.

    result = set_app_client( lv_id_prev ).

  ENDMETHOD.


  METHOD request_end.

    DATA(lo_ui5_model) = z2ui5_lcl_utility_tree_json=>factory( ).

    IF ms_next-s_set-check_set_prev_view = abap_false OR ms_next-s_set-xml_popup IS NOT INITIAL.
      lo_ui5_model->add_attribute_instance( request_end_model( ) ).
    ENDIF.

    IF ms_next-s_set-xml_main IS NOT INITIAL AND ms_next-s_set-check_set_prev_view = abap_false.
      lo_ui5_model->add_attribute( n = `vView` v = ms_next-s_set-xml_main ).
    ENDIF.

    IF ms_next-s_set-xml_popup IS NOT INITIAL.
      lo_ui5_model->add_attribute( n = `vViewPopup` v = ms_next-s_set-xml_popup ).
      IF ms_next-s_set-popup_open_by_id IS NOT INITIAL.
        lo_ui5_model->add_attribute( n = `OPENBY` v = ms_next-s_set-popup_open_by_id ).
      ENDIF.
    ENDIF.

    IF ms_next-s_set-check_set_prev_view = abap_false AND ms_next-s_set-xml_popup IS INITIAL AND ms_next-s_set-xml_main IS INITIAL.
      z2ui5_lcl_utility=>raise( `No view or popup found. Check your view rendering!` ).
    ENDIF.

    lo_ui5_model->add_attribute_object( `oSystem` )->add_attribute( n = `ID` v = ms_db-id ).

    IF ms_next-s_msg IS NOT INITIAL.
      lo_ui5_model->add_attribute_object( `oMessage` )->add_attribute_struc( ms_next-s_msg ).
    ENDIF.

    IF ms_next-s_set-t_scroll_pos IS NOT INITIAL.
      DATA(lo_list) = lo_ui5_model->add_attribute_list( `oScroll` ).
      LOOP AT ms_next-s_set-t_scroll_pos REFERENCE INTO DATA(lr_focus).
        lo_list->add_list_object( )->add_attribute_struc( lr_focus->* ).
      ENDLOOP.
    ENDIF.

    IF ms_next-s_set-s_cursor_pos IS NOT INITIAL.
      lo_ui5_model->add_attribute_object( `oCursor` )->add_attribute_struc( ms_next-s_set-s_cursor_pos ).
    ENDIF.

    IF ms_next-s_set-s_timer IS NOT INITIAL.
      lo_ui5_model->add_attribute_object( `oTimer` )->add_attribute_struc( ms_next-s_set-s_timer ).
    ENDIF.

    IF ms_next-s_set-check_set_prev_view = abap_true.
      lo_ui5_model->add_attribute( n = `SET_PREV_VIEW` v = `true` apos_active = abap_false ).
    ENDIF.

    result = lo_ui5_model->get_root( )->stringify( ).
    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

  ENDMETHOD.


  METHOD set_app_client.

    CONSTANTS c_prefix TYPE string VALUE `LO_APP->`.

    result = NEW #( ).
    result->ms_db-id = z2ui5_lcl_utility=>get_uuid( ).
    DATA(lv_id) = result->ms_db-id.
    result->ms_db = z2ui5_lcl_fw_db=>load_app( id_prev ).
    result->ms_db-id = lv_id.
    result->ms_db-id_prev = id_prev.

    DATA(lo_app) = CAST object( result->ms_db-o_app ) ##NEEDED.

    DATA(lo_model) = mo_body->get_attribute( `OUPDATE` ).

    LOOP AT result->ms_db-t_attri REFERENCE INTO DATA(lr_attri)
        WHERE bind_type = cs_bind_type-two_way.

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

      IF lr_attri->gen_kind IS NOT INITIAL.

        CASE lr_attri->gen_kind.
          WHEN cl_abap_datadescr=>kind_elem.
            CREATE DATA <attribute> TYPE (lr_attri->gen_type).
            ASSIGN <attribute>->* TO <attribute>.
          WHEN cl_abap_datadescr=>kind_table.
            DATA lr_data TYPE REF TO data.
            CREATE DATA lr_data TYPE (lr_attri->gen_type).
            ASSIGN lr_data->* TO FIELD-SYMBOL(<field>).
            CREATE DATA <attribute> LIKE STANDARD TABLE OF <field>.
            ASSIGN <attribute>->* TO <attribute>.
        ENDCASE.
      ENDIF.

      CASE lr_attri->type_kind.

        WHEN `g` OR `I` OR `C`.
          DATA(lv_value) = lo_model->get_attribute( lr_attri->name )->get_val( ).
          <attribute> = lv_value.

        WHEN `h`.
          z2ui5_lcl_utility=>trans_ref_tab_2_tab(
               EXPORTING ir_tab_from = lo_model->get_attribute( lr_attri->name )->mr_actual
               IMPORTING t_result    = <attribute> ).

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    TRY.
        result->ms_actual-event = mo_body->get_attribute( `OEVENT` )->get_attribute( `EVENT` )->get_val( ).
        result->ms_actual-event_data = mo_body->get_attribute( `OEVENT` )->get_attribute( `vData` )->get_val( ).
      CATCH cx_root.
    ENDTRY.

    TRY.
        DATA(lo_scroll) = mo_body->get_attribute( `OSCROLL` ).
        z2ui5_lcl_utility=>trans_ref_tab_2_tab(
            EXPORTING ir_tab_from = lo_scroll->mr_actual
            IMPORTING t_result    = result->ms_actual-t_scroll_pos ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD set_app_start.

    result = NEW #( ).
    result->ms_db-id = z2ui5_lcl_utility=>get_uuid( ).

    TRY.
        DATA(lv_classname) = z2ui5_lcl_utility=>get_trim_upper( z2ui5_cl_http_handler=>client-t_param[ name = `app` ]-value  ).
        z2ui5_lcl_utility=>raise( when = xsdbool( lv_classname = `` ) ).
      CATCH cx_root.
        result = result->set_app_system( ).
        RETURN.
    ENDTRY.

    TRY.
        CREATE OBJECT result->ms_db-o_app TYPE (lv_classname).

      CATCH cx_root.
        result = result->set_app_system( error_text = `class with name ` && lv_classname && ` not found` ).
        RETURN.
    ENDTRY.

    result->ms_db-o_app->id = result->ms_db-id.
    result->ms_db-t_attri   = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).

  ENDMETHOD.

  METHOD set_app_leave.

    result = NEW #( ).

    result->ms_db-o_app = ms_next-o_call_app.
    CLEAR ms_next.
    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

    DATA(ls_draft) = z2ui5_lcl_fw_db=>read( id = result->ms_db-o_app->id check_load_app = abap_false ).
    result->ms_db-id_prev_app_stack = ls_draft-uuid_prev_app_stack.

    result->ms_db-t_attri     = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    result->ms_db-id          = z2ui5_lcl_utility=>get_uuid( ).
    result->ms_db-o_app->id   = result->ms_db-id.
    result->ms_db-id_prev_app = ms_db-id.
    result->ms_db-id_prev     = ms_db-id.

  ENDMETHOD.

  METHOD set_app_call.

    z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).

    result = NEW #( ).
    result->ms_db-id        = z2ui5_lcl_utility=>get_uuid( ).
    result->ms_db-o_app     = ms_next-o_call_app.
    result->ms_db-o_app->id = result->ms_db-id.

    result->ms_db-id_prev_app       = ms_db-id.
    result->ms_db-id_prev_app_stack = ms_db-id.

    result->ms_next-s_msg = ms_next-s_msg.

    result->ms_db-t_attri = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    CLEAR ms_next.

  ENDMETHOD.

  METHOD _create_binding.

    CONSTANTS c_prefix TYPE string VALUE `LO_APP->`.

    DATA(lo_app) = CAST object( ms_db-o_app ) ##NEEDED.

    IF type = cs_bind_type-one_time.
      DATA(lv_id) = z2ui5_lcl_utility=>get_uuid_session( ).
      INSERT VALUE #(
        name = lv_id
        data_stringify = z2ui5_lcl_utility=>trans_any_2_json( value )
        bind_type = type
       ) INTO TABLE ms_db-t_attri.
      result = |/{ lv_id }|.
      RETURN.
    ENDIF.

    DATA(lr_in) = REF #( value ).

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) v = `Attribute in App with name ` && lv_name && ` not found` ).
      DATA lr_ref TYPE REF TO data.
      GET REFERENCE OF  <attribute> INTO lr_ref.

      IF check_gen_data = abap_true.
        TRY.

            DATA lr_ref2 TYPE REF TO data.
            GET REFERENCE OF  <attribute> INTO lr_ref2.

            FIELD-SYMBOLS <field> TYPE any.
            ASSIGN lr_ref2->* TO <field>.
            lr_ref = CAST data( <field> ).
            IF lr_attri->gen_type IS INITIAL.
              FIELD-SYMBOLS <field2> TYPE any.
              ASSIGN lr_ref->* TO <field2>.
              DATA(lo_datadescr) = cl_abap_datadescr=>describe_by_data( <field2> ).
              lr_attri->gen_type_kind = lo_datadescr->type_kind.
              lr_attri->gen_kind = lo_datadescr->kind.
              CASE lo_datadescr->kind.
                WHEN lo_datadescr->kind_elem.
                  SPLIT lo_datadescr->absolute_name AT '=' INTO DATA(lv_dummy)  lr_attri->gen_type.
                WHEN lo_datadescr->kind_table.
                  DATA(lo_tab) = CAST cl_abap_tabledescr( lo_datadescr  ).
                  DATA(lo_struc) = lo_tab->get_table_line_type( ).
                  SPLIT lo_struc->absolute_name AT '=' INTO lv_dummy lr_attri->gen_type.
              ENDCASE.
            ENDIF.
          CATCH cx_root.
            CONTINUE.
        ENDTRY.
      ENDIF.

      IF lr_in = lr_ref.
        IF lr_attri->bind_type IS NOT INITIAL AND lr_attri->bind_type <> type.
          z2ui5_lcl_utility=>raise( `Binding Error - two diffferent binding types for same attribute (` && lr_attri->name && `) used` ).
        ENDIF.
        lr_attri->bind_type = type.
        result = COND #( WHEN type = cs_bind_type-two_way THEN `/oUpdate/` ELSE `/` ) && lr_attri->name.
        RETURN.
      ENDIF.

    ENDLOOP.

    IF type = cs_bind_type-two_way.
      z2ui5_lcl_utility=>raise( `Binding Error - two way binding used but no attribute found (` && lr_attri->name && `)` ).
    ENDIF.

    "one time when not global class attribute
    lv_id = z2ui5_lcl_utility=>get_uuid_session( ).
    INSERT VALUE #(
      name = lv_id
      data_stringify = z2ui5_lcl_utility=>trans_any_2_json( value )
      bind_type = cs_bind_type-one_time
     ) INTO TABLE ms_db-t_attri.
    result = |/{ lv_id }|.

  ENDMETHOD.


  METHOD set_app_system.

    IF ms_db-o_app  IS BOUND.
      z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).
    ENDIF.

    result = NEW #( ).
    result->ms_db-id = z2ui5_lcl_utility=>get_uuid( ).

    IF ix IS NOT BOUND AND error_text IS NOT INITIAL.
      ix = NEW z2ui5_lcl_utility( val = error_text ).
    ENDIF.

    IF ix IS BOUND.

      z2ui5_lcl_fw_db=>create( id = ms_db-id db = ms_db ).
      result->ms_db-o_app = z2ui5_lcl_fw_app=>factory_error( error = ix app = ms_db-o_app ).

      result->ms_db-id_prev_app = ms_db-id.
      result->ms_db-id_prev_app_stack = ms_db-id.
      result->ms_next-s_msg = ms_next-s_msg.
      result->ms_db-id_prev_app = ms_db-id.

    ELSE.
      result->ms_db-o_app = NEW z2ui5_lcl_fw_app( ).
    ENDIF.

    result->ms_db-t_attri = z2ui5_lcl_utility=>get_t_attri_by_ref( result->ms_db-o_app ).
    result->ms_db-o_app->id = result->ms_db-id.

  ENDMETHOD.


  METHOD request_end_model.

    CONSTANTS c_prefix TYPE string VALUE `LO_APP->`.

    DATA(lo_app) = CAST object( ms_db-o_app ) ##NEEDED.
    r_view_model  = z2ui5_lcl_utility_tree_json=>factory( ).
    r_view_model->mv_name = `oViewModel`.
    DATA(lo_update) = r_view_model->add_attribute_object( `oUpdate` ).

    LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ``.

      IF lr_attri->bind_type = cs_bind_type-one_time.
        r_view_model->add_attribute( n = lr_attri->name v = lr_attri->data_stringify apos_active = abap_false ).
        CONTINUE.
      ENDIF.

      DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs_bind_type-one_way THEN r_view_model
                                 ELSE lo_update ).

      FIELD-SYMBOLS <attribute> TYPE any.
      DATA(lv_name) = c_prefix && to_upper( lr_attri->name ).
      ASSIGN (lv_name) TO <attribute>.
      z2ui5_lcl_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

      IF lr_attri->gen_kind IS NOT INITIAL.
        lv_name = '<ATTRIBUTE>->*'.
        ASSIGN (lv_name) TO <attribute>.
        lr_attri->type_kind = lr_attri->gen_type_kind.
      ENDIF.

      CASE lr_attri->type_kind.

        WHEN `g` OR `D` OR `P` OR `T` OR `C`.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = z2ui5_lcl_utility=>get_abap_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN `I`.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = CONV string( <attribute> )
                                    apos_active = abap_false ).

        WHEN `h`.
          lo_actual->add_attribute( n = lr_attri->name
                                    v = z2ui5_lcl_utility=>trans_any_2_json( <attribute> )
                                    apos_active = abap_false ).

        WHEN OTHERS.

      ENDCASE.
    ENDLOOP.

    DELETE ms_db-t_attri WHERE bind_type = cs_bind_type-one_time.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_fw_client IMPLEMENTATION.

  METHOD constructor.

    mo_handler = handler.

  ENDMETHOD.

  METHOD z2ui5_if_client~popup_message_toast.

    mo_handler->ms_next-s_msg =  VALUE #(
        control = `MessageToast`
        type    = `show`
        text    = text
    ).

  ENDMETHOD.


  METHOD z2ui5_if_client~popup_message_box.

    mo_handler->ms_next-s_msg =  VALUE #(
        control = `MessageBox`
        type    = type
        text    = text
    ).

  ENDMETHOD.


  METHOD z2ui5_if_client~nav_app_home.

    z2ui5_if_client~nav_app_call( NEW z2ui5_lcl_fw_app( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_client~get.

    result = VALUE #( BASE CORRESPONDING #( mo_handler->ms_db )
         event             = mo_handler->ms_actual-event
         event_data        = mo_handler->ms_actual-event_data
         t_scroll_pos      = mo_handler->ms_actual-t_scroll_pos
         t_req_header      = z2ui5_cl_http_handler=>client-t_header
         t_req_param       = z2ui5_cl_http_handler=>client-t_param
     ).

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_call.

    mo_handler->ms_next-o_call_app =  app.

  ENDMETHOD.

  METHOD z2ui5_if_client~set_next.

    mo_handler->ms_next-s_set = val.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind.

    result =  mo_handler->_create_binding(
        value = val
        type  = z2ui5_lcl_fw_handler=>cs_bind_type-two_way
        check_gen_data = check_gen_data
         ).
    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_bind_one.

    result = mo_handler->_create_binding( value = val type = z2ui5_lcl_fw_handler=>cs_bind_type-one_way ).
    IF path = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event.

    result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' } )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~_event_close_popup.

    result = `onEventFrontend( 'POPUP_CLOSE' )`.

  ENDMETHOD.

  METHOD z2ui5_if_client~nav_app_leave.

    z2ui5_if_client~nav_app_call( app ).
    mo_handler->ms_next-check_app_leave = abap_true.

  ENDMETHOD.

  METHOD z2ui5_if_client~get_app.

    result = CAST #( z2ui5_lcl_fw_db=>load_app( id )-o_app ).

  ENDMETHOD.

ENDCLASS.
