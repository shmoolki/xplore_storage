METHOD vhrecettesdetail_get_entityset.
  TYPES:BEGIN OF ts_recdt.
          INCLUDE TYPE zcl_zft_gw_value_help_mpc=>ts_vhrecettesdetails.
          TYPES : apfi2 TYPE zmm_ft_apfin,
                  apde2 TYPE zmm_ft_apdeb,
                  srtft TYPE zmm_sr_to_ft,
                  erdat TYPE erdat, "for Handling N last updated
                  aedat TYPE aedat, "for Handling N last created
        END OF ts_recdt.
  DATA: lv_frnum    TYPE zmm_srnum,
        lv_numfr    TYPE zmm_ftnum,
        lv_titre    TYPE string,
        lv_vkorg    TYPE vkorg,
        lv_niv_1    TYPE boolean,
        lv_dispn    TYPE rvari_val_255, "Default to display
        lv_nblin    TYPE i,
        ls_dmntx    TYPE dd07v,
        ls_ensgn    TYPE zgld_enseigne,
        ls_entty    TYPE ts_recdt,
        ls_filtr    TYPE /iwbep/s_mgw_select_option,
        ls_selop    TYPE /iwbep/s_cod_select_option,
        ls_where    TYPE string,
        lr_ensgn    TYPE /iwbep/s_mgw_select_option,
        lt_maktx    TYPE /iwbep/t_cod_select_options,
        lt_numfr    TYPE /iwbep/t_cod_select_options,
        lt_dmntt    TYPE TABLE OF dd07v,
        lt_dmntx    TYPE TABLE OF dd07v,
        lt_entcp    TYPE TABLE OF ts_recdt,
        lt_entty    TYPE TABLE OF ts_recdt,
        lt_entit    TYPE TABLE OF ts_recdt,
        lt_ensgn    TYPE TABLE OF zgld_enseigne,
        lt_frnum    TYPE TABLE OF zmm_frnum,
        lt_where    TYPE TABLE OF string,
        lt_wher2    TYPE TABLE OF string.


  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'ENSGN'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      ls_selop-sign               = 'I'.
      IF ls_selop-low IS NOT INITIAL.
        lv_vkorg        = ls_selop-low.
*        SHIFT lv_vkorg BY sy-fdpos PLACES.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'FRNUM'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
*       If MATNR --> conversion
        APPEND ls_selop TO lt_numfr.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'TITRE'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
*       If MATNR --> conversion
        IF ls_selop-low CO '*0123456789'.
          CONCATENATE '*' ls_selop-low INTO ls_selop-low.
        ENDIF.
        APPEND ls_selop TO lt_maktx.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'NIV_1'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      ls_selop-sign               = 'I'.
      IF ls_selop-low IS NOT INITIAL.
        lv_niv_1        = ls_selop-low.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SELECT  *
  INTO    TABLE lt_ensgn
  FROM    zgld_enseigne.

  LOOP AT lt_ensgn INTO ls_ensgn.
*    CONCATENATE 'Z' ls_ensgn-ensgn INTO ls_ensgn-ensgn.
    AUTHORITY-CHECK OBJECT 'W_VKPR_PLT'
             ID 'VKORG' FIELD ls_ensgn-vkorg
             ID 'VTWEG' FIELD '*'
             ID 'PLTYP' FIELD '*'
             ID 'MATKL' FIELD '*'
             ID 'ACTVT' FIELD '03'.
    IF sy-subrc EQ 0.
      ls_selop-sign             = 'I'.
      ls_selop-option           = 'EQ'.
*      ls_selop-low              = ls_ensgn-ensgn+1.
      ls_selop-low              = ls_ensgn-vkorg.
      APPEND ls_selop TO lr_ensgn-select_options.
    ENDIF.
  ENDLOOP.

  IF lv_vkorg IS NOT INITIAL.
    DELETE  lr_ensgn-select_options WHERE low NE  lv_vkorg.
    IF lr_ensgn IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  SORT lr_ensgn-select_options BY low.
  DELETE ADJACENT DUPLICATES FROM lr_ensgn-select_options.

  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_REC_STATS'
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_dmntx
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.

*********  READ TABLE it_key_tab INTO DATA(ls_keytb) WITH KEY name = 'TITRE'.
*********  IF sy-subrc EQ 0.
*********    lv_titre                      = ls_keytb-value.
*********  ELSE.
*********    READ TABLE  it_filter_select_options INTO ls_filtr WITH KEY property = 'TITRE'.
*********    IF sy-subrc EQ 0.
*********      lv_titre                    = ls_filtr-select_options[ 1 ]-low.
*********    ENDIF.
*********  ENDIF.
*********  IF sy-subrc EQ 0 AND lv_titre IS NOT INITIAL.
*********    CONCATENATE 'd~FTNUM LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_where.
*********
*********    CONCATENATE 'OR d~TITRE LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_where.
*********
*********    CONCATENATE 'd~SRNUM LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_wher2.
*********
*********    CONCATENATE 'OR d~TITRE LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_wher2.
*********
*********    TRANSLATE lv_titre TO UPPER CASE.
*********    CONCATENATE 'OR d~FTNUM LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_where.
*********
*********    CONCATENATE 'OR d~TITRE LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_where.
*********
*********    CONCATENATE 'OR d~SRNUM LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_wher2.
*********
*********    CONCATENATE 'OR d~TITRE LIKE ''%' lv_titre '%''' INTO ls_where RESPECTING BLANKS.
*********    APPEND ls_where TO lt_wher2.
*********
*********  ENDIF.


  IF lt_maktx[] IS INITIAL AND lt_numfr[] IS INITIAL.
    SELECT      SINGLE low
    INTO        lv_dispn
    FROM        tvarvc
    WHERE       name EQ 'ZFT_N_DISPLAYED'.
    IF lv_dispn IS INITIAL.
      lv_dispn                    = 15. "Valeur par defaut choisi
    ENDIF.

    lv_nblin                      = lv_dispn * 10.

    SELECT  d~ftnum AS frnum, d~titre, d~stats, v~apfin AS apfi2, v~apdeb AS apde2, v~ftver , '-' AS descr, n~wgbez AS class, d~erdat, d~aedat
    INTO    CORRESPONDING FIELDS OF TABLE @lt_entty
    UP TO   @lv_nblin ROWS
    FROM    zmm_ft_def AS d
    INNER   JOIN zmm_ft_ens AS e ON d~ftnum EQ e~ftnum
    INNER   JOIN zgld_enseigne AS g  ON g~ensgn EQ e~ensgn
    INNER   JOIN zmm_ft_ver AS v ON d~ftnum EQ v~ftnum
    INNER   JOIN mara       AS m ON d~ftnum EQ m~matnr
    INNER   JOIN t023t      AS n ON m~matkl EQ n~matkl
*    WHERE   e~ensgn IN @lr_ensgn-select_options
    WHERE   g~vkorg EQ @lv_vkorg
    AND     v~apdeb LE @sy-datum
    AND     v~apfin GE @sy-datum
    AND     n~spras EQ 'FR'
    ORDER   BY d~erdat DESCENDING.
*****    AND     ( (lt_where) ).

    SELECT  d~srnum AS frnum, v~srver AS ftver, d~titre, d~stats , v~descr, n~wgbez AS class, v~srtft, v~apfin AS apfi2, v~apdeb AS apde2, d~erdat, d~aedat
    APPENDING CORRESPONDING FIELDS OF TABLE @lt_entty
    UP TO   @lv_nblin ROWS
    FROM    zmm_sr_def AS d
    INNER   JOIN zmm_sr_ens AS e ON d~srnum EQ e~srnum
    INNER   JOIN zgld_enseigne AS g  ON g~ensgn EQ e~ensgn
    INNER   JOIN zmm_sr_ver AS v ON d~srnum EQ v~srnum
    INNER   JOIN t023t      AS n ON d~famil EQ n~matkl
*    WHERE   e~ensgn IN @lr_ensgn-select_options
    WHERE   g~vkorg EQ @lv_vkorg
    AND     d~stats NE '25'  "Exclut les SR transformees
    AND     n~spras EQ 'FR'
    ORDER   BY d~erdat DESCENDING.
****    AND     ( (lt_wher2) ).
  ELSE.
    SELECT  d~ftnum AS frnum, d~titre, d~stats, v~apfin AS apfi2, v~apdeb AS apde2, v~ftver , '-' AS descr, n~wgbez AS class
    INTO    CORRESPONDING FIELDS OF TABLE @lt_entty
    FROM    zmm_ft_def AS d
    INNER   JOIN zmm_ft_ens AS e ON d~ftnum EQ e~ftnum
    INNER   JOIN zgld_enseigne AS g  ON g~ensgn EQ e~ensgn
    INNER   JOIN zmm_ft_ver AS v ON d~ftnum EQ v~ftnum
    INNER   JOIN mara       AS m ON d~ftnum EQ m~matnr
    INNER   JOIN makt       AS k on m~matnr EQ k~matnr
    INNER   JOIN t023t      AS n ON m~matkl EQ n~matkl
    WHERE   g~vkorg EQ @lv_vkorg
    AND     v~apdeb LE @sy-datum
    AND     v~apfin GE @sy-datum
    AND     d~ftnum IN @lt_numfr
*    AND     d~titre IN @lt_maktx
    AND     n~spras EQ 'FR'
    AND     k~spras EQ 'FR'
    AND     k~maktg IN @lt_maktx.
****    AND     ( (lt_where) ).

    SELECT  d~srnum AS frnum, v~srver AS ftver, d~titre, d~stats , v~descr, n~wgbez AS class, v~srtft, v~apfin AS apfi2, v~apdeb AS apde2
    APPENDING CORRESPONDING FIELDS OF TABLE @lt_entty
    FROM    zmm_sr_def AS d
    INNER   JOIN zmm_sr_ens AS e ON d~srnum EQ e~srnum
    INNER   JOIN zgld_enseigne AS g  ON g~ensgn EQ e~ensgn
    INNER   JOIN zmm_sr_ver AS v ON d~srnum EQ v~srnum
    INNER   JOIN t023t      AS n ON d~famil EQ n~matkl
    WHERE   g~vkorg EQ @lv_vkorg
    AND     d~stats NE '25'  "Exclut les SR transformees
    AND     d~srnum IN @lt_numfr
    AND     d~titrg IN @lt_maktx
    AND     n~spras EQ 'FR'.
****    AND     ( (lt_wher2) ).

  ENDIF.






  IF lv_niv_1 EQ 'X'.
    SELECT  DISTINCT fting AS frnum
    INTO    TABLE lt_frnum
    FROM    zmm_ft_ing
    FOR ALL ENTRIES IN lt_entty
    WHERE   fting     EQ lt_entty-frnum.

    SELECT  DISTINCT sring AS frnum
    APPENDING TABLE lt_frnum
    FROM    zmm_sr_ing
    FOR ALL ENTRIES IN lt_entty
    WHERE   sring     EQ lt_entty-frnum.
  ENDIF.

  IF lt_entty IS NOT INITIAL.
    APPEND LINES OF lt_entty TO lt_entcp.
    SORT lt_entcp BY frnum ASCENDING apde2 DESCENDING.

    SORT lt_entty BY frnum ftver.
    DELETE ADJACENT DUPLICATES FROM lt_entty COMPARING frnum ftver.

    LOOP AT lt_entty INTO ls_entty.

      IF lv_frnum EQ ls_entty-frnum.
        CONTINUE.
      ENDIF.

      IF lv_niv_1 EQ 'X'.
        READ TABLE lt_frnum TRANSPORTING NO FIELDS WITH KEY table_line = ls_entty-frnum.

        CHECK sy-subrc NE 0.
      ENDIF.

*     Check the version
      IF ls_entty-frnum+0(2) EQ 'SR'.
        READ TABLE lt_entcp INTO ls_entty WITH KEY frnum = ls_entty-frnum srtft = 'X'.
        IF sy-subrc NE 0.
          READ TABLE lt_entcp INTO ls_entty WITH KEY frnum = ls_entty-frnum.
        ENDIF.
      ENDIF.

      IF strlen( ls_entty-apde2 ) EQ 7.
        CONCATENATE '0' ls_entty-apde2 INTO ls_entty-apde2.
      ENDIF.
      IF strlen( ls_entty-apfi2 ) EQ 7.
        CONCATENATE '0' ls_entty-apfi2 INTO ls_entty-apfi2.
      ENDIF.
      ls_entty-apdeb              = ls_entty-apde2.
      ls_entty-apfin              = ls_entty-apfi2.

      READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = ls_entty-stats.
      IF sy-subrc EQ 0.
        ls_entty-tstat             = ls_dmntx-ddtext.
      ENDIF.

      APPEND ls_entty TO lt_entit.
***      APPEND ls_entty TO et_entityset.
      lv_frnum                    = ls_entty-frnum.
    ENDLOOP.
  ENDIF.

  SORT  lt_entit BY aedat DESCENDING.
  IF lv_dispn IS NOT INITIAL.
    DELETE lt_entit FROM lv_dispn + 1 .
  ENDIF.

  et_entityset[]                  = lt_entit[].
  me->handle_paging(  EXPORTING is_pagin  = is_paging
                      CHANGING  ct_entty  = et_entityset ).

ENDMETHOD.