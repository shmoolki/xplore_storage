*&---------------------------------------------------------------------*
*&  Include           ZMM_MIGRATION_ENSEIGNE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  0INIT
*&---------------------------------------------------------------------*
FORM 0init .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  1MAIN
*&---------------------------------------------------------------------*
FORM 1main .

***  IF ''= 'eer'.

  PERFORM get_mapping_object.

  PERFORM make_enseigne_backup.

  PERFORM migrate_main_table.
***
  PERFORM migrate_ft_table.
***
  PERFORM migrate_sr_table.

  PERFORM migrate_alert_table.

  PERFORM migrate_hie_table.

  IF gt_prlog[] IS NOT INITIAL.
    PERFORM log_display.
  ENDIF.

***  ENDIF.
***
***  DATA: is_ensgn TYPE zmm_ft_ens,
***        lt_chara TYPE tt_typol.
***
***  is_ensgn-ftnum    = 'FT000044'.
***  is_ensgn-ensgn    = 'FDP'.
***
***  PERFORM get_char_ft USING is_ensgn CHANGING lt_chara.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_MAPPING_OBJECT
*&---------------------------------------------------------------------*
FORM get_mapping_object .
  DATA: ls_ensgn    TYPE zgld_enseigne,
        ls_prlog    TYPE ty_prlog,
        ls_gamme    TYPE ty_gamme,
        lv_vkorg    TYPE vkorg,
        lt_gamme    TYPE TABLE OF ty_gamme.
  FIELD-SYMBOLS: <fs_gamme>     TYPE ty_gamme,
                 <fs_ensgn>     TYPE zgld_enseigne.

  SELECT *
  INTO TABLE gt_ensgn
  FROM zgld_enseigne
  WHERE ensgn IN so_ensgn.

  LOOP AT gt_ensgn ASSIGNING <fs_ensgn>.

    CLEAR: lt_gamme.
    lv_vkorg                      = |Z{ <fs_ensgn>-ensgn }|.
    <fs_ensgn>-vkorg              = lv_vkorg.
     IF sy-mandt EQ 140 AND <fs_ensgn>-ensgn EQ 'BD'.
       lv_vkorg                   = 'ZBDO'.
       <fs_ensgn>-vkorg           = lv_vkorg.
    ENDIF.
    IF sy-mandt EQ 140 AND <fs_ensgn>-ensgn EQ 'FP'.
      lv_vkorg                   = 'ZFDP'.
      <fs_ensgn>-vkorg           = lv_vkorg.
    ENDIF.

    SELECT  g~vkorg g~asort t~name1 AS gamtx
    INTO    CORRESPONDING FIELDS OF TABLE lt_gamme
    FROM    wrs1 AS g
    INNER   JOIN wrst AS t ON g~asort EQ t~asort
    WHERE   t~spras EQ 'F'
    AND     g~sotyp EQ 'C'
    AND     g~vkorg EQ lv_vkorg.

    IF  sy-subrc NE 0.
      ls_prlog-icons      = icon_led_red.
      ls_prlog-messg      = |{ text-003 } { lv_vkorg } |. "Erreur lors de la récuperation de l'organisation commerciale
      APPEND ls_prlog TO gt_prlog.
*      RETURN.
    ELSE.
      LOOP AT lt_gamme INTO ls_gamme.
        ls_gamme-ensgn          = <fs_ensgn>-ensgn.
        APPEND ls_gamme TO gt_gamme.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ENSEIGNE_BACKUP
*&---------------------------------------------------------------------*
FORM make_enseigne_backup.
 DATA: lt_tbbck   TYPE TABLE OF zgld_enseigne_bk,
       ls_prlog   TYPE ty_prlog.

 SELECT *
 INTO CORRESPONDING FIELDS OF TABLE lt_tbbck
 FROM zgld_enseigne.

 MODIFY zgld_enseigne_bk FROM TABLE lt_tbbck.
 IF sy-subrc EQ 0.
   ls_prlog-icons      = icon_led_green.
   ls_prlog-messg      =  text-008. "copie de la table ZGLD_ENSEIGNE effectuée
   APPEND ls_prlog TO gt_prlog.
   COMMIT WORK.
 ELSE.
   ls_prlog-icons      = icon_led_red.
   ls_prlog-messg      =  text-009. "Probleme lors de la sauveguarde de la table ZGLD_ENSEIGNE
   APPEND ls_prlog TO gt_prlog.
   COMMIT WORK.
 ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MIGRATE_MAIN_TABLE
*&---------------------------------------------------------------------*
FORM migrate_main_table .
  DATA: ls_gamme    TYPE ty_gamme,
        ls_prlog    TYPE ty_prlog,
        ls_ensgn    TYPE zgld_enseigne,
        lt_ensgn    TYPE TABLE OF zgld_enseigne.

  LOOP AT gt_gamme INTO ls_gamme.
    ls_ensgn-ensgn                = ls_gamme-asort.
    ls_ensgn-entxt                = ls_gamme-gamtx.
    ls_ensgn-mandt                = sy-mandt.
    ls_ensgn-vkorg                = ls_gamme-vkorg.
    APPEND ls_ensgn TO lt_ensgn.
  ENDLOOP.

  IF pr_simul NE abap_true.

    DELETE FROM zgld_enseigne.
    MODIFY zgld_enseigne FROM TABLE lt_ensgn.
    IF sy-subrc EQ 0.
      ls_prlog-icons      = icon_led_green.
      ls_prlog-messg      =  text-004. "Migration de la table ZGLD_ENSEIGNE effectuée
      APPEND ls_prlog TO gt_prlog.
      COMMIT WORK.
    ELSE.
      ls_prlog-icons      = icon_led_red.
      ls_prlog-messg      =  text-005. "Erreur lors de la migration de la table ZGLD_ENSEIGNE
      APPEND ls_prlog TO gt_prlog.
      ROLLBACK WORK.
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MIGRATE_FT_TABLE
*&---------------------------------------------------------------------*
FORM migrate_ft_table.
  DATA: ls_gamme  TYPE ty_gamme,
        ls_gamm2  TYPE ty_gamme,
        ls_ensft  TYPE zmm_ft_ens,
        ls_prlog  TYPE ty_prlog,
        lt_twlk1  TYPE TABLE OF wlk1,
        lt_gamme  TYPE TABLE OF ty_gamme,
        lt_ensft  TYPE TABLE OF zmm_ft_ens,
        lt_chara  TYPE tt_typol,
        ls_chara  TYPE ty_typol,
        lv_stats  TYPE zmm_ft_stats.


  lt_gamme[]                      = gt_gamme[].
  SORT lt_gamme BY ensgn.
  DELETE ADJACENT DUPLICATES FROM lt_gamme COMPARING ensgn.

  LOOP AT lt_gamme INTO ls_gamme.
    SELECT *
    INTO  TABLE lt_ensft
    FROM zmm_ft_ens
    WHERE ensgn EQ ls_gamme-ensgn.

    IF sy-subrc EQ 0.
      LOOP AT lt_ensft  INTO ls_ensft.
        IF pr_simul NE abap_true.

          DELETE zmm_ft_ens FROM ls_ensft. "Suppression

          SELECT    SINGLE stats
          INTO      lv_stats
          FROM      zmm_ft_def
          WHERE     ftnum EQ ls_ensft-ftnum.

          PERFORM get_char_ft USING ls_ensft CHANGING lt_chara.

          LOOP AT gt_gamme INTO ls_gamm2 WHERE ensgn EQ ls_gamme-ensgn.
            IF lt_chara IS INITIAL. "Pas de typologie => toutes les gammes
              ls_ensft-ensgn                = ls_gamm2-asort.
              MODIFY zmm_ft_ens FROM ls_ensft.
              IF sy-subrc EQ 0.
                ls_prlog-icons      = icon_led_green.
                ls_prlog-messg      =  text-006. "Migration de la FT &1 effectuée pour la gamme &2
                REPLACE '&1' WITH ls_ensft-ftnum INTO ls_prlog-messg.
                REPLACE '&2' WITH ls_ensft-ensgn INTO ls_prlog-messg.
                APPEND ls_prlog TO gt_prlog.
                COMMIT WORK.
              ENDIF.
            ELSE. "Il existe des typologies
              READ TABLE lt_chara INTO ls_chara  WITH KEY vkorg = ls_gamm2-vkorg. "Verification typologie pour cette VKORG
              IF sy-subrc EQ 0. "Oui => on inscrit que celle-ci
                READ TABLE lt_chara INTO ls_chara  WITH KEY char_value = ls_gamm2-asort.
                IF sy-subrc EQ 0. "On inscrit que la gamme cochee dans typologie
                  ls_ensft-ensgn                = ls_gamm2-asort.
                  MODIFY zmm_ft_ens FROM ls_ensft.
                  IF sy-subrc EQ 0.
                    ls_prlog-icons      = icon_led_green.
                    ls_prlog-messg      =  text-006. "Migration de la FT &1 effectuée pour la gamme &2
                    REPLACE '&1' WITH ls_ensft-ftnum INTO ls_prlog-messg.
                    REPLACE '&2' WITH ls_ensft-ensgn INTO ls_prlog-messg.
                    APPEND ls_prlog TO gt_prlog.
                    COMMIT WORK.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MIGRATE_SR_TABLE
*&---------------------------------------------------------------------*
FORM migrate_sr_table.
  DATA: ls_gamme  TYPE ty_gamme,
        ls_gamm2  TYPE ty_gamme,
        ls_enssr  TYPE zmm_sr_ens,
        ls_prlog  TYPE ty_prlog,
        lt_gamme  TYPE TABLE OF ty_gamme,
        lt_enssr  TYPE TABLE OF zmm_sr_ens.

  lt_gamme[]                      = gt_gamme[].
  SORT lt_gamme BY ensgn.
  DELETE ADJACENT DUPLICATES FROM lt_gamme COMPARING ensgn.

  LOOP AT lt_gamme INTO ls_gamme.
    SELECT *
    INTO  TABLE lt_enssr
    FROM zmm_sr_ens
    WHERE ensgn EQ ls_gamme-ensgn.

    IF sy-subrc EQ 0.
      LOOP AT lt_enssr  INTO ls_enssr.
        IF pr_simul NE abap_true.

          DELETE zmm_sr_ens FROM ls_enssr. "Suppression de
          LOOP AT gt_gamme INTO ls_gamm2 WHERE ensgn EQ ls_gamme-ensgn.
            ls_enssr-ensgn                = ls_gamm2-asort.
            MODIFY zmm_sr_ens FROM ls_enssr.
            IF sy-subrc EQ 0.
              ls_prlog-icons      = icon_led_green.
              ls_prlog-messg      =  text-007. "Migration de la SR &1 effectuée pour la gamme &2
              REPLACE '&1' WITH ls_enssr-srnum INTO ls_prlog-messg.
              REPLACE '&2' WITH ls_enssr-ensgn INTO ls_prlog-messg.
              APPEND ls_prlog TO gt_prlog.
              COMMIT WORK.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MIGRATE_ALERT_TABLE
*&---------------------------------------------------------------------*
FORM migrate_alert_table .
  DATA: lt_ftalt  TYPE TABLE OF zmm_ft_alt,
        ls_ftalt  TYPE zmm_ft_alt,
        ls_prlog  TYPE ty_prlog,
        ls_ensgn  TYPE zgld_enseigne.
  FIELD-SYMBOLS: <fs_ftalt>   TYPE zmm_ft_alt.

  SELECT *
  INTO TABLE lt_ftalt
  FROM zmm_ft_alt.

  LOOP AT lt_ftalt  ASSIGNING  <fs_ftalt>.
    IF <fs_ftalt>-ensgn IS NOT INITIAL.
      READ TABLE gt_ensgn INTO ls_ensgn WITH  KEY ensgn = <fs_ftalt>-ensgn.
      IF sy-subrc EQ 0.
        <fs_ftalt>-vkorg          = ls_ensgn-vkorg.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF pr_simul NE 'X'.
    DELETE FROM zmm_ft_alt WHERE ensgn IS NOT NULL.
    MODIFY zmm_ft_alt FROM TABLE lt_ftalt.
    IF sy-subrc EQ 0.
      ls_prlog-icons      = icon_led_green.
      ls_prlog-messg      =  text-010. "Migration de la table ZMM_FT_ALT effectuée
      APPEND ls_prlog TO gt_prlog.
      COMMIT WORK.
    ELSE.
      ls_prlog-icons      = icon_led_red.
      ls_prlog-messg      =  text-011. "Migration de la table ZMM_FT_ALT impossible
      APPEND ls_prlog TO gt_prlog.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MIGRATE_HIE_TABLE
*&---------------------------------------------------------------------*
FORM migrate_hie_table .
  DATA: lt_cahie  TYPE TABLE OF zmm_ca_hie,
        ls_cahie  TYPE zmm_ca_hie,
        ls_prlog  TYPE ty_prlog,
        ls_ensgn  TYPE zgld_enseigne.
  FIELD-SYMBOLS: <fs_cahie>   TYPE zmm_ca_hie.

  SELECT *
  INTO TABLE lt_cahie
  FROM zmm_ca_hie.

  LOOP AT lt_cahie  ASSIGNING  <fs_cahie>.
    IF <fs_cahie>-ensgn IS NOT INITIAL.
      READ TABLE gt_ensgn INTO ls_ensgn WITH  KEY ensgn = <fs_cahie>-ensgn.
      IF sy-subrc EQ 0.
        <fs_cahie>-vkorg          = ls_ensgn-vkorg.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF pr_simul NE 'X'.
    DELETE FROM zmm_ca_hie WHERE ensgn IS NOT NULL.
    MODIFY zmm_ca_hie FROM TABLE lt_cahie.
    IF sy-subrc EQ 0.
      ls_prlog-icons      = icon_led_green.
      ls_prlog-messg      =  text-012. "Migration de la table ZMM_CA_HIE effectuée
      APPEND ls_prlog TO gt_prlog.
      COMMIT WORK.
    ELSE.
      ls_prlog-icons      = icon_led_red.
      ls_prlog-messg      =  text-013. "Migration de la table ZMM_CA_HIE impossible
      APPEND ls_prlog TO gt_prlog.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOG_DISPLAY
*&---------------------------------------------------------------------*
FORM log_display .
  DATA: lv_shrtx TYPE char10,
        lv_grtxt  TYPE string,
        lv_textl  TYPE scrtext_l,
        lv_textm  TYPE scrtext_m,
        lv_texts  TYPE scrtext_s,
        lr_gralv  TYPE REF TO cl_salv_table,
        lr_grcls  TYPE REF TO cl_salv_columns,
        lr_grcol  TYPE REF TO cl_salv_column,
        lr_grexc  TYPE REF TO cx_salv_msg,
        lr_grfct  TYPE REF TO cl_salv_functions,
        lr_grlay  TYPE REF TO cl_salv_form_layout_grid,
        lr_grtxt  TYPE REF TO cl_salv_form_text,
        lr_grxde  TYPE REF TO cx_salv_data_error,
        lr_grxex  TYPE REF TO cx_salv_existing,
        lr_grxnf  TYPE REF TO cx_salv_not_found.


  SORT gt_prlog BY icons.

  TRY.

*   Create ALV
    cl_salv_table=>factory( IMPORTING r_salv_table  = lr_gralv
                            CHANGING  t_table       = gt_prlog[] ).

*   Functions
    lr_grfct                      = lr_gralv->get_functions( ).
    lr_grfct->set_all( ).

*   Columns
    lr_grcls                      = lr_gralv->get_columns( ).

    lr_grcol                      = lr_grcls->get_column( 'MESSG' ).
    lv_textl                      = text-002.
    lr_grcol->set_long_text( lv_textl ).
    lv_textm                      = text-002.
    lr_grcol->set_medium_text( lv_textm ).
    lv_texts                      = text-002.
    lr_grcol->set_short_text( lv_texts ).
    lr_grcol->set_output_length( '55' ).


*   Display
    lr_gralv->display( ).

  CATCH cx_salv_msg INTO lr_grexc.
    MESSAGE lr_grexc TYPE 'I' DISPLAY LIKE 'E'.
  CATCH cx_salv_not_found INTO lr_grxnf.
    MESSAGE lr_grxnf TYPE 'I' DISPLAY LIKE 'E'.
  CATCH cx_salv_existing INTO lr_grxex.
    MESSAGE lr_grxex TYPE 'I' DISPLAY LIKE 'E'.
  CATCH cx_salv_data_error INTO lr_grxde.
    MESSAGE lr_grxde TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_CHAR_FT
*&---------------------------------------------------------------------*
FORM get_char_ft    USING    cs_ensft    TYPE zmm_ft_ens
                    CHANGING ct_chara    TYPE tt_typol.
   DATA:  lv_atinn    TYPE atinn,
          lv_tdnam    TYPE tdobname,
          ls_cawnt    TYPE cawnt,
**          ls_fting    TYPE zmm_ft_ing,
**          ls_ftver    TYPE zmm_ft_ver,
**          ls_ingre    TYPE zmm_s_ft_ingredient,
**          ls_stpob    TYPE stpob,
**          ls_tmakt    TYPE makt,
          ls_gamme    TYPE ty_gamme,
**          ls_versn    TYPE zmm_s_ft_version,
          lt_cawnt    TYPE TABLE OF cawnt,
          lt_fting    TYPE TABLE OF zmm_ft_ing,
          lt_ftver    TYPE TABLE OF zmm_ft_ver,
          lt_mastb    TYPE TABLE OF mastb,
          lt_stpob    TYPE TABLE OF stpob.

  FIELD-SYMBOLS <charc> TYPE ty_typol.

* Load Cawnt data
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input                       = 'TYPOLOGIE'
    IMPORTING
      output                      = lv_atinn.

  SELECT  *
  INTO    TABLE lt_cawnt
  FROM    cawnt
  WHERE   atinn   EQ lv_atinn
  AND     spras   EQ sy-langu.



  IF sy-subrc NE 0.
*    RAISE unknown_article.
  ENDIF.




  SELECT  a~atwrt AS char_value a~atzhl AS descr_cval
  INTO    CORRESPONDING FIELDS OF TABLE ct_chara
  FROM    inob        AS i
  INNER   JOIN ausp   AS a ON a~objek EQ i~cuobj
  WHERE   i~klart   EQ '026'
  AND     i~obtab   EQ 'MARAT'
  AND     i~objek   EQ cs_ensft-ftnum
  AND     a~atinn   EQ lv_atinn.

  DELETE ct_chara WHERE char_value IS INITIAL.

  LOOP AT ct_chara ASSIGNING <charc>.
    READ TABLE lt_cawnt INTO ls_cawnt WITH KEY atzhl = <charc>-descr_cval+1(3).
    IF sy-subrc EQ 0.
      <charc>-descr_cval          = ls_cawnt-atwtb.
      READ TABLE gt_gamme INTO ls_gamme WITH KEY ensgn = <charc>-char_value.
      IF sy-subrc EQ 0.
        <charc>-vkorg     = ls_gamme-vkorg.
      ENDIF.
    ELSE.
      CLEAR <charc>-char_value.
    ENDIF.
  ENDLOOP.
  DELETE ct_chara WHERE char_value IS INITIAL.


ENDFORM.