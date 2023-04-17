CLASS z2ui5_cl_app_demo_39 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_value    TYPE string.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render_main.
    METHODS z2ui5_on_render_popup.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_39 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    app-get = client->get( ).
    me->client = client.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render_main( ).
    z2ui5_on_render_popup( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).
      WHEN 'POPUP'.
        client->popup_message_box( 'Event raised value:' && mv_value ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    mv_value  = '200'.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    app-next-xml_main = `<mvc:View controllerName="sap.m.sample.GenericTileAsLaunchTile.Page"` && |\n|  &&
                        `xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc"` && |\n|  &&
                        `       xmlns:form="sap.ui.layout.form">` && |\n|  &&
                        `       <form:SimpleForm editable="true" width="40rem">` && |\n|  &&
                        `       <Label text="Loading time" />` && |\n|  &&
                        `       <Input id="loadingMinSeconds" width="8rem" type="Number" description="seconds" value="-1"/>` && |\n|  &&
                        `       <Button text="Start loading" type="Emphasized" press="onFormSubmit"/>` && |\n|  &&
                        `   </form:SimpleForm>  ` && |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Country-Specific Profit Margin"  press="onPress"` && |\n|  &&
                        `       frameType="OneByHalf" subheader="Subtitle">` && |\n|  &&
                        `       <TileContent>` && |\n|  &&
                        `           <ImageContent src="test-resources/sap/m/demokit/sample/GenericTileAsLaunchTile/images/SAPLogoLargeTile_28px_height.png" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Sales Fulfillment Application Title"` && |\n|  &&
                        `       subheader="Subtitle" press="press" frameType= "TwoByHalf">` && |\n|  &&
                        `       <TileContent />` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Manage Activity Master Data Type"` && |\n|  &&
                        `       subheader="Subtitle" press="press" frameType= "TwoByHalf">` && |\n|  &&
                        `       <TileContent unit="EUR" footer="Current Quarter">` && |\n|  &&
                        `           <ImageContent src="sap-icon://home-share" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Right click to open in new tab"` && |\n|  &&
                        `       subheader="Link tile" press="press" url="https://www.sap.com/">` && |\n|  &&
                        `       <TileContent>` && |\n|  &&
                        `           <ImageContent src="test-resources/sap/m/demokit/sample/GenericTileAsLaunchTile/images/SAPLogoLargeTile_28px_height.png" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Sales Fulfillment Application Title"` && |\n|  &&
                        `       subheader="Subtitle" press="press">` && |\n|  &&
                        `       <TileContent unit="EUR" footer="Current Quarter">` && |\n|  &&
                        `           <ImageContent src="sap-icon://home-share" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Manage Activity Master Data Type"` && |\n|  &&
                        `       subheader="Subtitle" press="press">` && |\n|  &&
                        `       <TileContent>` && |\n|  &&
                        `           <ImageContent src="test-resources/sap/m/demokit/sample/GenericTileAsLaunchTile/images/SAPLogoLargeTile_28px_height.png" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Manage Activity Master Data Type With a Long Title Without an Icon"` && |\n|  &&
                        `       subheader="Subtitle Launch Tile" mode="HeaderMode" press="press">` && |\n|  &&
                        `       <TileContent unit="EUR" footer="Current Quarter" />` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Jessica D. Prince Senior Consultant"` && |\n|  &&
                        `       subheader="Department" press="press" appShortcut = "shortcut" systemInfo = "systeminfo">` && |\n|  &&
                        `       <TileContent>` && |\n|  &&
                        `           <ImageContent src="test-resources/sap/m/demokit/sample/GenericTileAsLaunchTile/images/ProfileImage_LargeGenTile.png" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Sales Fulfillment Application Title"` && |\n|  &&
                        `       press="press" frameType= "OneByHalf">` && |\n|  &&
                        `       <TileContent unit="EUR" footer="Current Quarter">` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Sales Fulfillment Application Title"` && |\n|  &&
                        `       press="press" frameType= "TwoByHalf">` && |\n|  &&
                        `       <TileContent unit="EUR" footer="Current Quarter">` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        |\n|  &&
                        `   <GenericTile class="sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout" header="Jessica D. Prince Senior Consultant"` && |\n|  &&
                        `       subheader="Department" press="press" frameType="TwoByHalf">` && |\n|  &&
                        `       <TileContent>` && |\n|  &&
                        `           <ImageContent src="test-resources/sap/m/demokit/sample/GenericTileAsLaunchTile/images/ProfileImage_LargeGenTile.png" />` && |\n|  &&
                        `       </TileContent>` && |\n|  &&
                        `   </GenericTile>` && |\n|  &&
                        `</mvc:View>`.

    app-next-xml_main = z2ui5_cl_xml_view=>hlp_replace_controller_name( app-next-xml_main ).

  ENDMETHOD.


  METHOD z2ui5_on_render_popup.

    app-next-xml_popup = `<core:FragmentDefinition` && |\n|  &&
                         `  xmlns="sap.m"` && |\n|  &&
                         `  xmlns:core="sap.ui.core">` && |\n|  &&
                         `  <ViewSettingsDialog` && |\n|  &&
                         `      confirm="handleConfirm">` && |\n|  &&
                         `      <sortItems>` && |\n|  &&
                         `          <ViewSettingsItem text="Field 1" key="1" selected="true" />` && |\n|  &&
                         `          <ViewSettingsItem text="Field 2" key="2" />` && |\n|  &&
                         `          <ViewSettingsItem text="Field 3" key="3" />` && |\n|  &&
                         `      </sortItems>` && |\n|  &&
                         `      <groupItems>` && |\n|  &&
                         `          <ViewSettingsItem text="Field 1" key="1" selected="true" />` && |\n|  &&
                         `          <ViewSettingsItem text="Field 2" key="2" />` && |\n|  &&
                         `          <ViewSettingsItem text="Field 3" key="3" />` && |\n|  &&
                         `      </groupItems>` && |\n|  &&
                         `      <filterItems>` && |\n|  &&
                         `          <ViewSettingsFilterItem text="Field1" key="1">` && |\n|  &&
                         `              <items>` && |\n|  &&
                         `                  <ViewSettingsItem text="Value A" key="1a" />` && |\n|  &&
                         `                  <ViewSettingsItem text="Value B" key="1b" />` && |\n|  &&
                         `                  <ViewSettingsItem text="Value C" key="1c" />` && |\n|  &&
                         `              </items>` && |\n|  &&
                         `          </ViewSettingsFilterItem>` && |\n|  &&
                         `          <ViewSettingsFilterItem text="Field2" key="2">` && |\n|  &&
                         `              <items>` && |\n|  &&
                         `                  <ViewSettingsItem text="Value A" key="2a" />` && |\n|  &&
                         `                  <ViewSettingsItem text="Value B" key="2b" />` && |\n|  &&
                         `                  <ViewSettingsItem text="Value C" key="2c" />` && |\n|  &&
                         `              </items>` && |\n|  &&
                         `          </ViewSettingsFilterItem>` && |\n|  &&
                         `          <ViewSettingsFilterItem text="Field3" key="3">` && |\n|  &&
                         `              <items>` && |\n|  &&
                         `                  <ViewSettingsItem text="Value A" key="3a" />` && |\n|  &&
                         `                  <ViewSettingsItem text="Value B" key="3b" />` && |\n|  &&
                         `                  <ViewSettingsItem text="Value C" key="3c" />` && |\n|  &&
                         `              </items>` && |\n|  &&
                         `          </ViewSettingsFilterItem>` && |\n|  &&
                         `      </filterItems>` && |\n|  &&
                         `  </ViewSettingsDialog>` && |\n|  &&
                         `</core:FragmentDefinition>`.

  ENDMETHOD.
ENDCLASS.
