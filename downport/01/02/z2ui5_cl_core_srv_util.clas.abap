CLASS z2ui5_cl_core_srv_util DEFINITION
  PUBLIC
  INHERITING FROM z2ui5_cl_util
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS app_get_url_source_code
      IMPORTING
        !client       TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS app_get_url
      IMPORTING
        !client          TYPE REF TO z2ui5_if_client
        VALUE(classname) TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_core_srv_util IMPLEMENTATION.
  METHOD app_get_url.
    DATA lv_url TYPE string.
    DATA lt_param TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp1 TYPE z2ui5_cl_util=>ty_s_name_value.

    IF classname IS INITIAL.
      classname = rtti_get_classname_by_ref( client->get_app( ) ).
    ENDIF.

    
    lv_url = |{ client->get( )-s_config-origin }{ client->get( )-s_config-pathname }?|.
    
    lt_param = url_param_get_tab( client->get( )-s_config-search ).
    DELETE lt_param WHERE n = `app_start`.
    
    CLEAR temp1.
    temp1-n = `app_start`.
    temp1-v = to_lower( classname ).
    INSERT temp1 INTO TABLE lt_param.

    result = lv_url && url_param_create_url( lt_param ) && client->get( )-s_config-hash.

  ENDMETHOD.

  METHOD app_get_url_source_code.

    DATA ls_config TYPE z2ui5_if_types=>ty_s_config.
    ls_config = client->get( )-s_config.
    result = |{ ls_config-origin }/sap/bc/adt/oo/classes/|
       && |{ rtti_get_classname_by_ref( client->get_app( ) ) }/source/main|.

  ENDMETHOD.
ENDCLASS.
