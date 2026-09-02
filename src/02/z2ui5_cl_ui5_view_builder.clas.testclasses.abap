CLASS ltcl_builder DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS render_nested_view FOR TESTING.
    METHODS a_after_ele_hits_the_element FOR TESTING.
    METHODS a_after_tag_hits_the_tag FOR TESTING.
    METHODS a_after_end_hits_closed_ele FOR TESTING.
    METHODS tag_stays_and_siblings FOR TESTING.
    METHODS trailing_end_is_optional FOR TESTING.
    METHODS escape_attribute_value FOR TESTING.
    METHODS escape_whitespace_chars FOR TESTING.
    METHODS escape_control_chars FOR TESTING.
    METHODS escape_literal_braces FOR TESTING.
    METHODS escape_literal_passthrough FOR TESTING.
    METHODS bool_parameter FOR TESTING.
ENDCLASS.


CLASS ltcl_builder IMPLEMENTATION.

  METHOD render_nested_view.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( n  = `View`
               ns = `mvc`
        )->a( n   = `xmlns`
                v = `sap.m`

        )->tag( `Text`
            )->a( n   = `text`
                    v = `Hello`

        )->ele( `Panel`
            )->tag( `Title` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<mvc:View xmlns="sap.m"><Text text="Hello"/><Panel><Title/></Panel></mvc:View>` ).

  ENDMETHOD.


  METHOD a_after_ele_hits_the_element.

    " ele( ) descends into a node that has no children yet, so a( ) sets the
    " attribute on that node itself
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Page`
        )->a( n   = `title`
                v = `Home`
        )->ele( `Panel`
            )->a( n   = `width`
                    v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Page title="Home"><Panel width="100%"/></Page>` ).

  ENDMETHOD.


  METHOD a_after_tag_hits_the_tag.

    " tag( ) does not move, but the tag is now this node's last child, so the
    " a( ) still reaches it - this is what makes tag( ) usable for a leaf
    " that carries attributes
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Panel`
        )->tag( `Title`
            )->a( n   = `width`
                    v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel><Title width="100%"/></Panel>` ).

  ENDMETHOD.


  METHOD a_after_end_hits_closed_ele.

    " after end( ) the chain stands on the parent, whose last child is the
    " container just closed - so a( ) attaches to that container, not to the
    " parent. The flip side of the rule: an element that already has children
    " can no longer be given an attribute
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Page`
        )->ele( `Panel`
            )->tag( `Title`
        )->end(
        )->a( n   = `width`
                v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Page><Panel width="100%"><Title/></Panel></Page>` ).

  ENDMETHOD.


  METHOD tag_stays_and_siblings.

    " tag( ) does not move, so siblings follow directly and no end( ) is
    " needed - each a( ) block travels with the tag it follows
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Page`
        )->tag( `Text`
            )->a( n   = `text`
                    v = `first`
        )->tag( n  = `Text`
                ns = `m`
            )->a( n   = `text`
                    v = `second`
        )->tag( `ToolbarSpacer` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Page><Text text="first"/><m:Text text="second"/><ToolbarSpacer/></Page>` ).

  ENDMETHOD.


  METHOD trailing_end_is_optional.

    " stringify( ) renders from the root, so the chain may simply stop
    DATA(closed) = z2ui5_cl_ui5_view_builder=>factory( ).
    closed->ele( `Page`
        )->ele( `Panel`
            )->ele( `Title`
            )->end(
        )->end( ).

    DATA(open) = z2ui5_cl_ui5_view_builder=>factory( ).
    open->ele( `Page`
        )->ele( `Panel`
            )->ele( `Title` ).

    cl_abap_unit_assert=>assert_equals(
      act = open->stringify( )
      exp = closed->stringify( ) ).

  ENDMETHOD.


  METHOD escape_attribute_value.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->tag( `Text`
        )->a( n   = `text`
                v = `a<b>&"c` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="a&lt;b&gt;&amp;&quot;c"/>` ).

  ENDMETHOD.


  METHOD escape_whitespace_chars.

    " a literal LF/TAB in an attribute value must survive XML attribute-value
    " normalization as a character reference (e.g. a two-line noDataText)
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->tag( `Text`
        )->a( n   = `text`
                v = |line1{ z2ui5_cl_ui5_util_context=>cv_char_util_newline }line2{ z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab }end| ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="line1&#xA;line2&#x9;end"/>` ).

  ENDMETHOD.


  METHOD escape_control_chars.

    " a form feed (U+000C) and a record separator (U+001E) out of a legacy
    " long text: illegal in XML 1.0 even as a character reference, the whole
    " view failed at the parser - they are dropped, the legal whitespace
    " next to them still becomes its character reference
    DATA(lv_ctrl) = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( CONV xstring( `0C1E` ) ).
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->tag( `Text`
        )->a( n   = `text`
                v = |a{ lv_ctrl }b{ z2ui5_cl_ui5_util_context=>cv_char_util_horizontal_tab }c| ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="ab&#x9;c"/>` ).

  ENDMETHOD.

  METHOD escape_literal_braces.

    " a braced value is parsed by the UI5 binding parser, so literal text
    " needs UI5's backslash escaping - the backslash itself first, because
    " the parser unescapes the strings it processes
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `a {/PATH} b` )
      exp = `a \{/PATH\} b` ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `{= 1 > 0 }\x` )
      exp = `\{= 1 > 0 \}\\x` ).

  ENDMETHOD.


  METHOD escape_literal_passthrough.

    " no brace means UI5 never parses the value, and its backslashes stay
    " as they are - escaping them here would corrupt e.g. a Windows path
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `C:\temp\file` )
      exp = `C:\temp\file` ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `` )
      exp = `` ).

  ENDMETHOD.


  METHOD bool_parameter.

    " b is the only way to render a boolean - abap_false must come out as
    " `false`, not vanish, which is why it is read with IS SUPPLIED
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Panel`
        )->a( n   = `visible`
                b = abap_true
        )->a( n   = `expanded`
                b = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel visible="true" expanded="false"/>` ).

  ENDMETHOD.

ENDCLASS.
