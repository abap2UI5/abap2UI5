CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    DATA quantity          TYPE string.

  PRIVATE SECTION.
    METHODS test_model_set_frontend FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_model_set_frontend.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ( name = `QUANTITY` bind_type = z2ui5_cl_fw_binding=>cs_bind_type-two_way  name_front = `QUANTITY` ) ).
    DATA(lo_app)   = NEW ltcl_unit_test( ).

    lo_app->quantity = `600`.

    DATA(lo_model) = z2ui5_cl_fw_model=>factory(
        app      = lo_app
        attri    = lt_attri ).

    DATA(lv_frontend) = lo_model->main_set_frontend( ).

    cl_abap_unit_assert=>assert_equals(
        act                  =  lv_frontend
        exp                  =  `{"EDIT":{"QUANTITY":"600"}}`
   ).


  ENDMETHOD.

ENDCLASS.
