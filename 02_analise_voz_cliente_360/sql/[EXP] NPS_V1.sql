WITH UNIQUE_CAT AS (
SELECT 
PA.CD_PERFIL_ALERTA
, PA.PERFIL
, PAP.CD_PACIENTE
FROM DBAMV.PERFIL_ALERTA PA
LEFT JOIN DBAMV.PERFIL_ALERTA_PACIENTE PAP ON PAP.CD_PERFIL_ALERTA = PA.CD_PERFIL_ALERTA
WHERE PA.CD_PERFIL_ALERTA IN (
                             43 --UNIQUE VIP
                            ,44 --UNIQUE REFERENCIADO
                            ,45 --UNIQUE NOTORIO
                            ) 
)
SELECT
     CASE
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('MaternidadeInternação')THEN 'Maternidade'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('Emergênciac\concierge','Emergências\concierge')THEN 'Emergência'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemAgamenon')THEN 'Real Imagem Agamenon'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemBoaviagem')THEN 'Real Imagem Boa Viagem'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('HDConvenio','PesquisaHemodiáliseConvenio')THEN 'HD Convênio'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealLab','Coletadomiciliar')THEN 'Real Lab'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('PesquisaRealVacina','RealVacina')THEN 'Real Vacina'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('NossaClínica')THEN 'Nossa Clínica'
        ELSE REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '')
      END AS "Pesquisa"
    ,AC_MAILING_ID
    ,DH_DISPARO AS "Data/hora do envio"
    ,CANAL_DISTRIBUICAO AS "Canal de Distribuição"
    ,CANAL_RESPOSTA AS "Canal de resposta"
    ,DH_RESPOSTA AS "Data de Resposta"
    ,AREA_PESQUISA AS "Área de Pesquisa"
    ,NOME_PACIENTE_RHP AS "Nome"
    ,CONVENIO AS "Convênio"
    ,null AS "E-mail"
    ,CODIGO_PACIENTE AS "Código do paciente"
    ,CODIGO_ATENDIMENTO AS "Codigo do atendimento"
    ,ORIGEM AS "Origem do atendimento"
    ,NUMERO_CLIENTE AS "Telefone"
    ,DH_ATENDIMENTO AS "Data de Atendimento"
    ,NASCIMENTO AS "Data de nascimento"
    ,(SELECT ESP.DS_ESPECIALID FROM DBAMV.ESPECIALID ESP, DBAMV.ATENDIME ATE WHERE ESP.CD_ESPECIALID = ATE.CD_ESPECIALID AND ATE.CD_ATENDIMENTO = CODIGO_ATENDIMENTO) AS "Especialidade"
    ,IDADE_PACIENTE AS "Idade"
    ,GENERO_PACIENTE AS "Sexo"
    ,UNIDADE AS "Unidades"
    ,NOME_SETOR AS "Setores"
    ,decode(SEGUNDA_PERGUNTA,'Acompanhante',null ,'Paciente',null, null, '', SEGUNDA_PERGUNTA) AS "Nota"
    ,QUARTA_PERGUNTA AS "Comentário"
    ,'SMARTSPACE' AS FONTE
    ,CASE
        WHEN SEGUNDA_PERGUNTA BETWEEN '0' AND '6' THEN 'Detrator'
        WHEN SEGUNDA_PERGUNTA BETWEEN '7' AND '8' THEN 'Neutro'
        WHEN SEGUNDA_PERGUNTA BETWEEN '9' AND '10' THEN 'Promotor'
        ELSE 'Não classificado'
     END AS "Classificação"
     ,PRIMEIRA_PERGUNTA AS "Consentimento Feedback"
     ,TERCEIRA_PERGUNTA AS "Detalhar Experiência"
     ,QUINTA_PERGUNTA AS "Consentimento para novas perguntas"
     ,CASE
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE '%MUITO BOM%' THEN 'Muito Bom'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE '%MUITO RUIM%' THEN 'Muito Ruim'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE 'BOM%' THEN 'Bom'
        ELSE INITCAP(SEXTA_PERGUNTA)
      END AS "Avalia Atend. Profissionais"
     ,SETIMA_PERGUNTA AS "Profissional - Qual Principal Motivo"
     ,OITAVA_PERGUNTA AS "Avalia Qual Categoria"
     ,NONA_PERGUNTA AS "Destaque da Avaliação"
     ,CASE
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_PERGUNTA) LIKE '%MUITO BOM%' THEN 'Muito Bom'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_PERGUNTA) LIKE '%MUITO RUIM%' THEN 'Muito Ruim'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_PERGUNTA) LIKE 'BOM%' THEN 'Bom'
        ELSE INITCAP(DECIMA_PERGUNTA)
      END AS "Avalia Conforto e Comodidade"
     ,DECIMA_PRIMEIRA_PERGUNTA  AS "Infraestrutura - Principais Motivos"
     ,DECIMA_SEGUNDA_PERGUNTA AS "Infraestrutura - Qual Principal Motivo"
     ,CASE
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_TERCEIRA_PERGUNTA) LIKE '%POSITIVA%' THEN 'Positiva'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_TERCEIRA_PERGUNTA) LIKE '%NEGATIVA%' THEN 'Negativa'
        ELSE NVL(INITCAP(DECIMA_TERCEIRA_PERGUNTA),'Indiferente')
      END AS "Avaliação Experiência Completa"
     ,case when DH_RESPOSTA is not null then ROUND(((NVL(DH_RESPOSTA,SYSDATE) - DH_DISPARO)*24*60),0) else null end AS TMP_NPS    
     ,case when DH_RESPOSTA is not null then TRUNC(NVL(DH_RESPOSTA,SYSDATE)) - TRUNC(DH_DISPARO) else null end AS TMP_NPS_DIAS
     ,DH_INTEGRACAO
     ,CASE
        WHEN (SELECT PERFIL FROM UNIQUE_CAT WHERE CD_PACIENTE = des_campanha_nps.CODIGO_PACIENTE) IS NOT NULL
        THEN (SELECT PERFIL FROM UNIQUE_CAT WHERE CD_PACIENTE = des_campanha_nps.CODIGO_PACIENTE)
        
        WHEN (SELECT PERFIL FROM UNIQUE_CAT WHERE CD_PACIENTE = des_campanha_nps.CODIGO_PACIENTE) IS NULL AND ORIGEM IN ('RHC 14º - UNIQUE ')
        THEN 'EXP. UNIQUE'
        
        ELSE NULL 
      END AS CAT_UNIQUE
      
      
      
          
FROM RHPLEITURA.des_campanha_nps
WHERE DH_ATENDIMENTO >= '04/10/2025'
and DH_ATENDIMENTO < '05/10/2025'
--and DH_DISPARO >= '04/10/2025'
--and DH_DISPARO < '05/10/2025'
--WHERE UPPER(AREA_PESQUISA) LIKE '%CARDIO%'
--where DH_ATENDIMENTO = NASCIMENTO
--and DH_DISPARO BETWEEN TO_DATE('04/10/2025','DD/MM/YYYY') AND TO_DATE('05/10/2025','DD/MM/YYYY')
AND SEGUNDA_PERGUNTA is not null
--where ORIGEM like '%12%UTI%'
/*where CODIGO_ATENDIMENTO IN (
  5490062  --Atendimento de 25/03 || Disparo 26/03 || Resposta as 18:49 do dia 26/03/25
  ,5489896 --Atendimento de 25/03 || Disparo 26/03 || Resposta as 21:01 do dia 26/03/25
  ,5512230 --Atendimento de 01/04 || Disparo 02/04 || Resposta as 13:14 do dia 02/04/25
  ,5510549 --Atendimento de 01/04 || Disparo 02/04 || Resposta as 23:22 do dia 02/04/25
  ,5516147 --Atendimento de 05/04 || Disparo 06/04 || Resposta as 14:20 do dia 06/04/25
  ,5506362 --Atendimento de 31/03 || Disparo 01/04 || Resposta as 02:13 do dia 02/04/25
  )*/
--WHERE CODIGO_PACIENTE = 2128863
--where DH_ATENDIMENTO = (sysdate-1)
--where DH_RESPOSTA is not null
AND CODIGO_ATENDIMENTO NOT IN( 6050322,
6042601,
6029598,
6050878,
6029487,
6050314,
6050450,
6051211,
6050852,
6050758,
6050308,
6038832,
6050445,
6050779,
6050256,
6050387,
6050341,
6050570,
6050394,
6050454,
6050460,
6044576,
6050769,
6050559,
6050435,
6050423,
6050027,
6050931,
6050478,
6050739,
6048527,
6050399,
6046551,
6051145,
6050595,
6050578,
6050628,
6050305,
6050548,
6050489,
6031506,
6050246,
6051096,
6042720,
6051131,
6050349,
6050576,
6050877,
6042892,
6050825,
6050306,
6051108,
6051036,
6050857,
6050823,
6050752,
6050464,
6050807,
6050761,
6041878,
6050382,
6050757,
6046046,
6050362,
6046533,
6050841,
6050310,
6050648,
6046283,
6050641,
6035380,
6050917,
6042546,
6050412,
6050346,
6050631,
6050458,
6012761,
6050896,
6050364,
6050656,
6050538,
6046589,
6047105,
6020467,
6050563,
6050468,
6050745,
6050234,
6044526,
6050405,
6050366,
6050539,
6050419,
6048714,
6050582,
6050553,
6050942,
6050956,
6051030,
6051079,
6050764,
6050352,
6050742,
6050344,
6050390,
6050381,
6051017,
6036805,
6050793,
6050490,
6050434,
6050552,
6047993,
6051203,
6050432)
--and trunc(DH_ATENDIMENTO) >= TRUNC(SYSDATE-1)
--AND AREA_PESQUISA LIKE '%LINHA%'

--WHERE CODIGO_ATENDIMENTO IN (5732749, 5730841, 5724535)
--WHERE AREA_PESQUISA LIKE '%IMAG%'
--WHERE NOME_SETOR LIKE '%14%'

order by 
  --DH_INTEGRACAO desc
  DH_RESPOSTA desc
  , DH_DISPARO desc
;
SELECT DATAS, SUM(QNTD) QNTD FROM (
select TRUNC(DH_DISPARO) DATAS, COUNT(DH_DISPARO) QNTD FROM RHPLEITURA.des_campanha_nps
--where DH_RESPOSTA is not null
GROUP BY DH_DISPARO
order by to_date(DH_DISPARO) desc
)
GROUP BY DATAS
ORDER BY 1 DESC
;
select 
AREA_PESQUISA
, CODIGO_ATENDIMENTO
, DH_ATENDIMENTO AS DT_ATENDIMENTO
, DH_DISPARO AS DT_ENVIO
, DH_RESPOSTA AS DT_RESPOSTA
, DH_INTEGRACAO AS DT_API
, NOME_PACIENTE_RHP
, CONVENIO
, NOME_SETOR
, NUMERO_CLIENTE
, PRIMEIRA_PERGUNTA AS CONSENTIMENTO
, SEGUNDA_PERGUNTA AS NOTA
, CASE 
    WHEN CODIGO_ATENDIMENTO IN (5513093,5517787,5517375,5522113,5523047,5520937,5520528,5521337) THEN 'CASOS DE HOJE'
    ELSE 'CASOS ANTERIOR'
  END TIPO

from RHPLEITURA.des_campanha_nps
/*where CODIGO_ATENDIMENTO IN (
  5490062  --Atendimento de 25/03 || Disparo 26/03 || Resposta as 18:49 do dia 26/03/25
  ,5489896 --Atendimento de 25/03 || Disparo 26/03 || Resposta as 21:01 do dia 26/03/25
  ,5512230 --Atendimento de 01/04 || Disparo 02/04 || Resposta as 13:14 do dia 02/04/25
  ,5510549 --Atendimento de 01/04 || Disparo 02/04 || Resposta as 23:22 do dia 02/04/25
  ,5516147 --Atendimento de 05/04 || Disparo 06/04 || Resposta as 14:20 do dia 06/04/25
  ,5506362 --Atendimento de 31/03 || Disparo 01/04 || Resposta as 02:13 do dia 02/04/25
  ,5523395 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  /*casos a partir de 07/04/2025 - enviados por Adriele*/
 /* ,5513093 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5517787 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5517375 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5522113 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5523047 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5520937 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5520528 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  ,5521337 --Atendimento de 04/04 || Disparo 05/04 || Resposta as 02:13 do dia 05/04/25
  )*/
  where trunc(DH_DISPARO) >= '01/04/2025'
order by trunc(DH_ATENDIMENTO) desc, DH_DISPARO desc
;
SELECT DISTINCT 
DECODE (AREA_PESQUISA,'EXAMES_REAL_DOMICILIAR','EXAMES_LAB',AREA_PESQUISA) AS AREA_PESQUISA
, DECODE (REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''),'Pesquisa Hemodiálise Convenio','HD Convenio',' HD Convenio','HD Convenio','Emergência s\ concierge','Emergências','Emergência c\ concierge ','Emergências',' Coleta domiciliar','Real Lab','Pesquisa Real Vacina','Real Vacina',REPLACE(NOME_CAMPANHA, 'Pesquisa - ', '')) AS NOME_CAMPANHA FROM RHPLEITURA.des_campanha_nps
ORDER BY 1
--WHERE CODIGO_PACIENTE = 2208009
;
--CHECKLIST DE CAMPANHAS
SELECT 
REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') AS "Pesquisa"
,AC_MAILING_ID
,DH_ATENDIMENTO AS "Data de Atendimento"
,DH_DISPARO AS "Data/hora do envio"
,DH_RESPOSTA AS "Data de Resposta"
,CODIGO_ATENDIMENTO AS "Codigo do atendimento"
,CODIGO_PACIENTE AS "Código do paciente"
,NOME_PACIENTE_RHP AS "Nome"
,NUMERO_CLIENTE AS "Telefone"
FROM RHPLEITURA.des_campanha_nps
where DH_DISPARO BETWEEN TO_DATE('01/07/2025','DD/MM/YYYY') AND TO_DATE('31/07/2025','DD/MM/YYYY')
;
select distinct REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') AS "Pesquisa"
,CASE
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('MaternidadeInternação')THEN 'Maternidade'
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('Emergênciac\concierge','Emergências\concierge')THEN 'Emergência'
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemAgamenon','RealImagemBoaviagem')THEN 'Real Imagem'
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('HDConvenio','PesquisaHemodiáliseConvenio')THEN 'HD Convênio'
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealLab','Coletadomiciliar')THEN 'Real Lab'
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('PesquisaRealVacina','RealVacina')THEN 'Real Vacina'
    WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('NossaClínica')THEN 'Nossa Clínica'
    ELSE REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '')
  END AS AJUSTE
FROM RHPLEITURA.des_campanha_nps
--WHERE CODIGO_ATENDIMENTO = 5794958