CLASS z2ui5_cl_app_manifest_json DEFINITION
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


CLASS z2ui5_cl_app_manifest_json IMPLEMENTATION.

  METHOD get.

    result =              `{` &&
             `  "_version": "1.65.0",` &&
             `  "sap.app": {` &&
             `    "id": "z2ui5",` &&
             `    "type": "application",` &&
             `    "applicationVersion": {` &&
             `      "version": "0.0.1"` &&
             `    },` &&
             `    "title": "",` &&
             `    "description": "",` &&
             `    "resources": "resources.json",` &&
             `    "sourceTemplate": {` &&
             `      "id": "@sap/generator-fiori:basic",` &&
             `      "version": "1.15.0",` &&
             `      "toolsId": "3a966e20-9635-4c28-8861-d1b66f79f1de"` &&
             `    },` &&
             `    "dataSources": {` &&
             `      "http": {` &&
             `        "uri": "/sap/bc/z2ui5",` &&
             `        "type": "OData",` &&
             `        "settings": {` &&
             `          "annotations": [],` &&
             `          "localUri": "localService/metadata.xml",` &&
             `          "odataVersion": "2.0"` &&
             `        }` &&
             `      }` &&
             `    },` &&
             `    "crossNavigation": {` &&
             `      "inbounds": {` &&
             `        "z2ui5-display": {` &&
             `          "semanticObject": "z2ui5",` &&
             `          "action": "display",` &&
             `          "title": "",` &&
             `          "signature": {` &&
             `            "parameters": {},` &&
             `            "additionalParameters": "allowed"` &&
             `          }` &&
             `        }` &&
             `      }` &&
             `    }` &&
             `  },` &&
             `  "sap.ui": {` &&
             `    "technology": "UI5",` &&
             `    "icons": {` &&
             `      "icon": "",` &&
             `      "favIcon": "",` &&
             `      "phone": "",` &&
             `      "phone@2": "",` &&
             `      "tablet": "",` &&
             `      "tablet@2": ""` &&
             `    },` &&
             `    "deviceTypes": {` &&
             `      "desktop": true,` &&
             `      "tablet": true,` &&
             `      "phone": true` &&
             `    }` &&
             `  },` &&
             `  "sap.ui5": {` &&
             `    "flexEnabled": true,` &&
             `    "dependencies": {` &&
             `      "minUI5Version": "1.128.1",` &&
             `      "libs": {` &&
             `        "sap.m": {},` &&
             `        "sap.ui.core": {}` &&
             `      }` &&
             `    },` &&
             `    "contentDensities": {` &&
             `      "compact": true,` &&
             `      "cozy": true` &&
             `    },` &&
             `    "services": {` &&
             `      "ShellUIService": {` &&
             `        "factoryName": "sap.ushell.ui5service.ShellUIService"` &&
             `      }` &&
             `    },` &&
             `    "resources": {` &&
             `      "css": [` &&
             `        {` &&
             `          "uri": "css/style.css"` &&
             `        }` &&
             `      ]` &&
             `    },` &&
             `    "routing": {` &&
             `      "config": {` &&
             `        "routerClass": "sap.m.routing.Router",` &&
             `        "viewType": "XML",` &&
             `        "viewPath": "z2ui5.view",` &&
             `        "controlAggregation": "pages",` &&
             `        "controlId": "app",` &&
             `        "clearControlAggregation": false` &&
             `      },` &&
             `      "routes": [` &&
             `        {` &&
             `          "name": "RouteView1",` &&
             `          "pattern": ":?query:",` &&
             `          "target": [` &&
             `            "TargetView1"` &&
             `          ]` &&
             `        },` &&
             `        {` &&
             `          "name": "RouteView2",` &&
             `          "pattern": ":?query:",` &&
             `          "target": [` &&
             `            "TargetView2"` &&
             `          ]` &&
             `        }` &&
             `      ],` &&
             `      "targets": {` &&
             `        "TargetView1": {` &&
             `          "viewType": "XML",` &&
             `          "transition": "flip",` &&
             `          "clearControlAggregation": false,` &&
             `          "viewId": "View1",` &&
             `          "viewName": "View1"` &&
             `        },` &&
             `        "TargetView2": {` &&
             `          "viewType": "XML",` &&
             `          "transition": "flip",` &&
             `          "clearControlAggregation": false,` &&
             `          "viewId": "View2",` &&
             `          "viewName": "View2"` &&
             `        }` &&
             `      }` &&
             `    },` &&
             `    "rootView": {` &&
             `      "viewName": "z2ui5.view.App",` &&
             `      "type": "XML",` &&
             `      "id": "App"` &&
             `    }` &&
             `  },` &&
             `  "sap.cloud": {` &&
             `    "public": true,` &&
             `    "service": "z2ui5"` &&
             `  }` &&
             `}` &&
             `` &&
              ``.

  ENDMETHOD.

ENDCLASS.
