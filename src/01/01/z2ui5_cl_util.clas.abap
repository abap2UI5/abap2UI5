CLASS z2ui5_cl_util DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_util_api
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS app_get_url_source_code
      IMPORTING
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url
      IMPORTING
        !client          TYPE REF TO z2ui5_if_client
        VALUE(classname) TYPE string OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    CLASS-METHODS db_delete_by_handle
      IMPORTING
        !uname        TYPE clike OPTIONAL
        !handle       TYPE clike OPTIONAL
        !handle2      TYPE clike OPTIONAL
        !handle3      TYPE clike OPTIONAL
        !check_commit TYPE abap_bool DEFAULT abap_true.

    CLASS-METHODS db_save
      IMPORTING
        !uname        TYPE clike OPTIONAL
        !handle       TYPE clike OPTIONAL
        !handle2      TYPE clike OPTIONAL
        !handle3      TYPE clike OPTIONAL
        !data         TYPE any
        !check_commit TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS db_load_by_id
      IMPORTING
        !id           TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

    CLASS-METHODS db_load_by_handle
      IMPORTING
        !uname        TYPE clike OPTIONAL
        !handle       TYPE clike OPTIONAL
        !handle2      TYPE clike OPTIONAL
        !handle3      TYPE clike OPTIONAL
      EXPORTING
        VALUE(result) TYPE any.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_util IMPLEMENTATION.


  METHOD app_get_url.

    IF classname IS INITIAL.
      classname = rtti_get_classname_by_ref( client->get_app( ) ).
    ENDIF.

    DATA(lv_url) = to_lower( client->get( )-s_config-origin && client->get( )-s_config-pathname ) && `?`.
    DATA(lt_param) = url_param_get_tab( client->get( )-s_config-search ).
    DELETE lt_param WHERE n = `app_start`.
    INSERT VALUE #( n = `app_start` v = to_lower( classname ) ) INTO TABLE lt_param.

    result = lv_url && url_param_create_url( lt_param ).

  ENDMETHOD.


  METHOD app_get_url_source_code.

    DATA(ls_config) = client->get( )-s_config.
    result = ls_config-origin && `/sap/bc/adt/oo/classes/`
       && rtti_get_classname_by_ref( client->get_app( ) ) && `/source/main`.

  ENDMETHOD.


  METHOD db_delete_by_handle.

    DELETE FROM z2ui5_t_core_02
        WHERE
           uname = @uname
            AND handle = @handle
            AND handle2 = @handle2
            AND handle3 = @handle3.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD db_load_by_handle.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_core_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_core_02
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `No entry for handle exists`.
    ENDIF.

    DATA(ls_db) = lt_db[ 1 ].

    xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_load_by_id.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_core_02 WITH EMPTY KEY.

    SELECT data
      FROM z2ui5_t_core_02
      WHERE id = @id
      INTO CORRESPONDING FIELDS OF TABLE @lt_db.
    ASSERT sy-subrc = 0.

    DATA(ls_db) = lt_db[ 1 ].

    xml_parse(
      EXPORTING
        xml = ls_db-data
      IMPORTING
        any = result ).

  ENDMETHOD.


  METHOD db_save.

    DATA lt_db TYPE STANDARD TABLE OF z2ui5_t_core_02 WITH EMPTY KEY.
    SELECT id
      FROM z2ui5_t_core_02
       WHERE
        uname = @uname
        AND handle = @handle
        AND handle2 = @handle2
        AND handle3 = @handle3
      INTO CORRESPONDING FIELDS OF TABLE @lt_db ##SUBRC_OK.

    DATA(ls_db) = VALUE z2ui5_t_core_02(
        uname   = uname
        handle  = handle
        handle2 = handle2
        handle3 = handle3
        data    = xml_stringify( data ) ).

    TRY.
        ls_db-id = lt_db[ 1 ]-id.
      CATCH cx_root.
        ls_db-id = uuid_get_c32( ).
    ENDTRY.

    MODIFY z2ui5_t_core_02 FROM @ls_db.
    ASSERT sy-subrc = 0.

    IF check_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    result = ls_db-id.

  ENDMETHOD.
ENDCLASS.
