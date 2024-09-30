CLASS z2ui5_cl_app_cc_DebugTool_xml DEFINITION
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


CLASS z2ui5_cl_app_cc_DebugTool_xml IMPLEMENTATION.

  METHOD get.

    result =              `<core:FragmentDefinition` && |\n|  &&
             `    xmlns="sap.m"` && |\n|  &&
             `    xmlns:mvc="sap.ui.core.mvc"` && |\n|  &&
             `    xmlns:core="sap.ui.core"` && |\n|  &&
             `    xmlns:html="http://www.w3.org/1999/xhtml"` && |\n|  &&
             `    xmlns:ce="sap.ui.codeeditor"` && |\n|  &&
             `>` && |\n|  &&
             `    <Dialog` && |\n|  &&
             `        title="abap2UI5 - Debug Tool"` && |\n|  &&
             `        stretch="true"` && |\n|  &&
             `    >` && |\n|  &&
             `        <IconTabHeader` && |\n|  &&
             `            selectedKey="PLAIN"` && |\n|  &&
             `            select="onItemSelect"` && |\n|  &&
             `        >` && |\n|  &&
             `            <items>` && |\n|  &&
             `		        <IconTabFilter` && |\n|  &&
             `                    text="Config"` && |\n|  &&
             `                    key="CONFIG"` && |\n|  &&
             `					enabled="true"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Previous Request"` && |\n|  &&
             `                    key="REQUEST"` && |\n|  &&
             `					enabled="true"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Response"` && |\n|  &&
             `                    key="PLAIN"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Source Code"` && |\n|  &&
             `                    key="SOURCE"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="View"` && |\n|  &&
             `                    key="VIEW"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="View Model"` && |\n|  &&
             `                    key="MODEL"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Popup"` && |\n|  &&
             `                    key="POPUP"` && |\n|  &&
             `					enabled="{/activePopup}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Popup Model"` && |\n|  &&
             `                    key="POPUP_MODEL"` && |\n|  &&
             `					enabled="{/activePopup}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Popover"` && |\n|  &&
             `                    key="POPOVER"` && |\n|  &&
             `					enabled="{/activePopover}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Popover Model"` && |\n|  &&
             `                    key="POPOVER_MODEL"` && |\n|  &&
             `					enabled="{/activePopover}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Nest1"` && |\n|  &&
             `                    key="NEST1"` && |\n|  &&
             `					enabled="{/activeNest1}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Nest1 Model"` && |\n|  &&
             `                    key="NEST1_MODEL"` && |\n|  &&
             `					enabled="{/activeNest1}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Nest2"` && |\n|  &&
             `                    key="NEST2"` && |\n|  &&
             `					enabled="{/activeNest2}"` && |\n|  &&
             `                />` && |\n|  &&
             `                <IconTabFilter` && |\n|  &&
             `                    text="Nest2 Model"` && |\n|  &&
             `                    key="NEST2_MODEL"` && |\n|  &&
             `					enabled="{/activeNest2}"` && |\n|  &&
             `                />` && |\n|  &&
             `            </items>` && |\n|  &&
             `        </IconTabHeader>` && |\n|  &&
             `			<VBox>` && |\n|  &&
             `				<ToggleButton text="Source XML after Templating" visible="{/isTemplating}" pressed="{/templating` && |\n|  &&
             `Source}" press="onTemplatingPress" />` && |\n|  &&
             `        <ce:CodeEditor` && |\n|  &&
             `            type="{/type}"` && |\n|  &&
             `            value="{/value}"` && |\n|  &&
             `            height="2000px"` && |\n|  &&
             `            width="10000px"` && |\n|  &&
             `            visible="{/editor_visible}"` && |\n|  &&
             `        /></VBox>` && |\n|  &&
             `		<VBox visible="{/source_visible}">` && |\n|  &&
             `				<core:HTML/>` && |\n|  &&
             `			</VBox>` && |\n|  &&
             `        <endButton>` && |\n|  &&
             `            <Button` && |\n|  &&
             `                text="Close"` && |\n|  &&
             `                press="onClose"` && |\n|  &&
             `            />` && |\n|  &&
             `        </endButton>` && |\n|  &&
             `    </Dialog>` && |\n|  &&
             `</core:FragmentDefinition>` && |\n|  &&
             `` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.