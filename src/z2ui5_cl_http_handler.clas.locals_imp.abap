    CLASS z2ui5_lcl_runtime DEFINITION DEFERRED.

    CLASS z2ui5_lcl_utility DEFINITION CREATE PUBLIC
    INHERITING FROM cx_no_check.

      PUBLIC SECTION.
        INTERFACES if_t100_dyn_msg.

*        TYPES:
*          BEGIN OF ty_property,
*            n TYPE string,
*            v TYPE string,
*          END OF ty_property.

*        TYPES:
*          BEGIN OF ty_control,
*            name       TYPE string,
*            ns         TYPE string,
*            t_property TYPE STANDARD TABLE OF ty_property WITH EMPTY KEY, "if_web_http_request=>name_value_pairs,
*            t_child    TYPE STANDARD TABLE OF REF TO data WITH EMPTY KEY,
*            parent     TYPE REF TO data,
*          END OF ty_control.

        TYPES:
          BEGIN OF ty_attri,
            name           TYPE string,
            kind           TYPE string,
            bind_type      TYPE string,
            data_stringify TYPE string,
          END OF ty_attri.

        TYPES:
          BEGIN OF ty,
            BEGIN OF s,
*              property TYPE ty_property,
*              control  TYPE ty_control,
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
              attri TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY,
*              property TYPE STANDARD TABLE OF ty_property WITH EMPTY KEY,
*              control  TYPE STANDARD TABLE OF REF TO ty_control WITH EMPTY KEY,
            END OF t,
            BEGIN OF o,
              me TYPE REF TO z2ui5_lcl_utility,
            END OF o,
          END OF ty.

        DATA:
          BEGIN OF ms_log,
            t_log TYPE STANDARD TABLE OF ty-s-msg_result WITH EMPTY KEY,
          END OF ms_log.

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
            textid   LIKE if_t100_message=>t100key OPTIONAL
            previous LIKE previous OPTIONAL
              PREFERRED PARAMETER val.

        METHODS get_text REDEFINITION.

        CLASS-METHODS x_factory_by
          IMPORTING
            x_root        TYPE REF TO cx_root
          RETURNING
            VALUE(result) TYPE ty-o-me.

        CLASS-METHODS get_classname_by_ref
          IMPORTING
            in              TYPE REF TO object
          RETURNING
            VALUE(r_result) TYPE string.

        CLASS-METHODS get_uuid
          RETURNING
                    VALUE(r_result) TYPE string
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
          EXPORTING
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
            ir_tab_to   TYPE REF TO data.
        CLASS-METHODS _get_t_attri
          IMPORTING
            io_app          TYPE REF TO object
            ir_attri        TYPE string "REF TO abap_attrdescr
          RETURNING
            VALUE(r_result) TYPE abap_attrdescr_tab.


      PROTECTED SECTION.
        CLASS-DATA mv_counter TYPE int4.

      PRIVATE SECTION.

    ENDCLASS.



    CLASS z2ui5_lcl_utility IMPLEMENTATION.


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

        mv_counter = mv_counter + 1.
        r_result = shift_left( shift_right( CONV string( mv_counter ) ) ).

      ENDMETHOD.





      METHOD get_xml_by_data.

        CALL TRANSFORMATION id
        SOURCE data = is_any "i_result->ms_db-data
        RESULT XML r_result.

      ENDMETHOD.


      METHOD get_t_attri_by_ref.

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


          DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( <back> ) ).

          LOOP AT lo_Struct->get_components( ) REFERENCE INTO DATA(lr_comp).

            ASSIGN COMPONENT lr_comp->name OF STRUCTURE <back> TO <comp>.
            IF sy-subrc NE 0.
              EXIT.
            ENDIF.
            ASSIGN COMPONENT lr_comp->name OF STRUCTURE <ui5_row> TO <comp_ui5>.
            IF sy-subrc NE 0.
              EXIT.
            ENDIF.
            <comp> = <comp_ui5>->*.
          ENDLOOP.
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

      METHOD x_factory_by.

        result = NEW #(  ).
        result->ms_error-x_root = x_root.
        result->ms_error-text = x_root->get_text( ).

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
          lv_element = lv_element && '-' && lr_comp->name.


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

    ENDCLASS.

    CLASS _ DEFINITION INHERITING FROM z2ui5_lcl_utility.
    ENDCLASS.

    CLASS z2ui5_lcl_ui5_library DEFINITION
      CREATE PUBLIC .

      PUBLIC SECTION.

        INTERFACES: z2ui5_if_ui5_library.

        CONSTANTS cs LIKE z2ui5_if_ui5_library=>cs VALUE z2ui5_if_ui5_library=>cs.
        DATA m_name TYPE string.
        DATA m_ns   TYPE string.
        DATA mt_prop TYPE STANDARD TABLE OF z2ui5_if_ui5_library=>ty-s_property WITH EMPTY KEY.

        DATA mt_attri  TYPE _=>ty-t-attri.
        DATA mo_app TYPE REF TO object.

        DATA m_root    TYPE REF TO z2ui5_lcl_ui5_library.
        DATA m_parent  TYPE REF TO z2ui5_lcl_ui5_library.
        DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_lcl_ui5_library WITH EMPTY KEY.

        CLASS-METHODS factory
          IMPORTING
            t_attri       TYPE _=>ty-t-attri
            o_app         TYPE REF TO z2ui5_if_app
          RETURNING
            VALUE(result) TYPE REF TO z2ui5_lcl_ui5_library.

        METHODS _generic
          IMPORTING
            name          TYPE string
            ns            TYPE string OPTIONAL
            t_prop        LIKE mt_prop OPTIONAL
          RETURNING
            VALUE(result) TYPE REF TO z2ui5_lcl_ui5_library.

        TYPES:
          BEGIN OF ty_S_view,
            xml     TYPE string,
            o_model TYPE REF TO z2ui5_cl_hlp_tree_json,
            t_attri TYPE _=>ty-t-attri,
          END OF ty_S_view.

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



    CLASS z2ui5_lcl_ui5_library IMPLEMENTATION.

      METHOD _get_name_by_ref.

        IF type = cs-bind_type-one_time.
          DATA(lv_id) = _=>get_uuid_session( ).
          INSERT VALUE #(
            name = lv_id
            data_stringify = _=>trans_any_2_json( value )
            bind_type = type
           ) INTO TABLE m_root->mt_attri.
*          r_result = '{/' && lv_id && '}'.
          r_result = '/' && lv_id && ''.
          RETURN.
        ENDIF.

        DATA(lr_in) = REF #( value ).

        LOOP AT m_root->mt_attri REFERENCE INTO DATA(lr_attri).

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = |M_ROOT->MO_APP->{ to_upper( lr_attri->name ) }|.
          ASSIGN (lv_name) TO <attribute>.
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
         ) INTO TABLE m_root->mt_attri.
*        r_result = '{/' && lv_id && '}'.
        r_result = '/' && lv_id && ''.

      ENDMETHOD.

      METHOD xml_get_begin.

        result = COND #(  WHEN check_popup_active = abap_false
                  THEN      `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
                         `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                                   ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` &&
                             COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `<Shell>` )
                  ELSE   `<core:FragmentDefinition   xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
                         `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                                   ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` ).

      ENDMETHOD.

      METHOD xml_get_end.

        result &&= COND #( WHEN check_popup_active = abap_false
                  THEN COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `</Shell>` ) && `</mvc:View>`
                  ELSE `</core:FragmentDefinition>` ).

      ENDMETHOD.

      METHOD xml_get.

        "case - root
        IF me = m_root.
          result = xml_get_begin( check_popup_active ).

          LOOP AT t_child INTO DATA(lr_child).
            result &&= lr_child->xml_get(  ).
          ENDLOOP.

          result &&= xml_get_end( check_popup_active ).
          RETURN.
        ENDIF.

        "case - normal
        CASE m_name.

          WHEN 'ZZHTML'.
            result = mt_prop[ n = 'VALUE' ]-v.
            RETURN.
        ENDCASE.

        result = |{ result } <{ COND #( WHEN m_ns <> '' THEN |{ m_ns }:| ) }{ m_name } \n {
                             REDUCE #( INIT val = `` FOR row IN  mt_prop WHERE ( v <> '' )
                              NEXT val = |{ val } { row-n }="{ escape( val = row-v  format = cl_abap_format=>e_xml_attr ) }" \n | ) }|.

        IF t_child IS INITIAL.
          result &&= '/>'.
          RETURN.
        ENDIF.

        result &&= '>'.

        LOOP AT t_child INTO lr_child.
          result &&= lr_child->xml_get(  ).
        ENDLOOP.

        result &&= |</{ COND #( WHEN m_ns <> '' THEN |{ m_ns }:| ) }{ m_name }>|.

      ENDMETHOD.

      METHOD _generic.

        result = NEW z2ui5_lcl_ui5_library( ).
        result->m_name = name.
        result->m_ns = ns.
        result->mt_prop = t_prop.
        result->m_parent = me.
        result->m_root   = m_root.
        INSERT result INTO TABLE t_child.

      ENDMETHOD.

      METHOD factory.

        result = NEW z2ui5_lcl_ui5_library( ).
        result->m_root = result.
        result->m_parent = result.
        result->mt_attri = t_attri.
        result->mo_app = o_app.

      ENDMETHOD.



      METHOD z2ui5_if_ui5_library~button.

        result = me.

        _generic(
           name   = 'Button'
           t_prop = VALUE #(
              ( n = 'press'   v = press )
                  ( n = 'text'    v = text )
              ( n = 'enabled' v = _=>get_abap_2_json( enabled ) )
              ( n = 'icon'    v = icon )
              ( COND #( WHEN type IS NOT INITIAL THEN VALUE #( n = 'type'  v = type ) ) )
           ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~input.

        result = _generic(
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
                  ) ).


      ENDMETHOD.

      METHOD get_view.

        result-xml = m_root->xml_get( check_popup_active ).

        DATA(m_view_model) = z2ui5_cl_hlp_tree_json=>factory( ).
        DATA(lo_update) = m_view_model->add_attribute_object( 'oUpdate' ).

        LOOP AT mt_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ''.

          IF lr_attri->bind_type = cs-bind_type-one_time.
            m_view_model->add_attribute(
                  n = lr_attri->name
                  v = lr_attri->data_stringify
                  apos_active = abap_false
               ).
            CONTINUE.
          ENDIF.

          DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs-bind_type-one_way THEN m_view_model
                                     ELSE lo_update ).

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = |M_PARENT->MO_APP->{ to_upper( lr_attri->name ) }|.
          ASSIGN (lv_name) TO <attribute>.

          CASE lr_attri->kind.

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
        DELETE m_root->mt_attri WHERE bind_type = cs-bind_type-one_time.
        result-t_attri = m_root->mt_attri.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~page.

        result = _generic(
            name   = 'Page'
             t_prop = VALUE #(
                 ( n = 'title' v = title )
                 ( n = 'showNavButton' v = COND #( WHEN nav_button_tap = '' THEN 'false' ELSE 'true' ) )
                 ( n = 'navButtonTap' v = nav_button_tap )
             ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~vbox.

        result = _generic(
             name   = 'VBox'
             t_prop = VALUE #(
                ( n = 'class' v = 'sapUiSmallMargin' )
               "( n = 'height' v = '10%' )
                 ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~simple_form.

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


      METHOD z2ui5_if_ui5_library~content.

        result = _generic(
            ns    = ns
           name   = 'content'
          ).

      ENDMETHOD.


      METHOD z2ui5_if_ui5_library~title.

        result = me.

        _generic(
             name  = 'Title'
             t_prop = VALUE #(
                 ( n = 'text' v = title ) )
            ) .

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~code_editor.

        result = me.

        _generic(
            name  = 'CodeEditor'
            ns = 'editor'
            t_prop = VALUE #(
                ( n = 'value'   v = _get_name_by_ref( value ) )
                ( n = 'type'    v = type )
                ( n = 'height'  v = '600px' )
             ) ) .

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~zz_html.

        "todo
        DATA(lv_html) = replace( val = val sub = '</' with = '#+´"?' occ   =   0 ).
        lv_html = replace( val = lv_html sub = '<' with = '<html:' occ   =   0 ).
        lv_html = replace( val = lv_html sub = '#+´"?' with = '</html:' occ   =   0 ).

        result = me.

        _generic(
          name  = 'ZZHTML'
          t_prop = VALUE #( ( n = 'VALUE' v = lv_html ) )
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

        result = _generic(
          name  = 'ComboBox'
          t_prop = VALUE #(
           (  n = 'showClearIcon' v = _=>get_abap_2_json( show_clear_icon ) )
           (  n = 'selectedKey'   v = selectedkey )
           (  n = 'items'         v = items )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~date_picker.

        result = me.

        _generic(
          name       = 'DatePicker'
          t_prop = VALUE #(
              ( n = 'value' v = value  )
              ( n = 'placeholder' v = placeholder )
           ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~date_time_picker.

        result = me.

        _generic(
            name  = 'DateTimePicker'
            t_prop = VALUE #(
                ( n = 'value' v =  value )
                ( n = 'placeholder'  v = placeholder  )
             ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~label.

        result = me.

        _generic(
           name  = 'Label'
           t_prop = VALUE #(
               ( n = 'text' v = text )
            ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~link.

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

      METHOD z2ui5_if_ui5_library~segmented_button.

        result = _generic(
           name  = 'SegmentedButton'
           t_prop = VALUE #(
            ( n = 'selectedKey' v = selected_key )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~step_input.

        result = me.

        _generic(
             name  = 'StepInput'
             t_prop = VALUE #(
                ( n = 'max'  v = max  )
                ( n = 'min'  v = min  )
                ( n = 'step' v = step )
                ( n = 'value' v = _get_name_by_ref( value )  )
         ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~switch.

        result = me.

        _generic(
              name  = 'Switch'
              t_prop = VALUE #(
                 ( n = 'type'           v = type           )
                 ( n = 'enabled'        v = _=>get_abap_2_json( enabled  )      )
                 ( n = 'state'          v = _get_name_by_ref( state ) )
                 ( n = 'customTextOff'  v = customtextoff  )
                 ( n = 'customTextOn'   v = customtexton   )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~text_area.

        result = me.

        _generic(
              name  = 'TextArea'
                t_prop = VALUE #(
                  ( n = 'value' v = value )
                  ( n = 'rows' v = rows )
                  ( n = 'height' v = height )
                  ( n = 'width' v = width )
              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~time_picker.

        result = me.

        _generic(
         name   = 'TimePicker'
         t_prop = VALUE #(
              ( n = 'value' v =  value  )
              ( n = 'placeholder'  v = placeholder  )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~checkbox.

        result = me.

        _generic(
           name  = 'CheckBox'
           t_prop = VALUE #(
              ( n = 'text'  v = text )
              ( n = 'selected' v = selected )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~progress_indicator.

        result = me.

        _generic(
             name  = 'ProgressIndicator'
             t_prop = VALUE #(
                ( n = 'percentValue' v = _get_name_by_ref( percent_value ) )
                ( n = 'displayValue' v = display_Value )
                ( n = 'showValue'    v = _=>get_abap_2_json( show_value  )      )
                ( n = 'state'        v = state  )
         ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~radiobutton_group.

*        result = me.
*
*        _generic(
*         name   = 'RadioButtonGroup'
*         t_prop = VALUE #(
*                 ( n = 'columns' v = lines( t_prop ) )
*                 ( n = 'selectedIndex' v = selected_index )
*         ) ).
*
*        LOOP AT t_prop REFERENCE INTO DATA(lr_prop).
*          DATA(lv_tabix) = sy-tabix - 1.
*
*          _generic(
*            name   = 'RadioButton'
*            t_prop = VALUE #(
*               ( n = 'text' v = lr_prop->* )
*             ) ).
*
*        ENDLOOP.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~text.

        result = me.

        _generic(
          name  = 'Text'
          t_prop = VALUE #( ( n = 'text' v = text ) )
         ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~table.

        result = _generic(
            name  = 'Table'
            t_prop = VALUE #(
               ( n = 'items' v = items )
               ( n = 'growing' v = 'true' )
               ( n = 'growingThreshold' v = growing_threshold )
            ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~cells.

        result = _generic(  'cells' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~column.

        result = me.
        DATA(lo_col) = _generic(
            name  = 'Column'
              t_prop = VALUE #( ( n = 'width' v = width ) )
         ).

        lo_col->z2ui5_if_ui5_library~text( text ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~columns.

        result = _generic(  'columns' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~column_list_item.

        result = _generic(
            name = 'ColumnListItem'
            t_prop = VALUE #( ( n = 'vAlign' v = valign ) )
             ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~items.

        result = _generic(  'items' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~grid.

        result = _generic(
            name = 'Grid'
            ns   = 'l'
            t_prop = VALUE #(
                ( n = 'defaultSpan' v = default_span )
                ( n = 'class'       v = class )
                ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~header_toolbar.

        result = _generic( 'headerToolbar' ).

      ENDMETHOD.



      METHOD z2ui5_if_ui5_library~scroll_container.

        result = _generic(
             name = 'ScrollContainer'
             "  ns   = 'l'
            t_prop = VALUE #(
              ( n = 'height' v = height )
              ( n = 'width'       v = width )
              ( n = 'vertical'       v = 'true' )
              ( n = 'focusable'       v = 'true' )
              ) ).

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

        result = _generic(
             name = 'Dialog'
             "  ns   = 'l'
            t_prop = VALUE #(
              ( n = 'title'  v = title )
              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~table_select_dialog.

*        result = _generic(
*             name = 'TableSelectDialog'
*            t_prop = VALUE #(
*              ( n = 'title' v = title )
*              ( n = 'confirm'      v = _get_event_method( ` $event , { 'ID' : '` && event_id_confirm && `' } )` ) )
*              ( n = 'cancel'       v = _get_event_method( `{ 'ID' : '` && event_id_cancel && `' }` ) )
*              ( n = 'items' v = '{' && _get_name_by_ref( value = items ) && '}' )
*              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~list.

        result = _generic(
              name = 'List'
             t_prop = VALUE #(
               ( n = 'headerText' v = header_text )
               ( n = 'items' v = '{' && _get_name_by_ref( items ) && '}' )
               ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~standard_list_item.

        result = _generic(
          name = 'StandardListItem'
         t_prop = VALUE #(
           ( n = 'title' v = title )
           ( n = 'description' v = description )
           ( n = 'icon' v = icon )
               ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~message_page.

        result = _generic(
          name = 'MessagePage'
         t_prop = VALUE #(
           ( n = 'showHeader' v = _=>get_abap_2_json( show_header ) )
           ( n = 'description' v = description )
           ( n = 'icon' v = icon )
           ( n = 'text' v = text )
           ( n = 'enableFormattedText' v =  _=>get_abap_2_json( enable_formatted_text ) )
          ) ).


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

        _generic(
          name = 'MessageStrip'
         t_prop = VALUE #(
           ( n = 'text' v = text )
           ( n = 'type' v = type )
           ( n = 'class' v = class )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~_event.

        "  CASE type.

        "   WHEN cs-event_type-server_function.
        result = `onEvent( { 'EVENT' : '` && val && `', 'METHOD' : 'UPDATE' } )`.

        "  ENDCASE.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~_event_display_id.
        result = `onEvent( { 'ID' : '` && val && `', 'METHOD' : 'DISPLAY_ID' } )`.
      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~list_item.

        result = me.

        _generic(
                   name   = 'ListItem'
                   ns     = 'core'
                   t_prop = VALUE #(
                          ( n = 'text' v = text )
                          ( n = 'additionalText' v = additional_text ) ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~suggestion_items.

        result = _generic( 'suggestionItems' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~item.

        result = me.

        _generic(
        name = 'Item'
        ns = 'core'
        t_prop = VALUE #(
           ( n = 'key'  v = key  )
           ( n = 'text' v =  text )
       ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~segmented_button_item.

        result = me.

        _generic(
         name = 'SegmentedButtonItem'
         t_prop = VALUE #(
        ( n = 'icon'  v = icon  )
        ( n = 'key'   v = key )
        ( n = 'text'  v = text )
        ) ).


      ENDMETHOD.

    ENDCLASS.

    CLASS z2ui5_lcl_app_system DEFINITION.

      PUBLIC SECTION.

        INTERFACES  z2ui5_if_app.

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
            app             TYPE REF TO z2ui5_if_app OPTIONAL
            kind            TYPE string OPTIONAL
            "  server          TYPE REF TO z2ui5_lcl_runtime
          RETURNING
            VALUE(r_result) TYPE REF TO  z2ui5_lcl_app_system.

        TYPES: BEGIN OF ty_row,
                 id          TYPE string,
                 name        TYPE string,
                 value       TYPE string,
                 test1       TYPE string,
                 test2       TYPE string,
                 check_valid TYPE abap_bool,
               END OF ty_row.

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

    CLASS z2ui5_lcl_app_system IMPLEMENTATION.

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
        r_result->ms_error-app     = app.
        r_result->ms_error-kind    = kind.

      ENDMETHOD.


      METHOD z2ui5_on_init.
        IF ms_error-x_error IS NOT BOUND.
          client->display_view( 'HOME' ).
          ms_home-is_initialized = abaP_true.
          ms_home-btn_text = 'check'.
          ms_home-btn_event_id = 'BUTTON_CHECK'.
          ms_home-class_editable = abap_true.
          ms_home-btn_icon = 'sap-icon://validate'.
        ELSE.
          client->display_view( 'ERROR' ).
        ENDIF.

        " ms_home-classname = 'test'.
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
                    ms_home-classname = to_upper( ms_home-classname ).
                    CREATE OBJECT li_app_test TYPE (ms_home-classname).

                    client->display_message_toast( 'App is ready to start!' ).
                    ms_home-btn_text = 'edit'.
                    ms_home-btn_event_id = 'BUTTON_CHANGE'.
                    ms_home-btn_icon = 'sap-icon://edit'.
                    ms_home-class_value_state = z2ui5_if_client=>cs-input-value_state-success.
                    ms_home-class_editable = abap_false.

                  CATCH cx_root INTO DATA(lx).
                    ms_home-class_value_state_text = lx->get_text( ).
                    ms_home-class_value_state = z2ui5_if_client=>cs-input-value_state-warning.
                    client->display_message_box(
                        text = ms_home-class_value_state_text
                        type = z2ui5_if_client=>cs-message_box-type-error
                         ).
                ENDTRY.

              WHEN '0101'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_01( ) ).

              WHEN '0102'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_04( ) ).

              WHEN '0103'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_08( ) ).

              WHEN '0104'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_10( ) ).

              WHEN '0201'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_02( ) ).

              WHEN '0202'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_05( ) ).

              WHEN '0301'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_03( ) ).

              WHEN '0302'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_04( ) ).

              WHEN '0303'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_06( ) ).

              WHEN '0304'.
                client->nav_to_app( NEW zz2ui5_cl_app_demo_11( ) ).

            ENDCASE.

          WHEN 'ERROR'.
            CASE client->get( )-event.

              WHEN 'BUTTON_HOME'.
                client->nav_to_app( NEW z2ui5_lcl_app_system( ) ).
            ENDCASE.
        ENDCASE.

        "client->display_view( client->get( )-screen_active ).
      ENDMETHOD.


      METHOD z2ui5_on_rendering.

        DATA(view) = client->factory_view( 'HOME' ).

        DATA(page) = view->page( 'Welcome to ABAP2UI5! - Development of UI5 Apps in pure ABAP' ).
        page->header_content(
            )->link( text = 'Twitter' href = 'https://twitter.com/OblomovDev'
            )->link( text = 'GitHub' href = 'https://github.com/oblomov-dev/abap2ui5'
        ).

        DATA(lo_grid) = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).
        DATA(lo_form) = lo_grid->simple_form( 'Quick Start' )->content( 'f' ).

        lo_form->label( 'Step 1'
          )->text( 'Create a new global class in the abap system'
          )->label( 'Step 2'
          )->text( 'Add the interface Z2UI5_IF_APP'
          )->label( 'Step 3'
          )->text( 'Implement the view and the behaviour in the controller method'
          )->label( 'Step 4'
        ).

        IF ms_home-class_editable = abap_true.
          lo_form->input(
                         value          = lo_form->_bind( ms_home-classname )
                         placeholder    = 'fill in the classname and press check'
                         value_state      = ms_home-class_value_state
                         value_state_text = ms_home-class_value_state_text
                         editable         = ms_home-class_editable
                    ).
        ELSE.
          lo_form->text( ms_home-classname ).
        ENDIF.

        lo_form->button( text = ms_home-btn_text press = view->_event( ms_home-btn_event_id ) icon = ms_home-btn_icon   "type = view->cs-button-type-
                 )->label( 'Step 5' ).

        IF ms_home-class_editable = abap_false.
          DATA(lv_link) = client->get( )-s_request-url_app_gen && ms_home-classname.
          lo_form->link( text = 'Link to the Application'
                  href = lv_link " 'https://' && lv_url && '' && '?sap-client=' && lv_tenant && '&amp;app=' && ms_home-classname
               ).
        ENDIF.


        lo_grid = page->grid( default_span  = 'L4 M6 S12' )->content( 'l' ).

        lo_grid->simple_form(  'HowTo - General' )->content( 'f'
            )->button( text = 'Client-Server Communication (Data Binding)' press = view->_event( '0101' )
            )->button( text = 'Controller (Events, Navigation)' press = view->_event( '0102' )
            )->button( text = 'Messages (Toast, Box, Strip, Error)' press = view->_event( '0103' )
            )->button( text = 'Layout (Header, Footer, Grid)' press = view->_event( '0104' ) ).

        lo_grid->simple_form(  'HowTo - Selection-Screen' )->content( 'f'
            )->button( text = 'Basic' press = view->_event( '0201' )
            )->button( text = 'More Controls' press = view->_event( '0202' ) ).


        lo_form = lo_grid->simple_form(  'HowTo - Table and List' )->content( 'f'
            )->button( text = 'List' press = view->_event( '0301' )
            )->button( text = 'Table' press = view->_event( '0302' )
            )->button( text = 'Table with Toolbar, Icons, Checkbox' press = view->_event( '0303' )
            )->button( text = 'Table Editable' press = view->_event( '0304' ) ).


        IF ms_error-x_error IS BOUND.
          view = client->factory_view( 'ERROR' ).
          view->message_page(
              text = ms_error-classname
              description = ms_error-x_error->get_text( )
              )->buttons(
            )->button(
                  text  = 'HOME'
                  press = view->_event( 'BUTTON_HOME' )
            )->button(
                  text = 'BACK'
                  press = view->_event_display_id( client->get( )-id_prev_app )
                  type = view->cs-button-type-emphasized
            ).
        ENDIF.

      ENDMETHOD.

    ENDCLASS.

    CLASS z2ui5_lcl_client DEFINITION.

      PUBLIC SECTION.

        INTERFACES z2ui5_if_client.

        DATA mo_server TYPE REF TO z2ui5_lcl_runtime.

        METHODS constructor
          IMPORTING
            i_server TYPE REF TO z2ui5_lcl_runtime.

    ENDCLASS.


    CLASS z2ui5_lcl_runtime DEFINITION.

      PUBLIC SECTION.

        TYPES:
          BEGIN OF s_screen,
            name          TYPE string,
            check_binding TYPE abap_bool,
            o_parser      TYPE REF TO z2ui5_lcl_ui5_library,
*            t_controls    TYPE STANDARD TABLE OF _=>ty-s-control WITH EMPTY KEY,
          END OF s_screen.

        DATA:
          BEGIN OF ms_control,
            event_type TYPE string,
          END OF ms_control.

        DATA:
          BEGIN OF ms_db,
            id                TYPE string,
            id_prev           TYPE string,
            id_prev_app       TYPE string,
            app               TYPE string,
            screen            TYPE string,
            check_no_rerender TYPE abap_bool,
            screen_popup      TYPE string,
            t_attri           TYPE _=>ty-t-attri,
            o_app             TYPE REF TO object,
          END OF ms_db.

        DATA mt_after TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.
        DATA mt_screen TYPE STANDARD TABLE OF s_screen.
        DATA ms_leave_to_app LIKE ms_db.

        METHODS constructor RAISING cx_uuid_error.

        METHODS db_save
          IMPORTING
            response TYPE string OPTIONAL.

        METHODS db_load
          IMPORTING
            id              TYPE string
          RETURNING
            VALUE(r_result) LIKE ms_db.

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
            VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime.

        METHODS factory_new
          IMPORTING
            i_app           TYPE REF TO z2ui5_if_app
          RETURNING
            VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime.



      PRIVATE SECTION.

    ENDCLASS.

    CLASS z2ui5_lcl_runtime IMPLEMENTATION.

      METHOD constructor.

        ms_db-id = _=>get_uuid( ).

      ENDMETHOD.

      METHOD db_load.

        SELECT SINGLE FROM z2ui5_t_draft
            FIELDS
                data
           WHERE uuid = @id
          INTO @DATA(lv_data).

        _=>trans_xml_2_object(
          EXPORTING
            xml    = lv_data
           IMPORTING
            data   = r_result
        ).

      ENDMETHOD.

      METHOD db_save.

        MODIFY z2ui5_t_draft FROM @( VALUE #(
          uuid  = ms_db-id
          uname = _=>get_user_tech( )
          timestampl = _=>get_timestampl( )
          response = response
          data  = _=>trans_object_2_xml( REF #( ms_db ) )
          ) ).
        COMMIT WORK.

      ENDMETHOD.


      METHOD execute_init.

        TRY.
            ms_db-id_prev = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'ID')->get_val( ).
          CATCH cx_root.
            init_app_new( ).
            RETURN.
        ENDTRY.

        TRY.
            DATA(lv_method_event) = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'METHOD' )->get_val( ).
            IF lv_method_event = 'DISPLAY_ID'.

              SELECT SINGLE FROM z2ui5_t_draft
                  FIELDS
                      *
                 WHERE uuid = @( z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'ID' )->get_val( ) )
                INTO @DATA(ls_db).
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
                CAST z2ui5_if_app( ms_db-o_app )->controller( NEW z2ui5_lcl_client( me ) ).
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

        DATA(x) = COND i( WHEN lines( mt_screen ) = 0 THEN THROW _( 'no view defined in method set_view' ) ).

        IF ms_db-screen IS INITIAL.
          DATA(lr_screen) = REF #( mt_screen[ 1 ] ).
          ms_db-screen = lr_screen->name.
        ELSE.
          lr_screen = REF #( mt_screen[ name = ms_db-screen ] ).
        ENDIF.


        DATA(lo_ui5_model) = z2ui5_cl_hlp_tree_json=>factory( ).

        DATA(ls_view) = lr_screen->o_parser->get_view(  ).
        ms_db-t_attri = ls_view-t_attri.
        lo_ui5_model->add_attribute( n = `vView` v = ls_view-xml ).
        ls_view-o_model->mv_name = 'oViewModel'.
        lo_ui5_model->add_attribute_instance( ls_view-o_model ).


        DATA(lo_system) = lo_ui5_model->add_attribute_object( 'oSystem' ).
        lo_system->add_attribute( n = 'ID' v = ms_db-id ).
        " lo_system->add_attribute( n = 'ID_PREV' v = ms_db-id_prev ).
        " lo_system->add_attribute( n = 'ID_PREV_APP' v = ms_db-id_prev_app ).
        "    lo_ui5_model->add_attribute( n = 'CHECK_POPUP_ACTIVE' v = ''  apos_active = abap_false ).
        lo_system->add_attribute( n = 'CHECK_DEBUG_ACTIVE' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-check_debug_mode )  apos_active = abap_false ).


        IF mt_after IS NOT INITIAL.
          DATA(lo_list) = lo_ui5_model->add_attribute_list( 'oAfter' ).
          LOOP AT mt_after REFERENCE INTO DATA(lr_after).
            DATA(lo_list2) = lo_list->add_list_list(  ).
            LOOP AT lr_after->* REFERENCE INTO DATA(lr_con).
              lo_list2->add_list_val( lr_con->* ).
            ENDLOOP.
          ENDLOOP.
        ENDIF.

        r_result = lo_ui5_model->get_root( )->write_result( ).


      ENDMETHOD.


      METHOD init_app_prev.

        ms_db = CORRESPONDING #( BASE ( ms_db ) db_load( ms_db-id_prev ) EXCEPT id id_prev ).

        LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
            WHERE bind_type = z2ui5_if_ui5_library=>cs-bind_type-two_way. " check_used = abap_true AND check_update = abap_true.

          lr_attri->bind_type = ''.

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
          ASSIGN (lv_name) TO <attribute>.

          CASE lr_attri->kind.

            WHEN 'g' OR 'I' OR 'C'.
              DATA(lv_value) = z2ui5_cl_http_handler=>client-o_body->get_attribute( lr_attri->name )->get_val( ).
              <attribute> = lv_value.

            WHEN 'h'.
              _=>trans_ref_tab_2_tab(
                         ir_tab_from = z2ui5_cl_http_handler=>client-o_body->get_attribute( lr_attri->name )->mr_actual
                         ir_tab_to   = REF #( <attribute> )          ).

          ENDCASE.

        ENDLOOP.

        ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_event.
      ENDMETHOD.


      METHOD init_app_new.
        DO.
          TRY.

              z2ui5_cl_http_handler=>client-t_param = VALUE #( LET tab = z2ui5_cl_http_handler=>client-t_param IN FOR row IN tab
                ( name = to_upper( row-name ) value = to_upper( row-value ) ) ).

              TRY.
                  ms_db-app = z2ui5_cl_http_handler=>client-t_param[ name = 'APP' ]-value.
                CATCH cx_root.
                  ms_db-o_app = NEW z2ui5_lcl_app_system( ).
                  EXIT.
              ENDTRY.

              CREATE OBJECT ms_db-o_app TYPE (ms_db-app).
              EXIT.

            CATCH cx_root.
              DATA(lo_error) = NEW z2ui5_lcl_app_system( ).
              lo_error->ms_error-x_error = NEW _( val = `Class with name ` && ms_db-app && ` not found. Please check your repository.` ).
              ms_db-o_app = CAST #( lo_error ).
              EXIT.
          ENDTRY.
        ENDDO.

        ms_db-app     = _=>get_classname_by_ref( ms_db-o_app ).
        ms_db-t_attri = _=>get_t_attri_by_ref( ms_db-o_app ).

        ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_init.

      ENDMETHOD.

      METHOD factory_new.

        r_result = NEW z2ui5_lcl_runtime( ).
        r_result->ms_db-o_app = i_app.
        r_result->ms_db-app = _=>get_classname_by_ref( i_app ).
        CLEAR z2ui5_cl_http_handler=>client-o_body.
        r_result->mt_after = mt_after.
        r_result->ms_db-t_attri = _=>get_t_attri_by_ref( r_result->ms_db-o_app ).

      ENDMETHOD.

      METHOD factory_new_error.

        r_result = factory_new(
                 z2ui5_lcl_app_system=>factory_error( error = ix app = CAST #( me->ms_db-o_app ) kind = kind ) ).

        r_result->ms_control-event_type = z2ui5_if_client=>cs-lifecycle_method-on_init.
      ENDMETHOD.

    ENDCLASS.

    CLASS z2ui5_lcl_client IMPLEMENTATION.

      METHOD constructor.

        me->mo_server = i_server.

      ENDMETHOD.


      METHOD z2ui5_if_client~display_message_toast.

        INSERT VALUE #( ( `MessageToast` ) ( `show` ) ( text ) )
             INTO TABLE mo_server->mt_after.

      ENDMETHOD.

      METHOD z2ui5_if_client~display_message_box.

        INSERT VALUE #( ( `MessageBox` ) ( type ) ( text ) )
          INTO TABLE mo_server->mt_after.

      ENDMETHOD.

      METHOD z2ui5_if_client~display_view.

        mo_server->ms_db-screen = val.
        mo_server->ms_db-check_no_rerender = check_no_rerender.

      ENDMETHOD.

      METHOD z2ui5_if_client~factory_view.

        result = z2ui5_lcl_ui5_library=>factory(
            t_attri = mo_server->ms_db-t_attri
            o_app   = CAST #( mo_server->ms_db-o_app )
             ).
        INSERT VALUE #( name = name o_parser = CAST #(  result  ) ) INTO TABLE mo_server->mt_screen.

      ENDMETHOD.

      METHOD z2ui5_if_client~nav_to_home.

        z2ui5_if_client~nav_to_app( NEW z2ui5_lcl_app_system( ) ).

      ENDMETHOD.

      METHOD z2ui5_if_client~get.

        result = VALUE #(
            lifecycle_method = mo_server->ms_control-event_type
            check_previous_app = xsdbool( mo_server->ms_db-id_prev_app IS NOT INITIAL )
            view_active = mo_server->ms_db-screen
            id = mo_server->ms_db-id
            id_prev = mo_server->ms_db-id_prev
            id_prev_app = mo_server->ms_db-id_prev_app
        ).

        DATA(lt_head) = z2ui5_cl_http_handler=>client-t_header.
        DATA(lv_url) = lt_head[ name = 'referer' ]-value.

        result-s_request-tenant = sy-mandt.
        result-s_request-url_app = lv_url && '?sap-client=' && result-s_request-tenant && '&app=' && mo_server->ms_db-app.
        result-s_request-url_app_gen = lv_url && '?sap-client=' && result-s_request-tenant && '&app='.
        result-s_request-origin = lt_head[ name = 'origin' ]-value.
        result-s_request-url_source_code = result-s_request-origin && `/sap/bc/adt/oo/classes/` && mo_server->ms_db-app && `/source/main`.

        TRY.
            result-event = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'EVENT' )->get_val( ).
          CATCH cx_root.
        ENDTRY.

      ENDMETHOD.

      METHOD z2ui5_if_client~get_app_previous.

        DATA(x) = COND i( WHEN mo_server->ms_db-id_prev_app IS INITIAL THEN THROW _('CX_STACK_EMPTY - NO CALLING APP FOUND') ).
        result = CAST #( mo_server->db_load( mo_server->ms_db-id_prev_app )-o_app ).

      ENDMETHOD.

      METHOD z2ui5_if_client~nav_to_app.

        mo_server->ms_leave_to_app = VALUE #( o_app = app ).

      ENDMETHOD.

      METHOD z2ui5_if_client~display_popup.

        "coming soon
*        mo_server->ms_db-screen_popup = name.

      ENDMETHOD.

    ENDCLASS.
