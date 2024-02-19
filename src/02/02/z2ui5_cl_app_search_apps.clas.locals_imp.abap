CLASS lcl_github DEFINITION.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "
  " this file lists all github repositories using abap2UI5
  " they are displayed in the start app of abap2UI5
  "
  " your app is not listed her?
  " feel free to send a PR and extend this file
  "
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  PUBLIC SECTION.
    METHODS get_repositories
      RETURNING
        VALUE(result) TYPE z2ui5_cl_app_search_apps=>ty_t_repo.

ENDCLASS.

CLASS lcl_github IMPLEMENTATION.

  METHOD get_repositories.

    result = VALUE #(
        (
        name                 = `The Quest`
        descr                = `A wizard's adventure game based on a fork of the AXAGE game engine (ABAP teXt Adventure Game Engine) and abap2UI5.`
        check_abap_for_cloud = abap_true
        check_standard_abap  = abap_true
        link                 = `https://github.com/nomssi/axage`
        author_link          = `https://github.com/nomssi`
        author_name          = `Nomssi`
        t_app                = VALUE #(
          (
            name      = `The Quest - Start the Adventure`
            descr     = `Adventure Game: The Wizard&amp;apos;s Aspirant Quest`
            classname = `zcl_axage_wizard_ui.clas.abap`
        ) ) )
        (
        name                 = `Advent of Code`
        descr                = `Template for the Advent of Code 2023 in ABAP`
        author_link          = `https://github.com/joltdx`
        author_name          = `joltdx`
        link                 = `https://github.com/joltdx/abap-advent-2023-template`
        check_abap_for_cloud = abap_true
        check_standard_abap  = abap_true
        t_app                = VALUE #(
          (
            name      = `Advent of Code 2023 in ABAP`
            descr     = `Advent of Code 2023 - ABAP2UI5 app`
            classname = `zcl_advent_2023_a2ui5.clas.abap`
        ) ) )
        (
        name                 = `Table Loader`
        descr                = `Upload, Edit & Download Table Content (CSV, JSON)`
        author_link          = `https://github.com/oblomov-dev`
        author_name          = `oblomov`
        check_standard_abap  = abap_true
        check_abap_for_cloud = abap_true
        link                 = `https://github.com/oblomov-dev/a2UI5-db_table_loader`
        t_app                = VALUE #(
          (
            name      = `Upload JSON`
            descr     = `Modify DB Table with JSON Data`
            classname = `z2ui5_dbl_cl_app_01`
          )
          (
            name      = `Download (CSV, JSON)`
            descr     = `Download DB Table as JSON and CSV`
            classname = `z2ui5_dbl_cl_app_01`
        ) ) )
        ).

  ENDMETHOD.

ENDCLASS.
