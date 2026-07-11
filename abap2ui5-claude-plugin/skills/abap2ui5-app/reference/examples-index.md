# Examples Index — "which example shows what"

A lookup over the official **abap2UI5/samples** repo
(<https://github.com/abap2UI5/samples>), mined from its launchpad app
`z2ui5_cl_demo_app_000`. When the user asks for a feature, find the nearest entry
here and **read that demo class first** — each is a complete, lint-clean,
working implementation to adapt. The classes live at
`src/z2ui5_cl_demo_app_<NNN>.clas.abap` in that repo; fetch the file
(raw.githubusercontent.com or a local clone) and adapt it to your own class name
and data. Class names are case-insensitive at runtime.

## General

### Binding
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_001 | Binding I — Simple, send values to the backend |
| z2ui5_cl_demo_app_166 | Binding II — Structure component level |
| z2ui5_cl_demo_app_144 | Binding III — Table cell level |
| z2ui5_cl_demo_app_071 | setSizeLimit |

### Events
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_004 | Event I — Handle events & change the view |
| z2ui5_cl_demo_app_024 | Event II — Call other apps & exchange data |
| z2ui5_cl_demo_app_167 | Event III — Additional infos with t_args |
| z2ui5_cl_demo_app_197 | Event IV — Facet filter, t_arg with objects |

### Features
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_028 | Timer I — Wait n ms and call the server again |
| z2ui5_cl_demo_app_064 | Timer II — Loading indicator while server request |
| z2ui5_cl_demo_app_073 | New tab — open a URL in a new tab |
| z2ui5_cl_demo_app_325 | Clipboard — copy & paste text |
| z2ui5_cl_demo_app_133 | Focus I |
| z2ui5_cl_demo_app_189 | Focus II |
| z2ui5_cl_demo_app_362 | Scroll to position |
| z2ui5_cl_demo_app_363 | Scroll into view |
| z2ui5_cl_demo_app_139 | History |
| z2ui5_cl_demo_app_279 | Data loss protection |
| z2ui5_cl_demo_app_125 | Tab title |
| z2ui5_cl_demo_app_s_02 | Session stickiness I — stateful mode |
| z2ui5_cl_demo_app_s_01 | Session stickiness II — use locks |
| z2ui5_cl_demo_app_327 | Local/session storage |
| z2ui5_cl_demo_app_361 | System logout — SYSTEM_LOGOUT client event |

### Messages
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_008 | Basic — toast, box & strip |
| z2ui5_cl_demo_app_187 | Message box — sy, bapiret, cx_root |
| z2ui5_cl_demo_app_154 | Popup — messages & exception |
| z2ui5_cl_demo_app_038 | Message view — custom popup, popover & output |

### File API
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_057 | Download CSV — export table as CSV |
| z2ui5_cl_demo_app_074 | Upload CSV — import CSV as internal table |
| z2ui5_cl_demo_app_075 | File uploader — upload files to the backend |
| z2ui5_cl_demo_app_186 | File download — download files to the frontend |

### S-RTTI — Dynamic Typing
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_061 | Dynamic types — send tables to the frontend |
| z2ui5_cl_demo_app_131 | Dynamic objects I — render different subapps |
| z2ui5_cl_demo_app_117 | Dynamic objects II — generic data refs in subapps |
| z2ui5_cl_demo_app_185 | Dynamic objects III — generic data refs in subapps |

### Device Capabilities
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_120 | Geolocation |
| z2ui5_cl_demo_app_122 | Frontend infos |
| z2ui5_cl_demo_app_306 | Camera |

## Input & Output

### Output
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_051 | Label |
| z2ui5_cl_demo_app_022 | Progress indicator |
| z2ui5_cl_demo_app_079 | PDF viewer — display PDFs via iframe |
| z2ui5_cl_demo_app_015 | Formatted text — display HTML |
| z2ui5_cl_demo_app_206 | Text — max lines |
| z2ui5_cl_demo_app_209 | InfoLabel |
| z2ui5_cl_demo_app_215 | Busy indicator |
| z2ui5_cl_demo_app_272 | Object header — circle-shaped image |
| z2ui5_cl_demo_app_303 | Object page header — with header container |
| z2ui5_cl_demo_app_289 | Object marker in a table |
| z2ui5_cl_demo_app_293 | Link |
| z2ui5_cl_demo_app_300 | Object status |
| z2ui5_cl_demo_app_302 | Object attribute inside table |
| z2ui5_cl_demo_app_330 | ObjectPage — hidden section titles |

### Input
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_041 | Step input |
| z2ui5_cl_demo_app_005 | Range slider |
| z2ui5_cl_demo_app_021 | Text area |
| z2ui5_cl_demo_app_035 | Code editor |
| z2ui5_cl_demo_app_106 | Rich text editor |
| z2ui5_cl_demo_app_101 | Feed input |
| z2ui5_cl_demo_app_207 | Radio button |
| z2ui5_cl_demo_app_208 | Radio button group |
| z2ui5_cl_demo_app_210 | Input — types |
| z2ui5_cl_demo_app_213 | Input — password |
| z2ui5_cl_demo_app_220 | Rating indicator |
| z2ui5_cl_demo_app_229 | ComboBox — suggestions wrapping |
| z2ui5_cl_demo_app_231 | Date range selection |
| z2ui5_cl_demo_app_232 | Multi input — suggestions wrapping |
| z2ui5_cl_demo_app_233 | Multi combo box — suggestions wrapping |
| z2ui5_cl_demo_app_237 | Slider |
| z2ui5_cl_demo_app_239 | Checkbox |
| z2ui5_cl_demo_app_240 | Switch |
| z2ui5_cl_demo_app_288 | Select |
| z2ui5_cl_demo_app_297 | Select — with icons |
| z2ui5_cl_demo_app_301 | Expandable text |

### Interaction
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_053 | Search field I — filter with enter |
| z2ui5_cl_demo_app_059 | Search field II — filter with live change event |
| z2ui5_cl_demo_app_078 | Multi input — token & range handling |
| z2ui5_cl_demo_app_270 | Color picker |
| z2ui5_cl_demo_app_292 | Breadcrumbs |
| z2ui5_cl_demo_app_316 | URL helper — email, telephone, SMS |

### Formatting & Calculations
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_047 | Data types — integer, decimals, dates & time |
| z2ui5_cl_demo_app_067 | Formatting — currencies |
| z2ui5_cl_demo_app_110 | Mask input |
| z2ui5_cl_demo_app_027 | Expression binding — calculations in views |

### Tiles
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_228 | Tile — numeric content without margins |
| z2ui5_cl_demo_app_277 | Tile — KPI tile |
| z2ui5_cl_demo_app_262 | Tile — numeric content of different colors |
| z2ui5_cl_demo_app_271 | Tile — image content |
| z2ui5_cl_demo_app_281 | Tile — statuses |

## Tables & Trees

### Table
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_006 | Toolbar — add a container & toolbar |
| z2ui5_cl_demo_app_019 | Selection modes — single & multi select |
| z2ui5_cl_demo_app_011 | Editable — set columns editable |
| z2ui5_cl_demo_app_072 | Visualization — object number, states & tab filter |
| z2ui5_cl_demo_app_183 | Column menu |
| z2ui5_cl_demo_app_305 | Cell coloring |
| z2ui5_cl_demo_app_070 | ui.Table I — simple example |
| z2ui5_cl_demo_app_160 | ui.Table II — events on cell level |
| z2ui5_cl_demo_app_307 | Grid list — with drag & drop |

### Lists
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_003 | List I — basic |
| z2ui5_cl_demo_app_048 | List II — events & visualization |
| z2ui5_cl_demo_app_216 | Action list item |
| z2ui5_cl_demo_app_219 | Input list item |
| z2ui5_cl_demo_app_290 | Object list item — markers aggregation |

### Trees
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_068 | Tree table I — popup select entry |
| z2ui5_cl_demo_app_364 | Tree table II — checkbox binding per node |

## Popups & Popovers

### Popups
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_012 | Flow logic — different ways of calling popups |
| z2ui5_cl_demo_app_161 | Call popup in popup — backend popup stack handling |
| z2ui5_cl_demo_app_009 | F4 value help — popup for value help |
| z2ui5_cl_demo_app_273 | LightBox |

### Popovers
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_026 | Popover — simple example |
| z2ui5_cl_demo_app_052 | Popover item level — popover for a specific table entry |
| z2ui5_cl_demo_app_081 | Popover with list |
| z2ui5_cl_demo_app_109 | Popover with quick view |
| z2ui5_cl_demo_app_163 | Popover with action sheet |

### Built-in Popups (z2ui5_cl_pop_*)
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_151 | Popup to inform |
| z2ui5_cl_demo_app_150 | Popup to confirm |
| z2ui5_cl_demo_app_174 | Popup to select |
| z2ui5_cl_demo_app_155 | Popup textedit |
| z2ui5_cl_demo_app_156 | Popup input value |
| z2ui5_cl_demo_app_157 | Popup file upload |
| z2ui5_cl_demo_app_158 | Popup display PDF |
| z2ui5_cl_demo_app_056 | Popup get range — select-options in multi inputs |
| z2ui5_cl_demo_app_162 | Popup get range multi — select-options for structures & tables |
| z2ui5_cl_demo_app_164 | Popup display table |
| z2ui5_cl_demo_app_168 | Popup display download |
| z2ui5_cl_demo_app_149 | Popup display HTML |
| z2ui5_cl_demo_app_365 | Popup display CL_DEMO_OUTPUT |

## More Controls

### Visualization
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_080 | Planning calendar |
| z2ui5_cl_demo_app_175 | Wizard control I |
| z2ui5_cl_demo_app_202 | Wizard control II — next step & subsequent step |
| z2ui5_cl_demo_app_181 | Cards |

### Layouts
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_010 | Header, footer, grid — split view into areas |
| z2ui5_cl_demo_app_030 | Dynamic page — display items |
| z2ui5_cl_demo_app_069 | Flexible column layout — master/details with tree |
| z2ui5_cl_demo_app_103 | Splitting container |
| z2ui5_cl_demo_app_205 | Flex box — basic alignment |
| z2ui5_cl_demo_app_247 | Splitter layout — 2 areas |
| z2ui5_cl_demo_app_269 | Shell bar — title mega menu |

### Nested Views
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_065 | Nested views I — basic example |
| z2ui5_cl_demo_app_097 | Nested views II — head & item table |
| z2ui5_cl_demo_app_098 | Nested views III — head & item table & detail |
| z2ui5_cl_demo_app_104 | Nested views IV — sub-app |

### Navigation Container
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_088 | Nav container I |
| z2ui5_cl_demo_app_221 | Icon tab bar — icons only |
| z2ui5_cl_demo_app_226 | Icon tab bar — sub tabs |
| z2ui5_cl_demo_app_227 | Bar — page, toolbar & bar |

### Templating
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_173 | Templating I — basic example |
| z2ui5_cl_demo_app_176 | Templating II — nested views |

## Custom Extensions

### CSS
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_310 | Messages with styles I |
| z2ui5_cl_demo_app_311 | Messages with styles II |
| z2ui5_cl_demo_app_050 | Change CSS — send your own CSS to the frontend |

### General
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_031 | Import view — copy & paste views from the UI5 docs |
| z2ui5_cl_demo_app_s_05 | Websocket — consume APC messages |

## Generic XML Builder (z2ui5_cl_util_xml — obsolete, now pkg 99; avoid in new apps)
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_355 | InputListItem sample |
| z2ui5_cl_demo_app_357 | Controls overview |
| z2ui5_cl_demo_app_358 | Table |
| z2ui5_cl_demo_app_359 | Expression binding |
| z2ui5_cl_demo_app_360 | Formatter |

## Native JS / Extensions (pkg 03)
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_032 | extension — html css js |
| z2ui5_cl_demo_app_036 | extension — canvas and svg |
| z2ui5_cl_demo_app_037 | extension — custom control |
| z2ui5_cl_demo_app_040 | extension — ext library |
| z2ui5_cl_demo_app_093 | ext — call custom function |
| z2ui5_cl_demo_app_309 | follow_up_action with JS |

## Demos (full apps)
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_002 | Selection screen — explore input controls |
| z2ui5_cl_demo_app_085 | Sample app — nested view, object page, navigation, tables, lists, images |

## Charts & higher-release controls (UI5 only / version gated)
| App class | Title |
|---|---|
| z2ui5_cl_demo_app_013 | Donut chart |
| z2ui5_cl_demo_app_014 | Line chart |
| z2ui5_cl_demo_app_016 | Bar chart |
| z2ui5_cl_demo_app_312 | VizFrame charts |
| z2ui5_cl_demo_app_182 | Network graph |
| z2ui5_cl_demo_app_113 | Timeline |
| z2ui5_cl_demo_app_017 | Object page with avatar (≥1.73) |
| z2ui5_cl_demo_app_124 | Barcode scanner (≥1.102) |
| z2ui5_cl_demo_app_108 | Side panel (≥1.107) |
