"------------------------------------------------------------------------
" Helper: app with a tree-like table (rows carry a sub-table and a struct)
"------------------------------------------------------------------------
CLASS ltcl_app_tree DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_node,
        user      TYPE string,
        validated TYPE abap_bool,
      END OF ty_s_node.
    TYPES ty_t_nodes TYPE STANDARD TABLE OF ty_s_node WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_adr,
        city TYPE string,
        zip  TYPE string,
      END OF ty_s_adr.

    TYPES:
      BEGIN OF ty_s_root,
        user    TYPE string,
        enabled TYPE abap_bool,
        s_adr   TYPE ty_s_adr,
        nodes   TYPE ty_t_nodes,
      END OF ty_s_root.
    TYPES ty_t_tree TYPE STANDARD TABLE OF ty_s_root WITH EMPTY KEY.

    DATA mt_tree TYPE ty_t_tree.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_tree IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_app_typed DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_pos,
        qty TYPE i,
      END OF ty_s_pos.
    TYPES ty_t_pos TYPE STANDARD TABLE OF ty_s_pos WITH EMPTY KEY.
    " the nested shape a row delta cannot be applied to
    TYPES ty_t_pos_sorted TYPE SORTED TABLE OF ty_s_pos WITH UNIQUE KEY qty.

    " a table whose cells are NOT all strings - the only shape in which a
    " delta cell can fail to convert at all
    TYPES:
      BEGIN OF ty_s_row,
        name     TYPE string,
        price    TYPE p LENGTH 9 DECIMALS 2,
        t_pos    TYPE ty_t_pos,
        t_sorted TYPE ty_t_pos_sorted,
        " the three kinds whose wire form is ISO text, not their ABAP form
        dt       TYPE d,
        tm       TYPE t,
        ts       TYPE timestamp,
      END OF ty_s_row.
    TYPES ty_t_tab TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    " the one table shape a row delta cannot be applied to
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_row WITH UNIQUE KEY name.

    DATA mt_tab TYPE ty_t_tab.
    DATA mt_sorted TYPE ty_t_sorted.
ENDCLASS.


CLASS ltcl_app_typed IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" The shape catalogue: one attribute per FORM an app attribute can take, and
" the same invariants run over every row of mt_attri after every lifecycle
" step. A new form is one more attribute here - every test below picks it
" up. The forms and the numbering follow the test plan (S01-S30).
" ---------------------------------------------------------------------------

" a class that does NOT implement if_serializable_object: the view builder,
" the client, any helper an app keeps in an attribute. It must come back
" initial from the draft - and it must not fail the draft (S15)
CLASS ltcl_shp_dead DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    DATA mv_text TYPE string.
ENDCLASS.

CLASS ltcl_shp_dead IMPLEMENTATION.
ENDCLASS.


" a serializable helper instance with data of its own, a dref that points at
" the OUTER app's anonymous table (sample 339: mo_layout->mr_data) and a
" chain to another instance of itself (S12, S14, S18)
CLASS ltcl_shp_inner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mv_inner  TYPE string.
    DATA mt_own    TYPE ty_t_row.
    DATA mr_shared TYPE REF TO data.
    DATA mo_deeper TYPE REF TO ltcl_shp_inner.
ENDCLASS.

CLASS ltcl_shp_inner IMPLEMENTATION.
ENDCLASS.


CLASS ltcl_app_shapes DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row    TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    TYPES ty_t_sorted TYPE SORTED TABLE OF ty_s_row WITH UNIQUE KEY col1.
    " the shape of the runtime-built line: a known row plus SELKZ
    TYPES:
      BEGIN OF ty_s_row_sel,
        col1  TYPE string,
        col2  TYPE i,
        selkz TYPE abap_bool,
      END OF ty_s_row_sel.

    TYPES:
      BEGIN OF ty_s_deep,
        v1 TYPE string,
        BEGIN OF l1,
          v2 TYPE string,
          BEGIN OF l2,
            v3 TYPE string,
            BEGIN OF l3,
              v4 TYPE abap_bool,
            END OF l3,
          END OF l2,
        END OF l1,
      END OF ty_s_deep.

    TYPES:
      BEGIN OF ty_s_nested,
        id      TYPE string,
        t_items TYPE ty_t_row,
      END OF ty_s_nested.
    TYPES ty_t_nested TYPE STANDARD TABLE OF ty_s_nested WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_with_oref,
        text  TYPE string,
        o_obj TYPE REF TO ltcl_shp_inner,
      END OF ty_s_with_oref.

    TYPES:
      BEGIN OF ty_s_with_dref,
        text  TYPE string,
        r_tab TYPE REF TO data,
      END OF ty_s_with_dref.

    TYPES:
      BEGIN OF ty_s_row_ref,
        id     TYPE string,
        r_elem TYPE REF TO string,
        o_obj  TYPE REF TO ltcl_shp_inner,
      END OF ty_s_row_ref.
    TYPES ty_t_row_ref TYPE STANDARD TABLE OF ty_s_row_ref WITH EMPTY KEY.

    " S01 elementary
    DATA mv_string TYPE string.
    DATA mv_int    TYPE i.
    DATA mv_packed TYPE p LENGTH 8 DECIMALS 2.
    DATA mv_date   TYPE d.
    DATA mv_time   TYPE t.
    DATA mv_bool   TYPE abap_bool.
    DATA mv_xstr   TYPE xstring.
    " S02 flat structure, S03 four levels deep
    DATA ms_flat   TYPE ty_s_row.
    DATA ms_deep   TYPE ty_s_deep.
    " S04 standard, S05 sorted, S06 elementary line, S07 nested table
    DATA mt_std     TYPE ty_t_row.
    DATA mt_sorted  TYPE ty_t_sorted.
    DATA mt_strings TYPE string_table.
    DATA mt_nested  TYPE ty_t_nested.
    " S08 statically typed drefs
    DATA mr_typed_tab   TYPE REF TO ty_t_row.
    DATA mr_typed_struc TYPE REF TO ty_s_row.
    DATA mr_typed_elem  TYPE REF TO string.
    " S09 generic drefs created TYPE HANDLE (anonymous line type)
    DATA mr_handle_tab   TYPE REF TO data.
    DATA mr_handle_struc TYPE REF TO data.
    " S10 generic dref, elementary target
    DATA mr_elem TYPE REF TO data.
    " S11 drefs INTO other attributes
    DATA mr_alias_struc TYPE REF TO data.
    DATA mr_alias_tab   TYPE REF TO data.
    " S12 three drefs on ONE anonymous table - the third sits in mo_inner
    DATA mr_shared_a TYPE REF TO data.
    DATA mr_shared_b TYPE REF TO data.
    " S13 a dref whose target is a dref
    DATA mr_ref_ref TYPE REF TO data.
    " S14 serializable instance (with a chain inside), S15 a dead one
    DATA mo_inner TYPE REF TO ltcl_shp_inner.
    DATA mo_dead  TYPE REF TO ltcl_shp_dead.
    " S19 object as component, S20 dref as component - and both as cells
    DATA ms_with_oref TYPE ty_s_with_oref.
    DATA ms_with_dref TYPE ty_s_with_dref.
    DATA mt_rows_ref  TYPE ty_t_row_ref.
    " S25 a table whose rows hold RTTI descriptors - abap_component_tab, the
    " attribute every runtime-typed sample keeps (184, 190, 194, 199, 212)
    DATA mt_comp TYPE abap_component_tab.
    " S26 an anonymous STRUCTURE whose components are tables (194 ms_fixval)
    DATA mr_handle_nested TYPE REF TO data.
    " S27 a second helper over the same data as the first, and pointing at
    " a TYPED table attribute of the app (334: two objects, one target;
    " 347: the bound table aliased from inside a helper)
    DATA mo_inner_2 TYPE REF TO ltcl_shp_inner.
    " S28 an interface-typed reference (what a host keeps its sub-app in
    " when it is not REF TO object), S29 a table of object references
    DATA mi_app  TYPE REF TO z2ui5_if_app.
    DATA mt_apps TYPE STANDARD TABLE OF REF TO ltcl_shp_inner WITH EMPTY KEY.
    " S30 a string with markup, quotes and a line break - what has to pass
    " the JSON writer, the asXML of the draft and the way back unchanged
    DATA mv_markup TYPE string.

    METHODS fill.
    METHODS get_protected
      RETURNING
        VALUE(result) TYPE string.
    " the address of a protected attribute - what a search for it gets
    METHODS get_protected_ref
      RETURNING
        VALUE(result) TYPE REF TO data.

  PROTECTED SECTION.
    " S23 - serialized with the rest, never dissolved, never bindable
    DATA mv_protected TYPE string.
    DATA mo_hidden    TYPE REF TO ltcl_shp_dead.
ENDCLASS.


CLASS ltcl_app_shapes IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD get_protected.
    result = mv_protected.
  ENDMETHOD.

  METHOD get_protected_ref.
    result = REF #( mv_protected ).
  ENDMETHOD.

  METHOD fill.

    FIELD-SYMBOLS <tab>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <elem>  TYPE any.
    DATA ls_sel TYPE ty_s_row_sel.

    mv_string = `text`.
    mv_int    = 42.
    mv_packed = '1234.56'.
    mv_date   = '20240115'.
    mv_time   = '123045'.
    mv_bool   = abap_true.
    mv_xstr   = 'DEADBEEF'.

    ms_flat = VALUE #( col1 = `flat` col2 = 1 ).
    ms_deep-v1          = `v1`.
    ms_deep-l1-v2       = `v2`.
    ms_deep-l1-l2-v3    = `v3`.
    ms_deep-l1-l2-l3-v4 = abap_true.

    mt_std     = VALUE #( ( col1 = `a` col2 = 1 ) ( col1 = `b` col2 = 2 ) ).
    mt_sorted  = VALUE #( ( col1 = `x` col2 = 9 ) ( col1 = `y` col2 = 8 ) ).
    mt_strings = VALUE #( ( `one` ) ( `two` ) ).
    mt_nested  = VALUE #( ( id = `n1` t_items = VALUE #( ( col1 = `n1a` col2 = 1 ) ) )
                          ( id = `n2` t_items = VALUE #( ( col1 = `n2a` col2 = 2 ) ( col1 = `n2b` col2 = 3 ) ) ) ).

    CREATE DATA mr_typed_tab.
    mr_typed_tab->* = VALUE #( ( col1 = `typed` col2 = 7 ) ).
    CREATE DATA mr_typed_struc.
    mr_typed_struc->* = VALUE #( col1 = `typed-struc` col2 = 8 ).
    CREATE DATA mr_typed_elem.
    mr_typed_elem->* = `typed-elem`.

    " the anonymous line type of a runtime-built table: the components of a
    " known structure plus a field that exists in NO dictionary (SELKZ in
    " the samples)
    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ms_flat ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    " c LENGTH 1, not abap_bool: a type-pool type carries a full absolute
    " name (\TYPE-POOL=ABAP\TYPE=ABAP_BOOL) that S-RTTI resolves by name -
    " fine on a system, unknown to the NodeJS runtime, which only answers
    " for the built-in types by their anonymous names
    DATA lv_flag TYPE c LENGTH 1.
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_flag ) ) ) TO lt_comp.
    DATA(lo_struc) = cl_abap_structdescr=>create( lt_comp ).
    DATA(lo_tab)   = cl_abap_tabledescr=>create( p_line_type  = lo_struc
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std ).

    CREATE DATA mr_handle_tab TYPE HANDLE lo_tab.
    ASSIGN mr_handle_tab->* TO <tab>.
    ls_sel = VALUE #( col1 = `handle-row-1` selkz = abap_true ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    ls_sel = VALUE #( col1 = `handle-row-2` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    CREATE DATA mr_handle_struc TYPE HANDLE lo_struc.
    ASSIGN mr_handle_struc->* TO <row>.
    ls_sel = VALUE #( col1 = `handle-struc` ).
    MOVE-CORRESPONDING ls_sel TO <row>.

    CREATE DATA mr_elem TYPE string.
    ASSIGN mr_elem->* TO <elem>.
    <elem> = `elem`.

    mr_alias_struc = REF #( ms_flat ).
    mr_alias_tab   = REF #( mt_std ).

    " one data object, three references - two here, one in the helper
    CREATE DATA mr_shared_a TYPE HANDLE lo_tab.
    ASSIGN mr_shared_a->* TO <tab>.
    ls_sel = VALUE #( col1 = `shared` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mr_shared_b = mr_shared_a.

    mo_inner = NEW #( ).
    mo_inner->mv_inner  = `inner`.
    mo_inner->mt_own    = VALUE #( ( col1 = `own` col2 = 5 ) ).
    mo_inner->mr_shared = mr_shared_a.
    mo_inner->mo_deeper = NEW #( ).
    mo_inner->mo_deeper->mv_inner = `deeper`.

    mo_inner_2 = NEW #( ).
    mo_inner_2->mv_inner  = `inner-2`.
    mo_inner_2->mr_shared = REF #( mt_std ).

    mo_dead = NEW #( ).
    mo_dead->mv_text = `dead`.

    mt_comp = lt_comp.

    " a structure that exists at runtime only, with a table inside
    DATA lt_nested_comp TYPE abap_component_tab.
    APPEND VALUE #( name = `ID`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( mv_string ) ) ) TO lt_nested_comp.
    APPEND VALUE #( name = `T_ITEMS`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( mt_std ) ) ) TO lt_nested_comp.
    " a variable as the handle: a method call in this position is a syntax
    " error on a system ("No method can be specified in the current
    " position"), which neither abaplint nor the transpiler model
    DATA(lo_nested) = cl_abap_structdescr=>create( lt_nested_comp ).
    CREATE DATA mr_handle_nested TYPE HANDLE lo_nested.
    ASSIGN mr_handle_nested->* TO <row>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <row> TO <tab>.
    IF sy-subrc = 0.
      <tab> = mt_std.
    ENDIF.

    ms_with_oref-text  = `with-oref`.
    ms_with_oref-o_obj = NEW #( ).
    ms_with_oref-o_obj->mv_inner = `in-struc`.

    ms_with_dref-text = `with-dref`.
    CREATE DATA ms_with_dref-r_tab TYPE HANDLE lo_tab.
    ASSIGN ms_with_dref-r_tab->* TO <tab>.
    ls_sel = VALUE #( col1 = `in-struc-tab` ).
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.

    APPEND INITIAL LINE TO mt_rows_ref ASSIGNING FIELD-SYMBOL(<row_ref>).
    <row_ref>-id = `r1`.
    CREATE DATA <row_ref>-r_elem.
    <row_ref>-r_elem->* = `cell-ref`.
    <row_ref>-o_obj = NEW #( ).
    <row_ref>-o_obj->mv_inner = `cell-obj`.

    mv_protected = `protected`.
    mo_hidden = NEW #( ).

    APPEND NEW ltcl_shp_inner( ) TO mt_apps.
    mt_apps[ 1 ]->mv_inner = `in-table`.

    mv_markup = |<b>tag</b> & "quoted" 'single' \\ backslash{ cl_abap_char_utilities=>newline }second line|.

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 338: a host holds its sub-app in a REF TO object and swaps it for an
" instance of ANOTHER class between two roundtrips - the rows of the old
" class stay in mt_attri with nothing to resolve to.
" ---------------------------------------------------------------------------

CLASS ltcl_shp_sub_a DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_table  TYPE REF TO data.
    DATA mo_layout TYPE REF TO ltcl_shp_inner.
    METHODS fill.
ENDCLASS.

CLASS ltcl_shp_sub_a IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lv_selkz TYPE c LENGTH 1.
    DATA ls_line  TYPE ltcl_shp_inner=>ty_s_row.
    " a runtime-built line type, like the samples: known components plus
    " a field no dictionary has
    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_line ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_selkz ) ) ) TO lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_table TYPE HANDLE lo_tab.
    ASSIGN mt_table->* TO <tab>.
    ls_line-col1 = `a`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_line TO <row>.
    mo_layout->mr_shared = mt_table.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_shp_sub_b DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mt_data TYPE REF TO data.
    DATA mo_lay  TYPE REF TO ltcl_shp_inner.
    METHODS fill.
ENDCLASS.

CLASS ltcl_shp_sub_b IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lv_selkz TYPE c LENGTH 1.
    DATA ls_line  TYPE ltcl_shp_inner=>ty_s_row.
    " a runtime-built line type, like the samples: known components plus
    " a field no dictionary has
    DATA(lo_line) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_line ) ).
    DATA(lt_comp) = lo_line->get_components( ).
    APPEND VALUE #( name = `SELKZ`
                    type = CAST #( cl_abap_datadescr=>describe_by_data( lv_selkz ) ) ) TO lt_comp.
    DATA(lo_tab) = cl_abap_tabledescr=>create( p_line_type  = cl_abap_structdescr=>create( lt_comp )
                                               p_table_kind = cl_abap_tabledescr=>tablekind_std ).
    CREATE DATA mt_data TYPE HANDLE lo_tab.
    ASSIGN mt_data->* TO <tab>.
    ls_line-col1 = `b`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_line TO <row>.
    mo_lay->mr_shared = mt_data.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_app_host DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mv_selectedkey TYPE string.
    DATA mo_app         TYPE REF TO object.
ENDCLASS.

CLASS ltcl_app_host IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" Sample 339 with the sort order turned around: the canonical row of a shared
" table is whichever of its rows sorts LAST in mt_attri. In 339 that is an
" outer attribute (MT_TABLE_TMP->*); here the helper's reference sorts last
" (MZ_INNER->MR_SHARED->*), so the payload lives on the NESTED object and
" the outer references are re-pointed from there.
" ---------------------------------------------------------------------------

CLASS ltcl_app_shared_last DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA mr_table     TYPE REF TO data.
    DATA mr_table_tmp TYPE REF TO data.
    DATA mz_inner     TYPE REF TO ltcl_shp_inner.
ENDCLASS.

CLASS ltcl_app_shared_last IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" Three of the small test samples as unit tests: 343 (binding a REF TO data
" itself is refused), 138 (a leaf six levels down a structure whose
" components all carry the same name) and 118 (date and time fields the
" model has to ship as they are, initial or not)
" ---------------------------------------------------------------------------

CLASS ltcl_app_samples DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE i,
        descr TYPE string,
        adate TYPE d,
        atime TYPE t,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mt_rows TYPE ty_t_row.
    " a reference INTO the nested structure below - what a leaf reached
    " through it has to bind as
    DATA mr_alias TYPE REF TO data.

    DATA:
      BEGIN OF ms_data,
        BEGIN OF ms_data2,
          val TYPE string,
          BEGIN OF ms_data2,
            val TYPE string,
            BEGIN OF ms_data2,
              val TYPE string,
              BEGIN OF ms_data2,
                val TYPE string,
                BEGIN OF ms_data2,
                  val TYPE string,
                  BEGIN OF ms_data2,
                    val TYPE string,
                  END OF ms_data2,
                END OF ms_data2,
              END OF ms_data2,
            END OF ms_data2,
          END OF ms_data2,
        END OF ms_data2,
        val2 TYPE string,
      END OF ms_data.
ENDCLASS.

CLASS ltcl_app_samples IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.


" a serializable filter - what an app's own filter class has to be to
" survive the draft (z2ui5_cl_ui5_srv_bind refuses one that is not)
CLASS ltcl_shp_filter DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_ajson_filter.
ENDCLASS.

CLASS ltcl_shp_filter IMPLEMENTATION.

  METHOD z2ui5_if_ajson_filter~keep_node.
    " drop an initial string leaf, keep everything else
    rv_keep = xsdbool( is_node-type <> z2ui5_if_ajson_types=>node_type-string OR is_node-value IS NOT INITIAL ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_00_base DEFINITION DEFERRED.
CLASS ltcl_01_dissolve DEFINITION DEFERRED.
CLASS ltcl_02_search DEFINITION DEFERRED.
CLASS ltcl_03_model_out DEFINITION DEFERRED.
CLASS ltcl_04_model_in DEFINITION DEFERRED.
CLASS ltcl_05_draft DEFINITION DEFERRED.
CLASS z2ui5_cl_ui5_srv_model DEFINITION LOCAL FRIENDS ltcl_00_base ltcl_01_dissolve ltcl_02_search
                                                     ltcl_03_model_out ltcl_04_model_in ltcl_05_draft.


CLASS ltcl_00_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PROTECTED SECTION.
    DATA mo_app   TYPE REF TO ltcl_app_shapes.
    DATA mo_model TYPE REF TO z2ui5_cl_ui5_srv_model.
    DATA mr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    " the names every bound row must keep across the lifecycle
    DATA mt_bound TYPE string_table.

    " a fresh model over the same fixture and attribute table
    METHODS model_renew.

    " bind one value the way _bind( ) does - through the search - and record
    " the row it landed on
    METHODS bind
      IMPORTING
        ir_val        TYPE REF TO data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    " bind one value of every bindable form
    METHODS bind_all.

    " the draft roundtrip as the container runs it: srtti save, asXML of the
    " app AND of the attribute table, parse into fresh instances, load.
    " io_replace_app, when given, is put in as the app BEFORE the load - the
    " state of a restore against a live instance that changed meanwhile
    " iv_legacy strips the TYPE_NAME elements from the attribute table's
    " asXML - the draft a version before that component wrote
    METHODS roundtrip
      IMPORTING
        io_replace_app TYPE REF TO ltcl_app_shapes OPTIONAL
        iv_legacy      TYPE abap_bool OPTIONAL.

    " the asXML without every <iv_tag>...</iv_tag> element
    METHODS xml_without_tag
      IMPORTING
        iv_xml        TYPE string
        iv_tag        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    " one row of mt_attri, by value - and by reference for a write
    METHODS row
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_types=>ty_s_attri.
    METHODS row_ref
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.

    METHODS row_exists
      IMPORTING
        iv_name       TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    " the invariants - I1 types known, I3 reachable, I4 identity, I5 search,
    " I2/I6 model unchanged, I8 payload cleared (numbering of the test plan)
    METHODS inv_types_known.
    METHODS inv_rows_reachable.
    METHODS inv_identity_shared.
    METHODS inv_search_finds_bound.
    METHODS inv_json_unchanged
      IMPORTING
        iv_before TYPE string.
    METHODS inv_srtti_cleared.
    METHODS inv_all
      IMPORTING
        iv_before TYPE string.

  PRIVATE SECTION.
    " private, as ABAP Unit wants it - and inherited by every section
    METHODS setup.
ENDCLASS.


CLASS ltcl_00_base IMPLEMENTATION.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->fill( ).
    CREATE DATA mr_attri.
    model_renew( ).

  ENDMETHOD.

  METHOD model_renew.

    mo_model = NEW #( attri = mr_attri
                      app   = mo_app ).

  ENDMETHOD.

  METHOD bind.

    result = mo_model->main_attri_search( ir_val ).
    result->bind = abap_true.
    " a path the ajson writer accepts: no `-` and no `->` inside a segment
    DATA(lv_path) = result->name.
    REPLACE ALL OCCURRENCES OF `->*` IN lv_path WITH `_D`.
    REPLACE ALL OCCURRENCES OF `->` IN lv_path WITH `_`.
    REPLACE ALL OCCURRENCES OF `-` IN lv_path WITH `_`.
    result->name_client = |/{ lv_path }|.
    IF NOT line_exists( mt_bound[ table_line = result->name ] ).
      APPEND result->name TO mt_bound.
    ENDIF.

  ENDMETHOD.

  METHOD bind_all.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    CLEAR mt_bound.

    " S01
    bind( REF #( mo_app->mv_string ) ).
    bind( REF #( mo_app->mv_int ) ).
    bind( REF #( mo_app->mv_packed ) ).
    bind( REF #( mo_app->mv_date ) ).
    bind( REF #( mo_app->mv_time ) ).
    bind( REF #( mo_app->mv_bool ) ).
    bind( REF #( mo_app->mv_markup ) ).
    " S02/S03 - the structure and a leaf four levels down
    bind( REF #( mo_app->ms_flat ) ).
    bind( REF #( mo_app->ms_deep-l1-l2-l3-v4 ) ).
    " S04-S07
    bind( REF #( mo_app->mt_std ) ).
    bind( REF #( mo_app->mt_sorted ) ).
    bind( REF #( mo_app->mt_strings ) ).
    bind( REF #( mo_app->mt_nested ) ).
    " S08 - the dereferenced data, exactly what _bind( <fs> ) hands over
    bind( mo_app->mr_typed_tab ).
    bind( REF #( mo_app->mr_typed_struc->col1 ) ).
    bind( mo_app->mr_typed_elem ).
    " S09/S10
    bind( mo_app->mr_handle_tab ).
    bind( mo_model->attri_get_val_ref( `MR_HANDLE_STRUC->COL1` ) ).
    bind( mo_app->mr_elem ).
    " S12 - the shared table through the helper's reference
    bind( mo_app->mo_inner->mr_shared ).
    " S14 - data inside the helper and its chain
    bind( REF #( mo_app->mo_inner->mv_inner ) ).
    bind( REF #( mo_app->mo_inner->mt_own ) ).
    bind( REF #( mo_app->mo_inner->mo_deeper->mv_inner ) ).
    " S26 - the table inside the anonymous structure
    bind( mo_model->attri_get_val_ref( `MR_HANDLE_NESTED->T_ITEMS` ) ).
    " S27 - the typed table, reached through the second helper's reference
    bind( REF #( mo_app->mo_inner_2->mv_inner ) ).
    " S19/S20 - through the component
    bind( REF #( mo_app->ms_with_oref-o_obj->mv_inner ) ).
    ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>.
    bind( REF #( <tab> ) ).

  ENDMETHOD.

  METHOD roundtrip.

    mo_model->main_attri_db_save_srtti( ).

    " the container serializes itself with the app AND mt_attri inside -
    " o_typedescr is a REF TO cl_abap_typedescr and does not survive this,
    " which is the state every restore starts from
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    IF iv_legacy = abap_true.
      lv_attri_xml = xml_without_tag( iv_xml = lv_attri_xml
                                      iv_tag = `TYPE_NAME` ).
    ENDIF.

    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    IF io_replace_app IS BOUND.
      mo_app = io_replace_app.
    ENDIF.

    model_renew( ).
    mo_model->main_attri_db_load( ).

  ENDMETHOD.

  METHOD xml_without_tag.

    " both spellings of the element: with a value, and the empty one
    result = iv_xml.
    DATA(lv_open)  = |<{ iv_tag }>|.
    DATA(lv_close) = |</{ iv_tag }>|.
    DO.
      FIND FIRST OCCURRENCE OF lv_open IN result MATCH OFFSET DATA(lv_from).
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      FIND FIRST OCCURRENCE OF lv_close IN result MATCH OFFSET DATA(lv_to).
      IF sy-subrc <> 0 OR lv_to < lv_from.
        EXIT.
      ENDIF.
      DATA(lv_end) = lv_to + strlen( lv_close ).
      result = result(lv_from) && result+lv_end.
    ENDDO.
    REPLACE ALL OCCURRENCES OF |<{ iv_tag }/>| IN result WITH ``.

  ENDMETHOD.

  METHOD row.

    result = row_ref( iv_name )->*.

  ENDMETHOD.

  METHOD row_ref.

    READ TABLE mr_attri->* REFERENCE INTO result WITH TABLE KEY name = iv_name.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( |no row { iv_name }| ).
    ENDIF.

  ENDMETHOD.

  METHOD row_exists.

    result = xsdbool( line_exists( mr_attri->*[ name = iv_name ] ) ).

  ENDMETHOD.

  METHOD inv_types_known.

    " I1 - every row knows its type across the draft: the absolute name
    " travels as a string on the row (the search prefilters by it), while
    " the descriptor object is rebuilt only where the restore parses a
    " payload. A row without a name is a draft written before the name
    " existed - not a state a roundtrip of THIS version may produce
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri).
      cl_abap_unit_assert=>assert_not_initial( act = lr_attri->type_name
                                               msg = |I1: no type name on { lr_attri->name }| ).
      cl_abap_unit_assert=>assert_not_initial( act = lr_attri->type_kind
                                               msg = |I1: no type kind on { lr_attri->name }| ).
    ENDLOOP.
    " ...and the payload rows carry their descriptor again
    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(ls_row) = mr_attri->*[ name = lv_name ].
      IF ls_row-name_parent IS INITIAL OR ls_row-name_ref IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      DATA(ls_parent) = mr_attri->*[ name = ls_row-name_parent ].
      IF ls_parent-type_kind <> z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref.
        CONTINUE.
      ENDIF.
      cl_abap_unit_assert=>assert_bound( act = ls_parent-o_typedescr
                                         msg = |I1: no descriptor on the restored { ls_parent-name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_rows_reachable.

    " I3 - every row names data that exists on the instance
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri).
      IF lr_attri->name CP `MO_DEAD->*`.
        CONTINUE.
      ENDIF.
      TRY.
          DATA(lr_ref) = mo_model->attri_get_val_ref( lr_attri->name ).
          cl_abap_unit_assert=>assert_bound( act = lr_ref
                                             msg = |I3: { lr_attri->name } not reachable| ).
        CATCH cx_root.
          cl_abap_unit_assert=>fail( |I3: { lr_attri->name } not reachable| ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_identity_shared.

    " I4 - references that shared a data object share ONE again (identity,
    " not content: the sample toasts compare content and would miss a copy)
    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_shared_a
                                       msg = `I4: mr_shared_a lost` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_shared_a = mo_app->mr_shared_b )
                                      msg = `I4: mr_shared_a and mr_shared_b are two objects now` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_shared_a = mo_app->mo_inner->mr_shared )
                                      msg = `I4: the helper's mr_shared is a copy` ).
    " ...two helpers stay two objects (334)...
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mo_inner <> mo_app->mo_inner_2 )
                                      msg = `I4: the two helpers collapsed into one object` ).
    " ...and the aliases point INTO their owner again, the one inside the
    " second helper included (347)
    DATA(lr_flat) = REF #( mo_app->ms_flat ).
    DATA(lr_std)  = REF #( mo_app->mt_std ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_alias_struc = lr_flat )
                                      msg = `I4: mr_alias_struc detached from ms_flat` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_alias_tab = lr_std )
                                      msg = `I4: mr_alias_tab detached from mt_std` ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mo_inner_2->mr_shared = lr_std )
                                      msg = `I4: the helper's alias of mt_std is a copy` ).

  ENDMETHOD.

  METHOD inv_search_finds_bound.

    " I5 - the binding search answers with the same row for every bound
    " attribute, on the instance as it is NOW
    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(lr_ref) = mo_model->attri_get_val_ref( lv_name ).
      DATA(lr_attri) = mo_model->main_attri_search( lr_ref ).
      cl_abap_unit_assert=>assert_equals( act = lr_attri->name
                                          exp = lv_name
                                          msg = |I5: { lv_name } found as { lr_attri->name }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_json_unchanged.

    " I2/I6 - the model the next render ships is the model before the save
    DATA(lv_after) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_equals( act = lv_after
                                        exp = iv_before
                                        msg = `I2: the model changed across the draft` ).
    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(lv_key) = substring( val = row( lv_name )-name_client
                                off = 1 ).
      cl_abap_unit_assert=>assert_true( act = xsdbool( lv_after CS |"{ lv_key }"| )
                                        msg = |I6: { lv_name } missing from the model| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_srtti_cleared.

    " I8 - a successful restore leaves no payload behind
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri) "#EC CI_SORTSEQ
         WHERE srtti_data IS NOT INITIAL.
      cl_abap_unit_assert=>fail( |I8: { lr_attri->name } still carries srtti_data| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD inv_all.

    inv_types_known( ).
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( iv_before ).
    inv_srtti_cleared( ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 01 DISSOLVE - the attributes of the app become the rows of mt_attri
" ---------------------------------------------------------------------------
CLASS ltcl_01_dissolve DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every form gets its rows, protected attributes get none
    METHODS rows_per_form            FOR TESTING RAISING cx_static_check.
    " a row knows what it is
    METHODS row_kinds                FOR TESTING RAISING cx_static_check.
    " a reference INTO another attribute knows its owner (name_ref), and so
    " do the children it fans out into
    METHODS aliases_know_owner       FOR TESTING RAISING cx_static_check.
    " of several references to one data object exactly one row is canonical
    METHODS shared_one_canonical     FOR TESTING RAISING cx_static_check.
    " a structure is followed to its last level, however deep
    METHODS deep_struct_every_level  FOR TESTING RAISING cx_static_check.
    " an object graph that points back at itself ends at the hop limit
    METHODS cycle_self_ends          FOR TESTING RAISING cx_static_check.
    METHODS cycle_two_objects_ends   FOR TESTING RAISING cx_static_check.
    " a table of objects is a leaf - its rows are not attributes
    METHODS table_of_objects_is_leaf FOR TESTING RAISING cx_static_check.
    " an interface-typed reference is followed like a class-typed one
    METHODS interface_ref_followed   FOR TESTING RAISING cx_static_check.
    " a refresh rebuilds the rows and keeps what a bind wrote on them
    METHODS refresh_keeps_bindings   FOR TESTING RAISING cx_static_check.
    " a refresh finds an object that was initial at the first dissolve
    METHODS refresh_finds_late_obj   FOR TESTING RAISING cx_static_check.
    " a refresh drops the rows of an object that is gone
    METHODS refresh_drops_orphans    FOR TESTING RAISING cx_static_check.
    " dissolving twice changes nothing
    METHODS dissolve_idempotent      FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_01_dissolve IMPLEMENTATION.

  METHOD rows_per_form.

    mo_model->main_attri_refresh( ).

    DATA(lt_expected) = VALUE string_table(
        ( `MV_STRING` ) ( `MV_PACKED` ) ( `MV_XSTR` ) ( `MV_MARKUP` )
        ( `MS_FLAT` ) ( `MS_FLAT-COL1` )
        ( `MS_DEEP` ) ( `MS_DEEP-L1` ) ( `MS_DEEP-L1-L2` ) ( `MS_DEEP-L1-L2-L3` ) ( `MS_DEEP-L1-L2-L3-V4` )
        ( `MT_STD` ) ( `MT_SORTED` ) ( `MT_STRINGS` ) ( `MT_NESTED` )
        ( `MR_TYPED_TAB` ) ( `MR_TYPED_TAB->*` )
        ( `MR_TYPED_STRUC` ) ( `MR_TYPED_STRUC->COL1` )
        ( `MR_TYPED_ELEM` ) ( `MR_TYPED_ELEM->*` )
        ( `MR_HANDLE_TAB` ) ( `MR_HANDLE_TAB->*` )
        ( `MR_HANDLE_STRUC` ) ( `MR_HANDLE_STRUC->SELKZ` )
        ( `MR_ELEM` ) ( `MR_ELEM->*` )
        ( `MR_ALIAS_STRUC` ) ( `MR_ALIAS_STRUC->COL1` )
        ( `MR_ALIAS_TAB` ) ( `MR_ALIAS_TAB->*` )
        ( `MR_SHARED_A` ) ( `MR_SHARED_A->*` ) ( `MR_SHARED_B->*` )
        ( `MR_REF_REF` )
        ( `MO_INNER` ) ( `MO_INNER->MV_INNER` ) ( `MO_INNER->MT_OWN` )
        ( `MO_INNER->MR_SHARED` ) ( `MO_INNER->MR_SHARED->*` )
        ( `MO_INNER->MO_DEEPER` ) ( `MO_INNER->MO_DEEPER->MV_INNER` )
        ( `MO_DEAD` ) ( `MO_DEAD->MV_TEXT` )
        ( `MS_WITH_OREF-O_OBJ` ) ( `MS_WITH_OREF-O_OBJ->MV_INNER` )
        ( `MS_WITH_DREF-R_TAB` ) ( `MS_WITH_DREF-R_TAB->*` )
        ( `MT_ROWS_REF` ) ( `MT_COMP` ) ( `MT_APPS` ) ( `MI_APP` )
        ( `MR_HANDLE_NESTED` ) ( `MR_HANDLE_NESTED->ID` ) ( `MR_HANDLE_NESTED->T_ITEMS` )
        ( `MO_INNER_2` ) ( `MO_INNER_2->MR_SHARED` ) ).

    LOOP AT lt_expected INTO DATA(lv_name).
      cl_abap_unit_assert=>assert_true( act = row_exists( lv_name )
                                        msg = |no row for { lv_name }| ).
    ENDLOOP.

    " protected attributes are not dissolved - nothing can bind them
    cl_abap_unit_assert=>assert_false( row_exists( `MV_PROTECTED` ) ).
    cl_abap_unit_assert=>assert_false( row_exists( `MO_HIDDEN` ) ).

    " every row is done - nothing pending after a full refresh
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ check_dissolved = abap_false ] ) ) ).

  ENDMETHOD.

  METHOD row_kinds.

    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_string
                                        act = row( `MV_STRING` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_elem
                                        act = row( `MV_INT` )-kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = row( `MT_STD` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_oref
                                        act = row( `MO_INNER` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_dref
                                        act = row( `MR_HANDLE_TAB` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = row( `MR_HANDLE_TAB->*` )-type_kind ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_HANDLE_TAB`
                                        act = row( `MR_HANDLE_TAB->*` )-name_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER`
                                        act = row( `MO_INNER->MV_INNER` )-name_parent ).

  ENDMETHOD.

  METHOD aliases_know_owner.

    mo_model->main_attri_refresh( ).

    " the reference to a structure attribute, and its children
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = row( `MR_ALIAS_STRUC` )-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT-COL1`
                                        act = row( `MR_ALIAS_STRUC->COL1` )-name_ref ).
    " the reference to a table attribute
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).
    " the same from inside a helper object (347)
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MO_INNER_2->MR_SHARED->*` )-name_ref ).
    " a reference to its OWN data object owns it
    cl_abap_unit_assert=>assert_initial( row( `MR_HANDLE_TAB->*` )-name_ref ).

  ENDMETHOD.

  METHOD shared_one_canonical.

    mo_model->main_attri_refresh( ).

    DATA(lv_canonical) = 0.
    DATA lv_name TYPE string.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE ( name = `MR_SHARED_A->*` OR name = `MR_SHARED_B->*` OR name = `MO_INNER->MR_SHARED->*` )
           AND name_ref IS INITIAL.
      lv_canonical = lv_canonical + 1.
      lv_name = `x`.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lv_canonical
                                        msg = `the shared table needs exactly one canonical row` ).
    " and it is the one that sorts last - the contract the draft relies on
    " (the payload is stored on the canonical row's parent)
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_B->*` )-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = row( `MR_SHARED_A->*` )-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = row( `MO_INNER->MR_SHARED->*` )-name_ref ).

  ENDMETHOD.

  METHOD deep_struct_every_level.

    " sample 138: a leaf seven components down, every level of the same name
    DATA(lo_app) = NEW ltcl_app_samples( ).
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    lo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( xsdbool( line_exists(
        lt_attri[ name = `MS_DATA-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-VAL` ] ) ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lt_attri[ check_dissolved = abap_false ] ) ) ).

  ENDMETHOD.

  METHOD cycle_self_ends.

    mo_app->mo_inner->mo_deeper = mo_app->mo_inner.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).
    DATA(lv_deepest) = 0.
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri).
      DATA(lv_hops) = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_deepest <= 5 )
                                      msg = |the cycle ran { lv_deepest } hops deep| ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ check_dissolved = abap_false ] ) ) ).

  ENDMETHOD.

  METHOD cycle_two_objects_ends.

    " A holds B, B holds A - the hop count is the only thing that ends it
    mo_app->mo_inner->mo_deeper   = mo_app->mo_inner_2.
    mo_app->mo_inner_2->mo_deeper = mo_app->mo_inner.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).
    cl_abap_unit_assert=>assert_true( row_exists( `MO_INNER_2->MO_DEEPER->MO_DEEPER->MV_INNER` ) ).
    DATA(lv_deepest) = 0.
    LOOP AT mr_attri->* REFERENCE INTO DATA(lr_attri).
      DATA(lv_hops) = count( val = lr_attri->name
                             sub = `->` ).
      IF lv_hops > lv_deepest.
        lv_deepest = lv_hops.
      ENDIF.
    ENDLOOP.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_deepest <= 5 ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( mr_attri->*[ check_dissolved = abap_false ] ) ) ).

  ENDMETHOD.

  METHOD table_of_objects_is_leaf.

    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MT_APPS` ) ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_datadescr=>typekind_table
                                        act = row( `MT_APPS` )-type_kind ).
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS "#EC CI_SORTSEQ
         WHERE name CP `MT_APPS-*` OR name CP `MT_APPS->*`.
      cl_abap_unit_assert=>fail( `the rows of a table of objects are not attributes` ).
    ENDLOOP.

  ENDMETHOD.

  METHOD interface_ref_followed.

    " S28 - a REF TO z2ui5_if_app holding another instance of the app class
    DATA(lo_other) = NEW ltcl_app_shapes( ).
    lo_other->mv_string = `other`.
    mo_app->mi_app = lo_other.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MI_APP->MV_STRING` ) ).
    cl_abap_unit_assert=>assert_true( row_exists( `MI_APP->MT_STD` ) ).
    DATA(lr_attri) = mo_model->main_attri_search( REF #( lo_other->mv_string ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MI_APP->MV_STRING`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD refresh_keeps_bindings.

    DATA(lr_attri) = bind( REF #( mo_app->ms_flat ) ).
    lr_attri->custom_filter = NEW ltcl_shp_filter( ).
    lr_attri->custom_mapper = z2ui5_cl_ajson_mapping=>create_upper_case( ).
    lr_attri->check_json    = abap_false.
    DATA(lr_json) = bind( REF #( mo_app->mv_string ) ).
    lr_json->check_json = abap_true.

    mo_model->main_attri_refresh( ).

    DATA(lr_after) = row_ref( `MS_FLAT` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_after->bind ).
    cl_abap_unit_assert=>assert_equals( exp = `/MS_FLAT`
                                        act = lr_after->name_client ).
    cl_abap_unit_assert=>assert_bound( lr_after->custom_filter ).
    cl_abap_unit_assert=>assert_bound( lr_after->custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-check_json ).

  ENDMETHOD.

  METHOD refresh_finds_late_obj.

    " the app creates its helper AFTER the first bind (sample 117: mo_app is
    " created in render_sub_app, the host's own view was bound before)
    CLEAR mo_app->mi_app.
    bind( REF #( mo_app->mv_string ) ).
    cl_abap_unit_assert=>assert_false( row_exists( `MI_APP->MV_STRING` ) ).

    mo_app->mi_app = NEW ltcl_app_shapes( ).
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MI_APP->MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-bind ).

  ENDMETHOD.

  METHOD refresh_drops_orphans.

    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_true( row_exists( `MO_DEAD->MV_TEXT` ) ).

    CLEAR mo_app->mo_dead.
    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( row_exists( `MO_DEAD` ) ).
    cl_abap_unit_assert=>assert_false( row_exists( `MO_DEAD->MV_TEXT` ) ).

  ENDMETHOD.

  METHOD dissolve_idempotent.

    mo_model->main_attri_refresh( ).
    DATA(lv_rows) = lines( mr_attri->* ).
    mo_model->dissolve( ).
    mo_model->dissolve( ).
    cl_abap_unit_assert=>assert_equals( exp = lv_rows
                                        act = lines( mr_attri->* ) ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 02 SEARCH - a value handed to _bind( ) is found as the row it belongs to
" ---------------------------------------------------------------------------
CLASS ltcl_02_search DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every bindable form is found as its own row
    METHODS every_form_found          FOR TESTING RAISING cx_static_check.
    " a value reached by name - the addresses the search compares against
    METHODS address_per_form          FOR TESTING RAISING cx_static_check.
    " an alias binds as its OWNER - the model writes the owner's path
    METHODS alias_binds_as_owner      FOR TESTING RAISING cx_static_check.
    " three references to one table bind to the one canonical row
    METHODS shared_binds_canonical    FOR TESTING RAISING cx_static_check.
    " a reference itself is refused (sample 343)
    METHODS reference_itself_refused  FOR TESTING RAISING cx_static_check.
    " a leaf deeper than one dissolve pass reaches (sample 138)
    METHODS deep_leaf_found           FOR TESTING RAISING cx_static_check.
    " a leaf two levels below a reference INTO a structure binds as the
    " owner's leaf - the rows under a struct alias know their owner at
    " every depth, not only at the first
    METHODS alias_grandchild_as_owner FOR TESTING RAISING cx_static_check.
    " a row without a descriptor is passed over, not dumped on
    METHODS unreachable_row_skipped   FOR TESTING RAISING cx_static_check.
    " a value that is not there yet: the search dissolves, then refreshes
    METHODS search_refreshes_late_obj FOR TESTING RAISING cx_static_check.
    " a value that belongs to no public attribute is a named error
    METHODS unknown_value_is_error    FOR TESTING RAISING cx_static_check.
    " a value re-created in main( ) - a new object under the same name - is
    " found as that name; the object it replaced belongs to nobody
    METHODS recreated_value_found     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_02_search IMPLEMENTATION.

  METHOD every_form_found.

    bind_all( ).

    " every form landed on a row of its own, and each is found again
    cl_abap_unit_assert=>assert_equals( exp = 27
                                        act = lines( mt_bound ) ).
    LOOP AT mt_bound INTO DATA(lv_name).
      cl_abap_unit_assert=>assert_equals( exp = abap_true
                                          act = row( lv_name )-bind
                                          msg = |{ lv_name } is not bound| ).
    ENDLOOP.
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD address_per_form.

    mo_model->main_attri_refresh( ).

    cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MV_STRING` ) = REF #( mo_app->mv_string ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MR_ELEM->*` ) = mo_app->mr_elem ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MO_INNER->MV_INNER` ) = REF #( mo_app->mo_inner->mv_inner ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MO_INNER->MR_SHARED->*` ) = mo_app->mo_inner->mr_shared ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MS_DEEP-L1-L2-L3-V4` ) = REF #( mo_app->ms_deep-l1-l2-l3-v4 ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_model->attri_get_val_ref( `MR_TYPED_STRUC->COL1` ) = REF #( mo_app->mr_typed_struc->col1 ) ) ).

    TRY.
        mo_model->attri_get_val_ref( `NOT_AN_ATTRIBUTE` ).
        cl_abap_unit_assert=>fail( `an unknown name must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD alias_binds_as_owner.

    DATA(lr_attri) = mo_model->main_attri_search( mo_app->mr_alias_struc ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_FLAT`
                                        act = lr_attri->name ).
    lr_attri = mo_model->main_attri_search( mo_app->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_attri->name ).
    lr_attri = mo_model->main_attri_search( mo_app->mo_inner_2->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD shared_binds_canonical.

    DATA(lr_a) = mo_model->main_attri_search( mo_app->mr_shared_a ).
    DATA(lr_b) = mo_model->main_attri_search( mo_app->mr_shared_b ).
    DATA(lr_i) = mo_model->main_attri_search( mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = lr_a->name ).
    cl_abap_unit_assert=>assert_equals( exp = lr_a->name
                                        act = lr_b->name ).
    cl_abap_unit_assert=>assert_equals( exp = lr_a->name
                                        act = lr_i->name ).

  ENDMETHOD.

  METHOD reference_itself_refused.

    " _bind( mr_handle_tab ) hands the REFERENCE over, not the table behind
    " it - refused with a message that says what to do instead
    TRY.
        mo_model->main_attri_search( REF #( mo_app->mr_handle_tab ) ).
        cl_abap_unit_assert=>fail( `a reference itself must not be bindable` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `NO DATA REFERENCES` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD alias_grandchild_as_owner.

    DATA(lo_app) = NEW ltcl_app_samples( ).
    lo_app->mr_alias = REF #( lo_app->ms_data ).
    lo_app->ms_data-ms_data2-val = `two`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).

    " the leaf reached THROUGH the reference is the owner's leaf
    DATA(lr_leaf) = lo_model->attri_get_val_ref( `MR_ALIAS->MS_DATA2-VAL` ).
    DATA(lr_attri) = lo_model->main_attri_search( lr_leaf ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_attri->name ).
    " ...because every row under the alias names the owner's path
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2`
                                        act = lt_attri[ name = `MR_ALIAS->MS_DATA2` ]-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lt_attri[ name = `MR_ALIAS->MS_DATA2-VAL` ]-name_ref ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-VAL`
                                        act = lt_attri[ name = `MR_ALIAS->MS_DATA2-MS_DATA2-VAL` ]-name_ref ).

  ENDMETHOD.

  METHOD deep_leaf_found.

    DATA(lo_app) = NEW ltcl_app_samples( ).
    lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val = `deep`.
    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    DATA(lr_attri) = lo_model->main_attri_search(
        REF #( lo_app->ms_data-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-ms_data2-val ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-MS_DATA2-VAL`
                                        act = lr_attri->name ).
    DATA(lr_upper) = lo_model->main_attri_search( REF #( lo_app->ms_data-ms_data2-val ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MS_DATA-MS_DATA2-VAL`
                                        act = lr_upper->name ).

  ENDMETHOD.

  METHOD unreachable_row_skipped.

    " a row whose o_typedescr the restore could not re-resolve - the same
    " type_kind and kind as the searched value, so the prefilter visits it
    " first, and no descriptor. It used to dump CX_SY_REF_IS_INITIAL
    DATA(lo_descr) = z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( REF #( mo_app->mv_string ) ).
    INSERT VALUE #( name            = `AA_GONE`
                    check_dissolved = abap_true
                    type_kind       = lo_descr->type_kind
                    kind            = lo_descr->kind ) INTO TABLE mr_attri->*.

    DATA(lr_attri) = mo_model->main_attri_search( REF #( mo_app->mv_string ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).

  ENDMETHOD.

  METHOD search_refreshes_late_obj.

    CLEAR mo_app->mi_app.
    bind( REF #( mo_app->mv_string ) ).
    mo_app->mi_app = NEW ltcl_app_shapes( ).
    DATA lo_other TYPE REF TO ltcl_app_shapes.
    lo_other ?= mo_app->mi_app.

    " not in mt_attri yet - the search dissolves, finds nothing, refreshes
    DATA(lr_attri) = mo_model->main_attri_search( REF #( lo_other->mv_int ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MI_APP->MV_INT`
                                        act = lr_attri->name ).
    " and the earlier bind survived the refresh
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-bind ).

  ENDMETHOD.

  METHOD unknown_value_is_error.

    DATA lv_local TYPE string.
    TRY.
        mo_model->main_attri_search( REF #( lv_local ) ).
        cl_abap_unit_assert=>fail( `a value outside the app must raise` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `BINDING_ERROR` ) ).
    ENDTRY.
    " a protected attribute is outside as well
    TRY.
        mo_model->main_attri_search( mo_app->get_protected_ref( ) ).
        cl_abap_unit_assert=>fail( `a protected attribute must not be bindable` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.


  METHOD recreated_value_found.

    FIELD-SYMBOLS <elem> TYPE any.

    " the first render binds the target of the generic reference and the
    " helper's value
    bind( mo_app->mr_elem ).
    bind( REF #( mo_app->mo_inner->mv_inner ) ).
    DATA(lr_old_elem)  = mo_app->mr_elem.
    DATA(lo_old_inner) = mo_app->mo_inner.

    " main( ) of the next roundtrip: CREATE DATA and CREATE OBJECT again -
    " new objects under the same names, the old ones still alive in a local
    CREATE DATA mo_app->mr_elem TYPE string.
    ASSIGN mo_app->mr_elem->* TO <elem>.
    <elem> = `elem-new`.
    mo_app->mo_inner = NEW #( ).
    mo_app->mo_inner->mv_inner = `inner-new`.

    " the search answers with the rows, resolved against the NEW objects,
    " and the binding they carried stays
    DATA(lr_attri) = mo_model->main_attri_search( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_ELEM->*`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).
    lr_attri = mo_model->main_attri_search( REF #( mo_app->mo_inner->mv_inner ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MV_INNER`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lr_attri->bind ).

    " the model reads the new objects
    DATA(lv_model) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_model CS `"elem-new"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_model CS `"inner-new"` ) ).

    " the objects the render replaced are nobody's attribute any more: a
    " named error, never the stale row
    TRY.
        mo_model->main_attri_search( lr_old_elem ).
        cl_abap_unit_assert=>fail( `the replaced data object must not bind` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `BINDING_ERROR` ) ).
    ENDTRY.
    TRY.
        mo_model->main_attri_search( REF #( lo_old_inner->mv_inner ) ).
        cl_abap_unit_assert=>fail( `the replaced helper must not bind` ).
      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `BINDING_ERROR` ) ).
    ENDTRY.

    " ...and the refresh those misses ran left the bindings in place
    inv_search_finds_bound( ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 03 MODEL OUT - what the client receives
" ---------------------------------------------------------------------------
CLASS ltcl_03_model_out DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " every bound row is a key of the model, and nothing else is
    METHODS every_bound_row          FOR TESTING RAISING cx_static_check.
    METHODS nothing_bound_is_empty   FOR TESTING RAISING cx_static_check.
    " the values, per form
    METHODS values_per_form          FOR TESTING RAISING cx_static_check.
    " date and time fields, filled or not (sample 118)
    METHODS dates_initial_or_broken  FOR TESTING RAISING cx_static_check.
    " markup and quotes in a value arrive as a value
    METHODS markup_escaped           FOR TESTING RAISING cx_static_check.
    " _bind( json = abap_true ): the string IS JSON and becomes a node
    METHODS json_bind_spliced        FOR TESTING RAISING cx_static_check.
    METHODS json_bind_invalid_raises FOR TESTING RAISING cx_static_check.
    " a filter drops what it says (omit_initial)
    METHODS filter_applied           FOR TESTING RAISING cx_static_check.
    " a mapper renames what it says
    METHODS mapper_applied           FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_03_model_out IMPLEMENTATION.

  METHOD every_bound_row.

    bind_all( ).
    DATA(lv_json) = mo_model->main_json_stringify( ).

    LOOP AT mt_bound INTO DATA(lv_name).
      DATA(lv_key) = substring( val = row( lv_name )-name_client
                                off = 1 ).
      cl_abap_unit_assert=>assert_true( act = xsdbool( lv_json CS |"{ lv_key }"| )
                                        msg = |{ lv_name } missing from the model| ).
    ENDLOOP.
    " a reference row itself never travels - only the data behind it
    cl_abap_unit_assert=>assert_false( xsdbool( lv_json CS `"MR_HANDLE_TAB":` AND lv_json CS `"MO_INNER":` ) ).
    " and an unbound attribute does not either
    cl_abap_unit_assert=>assert_false( xsdbool( lv_json CS `"MV_XSTR"` ) ).

  ENDMETHOD.

  METHOD nothing_bound_is_empty.

    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_equals( exp = `{}`
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD values_per_form.

    bind_all( ).
    DATA(lo_json) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = lo_json->get_string( `/MV_STRING` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = lo_json->get_integer( `/MV_INT` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `2024-01-15`
                                        act = lo_json->get_string( `/MV_DATE` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_json->get_boolean( `/MV_BOOL` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `flat`
                                        act = lo_json->get_string( `/MS_FLAT/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_json->get_boolean( `/MS_DEEP_L1_L2_L3_V4` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = lo_json->get_string( `/MT_STD/2/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `n2b`
                                        act = lo_json->get_string( `/MT_NESTED/2/T_ITEMS/2/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `handle-row-1`
                                        act = lo_json->get_string( `/MR_HANDLE_TAB_D/1/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `shared`
                                        act = lo_json->get_string( `/MR_SHARED_B_D/1/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `elem`
                                        act = lo_json->get_string( `/MR_ELEM_D` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper`
                                        act = lo_json->get_string( `/MO_INNER_MO_DEEPER_MV_INNER` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `in-struc-tab`
                                        act = lo_json->get_string( `/MS_WITH_DREF_R_TAB_D/1/COL1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `a`
                                        act = lo_json->get_string( `/MR_HANDLE_NESTED_T_ITEMS/1/COL1` ) ).

  ENDMETHOD.

  METHOD dates_initial_or_broken.

    DATA(lo_app) = NEW ltcl_app_samples( ).
    DATA ls_row TYPE ltcl_app_samples=>ty_s_row.
    ls_row-id = 1.
    ls_row-descr = `initial`.
    APPEND ls_row TO lo_app->mt_rows.
    ls_row-id = 2.
    ls_row-descr = `zeros`.
    ls_row-adate = '00000000'.
    ls_row-atime = '000000'.
    APPEND ls_row TO lo_app->mt_rows.
    ls_row-id = 3.
    ls_row-descr = `valid`.
    ls_row-adate = '20240115'.
    ls_row-atime = '123045'.
    APPEND ls_row TO lo_app->mt_rows.
    ls_row-id = 4.
    ls_row-descr = `empty string moved in`.
    ls_row-adate = ``.
    ls_row-atime = ``.
    APPEND ls_row TO lo_app->mt_rows.

    DATA lt_attri TYPE z2ui5_if_ui5_types=>ty_t_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = REF #( lt_attri )
                                                 app   = lo_app ).
    DATA(lr_attri) = lo_model->main_attri_search( REF #( lo_app->mt_rows ) ).
    lr_attri->bind        = abap_true.
    lr_attri->name_client = `/MT_ROWS`.

    DATA(lv_json) = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"empty string moved in"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `2024-01-15` ) ).

  ENDMETHOD.

  METHOD markup_escaped.

    bind( REF #( mo_app->mv_markup ) ).
    DATA(lv_json) = mo_model->main_json_stringify( ).
    " parsed back, the value is what the attribute holds - quotes, angle
    " brackets, ampersand and the line break included
    DATA(lo_json) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( lv_json ) ).
    cl_abap_unit_assert=>assert_equals( exp = mo_app->mv_markup
                                        act = lo_json->get_string( `/MV_MARKUP` ) ).

  ENDMETHOD.

  METHOD json_bind_spliced.

    mo_app->mv_string = `{"_version":"1.0","sap.app":{"type":"card"},"sap.card":{"type":"List"}}`.
    DATA(lr_attri) = bind( REF #( mo_app->mv_string ) ).
    lr_attri->check_json = abap_true.

    DATA(lo_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ajson_types=>node_type-object
                                        act = lo_result->get_node_type( `/MV_STRING` )
                                        msg = `the raw JSON must become a node, not a quoted string` ).
    cl_abap_unit_assert=>assert_equals( exp = `card`
                                        act = lo_result->get_string( `/MV_STRING/sap.app/type` ) ).

  ENDMETHOD.

  METHOD json_bind_invalid_raises.

    mo_app->mv_string = `not json at all`.
    DATA(lr_attri) = bind( REF #( mo_app->mv_string ) ).
    lr_attri->check_json = abap_true.
    TRY.
        mo_model->main_json_stringify( ).
        cl_abap_unit_assert=>fail( `an unparseable json bind must raise` ).
      CATCH z2ui5_cx_ui5_util_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD filter_applied.

    " the behaviour behind _bind( omit_initial ): an INITIAL field stays
    " absent, so the control keeps its own default instead of receiving ``
    CLEAR mo_app->ms_flat-col1.
    mo_app->ms_flat-col2 = 7.
    DATA(lr_attri) = bind( REF #( mo_app->ms_flat ) ).
    lr_attri->custom_filter = NEW ltcl_shp_filter( ).

    DATA(lo_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = lo_result->get_integer( `/MS_FLAT/COL2` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->exists( `/MS_FLAT/COL1` )
                                        msg = `an initial field must stay ABSENT, not serialize as an empty string` ).

  ENDMETHOD.

  METHOD mapper_applied.

    DATA(lr_attri) = bind( REF #( mo_app->ms_flat ) ).
    lr_attri->custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ).

    DATA(lo_result) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( mo_model->main_json_stringify( ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `flat`
                                        act = lo_result->get_string( `/MS_FLAT/col1` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_result->exists( `/MS_FLAT/COL1` ) ).

  ENDMETHOD.

ENDCLASS.


" ---------------------------------------------------------------------------
" 04 MODEL IN - what the client sends back: whole values and row deltas
" ---------------------------------------------------------------------------
CLASS ltcl_04_model_in DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " a whole value, per form, written through every level
    METHODS whole_value_per_form     FOR TESTING RAISING cx_static_check.
    " what the client is not allowed to write
    METHODS unbound_not_written      FOR TESTING RAISING cx_static_check.
    METHODS json_bind_not_read_back  FOR TESTING RAISING cx_static_check.
    METHODS alias_written_once       FOR TESTING RAISING cx_static_check.
    " a scalar the type refuses keeps its value and is traced
    METHODS scalar_refused_traced    FOR TESTING RAISING cx_static_check.
    " markup and quotes come back as they went out
    METHODS markup_round_trips       FOR TESTING RAISING cx_static_check.
    " the whole model out and in again - the count the backend holds (199)
    METHODS whole_table_round_trips  FOR TESTING RAISING cx_static_check.
    " row deltas: which row, which cell, out of range
    METHODS delta_rows               FOR TESTING RAISING cx_static_check.
    " row deltas into the tables behind references and inside the helper
    METHODS delta_into_dref_table    FOR TESTING RAISING cx_static_check.
    METHODS delta_into_helper_table  FOR TESTING RAISING cx_static_check.
    " nested rows, structure cells, a replaced sub-table
    METHODS delta_nested             FOR TESTING RAISING cx_static_check.
    " typed cells: accepted, ISO dates, plain date, refused
    METHODS delta_typed_cells        FOR TESTING RAISING cx_static_check.
    " what the trace of a refused cell says
    METHODS delta_trace              FOR TESTING RAISING cx_static_check.
    " a table kind that takes no row delta
    METHODS delta_sorted_refused     FOR TESTING RAISING cx_static_check.
    " a column kind that takes no value of the shape the wire carries
    METHODS delta_kind_refused       FOR TESTING RAISING cx_static_check.
    " a delta over many rows with a refused cell and a refused nested table
    " in the middle: every good cell lands, the refused ones keep their
    " values and are traced, nothing else is touched
    METHODS delta_mass_edit          FOR TESTING RAISING cx_static_check.

    METHODS typed_app
      RETURNING
        VALUE(result) TYPE REF TO ltcl_app_typed.
    METHODS typed_model
      IMPORTING
        io_app        TYPE REF TO ltcl_app_typed
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_srv_model.
    METHODS tree_app
      RETURNING
        VALUE(result) TYPE REF TO ltcl_app_tree.
    METHODS delta
      IMPORTING
        iv_json       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson
      RAISING
        z2ui5_cx_ajson_error.
ENDCLASS.


CLASS ltcl_04_model_in IMPLEMENTATION.

  METHOD typed_app.

    result = NEW #( ).
    result->mt_tab = VALUE #( ( name  = `Notebook`
                                price = '1249.00'
                                t_pos = VALUE #( ( qty = 1 ) ) )
                              ( name  = `Monitor`
                                price = '299.00'
                                t_pos = VALUE #( ( qty = 2 ) ) ) ).

  ENDMETHOD.

  METHOD typed_model.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    result = NEW #( attri = lr_attri
                    app   = io_app ).

  ENDMETHOD.

  METHOD tree_app.

    result = NEW #( ).
    result->mt_tree = VALUE #( ( user    = `Manager`
                                 enabled = abap_false
                                 s_adr   = VALUE #( city = `Old Town`
                                                    zip  = `00000` )
                                 nodes   = VALUE #( ( user = `E1` validated = abap_false )
                                                    ( user = `E2` validated = abap_false ) ) ) ).

  ENDMETHOD.

  METHOD delta.

    result = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( iv_json ) ).

  ENDMETHOD.

  METHOD whole_value_per_form.

    bind_all( ).
    DATA(lo_front) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `updated` ).
    lo_front->set( iv_path = `/MV_INT`
                   iv_val  = 7 ).
    " a false is an EMPTY value to set( ) - it would be ignored
    lo_front->set_boolean( iv_path = `/MV_BOOL`
                           iv_val  = abap_false ).
    lo_front->set_boolean( iv_path = `/MS_DEEP_L1_L2_L3_V4`
                           iv_val  = abap_false ).
    lo_front->set( iv_path = `/MS_FLAT/COL1`
                   iv_val  = `written` ).
    lo_front->set( iv_path = `/MO_INNER_MO_DEEPER_MV_INNER`
                   iv_val  = `deeper-written` ).
    lo_front->set( iv_path = `/MR_ELEM_D`
                   iv_val  = `elem-written` ).
    lo_front->set( iv_path = `/MR_TYPED_STRUC_COL1`
                   iv_val  = `typed-written` ).
    lo_front->set( iv_path = `/MO_INNER_2_MV_INNER`
                   iv_val  = `inner-2-written` ).

    mo_model->main_json_to_attri( lo_front ).

    FIELD-SYMBOLS <elem> TYPE any.
    cl_abap_unit_assert=>assert_equals( exp = `updated`
                                        act = mo_app->mv_string ).
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = mo_app->mv_int ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->mv_bool ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = mo_app->ms_deep-l1-l2-l3-v4 ).
    cl_abap_unit_assert=>assert_equals( exp = `written`
                                        act = mo_app->ms_flat-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper-written`
                                        act = mo_app->mo_inner->mo_deeper->mv_inner ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `elem-written`
                                        act = <elem> ).
    cl_abap_unit_assert=>assert_equals( exp = `typed-written`
                                        act = mo_app->mr_typed_struc->col1 ).
    cl_abap_unit_assert=>assert_equals( exp = `inner-2-written`
                                        act = mo_app->mo_inner_2->mv_inner ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD unbound_not_written.

    mo_model->main_attri_refresh( ).
    DATA(lr_attri) = row_ref( `MV_STRING` ).
    lr_attri->bind        = abap_false.
    lr_attri->name_client = `/MV_STRING`.
    DATA(lo_front) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `should_not_update` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = mo_app->mv_string ).

  ENDMETHOD.

  METHOD json_bind_not_read_back.

    mo_app->mv_string = `{"sap.app":{"type":"card"}}`.
    DATA(lr_attri) = bind( REF #( mo_app->mv_string ) ).
    lr_attri->check_json = abap_true.
    DATA(lo_front) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `overwritten` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `{"sap.app":{"type":"card"}}`
                                        act = mo_app->mv_string
                                        msg = `a json bind must not be read back from the client model` ).

  ENDMETHOD.

  METHOD alias_written_once.

    " the same variable under two client paths: only the path the client
    " carries is written, the other entry is passed over
    DATA(lr_attri) = bind( REF #( mo_app->mv_string ) ).
    DATA(ls_extra) = lr_attri->*.
    ls_extra-name        = `MV_STRING_ALIAS`.
    ls_extra-name_client = `/ALIAS`.
    INSERT ls_extra INTO TABLE mr_attri->*.
    DATA(lo_front) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_front->set( iv_path = `/MV_STRING`
                   iv_val  = `once` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = `once`
                                        act = mo_app->mv_string ).

  ENDMETHOD.

  METHOD scalar_refused_traced.

    " `1,250.00` typed into an Input bound to a packed SCALAR: traced with
    " the attribute name, row 0 and the raw value, the old value kept
    bind( REF #( mo_app->mv_packed ) ).
    DATA(lo_front) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
    lo_front->set( iv_path = `/MV_PACKED`
                   iv_val  = `1,250.00` ).

    mo_model->main_json_to_attri( lo_front ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1234.56' )
                                        act = CONV decfloat34( mo_app->mv_packed ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_PACKED`
                                        act = mo_model->mt_skipped[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = mo_model->mt_skipped[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = mo_model->mt_skipped[ 1 ]-value ).

  ENDMETHOD.

  METHOD markup_round_trips.

    bind( REF #( mo_app->mv_markup ) ).
    DATA(lv_out) = mo_model->main_json_stringify( ).
    DATA(lv_before) = mo_app->mv_markup.
    CLEAR mo_app->mv_markup.

    mo_model->main_json_to_attri( CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( lv_out ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_app->mv_markup ).

  ENDMETHOD.

  METHOD whole_table_round_trips.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row TYPE ltcl_app_shapes=>ty_s_row.

    bind( mo_app->mr_typed_tab ).
    " the backend appends two rows and ships the table...
    ls_row-col1 = `second`.
    APPEND ls_row TO mo_app->mr_typed_tab->*.
    ls_row-col1 = `third`.
    APPEND ls_row TO mo_app->mr_typed_tab->*.
    DATA(lv_json) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS `"third"` ) ).

    " ...the client sends the whole table back with its next event, and the
    " backend holds exactly what it shipped
    CLEAR mo_app->mr_typed_tab->*.
    mo_model->main_json_to_attri( CAST z2ui5_if_ajson( z2ui5_cl_ajson=>parse( lv_json ) ) ).
    ASSIGN mo_app->mr_typed_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `third`
                                        act = mo_app->mr_typed_tab->*[ 3 ]-col1 ).

  ENDMETHOD.

  METHOD delta_rows.

    bind( REF #( mo_app->mt_std ) ).

    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"0":{"COL1":"X"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = mo_app->mt_std[ 1 ]-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = mo_app->mt_std[ 1 ]-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = mo_app->mt_std[ 2 ]-col1 ).

    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"1":{"COL2":9}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = mo_app->mt_std[ 2 ]-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = `b`
                                        act = mo_app->mt_std[ 2 ]-col1 ).

    " out of range, garbled and negative indexes: no crash, table unchanged
    mo_model->main_json_to_attri( delta( `{"MT_STD":{"__delta":{"5":{"COL1":"Z"},"x":{"COL1":"Z"},"-1":{"COL1":"Z"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).
    cl_abap_unit_assert=>assert_equals( exp = `X`
                                        act = mo_app->mt_std[ 1 ]-col1 ).

  ENDMETHOD.

  METHOD delta_into_dref_table.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <col> TYPE any.

    " the runtime-built table behind a generic reference (samples 339, 344)
    DATA(lr_attri) = bind( mo_app->mr_handle_tab ).
    DATA(lv_key) = substring( val = lr_attri->name_client
                              off = 1 ).
    mo_model->main_json_to_attri( delta( |\{"{ lv_key }":\{"__delta":\{"1":\{"COL1":"edited"\}\}\}\}| ) ).

    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO <col>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `edited`
                                        act = <col> ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_into_helper_table.

    " the table inside the helper object (the layout rows of sample 332)
    bind( REF #( mo_app->mo_inner->mt_own ) ).
    mo_model->main_json_to_attri( delta( `{"MO_INNER_MT_OWN":{"__delta":{"0":{"COL1":"own-edited","COL2":6}}}}` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `own-edited`
                                        act = mo_app->mo_inner->mt_own[ 1 ]-col1 ).
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = mo_app->mo_inner->mt_own[ 1 ]-col2 ).
    cl_abap_unit_assert=>assert_initial( mo_model->mt_skipped ).

  ENDMETHOD.

  METHOD delta_nested.

    DATA(lo_app) = tree_app( ).
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_app ).

    " a cell inside the nested table, a root cell next to it
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"ENABLED":true,"NODES":{"__delta":{"1":{"VALIDATED":true}}}}}}` )
                                    iv_name      = `MT_TREE` ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mt_tree[ 1 ]-enabled ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 2 ]-validated ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-validated ).
    cl_abap_unit_assert=>assert_equals( exp = `Manager`
                                        act = lo_app->mt_tree[ 1 ]-user ).

    " a structure cell ships whole
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"S_ADR":{"CITY":"Berlin","ZIP":"10115"}}}}` )
                                    iv_name      = `MT_TREE` ).
    cl_abap_unit_assert=>assert_equals( exp = `Berlin`
                                        act = lo_app->mt_tree[ 1 ]-s_adr-city ).

    " a whole sub-table value replaces the nested table
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"NODES":[{"USER":"NEW","VALIDATED":true}]}}}` )
                                    iv_name      = `MT_TREE` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->mt_tree[ 1 ]-nodes ) ).
    cl_abap_unit_assert=>assert_equals( exp = `NEW`
                                        act = lo_app->mt_tree[ 1 ]-nodes[ 1 ]-user ).

  ENDMETHOD.

  METHOD delta_typed_cells.

    DATA(lo_app) = typed_app( ).
    DATA(lo_model) = typed_model( lo_app ).

    " accepted
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"1250.00"}}}` )
                                    iv_name      = `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1250.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " the ISO spelling ajson wrote, and a plain date
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"DT":"2024-01-15","TM":"12:30:45","TS":"2024-01-15T12:30:45Z"},"1":{"DT":"20240115","TM":""}}}` )
                                    iv_name      = `MT_TAB` ).
    DATA lv_date TYPE d.
    lv_date = '20240115'.
    DATA lv_time TYPE t.
    lv_time = '123045'.
    DATA lv_ts TYPE timestamp.
    lv_ts = '20240115123045'.
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = lo_app->mt_tab[ 1 ]-dt ).
    cl_abap_unit_assert=>assert_equals( exp = lv_time
                                        act = lo_app->mt_tab[ 1 ]-tm ).
    cl_abap_unit_assert=>assert_equals( exp = lv_ts
                                        act = lo_app->mt_tab[ 1 ]-ts ).
    cl_abap_unit_assert=>assert_equals( exp = lv_date
                                        act = lo_app->mt_tab[ 2 ]-dt ).
    cl_abap_unit_assert=>assert_initial( lo_app->mt_tab[ 2 ]-tm ).
    cl_abap_unit_assert=>assert_initial( lo_model->mt_skipped ).

    " refused: the grouped thousands separator, text into a number - the
    " old value stands (on a system the failed conversion clears the target
    " first; the copy in delta_apply_field puts it back), the good cell in
    " the same delta lands, a field that is not in the delta is no finding
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"abc","NAME":"Laptop","NOT_A_COMPONENT":"x"},"1":{"PRICE":"1,250.00"}}}` )
                                    iv_name      = `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '1250.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Laptop`
                                        act = lo_app->mt_tab[ 1 ]-name ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '299.00' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 2 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).

  ENDMETHOD.

  METHOD delta_trace.

    DATA(lo_app) = typed_app( ).
    DATA(lo_model) = typed_model( lo_app ).

    " a top-level cell: name, row, field, the raw value, no parent
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"1":{"PRICE":"1,250.00"}}}` )
                                    iv_name      = `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_model->mt_skipped ) ).
    DATA(ls_skip) = lo_model->mt_skipped[ 1 ].
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = `PRICE`
                                        act = ls_skip-field ).
    cl_abap_unit_assert=>assert_equals( exp = `1,250.00`
                                        act = ls_skip-value ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = ls_skip-row_parent ).

    " a nested cell under the SECOND outer row: the path parent first, the
    " row inside the inner table, the outer record as row_parent
    CLEAR lo_model->mt_skipped.
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"1":{"T_POS":{"__delta":{"0":{"QTY":"many"}}}}}}` )
                                    iv_name      = `MT_TAB` ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_app->mt_tab[ 2 ]-t_pos[ 1 ]-qty ).
    ls_skip = lo_model->mt_skipped[ 1 ].
    cl_abap_unit_assert=>assert_equals( exp = `MT_TAB-T_POS`
                                        act = ls_skip-name ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = ls_skip-row ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_skip-row_parent ).
    cl_abap_unit_assert=>assert_equals( exp = `many`
                                        act = ls_skip-value ).

  ENDMETHOD.

  METHOD delta_sorted_refused.

    DATA(lo_app) = typed_app( ).
    INSERT VALUE #( name = `Monitor` price = '299.00' ) INTO TABLE lo_app->mt_sorted.
    DATA(lo_model) = typed_model( lo_app ).

    " a sorted table takes no row delta - every cell of it is traced, the
    " table untouched (decided by RTTI: the ASSIGN to a standard-table field
    " symbol is a runtime error on a system)
    lo_model->delta_apply_to_table( io_val_front = delta( `{"__delta":{"0":{"PRICE":"1250.00","NAME":"Screen"}}}` )
                                    iv_name      = `MT_SORTED` ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '299.00' )
                                        act = CONV decfloat34( lo_app->mt_sorted[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_SORTED`
                                        act = lo_model->mt_skipped[ 1 ]-name ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( lo_model->mt_skipped[ field = `PRICE` value = `1250.00` ] ) ) ).

    " the same for the fixture's sorted table, through the model path
    bind( REF #( mo_app->mt_sorted ) ).
    mo_model->main_json_to_attri( delta( `{"MT_SORTED":{"__delta":{"0":{"COL2":1}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = mo_app->mt_sorted[ 1 ]-col2 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).

  ENDMETHOD.


  METHOD delta_kind_refused.

    " a cell whose column takes no value of the shape the wire carries is
    " traced and left alone, never assigned: a string into a REF TO data or
    " a scalar into a nested table is no class-based exception on a system
    " but a runtime error, so the skip has to be decided up front. The
    " reference cell needs no crafted request - ajson ships it as its plain
    " value, and an Input bound to it sends a string back
    bind( REF #( mo_app->mt_rows_ref ) ).
    DATA(lr_before) = mo_app->mt_rows_ref[ 1 ]-r_elem.
    mo_model->main_json_to_attri( delta( `{"MT_ROWS_REF":{"__delta":{"0":{"R_ELEM":"x"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `R_ELEM`
                                        act = mo_model->mt_skipped[ 1 ]-field ).
    cl_abap_unit_assert=>assert_equals( exp = `x`
                                        act = mo_model->mt_skipped[ 1 ]-value ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_app->mt_rows_ref[ 1 ]-r_elem = lr_before ) ).
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = mo_app->mt_rows_ref[ 1 ]-r_elem->* ).

    " a scalar into a nested table column, next to a digit-only key that
    " would address a component by position: the first is traced, the
    " second skipped, the row is untouched
    CLEAR mo_model->mt_skipped.
    bind( REF #( mo_app->mt_nested ) ).
    mo_model->main_json_to_attri( delta( `{"MT_NESTED":{"__delta":{"0":{"T_ITEMS":"x","0":"y"}}}}` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_equals( exp = `T_ITEMS`
                                        act = mo_model->mt_skipped[ 1 ]-field ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_app->mt_nested[ 1 ]-t_items ) ).
    cl_abap_unit_assert=>assert_equals( exp = `n1`
                                        act = mo_app->mt_nested[ 1 ]-id ).

  ENDMETHOD.

  METHOD delta_mass_edit.

    DATA(lo_app) = NEW ltcl_app_typed( ).
    DO 6 TIMES.
      APPEND VALUE #( name     = |row-{ sy-index }|
                      price    = sy-index * 100
                      t_pos    = VALUE #( ( qty = sy-index ) )
                      t_sorted = VALUE #( ( qty = 1 ) ) ) TO lo_app->mt_tab.
    ENDDO.
    DATA(lo_model) = typed_model( lo_app ).

    " the select-all shape: one cell in every row - plus a price that does
    " not convert in the third, a nested standard-table cell under the
    " fourth and a nested SORTED table under the fifth
    DATA(lv_json) = `{"__delta":{`.
    DO 6 TIMES.
      IF sy-index > 1.
        lv_json = lv_json && `,`.
      ENDIF.
      lv_json = lv_json && |"{ sy-index - 1 }":\{"NAME":"edited-{ sy-index }"|.
      CASE sy-index.
        WHEN 3.
          lv_json = lv_json && `,"PRICE":"1,250.00"`.
        WHEN 4.
          lv_json = lv_json && `,"T_POS":{"__delta":{"0":{"QTY":"9"}}}`.
        WHEN 5.
          lv_json = lv_json && `,"T_SORTED":{"__delta":{"0":{"QTY":"5"}}}`.
        WHEN OTHERS.
          lv_json = lv_json && |,"PRICE":"{ sy-index * 10 }.50"|.
      ENDCASE.
      lv_json = lv_json && `}`.
    ENDDO.
    lv_json = lv_json && `}}`.

    lo_model->delta_apply_to_table( io_val_front = delta( lv_json )
                                    iv_name      = `MT_TAB` ).

    " every name landed, the good prices too
    DO 6 TIMES.
      cl_abap_unit_assert=>assert_equals( exp = |edited-{ sy-index }|
                                          act = lo_app->mt_tab[ sy-index ]-name ).
    ENDDO.
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '10.50' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 1 ]-price ) ).
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '60.50' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 6 ]-price ) ).
    " the refused price keeps its value - the good name in the SAME row was
    " written
    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '300' )
                                        act = CONV decfloat34( lo_app->mt_tab[ 3 ]-price ) ).
    " the nested standard table took its cell, the nested sorted one did not
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = lo_app->mt_tab[ 4 ]-t_pos[ 1 ]-qty ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_app->mt_tab[ 5 ]-t_sorted[ 1 ]-qty ).
    " a cell the delta did not name is untouched, and no row came or went
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lo_app->mt_tab[ 2 ]-t_pos[ 1 ]-qty ).
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = lines( lo_app->mt_tab ) ).

    " exactly the two refusals are traced, each naming its cell
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_model->mt_skipped ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( lo_model->mt_skipped[ name  = `MT_TAB`
                                                                                 row   = 3
                                                                                 field = `PRICE`
                                                                                 value = `1,250.00` ] ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( lo_model->mt_skipped[ name       = `MT_TAB-T_SORTED`
                                                                                 row        = 1
                                                                                 row_parent = 5
                                                                                 field      = `QTY`
                                                                                 value      = `5` ] ) ) ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 05 DRAFT - the state across the draft: save, restore, the next render
" ---------------------------------------------------------------------------
CLASS ltcl_05_draft DEFINITION INHERITING FROM ltcl_00_base FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    " the save detaches the generic references, the restore in place brings
    " them back - the roundtrip that is in flight goes on rendering
    METHODS save_restore_in_place    FOR TESTING RAISING cx_static_check.
    " the draft read into a NEW instance, and the render after that
    METHODS roundtrip_new_instance   FOR TESTING RAISING cx_static_check.
    METHODS second_roundtrip_clean   FOR TESTING RAISING cx_static_check.
    " the payload lives on the canonical row - also when that row is in the
    " nested object (sample 339 with the sort order turned around)
    METHODS payload_on_canonical_row FOR TESTING RAISING cx_static_check.
    " what does NOT survive, quietly
    METHODS dead_objects_stay_quiet  FOR TESTING RAISING cx_static_check.
    " what has to survive, loudly if it cannot
    METHODS broken_payload_bound_loud  FOR TESTING RAISING cx_static_check.
    METHODS broken_payload_unbound_ok  FOR TESTING RAISING cx_static_check.
    " the draft outlives the class
    METHODS attribute_gone_skipped   FOR TESTING RAISING cx_static_check.
    METHODS attribute_new_found      FOR TESTING RAISING cx_static_check.
    " the host swapped its sub-app's class (sample 338), before and after
    METHODS class_swap_before_load   FOR TESTING RAISING cx_static_check.
    METHODS class_swap_after_load    FOR TESTING RAISING cx_static_check.
    " what a bind carries survives: mapper, filter, json flag
    METHODS bind_options_survive     FOR TESTING RAISING cx_static_check.
    " values with markup survive both serializations
    METHODS markup_survives          FOR TESTING RAISING cx_static_check.
    " a cell binding on the restored instance (sample 332)
    METHODS cell_bind_after_restore  FOR TESTING RAISING cx_static_check.
    " the forms the samples never had: interface ref, table of objects
    METHODS interface_and_obj_table  FOR TESTING RAISING cx_static_check.
    " S13 - skipped in Node (CREATE DATA ... TYPE REF TO data)
    METHODS dref_chain_survives      FOR TESTING RAISING cx_static_check.
    " a draft written before the rows carried their type name loads, binds
    " and saves like one of this version
    METHODS legacy_draft_no_type_name FOR TESTING RAISING cx_static_check.
    " the LIVE instance across two roundtrips, no draft read in between (a
    " sticky session): main( ) creates its references again - the same type,
    " and another one - and the next render, model and draft follow
    METHODS live_recreated_same_type   FOR TESTING RAISING cx_static_check.
    METHODS live_recreated_other_type  FOR TESTING RAISING cx_static_check.
    " a save that no main( ) preceded changes neither the rows nor the data
    METHODS save_without_main_is_noop  FOR TESTING RAISING cx_static_check.
    " a helper created late, holding a reference INTO the app: bound after
    " the fact it binds as the owner, and the save keeps it that way
    METHODS late_alias_survives_save   FOR TESTING RAISING cx_static_check.
    " a reference pointed at ANOTHER attribute between two roundtrips, and
    " one of three shared references pointed at a table of its own: the
    " draft follows the new targets, not the owners of the first pass
    METHODS alias_repointed_survives   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_05_draft IMPLEMENTATION.

  METHOD save_restore_in_place.

    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_bound( act = mo_app->mr_handle_tab
                                           msg = `the save must detach the generic reference` ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mo_inner->mr_shared ).
    " EVERY data reference is detached, the typed ones too - S-RTTI carries
    " them all; typed attributes are not touched, asXML carries them
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_typed_tab ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `text`
                                        act = mo_app->mv_string ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( mo_app->mt_std ) ).

    mo_model->main_attri_db_load( ).
    inv_all( lv_before ).

  ENDMETHOD.

  METHOD roundtrip_new_instance.

    FIELD-SYMBOLS <tab>    TYPE STANDARD TABLE.
    FIELD-SYMBOLS <nested> TYPE any.

    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    roundtrip( ).
    inv_all( lv_before ).

    " the data behind the rows, not only the rows
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).
    ASSIGN mo_app->ms_with_dref-r_tab->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_equals( exp = `typed-elem`
                                        act = mo_app->mr_typed_elem->* ).
    cl_abap_unit_assert=>assert_equals( exp = `deeper`
                                        act = mo_app->mo_inner->mo_deeper->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `in-struc`
                                        act = mo_app->ms_with_oref-o_obj->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `cell-ref`
                                        act = mo_app->mt_rows_ref[ 1 ]-r_elem->* ).
    cl_abap_unit_assert=>assert_equals( exp = `cell-obj`
                                        act = mo_app->mt_rows_ref[ 1 ]-o_obj->mv_inner ).
    cl_abap_unit_assert=>assert_equals( exp = `protected`
                                        act = mo_app->get_protected( ) ).
    " the rows of the descriptor table survive, the descriptors they held do
    " not (an RTTI descriptor is not serializable), and neither is an error
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( mo_app->mt_comp ) ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mt_comp[ 1 ]-type ).
    ASSIGN mo_app->mr_handle_nested->* TO <nested>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <nested> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD second_roundtrip_clean.

    bind_all( ).
    roundtrip( ).
    DATA(lv_second) = mo_model->main_json_stringify( ).

    " the restored instance changes its data through the helper's reference
    " (sample 335) before the next draft; the change reaches the model of
    " the roundtrip after that, and the references stay one
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    ASSIGN mo_app->mo_inner->mr_shared->* TO <tab>.
    ls_sel-col1 = `appended after the restore`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    DATA(lv_changed) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_differs( exp = lv_second
                                         act = lv_changed ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_changed CS `"appended after the restore"` ) ).

    roundtrip( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD payload_on_canonical_row.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    DATA ls_row TYPE ltcl_shp_inner=>ty_s_row.

    " the fixture's own shared table: the canonical row is MR_SHARED_B->*
    bind( mo_app->mr_shared_a ).
    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_B` )-srtti_data ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_A` )-srtti_data ).
    cl_abap_unit_assert=>assert_initial( row( `MO_INNER->MR_SHARED` )-srtti_data ).
    mo_model->main_attri_db_load( ).
    inv_identity_shared( ).

    " and the app where the nested reference sorts LAST: the payload lives
    " on the nested object's row and the outer references are re-pointed
    " from there
    DATA(lo_app) = NEW ltcl_app_shared_last( ).
    lo_app->mz_inner = NEW #( ).
    DATA(lo_tab) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( lo_app->mz_inner->mt_own ) ).
    CREATE DATA lo_app->mr_table TYPE HANDLE lo_tab.
    ASSIGN lo_app->mr_table->* TO <tab>.
    ls_row-col1 = `shared`.
    INSERT ls_row INTO TABLE <tab>.
    lo_app->mr_table_tmp = lo_app->mr_table.
    lo_app->mz_inner->mr_shared = lo_app->mr_table.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_app ).
    DATA(ls_bind) = lo_model->main_attri_search( lo_app->mr_table ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MR_TABLE`.
    cl_abap_unit_assert=>assert_equals( exp = `MZ_INNER->MR_SHARED->*`
                                        act = ls_bind->name ).
    DATA(lv_before) = lo_model->main_json_stringify( ).

    lo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_not_initial( lr_attri->*[ name = `MZ_INNER->MR_SHARED` ]-srtti_data ).
    cl_abap_unit_assert=>assert_initial( lr_attri->*[ name = `MR_TABLE` ]-srtti_data ).

    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    lo_model = NEW #( attri = lr_attri
                      app   = lo_app ).
    lo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lo_app->mr_table = lo_app->mr_table_tmp ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_app->mr_table = lo_app->mz_inner->mr_shared ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD dead_objects_stay_quiet.

    bind_all( ).
    roundtrip( ).

    " S15 - not serializable, so gone; and nothing raised on the way
    cl_abap_unit_assert=>assert_not_bound( mo_app->mo_dead ).
    " the row it left behind carries no descriptor and is skipped by the
    " search instead of dumping it
    cl_abap_unit_assert=>assert_not_bound( row( `MO_DEAD->MV_TEXT` )-o_typedescr ).
    DATA(lr_attri) = mo_model->main_attri_search( REF #( mo_app->mv_string ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_STRING`
                                        act = lr_attri->name ).
    " a refresh drops the orphan rows for good
    mo_model->main_attri_refresh( ).
    cl_abap_unit_assert=>assert_false( row_exists( `MO_DEAD->MV_TEXT` ) ).

  ENDMETHOD.

  METHOD broken_payload_bound_loud.

    " the payload of a BOUND table is not what S-RTTI wrote (a system
    " upgrade, a type change): the load says so - the alternative was an
    " app running on a cleared reference and a view that comes back empty
    bind( mo_app->mr_handle_tab ).
    mo_model->main_attri_db_save_srtti( ).
    DATA(lr_payload) = row_ref( `MR_HANDLE_TAB` ).
    lr_payload->srtti_data = `this is not the serialized type`.

    TRY.
        mo_model->main_attri_db_load( ).
        cl_abap_unit_assert=>fail( `a failed restore of BOUND data must not pass silently` ).
      CATCH z2ui5_cx_ui5_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `APP_STATE_RESTORE_ERROR` ) ).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS `MR_HANDLE_TAB` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD broken_payload_unbound_ok.

    " nothing reads it, so it keeps the lenient treatment - the payload
    " stays on the row (only a SUCCESSFUL restore clears it), the reference
    " the save cleared stays unbound, everything else is restored
    bind( REF #( mo_app->mv_string ) ).
    mo_model->main_attri_db_save_srtti( ).
    DATA(lr_broken) = row_ref( `MR_ELEM` ).
    lr_broken->srtti_data = `this is not the serialized type`.

    mo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_not_initial( row( `MR_ELEM` )-srtti_data ).
    cl_abap_unit_assert=>assert_not_bound( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_handle_tab ).

  ENDMETHOD.

  METHOD attribute_gone_skipped.

    " the class lost an attribute since the draft was written: its rows are
    " skipped by every restore step, the rest comes back, and a bind on
    " what is left works
    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).
    mo_model->main_attri_db_save_srtti( ).
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    " the rows of the attribute that is gone: a plain one, and a dref with
    " a payload nobody can put anywhere
    INSERT VALUE #( name            = `MV_GONE`
                    check_dissolved = abap_true
                    type_kind       = row( `MV_STRING` )-type_kind
                    kind            = row( `MV_STRING` )-kind
                    bind            = abap_true
                    name_client     = `/MV_GONE` ) INTO TABLE mr_attri->*.
    INSERT VALUE #( name            = `MR_GONE`
                    check_dissolved = abap_true
                    type_kind       = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_dref
                    srtti_data      = `payload of a reference nobody has` ) INTO TABLE mr_attri->*.
    INSERT VALUE #( name            = `MR_GONE->*`
                    name_parent     = `MR_GONE`
                    check_dissolved = abap_true
                    type_kind       = z2ui5_cl_ui5_util_context=>cv_typedescr_typekind_table
                    name_ref        = `MR_SHARED_B->*` ) INTO TABLE mr_attri->*.

    model_renew( ).
    mo_model->main_attri_db_load( ).

    inv_identity_shared( ).
    inv_search_finds_bound( ).
    " the model is the old one - MV_GONE has no value to ship
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD attribute_new_found.

    " the class gained an attribute since the draft was written: it has no
    " row yet, and the first bind on it finds it through a refresh - with
    " every earlier bind kept
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( mo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( mr_attri->* ).
    CLEAR mo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = mo_app ).
    CREATE DATA mr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = mr_attri->* ).
    DELETE mr_attri->* WHERE name = `MV_XSTR`.
    model_renew( ).
    mo_model->main_attri_db_load( ).

    DATA(lr_attri) = mo_model->main_attri_search( REF #( mo_app->mv_xstr ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_XSTR`
                                        act = lr_attri->name ).
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD class_swap_before_load.

    " roundtrip 1: the host renders sub-app A and binds A's table
    DATA(lo_host) = NEW ltcl_app_host( ).
    DATA(lo_a) = NEW ltcl_shp_sub_a( ).
    lo_a->mo_layout = NEW #( ).
    lo_a->fill( ).
    lo_host->mo_app = lo_a.
    lo_host->mv_selectedkey = `1`.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_host ).
    DATA(ls_bind) = lo_model->main_attri_search( REF #( lo_host->mv_selectedkey ) ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MV_SELECTEDKEY`.
    ls_bind = lo_model->main_attri_search( lo_a->mt_table ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_TABLE->*`
                                        act = ls_bind->name ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_TABLE`.

    " roundtrip 2: the host holds sub-app B, whose attributes have OTHER
    " names, when the draft is restored. The rows of A resolve to nothing
    " and keep no descriptor - the restore must not raise over them
    lo_model->main_attri_db_save_srtti( ).
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_host ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_host ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    DATA(lo_b) = NEW ltcl_shp_sub_b( ).
    lo_b->mo_lay = NEW #( ).
    lo_b->fill( ).
    lo_host->mo_app = lo_b.
    lo_model = NEW #( attri = lr_attri
                      app   = lo_host ).
    lo_model->main_attri_db_load( ).
    cl_abap_unit_assert=>assert_not_bound( lr_attri->*[ name = `MO_APP->MO_LAYOUT->MV_INNER` ]-o_typedescr ).

    " the host's own bind first - it walks the A rows of its own kind and
    " used to dump on the first one without a descriptor
    ls_bind = lo_model->main_attri_search( REF #( lo_host->mv_selectedkey ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MV_SELECTEDKEY`
                                        act = ls_bind->name ).
    " then B's table: not in mt_attri, so the search refreshes and finds it
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).
    " the refresh dropped A's rows - nothing of the old class lingers
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( lr_attri->*[ name = `MO_APP->MT_TABLE->*` ] ) ) ).

  ENDMETHOD.

  METHOD class_swap_after_load.

    " the same switch AFTER the restore (the sample's own order: restore,
    " then the tab event creates B), and the draft roundtrip that follows
    DATA(lo_host) = NEW ltcl_app_host( ).
    DATA(lo_a) = NEW ltcl_shp_sub_a( ).
    lo_a->mo_layout = NEW #( ).
    lo_a->fill( ).
    lo_host->mo_app = lo_a.

    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_host ).
    DATA(ls_bind) = lo_model->main_attri_search( lo_a->mt_table ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_TABLE`.

    lo_model->main_attri_db_save_srtti( ).
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_host ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_host ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    lo_model = NEW #( attri = lr_attri
                      app   = lo_host ).
    lo_model->main_attri_db_load( ).

    DATA(lo_b) = NEW ltcl_shp_sub_b( ).
    lo_b->mo_lay = NEW #( ).
    lo_b->fill( ).
    lo_host->mo_app = lo_b.
    ls_bind = lo_model->main_attri_search( lo_b->mt_data ).
    ls_bind->bind = abap_true.
    ls_bind->name_client = `/MO_APP_MT_DATA`.
    DATA(lv_before) = lo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `"MO_APP_MT_DATA"` ) ).

    lo_model->main_attri_db_save_srtti( ).
    lv_app_xml   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_host ).
    lv_attri_xml = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_host.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_host ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    lo_model = NEW #( attri = lr_attri
                      app   = lo_host ).
    lo_model->main_attri_db_load( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = lo_model->main_json_stringify( ) ).
    DATA lo_b_restored TYPE REF TO ltcl_shp_sub_b.
    lo_b_restored ?= lo_host->mo_app.
    cl_abap_unit_assert=>assert_bound( lo_b_restored->mt_data ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_b_restored->mt_data = lo_b_restored->mo_lay->mr_shared ) ).
    ls_bind = lo_model->main_attri_search( lo_b_restored->mt_data ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_APP->MT_DATA->*`
                                        act = ls_bind->name ).

  ENDMETHOD.

  METHOD bind_options_survive.

    " mapper, filter and the json flag travel in mt_attri - a filter class
    " that is not serializable would be the app's fault (srv_bind refuses
    " it at bind time), a mapper always serializes
    CLEAR mo_app->ms_flat-col1.
    DATA(lr_flat) = bind( REF #( mo_app->ms_flat ) ).
    lr_flat->custom_filter = NEW ltcl_shp_filter( ).
    lr_flat->custom_mapper = z2ui5_cl_ajson_mapping=>create_lower_case( ).
    mo_app->mv_string = `{"sap.app":{"type":"card"}}`.
    DATA(lr_json) = bind( REF #( mo_app->mv_string ) ).
    lr_json->check_json = abap_true.
    DATA(lv_before) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_before CS `"col2"` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_before CS `"col1"` ) ).

    roundtrip( ).

    cl_abap_unit_assert=>assert_bound( row( `MS_FLAT` )-custom_filter ).
    cl_abap_unit_assert=>assert_bound( row( `MS_FLAT` )-custom_mapper ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = row( `MV_STRING` )-check_json ).
    cl_abap_unit_assert=>assert_equals( exp = lv_before
                                        act = mo_model->main_json_stringify( ) ).

  ENDMETHOD.

  METHOD markup_survives.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.

    " markup in a typed attribute (asXML) and in a cell of the runtime-built
    " table (S-RTTI inside asXML) - both serializations escape and unescape
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    ls_sel-col1 = mo_app->mv_markup.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    bind( REF #( mo_app->mv_markup ) ).
    bind( mo_app->mr_handle_tab ).
    DATA(lv_before) = mo_model->main_json_stringify( ).
    DATA(lv_markup) = mo_app->mv_markup.

    roundtrip( ).

    cl_abap_unit_assert=>assert_equals( exp = lv_markup
                                        act = mo_app->mv_markup ).
    inv_json_unchanged( lv_before ).

  ENDMETHOD.

  METHOD cell_bind_after_restore.

    bind_all( ).
    roundtrip( ).

    " the binder works on the container: the restored app and the restored
    " attribute table, exactly what the next render's _bind( ) sees
    DATA(lo_cont) = NEW z2ui5_cl_ui5_app_cont( ).
    lo_cont->mo_app   = mo_app.
    lo_cont->mt_attri = mr_attri.
    DATA(lo_bind) = NEW z2ui5_cl_ui5_srv_bind( lo_cont ).

    " row 1 of the helper's own table, the layout row of sample 332
    DATA(lr_row) = REF #( mo_app->mo_inner->mt_own[ 1 ] ).
    DATA(lv_path) = lo_bind->main( val    = REF #( lr_row->col1 )
                                   config = VALUE #( tab       = REF #( mo_app->mo_inner->mt_own )
                                                     tab_index = 1 ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{/MO_INNER_MT_OWN/0/COL1}`
                                        act = lv_path ).

    " ...and a cell of the runtime-built table behind the generic reference
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    ASSIGN mo_app->mr_handle_tab->* TO <tab>.
    READ TABLE <tab> INDEX 2 ASSIGNING <row>.
    cl_abap_unit_assert=>assert_subrc( ).
    ASSIGN COMPONENT `COL1` OF STRUCTURE <row> TO FIELD-SYMBOL(<cell>).
    cl_abap_unit_assert=>assert_subrc( ).
    lv_path = lo_bind->main( val    = REF #( <cell> )
                             config = VALUE #( tab       = mo_app->mr_handle_tab
                                               tab_index = 2 ) ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lv_path CP `{/*/1/COL1}` )
                                      msg = |cell path after restore: { lv_path }| ).

  ENDMETHOD.

  METHOD interface_and_obj_table.

    DATA(lo_other) = NEW ltcl_app_shapes( ).
    lo_other->mv_string = `other`.
    mo_app->mi_app = lo_other.
    bind( REF #( lo_other->mv_string ) ).
    bind( REF #( mo_app->mv_string ) ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    roundtrip( ).

    " S28 - the interface-typed reference and the instance behind it
    DATA lo_restored TYPE REF TO ltcl_app_shapes.
    lo_restored ?= mo_app->mi_app.
    cl_abap_unit_assert=>assert_equals( exp = `other`
                                        act = lo_restored->mv_string ).
    " S29 - the table of objects, row by row
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( mo_app->mt_apps ) ).
    cl_abap_unit_assert=>assert_equals( exp = `in-table`
                                        act = mo_app->mt_apps[ 1 ]->mv_inner ).
    inv_json_unchanged( lv_before ).
    inv_search_finds_bound( ).

  ENDMETHOD.

  METHOD dref_chain_survives.

    FIELD-SYMBOLS <inner> TYPE REF TO data.
    FIELD-SYMBOLS <elem>  TYPE any.

    " S13 - the value behind mr_ref_ref->*->* is data like any other; the
    " dref save cleared the outer reference and never restored it. Built
    " here and not in fill( ): the NodeJS runtime cannot CREATE DATA a
    " REF TO data object, so this one test is skipped there (see
    " node/setup/abap_transpile.json) while the catalogue stays runnable
    CREATE DATA mo_app->mr_ref_ref TYPE REF TO data.
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    CREATE DATA <inner> TYPE string.
    ASSIGN <inner>->* TO <elem>.
    <elem> = `ref-ref`.

    bind( <inner> ).
    cl_abap_unit_assert=>assert_true( row_exists( `MR_REF_REF->*->*` ) ).
    roundtrip( ).

    cl_abap_unit_assert=>assert_bound( act = mo_app->mr_ref_ref
                                       msg = `S13: the outer reference was lost` ).
    ASSIGN mo_app->mr_ref_ref->* TO <inner>.
    cl_abap_unit_assert=>assert_bound( act = <inner>
                                       msg = `S13: the inner reference was lost` ).
    ASSIGN <inner>->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `ref-ref`
                                        act = <elem> ).
    inv_search_finds_bound( ).

  ENDMETHOD.


  METHOD alias_repointed_survives.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA lr_own TYPE REF TO data.

    " roundtrip 1: the alias into mt_std, the shared trio, as the fixture
    " has them
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).

    " main( ) of roundtrip 2: the alias points INTO the helper's table now,
    " the first of the shared references at a table of its own
    mo_app->mr_alias_tab = REF #( mo_app->mo_inner->mt_own ).
    DATA(lo_tab) = CAST cl_abap_tabledescr( z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( mo_app->mr_shared_b ) ).
    CREATE DATA lr_own TYPE HANDLE lo_tab.
    ASSIGN lr_own->* TO <tab>.
    ls_sel-col1 = `own`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mo_app->mr_shared_a = lr_own.

    " the render: the alias binds as its NEW owner, the parted reference
    " as a row of its own
    DATA(lr_alias) = bind( mo_app->mr_alias_tab ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MT_OWN`
                                        act = lr_alias->name ).
    DATA(lr_own_row) = bind( mo_app->mr_shared_a ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_A->*`
                                        act = lr_own_row->name ).
    DATA(lv_changed) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_changed CS `"own"` ) ).

    " the save: the rows say what the references say now - the typed table
    " stays the owner, the reference the alias; the parted one carries a
    " payload of its own
    mo_model->main_attri_db_save_srtti( ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MT_OWN`
                                        act = row( `MR_ALIAS_TAB->*` )-name_ref ).
    cl_abap_unit_assert=>assert_initial( row( `MO_INNER->MT_OWN` )-name_ref ).
    cl_abap_unit_assert=>assert_initial( row( `MR_SHARED_A->*` )-name_ref ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_A` )-srtti_data ).
    cl_abap_unit_assert=>assert_not_initial( row( `MR_SHARED_B` )-srtti_data ).
    mo_model->main_attri_reattach( ).

    " ...and the draft read into a new instance follows the new targets
    roundtrip( ).
    DATA(lr_own_tab) = REF #( mo_app->mo_inner->mt_own ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( mo_app->mr_alias_tab = lr_own_tab )
                                      msg = `the restore pointed the alias at its old owner` ).
    cl_abap_unit_assert=>assert_bound( mo_app->mr_shared_a ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( mo_app->mr_shared_a = mo_app->mr_shared_b ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_app->mr_shared_b = mo_app->mo_inner->mr_shared ) ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_changed ).
    inv_srtti_cleared( ).

  ENDMETHOD.

  METHOD legacy_draft_no_type_name.

    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    " the asXML of the attribute table without its TYPE_NAME elements: what
    " a draft in the table looks like across the upgrade
    roundtrip( iv_legacy = abap_true ).
    cl_abap_unit_assert=>assert_initial( act = row( `MV_STRING` )-type_name
                                         msg = `the fixture still carries type names - nothing is proven` ).
    cl_abap_unit_assert=>assert_initial( row( `MR_HANDLE_TAB->*` )-type_name ).
    " the one kind of row the load resolves anyway - a payload row - gets
    " its name on the way
    cl_abap_unit_assert=>assert_not_initial( row( `MR_HANDLE_TAB` )-type_name ).

    " everything but the type invariant holds: the data is back, the search
    " finds every bound row without the prefilter, the model is the same
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_before ).
    inv_srtti_cleared( ).

    " the next draft of that instance: the same, the names still missing
    " on the rows nothing re-created - a refresh is what writes them
    roundtrip( ).
    inv_rows_reachable( ).
    inv_identity_shared( ).
    inv_search_finds_bound( ).
    inv_json_unchanged( lv_before ).
    inv_srtti_cleared( ).
    cl_abap_unit_assert=>assert_initial( row( `MV_STRING` )-type_name ).
    mo_model->main_attri_refresh( ).
    inv_all( lv_before ).

  ENDMETHOD.

  METHOD live_recreated_same_type.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <elem> TYPE any.
    DATA ls_sel TYPE ltcl_app_shapes=>ty_s_row_sel.
    DATA lr_new TYPE REF TO data.

    " roundtrip 1 on the live instance
    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ) of roundtrip 2: the three references to the shared table are
    " pointed at a NEW table of the same line type, the elementary
    " reference is created again - no draft was read, the rows stay
    DATA(lo_tab) = CAST cl_abap_tabledescr( z2ui5_cl_ui5_util_context=>rtti_get_typedescr_by_data_ref( mo_app->mr_shared_a ) ).
    CREATE DATA lr_new TYPE HANDLE lo_tab.
    ASSIGN lr_new->* TO <tab>.
    ls_sel-col1 = `re-created`.
    APPEND INITIAL LINE TO <tab> ASSIGNING <row>.
    MOVE-CORRESPONDING ls_sel TO <row>.
    mo_app->mr_shared_a = lr_new.
    mo_app->mr_shared_b = lr_new.
    mo_app->mo_inner->mr_shared = lr_new.
    CREATE DATA mo_app->mr_elem TYPE string.
    ASSIGN mo_app->mr_elem->* TO <elem>.
    <elem> = `elem-2`.

    " the render binds them again: the canonical row and the deref row as
    " before, resolved against the new objects
    DATA(lr_shared) = bind( mo_app->mo_inner->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_SHARED_B->*`
                                        act = lr_shared->name ).
    DATA(lr_elem) = bind( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_ELEM->*`
                                        act = lr_elem->name ).
    DATA(lv_changed) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_changed CS `"re-created"` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_changed CS `"elem-2"` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_changed CS `"shared"` ) ).

    " the draft of roundtrip 2, restored in place: the new data, the three
    " references one object again - and, with the save handing the same
    " objects back, the very object main( ) created
    DATA(lr_elem_2) = mo_app->mr_elem.
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_reattach( ).
    inv_all( lv_changed ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_app->mr_shared_a = lr_new ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_app->mr_elem = lr_elem_2 ) ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = `elem-2`
                                        act = <elem> ).

    " ...and read into a new instance
    roundtrip( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_shared_a->* TO <tab>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <tab> ) ).

  ENDMETHOD.

  METHOD live_recreated_other_type.

    FIELD-SYMBOLS <elem> TYPE any.

    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ) of roundtrip 2: the elementary reference is created again
    " with ANOTHER type - the row MR_ELEM->* still describes a string
    CREATE DATA mo_app->mr_elem TYPE i.
    ASSIGN mo_app->mr_elem->* TO <elem>.
    <elem> = 7.

    " the render binds it: the row, not a dump on the stale description,
    " described as what it is now, the binding it carried kept
    DATA(lr_attri) = bind( mo_app->mr_elem ).
    cl_abap_unit_assert=>assert_equals( exp = `MR_ELEM->*`
                                        act = lr_attri->name ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_int
                                        act = lr_attri->type_kind ).
    DATA(lv_changed) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_changed CS `"MR_ELEM_D":7` ) ).

    " the draft of that roundtrip brings the integer back, as an integer
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = <elem> ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>typekind_int
                                        act = z2ui5_cl_ui5_util_context=>rtti_get_type_kind( <elem> ) ).

    roundtrip( ).
    inv_all( lv_changed ).
    ASSIGN mo_app->mr_elem->* TO <elem>.
    cl_abap_unit_assert=>assert_equals( exp = 7
                                        act = <elem> ).

  ENDMETHOD.

  METHOD save_without_main_is_noop.

    bind_all( ).
    DATA(lv_before) = mo_model->main_json_stringify( ).

    mo_model->main_attri_db_save_srtti( ).
    DATA(lv_payloads_1) = 0.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      lv_payloads_1 = lv_payloads_1 + 1.
    ENDLOOP.
    mo_model->main_attri_db_load( ).
    DATA(lt_rows) = mr_attri->*.

    " a second save right away - nothing ran on the app in between
    mo_model->main_attri_db_save_srtti( ).
    DATA(lv_payloads_2) = 0.
    LOOP AT mr_attri->* TRANSPORTING NO FIELDS WHERE srtti_data IS NOT INITIAL. "#EC CI_SORTSEQ
      lv_payloads_2 = lv_payloads_2 + 1.
    ENDLOOP.
    mo_model->main_attri_db_load( ).

    " the same payloads, the same rows: names, owners, bindings, client
    " names, kinds - and the same model and data behind them
    cl_abap_unit_assert=>assert_true( xsdbool( lv_payloads_1 > 0 ) ).
    cl_abap_unit_assert=>assert_equals( exp = lv_payloads_1
                                        act = lv_payloads_2 ).
    cl_abap_unit_assert=>assert_equals( exp = lines( lt_rows )
                                        act = lines( mr_attri->* ) ).
    LOOP AT lt_rows REFERENCE INTO DATA(lr_old).
      DATA(lr_now) = row_ref( lr_old->name ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->name_ref
                                          act = lr_now->name_ref
                                          msg = |name_ref of { lr_old->name } changed| ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->name_parent
                                          act = lr_now->name_parent ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->bind
                                          act = lr_now->bind ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->name_client
                                          act = lr_now->name_client ).
      cl_abap_unit_assert=>assert_equals( exp = lr_old->type_kind
                                          act = lr_now->type_kind ).
    ENDLOOP.
    inv_all( lv_before ).

  ENDMETHOD.

  METHOD late_alias_survives_save.

    bind_all( ).
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).

    " main( ): the chain grows by one helper that points INTO the app -
    " created after the rows were dissolved, so no row knows it yet
    DATA(lo_late) = NEW ltcl_shp_inner( ).
    lo_late->mv_inner  = `late`.
    lo_late->mr_shared = REF #( mo_app->mt_std ).
    mo_app->mo_inner->mo_deeper->mo_deeper = lo_late.

    " the render binds the helper's value and the table through its
    " reference: the value as its own row, the table as the OWNER's
    DATA(lr_value) = bind( REF #( lo_late->mv_inner ) ).
    cl_abap_unit_assert=>assert_equals( exp = `MO_INNER->MO_DEEPER->MO_DEEPER->MV_INNER`
                                        act = lr_value->name ).
    DATA(lr_table) = mo_model->main_attri_search( lo_late->mr_shared ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = lr_table->name ).
    cl_abap_unit_assert=>assert_equals( exp = `MT_STD`
                                        act = row( `MO_INNER->MO_DEEPER->MO_DEEPER->MR_SHARED->*` )-name_ref ).
    DATA(lv_changed) = mo_model->main_json_stringify( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_changed CS `"late"` ) ).

    " the save keeps the alias an alias: restored in place and from a new
    " instance it points INTO mt_std again, not at a copy
    mo_model->main_attri_db_save_srtti( ).
    mo_model->main_attri_db_load( ).
    inv_all( lv_changed ).
    DATA(lr_std) = REF #( mo_app->mt_std ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_app->mo_inner->mo_deeper->mo_deeper->mr_shared = lr_std ) ).

    roundtrip( ).
    inv_all( lv_changed ).
    lr_std = REF #( mo_app->mt_std ).
    cl_abap_unit_assert=>assert_true( xsdbool( mo_app->mo_inner->mo_deeper->mo_deeper->mr_shared = lr_std ) ).
    cl_abap_unit_assert=>assert_equals( exp = `late`
                                        act = mo_app->mo_inner->mo_deeper->mo_deeper->mv_inner ).

  ENDMETHOD.
ENDCLASS.


" ---------------------------------------------------------------------------
" 06 - a generic reference at a structure that carries a table component. On
" its own fixture: the shared one above has struct aliases of flat structures
" only, and this shape is about what the restore does with the rows BELOW the
" alias - `<alias>->t_items` carries `<owner>-t_items` as name_ref for the
" binding search, and the restore used to follow it and re-point the alias at
" the table component of its own target (2026-09-05)
" ---------------------------------------------------------------------------
CLASS ltcl_app_struct_alias DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        col1 TYPE string,
        col2 TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_s_nested,
        id      TYPE string,
        t_items TYPE ty_t_row,
      END OF ty_s_nested.

    DATA ms_nested TYPE ty_s_nested.
    DATA mr_alias  TYPE REF TO data.

    METHODS fill.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_app_struct_alias IMPLEMENTATION.

  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.

  METHOD fill.
    ms_nested-id      = `n1`.
    ms_nested-t_items = VALUE #( ( col1 = `a` col2 = 1 ) ).
    mr_alias = REF #( ms_nested ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_06_struct_alias DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS alias_stays_on_struct FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_06_struct_alias IMPLEMENTATION.

  METHOD alias_stays_on_struct.

    FIELD-SYMBOLS <struc> TYPE any.
    FIELD-SYMBOLS <tab>   TYPE any.
    DATA lo_app   TYPE REF TO ltcl_app_struct_alias.
    DATA lr_attri TYPE REF TO z2ui5_if_ui5_types=>ty_t_attri.

    lo_app = NEW #( ).
    lo_app->fill( ).
    CREATE DATA lr_attri.
    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = lr_attri
                                                 app   = lo_app ).

    " the table bound through the alias, as _bind( mr_alias->t_items ) does
    ASSIGN lo_app->mr_alias->* TO <struc>.
    ASSIGN COMPONENT `T_ITEMS` OF STRUCTURE <struc> TO <tab>.
    cl_abap_unit_assert=>assert_subrc( ).
    DATA(lr_row) = lo_model->main_attri_search( REF #( <tab> ) ).
    lr_row->bind        = abap_true.
    lr_row->name_client = `/T_ITEMS`.

    " the draft roundtrip as the container runs it
    lo_model->main_attri_db_save_srtti( ).
    DATA(lv_app_xml)   = z2ui5_cl_ui5_util_context=>xml_stringify( lo_app ).
    DATA(lv_attri_xml) = z2ui5_cl_ui5_util_context=>xml_stringify( lr_attri->* ).
    CLEAR lo_app.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_app_xml
                                          IMPORTING any = lo_app ).
    CREATE DATA lr_attri.
    z2ui5_cl_ui5_util_context=>xml_parse( EXPORTING xml = lv_attri_xml
                                          IMPORTING any = lr_attri->* ).
    lo_model = NEW #( attri = lr_attri
                      app   = lo_app ).
    lo_model->main_attri_db_load( ).

    " the alias points at the STRUCTURE again, not at its table component
    cl_abap_unit_assert=>assert_bound( act = lo_app->mr_alias
                                       msg = `alias lost across the draft` ).
    DATA(lo_descr) = cl_abap_typedescr=>describe_by_data_ref( lo_app->mr_alias ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>kind_struct
                                        act = lo_descr->kind
                                        msg = |alias re-pointed - it derefs to kind { lo_descr->kind } ({ lo_descr->absolute_name })| ).
    DATA(lr_struc) = REF #( lo_app->ms_nested ).
    cl_abap_unit_assert=>assert_true( act = xsdbool( lo_app->mr_alias = lr_struc )
                                      msg = `alias no longer points at ms_nested` ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_app->ms_nested-t_items ) ).

  ENDMETHOD.

ENDCLASS.
