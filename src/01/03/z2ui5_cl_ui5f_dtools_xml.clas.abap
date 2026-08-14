* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_dtools_xml DEFINITION
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


CLASS z2ui5_cl_ui5f_dtools_xml IMPLEMENTATION.

  METHOD get.

    result = `<core:FragmentDefinition` &&
             `    xmlns="sap.m"` &&
             `    xmlns:core="sap.ui.core"` &&
             `    xmlns:ce="sap.ui.codeeditor"` &&
             `>` &&
             `    <Dialog` &&
             `        title="{= ${/appName} ? 'abap2UI5 - Developer Tools - ' + ${/appName} : 'abap2UI5 - Developer Tools' }"` &&
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
             `                    enabled="{/hasLog}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="History"` &&
             `                    key="HISTORY"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Model Diff"` &&
             `                    key="DIFF"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Previous Request"` &&
             `                    key="REQUEST"` &&
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
             `                    enabled="{/hasViewModel}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popup"` &&
             `                    key="POPUP"` &&
             `                    enabled="{/activePopup}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popup Model"` &&
             `                    key="POPUP_MODEL"` &&
             `                    enabled="{/hasPopupModel}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popover"` &&
             `                    key="POPOVER"` &&
             `                    enabled="{/activePopover}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Popover Model"` &&
             `                    key="POPOVER_MODEL"` &&
             `                    enabled="{/hasPopoverModel}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Nest1"` &&
             `                    key="NEST1"` &&
             `                    enabled="{/activeNest1}"` &&
             `                />` &&
             `                <IconTabFilter` &&
             `                    text="Nest2"` &&
             `                    key="NEST2"` &&
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
             `            <!-- The inline iframe below is only a preview: some systems block` &&
             `                 framing the ADT endpoint and the ADT jump link inside it never` &&
             `                 navigates. Use the "ADT" button in the dialog footer to open` &&
             `                 the same source in a new tab, where its ADT jump link works. -->` &&
             `            <!-- preferDOM defaults to true, which restores the preserved` &&
             `                 iframe DOM of a previous open instead of the freshly set` &&
             `                 content - the Source Code tab then kept showing the class` &&
             `                 of the previously running app. -->` &&
             `            <core:HTML id="sourceHtml" preferDOM="false"/>` &&
             `        </VBox>` &&
             `        <!-- sap.m.Dialog only gained a public ``footer`` aggregation around` &&
             `             1.110; on older releases (e.g. 1.71) a <footer> tag is resolved` &&
             `             as a control and fails with "failed to load sap/m/footer.js".` &&
             `             The ``buttons`` aggregation (since 1.21.1) is the cross-version` &&
             `             footer; UI5 lays the buttons out in an overflow toolbar. -->` &&
             `        <buttons>` &&
             `            <!-- Tier 2 of the roundtrip recorder. Off by default: keeping` &&
             `                 request/response bodies is the only part of the history` &&
             `                 that costs real memory, so a production session must not` &&
             `                 pay for it unnoticed (core/devtools/Recorder.js). -->` &&
             `            <ToggleButton` &&
             `                text="Record Payloads"` &&
             `                pressed="{/recordPayloads}"` &&
             `                press=".onToggleRecordPayloads"` &&
             `            />` &&
             `            <Button` &&
             `                text="Retry"` &&
             `                visible="{/hasRetry}"` &&
             `                press=".onErrorRetry"` &&
             `            />` &&
             `            <Button` &&
             `                text="Logout"` &&
             `                press=".onErrorLogout"` &&
             `            />` &&
             `            <Button` &&
             `                text="Restart"` &&
             `                press=".onErrorRestart"` &&
             `            />` &&
             `            <Button` &&
             `                text="ADT"` &&
             `                press=".onOpenAbapInAdt"` &&
             `            />` &&
             `            <Button` &&
             `                text="Export"` &&
             `                press=".onExport"` &&
             `            />` &&
             `            <Button` &&
             `                text="Close"` &&
             `                type="Emphasized"` &&
             `                press=".onClose"` &&
             `            />` &&
             `        </buttons>` &&
             `    </Dialog>` &&
             `</core:FragmentDefinition>` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
