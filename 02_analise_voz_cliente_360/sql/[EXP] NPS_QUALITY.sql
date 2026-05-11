WITH BASE_QUALITY AS(
    SELECT 
    nps.ID
    , nps.STATUS
    , nps.CD_PACIENTE
    , nps.CD_ATENDIMENTO
    , nps.DH_RESPOSTA
    , nps.DH_INTEGRACAO
    , resp.VL_RESPOSTA
    , resp.DS_QUESTIONARIO
    , resp.DS_COMENTARIO
    , resp.DS_MELHORIA
    --, AVG(resp.VL_RESPOSTA) AS NOTA_MED
    , (SELECT COUNT(DISTINCT DS_QUESTIONARIO) FROM rhpleitura.des_quality_resposta_nps resp) NR_PERG_ENVIADA
    , (SELECT COUNT(VL_RESPOSTA) FROM rhpleitura.des_quality_resposta_nps resp WHERE resp.ID = nps.ID AND VL_RESPOSTA IS NOT NULL) NR_PERG_RESPONDIDA
    FROM rhpleitura.des_quality_nps nps 
    LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID
    --WHERE nps.CD_PACIENTE = 2341570
    GROUP BY
    nps.ID
    , nps.STATUS
    , nps.CD_PACIENTE
    , nps.CD_ATENDIMENTO
    , nps.DH_RESPOSTA
    , nps.DH_INTEGRACAO
    , resp.VL_RESPOSTA
    , resp.DS_QUESTIONARIO
    , resp.DS_COMENTARIO
    , resp.DS_MELHORIA
),
BASE_PIVOTADA AS (
  SELECT *
  FROM BASE_QUALITY
 PIVOT (
    MAX(VL_RESPOSTA) FOR DS_QUESTIONARIO IN (
      'Como você avalia a frequência da higienização das mãos dos profissionais de saúde antes de realizarem os cuidados?' AS PERG_HIGIENIZAR_MAOS
      ,'Como você avalia a qualidade de nossas acomodações hoje?' AS PERG_INFRAESTRUTURA
      ,'Como você avalia a qualidade do atendimento da equipe de enfermagem hoje?' AS PERG_EQUIP_ENFERMAGEM
      ,'Como você avalia a qualidade do atendimento da equipe médica hoje?' AS PERG_EQUIP_MEDICA
      ,'Como você avalia a qualidade do atendimento da nossa equipe de concierges de hospitalidade?' AS PERG_EQUIP_CONCIERGE
      ,'Como você avalia a qualidade do nosso serviço de higienização hoje?' AS PERG_EQUIP_HIGIENIZACAO
      ,'Como você avalia a qualidade do nosso serviço de lavanderia/enxoval hoje?' AS PERG_EQUIP_LAVANDERIA
      ,'Como você avalia a qualidade do nosso serviço de nutrição hoje?' AS PERG_EQUIP_NUTRICAO
      ,'Como você avalia a qualidade do nosso serviço de transporte/remoção hoje?' AS PERG_EQUIP_TRANSPORTE
      ,'Como você avalia a qualidade dos exames realizados hoje?' AS PERG_EXAMES_REALIZADOS
    )
  )
)
SELECT 
BASE_PIVOTADA.* 
--,LISTAGG(DS_Q || ': ' || DS_COMENTARIO, '; ' || CHR(10)) WITHIN GROUP (ORDER BY DS_Q, DS_COMENTARIO) AS DS_COMENTARIO
FROM BASE_PIVOTADA
--WHERE CD_PACIENTE = 527491 --2261083
;
SELECT * FROM rhpleitura.des_quality_nps nps
LEFT JOIN rhpleitura.des_quality_resposta_nps resp ON resp.ID = nps.ID
WHERE nps.CD_PACIENTE = 527491
;
SELECT
    '''' || DS_QUESTIONARIO || ''' AS ' ||
    REPLACE(
        TRANSLATE(UPPER(SUBSTR(DS_QUESTIONARIO, 1, 100)),
                  'ÁÀÃÂÉÈÊÍÌÎÓÒÕÔÚÙÛÇ ?!,.:-/()',
                  'AAAAEEEIIIOOOOUUUC___________'),
        ' ', '_'
    ) AS linha_pivot
FROM (
    SELECT DISTINCT DS_QUESTIONARIO
    FROM rhpleitura.des_quality_resposta_nps
)
ORDER BY DS_QUESTIONARIO;
