CLASS lcl_db DEFINITION.


  PUBLIC SECTION.


    TYPES ty_t_table TYPE z2ui5_cl_app_demo_13=>ty_t_table.

    CLASS-DATA app TYPE REF TO z2ui5_cl_app_demo_13.
    "CLASS-DATA st_table TYPE ty_t_table.

    CLASS-METHODS generate_test_data.

    CLASS-METHODS get_table_by_json
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_table.

    CLASS-METHODS get_table_by_xml
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_table.

    CLASS-METHODS get_table_by_csv
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_table.

    CLASS-METHODS get_csv_by_table
      IMPORTING
        val           TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_xml_by_table
      IMPORTING
        val           TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_json_by_table
      IMPORTING
        val           TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_fieldlist_by_table
      IMPORTING
        it_table      TYPE table
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS db_save
      IMPORTING
        value TYPE ty_t_table.

    CLASS-METHODS db_read
      RETURNING
        VALUE(result) TYPE ty_t_table.
    CLASS-METHODS get_test_data_json
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_db IMPLEMENTATION.

  METHOD generate_test_data.

    app->st_db = VALUE #(
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
    ).

  ENDMETHOD.


  METHOD get_table_by_json.

    DATA lt_tab TYPE ty_t_table.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = val
*        jsonx            =
*        pretty_name      =
*        assoc_arrays     =
*        assoc_arrays_opt =
*        name_mappings    =
*        conversion_exits =
*        hex_as_base64    =
      CHANGING
        data             = lt_tab
    ).

    result = lt_tab.

  ENDMETHOD.


  METHOD get_table_by_xml.

    DATA lt_tab TYPE ty_t_table.

    CALL TRANSFORMATION id SOURCE xml = val RESULT data = lt_tab.

    result = lt_tab.

  ENDMETHOD.

  METHOD get_table_by_csv.

    SPLIT val AT ';' INTO TABLE DATA(lt_cols).

    LOOP AT lt_cols INTO DATA(lv_field).

      DATA(ls_row) = VALUE z2ui5_cl_app_demo_13=>ty_s_spfli( ).
      DATA(lv_index) = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE ls_row TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        <field> = lv_field.
        lv_index = lv_index + 1.
      ENDDO.
      INSERT ls_row INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD db_save.

    "normally modify database here

    "test scenario, therefore write internal table instead
    app->st_db = value.

  ENDMETHOD.

  METHOD db_read.

    "normally read database here

    "test scenario, therefore read internal table instead

    result = app->st_db.

  ENDMETHOD.

  METHOD get_csv_by_table.

    LOOP AT val INTO DATA(ls_row).

      DATA(lv_index) = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE ls_row TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        result = result && <field> && ';'.
      ENDDO.
      result = result && cl_abap_char_utilities=>cr_lf.
    ENDLOOP.


  ENDMETHOD.

  METHOD get_json_by_table.

    result = /ui2/cl_json=>serialize(
               val
*               compress         =
*               name             =
*               pretty_name      =
*               type_descr       =
*               assoc_arrays     =
*               ts_as_iso8601    =
*               expand_includes  =
*               assoc_arrays_opt =
*               numc_as_string   =
*               name_mappings    =
*               conversion_exits =
           "   format_output    = abap_true
*               hex_as_base64    =
             ).


  ENDMETHOD.

  METHOD get_xml_by_table.

    CALL TRANSFORMATION id SOURCE values = val RESULT XML result.

  ENDMETHOD.

  METHOD get_fieldlist_by_table.

    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( it_table ) ).
    DATA(lo_struc) = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).

    DATA(lt_comp) = lo_struc->get_components( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      INSERT ls_comp-name INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_test_data_json.

    result = `[` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  }` && |\n| &&
             `]`.

  ENDMETHOD.

ENDCLASS.

CLASS z2ui5_lcl_utility DEFINITION INHERITING FROM cx_no_check.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        type           TYPE string,
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

    CLASS-METHODS trans_data_2_xml
      IMPORTING
        data        TYPE data
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

      DATA(ls_attri2) = VALUE ty_attri( ).
      ls_attri2 = CORRESPONDING #( ls_attri ).

      FIELD-SYMBOLS <any> TYPE any.
      UNASSIGN <any>.
      DATA(lv_assign) = `IO_APP->` && ls_attri-name.
      ASSIGN (lv_assign) TO <any>.
      DATA(lo_descr) = cl_abap_datadescr=>describe_by_data( <any> ).
      CASE lo_descr->kind.
        WHEN lo_descr->kind_elem.
          ls_attri2-type =  CAST cl_abap_elemdescr( lo_descr )->get_relative_name( ).
      ENDCASE.

      APPEND ls_attri2 TO result.
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


  METHOD trans_data_2_xml.

   " FIELD-SYMBOLS <object> TYPE any.
  "  ASSIGN object->* TO <object>.
  "  raise( when = xsdbool( sy-subrc <> 0 ) ).

    CALL TRANSFORMATION id
       SOURCE data = data
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
      CREATE DATA lr_row LIKE LINE OF t_result.
      ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).

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
