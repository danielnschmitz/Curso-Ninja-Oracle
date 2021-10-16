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
                          I_DS_MODELO     IN CARRO.DS_MODELO%TYPE,
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
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'ERRO: '||SQLERRM;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro ao inserir nota fiscal. Erro: '||SQLERRM;
  END;
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------
  --1. Criar um procedimento para inserir/atualizar o carro (sem a informação de pessoa)
  PROCEDURE INSERE_cARRO (I_NR_PLACA      IN CARRO.NR_PLACA%TYPE,
                          I_DS_MODELO     IN CARRO.DS_MODELO%TYPE,
                          I_DT_COMPRA     IN CARRO.DT_COMPRA%TYPE,
                          I_VL_VENDA      IN CARRO.VL_VENDA%TYPE,
                          I_NR_ANOMODELO  IN CARRO.NR_ANOMODELO%TYPE,
                          O_MENSAGEM      OUT VARCHAR2) IS
  
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
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir veículo. Erro: '||SQLERRM;
    END;
    
    COMMIT;
    
  EXCEPTION
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
  BEGIN
    
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
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir pessoa. Erro: '||SQLERRM;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro no procedimento que insere uma pessoa: '||SQLERRM;
  END;
 
END PACK_NOTAFISCAL;
/
