(function (sap) {
    var fioriToolsGetManifestLibs = function (manifestPath) {
        var url = manifestPath;
        var result = "";
        // SAPUI5 delivered namespaces from https://ui5.sap.com/#/api/sap
        var ui5Libs = [
            "sap.apf",
            "sap.base",
            "sap.chart",
            "sap.collaboration",
            "sap.f",
            "sap.fe",
            "sap.fileviewer",
            "sap.gantt",
            "sap.landvisz",
            "sap.m",
            "sap.ndc",
            "sap.ovp",
            "sap.rules",
            "sap.suite",
            "sap.tnt",
            "sap.ui",
            "sap.uiext",
            "sap.ushell",
            "sap.uxap",
            "sap.viz",
            "sap.webanalytics",
            "sap.zen"
        ];
        function getKeys(libOrComp, libOrCompKeysString) {
            var libOrCompKeysStringTmp = libOrCompKeysString;
            Object.keys(libOrComp).forEach(function (libOrCompKey) {
                // ignore libs or Components that start with SAPUI5 delivered namespaces
                if (!ui5Libs.some(function (substring) { return libOrCompKey === substring || libOrCompKey.startsWith(substring + "."); })) {
                    if (libOrCompKeysStringTmp.length > 0) {
                        libOrCompKeysStringTmp = libOrCompKeysStringTmp + "," + libOrCompKey;
                    } else {
                        libOrCompKeysStringTmp = libOrCompKey;
                    }
                }
            });
            return libOrCompKeysStringTmp;
        }
        function getComponentUsageNames(compUsages, libOrCompKeysString) {
            var libOrCompKeysStringTmp = libOrCompKeysString;
            var compNames = Object.keys(compUsages).map(function (compUsageKey) {
                return compUsages[compUsageKey].name;
            });
            compNames.forEach(function (compName) {
                // ignore libs or Components that start with SAPUI5 delivered namespaces
                if (!ui5Libs.some(function (substring) { return compName === substring || compName.startsWith(substring + "."); })) {
                    if (libOrCompKeysStringTmp.length > 0) {
                        libOrCompKeysStringTmp = libOrCompKeysStringTmp + "," + compName;
                    } else {
                        libOrCompKeysStringTmp = compName;
                    }
                }
            });
            return libOrCompKeysStringTmp;
        }
        return new Promise(function (resolve, reject) {
            $.ajax(url)
                .done(function (manifest) {
                    if (manifest) {
                        if (
                            manifest["sap.ui5"] &&
                            manifest["sap.ui5"].dependencies
                        ) {
                            if (manifest["sap.ui5"].dependencies.libs) {
                                result = getKeys(manifest["sap.ui5"].dependencies.libs, result);
                            }
                            if (manifest["sap.ui5"].dependencies.components) {
                                result = getKeys(manifest["sap.ui5"].dependencies.components, result);
                            }
                        }
                        if (
                            manifest["sap.ui5"] &&
                            manifest["sap.ui5"].componentUsages
                        ) {
                            result = getComponentUsageNames(manifest["sap.ui5"].componentUsages, result);
                        }
                    }
                    resolve(result);
                })
                .fail(function () {
                    reject(new Error("Could not fetch manifest at '" + manifestPath));
                });
        });
    };
    function registerModules(dataFromAppIndex) {
        Object.keys(dataFromAppIndex).forEach(function (moduleDefinitionKey) {
            var moduleDefinition = dataFromAppIndex[moduleDefinitionKey];
            if (moduleDefinition && moduleDefinition.dependencies) {
                moduleDefinition.dependencies.forEach(function (dependency) {
                    if (dependency.url && dependency.url.length > 0 && dependency.type === "UI5LIB") {
                        sap.ui.require(["sap/base/Log"], function (Log) {
                            Log.info("Registering Library " +
                                dependency.componentId +
                                " from server " +
                                dependency.url);
                        });
                        var compId = dependency.componentId.replace(/\./g, "/");
                        var config = {
                            paths: {
                            }
                        };
                        config.paths[compId] = dependency.url;
                        sap.ui.loader.config(config);
                    }
                });
            }
        });
    }
    /**
     * Registers the module paths for dependencies of the given component.
     * @param {string} manifestPath The the path to the app manifest path
     * for which the dependencies should be registered.
     * @returns {Promise} A promise which is resolved when the ajax request for
     * the app-index was successful and the module paths were registered.
     */
    sap.registerComponentDependencyPaths = function (manifestPath) {

        return fioriToolsGetManifestLibs(manifestPath).then(function (libs) {
            if (libs && libs.length > 0) {
                var url = "/sap/bc/ui2/app_index/ui5_app_info?id=" + libs;
                var sapClient = "";

                return new Promise(
                    function (resolve) {
                        sap.ui.require(["sap/base/util/UriParameters"], function (UriParameters) {
                            sapClient = UriParameters.fromQuery(window.location.search).get("sap-client");
                            if (sapClient && sapClient.length === 3) {
                                url = url + "&sap-client=" + sapClient;
                            }
                            resolve(url);
                        });
                    }).then(function (url2) {
                        return $.ajax(url2).done(function (data) {
                            if (data) {
                                registerModules(data);
                            }
                        });
                    });
            } else {
                return undefined;
            }
        });
    };
})(sap);

function registerSAPFonts() {  
    sap.ui.require(["sap/ui/core/IconPool"], function (IconPool) {  
    //Fiori Theme font family and URI
    var fioriTheme = {
        fontFamily: "SAP-icons-TNT",
        fontURI: sap.ui.require.toUrl("sap/tnt/themes/base/fonts/")
    };
    //Registering to the icon pool
    IconPool.registerFont(fioriTheme);
    //SAP Business Suite Theme font family and URI
    var bSuiteTheme = {
        fontFamily: "BusinessSuiteInAppSymbols",
        fontURI: sap.ui.require.toUrl("sap/ushell/themes/base/fonts/")
    };
    //Registering to the icon pool
    IconPool.registerFont(bSuiteTheme);
    });
}

/*eslint-disable fiori-custom/sap-browser-api-warning, fiori-custom/sap-no-dom-access*/
var currentScript = document.getElementById("locate-reuse-libs");
if (!currentScript) {
    currentScript = document.currentScript;
}
var manifestUri = currentScript.getAttribute("data-sap-ui-manifest-uri");
var componentName = currentScript.getAttribute("data-sap-ui-componentName");
var useMockserver = currentScript.getAttribute("data-sap-ui-use-mockserver");

sap.registerComponentDependencyPaths(manifestUri)
    .catch(function (error) {
        sap.ui.require(["sap/base/Log"], function (Log) {
            Log.error(error);
        });
    })
    .finally(function () {

        // setting the app title with internationalization 
        sap.ui.getCore().attachInit(function () {
            var sLocale = sap.ui.getCore().getConfiguration().getLanguage();
            sap.ui.require(["sap/base/i18n/ResourceBundle"], function (ResourceBundle) {
                var oResourceBundle = ResourceBundle.create({
                    url: "i18n/i18n.properties",
                    locale: sLocale
                });
                document.title = oResourceBundle.getText("appTitle");
            });
        });

        if (componentName && componentName.length > 0) {
            if (useMockserver && useMockserver === "true") {
                sap.ui.getCore().attachInit(function () {
                    registerSAPFonts();
                    sap.ui.require([componentName.replace(/\./g, "/") + "/localService/mockserver"], function (server) {
                        // set up test service for local testing
                        server.init();
                        // initialize the ushell sandbox component
                        sap.ushell.Container.createRenderer().placeAt("content");
                    });
                });
            } else {
                // Requiring the ComponentSupport module automatically executes the component initialisation for all declaratively defined components
                sap.ui.require(["sap/ui/core/ComponentSupport"]);

                // setting the app title with the i18n text 
                sap.ui.getCore().attachInit(function () {
                    registerSAPFonts();
                    var sLocale = sap.ui.getCore().getConfiguration().getLanguage();
                    sap.ui.require(["sap/base/i18n/ResourceBundle"], function (ResourceBundle) {
                        var oResourceBundle = ResourceBundle.create({
                            url: "i18n/i18n.properties",
                            locale: sLocale
                        });
                        document.title = oResourceBundle.getText("appTitle");
                    });
                });
            }
        } else {
            sap.ui.getCore().attachInit(function () {
                registerSAPFonts();
                try {
                    // initialize the ushell sandbox component in ui5 v2
                    sap.ushell.Container.createRenderer(true).then(function (component) {
                        component.placeAt("content");
                    });
                } catch {
                    // support older versions of ui5 
                    sap.ushell.Container.createRenderer().placeAt("content");
                }
            });
        }
    });