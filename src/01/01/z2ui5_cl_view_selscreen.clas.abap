CLASS z2ui5_cl_view_selscreen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_selscreen.
    INTERFACES z2ui5_if_selscreen_block.
    INTERFACES z2ui5_if_selscreen_footer.
    INTERFACES z2ui5_if_selscreen_group.

    CLASS-METHODS create
      IMPORTING
        name              type string optional
        title             TYPE string OPTIONAL
        event_nav_back_id TYPE string OPTIONAL
        view              TYPE REF TO z2ui5_if_view
     returning
        value(result)     TYPE REF TO z2ui5_if_selscreen.


    DATA mo_control TYPE REF TO z2ui5_cl_control_library.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_view_selscreen IMPLEMENTATION.

  METHOD create.

    DATA(lo_new) = NEW z2ui5_cl_view_selscreen( ).
    lo_new->mo_control = z2ui5_cl_control_library=>factory( view->get_context( ) ).

    lo_new->mo_control = lo_new->mo_control->add_page(
        title             = title
        event_nav_back_id = event_nav_back_id
     ).

    view->factory_view( name = name parser = lo_new->mo_control->root ).

    result = lo_new.

  ENDMETHOD.


  METHOD z2ui5_if_selscreen~begin_of_block.

    r_result = me.
    mo_control = mo_control->add_vbox( )->add_simple_form( title )->add_content( ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~begin_of_footer.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~begin_of_group.

    r_result = me.
    mo_control->add_title( title ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~begin_of_overflow_toolbar.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~button.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~button.

    r_result = me.

    mo_control->add_button(
        text        = text
        icon        = icon
        on_press_id = on_press_id
        type        = type
        enabled     = enabled
    ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~checkbox.

    r_result = me.

    mo_control->add_checkbox(
        text     = text
        selected = selected
    ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~code_editor.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~combobox.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~custom_control.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~date_picker.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~date_time_picker.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~end_of_block.

    r_result = me.
    mo_control = mo_control->parent->parent.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~end_of_footer.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~end_of_group.

    r_result = me.
    mo_control = mo_control->parent.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~end_of_overflow_toolbar.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~end_of_screen.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_block~html.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~input.

    r_result = me.
    mo_control->add_input(
        value            = value
        placeholder      = placeholder
        type             = type
        show_clear_icon  = show_clear_icon
        value_state      = value_state
        value_state_text = value_state_text
        description      = description
        editable         = editable
        suggestion_items = suggestion_items
        showsuggestion   = showsuggestion
    ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~label.

    r_result = me.
    mo_control->add_label( text ).

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~link.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen~message_strip.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~progress_indicator.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~radiobutton_group.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~segmented_button.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~step_input.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~switch.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~text.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~text_area.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_group~time_picker.

  ENDMETHOD.

  METHOD z2ui5_if_selscreen_footer~toolbar_spacer.

  ENDMETHOD.

ENDCLASS.
