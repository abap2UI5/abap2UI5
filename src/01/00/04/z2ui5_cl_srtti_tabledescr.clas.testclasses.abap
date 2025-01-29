*"* use this source file for your ABAP unit test classes
CLASS ltc_main DEFINITION
      FOR TESTING
      DURATION SHORT
      RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_line_with_components,
             very__very_long_component_name TYPE i,
           END OF ty_line_with_components.
    TYPES ty_std_table_comps_default_key TYPE STANDARD TABLE OF ty_line_with_components WITH DEFAULT KEY.

    METHODS check_instantiated_classes FOR TESTING.
    METHODS bound_line_type FOR TESTING.

    METHODS assert_copy_equals_original
      IMPORTING
        srtti    TYPE REF TO z2ui5_cl_srtti_typedescr
        original TYPE ty_std_table_comps_default_key.
ENDCLASS.


CLASS ltc_main IMPLEMENTATION.
  METHOD assert_copy_equals_original.
    DATA rtti TYPE REF TO cl_abap_tabledescr.
    DATA dref TYPE REF TO data.

    FIELD-SYMBOLS <copy> TYPE any.

    rtti ?= srtti->get_rtti( ).
    CREATE DATA dref TYPE HANDLE rtti.
    ASSIGN dref->* TO <copy>.
    <copy> = original.
    cl_abap_unit_assert=>assert_equals( act = <copy>
                                        exp = original ).
  ENDMETHOD.

  METHOD bound_line_type.
    DATA line_with_components        TYPE ty_line_with_components.
    DATA std_table_comps_default_key TYPE ty_std_table_comps_default_key.
    DATA component                   TYPE abap_componentdescr.
    DATA components                  TYPE abap_component_tab.
    DATA rtti                        TYPE REF TO cl_abap_tabledescr.
    DATA dref                        TYPE REF TO data.
    DATA srtti                       TYPE REF TO z2ui5_cl_srtti_typedescr.

    FIELD-SYMBOLS <original_table>       TYPE ANY TABLE.
    FIELD-SYMBOLS <original_line>        TYPE any.
    FIELD-SYMBOLS <line_with_components> TYPE ty_line_with_components.

    line_with_components-very__very_long_component_name = 25.
    INSERT line_with_components INTO TABLE std_table_comps_default_key.
    line_with_components-very__very_long_component_name = 37.
    INSERT line_with_components INTO TABLE std_table_comps_default_key.

    component-name = 'VERY__VERY_LONG_COMPONENT_NAME'.
    component-type = cl_abap_elemdescr=>get_i( ).
    INSERT component INTO TABLE components.

    rtti = cl_abap_tabledescr=>create( p_line_type = cl_abap_structdescr=>create( p_components = components ) ).

    CREATE DATA dref TYPE HANDLE rtti.
    ASSIGN dref->* TO <original_table>.
    CREATE DATA dref LIKE LINE OF <original_table>.
    ASSIGN dref->* TO <original_line>.

    LOOP AT std_table_comps_default_key ASSIGNING <line_with_components>.
      MOVE-CORRESPONDING <line_with_components> TO <original_line>.
      INSERT <original_line> INTO TABLE <original_table>.
    ENDLOOP.

    srtti = z2ui5_cl_srtti_typedescr=>create_by_data_object( <original_table> ).

    assert_copy_equals_original( srtti    = srtti
                                 original = <original_table> ).
  ENDMETHOD.

  METHOD check_instantiated_classes.
    DATA comp_row    TYPE LINE OF abap_component_tab.
    DATA comp_tab    TYPE abap_component_tab.
    DATA struct_rtti TYPE REF TO cl_abap_structdescr.
    DATA table_rtti  TYPE REF TO cl_abap_tabledescr.
    DATA dref        TYPE REF TO data.
    DATA srtti       TYPE REF TO z2ui5_cl_srtti_typedescr.
    DATA test        TYPE REF TO z2ui5_cl_srtti_tabledescr.
    DATA srtti_tab   TYPE REF TO z2ui5_cl_srtti_tabledescr.
    DATA srtti2      TYPE REF TO z2ui5_cl_srtti_typedescr.
    DATA test2       TYPE REF TO z2ui5_cl_srtti_structdescr.

    FIELD-SYMBOLS <original> TYPE any.

    comp_row-name = 'VERY__VERY_LONG_COMPONENT_NAME'.
    comp_row-type = cl_abap_elemdescr=>get_i( ).
    INSERT comp_row INTO TABLE comp_tab.

    struct_rtti = cl_abap_structdescr=>create( p_components = comp_tab ).
    table_rtti = cl_abap_tabledescr=>create( p_line_type = struct_rtti ).
    CREATE DATA dref TYPE HANDLE table_rtti.
    ASSIGN dref->* TO <original>.

    srtti = z2ui5_cl_srtti_typedescr=>create_by_data_object( <original> ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    srtti_tab ?= srtti.
    srtti2 = srtti_tab->line_type.

    TRY.
        test2 ?= srtti2.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
