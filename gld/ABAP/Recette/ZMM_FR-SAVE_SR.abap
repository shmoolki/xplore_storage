METHOD save_sr.
  TYPES : BEGIN OF ty_field,
            tabname   TYPE tabname,
            fieldname TYPE fieldname,
            scrtext_l TYPE scrtext_l,
          END OF ty_field.

  DATA: lv_chgnr    TYPE i,
        lv_chgn2    TYPE cdchangenr,
        lv_iobjc    TYPE inri-object VALUE 'ZMM_CHGNR',
        lv_matnr    TYPE matnr,
        lv_newvl    TYPE string,
        lv_oldvl    TYPE string,
        lv_range    TYPE inri-nrrangenr VALUE '01',
        lv_reslt    TYPE xfeld,
        lv_txlin    TYPE tdline,
        ls_alert    TYPE ts_alert,
        ls_versn    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_version,
        ls_ensgn    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_enseigne,
        ls_field    TYPE ty_field,
        ls_histo    TYPE zmm_history,
        ls_ingre    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_ingredient,
        ls_retrn    TYPE bapiret2,
        ls_srdf2    TYPE zmm_sr_def,
        ls_srens    TYPE zmm_sr_ens,
        ls_srng2    TYPE zmm_sr_ing,
        ls_texte    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_texte,
        ls_oldtx    TYPE zcl_zft_gw_cat_recette_mpc_ext=>ts_texte,
        ls_srdef    TYPE zmm_sr_def,
        ls_srver    TYPE zmm_sr_ver,
        ls_srve2    TYPE zmm_sr_ver,
        ls_sring    TYPE zmm_sr_ing,
        ls_ttext    TYPE tline,
        ls_thead    TYPE thead,
        lt_field    TYPE TABLE OF ty_field,
        lt_histo    TYPE TABLE OF zmm_history,
        lt_srens    TYPE TABLE OF zmm_sr_ens,
        lt_sring    TYPE TABLE OF zmm_sr_ing,
        lt_srver    TYPE TABLE OF zmm_sr_ver,
        lt_txmat    TYPE re_t_textline,
        lt_txmod    TYPE re_t_textline,
        lt_txpre    TYPE re_t_textline,
        lt_txptc    TYPE re_t_textline,
        lt_olmat    TYPE re_t_textline,
        lt_olmod    TYPE re_t_textline,
        lt_olpre    TYPE re_t_textline,
        lt_olptc    TYPE re_t_textline,
        lt_ttext    TYPE tline_t.


  MOVE-CORRESPONDING me->gs_recet TO ls_srdef.

* Initial status & Created by / Changed by
  IF me->lv_newfr EQ 'X'.
    ls_srdef-erdat    = sy-datum.
    ls_srdef-ernam    = sy-uname.
    IF me->gs_recet-stats IS INITIAL OR me->gs_recet-stats EQ '00'.
      ls_srdef-stats  = '10'.
    ENDIF.
    ls_srdef-meins    = 'PC'.
  ELSE.
    ls_srdef-aedat    = sy-datum.
    ls_srdef-aenam    = sy-uname.
  ENDIF.

  IF me->gt_ingre IS INITIAL.
    me->ls_recet-stats            = '10'.
    ls_srdef-stats                = '10'.
  ENDIF.

  ls_srdef-titrg                  = ls_srdef-titre.
  TRANSLATE ls_srdef-titrg TO UPPER CASE.
  ls_srdef-srnum                  = me->gv_frnum.

* Save history *****************************************************
  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_SR_DEF'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-appnm                  = 'R'.
  ls_histo-tbnam                  = 'ZMM_SR_DEF'.
  ls_histo-descr                  = ls_srdef-titre.
  ls_histo-prnum                  = ls_srdef-srnum.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

  SELECT  SINGLE *
  INTO    CORRESPONDING FIELDS OF ls_srdf2
  FROM    zmm_sr_def
  WHERE   srnum EQ ls_srdef-srnum.

  IF sy-subrc NE 0.

    me->get_next( EXPORTING iv_range  = lv_range
                            iv_objct  = lv_iobjc
                  IMPORTING ev_numbr  = lv_chgnr ).

    IF lv_chgnr IS NOT INITIAL.

      MOVE lv_chgnr TO lv_chgn2.
      ls_histo-chgnr              = lv_chgn2.

    ENDIF.

    ls_histo-chngt                = 'I'.
    ls_histo-fname                = 'SRNUM'.
    ls_histo-newvl                = ls_srdef-srnum.
    CLEAR ls_histo-oldvl.

    READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
    IF sy-subrc EQ 0.
      ls_histo-ftext              = ls_field-scrtext_l.
      APPEND ls_histo TO lt_histo.
    ENDIF.

  ELSE.

    ls_histo-chngt                = 'U'.

    IF ls_srdf2-stats NE ls_srdef-stats.
      ls_histo-fname              = 'STATS'.
      ls_histo-oldvl              = ls_srdf2-stats.
      ls_histo-newvl              = ls_srdef-stats.

      CASE ls_histo-newvl.
        WHEN '15'.
          ls_histo-evtid          = 'RC03'.
        WHEN '20'.
          ls_histo-evtid          = 'RC04'.
        WHEN '16'.
          ls_histo-evtid          = 'RC13'.
        WHEN '25'.
          ls_histo-evtid          = 'RC14'.
        WHEN '35'.
          ls_histo-evtid          = 'RC15'.
      ENDCASE.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-imur1 NE ls_srdef-imur1.
      ls_histo-fname              = 'IMUR1'.
      ls_histo-oldvl              = ls_srdf2-imur1.
      ls_histo-newvl              = ls_srdef-imur1.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-imur2 NE ls_srdef-imur2.
      ls_histo-fname              = 'IMUR2'.
      ls_histo-oldvl              = ls_srdf2-imur2.
      ls_histo-newvl              = ls_srdef-imur2.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-imur3 NE ls_srdef-imur3.
      ls_histo-fname              = 'IMUR3'.
      ls_histo-oldvl              = ls_srdf2-imur3.
      ls_histo-newvl              = ls_srdef-imur3.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-titre NE ls_srdef-titre.
      ls_histo-fname              = 'TITRE'.
      ls_histo-oldvl              = ls_srdf2-titre.
      ls_histo-newvl              = ls_srdef-titre.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-cnsrv NE ls_srdef-cnsrv.
      ls_histo-fname              = 'CNSRV'.
      ls_histo-oldvl              = ls_srdf2-cnsrv.
      ls_histo-newvl              = ls_srdef-cnsrv.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-prixi NE ls_srdef-prixi.
      ls_histo-fname              = 'PRIXI'.

      MOVE ls_srdf2-prixi TO lv_oldvl.
      MOVE ls_srdef-prixi TO lv_newvl.

      ls_histo-oldvl              = lv_oldvl.
      ls_histo-newvl              = lv_newvl.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-dlcsc NE ls_srdef-dlcsc.
      ls_histo-fname              = 'DLCSC'.
      ls_histo-oldvl              = ls_srdf2-dlcsc.
      ls_histo-newvl              = ls_srdef-dlcsc.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-brgew NE ls_srdef-brgew.
      ls_histo-fname              = 'BRGEW'.

      MOVE ls_srdf2-brgew TO lv_oldvl.
      MOVE ls_srdef-brgew TO lv_newvl.

      ls_histo-oldvl              = lv_oldvl.
      ls_histo-newvl              = lv_newvl.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-ctrlr NE ls_srdef-ctrlr.
      ls_histo-fname              = 'CTRLR'.
      ls_histo-oldvl              = ls_srdf2-ctrlr.
      ls_histo-newvl              = ls_srdef-ctrlr.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-ctrdt NE ls_srdef-ctrdt.
      ls_histo-fname              = 'CTRDT'.
      ls_histo-oldvl              = ls_srdf2-ctrdt.
      ls_histo-newvl              = ls_srdef-ctrdt.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-famil NE ls_srdef-famil.
      ls_histo-fname              = 'FAMIL'.
      ls_histo-oldvl              = ls_srdf2-famil.
      ls_histo-newvl              = ls_srdef-famil.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

    IF ls_srdf2-arcid NE ls_srdef-arcid.
      ls_histo-fname              = 'ARCID'.
      ls_histo-oldvl              = ls_srdf2-arcid.
      ls_histo-newvl              = ls_srdef-arcid.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
      ENDIF.
    ENDIF.

  ENDIF.

  MODIFY zmm_sr_def FROM ls_srdef.
  IF sy-subrc EQ 0.
    INSERT zmm_history FROM TABLE lt_histo.
  ENDIF.

  CLEAR:  lt_field,
          lt_histo.

  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_SR_VER'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-tbnam                  = 'ZMM_SR_DEF'.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

* zmm_sr_ver --> remove versions from database
  LOOP AT me->lt_versn INTO ls_versn.
    READ TABLE me->gt_versn TRANSPORTING NO FIELDS WITH KEY ftver = ls_versn-ftver.
     IF sy-subrc NE 0.
      DELETE FROM zmm_sr_ver WHERE srnum EQ ls_versn-frnum AND srver EQ ls_versn-ftver.

*     Save History ******************************************************************
      IF sy-subrc EQ 0.

        CLEAR:  lv_chgnr,
                lv_chgn2,
                lt_histo.

        ls_histo-appnm            = 'R'.
        CONCATENATE 'Version' ls_versn-ftver 'de recette' ls_versn-frnum INTO ls_histo-descr SEPARATED BY ' '.
        CONCATENATE ls_versn-frnum '-' ls_versn-ftver INTO ls_histo-prnum.

        ls_histo-chngt            = 'D'.
        ls_histo-fname            = 'SRVER'.
        ls_histo-oldvl            = ls_versn-ftver.
        CLEAR ls_histo-newvl.

        READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
        IF sy-subrc EQ 0.

          ls_histo-ftext          = ls_field-scrtext_l.

          me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

          MOVE lv_chgnr TO lv_chgn2.
          ls_histo-chgnr          = lv_chgn2.

          APPEND ls_histo TO lt_histo.
          INSERT zmm_history FROM TABLE lt_histo.

        ENDIF.

      ENDIF.

*   End Save History *****************************************

    ENDIF.

  ENDLOOP.

  CLEAR lt_histo.

* Add new versions
  LOOP AT me->gt_versn INTO ls_versn.
    MOVE-CORRESPONDING ls_versn TO ls_srver.
    ls_srver-srnum                = me->gv_frnum.
    ls_srver-srver                = ls_versn-ftver.
    APPEND ls_srver TO lt_srver.

*   Save History **************************************************
    IF ls_versn-frnum NE '$'.

      CLEAR:  lv_chgnr,
              lv_chgn2.

      ls_histo-appnm                = 'R'.
      CONCATENATE 'Version' ls_versn-ftver 'de recette' ls_versn-frnum INTO ls_histo-descr SEPARATED BY ' '.
      CONCATENATE ls_versn-frnum '-' ls_versn-ftver INTO ls_histo-prnum.

      SELECT  SINGLE *
      INTO    CORRESPONDING FIELDS OF ls_srve2
      FROM    zmm_sr_ver
      WHERE   srnum EQ ls_srver-srnum
      AND     srver EQ ls_srver-srver.

      IF sy-subrc NE 0.

        ls_histo-chngt              = 'I'.
        ls_histo-fname              = 'SRVER'.
        ls_histo-newvl              = ls_versn-ftver.
        CLEAR ls_histo-oldvl.

        READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
        IF sy-subrc EQ 0.

          ls_histo-ftext            = ls_field-scrtext_l.

          me->get_next( EXPORTING iv_range  = lv_range
                                  iv_objct  = lv_iobjc
                        IMPORTING ev_numbr  = lv_chgnr ).

          MOVE lv_chgnr TO lv_chgn2.
          ls_histo-chgnr            = lv_chgn2.

          APPEND ls_histo TO lt_histo.

        ENDIF.

      ELSE.

        ls_histo-chngt              = 'U'.

        IF ls_srve2-apdeb NE ls_srver-apdeb.
          ls_histo-fname            = 'APDEB'.
          ls_histo-oldvl            = ls_srve2-apdeb.
          ls_histo-newvl            = ls_srver-apdeb.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srve2-apfin NE ls_srver-apfin.
          ls_histo-fname            = 'APFIN'.
          ls_histo-oldvl            = ls_srve2-apfin.
          ls_histo-newvl            = ls_srver-apfin.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srve2-tmppr NE ls_srver-tmppr.
          ls_histo-fname            = 'TMPPR'.
          ls_histo-oldvl            = ls_srve2-tmppr.
          ls_histo-newvl            = ls_srver-tmppr.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srve2-nbgst NE ls_srver-nbgst.
          ls_histo-fname            = 'NBGST'.

          MOVE ls_srve2-nbgst TO lv_oldvl.
          MOVE ls_srver-nbgst TO lv_newvl.

          ls_histo-oldvl              = lv_oldvl.
          ls_histo-newvl              = lv_newvl.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srve2-descr NE ls_srver-descr.
          ls_histo-fname            = 'DESCR'.
          ls_histo-oldvl            = ls_srve2-descr.
          ls_histo-newvl            = ls_srver-descr.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srve2-srtft NE ls_srver-srtft.
          ls_histo-fname            = 'SRTFT'.
          ls_histo-oldvl            = ls_srve2-srtft.
          ls_histo-newvl            = ls_srver-srtft.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srve2-ntgew NE ls_srver-ntgew.
          ls_histo-fname            = 'NTGEW'.
          ls_histo-oldvl            = ls_srve2-ntgew.
          ls_histo-newvl            = ls_srver-ntgew.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext          = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr          = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

*   End Save History ****************************************

  ENDLOOP.

  MODIFY zmm_sr_ver FROM TABLE lt_srver.
  IF sy-subrc EQ 0.
    INSERT zmm_history FROM TABLE lt_histo.
  ENDIF.

* zmm_sr_ens creation
  LOOP AT me->lt_ensgn INTO ls_ensgn WHERE activ EQ 'X'.
    READ TABLE me->gt_ensgn TRANSPORTING NO FIELDS WITH KEY ensgn = ls_ensgn-ensgn activ = 'X'.
     IF sy-subrc NE 0.
      DELETE FROM zmm_sr_ens WHERE srnum EQ me->gv_frnum AND ensgn EQ ls_ensgn-ensgn.
    ENDIF.
  ENDLOOP.

  LOOP AT me->gt_ensgn INTO ls_ensgn WHERE activ EQ 'X'.
    MOVE-CORRESPONDING ls_ensgn TO ls_srens.
    ls_srens-srnum                = me->gv_frnum.
*    ls_srens-ensgn                = ls_ensgn-ensgn.
    APPEND ls_srens TO lt_srens.
  ENDLOOP.
  MODIFY zmm_sr_ens FROM TABLE lt_srens.

  CLEAR:  lt_field,
          lt_histo.

  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_SR_ING'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-appnm                  = 'R'.
  ls_histo-tbnam                  = 'ZMM_SR_ING'.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

* zmm_sr_ing --> remove ingredients from versions
  LOOP AT me->lt_ingre INTO ls_ingre.
    READ TABLE me->gt_ingre TRANSPORTING NO FIELDS WITH KEY ftver = ls_ingre-ftver matnr = ls_ingre-matnr.
     IF sy-subrc NE 0.
      DELETE FROM zmm_sr_ing WHERE srnum EQ me->gv_frnum AND srver EQ ls_ingre-ftver AND sring EQ ls_ingre-matnr.

*     Save History ******************************************************************
      IF sy-subrc EQ 0.
***Mantis 1617**************************************************************
        ls_alert-matnr            = ls_ingre-matac.
***Mantis 1617**************************************************************
        ls_alert-evtid            = 'MP11'. "Alerte : Modification volume article
        APPEND ls_alert TO me->gt_alert.

        CLEAR:  lv_chgnr,
                lv_chgn2,
                lt_histo.

        lv_matnr                  = ls_ingre-matnr.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input                 = ls_ingre-matnr
          IMPORTING
            output                = lv_matnr.

        ls_histo-appnm            = 'R'.
*        CONCATENATE ls_versn-frnum '-' ls_versn-ftver '-' ls_ingre-matnr INTO ls_histo-prnum.
        CONCATENATE ls_ingre-frnum '-' ls_ingre-ftver '-' lv_matnr INTO ls_histo-prnum.
        ls_histo-descr            = ls_histo-prnum.

        ls_histo-chngt            = 'D'.
        ls_histo-fname            = 'SRING'.
        ls_histo-oldvl            = lv_matnr.
        CLEAR ls_histo-newvl.
        ls_histo-evtid            = 'MP11'.

        READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
        IF sy-subrc EQ 0.

          ls_histo-ftext          = ls_field-scrtext_l.

          me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

          MOVE lv_chgnr TO lv_chgn2.
          ls_histo-chgnr          = lv_chgn2.

          APPEND ls_histo TO lt_histo.
          INSERT zmm_history FROM TABLE lt_histo.

        ENDIF.

      ENDIF.

*   End Save History *****************************************

    ENDIF.
  ENDLOOP.

  CLEAR lt_histo.

  LOOP AT me->gt_ingre INTO ls_ingre.
    MOVE-CORRESPONDING ls_ingre TO ls_sring.
    ls_sring-srnum                = me->gv_frnum.
    ls_sring-srver                = ls_ingre-ftver.
    ls_sring-sring                = ls_ingre-matnr.
    APPEND ls_sring TO lt_sring.

*   Save History **************************************************
*    IF ls_versn-frnum NE '$'.

      CLEAR:  lv_chgnr,
              lv_chgn2.

      lv_matnr                    = ls_sring-sring.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input                   = ls_sring-sring
        IMPORTING
          output                  = lv_matnr.

      ls_histo-appnm              = 'R'.
      CONCATENATE ls_sring-srnum '-' ls_sring-srver '-' lv_matnr INTO ls_histo-prnum.
      ls_histo-descr            = ls_histo-prnum.

      SELECT  SINGLE *
      INTO    CORRESPONDING FIELDS OF ls_srng2
      FROM    zmm_sr_ing
      WHERE   srnum EQ ls_sring-srnum
      AND     srver EQ ls_sring-srver
      AND     sring EQ ls_sring-sring.

      IF sy-subrc NE 0.

        ls_histo-chngt            = 'I'.
        ls_histo-fname            = 'SRING'.
        ls_histo-newvl            = lv_matnr.
        CLEAR ls_histo-oldvl.

        READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
        IF sy-subrc EQ 0.

          ls_histo-ftext          = ls_field-scrtext_l.

          me->get_next( EXPORTING iv_range  = lv_range
                                  iv_objct  = lv_iobjc
                        IMPORTING ev_numbr  = lv_chgnr ).

          MOVE lv_chgnr TO lv_chgn2.
          ls_histo-chgnr          = lv_chgn2.

          APPEND ls_histo TO lt_histo.

        ENDIF.

      ELSE.

        ls_histo-chngt            = 'U'.

        IF ls_srng2-matac NE ls_sring-matac.
          ls_histo-fname          = 'MATAC'.
          ls_histo-oldvl          = ls_srng2-matac.
          ls_histo-newvl          = ls_sring-matac.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext        = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr        = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srng2-qtite NE ls_sring-qtite.
***Mantis 1617**************************************************************
          ls_alert-matnr              = ls_sring-matac.
***Mantis 1617**************************************************************
          ls_alert-evtid              = 'MP11'. "ALerte : Modification volume article
          ls_alert-vdesc              = ls_sring-srnum.
          APPEND ls_alert TO me->gt_alert.

          ls_histo-fname          = 'QTITE'.

          MOVE ls_srng2-qtite TO lv_oldvl.
          MOVE ls_sring-qtite TO lv_newvl.

          ls_histo-oldvl              = lv_oldvl.
          ls_histo-newvl              = lv_newvl.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext        = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr        = lv_chgn2.
            ls_histo-evtid        = 'MP11'.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srng2-perte NE ls_sring-perte.
          ls_histo-fname          = 'PERTE'.

          MOVE ls_srng2-perte TO lv_oldvl.
          MOVE ls_sring-perte TO lv_newvl.

          ls_histo-oldvl              = lv_oldvl.
          ls_histo-newvl              = lv_newvl.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext        = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr        = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

        IF ls_srng2-exlot NE ls_sring-exlot.
          ls_histo-fname          = 'EXLOT'.
          ls_histo-oldvl          = ls_srng2-exlot.
          ls_histo-newvl          = ls_sring-exlot.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.
            ls_histo-ftext        = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr        = lv_chgn2.

            APPEND ls_histo TO lt_histo.
          ENDIF.
        ENDIF.

      ENDIF.
*    ENDIF.

  ENDLOOP.

  MODIFY zmm_sr_ing FROM TABLE lt_sring.
  IF sy-subrc EQ 0.
    INSERT zmm_history FROM TABLE lt_histo.
  ENDIF.

  READ TABLE me->gt_texte INTO ls_texte INDEX 1.
  IF sy-subrc EQ 0.
    SPLIT ls_texte-materl AT cl_abap_char_utilities=>newline  INTO TABLE lt_txmat.
    SPLIT ls_texte-modop  AT cl_abap_char_utilities=>newline  INTO TABLE lt_txmod.
    SPLIT ls_texte-prepar AT cl_abap_char_utilities=>newline  INTO TABLE lt_txpre.
    SPLIT ls_texte-ptcrq  AT cl_abap_char_utilities=>newline  INTO TABLE lt_txptc.
  ENDIF.
  READ TABLE me->lt_texte INTO ls_oldtx INDEX 1.
  IF sy-subrc EQ 0.
    SPLIT ls_oldtx-materl AT cl_abap_char_utilities=>newline  INTO TABLE lt_olmat.
    SPLIT ls_oldtx-modop  AT cl_abap_char_utilities=>newline  INTO TABLE lt_olmod.
    SPLIT ls_oldtx-prepar AT cl_abap_char_utilities=>newline  INTO TABLE lt_olpre.
    SPLIT ls_oldtx-ptcrq  AT cl_abap_char_utilities=>newline  INTO TABLE lt_olptc.
  ENDIF.
* Material Texte
  IF lt_olmat[] NE lt_txmat[].
    CLEAR lt_ttext[].
    LOOP AT lt_txmat INTO lv_txlin.
      CLEAR ls_ttext.

*      CALL FUNCTION 'G_SPLIT_LINE'
*        EXPORTING
*          input_line              = input_line
*        IMPORTING
*          split_not_successful    = split_not_successful
*        TABLES
*          export_lines            = export_lines.



      ls_ttext-tdline = lv_txlin.
      APPEND ls_ttext TO lt_ttext.
    ENDLOOP.


    ls_thead-tdid     = 'ZMAT'.
    ls_thead-tdspras  = 'F'.
    ls_thead-tdname   = me->gv_frnum.
    ls_thead-tdobject = 'MATERIAL'.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header                = ls_thead
      TABLES
        lines                 = lt_ttext
      EXCEPTIONS
        OTHERS                = 1.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'COMMIT_TEXT'.
    ENDIF.
  ENDIF.

* Mode operatoire Texte
  IF lt_olmod[] NE lt_txmod[].
    CLEAR lt_ttext[].
    LOOP AT lt_txmod INTO lv_txlin.
      CLEAR ls_ttext.
      ls_ttext-tdline = lv_txlin.
      APPEND ls_ttext TO lt_ttext.
    ENDLOOP.

    ls_thead-tdid     = 'ZMOD'.
    ls_thead-tdspras  = 'F'.
    ls_thead-tdname   = me->gv_frnum.
    ls_thead-tdobject = 'MATERIAL'.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header                = ls_thead
      TABLES
        lines                 = lt_ttext
      EXCEPTIONS
        OTHERS                = 1.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'COMMIT_TEXT'.
    ENDIF.
  ENDIF.


* Preparation Texte
  IF lt_olpre[] NE lt_txpre[].
    CLEAR lt_ttext[].
    LOOP AT lt_txpre INTO lv_txlin.
      CLEAR ls_ttext.
      ls_ttext-tdline = lv_txlin.
      APPEND ls_ttext TO lt_ttext.
    ENDLOOP.

    ls_thead-tdid     = 'ZPRE'.
    ls_thead-tdspras  = 'F'.
    ls_thead-tdname   = me->gv_frnum.
    ls_thead-tdobject = 'MATERIAL'.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header                = ls_thead
      TABLES
        lines                 = lt_ttext
      EXCEPTIONS
        OTHERS                = 1.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'COMMIT_TEXT'.
    ENDIF.
  ENDIF.

* Point critique Texte
  IF lt_olptc[] NE lt_txptc[].
    CLEAR lt_ttext[].
    LOOP AT lt_txptc INTO lv_txlin.
      CLEAR ls_ttext.
      ls_ttext-tdline = lv_txlin.
      APPEND ls_ttext TO lt_ttext.
    ENDLOOP.

    ls_thead-tdid     = 'ZPTC'.
    ls_thead-tdspras  = 'F'.
    ls_thead-tdname   = me->gv_frnum.
    ls_thead-tdobject = 'MATERIAL'.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header                = ls_thead
      TABLES
        lines                 = lt_ttext
      EXCEPTIONS
        OTHERS                = 1.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'COMMIT_TEXT'.
    ENDIF.
  ENDIF.

  rv_reslt                      = 'X'.

ENDMETHOD.