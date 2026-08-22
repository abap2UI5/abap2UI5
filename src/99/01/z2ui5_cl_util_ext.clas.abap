CLASS z2ui5_cl_util_ext DEFINITION
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

    TYPES: BEGIN OF ty_usr01,
             mandt         TYPE c LENGTH 3,     " Client
             bname         TYPE c LENGTH 12,    " User Name
             stcod         TYPE c LENGTH 20,    " Start Menu (old)
             spld          TYPE c LENGTH 4,     " Output Device
             splg          TYPE c LENGTH 1,     " Print Parameter 1
             spdb          TYPE c LENGTH 1,     " Print Parameter 2
             spda          TYPE c LENGTH 1,     " Print Parameter 3
             datfm         TYPE c LENGTH 1,     " Date Format
             dcpfm         TYPE c LENGTH 1,     " Decimal Format
             hdest         TYPE c LENGTH 8,     " Host Destination
             hmand         TYPE c LENGTH 3,     " Default Host Client
             hname         TYPE c LENGTH 12,    " Default Host Username
             menon         TYPE c LENGTH 1,     " Automatic Start
             menue         TYPE c LENGTH 20,    " Menu Name
             strtt         TYPE c LENGTH 20,    " Start Menu (again)
             langu         TYPE c LENGTH 1,     " Logon Language
             cattkennz     TYPE c LENGTH 1,     " CATT Test Status
             timefm        TYPE c LENGTH 1,     " Time Format (12h/24h)
             ianatzonecode TYPE n LENGTH 4,     " IANA Timezone Code
           END OF ty_usr01.

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

    CLASS-METHODS conv_exit
      IMPORTING
        name   TYPE ty_s_dfies
        val    TYPE data
      CHANGING
        result TYPE data.

    CLASS-METHODS rtti_get_t_dfies_by_table_name
      IMPORTING
        table_name    TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_dfies.

    CLASS-METHODS tab_get_where_by_dfies
      IMPORTING
        mv_check_tab_field TYPE string
        ms_data_row        TYPE REF TO data
        it_dfies           TYPE ty_t_dfies
      RETURNING
        VALUE(result)      TYPE string.

    CLASS-METHODS rtti_get_table_desrc
      IMPORTING
        tabname       TYPE clike
        langu         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE string ##NEEDED.

    TYPES trobj_name     TYPE c LENGTH 120.
    TYPES sxco_transport TYPE c LENGTH 20.
    TYPES:
      BEGIN OF ty_s_transport,
        short_description TYPE string,
        transport         TYPE sxco_transport,
        task              TYPE sxco_transport,
        selkz             TYPE abap_bool,
        locl              TYPE abap_bool,
      END OF ty_s_transport.

    TYPES ty_t_data TYPE STANDARD TABLE OF ty_s_transport WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_dfies_2,
        tabname     TYPE c LENGTH 30,  " Table Name
        fieldname   TYPE c LENGTH 30,  " Field Name
        langu       TYPE c LENGTH 1,   " Language Key
        position    TYPE n LENGTH 4,   " Position of the field in the table
        offset      TYPE n LENGTH 6,   " Offset of a field
        domname     TYPE c LENGTH 30,  " Domain name
        rollname    TYPE c LENGTH 30,  " Data element (semantic domain)
        checktable  TYPE c LENGTH 30,  " Check Table
        leng        TYPE n LENGTH 6,   " Length (Characters)
        intlen      TYPE n LENGTH 6,   " Internal Length (Bytes)
        outputlen   TYPE n LENGTH 6,   " Output Length
        decimals    TYPE n LENGTH 6,   " Number of Decimal Places
        datatype    TYPE c LENGTH 4,   " Dynpro Data Type
        inttype     TYPE c LENGTH 1,   " ABAP Data Type (C,D,N,...)
        reftable    TYPE c LENGTH 30,  " Reference Table
        reffield    TYPE c LENGTH 30,  " Reference Field
        precfield   TYPE c LENGTH 30,  " Included Table Name
        authorid    TYPE c LENGTH 3,   " Authorization Class
        memoryid    TYPE c LENGTH 20,  " Set/Get Parameter ID
        logflag     TYPE c LENGTH 1,   " Change Documents Indicator
        mask        TYPE c LENGTH 20,  " Template
        masklen     TYPE n LENGTH 4,   " Template Length
        convexit    TYPE c LENGTH 5,   " Conversion Routine
        headlen     TYPE n LENGTH 2,   " Heading Length
        scrlen1     TYPE n LENGTH 2,   " Short Field Label Length
        scrlen2     TYPE n LENGTH 2,   " Medium Field Label Length
        scrlen3     TYPE n LENGTH 2,   " Long Field Label Length
        fieldtext   TYPE c LENGTH 60,  " Short Description
        reptext     TYPE c LENGTH 55,  " Heading
        scrtext_s   TYPE c LENGTH 10,  " Short Field Label
        scrtext_m   TYPE c LENGTH 20,  " Medium Field Label
        scrtext_l   TYPE c LENGTH 40,  " Long Field Label
        keyflag     TYPE c LENGTH 1,   " Key Field Indicator
        lowercase   TYPE c LENGTH 1,   " Lowercase Allowed
        mac         TYPE c LENGTH 1,   " Search Help Attached
        genkey      TYPE c LENGTH 1,   " Flag (X or Blank)
        noforkey    TYPE c LENGTH 1,   " Flag (X or Blank)
        valexi      TYPE c LENGTH 1,   " Fixed Values Exist
        noauthch    TYPE c LENGTH 1,   " Flag (X or Blank)
        sign        TYPE c LENGTH 1,   " Sign Flag
        dynpfld     TYPE c LENGTH 1,   " Field Displayed on Dynpro
        f4availabl  TYPE c LENGTH 1,   " Input Help Available
        comptype    TYPE c LENGTH 1,   " Component Type
        lfieldname  TYPE c LENGTH 132, " Long Field Name
        ltrflddis   TYPE c LENGTH 1,   " Left-to-Right Write Direction
        bidictrlc   TYPE c LENGTH 1,   " No BIDI Character Filtering
        outputstyle TYPE n LENGTH 2,   " Output Style (Decfloat Types)
        nohistory   TYPE c LENGTH 1,   " Input History Deactivated
        ampmformat  TYPE c LENGTH 1,   " AM/PM Time Format Indicator
      END OF ty_s_dfies_2.
    TYPES ty_t_dfies_2 TYPE STANDARD TABLE OF ty_s_dfies_2 WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_shlp_intdescr,
        issimple         TYPE c LENGTH 1,   " Elementary Search Help Flag
        hotkey           TYPE c LENGTH 1,   " Hot Key
        selmtype         TYPE c LENGTH 1,   " Category of Selection Method
        selmethod        TYPE c LENGTH 30,  " Selection Method Name
        texttab          TYPE c LENGTH 30,  " Text Table Name
        selmexit         TYPE c LENGTH 30,  " Search Help Exit
        dialogtype       TYPE c LENGTH 1,   " Dialog Type
        ddlanguage       TYPE c LENGTH 1,   " Language Key
        ddtext           TYPE c LENGTH 60,  " Short Text
        dialoginfo       TYPE c LENGTH 1,   " Flag: SELFIELDS/LISTFIELDS read
        f4state          TYPE c LENGTH 1,   " Internal Usage Only
        tabname          TYPE c LENGTH 30,  " Table Name
        fieldname        TYPE c LENGTH 30,  " Field Name
        title            TYPE c LENGTH 60,  " Title Text
        history          TYPE c LENGTH 1,   " Deprecated Usage
        handle           TYPE int4,         " Reference Handle (int4)
        autosuggest      TYPE c LENGTH 1,   " Autosuggest Flag
        fuzzy_search     TYPE c LENGTH 1,   " Fuzzy Search Flag
        fuzzy_similarity TYPE p DECIMALS 1 LENGTH 2, " Accuracy for Fuzzy Search (DEC 2,1)
      END OF ty_shlp_intdescr.

    TYPES:
      BEGIN OF ty_ddshiface,
        shlpfield  TYPE c LENGTH 30,  " Field Name for Pass by Value to F4 Help
        valtabname TYPE c LENGTH 30,  " Structure Name for Input Help Assignment
        valfield   TYPE c LENGTH 132, " Field for Input Help Assignment
        value      TYPE c LENGTH 132, " Field Content from Dynpro
        internal   TYPE c LENGTH 1,   " Flag: Internal Representation
        dispfield  TYPE c LENGTH 1,   " Display-Only Field Flag
        f4field    TYPE c LENGTH 1,   " F4 Pressed Flag
        topshlpnam TYPE c LENGTH 30,  " Higher-Level Search Help Name
        topshlpfld TYPE c LENGTH 30,  " Field of Higher-Level Search Help
      END OF ty_ddshiface.

    TYPES:
      BEGIN OF ty_ddshfprop,
        fieldname  TYPE c LENGTH 30, " Name of Search Help Parameter
        shlpinput  TYPE c LENGTH 1,  " IMPORT Parameter Flag
        shlpoutput TYPE c LENGTH 1,  " EXPORT Parameter Flag
        shlpselpos TYPE n LENGTH 2,  " Position in Dialog Box
        shlplispos TYPE n LENGTH 2,  " Position in Hit List
        shlpseldis TYPE c LENGTH 1,  " Display Field in Dialog Box
        defaultval TYPE c LENGTH 21, " Default Value
      END OF ty_ddshfprop.

    TYPES:
      BEGIN OF ty_ddshselopt,
        shlpname  TYPE c LENGTH 30, " Name of Search Help
        shlpfield TYPE c LENGTH 30, " Name of Search Help Parameter
        sign      TYPE c LENGTH 1,  " Include/Exclude Flag (I/E)
        option    TYPE c LENGTH 2,  " Selection Option (EQ/BT/CP/..)
        low       TYPE c LENGTH 45, " Low Value for Selection
        high      TYPE c LENGTH 45, " High Value for Selection
      END OF ty_ddshselopt.

    TYPES:
      BEGIN OF ty_ddshtextsearch_field,
        fieldname TYPE c LENGTH 30, " Name of a searchable field (freely chosen, not specified by SAP)
      END OF ty_ddshtextsearch_field.

    TYPES tt_ddshtextsearch_fields TYPE STANDARD TABLE OF ty_ddshtextsearch_field WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_ddshtextsearch,
        request TYPE c LENGTH 60,              " Text Search Request
        fields  TYPE tt_ddshtextsearch_fields, " Fields eligible for text search
      END OF ty_ddshtextsearch.

    TYPES:
      BEGIN OF ty_shlp_descr,
        shlpname   TYPE c LENGTH 30,       " Name of a Search Help
        shlptype   TYPE c LENGTH 2,        " Type of an input help (fixed values)
        intdescr   TYPE ty_shlp_intdescr,  " Placeholder for Internal Info of Search Help
        interface  TYPE STANDARD TABLE OF ty_ddshiface WITH DEFAULT KEY,                      " Placeholder for Interface of Search Help
        fielddescr TYPE STANDARD TABLE OF ty_s_dfies_2 WITH DEFAULT KEY,
        fieldprop  TYPE STANDARD TABLE OF ty_ddshfprop WITH DEFAULT KEY,
        selopt     TYPE STANDARD TABLE OF ty_ddshselopt WITH DEFAULT KEY,
        textsearch TYPE ty_ddshtextsearch,
      END OF ty_shlp_descr.

    CLASS-METHODS bus_tr_read
      RETURNING
        VALUE(mt_data) TYPE ty_t_data.

    CLASS-METHODS bus_tr_add
      IMPORTING
        ir_data      TYPE REF TO data
        iv_tabname   TYPE string
        is_transport TYPE ty_s_transport.

    CLASS-METHODS bus_search_help_read
      CHANGING
        ms_shlp        TYPE ty_shlp_descr
        mv_fname       TYPE string
        mv_table       TYPE string
        mr_data        TYPE REF TO data
        mt_result_desc TYPE ty_t_dfies_2
        mv_shlpfield   TYPE string
        mt_data        TYPE REF TO data
        ms_data_row    TYPE REF TO data.

    " ========== Business Application Log (BAL) ==========

    TYPES:
      BEGIN OF ty_s_bal_header,
        log_handle  TYPE string,
        object      TYPE string,
        subobject   TYPE string,
        external_id TYPE string,
        log_date    TYPE d,
        log_time    TYPE t,
        user        TYPE string,
        msg_count   TYPE i,
      END OF ty_s_bal_header.
    TYPES ty_t_bal_header TYPE STANDARD TABLE OF ty_s_bal_header WITH DEFAULT KEY.

    CLASS-METHODS bal_search
      IMPORTING
        object        TYPE clike OPTIONAL
        subobject     TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        date_from     TYPE d OPTIONAL
        date_to       TYPE d OPTIONAL
        !user         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_bal_header.

    CLASS-METHODS bal_read_latest
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_s_msg.

    CLASS-METHODS bal_delete_before
      IMPORTING
        object    TYPE clike
        subobject TYPE clike OPTIONAL
        !days     TYPE i DEFAULT 30.

    CLASS-METHODS bal_read_by_type
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
        msg_type      TYPE clike DEFAULT `E`
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_count
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS bal_read
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_create
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_update
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike
        t_log     TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_delete
      IMPORTING
        object    TYPE clike
        subobject TYPE clike
        id        TYPE clike.

    " ========== Transport Requests ==========

    TYPES:
      BEGIN OF ty_s_tr_object,
        pgmid    TYPE string,
        object   TYPE string,
        obj_name TYPE string,
      END OF ty_s_tr_object.
    TYPES ty_t_tr_object TYPE STANDARD TABLE OF ty_s_tr_object WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_tr_request,
        trkorr      TYPE string,
        description TYPE string,
        owner       TYPE string,
        status      TYPE string,
        type        TYPE string,
      END OF ty_s_tr_request.
    TYPES ty_t_tr_request TYPE STANDARD TABLE OF ty_s_tr_request WITH DEFAULT KEY.

    CLASS-METHODS tr_get_objects
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_tr_object.

    CLASS-METHODS tr_get_user_requests
      IMPORTING
        !user         TYPE clike DEFAULT sy-uname
        request_type  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_tr_request.

    CLASS-METHODS tr_get_description
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS tr_is_released
      IMPORTING
        trkorr        TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS tr_add_object
      IMPORTING
        trkorr  TYPE clike
        pgmid   TYPE clike DEFAULT 'R3TR'
        object  TYPE clike
        obj_name TYPE clike.

    CLASS-METHODS tr_create
      IMPORTING
        text          TYPE clike
        target        TYPE clike
        type          TYPE clike DEFAULT `T`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS tr_release
      IMPORTING
        trkorr       TYPE clike
        ignore_locks TYPE abap_bool DEFAULT abap_true.

    CLASS-METHODS tr_copy_objects
      IMPORTING
        source      TYPE clike
        destination TYPE clike.

    CLASS-METHODS tr_import
      IMPORTING
        trkorr         TYPE clike
        target_system  TYPE clike
        client         TYPE clike OPTIONAL
        ignore_version TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)  TYPE i.

    CLASS-METHODS tr_check_status
      IMPORTING
        trkorr   TYPE clike
        system   TYPE clike
      EXPORTING
        imported TYPE abap_bool
        rc       TYPE i.

    " ========== Enqueue/Dequeue Locks ==========

    TYPES:
      BEGIN OF ty_s_lock_param,
        name  TYPE c LENGTH 30,
        value TYPE string,
      END OF ty_s_lock_param.
    TYPES ty_t_lock_param TYPE STANDARD TABLE OF ty_s_lock_param WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_lock,
        lock_object TYPE string,
        argument    TYPE string,
        user        TYPE string,
        mode        TYPE string,
        client      TYPE string,
        date        TYPE d,
        time        TYPE t,
        owner       TYPE string,
        owner_vb    TYPE string,
      END OF ty_s_lock.
    TYPES ty_t_lock TYPE STANDARD TABLE OF ty_s_lock WITH DEFAULT KEY.

    CLASS-METHODS lock_set
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_set_wait
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
        retries       TYPE i DEFAULT 5
        delay_ms      TYPE i DEFAULT 500
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_is_locked
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_get_owner
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lock_get_dequeue_by_enqueue
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS lock_read
      IMPORTING
        lock_object   TYPE clike OPTIONAL
        !user         TYPE clike OPTIONAL
        client        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_lock.

    CLASS-METHODS lock_delete
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS lock_delete_entries
      IMPORTING
        t_lock        TYPE ty_t_lock
      RETURNING
        VALUE(result) TYPE abap_bool.

    " ========== System Services ==========

    TYPES:
      BEGIN OF ty_s_changdoc,
        changenr  TYPE string,
        username  TYPE string,
        udate     TYPE d,
        utime     TYPE t,
        tcode     TYPE string,
        fieldname TYPE string,
        old_value TYPE string,
        new_value TYPE string,
        tabname   TYPE string,
        chngind   TYPE string,
      END OF ty_s_changdoc.
    TYPES ty_t_changdoc TYPE STANDARD TABLE OF ty_s_changdoc WITH DEFAULT KEY.

    CLASS-METHODS auth_check
      IMPORTING
        object        TYPE clike
        field         TYPE clike
        !value        TYPE clike
        activity      TYPE clike DEFAULT '03'
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS text_get
      IMPORTING
        msgid         TYPE clike
        msgno         TYPE clike
        v1            TYPE clike OPTIONAL
        v2            TYPE clike OPTIONAL
        v3            TYPE clike OPTIONAL
        v4            TYPE clike OPTIONAL
        langu         TYPE clike DEFAULT sy-langu
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS mail_send
      IMPORTING
        !to      TYPE string
        subject  TYPE string
        body     TYPE string
        html     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS job_submit_report
      IMPORTING
        report          TYPE clike
        variant         TYPE clike OPTIONAL
        start_immediate TYPE abap_bool DEFAULT abap_true
        job_name        TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE string.

    CLASS-METHODS numrange_get_next
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike DEFAULT `01`
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS changdoc_read
      IMPORTING
        objectclass   TYPE clike
        objectid      TYPE clike
        date_from     TYPE d DEFAULT '19000101'
        date_to       TYPE d DEFAULT '99991231'
      RETURNING
        VALUE(result) TYPE ty_t_changdoc.

    " ========== Source Code / Dev Tools ==========

    CLASS-METHODS source_get_method
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS source_get_method2
      IMPORTING
        iv_classname  TYPE clike
        iv_methodname TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS source_get_file_types
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS source_method_to_file
      IMPORTING
        it_source     TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

    " ========== Calendar / Workdays ==========

    CLASS-METHODS cal_get_weekday
      IMPORTING
        !date         TYPE d
      RETURNING
        VALUE(result) TYPE i.

    CLASS-METHODS cal_is_weekend
      IMPORTING
        !date         TYPE d
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cal_is_workday
      IMPORTING
        !date         TYPE d
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS cal_add_workdays
      IMPORTING
        !date         TYPE d
        !days         TYPE i
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE d.

    CLASS-METHODS cal_count_workdays
      IMPORTING
        !date_from    TYPE d
        !date_to      TYPE d
        !calendar_id  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE i.

    " ========== XLSX / ZIP ==========

    TYPES:
      BEGIN OF ty_s_zip_file,
        name    TYPE string,
        content TYPE xstring,
      END OF ty_s_zip_file.
    TYPES ty_t_zip_file TYPE STANDARD TABLE OF ty_s_zip_file WITH DEFAULT KEY.

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

    CLASS-METHODS zip_pack
      IMPORTING
        !files        TYPE ty_t_zip_file
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS zip_unpack
      IMPORTING
        !val          TYPE xstring
      RETURNING
        VALUE(result) TYPE ty_t_zip_file.

  PROTECTED SECTION.
    CLASS-METHODS _set_e071k
      IMPORTING
        ir_data       TYPE REF TO data
        iv_tabname    TYPE string
        is_transport  TYPE ty_s_transport
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS _set_e071
      IMPORTING
        iv_tabname    TYPE string
        is_transport  TYPE ty_s_transport
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS _get_e071k_tabkey
      IMPORTING
        line             TYPE any
        dfies            TYPE ty_t_dfies
      RETURNING
        VALUE(rv_tabkey) TYPE trobj_name.

    CLASS-METHODS _read_e070
      CHANGING
        mt_data TYPE ty_t_data.

    CLASS-METHODS set_mandt
      IMPORTING
        ir_data TYPE REF TO data.

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


    CLASS-METHODS bal_cloud_add_items
      IMPORTING
        log   TYPE REF TO object
        t_log TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_cloud_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS bal_std_msg_add
      IMPORTING
        handle TYPE any
        t_log  TYPE z2ui5_cl_util=>ty_t_msg.

    CLASS-METHODS bal_std_load_handles
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_std_build_filter
      IMPORTING
        object        TYPE clike
        subobject     TYPE clike
        id            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS bal_std_filter_add
      IMPORTING
        comp   TYPE clike
        value  TYPE clike
      CHANGING
        filter TYPE any.

    CLASS-METHODS bal_std_map_msg
      IMPORTING
        msg           TYPE any
      RETURNING
        VALUE(result) TYPE z2ui5_cl_util=>ty_s_msg.

    CLASS-METHODS lock_call_function
      IMPORTING
        val           TYPE clike
        t_param       TYPE ty_t_lock_param OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS z2ui5_cl_util_ext IMPLEMENTATION.

 METHOD rtti_get_class_descr_on_cloud.

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

  ENDMETHOD.

  METHOD rtti_get_t_attri_on_prem.

    DATA structdescr TYPE REF TO cl_abap_structdescr.
    DATA dfies       TYPE REF TO data.
    DATA s_dfies     TYPE ty_s_dfies.

    FIELD-SYMBOLS <dfies> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    DATA temp9           TYPE cl_abap_structdescr=>component_table.
    DATA comps           LIKE temp9.
    DATA temp10          TYPE REF TO cl_abap_structdescr.
    DATA lo_struct       LIKE temp10.
    DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
    DATA new_table_desc  TYPE REF TO cl_abap_tabledescr.
    DATA comp            LIKE LINE OF comps.
    FIELD-SYMBOLS <value>      TYPE any.
    FIELD-SYMBOLS <value_dest> TYPE any.

    comps = temp9.

*    TYPES: BEGIN OF ty_s_dfies,
*             tabname     TYPE c LENGTH 30,
*             fieldname   TYPE c LENGTH 30,
*             langu       TYPE c LENGTH 1,
*             position    TYPE n LENGTH 4,
*             offset      TYPE n LENGTH 6,
*             domname     TYPE c LENGTH 30,
*             rollname    TYPE c LENGTH 30,
*             checktable  TYPE c LENGTH 30,
*             leng        TYPE n LENGTH 6,
*             intlen      TYPE n LENGTH 6,
*             outputlen   TYPE n LENGTH 6,
*             decimals    TYPE n LENGTH 6,
*             datatype    TYPE c LENGTH 4,
*             inttype     TYPE c LENGTH 1,
*             reftable    TYPE c LENGTH 30,
*             reffield    TYPE c LENGTH 30,
*             precfield   TYPE c LENGTH 30,
*             authorid    TYPE c LENGTH 3,
*             memoryid    TYPE c LENGTH 20,
*             logflag     TYPE c LENGTH 1,
*             mask        TYPE c LENGTH 20,
*             masklen     TYPE n LENGTH 4,
*             convexit    TYPE c LENGTH 5,
*             headlen     TYPE n LENGTH 2,
*             scrlen1     TYPE n LENGTH 2,
*             scrlen2     TYPE n LENGTH 2,
*             scrlen3     TYPE n LENGTH 2,
*             fieldtext   TYPE c LENGTH 60,
*             reptext     TYPE c LENGTH 55,
*             scrtext_s   TYPE c LENGTH 10,
*             scrtext_m   TYPE c LENGTH 20,
*             scrtext_l   TYPE c LENGTH 40,
*             keyflag     TYPE c LENGTH 1,
*             lowercase   TYPE c LENGTH 1,
*             mac         TYPE c LENGTH 1,
*             genkey      TYPE c LENGTH 1,
*             noforkey    TYPE c LENGTH 1,
*             valexi      TYPE c LENGTH 1,
*             noauthch    TYPE c LENGTH 1,
*             sign        TYPE c LENGTH 1,
*             dynpfld     TYPE c LENGTH 1,
*             f4availabl  TYPE c LENGTH 1,
*             comptype    TYPE c LENGTH 1,
*             lfieldname  TYPE c LENGTH 132,
*             ltrflddis   TYPE c LENGTH 1,
*             bidictrlc   TYPE c LENGTH 1,
*             outputstyle TYPE n LENGTH 2,
*             nohistory   TYPE c LENGTH 1,
*             ampmformat  TYPE c LENGTH 1,
*           END OF ty_s_dfies.
*    temp10 ?= cl_abap_structdescr=>describe_by_name( `TY_S_DFIES` ).

    temp10 ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

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
            EXPORTING
              val = `RTTI_BY_NAME_TAB_INITIAL`.
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

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_t_attri_on_cloud.

    DATA obj TYPE REF TO object.
    DATA lv_tabname TYPE c LENGTH 16.
    DATA lr_ddfields TYPE REF TO data.
    TYPES ty_c30 TYPE c LENGTH 30.
    TYPES temp1 TYPE STANDARD TABLE OF ty_c30 WITH DEFAULT KEY.
DATA names TYPE temp1.
    FIELD-SYMBOLS <any> TYPE any.
    FIELD-SYMBOLS <field> TYPE simple.
    FIELD-SYMBOLS <ddfields> TYPE ANY TABLE.
            DATA lv_method2 TYPE string.
            DATA workaround TYPE string.
            DATA temp22 TYPE REF TO cl_abap_structdescr.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp23 LIKE LINE OF lt_comp.
    DATA lr_comp LIKE REF TO temp23.
      DATA lv_check_key LIKE abap_false.
      DATA temp24 LIKE sy-subrc.
      DATA temp25 TYPE z2ui5_cl_util_ext=>ty_s_dfies.

* convert to correct type,
    lv_tabname = tabname.

    TRY.
        TRY.

            lv_method2 = `XCO_CP_ABAP_DICTIONARY`.
            CALL METHOD (lv_method2)=>(`DATABASE_TABLE`)
              EXPORTING
                iv_name           = lv_tabname
              RECEIVING
                ro_database_table = obj.
            ASSIGN obj->(`IF_XCO_DATABASE_TABLE~FIELDS->IF_XCO_DBT_FIELDS_FACTORY~KEY`) TO <any>.
            IF sy-subrc  <> 0.
* fallback to RTTI, KEY field does not exist in S/4 2020
              RAISE EXCEPTION TYPE cx_sy_dyn_call_illegal_class.
            ENDIF.
            obj = <any>.
            CALL METHOD obj->(`IF_XCO_DBT_FIELDS~GET_NAMES`)
              RECEIVING
                rt_names = names.
          CATCH cx_sy_dyn_call_illegal_class.

            workaround = `DDFIELDS`.
            CREATE DATA lr_ddfields TYPE (workaround).
            ASSIGN lr_ddfields->* TO <ddfields>.
            ASSERT sy-subrc = 0.

            temp22 ?= cl_abap_typedescr=>describe_by_name( lv_tabname ).
            <ddfields> = temp22->get_ddic_field_list( ).
            LOOP AT <ddfields> ASSIGNING <any>.
              ASSIGN COMPONENT `KEYFLAG` OF STRUCTURE <any> TO <field>.
              IF sy-subrc <> 0 OR <field> <> abap_true.
                CONTINUE.
              ENDIF.
              ASSIGN COMPONENT `FIELDNAME` OF STRUCTURE <any> TO <field>.
              ASSERT sy-subrc = 0.
              APPEND <field> TO names.
            ENDLOOP.
        ENDTRY.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.



    lt_comp  =  z2ui5_cl_util=>rtti_get_t_attri_by_any( tabname ).


    LOOP AT lt_comp REFERENCE INTO lr_comp.


      lv_check_key = abap_false.

      READ TABLE names WITH KEY table_line = lr_comp->name TRANSPORTING NO FIELDS.
      temp24 = sy-subrc.
      IF temp24 = 0.
        lv_check_key = abap_true.
      ENDIF.


      CLEAR temp25.
      temp25-fieldname = lr_comp->name.
      temp25-rollname = lr_comp->name.
      temp25-keyflag = lv_check_key.
      temp25-scrtext_s = lr_comp->name.
      temp25-scrtext_m = lr_comp->name.
      temp25-scrtext_l = lr_comp->name.
      INSERT temp25 INTO TABLE result.

    ENDLOOP.
*            structdescr->
*        <dfies> = structdescr->get_ddic_field_list( ).

*        LOOP AT <dfies> ASSIGNING <line>.
*
*          LOOP AT comps INTO comp.
*
*            ASSIGN COMPONENT comp-name OF STRUCTURE <line> TO <value>.
*            IF <value> IS NOT ASSIGNED.
*              CONTINUE.
*            ENDIF.
*
*            ASSIGN COMPONENT comp-name OF STRUCTURE s_dfies TO <value_dest>.
*            IF <value_dest> IS NOT ASSIGNED.
*              CONTINUE.
*            ENDIF.
*
*            <value_dest> = <value>.
*
*            UNASSIGN <value>.
*            UNASSIGN <value_dest>.
*
*          ENDLOOP.
*
*          APPEND s_dfies TO result.
*          CLEAR s_dfies.
*
*        ENDLOOP.



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
*    CALL METHOD (`XCO_CP_ABAP_DICTIONARY`)=>database_table
*      EXPORTING
*        iv_name           = tab
*      RECEIVING
*        ro_database_table = db.
*
*    ASSIGN db->(`IF_XCO_DATABASE_TABLE~FIELDS->IF_XCO_DBT_FIELDS_FACTORY~ALL`) TO <any>.
*
*    IF sy-subrc <> 0.
*      RETURN.
*    ENDIF.
*
*    fields = <any>.
*
*    CREATE DATA r_names TYPE (`SXCO_T_AD_FIELD_NAMES`).
*    ASSIGN r_names->* TO <Names>.
*    IF <Names> IS NOT ASSIGNED.
*      RETURN.
*    ENDIF.
*
*    CALL METHOD fields->(`IF_XCO_DBT_FIELDS~GET_NAMES`)
*      RECEIVING
*        rt_names = <Names>.
*
*    LOOP AT <Names> ASSIGNING <name>.
*
*      CLEAR t_param.
*
*      INSERT VALUE #( name  = `IV_NAME`
*                      kind  = cl_abap_objectdescr=>exporting
*                      value = REF #( <name> ) ) INTO TABLE t_param.
*      INSERT VALUE #( name  = `RO_FIELD`
*                      kind  = cl_abap_objectdescr=>receiving
*                      value = REF #( field ) ) INTO TABLE t_param.
*
*      CALL METHOD db->(`IF_XCO_DATABASE_TABLE~FIELD`)
*        PARAMETER-TABLE t_param.
*
*      ASSIGN t_param[ name = `RO_FIELD` ] TO FIELD-SYMBOL(<line>).
*      IF <line> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN <line>-value->* TO <fiel>.
*      IF <fiel> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      CALL METHOD <fiel>->(`IF_XCO_DBT_FIELD~CONTENT`)
*        RECEIVING
*          ro_content = content.
*
*      CREATE DATA r_content TYPE (`IF_XCO_DBT_FIELD_CONTENT=>TS_CONTENT`).
*      ASSIGN r_content->* TO FIELD-SYMBOL(<Content>) CASTING TYPE (`IF_XCO_DBT_FIELD_CONTENT=>TS_CONTENT`).
*      IF <content> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      CALL METHOD content->(`IF_XCO_DBT_FIELD_CONTENT~GET`)
*        RECEIVING
*          rs_content = <Content>.
*
*      ASSIGN COMPONENT `KEY_INDICATOR` OF STRUCTURE <content> TO FIELD-SYMBOL(<key>).
*      IF <key> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN COMPONENT `SHORT_DESCRIPTION` OF STRUCTURE <content> TO FIELD-SYMBOL(<text>).
*      IF <text> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*      ASSIGN COMPONENT `TYPE` OF STRUCTURE <content> TO FIELD-SYMBOL(<type>).
*      IF <type> IS NOT ASSIGNED.
*        CONTINUE.
*      ENDIF.
*
*      type = <type>.
*
*      CALL METHOD type->(`IF_XCO_DBT_FIELD_TYPE~GET_DATA_ELEMENT`)
*        RECEIVING
*          ro_data_element = element.
*
*      IF <text> IS INITIAL.
*        <text> = <name>.
*      ENDIF.
*
*      ASSIGN element->(`IF_XCO_AD_OBJECT~NAME`) TO FIELD-SYMBOL(<rname>).
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

    IF z2ui5_CL_UTIL=>context_check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_t_attri_on_cloud( table_name ).
    ELSE.
      result = rtti_get_t_attri_on_prem( table_name ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_table_desrc.

    DATA ddtext TYPE c LENGTH 60.
      DATA lan LIKE sy-langu.
          DATA lv_tabname TYPE string.

    IF langu IS NOT SUPPLIED.

      lan = sy-langu.
    ELSE.
      lan = langu.
    ENDIF.

    IF z2ui5_CL_UTIL=>context_check_abap_cloud( ) IS NOT INITIAL.

      ddtext = tabname.

    ELSE.

      TRY.

          lv_tabname = `dd02t`.
          SELECT SINGLE ddtext
            FROM (lv_tabname) INTO ddtext
            WHERE tabname    = tabname
              AND ddlanguage = lan
            .
        CATCH cx_root ##NO_HANDLER.
          " DD02T not available (e.g. JS transpiler runtime) - fall
          " back to the table name below
      ENDTRY.

    ENDIF.

    IF ddtext IS NOT INITIAL.
      result = ddtext.
    ELSE.
      result = tabname.
    ENDIF.

  ENDMETHOD.

  METHOD bus_search_help_read.

    TYPES temp2 TYPE TABLE OF string.
DATA lt_result_tab TYPE temp2.
    DATA ls_comp       TYPE abap_componentdescr.
    DATA lt_comps      TYPE abap_component_tab.
    DATA lo_datadescr  TYPE REF TO cl_abap_datadescr.
    DATA lr_line       TYPE REF TO data.

    " data ls_shlp type shlp_descr.

    DATA lr_shlp       TYPE REF TO data.

    DATA lv_type TYPE string.
    FIELD-SYMBOLS <shlp> TYPE any.
    DATA lv_tabname TYPE c LENGTH 30.
    DATA lv_fieldname TYPE c LENGTH 30.
      DATA lv_fm TYPE string.
        DATA lr_t_shlp TYPE REF TO data.
        DATA lv_type2 TYPE string.
        FIELD-SYMBOLS <shlp2> TYPE STANDARD TABLE.
        FIELD-SYMBOLS <row2> TYPE any.
      DATA temp26 LIKE LINE OF ms_shlp-interface.
      DATA r_interface LIKE REF TO temp26.
        FIELD-SYMBOLS <any> TYPE any.
        FIELD-SYMBOLS <value> TYPE any.
    DATA interface LIKE LINE OF ms_shlp-interface.
        DATA temp27 TYPE z2ui5_cl_util_ext=>ty_shlp_descr-selopt.
        DATA temp28 LIKE LINE OF temp27.
        DATA temp9 TYPE z2ui5_cl_util_ext=>ty_ddshselopt-option.
    DATA fieldrop LIKE LINE OF ms_shlp-fieldprop.
      DATA valule LIKE fieldrop-defaultval.
      DATA temp29 TYPE z2ui5_cl_util_ext=>ty_shlp_descr-selopt.
      DATA temp30 LIKE LINE OF temp29.
      DATA temp10 TYPE z2ui5_cl_util_ext=>ty_ddshselopt-option.
    DATA field_props LIKE LINE OF ms_shlp-fieldprop.
      DATA temp31 TYPE z2ui5_cl_util_ext=>ty_s_dfies_2.
      DATA temp32 TYPE z2ui5_cl_util_ext=>ty_s_dfies_2.
      DATA descption LIKE temp31.
    DATA temp33 LIKE sy-subrc.
    DATA strucdescr TYPE REF TO cl_abap_structdescr.
    DATA tabdescr TYPE REF TO cl_abap_tabledescr.
    FIELD-SYMBOLS <fs_target_tab> TYPE STANDARD TABLE.
    DATA result_line LIKE LINE OF lt_result_tab.
      FIELD-SYMBOLS <fs_line> TYPE data.
      DATA result_desc LIKE LINE OF mt_result_desc.
        FIELD-SYMBOLS <line_content> TYPE any.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <row> TYPE any.
    lv_type = `SHLP_DESCR`.
    CREATE DATA lr_shlp TYPE (lv_type).

    ASSIGN lr_shlp->* TO <shlp>.



    lv_tabname = mv_table.
    lv_fieldname = mv_fname.

    IF ms_shlp IS INITIAL.
      " Suchhilfe lesen

      lv_fm = `F4IF_DETERMINE_SEARCHHELP`.
      CALL FUNCTION lv_fm
        EXPORTING
          tabname           = lv_tabname
          fieldname         = lv_fieldname
        IMPORTING
          shlp              = <shlp>
        EXCEPTIONS
          field_not_found   = 1
          no_help_for_field = 2
          inconsistent_help = 3
          OTHERS            = 4.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = |F4IF_DETERMINE_SEARCHHELP failed for { lv_tabname }-{ lv_fieldname }|.
      ENDIF.
      MOVE-CORRESPONDING <shlp> TO ms_shlp.

      IF ms_shlp-intdescr-issimple = abap_false.

*      DATA lt_shlp       TYPE shlp_desct.


        lv_type2 = `SHLP_DESCT`.
        CREATE DATA lr_t_shlp TYPE (lv_type2).

        ASSIGN lr_t_shlp->* TO <shlp2>.

        lv_fm = `F4IF_EXPAND_SEARCHHELP`.
        CALL FUNCTION lv_fm
          EXPORTING
            shlp_top = ms_shlp
          IMPORTING
            shlp_tab = <shlp2>.

*        DATA(ls_row) = CORRESPONDING #( <shlp2>[ 1 ] OPTIONAL ).

        READ TABLE <shlp2> INDEX 1 ASSIGNING <row2>.
        MOVE-CORRESPONDING <row2> TO ms_shlp.
      ENDIF.
    ENDIF.

    IF mr_data IS BOUND.
      " Values from Caller app to Interface Values


      LOOP AT ms_shlp-interface REFERENCE INTO r_interface WHERE value IS INITIAL.


        ASSIGN mr_data->* TO <any>.

        ASSIGN COMPONENT r_interface->shlpfield OF STRUCTURE <any> TO <value>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        r_interface->value = <value>.

      ENDLOOP.
    ENDIF.

    " Interface Fixed Values to Selopt

    LOOP AT ms_shlp-interface INTO interface.

      " Match the name of the SH Field to the Input field name
      IF interface-valfield = mv_fname.
        mv_shlpfield = interface-shlpfield.
      ENDIF.

      IF interface-value IS NOT INITIAL.


        CLEAR temp27.
        temp27 = ms_shlp-selopt.

        temp28-shlpfield = interface-shlpfield.
        temp28-shlpname = interface-valtabname.

        IF interface-value CA `*`.
          temp9 = `CP`.
        ELSE.
          temp9 = `EQ`.
        ENDIF.
        temp28-option = temp9.
        temp28-sign = `I`.
        temp28-low = interface-value.
        INSERT temp28 INTO TABLE temp27.
        ms_shlp-selopt = temp27.

      ENDIF.

    ENDLOOP.


    LOOP AT ms_shlp-fieldprop INTO fieldrop.

      IF fieldrop-defaultval IS INITIAL.
        CONTINUE.
      ENDIF.


      valule = fieldrop-defaultval.
      REPLACE ALL OCCURRENCES OF `'` IN valule WITH ``.


      CLEAR temp29.
      temp29 = ms_shlp-selopt.

      temp30-shlpfield = fieldrop-fieldname.

      IF fieldrop-defaultval CA `*`.
        temp10 = `CP`.
      ELSE.
        temp10 = `EQ`.
      ENDIF.
      temp30-option = temp10.
      temp30-sign = `I`.
      temp30-low = valule.
      INSERT temp30 INTO TABLE temp29.
      ms_shlp-selopt = temp29.

    ENDLOOP.

    CREATE DATA lr_shlp TYPE (lv_type).
    ASSIGN lr_shlp->* TO <shlp>.
    CLEAR: <shlp>.
    MOVE-CORRESPONDING ms_shlp TO <shlp>.

    lv_fm = `F4IF_SELECT_VALUES`.
    CALL FUNCTION lv_fm
      EXPORTING
        shlp           = <shlp>
        sort           = space
        call_shlp_exit = abap_true
      TABLES
        record_tab     = lt_result_tab
        recdescr_tab   = mt_result_desc.

    SORT ms_shlp-fieldprop BY shlplispos ASCENDING.


    LOOP AT ms_shlp-fieldprop INTO field_props WHERE shlplispos IS NOT INITIAL.


      CLEAR temp31.

      READ TABLE mt_result_desc INTO temp32 WITH KEY fieldname = field_props-fieldname.
      IF sy-subrc = 0.
        temp31 = temp32.
      ENDIF.

      descption = temp31.

      ls_comp-name  = descption-fieldname.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( descption-rollname ).
      APPEND ls_comp TO lt_comps.

    ENDLOOP.


    READ TABLE lt_comps WITH KEY name = `ROW_ID` TRANSPORTING NO FIELDS.
    temp33 = sy-subrc.
    IF NOT temp33 = 0.
      lo_datadescr ?= cl_abap_datadescr=>describe_by_name( `INT4` ).
      ls_comp-name  = `ROW_ID`.
      ls_comp-type ?= lo_datadescr.
      APPEND ls_comp TO lt_comps.
    ENDIF.


    strucdescr = cl_abap_structdescr=>create( p_components = lt_comps ).


    tabdescr = cl_abap_tabledescr=>create( p_line_type = strucdescr ).

    IF mt_data IS NOT BOUND.
      CREATE DATA mt_data TYPE HANDLE tabdescr.
    ENDIF.


    ASSIGN mt_data->* TO <fs_target_tab>.

    CLEAR <fs_target_tab>.

    " we don`t want to lose all inputs in row ...
    IF ms_data_row IS NOT BOUND.
      CREATE DATA ms_data_row TYPE HANDLE strucdescr.
    ENDIF.


    LOOP AT lt_result_tab INTO result_line.

      CREATE DATA lr_line TYPE HANDLE strucdescr.

      ASSIGN lr_line->* TO <fs_line>.


      LOOP AT mt_result_desc INTO result_desc.


        ASSIGN COMPONENT result_desc-fieldname OF STRUCTURE <fs_line>
               TO <line_content>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF result_desc-leng < result_desc-intlen.
          " interne Darstellung anders als externe Darstellung
          " UNICODE, offset halbieren
          result_desc-offset = result_desc-offset / 2.
        ENDIF.

        TRY.
            <line_content> = result_line+result_desc-offset(result_desc-outputlen).
          CATCH cx_root.

            TRY.
                " String table will crash if value length <> outputlen
                <line_content> = result_line+result_desc-offset.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
        ENDTRY.

      ENDLOOP.

      INSERT <fs_line> INTO TABLE <fs_target_tab>.

    ENDLOOP.

    " Set default values
    LOOP AT ms_shlp-interface INTO interface.

      IF interface-value IS NOT INITIAL.

        UNASSIGN <any>.
        ASSIGN ms_data_row->* TO <any>.
        ASSIGN COMPONENT interface-shlpfield OF STRUCTURE <any> TO <value>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        <value> = interface-value.

      ENDIF.

    ENDLOOP.

*    LOOP AT ms_shlp-fieldprop INTO fieldrop.
*
*      IF fieldrop-defaultval IS NOT INITIAL.
*
*        ASSIGN COMPONENT fieldrop-fieldname OF STRUCTURE ms_data_row->* TO <value>.
*
*        IF sy-subrc <> 0.
*          CONTINUE.
*        ENDIF.
*        <value> = fieldrop-defaultval.
*       REPLACE ALL OCCURRENCES OF ``` in <value> with ``.
*      ENDIF.
*
*    ENDLOOP.

*    set_row_id( ).




    ASSIGN mt_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.


      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <line> TO <row>.
      IF <row> IS ASSIGNED.
        <row> = sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.



  METHOD tab_get_where_by_dfies.

    DATA val TYPE string.

    DATA temp34 LIKE LINE OF it_dfies.
    DATA dfies LIKE REF TO temp34.
      FIELD-SYMBOLS <row> TYPE data.
      FIELD-SYMBOLS <value> TYPE any.
        DATA and TYPE string.
        DATA escape TYPE string.
    LOOP AT it_dfies REFERENCE INTO dfies.

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.


      ASSIGN ms_data_row->* TO <row>.


      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE <row> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF <value> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS NOT INITIAL.

        and = ` AND `.
      ENDIF.

      IF <value> CA `_`.

        escape = `ESCAPE '#'`.
      ELSE.
        CLEAR escape.
      ENDIF.

      val = <value>.

      IF val CA `_`.
        REPLACE ALL OCCURRENCES OF `_` IN val WITH `#_`.
      ENDIF.

      result = |{ result }{ and } ( { dfies->fieldname } LIKE '%{ val }%' { escape } )|.

    ENDLOOP.

  ENDMETHOD.

  METHOD _get_e071k_tabkey.

    DATA lv_type       TYPE c LENGTH 1.
    DATA lv_tabkey     TYPE c LENGTH 999.
    DATA lv_tabkey_len TYPE i.
    DATA lv_field_len  TYPE i.
    DATA lv_offset     TYPE i.

    DATA s_dfies LIKE LINE OF dfies.
      FIELD-SYMBOLS <value> TYPE any.
    LOOP AT dfies INTO s_dfies WHERE keyflag = abap_true.


      ASSIGN COMPONENT s_dfies-fieldname OF STRUCTURE line TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      lv_type = cl_abap_typedescr=>describe_by_data( <value> )->type_kind.

      IF lv_type NA 'CDNT'.
        lv_tabkey+lv_tabkey_len = '*'.
        rv_tabkey = lv_tabkey.
        RETURN.
      ELSE.
        lv_field_len = cl_abap_typedescr=>describe_by_data( <value> )->length / z2ui5_cl_util=>cv_char_util_charsize.
      ENDIF.

      lv_field_len = cl_abap_typedescr=>describe_by_data( <value> )->length / z2ui5_cl_util=>cv_char_util_charsize.
      lv_tabkey+lv_tabkey_len(lv_field_len) = <value>.
      lv_tabkey_len = lv_tabkey_len + lv_field_len.

    ENDLOOP.

    IF lv_tabkey_len > 119.

      IF lv_tabkey CS '_'.
        lv_offset = sy-fdpos.
        lv_tabkey+lv_offset = '*'.
      ELSE.
        lv_tabkey+119 = '*'.
      ENDIF.

    ENDIF.
    rv_tabkey = lv_tabkey.
  ENDMETHOD.

  METHOD bus_tr_add.
      FIELD-SYMBOLS <e071> TYPE any.
      FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <t_e071> TYPE STANDARD TABLE.
      DATA r_e071k TYPE REF TO data.
      DATA r_e071 TYPE REF TO data.
      DATA fb1 TYPE c LENGTH 27.
      DATA fb2 TYPE c LENGTH 25.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.

    ELSE.





      " We need to set the MANDT is necessary
      set_mandt( ir_data ).


      r_e071k = _set_e071k( ir_data      = ir_data
                                  iv_tabname   = iv_tabname
                                  is_transport = is_transport ).
      ASSIGN r_e071k->* TO <e071>.
      IF <e071> IS INITIAL.
        RETURN.
      ENDIF.


      r_e071 = _set_e071( iv_tabname   = iv_tabname
                                is_transport = is_transport ).

      ASSIGN r_e071k->* TO <t_e071k>.
      ASSIGN r_e071->* TO <t_e071>.


      fb1 = 'TR_APPEND_TO_COMM_OBJS_KEYS'.
      CALL FUNCTION fb1
        EXPORTING
          wi_trkorr     = is_transport-transport
          iv_dialog     = abap_false
        TABLES
          wt_e071       = <t_e071>
          wt_e071k      = <t_e071k>
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error.
      ENDIF.


      fb2 = 'TR_SORT_AND_COMPRESS_COMM'.
      CALL FUNCTION fb2
        EXPORTING
          iv_trkorr     = is_transport-task
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD _set_e071k.

    DATA t_e071k TYPE REF TO data.
    DATA s_e071k TYPE REF TO data.

    FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <s_e071k> TYPE any.
    FIELD-SYMBOLS <value>   TYPE any.
    FIELD-SYMBOLS <tab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>    TYPE any.

    DATA t_comp TYPE abap_component_tab.
        DATA struct_desc TYPE REF TO cl_abap_structdescr.
        DATA table_desc TYPE REF TO cl_abap_tabledescr.
    DATA dfies TYPE z2ui5_cl_util_ext=>ty_t_dfies.
    t_comp = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( 'E071K' ).

    TRY.


        struct_desc = cl_abap_structdescr=>create( t_comp ).


        table_desc = cl_abap_tabledescr=>create( p_line_type  = struct_desc
                                                       p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071k TYPE HANDLE table_desc.
        CREATE DATA s_e071k TYPE HANDLE struct_desc.

        ASSIGN t_e071k->* TO <t_e071k>.
        ASSIGN s_e071k->* TO <s_e071k>.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    dfies = rtti_get_t_dfies_by_table_name( iv_tabname ).

*   is_transport-transport = assign_value( component = 'TRKORR'
*                                          structure = <s_e071k> ).                                         )

    ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = is_transport-task.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'PGMID' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'R3TR'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'MASTERTYPE' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJECT' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'MASTERNAME' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJNAME' OF STRUCTURE <s_e071k> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.

    ASSIGN ir_data->* TO <tab>.

*    IF <tab> IS INITIAL.
*      RETURN.
*    ENDIF.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT 'TABKEY' OF STRUCTURE <s_e071k> TO <value>.
      IF <value> IS NOT ASSIGNED.
        RETURN.
      ELSE.
        <value> = _get_e071k_tabkey( dfies = dfies
                                     line  = <line> ).
      ENDIF.

      APPEND <s_e071k> TO <t_e071k>.

    ENDLOOP.

    result = t_e071k.

  ENDMETHOD.

  METHOD _set_e071.

    DATA t_e071 TYPE REF TO data.
    DATA s_e071 TYPE REF TO data.

    FIELD-SYMBOLS <t_e071> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <s_e071> TYPE any.
    FIELD-SYMBOLS <value>  TYPE any.

    DATA t_comp TYPE abap_component_tab.
        DATA struct_desc_new TYPE REF TO cl_abap_structdescr.
        DATA table_desc_new TYPE REF TO cl_abap_tabledescr.
    t_comp = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( 'E071' ).

    TRY.


        struct_desc_new = cl_abap_structdescr=>create( t_comp ).


        table_desc_new = cl_abap_tabledescr=>create( p_line_type  = struct_desc_new
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071 TYPE HANDLE table_desc_new.
        CREATE DATA s_e071 TYPE HANDLE struct_desc_new.

        ASSIGN t_e071->* TO <t_e071>.
        ASSIGN s_e071->* TO <s_e071>.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = is_transport-task.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'PGMID' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'R3TR'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJECT' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'TABU'.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJ_NAME' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = iv_tabname.
    ENDIF.
    UNASSIGN <value>.
    ASSIGN COMPONENT 'OBJFUNC' OF STRUCTURE <s_e071> TO <value>.
    IF <value> IS NOT ASSIGNED.
      RETURN.
    ELSE.
      <value> = 'K'.
    ENDIF.
    UNASSIGN <value>.

    APPEND <s_e071> TO <t_e071>.

    result = t_e071.

  ENDMETHOD.

  METHOD _read_e070.

    DATA lo_tab  TYPE REF TO data.
    DATA lo_line TYPE REF TO data.
    DATA ls_data TYPE ty_s_transport.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <value> TYPE any.

    DATA table_name TYPE c LENGTH 4.
        DATA t_comp TYPE abap_component_tab.
        DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
        DATA new_table_desc TYPE REF TO cl_abap_tabledescr.
        DATA where TYPE string.
    table_name = 'E070'.

    TRY.

        t_comp = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( table_name ).


        new_struct_desc = cl_abap_structdescr=>create( t_comp ).


        new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA lo_tab TYPE HANDLE new_table_desc.
        CREATE DATA lo_line TYPE HANDLE new_struct_desc.

        ASSIGN lo_tab->* TO <table>.
        ASSIGN lo_line->* TO <line>.


        where =
        |( TRFUNCTION EQ 'Q' ) AND ( TRSTATUS EQ 'D' ) AND ( KORRDEV EQ 'CUST' ) AND ( AS4USER EQ '{ sy-uname }' )|.

        SELECT trkorr
               trfunction
               trstatus
               tarsystem
               korrdev
               as4user
               as4date
               as4time
               strkorr
          FROM (table_name) INTO TABLE <table>
          WHERE (where)
          .
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    LOOP AT <table> INTO <line>.

      ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.
        ls_data-transport = <value>.
      ENDIF.

      UNASSIGN <value>.

      ASSIGN COMPONENT 'STRKORR' OF STRUCTURE <line> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ELSE.
        ls_data-task = <value>.
      ENDIF.

      UNASSIGN <value>.

      APPEND ls_data TO mt_data.

    ENDLOOP.

  ENDMETHOD.

  METHOD bus_tr_read.
      DATA lo_tab TYPE REF TO data.
      DATA lo_line TYPE REF TO data.
      FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <value> TYPE any.
      DATA table_name TYPE c LENGTH 4.
          DATA t_comp TYPE abap_component_tab.
          DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
          DATA new_table_desc TYPE REF TO cl_abap_tabledescr.
          DATA index TYPE i.
          DATA line LIKE LINE OF mt_data.
              DATA where TYPE string.
          DATA data TYPE REF TO z2ui5_cl_util_ext=>ty_s_transport.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.

*          data(lo_current_user) = xco_cp=>sy->user( ).
*
*    DATA(lo_kind_filter) = xco_cp_transport=>filter->kind( xco_cp_transport=>kind->task ).
*    DATA(lo_owner_filter) = xco_cp_transport=>filter->owner( xco_cp_abap_sql=>constraint->equal( lo_current_user->name ) ).
*    DATA(lo_status_filter) = xco_cp_transport=>filter->status( xco_cp_transport=>status->modifiable ).
*    DATA(lo_type_filter) = xco_cp_transport=>filter->type( io_type = xco_cp_transport=>type->customizing_task ).
*    DATA(lt_transports) = xco_cp_cts=>transports->where( VALUE #( ( lo_kind_filter )
*                                                                  ( lo_owner_filter )
*                                                                  ( lo_status_filter )
*                                                                  ( lo_type_filter ) )
*    )->resolve( xco_cp_transport=>resolution->request ).
*
*    LOOP AT lt_transports INTO DATA(lo_transport).
*      DATA(lo_transport_request) = lo_transport->get_request( ).
*
*      DATA(prop) = lo_transport_request->properties( )->get( ).
*
*      DATA(tasks) = lo_transport_request->get_tasks( ).
*
*      LOOP AT tasks INTO DATA(task).
*
*        IF lo_current_user->name = task->properties( )->get_owner( )->name.
*
*          DATA(data) = VALUE ty_s_data( short_description = prop-short_description
*                                        transport         = lo_transport_request->value
*                                        task              = task->value ).
*          APPEND data TO mt_data.
*
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDLOOP.

    ELSE.








      _read_e070( CHANGING mt_data = mt_data ).


      table_name = 'E07T'.

      TRY.

          t_comp = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( table_name ).


          new_struct_desc = cl_abap_structdescr=>create( t_comp ).


          new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                             p_table_kind = cl_abap_tabledescr=>tablekind_std ).

          CREATE DATA lo_tab TYPE HANDLE new_table_desc.
          CREATE DATA lo_line TYPE HANDLE new_struct_desc.

          ASSIGN lo_tab->* TO <table>.
          ASSIGN lo_line->* TO <line>.


          index = 0.


          LOOP AT mt_data INTO line.
            index = index + 1.
            IF index = 1.

              where = |TRKORR EQ '{ line-task }'|.
            ELSE.
              where = |{ where } OR TRKORR EQ '{ line-task }'|.
            ENDIF.
            where = |( { where } )|.
          ENDLOOP.

          SELECT trkorr
                 langu
                 as4text
            FROM (table_name) INTO TABLE <table>
            WHERE (where)
            .
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      LOOP AT <table> INTO <line>.

        ASSIGN COMPONENT 'TRKORR' OF STRUCTURE <line> TO <value>.
        IF <value> IS NOT ASSIGNED.
          CONTINUE.
        ELSE.


          READ TABLE mt_data REFERENCE INTO data WITH KEY task = <value>.
          IF sy-subrc = 0.

            ASSIGN COMPONENT 'AS4TEXT' OF STRUCTURE <line> TO <value>.
            IF <value> IS NOT ASSIGNED.
              CONTINUE.
            ELSE.

              data->short_description = <value>.

            ENDIF.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD set_mandt.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
      FIELD-SYMBOLS <row> TYPE any.

    ASSIGN ir_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.


      ASSIGN COMPONENT `MANDT` OF STRUCTURE <line> TO <row>.
      IF <row> IS ASSIGNED.

        TRY.
            <row> = sy-mandt.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD conv_exit.
      DATA conv TYPE string.
      DATA conex TYPE c LENGTH 30.
      DATA lv_tab TYPE c LENGTH 5.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.

    ELSE.


      conv = |CONVERSION_EXIT_{ name-convexit }_INPUT|.


      lv_tab = 'TFDIR'.

      SELECT SINGLE funcname FROM (lv_tab) INTO conex
        WHERE funcname = conv
        .

      IF sy-subrc = 0.

        CALL FUNCTION conex
          EXPORTING
            input         = val
          IMPORTING
            output        = result
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error.
        ENDIF.


      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD bal_search.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp3 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp3.
      DATA lv_class TYPE string.
          DATA temp35 TYPE string.
          DATA lv_obj_f LIKE temp35.
          DATA temp36 TYPE string.
          DATA lv_sub_f LIKE temp36.
          DATA temp37 TYPE string.
          DATA lv_id_f LIKE temp37.
            DATA temp38 TYPE d.
            DATA lv_from LIKE temp38.
            DATA temp39 TYPE d.
            DATA lv_to LIKE temp39.
          DATA lo_log LIKE LINE OF lt_logs.
            DATA temp40 TYPE ty_s_bal_header.
            DATA ls_hdr_c LIKE temp40.
                DATA lo_header TYPE REF TO object.
    DATA lv_fm TYPE string.
    DATA lr_filter TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.
    FIELD-SYMBOLS <headers> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <header> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline> TYPE any.
    DATA lr_rline TYPE REF TO data.
          DATA temp41 TYPE d.
          DATA temp42 TYPE d.
          DATA temp43 TYPE ty_s_bal_header.
          DATA ls_hdr LIKE temp43.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use CL_BALI_LOG_FILTER + CL_BALI_LOG_DB






      TRY.
          lv_class = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              filter = lo_filter.


          IF object IS NOT INITIAL.
            temp35 = object.
          ELSE.
            temp35 = ``.
          ENDIF.

          lv_obj_f = temp35.

          IF subobject IS NOT INITIAL.
            temp36 = subobject.
          ELSE.
            temp36 = ``.
          ENDIF.

          lv_sub_f = temp36.

          IF id IS NOT INITIAL.
            temp37 = id.
          ELSE.
            temp37 = ``.
          ENDIF.

          lv_id_f = temp37.
          CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = lv_obj_f
              subobject   = lv_sub_f
              external_id = lv_id_f.

          IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.

            IF date_from IS NOT INITIAL.
              temp38 = date_from.
            ELSE.
              temp38 = '19000101'.
            ENDIF.

            lv_from = temp38.

            IF date_to IS NOT INITIAL.
              temp39 = date_to.
            ELSE.
              temp39 = sy-datum.
            ENDIF.

            lv_to = temp39.
            CALL METHOD lo_filter->(`SET_CREATE_DATE`)
              EXPORTING
                from_date = lv_from
                to_date   = lv_to.
          ENDIF.

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter           = lo_filter
              read_only_header = abap_true
            RECEIVING
              log_table        = lt_logs.


          LOOP AT lt_logs INTO lo_log.

            CLEAR temp40.

            ls_hdr_c = temp40.
            TRY.

                CALL METHOD lo_log->(`GET_HEADER`)
                  RECEIVING
                    header = lo_header.
                CALL METHOD lo_header->(`GET_OBJECT`)
                  RECEIVING
                    object = ls_hdr_c-object.
                CALL METHOD lo_header->(`GET_SUBOBJECT`)
                  RECEIVING
                    subobject = ls_hdr_c-subobject.
                CALL METHOD lo_header->(`GET_EXTERNAL_ID`)
                  RECEIVING
                    external_id = ls_hdr_c-external_id.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            INSERT ls_hdr_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use BAL_DB_SEARCH











    TRY.
        CREATE DATA lr_filter TYPE ('BAL_S_LFIL').
        ASSIGN lr_filter->* TO <filter>.

        IF object IS NOT INITIAL.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = object.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF subobject IS NOT INITIAL.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = subobject.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF id IS NOT INITIAL.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = id.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.
          ASSIGN COMPONENT `ALDATE` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `BT`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>.

          IF date_from IS NOT INITIAL.
            temp41 = date_from.
          ELSE.
            temp41 = '19000101'.
          ENDIF.
          <comp> = temp41.
          ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>.

          IF date_to IS NOT INITIAL.
            temp42 = date_to.
          ELSE.
            temp42 = sy-datum.
          ENDIF.
          <comp> = temp42.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        IF user IS NOT INITIAL.
          ASSIGN COMPONENT `ALUSER` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = user.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        CREATE DATA lr_headers TYPE ('BALHDR_T').
        ASSIGN lr_headers->* TO <headers>.

        lv_fm = `BAL_DB_SEARCH`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log_filter = <filter>
          IMPORTING
            e_t_log_header = <headers>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <headers> ASSIGNING <header>.

          CLEAR temp43.

          ls_hdr = temp43.
          ASSIGN COMPONENT `LOG_HANDLE` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_handle = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-object = <comp>. ENDIF.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-subobject = <comp>. ENDIF.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-external_id = <comp>. ENDIF.
          ASSIGN COMPONENT `ALDATE` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_date = <comp>. ENDIF.
          ASSIGN COMPONENT `ALTIME` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-log_time = <comp>. ENDIF.
          ASSIGN COMPONENT `ALUSER` OF STRUCTURE <header> TO <comp>.
          IF sy-subrc = 0. ls_hdr-user = <comp>. ENDIF.
          INSERT ls_hdr INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_read_latest.

    DATA lt_msgs TYPE z2ui5_cl_util=>ty_t_msg.
      DATA temp44 LIKE LINE OF lt_msgs.
      DATA temp45 LIKE sy-tabix.
    lt_msgs = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    IF lt_msgs IS NOT INITIAL.


      temp45 = sy-tabix.
      READ TABLE lt_msgs INDEX lines( lt_msgs ) INTO temp44.
      sy-tabix = temp45.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result = temp44.
    ENDIF.

  ENDMETHOD.

  METHOD bal_delete_before.

    DATA temp46 TYPE d.
    DATA lv_cutoff LIKE temp46.
      DATA lo_filter_c TYPE REF TO object.
      DATA lo_db_c TYPE REF TO object.
      TYPES temp4 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs_c TYPE temp4.
      DATA lv_cls TYPE string.
          DATA temp47 TYPE string.
          DATA lv_sub_c LIKE temp47.
          DATA temp48 TYPE d.
          DATA lo_log_c LIKE LINE OF lt_logs_c.
    DATA lv_fm TYPE string.
    DATA lr_filter TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
    DATA lr_rline TYPE REF TO data.
    temp46 = sy-datum - days.

    lv_cutoff = temp46.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use CL_BALI_LOG_DB to delete via filter






      TRY.
          lv_cls = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_cls)=>(`CREATE`)
            RECEIVING
              filter = lo_filter_c.


          IF subobject IS NOT INITIAL.
            temp47 = subobject.
          ELSE.
            temp47 = ``.
          ENDIF.

          lv_sub_c = temp47.
          CALL METHOD lo_filter_c->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = object
              subobject   = lv_sub_c
              external_id = ``.


          temp48 = '19000101'.
          CALL METHOD lo_filter_c->(`SET_CREATE_DATE`)
            EXPORTING
              from_date = temp48
              to_date   = lv_cutoff.

          lv_cls = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_cls)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db_c.

          CALL METHOD lo_db_c->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter_c
            RECEIVING
              log_table = lt_logs_c.


          LOOP AT lt_logs_c INTO lo_log_c.
            CALL METHOD lo_db_c->(`DELETE_LOG`)
              EXPORTING
                log = lo_log_c.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use BAL_DB_DELETE








    TRY.
        CREATE DATA lr_filter TYPE ('BAL_S_LFIL').
        ASSIGN lr_filter->* TO <filter>.

        ASSIGN COMPONENT `OBJECT` OF STRUCTURE <filter> TO <range>.
        CREATE DATA lr_rline LIKE LINE OF <range>.
        ASSIGN lr_rline->* TO <rline>.
        ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
        ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = object.
        INSERT <rline> INTO TABLE <range>.

        IF subobject IS NOT INITIAL.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <filter> TO <range>.
          CREATE DATA lr_rline LIKE LINE OF <range>.
          ASSIGN lr_rline->* TO <rline>.
          ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
          ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `EQ`.
          ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = subobject.
          INSERT <rline> INTO TABLE <range>.
        ENDIF.

        ASSIGN COMPONENT `ALDATE` OF STRUCTURE <filter> TO <range>.
        CREATE DATA lr_rline LIKE LINE OF <range>.
        ASSIGN lr_rline->* TO <rline>.
        ASSIGN COMPONENT `SIGN` OF STRUCTURE <rline> TO <comp>. <comp> = `I`.
        ASSIGN COMPONENT `OPTION` OF STRUCTURE <rline> TO <comp>. <comp> = `BT`.
        ASSIGN COMPONENT `LOW` OF STRUCTURE <rline> TO <comp>. <comp> = '19000101'.
        ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>. <comp> = lv_cutoff.
        INSERT <rline> INTO TABLE <range>.

        lv_fm = `BAL_DB_DELETE`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_s_log_filter = <filter>
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_read_by_type.

    DATA lt_all TYPE z2ui5_cl_util=>ty_t_msg.
    DATA ls_msg LIKE LINE OF lt_all.
    lt_all = bal_read( object    = object
                             subobject = subobject
                             id        = id ).


    LOOP AT lt_all INTO ls_msg
         WHERE type = msg_type.
      INSERT ls_msg INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD bal_count.

    DATA lt_msgs TYPE z2ui5_cl_util=>ty_t_msg.
    lt_msgs = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    result = lines( lt_msgs ).

  ENDMETHOD.

  METHOD bal_read.
TYPES BEGIN OF ty_item.
TYPES log_item_number TYPE i.
TYPES item TYPE REF TO object.
TYPES END OF ty_item.
      TYPES temp5 TYPE STANDARD TABLE OF ty_item.
DATA lt_items TYPE temp5.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp6 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp6.
      DATA lv_text TYPE string.
      DATA lv_class TYPE string.
      DATA lv_severity TYPE c LENGTH 1.
      DATA lv_msgid TYPE string.
      DATA lv_msgno TYPE string.
      DATA lv_msgv1 TYPE string.
      DATA lv_msgv2 TYPE string.
      DATA lv_msgv3 TYPE string.
      DATA lv_msgv4 TYPE string.
          DATA lo_log LIKE LINE OF lt_logs.
            DATA temp49 LIKE lt_items.
            DATA ls_item LIKE LINE OF lt_items.
              DATA temp50 TYPE z2ui5_cl_util=>ty_s_msg.
              DATA ls_msg LIKE temp50.
      DATA lv_fm TYPE string.
      DATA lr_handles TYPE REF TO data.
      DATA lr_single TYPE REF TO data.
      DATA lr_msgh TYPE REF TO data.
      DATA lr_msg TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle> TYPE any.
      FIELD-SYMBOLS <single> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <msgh> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <mh> TYPE any.
      FIELD-SYMBOLS <msg> TYPE any.
          DATA lx_read TYPE REF TO cx_root.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.

      " Load the persisted logs (incl. items) via the released filter API and map
      " each item back to the framework's z2ui5_cl_util=>ty_s_msg structure with full metadata.

















      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.


          LOOP AT lt_logs INTO lo_log.


            CLEAR temp49.
            lt_items = temp49.
            CALL METHOD lo_log->(`GET_ALL_ITEMS`)
              RECEIVING
                item_table = lt_items.


            LOOP AT lt_items INTO ls_item.
              IF ls_item-item IS NOT BOUND.
                CONTINUE.
              ENDIF.


              CLEAR temp50.

              ls_msg = temp50.

              lv_text = ``.
              CALL METHOD ls_item-item->(`GET_MESSAGE_TEXT`)
                RECEIVING
                  message_text = lv_text.
              ls_msg-text = lv_text.

              TRY.
                  CALL METHOD ls_item-item->(`GET_SEVERITY`)
                    RECEIVING
                      severity = lv_severity.
                  ls_msg-type = lv_severity.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_ID`)
                    RECEIVING
                      id = lv_msgid.
                  ls_msg-id = lv_msgid.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_NUMBER`)
                    RECEIVING
                      number = lv_msgno.
                  ls_msg-no = lv_msgno.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              TRY.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_1`)
                    RECEIVING
                      variable_1 = lv_msgv1.
                  ls_msg-v1 = lv_msgv1.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_2`)
                    RECEIVING
                      variable_2 = lv_msgv2.
                  ls_msg-v2 = lv_msgv2.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_3`)
                    RECEIVING
                      variable_3 = lv_msgv3.
                  ls_msg-v3 = lv_msgv3.
                  CALL METHOD ls_item-item->(`GET_MESSAGE_VARIABLE_4`)
                    RECEIVING
                      variable_4 = lv_msgv4.
                  ls_msg-v4 = lv_msgv4.
                CATCH cx_root ##NO_HANDLER.
              ENDTRY.

              INSERT ls_msg INTO TABLE result.
            ENDLOOP.

          ENDLOOP.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.













      TRY.
          lr_handles = bal_std_load_handles( object    = object
                                             subobject = subobject
                                             id        = id ).
          IF lr_handles IS NOT BOUND.
            RETURN.
          ENDIF.
          ASSIGN lr_handles->* TO <handles>.

          CREATE DATA lr_single TYPE ('BAL_T_LOGH').
          ASSIGN lr_single->* TO <single>.
          CREATE DATA lr_msgh TYPE ('BAL_T_MSGH').
          ASSIGN lr_msgh->* TO <msgh>.
          CREATE DATA lr_msg TYPE ('BAL_S_MSG').
          ASSIGN lr_msg->* TO <msg>.

          LOOP AT <handles> ASSIGNING <handle>.

            CLEAR <single>.
            INSERT <handle> INTO TABLE <single>.

            CLEAR <msgh>.
            lv_fm = `BAL_GLB_SEARCH_MSG`.
            CALL FUNCTION lv_fm
              EXPORTING
                i_t_log_handle = <single>
              IMPORTING
                e_t_msg_handle = <msgh>
              EXCEPTIONS
                OTHERS         = 1.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            LOOP AT <msgh> ASSIGNING <mh>.
              CLEAR <msg>.
              lv_fm = `BAL_LOG_MSG_READ`.
              CALL FUNCTION lv_fm
                EXPORTING
                  i_s_msg_handle = <mh>
                IMPORTING
                  e_s_msg        = <msg>
                EXCEPTIONS
                  OTHERS         = 1.
              IF sy-subrc = 0.
                INSERT bal_std_map_msg( <msg> ) INTO TABLE result.
              ENDIF.
            ENDLOOP.

          ENDLOOP.


        CATCH cx_root INTO lx_read.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_read.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_create.
      DATA lo_header TYPE REF TO object.
      DATA lo_log TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      DATA lv_class TYPE string.
      DATA lv_fm TYPE string.
      DATA lr_log TYPE REF TO data.
      DATA lr_handle TYPE REF TO data.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <log> TYPE any.
      FIELD-SYMBOLS <handle> TYPE any.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <comp> TYPE any.
          DATA lx_create TYPE REF TO cx_root.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.

      " ABAP Cloud: released Business Application Log API (cl_bali_*).
      " All access is dynamic so this class still compiles on lower releases.
      " The class names are kept in variables - a string literal inside the
      " dynamic component selector ( '...' )=>( '...' ) is not valid ABAP.
      " Returning parameter names follow the released API (header/log/db_handler).





      TRY.
          lv_class = `CL_BALI_HEADER_SETTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            EXPORTING
              object      = object
              subobject   = subobject
              external_id = id
            RECEIVING
              header      = lo_header.

          lv_class = `CL_BALI_LOG`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              log = lo_log.

          CALL METHOD lo_log->(`SET_HEADER`)
            EXPORTING
              header = lo_header.

          bal_cloud_add_items( log   = lo_log
                               t_log = t_log ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`SAVE_LOG`)
            EXPORTING
              log = lo_log.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

      " Standard ABAP / on-premise: classic Business Application Log function modules.









      TRY.
          CREATE DATA lr_log TYPE ('BAL_S_LOG').
          ASSIGN lr_log->* TO <log>.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <log> TO <comp>.
          <comp> = object.
          ASSIGN COMPONENT `SUBOBJECT` OF STRUCTURE <log> TO <comp>.
          <comp> = subobject.
          ASSIGN COMPONENT `EXTNUMBER` OF STRUCTURE <log> TO <comp>.
          <comp> = id.

          CREATE DATA lr_handle TYPE ('BALLOGHNDL').
          ASSIGN lr_handle->* TO <handle>.

          lv_fm = `BAL_LOG_CREATE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_s_log      = <log>
            IMPORTING
              e_log_handle = <handle>
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          bal_std_msg_add( handle = <handle>
                           t_log  = t_log ).

          CREATE DATA lr_handles TYPE ('BAL_T_LOGH').
          ASSIGN lr_handles->* TO <handles>.
          INSERT <handle> INTO TABLE <handles>.

          lv_fm = `BAL_DB_SAVE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_t_log_handle = <handles>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.


        CATCH cx_root INTO lx_create.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_create.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_update.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp7 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp7.
      DATA lv_class TYPE string.
          DATA lo_log LIKE LINE OF lt_logs.
          DATA temp11 LIKE LINE OF lt_logs.
          DATA temp12 LIKE sy-tabix.
      DATA lv_fm TYPE string.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle> TYPE any.
          DATA lx_update TYPE REF TO cx_root.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.

      " Load the existing log and append items. If no log exists, create a new one.






      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.

          IF lt_logs IS INITIAL.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          " Append to the first (most recent) log



          temp12 = sy-tabix.
          READ TABLE lt_logs INDEX 1 INTO temp11.
          sy-tabix = temp12.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lo_log = temp11.
          bal_cloud_add_items( log   = lo_log
                               t_log = t_log ).

          CALL METHOD lo_db->(`SAVE_LOG`)
            EXPORTING
              log = lo_log.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          " Fallback: create new log if update fails
          bal_create( object    = object
                      subobject = subobject
                      id        = id
                      t_log     = t_log ).
      ENDTRY.

    ELSE.

      " Append the given messages to an already persisted log; create a new one if none exists.





      TRY.
          lr_handles = bal_std_load_handles( object    = object
                                             subobject = subobject
                                             id        = id ).
          IF lr_handles IS NOT BOUND.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          ASSIGN lr_handles->* TO <handles>.
          IF <handles> IS INITIAL.
            bal_create( object    = object
                        subobject = subobject
                        id        = id
                        t_log     = t_log ).
            RETURN.
          ENDIF.

          READ TABLE <handles> INDEX 1 ASSIGNING <handle>.
          bal_std_msg_add( handle = <handle>
                           t_log  = t_log ).

          lv_fm = `BAL_DB_SAVE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_t_log_handle = <handles>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.


        CATCH cx_root INTO lx_update.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_update.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_delete.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db TYPE REF TO object.
      TYPES temp8 TYPE STANDARD TABLE OF REF TO object.
DATA lt_logs TYPE temp8.
      DATA lv_class TYPE string.
          DATA lo_log LIKE LINE OF lt_logs.
      DATA lv_fm TYPE string.
      DATA lr_filter TYPE REF TO data.
      FIELD-SYMBOLS <filter> TYPE any.
          DATA lx_delete TYPE REF TO cx_root.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.







      TRY.
          lo_filter = bal_cloud_build_filter( object    = object
                                              subobject = subobject
                                              id        = id ).

          lv_class = `CL_BALI_LOG_DB`.
          CALL METHOD (lv_class)=>(`GET_INSTANCE`)
            RECEIVING
              db_handler = lo_db.

          CALL METHOD lo_db->(`LOAD_LOGS_VIA_FILTER`)
            EXPORTING
              filter    = lo_filter
            RECEIVING
              log_table = lt_logs.


          LOOP AT lt_logs INTO lo_log.
            CALL METHOD lo_db->(`DELETE_LOG`)
              EXPORTING
                log = lo_log.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.





      TRY.
          lr_filter = bal_std_build_filter( object    = object
                                            subobject = subobject
                                            id        = id ).
          ASSIGN lr_filter->* TO <filter>.

          lv_fm = `BAL_DB_DELETE`.
          CALL FUNCTION lv_fm
            EXPORTING
              i_s_log_filter = <filter>
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.


        CATCH cx_root INTO lx_delete.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_delete.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD tr_get_objects.
          DATA lo_transport TYPE REF TO object.
          TYPES temp9 TYPE STANDARD TABLE OF REF TO object.
DATA lt_objects_c TYPE temp9.
          DATA lv_xco TYPE string.
          DATA temp51 TYPE string.
          DATA lv_trkorr_c LIKE temp51.
          DATA lo_objects_api TYPE REF TO object.
          DATA lo_all TYPE REF TO object.
          DATA lo_obj LIKE LINE OF lt_objects_c.
            DATA ls_obj_c TYPE ty_s_tr_object.
    DATA lr_objects TYPE REF TO data.
    DATA lr_header TYPE REF TO data.
    FIELD-SYMBOLS <objects> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <object> TYPE any.
    FIELD-SYMBOLS <header> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
    DATA lv_fm TYPE string.
          DATA temp52 TYPE ty_s_tr_object.
          DATA ls_obj LIKE temp52.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS
      TRY.




          lv_xco = `XCO_CP_CTS`.

          temp51 = trkorr.

          lv_trkorr_c = temp51.

          CALL METHOD (lv_xco)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = lv_trkorr_c
            RECEIVING
              ro_transport = lo_transport.


          CALL METHOD lo_transport->(`OBJECTS`)
            RECEIVING
              ro_objects = lo_objects_api.


          CALL METHOD lo_objects_api->(`ALL`)
            RECEIVING
              ro_all = lo_all.

          CALL METHOD lo_all->(`GET`)
            RECEIVING
              rt_objects = lt_objects_c.


          LOOP AT lt_objects_c INTO lo_obj.

            CLEAR ls_obj_c.
            TRY.
                CALL METHOD lo_obj->(`GET_PGMID`)
                  RECEIVING
                    rv_pgmid = ls_obj_c-pgmid.
                CALL METHOD lo_obj->(`GET_TYPE`)
                  RECEIVING
                    rv_type = ls_obj_c-object.
                CALL METHOD lo_obj->(`GET_NAME`)
                  RECEIVING
                    rv_name = ls_obj_c-obj_name.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            INSERT ls_obj_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use TR_GET_OBJECTS_OF_REQ_AN_TASKS








    TRY.
        CREATE DATA lr_objects TYPE STANDARD TABLE OF (`E071`).
        ASSIGN lr_objects->* TO <objects>.

        CREATE DATA lr_header TYPE (`TRWBO_REQUEST_HEADER`).
        ASSIGN lr_header->* TO <header>.
        ASSIGN COMPONENT `TRKORR` OF STRUCTURE <header> TO <comp>.
        <comp> = trkorr.

        lv_fm = `TR_GET_OBJECTS_OF_REQ_AN_TASKS`.
        CALL FUNCTION lv_fm
          EXPORTING
            is_request_header = <header>
          IMPORTING
            et_objects        = <objects>
          EXCEPTIONS
            OTHERS            = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <objects> ASSIGNING <object>.

          CLEAR temp52.

          ls_obj = temp52.
          ASSIGN COMPONENT `PGMID` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-pgmid = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJECT` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-object = <comp>. ENDIF.
          ASSIGN COMPONENT `OBJ_NAME` OF STRUCTURE <object> TO <comp>.
          IF sy-subrc = 0. ls_obj-obj_name = <comp>. ENDIF.
          INSERT ls_obj INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_get_user_requests.
          DATA lv_xco TYPE string.
          DATA lo_filter_tr TYPE REF TO object.
          DATA lo_status_f TYPE REF TO object.
          DATA lo_owner_f TYPE REF TO object.
          TYPES temp10 TYPE STANDARD TABLE OF REF TO object.
DATA lt_transports TYPE temp10.
          DATA temp53 TYPE string.
          DATA temp13 TYPE string.
          DATA lv_user_c LIKE temp53.
          DATA lo_where TYPE REF TO object.
          DATA lo_tr LIKE LINE OF lt_transports.
            DATA ls_req_c TYPE ty_s_tr_request.
                DATA lo_props TYPE REF TO object.
                DATA ls_prop TYPE REF TO data.
                FIELD-SYMBOLS <prop> TYPE any.
                FIELD-SYMBOLS <pcomp> TYPE any.
                DATA lv_tr_value TYPE string.
    DATA lv_user TYPE c LENGTH 12.
    DATA lv_type TYPE c LENGTH 1.
    DATA lr_data TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
        DATA lv_tab1 TYPE string.
        DATA lv_tab2 TYPE string.
        DATA lv_where TYPE string.
        DATA lt_comp TYPE abap_component_tab.
        DATA lo_struct TYPE REF TO cl_abap_structdescr.
        DATA lo_table TYPE REF TO cl_abap_tabledescr.
          DATA temp54 TYPE ty_s_tr_request.
          DATA ls_req LIKE temp54.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS transport filter
      TRY.

          lv_xco = `XCO_CP_CTS`.








          IF user IS NOT INITIAL.
            temp13 = user.
          ELSE.
            temp13 = sy-uname.
          ENDIF.
          temp53 = temp13.

          lv_user_c = temp53.

          " Get modifiable transports for user
          CALL METHOD (lv_xco)=>(`TRANSPORTS`)
            RECEIVING
              ro_transports = lo_filter_tr.


          CALL METHOD lo_filter_tr->(`ALL`)
            RECEIVING
              ro_all = lo_where.

          CALL METHOD lo_where->(`GET`)
            RECEIVING
              rt_transports = lt_transports.


          LOOP AT lt_transports INTO lo_tr.

            CLEAR ls_req_c.
            TRY.

                CALL METHOD lo_tr->(`PROPERTIES`)
                  RECEIVING
                    ro_properties = lo_props.

                CALL METHOD lo_props->(`GET`)
                  RECEIVING
                    rs_properties = ls_prop.


                ASSIGN ls_prop->* TO <prop>.
                ASSIGN COMPONENT `OWNER` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-owner = <pcomp>. ENDIF.
                IF ls_req_c-owner <> lv_user_c.
                  CONTINUE.
                ENDIF.
                ASSIGN COMPONENT `SHORT_DESCRIPTION` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-description = <pcomp>. ENDIF.
                ASSIGN COMPONENT `STATUS` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-status = <pcomp>. ENDIF.
                ASSIGN COMPONENT `TYPE` OF STRUCTURE <prop> TO <pcomp>.
                IF sy-subrc = 0. ls_req_c-type = <pcomp>. ENDIF.


                CALL METHOD lo_tr->(`GET_VALUE`)
                  RECEIVING
                    rv_value = lv_tr_value.
                ls_req_c-trkorr = lv_tr_value.

              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
            IF ls_req_c-trkorr IS NOT INITIAL.
              INSERT ls_req_c INTO TABLE result.
            ENDIF.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use dynamic SELECT from E070/E07T







    TRY.
        lv_user = user.
        lv_type = request_type.


        lv_tab1 = `E070`.

        lv_tab2 = `E07T`.

        lv_where = |AS4USER = '{ lv_user }' AND TRSTATUS IN ('D','L')|.

        " First read transports from E070

        lt_comp = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( lv_tab1 ).

        lo_struct = cl_abap_structdescr=>create( lt_comp ).

        lo_table = cl_abap_tabledescr=>create( lo_struct ).
        CREATE DATA lr_data TYPE HANDLE lo_table.
        ASSIGN lr_data->* TO <tab>.

        SELECT trkorr as4user trstatus trfunction
          FROM (lv_tab1) INTO CORRESPONDING FIELDS OF TABLE <tab>
          WHERE (lv_where)
          .

        LOOP AT <tab> ASSIGNING <row>.

          CLEAR temp54.

          ls_req = temp54.
          ASSIGN COMPONENT `TRKORR` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-trkorr = <comp>. ENDIF.
          ASSIGN COMPONENT `AS4USER` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-owner = <comp>. ENDIF.
          ASSIGN COMPONENT `TRSTATUS` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-status = <comp>. ENDIF.
          ASSIGN COMPONENT `TRFUNCTION` OF STRUCTURE <row> TO <comp>.
          IF sy-subrc = 0. ls_req-type = <comp>. ENDIF.

          IF lv_type IS NOT INITIAL AND ls_req-type <> lv_type.
            CONTINUE.
          ENDIF.

          " Get description from E07T
          ls_req-description = tr_get_description( ls_req-trkorr ).
          INSERT ls_req INTO TABLE result.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_get_description.
          DATA lo_tr_d TYPE REF TO object.
          DATA lv_xco_d TYPE string.
          DATA temp55 TYPE string.
          DATA lo_props_d TYPE REF TO object.
    DATA lv_trkorr TYPE c LENGTH 20.
        DATA lv_tab TYPE string.
        DATA lv_where TYPE string.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS
      TRY.


          lv_xco_d = `XCO_CP_CTS`.

          temp55 = trkorr.
          CALL METHOD (lv_xco_d)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = temp55
            RECEIVING
              ro_transport = lo_tr_d.

          CALL METHOD lo_tr_d->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_d.
          CALL METHOD lo_props_d->(`GET_SHORT_DESCRIPTION`)
            RECEIVING
              rv_short_description = result.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E07T

    lv_trkorr = trkorr.

    TRY.

        lv_tab = `E07T`.

        lv_where = |TRKORR = '{ lv_trkorr }' AND LANGU = '{ sy-langu }'|.

        SELECT SINGLE as4text
          FROM (lv_tab) INTO result
          WHERE (lv_where)
          .
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_is_released.
          DATA lo_tr_r TYPE REF TO object.
          DATA lv_xco_r TYPE string.
          DATA temp56 TYPE string.
          DATA lo_props_r TYPE REF TO object.
          DATA lv_status_c TYPE string.
          DATA temp1 TYPE xsdboolean.
    DATA lv_trkorr TYPE c LENGTH 20.
    DATA lv_status TYPE c LENGTH 1.
        DATA lv_tab TYPE string.
        DATA lv_where TYPE string.
        DATA temp2 TYPE xsdboolean.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use XCO_CP_CTS
      TRY.


          lv_xco_r = `XCO_CP_CTS`.

          temp56 = trkorr.
          CALL METHOD (lv_xco_r)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = temp56
            RECEIVING
              ro_transport = lo_tr_r.

          CALL METHOD lo_tr_r->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_r.

          CALL METHOD lo_props_r->(`GET_STATUS`)
            RECEIVING
              rv_status = lv_status_c.

          temp1 = boolc( lv_status_c = `RELEASED` OR lv_status_c = `R` ).
          result = temp1.
        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E070


    lv_trkorr = trkorr.

    TRY.

        lv_tab = `E070`.

        lv_where = |TRKORR = '{ lv_trkorr }'|.

        SELECT SINGLE trstatus
          FROM (lv_tab) INTO lv_status
          WHERE (lv_where)
          .

        temp2 = boolc( lv_status = `R` ).
        result = temp2.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_add_object.

    DATA lv_fm       TYPE string.
    DATA lv_trkorr   TYPE c LENGTH 20.
    DATA lv_pgmid    TYPE c LENGTH 4.
    DATA lv_object   TYPE c LENGTH 4.
    DATA lv_obj_name TYPE c LENGTH 120.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
        DATA x TYPE REF TO cx_root.

    lv_trkorr   = trkorr.
    lv_pgmid    = pgmid.
    lv_object   = object.
    lv_obj_name = obj_name.

    TRY.
        lv_fm = `TR_ORDER_CHOICE_CORRECTION`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_category    = lv_pgmid
            iv_object      = lv_object
            iv_obj_name    = lv_obj_name
            iv_order       = lv_trkorr
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TR_ADD_OBJECT failed`.
        ENDIF.


      CATCH z2ui5_cx_util_error INTO lx.
        RAISE EXCEPTION lx.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_create.
        DATA lr_header TYPE REF TO data.
        FIELD-SYMBOLS <header> TYPE any.
        FIELD-SYMBOLS <trkorr> TYPE any.
        DATA lv_class TYPE string.
        DATA x TYPE REF TO cx_root.

    " Create an empty transport request (default type `T` = transport of copies).
    " Uses the released class CL_ADT_CTS_MANAGEMENT, available on standard ABAP
    " (>= 7.51) and ABAP Cloud. Called dynamically so the source stays compilable
    " on all targets - on releases where the class is missing a clean
    " z2ui5_cx_util_error is raised instead of a short dump.
    TRY.






        CREATE DATA lr_header TYPE (`TRWBO_REQUEST_HEADER`).
        ASSIGN lr_header->* TO <header>.

        lv_class = `CL_ADT_CTS_MANAGEMENT`.
        CALL METHOD (lv_class)=>(`CREATE_EMPTY_REQUEST`)
          EXPORTING
            iv_type           = type
            iv_text           = text
            iv_target         = target
          IMPORTING
            es_request_header = <header>.

        ASSIGN COMPONENT `TRKORR` OF STRUCTURE <header> TO <trkorr>.
        result = <trkorr>.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_release.
        DATA lo_api TYPE REF TO object.
        DATA lv_class TYPE string.
        DATA x TYPE REF TO cx_root.

    " Release a transport request via the released CTS REST API
    " (CL_CTS_REST_API_FACTORY). Works on standard ABAP and ABAP Cloud.
    TRY.




        lv_class = `CL_CTS_REST_API_FACTORY`.
        CALL METHOD (lv_class)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = lo_api.

        CALL METHOD lo_api->(`RELEASE`)
          EXPORTING
            iv_trkorr       = trkorr
            iv_ignore_locks = ignore_locks.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_copy_objects.
        DATA lr_headers TYPE REF TO data.
        FIELD-SYMBOLS <headers> TYPE ANY TABLE.
        FIELD-SYMBOLS <header> TYPE any.
        FIELD-SYMBOLS <trkorr> TYPE any.
        FIELD-SYMBOLS <strkorr> TYPE any.
        DATA lv_fm TYPE string.
        DATA lx_known TYPE REF TO z2ui5_cx_util_error.
        DATA x TYPE REF TO cx_root.

    " Copying objects between requests relies on the classic transport
    " functions (TR_COPY_COMM) which are not released on ABAP Cloud.
    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_copy_objects is not supported on ABAP Cloud`.
    ENDIF.

    " Copy all objects/commands of a source request (and its tasks) into a
    " target request via the classic transport functions. Called dynamically
    " so the statement stays compilable on ABAP Cloud as well, even though the
    " function modules only exist on-premise.
    TRY.








        CREATE DATA lr_headers TYPE (`TRWBO_REQUEST_HEADERS`).
        ASSIGN lr_headers->* TO <headers>.

        lv_fm = `TR_READ_REQUEST_WITH_TASKS`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_trkorr          = source
          IMPORTING
            et_request_headers = <headers>
          EXCEPTIONS
            invalid_input      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TR_READ_REQUEST_WITH_TASKS failed`.
        ENDIF.

        LOOP AT <headers> ASSIGNING <header>.

          ASSIGN COMPONENT `TRKORR`  OF STRUCTURE <header> TO <trkorr>.
          ASSIGN COMPONENT `STRKORR` OF STRUCTURE <header> TO <strkorr>.
          IF <trkorr> <> source AND <strkorr> <> source.
            CONTINUE.
          ENDIF.

          lv_fm = `TR_COPY_COMM`.
          CALL FUNCTION lv_fm
            EXPORTING
              wi_dialog                = abap_false
              wi_trkorr_from           = <trkorr>
              wi_trkorr_to             = destination
              wi_without_documentation = abap_false
            EXCEPTIONS
              OTHERS                   = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING
                val = `TR_COPY_COMM failed`.
          ENDIF.

        ENDLOOP.


      CATCH z2ui5_cx_util_error INTO lx_known.
        RAISE EXCEPTION lx_known.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_import.
        DATA lv_system TYPE c LENGTH 8.
        DATA lv_client TYPE c LENGTH 3.
        DATA lv_retcode TYPE c LENGTH 4.
        DATA lr_exc TYPE REF TO data.
        FIELD-SYMBOLS <exc> TYPE any.
        DATA lv_fm TYPE string.
        DATA lx_known TYPE REF TO z2ui5_cx_util_error.
        DATA x TYPE REF TO cx_root.

    " Importing transports via TMS (TMS_MGR_*) is not available on ABAP Cloud.
    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_import is not supported on ABAP Cloud`.
    ENDIF.

    " Import a transport request into a target system via TMS. The target
    " system may be given as `SYSTEM` or `SYSTEM.CLIENT`; an explicit client
    " parameter takes precedence, otherwise the current client is used.
    TRY.








        SPLIT target_system AT `.` INTO lv_system lv_client.
        IF lv_client IS INITIAL.
          IF client IS NOT INITIAL.
            lv_client = client.
          ELSE.
            lv_client = sy-mandt.
          ENDIF.
        ENDIF.

        CREATE DATA lr_exc TYPE (`STMSCALERT`).
        ASSIGN lr_exc->* TO <exc>.

        lv_fm = `TMS_MGR_REFRESH_IMPORT_QUEUES`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_system    = lv_system
            iv_monitor   = abap_true
            iv_verbose   = abap_true
          IMPORTING
            es_exception = <exc>
          EXCEPTIONS
            OTHERS       = 99.
        IF sy-subrc = 99.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TMS_MGR_REFRESH_IMPORT_QUEUES failed`.
        ENDIF.

        lv_fm = `TMS_MGR_IMPORT_TR_REQUEST`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_system                  = lv_system
            iv_request                 = trkorr
            iv_client                  = lv_client
            iv_ignore_cvers            = ignore_version
          IMPORTING
            ev_tp_ret_code             = lv_retcode
          EXCEPTIONS
            read_config_failed         = 1
            table_of_requests_is_empty = 2
            OTHERS                     = 3.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `TMS_MGR_IMPORT_TR_REQUEST failed`.
        ENDIF.

        result = lv_retcode.


      CATCH z2ui5_cx_util_error INTO lx_known.
        RAISE EXCEPTION lx_known.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_check_status.
        DATA lr_settings TYPE REF TO data.
        DATA lr_cofile TYPE REF TO data.
        DATA lr_sysline TYPE REF TO data.
        FIELD-SYMBOLS <settings> TYPE any.
        FIELD-SYMBOLS <systems> TYPE ANY TABLE.
        FIELD-SYMBOLS <sysline> TYPE any.
        FIELD-SYMBOLS <cofile> TYPE any.
        FIELD-SYMBOLS <comp> TYPE any.
        DATA lv_fm TYPE string.
        DATA lx_known TYPE REF TO z2ui5_cx_util_error.
        DATA x TYPE REF TO cx_root.

    " Reading the transport log (TR_READ_GLOBAL_INFO_OF_REQUEST) is not
    " available on ABAP Cloud.
    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_check_status is not supported on ABAP Cloud`.
    ENDIF.

    " Read the import status (imported flag + return code) of a request in a
    " given system via the classic transport log API.
    TRY.











        CREATE DATA lr_settings TYPE (`CTSLG_SETTINGS`).
        ASSIGN lr_settings->* TO <settings>.
        ASSIGN COMPONENT `SYSTEMS` OF STRUCTURE <settings> TO <systems>.

        CREATE DATA lr_sysline LIKE LINE OF <systems>.
        ASSIGN lr_sysline->* TO <sysline>.
        <sysline> = system.
        INSERT <sysline> INTO TABLE <systems>.

        CREATE DATA lr_cofile TYPE (`CTSLG_COFILE`).
        ASSIGN lr_cofile->* TO <cofile>.

        lv_fm = `TR_READ_GLOBAL_INFO_OF_REQUEST`.
        CALL FUNCTION lv_fm
          EXPORTING
            iv_trkorr   = trkorr
            is_settings = <settings>
          IMPORTING
            es_cofile   = <cofile>.

        ASSIGN COMPONENT `EXISTS` OF STRUCTURE <cofile> TO <comp>.
        IF <comp> = abap_false.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `request does not exist in target system`.
        ENDIF.

        ASSIGN COMPONENT `IMPORTED` OF STRUCTURE <cofile> TO <comp>.
        imported = <comp>.
        ASSIGN COMPONENT `RC` OF STRUCTURE <cofile> TO <comp>.
        rc = <comp>.


      CATCH z2ui5_cx_util_error INTO lx_known.
        RAISE EXCEPTION lx_known.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_cloud_add_items.

    DATA lo_item  TYPE REF TO object.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_class TYPE string.

    DATA ls_log LIKE LINE OF t_log.
    LOOP AT t_log INTO ls_log.

      lv_msgty = ls_log-type.

      IF ls_log-id IS NOT INITIAL AND ls_log-no IS NOT INITIAL.
        lv_class = `CL_BALI_MESSAGE_SETTER`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            severity   = lv_msgty
            id         = ls_log-id
            number     = ls_log-no
            variable_1 = ls_log-v1
            variable_2 = ls_log-v2
            variable_3 = ls_log-v3
            variable_4 = ls_log-v4
          RECEIVING
            message    = lo_item.
      ELSE.
        lv_class = `CL_BALI_FREE_TEXT_SETTER`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            severity  = lv_msgty
            text      = ls_log-text
          RECEIVING
            free_text = lo_item.
      ENDIF.

      CALL METHOD log->(`ADD_ITEM`)
        EXPORTING
          item = lo_item.

    ENDLOOP.

  ENDMETHOD.

  METHOD bal_cloud_build_filter.

    DATA lo_filter TYPE REF TO object.
    DATA lv_class  TYPE string.

    lv_class = `CL_BALI_LOG_FILTER`.
    CALL METHOD (lv_class)=>(`CREATE`)
      RECEIVING
        filter = lo_filter.

    CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
      EXPORTING
        object      = object
        subobject   = subobject
        external_id = id.

    result = lo_filter.

  ENDMETHOD.

  METHOD bal_std_msg_add.

    DATA lv_fm    TYPE string.
    DATA lr_msg   TYPE REF TO data.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_text  TYPE c LENGTH 200.
    FIELD-SYMBOLS <msg>  TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.

    DATA ls_log LIKE LINE OF t_log.
    LOOP AT t_log INTO ls_log.

      IF ls_log-id IS NOT INITIAL AND ls_log-no IS NOT INITIAL.

        CREATE DATA lr_msg TYPE ('BAL_S_MSG').
        ASSIGN lr_msg->* TO <msg>.
        ASSIGN COMPONENT `MSGTY` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-type.
        ASSIGN COMPONENT `MSGID` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-id.
        ASSIGN COMPONENT `MSGNO` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-no.
        ASSIGN COMPONENT `MSGV1` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v1.
        ASSIGN COMPONENT `MSGV2` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v2.
        ASSIGN COMPONENT `MSGV3` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v3.
        ASSIGN COMPONENT `MSGV4` OF STRUCTURE <msg> TO <comp>.
        <comp> = ls_log-v4.

        lv_fm = `BAL_LOG_MSG_ADD`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_log_handle = handle
            i_s_msg      = <msg>
          EXCEPTIONS
            OTHERS       = 1.

      ELSE.

        lv_msgty = ls_log-type.
        lv_text  = ls_log-text.
        lv_fm    = `BAL_LOG_MSG_ADD_FREE_TEXT`.
        CALL FUNCTION lv_fm
          EXPORTING
            i_log_handle = handle
            i_msgty      = lv_msgty
            i_text       = lv_text
          EXCEPTIONS
            OTHERS       = 1.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD bal_std_load_handles.

    DATA lv_fm      TYPE string.
    DATA lr_filter  TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter>  TYPE any.
    FIELD-SYMBOLS <headers> TYPE SORTED TABLE.
    FIELD-SYMBOLS <handles> TYPE SORTED TABLE.

    lr_filter = bal_std_build_filter( object    = object
                                      subobject = subobject
                                      id        = id ).
    ASSIGN lr_filter->* TO <filter>.

    CREATE DATA lr_headers TYPE ('BALHDR_T').
    ASSIGN lr_headers->* TO <headers>.

    lv_fm = `BAL_DB_SEARCH`.
    CALL FUNCTION lv_fm
      EXPORTING
        i_s_log_filter = <filter>
      IMPORTING
        e_t_log_header = <headers>
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0 OR <headers> IS INITIAL.
      RETURN.
    ENDIF.

    CREATE DATA result TYPE ('BAL_T_LOGH').
    ASSIGN result->* TO <handles>.

    lv_fm = `BAL_DB_LOAD`.
    CALL FUNCTION lv_fm
      EXPORTING
        i_t_log_header = <headers>
      IMPORTING
        e_t_log_handle = <handles>
      EXCEPTIONS
        OTHERS         = 1.

  ENDMETHOD.

  METHOD bal_std_build_filter.

    FIELD-SYMBOLS <filter> TYPE any.

    CREATE DATA result TYPE ('BAL_S_LFIL').
    ASSIGN result->* TO <filter>.

    bal_std_filter_add( EXPORTING comp   = `OBJECT`
                                  value  = object
                        CHANGING  filter = <filter> ).
    bal_std_filter_add( EXPORTING comp   = `SUBOBJECT`
                                  value  = subobject
                        CHANGING  filter = <filter> ).
    bal_std_filter_add( EXPORTING comp   = `EXTNUMBER`
                                  value  = id
                        CHANGING  filter = <filter> ).

  ENDMETHOD.

  METHOD bal_std_filter_add.

    DATA lr_line TYPE REF TO data.
    FIELD-SYMBOLS <range> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.
    FIELD-SYMBOLS <comp>  TYPE any.

    IF value IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT comp OF STRUCTURE filter TO <range>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CREATE DATA lr_line LIKE LINE OF <range>.
    ASSIGN lr_line->* TO <line>.
    ASSIGN COMPONENT `SIGN` OF STRUCTURE <line> TO <comp>.
    <comp> = `I`.
    ASSIGN COMPONENT `OPTION` OF STRUCTURE <line> TO <comp>.
    <comp> = `EQ`.
    ASSIGN COMPONENT `LOW` OF STRUCTURE <line> TO <comp>.
    <comp> = value.
    INSERT <line> INTO TABLE <range>.

  ENDMETHOD.

  METHOD bal_std_map_msg.

    DATA lv_fm   TYPE string.
    DATA lv_text TYPE c LENGTH 200.
    FIELD-SYMBOLS <comp> TYPE any.

    ASSIGN COMPONENT `MSGTY` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-type = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGID` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-id = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGNO` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-no = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV1` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v1 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV2` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v2 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV3` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v3 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `MSGV4` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-v4 = <comp>.
    ENDIF.
    ASSIGN COMPONENT `TIME_STMP` OF STRUCTURE msg TO <comp>.
    IF sy-subrc = 0.
      result-timestampl = <comp>.
    ENDIF.

    TRY.
        lv_fm = `MESSAGE_TEXT_BUILD`.
        CALL FUNCTION lv_fm
          EXPORTING
            msgid               = result-id
            msgnr               = result-no
            msgv1               = result-v1
            msgv2               = result-v2
            msgv3               = result-v3
            msgv4               = result-v4
          IMPORTING
            message_text_output = lv_text.
        result-text = lv_text.
      CATCH cx_root.
        result-text = result-v1.
    ENDTRY.

  ENDMETHOD.


  METHOD lock_set.

    result = lock_call_function( val     = val
                                 t_param = t_param ).

  ENDMETHOD.

  METHOD lock_set_wait.

    DATA lv_remaining LIKE retries.
    lv_remaining = retries.

    WHILE lv_remaining > 0.
      result = lock_set( val     = val
                          t_param = t_param ).
      IF result = abap_true.
        RETURN.
      ENDIF.
      lv_remaining = lv_remaining - 1.
      IF lv_remaining > 0.
        WAIT UP TO delay_ms / 1000 SECONDS.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD lock_is_locked.

    " Try to set the lock — if it fails, the object is locked.
    DATA lv_locked TYPE abap_bool.
    lv_locked = lock_set( val     = val
                                 t_param = t_param ).
    IF lv_locked = abap_true.
      " We got it — release immediately
      lock_delete( val     = val
                   t_param = t_param ).
      result = abap_false.
    ELSE.
      result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD lock_get_owner.
        DATA lt_locks TYPE z2ui5_cl_util_ext=>ty_t_lock.
        DATA lv_arg TYPE string.
        DATA ls_param LIKE LINE OF t_param.
        DATA lv_name TYPE string.
        DATA ls_lock LIKE LINE OF lt_locks.

    TRY.

        lt_locks = lock_read( ).

        " Build the lock argument from params for matching

        lv_arg = ``.

        LOOP AT t_param INTO ls_param.
          lv_arg = lv_arg && ls_param-value.
        ENDLOOP.


        lv_name = z2ui5_cl_util=>c_trim_upper( val ).
        REPLACE `ENQUEUE_` IN lv_name WITH ``.


        LOOP AT lt_locks INTO ls_lock
             WHERE lock_object CS lv_name.
          IF lv_arg IS INITIAL OR ls_lock-argument CS lv_arg.
            result = ls_lock-user.
            RETURN.
          ENDIF.
        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD lock_get_dequeue_by_enqueue.

    result = replace( val  = z2ui5_cl_util=>c_trim_upper( val )
                      sub  = `ENQUEUE_`
                      with = `DEQUEUE_` ).

  ENDMETHOD.

  METHOD lock_read.

    DATA lr_enq TYPE REF TO data.
    FIELD-SYMBOLS <lt_enq>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_enq>   TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    DATA lv_client     TYPE c LENGTH 3.
    DATA lv_name       TYPE c LENGTH 30.
    DATA lv_uname      TYPE c LENGTH 12.
    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
    DATA ls_lock       TYPE ty_s_lock.
        DATA lx_error TYPE REF TO z2ui5_cx_util_error.
        DATA lx_root TYPE REF TO cx_root.

    TRY.
        CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`).
        ASSIGN lr_enq->* TO <lt_enq>.

        IF client IS INITIAL.
          lv_client = z2ui5_cl_util=>context_get_sy( )-mandt.
        ELSE.
          lv_client = client.
        ENDIF.
        lv_name  = lock_object.
        lv_uname = user.

        ls_param-name = `GCLIENT`.
        ls_param-kind = abap_func_exporting.
        GET REFERENCE OF lv_client INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `GNAME`.
        GET REFERENCE OF lv_name INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `GUNAME`.
        GET REFERENCE OF lv_uname INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `ENQ`.
        ls_param-kind = abap_func_tables.
        GET REFERENCE OF <lt_enq> INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = `ENQUEUE_READ`.
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = `LOCK_READ_FAILED`.
        ENDIF.

        LOOP AT <lt_enq> ASSIGNING <ls_enq>.
          CLEAR ls_lock.
          ASSIGN COMPONENT `GNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-lock_object = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GARG` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-argument = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-user = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GMODE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-mode = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GCLIENT` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-client = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GTDATE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-date = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GTTIME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-time = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUSR` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-owner = <lv_value>.
          ENDIF.
          ASSIGN COMPONENT `GUSRVB` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            ls_lock-owner_vb = <lv_value>.
          ENDIF.
          INSERT ls_lock INTO TABLE result.
        ENDLOOP.


      CATCH z2ui5_cx_util_error INTO lx_error.
        RAISE EXCEPTION lx_error.

      CATCH cx_root INTO lx_root.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = lx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD lock_delete.

    result = lock_call_function( val     = lock_get_dequeue_by_enqueue( val )
                                 t_param = t_param ).

  ENDMETHOD.

  METHOD lock_delete_entries.

    DATA lr_enq TYPE REF TO data.
    FIELD-SYMBOLS <lt_enq>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_enq>   TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    DATA lr_row        TYPE REF TO data.
    DATA ls_lock       TYPE ty_s_lock.
    DATA lv_check_upd  TYPE i.
    DATA lv_subrc      TYPE sy-subrc.
    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
        DATA temp3 TYPE xsdboolean.

    TRY.
        CREATE DATA lr_enq TYPE STANDARD TABLE OF (`SEQG3`).
        ASSIGN lr_enq->* TO <lt_enq>.
        CREATE DATA lr_row TYPE (`SEQG3`).
        ASSIGN lr_row->* TO <ls_enq>.

        LOOP AT t_lock INTO ls_lock.
          CLEAR <ls_enq>.
          ASSIGN COMPONENT `GNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-lock_object.
          ENDIF.
          ASSIGN COMPONENT `GARG` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-argument.
          ENDIF.
          ASSIGN COMPONENT `GUNAME` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-user.
          ENDIF.
          ASSIGN COMPONENT `GMODE` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-mode.
          ENDIF.
          ASSIGN COMPONENT `GCLIENT` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-client.
          ENDIF.
          ASSIGN COMPONENT `GUSR` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-owner.
          ENDIF.
          ASSIGN COMPONENT `GUSRVB` OF STRUCTURE <ls_enq> TO <lv_value>.
          IF sy-subrc = 0.
            <lv_value> = ls_lock-owner_vb.
          ENDIF.
          INSERT <ls_enq> INTO TABLE <lt_enq>.
        ENDLOOP.

        IF <lt_enq> IS INITIAL.
          result = abap_true.
          RETURN.
        ENDIF.

        ls_param-name = `CHECK_UPD_REQUESTS`.
        ls_param-kind = abap_func_exporting.
        GET REFERENCE OF lv_check_upd INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `SUBRC`.
        ls_param-kind = abap_func_importing.
        GET REFERENCE OF lv_subrc INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_param-name = `ENQ`.
        ls_param-kind = abap_func_tables.
        GET REFERENCE OF <lt_enq> INTO ls_param-value.
        INSERT ls_param INTO TABLE lt_param.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = `ENQUE_DELETE`.
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.


        temp3 = boolc( sy-subrc = 0 AND lv_subrc = 0 ).
        result = temp3.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD auth_check.

    DATA lv_object   TYPE c LENGTH 10.
    DATA lv_field    TYPE c LENGTH 10.
    DATA lv_value    TYPE c LENGTH 40.
    DATA lv_activity TYPE c LENGTH 2.
    DATA temp4 TYPE xsdboolean.

    lv_object   = object.
    lv_field    = field.
    lv_value    = value.
    lv_activity = activity.

    AUTHORITY-CHECK OBJECT lv_object
      ID lv_field FIELD lv_value
      ID 'ACTVT' FIELD lv_activity.


    temp4 = boolc( sy-subrc = 0 ).
    result = temp4.

  ENDMETHOD.

  METHOD text_get.

    DATA lv_msgid TYPE c LENGTH 20.
    DATA lv_msgno TYPE n LENGTH 3.
    DATA lv_msgv1 TYPE c LENGTH 50.
    DATA lv_msgv2 TYPE c LENGTH 50.
    DATA lv_msgv3 TYPE c LENGTH 50.
    DATA lv_msgv4 TYPE c LENGTH 50.
    DATA lv_text  TYPE c LENGTH 200.
        DATA lv_fm TYPE string.

    lv_msgid = msgid.
    lv_msgno = msgno.
    lv_msgv1 = v1.
    lv_msgv2 = v2.
    lv_msgv3 = v3.
    lv_msgv4 = v4.

    TRY.

        lv_fm = `MESSAGE_TEXT_BUILD`.
        CALL FUNCTION lv_fm
          EXPORTING
            msgid               = lv_msgid
            msgnr               = lv_msgno
            msgv1               = lv_msgv1
            msgv2               = lv_msgv2
            msgv3               = lv_msgv3
            msgv4               = lv_msgv4
          IMPORTING
            message_text_output = lv_text.
        result = lv_text.
      CATCH cx_root.
        result = |{ lv_msgid } { lv_msgno }: { lv_msgv1 } { lv_msgv2 } { lv_msgv3 } { lv_msgv4 }|.
    ENDTRY.

  ENDMETHOD.

  METHOD mail_send.
      DATA lo_mail_c TYPE REF TO object.
      DATA lv_cls_c TYPE string.
    DATA lo_mail TYPE REF TO object.
    DATA lo_sender TYPE REF TO object.
    DATA lo_recipient TYPE REF TO object.
    DATA lo_doc TYPE REF TO object.
    DATA lr_body TYPE REF TO data.
    DATA lr_line TYPE REF TO data.
    DATA lv_class TYPE string.
    DATA lv_subject TYPE c LENGTH 50.
    DATA lv_type TYPE c LENGTH 3.
    DATA lv_address TYPE c LENGTH 241.
    FIELD-SYMBOLS <body> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    DATA temp57 LIKE lv_type.
        DATA lt_lines TYPE string_table.
        DATA lv_body_line LIKE LINE OF lt_lines.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use CL_BCS_MAIL_MESSAGE (released cloud mail API)



      TRY.
          lv_cls_c = `CL_BCS_MAIL_MESSAGE`.
          CALL METHOD (lv_cls_c)=>(`CREATE_INSTANCE`)
            RECEIVING
              result = lo_mail_c.

          CALL METHOD lo_mail_c->(`SET_SENDER`)
            EXPORTING
              iv_address = z2ui5_cl_util=>context_get_user_tech( ) && `@placeholder.local`.

          CALL METHOD lo_mail_c->(`ADD_RECIPIENT`)
            EXPORTING
              iv_address = to.

          CALL METHOD lo_mail_c->(`SET_SUBJECT`)
            EXPORTING
              iv_subject = subject.

          IF html = abap_true.
            CALL METHOD lo_mail_c->(`SET_MAIN`)
              EXPORTING
                iv_content_type = `text/html`
                iv_content_text = body.
          ELSE.
            CALL METHOD lo_mail_c->(`SET_MAIN`)
              EXPORTING
                iv_content_type = `text/plain`
                iv_content_text = body.
          ENDIF.

          CALL METHOD lo_mail_c->(`SEND`)
            RECEIVING
              result = result.

        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use CL_BCS














    lv_subject = subject.
    lv_address = to.

    IF html = abap_true.
      temp57 = `HTM`.
    ELSE.
      temp57 = `RAW`.
    ENDIF.
    lv_type    = temp57.

    TRY.
        " Create BCS instance
        lv_class = `CL_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_PERSISTENT`)
          RECEIVING
            result = lo_mail.

        " Sender
        lv_class = `CL_SAPUSER_BCS`.
        CALL METHOD (lv_class)=>(`CREATE`)
          EXPORTING
            i_user = sy-uname
          RECEIVING
            result = lo_sender.
        CALL METHOD lo_mail->(`SET_SENDER`)
          EXPORTING
            i_sender = lo_sender.

        " Recipient
        lv_class = `CL_CAM_ADDRESS_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_INTERNET_ADDRESS`)
          EXPORTING
            i_address_string = lv_address
          RECEIVING
            result           = lo_recipient.
        CALL METHOD lo_mail->(`ADD_RECIPIENT`)
          EXPORTING
            i_recipient = lo_recipient.

        " Build body text table
        CREATE DATA lr_body TYPE (`BCSY_TEXT`).
        ASSIGN lr_body->* TO <body>.
        CREATE DATA lr_line TYPE (`SOLI`).
        ASSIGN lr_line->* TO <line>.


        lt_lines = z2ui5_cl_util=>c_split( val = body sep = z2ui5_cl_util=>cv_char_util_newline ).

        LOOP AT lt_lines INTO lv_body_line.
          ASSIGN COMPONENT `LINE` OF STRUCTURE <line> TO <field>.
          <field> = lv_body_line.
          INSERT <line> INTO TABLE <body>.
        ENDLOOP.

        " Create document
        lv_class = `CL_DOCUMENT_BCS`.
        CALL METHOD (lv_class)=>(`CREATE_DOCUMENT`)
          EXPORTING
            i_type    = lv_type
            i_text    = <body>
            i_subject = lv_subject
          RECEIVING
            result    = lo_doc.

        CALL METHOD lo_mail->(`SET_DOCUMENT`)
          EXPORTING
            i_document = lo_doc.
        CALL METHOD lo_mail->(`SET_SEND_IMMEDIATELY`)
          EXPORTING
            i_send_immediately = abap_true.

        CALL METHOD lo_mail->(`SEND`)
          RECEIVING
            result = result.
        COMMIT WORK AND WAIT.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD job_submit_report.
    DATA lv_fm TYPE string.
    DATA lv_jobname TYPE c LENGTH 32.
    DATA lv_jobcount TYPE c LENGTH 8.
    DATA lv_report TYPE c LENGTH 40.
    DATA lv_variant TYPE c LENGTH 14.
    DATA temp58 LIKE lv_jobname.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
        DATA x TYPE REF TO cx_root.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: Application Jobs have a different architecture (job catalog + templates).
      " Direct report submission is not available. Raise informative exception.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `job_submit_report: On ABAP Cloud use CL_APJ_RT_API with a registered job catalog entry instead`.
    ENDIF.

    " Standard ABAP: JOB_OPEN / JOB_SUBMIT / JOB_CLOSE






    lv_report = report.
    lv_variant = variant.

    IF job_name IS NOT INITIAL.
      temp58 = job_name.
    ELSE.
      temp58 = |Z2UI5_{ sy-datum }{ sy-uzeit }|.
    ENDIF.
    lv_jobname = temp58.

    TRY.
        lv_fm = `JOB_OPEN`.
        CALL FUNCTION lv_fm
          EXPORTING
            jobname  = lv_jobname
          IMPORTING
            jobcount = lv_jobcount
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `JOB_OPEN failed`.
        ENDIF.

        lv_fm = `JOB_SUBMIT`.
        CALL FUNCTION lv_fm
          EXPORTING
            authcknam = sy-uname
            jobcount  = lv_jobcount
            jobname   = lv_jobname
            report    = lv_report
            variant   = lv_variant
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `JOB_SUBMIT failed`.
        ENDIF.

        lv_fm = `JOB_CLOSE`.
        IF start_immediate = abap_true.
          CALL FUNCTION lv_fm
            EXPORTING
              jobcount  = lv_jobcount
              jobname   = lv_jobname
              strtimmed = abap_true
            EXCEPTIONS
              OTHERS    = 1.
        ELSE.
          CALL FUNCTION lv_fm
            EXPORTING
              jobcount  = lv_jobcount
              jobname   = lv_jobname
            EXCEPTIONS
              OTHERS    = 1.
        ENDIF.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `JOB_CLOSE failed`.
        ENDIF.

        result = lv_jobname.


      CATCH z2ui5_cx_util_error INTO lx.
        RAISE EXCEPTION lx.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD numrange_get_next.

    DATA lv_object  TYPE c LENGTH 10.
    DATA lv_nr_sub  TYPE c LENGTH 2.
    DATA lv_number  TYPE c LENGTH 20.
          DATA lv_cls TYPE string.
          DATA lv_fm TYPE string.
        DATA lx TYPE REF TO z2ui5_cx_util_error.
        DATA x TYPE REF TO cx_root.

    lv_object = object.
    lv_nr_sub = subobject.

    TRY.
        IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
          " Cloud: use CL_NUMBERRANGE_RUNTIME

          lv_cls = `CL_NUMBERRANGE_RUNTIME`.
          CALL METHOD (lv_cls)=>(`NUMBER_GET`)
            EXPORTING
              nr_range_nr = lv_nr_sub
              object      = lv_object
            IMPORTING
              number      = lv_number.
        ELSE.
          " Standard: use NUMBER_GET_NEXT FM

          lv_fm = `NUMBER_GET_NEXT`.
          CALL FUNCTION lv_fm
            EXPORTING
              nr_range_nr = lv_nr_sub
              object      = lv_object
            IMPORTING
              number      = lv_number
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING
                val = |NUMBER_GET_NEXT failed for { lv_object }/{ lv_nr_sub }|.
          ENDIF.
        ENDIF.

        result = lv_number.


      CATCH z2ui5_cx_util_error INTO lx.
        RAISE EXCEPTION lx.

      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD changdoc_read.
          DATA lv_cds TYPE string.
          DATA lv_where_c TYPE string.
          FIELD-SYMBOLS <cds_tab> TYPE STANDARD TABLE.
          FIELD-SYMBOLS <cds_row> TYPE any.
          FIELD-SYMBOLS <cds_fld> TYPE any.
          DATA lr_cds_tab TYPE REF TO data.
          DATA lt_comp_c TYPE abap_component_tab.
          DATA lo_struct_c TYPE REF TO cl_abap_structdescr.
          DATA lo_table_c TYPE REF TO cl_abap_tabledescr.
            DATA temp59 TYPE ty_s_changdoc.
            DATA ls_doc_c LIKE temp59.
    DATA lv_fm TYPE string.
    DATA lv_objectclas TYPE c LENGTH 15.
    DATA lv_objectid TYPE c LENGTH 90.
    DATA lr_headers TYPE REF TO data.
    DATA lr_positions TYPE REF TO data.
    FIELD-SYMBOLS <headers> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <positions> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <hdr> TYPE any.
    FIELD-SYMBOLS <pos> TYPE any.
    FIELD-SYMBOLS <comp> TYPE any.
          DATA temp60 TYPE ty_s_changdoc.
          DATA ls_doc LIKE temp60.
              DATA ls_pos LIKE ls_doc.

    IF z2ui5_cl_util=>context_check_abap_cloud( ) IS NOT INITIAL.
      " Cloud: use released CDS view I_ChangeDocument
      TRY.

          lv_cds = `I_CHANGEDOCUMENTITEM`.

          lv_where_c = |OBJECTCLASS = '{ objectclass }' AND OBJECTID = '{ objectid }'|.
          IF date_from IS NOT INITIAL.
            lv_where_c = |{ lv_where_c } AND CREATIONDATE >= '{ date_from }'|.
          ENDIF.
          IF date_to IS NOT INITIAL AND date_to <> '99991231'.
            lv_where_c = |{ lv_where_c } AND CREATIONDATE <= '{ date_to }'|.
          ENDIF.







          lt_comp_c = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( lv_cds ).

          lo_struct_c = cl_abap_structdescr=>create( lt_comp_c ).

          lo_table_c = cl_abap_tabledescr=>create( lo_struct_c ).
          CREATE DATA lr_cds_tab TYPE HANDLE lo_table_c.
          ASSIGN lr_cds_tab->* TO <cds_tab>.

          SELECT *
            FROM (lv_cds) INTO CORRESPONDING FIELDS OF TABLE <cds_tab>
            WHERE (lv_where_c)
            .

          LOOP AT <cds_tab> ASSIGNING <cds_row>.

            CLEAR temp59.

            ls_doc_c = temp59.
            ASSIGN COMPONENT `CHANGEDOCOBJECTCLASS` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc <> 0.
              ASSIGN COMPONENT `OBJECTCLASS` OF STRUCTURE <cds_row> TO <cds_fld>.
            ENDIF.
            ASSIGN COMPONENT `CHANGEDOCUMENT` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-changenr = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATEDBYUSER` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-username = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATIONDATE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-udate = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CREATIONTIME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-utime = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `TRANSACTIONCODE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-tcode = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMFIELDNAME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-fieldname = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMNEWVALUE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-new_value = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMOLDVALUE` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-old_value = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHANGEDOCITEMTABLENAME` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-tabname = <cds_fld>. ENDIF.
            ASSIGN COMPONENT `CHNGEDOCITEMCHNGIND` OF STRUCTURE <cds_row> TO <cds_fld>.
            IF sy-subrc = 0. ls_doc_c-chngind = <cds_fld>. ENDIF.
            INSERT ls_doc_c INTO TABLE result.
          ENDLOOP.

        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard ABAP: use CHANGEDOCUMENT_READ_HEADERS/POSITIONS FMs











    lv_objectclas = objectclass.
    lv_objectid   = objectid.

    TRY.
        CREATE DATA lr_headers TYPE STANDARD TABLE OF (`CDHDR`).
        CREATE DATA lr_positions TYPE STANDARD TABLE OF (`CDPOS`).
        ASSIGN lr_headers->* TO <headers>.
        ASSIGN lr_positions->* TO <positions>.

        lv_fm = `CHANGEDOCUMENT_READ_HEADERS`.
        CALL FUNCTION lv_fm
          EXPORTING
            objectclass = lv_objectclas
            objectid    = lv_objectid
            date_of_change = date_from
          TABLES
            i_cdhdr     = <headers>
          EXCEPTIONS
            OTHERS      = 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT <headers> ASSIGNING <hdr>.


          CLEAR temp60.

          ls_doc = temp60.
          ASSIGN COMPONENT `CHANGENR` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-changenr = <comp>. ENDIF.
          ASSIGN COMPONENT `USERNAME` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-username = <comp>. ENDIF.
          ASSIGN COMPONENT `UDATE` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-udate = <comp>. ENDIF.
          ASSIGN COMPONENT `UTIME` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-utime = <comp>. ENDIF.
          ASSIGN COMPONENT `TCODE` OF STRUCTURE <hdr> TO <comp>.
          IF sy-subrc = 0. ls_doc-tcode = <comp>. ENDIF.

          " Read positions for this change number
          CLEAR <positions>.
          lv_fm = `CHANGEDOCUMENT_READ_POSITIONS`.
          CALL FUNCTION lv_fm
            EXPORTING
              changenumber = ls_doc-changenr
            TABLES
              editpos      = <positions>
            EXCEPTIONS
              OTHERS       = 1.

          IF <positions> IS INITIAL.
            INSERT ls_doc INTO TABLE result.
          ELSE.
            LOOP AT <positions> ASSIGNING <pos>.

              ls_pos = ls_doc.
              ASSIGN COMPONENT `FNAME` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-fieldname = <comp>. ENDIF.
              ASSIGN COMPONENT `VALUE_OLD` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-old_value = <comp>. ENDIF.
              ASSIGN COMPONENT `VALUE_NEW` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-new_value = <comp>. ENDIF.
              ASSIGN COMPONENT `TABNAME` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-tabname = <comp>. ENDIF.
              ASSIGN COMPONENT `CHNGIND` OF STRUCTURE <pos> TO <comp>.
              IF sy-subrc = 0. ls_pos-chngind = <comp>. ENDIF.
              INSERT ls_pos INTO TABLE result.
            ENDLOOP.
          ENDIF.

        ENDLOOP.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD source_get_method.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_source       TYPE string_table.
    DATA lt_string       TYPE string_table.
    DATA lv_class        TYPE string.
    DATA lv_method       TYPE string.
    DATA xco_cp_abap     TYPE c LENGTH 11.
    DATA lv_name         TYPE c LENGTH 13.
    DATA lv_check_method LIKE abap_false.
    DATA lv_source       LIKE LINE OF lt_source.
    DATA lv_source_upper TYPE string.

    TRY.

        lv_class  = to_upper( iv_classname ).
        lv_method = to_upper( iv_methodname ).

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_class
          RECEIVING
            ro_class = object.

        ASSIGN object->(`IF_XCO_AO_CLASS~IMPLEMENTATION`) TO <any>.
        ASSERT sy-subrc = 0.
        object = <any>.

        CALL METHOD object->(`IF_XCO_CLAS_IMPLEMENTATION~METHOD`)
          EXPORTING
            iv_name   = lv_method
          RECEIVING
            ro_method = object.

        CALL METHOD object->(`IF_XCO_CLAS_I_METHOD~CONTENT`)
          RECEIVING
            ro_content = object.

        CALL METHOD object->(`IF_XCO_CLAS_I_METHOD_CONTENT~GET_SOURCE`)
          RECEIVING
            rt_source = result.

      CATCH cx_root.

        lv_name = `CL_OO_FACTORY`.
        CALL METHOD (lv_name)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = object.

        CALL METHOD object->(`IF_OO_CLIF_SOURCE_FACTORY~CREATE_CLIF_SOURCE`)
          EXPORTING
            clif_name = lv_class
          RECEIVING
            result    = object.

        CALL METHOD object->(`IF_OO_CLIF_SOURCE~GET_SOURCE`)
          IMPORTING
            source = lt_source.

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

        result = lt_string.

    ENDTRY.

  ENDMETHOD.

  METHOD source_get_method2.

    DATA lt_source TYPE string_table.
    lt_source = source_get_method( iv_classname  = iv_classname
                                         iv_methodname = iv_methodname ).

    result = source_method_to_file( lt_source ).

  ENDMETHOD.

  METHOD source_get_file_types.

    DATA lv_types TYPE string.
    lv_types = |abap, abc, actionscript, ada, apache_conf, applescript, asciidoc, assembly_x86, autohotkey, batchfile, bro, c9search, c_cpp, cirru, clojure, cobol, coffee, coldfusion, csharp, css, curly, d, dart, diff, django, dockerfile, | &&
|dot, drools, eiffel, yaml, ejs, elixir, elm, erlang, forth, fortran, ftl, gcode, gherkin, gitignore, glsl, gobstones, golang, groovy, haml, handlebars, haskell, haskell_cabal, haxe, hjson, html, html_elixir, html_ruby, ini, io, jack, jade, java, ja| &&
      |vascri| &&
|pt, json, jsoniq, jsp, jsx, julia, kotlin, latex, lean, less, liquid, lisp, live_script, livescript, logiql, lsl, lua, luapage, lucene, makefile, markdown, mask, matlab, mavens_mate_log, maze, mel, mips_assembler, mipsassembler, mushcode, mysql, ni| &&
|x, nsis, objectivec, ocaml, pascal, perl, pgsql, php, plain_text, powershell, praat, prolog, properties, protobuf, python, r, razor, rdoc, rhtml, rst, ruby, rust, sass, scad, scala, scheme, scss, sh, sjs, smarty, snippets, soy_template, space, sql,| &&
      | sqlserver, stylus, svg, swift, swig, tcl, tex, text, textile, toml, tsx, twig, typescript, vala, vbscript, velocity, verilog, vhdl, wollok, xml, xquery, terraform, slim, redshift, red, puppet, php_laravel_blade, mixal, jssm, fsharp, edifact,| &&
      | csp, cssound_score, cssound_orchestra, cssound_document| ##NO_TEXT.
    SPLIT lv_types AT `,` INTO TABLE result.

  ENDMETHOD.

  METHOD source_method_to_file.

    DATA lv_source LIKE LINE OF it_source.
    LOOP AT it_source INTO lv_source.
      IF strlen( lv_source ) > 1.
        result = result && lv_source+1 && z2ui5_cl_util=>cv_char_util_newline.
      ELSE.
        result = result && z2ui5_cl_util=>cv_char_util_newline.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD lock_call_function.

    DATA lt_param      TYPE abap_func_parmbind_tab.
    DATA ls_param      TYPE abap_func_parmbind.
    DATA ls_lock_param TYPE ty_s_lock_param.
    DATA lr_value      TYPE REF TO string.
    DATA lt_exception  TYPE abap_func_excpbind_tab.
    DATA ls_exception  TYPE abap_func_excpbind.
    DATA lv_function   TYPE string.
        DATA temp5 TYPE xsdboolean.

    TRY.
        LOOP AT t_param INTO ls_lock_param.
          ls_param-name = ls_lock_param-name.
          ls_param-kind = abap_func_exporting.
          CREATE DATA lr_value.
          lr_value->* = ls_lock_param-value.
          ls_param-value = lr_value.
          INSERT ls_param INTO TABLE lt_param.
        ENDLOOP.

        ls_exception-name  = `OTHERS`.
        ls_exception-value = 4.
        INSERT ls_exception INTO TABLE lt_exception.

        lv_function = z2ui5_cl_util=>c_trim_upper( val ).
        CALL FUNCTION lv_function
          PARAMETER-TABLE lt_param
          EXCEPTION-TABLE lt_exception.


        temp5 = boolc( sy-subrc = 0 ).
        result = temp5.

      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD cal_get_weekday.

    " 1900-01-01 was a Monday, so the day distance modulo 7 yields the weekday
    DATA temp61 TYPE d.
    DATA lv_days TYPE d.
    temp61 = `19000101`.

    lv_days = date - temp61.
    result = lv_days MOD 7 + 1.

  ENDMETHOD.

  METHOD cal_is_weekend.

    DATA temp6 TYPE xsdboolean.
    temp6 = boolc( cal_get_weekday( date ) >= 6 ).
    result = temp6.

  ENDMETHOD.

  METHOD cal_is_workday.
    DATA temp7 TYPE xsdboolean.

    IF calendar_id IS NOT INITIAL.
      z2ui5_cl_util=>x_raise( `cal_is_workday: factory calendar support is not yet implemented` ).
    ENDIF.


    temp7 = boolc( cal_is_weekend( date ) = abap_false ).
    result = temp7.

  ENDMETHOD.

  METHOD cal_add_workdays.

    DATA lv_remaining TYPE i.
    DATA temp62 TYPE i.
    DATA lv_step LIKE temp62.
    lv_remaining = abs( days ).

    IF days < 0.
      temp62 = -1.
    ELSE.
      temp62 = 1.
    ENDIF.

    lv_step = temp62.

    result = date.
    WHILE lv_remaining > 0.
      result = result + lv_step.
      IF cal_is_workday( date = result calendar_id = calendar_id ) = abap_true.
        lv_remaining = lv_remaining - 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD cal_count_workdays.

    DATA lv_date LIKE date_from.
    DATA temp63 TYPE i.
    DATA lv_step LIKE temp63.
    lv_date = date_from.

    IF date_to < date_from.
      temp63 = -1.
    ELSE.
      temp63 = 1.
    ENDIF.

    lv_step = temp63.

    WHILE lv_date <> date_to.
      lv_date = lv_date + lv_step.
      IF cal_is_workday( date = lv_date calendar_id = calendar_id ) = abap_true.
        result = result + 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.

  METHOD conv_get_xlsx_by_itab.

*    DATA(write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
*    DATA(worksheet) = write_access->get_workbook( )->worksheet->at_position( 1 ).
*    DATA(selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*    worksheet->select( selection_pattern
*               )->row_stream(
*               )->operation->write_from( REF #( val )
*               )->execute( ).
*    result = write_access->get_file_content( ).

  ENDMETHOD.

  METHOD conv_get_itab_by_xlsx.

*    CLEAR result.
*    DATA(document) = xco_cp_xlsx=>document->for_file_content( val )->read_access( ).
*    DATA(sheet) = document->get_workbook( )->worksheet->at_position( 1 ).
*    DATA(pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*    sheet->select( pattern
*            )->row_stream(
*            )->operation->write_to( REF #( result )
*            )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
*            )->execute( ).

  ENDMETHOD.

  METHOD zip_pack.

    DATA lo_zip TYPE REF TO object.
        DATA ls_file LIKE LINE OF files.
        DATA x TYPE REF TO cx_root.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').

        LOOP AT files INTO ls_file.
          CALL METHOD lo_zip->('ADD')
            EXPORTING
              name    = ls_file-name
              content = ls_file-content.
        ENDLOOP.
        CALL METHOD lo_zip->('SAVE')
          RECEIVING
            zip = result.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD zip_unpack.

    DATA lo_zip    TYPE REF TO object.
    DATA lv_name   TYPE string.
    DATA ls_result LIKE LINE OF result.

    FIELD-SYMBOLS <files> TYPE ANY TABLE.
    FIELD-SYMBOLS <file>  TYPE any.
    FIELD-SYMBOLS <name>  TYPE any.
        DATA x TYPE REF TO cx_root.

    TRY.

        CREATE OBJECT lo_zip TYPE ('CL_ABAP_ZIP').
        CALL METHOD lo_zip->('LOAD')
          EXPORTING
            zip = val.

        ASSIGN lo_zip->('FILES') TO <files>.
        LOOP AT <files> ASSIGNING <file>.
          ASSIGN COMPONENT `NAME` OF STRUCTURE <file> TO <name>.
          lv_name = <name>.

          CLEAR ls_result.
          ls_result-name = lv_name.
          CALL METHOD lo_zip->('GET')
            EXPORTING
              name    = lv_name
            IMPORTING
              content = ls_result-content.
          INSERT ls_result INTO TABLE result.
        ENDLOOP.


      CATCH cx_root INTO x.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
