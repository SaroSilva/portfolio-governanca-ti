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
#   02/12/2025  #    26521    # ADIÇÃO DE DIMENNSÕES                            #     SERVICENOW      # 
#     10:50     #             # -Adc base de laboratorio oriunda de regra de    #     RITM0020543     # 
#               #             # negocio utilizado nos tempos de emergencias     #                     # 
-----------------------------------------------------------------------------------------------------*/

WITH BASE_NPS AS (
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
    ,AREA_PESQUISA
    ,AREA_PESQUISA AS "Área de Pesquisa"
    ,NOME_PACIENTE_RHP AS "Nome"
    ,CONVENIO AS "Convênio"
    ,null AS "E-mail"
    ,REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', '') AS CODIGO_PACIENTE
    ,REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') AS CODIGO_ATENDIMENTO
    ,REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', '') AS "Código do paciente"
    ,REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') AS "Codigo do atendimento"
    ,ORIGEM
    ,ORIGEM AS "Origem do atendimento"
    ,NUMERO_CLIENTE AS "Telefone"
    ,DH_ATENDIMENTO
    ,DH_ATENDIMENTO AS "Data de Atendimento"
    ,NASCIMENTO AS "Data de nascimento"
    ,(SELECT ESP.DS_ESPECIALID FROM DBAMV.ESPECIALID ESP, DBAMV.ATENDIME ATE WHERE ESP.CD_ESPECIALID = ATE.CD_ESPECIALID AND ATE.CD_ATENDIMENTO = REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '')) AS "Especialidade"
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
  FROM RHPLEITURA.des_campanha_nps
),

UNIQUE_CAT AS (
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
AND PAP.CD_PACIENTE IN (SELECT CODIGO_PACIENTE FROM BASE_NPS)
),

EXAME_UNICO AS(
SELECT CD_ATENDIMENTO, DS_EXA ,DT_PEDIDO, REVISORNOME
  FROM (
    select 
    PRX.CD_ATENDIMENTO
    ,IRX.CD_PED_RX
    ,PRX.DT_PEDIDO
    ,IRX.CD_EXA_RX ||' - '||ERX.DS_EXA_RX AS DS_EXA
    ,(SELECT MAX(LAU.REVISORNOME) FROM IDCE.LAUDOS LAU WHERE LAU.CD_PED_RX = PRX.CD_PED_RX AND PRX.CD_ATENDIMENTO = LAU.CD_ATENDIMENTO) AS REVISORNOME
    ,RANK() OVER (PARTITION BY PRX.CD_ATENDIMENTO ORDER BY IRX.DT_REALIZADO DESC) AS AUX
    
    from DBAMV.ITPED_RX IRX
    left join DBAMV.PED_RX PRX ON PRX.CD_PED_RX = IRX.CD_PED_RX
    left join DBAMV.EXA_RX ERX ON IRX.CD_EXA_RX = ERX.CD_EXA_RX
    WHERE PRX.CD_ATENDIMENTO IN (SELECT CODIGO_ATENDIMENTO FROM BASE_NPS WHERE AREA_PESQUISA = 'EXAME_IMAGEM')
    )
WHERE AUX = 1
),
LAB AS(
  SELECT * FROM(
    SELECT 
        P.CD_ATENDIMENTO,
        MAX(P.CD_PED_LAB) AS CD_PED_LAB,
        IPL.CD_EXA_LAB,
        
        (SELECT MAX(CD_USUARIO_RESPONSAVEL) AS DT_MOVIMENTO FROM DBAMV.LOG_MOVIMENTO_EXAME lme
            WHERE lme.DT_MOVIMENTO >= '01/01/2025'
            AND lme.DT_MOVIMENTO < TRUNC(SYSDATE)+INTERVAL '24' HOUR
            AND CD_ATENDIMENTO = P.CD_ATENDIMENTO
            AND CD_PED_LAB_RX = P.CD_PED_LAB
            AND CD_ITPED_LAB_RX = IPL.CD_ITPED_LAB
            AND DS_MOVIMENTO LIKE '%Amostra associada ao exame foi colhida no Setor%'
              ) AS CD_COLETA_LAB,
        
        (SELECT MAX(CD_USUARIO_RESPONSAVEL) AS DT_MOVIMENTO FROM DBAMV.LOG_MOVIMENTO_EXAME lme
            WHERE lme.DT_MOVIMENTO >= '01/01/2025'-->= TRUNC(SYSDATE)- INTERVAL '24' HOUR
            AND lme.DT_MOVIMENTO < TRUNC(SYSDATE)+INTERVAL '24' HOUR
            AND CD_ATENDIMENTO = P.CD_ATENDIMENTO
            AND CD_PED_LAB_RX = P.CD_PED_LAB
            AND CD_ITPED_LAB_RX = IPL.CD_ITPED_LAB
            AND DS_MOVIMENTO LIKE '%Amostra associada ao exame foi recepcionada/colhida pelo Laboratório%'
              ) AS CD_CONFIRMA_LAB,
        
        (SELECT MAX(CD_USUARIO_RESPONSAVEL) AS DT_MOVIMENTO FROM DBAMV.LOG_MOVIMENTO_EXAME lme
            WHERE lme.DT_MOVIMENTO >= '01/01/2025'-->= TRUNC(SYSDATE)- INTERVAL '24' HOUR
            AND lme.DT_MOVIMENTO < TRUNC(SYSDATE)+INTERVAL '24' HOUR
            AND CD_ATENDIMENTO = P.CD_ATENDIMENTO
            AND CD_PED_LAB_RX = P.CD_PED_LAB
            AND CD_ITPED_LAB_RX = IPL.CD_ITPED_LAB
            AND DS_MOVIMENTO LIKE '%Exame movimentado pela Bancada%'
              ) AS CD_BANCADA,
        
        (SELECT MAX(CD_USUARIO_RESPONSAVEL) AS DT_MOVIMENTO FROM DBAMV.LOG_MOVIMENTO_EXAME lme
            WHERE lme.DT_MOVIMENTO >= '01/01/2025'-->= TRUNC(SYSDATE)- INTERVAL '24' HOUR
            AND lme.DT_MOVIMENTO < TRUNC(SYSDATE)+INTERVAL '24' HOUR
            AND CD_ATENDIMENTO = P.CD_ATENDIMENTO
            AND CD_PED_LAB_RX = P.CD_PED_LAB
            AND CD_ITPED_LAB_RX = IPL.CD_ITPED_LAB
            AND DS_MOVIMENTO LIKE '%Exame revisado%'
              ) AS CD_RESULTADO_LAB,
        
        (SELECT MAX(CD_USUARIO_RESPONSAVEL) AS DT_MOVIMENTO FROM DBAMV.LOG_MOVIMENTO_EXAME lme
            WHERE lme.DT_MOVIMENTO >= '01/01/2025'-->= TRUNC(SYSDATE)- INTERVAL '24' HOUR
            AND lme.DT_MOVIMENTO < TRUNC(SYSDATE)+INTERVAL '24' HOUR
            AND CD_ATENDIMENTO = P.CD_ATENDIMENTO
            AND CD_PED_LAB_RX = P.CD_PED_LAB
            AND CD_ITPED_LAB_RX = IPL.CD_ITPED_LAB
            AND DS_MOVIMENTO LIKE '%Exame Assinado%'
              ) AS CD_LIBERADO_LAB,

        RANK() OVER (PARTITION BY P.CD_ATENDIMENTO ORDER BY P.CD_PED_LAB DESC, P.HR_PED_LAB DESC) AS NR_ORD_PED,
        RANK() OVER (PARTITION BY P.CD_PED_LAB ORDER BY IPL.HR_LAUDO DESC, IPL.CD_ITPED_LAB DESC) AS NR_ORD_EXA

    FROM DBAMV.PED_LAB P,
         DBAMV.SET_EXA S,
         DBAMV.ITPED_LAB IPL
                    
    WHERE P.CD_ATENDIMENTO IN (SELECT CODIGO_ATENDIMENTO FROM BASE_NPS WHERE AREA_PESQUISA = 'EXAMES_LAB')
    AND P.CD_PED_LAB = IPL.CD_PED_LAB
    AND S.CD_SET_EXA(+) = P.CD_SET_EXA
    
    AND P.DT_PEDIDO >= '01/01/2025'--INTERVAL '24' HOUR TO_DATE(TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1) || '-01-01', 'YYYY-MM-DD') --
    --AND P.DT_PEDIDO >= TRUNC(SYSDATE)--INTERVAL '24' HOUR
    AND P.DT_PEDIDO < TRUNC(SYSDATE)+INTERVAL '24' HOUR

    group by P.CD_ATENDIMENTO, P.DT_PEDIDO, P.CD_PED_LAB, P.HR_PED_LAB, P.CD_PED_LAB, IPL.CD_EXA_LAB, IPL.HR_LAUDO, IPL.CD_SET_EXA, IPL.CD_ITPED_LAB
) base
WHERE NR_ORD_PED = 1
AND NR_ORD_EXA = 1
)

SELECT 
BASE_NPS.* 
,CASE
  WHEN UNIQUE_CAT.PERFIL IS NOT NULL THEN UNIQUE_CAT.PERFIL
  WHEN UNIQUE_CAT.PERFIL IS NULL AND ORIGEM IN ('RHC 14º - UNIQUE ', 'RHC 13° - UNIQUE')
  THEN 'EXP. UNIQUE'
  ELSE NULL 
END AS CAT_UNIQUE
,(SELECT CD_MULTI_EMPRESA FROM ATENDIME WHERE CD_ATENDIMENTO = CODIGO_ATENDIMENTO) AS CD_MULTI_EMPRESA  
,EXAME_UNICO.DS_EXA

,(SELECT NM_USUARIO FROM ATENDIME WHERE CD_ATENDIMENTO = CODIGO_ATENDIMENTO) AS CD_ATEND_RECEPCAO
,(SELECT NM_PRESTADOR FROM DBAMV.PRESTADOR PRE, DBAMV.ATENDIME ATE WHERE PRE.CD_PRESTADOR = ATE.CD_PRESTADOR AND ATE.CD_ATENDIMENTO = CODIGO_ATENDIMENTO) AS CD_ATEND_MA /*MEDICO ASSISTENTE*/
,(SELECT DS_ESPECIALID FROM DBAMV.ESPECIALID ESP, DBAMV.ESP_MED EMD, DBAMV.ATENDIME ATE WHERE ESP.CD_ESPECIALID = EMD.CD_ESPECIALID AND EMD.CD_PRESTADOR = ATE.CD_PRESTADOR AND ATE.CD_ATENDIMENTO = CODIGO_ATENDIMENTO AND EMD.SN_ESPECIAL_PRINCIPAL = 'S') AS DS_MA_ESPECIALID /*MEDICO ASSISTENTE*/
,CASE WHEN AREA_PESQUISA = 'EXAMES_LAB' THEN LAB.CD_COLETA_LAB    ELSE NULL END AS CD_COLETA_LAB
,CASE WHEN AREA_PESQUISA = 'EXAMES_LAB' THEN LAB.CD_BANCADA       ELSE NULL END AS CD_BANCADA
,CASE WHEN AREA_PESQUISA = 'EXAMES_LAB' THEN LAB.CD_RESULTADO_LAB ELSE NULL END AS CD_RESULTADO_LAB
,CASE WHEN AREA_PESQUISA = 'EXAMES_LAB' THEN LAB.CD_LIBERADO_LAB  ELSE NULL END AS CD_LIBERADO_LAB

,CASE WHEN AREA_PESQUISA = 'EXAME_IMAGEM' THEN EXAME_UNICO.REVISORNOME ELSE NULL END AS REVISORNOME_IMG

FROM BASE_NPS
LEFT JOIN UNIQUE_CAT ON UNIQUE_CAT.CD_PACIENTE = BASE_NPS.CODIGO_PACIENTE
LEFT JOIN EXAME_UNICO ON EXAME_UNICO.CD_ATENDIMENTO = BASE_NPS.CODIGO_ATENDIMENTO AND EXAME_UNICO.DT_PEDIDO = TRUNC(BASE_NPS.DH_ATENDIMENTO)
LEFT JOIN LAB ON LAB.CD_ATENDIMENTO = BASE_NPS.CODIGO_ATENDIMENTO