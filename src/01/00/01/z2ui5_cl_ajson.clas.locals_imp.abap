**********************************************************************
* UTILS
**********************************************************************

interface lif_kind.

  types ty_kind type c length 1.

  constants:
    any         type ty_kind value cl_abap_typedescr=>typekind_any,
    date        type ty_kind value cl_abap_typedescr=>typekind_date,
    time        type ty_kind value cl_abap_typedescr=>typekind_time,
    packed      type ty_kind value cl_abap_typedescr=>typekind_packed,
    table       type ty_kind value cl_abap_typedescr=>typekind_table,
    struct_flat type ty_kind value cl_abap_typedescr=>typekind_struct1,
    struct_deep type ty_kind value cl_abap_typedescr=>typekind_struct2,
    data_ref    type ty_kind value cl_abap_typedescr=>typekind_dref,
    object_ref  type ty_kind value cl_abap_typedescr=>typekind_oref,
    enum        type ty_kind value 'k'. " cl_abap_typedescr=>typekind_enum not in lower releases

  constants:
    begin of numeric,
      int1       type ty_kind value cl_abap_tabledescr=>typekind_int1,
      int2       type ty_kind value cl_abap_tabledescr=>typekind_int2,
      int4       type ty_kind value cl_abap_tabledescr=>typekind_int,
      int8       type ty_kind value '8', " cl_abap_tabledescr=>typekind_int8 not in lower releases
      float      type ty_kind value cl_abap_tabledescr=>typekind_float,
      packed     type ty_kind value cl_abap_tabledescr=>typekind_packed,
      decfloat16 type ty_kind value cl_abap_tabledescr=>typekind_decfloat16,
      decfloat34 type ty_kind value cl_abap_tabledescr=>typekind_decfloat34,
    end of numeric.

  constants:
    begin of texts,
      char   type ty_kind value cl_abap_tabledescr=>typekind_char,
      numc   type ty_kind value cl_abap_tabledescr=>typekind_num,
      string type ty_kind value cl_abap_tabledescr=>typekind_string,
    end of texts.

  constants:
    begin of binary,
      hex     type ty_kind value cl_abap_tabledescr=>typekind_hex,
      xstring type ty_kind value cl_abap_tabledescr=>typekind_xstring,
    end of binary.

  constants:
    begin of deep_targets,
      table       type ty_kind value cl_abap_typedescr=>typekind_table,
      struct_flat type ty_kind value cl_abap_typedescr=>typekind_struct1,
      struct_deep type ty_kind value cl_abap_typedescr=>typekind_struct2,
      data_ref    type ty_kind value cl_abap_typedescr=>typekind_dref,
      object_ref  type ty_kind value cl_abap_typedescr=>typekind_oref,
    end of deep_targets.

endinterface.

class lcl_utils definition final.
  public section.

    class-methods normalize_path
      importing
        iv_path type string
      returning
        value(rv_path) type string.
    class-methods split_path
      importing
        iv_path type string
      returning
        value(rv_path_name) type z2ui5_if_ajson_types=>ty_path_name.
    class-methods validate_array_index
      importing
        iv_path type string
        iv_index type string
      returning
        value(rv_index) type i
      raising
        z2UI5_cx_ajson_error.
    class-methods string_to_xstring_utf8
      importing
        iv_str type string
      returning
        value(rv_xstr) type xstring.

endclass.

class lcl_utils implementation.

  method string_to_xstring_utf8.

    data lo_conv type ref to object.
    data lv_out_ce type string.

    lv_out_ce = 'CL_ABAP_CONV_OUT_CE'.

    try.
      call method ('CL_ABAP_CONV_CODEPAGE')=>create_out
        receiving
          instance = lo_conv.
      call method lo_conv->('IF_ABAP_CONV_OUT~CONVERT')
        exporting
          source = iv_str
        receiving
          result = rv_xstr.
    catch cx_sy_dyn_call_illegal_class.
      call method (lv_out_ce)=>create
        exporting
          encoding = 'UTF-8'
        receiving
          conv = lo_conv.
      call method lo_conv->('CONVERT')
        exporting
          data = iv_str
        importing
          buffer = rv_xstr.
    endtry.

  endmethod.

  method validate_array_index.

    if not iv_index co '0123456789'.
      z2ui5_cx_ajson_error=>raise( |Cannot add non-numeric key [{ iv_index }] to array [{ iv_path }]| ).
    endif.
    rv_index = iv_index.
    if rv_index = 0.
      z2ui5_cx_ajson_error=>raise( |Cannot add zero key to array [{ iv_path }]| ).
    endif.

  endmethod.

  method normalize_path.

    rv_path = iv_path.
    if strlen( rv_path ) = 0.
      rv_path = '/'.
    endif.
    if rv_path+0(1) <> '/'.
      rv_path = '/' && rv_path.
    endif.
    if substring( val = rv_path off = strlen( rv_path ) - 1 ) <> '/'.
      rv_path = rv_path && '/'.
    endif.

  endmethod.

  method split_path.

    data lv_offs type i.
    data lv_len type i.
    data lv_trim_slash type i.

    lv_len = strlen( iv_path ).
    if lv_len = 0 or iv_path = '/'.
      return. " empty path is the alias for root item = '' + ''
    endif.

    if substring( val = iv_path off = lv_len - 1 ) = '/'.
      lv_trim_slash = 1. " ignore last '/'
    endif.

    lv_offs = find( val = reverse( iv_path ) sub = '/' off = lv_trim_slash ).
    if lv_offs = -1.
      lv_offs  = lv_len. " treat whole string as the 'name' part
    endif.
    lv_offs = lv_len - lv_offs.

    rv_path_name-path = normalize_path( substring( val = iv_path len = lv_offs ) ).
    rv_path_name-name = substring( val = iv_path off = lv_offs len = lv_len - lv_offs - lv_trim_slash ).

  endmethod.

endclass.


**********************************************************************
* PARSER
**********************************************************************

class lcl_json_parser definition final.
  public section.

    methods parse
      importing
        iv_json type string
        iv_keep_item_order type abap_bool default abap_false
      returning
        value(rt_json_tree) type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

  private section.

    types:
      ty_stack_tt TYPE STANDARD TABLE OF ref to z2ui5_if_ajson_types=>ty_node.

    data mt_stack type ty_stack_tt.
    data mv_stack_path type string.
    data mv_keep_item_order type abap_bool.

    methods raise
      importing
        iv_error type string
      raising
        z2ui5_cx_ajson_error.

    methods _parse
      importing
        iv_json type string
      returning
        value(rt_json_tree) type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error cx_dynamic_check. " cx_sxml_error is not released on Steampunk #153

    methods _get_location
      importing
        iv_json            type string
        iv_offset          type i
      returning
        value(rv_location) type string.

endclass.

class lcl_json_parser implementation.

  method parse.
    data lx_sxml_parse type ref to cx_sxml_parse_error.
    data lx_sxml type ref to cx_dynamic_check.
    data lv_location type string.

    mv_keep_item_order = iv_keep_item_order.

    try.
      " TODO sane JSON check:
      " JSON can be true,false,null,(-)digits
      " or start from " or from {
      rt_json_tree = _parse( iv_json ).
    catch cx_sxml_parse_error into lx_sxml_parse.
      lv_location = _get_location(
        iv_json   = iv_json
        iv_offset = lx_sxml_parse->xml_offset ).
      z2ui5_cx_ajson_error=>raise(
        iv_msg      = |Json parsing error (SXML): { lx_sxml_parse->get_text( ) }|
        iv_location = lv_location ).
    catch cx_dynamic_check into lx_sxml. " cx_sxml_error
      z2ui5_cx_ajson_error=>raise(
        iv_msg      = |Json parsing error (SXML): { lx_sxml->get_text( ) }|
        iv_location = '@PARSER' ).
    endtry.

  endmethod.

  method _get_location.

    data lv_json type string.
    data lv_offset type i.
    data lt_text TYPE STANDARD TABLE OF string.
    data lv_text type string.
    data lv_line type i.
    data lv_pos type i.

    lv_offset = iv_offset.
    if lv_offset < 0.
      lv_offset = 0.
    endif.
    if lv_offset > strlen( iv_json ).
      lv_offset = strlen( iv_json ).
    endif.

    lv_json = iv_json(lv_offset).

    replace all occurrences of cl_abap_char_utilities=>cr_lf
      in lv_json with cl_abap_char_utilities=>newline.

    split lv_json at cl_abap_char_utilities=>newline into table lt_text.

    lv_line = lines( lt_text ).
    if lv_line = 0.
      lv_line = 1.
      lv_pos = 1.
    else.
      read table lt_text index lv_line into lv_text.
      lv_pos = strlen( lv_text ) + 1.
    endif.

    rv_location = |Line { lv_line }, Offset { lv_pos }|.

  endmethod.

  method _parse.

    data lo_reader type ref to if_sxml_reader.
    data lr_stack_top like line of mt_stack.
    data lo_node type ref to if_sxml_node.
    field-symbols <item> like line of rt_json_tree.

    clear mt_stack.
    clear mv_stack_path.
    if iv_json is initial.
      return.
    endif.
    lo_reader = cl_sxml_string_reader=>create( lcl_utils=>string_to_xstring_utf8( iv_json ) ).

    " TODO: self protection, check non-empty, check starting from object ...

    do.
      lo_node = lo_reader->read_next_node( ).
      if lo_node is not bound.
        exit.
      endif.


      case lo_node->type.
        when if_sxml_node=>co_nt_element_open.
          data lt_attributes type if_sxml_attribute=>attributes.
          data lo_attr like line of lt_attributes.
          data lo_open type ref to if_sxml_open_element.
          lo_open ?= lo_node.

          append initial line to rt_json_tree assigning <item>.

          <item>-type = lo_open->qname-name.

          read table mt_stack index 1 into lr_stack_top.
          if sy-subrc = 0.
            " Using string is faster than rebuilding path from stack
            <item>-path = mv_stack_path.
            lr_stack_top->children = lr_stack_top->children + 1.

            if lr_stack_top->type = `array`. " This is parser type not ajson type
              <item>-name = |{ lr_stack_top->children }|.
              <item>-index = lr_stack_top->children.
            else.
              lt_attributes = lo_open->get_attributes( ).
              loop at lt_attributes into lo_attr.
                if lo_attr->qname-name = 'name' and lo_attr->value_type = if_sxml_value=>co_vt_text.
                  <item>-name = lo_attr->get_value( ).
                endif.
              endloop.
              if mv_keep_item_order = abap_true.
                <item>-order = lr_stack_top->children.
              endif.
            endif.
            if <item>-name is initial.
              raise( 'Node without name (maybe not JSON)' ).
            endif.
          endif.

          get reference of <item> into lr_stack_top.
          insert lr_stack_top into mt_stack index 1.
          " add path component
          mv_stack_path = mv_stack_path && <item>-name && '/'.

        when if_sxml_node=>co_nt_element_close.
          data lo_close type ref to if_sxml_close_element.
          lo_close ?= lo_node.

          read table mt_stack index 1 into lr_stack_top.
          delete mt_stack index 1.
          if lo_close->qname-name <> lr_stack_top->type.
            raise( 'Unexpected closing node type' ).
          endif.

          " remove last path component
          mv_stack_path = substring( val = mv_stack_path len = find( val = mv_stack_path sub = '/' occ = -2 ) + 1 ).
        when if_sxml_node=>co_nt_value.
          data lo_value type ref to if_sxml_value_node.
          lo_value ?= lo_node.

          <item>-value = lo_value->get_value( ).

        when others.
          raise( 'Unexpected node type' ).
      endcase.
    enddo.

    if lines( mt_stack ) > 0.
      raise( 'Unexpected end of data' ).
    endif.

  endmethod.

  method raise.

    z2ui5_cx_ajson_error=>raise(
      iv_location = mv_stack_path
      iv_msg      = |JSON PARSER: { iv_error } @ { mv_stack_path }| ).

  endmethod.

endclass.

**********************************************************************
* SERIALIZER
**********************************************************************

class lcl_json_serializer definition final create private.
  public section.

    class-methods stringify
      importing
        it_json_tree type z2ui5_if_ajson_types=>ty_nodes_ts
        iv_indent type i default 0
        iv_keep_item_order type abap_bool default abap_false
      returning
        value(rv_json_string) type string
      raising
        z2ui5_cx_ajson_error.

    class-methods class_constructor.

  private section.

    class-data gv_comma_with_lf type string.

    data mt_json_tree type z2ui5_if_ajson_types=>ty_nodes_ts.
    data mv_keep_item_order type abap_bool.
    data mt_buffer type string_table.
    data mv_indent_step type i.
    data mv_level type i.

    class-methods escape_string
      importing
        iv_unescaped type string
      returning
        value(rv_escaped) type string.

    methods _stringify
      returning
        value(rv_json_string) type string
      raising
        z2ui5_cx_ajson_error.

    methods stringify_node
      importing
        is_node type z2ui5_if_ajson_types=>ty_node
      raising
        z2ui5_cx_ajson_error.

    methods stringify_set
      importing
        iv_parent_path type string
        iv_array type abap_bool
      raising
        z2ui5_cx_ajson_error.

endclass.

class lcl_json_serializer implementation.

  method class_constructor.
    gv_comma_with_lf = ',' && cl_abap_char_utilities=>newline.
  endmethod.

  method stringify.

    data lo type ref to lcl_json_serializer.
    create object lo.
    lo->mt_json_tree = it_json_tree.
    lo->mv_indent_step = iv_indent.
    lo->mv_keep_item_order = iv_keep_item_order.
    rv_json_string = lo->_stringify( ).

  endmethod.

  method _stringify.

    field-symbols <n> like line of mt_json_tree.
    read table mt_json_tree assigning <n>
      with key
        path = ''
        name = ''. " Root
    if sy-subrc <> 0.
      return.
    endif.

    stringify_node( <n> ).

    rv_json_string = concat_lines_of( table = mt_buffer ).

  endmethod.

  method stringify_node.

    data lv_item type string.
    data lv_indent_prefix type string.

    if mv_indent_step > 0.
      lv_indent_prefix = repeat( val = ` ` occ = mv_indent_step * mv_level ).
      lv_item = lv_indent_prefix.
    endif.

    if is_node-name is not initial and is_node-index is initial. " Not root, not array item
      if mv_indent_step > 0.
        lv_item = lv_item && |"{ is_node-name }": |.
      else.
        lv_item = |"{ is_node-name }":|.
      endif.
    endif.

    case is_node-type.
      when z2ui5_if_ajson_types=>node_type-array.
        lv_item = lv_item && '['.
      when z2ui5_if_ajson_types=>node_type-object.
        lv_item = lv_item && '{'.
      when z2ui5_if_ajson_types=>node_type-string.
        lv_item = lv_item && |"{ escape_string( is_node-value ) }"|.
      when z2ui5_if_ajson_types=>node_type-boolean or z2ui5_if_ajson_types=>node_type-number.
        lv_item = lv_item && is_node-value.
      when z2ui5_if_ajson_types=>node_type-null.
        lv_item = lv_item && 'null'.
      when others.
        z2ui5_cx_ajson_error=>raise(
          iv_msg = |Unexpected type [{ is_node-type }]|
          iv_location = is_node-path && is_node-name ).
    endcase.

    if mv_indent_step > 0
      and ( is_node-type = z2ui5_if_ajson_types=>node_type-array or is_node-type = z2ui5_if_ajson_types=>node_type-object )
      and is_node-children > 0.
      mv_level = mv_level + 1.
      lv_item = lv_item && cl_abap_char_utilities=>newline.
    endif.

    append lv_item to mt_buffer.

    " finish complex item

    if is_node-type = z2ui5_if_ajson_types=>node_type-array or is_node-type = z2ui5_if_ajson_types=>node_type-object.
      data lv_children_path type string.
      data lv_tail type string.

      lv_children_path = is_node-path && is_node-name && '/'. " for root: path = '' and name = '', so result is '/'

      case is_node-type.
        when z2ui5_if_ajson_types=>node_type-array.
          if is_node-children > 0.
            stringify_set(
              iv_parent_path = lv_children_path
              iv_array       = abap_true ).
          endif.
          lv_tail = ']'.
        when z2ui5_if_ajson_types=>node_type-object.
          if is_node-children > 0.
            stringify_set(
              iv_parent_path = lv_children_path
              iv_array       = abap_false ).
          endif.
          lv_tail = '}'.
      endcase.

      if mv_indent_step > 0 and is_node-children > 0.
        lv_tail = lv_indent_prefix && lv_tail.
        mv_level = mv_level - 1.
      endif.
      append lv_tail to mt_buffer.
    endif.

  endmethod.

  method stringify_set.

    data lv_tab_key type string.
    data lv_first_done type abap_bool.
    field-symbols <n> like line of mt_json_tree.

    if iv_array = abap_true.
      lv_tab_key = 'array_index'. " path + index
    elseif mv_keep_item_order = abap_true.
      lv_tab_key = 'item_order'. " path + order
    else.
      lv_tab_key = 'primary_key'. " path + name
    endif.

    loop at mt_json_tree assigning <n> using key (lv_tab_key) where path = iv_parent_path.
      if lv_first_done = abap_false.
        lv_first_done = abap_true.
      elseif mv_indent_step > 0.
        append gv_comma_with_lf to mt_buffer.
      else.
        append ',' to mt_buffer.
      endif.
      stringify_node( <n> ).
    endloop.

    if mv_indent_step > 0 and lv_first_done = abap_true. " only of items were in the list
      append cl_abap_char_utilities=>newline to mt_buffer.
    endif.

  endmethod.

  method escape_string.

    rv_escaped = iv_unescaped.
    if rv_escaped ca |"\\\t\n\r|.
      " TODO consider performance ...
      " see also https://www.json.org/json-en.html
      rv_escaped = replace(
        val = rv_escaped
        sub = '\'
        with = '\\'
        occ = 0 ).
      rv_escaped = replace(
        val = rv_escaped
        sub = |\n|
        with = '\n'
        occ = 0 ).
      rv_escaped = replace(
        val = rv_escaped
        sub = |\r|
        with = '\r'
        occ = 0 ).
      rv_escaped = replace(
        val = rv_escaped
        sub = |\t|
        with = '\t'
        occ = 0 ).
      rv_escaped = replace(
        val = rv_escaped
        sub = '"'
        with = '\"'
        occ = 0 ).

    endif.

  endmethod.

endclass.


**********************************************************************
* JSON_TO_ABAP
**********************************************************************

class lcl_json_to_abap definition final.
  public section.

    methods constructor
      importing
        !iv_corresponding  type abap_bool default abap_false
        !ii_custom_mapping type ref to z2ui5_if_ajson_mapping optional.

    methods to_abap
      importing
        it_nodes     type z2ui5_if_ajson_types=>ty_nodes_ts
      changing
        c_container type any
      raising
        z2ui5_cx_ajson_error.

    methods to_timestamp
      importing
        iv_value         type z2ui5_if_ajson_types=>ty_node-value
      returning
        value(rv_result) type timestamp
      raising
        z2ui5_cx_ajson_error.

    methods to_date
      importing
        iv_value         type z2ui5_if_ajson_types=>ty_node-value
      returning
        value(rv_result) type d
      raising
        z2ui5_cx_ajson_error.

    methods to_time
      importing
        iv_value         type z2ui5_if_ajson_types=>ty_node-value
      returning
        value(rv_result) type t
      raising
        z2ui5_cx_ajson_error.

  private section.

    types:
      begin of ty_type_cache,
        type_path         type string,
        target_field_name type string,
        dd                type ref to cl_abap_datadescr,
        type_kind         like lif_kind=>any,
        tab_item_buf      type ref to data,
      end of ty_type_cache.
    data mt_node_type_cache type hashed table of ty_type_cache with unique key type_path.

    data mr_nodes type ref to z2ui5_if_ajson_types=>ty_nodes_ts.
    data mi_custom_mapping type ref to z2ui5_if_ajson_mapping.
    data mv_corresponding type abap_bool.

    methods any_to_abap
      importing
        iv_path        type string
        is_parent_type type ty_type_cache optional
        i_container_ref type ref to data
      raising
        z2ui5_cx_ajson_error.

    methods value_to_abap
      importing
        is_node      type z2ui5_if_ajson_types=>ty_node
        is_node_type type ty_type_cache
        i_container_ref type ref to data
      raising
        z2ui5_cx_ajson_error
        cx_sy_conversion_no_number.

    methods get_node_type
      importing
        is_node            type z2ui5_if_ajson_types=>ty_node optional " Empty for root
        is_parent_type     type ty_type_cache optional
        i_container_ref    type ref to data optional
      returning
        value(rs_node_type) type ty_type_cache
      raising
        z2ui5_cx_ajson_error.

endclass.

class lcl_json_to_abap implementation.

  method constructor.
    mi_custom_mapping = ii_custom_mapping.
    mv_corresponding  = iv_corresponding.
  endmethod.

  method to_abap.

    data lr_ref type ref to data.

    clear c_container. " what about data/obj refs ?
    clear mt_node_type_cache.

    get reference of c_container into lr_ref.
    get reference of it_nodes into mr_nodes.

    get_node_type( i_container_ref = lr_ref ). " Pre-cache root node type

    any_to_abap(
      iv_path         = ''
      i_container_ref = lr_ref ).

  endmethod.

  method get_node_type.

    data lv_node_type_path type string.
    data lo_sdescr type ref to cl_abap_structdescr.
    data lo_tdescr type ref to cl_abap_tabledescr.
    data lo_ddescr type ref to cl_abap_datadescr.

    " Calculate type path
    if is_parent_type-type_kind = lif_kind=>table.
      lv_node_type_path = is_parent_type-type_path && '/-'. " table item type
    elseif is_parent_type-type_kind is not initial.
      lv_node_type_path = is_parent_type-type_path && '/' && is_node-name.
    endif. " For root node lv_node_type_path remains ''

    " Get or create cached
    read table mt_node_type_cache into rs_node_type with key type_path = lv_node_type_path.
    if sy-subrc <> 0.

      rs_node_type-type_path         = lv_node_type_path.

      if mi_custom_mapping is bound.
        rs_node_type-target_field_name = to_upper( mi_custom_mapping->to_abap(
          iv_path = is_node-path
          iv_name = is_node-name ) ).
        if rs_node_type-target_field_name is initial.
          rs_node_type-target_field_name = to_upper( is_node-name ).
        endif.
      else.
        rs_node_type-target_field_name = to_upper( is_node-name ).
      endif.

      case is_parent_type-type_kind.
        when lif_kind=>table.
          lo_tdescr ?= is_parent_type-dd.
          rs_node_type-dd = lo_tdescr->get_table_line_type( ).

        when lif_kind=>struct_flat or lif_kind=>struct_deep.
          lo_sdescr ?= is_parent_type-dd.
          lo_sdescr->get_component_type(
            exporting
              p_name      = rs_node_type-target_field_name
            receiving
              p_descr_ref = rs_node_type-dd
            exceptions
              component_not_found = 4 ).
          if sy-subrc <> 0.
            if mv_corresponding = abap_false.
              z2ui5_cx_ajson_error=>raise( |Path not found| ).
            else.
              clear rs_node_type.
              return.
            endif.
          endif.

        when ''. " Root node
          rs_node_type-dd ?= cl_abap_typedescr=>describe_by_data_ref( i_container_ref ).

        when others.
          z2ui5_cx_ajson_error=>raise( |Unexpected parent type| ).
      endcase.

      rs_node_type-type_kind         = rs_node_type-dd->type_kind. " for caching and cleaner uninitialized access
      if rs_node_type-type_kind = lif_kind=>table.
        lo_tdescr ?= rs_node_type-dd.
        if lo_tdescr->table_kind <> cl_abap_tabledescr=>tablekind_std.
          lo_ddescr = lo_tdescr->get_table_line_type( ).
          create data rs_node_type-tab_item_buf type handle lo_ddescr.
        endif.
      endif.

      insert rs_node_type into table mt_node_type_cache.
    endif.

  endmethod.

  method any_to_abap.

    data ls_node_type like line of mt_node_type_cache.
    data lx_ajson type ref to z2ui5_cx_ajson_error.
    data lx_root type ref to cx_root.
    data lr_target_field type ref to data.

    field-symbols <n> type z2ui5_if_ajson_types=>ty_node.
    field-symbols <parent_stdtab> type standard table.
    field-symbols <parent_anytab> type any table.
    field-symbols <parent_struc> type any.
    field-symbols <tab_item> type any.

    " Assign container
    case is_parent_type-type_kind.
      when lif_kind=>table.
        if is_parent_type-tab_item_buf is bound. " Indirect hint that table was sorted/hashed, see get_node_type.
          assign i_container_ref->* to <parent_anytab>.
          assert sy-subrc = 0.

          lr_target_field = is_parent_type-tab_item_buf. " For hashed/sorted table - same buffer for all children
          assign is_parent_type-tab_item_buf->* to <tab_item>.
          assert sy-subrc = 0.

        else.
          assign i_container_ref->* to <parent_stdtab>.
          assert sy-subrc = 0.
        endif.

      when lif_kind=>struct_flat or lif_kind=>struct_deep.
        assign i_container_ref->* to <parent_struc>.
        assert sy-subrc = 0.
    endcase.

    try.

      " array_index because stringified index goes in wrong order [1, 10, 2 ...]
      loop at mr_nodes->* assigning <n> using key array_index where path = iv_path.

        " Get or create type cache record
        if is_parent_type-type_kind <> lif_kind=>table or ls_node_type-type_kind is initial.
          " table records are the same, no need to refetch twice

          ls_node_type = get_node_type(
            is_node        = <n>
            is_parent_type = is_parent_type ).

          if mv_corresponding = abap_true and ls_node_type is initial.
            continue.
          endif.

        endif.

        " Validate node type
        if ls_node_type-type_kind = lif_kind=>data_ref or
           ls_node_type-type_kind = lif_kind=>object_ref.
          " TODO maybe in future
          z2ui5_cx_ajson_error=>raise( 'Cannot assign to ref' ).
        endif.

        " Find target field reference
        case is_parent_type-type_kind.
          when lif_kind=>table.
            if not ls_node_type-target_field_name co '0123456789'.
              " Does not affect anything actually but for integrity
              z2ui5_cx_ajson_error=>raise( 'Need index to access tables' ).
            endif.

            if is_parent_type-tab_item_buf is not bound. " Indirect hint that table was srt/hsh, see get_node_type
              append initial line to <parent_stdtab> reference into lr_target_field.
              assert sy-subrc = 0.
            endif.

          when lif_kind=>struct_flat or lif_kind=>struct_deep.
            field-symbols <field> type any.
            assign component ls_node_type-target_field_name of structure <parent_struc> to <field>.
            assert sy-subrc = 0.
            get reference of <field> into lr_target_field.

          when ''. " Root node
            lr_target_field = i_container_ref.

          when others.
            z2ui5_cx_ajson_error=>raise( 'Unexpected parent type' ).
        endcase.

        " Process value assignment
        case <n>-type.
          when z2ui5_if_ajson_types=>node_type-object.
            if ls_node_type-type_kind <> lif_kind=>struct_flat and
               ls_node_type-type_kind <> lif_kind=>struct_deep.
              z2ui5_cx_ajson_error=>raise( 'Expected structure' ).
            endif.
            any_to_abap(
              iv_path         = <n>-path && <n>-name && '/'
              is_parent_type  = ls_node_type
              i_container_ref = lr_target_field ).

          when z2ui5_if_ajson_types=>node_type-array.
            if not ls_node_type-type_kind = lif_kind=>table.
              z2ui5_cx_ajson_error=>raise( 'Expected table' ).
            endif.
            any_to_abap(
              iv_path         = <n>-path && <n>-name && '/'
              is_parent_type  = ls_node_type
              i_container_ref = lr_target_field ).

          when others.
            value_to_abap(
              is_node         = <n>
              is_node_type    = ls_node_type
              i_container_ref = lr_target_field ).
        endcase.

        if is_parent_type-tab_item_buf is bound. " Indirect hint that table was sorted/hashed, see get_node_type.
          try.
            insert <tab_item> into table <parent_anytab>.
            if sy-subrc <> 0.
              z2ui5_cx_ajson_error=>raise( 'Duplicate insertion' ).
            endif.
          catch cx_sy_itab_duplicate_key.
            z2ui5_cx_ajson_error=>raise( 'Duplicate insertion' ).
          endtry.
        endif.

      endloop.

    catch z2ui5_cx_ajson_error into lx_ajson.
      if lx_ajson->location is initial.
        lx_ajson->set_location( <n>-path && <n>-name ).
      endif.
      raise exception lx_ajson.
    catch cx_sy_conversion_no_number.
      z2ui5_cx_ajson_error=>raise(
        iv_msg = 'Source is not a number'
        iv_location = <n>-path && <n>-name ).
    catch cx_root into lx_root.
      z2ui5_cx_ajson_error=>raise(
        iv_msg = lx_root->get_text( )
        iv_location = <n>-path && <n>-name ).
    endtry.

  endmethod.

  method value_to_abap.

    field-symbols <container> type any.

    if is_node_type-type_kind ca lif_kind=>deep_targets.
      z2ui5_cx_ajson_error=>raise( |Unsupported target for value [{ is_node_type-type_kind }]| ).
    endif.

    assign i_container_ref->* to <container>.
    assert sy-subrc = 0.

    case is_node-type.
      when z2ui5_if_ajson_types=>node_type-null.
        " Do nothing
      when z2ui5_if_ajson_types=>node_type-boolean.
        " TODO: check type ?
        <container> = boolc( is_node-value = 'true' ).
      when z2ui5_if_ajson_types=>node_type-number.
        " TODO: check type ?
        <container> = is_node-value.

      when z2ui5_if_ajson_types=>node_type-string.
        " TODO: check type ?
        if is_node-value is not initial.
          if is_node_type-type_kind = lif_kind=>date.
            <container> = to_date( is_node-value ).
          elseif is_node_type-type_kind = lif_kind=>time.
            <container> = to_time( is_node-value ).
          elseif is_node_type-dd->absolute_name = '\TYPE=TIMESTAMP'
            or is_node_type-dd->absolute_name = '\TYPE=TIMESTAMPL'.
            <container> = to_timestamp( is_node-value ).
          elseif is_node_type-type_kind = lif_kind=>packed. " Number as a string, but not a timestamp
            <container> = is_node-value.
          else.
            <container> = is_node-value.
          endif.
        else.
          <container> = is_node-value.
        endif.
      when others.
        z2ui5_cx_ajson_error=>raise( |Unexpected JSON type [{ is_node-type }]| ).
    endcase.

  endmethod.

  method to_date.

    data lv_y type c length 4.
    data lv_m type c length 2.
    data lv_d type c length 2.

    find first occurrence of regex '^(\d{4})-(\d{2})-(\d{2})(T|$)' "#EC NOTEXT
      in iv_value
      submatches lv_y lv_m lv_d.
    if sy-subrc <> 0.
      z2ui5_cx_ajson_error=>raise( 'Unexpected date format' ).
    endif.
    concatenate lv_y lv_m lv_d into rv_result.

  endmethod.

  method to_timestamp.

    constants lc_utc type c length 6 value 'UTC'.
    constants lc_regex_ts_with_hour type string
      value `^(\d{4})-(\d{2})-(\d{2})(T)(\d{2}):(\d{2}):(\d{2})(\+)(\d{2}):(\d{2})`. "#EC NOTEXT
    constants lc_regex_ts_utc type string
      value `^(\d{4})-(\d{2})-(\d{2})(T)(\d{2}):(\d{2}):(\d{2})(Z|$)`. "#EC NOTEXT

    data:
      begin of ls_timestamp,
        year         type c length 4,
        month        type c length 2,
        day          type c length 2,
        t            type c length 1,
        hour         type c length 2,
        minute       type c length 2,
        second       type c length 2,
        local_sign   type c length 1,
        local_hour   type c length 2,
        local_minute type c length 2,
      end of ls_timestamp.

    data lv_date type d.
    data lv_time type t.
    data lv_seconds_conv type i.
    data lv_timestamp type timestampl.

    find first occurrence of regex lc_regex_ts_with_hour
      in iv_value submatches
        ls_timestamp-year ls_timestamp-month ls_timestamp-day ls_timestamp-t
        ls_timestamp-hour ls_timestamp-minute ls_timestamp-second
        ls_timestamp-local_sign ls_timestamp-local_hour ls_timestamp-local_minute.

    if sy-subrc = 0.

      lv_seconds_conv = ( ls_timestamp-local_hour * 3600 ) + ( ls_timestamp-local_minute * 60 ).

    else.

      find first occurrence of regex lc_regex_ts_utc
        in iv_value submatches
          ls_timestamp-year ls_timestamp-month ls_timestamp-day ls_timestamp-t
          ls_timestamp-hour ls_timestamp-minute ls_timestamp-second.

      if sy-subrc <> 0.
        z2ui5_cx_ajson_error=>raise( 'Unexpected timestamp format' ).
      endif.

    endif.

    concatenate ls_timestamp-year ls_timestamp-month ls_timestamp-day into lv_date.
    concatenate ls_timestamp-hour ls_timestamp-minute ls_timestamp-second into lv_time.

    convert date lv_date time lv_time into time stamp lv_timestamp time zone lc_utc.

    try.

      case ls_timestamp-local_sign.
        when '-'.
          lv_timestamp = cl_abap_tstmp=>add(
            tstmp = lv_timestamp
            secs  = lv_seconds_conv ).
        when '+'.
          lv_timestamp = cl_abap_tstmp=>subtractsecs(
            tstmp = lv_timestamp
            secs  = lv_seconds_conv ).
      endcase.

    catch cx_parameter_invalid_range cx_parameter_invalid_type.
      z2ui5_cx_ajson_error=>raise( 'Unexpected error calculating timestamp' ).
    endtry.

    if lv_timestamp is not initial.
      cl_abap_tstmp=>move(
        exporting
          tstmp_src = lv_timestamp
        importing
          tstmp_tgt = rv_result ).
    endif.

  endmethod.

  method to_time.

    data lv_h type c length 2.
    data lv_m type c length 2.
    data lv_s type c length 2.

    find first occurrence of regex '^(\d{2}):(\d{2}):(\d{2})(T|$)' "#EC NOTEXT
      in iv_value
      submatches lv_h lv_m lv_s.
    if sy-subrc <> 0.
      z2ui5_cx_ajson_error=>raise( 'Unexpected time format' ).
    endif.
    concatenate lv_h lv_m lv_s into rv_result.

  endmethod.

endclass.

**********************************************************************
* ABAP_TO_JSON
**********************************************************************

class lcl_abap_to_json definition final.
  public section.

    class-methods convert
      importing
        iv_data            type any
        is_prefix          type z2ui5_if_ajson_types=>ty_path_name optional
        iv_array_index     type i default 0
        ii_custom_mapping  type ref to z2ui5_if_ajson_mapping optional
        is_opts            type z2ui5_if_ajson=>ty_opts optional
        iv_item_order      type i default 0
      returning
        value(rt_nodes)   type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    class-methods insert_with_type
      importing
        iv_data            type any
        iv_type            type z2ui5_if_ajson_types=>ty_node_type
        is_prefix          type z2ui5_if_ajson_types=>ty_path_name optional
        iv_array_index     type i default 0
        ii_custom_mapping  type ref to z2ui5_if_ajson_mapping optional
        is_opts            type z2ui5_if_ajson=>ty_opts optional
        iv_item_order      type i default 0
      returning
        value(rt_nodes)   type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    class-methods format_date
      importing
        iv_date type d
      returning
        value(rv_str) type string.
    class-methods format_time
      importing
        iv_time type t
      returning
        value(rv_str) type string.
    class-methods format_timestamp
      importing
        iv_ts type timestamp
      returning
        value(rv_str) type string.

    class-methods class_constructor.

  private section.

    class-data gv_ajson_absolute_type_name type string.
    data mi_custom_mapping type ref to z2ui5_if_ajson_mapping.
    data mv_keep_item_order type abap_bool.
    data mv_format_datetime type abap_bool.

    methods convert_any
      importing
        iv_data type any
        io_type type ref to cl_abap_typedescr
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    methods convert_ajson
      importing
        io_json type ref to z2ui5_if_ajson
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    methods convert_value
      importing
        iv_data type any
        io_type type ref to cl_abap_typedescr
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    methods convert_ref
      importing
        iv_data type any
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    methods convert_struc
      importing
        iv_data type any
        io_type type ref to cl_abap_typedescr
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    methods convert_table
      importing
        iv_data type any
        io_type type ref to cl_abap_typedescr
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

    methods insert_value_with_type
      importing
        iv_data type any
        iv_type type z2ui5_if_ajson_types=>ty_node_type
        io_type type ref to cl_abap_typedescr
        is_prefix type z2ui5_if_ajson_types=>ty_path_name
        iv_index type i default 0
        iv_item_order type i default 0
      changing
        ct_nodes type z2ui5_if_ajson_types=>ty_nodes_tt
      raising
        z2ui5_cx_ajson_error.

endclass.

class lcl_abap_to_json implementation.

  method class_constructor.

    data lo_dummy type ref to z2ui5_cl_ajson.
    data lo_type type ref to cl_abap_refdescr.
    lo_type ?= cl_abap_typedescr=>describe_by_data( lo_dummy ).
    gv_ajson_absolute_type_name = lo_type->get_referenced_type( )->absolute_name.

  endmethod.

  method convert.

    data lo_type type ref to cl_abap_typedescr.
    data lo_converter type ref to lcl_abap_to_json.

    lo_type = cl_abap_typedescr=>describe_by_data( iv_data ).

    create object lo_converter.
    lo_converter->mi_custom_mapping  = ii_custom_mapping.
    lo_converter->mv_keep_item_order = is_opts-keep_item_order.
    lo_converter->mv_format_datetime = is_opts-format_datetime.

    lo_converter->convert_any(
      exporting
        iv_data       = iv_data
        io_type       = lo_type
        is_prefix     = is_prefix
        iv_index      = iv_array_index
        iv_item_order = iv_item_order
      changing
        ct_nodes = rt_nodes ).

  endmethod.

  method convert_any.

    case io_type->kind.
      when cl_abap_typedescr=>kind_elem.
        convert_value(
          exporting
            iv_data   = iv_data
            io_type   = io_type
            is_prefix = is_prefix
            iv_index  = iv_index
            iv_item_order = iv_item_order
          changing
            ct_nodes = ct_nodes ).

      when cl_abap_typedescr=>kind_struct.
        convert_struc(
          exporting
            iv_data   = iv_data
            io_type   = io_type
            is_prefix = is_prefix
            iv_index  = iv_index
            iv_item_order = iv_item_order
          changing
            ct_nodes = ct_nodes ).

      when cl_abap_typedescr=>kind_table.
        convert_table(
          exporting
            iv_data   = iv_data
            io_type   = io_type
            is_prefix = is_prefix
            iv_index  = iv_index
            iv_item_order = iv_item_order
          changing
            ct_nodes = ct_nodes ).

      when others.

        if io_type->type_kind = lif_kind=>data_ref or iv_data is initial.
          " Convert data references and initial references to other types (like ref to class or interface)
          " Initial references will result in "null"
          convert_ref(
            exporting
              iv_data   = iv_data
              is_prefix = is_prefix
              iv_index  = iv_index
              iv_item_order = iv_item_order
            changing
              ct_nodes = ct_nodes ).

        elseif io_type->type_kind = lif_kind=>object_ref
          and cl_abap_typedescr=>describe_by_object_ref( iv_data )->absolute_name = gv_ajson_absolute_type_name.
          convert_ajson(
            exporting
              io_json   = iv_data
              is_prefix = is_prefix
              iv_index  = iv_index
              iv_item_order = iv_item_order
            changing
              ct_nodes = ct_nodes ).
        else.
          z2ui5_cx_ajson_error=>raise( |Unsupported type [{ io_type->type_kind
            }] @{ is_prefix-path && is_prefix-name }| ).
        endif.

    endcase.

  endmethod.

  method convert_ajson.

    field-symbols <src> like line of ct_nodes.
    field-symbols <dst> like line of ct_nodes.

    if io_json is not bound.
      return.
    endif.

    loop at io_json->mt_json_tree assigning <src>.
      append <src> to ct_nodes assigning <dst>.

      if <dst>-path is initial and <dst>-name is initial. " root node
        <dst>-path  = is_prefix-path.
        <dst>-name  = is_prefix-name.
        <dst>-index = iv_index.
        <dst>-order = iv_item_order.
      else.
        <dst>-path = is_prefix-path && is_prefix-name && <dst>-path.
      endif.
    endloop.

  endmethod.

  method format_date.
    if iv_date is not initial.
      rv_str = iv_date+0(4) && '-' && iv_date+4(2) && '-' && iv_date+6(2).
    endif.
  endmethod.

  method format_time.
    if iv_time is not initial.
      rv_str = iv_time+0(2) && ':' && iv_time+2(2) && ':' && iv_time+4(2).
    endif.
  endmethod.

  method format_timestamp.

    constants lc_utc type c length 6 value 'UTC'.

    data lv_date type d.
    data lv_time type t.

    convert time stamp iv_ts time zone lc_utc
      into date lv_date time lv_time.

    rv_str =
      lv_date+0(4) && '-' && lv_date+4(2) && '-' && lv_date+6(2) &&
      'T' &&
      lv_time+0(2) && ':' && lv_time+2(2) && ':' && lv_time+4(2) &&
      'Z'.

  endmethod.

  method convert_value.

    data ls_node like line of ct_nodes.

    ls_node-path  = is_prefix-path.
    ls_node-name  = is_prefix-name.
    ls_node-index = iv_index.
    ls_node-order = iv_item_order.

    if ls_node-name is initial.
      ls_node-name  = is_prefix-name.
    endif.

    if io_type->absolute_name = '\TYPE-POOL=ABAP\TYPE=ABAP_BOOL'
        or io_type->absolute_name = '\TYPE=ABAP_BOOLEAN'
        or io_type->absolute_name = '\TYPE=XSDBOOLEAN'
        or io_type->absolute_name = '\TYPE=FLAG'
        or io_type->absolute_name = '\TYPE=XFELD'.
      ls_node-type = z2ui5_if_ajson_types=>node_type-boolean.
      if iv_data is not initial.
        ls_node-value = 'true'.
      else.
        ls_node-value = 'false'.
      endif.
    elseif io_type->absolute_name = '\TYPE=TIMESTAMP'.
      if mv_format_datetime = abap_true.
        ls_node-type  = z2ui5_if_ajson_types=>node_type-string.
        ls_node-value = format_timestamp( iv_data ).
      else.
        ls_node-type  = z2ui5_if_ajson_types=>node_type-number.
        ls_node-value = |{ iv_data }|.
      endif.
    elseif io_type->type_kind co lif_kind=>texts or
           io_type->type_kind co lif_kind=>binary or
           io_type->type_kind co lif_kind=>enum.
      ls_node-type = z2ui5_if_ajson_types=>node_type-string.
      ls_node-value = |{ iv_data }|.
    elseif io_type->type_kind = lif_kind=>date.
      ls_node-type = z2ui5_if_ajson_types=>node_type-string.
      if mv_format_datetime = abap_true.
        ls_node-value = format_date( iv_data ).
      else.
        ls_node-value = |{ iv_data }|.
      endif.
    elseif io_type->type_kind = lif_kind=>time.
      ls_node-type = z2ui5_if_ajson_types=>node_type-string.
      if mv_format_datetime = abap_true.
        ls_node-value = format_time( iv_data ).
      else.
        ls_node-value = |{ iv_data }|.
      endif.
    elseif io_type->type_kind co lif_kind=>numeric.
      ls_node-type = z2ui5_if_ajson_types=>node_type-number.
      ls_node-value = |{ iv_data }|.
    else.
      z2ui5_cx_ajson_error=>raise( |Unexpected elementary type [{
        io_type->type_kind }] @{ is_prefix-path && is_prefix-name }| ).
    endif.

    append ls_node to ct_nodes.

  endmethod.

  method convert_ref.

    data ls_node like line of ct_nodes.

    ls_node-path  = is_prefix-path.
    ls_node-name  = is_prefix-name.
    ls_node-index = iv_index.
    ls_node-order = iv_item_order.

    if mi_custom_mapping is bound.
      ls_node-name = mi_custom_mapping->to_json(
        iv_path = is_prefix-path
        iv_name = is_prefix-name ).
    endif.

    if ls_node-name is initial.
      ls_node-name  = is_prefix-name.
    endif.

    if iv_data is initial.
      ls_node-type  = z2ui5_if_ajson_types=>node_type-null.
      ls_node-value = 'null'.
    else.
      " TODO support data references
      z2ui5_cx_ajson_error=>raise( |Unexpected reference @{ is_prefix-path && is_prefix-name }| ).
    endif.

    append ls_node to ct_nodes.

  endmethod.

  method convert_struc.

    data lo_struc type ref to cl_abap_structdescr.
    data lt_comps type cl_abap_structdescr=>included_view.
    data ls_next_prefix like is_prefix.
    data lv_mapping_prefix_name like is_prefix-name.
    data lv_item_order type i.
    data ls_root like line of ct_nodes.

    field-symbols <root> like ls_root.
    field-symbols <c> like line of lt_comps.
    field-symbols <val> type any.

    " Object root

    ls_root-path  = is_prefix-path.
    ls_root-name  = is_prefix-name.
    ls_root-type  = z2ui5_if_ajson_types=>node_type-object.
    ls_root-index = iv_index.

    if mi_custom_mapping is bound.
      ls_root-name = mi_custom_mapping->to_json(
        iv_path = is_prefix-path
        iv_name = is_prefix-name ).
    endif.

    if ls_root-name is initial.
      ls_root-name  = is_prefix-name.
    endif.

    ls_root-order = iv_item_order.

    append ls_root to ct_nodes assigning <root>.

    " Object attributes

    lo_struc ?= io_type.
    lt_comps = lo_struc->get_included_view( ).
    " replaced call to get_components() with get_included_view() to avoid problems with suffixes in includes.
    " get_components is potentially much slower than lo_struc->components
    " but ! we still need it to identify booleans
    " and rtti seems to cache type descriptions really well (https://github.com/sbcgua/benchmarks.git)
    " the structures will be repeated in real life

    ls_next_prefix-path = is_prefix-path && <root>-name && '/'.

    loop at lt_comps assigning <c>.
      clear lv_mapping_prefix_name.

      <root>-children = <root>-children + 1.
      ls_next_prefix-name = to_lower( <c>-name ).
      assign component <c>-name of structure iv_data to <val>.
      assert sy-subrc = 0.

      if mi_custom_mapping is bound and <c>-type->kind = cl_abap_typedescr=>kind_elem.
        lv_mapping_prefix_name = mi_custom_mapping->to_json( iv_path = ls_next_prefix-path
                                                             iv_name = ls_next_prefix-name ).
      endif.

      if lv_mapping_prefix_name is not initial.
        ls_next_prefix-name = lv_mapping_prefix_name.
      endif.

      if mv_keep_item_order = abap_true.
        lv_item_order = <root>-children.
      endif.

      convert_any(
        exporting
          iv_data   = <val>
          io_type   = <c>-type
          is_prefix = ls_next_prefix
          iv_item_order = lv_item_order
        changing
          ct_nodes = ct_nodes ).

    endloop.

  endmethod.

  method convert_table.

    data lo_table type ref to cl_abap_tabledescr.
    data lo_ltype type ref to cl_abap_typedescr.
    data ls_next_prefix like is_prefix.
    data lv_tabix type sy-tabix.
    data ls_root like line of ct_nodes.

    field-symbols <root> like ls_root.
    field-symbols <tab> type any table.
    field-symbols <val> type any.

    " Array root

    ls_root-path  = is_prefix-path.
    ls_root-name  = is_prefix-name.
    ls_root-type  = z2ui5_if_ajson_types=>node_type-array.
    ls_root-index = iv_index.
    ls_root-order = iv_item_order.

    if mi_custom_mapping is bound.
      ls_root-name = mi_custom_mapping->to_json(
        iv_path = is_prefix-path
        iv_name = is_prefix-name ).
    endif.

    if ls_root-name is initial.
      ls_root-name  = is_prefix-name.
    endif.

    append ls_root to ct_nodes assigning <root>.

    " Array items

    lo_table ?= io_type.
    lo_ltype  = lo_table->get_table_line_type( ).

    ls_next_prefix-path = is_prefix-path && <root>-name && '/'.
    assign iv_data to <tab>.

    lv_tabix = 1.
    loop at <tab> assigning <val>.
      ls_next_prefix-name = to_lower( |{ lv_tabix }| ).

      convert_any(
        exporting
          iv_data   = <val>
          io_type   = lo_ltype
          is_prefix = ls_next_prefix
          iv_index  = <root>-children + 1
        changing
          ct_nodes = ct_nodes ).

      <root>-children = <root>-children + 1.
      lv_tabix = lv_tabix + 1.
    endloop.

  endmethod.

  method insert_with_type.

    data lo_type type ref to cl_abap_typedescr.
    data lo_converter type ref to lcl_abap_to_json.

    lo_type = cl_abap_typedescr=>describe_by_data( iv_data ).

    create object lo_converter.
    lo_converter->mi_custom_mapping  = ii_custom_mapping.
    lo_converter->mv_keep_item_order = is_opts-keep_item_order.
    lo_converter->mv_format_datetime = is_opts-format_datetime.

    lo_converter->insert_value_with_type(
      exporting
        iv_data       = iv_data
        iv_type       = iv_type
        io_type       = lo_type
        is_prefix     = is_prefix
        iv_index      = iv_array_index
        iv_item_order = iv_item_order
      changing
        ct_nodes = rt_nodes ).

  endmethod.

  method insert_value_with_type.

    data lv_prefix type string.
    data ls_node like line of ct_nodes.

    lv_prefix = is_prefix-path && is_prefix-name.
    if io_type->type_kind co lif_kind=>texts or
       io_type->type_kind co lif_kind=>date or
       io_type->type_kind co lif_kind=>time.
      if iv_type = z2ui5_if_ajson_types=>node_type-boolean and iv_data <> 'true' and iv_data <> 'false'.
        z2ui5_cx_ajson_error=>raise( |Unexpected boolean value [{ iv_data }] @{ lv_prefix }| ).
      elseif iv_type = z2ui5_if_ajson_types=>node_type-null and iv_data is not initial.
        z2ui5_cx_ajson_error=>raise( |Unexpected null value [{ iv_data }] @{ lv_prefix }| ).
      elseif iv_type = z2ui5_if_ajson_types=>node_type-number and iv_data cn '0123456789. E+-'.
        z2ui5_cx_ajson_error=>raise( |Unexpected numeric value [{ iv_data }] @{ lv_prefix }| ).
      elseif iv_type <> z2ui5_if_ajson_types=>node_type-string and iv_type <> z2ui5_if_ajson_types=>node_type-boolean
        and iv_type <> z2ui5_if_ajson_types=>node_type-null and iv_type <> z2ui5_if_ajson_types=>node_type-number.
        z2ui5_cx_ajson_error=>raise( |Unexpected type for value [{ iv_type },{ iv_data }] @{ lv_prefix }| ).
      endif.
    elseif io_type->type_kind co lif_kind=>numeric.
      if iv_type <> z2ui5_if_ajson_types=>node_type-number.
        z2ui5_cx_ajson_error=>raise( |Unexpected value for numeric [{ iv_data }] @{ lv_prefix }| ).
      endif.
    else.
      z2ui5_cx_ajson_error=>raise( |Unexpected type [{ io_type->type_kind }] @{ lv_prefix }| ).
    endif.

    ls_node-path  = is_prefix-path.
    ls_node-name  = is_prefix-name.
    ls_node-index = iv_index.
    ls_node-value = iv_data.
    ls_node-type  = iv_type.
    ls_node-order = iv_item_order.

    if mi_custom_mapping is bound.
      ls_node-name = mi_custom_mapping->to_json(
        iv_path = is_prefix-path
        iv_name = is_prefix-name ).
    endif.

    if ls_node-name is initial.
      ls_node-name  = is_prefix-name.
    endif.

    append ls_node to ct_nodes.

  endmethod.

endclass.

**********************************************************************
* MUTATOR INTERFACE
**********************************************************************

interface lif_mutator_runner.
  methods run
    importing
      it_source_tree type z2ui5_if_ajson_types=>ty_nodes_ts
    exporting
      et_dest_tree type z2ui5_if_ajson_types=>ty_nodes_ts
    raising
      z2ui5_cx_ajson_error.
endinterface.

**********************************************************************
* FILTER RUNNER
**********************************************************************

class lcl_filter_runner definition final.
  public section.
    interfaces lif_mutator_runner.
    class-methods new
      importing
        ii_filter type ref to z2ui5_if_ajson_filter
      returning
        value(ro_instance) type ref to lcl_filter_runner.
    methods constructor
      importing
        ii_filter type ref to z2ui5_if_ajson_filter.

  private section.
    data mi_filter type ref to z2ui5_if_ajson_filter.
    data mr_source_tree type ref to z2ui5_if_ajson_types=>ty_nodes_ts.
    data mr_dest_tree type ref to z2ui5_if_ajson_types=>ty_nodes_ts.

    methods walk
      importing
        iv_path type string
      changing
        cs_parent type z2ui5_if_ajson_types=>ty_node optional
      raising
        z2ui5_cx_ajson_error.

endclass.

class lcl_filter_runner implementation.

  method new.
    create object ro_instance exporting ii_filter = ii_filter.
  endmethod.

  method constructor.
    assert ii_filter is bound.
    mi_filter = ii_filter.
  endmethod.

  method lif_mutator_runner~run.

    clear et_dest_tree.
    get reference of it_source_tree into mr_source_tree.
    get reference of et_dest_tree into mr_dest_tree.

    walk( iv_path = '' ).

  endmethod.

  method walk.

    data ls_node type z2ui5_if_ajson_types=>ty_node.

    loop at mr_source_tree->* into ls_node where path = iv_path.
      case ls_node-type.
        when z2ui5_if_ajson_types=>node_type-boolean or z2ui5_if_ajson_types=>node_type-null
          or z2ui5_if_ajson_types=>node_type-number or z2ui5_if_ajson_types=>node_type-string.

          if mi_filter->keep_node( ls_node ) = abap_false.
            continue.
          endif.

        when z2ui5_if_ajson_types=>node_type-array or z2ui5_if_ajson_types=>node_type-object.

          if mi_filter->keep_node(
              is_node  = ls_node
              iv_visit = z2ui5_if_ajson_filter=>visit_type-open ) = abap_false.
            continue.
          endif.

          " Intentionally clear AFTER "open"
          clear ls_node-children.

          walk(
            exporting
              iv_path = iv_path && ls_node-name && `/`
            changing
              cs_parent    = ls_node ).

          if mi_filter->keep_node(
              is_node  = ls_node
              iv_visit = z2ui5_if_ajson_filter=>visit_type-close ) = abap_false.
            continue.
          endif.

        when others.
          z2ui5_cx_ajson_error=>raise( |Unexpected node type { ls_node-type }| ).
      endcase.

      if cs_parent is supplied.
        cs_parent-children = cs_parent-children + 1.
        if cs_parent-type = z2ui5_if_ajson_types=>node_type-array.
          ls_node-name  = |{ cs_parent-children }|.
          ls_node-index = cs_parent-children.
        endif.
      endif.
      insert ls_node into table mr_dest_tree->*.

    endloop.

  endmethod.

endclass.

**********************************************************************
* MAPPER RUNNER
**********************************************************************

class lcl_mapper_runner definition final.
  public section.
    interfaces lif_mutator_runner.
    class-methods new
      importing
        ii_mapper type ref to z2ui5_if_ajson_mapping
      returning
        value(ro_instance) type ref to lcl_mapper_runner.
    methods constructor
      importing
        ii_mapper type ref to z2ui5_if_ajson_mapping.

  private section.
    data mi_mapper type ref to z2ui5_if_ajson_mapping.
    data mr_source_tree type ref to z2ui5_if_ajson_types=>ty_nodes_ts.
    data mr_dest_tree type ref to z2ui5_if_ajson_types=>ty_nodes_ts.

    methods process_deep_node
      importing
        iv_path         type string
        iv_renamed_path type string
        iv_node_type    type z2ui5_if_ajson_types=>ty_node-type
      raising
        z2ui5_cx_ajson_error.

endclass.

class lcl_mapper_runner implementation.

  method new.
    create object ro_instance exporting ii_mapper = ii_mapper.
  endmethod.

  method constructor.
    assert ii_mapper is bound.
    mi_mapper = ii_mapper.
  endmethod.

  method lif_mutator_runner~run.

    field-symbols <root> like line of it_source_tree.

    read table it_source_tree with key path = `` name = `` assigning <root>.
    if sy-subrc <> 0
      or not ( <root>-type = z2ui5_if_ajson_types=>node_type-array or <root>-type = z2ui5_if_ajson_types=>node_type-object ).
      " empty or one-value-only tree
      et_dest_tree = it_source_tree.
      return.
    endif.

    clear et_dest_tree.
    get reference of it_source_tree into mr_source_tree.
    get reference of et_dest_tree into mr_dest_tree.
    insert <root> into table et_dest_tree.

    process_deep_node(
      iv_path         = `/`
      iv_renamed_path = `/`
      iv_node_type    = <root>-type ).

  endmethod.

  method process_deep_node.


    field-symbols <item> like line of mr_source_tree->*.
    data ls_renamed_node like <item>.

    loop at mr_source_tree->* assigning <item> where path = iv_path.
      ls_renamed_node = <item>.
      if iv_node_type <> z2ui5_if_ajson_types=>node_type-array.
        " don't rename array item names -> they are numeric index
        mi_mapper->rename_node(
          exporting
            is_node = <item>
          changing
            cv_name = ls_renamed_node-name ).
        if ls_renamed_node-name is initial.
          z2ui5_cx_ajson_error=>raise(
            iv_msg  = 'Renamed node name cannot be empty'
            is_node = <item> ).
        endif.
      endif.
      ls_renamed_node-path = iv_renamed_path.

      insert ls_renamed_node into table mr_dest_tree->*.
      if sy-subrc <> 0. " = 4 ?
        z2ui5_cx_ajson_error=>raise(
          iv_msg  = 'Renamed node has a duplicate'
          is_node = ls_renamed_node ).
      endif.

      " maybe also catch CX_SY_ITAB_DUPLICATE_KEY but secondary keys are not changed here, so not for now

      if <item>-type = z2ui5_if_ajson_types=>node_type-array or <item>-type = z2ui5_if_ajson_types=>node_type-object.
        process_deep_node(
          iv_path         = iv_path && <item>-name && `/`
          iv_renamed_path = iv_renamed_path && ls_renamed_node-name && `/`
          iv_node_type    = <item>-type ).
      endif.

    endloop.

  endmethod.

endclass.

**********************************************************************
* MUTATOR QUEUE
**********************************************************************

class lcl_mutator_queue definition final.
  public section.
    interfaces lif_mutator_runner.
    class-methods new
      returning
        value(ro_instance) type ref to lcl_mutator_queue.
    methods add
      importing
        ii_mutator type ref to lif_mutator_runner
      returning
        value(ro_self) type ref to lcl_mutator_queue.

  private section.
    data mt_queue TYPE STANDARD TABLE OF ref to lif_mutator_runner.

endclass.

class lcl_mutator_queue implementation.

  method add.
    if ii_mutator is bound.
      append ii_mutator to mt_queue.
    endif.
    ro_self = me.
  endmethod.

  method new.
    create object ro_instance.
  endmethod.

  method lif_mutator_runner~run.

    data li_mutator type ref to lif_mutator_runner.
    data lv_qsize type i.
    field-symbols <from> like it_source_tree.
    field-symbols <to> like it_source_tree.
    data lr_buf type ref to z2ui5_if_ajson_types=>ty_nodes_ts.

    lv_qsize = lines( mt_queue ).

    if lv_qsize = 0.
      et_dest_tree = it_source_tree.
      return.
    endif.

    loop at mt_queue into li_mutator.
      if sy-tabix = 1.
        assign it_source_tree to <from>.
      else.
        assign lr_buf->* to <from>.
      endif.

      if sy-tabix = lv_qsize.
        assign et_dest_tree to <to>.
      else.
        create data lr_buf.
        assign lr_buf->* to <to>.
      endif.

      li_mutator->run(
        exporting
          it_source_tree = <from>
        importing
          et_dest_tree = <to> ).
    endloop.

  endmethod.

endclass.
