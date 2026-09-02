"! <p class="shorttext synchronized">abap2UI5 - JSON reader</p>
"!
"! The released way for APP code to read a JSON string - an event argument, a
"! control payload, a value help result. It exists because nothing portable
"! does the job on every release abap2UI5 ships to: /ui2/cl_json is not
"! released for ABAP Cloud, xco_cp_json does not exist on 7.02, and the
"! vendored ajson in src/00 is an internal the linter's non-released-api rule
"! rightly refuses to app code (see docs/removal-plan.md section 5).
"!
"! A thin veneer over that ajson, deliberately READ-ONLY and deliberately
"! small: parse once via factory( ), then address values by path
"! (`/order/items/1/name` - arrays are 1-based). Iteration goes through
"! members( ), which lists an object's keys and an array's indices in
"! document order. Anything beyond that - building JSON, typed mapping into
"! structures - is the framework's business, not this surface's.
CLASS z2ui5_cl_ui5_json DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.

    "! Parse a JSON string into a reader. Invalid JSON raises
    "! z2ui5_cx_ui5_util_error with the parser's error as the cause.
    "! @parameter val | the JSON text
    CLASS-METHODS factory
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_json.

    "! The value at the path as a string - numbers and booleans arrive as
    "! their raw JSON text, a missing path as the empty string.
    METHODS get_string
      IMPORTING
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    "! The JSON NUMBER at the path; 0 when the path is missing or the value
    "! is not a number (a number sent as a string is read with get_string).
    METHODS get_integer
      IMPORTING
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE i.

    "! The JSON boolean at the path; abap_false when missing or not true.
    METHODS get_boolean
      IMPORTING
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! abap_true when a node exists at the path - the way to tell an absent
    "! value from an empty one.
    METHODS exists
      IMPORTING
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! The child names under the path, in document order: an object's member
    "! names, an array's indices (`1`, `2`, ...). Loop over them and build
    "! the child path per entry to iterate.
    METHODS members
      IMPORTING
        path          TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mi_json TYPE REF TO z2ui5_if_ajson.

ENDCLASS.


CLASS z2ui5_cl_ui5_json IMPLEMENTATION.

  METHOD factory.

    TRY.
        result = NEW #( ).
        result->mi_json = z2ui5_cl_ajson=>parse( val ).
      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING
            val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD get_string.

    DATA(lv_path) = CONV string( path ).
    result = mi_json->get_string( lv_path ).

  ENDMETHOD.

  METHOD get_integer.

    DATA(lv_path) = CONV string( path ).
    result = mi_json->get_integer( lv_path ).

  ENDMETHOD.

  METHOD get_boolean.

    DATA(lv_path) = CONV string( path ).
    " ajson's get_boolean answers abap_true for ANY non-empty value that is
    " not a JSON boolean - the number 0, the string "false", "abc" - which
    " is not what the contract above promises. Only a boolean node is asked
    IF mi_json->get_node_type( lv_path ) = z2ui5_if_ajson_types=>node_type-boolean.
      result = mi_json->get_boolean( lv_path ).
    ENDIF.

  ENDMETHOD.

  METHOD exists.

    DATA(lv_path) = CONV string( path ).
    result = mi_json->exists( lv_path ).

  ENDMETHOD.

  METHOD members.

    DATA(lv_path) = CONV string( path ).
    result = mi_json->members( lv_path ).

  ENDMETHOD.

ENDCLASS.
