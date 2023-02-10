CLASS z2ui5_cl_hlp_utility DEFINITION
  PUBLIC
 CREATE PUBLIC INHERITING FROM cx_no_check.

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ty_property,
             n TYPE string,
             v TYPE string,
             "  name TYPE string,
           END OF ty_property.

    TYPES: BEGIN OF ty_attri,
             name         TYPE string,
             kind         TYPE string,
             check_used   TYPE abap_bool,
             check_update type abap_bool,
           END OF ty_attri.

    TYPES: BEGIN OF ty_control,
             name       TYPE string,
             ns         TYPE string,
             t_property TYPE STANDARD TABLE OF ty_property WITH EMPTY KEY, "if_web_http_request=>name_value_pairs,
             t_child    TYPE STANDARD TABLE OF REF TO data WITH EMPTY KEY,
             parent     TYPE REF TO data,
           END OF ty_control.

    TYPES:
      BEGIN OF ty,
        BEGIN OF s,
          property TYPE ty_property,
          control TYPE ty_control,
          attri TYPE ty_attri,
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
          BEGIN OF get,
            username    TYPE abap_bool,
            timestampl  TYPE abap_bool,
            uuid        TYPE abap_bool,
            user_tech   TYPE abap_bool,
            utc_current TYPE abap_bool,
          END OF get,
          BEGIN OF get_result,
            username    TYPE string,
            user_tech   TYPE string,
            uuid        TYPE string,
            timestampl  TYPE timestampl,
            utc_current TYPE utcl,
            val         TYPE string,
            o           TYPE REF TO z2ui5_cl_hlp_utility,
          END OF get_result,
          BEGIN OF get_server_info,
            url_app  TYPE string,
            url_abap TYPE string,
            origin   TYPE string,
            tenant   TYPE string,
          END OF get_server_info,
        END OF s,
        BEGIN OF t,
          property TYPE STANDARD TABLE OF ty_property WITH EMPTY KEY,
          attri    TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY,
          control  TYPE STANDARD TABLE OF REF TO ty_control WITH EMPTY KEY,
        END OF t,
        BEGIN OF o,
          me TYPE REF TO z2ui5_cl_hlp_utility,
        END OF o,
      END OF ty.

    DATA:
      BEGIN OF ms_log,
        t_log TYPE STANDARD TABLE OF ty-s-msg_result WITH EMPTY KEY,
      END OF ms_log.

    DATA:
      BEGIN OF ms_error,
        x_root TYPE REF TO cx_root,
        "   x_me   type ty-o_me,
        uuid   TYPE string,
        kind   TYPE string,
        text   TYPE string,
        s_msg  TYPE ty-s-msg_result,
        o_log  TYPE ty-o-me,
      END OF ms_error.

    CLASS-DATA x TYPE REF TO cx_root.

    METHODS constructor
      IMPORTING
        val      TYPE any OPTIONAL
        kind     TYPE string OPTIONAL
        textid   LIKE if_t100_message=>t100key OPTIONAL
        previous LIKE previous OPTIONAL
          PREFERRED PARAMETER val.

    METHODS get_text REDEFINITION.

    CLASS-METHODS get_xml_by_control
      IMPORTING ms_control      TYPE ty-s-control
      RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS log_factory
      RETURNING VALUE(result) TYPE ty-o-me.

    METHODS x_get_kind
      RETURNING VALUE(r_result) TYPE string.

    METHODS log
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE ty-o-me.

    METHODS log_sy
      RETURNING VALUE(result) TYPE ty-o-me.


    CLASS-METHODS get_server_info
      IMPORTING
        app           TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty-s-get_server_info.


    CLASS-METHODS msg
      IMPORTING val             TYPE any OPTIONAL
                msg             TYPE ty-s-msg OPTIONAL
                  PREFERRED PARAMETER val
      RETURNING VALUE(r_result) TYPE ty-s-msg_result.

    CLASS-METHODS x_factory_by
      IMPORTING x_root        TYPE REF TO cx_root
      RETURNING VALUE(result) TYPE ty-o-me.

    METHODS x_db_save RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS x_factory_by_db
      IMPORTING iv_guid         TYPE string
      RETURNING VALUE(r_result) TYPE ty-o-me. "REF TO zzzyyy77_cx.

    CLASS-METHODS db_save_root
      IMPORTING ix_root       TYPE REF TO cx_root
      RETURNING VALUE(r_uuid) TYPE string.

    CLASS-METHODS db_factory_root
      IMPORTING iv_uuid         TYPE string
      RETURNING VALUE(r_result) TYPE REF TO cx_root.

    CLASS-METHODS mail.

    CLASS-METHODS get_classname_by_ref
      IMPORTING in              TYPE REF TO object
      RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS get
      IMPORTING val             TYPE ty-s-get OPTIONAL
      RETURNING VALUE(r_result) TYPE ty-s-get_result.

    CLASS-METHODS get_uuid
      RETURNING VALUE(r_result) TYPE string
      RAISING   cx_uuid_error.

    CLASS-METHODS get_uuid_session
      RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS get_timestamp_utcl
      RETURNING VALUE(r_result) TYPE utcl.

    CLASS-METHODS get_user_tech
      RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS get_timestampl
      RETURNING VALUE(r_result) TYPE timestampl.

    CLASS-METHODS get_user_name
      RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS get_data_by_json
      IMPORTING val             TYPE string
      EXPORTING VALUE(r_result) TYPE data.

    CLASS-METHODS trans_json_2_data
      IMPORTING
        iv_json   TYPE clike
       exporting
        ev_result TYPE REF TO data.

    CLASS-METHODS trans_data_2_json
      IMPORTING
        data            TYPE data
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS trans_xml_2_object
      IMPORTING
        xml           TYPE clike
      EXPORTING
        data          TYPE data
      RETURNING
        VALUE(result) TYPE REF TO data. "if_serializable_object.

    CLASS-METHODS trans_xml_2_any_multi
      IMPORTING
        xml     TYPE clike
      EXPORTING
        object1 TYPE REF TO if_serializable_object
        object2 TYPE REF TO if_serializable_object
        data1   TYPE REF TO data
        data2   TYPE REF TO data.

    CLASS-METHODS trans_any_2_xml_multi
      IMPORTING
        object1       TYPE REF TO if_serializable_object OPTIONAL
        object2       TYPE REF TO if_serializable_object OPTIONAL
        data1         TYPE REF TO data OPTIONAL
        data2         TYPE REF TO data OPTIONAL
      RETURNING
        VALUE(result) TYPE string.



    CLASS-METHODS hlp_get_t_attri
      IMPORTING
        VALUE(io_app)   TYPE REF TO object
      RETURNING
        VALUE(r_result) TYPE ty-t-attri.

    CLASS-METHODS trans_object_2_xml
      IMPORTING
        object        TYPE data
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_any_2_json
      IMPORTING
        any           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS action_parallel
      IMPORTING
        it_parallel   TYPE cl_abap_parallel=>t_in_inst_tab
      RETURNING
        VALUE(result) TYPE cl_abap_parallel=>t_out_inst_tab.

    CLASS-METHODS conv_char_2_hex
      IMPORTING
        iv_string       TYPE clike
      RETURNING
        VALUE(r_result) TYPE xstring.

    CLASS-METHODS conv_hex_2_bin
      IMPORTING
        iv_string       TYPE clike
      RETURNING
        VALUE(r_result) TYPE xstring.

    CLASS-METHODS conv_bin_2_base64
      IMPORTING
        iv_string       TYPE clike
      RETURNING
        VALUE(r_result) TYPE xstring.

    CLASS-METHODS conv_string_2_xstring
      IMPORTING
        iv_string       TYPE clike
      RETURNING
        VALUE(r_result) TYPE xstring.

    CLASS-METHODS get_abap_as_json
      IMPORTING
        i_mo_app_row2_abap TYPE any
      RETURNING
        VALUE(r_result)    TYPE string.

    CLASS-METHODS hlp_get_json_as_abap
      IMPORTING
        i_mo_app_row2_abap TYPE REF TO data
      CHANGING
        co_data            TYPE data.

    CLASS-METHODS conv_xstring_2_string
      IMPORTING
        iv_xstring      TYPE xstring
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS assign
      IMPORTING
        object          TYPE REF TO object
        attri_name      TYPE clike
      RETURNING
        VALUE(r_result) TYPE REF TO data.

    CLASS-METHODS get_data_by_xml
      IMPORTING
        iv_data         TYPE string
      EXPORTING
        VALUE(r_result) TYPE data.

    CLASS-METHODS get_xml_by_data
      IMPORTING
        is_any          TYPE data
      RETURNING
        VALUE(r_result) TYPE string.
    CLASS-METHODS x_get_details
      IMPORTING
        val             TYPE REF TO cx_root
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_param_user
      IMPORTING
        val             TYPE clike
        VALUE(user)     TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS get_memory_user
      IMPORTING
        id              TYPE clike
        VALUE(user)     TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS set_memory_user
      IMPORTING
        val             TYPE clike
        id              TYPE clike
        VALUE(user)     TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS mime_db_read
      IMPORTING
                iv_id           TYPE string
      RETURNING VALUE(r_result) TYPE string.

    CLASS-METHODS mime_db_save
      IMPORTING
        iv_name1 TYPE string OPTIONAL
        iv_name2 TYPE string OPTIONAL
        iv_name3 TYPE string OPTIONAL
        iv_type  TYPE string
        iv_descr TYPE string OPTIONAL
        iv_data  TYPE string.

    CLASS-METHODS http_db_log.
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
      IMPORTING n             TYPE clike
                o             TYPE REF TO object
      RETURNING VALUE(result) TYPE REF TO data.

    CLASS-METHODS get_abap_2_json
      IMPORTING
        val             TYPE any
      RETURNING
        VALUE(r_result) TYPE string.
    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING
        ir_tab_from TYPE REF TO data
        ir_tab_to   TYPE REF TO data.
    CLASS-METHODS _get_t_attri
      IMPORTING
        io_app          TYPE REF TO object
        ir_attri        TYPE string "REF TO abap_attrdescr
      RETURNING
        VALUE(r_result) TYPE abap_attrdescr_tab.
    "" ct_attri TYPE abap_attrdescr_tab
    " ct_tmp   TYPE abap_attrdescr_tab.
*      IMPORTING
*        is_db TYPE zzzyyy77_t_001.
  PRIVATE SECTION.
    CLASS-DATA mv_counter TYPE int4.

ENDCLASS.



CLASS Z2UI5_CL_HLP_UTILITY IMPLEMENTATION.


  METHOD action_parallel.

    NEW cl_abap_parallel( )->run_inst(
       EXPORTING
          p_in_tab = it_parallel "value #( ( lo_update )  )
       IMPORTING
          p_out_tab = result ). "DATA(l_out_tab) ).

  ENDMETHOD.


  METHOD assign.
    "DATA(lr_data) = REF #( object->(lv_attri) ).
    "CREATE DATA r_result LIKE lr_data->*.
    "r_result->* = lr_data->*.

    FIELD-SYMBOLS <attribute> TYPE any.
    FIELD-SYMBOLS <result> TYPE any.

    DATA(lv_name) = |OBJECT->{ to_upper( attri_name ) }|.
    ASSIGN (lv_name) TO <attribute>.

    CREATE DATA r_result LIKE <attribute>.
    ASSIGN r_result->* TO <result>.

    <result> = <attribute>.

  ENDMETHOD.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).
    .
*"    super->constructor( previous = cond #( when val is INSTANCE OF cx_root then val else previous ) ).

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.


    CASE TYPE OF cl_abap_typedescr=>describe_by_data( val ).
      WHEN TYPE cl_abap_refdescr.
        ms_error-x_root ?= val.
      WHEN OTHERS.
        ms_error-s_msg-message = val.
    ENDCASE.


    " msg( val ).
    "text  = txt.
    ms_error-kind = kind.



    TRY.
        ms_error-uuid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD conv_bin_2_base64.

  ENDMETHOD.


  METHOD conv_char_2_hex.

  ENDMETHOD.


  METHOD conv_hex_2_bin.

  ENDMETHOD.


  METHOD conv_string_2_XSTRING.

    " TRY.
    DATA(l_convout2) = cl_abap_conv_codepage=>create_out(
        codepage = 'UTF-8' ).
    r_result = l_convout2->convert( source = iv_string ).
*      CATCH cx_sy_conversion_codepage.(

    "  CATCH cx_root.
    " message 'Conversion failure' type 'E'.
    "ENDTRY.

  ENDMETHOD.


  METHOD conv_XSTRING_2_string.

    " TRY.
    DATA(l_conv_in) = cl_abap_conv_codepage=>create_in(
        codepage = 'UTF-8' ).

    r_result = l_conv_in->convert( source = iv_xstring ).
*      CATCH cx_sy_conversion_codepage.(

    "  CATCH cx_root.
    " message 'Conversion failure' type 'E'.
    "ENDTRY.

  ENDMETHOD.


  METHOD db_factory_root.

*    SELECT SINGLE FROM ztt_test77_log
*        FIELDS
*        *
*      WHERE id = @iv_uuid
*      INTO @DATA(ls_db).
*
*    r_result = CAST #( trans_xml_2_object( ls_db-xml_data ) ).

  ENDMETHOD.


  METHOD db_save_root.

*    r_uuid = lcl_help=>get_uuid( ).
*
*    INSERT ztt_test77_log FROM @(
*        VALUE #(
*        id = r_uuid
*        message = ix_root->get_text( )
*        xml_data = trans_object_2_xml( ix_root )
*        )
*    ).

  ENDMETHOD.


  METHOD get.


*    CASE abap_true.
*
*      WHEN val-timestampl.
*        r_result-timestampl = lcl_help=>get_timestampl( ).
*        r_result-val = CONV #( r_result-timestampl ).
*      WHEN val-user_tech.
*        r_result-user_tech = lcl_help=>get_user_tech( ).
*        r_result-val = CONV #( r_result-user_tech ).
*      WHEN val-username.
*        r_result-username = lcl_help=>get_user_name( ).
*        r_result-val = CONV #( r_result-username ).
*      WHEN val-utc_current.
*        r_result-utc_current = lcl_help=>get_utc_current( ).
*        r_result-val = CONV #(  r_result-utc_current ).
*      WHEN val-uuid.
*        r_result-uuid = lcl_help=>get_uuid( ).
*        r_result-val = CONV #( r_result-uuid ).
*
*    ENDCASE.


  ENDMETHOD.


  METHOD get_abap_2_json.

    DATA(lo_ele) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( val ) ).
    IF lo_ele->get_relative_name( ) = 'ABAP_BOOL'.
      r_result = COND #( WHEN val = abap_true THEN 'true' ELSE 'false' ).
    ELSE.
      r_result = |"{ CONV string( val ) }"|.
    ENDIF.

  ENDMETHOD.


  METHOD get_abap_as_json.

    DATA(o_type_desc) = cl_abap_typedescr=>describe_by_data( i_mo_app_row2_abap ).

    CASE o_type_desc->kind.
      WHEN cl_abap_typedescr=>kind_struct.
*      DATA(o_struct_desc) = CAST cl_abap_structdescr( o_type_desc ).
*      cl_demo_output=>write_data( o_struct_desc->components ).
      WHEN cl_abap_typedescr=>kind_table.

        r_result = /ui2/cl_json=>serialize( i_mo_app_row2_abap ).
        RETURN.

        r_result = escape( val    = /ui2/cl_json=>serialize( i_mo_app_row2_abap )
                           format = cl_abap_format=>e_json_string ) .

*      DATA(o_table_desc) = CAST cl_abap_tabledescr( o_type_desc ).
*      DATA(o_tl_struct_desc) = CAST cl_abap_structdescr( o_table_desc->get_table_line_type( ) ).
*      cl_demo_output=>write_data( o_tl_struct_desc->components ).
      WHEN cl_abap_typedescr=>kind_class.
*      DATA(o_class_desc) = CAST cl_abap_classdescr( o_type_desc ).
*      LOOP AT o_class_desc->methods ASSIGNING FIELD-SYMBOL(xxx<m>).
*        cl_demo_output=>write( <m>-name ).
*      ENDLOOP.
      WHEN cl_abap_typedescr=>kind_intf.
*      DATA(o_if_desc) = CAST cl_abap_intfdescr( o_type_desc ).
*      LOOP AT o_if_desc->methods ASSIGNING FIELD-SYMBOL(<i>).
*        cl_demo_output=>write( <i>-name ).
*      ENDLOOP.
      WHEN cl_abap_typedescr=>kind_elem.

        IF o_type_desc->get_relative_name( ) = 'ABAP_BOOL'.
          DATA(lv_value) = COND #( WHEN i_mo_app_row2_abap = abap_true THEN `true` ELSE `false` ).
          r_result = lv_value.
        ELSE.
          r_result = escape( val    = i_mo_app_row2_abap
                     format = cl_abap_format=>e_json_string ) .
          r_result =  '"' && r_result && '"'.

        ENDIF.

      WHEN cl_abap_typedescr=>kind_ref.
    ENDCASE.



  ENDMETHOD.


  METHOD get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    r_result = substring_after( val = lv_classname sub = '\CLASS=' ).

  ENDMETHOD.


  METHOD get_data_by_json.
    CHECK val IS NOT INITIAL.
    RETURN.
*    " Convert JSON to post structure
*    xco_cp_json=>data->from_string( val )->apply(
*      VALUE #( ( xco_cp_json=>transformation->camel_case_to_underscore ) )
*      )->write_to( r_result ).

  ENDMETHOD.


  METHOD get_data_by_xml.

    CALL TRANSFORMATION id
        SOURCE XML iv_data
        RESULT data = r_result.

  ENDMETHOD.


  METHOD get_memory_user.

*    DATA(lv_user) = COND string( WHEN user IS NOT SUPPLIED THEN hlp=>get( VALUE #( user_tech = 'X' ) )-val ELSE user ).
*
*    SELECT SINGLE FROM zzzyyy88_t_003
*    FIELDS
*        value
*    WHERE uname = @lv_user AND
*            id = @id
*          INTO @r_result.

  ENDMETHOD.


  METHOD get_params_by_url.

    url = to_upper( url ).
    name = to_upper( name ).
    SPLIT url AT `?` INTO DATA(dummy) url.
    SPLIT url AT `&` INTO TABLE DATA(lt_href).
    DATA(lt_url_params) = VALUE if_web_http_request=>name_value_pairs(  ).
    LOOP AT lt_href REFERENCE INTO DATA(lr_href).
      SPLIT lr_href->* AT `=` INTO TABLE DATA(lt_param).
      INSERT VALUE #( name = to_upper( lt_param[ 1 ] ) value = to_upper( lt_param[ 2 ] ) ) INTO TABLE lt_url_params.
    ENDLOOP.

    r_result = lt_url_params[ name = name ]-value.

  ENDMETHOD.


  METHOD get_param_user.

*    DATA(lv_user) = COND string( WHEN user IS NOT SUPPLIED THEN hlp=>get( VALUE #( user_tech = 'X' ) )-val ELSE user ).
*
*    SELECT SINGLE FROM zzzyyy88_t_002
*    FIELDS
*        value
*    WHERE uname = @lv_user AND
*        name = @val
*          INTO @r_result.


  ENDMETHOD.


  METHOD get_prev_when_no_handler.

    CASE TYPE OF val.
      WHEN TYPE cx_sy_no_handler INTO DATA(lx_no_handler).
        r_result = lx_no_handler->previous.
    ENDCASE.

    IF r_result IS NOT BOUND.
      r_result = val.
    ENDIF.

  ENDMETHOD.


  METHOD get_ref_data.

    ASSIGN o->(n) TO FIELD-SYMBOL(<field>).
    GET REFERENCE OF <field> INTO result.

  ENDMETHOD.


  METHOD get_timestampl.

    GET TIME STAMP FIELD r_result.

  ENDMETHOD.


  METHOD get_timestamp_utcl.

*    r_result = lcl_help=>get_utc_current(  ).

  ENDMETHOD.


  METHOD get_user_name.

*   r_result =  lcl_help=>get_user_name(  ).

  ENDMETHOD.


  METHOD get_user_tech.

    r_result = cl_abap_context_info=>get_user_technical_name( ).

  ENDMETHOD.


  METHOD get_uuid.

    r_result = cl_system_uuid=>create_uuid_c32_static( ).

  ENDMETHOD.


  METHOD get_uuid_session.

    mv_counter += 1.
    r_result = shift_left( shift_right( CONV string( mv_counter ) ) ).

  ENDMETHOD.


  METHOD get_xml_by_control.


    CASE ms_control-name.

      WHEN 'ZZHTML'.
        r_result = ms_control-t_property[ n = 'VALUE' ]-v.
        RETURN.
    ENDCASE.

    r_result = |{ r_result } <{ COND #( WHEN ms_control-ns <> '' THEN |{ ms_control-ns }:| ) }{ ms_control-name } \n {
                         REDUCE #( INIT val = `` FOR row IN ms_control-t_property
                          NEXT val = |{ val } { row-n }="{ escape( val = row-v  format = cl_abap_format=>e_xml_attr ) }" \n | ) }|.

    "     COND #( WHEN row-name IS NOT INITIAL " IS BOUND
    "                  THEN row-name "`{/oUpdate/` && row-name && `}`
    "                ELSE row-v ) }" \n | ) }|.
    IF ms_control-t_child IS INITIAL.
      r_result &&= '/>'.
      RETURN.
    ENDIF.

    r_result &&= '>'.

    LOOP AT ms_control-t_child INTO DATA(lr_child).
      FIELD-SYMBOLS <child> TYPE ty-s-control.

      ASSIGN lr_child->* TO <child>.
      r_result &&= get_xml_by_control( <child> ).

    ENDLOOP.

    r_result &&= |</{ COND #( WHEN ms_control-ns <> '' THEN |{ ms_control-ns }:| ) }{ ms_control-name }>|.


  ENDMETHOD.


  METHOD get_xml_by_data.

    CALL TRANSFORMATION id
    SOURCE data = is_any "i_result->ms_db-data
    RESULT XML r_result.

  ENDMETHOD.


  METHOD hlp_get_json_as_abap.
    FIELD-SYMBOLS <any> TYPE any.

    DATA(o_type_desc) = cl_abap_typedescr=>describe_by_data( co_data ).

    CASE o_type_desc->kind.
      WHEN cl_abap_typedescr=>kind_struct.

      WHEN cl_abap_typedescr=>kind_table.
        FIELD-SYMBOLS <output> TYPE table.
        FIELD-SYMBOLS <row> TYPE any.
        DATA lr_row TYPE REF TO data.

        CLEAR co_data.
        ASSIGN co_data TO <output>.

        FIELD-SYMBOLS <tab> TYPE table.
        ASSIGN i_mo_app_row2_abap->* TO <tab>.
        LOOP AT <tab> ASSIGNING <any>.
          "INSERT INITIAL LINE INTO TABLE co_data ASSIGNING FIELD-SYMBOL(<row>).

          CREATE DATA lr_row LIKE LINE OF <tab>.
          ASSIGN lr_row->* TO <row>.

          INSERT <row> INTO TABLE <output>.
          " move corresponding ?
          DO.
            DATA(lv_index) = sy-index.
            ASSIGN COMPONENT lv_index OF STRUCTURE <any> TO FIELD-SYMBOL(<field>).
            IF sy-subrc <> 0.
              EXIT.
            ENDIF.
            ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO FIELD-SYMBOL(<field2>).
            <field2> = <field>.
          ENDDO.

        ENDLOOP.


      WHEN cl_abap_typedescr=>kind_class.

      WHEN cl_abap_typedescr=>kind_intf.

      WHEN cl_abap_typedescr=>kind_elem.

        ASSIGN i_mo_app_row2_abap->* TO <any>.
        co_data = <any>.
*        IF  o_type_desc->get_relative_name( ) = 'ABAP_BOOL'.
*          DATA(lv_value) = COND #(  WHEN i_mo_app_row2_abap = abap_true THEN `true` ELSE `false` ).
*          r_result = lv_value.
*          RETURN.
*        ENDIF.
*
*        r_result =  '"' && i_mo_app_row2_abap && '"'.


      WHEN cl_abap_typedescr=>kind_ref.
    ENDCASE.


  ENDMETHOD.


  METHOD hlp_get_t_attri.

    io_app = CAST object( io_app ).

    DATA(lo_descr) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_object_ref(
          p_object_ref         = io_app
          ) ).

    DATA(rt_attri)  = lo_descr->attributes.

    DATA(rt_tmp) = VALUE abap_attrdescr_tab( ).

    DELETE rt_attri WHERE visibility <> cl_abap_classdescr=>public.

    LOOP AT rt_attri REFERENCE INTO DATA(lr_attri).

      CASE lr_attri->type_kind.

        WHEN cl_abap_classdescr=>typekind_struct2.

          DATA(lt_attri_tmp) =  _get_t_attri(
              io_app = io_app
              ir_attri = CONV #( lr_attri->name )
               ).

          DELETE rt_attri.
          INSERT LINES OF lt_attri_tmp INTO TABLE rt_attri.

      ENDCASE.

    ENDLOOP.


    LOOP AT rt_attri REFERENCE INTO lr_attri.

      INSERT VALUE #(
       name = lr_attri->name
       kind = lr_attri->type_kind
      ) INTO TABLE r_result.

    ENDLOOP.

  ENDMETHOD.


  METHOD http_db_log.


*    DATA(ls_db) = is_db.
*
*    ls_db-uuid = hlp=>get( VALUE #( uuid = 'X' ) )-val. "( ).
*    ls_db-utc_stamp = hlp=>get( VALUE #( utc_current = 'X' ) )-utc_current.
*    ls_db-uname = hlp=>get( VALUE #( username = 'X' ) )-val.
*    " ls_db-
*
*    MODIFY zzzyyy77_t_001 FROM @ls_db.

  ENDMETHOD.


  METHOD if_message~get_text.

    IF ms_error-x_root IS NOT INITIAL.
      result = ms_error-x_root->get_text(  ).
      result = COND #( WHEN result IS INITIAL THEN 'Es ist ein unbekannter Fehler aufgetreten' ELSE result ).
      RETURN.
    ENDIF.

    IF ms_error-s_msg-message IS NOT INITIAL.
      result = ms_error-s_msg-message.
      result = COND #( WHEN result IS INITIAL THEN 'Es ist ein unbekannter Fehler aufgetreten' ELSE result ).
      RETURN.
    ENDIF.

    IF if_t100_message~t100key-msgid IS NOT INITIAL.

      MESSAGE ID if_t100_message~t100key-msgid TYPE `I` NUMBER if_t100_message~t100key-msgno
         INTO ms_error-text.
      result = COND #( WHEN result IS INITIAL THEN 'Es ist ein unbekannter Fehler aufgetreten' ELSE result ).
      RETURN.
    ENDIF.

*CALL METHOD SUPER->IF_MESSAGE~GET_TEXT
*  RECEIVING
*    RESULT =
*    .
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

*DATA: lo_pdf               TYPE REF TO zcl_pdf.
*      DATA : gt_data TYPE TABLE OF xstring.
*    DATA lv_text      TYPE string.
*  DATA lv_content   TYPE xstring.
*  DATA lv_len       TYPE i.
*  data lv_font_size TYPE i.
*
*  create object lo_pdf.
*
*  lv_text = 'Hello world! : - ( )'' " \|/?´`^¨§$'.
*
*  lo_pdf->rect( iv_x = 10 iv_y = 10 iv_width = 80 iv_heigth = 200  iv_style = 'S' ).
*
*lv_font_size = lo_pdf->get_max_font_size_for_width( iv_text = lv_text iv_max_width = 80 ).
* lo_pdf->set_font_size( lv_font_size ).
*
*  lo_pdf->text_box( iv_text = lv_text iv_x = 10 iv_y = 10 iv_width = 80 iv_height = 200 ).
*  lo_pdf->add_page( ).
*
*  lv_content = lo_pdf->output( ).


*  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*    EXPORTING
*      buffer        = lv_content
*    IMPORTING
*      output_length = lv_len
*    TABLES
*      binary_tab    = gt_data.















    DATA lv_string TYPE string.
    DATA lv_xstring TYPE xstring.

    lv_xstring = '41'.

    DATA(lv_string2) = conv_xstring_2_string( lv_xstring ).
    lv_string = 'A'.

    DATA(lv_xstring2) = conv_string_2_xstring( iv_string = lv_string  ).

    lv_xstring = 'A'.

    lv_string = 'A'.


*https://de.wikipedia.org/wiki/Base64
*Phase   Daten   Anmerkungen
*Ursprungstext   Pol
*Unicode-Zeichen U+0050      U+006F      U+006C  gemäß Unicodeblock Basis-Lateinisch
*Bytes   0x50        0x6F        0x6C    gemäß UTF-8
*Binärschreibweise   0101 0000   0110 1111   0110 1100   siehe Hexadezimalsystem
*Gruppierung in 6er-Blöcken  010100   000110   111101   101100   jeder 6er-Block entspricht einem Base64-Zeichen
*Codierung als Base64-Zeichen    U        G        9        s    gemäß der Tabelle oben von „binär“ nach „Zeichen“
*Ohne Leerzeichen    UG9s

*    string -> xstring / hex
*    hex -> bin / raw
*    bin -> base 64


*    call function 'SCMS_XSTRING_TO_BINARY'
*      EXPORTING
*        buffer          = lv_xstring
**        append_to_table = space
**      IMPORTING
**        output_length   =
*      TABLES
*        binary_tab      = lt_stringtab
*      .

*CALL METHOD cl_http_utility=>if_http_utility~encode_base64
*      EXPORTING
*        unencoded = lv_string
*      RECEIVING
*        encoded   = data(lv_base64).


*DATA(lt_binary_data) = CL_BCS_CONVERT=>XSTRING_TO_SOLIX(
*    EXPORTING
*        iv_xstring = lv_xstring
*).
*
*
*CL_SWF_UTL_CONVERT_XSTRING=>XSTRING_TO_TABLE(
*    EXPORTING
*        i_stream = lv_xstring
*    IMPORTING
*        e_table  = lt_stringtab
*).

    "data lv_raw type raw length 255.

    "DATA: it_bin_data TYPE STANDARD TABLE OF raw255.
    DATA(iv_xstring) = lv_xstring2.
    DATA et_solix TYPE STANDARD TABLE OF xstring. " = lt_stringtab.
    DATA(ls_solix) = ``.
    DATA lv_size TYPE i.
    DATA lv_off TYPE i.
    " data ls_solix type solix.
    DATA lv_rows TYPE i.
    DATA lv_last_row_len TYPE i.
    DATA lv_row_len TYPE i.

    "describe table et_solix.
    lv_row_len = sy-tleng.
    lv_size = xstrlen( iv_xstring ).

    lv_rows = lv_size DIV lv_row_len.
    lv_last_row_len = lv_size MOD lv_row_len.
    DO lv_rows TIMES.
      ls_solix = iv_xstring+lv_off(lv_row_len).
      APPEND ls_solix TO et_solix.
      ADD lv_row_len TO lv_off.
    ENDDO.
    IF lv_last_row_len > 0.
      ls_solix = iv_xstring+lv_off(lv_last_row_len).
      APPEND ls_solix TO et_solix.
    ENDIF.

*
*  data(binary_size) = xstrlen( lv_xstring ).
*  data(binary_tab) =   lt_stringtab.
*  assign component 1 of structure binary_tab to <binary> type 'X'.
*  if sy-subrc = 4.
*    assign component 0 of structure binary_tab to <binary> type 'X'.
*  endif.
*  describe field <binary> length binary_len in byte mode.
*  pos = 0.
*  i = ( binary_size + binary_len - 1 ) div binary_len.
*
*  do i times.
*    <binary> = xbuffer+pos.
*    pos = pos + binary_len.
*    append binary_tab.
*  enddo.

  ENDMETHOD.


  METHOD log.

  ENDMETHOD.


  METHOD log_factory.

  ENDMETHOD.


  METHOD log_sy.

  ENDMETHOD.


  METHOD mail.

*    data(lo_mail) = cl_bcs_mail_message=>create_instance( ).
*
*    lo_mail->set_subject( `das ist ein subject` ).
*    lo_mail->set_sender( `lk@status-c.com` ).
*    lo_mail->add_recipient(
*        iv_address = `lars.kaldewey@status-c.com`
**        iv_copy    = TO
*    ).

    "data(lo_body) = new cl_bcs_mail_bodypart( ).

    " cl_bcs_mail_bodypart=>

    " lo_mail->set_main( io_main =  ).
*    CATCH cx_bcs_mail.

    " lo_mail->set_main( io_main = new #( )->  ).
*    CATCH cx_bcs_mail.
*    lo_mail->send(
*    IMPORTING
*       et_status      = data(lv_status)
*       ev_mail_status = data(lv_mail_status)
*    ).

  ENDMETHOD.


  METHOD mime_db_read.

*    SELECT SINGLE FROM zzzyyy87_t_001
*        FIELDS data
*        WHERE id = @( CONV #( iv_id ) )
*       INTO @r_result.

  ENDMETHOD.


  METHOD mime_db_save.


*    MODIFY zzzyyy87_t_001 FROM @( VALUE #(
*            id = hlp=>get( VALUE #( uuid = abap_true ) )-val
*            name1 = iv_name1
*            name2 = iv_name2
*            name3 = iv_name3
*            type = iv_type
*            descr = iv_descr
*            data = iv_data
*         ) ).
*
*    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD msg.

*    r_result = COND #( WHEN val IS SUPPLIED
*                  THEN lcl_help_msg_mapper=>factory( )->get( val )
*                  ELSE lcl_help_msg_mapper=>factory( )->get_by_msg(
*                                               id   = msg-id
*                                               no   = msg-no
*                                               type = msg-ty
*                                               v1   = msg-v1
*                                               v2   = msg-v2
*                                               v3   = msg-v3
*                                               v4   = msg-v4
*                  ) ).

  ENDMETHOD.


  METHOD set_memory_user.

*    DATA(lv_user) = COND string( WHEN user IS NOT SUPPLIED THEN hlp=>get( VALUE #( user_tech = 'X' ) )-val ELSE user ).
*
*    MODIFY zzzyyy88_t_003 FROM @( VALUE #(  id = id uname = lv_user value = val ) ).
*    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD trans_any_2_json.

    result = /ui2/cl_json=>serialize( any ).

  ENDMETHOD.


  METHOD trans_any_2_xml_multi.

    CALL TRANSFORMATION id
       SOURCE
        obj1  = object1
        obj2  = object2
        data1 = data1
        data2 = data2 "i_result->ms_db-data
       RESULT
       XML result.
    "i_result->mi_object.

  ENDMETHOD.


  METHOD trans_data_2_json.

    r_result = /ui2/cl_json=>serialize( data ).

    " RETURN.
    " Convert input post to JSON
    "  DATA(json_post) = xco_cp_json=>data->from_abap( data )->apply(
    "    VALUE #( ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->to_string(  ).

    "  r_result = json_post.

  ENDMETHOD.


  METHOD trans_json_2_data.

    CHECK iv_json IS NOT INITIAL.

    DATA lr_data TYPE REF TO data.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( iv_json )
            assoc_arrays = abap_true
        CHANGING
         data            = ev_result
        ).


*    RETURN.
    " Convert JSON to post structure
*    xco_cp_json=>data->from_string( iv_json )->apply(
*      VALUE #( ( xco_cp_json=>transformation->camel_case_to_underscore ) )
*      )->write_to( iv_result ).

  ENDMETHOD.


  METHOD trans_object_2_xml.
    FIELD-SYMBOLS <object> TYPE any.
    ASSIGN object->* TO <object>.

    CALL TRANSFORMATION id
       SOURCE data = <object> "i_result->ms_db-data
       RESULT XML result
        OPTIONS data_refs = 'heap-or-create'.
    "i_result->mi_object.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_ui5> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <comp> TYPE data.
    FIELD-SYMBOLS <comp_ui5> TYPE data.

    DATA lr_tab_back TYPE REF TO data.
    DATA lr_tab_ui5_row TYPE REF TO data.
    FIELD-SYMBOLS <back> TYPE data.
    FIELD-SYMBOLS <ui5_row> TYPE data.

    "  DATA(lr_tab) = REF #( io_obj->(ir_attri->name) ).
    ASSIGN ir_tab_to->* TO <tab>.
    " DATA(lv_name) = ir_attri->name.
    "lr_tab_ui5 = mo_body->get_attribute( lv_name )->mr_actual.
    ASSIGN ir_tab_from->* TO <tab_ui5>.
    " <tab>.

    "  DATA(lv_test) = mo_body->get_attribute( lv_name )->write_result( ). "write( ).

    LOOP AT <tab> REFERENCE INTO lr_tab_back.
      ASSIGN lr_tab_back->* TO <back>.

      DATA(lv_tabix) = sy-tabix.

      lr_tab_ui5_row = <tab_ui5>[ lv_tabix ].
      ASSIGN lr_tab_ui5_row->* TO <ui5_row>.


       data(lo_struct) = cast cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( <back> ) ).

        loop at lo_Struct->get_components( ) REFERENCE INTO data(lr_comp).

             ASSIGN COMPONENT lr_comp->name OF STRUCTURE <back> TO <comp>.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        ASSIGN COMPONENT lr_comp->name OF STRUCTURE <ui5_row> TO <comp_ui5>.
           IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        <comp> = <comp_ui5>->*.
       endloop.
*      DATA(lv_int) = 0.
*      DO.
*        lv_int += 1.
*        ASSIGN COMPONENT lv_int OF STRUCTURE <back> TO <comp>.
*        IF sy-subrc NE 0.
*          EXIT.
*        ENDIF.
*        ASSIGN COMPONENT lv_int OF STRUCTURE <ui5_row> TO <comp_ui5>.
*        <comp> = <comp_ui5>.
*      ENDDO.

    ENDLOOP.

  ENDMETHOD.


  METHOD trans_xml_2_any_multi.

    CALL TRANSFORMATION id
       SOURCE XML xml
       RESULT
        obj1  = object1
        obj2  = object2
        data1 = data1
        data2 = data2.

  ENDMETHOD.


  METHOD trans_xml_2_object.

    CALL TRANSFORMATION id
       SOURCE XML xml
       RESULT data = data.

  ENDMETHOD.


  METHOD x_db_save.

*    INSERT ztt_test77_log FROM @(
*        VALUE #(
*        id = ms_error-uuid  "hlp=>get_uuid( )
*        message = get_text( )
*        xml_data = trans_object_2_xml( me )
*        )
*    ).

  ENDMETHOD.


  METHOD x_factory_by.

    result = NEW #(  ).
    result->ms_error-x_root = x_root.
    result->ms_error-text = x_root->get_text( ).

  ENDMETHOD.


  METHOD x_factory_by_db.

*    SELECT SINGLE FROM ztt_test77_log
*        FIELDS
*        *
*      WHERE id = @iv_GUID
*      INTO @DATA(ls_db).
*
*    r_result = CAST #( trans_xml_2_object( ls_db-xml_data ) ).


  ENDMETHOD.


  METHOD x_get_details.

    DATA(lx) = val.
    DATA(lt_text) = VALUE string_table(   ).
    WHILE lx IS BOUND.
      INSERT lx->get_text(  ) INTO TABLE lt_text.
      lx = lx->previous.
    ENDWHILE.

    DELETE ADJACENT DUPLICATES FROM lt_text COMPARING table_line.

    r_result = REDUCE #( INIT result = ||
                         FOR row IN lt_text
                         NEXT result = result && row && | / | ).

  ENDMETHOD.


  METHOD x_get_kind.

    r_result = ms_error-kind.

  ENDMETHOD.


  METHOD _get_t_attri.
    FIELD-SYMBOLS <attribute> TYPE any.

    "DATA(lr_assign_struct) = REF #( io_app->(ir_attri) ).
    "DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( lr_assign_struct->* ) ).
    DATA(lv_name) = |IO_APP->{ to_upper( ir_attri ) }|.
    ASSIGN (lv_name) TO <attribute>.
    DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( <attribute> ) ).

    DATA(lt_comp2) = lo_struct->get_components( ).

    LOOP AT lt_comp2 REFERENCE INTO DATA(lr_comp).
      DATA(lv_element) = ir_attri.
      lv_element &&= '-' && lr_comp->name.


      TRY.
          "DATA(lr_value) = REF #( io_app->(lv_element) ).
          "lo_struct = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( lr_value->* ) ).
          lv_name = |IO_APP->{ to_upper( lv_element ) }|.
          ASSIGN (lv_name) TO <attribute>.
          lo_struct = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( <attribute> ) ).

          DATA(lt_comp3) = lo_struct->get_components( ).

          LOOP AT lt_comp3 REFERENCE INTO DATA(lr_comp2).

            DATA(lt_tmp) =  _get_t_attri(
                  io_app   = io_app
                  ir_attri = lr_comp2->name ).

            INSERT LINES OF lt_tmp INTO TABLE r_result.
          ENDLOOP.
        CATCH cx_root.
          INSERT VALUE #(
            name = lv_element
            type_kind = lr_comp->type->type_kind ) INTO TABLE r_result.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_server_info.

    DATA(lt_head) = z2ui5_cl_http_handler=>client-t_header.
    DATA(lv_url) = lt_head[ name = 'referer' ]-value.

    result-tenant = sy-mandt.
    result-url_app = lv_url && '?sap-client=' && result-tenant && '&app=' && app .
    result-origin = lt_head[ name = 'origin' ]-value.
    result-url_abap = result-origin && `/sap/bc/adt/oo/classes/` && app && `/source/main`.

  ENDMETHOD.
ENDCLASS.
