CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL DANGEROUS.

  PUBLIC SECTION.
    DATA quantity          TYPE string.

  PRIVATE SECTION.
    METHODS test_model_set_frontend FOR TESTING RAISING cx_static_check.
    METHODS test_model_set_backend  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_model_set_frontend.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ( name = `QUANTITY` bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way  name_front = `QUANTITY` ) ).
    DATA(lo_app)   = NEW ltcl_unit_test( ).

    lo_app->quantity = `600`.

    DATA(lo_model) = z2ui5_cl_fw_model=>factory(
        viewname = ``
        app      = lo_app
        attri    = lt_attri ).

    DATA(lv_frontend) = lo_model->main_set_frontend( ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_frontend
        exp = `{"EDIT":{"QUANTITY":"600"}}` ).

  ENDMETHOD.

  METHOD test_model_set_backend.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ( name = `QUANTITY` bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way  name_front = `QUANTITY` ) ).
    DATA(lo_app)   = NEW ltcl_unit_test( ).

    DATA(lv_model) = `{"EDIT":{"QUANTITY":"600"},"oScroll":[],"OMESSAGEMANAGER":[],"ID":"0242B09497911EDE90A60CD0D8519DD5","ARGUMENTS":[{"EVENT":"BUTTON_POST","METHOD":"UPDATE","CHECK_VIEW_DESTROY":false}],"OCURSOR":{"id":"__button1"},"OLOCATION":{`
      && `"SEARCH":"?sap-client=001&app_start=z2ui5_cl_app_hello_world","VERSION":"com.sap.ui5.dist:sapui5-sdk-dist:1.116.0:war"}}`.

    DATA lr_model TYPE REF TO data.
    FIELD-SYMBOLS <any> TYPE any.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = lv_model
      CHANGING
        data = lr_model ).

    DATA(lo_model) = z2ui5_cl_fw_model=>factory(
      viewname = ``
      app      = lo_app
      attri    = lt_attri ).

    DATA(lv_assign) = `LR_MODEL->` && z2ui5_cl_fw_binding=>cv_model_edit_name.

    ASSIGN (lv_assign) TO <any>.
    lo_model->main_set_backend( <any> ).

    cl_abap_unit_assert=>assert_equals(
        act = lo_app->quantity
        exp = `600` ).

  ENDMETHOD.

ENDCLASS.
