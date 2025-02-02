"! <p class="shorttext synchronized" lang="en">Serializable RTTI object type</p>
class z2ui5_cl_srt_objectdescr definition
  public
  inheriting from z2ui5_cl_srt_typedescr
  create public .

public section.

  data INTERFACES like CL_ABAP_OBJECTDESCR=>INTERFACES .
  data TYPES like CL_ABAP_OBJECTDESCR=>TYPES .
  data ATTRIBUTES like CL_ABAP_OBJECTDESCR=>ATTRIBUTES .
  data METHODS like CL_ABAP_OBJECTDESCR=>METHODS .
  data EVENTS like CL_ABAP_OBJECTDESCR=>EVENTS .

  methods CONSTRUCTOR
    importing
      !RTTI type ref to CL_ABAP_OBJECTDESCR .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_srt_objectdescr IMPLEMENTATION.


  METHOD constructor.
    super->constructor( rtti ).

    interfaces = rtti->interfaces.
    types      = rtti->types.
    attributes = rtti->attributes.
    methods    = rtti->methods.
    events     = rtti->events.

    READ TABLE interfaces WITH KEY name = 'IF_SERIALIZABLE_OBJECT' TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      not_serializable = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
