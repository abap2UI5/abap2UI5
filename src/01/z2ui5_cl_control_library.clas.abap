CLASS z2ui5_cl_control_library DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_view_parser.
    CONSTANTS:
      BEGIN OF cs,
        BEGIN OF input,
          BEGIN OF type,
            password TYPE string VALUE 'Password',
            email    TYPE string VALUE 'Email',
            telefon  TYPE string VALUE 'Tel',
            number   TYPE string VALUE 'Number',
            url      TYPE string VALUE 'Url',
          END OF type,
          BEGIN OF value_state,
            warning     TYPE string VALUE 'Warning',
            success     TYPE string VALUE 'Success',
            error       TYPE string VALUE 'Error',
            information TYPE string VALUE 'Information',
          END OF value_state,
        END OF input,
        BEGIN OF button,
          BEGIN OF type,
            reject     TYPE string VALUE 'Reject',
            success    TYPE string VALUE 'Success',
            emphasized TYPE string VALUE 'Emphasized',
          END OF type,
        END OF button,
        BEGIN OF message_strip,
          BEGIN OF type,
            error       TYPE string VALUE 'Error',
            warning     TYPE string VALUE 'Warning',
            success     TYPE string VALUE 'Success',
            information TYPE string VALUE 'Information',
          END OF type,
        END OF message_strip,
        BEGIN OF message_box,
          BEGIN OF type,
            error   TYPE string VALUE 'error',
            alert   TYPE string VALUE 'alert',
            info    TYPE string VALUE 'information',
            warning TYPE string VALUE 'warning',
            success TYPE string VALUE 'success',
          END OF type,
        END OF message_box,
        BEGIN OF code_editor,
        "The type of the code in the editor used for syntax highlighting. Possible types are: abap, abc, actionscript, ada, apache_conf, applescript, asciidoc, assembly_x86, autohotkey, batchfile, bro, c9search, c_cpp, cirru, clojure, cobol, coffee, coldf
 "usion, csharp, css, curly, d, dart, diff, django, dockerfile, dot, drools, eiffel, ejs, elixir, elm, erlang, forth, fortran, ftl, gcode, gherkin, gitignore, glsl, gobstones, golang, groovy, haml, handlebars, haskell, haskell_cabal, haxe, hjson, html, ht
 "ml_elixir, html_ruby, ini, io, jack, jade, java, javascript, json, jsoniq, jsp, jsx, julia, kotlin, latex, lean, less, liquid, lisp, live_script, livescript, logiql, lsl, lua, luapage, lucene, makefile, markdown, mask, matlab, mavens_mate_log, maze, mel
 ", mips_assembler, mipsassembler, mushcode, mysql, nix, nsis, objectivec, ocaml, pascal, perl, pgsql, php, plain_text, powershell, praat, prolog, properties, protobuf, python, r, razor, rdoc, rhtml, rst, ruby, rust, sass, scad, scala, scheme, scss, sh, s
 "js, smarty, snippets, soy_template, space, sql, sqlserver, stylus, svg, swift, swig, tcl, tex, text, textile, toml, tsx, twig, typescript, vala, vbscript, velocity, verilog, vhdl, wollok, xml, xquery, yaml, terraform, slim, redshift, red, puppet, php_la
          "ravel_blade, mixal, jssm, fsharp, edifact, csp, cssound_score, cssound_orchestra, cssound_document
          BEGIN OF type,
            abap       TYPE string VALUE 'abap',
            json       TYPE string VALUE 'json',
            xml        TYPE string VALUE 'xml',
            yaml       TYPE string VALUE 'yaml',
            css        TYPE string VALUE 'css',
            javascript TYPE string VALUE 'javascript',
          END OF type,
        END OF code_editor,
        BEGIN OF switch,
          BEGIN OF type,
            accept_reject TYPE string VALUE 'AcceptReject',
            Default       TYPE string VALUE 'Default',
          END OF type,
        END OF switch,
        BEGIN OF progress_indicator,
          BEGIN OF state,
            error       TYPE string VALUE 'Error',
            warning     TYPE string VALUE 'Warning',
            success     TYPE string VALUE 'Success',
            information TYPE string VALUE 'Information',
            none        TYPE string VALUE 'None',
          END OF state,
        END OF progress_indicator,
      END OF cs.

    TYPES:
      BEGIN OF ty,
        BEGIN OF _,
          BEGIN OF s_suggestion_items,
            value TYPE string,
            descr TYPE string,
          END OF s_suggestion_items,
          BEGIN OF s_combobox,
            key  TYPE string,
            text TYPE string,
          END OF s_combobox,
          BEGIN OF s_seg_btn,
            key  TYPE string,
            icon TYPE string,
            text TYPE string,
          END OF s_seg_btn,
        END OF _,
        BEGIN OF input,
          t_suggestions TYPE STANDARD TABLE OF ty-_-s_suggestion_items WITH EMPTY KEY,
        END OF input,
        BEGIN OF combobox,
          t_item TYPE STANDARD TABLE OF ty-_-s_combobox WITH EMPTY KEY,
        END OF combobox,
        BEGIN OF radiobutton_group,
          BEGIN OF s_prop,
            selected TYPE abap_bool,
            text     TYPE string,
          END OF s_prop,
          t_prop TYPE string_table,
        END OF radiobutton_group,
        BEGIN OF segemented_button,
          t_button TYPE STANDARD TABLE OF ty-_-s_seg_btn WITH EMPTY KEY,
          BEGIN OF s_tab,
            text     TYPE string,
            icon     TYPE string,
            selected TYPE abap_bool,
          END OF s_tab,
          tr_btn   TYPE STANDARD TABLE OF ty-segemented_button-s_tab WITH EMPTY KEY,
        END OF segemented_button,
        test    TYPE string,
        t_radio TYPE STANDARD TABLE OF ty-test WITH EMPTY KEY,
      END OF ty.

    DATA name TYPE string.
    DATA ns   TYPE string.
    DATA t_prop TYPE STANDARD TABLE OF z2ui5_cl_hlp_utility=>ty_property WITH EMPTY KEY.


    DATA root    TYPE REF TO z2ui5_cl_control_library.
    DATA parent  TYPE REF TO z2ui5_cl_control_library.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_cl_control_library WITH EMPTY KEY.

    DATA config TYPE REF TO z2ui5_if_config.

    CLASS-METHODS factory
      " IMPORTING
      "   config        TYPE REF TO z2ui5_if_config
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add
      IMPORTING
        name          TYPE string
        ns            TYPE string OPTIONAL
        t_prop        LIKE t_prop OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_input
      IMPORTING
        value            TYPE clike OPTIONAL
        placeholder      TYPE clike OPTIONAL
        type             TYPE clike OPTIONAL
        show_clear_icon  TYPE abap_bool DEFAULT abap_false
        value_state      TYPE clike OPTIONAL
        value_state_text TYPE clike OPTIONAL
        description      TYPE clike OPTIONAL
        editable         TYPE abap_bool DEFAULT abap_true
        suggestion_items TYPE ty-input-t_suggestions OPTIONAL
        showSuggestion   TYPE abap_bool DEFAULT abap_true
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_control_library.

    METHODS add_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        on_press_id   TYPE clike
        type          TYPE clike OPTIONAL
        enabled       TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_page
      IMPORTING
        title             TYPE string OPTIONAL
        event_nav_back_id TYPE string OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_control_library.

    METHODS add_vbox
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_simple_form
      IMPORTING
        title         TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS xml_get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS xml_get_begin
      RETURNING
        VALUE(result) TYPE string.

    METHODS xml_get_end
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_control_library IMPLEMENTATION.

  METHOD xml_get_begin.

    result = `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
               `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                         ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` &&
                  COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `<Shell>` ).

  ENDMETHOD.

  METHOD xml_get_end.

    result &&= COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `</Shell>` ) && `</mvc:View>`.

  ENDMETHOD.

  METHOD xml_get.

    "case - root
    IF me = root.
      result = xml_get_begin( ).

      LOOP AT t_child INTO DATA(lr_child).
        result &&= lr_child->xml_get(  ).
      ENDLOOP.

      result &&= xml_get_end( ).
      RETURN.
    ENDIF.

    "case - normal
    CASE name.

      WHEN 'ZZHTML'.
        result = t_prop[ n = 'VALUE' ]-v.
        RETURN.
    ENDCASE.

    result = |{ result } <{ COND #( WHEN ns <> '' THEN |{ ns }:| ) }{ name } \n {
                         REDUCE #( INIT val = `` FOR row IN  t_prop where ( v <> '' )
                          NEXT val = |{ val } { row-n }="{ escape( val = row-v  format = cl_abap_format=>e_xml_attr ) }" \n | ) }|.

    IF t_child IS INITIAL.
      result &&= '/>'.
      RETURN.
    ENDIF.

    result &&= '>'.

    LOOP AT t_child INTO lr_child.
      result &&= lr_child->xml_get(  ).
    ENDLOOP.

    result &&= |</{ COND #( WHEN ns <> '' THEN |{ ns }:| ) }{ name }>|.

  ENDMETHOD.

  METHOD add.

    result = NEW z2ui5_cl_control_library( ).
    result->name = name.
    result->ns = ns.
    result->t_prop = t_prop.
    result->parent = me.
    result->root   = root.
    result->config = config.

    INSERT result INTO TABLE t_child.

  ENDMETHOD.

  METHOD factory.

    result = NEW z2ui5_cl_control_library( ).
    result->root = result.
    result->parent = result.

  ENDMETHOD.

  METHOD add_button.

    result = me.

    add(
       name   = 'Button'
       t_prop = VALUE #(
          ( n = 'press'   v = config->get_event_method( `{ 'ID' : '` && on_press_id && `' }` ) )
          ( n = 'text'    v = text )
          ( n = 'enabled' v = _=>get_abap_2_json( enabled ) )
          ( n = 'icon'    v = icon )
          ( COND #( WHEN type IS NOT INITIAL THEN VALUE #( n = 'type'  v = type ) ) )
       ) ).

  ENDMETHOD.

  METHOD add_input.

    result = me.

    DATA(lr_input) = add(
        name   = 'Input'
        t_prop = VALUE #(
            ( n = 'placeholder'    v = placeholder )
            ( n = 'type'           v = type )
            ( n = 'showClearIcon'  v = _=>get_abap_2_json( show_clear_icon ) )
            ( n = 'description'    v = description )
            ( n = 'editable'       v = _=>get_abap_2_json( editable ) )
            ( n = 'valueState'     v = value_state )
            ( n = 'valueStateText' v = value_state_text )
            ( n = 'value'          v = COND #( WHEN editable = abap_false THEN value
                                                  ELSE  '{' && config->get_attr_name_by_ref( value ) && '}' ) )
                          ) ).

    IF suggestion_items IS NOT INITIAL.

      DATA(lv_id) = _=>get_uuid_session( ).
      lr_input->t_prop = VALUE #( BASE lr_input->t_prop
        ( n = 'suggestionItems' v = '{/' && lv_id && '}' )
        ( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )
        ).

      " ??????
      config->mo_view_model->add_attribute(
           n = lv_id
           v = _=>trans_any_2_json( suggestion_items  )
        apos_active = abap_false
      ).

      lr_input->add( |suggestionItems|
             )->add(
                 name   = 'ListItem'
                 ns     = 'core'
                 t_prop = VALUE #(
                        ( n = 'text' v = '{VALUE}' )
                        ( n = 'additionalText' v = '{DESCR}' ) ) ).

    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_view_parser~get_view.

    result = root->xml_get( ).

  ENDMETHOD.

  METHOD add_page.

    DATA(lo_page) = add(
        name   = 'Page'
         t_prop = VALUE #(
             ( n = 'title' v = title )
             ( n = 'showNavButton' v = COND #( WHEN event_nav_back_id = '' THEN 'false' ELSE 'true' ) )
             ( n = 'navButtonTap' v = config->get_event_method( event_nav_back_id ) )
     ) ).

    result = lo_page->add( 'content').

  ENDMETHOD.

  METHOD add_vbox.

    result = add(
         name   = 'VBox'
         t_prop = VALUE #( ( n = 'class' v = 'sapUiSmallMargin' ) )
     ).

  ENDMETHOD.

  METHOD add_simple_form.

    DATA(lo_form) = add(
      name   = 'SimpleForm'
      ns     = 'f'
      t_prop = VALUE #(
        ( n = 'title' v = title )
        ( n = 'editable' v = 'true' )
        ( n = 'layout' v = 'ResponsiveGridLayout' )
        ( n = 'labelSpanXL' v = '4' )
        ( n = 'labelSpanL' v = '3' )
        ( n = 'labelSpanM' v = '4' )
        ( n = 'labelSpanS' v = '12' )
        ( n = 'emptySpanXL' v = '0' )
        ( n = 'emptySpanL' v = '4' )
        ( n = 'emptySpanM' v = '0' )
        ( n = 'emptySpanS' v = '0' )
        ( n = 'columnsL' v = '1' )
        ( n = 'columnsM' v = '1' )
        ( n = 'singleContainerFullSize' v = 'false' )
        ( n = 'adjustLabelSpan' v = 'false' )
      ) ).

    result = lo_form->add(
        name   = 'content'
        ns     = 'f' ).

  ENDMETHOD.

ENDCLASS.
