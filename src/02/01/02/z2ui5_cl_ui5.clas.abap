CLASS z2ui5_cl_ui5 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS _factory
      IMPORTING check_popup   TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _go_up
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _go_root
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _go_new
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _add
      IMPORTING n             TYPE clike
                ns            TYPE clike
                t_p           TYPE z2ui5_if_types=>ty_t_name_value OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _add_p
      IMPORTING n             TYPE clike
                v             TYPE clike
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _add_c
      IMPORTING val           TYPE clike
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _ns
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5.

    METHODS _ns_ndc
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ndc.

    METHODS _ns_m
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS _ns_ui
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

    METHODS _ns_suite
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_suite.

    METHODS _ns_z2ui5
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_z2ui5.

    METHODS _ns_html
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_html.

    METHODS _ns_webc
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS constructor
      IMPORTING node TYPE REF TO z2ui5_cl_ui5_tree_xml OPTIONAL.

    METHODS _stringify
      RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA _node TYPE REF TO z2ui5_cl_ui5_tree_xml.

    CLASS-METHODS _2xml
      IMPORTING obj           TYPE REF TO z2ui5_cl_ui5
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS _2bool
      IMPORTING val           TYPE any
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5 IMPLEMENTATION.
  METHOD constructor.
    IF node IS NOT BOUND.
      _node = NEW #( ).
      _node->mo_root = _node.
    ELSE.
      _node = node.
    ENDIF.
  ENDMETHOD.

  METHOD _2bool.
    result = z2ui5_cl_util=>boolean_abap_2_json( val ).
  ENDMETHOD.

  METHOD _2xml.

    DATA lt_prop TYPE z2ui5_if_types=>ty_t_name_value.
    lt_prop = VALUE #( ( n = ``          v = `sap.m` )
                       ( n = `f`         v = `sap.f` )
                       ( n = `ndc`       v = `sap.ndc` )
                       ( n = `tnt`       v = `sap.tnt` )
                       ( n = `mvc`       v = `sap.ui.core.mvc` )
                       ( n = `core`      v = `sap.ui.core` )
                       ( n = `form`      v = `sap.ui.layout.form` )
                       ( n = `l`         v = `sap.ui.layout` )
                       ( n = `t`         v = `sap.ui.table` )
                       ( n = `webc`      v = `sap.ui.webc.main` )
                       ( n = `fl`        v = `sap.ui.fl` )
                       ( n = `vk`        v = `sap.ui.vk` )
                       ( n = `vbm`       v = `sap.ui.vbm` )
                       ( n = `z2ui5`     v = `z2ui5` )
                       ( n = `mchart`    v = `sap.suite.ui.microchart` )
                       ( n = `editor`    v = `sap.ui.codeeditor` )
                       ( n = `wf`        v = `sap.ui.webc.fiori` )
                       ( n = `wm`        v = `sap.ui.webc.main` )
                       ( n = `html`      v = `http://www.w3.org/1999/xhtml` )
*                       ( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` )
*                       ( n = `core:require` v = `{ URLHelper: 'sap/m/library/URLHelper' }` )
*                       ( n = `xmlns:webc`      v = `sap.ui.webc.main` )
                       ( n = `xmlns:uxap`      v = `sap.uxap` )
                       ( n = `xmlns:text`      v = `sap.ui.richtexteditor` )
                       ( n = `xmlns:fb`        v = `sap.ui.comp.filterbar` )
                       ( n = `xmlns:u`         v = `sap.ui.unified` )
                       ( n = `xmlns:gantt`     v = `sap.gantt.simple` )
                       ( n = `xmlns:axistime`  v = `sap.gantt.axistime` )
                       ( n = `xmlns:config`    v = `sap.gantt.config` )
                       ( n = `xmlns:shapes`    v = `sap.gantt.simple.shapes` )
                       ( n = `xmlns:commons`   v = `sap.suite.ui.commons` )
                       ( n = `xmlns:vm`        v = `sap.ui.comp.variants` )
                       ( n = `xmlns:viz`        v = `sap.viz.ui5.controls` )
                       ( n = `xmlns:svm`       v = `sap.ui.comp.smartvariants` )
                       ( n = `xmlns:flvm`      v = `sap.ui.fl.variants` )
                       ( n = `xmlns:p13n`      v = `sap.m.p13n` )
                       ( n = `xmlns:upload`    v = `sap.m.upload` ) ).

    IF obj->_node = obj->_node->mo_root.

      LOOP AT obj->_node->mt_ns INTO DATA(lv_ns_tmp).
        TRY.
            DATA(ls_prop) = lt_prop[ v = lv_ns_tmp ].
            ls_prop-n = `xmlns` && COND #( WHEN ls_prop-n IS NOT INITIAL THEN `:` && ls_prop-n ).
            INSERT ls_prop INTO TABLE obj->_node->mt_prop.

          CATCH cx_root.

            DATA(lv_text) = COND #( WHEN lv_ns_tmp IS INITIAL THEN `XML_VIEW_NOT_VALID_NAMESPACE_EMPTY`
                ELSE `XML_VIEW_NOT_VALID_NAMESPACE_NOT_FOUND failure: ` && lv_ns_tmp ).

            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING
                val = lv_text.
        ENDTRY.
      ENDLOOP.

    ENDIF.

    DATA(lv_ns) = lt_prop[ v = obj->_node->mv_ns ]-n.
    lv_ns = COND #( WHEN lv_ns <> `` THEN |{ lv_ns }:| ).

    DATA(lv_element) = obj->_node->mv_name.
    DATA(lv_prop) = REDUCE #( INIT val = `` FOR row IN obj->_node->mt_prop
                       NEXT val = |{ val } { row-n }="{ escape(
                                                            val    = COND #( WHEN row-v = abap_true
                                                                             THEN `true`
                                                                             ELSE row-v )
                                                            format = cl_abap_format=>e_xml_attr ) }"| ).

    result = |{ result }<{ lv_ns }{ lv_element }{ lv_prop }|.

    IF obj->_node->mt_child IS INITIAL AND obj->_node->mv_content IS INITIAL.
      result = |{ result }/>|.
      RETURN.
    ENDIF.

    result = |{ result }>|.

    IF obj->_node->mv_content IS NOT INITIAL.
      result = result && obj->_node->mv_content.
      result = |{ result }</{ lv_ns }{ lv_element }>|.
      RETURN.
    ENDIF.

    LOOP AT obj->_node->mt_child INTO DATA(lr_child).
      DATA(lo_child) = NEW z2ui5_cl_ui5( lr_child ).
      result = result && _2xml( lo_child ).
    ENDLOOP.

    result = |{ result }</{ lv_ns }{ lv_element }>|.
  ENDMETHOD.

  METHOD _add.
    TRY.
        INSERT CONV #( ns ) INTO TABLE _node->mo_root->mt_ns.
      CATCH cx_root.
    ENDTRY.

    DATA(lo_node) = NEW z2ui5_cl_ui5_tree_xml( ).
    DATA(result2) = NEW z2ui5_cl_ui5( lo_node ).
    result2->_node->mv_name = n.
    result2->_node->mv_ns   = ns.
    result2->_node->mt_prop = t_p.
    DELETE result2->_node->mt_prop WHERE v = ``.
    result2->_node->mo_parent = _node.
    result2->_node->mo_root   = _node->mo_root.
    INSERT result2->_node INTO TABLE _node->mt_child.

    _node->mo_root->mo_previous = result2->_node.
    result = result2.
  ENDMETHOD.

  METHOD _add_p.
    INSERT VALUE #( n = n v = v ) INTO TABLE _node->mt_prop.
    result = me.
  ENDMETHOD.

  METHOD _factory.
    result = NEW #( ).

    DATA(lv_n) = COND #( WHEN check_popup = abap_true THEN `FragmentDefinition` ELSE `View` ).
    DATA(lv_ns) = COND #( WHEN check_popup = abap_true THEN `sap.ui.core` ELSE `sap.ui.core.mvc` ).

    result->_node->mv_name = lv_n.
    result->_node->mv_ns = lv_ns.
    INSERT lv_ns INTO TABLE result->_node->mo_root->mt_ns.
    "( n = lv_n ns  = lv_ns ).

    IF check_popup = abap_false.
      result->_add_p( n = `displayBlock`
                      v = `true` ).
      result->_add_p( n = `height`
                      v = `100%` ).
    ENDIF.

    result->_node->mt_ns   = result->_node->mo_root->mt_ns.
    result->_node->mo_root = result->_node.
  ENDMETHOD.

  METHOD _go_new.
    result = NEW #( _node->mo_root->mo_previous ).
  ENDMETHOD.

  METHOD _go_root.
    result = NEW #( _node->mo_root ).
  ENDMETHOD.

  METHOD _go_up.
    IF _node = _node->mo_root.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `XML_VIEW_PARSER_ERROR - go_up on root element not possible`.
    ENDIF.
    result = NEW #( _node->mo_parent ).
  ENDMETHOD.

  METHOD _ns.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _ns_html.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _ns_webc.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _ns_ndc.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _ns_m.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _ns_ui.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _ns_z2ui5.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _stringify.
    DATA(lo_node) = NEW z2ui5_cl_ui5( _node->mo_root ).
    result = _2xml( lo_node ).
  ENDMETHOD.

  METHOD _ns_suite.
    result = NEW #( _node ).
  ENDMETHOD.

  METHOD _add_c.
    _node->mv_content = val.
    result = me.
  ENDMETHOD.

ENDCLASS.
