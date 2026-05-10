CLASS z2ui5_cl_app_flexibility-bundle_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_flexibility-bundle_json IMPLEMENTATION.

  METHOD get.

    result = `{` &&
             `  "changes": [],` &&
             `  "compVariants": [],` &&
             `  "variants": [],` &&
             `  "variantChanges": [],` &&
             `  "variantDependentControlChanges": [],` &&
             `  "variantManagementChanges": []` &&
             `}` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
