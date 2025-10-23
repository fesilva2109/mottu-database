-- Integrantes: Eduardo H. S. Nagado, Gustavo R. Lazzuri, Felipe S. Maciel
-- Sprint 3: Procedures, Functions e Triggers

SET SERVEROUTPUT ON;

-- SEÇÃO 1: DROPS e CRIAÇÃO DE TABELAS E SEQUÊNCIAS 

-- Limpeza de sequences existentes para evitar conflitos
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE patio_seq';
    DBMS_OUTPUT.PUT_LINE('Sequence PATIO_SEQ dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2289 THEN
            DBMS_OUTPUT.PUT_LINE('Sequence PATIO_SEQ does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE moto_seq';
    DBMS_OUTPUT.PUT_LINE('Sequence MOTO_SEQ dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2289 THEN
            DBMS_OUTPUT.PUT_LINE('Sequence MOTO_SEQ does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE deteccao_seq';
    DBMS_OUTPUT.PUT_LINE('Sequence DETECCAO_SEQ dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2289 THEN
            DBMS_OUTPUT.PUT_LINE('Sequence DETECCAO_SEQ does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE operador_seq';
    DBMS_OUTPUT.PUT_LINE('Sequence OPERADOR_SEQ dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2289 THEN
            DBMS_OUTPUT.PUT_LINE('Sequence OPERADOR_SEQ does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE manutencao_seq';
    DBMS_OUTPUT.PUT_LINE('Sequence MANUTENCAO_SEQ dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2289 THEN
            DBMS_OUTPUT.PUT_LINE('Sequence MANUTENCAO_SEQ does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Remove as tabelas na ordem inversa de dependência
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AUDITORIA CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Table AUDITORIA dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('Table AUDITORIA does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DETECCAO CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Table DETECCAO dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('Table DETECCAO does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE MANUTENCAO CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Table MANUTENCAO dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('Table MANUTENCAO does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE OPERADOR CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Table OPERADOR dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('Table OPERADOR does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE MOTO CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Table MOTO dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('Table MOTO does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PATIO CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Table PATIO dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('Table PATIO does not exist.');
        ELSE
            RAISE;
        END IF;
END;
/

-- =============================================================================
-- Criação das Tabelas e Sequências
-- =============================================================================

-- Tabela PATIO: Representa os pátios de armazenamento de motocicletas
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE PATIO (
        PATIO_ID NUMBER PRIMARY KEY,
        NOME VARCHAR2(255) NOT NULL,
        LOCALIZACAO VARCHAR2(255) NOT NULL,
        CAPACIDADE NUMBER(5) DEFAULT 100 NOT NULL
    )';
    DBMS_OUTPUT.PUT_LINE('Tabela PATIO criada.');
EXCEPTION WHEN OTHERS THEN IF SQLCODE = -955 THEN DBMS_OUTPUT.PUT_LINE('Tabela PATIO já existe.'); ELSE RAISE; END IF;
END;
/
CREATE SEQUENCE patio_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Tabela MOTO: Registra todas as motocicletas do sistema
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE MOTO (
        MOTO_ID NUMBER PRIMARY KEY,
        PLACA VARCHAR2(10) UNIQUE NOT NULL,
        MODELO VARCHAR2(50) NOT NULL CHECK (MODELO IN (''Mottu Pop'', ''Mottu Sport'', ''Mottu-E'')),
        ANO NUMBER(4) CHECK (ANO >= 2015 AND ANO <= 2050),
        PATIO_ID NUMBER NOT NULL,
        STATUS VARCHAR2(30) CHECK (STATUS IN (''Pronta para aluguel'', ''Em manutencao'', ''Em quarentena'', ''Alta prioridade'', ''Reservada'', ''Aguardando vistoria'')),
        DATA_CADASTRO TIMESTAMP DEFAULT SYSTIMESTAMP,
        CONSTRAINT FK_MOTO_PATIO FOREIGN KEY (PATIO_ID) REFERENCES PATIO(PATIO_ID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabela MOTO criada.');
EXCEPTION WHEN OTHERS THEN IF SQLCODE = -955 THEN DBMS_OUTPUT.PUT_LINE('Tabela MOTO já existe.'); ELSE RAISE; END IF;
END;
/
CREATE SEQUENCE moto_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Tabela DETECCAO: Registra eventos de detecção via IoT (YOLO + OCR)
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE DETECCAO (
        DETECCAO_ID NUMBER PRIMARY KEY,
        MOTO_ID NUMBER NOT NULL,
        PATIO_ID NUMBER NOT NULL,
        TIPO_EVENTO VARCHAR2(20) CHECK (TIPO_EVENTO IN (''ENTRADA'', ''SAIDA'')),
        TIMESTAMP_DETECCAO TIMESTAMP DEFAULT SYSTIMESTAMP,
        CONFIANCA_YOLO NUMBER(3,2) CHECK (CONFIANCA_YOLO >= 0 AND CONFIANCA_YOLO <= 1),
        CONSTRAINT FK_DETECCAO_MOTO FOREIGN KEY (MOTO_ID) REFERENCES MOTO(MOTO_ID),
        CONSTRAINT FK_DETECCAO_PATIO FOREIGN KEY (PATIO_ID) REFERENCES PATIO(PATIO_ID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabela DETECCAO criada.');
EXCEPTION WHEN OTHERS THEN IF SQLCODE = -955 THEN DBMS_OUTPUT.PUT_LINE('Tabela DETECCAO já existe.'); ELSE RAISE; END IF;
END;
/
CREATE SEQUENCE deteccao_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Tabela OPERADOR: Funcionários que gerenciam os pátios
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE OPERADOR (
        OPERADOR_ID NUMBER PRIMARY KEY,
        NOME VARCHAR2(255) NOT NULL,
        EMAIL VARCHAR2(255) NOT NULL UNIQUE,
        PASSWORD VARCHAR2(255) NOT NULL,
        CARGO VARCHAR2(50) NOT NULL CHECK (CARGO IN (''GESTOR'', ''OPERADOR'', ''TECNICO'')),
        PATIO_ID NUMBER NOT NULL,
        SALARIO NUMBER(10, 2) DEFAULT 2500.00 NOT NULL,
        DATA_ADMISSAO DATE DEFAULT SYSDATE,
        CONSTRAINT FK_OPERADOR_PATIO FOREIGN KEY (PATIO_ID) REFERENCES PATIO(PATIO_ID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabela OPERADOR criada.');
EXCEPTION WHEN OTHERS THEN IF SQLCODE = -955 THEN DBMS_OUTPUT.PUT_LINE('Tabela OPERADOR já existe.'); ELSE RAISE; END IF;
END;
/
CREATE SEQUENCE operador_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Tabela MANUTENCAO: Registra eventos de manutenção das motocicletas
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE MANUTENCAO (
        MANUTENCAO_ID NUMBER PRIMARY KEY,
        MOTO_ID NUMBER NOT NULL,
        OPERADOR_ID NUMBER NOT NULL,
        TIPO_SERVICO VARCHAR2(100) NOT NULL,
        DATA_INICIO TIMESTAMP DEFAULT SYSTIMESTAMP,
        DATA_FIM TIMESTAMP,
        CUSTO NUMBER(10, 2) DEFAULT 0,
        CONSTRAINT FK_MANUTENCAO_MOTO FOREIGN KEY (MOTO_ID) REFERENCES MOTO(MOTO_ID),
        CONSTRAINT FK_MANUTENCAO_OPERADOR FOREIGN KEY (OPERADOR_ID) REFERENCES OPERADOR(OPERADOR_ID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabela MANUTENCAO criada.');
EXCEPTION WHEN OTHERS THEN IF SQLCODE = -955 THEN DBMS_OUTPUT.PUT_LINE('Tabela MANUTENCAO já existe.'); ELSE RAISE; END IF;
END;
/
CREATE SEQUENCE manutencao_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =============================================================================
-- SEÇÃO 2: INSERÇÃO DE DADOS INICIAIS (MÍNIMO 5 REGISTROS)
-- =============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserindo dados iniciais...');
    
    -- Inserir 5 Pátios
    INSERT INTO PATIO(PATIO_ID, NOME, LOCALIZACAO, CAPACIDADE) VALUES (patio_seq.NEXTVAL, 'Pátio Centro', 'Av. Paulista, 1000', 50);
    INSERT INTO PATIO(PATIO_ID, NOME, LOCALIZACAO, CAPACIDADE) VALUES (patio_seq.NEXTVAL, 'Pátio Zona Leste', 'Rua das Flores, 250', 70);
    INSERT INTO PATIO(PATIO_ID, NOME, LOCALIZACAO, CAPACIDADE) VALUES (patio_seq.NEXTVAL, 'Pátio Zona Oeste', 'Av. Imigrantes, 500', 60);
    INSERT INTO PATIO(PATIO_ID, NOME, LOCALIZACAO, CAPACIDADE) VALUES (patio_seq.NEXTVAL, 'Pátio Zona Norte', 'Estrada Velha, 100', 40);
    INSERT INTO PATIO(PATIO_ID, NOME, LOCALIZACAO, CAPACIDADE) VALUES (patio_seq.NEXTVAL, 'Pátio Zona Sul', 'Praça da Sé, 50', 55);
    
    -- Inserir 5 Motos com novos modelos e status
    INSERT INTO MOTO(MOTO_ID, PLACA, MODELO, ANO, PATIO_ID, STATUS) VALUES (moto_seq.NEXTVAL, 'ABC1234', 'Mottu Pop', 2023, 1, 'Pronta para aluguel');
    INSERT INTO MOTO(MOTO_ID, PLACA, MODELO, ANO, PATIO_ID, STATUS) VALUES (moto_seq.NEXTVAL, 'DEF5678', 'Mottu Sport', 2022, 1, 'Em manutencao');
    INSERT INTO MOTO(MOTO_ID, PLACA, MODELO, ANO, PATIO_ID, STATUS) VALUES (moto_seq.NEXTVAL, 'GHI9012', 'Mottu-E', 2023, 2, 'Pronta para aluguel');
    INSERT INTO MOTO(MOTO_ID, PLACA, MODELO, ANO, PATIO_ID, STATUS) VALUES (moto_seq.NEXTVAL, 'JKL3456', 'Mottu Pop', 2021, 2, 'Em quarentena');
    INSERT INTO MOTO(MOTO_ID, PLACA, MODELO, ANO, PATIO_ID, STATUS) VALUES (moto_seq.NEXTVAL, 'MNO7890', 'Mottu Sport', 2023, 3, 'Reservada');
    
    -- Inserir 5 Operadores
    INSERT INTO OPERADOR(OPERADOR_ID, NOME, EMAIL, PASSWORD, CARGO, PATIO_ID, SALARIO) 
    VALUES (operador_seq.NEXTVAL, 'Admin Mottu', 'admin@mottu.com', 'senha123', 'GESTOR', 1, 5000.00);
    INSERT INTO OPERADOR(OPERADOR_ID, NOME, EMAIL, PASSWORD, CARGO, PATIO_ID, SALARIO) 
    VALUES (operador_seq.NEXTVAL, 'João Silva', 'joao@mottu.com', 'senha123', 'OPERADOR', 1, 2500.00);
    INSERT INTO OPERADOR(OPERADOR_ID, NOME, EMAIL, PASSWORD, CARGO, PATIO_ID, SALARIO) 
    VALUES (operador_seq.NEXTVAL, 'Maria Santos', 'maria@mottu.com', 'senha123', 'OPERADOR', 2, 2500.00);
    INSERT INTO OPERADOR(OPERADOR_ID, NOME, EMAIL, PASSWORD, CARGO, PATIO_ID, SALARIO) 
    VALUES (operador_seq.NEXTVAL, 'Carlos Tecnico', 'carlos@mottu.com', 'senha123', 'TECNICO', 2, 3500.00);
    INSERT INTO OPERADOR(OPERADOR_ID, NOME, EMAIL, PASSWORD, CARGO, PATIO_ID, SALARIO) 
    VALUES (operador_seq.NEXTVAL, 'Ana Gerente', 'ana@mottu.com', 'senha123', 'GESTOR', 3, 5000.00);
    
    -- Inserir 5 Detecções
    INSERT INTO DETECCAO(DETECCAO_ID, MOTO_ID, PATIO_ID, TIPO_EVENTO, CONFIANCA_YOLO) 
    VALUES (deteccao_seq.NEXTVAL, 1, 1, 'ENTRADA', 0.95);
    INSERT INTO DETECCAO(DETECCAO_ID, MOTO_ID, PATIO_ID, TIPO_EVENTO, CONFIANCA_YOLO) 
    VALUES (deteccao_seq.NEXTVAL, 2, 1, 'SAIDA', 0.92);
    INSERT INTO DETECCAO(DETECCAO_ID, MOTO_ID, PATIO_ID, TIPO_EVENTO, CONFIANCA_YOLO) 
    VALUES (deteccao_seq.NEXTVAL, 3, 2, 'ENTRADA', 0.88);
    INSERT INTO DETECCAO(DETECCAO_ID, MOTO_ID, PATIO_ID, TIPO_EVENTO, CONFIANCA_YOLO) 
    VALUES (deteccao_seq.NEXTVAL, 4, 2, 'ENTRADA', 0.90);
    INSERT INTO DETECCAO(DETECCAO_ID, MOTO_ID, PATIO_ID, TIPO_EVENTO, CONFIANCA_YOLO) 
    VALUES (deteccao_seq.NEXTVAL, 5, 3, 'SAIDA', 0.91);
    
    -- Inserir 5 Manutenções
    INSERT INTO MANUTENCAO(MANUTENCAO_ID, MOTO_ID, OPERADOR_ID, TIPO_SERVICO, CUSTO) 
    VALUES (manutencao_seq.NEXTVAL, 1, 4, 'Revisao de oleo', 150.00);
    INSERT INTO MANUTENCAO(MANUTENCAO_ID, MOTO_ID, OPERADOR_ID, TIPO_SERVICO, CUSTO) 
    VALUES (manutencao_seq.NEXTVAL, 4, 4, 'Reparo de pneu', 200.00);
    INSERT INTO MANUTENCAO(MANUTENCAO_ID, MOTO_ID, OPERADOR_ID, TIPO_SERVICO, CUSTO) 
    VALUES (manutencao_seq.NEXTVAL, 2, 4, 'Limpeza completa', 100.00);
    INSERT INTO MANUTENCAO(MANUTENCAO_ID, MOTO_ID, OPERADOR_ID, TIPO_SERVICO, CUSTO) 
    VALUES (manutencao_seq.NEXTVAL, 3, 4, 'Inspecao de seguranca', 120.00);
    INSERT INTO MANUTENCAO(MANUTENCAO_ID, MOTO_ID, OPERADOR_ID, TIPO_SERVICO, CUSTO) 
    VALUES (manutencao_seq.NEXTVAL, 5, 4, 'Troca de bateria', 300.00);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de dados iniciais concluida.');
END;
/

-- =============================================================================
-- SEÇÃO 3: PROCEDURES, FUNÇÕES E TRIGGER
-- =============================================================================

-- FUNÇÃO 1: Converte um SYS_REFCURSOR para JSON 
CREATE OR REPLACE FUNCTION FNC_RELACIONAL_PARA_JSON (
    p_cursor IN SYS_REFCURSOR
) RETURN CLOB
IS
    v_json_clob CLOB;
    v_col_count INTEGER;
    v_desc_tab DBMS_SQL.DESC_TAB;
    v_cursor_id INTEGER;
    v_col_value VARCHAR2(4000);
    v_is_first_row BOOLEAN := TRUE;
    l_cursor SYS_REFCURSOR;
BEGIN
    l_cursor := p_cursor;
    v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(l_cursor);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_count, v_desc_tab);
    
    FOR i IN 1..v_col_count LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_col_value, 4000);
    END LOOP;
    
    v_json_clob := '[';
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
        IF NOT v_is_first_row THEN v_json_clob := v_json_clob || ','; END IF;
        v_json_clob := v_json_clob || CHR(10) || '{';
        FOR i IN 1..v_col_count LOOP
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_col_value);
            v_json_clob := v_json_clob || '"' || LOWER(v_desc_tab(i).col_name) || '":"' || REPLACE(v_col_value, '"', '\"') || '"';
            IF i < v_col_count THEN v_json_clob := v_json_clob || ','; END IF;
        END LOOP;
        v_json_clob := v_json_clob || '}';
        v_is_first_row := FALSE;
    END LOOP;
    v_json_clob := v_json_clob || CHR(10) || ']';
    
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    IF v_is_first_row THEN RETURN '[]'; END IF;
    RETURN v_json_clob;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN DBMS_SQL.CLOSE_CURSOR(v_cursor_id); END IF;
        RETURN '{"erro": "Nenhum dado encontrado no cursor."}';
    WHEN INVALID_CURSOR THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN DBMS_SQL.CLOSE_CURSOR(v_cursor_id); END IF;
        RETURN '{"erro": "Cursor invalido ou fechado fornecido."}';
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN DBMS_SQL.CLOSE_CURSOR(v_cursor_id); END IF;
        RETURN '{"erro": "Ocorreu um erro ao converter para JSON: ' || SQLERRM || '"}';
END FNC_RELACIONAL_PARA_JSON;
/

-- PROCEDIMENTO 1: Lista detecções com JOIN entre DETECCAO e MOTO, retornando em JSON
CREATE OR REPLACE PROCEDURE PRC_LISTAR_DETECCOES_JSON
IS
    v_cursor SYS_REFCURSOR;
    v_json_result CLOB;
    e_nenhuma_deteccao EXCEPTION;
BEGIN
    OPEN v_cursor FOR
        SELECT d.DETECCAO_ID, m.PLACA, m.MODELO, d.TIPO_EVENTO, d.TIMESTAMP_DETECCAO, d.CONFIANCA_YOLO
        FROM DETECCAO d 
        JOIN MOTO m ON d.MOTO_ID = m.MOTO_ID
        ORDER BY d.TIMESTAMP_DETECCAO DESC;
    
    v_json_result := FNC_RELACIONAL_PARA_JSON(v_cursor);
    
    IF v_json_result = '[]' THEN 
        RAISE e_nenhuma_deteccao; 
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('--- Relatorio de Deteccoes em formato JSON ---');
    DBMS_OUTPUT.PUT_LINE(v_json_result);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
EXCEPTION
    WHEN e_nenhuma_deteccao THEN DBMS_OUTPUT.PUT_LINE('Erro Tratado: Nenhuma deteccao encontrada para gerar o relatorio.');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Erro Tratado: A consulta nao retornou nenhum dado (NO_DATA_FOUND).');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Erro Tratado Inesperado no procedimento PRC_LISTAR_DETECCOES_JSON: ' || SQLERRM);
END PRC_LISTAR_DETECCOES_JSON;
/

-- FUNÇÃO 2: Verifica disponibilidade de vagas no pátio e motos prontas para aluguel
CREATE OR REPLACE FUNCTION FNC_VERIFICAR_VAGA_PATIO (p_patio_id IN NUMBER) RETURN NUMBER
IS
    v_capacidade NUMBER;
    v_motos_prontas NUMBER;
    e_capacidade_invalida EXCEPTION;
BEGIN
    SELECT CAPACIDADE INTO v_capacidade FROM PATIO WHERE PATIO_ID = p_patio_id;
    IF v_capacidade IS NULL OR v_capacidade <= 0 THEN 
        RAISE e_capacidade_invalida; 
    END IF;
    
    SELECT COUNT(*) INTO v_motos_prontas FROM MOTO WHERE PATIO_ID = p_patio_id AND STATUS = 'Pronta para aluguel';
    
    IF v_motos_prontas > 0 THEN 
        RETURN 1; 
    ELSE 
        RETURN 0; 
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002, 'Erro Tratado: Patio com ID ' || p_patio_id || ' nao encontrado.');
    WHEN e_capacidade_invalida THEN RAISE_APPLICATION_ERROR(-20003, 'Erro Tratado: A capacidade do patio ' || p_patio_id || ' nao e valida.');
    WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20004, 'Erro Tratado Inesperado ao verificar vagas: ' || SQLERRM);
END FNC_VERIFICAR_VAGA_PATIO;
/

-- PROCEDIMENTO 2: Relatório de custos de manutenção por pátio e operador (agregação manual)A
CREATE OR REPLACE PROCEDURE PRC_RELATORIO_CUSTOS_MANUAL
IS
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
    DBMS_OUTPUT.PUT_LINE('--- Relatorio de Custos de Manutencao por Patio e Cargo ---');
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
        DBMS_OUTPUT.PUT_LINE('Nenhuma manutencao encontrada para o relatorio.'); 
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('Erro Tratado: Nenhuma manutencao foi encontrada para o relatorio.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro Tratado: Ocorreu um erro de conversao de dados no relatorio de custos.');
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Erro Tratado Inesperado ao gerar relatorio de custos: ' || SQLERRM);
END PRC_RELATORIO_CUSTOS_MANUAL;
/

-- Tabela de Auditoria para registrar alteracoes na tabela MOTO
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE AUDITORIA (
        ID_AUDITORIA NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
        NOME_USUARIO VARCHAR2(100),
        TIPO_OPERACAO VARCHAR2(10),
        DATA_HORA TIMESTAMP,
        VALORES_ANTERIORES CLOB,
        VALORES_NOVOS CLOB
    )';
EXCEPTION WHEN OTHERS THEN IF SQLCODE = -955 THEN DBMS_OUTPUT.PUT_LINE('Tabela AUDITORIA ja existe.'); ELSE RAISE; END IF;
END;
/

-- TRIGGER: Auditoria de operações DML na tabela MOTO
CREATE OR REPLACE TRIGGER TRG_AUDITA_MOTO
AFTER INSERT OR UPDATE OR DELETE ON MOTO
FOR EACH ROW
DECLARE
    v_old_values CLOB;
    v_new_values CLOB;
BEGIN
    IF DELETING OR UPDATING THEN 
        v_old_values := 'MOTO_ID=' || :OLD.MOTO_ID || ', PLACA=' || :OLD.PLACA || ', MODELO=' || :OLD.MODELO || ', ANO=' || :OLD.ANO || ', STATUS=' || :OLD.STATUS; 
    END IF;
    IF INSERTING OR UPDATING THEN 
        v_new_values := 'MOTO_ID=' || :NEW.MOTO_ID || ', PLACA=' || :NEW.PLACA || ', MODELO=' || :NEW.MODELO || ', ANO=' || :NEW.ANO || ', STATUS=' || :NEW.STATUS; 
    END IF;
    
    IF INSERTING THEN 
        INSERT INTO AUDITORIA (NOME_USUARIO, TIPO_OPERACAO, DATA_HORA, VALORES_NOVOS) VALUES (USER, 'INSERT', SYSTIMESTAMP, v_new_values);
    ELSIF UPDATING THEN 
        INSERT INTO AUDITORIA (NOME_USUARIO, TIPO_OPERACAO, DATA_HORA, VALORES_ANTERIORES, VALORES_NOVOS) VALUES (USER, 'UPDATE', SYSTIMESTAMP, v_old_values, v_new_values);
    ELSIF DELETING THEN 
        INSERT INTO AUDITORIA (NOME_USUARIO, TIPO_OPERACAO, DATA_HORA, VALORES_ANTERIORES) VALUES (USER, 'DELETE', SYSTIMESTAMP, v_old_values); 
    END IF;
EXCEPTION 
    WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20001, 'Erro no trigger de auditoria: ' || SQLERRM);
END TRG_AUDITA_MOTO;
/

-- =============================================================================
-- SEÇÃO 4: BLOCO DE TESTES E EXECUÇÃO FINAL
-- =============================================================================
DECLARE
    v_tem_vaga NUMBER;
    v_cursor_teste SYS_REFCURSOR;
    v_json_teste CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '========== EXECUTANDO TESTES DA SPRINT 3 ==========');
    
    -- ===================================
    -- Testes de SUCESSO
    -- ===================================
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- TESTES DE SUCESSO ---');
    
    -- Teste Procedimento 1 (Sucesso)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 1: Procedimento PRC_LISTAR_DETECCOES_JSON');
    PRC_LISTAR_DETECCOES_JSON;
    
    -- Teste Trigger (Sucesso)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 2: Trigger TRG_AUDITA_MOTO - Testando INSERT');
    INSERT INTO MOTO (MOTO_ID, PLACA, MODELO, ANO, PATIO_ID, STATUS) VALUES (moto_seq.NEXTVAL, 'TEST001', 'Mottu Pop', 2023, 1, 'Pronta para aluguel');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Moto de teste inserida. Auditoria registrada.');
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 3: Trigger TRG_AUDITA_MOTO - Testando UPDATE');
    UPDATE MOTO SET STATUS = 'Em manutencao' WHERE PLACA = 'TEST001';
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Moto de teste atualizada. Auditoria registrada.');
    
    -- Teste Função 2 (Sucesso)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 4: Funcao FNC_VERIFICAR_VAGA_PATIO - Patio 1');
    v_tem_vaga := FNC_VERIFICAR_VAGA_PATIO(p_patio_id => 1);
    IF v_tem_vaga = 1 THEN 
        DBMS_OUTPUT.PUT_LINE('Resultado: Ha motos prontas para aluguel no Patio 1.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Resultado: Nenhuma moto pronta para aluguel no Patio 1.'); 
    END IF;

    -- Teste Procedimento 2 (Sucesso)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 5: Procedimento PRC_RELATORIO_CUSTOS_MANUAL');
    PRC_RELATORIO_CUSTOS_MANUAL;

    -- ===================================
    -- Testes de EXCEÇÃO
    -- ===================================
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- TESTES DE EXCEÇÃO ---');
    
    -- Teste de Exceção para a Função 2
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 6: Exceção em FNC_VERIFICAR_VAGA_PATIO - Patio inexistente (ID 999)');
        v_tem_vaga := FNC_VERIFICAR_VAGA_PATIO(p_patio_id => 999);
    EXCEPTION 
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Exceção capturada corretamente: ' || SQLERRM);
    END;

    -- Teste de Exceção para o Procedimento 1
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 7: Exceção em PRC_LISTAR_DETECCOES_JSON - Cursor invalido');
    v_json_teste := FNC_RELACIONAL_PARA_JSON(v_cursor_teste);
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_json_teste);

    -- Teste de Exceção para o Procedimento 2 - Deletando temporariamente dados
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 8: Exceção em PRC_RELATORIO_CUSTOS_MANUAL - Nenhuma manutencao');
        DELETE FROM MANUTENCAO;
        PRC_RELATORIO_CUSTOS_MANUAL;
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Rollback executado - dados restaurados.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Exceção capturada: ' || SQLERRM);
            ROLLBACK;
    END;

    -- Teste de Trigger - Deletando e verificando auditoria
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 9: Trigger TRG_AUDITA_MOTO - Testando DELETE');
    DELETE FROM MOTO WHERE PLACA = 'TEST001';
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Moto de teste deletada. Auditoria registrada.');
    
    -- Exibir registros de auditoria
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'TESTE 10: Verificando registros na tabela AUDITORIA');
    FOR rec IN (SELECT TIPO_OPERACAO, DATA_HORA, VALORES_ANTERIORES, VALORES_NOVOS FROM AUDITORIA ORDER BY DATA_HORA DESC FETCH FIRST 5 ROWS ONLY) LOOP
        DBMS_OUTPUT.PUT_LINE('Operacao: ' || rec.TIPO_OPERACAO || ' | Hora: ' || rec.DATA_HORA);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '========== TESTES FINALIZADOS COM SUCESSO ==========');
END;
/