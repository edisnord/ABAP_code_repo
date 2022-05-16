CLASS cl_log DEFINITION.
  PUBLIC SECTION.
    DATA: errorslogged TYPE i VALUE 0.
    METHODS: constructor IMPORTING class TYPE string subclass TYPE string,
             do_application_log_display,
             msg_add IMPORTING l_s_msg TYPE bal_s_msg.
  PRIVATE SECTION.
    DATA: gs_log   TYPE bal_s_log.
    DATA: gv_log_handle TYPE  balloghndl.
    DATA: gc_object    TYPE bal_s_log-object,
          gc_subobject TYPE bal_s_log-subobject.
    DATA: g_s_msg TYPE bal_s_msg.
ENDCLASS.                    "cl_log DEFINITION
CLASS cl_log IMPLEMENTATION.
  METHOD constructor.
    gc_object = class.
    gc_subobject = subclass.
    gs_log-aluser    = sy-uname.
    gs_log-alprog    = sy-repid.
    gs_log-object    = gc_object.
    gs_log-subobject = gc_subobject.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = gs_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.                    "constructor

  METHOD do_application_log_display.
    DATA: lt_log_handle TYPE bal_t_logh.
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_save_all = 'X'
      EXCEPTIONS
        OTHERS     = 4.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF sy-batch IS INITIAL.
      APPEND gv_log_handle TO lt_log_handle.
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
        EXPORTING
          i_t_log_handle = lt_log_handle
        EXCEPTIONS
          OTHERS         = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "do_application_log_display

  METHOD msg_add.
    errorslogged = errorslogged + 1.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = l_s_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.                    "msg_add

ENDCLASS.                    "cl_log IMPLEMENTATION