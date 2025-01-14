*&---------------------------------------------------------------------*
*& Report z_performance_at_group
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_performance_at_group.

SELECT
  ebeln,
  ebelp
FROM ekpo
INTO TABLE @DATA(lt_ekpo).
IF sy-subrc = 0.

  "At new
  DATA lr_ebeln TYPE RANGE OF ebeln.
  DATA: lv_time_stamp_at_new_beg TYPE timestampl,
        lv_time_stamp_at_new_end TYPE timestampl,
        lv_duration_at_new       TYPE tzntstmpl.        "Time Interval in Seconds
  GET TIME STAMP FIELD lv_time_stamp_at_new_beg.
  SORT lt_ekpo BY ebeln.
  LOOP AT lt_ekpo INTO DATA(ls_ekpo).
    AT NEW ebeln.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_ekpo-ebeln ) TO lr_ebeln.
    ENDAT.
  ENDLOOP.
  GET TIME STAMP FIELD lv_time_stamp_at_new_end.
  TRY.
      lv_duration_at_new =  cl_abap_tstmp=>subtract(  tstmp1 =  lv_time_stamp_at_new_end
                                                      tstmp2 =  lv_time_stamp_at_new_beg  ).
    CATCH cx_parameter_invalid_range. " Parameter with invalid value range
    CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
  ENDTRY.


  "At group
  DATA lr_ebeln_2 TYPE RANGE OF ebeln.
  DATA: lv_time_stamp_at_group_beg TYPE timestampl,
        lv_time_stamp_at_group_end TYPE timestampl,
        lv_duration_at_group       TYPE tzntstmpl.      "Time Interval in Seconds
  GET TIME STAMP FIELD lv_time_stamp_at_group_beg.
  LOOP AT lt_ekpo INTO DATA(lg_ekpo)
    GROUP BY ( key1 = lg_ekpo-ebeln ).
    APPEND VALUE #( sign = 'I' option = 'EQ' low = lg_ekpo-ebeln ) TO lr_ebeln_2.
  ENDLOOP.
  GET TIME STAMP FIELD lv_time_stamp_at_group_end.
  TRY.
      lv_duration_at_group =  cl_abap_tstmp=>subtract(  tstmp1 =  lv_time_stamp_at_group_end
                                                        tstmp2 =  lv_time_stamp_at_group_beg  ).
    CATCH cx_parameter_invalid_range. " Parameter with invalid value range
    CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
  ENDTRY.

  DATA lv_duration_percent TYPE i.
  lv_duration_percent = ( lv_duration_at_group - lv_duration_at_new ) / lv_duration_at_group * 100.

  WRITE / 'Loop at new début : ' && lv_time_stamp_at_new_beg.
  WRITE / 'Loop at new fin : ' && lv_time_stamp_at_new_end.
  WRITE / 'Temps de process at new : ' && lv_duration_at_new.
  WRITE / 'Loop at group début : ' && lv_time_stamp_at_group_beg.
  WRITE / 'Loop at group fin : ' && lv_time_stamp_at_group_end.
  WRITE / 'Temps de process at group : ' && lv_duration_at_group.
  WRITE /.
  WRITE / 'Pourcentage d''écart : ' && lv_duration_percent && '%'.

ENDIF.
