*&---------------------------------------------------------------------*
*&  Include           Z_SOLD_OUT_CL
*&---------------------------------------------------------------------*

CLASS xmltoal11 DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor IMPORTING table TYPE ANY TABLE,
             createxml,
             upload_al11.

  PRIVATE SECTION.
    TYPES: BEGIN OF tp_row,
      styleid TYPE string,
      type TYPE string,
      value TYPE string,
    END OF tp_row,
    tbp_row TYPE TABLE OF tp_row WITH NON-UNIQUE DEFAULT KEY,
    BEGIN OF tp_table,
      header TYPE string,
      rows    TYPE tbp_row,
    END OF tp_table.

    DATA: file TYPE STANDARD TABLE OF string,
          rowcount TYPE i,
          colcount TYPE i,
          worksheetname TYPE string,
          header TYPE STANDARD TABLE OF string,
          style TYPE STANDARD TABLE OF string,
          columns TYPE STANDARD TABLE OF string,
          rows TYPE STANDARD TABLE OF string,
          footer TYPE STANDARD TABLE OF string,
          wa_row TYPE tp_row,
          it_row TYPE tbp_row,
          it_table TYPE STANDARD TABLE OF tp_table,
          wa_table TYPE tp_table.

    METHODS: append_header,
             append_style,
             itab_conv,
             append_footer.

ENDCLASS.                    "xmltoal11 DEFINITION

*----------------------------------------------------------------------*
*       CLASS xmltoal11 IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS xmltoal11 IMPLEMENTATION.
  METHOD constructor.
    worksheetname = 'sheet'.
    DATA count TYPE i VALUE 0.
    DATA: it_detail   TYPE abap_compdescr_tab,
          tab_descr TYPE REF TO cl_abap_tabledescr,
          struct_descr TYPE REF TO cl_abap_structdescr,
          wa_comp TYPE abap_compdescr,
          str TYPE string.
    FIELD-SYMBOLS: <table> TYPE ANY TABLE,
                   <row> TYPE ANY,
                   <tabrow> TYPE tp_table,
                   <cell> TYPE ANY.
    ASSIGN table TO <table>.

    DESCRIBE TABLE table LINES rowcount.

    tab_descr ?= cl_abap_typedescr=>describe_by_data( table ).
    struct_descr ?= tab_descr->get_table_line_type( ).
    it_detail[] = struct_descr->components .

    LOOP AT it_detail INTO wa_comp.
      count = count + 1.
      wa_table-header = wa_comp-name.
      APPEND wa_table TO it_table.
      CLEAR wa_table.
    ENDLOOP.
    colcount = count.

    LOOP AT <table> ASSIGNING <row>.
      sy-subrc = 0.
      WHILE sy-subrc = 0.
        ASSIGN COMPONENT sy-index OF STRUCTURE <row> TO <cell>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        wa_row-styleid = 'tabcell'.
        wa_row-type = 'String'.
        wa_row-value = <cell>.
        READ TABLE it_table ASSIGNING <tabrow> INDEX sy-index.
        APPEND wa_row TO <tabrow>-rows.
      ENDWHILE.
    ENDLOOP.

  ENDMETHOD.                    "constructor

  METHOD createxml.
    append_header( ).
    append_style( ).
    itab_conv( ).
    append_footer( ).
    APPEND LINES OF header TO file.
    APPEND LINES OF style TO file.
    APPEND LINES OF columns TO file.
    APPEND LINES OF rows TO file.
    APPEND LINES OF footer TO file.
  ENDMETHOD.                    "createXML

  METHOD append_header.
    APPEND '<?xml version="1.0"?>' TO header.
    APPEND  '<?mso-application progid="Excel.Sheet"?>'  TO header.
    APPEND  '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'  TO header.
    APPEND  'xmlns:o="urn:schemas-microsoft-com:office:office"'  TO header.
    APPEND  'xmlns:x="urn:schemas-microsoft-com:office:excel"'  TO header.
    APPEND  'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'  TO header.
    APPEND  'xmlns:html="http://www.w3.org/TR/REC-html40">'  TO header.
  ENDMETHOD.                    "append_header

  METHOD append_style.
    APPEND  '<Styles>'  TO style.
    APPEND  '<Style ss:ID="tabcell">'  TO style.
    APPEND  '<Borders>'  TO style.
    APPEND  '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'  TO style.
    APPEND  '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'  TO style.
    APPEND  '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'  TO style.
    APPEND  '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'  TO style.
    APPEND  '</Borders>'  TO style.
    APPEND  '</Style>'  TO style.
    APPEND  '</Styles>'  TO style.
    CONCATENATE '<Worksheet ss:Name="' worksheetname '">' INTO worksheetname.
    APPEND  worksheetname TO style.
  ENDMETHOD.                    "append_style

  METHOD itab_conv.
    DATA: tmpcol TYPE string,
          tmprow TYPE string,
          countcol TYPE c length 20,
          countrow TYPE c LENGTH 20.

    countcol = colcount.
    CONDENSE countcol.
    countrow = rowcount.
    CONDENSE countrow.

    CONCATENATE '<Table ss:ExpandedColumnCount="' countcol '" ss:DefaultRowHeight="14.55">' INTO tmpcol.
    APPEND tmpcol TO columns.

    LOOP AT it_table INTO wa_table.
      countcol = sy-tabix.
      CONCATENATE '<Column ss:Index="' countcol '" ss:AutoFitWidth="1" />' INTO tmpcol.
    ENDLOOP.

    LOOP AT it_table INTO wa_table.
      AT FIRST.
        APPEND '<Row ss:AutoFitHeight="0" ss:Height="16.8">' TO rows.
      ENDAT.
      CONCATENATE '<Cell ss:StyleID="tabcell"><Data ss:Type="String">' wa_table-header '</Data></Cell>' INTO tmprow.
      APPEND tmprow TO rows.
      AT LAST.
        APPEND '</Row>' TO rows.
      ENDAT.
    ENDLOOP.
    DO colcount TIMES.
      LOOP AT it_table INTO wa_table.
        AT FIRST.
          APPEND '<Row ss:AutoFitHeight="0" ss:Height="16.8">' TO rows.
        ENDAT.
        READ TABLE wa_table-rows INTO wa_row INDEX sy-index.
        CONCATENATE '<Cell ss:StyleID="' wa_row-styleid '"><Data ss:Type="' wa_row-type '">' wa_row-value '</Data></Cell>' INTO tmprow.
        APPEND tmprow TO rows.
        AT LAST.
          APPEND '</Row>' TO rows.
        ENDAT.
      ENDLOOP.
    ENDDO.
    APPEND '</Table>' TO rows.

  ENDMETHOD.                    "itab_conv

  METHOD append_footer.
    APPEND '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'  TO footer.
    APPEND  '</WorksheetOptions>'  TO footer.
    APPEND  '</Worksheet>'  TO footer.
    APPEND  '</Workbook>'  TO footer.
  ENDMETHOD.                    "append_footer

  METHOD upload_al11.
    DATA: fname TYPE string,
          looprow TYPE string.
    CONCATENATE '/tmp/' 'sold_out-' sy-datum '-' sy-uzeit '.xml' INTO fname.
    OPEN DATASET fname FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    LOOP AT file into looprow.
      TRANSFER looprow TO fname.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.                    "xmltoal11 IMPLEMENTATION
