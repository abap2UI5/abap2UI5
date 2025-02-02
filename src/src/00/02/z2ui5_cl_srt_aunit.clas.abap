CLASS z2ui5_cl_srt_aunit DEFINITION
  PUBLIC
  FOR TESTING
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS serialize_deserialize IMPORTING variable TYPE any.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_srt_aunit IMPLEMENTATION.

  METHOD serialize_deserialize.
    " Serialize: both type and value at the same time.
    FIELD-SYMBOLS <variable1> TYPE any.
    DATA rtti1 TYPE REF TO cl_abap_typedescr.
    DATA srtti1 TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA xstring TYPE xstring.
    DATA srtti2 TYPE REF TO z2ui5_cl_srt_typedescr.
    DATA temp1 TYPE REF TO cl_abap_datadescr.
    DATA rtti2 LIKE temp1.
    DATA ref_variable2 TYPE REF TO data.
    FIELD-SYMBOLS <variable2> TYPE any.
    ASSIGN variable TO <variable1>.

    rtti1 = cl_abap_typedescr=>describe_by_data( <variable1> ).

    srtti1 = z2ui5_cl_srt_typedescr=>create_by_data_object( <variable1> ).

    CALL TRANSFORMATION id
        SOURCE  srtti = srtti1
                dobj  = <variable1>
        RESULT XML xstring
        OPTIONS data_refs = 'heap-or-create'.

    " Deserialize: (1) the type, to create the variable (2) then the value.

    CALL TRANSFORMATION id
        SOURCE XML xstring
        RESULT srtti = srtti2.

    temp1 ?= srtti2->get_rtti( ).

    rtti2 = temp1.

    CREATE DATA ref_variable2 TYPE HANDLE rtti2.

    ASSIGN ref_variable2->* TO <variable2>.
    CALL TRANSFORMATION id
        SOURCE XML xstring
        RESULT dobj = <variable2>.

    cl_abap_unit_assert=>assert_equals( exp = rtti1 act = rtti2 ).
    cl_abap_unit_assert=>assert_equals( exp = <variable1> act = <variable2> ).
  ENDMETHOD.

ENDCLASS.
