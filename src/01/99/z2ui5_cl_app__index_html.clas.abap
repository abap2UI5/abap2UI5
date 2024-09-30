CLASS z2ui5_cl_app__index_html DEFINITION
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


CLASS z2ui5_cl_app__index_html IMPLEMENTATION.

  METHOD get.

    result =              `<!DOCTYPE html>` && |\n|  &&
             `<html lang="en">` && |\n|  &&
             `<head>` && |\n|  &&
             `    <meta charset="UTF-8">` && |\n|  &&
             `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n|  &&
             `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n|  &&
             `    <title></title>` && |\n|  &&
             `    <style>` && |\n|  &&
             `        html, body, body > div, #container, #container-uiarea {` && |\n|  &&
             `            height: 100%;` && |\n|  &&
             `        }` && |\n|  &&
             `    </style>` && |\n|  &&
             `    <script` && |\n|  &&
             `        id="sap-ui-bootstrap"` && |\n|  &&
             `        src="https://openui5.hana.ondemand.com/resources/sap-ui-core.js"` && |\n|  &&
             `        data-sap-ui-theme="sap_horizon"` && |\n|  &&
             `        data-sap-ui-resourceroots='{` && |\n|  &&
             `            "z2ui5": "./"` && |\n|  &&
             `        }'` && |\n|  &&
             `        data-sap-ui-oninit="module:sap/ui/core/ComponentSupport"` && |\n|  &&
             `        data-sap-ui-compatVersion="edge"` && |\n|  &&
             `        data-sap-ui-async="true"` && |\n|  &&
             `        data-sap-ui-frameOptions="trusted"` && |\n|  &&
             `    ></script>` && |\n|  &&
             `</head>` && |\n|  &&
             `<body class="sapUiBody sapUiSizeCompact" id="content">` && |\n|  &&
             `    <div` && |\n|  &&
             `        data-sap-ui-component` && |\n|  &&
             `        data-name="z2ui5"` && |\n|  &&
             `        data-id="container"` && |\n|  &&
             `        data-settings='{"id" : "z2ui5"}'` && |\n|  &&
             `        data-handle-validation="true"` && |\n|  &&
             `    ></div>` && |\n|  &&
             `</body>` && |\n|  &&
             `</html>` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.