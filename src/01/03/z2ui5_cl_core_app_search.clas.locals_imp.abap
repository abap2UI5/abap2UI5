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
        VALUE(result) TYPE z2ui5_cl_core_app_search=>ty_t_repo.

    METHODS get_repositories_addons
      RETURNING
        VALUE(result) TYPE z2ui5_cl_core_app_search=>ty_t_repo.

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
        )
        (
        name                 = `Advent of Code`
        descr                = `Template for the Advent of Code 2023 in ABAP`
        author_link          = `https://github.com/joltdx`
        author_name          = `joltdx`
        link                 = `https://github.com/joltdx/abap-advent-2023-template`
        check_abap_for_cloud = abap_true
        check_standard_abap  = abap_true
        )
        (
        name                 = `Table Loader`
        descr                = `Upload, Edit & Download Table Content (CSV, JSON)`
        author_link          = `https://github.com/oblomov-dev`
        author_name          = `oblomov`
        check_standard_abap  = abap_true
        check_abap_for_cloud = abap_false
        link                 = `https://github.com/oblomov-dev/a2UI5-db_table_loader`
        )
        (
        name                 = `Generic Search Help`
        descr                = `Popups with Search Helps, dynamically created based on imported values`
        author_link          = `https://github.com/axelmohnen`
        author_name          = `axelmohnen`
        check_standard_abap  = abap_true
        check_abap_for_cloud = abap_true
        link                 = `https://github.com/axelmohnen/a2UI5-generic_search_hlp`
        )
        (
        name                 = `ABAP SQL Console`
        descr                = `Quickly Run SQL Commands in Your Browser`
        author_link          = `https://github.com/abap2UI5-apps/abap-sql-console`
        author_name          = `oblomov`
        check_standard_abap  = abap_true
        check_abap_for_cloud = abap_true
        link                 = `https://github.com/axelmohnen/a2UI5-generic_search_hlp`
        )
        ).

  ENDMETHOD.

  METHOD get_repositories_addons.

    result = VALUE #(
            (
            name           = `Launchpad Proxy App`
            descr          = `Integrate your apps to the on-premise fiori launchpad`
            link           = `https://github.com/abap2UI5/abap2UI5-launchpad_proxy_app`
            )
            (
            name           = `BTP Proxy App`
            descr          = `Integrate your apps with Business Technology Platform & SAP Mobile Start`
            link           = `https://github.com/abap2UI5/abap2UI5-btp_proxy_app`
            )
            (
             name          = `S-RTTI`
            descr          = `Install this repository to use dynamically types variables and tables in your abap2UI5 apps`
            link           = `https://github.com/sandraros/S-RTTI`
            )
            (
             name          = `abap2UI5-web`
            descr          = `Run abap2UI5 with open-abap on Node.js`
            link           = `https://github.com/abap2UI5/abap2UI5-web`
            )
            (
             name          = `abap2UI5-samples`
            descr          = `Explore Code Samples of abap2UI5`
            link           = `https://github.com/abap2UI5/abap2UI5-samples`
            )
            ).

  ENDMETHOD.

ENDCLASS.
