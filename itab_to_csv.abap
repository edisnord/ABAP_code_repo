"it_csv can be any standard table
FORM create_csv CHANGING final_csv TYPE truxs_t_text_data.
  DATA : it_detail   TYPE abap_compdescr_tab,
         wa_comp TYPE abap_compdescr,
         header TYPE string.
  DATA : ref_descr TYPE REF TO cl_abap_structdescr.

  ref_descr ?= cl_abap_typedescr=>describe_by_data( wa_final ).
  it_detail[] = ref_descr->components .

  LOOP AT it_detail INTO wa_comp.
    CONCATENATE header wa_comp-name ';' INTO header.
  ENDLOOP.

  CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
    TABLES
      i_tab_sap_data       = it_csv
    CHANGING
      i_tab_converted_data = final_csv
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

    INSERT header INTO final_csv INDEX 1.
ENDFORM.