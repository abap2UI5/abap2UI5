CLASS z2ui5_cl_util_api DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_fix_val,
        low   TYPE string,
        high  TYPE string,
        descr TYPE string,
      END OF ty_s_fix_val.
    TYPES ty_t_fix_val TYPE STANDARD TABLE OF ty_s_fix_val WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_syst,
        index TYPE i,
        pagno TYPE i,
        tabix TYPE i,
        tfill TYPE i,
        tlopc TYPE i,
        tmaxl TYPE i,
        toccu TYPE i,
        ttabc TYPE i,
        tstis TYPE i,
        ttabi TYPE i,
        dbcnt TYPE i,
        fdpos TYPE i,
        colno TYPE i,
        linct TYPE i,
        linno TYPE i,
        linsz TYPE i,
        pagct TYPE i,
        macol TYPE i,
        marow TYPE i,
        tleng TYPE i,
        sfoff TYPE i,
        willi TYPE i,
        lilli TYPE i,
        subrc TYPE i,
        fleng TYPE i,
        cucol TYPE i,
        curow TYPE i,
        lsind TYPE i,
        listi TYPE i,
        stepl TYPE i,
        tpagi TYPE i,
        winx1 TYPE i,
        winy1 TYPE i,
        winx2 TYPE i,
        winy2 TYPE i,
        winco TYPE i,
        winro TYPE i,
        windi TYPE i,
        srows TYPE i,
        scols TYPE i,
        loopc TYPE i,
        folen TYPE i,
        fodec TYPE i,
        tzone TYPE i,
        dayst TYPE c LENGTH 1,
        ftype TYPE c LENGTH 1,
        appli TYPE x LENGTH 2,
        fdayw TYPE int1,
        ccurs TYPE p LENGTH 9 DECIMALS 0,
        ccurt TYPE p LENGTH 9 DECIMALS 0,
        debug TYPE c LENGTH 1,
        ctype TYPE c LENGTH 1,
        input TYPE c LENGTH 1,
        langu TYPE c LENGTH 1,
        modno TYPE i,
        batch TYPE c LENGTH 1,
        binpt TYPE c LENGTH 1,
        calld TYPE c LENGTH 1,
        dynnr TYPE c LENGTH 4,
        dyngr TYPE c LENGTH 4,
        newpa TYPE c LENGTH 1,
        pri40 TYPE c LENGTH 1,
        rstrt TYPE c LENGTH 1,
        wtitl TYPE c LENGTH 1,
        cpage TYPE i,
        dbnam TYPE c LENGTH 20,
        mandt TYPE c LENGTH 3,
        prefx TYPE c LENGTH 3,
        fmkey TYPE c LENGTH 3,
        pexpi TYPE n LENGTH 1,
        prini TYPE n LENGTH 1,
        primm TYPE c LENGTH 1,
        prrel TYPE c LENGTH 1,
        playo TYPE c LENGTH 5,
        prbig TYPE c LENGTH 1,
        playp TYPE c LENGTH 1,
        prnew TYPE c LENGTH 1,
        prlog TYPE c LENGTH 1,
        pdest TYPE c LENGTH 4,
        plist TYPE c LENGTH 12,
        pauth TYPE n LENGTH 2,
        prdsn TYPE c LENGTH 6,
        pnwpa TYPE c LENGTH 1,
        callr TYPE c LENGTH 8,
        repi2 TYPE c LENGTH 40,
        rtitl TYPE c LENGTH 70,
        prrec TYPE c LENGTH 12,
        prtxt TYPE c LENGTH 68,
        prabt TYPE c LENGTH 12,
        lpass TYPE c LENGTH 4,
        nrpag TYPE c LENGTH 1,
        paart TYPE c LENGTH 16,
        prcop TYPE n LENGTH 3,
        batzs TYPE c LENGTH 1,
        bspld TYPE c LENGTH 1,
        brep4 TYPE c LENGTH 4,
        batzo TYPE c LENGTH 1,
        batzd TYPE c LENGTH 1,
        batzw TYPE c LENGTH 1,
        batzm TYPE c LENGTH 1,
        ctabl TYPE c LENGTH 4,
        dbsys TYPE c LENGTH 10,
        dcsys TYPE c LENGTH 4,
        macdb TYPE c LENGTH 4,
        sysid TYPE c LENGTH 8,
        opsys TYPE c LENGTH 10,
        pfkey TYPE c LENGTH 20,
        saprl TYPE c LENGTH 4,
        tcode TYPE c LENGTH 20,
        ucomm TYPE c LENGTH 70,
        cfwae TYPE c LENGTH 5,
        chwae TYPE c LENGTH 5,
        spono TYPE n LENGTH 10,
        sponr TYPE n LENGTH 10,
        waers TYPE c LENGTH 5,
        cdate TYPE d,
        datum TYPE d,
        slset TYPE c LENGTH 14,
        subty TYPE x LENGTH 1,
        subcs TYPE c LENGTH 1,
        group TYPE c LENGTH 1,
        ffile TYPE c LENGTH 8,
        uzeit TYPE t,
        dsnam TYPE c LENGTH 8,
        tabid TYPE c LENGTH 8,
        tfdsn TYPE c LENGTH 8,
        uname TYPE c LENGTH 12,
        lstat TYPE c LENGTH 16,
        abcde TYPE c LENGTH 26,
        marky TYPE c LENGTH 1,
        sfnam TYPE c LENGTH 30,
        tname TYPE c LENGTH 30,
        msgli TYPE c LENGTH 60,
        title TYPE c LENGTH 70,
        entry TYPE c LENGTH 72,
        lisel TYPE c LENGTH 255,
        uline TYPE c LENGTH 255,
        xcode TYPE c LENGTH 70,
        cprog TYPE c LENGTH 40,
        xprog TYPE c LENGTH 40,
        xform TYPE c LENGTH 30,
        ldbpg TYPE c LENGTH 40,
        tvar0 TYPE c LENGTH 20,
        tvar1 TYPE c LENGTH 20,
        tvar2 TYPE c LENGTH 20,
        tvar3 TYPE c LENGTH 20,
        tvar4 TYPE c LENGTH 20,
        tvar5 TYPE c LENGTH 20,
        tvar6 TYPE c LENGTH 20,
        tvar7 TYPE c LENGTH 20,
        tvar8 TYPE c LENGTH 20,
        tvar9 TYPE c LENGTH 20,
        msgid TYPE c LENGTH 20,
        msgty TYPE c LENGTH 1,
        msgno TYPE n LENGTH 3,
        msgv1 TYPE c LENGTH 50,
        msgv2 TYPE c LENGTH 50,
        msgv3 TYPE c LENGTH 50,
        msgv4 TYPE c LENGTH 50,
        oncom TYPE c LENGTH 1,
        vline TYPE c LENGTH 1,
        winsl TYPE c LENGTH 79,
        staco TYPE i,
        staro TYPE i,
        datar TYPE c LENGTH 1,
        host  TYPE c LENGTH 32,
        locdb TYPE c LENGTH 1,
        locop TYPE c LENGTH 1,
        datlo TYPE d,
        timlo TYPE t,
        zonlo TYPE c LENGTH 6,
      END OF ty_syst.

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
    TYPES ty_t_classes TYPE STANDARD TABLE OF ty_s_class_descr WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_stack,
        class   TYPE string,
        include TYPE string,
        method  TYPE string,
        line    TYPE string,
      END OF ty_s_stack.
    TYPES ty_t_stack TYPE STANDARD TABLE OF ty_s_stack WITH DEFAULT KEY.

    CLASS-METHODS bal_read
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_save
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS context_get_callstack
      RETURNING
        VALUE(result) TYPE ty_t_stack.

    CLASS-METHODS context_get_tenant
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS context_get_sy
      RETURNING
        VALUE(result) TYPE ty_syst.

    CLASS-METHODS context_check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS context_get_user_tech
      RETURNING
        VALUE(result) TYPE string.

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
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_data_element_text.

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

    CLASS-METHODS conv_get_xlsx_by_itab
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS conv_get_itab_by_xlsx
      IMPORTING
        val    TYPE xstring
      EXPORTING
        result TYPE REF TO data.

    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_classes.

    CLASS-METHODS rtti_get_t_fixvalues
      IMPORTING
        elemdescr     TYPE REF TO cl_abap_elemdescr
        langu         TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_fix_val.

    CLASS-METHODS rtti_get_table_desrc
      IMPORTING
        tabname       TYPE clike
        langu         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string ##NEEDED.


  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        i_classname   TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_util_api IMPLEMENTATION.

  METHOD context_check_abap_cloud.

    TRY.
        cl_abap_typedescr=>describe_by_name( `T100` ).
        result = abap_false.
      CATCH cx_root.
        result = abap_true.
    ENDTRY.

  ENDMETHOD.

  METHOD context_get_user_tech.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>context_get_user_tech( ).
    ELSE.
      result = z2ui5_cl_util_api_s=>context_get_user_tech( ).
    ENDIF.

  ENDMETHOD.

  METHOD context_get_sy.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>context_get_sy( ).
    ELSE.
      result = z2ui5_cl_util_api_s=>context_get_sy( ).
    ENDIF.

  ENDMETHOD.

  METHOD context_get_callstack.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>context_get_callstack( ).
    ELSE.
      result = z2ui5_cl_util_api_s=>context_get_callstack( ).
    ENDIF.

  ENDMETHOD.

  METHOD context_get_tenant.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>context_get_tenant( ).
    ELSE.
      result = z2ui5_cl_util_api_s=>context_get_tenant( ).
    ENDIF.

  ENDMETHOD.

  METHOD bal_read.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>bal_read( object = object subobject = subobject id = id ).
    ELSE.
      result = z2ui5_cl_util_api_s=>bal_read( object = object subobject = subobject id = id ).
    ENDIF.

  ENDMETHOD.

  METHOD bal_save.

    IF context_check_abap_cloud( ).
      z2ui5_cl_util_api_c=>bal_save( object = object subobject = subobject id = id t_log = t_log ).
    ELSE.
      z2ui5_cl_util_api_s=>bal_save( object = object subobject = subobject id = id t_log = t_log ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_t_fixvalues.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>rtti_get_t_fixvalues( elemdescr = elemdescr langu = langu ).
    ELSE.
      result = z2ui5_cl_util_api_s=>rtti_get_t_fixvalues( elemdescr = elemdescr langu = langu ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>rtti_get_data_element_texts( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>rtti_get_data_element_texts( val ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_classes_impl_intf.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>rtti_get_classes_impl_intf( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>rtti_get_classes_impl_intf( val ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_table_desrc.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>rtti_get_table_desrc( tabname = tabname ).
    ELSEIF langu IS SUPPLIED.
      result = z2ui5_cl_util_api_s=>rtti_get_table_desrc( tabname = tabname langu = langu ).
    ELSE.
      result = z2ui5_cl_util_api_s=>rtti_get_table_desrc( tabname = tabname ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_class_descr_on_cloud.

    TRY.

        DATA obj          TYPE REF TO object.
        DATA content      TYPE REF TO object.
        DATA lv_classname TYPE c LENGTH 30.
        DATA xco_cp_abap  TYPE c LENGTH 11.

        lv_classname = i_classname.

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_classname
          RECEIVING
            ro_class = obj.

        CALL METHOD obj->(`IF_XCO_AO_CLASS~CONTENT`)
          RECEIVING
            ro_content = content.

        CALL METHOD content->(`IF_XCO_CLAS_CONTENT~GET_SHORT_DESCRIPTION`)
          RECEIVING
            rv_short_description = result.

      CATCH cx_root INTO DATA(x).
        DATA(lv_error) = x->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD conv_decode_x_base64.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>conv_decode_x_base64( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>conv_decode_x_base64( val ).
    ENDIF.

  ENDMETHOD.

  METHOD conv_encode_x_base64.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>conv_encode_x_base64( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>conv_encode_x_base64( val ).
    ENDIF.

  ENDMETHOD.

  METHOD conv_get_string_by_xstring.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>conv_get_string_by_xstring( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>conv_get_string_by_xstring( val ).
    ENDIF.

  ENDMETHOD.

  METHOD conv_get_xstring_by_string.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>conv_get_xstring_by_string( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>conv_get_xstring_by_string( val ).
    ENDIF.

  ENDMETHOD.

  METHOD conv_get_xlsx_by_itab.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>conv_get_xlsx_by_itab( val ).
    ELSE.
      result = z2ui5_cl_util_api_s=>conv_get_xlsx_by_itab( val ).
    ENDIF.

  ENDMETHOD.

  METHOD conv_get_itab_by_xlsx.

    IF context_check_abap_cloud( ).
      z2ui5_cl_util_api_c=>conv_get_itab_by_xlsx( EXPORTING val = val IMPORTING result = result ).
    ELSE.
      z2ui5_cl_util_api_s=>conv_get_itab_by_xlsx( EXPORTING val = val IMPORTING result = result ).
    ENDIF.

  ENDMETHOD.

  METHOD source_get_method.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>source_get_method( iv_classname = iv_classname iv_methodname = iv_methodname ).
    ELSE.
      result = z2ui5_cl_util_api_s=>source_get_method( iv_classname = iv_classname iv_methodname = iv_methodname ).
    ENDIF.

  ENDMETHOD.

  METHOD uuid_get_c22.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>uuid_get_c22( ).
    ELSE.
      result = z2ui5_cl_util_api_s=>uuid_get_c22( ).
    ENDIF.

  ENDMETHOD.

  METHOD uuid_get_c32.

    IF context_check_abap_cloud( ).
      result = z2ui5_cl_util_api_c=>uuid_get_c32( ).
    ELSE.
      result = z2ui5_cl_util_api_s=>uuid_get_c32( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
