METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
  TYPES : BEGIN OF ty_alert,
            evtid TYPE zmm_ft_alert,
            matnr TYPE matnr,
            descr TYPE zft_gw_descr,
          END OF ty_alert.

  TYPES : BEGIN OF ty_field,
            tabname   TYPE tabname,
            fieldname TYPE fieldname,
            scrtext_l TYPE scrtext_l,
          END OF ty_field.

  DATA: lv_arcid    TYPE saeardoid,
        lv_chgnr    TYPE i,
        lv_chgn2    TYPE cdchangenr,
        lv_compt    TYPE i,
        lv_count    TYPE i,
        lv_ctnum    TYPE string,
        lv_descr    TYPE zft_gw_descr,
        lv_diffd    TYPE p DECIMALS 2,
        lv_drbis    TYPE vtbbewe-dberbis,
        lv_drvon    TYPE vtbbewe-dbervon,
        lv_error    TYPE xfeld,
        lv_iobjc    TYPE inri-object VALUE 'ZMM_CHGNR',
        lv_newvl    TYPE string,
        lv_noval    TYPE xfeld,
        lv_objid    TYPE saeobjid,
        lv_objct    TYPE saeanwdid,
        lv_oldvl    TYPE string,
        lv_range    TYPE inri-nrrangenr VALUE '01',
        lv_subrc    TYPE i,
        lv_volum    TYPE i,
        ls_alert    TYPE ty_alert,
        ls_arcob    TYPE zao_s_toauri,
        ls_cadef    TYPE zmm_ca_def,
        ls_cade2    TYPE zmm_ca_def,
        ls_cade3    TYPE zmm_ca_def,
        ls_caitm    TYPE zmm_ca_itm,
        ls_cait2    TYPE zmm_ca_itm,
        ls_ensgn    TYPE zft_s_alert_ensgn,
        ls_field    TYPE ty_field,
        ls_ftalt    TYPE zmm_ft_alt,
        ls_ftal2    TYPE zmm_ft_alt,
        ls_ftfil    TYPE zmm_ft_fil,
        ls_ftfi2    TYPE zmm_ft_fil,
        ls_histo    TYPE zmm_history,
        ls_notif    TYPE zmm_ft_notificat,
        ls_retrn    TYPE bapiret2,
        ls_sdetl    TYPE zcl_zft_gw_ges_carte_mpc_ext=>ts_detail,
        ls_smenu    TYPE zcl_zft_gw_ges_carte_mpc_ext=>ts_menu,
        ls_sofil    TYPE /iwbep/s_cod_select_option,
        ls_soitm    TYPE /iwbep/s_cod_select_option,
        ls_sfile    TYPE zcl_zft_gw_ges_carte_mpc_ext=>ts_file,
        ls_srdef    TYPE zmm_sr_def,
        ls_where    TYPE string,
        lt_alert    TYPE TABLE OF ty_alert,
        lt_arcob    TYPE zao_t_toauri,
        lt_caitm    TYPE TABLE OF zmm_ca_itm,
        lt_ensgn    TYPE zft_t_alert_ensgn,
        lt_field    TYPE TABLE OF ty_field,
        lt_ftalt    TYPE TABLE OF zmm_ft_alt,
        lt_ftal2    TYPE TABLE OF zmm_ft_alt,
        lt_ftfi2    TYPE TABLE OF zmm_ft_fil,
        lt_histo    TYPE TABLE OF zmm_history,
        lt_retrn    TYPE bapiret2_t,
        lt_sofil    TYPE /iwbep/t_cod_select_options,
        lt_soitm    TYPE /iwbep/t_cod_select_options,
        lt_tdetl    TYPE zcl_zft_gw_ges_carte_mpc_ext=>tt_detail,
        lt_tfile    TYPE zcl_zft_gw_ges_carte_mpc_ext=>tt_file,
        lt_where    TYPE TABLE OF string,
        lr_rdata    TYPE REF TO data.

  FIELD-SYMBOLS:  <dmenu>   TYPE zcl_zft_gw_ges_carte_mpc_ext=>ts_deep_menu.

  CREATE DATA lr_rdata TYPE zcl_zft_gw_ges_carte_mpc_ext=>ts_deep_menu.
  ASSIGN lr_rdata->* TO <dmenu>.

* Get Data
  io_data_provider->read_entry_data( IMPORTING es_data  = <dmenu> ).

*** check data consistency *************************************************** BEG *
  IF <dmenu>-ctnum IS INITIAL OR strlen( <dmenu>-ctnum ) GE 19.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '143'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.
  IF <dmenu>-descr IS INITIAL OR strlen( <dmenu>-descr ) GE 129.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '144'.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.
  IF <dmenu>-apdeb IS INITIAL OR strlen( <dmenu>-apdeb ) GE 9 OR NOT <dmenu>-apdeb CO '0123456789'.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '145'.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.
  IF <dmenu>-apfin IS INITIAL OR strlen( <dmenu>-apfin ) GE 9 OR NOT <dmenu>-apfin CO '0123456789'.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '146'.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.
  IF <dmenu>-apfin LE <dmenu>-apdeb.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '165'.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.
  IF <dmenu>-vkorg IS INITIAL OR strlen( <dmenu>-vkorg ) GE 5.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '147'.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.

  MOVE-CORRESPONDING <dmenu>-mn2dt TO lt_tdetl.
  LOOP AT lt_tdetl INTO ls_sdetl.
    IF ls_sdetl-volum IS NOT INITIAL AND ls_sdetl-vunit IS INITIAL.
*     Error: Recette &1 : l'unité de volume n'a pas été selectionnée
      ls_retrn-type                 = 'E'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '220'.
      ls_retrn-message_v1           = ls_sdetl-frnum.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.

*   Check status (Id 14)
    IF ls_sdetl-stats IS INITIAL.

      SELECT  SINGLE *
      INTO    CORRESPONDING FIELDS OF ls_srdef
      FROM    zmm_sr_def
      WHERE   srnum EQ ls_sdetl-frnum.

      ls_sdetl-stats              = ls_srdef-stats.

    ENDIF.

    IF ( ls_sdetl-stats NE '20' AND ls_sdetl-stats NE '25' ) AND ls_sdetl-frnum CS 'SR'.
      lv_noval                    = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT  SINGLE *
  INTO    CORRESPONDING FIELDS OF ls_cadef
  FROM    zmm_ca_def
  WHERE   ctnum EQ <dmenu>-ctnum.

  IF lv_noval EQ 'X'.

*    IF <dmenu>-stats EQ '30'.
*
*      IF ls_cadef-stats EQ '20'.
*
*        ls_retrn-type             = 'E'.
*        ls_retrn-id               = 'ZMM'.
*        ls_retrn-number           = '231'.
*
*        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
*                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
*                                                                         iv_add_to_response_header = abap_true
*                                                                         iv_message_target         = 'E' ).
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
*
      IF ls_cadef-stats NE <dmenu>-stats AND <dmenu>-stats EQ '20'.
        ls_alert-evtid          = 'CA10'.
        ls_alert-matnr          = <dmenu>-ctnum.
        ls_alert-descr          = <dmenu>-descr.
        APPEND ls_alert TO lt_alert.
      ENDIF.

      IF ls_cadef-stats EQ '30'.
        <dmenu>-stats             = '20'.
      ENDIF.
*
*    ENDIF.

  ELSE.

    IF lt_tdetl IS NOT INITIAL.

      IF <dmenu>-stats EQ '20' OR <dmenu>-stats EQ '30'.


        IF ls_cadef-stats EQ '20'.

          CONCATENATE 'CR' lv_ctnum INTO lv_ctnum.
        ELSE.
          IF <dmenu>-stats EQ 20.
            ls_alert-evtid        = 'CA10'.
            ls_alert-matnr        = <dmenu>-ctnum.
            ls_alert-descr        = <dmenu>-descr.
            APPEND ls_alert TO lt_alert.
          ENDIF.
        ENDIF.
        <dmenu>-stats             = '30'.
        ls_alert-evtid            = 'CA07'.
        ls_alert-matnr            = <dmenu>-ctnum.
        ls_alert-descr            = <dmenu>-descr.
        APPEND ls_alert TO lt_alert.

      ENDIF.

    ELSE.
       IF <dmenu>-stats NE ls_cadef-stats AND <dmenu>-stats EQ '20'.
          ls_alert-evtid        = 'CA10'.
          ls_alert-matnr        = <dmenu>-ctnum.
          ls_alert-descr        = <dmenu>-descr.
          APPEND ls_alert TO lt_alert.
       ENDIF.
*      IF <dmenu>-stats EQ '30'.
*        <dmenu>-stats             = '20'.
*      ENDIF.

    ENDIF.

  ENDIF.

  MOVE-CORRESPONDING <dmenu>-mn2fl TO lt_tfile.
  LOOP AT lt_tfile INTO ls_sfile.
    IF ls_sfile-arcid IS INITIAL OR strlen( ls_sfile-arcid ) GE 41.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '148'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF ls_sfile-objnr IS INITIAL OR strlen( ls_sfile-objnr ) GE 19.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '149'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF ls_sfile-objtp IS INITIAL OR strlen( ls_sfile-objtp ) GE 2 OR NOT ls_sfile-objtp CO 'CIFS'.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '150'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF ls_sfile-descr IS INITIAL OR strlen( ls_sfile-descr ) GE 129.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '151'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
  ENDLOOP.
*** check data consistency *************************************************** END *

* Save menu.
  MOVE-CORRESPONDING <dmenu> TO ls_smenu.
  IF ls_smenu-ctnum+0(1) EQ '$'.

    lv_descr                      = <dmenu>-descr.
    TRANSLATE lv_descr TO UPPER CASE.

******   Check if an identical menu exists
*****    SELECT  SINGLE *
*****    INTO    CORRESPONDING FIELDS OF ls_cade3
*****    FROM    zmm_ca_def
*****    WHERE   descx EQ lv_descr
*****    AND     vkorg EQ <dmenu>-vkorg.
*****
*****    IF sy-subrc EQ 0.
*****      IF ls_cade3-stats NE '40'.
*****
******       Error. An identical menu already exists
*****        ls_retrn-type             = 'E'.
*****        ls_retrn-id               = 'ZMM'.
*****        ls_retrn-number           = '233'.
*****
*****        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
*****                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
*****                                                                         iv_add_to_response_header = abap_true
*****                                                                         iv_message_target         = 'E' ).
*****        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
*****
*****      ENDIF.
*****    ENDIF.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr               = '01'
        object                    = 'ZMM_CTNUM'
      IMPORTING
        number                    = lv_ctnum
      EXCEPTIONS
        interval_not_found        = 1
        number_range_not_intern   = 2
        object_not_found          = 3
        quantity_is_0             = 4
        quantity_is_not_1         = 5
        interval_overflow         = 6
        buffer_overflow           = 7
        OTHERS                    = 8.
    IF sy-subrc NE 0.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '111'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ELSE.
      CONCATENATE 'CR' lv_ctnum INTO lv_ctnum.
      ls_smenu-ctnum              = lv_ctnum.

***      ls_alert-evtid              = 'CA01'.
***      ls_alert-matnr              = lv_ctnum.
***      ls_alert-descr              = ls_smenu-descr.
***      APPEND ls_alert TO lt_alert.
      <dmenu>-ctnum               = lv_ctnum.
    ENDIF.
  ENDIF.

* Save Definition
  MOVE-CORRESPONDING ls_smenu TO ls_cadef.

  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_CA_DEF'
  AND     t~ddlanguage EQ sy-langu.

  SELECT SINGLE *
  INTO CORRESPONDING FIELDS OF ls_cade2
  FROM zmm_ca_def
  WHERE ctnum EQ ls_cadef-ctnum.

  IF sy-subrc NE 0.
    ls_cadef-aedat                = sy-datum.
    ls_cadef-aenam                = sy-uname.

*   Save Histo *********************************************
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr               = '01'
        object                    = 'ZMM_CHGNR'
      IMPORTING
        number                    = lv_chgnr
      EXCEPTIONS
        interval_not_found        = 1
        number_range_not_intern   = 2
        object_not_found          = 3
        quantity_is_0             = 4
        quantity_is_not_1         = 5
        interval_overflow         = 6
        buffer_overflow           = 7
        OTHERS                    = 8.

    IF sy-subrc NE 0.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '238'.
      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ELSE.
      MOVE lv_chgnr TO lv_chgn2.
      ls_histo-chgnr              = lv_chgn2.
    ENDIF.

    ls_histo-appnm                = 'C'.
    ls_histo-chngt                = 'I'.
    ls_histo-tbnam                = 'ZMM_CA_DEF'.
    ls_histo-descr                = ls_cadef-descr.
    ls_histo-prnum                = ls_cadef-ctnum.
    ls_histo-udate                = sy-datum.
    ls_histo-usern                = sy-uname.
    ls_histo-utime                = sy-uzeit.
    ls_histo-fname                = 'CTNUM'.
    ls_histo-newvl                = ls_cadef-ctnum.

    READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
    IF sy-subrc EQ 0.
      ls_histo-ftext              = ls_field-scrtext_l.
      APPEND ls_histo TO lt_histo.
    ENDIF.

  ELSE.

    IF    ls_cadef-descr NE ls_cade2-descr
      OR  ls_cadef-vkorg NE ls_cade2-vkorg
      OR  ls_cadef-cahie NE ls_cade2-cahie
      OR  ls_cadef-apdeb NE ls_cade2-apdeb
      OR  ls_cadef-apfin NE ls_cade2-apfin.
      ls_cadef-aedat              = sy-datum.
      ls_cadef-aenam              = sy-uname.

      IF ls_cadef-apdeb NE ls_cade2-apdeb OR ls_cadef-apfin NE ls_cade2-apfin.
        ls_alert-evtid            = 'CA03'.
        ls_alert-matnr            = ls_smenu-ctnum.
        ls_alert-descr            = ls_smenu-descr.
        APPEND ls_alert TO lt_alert.
      ENDIF.
      IF ls_cadef-descr NE ls_cade2-descr.
        ls_alert-evtid            = 'CA04'.
        ls_alert-matnr            = ls_smenu-ctnum.
        ls_alert-descr            = ls_smenu-descr.
        APPEND ls_alert TO lt_alert.
      ENDIF.
    ENDIF.

    ls_histo-appnm                = 'C'.
    ls_histo-chngt                = 'U'.
    ls_histo-tbnam                = 'ZMM_CA_DEF'.
    ls_histo-descr                = ls_cadef-descr.
    ls_histo-prnum                = ls_cadef-ctnum.
    ls_histo-udate                = sy-datum.
    ls_histo-usern                = sy-uname.
    ls_histo-utime                = sy-uzeit.

    IF ls_cade2-descr NE ls_cadef-descr.
      ls_histo-fname              = 'DESCR'.
      ls_histo-oldvl              = ls_cade2-descr.
      ls_histo-newvl              = ls_cadef-descr.
      ls_histo-evtid              = 'CA04'.

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

    IF ls_cade2-vkorg NE ls_cadef-vkorg.
      ls_histo-fname              = 'VKORG'.
      ls_histo-oldvl              = ls_cade2-vkorg.
      ls_histo-newvl              = ls_cadef-vkorg.

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

    IF ls_cade2-cahie NE ls_cadef-cahie.
      ls_histo-fname              = 'CAHIE'.
      ls_histo-oldvl              = ls_cade2-cahie.
      ls_histo-newvl              = ls_cadef-cahie.

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

    IF ls_cade2-apdeb NE ls_cadef-apdeb.
      ls_histo-fname              = 'APDEB'.
      ls_histo-oldvl              = ls_cade2-apdeb.
      ls_histo-newvl              = ls_cadef-apdeb.
      ls_histo-evtid              = 'CA03'.

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

    IF ls_cade2-apfin NE ls_cadef-apfin.
      ls_histo-fname              = 'APFIN'.
      ls_histo-oldvl              = ls_cade2-apfin.
      ls_histo-newvl              = ls_cadef-apfin.
      ls_histo-evtid              = 'CA03'.

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

    IF ls_cade2-arcid NE ls_cadef-arcid.
      ls_histo-fname              = 'ARCID'.
      ls_histo-oldvl              = ls_cade2-arcid.
      ls_histo-newvl              = ls_cadef-arcid.

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

    IF ls_cade2-stats NE ls_cadef-stats.
      ls_histo-fname              = 'STATS'.
      ls_histo-oldvl              = ls_cade2-stats.
      ls_histo-newvl              = ls_cadef-stats.

      CASE ls_histo-newvl.
        WHEN '30'.
          ls_histo-evtid          = 'CA07'.
        WHEN '20'.
          ls_histo-evtid          = 'CA10'.
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

  ENDIF.
  IF ls_cadef-descx IS INITIAL OR ls_cadef-descr NE ls_cade2-descr.
    ls_cadef-descx                = ls_cadef-descr.
    TRANSLATE ls_cadef-descx TO UPPER CASE.
  ENDIF.
  MOVE-CORRESPONDING <dmenu>-mn2fl TO lt_tfile.
  LOOP AT lt_tfile INTO ls_sfile.
    IF ls_sfile-fmain EQ abap_true.
      lv_arcid                    = ls_sfile-arcid.
    ENDIF.
    ls_sofil-sign                 = 'I'.
    ls_sofil-option               = 'EQ'.
    ls_sofil-low                  = ls_sfile-arcid.
    APPEND ls_sofil TO lt_sofil.
  ENDLOOP.
  ls_cadef-arcid                  = lv_arcid.

* Si nouvelle carte --> statut initial
  IF ls_cadef-stats IS INITIAL.
    ls_cadef-stats                = '10'.
  ENDIF.

  IF ls_cadef-ersda IS INITIAL.
    ls_cadef-ersda                = sy-datum.
  ENDIF.

  MODIFY zmm_ca_def FROM ls_cadef.

  IF sy-subrc NE 0.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '109'.
    ls_retrn-message_v1           = ls_cadef-ctnum.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    lv_subrc                      = 1.
  ELSE.
    INSERT zmm_history FROM TABLE lt_histo.
  ENDIF.
* #Bug 125
  IF me->verif_doublon( ls_cadef ) EQ abap_true.
    ls_retrn-type             = 'W'.
    ls_retrn-id               = 'ZMM'.
    ls_retrn-number           = '235'. "Message inexistant pour l'instant a faire
    ls_retrn-message_v1       = ''.
    ls_retrn-message_v2       = ''.

    me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                      iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                      iv_add_to_response_header = abap_true
                                                                      iv_message_target         = 'W' ).

  ENDIF.

* Save Details
  MOVE-CORRESPONDING <dmenu>-mn2dt TO lt_tdetl.

  SELECT  *
  INTO    CORRESPONDING FIELDS OF TABLE lt_caitm
  FROM    zmm_ca_itm
  WHERE   ctnum EQ ls_smenu-ctnum.

  lv_drbis                        = ls_cadef-apfin.
  lv_drvon                        = ls_cadef-apdeb.

  CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
    EXPORTING
      i_datum_bis                 = lv_drbis
      i_datum_von                 = lv_drvon
    IMPORTING
      e_tage                      = lv_diffd
    EXCEPTIONS
      OTHERS                      = 1.

  IF sy-subrc EQ 0.
    lv_diffd                      = lv_diffd / 30.
  ENDIF.

  SELECT  fieldname tabname scrtext_l
  INTO    CORRESPONDING FIELDS OF TABLE lt_field
  FROM    dd03l AS l
  INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
  WHERE   l~tabname EQ 'ZMM_CA_ITM'
  AND     t~ddlanguage EQ sy-langu.

  ls_histo-tbnam                  = 'ZMM_CA_ITM'.
  ls_histo-udate                  = sy-datum.
  ls_histo-usern                  = sy-uname.
  ls_histo-utime                  = sy-uzeit.

  LOOP AT lt_tdetl INTO ls_sdetl.
    ls_soitm-sign                 = 'I'.
    ls_soitm-option               = 'EQ'.
    ls_soitm-low                  = ls_sdetl-frnum.
    APPEND ls_soitm TO lt_soitm.

    IF ls_sdetl-frnum IS NOT INITIAL.
      MOVE-CORRESPONDING ls_sdetl TO ls_caitm.
      ls_caitm-ctnum              = ls_smenu-ctnum.
      IF ls_caitm-rstat IS INITIAL.
        ls_caitm-rstat            = 'N'.
      ENDIF.
      CLEAR: ls_cait2.
      READ TABLE lt_caitm INTO ls_cait2 WITH KEY frnum = ls_caitm-frnum.
      IF sy-subrc NE 0 AND ls_smenu-stats EQ '20'. "Alerte ajout de recette que en statut brief realise
        ls_caitm-aedat            = sy-datum.
        ls_caitm-aenam            = sy-uname.
        ls_alert-evtid            = 'CA06'.
        ls_alert-matnr            = ls_smenu-ctnum.
        ls_alert-descr            = ls_smenu-descr.
        APPEND ls_alert TO lt_alert.
      ELSE.
        IF ls_caitm-ftver NE ls_cait2-ftver OR ls_caitm-rstat NE ls_cait2-rstat OR ls_caitm-qtite NE ls_cait2-qtite OR ls_caitm-qtitm NE ls_cait2-qtitm.
          ls_caitm-aedat          = sy-datum.
          ls_caitm-aenam          = sy-uname.
        ENDIF.

*       Changement de Vol Prev => Alerte CA08
        IF ls_caitm-volum NE ls_cait2-volum.
          ls_caitm-aedat          = sy-datum.
          ls_caitm-aenam          = sy-uname.
          ls_alert-evtid          = 'CA08'.
          ls_alert-matnr          = ls_smenu-ctnum.
          ls_alert-descr          = ls_smenu-descr.
          APPEND ls_alert TO lt_alert.
*         A verifier pourquoi 2 alertes pour la meme chose
          ls_alert-evtid          = 'RC10'.
          ls_alert-matnr          = ls_smenu-ctnum.
          ls_alert-descr          = ls_smenu-descr.
          APPEND ls_alert TO lt_alert.
        ENDIF.

*       Changement de Vunit => Alerte CA09
        IF ls_caitm-vunit NE ls_cait2-vunit.
          ls_caitm-aedat          = sy-datum.
          ls_caitm-aenam          = sy-uname.
          ls_alert-evtid          = 'CA09'.
          ls_alert-matnr          = ls_smenu-ctnum.
          ls_alert-descr          = ls_smenu-descr.
          APPEND ls_alert TO lt_alert.
        ENDIF.
      ENDIF.

      IF ls_caitm-vunit EQ 'P'.
        ls_caitm-qtite            = ls_caitm-volum.
        lv_volum                  = ls_caitm-volum / lv_diffd.
        ls_caitm-qtitm            = lv_volum.
      ELSEIF ls_caitm-vunit EQ 'M'.
        lv_volum                  = ls_caitm-volum * lv_diffd.
        ls_caitm-qtite            = lv_volum.
        ls_caitm-qtitm            = ls_caitm-volum.
      ENDIF.


*     Save history ****************************************************
      CLEAR:  lv_chgnr,
              lv_chgn2,
              lt_histo.

      ls_histo-appnm              = 'C'.
      CONCATENATE 'Recette' ls_sdetl-frnum 'dans carte' ls_smenu-ctnum INTO ls_histo-descr SEPARATED BY ' '.
      CONCATENATE ls_smenu-ctnum '-' ls_sdetl-frnum INTO ls_histo-prnum.

      READ TABLE lt_caitm INTO ls_cait2 WITH KEY frnum = ls_caitm-frnum.

      IF sy-subrc NE 0.

        ls_histo-chngt            = 'I'.
        ls_histo-fname            = 'FRNUM'.
        ls_histo-newvl            = ls_caitm-frnum.
        CLEAR ls_histo-oldvl.
        ls_histo-evtid            = 'CA06'.

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

        IF ls_caitm-rstat NE ls_cait2-rstat.
          ls_histo-fname          = 'RSTAT'.
          ls_histo-oldvl          = ls_cait2-rstat.
          ls_histo-newvl          = ls_caitm-rstat.

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

        IF ls_caitm-volum NE ls_cait2-volum.
          ls_histo-fname          = 'VOLUM'.

          MOVE ls_cait2-volum TO lv_oldvl.
          MOVE ls_caitm-volum TO lv_newvl.

          ls_histo-oldvl              = lv_oldvl.
          ls_histo-newvl              = lv_newvl.
          ls_histo-evtid              = 'CA08'.

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

        IF ls_caitm-vunit NE ls_cait2-vunit.
          ls_histo-fname          = 'VUNIT'.
          ls_histo-oldvl          = ls_cait2-vunit.
          ls_histo-newvl          = ls_caitm-vunit.
          ls_histo-evtid          = 'CA09'.

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
*     End Save history **************************************

      MODIFY zmm_ca_itm FROM ls_caitm.

      IF sy-subrc NE 0.
        ls_retrn-type             = 'E'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '110'.
        ls_retrn-message_v1       = ls_caitm-frnum.
        ls_retrn-message_v2       = ls_cadef-ctnum.

        me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                          iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                          iv_add_to_response_header = abap_true
                                                                          iv_message_target         = 'E' ).
        lv_subrc                  = 1.

      ELSE.

        INSERT zmm_history FROM TABLE lt_histo.

      ENDIF.
    ENDIF.
  ENDLOOP.

* Save history for deleted recipes ********************************
  LOOP AT lt_caitm INTO ls_caitm.

    READ TABLE lt_tdetl INTO ls_sdetl WITH KEY frnum = ls_caitm-frnum.
    IF sy-subrc NE 0.

      CLEAR:  lv_chgnr,
              lv_chgn2,
              lt_histo.

      ls_histo-appnm              = 'C'.
      CONCATENATE 'Recette' ls_caitm-frnum 'dans carte' ls_smenu-ctnum INTO ls_histo-descr SEPARATED BY ' '.
      CONCATENATE ls_smenu-ctnum '-' ls_caitm-frnum INTO ls_histo-prnum.

      ls_histo-chngt              = 'D'.
      ls_histo-fname              = 'FRNUM'.
      ls_histo-oldvl              = ls_caitm-frnum.
      CLEAR ls_histo-newvl.
      ls_histo-evtid              = 'CA05'.

      READ TABLE lt_field INTO ls_field WITH KEY fieldname = ls_histo-fname.
      IF sy-subrc EQ 0.
        ls_histo-ftext            = ls_field-scrtext_l.

        me->get_next( EXPORTING iv_range  = lv_range
                                  iv_objct  = lv_iobjc
                        IMPORTING ev_numbr  = lv_chgnr ).

        MOVE lv_chgnr TO lv_chgn2.
        ls_histo-chgnr            = lv_chgn2.

        APPEND ls_histo TO lt_histo.
        INSERT zmm_history FROM TABLE lt_histo.

      ENDIF.

    ENDIF.

  ENDLOOP.

  IF lt_soitm[] IS NOT INITIAL.
    CONCATENATE 'frnum NOT IN' 'lt_soitm' INTO ls_where SEPARATED BY space.
    APPEND ls_where TO lt_where.
  ENDIF.

  SELECT *
  INTO TABLE lt_caitm
  FROM zmm_ca_itm
  WHERE ctnum EQ ls_cadef-ctnum
  AND  ( (lt_where) ).

  IF sy-subrc EQ 0.
    DELETE FROM zmm_ca_itm
    WHERE   ctnum EQ ls_cadef-ctnum
    AND     ( (lt_where) ).

    IF sy-subrc EQ 0.
      ls_alert-evtid              = 'CA05'.
      ls_alert-matnr              = ls_smenu-ctnum.
      ls_alert-descr              = ls_smenu-descr.
      APPEND ls_alert TO lt_alert.
    ENDIF.
  ENDIF.

* Delete Files
  CLEAR : ls_where, lt_where.
  lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_carte.
  lv_objid                      = <dmenu>-ctnum.

  CALL FUNCTION 'ZAO_DOCUMENT_GET'
    EXPORTING
      iv_objct                  = lv_objct
      iv_objid                  = lv_objid
    IMPORTING
      et_arcob                  = lt_arcob
    EXCEPTIONS
      OTHERS                    = 0.

  IF lt_arcob[] IS NOT INITIAL.
    IF lt_sofil[] IS NOT INITIAL.
      DELETE lt_arcob WHERE arc_doc_id IN lt_sofil.
    ENDIF.
    LOOP AT lt_arcob INTO ls_arcob.
      CALL FUNCTION 'ZAO_DOCUMENT_DELETE'
        EXPORTING
          iv_objct                = lv_objct
          iv_objid                = lv_objid
          iv_arcid                = ls_arcob-arc_doc_id
       IMPORTING
         et_retrn                 = lt_retrn
       EXCEPTIONS
         OTHERS                   = 1.

      IF sy-subrc NE 0.
        CLEAR ls_retrn.
        ls_retrn-type             = 'E'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '125'. "Une ou plusieurs piece jointe n'ont pu etre supprimees de l'article &1.
        ls_retrn-message_v1       = ls_cadef-ctnum.
        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
        lv_subrc                  = 1.
      ELSE.
        IF lt_retrn[] IS NOT INITIAL.
          LOOP AT lt_retrn INTO ls_retrn.
            me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                           iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                           iv_add_to_response_header = abap_true
                                                                           iv_message_target         = 'E' ).
            lv_subrc              = 1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_subrc EQ 1.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ELSE.
*   Return Data
    ls_retrn-type                 = 'S'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '108'.
    ls_retrn-message_v1           = ls_cadef-ctnum.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'S' ).
    ls_ensgn-ensgn                = ls_cadef-vkorg+1.
    APPEND ls_ensgn TO lt_ensgn.

    SORT lt_alert BY evtid.
    DELETE ADJACENT DUPLICATES FROM lt_alert.

    LOOP AT lt_alert INTO ls_alert.
      CALL FUNCTION 'ZMM_FT_ALERT_MNGMT'
        EXPORTING
          iv_evtid                = ls_alert-evtid
          iv_descr                = ls_alert-descr
          iv_matnr                = ls_alert-matnr
        TABLES
          ensgn_tab               = lt_ensgn
        EXCEPTIONS
          param_missing           = 1
          send_mail_error         = 2
          mail_content            = 3
          unknown_event           = 4
          unknown_receiver        = 5
          OTHERS                  = 0.

      IF sy-subrc NE 0.
        ls_retrn-type             = 'W'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '135'.
        ls_retrn-message_v1       = ls_alert-evtid.
        ls_retrn-message_v2       = ls_alert-matnr.

        me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                          iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                          iv_add_to_response_header = abap_true
                                                                          iv_message_target         = 'W' ).
      ENDIF.
    ENDLOOP.

*   Handle notifications
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

    er_deep_entity                = lr_rdata.
  ENDIF.
ENDMETHOD.