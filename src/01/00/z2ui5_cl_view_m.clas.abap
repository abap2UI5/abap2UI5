CLASS z2ui5_cl_view_m DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_view.

  PUBLIC SECTION.
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
      RETURNING VALUE(result)                 TYPE REF TO z2ui5_cl_view_m.

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
      RETURNING VALUE(result)    TYPE REF TO z2ui5_cl_view_m.

    METHODS shell
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_view_m.

    METHODS title
      IMPORTING text          TYPE clike OPTIONAL
                wrapping      TYPE clike OPTIONAL
                level         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_view_m.

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
      RETURNING VALUE(result)    TYPE REF TO z2ui5_cl_view_m.

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
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_view_m.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_view_m IMPLEMENTATION.
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
    result = _add( n = `Shell`  ns = `sap.m` )->_ns_m( ).
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
