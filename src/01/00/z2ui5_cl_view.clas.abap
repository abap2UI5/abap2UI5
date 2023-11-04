CLASS z2ui5_cl_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-DATA mt_prop  TYPE z2ui5_if_client=>ty_t_name_value.

    CLASS-METHODS class_constructor.
    CLASS-METHODS factory
      IMPORTING
        t_ns          TYPE z2ui5_if_client=>ty_t_name_value DEFAULT mt_prop
        client        TYPE REF TO z2ui5_if_client OPTIONAL
          PREFERRED PARAMETER client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS add
      IMPORTING
        !name         TYPE clike
        !ns           TYPE clike OPTIONAL
        !t_prop       TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS add_property
      IMPORTING
        !val          TYPE z2ui5_if_client=>ty_s_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS _cc_plain_xml
      IMPORTING
        !val          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view.

    METHODS get_m
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_m.

    METHODS get_ui
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

  PROTECTED SECTION.

    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mo_root   TYPE REF TO z2ui5_cl_view.
    DATA mo_previous   TYPE REF TO z2ui5_cl_view.
    DATA mo_parent TYPE REF TO z2ui5_cl_view.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_view WITH EMPTY KEY.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_view IMPLEMENTATION.


  METHOD class_constructor.

    mt_prop  = VALUE #( BASE mt_prop
                                (  n = 'displayBlock'   v = 'true' )
                                (  n = 'height'         v = '100%' ) ).

  ENDMETHOD.


  METHOD add_property.

    INSERT val INTO TABLE mt_prop.
    result = me.

  ENDMETHOD.

  METHOD _cc_plain_xml.

    result = me.
    add( name   = `ZZPLAIN`
              t_prop = VALUE #( ( n = `VALUE` v = val ) ) ).

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mv_name   = `View`.
    result->mv_ns     = `mvc`.
    result->mo_root   = result.
    result->mo_parent = result.

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

  METHOD get_m.

  ENDMETHOD.

  METHOD get_ui.

  ENDMETHOD.

ENDCLASS.
