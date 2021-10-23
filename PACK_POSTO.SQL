CREATE OR REPLACE PACKAGE PACK_POSTO IS
  PROCEDURE GRAVA_COMBUSTIVEL(IO_CD_COMBUSTIVEL IN OUT COMBUSTIVEL.CD_COMBUSTIVEL%TYPE,
                              I_DS_COMBUSTIVEL  IN COMBUSTIVEL.DS_COMBUSTIVEL%TYPE,
                              I_VL_COMBUSTIVEL  IN COMBUSTIVEL.VL_COMBUSTIVEL%TYPE,
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
      O_MENSAGEM := 'O npumero do CPF/CNPJ precisa ser informado.';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CNPJCPF) <> 11 AND LENGTH(I_NR_CNPJCPF) <> 14 THEN
      O_MENSAGEM := 'Precisa ser informado um número correto de CPF/CNPJ';
      RAISE E_GERAL;
    END IF;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PROPRIETARIO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PROPRIETARIO] Erro no procedimento que grava o proprietário: '||SQLERRM;
  END;
  
END PACK_POSTO;
/
