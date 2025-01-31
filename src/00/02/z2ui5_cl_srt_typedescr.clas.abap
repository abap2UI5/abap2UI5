"! <p class="shorttext synchronized" lang="en">Serializable RTTI any type</p>
CLASS z2ui5_cl_srt_typedescr DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    DATA absolute_name    LIKE cl_abap_typedescr=>absolute_name READ-ONLY.
    DATA type_kind        LIKE cl_abap_typedescr=>type_kind     READ-ONLY.
    DATA length           LIKE cl_abap_typedescr=>length        READ-ONLY.
    DATA decimals         LIKE cl_abap_typedescr=>decimals      READ-ONLY.
    DATA kind             LIKE cl_abap_typedescr=>kind          READ-ONLY.
    "! True if it's an object type which doesn't implement the interface IF_SERIALIZABLE_OBJECT
    DATA not_serializable TYPE abap_bool                        READ-ONLY.
    DATA is_ddic_type     TYPE abap_bool                        READ-ONLY.
    "! True if the absolute name is %_T...
    DATA technical_type   TYPE abap_bool                        READ-ONLY.

    METHODS constructor
      IMPORTING
        !rtti TYPE REF TO cl_abap_typedescr.
    METHODS get_rtti
      RETURNING
        VALUE(rtti) TYPE REF TO cl_abap_typedescr.
    CLASS-METHODS create_by_rtti
      IMPORTING
        !rtti TYPE REF TO cl_abap_typedescr
      RETURNING
        VALUE(srtti) TYPE REF TO z2ui5_cl_srt_typedescr.
    CLASS-METHODS create_by_data_object
      IMPORTING
        !data_object TYPE any
      RETURNING
        VALUE(srtti) TYPE REF TO z2ui5_cl_srt_typedescr.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_srt_typedescr IMPLEMENTATION.
  METHOD constructor.
    absolute_name = rtti->absolute_name.
    type_kind     = rtti->type_kind.
    length        = rtti->length.
    decimals      = rtti->decimals.
    kind          = rtti->kind.
    is_ddic_type  = rtti->is_ddic_type( ).
    IF rtti->absolute_name CP '\TYPE=%_T*'.
      technical_type = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD create_by_data_object.
    srtti = create_by_rtti( cl_abap_typedescr=>describe_by_data( data_object ) ).
  ENDMETHOD.

  METHOD create_by_rtti.
    DATA elem_rtti   TYPE REF TO cl_abap_elemdescr.
    DATA struct_rtti TYPE REF TO cl_abap_structdescr.
    DATA table_rtti  TYPE REF TO cl_abap_tabledescr.
    DATA ref_rtti    TYPE REF TO cl_abap_refdescr.
    DATA class_rtti  TYPE REF TO cl_abap_classdescr.
    DATA intf_rtti   TYPE REF TO cl_abap_intfdescr.

    CASE rtti->kind.
      WHEN cl_abap_typedescr=>kind_elem.

        elem_rtti ?= rtti.
        CREATE OBJECT srtti TYPE z2ui5_cl_srt_elemdescr
          EXPORTING rtti = elem_rtti.

      WHEN cl_abap_typedescr=>kind_struct.

        struct_rtti ?= rtti.
        CREATE OBJECT srtti TYPE z2ui5_cl_srt_structdescr
          EXPORTING rtti = struct_rtti.

      WHEN cl_abap_typedescr=>kind_table.

        table_rtti ?= rtti.
        CREATE OBJECT srtti TYPE z2ui5_cl_srt_tabledescr
          EXPORTING rtti = table_rtti.

      WHEN cl_abap_typedescr=>kind_ref.

        ref_rtti ?= rtti.
        CREATE OBJECT srtti TYPE z2ui5_cl_srt_refdescr
          EXPORTING rtti = ref_rtti.

      WHEN cl_abap_typedescr=>kind_class.

        class_rtti ?= rtti.
        CREATE OBJECT srtti TYPE z2ui5_cl_srt_classdescr
          EXPORTING rtti = class_rtti.

      WHEN cl_abap_typedescr=>kind_intf.

        intf_rtti ?= rtti.
        CREATE OBJECT srtti TYPE z2ui5_cl_srt_intfdescr
          EXPORTING rtti = intf_rtti.

      WHEN OTHERS.
        " Unsupported (new ABAP features in the future)
        RAISE EXCEPTION TYPE z2ui5_cx_srt.
    ENDCASE.
  ENDMETHOD.

  METHOD get_rtti.
    " default behavior
    IF technical_type = abap_false.
      rtti = cl_abap_typedescr=>describe_by_name( absolute_name ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
