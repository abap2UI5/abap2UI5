CLASS z2ui5_cl_app_developertool_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_developertool_xml IMPLEMENTATION.

  METHOD get.

    result = `<core:FragmentDefinition` &&
             `    xmlns="sap.m"` &&
             `    xmlns:core="sap.ui.core"` &&
             `    xmlns:ce="sap.ui.codeeditor"` &&
             `>` &&
             `    <Dialog` &&
             `        title="abap2UI5 - Developer Tools"` &&
             `        stretch="true"` &&
             `        escapeHandler=".onEscape"` &&
             `    >` &&
             `        <IconTabHeader` &&
             `            selectedKey="{/selectedTab}"` &&
             `            select=".onItemSelect"` &&
             `        >` &&
             `            <items>` &&
             `                <IconTabFilter` &&
             `                    text="Error"` &&
             `                    key="ERROR"` &&
             `                    enabled="{/hasError}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Log"` &&
             `                    key="LOG"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="System"` &&
             `                    key="SYSTEM"` &&
             `                    enabled="true"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Previous Request"` &&
             `                    key="REQUEST"` &&
             `                    enabled="true"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Response"` &&
             `                    key="PLAIN"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Source Code"` &&
             `                    key="SOURCE"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="View"` &&
             `                    key="VIEW"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="View Model"` &&
             `                    key="MODEL"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popup"` &&
             `                    key="POPUP"` &&
             `                    enabled="{/activePopup}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popup Model"` &&
             `                    key="POPUP_MODEL"` &&
             `                    enabled="{/activePopup}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popover"` &&
             `                    key="POPOVER"` &&
             `                    enabled="{/activePopover}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popover Model"` &&
             `                    key="POPOVER_MODEL"` &&
             `                    enabled="{/activePopover}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Nest1"` &&
             `                    key="NEST1"` &&
             `                    enabled="{/activeNest1}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Nest1 Model"` &&
             `                    key="NEST1_MODEL"` &&
             `                    enabled="{/activeNest1}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Nest2"` &&
             `                    key="NEST2"` &&
             `                    enabled="{/activeNest2}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Nest2 Model"` &&
             `                    key="NEST2_MODEL"` &&
             `                    enabled="{/activeNest2}"` &&
             `                />` &&
             `            </items>` &&
             `        </IconTabHeader>` &&
             `        <VBox>` &&
             `            <ToggleButton text="Source XML after Templating" visible="{/isTemplating}" pressed="{/templatingSource}" press=".onTemplatingPress" />` &&
             `            <ce:CodeEditor` &&
             `                id="developerToolsEditor"` &&
             `                type="{/type}"` &&
             `                value="{/value}"` &&
             `                height="2000px"` &&
             `                width="10000px"` &&
             `                visible="{/editor_visible}"` &&
             `            />` &&
             `        </VBox>` &&
             `        <VBox visible="{/source_visible}">` &&
             `            <core:HTML id="sourceHtml"/>` &&
             `        </VBox>` &&
             `        <footer>` &&
             `            <OverflowToolbar>` &&
             `                <Button` &&
             `                    text="Restart"` &&
             `                    icon="sap-icon://restart"` &&
             `                    press=".onErrorRestart"` &&
             `                />` &&
             `                <Button` &&
             `                    text="Logout"` &&
             `                    icon="sap-icon://log"` &&
             `                    press=".onErrorLogout"` &&
             `                />` &&
             `                <ToolbarSpacer/>` &&
             `                <Button` &&
             `                    text="Retry"` &&
             `                    type="Emphasized"` &&
             `                    icon="sap-icon://refresh"` &&
             `                    visible="{/hasRetry}"` &&
             `                    press=".onErrorRetry"` &&
             `                />` &&
             `                <Button` &&
             `                    text="Close"` &&
             `                    press=".onClose"` &&
             `                />` &&
             `            </OverflowToolbar>` &&
             `        </footer>` &&
             `    </Dialog>` &&
             `</core:FragmentDefinition>` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
