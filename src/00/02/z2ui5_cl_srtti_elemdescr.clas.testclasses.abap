*"* use this source file for your ABAP unit test classes

CLASS ltc_subclass DEFINITION INHERITING FROM z2ui5_cl_srtti_elemdescr.
  PUBLIC SECTION.
    METHODS get_rtti_by_type_kind_2
      IMPORTING
        i_type_kind LIKE cl_abap_typedescr=>type_kind
      RETURNING
        VALUE(rtti) TYPE REF TO cl_abap_typedescr.
ENDCLASS.


CLASS ltc_subclass IMPLEMENTATION.
  METHOD get_rtti_by_type_kind_2.
    rtti = get_rtti_by_type_kind( i_type_kind ).
  ENDMETHOD.
ENDCLASS.


CLASS ltc_main DEFINITION
      FOR TESTING
      DURATION SHORT
      RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS serialize_deserialize FOR TESTING.
    METHODS get_rtti_by_type_kind FOR TESTING.

    METHODS get_rtti_by_type_kind_assert
      IMPORTING
        variable TYPE simple.
ENDCLASS.


CLASS ltc_main IMPLEMENTATION.
  METHOD serialize_deserialize.
    DATA variable TYPE c LENGTH 20.

    variable = 'Hello World'.
    z2ui5_cl_srtti_aunit=>serialize_deserialize( variable ).
  ENDMETHOD.

  METHOD get_rtti_by_type_kind_assert.
    DATA rtti        TYPE REF TO cl_abap_elemdescr.
    DATA lo_subclass TYPE REF TO ltc_subclass.
    DATA rtti2       TYPE REF TO cl_abap_typedescr.

    rtti ?= cl_abap_typedescr=>describe_by_data( variable ).

    CREATE OBJECT lo_subclass
      EXPORTING rtti = rtti.

    rtti2 = lo_subclass->get_rtti_by_type_kind_2( i_type_kind = rtti->type_kind ).

    cl_abap_unit_assert=>assert_equals( msg = 'decimals'
                                        exp = rtti->decimals
                                        act = rtti2->decimals ).
    cl_abap_unit_assert=>assert_equals( msg = 'type_kind'
                                        exp = rtti->type_kind
                                        act = rtti2->type_kind ).
    cl_abap_unit_assert=>assert_equals( msg = 'length'
                                        exp = rtti->length
                                        act = rtti2->length ).
  ENDMETHOD.

  METHOD get_rtti_by_type_kind.
    DATA n          TYPE n LENGTH 20.
    DATA c          TYPE c LENGTH 20.
    DATA string     TYPE string.
    DATA xstring    TYPE xstring.
    DATA i          TYPE i.
    DATA f          TYPE f.
    DATA d          TYPE d.
    DATA t          TYPE t.
    DATA x          TYPE x LENGTH 20.
    DATA p          TYPE p LENGTH 10 DECIMALS 3.
    DATA int1       TYPE int1.
    DATA int2       TYPE int2.
    DATA decfloat16 TYPE decfloat16.
    DATA decfloat34 TYPE decfloat34.

    get_rtti_by_type_kind_assert( n          ).
    get_rtti_by_type_kind_assert( c          ).
    get_rtti_by_type_kind_assert( string     ).
    get_rtti_by_type_kind_assert( xstring    ).
    get_rtti_by_type_kind_assert( i          ).
    get_rtti_by_type_kind_assert( f          ).
    get_rtti_by_type_kind_assert( d          ).
    get_rtti_by_type_kind_assert( t          ).
    get_rtti_by_type_kind_assert( x          ).
    get_rtti_by_type_kind_assert( p          ).
    get_rtti_by_type_kind_assert( int1       ).
    get_rtti_by_type_kind_assert( int2       ).
    get_rtti_by_type_kind_assert( decfloat16 ).
    get_rtti_by_type_kind_assert( decfloat34 ).
  ENDMETHOD.
ENDCLASS.
