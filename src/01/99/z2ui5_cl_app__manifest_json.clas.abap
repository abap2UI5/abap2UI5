CLASS z2ui5_cl_app__manifest_json DEFINITION
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


CLASS z2ui5_cl_app__manifest_json IMPLEMENTATION.

  METHOD get.

    result =              `{` && |\n|  &&
             `  "_version": "1.65.0",` && |\n|  &&
             `  "sap.app": {` && |\n|  &&
             `    "id": "z2ui5",` && |\n|  &&
             `    "type": "application",` && |\n|  &&
             `    "applicationVersion": {` && |\n|  &&
             `      "version": "0.0.1"` && |\n|  &&
             `    },` && |\n|  &&
             `    "title": "{{appTitle}}",` && |\n|  &&
             `    "description": "{{appDescription}}",` && |\n|  &&
             `    "resources": "resources.json",` && |\n|  &&
             `    "sourceTemplate": {` && |\n|  &&
             `      "id": "@sap/generator-fiori:basic",` && |\n|  &&
             `      "version": "1.15.0",` && |\n|  &&
             `      "toolsId": "3a966e20-9635-4c28-8861-d1b66f79f1de"` && |\n|  &&
             `    },` && |\n|  &&
             `    "dataSources": {` && |\n|  &&
             `      "mainService": {` && |\n|  &&
             `        "uri": "/sap/bc/z2UI5",` && |\n|  &&
             `        "type": "OData",` && |\n|  &&
             `        "settings": {` && |\n|  &&
             `          "annotations": [],` && |\n|  &&
             `          "localUri": "localService/metadata.xml",` && |\n|  &&
             `          "odataVersion": "2.0"` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    "crossNavigation": {` && |\n|  &&
             `      "inbounds": {` && |\n|  &&
             `        "z2ui5-display": {` && |\n|  &&
             `          "semanticObject": "z2ui5",` && |\n|  &&
             `          "action": "display",` && |\n|  &&
             `          "title": "{{flpTitle}}",` && |\n|  &&
             `          "signature": {` && |\n|  &&
             `            "parameters": {},` && |\n|  &&
             `            "additionalParameters": "allowed"` && |\n|  &&
             `          }` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    }` && |\n|  &&
             `  },` && |\n|  &&
             `  "sap.ui": {` && |\n|  &&
             `    "technology": "UI5",` && |\n|  &&
             `    "icons": {` && |\n|  &&
             `      "icon": "",` && |\n|  &&
             `      "favIcon": "",` && |\n|  &&
             `      "phone": "",` && |\n|  &&
             `      "phone@2": "",` && |\n|  &&
             `      "tablet": "",` && |\n|  &&
             `      "tablet@2": ""` && |\n|  &&
             `    },` && |\n|  &&
             `    "deviceTypes": {` && |\n|  &&
             `      "desktop": true,` && |\n|  &&
             `      "tablet": true,` && |\n|  &&
             `      "phone": true` && |\n|  &&
             `    }` && |\n|  &&
             `  },` && |\n|  &&
             `  "sap.ui5": {` && |\n|  &&
             `    "flexEnabled": true,` && |\n|  &&
             `    "dependencies": {` && |\n|  &&
             `      "minUI5Version": "1.128.1",` && |\n|  &&
             `      "libs": {` && |\n|  &&
             `        "sap.m": {},` && |\n|  &&
             `        "sap.ui.core": {}` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    "contentDensities": {` && |\n|  &&
             `      "compact": true,` && |\n|  &&
             `      "cozy": true` && |\n|  &&
             `    },` && |\n|  &&
             `    "services": {                                                                                   ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                       ` && |\n|  &&
             `      "ShellUIService": {                                                                           ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                       ` && |\n|  &&
             `        "factoryName": "sap.ushell.ui5service.ShellUIService"                                       ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                       ` && |\n|  &&
             `      }                                                                                             ` && |\n|  &&
             `                                                                                                    ` && |\n|  &&
             `                                                       ` && |\n|  &&
             `    },          ` && |\n|  &&
             `    "models": {` && |\n|  &&
             `      "": {` && |\n|  &&
             `        "dataSource": "mainService",` && |\n|  &&
             `        "preload": true,` && |\n|  &&
             `        "settings": {}` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    "resources": {` && |\n|  &&
             `      "css": [` && |\n|  &&
             `        {` && |\n|  &&
             `          "uri": "css/style.css"` && |\n|  &&
             `        }` && |\n|  &&
             `      ]` && |\n|  &&
             `    },` && |\n|  &&
             `    "routing": {` && |\n|  &&
             `      "config": {` && |\n|  &&
             `        "routerClass": "sap.m.routing.Router",` && |\n|  &&
             `        "viewType": "XML",` && |\n|  &&
             `        "async": true,` && |\n|  &&
             `        "viewPath": "z2ui5.view",` && |\n|  &&
             `        "controlAggregation": "pages",` && |\n|  &&
             `        "controlId": "app",` && |\n|  &&
             `        "clearControlAggregation": false` && |\n|  &&
             `      },` && |\n|  &&
             `      "routes": [` && |\n|  &&
             `        {` && |\n|  &&
             `          "name": "RouteView1",` && |\n|  &&
             `          "pattern": ":?query:",` && |\n|  &&
             `          "target": [` && |\n|  &&
             `            "TargetView1"` && |\n|  &&
             `          ]` && |\n|  &&
             `        },` && |\n|  &&
             `        {` && |\n|  &&
             `          "name": "RouteView2",` && |\n|  &&
             `          "pattern": ":?query:",` && |\n|  &&
             `          "target": [` && |\n|  &&
             `            "TargetView2"` && |\n|  &&
             `          ]` && |\n|  &&
             `        }` && |\n|  &&
             `      ],` && |\n|  &&
             `      "targets": {` && |\n|  &&
             `        "TargetView1": {` && |\n|  &&
             `          "viewType": "XML",` && |\n|  &&
             `          "transition": "flip",` && |\n|  &&
             `          "clearControlAggregation": false,` && |\n|  &&
             `          "viewId": "View1",` && |\n|  &&
             `          "viewName": "View1"` && |\n|  &&
             `        },` && |\n|  &&
             `        "TargetView2": {` && |\n|  &&
             `          "viewType": "XML",` && |\n|  &&
             `          "transition": "flip",` && |\n|  &&
             `          "clearControlAggregation": false,` && |\n|  &&
             `          "viewId": "View2",` && |\n|  &&
             `          "viewName": "View2"` && |\n|  &&
             `        }` && |\n|  &&
             `      }` && |\n|  &&
             `    },` && |\n|  &&
             `    "rootView": {` && |\n|  &&
             `      "viewName": "z2ui5.view.App",` && |\n|  &&
             `      "type": "XML",` && |\n|  &&
             `      "async": true,` && |\n|  &&
             `      "id": "App"` && |\n|  &&
             `    }` && |\n|  &&
             `  },` && |\n|  &&
             `  "sap.cloud": {` && |\n|  &&
             `    "public": true,` && |\n|  &&
             `    "service": "z2ui5"` && |\n|  &&
             `  }` && |\n|  &&
             `}` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.