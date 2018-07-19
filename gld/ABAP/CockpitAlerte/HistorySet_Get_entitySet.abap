METHOD historyset_get_entityset.
  TYPES:  BEGIN OF tt_histr.
           INCLUDE TYPE zft_s_gw_cockpitalerte_history.
           TYPES: objectclas    TYPE cdobjectcl,
                  objectid      TYPE cdobjectv,
          END OF tt_histr.
  TYPES : BEGIN OF ty_field,
            tabname   TYPE tabname,
            fieldname TYPE fieldname,
            scrtext_l TYPE scrtext_l,
          END OF ty_field.

  DATA: lv_dispn    TYPE rvari_val_255,
        lv_disp2    TYPE i,
        lv_matnr    TYPE matnr,
        lv_numln    TYPE i VALUE '1',
        ls_cdhdr    TYPE cdhdr,
        ls_cdpos    TYPE cdpos,
        ls_dmntx    TYPE dd07v,
        ls_editp    TYPE cdshw,
        ls_field    TYPE ty_field,
        ls_filtr    TYPE /iwbep/s_mgw_select_option,
        ls_histr    TYPE tt_histr,
        ls_histo    TYPE zmm_history,
        lt_cdpos    TYPE SORTED TABLE OF cdpos WITH NON-UNIQUE KEY objectclas objectid changenr tabname tabkey fname chngind,
        lt_histo    TYPE TABLE OF zmm_history,
        ls_selop    TYPE /iwbep/s_cod_select_option,
        lt_stsrc    TYPE TABLE OF dd07v,
        lt_sttft    TYPE TABLE OF dd07v,
        lt_sttsr    TYPE TABLE OF dd07v,
        lt_sttca    TYPE TABLE OF dd07v,
        lt_strcc    TYPE TABLE OF dd07v,
        lt_dmntt    TYPE TABLE OF dd07v,
        lt_cdhdr    TYPE TABLE OF cdhdr,
        lt_editp    TYPE TABLE OF cdshw,
        lt_field    TYPE TABLE OF ty_field,
        lt_hist2    TYPE TABLE OF zft_s_gw_cockpitalerte_history,
        lt_histr    TYPE TABLE OF tt_histr,
        lt_matnr    TYPE /iwbep/t_cod_select_options.


  SELECT  SINGLE low
  INTO    lv_dispn
  FROM    tvarvc
  WHERE   name EQ 'ZFT_COCKPIT_N'.

  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZFT_GW_STATS '
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_stsrc
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.

    CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_FT_STATS '
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_stTFT
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.

    CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_SR_STATS '
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_sttsr
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.

    CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_CA_STATS '
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_sttca
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.

    CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZFT_GW_CSTAT '
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_strcc
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.



* Get real
*****  SELECT  objectclas objectid AS prnum username AS usern udate utime changenr m~maktx AS descr
*****  INTO    CORRESPONDING FIELDS OF TABLE lt_histr
*****  UP      TO lv_dispn ROWS
*****  FROM    cdhdr AS c
*****  LEFT    OUTER JOIN makt AS m ON c~objectid EQ m~matnr
*****  WHERE   objectclas EQ 'MAT_FULL'
*****  ORDER   BY udate DESCENDING utime DESCENDING.
*****
*****  DELETE ADJACENT DUPLICATES FROM lt_histr COMPARING changenr.
*****
*****  SELECT  *
*****  INTO    CORRESPONDING FIELDS OF TABLE lt_cdpos
*****  FROM    cdpos
*****  FOR     ALL ENTRIES IN lt_histr
*****  WHERE   objectclas EQ lt_histr-objectclas
*****  AND     objectid EQ lt_histr-prnum
*****  AND     changenr EQ lt_histr-changenr.
*****
*****  SELECT  fieldname tabname scrtext_l
*****  INTO    CORRESPONDING FIELDS OF TABLE lt_field
*****  FROM    dd03l AS l
*****  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
*****  FOR     ALL ENTRIES IN lt_cdpos
*****  WHERE   l~tabname EQ lt_cdpos-tabname
*****  AND     t~ddlanguage EQ sy-langu.
*****
*****  LOOP AT lt_histr INTO ls_histr.
******    CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
******      EXPORTING
******        archive_handle            = 0
******        changenumber              = ls_histr-changenr
******        i_prep_unit               = 'X'
******      TABLES
******        editpos                   = lt_editp
******      EXCEPTIONS
******        OTHERS                    = 1.
******
******    IF sy-subrc EQ 0.
******      LOOP AT lt_editp INTO ls_editp.
*****      LOOP AT lt_cdpos INTO ls_cdpos WHERE objectclas EQ ls_histr-objectclas
*****                                       AND objectid EQ ls_histr-prnum
*****                                       AND changenr EQ ls_histr-changenr
*****                                       AND fname NE 'LAEDA'
*****                                       AND fname NE 'KEY'
*****                                       AND fname IS NOT INITIAL.
******        IF ls_editp-fname NE 'LAEDA'.
*****          ls_histr-chngt          = ls_cdpos-chngind.
*****          ls_histr-fname          = ls_cdpos-fname.
*****          ls_histr-oldvl          = ls_cdpos-value_old.
*****          ls_histr-newvl          = ls_cdpos-value_new.
*****
*****          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histr-fname.
*****          IF sy-subrc EQ 0.
*****            ls_histr-ftext        = ls_field-scrtext_l.
*****          ENDIF.
*****
*****          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*****            EXPORTING
*****              input               = ls_histr-prnum
*****            IMPORTING
*****              output              = ls_histr-prnum.
*****
*****          APPEND ls_histr TO lt_hist2.
******        ENDIF.
*****      ENDLOOP.
******    ENDIF.
*****
*****  ENDLOOP.

* Get fictives
  SELECT  *
  INTO    CORRESPONDING FIELDS OF TABLE lt_histo
  FROM    zmm_history AS y
  INNER   JOIN zmm_histo AS h ON y~tbnam EQ h~tabnm AND y~fname EQ h~fldnm.

  LOOP AT lt_histo INTO ls_histo.
    CLEAR: ls_dmntx.
    IF ls_histo-fname EQ 'STATS'.
      CASE ls_histo-tbnam.
        WHEN 'ZMM_AF_SRC'.
          READ TABLE lt_stsrc INTO ls_dmntx WITH KEY domvalue_l = ls_histo-oldvl.
          IF sy-subrc EQ 0.
            ls_histo-oldvl              = ls_dmntx-ddtext.
          ENDIF.

          READ TABLE lt_stsrc INTO ls_dmntx WITH KEY domvalue_l = ls_histo-newvl.
          IF sy-subrc EQ 0.
            ls_histo-newvl              = ls_dmntx-ddtext.
          ENDIF.
        WHEN 'ZMM_FT_DEF'.
          READ TABLE lt_sttft INTO ls_dmntx WITH KEY domvalue_l = ls_histo-oldvl.
          IF sy-subrc EQ 0.
            ls_histo-oldvl              = ls_dmntx-ddtext.
          ENDIF.

          READ TABLE lt_sttft INTO ls_dmntx WITH KEY domvalue_l = ls_histo-newvl.
          IF sy-subrc EQ 0.
            ls_histo-newvl              = ls_dmntx-ddtext.
          ENDIF.
        WHEN 'ZMM_SR_DEF'.
          READ TABLE lt_sttsr INTO ls_dmntx WITH KEY domvalue_l = ls_histo-oldvl.
          IF sy-subrc EQ 0.
            ls_histo-oldvl              = ls_dmntx-ddtext.
          ENDIF.

          READ TABLE lt_sttsr INTO ls_dmntx WITH KEY domvalue_l = ls_histo-newvl.
          IF sy-subrc EQ 0.
            ls_histo-newvl              = ls_dmntx-ddtext.
          ENDIF.
        WHEN 'ZMM_CA_DEF'.
          READ TABLE lt_sttca INTO ls_dmntx WITH KEY domvalue_l = ls_histo-oldvl.
          IF sy-subrc EQ 0.
            ls_histo-oldvl              = ls_dmntx-ddtext.
          ENDIF.

          READ TABLE lt_sttca INTO ls_dmntx WITH KEY domvalue_l = ls_histo-newvl.
          IF sy-subrc EQ 0.
            ls_histo-newvl              = ls_dmntx-ddtext.
          ENDIF.
        WHEN 'ZMM_CA_ITM'.
          READ TABLE lt_strcc INTO ls_dmntx WITH KEY domvalue_l = ls_histo-oldvl.
          IF sy-subrc EQ 0.
            ls_histo-oldvl              = ls_dmntx-ddtext.
          ENDIF.

          READ TABLE lt_strcc INTO ls_dmntx WITH KEY domvalue_l = ls_histo-newvl.
          IF sy-subrc EQ 0.
            ls_histo-newvl              = ls_dmntx-ddtext.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    ls_histr-appnm                = ls_histo-appnm.
    ls_histr-changenr             = ls_histo-chgnr.
    ls_histr-chngt                = ls_histo-chngt.
    ls_histr-descr                = ls_histo-descr.
    ls_histr-fname                = ls_histo-fname.
    ls_histr-ftext                = ls_histo-ftext.
    ls_histr-newvl                = ls_histo-newvl.
    ls_histr-oldvl                = ls_histo-oldvl.
    ls_histr-prnum                = ls_histo-prnum.
    ls_histr-udate                = ls_histo-udate.
    ls_histr-usern                = ls_histo-usern.
    ls_histr-utime                = ls_histo-utime.

    APPEND ls_histr TO lt_hist2.

  ENDLOOP.

  SORT lt_hist2 DESCENDING BY changenr fname.
  DELETE ADJACENT DUPLICATES FROM lt_hist2 COMPARING changenr fname.
  SORT lt_hist2 BY udate DESCENDING utime DESCENDING.

  IF lv_dispn IS NOT INITIAL.
    lv_disp2                      = lv_dispn + 1.
    DELETE lt_hist2 FROM lv_disp2.
  ENDIF.

  et_entityset                    = lt_hist2.

ENDMETHOD.