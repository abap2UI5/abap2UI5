CLASS z2ui5_cl_ui5_ui_webc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

  PUBLIC SECTION.
    METHODS button
      IMPORTING id            TYPE clike OPTIONAL
                icon          TYPE clike OPTIONAL
                text          TYPE clike OPTIONAL
                tooltip       TYPE clike OPTIONAL
                design        TYPE clike OPTIONAL
                click         TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS bar
      IMPORTING id            TYPE clike OPTIONAL
                design        TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS label
      IMPORTING
        id            TYPE clike OPTIONAL
        text            TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS panel
      IMPORTING id            TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS header
      IMPORTING id            TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS input
      IMPORTING id            TYPE clike OPTIONAL
                text          TYPE clike OPTIONAL
                click         TYPE clike OPTIONAL
                value         TYPE clike OPTIONAL
                width         TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

    METHODS toast
      IMPORTING id            TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_ui_webc.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_UI5_UI_WEBC IMPLEMENTATION.


  METHOD bar.

    result = _add( n   = `Bar`
                   ns  = 'sap.ui.webc.fiori'
                   t_p = VALUE #( ( n = `id`     v = id )
                                  ( n = `design` v = design )
                   ) )->_ns_webc( ).

  ENDMETHOD.


  METHOD button.

    result = me.
    _add( n            = `Button`
                   ns  = 'sap.ui.webc.main'
                   t_p = VALUE #( ( n = `id`                 v = id )
                                  ( n = `icon`        v = icon )
                                  ( n = `tooltip`           v = tooltip )
                                  ( n = `text`           v = text )
                                  ( n = `click`           v = click )
                                  ( n = `design`    v = design ) ) )->_ns_webc( ).

  ENDMETHOD.


  METHOD header.

    result = _add( n   = `header`
                   ns  = 'sap.ui.webc.main'
                   t_p = VALUE #( ( n = `id` v = id ) ) )->_ns_webc( ).

  ENDMETHOD.


  METHOD input.

    result = me.
    _add( n            = `Input`
                   ns  = 'sap.ui.webc.main'
                   t_p = VALUE #(
                    ( n = `id` v = id )
                    ( n = `text` v = text )
                    ( n = `click` v = click )
                    ( n = `width` v = width )
                    ( n = `value` v = value )
                    ) )->_ns_webc( ).

  ENDMETHOD.


  METHOD label.

    result = me.
    _add( n            = `Label`
                   ns  = 'sap.ui.webc.main'
                   t_p = VALUE #(
                    ( n = `id`   v = id )
                    ( n = `text` v = text )
                    ) )->_ns_webc( ).

  ENDMETHOD.


  METHOD panel.

    result = _add( n   = `Panel`
                   ns  = 'sap.ui.webc.main'
                   t_p = VALUE #(
                    ( n = `id` v = id )
                    ) )->_ns_webc( ).

  ENDMETHOD.


  METHOD toast.

    result = me.
    _add( n            = `Toast`
                   ns  = 'sap.ui.webc.main'
                   t_p = VALUE #(
                    ( n = `id` v = id )
              ) )->_ns_webc( ).

  ENDMETHOD.
ENDCLASS.
