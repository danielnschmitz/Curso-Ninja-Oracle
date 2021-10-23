CREATE OR REPLACE PACKAGE PACK_NOTAFISCAL IS

  -- AUTHOR  : DANIEL.NATAN
  -- CREATED : 16/10/2021 13:15:39
  -- PURPOSE : PACOTE PARA CENTRALIZAR OS PROCEDIMENTOS REFERENTES A NOTA FISCAL
  
  PROCEDURE INSERE_NOTA (I_NR_NOTA     IN NOTAFISCAL.NR_NOTA%TYPE,
                         I_VL_NOTA     IN NOTAFISCAL.VL_NOTA%TYPE,
                         I_DS_VENDEDOR IN NOTAFISCAL.DS_VENDEDOR%TYPE,
                         I_DS_CLIENTE  IN NOTAFISCAL.DS_CLIENTE%TYPE,
                         I_DT_COMPRA   IN NOTAFISCAL.DT_COMPRA%TYPE,
                         O_MENSAGEM    OUT VARCHAR2);
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------                       
  PROCEDURE INSERE_cARRO (I_NR_PLACA      IN CARRO.NR_PLACA%TYPE,
                          I_DS_MODELO     IN VARCHAR2,
                          I_DT_COMPRA     IN CARRO.DT_COMPRA%TYPE,
                          I_VL_VENDA      IN CARRO.VL_VENDA%TYPE,
                          I_NR_ANOMODELO  IN CARRO.NR_ANOMODELO%TYPE,
                          O_MENSAGEM      OUT VARCHAR2);
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------                       
  PROCEDURE INSERE_PESSOA (I_NM_PESSOA     IN PESSOA.NM_PESSOA%TYPE,
                           I_NR_CPF        IN PESSOA.NR_CPF%TYPE,
                           I_DT_NASCIMENTO IN PESSOA.DT_NASCIMENTO%TYPE,
                           I_ID_PESSOA     IN PESSOA.ID_PESSOA%TYPE,
                           I_NR_ALTURA     IN PESSOA.NR_ALTURA%TYPE,
                           O_MENSAGEM      OUT VARCHAR2);
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_CARRO (I_NR_PLACA   IN CARRO.NR_PLACA%TYPE,
                          O_MENSAGEM   OUT VARCHAR2);
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  PROCEDURE INSERE_ITEMNOTA (I_ID_ITEM  IN ITEMNOTA.ID_ITEM%TYPE,
                             I_VL_ITEM  IN ITEMNOTA.VL_ITEM%TYPE,
                             I_DS_ITEM  IN ITEMNOTA.DS_ITEM%TYPE,
                             I_NR_NOTA  IN ITEMNOTA.NR_NOTA%TYPE,
                             O_MENSAGEM OUT VARCHAR2);
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION RETORNA_QUANTIDADECARROS (I_NR_ANOMODELO IN CARRO.NR_ANOMODELO%TYPE)
                                                     RETURN NUMBER;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --1 - Crie uma função que receba o número de uma nota e retorne o seu valor
  FUNCTION RETORNA_VALORNOTA (I_NR_NOTA IN NOTAFISCAL.NR_NOTA%TYPE) 
                                  RETURN NOTAFISCAL.VL_NOTA%TYPE;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --2 - Crie uma função que receba a data e retorne a quantidade de notas
  -- emitidas naquela data 
  FUNCTION RETORNA_QTDENOTAS (I_DT_COMPRA IN NOTAFISCAL.DT_COMPRA%TYPE)
                                          RETURN NUMBER;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --3 - Crie uma função que receba o nome de um vendedor e retorne quantas
  -- notas foram emitidas por ele
  FUNCTION RETORNA_QTVENDAS_VENDEDOR (I_DS_VENDEDOR IN NOTAFISCAL.DS_VENDEDOR%TYPE)
                                     RETURN NUMBER;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION RETORNA_VALORTOTALNOTAS RETURN NUMBER;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --Crie uma função que retorne o nome de todos os clientes, sem repetir, em 
  --uma string separado por vírgulas
  FUNCTION RETORNA_NOMECLIENTES RETURN VARCHAR2;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION TESTE_VETOR RETURN VARCHAR2;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION RETORNA_CLIENTEVALOR RETURN VARCHAR2;
END PACK_NOTAFISCAL;
/
CREATE OR REPLACE PACKAGE BODY PACK_NOTAFISCAL IS
  PROCEDURE INSERE_NOTA (I_NR_NOTA     IN NOTAFISCAL.NR_NOTA%TYPE,
                         I_VL_NOTA     IN NOTAFISCAL.VL_NOTA%TYPE,
                         I_DS_VENDEDOR IN NOTAFISCAL.DS_VENDEDOR%TYPE,
                         I_DS_CLIENTE  IN NOTAFISCAL.DS_CLIENTE%TYPE,
                         I_DT_COMPRA   IN NOTAFISCAL.DT_COMPRA%TYPE,
                         O_MENSAGEM    OUT VARCHAR2) IS
    V_NR_NOTA NOTAFISCAL.NR_NOTA%TYPE;
    E_GERAL   EXCEPTION;
  BEGIN
    
    SELECT MAX(NOTAFISCAL.NR_NOTA)
      INTO V_NR_NOTA
      FROM NOTAFISCAL;
    
    /*
    V_NR_NOTA = NULL
    V_NR_NOTA = 1..N
    */
    
    V_NR_NOTA := NVL(V_NR_NOTA,0) + 1;
    
    BEGIN
      INSERT INTO NOTAFISCAL
       (NR_NOTA,
        VL_NOTA,
        DS_VENDEDOR,
        DS_CLIENTE,
        DT_COMPRA)
      VALUES
       (NVL(I_NR_NOTA,V_NR_NOTA),
        I_VL_NOTA,
        I_DS_VENDEDOR,
        I_DS_CLIENTE,
        SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE NOTAFISCAL
             SET VL_NOTA = I_VL_NOTA,
                 DS_VENDEDOR = I_DS_VENDEDOR,
                 DS_CLIENTE = I_DS_CLIENTE,
                 DT_COMPRA = I_DT_COMPRA
           WHERE NR_NOTA = I_NR_NOTA;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar nota. Erro: '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'ERRO: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[INSERE NOTA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro ao inserir nota fiscal. Erro: '||SQLERRM;
  END;
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  --1. Criar um procedimento para inserir/atualizar o carro (sem a informação de pessoa)
  PROCEDURE INSERE_CARRO (I_NR_PLACA      IN CARRO.NR_PLACA%TYPE,
                          I_DS_MODELO     IN VARCHAR2,
                          I_DT_COMPRA     IN CARRO.DT_COMPRA%TYPE,
                          I_VL_VENDA      IN CARRO.VL_VENDA%TYPE,
                          I_NR_ANOMODELO  IN CARRO.NR_ANOMODELO%TYPE,
                          O_MENSAGEM      OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    BEGIN
      INSERT INTO CARRO(
        NR_PLACA,
        DS_MODELO,
        DT_COMPRA,
        VL_VENDA,
        NR_ANOMODELO)
      VALUES(
        I_NR_PLACA,
        I_DS_MODELO,
        I_DT_COMPRA,
        I_VL_VENDA,
        I_NR_ANOMODELO);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE CARRO
             SET DS_MODELO = I_DS_MODELO,
                 DT_COMPRA = I_DT_COMPRA,
                 VL_VENDA  = I_VL_VENDA,
                 NR_ANOMODELO = I_NR_ANOMODELO
           WHERE NR_PLACA = I_NR_PLACA;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar veículo. Erro: '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir veículo. Erro: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
    --CARRO CADASTRADO
    
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[INSERE_CARRO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento que insere o carro: '||SQLERRM;
  END;                
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  --2. Criar um procedimento para inserir/atualizar uma pessoa
  PROCEDURE INSERE_PESSOA (I_NM_PESSOA     IN PESSOA.NM_PESSOA%TYPE,
                           I_NR_CPF        IN PESSOA.NR_CPF%TYPE,
                           I_DT_NASCIMENTO IN PESSOA.DT_NASCIMENTO%TYPE,
                           I_ID_PESSOA     IN PESSOA.ID_PESSOA%TYPE,
                           I_NR_ALTURA     IN PESSOA.NR_ALTURA%TYPE,
                           O_MENSAGEM      OUT VARCHAR2) IS
    V_ID_PESSOA PESSOA.ID_PESSOA%TYPE;
    E_GERAL     EXCEPTION;
  BEGIN
    
    IF I_NM_PESSOA IS NULL THEN
      O_MENSAGEM := 'O nome precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_NR_CPF IS NULL THEN
      O_MENSAGEM := 'O CPF precisa ser informado!';
      RAISE E_GERAL;
    END IF;
    
    IF I_DT_NASCIMENTO IS NULL THEN
      O_MENSAGEM := 'A data de nascimento precisa ser informada!';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CPF) <> 11 THEN
      O_MENSAGEM := 'CPF informado é inválido!';
      RAISE E_GERAL;
    END IF;
    
    IF INSTR(I_NM_PESSOA,' ') = 0 THEN
      O_MENSAGEM := 'Precisa ser informado o nome completo!';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT MAX(PESSOA.ID_PESSOA)
        INTO V_ID_PESSOA
        FROM PESSOA;
    EXCEPTION
      WHEN OTHERS THEN
        V_ID_PESSOA := 0;
    END;
    
    V_ID_PESSOA := NVL(V_ID_PESSOA,0) + 1;
    
    BEGIN
      INSERT INTO PESSOA(
        NM_PESSOA,
        NR_CPF,
        DT_NASCIMENTO,
        ID_PESSOA,
        NR_ALTURA)
      VALUES(
        I_NM_PESSOA,
        I_NR_CPF,
        I_DT_NASCIMENTO,
        NVL(I_ID_PESSOA,V_ID_PESSOA),
        I_NR_ALTURA);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE PESSOA
             SET NM_PESSOA     = I_NM_PESSOA,
                 NR_CPF        = I_NR_CPF,
                 DT_NASCIMENTO = I_DT_NASCIMENTO,
                 NR_ALTURA     = I_NR_ALTURA
           WHERE ID_PESSOA = I_ID_PESSOA;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar pessoa. Erro: '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir pessoa. Erro: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := 'INSERE_PESSOA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento que insere uma pessoa: '||SQLERRM;
  END;
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_CARRO (I_NR_PLACA   IN CARRO.NR_PLACA%TYPE,
                          O_MENSAGEM   OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    IF I_NR_PLACA IS NULL THEN
      O_MENSAGEM := 'Informe a placa';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE CARRO
       WHERE NR_PLACA = I_NR_PLACA;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir carro: '||SQLERRM;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[EXCLUI_CARRO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento de exclusão de carro: '||SQLERRM;
  END;
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  PROCEDURE INSERE_ITEMNOTA (I_ID_ITEM  IN ITEMNOTA.ID_ITEM%TYPE,
                             I_VL_ITEM  IN ITEMNOTA.VL_ITEM%TYPE,
                             I_DS_ITEM  IN ITEMNOTA.DS_ITEM%TYPE,
                             I_NR_NOTA  IN ITEMNOTA.NR_NOTA%TYPE,
                             O_MENSAGEM OUT VARCHAR2) IS
    E_GERAL    EXCEPTION;
    V_ID_ITEM  ITEMNOTA.ID_ITEM%TYPE;
    V_COUNT    NUMBER;
  BEGIN
    IF I_VL_ITEM IS NULL THEN
      O_MENSAGEM := 'O valor do item precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    IF I_DS_ITEM IS NULL THEN
      O_MENSAGEM := 'A descrição precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    IF I_NR_NOTA IS NULL THEN
      O_MENSAGEM := 'O número da nota, precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM NOTAFISCAL
       WHERE NOTAFISCAL.NR_NOTA = I_NR_NOTA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF V_COUNT = 0 THEN
      O_MENSAGEM := 'Nota '||I_NR_NOTA||' não cadastrada';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT MAX(ITEMNOTA.ID_ITEM)
        INTO V_ID_ITEM
        FROM ITEMNOTA;
    EXCEPTION
      WHEN OTHERS THEN
        V_ID_ITEM := 0;
    END;
    
    V_ID_ITEM := V_ID_ITEM + 1;
    V_ID_ITEM := NVL(I_ID_ITEM,V_ID_ITEM);
    
    BEGIN
      INSERT INTO ITEMNOTA(
        ID_ITEM,
        VL_ITEM,
        DS_ITEM,
        NR_NOTA)
      VALUES(
        V_ID_ITEM,
        I_VL_ITEM,
        I_DS_ITEM,
        I_NR_NOTA);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE ITEMNOTA
             SET VL_ITEM = I_VL_ITEM,
                 DS_ITEM = I_DS_ITEM
           WHERE ID_ITEM = I_ID_ITEM;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atulizar o item: '||SQLERRM;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir nota: '||SQLERRM;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[INSERE_ITEMNOTA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento que insere nota: '||SQLERRM;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION RETORNA_QUANTIDADECARROS (I_NR_ANOMODELO IN CARRO.NR_ANOMODELO%TYPE)
                                                     RETURN NUMBER IS
    V_COUNT NUMBER;
  BEGIN
    
    SELECT COUNT(*)
      INTO V_COUNT
      FROM CARRO
     WHERE CARRO.NR_ANOMODELO = I_NR_ANOMODELO;
     
    RETURN V_COUNT;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --1 - Crie uma função que receba o número de uma nota e retorne o seu valor
  FUNCTION RETORNA_VALORNOTA (I_NR_NOTA IN NOTAFISCAL.NR_NOTA%TYPE) 
                                  RETURN NOTAFISCAL.VL_NOTA%TYPE IS
    V_VL_NOTA NOTAFISCAL.VL_NOTA%TYPE;
  BEGIN
    SELECT NOTAFISCAL.VL_NOTA
      INTO V_VL_NOTA
      FROM NOTAFISCAL
     WHERE NOTAFISCAL.NR_NOTA = I_NR_NOTA;
     
    RETURN V_VL_NOTA;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --2 - Crie uma função que receba a data e retorne a quantidade de notas
  -- emitidas naquela data 
  FUNCTION RETORNA_QTDENOTAS (I_DT_COMPRA IN NOTAFISCAL.DT_COMPRA%TYPE)
                                          RETURN NUMBER IS
    V_COUNT NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM NOTAFISCAL
     WHERE NOTAFISCAL.DT_COMPRA = I_DT_COMPRA;
    
    RETURN V_COUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --3 - Crie uma função que receba o nome de um vendedor e retorne quantas
  -- notas foram emitidas por ele
  FUNCTION RETORNA_QTVENDAS_VENDEDOR (I_DS_VENDEDOR IN NOTAFISCAL.DS_VENDEDOR%TYPE)
                                     RETURN NUMBER IS
    V_COUNT NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM NOTAFISCAL
     WHERE NOTAFISCAL.DS_VENDEDOR = I_DS_VENDEDOR;
    
    RETURN V_COUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION RETORNA_VALORTOTALNOTAS RETURN NUMBER IS
    V_VL_SUMNF  NUMBER;
    
    CURSOR CUR_NOTAS IS
      SELECT NOTAFISCAL.VL_NOTA
        FROM NOTAFISCAL;
  BEGIN
    V_VL_SUMNF := 0; 
    FOR I IN CUR_NOTAS LOOP
      V_VL_SUMNF := V_VL_SUMNF + NVL(I.VL_NOTA,0);
    END LOOP;
    
    RETURN V_VL_SUMNF;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --Crie uma função que retorne o nome de todos os clientes, sem repetir, em 
  --uma string separado por vírgulas
  FUNCTION RETORNA_NOMECLIENTES RETURN VARCHAR2 IS
    V_DS_NOMECLIENTES VARCHAR2(32000);
    
    V_COUNT NUMBER;
    
    CURSOR CUR_CLIENTES IS
      SELECT DISTINCT NOTAFISCAL.DS_CLIENTE
        FROM NOTAFISCAL;
  BEGIN
    V_COUNT := 0;
    FOR I IN CUR_CLIENTES LOOP
      V_COUNT := V_COUNT+1;
      IF V_COUNT = 1 THEN
        V_DS_NOMECLIENTES := I.DS_CLIENTE;
      ELSE
        V_DS_NOMECLIENTES := V_DS_NOMECLIENTES||', '||I.DS_CLIENTE;
      END IF;
    END LOOP;
    
    FOR I IN CUR_CLIENTES LOOP
      IF CUR_CLIENTES%ROWCOUNT = 1 THEN
        V_DS_NOMECLIENTES := I.DS_CLIENTE;
      ELSE
        V_DS_NOMECLIENTES := V_DS_NOMECLIENTES||', '||I.DS_CLIENTE;
      END IF;
    END LOOP;
    
    RETURN V_DS_NOMECLIENTES;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION TESTE_VETOR RETURN VARCHAR2 IS
    TYPE T_CLIENTES IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
    V_CLIENTES T_CLIENTES;
    
    V_DS_CLIENTES VARCHAR2(32000);
    
    CURSOR CUR_CLIENTES IS
      SELECT DISTINCT NOTAFISCAL.DS_CLIENTE
        FROM NOTAFISCAL;
  BEGIN
    
    FOR I IN CUR_CLIENTES LOOP
      V_CLIENTES(CUR_CLIENTES%ROWCOUNT) := I.DS_CLIENTE;
    END LOOP;
    
    FOR I IN 1..V_CLIENTES.COUNT LOOP
      IF I = 1 THEN
        V_DS_CLIENTES := V_CLIENTES(I);
      ELSE
        V_DS_CLIENTES := V_DS_CLIENTES||', '||V_CLIENTES(I);
      END IF;
    END LOOP;
    
    RETURN V_DS_CLIENTES;
      
    
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  FUNCTION RETORNA_CLIENTEVALOR RETURN VARCHAR2 IS
    TYPE R_CLIENTE IS RECORD(DS_CLIENTE  NOTAFISCAL.DS_CLIENTE%TYPE,
                             VL_CLIENTE  NUMBER);
    TYPE T_CLIENTE IS TABLE OF R_CLIENTE INDEX BY BINARY_INTEGER;
    V_CLIENTE T_CLIENTE;
    
    V_DS_CLIENTES  VARCHAR2(32000);
    
    CURSOR CUR_CLIENTES IS
      SELECT NOTAFISCAL.DS_CLIENTE, SUM(NOTAFISCAL.VL_NOTA) VL_CLIENTE
        FROM NOTAFISCAL
       GROUP BY NOTAFISCAL.DS_CLIENTE;
  BEGIN
    
    FOR I IN CUR_CLIENTES LOOP
      V_CLIENTE(CUR_CLIENTES%ROWCOUNT).DS_CLIENTE := I.DS_CLIENTE;
      V_CLIENTE(CUR_CLIENTES%ROWCOUNT).VL_CLIENTE := I.VL_CLIENTE;
    END LOOP;
    
    FOR I IN 1..V_CLIENTE.COUNT LOOP
      IF I = 1 THEN
        V_DS_CLIENTES := V_CLIENTE(I).DS_CLIENTE||' ('||
                            V_CLIENTE(I).VL_CLIENTE||')';
      ELSE
        V_DS_CLIENTES := V_DS_CLIENTES||', '||V_CLIENTE(I).DS_CLIENTE||' ('||
                            V_CLIENTE(I).VL_CLIENTE||')';
      END IF;
    END LOOP;
    
    RETURN V_DS_CLIENTES;
  END;
END PACK_NOTAFISCAL;
/
