"wa_sol, it_sol can be any table type, as long as wa_sol is like line of it_sol
DATA : itab1 TYPE TABLE OF alsmex_tabline.
DATA : b1 TYPE i VALUE 1,
c1 TYPE i VALUE 1,
b2 TYPE i VALUE 100,
c2 TYPE i VALUE 9999.

CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = p_file
        i_begin_col             = b1
        i_begin_row             = c1
        i_end_col               = b2
        i_end_row               = c2
      TABLES
        intern                  = itab1
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
		
IF sy-subrc NE 0.
    MESSAGE 'Conversion error' TYPE 'E' DISPLAY LIKE 'I'.
ENDIF.
	
FORM extract_data USING withheader TYPE abap_bool colnr TYPE i.

	DATA : wa_alsm TYPE alsmex_tabline,
    lastrow TYPE i,
    lastcol TYPE i.

	FIELD-SYMBOLS: <column> TYPE ANY.
	DELETE itab1 WHERE col > colnr.

	IF withheader = abap_true.
		DELETE itab1 WHERE row = 1.
	ENDIF.

	LOOP AT itab1 INTO wa_alsm.

		IF lastrow IS INITIAL.
			lastrow = wa_alsm-row.
		ENDIF.

		IF lastrow NE wa_alsm-row.
			APPEND wa_sol TO it_sol.
			CLEAR wa_sol.
			lastrow = wa_alsm-row.
			ASSIGN COMPONENT wa_alsm-col OF STRUCTURE wa_sol TO <column>.
			<column> = wa_alsm-value.
			lastcol = wa_alsm-col.
			CONTINUE.
		ENDIF.

		IF wa_alsm-col NE lastcol.
			ASSIGN COMPONENT wa_alsm-col OF STRUCTURE wa_sol TO <column>.
			<column> = wa_alsm-value.
		ENDIF.

		lastcol = wa_alsm-col.
		lastrow = wa_alsm-row.
		AT LAST.
			APPEND wa_sol TO it_sol.
			CLEAR wa_sol.
		ENDAT.
	ENDLOOP.
ENDFORM.                    " EXTRACT_DATA