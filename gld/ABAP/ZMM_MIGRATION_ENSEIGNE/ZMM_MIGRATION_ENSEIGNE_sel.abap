*&---------------------------------------------------------------------*
*&  Include           ZMM_MIGRATION_ENSEIGNE_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK mig WITH FRAME TITLE text-001.
*  SELECT-OPTIONS: so_ensgn  FOR   gv_ensgn.
  PARAMETERS :      pr_simul  AS CHECKBOX MODIF ID dat DEFAULT abap_true. "Simulation
SELECTION-SCREEN END OF BLOCK mig.

INITIALIZATION.
  PERFORM 0init.


START-OF-SELECTION.
  PERFORM 1main.