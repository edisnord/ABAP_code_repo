FORM display_alv using it_output type any table.

  DATA lo_alv TYPE REF TO cl_salv_table.
  DATA lex_message TYPE REF TO cx_salv_msg.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = it_output )
          .

    CATCH cx_salv_msg INTO lex_message.
      MESSAGE lex_message TYPE 'E'.
  ENDTRY.
ENDFORM.
