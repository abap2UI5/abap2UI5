CLASS z2ui5_cl_util_xml DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS constructor.

    METHODS __
      IMPORTING
        n             TYPE clike
        ns            TYPE clike                           OPTIONAL
        a             TYPE clike                           OPTIONAL
        v             TYPE clike                           OPTIONAL
        p             TYPE z2ui5_cl_util=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

    METHODS _
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
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_util_xml WITH DEFAULT KEY.

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

    CREATE OBJECT result.

    result->mo_root   = result.
    result->mo_parent = result.

  ENDMETHOD.

  METHOD __.

    DATA lo_child TYPE REF TO z2ui5_cl_util_xml.
      DATA temp27 TYPE z2ui5_cl_util=>ty_s_name_value.
    CREATE OBJECT lo_child TYPE z2ui5_cl_util_xml.
    lo_child->mv_name   = n.
    lo_child->mv_ns     = ns.
    lo_child->mt_prop   = p.
    IF a IS NOT INITIAL.
      
      CLEAR temp27.
      temp27-n = a.
      temp27-v = v.
      INSERT temp27 INTO TABLE lo_child->mt_prop.
    ENDIF.
    lo_child->mo_parent = me.
    lo_child->mo_root   = mo_root.
    INSERT lo_child INTO TABLE mt_child.

    mo_root->mo_previous = lo_child.
    result = lo_child.

  ENDMETHOD.

  METHOD _.

    result = me.
    __( n  = n
        ns = ns
        a  = a
        v  = v
        p  = p ).

  ENDMETHOD.

  METHOD _if.

    IF when = abap_true.
      result = __( n  = n
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
      _( n  = n
         ns = ns
         a  = a
         v  = v
         p  = p ).
    ENDIF.
    result = me.

  ENDMETHOD.

  METHOD p.

    DATA temp28 TYPE z2ui5_cl_util=>ty_s_name_value.
    CLEAR temp28.
    temp28-n = n.
    temp28-v = v.
    INSERT temp28 INTO TABLE mt_prop.
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
      DATA lr_root LIKE LINE OF mt_child.
        DATA temp29 TYPE REF TO z2ui5_cl_util_xml.
    DATA temp30 TYPE string.
    DATA lv_tmp2 LIKE temp30.
    DATA temp31 TYPE string.
    DATA val TYPE string.
    DATA row LIKE LINE OF mt_prop.
      DATA temp1 TYPE string.
    DATA lv_tmp3 LIKE temp31.
      DATA temp32 LIKE LINE OF ct_parts.
    DATA temp33 LIKE LINE OF ct_parts.
    DATA lr_child LIKE LINE OF mt_child.
      DATA temp34 TYPE REF TO z2ui5_cl_util_xml.
    DATA temp35 LIKE LINE OF ct_parts.

    IF mv_name IS INITIAL.
      
      LOOP AT mt_child INTO lr_root.
        
        temp29 ?= lr_root.
        temp29->xml_get_parts( CHANGING ct_parts = ct_parts ).
      ENDLOOP.
      RETURN.
    ENDIF.

    
    IF mv_ns <> ``.
      temp30 = |{ mv_ns }:|.
    ELSE.
      CLEAR temp30.
    ENDIF.
    
    lv_tmp2 = temp30.
    
    
    val = ``.
    
    LOOP AT mt_prop INTO row WHERE v <> ``.
      
      IF row-v = abap_true.
        temp1 = `true`.
      ELSE.
        temp1 = row-v.
      ENDIF.
      val = |{ val } { row-n }="{ escape( val = temp1 format = cl_abap_format=>e_xml_attr ) }"|.
    ENDLOOP.
    temp31 = val.
    
    lv_tmp3 = temp31.

    IF mt_child IS INITIAL.
      
      temp32 = | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }/>|.
      APPEND temp32 TO ct_parts.
      RETURN.
    ENDIF.

    
    temp33 = | <{ lv_tmp2 }{ mv_name }{ lv_tmp3 }>|.
    APPEND temp33 TO ct_parts.

    
    LOOP AT mt_child INTO lr_child.
      
      temp34 ?= lr_child.
      temp34->xml_get_parts( CHANGING ct_parts = ct_parts ).
    ENDLOOP.

    
    temp35 = |</{ lv_tmp2 }{ mv_name }>|.
    APPEND temp35 TO ct_parts.

  ENDMETHOD.

  METHOD xml_get_parts_indent.
      DATA lr_root LIKE LINE OF mt_child.
        DATA temp36 TYPE REF TO z2ui5_cl_util_xml.
    DATA lv_pad TYPE string.
    DATA temp37 TYPE string.
    DATA lv_ns LIKE temp37.
    DATA temp38 TYPE string.
    DATA val TYPE string.
    DATA row LIKE LINE OF mt_prop.
      DATA temp2 TYPE string.
    DATA lv_attr LIKE temp38.
      DATA temp39 LIKE LINE OF ct_parts.
    DATA temp40 LIKE LINE OF ct_parts.
    DATA lr_child LIKE LINE OF mt_child.
      DATA temp41 TYPE REF TO z2ui5_cl_util_xml.
    DATA temp42 LIKE LINE OF ct_parts.

    IF mv_name IS INITIAL.
      
      LOOP AT mt_child INTO lr_root.
        
        temp36 ?= lr_root.
        temp36->xml_get_parts_indent( EXPORTING iv_depth = iv_depth
                                                                  CHANGING ct_parts = ct_parts ).
      ENDLOOP.
      RETURN.
    ENDIF.

    
    lv_pad  = repeat( val = ` ` occ = iv_depth * 2 ).
    
    IF mv_ns <> ``.
      temp37 = |{ mv_ns }:|.
    ELSE.
      CLEAR temp37.
    ENDIF.
    
    lv_ns = temp37.
    
    
    val = ``.
    
    LOOP AT mt_prop INTO row WHERE v <> ``.
      
      IF row-v = abap_true.
        temp2 = `true`.
      ELSE.
        temp2 = row-v.
      ENDIF.
      val = |{ val } { row-n }="{ escape( val = temp2 format = cl_abap_format=>e_xml_attr ) }"|.
    ENDLOOP.
    temp38 = val.
    
    lv_attr = temp38.

    IF mt_child IS INITIAL.
      
      temp39 = |{ lv_pad }<{ lv_ns }{ mv_name }{ lv_attr }/>|.
      APPEND temp39 TO ct_parts.
      RETURN.
    ENDIF.

    
    temp40 = |{ lv_pad }<{ lv_ns }{ mv_name }{ lv_attr }>|.
    APPEND temp40 TO ct_parts.

    
    LOOP AT mt_child INTO lr_child.
      
      temp41 ?= lr_child.
      temp41->xml_get_parts_indent( EXPORTING iv_depth = iv_depth + 1
                                                                 CHANGING ct_parts = ct_parts ).
    ENDLOOP.

    
    temp42 = |{ lv_pad }</{ lv_ns }{ mv_name }>|.
    APPEND temp42 TO ct_parts.

  ENDMETHOD.

ENDCLASS.
