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
                            ,47 --UNIQUE ASSOCIADO
                            ) 
),
EXAME_UNICO AS(
SELECT CD_ATENDIMENTO, DS_EXA ,DT_PEDIDO
  FROM (
    select 
    PRX.CD_ATENDIMENTO
    ,IRX.CD_PED_RX
    ,PRX.DT_PEDIDO
    ,IRX.CD_EXA_RX ||' - '||ERX.DS_EXA_RX AS DS_EXA
    ,RANK() OVER (PARTITION BY PRX.CD_ATENDIMENTO ORDER BY IRX.DT_REALIZADO DESC) AS AUX
    
    from DBAMV.ITPED_RX IRX
    left join DBAMV.PED_RX PRX ON PRX.CD_PED_RX = IRX.CD_PED_RX
    left join DBAMV.EXA_RX ERX ON IRX.CD_EXA_RX = ERX.CD_EXA_RX
    ORDER BY PRX.HR_PEDIDO ASC
    )
WHERE AUX = 1
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
      ,(SELECT CD_MULTI_EMPRESA FROM ATENDIME WHERE CD_ATENDIMENTO = CODIGO_ATENDIMENTO) AS CD_MULTI_EMPRESA  
      ,(SELECT MAX(DS_EXA) FROM EXAME_UNICO  WHERE CD_ATENDIMENTO = CODIGO_ATENDIMENTO AND TRUNC(DH_ATENDIMENTO) = DT_PEDIDO ) AS DS_EXA
FROM RHPLEITURA.des_campanha_nps
WHERE SEGUNDA_PERGUNTA IS NOT NULL
and UPPER(NOME_CAMPANHA) like '%IMUNO%'
;
SELECT * FROM RHPLEITURA.des_campanha_nps
WHERE 
--UPPER(AREA_PESQUISA) like '%DAY%'
CODIGO_ATENDIMENTO = 5991491 --5992322