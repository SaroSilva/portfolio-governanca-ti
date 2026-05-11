/*====================================================================================================================
OBJETO       : QUERY / VIEW – BASE NPS SMARTSPACE
SISTEMA      : SMARTSPACE / BUSINESS INTELLIGENCE
RESPONSÁVEL  : 26521
FINALIDADE   : Consolidação e tratamento dos dados de pesquisas NPS para consumo no BI institucional.
----------------------------------------------------------------------------------------------------------------------
HISTÓRICO DE ALTERAÇÕES
----------------------------------------------------------------------------------------------------------------------
DATA       HORA   RESPONSÁVEL  SISTEMA / CHAMADO      DESCRIÇÃO DA ALTERAÇÃO
----------#------#------------#----------------------#----------------------------------------------------------------
27/01/2025         26521       REDMINE 9562            Criação da query para extração de dados NPS após migração
                                                       dos disparos de pesquisa para a plataforma SmartSpace.
----------#------#------------#----------------------#----------------------------------------------------------------
20/02/2025        26521        REDMINE 9726            Inclusão dos comentários dos pacientes na visão geral,
                                                       permitindo exportação consolidada de todas as áreas.
----------#------#------------#----------------------#----------------------------------------------------------------
21/02/2025        26521        REDMINE 9894            Anonimização do nome do paciente (exibição por iniciais).
                                                       Remoção da coluna de e-mail da base exportada.
                                                       Inclusão da dimensão de setores em todas as visões.
----------#------#------------#----------------------#----------------------------------------------------------------
21/02/2025        26521        REDMINE 9897            Alteração da regra de cálculo do NPS para as áreas:
                                                       Internação e Maternidade Internação.
                                                       Cálculo passa a considerar a data do disparo da pesquisa.
----------#------#------------#----------------------#----------------------------------------------------------------
27/05/2025        26521        REDMINE 11150           Unificação das áreas:
                                                       "HD Convênio" e "Pesquisa Hemodiálise Convênio",
                                                       passando a utilizar a nomenclatura única
                                                       "Hemodiálise Convênio".
----------#------#------------#----------------------#----------------------------------------------------------------
06/06/2025        26521        REDMINE 11204           Ajuste de inconsistência entre BI e base SmartSpace.
                                                       Unificação de setores duplicados nas áreas:
                                                       Real Vida Emergência e Unidades de Internação.
                                                       Correção da divergência de respostas
                                                       (SmartSpace: 8.082 | BI: 7.359).
----------#------#------------#----------------------#----------------------------------------------------------------
20/06/2025        26521        REDMINE 11353           Alteração na regra de envio da pesquisa para
                                                       Hemodiálise Convênio, permitindo recorrência
                                                       após 7 dias para o mesmo paciente.
----------#------#------------#----------------------#----------------------------------------------------------------
27/11/2025 13:50  26521        SMARTSPACE              Adequação após alteração estrutural realizada
                                                       pela SmartSpace nos campos de atendimento e
                                                       paciente (VARCHAR2 com sufixo ".0").
----------#------#------------#----------------------#----------------------------------------------------------------
27/11/2025 15:50  26521        SMARTSPACE              Atualização da regra de origem para UNIQS:
                                                       - Inclusão do perfil 47 na UNIQUE_CAT
                                                       - Inclusão da origem "13º RHC UNIQUE".
----------#------#------------#----------------------#----------------------------------------------------------------
01/12/2025 15:50  26521        SERVICENOW RITM0020543  Inclusão de novas colunas:
                                                       - Responsável pela abertura do atendimento
                                                       - Médico assistente
                                                       - Especialidade médica do médico assistente.
----------#------#------------#----------------------#----------------------------------------------------------------
02/12/2025 10:50  26521        SERVICENOW RITM0020543  Inclusão de novas dimensões analíticas:
                                                       - Base de laboratório
                                                       - Base de exames de imagem
                                                       Regras derivadas dos indicadores de tempo
                                                       utilizados na emergência.
----------#------#------------#----------------------#----------------------------------------------------------------
05/12/2025 17:29  26521        SERVICENOW RITM0020543  Revisão estrutural da query.
                                                       Implementação de regras para evitar duplicidade
                                                       em exames únicos utilizando:
                                                       - DT_REALIZADO NOT NULL
                                                       - CD_SEQ_INTEGRA.
----------#------#------------#----------------------#----------------------------------------------------------------
15/12/2025 17:23  26521        SERVICENOW RITM0020543  Inclusão de regra na dimensão D_LOG_AGG:
                                                       - JOIN com ITPED_LAB para verificação do prazo
                                                         de liberação de exames.
                                                       - Inclusão de métricas de contagem de itens
                                                         e exames liberados dentro do prazo.
----------#------#------------#----------------------#----------------------------------------------------------------
15/12/2025 18:16  26521        SERVICENOW RITM0020543  Remoção da regra de verificação de prazo
                                                       anteriormente aplicada na dimensão D_LOG_AGG.
----------#------#------------#----------------------#----------------------------------------------------------------
16/12/2025 08:41  26521        SERVICENOW RITM0020543  Verificação de integridade dos dados:
                                                       - Registros após aplicação dos JOINs: 381.556
                                                       - Registros na dimensão base materializada:
                                                         381.556.
----------#------#------------#----------------------#----------------------------------------------------------------
16/12/2025 18:07  26521        SERVICENOW RITM0020543  Inclusão da dimensão D_DOCUMENTO_CLINICO
                                                       para identificação do médico do primeiro
                                                       atendimento.
----------#------#------------#----------------------#----------------------------------------------------------------
17/12/2025 18:12  26521        SERVICENOW RITM0020543  Nova validação de integridade após ajustes
                                                       estruturais:
                                                       - Total de registros: 383.290.
----------#------#------------#----------------------#----------------------------------------------------------------
24/12/2025 08:29  26521        SERVICENOW RITM0024462  Implementação da regra de identificação
                                                       do primeiro atendimento do paciente.
----------#------#------------#----------------------#----------------------------------------------------------------
29/12/2025 13:29  26521        SERVICENOW RITM0024462  Padronização de nomenclatura de setores:
                                                       - ESAN 04º / ESAN 4º
                                                       - ESAN 05º / ESAN 5º.
----------#------#------------#----------------------#----------------------------------------------------------------
09/01/2026 13:29  26521        SERVICENOW RITM0024462  Evolução da regra de primeiro atendimento:
                                                       segmentação por campanha de pesquisa.
----------#------#------------#----------------------#----------------------------------------------------------------
19/02/2026 10:52  26521        SERVICENOW XXXXXXXXXXX  Implementação de UNION ALL para pesquisas
                                                       de exames laboratoriais (EXAMES_LAB),
                                                       devido alteração estrutural no questionário
                                                       a partir de nova data de vigência.
----------#------#------------#----------------------#----------------------------------------------------------------
25/02/2026 15:12  26521        SERVICENOW RITM0031341  Implementação de regra CASE para
                                                       agrupamento das Business Units (BU's)
                                                       conforme planilha anexada ao chamado.
----------#------#------------#----------------------#----------------------------------------------------------------
09/04/2026 09:16  26521        SERVICENOW XXXXXXXXXXX  Adição no Case (BU's) - Tipo Pesquisa LCC como Cardiologia
----------#------#------------#----------------------#----------------------------------------------------------------
16/04/2026 09:57  26521        SERVICENOW XXXXXXXXXXX  Verificação da nova campanha do LAB para novo fluxo de perg.
=====================================================================================================================*/

WITH /*+ MATERIALIZE */NPS_SMARTSPACE AS(
    SELECT
        'SMARTSPACE' AS FONTE
        ,CASE
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('MaternidadeInternação')THEN 'Maternidade'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('Emergênciac\concierge','Emergências\concierge')THEN 'Emergência'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemAgamenon')THEN 'Real Imagem Agamenon'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemBoaviagem')THEN 'Real Imagem Boa Viagem'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('HDConvenio','PesquisaHemodiáliseConvenio')THEN 'HD Convênio'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealLab','Coletadomiciliar')THEN 'Real Lab'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('PesquisaRealVacina','RealVacina')THEN 'Real Vacina'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('NossaClínica', 'RealMedCenter')THEN 'Real Med Center'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('LCCCardio')THEN 'LCC Cardiologia'
            ELSE REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '')
        END AS NOME_CAMPANHA
        ,AREA_PESQUISA
        ,AC_MAILING_ID
        ,CASE 
          WHEN REGEXP_LIKE(CODIGO_PACIENTE, '^\d+$') THEN TO_NUMBER(CODIGO_PACIENTE)
          WHEN INSTR(CODIGO_PACIENTE, '.') > 0       THEN TO_NUMBER(REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', ''))
          ELSE NULL
         END AS CODIGO_PACIENTE 
        ,CASE 
          WHEN REGEXP_LIKE(CODIGO_ATENDIMENTO, '^\d+$') THEN CAST(CODIGO_ATENDIMENTO AS INTEGER)
          WHEN INSTR(CODIGO_ATENDIMENTO, '.') > 0       THEN CAST(REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') AS INTEGER)
          ELSE NULL
         END AS CODIGO_ATENDIMENTO
        ,DH_ATENDIMENTO
        ,DH_DISPARO
        ,DH_RESPOSTA
        ,NOME_PACIENTE_RHP
        ,NUMERO_CLIENTE
        ,NASCIMENTO
        ,IDADE_PACIENTE
        ,GENERO_PACIENTE
        ,UNIDADE
        ,CASE 
            WHEN NOME_SETOR = 'ESAN 04¿ AND - DAY CLINIC TMO - TRANSP. MED. OSSEA' THEN 'ESAN 04º AND - DAY CLINIC TMO - TRANSP. MED. OSSEA'
            WHEN NOME_SETOR = 'ESAN 05¿ AND - DAY CLINIC SUS' THEN 'ESAN 05º AND - DAY CLINIC SUS'
            ELSE NOME_SETOR
        END AS NOME_SETOR
        ,CASE
          WHEN NOME_SETOR in (
            'UABV - EMERGENCIA'
            , 'UABV - REAL IMAGEM - RADIOLOGIA'
            )
          THEN 'UABV'
          WHEN NOME_SETOR in (
            'ERHC 01º AND - UTI CORONARIA'
            , 'ERHC 02º AND - UNIDADE DE OBSERVAÇÃO DA CARDIOLOGIA'
            , 'EEMZ 07º AND - APARTAMENTO'
            , 'EEMZ 07¿ AND - APARTAMENTO'
            , 'ESAN 06º AND - ENFERMARIA SUS'
            , 'ESAN 06¿ AND - ENFERMARIA SUS'
            )
          THEN 'Cardiologia'
          WHEN AREA_PESQUISA in (
            'LINHA CUIDADO CARDIO'
            )
          THEN 'Cardiologia'
          WHEN NOME_SETOR in (
            'EJDS 06º AND - RIO - INFUSAO'
            , 'EJDS 06¿ AND - RIO - INFUSAO'
            , 'EJDS 09º AND - APARTAMENTO ONCOLOGIA'
            , 'EJDS 09¿ AND - APARTAMENTO ONCOLOGIA'
            , 'EJDS 15º AND - APARTAMENTO TMO'
            , 'EJDS TERREO - RADIOTERAPIA UNIDADE 2'
            , 'ESAN 04º AND - DAY CLINIC INTER'
            , 'ESAN 04º AND - DAY CLINIC TMO - TRANSP. MED. OSSEA'
            , 'ESAN 04¿ AND - DAY CLINIC TMO - TRANSP. MED. OSSEA'
            , 'ESAN 04º AND - REAL DAY CLINIC'
            , 'ESAN 05º AND - DAY CLINIC SUS'
            , 'ESAN 05¿ AND - DAY CLINIC SUS'
            )
          THEN 'Oncologia'
          WHEN NOME_SETOR in (
            'ERLAB - REAL LAB'
            , 'ERLAB - REAL LAB DOMICILIAR'
            , 'ERLAB - REAL PATOLOGIA'
            , 'EJDS 01º AND - REAL VACINAS'
            , 'EJDS 01¿ AND - REAL VACINAS'
            , 'ESAN 06¿ AND - ENFERMARIA SUS'
            , 'PAVP TERREO - REAL IMAGEM - ADMINISTRATIVO'
            , 'PAVP TERREO - REAL IMAGEM - CINTILOGRAFIA'
            , 'PAVP 01º AND - REAL IMAGEM - ENDOSCOPIA.'
            , 'PAVP 01º AND - REAL IMAGEM - ULTRASSONOGRAFIA.'
            )
          THEN 'MDT'
          WHEN NOME_SETOR in (
            'ERMT TERREO - INFANTE EMERGENCIA'
            , 'ERMT TERREO - INFANTE INTERNAMENTO'
            , 'ERMT TERREO - REAL MATER EMERGENCIA'
            , 'ERMT 01º E 02º AND - APARTAMENTO'
            , 'EJDS 04º AND - UTI CARDIOPEDIATRICA'
            , 'EJDS 04º AND - UTI NEONATAL II'
            , 'EJDS 10º AND - APARTAMENTO PEDIATRIA'
            , 'EJDS 10¿ AND - APARTAMENTO PEDIATRIA'
            , 'EJDS 11º AND - APARTAMENTO PEDIATRIA'
            , 'EJDS 11¿ AND - APARTAMENTO PEDIATRIA'
            , 'EJDS 12º AND - APARTAMENTO PEDIATRIA'
            , 'EJDS 12¿ AND - APARTAMENTO PEDIATRIA'
            , 'EJDS 12º AND - UTI ONCOPEDIATRICA'
            , 'EJDS 12¿ AND - UTI ONCOPEDIATRICA'
            , 'EJDS 13º AND - UTI PEDIATRICA'
            , 'EJDS 13¿ AND - UTI PEDIATRICA'
            , 'JOAO DE DEUS-12º UTI ONCOPEDIA'
            , 'JOAO DE DEUS-13º UTI PEDIATRIA'
            , 'JOAO DE DEUS-4º UTI CARDIOPEDI'
            , 'JOAO DE DEUS-4ºUTI NEONATAL II'
            , 'REALMATER ALA 2º ANDAR'
            , 'REALMATER ALA 2¿ ANDAR'
            , 'ESAN 02º AND - UTI NEONATAL II'
            )
          THEN 'Pediatria'
          WHEN NOME_SETOR in (
          'ESAN TERREO E 01º AND - HEMODIALISE AMBULATORIAL SUS'
          , 'ESAN 01º AND – HEMODIALISE AMBULATORIAL CONVENIOS'
          , 'ESAN 01¿ AND ¿ HEMODIALISE AMBULATORIAL CONVENIOS'
          , 'ESAN 02º AND - UTI SUS GERAL 1'
          , 'ESAN 2º ANDAR- UTI SUS GERAL 1'
          , 'ESAN 05º AND - ENFERMARIA SUS'
          , 'ESAN 05¿ AND - ENFERMARIA SUS'
          )
          THEN 'SUS'
        END AS UNIDADES_BU 
        ,ORIGEM
        ,CONVENIO
        ,CANAL_DISTRIBUICAO
        ,CANAL_RESPOSTA
        ,decode(SEGUNDA_PERGUNTA,'Acompanhante',null ,'Paciente',null, null, '', SEGUNDA_PERGUNTA) AS SEGUNDA_PERGUNTA
        ,QUARTA_PERGUNTA
        ,PRIMEIRA_PERGUNTA 
        ,TERCEIRA_PERGUNTA 
        ,QUINTA_PERGUNTA
        ,CASE
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE '%MUITO BOM%'    THEN 'Muito Bom'
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE '%MUITO RUIM%'   THEN 'Muito Ruim'
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE 'BOM%'           THEN 'Bom'
            ELSE INITCAP(SEXTA_PERGUNTA)
        END AS TP_AVALIA_PROFISSIONAL
        ,SETIMA_PERGUNTA 
        ,OITAVA_PERGUNTA 
        ,NONA_PERGUNTA
        ,CASE
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_PERGUNTA) LIKE '%MUITO BOM%'   THEN 'Muito Bom'
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_PERGUNTA) LIKE '%MUITO RUIM%'  THEN 'Muito Ruim'
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_PERGUNTA) LIKE 'BOM%'          THEN 'Bom'
            ELSE INITCAP(DECIMA_PERGUNTA)
        END TP_AVALIA_CONFORTO
        ,DECIMA_PRIMEIRA_PERGUNTA  
        ,DECIMA_SEGUNDA_PERGUNTA 
        ,CASE
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_TERCEIRA_PERGUNTA) LIKE '%POSITIVA%' THEN 'Positiva'
            WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(DECIMA_TERCEIRA_PERGUNTA) LIKE '%NEGATIVA%' THEN 'Negativa'
            ELSE NVL(INITCAP(DECIMA_TERCEIRA_PERGUNTA),'Indiferente')
        END AS TP_AVALIA_EXP_COMPLETA
        ,CASE WHEN DH_RESPOSTA is not null THEN ROUND(((NVL(DH_RESPOSTA,SYSDATE) - DH_DISPARO)*24*60),0)    ELSE null end AS TMP_NPS    
        ,CASE WHEN DH_RESPOSTA is not null THEN TRUNC(NVL(DH_RESPOSTA,SYSDATE)) - TRUNC(DH_DISPARO)         ELSE null end AS TMP_NPS_DIAS
        ,DH_INTEGRACAO
    FROM RHPLEITURA.DES_CAMPANHA_NPS 
    WHERE DH_ATENDIMENTO IS NOT NULL
    AND CODIGO_ATENDIMENTO IS NOT NULL
    --AND AREA_PESQUISA not in ('EXAMES_LAB')
    --AND NOME_SETOR LIKE '%LAB%'
    --AND NUMERO_CLIENTE IN ('81984297985', '81999958544','81987786917', '81999611545')
    --AND NOT REGEXP_LIKE(CODIGO_ATENDIMENTO, '^\s*\d+(\.\d+)?\s*$')

),
D_PRIMEIRO_CAMPANHA AS(
SELECT 
  NS.CODIGO_PACIENTE AS PACIENTE_ATEND
  , NS.NOME_CAMPANHA AS CAMPANHA_ATEND
  , MIN(NS.CODIGO_ATENDIMENTO) AS PRIMEIRO_ATEND
  , 'PRIMEIRO' AS TIPO_ATEND
FROM NPS_SMARTSPACE NS 
GROUP BY NS.CODIGO_PACIENTE, NS.NOME_CAMPANHA
),
/*+ MATERIALIZE */D_DOCUMENTO_CLINICO AS(
    SELECT * FROM (
    SELECT 
      PDC.CD_ATENDIMENTO
      , PDC.CD_DOCUMENTO_CLINICO
      , PDC.CD_PRESTADOR
      , ROW_NUMBER() OVER (PARTITION BY PDC.CD_ATENDIMENTO ORDER BY PDC.DH_FECHAMENTO DESC, PDC.CD_DOCUMENTO_CLINICO) AS AUX
    FROM DBAMV.PW_DOCUMENTO_CLINICO PDC
    JOIN(SELECT CODIGO_ATENDIMENTO FROM NPS_SMARTSPACE WHERE AREA_PESQUISA = 'PRONTO_SOCORRO_GERAL') NS ON NS.CODIGO_ATENDIMENTO = PDC.CD_ATENDIMENTO
    JOIN DBAMV.PW_EDITOR_CLINICO PEC ON PEC.CD_DOCUMENTO_CLINICO = PDC.CD_DOCUMENTO_CLINICO AND PEC.CD_DOCUMENTO IN (730,566,1130,1131,1298) /*DOCUMENTOS DE EVOLUÇÃO MEDICA*/
    JOIN DBAMV.PRESTADOR PRES        ON PRES.CD_PRESTADOR = PDC.CD_PRESTADOR
    JOIN DBAMV.CONSELHO CONS         ON CONS.CD_CONSELHO = PRES.CD_CONSELHO AND CONS.TP_CONSELHO = '1' /*CRM*/
    
    WHERE PDC.TP_STATUS = 'FECHADO'
    AND PDC.DH_FECHAMENTO >= DATE'2025-01-01'
    AND PDC.CD_ATENDIMENTO IS NOT NULL
    ) 
    WHERE AUX = 1
),
D_ATENDIMENTO AS(
    SELECT 
    CAST(ATE.CD_ATENDIMENTO AS NUMBER) AS CD_ATENDIMENTO
    , ATE.CD_MULTI_EMPRESA
    , ESPAT.DS_ESPECIALID   AS DS_ATEND_ESP
    , ATE.NM_USUARIO        AS CD_RECEP_AT
    , STP.NM_USUARIO        AS CD_ENF_TRIAGEM
    , NVL (DC.CD_PRESTADOR, ATE.CD_PRESTADOR)  AS CD_MEDASS_AT
    , SN_OBITO
    FROM DBAMV.ATENDIME ATE
    JOIN(SELECT CODIGO_ATENDIMENTO FROM NPS_SMARTSPACE) NS ON NS.CODIGO_ATENDIMENTO = ATE.CD_ATENDIMENTO
    LEFT JOIN (SELECT CD_ATENDIMENTO, CD_PRESTADOR FROM D_DOCUMENTO_CLINICO) DC ON DC.CD_ATENDIMENTO = ATE.CD_ATENDIMENTO
    LEFT JOIN D_DOCUMENTO_CLINICO DC          ON REGEXP_REPLACE(DC.CD_ATENDIMENTO, '[^0-9]') = ATE.CD_ATENDIMENTO
    LEFT JOIN DBAMV.ESPECIALID ESPAT          ON ESPAT.CD_ESPECIALID = ATE.CD_ESPECIALID
    LEFT JOIN DBAMV.SACR_TEMPO_PROCESSO STP   ON STP.CD_ATENDIMENTO = ATE.CD_ATENDIMENTO AND STP.CD_TIPO_TEMPO_PROCESSO = 12
       
    WHERE (ATE.CD_ATENDIMENTO IS NOT NULL)
    --AND ATE.CD_ATENDIMENTO IN (5582268, 6072753)
    GROUP BY ATE.CD_ATENDIMENTO, ATE.NM_USUARIO , ATE.CD_MULTI_EMPRESA, ESPAT.DS_ESPECIALID, STP.NM_USUARIO, NVL (DC.CD_PRESTADOR, ATE.CD_PRESTADOR) ,SN_OBITO
),
D_UNIQUE AS(
    SELECT 
        PA.CD_PERFIL_ALERTA
        , PA.PERFIL
        , PAP.CD_PACIENTE
    FROM DBAMV.PERFIL_ALERTA PA
    LEFT JOIN DBAMV.PERFIL_ALERTA_PACIENTE PAP ON PAP.CD_PERFIL_ALERTA = PA.CD_PERFIL_ALERTA
    JOIN(SELECT CODIGO_PACIENTE FROM NPS_SMARTSPACE) NS ON NS.CODIGO_PACIENTE = PAP.CD_PACIENTE
    WHERE (PAP.CD_PACIENTE IS NOT NULL)
    AND PA.CD_PERFIL_ALERTA IN (
                                43 --UNIQUE VIP
                                ,44 --UNIQUE REFERENCIADO
                                ,45 --UNIQUE NOTORIO
                                ,47 --UNIQUE ASSOCIADO
                                )
    GROUP BY PA.CD_PERFIL_ALERTA, PA.PERFIL, PAP.CD_PACIENTE
),
D_EXAME_UNICO AS(
SELECT CD_ATENDIMENTO, DS_EXA ,DT_PEDIDO, CD_EXA_LAUDADOR
FROM (
    SELECT 
    PRX.CD_ATENDIMENTO
    ,IRX.CD_PED_RX
    ,PRX.DT_PEDIDO
    ,IRX.CD_EXA_RX ||' - '||ERX.DS_EXA_RX AS DS_EXA
    ,(SELECT MAX(REVISORNOME) FROM IDCE.LAUDOS LAU WHERE LAU.CD_PED_RX = PRX.CD_PED_RX AND PRX.CD_ATENDIMENTO = LAU.CD_ATENDIMENTO AND AC_NUMBER = IRX.CD_ITPED_RX) AS CD_EXA_LAUDADOR
    ,RANK() OVER (PARTITION BY PRX.CD_ATENDIMENTO ORDER BY IRX.DT_REALIZADO DESC, IRX.CD_SEQ_INTEGRA) AS AUX
    
    from DBAMV.ITPED_RX IRX
    left join DBAMV.PED_RX PRX      ON PRX.CD_PED_RX = IRX.CD_PED_RX
    left join DBAMV.EXA_RX ERX      ON IRX.CD_EXA_RX = ERX.CD_EXA_RX
    JOIN(SELECT CODIGO_ATENDIMENTO FROM NPS_SMARTSPACE  WHERE AREA_PESQUISA = 'EXAMES_IMAGEM') NS ON NS.CODIGO_ATENDIMENTO = PRX.CD_ATENDIMENTO
    WHERE IRX.DT_REALIZADO IS NOT NULL
    AND (CD_ATENDIMENTO IS NOT NULL)
    )
  WHERE AUX = 1
  GROUP BY CD_ATENDIMENTO, DS_EXA ,DT_PEDIDO, CD_EXA_LAUDADOR
),
/*BLOCO SOBRE ATENDIMENTOS DE LABORATORIO*/
D_LOG_AGG AS (
  SELECT
    CD_ATENDIMENTO,
    CD_PED_LAB_RX,
    CD_ITPED_LAB_RX,
    MAX(CASE WHEN DS_MOVIMENTO LIKE '%Amostra associada ao exame foi colhida no Setor%' THEN CD_USUARIO_RESPONSAVEL END) AS CD_COLETA_LAB,
    MAX(CASE WHEN DS_MOVIMENTO LIKE '%Amostra associada ao exame foi recepcionada/colhida pelo Laboratório%' THEN CD_USUARIO_RESPONSAVEL END) AS CD_CONFIRMA_LAB,
    MAX(CASE WHEN DS_MOVIMENTO LIKE '%Exame movimentado pela Bancada%' THEN CD_USUARIO_RESPONSAVEL END) AS CD_BANCADA,
    --MAX(CASE WHEN DS_MOVIMENTO LIKE '%Exame revisado%' THEN CD_USUARIO_RESPONSAVEL END) AS CD_RESULTADO_LAB,
    MAX(CASE WHEN DS_MOVIMENTO LIKE '%Exame Assinado%' THEN CD_USUARIO_RESPONSAVEL END) AS CD_LIBERADO_LAB
  FROM DBAMV.LOG_MOVIMENTO_EXAME lme
  JOIN DBAMV.ITPED_LAB IPL ON lme.CD_PED_LAB_RX = IPL.CD_PED_LAB
  JOIN(SELECT CODIGO_ATENDIMENTO FROM NPS_SMARTSPACE WHERE AREA_PESQUISA = 'EXAMES_LAB') NS ON NS.CODIGO_ATENDIMENTO = lme.CD_ATENDIMENTO
  WHERE lme.DT_MOVIMENTO >= TO_DATE('01/01/2022','DD/MM/YYYY')
  AND lme.DT_MOVIMENTO < TRUNC(SYSDATE) + 1
  AND (CD_ATENDIMENTO IS NOT NULL)
  GROUP BY CD_ATENDIMENTO, CD_PED_LAB_RX, CD_ITPED_LAB_RX
),
D_LAB AS(
  SELECT CD_ATENDIMENTO, CD_COLETA_LAB, CD_BANCADA, CD_LIBERADO_LAB
  FROM(
    SELECT
      P.CD_ATENDIMENTO,
      P.CD_PED_LAB,
      IPL.CD_EXA_LAB,
      la.CD_COLETA_LAB,
      la.CD_CONFIRMA_LAB,
      la.CD_BANCADA,
      --la.CD_RESULTADO_LAB,
      la.CD_LIBERADO_LAB,
      RANK() OVER (PARTITION BY P.CD_ATENDIMENTO ORDER BY P.CD_PED_LAB DESC, P.HR_PED_LAB DESC) AS NR_ORD_PED,
      RANK() OVER (PARTITION BY P.CD_PED_LAB ORDER BY IPL.HR_LAUDO DESC, IPL.CD_ITPED_LAB DESC) AS NR_ORD_EXA
    FROM DBAMV.PED_LAB P
    JOIN DBAMV.ITPED_LAB IPL ON P.CD_PED_LAB = IPL.CD_PED_LAB
    LEFT JOIN D_LOG_AGG la ON la.CD_ATENDIMENTO = P.CD_ATENDIMENTO AND la.CD_PED_LAB_RX = P.CD_PED_LAB AND la.CD_ITPED_LAB_RX = IPL.CD_ITPED_LAB
    LEFT JOIN DBAMV.SET_EXA S ON S.CD_SET_EXA = P.CD_SET_EXA
    JOIN (SELECT CODIGO_ATENDIMENTO FROM NPS_SMARTSPACE WHERE AREA_PESQUISA = 'EXAMES_LAB') ns ON ns.CODIGO_ATENDIMENTO = P.CD_ATENDIMENTO
    
    WHERE P.DT_PEDIDO >= TO_DATE('01/01/2025','DD/MM/YYYY')
    AND P.DT_PEDIDO < TRUNC(SYSDATE) + 1
) base
WHERE NR_ORD_PED = 1
AND NR_ORD_EXA = 1
GROUP BY CD_ATENDIMENTO, CD_COLETA_LAB, CD_BANCADA, CD_LIBERADO_LAB
)

SELECT 
FONTE
, NOME_CAMPANHA             AS "Pesquisa"
, AREA_PESQUISA             AS "Área de Pesquisa" 
, AC_MAILING_ID
, CODIGO_PACIENTE           AS "Código do paciente"
, CODIGO_ATENDIMENTO        AS "Codigo do atendimento"
, DH_ATENDIMENTO            AS "Data de Atendimento"
, DH_DISPARO                AS "Data/hora do envio"
, DH_RESPOSTA               AS "Data de Resposta"
, NOME_PACIENTE_RHP         AS "Nome"
, NUMERO_CLIENTE            AS "Telefone"
, NASCIMENTO                AS "Data de nascimento"
, IDADE_PACIENTE            AS "Idade"
, GENERO_PACIENTE           AS "Sexo"
, UNIDADE                   AS "Unidades"
, NOME_SETOR                AS "Setores"
, UNIDADES_BU               AS "BU's"
, ORIGEM                    AS "Origem do atendimento"
, CONVENIO                  AS "Convênio"
, CANAL_DISTRIBUICAO        AS "Canal de Distribuição"
, CANAL_RESPOSTA            AS "Canal de resposta"
, null                      AS "E-mail"
, SEGUNDA_PERGUNTA          AS "Nota"
, CASE
      WHEN SEGUNDA_PERGUNTA BETWEEN 0 AND 6   THEN 'Detrator'
      WHEN SEGUNDA_PERGUNTA BETWEEN 7 AND 8   THEN 'Neutro'
      WHEN SEGUNDA_PERGUNTA BETWEEN 9 AND 11  THEN 'Promotor'
      ELSE 'Não classificado'
  END AS "Classificação"
, QUARTA_PERGUNTA           AS "Comentário"
, PRIMEIRA_PERGUNTA         AS "Consentimento Feedback"
, TERCEIRA_PERGUNTA         AS "Detalhar Experiência"
, QUINTA_PERGUNTA           AS "Consentimento para novas perguntas"
, TP_AVALIA_PROFISSIONAL    AS "Avalia Atend. Profissionais"
, SETIMA_PERGUNTA           AS "Profissional - Qual Principal Motivo"
, OITAVA_PERGUNTA           AS "Avalia Qual Categoria"
, NONA_PERGUNTA             AS "Destaque da Avaliação"
, TP_AVALIA_CONFORTO        AS "Avalia Conforto e Comodidade"
, DECIMA_PRIMEIRA_PERGUNTA  AS "Infraestrutura - Principais Motivos"
, DECIMA_SEGUNDA_PERGUNTA   AS "Infraestrutura - Qual Principal Motivo"
, TP_AVALIA_EXP_COMPLETA    AS "Avaliação Experiência Completa"
, TMP_NPS
, TMP_NPS_DIAS
, DH_INTEGRACAO

, NVL(D_PRIMEIRO_CAMPANHA.TIPO_ATEND, 'RETORNO') AS SN_PRIMEIRO_CAMPANHA

, D_ATENDIMENTO.CD_MULTI_EMPRESA
, D_ATENDIMENTO.CD_RECEP_AT
, D_ATENDIMENTO.CD_ENF_TRIAGEM
, D_ATENDIMENTO.CD_MEDASS_AT
, D_ATENDIMENTO.DS_ATEND_ESP AS "Especialidade"
, D_ATENDIMENTO.SN_OBITO

, CASE
    WHEN D_UNIQUE.PERFIL IS NOT NULL 
        THEN D_UNIQUE.PERFIL
    WHEN D_UNIQUE.PERFIL IS NULL AND ORIGEM IN ('RHC 14º - UNIQUE ', 'RHC 13° - UNIQUE')
        THEN 'EXP. UNIQUE'
END AS CAT_UNIQUE

, D_EXAME_UNICO.DS_EXA
, D_EXAME_UNICO.CD_EXA_LAUDADOR

, D_LAB.CD_COLETA_LAB
, D_LAB.CD_BANCADA
, D_LAB.CD_LIBERADO_LAB

,CASE 
  WHEN CODIGO_ATENDIMENTO = (SELECT MIN(CD_ATENDIMENTO) FROM DBAMV.ATENDIME WHERE CD_PACIENTE = CODIGO_PACIENTE)
  THEN 'PRIMEIRO' ELSE 'RETORNO'
END AS SN_PRIMEIRO_ATEND

FROM NPS_SMARTSPACE 
LEFT JOIN D_PRIMEIRO_CAMPANHA ON D_PRIMEIRO_CAMPANHA.PRIMEIRO_ATEND = NPS_SMARTSPACE.CODIGO_ATENDIMENTO AND D_PRIMEIRO_CAMPANHA.CAMPANHA_ATEND = NPS_SMARTSPACE.NOME_CAMPANHA
LEFT JOIN D_ATENDIMENTO       ON D_ATENDIMENTO.CD_ATENDIMENTO = NPS_SMARTSPACE.CODIGO_ATENDIMENTO
LEFT JOIN D_UNIQUE            ON D_UNIQUE.CD_PACIENTE = NPS_SMARTSPACE.CODIGO_PACIENTE
LEFT JOIN D_EXAME_UNICO       ON D_EXAME_UNICO.CD_ATENDIMENTO = NPS_SMARTSPACE.CODIGO_ATENDIMENTO
LEFT JOIN D_LAB               ON D_LAB.CD_ATENDIMENTO = NPS_SMARTSPACE.CODIGO_ATENDIMENTO

--WHERE TRUNC(DH_ATENDIMENTO) >= DATE '2026-03-31'
--AND TRUNC(DH_DISPARO) >= DATE '2026-04-01'

--ORDER BY DH_DISPARO DESC

/*----------------------------------------------------------------------------------------------
# VERIFICAÇÃO DE PROCESSAMENTO DE DADOS E PERFORMANCE DA CARGA                                 #
----------------------#-------------------------#-----------------#--------------#-------------#
#     TABLESPACE      #      TEMPO INICIAL      #  LINHAS TOTAIS  # REALIZADO EM # RESPONSAVEL #
----------------------#-------------------------#-----------------#--------------#-------------#
# NPS_SMARTSPACE      # 50 LINHAS EM 00,176 SEG #     383.290     #  17/12/2025  #    26521    #
# D_ATENDIMENTO       # 50 LINHAS EM 04.897 SEG #     383.290     #  17/12/2025  #    26521    #
# D_UNIQUE            # 50 LINHAS EM 04,783 SEG #     383.290     #  17/12/2025  #    26521    #
# D_EXAME_UNICO       # 50 LINHAS EM 12,861 SEG #     383.290     #  17/12/2025  #    26521    #
# D_LAB               # 50 LINHAS EM 22.311 SEG #     383.290     #  17/12/2025  #    26521    #
# D_DOCUMENTO_CLINICO # 50 LINHAS EM 52.599 SEG #     383.290     #  17/12/2025  #    26521    # ADC INFORMAÇÃO PARA VERIFICAR O PRIMEIRO PRESTADOR DA EVOLUÇÃO MÉDICA
----------------------#-------------------------#-----------------#--------------#-------------#
# NPS_SMARTSPACE      # 50 LINHAS EM 00,256 SEG #     406.706     #  10/01/2026  #    26521    #
# D_PRI_CAMPANHA      # 50 LINHAS EM 02,467 SEG #     406.706     #  10/01/2026  #    26521    #
# D_ATENDIMENTO       # 50 LINHAS EM 25.525 SEG #     406.706     #  10/01/2026  #    26521    # VINCULO COM A D_DOCUMENTO_CLINICO QUE É RESPONSAVEL VERIFICAR O PRIMEIRO PRESTADOR DA EVOLUÇÃO MÉDICA
# D_UNIQUE            # 50 LINHAS EM 20,669 SEG #     406.706     #  10/01/2026  #    26521    #
# D_EXAME_UNICO       # 50 LINHAS EM 37,077 SEG #     406.706     #  10/01/2026  #    26521    #
# D_LAB               # 50 LINHAS EM 53.133 SEG #     406.706     #  10/01/2026  #    26521    #
----------------------#-------------------------#-----------------#--------------#-------------#
# NOVA CHECAGEM APOS AJUSTES SUGERIDOS PELO CHATGPT, APOS ANALISE DOS REGISTROS ANTERIORES     #
----------------------#-------------------------#-----------------#--------------#-------------#
# NPS_SMARTSPACE      # 50 LINHAS EM 00,191 SEG #     406.706     #  10/01/2026  #    26521    #
# D_PRI_CAMPANHA      # 50 LINHAS EM 02,460 SEG #     406.706     #  10/01/2026  #    26521    #
# D_ATENDIMENTO       # 50 LINHAS EM 27.250 SEG #     406.706     #  10/01/2026  #    26521    # VINCULO COM A D_DOCUMENTO_CLINICO QUE É RESPONSAVEL VERIFICAR O PRIMEIRO PRESTADOR DA EVOLUÇÃO MÉDICA
# D_UNIQUE            # 50 LINHAS EM 24,033 SEG #     406.706     #  10/01/2026  #    26521    #
# D_EXAME_UNICO       # 50 LINHAS EM 38,723 SEG #     406.706     #  10/01/2026  #    26521    #
# D_LAB               # 50 LINHAS EM 54.382 SEG #     406.706     #  10/01/2026  #    26521    #
----------------------#-------------------------#-----------------#--------------#-------------#
# NPS_SMARTSPACE      # 50 LINHAS EM 00,212 SEG #     437.609     #  19/02/2026  #    26521    # ADICIONADO UNION ALL PARA TRATAMENTO DIFERENCIADO SOBRE CAMPANHA EXAMES_LAB
# D_PRI_CAMPANHA      # 50 LINHAS EM 03,471 SEG #     437.609     #  19/02/2026  #    26521    #
# D_ATENDIMENTO       # 50 LINHAS EM 25.307 SEG #     437.609     #  19/02/2026  #    26521    # VINCULO COM A D_DOCUMENTO_CLINICO QUE É RESPONSAVEL VERIFICAR O PRIMEIRO PRESTADOR DA EVOLUÇÃO MÉDICA
# D_UNIQUE            # 50 LINHAS EM 29,148 SEG #     437.609     #  19/02/2026  #    26521    #
# D_EXAME_UNICO       # 50 LINHAS EM 43,294 SEG #     437.609     #  19/02/2026  #    26521    #
# D_LAB               # 50 LINHAS EM 79.084 SEG #     437.609     #  19/02/2026  #    26521    #
----------------------#-------------------------#-----------------#--------------#-------------#*/
