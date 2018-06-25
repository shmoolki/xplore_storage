*&---------------------------------------------------------------------*
*&  Include           ZXWPUU17
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Interface
*"       TABLES
*"              OUTPUT_ERROR_MESSAGES TYPE  WPUPL_ERROR_MESSAGES
*"       CHANGING
*"             REFERENCE(IO_INTERFACE) TYPE  WPUPL_WPUWBW01
*"----------------------------------------------------------------------

* ----------------------------------------------------------------------
*                     C H A N G E   H I S T O R Y
* ----------------------------------------------------------------------
*    Date    |  Changed by  | Description
* ----------------------------------------------------------------------
* 26.01.2014 | XPLORE       | CR0159 - Refonte POSDM
* ----------------------------------------------------------------------
* 18.02.2014 | XPLORE       | CR0269 - Exclure les articles non gérés en stock
*            |              | CR0270 - Prévoir les articles simples dans xxx_PST
* ----------------------------------------------------------------------
* 06.06.2018 | XPLORE       | Projet Refonte FT Fiori: Changer valo MATNR par MATAC
* ----------------------------------------------------------------------

  DATA: lv_factr    TYPE mb_erfmg,
        lv_isaft    TYPE xfeld,
        lV_land1    TYPE land1,
        lv_mmidx    TYPE char6                VALUE 0,
        lv_pltyp    TYPE pltyp,
        lv_reslt    TYPE xfeld,
        lv_store    TYPE kunnr,
        ls_aninv    TYPE zposdm_aninv,
        ls_anpst    TYPE zposdm_aninv_pst,
        ls_dbinv    TYPE zposdm_aninv,
        ls_dbplt    TYPE wsrs_db_plnt_cc,
        ls_dbpst    TYPE zposdm_aninv_pst,
        ls_edidd    TYPE edidd,
        ls_fting    TYPE zft_s_gw_cat_recette_ing,"zmm_s_ft_ingredient,
        ls_mmdat    TYPE imseg,
        ls_mmhdr    TYPE imkpf,
        ls_t001w    TYPE t001w,
        ls_t134m    TYPE t134m,
        ls_tcsks    TYPE csks,
        ls_tmara    TYPE mara,
        ls_vlpmp    TYPE zmm_s_ft_val_pmp,
        ls_vlpxc    TYPE zmm_s_ft_val_pline,
        ls_wpg01    TYPE e1wpg01,
        lt_aninv    TYPE TABLE OF zposdm_aninv,
        lt_anpst    TYPE TABLE OF zposdm_aninv_pst,
        lt_fting    TYPE zft_t_gw_cat_recette_ing,"zmm_t_ft_ingredient,
        lt_mmdat    TYPE TABLE OF imseg,
        lt_t134m    TYPE TABLE OF t134m,
        lt_vlpmp    TYPE zmm_t_ft_val_pmp.
  FIELD-SYMBOLS:  <imseg> TYPE imseg.


* Get store number
  lv_store                        = io_interface-idoc_segs-edidc-sndprn.

* Get document header data
  ls_mmhdr                        = io_interface-imkpf.

* Add leading zeros
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input                       = lv_store
    IMPORTING
      output                      = lv_store.

* Check if this IDoc has to be processed
  lv_reslt                        = zcl_posdm_util=>is_stock_managed( lv_store ).

  IF lv_reslt NE 'X'.
    io_interface-status-reject    = 'X'.
  ELSE.
*   Load Valuation Area >>> CR0159 - Extend to site data
    SELECT  SINGLE *            "#EC *
    INTO    ls_t001w
    FROM    t001w
    WHERE   kunnr   EQ lv_store.
*<<<CR0159

*>>> 19.10.2014 - Mantis 1093 & Mantis 1101
    lv_land1                      = ls_t001w-land1.

    SELECT  SINGLE pltyp
    INTO    lv_pltyp
    FROM    knvv
    WHERE   kunnr   EQ ls_t001w-kunnr
    AND     vkorg   EQ 'ZLOG'.
*<<< 19.10.2014 - Mantis 1093 & Mantis 1101

*   Load stock management data
    SELECT  *
    INTO    TABLE lt_t134m
    FROM    t134m
    WHERE   bwkey   EQ ls_t001w-bwkey.

    CHECK sy-subrc EQ 0.

*   Process MM Documents items
*   --------------------------
    LOOP AT io_interface-imseg INTO ls_mmdat.
*>>>CR0159 - Refonte POSDM - Lot 3
      CLEAR:  ls_mmdat-sgtxt.
*<<<CR0159 - Refonte POSDM - Lot 3

*>>> Projet Refonte FT 06.2018
    zmm_fr=>explode( EXPORTING  iv_ftnum = ls_mmdat-matnr
                                iv_bdate = ls_mmhdr-bldat
                     IMPORTING  et_ingre = lt_fting
                                ev_reslt = lv_isaft       ).
*<<< Projet Refonte FT 06.2018


*     Replace with right movement type (if necessary) - Mantis 318
      IF ls_mmdat-erfmg LT '0.000'.
        CASE ls_mmdat-bwart.
          WHEN '931'.
            ls_mmdat-bwart        = '932'.
          WHEN '932'.
            ls_mmdat-bwart        = '931'.
          WHEN '941'.
            ls_mmdat-bwart        = '942'.
          WHEN '942'.
            ls_mmdat-bwart        = '941'.
        ENDCASE.
        MULTIPLY ls_mmdat-erfmg BY -1.
      ENDIF.

*     Append MM data to reporting table ZPOSDM_ANINV
*>>>  CR0159 - Refonte POSDM
      CLEAR:  ls_aninv , ls_vlpxc , lt_vlpmp[].
      ls_aninv-mandt              = sy-mandt.
      ls_aninv-store              = ls_t001w-werks.
      ls_aninv-bdate              = ls_mmhdr-bldat.
      ls_aninv-matnr              = ls_mmdat-matnr.
      ls_aninv-bwart              = ls_mmdat-bwart.
      ls_aninv-erfmg              = ls_mmdat-erfmg.
      ls_aninv-erfme              = ls_mmdat-erfme.

*     Calcul de la valeur au PMP
      CALL FUNCTION 'ZMM_FT_VAL_PMP'
****      CALL FUNCTION 'ZMM_FT_NEW_VAL_PMP'
        EXPORTING
          iv_bdate                = ls_aninv-bdate
          iv_ftnum                = ls_aninv-matnr
          iv_werks                = ls_aninv-store
        IMPORTING
          et_costs                = lt_vlpmp[].

      LOOP AT lt_vlpmp INTO ls_vlpmp.
        ADD ls_vlpmp-verpr TO ls_aninv-vlpmp.
      ENDLOOP.

*     Calcul de la valeur au Prix de Cession (ou moyenne des FIAs)
*>>> Projet Refonte FT 06.2018
      ls_vlpxc                      =   zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr = ls_aninv-matnr
                                                                                    iv_bdate = ls_aninv-bdate
*                                                                                    iv_isaft = lv_isaft
                                                                                    iv_itype = 'FT'
                                                                                    iv_pltyp = lv_pltyp
*                            >>> 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                    iv_land1 = lv_land1
*                            <<< 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                    iv_vkorg = 'ZLOG'
                                                                                    iv_vtweg = '10'
                                                                                    iv_qtite = 1
                                                                                    iv_unite = ls_aninv-erfme
                                                                                    iv_perte = 0                ).
*<<< Projet Refonte FT 06.2018
      ls_aninv-vlpxc               = ls_vlpxc-kbetr.
      APPEND ls_aninv TO lt_aninv.
*<<<  CR0159 - Refonte POSDM

      IF lv_isaft EQ 'X'.
*       Get quantity factor
        lv_factr                  = ls_mmdat-erfmg.

*       Add only new rows
        LOOP AT lt_fting INTO ls_fting.
          ADD 1 TO lv_mmidx.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input               = lv_mmidx
            IMPORTING
              output              = ls_mmdat-posnr.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input               = lv_mmidx
            IMPORTING
              output              = ls_mmdat-ilinr.

          ls_mmdat-matnr          = ls_fting-matnr.
****          ls_mmdat-matnr          = ls_fting-matac.
          ls_mmdat-erfme          = ls_fting-unite.
          ls_mmdat-erfmg          = lv_factr * ls_fting-qtite.

*         Skip ingredient with null quantity
          IF ls_mmdat-erfmg EQ '0.000'.
            CONTINUE.
          ENDIF.

          APPEND ls_mmdat TO lt_mmdat.

*>>>      CR0159 - Refonte POSDM
*         Ajout des ingredients eclates de la FT dans la tables des postes de mouvements ANINV
          CLEAR:  ls_anpst , ls_vlpxc , lt_vlpmp[].
          ls_anpst-mandt              = ls_aninv-mandt.
          ls_anpst-store              = ls_aninv-store.
          ls_anpst-bdate              = ls_aninv-bdate.
          ls_anpst-bwart              = ls_aninv-bwart.
          ls_anpst-ftnum              = ls_aninv-matnr.
          ls_anpst-matnr              = ls_fting-matnr.
****          ls_anpst-matnr              = ls_fting-matac.
          ls_anpst-erfmg              = ls_mmdat-erfmg.
          ls_anpst-erfme              = ls_mmdat-erfme.

*         Calcul de la valeur au PMP
          CALL FUNCTION 'ZMM_FT_VAL_PMP'
****          CALL FUNCTION 'ZMM_FT_NEW_VAL_PMP'
            EXPORTING
              iv_bdate                = ls_anpst-bdate
              iv_ftnum                = ls_anpst-matnr
              iv_werks                = ls_anpst-store
            IMPORTING
              et_costs                = lt_vlpmp[].

          LOOP AT lt_vlpmp INTO ls_vlpmp.
            ADD ls_vlpmp-verpr TO ls_anpst-vlpmp.
          ENDLOOP.

*         Calcul de la valeur au Prix de Cession (ou moyenne des FIAs)
          ls_vlpxc                      =   zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr = ls_fting-matac "ls_anpst-matnr
                                                                                        iv_bdate = ls_anpst-bdate
*                                                                                        iv_isaft = lv_isaft
                                                                                        iv_itype = 'AR'
                                                                                        iv_pltyp = lv_pltyp
*                                >>> 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                        iv_land1 = lv_land1
*                                <<< 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                        iv_vkorg = 'ZLOG'
                                                                                        iv_vtweg = '10'
                                                                                        iv_qtite = 1
                                                                                        iv_unite = ls_anpst-erfme
                                                                                        iv_perte = ls_fting-perte                ).


          ls_anpst-vlpxc              = ls_vlpxc-kbetr.

          APPEND ls_anpst TO lt_anpst.
*>>>      CR0159 - Refonte POSDM
        ENDLOOP.
      ELSE.
        ADD 1 TO lv_mmidx.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input                 = lv_mmidx
          IMPORTING
            output                = ls_mmdat-posnr.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input                 = lv_mmidx
          IMPORTING
            output                = ls_mmdat-ilinr.

        APPEND ls_mmdat TO lt_mmdat.

*>>>    CR0270 - Prévoir les articles simples dans xxx_PST
        CLEAR:  ls_anpst.
        MOVE-CORRESPONDING ls_aninv TO ls_anpst.
        ls_anpst-ftnum            = ls_aninv-matnr.
        APPEND ls_anpst TO lt_anpst.
*<<<    CR0270 - Prévoir les articles simples dans xxx_PST
      ENDIF.
    ENDLOOP.

    CLEAR: io_interface-imseg[].

    LOOP AT lt_mmdat INTO ls_mmdat.
*     Get Article data
      CALL FUNCTION 'MARA_SINGLE_READ'
        EXPORTING
          matnr                   = ls_mmdat-matnr
        IMPORTING
          wmara                   = ls_tmara
        EXCEPTIONS
          OTHERS                  = 0.


      READ TABLE lt_t134m INTO ls_t134m WITH KEY mtart = ls_tmara-mtart.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

*     Skip Service articles
      IF ls_t134m-mengu EQ 'X'.
        APPEND ls_mmdat TO io_interface-imseg.
      ENDIF.
    ENDLOOP.

*   Insert/Update data in ZPOSDM_ANINV table
    LOOP AT lt_aninv INTO ls_aninv WHERE erfmg IS NOT INITIAL.
*>>>  CR0269 - Exclure les articles non gérés en stock
      CALL FUNCTION 'MARA_SINGLE_READ'
        EXPORTING
          matnr                   = ls_aninv-matnr
        IMPORTING
          wmara                   = ls_tmara
        EXCEPTIONS
          OTHERS                  = 1.

      CHECK sy-subrc EQ 0.

      READ TABLE lt_t134m INTO ls_t134m WITH KEY mtart = ls_tmara-mtart.

      CHECK ls_t134m-mengu EQ 'X'.
*<<<  CR0269 - Exclure les articles non gérés en stock

      SELECT  SINGLE *
      INTO    ls_dbinv
      FROM    zposdm_aninv
      WHERE   store   EQ ls_aninv-store
      AND     bdate   EQ ls_aninv-bdate
      AND     matnr   EQ ls_aninv-matnr
      AND     bwart   EQ ls_aninv-bwart.

      IF sy-subrc EQ 0.
        ADD ls_aninv-erfmg TO ls_dbinv-erfmg.
        UPDATE zposdm_aninv FROM ls_dbinv.
      ELSE.
        INSERT zposdm_aninv FROM ls_aninv.
      ENDIF.
    ENDLOOP.

*>>>CR0159 - Refonte POSDM
*   Mise a jour de la table des postes de Fiches Techniques
    LOOP AT lt_anpst INTO ls_anpst WHERE erfmg IS NOT INITIAL.
*>>>  CR0269 - Exclure les articles non gérés en stock
      CALL FUNCTION 'MARA_SINGLE_READ'
        EXPORTING
          matnr                   = ls_anpst-matnr
        IMPORTING
          wmara                   = ls_tmara
        EXCEPTIONS
          OTHERS                  = 1.

      CHECK sy-subrc EQ 0.

      READ TABLE lt_t134m INTO ls_t134m WITH KEY mtart = ls_tmara-mtart.

      CHECK ls_t134m-mengu EQ 'X'.
*<<<  CR0269 - Exclure les articles non gérés en stock

      SELECT  SINGLE *
      INTO    ls_dbpst
      FROM    zposdm_aninv_pst
      WHERE   store   EQ ls_anpst-store
      AND     bdate   EQ ls_anpst-bdate
      AND     ftnum   EQ ls_anpst-ftnum
      AND     matnr   EQ ls_anpst-matnr
      AND     bwart   EQ ls_anpst-bwart.

      IF sy-subrc EQ 0.
        ADD ls_anpst-erfmg TO ls_dbpst-erfmg.
        UPDATE zposdm_aninv_pst FROM ls_dbpst.
      ELSE.
        INSERT zposdm_aninv_pst FROM ls_anpst.
      ENDIF.
    ENDLOOP.
*<<<CR0159 - Refonte POSDM
  ENDIF.

*>>>CR0159 - Refonte POSDM
* Compression des postes du document MM (Refonte POSDM - Lot 2)
* ----------------------------------------------------------------
* Copie de la table des postes
  lt_mmdat[]                      = io_interface-imseg[].

* Vidage de la table initiale des postes
  CLEAR:  io_interface-imseg[].

*>>>  27.08.2014 : Mantis 980 - Correction Bug standard lors du traitement de l'IDoc en forcant le centre de profit
* Recuperation des donnees du segment E1WPG01 de l'IDoc
  READ TABLE io_interface-idoc_segs-edidd INTO ls_edidd WITH KEY segnam = 'E1WPG01'.
  IF sy-subrc EQ 0.
    ls_wpg01                      = ls_edidd-sdata.
  ENDIF.

* Recuperation du centre de cout
  SELECT  SINGLE *
  INTO    ls_dbplt
  FROM    wsrs_db_plnt_cc
  WHERE   plant   EQ ls_t001w-werks
  AND     co_area EQ 'GLD'.

* Recuperation du centre de Profit
  IF sy-subrc EQ 0.
    SELECT  SINGLE *
    INTO    ls_tcsks
    FROM    csks
    WHERE   kokrs EQ ls_dbplt-co_area
    AND     kostl EQ ls_dbplt-costcenter
    AND     datbi GE ls_wpg01-belegdatum.
  ENDIF.
*<<<  27.08.2014 : Mantis 980 -  Correction Bug standard lors du traitement de l'IDoc en forcant le centre de profit

  LOOP AT lt_mmdat INTO ls_mmdat.
    READ TABLE io_interface-imseg ASSIGNING <imseg> WITH KEY matnr = ls_mmdat-matnr erfme = ls_mmdat-erfme bwart = ls_mmdat-bwart.
    IF sy-subrc EQ 0.
      ADD ls_mmdat-erfmg TO <imseg>-erfmg.
    ELSE.
      APPEND INITIAL LINE TO io_interface-imseg ASSIGNING <imseg>.
      MOVE-CORRESPONDING ls_mmdat TO <imseg>.

*>>>  26.08.2014 : Ajout d'un texte au niveau poste MM
      <imseg>-sgtxt               = 'Remontée caisse'.
*<<<  26.08.2014 : Ajout d'un texte au niveau poste MM

*>>>  27.08.2014 : Mantis 980 - Correction Bug standard lors du traitement de l'IDoc en forcant le centre de profit
*     Forcer le centre de Profit
      IF ls_tcsks-prctr IS NOT INITIAL.
        <imseg>-prctr             = ls_tcsks-prctr.
      ENDIF.
*<<<  27.08.2014 : Mantis 980 -  Correction Bug standard lors du traitement de l'IDoc en forcant le centre de profit

*     Suppression du lien avec l'IDoc pour eviter tout probleme d'interaction entre MM et SD
      CLEAR:  <imseg>-ilinr.
    ENDIF.
  ENDLOOP.
*<<<CR0159 - Refonte POSDM