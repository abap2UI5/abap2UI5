class z2ui5_cl_ajson definition
  public
  create public .

  public section.

    interfaces z2ui5_if_ajson .

    aliases:
      is_empty for z2ui5_if_ajson~is_empty,
      exists for z2ui5_if_ajson~exists,
      members for z2ui5_if_ajson~members,
      get for z2ui5_if_ajson~get,
      get_boolean for z2ui5_if_ajson~get_boolean,
      get_integer for z2ui5_if_ajson~get_integer,
      get_number for z2ui5_if_ajson~get_number,
      get_date for z2ui5_if_ajson~get_date,
      get_timestamp for z2ui5_if_ajson~get_timestamp,
      get_string for z2ui5_if_ajson~get_string,
      slice for z2ui5_if_ajson~slice,
      to_abap for z2ui5_if_ajson~to_abap,
      array_to_string_table for z2ui5_if_ajson~array_to_string_table.

    aliases:
      clear for z2ui5_if_ajson~clear,
      set for z2ui5_if_ajson~set,
      setx for z2ui5_if_ajson~setx,
      set_boolean for z2ui5_if_ajson~set_boolean,
      set_string for z2ui5_if_ajson~set_string,
      set_integer for z2ui5_if_ajson~set_integer,
      set_date for z2ui5_if_ajson~set_date,
      set_timestamp for z2ui5_if_ajson~set_timestamp,
      set_null for z2ui5_if_ajson~set_null,
      delete for z2ui5_if_ajson~delete,
      touch_array for z2ui5_if_ajson~touch_array,
      push for z2ui5_if_ajson~push,
      stringify for z2ui5_if_ajson~stringify.

    aliases:
      clone for z2ui5_if_ajson~clone,
      filter for z2ui5_if_ajson~filter,
      map for z2ui5_if_ajson~map.

    aliases:
      mt_json_tree for z2ui5_if_ajson~mt_json_tree,
      keep_item_order for z2ui5_if_ajson~keep_item_order,
      format_datetime for z2ui5_if_ajson~format_datetime,
      to_abap_corresponding_only for z2ui5_if_ajson~to_abap_corresponding_only,
      freeze for z2ui5_if_ajson~freeze.

    class-methods parse
      importing
        !iv_json            type string
        !iv_freeze          type abap_bool default abap_false
        !ii_custom_mapping  type ref to z2ui5_if_ajson_mapping optional
        !iv_keep_item_order type abap_bool default abap_false
      returning
        value(ro_instance) type ref to z2ui5_cl_ajson
      raising
        z2UI5_cx_ajson_error .

    class-methods create_empty " Might be deprecated, prefer using new( ) or create object
      importing
        !ii_custom_mapping type ref to z2ui5_if_ajson_mapping optional
        iv_keep_item_order type abap_bool default abap_false
        iv_format_datetime type abap_bool default abap_true
        iv_to_abap_corresponding_only type abap_bool default abap_false
      returning
        value(ro_instance) type ref to z2ui5_cl_ajson.

    " Experimental ! May change
    class-methods create_from " TODO, rename to 'from' ?
      importing
        !ii_source_json type ref to z2ui5_if_ajson
        !ii_filter type ref to z2ui5_if_ajson_filter optional " Might be deprecated, use filter() instead
        !ii_mapper type ref to z2ui5_if_ajson_mapping optional " Might be deprecated, use map() instead
      returning
        value(ro_instance) type ref to z2ui5_cl_ajson
      raising
        z2UI5_cx_ajson_error .

    methods constructor
      importing
        iv_keep_item_order type abap_bool default abap_false
        iv_format_datetime type abap_bool default abap_true
        iv_to_abap_corresponding_only type abap_bool default abap_false.
    class-methods new
      importing
        iv_keep_item_order type abap_bool default abap_false
        iv_format_datetime type abap_bool default abap_true
        iv_to_abap_corresponding_only type abap_bool default abap_false
      returning
        value(ro_instance) type ref to z2ui5_cl_ajson.

  protected section.

  private section.

    class-data go_float_regex type ref to cl_abap_regex.

    data ms_opts type z2ui5_if_ajson=>ty_opts.
    data mi_custom_mapping type ref to z2ui5_if_ajson_mapping. " DEPRECATED, will be removed

    methods get_item
      importing
        iv_path        type string
      returning
        value(rv_item) type ref to z2ui5_if_ajson_types=>ty_node.
    methods prove_path_exists
      importing
        iv_path              type string
      returning
        value(rr_end_node) type ref to z2ui5_if_ajson_types=>ty_node
      raising
        z2UI5_cx_ajson_error.
    methods delete_subtree
      importing
        iv_path           type string
        iv_name           type string
        ir_parent         type ref to z2ui5_if_ajson_types=>ty_node optional
      returning
        value(rs_top_node) type z2ui5_if_ajson_types=>ty_node.
    methods read_only_watchdog
      raising
        z2UI5_cx_ajson_error.
ENDCLASS.



CLASS Z2UI5_CL_AJSON IMPLEMENTATION.


  method constructor.
    ms_opts-keep_item_order = iv_keep_item_order.
    ms_opts-to_abap_corresponding_only = iv_to_abap_corresponding_only.
    format_datetime( iv_format_datetime ).
  endmethod.


  method create_empty.
    create object ro_instance
      exporting
        iv_to_abap_corresponding_only = iv_to_abap_corresponding_only
        iv_format_datetime = iv_format_datetime
        iv_keep_item_order = iv_keep_item_order.
    ro_instance->mi_custom_mapping = ii_custom_mapping.
  endmethod.


  method create_from.

    data lo_mutator_queue type ref to lcl_mutator_queue.

    if ii_source_json is not bound.
      z2UI5_cx_ajson_error=>raise( 'Source not bound' ).
    endif.

    create object ro_instance
      exporting
        iv_to_abap_corresponding_only = ii_source_json->opts( )-to_abap_corresponding_only
        iv_format_datetime = ii_source_json->opts( )-format_datetime
        iv_keep_item_order = ii_source_json->opts( )-keep_item_order.

    if ii_filter is not bound and ii_mapper is not bound.
      ro_instance->mt_json_tree = ii_source_json->mt_json_tree.
    else.
      create object lo_mutator_queue.
      if ii_mapper is bound.
        " Mapping goes first. But maybe it should be a freely definable queue of processors ?
        lo_mutator_queue->add( lcl_mapper_runner=>new( ii_mapper ) ).
      endif.
      if ii_filter is bound.
        lo_mutator_queue->add( lcl_filter_runner=>new( ii_filter ) ).
      endif.
      lo_mutator_queue->lif_mutator_runner~run(
        exporting
          it_source_tree = ii_source_json->mt_json_tree
        importing
          et_dest_tree = ro_instance->mt_json_tree ).
    endif.

  endmethod.


  method delete_subtree.

    data lv_parent_path type string.
    data lr_parent like ir_parent.

    read table mt_json_tree into rs_top_node
      with key
        path = iv_path
        name = iv_name.
    if sy-subrc <> 0.
      return. " Not found ? nothing to delete !
    endif.

    delete mt_json_tree index sy-tabix. " where path = iv_path and name = iv_name.

    if rs_top_node-children > 0. " only for objects and arrays
      lv_parent_path = iv_path && iv_name && '/*'.
      delete mt_json_tree where path cp lv_parent_path.
    endif.

    " decrement parent children
    if ir_parent is supplied.
      ir_parent->children = ir_parent->children - 1.
    else.
      lr_parent = get_item( iv_path ).
      if lr_parent is not initial.
        lr_parent->children = lr_parent->children - 1.
      endif.
    endif.

  endmethod.


  method get_item.

    field-symbols <item> like line of mt_json_tree.
    data ls_path_name type z2ui5_if_ajson_types=>ty_path_name.
    ls_path_name = lcl_utils=>split_path( iv_path ).

    read table mt_json_tree
      assigning <item>
      with key
        path = ls_path_name-path
        name = ls_path_name-name.
    if sy-subrc = 0.
      get reference of <item> into rv_item.
    endif.

  endmethod.


  method new.
    create object ro_instance
      exporting
        iv_to_abap_corresponding_only = iv_to_abap_corresponding_only
        iv_format_datetime = iv_format_datetime
        iv_keep_item_order = iv_keep_item_order.
  endmethod.


  method parse.

    data lo_parser type ref to lcl_json_parser.

    create object ro_instance.
    create object lo_parser.
    ro_instance->mt_json_tree = lo_parser->parse(
      iv_json            = iv_json
      iv_keep_item_order = iv_keep_item_order ).
    ro_instance->mi_custom_mapping = ii_custom_mapping.
    ro_instance->ms_opts-keep_item_order = iv_keep_item_order.

    if iv_freeze = abap_true.
      ro_instance->freeze( ).
    endif.

  endmethod.


  method prove_path_exists.

    data lt_path type string_table.
    data lr_node_parent like rr_end_node.
    data lv_cur_path type string.
    data lv_cur_name type string.
    data ls_new_node like line of mt_json_tree.

    split iv_path at '/' into table lt_path.
    delete lt_path where table_line is initial.

    do.
      lr_node_parent = rr_end_node.
      read table mt_json_tree reference into rr_end_node
        with key
          path = lv_cur_path
          name = lv_cur_name.
      if sy-subrc <> 0. " New node, assume it is always object as it has a named child, use touch_array to init array
        clear ls_new_node.
        if lr_node_parent is not initial. " if has parent
          lr_node_parent->children = lr_node_parent->children + 1.
          if lr_node_parent->type = z2ui5_if_ajson_types=>node_type-array.
            ls_new_node-index = lcl_utils=>validate_array_index(
              iv_path  = lv_cur_path
              iv_index = lv_cur_name ).
          endif.
        endif.
        ls_new_node-path = lv_cur_path.
        ls_new_node-name = lv_cur_name.
        ls_new_node-type = z2ui5_if_ajson_types=>node_type-object.
        insert ls_new_node into table mt_json_tree reference into rr_end_node.
      endif.
      lv_cur_path = lv_cur_path && lv_cur_name && '/'.
      read table lt_path index sy-index into lv_cur_name.
      if sy-subrc <> 0.
        exit. " no more segments
      endif.
    enddo.

  endmethod.


  method read_only_watchdog.
    if ms_opts-read_only = abap_true.
      z2UI5_cx_ajson_error=>raise( 'This json instance is read only' ).
    endif.
  endmethod.


  method z2ui5_if_ajson~array_to_string_table.

    data lv_normalized_path type string.
    data lr_node type ref to z2ui5_if_ajson_types=>ty_node.
    field-symbols <item> like line of mt_json_tree.

    lv_normalized_path = lcl_utils=>normalize_path( iv_path ).
    lr_node = get_item( iv_path ).

    if lr_node is initial.
      z2UI5_cx_ajson_error=>raise( |Path not found: { iv_path }| ).
    endif.
    if lr_node->type <> z2ui5_if_ajson_types=>node_type-array.
      z2UI5_cx_ajson_error=>raise( |Array expected at: { iv_path }| ).
    endif.

    loop at mt_json_tree assigning <item> where path = lv_normalized_path.
      case <item>-type.
        when z2ui5_if_ajson_types=>node_type-number or z2ui5_if_ajson_types=>node_type-string.
          append <item>-value to rt_string_table.
        when z2ui5_if_ajson_types=>node_type-null.
          append '' to rt_string_table.
        when z2ui5_if_ajson_types=>node_type-boolean.
          data lv_tmp type string.
          if <item>-value = 'true'.
            lv_tmp = abap_true.
          else.
            clear lv_tmp.
          endif.
          append lv_tmp to rt_string_table.
        when others.
          z2UI5_cx_ajson_error=>raise( |Cannot convert [{ <item>-type
            }] to string at [{ <item>-path }{ <item>-name }]| ).
      endcase.
    endloop.

  endmethod.


  method z2ui5_if_ajson~clear.

    read_only_watchdog( ).
    clear mt_json_tree.

  endmethod.


  method z2ui5_if_ajson~clone.
    ri_json = create_from( me ).
  endmethod.


  method z2ui5_if_ajson~delete.

    read_only_watchdog( ).

    data ls_split_path type z2ui5_if_ajson_types=>ty_path_name.
    ls_split_path = lcl_utils=>split_path( iv_path ).

    delete_subtree(
      iv_path = ls_split_path-path
      iv_name = ls_split_path-name ).

    ri_json = me.

  endmethod.


  method z2ui5_if_ajson~exists.
    rv_exists = boolc( get_item( iv_path ) is not initial ).
  endmethod.


  method z2ui5_if_ajson~filter.
    ri_json = create_from(
      ii_source_json = me
      ii_filter      = ii_filter ).
  endmethod.


  method z2ui5_if_ajson~format_datetime.
    ms_opts-format_datetime = iv_use_iso.
    ri_json = me.
  endmethod.


  method z2ui5_if_ajson~freeze.
    ms_opts-read_only = abap_true.
  endmethod.


  method z2ui5_if_ajson~get.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    lr_item = get_item( iv_path ).
    if lr_item is not initial.
      rv_value = lr_item->value.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_boolean.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    lr_item = get_item( iv_path ).
    if lr_item is initial or lr_item->type = z2ui5_if_ajson_types=>node_type-null.
      return.
    elseif lr_item->type = z2ui5_if_ajson_types=>node_type-boolean.
      rv_value = boolc( lr_item->value = 'true' ).
    elseif lr_item->value is not initial.
      rv_value = abap_true.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_date.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    data lv_y type c length 4.
    data lv_m type c length 2.
    data lv_d type c length 2.

    lr_item = get_item( iv_path ).

    if lr_item is not initial and lr_item->type = z2ui5_if_ajson_types=>node_type-string.
      find first occurrence of regex '^(\d{4})-(\d{2})-(\d{2})(T|$)' "#EC NOTEXT
        in lr_item->value
        submatches lv_y lv_m lv_d.
      concatenate lv_y lv_m lv_d into rv_value.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_integer.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    lr_item = get_item( iv_path ).
    if lr_item is not initial and lr_item->type = z2ui5_if_ajson_types=>node_type-number.
      rv_value = lr_item->value.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_node_type.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    lr_item = get_item( iv_path ).
    if lr_item is not initial.
      rv_node_type = lr_item->type.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_number.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    lr_item = get_item( iv_path ).
    if lr_item is not initial and lr_item->type = z2ui5_if_ajson_types=>node_type-number.
      rv_value = lr_item->value.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_string.

    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.
    lr_item = get_item( iv_path ).
    if lr_item is not initial and lr_item->type <> z2ui5_if_ajson_types=>node_type-null.
      rv_value = lr_item->value.
    endif.

  endmethod.


  method z2ui5_if_ajson~get_timestamp.

    data lo_to_abap type ref to lcl_json_to_abap.
    data lr_item type ref to z2ui5_if_ajson_types=>ty_node.

    lr_item = get_item( iv_path ).

    if lr_item is initial.
      return.
    endif.

    create object lo_to_abap.

    try.
      rv_value = lo_to_abap->to_timestamp( lr_item->value ).
    catch z2UI5_cx_ajson_error.
      return.
    endtry.

  endmethod.


  method z2ui5_if_ajson~is_empty.
    rv_yes = boolc( lines( mt_json_tree ) = 0 ).
  endmethod.


  method z2ui5_if_ajson~keep_item_order.
    ms_opts-keep_item_order = abap_true.
    ri_json = me.
  endmethod.


  method z2ui5_if_ajson~map.
    ri_json = create_from(
      ii_source_json = me
      ii_mapper      = ii_mapper ).
  endmethod.


  method z2ui5_if_ajson~members.

    data lv_normalized_path type string.
    field-symbols <item> like line of mt_json_tree.

    lv_normalized_path = lcl_utils=>normalize_path( iv_path ).

    loop at mt_json_tree assigning <item> where path = lv_normalized_path.
      append <item>-name to rt_members.
    endloop.

  endmethod.


  method z2ui5_if_ajson~opts.
    rs_opts = ms_opts.
  endmethod.


  method z2ui5_if_ajson~push.

    data lr_parent type ref to z2ui5_if_ajson_types=>ty_node.
    data lr_new_node type ref to z2ui5_if_ajson_types=>ty_node.

    read_only_watchdog( ).

    lr_parent = get_item( iv_path ).

    if lr_parent is initial.
      z2UI5_cx_ajson_error=>raise( |Path [{ iv_path }] does not exist| ).
    endif.

    if lr_parent->type <> z2ui5_if_ajson_types=>node_type-array.
      z2UI5_cx_ajson_error=>raise( |Path [{ iv_path }] is not array| ).
    endif.

    data lt_new_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    data ls_new_path type z2ui5_if_ajson_types=>ty_path_name.
    data lv_new_index type i.

    lv_new_index     = lr_parent->children + 1.
    ls_new_path-path = lcl_utils=>normalize_path( iv_path ).
    ls_new_path-name = |{ lv_new_index }|.

    lt_new_nodes = lcl_abap_to_json=>convert(
      is_opts            = ms_opts
      iv_data   = iv_val
      is_prefix = ls_new_path ).
    read table lt_new_nodes index 1 reference into lr_new_node. " assume first record is the array item - not ideal !
    assert sy-subrc = 0.
    lr_new_node->index = lv_new_index.

    " update data
    lr_parent->children = lv_new_index.
    insert lines of lt_new_nodes into table mt_json_tree.

    ri_json = me.

  endmethod.


  method z2ui5_if_ajson~set.

    data ls_split_path type z2ui5_if_ajson_types=>ty_path_name.
    data lr_parent type ref to z2ui5_if_ajson_types=>ty_node.
    data ls_deleted_node type z2ui5_if_ajson_types=>ty_node.
    data lv_item_order type z2ui5_if_ajson_types=>ty_node-order.

    read_only_watchdog( ).

    ri_json = me.

    if iv_val is initial and iv_ignore_empty = abap_true and iv_node_type is initial.
      return. " nothing to assign
    endif.

    if iv_node_type is not initial
      and iv_node_type <> z2ui5_if_ajson_types=>node_type-boolean and iv_node_type <> z2ui5_if_ajson_types=>node_type-null
      and iv_node_type <> z2ui5_if_ajson_types=>node_type-number and iv_node_type <> z2ui5_if_ajson_types=>node_type-string.
      z2UI5_cx_ajson_error=>raise( |Unexpected type { iv_node_type }| ).
    endif.

    ls_split_path = lcl_utils=>split_path( iv_path ).
    if ls_split_path is initial. " Assign root, exceptional processing
      if iv_node_type is not initial.
        mt_json_tree = lcl_abap_to_json=>insert_with_type(
          is_opts            = ms_opts
          iv_data            = iv_val
          iv_type            = iv_node_type
          is_prefix          = ls_split_path
          ii_custom_mapping  = mi_custom_mapping ).
      else.
        mt_json_tree = lcl_abap_to_json=>convert(
          is_opts            = ms_opts
          iv_data            = iv_val
          is_prefix          = ls_split_path
          ii_custom_mapping  = mi_custom_mapping ).
      endif.
      return.
    endif.

    " Ensure whole path exists
    lr_parent = prove_path_exists( ls_split_path-path ).
    assert lr_parent is not initial.

    " delete if exists with subtree
    ls_deleted_node = delete_subtree(
      ir_parent = lr_parent
      iv_path   = ls_split_path-path
      iv_name   = ls_split_path-name ).
    lv_item_order = ls_deleted_node-order.

    " convert to json
    data lt_new_nodes type z2ui5_if_ajson_types=>ty_nodes_tt.
    data lv_array_index type i.

    if lr_parent->type = z2ui5_if_ajson_types=>node_type-array.
      lv_array_index = lcl_utils=>validate_array_index(
        iv_path  = ls_split_path-path
        iv_index = ls_split_path-name ).
    elseif lr_parent->type = z2ui5_if_ajson_types=>node_type-object
      and lv_item_order = 0 and ms_opts-keep_item_order = abap_true.
      lv_item_order = lr_parent->children + 1.
    endif.

    if iv_node_type is not initial.
      lt_new_nodes = lcl_abap_to_json=>insert_with_type(
        is_opts            = ms_opts
        iv_item_order      = lv_item_order
        iv_data            = iv_val
        iv_type            = iv_node_type
        iv_array_index     = lv_array_index
        is_prefix          = ls_split_path
        ii_custom_mapping  = mi_custom_mapping ).
    else.
      lt_new_nodes = lcl_abap_to_json=>convert(
        is_opts            = ms_opts
        iv_item_order      = lv_item_order
        iv_data            = iv_val
        iv_array_index     = lv_array_index
        is_prefix          = ls_split_path
        ii_custom_mapping  = mi_custom_mapping ).
    endif.

    " update nodes
    if lines( lt_new_nodes ) > 0.
      lr_parent->children = lr_parent->children + 1.
      insert lines of lt_new_nodes into table mt_json_tree.
    endif.

  endmethod.


  method z2ui5_if_ajson~setx.

    data lv_path type string.
    data lv_val type string.
    data lv_int type i.
    data lv_dec type decfloat34.
    data lv_last type i.

    if iv_param is initial.
      ri_json = me.
      return.
    endif.

    split iv_param at ':' into lv_path lv_val.
    condense lv_path.
    condense lv_val.

    if lv_val is initial.
      ri_json = me.
      return. " Hmm ? or empty string ? or null ?
    endif.

    if go_float_regex is not bound.
      create object go_float_regex exporting pattern = '^([1-9][0-9]*|0)\.[0-9]+$'.
      " expects fractional, because ints are detected separately
    endif.

    if lv_val = 'null'.
      z2ui5_if_ajson~set_null( lv_path ).
    elseif lv_val = 'true'.
      z2ui5_if_ajson~set_boolean(
        iv_path = lv_path
        iv_val  = abap_true ).
    elseif lv_val = 'false'.
      z2ui5_if_ajson~set_boolean(
        iv_path = lv_path
        iv_val  = abap_false ).
    elseif lv_val co '0123456789'.
      lv_int = lv_val.
      z2ui5_if_ajson~set_integer(
        iv_path = lv_path
        iv_val  = lv_int ).
    elseif lv_val co '0123456789.' and go_float_regex->create_matcher( text = lv_val )->match( ) = abap_true.
      lv_dec = lv_val.
      z2ui5_if_ajson~set(
        iv_path = lv_path
        iv_val  = lv_dec ).
    elseif lv_val+0(1) = '{' or lv_val+0(1) = '['.
      "Expect object/array, but no further checks, parser will catch errors
      z2ui5_if_ajson~set(
        iv_path = lv_path
        iv_val  = parse(
          iv_json = lv_val
          iv_keep_item_order = ms_opts-keep_item_order ) ).
    else. " string
      lv_last = strlen( lv_val ) - 1.
      if lv_val+0(1) = '"' and lv_val+lv_last(1) = '"'.
        lv_val = substring(
          val = lv_val
          off = 1
          len = lv_last - 1 ).
      endif.
      z2ui5_if_ajson~set_string(
        iv_path = lv_path
        iv_val  = lv_val ).
    endif.

    ri_json = me.

  endmethod.


  method z2ui5_if_ajson~set_boolean.

    ri_json = me.

    data lv_bool type abap_bool.
    lv_bool = boolc( iv_val is not initial ).
    z2ui5_if_ajson~set(
      iv_ignore_empty = abap_false
      iv_path = iv_path
      iv_val  = lv_bool ).

  endmethod.


  method z2ui5_if_ajson~set_date.

    ri_json = me.

    data lv_val type string.
    lv_val = lcl_abap_to_json=>format_date( iv_val ).

    z2ui5_if_ajson~set(
      iv_ignore_empty = abap_false
      iv_path = iv_path
      iv_val  = lv_val ).

  endmethod.


  method z2ui5_if_ajson~set_integer.

    ri_json = me.

    z2ui5_if_ajson~set(
      iv_ignore_empty = abap_false
      iv_path = iv_path
      iv_val  = iv_val ).

  endmethod.


  method z2ui5_if_ajson~set_null.

    ri_json = me.

    data lv_null_ref type ref to data.
    z2ui5_if_ajson~set(
      iv_ignore_empty = abap_false
      iv_path = iv_path
      iv_val  = lv_null_ref ).

  endmethod.


  method z2ui5_if_ajson~set_string.

    ri_json = me.

    data lv_val type string.
    lv_val = iv_val.
    z2ui5_if_ajson~set(
      iv_ignore_empty = abap_false
      iv_path = iv_path
      iv_val  = lv_val ).

  endmethod.


  method z2ui5_if_ajson~set_timestamp.

    ri_json = me.

    data lv_timestamp_iso type string.
    lv_timestamp_iso = lcl_abap_to_json=>format_timestamp( iv_val ).

    z2ui5_if_ajson~set(
      iv_ignore_empty = abap_false
      iv_path = iv_path
      iv_val  = lv_timestamp_iso ).

  endmethod.


  method z2ui5_if_ajson~slice.

    data lo_section         type ref to z2ui5_cl_ajson.
    data ls_item            like line of mt_json_tree.
    data lv_normalized_path type string.
    data ls_path_parts      type z2ui5_if_ajson_types=>ty_path_name.
    data lv_path_len        type i.
    data lv_path_pattern    type string.

    create object lo_section.
    lv_normalized_path = lcl_utils=>normalize_path( iv_path ).
    lv_path_len        = strlen( lv_normalized_path ).
    ls_path_parts      = lcl_utils=>split_path( lv_normalized_path ).

    read table mt_json_tree into ls_item
      with key path = ls_path_parts-path name = ls_path_parts-name.
    if sy-subrc <> 0.
      return.
    endif.

    clear: ls_item-path, ls_item-name, ls_item-order. " this becomes a new root
    insert ls_item into table lo_section->mt_json_tree.

    lv_path_pattern = lv_normalized_path && `*`.

    loop at mt_json_tree into ls_item where path cp lv_path_pattern.

      ls_item-path = substring( val = ls_item-path off = lv_path_len - 1 ). " less closing '/'
      insert ls_item into table lo_section->mt_json_tree.

    endloop.

    ri_json = lo_section.

  endmethod.


  method z2ui5_if_ajson~stringify.

    rv_json = lcl_json_serializer=>stringify(
      it_json_tree       = mt_json_tree
      iv_keep_item_order = ms_opts-keep_item_order
      iv_indent          = iv_indent ).

  endmethod.


  method z2ui5_if_ajson~touch_array.

    data lr_node type ref to z2ui5_if_ajson_types=>ty_node.
    data ls_deleted_node type z2ui5_if_ajson_types=>ty_node.
    data ls_new_node like line of mt_json_tree.
    data ls_split_path type z2ui5_if_ajson_types=>ty_path_name.

    read_only_watchdog( ).

    ls_split_path = lcl_utils=>split_path( iv_path ).
    if ls_split_path is initial. " Assign root, exceptional processing
      ls_new_node-path = ls_split_path-path.
      ls_new_node-name = ls_split_path-name.
      ls_new_node-type = z2ui5_if_ajson_types=>node_type-array.
      insert ls_new_node into table mt_json_tree.
      return.
    endif.

    if iv_clear = abap_true.
      ls_deleted_node = delete_subtree(
        iv_path = ls_split_path-path
        iv_name = ls_split_path-name ).
    else.
      lr_node = get_item( iv_path ).
    endif.

    if lr_node is initial. " Or node was cleared

      data lr_parent type ref to z2ui5_if_ajson_types=>ty_node.
      lr_parent = prove_path_exists( ls_split_path-path ).
      assert lr_parent is not initial.

      lr_parent->children = lr_parent->children + 1.

      ls_new_node-path = ls_split_path-path.
      ls_new_node-name = ls_split_path-name.
      ls_new_node-type = z2ui5_if_ajson_types=>node_type-array.

      if ms_opts-keep_item_order = abap_true and ls_deleted_node is not initial.
        ls_new_node-order = ls_deleted_node-order.
      endif.

      insert ls_new_node into table mt_json_tree.

    elseif lr_node->type <> z2ui5_if_ajson_types=>node_type-array.
      z2UI5_cx_ajson_error=>raise( |Path [{ iv_path }] already used and is not array| ).
    endif.

    ri_json = me.

  endmethod.


  method z2ui5_if_ajson~to_abap.

    data lo_to_abap type ref to lcl_json_to_abap.

    clear ev_container.
    create object lo_to_abap
      exporting
        iv_corresponding  = boolc( iv_corresponding = abap_true or ms_opts-to_abap_corresponding_only = abap_true )
        ii_custom_mapping = mi_custom_mapping.

    lo_to_abap->to_abap(
      exporting
        it_nodes    = z2ui5_if_ajson~mt_json_tree
      changing
        c_container = ev_container ).

  endmethod.


  method z2ui5_if_ajson~to_abap_corresponding_only.
    ms_opts-to_abap_corresponding_only = iv_enable.
    ri_json = me.
  endmethod.
ENDCLASS.
