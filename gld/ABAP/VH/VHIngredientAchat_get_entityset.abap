METHOD vhingredientsach_get_entityset.
  TYPES:  BEGIN OF ts_tempb.
            TYPES: tempb TYPE tempb,
                   tbtxt TYPE tbtxt,
          END OF ts_tempb,
          BEGIN OF ty_ensei,
*            vkorg TYPE vkorg.
            include TYPE zgld_enseigne.
  TYPES: END OF ty_ensei,
         BEGIN OF ty_entit,
            apdeb TYPE zmm_ft_apdeb,
            mstae TYPE mstae,
            srtft TYPE zmm_sr_to_ft.
            INCLUDE TYPE zft_s_gw_vh_ingredients.
  TYPES: END OF ty_entit.

  DATA: lv_cntxt    TYPE zmm_fr_cntxt,
        lv_ekorg    TYPE ekorg,
        lv_frnum    TYPE char18,
        lv_matn1    TYPE matnr,
        lv_matnr    TYPE matnr,
        lv_mfrnm    TYPE name1_gp,
        lv_perte    TYPE zmm_perte,
        lv_sokey    TYPE zft_gw_sokey,
        lv_srver    TYPE zmm_srver,
        lv_dispn    TYPE rvari_val_255, "Default to display
        lv_nblin    TYPE i,
        lv_typea    TYPE zmm_fr_ing_type,
        lr_typea    TYPE /iwbep/s_mgw_select_option,
        lr_matnr    TYPE /iwbep/s_mgw_select_option,
        ls_afsrc    TYPE zmm_af_src,
        ls_dsrtx    TYPE dd07v,
        ls_filtr    TYPE /iwbep/s_mgw_select_option,
        ls_seina    TYPE eina,
        ls_selop    TYPE /iwbep/s_cod_select_option,
        ls_pline    TYPE zmm_s_ft_val_pline,
        ls_slfa1    TYPE lfa1,
        ls_vhing    TYPE zcl_zft_gw_value_help_mpc_ext=>ts_vhingredientsachat,
        ls_tempb    TYPE ts_tempb,
        ls_tmara    TYPE mara,
        ls_tmarc    TYPE marc,
        lt_afsrc    TYPE TABLE OF zmm_af_src,
        lt_dartx    TYPE TABLE OF dd07v,
        lt_dfttx    TYPE TABLE OF dd07v,
        lt_dmptx    TYPE TABLE OF dd07v,
        lt_dsrtx    TYPE TABLE OF dd07v,
        lt_dsrtt    TYPE TABLE OF dd07v,
        lt_maktx    TYPE /iwbep/t_cod_select_options,
        lt_teina    TYPE TABLE OF eina,
        lt_tempb    TYPE TABLE OF ts_tempb,
        lt_tmarc    TYPE TABLE OF marc,
        lt_vhing    TYPE zcl_zft_gw_value_help_mpc_ext=>tt_vhingredientsachat,
        ls_vhent    TYPE zcl_zft_gw_value_help_mpc_ext=>ts_vhingredientsachat,
        ls_entcp    TYPE ty_entit,
        lt_entcp    TYPE TABLE OF ty_entit,
        lt_entit    TYPE TABLE OF ty_entit,
        ls_entit    TYPE ty_entit,
*        lt_ensei    TYPE TABLE OF ty_ensei,
        lt_ensei    TYPE TABLE OF zgld_enseigne,
*        ls_ensei    TYPE ty_ensei,
        ls_ensei    TYPE zgld_enseigne,
        lr_rgens    TYPE RANGE OF string,
        ls_rgens    LIKE LINE OF lr_rgens,
        ls_fictp    TYPE zcl_zft_gw_value_help_mpc=>ts_vhingredientsachat,
        ls_fictf    TYPE zcl_zft_gw_value_help_mpc=>ts_vhingredientsachat,
        lt_fictc    TYPE zcl_zft_gw_value_help_mpc=>tt_vhingredientsachat,
        lt_fictf    TYPE zcl_zft_gw_value_help_mpc=>tt_vhingredientsachat.
  FIELD-SYMBOLS: <vhing> TYPE zcl_zft_gw_value_help_mpc_ext=>ts_vhingredientsachat.


* Get MAKTX
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'MAKTX'.
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

* Get CNTXT
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'CNTXT'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        lv_cntxt                  = ls_selop-low.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* Get FRNUM
  LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'FRNUM'.
    LOOP AT ls_filtr-select_options INTO ls_selop.
      IF ls_selop-low IS NOT INITIAL.
        TRANSLATE ls_selop-low TO UPPER CASE.
        lv_frnum                  = ls_selop-low.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*  IF lv_cntxt EQ 'FT' AND lt_maktx[] IS INITIAL.
*
**    RETURN.
*  ENDIF.

*  IF lt_maktx[] IS INITIAL.
    SELECT      SINGLE low
    INTO        lv_dispn
    FROM        tvarvc
    WHERE       name EQ 'ZFT_LAST_ING_DISPLAYED'.
*  ENDIF.

* Range to test authorization
*  SELECT      E~*, g~vkorg
  SELECT      e~ensgn, e~entxt, e~gamme, g~vkorg
  INTO        CORRESPONDING FIELDS OF TABLE @lt_ensei
  FROM        zgld_enseigne AS e
  INNER       JOIN wrs1 AS g ON g~asort EQ e~ensgn
  WHERE       e~activ EQ 'X'.

  LOOP AT lt_ensei INTO ls_ensei.
    AUTHORITY-CHECK OBJECT 'W_VKPR_PLT'
             ID 'VKORG' FIELD ls_ensei-vkorg
             ID 'VTWEG' FIELD '*'
             ID 'PLTYP' FIELD '*'
             ID 'MATKL' FIELD '*'
             ID 'ACTVT' FIELD '03'.
    IF sy-subrc EQ 0.
      ls_rgens-sign               = 'I'.
      ls_rgens-option             = 'EQ'.
      ls_rgens-low                = ls_ensei-ensgn.
      APPEND ls_rgens TO lr_rgens.
    ENDIF.
  ENDLOOP.

****
***** Get Article
****  IF lt_maktx[] IS NOT INITIAL.
****    SELECT  DISTINCT v~matnr AS matnr , t~maktx, m~mhdrz, m~matnr AS matac, m~tempb, m~meins, w~bbtyp AS distb, 'AR' AS cntxt, m~mstae
*****    APPENDING CORRESPONDING FIELDS OF TABLE @et_entityset
****    INTO CORRESPONDING FIELDS OF TABLE @lt_entit
****    FROM    mara      AS m
****    INNER   JOIN makt AS t ON m~matnr EQ t~matnr
****    INNER   JOIN marc AS c ON c~matnr EQ m~matnr AND c~werks EQ 'R100'
****    INNER   JOIN marc AS d ON d~matnr EQ m~matnr AND d~werks EQ 'R120'
****    INNER   JOIN mara AS v ON v~satnr EQ m~satnr
****    INNER   JOIN maw1 AS w ON m~matnr EQ w~matnr
****    WHERE   m~attyp   EQ '02'
****    AND     m~bflme   EQ '3'
****    AND     t~spras   EQ @sy-langu
*****    AND     m~mstae   NE 'Z3'      " Id 21 Ecart 5
*****    AND     c~mmsta   NE 'Z3'
*****    AND     d~mmsta   NE 'Z3'
****    AND     v~attyp   EQ '02'
****    AND     v~bflme   EQ '2'
****    AND     v~mtart   EQ 'ZAWA'
*****    AND     v~mstae   NE 'Z3'
****    AND     ( t~maktg IN @lt_maktx OR m~matnr IN @lt_maktx ).

****  ELSE.
    lv_nblin                      = lv_dispn * 10.
    SELECT  DISTINCT v~matnr AS matnr , t~maktx, m~mhdrz, m~matnr AS matac, m~tempb, m~meins, w~bbtyp AS distb, 'AR' AS cntxt, m~mstae, m~ersda
    INTO CORRESPONDING FIELDS OF TABLE @lt_entit
    UP      TO @lv_nblin ROWS
    FROM    mara      AS m
    INNER   JOIN makt AS t ON m~matnr EQ t~matnr
    INNER   JOIN marc AS c ON c~matnr EQ m~matnr AND c~werks EQ 'R100'
    INNER   JOIN marc AS d ON d~matnr EQ m~matnr AND d~werks EQ 'R120'
    INNER   JOIN mara AS v ON v~satnr EQ m~satnr
    INNER   JOIN maw1 AS w ON m~matnr EQ w~matnr
    WHERE   m~attyp   EQ '02'
    AND     m~bflme   EQ '3'
    AND     t~spras   EQ @sy-langu
    AND     v~attyp   EQ '02'
    AND     v~bflme   EQ '2'
    AND     v~mtart   EQ 'ZAWA'
    AND     ( t~maktg IN @lt_maktx OR m~matnr IN @lt_maktx )
    AND     m~matnr   NE @lv_frnum
    ORDER   BY m~ersda DESCENDING.

****  ENDIF.

  LOOP AT lt_entit INTO ls_entit.
    MOVE-CORRESPONDING ls_entit TO ls_vhent.
    IF ls_entit-mstae EQ 'Z3'.
      ls_vhent-warni            = abap_true.
    ENDIF.
    ls_vhent-typea                = 'VV'.
    APPEND ls_vhent TO et_entityset.
  ENDLOOP.

* Get FT
****  IF lt_maktx[] IS NOT INITIAL.
    SELECT d~ftnum AS matnr, v~ftnum AS matac, k~maktx, m~mhdrz, m~meins, 'FT' AS cntxt, d~stats, d~erdat AS ersda
    INTO CORRESPONDING FIELDS OF TABLE @lt_entit
****    APPENDING CORRESPONDING FIELDS OF TABLE @et_entityset
    FROM  zmm_ft_def AS d
    INNER JOIN  zmm_ft_ver  AS v  ON d~ftnum EQ v~ftnum
    INNER JOIN  mara        AS m  ON d~ftnum EQ m~matnr
    INNER JOIN  makt        AS k  ON m~matnr EQ k~matnr
    INNER JOIN  zmm_ft_ens AS e ON d~ftnum EQ e~ftnum
    WHERE   k~spras EQ @sy-langu
    AND     ( k~maktg IN @lt_maktx OR d~ftnum IN @lt_maktx )
    AND     v~apdeb LE @sy-datum
    AND     v~apfin GE @sy-datum
    AND     e~ensgn IN @lr_rgens "Ecart 5: verification des autorisations pour les FT
    AND     d~ftnum NE @lv_frnum
    ORDER BY d~erdat DESCENDING.

  LOOP AT lt_entit INTO ls_entit.
    MOVE-CORRESPONDING ls_entit TO ls_vhent.
    ls_vhent-typea                = 'FT'.
    APPEND ls_vhent TO et_entityset.
  ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING matac.
****  ENDIF.

  IF lv_cntxt EQ 'SR'.
*   Get SR (Only for SR)
*****    IF lt_maktx[] IS NOT INITIAL.
      CLEAR: lt_entit , ls_entit, ls_vhent.
      SELECT  v~srnum AS matnr, v~descr AS maktx,  v~srver  AS matac, d~stats, d~meins, 'SR' AS cntxt, d~titre AS matax, v~apdeb, v~srtft, d~erdat AS ersda
      INTO CORRESPONDING FIELDS OF TABLE @lt_entit
*      APPENDING CORRESPONDING FIELDS OF TABLE @et_entityset
      FROM    zmm_sr_def AS d
      INNER   JOIN zmm_sr_ver AS v ON d~srnum EQ v~srnum
      INNER   JOIN zmm_sr_ens AS e ON d~srnum EQ e~srnum
      WHERE   e~ensgn IN @lr_rgens
      AND     d~stats NE '25'  "Exclut les SR transformees
      AND     ( v~srnum IN @lt_maktx OR v~descr IN @lt_maktx )
      AND     d~srnum NE @lv_frnum
      ORDER   BY d~erdat DESCENDING.

      APPEND LINES OF lt_entit TO lt_entcp.
      SORT lt_entcp BY matnr ASCENDING apdeb DESCENDING.

      SORT lt_entit BY matnr matac.
      DELETE ADJACENT DUPLICATES FROM lt_entit COMPARING matnr.

      LOOP AT lt_entit INTO ls_entit.

        READ TABLE lt_entcp INTO ls_entit WITH KEY matnr = ls_entit-matnr srtft = 'X'.
        IF sy-subrc NE 0.
          READ TABLE lt_entcp INTO ls_entit WITH KEY matnr = ls_entit-matnr.
        ENDIF.

        MOVE-CORRESPONDING ls_entit TO ls_vhent.
        ls_vhent-matac              = |{ ls_vhent-matnr } - { ls_vhent-matac }|.
        ls_vhent-typea              = 'SR'.
        APPEND ls_vhent TO et_entityset.
      ENDLOOP.
****    ENDIF.

*   Get AF (Only for SR)
    SELECT    d~matnr , ( d~maktx && ' - ' && s~maktx ) AS maktx , s~sokey AS matac, s~stats, s~vlcrn, s~distb, s~mfrnr, s~mfrnm, s~tempb, CASE s~meins WHEN ' ' THEN d~meins ELSE s~meins END AS meins , 'AF' AS cntxt, d~tarap AS kbetr, d~ersda, 'AF' AS
typea
    APPENDING CORRESPONDING FIELDS OF TABLE @et_entityset
    FROM      zmm_af_def AS d
    INNER     JOIN zmm_af_src AS s ON d~matnr EQ s~matnr
    WHERE   ( d~matnr IN @lt_maktx
    OR        d~maktg IN @lt_maktx
    OR        s~maktg IN @lt_maktx )
    AND       s~rmatn EQ ''   " Ecart 5 ajouter pour ne pas inclure ceux qui ont un code appro
    AND       s~stats NE '80'
    ORDER     BY d~ersda DESCENDING.
****    ORDER     BY d~matnr DESCENDING.
  ELSE.
*   Get AF (Only for SR)
*    SELECT    d~matnr , ( d~maktx && ' - ' && s~maktx ) AS maktx , s~sokey AS matac, s~vlcrn, s~distb, s~mfrnr, s~mfrnm, s~tempb, CASE s~meins WHEN ' ' THEN d~meins ELSE s~meins END AS meins , 'AF' AS cntxt, d~ersda
**    APPENDING CORRESPONDING FIELDS OF TABLE @et_entityset
*    INTO    CORRESPONDING FIELDS OF TABLE @lt_entit
*    UP      TO @lv_nblin ROWS
*    FROM      zmm_af_def AS d
*    INNER     JOIN zmm_af_src AS s ON d~matnr EQ s~matnr
*    WHERE   ( d~matnr IN @lt_maktx
*    OR        d~maktg IN @lt_maktx
*    OR        s~maktg IN @lt_maktx )
*    AND       s~rmatn EQ ''   " Ecart 5 ajouter pour ne pas inclure ceux qui ont un code appro
*    ORDER     BY d~ersda DESCENDING.
*
*    LOOP AT lt_entit INTO ls_entit.
*    MOVE-CORRESPONDING ls_entit TO ls_vhent.
*    APPEND ls_vhent TO et_entityset.
*  ENDLOOP.

  ENDIF.

*  APPEND LINES OF lt_fictf TO lt_fictc.

*  LOOP AT lt_fictf INTO ls_fictf.

*    read TABLE lt_fictp INTO ls_fictp

*    APPEND ls_fictf TO et_entityset.

*  ENDLOOP.


  SORT et_entityset BY ersda DESCENDING.
  IF lv_dispn IS NOT INITIAL.
    DELETE et_entityset FROM lv_dispn + 1 .
  ENDIF.
  SORT et_entityset BY maktx matnr.
*  DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING matnr.  "Ecart 5: Delete pour les doublons de la requete articles fictifs du a la nouvelle jointure

* Si renvoie des SR, les ordonne par versions
  IF lv_cntxt EQ 'SR'.
    SORT et_entityset BY matac.
  ENDIF.

  IF et_entityset[] IS NOT INITIAL.
****Initialisation********************************************** BEG *
    SELECT  DISTINCT tempb tbtxt
    INTO    CORRESPONDING FIELDS OF TABLE lt_tempb
    FROM    t143t
    WHERE   spras EQ 'FR'.
****Initialisation********************************************** END *
  ENDIF.

* Get AF status
  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_MP_STATS'
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_dmptx
      dd07v_tab_n                 = lt_dsrtt
    EXCEPTIONS
      OTHERS                      = 0.

* Get AR status
  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_AR_STATS'
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_dartx
      dd07v_tab_n                 = lt_dsrtt
    EXCEPTIONS
      OTHERS                      = 0.

* Get SR status
  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_SR_STATS'
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_dsrtx
      dd07v_tab_n                 = lt_dsrtt
    EXCEPTIONS
      OTHERS                      = 0.

* Get FT status
  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name                 = 'ZMM_FT_STATS'
      get_state                   = 'M  '
      langu                       = sy-langu
      prid                        = 0
      withtext                    = 'X'
    TABLES
      dd07v_tab_a                 = lt_dfttx
      dd07v_tab_n                 = lt_dsrtt
    EXCEPTIONS
      OTHERS                      = 0.


  LOOP AT et_entityset ASSIGNING <vhing>.
    CLEAR:  ls_pline,
            ls_tmarc,
            lt_tmarc.

    CONDENSE <vhing>-vlcrn.
    WRITE <vhing>-vlcrn LEFT-JUSTIFIED.

    CASE <vhing>-cntxt.
      WHEN 'AF'.
        READ TABLE lt_tempb INTO ls_tempb WITH KEY tempb = <vhing>-tempb.
        IF sy-subrc EQ 0.
          <vhing>-tbtxt           = ls_tempb-tbtxt.
        ENDIF.
        REPLACE ALL OCCURRENCES OF 'GLD - ' IN <vhing>-tbtxt WITH ''.

        IF <vhing>-mfrnr IS NOT INITIAL.
          CALL FUNCTION 'LFA1_SINGLE_READ'
            EXPORTING
              lfa1_lifnr          = <vhing>-mfrnr
            IMPORTING
              wlfa1               = ls_slfa1
              EXCEPTIONS
              not_found           = 1
              lifnr_blocked       = 2
              OTHERS              = 3.

          IF sy-subrc EQ 0 AND ls_slfa1 IS NOT INITIAL.
*           Implement suitable error handling here
            <vhing>-mfrnm         = ls_slfa1-name1.
          ENDIF.
        ENDIF.


        lv_sokey                  = <vhing>-matac.
        ls_pline                  = zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr =  <vhing>-matnr
                                                                                iv_bdate =  sy-datum
                                                                                iv_itype =  'AF'
                                                                                iv_pltyp =  'FR'
                                                                                iv_vkorg =  'ZLOG'
                                                                                iv_vtweg =  '10'
                                                                                iv_qtite =  '1'
                                                                                iv_unite =  <vhing>-meins
                                                                                iv_perte =  lv_perte
                                                                                iv_sokey =  lv_sokey ).
*        <vhing>-kbetr             = ls_pline-kbetr.

*       Get status description
        READ TABLE lt_dmptx INTO ls_dsrtx WITH KEY domvalue_l = <vhing>-stats.
        IF sy-subrc EQ 0.
          <vhing>-vstat           = ls_dsrtx-ddtext.
        ENDIF.

      WHEN 'AR'.
        READ TABLE lt_tempb INTO ls_tempb WITH KEY tempb = <vhing>-tempb.
        IF sy-subrc EQ 0.
          <vhing>-tbtxt           = ls_tempb-tbtxt.
        ENDIF.
        REPLACE ALL OCCURRENCES OF 'GLD - ' IN <vhing>-tbtxt WITH ''.

        IF <vhing>-distb EQ 'L'.
          lv_ekorg                = '2000'.
        ELSE.
          lv_ekorg                = '1000'.
        ENDIF.

        SELECT  *
        INTO    CORRESPONDING FIELDS OF TABLE lt_teina
        FROM    eina  AS a
        INNER   JOIN  eine AS e ON e~infnr EQ a~infnr
        WHERE   a~matnr   EQ <vhing>-matac
        AND     a~loekz   NE 'X'
        AND     e~ekorg   EQ lv_ekorg
        AND     e~loekz   NE 'X'.

        IF <vhing>-distb EQ 'L'.
          LOOP AT lt_teina INTO ls_seina.
            CALL FUNCTION 'LFA1_SINGLE_READ'
              EXPORTING
                lfa1_lifnr        = ls_seina-lifnr
              IMPORTING
                wlfa1             = ls_slfa1
                EXCEPTIONS
                not_found         = 1
                lifnr_blocked     = 2
                OTHERS            = 3.

            IF sy-subrc EQ 0 AND ls_slfa1 IS NOT INITIAL.
              IF <vhing>-mfrnm IS INITIAL.
                <vhing>-mfrnm     = ls_slfa1-name1.
              ELSE.
                CONCATENATE ',' ls_slfa1-name1 INTO <vhing>-mfrnm SEPARATED BY space.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSE.
          READ TABLE lt_teina INTO ls_seina INDEX 1.
          IF sy-subrc EQ 0.
            <vhing>-mfrnr         = ls_seina-lifnr.

            CALL FUNCTION 'LFA1_SINGLE_READ'
              EXPORTING
                lfa1_lifnr        = ls_seina-lifnr
              IMPORTING
                wlfa1             = ls_slfa1
                EXCEPTIONS
                not_found         = 1
                lifnr_blocked     = 2
                OTHERS            = 3.

            IF sy-subrc EQ 0 AND ls_slfa1 IS NOT INITIAL.
              <vhing>-mfrnm       = ls_slfa1-name1.
            ENDIF.
          ENDIF.
        ENDIF.

        ls_pline                  = zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr = <vhing>-matac
                                                                                iv_bdate = sy-datum
                                                                                iv_itype = 'AR'
                                                                                iv_pltyp = 'FR'
                                                                                iv_vkorg = 'ZLOG'
                                                                                iv_vtweg = '10'
                                                                                iv_qtite = '1'
                                                                                iv_unite = <vhing>-meins
                                                                                iv_perte = lv_perte
                                                                                ).

        <vhing>-kbetr             = ls_pline-kbetr.

*       Get status
        IF <vhing>-warni EQ 'X'.
          <vhing>-stats           = '1'.
        ELSE.
          SELECT *
          INTO TABLE lt_tmarc
          FROM marc
*          WHERE matnr EQ <vhing>-matnr
          WHERE matnr EQ <vhing>-matac
          AND   werks IN ( 'R120' , 'R100' ).

          IF sy-subrc EQ 0 AND lt_tmarc IS NOT INITIAL.
            READ TABLE lt_tmarc INTO ls_tmarc WITH KEY werks = 'R120' mmsta = 'Z3'.
            IF sy-subrc EQ 0 AND ls_tmarc IS NOT INITIAL.
               <vhing>-stats      = '2'. "Fermé sur les Cadenciers

            ELSE.
              READ TABLE lt_tmarc INTO ls_tmarc WITH KEY werks = 'R120' mmsta = 'Z9'.
              IF sy-subrc EQ 0 AND ls_tmarc IS NOT INITIAL.
                <vhing>-stats     = '3'. "En attente d'ouverture Cadenciers

              ELSE.
                READ TABLE lt_tmarc INTO ls_tmarc WITH KEY werks = 'R100' mmsta = 'Z3'.
                IF sy-subrc EQ 0 AND ls_tmarc IS NOT INITIAL.
                  <vhing>-stats   = '4'. "Stop Appro PtF

                ELSE.
                  <vhing>-stats  = ''.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            <vhing>-stats        = ''.
          ENDIF.
        ENDIF.

*       Get status description
        READ TABLE lt_dartx INTO ls_dsrtx WITH KEY domvalue_l = <vhing>-stats.
        IF sy-subrc EQ 0.
          <vhing>-vstat           = ls_dsrtx-ddtext.
        ENDIF.

      WHEN 'SR'.
        lv_srver                  = <vhing>-matac.
        ls_pline                  = zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr  = <vhing>-matnr
                                                                                iv_bdate  = sy-datum
                                                                                iv_itype  = 'SR'
                                                                                iv_srver  = lv_srver
                                                                                iv_pltyp  = 'FR'
                                                                                iv_land1  = space
                                                                                iv_vkorg  = 'ZLOG'
                                                                                iv_vtweg  = '10'
                                                                                iv_qtite  = '1.000'
                                                                                iv_unite  = 'PCE'
                                                                                iv_perte  = '0.00'
                                                                                ).
        <vhing>-kbetr             = ls_pline-prixm.

*       Get status description
        READ TABLE lt_dsrtx INTO ls_dsrtx WITH KEY domvalue_l = <vhing>-stats.
        IF sy-subrc EQ 0.
          <vhing>-vstat           = ls_dsrtx-ddtext.
        ENDIF.

      WHEN 'FT'.
        ls_pline                  = zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr  = <vhing>-matnr
                                                                                iv_bdate  = sy-datum
                                                                                iv_itype  = 'FT'
                                                                                iv_pltyp  = 'FR'
                                                                                iv_land1  = space
                                                                                iv_vkorg  = 'ZLOG'
                                                                                iv_vtweg  = '10'
                                                                                iv_qtite  = '1.000'
                                                                                iv_unite  = 'PCE'
                                                                                iv_perte  = '0.00'
                                                                               ).
        <vhing>-kbetr             = ls_pline-prixm.

*       Get status description
        READ TABLE lt_dfttx INTO ls_dsrtx WITH KEY domvalue_l = <vhing>-stats.
        IF sy-subrc EQ 0.
          <vhing>-vstat           = ls_dsrtx-ddtext.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.


  me->handle_paging(  EXPORTING is_pagin  = is_paging
                      CHANGING  ct_entty  = et_entityset ).

ENDMETHOD.