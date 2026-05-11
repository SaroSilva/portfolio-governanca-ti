/*-----------------------------------------------------------------------------------------------------
# ATUALIZADO EM # RESPONSÁVEL #           JUSTIFICATIVA // MOTIVO               # CHAMADO/SOLICITAÇÃO #
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   27/01/2025  #    26521    # Conforme migração dos disparos para SMARTSPACE. #       REDMINE       # 
#               #             # Foi realizado a montagem da query para estração #        9562         # 
#               #             # dos dados via API SmartSpace.                   #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   20/02/2025  #    26521    # Inserir os comentários dos pacientes na visão   #       REDMINE       # 
#               #             # geral para que possamos exportar a base de      #        9726         # 
#               #             # dados com todas as áreas juntas.                #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   21/02/2025  #    26521    # Na coluna do nome do paciente, apresentar apenas#       REDMINE       # 
#               #             # as iniciais. Retirar a coluna de e-mail da base #        9894         # 
#               #             # de dados que é exportada do B.I e incluir a     #                     # 
#               #             # colunas de setores, isso para a visão geral e   #                     #
#               #             # para todas as outras áreas.                     #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   21/02/2025  #    26521    # Mudar regra do cálculo do NPS para as áreas de  #       REDMINE       # 
#               #             # Internação e Maternidade internação. Para essas #        9897         # 
#               #             # duas áreas, o cálculo deve ser feito pela data  #                     # 
#               #             # do disparo.                                     #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   27/05/2025  #    26521    # Solicitamos por gentileza a agregação dos dados #       REDMINE       # 
#               #             # relacionados a área HD Convênio, pois atualmente#        11150        # 
#               #             # na visão geral do BI está aparecendo HD Convênio#                     # 
#               #             # e Pesquisa Hemodiálise Convênio o que corres-   #                     # 
#               #             # ponde a mesma área, sendo assim precisamos      #                     # 
#               #             # agregar esses dados e utilizar o nome           #                     # 
#               #             # Hemodiálise Convênio.                           #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   06/06/2025  #    26521    # No BI os dados de maio precisamos dos seguintes #       REDMINE       # 
#               #             # ajustes: Unificar os setores que estão repetidos#        11204        # 
#               #             # ,tanto no Real Vida Emergência como Unidades de #                     # 
#               #             # Internação Nº de respostas do BI está diferente #                     # 
#               #             # do que temos na Base de dados. Na base de dados #                     # 
#               #             # da Smartspace temos 8.082 respostas, no BI temos#                     # 
#               #             # 7.359.Precisamos do ajuste das informações para #                     # 
#               #             # que as informações apresentadas permaneçam      #                     # 
#               #             # organizadas.                                    #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   20/06/2025  #    26521    # MUDANÇA NA VIEW DO NPS - SMARTSPACE             #       REDMINE       # 
#               #             # Ajustar regra de envio da pesquisa dos atendim- #        11353        # 
#               #             # entos da hemodialise convenio para recorrencia  #                     # 
#               #             # apos 7 dias para um mesmo paciente              #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   27/11/2025  #    26521    # Após modificação no campo de atenidmento e Paci-#                     # 
#     13:50     #             # ente, ajuste realizado pelo time da SmartSpace. #                     # 
#               #             # O campo na tabela é VARCHAR2 e conforme a infor-#                     # 
#               #             # mação inputada passou a ter ao seu final o cara-#                     # 
#               #             # cter ".0", que por padrão representa dado INT.  #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   27/11/2025  #    26521    # ADIÇÃO NA REGRA DE ORIGEM UNIQUES               #                     # 
#     15:50     #             # -Adc o perfil 47 associados na UNIQUE_CAT       #                     # 
#               #             # -Adc a ORIGEM 13º RHC UNIQUE                    #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   01/12/2025  #    26521    # ADIÇÃO DE COLUNAS                               #     SERVICENOW      # 
#     15:50     #             # -Adc da coluna de responsavel pela abertura de  #     RITM0020543     # 
#               #             # atedimento - pertecente a recepção.             #                     #
#               #             # -Adc da coluna de responsavel médico pelo atend.#                     #
#               #             # sinalizado como médico assistente.              #                     # 
#               #             # -Adc da coluna de especialidade médica do MA.   #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   02/12/2025  #    26521    # ADIÇÃO DE DIMENSSÕES                            #     SERVICENOW      # 
#     10:50     #             # -Adc base de laboratorio oriunda de regra de    #     RITM0020543     # 
#               #             # negocio utilizado nos tempos de emergencias     #                     # 
#               #             # -Adc base de exame imagem oriunda de regra de   #                     # 
#               #             # negocio utilizado nos tempos de emergencias     #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   05/12/2025  #    26521    # REVISÃO SOBRE ESTRUTURA DA QUERY                #     SERVICENOW      # 
#     17:29     #             # -Adc na base de exames unicos, regra de evitar  #     RITM0020543     # 
#               #             # atendimentos duplicatos, DT_REALIZADO NOT NULL. #                     #
#               #             # -Adc na base de exames unicos, regra de evitar  #                     #
#               #             # atendimentos duplicatos,CD_SEQ_INTEGRA.         #                     #
#               #             # -Adc na base de exames unicos, regra de evitar  #                     #
#               #             # atendimentos duplicatos, DT_REALIZADO NOT NULL. #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   15/12/2025  #    26521    # ADIÇÃO DE REGRA NA DIMENSSÃO D_LOG_AGG          #     SERVICENOW      # 
#     17:23     #             # -Adc JOIN com a tabela ITPED_LAB para verificar #     RITM0020543     # 
#               #             # Data Prazo e comparar se a regra de liberação   #                     #
#               #             # do Exame foi realizada antes do prazo.          #                     #
#               #             # -Adc colunas de contagem de itens + soma de     #                     #
#               #             # itens que tiveram resultado no prazo.           #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   15/12/2025  #    26521    # REMOÇÃO DE REGRA NA DIMENSSÃO D_LOG_AGG         #     SERVICENOW      # 
#     18:16     #             # -Adc JOIN com a tabela ITPED_LAB para verificar #     RITM0020543     # 
#               #             # Data Prazo e comparar se a regra de liberação   #                     #
#               #             # do Exame foi realizada antes do prazo.          #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   16/12/2025  #    26521    # VERIFICAÇÃO DE INTEGRIDADE DE DADOS             #     SERVICENOW      # 
#     08:41     #             # -Total de Registros contidos com aplicação dos  #     RITM0020543     # 
#               #             # JOINS com as dimenssões estruturadas, 381.556.  #                     #
#               #             # -Total de registros contidos na dimessão base   #                     #
#               #             # NPS_SMARTSPACE com função MATERIALIZA, 381.556. #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   16/12/2025  #    26521    # ADIÇÃO DE DIMENSSÕES                            #     SERVICENOW      # 
#     18:07     #             # -Adc base de D_DOCUMENTO_CLINICO oriunda de     #     RITM0020543     # 
#               #             # regra de negocio utilizado nos tempos de emer-  #                     # 
#               #             # gencias para referenciar o medico do primeiro   #                     # 
#               #             # atendimento.                                    #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   17/12/2025  #    26521    # VERIFICAÇÃO DE INTEGRIDADE DE DADOS             #     SERVICENOW      # 
#     18:12     #             # -Total de Registros contidos com aplicação dos  #     RITM0020543     # 
#               #             # JOINS com as dimenssões estruturadas, 383.290.  #                     #
#               #             # -Total de registros contidos na dimessão base   #                     #
#               #             # NPS_SMARTSPACE com função MATERIALIZA, 383.290. #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   24/12/2025  #    26521    # ADC. REGRA DE PRIMEIRO ATENDIMENTO              #     SERVICENOW      # 
#     08:29     #             #                                                 #     RITM0024462     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   29/12/2025  #    26521    # UNIFICAÇÃO DE NOMECLATURA DE SETORES            #     SERVICENOW      # 
#     13:29     #             # >> Unificar os setores ESAN 04º / ESAN 4º       #     RITM0024462     # 
#               #             # >> Unificar os setores ESAN 05º / ESAN 5º       #                     # 
#               #             # >> Modificação no bloco NPS_SMARTSPACE          #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   09/01/2026  #    26521    # ADC. REGRA DE PRIMEIRO ATENDIMENTO              #     SERVICENOW      # 
#     13:29     #             # >> Está regra será segmentada por campanha. e a #     RITM0024462     # 
#               #             # anterior será primeira vez a nivel instituicão. #                     #
-----------------------------------------------------------------------------------------------------*/

WITH /*+ MATERIALIZE */NPS_SMARTSPACE AS(
    SELECT
        'SMARTSPACE' AS FONTE
        ,CASE
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('MaternidadeInternação')THEN 'Maternidade'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('Emergênciac\concierge','Emergências\concierge')THEN 'Emergência'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemAgamenon')THEN 'Real Imagem Agamenon'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemBoaviagem')THEN 'Real Imagem Boa Viagem'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('HDConvenio','PesquisaHemodiáliseConvenio', 'Pesquisa Hemodiálise Convenio')THEN 'HD Convênio'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealLab','Coletadomiciliar')THEN 'Real Lab'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('PesquisaRealVacina','RealVacina')THEN 'Real Vacina'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('NossaClínica', 'RealMedCenter')THEN 'Real MedCenter'
            WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('LCCCardio')THEN 'LCC Cardiologia'
            ELSE REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '')
        END AS NOME_CAMPANHA
        ,AREA_PESQUISA
        ,AC_MAILING_ID
        ,TO_NUMBER(
        CASE 
            WHEN INSTR(CODIGO_PACIENTE, '.') > 0 
            THEN REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', '')
            ELSE CODIGO_PACIENTE 
        END) AS CODIGO_PACIENTE 
        ,TO_NUMBER(
        CASE 
            WHEN INSTR(CODIGO_ATENDIMENTO, '.') > 0 
            THEN REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '')
            ELSE CODIGO_ATENDIMENTO 
        END) AS CODIGO_ATENDIMENTO
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
        ,ORIGEM
        ,CONVENIO
        ,CANAL_DISTRIBUICAO
        ,CANAL_RESPOSTA
        ,decode(SEGUNDA_PERGUNTA,'Acompanhante',null ,'Paciente',null, null, '', SEGUNDA_PERGUNTA) AS SEGUNDA_PERGUNTA
        ,QUARTA_PERGUNTA
        ,CASE
            WHEN SEGUNDA_PERGUNTA BETWEEN '0' AND '6'   THEN 'Detrator'
            WHEN SEGUNDA_PERGUNTA BETWEEN '7' AND '8'   THEN 'Neutro'
            WHEN SEGUNDA_PERGUNTA BETWEEN '9' AND '10'  THEN 'Promotor'
            ELSE 'Não classificado'
        END AS TP_CLASSIFICACAO
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
    --AND AREA_PESQUISA = 'PRONTO_SOCORRO_GERAL'
    --AND NOME_SETOR LIKE '%DAY CLINIC%'
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
),
D_ATENDIMENTO AS(
    SELECT 
    ATE.CD_ATENDIMENTO
    , ATE.CD_MULTI_EMPRESA
    , ESPAT.DS_ESPECIALID   AS DS_ATEND_ESP
    , ATE.NM_USUARIO        AS CD_RECEP_AT
    , STP.NM_USUARIO        AS CD_ENF_TRIAGEM
    , NVL (DC.CD_PRESTADOR, ATE.CD_PRESTADOR)  AS CD_MEDASS_AT
    FROM DBAMV.ATENDIME ATE
    JOIN(SELECT CODIGO_ATENDIMENTO FROM NPS_SMARTSPACE) NS ON NS.CODIGO_ATENDIMENTO = ATE.CD_ATENDIMENTO 
    LEFT JOIN (SELECT CD_ATENDIMENTO, CD_PRESTADOR FROM D_DOCUMENTO_CLINICO WHERE AUX = 1)  DC ON DC.CD_ATENDIMENTO = ATE.CD_ATENDIMENTO
    LEFT JOIN DBAMV.ESPECIALID ESPAT          ON ESPAT.CD_ESPECIALID = ATE.CD_ESPECIALID
    LEFT JOIN DBAMV.SACR_TEMPO_PROCESSO STP   ON STP.CD_ATENDIMENTO = ATE.CD_ATENDIMENTO AND STP.CD_TIPO_TEMPO_PROCESSO = 12
       
    WHERE (ATE.CD_ATENDIMENTO IS NOT NULL)
    --AND ATE.CD_ATENDIMENTO IN (5582268, 6072753)
    GROUP BY ATE.CD_ATENDIMENTO, ATE.NM_USUARIO , ATE.CD_MULTI_EMPRESA, ESPAT.DS_ESPECIALID, STP.NM_USUARIO, NVL (DC.CD_PRESTADOR, ATE.CD_PRESTADOR)
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
, ORIGEM                    AS "Origem do atendimento"
, CONVENIO                  AS "Convênio"
, CANAL_DISTRIBUICAO        AS "Canal de Distribuição"
, CANAL_RESPOSTA            AS "Canal de resposta"
, null                      AS "E-mail"
, SEGUNDA_PERGUNTA          AS "Nota"
, QUARTA_PERGUNTA           AS "Comentário"
, TP_CLASSIFICACAO          AS "Classificação"
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
# D_ATENDIMENTO       # 50 LINHAS EM 25.525 SEG #     406.706     #  10/01/2026  #    26521    # VINCULO COM A D_DOCUMENTO_CLINICO QUE É RESPONSAVEL ERIFICAR O PRIMEIRO PRESTADOR DA EVOLUÇÃO MÉDICA
# D_UNIQUE            # 50 LINHAS EM 20,669 SEG #     406.706     #  10/01/2026  #    26521    #
# D_EXAME_UNICO       # 50 LINHAS EM 37,077 SEG #     406.706     #  10/01/2026  #    26521    #
# D_LAB               # 50 LINHAS EM 53.133 SEG #     406.706     #  10/01/2026  #    26521    #
----------------------#-------------------------#-----------------#--------------#-------------#
# NOVA CHECAGEM APOS AJUSTES SUGERIDOS PELO CHATGPT, APOS ANALISE DOS REGISTROS ANTERIORES     #
----------------------#-------------------------#-----------------#--------------#-------------#
# NPS_SMARTSPACE      # 50 LINHAS EM 00,191 SEG #     406.706     #  10/01/2026  #    26521    #
# D_PRI_CAMPANHA      # 50 LINHAS EM 02,460 SEG #     406.706     #  10/01/2026  #    26521    #
# D_ATENDIMENTO       # 50 LINHAS EM 27.250 SEG #     406.706     #  10/01/2026  #    26521    # VINCULO COM A D_DOCUMENTO_CLINICO QUE É RESPONSAVEL ERIFICAR O PRIMEIRO PRESTADOR DA EVOLUÇÃO MÉDICA
# D_UNIQUE            # 50 LINHAS EM 24,033 SEG #     406.706     #  10/01/2026  #    26521    #
# D_EXAME_UNICO       # 50 LINHAS EM 38,723 SEG #     406.706     #  10/01/2026  #    26521    #
# D_LAB               # 50 LINHAS EM 54.382 SEG #     406.706     #  10/01/2026  #    26521    #
----------------------#-------------------------#-----------------#--------------#-------------#*/
