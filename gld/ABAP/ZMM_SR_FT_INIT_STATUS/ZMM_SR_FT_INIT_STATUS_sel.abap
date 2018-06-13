*&---------------------------------------------------------------------*
*&  Include           ZMM_SR_FT_INIT_STATUS_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK mig WITH FRAME TITLE text-007.
  PARAMETERS :      pr_simul  AS CHECKBOX MODIF ID dat DEFAULT abap_true. "Simulation
SELECTION-SCREEN END OF BLOCK mig.

INITIALIZATION.
  PERFORM 0init.

START-OF-SELECTION.
  PERFORM 1main.