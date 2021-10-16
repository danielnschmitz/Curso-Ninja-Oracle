CREATE OR REPLACE PROCEDURE RETORNA_VALORNOTA (I_NR_NOTA IN NOTAFISCAL.NR_NOTA%TYPE,
                                               O_VL_NOTA OUT NOTAFISCAL.VL_NOTA%TYPE) IS
BEGIN
  SELECT NOTAFISCAL.VL_NOTA
    INTO O_VL_NOTA
    FROM NOTAFISCAL
   WHERE NOTAFISCAL.NR_NOTA = I_NR_NOTA;
END RETORNA_VALORNOTA;
/
