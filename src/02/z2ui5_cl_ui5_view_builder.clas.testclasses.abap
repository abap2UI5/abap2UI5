CLASS ltcl_builder DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS render_nested_view FOR TESTING.
    METHODS att_hits_current_element FOR TESTING.
    METHODS att_after_end_hits_parent FOR TESTING.
    METHODS att_after_children FOR TESTING.
    METHODS trailing_end_is_optional FOR TESTING.
    METHODS escape_attribute_value FOR TESTING.
    METHODS escape_whitespace_chars FOR TESTING.
    METHODS bool_parameter FOR TESTING.
    METHODS tag_stays_and_siblings FOR TESTING.
    METHODS tag_attr_splits_first_equals FOR TESTING.
    METHODS att_after_tag_hits_parent FOR TESTING.
ENDCLASS.


CLASS ltcl_builder IMPLEMENTATION.

  METHOD render_nested_view.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( n  = `View`
               ns = `mvc`
        )->att( n = `xmlns`
                v = `sap.m`

        )->ele( `Text`
            )->att( n = `text`
                    v = `Hello`
        )->end(

        )->ele( `Panel`
            )->ele( `Title` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<mvc:View xmlns="sap.m"><Text text="Hello"/><Panel><Title/></Panel></mvc:View>` ).

  ENDMETHOD.


  METHOD att_hits_current_element.

    " the one rule: att( ) lands on the element the chain is standing on, so
    " repeated ele( )/end( ) pairs produce siblings each carrying their own
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Page`
        )->ele( `Text`
            )->att( n = `text`
                    v = `first`
        )->end(
        )->ele( `Text`
            )->att( n = `text`
                    v = `second` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Page><Text text="first"/><Text text="second"/></Page>` ).

  ENDMETHOD.


  METHOD att_after_end_hits_parent.

    " after end( ) the chain stands on the parent - att( ) attaches there,
    " which is what the indentation suggests and what the old builder could
    " not do
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Panel`
            )->ele( `Title`
        )->end(
        )->att( n = `width`
                v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel width="100%"><Title/></Panel>` ).

  ENDMETHOD.


  METHOD att_after_children.

    " an attribute may follow the children of its own element - impossible in
    " the predecessor, where it silently went to the last child
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Panel`
            )->ele( `Title`
            )->end(
        )->att( n = `width`
                v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel width="100%"><Title/></Panel>` ).

  ENDMETHOD.


  METHOD trailing_end_is_optional.

    " stringify( ) renders from the root, so the chain may simply stop
    DATA closed TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA open TYPE REF TO z2ui5_cl_ui5_view_builder.
    closed = z2ui5_cl_ui5_view_builder=>new( ).
    closed->ele( `Page` )->ele( `Panel` )->ele( `Title` )->end( )->end( ).


    open = z2ui5_cl_ui5_view_builder=>new( ).
    open->ele( `Page` )->ele( `Panel` )->ele( `Title` ).

    cl_abap_unit_assert=>assert_equals(
      act = open->stringify( )
      exp = closed->stringify( ) ).

  ENDMETHOD.


  METHOD escape_attribute_value.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Text`
        )->att( n = `text`
                v = `a<b>&"c` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="a&lt;b&gt;&amp;&quot;c"/>` ).

  ENDMETHOD.


  METHOD escape_whitespace_chars.

    " a literal LF/TAB in an attribute value must survive XML attribute-value
    " normalization as a character reference (e.g. a two-line noDataText)
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Text`
        )->att( n = `text`
                v = |line1{ z2ui5_cl_a2ui5_context=>cv_char_util_newline }line2{ z2ui5_cl_a2ui5_context=>cv_char_util_horizontal_tab }end| ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Text text="line1&#xA;line2&#x9;end"/>` ).

  ENDMETHOD.


  METHOD bool_parameter.

    " b replaces the predecessor's as_bool( ) helper - abap_false must render
    " as `false`, not vanish, which is why it is read with IS SUPPLIED
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Panel`
        )->att( n = `visible`
                b = abap_true
        )->att( n = `expanded`
                b = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel visible="true" expanded="false"/>` ).

  ENDMETHOD.


  METHOD tag_stays_and_siblings.

    " tag( ) does not move, so siblings follow directly and no end( ) is needed
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp1 TYPE z2ui5_cl_ui5_view_builder=>ty_t_attr.
    DATA temp2 TYPE z2ui5_cl_ui5_view_builder=>ty_t_attr.
    view = z2ui5_cl_ui5_view_builder=>new( ).


    CLEAR temp1.
    INSERT `text=first` INTO TABLE temp1.

    CLEAR temp2.
    INSERT `text=second` INTO TABLE temp2.
    view->ele( `Page`
        )->tag( n     = `Text`
                t_att = temp1
        )->tag( n     = `Text`
                t_att = temp2
        )->tag( `ToolbarSpacer` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Page><Text text="first"/><Text text="second"/><ToolbarSpacer/></Page>` ).

  ENDMETHOD.


  METHOD tag_attr_splits_first_equals.

    " attributes split on the FIRST equals sign, so the value may contain more
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp3 TYPE z2ui5_cl_ui5_view_builder=>ty_t_attr.
    view = z2ui5_cl_ui5_view_builder=>new( ).


    CLEAR temp3.
    INSERT `text=a=b` INTO TABLE temp3.
    INSERT `width=100%` INTO TABLE temp3.
    view->tag( n     = `Text`
               ns    = `m`
               t_att = temp3 ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<m:Text text="a=b" width="100%"/>` ).

  ENDMETHOD.


  METHOD att_after_tag_hits_parent.

    " pinned on purpose: tag( ) does not move, so a following att( ) attaches
    " to the element the chain stands on - the PARENT, not the tag just added.
    " That is the one rule holding; attributes of a tag belong in t_att.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>new( ).

    view->ele( `Panel`
        )->tag( `Title`
        )->att( n = `width`
                v = `100%` ).

    cl_abap_unit_assert=>assert_equals(
      act = view->stringify( )
      exp = `<Panel width="100%"><Title/></Panel>` ).

  ENDMETHOD.

ENDCLASS.
