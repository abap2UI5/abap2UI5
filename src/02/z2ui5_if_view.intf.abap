INTERFACE z2ui5_if_view PUBLIC.

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

  METHODS factory_selscreen_page
    IMPORTING
      name              TYPE string OPTIONAL
      title             TYPE string DEFAULT 'screen_title'
      event_nav_back_id TYPE string OPTIONAL
        PREFERRED PARAMETER name
    RETURNING
      VALUE(r_result)   TYPE REF TO z2ui5_if_selscreen.

ENDINTERFACE.
