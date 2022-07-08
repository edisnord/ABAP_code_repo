CLASS zarraylist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_ls_list,
        element TYPE REF TO object,
      END OF ty_ls_list .
    TYPES:
      ty_lt_list TYPE STANDARD TABLE OF ty_ls_list .

    METHODS constructor
      IMPORTING
        !list TYPE ty_lt_list OPTIONAL.

    METHODS add IMPORTING e            TYPE REF TO object
                RETURNING VALUE(added) TYPE abap_bool.

    METHODS get IMPORTING index      TYPE i
                RETURNING VALUE(ret) TYPE REF TO object.

    METHODS contains IMPORTING e           TYPE REF TO object
                     RETURNING VALUE(cont) TYPE abap_bool.

    METHODS remove importing e TYPE REF TO object
    RETURNING VALUE(rmoved) TYPE abap_bool.

    methods size RETURNING VALUE(size) TYPE i.

    methods isEmpty returning value(isempty) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: lt_list TYPE ty_lt_list.

ENDCLASS.



CLASS zarraylist IMPLEMENTATION.


  METHOD add.
    CHECK e IS NOT INITIAL.
    DATA(lncnt) = lines( lt_list ).

    APPEND VALUE ty_ls_list( element = e ) TO lt_list.

    added = COND #( WHEN lines( lt_list ) > lncnt THEN abap_true
                    ELSE abap_false ).

  ENDMETHOD.

  METHOD constructor.
    CHECK list IS NOT INITIAL.
    lt_list = list.
  ENDMETHOD.

  METHOD get.
    TRY.
        ret = lt_list[ index ]-element.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD contains.
    cont = cond #( WHEN line_exists( lt_list[ element = e ] ) THEN abap_true
                   ELSE abap_false ).
  ENDMETHOD.

  method remove.
    if line_exists( lt_list[ element = e ] ).
        delete lt_list where element = e.
        rmoved = abap_true.
    else.
        rmoved = abap_false.
    ENDIF.
  endmethod.

  METHOD isempty.
        isempty = cond #( when lines( lt_list ) = 0 THEN abap_true
                          else abap_false ).
  ENDMETHOD.

  METHOD size.
        size = lines( lt_list ).
  ENDMETHOD.

ENDCLASS.
