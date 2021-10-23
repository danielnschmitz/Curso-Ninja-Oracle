CREATE OR REPLACE PACKAGE PACK_POSTO IS
  PROCEDURE GRAVA_COMBUSTIVEL(IO_CD_COMBUSTIVEL IN OUT COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                              I_DS_COMBUSTIVEL  IN COMBUSTIVEL.DS_COMBUSTIVEL%TYPE,
                              I_VL_COMBUSTIVEL  IN COMBUSTIVEL.VL_COMBUSTIVEL%TYPE,
                              O_MENSAGEM        OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_PROPRIETARIO(IO_CD_PROPRIETARIO IN OUT PROPRIETARIO.CD_PROPRIETARIO%TYPE,
                               I_NM_PROPRIETARIO  IN PROPRIETARIO.NM_PROPRIETARIO%TYPE,
                               I_NR_CNPJCPF       IN PROPRIETARIO.NR_CNPJCPF%TYPE,
                               I_DS_ENDERECO      IN PROPRIETARIO.DS_ENDERECO%TYPE,
                               I_NR_TELEFONE      IN PROPRIETARIO.NR_TELEFONE%TYPE,
                               O_MENSAGEM         OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_VEICULO(I_NR_PLACA        IN VEICULO.NR_PLACA%TYPE,
                          I_CD_COMBUSTIVEL  IN COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                          I_CD_PROPRIETARIO IN PROPRIETARIO.CD_PROPRIETARIO%TYPE,
                          I_KM_ATUAL        IN VEICULO.KM_ATUAL%TYPE,
                          O_MENSAGEM        OUT VARCHAR2);
END PACK_POSTO;
/
CREATE OR REPLACE PACKAGE BODY PACK_POSTO IS
  PROCEDURE GRAVA_COMBUSTIVEL(IO_CD_COMBUSTIVEL IN OUT COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                              I_DS_COMBUSTIVEL  IN COMBUSTIVEL.DS_COMBUSTIVEL%TYPE,
                              I_VL_COMBUSTIVEL  IN COMBUSTIVEL.VL_COMBUSTIVEL%TYPE,
                              O_MENSAGEM        OUT VARCHAR2) IS
    E_GERAL             EXCEPTION;
  BEGIN
    IF I_DS_COMBUSTIVEL IS NULL THEN
      O_MENSAGEM := 'A descrição do combustível precisa ser informada.';
      RAISE E_GERAL;
    END IF;
    
    IF I_VL_COMBUSTIVEL IS NULL THEN
      O_MENSAGEM := 'O valor do combustível precisa ser informado.';
      RAISE E_GERAL;
    END IF;
    
    IF IO_CD_COMBUSTIVEL IS NULL THEN
      BEGIN
        SELECT MAX(COMBUSTIVEL.CD_COMBUSTIVEL)
          INTO IO_CD_COMBUSTIVEL
          FROM COMBUSTIVEL;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_COMBUSTIVEL := 0;
      END;
      
      IO_CD_COMBUSTIVEL := NVL(IO_CD_COMBUSTIVEL,0) + 1;
    END IF;
    
    BEGIN
      INSERT INTO COMBUSTIVEL(
        CD_COMBUSTIVEL,
        DS_COMBUSTIVEL,
        VL_COMBUSTIVEL,
        DT_RECORD)
      VALUES(
        IO_CD_COMBUSTIVEL,
        I_DS_COMBUSTIVEL,
        I_VL_COMBUSTIVEL,
        SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE COMBUSTIVEL
             SET DS_COMBUSTIVEL = I_DS_COMBUSTIVEL,
                 VL_COMBUSTIVEL = I_VL_COMBUSTIVEL,
                 DT_REFRESH     = SYSDATE
           WHERE CD_COMBUSTIVEL = IO_CD_COMBUSTIVEL;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro inesperado ao atualizar o combustível ('||IO_CD_COMBUSTIVEL||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir o combustível ('||IO_CD_COMBUSTIVEL||'): '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_COMBUSTIVEL] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_COMBUSTIVEL] Erro no procedimento que grava combustível: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_PROPRIETARIO(IO_CD_PROPRIETARIO IN OUT PROPRIETARIO.CD_PROPRIETARIO%TYPE,
                               I_NM_PROPRIETARIO  IN PROPRIETARIO.NM_PROPRIETARIO%TYPE,
                               I_NR_CNPJCPF       IN PROPRIETARIO.NR_CNPJCPF%TYPE,
                               I_DS_ENDERECO      IN PROPRIETARIO.DS_ENDERECO%TYPE,
                               I_NR_TELEFONE      IN PROPRIETARIO.NR_TELEFONE%TYPE,
                               O_MENSAGEM         OUT VARCHAR2) IS
    E_GERAL  EXCEPTION;                           
  BEGIN
    IF I_NM_PROPRIETARIO IS NULL THEN
      O_MENSAGEM := 'O nome do proprietário precisa ser informado.';
      RAISE E_GERAL;
    END IF;
   
    IF I_NR_CNPJCPF IS NULL THEN
      O_MENSAGEM := 'O número do CPF/CNPJ precisa ser informado.';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CNPJCPF) <> 11 AND LENGTH(I_NR_CNPJCPF) <> 14 THEN
      O_MENSAGEM := 'Precisa ser informado um número correto de CPF/CNPJ';
      RAISE E_GERAL;
    END IF;
    
    IF IO_CD_PROPRIETARIO IS NULL THEN
      BEGIN
        SELECT MAX(PROPRIETARIO.CD_PROPRIETARIO)
          INTO IO_CD_PROPRIETARIO
          FROM PROPRIETARIO;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_PROPRIETARIO := 0;
      END;
      IO_CD_PROPRIETARIO := NVL(IO_CD_PROPRIETARIO,0) + 1;
    END IF;
    
    BEGIN
      INSERT INTO PROPRIETARIO(
        CD_PROPRIETARIO,
        NM_PROPRIETARIO,
        NR_CNPJCPF,
        DS_ENDERECO,
        NR_TELEFONE,
        DT_RECORD)
      VALUES(
        IO_CD_PROPRIETARIO,
        I_NM_PROPRIETARIO,
        I_NR_CNPJCPF,
        I_DS_ENDERECO,
        I_NR_TELEFONE,
        SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE PROPRIETARIO
             SET NM_PROPRIETARIO = NVL(I_NM_PROPRIETARIO,NM_PROPRIETARIO),
                 NR_CNPJCPF = NVL(I_NR_CNPJCPF,NR_CNPJCPF),
                 DS_ENDERECO = NVL(I_DS_ENDERECO,DS_ENDERECO),
                 NR_TELEFONE = NVL(I_NR_TELEFONE,NR_TELEFONE),
                 DT_REFRESH = SYSDATE
           WHERE CD_PROPRIETARIO = IO_CD_PROPRIETARIO;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar proprietário('||IO_CD_PROPRIETARIO||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir proprietário('||IO_CD_PROPRIETARIO||'): '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PROPRIETARIO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PROPRIETARIO] Erro no procedimento que grava o proprietário: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_VEICULO(I_NR_PLACA        IN VEICULO.NR_PLACA%TYPE,
                          I_CD_COMBUSTIVEL  IN COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                          I_CD_PROPRIETARIO IN PROPRIETARIO.CD_PROPRIETARIO%TYPE,
                          I_KM_ATUAL        IN VEICULO.KM_ATUAL%TYPE,
                          O_MENSAGEM        OUT VARCHAR2) IS
    E_GERAL  EXCEPTION;
    V_COUNT  NUMBER;
  BEGIN
    IF I_NR_PLACA IS NULL THEN
      O_MENSAGEM := 'A placa precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    IF I_CD_COMBUSTIVEL IS NULL THEN
      O_MENSAGEM := 'O tipo de combustível precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    IF I_CD_PROPRIETARIO IS NULL THEN
      O_MENSAGEM := 'O proprietário precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM COMBUSTIVEL
       WHERE COMBUSTIVEL.CD_COMBUSTIVEL = I_CD_COMBUSTIVEL;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF NVL(V_COUNT,0) = 0 THEN
      O_MENSAGEM := 'Nenhum combustível cadastrado com o código '||I_CD_COMBUSTIVEL||'. Verifique!';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PROPRIETARIO
       WHERE PROPRIETARIO.CD_PROPRIETARIO = I_CD_PROPRIETARIO;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF NVL(V_COUNT,0) = 0 THEN
      O_MENSAGEM := 'Nenhum proprietário cadastrado com o código '||I_CD_PROPRIETARIO||'. Verifique!';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      INSERT INTO VEICULO(
        NR_PLACA,
        CD_COMBUSTIVEL,
        CD_PROPRIETARIO,
        KM_ATUAL,
        DT_RECORD)
      VALUES(
        I_NR_PLACA,
        I_CD_COMBUSTIVEL,
        I_CD_PROPRIETARIO,
        NVL(I_KM_ATUAL,0),
        SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE VEICULO
             SET CD_PROPRIETARIO = NVL(I_CD_PROPRIETARIO,CD_PROPRIETARIO),
                 KM_ATUAL = NVL(I_KM_ATUAL,KM_ATUAL),
                 DT_REFRESH = SYSDATE
           WHERE NR_PLACA = I_NR_PLACA;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar o veículo '||I_NR_PLACA||': '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir o veículo '||I_NR_PLACA||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_VEICULO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_VEICULO] Erro no procedimento que insere o veículo: '||SQLERRM;
  END;
END PACK_POSTO;
/
