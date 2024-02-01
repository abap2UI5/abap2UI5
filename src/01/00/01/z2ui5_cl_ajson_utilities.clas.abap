class z2ui5_cl_ajson_utilities definition
  public
  create public .

  public section.

    class-methods new
      returning
        value(ro_instance) type ref to z2ui5_cl_ajson_utilities.
    methods diff
      importing
        !iv_json_a            type string optional
        !iv_json_b            type string optional
        !io_json_a            type ref to z2ui5_if_ajson optional
        !io_json_b            type ref to z2ui5_if_ajson optional
        !iv_keep_empty_arrays type abap_bool default abap_false
      exporting
        !eo_insert            type ref to z2ui5_if_ajson
        !eo_delete            type ref to z2ui5_if_ajson
        !eo_change            type ref to z2ui5_if_ajson
      raising
        z2UI5_cx_ajson_error .
    methods merge
      importing
        !iv_json_a            type string optional
        !iv_json_b            type string optional
        !io_json_a            type ref to z2ui5_if_ajson optional
        !io_json_b            type ref to z2ui5_if_ajson optional
        !iv_keep_empty_arrays type abap_bool default abap_false
      returning
        value(ro_json)        type ref to z2ui5_if_ajson
      raising
        z2UI5_cx_ajson_error .
    methods sort
      importing
        !iv_json         type string optional
        !io_json         type ref to z2ui5_if_ajson optional
      returning
        value(rv_sorted) type string
      raising
        z2UI5_cx_ajson_error .
    methods is_equal
      importing
        !iv_json_a            type string optional
        !iv_json_b            type string optional
        !ii_json_a            type ref to z2ui5_if_ajson optional
        !ii_json_b            type ref to z2ui5_if_ajson optional
      returning
        value(rv_yes) type abap_bool
      raising
        z2UI5_cx_ajson_error .

  protected section.

  private section.

    data mo_json_a type ref to z2ui5_if_ajson .
    data mo_json_b type ref to z2ui5_if_ajson .
    data mo_insert type ref to z2ui5_if_ajson .
    data mo_delete type ref to z2ui5_if_ajson .
    data mo_change type ref to z2ui5_if_ajson .

    methods normalize_input
      importing
        !iv_json       type string optional
        !io_json       type ref to z2ui5_if_ajson optional
      returning
        value(ro_json) type ref to z2ui5_if_ajson
      raising
        z2UI5_cx_ajson_error .
    methods diff_a_b
      importing
        !iv_path type string
      raising
        z2UI5_cx_ajson_error .
    methods diff_b_a
      importing
        !iv_path  type string
        !iv_array type abap_bool default abap_false
      raising
        z2UI5_cx_ajson_error .
    methods delete_empty_nodes
      importing
        !io_json              type ref to z2ui5_if_ajson
        !iv_keep_empty_arrays type abap_bool
      raising
        z2UI5_cx_ajson_error .
ENDCLASS.



CLASS Z2UI5_CL_AJSON_UTILITIES IMPLEMENTATION.


  method delete_empty_nodes.

    data ls_json_tree like line of io_json->mt_json_tree.
    data lv_done type abap_bool.

    do.
      lv_done = abap_true.

      if iv_keep_empty_arrays = abap_false.
        loop at io_json->mt_json_tree into ls_json_tree
          where type = z2ui5_if_ajson_types=>node_type-array and children = 0.

          io_json->delete( ls_json_tree-path && ls_json_tree-name ).

        endloop.
        if sy-subrc = 0.
          lv_done = abap_false.
        endif.
      endif.

      loop at io_json->mt_json_tree into ls_json_tree
        where type = z2ui5_if_ajson_types=>node_type-object and children = 0.

        io_json->delete( ls_json_tree-path && ls_json_tree-name ).

      endloop.
      if sy-subrc = 0.
        lv_done = abap_false.
      endif.

      if lv_done = abap_true.
        exit. " nothing else to delete
      endif.
    enddo.

  endmethod.


  method diff.

    mo_json_a = normalize_input(
      iv_json = iv_json_a
      io_json = io_json_a ).

    mo_json_b = normalize_input(
      iv_json = iv_json_b
      io_json = io_json_b ).

    mo_insert = z2ui5_cl_ajson=>create_empty( ).
    mo_delete = z2ui5_cl_ajson=>create_empty( ).
    mo_change = z2ui5_cl_ajson=>create_empty( ).

    diff_a_b( '/' ).
    diff_b_a( '/' ).

    eo_insert ?= mo_insert.
    eo_delete ?= mo_delete.
    eo_change ?= mo_change.

    delete_empty_nodes(
      io_json              = eo_insert
      iv_keep_empty_arrays = iv_keep_empty_arrays ).
    delete_empty_nodes(
      io_json              = eo_delete
      iv_keep_empty_arrays = iv_keep_empty_arrays ).
    delete_empty_nodes(
      io_json              = eo_change
      iv_keep_empty_arrays = iv_keep_empty_arrays ).

  endmethod.


  method diff_a_b.

    data:
      lv_path_a type string,
      lv_path_b type string.

    field-symbols:
      <node_a> like line of mo_json_a->mt_json_tree,
      <node_b> like line of mo_json_a->mt_json_tree.

    loop at mo_json_a->mt_json_tree assigning <node_a> where path = iv_path.
      lv_path_a = <node_a>-path && <node_a>-name && '/'.

      read table mo_json_b->mt_json_tree assigning <node_b>
        with table key path = <node_a>-path name = <node_a>-name.
      if sy-subrc = 0.
        lv_path_b = <node_b>-path && <node_b>-name && '/'.

        if <node_a>-type = <node_b>-type.
          case <node_a>-type.
            when z2ui5_if_ajson_types=>node_type-array.
              mo_insert->touch_array( lv_path_a ).
              mo_change->touch_array( lv_path_a ).
              mo_delete->touch_array( lv_path_a ).
              diff_a_b( lv_path_a ).
            when z2ui5_if_ajson_types=>node_type-object.
              diff_a_b( lv_path_a ).
            when others.
              if <node_a>-value <> <node_b>-value.
                " save as changed value
                mo_change->set(
                  iv_path      = lv_path_b
                  iv_val       = <node_b>-value
                  iv_node_type = <node_b>-type ).
              endif.
          endcase.
        else.
          " save changed type as delete + insert
          case <node_a>-type.
            when z2ui5_if_ajson_types=>node_type-array.
              mo_delete->touch_array( lv_path_a ).
              diff_a_b( lv_path_a ).
            when z2ui5_if_ajson_types=>node_type-object.
              diff_a_b( lv_path_a ).
            when others.
              mo_delete->set(
                iv_path      = lv_path_a
                iv_val       = <node_a>-value
                iv_node_type = <node_a>-type ).
          endcase.
          case <node_b>-type.
            when z2ui5_if_ajson_types=>node_type-array.
              mo_insert->touch_array( lv_path_b ).
              diff_b_a( lv_path_b ).
            when z2ui5_if_ajson_types=>node_type-object.
              diff_b_a( lv_path_b ).
            when others.
              mo_insert->set(
                iv_path      = lv_path_b
                iv_val       = <node_b>-value
                iv_node_type = <node_b>-type ).
          endcase.
        endif.
      else.
        " save as delete
        case <node_a>-type.
          when z2ui5_if_ajson_types=>node_type-array.
            mo_delete->touch_array( lv_path_a ).
            diff_a_b( lv_path_a ).
          when z2ui5_if_ajson_types=>node_type-object.
            diff_a_b( lv_path_a ).
          when others.
            mo_delete->set(
              iv_path      = lv_path_a
              iv_val       = <node_a>-value
              iv_node_type = <node_a>-type ).
        endcase.
      endif.
    endloop.

  endmethod.


  method diff_b_a.

    data lv_path type string.

    field-symbols <node_b> like line of mo_json_b->mt_json_tree.

    loop at mo_json_b->mt_json_tree assigning <node_b> where path = iv_path.
      lv_path = <node_b>-path && <node_b>-name && '/'.

      case <node_b>-type.
        when z2ui5_if_ajson_types=>node_type-array.
          mo_insert->touch_array( lv_path ).
          diff_b_a(
            iv_path  = lv_path
            iv_array = abap_true ).
        when z2ui5_if_ajson_types=>node_type-object.
          diff_b_a( lv_path ).
        when others.
          if iv_array = abap_false.
            read table mo_json_a->mt_json_tree transporting no fields
              with table key path = <node_b>-path name = <node_b>-name.
            if sy-subrc <> 0.
              " save as insert
              mo_insert->set(
                iv_path      = lv_path
                iv_val       = <node_b>-value
                iv_node_type = <node_b>-type ).
            endif.
          else.
            read table mo_insert->mt_json_tree transporting no fields
              with key path = <node_b>-path value = <node_b>-value.
            if sy-subrc <> 0.
              " save as new array value
              mo_insert->push(
                iv_path = iv_path
                iv_val  = <node_b>-value ).
            endif.
          endif.
      endcase.
    endloop.

  endmethod.


  method is_equal.

    data li_ins type ref to z2ui5_if_ajson.
    data li_del type ref to z2ui5_if_ajson.
    data li_mod type ref to z2ui5_if_ajson.

    diff(
      exporting
        iv_json_a = iv_json_a
        iv_json_b = iv_json_b
        io_json_a = ii_json_a
        io_json_b = ii_json_b
      importing
        eo_insert = li_ins
        eo_delete = li_del
        eo_change = li_mod ).

    rv_yes = boolc(
      li_ins->is_empty( ) = abap_true and
      li_del->is_empty( ) = abap_true and
      li_mod->is_empty( ) = abap_true ).

  endmethod.


  method merge.

    mo_json_a = normalize_input(
      iv_json = iv_json_a
      io_json = io_json_a ).

    mo_json_b = normalize_input(
      iv_json = iv_json_b
      io_json = io_json_b ).

    " Start with first JSON...
    mo_insert = mo_json_a.

    " ...and add all nodes from second JSON
    diff_b_a( '/' ).

    ro_json ?= mo_insert.

    delete_empty_nodes(
      io_json              = ro_json
      iv_keep_empty_arrays = iv_keep_empty_arrays ).

  endmethod.


  method new.
    create object ro_instance.
  endmethod.


  method normalize_input.

    if boolc( iv_json is initial ) = boolc( io_json is initial ).
      z2UI5_cx_ajson_error=>raise( 'Either supply JSON string or instance, but not both' ).
    endif.

    if iv_json is not initial.
      ro_json = z2ui5_cl_ajson=>parse( iv_json ).
    elseif io_json is not initial.
      ro_json = io_json.
    else.
      z2UI5_cx_ajson_error=>raise( 'Supply either JSON string or instance' ).
    endif.

  endmethod.


  method sort.

    data lo_json type ref to z2ui5_if_ajson.

    lo_json = normalize_input(
      iv_json = iv_json
      io_json = io_json ).

    " Nodes are parsed into a sorted table, so no explicit sorting required
    rv_sorted = lo_json->stringify( 2 ).

  endmethod.
ENDCLASS.
