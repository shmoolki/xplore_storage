METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
  TYPES : BEGIN OF ty_alert,
            descr   TYPE zft_gw_descr,
            evtid   TYPE zmm_ft_alert,
            matnr   TYPE matnr,
            rmatn   TYPE matnr,
            kbetn   TYPE zmm_af_price,
            kbeto   TYPE zmm_af_price,
            rcttb   TYPE zft_t_alert_frnum,
          END OF ty_alert.

  TYPES : BEGIN OF ty_field,
            tabname   TYPE tabname,
            fieldname TYPE fieldname,
            scrtext_l TYPE scrtext_l,
          END OF ty_field.

  DATA: lv_afstt    TYPE zmm_ft_tstat,
        lv_chgnr    TYPE i,
        lv_chgn2    TYPE cdchangenr,
        lv_compt    TYPE i,
        lv_count    TYPE i,
        lv_iobjc    TYPE inri-object VALUE 'ZMM_CHGNR',
        lv_meins    TYPE meins,
        lv_matmp    TYPE matnr,
        lv_matnr    TYPE matnr,
        lv_modif    TYPE xfeld,
        lv_newvl    TYPE string,
        lv_numbr    TYPE i,
        lv_numb2    TYPE i,
        lv_numb3    TYPE string,
        lv_objid    TYPE saeobjid,
        lv_objct    TYPE saeanwdid,
        lv_oldvl    TYPE string,
        lv_range    TYPE inri-nrrangenr VALUE '01',
        lv_sokey    TYPE zft_gw_sokey,
        lv_stats    TYPE zft_gw_stats,
        lv_statt    TYPE zmm_ft_tstat,
        lv_stchg    TYPE xfeld,
        lv_subrc    TYPE i,
        ls_afdef    TYPE zmm_af_def,
        ls_afdf2    TYPE zmm_af_def,
        ls_afsrc    TYPE zmm_af_src,
        ls_afsr2    TYPE zmm_af_src,
        ls_afsr3    TYPE zmm_af_src,
        ls_alert    TYPE ty_alert,
        ls_arcob    TYPE zao_s_toauri,
        ls_dmntx    TYPE dd07v,
        ls_dpacl    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>ts_deep_article,
        ls_field    TYPE ty_field,
        ls_files    TYPE /iwbep/s_cod_select_option,
        ls_ftalt    TYPE zmm_ft_alt,
        ls_ftal2    TYPE zmm_ft_alt,
        ls_histo    TYPE zmm_history,
        ls_image    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>ts_image,
        ls_imfil    TYPE /iwbep/s_cod_select_option,
        ls_imgdt    TYPE zmm_ar_imgdt,
        ls_notif    TYPE zmm_ft_notificat,
        ls_retrn    TYPE bapiret2,
        ls_rsttb    TYPE zft_s_recipe_result,
        ls_sfile    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>ts_file,
        ls_sofil    TYPE /iwbep/s_cod_select_option,
        ls_srcfl    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>ts_srcfile,
        ls_teina    TYPE eina,
        ls_tmara    TYPE mara,
        lt_afsrc    TYPE TABLE OF zmm_af_src,
        lt_afsr2    TYPE TABLE OF zmm_af_src,
        lt_afsr3    TYPE TABLE OF zmm_af_src,
        lt_arcob    TYPE zao_t_toauri,
        lt_alert    TYPE TABLE OF ty_alert,
        lt_dmntt    TYPE TABLE OF dd07v,
        lt_dmntx    TYPE TABLE OF dd07v,
        lt_field    TYPE TABLE OF ty_field,
        lt_files    TYPE /iwbep/t_cod_select_options,
        lt_ftalt    TYPE TABLE OF zmm_ft_alt,
        lt_ftal2    TYPE TABLE OF zmm_ft_alt,
        lt_histo    TYPE TABLE OF zmm_history,
        lt_image    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>tt_image,
        lt_imfil    TYPE /iwbep/t_cod_select_options,
        lt_retrn    TYPE bapiret2_t,
        lt_rsttb    TYPE zft_t_recipe_result,
        lt_sofil    TYPE /iwbep/t_cod_select_options,
        lt_srcfl    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>tt_srcfile,
        lt_teina    TYPE TABLE OF eina,
        lt_tfile    TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>tt_file,
        lr_rdata    TYPE REF TO data.

  FIELD-SYMBOLS:  <dpacl>   TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>ts_deep_article.

  CREATE DATA lr_rdata TYPE zcl_zft_gw_cat_mat1ere_mpc_ext=>ts_deep_article.
  ASSIGN lr_rdata->* TO <dpacl>.
* Get Data
  io_data_provider->read_entry_data( IMPORTING es_data  = <dpacl> ).
  MOVE-CORRESPONDING <dpacl> TO ls_dpacl.

*** Check data consistency ****************************************** BEG *
  IF <dpacl>-matnr IS INITIAL OR strlen( <dpacl>-matnr ) GE 19.
    ls_retrn-type                 = 'E'.
    ls_retrn-id                   = 'ZMM'.
    ls_retrn-number               = '153'.

    me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                     iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                     iv_add_to_response_header = abap_true
                                                                     iv_message_target         = 'E' ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ENDIF.

  IF <dpacl>-matnr CS 'AF'.
    IF <dpacl>-meins IS INITIAL OR strlen( <dpacl>-meins ) GE 4 OR <dpacl>-meins CS '***'.
      ls_retrn-type                 = 'E'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '154'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
*    IF <dpacl>-acnum IS INITIAL.
*      ls_retrn-type                 = 'E'.
*      ls_retrn-id                   = 'ZMM'.
*      ls_retrn-number               = '205'.
*
*      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
*                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
*                                                                       iv_add_to_response_header = abap_true
*                                                                       iv_message_target         = 'E' ).
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
*    ENDIF.
    IF <dpacl>-tarap IS INITIAL.
      ls_retrn-type                 = 'E'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '155'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF <dpacl>-maktx IS INITIAL OR strlen( <dpacl>-maktx ) GE 41.
      ls_retrn-type                 = 'E'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '156'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.

    MOVE-CORRESPONDING ls_dpacl-ar2sr TO lt_afsrc.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input                       = ls_dpacl-meins
        language                    = sy-langu
      IMPORTING
        output                      = lv_meins
      EXCEPTIONS
        OTHERS                      = 1.

    IF sy-subrc EQ 0.
      ls_dpacl-meins                = lv_meins.
    ENDIF.


    LOOP AT lt_afsrc INTO ls_afsrc.
      IF ls_afsrc-matnr IS INITIAL OR strlen( ls_afsrc-matnr ) GE 19.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '157'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.
      IF ( ls_afsrc-mfrnm IS INITIAL AND ls_afsrc-mfrnr IS INITIAL AND ls_afsrc-stats NE '10' AND ls_afsrc-stats NE '20' ) OR strlen( ls_afsrc-mfrnr ) GE 11 OR strlen( ls_afsrc-mfrnm ) GE 31.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '158'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.

*     Check consistency for status 30
      IF ls_afsrc-stats EQ '30'
        AND ( ls_afsrc-distb IS INITIAL
        OR  ( ls_afsrc-mfrnr IS INITIAL AND ls_afsrc-mfrnm IS INITIAL )
        OR    ls_afsrc-maktx IS INITIAL
        OR    ls_afsrc-tempb IS INITIAL
        OR    ls_afsrc-kbetr IS INITIAL
        OR    ls_afsrc-meins IS INITIAL
        OR    ls_afsrc-dcdtd IS INITIAL ).

        ls_retrn-type             = 'E'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '225'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                           iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                           iv_add_to_response_header = abap_true
                                                                           iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.

*     Error if sourcing unit of measure <> base unit
      IF ls_afsrc-meins NE <dpacl>-meins.

        ls_retrn-type             = 'E'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '227'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.

      ENDIF.

      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name                 = 'ZMM_FT_VH_STATS'
          langu                       = sy-langu
          prid                        = 0
          withtext                    = 'X'
        TABLES
          dd07v_tab_a                 = lt_dmntx
          dd07v_tab_n                 = lt_dmntt.

      IF ls_afsrc-stats IS INITIAL.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '164'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ELSE.
        CLEAR lv_stats.
        SELECT SINGLE stats
        INTO lv_stats
        FROM zmm_af_src
        WHERE matnr EQ ls_afsrc-matnr
        AND   sokey EQ ls_afsrc-sokey.

        IF lv_stats NE ls_afsrc-stats.
          READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = ls_afsrc-stats.
          IF sy-subrc EQ 0.
            lv_afstt           = ls_dmntx-ddtext.
          ENDIF.

          READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = lv_stats.
          IF sy-subrc EQ 0.
            lv_statt           = ls_dmntx-ddtext.
          ENDIF.
          IF sy-subrc EQ 0 AND lv_stats IS NOT INITIAL AND lv_stats NE ls_afsrc-stats.

*           S'il y a eu changement de statut
            lv_stchg              = 'X'.

            IF ( lv_stats EQ '20' AND ( ls_afsrc-stats NE '30' AND ls_afsrc-stats NE '50' AND  ls_afsrc-stats NE '60'  ) )
              OR ( lv_stats EQ '30' AND ( ls_afsrc-stats NE '40' AND ls_afsrc-stats NE '50' AND ls_afsrc-stats NE '60' ) ).

              ls_retrn-type         = 'E'.
              ls_retrn-id           = 'ZMM'.
              ls_retrn-number       = '207'.
              ls_retrn-message_v1   = ls_afsrc-distt.
              ls_retrn-message_v2   = lv_afstt.
              ls_retrn-message_v3   = lv_statt.

              me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                               iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                               iv_add_to_response_header = abap_true
                                                                               iv_message_target         = 'E' ).
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.

            ELSEIF ( ls_afsrc-stats EQ '90' AND <dpacl>-rmatn IS INITIAL ).

                  ls_retrn-type       = 'E'.
                  ls_retrn-id         = 'ZMM'.
                  ls_retrn-number     = '208'.
                  ls_retrn-message_v1 = ls_afsrc-distt.
                  ls_retrn-message_v2 = lv_afstt.

                  me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                                   iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                                   iv_add_to_response_header = abap_true
                                                                                   iv_message_target         = 'E' ).
                  RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.

                ELSEIF ( ls_afsrc-stats EQ '100' AND ( <dpacl>-rmatn IS INITIAL OR ls_afsrc-rmatn IS INITIAL ) ).

                      ls_retrn-type       = 'E'.
                      ls_retrn-id         = 'ZMM'.
                      ls_retrn-number     = '209'.
                      ls_retrn-message_v1 = ls_afsrc-distt.
                      ls_retrn-message_v2 = lv_afstt.

                      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                                       iv_add_to_response_header = abap_true
                                                                                       iv_message_target         = 'E' ).
                      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.

            ENDIF.

          ENDIF.



        ENDIF.
      ENDIF.
      IF ls_afsrc-rmatn IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input                   = ls_afsrc-rmatn
          IMPORTING
            output                  = ls_afsrc-rmatn.

        SELECT COUNT( * )
        INTO lv_count
        FROM zmm_af_src
        WHERE rmatn EQ ls_afsrc-rmatn
        AND   sokey NE ls_afsrc-sokey.

        IF sy-subrc EQ 0 OR lv_count IS NOT INITIAL.
          ls_retrn-type             = 'E'.
          ls_retrn-id               = 'ZMM'.
          ls_retrn-number           = '140'.
          ls_retrn-message_v1       = ls_afsrc-rmatn.

          me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                           iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                           iv_add_to_response_header = abap_true
                                                                           iv_message_target         = 'E' ).
*          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
        ENDIF.

        SELECT COUNT( * )
        INTO lv_count
        FROM mara
        WHERE attyp EQ '02'
        AND   bflme EQ '3'
        AND   matnr EQ ls_afsrc-rmatn.

        IF sy-subrc NE 0 OR lv_count IS INITIAL.
          ls_retrn-type             = 'E'.
          ls_retrn-id               = 'ZMM'.
          ls_retrn-number           = '161'.
          ls_retrn-message_v1       = ls_afsrc-rmatn.

          me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                           iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                           iv_add_to_response_header = abap_true
                                                                           iv_message_target         = 'E' ).
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  MOVE-CORRESPONDING ls_dpacl-ar2im TO lt_image.
  LOOP AT lt_image INTO ls_image.
    IF ls_image-objnr IS INITIAL OR strlen( ls_image-objnr ) GE 19.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '149'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF ls_image-objtp IS INITIAL OR strlen( ls_image-objtp ) GE 2 OR NOT ls_image-objtp CO 'CIFS'.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '150'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF ls_image-descr IS INITIAL OR strlen( ls_image-descr ) GE 129.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '151'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    IF ls_image-fisrc IS INITIAL OR strlen( ls_image-fisrc ) GE 4097.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '152'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    ls_imfil-sign                 = 'I'.
    ls_imfil-option               = 'EQ'.
    ls_imfil-low                  = ls_image-arcid.
    APPEND ls_imfil TO lt_imfil.
  ENDLOOP.
  MOVE-CORRESPONDING ls_dpacl-ar2fl TO lt_tfile.
  LOOP AT lt_tfile INTO ls_sfile.
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
    IF ls_sfile-fisrc IS INITIAL OR strlen( ls_sfile-fisrc ) GE 4097.
      ls_retrn-type               = 'E'.
      ls_retrn-id                 = 'ZMM'.
      ls_retrn-number             = '152'.

      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ENDIF.
    ls_files-sign                 = 'I'.
    ls_files-option               = 'EQ'.
    ls_files-low                  = ls_sfile-arcid.
    APPEND ls_files TO lt_files.
  ENDLOOP.

*  IF <dpacl>-matnr CS 'AF'.
    MOVE-CORRESPONDING ls_dpacl-ar2sf TO lt_srcfl.
    LOOP AT lt_srcfl INTO ls_srcfl.
      IF ls_srcfl-objnr IS INITIAL OR strlen( ls_srcfl-objnr ) GE 19.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '149'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.
      IF ls_srcfl-objtp IS INITIAL OR strlen( ls_srcfl-objtp ) GE 2 OR NOT ls_srcfl-objtp CO 'CIFS'.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '150'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.
      IF ls_srcfl-descr IS INITIAL OR strlen( ls_srcfl-descr ) GE 129.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '151'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.
      IF ls_srcfl-fisrc IS INITIAL OR strlen( ls_srcfl-fisrc ) GE 4097.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '152'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.
      IF ls_srcfl-mfrnr IS INITIAL OR strlen( ls_srcfl-mfrnr ) GE 11.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '160'.

        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'E' ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
      ENDIF.
      ls_sofil-sign                 = 'I'.
      ls_sofil-option               = 'EQ'.
      ls_sofil-low                  = ls_srcfl-arcid.
      APPEND ls_sofil TO lt_sofil.
    ENDLOOP.
*  ENDIF.
*** Check data consistency ****************************************** END *

  IF <dpacl>-matnr CS 'AF'.
*   Save Definition
    MOVE-CORRESPONDING <dpacl> TO ls_dpacl.
    MOVE-CORRESPONDING ls_dpacl TO ls_afdef.
    ls_afdef-laeda                  = sy-datum.
    ls_afdef-aenam                  = sy-uname.
    ls_afdef-maktg                  = ls_afdef-maktx.
    TRANSLATE ls_afdef-maktg TO UPPER CASE.
    LOOP AT lt_image INTO ls_image.
      IF ls_image-fmain EQ abap_true.
        ls_afdef-arcid              = ls_image-arcid.
      ENDIF.
    ENDLOOP.

*   Save histo *******************************************************
    SELECT  SINGLE *
    INTO    CORRESPONDING FIELDS OF ls_afdf2
    FROM    zmm_af_def
    WHERE   matnr EQ <dpacl>-matnr.

    SELECT  fieldname tabname scrtext_l
    INTO    CORRESPONDING FIELDS OF TABLE lt_field
    FROM    dd03l AS l
    INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
    WHERE   l~tabname EQ 'ZMM_AF_DEF'
    AND     t~ddlanguage EQ sy-langu.

    ls_histo-appnm                = 'I'.
    ls_histo-chngt                = 'U'.
    ls_histo-tbnam                = 'ZMM_AF_DEF'.
    ls_histo-descr                = <dpacl>-maktx.
    ls_histo-prnum                = <dpacl>-matnr.
    ls_histo-udate                = sy-datum.
    ls_histo-usern                = sy-uname.
    ls_histo-utime                = sy-uzeit.

    IF ls_afdf2-meins NE <dpacl>-meins.
      ls_histo-fname              = 'MEINS'.
      ls_histo-oldvl              = ls_afdf2-meins.
      ls_histo-newvl              = <dpacl>-meins.

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

    IF ls_afdf2-mhdrz NE <dpacl>-mhdrz.
      ls_histo-fname              = 'MHDRZ'.
      ls_histo-oldvl              = ls_afdf2-mhdrz.
      ls_histo-newvl              = <dpacl>-mhdrz.

      MOVE ls_afdf2-mhdrz TO lv_oldvl.
      MOVE <dpacl>-mhdrz TO lv_newvl.

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

    IF ls_afdf2-maktx NE <dpacl>-maktx.
      ls_histo-fname              = 'MAKTX'.
      ls_histo-oldvl              = ls_afdf2-maktx.
      ls_histo-newvl              = <dpacl>-maktx.

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

    IF ls_afdf2-wwghb NE <dpacl>-wwghb.
      ls_histo-fname              = 'WWGHB'.
      ls_histo-oldvl              = ls_afdf2-wwghb.
      ls_histo-newvl              = <dpacl>-wwghb.

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

    IF ls_afdf2-atwtb NE <dpacl>-atwtb.
      ls_histo-fname              = 'ATWTB'.
      ls_histo-oldvl              = ls_afdf2-atwtb.
      ls_histo-newvl              = <dpacl>-atwtb.

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

    IF ls_afdf2-atwrt NE <dpacl>-atwrt.
      ls_histo-fname              = 'ATWRT'.
      ls_histo-oldvl              = ls_afdf2-atwrt.
      ls_histo-newvl              = <dpacl>-atwrt.

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

    IF ls_afdf2-actif NE <dpacl>-actif.
      ls_histo-fname              = 'ACTIF'.
      ls_histo-oldvl              = ls_afdf2-actif.
      ls_histo-newvl              = <dpacl>-actif.

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

    IF ls_afdf2-fictf NE <dpacl>-fictf.
      ls_histo-fname              = 'FICTF'.
      ls_histo-oldvl              = ls_afdf2-fictf.
      ls_histo-newvl              = <dpacl>-fictf.

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

    IF ls_afdf2-werks NE <dpacl>-werks.
      ls_histo-fname              = 'WERKS'.
      ls_histo-oldvl              = ls_afdf2-werks.
      ls_histo-newvl              = <dpacl>-werks.

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

    IF ls_afdf2-tarap NE <dpacl>-tarap.
      ls_histo-fname              = 'TARAP'.

      MOVE ls_afdf2-tarap TO lv_oldvl. "ls_histo-oldvl.
      MOVE <dpacl>-tarap TO lv_newvl. "ls_histo-newvl.

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

    IF ls_afdf2-waers NE <dpacl>-waers.
      ls_histo-fname              = 'WAERS'.
      ls_histo-oldvl              = ls_afdf2-waers.
      ls_histo-newvl              = <dpacl>-waers.

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

    IF ls_afdf2-descp NE <dpacl>-descp.
      ls_histo-fname              = 'DESCP'.
      ls_histo-oldvl              = ls_afdf2-descp.
      ls_histo-newvl              = <dpacl>-descp.

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

    IF ls_afdf2-rfmat NE <dpacl>-rfmat.
      ls_histo-fname              = 'RFMAT'.
      ls_histo-oldvl              = ls_afdf2-rfmat.
      ls_histo-newvl              = <dpacl>-rfmat.

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

    IF ls_afdf2-arcid NE <dpacl>-arcid.
      ls_histo-fname              = 'ARCID'.
      ls_histo-oldvl              = ls_afdf2-arcid.
      ls_histo-newvl              = <dpacl>-arcid.

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

    IF ls_afdf2-ctnum NE <dpacl>-ctnum.
      ls_histo-fname              = 'CTNUM'.
      ls_histo-oldvl              = ls_afdf2-ctnum.
      ls_histo-newvl              = <dpacl>-ctnum.

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

    MODIFY zmm_af_def FROM ls_afdef.

    IF sy-subrc NE 0.
      ls_retrn-type                 = 'E'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '120'.
      ls_retrn-message_v1           = ls_afdef-matnr.
      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
    ELSE.
      ls_retrn-type                 = 'S'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '113'.
      ls_retrn-message_v1           = ls_afdef-matnr.
      me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'S' ).

      INSERT zmm_history FROM TABLE lt_histo.

    ENDIF.

*   End Save histo *****************************************

*   Save sourcing data
    MOVE-CORRESPONDING ls_dpacl-ar2sr TO lt_afsrc.

    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_afsr2
    FROM zmm_af_src
    WHERE matnr EQ ls_afdef-matnr.

    SELECT  fieldname tabname scrtext_l
    INTO    CORRESPONDING FIELDS OF TABLE lt_field
    FROM    dd03l AS l
    INNER   JOIN dd04t AS t ON t~rollname EQ l~rollname
    WHERE   l~tabname EQ 'ZMM_AF_SRC'
    AND     t~ddlanguage EQ sy-langu.

    ls_histo-tbnam                = 'ZMM_AF_SRC'.
    ls_histo-udate                = sy-datum.
    ls_histo-usern                = sy-uname.
    ls_histo-utime                = sy-uzeit.

    LOOP AT lt_afsrc INTO ls_afsrc.
      IF ls_afsrc-sokey IS INITIAL.
        SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_afsr3
        FROM zmm_af_src
        WHERE matnr EQ ls_afdef-matnr.

        IF sy-subrc NE 0.
          lv_numbr                 = 1.
        ELSE.
          LOOP AT lt_afsr3 INTO ls_afsr3.
            SPLIT ls_afsr3-sokey AT '-' INTO lv_matmp
                                             lv_numb3.
            lv_numb2                = lv_numb3.
            IF lv_numb2 GT lv_numbr.
              lv_numbr              = lv_numb2.
            ENDIF.
          ENDLOOP.
          ADD 1 TO lv_numbr.
        ENDIF.
        lv_numb3                    = lv_numbr.
        CONCATENATE ls_afdef-matnr '-' lv_numb3 INTO ls_afsrc-sokey.
      ENDIF.
      IF ls_afsrc-matnr IS INITIAL.
        ls_afsrc-matnr              = ls_afdef-matnr.
      ENDIF.
      READ TABLE lt_afsr2  INTO ls_afsr2 WITH KEY sokey = ls_afsrc-sokey.
      IF sy-subrc NE 0.
        IF ls_afsrc-stats EQ '20'.
          ls_alert-descr            = ls_afdef-maktx.
          ls_alert-matnr            = ls_afdef-matnr.
          ls_alert-evtid            = 'MP02'.
          APPEND ls_alert TO lt_alert.
        ENDIF.
        IF ls_afsrc-rmatn IS NOT INITIAL.

          ls_afsrc-stats            = '80'.
          ls_alert-evtid            = 'MP08'.
          ls_alert-matnr            = ls_afsrc-matnr.
          ls_alert-descr            = ls_afdef-maktx.
          ls_alert-rmatn            = ls_afsrc-rmatn.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input                 = ls_afsrc-rmatn
            IMPORTING
              output                = ls_afsrc-rmatn.

          CALL FUNCTION 'ZMM_FT_RECIPE_MNGMT'
            EXPORTING
              iv_matnr              = ls_afsrc-matnr
              iv_rmatn              = ls_afsrc-rmatn
              iv_sokey              = ls_afsrc-sokey
            TABLES
              recette_tab           = ls_alert-rcttb
              result_tab            = lt_rsttb
           EXCEPTIONS
             no_data_found          = 1
             OTHERS                 = 2.

          IF sy-subrc <> 0 OR lt_rsttb[] IS NOT INITIAL.
            LOOP AT lt_rsttb INTO ls_rsttb.
              ls_retrn-type         = 'W'.
              ls_retrn-id           = 'ZMM'.
              ls_retrn-number       = ls_rsttb-msgnb.
              ls_retrn-message_v1   = ls_rsttb-srnum.
              ls_retrn-message_v2   = ls_rsttb-matnr.
              me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                                iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                                iv_add_to_response_header = abap_true
                                                                                iv_message_target         = 'W' ).
            ENDLOOP.
          ELSE.
            SORT ls_alert-rcttb BY frnum.
            DELETE ADJACENT DUPLICATES FROM ls_alert-rcttb.
            APPEND ls_alert TO lt_alert.
          ENDIF.
        ENDIF.
      ELSE.
        IF ls_afsrc-rmatn NE ls_afsr2-rmatn AND ls_afsrc-rmatn IS NOT INITIAL.

          ls_afsrc-stats            = '80'.
          ls_alert-evtid            = 'MP08'.
          ls_alert-matnr            = ls_afdef-matnr.
          ls_alert-descr            = ls_afdef-maktx.
          ls_alert-rmatn            = ls_afsrc-rmatn.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input                 = ls_afsrc-rmatn
            IMPORTING
              output                = ls_afsrc-rmatn.

*         Check appro code base unit
          CALL FUNCTION 'MARA_SINGLE_READ'
            EXPORTING
              matnr               = ls_afsrc-rmatn
            IMPORTING
              wmara               = ls_tmara.

          IF sy-subrc NE 0 OR ls_tmara-meins NE ls_afsrc-meins.

            ls_retrn-type         = 'E'.
            ls_retrn-id           = 'ZMM'.
            ls_retrn-number       = '236'.

            me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                             iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                             iv_add_to_response_header = abap_true
                                                                             iv_message_target         = 'E' ).
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.

          ENDIF.

          CALL FUNCTION 'ZMM_FT_RECIPE_MNGMT'
            EXPORTING
              iv_matnr              = ls_afsrc-matnr
              iv_rmatn              = ls_afsrc-rmatn
              iv_sokey              = ls_afsrc-sokey
            TABLES
              recette_tab           = ls_alert-rcttb
              result_tab            = lt_rsttb
           EXCEPTIONS
             no_data_found          = 1
             OTHERS                 = 2.
          IF sy-subrc <> 0 OR lt_rsttb[] IS NOT INITIAL.
            LOOP AT lt_rsttb INTO ls_rsttb.
              ls_retrn-type         = 'W'.
              ls_retrn-id           = 'ZMM'.
              ls_retrn-number       = ls_rsttb-msgnb.
              ls_retrn-message_v1   = ls_rsttb-srnum.
              ls_retrn-message_v2   = ls_rsttb-matnr.
              me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                                iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                                iv_add_to_response_header = abap_true
                                                                                iv_message_target         = 'W' ).
            ENDLOOP.
          ELSE.
            SORT ls_alert-rcttb BY frnum.
            DELETE ADJACENT DUPLICATES FROM ls_alert-rcttb.
            APPEND ls_alert TO lt_alert.
          ENDIF.
        ENDIF.
        IF ls_afsrc-kbetr NE ls_afsr2-kbetr.
          ls_alert-evtid            = 'MP12'.
          ls_alert-descr            = ls_afdef-maktx.
          ls_alert-matnr            = ls_afdef-matnr.
          ls_alert-kbetn            = ls_afsrc-kbetr.
          ls_alert-kbeto            = ls_afsr2-kbetr.

          SELECT d~srnum AS frnum, d~titre AS descr
          INTO CORRESPONDING FIELDS OF TABLE @ls_alert-rcttb
          FROM zmm_sr_def AS d
          INNER JOIN zmm_sr_ing AS i ON d~srnum EQ i~srnum
          WHERE i~sring EQ @ls_afsrc-matnr.

          SORT ls_alert-rcttb BY frnum.
          DELETE ADJACENT DUPLICATES FROM ls_alert-rcttb COMPARING frnum.

          APPEND ls_alert TO lt_alert.
        ENDIF.
        IF ls_afsrc-stats NE ls_afsr2-stats.
          ls_alert-descr            = ls_afdef-maktx.
          ls_alert-matnr            = ls_afdef-matnr.
          CASE ls_afsrc-stats.
            WHEN '20'.
              ls_alert-evtid        = 'MP02'.
              APPEND ls_alert TO lt_alert.
            WHEN '30'.
              ls_alert-evtid        = 'MP03'.
              APPEND ls_alert TO lt_alert.
            WHEN '40'.
              ls_alert-evtid        = 'MP04'.
              APPEND ls_alert TO lt_alert.
            WHEN '50'.
              ls_alert-evtid        = 'MP05'.
              APPEND ls_alert TO lt_alert.
            WHEN '60'.
              ls_alert-evtid        = 'MP06'.
              APPEND ls_alert TO lt_alert.
            WHEN '70'.
              ls_alert-evtid        = 'MP07'.
              APPEND ls_alert TO lt_alert.
            WHEN '80'.
              IF ls_afsrc-rmatn IS INITIAL.
                ls_retrn-type               = 'E'.
                ls_retrn-id                 = 'ZMM'.
                ls_retrn-number             = '137'.
                ls_retrn-message_v1         = ls_afdef-matnr.
                me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                                 iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                                 iv_add_to_response_header = abap_true
                                                                                 iv_message_target         = 'E' ).
                CONTINUE.
              ENDIF.
              ls_alert-evtid        = 'MP08'.
              ls_alert-rmatn        = ls_afsrc-rmatn.
              APPEND ls_alert TO lt_alert.
            WHEN '90'.
              ls_alert-evtid        = 'MP09'.
              APPEND ls_alert TO lt_alert.
            WHEN '100'.
              ls_alert-evtid        = 'MP10'.
              APPEND ls_alert TO lt_alert.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.

      IF    ls_afsrc-stats EQ '20' AND ls_afsrc-distb IS NOT INITIAL
        AND ( ls_afsrc-mfrnr IS NOT INITIAL OR ls_afsrc-mfrnm IS NOT INITIAL )
        AND ls_afsrc-maktx IS NOT INITIAL
        AND ls_afsrc-tempb IS NOT INITIAL
        AND ls_afsrc-kbetr IS NOT INITIAL
        AND ls_afsrc-meins IS NOT INITIAL
        AND ls_afsrc-dcdtd IS NOT INITIAL.

        ls_afsrc-stats            = '30'.
        ls_alert-evtid            = 'MP03'.
        ls_alert-descr            = ls_afdef-maktx.
        ls_alert-matnr            = ls_afdef-matnr.
        APPEND ls_alert TO lt_alert.
      ENDIF.

*     Save History *****************************************

      CLEAR:  lv_chgnr,
              lv_chgn2,
              lt_histo.

      ls_histo-appnm              = 'I'.
      ls_histo-descr              = ls_afsrc-maktx.
      ls_histo-prnum              = ls_afsrc-sokey.
      CLEAR ls_histo-evtid.

      READ TABLE lt_afsr2 INTO ls_afsr2 WITH KEY sokey = ls_afsrc-sokey matnr = ls_afsrc-matnr.

      IF sy-subrc NE 0.

        ls_histo-chngt            = 'I'.
        ls_histo-fname            = 'SOKEY'.
        ls_histo-newvl            = ls_afsrc-sokey.

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

        IF ls_afsr2-mfrnr NE ls_afsrc-mfrnr.
          ls_histo-fname          = 'MFRNR'.
          ls_histo-oldvl          = ls_afsr2-mfrnr.
          ls_histo-newvl          = ls_afsrc-mfrnr.

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

        IF ls_afsr2-distb NE ls_afsrc-distb.
          ls_histo-fname          = 'DISTB'.
          ls_histo-oldvl          = ls_afsr2-distb.
          ls_histo-newvl          = ls_afsrc-distb.

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

        IF ls_afsr2-tempb NE ls_afsrc-tempb.
          ls_histo-fname          = 'TEMPB'.
          ls_histo-oldvl          = ls_afsr2-tempb.
          ls_histo-newvl          = ls_afsrc-tempb.

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

        IF ls_afsr2-ntgew NE ls_afsrc-ntgew.
          ls_histo-fname          = 'NTGEW'.
          ls_histo-oldvl          = ls_afsr2-ntgew.
          ls_histo-newvl          = ls_afsrc-ntgew.

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

        IF ls_afsr2-vlcrn NE ls_afsrc-vlcrn.
          ls_histo-fname          = 'VLCRN'.
          ls_histo-oldvl          = ls_afsr2-vlcrn.
          ls_histo-newvl          = ls_afsrc-vlcrn.

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

        IF ls_afsr2-kbetr NE ls_afsrc-kbetr.
          ls_histo-fname          = 'KBETR'.
          MOVE ls_afsr2-kbetr TO lv_oldvl.
          MOVE ls_afsrc-kbetr TO lv_newvl.

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

        IF ls_afsr2-meins NE ls_afsrc-meins.
          ls_histo-fname          = 'MEINS'.
          ls_histo-oldvl          = ls_afsr2-meins.
          ls_histo-newvl          = ls_afsrc-meins.

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

        IF ls_afsr2-stext NE ls_afsrc-stext.
          ls_histo-fname          = 'STEXT'.
          ls_histo-oldvl          = ls_afsr2-stext.
          ls_histo-newvl          = ls_afsrc-stext.

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

        IF ls_afsr2-stats NE ls_afsrc-stats.
          ls_histo-fname          = 'STATS'.
          ls_histo-oldvl          = ls_afsr2-stats.
          ls_histo-newvl          = ls_afsrc-stats.

          CASE ls_histo-newvl.
            WHEN '20'.
              ls_histo-evtid      = 'MP02'.
            WHEN '30'.
              ls_histo-evtid      = 'MP03'.
            WHEN '40'.
              ls_histo-evtid      = 'MP04'.
            WHEN '50'.
              ls_histo-evtid      = 'MP05'.
            WHEN '70'.
              ls_histo-evtid      = 'MP07'.
            WHEN '80'.
              ls_histo-evtid      = 'MP08'.
          ENDCASE.

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

        IF ls_afsr2-recip NE ls_afsrc-recip.
          ls_histo-fname          = 'RECIP'.
          ls_histo-oldvl          = ls_afsr2-recip.
          ls_histo-newvl          = ls_afsrc-recip.

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

        IF ls_afsr2-rmatn NE ls_afsrc-rmatn.
          ls_histo-fname          = 'RMATN'.
          ls_histo-oldvl          = ls_afsr2-rmatn.
          ls_histo-newvl          = ls_afsrc-rmatn.

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

        IF ls_afsr2-dcdtd NE ls_afsrc-dcdtd.
          ls_histo-fname          = 'DCDTD'.
          ls_histo-oldvl          = ls_afsr2-dcdtd.
          ls_histo-newvl          = ls_afsrc-dcdtd.

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

        IF ls_afsr2-waers NE ls_afsrc-waers.
          ls_histo-fname          = 'WAERS'.
          ls_histo-oldvl          = ls_afsr2-waers.
          ls_histo-newvl          = ls_afsrc-waers.

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

        IF ls_afsr2-maktx NE ls_afsrc-maktx.
          ls_histo-fname          = 'MAKTX'.
          ls_histo-oldvl          = ls_afsr2-maktx.
          ls_histo-newvl          = ls_afsrc-maktx.

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

        IF ls_afsr2-tarap NE ls_afsrc-tarap.
          ls_histo-fname          = 'TARAP'.

          MOVE ls_afsr2-tarap TO lv_oldvl.
          MOVE ls_afsrc-tarap TO lv_newvl.

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

      ENDIF.

*     End Save history **************************************

      MODIFY zmm_af_src FROM ls_afsrc.
      IF sy-subrc EQ 0.
*        ls_retrn-type               = 'S'.
*        ls_retrn-id                 = 'ZMM'.
*        ls_retrn-number             = '118'.
*        ls_retrn-message_v1         = ls_afdef-matnr.
*        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
*                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
*                                                                       iv_add_to_response_header = abap_true
*                                                                       iv_message_target         = 'S' ).

        IF lv_stchg IS NOT INITIAL.

          ls_retrn-type           = 'S'.
          ls_retrn-id             = 'ZMM'.
          ls_retrn-number         = '226'.
          ls_retrn-message_v1     = ls_afdef-matnr.
          me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                         iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                         iv_add_to_response_header = abap_true
                                                                         iv_message_target         = 'S' ).

        ENDIF.

        INSERT zmm_history FROM TABLE lt_histo.

      ELSE.
        ls_retrn-type               = 'E'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '117'.
        ls_retrn-message_v1         = ls_afdef-matnr.
        me->mo_context->get_message_container( )->add_message_from_bapi( is_bapi_message           = ls_retrn
                                                                       iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                       iv_add_to_response_header = abap_true
                                                                       iv_message_target         = 'E' ).
        lv_subrc                    = 1.
      ENDIF.
    ENDLOOP.
**********************************************************************
    DATA: lv_nwsky          TYPE zft_gw_sokey.
    lv_nwsky                      = me->check_src_abouti( EXPORTING iv_afnum = ls_afdef-matnr ).

**********************************************************************

  ELSE.

    ls_imgdt-matnr                = <dpacl>-matnr.
    LOOP AT lt_image INTO ls_image.
      IF ls_image-fmain EQ abap_true.
        ls_imgdt-arcid            = ls_image-arcid.
      ENDIF.
    ENDLOOP.

    MODIFY zmm_ar_imgdt FROM ls_imgdt.

  ENDIF.
* Delete AR2IM
  lv_matnr                        = <dpacl>-matnr.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input                       = lv_matnr
    IMPORTING
      output                      = lv_matnr.

  CLEAR: lt_arcob, ls_arcob.
  lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_article.
*  lv_objid                      = <dpacl>-matnr.
  lv_objid                      = lv_matnr.

  CALL FUNCTION 'ZAO_DOCUMENT_GET'
    EXPORTING
      iv_objct                  = lv_objct
      iv_objid                  = lv_objid
    IMPORTING
      et_arcob                  = lt_arcob
    EXCEPTIONS
      OTHERS                    = 1.

  IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
    IF lt_imfil[] IS NOT INITIAL.
      DELETE lt_arcob WHERE arc_doc_id IN lt_imfil.
    ENDIF.
    DELETE lt_arcob WHERE NOT mimetype CS 'IMAGE'.

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
        ls_retrn-message_v1       = lv_objid.
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

* Delete AR2FL

*  lv_matnr                        = <dpacl>-matnr.
*
*  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
*    EXPORTING
*      input                       = lv_matnr
*    IMPORTING
*      output                      = lv_matnr.

  lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_article.
*  lv_objid                      = <dpacl>-matnr.
  lv_objid                      = lv_matnr.
  CLEAR: lt_arcob, ls_arcob.

  CALL FUNCTION 'ZAO_DOCUMENT_GET'
    EXPORTING
      iv_objct                  = lv_objct
      iv_objid                  = lv_objid
    IMPORTING
      et_arcob                  = lt_arcob
    EXCEPTIONS
      OTHERS                    = 1.

  IF lt_arcob[] IS NOT INITIAL AND sy-subrc EQ 0.
    IF lt_files[] IS NOT INITIAL.
      DELETE lt_arcob WHERE arc_doc_id IN lt_files.
    ENDIF.
    DELETE lt_arcob WHERE mimetype CS 'IMAGE'.

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
        ls_retrn-message_v1       = lv_objid.
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

* Delete AR2SF
* If AF
  IF <dpacl>-matnr CS 'AF'.
    lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_fourn.

    LOOP AT lt_afsr2 INTO ls_afsrc.
      CLEAR: lt_arcob, ls_arcob.

      lv_objid                    = ls_afsrc-sokey.
      CALL FUNCTION 'ZAO_DOCUMENT_GET'
        EXPORTING
          iv_objct                  = lv_objct
          iv_objid                  = lv_objid
        IMPORTING
          et_arcob                  = lt_arcob
        EXCEPTIONS
          OTHERS                    = 1.

      IF sy-subrc EQ 0.
        IF lt_sofil IS NOT INITIAL.
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
            ls_retrn-number           = '123'. "Erreur lors de la sauvegarde de la piece jointe &1 à l'article &2
            ls_retrn-message_v1       = ls_arcob-arc_doc_id.
            ls_retrn-message_v2       = ls_afdef-matnr.

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
    ENDLOOP.

* If AR
  ELSE.

    lv_objct                      = zcl_zft_gw_ft_utilities=>cv_content_fourn.

    CLEAR:  lt_arcob.

    SELECT  *
    INTO    CORRESPONDING FIELDS OF TABLE lt_teina
    FROM    eina  AS a
    WHERE   a~matnr   EQ <dpacl>-matnr
    AND     a~loekz   NE 'X'.

    LOOP AT lt_teina INTO ls_teina.
      CLEAR lv_objid.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input                   = ls_teina-lifnr
        IMPORTING
          output                  = ls_teina-lifnr.

      CONCATENATE lv_matnr '-' ls_teina-lifnr INTO lv_objid.

      CALL FUNCTION 'ZAO_DOCUMENT_GET'
        EXPORTING
          iv_objct                = lv_objct
          iv_objid                = lv_objid
        IMPORTING
          et_arcob                = lt_arcob
        EXCEPTIONS
          OTHERS                  = 1.

      IF sy-subrc EQ 0.
        IF lt_sofil IS NOT INITIAL.
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
            ls_retrn-number           = '123'. "Erreur lors de la sauvegarde de la piece jointe &1 à l'article &2
            ls_retrn-message_v1       = ls_arcob-arc_doc_id.
            ls_retrn-message_v2       = <dpacl>-matnr.

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
    ENDLOOP.



  ENDIF.
  IF lv_subrc NE 0.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.
  ELSE.
    SORT lt_alert BY evtid.
    DELETE ADJACENT DUPLICATES FROM lt_alert.
    LOOP AT lt_alert INTO ls_alert.
      CALL FUNCTION 'ZMM_FT_ALERT_MNGMT'
        EXPORTING
          iv_evtid                = ls_alert-evtid
          iv_descr                = ls_alert-descr
          iv_matnr                = ls_alert-matnr
          iv_kbetn                = ls_alert-kbetn
          iv_kbeto                = ls_alert-kbeto
          iv_rmatn                = ls_alert-rmatn
        TABLES
          recette_tab             = ls_alert-rcttb
        EXCEPTIONS
          param_missing           = 1
          send_mail_error         = 2
          mail_content            = 3
          unknown_event           = 4
          unknown_receiver        = 5
          OTHERS                  = 6
                .
      IF sy-subrc <> 0.
        ls_retrn-type             = 'W'.
        ls_retrn-id               = 'ZMM'.
        ls_retrn-number           = '136'.
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

*   Return Data
    er_deep_entity                = lr_rdata.
  ENDIF.

ENDMETHOD.