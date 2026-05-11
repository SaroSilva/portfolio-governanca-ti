/*-----------------------------------------------------------------------------------------------------
# ATUALIZADO EM # RESPONS�VEL #           JUSTIFICATIVA // MOTIVO               # CHAMADO/SOLICITA��O #
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   27/01/2025  #    26521    # Conforme migra��o dos disparos para SMARTSPACE. #       REDMINE       # 
#               #             # Foi realizado a montagem da query para estra��o #        9562         # 
#               #             # dos dados via API SmartSpace.                   #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   20/02/2025  #    26521    # Inserir os coment�rios dos pacientes na vis�o   #       REDMINE       # 
#               #             # geral para que possamos exportar a base de      #        9726         # 
#               #             # dados com todas as �reas juntas.                #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   21/02/2025  #    26521    # Na coluna do nome do paciente, apresentar apenas#       REDMINE       # 
#               #             # as iniciais. Retirar a coluna de e-mail da base #        9894         # 
#               #             # de dados que � exportada do B.I e incluir a     #                     # 
#               #             # colunas de setores, isso para a vis�o geral e   #                     #
#               #             # para todas as outras �reas.                     #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   21/02/2025  #    26521    # Mudar regra do c�lculo do NPS para as �reas de  #       REDMINE       # 
#               #             # Interna��o e Maternidade interna��o. Para essas #        9897         # 
#               #             # duas �reas, o c�lculo deve ser feito pela data  #                     # 
#               #             # do disparo.                                     #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   27/05/2025  #    26521    # Solicitamos por gentileza a agrega��o dos dados #       REDMINE       # 
#               #             # relacionados a �rea HD Conv�nio, pois atualmente#        11150        # 
#               #             # na vis�o geral do BI est� aparecendo HD Conv�nio#                     # 
#               #             # e Pesquisa Hemodi�lise Conv�nio o que corres-   #                     # 
#               #             # ponde a mesma �rea, sendo assim precisamos      #                     # 
#               #             # agregar esses dados e utilizar o nome           #                     # 
#               #             # Hemodi�lise Conv�nio.                           #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   06/06/2025  #    26521    # No BI os dados de maio precisamos dos seguintes #       REDMINE       # 
#               #             # ajustes: Unificar os setores que est�o repetidos#        11204        # 
#               #             # ,tanto no Real Vida Emerg�ncia como Unidades de #                     # 
#               #             # Interna��o N� de respostas do BI est� diferente #                     # 
#               #             # do que temos na Base de dados. Na base de dados #                     # 
#               #             # da Smartspace temos 8.082 respostas, no BI temos#                     # 
#               #             # 7.359.Precisamos do ajuste das informa��es para #                     # 
#               #             # que as informa��es apresentadas permane�am      #                     # 
#               #             # organizadas.                                    #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   20/06/2025  #    26521    # MUDAN�A NA VIEW DO NPS - SMARTSPACE             #       REDMINE       # 
#               #             # Ajustar regra de envio da pesquisa dos atendim- #        11353        # 
#               #             # entos da hemodialise convenio para recorrencia  #                     # 
#               #             # apos 7 dias para um mesmo paciente              #                     #
# ------------- # ----------- # ----------------------------------------------- # ------------------- #
#   27/11/2025  #    26521    # Ap�s modifica��o no campo de atenidmento e Paci-#                     # 
#     13:50     #             # ente, ajuste realizado pelo time da SmartSpace. #                     # 
#               #             # O campo na tabela � VARCHAR2 e conforme a infor-#                     # 
#               #             # ma��o inputada passou a ter ao seu final o cara-#                     # 
#               #             # cter ".0", que por padr�o representa dado INT.  #                     # 
# ------------- # ----------- # ----------------------------------------------- # ------------------- # 
#   27/11/2025  #    26521    # ADI��O NA REGRA DE ORIGEM UNIQUES               #                     # 
#     15:50     #             # -Adc o perfil 47 associados na UNIQUE_CAT       #                     # 
#               #             # -Adc a ORIGEM 13� RHC UNIQUE                    #                     # 
-----------------------------------------------------------------------------------------------------*/
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
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('MaternidadeInterna��o')THEN 'Maternidade'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('Emerg�nciac\concierge','Emerg�ncias\concierge')THEN 'Emerg�ncia'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemAgamenon')THEN 'Real Imagem Agamenon'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealImagemBoaviagem')THEN 'Real Imagem Boa Viagem'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('HDConvenio','PesquisaHemodi�liseConvenio')THEN 'HD Conv�nio'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('RealLab','Coletadomiciliar')THEN 'Real Lab'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('PesquisaRealVacina','RealVacina')THEN 'Real Vacina'
        WHEN REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '') IN ('NossaCl�nica')THEN 'Nossa Cl�nica'
        ELSE REPLACE(REPLACE(NOME_CAMPANHA, 'Pesquisa - ', ''), ' ', '')
      END AS "Pesquisa"
    ,AC_MAILING_ID
    ,DH_DISPARO AS "Data/hora do envio"
    ,CANAL_DISTRIBUICAO AS "Canal de Distribui��o"
    ,CANAL_RESPOSTA AS "Canal de resposta"
    ,DH_RESPOSTA AS "Data de Resposta"
    ,AREA_PESQUISA AS "�rea de Pesquisa"
    ,NOME_PACIENTE_RHP AS "Nome"
    ,CONVENIO AS "Conv�nio"
    ,null AS "E-mail"
    ,REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', '') AS "C�digo do paciente"
    ,REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') AS "Codigo do atendimento"
    ,ORIGEM AS "Origem do atendimento"
    ,NUMERO_CLIENTE AS "Telefone"
    ,DH_ATENDIMENTO AS "Data de Atendimento"
    ,NASCIMENTO AS "Data de nascimento"
    ,(SELECT ESP.DS_ESPECIALID FROM DBAMV.ESPECIALID ESP, DBAMV.ATENDIME ATE WHERE ESP.CD_ESPECIALID = ATE.CD_ESPECIALID AND ATE.CD_ATENDIMENTO = REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') ) AS "Especialidade"
    ,IDADE_PACIENTE AS "Idade"
    ,GENERO_PACIENTE AS "Sexo"
    ,UNIDADE AS "Unidades"
    ,NOME_SETOR AS "Setores"
    ,decode(SEGUNDA_PERGUNTA,'Acompanhante',null ,'Paciente',null, null, '', SEGUNDA_PERGUNTA) AS "Nota"
    ,QUARTA_PERGUNTA AS "Coment�rio"
    ,'SMARTSPACE' AS FONTE
    ,CASE
        WHEN SEGUNDA_PERGUNTA BETWEEN '0' AND '6' THEN 'Detrator'
        WHEN SEGUNDA_PERGUNTA BETWEEN '7' AND '8' THEN 'Neutro'
        WHEN SEGUNDA_PERGUNTA BETWEEN '9' AND '10' THEN 'Promotor'
        ELSE 'N�o classificado'
     END AS "Classifica��o"
     ,PRIMEIRA_PERGUNTA AS "Consentimento Feedback"
     ,TERCEIRA_PERGUNTA AS "Detalhar Experi�ncia"
     ,QUINTA_PERGUNTA AS "Consentimento para novas perguntas"
     ,CASE
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE '%MUITO BOM%' THEN 'Muito Bom'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE '%MUITO RUIM%' THEN 'Muito Ruim'
        WHEN SEGUNDA_PERGUNTA is not null AND TERCEIRA_PERGUNTA = 'Sim' AND UPPER(SEXTA_PERGUNTA) LIKE 'BOM%' THEN 'Bom'
        ELSE INITCAP(SEXTA_PERGUNTA)
      END AS "Avalia Atend. Profissionais"
     ,SETIMA_PERGUNTA AS "Profissional - Qual Principal Motivo"
     ,OITAVA_PERGUNTA AS "Avalia Qual Categoria"
     ,NONA_PERGUNTA AS "Destaque da Avalia��o"
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
      END AS "Avalia��o Experi�ncia Completa"
     ,case when DH_RESPOSTA is not null then ROUND(((NVL(DH_RESPOSTA,SYSDATE) - DH_DISPARO)*24*60),0) else null end AS TMP_NPS    
     ,case when DH_RESPOSTA is not null then TRUNC(NVL(DH_RESPOSTA,SYSDATE)) - TRUNC(DH_DISPARO) else null end AS TMP_NPS_DIAS
     ,DH_INTEGRACAO
     ,CASE
        WHEN (SELECT PERFIL FROM UNIQUE_CAT WHERE CD_PACIENTE = REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', '')) IS NOT NULL
        THEN (SELECT PERFIL FROM UNIQUE_CAT WHERE CD_PACIENTE = REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', ''))
        
        WHEN (SELECT PERFIL FROM UNIQUE_CAT WHERE CD_PACIENTE = REGEXP_REPLACE(CODIGO_PACIENTE, '\.0$', '')) IS NULL AND ORIGEM IN ('RHC 14� - UNIQUE ', 'RHC 13� - UNIQUE')
        THEN 'EXP. UNIQUE'
        
        ELSE NULL 
      END AS CAT_UNIQUE
      ,(SELECT CD_MULTI_EMPRESA FROM ATENDIME WHERE CD_ATENDIMENTO = REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') ) AS CD_MULTI_EMPRESA  
      ,(SELECT MAX(DS_EXA) FROM EXAME_UNICO  WHERE CD_ATENDIMENTO = REGEXP_REPLACE(CODIGO_ATENDIMENTO, '\.0$', '') AND TRUNC(DH_ATENDIMENTO) = DT_PEDIDO ) AS DS_EXA
    
FROM RHPLEITURA.des_campanha_nps