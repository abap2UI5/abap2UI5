CLASS lcl_db DEFINITION.


  PUBLIC SECTION.


    TYPES ty_t_table TYPE z2ui5_cl_app_demo_13=>ty_t_table.

    CLASS-DATA app TYPE REF TO z2ui5_cl_app_demo_13.
    "CLASS-DATA st_table TYPE ty_t_table.

    CLASS-METHODS generate_test_data.

    CLASS-METHODS get_table_by_json
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_table.

    CLASS-METHODS get_table_by_xml
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_table.

    CLASS-METHODS get_table_by_csv
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE ty_t_table.

    CLASS-METHODS get_csv_by_table
      IMPORTING
        val           TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_xml_by_table
      IMPORTING
        val           TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_json_by_table
      IMPORTING
        val           TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_fieldlist_by_table
      IMPORTING
        it_table      TYPE ty_t_table
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS db_save
      IMPORTING
        value TYPE ty_t_table.

    CLASS-METHODS db_read
      RETURNING
        VALUE(result) TYPE ty_t_table.
    CLASS-METHODS get_test_data_json
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_db IMPLEMENTATION.

  METHOD generate_test_data.

    app->st_db = VALUE #(
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
        ( carrid = 'DL' connid = '0106' countryfr = 'US' cityfrom = 'NEW YORK' airpfrom = 'JFK' countryto = 'DE' cityto = 'FRANKFURT' airpto = 'FR' )
    ).

  ENDMETHOD.


  METHOD get_table_by_json.

    DATA lt_tab TYPE ty_t_table.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = val
*        jsonx            =
*        pretty_name      =
*        assoc_arrays     =
*        assoc_arrays_opt =
*        name_mappings    =
*        conversion_exits =
*        hex_as_base64    =
      CHANGING
        data             = lt_tab
    ).

    result = lt_tab.

  ENDMETHOD.


  METHOD get_table_by_xml.

    DATA lt_tab TYPE ty_t_table.

    CALL TRANSFORMATION id SOURCE xml = val RESULT data = lt_tab.

    result = lt_tab.

  ENDMETHOD.

  METHOD get_table_by_csv.

    SPLIT val AT ';' INTO TABLE DATA(lt_cols).

    LOOP AT lt_cols INTO DATA(lv_field).

      DATA(ls_row) = VALUE z2ui5_cl_app_demo_13=>ty_s_spfli( ).
      DATA(lv_index) = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE ls_row TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        <field> = lv_field.
        lv_index = lv_index + 1.
      ENDDO.
      INSERT ls_row INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD db_save.

    "normally modify database here

    "test scenario, therefore write internal table instead
    app->st_db = value.

  ENDMETHOD.

  METHOD db_read.

    "normally read database here

    "test scenario, therefore read internal table instead

    result = app->st_db.

  ENDMETHOD.

  METHOD get_csv_by_table.

    LOOP AT val INTO DATA(ls_row).

      DATA(lv_index) = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE ls_row TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_index = lv_index + 1.
        result = result && <field> && ';'.
      ENDDO.
      result = result && cl_abap_char_utilities=>cr_lf.
    ENDLOOP.


  ENDMETHOD.

  METHOD get_json_by_table.

    result = /ui2/cl_json=>serialize(
               val
*               compress         =
*               name             =
*               pretty_name      =
*               type_descr       =
*               assoc_arrays     =
*               ts_as_iso8601    =
*               expand_includes  =
*               assoc_arrays_opt =
*               numc_as_string   =
*               name_mappings    =
*               conversion_exits =
           "   format_output    = abap_true
*               hex_as_base64    =
             ).


  ENDMETHOD.

  METHOD get_xml_by_table.

    CALL TRANSFORMATION id SOURCE values = val RESULT XML result.

  ENDMETHOD.

  METHOD get_fieldlist_by_table.

    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_datadescr=>describe_by_data( it_table ) ).
    DATA(lo_struc) = CAST cl_abap_structdescr( lo_tab->get_table_line_type( ) ).

    DATA(lt_comp) = lo_struc->get_components( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      INSERT ls_comp-name INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_test_data_json.

    result = `[` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  },` && |\n| &&
             `  {` && |\n| &&
             `    "CARRID": "DL",` && |\n| &&
             `    "CONNID": 106,` && |\n| &&
             `    "COUNTRYFR": "US",` && |\n| &&
             `    "CITYFROM": "NEW YORK",` && |\n| &&
             `    "AIRPFROM": "JFK",` && |\n| &&
             `    "COUNTRYTO": "DE",` && |\n| &&
             `    "CITYTO": "FRANKFURT",` && |\n| &&
             `    "AIRPTO": "FR"` && |\n| &&
             `  }` && |\n| &&
             `]`.

  ENDMETHOD.

ENDCLASS.
