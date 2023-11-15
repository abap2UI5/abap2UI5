CLASS z2ui5_cl_view__node DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      DATA mt_prop  TYPE z2ui5_if_client=>ty_t_name_value.
    DATA mt_ns  TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mo_root   TYPE REF TO z2ui5_cl_view__node.
    DATA mo_previous   TYPE REF TO z2ui5_cl_view__node.
    DATA mo_parent TYPE REF TO z2ui5_cl_view__node.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO z2ui5_cl_view__node WITH EMPTY KEY.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_view__node IMPLEMENTATION.
ENDCLASS.
