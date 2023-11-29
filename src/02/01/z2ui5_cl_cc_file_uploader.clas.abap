class Z2UI5_CL_CC_FILE_UPLOADER definition
  public
  final
  create public .

public section.

  methods CONTROL
    importing
      !VALUE type CLIKE optional
      !PATH type CLIKE optional
      !PLACEHOLDER type CLIKE optional
      !UPLOAD type CLIKE optional
      !ICONONLY type CLIKE optional
      !BUTTONONLY type CLIKE optional
      !BUTTONTEXT type CLIKE optional
      !UPLOADBUTTONTEXT type CLIKE optional
      !CHECKDIRECTUPLOAD type CLIKE optional
      !FILETYPE type CLIKE optional
      !VISIBLE type CLIKE optional
      !STYLE type CLIKE optional
      !ICON type CLIKE optional
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONSTRUCTOR
    importing
      !VIEW type ref to Z2UI5_CL_XML_VIEW .
  methods LOAD_CC
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  class-methods GET_JS
    returning
      value(R_JS) type STRING .
  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.
  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_CC_FILE_UPLOADER IMPLEMENTATION.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD control.

    result = mo_view.
    mo_view->_generic( name   = `FileUploader`
              ns     = `z2ui5`
              t_prop = VALUE #( (  n = `placeholder`         v = placeholder )
                                (  n = `upload`              v = upload )
                                (  n = `path`                v = path )
                                (  n = `value`               v = value )
                                (  n = `iconOnly`            v = z2ui5_cl_fw_utility=>boolean_abap_2_json( icononly ) )
                                (  n = `buttonOnly`          v = z2ui5_cl_fw_utility=>boolean_abap_2_json( buttononly ) )
                                (  n = `visible`             v = z2ui5_cl_fw_utility=>boolean_abap_2_json( visible ) )
                                (  n = `buttonText`          v = buttontext )
                                (  n = `uploadButtonText`    v = uploadbuttontext )
                                (  n = `fileType`            v = filetype )
                                (  n = `style`               v = style )
                                (  n = `icon`                v = icon )
                                (  n = `checkDirectUpload`   v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkdirectupload ) ) ) ).

  ENDMETHOD.


  METHOD get_js.

    r_js  = `jQuery.sap.declare("z2ui5.FileUploader");` && |\n| &&
                     |\n| &&
                     `        sap.ui.require([` && |\n| &&
                     `            "sap/ui/core/Control",` && |\n| &&
                     `            "sap/m/Button",` && |\n| &&
                     `            "sap/ui/unified/FileUploader"` && |\n| &&
                     `        ], function (Control, Button, FileUploader) {` && |\n| &&
                     `            "use strict";` && |\n| &&
                     |\n| &&
                     `            return Control.extend("z2ui5.FileUploader", {` && |\n| &&
                     |\n| &&
                     `                metadata: {` && |\n| &&
                     `                    properties: {` && |\n| &&
                     `                        value: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        path: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        tooltip: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        fileType: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        placeholder: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        buttonText: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        style: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: ""` && |\n| &&
                     `                        },` && |\n| &&
                     `                        uploadButtonText: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: "Upload"` && |\n| &&
                     `                        },` && |\n| &&
                     `                        enabled: {` && |\n| &&
                     `                            type: "boolean",` && |\n| &&
                     `                            defaultValue: true` && |\n| &&
                     `                        },` && |\n| &&
                     `                        icon: {` && |\n| &&
                     `                            type: "string",` && |\n| &&
                     `                            defaultValue: "sap-icon://browse-folder"` && |\n| &&
                     `                        },` && |\n| &&
                     `                        iconOnly: {` && |\n| &&
                     `                            type: "boolean",` && |\n| &&
                     `                            defaultValue: false` && |\n| &&
                     `                        },` && |\n| &&
                     `                        buttonOnly: {` && |\n| &&
                     `                            type: "boolean",` && |\n| &&
                     `                            defaultValue: false` && |\n| &&
                     `                        },` && |\n| &&
                     `                        multiple: {` && |\n| &&
                     `                            type: "boolean",` && |\n| &&
                     `                            defaultValue: false` && |\n| &&
                     `                        },` && |\n| &&
                     `                        visible: {` && |\n| &&
                     `                            type: "boolean",` && |\n| &&
                     `                            defaultValue: true` && |\n| &&
                     `                        },` && |\n| &&
                     `                        checkDirectUpload: {` && |\n| &&
                     `                            type: "boolean",` && |\n| &&
                     `                            defaultValue: false` && |\n| &&
                     `                        }` && |\n| &&
                     `                    },` && |\n| &&
                     |\n| &&
                     |\n| &&
                     `                    aggregations: {` && |\n| &&
                     `                    },` && |\n| &&
                     `                    events: {` && |\n| &&
                     `                        "upload": {` && |\n| &&
                     `                            allowPreventDefault: true,` && |\n| &&
                     `                            parameters: {}` && |\n| &&
                     `                        }` && |\n| &&
                     `                    },` && |\n| &&
                     `                    renderer: null` && |\n| &&
                     `                },` && |\n| &&
                     |\n| &&
                     `                renderer: function (oRm, oControl) {` && |\n| &&
                     |\n| &&
                     `                    if (!oControl.getProperty("checkDirectUpload")) {` && |\n| &&
                     `                     oControl.oUploadButton = new Button({` && |\n| &&
                     `                        text: oControl.getProperty("uploadButtonText"),` && |\n| &&
                     `                        enabled: oControl.getProperty("path") !== "",` && |\n| &&
                     `                        press: function (oEvent) { ` && |\n| &&
                     |\n| &&
                     `                            this.setProperty("path", this.oFileUploader.getProperty("value"));` && |\n| &&
                     |\n| &&
                     `                            var file = sap.z2ui5.oUpload.oFileUpload.files[0];` && |\n| &&
                     `                            var reader = new FileReader();` && |\n| &&
                     |\n| &&
                     `                            reader.onload = function (evt) {` && |\n| &&
                     `                                var vContent = evt.currentTarget.result;` && |\n| &&
                     `                                this.setProperty("value", vContent);` && |\n| &&
                     `                                this.fireUpload();` && |\n| &&
                     `                                //this.getView().byId('picture' ).getDomRef().src = vContent;` && |\n| &&
                     `                            }.bind(this)` && |\n| &&
                     |\n| &&
                     `                            reader.readAsDataURL(file);` && |\n| &&
                     `                        }.bind(oControl)` && |\n| &&
                     `                     });` && |\n| &&
                     `                    }` && |\n| &&
                     |\n| &&
                     `                    oControl.oFileUploader = new FileUploader({` && |\n| &&
                     `                        icon: oControl.getProperty("icon"),` && |\n| &&
                     `                        iconOnly: oControl.getProperty("iconOnly"),` && |\n| &&
                     `                        buttonOnly: oControl.getProperty("buttonOnly"),` && |\n| &&
                     `                        buttonText: oControl.getProperty("buttonText"),` && |\n| &&
                     `                        style: oControl.getProperty("style"),` && |\n| &&
                     `                        fileType: oControl.getProperty("fileType"),` && |\n| &&
                     `                        visible: oControl.getProperty("visible"),` && |\n| &&
                     `                        uploadOnChange: true,` && |\n| &&
                     `                        value: oControl.getProperty("path"),` && |\n| &&
                     `                        placeholder: oControl.getProperty("placeholder"),` && |\n| &&
                     `                        change: function (oEvent) {` && |\n| &&
                     `                           if (oControl.getProperty("checkDirectUpload")) {` && |\n| &&
                     `                             return; ` && |\n| &&
                     `                           }` && |\n| &&
                     |\n| &&
                     `                            var value = oEvent.getSource().getProperty("value");` && |\n| &&
                     `                            this.setProperty("path", value);` && |\n| &&
                     `                            if (value) {` && |\n| &&
                     `                                this.oUploadButton.setEnabled();` && |\n| &&
                     `                            } else {` && |\n| &&
                     `                                this.oUploadButton.setEnabled(false);` && |\n| &&
                     `                            }` && |\n| &&
                     `                            this.oUploadButton.rerender();` && |\n| &&
                     `                            sap.z2ui5.oUpload = oEvent.oSource;` && |\n| &&
                     `                        }.bind(oControl),` && |\n| &&
                     `                        uploadComplete: function (oEvent) {` && |\n| &&
                     `                           if (!oControl.getProperty("checkDirectUpload")) {` && |\n| &&
                     `                             return; ` && |\n| &&
                     `                           }` && |\n| &&
                     |\n| &&
                     `                            var value = oEvent.getSource().getProperty("value");` && |\n| &&
                     `                            this.setProperty("path", value);` && |\n| &&
                     |\n| &&
                     `                            var file = oEvent.oSource.oFileUpload.files[0];` && |\n| &&
                     `                            var reader = new FileReader();` && |\n| &&
                     |\n| &&
                     `                            reader.onload = function (evt) {` && |\n| &&
                     `                                var vContent = evt.currentTarget.result;` && |\n| &&
                     `                                this.setProperty("value", vContent);` && |\n| &&
                     `                                this.fireUpload();` && |\n| &&
                     `                            }.bind(this)` && |\n| &&
                     |\n| &&
                     `                            reader.readAsDataURL(file);` && |\n| &&
                     `                        }.bind(oControl)` && |\n| &&
                     `                    });` && |\n| &&
                     |\n| &&
                     `                    var hbox = new sap.m.HBox();` && |\n| &&
                     `                    hbox.addItem(oControl.oFileUploader);` && |\n| &&
                     `                    hbox.addItem(oControl.oUploadButton);` && |\n| &&
                     `                    oRm.renderControl(hbox);` && |\n| &&
                     `                }` && |\n| &&
                     `            });` && |\n| &&
                     `        });`.

  ENDMETHOD.


  METHOD load_cc.

    DATA(js) = get_js( ).
    result = mo_view->_generic( ns = `html` name = `script` )->_cc_plain_xml( js )->get_parent( ).

  ENDMETHOD.
ENDCLASS.
