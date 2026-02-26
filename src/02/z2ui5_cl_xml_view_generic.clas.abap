CLASS z2ui5_cl_xml_view_generic DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.

    CLASS-METHODS factory
      IMPORTING
        t_ns          TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    CLASS-METHODS factory_popup
      IMPORTING
        t_ns          TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    CLASS-METHODS factory_plain
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS constructor.

    METHODS add
      IMPORTING
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        p             TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS leaf
      IMPORTING
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        p             TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS up
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS get
      IMPORTING
        n             TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS child
      IMPORTING
        index         TYPE i
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_generic.

    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.

    METHODS xml_get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    DATA mv_name   TYPE string.
    DATA mv_ns     TYPE string.
    DATA mt_prop   TYPE SORTED TABLE OF z2ui5_if_types=>ty_s_name_value WITH NON-UNIQUE KEY n.

    DATA mt_ns     TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
    DATA mo_root   TYPE REF TO z2ui5_cl_xml_view_generic.
    DATA mo_previous TYPE REF TO z2ui5_cl_xml_view_generic.
    DATA mo_parent TYPE REF TO z2ui5_cl_xml_view_generic.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view_generic WITH EMPTY KEY.

    METHODS xml_get_parts
      CHANGING
        ct_parts TYPE string_table.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_xml_view_generic IMPLEMENTATION.

  METHOD constructor.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mt_prop   = VALUE #( BASE result->mt_prop
                                 (  n = `displayBlock`   v = `true` )
                                 (  n = `height`         v = `100%` ) ).

    result->mv_name   = `View`.
    result->mv_ns     = `mvc`.
    result->mo_root   = result.
    result->mo_parent = result.

    INSERT VALUE #( n = `xmlns`
                    v = `sap.m` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:mvc`
                    v = `sap.ui.core.mvc` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:core`
                    v = `sap.ui.core` ) INTO TABLE result->mt_prop.

  ENDMETHOD.

  METHOD factory_popup.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mv_name   = `FragmentDefinition`.
    result->mv_ns     = `core`.
    result->mo_root   = result.
    result->mo_parent = result.

    INSERT VALUE #( n = `xmlns`
                    v = `sap.m` ) INTO TABLE result->mt_prop.
    INSERT VALUE #( n = `xmlns:core`
                    v = `sap.ui.core` ) INTO TABLE result->mt_prop.

  ENDMETHOD.

  METHOD factory_plain.

    result = NEW #( ).

    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.

  METHOD add.

    TRY.
        INSERT CONV #( ns ) INTO TABLE mo_root->mt_ns.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    DATA(lo_child) = NEW z2ui5_cl_xml_view_generic( ).
    lo_child->mv_name   = n.
    lo_child->mv_ns     = ns.
    lo_child->mt_prop   = p.
    lo_child->mo_parent = me.
    lo_child->mo_root   = mo_root.
    INSERT lo_child INTO TABLE mt_child.

    mo_root->mo_previous = lo_child.
    result = lo_child.

  ENDMETHOD.

  METHOD leaf.

    result = me.
    add( n  = n
         ns = ns
         p  = p ).

  ENDMETHOD.

  METHOD up.
    result = mo_parent.
  ENDMETHOD.

  METHOD root.
    result = mo_root.
  ENDMETHOD.

  METHOD get.

    IF n IS INITIAL.
      result = mo_root->mo_previous.
      RETURN.
    ENDIF.

    IF mo_parent->mv_name = n.
      result = mo_parent.
    ELSE.
      result = mo_parent->get( n ).
    ENDIF.

  ENDMETHOD.

  METHOD child.
    result = mt_child[ index ].
  ENDMETHOD.

  METHOD stringify.

    DATA lt_parts TYPE string_table.
    root( )->xml_get_parts( CHANGING ct_parts = lt_parts ).
    result = concat_lines_of( lt_parts ).

  ENDMETHOD.

  METHOD xml_get.

    DATA lt_parts TYPE string_table.
    xml_get_parts( CHANGING ct_parts = lt_parts ).
    result = concat_lines_of( lt_parts ).

  ENDMETHOD.

  METHOD xml_get_parts.

    DATA lt_prop TYPE HASHED TABLE OF z2ui5_if_types=>ty_s_name_value WITH UNIQUE KEY n.

    IF me = mo_root.

      lt_prop = VALUE #(
          ( n = `z2ui5`             v = `z2ui5` )
          ( n = `layout`            v = `sap.ui.layout` )
          ( n = `networkgraph`      v = `sap.suite.ui.commons.networkgraph` )
          ( n = `nglayout`          v = `sap.suite.ui.commons.networkgraph.layout` )
          ( n = `ngcustom`          v = `sap.suite.ui.commons.sample.NetworkGraphCustomRendering` )
          ( n = `table`             v = `sap.ui.table` )
          ( n = `template`          v = `http://schemas.sap.com/sapui5/extension/sap.ui.core.template/1` )
          ( n = `customData`        v = `http://schemas.sap.com/sapui5/extension/sap.ui.core.CustomData/1` )
          ( n = `f`                 v = `sap.f` )
          ( n = `columnmenu`        v = `sap.m.table.columnmenu` )
          ( n = `card`              v = `sap.f.cards` )
          ( n = `dnd`               v = `sap.ui.core.dnd` )
          ( n = `dnd-grid`          v = `sap.f.dnd` )
          ( n = `grid`              v = `sap.ui.layout.cssgrid` )
          ( n = `form`              v = `sap.ui.layout.form` )
          ( n = `editor`            v = `sap.ui.codeeditor` )
          ( n = `mchart`            v = `sap.suite.ui.microchart` )
          ( n = `smartFilterBar`    v = `sap.ui.comp.smartfilterbar` )
          ( n = `smartVariantManagement`    v = `sap.ui.comp.smartvariants` )
          ( n = `smartTable`        v = `sap.ui.comp.smarttable` )
          ( n = `webc`              v = `sap.ui.webc.main` )
          ( n = `uxap`              v = `sap.uxap` )
          ( n = `sap`               v = `sap` )
          ( n = `text`              v = `sap.ui.richtexteditor` )
          ( n = `html`              v = `http://www.w3.org/1999/xhtml` )
          ( n = `fb`                v = `sap.ui.comp.filterbar` )
          ( n = `u`                 v = `sap.ui.unified` )
          ( n = `gantt`             v = `sap.gantt.simple` )
          ( n = `axistime`          v = `sap.gantt.axistime` )
          ( n = `config`            v = `sap.gantt.config` )
          ( n = `shapes`            v = `sap.gantt.simple.shapes` )
          ( n = `commons`           v = `sap.suite.ui.commons` )
          ( n = `si`                v = `sap.suite.ui.commons.statusindicator` )
          ( n = `vm`                v = `sap.ui.comp.variants` )
          ( n = `viz`               v = `sap.viz.ui5.controls` )
          ( n = `viz.data`          v = `sap.viz.ui5.data` )
          ( n = `viz.feeds`         v = `sap.viz.ui5.controls.common.feeds` )
          ( n = `vk`                v = `sap.ui.vk` )
          ( n = `vbm`               v = `sap.ui.vbm` )
          ( n = `ndc`               v = `sap.ndc` )
          ( n = `svm`               v = `sap.ui.comp.smartvariants` )
          ( n = `flvm`              v = `sap.ui.fl.variants` )
          ( n = `p13n`              v = `sap.m.p13n` )
          ( n = `upload`            v = `sap.m.upload` )
          ( n = `fl`                v = `sap.ui.fl` )
          ( n = `plugins`           v = `sap.m.plugins` )
          ( n = `tnt`               v = `sap.tnt` )
          ( n = `mdc`               v = `sap.ui.mdc` )
          ( n = `trm`               v = `sap.ui.table.rowmodes` )
          ( n = `smi`               v = `sap.ui.comp.smartmultiinput` )
          ( n = `ie`                v = `sap.suite.ui.commons.imageeditor` ) ).

      LOOP AT mt_ns REFERENCE INTO DATA(lr_ns) WHERE table_line IS NOT INITIAL  "#EC CI_SORTSEQ
                                                     AND table_line <> `mvc`
                                                     AND table_line <> `core`.
        TRY.
            DATA(ls_prop) = lt_prop[ n = lr_ns->* ].
            INSERT VALUE #( n = |xmlns:{ ls_prop-n }|
                            v = ls_prop-v ) INTO TABLE mt_prop.
          CATCH cx_root.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING val = |XML_VIEW_ERROR_NO_NAMESPACE_FOUND_FOR:  { lr_ns->* }|.
        ENDTRY.
      ENDLOOP.

    ENDIF.

    DATA(lv_tmp2) = COND #( WHEN mv_ns <> `` THEN |{ mv_ns }:| ).
    DATA(lv_tmp3) = REDUCE string( INIT val = `` FOR row IN mt_prop WHERE ( v <> `` ) "#EC CI_SORTSEQ
                          NEXT val = |{ val } { row-n }="{ escape( val    = COND string( WHEN row-v = abap_true
                                                                                         THEN `true`
                                                                                         ELSE row-v )
                                                                   format = cl_abap_format=>e_xml_attr ) }"| ).

    IF mt_child IS INITIAL.
      APPEND | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }/>| TO ct_parts.
      RETURN.
    ENDIF.

    APPEND | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }>| TO ct_parts.

    LOOP AT mt_child INTO DATA(lr_child).
      CAST z2ui5_cl_xml_view_generic( lr_child )->xml_get_parts( CHANGING ct_parts = ct_parts ).
    ENDLOOP.

    APPEND |</{ lv_tmp2 }{ mv_name }>| TO ct_parts.

  ENDMETHOD.

ENDCLASS.
