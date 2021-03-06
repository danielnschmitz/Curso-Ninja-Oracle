CRIE UMA TABELA NOTAFISCAL QUE VAI TER, NUMERO DA NOTA, VALOR DA NOTA,
DESCRI??O DO VENDEDOR, DESCRI??O DO CLIENTE, DATA DE COMPRA.

CRIE UMA TABELA ITEMNOTA QUE VAI TER UM ID DO ITEM, VALOR DO ITEM, 
DESCRI??O DO ITEM, REFERENCIAR A TABELA NOTAFISCAL

CREATE TABLE NOTAFISCAL(
  NR_NOTA NUMBER(15),
  VL_NOTA NUMBER(15,2),
  DS_VENDEDOR VARCHAR2(100),
  DS_CLIENTE VARCHAR2(100),
  DT_COMPRA DATE,
  CONSTRAINT PKNOTAFISCAL PRIMARY KEY (NR_NOTA)
);

CREATE TABLE ITEMNOTA(
  ID_ITEM NUMBER(15),
  VL_ITEM NUMBER(15,2),
  DS_ITEM VARCHAR2(100),
  NR_NOTA NUMBER(15),
  CONSTRAINT PKITEMNOTA PRIMARY KEY (ID_ITEM),
  CONSTRAINT FKITEMNOTA_NOTAFISCAL FOREIGN KEY (NR_NOTA) REFERENCES NOTAFISCAL(NR_NOTA)
);

/*
INSIRA OS DADOS DE DUAS NOTAS, E DEPOIS PARA A PRIMEIRA NOTA, INSIRA 3 ITENS.
FA?A UMA CONSULTA TRAZENDO, OS ITENS JUNTO COM A DESCRI??O DO CLIENTE QUE COMPROU O ITEM
*/
INSERT INTO NOTAFISCAL(NR_NOTA,
                       VL_NOTA,
                       DS_VENDEDOR,
                       DS_CLIENTE,
                       DT_COMPRA) VALUES (1,85,'DANIEL NATAN','CANT YOU SEE','15/10/2021');

INSERT INTO NOTAFISCAL(NR_NOTA,
                       VL_NOTA,
                       DS_VENDEDOR,
                       DS_CLIENTE,
                       DT_COMPRA) VALUES (2,95.30,'DANIEL NATAN','CANT YOU SEE','20/10/2021');

INSERT INTO ITEMNOTA(ID_ITEM,
                     VL_ITEM,
                     DS_ITEM,
                     NR_NOTA) VALUES (1,50,'ITEM 1',2);

INSERT INTO ITEMNOTA(ID_ITEM,
                     VL_ITEM,
                     DS_ITEM,
                     NR_NOTA) VALUES (2,20.20,'ITEM 2',2);

INSERT INTO ITEMNOTA(ID_ITEM,
                     VL_ITEM,
                     DS_ITEM,
                     NR_NOTA) VALUES (3,20.10,'ITEM 3',2);

SELECT * FROM NOTAFISCAL;
SELECT * FROM ITEMNOTA;

SELECT ITEMNOTA.VL_ITEM, 
       NOTAFISCAL.DS_CLIENTE
  FROM ITEMNOTA, 
       NOTAFISCAL
 WHERE ITEMNOTA.NR_NOTA = NOTAFISCAL.NR_NOTA
 
