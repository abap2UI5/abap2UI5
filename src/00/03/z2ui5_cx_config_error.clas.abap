CLASS z2ui5_cx_config_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF config_locked,
        msgid TYPE symsgid      VALUE 'Z2UI5_CONF',
        msgno TYPE symsgno      VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF config_locked.

    CONSTANTS:
      BEGIN OF save_failed,
        msgid TYPE symsgid      VALUE 'Z2UI5_CONF',
        msgno TYPE symsgno      VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF save_failed.

    DATA config_key TYPE string READ-ONLY.
    DATA user_id    TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING textid     LIKE if_t100_message=>t100key OPTIONAL
                !previous  LIKE previous                 OPTIONAL
                config_key TYPE string                   OPTIONAL
                user_id    TYPE string                   OPTIONAL.

    CLASS-METHODS raise_config_locked
      RAISING z2ui5_cx_config_error.

    CLASS-METHODS raise_save_failed
      RAISING z2ui5_cx_config_error.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cx_config_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = previous ).
    me->config_key = config_key.
    me->user_id    = user_id.

    " Set the T100 message key
    CLEAR me->if_t100_message~t100key.
    if_t100_message~t100key = textid.
  ENDMETHOD.

  METHOD raise_config_locked.
    RAISE EXCEPTION TYPE z2ui5_cx_config_error
      EXPORTING textid = config_locked.
  ENDMETHOD.

  METHOD raise_save_failed.
    RAISE EXCEPTION TYPE z2ui5_cx_config_error
      EXPORTING textid = save_failed.
  ENDMETHOD.
ENDCLASS.
