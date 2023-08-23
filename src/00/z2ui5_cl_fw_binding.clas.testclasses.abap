
CLASS ltcl_value DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    DATA mv_value TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS test_one_way FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_t_attri FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_multiple FOR TESTING RAISING cx_static_check.
    METHODS test_two_way FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_two_way_error FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_value IMPLEMENTATION.

  METHOD test_one_way.

    DATA(lo_app) = NEW ltcl_value( ).
    lo_app->mv_value = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->mv_value
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_result
        exp = `/MV_VALUE` ).

  ENDMETHOD.

  METHOD test_two_way.

    DATA(lo_app) = NEW ltcl_value( ).
    lo_app->mv_value = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-two_way
        data     = lo_app->mv_value
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/` && z2ui5_cl_fw_binding=>cv_model_edit_name && `/MV_VALUE` ).

  ENDMETHOD.

  METHOD test_one_way_t_attri.

    DATA(lo_app) = NEW ltcl_value( ).
    lo_app->mv_value = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->mv_value
    ).

    lo_bind->main( ).

    DATA(ls_attri) = lo_bind->mt_attri[ name = `MV_VALUE` bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way ] ##NEEDED.

  ENDMETHOD.

  METHOD test_one_way_multiple.

    DATA(lo_app) = NEW ltcl_value( ).
    lo_app->mv_value = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-two_way
        data     = lo_app->mv_value
    ).

    DATA(lv_result) = lo_bind->main( ).

    DATA(lo_bind2) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-two_way
        data     = lo_app->mv_value
    ).

    DATA(lv_result2) = lo_bind2->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = lv_result2 ).

  ENDMETHOD.

  METHOD test_one_way_two_way_error.

    DATA(lo_app) = NEW ltcl_value( ).
    lo_app->mv_value = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->mv_value
    ).

    lo_bind->main( ).

    DATA(lo_bind2) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lo_bind->mt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-two_way
        data     = lo_app->mv_value
    ).

    TRY.

        lo_bind2->main( ).
        cl_abap_unit_assert=>fail( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_structure DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF s_01,
        input TYPE string,
        BEGIN OF s_02,
          input TYPE string,
          BEGIN OF s_03,
            input TYPE string,
            BEGIN OF s_04,
              input TYPE string,
            END OF s_04,
          END OF s_03,
        END OF s_02,
      END OF s_01.

    DATA ms_struc TYPE s_01.

  PRIVATE SECTION.

    METHODS test_one_way_lev1 FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev2 FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_lev3 FOR TESTING RAISING cx_static_check.

    METHODS test_one_way_lev4_long_name FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_structure IMPLEMENTATION.

  METHOD test_one_way_lev1.

    DATA(lo_app) = NEW ltcl_structure( ).
    lo_app->ms_struc-input = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->ms_struc-input
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MS_STRUC_INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_lev2.

    DATA(lo_app) = NEW ltcl_structure( ).
    lo_app->ms_struc-s_02-input = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->ms_struc-s_02-input
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MS_STRUC_S_02_INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_lev3.

    DATA(lo_app) = NEW ltcl_structure( ).
    lo_app->ms_struc-s_02-s_03-input = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->ms_struc-s_02-s_03-input
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MS_STRUC_S_02_S_03_INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_lev4_long_name.

    DATA(lo_app) = NEW ltcl_structure( ).
    lo_app->ms_struc-s_02-s_03-s_04-input = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->ms_struc-s_02-s_03-s_04-input
    ).

    DATA(lv_result) = lo_bind->main( ).

    DATA(ls_attri) = lo_bind->mt_attri[ name = `MS_STRUC-S_02-S_03-S_04-INPUT` bind_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way ].

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/` && ls_attri-name_front ).

  ENDMETHOD.

ENDCLASS.

class ltcl_general definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      first_test for testing raising cx_static_check.
endclass.


class ltcl_general implementation.

  method first_test.



  endmethod.

endclass.

CLASS ltcl_data_ref DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_01,
        input    TYPE string,
        input_02 TYPE string,
        input_03 TYPE string,
      END OF ty_s_01.

    DATA mr_value TYPE REF TO data.
    DATA mr_struc TYPE REF TO data.

  PRIVATE SECTION.

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_data_ref IMPLEMENTATION.

  METHOD test_one_way_value.

    DATA(lo_app) = NEW ltcl_data_ref( ).

    FIELD-SYMBOLS <field> TYPE any.
    CREATE DATA lo_app->mr_value TYPE string.
    ASSIGN (`LO_APP->MR_VALUE->*`) TO <field>.
    <field> = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = <field>
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MR_VALUE___` ).

  ENDMETHOD.

  METHOD test_one_way_struc.

    DATA(lo_app) = NEW ltcl_data_ref( ).

    CREATE DATA lo_app->mr_struc TYPE ty_s_01.
    FIELD-SYMBOLS <field> TYPE any.
    ASSIGN (`LO_APP->MR_STRUC->INPUT`) TO <field>.
    <field> = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = <field>
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MR_STRUC__INPUT` ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_object DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_01,
        input    TYPE string,
        input_02 TYPE string,
        input_03 TYPE string,
      END OF ty_s_01.

    DATA mv_value TYPE string.
    DATA ms_struc TYPE ty_s_01.

    DATA mo_obj TYPE REF TO ltcl_object.

  PRIVATE SECTION.

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_object IMPLEMENTATION.

  METHOD test_one_way_value.

    DATA(lo_app) = NEW ltcl_object( ).
    lo_app->mo_obj = NEW #( ).
    lo_app->mo_obj->mv_value = `my value`.


    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->mo_obj->mv_value
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MO_OBJ__MV_VALUE` ).

  ENDMETHOD.

  METHOD test_one_way_struc.

    DATA(lo_app) = NEW ltcl_object( ).
    lo_app->mo_obj = NEW #( ).
    lo_app->mo_obj->ms_struc-input = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = lo_app->mo_obj->ms_struc-input
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MO_OBJ__MS_STRUC_INPUT` ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_object_ref_app DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_01,
        input    TYPE string,
        input_02 TYPE string,
        input_03 TYPE string,
      END OF ty_s_01.
    TYPES ty_t_01 TYPE STANDARD TABLE OF ty_s_01 WITH EMPTY KEY.

    DATA mr_value TYPE REF TO data.
    DATA mr_struc TYPE REF TO data.
    DATA mr_tab   TYPE REF TO data.

  PRIVATE SECTION.

ENDCLASS.

CLASS ltcl_object_ref DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    DATA mo_obj TYPE REF TO ltcl_object_ref_app.

  PRIVATE SECTION.

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_tab FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_object_ref IMPLEMENTATION.

  METHOD test_one_way_value.

    DATA(lo_app) = NEW ltcl_object_ref( ).
    lo_app->mo_obj = NEW #( ).
    CREATE DATA lo_app->mo_obj->mr_value TYPE string.

    FIELD-SYMBOLS <any> TYPE any.
    ASSIGN ('LO_APP->MO_OBJ->MR_VALUE->*') TO <any>.
    <any> = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = <any>
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MO_OBJ__MR_VALUE___` ).

  ENDMETHOD.

  METHOD test_one_way_struc.

    DATA(lo_app) = NEW ltcl_object_ref( ).
    lo_app->mo_obj = NEW #( ).
    CREATE DATA lo_app->mo_obj->mr_struc TYPE ltcl_object_ref_app=>ty_s_01.

    FIELD-SYMBOLS <any> TYPE any.
    ASSIGN ('LO_APP->MO_OBJ->MR_STRUC->INPUT') TO <any>.

    <any> = `my value`.

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = <any>
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MO_OBJ__MR_STRUC__INPUT` ).

  ENDMETHOD.

  METHOD test_one_way_tab.

    DATA(lo_app) = NEW ltcl_object_ref( ).
    lo_app->mo_obj = NEW #( ).
    CREATE DATA lo_app->mo_obj->mr_tab TYPE  ltcl_object_ref_app=>ty_t_01.

    FIELD-SYMBOLS <any> TYPE  ltcl_object_ref_app=>ty_t_01.
    ASSIGN ('LO_APP->MO_OBJ->MR_TAB->*') TO <any>.


    <any> = VALUE #( (  input = 'test' ) ).

    DATA(lt_attri) = VALUE z2ui5_cl_fw_binding=>ty_t_attri( ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        attri    = lt_attri
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = <any>
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MO_OBJ__MR_TAB___` ).

  ENDMETHOD.

ENDCLASS.
