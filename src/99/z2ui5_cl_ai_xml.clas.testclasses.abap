CLASS ltcl_builder DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS render_nested_view FOR TESTING.
    METHODS attr_targets_last_child FOR TESTING.
    METHODS attr_after_shut FOR TESTING.
    METHODS upfront_attr_table FOR TESTING.
    METHODS escape_attribute_value FOR TESTING.
    METHODS escape_whitespace_chars FOR TESTING.
    METHODS as_bool_literals FOR TESTING.
ENDCLASS.


CLASS ltcl_builder IMPLEMENTATION.

  METHOD render_nested_view.

    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->open( n  = `View`
                ns = `mvc`
        )->a( n = `xmlns`
              v = `sap.m`

        )->leaf( `Text`
            )->a( n = `text`
                  v = `Hello`

        )->open( `Panel`
            )->leaf( `Title`

        )->shut( ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<mvc:View xmlns="sap.m"><Text text="Hello"/><Panel><Title/></Panel></mvc:View>` ).

  ENDMETHOD.


  METHOD attr_targets_last_child.

    " after a leaf the chain stays on the parent - a( ) must still hit the leaf
    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->open( `Page`
        )->leaf( `Text`
            )->a( n = `text`
                  v = `first`
        )->leaf( `Text`
            )->a( n = `text`
                  v = `second` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Page><Text text="first"/><Text text="second"/></Page>` ).

  ENDMETHOD.


  METHOD attr_after_shut.

    " after a shut the chain points at the parent whose last child is the
    " container just closed - a( ) attaches to that container
    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->open( `Panel`
        )->leaf( `Title`

      )->shut(
        )->a( n = `width`
              v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel width="100%"><Title/></Panel>` ).

  ENDMETHOD.


  METHOD upfront_attr_table.

    " attributes passed as a `key=value` table split on the FIRST equals sign
    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->leaf( n = `Text`
                a = VALUE #( ( `text=a=b` ) ( `width=100%` ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="a=b" width="100%"/>` ).

  ENDMETHOD.


  METHOD escape_attribute_value.

    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->leaf( `Text`
        )->a( n = `text`
              v = `a<b>&"c` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="a&lt;b&gt;&amp;&quot;c"/>` ).

  ENDMETHOD.


  METHOD escape_whitespace_chars.

    " a literal LF/TAB in an attribute value must survive XML attribute-value
    " normalization as a character reference (e.g. a two-line noDataText)
    DATA(view) = z2ui5_cl_ai_xml=>factory( ).

    view->leaf( `Text`
        )->a( n = `text`
              v = |line1{ z2ui5_cl_ui5_context=>cv_char_util_newline }line2{ z2ui5_cl_ui5_context=>cv_char_util_horizontal_tab }end| ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="line1&#xA;line2&#x9;end"/>` ).

  ENDMETHOD.


  METHOD as_bool_literals.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ai_xml=>as_bool( abap_true )
      exp = `true` ).
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ai_xml=>as_bool( abap_false )
      exp = `false` ).

  ENDMETHOD.

ENDCLASS.
