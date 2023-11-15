CLASS z2ui5_cl_view_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_view.

  PUBLIC SECTION.

    METHODS simpleform
      IMPORTING
        !title        TYPE clike OPTIONAL
        !layout       TYPE clike OPTIONAL
        !editable     TYPE clike OPTIONAL
        !columnsxl    TYPE clike OPTIONAL
        !columnsl     TYPE clike OPTIONAL
        !columnsm     TYPE clike OPTIONAL
        !id           TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

    METHODS content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_ui.

    DATA _view TYPE REF TO z2ui5_cl_view.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_view_ui IMPLEMENTATION.

  METHOD content.

    result = _view->add(
        ns   = `form`
        name = `content` )->ns_ui( ).

  ENDMETHOD.

  METHOD simpleform.

    result = add(
        name   = `SimpleForm`
        ns     = `form`
        t_prop = VALUE #( ( n = `title`      v = title )
                          ( n = `layout`     v = layout )
                          ( n = `id`         v = id )
                          ( n = `columnsXL`  v = columnsxl )
                          ( n = `columnsL`   v = columnsl )
                          ( n = `columnsM`   v = columnsm )
                          ( n = `editable`   v = b2json( editable ) ) ) )->ns_ui( ).

  ENDMETHOD.

ENDCLASS.
