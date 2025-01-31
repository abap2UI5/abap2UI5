*"* use this source file for your ABAP unit test classes

INTERFACE lif_any.
ENDINTERFACE.


CLASS lcl_any DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_any.
ENDCLASS.


CLASS ltc_main DEFINITION
      FOR TESTING
      DURATION SHORT
      RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS technical_type FOR TESTING.
    METHODS create_by_rtti_elem FOR TESTING RAISING cx_static_check.
    METHODS create_by_rtti_struct FOR TESTING RAISING cx_static_check.
    METHODS create_by_rtti_table FOR TESTING RAISING cx_static_check.
    METHODS create_by_rtti_ref FOR TESTING RAISING cx_static_check.
    METHODS create_by_rtti_class FOR TESTING RAISING cx_static_check.
    METHODS create_by_rtti_intf FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltc_serialize_deserialize DEFINITION
      FOR TESTING
      DURATION SHORT
      RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS class FOR TESTING.
    METHODS elem FOR TESTING.
    METHODS intf FOR TESTING.
    METHODS ref FOR TESTING.
    METHODS structure FOR TESTING.
    METHODS table FOR TESTING.

    TYPES ty_char_10 TYPE c LENGTH 10.
    DATA: BEGIN OF variables,
            char_10      TYPE ty_char_10,
            ref_to_class TYPE REF TO lcl_any,
            ref_to_intf  TYPE REF TO lif_any,
            BEGIN OF structure,
              comp1 TYPE i,
            END OF structure,
            table        TYPE STANDARD TABLE OF i WITH DEFAULT KEY,
            dref         TYPE REF TO ty_char_10,
          END OF variables.
    DATA rtti_before TYPE REF TO cl_abap_typedescr.

    METHODS assert_equal_serializ_deserial.
ENDCLASS.


CLASS ltc_main IMPLEMENTATION.
  METHOD create_by_rtti_class.
    DATA variable  TYPE REF TO lcl_any.
    DATA typedescr TYPE REF TO cl_abap_typedescr.
    DATA srtti     TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA test      TYPE REF TO z2ui5_cl_srt_classdescr.

    CREATE OBJECT variable TYPE lcl_any.
    typedescr ?= cl_abap_typedescr=>describe_by_object_ref( variable ).
    srtti = z2ui5_cl_srt_typedescr=>create_by_rtti( typedescr ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( 'is instance of zcl_srtti_classdescr' ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_by_rtti_elem.
    DATA srtti    TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA variable TYPE c LENGTH 20.
    DATA test     TYPE REF TO z2ui5_cl_srt_elemdescr.

    srtti = z2ui5_cl_srt_typedescr=>create_by_data_object( variable ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( 'is instance of zcl_srtti_elemdescr' ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_by_rtti_intf.
    DATA variable        TYPE REF TO lcl_any.
    DATA rtti_classdescr TYPE REF TO cl_abap_classdescr.
    DATA rtti_intf       TYPE REF TO cl_abap_intfdescr.
    DATA srtti           TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA test            TYPE REF TO z2ui5_cl_srt_intfdescr.

    CREATE OBJECT variable TYPE lcl_any.
    rtti_classdescr ?= cl_abap_typedescr=>describe_by_object_ref( variable ).
    rtti_intf = rtti_classdescr->get_interface_type( 'LIF_ANY' ).
    srtti = z2ui5_cl_srt_typedescr=>create_by_rtti( rtti_intf ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( 'is instance of zcl_srtti_intfdescr' ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_by_rtti_struct.
    DATA srtti TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA test  TYPE REF TO z2ui5_cl_srt_structdescr.
    DATA:
      BEGIN OF variable,
        comp1 TYPE c LENGTH 20,
      END OF variable.

    srtti = z2ui5_cl_srt_typedescr=>create_by_data_object( variable ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( 'is instance of zcl_srtti_structdescr' ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_by_rtti_table.
    DATA srtti TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA test  TYPE REF TO z2ui5_cl_srt_structdescr.
    DATA:
      BEGIN OF variable,
        comp1 TYPE c LENGTH 20,
      END OF variable.

    srtti = z2ui5_cl_srt_typedescr=>create_by_data_object( variable ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( 'is instance of zcl_srtti_structdescr' ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_by_rtti_ref.
    DATA srtti    TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA variable TYPE REF TO flag.
    DATA test     TYPE REF TO z2ui5_cl_srt_refdescr.

    srtti = z2ui5_cl_srt_typedescr=>create_by_data_object( variable ).

    TRY.
        test ?= srtti.
      CATCH cx_sy_move_cast_error.
        cl_abap_unit_assert=>fail( 'is instance of zcl_srtti_refdescr' ).
    ENDTRY.
  ENDMETHOD.

  METHOD technical_type.
    DATA srtti                     TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA dobj_with_bound_data_type TYPE c LENGTH 20.

    srtti = z2ui5_cl_srt_typedescr=>create_by_data_object( dobj_with_bound_data_type ).
    cl_abap_unit_assert=>assert_true( msg = 'technical_type'
                                      act = srtti->technical_type ).
  ENDMETHOD.
ENDCLASS.


CLASS ltc_serialize_deserialize IMPLEMENTATION.
  METHOD assert_equal_serializ_deserial.
    DATA srtti      TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA rtti_after TYPE REF TO cl_abap_typedescr.

    srtti = z2ui5_cl_srt_typedescr=>create_by_rtti( rtti = rtti_before ).

    rtti_after = srtti->get_rtti( ).

    cl_abap_unit_assert=>assert_bound( msg = 'result bound'
                                       act = rtti_after ).
    cl_abap_unit_assert=>assert_equals( msg = 'Type kind'
                                        exp = rtti_before->type_kind
                                        act = rtti_after->type_kind ).
    cl_abap_unit_assert=>assert_equals( msg = 'length'
                                        exp = rtti_before->length
                                        act = rtti_after->length ).
    cl_abap_unit_assert=>assert_equals( msg = 'decimals'
                                        exp = rtti_before->decimals
                                        act = rtti_after->decimals ).
    cl_abap_unit_assert=>assert_equals( msg = 'Kind'
                                        exp = rtti_before->kind
                                        act = rtti_after->kind ).
    cl_abap_unit_assert=>assert_equals( msg = 'is_ddic_type'
                                        exp = rtti_before->is_ddic_type( )
                                        act = rtti_after->is_ddic_type( ) ).
  ENDMETHOD.

  METHOD class.
    rtti_before = cl_abap_typedescr=>describe_by_data( variables-ref_to_class ).
    assert_equal_serializ_deserial( ).
  ENDMETHOD.

  METHOD elem.
    rtti_before = cl_abap_typedescr=>describe_by_data( variables-char_10 ).
    assert_equal_serializ_deserial( ).
  ENDMETHOD.

  METHOD intf.
    rtti_before = cl_abap_typedescr=>describe_by_data( variables-ref_to_intf ).
    assert_equal_serializ_deserial( ).
  ENDMETHOD.

  METHOD ref.
    rtti_before = cl_abap_typedescr=>describe_by_data( variables-dref ).
    assert_equal_serializ_deserial( ).
  ENDMETHOD.

  METHOD structure.
    rtti_before = cl_abap_typedescr=>describe_by_data( variables-structure ).
    assert_equal_serializ_deserial( ).
  ENDMETHOD.

  METHOD table.
    rtti_before = cl_abap_typedescr=>describe_by_data( variables-table ).
    assert_equal_serializ_deserial( ).
  ENDMETHOD.
ENDCLASS.
