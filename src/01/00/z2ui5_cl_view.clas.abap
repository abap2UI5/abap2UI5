CLASS z2ui5_cl_view DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS add
      IMPORTING
        !name         TYPE clike
        !ns           TYPE clike OPTIONAL
        !t_prop       TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS to_parent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS to_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS to_previous
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.

    METHODS add_property
      IMPORTING
        !val          TYPE z2ui5_if_client=>ty_s_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS ns_m
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_m.

    METHODS ns_ui
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

    METHODS ns_zcc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.


  PROTECTED SECTION.

    DATA mt_prop  TYPE z2ui5_if_client=>ty_t_name_value.
    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mo_root   TYPE REF TO z2ui5_cl_view.
    DATA mo_previous   TYPE REF TO z2ui5_cl_view.
    DATA mo_parent TYPE REF TO z2ui5_cl_view.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_view WITH EMPTY KEY.

    CLASS-METHODS b2json
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_view IMPLEMENTATION.


  METHOD b2json.

*    IF  val.
    result = COND #( WHEN val = abap_true THEN `true` ELSE `false` ).
*    ELSE.
    result = val.
*    ENDIF.

  ENDMETHOD.


  METHOD add_property.

    INSERT val INTO TABLE mt_prop.
    result = me.

  ENDMETHOD.

  METHOD add.

    DATA(result2) = NEW z2ui5_cl_view( ).
    result2->mv_name   = name.
    result2->mv_ns     = ns.
    result2->mt_prop  = t_prop.
    result2->mo_parent = me.
    result2->mo_root   = mo_root.
    INSERT result2 INTO TABLE mt_child.

    mo_root->mo_previous = result2.
    result = result2.

  ENDMETHOD.

  METHOD ns_m.

    result = NEW #( ).
    result->_view = me.

  ENDMETHOD.

  METHOD ns_ui.

    result = NEW #( ).
    result->_view = me.

  ENDMETHOD.

  METHOD ns_zcc.

    result = NEW #( ).
    result->_view = me.

  ENDMETHOD.

  METHOD stringify.

    result = ``.

  ENDMETHOD.

  METHOD to_parent.

    result = mo_parent.

  ENDMETHOD.

  METHOD to_previous.

    result = mo_previous.

  ENDMETHOD.

  METHOD to_root.

    result = mo_root.

  ENDMETHOD.

ENDCLASS.
