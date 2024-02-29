CLASS z2ui5_cl_ui5_z2ui5 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

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
        VALUE(result)      TYPE REF TO z2ui5_cl_ui5_z2ui5.

    METHODS timer
      IMPORTING
        finished      TYPE clike OPTIONAL
        delayms       TYPE clike OPTIONAL
        checkrepeat   TYPE clike OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_z2ui5.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_ui5_z2ui5 IMPLEMENTATION.

  METHOD timer.

    result = me.
    _add( n   = `Timer`
          ns  = `z2ui5`
          t_p = VALUE #( ( n = `delayMS`     v = delayms )
                         ( n = `finished`    v = finished )
                         ( n = `checkRepeat` v = _2bool( checkrepeat ) )
              ) ).

  ENDMETHOD.

  METHOD file_uploader.

    result = me.
    _add( n   = `FileUploader`
          ns  = `z2ui5`
          t_p = VALUE #( (  n = `placeholder`        v = placeholder )
                         (  n = `upload`             v = upload )
                         (  n = `path`               v = path )
                         (  n = `value`              v = value )
                         (  n = `iconOnly`           v = _2bool( icononly ) )
                         (  n = `buttonOnly`         v = _2bool( buttononly ) )
                         (  n = `buttonText`         v = buttontext )
                         (  n = `uploadButtonText`   v = uploadbuttontext )
                         (  n = `fileType`           v = filetype )
                         (  n = `checkDirectUpload`  v = _2bool( checkdirectupload ) ) ) ).

  ENDMETHOD.

ENDCLASS.
