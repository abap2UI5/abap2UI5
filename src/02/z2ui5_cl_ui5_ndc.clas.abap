CLASS z2ui5_cl_ui5_ndc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

  PUBLIC SECTION.
    METHODS barcodescannerbutton
      IMPORTING id              TYPE clike OPTIONAL
                scansuccess     TYPE clike OPTIONAL
                scanfail        TYPE clike OPTIONAL
                inputliveupdate TYPE clike OPTIONAL
                dialogtitle     TYPE clike OPTIONAL
      RETURNING VALUE(result)   TYPE REF TO z2ui5_cl_ui5_ndc.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_ndc IMPLEMENTATION.
  METHOD barcodescannerbutton.
    result = _add( n   = `BarcodeScannerButton`
                   ns  = 'sap.ndc'
                   t_p = VALUE #( ( n = `id`                 v = id )
                                  ( n = `scanSuccess`        v = scansuccess )
                                  ( n = `scanFail`           v = scanfail )
                                  ( n = `inputLiveUpdate`    v = inputliveupdate )
                                  ( n = `dialogTitle`        v = dialogtitle ) ) )->_ns_ndc( ).
  ENDMETHOD.
ENDCLASS.
