CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION long
  RISK LEVEL DANGEROUS.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    DATA mr_data TYPE REF TO data.

  PRIVATE SECTION.
    METHODS test_trans_xml FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_trans_xml.

    DATA(lo_app) = NEW ltcl_test( ).

    TYPES:
      BEGIN OF ty_s_attri,
        name      TYPE string,
        type_kind TYPE string,
        type      TYPE string,
      END OF ty_s_attri.
    TYPES ty_t_attri TYPE STANDARD TABLE OF ty_s_attri WITH EMPTY KEY.

    DATA(ls_tab) = VALUE ty_s_attri( ).
    DATA(lt_table) = VALUE ty_t_attri( ).

    DATA(lo_tab_desc) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( lt_table ) ).
    DATA(o_struct_desc) = CAST cl_abap_structdescr( lo_tab_desc->get_table_line_type( ) ).
    DATA(comp) = o_struct_desc->get_components( ).

    INSERT VALUE abap_componentdescr( name = 'ROW_ID'
                                      type = CAST #( cl_abap_datadescr=>describe_by_data( ls_tab-type ) ) )
                            INTO TABLE comp.

    DATA(new_struct_desc) = cl_abap_structdescr=>create( comp ).
    DATA(new_table_desc) = cl_abap_tabledescr=>create(
      p_line_type  = new_struct_desc
      p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA lo_app->mr_data TYPE HANDLE new_table_desc.

    FIELD-SYMBOLS <tab> TYPE table.
    ASSIGN lo_app->mr_data->* TO <tab>.

    DATA(lt_tab) = VALUE ty_t_attri( ( name = `test` ) ).

    DATA lr_struc TYPE REF TO data.
    FIELD-SYMBOLS <any> TYPE any.
    LOOP AT lt_tab INTO DATA(ls_tab2).
      CREATE DATA lr_struc TYPE HANDLE new_struct_desc.
      ASSIGN lr_struc->* TO <any>.
      <any> = CORRESPONDING #( ls_tab2 ).
      INSERT <any> INTO TABLE <tab>.
    ENDLOOP.

    TRY.

        DATA(lv_xml) = z2ui5_cl_fw_db=>trans_any_2_xml( VALUE #( app = lo_app )  ).
        cl_abap_unit_assert=>assert_not_initial( lv_xml ).

      CATCH z2ui5_cx_fw_error.
        " when rtti not installed, then no test...
    ENDTRY.



  ENDMETHOD.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.

ENDCLASS.
