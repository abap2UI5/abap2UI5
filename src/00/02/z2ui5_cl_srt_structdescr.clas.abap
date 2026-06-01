"! <p class="shorttext synchronized" lang="en">Serializable RTTI structure</p>
CLASS z2ui5_cl_srt_structdescr DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_srt_complexdescr
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF sabap_componentdescr,
        name       TYPE string,
        type       TYPE REF TO z2ui5_cl_srt_datadescr,
        as_include TYPE abap_bool,
        suffix     TYPE string,
      END OF sabap_componentdescr.
    TYPES sabap_component_tab TYPE STANDARD TABLE OF sabap_componentdescr WITH DEFAULT KEY.

    DATA struct_kind LIKE cl_abap_structdescr=>struct_kind READ-ONLY.
    DATA components  TYPE sabap_component_tab              READ-ONLY.
    DATA has_include LIKE cl_abap_structdescr=>has_include READ-ONLY.

    METHODS constructor
      IMPORTING
        !rtti TYPE REF TO cl_abap_structdescr.

    METHODS get_rtti
      REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_srt_structdescr IMPLEMENTATION.
  METHOD constructor.
    DATA components_rtti TYPE abap_component_tab.
    DATA scomponent      TYPE sabap_componentdescr.
    DATA scomponent_rtti TYPE REF TO z2ui5_cl_srt_datadescr.

    FIELD-SYMBOLS <component> TYPE abap_componentdescr.

    super->constructor( rtti ).

    struct_kind = rtti->struct_kind.
    has_include = rtti->has_include.

    components_rtti = rtti->get_components( ).

    LOOP AT components_rtti ASSIGNING <component>.

      CLEAR scomponent.
      scomponent-name = <component>-name.

      scomponent_rtti ?= z2ui5_cl_srt_datadescr=>create_by_rtti( <component>-type ).
      scomponent-type       = scomponent_rtti.
      scomponent-as_include = <component>-as_include.
      scomponent-suffix     = <component>-suffix.

      APPEND scomponent TO components.
      IF scomponent-type->not_serializable = abap_true.
        not_serializable = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_rtti.
    DATA components_rtti TYPE cl_abap_structdescr=>component_table.
    DATA component_rtti  TYPE abap_componentdescr.

    FIELD-SYMBOLS <component> TYPE sabap_componentdescr.

    CLEAR components_rtti.
    LOOP AT components ASSIGNING <component>.

      CLEAR component_rtti.
      component_rtti-name        = <component>-name.
      component_rtti-type       ?= <component>-type->get_rtti( ).
      component_rtti-as_include  = <component>-as_include.
      component_rtti-suffix      = <component>-suffix.

      APPEND component_rtti TO components_rtti.
    ENDLOOP.
    rtti = cl_abap_structdescr=>create( components_rtti ).
  ENDMETHOD.
ENDCLASS.
