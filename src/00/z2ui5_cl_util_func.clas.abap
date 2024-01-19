CLASS z2ui5_cl_util_func DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS js_load_ext_lib
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url_source_code
      IMPORTING
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url
      IMPORTING
        !client          TYPE REF TO z2ui5_if_client
        VALUE(classname) TYPE string OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    CLASS-METHODS url_param_get
      IMPORTING
        !val          TYPE string
        !url          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        !t_params     TYPE z2ui5_if_client=>ty_t_name_value
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_set
      IMPORTING
        !url          TYPE string
        !name         TYPE string
        !value        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        !in           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS x_check_raise
      IMPORTING
        !v    TYPE clike DEFAULT `CX_SY_SUBRC`
        !when TYPE abap_bool.

    CLASS-METHODS x_raise
      IMPORTING
        !v TYPE clike DEFAULT `CX_SY_SUBRC`
          PREFERRED PARAMETER v.

    CLASS-METHODS func_get_uuid_32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS func_get_uuid_22
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS func_get_user_tech
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_json_any_2
      IMPORTING
        !any          TYPE any
        !pretty_name  TYPE clike DEFAULT /ui2/cl_json=>pretty_mode-none
        !compress     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS trans_xml_2_any
      IMPORTING
        !xml TYPE clike
      EXPORTING
        !any TYPE any.

    CLASS-METHODS trans_xml_any_2
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    CLASS-METHODS boolean_check_by_data
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS boolean_abap_2_json
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_replace_assign_struc
      IMPORTING
        !iv_attri       TYPE clike
      RETURNING
        VALUE(rv_attri) TYPE string.

    CLASS-METHODS trans_json_2_any
      IMPORTING
        !val  TYPE any
      CHANGING
        !data TYPE any.

    CLASS-METHODS trans_ref_tab_2_tab
      IMPORTING
        !ir_tab_from TYPE REF TO data
        pretty_name  TYPE abap_bool DEFAULT abap_false
      EXPORTING
        !t_result    TYPE STANDARD TABLE.

    CLASS-METHODS trans_ref_struc_2_struc
      IMPORTING
        !ir_struc_from TYPE REF TO data
        pretty_name    TYPE abap_bool DEFAULT abap_false
      EXPORTING
        !r_result      TYPE data.

    CLASS-METHODS c_trim_upper
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_xml_get_by_data
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_xml_set_to_data
      IMPORTING
        !rtti_data TYPE clike
      EXPORTING
        !e_data    TYPE REF TO data .
    CLASS-METHODS time_get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl .
    CLASS-METHODS time_substract_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl .
    CLASS-METHODS c_trim
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS c_trim_lower
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS url_param_get_tab
      IMPORTING
        !i_val           TYPE clike
      RETURNING
        VALUE(rt_params) TYPE z2ui5_if_client=>ty_t_name_value .
    CLASS-METHODS rtti_get_t_attri_by_object
      IMPORTING
        !val          TYPE REF TO object
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab .
    CLASS-METHODS rtti_get_t_comp_by_data
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.
    CLASS-METHODS rtti_get_type_name
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_type_kind_dref
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        !val          TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS boolean_check_by_name
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util_func IMPLEMENTATION.


  METHOD app_get_url.

    IF classname IS INITIAL.
      classname = rtti_get_classname_by_ref( client->get( )-s_draft-app ).
    ENDIF.

    DATA(lv_url) = to_lower( client->get( )-s_config-origin && client->get( )-s_config-pathname ) && `?`.
    DATA(lt_param) = url_param_get_tab( client->get( )-s_config-search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start` v = to_lower( classname ) ) INTO TABLE lt_param.

    result = lv_url && url_param_create_url( lt_param ).

  ENDMETHOD.


  METHOD app_get_url_source_code.

    DATA(ls_draft) = client->get( )-s_draft.
    DATA(ls_config) = client->get( )-s_config.

    result = ls_config-origin && `/sap/bc/adt/oo/classes/`
       && rtti_get_classname_by_ref( ls_draft-app ) && `/source/main`.

  ENDMETHOD.


  METHOD boolean_abap_2_json.

    IF boolean_check_by_data( val ).
      result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.


  METHOD boolean_check_by_data.

    TRY.
        DATA(lv_type_name) = rtti_get_type_name( val ).
        result = boolean_check_by_name( lv_type_name ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD c_replace_assign_struc.

    rv_attri  = iv_attri.
    DATA(lv_length) = strlen( rv_attri ) - 2.
    DATA(lv_attri_end) = rv_attri+lv_length.

    IF lv_attri_end = `>*`.
      lv_attri_end = `>`.
      lv_length = lv_length.
    ELSE.
      lv_attri_end = `-`.
      lv_length = lv_length + 2.
    ENDIF.
    rv_attri = rv_attri(lv_length) && lv_attri_end.

  ENDMETHOD.


  METHOD c_trim.

    result = shift_left( shift_right( CONV string( val ) ) ).
    result = shift_right( val = result sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( val = result sub = cl_abap_char_utilities=>horizontal_tab ).
    result = shift_left( shift_right( result ) ).

  ENDMETHOD.


  METHOD c_trim_lower.

    result = to_lower( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD c_trim_upper.

    result = to_upper( c_trim( CONV string( val ) ) ).

  ENDMETHOD.


  METHOD func_get_user_tech.
    result = sy-uname.
  ENDMETHOD.


  METHOD func_get_uuid_22.

    TRY.
        DATA uuid TYPE c LENGTH 22.

        TRY.
            CALL METHOD (`CL_SYSTEM_UUID`)=>if_system_uuid_static~create_uuid_c22
              RECEIVING
                uuid = uuid.

          CATCH cx_sy_dyn_call_illegal_class.

            DATA(lv_fm) = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_22 = uuid.

        ENDTRY.

        result = uuid.

      CATCH cx_root.
        ASSERT 1 = 0.
    ENDTRY.

    result = replace( val = result sub = `}` with = `0` occ = 0 ).
    result = replace( val = result sub = `{` with = `0` occ = 0 ).
    result = replace( val = result sub = `"` with = `0` occ = 0 ).
    result = replace( val = result sub = `'` with = `0` occ = 0 ).

  ENDMETHOD.


  METHOD func_get_uuid_32.

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


  METHOD js_load_ext_lib.

    result = `      async loadScriptExt(url) {` && |\n|  &&
             `          this.BusyDialog = new sap.m.BusyDialog({ title: "External Library", text: "... now loading the data from a far away server" });` && |\n|  &&
             `          this.BusyDialog.open();` && |\n|  &&
             |\n|  &&
             `          const loadScript = (FILE_URL, async = true, type = "text/javascript") => {` && |\n|  &&
             `              return new Promise((resolve, reject) => {` && |\n|  &&
             `                  try {` && |\n|  &&
             `                      const scriptEle = document.createElement("script");` && |\n|  &&
             `                      scriptEle.type = type;` && |\n|  &&
             `                      scriptEle.async = async;` && |\n|  &&
             `                      scriptEle.src = FILE_URL;` && |\n|  &&
             `                      scriptEle.addEventListener("load", (ev) => {` && |\n|  &&
             `                          resolve({ status: true });` && |\n|  &&
             `                      });` && |\n|  &&
             `                      scriptEle.addEventListener("error", (ev) => {` && |\n|  &&
             `                          reject({` && |\n|  &&
             `                              status: false,` && |\n|  &&
             `                              message: ``Failed to load the script ${FILE_URL}``` && |\n|  &&
             `                          });` && |\n|  &&
             `                      });` && |\n|  &&
             `                      document.body.appendChild(scriptEle);` && |\n|  &&
             `                  } catch (error) {` && |\n|  &&
             `                      reject(error);` && |\n|  &&
             `                  }` && |\n|  &&
             `              });` && |\n|  &&
             `          };` && |\n|  &&
             |\n|  &&
             `          await loadScript(url)` && |\n|  &&
             `              .then(data => {` && |\n|  &&
             `                  this.result = 'A';` && |\n|  &&
             `              }).catch(err => {` && |\n|  &&
             `                  this.result = 'E';` && |\n|  &&
             `              });` && |\n|  &&
             `          this.BusyDialog.close();` && |\n|  &&
             `          return this.result;` && |\n|  &&
             |\n|  &&
             `      },`.

  ENDMETHOD.


  METHOD rtti_check_type_kind_dref.

    DATA(lv_type_kind) = cl_abap_datadescr=>get_data_type_kind( val ).
    result = xsdbool( lv_type_kind = cl_abap_typedescr=>typekind_dref ).

  ENDMETHOD.


  METHOD rtti_get_classes_impl_intf.

    TRY.

        DATA obj TYPE REF TO object.
        CALL METHOD ('XCO_CP_ABAP')=>interface
          EXPORTING
            iv_name      = val
          RECEIVING
            ro_interface = obj.

        FIELD-SYMBOLS <any> TYPE any.
        ASSIGN obj->('IF_XCO_AO_INTERFACE~IMPLEMENTATIONS') TO <any>.
        obj = <any>.

        ASSIGN obj->('IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL') TO <any>.
        obj = <any>.

        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET').

        DATA lt_implementation_names TYPE string_table.
        CALL METHOD obj->('IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES')
          RECEIVING
            rt_names = lt_implementation_names.

        result = lt_implementation_names.

      CATCH cx_sy_dyn_call_illegal_class.

        TYPES:
          BEGIN OF ty_s_impl,
            clsname    TYPE c LENGTH 30,
            refclsname TYPE c LENGTH 30,
          END OF ty_s_impl.
        DATA lt_impl TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.

        TYPES:
          BEGIN OF ty_s_key,
            intkey TYPE c LENGTH 30,
          END OF ty_s_key.
        DATA ls_key TYPE ty_s_key.
        ls_key-intkey = val.

        DATA(lv_fm) = `SEO_INTERFACE_IMPLEM_GET_ALL`.
        CALL FUNCTION lv_fm
          EXPORTING
            intkey       = ls_key
          IMPORTING
            impkeys      = lt_impl
          EXCEPTIONS
            not_existing = 1
            OTHERS       = 2.

        LOOP AT lt_impl REFERENCE INTO DATA(lr_impl).
          INSERT CONV #( lr_impl->clsname ) INTO TABLE result.
        ENDLOOP.

    ENDTRY.

  ENDMETHOD.


  METHOD rtti_get_classname_by_ref.

    DATA(lv_classname) = cl_abap_classdescr=>get_class_name( in ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.


  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.


  METHOD rtti_get_type_name.

    DATA(lo_descr) = cl_abap_elemdescr=>describe_by_data( val ).
    DATA(lo_ele) = CAST cl_abap_elemdescr( lo_descr ).
    result  = lo_ele->get_relative_name( ).

  ENDMETHOD.


  METHOD rtti_get_t_attri_by_object.

    DATA(lo_obj_ref) = cl_abap_objectdescr=>describe_by_object_ref( val ).
    result   = CAST cl_abap_classdescr( lo_obj_ref )->attributes.

  ENDMETHOD.


  METHOD rtti_get_t_comp_by_data.

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( val ).
    TRY.
        DATA(lo_tab) = CAST cl_abap_tabledescr( lo_type ).
        DATA(lo_struct) = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).
      CATCH cx_root.
        lo_struct = CAST cl_abap_structdescr( lo_type ).
    ENDTRY.

    result = lo_struct->get_components( ).

  ENDMETHOD.


  METHOD rtti_xml_get_by_data.

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

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.


  METHOD rtti_xml_set_to_data.

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

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING
            val = lv_text.

    ENDTRY.

  ENDMETHOD.


  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD time_substract_seconds.
    result = cl_abap_tstmp=>subtractsecs( tstmp = time secs  = seconds ).
  ENDMETHOD.


  METHOD trans_json_2_any.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( val )
            assoc_arrays = abap_true
        CHANGING
            data = data ).

  ENDMETHOD.


  METHOD trans_json_any_2.

    DATA lo_json TYPE REF TO z2ui5_cl_util_ui2_json.

    CREATE OBJECT lo_json
      EXPORTING
        compress    = compress
        pretty_name = pretty_name.
*      name_mappings     = name_mappings
*      assoc_arrays      = assoc_arrays
*      assoc_arrays_opt  = assoc_arrays_opt
*      expand_includes   = expand_includes
*      numc_as_string   = numc_as_string
*      conversion_exits  = conversion_exits
*      ts_as_iso8601    = ts_as_iso8601.

    result = lo_json->serialize_int( data = any ).

*    result = z2ui5_cl_util_ui2_json=>serialize(
*        data = any
*        pretty_name = CONV #( pretty_name )
*        compress = compress ).

*    result = /ui2/cl_json=>serialize(
*        data = any
*        pretty_name = CONV #( pretty_name )
*        compress = compress ).

  ENDMETHOD.


  METHOD trans_ref_struc_2_struc.

    FIELD-SYMBOLS <ls_from> TYPE any.

    ASSIGN ir_struc_from->* TO <ls_from>.
    x_check_raise( xsdbool( sy-subrc <> 0 ) ).
    CLEAR r_result.

    DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( r_result ) ).
    DATA(lt_components) = lo_struc->get_components( ).
    LOOP AT lt_components INTO DATA(ls_comp).

      DATA(lv_from) = ls_comp-name.
      IF pretty_name = abap_true.
        REPLACE ALL OCCURRENCES OF `_` IN lv_from WITH ``.
      ENDIF.
      ASSIGN COMPONENT lv_from OF STRUCTURE <ls_from> TO FIELD-SYMBOL(<comp_from>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE r_result TO FIELD-SYMBOL(<comp_to>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      FIELD-SYMBOLS <comp_from_deref> TYPE any.
      ASSIGN <comp_from>->* TO <comp_from_deref>.
      DATA(lv_type_kind) = rtti_get_type_kind( <comp_to> ).

      IF <comp_from_deref> IS INITIAL.
        CONTINUE.
      ENDIF.

      CASE lv_type_kind.

        WHEN cl_abap_typedescr=>typekind_table.
          trans_ref_tab_2_tab(
         EXPORTING
             ir_tab_from = <comp_from>
             pretty_name = pretty_name
         IMPORTING
             t_result    = <comp_to> ).

        WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2.
          trans_ref_struc_2_struc(
            EXPORTING
                ir_struc_from = <comp_from>
                pretty_name   = pretty_name
            IMPORTING
                r_result    = <comp_to> ).

        WHEN OTHERS.
          <comp_to> = <comp_from_deref>.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD trans_ref_tab_2_tab.

    TYPES ty_t_ref TYPE STANDARD TABLE OF REF TO data.
    FIELD-SYMBOLS <lt_from> TYPE ty_t_ref.

    ASSIGN ir_tab_from->* TO <lt_from>.
    x_check_raise( xsdbool( sy-subrc <> 0 ) ).
    CLEAR t_result.

    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( t_result ) ).
    IF lo_tab->absolute_name = `\TYPE=STRING_TABLE`.
      LOOP AT <lt_from> INTO DATA(lr_string).
        ASSIGN lr_string->* TO FIELD-SYMBOL(<row_string>).
        INSERT <row_string> INTO TABLE t_result.
      ENDLOOP.
      RETURN.
    ENDIF.
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
      x_check_raise( when = xsdbool( sy-subrc <> 0 ) ).

      DATA(lt_components_dissolved) = lt_components.
      CLEAR lt_components_dissolved.

      LOOP AT lt_components INTO DATA(ls_comp).

        IF ls_comp-as_include = abap_false.
          APPEND ls_comp TO lt_components_dissolved.
        ELSE.
          DATA(struct) = CAST cl_abap_structdescr( ls_comp-type ).
          APPEND LINES OF struct->get_components( ) TO lt_components_dissolved.

        ENDIF.
      ENDLOOP.

      LOOP AT lt_components_dissolved INTO ls_comp.
        TRY.

            FIELD-SYMBOLS <comp> TYPE data.
            ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row> TO <comp>.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            FIELD-SYMBOLS <comp_ui5> TYPE data.
            IF pretty_name = abap_true.
              REPLACE ALL OCCURRENCES OF `_` IN ls_comp-name  WITH ``.
            ENDIF.
            ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row_ui5> TO <comp_ui5>.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            ASSIGN <comp_ui5>->* TO FIELD-SYMBOL(<ls_data_ui5>).

            IF sy-subrc = 0.
              CASE ls_comp-type->kind.
                WHEN cl_abap_typedescr=>kind_table.
                  trans_ref_tab_2_tab(
                    EXPORTING
                        ir_tab_from = <comp_ui5>
                        pretty_name = pretty_name
                    IMPORTING
                        t_result    = <comp> ).
                WHEN cl_abap_typedescr=>kind_struct.
                  trans_ref_struc_2_struc(
                    EXPORTING
                        ir_struc_from = <comp_ui5>
                        pretty_name = pretty_name
                    IMPORTING
                        r_result    = <comp> ).
                WHEN OTHERS.
                  <comp> = <ls_data_ui5>.
              ENDCASE.
            ENDIF.

          CATCH cx_root.
        ENDTRY.
      ENDLOOP.

      INSERT <row> INTO TABLE t_result.
    ENDLOOP.

  ENDMETHOD.


  METHOD trans_xml_2_any.

    CALL TRANSFORMATION id
        SOURCE XML xml
        RESULT data = any.

  ENDMETHOD.


  METHOD trans_xml_any_2.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.


  METHOD url_param_create_url.

    LOOP AT t_params INTO DATA(ls_param).
      result = result && ls_param-n && `=` && ls_param-v && `&`.
    ENDLOOP.
    result = shift_right( val = result  sub = `&` ).

  ENDMETHOD.


  METHOD url_param_get.

    DATA(lt_params) = url_param_get_tab( url ).
    DATA(lv_val) = c_trim_lower( val ).
    result = VALUE #( lt_params[ n = lv_val ]-v OPTIONAL ).

  ENDMETHOD.


  METHOD url_param_get_tab.

    DATA(lv_search) = replace( val  = i_val sub  = `%3D` with = '=' occ  = 0 ).
    lv_search = shift_left( val = lv_search sub = `?` ).
    lv_search = c_trim_lower( lv_search ).

    DATA(lv_search2) = substring_after( val = lv_search
                                        sub = `&sap-startup-params=` ).
    lv_search = COND #( WHEN lv_search2 IS NOT INITIAL THEN lv_search2 ELSE lv_search ).

    lv_search2 = substring_after( val = c_trim_lower( lv_search ) sub = `?` ).
    IF lv_search2 IS NOT INITIAL.
      lv_search = lv_search2.
    ENDIF.

    SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).

    LOOP AT lt_param REFERENCE INTO DATA(lr_param).
      SPLIT lr_param->* AT `=` INTO DATA(lv_name) DATA(lv_value).
      INSERT VALUE #( n = c_trim_lower( lv_name ) v = c_trim_lower( lv_value ) ) INTO TABLE rt_params.
    ENDLOOP.

  ENDMETHOD.


  METHOD url_param_set.

    DATA(lt_params) = url_param_get_tab( url ).
    DATA(lv_n) = c_trim_lower( name ).

    LOOP AT lt_params REFERENCE INTO DATA(lr_params)
        WHERE n = lv_n.
      lr_params->v = c_trim_lower( value ).
    ENDLOOP.
    IF sy-subrc <> 0.
      INSERT VALUE #( n = lv_n v = c_trim_lower( value ) ) INTO TABLE lt_params.
    ENDIF.

    result = url_param_create_url( lt_params ).

  ENDMETHOD.


  METHOD x_check_raise.

    IF when = abap_true.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.
    ENDIF.

  ENDMETHOD.


  METHOD x_raise.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error EXPORTING val = v.

  ENDMETHOD.

  METHOD boolean_check_by_name.

    CASE val.
      WHEN 'ABAP_BOOL'
      OR 'XSDBOOLEAN'
      OR 'FLAG'
      OR 'XFELD'
      OR 'ABAP_BOOLEAN'
      OR 'WDY_BOOLEAN'
      OR 'OS_BOOLEAN'.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
