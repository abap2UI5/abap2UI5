CLASS z2ui5_cl_utility DEFINITION PUBLIC INHERITING FROM cx_no_check
    CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        type           TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
        data_rtti      TYPE string,
        check_ref_data TYPE abap_bool,
      END OF ty_attri.
    TYPES ty_t_attri TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        uuid   TYPE string,
        text   TYPE string,
      END OF ms_error.

    METHODS constructor
      IMPORTING
        val      TYPE any            OPTIONAL
        previous TYPE REF TO cx_root OPTIONAL
          PREFERRED PARAMETER val.

    METHODS get_text REDEFINITION.

    CLASS-METHODS get_classname_by_ref
      IMPORTING in            TYPE REF TO object
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS raise
      IMPORTING
        v    TYPE clike     DEFAULT `CX_SY_SUBRC`
        when TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER v.

    CLASS-METHODS get_uuid
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_user_tech
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS trans_any_2_json
      IMPORTING any           TYPE any
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS trans_xml_2_object
      IMPORTING xml  TYPE clike
      EXPORTING data TYPE data.

    CLASS-METHODS get_t_attri_by_ref
      IMPORTING io_app        TYPE REF TO object
      RETURNING VALUE(result) TYPE ty_t_attri ##NEEDED.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
                object        TYPE data
      RETURNING
                VALUE(result) TYPE string
      RAISING   cx_xslt_serialization_error.

    CLASS-METHODS get_abap_2_json
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS check_is_boolean
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE abap_bool.

    CLASS-METHODS get_json_boolean
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING ir_tab_from TYPE REF TO data
      EXPORTING t_result    TYPE STANDARD TABLE.

    CLASS-METHODS get_trim_upper
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS _get_t_attri_by_struc
      IMPORTING io_app        TYPE REF TO object
                iv_attri      TYPE csequence
      RETURNING VALUE(result) TYPE abap_attrdescr_tab.

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

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_utility IMPLEMENTATION.

  METHOD get_trim_upper.

    result = CONV #( val ).
    result = to_upper( shift_left( shift_right( result ) ) ).

  ENDMETHOD.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).
    CLEAR textid.

    TRY.
        ms_error-x_root ?= val.
      CATCH cx_root ##CATCH_ALL.
        ms_error-text = val.
    ENDTRY.

    ms_error-uuid = get_uuid( ).

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

  METHOD get_t_attri_by_ref.

    DATA(lt_attri) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref( io_app ) )->attributes.
    DELETE lt_attri WHERE visibility <> cl_abap_classdescr=>public.

    LOOP AT lt_attri INTO DATA(ls_attri)
         WHERE type_kind = cl_abap_classdescr=>typekind_struct2
               OR type_kind = cl_abap_classdescr=>typekind_struct1.

      DELETE lt_attri INDEX sy-tabix.

      INSERT LINES OF _get_t_attri_by_struc( io_app   = io_app
                                             iv_attri = ls_attri-name ) INTO TABLE lt_attri.

    ENDLOOP.

    LOOP AT lt_attri INTO ls_attri.

      DATA(ls_attri2) = VALUE ty_attri( ).
      ls_attri2 = CORRESPONDING #( ls_attri ).

      FIELD-SYMBOLS <any> TYPE any.
      UNASSIGN <any>.
      DATA(lv_assign) = `IO_APP->` && ls_attri-name.
      ASSIGN (lv_assign) TO <any>.

      DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <any> ).
      TRY.
          DATA(lo_refdescr) = CAST cl_abap_refdescr( lo_descr ).
          DATA(lo_reftype) = CAST cl_abap_datadescr( lo_refdescr->get_referenced_type( ) ) ##NEEDED.
          ls_attri2-check_ref_data = abap_true.
        CATCH cx_root.
      ENDTRY.

      APPEND ls_attri2 TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD _get_t_attri_by_struc.

    FIELD-SYMBOLS <attribute> TYPE any.

    DATA(lv_name) = `IO_APP->` && to_upper( iv_attri ).
    ASSIGN (lv_name) TO <attribute>.
    raise( when = xsdbool( sy-subrc <> 0 ) ).

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <attribute> ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_type ).

    LOOP AT lo_struct->get_components( ) REFERENCE INTO DATA(lr_comp).

      DATA(lv_element) = iv_attri && `-` && lr_comp->name.

      IF lr_comp->as_include = abap_true.
        INSERT LINES OF _get_t_attri_by_struc( io_app   = io_app
                                               iv_attri = lv_element ) INTO TABLE result.

      ELSE.
        INSERT VALUE #( name      = lv_element
                        type_kind = lr_comp->type->type_kind ) INTO TABLE result.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD trans_any_2_json.
    result = /ui2/cl_json=>serialize( any ).
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

        RAISE EXCEPTION TYPE z2ui5_cl_utility
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

        RAISE EXCEPTION TYPE z2ui5_cl_utility
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.

  METHOD get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname sub = `\CLASS=` ).

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
          CASE ls_comp-type->kind.
            WHEN cl_abap_typedescr=>kind_table.
              trans_ref_tab_2_tab( EXPORTING ir_tab_from = <comp_ui5>
                                   IMPORTING t_result    = <comp> ).
            WHEN OTHERS.
              <comp> = <ls_data_ui5>.
          ENDCASE.
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
    ELSEIF ms_error-text IS NOT INITIAL.
      result = ms_error-text.
      error = abap_true.
    ENDIF.

    result = COND #(  WHEN error = abap_true AND result IS INITIAL THEN `unknown error` ).

  ENDMETHOD.

  METHOD raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cl_utility EXPORTING val = v.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


