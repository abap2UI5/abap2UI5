CLASS z2ui5_cl_app_style_css DEFINITION
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


CLASS z2ui5_cl_app_style_css IMPLEMENTATION.

  METHOD get.

    result = `/* abap2UI5 — frontend styles */` &&
             `` &&
             `/* DebugTool: force LTR direction inside the debug dialog so JSON/XML stays readable in RTL apps */` &&
             `.dbg-ltr,` &&
             `.dbg-ltr * {` &&
             `    direction: ltr;` &&
             `}` &&
             `` &&
             `/* Server: full-screen error overlay shown when the backend returns a fatal error */` &&
             `.z2ui5-error-overlay {` &&
             `    position: fixed;` &&
             `    top: 50%;` &&
             `    left: 50%;` &&
             `    transform: translate(-50%, -50%);` &&
             `    width: 90%;` &&
             `    height: 90%;` &&
             `    background: white;` &&
             `    border: 2px solid #d32f2f;` &&
             `    border-radius: 4px;` &&
             `    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);` &&
             `    z-index: 9999;` &&
             `    display: flex;` &&
             `    flex-direction: column;` &&
             `}` &&
             `` &&
             `.z2ui5-error-overlay__header {` &&
             `    padding: 15px;` &&
             `    background: #d32f2f;` &&
             `    color: white;` &&
             `    display: flex;` &&
             `    justify-content: space-between;` &&
             `    align-items: center;` &&
             `}` &&
             `` &&
             `.z2ui5-error-overlay__title {` &&
             `    margin: 0;` &&
             `}` &&
             `` &&
             `.z2ui5-error-overlay__actions {` &&
             `    display: flex;` &&
             `    gap: 8px;` &&
             `}` &&
             `` &&
             `.z2ui5-error-overlay__btn {` &&
             `    padding: 6px 14px;` &&
             `    background: white;` &&
             `    color: #d32f2f;` &&
             `    border: none;` &&
             `    border-radius: 3px;` &&
             `    cursor: pointer;` &&
             `    font-weight: bold;` &&
             `}` &&
             `` &&
             `.z2ui5-error-overlay__iframe {` &&
             `    width: 100%;` &&
             `    height: 100%;` &&
             `    border: none;` &&
             `    flex: 1;` &&
             `}` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
