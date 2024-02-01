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
      IMPORTING
        ns            TYPE clike DEFAULT `sap.ui.layout.form`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui.

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

    METHODS codeeditor
      IMPORTING
        !value        TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !height       TYPE clike OPTIONAL
        !width        TYPE clike OPTIONAL
        !editable     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui .
    METHODS listitem
      IMPORTING
        !text           TYPE clike OPTIONAL
        !additionaltext TYPE clike OPTIONAL
        !key            TYPE clike OPTIONAL
        !icon           TYPE clike OPTIONAL
        !enabled        TYPE clike OPTIONAL
        !textdirection  TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_ui5_ui.
  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_ui IMPLEMENTATION.

  METHOD listitem.
    result = me.
    _add( n       = `ListItem`
              ns  = `sap.ui.core`
              t_p = VALUE #( ( n = `text` v = text )
                                ( n = `icon` v = icon )
                                ( n = `key`  v = key )
                                ( n = `textDirection`  v = textdirection )
                                ( n = `enabled`        v = _2bool( enabled ) )
                                ( n = `additionalText` v = additionaltext ) ) ).
  ENDMETHOD.

  METHOD codeeditor.
    result = me.
    _add( n       = `CodeEditor`
              ns  = `sap.ui.codeeditor`
              t_p = VALUE #( ( n = `value`   v = value )
                                ( n = `type`    v = type )
                                ( n = `editable`   v = _2bool( editable ) )
                                ( n = `height` v = height )
                                ( n = `width`  v = width ) ) )->_ns_ui( ).
  ENDMETHOD.

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
    result = _add( n  = `TabContainer`
                   ns = `sap.ui.webc.main` )->_ns_ui( ).
  ENDMETHOD.

  METHOD content.
    result = _add( ns = ns
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
