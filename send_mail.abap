  FORM send_mail USING sender TYPE uname.
  
  DATA(lo_send_request) = cl_bcs=>create_persistent( ).
  DATA(lo_sender) = cl_sapuser_bcs=>create( sender ).
  DATA: lv_subject TYPE so_obj_des,
        currdate   TYPE string,
        l_email        TYPE c LENGTH 241,
        it_error_table TYPE STANDARD TABLE OF rpbenerr,
        main_text      TYPE bcsy_text,
        l_size         TYPE sood-objlen,
        convertedDate      TYPE string.      
        
        
  CALL METHOD lo_send_request->set_sender
    EXPORTING
      i_sender = lo_sender.
  

  "placeholder value
  DATA(reaction) = 'r'.

  CALL FUNCTION 'HR_FBN_GET_USER_EMAIL_ADDRESS'
    EXPORTING
      user_id       = sender
      reaction      = reaction
    IMPORTING
      email_address = l_email
    TABLES
      error_table   = it_error_table.

  DATA(lo_recepient) = cl_cam_address_bcs=>create_internet_address( i_address_string = l_email ).
  lo_send_request->add_recipient( lo_recepient ).


  PERFORM create_solix USING it_output.

  "Appending email body
  IF main_text IS INITIAL.
    APPEND 'INSERT MAIL BODY HERE' TO main_text.
  ENDIF.

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4) INTO currdate SEPARATED BY '/'.


  CONCATENATE 'Rapporti Lavoro senza esito al' currdate INTO lv_subject SEPARATED BY ' '.

  DATA(lo_document) = cl_document_bcs=>create_document(
                             "mail body
                             i_text = main_text
                             i_type  = 'RAW'
                             "mail subject
                             i_subject = lv_subject ).

  CALL METHOD lo_document->add_attachment
    EXPORTING
      i_attachment_type    = 'XLS'
      i_attachment_size    = l_size
      "name of attachment
      i_attachment_subject = 'TESTFILE'
      i_att_content_hex    = i_attach. "what came out of the solix conversion form

  lo_send_request->set_document( lo_document ).
  lo_send_request->send(
  EXPORTING
    i_with_error_screen = 'X'
  RECEIVING
    result = DATA(lv_sent_to_all)
  ).
  IF lv_sent_to_all = 'X'.
    MESSAGE 'Email sent!' TYPE 'S'.
  ENDIF.

  COMMIT WORK.

ENDFORM.
