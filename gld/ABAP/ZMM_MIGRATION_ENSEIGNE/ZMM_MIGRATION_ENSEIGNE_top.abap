*&---------------------------------------------------------------------*
*& Include ZMM_MIGRATION_ENSEIGNE_TOP                        Report ZMM_MIGRATION_ENSEIGNE
*&
*&---------------------------------------------------------------------*

TYPE-POOLS: icon.

TYPES : BEGIN OF ty_prlog,
          icons     TYPE icon_d,
          messg     TYPE string,
        END OF ty_prlog,
        BEGIN OF ty_gamme,
          ensgn TYPE zgld_ensgn,
          asort TYPE asort,
          vkorg TYPE vkorg,
          gamtx TYPE asorttext40,
        END OF ty_gamme,
        BEGIN OF ty_typol.
          INCLUDE TYPE bapimatcha.
TYPES:    vkorg TYPE vkorg,
        END OF ty_typol,
        tt_typol    TYPE TABLE OF ty_typol,
        tt_prlog    TYPE TABLE OF ty_prlog.
DATA  : gv_ensgn    TYPE zgld_ensgn,
        gt_gamme    TYPE TABLE OF ty_gamme,
        gt_ensgn    TYPE TABLE OF zgld_enseigne,
        gt_prlog    TYPE tt_prlog.