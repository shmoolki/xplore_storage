*&---------------------------------------------------------------------*
*&  Include           ZMM_SR_FT_INIT_STATUS_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  1MAIN
*&---------------------------------------------------------------------*
FORM 1main .
  DATA: lv_stats    TYPE zmm_ft_stats,
        ls_afsrc    TYPE zmm_af_src,
        ls_ftdef    TYPE zmm_ft_def,
        lt_afsrc    TYPE TABLE OF zmm_af_src,
        lt_ftdef    TYPE TABLE OF zmm_ft_def.


  CLEAR lv_stats.

  SELECT  *
  INTO    CORRESPONDING FIELDS OF TABLE lt_ftdef
  FROM    zmm_ft_def
  WHERE   stats NE lv_stats.

  LOOP AT lt_ftdef INTO ls_ftdef.

    CASE ls_ftdef-stats.

      WHEN lv_stats.
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

      WHEN OTHERS.
        CLEAR ls_ftdef-stats.
        MODIFY zmm_ft_def FROM ls_ftdef.

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
