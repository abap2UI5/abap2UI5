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
    METHODS escape_literal_backslash FOR TESTING.
    METHODS bool_parameter FOR TESTING.
    METHODS text_parameter FOR TESTING.
    METHODS text_parameter_empty FOR TESTING.
    METHODS text_parameter_beside_empty_v FOR TESTING.
    METHODS misuse_raises_not_dumps FOR TESTING.
    METHODS end_past_root_raises FOR TESTING.
ENDCLASS.


CLASS ltcl_builder IMPLEMENTATION.

  METHOD render_nested_view.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA closed TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA open TYPE REF TO z2ui5_cl_ui5_view_builder.
    closed = z2ui5_cl_ui5_view_builder=>factory( ).
    closed->ele( `Page`
        )->ele( `Panel`
            )->ele( `Title`
            )->end(
        )->end( ).


    open = z2ui5_cl_ui5_view_builder=>factory( ).
    open->ele( `Page`
        )->ele( `Panel`
            )->ele( `Title` ).

    cl_abap_unit_assert=>assert_equals(
      act = open->stringify( )
      exp = closed->stringify( ) ).

  ENDMETHOD.


  METHOD escape_attribute_value.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

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
    DATA temp1 TYPE xstring.
    DATA lv_ctrl TYPE string.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    temp1 = `0C1E`.

    lv_ctrl = z2ui5_cl_ui5_util_context=>conv_get_string_by_xstring( temp1 ).

    view = z2ui5_cl_ui5_view_builder=>factory( ).

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

    " neither brace nor backslash: nothing to escape
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `a plain text` )
      exp = `a plain text` ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `` )
      exp = `` ).

  ENDMETHOD.


  METHOD escape_literal_backslash.

    " UI5 unescapes a doubled backslash in EVERY string property, brace or
    " not - so the backslash is escaped whenever present: a lone one comes
    " back as itself (`C:\temp\file` renders unchanged), and a UNC path
    " keeps both of its leading backslashes instead of losing one
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `C:\temp\file` )
      exp = `C:\\temp\\file` ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_ui5_view_builder=>escape_literal( `\\server\share` )
      exp = `\\\\server\\share` ).

  ENDMETHOD.


  METHOD bool_parameter.

    " b is the only way to render a boolean - abap_false must come out as
    " `false`, not vanish, which is why it is read with IS SUPPLIED
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Panel`
        )->a( n   = `visible`
                b = abap_true
        )->a( n   = `expanded`
                b = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel visible="true" expanded="false"/>` ).

  ENDMETHOD.

  METHOD text_parameter.

    " t renders TEXT: a brace that would otherwise start a binding and a
    " backslash UI5 would unescape are escaped the escape_literal( ) way,
    " and the XML escaping of the render still follows on top
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Panel`
        )->a( n = `headerText`
              t = `Results for {/PASSWORD} & co`
        )->a( n = `tooltip`
              t = `\\server\share` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel headerText="Results for \{/PASSWORD\} &amp; co" tooltip="\\\\server\\share"/>` ).

  ENDMETHOD.

  METHOD text_parameter_beside_empty_v.

    " the tolerance b always had, carried over: an empty v next to t is
    " ignored, t decides the value
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Panel`
        )->a( n = `headerText`
              v = ``
              t = `{x}` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel headerText="\{x\}"/>` ).

  ENDMETHOD.

  METHOD text_parameter_empty.

    " an empty t is a value like an empty v - the refusal is for NO
    " parameter at all, not for an empty one
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    view->ele( `Panel`
        )->a( n = `headerText`
              t = `` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel headerText=""/>` ).

  ENDMETHOD.

  METHOD misuse_raises_not_dumps.

    " every misuse of the chain is a catchable exception naming the element
    " and the attribute - not an ASSERT, whose ASSERTION_FAILED bypasses the
    " framework's top-level catch and dumps instead of rendering the error
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
        DATA lx_root TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp1 TYPE xsdboolean.
        DATA lx_none TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp2 TYPE xsdboolean.
        DATA lx_both TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp3 TYPE xsdboolean.
        DATA lx_v_t TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp4 TYPE xsdboolean.
        DATA lx_b_t TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp5 TYPE xsdboolean.
        DATA lx_dup TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp6 TYPE xsdboolean.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    TRY.
        view->a( n = `text`
                 v = `x` ).
        cl_abap_unit_assert=>fail( `a( ) on the empty root must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_root.

        temp1 = boolc( lx_root->get_text( ) CS `text` ).
        cl_abap_unit_assert=>assert_true( temp1 ).
    ENDTRY.

    view->ele( `Panel` ).
    TRY.
        view->a( `visible` ).
        cl_abap_unit_assert=>fail( `a( ) without v and b must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_none.

        temp2 = boolc( lx_none->get_text( ) CS `visible` ).
        cl_abap_unit_assert=>assert_true( temp2 ).
    ENDTRY.

    TRY.
        view->a( n = `visible`
                 v = `true`
                 b = abap_true ).
        cl_abap_unit_assert=>fail( `a( ) with v and b must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_both.

        temp3 = boolc( lx_both->get_text( ) CS `visible` ).
        cl_abap_unit_assert=>assert_true( temp3 ).
    ENDTRY.

    " t is the third of the exclusive three - with v as much as with b. An
    " EMPTY v next to it is tolerated, as it always was next to b (see
    " attr_value), so the conflict needs a v that carries something
    TRY.
        view->a( n = `title`
                 v = `y`
                 t = `x` ).
        cl_abap_unit_assert=>fail( `a( ) with v and t must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_v_t.

        temp4 = boolc( lx_v_t->get_text( ) CS `title` ).
        cl_abap_unit_assert=>assert_true( temp4 ).
    ENDTRY.

    TRY.
        view->a( n = `title`
                 b = abap_true
                 t = `x` ).
        cl_abap_unit_assert=>fail( `a( ) with b and t must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_b_t.

        temp5 = boolc( lx_b_t->get_text( ) CS `title` ).
        cl_abap_unit_assert=>assert_true( temp5 ).
    ENDTRY.

    view->a( n = `text`
             v = `once` ).
    TRY.
        view->a( n = `text`
                 v = `twice` ).
        cl_abap_unit_assert=>fail( `a duplicate attribute must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_dup.

        temp6 = boolc( lx_dup->get_text( ) CS `Panel` ).
        cl_abap_unit_assert=>assert_true( temp6 ).
    ENDTRY.

  ENDMETHOD.

  METHOD end_past_root_raises.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
        DATA lx_end TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA temp7 TYPE xsdboolean.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    TRY.
        view->ele( `Panel` )->end( )->end( ).
        cl_abap_unit_assert=>fail( `end( ) past the root must raise` ).

      CATCH z2ui5_cx_ui5_util_error INTO lx_end.

        temp7 = boolc( lx_end->get_text( ) CS `end( )` ).
        cl_abap_unit_assert=>assert_true( temp7 ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
