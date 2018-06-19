METHOD detailset_get_entityset.

  TYPES:  BEGIN OF tt_frdef.
            TYPES:  frnum TYPE zmm_ftnum,
                    descr TYPE zmm_ft_titre,
                    apdeb TYPE zmm_ft_apdeb,
                    apfin TYPE zmm_ft_apfin,
                    vkorg TYPE vkorg,
                    stats TYPE zmm_ft_stats,
                    famil TYPE matkl,
                    arcid TYPE saeardoid,
          END OF tt_frdef.

  DATA :  lv_arcid    TYPE saeardoid,
          lv_class    TYPE klasse_d,
          lv_clasf    TYPE klasse_d,
          lv_clasn    TYPE klasse_d,
          lv_ctnum    TYPE zft_gw_ctnum,
          lv_diffd    TYPE i,
          lv_drbis    TYPE vtbbewe-dberbis,
          lv_drvon    TYPE vtbbewe-dbervon,
          lv_objct    TYPE saeanwdid,
          lv_objid    TYPE saeobjid,
          lv_paths    TYPE localfile,
          ls_arcob    TYPE zao_s_toauri,
          ls_cadef    TYPE zmm_ca_def,
          ls_dmntx    TYPE dd07v,
          ls_filtr    TYPE /iwbep/s_mgw_select_option,
          ls_frdef    TYPE tt_frdef,
          ls_ftfil    TYPE zmm_ft_fil,
          ls_hiera    TYPE zmm_art_hierarch,
          ls_retrn    TYPE bapiret2,
          ls_selop    TYPE /iwbep/s_cod_select_option,
          ls_slist    TYPE bapi1003_tree,
          ls_smara    TYPE mara,
          ls_where    TYPE string,
          lt_arcob    TYPE zao_t_toauri,
          lt_caitm    TYPE zcl_zft_gw_ges_carte_mpc=>tt_detail,
          lt_class    TYPE /iwbep/t_cod_select_options,
          lt_ctnum    TYPE /iwbep/t_cod_select_options,
          lt_dmntt    TYPE TABLE OF dd07v,
          lt_dmntx    TYPE TABLE OF dd07v,
          lt_dmnt2    TYPE TABLE OF dd07v,
          lt_dmnt3    TYPE TABLE OF dd07v,
          lt_frnum    TYPE /iwbep/t_cod_select_options,
          lt_retrn    TYPE TABLE OF bapiret2,
          lt_slist    TYPE TABLE OF bapi1003_tree,
          lt_stats    TYPE /iwbep/t_cod_select_options,
          lt_where    TYPE TABLE OF string.

  FIELD-SYMBOLS <caitm> TYPE zcl_zft_gw_ges_carte_mpc=>ts_detail.

* Get CTNUM
  READ TABLE it_key_tab INTO DATA(ls_keytb) WITH KEY name = 'CTNUM'.
  IF sy-subrc EQ 0.
    lv_ctnum                      = ls_keytb-value.
    IF lv_ctnum IS NOT INITIAL.
      CONCATENATE 'ctnum EQ' 'lv_ctnum' INTO ls_where SEPARATED BY space.
      APPEND ls_where TO lt_where.
    ENDIF.
  ELSE.
    CLEAR : ls_filtr, ls_selop.
    LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'CTNUM'.
      LOOP AT ls_filtr-select_options INTO ls_selop.
        ls_selop-sign             = 'I'.
        IF ls_selop-low IS NOT INITIAL.
          TRANSLATE ls_selop-low TO UPPER CASE.
          APPEND ls_selop TO lt_ctnum.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    IF lt_ctnum IS NOT INITIAL.
      CONCATENATE 'ctnum IN' 'lt_ctnum' INTO ls_where SEPARATED BY space.
      APPEND ls_where TO lt_where.
    ENDIF.
  ENDIF.
  IF lv_ctnum+0(1) NE '$'.
*   Get FRNUM
    CLEAR : ls_filtr, ls_selop.
    LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'FRNUM'.
      LOOP AT ls_filtr-select_options INTO ls_selop.
        ls_selop-sign               = 'I'.
        IF ls_selop-low IS NOT INITIAL.
          TRANSLATE ls_selop-low TO UPPER CASE.
          APPEND ls_selop TO lt_frnum.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    IF lt_frnum IS NOT INITIAL.
      CONCATENATE 'frnum IN' 'lt_frnum' INTO ls_where SEPARATED BY space.
      APPEND ls_where TO lt_where.
    ENDIF.

*   Get STATS
    CLEAR : ls_filtr, ls_selop.
    LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'STATS'.
      LOOP AT ls_filtr-select_options INTO ls_selop.
        ls_selop-sign               = 'I'.
        IF ls_selop-low IS NOT INITIAL.
          TRANSLATE ls_selop-low TO UPPER CASE.
          APPEND ls_selop TO lt_stats.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    IF lt_stats IS NOT INITIAL.
      CONCATENATE 'stats IN' 'lt_stats' INTO ls_where SEPARATED BY space.
      APPEND ls_where TO lt_where.
    ENDIF.
*   Get CLASS
    CLEAR : ls_filtr, ls_selop.
    LOOP AT it_filter_select_options INTO ls_filtr WHERE property = 'CLASS'.
      LOOP AT ls_filtr-select_options INTO ls_selop.
        ls_selop-sign               = 'I'.
        IF ls_selop-low IS NOT INITIAL.
          TRANSLATE ls_selop-low TO UPPER CASE.
          lv_clasf                = ls_selop-low.
          APPEND ls_selop TO lt_class.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

*  *************Initialisation*************************************************  BEG *
    CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name               = 'ZMM_FT_STATS'
        langu                     = sy-langu
        prid                      = 0
        withtext                  = 'X'
      TABLES
        dd07v_tab_a               = lt_dmntx
        dd07v_tab_n               = lt_dmntt
      EXCEPTIONS
        illegal_value             = 1
        op_failure                = 2
        OTHERS                    = 3.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name               = 'ZMM_SR_STATS'
        langu                     = sy-langu
        prid                      = 0
        withtext                  = 'X'
      TABLES
        dd07v_tab_a               = lt_dmnt3
        dd07v_tab_n               = lt_dmntt
      EXCEPTIONS
        illegal_value             = 1
        op_failure                = 2
        OTHERS                    = 3.
    ENDIF.
    IF sy-subrc NE 0.
          ls_retrn-type                 = 'W'.
          ls_retrn-id                   = 'ZMM'.
          ls_retrn-number               = '129'.

          me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                            iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                            iv_add_to_response_header = abap_true
                                                                            iv_message_target         = 'W' ).
    ENDIF.
    CALL FUNCTION 'DD_DOMA_GET'
    EXPORTING
      domain_name               = 'ZFT_GW_CSTAT'
      langu                     = sy-langu
      prid                      = 0
      withtext                  = 'X'
    TABLES
      dd07v_tab_a               = lt_dmnt2
      dd07v_tab_n               = lt_dmntt
    EXCEPTIONS
      illegal_value             = 1
      op_failure                = 2
      OTHERS                    = 3.

    IF sy-subrc NE 0.
      ls_retrn-type                 = 'W'.
      ls_retrn-id                   = 'ZMM'.
      ls_retrn-number               = '130'.

      me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                        iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                        iv_add_to_response_header = abap_true
                                                                        iv_message_target         = 'W' ).
    ENDIF.
*  *************Initialisation*************************************************  END *

    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_caitm
    FROM zmm_ca_itm
    WHERE ( (lt_where) ).

    IF sy-subrc EQ 0.
      SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF ls_cadef
      FROM zmm_ca_def
      WHERE ctnum EQ lv_ctnum.

      IF sy-subrc EQ 0.
        lv_drbis                  = ls_cadef-apfin.
        lv_drvon                  = ls_cadef-apdeb.
        CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
          EXPORTING
            i_datum_bis           = lv_drbis
            i_datum_von           = lv_drvon
          IMPORTING
            e_tage                = lv_diffd
          EXCEPTIONS
            OTHERS                = 1.

      ENDIF.

    ENDIF.

*  ***Get Recipe informations***************************************************************** BEG*
    LOOP AT lt_caitm ASSIGNING <caitm>.
      CLEAR : ls_smara,ls_frdef, ls_ftfil,ls_arcob,lt_arcob.

      IF <caitm>-frnum CS 'SR'.
        SELECT SINGLE d~srnum AS frnum, d~titre AS descr, v~apdeb, v~apfin, d~stats, d~famil , d~arcid
        INTO CORRESPONDING FIELDS OF @ls_frdef
        FROM zmm_sr_def AS d
        INNER JOIN zmm_sr_ver AS v ON d~srnum EQ v~srnum
        WHERE d~srnum EQ @<caitm>-frnum.
      ELSE.
        SELECT SINGLE d~ftnum AS frnum, d~titre AS descr,v~apdeb, v~apfin, d~stats , d~arcid
        INTO CORRESPONDING FIELDS OF @ls_frdef
        FROM zmm_ft_def AS d
        INNER JOIN zmm_ft_ver AS v ON d~ftnum EQ v~ftnum
        WHERE d~ftnum EQ @<caitm>-frnum.
      ENDIF.

      IF sy-subrc EQ 0 AND ls_frdef IS NOT INITIAL.
        <caitm>-descr             = ls_frdef-descr.
        <caitm>-apdeb             = ls_frdef-apdeb.
        <caitm>-apfin             = ls_frdef-apfin.
        <caitm>-stats             = ls_frdef-stats.


        lv_objct                  = zcl_zft_gw_ft_utilities=>cv_content_article.
        lv_objid                  = <caitm>-frnum.
        lv_arcid                  = ls_frdef-arcid.

        IF ls_frdef-arcid IS NOT INITIAL.
          CALL FUNCTION 'ZAO_DOCUMENT_GET'
            EXPORTING
              iv_objct            = lv_objct
              iv_objid            = lv_objid
              iv_arcid            = lv_arcid
            IMPORTING
              et_arcob            = lt_arcob
              et_retrn            = lt_retrn
            EXCEPTIONS
              OTHERS              = 1 .
         ELSE.
          CALL FUNCTION 'ZAO_DOCUMENT_GET'
            EXPORTING
              iv_objct            = lv_objct
              iv_objid            = lv_objid
            IMPORTING
              et_arcob            = lt_arcob
              et_retrn            = lt_retrn
            EXCEPTIONS
              OTHERS              = 1 .
         ENDIF.

         LOOP AT lt_arcob INTO ls_arcob.
           TRANSLATE ls_arcob-mimetype TO UPPER CASE.
           IF NOT ls_arcob-mimetype CS 'IMAGE'.
             CONTINUE.
           ENDIF.
           EXIT.
         ENDLOOP.
         IF ls_arcob IS NOT INITIAL.
           <caitm>-imsrc          = ls_arcob-uri.
         ENDIF.


*    *********Get Family**************************************************  BEG *

        CALL FUNCTION 'MARA_SINGLE_READ'
          EXPORTING
            matnr                 = ls_frdef-frnum
         IMPORTING
           wmara                  = ls_smara
         EXCEPTIONS
           OTHERS                 = 5.

        IF sy-subrc EQ 0.
          IF lv_clasf IS NOT INITIAL AND ls_smara-matkl+0(6) NE lv_clasf.
            CONTINUE.
          ENDIF.
          ls_hiera                = zcl_zft_gw_ft_utilities=>get_hierarchy_from_matkl( ls_smara-matkl ).

          <caitm>-famil           = ls_hiera-lv3nm.
          <caitm>-class           = ls_hiera-lv3cd.
          <caitm>-matkl           = ls_smara-matkl.
          <caitm>-ordre           = ls_hiera-ordre.
        ELSE.
          IF lv_clasf IS NOT INITIAL AND ls_frdef-famil+0(6) NE lv_clasf.
            CONTINUE.
          ELSE.
            ls_hiera              = zcl_zft_gw_ft_utilities=>get_hierarchy_from_matkl( ls_frdef-famil ).
            <caitm>-famil         = ls_hiera-lv3nm.
            <caitm>-class         = ls_hiera-lv3cd.
            <caitm>-matkl         = ls_frdef-famil.
            <caitm>-ordre         = ls_hiera-ordre.
          ENDIF.
        ENDIF.

*    *********Get Family**************************************************  END*
*    *********Get Status**************************************************  BEG*
        IF <caitm>-frnum CS 'SR'.
          READ TABLE lt_dmnt3 INTO ls_dmntx WITH KEY domvalue_l = <caitm>-stats.
        ELSE.
          READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = <caitm>-stats.
        ENDIF.
        IF sy-subrc EQ 0.
          <caitm>-tstat           = ls_dmntx-ddtext.
        ENDIF.
        READ TABLE lt_dmnt2 INTO ls_dmntx WITH KEY domvalue_l = <caitm>-rstat.
        IF sy-subrc EQ 0.
          <caitm>-trstt           = ls_dmntx-ddtext.
        ENDIF.
*    *********Get Status**************************************************  END*
      ENDIF.

      APPEND <caitm> TO et_entityset.
    ENDLOOP.
****Get Recipe informations***************************************************************** END*
  ELSE.
    CLEAR : et_entityset.
  ENDIF.
ENDMETHOD.
