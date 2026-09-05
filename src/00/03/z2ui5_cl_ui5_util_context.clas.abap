CLASS z2ui5_cl_ui5_util_context DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " abap-toolkit - Utility Functions for ABAP Cloud & Standard ABAP
    " version: `0.0.1`.
    " origin: https://github.com/oblomov-dev/abap-toolkit
    " author: https://github.com/oblomov-dev
    " license: MIT.
    "
    " Vendored copy of zabaputil_cl_util_context (abap-util), trimmed to the
    " methods this repository uses. Editing it here is the normal way to work:
    " add or change methods directly, the master catalog harvests them back.
    "
    " The trim is NOT driven by the core engine alone. The symbols marked
    " `FROZEN-ONLY` below have no caller in src/00 - src/02; they survive
    " purely because the frozen src/99 package (z2ui5_cl_xml_view, the retired
    " z2ui5_cl_util* classes, the built-in popups) still calls them. They are
    " not dead code and must not be trimmed away while src/99 ships, but they
    " are also not part of the framework's own utility surface: when src/99 is
    " finally removed, every FROZEN-ONLY symbol goes with it. Do not build new
    " callers on them.
    CONSTANTS:
      BEGIN OF cs_ui5_msg_type,
        e TYPE string VALUE `Error` ##NO_TEXT,
        s TYPE string VALUE `Success` ##NO_TEXT,
        w TYPE string VALUE `Warning` ##NO_TEXT,
        i TYPE string VALUE `Information` ##NO_TEXT,
      END OF cs_ui5_msg_type.

    " Environment-abstracted character/format constants. Callers must read
    " these from z2ui5_cl_ui5_util_context instead of referencing cl_abap_char_utilities /
    " cl_abap_format directly, so the dependency on those SAP standard classes
    " lives in exactly one place (this class' class_constructor) and can be
    " ported once for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-DATA cv_char_util_newline        TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_char_util_cr_lf          TYPE c LENGTH 2 READ-ONLY.

    CLASS-DATA cv_char_util_horizontal_tab TYPE c LENGTH 1 READ-ONLY.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-DATA cv_format_e_xml_attr        TYPE i          READ-ONLY.

    " RTTI type-kind / kind / visibility constants, so callers can branch on
    " stored type_kind/kind fields without referencing cl_abap_typedescr /
    " cl_abap_objectdescr directly.
    CLASS-DATA cv_typedescr_typekind_table   TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_dref    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_oref    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_struct1 TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_struct2 TYPE c LENGTH 1 READ-ONLY.

    " the three elementary kinds whose JSON form is not their ABAP form (ISO
    " date/time strings, ISO timestamps) - what a delta cell must convert
    " before assigning (see z2ui5_cl_ui5_srv_model=>delta_apply_scalar)
    CLASS-DATA cv_typedescr_typekind_date    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_time    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_packed  TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_struct      TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_elem        TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_ref         TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_objectdescr_public         TYPE c LENGTH 1 READ-ONLY.

    CLASS-METHODS class_constructor.

    " Wraps the ABAP `ROLLBACK WORK` statement so the dependency on the
    " database transaction control lives in one place and can be ported once
    " for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-METHODS db_rollback.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.

    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.

    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.

    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.

    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH DEFAULT KEY ##NEEDED.

    TYPES:
      BEGIN OF ty_s_msg,
        text       TYPE string,
        id         TYPE string,
        no         TYPE string,
        type       TYPE string,
        v1         TYPE string,
        v2         TYPE string,
        v3         TYPE string,
        v4         TYPE string,
        timestampl TYPE timestampl,
        t_meta     TYPE ty_t_name_value,
      END OF ty_s_msg,
      ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_msg_box,
        text    TYPE string,
        type    TYPE string,
        title   TYPE string,
        details TYPE string,
        skip    TYPE abap_bool,
      END OF ty_s_msg_box.

    CLASS-METHODS ui5_get_msg_type
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS ui5_msg_box_format
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_s_msg_box.

    "! Everything a message box can be built from that is NOT a message.
    "! ui5_msg_box_format( ) is asked first and answers `skip` when nothing
    "! it was handed is a message - this is what runs then, so that a box
    "! the app asked for always has something to show: a character value
    "! (its own text, markup moved into the details), a number, a table, a
    "! nested structure or tree, an object, a data reference. `text` gets a
    "! one-line headline, `details` the data itself rendered as HTML.
    "! Complex data that is initial answers `skip` - a call over an empty
    "! table stays as silent as it is over an empty message table.
    CLASS-METHODS ui5_data_box_format
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_s_msg_box.

    CLASS-METHODS rtti_check_serializable
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_t
      IMPORTING
        !val          TYPE any
        !val2         TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_get_data_element_text_l
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

    " Extracts the DDIC data element name (`\TYPE=...` part of the absolute
    " name) from a component's elementary type, so callers do not reference
    " cl_abap_elemdescr directly.
    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_get_ddic_type_name
      IMPORTING
        type          TYPE REF TO cl_abap_datadescr
      RETURNING
        VALUE(result) TYPE string.

    " Thin wrappers around cl_abap_typedescr=>describe_by_data(_ref), so the
    " RTTI describe calls live in one place. Return cl_abap_typedescr, which
    " already carries type_kind / kind / absolute_name.
    CLASS-METHODS rtti_get_typedescr_by_data_ref
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_typedescr.

    "! Is the data object behind the reference a STANDARD table - false for
    "! a sorted or hashed table, for anything that is no table, and for a
    "! reference RTTI cannot describe
    CLASS-METHODS rtti_check_table_standard
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_typedescr_by_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_typedescr.

    TYPES:
      BEGIN OF ty_s_sel_tab_type,
        tabledescr       TYPE REF TO cl_abap_tabledescr,
        check_table_line TYPE abap_bool,
      END OF ty_s_sel_tab_type.

    " Builds a working table type from the line type of the source table. If
    " the source line is elementary it is wrapped into a `TAB_LINE` component
    " (check_table_line reports whether that happened). By default no extra
    " column is added; when add_sel_field = abap_true an additional boolean
    " flag column named sel_field_name (default `ZZSELKZ`) is inserted.
    " Keeps the dynamic RTTI type construction (describe_by_data / create) in
    " one place so it can be ported once for non-ABAP runtimes.
    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    " `ir_tab` keeps its Hungarian name against the `val` convention used by
    " the rest of this class: z2ui5_cl_pop_to_select (src/99/02) passes it as
    " a NAMED argument, and src/99 is frozen, so renaming the parameter would
    " break a package this repository is not allowed to edit. Rename it only
    " together with the removal of src/99.
    CLASS-METHODS rtti_create_sel_tab_type
      IMPORTING
        ir_tab         TYPE REF TO data
        add_sel_field  TYPE abap_bool DEFAULT abap_false
        sel_field_name TYPE clike     DEFAULT `ZZSELKZ`
      RETURNING
        VALUE(result)  TYPE ty_s_sel_tab_type.

    " depth guards the mutual recursion between these two (an include whose
    " expansion reaches itself would otherwise be an unbounded stack) - same
    " idea as cv_chain_max in z2ui5_cx_ui5_util_error
    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS expand_components
      IMPORTING
        val           TYPE abap_component_tab
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS check_bound_a_not_initial
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS check_unassign_initial
      IMPORTING
        val           TYPE REF TO data
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS unassign_object
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS unassign_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS conv_get_as_data_ref
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS url_param_get
      IMPORTING
        val           TYPE string
        url           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_create_url
      IMPORTING
        t_params      TYPE ty_t_name_value
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_parse
      IMPORTING
        !xml TYPE clike
      EXPORTING
        !any TYPE any.

    CLASS-METHODS xml_stringify
      IMPORTING
        !any          TYPE any
      RETURNING
        VALUE(result) TYPE string
      RAISING
        cx_xslt_serialization_error.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS boolean_check_by_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS boolean_abap_2_json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_trim_upper
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_stringify
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS xml_srtti_parse
      IMPORTING
        rtti_data     TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    "! The S-RTTI descriptor graph and the data of a dynamically typed object
    "! as TWO asXML documents. xml_srtti_stringify writes both into ONE, and
    "! the way back then has to lex the whole document twice - once for the
    "! type (skipping every byte of the data), once for the data. Written per
    "! generic reference on every draft save and read back on every draft
    "! load, so a multi-MB table behind a REF TO data paid a redundant full
    "! lex per roundtrip in a stateless session. Same content, split.
    CLASS-METHODS xml_srtti_stringify_pair
      IMPORTING
        !data   TYPE any
      EXPORTING
        ev_type TYPE string
        ev_data TYPE string.

    "! The way back for xml_srtti_stringify_pair: one parse per document
    CLASS-METHODS xml_srtti_parse_pair
      IMPORTING
        iv_type       TYPE clike
        iv_data       TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    "! the S-RTTI descriptor object of a data object - the shipped mirror, or
    "! the system's own S-RTTI where it is installed
    CLASS-METHODS xml_srtti_descr
      IMPORTING
        !data         TYPE any
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS time_get_timestampl
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS time_subtract_seconds
      IMPORTING
        !time         TYPE timestampl
        !seconds      TYPE i
      RETURNING
        VALUE(result) TYPE timestampl.

    CLASS-METHODS c_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_trim_lower
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    "! Escape what would otherwise be read as markup. Vendored from
    "! abap-util's `c_escape_html`, name and body: this class used to carry a
    "! private `html_escape` that did the same for `&`, `<` and `>` only,
    "! which is a re-implementation of something the catalog already had -
    "! and the next sync would have reported it as a second name for one
    "! method rather than as a missing one.
    CLASS-METHODS c_escape_html
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS url_param_get_tab
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS rtti_get_t_attri_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_check_class_exists
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_ref_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS boolean_check_by_name
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS filter_get_token_t_by_range_t
      IMPORTING
        val           TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_token ##NEEDED.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS filter_get_token_range_mapping
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS itab_corresponding
      IMPORTING
        val  TYPE STANDARD TABLE
      CHANGING
        !tab TYPE STANDARD TABLE.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS itab_filter_by_val
      IMPORTING
        val         TYPE clike
        fields      TYPE string_table OPTIONAL
        ignore_case TYPE abap_bool DEFAULT abap_false
      CHANGING
        !tab        TYPE STANDARD TABLE.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS itab_get_by_struc
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS conv_copy_ref_data
      IMPORTING
        !from         TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS conv_get_xstring_by_data_uri
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE xstring.

    CLASS-METHODS rtti_check_clike
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_check_table
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_check_structure
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

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

    CLASS-METHODS check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_data_element_text.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS conv_decode_x_base64
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS conv_encode_x_base64
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    " the view builder's xml_escape builds its control-character set with it
    CLASS-METHODS conv_get_string_by_xstring
      IMPORTING
        val           TYPE xstring
      RETURNING
        VALUE(result) TYPE string.

    " back in the utility surface since 2026-09 - it used to carry the
    " frozen-only marker (no framework caller, kept for src/99), but the
    " GET-shell ETag hashes the page body's UTF-8 bytes, so the framework
    " itself calls this again: see z2ui5_cl_ui5_http_handler=>_get_body_etag
    CLASS-METHODS conv_get_xstring_by_string
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE xstring.

    " read_description defaults to off: filling it costs one repository
    " read PER implementing class (SEO_CLASS_READ / XCO) and the one
    " framework caller - user-exit discovery, once per HTTP request - only
    " ever reads the classname
    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    " abap_true for values that can be rendered into a text without a
    " conversion dump - the elementary types. Anything structured (struct,
    " table, reference) must be excluded before a generic `|{ val }|`.
    CLASS-METHODS rtti_check_printable
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " The source-code position an exception was raised at, as
    " `<program> / <include> / line <n>`; empty when the runtime supplies
    " none. Wraps cx_root->get_source_position so the dependency on the SAP
    " standard exception API stays inside this class. This is what identifies
    " the failing method for exceptions that carry no text of their own -
    " a CX_SY_MOVE_CAST_ERROR only says which types did not match, the
    " position says where.
    CLASS-METHODS error_get_source_position
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    " Every public, non-static, non-constant attribute of an exception that
    " has a printable value - the class-specific payload the text alone does
    " not carry (source/target type of a cast error, the offending value of a
    " conversion error, DB object of an SQL error, ...). The general cx_root
    " attributes (PREVIOUS, TEXTID, IS_RESUMABLE, KERNEL_ERRID) are skipped -
    " the caller renders them itself or they carry no information.
    CLASS-METHODS error_get_attributes
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        classname     TYPE clike
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_s_bool_cache,
        typedescr TYPE REF TO cl_abap_typedescr,
        is_bool   TYPE abap_bool,
      END OF ty_s_bool_cache.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-DATA mt_bool_cache TYPE HASHED TABLE OF ty_s_bool_cache WITH UNIQUE KEY typedescr.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    " answers of rtti_check_class_exists, per roll area - the repository
    " lookup behind it is not free and the same names are asked again on
    " every render (the start page alone asks up to seven per roundtrip).
    " A class created at runtime after a negative answer is the one caller
    " this cache can mislead, within one roll area only - same trade as
    " gv_check_cloud below
    TYPES:
      BEGIN OF ty_s_class_exists,
        name   TYPE string,
        exists TYPE abap_bool,
      END OF ty_s_class_exists.
    CLASS-DATA gt_class_exists TYPE HASHED TABLE OF ty_s_class_exists WITH UNIQUE KEY name.

    CLASS-DATA gv_check_cloud TYPE abap_bool.

    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

    " Guards the cycle z2ui5_cx_ui5_util_error=>constructor -> uuid_get_c32 ->
    " RAISE z2ui5_cx_ui5_util_error -> ... see uuid_get_c32.

    CLASS-METHODS rtti_get_classes_intf_cloud
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    CLASS-METHODS rtti_get_classes_intf_std
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_get_dtel_texts_by_ddic
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.

    " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
    CLASS-METHODS rtti_get_dtel_texts_by_xco
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.


    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        msg           TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS msg_get_internal
      IMPORTING
        val           TYPE any
        " the RAP-shape check of a structure is a property of its TYPE - a
        " table decides it once for its rows (msg_get_internal_tab) and hands
        " the answer down, instead of asking for every row
        iv_check_rap  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    "! the rows of a table, the RAP shape decided on the first structured row
    CLASS-METHODS msg_get_internal_tab
      IMPORTING
        it_tab        TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    "! the public attributes of an object that carry a message part (TEXT,
    "! TYPE, MSGV1 ...), mapped over is_msg - see msg_map
    CLASS-METHODS msg_get_by_oref_attri
      IMPORTING
        io_obj        TYPE REF TO object
        is_msg        TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    CLASS-METHODS check_is_rap_struct
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_rap
      IMPORTING
        val           TYPE any
        entity_name   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_rap_row
      IMPORTING
        val         TYPE any
        entity_name TYPE string OPTIONAL
      EXPORTING
        messages    TYPE ty_t_msg
        is_row      TYPE abap_bool.

    CLASS-METHODS msg_get_rap_element
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_comp_str
      IMPORTING
        val           TYPE any
        comp          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS scan_flag_prefix
      IMPORTING
        val           TYPE any
        prefix        TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS msg_get_rap_state_area
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_action
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_pid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_cid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_tky
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_flatten
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_meta
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    " What a rendered box stays inside. A data dump is a diagnostic, not a
    " report: a MessageBox that carries 10.000 rows or follows a reference
    " graph until it runs out of stack helps nobody, and the roundtrip pays
    " for every character of it. Both limits are announced in the output
    " rather than applied silently.
    CONSTANTS cv_data_max_rows  TYPE i VALUE 100.
    CONSTANTS cv_data_max_depth TYPE i VALUE 5.
    " the headline is one line of a MessageBox - what does not fit there is
    " in the details anyway
    CONSTANTS cv_data_max_text  TYPE i VALUE 200.

    "! Render any value into the HTML fragment the box details show. Depth
    "! is the recursion level, checked against cv_data_max_depth.
    CLASS-METHODS data_render
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_tab
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_struc
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_oref
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS data_render_dref
      IMPORTING
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    "! One named value as a list item - the shape a component of a
    "! structure and an attribute of an object both take.
    CLASS-METHODS data_render_item
      IMPORTING
        name          TYPE clike
        val           TYPE any
        depth         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    "! The one line the box shows without the details being opened.
    CLASS-METHODS data_get_headline
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    "! Any elementary value as its text, and never an exception.
    CLASS-METHODS data_get_string
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    "! The text of an exception object, empty for every other object.
    CLASS-METHODS data_get_exc_text
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS html_get_list
      IMPORTING
        items         TYPE string_table
        ordered       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string.

    "! Does this text carry HTML markup?
    CLASS-METHODS html_check
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! HTML as the plain text behind it, capped at cv_data_max_text.
    CLASS-METHODS html_get_plain
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5_util_context IMPLEMENTATION.

  METHOD class_constructor.

    cv_char_util_newline        = cl_abap_char_utilities=>newline.
    cv_char_util_cr_lf          = cl_abap_char_utilities=>cr_lf.
    cv_char_util_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.
    cv_format_e_xml_attr        = cl_abap_format=>e_xml_attr.

    cv_typedescr_typekind_table      = cl_abap_typedescr=>typekind_table.
    cv_typedescr_typekind_dref       = cl_abap_typedescr=>typekind_dref.
    cv_typedescr_typekind_oref       = cl_abap_typedescr=>typekind_oref.
    cv_typedescr_typekind_struct1    = cl_abap_typedescr=>typekind_struct1.
    cv_typedescr_typekind_struct2    = cl_abap_typedescr=>typekind_struct2.
    cv_typedescr_typekind_date       = cl_abap_typedescr=>typekind_date.
    cv_typedescr_typekind_time       = cl_abap_typedescr=>typekind_time.
    cv_typedescr_typekind_packed     = cl_abap_typedescr=>typekind_packed.
    cv_typedescr_kind_struct         = cl_abap_typedescr=>kind_struct.
    cv_typedescr_kind_elem           = cl_abap_typedescr=>kind_elem.
    cv_typedescr_kind_ref            = cl_abap_typedescr=>kind_ref.
    cv_objectdescr_public            = cl_abap_objectdescr=>public.

  ENDMETHOD.

  METHOD db_rollback.

    ROLLBACK WORK.

  ENDMETHOD.

  METHOD boolean_abap_2_json.
      DATA temp70 TYPE string.

    IF boolean_check_by_data( val ) IS NOT INITIAL.

      IF val = abap_true.
        temp70 = `true`.
      ELSE.
        temp70 = `false`.
      ENDIF.
      result = temp70.
    ELSE.
      result = val.
    ENDIF.

  ENDMETHOD.

  METHOD boolean_check_by_data.
        DATA lo_descr TYPE REF TO cl_abap_typedescr.
        DATA lr_cache TYPE REF TO z2ui5_cl_ui5_util_context=>ty_s_bool_cache.
        DATA temp71 TYPE REF TO cl_abap_elemdescr.
        DATA lo_ele LIKE temp71.
        DATA temp72 TYPE z2ui5_cl_ui5_util_context=>ty_s_bool_cache.

    TRY.

        lo_descr = cl_abap_elemdescr=>describe_by_data( val ).

        " all supported boolean types are character-like flags, this check
        " filters out every other type before the cache lookup
        IF lo_descr->type_kind <> cl_abap_typedescr=>typekind_char.
          RETURN.
        ENDIF.

        " type descriptors are singletons, so the reference identifies the
        " type without converting/hashing the absolute name on every call

        READ TABLE mt_bool_cache REFERENCE INTO lr_cache
             WITH TABLE KEY typedescr = lo_descr.
        IF sy-subrc = 0.
          result = lr_cache->is_bool.
          RETURN.
        ENDIF.


        temp71 ?= lo_descr.

        lo_ele = temp71.
        result = boolean_check_by_name( lo_ele->get_relative_name( ) ).


        CLEAR temp72.
        temp72-typedescr = lo_descr.
        temp72-is_bool = result.
        INSERT temp72 INTO TABLE mt_bool_cache.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD boolean_check_by_name.

    CASE val.
      WHEN `ABAP_BOOL`
          OR `XSDBOOLEAN`
          OR `FLAG`
          OR `XFLAG`
          OR `XFELD`
          OR `ABAP_BOOLEAN`
          OR `WDY_BOOLEAN`
          OR `BOOLE_D`
          OR `OS_BOOLEAN`.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD check_bound_a_not_initial.
    DATA temp1 TYPE xsdboolean.

    IF val IS NOT BOUND.
      result = abap_false.
      RETURN.
    ENDIF.

    temp1 = boolc( check_unassign_initial( val ) = abap_false ).
    result = temp1.

  ENDMETHOD.

  METHOD check_unassign_initial.
    FIELD-SYMBOLS <any> TYPE data.
    DATA temp2 TYPE xsdboolean.

    IF val IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.


    ASSIGN val->* TO <any>.


    temp2 = boolc( <any> IS INITIAL ).
    result = temp2.

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    FIELD-SYMBOLS <from>   TYPE data.
    FIELD-SYMBOLS <result> TYPE data.

    IF rtti_check_ref_data( from ) IS NOT INITIAL.
      ASSIGN from->* TO <from>.
      IF <from> IS NOT ASSIGNED.
        " unbound data reference - nothing to copy, return an initial reference
        RETURN.
      ENDIF.
    ELSE.
      ASSIGN from TO <from>.
    ENDIF.
    CREATE DATA result LIKE <from>.
    ASSIGN result->* TO <result>.

    <result> = <from>.

  ENDMETHOD.

  METHOD conv_get_as_data_ref.

    GET REFERENCE OF val INTO result.

  ENDMETHOD.

  METHOD conv_get_xstring_by_data_uri.

    DATA lv_metadata TYPE string ##NEEDED.
    DATA lv_base64   TYPE string.

    SPLIT val AT `,` INTO lv_metadata lv_base64.
    result = conv_decode_x_base64( lv_base64 ).

  ENDMETHOD.

  METHOD c_trim.

    DATA temp73 TYPE string.
      DATA lv_before LIKE result.
    temp73 = val.
    result = temp73.
    " spaces and tabs alternate at either end (`\t \tx`) - one pass of each
    " leaves the inner layer standing, so strip until nothing changes
    DO 10 TIMES.

      lv_before = result.
      result = shift_left( shift_right( result ) ).
      result = shift_right( val = result
                            sub = cv_char_util_horizontal_tab ).
      result = shift_left( val = result
                           sub = cv_char_util_horizontal_tab ).
      IF result = lv_before.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD c_trim_lower.

    DATA temp74 TYPE string.
    temp74 = val.
    result = to_lower( c_trim( temp74 ) ).

  ENDMETHOD.

  METHOD c_trim_upper.

    DATA temp75 TYPE string.
    temp75 = val.
    result = to_upper( c_trim( temp75 ) ).

  ENDMETHOD.

  METHOD filter_get_token_range_mapping.

    DATA temp76 TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp77 LIKE LINE OF temp76.
    CLEAR temp76.

    temp77-n = `EQ`.
    temp77-v = `={LOW}`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `LT`.
    temp77-v = `<{LOW}`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `LE`.
    temp77-v = `<={LOW}`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `GT`.
    temp77-v = `>{LOW}`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `GE`.
    temp77-v = `>={LOW}`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `CP`.
    temp77-v = `*{LOW}*`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `BT`.
    temp77-v = `{LOW}...{HIGH}`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `NB`.
    temp77-v = `!({LOW}...{HIGH})`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `NE`.
    temp77-v = `!(={LOW})`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `NP`.
    temp77-v = `!(*{LOW}*)`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `!<leer>`.
    temp77-v = `!(<leer>)`.
    INSERT temp77 INTO TABLE temp76.
    temp77-n = `<leer>`.
    temp77-v = `<leer>`.
    INSERT temp77 INTO TABLE temp76.
    result = temp76.

  ENDMETHOD.

  METHOD filter_get_token_t_by_range_t.

    DATA lt_mapping TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA temp78 TYPE ty_t_range.
    DATA lt_tab LIKE temp78.
    DATA temp79 LIKE LINE OF lt_tab.
    DATA lr_row LIKE REF TO temp79.
      DATA lv_value TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value-v.
      FIELD-SYMBOLS <temp4> LIKE LINE OF lt_mapping.
      DATA temp5 LIKE sy-tabix.
      DATA temp80 TYPE z2ui5_cl_ui5_util_context=>ty_s_token.
    lt_mapping = filter_get_token_range_mapping( ).


    CLEAR temp78.

    lt_tab = temp78.

    itab_corresponding( EXPORTING val = val
                        CHANGING  tab = lt_tab ).



    LOOP AT lt_tab REFERENCE INTO lr_row.




      temp5 = sy-tabix.
      READ TABLE lt_mapping WITH KEY n = lr_row->option ASSIGNING <temp4>.
      sy-tabix = temp5.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_value = <temp4>-v. "#EC CI_SORTSEQ
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      " an excluding row must not render like its including twin - negate the
      " token so the MultiInput shows the filter's real meaning
      IF lr_row->sign = `E`.
        lv_value = |!({ lv_value })|.
      ENDIF.


      CLEAR temp80.
      temp80-key = lv_value.
      temp80-text = lv_value.
      temp80-visible = abap_true.
      temp80-editable = abap_true.
      INSERT temp80 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_filter_by_val.
    " TRANSPILER NOTE: ABAP CS is always case-insensitive, so the two match
    " branches below differ deliberately: ignore_case = abap_true uses
    " to_upper + CS (JS: toLowerCase().includes(toLowerCase())), the default
    " uses find( ) for a genuinely case-sensitive match (JS: plain includes()).
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.

    DATA temp81 TYPE string.
    DATA lv_search LIKE temp81.
    DATA lv_field_count TYPE i.
      DATA lv_tabix LIKE sy-tabix.
      DATA lv_check_found LIKE abap_false.
      DATA lv_index TYPE i.
          DATA lv_name LIKE LINE OF fields.
          FIELD-SYMBOLS <temp6> LIKE LINE OF fields.
          DATA temp7 LIKE sy-tabix.
        DATA lv_value TYPE string.
    IF ignore_case = abap_true.
      temp81 = to_upper( val ).
    ELSE.
      temp81 = val.
    ENDIF.

    lv_search = temp81.

    lv_field_count = lines( fields ).

    LOOP AT tab ASSIGNING <row>.


      lv_tabix = sy-tabix.

      lv_check_found = abap_false.

      lv_index = 1.
      DO.
        IF fields IS INITIAL.
          ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            IF lv_index = 1.
              " elementary line type (e.g. string_table) has no components -
              " match against the whole line instead of deleting every row
              ASSIGN <row> TO <field>.
            ELSE.
              EXIT.
            ENDIF.
          ENDIF.
        ELSE.
          IF lv_index > lv_field_count.
            EXIT.
          ENDIF.



          temp7 = sy-tabix.
          READ TABLE fields INDEX lv_index ASSIGNING <temp6>.
          sy-tabix = temp7.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lv_name = <temp6>.
          ASSIGN COMPONENT lv_name OF STRUCTURE <row> TO <field>.
          IF sy-subrc <> 0.
            lv_index = lv_index + 1.
            CONTINUE.
          ENDIF.
        ENDIF.


        lv_value = |{ <field> }|.
        IF ignore_case = abap_true.
          lv_value = to_upper( lv_value ).
          IF lv_value CS lv_search.
            lv_check_found = abap_true.
            EXIT.
          ENDIF.
        ELSEIF find( val = lv_value
                     sub = lv_search ) >= 0.
          lv_check_found = abap_true.
          EXIT.
        ENDIF.

        lv_index = lv_index + 1.
      ENDDO.

      IF lv_check_found = abap_false.
        DELETE tab INDEX lv_tabix.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_check_class_exists.

    " cached per name - see gt_class_exists at the declaration
    DATA lv_name TYPE string.
    DATA lr_hit TYPE REF TO z2ui5_cl_ui5_util_context=>ty_s_class_exists.
    DATA temp82 TYPE z2ui5_cl_ui5_util_context=>ty_s_class_exists.
    lv_name = to_upper( val ).


    READ TABLE gt_class_exists REFERENCE INTO lr_hit WITH TABLE KEY name = lv_name.
    IF sy-subrc = 0.
      result = lr_hit->exists.
      RETURN.
    ENDIF.

    TRY.
        cl_abap_classdescr=>describe_by_name( EXPORTING  p_name         = val
                                              EXCEPTIONS type_not_found = 1 ).
        IF sy-subrc = 0.
          result = abap_true.
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    CLEAR temp82.
    temp82-name = lv_name.
    temp82-exists = result.
    INSERT temp82 INTO TABLE gt_class_exists.

  ENDMETHOD.

  METHOD rtti_check_ref_data.
        DATA lo_typdescr TYPE REF TO cl_abap_typedescr.
        DATA temp83 TYPE REF TO cl_abap_refdescr.
        DATA lo_referenced TYPE REF TO cl_abap_typedescr.
        DATA temp3 TYPE xsdboolean.

    TRY.
        " a kind comparison, not a CAST probe: the cast raised
        " CX_SY_MOVE_CAST_ERROR for every NON-reference value, and the
        " non-reference is the COMMON case on this path (every value routed
        " through conv_copy_ref_data asks) - deciding a type question by
        " exception is orders of magnitude more expensive than comparing.
        " cl_abap_refdescr covers data and object references alike, and so
        " does kind_ref

        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).
        IF lo_typdescr->kind <> cl_abap_typedescr=>kind_ref.
          RETURN.
        ENDIF.
        " kind_ref covers object references too, and the one caller that
        " dereferences on a true answer (conv_copy_ref_data: `from->*`)
        " cannot do that to an object reference - nav_app_leave( r_data =
        " lo_object ) reached it. Only a reference to DATA answers true

        temp83 ?= lo_typdescr.

        lo_referenced = temp83->get_referenced_type( ).

        temp3 = boolc( lo_referenced->kind <> cl_abap_typedescr=>kind_class AND lo_referenced->kind <> cl_abap_typedescr=>kind_intf ).
        result = temp3.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_classname_by_ref.
    DATA lv_classname TYPE abap_abstypename.

    " an unbound reference has no class - answer with an empty name instead
    " of letting the RTTI call fail. Callers ask this while rendering (error
    " context, response header), where a half-built object graph is normal
    IF val IS NOT BOUND.
      RETURN.
    ENDIF.


    lv_classname = cl_abap_classdescr=>get_class_name( val ).
    result = substring_after( val = lv_classname
                              sub = `\CLASS=` ).

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.

    DATA type_desc TYPE REF TO cl_abap_typedescr.
    DATA temp84 TYPE REF TO cl_abap_structdescr.
    DATA sdescr LIKE temp84.
    DATA comps TYPE abap_component_tab.
    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = type->absolute_name
                                         RECEIVING p_descr_ref     = type_desc
                                         EXCEPTIONS type_not_found = 1 ).
    " classic exception method: a missing type sets sy-subrc and leaves the
    " ref unbound instead of raising - check it, or get_components below
    " dumps with CX_SY_REF_IS_INITIAL
    IF sy-subrc <> 0 OR type_desc IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = |Include type '{ type->absolute_name }' not found|.
    ENDIF.

    temp84 ?= type_desc.

    sdescr = temp84.

    comps = sdescr->get_components( ).
    result = expand_components( val   = comps
                                depth = depth ).

  ENDMETHOD.

  METHOD expand_components.
    DATA temp85 LIKE LINE OF val.
    DATA lr_comp LIKE REF TO temp85.
        DATA lt_incl TYPE abap_component_tab.

    " see the declaration: bounded so a cyclic include chain surfaces as a
    " readable error instead of a stack-overflow dump. 16 nested include
    " levels is far beyond any real DDIC structure
    IF depth > 16.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
        EXPORTING
          val = `RTTI_INCLUDE_RECURSION - include expansion exceeded 16 levels (cyclic include?)`.
    ENDIF.



    LOOP AT val REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.

        lt_incl = rtti_get_t_attri_by_include( type  = lr_comp->type
                                                     depth = depth + 1 ).
        APPEND LINES OF lt_incl TO result.
      ELSE.
        APPEND lr_comp->* TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_oref.

    DATA lo_obj_ref TYPE REF TO cl_abap_typedescr.
    DATA temp86 TYPE REF TO cl_abap_classdescr.
    lo_obj_ref = cl_abap_objectdescr=>describe_by_object_ref( val ).

    temp86 ?= lo_obj_ref.
    result = temp86->attributes.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct        TYPE REF TO cl_abap_structdescr.
    DATA lo_type          TYPE REF TO cl_abap_typedescr.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_absolute_name TYPE string.
        DATA temp87 TYPE REF TO cl_abap_structdescr.
        DATA temp88 TYPE REF TO cl_abap_structdescr.
        DATA temp8 TYPE REF TO cl_abap_tabledescr.
    DATA lr_cache TYPE REF TO z2ui5_cl_ui5_util_context=>ty_s_attri_cache.
    DATA comps TYPE abap_component_tab.
      DATA temp89 TYPE z2ui5_cl_ui5_util_context=>ty_s_attri_cache.

    " describe_by_data never fails for a data object, and the reference case
    " is the one branch. The fallback chain that used to sit here - a second
    " describe_by_data_ref, then describe_by_name( val ) - could rescue no
    " input: the first only re-raised what the branch above had raised, and
    " a data object is no type name
    lo_type = cl_abap_typedescr=>describe_by_data( val ).
    IF lo_type->kind = cl_abap_typedescr=>kind_ref.
      lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
    ENDIF.

    CASE lo_type->kind.
      WHEN cl_abap_typedescr=>kind_struct.

        temp87 ?= lo_type.
        lo_struct = temp87.
      WHEN cl_abap_typedescr=>kind_table.


        temp8 ?= lo_type.
        temp88 ?= temp8->get_table_line_type( ).
        lo_struct = temp88.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types
    lv_absolute_name = lo_struct->absolute_name.

    READ TABLE mt_attri_cache REFERENCE INTO lr_cache
         WITH TABLE KEY absolute_name = lv_absolute_name.
    IF sy-subrc = 0 AND lr_cache->o_struct = lo_struct.
      result = lr_cache->t_attri.
      RETURN.
    ENDIF.


    comps = lo_struct->get_components( ).
    result = expand_components( comps ).

    IF lr_cache IS BOUND.
      lr_cache->o_struct = lo_struct.
      lr_cache->t_attri  = result.
    ELSE.

      CLEAR temp89.
      temp89-absolute_name = lv_absolute_name.
      temp89-o_struct = lo_struct.
      temp89-t_attri = result.
      INSERT temp89 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD time_get_timestampl.
    GET TIME STAMP FIELD result.
  ENDMETHOD.

  METHOD time_subtract_seconds.

    result = cl_abap_tstmp=>subtractsecs( tstmp = time
                                          secs  = seconds ).

  ENDMETHOD.

  METHOD unassign_data.

    FIELD-SYMBOLS <unassign> TYPE any.

    " IS ASSIGNED, not sy-subrc: on some releases (7.40 SP7, #1937) a
    " successful ASSIGN does not reset sy-subrc, so a stale 4 from an
    " earlier statement read as "not assigned" and vice versa. The symbol
    " is declared fresh in this method and assigned exactly once, so no
    " UNASSIGN is needed before the test
    ASSIGN val->* TO <unassign>.
    IF <unassign> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    result = <unassign>.

  ENDMETHOD.

  METHOD unassign_object.

    FIELD-SYMBOLS <unassign> TYPE any.

    " same reasoning as unassign_data directly above
    ASSIGN val->* TO <unassign>.
    IF <unassign> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    result = <unassign>.

  ENDMETHOD.

  METHOD url_param_create_url.

    DATA ls_param LIKE LINE OF t_params.
    LOOP AT t_params INTO ls_param.
      result = |{ result }{ ls_param-n }={ ls_param-v }&|.
    ENDLOOP.
    result = shift_right( val = result
                          sub = `&` ).

  ENDMETHOD.

  METHOD url_param_get.

    DATA lt_params TYPE z2ui5_cl_ui5_util_context=>ty_t_name_value.
    DATA lv_val TYPE string.
    DATA temp90 TYPE string.
    DATA temp91 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    lt_params = url_param_get_tab( url ).

    lv_val = c_trim_lower( val ).

    CLEAR temp90.

    READ TABLE lt_params INTO temp91 WITH KEY n = lv_val.
    IF sy-subrc = 0.
      temp90 = temp91-v.
    ENDIF.
    result = temp90. "#EC CI_SORTSEQ

  ENDMETHOD.

  METHOD url_param_get_tab.

    " a full URL or a request URI carries a path before its query: cut at
    " the FIRST `?` only. A later `?` is a legal, unencoded character of a
    " value (`title=why?`) - cutting there dropped every parameter before
    " it, app_start included, and the shell fell back to the start page
    " declared, not inline: DATA( ) from a generic CLIKE parameter is
    " "fixed type STRING used for generic type CLIKE" in the extended check
    DATA lv_search TYPE string.
    DATA lv_startup TYPE string.
      DATA lv_packed TYPE string.
      DATA lv_rest TYPE string.
    TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA lt_param TYPE temp1.
    DATA temp92 LIKE LINE OF lt_param.
    DATA lr_param LIKE REF TO temp92.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      DATA temp93 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    lv_search = val.
    IF lv_search CS `?`.
      lv_search = substring_after( val = lv_search
                                   sub = `?` ).
    ENDIF.

    " The FLP packs the target's own parameters into ONE value,
    " sap-startup-params, with its `=` and `&` percent-encoded. Prepend &
    " before searching so it is also unwrapped when it is the first/only
    " query parameter (typical FLP target mapping). Only THAT value is
    " decoded: decoding the whole query first tore every legitimately
    " encoded `&` or `=` in any other value apart (`a=x%26y` became the
    " two parameters a=x and y=), and app_get_url wrote the damage back
    " into every generated link

    lv_startup = substring_after( val = |&{ lv_search }|
                                        sub = `&sap-startup-params=` ).
    IF lv_startup IS NOT INITIAL.


      SPLIT lv_startup AT `&` INTO lv_packed lv_rest.
      lv_packed = replace( val  = lv_packed
                           sub  = `%3D`
                           with = `=`
                           occ  = 0 ).
      " RFC 3986 allows lowercase hex digits in percent-encodings, so decode
      " %3d the same way as %3D (%26 contains no letters and needs no twin)
      lv_packed = replace( val  = lv_packed
                           sub  = `%3d`
                           with = `=`
                           occ  = 0 ).
      lv_packed = replace( val  = lv_packed
                           sub  = `%26`
                           with = `&`
                           occ  = 0 ).
      lv_search = lv_packed.
      IF lv_rest IS NOT INITIAL.
        lv_search = |{ lv_packed }&{ lv_rest }|.
      ENDIF.
    ENDIF.



    SPLIT lv_search AT `&` INTO TABLE lt_param.



    LOOP AT lt_param REFERENCE INTO lr_param.


      SPLIT lr_param->* AT `=` INTO lv_name lv_value.
      " an empty segment (empty search string, trailing &) would otherwise
      " produce a phantom nameless parameter that url_param_create_url
      " writes back out as a stray `=&`
      IF lv_name IS INITIAL.
        CONTINUE.
      ENDIF.
      " normalize the name so lookups are case-insensitive on every input
      " shape (with or without a leading path/question mark) - the value
      " keeps its original case

      CLEAR temp93.
      temp93-n = c_trim_lower( lv_name ).
      temp93-v = lv_value.
      INSERT temp93 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD xml_parse.

    IF xml IS INITIAL.
      CLEAR any.
      RETURN.
    ENDIF.

    CALL TRANSFORMATION id
         SOURCE XML xml
         RESULT data = any.

  ENDMETHOD.

  METHOD xml_srtti_descr.

    DATA temp94 TYPE string.
    DATA lv_classname LIKE temp94.
    IF rtti_check_class_exists( `ZCL_SRTTI_TYPEDESCR` ) = abap_true.
      temp94 = `ZCL_SRTTI_TYPEDESCR`.
    ELSE.
      temp94 = `Z2UI5_CL_SRT_TYPEDESCR`.
    ENDIF.

    lv_classname = temp94.
    CALL METHOD (lv_classname)=>(`CREATE_BY_DATA_OBJECT`)
      EXPORTING
        data_object = data
      RECEIVING
        srtti       = result.

  ENDMETHOD.

  METHOD xml_srtti_stringify_pair.
        DATA lo_srtti TYPE REF TO object.
        DATA lx_srtti TYPE REF TO cx_root.

    TRY.

        lo_srtti = xml_srtti_descr( data ).
        CALL TRANSFORMATION id SOURCE srtti = lo_srtti RESULT XML ev_type.
        CALL TRANSFORMATION id SOURCE dobj = data RESULT XML ev_data.

      CATCH cx_root INTO lx_srtti.
        " keep the root cause - a transformation error on the app's own
        " data must not be masked behind a bare UNSUPPORTED_FEATURE
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val      = `UNSUPPORTED_FEATURE`
            previous = lx_srtti.
    ENDTRY.

  ENDMETHOD.

  METHOD xml_srtti_parse_pair.

    DATA srtti TYPE REF TO object.
    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
    FIELD-SYMBOLS <variable> TYPE data.
    CALL TRANSFORMATION id SOURCE XML iv_type RESULT srtti = srtti.


    CALL METHOD srtti->(`GET_RTTI`)
      RECEIVING
        rtti = rtti_type.


    lo_datadescr ?= rtti_type.

    CREATE DATA result TYPE HANDLE lo_datadescr.

    ASSIGN result->* TO <variable>.
    CALL TRANSFORMATION id SOURCE XML iv_data RESULT dobj = <variable>.

  ENDMETHOD.

  METHOD xml_srtti_parse.

    DATA srtti TYPE REF TO object.
    DATA rtti_type TYPE REF TO cl_abap_typedescr.
    DATA lo_datadescr TYPE REF TO cl_abap_datadescr.
    FIELD-SYMBOLS <variable> TYPE data.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT srtti = srtti.


    CALL METHOD srtti->(`GET_RTTI`)
      RECEIVING
        rtti = rtti_type.


    lo_datadescr ?= rtti_type.

    CREATE DATA result TYPE HANDLE lo_datadescr.

    ASSIGN result->* TO <variable>.
    CALL TRANSFORMATION id SOURCE XML rtti_data RESULT dobj = <variable>.

  ENDMETHOD.

  METHOD xml_srtti_stringify.
      DATA srtti TYPE REF TO object.
      DATA lv_classname TYPE string.
          DATA lx_srtti TYPE REF TO cx_root.
          DATA lv_text TYPE string.

    IF rtti_check_class_exists( `ZCL_SRTTI_TYPEDESCR` ) = abap_true.



      lv_classname = `ZCL_SRTTI_TYPEDESCR`.
      CALL METHOD (lv_classname)=>(`CREATE_BY_DATA_OBJECT`)
        EXPORTING
          data_object = data
        RECEIVING
          srtti       = srtti.
      CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.

    ELSE.

      TRY.
          CALL METHOD z2ui5_cl_srt_typedescr=>(`CREATE_BY_DATA_OBJECT`)
            EXPORTING
              data_object = data
            RECEIVING
              srtti       = srtti.
          CALL TRANSFORMATION id SOURCE srtti = srtti dobj = data RESULT XML result.


        CATCH cx_root INTO lx_srtti.

          " keep the root cause - a transformation error on the app's own
          " data must not be masked behind a bare UNSUPPORTED_FEATURE

          lv_text = `UNSUPPORTED_FEATURE`.
          RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
            EXPORTING
              val      = lv_text
              previous = lx_srtti.

      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD xml_stringify.

    CALL TRANSFORMATION id
         SOURCE data = any
         RESULT XML result
         OPTIONS data_refs = `heap-or-create`.

  ENDMETHOD.

  METHOD itab_corresponding.

    FIELD-SYMBOLS <row_in>  TYPE any.
    FIELD-SYMBOLS <row_out> TYPE any.

    LOOP AT val ASSIGNING <row_in>.
      APPEND INITIAL LINE TO tab ASSIGNING <row_out>.
      MOVE-CORRESPONDING <row_in> TO <row_out>.
    ENDLOOP.

  ENDMETHOD.

  METHOD itab_get_by_struc.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp95 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp95.
      FIELD-SYMBOLS <component> TYPE any.
          DATA temp96 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO lr_attri.


      ASSIGN COMPONENT lr_attri->name OF STRUCTURE val TO <component>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE rtti_get_type_kind( <component> ).

        " skip components that cannot be moved into the string value: tables,
        " nested structures and references would raise an unhandled move
        " error at runtime
        WHEN cl_abap_typedescr=>typekind_table OR
             cl_abap_typedescr=>typekind_struct1 OR
             cl_abap_typedescr=>typekind_struct2 OR
             cl_abap_typedescr=>typekind_dref OR
             cl_abap_typedescr=>typekind_oref.

        WHEN OTHERS.

          CLEAR temp96.
          temp96-n = lr_attri->name.
          temp96-v = <component>.
          INSERT temp96 INTO TABLE result.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_t.

    result = msg_get_internal( val ).
    IF result IS INITIAL AND val2 IS NOT INITIAL.
      result = msg_get_internal( val2 ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_clike.

    DATA lv_type TYPE string.
    lv_type = rtti_get_type_kind( val ).
    CASE lv_type.
      " typekind_clike/_csequence are generic kinds of formal parameters and
      " can never be returned for a concrete data object - list the concrete
      " character-like kinds (c, string, n, d, t) instead
      WHEN cl_abap_datadescr=>typekind_char OR
          cl_abap_datadescr=>typekind_string OR
          cl_abap_datadescr=>typekind_num OR
          cl_abap_datadescr=>typekind_date OR
          cl_abap_datadescr=>typekind_time.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_check_printable.

    IF rtti_check_clike( val ) = abap_true.
      result = abap_true.
      RETURN.
    ENDIF.

    CASE rtti_get_type_kind( val ).
      WHEN cl_abap_datadescr=>typekind_int OR
          cl_abap_datadescr=>typekind_int1 OR
          cl_abap_datadescr=>typekind_int2 OR
          cl_abap_datadescr=>typekind_packed OR
          cl_abap_datadescr=>typekind_float OR
          cl_abap_datadescr=>typekind_decfloat16 OR
          cl_abap_datadescr=>typekind_decfloat34 OR
          cl_abap_datadescr=>typekind_hex.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD error_get_source_position.

    " typed like the EXPORTING parameters of get_source_position (syrepid is
    " CHAR40) - they are passed by reference, so a string would not be
    " type-compatible here
    DATA lv_program TYPE c LENGTH 40.
    DATA lv_include TYPE c LENGTH 40.
    DATA lv_line    TYPE i.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    " open-abap - the transpiled JS runtime behind the dev server and the node
    " tests - implements get_source_position by reading a field that only the
    " RAISE statement writes, and fails with a JS TypeError for every other
    " exception (a runtime-thrown one, or one built with NEW). That error is
    " not an ABAP exception, so the TRY below cannot intercept it and the
    " renderer would take the request down instead of reporting it. sy-saprl
    " is `OPEN` on that runtime and a real release everywhere else.
    IF sy-saprl = `OPEN`.
      RETURN.
    ENDIF.

    TRY.
        val->get_source_position( IMPORTING program_name = lv_program
                                            include_name = lv_include
                                            source_line  = lv_line ).
      CATCH cx_root ##NO_HANDLER.
        " never let the diagnostic renderer be the reason a request fails
    ENDTRY.

    IF lv_program IS INITIAL AND lv_line IS INITIAL.
      RETURN.
    ENDIF.

    result = c_trim( lv_program ).
    " the include is the interesting part for a class (...CM001 = the method
    " that raised); repeating it when it equals the program adds nothing
    IF lv_include IS NOT INITIAL AND lv_include <> lv_program.
      result = |{ result } / { c_trim( lv_include ) }|.
    ENDIF.
    IF lv_line IS NOT INITIAL.
      result = |{ result } / line { lv_line }|.
    ENDIF.

  ENDMETHOD.

  METHOD error_get_attributes.

    " declared, NOT `DATA(lv_name) = CONV string( lr_attri->name )`: a CONV
    " that is the whole right-hand side of an assignment is "Redundant
    " conversion for type STRING" in SLIN - the assignment converts by
    " itself. The variable stays a string on purpose: the RTTI name is a
    " CHAR field whose trailing blanks have no business in the rendered name
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp97 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp97.
      DATA temp98 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.

        lt_attri = rtti_get_t_attri_by_oref( val ).
      CATCH cx_root.
        RETURN.
    ENDTRY.



    LOOP AT lt_attri REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE visibility  = cv_objectdescr_public
           AND is_constant = abap_false
           AND is_class    = abap_false.

      CASE lr_attri->name.
          " rendered by the caller (PREVIOUS as the next chain entry,
          " KERNEL_ERRID as its own line) or without information value
        WHEN `PREVIOUS` OR `TEXTID` OR `IS_RESUMABLE` OR `KERNEL_ERRID`.
          CONTINUE.
      ENDCASE.

      lv_name = lr_attri->name.
      ASSIGN val->(lv_name) TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF rtti_check_printable( <comp> ) = abap_false OR <comp> IS INITIAL.
        CONTINUE.
      ENDIF.


      CLEAR temp98.
      temp98-n = lv_name.
      temp98-v = c_trim( |{ <comp> }| ).
      INSERT temp98 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD ui5_get_msg_type.

    CASE val.
      WHEN `E`.
        result = cs_ui5_msg_type-e.
      WHEN `S`.
        result = cs_ui5_msg_type-s.
      WHEN `W`.
        result = cs_ui5_msg_type-w.
      WHEN OTHERS.
        result = cs_ui5_msg_type-i.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_get_data_element_text_l.

    result = rtti_get_data_element_texts( val )-long.

  ENDMETHOD.

  METHOD rtti_get_ddic_type_name.

    DATA temp99 TYPE REF TO cl_abap_elemdescr.
    temp99 ?= type.
    result = substring_after( val = temp99->absolute_name
                              sub = `\TYPE=` ).

  ENDMETHOD.

  METHOD rtti_get_typedescr_by_data_ref.

    result = cl_abap_typedescr=>describe_by_data_ref( val ).

  ENDMETHOD.

  METHOD rtti_check_table_standard.

    DATA lo_tab TYPE REF TO cl_abap_tabledescr.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp4 TYPE xsdboolean.

    TRY.

        lo_type = cl_abap_typedescr=>describe_by_data_ref( val ).
        IF lo_type->kind <> cl_abap_typedescr=>kind_table.
          RETURN.
        ENDIF.
        lo_tab ?= lo_type.

        temp4 = boolc( lo_tab->table_kind = cl_abap_tabledescr=>tablekind_std ).
        result = temp4.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_typedescr_by_data.

    result = cl_abap_typedescr=>describe_by_data( val ).

  ENDMETHOD.

  METHOD rtti_create_sel_tab_type.

    DATA lt_comp TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
    DATA temp100 TYPE REF TO cl_abap_tabledescr.
    DATA lo_table LIKE temp100.
        DATA temp101 TYPE REF TO cl_abap_structdescr.
        DATA lo_struct LIKE temp101.
        DATA temp102 TYPE REF TO cl_abap_elemdescr.
        DATA lo_elem LIKE temp102.
        DATA temp103 TYPE abap_componentdescr.
    DATA temp104 LIKE sy-subrc.
      DATA lo_type_bool TYPE REF TO cl_abap_typedescr.
      DATA temp105 TYPE abap_componentdescr.
      DATA temp9 TYPE REF TO cl_abap_datadescr.
    DATA lo_line_type TYPE REF TO cl_abap_structdescr.
    ASSIGN ir_tab->* TO <tab>.


    temp100 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

    lo_table = temp100.
    TRY.

        temp101 ?= lo_table->get_table_line_type( ).

        lo_struct = temp101.
        lt_comp = lo_struct->get_components( ).
      CATCH cx_root.
        result-check_table_line = abap_true.

        temp102 ?= lo_table->get_table_line_type( ).

        lo_elem = temp102.

        CLEAR temp103.
        temp103-name = `TAB_LINE`.
        temp103-type = lo_elem.
        INSERT temp103 INTO TABLE lt_comp.
    ENDTRY.


    READ TABLE lt_comp WITH KEY name = sel_field_name TRANSPORTING NO FIELDS.
    temp104 = sy-subrc.
    IF add_sel_field = abap_true
        AND NOT temp104 = 0. "#EC CI_SORTSEQ

      lo_type_bool = cl_abap_typedescr=>describe_by_name( `ABAP_BOOL` ).

      CLEAR temp105.
      temp105-name = sel_field_name.

      temp9 ?= lo_type_bool.
      temp105-type = temp9.
      INSERT temp105 INTO TABLE lt_comp.
    ENDIF.


    lo_line_type = cl_abap_structdescr=>create( lt_comp ).
    result-tabledescr = cl_abap_tabledescr=>create( lo_line_type ).

  ENDMETHOD.

  METHOD rtti_check_table.

    DATA lv_type_kind TYPE abap_typekind.
    DATA temp5 TYPE xsdboolean.
    lv_type_kind = cl_abap_datadescr=>get_data_type_kind( val ).

    temp5 = boolc( lv_type_kind = cl_abap_typedescr=>typekind_table ).
    result = temp5.

  ENDMETHOD.

  METHOD rtti_check_structure.
        DATA lo_type TYPE REF TO cl_abap_typedescr.
        DATA temp6 TYPE xsdboolean.

    TRY.

        lo_type = cl_abap_typedescr=>describe_by_data( val ).

        temp6 = boolc( lo_type->kind = cl_abap_typedescr=>kind_struct ).
        result = temp6.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD ui5_msg_box_format.

    DATA lt_msg TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
    DATA lv_lines TYPE i.
    DATA lv_type TYPE string.
    FIELD-SYMBOLS <temp10> LIKE LINE OF lt_msg.
    DATA temp11 LIKE sy-tabix.
      FIELD-SYMBOLS <temp106> LIKE LINE OF lt_msg.
      DATA temp107 LIKE sy-tabix.
    DATA lt_detail_items TYPE string_table.
    DATA temp108 LIKE LINE OF lt_msg.
    DATA lr_msg LIKE REF TO temp108.
      DATA temp109 LIKE LINE OF lt_detail_items.
    lt_msg = msg_get_t( val ).

    " a structure that carries none of the message components maps to an
    " entry with no text at all - that is not a message, it is data, and it
    " used to reach the box as a popup with a blank line in it. Dropping it
    " here is what lets `skip` mean "nothing in here is a message" and lets
    " the caller fall back to ui5_data_box_format( )
    DELETE lt_msg WHERE text IS INITIAL.


    lv_lines = lines( lt_msg ).

    IF lv_lines = 0.
      result-skip = abap_true.
      RETURN.
    ENDIF.

    " the box takes its type/title from the FIRST message, also when several
    " are collapsed into one box below



    temp11 = sy-tabix.
    READ TABLE lt_msg INDEX 1 ASSIGNING <temp10>.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_type = ui5_get_msg_type( <temp10>-type ).
    result-title = lv_type.
    result-type  = to_lower( lv_type ).

    IF lv_lines = 1.


      temp107 = sy-tabix.
      READ TABLE lt_msg INDEX 1 ASSIGNING <temp106>.
      sy-tabix = temp107.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result-text = <temp106>-text.
      RETURN.
    ENDIF.

    " several messages: a counting headline plus every text as a bullet
    result-text = | { lv_lines } Messages found: |.

    " the texts are data inside markup, escaped like every sibling renderer
    " escapes its values: unescaped, `Enter a value for <MATNR>` lost its
    " token to the frontend sanitizer, which drops an unknown element


    LOOP AT lt_msg REFERENCE INTO lr_msg.

      temp109 = |<li>{ c_escape_html( lr_msg->text ) }</li>|.
      INSERT temp109 INTO TABLE lt_detail_items.
    ENDLOOP.
    result-details = `<ul>` && concat_lines_of( lt_detail_items ) && `</ul>`.

  ENDMETHOD.

  METHOD ui5_data_box_format.

    " a character value is its own text, whatever is in it - an empty one
    " included, which is the shape message_box_display( lv_text ) has always
    " had and is not this method's to change
    IF rtti_check_clike( val ) = abap_true.
      IF html_check( val ) = abap_true.
        " markup in the box text would be shown as the tags it is written
        " with - sap.m.MessageBox renders the text through a sap.m.Text and
        " the DETAILS through a sap.m.FormattedText, so that is where HTML
        " belongs. The plain text behind it stays as the headline
        result-text    = html_get_plain( val ).
        result-details = val.
      ELSE.
        result-text = val.
      ENDIF.
      RETURN.
    ENDIF.

    " a number, a date, a hex value: shown the way the runtime writes it
    IF rtti_check_printable( val ) = abap_true.
      result-text = data_get_string( val ).
      RETURN.
    ENDIF.

    " complex data that is initial stays silent. An app that hands over the
    " result table of a call it just made expects no popup when the call
    " returned nothing, and that expectation predates this method
    IF val IS INITIAL.
      result-skip = abap_true.
      RETURN.
    ENDIF.

    result-text    = data_get_headline( val ).
    result-details = data_render( val   = val
                                  depth = 0 ).

    IF result-text IS INITIAL AND result-details IS INITIAL.
      result-skip = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD data_render.

    " the recursion stops here rather than in every branch below, and says
    " in the output that it did
    IF depth > cv_data_max_depth.
      result = `<em>...</em>`.
      RETURN.
    ENDIF.

    CASE rtti_get_type_kind( val ).
      WHEN cl_abap_datadescr=>typekind_table.
        result = data_render_tab( val   = val
                                  depth = depth ).
      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
        result = data_render_struc( val   = val
                                    depth = depth ).
      WHEN cl_abap_datadescr=>typekind_oref.
        result = data_render_oref( val   = val
                                   depth = depth ).
      WHEN cl_abap_datadescr=>typekind_dref.
        result = data_render_dref( val   = val
                                   depth = depth ).
      WHEN OTHERS.
        result = c_escape_html( data_get_string( val ) ).
    ENDCASE.

  ENDMETHOD.

  METHOD data_render_tab.

    DATA lt_item TYPE string_table.
    DATA lv_no   TYPE i.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <row> TYPE ANY.
        DATA temp110 LIKE LINE OF lt_item.
      DATA temp111 LIKE LINE OF lt_item.

    ASSIGN val TO <tab>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.


    LOOP AT <tab> ASSIGNING <row>.
      lv_no = lv_no + 1.
      IF lv_no > cv_data_max_rows.

        temp110 = |<li><em>... { lines( <tab> ) - cv_data_max_rows } more entries</em></li>|.
        INSERT temp110
               INTO TABLE lt_item.
        EXIT.
      ENDIF.

      temp111 = |<li>{ data_render( val = <row> depth = depth + 1 ) }</li>|.
      INSERT temp111 INTO TABLE lt_item.
    ENDLOOP.

    result = html_get_list( items   = lt_item
                            ordered = abap_true ).

  ENDMETHOD.

  METHOD data_render_struc.

    DATA lt_item TYPE string_table.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_component_tab.
    DATA temp112 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp112.

    TRY.

        lt_attri = rtti_get_t_attri_by_any( val ).
      CATCH cx_root.
        " a structure RTTI cannot describe still has a value - the caller
        " keeps the headline, the details stay empty
        RETURN.
    ENDTRY.



    LOOP AT lt_attri REFERENCE INTO lr_attri.
      lv_name = lr_attri->name.
      ASSIGN COMPONENT lv_name OF STRUCTURE val TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT data_render_item( name  = lv_name
                               val   = <comp>
                               depth = depth ) INTO TABLE lt_item.
    ENDLOOP.

    result = html_get_list( lt_item ).

  ENDMETHOD.

  METHOD data_render_oref.

    DATA lo_obj  TYPE REF TO object.
    DATA lt_item TYPE string_table.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp113 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp113.

    TRY.
        lo_obj = val.
      CATCH cx_root.
        RETURN.
    ENDTRY.
    IF lo_obj IS NOT BOUND.
      RETURN.
    ENDIF.

    " an exception carries its own text, and that text is the whole story -
    " its attributes are the placeholders that are already substituted in it
    result = data_get_exc_text( lo_obj ).
    IF result IS NOT INITIAL.
      result = c_escape_html( result ).
      RETURN.
    ENDIF.

    TRY.

        lt_attri = rtti_get_t_attri_by_oref( lo_obj ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    " the public state is what an object can show of itself; a constant is
    " the type's, not this instance's, and a class attribute is nobody's


    LOOP AT lt_attri REFERENCE INTO lr_attri                  "#EC CI_SORTSEQ
         WHERE visibility  = cv_objectdescr_public
           AND is_constant = abap_false
           AND is_class    = abap_false.
      lv_name = lr_attri->name.
      ASSIGN lo_obj->(lv_name) TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT data_render_item( name  = lv_name
                               val   = <comp>
                               depth = depth ) INTO TABLE lt_item.
    ENDLOOP.

    result = html_get_list( lt_item ).

  ENDMETHOD.

  METHOD data_render_dref.

    DATA lr_data TYPE REF TO data.

    FIELD-SYMBOLS <val> TYPE any.

    TRY.
        lr_data = val.
      CATCH cx_root.
        RETURN.
    ENDTRY.
    IF lr_data IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lr_data->* TO <val>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a reference is no level of its own for the reader, but it is one for
    " the recursion: a structure that points at itself would otherwise
    " never reach the depth limit
    result = data_render( val   = <val>
                          depth = depth + 1 ).

  ENDMETHOD.

  METHOD data_render_item.

    DATA lv_val TYPE string.
    lv_val = data_render( val   = val
                                depth = depth + 1 ).

    result = |<li><strong>{ c_escape_html( name ) }</strong>: { lv_val }</li>|.

  ENDMETHOD.

  METHOD data_get_headline.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        DATA lv_lines TYPE i.
            DATA lt_attri TYPE abap_component_tab.
        DATA lo_obj TYPE REF TO object.

    CASE rtti_get_type_kind( val ).

      WHEN cl_abap_datadescr=>typekind_table.
        ASSIGN val TO <tab>.

        lv_lines = lines( <tab> ).
        IF lv_lines = 1.
          result = `Table with 1 entry`.
        ELSE.
          result = |Table with { lv_lines } entries|.
        ENDIF.

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.
        TRY.

            lt_attri = rtti_get_t_attri_by_any( val ).
            result = |Structure with { lines( lt_attri ) } fields|.
          CATCH cx_root.
            result = `Structure`.
        ENDTRY.

      WHEN cl_abap_datadescr=>typekind_oref.

        TRY.
            lo_obj = val.
            result = |Object { rtti_get_classname_by_ref( lo_obj ) }|.
          CATCH cx_root.
            result = `Object`.
        ENDTRY.

      WHEN OTHERS.
        result = `Data`.

    ENDCASE.

  ENDMETHOD.

  METHOD data_get_string.

    " the plain assignment is what turns an elementary value into its text
    " - the same trick get_comp_str( ) uses. A value the runtime refuses to
    " convert must not be the reason a box does not appear
    TRY.
        result = val.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " a number reaches a character target right-aligned in the length its
    " type needs (` 12` for an i on some runtimes), and a CHAR field brings
    " its padding along - neither is what the value says
    result = c_trim( result ).

  ENDMETHOD.

  METHOD data_get_exc_text.
        DATA temp114 TYPE REF TO cx_root.
        DATA lx LIKE temp114.

    TRY.

        temp114 ?= val.

        lx = temp114.
        result = lx->get_text( ).
      CATCH cx_root ##NO_HANDLER.
        " not an exception, or one that cannot render itself
    ENDTRY.

  ENDMETHOD.

  METHOD html_get_list.

    IF items IS INITIAL.
      RETURN.
    ENDIF.

    IF ordered = abap_true.
      result = `<ol>` && concat_lines_of( items ) && `</ol>`.
    ELSE.
      result = `<ul>` && concat_lines_of( items ) && `</ul>`.
    ENDIF.

  ENDMETHOD.

  METHOD c_escape_html.

    " the ampersand first: escaping it afterwards would hit the ones the
    " replacements below have just written
    result = val.
    REPLACE ALL OCCURRENCES OF `&` IN result WITH `&amp;`.
    REPLACE ALL OCCURRENCES OF `<` IN result WITH `&lt;`.
    REPLACE ALL OCCURRENCES OF `>` IN result WITH `&gt;`.
    REPLACE ALL OCCURRENCES OF `"` IN result WITH `&quot;`.
    REPLACE ALL OCCURRENCES OF `'` IN result WITH `&#39;`.

  ENDMETHOD.

  METHOD html_check.

    " a closing tag is the one shape a business text does not produce by
    " accident; the void elements are the ones that have none. CS ignores
    " case, so `</DIV>` and `<BR/>` are covered with it
    DATA temp7 TYPE xsdboolean.
    temp7 = boolc( val CS `</` OR val CS `<br` OR val CS `<hr` OR val CS `<img` ).
    result = temp7.

  ENDMETHOD.

  METHOD html_get_plain.
    DATA lv_open TYPE i.

    " one pass over the text: every tag becomes a blank (so that
    " `<td>a</td><td>b</td>` does not read as `ab`), and an unclosed `<`
    " takes the rest of the text with it. The loop this used to be re-sliced
    " the remainder once per tag - quadratic over a long body, in the path
    " that renders an HTML message for the box
    result = val.
    REPLACE ALL OCCURRENCES OF REGEX `<[^>]*>` IN result WITH ` ` ##REGEX_POSIX.

    FIND `<` IN result MATCH OFFSET lv_open.
    IF sy-subrc = 0.
      result = substring( val = result
                          len = lv_open ) && ` `.
    ENDIF.

    " the entities the stripped text would otherwise show as written
    REPLACE ALL OCCURRENCES OF `&nbsp;` IN result WITH ` `.
    REPLACE ALL OCCURRENCES OF `&lt;` IN result WITH `<`.
    REPLACE ALL OCCURRENCES OF `&gt;` IN result WITH `>`.
    REPLACE ALL OCCURRENCES OF `&amp;` IN result WITH `&`.
    CONDENSE result.

    IF strlen( result ) > cv_data_max_text.
      result = substring( val = result
                          len = cv_data_max_text ) && `...`.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_serializable.
        DATA temp115 TYPE REF TO if_serializable_object.
        DATA lo_dummy LIKE temp115.

    IF val IS NOT BOUND.
      result = abap_true.
      RETURN.
    ENDIF.
    TRY.

        temp115 ?= val.

        lo_dummy = temp115.
        result = abap_true.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.

  ENDMETHOD.

  METHOD check_abap_cloud.

    IF gv_check_cloud_cached = abap_true.
      result = gv_check_cloud.
      RETURN.
    ENDIF.

    TRY.
        cl_abap_typedescr=>describe_by_name( `T100` ).
        gv_check_cloud = abap_false.
      CATCH cx_root.
        gv_check_cloud = abap_true.
    ENDTRY.
    gv_check_cloud_cached = abap_true.
    result = gv_check_cloud.

  ENDMETHOD.

  METHOD conv_decode_x_base64.
    DATA lv_web_http_name TYPE c LENGTH 19.
    DATA classname        TYPE c LENGTH 15.

    TRY.

        lv_web_http_name = `CL_WEB_HTTP_UTILITY`.
        CALL METHOD (lv_web_http_name)=>(`DECODE_X_BASE64`)
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

      CATCH cx_root.

        classname = `CL_HTTP_UTILITY`.
        CALL METHOD (classname)=>(`DECODE_X_BASE64`)
          EXPORTING
            encoded = val
          RECEIVING
            decoded = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_encode_x_base64.
    DATA lv_web_http_name TYPE c LENGTH 19.
    DATA classname        TYPE c LENGTH 15.

    TRY.

        lv_web_http_name = `CL_WEB_HTTP_UTILITY`.
        CALL METHOD (lv_web_http_name)=>(`ENCODE_X_BASE64`)
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

      CATCH cx_root.

        classname = `CL_HTTP_UTILITY`.
        CALL METHOD (classname)=>(`ENCODE_X_BASE64`)
          EXPORTING
            unencoded = val
          RECEIVING
            encoded   = result.

    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_string_by_xstring.

    DATA conv          TYPE REF TO object.
    DATA conv_codepage TYPE c LENGTH 21.
    DATA conv_in_class TYPE c LENGTH 18.

    TRY.

        conv_codepage = `CL_ABAP_CONV_CODEPAGE`.
        CALL METHOD (conv_codepage)=>create_in
          RECEIVING
            instance = conv.

        CALL METHOD conv->(`IF_ABAP_CONV_IN~CONVERT`)
          EXPORTING
            source = val
          RECEIVING
            result = result.

      CATCH cx_root.

        conv_in_class = `CL_ABAP_CONV_IN_CE`.
        CALL METHOD (conv_in_class)=>create
          EXPORTING
            encoding = `UTF-8`
          RECEIVING
            conv     = conv.

        CALL METHOD conv->(`CONVERT`)
          EXPORTING
            input = val
          IMPORTING
            data  = result.
    ENDTRY.

  ENDMETHOD.

  METHOD conv_get_xstring_by_string.

    DATA conv           TYPE REF TO object.
    DATA conv_codepage  TYPE c LENGTH 21.
    DATA conv_out_class TYPE c LENGTH 19.

    TRY.

        conv_codepage = `CL_ABAP_CONV_CODEPAGE`.
        CALL METHOD (conv_codepage)=>create_out
          RECEIVING
            instance = conv.

        CALL METHOD conv->(`IF_ABAP_CONV_OUT~CONVERT`)
          EXPORTING
            source = val
          RECEIVING
            result = result.

      CATCH cx_root.

        conv_out_class = `CL_ABAP_CONV_OUT_CE`.
        CALL METHOD (conv_out_class)=>create
          EXPORTING
            encoding = `UTF-8`
          RECEIVING
            conv     = conv.

        CALL METHOD conv->(`CONVERT`)
          EXPORTING
            data   = val
          IMPORTING
            buffer = result.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_classes_impl_intf.

    IF check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_classes_intf_cloud( val              = val
                                            read_description = read_description ).
    ELSE.
      result = rtti_get_classes_intf_std( val              = val
                                          read_description = read_description ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_cloud.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA xco_cp_abap         TYPE c LENGTH 11.
    DATA implementation_name LIKE LINE OF lt_implementation_names.
    DATA ls_class            LIKE LINE OF result.

    ls_clskey-clsname = val.

    xco_cp_abap = `XCO_CP_ABAP`.
    CALL METHOD (xco_cp_abap)=>interface
      EXPORTING
        iv_name      = ls_clskey-clsname
      RECEIVING
        ro_interface = obj.

    " an XCO object without the attribute knows no implementations: the
    " answer is the empty list the on-prem twin gives for an interface
    " nobody implements - not a kernel exception raised by hand
    ASSIGN obj->(`IF_XCO_AO_INTERFACE~IMPLEMENTATIONS`) TO <any>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    obj = <any>.

    ASSIGN obj->(`IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL`) TO <any>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    obj = <any>.

    CALL METHOD obj->(`IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES`)
      RECEIVING
        rt_names = lt_implementation_names.

    LOOP AT lt_implementation_names INTO implementation_name.

      CLEAR ls_class.
      ls_class-classname = implementation_name.
      IF read_description = abap_true.
        " a class the XCO layer cannot describe (deleted mid-list, locked)
        " keeps its slot with a blank description - one broken implementer
        " must not hide every other one from the caller
        TRY.
            ls_class-description = rtti_get_class_descr_on_cloud( implementation_name ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
      INSERT ls_class INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_std.

    TYPES BEGIN OF ty_s_impl.
    TYPES clsname    TYPE c LENGTH 30.
    TYPES refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    " DEFAULT KEY on purpose: this table is passed to the classic function
    " module SEO_INTERFACE_IMPLEM_GET_ALL (impkeys), whose formal parameter is
    " a STANDARD TABLE WITH DEFAULT KEY. WITH EMPTY KEY makes the table type
    " incompatible, so the CALL FUNCTION fails and no implementers are returned
    " (silently breaking user-exit discovery). Never change this key type.
    TYPES temp2 TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
DATA lt_impl TYPE temp2.
    "#EC DEFAULT_KEY
    TYPES BEGIN OF ty_s_key.
    TYPES intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA class    TYPE REF TO data.
    DATA type     TYPE c LENGTH 12.
    FIELD-SYMBOLS <class> TYPE data.
    DATA lr_impl  TYPE REF TO ty_s_impl.
    FIELD-SYMBOLS <description> TYPE any.
    DATA ls_class TYPE ty_s_class_descr.
    DATA lv_fm    TYPE string.

    ls_key-intkey = val.

    lv_fm = `SEO_INTERFACE_IMPLEM_GET_ALL`.
    CALL FUNCTION lv_fm
      EXPORTING
        intkey        = ls_key
      IMPORTING
        impkeys       = lt_impl
      EXCEPTIONS
        error_message = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    type = `SEOC_CLASS_R`.
    CREATE DATA class TYPE (type).

    ASSIGN class->* TO <class>.

    LOOP AT lt_impl REFERENCE INTO lr_impl.

      CLEAR ls_class.
      ls_class-classname = lr_impl->clsname.

      IF read_description = abap_true.

        CLEAR <class>.
        ls_clskey-clsname = lr_impl->clsname.

        lv_fm = `SEO_CLASS_READ`.
        CALL FUNCTION lv_fm
          EXPORTING
            clskey        = ls_clskey
          IMPORTING
            class         = <class>
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.
        " a class the repository cannot read (deleted mid-list, inactive,
        " locked) keeps its slot with a blank description. This used to
        " RAISE, which turned ONE broken implementer into an empty result
        " for the caller - and the framework caller swallows that into
        " "no user exit configured anywhere", the #2564 damage picture,
        " with no error to point at
        IF sy-subrc = 0.
          ASSIGN
            COMPONENT `DESCRIPT`
            OF STRUCTURE <class>
            TO <description>.
          ASSERT sy-subrc = 0.
          ls_class-description = <description>.
        ENDIF.

      ENDIF.

      INSERT
        ls_class
        INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    DATA data_element_name TYPE string.
    DATA lv_do_fallback    TYPE abap_bool.

    data_element_name = val.

    TRY.
        rtti_get_dtel_texts_by_ddic( EXPORTING name        = data_element_name
                                     IMPORTING texts       = result
                                               do_fallback = lv_do_fallback ).
      CATCH cx_root.
        rtti_get_dtel_texts_by_xco( EXPORTING name        = data_element_name
                                    IMPORTING texts       = result
                                              do_fallback = lv_do_fallback ).
    ENDTRY.

    IF lv_do_fallback = abap_true AND result IS INITIAL.
      result-header = val.
      result-long = val.
      result-medium = val.
      result-short = val.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_ddic.

    DATA ddic_ref TYPE REF TO data.
    DATA: BEGIN OF ddic,
            reptext   TYPE string,
            scrtext_s TYPE string,
            scrtext_m TYPE string,
            scrtext_l TYPE string,
          END OF ddic.
    DATA struct_descr TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <ddic> TYPE data.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
    DATA data_descr   TYPE REF TO cl_abap_datadescr.

    CLEAR texts.
    do_fallback = abap_false.

    cl_abap_typedescr=>describe_by_name( `T100` ).

    struct_descr ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

    CREATE DATA ddic_ref TYPE HANDLE struct_descr.

    ASSIGN ddic_ref->* TO <ddic>.
    ASSERT sy-subrc = 0.

    cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name     = name
                                         RECEIVING p_descr_ref = lo_typedescr
                                         EXCEPTIONS OTHERS     = 1 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    data_descr ?= lo_typedescr.

    CALL METHOD data_descr->(`GET_DDIC_FIELD`)
      RECEIVING
        p_flddescr   = <ddic>
      EXCEPTIONS
        not_found    = 1
        no_ddic_type = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING <ddic> TO ddic.
    texts-header = ddic-reptext.
    texts-short  = ddic-scrtext_s.
    texts-medium = ddic-scrtext_m.
    texts-long   = ddic-scrtext_l.
    do_fallback  = abap_true.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_xco.

    DATA data_element TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA exists       TYPE abap_bool.
    DATA lv_xco_cp_abap_dictionary TYPE string.

    CLEAR texts.
    do_fallback = abap_false.

    TRY.
        lv_xco_cp_abap_dictionary = `XCO_CP_ABAP_DICTIONARY`.
        CALL METHOD (lv_xco_cp_abap_dictionary)=>(`DATA_ELEMENT`)
          EXPORTING
            iv_name         = name
          RECEIVING
            ro_data_element = data_element.

        CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~EXISTS`)
          RECEIVING
            rv_exists = exists.

        IF exists = abap_false.
          RETURN.
        ENDIF.

        CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~CONTENT`)
          RECEIVING
            ro_content = content.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL`)
          RECEIVING
            rs_heading_field_label = texts-header.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL`)
          RECEIVING
            rs_short_field_label = texts-short.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL`)
          RECEIVING
            rs_medium_field_label = texts-medium.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL`)
          RECEIVING
            rs_long_field_label = texts-long.

        do_fallback = abap_true.

      CATCH cx_root.
        do_fallback = abap_true.
    ENDTRY.

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid      TYPE c LENGTH 32.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.
        DATA lx_uuid TYPE REF TO cx_root.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_root.

            lv_fm = `GUID_CREATE`.
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32 = lv_uuid.

        ENDTRY.

        result = lv_uuid.


      CATCH cx_root INTO lx_uuid.
        " both UUID mechanisms failed - raise the framework exception so the
        " single top-level catch in the HTTP handler turns it into a 500.
        " ASSERT would raise the uncatchable ASSERTION_FAILED and bypass that
        " catch (short dump instead of a handled error response). No
        " re-entrancy guard any more: z2ui5_cx_ui5_util_error's constructor
        " no longer asks for a uuid (it is computed on the first render,
        " inside a CATCH of its own), so the raise cannot come back here
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = lx_uuid.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_class_descr_on_cloud.
        DATA obj TYPE REF TO object.
        DATA content TYPE REF TO object.
        DATA lv_classname TYPE c LENGTH 30.
        DATA xco_cp_abap TYPE c LENGTH 11.
    TRY.






        lv_classname = classname.

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

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


  METHOD msg_get_internal.

    DATA lv_kind TYPE string.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp116 TYPE ty_s_msg.
        DATA ls_result LIKE temp116.
        DATA temp117 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp117.
          FIELD-SYMBOLS <comp> TYPE any.
          DATA temp118 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    lv_kind = rtti_get_type_kind( val ).
    CASE lv_kind.

      WHEN cl_abap_datadescr=>typekind_table.

        ASSIGN val TO <tab>.
        result = msg_get_internal_tab( <tab> ).

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        IF iv_check_rap = abap_true AND check_is_rap_struct( val ) = abap_true.
          result = msg_get_rap( val ).
          RETURN.
        ENDIF.


        lt_attri = rtti_get_t_attri_by_any( val ).


        CLEAR temp116.

        ls_result = temp116.


        LOOP AT lt_attri REFERENCE INTO ls_attri.

          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          IF ls_attri->name = `ITEM`.
            INSERT LINES OF msg_get_internal( <comp> ) INTO TABLE result.
            RETURN.
          ELSE.
            ls_result = msg_map( name = ls_attri->name
                                 val  = <comp>
                                 msg  = ls_result ).
          ENDIF.

        ENDLOOP.
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL.
          ls_result-id = to_upper( ls_result-id ).
          MESSAGE ID ls_result-id TYPE `I` NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        " an unbound reference carries no message - guarded like the struct
        " and table branches guard theirs. Unguarded it fell through the
        " three handlers of msg_get_by_oref into a describe on the null
        " reference, and message_box_display( unbound ) ended in a 500
        " instead of the documented silence
        IF val IS NOT INITIAL.
          result = msg_get_by_oref( val ).
        ENDIF.

      WHEN OTHERS.

        " skip an empty character value like the struct branch does -
        " otherwise msg_get_t's val2 fallback can never take over and the
        " caller renders a message box with blank text
        IF rtti_check_clike( val ) IS NOT INITIAL AND val IS NOT INITIAL.

          CLEAR temp118.
          temp118-text = val.
          INSERT temp118 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get_internal_tab.

    " the RAP shape is a property of the ROW TYPE: decided on the first
    " structured row and handed down, not asked of every row - the check
    " describes every table component of a row, which a business table of a
    " few thousand rows paid a few thousand times before the box even
    " decided it carries no message at all
    DATA lv_rap LIKE abap_false.
    DATA lv_first LIKE abap_true.
    FIELD-SYMBOLS <row> TYPE ANY.
        DATA lv_row_kind TYPE string.
    lv_rap = abap_false.

    lv_first = abap_true.

    LOOP AT it_tab ASSIGNING <row>.
      IF lv_first = abap_true.
        lv_first = abap_false.

        lv_row_kind = rtti_get_type_kind( <row> ).
        IF lv_row_kind = cl_abap_datadescr=>typekind_struct1
            OR lv_row_kind = cl_abap_datadescr=>typekind_struct2.
          lv_rap = check_is_rap_struct( <row> ).
        ENDIF.
      ENDIF.
      IF lv_rap = abap_true AND <row> IS NOT INITIAL.
        INSERT LINES OF msg_get_rap( <row> ) INTO TABLE result.
      ELSE.
        INSERT LINES OF msg_get_internal( val          = <row>
                                          iv_check_rap = abap_false ) INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_by_oref.
        DATA temp119 TYPE REF TO cx_root.
        DATA lx LIKE temp119.
        DATA temp120 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.
    DATA obj TYPE REF TO object.
    DATA lr_tab TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE any.
    DATA temp121 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.

    " four shapes, tried in turn and each on its own level - the nested
    " TRY/CATCH pyramid this used to be carried the attribute mapping twice,
    " three CATCH blocks deep, one fix away from drifting. Every attempt
    " that fails falls through to the next; the last one cannot fail
    " quietly, it maps whatever public attributes the object has

    " 1. an exception: its text, and its public attributes over it
    TRY.

        temp119 ?= val.

        lx = temp119.

        CLEAR temp120.
        temp120-type = `E`.
        temp120-text = lx->get_text( ).
        INSERT msg_get_by_oref_attri( io_obj = lx
                                      is_msg = temp120 ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    obj = val.



    " 2. an application log (IF_BALI_LOG)
    TRY.
        CREATE DATA lr_tab TYPE (`if_bali_log=>ty_item_table`).
        ASSIGN lr_tab->* TO <tab>.
        CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
          RECEIVING
            item_table = <tab>.
        INSERT LINES OF msg_get_internal( <tab> ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " 3. a logger (ZIF_LOGGER)
    TRY.
        CREATE DATA lr_tab TYPE (`BAPIRETTAB`).
        ASSIGN lr_tab->* TO <tab>.
        CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
          RECEIVING
            rt_bapiret = <tab>.
        INSERT LINES OF msg_get_internal( <tab> ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " 4. any object: whatever public attributes carry a message part

    CLEAR temp121.
    INSERT msg_get_by_oref_attri( io_obj = obj
                                  is_msg = temp121 ) INTO TABLE result.

  ENDMETHOD.

  METHOD msg_get_by_oref_attri.

    FIELD-SYMBOLS <comp> TYPE any.
    DATA lt_attri_o TYPE abap_attrdescr_tab.
    DATA temp122 LIKE LINE OF lt_attri_o.
    DATA ls_attri_o LIKE REF TO temp122.
      DATA lv_name LIKE ls_attri_o->name.

    result = is_msg.

    lt_attri_o = rtti_get_t_attri_by_oref( io_obj ).


    LOOP AT lt_attri_o REFERENCE INTO ls_attri_o "#EC CI_SORTSEQ
         WHERE visibility = cv_objectdescr_public.

      lv_name = ls_attri_o->name.
      ASSIGN io_obj->(lv_name) TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      result = msg_map( name = ls_attri_o->name
                        val  = <comp>
                        msg  = result ).
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_map.

    result = msg.
    CASE name.
      WHEN `ID` OR `MSGID`.
        result-id = val.
      WHEN `NO` OR `NUMBER` OR `MSGNO`.
        result-no = val.
      WHEN `MESSAGE` OR `TEXT`.
        result-text = val.
      WHEN `TYPE` OR `MSGTY` OR `M_SEVERITY`.
        result-type = val.
      WHEN `MESSAGE_V1` OR `MSGV1` OR `V1`.
        result-v1 = val.
      WHEN `MESSAGE_V2` OR `MSGV2` OR `V2`.
        result-v2 = val.
      WHEN `MESSAGE_V3` OR `MSGV3` OR `V3`.
        result-v3 = val.
      WHEN `MESSAGE_V4` OR `MSGV4` OR `V4`.
        result-v4 = val.
      WHEN `TIME_STMP`.
        result-timestampl = val.
    ENDCASE.

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp123 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp123.
      FIELD-SYMBOLS <tab> TYPE any.
          DATA temp124 TYPE REF TO cl_abap_tabledescr.
          DATA lo_tab LIKE temp124.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp125 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp126 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp126.
    lt_attri = rtti_get_t_attri_by_any( val ).



    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CASE ls_attri->name.
        WHEN `%MSG` OR `%FAIL` OR `%OTHER`.
          result = abap_true.
          RETURN.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.

      TRY.

          temp124 ?= cl_abap_typedescr=>describe_by_data( <tab> ).

          lo_tab = temp124.

          lo_line = lo_tab->get_table_line_type( ).
          CHECK lo_line->kind = cl_abap_typedescr=>kind_struct.

          temp125 ?= lo_line.

          lt_comps = temp125->get_components( ).


          LOOP AT lt_comps REFERENCE INTO ls_comp.
            IF ls_comp->name = `%MSG` OR ls_comp->name = `%FAIL`.
              result = abap_true.
              RETURN.
            ENDIF.
          ENDLOOP.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap.

    DATA lv_kind TYPE string.
    DATA lv_is_row TYPE abap_bool.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp127 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp127.
      FIELD-SYMBOLS <tab> TYPE any.
      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      FIELD-SYMBOLS <row> TYPE ANY.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    msg_get_rap_row( EXPORTING val         = val
                               entity_name = entity_name
                     IMPORTING messages    = result
                               is_row      = lv_is_row ).
    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      CHECK sy-subrc = 0.
      CHECK rtti_get_type_kind( <tab> ) = cl_abap_datadescr=>typekind_table.


      ASSIGN <tab> TO <ftab>.


      LOOP AT <ftab> ASSIGNING <row>.
        IF rtti_get_type_kind( <row> ) = cl_abap_datadescr=>typekind_oref.
          IF <row> IS NOT INITIAL.
            TRY.
                INSERT LINES OF msg_get_t( <row> ) INTO TABLE result.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
        ELSE.
          INSERT LINES OF msg_get_rap( val         = <row>
                                       entity_name = ls_attri->name ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_row.
    DATA lv_meta_built TYPE abap_bool.
    DATA lt_meta TYPE ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE z2ui5_cl_ui5_util_context=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp128 TYPE z2ui5_cl_ui5_util_context=>ty_s_msg.

    CLEAR messages.
    is_row = abap_false.

    " the meta block is built LAZILY: msg_get_rap_meta walks the row's
    " components three times over (element/action/tky scans), and the
    " common row in a RAP response table carries neither a filled %MSG nor
    " a %FAIL - building the block up front threw that work away per row




    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO <msg>.
    IF sy-subrc = 0.
      is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        lt_meta = msg_get_rap_meta( val ).
        lv_meta_built = abap_true.
        TRY.

            lt_one = msg_get_t( <msg> ).

            LOOP AT lt_one ASSIGNING <m>.
              <m>-t_meta = lt_meta.
            ENDLOOP.
            INSERT LINES OF lt_one INTO TABLE messages.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO <fail>.
    IF sy-subrc = 0.
      is_row = abap_true.

      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
      IF sy-subrc = 0.
        IF lv_meta_built = abap_false.
          lt_meta = msg_get_rap_meta( val ).
        ENDIF.

        lv_cause = <cause>.

        lv_text = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.

        CLEAR temp128.
        temp128-type = `E`.
        temp128-text = lv_text.
        temp128-t_meta = lt_meta.
        INSERT temp128 INTO TABLE messages.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_element.

    DATA lt_suffix TYPE string_table.
    lt_suffix = scan_flag_prefix( val    = val
                                        prefix = `%ELEMENT-` ).
    result = concat_lines_of( table = lt_suffix
                              sep   = `, ` ).

  ENDMETHOD.

  METHOD get_comp_str.

    FIELD-SYMBOLS <comp> TYPE any.
    ASSIGN COMPONENT comp OF STRUCTURE val TO <comp>.
    IF sy-subrc = 0.
      result = <comp>.
    ENDIF.

  ENDMETHOD.

  METHOD scan_flag_prefix.

    DATA lv_len TYPE i.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp129 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp129.
      FIELD-SYMBOLS <flag> TYPE any.
    lv_len = strlen( prefix ).

    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CHECK strlen( ls_attri->name ) > lv_len.
      CHECK ls_attri->name(lv_len) = prefix.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <flag>.
      CHECK sy-subrc = 0.
      CHECK <flag> IS NOT INITIAL.
      APPEND ls_attri->name+lv_len TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_state_area.

    result = get_comp_str( val  = val
                           comp = `%STATE_AREA` ).

  ENDMETHOD.

  METHOD msg_get_rap_action.

    DATA lt_suffix TYPE string_table.
    DATA temp130 TYPE string.
    DATA temp131 TYPE string.
    lt_suffix = scan_flag_prefix( val    = val
                                        prefix = `%OP-%ACTION-` ).

    CLEAR temp130.

    READ TABLE lt_suffix INTO temp131 INDEX 1.
    IF sy-subrc = 0.
      temp130 = temp131.
    ENDIF.
    result = temp130.

  ENDMETHOD.

  METHOD msg_get_rap_pid.

    result = get_comp_str( val  = val
                           comp = `%PID` ).

  ENDMETHOD.

  METHOD msg_get_rap_cid.

    result = get_comp_str( val  = val
                           comp = `%CID` ).

  ENDMETHOD.

  METHOD msg_get_rap_tky.

    FIELD-SYMBOLS <tky> TYPE any.
    ASSIGN COMPONENT `%TKY` OF STRUCTURE val TO <tky>.
    IF sy-subrc <> 0 OR <tky> IS INITIAL.
      RETURN.
    ENDIF.
    result = msg_get_rap_flatten( <tky> ).

  ENDMETHOD.

  METHOD msg_get_rap_flatten.

    DATA lv_kind TYPE string.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp132 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp132.
      FIELD-SYMBOLS <comp> TYPE any.
      DATA lv_sub_kind TYPE string.
        DATA lv_sub TYPE string.
            DATA lv_str TYPE string.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
      CHECK sy-subrc = 0.


      lv_sub_kind = rtti_get_type_kind( <comp> ).
      IF lv_sub_kind = cl_abap_datadescr=>typekind_struct1
          OR lv_sub_kind = cl_abap_datadescr=>typekind_struct2.

        lv_sub = msg_get_rap_flatten( <comp> ).
        IF lv_sub IS NOT INITIAL.
          IF result IS NOT INITIAL.
            result = |{ result }, |.
          ENDIF.
          result = |{ result }{ lv_sub }|.
        ENDIF.
      ELSEIF <comp> IS NOT INITIAL.
        TRY.

            lv_str = <comp>.
            IF result IS NOT INITIAL.
              result = |{ result }, |.
            ENDIF.
            result = |{ result }{ ls_attri->name }={ lv_str }|.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_meta.

    DATA lv TYPE string.
      DATA temp133 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
      DATA temp134 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
      DATA temp135 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
      DATA temp136 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
      DATA temp137 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.
      DATA temp138 TYPE z2ui5_cl_ui5_util_context=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp133.
      temp133-n = `element`.
      temp133-v = lv.
      INSERT temp133 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp134.
      temp134-n = `state_area`.
      temp134-v = lv.
      INSERT temp134 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp135.
      temp135-n = `action`.
      temp135-v = lv.
      INSERT temp135 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp136.
      temp136-n = `pid`.
      temp136-v = lv.
      INSERT temp136 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp137.
      temp137-n = `cid`.
      temp137-v = lv.
      INSERT temp137 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp138.
      temp138-n = `tky`.
      temp138-v = lv.
      INSERT temp138 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.

    DATA temp139 TYPE string.
    CASE cause.
      WHEN 0.
        temp139 = `Operation failed`.
      WHEN 1.
        temp139 = `Entity not found`.
      WHEN 2.
        temp139 = `Entity is locked`.
      WHEN 3.
        temp139 = `Authorization failure`.
      WHEN 4.
        temp139 = `Concurrent modification`.
      WHEN 5.
        temp139 = `Concurrent modification`.
      WHEN 6.
        temp139 = `Operation disabled`.
      WHEN 7.
        temp139 = `Operation forbidden`.
      WHEN 8.
        temp139 = `Semantic error`.
      WHEN 9.
        temp139 = `Determination failed`.
      WHEN 10.
        temp139 = `Permission denied`.
      WHEN 11.
        temp139 = `Validation failed`.
      WHEN OTHERS.
        temp139 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp139.

  ENDMETHOD.

ENDCLASS.
