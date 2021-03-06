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
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_FRENTISTA(IO_CD_FRENTISTA IN OUT FRENTISTA.CD_FRENTISTA%TYPE,
                            I_NM_FRENTISTA  IN FRENTISTA.NM_FRENTISTA%TYPE,
                            I_PC_COMISSAO   IN FRENTISTA.PC_COMISSAO%TYPE,
                            O_MENSAGEM      OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_ABASTECIMENTO(IO_CD_ABASTECIMENTO IN OUT ABASTECIMENTO.CD_ABASTECIMENTO%TYPE,
                                I_NR_PLACA          IN VEICULO.NR_PLACA%TYPE,
                                I_CD_FRENTISTA      IN FRENTISTA.CD_FRENTISTA%TYPE,
                                I_QT_ABASTECIDA     IN ABASTECIMENTO.QT_ABASTECIDA%TYPE,
                                I_KM_ABASTECIMENTO  IN ABASTECIMENTO.KM_ABASTECIMENTO%TYPE,
                                O_MENSAGEM          OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_PROPRIETARIO(I_CD_PROPRIETARIO IN PROPRIETARIO.CD_PROPRIETARIO%TYPE,
                                O_MENSAGEM        OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_COMBUSTIVEL(I_CD_COMBUSTIVEL IN COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                               O_MENSAGEM        OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_VEICULO(I_NR_PLACA IN VEICULO.NR_PLACA%TYPE,
                           O_MENSAGEM OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_FRENTISTA(I_CD_FRENTISTA IN FRENTISTA.CD_FRENTISTA%TYPE,
                             O_MENSAGEM     OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_ABASTECIMENTO(I_CD_ABASTECIMENTO IN ABASTECIMENTO.CD_ABASTECIMENTO%TYPE,
                                 O_MENSAGEM         OUT VARCHAR2);
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
      O_MENSAGEM := 'A descri��o do combust�vel precisa ser informada.';
      RAISE E_GERAL;
    END IF;
    
    IF I_VL_COMBUSTIVEL IS NULL THEN
      O_MENSAGEM := 'O valor do combust�vel precisa ser informado.';
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
            O_MENSAGEM := 'Erro inesperado ao atualizar o combust�vel ('||IO_CD_COMBUSTIVEL||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir o combust�vel ('||IO_CD_COMBUSTIVEL||'): '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_COMBUSTIVEL] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_COMBUSTIVEL] Erro no procedimento que grava combust�vel: '||SQLERRM;
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
      O_MENSAGEM := 'O nome do propriet�rio precisa ser informado.';
      RAISE E_GERAL;
    END IF;
   
    IF I_NR_CNPJCPF IS NULL THEN
      O_MENSAGEM := 'O n�mero do CPF/CNPJ precisa ser informado.';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CNPJCPF) <> 11 AND LENGTH(I_NR_CNPJCPF) <> 14 THEN
      O_MENSAGEM := 'Precisa ser informado um n�mero correto de CPF/CNPJ';
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
            O_MENSAGEM := 'Erro ao atualizar propriet�rio('||IO_CD_PROPRIETARIO||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir propriet�rio('||IO_CD_PROPRIETARIO||'): '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PROPRIETARIO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PROPRIETARIO] Erro no procedimento que grava o propriet�rio: '||SQLERRM;
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
      O_MENSAGEM := 'O tipo de combust�vel precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    IF I_CD_PROPRIETARIO IS NULL THEN
      O_MENSAGEM := 'O propriet�rio precisa ser informado';
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
      O_MENSAGEM := 'Nenhum combust�vel cadastrado com o c�digo '||I_CD_COMBUSTIVEL||'. Verifique!';
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
      O_MENSAGEM := 'Nenhum propriet�rio cadastrado com o c�digo '||I_CD_PROPRIETARIO||'. Verifique!';
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
            O_MENSAGEM := 'Erro ao atualizar o ve�culo '||I_NR_PLACA||': '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir o ve�culo '||I_NR_PLACA||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_VEICULO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_VEICULO] Erro no procedimento que insere o ve�culo: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_FRENTISTA(IO_CD_FRENTISTA IN OUT FRENTISTA.CD_FRENTISTA%TYPE,
                            I_NM_FRENTISTA  IN FRENTISTA.NM_FRENTISTA%TYPE,
                            I_PC_COMISSAO   IN FRENTISTA.PC_COMISSAO%TYPE,
                            O_MENSAGEM      OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    IF I_NM_FRENTISTA IS NULL THEN
      O_MENSAGEM := 'O nome do frentista precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    IF IO_CD_FRENTISTA IS NULL THEN
      BEGIN
        SELECT MAX(FRENTISTA.CD_FRENTISTA)
          INTO IO_CD_FRENTISTA
          FROM FRENTISTA;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_FRENTISTA := 0;
      END;
      IO_CD_FRENTISTA := NVL(IO_CD_FRENTISTA,0) + 1;
    END IF;
    
    BEGIN
      INSERT INTO FRENTISTA(
        CD_FRENTISTA,
        NM_FRENTISTA,
        PC_COMISSAO,
        DT_RECORD)
      VALUES(
        IO_CD_FRENTISTA,
        I_NM_FRENTISTA,
        I_PC_COMISSAO,
        SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE FRENTISTA
             SET NM_FRENTISTA = NVL(I_NM_FRENTISTA,NM_FRENTISTA),
                 PC_COMISSAO = NVL(I_PC_COMISSAO,0),
                 DT_REFRESH = SYSDATE
           WHERE CD_FRENTISTA = IO_CD_FRENTISTA;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar o frentista '||IO_CD_FRENTISTA||': '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao gravar o frentista '||IO_CD_FRENTISTA||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_FRENTISTA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_FRENTISTA] Erro no procedimento que insere o frentista: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_ABASTECIMENTO(IO_CD_ABASTECIMENTO IN OUT ABASTECIMENTO.CD_ABASTECIMENTO%TYPE,
                                I_NR_PLACA          IN VEICULO.NR_PLACA%TYPE,
                                I_CD_FRENTISTA      IN FRENTISTA.CD_FRENTISTA%TYPE,
                                I_QT_ABASTECIDA     IN ABASTECIMENTO.QT_ABASTECIDA%TYPE,
                                I_KM_ABASTECIMENTO  IN ABASTECIMENTO.KM_ABASTECIMENTO%TYPE,
                                O_MENSAGEM          OUT VARCHAR2) IS
    E_GERAL           EXCEPTION;
    V_COUNT           NUMBER;
    V_VL_COMBUSTIVEL  COMBUSTIVEL.VL_COMBUSTIVEL%TYPE;
  BEGIN
    
    IF I_NR_PLACA IS NULL THEN
      O_MENSAGEM := 'A placa precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    IF I_CD_FRENTISTA IS NULL THEN
      O_MENSAGEM := 'O frentista precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    IF I_QT_ABASTECIDA IS NULL THEN
      O_MENSAGEM := 'A quantidade abastecida precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM VEICULO 
       WHERE VEICULO.NR_PLACA = I_NR_PLACA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF NVL(V_COUNT,0) = 0 THEN
      O_MENSAGEM := 'Ve�culo de placa '||I_NR_PLACA||' n�o cadastrado';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM FRENTISTA
       WHERE FRENTISTA.CD_FRENTISTA = I_CD_FRENTISTA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF NVL(V_COUNT,0) = 0 THEN
      O_MENSAGEM := 'Frentista de c�digo '||I_CD_FRENTISTA||' n�o cadastrado';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      SELECT COMBUSTIVEL.VL_COMBUSTIVEL
        INTO V_VL_COMBUSTIVEL
        FROM COMBUSTIVEL,
             VEICULO
       WHERE COMBUSTIVEL.CD_COMBUSTIVEL = VEICULO.CD_COMBUSTIVEL
         AND VEICULO.NR_PLACA = I_NR_PLACA;
    EXCEPTION
      WHEN OTHERS THEN
        V_VL_COMBUSTIVEL := 0;
    END;
    
    IF NVL(V_VL_COMBUSTIVEL,0) = 0 THEN
      O_MENSAGEM := 'Valor n�o cadastrado para o combust�vel, ou zerado. Verifique o cadastro de combust�vel';
      RAISE E_GERAL;
    END IF;
    
    IF IO_CD_ABASTECIMENTO IS NULL THEN
      BEGIN
        SELECT MAX(ABASTECIMENTO.CD_ABASTECIMENTO)
          INTO IO_CD_ABASTECIMENTO
          FROM ABASTECIMENTO;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_ABASTECIMENTO := 0;
      END;
      IO_CD_ABASTECIMENTO := NVL(IO_CD_ABASTECIMENTO,0) + 1;
      
      BEGIN
        UPDATE VEICULO 
           SET KM_ATUAL = I_KM_ABASTECIMENTO,
               DT_REFRESH = SYSDATE
         WHERE NR_PLACA = I_NR_PLACA;
      EXCEPTION
        WHEN OTHERS THEN
          O_MENSAGEM := 'Erro ao atualizar a quilometragem do ve�culo '||I_NR_PLACA||': '||SQLERRM;
          RAISE E_GERAL;
      END;
      
    END IF;
    
    BEGIN
      INSERT INTO ABASTECIMENTO(
        CD_ABASTECIMENTO,
        NR_PLACA,
        CD_FRENTISTA,
        QT_ABASTECIDA,
        KM_ABASTECIMENTO,
        VL_COMBUSTIVEL,
        DT_RECORD)
      VALUES(
        IO_CD_ABASTECIMENTO,
        I_NR_PLACA,
        I_CD_FRENTISTA,
        I_QT_ABASTECIDA,
        I_KM_ABASTECIMENTO,
        V_VL_COMBUSTIVEL,
        SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE ABASTECIMENTO
             SET NR_PLACA = I_NR_PLACA,
                 CD_FRENTISTA = I_CD_FRENTISTA,
                 QT_ABASTECIDA = I_QT_ABASTECIDA,
                 DT_REFRESH = SYSDATE
           WHERE CD_ABASTECIMENTO = IO_CD_ABASTECIMENTO;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar o abastecimento '||IO_CD_ABASTECIMENTO||': '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir o abastecimento: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_ABASTECIMENTO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_ABASTECIMENTO] Erro no procedimento que insere o abastecimento: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_PROPRIETARIO(I_CD_PROPRIETARIO IN PROPRIETARIO.CD_PROPRIETARIO%TYPE,
                                O_MENSAGEM        OUT VARCHAR2) IS
                                
    E_GERAL   EXCEPTION;
    V_COUNT   NUMBER;
  BEGIN
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM VEICULO
       WHERE VEICULO.CD_PROPRIETARIO = I_CD_PROPRIETARIO;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF V_COUNT > 0 THEN
      O_MENSAGEM := 'O propriet�rio n�o pode ser excluido, pois existem ve�culos cadastrados que pertencem a ele';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE PROPRIETARIO
       WHERE CD_PROPRIETARIO = I_CD_PROPRIETARIO;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir o propriet�rio '||I_CD_PROPRIETARIO||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_PROPRIETARIO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_PROPRIETARIO] Erro no procedimento de exclus�o do propriet�rio: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_COMBUSTIVEL(I_CD_COMBUSTIVEL IN COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                               O_MENSAGEM        OUT VARCHAR2) IS
                                
    E_GERAL   EXCEPTION;
    V_COUNT   NUMBER;
  BEGIN
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM VEICULO
       WHERE VEICULO.CD_COMBUSTIVEL = I_CD_COMBUSTIVEL;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF V_COUNT > 0 THEN
      O_MENSAGEM := 'O combust�vel n�o pode ser excluido, pois existem ve�culos associados a ele';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE COMBUSTIVEL
       WHERE CD_COMBUSTIVEL = I_CD_COMBUSTIVEL;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir o combustivel '||I_CD_COMBUSTIVEL||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_COMBUSTIVEL] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_COMBUSTIVEL] Erro no procedimento de exclus�o do propriet�rio: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_VEICULO(I_NR_PLACA IN VEICULO.NR_PLACA%TYPE,
                           O_MENSAGEM OUT VARCHAR2) IS
                                
    E_GERAL   EXCEPTION;
    V_COUNT   NUMBER;
  BEGIN
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM ABASTECIMENTO
       WHERE ABASTECIMENTO.NR_PLACA = I_NR_PLACA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF V_COUNT > 0 THEN
      O_MENSAGEM := 'O ve�culo n�o pode ser excluido, pois existem abastecimentos associados a ele';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE VEICULO
       WHERE NR_PLACA = I_NR_PLACA;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir o ve�culo '||I_NR_PLACA||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_VEICULO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_VEICULO] Erro no procedimento de exclus�o do ve�culo: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_FRENTISTA(I_CD_FRENTISTA IN FRENTISTA.CD_FRENTISTA%TYPE,
                             O_MENSAGEM     OUT VARCHAR2) IS
                                
    E_GERAL   EXCEPTION;
    V_COUNT   NUMBER;
  BEGIN
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM ABASTECIMENTO
       WHERE ABASTECIMENTO.CD_FRENTISTA = I_CD_FRENTISTA;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    
    IF V_COUNT > 0 THEN
      O_MENSAGEM := 'O frentista n�o pode ser excluido, pois existem abastecimentos associados a ele';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      DELETE FRENTISTA
       WHERE CD_FRENTISTA = I_CD_FRENTISTA;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir o frentista '||I_CD_FRENTISTA||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_FRENTISTA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_FRENTISTA] Erro no procedimento de exclus�o do frentista: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_ABASTECIMENTO(I_CD_ABASTECIMENTO IN ABASTECIMENTO.CD_ABASTECIMENTO%TYPE,
                                 O_MENSAGEM         OUT VARCHAR2) IS
                                
    E_GERAL   EXCEPTION;
  BEGIN
    
    BEGIN
      DELETE ABASTECIMENTO
       WHERE CD_ABASTECIMENTO = I_CD_ABASTECIMENTO;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao excluir o abastecimento '||I_CD_ABASTECIMENTO||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_ABASTECIMENTO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_ABASTECIMENTO] Erro no procedimento de exclus�o do abastecimento: '||SQLERRM;
  END;
END PACK_POSTO;
/
