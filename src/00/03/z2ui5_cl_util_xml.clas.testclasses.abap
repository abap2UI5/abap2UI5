CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_factory           FOR TESTING RAISING cx_static_check.
    METHODS test_factory_popup     FOR TESTING RAISING cx_static_check.
    METHODS test_shell_page        FOR TESTING RAISING cx_static_check.
    METHODS test_button            FOR TESTING RAISING cx_static_check.
    METHODS test_leaf              FOR TESTING RAISING cx_static_check.
    METHODS test_nested            FOR TESTING RAISING cx_static_check.
    METHODS test_nav_up            FOR TESTING RAISING cx_static_check.
    METHODS test_nav_named         FOR TESTING RAISING cx_static_check.
    METHODS test_nav_not_found     FOR TESTING RAISING cx_static_check.
    METHODS test_nav_prev          FOR TESTING RAISING cx_static_check.
    METHODS test_nav_root          FOR TESTING RAISING cx_static_check.
    METHODS test_namespace         FOR TESTING RAISING cx_static_check.
    METHODS test_table             FOR TESTING RAISING cx_static_check.
    METHODS test_simple_form       FOR TESTING RAISING cx_static_check.
    METHODS test_preferred_param   FOR TESTING RAISING cx_static_check.
    METHODS test_shortcut_av       FOR TESTING RAISING cx_static_check.
    METHODS test_stringify_subnode FOR TESTING RAISING cx_static_check.
    METHODS test_p                 FOR TESTING RAISING cx_static_check.
    METHODS test_if_true           FOR TESTING RAISING cx_static_check.
    METHODS test_if_false          FOR TESTING RAISING cx_static_check.
    METHODS test_leaf_if_true      FOR TESTING RAISING cx_static_check.
    METHODS test_leaf_if_false     FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_page_sample   FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_page_sample_indent FOR TESTING RAISING cx_static_check.

    METHODS build_page_view
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_view) = z2ui5_cl_util_xml=>factory( )->_( `View` ).
    DATA(lv_xml) = lo_view->_( n = `Page`
                                p = VALUE #( ( n = `title` v = `test` ) )
                              )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA(lo_popup) = z2ui5_cl_util_xml=>factory( )->_( n = `FragmentDefinition` ns = `core`
                       p = VALUE #( ( n = `xmlns` v = `sap.m` )
                                    ( n = `xmlns:core` v = `sap.ui.core` ) ) ).
    DATA(lv_xml) = lo_popup->_( n = `Dialog`
                                 p = VALUE #( ( n = `title` v = `Test` ) )
                               )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Dialog` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `core:FragmentDefinition` ) ).

  ENDMETHOD.

  METHOD test_shell_page.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( n = `Page`
            p = VALUE #( ( n = `title` v = `My Page` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Shell` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Page` ) ).

  ENDMETHOD.

  METHOD test_button.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( n = `Page` a = `title` v = `Test`
      )->__( n = `Button`
             p = VALUE #( ( n = `text`  v = `Click Me` )
                           ( n = `press` v = `onPress` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Click Me` ) ).

  ENDMETHOD.

  METHOD test_leaf.

    DATA(lo_page) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( n = `Page` a = `title` v = `Test` ).

    lo_page->__( n = `Button` a = `text` v = `Btn1` ).
    lo_page->__( n = `Button` a = `text` v = `Btn2` ).

    DATA(lv_xml) = lo_page->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Btn1` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Btn2` ) ).

  ENDMETHOD.

  METHOD test_nested.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( n = `Page` a = `title` v = `Test`
      )->_( `VBox`
      )->_( `HBox`
      )->__( n = `Text` a = `text` v = `Nested`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `VBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `HBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Nested` ) ).

  ENDMETHOD.

  METHOD test_nav_up.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_view) = lo_root->_( n = `View` ns = `mvc` ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    DATA(lo_vbox) = lo_page->_( `VBox` ).
    DATA(lo_parent) = lo_vbox->n( ).

    cl_abap_unit_assert=>assert_equals( exp = lo_page act = lo_parent ).

  ENDMETHOD.

  METHOD test_nav_named.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_view) = lo_root->_( n = `View` ns = `mvc` ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->_( `VBox`
      )->_( `HBox` ).

    DATA(lo_result) = lo_page->_( `VBox`
      )->_( `HBox`
      )->n( `Page` ).

    cl_abap_unit_assert=>assert_equals( exp = lo_page act = lo_result ).

  ENDMETHOD.

  METHOD test_nav_not_found.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_view) = lo_root->_( n = `View` ns = `mvc` ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).

    DATA(lo_result) = lo_page->_( `VBox`
      )->_( `HBox`
      )->n( `NotExisting` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

  ENDMETHOD.

  METHOD test_nav_prev.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_view) = lo_root->_( n = `View` ns = `mvc` ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->__( n = `Button` a = `text` v = `Btn` ).

    DATA(lo_prev) = lo_root->n_prev( ).

    cl_abap_unit_assert=>assert_bound( lo_prev ).

  ENDMETHOD.

  METHOD test_nav_root.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_deep) = lo_root->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( `Page`
      )->_( `VBox` ).

    DATA(lo_result) = lo_deep->n_root( ).

    cl_abap_unit_assert=>assert_equals( exp = lo_root act = lo_result ).

  ENDMETHOD.

  METHOD test_namespace.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
            p = VALUE #( ( n = `xmlns:f` v = `sap.f` ) )
      )->_( n  = `DynamicPage`
            ns = `f`
      )->_( n  = `DynamicPageTitle`
            ns = `f`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `f:DynamicPage` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `f:DynamicPageTitle` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `xmlns:f` ) ).

  ENDMETHOD.

  METHOD test_table.

    DATA(lo_page) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( n = `Page` a = `title` v = `Test` ).

    DATA(lo_table) = lo_page->_( n = `Table`
                                  p = VALUE #( ( n = `items`      v = `{/ITEMS}` )
                                               ( n = `headerText` v = `My Table` ) ) ).

    lo_table->_( `columns`
      )->_( `Column`
      )->_( `header`
      )->__( n = `Text` a = `text` v = `Col1` ).

    lo_table->_( `items`
      )->_( `ColumnListItem`
      )->_( `cells`
      )->__( n = `Text` a = `text` v = `{COL1}` ).

    DATA(lv_xml) = lo_page->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `columns` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `ColumnListItem` ) ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA(lo_form) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
            p = VALUE #( ( n = `xmlns:form` v = `sap.ui.layout.form` ) )
      )->_( n = `Page` a = `title` v = `Test`
      )->_( n  = `SimpleForm`
            ns = `form`
            a  = `editable`
            v  = `true` ).

    lo_form->_( n  = `content`
                ns = `form`
      )->__( n = `Label` a = `text` v = `Name`
      )->__( n = `Input` a = `value` v = `{/NAME}` ).

    DATA(lv_xml) = lo_form->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `SimpleForm` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Label` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Input` ) ).

  ENDMETHOD.

  METHOD test_preferred_param.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( `Page`
      )->__( `Button`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Shell` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).

  ENDMETHOD.

  METHOD test_shortcut_av.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->__( n = `Button` a = `text` v = `OK`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `text="OK"` ) ).

  ENDMETHOD.

  METHOD test_stringify_subnode.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_view) = lo_root->_( n = `View` ns = `mvc` ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->__( n = `Button` a = `text` v = `Click` ).

    DATA(lv_full) = lo_page->stringify( ).
    DATA(lv_sub)  = lo_page->stringify( from_root = abap_false ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `mvc:View` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_sub CS `mvc:View` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_sub CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_sub CS `Button` ) ).

  ENDMETHOD.

  METHOD test_p.

    DATA(lo_root) = z2ui5_cl_util_xml=>factory( ).
    DATA(lo_view) = lo_root->_( n = `View` ns = `mvc` ).
    DATA(lo_btn)  = lo_view->_( `Page`
      )->_( n = `Button` a = `text` v = `OK` ).

    lo_btn->p( n = `type` v = `Emphasized` ).
    lo_btn->p( n = `icon` v = `sap-icon://accept` ).

    DATA(lv_xml) = lo_root->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `text="OK"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `type="Emphasized"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `sap-icon://accept` ) ).

  ENDMETHOD.

  METHOD test_if_true.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->_if( when = abap_true
              n    = `Panel`
              a    = `headerText`
              v    = `Admin`
      )->__( n = `Text` a = `text` v = `Secret`
      )->n( `Page`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Panel` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Secret` ) ).

  ENDMETHOD.

  METHOD test_if_false.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->_if( when = abap_false
              n    = `Panel`
              a    = `headerText`
              v    = `Admin`
      )->__( n = `Button` a = `text` v = `Visible`
      )->stringify( ).

    cl_abap_unit_assert=>assert_false( xsdbool( lv_xml CS `Panel` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).

  ENDMETHOD.

  METHOD test_leaf_if_true.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->__if( when = abap_true
               n    = `Button`
               a    = `text`
               v    = `Admin Only`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Admin Only` ) ).

  ENDMETHOD.

  METHOD test_leaf_if_false.

    DATA(lv_xml) = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->__if( when = abap_false
               n    = `Button`
               a    = `text`
               v    = `Hidden`
      )->__( n = `Text` a = `text` v = `Visible`
      )->stringify( ).

    cl_abap_unit_assert=>assert_false( xsdbool( lv_xml CS `Hidden` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Visible` ) ).

  ENDMETHOD.

  METHOD build_page_view.

    result = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
            p = VALUE #( ( n = `height`    v = `100%` )
                         ( n = `xmlns:mvc` v = `sap.ui.core.mvc` )
                         ( n = `xmlns`     v = `sap.m` ) ) ).

    DATA(lo_page) = result->_( n = `Page`
      p = VALUE #( ( n = `title`         v = `Title` )
                   ( n = `class`         v = `sapUiContentPadding sapUiResponsivePadding--header sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer` )
                   ( n = `showNavButton` v = `true` ) ) ).

    lo_page->_( `headerContent`
      )->__( n = `Button`
             p = VALUE #( ( n = `icon`    v = `sap-icon://action` )
                          ( n = `tooltip` v = `Share` ) ) ).

    lo_page->_( `subHeader`
      )->_( `OverflowToolbar`
      )->__( `SearchField` ).

    lo_page->_( `content`
      )->_( `VBox`
      )->__( n = `Text` a = `text`
             v = `Lorem ipsum dolor st amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
           && ` At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
           && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
           && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat` ).

    DATA(lo_footer_toolbar) = lo_page->_( `footer`
      )->_( `OverflowToolbar` ).
    lo_footer_toolbar->__( `ToolbarSpacer` ).
    lo_footer_toolbar->__( n = `Button` p = VALUE #( ( n = `text` v = `Accept` ) ( n = `type` v = `Accept` ) ) ).
    lo_footer_toolbar->__( n = `Button` p = VALUE #( ( n = `text` v = `Reject` ) ( n = `type` v = `Reject` ) ) ).
    lo_footer_toolbar->__( n = `Button` a = `text` v = `Edit` ).
    lo_footer_toolbar->__( n = `Button` a = `text` v = `Delete` ).

  ENDMETHOD.

  METHOD test_ui5_page_sample.

    DATA(lv_xml) = build_page_view( )->stringify( ).

    DATA(lv_exp) = ` <mvc:View height="100%" xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc">`
                && ` <Page class="sapUiContentPadding sapUiResponsivePadding--header sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" showNavButton="true" title="Title">`
                && ` <headerContent>`
                && ` <Button icon="sap-icon://action" tooltip="Share"/>`
                && `</headerContent>`
                && ` <subHeader>`
                && ` <OverflowToolbar>`
                && ` <SearchField/>`
                && `</OverflowToolbar>`
                && `</subHeader>`
                && ` <content>`
                && ` <VBox>`
                && ` <Text text="Lorem ipsum dolor st amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat"/>`
                && `</VBox>`
                && `</content>`
                && ` <footer>`
                && ` <OverflowToolbar>`
                && ` <ToolbarSpacer/>`
                && ` <Button text="Accept" type="Accept"/>`
                && ` <Button text="Reject" type="Reject"/>`
                && ` <Button text="Edit"/>`
                && ` <Button text="Delete"/>`
                && `</OverflowToolbar>`
                && `</footer>`
                && `</Page>`
                && `</mvc:View>`.

    cl_abap_unit_assert=>assert_equals( exp = lv_exp act = lv_xml ).

  ENDMETHOD.

  METHOD test_ui5_page_sample_indent.

    DATA(lv_xml) = build_page_view( )->stringify( indent = abap_true ).

    DATA(lv_exp) = `<mvc:View height="100%" xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc">` && |\n|
                && `  <Page class="sapUiContentPadding sapUiResponsivePadding--header sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" showNavButton="true" title="Title">` && |\n|
                && `    <headerContent>` && |\n|
                && `      <Button icon="sap-icon://action" tooltip="Share"/>` && |\n|
                && `    </headerContent>` && |\n|
                && `    <subHeader>` && |\n|
                && `      <OverflowToolbar>` && |\n|
                && `        <SearchField/>` && |\n|
                && `      </OverflowToolbar>` && |\n|
                && `    </subHeader>` && |\n|
                && `    <content>` && |\n|
                && `      <VBox>` && |\n|
                && `        <Text text="Lorem ipsum dolor st amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat"/>` && |\n|
                && `      </VBox>` && |\n|
                && `    </content>` && |\n|
                && `    <footer>` && |\n|
                && `      <OverflowToolbar>` && |\n|
                && `        <ToolbarSpacer/>` && |\n|
                && `        <Button text="Accept" type="Accept"/>` && |\n|
                && `        <Button text="Reject" type="Reject"/>` && |\n|
                && `        <Button text="Edit"/>` && |\n|
                && `        <Button text="Delete"/>` && |\n|
                && `      </OverflowToolbar>` && |\n|
                && `    </footer>` && |\n|
                && `  </Page>` && |\n|
                && `</mvc:View>`.

    cl_abap_unit_assert=>assert_equals( exp = lv_exp act = lv_xml ).

  ENDMETHOD.

ENDCLASS.
