*&---------------------------------------------------------------------*
*&  Include           ZMM_SR_FT_INIT_STATUS_F01
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
  CLEAR  gt_prlog.
  PERFORM check_if_update_done.

  IF gt_prlog IS INITIAL.
    IF pr_simul EQ abap_true.
      MESSAGE text-003 TYPE 'S' DISPLAY LIKE 'S'. "La migration peut être executée.
    ELSE.
      PERFORM migration_status.
    ENDIF.
  ELSE.
    CLEAR: gt_prlog.
  ENDIF.

  IF gt_prlog IS NOT INITIAL.
    PERFORM display_log.
  ELSE.
    IF pr_simul EQ abap_true.
      MESSAGE text-009 TYPE 'S' DISPLAY LIKE 'S'. "Aucune modification
    ELSE.
      MESSAGE text-008 TYPE 'S' DISPLAY LIKE 'S'. "Aucune modification
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_IF_UPDATE_DONE
*&---------------------------------------------------------------------*
FORM check_if_update_done .
  DATA: lt_tdata    TYPE TABLE OF zmm_ft_def,
        ls_prlog    TYPE ty_prlog.

  SELECT *
  INTO TABLE lt_tdata
  FROM zmm_ft_def
  WHERE stats IN ('12','22','32','42').

  IF sy-subrc EQ 0.
    SELECT *
    INTO TABLE lt_tdata
    FROM zmm_ft_def
    WHERE stats IN ('10','20','30','40').

    IF sy-subrc NE 0. "Aucune FT avec les anciens Status
      MESSAGE text-001 TYPE 'S' DISPLAY LIKE 'E'.
      ls_prlog-messg                = text-001."La migration des statuts a déja été effectuée
      APPEND ls_prlog TO gt_prlog.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MIGRATION_STATUS
*&---------------------------------------------------------------------*
FORM migration_status .
  DATA: lv_stats    TYPE zmm_ft_stats,
        lv_ftsta    TYPE zmm_ft_stats,
        ls_afsrc    TYPE zmm_af_src,
        ls_ftdef    TYPE zmm_ft_def,
        lt_afsrc    TYPE TABLE OF zmm_af_src,
        lt_ftdef    TYPE TABLE OF zmm_ft_def,
        ls_prlog    TYPE ty_prlog.



  CLEAR lv_stats.

  SELECT  *
  INTO    CORRESPONDING FIELDS OF TABLE lt_ftdef
  FROM    zmm_ft_def
  WHERE   stats NE lv_stats.

  LOOP AT lt_ftdef INTO ls_ftdef.
    CLEAR : lv_ftsta.

    lv_ftsta                      = ls_ftdef-stats.

    CASE lv_ftsta.
      WHEN lv_stats. "Impossible en theorie mais bon?!
        ls_ftdef-stats            = '00'.
        MODIFY zmm_ft_def FROM ls_ftdef.

      WHEN '10'.
        ls_ftdef-stats            = '12'.
        MODIFY zmm_ft_def FROM ls_ftdef.

      WHEN '20'.
        ls_ftdef-stats            = '22'.
        MODIFY zmm_ft_def FROM ls_ftdef.

      WHEN '30'.
        ls_ftdef-stats            = '32'.
        MODIFY zmm_ft_def FROM ls_ftdef.

      WHEN '40'.
        ls_ftdef-stats            = '42'.
        MODIFY zmm_ft_def FROM ls_ftdef.

      WHEN '00' OR '12' OR '22' OR '32' OR '42'.
        ls_prlog-icons            = icon_led_yellow.
        ls_prlog-ftnum            = ls_ftdef-ftnum.
        ls_prlog-stats            = ls_ftdef-stats.
        ls_prlog-messg            = text-005. " Le statut de cette FT est déjà valide. Aucune modification n'a été apportée.
        APPEND ls_prlog TO gt_prlog.

      WHEN OTHERS.
        ls_prlog-icons            = icon_led_yellow.
        ls_prlog-ftnum            = ls_ftdef-ftnum.
        ls_prlog-stats            = ls_ftdef-stats.
        ls_prlog-messg            = text-002. "Cette FT contient un statut inconnu. Aucune modification n'a été apportée
        APPEND ls_prlog TO gt_prlog.
***        CLEAR ls_ftdef-stats.
***        MODIFY zmm_ft_def FROM ls_ftdef.
    ENDCASE.

    CASE lv_ftsta.
      WHEN '10' OR '20' OR '30' OR '40'.
        ls_prlog-icons            = icon_led_green.
        ls_prlog-ftnum            = ls_ftdef-ftnum.
        ls_prlog-stats            = ls_ftdef-stats.
        ls_prlog-messg            = text-006. " Le statut de cette FT a été mis à jour.
        APPEND ls_prlog TO gt_prlog.
     	WHEN OTHERS.
    ENDCASE.

   ENDLOOP.

  SELECT  *
  INTO    CORRESPONDING FIELDS OF TABLE lt_afsrc
  FROM    zmm_af_src
  WHERE   stats NE lv_stats.

  LOOP AT lt_afsrc INTO ls_afsrc.

    CASE ls_afsrc-stats.

      WHEN lv_stats.
        ls_afsrc-stats            = '10'.
        MODIFY zmm_af_src FROM ls_afsrc.

      WHEN '60'.
        ls_afsrc-stats            = '20'.
        MODIFY zmm_af_src FROM ls_afsrc.

      WHEN '90'.
        ls_afsrc-stats            = '50'.
        MODIFY zmm_af_src FROM ls_afsrc.

      WHEN '100'.
        ls_afsrc-stats            = '20'.
        MODIFY zmm_af_src FROM ls_afsrc.
    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
FORM display_log .
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
    lv_textl                      = text-004.
    lr_grcol->set_long_text( lv_textl ).
    lv_textm                      = text-004.
    lr_grcol->set_medium_text( lv_textm ).
    lv_texts                      = text-004.
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