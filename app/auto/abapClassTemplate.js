module.exports = function(className, formattedContent) {
    return `CLASS ${className} DEFINITION
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


CLASS ${className} IMPLEMENTATION.

  METHOD get.

    result = ${formattedContent}
              \`\`.

  ENDMETHOD.

ENDCLASS.`;
};