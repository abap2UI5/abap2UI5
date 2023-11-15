CLASS z2ui5_cl_view DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS _factory
      IMPORTING
        check_popup   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _go_up
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _go_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _go_new
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _add
      IMPORTING
        n             TYPE clike
        ns            TYPE clike OPTIONAL
        t_p           TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _add_p
      IMPORTING
        n             TYPE clike
        v             TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _ns_ndc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ndc.

    METHODS _ns_m
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_m.

    METHODS _ns_ui
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

    METHODS _ns_zcc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

    METHODS constructor
      IMPORTING
        node TYPE REF TO object OPTIONAL.

    METHODS _stringify
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    CLASS-METHODS _2xml
      IMPORTING
        obj           TYPE REF TO z2ui5_cl_view
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS _2bool
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
    DATA _node TYPE REF TO lcl_view_node.

ENDCLASS.



CLASS z2ui5_cl_view IMPLEMENTATION.


  METHOD constructor.

    IF node IS NOT BOUND.
      me->_node = NEW #( ).
      me->_node->mo_root = me->_node.
    ELSE.
      me->_node = CAST #( node ).
    ENDIF.

  ENDMETHOD.


  METHOD _2bool.

    result = z2ui5_cl_fw_utility=>boolean_abap_2_json( val ).

  ENDMETHOD.


  METHOD _2xml.

    IF obj->_node->mv_name = `ZZPLAIN`.
      result = obj->_node->mt_prop[ n = `VALUE` ]-v.
      RETURN.
    ENDIF.

    DATA lt_prop TYPE z2ui5_if_client=>ty_t_name_value.
    lt_prop = VALUE #(
                   ( n = ``          v = `sap.m` )
                   ( n = `f`         v = `sap.f` )
                   ( n = `ndc`       v = `sap.ndc` )
                   ( n = `tnt`       v = `sap.tnt` )
                   ( n = `mvc`       v = `sap.ui.core.mvc` )
                   ( n = `core`      v = `sap.ui.core` )
                   ( n = `form`      v = `sap.ui.layout.form` )
                   ( n = `l`         v = `sap.ui.layout` )
                   ( n = `t`         v = `sap.ui.table` )
                   ( n = `fl`        v = `sap.ui.fl` )
                   ( n = `vk`        v = `sap.ui.vk` )
                   ( n = `vbm`       v = `sap.ui.vbm` )
                   ( n = `z2ui5`     v = `z2ui5` )
*                       ( n = `core:require` v = `{ MessageToast: 'sap/m/MessageToast' }` )
*                       ( n = `core:require` v = `{ URLHelper: 'sap/m/library/URLHelper' }` )
                    ( n = `xmlns:editor`    v = `sap.ui.codeeditor` )
                    ( n = `xmlns:mchart`    v = `sap.suite.ui.microchart` )
                    ( n = `xmlns:webc`      v = `sap.ui.webc.main` )
                    ( n = `xmlns:uxap`      v = `sap.uxap` )
                    ( n = `xmlns:text`      v = `sap.ui.richtexteditor` )
                    ( n = `xmlns:html`      v = `http://www.w3.org/1999/xhtml` )
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

        DATA(ls_prop) = lt_prop[ v = lv_ns_tmp ].
        ls_prop-n = `xmlns` && COND #( WHEN ls_prop-n IS NOT INITIAL THEN `:` && ls_prop-n ).
        INSERT ls_prop INTO TABLE obj->_node->mt_prop.

      ENDLOOP.

    ENDIF.

    DATA(lv_ns) = lt_prop[ v = obj->_node->mv_ns ]-n.
    lv_ns = COND #( WHEN lv_ns <> `` THEN |{ lv_ns }:| ).

    DATA(lv_element) = obj->_node->mv_name.
    DATA(lv_prop) = REDUCE #( INIT val = `` FOR row IN obj->_node->mt_prop
                       NEXT val = |{ val } { row-n }="{ escape( val    = COND #( WHEN row-v = abap_true THEN `true` ELSE row-v )
                                                                format = cl_abap_format=>e_xml_attr ) }"| ).

    result = |{ result }<{ lv_ns }{ lv_element }{ lv_prop }|.

    IF obj->_node->mt_child IS INITIAL.
      result = |{ result }/>|.
      RETURN.
    ENDIF.

    result = |{ result }>|.

    LOOP AT obj->_node->mt_child INTO DATA(lr_child).
      DATA(lo_child) = NEW z2ui5_cl_view( lr_child ).
      result = result && _2xml( lo_child ).
    ENDLOOP.

    result = |{ result }</{ lv_ns }{ lv_element }>|.

  ENDMETHOD.


  METHOD _add.

    TRY.
        INSERT CONV #( ns ) INTO TABLE _node->mo_root->mt_ns.
      CATCH cx_root.
    ENDTRY.

    DATA(lo_node) = NEW lcl_view_node( ).
    DATA(result2) = NEW z2ui5_cl_view( lo_node ).
    result2->_node->mv_name  = n.
    result2->_node->mv_ns    = ns.
    result2->_node->mt_prop  = t_p.
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

    result = result->_add( n = lv_n ns  = lv_ns ).

    IF check_popup = abap_false.
      result->_add_p( n = `displayBlock`  v = `true` ).
      result->_add_p( n = `height`  v = `100%` ).
    ENDIF.

    result->_node->mt_ns = result->_node->mo_root->mt_ns.
    result->_node->mo_root = result->_node.

  ENDMETHOD.


  METHOD _go_new.

    result = NEW #( _node->mo_previous ).

  ENDMETHOD.


  METHOD _go_root.

    result = NEW #( _node->mo_root ).

  ENDMETHOD.


  METHOD _go_up.

    result = NEW #( _node->mo_parent ).

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


  METHOD _ns_zcc.

    result = NEW #( _node ).

  ENDMETHOD.


  METHOD _stringify.

    DATA(lo_node) = NEW z2ui5_cl_view( _node->mo_root ).
    result = _2xml( lo_node ).

  ENDMETHOD.
ENDCLASS.
