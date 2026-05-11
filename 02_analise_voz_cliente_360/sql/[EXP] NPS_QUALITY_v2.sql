SELECT DISTINCT DS_QUESTIONARIO FROM rhpleitura.des_quality_resposta_nps resp
;
WITH BASE_QUALITY AS(
SELECT 
  'Pesquisa - Enfermagem' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do atendimento da equipe de enfermagem hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Médica' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do atendimento da equipe médica hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Concierges' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do atendimento da nossa equipe de concierges de hospitalidade?'

  UNION ALL

SELECT 
  'Pesquisa - Higienização' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do nosso serviço de higienização hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Lavanderia' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do nosso serviço de lavanderia/enxoval hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Transporte' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do nosso serviço de transporte/remoção hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Nutrição' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade do nosso serviço de nutrição hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Exames' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade dos exames realizados hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Infraestrutura' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a qualidade de nossas acomodações hoje?'

  UNION ALL

SELECT 
  'Pesquisa - Hig. Mãos' AS PESQUISA
  ,nps.ID
  , nps.STATUS
  , nps.CD_PACIENTE
  , nps.CD_ATENDIMENTO
  , nps.DH_RESPOSTA
  , nps.DH_INTEGRACAO
  , resp.VL_RESPOSTA
  --, resp.DS_QUESTIONARIO
  , resp.DS_COMENTARIO
  , resp.DS_MELHORIA
  , (SELECT COUNT(ID) FROM rhpleitura.des_quality_nps) NR_QUEST_DISPARADO
FROM rhpleitura.des_quality_nps nps 
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID 
WHERE DS_QUESTIONARIO = 'Como você avalia a frequência da higienização das mãos dos profissionais de saúde antes de realizarem os cuidados?'
)
SELECT * FROM BASE_QUALITY
