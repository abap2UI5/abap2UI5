CLASS z2ui5_cl_view_m DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM z2ui5_cl_view.

  PUBLIC SECTION.

    METHODS input
      IMPORTING
        id                            TYPE clike OPTIONAL
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
      RETURNING
        VALUE(result)                 TYPE REF TO z2ui5_cl_view_m.

    METHODS page
      IMPORTING
        title            TYPE clike OPTIONAL
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
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_view_m.

    METHODS shell
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_m.

    METHODS title
      IMPORTING
        text          TYPE clike OPTIONAL
        wrapping      TYPE clike OPTIONAL
        level         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_m.

    METHODS button
      IMPORTING
        text             TYPE clike OPTIONAL
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
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_view_m.

    METHODS label
      IMPORTING
        text          TYPE clike OPTIONAL
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
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_view_m.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_view_m IMPLEMENTATION.
  METHOD button.
    result = me.
    add( name   = `Button`
                t_prop = VALUE #( ( n = `press`   v = press )
                                  ( n = `text`    v = text )
                                  ( n = `enabled` v = b2json( enabled ) )
                                  ( n = `visible` v = b2json( visible ) )
                                  ( n = `iconDensityAware` v = b2json( icondensityaware ) )
                                  ( n = `iconFirst` v = b2json( iconfirst ) )
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
    add( name   = `Label`
                t_prop = VALUE #( ( n = `text`           v = text )
                                  ( n = `displayOnly`    v = b2json( displayonly ) )
                                  ( n = `required`       v = b2json( required ) )
                                  ( n = `showColon`      v = b2json( showcolon ) )
                                  ( n = `textAlign`      v = textalign )
                                  ( n = `textDirection`  v = textdirection )
                                  ( n = `vAlign`         v = valign )
                                  ( n = `width`          v = width )
                                  ( n = `wrapping`       v = b2json( wrapping ) )
                                  ( n = `wrappingType`   v = wrappingtype )
                                  ( n = `design`         v = design )
                                  ( n = `id`             v = id )
                                  ( n = `class`          v = class )
                                  ( n = `labelFor`       v = labelfor ) ) ).
  ENDMETHOD.

  METHOD title.
    result = me.
    add( name   = `Title`
                t_prop = VALUE #( ( n = `text`     v = text )
                                  ( n = `wrapping` v = b2json( wrapping ) )
                                  ( n = `level`    v = level ) ) ).
  ENDMETHOD.

  METHOD page.

    result = add( name   = `Page`
                  t_prop = VALUE #( ( n = `title`            v = title )
                                    ( n = `showNavButton`    v = b2json( shownavbutton ) )
                                    ( n = `navButtonPress`   v = navbuttonpress )
                                    ( n = `showHeader`       v = b2json( showheader ) )
                                    ( n = `class`            v = class )
                                    ( n = `backgroundDesign` v = backgrounddesign )
                                    ( n = `navButtonTooltip` v = navbuttontooltip )
                                    ( n = `titleAlignment`   v = titlealignment )
                                    ( n = `titleLevel`       v = titlelevel )
                                    ( n = `contentOnlyBusy`  v = b2json( contentonlybusy ) )
                                    ( n = `enableScrolling`  v = b2json( enablescrolling ) )
                                    ( n = `floatingFooter`   v = b2json( floatingfooter ) )
                                    ( n = `showFooter`       v = b2json( showfooter ) )
                                    ( n = `showSubHeader`    v = b2json( showsubheader ) )
                                    ( n = `id`               v = id ) ) )->ns_m( ).

  ENDMETHOD.

  METHOD shell.
    result = add( `Shell` )->ns_m( ).
  ENDMETHOD.

  METHOD input.
    result = me.
    add( name   = `Input`
                t_prop = VALUE #( ( n = `id`                       v = id )
                                  ( n = `placeholder`              v = placeholder )
                                  ( n = `type`                     v = type )
                                  ( n = `maxLength`                v = maxlength )
                                  ( n = `showClearIcon`            v = b2json( showclearicon ) )
                                  ( n = `description`              v = description )
                                  ( n = `editable`                 v = b2json( editable ) )
                                  ( n = `enabled`                  v = b2json( enabled ) )
                                  ( n = `visible`                  v = b2json( visible ) )
                                  ( n = `enableTableAutoPopinMode` v = b2json( enabletableautopopinmode ) )
                                  ( n = `enableSuggestionsHighlighting`  v = b2json( enablesuggestionshighlighting ) )
                                  ( n = `showTableSuggestionValueHelp`   v = b2json( showtablesuggestionvaluehelp ) )
                                  ( n = `valueState`               v = valuestate )
                                  ( n = `valueStateText`           v = valuestatetext )
                                  ( n = `value`                    v = value )
                                  ( n = `required`                 v = b2json( required ) )
                                  ( n = `suggest`                  v = suggest )
                                  ( n = `suggestionItems`          v = suggestionitems )
                                  ( n = `suggestionRows`           v = suggestionrows )
                                  ( n = `showSuggestion`           v = b2json( showsuggestion ) )
                                  ( n = `valueHelpRequest`         v = valuehelprequest )
                                  ( n = `autocomplete`             v = b2json( autocomplete ) )
                                  ( n = `valueLiveUpdate`  v = b2json( valueliveupdate ) )
                                  ( n = `submit`           v = b2json( submit ) )
                                  ( n = `showValueHelp`    v = b2json( showvaluehelp ) )
                                  ( n = `valueHelpOnly`    v = b2json( valuehelponly ) )
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
