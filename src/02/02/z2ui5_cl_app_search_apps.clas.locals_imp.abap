
CLASS lcl_github DEFINITION.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_app,
        name       TYPE string,
        descr      TYPE string,
        classname  TYPE string,
        check_hide TYPE abap_bool,
      END OF ty_s_app.
    TYPES ty_t_app TYPE STANDARD TABLE OF ty_s_app WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_repo,
        name              TYPE string,
        descr             TYPE string,
        author_link       TYPE string,
        author_name       TYPE string,
        check_cloud_ready TYPE abap_bool,
        min_release       TYPE string,
        link              TYPE string,
        t_app             TYPE ty_t_app,
        check_installed   TYPE abap_bool,
        number_of_app     TYPE i,
      END OF ty_s_repo.
    TYPES ty_t_repo TYPE STANDARD TABLE OF ty_s_repo WITH EMPTY KEY.

    METHODS get_repositories
      RETURNING
        VALUE(result) TYPE ty_t_repo.

ENDCLASS.

CLASS lcl_github IMPLEMENTATION.

  METHOD get_repositories.

    result = VALUE #(
        (
        name              = `Table Loader`
        descr             = `Upload, Edit & Download Table Content (CSV, JSON)`
        author_link       = `https://github.com/oblomov-dev`
        check_cloud_ready = abap_true
        min_release       = `750`
        link              = `https://github.com/oblomov-dev/a2UI5-db_table_loader`
        t_app             = VALUE #(
          (
            name      = `Upload JSON`
            descr     = `Modify DB Table with JSON Data`
            classname = `z2ui5_dbl_cl_app_01`
          )
          (
            name      = `Download (CSV, JSON)`
            descr     = `Download DB Table as JSON and CSV`
            classname = `z2ui5_dbl_cl_app_01`
          )
        ) )
         (
        name              = `Axage`
        descr             = `Play the Game Axage`
        author_link       = `https://github.com/oblomov-dev`
        check_cloud_ready = abap_true
        min_release       = `750`
        link              = `https://github.com/oblomov-dev/a2UI5-db_table_loader`
        t_app             = VALUE #(
          (
            name      = `Upload JSON`
            descr     = `Modify DB Table with JSON Data`
            classname = `z2ui5_dbl_cl_app_01`
          )
          (
            name      = `Download (CSV, JSON)`
            descr     = `Download DB Table as JSON and CSV`
            classname = `z2ui5_dbl_cl_app_01`
          )
        ) )
                 (
        name              = `Advent of Code`
        descr             = `Solve the Advent of Code `
        author_link       = `https://github.com/oblomov-dev`
        check_cloud_ready = abap_true
        min_release       = `750`
        link              = `https://github.com/oblomov-dev/a2UI5-db_table_loader`
        t_app             = VALUE #(
          (
            name      = `Upload JSON`
            descr     = `Modify DB Table with JSON Data`
            classname = `z2ui5_dbl_cl_app_01`
          )
          (
            name      = `Download (CSV, JSON)`
            descr     = `Download DB Table as JSON and CSV`
            classname = `z2ui5_dbl_cl_app_01`
          )
        ) ) ).


    LOOP AT result REFERENCE INTO DATA(lr_repo).

      LOOP AT lr_repo->t_app REFERENCE INTO DATA(lr_app).

        IF z2ui5_cl_util_func=>rtti_check_class_exists( lr_app->classname ).
          lr_repo->check_installed = abap_true.
        ENDIF.
        EXIT.
      ENDLOOP.

      lr_repo->number_of_app = lines( lr_repo->t_app ).
      lr_repo->author_name = shift_left( val = lr_repo->author_link
                                         sub = `https://github.com/` ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
