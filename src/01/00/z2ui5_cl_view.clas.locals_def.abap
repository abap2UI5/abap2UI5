
class lcl_view_node DEFINITION.

PUBLIC SECTION.

    DATA mt_prop  TYPE z2ui5_if_client=>ty_t_name_value.
    DATA mt_ns  TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.
    DATA mv_name  TYPE string.
    DATA mv_ns     TYPE string.
    DATA mo_root   TYPE REF TO lcl_view_node.
    DATA mo_previous   TYPE REF TO lcl_view_node.
    DATA mo_parent TYPE REF TO lcl_view_node.
    DATA mt_child  TYPE STANDARD TABLE OF REF TO lcl_view_node WITH EMPTY KEY.

ENDCLASS.
