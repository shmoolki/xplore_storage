METHOD load_ft.
  TYPES: BEGIN OF ty_crdef,
            ftnum   TYPE zmm_ftnum,
            srnum   TYPE zmm_srnum,
            srver   TYPE zmm_srver,
            apdeb   TYPE zmm_ft_apdeb.
    INCLUDE TYPE  zft_s_gw_cat_recette.
  TYPES: END OF ty_crdef,
        BEGIN OF ty_volum,
          apde2     TYPE zmm_ft_apdeb,
          apfi2     TYPE zmm_ft_apdeb.
       INCLUDE TYPE zft_s_gw_cat_recette_volume .
       TYPES: END OF ty_volum,
        tt_crdef    TYPE TABLE OF ty_crdef.

  DATA: lv_arcid    TYPE saeardoid,
        lv_matnr    TYPE matnr,
        lv_objct    TYPE saeanwdid,
        lv_objid    TYPE saeobjid,
        ls_arcob    TYPE zao_s_toauri,
        ls_volum    TYPE ty_volum,
        ls_volu2    TYPE zft_s_gw_cat_recette_volume,
        lt_arcob    TYPE zao_t_toauri,
        lt_volum    TYPE TABLE OF ty_volum,
        lx_croot    TYPE REF TO cx_root,
*        lv_datab    TYPE datab,
        lv_datbi    TYPE datbi,
        lv_frnum    TYPE zmm_ftnum,
        lv_objtp    TYPE zft_gw_objtp,
        ls_ensgn    TYPE zmm_ft_ens,
        ls_ingre    TYPE zmm_s_ft_ingredient,
        ls_micrs    TYPE ztmm0001,
        lt_sring    TYPE TABLE OF zmm_sr_ing,
        lt_srver    TYPE TABLE OF zmm_sr_ver,
        ls_srver    TYPE zmm_sr_ver,
        ls_sring    TYPE zmm_sr_ing,
        ls_defft    TYPE zmm_ft_def,
        ls_rcthd    TYPE zcl_zft_gw_cat_recette_mpc=>ts_recette,
        ls_rc2en    TYPE zcl_zft_gw_cat_recette_mpc=>ts_enseigne,
        ls_rc2im    TYPE zcl_zft_gw_cat_recette_mpc=>ts_image,
        ls_rc2in    TYPE zcl_zft_gw_cat_recette_mpc=>ts_ingredient,
        ls_rc2tp    TYPE zcl_zft_gw_cat_recette_mpc=>ts_tpv,
        ls_rc2vr    TYPE zcl_zft_gw_cat_recette_mpc=>ts_version,
        ls_rc2tx    TYPE zcl_zft_gw_cat_recette_mpc=>ts_texte,
        ls_recet    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_deep_recette,
        lt_ense2   TYPE TABLE OF zcl_zft_gw_cat_recette_mpc=>ts_enseigne,
        ls_ense2   TYPE zcl_zft_gw_cat_recette_mpc=>ts_enseigne,
        ls_t023t    TYPE t023t,
        ls_tmara    TYPE mara,
        ls_tmakt    TYPE makt,
        ls_tmaw1    TYPE maw1,
        ls_txmat    TYPE tdline,
        ls_txmod    TYPE tdline,
        ls_txpre    TYPE tdline,
        ls_txptc    TYPE tdline,
        ls_versn    TYPE zmm_s_ft_version,
        ls_ftdef    TYPE zmm_ft_def,
        lt_taxdt    TYPE TABLE OF mg03steuer,
        lt_txmat    TYPE tline_t,
        lt_txmod    TYPE tline_t,
        lt_txpre    TYPE tline_t,
        lt_txptc    TYPE tline_t,
        lt_micrs    TYPE zmm_t_0001,
        lt_charc    TYPE zmm_t_bapimatcha,
        lt_ensgn    TYPE zmm_t_ft_enseigne,
        lt_ensei    TYPE TABLE OF zgld_enseigne,
        ls_ensei    TYPE zgld_enseigne,
        lt_ingre    TYPE zmm_t_ft_ingredient,
        lt_versn    TYPE zmm_t_ft_version,
        lt_catrc    TYPE tt_crdef,
        lt_dmntx    TYPE TABLE OF dd07v,
        lt_dmntt    TYPE TABLE OF dd07v,
        ls_dmntx    TYPE dd07v,
        ls_etset    TYPE zft_s_gw_vh_statuts,
        lt_stats    TYPE TABLE OF zft_s_gw_vh_statuts,
        lt_catsr    TYPE tt_crdef,
        ls_catrc    TYPE ty_crdef,
        ls_infcr    TYPE zft_s_gw_cat_recette,
        lv_class    TYPE klasse_d,
        ls_wmara    TYPE mara,
        lt_retrn    TYPE TABLE OF bapiret2,
        lt_slist    TYPE TABLE OF bapi1003_tree,
        lt_rcing    TYPE TABLE OF zmm_ft_ing,
        ls_rcing    TYPE zmm_ft_ing,
        ls_valdt    TYPE zmm_s_ft_val_pline,
        ls_retrn    TYPE bapiret2,
        ls_slist    TYPE bapi1003_tree,
        ls_famil    TYPE /iwbep/s_mgw_select_option,
        lr_frnum    TYPE /iwbep/s_mgw_select_option,
        lr_carte    TYPE /iwbep/s_mgw_select_option,
        lr_titre    TYPE /iwbep/s_mgw_select_option,
        lr_ensgn    TYPE /iwbep/s_mgw_select_option,
        lr_stats    TYPE /iwbep/s_mgw_select_option,
        ls_selop    TYPE /iwbep/s_cod_select_option,
        lv_dummy    TYPE string VALUE 'dummy',
        lv_paths    TYPE localfile,
        lv_datab    TYPE datab,
        lv_month    TYPE i,
        ls_ftver    TYPE ty_crdef,
        lt_ftver    TYPE TABLE OF ty_crdef.
    FIELD-SYMBOLS: <catrc> TYPE  ty_crdef.
  FIELD-SYMBOLS: <rc2vl>    TYPE zcl_zft_gw_cat_recette_mpc=>ts_volume,
                 <rc2im>    TYPE zcl_zft_gw_cat_recette_mpc=>ts_image,
                 <ensgn>   TYPE zmm_ft_ens.

* Convert MATNR
  lv_matnr  = me->gv_frnum.

* Create a new object instance
  CREATE OBJECT me->gr_ftobj
    EXPORTING
      iv_ftnum = me->gv_frnum.

  TRY.
     gr_ftobj->load( ).
  CATCH cx_root INTO lx_croot.

  ENDTRY.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
   EXPORTING
     input                 = me->gv_frnum
   IMPORTING
     output                = me->gv_frnum
   EXCEPTIONS
     OTHERS                = 0.

  ls_rcthd-frnum                = me->gv_frnum.

  LOOP AT me->gr_ftobj->gt_versn INTO ls_versn.
    MOVE-CORRESPONDING ls_versn TO ls_rc2vr.
    ls_rc2vr-frnum              = lv_frnum.
    APPEND ls_rc2vr TO me->gt_versn.
  ENDLOOP.

  SORT me->gt_versn BY apdeb ASCENDING.

* Initialisation
  CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name          = 'ZMM_FT_STATS'
      get_state            = 'M  '
      langu                = sy-langu
      prid                 = 0
      withtext             = 'X'
    TABLES
      dd07v_tab_a          = lt_dmntx
      dd07v_tab_n          = lt_dmntt
    EXCEPTIONS
      OTHERS               = 3
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    LOOP AT lt_dmntx INTO ls_dmntx.
      ls_etset-stats        = ls_dmntx-domvalue_l.
      ls_etset-vtext        = ls_dmntx-ddtext.
      APPEND ls_etset TO lt_stats.
    ENDLOOP.
  ENDIF.

  IF me->lv_newfr NE 'X'.
    SELECT   R~* , ' ' AS isfic , m~maktx AS titre, r~arcid
    INTO     CORRESPONDING FIELDS OF TABLE @lt_catrc
    FROM     zmm_ft_def AS r
    INNER    JOIN makt AS m ON m~matnr EQ r~ftnum AND m~spras EQ 'F'
    LEFT     OUTER JOIN zmm_ca_itm AS c ON r~ftnum EQ c~frnum
    LEFT     OUTER JOIN zmm_ft_ens AS e ON r~ftnum EQ e~ftnum
    WHERE    r~ftnum EQ @me->gv_frnum.

    SORT lt_catrc.
    DELETE ADJACENT DUPLICATES FROM lt_catrc COMPARING ftnum.

    LOOP AT lt_catrc ASSIGNING <catrc>.
       READ TABLE lt_stats WITH KEY stats = <catrc>-stats INTO ls_etset.
       <catrc>-tstat               = ls_etset-vtext.


      <catrc>-frnum            = <catrc>-ftnum.
      lv_objtp                    = 'F'.
      MOVE-CORRESPONDING <catrc> TO ls_infcr.

      SELECT       SINGLE *
      INTO         CORRESPONDING FIELDS OF <catrc>
      FROM         zmm_ft_ver
      WHERE        ftnum EQ <catrc>-ftnum
      AND          apdeb LE sy-datum
      AND          apfin GE sy-datum.

*     If there's not active version
      IF sy-subrc NE 0.

        SELECT     *
        INTO       CORRESPONDING FIELDS OF TABLE lt_ftver
        FROM       zmm_ft_ver
        WHERE      ftnum EQ <catrc>-ftnum.

        IF sy-subrc EQ 0.

          SORT lt_ftver BY apdeb.

          LOOP AT lt_ftver INTO ls_ftver WHERE apdeb GT sy-datum.
            <catrc>-ftver         = ls_ftver-ftver.
            EXIT.
          ENDLOOP.

          IF ls_ftver IS INITIAL.

            LOOP AT lt_ftver INTO ls_ftver WHERE apdeb LT sy-datum.
            ENDLOOP.

            IF ls_ftver IS NOT INITIAL.
              <catrc>-ftver       = ls_ftver-ftver.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

      SELECT       *
      INTO         TABLE lt_rcing
      FROM         zmm_ft_ing
      WHERE        ftnum EQ <catrc>-ftnum
      AND          ftver EQ <catrc>-ftver.

      DESCRIBE TABLE lt_rcing LINES <catrc>-nbing.

      lv_objct                        = zcl_zft_gw_ft_utilities=>cv_content_article.
      lv_objid                        = <catrc>-frnum.
      lv_arcid                        = <catrc>-arcid.

      IF <catrc>-arcid IS NOT INITIAL.
        CALL FUNCTION 'ZAO_DOCUMENT_GET'
          EXPORTING
            iv_objct                  = lv_objct
            iv_objid                  = lv_objid
            iv_arcid                  = lv_arcid
          IMPORTING
            et_arcob                  = lt_arcob
            et_retrn                  = lt_retrn
          EXCEPTIONS
            OTHERS                    = 1 .
       ELSE.
        CALL FUNCTION 'ZAO_DOCUMENT_GET'
          EXPORTING
            iv_objct                  = lv_objct
            iv_objid                  = lv_objid
          IMPORTING
            et_arcob                  = lt_arcob
            et_retrn                  = lt_retrn
          EXCEPTIONS
            OTHERS                    = 1 .
       ENDIF.

       LOOP AT lt_arcob INTO ls_arcob.
         TRANSLATE ls_arcob-mimetype TO UPPER CASE.
         IF NOT ls_arcob-mimetype CS 'IMAGE'.
           CONTINUE.
         ENDIF.
         EXIT.
       ENDLOOP.
       IF ls_arcob IS NOT INITIAL.

         SELECT SINGLE *
         INTO   ls_defft
         FROM   zmm_ft_def
         WHERE  ftnum EQ <catrc>-ftnum.

         IF sy-subrc EQ 0 AND ls_defft-arcid IS INITIAL.
           ls_defft-arcid         = ls_arcob-arc_doc_id.
           MODIFY zmm_ft_def FROM ls_defft.

           IF sy-subrc EQ 0.
             COMMIT WORK AND WAIT.
             <catrc>-arcid        = ls_defft-arcid  .
           ENDIF.
         ENDIF.

         <catrc>-imsrc             = ls_arcob-uri.
       ENDIF.

*     Valorisation
      ls_valdt                        = zcl_zft_gw_ft_utilities=>get_valorisation(  iv_matnr  = <catrc>-frnum
                                                                                    iv_bdate  = sy-datum
                                                                                    iv_itype  = 'FT'
                                                                                    iv_pltyp  = 'FR'
                                                                                    iv_land1  = space
                                                                                    iv_vkorg  = 'ZLOG'
                                                                                    iv_vtweg  = '10'
                                                                                    iv_qtite  = '1.000'
                                                                                    iv_unite  = 'PCE'
                                                                                   iv_perte  = '0.00'
                                                                                   ). "Initialiser a 1 pour les SR (en cas de FT n'est pas pris en compte)
       <catrc>-valor                = ls_valdt-prixm.

      CALL FUNCTION 'MARA_SINGLE_READ'
        EXPORTING
          matnr                     = <catrc>-frnum
       IMPORTING
         wmara                      = ls_wmara
       EXCEPTIONS
         OTHERS                     = 0.

      <catrc>-famil              = ls_wmara-matkl.

      CALL FUNCTION 'T023T_SINGLE_READ'
        EXPORTING
          t023t_spras               = sy-langu
          t023t_matkl               = ls_wmara-matkl
        IMPORTING
          wt023t                    = ls_t023t
        EXCEPTIONS
          OTHERS                    = 1.

      IF sy-subrc EQ 0.
        <catrc>-famtx            = ls_t023t-wgbez.
      ENDIF.
    ENDLOOP.

    IF sy-subrc EQ 0.

    ENDIF.
    READ TABLE lt_catrc INDEX 1 INTO ls_catrc.

    MOVE-CORRESPONDING ls_catrc TO me->gs_recet.


    me->gs_recet-aeda2                 = ls_catrc-aedat.
    me->gs_recet-erda2                 = ls_catrc-erdat.


    LOOP AT me->gr_ftobj->gt_ingre INTO ls_ingre.
      MOVE-CORRESPONDING ls_ingre TO ls_rc2in.

      me->get_ing_stat(
            EXPORTING
              iv_matnr            = ls_rc2in-matnr
              iv_typea            = ls_rc2in-typea
              iv_frnum            = me->gs_recet-frnum
            IMPORTING
              ev_stats            = ls_rc2in-stats
              ev_tstat            = ls_rc2in-tstat ).

      ls_rc2in-frnum              = lv_frnum.
      ls_rc2in-qtyrl              = ls_rc2in-qtite + (  ls_rc2in-perte *  ls_rc2in-qtite / 100 ) .

      APPEND ls_rc2in TO me->gt_ingre.
    ENDLOOP.



      ls_rc2tx-frnum                = lv_frnum.

      LOOP AT me->gr_ftobj->gt_txmat INTO ls_txmat.
        IF sy-tabix EQ 1.
          ls_rc2tx-materl           = ls_txmat.
        ELSE.
          CONCATENATE ls_rc2tx-materl ls_txmat INTO ls_rc2tx-materl SEPARATED BY cl_abap_char_utilities=>newline.
        ENDIF.
      ENDLOOP.
      LOOP AT me->gr_ftobj->gt_txpre INTO ls_txmat.
        IF sy-tabix EQ 1.
          ls_rc2tx-prepar           = ls_txmat.
        ELSE.
          CONCATENATE ls_rc2tx-prepar ls_txmat INTO ls_rc2tx-prepar SEPARATED BY cl_abap_char_utilities=>newline.
        ENDIF.
      ENDLOOP.
      LOOP AT me->gr_ftobj->gt_txmod INTO ls_txmat.
        IF sy-tabix EQ 1.
          ls_rc2tx-modop           = ls_txmat.
        ELSE.
          CONCATENATE ls_rc2tx-modop ls_txmat INTO ls_rc2tx-modop SEPARATED BY cl_abap_char_utilities=>newline.
        ENDIF.
      ENDLOOP.
      LOOP AT me->gr_ftobj->gt_txptc INTO ls_txmat.
        IF sy-tabix EQ 1.
          ls_rc2tx-ptcrq           = ls_txmat.
        ELSE.
          CONCATENATE ls_rc2tx-ptcrq ls_txmat INTO ls_rc2tx-ptcrq SEPARATED BY cl_abap_char_utilities=>newline.
        ENDIF.
      ENDLOOP.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txptc TO me->gt_txptc.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txptc TO me->lt_txptc.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txmat TO me->gt_txmat.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txmat TO me->lt_txmat.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txpre TO me->gt_txpre.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txpre TO me->lt_txpre.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txmod TO me->gt_txmod.
      MOVE-CORRESPONDING me->gr_ftobj->gt_txmod TO me->lt_txmod.
      APPEND ls_rc2tx TO me->gt_texte.

      READ TABLE me->gr_ftobj->gt_ensgn INTO ls_ensgn INDEX 1.
      IF sy-subrc EQ 0.
        ls_recet-ensgn              = ls_ensgn-ensgn.
      ENDIF.

****      SELECT *
****      INTO TABLE lt_ensei
****      FROM zgld_enseigne.
****
****      LOOP AT lt_ensei INTO ls_ensei.
****        CLEAR: ls_rc2en.
****        CONCATENATE 'Z' ls_ensei-ensgn INTO ls_ensei-ensgn.
****        AUTHORITY-CHECK OBJECT 'W_VKPR_PLT'
****                 ID 'VKORG' FIELD ls_ensei-ensgn
****                 ID 'VTWEG' FIELD '*'
****                 ID 'PLTYP' FIELD '*'
****                 ID 'MATKL' FIELD '*'
****                 ID 'ACTVT' FIELD '03'.
****        IF sy-subrc EQ 0.
****         ls_ensei-ensgn           = ls_ensei-ensgn+1.
****         MOVE-CORRESPONDING ls_ensei TO ls_rc2en.
****         READ TABLE me->gr_ftobj->gt_ensgn TRANSPORTING NO FIELDS WITH KEY ensgn = ls_ensei-ensgn.
****         IF sy-subrc EQ 0.
****           ls_rc2en-activ              = 'X'.
****         ENDIF.
****         ls_rc2en-frnum              = me->gv_frnum.
****         APPEND ls_rc2en TO me->gt_ensgn.
****        ENDIF.
****      ENDLOOP.
**********************************************************************
****    SELECT      e~ensgn, e~entxt, e~gamme, t~name1 AS gamtx, g~vkorg, v~vtext AS orgtx
    SELECT      e~ensgn, e~entxt, e~ensgn AS gamme, e~entxt AS gamtx, e~vkorg, v~vtext AS orgtx
    INTO        CORRESPONDING FIELDS OF TABLE @lt_ense2
    FROM        zgld_enseigne AS e
****    INNER       JOIN  wrs1   AS g ON g~asort EQ e~gamme
****    INNER       JOIN  wrst   AS t ON g~asort EQ t~asort
****    INNER       JOIN  tvkot  AS v ON g~vkorg EQ v~vkorg
    INNER       JOIN  tvkot  AS v ON e~vkorg EQ v~vkorg
    WHERE       v~spras EQ 'F'
    AND         e~activ EQ 'X'.
****    AND         t~spras EQ 'F'.

    LOOP AT lt_ense2 INTO ls_ense2.
      CLEAR: ls_rc2en.
      AUTHORITY-CHECK OBJECT 'W_VKPR_PLT'
               ID 'VKORG' FIELD ls_ense2-vkorg
               ID 'VTWEG' FIELD '*'
               ID 'PLTYP' FIELD '*'
               ID 'MATKL' FIELD '*'
               ID 'ACTVT' FIELD '03'.

      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_ense2 TO ls_rc2en.
        ls_rc2en-frnum            = me->gv_frnum.
       READ TABLE me->gr_ftobj->gt_ensgn TRANSPORTING NO FIELDS WITH KEY ensgn = ls_ense2-ensgn.
       IF sy-subrc EQ 0.
         ls_rc2en-activ              = 'X'.
       ENDIF.
        APPEND ls_rc2en TO me->gt_ensgn.
      ENDIF.
    ENDLOOP.


      LOOP AT me->gr_ftobj->gt_micrs INTO ls_micrs.
        MOVE-CORRESPONDING ls_micrs TO ls_rc2tp.

        ls_rc2tp-frnum                = lv_frnum.
        APPEND ls_rc2tp TO me->gt_micrs.
      ENDLOOP.

    lv_objid                          = me->gv_frnum.

    CALL FUNCTION 'ZAO_DOCUMENT_GET'
      EXPORTING
        iv_objct                      = lv_objct
        iv_objid                      = lv_objid
      IMPORTING
        et_arcob                      = lt_arcob
        et_retrn                      = lt_retrn
      EXCEPTIONS
        OTHERS                        = 1.

      IF sy-subrc EQ 0 AND lt_retrn[] IS INITIAL.
        LOOP AT lt_arcob INTO ls_arcob.
          TRANSLATE ls_arcob-mimetype TO UPPER CASE.
          IF NOT ls_arcob-mimetype CS 'IMAGE'.
            CONTINUE.
          ENDIF.
          CLEAR ls_rc2im.
          ls_rc2im-arcid              = ls_arcob-arc_doc_id.
          ls_rc2im-frnum              = lv_objid.
          ls_rc2im-imsrc              = ls_arcob-uri.
          ls_rc2im-descr              = ls_arcob-descr.
          ls_rc2im-fname              = ls_arcob-fname.
          IF ls_rc2im-arcid EQ <catrc>-arcid.
            ls_rc2im-fmain            =  abap_true.
          ENDIF.
          APPEND ls_rc2im TO me->gt_image.
        ENDLOOP.
      ENDIF.

*     Volumes
      me->gt_volum = me->get_volum( ) .
  ELSE.

  ENDIF.

ENDMETHOD.