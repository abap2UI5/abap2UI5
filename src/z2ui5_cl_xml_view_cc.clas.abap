CLASS z2ui5_cl_xml_view_cc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS title
      IMPORTING
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS scroll
      IMPORTING
        setupdate     TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS timer
      IMPORTING
        finished      TYPE clike OPTIONAL
        delayms       TYPE clike OPTIONAL
        checkrepeat   TYPE clike OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view.

    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_xml_view_cc IMPLEMENTATION.

  METHOD scroll.

    result = mo_view.
    mo_view->_generic( name   = `Scroll`
              ns     = `z2ui5`
              t_prop = VALUE #(
                ( n = `setUpdate`   v = setupdate )
                ( n = `items`       v = items )
       ) ).

  ENDMETHOD.

  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.

  METHOD title.

    result = mo_view.
    mo_view->_generic( name   = `Title`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `title`  v = title ) ) ).

  ENDMETHOD.

  METHOD timer.

    result = mo_view.
    mo_view->_generic( name   = `Timer`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `delayMS`  v = delayms )
                                ( n = `finished`  v = finished )
                                ( n = `checkRepeat`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkrepeat ) )
              ) ).

  ENDMETHOD.

ENDCLASS.
