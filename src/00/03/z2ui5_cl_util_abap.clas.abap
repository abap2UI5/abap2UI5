CLASS z2ui5_cl_util_abap DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    " abap-api - Serving a Release & Version Independent ABAP Layer
    " version: '0.0.1'.
    " origin: https://github.com/oblomov-dev/abap-api
    " author: https://github.com/oblomov-dev
    " license: MIT.

    TYPES:
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_dfies,
        tabname     TYPE c LENGTH 30,
        fieldname   TYPE c LENGTH 30,
        langu       TYPE string,
        position    TYPE n LENGTH 4,
        offset      TYPE n LENGTH 6,
        domname     TYPE c LENGTH 30,
        rollname    TYPE c LENGTH 30,
        checktable  TYPE c LENGTH 30,
        leng        TYPE n LENGTH 6,
        intlen      TYPE n LENGTH 6,
        outputlen   TYPE n LENGTH 6,
        decimals    TYPE n LENGTH 6,
        datatype    TYPE c LENGTH 4,
        inttype     TYPE c LENGTH 1,
        reftable    TYPE c LENGTH 30,
        reffield    TYPE c LENGTH 30,
        precfield   TYPE c LENGTH 30,
        authorid    TYPE c LENGTH 3,
        memoryid    TYPE c LENGTH 20,
        logflag     TYPE c LENGTH 1,
        mask        TYPE c LENGTH 20,
        masklen     TYPE n LENGTH 4,
        convexit    TYPE c LENGTH 5,
        headlen     TYPE n LENGTH 2,
        scrlen1     TYPE n LENGTH 2,
        scrlen2     TYPE n LENGTH 2,
        scrlen3     TYPE n LENGTH 2,
        fieldtext   TYPE c LENGTH 60,
        reptext     TYPE c LENGTH 55,
        scrtext_s   TYPE c LENGTH 10,
        scrtext_m   TYPE c LENGTH 20,
        scrtext_l   TYPE c LENGTH 40,
        keyflag     TYPE c LENGTH 1,
        lowercase   TYPE c LENGTH 1,
        mac         TYPE c LENGTH 1,
        genkey      TYPE c LENGTH 1,
        noforkey    TYPE c LENGTH 1,
        valexi      TYPE c LENGTH 1,
        noauthch    TYPE c LENGTH 1,
        sign        TYPE c LENGTH 1,
        dynpfld     TYPE c LENGTH 1,
        f4availabl  TYPE c LENGTH 1,
        comptype    TYPE c LENGTH 1,
        lfieldname  TYPE c LENGTH 132,
        ltrflddis   TYPE c LENGTH 1,
        bidictrlc   TYPE c LENGTH 1,
        outputstyle TYPE n LENGTH 2,
        nohistory   TYPE c LENGTH 1,
        ampmformat  TYPE c LENGTH 1,
      END OF ty_s_dfies,
      ty_t_dfies TYPE STANDARD TABLE OF ty_s_dfies WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_data_element_text,
        header TYPE string,
        short  TYPE string,
        medium TYPE string,
        long   TYPE string,
      END OF ty_s_data_element_text.

    TYPES:
      BEGIN OF ty_s_class_descr,
        classname   TYPE string,
        description TYPE string,
      END OF ty_s_class_descr.
    TYPES ty_t_classes TYPE STANDARD TABLE OF ty_s_class_descr WITH NON-UNIQUE DEFAULT KEY.

    CLASS-METHODS context_check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS source_get_method
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS uuid_get_c22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        i_data_element_name TYPE string
      RETURNING
        VALUE(result)       TYPE ty_s_data_element_text.

    CLASS-METHODS conv_decode_x_base64
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_encode_x_base64
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_string_by_xstring
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS conv_get_xstring_by_string
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_classes.

    CLASS-METHODS rtti_get_t_dfies_by_table_name
      IMPORTING
        table_name    TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies.

    CLASS-METHODS rtti_get_t_fixvalues
      IMPORTING
        elemdescr     TYPE REF TO cl_abap_elemdescr
        langu         TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_fix_val.

  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        i_classname   TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_t_attri_on_prem
      IMPORTING
        tabname       TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies.

    CLASS-METHODS rtti_get_t_attri_on_cloud
      IMPORTING
        tabname       TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies ##NEEDED.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_util_abap IMPLEMENTATION.
  METHOD context_check_abap_cloud.

    TRY.
        cl_abap_typedescr=>describe_by_name( 'T100' ).
        result = abap_false.
      CATCH cx_root.
        result = abap_true.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_t_fixvalues.

    TYPES:
      BEGIN OF fixvalue,
        low        TYPE c LENGTH 10,
        high       TYPE c LENGTH 10,
        option     TYPE c LENGTH 2,
        ddlanguage TYPE c LENGTH 1,
        ddtext     TYPE c LENGTH 60,
      END OF fixvalue.
    TYPES fixvalues TYPE STANDARD TABLE OF fixvalue WITH DEFAULT KEY.
    DATA lt_values TYPE fixvalues.

    DATA lv_langu TYPE c LENGTH 1.
    DATA temp1 LIKE LINE OF lt_values.
    DATA lr_fix LIKE REF TO temp1.
      DATA temp2 TYPE z2ui5_cl_util_abap=>ty_s_fix_val.
    lv_langu = ' '.
    lv_langu = langu.

    CALL METHOD elemdescr->('GET_DDIC_FIXED_VALUES')
      EXPORTING  p_langu        = lv_langu
      RECEIVING  p_fixed_values = lt_values
      EXCEPTIONS not_found      = 1
                 no_ddic_type   = 2
                 OTHERS         = 3.



    LOOP AT lt_values REFERENCE INTO lr_fix.


      CLEAR temp2.
      temp2-low = lr_fix->low.
      temp2-high = lr_fix->high.
      temp2-descr = lr_fix->ddtext.
      INSERT temp2
             INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD conv_decode_x_base64.
        DATA lv_web_http_name TYPE c LENGTH 19.
        DATA classname TYPE c LENGTH 15.

    TRY.


        lv_web_http_name = 'CL_WEB_HTTP_UTILITY'.
        CALL METHOD (lv_web_http_name)=>('DECODE_X_BASE64')
          EXPORTING encoded = val
          RECEIVING decoded = result.

      CATCH cx_root.


        classname = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>('DECODE_X_BASE64')
          EXPORTING encoded = val
          RECEIVING decoded = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_encode_x_base64.
        DATA lv_web_http_name TYPE c LENGTH 19.
        DATA classname TYPE c LENGTH 15.

    TRY.


        lv_web_http_name = 'CL_WEB_HTTP_UTILITY'.
        CALL METHOD (lv_web_http_name)=>('ENCODE_X_BASE64')
          EXPORTING unencoded = val
          RECEIVING encoded   = result.

      CATCH cx_root.


        classname = 'CL_HTTP_UTILITY'.
        CALL METHOD (classname)=>('ENCODE_X_BASE64')
          EXPORTING unencoded = val
          RECEIVING encoded   = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_string_by_xstring.

    DATA conv TYPE REF TO object.
        DATA conv_codepage TYPE c LENGTH 21.
        DATA conv_in_class TYPE c LENGTH 18.

    TRY.

        conv_codepage = 'CL_ABAP_CONV_CODEPAGE'.
        CALL METHOD (conv_codepage)=>create_in
          RECEIVING instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_IN~CONVERT')
          EXPORTING source = val
          RECEIVING result = result.

      CATCH cx_root.


        conv_in_class = 'CL_ABAP_CONV_IN_CE'.
        CALL METHOD (conv_in_class)=>create
          EXPORTING encoding = 'UTF-8'
          RECEIVING conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING input = val
          IMPORTING data  = result.
    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_xstring_by_string.

    DATA conv TYPE REF TO object.
        DATA conv_codepage TYPE c LENGTH 21.
        DATA conv_out_class TYPE c LENGTH 19.

    TRY.

        conv_codepage = 'CL_ABAP_CONV_CODEPAGE'.
        CALL METHOD (conv_codepage)=>create_out
          RECEIVING instance = conv.

        CALL METHOD conv->('IF_ABAP_CONV_OUT~CONVERT')
          EXPORTING source = val
          RECEIVING result = result.

      CATCH cx_root.


        conv_out_class = 'CL_ABAP_CONV_OUT_CE'.
        CALL METHOD (conv_out_class)=>create
          EXPORTING encoding = 'UTF-8'
          RECEIVING conv     = conv.

        CALL METHOD conv->('CONVERT')
          EXPORTING data   = val
          IMPORTING buffer = result.
    ENDTRY.

  ENDMETHOD.

  METHOD source_get_method.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_source TYPE string_table.
    DATA lt_string TYPE string_table.
        DATA lv_class TYPE string.
        DATA lv_method TYPE string.
        DATA xco_cp_abap TYPE c LENGTH 11.
        DATA lv_name TYPE c LENGTH 13.
        DATA lv_check_method LIKE abap_false.
        DATA lv_source LIKE LINE OF lt_source.
          DATA lv_source_upper TYPE string.

    TRY.


        lv_class  = to_upper( iv_classname ).

        lv_method = to_upper( iv_methodname ).


        xco_cp_abap = 'XCO_CP_ABAP'.
        CALL METHOD (xco_cp_abap)=>('CLASS')
          EXPORTING iv_name  = lv_class
          RECEIVING ro_class = object.

        ASSIGN ('OBJECT->IF_XCO_AO_CLASS~IMPLEMENTATION') TO <any>.
        ASSERT sy-subrc = 0.
        object = <any>.

        CALL METHOD object->('IF_XCO_CLAS_IMPLEMENTATION~METHOD')
          EXPORTING iv_name   = lv_method
          RECEIVING ro_method = object.

        CALL METHOD object->('IF_XCO_CLAS_I_METHOD~CONTENT')
          RECEIVING ro_content = object.

        CALL METHOD object->('IF_XCO_CLAS_I_METHOD_CONTENT~GET_SOURCE')
          RECEIVING rt_source = result.

      CATCH cx_root.


        lv_name = 'CL_OO_FACTORY'.
        CALL METHOD (lv_name)=>('CREATE_INSTANCE')
          RECEIVING result = object.

        CALL METHOD object->('IF_OO_CLIF_SOURCE_FACTORY~CREATE_CLIF_SOURCE')
          EXPORTING clif_name = lv_class
          RECEIVING result    = object.

        CALL METHOD object->('IF_OO_CLIF_SOURCE~GET_SOURCE')
          IMPORTING source = lt_source.


        lv_check_method = abap_false.

        LOOP AT lt_source INTO lv_source.

          lv_source_upper = to_upper( lv_source ).

          IF lv_source_upper CS `ENDMETHOD`.
            lv_check_method = abap_false.
          ENDIF.

          IF lv_source_upper CS |METHOD { lv_method }|.
            lv_check_method = abap_true.
            CONTINUE.
          ENDIF.

          IF lv_check_method = abap_true.
            INSERT lv_source INTO TABLE lt_string.
          ENDIF.

        ENDLOOP.

    ENDTRY.

    result = lt_string.

  ENDMETHOD.

  METHOD rtti_get_classes_impl_intf.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    TYPES BEGIN OF ty_s_impl.
    TYPES   clsname    TYPE c LENGTH 30.
    TYPES   refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
    TYPES BEGIN OF ty_s_key.
    TYPES   intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
    DATA BEGIN OF ls_clskey.
    DATA   clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA class TYPE REF TO data.
        DATA xco_cp_abap TYPE c LENGTH 11.
        DATA temp3 TYPE z2ui5_cl_util_abap=>ty_t_classes.
        DATA implementation_name LIKE LINE OF lt_implementation_names.
          DATA temp4 LIKE LINE OF temp3.
        DATA lv_fm TYPE string.
        DATA type TYPE c LENGTH 12.
        FIELD-SYMBOLS <class> TYPE data.
        DATA temp5 LIKE LINE OF lt_impl.
        DATA lr_impl LIKE REF TO temp5.
          FIELD-SYMBOLS <description> TYPE any.
          DATA temp6 TYPE z2ui5_cl_util_abap=>ty_s_class_descr.

    TRY.

        ls_clskey-clsname = val.


        xco_cp_abap = 'XCO_CP_ABAP'.
        CALL METHOD (xco_cp_abap)=>interface
          EXPORTING iv_name      = ls_clskey-clsname
          RECEIVING ro_interface = obj.

        ASSIGN obj->('IF_XCO_AO_INTERFACE~IMPLEMENTATIONS') TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        ASSIGN obj->('IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL') TO <any>.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
        ENDIF.
        obj = <any>.

        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES')
          RECEIVING rt_names = lt_implementation_names.


        CLEAR temp3.

        LOOP AT lt_implementation_names INTO implementation_name.

          temp4-classname = implementation_name.
          temp4-description = rtti_get_class_descr_on_cloud( implementation_name ).
          INSERT temp4 INTO TABLE temp3.
        ENDLOOP.
        result = temp3.

      CATCH cx_root.

        ls_key-intkey = val.


        lv_fm = `SEO_INTERFACE_IMPLEM_GET_ALL`.
        CALL FUNCTION lv_fm
          EXPORTING  intkey       = ls_key
          IMPORTING  impkeys      = lt_impl
          EXCEPTIONS not_existing = 1
                     OTHERS       = 2.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        type = 'SEOC_CLASS_R'.
        CREATE DATA class TYPE (type).

        ASSIGN class->* TO <class>.



        LOOP AT lt_impl REFERENCE INTO lr_impl.

          CLEAR <class>.

          ls_clskey-clsname = lr_impl->clsname.

          lv_fm = `SEO_CLASS_READ`.
          CALL FUNCTION lv_fm
            EXPORTING clskey = ls_clskey
            IMPORTING class  = <class>.


          ASSIGN
            COMPONENT 'DESCRIPT'
            OF STRUCTURE <class>
            TO <description>.
          ASSERT sy-subrc = 0.


          CLEAR temp6.
          temp6-classname = lr_impl->clsname.
          temp6-description = <description>.
          INSERT
            temp6
            INTO TABLE result.
        ENDLOOP.

    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    DATA ddic_ref     TYPE REF TO data.
    DATA data_element TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA: BEGIN OF ddic,
            reptext   TYPE string,
            scrtext_s TYPE string,
            scrtext_m TYPE string,
            scrtext_l TYPE string,
          END OF ddic.
    DATA exists TYPE abap_bool.

    DATA data_element_name LIKE i_data_element_name.
        DATA temp7 TYPE REF TO cl_abap_structdescr.
        DATA struct_desrc LIKE temp7.
        FIELD-SYMBOLS <ddic> TYPE data.
        DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
        DATA temp8 TYPE REF TO cl_abap_datadescr.
        DATA data_descr LIKE temp8.
            DATA xco_cp_abap_dictionary TYPE c LENGTH 22.
    data_element_name = i_data_element_name.

    TRY.
        cl_abap_typedescr=>describe_by_name( 'T100' ).


        temp7 ?= cl_abap_structdescr=>describe_by_name( 'DFIES' ).

        struct_desrc = temp7.

        CREATE DATA ddic_ref TYPE HANDLE struct_desrc.

        ASSIGN ddic_ref->* TO <ddic>.
        ASSERT sy-subrc = 0.


        cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name      = data_element_name
                                             RECEIVING  p_descr_ref = lo_typedescr
                                             EXCEPTIONS OTHERS      = 1 ).
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        temp8 ?= lo_typedescr.

        data_descr = temp8.

        CALL METHOD data_descr->('GET_DDIC_FIELD')
          RECEIVING  p_flddescr   = <ddic>
          EXCEPTIONS not_found    = 1
                     no_ddic_type = 2
                     OTHERS       = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        MOVE-CORRESPONDING <ddic> TO ddic.
        result-header = ddic-reptext.
        result-short  = ddic-scrtext_s.
        result-medium = ddic-scrtext_m.
        result-long   = ddic-scrtext_l.

      CATCH cx_root.
        TRY.

            xco_cp_abap_dictionary = 'XCO_CP_ABAP_DICTIONARY'.
            CALL METHOD (xco_cp_abap_dictionary)=>('DATA_ELEMENT')
              EXPORTING iv_name         = data_element_name
              RECEIVING ro_data_element = data_element.

            CALL METHOD data_element->('IF_XCO_AD_DATA_ELEMENT~EXISTS')
              RECEIVING rv_exists = exists.

            IF exists = abap_false.
              RETURN.
            ENDIF.

            CALL METHOD data_element->('IF_XCO_AD_DATA_ELEMENT~CONTENT')
              RECEIVING ro_content = content.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL')
              RECEIVING rs_heading_field_label = result-header.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL')
              RECEIVING rs_short_field_label = result-short.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL')
              RECEIVING rs_medium_field_label = result-medium.

            CALL METHOD content->('IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL')
              RECEIVING rs_long_field_label = result-long.

          CATCH cx_root.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD uuid_get_c22.

    DATA lv_uuid TYPE c LENGTH 22.
            DATA lv_classname TYPE string.
            DATA lv_fm TYPE string.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c22
              RECEIVING uuid = lv_uuid.

          CATCH cx_sy_dyn_call_illegal_class.


            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING ev_guid_22 = lv_uuid.

        ENDTRY.

        result = lv_uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

    result = replace( val  = result
                      sub  = `}`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `{`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `0`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `'`
                      with = `0`
                      occ  = 0 ).

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid TYPE c LENGTH 32.
            DATA lv_classname TYPE string.
            DATA lv_fm TYPE string.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING uuid = lv_uuid.

          CATCH cx_root.


            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING ev_guid_32 = lv_uuid.

        ENDTRY.

        result = lv_uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_class_descr_on_cloud.

    DATA obj          TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA lv_classname TYPE c LENGTH 30.
    DATA xco_cp_abap TYPE c LENGTH 11.

    lv_classname = i_classname.


    xco_cp_abap = 'XCO_CP_ABAP'.
    CALL METHOD (xco_cp_abap)=>('CLASS')
      EXPORTING iv_name  = lv_classname
      RECEIVING ro_class = obj.

    CALL METHOD obj->('IF_XCO_AO_CLASS~CONTENT')
      RECEIVING ro_content = content.

    CALL METHOD content->('IF_XCO_CLAS_CONTENT~GET_SHORT_DESCRIPTION')
      RECEIVING rv_short_description = result.

  ENDMETHOD.

  METHOD rtti_get_t_attri_on_prem.

    DATA structdescr TYPE REF TO cl_abap_structdescr.
    DATA dfies       TYPE REF TO data.
    DATA s_dfies     TYPE ty_s_dfies.

    FIELD-SYMBOLS <dfies> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    DATA temp9 TYPE cl_abap_structdescr=>component_table.
    DATA comps LIKE temp9.
    DATA temp10 TYPE REF TO cl_abap_structdescr.
    DATA lo_struct LIKE temp10.
        DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
        DATA new_table_desc TYPE REF TO cl_abap_tabledescr.
          DATA comp LIKE LINE OF comps.
            FIELD-SYMBOLS <value> TYPE any.
            FIELD-SYMBOLS <value_dest> TYPE any.
    CLEAR temp9.

    comps = temp9.

    temp10 ?= cl_abap_structdescr=>describe_by_name( 'DFIES' ).

    lo_struct = temp10.
    comps = lo_struct->get_components( ).

    TRY.


        new_struct_desc = cl_abap_structdescr=>create( comps ).

        new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA dfies TYPE HANDLE new_table_desc.

        ASSIGN dfies->* TO <dfies>.
        IF <dfies> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        IF tabname IS INITIAL.

          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING val = `RTTI_BY_NAME_TAB_INITIAL`.
        ENDIF.

        structdescr ?= cl_abap_structdescr=>describe_by_name( tabname ).
        <dfies> = structdescr->get_ddic_field_list( ).

        LOOP AT <dfies> ASSIGNING <line>.


          LOOP AT comps INTO comp.


            ASSIGN COMPONENT comp-name OF STRUCTURE <line> TO <value>.
            IF <value> IS NOT ASSIGNED.
              CONTINUE.
            ENDIF.


            ASSIGN COMPONENT comp-name OF STRUCTURE s_dfies TO <value_dest>.
            IF <value_dest> IS NOT ASSIGNED.
              CONTINUE.
            ENDIF.

            <value_dest> = <value>.

            UNASSIGN <value>.
            UNASSIGN <value_dest>.

          ENDLOOP.

          APPEND s_dfies TO result.
          CLEAR s_dfies.

        ENDLOOP.

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_t_attri_on_cloud.

*    DATA db        TYPE REF TO object.
*    DATA fields    TYPE REF TO object.
*    DATA r_names   TYPE REF TO data.
*    DATA t_param   TYPE abap_parmbind_tab.
*    DATA field     TYPE REF TO object.
*    DATA content   TYPE REF TO object.
*    DATA r_content TYPE REF TO data.
*    DATA type      TYPE REF TO object.
*    DATA element   TYPE REF TO object.
*    DATA tab       TYPE c LENGTH 16.
*
*    FIELD-SYMBOLS <any>   TYPE any.
*    FIELD-SYMBOLS <names> TYPE STANDARD TABLE.
*    FIELD-SYMBOLS <name>  TYPE any.
*    FIELD-SYMBOLS <fiel>  TYPE REF TO object.
*
*    tab = tabname.
*
*    CALL METHOD ('XCO_CP_ABAP_DICTIONARY')=>database_table
*      EXPORTING
*        iv_name           = tab
*      RECEIVING
*        ro_database_table = db.
*
*    ASSIGN db->('IF_XCO_DATABASE_TABLE~FIELDS->IF_XCO_DBT_FIELDS_FACTORY~ALL') TO <any>.
*
*    IF sy-subrc <> 0.
*      RETURN.
*    ENDIF.
*
*    fields = <any>.
*
*    CREATE DATA r_names TYPE ('SXCO_T_AD_FIELD_NAMES').
*    ASSIGN r_names->* TO <Names>.
*    IF <Names> IS NOT ASSIGNED.
*      RETURN.
*    ENDIF.
*
*    CALL METHOD fields->('IF_XCO_DBT_FIELDS~GET_NAMES')
*      RECEIVING
*        rt_names = <Names>.
*
*    LOOP AT <Names> ASSIGNING <name>.
*
*      CLEAR t_param.
*
*      INSERT VALUE #( name  = 'IV_NAME'
*                      kind  = cl_abap_objectdescr=>exporting
*                      value = REF #( <name> ) ) INTO TABLE t_param.
*      INSERT VALUE #( name  = 'RO_FIELD'
*                      kind  = cl_abap_objectdescr=>receiving
*                      value = REF #( field ) ) INTO TABLE t_param.
*
*      CALL METHOD db->(`IF_XCO_DATABASE_TABLE~FIELD`)
*        PARAMETER-TABLE t_param.
*
*      ASSIGN t_param[ name = 'RO_FIELD' ] TO FIELD-SYMBOL(<line>).
*      IF <line> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN <line>-value->* TO <fiel>.
*      IF <fiel> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      CALL METHOD <fiel>->('IF_XCO_DBT_FIELD~CONTENT')
*        RECEIVING
*          ro_content = content.
*
*      CREATE DATA r_content TYPE ('IF_XCO_DBT_FIELD_CONTENT=>TS_CONTENT').
*      ASSIGN r_content->* TO FIELD-SYMBOL(<Content>) CASTING TYPE ('IF_XCO_DBT_FIELD_CONTENT=>TS_CONTENT').
*      IF <content> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      CALL METHOD content->('IF_XCO_DBT_FIELD_CONTENT~GET')
*        RECEIVING
*          rs_content = <Content>.
*
*      ASSIGN COMPONENT 'KEY_INDICATOR' OF STRUCTURE <content> TO FIELD-SYMBOL(<key>).
*      IF <key> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN COMPONENT 'SHORT_DESCRIPTION' OF STRUCTURE <content> TO FIELD-SYMBOL(<text>).
*      IF <text> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN COMPONENT 'TYPE' OF STRUCTURE <content> TO FIELD-SYMBOL(<type>).
*      IF <type> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      type = <type>.
*
*      CALL METHOD type->('IF_XCO_DBT_FIELD_TYPE~GET_DATA_ELEMENT')
*        RECEIVING
*          ro_data_element = element.
*
*      IF <text> IS INITIAL.
*        <text> = <name>.
*      ENDIF.
*
*      ASSIGN element->('IF_XCO_AD_OBJECT~NAME') TO FIELD-SYMBOL(<rname>).
*      IF <rname> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      IF sy-subrc = 0.
*        result = VALUE #( BASE result
*                          ( fieldname = <name> keyflag = <key> tabname = tab scrtext_s = <text> rollname = <rname> ) ).
*      ELSE.
*        result = VALUE #( BASE result
*                          ( fieldname = <name> keyflag = <key> tabname = tab scrtext_s = <text> rollname = <name> ) ).
*      ENDIF.
*
*      UNASSIGN <Content>.
*      UNASSIGN <key>.
*      UNASSIGN <Text>.
*      UNASSIGN <type>.
*      UNASSIGN <rname>.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_dfies_by_table_name.

    IF context_check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_t_attri_on_cloud( table_name ).
    ELSE.
      result = rtti_get_t_attri_on_prem( table_name ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

