-- INTEGRANTES: Eduardo H. S. Nagado, Gustavo R. Lazzuri, Felipe S. Maciel
-- PACOTE: PKG_MOTTU_OPERACOES
----

CREATE OR REPLACE PACKAGE PKG_MOTTU_OPERACOES AS
    
    -- Função: Converte um cursor relacional em JSON
    
    FUNCTION FNC_RELACIONAL_PARA_JSON(p_cursor IN SYS_REFCURSOR) RETURN CLOB;


    
    -- Procedure: Lista detecções em formato JSON (JOIN com MOTO)
    
    PROCEDURE PRC_LISTAR_DETECCOES_JSON;

    
    -- Procedure: Relatório de custos de manutenção (manual com cursores)
    
    PROCEDURE PRC_RELATORIO_CUSTOS_MANUAL;
END PKG_MOTTU_OPERACOES;
/

-- PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY PKG_MOTTU_OPERACOES AS

    FUNCTION FNC_RELACIONAL_PARA_JSON (
        p_cursor IN SYS_REFCURSOR
    ) RETURN CLOB
    IS
        v_json_clob   CLOB := '[';
        v_col_count   INTEGER;
        v_desc_tab    DBMS_SQL.DESC_TAB;
        v_cursor_id   INTEGER;
        v_is_first    BOOLEAN := TRUE;
        v_col_value   VARCHAR2(4000);
        l_cursor      SYS_REFCURSOR;
    BEGIN
        l_cursor := p_cursor; 
        v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(l_cursor); 

        DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_count, v_desc_tab);

        FOR i IN 1 .. v_col_count LOOP
            DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_col_value, 4000);
        END LOOP;

        WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
            IF NOT v_is_first THEN
                v_json_clob := v_json_clob || ',';
            END IF;
            v_json_clob := v_json_clob || CHR(10) || '{';
            FOR i IN 1 .. v_col_count LOOP
                BEGIN
                    DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_col_value);
                EXCEPTION
                    WHEN OTHERS THEN
                        v_col_value := '[valor invalido]';
                END;
                
                v_col_value := NVL(TRIM(TO_CHAR(v_col_value)), 'null');

                v_json_clob := v_json_clob || '"' || LOWER(v_desc_tab(i).col_name) || '":"' ||
                            REPLACE(v_col_value, '"', '\"') || '"';
                IF i < v_col_count THEN
                    v_json_clob := v_json_clob || ',';
                END IF;
            END LOOP;
            v_json_clob := v_json_clob || '}';
            v_is_first := FALSE;
        END LOOP;

        v_json_clob := v_json_clob || CHR(10) || ']';
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);

        IF v_is_first THEN RETURN '[]'; END IF;

        RETURN v_json_clob;
    EXCEPTION
        WHEN OTHERS THEN
            IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
            END IF;
            RETURN '{"erro": "Falha na conversao para JSON: ' || SQLERRM || '"}';
    END FNC_RELACIONAL_PARA_JSON;
    
    PROCEDURE PRC_LISTAR_DETECCOES_JSON IS
        v_cursor SYS_REFCURSOR;
        v_json_result CLOB;
        e_nenhuma_deteccao EXCEPTION;
    BEGIN
        OPEN v_cursor FOR
            SELECT
                d.DETECTION_ID,
                d.MODEL_NAME,
                m.PLACA,
                m.MODELO,
                m.STATUS,
                d.CENTER_X,
                d.CENTER_Y,
                TO_CHAR(d.DETECTION_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS') AS timestamp_deteccao
            FROM DETECTIONS d
            LEFT JOIN MOTO m ON UPPER(TRIM(d.MODEL_NAME)) = UPPER(TRIM(m.MODELO))
            ORDER BY d.DETECTION_TIMESTAMP DESC;

        v_json_result := FNC_RELACIONAL_PARA_JSON(v_cursor);
        
        IF v_json_result = '[]' THEN
            RAISE e_nenhuma_deteccao;
        END IF;

        DBMS_OUTPUT.PUT_LINE('--- Relatorio de Deteccoes (IoT) em formato JSON ---');
        DBMS_OUTPUT.PUT_LINE(v_json_result);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    EXCEPTION
        WHEN e_nenhuma_deteccao THEN
            DBMS_OUTPUT.PUT_LINE('Nenhuma deteccao encontrada na tabela DETECTIONS.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro na procedure PRC_LISTAR_DETECCOES_JSON: ' || SQLERRM);
    END PRC_LISTAR_DETECCOES_JSON;

    PROCEDURE PRC_RELATORIO_CUSTOS_MANUAL IS
        CURSOR c_manutencoes IS 
            SELECT p.NOME AS nome_patio, o.CARGO, m.CUSTO
            FROM MANUTENCAO m
            JOIN OPERADOR o ON m.OPERADOR_ID = o.OPERADOR_ID
            JOIN PATIO p ON o.PATIO_ID = p.PATIO_ID
            ORDER BY p.NOME, o.CARGO;
            
        v_patio_atual PATIO.NOME%TYPE := NULL;
        v_subtotal_patio NUMBER(12, 2) := 0;
        v_total_geral NUMBER(14, 2) := 0;
        v_primeira_linha BOOLEAN := TRUE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Relatorio de Custos de Manutencao ---');
        DBMS_OUTPUT.PUT_LINE(RPAD('Patio', 30) || RPAD('Cargo', 20) || 'Custo (R$)');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));

        FOR rec IN c_manutencoes LOOP
            IF v_patio_atual IS NOT NULL AND rec.nome_patio != v_patio_atual THEN
                DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
                DBMS_OUTPUT.PUT_LINE(RPAD('Subtotal ' || v_patio_atual, 50) || TO_CHAR(v_subtotal_patio, '999G999D99'));
                DBMS_OUTPUT.PUT_LINE('');
                v_total_geral := v_total_geral + v_subtotal_patio;
                v_subtotal_patio := 0;
            END IF;
            DBMS_OUTPUT.PUT_LINE(RPAD(rec.nome_patio, 30) || RPAD(rec.cargo, 20) || TO_CHAR(rec.CUSTO, '999G999D99'));
            v_subtotal_patio := v_subtotal_patio + rec.CUSTO;
            v_patio_atual := rec.nome_patio;
            v_primeira_linha := FALSE;
        END LOOP;

        IF NOT v_primeira_linha THEN
            DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Subtotal ' || v_patio_atual, 50) || TO_CHAR(v_subtotal_patio, '999G999D99'));
            v_total_geral := v_total_geral + v_subtotal_patio;
            DBMS_OUTPUT.PUT_LINE(RPAD('=', 70, '='));
            DBMS_OUTPUT.PUT_LINE(RPAD('TOTAL GERAL', 50) || TO_CHAR(v_total_geral, '999G999D99'));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma manutencao encontrada.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro no relatorio de custos: ' || SQLERRM);
    END PRC_RELATORIO_CUSTOS_MANUAL;

END PKG_MOTTU_OPERACOES;
/
----
-- BLOCO DE TESTES DO PACOTE
----
DECLARE
    v_result NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '========== TESTES PKG_MOTTU_OPERACOES ==========');

    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Teste 1: PRC_LISTAR_DETECCOES_JSON (com dados de IoT)');
    PKG_MOTTU_OPERACOES.PRC_LISTAR_DETECCOES_JSON;

    -- O teste da FNC_VERIFICAR_VAGA_PATIO foi removido pois a função foi descontinuada.
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Teste 2: PRC_RELATORIO_CUSTOS_MANUAL');
    PKG_MOTTU_OPERACOES.PRC_RELATORIO_CUSTOS_MANUAL;

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '========== FIM DOS TESTES ==========');
END;
/
