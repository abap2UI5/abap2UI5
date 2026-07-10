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

    TYPES ty_t_data TYPE STANDARD TABLE OF ty_s_transport WITH EMPTY KEY.

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
    TYPES ty_t_dfies_2 TYPE STANDARD TABLE OF ty_s_dfies_2 WITH EMPTY KEY.

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
        interface  TYPE STANDARD TABLE OF ty_ddshiface WITH EMPTY KEY,                      " Placeholder for Interface of Search Help
        fielddescr TYPE STANDARD TABLE OF ty_s_dfies_2 WITH EMPTY KEY,
        fieldprop  TYPE STANDARD TABLE OF ty_ddshfprop WITH EMPTY KEY,
        selopt     TYPE STANDARD TABLE OF ty_ddshselopt WITH EMPTY KEY,
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
    TYPES ty_t_bal_header TYPE STANDARD TABLE OF ty_s_bal_header WITH EMPTY KEY.

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
    TYPES ty_t_tr_object TYPE STANDARD TABLE OF ty_s_tr_object WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_tr_request,
        trkorr      TYPE string,
        description TYPE string,
        owner       TYPE string,
        status      TYPE string,
        type        TYPE string,
      END OF ty_s_tr_request.
    TYPES ty_t_tr_request TYPE STANDARD TABLE OF ty_s_tr_request WITH EMPTY KEY.

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
    DATA names TYPE STANDARD TABLE OF ty_c30 WITH EMPTY KEY.
    FIELD-SYMBOLS <any> TYPE any.
    FIELD-SYMBOLS <field> TYPE simple.
    FIELD-SYMBOLS <ddfields> TYPE ANY TABLE.

* convert to correct type,
    lv_tabname = tabname.

    TRY.
        TRY.
            DATA(lv_method2) = `XCO_CP_ABAP_DICTIONARY`.
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
            DATA(workaround) = `DDFIELDS`.
            CREATE DATA lr_ddfields TYPE (workaround).
            ASSIGN lr_ddfields->* TO <ddfields>.
            ASSERT sy-subrc = 0.
            <ddfields> = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
              lv_tabname ) )->get_ddic_field_list( ).
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


    DATA(lt_comp)  =  z2ui5_cl_util=>rtti_get_t_attri_by_any( tabname ).
    LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).

      DATA(lv_check_key) = abap_false.
      IF line_exists( names[ table_line = lr_comp->name ] ).
        lv_check_key = abap_true.
      ENDIF.

      INSERT VALUE #(
          fieldname = lr_comp->name
          rollname  = lr_comp->name
          keyflag = lv_check_key
        scrtext_s =  lr_comp->name
        scrtext_m =  lr_comp->name
        scrtext_l =  lr_comp->name
       ) INTO TABLE result.

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

    IF langu IS NOT SUPPLIED.
      DATA(lan) = sy-langu.
    ELSE.
      lan = langu.
    ENDIF.

    IF z2ui5_CL_UTIL=>context_check_abap_cloud( ).

      ddtext = tabname.

    ELSE.

      DATA(lv_tabname) = `dd02t`.
      SELECT SINGLE ddtext
        FROM (lv_tabname)
        WHERE tabname    = @tabname
          AND ddlanguage = @lan
        INTO @ddtext.

    ENDIF.

    IF ddtext IS NOT INITIAL.
      result = ddtext.
    ELSE.
      result = tabname.
    ENDIF.

  ENDMETHOD.

  METHOD bus_search_help_read.

    DATA lt_result_tab TYPE TABLE OF string.
    DATA ls_comp       TYPE abap_componentdescr.
    DATA lt_comps      TYPE abap_component_tab.
    DATA lo_datadescr  TYPE REF TO cl_abap_datadescr.
    DATA lr_line       TYPE REF TO data.

    " data ls_shlp type shlp_descr.

    DATA lr_shlp       TYPE REF TO data.

    DATA(lv_type) = `SHLP_DESCR`.
    CREATE DATA lr_shlp TYPE (lv_type).
    FIELD-SYMBOLS <shlp> TYPE any.
    ASSIGN lr_shlp->* TO <shlp>.

    DATA lv_tabname   TYPE c LENGTH 30.
    DATA lv_fieldname TYPE c LENGTH 30.
    lv_tabname = mv_table.
    lv_fieldname = mv_fname.

    IF ms_shlp IS INITIAL.
      " Suchhilfe lesen
      DATA(lv_fm) = `F4IF_DETERMINE_SEARCHHELP`.
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
      ms_shlp = CORRESPONDING #( <shlp> ).

      IF ms_shlp-intdescr-issimple = abap_false.

*      DATA lt_shlp       TYPE shlp_desct.
        DATA lr_t_shlp TYPE REF TO data.
        DATA(lv_type2) = `SHLP_DESCT`.
        CREATE DATA lr_t_shlp TYPE (lv_type2).
        FIELD-SYMBOLS <shlp2> TYPE STANDARD TABLE.
        ASSIGN lr_t_shlp->* TO <shlp2>.

        lv_fm = `F4IF_EXPAND_SEARCHHELP`.
        CALL FUNCTION lv_fm
          EXPORTING
            shlp_top = ms_shlp
          IMPORTING
            shlp_tab = <shlp2>.

*        DATA(ls_row) = CORRESPONDING #( <shlp2>[ 1 ] OPTIONAL ).
        FIELD-SYMBOLS <row2> TYPE any.
        ASSIGN  <shlp2>[ 1 ] TO <row2>.
        ms_shlp = CORRESPONDING #( <row2> ).
      ENDIF.
    ENDIF.

    IF mr_data IS BOUND.
      " Values from Caller app to Interface Values
      LOOP AT ms_shlp-interface REFERENCE INTO DATA(r_interface) WHERE value IS INITIAL.

        FIELD-SYMBOLS <any> TYPE any.
        ASSIGN mr_data->* TO <any>.
        FIELD-SYMBOLS <value> TYPE any.
        ASSIGN COMPONENT r_interface->shlpfield OF STRUCTURE <any> TO <value>.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        r_interface->value = <value>.

      ENDLOOP.
    ENDIF.

    " Interface Fixed Values to Selopt
    LOOP AT ms_shlp-interface INTO DATA(interface).

      " Match the name of the SH Field to the Input field name
      IF interface-valfield = mv_fname.
        mv_shlpfield = interface-shlpfield.
      ENDIF.

      IF interface-value IS NOT INITIAL.

        ms_shlp-selopt = VALUE #( BASE ms_shlp-selopt
                                  ( shlpfield = interface-shlpfield
                                    shlpname  = interface-valtabname
                                    option    = COND #( WHEN interface-value CA `*` THEN `CP` ELSE `EQ` )
                                    sign      = `I`
                                    low       = interface-value  ) ).

      ENDIF.

    ENDLOOP.

    LOOP AT ms_shlp-fieldprop INTO DATA(fieldrop).

      IF fieldrop-defaultval IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(valule) = fieldrop-defaultval.
      REPLACE ALL OCCURRENCES OF `'` IN valule WITH ``.

      ms_shlp-selopt = VALUE #( BASE ms_shlp-selopt
                                ( shlpfield = fieldrop-fieldname
*                                  shlpname  =
                                  option    = COND #( WHEN fieldrop-defaultval CA `*` THEN `CP` ELSE `EQ` )
                                  sign      = `I`
                                  low       = valule  ) ).

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

    LOOP AT ms_shlp-fieldprop INTO DATA(field_props) WHERE shlplispos IS NOT INITIAL.

      DATA(descption) = VALUE #( mt_result_desc[ fieldname = field_props-fieldname ] OPTIONAL ).

      ls_comp-name  = descption-fieldname.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( descption-rollname ).
      APPEND ls_comp TO lt_comps.

    ENDLOOP.

    IF NOT line_exists( lt_comps[ name = `ROW_ID` ] ).
      lo_datadescr ?= cl_abap_datadescr=>describe_by_name( `INT4` ).
      ls_comp-name  = `ROW_ID`.
      ls_comp-type ?= lo_datadescr.
      APPEND ls_comp TO lt_comps.
    ENDIF.

    DATA(strucdescr) = cl_abap_structdescr=>create( p_components = lt_comps ).

    DATA(tabdescr) = cl_abap_tabledescr=>create( p_line_type = strucdescr ).

    IF mt_data IS NOT BOUND.
      CREATE DATA mt_data TYPE HANDLE tabdescr.
    ENDIF.

    FIELD-SYMBOLS <fs_target_tab> TYPE STANDARD TABLE.
    ASSIGN mt_data->* TO <fs_target_tab>.

    CLEAR <fs_target_tab>.

    " we don`t want to lose all inputs in row ...
    IF ms_data_row IS NOT BOUND.
      CREATE DATA ms_data_row TYPE HANDLE strucdescr.
    ENDIF.

    LOOP AT lt_result_tab INTO DATA(result_line).

      CREATE DATA lr_line TYPE HANDLE strucdescr.
      ASSIGN lr_line->* TO FIELD-SYMBOL(<fs_line>).

      LOOP AT mt_result_desc INTO DATA(result_desc).

        ASSIGN COMPONENT result_desc-fieldname OF STRUCTURE <fs_line>
               TO FIELD-SYMBOL(<line_content>).

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

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.

    ASSIGN mt_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <line> TO FIELD-SYMBOL(<row>).
      IF <row> IS ASSIGNED.
        <row> = sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.



  METHOD tab_get_where_by_dfies.

    DATA val TYPE string.

    LOOP AT it_dfies REFERENCE INTO DATA(dfies).

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      ASSIGN ms_data_row->* TO FIELD-SYMBOL(<row>).

      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE <row> TO FIELD-SYMBOL(<value>).
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF <value> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS NOT INITIAL.
        DATA(and) = ` AND `.
      ENDIF.

      IF <value> CA `_`.
        DATA(escape) = `ESCAPE '#'`.
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

    LOOP AT dfies INTO DATA(s_dfies) WHERE keyflag = abap_true.

      ASSIGN COMPONENT s_dfies-fieldname OF STRUCTURE line TO FIELD-SYMBOL(<value>).
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

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

    ELSE.

      FIELD-SYMBOLS <e071>    TYPE any.
      FIELD-SYMBOLS <t_e071k> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <t_e071>  TYPE STANDARD TABLE.

      " We need to set the MANDT is necessary
      set_mandt( ir_data ).

      DATA(r_e071k) = _set_e071k( ir_data      = ir_data
                                  iv_tabname   = iv_tabname
                                  is_transport = is_transport ).
      ASSIGN r_e071k->* TO <e071>.
      IF <e071> IS INITIAL.
        RETURN.
      ENDIF.

      DATA(r_e071) = _set_e071( iv_tabname   = iv_tabname
                                is_transport = is_transport ).

      ASSIGN r_e071k->* TO <t_e071k>.
      ASSIGN r_e071->* TO <t_e071>.

      DATA(fb1) = 'TR_APPEND_TO_COMM_OBJS_KEYS'.
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

      DATA(fb2) = 'TR_SORT_AND_COMPRESS_COMM'.
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

    DATA(t_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( 'E071K' ).

    TRY.

        DATA(struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(table_desc) = cl_abap_tabledescr=>create( p_line_type  = struct_desc
                                                       p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA t_e071k TYPE HANDLE table_desc.
        CREATE DATA s_e071k TYPE HANDLE struct_desc.

        ASSIGN t_e071k->* TO <t_e071k>.
        ASSIGN s_e071k->* TO <s_e071k>.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    DATA(dfies) = rtti_get_t_dfies_by_table_name( iv_tabname ).

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

    DATA(t_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( 'E071' ).

    TRY.

        DATA(struct_desc_new) = cl_abap_structdescr=>create( t_comp ).

        DATA(table_desc_new) = cl_abap_tabledescr=>create( p_line_type  = struct_desc_new
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

    DATA(table_name) = 'E070'.

    TRY.
        DATA(t_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( table_name ).

        DATA(new_struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA lo_tab TYPE HANDLE new_table_desc.
        CREATE DATA lo_line TYPE HANDLE new_struct_desc.

        ASSIGN lo_tab->* TO <table>.
        ASSIGN lo_line->* TO <line>.

        DATA(where) =
        |( TRFUNCTION EQ 'Q' ) AND ( TRSTATUS EQ 'D' ) AND ( KORRDEV EQ 'CUST' ) AND ( AS4USER EQ '{ sy-uname }' )|.

        SELECT trkorr,
               trfunction,
               trstatus,
               tarsystem,
               korrdev,
               as4user,
               as4date,
               as4time,
               strkorr
          FROM (table_name)
          WHERE (where)
          INTO TABLE @<table>.
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

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

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

      DATA lo_tab  TYPE REF TO data.
      DATA lo_line TYPE REF TO data.

      FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <line>  TYPE any.
      FIELD-SYMBOLS <value> TYPE any.

      _read_e070( CHANGING mt_data = mt_data ).

      DATA(table_name) = 'E07T'.

      TRY.
          DATA(t_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( table_name ).

          DATA(new_struct_desc) = cl_abap_structdescr=>create( t_comp ).

          DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                             p_table_kind = cl_abap_tabledescr=>tablekind_std ).

          CREATE DATA lo_tab TYPE HANDLE new_table_desc.
          CREATE DATA lo_line TYPE HANDLE new_struct_desc.

          ASSIGN lo_tab->* TO <table>.
          ASSIGN lo_line->* TO <line>.

          DATA(index) = 0.

          LOOP AT mt_data INTO DATA(line).
            index = index + 1.
            IF index = 1.
              DATA(where) = |TRKORR EQ '{ line-task }'|.
            ELSE.
              where = |{ where } OR TRKORR EQ '{ line-task }'|.
            ENDIF.
            where = |( { where } )|.
          ENDLOOP.

          SELECT trkorr,
                 langu,
                 as4text
            FROM (table_name)
            WHERE (where)
            INTO TABLE @<table>.
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

          READ TABLE mt_data REFERENCE INTO DATA(data) WITH KEY task = <value>.
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

    ASSIGN ir_data->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT `MANDT` OF STRUCTURE <line> TO FIELD-SYMBOL(<row>).
      IF <row> IS ASSIGNED.

        TRY.
            <row> = sy-mandt.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD conv_exit.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

    ELSE.

      DATA(conv) = |CONVERSION_EXIT_{ name-convexit }_INPUT|.
      DATA conex TYPE c LENGTH 30.
      DATA(lv_tab) = 'TFDIR'.

      SELECT SINGLE funcname FROM (lv_tab)
        WHERE funcname = @conv
        INTO @conex.

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

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      " Cloud: use CL_BALI_LOG_FILTER + CL_BALI_LOG_DB
      DATA lo_filter TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lt_logs   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_class  TYPE string.

      TRY.
          lv_class = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_class)=>(`CREATE`)
            RECEIVING
              filter = lo_filter.

          DATA(lv_obj_f) = COND string( WHEN object IS NOT INITIAL THEN object ELSE `` ).
          DATA(lv_sub_f) = COND string( WHEN subobject IS NOT INITIAL THEN subobject ELSE `` ).
          DATA(lv_id_f)  = COND string( WHEN id IS NOT INITIAL THEN id ELSE `` ).
          CALL METHOD lo_filter->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = lv_obj_f
              subobject   = lv_sub_f
              external_id = lv_id_f.

          IF date_from IS NOT INITIAL OR date_to IS NOT INITIAL.
            DATA(lv_from) = COND d( WHEN date_from IS NOT INITIAL THEN date_from ELSE '19000101' ).
            DATA(lv_to)   = COND d( WHEN date_to IS NOT INITIAL THEN date_to ELSE sy-datum ).
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

          LOOP AT lt_logs INTO DATA(lo_log).
            DATA(ls_hdr_c) = VALUE ty_s_bal_header( ).
            TRY.
                DATA lo_header TYPE REF TO object.
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
    DATA lv_fm      TYPE string.
    DATA lr_filter  TYPE REF TO data.
    DATA lr_headers TYPE REF TO data.
    FIELD-SYMBOLS <filter>  TYPE any.
    FIELD-SYMBOLS <headers> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <header>  TYPE any.
    FIELD-SYMBOLS <comp>    TYPE any.
    FIELD-SYMBOLS <range>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline>   TYPE any.
    DATA lr_rline TYPE REF TO data.

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
          <comp> = COND d( WHEN date_from IS NOT INITIAL THEN date_from ELSE '19000101' ).
          ASSIGN COMPONENT `HIGH` OF STRUCTURE <rline> TO <comp>.
          <comp> = COND d( WHEN date_to IS NOT INITIAL THEN date_to ELSE sy-datum ).
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
          DATA(ls_hdr) = VALUE ty_s_bal_header( ).
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

    DATA(lt_msgs) = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    IF lt_msgs IS NOT INITIAL.
      result = lt_msgs[ lines( lt_msgs ) ].
    ENDIF.

  ENDMETHOD.

  METHOD bal_delete_before.

    DATA(lv_cutoff) = CONV d( sy-datum - days ).

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      " Cloud: use CL_BALI_LOG_DB to delete via filter
      DATA lo_filter_c TYPE REF TO object.
      DATA lo_db_c     TYPE REF TO object.
      DATA lt_logs_c   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_cls      TYPE string.

      TRY.
          lv_cls = `CL_BALI_LOG_FILTER`.
          CALL METHOD (lv_cls)=>(`CREATE`)
            RECEIVING
              filter = lo_filter_c.

          DATA(lv_sub_c) = COND string( WHEN subobject IS NOT INITIAL THEN subobject ELSE `` ).
          CALL METHOD lo_filter_c->(`SET_DESCRIPTOR`)
            EXPORTING
              object      = object
              subobject   = lv_sub_c
              external_id = ``.

          CALL METHOD lo_filter_c->(`SET_CREATE_DATE`)
            EXPORTING
              from_date = CONV d( '19000101' )
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

          LOOP AT lt_logs_c INTO DATA(lo_log_c).
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
    DATA lv_fm     TYPE string.
    DATA lr_filter TYPE REF TO data.
    FIELD-SYMBOLS <filter> TYPE any.
    FIELD-SYMBOLS <range>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <rline>  TYPE any.
    FIELD-SYMBOLS <comp>   TYPE any.
    DATA lr_rline TYPE REF TO data.

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

    DATA(lt_all) = bal_read( object    = object
                             subobject = subobject
                             id        = id ).

    LOOP AT lt_all INTO DATA(ls_msg)
         WHERE type = msg_type.
      INSERT ls_msg INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD bal_count.

    DATA(lt_msgs) = bal_read( object    = object
                              subobject = subobject
                              id        = id ).
    result = lines( lt_msgs ).

  ENDMETHOD.

  METHOD bal_read.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

      " Load the persisted logs (incl. items) via the released filter API and map
      " each item back to the framework's z2ui5_cl_util=>ty_s_msg structure with full metadata.
      TYPES:
        BEGIN OF ty_item,
          log_item_number TYPE i,
          item            TYPE REF TO object,
        END OF ty_item.
      DATA lt_items    TYPE STANDARD TABLE OF ty_item.
      DATA lo_filter   TYPE REF TO object.
      DATA lo_db       TYPE REF TO object.
      DATA lt_logs     TYPE STANDARD TABLE OF REF TO object.
      DATA lv_text     TYPE string.
      DATA lv_class    TYPE string.
      DATA lv_severity TYPE c LENGTH 1.
      DATA lv_msgid    TYPE string.
      DATA lv_msgno    TYPE string.
      DATA lv_msgv1    TYPE string.
      DATA lv_msgv2    TYPE string.
      DATA lv_msgv3    TYPE string.
      DATA lv_msgv4    TYPE string.

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

          LOOP AT lt_logs INTO DATA(lo_log).

            lt_items = VALUE #( ).
            CALL METHOD lo_log->(`GET_ALL_ITEMS`)
              RECEIVING
                item_table = lt_items.

            LOOP AT lt_items INTO DATA(ls_item).
              IF ls_item-item IS NOT BOUND.
                CONTINUE.
              ENDIF.

              DATA(ls_msg) = VALUE z2ui5_cl_util=>ty_s_msg( ).

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

      DATA lv_fm      TYPE string.
      DATA lr_handles TYPE REF TO data.
      DATA lr_single  TYPE REF TO data.
      DATA lr_msgh    TYPE REF TO data.
      DATA lr_msg     TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle>  TYPE any.
      FIELD-SYMBOLS <single>  TYPE STANDARD TABLE.
      FIELD-SYMBOLS <msgh>    TYPE STANDARD TABLE.
      FIELD-SYMBOLS <mh>      TYPE any.
      FIELD-SYMBOLS <msg>     TYPE any.

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

        CATCH cx_root INTO DATA(lx_read).
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_read.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_create.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

      " ABAP Cloud: released Business Application Log API (cl_bali_*).
      " All access is dynamic so this class still compiles on lower releases.
      " The class names are kept in variables - a string literal inside the
      " dynamic component selector ( '...' )=>( '...' ) is not valid ABAP.
      " Returning parameter names follow the released API (header/log/db_handler).
      DATA lo_header TYPE REF TO object.
      DATA lo_log    TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lv_class  TYPE string.

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
      DATA lv_fm      TYPE string.
      DATA lr_log     TYPE REF TO data.
      DATA lr_handle  TYPE REF TO data.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <log>     TYPE any.
      FIELD-SYMBOLS <handle>  TYPE any.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <comp>    TYPE any.

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

        CATCH cx_root INTO DATA(lx_create).
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_create.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_update.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

      " Load the existing log and append items. If no log exists, create a new one.
      DATA lo_filter TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lt_logs   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_class  TYPE string.

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
          DATA(lo_log) = lt_logs[ 1 ].
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
      DATA lv_fm      TYPE string.
      DATA lr_handles TYPE REF TO data.
      FIELD-SYMBOLS <handles> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <handle>  TYPE any.

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

          ASSIGN <handles>[ 1 ] TO <handle>.
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

        CATCH cx_root INTO DATA(lx_update).
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_update.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD bal_delete.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).

      DATA lo_filter TYPE REF TO object.
      DATA lo_db     TYPE REF TO object.
      DATA lt_logs   TYPE STANDARD TABLE OF REF TO object.
      DATA lv_class  TYPE string.

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

          LOOP AT lt_logs INTO DATA(lo_log).
            CALL METHOD lo_db->(`DELETE_LOG`)
              EXPORTING
                log = lo_log.
          ENDLOOP.

          COMMIT WORK AND WAIT.

        CATCH cx_root.
          RETURN.
      ENDTRY.

    ELSE.

      DATA lv_fm     TYPE string.
      DATA lr_filter TYPE REF TO data.
      FIELD-SYMBOLS <filter> TYPE any.

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

        CATCH cx_root INTO DATA(lx_delete).
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = lx_delete.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

  METHOD tr_get_objects.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS
      TRY.
          DATA lo_transport TYPE REF TO object.
          DATA lt_objects_c TYPE STANDARD TABLE OF REF TO object.
          DATA(lv_xco) = `XCO_CP_CTS`.
          DATA(lv_trkorr_c) = CONV string( trkorr ).

          CALL METHOD (lv_xco)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = lv_trkorr_c
            RECEIVING
              ro_transport = lo_transport.

          DATA lo_objects_api TYPE REF TO object.
          CALL METHOD lo_transport->(`OBJECTS`)
            RECEIVING
              ro_objects = lo_objects_api.

          DATA lo_all TYPE REF TO object.
          CALL METHOD lo_objects_api->(`ALL`)
            RECEIVING
              ro_all = lo_all.

          CALL METHOD lo_all->(`GET`)
            RECEIVING
              rt_objects = lt_objects_c.

          LOOP AT lt_objects_c INTO DATA(lo_obj).
            DATA ls_obj_c TYPE ty_s_tr_object.
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
    DATA lr_objects TYPE REF TO data.
    DATA lr_header  TYPE REF TO data.
    FIELD-SYMBOLS <objects> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <object>  TYPE any.
    FIELD-SYMBOLS <header>  TYPE any.
    FIELD-SYMBOLS <comp>    TYPE any.
    DATA lv_fm TYPE string.

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
          DATA(ls_obj) = VALUE ty_s_tr_object( ).
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

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS transport filter
      TRY.
          DATA(lv_xco) = `XCO_CP_CTS`.
          DATA lo_filter_tr  TYPE REF TO object.
          DATA lo_status_f   TYPE REF TO object.
          DATA lo_owner_f    TYPE REF TO object.
          DATA lt_transports TYPE STANDARD TABLE OF REF TO object.

          DATA(lv_user_c) = CONV string( COND #( WHEN user IS NOT INITIAL THEN user ELSE sy-uname ) ).

          " Get modifiable transports for user
          CALL METHOD (lv_xco)=>(`TRANSPORTS`)
            RECEIVING
              ro_transports = lo_filter_tr.

          DATA lo_where TYPE REF TO object.
          CALL METHOD lo_filter_tr->(`ALL`)
            RECEIVING
              ro_all = lo_where.

          CALL METHOD lo_where->(`GET`)
            RECEIVING
              rt_transports = lt_transports.

          LOOP AT lt_transports INTO DATA(lo_tr).
            DATA ls_req_c TYPE ty_s_tr_request.
            CLEAR ls_req_c.
            TRY.
                DATA lo_props TYPE REF TO object.
                CALL METHOD lo_tr->(`PROPERTIES`)
                  RECEIVING
                    ro_properties = lo_props.
                DATA ls_prop TYPE REF TO data.
                CALL METHOD lo_props->(`GET`)
                  RECEIVING
                    rs_properties = ls_prop.
                FIELD-SYMBOLS <prop> TYPE any.
                FIELD-SYMBOLS <pcomp> TYPE any.
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

                DATA lv_tr_value TYPE string.
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
    DATA lv_user  TYPE c LENGTH 12.
    DATA lv_type  TYPE c LENGTH 1.
    DATA lr_data  TYPE REF TO data.
    FIELD-SYMBOLS <tab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <comp>  TYPE any.

    TRY.
        lv_user = user.
        lv_type = request_type.

        DATA(lv_tab1) = `E070`.
        DATA(lv_tab2) = `E07T`.
        DATA(lv_where) = |AS4USER = '{ lv_user }' AND TRSTATUS IN ('D','L')|.

        " First read transports from E070
        DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_table_name( lv_tab1 ).
        DATA(lo_struct) = cl_abap_structdescr=>create( lt_comp ).
        DATA(lo_table) = cl_abap_tabledescr=>create( lo_struct ).
        CREATE DATA lr_data TYPE HANDLE lo_table.
        ASSIGN lr_data->* TO <tab>.

        SELECT trkorr, as4user, trstatus, trfunction
          FROM (lv_tab1)
          WHERE (lv_where)
          INTO CORRESPONDING FIELDS OF TABLE @<tab>.

        LOOP AT <tab> ASSIGNING <row>.
          DATA(ls_req) = VALUE ty_s_tr_request( ).
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

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS
      TRY.
          DATA lo_tr_d TYPE REF TO object.
          DATA(lv_xco_d) = `XCO_CP_CTS`.
          CALL METHOD (lv_xco_d)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = CONV string( trkorr )
            RECEIVING
              ro_transport = lo_tr_d.
          DATA lo_props_d TYPE REF TO object.
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
    DATA lv_trkorr TYPE c LENGTH 20.
    lv_trkorr = trkorr.

    TRY.
        DATA(lv_tab) = `E07T`.
        DATA(lv_where) = |TRKORR = '{ lv_trkorr }' AND LANGU = '{ sy-langu }'|.

        SELECT SINGLE as4text
          FROM (lv_tab)
          WHERE (lv_where)
          INTO @result.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_is_released.

    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      " Cloud: use XCO_CP_CTS
      TRY.
          DATA lo_tr_r TYPE REF TO object.
          DATA(lv_xco_r) = `XCO_CP_CTS`.
          CALL METHOD (lv_xco_r)=>(`TRANSPORT`)
            EXPORTING
              iv_transport = CONV string( trkorr )
            RECEIVING
              ro_transport = lo_tr_r.
          DATA lo_props_r TYPE REF TO object.
          CALL METHOD lo_tr_r->(`PROPERTIES`)
            RECEIVING
              ro_properties = lo_props_r.
          DATA lv_status_c TYPE string.
          CALL METHOD lo_props_r->(`GET_STATUS`)
            RECEIVING
              rv_status = lv_status_c.
          result = xsdbool( lv_status_c = `RELEASED` OR lv_status_c = `R` ).
        CATCH cx_root.
          result = abap_false.
      ENDTRY.
      RETURN.
    ENDIF.

    " Standard: dynamic SELECT from E070
    DATA lv_trkorr TYPE c LENGTH 20.
    DATA lv_status TYPE c LENGTH 1.
    lv_trkorr = trkorr.

    TRY.
        DATA(lv_tab) = `E070`.
        DATA(lv_where) = |TRKORR = '{ lv_trkorr }'|.

        SELECT SINGLE trstatus
          FROM (lv_tab)
          WHERE (lv_where)
          INTO @lv_status.
        result = xsdbool( lv_status = `R` ).
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

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        RAISE EXCEPTION lx.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_create.

    " Create an empty transport request (default type `T` = transport of copies).
    " Uses the released class CL_ADT_CTS_MANAGEMENT, available on standard ABAP
    " (>= 7.51) and ABAP Cloud. Called dynamically so the source stays compilable
    " on all targets - on releases where the class is missing a clean
    " z2ui5_cx_util_error is raised instead of a short dump.
    TRY.

        DATA lr_header TYPE REF TO data.
        FIELD-SYMBOLS <header> TYPE any.
        FIELD-SYMBOLS <trkorr> TYPE any.
        DATA lv_class TYPE string.

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

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_release.

    " Release a transport request via the released CTS REST API
    " (CL_CTS_REST_API_FACTORY). Works on standard ABAP and ABAP Cloud.
    TRY.

        DATA lo_api   TYPE REF TO object.
        DATA lv_class TYPE string.

        lv_class = `CL_CTS_REST_API_FACTORY`.
        CALL METHOD (lv_class)=>(`CREATE_INSTANCE`)
          RECEIVING
            result = lo_api.

        CALL METHOD lo_api->(`RELEASE`)
          EXPORTING
            iv_trkorr       = trkorr
            iv_ignore_locks = ignore_locks.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_copy_objects.

    " Copying objects between requests relies on the classic transport
    " functions (TR_COPY_COMM) which are not released on ABAP Cloud.
    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_copy_objects is not supported on ABAP Cloud`.
    ENDIF.

    " Copy all objects/commands of a source request (and its tasks) into a
    " target request via the classic transport functions. Called dynamically
    " so the statement stays compilable on ABAP Cloud as well, even though the
    " function modules only exist on-premise.
    TRY.

        DATA lr_headers TYPE REF TO data.
        FIELD-SYMBOLS <headers> TYPE ANY TABLE.
        FIELD-SYMBOLS <header>  TYPE any.
        FIELD-SYMBOLS <trkorr>  TYPE any.
        FIELD-SYMBOLS <strkorr> TYPE any.
        DATA lv_fm TYPE string.

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

      CATCH z2ui5_cx_util_error INTO DATA(lx_known).
        RAISE EXCEPTION lx_known.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_import.

    " Importing transports via TMS (TMS_MGR_*) is not available on ABAP Cloud.
    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_import is not supported on ABAP Cloud`.
    ENDIF.

    " Import a transport request into a target system via TMS. The target
    " system may be given as `SYSTEM` or `SYSTEM.CLIENT`; an explicit client
    " parameter takes precedence, otherwise the current client is used.
    TRY.

        DATA lv_system  TYPE c LENGTH 8.
        DATA lv_client  TYPE c LENGTH 3.
        DATA lv_retcode TYPE c LENGTH 4.
        DATA lr_exc     TYPE REF TO data.
        FIELD-SYMBOLS <exc> TYPE any.
        DATA lv_fm TYPE string.

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

      CATCH z2ui5_cx_util_error INTO DATA(lx_known).
        RAISE EXCEPTION lx_known.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD tr_check_status.

    " Reading the transport log (TR_READ_GLOBAL_INFO_OF_REQUEST) is not
    " available on ABAP Cloud.
    IF z2ui5_cl_util=>context_check_abap_cloud( ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `tr_check_status is not supported on ABAP Cloud`.
    ENDIF.

    " Read the import status (imported flag + return code) of a request in a
    " given system via the classic transport log API.
    TRY.

        DATA lr_settings TYPE REF TO data.
        DATA lr_cofile   TYPE REF TO data.
        DATA lr_sysline  TYPE REF TO data.
        FIELD-SYMBOLS <settings> TYPE any.
        FIELD-SYMBOLS <systems>  TYPE ANY TABLE.
        FIELD-SYMBOLS <sysline>  TYPE any.
        FIELD-SYMBOLS <cofile>   TYPE any.
        FIELD-SYMBOLS <comp>     TYPE any.
        DATA lv_fm TYPE string.

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

      CATCH z2ui5_cx_util_error INTO DATA(lx_known).
        RAISE EXCEPTION lx_known.
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            previous = x.
    ENDTRY.

  ENDMETHOD.

  METHOD bal_cloud_add_items.

    DATA lo_item  TYPE REF TO object.
    DATA lv_msgty TYPE c LENGTH 1.
    DATA lv_class TYPE string.

    LOOP AT t_log INTO DATA(ls_log).

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

    LOOP AT t_log INTO DATA(ls_log).

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

ENDCLASS.
