METHOD recipeset_get_entityset.

  TYPES: BEGIN OF ts_recipe.
          INCLUDE TYPE zcl_zft_gw_cat_mat1ere_mpc=>ts_recipe.
          TYPES : apde2 TYPE zmm_ft_apdeb,
                  apfi2 TYPE zmm_ft_apfin,
          END OF ts_recipe.

  DATA :  lv_apdeb    TYPE zmm_ft_apdeb,
          lv_apfin    TYPE zmm_ft_apfin,
          lv_matnr    TYPE matnr,
          lv_subrc    TYPE i,
          ls_dmntx    TYPE dd07v,
          ls_enset    TYPE ts_recipe,
          ls_ensgn   TYPE zgld_enseigne,
          ls_filtr    TYPE /iwbep/s_mgw_select_option,
          ls_retrn    TYPE bapiret2,
          ls_selop    TYPE /iwbep/s_cod_select_option,
          ls_where    TYPE string,
          lt_dmntt    TYPE TABLE OF dd07v,
          lt_dmntx    TYPE TABLE OF dd07v,
          lt_dmnt2    TYPE TABLE OF dd07v,
          lt_enset    TYPE TABLE OF ts_recipe,
          lt_ensgn    TYPE /iwbep/s_mgw_select_option,
          lt_ensg2    TYPE TABLE OF zgld_enseigne,
          lt_where    TYPE TABLE OF string.

FIELD-SYMBOLS : <enset> TYPE  ts_recipe.

  SELECT  *
  INTO    TABLE lt_ensg2
  FROM    zgld_enseigne
  WHERE   activ EQ 'X'.

  LOOP AT lt_ensg2 INTO ls_ensgn.
    CONCATENATE 'Z' ls_ensgn-ensgn INTO ls_ensgn-ensgn.
    AUTHORITY-CHECK OBJECT 'W_VKPR_PLT'
             ID 'VKORG' FIELD ls_ensgn-ensgn
             ID 'VTWEG' FIELD '*'
             ID 'PLTYP' FIELD '*'
             ID 'MATKL' FIELD '*'
             ID 'ACTVT' FIELD '03'.
    IF sy-subrc EQ 0.
      lt_ensgn-property           = 'ENSGN'.
      ls_selop-sign               = 'I'.
      ls_selop-option             = 'EQ'.
      ls_selop-low                = ls_ensgn-ensgn+1.
      APPEND ls_selop TO lt_ensgn-select_options.
    ENDIF.
  ENDLOOP.
****Get MATNR *******************************************************
  READ TABLE it_key_tab INTO DATA(ls_keytb) WITH KEY name = 'MATNR'.
  IF sy-subrc EQ 0.
    lv_matnr                      = ls_keytb-value.
  ENDIF.
**************Get filters*************************************************  BEG *
* Get MATNR
  IF lv_matnr IS INITIAL.
    READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'MATNR'.
    IF sy-subrc EQ 0.
      lv_matnr                    = ls_filtr-select_options[ 1 ]-low.
    ENDIF.
  ENDIF.
* Get APDEB
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'APDEB'.
  IF sy-subrc EQ 0.
    lv_apdeb                      = ls_filtr-select_options[ 1 ]-low.
    IF lv_apdeb IS NOT INITIAL.
      CONCATENATE 'v~apdeb LE' '@lv_apdeb' INTO ls_where SEPARATED BY space.
      APPEND ls_where TO lt_where.
    ENDIF.
  ENDIF.
* Get APFIN
  READ TABLE it_filter_select_options INTO ls_filtr WITH KEY property = 'APFIN'.
  IF sy-subrc EQ 0.
     lv_apfin                     = ls_filtr-select_options[ 1 ]-low.
     IF lv_apdeb IS NOT INITIAL.
      CONCATENATE 'v~apfin GE' '@lv_apfin' INTO ls_where SEPARATED BY space.
      APPEND ls_where TO lt_where.
    ENDIF.
  ENDIF.
  IF lv_apdeb IS INITIAL AND lv_apfin IS INITIAL.
    CONCATENATE 'v~apdeb LE' '@sy-datum AND v~apfin GE ' '@sy-datum' INTO ls_where SEPARATED BY space.
    APPEND ls_where TO lt_where.

  ENDIF.

  IF lv_matnr IS NOT INITIAL.
    IF lv_matnr+0(1) EQ '$'.
      ls_enset-matnr              = lv_matnr.
      APPEND ls_enset TO et_entityset.
    ELSE.
*     Initialisation
      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name             = 'ZMM_FT_STATS'
          langu                   = sy-langu
          prid                    = 0
          withtext                = 'X'
        TABLES
          dd07v_tab_a             = lt_dmntx
          dd07v_tab_n             = lt_dmntt
        EXCEPTIONS
          ILLEGAL_VALUE           = 1
          OP_FAILURE              = 2
          OTHERS                  = 3.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name             = 'ZMM_SR_STATS'
          langu                   = sy-langu
          prid                    = 0
          withtext                = 'X'
        TABLES
          dd07v_tab_a             = lt_dmnt2
          dd07v_tab_n             = lt_dmntt
        EXCEPTIONS
          ILLEGAL_VALUE           = 1
          OP_FAILURE              = 2
          OTHERS                  = 3.

      ENDIF.
      IF sy-subrc NE 0.
        ls_retrn-type               = 'W'.
        ls_retrn-id                 = 'ZMM'.
        ls_retrn-number             = '129'.

        me->mo_context->get_message_container( )->add_message_from_bapi(  is_bapi_message           = ls_retrn
                                                                          iv_error_category         = /iwbep/if_message_container=>gcs_error_category-no_error
                                                                          iv_add_to_response_header = abap_true
                                                                          iv_message_target         = 'W' ).
      ENDIF.
*     Get FT informations
      SELECT  d~ftnum AS rcnum, f~descr AS descr, d~stats AS stats, i~unite AS unite, v~apdeb AS apde2, v~apfin  AS apfi2,
              i~qtite AS qtite, f~ctnum AS ctnum, v~ftver AS rcver, d~titre AS titre
      INTO CORRESPONDING FIELDS OF TABLE @lt_enset
      FROM       zmm_ft_ing  AS i
      LEFT OUTER JOIN zmm_ca_itm  AS c ON c~frnum EQ i~ftnum
      LEFT OUTER JOIN zmm_ca_def  AS f ON f~ctnum EQ c~ctnum
      INNER JOIN zmm_ft_ver   AS v  ON i~ftnum EQ v~ftnum
      INNER JOIN zmm_ft_def   AS d  ON i~ftnum EQ d~ftnum
      INNER JOIN zmm_ft_ens   AS e  ON i~ftnum EQ e~ftnum
      WHERE ( i~matac EQ @lv_matnr OR i~fting EQ @lv_matnr )
      AND   e~ensgn IN @lt_ensgn-select_options
      AND   ( (lt_where) ).

      lv_subrc                    = sy-subrc.
      SORT lt_enset BY rcnum ctnum.
      DELETE ADJACENT DUPLICATES FROM lt_enset COMPARING rcnum ctnum.

      IF lv_subrc EQ 0 and lt_enset IS NOT INITIAL.
        LOOP AT lt_enset ASSIGNING <enset>.
          IF <enset>-apde2 IS NOT INITIAL.
            <enset>-apdeb         = <enset>-apde2.
          ENDIF.
          IF <enset>-apfi2 IS NOT INITIAL.
            <enset>-apfin         = <enset>-apfi2.
          ENDIF.
          READ TABLE lt_dmntx INTO ls_dmntx WITH KEY domvalue_l = <enset>-stats.
          IF sy-subrc EQ 0.
            <enset>-tstat         = ls_dmntx-ddtext.
          ENDIF.
        ENDLOOP.
        APPEND LINES OF lt_enset TO et_entityset.
      ENDIF.
*     Get SR informations
      SELECT d~srnum AS rcnum, f~descr AS descr, d~stats AS stats, i~unite AS unite, i~qtite AS qtite, f~ctnum AS ctnum, d~titre AS titre
      INTO CORRESPONDING FIELDS OF TABLE @lt_enset
      FROM            zmm_sr_ing  AS i
      LEFT OUTER JOIN zmm_ca_itm  AS c ON c~frnum EQ i~srnum
      LEFT OUTER JOIN zmm_ca_def  AS f ON f~ctnum EQ c~ctnum
      INNER JOIN zmm_sr_def   AS d ON i~srnum EQ d~srnum
      INNER JOIN zmm_sr_ver   AS v ON v~srnum EQ i~srnum
      INNER JOIN zmm_sr_ens   AS e ON i~srnum EQ e~srnum
      WHERE ( i~matac EQ @lv_matnr OR i~sring EQ @lv_matnr )
      AND   e~ensgn IN @lt_ensgn-select_options.

      lv_subrc                    = sy-subrc.
      SORT lt_enset BY rcnum ctnum.
      DELETE ADJACENT DUPLICATES FROM lt_enset COMPARING rcnum ctnum.

      IF lv_subrc EQ 0 and lt_enset IS NOT INITIAL.
        LOOP AT lt_enset ASSIGNING <enset>.
          IF <enset>-apde2 IS NOT INITIAL.
            <enset>-apdeb         = <enset>-apde2.
          ENDIF.
          IF <enset>-apfi2 IS NOT INITIAL.
            <enset>-apfin         = <enset>-apfi2.
          ENDIF.
          <enset>-fictf           = abap_true.
          READ TABLE lt_dmnt2 INTO ls_dmntx WITH KEY domvalue_l = <enset>-stats..
          IF sy-subrc EQ 0.
            <enset>-tstat         = ls_dmntx-ddtext.
          ENDIF.
        ENDLOOP.
        APPEND LINES OF lt_enset TO et_entityset.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMETHOD.