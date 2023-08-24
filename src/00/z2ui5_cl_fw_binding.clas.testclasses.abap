
CLASS ltcl_test_dissolve DEFINITION DEFERRED.
CLASS z2ui5_cl_fw_binding DEFINITION LOCAL FRIENDS ltcl_test_dissolve.

CLASS ltcl_test_dissolve DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
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

    DATA ms_struc TYPE s_01 ##NEEDED.
    DATA mv_value TYPE string ##NEEDED.
    DATA mr_value TYPE REF TO data.
    DATA mr_struc TYPE REF TO s_01.
    DATA mo_app TYPE REF TO ltcl_test_dissolve.

  PRIVATE SECTION.
    METHODS test_dissolve_init  FOR TESTING RAISING cx_static_check.
    METHODS test_dissolve_struc FOR TESTING RAISING cx_static_check.
    METHODS test_dissolve_dref  FOR TESTING RAISING cx_static_check.
    METHODS test_dissolve_oref  FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_dissolve IMPLEMENTATION.

  METHOD test_dissolve_init.

    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
    lo_bind->mo_app = lo_app.

    lo_bind->dissolve_init( ).
    DATA(lt_dissolve) = lo_bind->mt_attri.

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MV_VALUE` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_dissolve_dref.

    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
    lo_bind->mo_app = lo_app.

    CREATE DATA lo_app->mr_struc.
    CREATE DATA lo_app->mr_value TYPE string.

    lo_bind->dissolve_init( ).
    lo_bind->dissolve_dref( ).
    DATA(lt_dissolve) = lo_bind->mt_attri.

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_STRUC->*` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_VALUE->*` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MV_VALUE` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_dissolve_oref.

    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
    lo_bind->mo_app = lo_app.

    CREATE DATA lo_app->mo_app->mr_struc.
    CREATE DATA lo_app->mo_app->mr_value TYPE string.

    lo_bind->dissolve_init( ).
    lo_bind->dissolve_oref( ).
    DATA(lt_dissolve) = lo_bind->mt_attri.

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP->MV_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP->MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP->MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP->MS_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MV_VALUE` ] OPTIONAL ) ).

  ENDMETHOD.

  METHOD test_dissolve_struc.

    DATA(lo_app)    = NEW ltcl_test_dissolve( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).
    lo_bind->mo_app = lo_app.

    lo_bind->dissolve_init( ).
    lo_bind->dissolve_struc( ).
    DATA(lt_dissolve) = lo_bind->mt_attri.

    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MO_APP` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC-INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC-S_02-INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC-S_02-S_03-S_04-INPUT` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MR_VALUE` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MS_STRUC` ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_not_initial( VALUE #( lt_dissolve[ name = `MV_VALUE` ] OPTIONAL ) ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_bind DEFINITION DEFERRED.
CLASS z2ui5_cl_fw_binding DEFINITION LOCAL FRIENDS ltcl_test_bind.

CLASS ltcl_test_bind DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
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
    DATA mv_value TYPE string.
    DATA mr_value TYPE REF TO data.
    DATA mr_struc TYPE REF TO s_01.
    DATA mo_app TYPE REF TO ltcl_test_bind.

  PRIVATE SECTION.
    METHODS test_value      FOR TESTING RAISING cx_static_check.
    METHODS test_struc      FOR TESTING RAISING cx_static_check.
    METHODS test_dref_val   FOR TESTING RAISING cx_static_check.
    METHODS test_dref_struc FOR TESTING RAISING cx_static_check.
    METHODS test_oref_val   FOR TESTING RAISING cx_static_check.
    METHODS test_oref_struc FOR TESTING RAISING cx_static_check.
    METHODS test_oref_dref_val FOR TESTING RAISING cx_static_check.
    METHODS test_local      FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_bind IMPLEMENTATION.

  METHOD test_value.

    DATA(lo_app)    = NEW ltcl_test_bind( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( lo_app->mv_value ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MV_VALUE` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MV_VALUE` ).

  ENDMETHOD.


  METHOD test_struc.

    DATA(lo_app)    = NEW ltcl_test_bind( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( lo_app->ms_struc-s_02-s_03-s_04-input ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MS_STRUC-S_02-S_03-S_04-INPUT` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MS_STRUC_S_02_S_03_S_04_INPUT` ).

  ENDMETHOD.


  METHOD test_dref_val.

    DATA(lo_app)  = NEW ltcl_test_bind( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).

    FIELD-SYMBOLS <any> TYPE any.
    CREATE DATA lo_app->mr_value TYPE string.
    ASSIGN lo_app->mr_value->* TO <any>.

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( <any> ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MR_VALUE->*` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MR_VALUE___` ).

  ENDMETHOD.

  METHOD test_dref_struc.

    DATA(lo_app)  = NEW ltcl_test_bind( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).

    FIELD-SYMBOLS <any> TYPE any.
    CREATE DATA lo_app->mr_struc.
    ASSIGN lo_app->mr_struc->input TO <any>.

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( <any> ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MR_STRUC->INPUT` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MR_STRUC__INPUT` ).

  ENDMETHOD.

  METHOD test_oref_val.

    DATA(lo_app)  = NEW ltcl_test_bind( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( lo_app->mo_app->mv_value ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MO_APP->MV_VALUE` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MO_APP__MV_VALUE` ).

  ENDMETHOD.

  METHOD test_oref_struc.

    DATA(lo_app)  = NEW ltcl_test_bind( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_bind) = NEW z2ui5_cl_fw_binding( ).

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( lo_app->mo_app->ms_struc-input ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MO_APP->MS_STRUC-INPUT` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MO_APP__MS_STRUC_INPUT` ).

  ENDMETHOD.

  METHOD test_oref_dref_val.

    DATA(lo_app)   = NEW ltcl_test_bind( ).
    lo_app->mo_app = NEW #( ).
    DATA(lo_bind)  = NEW z2ui5_cl_fw_binding( ).

    FIELD-SYMBOLS <any> TYPE any.
    CREATE DATA lo_app->mo_app->mr_value TYPE string.
    ASSIGN lo_app->mo_app->mr_value->* TO <any>.

    lo_bind->mo_app = lo_app.
    lo_bind->mr_data = REF #( <any> ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_way.

    DATA(ls_attri) = VALUE z2ui5_cl_fw_binding=>ty_s_attri( name = `MO_APP->MR_VALUE->*` ).
    DATA(lv_result) = lo_bind->bind( REF #( ls_attri ) ).

    cl_abap_unit_assert=>assert_equals(
     act                  = lv_result
     exp                  = `/MO_APP__MR_VALUE___` ).

  ENDMETHOD.

  METHOD test_local.

    DATA(lo_bind)  = NEW z2ui5_cl_fw_binding( ).
    DATA(lv_value) = `test`.
    lo_bind->mr_data = REF #( lv_value ).
    lo_bind->mv_type = z2ui5_cl_fw_binding=>cs_bind_type-one_time.

    DATA(lv_result) = lo_bind->bind_local( ).

    IF lv_result IS INITIAL.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_test_main_value DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
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

CLASS ltcl_test_main_value IMPLEMENTATION.

  METHOD test_one_way.

    DATA(lo_app) = NEW ltcl_test_main_value( ).
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

    DATA(lo_app) = NEW ltcl_test_main_value( ).
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

    DATA(lo_app) = NEW ltcl_test_main_value( ).
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

    DATA(lo_app) = NEW ltcl_test_main_value( ).
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

    DATA(lo_app) = NEW ltcl_test_main_value( ).
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

CLASS ltcl_test_main_structure DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
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

CLASS ltcl_test_main_structure IMPLEMENTATION.

  METHOD test_one_way_lev1.

    DATA(lo_app) = NEW ltcl_test_main_structure( ).
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

    DATA(lo_app) = NEW ltcl_test_main_structure( ).
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

    DATA(lo_app) = NEW ltcl_test_main_structure( ).
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

    DATA(lo_app) = NEW ltcl_test_main_structure( ).
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

CLASS ltcl_test_main_data_ref DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
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

CLASS ltcl_test_main_data_ref IMPLEMENTATION.

  METHOD test_one_way_value.

    DATA(lo_app) = NEW ltcl_test_main_data_ref( ).

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

    DATA(lo_app) = NEW ltcl_test_main_data_ref( ).

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

CLASS ltcl_test_main_object DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
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

    DATA mo_obj TYPE REF TO ltcl_test_main_object.

  PRIVATE SECTION.

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.


ENDCLASS.

CLASS ltcl_test_main_object IMPLEMENTATION.

  METHOD test_one_way_value.

    DATA(lo_app) = NEW ltcl_test_main_object( ).
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

    DATA(lo_app) = NEW ltcl_test_main_object( ).
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

CLASS ltcl_test_main_object_ref_app DEFINITION.

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

CLASS ltcl_test_main_object_ref DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    DATA mo_obj TYPE REF TO ltcl_test_main_object_ref_app.

  PRIVATE SECTION.

    METHODS test_one_way_value FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_struc FOR TESTING RAISING cx_static_check.
    METHODS test_one_way_tab   FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_test_main_object_ref IMPLEMENTATION.

  METHOD test_one_way_value.

    DATA(lo_app) = NEW ltcl_test_main_object_ref( ).
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

    DATA(lo_app) = NEW ltcl_test_main_object_ref( ).
    lo_app->mo_obj = NEW #( ).
    CREATE DATA lo_app->mo_obj->mr_struc TYPE ltcl_test_main_object_ref_app=>ty_s_01.

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

    DATA(lo_app) = NEW ltcl_test_main_object_ref( ).
    lo_app->mo_obj = NEW #( ).
    CREATE DATA lo_app->mo_obj->mr_tab TYPE  ltcl_test_main_object_ref_app=>ty_t_01.

    FIELD-SYMBOLS <any> TYPE  ltcl_test_main_object_ref_app=>ty_t_01.
    ASSIGN ('LO_APP->MO_OBJ->MR_TAB->*') TO <any>.

    <any> = VALUE #( (  input = 'test' ) ).

    DATA(lo_bind) = z2ui5_cl_fw_binding=>factory(
        app      = lo_app
        type     = z2ui5_cl_fw_binding=>cs_bind_type-one_way
        data     = <any>
    ).

    DATA(lv_result) = lo_bind->main( ).

    cl_abap_unit_assert=>assert_equals(
        act                  = lv_result
        exp                  = `/MO_OBJ__MR_TAB___` ).

  ENDMETHOD.

ENDCLASS.
