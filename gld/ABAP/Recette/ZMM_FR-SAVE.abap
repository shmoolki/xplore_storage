METHOD save.
  DATA: lv_compt    TYPE i,
        lv_imcop    TYPE xfeld,
        lv_evtid    TYPE zmm_ft_alert,
        lv_objid    TYPE saeobjid,
        lv_objct    TYPE saeanwdid,
        lv_srref    TYPE zmm_frnum,
        ls_arcob    TYPE zao_s_toauri,
        ls_ensgn    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_enseigne,
        ls_ensft    TYPE zmm_ft_ens,
        ls_notif    TYPE zmm_ft_notificat,
        ls_rc2tx    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_texte,
        ls_recet    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_deep_recette,
        ls_retrn    TYPE bapiret2,
        ls_image    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_image,
        ls_imfil    TYPE /iwbep/s_cod_select_option,
        ls_ftalt    TYPE zmm_ft_alt,
        ls_ftal2    TYPE zmm_ft_alt,
        ls_ftfil    TYPE zmm_ft_fil,
        ls_ftdef    TYPE zmm_ft_def,
        ls_srcfl    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_srcfile,
        ls_srfil    TYPE /iwbep/s_cod_select_option,
        ls_srdef    TYPE zmm_sr_def,
        lt_arcob    TYPE zao_t_toauri,
        lt_ftfil    TYPE TABLE OF zmm_ft_fil,
        lt_ensgn    TYPE zft_t_alert_ensgn,
        lt_imfil    TYPE /iwbep/t_cod_select_options,
        lt_retrn    TYPE bapiret2_t,
        lt_srcfl    TYPE /iwbep/t_cod_select_options,
        lv_descr    TYPE zft_gw_descr,
        lv_matnr    TYPE matnr,
        lv_dummy    TYPE string VALUE 'dummy',
        lv_paths    TYPE localfile,
        lv_itype    TYPE zft_gw_objtp,
        ls_alert    TYPE zmm_fr=>ts_alert,
        lt_alert    TYPE zmm_fr=>tt_alert,
        lt_evtid    TYPE zmm_fr=>tt_evtid,
        lt_ftalt    TYPE TABLE OF zmm_ft_alt,
        lt_ftal2    TYPE TABLE OF zmm_ft_alt.

  FIELD-SYMBOLS:  <files> TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_srcfile,
                  <image> TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_image,
                  <ingre> TYPE zft_s_gw_cat_recette_ing,
                  <versn> TYPE zft_s_gw_cat_recette_version.


  ls_recet                        = is_recet.

  me->check_before_save( CHANGING cs_recet = ls_recet ).

  CHECK me->gt_error IS INITIAL.

  IF me->lv_newfr EQ 'X'.
    me->save_numbr( ).
  ENDIF.

  ls_recet-erdat                  = ls_recet-erda2.
  ls_recet-aedat                  = ls_recet-aeda2.

  MOVE-CORRESPONDING  ls_recet-rc2in  TO me->gt_ingre.
  MOVE-CORRESPONDING  ls_recet-rc2vr  TO me->gt_versn.
  MOVE-CORRESPONDING  ls_recet-rc2im  TO me->gt_image.
  MOVE-CORRESPONDING  ls_recet-rc2sf  TO me->gt_files.
  MOVE-CORRESPONDING  ls_recet-rc2en  TO me->gt_ensgn.
  MOVE-CORRESPONDING  ls_recet-rc2tp  TO me->gt_micrs.
  MOVE-CORRESPONDING  ls_recet-rc2tx  TO me->gt_texte.
  MOVE-CORRESPONDING  ls_recet-rc2vl  TO me->gt_volum.
  MOVE-CORRESPONDING  ls_recet        TO me->gs_recet.
  MOVE-CORRESPONDING  ls_recet        TO me->gs_frdat.
  me->dispatch_text( ls_recet-rc2tx ).

  me->gs_frdat-matnr              = ls_recet-frnum.

  LOOP AT me->gt_ingre ASSIGNING <ingre>.
    <ingre>-frnum                 = ls_recet-frnum.
  ENDLOOP.

  LOOP AT me->gt_versn ASSIGNING <versn>.
     IF <versn>-frnum IS NOT INITIAL AND <versn>-frnum NE ls_recet-frnum .
      me->lv_refer                = <versn>-frnum.
    ENDIF.
    <versn>-frnum                 = ls_recet-frnum.
  ENDLOOP.

  IF me->lv_isfic EQ 'X'.
    lv_itype                      = 'S'.
    rv_reslt                      = me->save_sr( CHANGING cs_recet = ls_recet ) .
  ELSE.
    lv_itype                      = 'F'.
    rv_reslt                      = me->save_ft( CHANGING cs_recet = ls_recet ) .
  ENDIF.

* Check if duplication with images and files
  IF rv_reslt EQ 'X'.

    LOOP AT me->gt_image ASSIGNING <image>.

      IF <image>-frnum NE me->gv_frnum.
        lv_imcop                  = 'X'.
        lv_srref                  = <image>-frnum.
        <image>-frnum             = me->gv_frnum.
      ENDIF.

    ENDLOOP.

    LOOP AT me->gt_files ASSIGNING <files>.

      IF <files>-objnr NE me->gv_frnum.
        lv_imcop                  = 'X'.
        lv_srref                  = <files>-objnr.
        <files>-objnr             = me->gv_frnum.
      ENDIF.

    ENDLOOP.

    IF lv_imcop IS NOT INITIAL.

      CALL FUNCTION 'ZMM_COPY_IMAGES_FILES'
        EXPORTING
          iv_srnew                = me->gv_frnum
          iv_srref                = lv_srref.

    ENDIF.

  ENDIF.

  IF rv_reslt EQ 'X'.
    me->handle_carte( ).
    IF me->lv_refer IS NOT INITIAL AND me->lv_refer+0(2) EQ 'SR' AND me->lv_isfic NE 'X'.
      me->update_carte_itm( ).
    ENDIF.
    me->version_for_carte( me->gv_frnum ).  " M-a-J des cartes en fonction des changement de versions actives #ID37 SML

*   Handle Image File save
    LOOP AT me->gt_image INTO ls_image.
*      READ TABLE me->gt_image TRANSPORTING NO FIELDS WITH KEY arcid = ls_image-arcid.
*      IF sy-subrc NE 0.
        ls_imfil-sign             = 'I'.
        ls_imfil-option           = 'EQ'.
        ls_imfil-low              = ls_image-arcid.
        APPEND ls_imfil TO lt_imfil.
*      ENDIF.
    ENDLOOP.

    lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_article.
    lv_objid                      = ls_recet-frnum.

    CALL FUNCTION 'ZAO_DOCUMENT_GET'
      EXPORTING
        iv_objct                  = lv_objct
        iv_objid                  = lv_objid
      IMPORTING
        et_arcob                  = lt_arcob
      EXCEPTIONS
        OTHERS                    = 0.

    IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
      IF lt_imfil[] IS NOT INITIAL.
        DELETE lt_arcob WHERE arc_doc_id IN lt_imfil.
      ENDIF.
      DELETE lt_arcob WHERE NOT mimetype CS 'IMAGE'.

      LOOP AT lt_arcob INTO ls_arcob.
        CALL FUNCTION 'ZAO_DOCUMENT_DELETE'
          EXPORTING
            iv_objct              = lv_objct
            iv_objid              = lv_objid
            iv_arcid              = ls_arcob-arc_doc_id
          IMPORTING
            et_retrn              = lt_retrn
          EXCEPTIONS
            OTHERS                = 1.

        IF sy-subrc NE 0.
          CLEAR ls_retrn.
          ls_retrn-type           = 'E'.
          ls_retrn-id             = 'ZMM'.
          ls_retrn-number         = '217'. "Une ou plusieurs pieces jointes n'ont pu etre supprimees de la recette &1.
          ls_retrn-message_v1     = lv_objid.
          APPEND ls_retrn TO me->gt_error.
        ELSE.
          IF lt_retrn[] IS NOT INITIAL.
            LOOP AT lt_retrn INTO ls_retrn.
              APPEND ls_retrn TO me->gt_error.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

      READ TABLE me->gt_image INTO ls_image WITH KEY fmain = abap_true.
      IF sy-subrc EQ 0.
*        Save main
        IF ls_recet-frnum CS 'SR'.
          SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF ls_srdef
          FROM zmm_sr_def
          WHERE srnum EQ ls_recet-frnum.

          IF sy-subrc EQ 0.
            ls_srdef-arcid        = ls_image-arcid.
            MODIFY zmm_sr_def FROM ls_srdef.
          ENDIF.
        ELSE.
          SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF ls_ftdef
          FROM zmm_ft_def
          WHERE ftnum EQ ls_recet-frnum.

          IF sy-subrc EQ 0.
            ls_ftdef-arcid        = ls_image-arcid.
            MODIFY zmm_ft_def FROM ls_ftdef.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*   Handle PJ File save
    CLEAR lt_arcob.
    LOOP AT is_recet-rc2sf INTO ls_srcfl.
      ls_srfil-sign               = 'I'.
      ls_srfil-option             = 'EQ'.
      ls_srfil-low                = ls_srcfl-arcid.
      APPEND ls_srfil TO lt_srcfl.
    ENDLOOP.

    lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_article.
    lv_objid                      = ls_recet-frnum.

    CALL FUNCTION 'ZAO_DOCUMENT_GET'
      EXPORTING
        iv_objct                  = lv_objct
        iv_objid                  = lv_objid
      IMPORTING
        et_arcob                  = lt_arcob
      EXCEPTIONS
        OTHERS                    = 0.

    IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
      IF lt_srcfl[] IS NOT INITIAL.
        DELETE lt_arcob WHERE arc_doc_id IN lt_srcfl.
      ENDIF.
      DELETE lt_arcob WHERE mimetype CS 'IMAGE'.

      LOOP AT lt_arcob INTO ls_arcob.
        CALL FUNCTION 'ZAO_DOCUMENT_DELETE'
          EXPORTING
            iv_objct              = lv_objct
            iv_objid              = lv_objid
            iv_arcid              = ls_arcob-arc_doc_id
         IMPORTING
           et_retrn               = lt_retrn
         EXCEPTIONS
           OTHERS                 = 1.

        IF sy-subrc NE 0.
          CLEAR ls_retrn.
          ls_retrn-type           = 'E'.
          ls_retrn-id             = 'ZMM'.
          ls_retrn-number         = '217'. "Une ou plusieurs pieces jointes n'ont pu etre supprimees de la recette &1.
          ls_retrn-message_v1     = lv_objid.
          APPEND ls_retrn TO me->gt_error.
        ELSE.
          IF lt_retrn[] IS NOT INITIAL.
            LOOP AT lt_retrn INTO ls_retrn.
              APPEND ls_retrn TO me->gt_error.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.

    me->get_alert( IMPORTING et_alert = lt_alert ).
    LOOP AT lt_alert INTO ls_alert.

      LOOP AT me->lt_ensgn INTO ls_ensgn WHERE activ EQ 'X' .
        APPEND ls_ensgn-ensgn TO lt_ensgn.
      ENDLOOP.

      lv_descr                    = me->gs_recet-titre.
      IF ls_alert-matnr IS INITIAL.
        lv_matnr                    = me->gv_frnum.
      ELSE.
        lv_matnr                    = ls_alert-matnr."me->gv_frnum.
      ENDIF.

      CALL FUNCTION 'ZMM_FT_ALERT_MNGMT'
        EXPORTING
          iv_evtid                = ls_alert-evtid
          iv_descr                = lv_descr
          iv_matnr                = lv_matnr
          iv_frver                = ls_alert-versn
          iv_vdesc                = ls_alert-vdesc
       TABLES
          ensgn_tab               = lt_ensgn
       EXCEPTIONS
          param_missing           = 1
          send_mail_error         = 2
          mail_content            = 3
          unknown_event           = 4
          unknown_receiver        = 5
          unknown_url             = 6
          OTHERS                  = 7.
      IF sy-subrc <> 0.
        ls_retrn-type             = 'E'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '109'.
        ls_retrn-message_v1       = lv_evtid.
        ls_retrn-message_v2       = me->gv_frnum.
        APPEND ls_retrn TO me->gt_error.
      ENDIF.
    ENDLOOP.

*   Handle notifications
    SORT lt_alert BY evtid.
    DELETE ADJACENT DUPLICATES FROM lt_alert COMPARING evtid.

    LOOP AT lt_alert INTO ls_alert.

      SELECT  *
      INTO    CORRESPONDING FIELDS OF TABLE lt_ftalt
      FROM    zmm_ft_alt
      WHERE   evtid EQ ls_alert-evtid
      AND     notif EQ 'X'.

      SORT lt_ftalt BY email evtid.
      DELETE ADJACENT DUPLICATES FROM lt_ftalt COMPARING email evtid.

      APPEND LINES OF lt_ftalt TO lt_ftal2.
      DELETE ADJACENT DUPLICATES FROM lt_ftal2 COMPARING email.

      LOOP AT lt_ftal2 INTO ls_ftal2.
        CLEAR lv_compt.

        LOOP AT lt_ftalt INTO ls_ftalt WHERE email EQ ls_ftal2-email.

          lv_compt                = lv_compt + 1.

        ENDLOOP.

        SELECT  SINGLE *
        INTO    CORRESPONDING FIELDS OF ls_notif
        FROM    zmm_ft_notificat
        WHERE   email EQ ls_ftal2-email.

        ls_notif-notif            = ls_notif-notif + lv_compt.
        ls_notif-email            = ls_ftal2-email.
        MODIFY zmm_ft_notificat FROM ls_notif.

      ENDLOOP.

    ENDLOOP.

  ENDIF.

ENDMETHOD.