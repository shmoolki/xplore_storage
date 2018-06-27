METHOD save_gldtb.
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
        ls_alert    TYPE ts_alert,
        ls_ensgn    TYPE zft_s_gw_cat_recette_enseigne,
        ls_field    TYPE ty_field,
        ls_ftens    TYPE zmm_ft_ens,
        ls_ftdef    TYPE zmm_ft_def,
        ls_ftdf2    TYPE zmm_ft_def,
        ls_ingre    TYPE zft_s_gw_cat_recette_ing,
        ls_fting    TYPE zmm_ft_ing,
        ls_ftng2    TYPE zmm_ft_ing,
        ls_ftver    TYPE zmm_ft_ver,
        ls_ftvr2    TYPE zmm_ft_ver,
        ls_histo    TYPE zmm_history,
        ls_srdef    TYPE zmm_sr_def,
        ls_versn    TYPE zft_s_gw_cat_recette_version,
        lt_field    TYPE TABLE OF ty_field,
        lt_fting    TYPE TABLE OF zmm_ft_ing,
        lt_ftver    TYPE TABLE OF zmm_ft_ver,
        lt_histo    TYPE TABLE OF zmm_history.



  CHECK me->gt_error[] IS INITIAL.

* Initial status & Created by / Changed by
  IF me->lv_newfr EQ 'X'.
    me->gs_frdat-erdat    = sy-datum.
    me->gs_frdat-ernam    = sy-uname.
    IF me->gs_frdat-stats IS INITIAL OR me->gs_frdat-stats EQ '00'.
****      me->gs_frdat-stats  = '00'.
      me->gs_frdat-stats  = '12'.
      ls_alert-evtid                = 'RC07'.
      ls_alert-matnr                = me->gv_frnum.
      APPEND ls_alert TO me->gt_alert.
    ENDIF.
  ELSE.
    me->gs_frdat-aedat    = sy-datum.
    me->gs_frdat-aenam    = sy-uname.
  ENDIF.

" FT Header data
  ls_ftdef-mandt          = sy-mandt.
  ls_ftdef-ftnum          = me->gv_frnum.
  ls_ftdef-stats          = me->gs_frdat-stats.
  ls_ftdef-imur1          = me->gs_frdat-imur1.
  ls_ftdef-imur2          = me->gs_frdat-imur2.
  ls_ftdef-imur3          = me->gs_frdat-imur3.
  ls_ftdef-brgew          = me->gs_frdat-brgew.
  ls_ftdef-ctrlr          = me->gs_frdat-ctrlr.
  ls_ftdef-ctrdt          = me->gs_frdat-ctrdt.
  ls_ftdef-titre          = me->gs_frdat-titre.
  ls_ftdef-cnsrv          = me->gs_frdat-cnsrv.
  ls_ftdef-prixi          = me->gs_frdat-prixi.
  ls_ftdef-dlcsc          = me->gs_frdat-dlcsc.
  ls_ftdef-erdat          = me->gs_frdat-erdat.
  ls_ftdef-ernam          = me->gs_frdat-ernam.
  ls_ftdef-aedat          = me->gs_frdat-aedat.
  ls_ftdef-aenam          = me->gs_frdat-aenam.
  IF ls_ftdef-stats EQ '22' AND ls_ftdef-stats NE me->gr_ftobj->gs_ftdat-stats.

  ENDIF.

* Save history *****************************************************
  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_FT_DEF'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-appnm                  = 'R'.
  ls_histo-tbnam                  = 'ZMM_FT_DEF'.
  ls_histo-descr                  = ls_ftdef-titre.
  ls_histo-prnum                  = ls_ftdef-ftnum.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

  SELECT  SINGLE *
  INTO    CORRESPONDING FIELDS OF ls_ftdf2
  FROM    zmm_ft_def
  WHERE   ftnum EQ ls_ftdef-ftnum.

  IF sy-subrc NE 0.

    me->get_next( EXPORTING iv_range  = lv_range
                            iv_objct  = lv_iobjc
                  IMPORTING ev_numbr  = lv_chgnr ).

    IF lv_chgnr IS NOT INITIAL.

      MOVE lv_chgnr TO lv_chgn2.
      ls_histo-chgnr              = lv_chgn2.

    ENDIF.

    ls_histo-chngt                = 'I'.
    ls_histo-fname                = 'FTNUM'.
    ls_histo-newvl                = ls_ftdef-ftnum.
    CLEAR ls_histo-oldvl.

    ls_histo-evtid                = 'RC07'.

    READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
    IF sy-subrc EQ 0.
      ls_histo-ftext              = ls_field-scrtext_l.
      APPEND ls_histo TO lt_histo.
    ENDIF.

  ELSE.

    ls_histo-chngt                = 'U'.

    IF ls_ftdf2-stats NE ls_ftdef-stats.
      ls_histo-fname              = 'STATS'.
      ls_histo-oldvl              = ls_ftdf2-stats.
      ls_histo-newvl              = ls_ftdef-stats.

      CASE ls_histo-newvl.
        WHEN '22'.
          ls_histo-evtid          = 'RC08'.
        WHEN '32'.
          ls_histo-evtid          = 'RC16'.
        WHEN '42'.
          ls_histo-evtid          = 'RC17'.
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

    IF ls_ftdf2-imur1 NE ls_ftdef-imur1.
      ls_histo-fname              = 'IMUR1'.
      ls_histo-oldvl              = ls_ftdf2-imur1.
      ls_histo-newvl              = ls_ftdef-imur1.

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

    IF ls_ftdf2-imur2 NE ls_ftdef-imur2.
      ls_histo-fname              = 'IMUR2'.
      ls_histo-oldvl              = ls_ftdf2-imur2.
      ls_histo-newvl              = ls_ftdef-imur2.

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

    IF ls_ftdf2-imur3 NE ls_ftdef-imur3.
      ls_histo-fname              = 'IMUR3'.
      ls_histo-oldvl              = ls_ftdf2-imur3.
      ls_histo-newvl              = ls_ftdef-imur3.

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

    IF ls_ftdf2-titre NE ls_ftdef-titre.
      ls_histo-fname              = 'TITRE'.
      ls_histo-oldvl              = ls_ftdf2-titre.
      ls_histo-newvl              = ls_ftdef-titre.

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

    IF ls_ftdf2-cnsrv NE ls_ftdef-cnsrv.
      ls_histo-fname              = 'CNSRV'.
      ls_histo-oldvl              = ls_ftdf2-cnsrv.
      ls_histo-newvl              = ls_ftdef-cnsrv.

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

    IF ls_ftdf2-prixi NE ls_ftdef-prixi.
      ls_histo-fname              = 'PRIXI'.

      MOVE ls_ftdf2-prixi TO lv_oldvl.
      MOVE ls_ftdef-prixi TO lv_newvl.

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

    IF ls_ftdf2-dlcsc NE ls_ftdef-dlcsc.
      ls_histo-fname              = 'DLCSC'.
      ls_histo-oldvl              = ls_ftdf2-dlcsc.
      ls_histo-newvl              = ls_ftdef-dlcsc.

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

    IF ls_ftdf2-brgew NE ls_ftdef-brgew.
      ls_histo-fname              = 'BRGEW'.

      MOVE ls_ftdf2-brgew TO lv_oldvl.
      MOVE ls_ftdef-brgew TO lv_newvl.

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

    IF ls_ftdf2-ctrlr NE ls_ftdef-ctrlr.
      ls_histo-fname              = 'CTRLR'.
      ls_histo-oldvl              = ls_ftdf2-ctrlr.
      ls_histo-newvl              = ls_ftdef-ctrlr.

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

    IF ls_ftdf2-ctrdt NE ls_ftdef-ctrdt.
      ls_histo-fname              = 'CTRDT'.
      ls_histo-oldvl              = ls_ftdf2-ctrdt.
      ls_histo-newvl              = ls_ftdef-ctrdt.

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

    IF ls_ftdf2-arcid NE ls_ftdef-arcid.
      ls_histo-fname              = 'ARCID'.
      ls_histo-oldvl              = ls_ftdf2-arcid.
      ls_histo-newvl              = ls_ftdef-arcid.

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

  MODIFY zmm_ft_def FROM ls_ftdef.
  IF sy-subrc EQ 0.
    INSERT zmm_history FROM TABLE lt_histo.
  ENDIF.

* Change SR status in case of duplication
  IF sy-subrc EQ 0 AND me->gs_recet-srdup IS NOT INITIAL.

    SELECT  SINGLE *
    INTO    CORRESPONDING FIELDS OF ls_srdef
    FROM    zmm_sr_def
    WHERE   srnum EQ me->gs_recet-srdup.

    IF sy-subrc EQ 0 AND ls_srdef-stats NE '25'.
      ls_histo-oldvl              = ls_srdef-stats.

      ls_srdef-stats              = '25'.
      MODIFY zmm_sr_def FROM ls_srdef.

      IF sy-subrc EQ 0.

        ls_alert-evtid                = 'RC14'.
        ls_alert-matnr                = ls_srdef-srnum.
        APPEND ls_alert TO me->gt_alert.

        CLEAR:  lv_chgnr,
                lv_chgn2.
        ls_histo-appnm                = 'R'.
        ls_histo-tbnam                = 'ZMM_SR_DEF'.
        ls_histo-descr                = ls_srdef-maktx.
        ls_histo-prnum                = ls_srdef-srnum.
        ls_histo-udate                = sy-datum.
        ls_histo-usern                = sy-uname.
        ls_histo-utime                = sy-uzeit.

        me->get_next( EXPORTING iv_range  = lv_range
                                iv_objct  = lv_iobjc
                      IMPORTING ev_numbr  = lv_chgnr ).

        IF lv_chgnr IS NOT INITIAL.
          MOVE lv_chgnr TO lv_chgn2.
          ls_histo-chgnr              = lv_chgn2.
        ENDIF.

        ls_histo-chngt                = 'U'.
        ls_histo-fname                = 'STATS'.
        ls_histo-ftext                = text-001.
        ls_histo-newvl                = '25'.
        ls_histo-evtid                = 'RC14'.

        INSERT zmm_history FROM ls_histo.

      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR:  lt_field,
          lt_histo.

  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_FT_VER'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-tbnam                  = 'ZMM_FT_VER'.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

* FT Versions
  LOOP AT me->gt_versn INTO ls_versn.
    CLEAR ls_ftver.
    MOVE-CORRESPONDING ls_versn TO ls_ftver.      "#EC ENHOK
    ls_ftver-ftnum = me->gv_frnum.
*    MODIFY zmm_ft_ver FROM ls_ftver.

    APPEND ls_ftver TO lt_ftver.

*   Save History **************************************************
    IF ls_versn-frnum NE '$'.

      CLEAR:  lv_chgnr,
              lv_chgn2.

      ls_histo-appnm                = 'R'.
      CONCATENATE 'Version' ls_versn-ftver 'de FT' ls_versn-frnum INTO ls_histo-descr SEPARATED BY ' '.
      CONCATENATE ls_versn-frnum '-' ls_versn-ftver INTO ls_histo-prnum.

      SELECT  SINGLE *
      INTO    CORRESPONDING FIELDS OF ls_ftvr2
      FROM    zmm_ft_ver
      WHERE   ftnum EQ ls_ftver-ftnum
      AND     ftver EQ ls_ftver-ftver.

      IF sy-subrc NE 0.

        ls_histo-chngt              = 'I'.
        ls_histo-fname              = 'FTVER'.
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

          ls_histo-chngt            = 'U'.

          IF ls_ftvr2-apdeb NE ls_ftver-apdeb.
            ls_histo-fname          = 'APDEB'.
            ls_histo-oldvl          = ls_ftvr2-apdeb.
            ls_histo-newvl          = ls_ftver-apdeb.

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

          IF ls_ftvr2-apfin NE ls_ftver-apfin.
            ls_histo-fname          = 'APFIN'.
            ls_histo-oldvl          = ls_ftvr2-apfin.
            ls_histo-newvl          = ls_ftver-apfin.

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

          IF ls_ftvr2-tmppr NE ls_ftver-tmppr.
            ls_histo-fname          = 'TMPPR'.
            ls_histo-oldvl          = ls_ftvr2-tmppr.
            ls_histo-newvl          = ls_ftver-tmppr.

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

          IF ls_ftvr2-nbgst NE ls_ftver-nbgst.
            ls_histo-fname          = 'NBGST'.

            MOVE ls_ftvr2-nbgst TO lv_oldvl.
            MOVE ls_ftver-nbgst TO lv_newvl.

            ls_histo-oldvl          = lv_oldvl.
            ls_histo-newvl          = lv_newvl.

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

          IF ls_ftvr2-ntgew NE ls_ftver-ntgew.
            ls_histo-fname          = 'NTGEW'.
            ls_histo-oldvl          = ls_ftvr2-ntgew.
            ls_histo-newvl          = ls_ftver-ntgew.

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

      ENDIF.

*   End Save History ****************************************

  ENDLOOP.

  MODIFY zmm_ft_ver FROM TABLE lt_ftver.
  IF sy-subrc EQ 0.
    INSERT zmm_history FROM TABLE lt_histo.
  ENDIF.

* Look for deleted versions
  LOOP AT me->lt_versn INTO ls_versn.
*   Search by Version Number
    READ TABLE me->gt_versn TRANSPORTING NO FIELDS WITH KEY ftver = ls_versn-ftver.
    IF sy-subrc NE 0.
      DELETE FROM zmm_ft_ver WHERE ftnum EQ me->gv_frnum AND ftver EQ ls_versn-ftver.

*     Save History ******************************************************************
      IF sy-subrc EQ 0.

        CLEAR:  lv_chgnr,
                lv_chgn2,
                lt_histo.

        ls_histo-appnm            = 'R'.
        CONCATENATE 'Version' ls_versn-ftver 'de recette' ls_versn-frnum INTO ls_histo-descr SEPARATED BY ' '.
        CONCATENATE ls_versn-frnum '-' ls_versn-ftver INTO ls_histo-prnum.

        ls_histo-chngt            = 'D'.
        ls_histo-fname            = 'FTVER'.
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

*     End Save History *****************************************

    ENDIF.

*   Search by Dates
    READ TABLE me->gt_versn TRANSPORTING NO FIELDS WITH KEY apdeb = ls_versn-apdeb apfin = ls_versn-apfin.
    IF sy-subrc NE 0.
      DELETE FROM zmm_ft_ver WHERE ftnum EQ me->gv_frnum AND apdeb = ls_versn-apdeb AND apfin = ls_versn-apfin.
    ENDIF.
  ENDLOOP.

  CLEAR:  lt_field,
          lt_histo.

  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_FT_ING'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-appnm                  = 'R'.
  ls_histo-tbnam                  = 'ZMM_FT_ING'.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

  IF me->gt_ingre NE me->lt_ingre.
*   FT Components data
    LOOP AT me->gt_ingre INTO ls_ingre.
      ls_fting-mandt      = sy-mandt.
      ls_fting-ftnum      = me->gv_frnum.
      ls_fting-ftver      = ls_ingre-ftver.
      ls_fting-fting      = ls_ingre-matnr.
      ls_fting-isaft      = ls_ingre-isaft.
      ls_fting-qtite      = ls_ingre-qtite.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
         input                    = ls_ingre-unite
         language                 = sy-langu
       IMPORTING
         output                   = ls_ingre-unite
       EXCEPTIONS
         unit_not_found           = 1.

      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

      ls_fting-unite      = ls_ingre-unite.
      ls_fting-perte      = ls_ingre-perte.
      ls_fting-exlot      = ls_ingre-exlot.
      ls_fting-matac      = ls_ingre-matac.
      ls_fting-typea      = ls_ingre-typea.

      APPEND ls_fting TO lt_fting.

*      MODIFY zmm_ft_ing FROM ls_fting.

*     Save History **************************************************

      CLEAR:  lv_chgnr,
              lv_chgn2.

      lv_matnr                    = ls_fting-fting.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input                   = ls_fting-fting
        IMPORTING
          output                  = lv_matnr.

      ls_histo-appnm              = 'R'.
      CONCATENATE ls_fting-ftnum '-' ls_fting-ftver '-' lv_matnr INTO ls_histo-prnum.
      ls_histo-descr              = ls_histo-prnum.

      SELECT  SINGLE *
      INTO    CORRESPONDING FIELDS OF ls_ftng2
      FROM    zmm_ft_ing
      WHERE   ftnum EQ ls_fting-ftnum
      AND     ftver EQ ls_fting-ftver
      AND     fting EQ ls_fting-fting.

      IF sy-subrc NE 0.

        ls_histo-chngt            = 'I'.
        ls_histo-fname            = 'FTING'.
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

        IF ls_ftng2-matac NE ls_fting-matac.
          ls_histo-fname          = 'MATAC'.
          ls_histo-oldvl          = ls_ftng2-matac.
          ls_histo-newvl          = ls_fting-matac.

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

        IF ls_ftng2-qtite NE ls_fting-qtite.

***Mantis 1617******************************************************
***          ls_alert-matnr              = ls_fting-fting.
          ls_alert-matnr              = ls_fting-matac.
          ls_alert-vdesc              = ls_fting-ftnum.
***Mantis 1617******************************************************
          ls_alert-evtid              = 'MP11'. "ALerte : Modification volume article
          APPEND ls_alert TO me->gt_alert.
          ls_histo-fname          = 'QTITE'.

          MOVE ls_ftng2-qtite TO lv_oldvl.
          MOVE ls_fting-qtite TO lv_newvl.

          ls_histo-oldvl              = lv_oldvl.
          ls_histo-newvl              = lv_newvl.
          ls_histo-evtid              = 'MP11'.

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

        IF ls_ftng2-perte NE ls_fting-perte.
          ls_histo-fname          = 'PERTE'.

          MOVE ls_ftng2-perte TO lv_oldvl.
          MOVE ls_fting-perte TO lv_newvl.

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

        IF ls_ftng2-exlot NE ls_fting-exlot.
          ls_histo-fname          = 'EXLOT'.
          ls_histo-oldvl          = ls_ftng2-exlot.
          ls_histo-newvl          = ls_fting-exlot.

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

        IF ls_ftng2-isaft NE ls_fting-isaft.
          ls_histo-fname          = 'ISAFT'.
          ls_histo-oldvl          = ls_ftng2-isaft.
          ls_histo-newvl          = ls_fting-isaft.

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

        IF ls_ftng2-unite NE ls_fting-unite.
          ls_histo-fname          = 'UNITE'.
          ls_histo-oldvl          = ls_ftng2-unite.
          ls_histo-newvl          = ls_fting-unite.

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

        IF ls_ftng2-typea NE ls_fting-typea.
          ls_histo-fname          = 'TYPEA'.
          ls_histo-oldvl          = ls_ftng2-typea.
          ls_histo-newvl          = ls_fting-typea.

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

    ENDLOOP.

    MODIFY zmm_ft_ing FROM TABLE lt_fting.
    IF sy-subrc EQ 0.
      INSERT zmm_history FROM TABLE lt_histo.
    ENDIF.

    CLEAR:  lt_histo.

*   Look for deleted ingredients
    LOOP AT me->lt_ingre INTO ls_ingre.
      READ TABLE me->gt_ingre TRANSPORTING NO FIELDS WITH KEY matnr = ls_ingre-matnr ftver = ls_ingre-ftver.
      IF sy-subrc NE 0.
        DELETE FROM zmm_ft_ing WHERE ftnum = me->gv_frnum AND fting EQ ls_ingre-matnr AND ftver = ls_ingre-ftver.

*       Save History ******************************************************************
        IF sy-subrc EQ 0.
***Mantis 1617******************************************************
          ls_alert-matnr          = ls_ingre-matac.
          ls_alert-vdesc          = ls_ingre-frnum.
***Mantis 1617******************************************************
          ls_alert-evtid          = 'MP11'. "ALerte : Modification volume article
          APPEND ls_alert TO me->gt_alert.
          CLEAR:  lv_chgnr,
                  lv_chgn2,
                  lt_histo.

          lv_matnr                = ls_ingre-matnr.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input               = ls_ingre-matnr
            IMPORTING
              output              = lv_matnr.

          ls_histo-appnm          = 'R'.
          CONCATENATE me->gv_frnum '-' ls_ingre-ftver '-' lv_matnr INTO ls_histo-prnum.
          ls_histo-descr          = ls_histo-prnum.

          ls_histo-chngt          = 'D'.
          ls_histo-fname          = 'FTING'.
          ls_histo-oldvl          = lv_matnr.
          CLEAR ls_histo-newvl.
          ls_histo-evtid          = 'MP11'.

          READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
          IF sy-subrc EQ 0.

            ls_histo-ftext        = ls_field-scrtext_l.

            me->get_next( EXPORTING iv_range  = lv_range
                                    iv_objct  = lv_iobjc
                          IMPORTING ev_numbr  = lv_chgnr ).

            MOVE lv_chgnr TO lv_chgn2.
            ls_histo-chgnr        = lv_chgn2.

            APPEND ls_histo TO lt_histo.
            INSERT zmm_history FROM TABLE lt_histo.

          ENDIF.

        ENDIF.

*     End Save History *****************************************

      ENDIF.
    ENDLOOP.
  ENDIF.

* Enseignes
  LOOP AT me->gt_ensgn INTO ls_ensgn WHERE activ EQ 'X'.
    READ TABLE me->lt_ensgn TRANSPORTING NO FIELDS WITH KEY ensgn = ls_ensgn-ensgn activ = 'X'.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING ls_ensgn TO ls_ftens.
      ls_ftens-ftnum              = me->gv_frnum.
      INSERT zmm_ft_ens FROM ls_ftens.
    ENDIF.
  ENDLOOP.
  LOOP AT me->lt_ensgn INTO ls_ensgn WHERE activ EQ 'X'.
    READ TABLE me->gt_ensgn TRANSPORTING NO FIELDS WITH KEY ensgn = ls_ensgn-ensgn activ = 'X'.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING ls_ensgn TO ls_ftens.
      ls_ftens-ftnum              = me->gv_frnum.
      DELETE zmm_ft_ens FROM ls_ftens.
    ENDIF.
  ENDLOOP.

ENDMETHOD.