CLASS z2ui5_cl_view_ui DEFINITION
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
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

  PROTECTED SECTION.

    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.


    DATA mo_root   TYPE REF TO z2ui5_cl_view_ui.
    DATA mo_previous   TYPE REF TO z2ui5_cl_view_ui.
    DATA mo_parent TYPE REF TO z2ui5_cl_view_ui.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view WITH EMPTY KEY.


  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_view_ui IMPLEMENTATION.

  METHOD class_constructor.

    mt_prop  = VALUE #( BASE mt_prop
                                (  n = 'displayBlock'   v = 'true' )
                                (  n = 'height'         v = '100%' ) ).

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

ENDCLASS.
