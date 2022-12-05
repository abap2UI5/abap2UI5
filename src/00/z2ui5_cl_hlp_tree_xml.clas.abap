CLASS z2ui5_cl_hlp_tree_xml DEFINITION
  PUBLIC.

  PUBLIC SECTION.

    TYPES ty_o_me TYPE REF TO z2ui5_cl_hlp_tree_xml.
    TYPES ty_T_me TYPE STANDARD TABLE OF ty_o_me WITH EMPTY KEY.
    TYPES:
      BEGIN OF TY_S_attributes,
        name   TYPE string,
        value  TYPE string,
        prefix TYPE string,
      END OF ty_s_attributes.
    TYPES: ty_T_attributes TYPE STANDARD TABLE OF ty_S_attributes WITH EMPTY KEY.
    TYPES ty_t_nodes TYPE STANDARD TABLE OF REF TO z2ui5_cl_hlp_tree_xml WITH EMPTY KEY.
    DATA mv_name TYPE string.
    DATA mv_namespace TYPE string.
    DATA mt_attributes TYPE ty_t_attributes.
    CLASS-METHODS factory
      IMPORTING
        iv_xml          TYPE string optional
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_hlp_tree_xml.
    METHODS get_child_all
      RETURNING
        VALUE(r_result) TYPE ty_t_nodes.
    METHODS get_child_first
      RETURNING
        VALUE(r_result) TYPE ty_o_me.
    DATA mv_xml TYPE string.
    METHODS _writer_insert_element
      IMPORTING
        io_xml_doc    TYPE REF TO  if_ixml_document
        io_xml_parent TYPE REF TO  if_ixml_element.
    METHODS get_name
      RETURNING
        VALUE(r_result) TYPE string.
    METHODS get_attribute_all
      RETURNING
        VALUE(r_result) TYPE ty_T_attributes.
    METHODS get_attribute
      IMPORTING
        name            TYPE clike
      RETURNING
        VALUE(r_result) TYPE ty_s_attributes.
    METHODS get_namespace
      RETURNING
        VALUE(r_result) TYPE string.
    METHODS init.
    METHODS write
      RETURNING
        VALUE(r_result) TYPE string.
    METHODS set_attribute
      IMPORTING
        n TYPE string
        v TYPE string
        p TYPE string OPTIONAL.
    DATA:
      mo_document TYPE REF TO if_ixml_document,
      mo_parser   TYPE REF TO if_ixml_parser_core,
      mo_node     TYPE REF TO if_ixml_node.
  PROTECTED SECTION.
    DATA mt_child TYPE ty_T_me.
    METHODS _read_childs.
ENDCLASS.



CLASS Z2UI5_CL_HLP_TREE_XML IMPLEMENTATION.


  METHOD _writer_insert_element.


    DATA(lo_element) = io_xml_doc->create_element_ns(
         name   = mv_name "get_name( )
         prefix = mv_namespace
     ).

    io_xml_parent->append_child( lo_element  ).


    LOOP AT mt_attributes REFERENCE INTO DATA(lr_attri).
      lo_element->set_attribute_ns(
         name      = lr_attri->name
         prefix =  lr_attri->prefix
         value     = lr_attri->value
      ).
    ENDLOOP.

    LOOP AT mt_child INTO DATA(lo_child).
      lo_child->_writer_insert_element(
          io_xml_doc    = io_xml_doc
          io_xml_parent = lo_element
      ).
    ENDLOOP.


  ENDMETHOD.


  METHOD factory.



    DATA(lo_root) = NEW z2ui5_cl_hlp_tree_xml(  ).
    lo_root->mv_xml = iv_xml.

    lo_root->init( ).

    r_result = lo_root.



  ENDMETHOD.


  METHOD write.


    DATA:
      mo_document TYPE REF TO if_ixml_document,
      mo_parser   TYPE REF TO if_ixml_parser_core,
      mo_node     TYPE REF TO if_ixml_node.

* XML-Interface
    DATA(o_ixml) = cl_ixml_core=>create( ).
* XML-Doc
    mo_document  = o_ixml->create_document( ).


    DATA(lo_element) = mo_document->create_element_ns(
         name   = 'root'
*       uri    = ''
     ).

    mo_document->append_child( lo_element ).


    _writer_insert_element(
          io_xml_doc    = mo_document
          io_xml_parent = lo_element
      ).



    DATA(lo_childs) = lo_element->get_children( ).


    DATA(lo_iterator) = lo_childs->create_iterator( ).
    DO.
      DATA(lo_node) = lo_iterator->get_next( ).
      "IF lo_node IS NOT BOUND.
      EXIT.
      "  ENDIF.
      " mo_document->append_child( lo_node ).
    ENDDO.

    mo_document->replace_child( old_child = lo_element new_child = lo_node ).

    TRY.
        " DATA(o_ixml) = cl_ixml=>create( ).
        DATA(o_sf) = o_ixml->create_stream_factory( ).
        DATA(o_encoding) = o_ixml->create_encoding( character_set =  'UTF-8'
                                                    byte_order = if_ixml_encoding=>co_none ).

        DATA: lv_xml TYPE xstring.

        DATA(o_ostream) = o_sf->create_ostream_xstring( lv_xml ).
        "  o_ostream->set_encoding( encoding = o_encoding ).
        " o_ostream->set_pretty_print( pretty_print = abap_true ).
        " o_ostream->s

        DATA(o_render) = o_ixml->create_renderer( ostream  = o_ostream
                                                  document = mo_document ).

* XML-String in lv_xml generieren
        DATA(lv_rc) = o_render->render( ).

* Dateigröße in Bytes
        DATA(lv_size) = o_ostream->get_num_written_raw( ).

* Stream schließen
        " o_ostream->close( ).

        IF lv_rc = 0 AND lv_size > 0.
          " data(ret_xml_str) = lv_xml.
          "2 data(lv_line_break) = lcl_help=>conv_string_2_xstring( CL_ABAP_CHAR_UTILITIES=>NEWLINE ).
          r_result = _=>conv_xstring_2_string( lv_xml ).
          " r_result = segment( val = r_result sep = `>` index = 2 ).
          r_result = substring_after( val = r_result sub = '>' ).
          "  REPLACE all OCCURRENCES OF `"` in r_result with `'`.
        ENDIF.
      CATCH cx_root.
    ENDTRY.


  ENDMETHOD.


  METHOD get_attribute_all.



    TRY.
        DATA(lo_attri_iterator) = mo_node->get_attributes( )->create_iterator( ).

      CATCH cx_root.
        RETURN.
    ENDTRY.


    DO.
      DATA(node) = lo_attri_iterator->get_next( ).
      IF node IS INITIAL.
        EXIT.
      ENDIF.

      INSERT VALUE #(
          name   = node->get_name( )
          value  = node->get_value( )
          prefix = node->get_namespace_prefix( )
       ) INTO TABLE r_result.
    ENDDO.



  ENDMETHOD.


  METHOD get_namespace.



    r_result = mo_node->get_namespace( ).



  ENDMETHOD.


  METHOD get_child_all.


    _read_childs(  ).
    r_result = mt_child.


  ENDMETHOD.


  METHOD init.




    DATA(lv_xml) = _=>conv_string_2_xstring( mv_xml ).

* XML-Interface
    DATA(o_ixml) = cl_ixml_core=>create( ).
* XML-Doc
    mo_document  = o_ixml->create_document( ).
* Stream-Factory
    DATA(o_sf) = o_ixml->create_stream_factory( ).

* Stream
    DATA(o_stream) = o_sf->create_istream_xstring( string = lv_xml ).

* Parser-Objekt erzeugen
    mo_parser  = o_ixml->create_parser( document       = mo_document
                                       istream        = o_stream
                                       stream_factory = o_sf ).


    mo_parser->parse( ).


    mo_node = mo_document->get_root_element( ).

    mv_name = get_name(  ).
    mv_namespace = get_namespace(  ).

    mt_attributes = get_attribute_all( ).


    _read_childs( ).


*    data(lo_Node) =
*      data(lo_Node2) = mo_document->get_root( ).
*
*      data(lo_node3) = lo_node2->get_first_child(  ).
*        data(lv_test) = lo_node3->get_name(  ).
*      data(lv_val) = lo_node3->get_value(  ).
    " mo_node->get



  ENDMETHOD.


  METHOD get_name.


    r_result = mo_node->get_name(  ).


  ENDMETHOD.


  METHOD get_child_first.


    _read_childs( ).
    r_result = VALUE #( mt_child[ 1 ] OPTIONAL ).


  ENDMETHOD.


  METHOD _read_childs.


    IF mt_child IS NOT INITIAL.
      RETURN.
    ENDIF.


    DATA(lo_children_iterator) = mo_node->get_children( )->create_iterator( ).

    DO.
      DATA(node2) = lo_children_iterator->get_next( ).
      IF node2 IS INITIAL.
        EXIT.
      ENDIF.

      DATA(lo_node) = NEW z2ui5_cl_hlp_tree_xml(  ).
      lo_node->mo_node = node2.
      lo_node->mo_parser = mo_parser.
      lo_node->mo_document = mo_document.
      lo_node->mv_name = lo_node->get_name(  ).
      lo_node->mv_namespace = lo_node->get_namespace(  ).
      lo_node->mt_attributes = lo_node->get_attribute_all( ).

      CHECK lo_node->mv_name NE `#text`.

      INSERT lo_node INTO TABLE mt_child.


      lo_node->_read_childs( ).
      "APPEND node->get_name( ) TO target_tab2.
      " APPEND node->get_value( ) TO target_tab.
    ENDDO.


  ENDMETHOD.


  METHOD get_attribute.


    r_result = mt_attributes[ name = name ].


  ENDMETHOD.


  METHOD set_attribute.


    DELETE mt_attributes WHERE name = n.
    INSERT VALUE #( name = n value = v prefix = p  ) INTO TABLE mt_attributes.

  ENDMETHOD.
ENDCLASS.
