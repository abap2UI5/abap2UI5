CLASS z2ui5_cl_xml_view_cc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS file_uploader
      IMPORTING
        !value             TYPE clike OPTIONAL
        !path              TYPE clike OPTIONAL
        !placeholder       TYPE clike OPTIONAL
        !upload            TYPE clike OPTIONAL
        !icononly          TYPE clike OPTIONAL
        !buttononly        TYPE clike OPTIONAL
        !buttontext        TYPE clike OPTIONAL
        !uploadbuttontext  TYPE clike OPTIONAL
        !checkdirectupload TYPE clike OPTIONAL
        !filetype          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)      TYPE REF TO z2ui5_cl_xml_view.

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

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_xml_view_cc IMPLEMENTATION.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD scroll.

    result = mo_view.
    mo_view->_generic( name   = `Scroll`
              ns     = `z2ui5`
              t_prop = VALUE #(
                ( n = `setUpdate`   v = setupdate )
                ( n = `items`       v = items )
       ) ).

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


  METHOD title.

    result = mo_view.
    mo_view->_generic( name   = `Title`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `title`  v = title ) ) ).

  ENDMETHOD.

  METHOD file_uploader.

    result = mo_view.
    mo_view->_generic( name   = `FileUploader`
              ns     = `z2ui5`
              t_prop = VALUE #( (  n = `placeholder`        v = placeholder )
                                (  n = `upload`             v = upload )
                                (  n = `path`               v = path )
                                (  n = `value`              v = value )
                                (  n = `iconOnly`           v = z2ui5_cl_fw_utility=>boolean_abap_2_json( icononly ) )
                                (  n = `buttonOnly`         v = z2ui5_cl_fw_utility=>boolean_abap_2_json( buttononly ) )
                                (  n = `buttonText`         v = buttontext )
                                (  n = `uploadButtonText`   v = uploadbuttontext )
                                (  n = `fileType`           v = filetype )
                                (  n = `checkDirectUpload`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkdirectupload ) ) ) ).


  ENDMETHOD.

ENDCLASS.
