CLASS z2ui5_cl_core_srv_msg DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! Build the CONTROL_GLOBAL argument list that displays a message toast:
    "! `MESSAGE_TOAST`, `show`, the text, and the options object. Only the
    "! options the app actually set end up in that object, and when it would
    "! be empty it is left off entirely - the control then applies its own
    "! defaults for everything.
    METHODS get_toast_arg
      IMPORTING
        text                     TYPE clike
        duration                 TYPE clike     OPTIONAL
        width                    TYPE clike     OPTIONAL
        my                       TYPE clike     OPTIONAL
        at                       TYPE clike     OPTIONAL
        of                       TYPE clike     OPTIONAL
        offset                   TYPE clike     OPTIONAL
        collision                TYPE clike     OPTIONAL
        onclose                  TYPE clike     OPTIONAL
        autoclose                TYPE abap_bool DEFAULT abap_true
        animationtimingfunction  TYPE clike     OPTIONAL
        animationduration        TYPE clike     OPTIONAL
        closeonbrowsernavigation TYPE abap_bool DEFAULT abap_true
        class                    TYPE clike     OPTIONAL
      RETURNING
        VALUE(result)            TYPE string_table.

    "! The same for a message box: `MESSAGE_BOX`, the box type - which is the
    "! MessageBox display method the global call invokes - the text, and the
    "! options object. text is TYPE any: a message table ( BAPIRET2 and
    "! friends ) is run through the formatter first. An EMPTY result means
    "! the formatter found nothing worth showing.
    METHODS get_box_arg
      IMPORTING
        text              TYPE any
        type              TYPE clike        DEFAULT `information`
        title             TYPE clike        OPTIONAL
        styleclass        TYPE clike        OPTIONAL
        onclose           TYPE clike        OPTIONAL
        actions           TYPE string_table OPTIONAL
        emphasizedaction  TYPE clike        OPTIONAL
        initialfocus      TYPE clike        OPTIONAL
        textdirection     TYPE clike        OPTIONAL
        icon              TYPE clike        OPTIONAL
        details           TYPE clike        OPTIONAL
        closeonnavigation TYPE abap_bool    DEFAULT abap_true
        dependenton       TYPE clike        OPTIONAL
        contentwidth      TYPE clike        OPTIONAL
      RETURNING
        VALUE(result)     TYPE string_table.

  PROTECTED SECTION.
  PRIVATE SECTION.

    "! The sap.m.MessageBox display methods, i.e. the box types the
    "! whitelisted global call accepts.
    CLASS-DATA ct_box_type TYPE string_table.

    CLASS-METHODS class_constructor.

    "! Resolve what the message box actually shows. The result carries the
    "! MessageBox display method in `type`, lowercased and guaranteed to be
    "! one of ct_box_type.
    METHODS box_resolve
      IMPORTING
        text          TYPE any
        type          TYPE clike
        title         TYPE clike
        details       TYPE clike
      RETURNING
        VALUE(result) TYPE z2ui5_cl_a2ui5_context=>ty_s_msg_box.

    "! Append the options object to the argument list - unless the app set no
    "! option at all, in which case there is nothing to send and the frontend
    "! applies the control's own defaults for everything.
    METHODS append_opt
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        arg  TYPE REF TO string_table
      RAISING
        z2ui5_cx_ajson_error.

    "! Add an option to the payload, but only when the app set it - an option
    "! that is absent lets the control apply its own default.
    METHODS set_opt_string
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

    METHODS set_opt_int
      IMPORTING
        json TYPE REF TO z2ui5_if_ajson
        name TYPE string
        val  TYPE clike
      RAISING
        z2ui5_cx_ajson_error.

ENDCLASS.


CLASS z2ui5_cl_core_srv_msg IMPLEMENTATION.


  METHOD class_constructor.

    ct_box_type = VALUE #( ( `show` )
                           ( `alert` )
                           ( `confirm` )
                           ( `information` )
                           ( `warning` )
                           ( `error` )
                           ( `success` ) ).

  ENDMETHOD.


  METHOD get_toast_arg.

    TRY.
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        " Only what the app actually set travels. sap.m.MessageToast owns a
        " default for every option, and it applies its vertical lift ONLY
        " while none of my/at/of/offset is passed ( its hasDefaultPosition
        " check ) - so mirroring a UI5 default here would both suppress that
        " lift and silently freeze the value if UI5 ever changes it.
        set_opt_int( json = li_opt
                     name = `duration`
                     val  = duration ).
        set_opt_int( json = li_opt
                     name = `animationDuration`
                     val  = animationduration ).
        set_opt_string( json = li_opt
                        name = `width`
                        val  = width ).
        set_opt_string( json = li_opt
                        name = `my`
                        val  = my ).
        set_opt_string( json = li_opt
                        name = `at`
                        val  = at ).
        set_opt_string( json = li_opt
                        name = `of`
                        val  = of ).
        set_opt_string( json = li_opt
                        name = `offset`
                        val  = offset ).
        set_opt_string( json = li_opt
                        name = `collision`
                        val  = collision ).
        set_opt_string( json = li_opt
                        name = `onClose`
                        val  = onclose ).
        set_opt_string( json = li_opt
                        name = `animationTimingFunction`
                        val  = animationtimingfunction ).
        " not a MessageToast option - the frontend puts the classes on the
        " DOM node of the toast, which carries no id to address it by
        set_opt_string( json = li_opt
                        name = `class`
                        val  = class ).

        " abap_true is UI5's own default for both, so only the opt-out is
        " worth sending
        IF autoclose = abap_false.
          li_opt->set_boolean( iv_path = `/autoClose`
                               iv_val  = abap_false ).
        ENDIF.
        IF closeonbrowsernavigation = abap_false.
          li_opt->set_boolean( iv_path = `/closeOnBrowserNavigation`
                               iv_val  = abap_false ).
        ENDIF.

        " sap.m.MessageToast is a global object, so the toast rides the
        " generic whitelisted global call
        result = VALUE #( ( `MESSAGE_TOAST` )
                          ( `show` )
                          ( CONV string( text ) ) ).
        append_opt( json = li_opt
                    arg  = REF #( result ) ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |MESSAGE_TOAST_OPTIONS_INVALID - { lx_json->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.


  METHOD get_box_arg.

    DATA(ls_msg) = box_resolve( text    = text
                                type    = type
                                title   = title
                                details = details ).
    IF ls_msg-skip = abap_true.
      RETURN.
    ENDIF.

    TRY.
        DATA(li_opt) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).

        " only what the app actually set travels - every MessageBox method
        " carries its OWN defaults ( confirm's [OK, CANCEL], error's [CLOSE],
        " the emphasized action derived from them ), so sending a value for an
        " option the app left alone would override those
        set_opt_string( json = li_opt
                        name = `title`
                        val  = ls_msg-title ).
        set_opt_string( json = li_opt
                        name = `styleClass`
                        val  = styleclass ).
        set_opt_string( json = li_opt
                        name = `onClose`
                        val  = onclose ).
        set_opt_string( json = li_opt
                        name = `emphasizedAction`
                        val  = emphasizedaction ).
        set_opt_string( json = li_opt
                        name = `initialFocus`
                        val  = initialfocus ).
        set_opt_string( json = li_opt
                        name = `textDirection`
                        val  = textdirection ).
        set_opt_string( json = li_opt
                        name = `details`
                        val  = ls_msg-details ).
        set_opt_string( json = li_opt
                        name = `dependentOn`
                        val  = dependenton ).
        set_opt_string( json = li_opt
                        name = `contentWidth`
                        val  = contentwidth ).

        " MessageBox.Icon.NONE is a valid UI5 value, but passing it would
        " defeat the icon the chosen method sets for itself ( error -> the
        " error icon ), so it is dropped like an unset icon
        IF icon <> `NONE`.
          set_opt_string( json = li_opt
                          name = `icon`
                          val  = icon ).
        ENDIF.

        IF actions IS NOT INITIAL.
          li_opt->touch_array( `/actions` ).
          LOOP AT actions INTO DATA(lv_action).
            li_opt->push( iv_path = `/actions`
                          iv_val  = lv_action ).
          ENDLOOP.
        ENDIF.

        " abap_true is UI5's own default, so only the opt-out is worth sending
        IF closeonnavigation = abap_false.
          li_opt->set_boolean( iv_path = `/closeOnNavigation`
                               iv_val  = abap_false ).
        ENDIF.

        " sap.m.MessageBox is a global too - and its display methods are the
        " box types, so the type IS the method of the global call
        result = VALUE #( ( `MESSAGE_BOX` )
                          ( ls_msg-type )
                          ( ls_msg-text ) ).
        append_opt( json = li_opt
                    arg  = REF #( result ) ).

      CATCH z2ui5_cx_ajson_error INTO DATA(lx_json).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |MESSAGE_BOX_OPTIONS_INVALID - { lx_json->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.


  METHOD box_resolve.

    IF z2ui5_cl_a2ui5_context=>rtti_check_clike( text ) = abap_false.
      result = z2ui5_cl_a2ui5_context=>ui5_msg_box_format( text ).
      IF result-skip = abap_true.
        RETURN.
      ENDIF.
      IF title IS NOT INITIAL.
        result-title = title.
      ENDIF.
    ELSE.
      result = VALUE #( text    = text
                        type    = type
                        title   = title
                        details = details ).

      IF result-type = `information`.
        result-type = `show`.
        IF result-title IS INITIAL.
          result-title = `Information`.
        ENDIF.
      ENDIF.
    ENDIF.

    IF result-type IS INITIAL.
      result-type = `show`.
    ENDIF.

    " MessageBox display methods are lowercase (show, error, warning, ...) but
    " the type arrives capitalized from ui5_msg_box_format ( `Error` for a
    " multi-message box ) or however an app spelled it
    result-type = to_lower( result-type ).

    " the type travels as the method of the whitelisted global call, so a type
    " that is no MessageBox display method would be rejected there and the box
    " would not appear at all - a requested box is never dropped silently, it
    " falls back to a plain show( ) like the frontend used to do
    IF NOT line_exists( ct_box_type[ table_line = result-type ] ).
      result-type = `show`.
    ENDIF.

  ENDMETHOD.


  METHOD append_opt.

    DATA(lv_opt) = json->stringify( ).
    IF lv_opt IS NOT INITIAL.
      INSERT lv_opt INTO TABLE arg->*.
    ENDIF.

  ENDMETHOD.


  METHOD set_opt_string.

    " an option the app left alone must not appear in the payload at all -
    " the control's own default has to win, and an empty string is a value
    IF val IS NOT INITIAL.
      json->set_string( iv_path = |/{ name }|
                        iv_val  = val ).
    ENDIF.

  ENDMETHOD.


  METHOD set_opt_int.

    " a duration the app left alone must not appear in the payload - UI5's
    " own default has to win. A non-numeric value is dropped rather than
    " converted, so a stray string can never reach MessageToast as NaN.
    IF val IS NOT INITIAL AND val CO ` 0123456789`.
      json->set_integer( iv_path = |/{ name }|
                         iv_val  = CONV i( val ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
