*&---------------------------------------------------------------------*
*&  Include           ZXWPUU07
*&---------------------------------------------------------------------*
*"  Parameters
*"       EXPORTING
*"             VALUE(O_TRANSACTION_WITH_ERROR) TYPE  WPUPL_BOOLEAN
*"       TABLES
*"              OUTPUT_ERROR_MESSAGES TYPE  WPUPL_ERROR_MESSAGES
*"       CHANGING
*"             REFERENCE(IO_INTERFACE)
*"                             TYPE  WPUPL_APPLICATION_DOCUMENTS
*"----------------------------------------------------------------------

* ----------------------------------------------------------------------
*                     C H A N G E   H I S T O R Y
* ----------------------------------------------------------------------
*    Date    |  Changed by  | Description
* ----------------------------------------------------------------------
* 02.02.2014 | XPLORE       | CR0159 - Refonte POSDM
* ----------------------------------------------------------------------
* 18.02.2014 | XPLORE       | CR0269 - Exclure les articles non gérés en stock
*            |              | CR0270 - Prévoir les articles simples dans xxx_PST
* ----------------------------------------------------------------------
* 06.06.2018 | XPLORE       | Projet Refonte FT Fiori: Changer valo MATNR par MATAC
* ----------------------------------------------------------------------

  DATA: lv_factr    TYPE mb_erfmg,
        lv_isaft    TYPE xfeld,
        lv_ktgrm    TYPE ktgrm,
        lv_land1    TYPE land1,
        lv_mmidx    TYPE char6                VALUE 0,
        lv_sdidx    TYPE i,
        lv_taxcd    TYPE char4,
        lv_taxm1    TYPE taxm1,
        lv_vente    TYPE char4,
        ls_cndat    TYPE komv,
        ls_fting    TYPE zft_s_gw_cat_recette_ing,"zmm_s_ft_ingredient,
        ls_idc02    TYPE edidd,
        ls_idcxx    TYPE edidd,
        ls_messg    TYPE wpupl_error_message,
        ls_mmdat    TYPE imseg,
        ls_mmhdr    TYPE imkpf,
        ls_sddat    TYPE komfkgn,
        ls_sdpos    TYPE mccpos,
        ls_tmara    TYPE mara,
        ls_wxx01    TYPE e1wxx01,
        lt_cndat    TYPE TABLE OF komv,
        lt_fting    TYPE zft_t_gw_cat_recette_ing,"zmm_t_ft_ingredient,
        lt_idc02    TYPE TABLE OF edidd,
        lt_idcxx    TYPE TABLE OF edidd,
        lt_mmdat    TYPE TABLE OF imseg,
        lt_sddat    TYPE TABLE OF komfkgn,
        lt_sdpos    TYPE TABLE OF mccpos.
  FIELD-SYMBOLS:  <cndat> TYPE komv,
                  <imseg> TYPE imseg,
                  <sddat> TYPE komfkgn.

*>>>    CR0159 - Refonte POSDM
  DATA: lv_pltyp    TYPE pltyp,
        ls_dbvnt    TYPE zposdm_vente,
        ls_dbpst    TYPE zposdm_vente_pst,
        ls_t001w    TYPE t001w,
        ls_vente    TYPE zposdm_vente,
        ls_vlpmp    TYPE zmm_s_ft_val_pmp,
        ls_vlpxc    TYPE zmm_s_ft_val_pline,
        ls_vnpst    TYPE zposdm_vente_pst,
        lt_vente    TYPE TABLE OF zposdm_vente,
        lt_vlpmp    TYPE zmm_t_ft_val_pmp,
        lt_vnpst    TYPE TABLE OF zposdm_vente_pst.
*<<<    CR0159 - Refonte POSDM

*>>>    CR0269 - Exclure les articles non gérés en stock
  DATA: ls_t134m    TYPE t134m,
        lt_t134m    TYPE TABLE OF t134m.
*<<<    CR0269 - Exclure les articles non gérés en stock



* 1. Save original values
* -----------------------
  ls_mmhdr                        = io_interface-dh_imkpf.
  lt_idc02[]                      = io_interface-idoc_segs-edidd[].
  lt_idcxx[]                      = io_interface-idoc_segs-edidd[].
  lt_sddat[]                      = io_interface-dc_komfkgn[].
  lt_sdpos[]                      = io_interface-dl_cpos[].

* 2. Process lines for MM Documents
* ---------------------------------

*>>>    CR0159 - Refonte POSDM
* Recuperation des donnees du site
  SELECT  SINGLE *
  INTO    ls_t001w
  FROM    t001w
  WHERE   kunnr   EQ io_interface-idoc_segs-edidc-sndprn.
*<<<    CR0159 - Refonte POSDM

*>>> 19.10.2014 - Mantis 1093 & Mantis 1101
  lv_land1                        = ls_t001w-land1.

  SELECT  SINGLE pltyp
  INTO    lv_pltyp
  FROM    knvv
  WHERE   kunnr   EQ ls_t001w-kunnr
  AND     vkorg   EQ 'ZLOG'.
*<<< 19.10.2014 - Mantis 1093 & Mantis 1101

*>>>    CR0269 - Exclure les articles non gérés en stock
* Load stock management data
  SELECT  *
  INTO    TABLE lt_t134m
  FROM    t134m
  WHERE   bwkey   EQ ls_t001w-bwkey.
*<<<    CR0269 - Exclure les articles non gérés en stock

  LOOP AT io_interface-dl_imseg INTO ls_mmdat.
*>>>CR0159 - Refonte POSDM - Lot 3
    CLEAR:  ls_mmdat-sgtxt.
*<<<CR0159 - Refonte POSDM - Lot 3

*>>> Projet Refonte FT 06.2018
    zmm_fr=>explode( EXPORTING  iv_ftnum = ls_mmdat-matnr
                                iv_bdate = ls_mmhdr-bldat
                     IMPORTING  et_ingre = lt_fting
                                ev_reslt = lv_isaft       ).
*<<< Projet Refonte FT 06.2018

*>>>CR0159 - Refonte POSDM
    CLEAR:  ls_vente , ls_vlpxc , lt_vlpmp[].

    ls_vente-mandt                = sy-mandt.
    ls_vente-store                = ls_t001w-werks.
    ls_vente-bdate                = ls_mmhdr-bldat.
    ls_vente-matnr                = ls_mmdat-matnr.
    ls_vente-bwart                = ls_mmdat-bwart.
    ls_vente-erfmg                = ls_mmdat-erfmg.
    ls_vente-erfme                = ls_mmdat-erfme.

*   Calcul de la valeur au PMP
    CALL FUNCTION 'ZMM_FT_VAL_PMP'
****    CALL FUNCTION 'ZMM_FT_NEW_VAL_PMP'
      EXPORTING
        iv_bdate                  = ls_vente-bdate
        iv_ftnum                  = ls_vente-matnr
        iv_werks                  = ls_vente-store
      IMPORTING
        et_costs                  = lt_vlpmp[].

    LOOP AT lt_vlpmp INTO ls_vlpmp.
      ADD ls_vlpmp-verpr TO ls_vente-vlpmp.
    ENDLOOP.

*   Calcul de la valeur au Prix de Cession (ou moyenne des FIAs)
*>>> Projet Refonte FT 06.2018
    ls_vlpxc                      =   zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr = ls_vente-matnr
                                                                                  iv_bdate = ls_vente-bdate
*                                                                                  iv_isaft = lv_isaft
                                                                                  iv_itype = 'FT'
                                                                                  iv_pltyp = lv_pltyp
*                          >>> 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                  iv_land1 = lv_land1
*                          <<< 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                  iv_vkorg = 'ZLOG'
                                                                                  iv_vtweg = '10'
                                                                                  iv_qtite = 1
                                                                                  iv_unite = ls_vente-erfme
                                                                                  iv_perte = 0                ).
*<<< Projet Refonte FT 06.2018
    ls_vente-vlpxc                = ls_vlpxc-kbetr.

    APPEND ls_vente TO lt_vente.
*<<<CR0159 - Refonte POSDM

    IF lv_isaft EQ 'X'.
*     Get quantity factor
      lv_factr                    = ls_mmdat-erfmg.

*     Add only new rows
      LOOP AT lt_fting INTO ls_fting.
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

        ls_mmdat-matnr            = ls_fting-matnr.
****        ls_mmdat-matnr            = ls_fting-matac.
        ls_mmdat-erfme            = ls_fting-unite.

*       Mantis 1446 - Utilisation d'une quantite avec plus de decimales pour gerer les arrondis sur plusieurs niveaux
        ls_mmdat-erfmg            = lv_factr * ls_fting-qte_7.
        APPEND ls_mmdat TO lt_mmdat.

*>>>    CR0159 - Refonte POSDM
*       Ajout des ingredients eclates de la FT dans la tables des postes de mouvements VENTE
        CLEAR:  ls_vnpst , ls_vlpxc , lt_vlpmp[].
        ls_vnpst-mandt            = ls_vente-mandt.
        ls_vnpst-store            = ls_vente-store.
        ls_vnpst-bdate            = ls_vente-bdate.
        ls_vnpst-bwart            = ls_vente-bwart.
        ls_vnpst-ftnum            = ls_vente-matnr.
        ls_vnpst-matnr            = ls_fting-matnr.
****        ls_vnpst-matnr            = ls_fting-matac.
        ls_vnpst-erfmg            = ls_mmdat-erfmg.
        ls_vnpst-erfme            = ls_mmdat-erfme.

*       Calcul de la valeur au PMP
        CALL FUNCTION 'ZMM_FT_VAL_PMP'
****        CALL FUNCTION 'ZMM_FT_NEW_VAL_PMP'
          EXPORTING
            iv_bdate              = ls_vnpst-bdate
            iv_ftnum              = ls_vnpst-matnr
            iv_werks              = ls_vnpst-store
          IMPORTING
            et_costs              = lt_vlpmp[].

        LOOP AT lt_vlpmp INTO ls_vlpmp.
          ADD ls_vlpmp-verpr TO ls_vnpst-vlpmp.
        ENDLOOP.

*       Calcul de la valeur au Prix de Cession (ou moyenne des FIAs)
      ls_vlpxc                      =   zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr = ls_fting-matac "ls_vnpst-matnr
                                                                                    iv_bdate = ls_vnpst-bdate
*                                                                                    iv_isaft = lv_isaft
                                                                                    iv_itype = 'AR'
                                                                                    iv_pltyp = lv_pltyp
*                            >>> 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                    iv_land1 = lv_land1
*                            <<< 19.10.2014 - Mantis 1093 & Mantis 1101
                                                                                    iv_vkorg = 'ZLOG'
                                                                                    iv_vtweg = '10'
                                                                                    iv_qtite = 1
                                                                                    iv_unite = ls_vnpst-erfme
                                                                                    iv_perte = ls_fting-perte               ).

        ls_vnpst-vlpxc            = ls_vlpxc-kbetr.

        APPEND ls_vnpst TO lt_vnpst.
*>>>    CR0159 - Refonte POSDM
      ENDLOOP.
    ELSE.
      ADD 1 TO lv_mmidx.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input                   = lv_mmidx
        IMPORTING
          output                  = ls_mmdat-posnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input                   = lv_mmidx
        IMPORTING
          output                  = ls_mmdat-ilinr.

      APPEND ls_mmdat TO lt_mmdat.

*>>>  CR0270 - Prévoir les articles simples dans xxx_PST
      CLEAR:  ls_vnpst.
      MOVE-CORRESPONDING ls_vente TO ls_vnpst.
      ls_vnpst-ftnum              = ls_vente-matnr.
      APPEND ls_vnpst TO lt_vnpst.
*<<<  CR0270 - Prévoir les articles simples dans xxx_PST
    ENDIF.
  ENDLOOP.

* 3. Process lines for SD Documents
* ---------------------------------
  DELETE lt_idc02 WHERE segnam NE 'E1WPU02'.
  DELETE lt_idcxx WHERE segnam NE 'E1WXX01'.

  SORT lt_idc02 BY mandt docnum segnum segnam psgnum hlevel.
  DELETE ADJACENT DUPLICATES FROM lt_idc02.

* IDoc data
  LOOP AT lt_idc02 INTO ls_idc02.
    lv_sdidx                      = lv_sdidx + 1.

*   Extension data
    CLEAR:  lv_vente , lv_taxcd.
    LOOP AT lt_idcxx INTO ls_idcxx WHERE psgnum = ls_idc02-segnum.
      ls_wxx01                    = ls_idcxx-sdata.

      CASE ls_wxx01-fldname.
        WHEN 'VENTE'.
*         Vente
          lv_vente                = ls_wxx01-fldval.

        WHEN 'TAXCD'.
*         Code TVA
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input               = ls_wxx01-fldval
            IMPORTING
              output              = lv_taxcd.

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

*   Vente transcodification
    CASE lv_vente.
      WHEN '1001'.  " VES
        lv_ktgrm                  = 'A2'.

      WHEN '1002'.  " VAE
        lv_ktgrm                  = 'A1'.

      WHEN '1003'.  " Kiosque
        lv_ktgrm                  = 'A3'.

      WHEN OTHERS.
    ENDCASE.

*   Tax transcodification
    CASE lv_taxcd.
      WHEN '1' OR '19.6'.   " TVA Taux Plein
        lv_taxm1                  = '1'.

      WHEN '2' OR '5.5'.    " TVA Taux Réduit
        lv_taxm1                  = '2'.

      WHEN '3'.             " TVA Taux Luxembourg
        lv_taxm1                  = '3'.

      WHEN '4'.             " TVA Taux Intermédiaire
        lv_taxm1                  = '4'.

      WHEN OTHERS.
*       Incorrect tax code
        ls_messg-segnum           = ls_idc02-segnum.
        ls_messg-msgty            = 'E'.
        ls_messg-msgnr            = '011'.
        ls_messg-msgid            = 'ZPOSDM'.
        ls_messg-parameter1       = lv_taxcd.
        APPEND ls_messg TO output_error_messages.
    ENDCASE.

*   Update billing data
    READ TABLE lt_sddat INTO ls_sddat INDEX lv_sdidx.
    IF sy-subrc EQ 0.
*     Update "vente"
      ls_sddat-ktgrm              = lv_ktgrm.

*     Update tax code
      ls_sddat-taxm1              = lv_taxm1.

*     Set the right partner (SAP's bug fix)
      IF io_interface-idoc_segs-edidc-rcvprn NE 'SAP'.  " WPUK fills the IDoc receiver with "SAP"
        ls_sddat-kunag            = io_interface-idoc_segs-edidc-rcvprn.
      ENDIF.

      MODIFY lt_sddat FROM ls_sddat INDEX lv_sdidx.
    ENDIF.

*   Update statistics data
    READ TABLE lt_sdpos INTO ls_sdpos INDEX lv_sdidx.
    IF sy-subrc EQ 0.
*>>>    CR0159 - Refonte POSDM - Lot 2
**     Update "vente"
*      ls_sdpos-ktgrm              = lv_ktgrm.
*<<<    CR0159 - Refonte POSDM - Lot 2

*     Update tax code
      ls_sdpos-mwskz              = lv_taxm1.

      MODIFY lt_sdpos FROM ls_sdpos INDEX lv_sdidx.
    ENDIF.
  ENDLOOP.

*>>>    CR0159 - Refonte POSDM
* 4. Sauvegarde du detail des mouvements avec valorisation dans les tables de VENTE
* ----------------------------
*   Mise a jour de la table d'entete des mouvements
  LOOP AT lt_vente INTO ls_vente WHERE erfmg IS NOT INITIAL.
*>>>    CR0269 - Exclure les articles non gérés en stock
    CALL FUNCTION 'MARA_SINGLE_READ'
      EXPORTING
        matnr                     = ls_vente-matnr
      IMPORTING
        wmara                     = ls_tmara
      EXCEPTIONS
        OTHERS                    = 1.

    CHECK sy-subrc EQ 0.

    READ TABLE lt_t134m INTO ls_t134m WITH KEY mtart = ls_tmara-mtart.

    CHECK ls_t134m-mengu EQ 'X'.
*<<<    CR0269 - Exclure les articles non gérés en stock

    SELECT  SINGLE *
    INTO    ls_dbvnt
    FROM    zposdm_vente
    WHERE   store   EQ ls_vente-store
    AND     bdate   EQ ls_vente-bdate
    AND     matnr   EQ ls_vente-matnr
    AND     bwart   EQ ls_vente-bwart.

    IF sy-subrc EQ 0.
      ADD ls_vente-erfmg TO ls_dbvnt-erfmg.
      UPDATE zposdm_vente FROM ls_dbvnt.
    ELSE.
      INSERT zposdm_vente FROM ls_vente.
    ENDIF.
  ENDLOOP.

* Mise a jour de la table des postes de Fiches Techniques
  LOOP AT lt_vnpst INTO ls_vnpst WHERE erfmg IS NOT INITIAL.
*>>>    CR0269 - Exclure les articles non gérés en stock
    CALL FUNCTION 'MARA_SINGLE_READ'
      EXPORTING
        matnr                   = ls_vnpst-matnr
      IMPORTING
        wmara                   = ls_tmara
      EXCEPTIONS
        OTHERS                  = 1.

    CHECK sy-subrc EQ 0.

    READ TABLE lt_t134m INTO ls_t134m WITH KEY mtart = ls_tmara-mtart.

    CHECK ls_t134m-mengu EQ 'X'.
*<<<    CR0269 - Exclure les articles non gérés en stock

    SELECT  SINGLE *
    INTO    ls_dbpst
    FROM    zposdm_vente_pst
    WHERE   store   EQ ls_vnpst-store
    AND     bdate   EQ ls_vnpst-bdate
    AND     ftnum   EQ ls_vnpst-ftnum
    AND     matnr   EQ ls_vnpst-matnr
    AND     bwart   EQ ls_vnpst-bwart.

    IF sy-subrc EQ 0.
      ADD ls_vnpst-erfmg TO ls_dbpst-erfmg.
      UPDATE zposdm_vente_pst FROM ls_dbpst.
    ELSE.
      INSERT zposdm_vente_pst FROM ls_vnpst.
    ENDIF.
  ENDLOOP.

* 4. Compression des postes du document MM (Refonte POSDM - Lot 2)
* ----------------------------------------------------------------
* Vidage de la table initiale des postes
  CLEAR:  io_interface-dl_imseg[].

  LOOP AT lt_mmdat INTO ls_mmdat.
    READ TABLE io_interface-dl_imseg ASSIGNING <imseg> WITH KEY matnr = ls_mmdat-matnr erfme = ls_mmdat-erfme bwart = ls_mmdat-bwart.
    IF sy-subrc EQ 0.
      ADD ls_mmdat-erfmg TO <imseg>-erfmg.
    ELSE.
      APPEND INITIAL LINE TO io_interface-dl_imseg ASSIGNING <imseg>.
      MOVE-CORRESPONDING ls_mmdat TO <imseg>.

*>>>  26.08.2014 : Ajout d'un texte au niveau poste MM
      <imseg>-sgtxt               = 'Remontée caisse'.
*<<<  26.08.2014 : Ajout d'un texte au niveau poste MM

*     Suppression du lien avec l'IDoc pour eviter tout probleme d'interaction entre MM et SD
      CLEAR:  <imseg>-ilinr.
    ENDIF.
  ENDLOOP.

* 5. Compression des postes du document SD (Refonte POSDM - Lot 2) et des conditions SD
* -------------------------------------------------------------------------------------
* 03.06.2014 - Demande annulee suite a un mail de Marieke Briens a cause des problemes
*              causes sur la table S921
  io_interface-dc_komfkgn[]       = lt_sddat[].
*<<<CR0159 - Refonte POSDM

* 6. Final values update
* ----------------------
  io_interface-dl_cpos[]          = lt_sdpos[].