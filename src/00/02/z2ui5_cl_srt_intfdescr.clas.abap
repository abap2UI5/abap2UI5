"! <p class="shorttext synchronized" lang="en">Serializable RTTI interface</p>
CLASS z2ui5_cl_srt_intfdescr DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_srt_objectdescr
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA intf_kind LIKE cl_abap_intfdescr=>intf_kind.

    METHODS constructor
      IMPORTING
        !rtti TYPE REF TO cl_abap_intfdescr.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_srt_intfdescr IMPLEMENTATION.
  METHOD constructor.
    super->constructor( rtti ).
    intf_kind = rtti->intf_kind.
  ENDMETHOD.
ENDCLASS.
