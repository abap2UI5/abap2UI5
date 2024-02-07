CLASS z2ui5_cl_ui5_m DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_ui5.

  PUBLIC SECTION.
    METHODS suggestionitems
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS toolbarspacer
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS input
      IMPORTING id                            TYPE clike OPTIONAL
                value                         TYPE clike OPTIONAL
                placeholder                   TYPE clike OPTIONAL
                type                          TYPE clike OPTIONAL
                showclearicon                 TYPE clike OPTIONAL
                valuestate                    TYPE clike OPTIONAL
                valuestatetext                TYPE clike OPTIONAL
                showtablesuggestionvaluehelp  TYPE clike OPTIONAL
                description                   TYPE clike OPTIONAL
                editable                      TYPE clike OPTIONAL
                enabled                       TYPE clike OPTIONAL
                suggestionitems               TYPE clike OPTIONAL
                suggestionrows                TYPE clike OPTIONAL
                showsuggestion                TYPE clike OPTIONAL
                showvaluehelp                 TYPE clike OPTIONAL
                valuehelprequest              TYPE clike OPTIONAL
                required                      TYPE clike OPTIONAL
                suggest                       TYPE clike OPTIONAL
                class                         TYPE clike OPTIONAL
                visible                       TYPE clike OPTIONAL
                submit                        TYPE clike OPTIONAL
                valueliveupdate               TYPE clike OPTIONAL
                autocomplete                  TYPE clike OPTIONAL
                maxsuggestionwidth            TYPE clike OPTIONAL
                fieldwidth                    TYPE clike OPTIONAL
                valuehelponly                 TYPE clike OPTIONAL
                width                         TYPE clike OPTIONAL
                change                        TYPE clike OPTIONAL
                valuehelpiconsrc              TYPE clike OPTIONAL
                textformatter                 TYPE clike OPTIONAL
                textformatmode                TYPE clike OPTIONAL
                maxlength                     TYPE clike OPTIONAL
                startsuggestion               TYPE clike OPTIONAL
                enablesuggestionshighlighting TYPE clike OPTIONAL
                enabletableautopopinmode      TYPE clike OPTIONAL
                  PREFERRED PARAMETER value
      RETURNING VALUE(result)                 TYPE REF TO z2ui5_cl_ui5_m.

    METHODS page
      IMPORTING title            TYPE clike OPTIONAL
                navbuttonpress   TYPE clike OPTIONAL
                shownavbutton    TYPE clike OPTIONAL
                showheader       TYPE clike OPTIONAL
                id               TYPE clike OPTIONAL
                class            TYPE clike OPTIONAL
                backgrounddesign TYPE clike OPTIONAL
                contentonlybusy  TYPE clike OPTIONAL
                enablescrolling  TYPE clike OPTIONAL
                navbuttontooltip TYPE clike OPTIONAL
                floatingfooter   TYPE clike OPTIONAL
                showfooter       TYPE clike OPTIONAL
                showsubheader    TYPE clike OPTIONAL
                titlealignment   TYPE clike OPTIONAL
                titlelevel       TYPE clike OPTIONAL
                  PREFERRED PARAMETER title
      RETURNING VALUE(result)    TYPE REF TO z2ui5_cl_ui5_m.

    METHODS shell
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS title
      IMPORTING text          TYPE clike OPTIONAL
                wrapping      TYPE clike OPTIONAL
                level         TYPE clike OPTIONAL
                  PREFERRED PARAMETER text
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS bar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_m .


    METHODS content_middle
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_m .

    METHODS panel
      IMPORTING
        !expandable   TYPE clike OPTIONAL
        !expanded     TYPE clike OPTIONAL
        !headertext   TYPE clike OPTIONAL
        stickyheader  TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS button
      IMPORTING text             TYPE clike OPTIONAL
                icon             TYPE clike OPTIONAL
                type             TYPE clike OPTIONAL
                enabled          TYPE clike OPTIONAL
                visible          TYPE clike OPTIONAL
                press            TYPE clike OPTIONAL
                class            TYPE clike OPTIONAL
                id               TYPE clike OPTIONAL
                tooltip          TYPE clike OPTIONAL
                width            TYPE clike OPTIONAL
                iconfirst        TYPE clike OPTIONAL
                icondensityaware TYPE clike OPTIONAL
                ariahaspopup     TYPE clike OPTIONAL
                activeicon       TYPE clike OPTIONAL
                accessiblerole   TYPE clike OPTIONAL
                textdirection    TYPE clike OPTIONAL
      RETURNING VALUE(result)    TYPE REF TO z2ui5_cl_ui5_m.

    METHODS label
      IMPORTING text          TYPE clike OPTIONAL
                labelfor      TYPE clike OPTIONAL
                design        TYPE clike OPTIONAL
                displayonly   TYPE clike OPTIONAL
                required      TYPE clike OPTIONAL
                showcolon     TYPE clike OPTIONAL
                textalign     TYPE clike OPTIONAL
                textdirection TYPE clike OPTIONAL
                valign        TYPE clike OPTIONAL
                width         TYPE clike OPTIONAL
                wrapping      TYPE clike OPTIONAL
                wrappingtype  TYPE clike OPTIONAL
                id            TYPE clike OPTIONAL
                class         TYPE clike OPTIONAL
                  PREFERRED PARAMETER text
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS link
      IMPORTING text               TYPE clike OPTIONAL
                href               TYPE clike OPTIONAL
                target             TYPE clike OPTIONAL
                enabled            TYPE clike OPTIONAL
                press              TYPE clike OPTIONAL
                id                 TYPE clike OPTIONAL
                wrapping           TYPE clike OPTIONAL
                width              TYPE clike OPTIONAL
                validateurl        TYPE clike OPTIONAL
                textdirection      TYPE clike OPTIONAL
                textalign          TYPE clike OPTIONAL
                subtle             TYPE clike OPTIONAL
                rel                TYPE clike OPTIONAL
                emptyindicatormode TYPE clike OPTIONAL
                emphasized         TYPE clike OPTIONAL
                ariahaspopup       TYPE clike OPTIONAL
                accessiblerole     TYPE clike OPTIONAL
      RETURNING VALUE(result)      TYPE REF TO z2ui5_cl_ui5_m.

    METHODS headercontent
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.


    METHODS illustratedmessage
      IMPORTING
        !enableverticalresponsiveness TYPE clike OPTIONAL
        !enableformattedtext          TYPE clike OPTIONAL
        !illustrationtype             TYPE clike OPTIONAL
        !title                        TYPE clike OPTIONAL
        !description                  TYPE clike OPTIONAL
        !illustrationsize             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_ui5_m.

    METHODS messagestrip
      IMPORTING
        !text         TYPE clike OPTIONAL
        !type         TYPE clike OPTIONAL
        !showicon     TYPE clike OPTIONAL
        !class        TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS text
      IMPORTING text               TYPE clike OPTIONAL
                class              TYPE clike OPTIONAL
                emptyindicatormode TYPE clike OPTIONAL
                maxlines           TYPE clike OPTIONAL
                renderwhitespace   TYPE clike OPTIONAL
                textalign          TYPE clike OPTIONAL
                textdirection      TYPE clike OPTIONAL
                width              TYPE clike OPTIONAL
                wrapping           TYPE clike OPTIONAL
                wrappingtype       TYPE clike OPTIONAL
                id                 TYPE clike OPTIONAL
                  PREFERRED PARAMETER text
      RETURNING VALUE(result)      TYPE REF TO z2ui5_cl_ui5_m.

    METHODS layoutdata
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS items
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS flexbox
      IMPORTING class            TYPE clike OPTIONAL
                rendertype       TYPE clike OPTIONAL
                width            TYPE clike OPTIONAL
                fitcontainer     TYPE clike OPTIONAL
                height           TYPE clike OPTIONAL
                alignitems       TYPE clike OPTIONAL
                justifycontent   TYPE clike OPTIONAL
                wrap             TYPE clike OPTIONAL
                visible          TYPE clike OPTIONAL
                direction        TYPE clike OPTIONAL
                displayinline    TYPE clike OPTIONAL
                backgrounddesign TYPE clike OPTIONAL
                aligncontent     TYPE clike OPTIONAL
      RETURNING VALUE(result)    TYPE REF TO z2ui5_cl_ui5_m.

    METHODS footer
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS overflowtoolbar
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS overflowtoolbartogglebutton
      IMPORTING text          TYPE clike OPTIONAL
                icon          TYPE clike OPTIONAL
                type          TYPE clike OPTIONAL
                enabled       TYPE clike OPTIONAL
                press         TYPE clike OPTIONAL
                tooltip       TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS overflowtoolbarbutton
      IMPORTING text          TYPE clike OPTIONAL
                icon          TYPE clike OPTIONAL
                type          TYPE clike OPTIONAL
                enabled       TYPE clike OPTIONAL
                press         TYPE clike OPTIONAL
                tooltip       TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS overflowtoolbarmenubutton
      IMPORTING text          TYPE clike OPTIONAL
                icon          TYPE clike OPTIONAL
                buttonmode    TYPE clike OPTIONAL
                type          TYPE clike OPTIONAL
                enabled       TYPE clike OPTIONAL
                tooltip       TYPE clike OPTIONAL
                defaultaction TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

    METHODS additionalcontent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_m.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_m IMPLEMENTATION.

  METHOD panel.

    result = _add( n   = `Panel`
                   ns  = `sap.m`
                   t_p = VALUE #( ( n = `expandable` v = z2ui5_cl_util=>boolean_abap_2_json( expandable ) )
                                         ( n = `expanded`   v = z2ui5_cl_util=>boolean_abap_2_json( expanded ) )
                                         ( n = `stickyHeader`   v = z2ui5_cl_util=>boolean_abap_2_json( stickyheader ) )
                                         ( n = `height`   v = height )
                                         ( n = `headerText` v = headertext ) ) )->_ns_m( ).

  ENDMETHOD.

  METHOD additionalcontent.
    result = _add( ns = `sap.m`
                   n  = `additionalContent` )->_ns_m( ).
  ENDMETHOD.


  METHOD illustratedmessage.

    result = _add( ns      = `sap.m`
                    n      = `IllustratedMessage`
                       t_p = VALUE #( ( n = `enableVerticalResponsiveness` v = enableverticalresponsiveness )
                       ( n = `illustrationType`             v = illustrationtype )
                       ( n = `enableFormattedText`             v = z2ui5_cl_util=>boolean_abap_2_json( enableformattedtext ) )
                       ( n = `illustrationSize`             v = illustrationsize )
                       ( n = `description`             v = description )
                       ( n = `title`             v = title )
                       ) )->_ns_m( ).
  ENDMETHOD.


  METHOD toolbarspacer.
    result = me.
    _add( n  = `ToolbarSpacer`
          ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.

  METHOD overflowtoolbar.
    result = _add( n  = `OverflowToolbar`
                   ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.

  METHOD overflowtoolbarbutton.
    result = me.
    _add( n   = `OverflowToolbarButton`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `press`   v = press )
                         ( n = `text`    v = text )
                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                         ( n = `icon`    v = icon )
                         ( n = `type`    v = type )
                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.

  METHOD overflowtoolbarmenubutton.
    result = _add( n   = `OverflowToolbarMenuButton`
                   ns  = `sap.m`
                   t_p = VALUE #( ( n = `buttonMode` v = buttonmode )
                                  ( n = `defaultAction` v = defaultaction )
                                  ( n = `text`    v = text )
                                  ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                                  ( n = `icon`    v = icon )
                                  ( n = `type`    v = type )
                                  ( n = `tooltip` v = tooltip ) ) )->_ns_m( ).
  ENDMETHOD.

  METHOD overflowtoolbartogglebutton.
    result = me.
    _add( n   = `OverflowToolbarToggleButton`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `press`   v = press )
                         ( n = `text`    v = text )
                         ( n = `enabled` v = z2ui5_cl_util=>boolean_abap_2_json( enabled ) )
                         ( n = `icon`    v = icon )
                         ( n = `type`    v = type )
                         ( n = `tooltip` v = tooltip ) ) ).
  ENDMETHOD.

  METHOD footer.
    result = _add( ns = `sap.m`
                   n  = `footer` )->_ns_m( ).
  ENDMETHOD.

  METHOD suggestionitems.
    result = _add( ns = `sap.m`
                   n  = `suggestionItems` )->_ns_m( ).
  ENDMETHOD.

  METHOD items.
    result = _add( n  = `items`
                   ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.

  METHOD flexbox.
    result = _add( n   = `FlexBox`
                   ns  = `sap.m`
                   t_p = VALUE #( ( n = `class`  v = class )
                                  ( n = `renderType`  v = rendertype )
                                  ( n = `width`  v = width )
                                  ( n = `height`  v = height )
                                  ( n = `alignItems`  v = alignitems )
                                  ( n = `fitContainer`  v = z2ui5_cl_util=>boolean_abap_2_json( fitcontainer ) )
                                  ( n = `justifyContent`  v = justifycontent )
                                  ( n = `wrap`  v = wrap )
                                  ( n = `direction`  v = direction )
                                  ( n = `alignContent`  v = aligncontent )
                                  ( n = `backgroundDesign`  v = backgrounddesign )
                                  ( n = `displayInline`  v = z2ui5_cl_util=>boolean_abap_2_json( displayinline ) )
                                  ( n = `visible`  v = visible ) ) )->_ns_m( ).
  ENDMETHOD.

  METHOD messagestrip.
    result = me.
    _add( n       = `MessageStrip`
          ns      = `sap.m`
              t_p = VALUE #( ( n = `text`     v = text )
                                ( n = `type`     v = type )
                                ( n = `showIcon` v = z2ui5_cl_util=>boolean_abap_2_json( showicon ) )
                                ( n = `class`    v = class ) ) ).
  ENDMETHOD.

  METHOD text.
    result = me.
    _add( n   = `Text`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `text`  v = text )
                         ( n = `emptyIndicatorMode`  v = emptyindicatormode )
                         ( n = `maxLines`  v = maxlines )
                         ( n = `renderWhitespace`  v = renderwhitespace )
                         ( n = `textAlign`  v = textalign )
                         ( n = `textDirection`  v = textdirection )
                         ( n = `width`  v = width )
                         ( n = `id`  v = id )
                         ( n = `wrapping`  v = z2ui5_cl_util=>boolean_abap_2_json( wrapping ) )
                         ( n = `wrappingType`  v = wrappingtype )
                         ( n = `class` v = class ) ) ).
  ENDMETHOD.

  METHOD headercontent.
    result = _add( n  = `headerContent`
                   ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.

  METHOD link.
    result = me.

    _add( n   = `Link`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `text`    v = text )
                         ( n = `target`  v = target )
                         ( n = `href`    v = href )
                         ( n = `press`   v = press )
                         ( n = `id`      v = id )
                         ( n = `accessibleRole`      v = accessiblerole )
                         ( n = `ariaHasPopup`      v = ariahaspopup )
                         ( n = `emptyIndicatorMode`      v = emptyindicatormode )
                         ( n = `rel`      v = rel )
                         ( n = `subtle`      v = _2bool( subtle ) )
                         ( n = `textAlign`      v = textalign )
                         ( n = `textDirection`      v = textdirection )
                         ( n = `validateUrl`      v = _2bool( validateurl ) )
                         ( n = `width`      v = width )
                         ( n = `wrapping`      v = _2bool( wrapping ) )
                         ( n = `emphasized`      v = _2bool( emphasized ) )
                         ( n = `enabled` v = _2bool( enabled ) ) ) ).
  ENDMETHOD.

  METHOD button.
    result = me.
    _add( n   = `Button`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `press`   v = press )
                         ( n = `text`    v = text )
                         ( n = `enabled` v = _2bool( enabled ) )
                         ( n = `visible` v = _2bool( visible ) )
                         ( n = `iconDensityAware` v = _2bool( icondensityaware ) )
                         ( n = `iconFirst` v = _2bool( iconfirst ) )
                         ( n = `icon`    v = icon )
                         ( n = `type`    v = type )
                         ( n = `id`      v = id )
                         ( n = `width`   v = width )
                         ( n = `tooltip` v = tooltip )
                         ( n = `textDirection` v = textdirection )
                         ( n = `accessibleRole` v = accessiblerole )
                         ( n = `activeIcon` v = activeicon )
                         ( n = `ariaHasPopup` v = ariahaspopup )
                         ( n = `class`   v = class ) ) ).
  ENDMETHOD.

  METHOD layoutdata.
    result = _add( n  = `layoutData`
                   ns = `sap.m`
                       )->_ns_m( ).
  ENDMETHOD.

  METHOD label.
    result = me.
    _add( n   = `Label`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `text`           v = text )
                         ( n = `displayOnly`    v = _2bool( displayonly ) )
                         ( n = `required`       v = _2bool( required ) )
                         ( n = `showColon`      v = _2bool( showcolon ) )
                         ( n = `textAlign`      v = textalign )
                         ( n = `textDirection`  v = textdirection )
                         ( n = `vAlign`         v = valign )
                         ( n = `width`          v = width )
                         ( n = `wrapping`       v = _2bool( wrapping ) )
                         ( n = `wrappingType`   v = wrappingtype )
                         ( n = `design`         v = design )
                         ( n = `id`             v = id )
                         ( n = `class`          v = class )
                         ( n = `labelFor`       v = labelfor ) ) ).
  ENDMETHOD.

  METHOD title.
    result = me.
    _add( n   = `Title`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `text`     v = text )
                         ( n = `wrapping` v = _2bool( wrapping ) )
                         ( n = `level`    v = level ) ) ).
  ENDMETHOD.

  METHOD page.
    result = _add( n   = `Page`
                   ns  = `sap.m`
                   t_p = VALUE #( ( n = `title`            v = title )
                                  ( n = `showNavButton`    v = _2bool( shownavbutton ) )
                                  ( n = `navButtonPress`   v = navbuttonpress )
                                  ( n = `showHeader`       v = _2bool( showheader ) )
                                  ( n = `class`            v = class )
                                  ( n = `backgroundDesign` v = backgrounddesign )
                                  ( n = `navButtonTooltip` v = navbuttontooltip )
                                  ( n = `titleAlignment`   v = titlealignment )
                                  ( n = `titleLevel`       v = titlelevel )
                                  ( n = `contentOnlyBusy`  v = _2bool( contentonlybusy ) )
                                  ( n = `enableScrolling`  v = _2bool( enablescrolling ) )
                                  ( n = `floatingFooter`   v = _2bool( floatingfooter ) )
                                  ( n = `showFooter`       v = _2bool( showfooter ) )
                                  ( n = `showSubHeader`    v = _2bool( showsubheader ) )
                                  ( n = `id`               v = id ) ) )->_ns_m( ).
  ENDMETHOD.

  METHOD shell.
    result = _add( n  = `Shell`
                   ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.

  METHOD bar.
    result = _add( n  = `Bar`
                   ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.

  METHOD content_middle.
    result = _add( n  = `contentMiddle`
                   ns = `sap.m` )->_ns_m( ).
  ENDMETHOD.


  METHOD input.
    result = me.
    _add( n   = `Input`
          ns  = `sap.m`
          t_p = VALUE #( ( n = `id`                       v = id )
                         ( n = `placeholder`              v = placeholder )
                         ( n = `type`                     v = type )
                         ( n = `maxLength`                v = maxlength )
                         ( n = `showClearIcon`            v = _2bool( showclearicon ) )
                         ( n = `description`              v = description )
                         ( n = `editable`                 v = _2bool( editable ) )
                         ( n = `enabled`                  v = _2bool( enabled ) )
                         ( n = `visible`                  v = _2bool( visible ) )
                         ( n = `enableTableAutoPopinMode` v = _2bool( enabletableautopopinmode ) )
                         ( n = `enableSuggestionsHighlighting`  v = _2bool( enablesuggestionshighlighting ) )
                         ( n = `showTableSuggestionValueHelp`   v = _2bool( showtablesuggestionvaluehelp ) )
                         ( n = `valueState`               v = valuestate )
                         ( n = `valueStateText`           v = valuestatetext )
                         ( n = `value`                    v = value )
                         ( n = `required`                 v = _2bool( required ) )
                         ( n = `suggest`                  v = suggest )
                         ( n = `suggestionItems`          v = suggestionitems )
                         ( n = `suggestionRows`           v = suggestionrows )
                         ( n = `showSuggestion`           v = _2bool( showsuggestion ) )
                         ( n = `valueHelpRequest`         v = valuehelprequest )
                         ( n = `autocomplete`             v = _2bool( autocomplete ) )
                         ( n = `valueLiveUpdate`  v = _2bool( valueliveupdate ) )
                         ( n = `submit`           v = _2bool( submit ) )
                         ( n = `showValueHelp`    v = _2bool( showvaluehelp ) )
                         ( n = `valueHelpOnly`    v = _2bool( valuehelponly ) )
                         ( n = `class`            v = class )
                         ( n = `change`            v = change )
                         ( n = `maxSuggestionWidth` v = maxsuggestionwidth )
                         ( n = `width`             v = width )
                         ( n = `textFormatter`     v = textformatter )
                         ( n = `startSuggestion`     v = startsuggestion )
                         ( n = `valueHelpIconSrc` v = valuehelpiconsrc )
                         ( n = `textFormatMode`  v = textformatmode )
                         ( n = `fieldWidth`          v = fieldwidth ) ) ).
  ENDMETHOD.
ENDCLASS.
