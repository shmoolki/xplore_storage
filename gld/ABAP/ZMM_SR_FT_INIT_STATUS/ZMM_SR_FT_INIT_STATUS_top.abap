*&---------------------------------------------------------------------*
*& Include ZMM_SR_FT_INIT_STATUS_TOP                         Report ZMM_SR_FT_INIT_STATUS
*&
*&---------------------------------------------------------------------*
REPORT zmm_sr_ft_init_status.

TYPE-POOLS: icon.

TYPES : BEGIN OF ty_prlog,
          icons     TYPE icon_d,
          ftnum     TYPE zmm_ftnum,
          stats     TYPE zmm_ft_stats,
          messg     TYPE string,
        END OF ty_prlog,
        tt_prlog    TYPE TABLE OF ty_prlog.

DATA:   gt_prlog    TYPE tt_prlog.