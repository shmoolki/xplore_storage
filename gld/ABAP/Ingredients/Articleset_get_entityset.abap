METHOD articleset_get_entityset.
  TYPES:  BEGIN OF tt_artcl.
            INCLUDE TYPE zcl_zft_gw_cat_mat1ere_mpc=>ts_article.
            TYPES: bbtyp  TYPE bbtyp,
                   ersd2  TYPE ersda,
                   laed2  TYPE laeda,
                   mstae  TYPE mstae,
                   umrez  TYPE umrez,
                   umren  TYPE umren,
                   bstme  TYPE bstme,
                   sokey  TYPE zft_gw_sokey,
                   gewei  TYPE gewei,
          END OF tt_artcl,
          BEGIN OF ts_tempb.
            TYPES: tempb TYPE tempb,
                   tbtxt TYPE tbtxt,
          END OF ts_tempb,
          BEGIN OF tt_afsrc.
            INCLUDE TYPE zmm_af_src.
            TYPES: ordre  TYPE zmm_stats_ordr,
          END OF tt_afsrc.

  DATA: lv_arcid    TYPE saeardoid,
        lv_artty    TYPE c,
        lv_atinn    TYPE atinn,
        lv_atwrt    TYPE string,
        lv_brgew    TYPE brgew VALUE '1.00',
        lv_count    TYPE i,
        lv_distb    TYPE c,
        lv_dupli    TYPE xfeld,
        lv_filtr    TYPE string,
        lv_flpmd    TYPE xfeld,               " Fiori Launchpad mode (requete allegee)
        lv_lnobj    TYPE int4,
        lv_matnr    TYPE matnr,
        lv_matn2    TYPE matnr,
        lv_objct    TYPE saeanwdid,
        lv_objid    TYPE saeobjid,
        lv_perte    TYPE zmm_perte,
        lv_qntty    TYPE menge_d,
        lv_srcvs    TYPE xfeld,
        lv_statf    TYPE string,
        lv_vlcrn    TYPE zft_gw_vlcrn,
        lv_wwghb    TYPE string,
        lv_dispn    TYPE rvari_val_255, "Default to display
        lv_uptos    TYPE string,
        lv_nbent    TYPE i,
        lv_nblin    TYPE i,
        lv_nbln2    TYPE i,
        lv_vkorg    TYPE vkorg,
        ls_afsrc    TYPE tt_afsrc,
        ls_afsr2    TYPE tt_afsrc,
        ls_arcob    TYPE zao_s_toauri,
        ls_artc2    TYPE tt_artcl,
        ls_artcl    TYPE tt_artcl,
        ls_cawnt    TYPE cawnt,
        ls_chrct    TYPE bapimatcha,
        ls_dmntx    TYPE dd07v,
        ls_entit    TYPE zcl_zft_gw_cat_mat1ere_mpc=>ts_article,
        ls_hiera    TYPE zmm_art_hierarch,
        ls_filtr    TYPE /iwbep/s_mgw_select_option,
        ls_imgdt    TYPE zmm_ar_imgdt,
        ls_pline    TYPE zmm_s_ft_val_pline,
        ls_slfa1    TYPE lfa1,
        ls_smarc    TYPE marc,
        ls_smarm    TYPE marm,
        ls_retr1    TYPE bapireturn1 ##NEEDED,
        ls_retrn    TYPE bapiret2,
        ls_selop    TYPE /iwbep/s_cod_select_option,
        ls_statf    TYPE /iwbep/s_cod_select_option,
        ls_wwghb    TYPE /iwbep/s_cod_select_option,
        ls_tempd    TYPE ts_tempb,
        ls_tlfmh    TYPE lfmh,
        lt_arcob    TYPE zao_t_toauri,
        lt_artcl    TYPE TABLE OF tt_artcl,
        lt_artc2    TYPE TABLE OF tt_artcl,
        lt_cawnt    TYPE TABLE OF cawnt,
        lt_chrct    TYPE TABLE OF bapimatcha,
        lt_chrc2    TYPE TABLE OF bapimatcha,
        lt_tmarc    TYPE TABLE OF marc,
        lt_matnr    TYPE /iwbep/t_cod_select_options,
        lt_maktx    TYPE /iwbep/t_cod_select_options,
        lt_atwrt    TYPE /iwbep/t_cod_select_options,
        lt_atwtb    TYPE /iwbep/t_cod_select_options ##NEEDED,
        lt_dmnt2    TYPE TABLE OF dd07v,
        lt_dmntt    TYPE TABLE OF dd07v,
        lt_dmntx    TYPE TABLE OF dd07v,
        lt_mfrnm    TYPE /iwbep/t_cod_select_options ##NEEDED,
        lt_mfrnr    TYPE /iwbep/t_cod_select_options,
        lt_statf    TYPE /iwbep/t_cod_select_options,
        lt_tempb    TYPE /iwbep/t_cod_select_options,
        lt_tempd    TYPE TABLE OF ts_tempb,
        lt_distb    TYPE /iwbep/t_cod_select_options,
        ls_distb    TYPE /iwbep/s_cod_select_option,
        ls_tempb    TYPE /iwbep/s_cod_select_option,
*        ls_distb    TYPE /iwbep/s_cod_select_option,
        lt_wwghb    TYPE /iwbep/t_cod_select_options,
        lt_ctnum    TYPE /iwbep/t_cod_select_options,
        lt_afsrc    TYPE TABLE OF tt_afsrc.


  FIELD-SYMBOLS <artcl> TYPE zcl_zft_gw_cat_mat1ere_mpc=>ts_article.
  FIELD-SYMBOLS <artc2> TYPE zcl_zft_gw_cat_mat1ere_mpc=>ts_article.
  FIELD-SYMBOLS <tempd> TYPE ts_tempb.

*  IF it_filter_select_options[] IS INITIAL.
*    RETURN.
    SELECT      SINGLE low
    INTO        lv_dispn
    FROM        tvarvc
    WHERE       name EQ 'ZING_LAST_ING_DISPLAYED'.
*  ENDIF.
**************Get filters*************************************************  BEG *
* Get ARTTY
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'ARTTY'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
      TRANSLATE ls_selop-low TO UPPER CASE.
      lv_artty                        = ls_selop-low.
    ENDIF.
  ENDIF.
* Get ATWTB
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'ATWTB'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
      TRANSLATE ls_selop-low TO UPPER CASE.
      APPEND ls_selop TO lt_atwtb.
    ENDIF.
  ENDIF.
* Get ATWRT
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'ATWRT'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_atwrt.
      ENDIF.
    ENDLOOP.
*    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
*    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
*      TRANSLATE ls_selop-low TO UPPER CASE.
*      lv_atwrt                        = ls_selop-low.
*      APPEND ls_selop TO lt_atwrt.
*    ENDIF.
  ENDIF.
* Get MAKTX
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'MAKTX'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_maktx.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
* Get MATNR
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'MATNR'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low EQ '@'.
*       Fiori Launchpad mode
        lv_flpmd                  = abap_true.

        EXIT.
      ENDIF.

      ls_selop-sign                   = 'I'.
      IF ls_selop-low IS NOT INITIAL.
        lv_matnr                      = ls_selop-low.
        lv_matn2                      = lv_matnr.
        lv_lnobj                      = strlen( lv_matnr ) - 1.
        lv_lnobj                      = 18 - lv_lnobj.

        TRANSLATE lv_matnr TO UPPER CASE.
        ls_selop-low                  = lv_matnr.
        APPEND ls_selop TO lt_matnr.
        DO lv_lnobj TIMES.
              CONCATENATE '0' lv_matnr INTO lv_matnr.
              TRANSLATE lv_matnr TO UPPER CASE.
              ls_selop-low            = lv_matnr.
              APPEND ls_selop TO lt_matnr.
        ENDDO.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                EXPORTING
                  input               = lv_matn2
                IMPORTING
                  output              = lv_matnr
                EXCEPTIONS
                  OTHERS              = 0.
        ls_selop-low                  = lv_matnr.
        APPEND ls_selop TO lt_matnr.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
* Get MFRNR
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'MFRNR'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_mfrnr.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
* Get MFRNM
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'MFRNM'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_mfrnm.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
* Get SRCVS
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'SRCVS'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
      TRANSLATE ls_selop-low TO UPPER CASE.
      lv_srcvs                        = ls_selop-low.
    ENDIF.
  ENDIF.
* Get STATS
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'STATS'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_statf.
      ENDIF.
    ENDLOOP.


*    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
*    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
*      APPEND ls_selop TO lt_statf.
*      TRANSLATE ls_selop-low TO UPPER CASE.
*      REPLACE ALL OCCURRENCES OF '*' IN ls_selop-low WITH ''.
*      lv_statf                        = ls_selop-low.
*    ENDIF.
  ENDIF.

* Get TEMPB
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'TEMPB'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_tempb.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
* Get DISTB
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'DISTB'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_distb.
      ENDIF.
    ENDLOOP.
*    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
*    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
*      TRANSLATE ls_selop-low TO UPPER CASE.
*      APPEND ls_selop TO lt_distb.
*      REPLACE ALL OCCURRENCES OF '*' IN ls_selop-low WITH ''.
*      lv_distb                        = ls_selop-low.
*    ENDIF.
  ENDIF.
* Get ARTTY
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'ARTTY'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
      TRANSLATE ls_selop-low TO UPPER CASE.
      lv_artty                        = ls_selop-low.
    ENDIF.
  ENDIF.
* Get WWGHB
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'WWGHB'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        APPEND ls_selop TO lt_wwghb.
      ENDIF.
    ENDLOOP.
*    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
*    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
*      APPEND ls_selop TO lt_wwghb.
*      REPLACE ALL OCCURRENCES OF '*' IN ls_selop-low WITH ''.
*      lv_wwghb                        = ls_selop-low.
*    ENDIF.
  ENDIF.

* Get CTNUM
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'CTNUM'.
  IF sy-subrc EQ 0 AND ls_filtr-select_options[] IS NOT INITIAL.
    READ TABLE ls_filtr-select_options INTO ls_selop INDEX 1.
    IF sy-subrc EQ 0 AND ls_selop IS NOT INITIAL.
      TRANSLATE ls_selop-low TO UPPER CASE.
      APPEND ls_selop TO lt_ctnum.
    ENDIF.
  ENDIF.
**************Get filters*************************************************  END *

**************Initialisation*************************************************  BEG *
*  CALL FUNCTION 'DD_DOMA_GET'
*    EXPORTING
*      domain_name                     = 'ZMM_FT_VH_STATS'
*      langu                           = sy-langu
*      prid                            = 0
*      withtext                        = 'X'
*    TABLES
*      dd07v_tab_a                     = lt_dmntx
*      dd07v_tab_n                     = lt_dmntt
*    EXCEPTIONS
*      illegal_value                   = 1
*      op_failure                      = 2
*      OTHERS                          = 3.

* Modif Id stats MP
  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_MP_STATS'
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

  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_AR_STATS'
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_dmnt2
      dd07v_tab_n                 = lt_dmntt
    EXCEPTIONS
      illegal_value               = 1
      op_failure                  = 2
      OTHERS                      = 3.

  APPEND LINES OF lt_dmnt2 TO lt_dmntx.

  IF lt_dmntx IS INITIAL.
    ls_retrn-type                     = 'W'.
    ls_retrn-id                       = 'ZMM'.
    ls_retrn-number                   = '132'.

    me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                      iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                      iv_add_to_response_header = abap_true
                                                                      iv_message_target         = 'W' ).
  ENDIF.

  SELECT DISTINCT tempb, tbtxt
  INTO CORRESPONDING FIELDS OF TABLE @lt_tempd
  FROM t143t
  WHERE spras EQ 'FR'.

  LOOP AT lt_tempd ASSIGNING <tempd>.
    REPLACE ALL OCCURRENCES OF 'GLD - ' IN <tempd>-tbtxt WITH ''.
    CONDENSE <tempd>-tbtxt.
  ENDLOOP.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input                       = 'TYPOLOGIE'
    IMPORTING
      output                      = lv_atinn.

  SELECT  *
  INTO    TABLE lt_cawnt
  FROM    cawnt
  WHERE   atinn   EQ lv_atinn
  AND     spras   EQ sy-langu.

**************Initialisation*************************************************  END *
  IF lv_artty EQ 'R' OR lv_artty IS INITIAL.
**************Get real items**********************************************  BEG *
    IF lv_dispn IS NOT INITIAL.
      lv_nblin                    = lv_dispn * 30.
      SELECT m~matnr, m~matnr AS rmatn, m~laeda AS laed2, m~ersda AS ersd2, m~mhdrz, k~maktx, m~matkl, k~maktg, l~name1 AS mfrnm, m~tempb, m~aenam, m~ntgew, m~gewei,
****             w~bbtyp, e~lifnr AS mfrnr, m~meins, m~mstae, r~umrez, r~umren , p~meins AS bstme, h~lv3nm AS wwghb
             w~bbtyp, e~lifnr AS mfrnr, m~meins, m~mstae, r~umrez, r~umren , e~meins AS bstme, h~lv3nm AS wwghb
      INTO CORRESPONDING FIELDS OF TABLE @lt_artcl
      UP TO @lv_nblin ROWS
      FROM mara AS m
****      LEFT OUTER JOIN eina AS e ON m~matnr  EQ e~matnr
      LEFT OUTER JOIN eina AS e ON m~matnr  EQ e~matnr AND e~loekz NE 'X'
****      LEFT OUTER JOIN eina AS p ON p~matnr  EQ m~matnr AND p~loekz NE 'X' "AND p~lifnr LIKE 'VZ%'
*****     Ajout jointure EINE pour remonte FIA de Org 1000
****      LEFT OUTER JOIN eine AS i ON i~infnr EQ p~infnr AND i~ekorg EQ '1000'
      LEFT OUTER JOIN lfa1 AS l ON e~lifnr  EQ l~lifnr
      LEFT OUTER JOIN makt AS k ON m~matnr  EQ k~matnr
      LEFT OUTER JOIN maw1 AS w ON m~matnr  EQ w~matnr
      LEFT OUTER JOIN marm AS r ON m~matnr  EQ r~matnr AND r~meinh EQ m~meins
      LEFT OUTER JOIN zmm_art_hierarch AS h ON h~matkl  EQ m~matkl
      WHERE m~mtart EQ 'ZAWA'
      AND ( m~attyp EQ '02' AND m~bflme EQ '3' )
      AND   e~loekz NE 'X'
      AND   k~spras EQ @sy-langu
      AND   m~matnr IN @lt_matnr
      AND   k~maktg IN @lt_maktx
      AND   m~tempb IN @lt_tempb
      AND   h~lv3nm IN @lt_wwghb
      AND ( l~lifnr IN @lt_mfrnr OR l~name1 IN @lt_mfrnr )
      ORDER BY ersda DESCENDING.
    ELSE.
      SELECT m~matnr, m~matnr AS rmatn, m~laeda AS laed2, m~ersda AS ersd2, m~mhdrz, k~maktx, m~matkl, k~maktg, l~name1 AS mfrnm, m~tempb, m~aenam, m~ntgew, m~gewei,
****             w~bbtyp, e~lifnr AS mfrnr, m~meins, m~mstae, r~umrez, r~umren , p~meins AS bstme, h~lv3nm AS wwghb
             w~bbtyp, e~lifnr AS mfrnr, m~meins, m~mstae, r~umrez, r~umren , e~meins AS bstme, h~lv3nm AS wwghb
      INTO CORRESPONDING FIELDS OF TABLE @lt_artcl
      FROM mara AS m
****      LEFT OUTER JOIN eina AS e ON m~matnr  EQ e~matnr
      LEFT OUTER JOIN eina AS e ON m~matnr  EQ e~matnr AND e~loekz NE 'X'
****      LEFT OUTER JOIN eina AS p ON p~matnr  EQ m~matnr AND p~loekz NE 'X' "AND p~lifnr LIKE 'VZ%'
*****     Ajout jointure EINE pour remonte FIA de Org 1000
****      LEFT OUTER JOIN eine AS i ON i~infnr EQ p~infnr AND i~ekorg EQ '1000'
      LEFT OUTER JOIN lfa1 AS l ON e~lifnr  EQ l~lifnr
      LEFT OUTER JOIN makt AS k ON m~matnr  EQ k~matnr
      LEFT OUTER JOIN maw1 AS w ON m~matnr  EQ w~matnr
      LEFT OUTER JOIN marm AS r ON m~matnr  EQ r~matnr AND r~meinh EQ m~meins
      LEFT OUTER JOIN zmm_art_hierarch AS h ON h~matkl  EQ m~matkl
      WHERE m~mtart EQ 'ZAWA'
      AND ( m~attyp EQ '02' AND m~bflme EQ '3' )
      AND   e~loekz NE 'X'
      AND   k~spras EQ @sy-langu
      AND   m~matnr IN @lt_matnr
      AND   k~maktg IN @lt_maktx
      AND   m~tempb IN @lt_tempb
      AND   h~lv3nm IN @lt_wwghb
      AND ( l~lifnr IN @lt_mfrnr OR l~name1 IN @lt_mfrnr ).
    ENDIF.


*    ********************************************************************** 23/05/01 bug sur fournisseur dans Overview
    DATA: lt_tmpar  TYPE  TABLE OF tt_artcl,
          lt_teina  TYPE  TABLE OF eina,
          ls_teina  TYPE  eina,
          lv_lines  TYPE  i.
    FIELD-SYMBOLS: <fs_artcl> TYPE tt_artcl.

    SORT lt_artcl BY matnr mfrnr.
    DELETE ADJACENT DUPLICATES FROM lt_artcl COMPARING matnr mfrnr.

    lt_tmpar[]                    = lt_artcl[]. " Table temporaire

    LOOP AT lt_tmpar INTO ls_artcl.
      CLEAR: lv_vkorg.

      IF ls_artcl-bbtyp EQ 'L'.
        lv_vkorg                  = '2000'.
      ELSE.
        lv_vkorg                  = '1000'.
      ENDIF.

      SELECT  *
      INTO    CORRESPONDING FIELDS OF TABLE lt_teina
      FROM    eina  AS a
      INNER   JOIN  eine AS e ON e~infnr EQ a~infnr
      WHERE   a~matnr   EQ ls_artcl-matnr
      AND     a~loekz   NE 'X'
      AND     e~ekorg   EQ lv_vkorg
      AND     e~loekz   NE 'X'.

      IF sy-subrc EQ 0.
        DESCRIBE TABLE lt_teina LINES lv_lines.
        LOOP AT lt_teina INTO ls_teina.
          IF ls_artcl-bbtyp EQ 'L'.
            IF lv_lines GT 1.
              LOOP AT lt_artcl ASSIGNING <fs_artcl> WHERE matnr EQ ls_artcl-matnr.
                CLEAR : <fs_artcl>-mfrnr, <fs_artcl>-mfrnm.
                <fs_artcl>-mfrnm           = text-020.
              ENDLOOP.
            ENDIF.
          ELSE.
            READ TABLE lt_tmpar INTO ls_artc2 WITH KEY matnr = ls_artcl-matnr mfrnr = ls_teina-lifnr.
            IF sy-subrc EQ 0.
              DELETE lt_artcl WHERE matnr EQ ls_artcl-matnr AND mfrnr NE ls_artc2-mfrnr.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT lt_artcl ASSIGNING <fs_artcl> WHERE matnr EQ ls_artcl-matnr.
          CLEAR : <fs_artcl>-mfrnr, <fs_artcl>-mfrnm.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

*    **********************************************************************
    SORT lt_artcl BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_artcl COMPARING matnr.

    IF lv_flpmd EQ abap_true.
*      DELETE lt_artcl WHERE mstae EQ '03'.
      DELETE lt_artcl WHERE mstae EQ 'Z3'.

      MOVE-CORRESPONDING lt_artcl TO et_entityset.

      RETURN.
    ENDIF.

*   IF sy-subrc EQ 0 AND lt_artcl IS NOT INITIAL.
    IF lt_artcl IS NOT INITIAL.
      LOOP AT lt_artcl INTO ls_artcl.
        CLEAR ls_entit.

        ls_artcl-artty            = 'R'.
        IF ls_artcl-rmatn IS INITIAL.
          ls_artcl-rmatn          = ls_artcl-matnr.
        ENDIF.
        READ TABLE lt_tempd INTO ls_tempd WITH KEY tempb = ls_artcl-tempb.
        IF sy-subrc EQ 0.
          ls_artcl-tbtxt          = ls_tempd-tbtxt.
        ENDIF.
        ls_artcl-ersda            = ls_artcl-ersd2.
        ls_artcl-laeda            = ls_artcl-laed2.
        ls_artcl-fictf            = abap_false.
        IF ls_artcl-bbtyp EQ 'L'.
          ls_artcl-distb          = 'L'. "Local
          ls_artcl-vendr          = text-007 ."'Direct'
          ls_artcl-distt          = text-007 ."'Direct'
        ELSE.
          ls_artcl-distb          = 'P'. "Plateforme
          ls_artcl-vendr          = text-006. "'Plateforme'
          ls_artcl-distt          = text-006. "'Plateforme'
        ENDIF.
        IF lv_distb IS NOT INITIAL AND ls_artcl-distb NE lv_distb.
          CONTINUE.
        ENDIF.

        SELECT  SINGLE *
        INTO    CORRESPONDING FIELDS OF ls_smarm
        FROM    marm
        WHERE   meinh LIKE 'VL%'
        AND     matnr EQ ls_artcl-matnr.

        IF sy-subrc EQ 0.

           lv_brgew                = ls_artcl-ntgew.

          CALL FUNCTION 'OIB_MATERIAL_UNIT_CONVERSION'
            EXPORTING
              iv_matnr            = ls_artcl-matnr
              iv_inuom            = 'VL'
              iv_outuom           = ls_artcl-meins
              iv_quantity         = lv_brgew
            IMPORTING
              ev_quantity         = lv_qntty
            EXCEPTIONS
              error_material_read = 1
              conversion_failed   = 2
              OTHERS              = 3.

          IF sy-subrc EQ 0.
            IF ls_artcl-gewei EQ 'G'.
              lv_qntty                = lv_qntty / 1000.
            ENDIF.
            ls_artcl-ntgew        = lv_qntty.
          ENDIF.

          lv_brgew                = '1.00'.
          CALL FUNCTION 'OIB_MATERIAL_UNIT_CONVERSION'
            EXPORTING
              iv_matnr            = ls_artcl-matnr
              iv_inuom            = 'KAR'
              iv_outuom           = ls_smarm-meinh
              iv_quantity         = lv_brgew
            IMPORTING
              ev_quantity         = lv_qntty
            EXCEPTIONS
              error_material_read = 1
              conversion_failed   = 2
              OTHERS              = 3.

          IF sy-subrc EQ 0 AND lv_qntty IS NOT INITIAL.
            WRITE lv_qntty TO ls_artcl-vlcrn LEFT-JUSTIFIED NO-GROUPING NO-GAP.
          ELSE.
            ls_artcl-vlcrn        = 1.
          ENDIF.
        ELSE.
          ls_artcl-vlcrn          = 1.
        ENDIF.

        IF ls_artcl-bbtyp NE 'L'.
*            IF ls_artcl-bstme NE 'CRN' AND ls_artcl-bstme NE 'KAR'.
*              ls_artcl-dcdtd        = 'O'.
*            ELSE.
*              ls_artcl-dcdtd        = 'N'.
*            ENDIF.
          SELECT  SINGLE *
          INTO    CORRESPONDING FIELDS OF ls_teina
          FROM    eina  AS a
          INNER   JOIN  eine AS e ON e~infnr EQ a~infnr
          WHERE   a~matnr   EQ ls_artcl-matnr
          AND     a~loekz   NE 'X'
          AND     e~ekorg   EQ '2000'
          AND     e~loekz   NE 'X'.

          IF sy-subrc EQ 0.
            IF ls_teina-meins NE  'CRN' AND ls_teina-meins NE 'KAR'.
              ls_artcl-dcdtd       = 'O'.
            ELSE.
               ls_artcl-dcdtd      = 'N'.
            ENDIF.
          ENDIF.
        ELSE.
          ls_artcl-dcdtd          = '-'.
        ENDIF.

        IF  ls_artcl-distb EQ 'L'.
          CLEAR lv_count.

          SELECT  SINGLE *
          INTO    CORRESPONDING FIELDS OF ls_tlfmh
          FROM    lfmh
          WHERE   lifnr   EQ  ls_artcl-mfrnr.

          IF sy-subrc EQ 0 AND ls_tlfmh-hlifnr IS NOT INITIAL.
            ls_artcl-mfrnr        = ls_tlfmh-hlifnr.

            CALL FUNCTION 'LFA1_SINGLE_READ'
              EXPORTING
                lfa1_lifnr        = ls_artcl-mfrnr
              IMPORTING
                wlfa1             = ls_slfa1
              EXCEPTIONS
                not_found         = 1
                lifnr_blocked     = 2
                OTHERS            = 3.
            IF sy-subrc EQ 0.
              ls_artcl-mfrnm      = ls_slfa1-name1.
            ENDIF.

            SELECT COUNT( * )
            INTO    lv_count
            FROM    lfmh
            WHERE   lifnr   EQ ls_artcl-mfrnr.

*            IF lv_count LE 1 AND sy-subrc EQ 0.
*              ls_artcl-distt      = ls_artcl-mfrnm.
*            ELSE.
*              ls_artcl-distt      = text-008. "'local'
*            ENDIF.
          ELSE.
            CALL FUNCTION 'LFA1_SINGLE_READ'
              EXPORTING
                lfa1_lifnr        = ls_artcl-mfrnr
              IMPORTING
                wlfa1             = ls_slfa1
              EXCEPTIONS
                not_found         = 1
                lifnr_blocked     = 2
                OTHERS            = 3.
            IF sy-subrc EQ 0.
              ls_artcl-mfrnm      = ls_slfa1-name1.
            ENDIF.

            SELECT COUNT( * )
            INTO    lv_count
            FROM    lfmh
            WHERE   lifnr   EQ ls_artcl-mfrnr.

*            IF lv_count LE 1 OR sy-subrc EQ 0.
*              ls_artcl-distt      = ls_artcl-mfrnm.
*            ELSE.
*              ls_artcl-distt      = text-008. "'local'
*            ENDIF.
          ENDIF.
        ELSE.
          SELECT  SINGLE name1
          INTO    ls_artcl-mfrnm
          FROM    lfa1
          WHERE   lifnr EQ ls_artcl-mfrnr.

          ls_artcl-distt          = text-006. "'plateforme'.
        ENDIF.
*  ********Get Status**************************************************  BEG *
        IF ls_artcl-mstae EQ 'Z3'.
          ls_artcl-tstat          = text-001. "Fermeture générale
          ls_artcl-stats          = '1'.
          IF lv_statf IS INITIAL AND it_filter_select_options IS INITIAL.
            CONTINUE.
          ENDIF.
        ELSE.
          SELECT *
          INTO TABLE lt_tmarc
          FROM marc
          WHERE matnr EQ ls_artcl-matnr
          AND   werks IN ( 'R120' , 'R100' ).

          IF sy-subrc EQ 0 AND lt_tmarc IS NOT INITIAL.
            READ TABLE lt_tmarc INTO ls_smarc WITH KEY werks = 'R120' mmsta = 'Z3'.
            IF sy-subrc EQ 0 AND ls_smarc IS NOT INITIAL.
              ls_artcl-tstat      = text-002. "Fermé sur les Cadenciers
              ls_artcl-stats      = '2'.
            ELSE.
              READ TABLE lt_tmarc INTO ls_smarc WITH KEY werks = 'R120' mmsta = 'Z9'.
              IF sy-subrc EQ 0 AND ls_smarc IS NOT INITIAL.
                ls_artcl-tstat    = text-003. "En attente d'ouverture Cadenciers
                ls_artcl-stats    = '3'.
              ELSE.
                READ TABLE lt_tmarc INTO ls_smarc WITH KEY werks = 'R100' mmsta = 'Z3'.
                IF sy-subrc EQ 0 AND ls_smarc IS NOT INITIAL.
                  ls_artcl-tstat  = text-004. "Stop Appro PtF
                  ls_artcl-stats  = '4'.
                ELSE.
                  ls_artcl-tstat  = ''.
                  ls_artcl-stats  = ''.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            ls_artcl-tstat        = ''.
            ls_artcl-stats        = ''.
          ENDIF.
        ENDIF.

        IF lt_statf IS NOT INITIAL. " AND ls_artcl-stats IS NOT INITIAL.
          READ TABLE lt_statf INTO ls_statf WITH KEY low = ls_artcl-stats.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        lv_filtr                = ls_artcl-stats.
        TRANSLATE lv_filtr TO UPPER CASE.
        IF lv_statf IS NOT INITIAL AND lv_statf NE lv_filtr.
          CONTINUE.
        ENDIF.
*  *****Get Status**************************************************  END *

*  ***********Get Typology******************************************  BEG *
        SELECT  a~atwrt AS char_value a~atzhl AS descr_cval
        INTO    CORRESPONDING FIELDS OF TABLE lt_chrct
        FROM    inob        AS i
        INNER   JOIN ausp   AS a ON a~objek EQ i~cuobj
        WHERE   i~klart   EQ '026'
        AND     i~obtab   EQ 'MARAT'
        AND     i~objek   EQ ls_artcl-matnr
        AND     a~atinn   EQ lv_atinn.

****        IF lv_atwrt IS NOT INITIAL.
****          DELETE lt_chrct WHERE char_value NE lv_atwrt.
****
****          IF lt_chrct[] IS INITIAL.
****            CONTINUE.
****          ENDIF.
****        ENDIF.
        IF lt_atwrt IS NOT INITIAL.
          DELETE lt_chrct WHERE char_value NOT IN lt_atwrt.
          IF lt_chrct[] IS INITIAL.
            CONTINUE.
          ENDIF.
        ENDIF.

        LOOP AT lt_chrct INTO ls_chrct.
          SELECT  SINGLE   vkorg
          INTO    lv_vkorg
          FROM    wrs1
          WHERE   asort EQ ls_chrct-char_value.

          IF sy-subrc EQ 0.
             AUTHORITY-CHECK OBJECT 'W_VKPR_PLT'
               ID 'VKORG' FIELD lv_vkorg
               ID 'VTWEG' FIELD '*'
               ID 'PLTYP' FIELD '*'
               ID 'MATKL' FIELD '*'
               ID 'ACTVT' FIELD '03'.
            IF sy-subrc EQ 0.
              APPEND ls_chrct TO lt_chrc2.
            ENDIF.
          ELSE. " Si ce n'est pas une Gamme on la considere comme autorisee Ex : Non referencee
            APPEND ls_chrct TO lt_chrc2.
          ENDIF.
        ENDLOOP.

        lt_chrct[]                = lt_chrc2[].

        IF lt_chrct[] IS INITIAL.
          CONTINUE.
        ENDIF.
        LOOP AT lt_chrct INTO ls_chrct.
          READ TABLE lt_cawnt INTO ls_cawnt WITH KEY atzhl = ls_chrct-descr_cval+1(3).
          IF sy-subrc EQ 0.
            ls_artcl-atwrt          = ls_chrct-char_value.
            CONCATENATE ls_artcl-atwtb ',' ls_cawnt-atwtb INTO ls_artcl-atwtb SEPARATED BY space.
          ENDIF.
        ENDLOOP.
        IF ls_artcl-atwtb IS NOT INITIAL.
          ls_artcl-atwtb          = ls_artcl-atwtb+2.
        ENDIF.
*  ********Get Typology*********************************************  END *

*  ********Get Family***********************************************  BEG *
*        IF lv_wwghb IS NOT INITIAL AND ls_artcl-matkl+0(6) NE lv_wwghb.
*          CONTINUE.
*        ENDIF.
*
*        ls_hiera                  = zcl_zft_gw_ft_utilities=>get_hierarchy_from_matkl( ls_artcl-matkl ).
*
*        ls_artcl-wwghb            = ls_hiera-lv3nm.

*  ********Get Family***********************************************  END *
*  ********Get Condition Price**************************************  BEG *
        ls_pline                  = zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr = ls_artcl-matnr
                                                                                iv_bdate = sy-datum
                                                                                iv_itype = 'AR'
                                                                                iv_pltyp = 'FR'
                                                                                iv_vkorg = 'ZLOG'
                                                                                iv_vtweg = '10'
                                                                                iv_qtite = '1'
                                                                                iv_unite = ls_artcl-meins
                                                                                iv_perte = lv_perte
                                                                                iv_sokey = '').
        ls_artcl-kbetr            = ls_pline-kbetr.
        ls_artcl-tarap            = ls_pline-kbetr.
*********Get Condition Price**************************************  END *
        MOVE-CORRESPONDING ls_artcl TO ls_entit.

*    *********Get IMSRC********************************************************  BEG *
          CLEAR:  ls_arcob.

          SELECT  SINGLE *
          INTO    CORRESPONDING FIELDS OF ls_imgdt
          FROM    zmm_ar_imgdt
          WHERE   matnr EQ ls_artcl-matnr.

          lv_objct                  = zcl_zft_gw_ft_utilities=>cv_content_article.
          lv_matnr                  = ls_artcl-matnr.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input               = lv_matnr
            IMPORTING
              output              = lv_matnr
            EXCEPTIONS
              OTHERS              = 0.

          lv_objid                = lv_matnr.

          IF ls_artc2-arcid IS NOT INITIAL.
            lv_arcid                = ls_artcl-arcid.

            CALL FUNCTION 'ZAO_DOCUMENT_GET'
              EXPORTING
                iv_objct            = lv_objct
                iv_objid            = lv_objid
                iv_arcid            = lv_arcid
              IMPORTING
                et_arcob            = lt_arcob
              EXCEPTIONS
                OTHERS              = 1.

            IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
*              READ TABLE lt_arcob INTO ls_arcob INDEX 1.
              READ TABLE lt_arcob INTO ls_arcob WITH KEY arc_doc_id = ls_imgdt-arcid.
            ENDIF.
          ELSE.
            CALL FUNCTION 'ZAO_DOCUMENT_GET'
              EXPORTING
                iv_objct            = lv_objct
                iv_objid            = lv_objid
              IMPORTING
                et_arcob            = lt_arcob
              EXCEPTIONS
                OTHERS              = 1.

            IF sy-subrc EQ 0.
              LOOP AT lt_arcob INTO ls_arcob WHERE arc_doc_id EQ ls_imgdt-arcid.
                IF ls_arcob-mimetype CS 'IMAGE'.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.

          ENDIF.

          IF ls_arcob IS NOT INITIAL.
            ls_artcl-imsrc        = ls_arcob-uri.
            ls_entit-imsrc        = ls_arcob-uri.
          ENDIF.
*    *********Get IMSRC********************************************************  END *


*        APPEND ls_artcl TO et_entityset.
        APPEND ls_entit TO et_entityset.
      ENDLOOP.

*     Filtre sur distributeur et statut
      DELETE et_entityset WHERE distb NOT IN lt_distb.
*      DELETE et_entityset WHERE stats NOT IN lt_statf.


    ENDIF.
  ENDIF.
**************Get real items***********************************************  END *
**************Get fict. items**********************************************  BEG *

  IF ( lv_artty EQ 'F' OR lv_artty IS INITIAL )  AND lt_atwrt IS INITIAL AND lt_wwghb IS INITIAL.
    IF lv_srcvs EQ abap_true.

      IF lt_statf IS INITIAL.
        lt_statf                      = me->get_status( ).
      ENDIF.

      IF lv_dispn IS NOT INITIAL.
        SELECT   d~matnr, s~meins, d~laeda AS laed2, d~ersda AS ersd2, d~mhdrz, s~dcdtd, d~maktx, s~rmatn, d~maktg, s~mfrnr, s~distb, s~distt, d~vendr, s~kbetr, s~stats, d~tarap,
                 s~tempb, d~aenam, s~vlcrn, s~ntgew, d~actif,d~fictf, d~werks, d~atwrt, s~mfrnm, d~wwghb, s~sokey
        INTO CORRESPONDING FIELDS OF TABLE @lt_artc2
        UP TO @lv_nblin ROWS
        FROM zmm_af_def AS d
        LEFT OUTER JOIN zmm_af_src AS s ON d~matnr EQ s~matnr
        WHERE d~matnr IN @lt_matnr
        AND   d~maktg IN @lt_maktx
        AND ( s~mfrnr IN @lt_mfrnr OR s~mfrnm IN @lt_mfrnr )
        AND   s~stats IN @lt_statf
        AND   s~tempb IN @lt_tempb
*        AND   d~atwrt IN @lt_atwrt
*        AND   d~wwghb IN @lt_wwghb
        AND   s~distb IN @lt_distb
        AND   d~ctnum IN @lt_ctnum
        ORDER BY ersda DESCENDING.
      ELSE.
        SELECT   d~matnr, s~meins, d~laeda AS laed2, d~ersda AS ersd2, d~mhdrz, s~dcdtd, d~maktx, s~rmatn, d~maktg, s~mfrnr, s~distb, s~distt, d~vendr, s~kbetr, s~stats, d~tarap,
                 s~tempb, d~aenam, s~vlcrn, s~ntgew, d~actif,d~fictf, d~werks, d~atwrt, s~mfrnm, d~wwghb, s~sokey
        INTO CORRESPONDING FIELDS OF TABLE @lt_artc2
        FROM zmm_af_def AS d
        LEFT OUTER JOIN zmm_af_src AS s ON d~matnr EQ s~matnr
        WHERE d~matnr IN @lt_matnr
        AND   d~maktg IN @lt_maktx
        AND ( s~mfrnr IN @lt_mfrnr OR s~mfrnm IN @lt_mfrnr )
        AND   s~stats IN @lt_statf
        AND   s~tempb IN @lt_tempb
*        AND   d~atwrt IN @lt_atwrt
*        AND   d~wwghb IN @lt_wwghb
        AND   d~ctnum IN @lt_ctnum
        AND   s~distb IN @lt_distb
        ORDER BY ersda DESCENDING.
      ENDIF.


      IF sy-subrc EQ 0.
        SORT lt_artc2  BY matnr.
        LOOP AT lt_artc2 INTO ls_artc2.
          CLEAR ls_entit.

          ls_artc2-artty            = 'F'.
          IF ls_artc2-mfrnr IS NOT INITIAL.
            CALL FUNCTION 'LFA1_READ_SINGLE'
              EXPORTING
                id_lifnr            = ls_artc2-mfrnr
              IMPORTING
                es_lfa1             = ls_slfa1
              EXCEPTIONS
                not_found           = 1
                input_not_specified = 2
                lifnr_blocked       = 3
                OTHERS              = 4.

            IF sy-subrc EQ 0.
              ls_artc2-mfrnm        = ls_slfa1-name1.
            ENDIF.
          ENDIF.
          IF ls_artc2-distb EQ 'L'.
            IF ls_artc2-stats EQ '40'.
              ls_artc2-distt        = ls_artc2-mfrnm.
            ELSE.
              ls_artc2-distt        = text-008. "Local
            ENDIF.
          ENDIF.

          IF ls_artc2-distb EQ 'P'.
            ls_artc2-distt          = text-006. "Plateforme
          ENDIF.
          IF ls_artc2-rmatn IS NOT INITIAL.
            READ TABLE et_entityset ASSIGNING <artcl> WITH KEY matnr = ls_artc2-rmatn.
            IF sy-subrc NE 0.
              ls_artc2-rmatn        = ls_artc2-matnr.
            ELSE.
              IF lv_srcvs EQ abap_true.
                lv_dupli            = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
          IF ls_artc2-rmatn IS INITIAL OR lv_artty EQ 'F'.
            ls_artc2-rmatn          = ls_artc2-matnr.
          ENDIF.
          READ TABLE lt_tempd INTO ls_tempd WITH KEY tempb = ls_artc2-tempb.
          IF sy-subrc EQ 0.
            ls_artc2-tbtxt          = ls_tempd-tbtxt.
          ENDIF.
          IF ls_artc2-tempb IS INITIAL AND lt_tempb IS NOT INITIAL.
            CONTINUE.
          ENDIF.
          READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = ls_artc2-stats.
          IF sy-subrc EQ 0.
            ls_artc2-tstat          = ls_dmntx-ddtext.
          ENDIF.
          ls_artc2-laeda            = ls_artc2-laed2.
          ls_artc2-ersda            = ls_artc2-ersd2.
*    *********Get IMSRC********************************************************  BEG *
          CLEAR:  ls_arcob.

          lv_objct                  = zcl_zft_gw_ft_utilities=>cv_content_article.
          lv_objid                  = ls_artc2-matnr.
          IF ls_artc2-arcid IS NOT INITIAL.
            lv_arcid                = ls_artc2-arcid.

            CALL FUNCTION 'ZAO_DOCUMENT_GET'
              EXPORTING
                iv_objct            = lv_objct
                iv_objid            = lv_objid
                iv_arcid            = lv_arcid
              IMPORTING
                et_arcob            = lt_arcob
              EXCEPTIONS
                OTHERS              = 1.

            IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
              READ TABLE lt_arcob INTO ls_arcob INDEX 1.
            ENDIF.
          ELSE.
            CALL FUNCTION 'ZAO_DOCUMENT_GET'
              EXPORTING
                iv_objct            = lv_objct
                iv_objid            = lv_objid
              IMPORTING
                et_arcob            = lt_arcob
              EXCEPTIONS
                OTHERS              = 1.

            IF sy-subrc EQ 0.
              LOOP AT lt_arcob INTO ls_arcob.
                IF ls_arcob-mimetype CS 'IMAGE'.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
          IF ls_arcob IS NOT INITIAL.
            ls_artc2-imsrc           = ls_arcob-uri.
          ENDIF.
*    *********Get IMSRC********************************************************  END *
          MOVE-CORRESPONDING ls_artc2 TO ls_entit.

          IF lt_wwghb IS NOT INITIAL.
            LOOP AT lt_wwghb INTO ls_wwghb WHERE low CS ls_artc2-wwghb.
            ENDLOOP.

            IF sy-subrc NE 0.
              CONTINUE.
            ENDIF.
          ENDIF.


*         Get data from the best status
          SELECT  s~dcdtd s~distb s~kbetr s~meins s~ntgew s~recip s~stats s~tempb s~vlcrn o~ordre s~sokey
          INTO    CORRESPONDING FIELDS OF TABLE lt_afsrc
          FROM    zmm_af_src AS s
          INNER   JOIN zmm_stats_order AS o ON s~stats EQ o~stats
          WHERE   matnr EQ ls_artc2-matnr.

          SORT lt_afsrc BY ordre ASCENDING.

*          ls_entit-isprt          = 'X'.

          READ TABLE lt_afsrc INTO ls_afsrc INDEX 1.
          IF sy-subrc EQ 0.

            ls_entit-tarap        = ls_entit-kbetr.

            READ TABLE lt_afsrc INTO ls_afsr2 WITH KEY ordre = ls_afsrc-ordre recip = 'X'.
            IF sy-subrc EQ 0.

              IF ls_afsr2-sokey EQ ls_artc2-sokey.
*                CLEAR ls_entit-isprt.
                ls_entit-isprt          = 'X'.
              ENDIF.

            ELSE.

              IF ls_afsrc-sokey EQ ls_artc2-sokey.
*                CLEAR ls_entit-isprt.
                ls_entit-isprt          = 'X'.
              ENDIF.

            ENDIF.

          ENDIF.

*          APPEND ls_artc2 TO et_entityset.

          IF ls_entit-distb EQ 'L'.
            ls_entit-distt        = text-008.
          ELSEIF ls_entit-distb EQ 'P'.
            ls_entit-distt        = text-006.
          ENDIF.

          APPEND ls_entit TO et_entityset.
          IF lv_dupli EQ abap_true.  " Dupliquer une ligne du AF si il a un RMATN d'un article reel faisant parti de l'entitySet
            ls_entit-rmatn        = ls_entit-matnr.
            APPEND ls_entit TO et_entityset.
            lv_dupli              = abap_false.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ELSE.
      SELECT   d~matnr, s~meins, d~laeda AS laed2, d~ersda AS ersd2, d~mhdrz , d~maktx, s~rmatn, d~maktg, s~mfrnr, s~distb, d~vendr, s~kbetr, s~stats, d~tarap,
               s~tempb, d~aenam, s~vlcrn, s~ntgew, d~actif,d~fictf, d~werks, d~atwrt, s~mfrnm, d~arcid, d~wwghb
      INTO CORRESPONDING FIELDS OF TABLE @lt_artc2
      FROM zmm_af_def AS d
      LEFT OUTER JOIN zmm_af_src AS s ON d~matnr EQ s~matnr
      WHERE d~matnr IN @lt_matnr
      AND   d~maktg IN @lt_maktx
      AND ( s~mfrnr IN @lt_mfrnr OR s~mfrnm IN @lt_mfrnr )
      AND   s~stats IN @lt_statf
      AND   s~tempb IN @lt_tempb
*      AND   d~atwrt IN @lt_atwrt
*      AND   d~wwghb IN @lt_wwghb
      AND   d~ctnum IN @lt_ctnum
      AND   s~distb IN @lt_distb
      ORDER BY ersda DESCENDING.

      IF sy-subrc EQ 0.
        SORT lt_artc2  BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_artc2 COMPARING matnr.
        IF lv_flpmd EQ abap_true.
          DELETE lt_artc2 WHERE mstae EQ '03'.
          MOVE-CORRESPONDING lt_artc2 TO et_entityset.
          RETURN.
        ENDIF.
        LOOP AT lt_artc2 INTO ls_artc2.
          CLEAR ls_entit.

          CONDENSE ls_artc2-vlcrn.
          ls_artc2-artty            = 'F'.
          IF lt_mfrnr IS INITIAL AND ls_artc2-mfrnr IS NOT INITIAL AND ( lv_distb EQ 'L' OR lv_distb IS INITIAL ).
            CLEAR : ls_afsrc.
            IF ls_artc2-stats NE '40' AND ls_artc2-stats NE '80'.
              SELECT SINGLE *
              INTO  CORRESPONDING FIELDS OF ls_afsrc
              FROM zmm_af_src
              WHERE matnr EQ ls_artc2-matnr
              AND   stats EQ '40'
              AND   stats IN lt_statf
              AND   tempb IN lt_tempb
              AND   distb IN lt_distb
              AND ( mfrnr IN lt_mfrnr OR mfrnm IN lt_mfrnr ).

              IF sy-subrc EQ 0.
                ls_artc2-tempb  = ls_afsrc-tempb.
                ls_artc2-mfrnr  = ls_afsrc-mfrnr.
                IF ls_artc2-mfrnr IS NOT INITIAL.
                  CALL FUNCTION 'LFA1_READ_SINGLE'
                    EXPORTING
                      id_lifnr            = ls_artc2-mfrnr
                    IMPORTING
                      es_lfa1             = ls_slfa1
                    EXCEPTIONS
                      not_found           = 1
                      input_not_specified = 2
                      lifnr_blocked       = 3
                      OTHERS              = 4.

                  IF sy-subrc EQ 0.
                    ls_artc2-mfrnm        = ls_slfa1-name1.
                  ENDIF.
                ENDIF.

                ls_artc2-tarap      = ls_afsrc-tarap.
                ls_artc2-kbetr      = ls_afsrc-kbetr.
                ls_artc2-stats      = ls_afsrc-stats.
                ls_artc2-meins      = ls_afsrc-meins.
*               ls_artc2-dcdtd      = ls_afsrc-dcdtd.
                ls_artc2-rmatn      = ls_afsrc-rmatn.
                ls_artc2-distb      = ls_afsrc-distb.
                IF ls_artc2-distb EQ 'L'.
                  IF ls_artc2-stats EQ '40'.
                    ls_artc2-distt  = ls_artc2-mfrnm.
                  ELSE.
                    ls_artc2-distt  = text-008. "Local
                  ENDIF.
                ENDIF.
                IF ls_artc2-distb EQ 'P'.
                  ls_artc2-distt    = text-006. "Plateforme
                ENDIF.
                ls_artc2-vlcrn      = ls_afsrc-vlcrn.
                CONDENSE ls_artc2-vlcrn.
                ls_artc2-ntgew      = ls_afsrc-ntgew.
              ELSE.
                IF ls_artc2-stats NE '70'.
                  SELECT SINGLE *
                  INTO  CORRESPONDING FIELDS OF ls_afsrc
                  FROM zmm_af_src
                  WHERE matnr EQ ls_artc2-matnr
                  AND   stats EQ '70'
                  AND   stats IN lt_statf
                  AND   tempb IN lt_tempb
                  AND   distb IN lt_distb
                  AND ( mfrnr IN lt_mfrnr OR mfrnm IN lt_mfrnr ).

                  IF sy-subrc EQ 0.
                    ls_artc2-tempb  = ls_afsrc-tempb.
                    ls_artc2-mfrnr  = ls_afsrc-mfrnr.
                    IF ls_artc2-mfrnr IS NOT INITIAL.
                      CALL FUNCTION 'LFA1_READ_SINGLE'
                        EXPORTING
                          id_lifnr            = ls_artc2-mfrnr
*                         ID_CVP_BEHAVIOR     =
                        IMPORTING
                          es_lfa1             = ls_slfa1
                        EXCEPTIONS
                          not_found           = 1
                          input_not_specified = 2
                          lifnr_blocked       = 3
                          OTHERS              = 4.

                      IF sy-subrc EQ 0.
                        ls_artc2-mfrnm        = ls_slfa1-name1.
                      ENDIF.
                    ENDIF.
                    ls_artc2-tarap  = ls_afsrc-tarap.
                    ls_artc2-kbetr  = ls_afsrc-kbetr.
                    ls_artc2-stats  = ls_afsrc-stats.
                    ls_artc2-meins  = ls_afsrc-meins.
*                   ls_artc2-dcdtd  = ls_afsrc-dcdtd.
                    ls_artc2-rmatn  = ls_afsrc-rmatn.
                    ls_artc2-distb  = ls_afsrc-distb.
                    IF ls_artc2-distb EQ 'L'.
                      IF ls_artc2-stats EQ '40'.
                        ls_artc2-distt  = ls_artc2-mfrnm.
                      ELSE.
                        ls_artc2-distt  = text-008. "Local
                      ENDIF.
                    ENDIF.
                    IF ls_artc2-distb EQ 'P'.
                      ls_artc2-distt    = text-006. "Plateforme
                    ENDIF.
                    ls_artc2-vlcrn  = ls_afsrc-vlcrn.
                    CONDENSE ls_artc2-vlcrn.
                    ls_artc2-ntgew  = ls_afsrc-ntgew.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              IF ls_artc2-mfrnr IS NOT INITIAL.
                CALL FUNCTION 'LFA1_READ_SINGLE'
                  EXPORTING
                    id_lifnr              = ls_artc2-mfrnr
*                   ID_CVP_BEHAVIOR       =
                  IMPORTING
                    es_lfa1               = ls_slfa1
                  EXCEPTIONS
                    not_found             = 1
                    input_not_specified   = 2
                    lifnr_blocked         = 3
                    OTHERS                = 4.

                IF sy-subrc EQ 0.
                  ls_artc2-mfrnm          = ls_slfa1-name1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
*          IF ls_artc2-distb EQ 'L'.
*            IF ls_artc2-stats EQ '40'.
*              ls_artc2-distt        = ls_artc2-mfrnm.
*            ELSE.
*              ls_artc2-distt        = text-008. "Local
*            ENDIF.
*          ENDIF.
*          IF ls_artc2-distb EQ 'P'.
*            ls_artc2-distt          = text-006. "Plateforme
*          ENDIF.
          IF ls_artc2-stats NE '40'.
*            CLEAR : ls_artc2-tempb, ls_artc2-mfrnr, ls_artc2-mfrnm.
          ELSE.
            READ TABLE lt_tempd INTO ls_tempd WITH KEY tempb = ls_artc2-tempb.
            IF sy-subrc EQ 0.
              ls_artc2-tbtxt        = ls_tempd-tbtxt.
            ENDIF.
          ENDIF.
          READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = ls_artc2-stats.
          IF sy-subrc EQ 0.
            ls_artc2-tstat          = ls_dmntx-ddtext.
          ENDIF.
          ls_artc2-laeda            = ls_artc2-laed2.
          ls_artc2-ersda            = ls_artc2-ersd2.
*    *********Get IMSRC********************************************************  BEG *
          lv_objct                  = zcl_zft_gw_ft_utilities=>cv_content_article..
          lv_objid                  = ls_artc2-matnr.
          CLEAR : lt_arcob, ls_arcob.
          IF ls_artc2-arcid IS NOT INITIAL.
            lv_arcid                = ls_artc2-arcid.

            CALL FUNCTION 'ZAO_DOCUMENT_GET'
              EXPORTING
                iv_objct            = lv_objct
                iv_objid            = lv_objid
                iv_arcid            = lv_arcid
              IMPORTING
                et_arcob            = lt_arcob
              EXCEPTIONS
                OTHERS              = 1.

            IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
              READ TABLE lt_arcob INTO ls_arcob INDEX 1.
            ENDIF.
          ELSE.
            CALL FUNCTION 'ZAO_DOCUMENT_GET'

              EXPORTING
                iv_objct            = lv_objct
                iv_objid            = lv_objid
              IMPORTING
                et_arcob            = lt_arcob
              EXCEPTIONS
                OTHERS              = 1.

            IF sy-subrc EQ 0.
              LOOP AT lt_arcob INTO ls_arcob.
                IF ls_arcob-mimetype CS 'IMAGE'.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
          IF ls_arcob IS NOT INITIAL.
            ls_artc2-imsrc           = ls_arcob-uri.
          ENDIF.
*    *********Get IMSRC********************************************************  END *
          IF ls_artc2-tempb IS INITIAL AND lt_tempb IS NOT INITIAL.
            CONTINUE.
          ENDIF.

          WRITE ls_artc2-vlcrn TO ls_artc2-vlcrn LEFT-JUSTIFIED .

          MOVE-CORRESPONDING ls_artc2 TO ls_entit.
*          APPEND ls_artc2 TO et_entityset.

          IF lt_wwghb IS NOT INITIAL.
            LOOP AT lt_wwghb INTO ls_wwghb WHERE low CS ls_artc2-wwghb.
            ENDLOOP.

            IF sy-subrc NE 0.
              CONTINUE.
            ENDIF.
          ENDIF.

*         Get data from the best status
          SELECT  s~mfrnr s~mfrnm s~dcdtd s~distb s~kbetr s~meins s~ntgew s~recip s~stats s~tempb s~vlcrn o~ordre
          INTO    CORRESPONDING FIELDS OF TABLE lt_afsrc
          FROM    zmm_af_src AS s
          INNER   JOIN zmm_stats_order AS o ON s~stats EQ o~stats
          WHERE   matnr EQ ls_artc2-matnr.

          SORT lt_afsrc BY ordre ASCENDING.

          READ TABLE lt_afsrc INTO ls_afsrc INDEX 1.
          IF sy-subrc EQ 0.

            READ TABLE lt_afsrc INTO ls_afsr2 WITH KEY ordre = ls_afsrc-ordre recip = 'X'.
            IF sy-subrc EQ 0.

              READ TABLE lt_distb INTO ls_distb WITH KEY low = ls_afsr2-distb.
              IF sy-subrc EQ 0 OR lt_distb IS INITIAL.

                READ TABLE lt_tempb INTO ls_tempb WITH KEY low = ls_afsr2-tempb.
                IF sy-subrc EQ 0 OR lt_tempb IS INITIAL.

                  READ TABLE lt_statf INTO ls_statf WITH KEY low = ls_afsr2-stats.
                  IF sy-subrc EQ 0 OR lt_statf IS INITIAL.

                    ls_entit-tempb          = ls_afsr2-tempb.

                    READ TABLE lt_tempd INTO ls_tempd WITH KEY tempb = ls_entit-tempb.
                    IF sy-subrc EQ 0.
                      ls_entit-tbtxt        = ls_tempd-tbtxt.
                    ENDIF.

                    ls_entit-ntgew          = ls_afsr2-ntgew.
                    ls_entit-stats          = ls_afsr2-stats.

                    READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = ls_entit-stats.
                    IF sy-subrc EQ 0.
                      ls_entit-tstat        = ls_dmntx-ddtext.
                    ENDIF.

                    ls_entit-vlcrn          = ls_afsr2-vlcrn.
                    ls_entit-dcdtd          = ls_afsr2-dcdtd.
                    ls_entit-kbetr          = ls_afsr2-kbetr.
                    ls_entit-tarap          = ls_afsr2-kbetr.
                    ls_entit-meins          = ls_afsr2-meins.
                    ls_entit-mfrnr          = ls_afsr2-mfrnr.
                    ls_entit-mfrnm          = ls_afsr2-mfrnm.
                    ls_entit-distb          = ls_afsr2-distb.

                    IF ls_entit-distb EQ 'L'.
                      ls_entit-distt        = text-008.
                    ELSEIF ls_entit-distb EQ 'P'.
                      ls_entit-distt        = text-006.
                    ENDIF.

                    APPEND ls_entit TO et_entityset.
                    CONTINUE.

                  ELSE.
                    CONTINUE.

                  ENDIF.

                ELSE.
                  CONTINUE.

                ENDIF.

              ELSE.
                CONTINUE.

              ENDIF.

            ELSE.

              READ TABLE lt_distb INTO ls_distb WITH KEY low = ls_afsrc-distb.
              IF sy-subrc EQ 0 OR lt_distb IS INITIAL.

                READ TABLE lt_tempb INTO ls_tempb WITH KEY low = ls_afsrc-tempb.
                IF sy-subrc EQ 0 OR lt_tempb IS INITIAL.

                  READ TABLE lt_statf INTO ls_statf WITH KEY low = ls_afsrc-stats.
                  IF sy-subrc EQ 0 OR lt_statf IS INITIAL.

                    ls_entit-tempb          = ls_afsrc-tempb.

                    READ TABLE lt_tempd INTO ls_tempd WITH KEY tempb = ls_entit-tempb.
                    IF sy-subrc EQ 0.
                      ls_entit-tbtxt        = ls_tempd-tbtxt.
                    ENDIF.

                    ls_entit-ntgew          = ls_afsrc-ntgew.
                    ls_entit-stats          = ls_afsrc-stats.

                    READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = ls_entit-stats.
                    IF sy-subrc EQ 0.
                      ls_entit-tstat        = ls_dmntx-ddtext.
                    ENDIF.

                    ls_entit-vlcrn          = ls_afsrc-vlcrn.
                    ls_entit-dcdtd          = ls_afsrc-dcdtd.
                    ls_entit-kbetr          = ls_afsrc-kbetr.
                    ls_entit-tarap          = ls_afsrc-kbetr.
                    ls_entit-meins          = ls_afsrc-meins.
                    ls_entit-mfrnr          = ls_afsrc-mfrnr.
                    ls_entit-mfrnm          = ls_afsrc-mfrnm.

                    ls_entit-distb          = ls_afsrc-distb.

                    IF ls_entit-distb EQ 'L'.
                      ls_entit-distt        = text-008.
                    ELSEIF ls_entit-distb EQ 'P'.
                       ls_entit-distt       = text-006.
                    ENDIF.

                    APPEND ls_entit TO et_entityset.
                    CONTINUE.

                  ELSE.
                    CONTINUE.

                  ENDIF.

                ELSE.
                  CONTINUE.

                ENDIF.

              ELSE.
                CONTINUE.

              ENDIF.

            ENDIF.

          ELSE.

            APPEND ls_entit TO et_entityset.

          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
**************Get fict. items**********************************************  END *
  IF lv_srcvs EQ abap_true AND lv_artty NE 'F'.

    LOOP AT et_entityset ASSIGNING <artc2>.
      IF <artc2>-matnr NE <artc2>-rmatn.
        READ TABLE et_entityset ASSIGNING <artcl> WITH KEY matnr = <artc2>-rmatn.
        IF sy-subrc EQ 0.
          <artcl>-isprt           = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_dispn IS NOT INITIAL.
    lv_nbent                      = lines( et_entityset ).
    SORT et_entityset BY ersda DESCENDING.
    CLEAR:  lv_matnr,
            lv_nblin.

    LOOP AT et_entityset INTO ls_entit.

      IF lv_nblin GE lv_dispn.
        lv_nbln2                  = sy-tabix.
        EXIT.
      ELSE.
        IF lv_matnr NE ls_entit-matnr.
          lv_nblin                = lv_nblin + 1.
          lv_matnr                = ls_entit-matnr.
        ENDIF.
        lv_nbln2                  = sy-tabix.
      ENDIF.

    ENDLOOP.

    IF lv_nbent LT lv_dispn.
      lv_nbln2                    = lv_nbln2 + 1.
    ENDIF.
    SORT et_entityset BY ersda DESCENDING.
    DELETE et_entityset FROM lv_nbln2.
  ENDIF.


  MOVE '1' TO lv_vlcrn.
  CONDENSE lv_vlcrn NO-GAPS.

  LOOP AT et_entityset INTO ls_entit.

    CONDENSE ls_entit-vlcrn NO-GAPS.
    IF ls_entit-distb EQ 'L' AND ls_entit-meins EQ 'KG' AND ls_entit-vlcrn EQ lv_vlcrn.
      CLEAR ls_entit-vlcrn.
      MODIFY et_entityset FROM ls_entit.
    ENDIF.

  ENDLOOP.




*  SORT et_entityset BY matnr.

ENDMETHOD.