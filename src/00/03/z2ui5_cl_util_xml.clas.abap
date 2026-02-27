CLASS z2ui5_cl_util_xml DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS constructor.

    METHODS _
      IMPORTING
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        a             TYPE clike                           OPTIONAL
        v             TYPE clike                           OPTIONAL
        p             TYPE z2ui5_cl_util=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS __
      IMPORTING
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        a             TYPE clike                           OPTIONAL
        v             TYPE clike                           OPTIONAL
        p             TYPE z2ui5_cl_util=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS _if
      IMPORTING
        when          TYPE abap_bool
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        a             TYPE clike                           OPTIONAL
        v             TYPE clike                           OPTIONAL
        p             TYPE z2ui5_cl_util=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS __if
      IMPORTING
        when          TYPE abap_bool
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        a             TYPE clike                           OPTIONAL
        v             TYPE clike                           OPTIONAL
        p             TYPE z2ui5_cl_util=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS p
      IMPORTING
        n             TYPE clike
        v             TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS n
      IMPORTING
        name          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS n_prev
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS n_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS stringify
      IMPORTING
        from_root     TYPE abap_bool DEFAULT abap_true
        indent        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    DATA mv_name   TYPE string.
    DATA mv_ns     TYPE string.
    DATA mt_prop   TYPE SORTED TABLE OF z2ui5_cl_util=>ty_s_name_value WITH NON-UNIQUE KEY n.

    DATA mo_root   TYPE REF TO z2ui5_cl_util_xml.
    DATA mo_previous TYPE REF TO z2ui5_cl_util_xml.
    DATA mo_parent TYPE REF TO z2ui5_cl_util_xml.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_util_xml WITH EMPTY KEY.

    METHODS xml_get_parts
      CHANGING
        ct_parts TYPE string_table.

    METHODS xml_get_parts_indent
      IMPORTING
        iv_depth TYPE i DEFAULT 0
      CHANGING
        ct_parts TYPE string_table.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_util_xml IMPLEMENTATION.

  METHOD constructor.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.

  METHOD _.

    DATA(lo_child) = NEW z2ui5_cl_util_xml( ).
    lo_child->mv_name   = n.
    lo_child->mv_ns     = ns.
    lo_child->mt_prop   = p.
    IF a IS NOT INITIAL.
      INSERT VALUE #( n = a v = v ) INTO TABLE lo_child->mt_prop.
    ENDIF.
    lo_child->mo_parent = me.
    lo_child->mo_root   = mo_root.
    INSERT lo_child INTO TABLE mt_child.

    mo_root->mo_previous = lo_child.
    result = lo_child.

  ENDMETHOD.

  METHOD __.

    result = me.
    _( n  = n
       ns = ns
       a  = a
       v  = v
       p  = p ).

  ENDMETHOD.

  METHOD _if.

    IF when = abap_true.
      result = _( n  = n
                  ns = ns
                  a  = a
                  v  = v
                  p  = p ).
    ELSE.
      result = me.
    ENDIF.

  ENDMETHOD.

  METHOD __if.

    IF when = abap_true.
      __( n  = n
          ns = ns
          a  = a
          v  = v
          p  = p ).
    ENDIF.
    result = me.

  ENDMETHOD.

  METHOD p.

    INSERT VALUE #( n = n v = v ) INTO TABLE mt_prop.
    result = me.

  ENDMETHOD.

  METHOD n.

    IF name IS INITIAL.
      result = mo_parent.
      RETURN.
    ENDIF.

    IF mo_parent->mv_name = name.
      result = mo_parent.
    ELSEIF me = mo_root.
      result = me.
    ELSE.
      result = mo_parent->n( name ).
    ENDIF.

  ENDMETHOD.

  METHOD n_prev.

    result = mo_root->mo_previous.

  ENDMETHOD.

  METHOD n_root.

    result = mo_root.

  ENDMETHOD.

  METHOD stringify.

    DATA lt_parts TYPE string_table.
    IF indent = abap_true.
      IF from_root = abap_true.
        mo_root->xml_get_parts_indent( CHANGING ct_parts = lt_parts ).
      ELSE.
        xml_get_parts_indent( CHANGING ct_parts = lt_parts ).
      ENDIF.
      result = concat_lines_of( table = lt_parts sep = |\n| ).
    ELSE.
      IF from_root = abap_true.
        mo_root->xml_get_parts( CHANGING ct_parts = lt_parts ).
      ELSE.
        xml_get_parts( CHANGING ct_parts = lt_parts ).
      ENDIF.
      result = concat_lines_of( lt_parts ).
    ENDIF.

  ENDMETHOD.

  METHOD xml_get_parts.

    IF mv_name IS INITIAL.
      LOOP AT mt_child INTO DATA(lr_root).
        CAST z2ui5_cl_util_xml( lr_root )->xml_get_parts( CHANGING ct_parts = ct_parts ).
      ENDLOOP.
      RETURN.
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
      CAST z2ui5_cl_util_xml( lr_child )->xml_get_parts( CHANGING ct_parts = ct_parts ).
    ENDLOOP.

    APPEND |</{ lv_tmp2 }{ mv_name }>| TO ct_parts.

  ENDMETHOD.

  METHOD xml_get_parts_indent.

    IF mv_name IS INITIAL.
      LOOP AT mt_child INTO DATA(lr_root).
        CAST z2ui5_cl_util_xml( lr_root )->xml_get_parts_indent( EXPORTING iv_depth = iv_depth
                                                                  CHANGING ct_parts = ct_parts ).
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lv_pad)  = repeat( val = ` ` occ = iv_depth * 2 ).
    DATA(lv_ns)   = COND #( WHEN mv_ns <> `` THEN |{ mv_ns }:| ).
    DATA(lv_attr) = REDUCE string( INIT val = `` FOR row IN mt_prop WHERE ( v <> `` ) "#EC CI_SORTSEQ
                          NEXT val = |{ val } { row-n }="{ escape( val    = COND string( WHEN row-v = abap_true
                                                                                         THEN `true`
                                                                                         ELSE row-v )
                                                                   format = cl_abap_format=>e_xml_attr ) }"| ).

    IF mt_child IS INITIAL.
      APPEND |{ lv_pad }<{ lv_ns }{ mv_name }{ lv_attr }/>| TO ct_parts.
      RETURN.
    ENDIF.

    APPEND |{ lv_pad }<{ lv_ns }{ mv_name }{ lv_attr }>| TO ct_parts.

    LOOP AT mt_child INTO DATA(lr_child).
      CAST z2ui5_cl_util_xml( lr_child )->xml_get_parts_indent( EXPORTING iv_depth = iv_depth + 1
                                                                 CHANGING ct_parts = ct_parts ).
    ENDLOOP.

    APPEND |{ lv_pad }</{ lv_ns }{ mv_name }>| TO ct_parts.

  ENDMETHOD.

ENDCLASS.
