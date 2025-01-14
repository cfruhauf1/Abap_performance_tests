*&---------------------------------------------------------------------*
*& Report z_hashed_sorted_standard_table
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_hashed_sorted_standard_table.

TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
       END OF ty_ekpo.

SELECT
  ebeln,
  ebelp,
  menge,
  meins
FROM ekpo
INTO TABLE @DATA(gt_ekpo_selection).
IF sy-subrc = 0.

  "Random line to find : first bigger item number
  SORT gt_ekpo_selection DESCENDING BY ebelp.
  DATA(gs_ekpo_line_to_find) = VALUE #( gt_ekpo_selection[ 1 ] OPTIONAL ) .


  "Standard
  DATA: gv_timestmp_standard_read_beg TYPE timestampl,
        gv_timestmp_standard_read_end TYPE timestampl.

  GET TIME STAMP FIELD gv_timestmp_standard_read_beg.
  DATA gt_ekpo_standard TYPE STANDARD TABLE OF ty_ekpo.
  gt_ekpo_standard = gt_ekpo_selection.
  READ TABLE gt_ekpo_standard INTO DATA(gs_ekpo_standard) WITH KEY ebeln = gs_ekpo_line_to_find-ebeln
                                                                   ebelp = gs_ekpo_line_to_find-ebelp.
  IF sy-subrc = 0.
    GET TIME STAMP FIELD gv_timestmp_standard_read_end.
    TRY.
        DATA(gv_read_duration_standard) =  cl_abap_tstmp=>subtract( tstmp1 =  gv_timestmp_standard_read_end
                                                                    tstmp2 =  gv_timestmp_standard_read_beg  ).
      CATCH cx_parameter_invalid_range. " Parameter with invalid value range
      CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
    ENDTRY.
  ENDIF.

  "Binary search
  DATA: gv_timestmp_binary_read_beg TYPE timestampl,
        gv_timestmp_binary_read_end TYPE timestampl.

  GET TIME STAMP FIELD gv_timestmp_binary_read_beg.
  DATA gt_ekpo_binary TYPE STANDARD TABLE OF ty_ekpo.
  gt_ekpo_binary = gt_ekpo_selection.
  SORT gt_ekpo_binary BY ebeln ebelp.
  READ TABLE gt_ekpo_binary INTO DATA(gs_ekpo_binary) WITH KEY ebeln = gs_ekpo_line_to_find-ebeln
                                                               ebelp = gs_ekpo_line_to_find-ebelp
                                                               BINARY SEARCH.
  IF sy-subrc = 0.
  GET TIME STAMP FIELD gv_timestmp_binary_read_end.
    TRY.
        DATA(gv_read_duration_binary) =  cl_abap_tstmp=>subtract( tstmp1 =  gv_timestmp_binary_read_end
                                                                  tstmp2 =  gv_timestmp_binary_read_beg  ).
      CATCH cx_parameter_invalid_range. " Parameter with invalid value range
      CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
    ENDTRY.
  ENDIF.


  "Hashed
  DATA: gv_timestmp_hashed_read_beg TYPE timestampl,
        gv_timestmp_hashed_read_end TYPE timestampl.

  GET TIME STAMP FIELD gv_timestmp_hashed_read_beg.
  DATA gt_ekpo_hashed TYPE HASHED TABLE OF ty_ekpo WITH UNIQUE KEY ebeln ebelp.
  gt_ekpo_hashed = gt_ekpo_selection.
  READ TABLE gt_ekpo_hashed INTO DATA(gs_ekpo_hashed) WITH TABLE KEY ebeln = gs_ekpo_line_to_find-ebeln
                                                                     ebelp = gs_ekpo_line_to_find-ebelp.
  IF sy-subrc = 0.
    GET TIME STAMP FIELD gv_timestmp_hashed_read_end.
    TRY.
        DATA(gv_read_duration_hashed) =  cl_abap_tstmp=>subtract(  tstmp1 =  gv_timestmp_hashed_read_end
                                                                   tstmp2 =  gv_timestmp_hashed_read_beg  ).
      CATCH cx_parameter_invalid_range. " Parameter with invalid value range
      CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
    ENDTRY.
  ENDIF.

  "Sorted
  DATA: gv_timestmp_sorted_read_beg TYPE timestampl,
        gv_timestmp_sorted_read_end TYPE timestampl.

  GET TIME STAMP FIELD gv_timestmp_sorted_read_beg.
  DATA gt_ekpo_sorted TYPE SORTED TABLE OF ty_ekpo WITH UNIQUE KEY ebeln ebelp.
  gt_ekpo_sorted = gt_ekpo_selection.
  READ TABLE gt_ekpo_sorted INTO DATA(gs_ekpo_sorted) WITH TABLE KEY ebeln = gs_ekpo_line_to_find-ebeln
                                                                     ebelp = gs_ekpo_line_to_find-ebelp.
  IF sy-subrc = 0.
    GET TIME STAMP FIELD gv_timestmp_sorted_read_end.
    TRY.
        DATA(gv_read_duration_sorted) =  cl_abap_tstmp=>subtract(  tstmp1 =  gv_timestmp_sorted_read_end
                                                                   tstmp2 =  gv_timestmp_sorted_read_beg  ).
      CATCH cx_parameter_invalid_range. " Parameter with invalid value range
      CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
    ENDTRY.
  ENDIF.

  DATA: gv_percent_standard_vs_std TYPE i,
        gv_percent_binary_vs_std   TYPE i,
        gv_percent_hashed_vs_std   TYPE i,
        gv_percent_sorted_vs_std   TYPE i.

  gv_percent_standard_vs_std =  gv_read_duration_standard  / gv_read_duration_standard * 100.
  gv_percent_binary_vs_std   =  gv_read_duration_binary    / gv_read_duration_standard * 100.
  gv_percent_hashed_vs_std   =  gv_read_duration_hashed    / gv_read_duration_standard * 100.
  gv_percent_sorted_vs_std   =  gv_read_duration_sorted    / gv_read_duration_standard * 100.

  "Duration
  WRITE / 'Read on standard table : ' && gv_read_duration_standard.
  WRITE / 'Read on standard table (sort + binary search) : ' && gv_read_duration_binary.
  WRITE / 'Read on hashed table : ' && gv_read_duration_hashed.
  WRITE / 'Read on sorted table : ' && gv_read_duration_sorted.

  WRITE /.

  "Percent
  WRITE / '% standard vs standard : ' && gv_percent_standard_vs_std.
  WRITE / '% binary vs standard : '   && gv_percent_binary_vs_std  .
  WRITE / '% hashed vs standard : '   && gv_percent_hashed_vs_std  .
  WRITE / '% sorted vs standard : '   && gv_percent_sorted_vs_std  .

ENDIF.
