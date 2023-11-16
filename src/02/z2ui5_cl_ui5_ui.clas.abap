CLASS z2ui5_cl_ui5_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

  PUBLIC SECTION.
    METHODS simpleform
      IMPORTING title         TYPE clike OPTIONAL
                layout        TYPE clike OPTIONAL
                editable      TYPE clike OPTIONAL
                columnsxl     TYPE clike OPTIONAL
                columnsl      TYPE clike OPTIONAL
                columnsm      TYPE clike OPTIONAL
                id            TYPE clike OPTIONAL
                  PREFERRED PARAMETER title
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

    METHODS content
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

    METHODS tabcontainer
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

    METHODS tab
      IMPORTING text          TYPE clike OPTIONAL
                selected      TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

    METHODS grid
      IMPORTING class         TYPE clike OPTIONAL
                default_span  TYPE clike OPTIONAL
          PREFERRED PARAMETER default_span
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

    METHODS griddata
      IMPORTING span          TYPE clike OPTIONAL
          PREFERRED PARAMETER span
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_ui IMPLEMENTATION.
  METHOD griddata.
    result = me.
    _add( n   = `GridData`
          ns  = `sap.ui.layout`
          t_p = VALUE #( ( n = `span` v = span ) ) ).
  ENDMETHOD.

  METHOD grid.
    result = _add( n   = `Grid`
                   ns  = `sap.ui.layout`
                   t_p = VALUE #( ( n = `defaultSpan` v = default_span )
                                  ( n = `class`       v = class ) ) )->_ns_ui( ).
  ENDMETHOD.

  METHOD tab.
    result = _add( n   = `Tab`
                   ns  = `sap.ui.webc.main`
                   t_p = VALUE #( ( n = `text`     v = text )
                                  ( n = `selected` v = selected ) ) )->_ns_ui( ).
  ENDMETHOD.

  METHOD tabcontainer.
    result = _add( n = `TabContainer` ns = `sap.ui.webc.main` )->_ns_ui( ).
  ENDMETHOD.

  METHOD content.
    result = _add( ns = `sap.ui.layout.form`
                   n  = `content` )->_ns_ui( ).
  ENDMETHOD.

  METHOD simpleform.
    result = _add( n   = `SimpleForm`
                   ns  = `sap.ui.layout.form`
                   t_p = VALUE #( ( n = `title`      v = title )
                                  ( n = `layout`     v = layout )
                                  ( n = `id`         v = id )
                                  ( n = `columnsXL`  v = columnsxl )
                                  ( n = `columnsL`   v = columnsl )
                                  ( n = `columnsM`   v = columnsm )
                                  ( n = `editable`   v = _2bool( editable ) ) ) )->_ns_ui( ).
  ENDMETHOD.
ENDCLASS.
