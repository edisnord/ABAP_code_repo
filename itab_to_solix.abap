FORM create_solix using it_output TYPE ANY TABLE.

DATA: l_text TYPE string, 
      l_con(50) TYPE c, 
      i_attach       TYPE solix_tab,
      l_size         TYPE sood-objlen,

DATA(gc_tab) = cl_bcs_convert=>gc_tab. "space element in solix string
DATA(gc_crlf) = cl_bcs_convert=>gc_crlf. "newline element in solix string

  CONCATENATE 'headers'
  SEPARATED BY gc_tab.
  l_text = |{ l_text }| & |{ gc_crlf }|.

  LOOP AT it_output ASSIGNING FIELD-SYMBOL(<fs_logi>).
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <fs_logi> TO FIELD-SYMBOL(<fs_temp>).
      IF sy-subrc <> 0.

        l_text = |{ l_text }| & |{ gc_crlf }|.
        EXIT.
      ENDIF.

      CLEAR: l_con.
      MOVE <fs_temp> TO l_con.
      CONDENSE l_con.

      IF sy-index = 1.
        l_text = |{ l_text }| & |{ l_con }|.
      ELSE.
        l_text = |{ l_text }| & |{ gc_tab }| & |{ l_con }|.
      ENDIF.

    ENDDO.
  ENDLOOP.

  cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = l_text
            iv_codepage = '4103'  "suitable for MS Excel, leave empty
            iv_add_bom  = 'X'     "for other doc types
          IMPORTING
            et_solix  = i_attach
            ev_size   = l_size ).

ENDFORM.
