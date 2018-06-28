  METHOD get_ing_stat.
    DATA: lt_dfttx    TYPE TABLE OF dd07v,
          ls_dsrtx    TYPE dd07v,
          ls_fting    TYPE zmm_ft_ing,
          ls_smarc    TYPE marc,
          ls_sring    TYPE zmm_sr_ing,
          ls_tmara    TYPE mara,
          lt_dsrtt    TYPE TABLE OF dd07v,
          lt_tmarc    TYPE TABLE OF marc,
          lv_domain   TYPE char20,
          lv_artcd    TYPE char2.


    lv_artcd  = iv_matnr+0(2).
    CLEAR:  ev_stats,
            ev_tstat.

    IF lv_artcd EQ 'FT'.
      SELECT  SINGLE stats
      INTO    ev_stats
      FROM    zmm_ft_def
      WHERE   ftnum EQ  iv_matnr.

*      lv_domain = .
      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name                 = 'ZMM_FT_STATS'
          get_state                   = 'M  '
          langu                       = sy-langu
          prid                        = 0
          withtext                    = 'X'
        TABLES
          dd07v_tab_a                 = lt_dfttx
          dd07v_tab_n                 = lt_dsrtt
        EXCEPTIONS
          OTHERS                      = 0.

    ELSEIF lv_artcd EQ 'SR'.

      SELECT  SINGLE stats
      INTO    ev_stats
      FROM    zmm_sr_def
      WHERE   srnum EQ  iv_matnr.
*      lv_domain = 'ZMM_SR_STATS'.

      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name                 = 'ZMM_SR_STATS'
          get_state                   = 'M  '
          langu                       = sy-langu
          prid                        = 0
          withtext                    = 'X'
        TABLES
          dd07v_tab_a                 = lt_dfttx
          dd07v_tab_n                 = lt_dsrtt
        EXCEPTIONS
          OTHERS                      = 0.

     ELSEIF lv_artcd EQ 'AF'.

      SELECT  SINGLE stats
      INTO    ev_stats
      FROM    zmm_af_src
      WHERE   matnr EQ  iv_matnr
      AND     sokey EQ  iv_matac.
*      lv_domain = 'ZMM_SR_STATS'.

      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name                 = 'ZMM_MP_STATS'
          get_state                   = 'M  '
          langu                       = sy-langu
          prid                        = 0
          withtext                    = 'X'
        TABLES
          dd07v_tab_a                 = lt_dfttx
          dd07v_tab_n                 = lt_dsrtt
        EXCEPTIONS
          OTHERS                      = 0.

    ELSE. " Article reel

      IF iv_frnum+0(2) EQ 'SR'.

        SELECT  SINGLE *
        INTO    CORRESPONDING FIELDS OF ls_sring
        FROM    zmm_sr_ing
        WHERE   sring EQ iv_matnr
        AND     srnum EQ iv_frnum.

        SELECT  SINGLE *
        INTO    CORRESPONDING FIELDS OF ls_tmara
        FROM    mara
        WHERE   matnr EQ ls_sring-matac.

      ELSEIF iv_frnum+0(2) EQ 'FT'.

        SELECT  SINGLE *
        INTO    CORRESPONDING FIELDS OF ls_fting
        FROM    zmm_ft_ing
        WHERE   fting EQ iv_matnr
        AND     ftnum EQ iv_frnum.

        SELECT  SINGLE *
        INTO    CORRESPONDING FIELDS OF ls_tmara
        FROM    mara
        WHERE   matnr EQ ls_fting-matac.

      ENDIF.

      IF ls_tmara IS INITIAL.
        RETURN.
      ENDIF.

      IF ls_tmara-mstae EQ 'Z3'.
          ev_stats                = '1'.

         ELSE.

          SELECT *
          INTO TABLE lt_tmarc
          FROM marc
          WHERE matnr EQ ls_tmara-matnr
          AND   werks IN ( 'R120' , 'R100' ).

          IF sy-subrc EQ 0 AND lt_tmarc IS NOT INITIAL.
            READ TABLE lt_tmarc INTO ls_smarc WITH KEY werks = 'R120' mmsta = 'Z3'.
            IF sy-subrc EQ 0 AND ls_smarc IS NOT INITIAL.
              ev_stats            = '2'.
            ELSE.
              READ TABLE lt_tmarc INTO ls_smarc WITH KEY werks = 'R120' mmsta = 'Z9'.
              IF sy-subrc EQ 0 AND ls_smarc IS NOT INITIAL.
                ev_stats          = '3'.
              ELSE.
                READ TABLE lt_tmarc INTO ls_smarc WITH KEY werks = 'R100' mmsta = 'Z3'.
                IF sy-subrc EQ 0 AND ls_smarc IS NOT INITIAL.
                  ev_stats        = '4'.
                ELSE.
                  ev_stats        = ''.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            ev_stats              = ''.
          ENDIF.

        ENDIF.

        CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name             = 'ZMM_AR_STATS'
          get_state               = 'M  '
          langu                   = sy-langu
          prid                    = 0
          withtext                = 'X'
        TABLES
          dd07v_tab_a             = lt_dfttx
          dd07v_tab_n             = lt_dsrtt
        EXCEPTIONS
          OTHERS                  = 0.

    ENDIF.

    IF lt_dfttx IS NOT INITIAL.
*     Get FT status


       READ TABLE lt_dfttx INTO ls_dsrtx WITH KEY domvalue_l = ev_stats.
            IF sy-subrc EQ 0.
              ev_tstat           = ls_dsrtx-ddtext.
            ENDIF.

    ENDIF.

  ENDMETHOD.