WITH variaveis AS (
    SELECT TRUNC(SYSDATE) - 8 AS ontem
    FROM DUAL
),
/*ADC POR 26521 EM 20/06/25 15:48 UTILIZADO PARA CAMPANHA DA HEMODIALISE*/
atendimentos_ordenados AS (
    SELECT
        cd_atendimento,
        cd_paciente,
        dt_atendimento,
        ROW_NUMBER() OVER (PARTITION BY cd_paciente ORDER BY dt_atendimento) AS ordem
    FROM dbamv.atendime ate
    LEFT JOIN DBAMV.ORI_ATE OA ON OA.CD_ORI_ATE = ATE.CD_ORI_ATE
    WHERE ATE.CD_CONVENIO NOT IN (2)
    AND OA.CD_MULTI_EMPRESA IN (1,2)
    AND OA.CD_SETOR IN (43,46)
),
cte_selecao (cd_atendimento, cd_paciente, dt_atendimento, ordem) AS (
    -- Primeira linha (atendimento mais antigo por paciente)
    SELECT
        cd_atendimento,
        cd_paciente,
        dt_atendimento,
        ordem
    FROM atendimentos_ordenados
    WHERE ordem = 1

    UNION ALL

    -- Próximos atendimentos, sempre pegando o primeiro que ocorra pelo menos 7 dias depois do anterior
    SELECT
        a.cd_atendimento,
        a.cd_paciente,
        a.dt_atendimento,
        a.ordem
    FROM atendimentos_ordenados a
    INNER JOIN cte_selecao c
        ON a.cd_paciente = c.cd_paciente
       AND a.ordem > c.ordem
       AND a.dt_atendimento >= c.dt_atendimento + 7
       AND NOT EXISTS (
           -- Evitar pegar atendimentos dentro da mesma janela de 7 dias
           SELECT 1 FROM atendimentos_ordenados x
           WHERE x.cd_paciente = c.cd_paciente
             AND x.ordem > c.ordem
             AND x.ordem < a.ordem
             AND x.dt_atendimento >= c.dt_atendimento + 7
       )
)
-------------------------------------------------------------------------------
-- ONCOLOGIA
SELECT
	'NPS_ONCOLOGIA' AS TABELA,
    40066 AS ID_Cliente_Hfocus,
    atendime.cd_atendimento,
    TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base,
    paciente.cd_paciente,
    paciente.nm_paciente AS Nome_Completo_Paciente,
    paciente.email AS Email,
    paciente.tp_sexo AS Genero,
    Fn_Idade(paciente.dt_nascimento, 'a') AS Idade,
    TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento,
--    paciente.nr_fone AS Telefone_Residencial,
    paciente.nr_ddd_celular || paciente.nr_celular AS Telefone_Celular,
    paciente.nr_cpf AS CPF,
    'ONCOLOGIA' AS Area_Pesquisa,
    CASE 
        WHEN ori_ate.cd_multi_empresa = '2' THEN 'POSTO AVANÇADO BOA VIAGEM' 
        ELSE 'REAL HOSPITAL PORTUGUES' 
    END AS segmentacao_1,
    ori_ate.cd_multi_empresa,
    ori_ate.cd_ori_ate,
    ori_ate.ds_ori_ate AS segmentacao_2,
    convenio.nm_convenio AS segmentacao_3,
    NULL AS segmentacao_4,
    NULL AS segmentacao_5,
    NULL AS extra_info,
    especialid.ds_especialid,
    paciente.NM_BAIRRO,
    paciente.nr_cep,
    atendime.tp_atendimento,
    prestador.cd_prestador,
    prestador.nm_prestador,
    setor.cd_setor,
    setor.nm_setor,
    con_pla.cd_con_pla,
    con_pla.ds_con_pla,
    CASE 
        WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO

FROM 
    dbamv.atendime,
    dbamv.paciente,
    dbamv.ori_ate, 
    dbamv.convenio,
    dbamv.especialid, 
    dbamv.prestador, 
    dbamv.setor, 
    dbamv.con_pla
WHERE 
    atendime.cd_paciente = paciente.cd_paciente
    AND atendime.cd_ori_ate = ori_ate.cd_ori_ate
    AND atendime.cd_convenio = convenio.cd_convenio
    AND ori_ate.cd_setor = setor.cd_setor
    AND atendime.cd_convenio = con_pla.cd_convenio
    AND atendime.cd_con_pla = con_pla.cd_con_pla
    AND atendime.cd_prestador = prestador.cd_prestador(+)
    AND atendime.cd_especialid = especialid.cd_especialid(+)
    AND trunc(atendime.dt_atendimento) = (SELECT ontem FROM variaveis)
--    AND trunc(atendime.dt_atendimento) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')
    --AND atendime.cd_ori_ate IN (32, 56, 45, 196)
    AND ori_ate.cd_multi_empresa IN ('1', '2')
    AND atendime.CD_ATENDIMENTO_PAI IS NULL
--    AND atendime.dt_alta IS NOT NULL
    AND atendime.tp_atendimento NOT IN ('I')
    AND convenio.cd_convenio NOT IN (2, 1, 165) -- desconsiderar SUS
    AND paciente.tp_situacao <> 'O'
    AND atendime.cd_ori_ate IN (32, 56, 45, 196)
--ORDER BY 
--    Data_Base DESC
    
UNION 

-- INTERNACAO

SELECT 'NPS_INTERNACAO' AS TABELA
		,null AS ID_Cliente_Hfocus
  		,atendime.cd_atendimento                                                                                                                                    
        ,TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss') AS Data_Base                                                                                                  
        ,paciente.cd_paciente                                                                                                                                       
        ,paciente.nm_paciente Nome_Completo_Paciente                                                                                                                
        ,paciente.email Email                                                                                                                                       
        ,paciente.tp_sexo Genero                                                                                                                                    
        ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                                                
        ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                                                
        ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                                                         
                                          9 || paciente.nr_celular                                                                                                  
                                        ELSE                                                                                                                        
                                          paciente.nr_celular                                                                                                       
                                        END Telefone_Celular 
		,paciente.nr_cpf AS CPF
        ,case                                                                                                                                                       
          when atendime.cd_ori_ate in ('2','3','4','5','22','128','106','107','108','119') then 'INTERNACAO'                                                                      
          when atendime.cd_ori_ate in ('21','23','52') then 'EXAMES_LAB'                                                                                            
          when atendime.cd_ori_ate in ('14','24','53') then 'EXAMES_IMAGEM'                                                                                         
          when atendime.cd_ori_ate in ('31') then 'EXAMES_REAL_PATOLOGIA'                                                                                           
          when atendime.cd_ori_ate in ('163') then 'EXAMES_REAL_DOMICILIAR'                                                                                         
         end as Area_Pesquisa
        ,CASE 
	        WHEN ori_ate.cd_multi_empresa = '2' THEN 'POSTO AVANÇADO BOA VIAGEM' 
	        ELSE 'REAL HOSPITAL PORTUGUES' 
	    END AS segmentacao_1
	    ,ori_ate.cd_multi_empresa
	    ,ori_ate.cd_ori_ate                                                                                                                                    
        ,unid_int.ds_unid_int segmentacao_2                                                                                                                         
        ,convenio.nm_convenio AS segmentacao_3
        ,NULL AS segmentacao_4
    	,NULL AS segmentacao_5
	    ,NULL AS extra_info
        ,esp.ds_especialid
        ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,unid_int.cd_setor
      ,setor.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
    from dbamv.atendime, dbamv.paciente, dbamv.ori_ate, dbamv.convenio, dbamv.especialid  esp, dbamv.unid_int, dbamv.leito, dbamv.setor                                          
   where atendime.cd_paciente = paciente.cd_paciente                                                                                                                
     and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                                                   
     and atendime.cd_convenio = convenio.cd_convenio                                                                                                                
     AND unid_int.cd_unid_int =  leito.cd_unid_int 
     and setor.cd_setor = unid_int.cd_setor
     and leito.cd_leito =DBAMV.FNCDES_REP_LEITO_ATENDIMENTO(atendime.CD_ATENDIMENTO,dbamv.fnc_mv_recupera_data_hora(atendime.dt_alta, atendime.hr_alta))            
     and atendime.cd_especialid =  esp.cd_especialid(+)                                                                                                             
     /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br') and paciente.email not like ('nao%')  
								    and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30                                                       
     and TRUNC(atendime.dt_alta) = (SELECT ontem FROM variaveis)
--	AND trunc(atendime.dt_alta) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')                                                                               
     and atendime.tp_atendimento = 'I'                                                                                                                              
     and atendime.cd_ori_ate in (3, 2, 4, 5, 22, 128,106,107,108,119)                                                                                                            
     and ori_ate.cd_multi_empresa in (1,2)                                                                                                                          
     and atendime.dt_alta is not null                
     AND paciente.tp_situacao <> 'O'
     and unid_int.cd_unid_int not in (40,42)
     
--   order by Data_Base 
     
 UNION
 
-- NPS_LABORATORIO
  SELECT 'NPS_LABORATORIO' AS TABELA
  	   ,NULL AS ID_CLIENTE_HFOCUS
       ,atendime.cd_atendimento                                                                                                                                        
       ,TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base                                                                                                      
       ,paciente.cd_paciente                                                                                                                                           
       ,paciente.nm_paciente Nome_Completo_Paciente                                                                                                                    
       ,paciente.email Email                                                                                                                                           
       ,paciente.tp_sexo Genero                                                                                                                                        
       ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                                                    
       ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento
       ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                                                             
                                        9 || paciente.nr_celular                                                                                                       
                                      ELSE                                                                                                                             
                                        paciente.nr_celular                                                                                                            
                                      END Telefone_Celular
       ,paciente.nr_cpf AS CPF
       ,case                                                                                                                                                           
         when atendime.cd_ori_ate in ('2','3','4','5','22','128') then 'PRONTO_SOCORRO_GERAL'                                                                          
         when atendime.cd_ori_ate in ('21','23','52','31') then 'EXAMES_LAB'                                                                                           
         when atendime.cd_ori_ate in ('14','24','53') then 'EXAMES_IMAGEM'                                                                                             
         when atendime.cd_ori_ate in ('163') then 'EXAMES_REAL_DOMICILIAR'                                                                                             
        end as Area_Pesquisa                                                                                                                                           
       ,CASE 
	        WHEN ori_ate.cd_multi_empresa = '2' THEN 'POSTO AVANÇADO BOA VIAGEM' 
	        ELSE 'REAL HOSPITAL PORTUGUES' 
	    END AS segmentacao_1                                                                                                                                                
       ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                                                      
       ,ori_ate.cd_ori_ate                                                                                                                                             
       ,ori_ate.ds_ori_ate segmentacao_2                                                                                                                               
       ,convenio.nm_convenio segmentacao_3                                                                                                                                        
       ,NULL AS segmentacao_4                                                                                                                                               
       ,NULL AS segmentacao_5                                                                                                                                               
       ,NULL AS extra_info                                                                                                                                                  
       , esp.ds_especialid 
       ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,CASE WHEN atendime.cd_ori_ate = 163 THEN 'ERLAB - REAL LAB DOMICILIAR' ELSE setor.nm_setor END
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from atendime, paciente, ori_ate, convenio, dbamv.especialid  esp, setor                                                                                                     
  where atendime.cd_paciente = paciente.cd_paciente                                                                                                                    
	and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                                                       
	and atendime.cd_convenio = convenio.cd_convenio
	and ori_ate.cd_setor = setor.cd_setor
	AND ATENDIME.CD_ESPECIALID =  ESP.CD_ESPECIALID(+)                                                                                                                 
	/*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br') and paciente.email not like ('nao%')      
								   and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30                                                           
	and TRUNC(atendime.dt_atendimento) = (SELECT ontem FROM variaveis)    
--	AND trunc(atendime.dt_atendimento) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')
	and atendime.tp_atendimento = 'E'                                                                                                                                  
	and atendime.cd_ori_ate in (21, 23, 163)    /* 23 -	BOA VIAGEM REAL LAB || 163 - LAB - COLETA DOMICILIAR || 21 - REAL LAB */                                                                                          
	and ori_ate.cd_multi_empresa in (1,2)               
  AND paciente.tp_situacao <> 'O'
--  order by Data_Base       

UNION
 
-- NPS_EXAME_IMAGEM
  SELECT 'NPS_EXAME_IMAGEM' AS TABELA
  	   ,NULL AS ID_CLIENTE_HFOCUS
       ,atendime.cd_atendimento                                                                                                                                        
       ,TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base                                                                                                      
       ,paciente.cd_paciente                                                                                                                                           
       ,paciente.nm_paciente Nome_Completo_Paciente                                                                                                                    
       ,paciente.email Email                                                                                                                                           
       ,paciente.tp_sexo Genero                                                                                                                                        
       ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                                                    
       ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento
       ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                                                             
                                        9 || paciente.nr_celular                                                                                                       
                                      ELSE                                                                                                                             
                                        paciente.nr_celular                                                                                                            
                                      END Telefone_Celular
       ,paciente.nr_cpf AS CPF
       ,case                                                                                                                                                           
         when atendime.cd_ori_ate in ('2','3','4','5','22','128') then 'PRONTO_SOCORRO_GERAL'                                                                          
         when atendime.cd_ori_ate in ('21','23','52','31') then 'EXAMES_LAB'                                                                                           
         when atendime.cd_ori_ate in ('14','24','53') then 'EXAMES_IMAGEM'                                                                                             
         when atendime.cd_ori_ate in ('163') then 'EXAMES_REAL_DOMICILIAR'                                                                                             
        end as Area_Pesquisa                                                                                                                                           
       ,CASE 
	        WHEN ori_ate.cd_multi_empresa = '2' THEN 'POSTO AVANÇADO BOA VIAGEM' 
	        ELSE 'REAL HOSPITAL PORTUGUES' 
	    END AS segmentacao_1                                                                                                                                                
       ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                                                      
       ,ori_ate.cd_ori_ate                                                                                                                                             
       ,ori_ate.ds_ori_ate segmentacao_2                                                                                                                               
       ,convenio.nm_convenio segmentacao_3                                                                                                                                        
       ,NULL AS segmentacao_4                                                                                                                                               
       ,NULL AS segmentacao_5                                                                                                                                               
       ,NULL AS extra_info                                                                                                                                                  
       , esp.ds_especialid 
       ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,CASE WHEN atendime.cd_ori_ate = 163 THEN 'ERLAB - REAL LAB DOMICILIAR' ELSE setor.nm_setor END
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from atendime, paciente, ori_ate, convenio, dbamv.especialid  esp, setor                                                                                                     
  where atendime.cd_paciente = paciente.cd_paciente                                                                                                                    
	and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                                                       
	and atendime.cd_convenio = convenio.cd_convenio
	and ori_ate.cd_setor = setor.cd_setor
	AND ATENDIME.CD_ESPECIALID =  ESP.CD_ESPECIALID(+)                                                                                                                 
	/*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br') and paciente.email not like ('nao%')      
								   and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30                                                           
	and TRUNC(atendime.dt_atendimento) = (SELECT ontem FROM variaveis)    
--	AND trunc(atendime.dt_atendimento) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')
	and atendime.tp_atendimento = 'E'                                                                                                                                  
	and atendime.cd_ori_ate in (24, 31, 52, 53, 14, 227, 225, 226, 92, 94) /*14	- REAL IMAGEM RECEPÇAO || 24 - BOA VIAGEM REAL IMAGEM || 31	- REAL PATOLOGIA || 94	- EXAME MED NUCLEAR || 92	- MEDICINA NUCLEAR || 225 -	ESPACO MULHER RECEPCAO || 226	- REAL ENDOSCOPIA RECEPCAO || 227	- REAL IMAGEM RECEPÇÃO*/                                                                                          
	--and setor.CD_SETOR IN (163 ,164 ,167 ,168 ,169 ,170 ,171 ,173 ,174 ,175 ,178 ,179 ,180 ,977 )
  and ori_ate.cd_multi_empresa in (1,2)               
  AND paciente.tp_situacao <> 'O'
--  order by Data_Base       

UNION

-- NPS_MATERNIDADE_INTERNACAO
 select 'NPS_MATERNIDADE_INTERNACAO' AS TABELA
 		,NULL AS ID_CLIENTE_HFOCUS
 		,atendime.cd_atendimento                                                                                                                                  
        ,TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss') AS Data_Base                                                                                               
        ,PACIENTE.CD_PACIENTE 
        ,paciente.nm_paciente NOME_COMPLETO_PACIENTE
        ,paciente.email Email                                                                                                                                    
        ,paciente.tp_sexo Genero                                                                                                                                 
        ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                                             
        ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                                             
        ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                                                      
                                            9 || paciente.nr_celular                                                                                             
                                          ELSE                                                                                                                   
                                            paciente.nr_celular                                                                                                  
                                          END Telefone_Celular                                                                                                   
        ,paciente.NR_CPF AS CPF                              
        ,case when unid_int.cd_unid_int in ('40','42') then 'MATERNIDADE'                                                                                        
         else                                                                                                                                                    
          'INTERNACAO'                                                                                                                                           
         end as Area_Pesquisa                                                                                                                                    
        ,'REAL HOSPITAL PORTUGUES' segmentacao_1                                                                                                                 
        ,atendime.cd_multi_empresa
        ,ori_ate.cd_ori_ate
--        ,unid_int.cd_unid_int id_segmentacao_2                                                                                                                   
        ,unid_int.ds_unid_int segmentacao_2 
        ,convenio.nm_convenio AS segmentacao_3 
        ,NULL AS segmentacao_4                                                                                                                                               
        ,NULL AS segmentacao_5
        ,case when ori_ate.tp_origem = 'U' then 'EMERGENCIA'                                                                                                     
              when ori_ate.tp_origem = 'I' then 'INTERNACAO'                                                                                                     
              when ori_ate.tp_origem = 'E' then 'EXTERNO'                                                                                                        
              when ori_ate.tp_origem = 'A' then 'AMBULATORIAL'                                                                                                   
         end as extra_info                                                                                                                                       
        ,ESP.DS_ESPECIALID
        ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,unid_int.cd_setor
	    ,case when setor.nm_setor = 'ERMT 01º E 02º AND - APARTAMENTO'
      then unid_int.ds_unid_int else
      setor.nm_setor end
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from dbamv.atendime, dbamv.paciente, dbamv.leito, dbamv.unid_int, dbamv.ori_ate, dbamv.convenio,  dbamv.especialid  esp, setor                                        
  where atendime.cd_ori_ate = ori_ate.cd_ori_ate(+)                                                                                                              
    and atendime.cd_paciente = paciente.cd_paciente                                                                                                              
    and atendime.cd_convenio = convenio.cd_convenio 
    and setor.cd_setor = unid_int.cd_setor
    and atendime.tp_atendimento = 'I'                                                                                                                            
    and leito.cd_leito =DBAMV.FNCDES_REP_LEITO_ATENDIMENTO(atendime.CD_ATENDIMENTO,dbamv.fnc_mv_recupera_data_hora(atendime.dt_alta, atendime.hr_alta))          
    and unid_int.cd_unid_int = leito.cd_unid_int                                                                                                                 
    AND ATENDIME.CD_ESPECIALID =  ESP.CD_ESPECIALID(+)                                                                                                           
    /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br') and paciente.email not like ('nao%')
     							   and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30                                                     
    and TRUNC(atendime.dt_alta) = (SELECT ontem FROM variaveis)
--	AND trunc(atendime.DT_ALTA) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')                                                                            
    and atendime.cd_multi_empresa in (1)                                                                                                                         
    and atendime.cd_mot_alt not in ('41','42','43','63','64','65','66','67','73')                                                                                
    and atendime.sn_obito not in('S')                                                                                                                            
    and unid_int.cd_unid_int in ('40','42')
    and atendime.dt_alta is not null                     
    AND paciente.tp_situacao <> 'O'
--      order by AREA_PESQUISA , cd_paciente 

UNION 

-- NPS_PRONTO_ATENDIMENTO
 SELECT  'NPS_PRONTO_ATENDIMENTO' AS TABELA
 		,NULL AS ID_CLIENTE_HFOCUS
 		,atendime.cd_atendimento                                                                                                        
        ,TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base                                                                      
        ,paciente.cd_paciente                                                                                                           
        ,paciente.nm_paciente Nome_Completo_Paciente                                                    
        ,paciente.email Email                                                                                                           
        ,paciente.tp_sexo Genero                                                                                                        
        ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                    
        ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                    
        ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                             
                                          9 || paciente.nr_celular                                                                      
                                        ELSE                                                                                            
                                          paciente.nr_celular                                                                           
                                        END Telefone_Celular                                                                            
		,paciente.NR_CPF AS CPF
        ,case                                                                                                                           
          when atendime.cd_ori_ate in ('2','3','4','5','22','128') then 'PRONTO_SOCORRO_GERAL'                                          
          when atendime.cd_ori_ate in ('21','23','52','31') then 'EXAMES_LAB'                                                           
          when atendime.cd_ori_ate in ('14','24','53') then 'EXAMES_IMAGEM'                                                             
          when atendime.cd_ori_ate in ('163') then 'EXAMES_REAL_DOMICILIAR'                                                             
        end as Area_Pesquisa                                                                                                            
        ,case                                                                                                                           
          when ori_ate.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM'                                                          
        else                                                                                                                            
          'REAL HOSPITAL PORTUGUES'                                                                                                     
        end as segmentacao_1                                                                                                            
        ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                      
        ,ori_ate.cd_ori_ate                                                                                                             
        ,ori_ate.ds_ori_ate segmentacao_2                                                                                               
        ,convenio.nm_convenio segmentacao_3
        ,NULL AS segmentacao_4                                                                                                                                               
        ,NULL AS segmentacao_5
        , NULL AS extra_info
        ,esp.ds_especialid 
        ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,setor.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from dbamv.atendime, dbamv.paciente, dbamv.ori_ate, dbamv.convenio, dbamv.especialid  esp, setor                                            
  WHERE atendime.cd_paciente = paciente.cd_paciente                                                                                     
    and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                        
    and atendime.cd_convenio = convenio.cd_convenio
    and setor.cd_setor = ori_ate.cd_setor
    and atendime.cd_especialid =  esp.cd_especialid(+)                                                                                  
    /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br')            
                        and paciente.email not like ('nao%') and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30  
    and TRUNC(atendime.dt_atendimento) = (SELECT ontem FROM variaveis)  
--	AND trunc(atendime.dt_atendimento) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')                                        
    and atendime.tp_atendimento = 'U'                                                                                                   
    and atendime.cd_ori_ate in (2, 4, 5, 22)                                                                                
    and ori_ate.cd_multi_empresa in (1,2)                
    AND paciente.tp_situacao <> 'O'
--  order by Data_Base  

UNION

--NPS_NOSSA_CLINICA
 select 'NPS_NOSSA_CLINICA' AS TABELA
 		,NULL AS ID_CLIENTE_HFOCUS
 		,atendime.cd_atendimento                                                                                                        
       ,TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base                                                                      
       ,paciente.cd_paciente                                                                                                           
       ,paciente.nm_paciente Nome_Completo_Paciente                                                                                    
       ,paciente.email Email                                                                                                           
       ,paciente.tp_sexo Genero                                                                                                        
       ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                    
       ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                    
       ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                             
                                         9 || paciente.nr_celular                                                                      
                                       ELSE                                                                                            
                                         paciente.nr_celular                                                                           
                                       END Telefone_Celular
       ,PACIENTE.NR_CPF AS CPF
       ,'AMBULATORIO_COLABORADOR' as Area_Pesquisa                                                                                     
       ,case when ori_ate.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM' else 'REAL HOSPITAL PORTUGUES' end as segmentacao_1  
       ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                      
       ,ori_ate.cd_ori_ate                                                                                                             
       ,ori_ate.ds_ori_ate segmentacao_2                                                                                               
       ,convenio.nm_convenio segmentacao_3
        ,NULL AS segmentacao_4                                                                                                                                               
        ,NULL AS segmentacao_5
        , NULL AS extra_info
       ,esp.ds_especialid
       ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,setor.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from dbamv.atendime, dbamv.paciente, dbamv.ori_ate, dbamv.convenio, dbamv.especialid  esp, setor                                            
  where atendime.cd_paciente = paciente.cd_paciente                                                                                    
    and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                       
    and atendime.cd_convenio = convenio.cd_convenio
    and ori_ate.cd_setor = setor.cd_setor
    and atendime.cd_especialid =  esp.cd_especialid(+)                                                                                 
    /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br')           
                        and paciente.email not like ('nao%') and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30 
    and TRUNC(atendime.dt_atendimento) =  (SELECT ontem FROM variaveis)     
--AND trunc(atendime.dt_atendimento) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')                                       
    and atendime.cd_ori_ate in (181)                                                                                                   
    and ori_ate.cd_multi_empresa in ('1','2')                                                                                          
    and CD_ATENDIMENTO_PAI is null
    AND paciente.tp_situacao <> 'O'
    
UNION

--NPS_REAL_VACINA
 select 'NPS_REAL_VACINA' AS TABELA
 		,NULL AS ID_CLIENTE_HFOCUS
 		,atendime.cd_atendimento                                                                                                        
       ,TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base                                                                      
       ,paciente.cd_paciente                                                                                                           
       ,paciente.nm_paciente Nome_Completo_Paciente                                                                                    
       ,paciente.email Email                                                                                                           
       ,paciente.tp_sexo Genero                                                                                                        
       ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                    
       ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                    
       ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                             
                                         9 || paciente.nr_celular                                                                      
                                       ELSE                                                                                            
                                         paciente.nr_celular                                                                           
                                       END Telefone_Celular
       ,PACIENTE.NR_CPF AS CPF
       ,'REAL VACINA' as Area_Pesquisa                                                                                     
       ,case when ori_ate.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM' else 'REAL HOSPITAL PORTUGUES' end as segmentacao_1  
       ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                      
       ,ori_ate.cd_ori_ate                                                                                                             
       ,ori_ate.ds_ori_ate segmentacao_2                                                                                               
       ,convenio.nm_convenio segmentacao_3
        ,NULL AS segmentacao_4                                                                                                                                               
        ,NULL AS segmentacao_5
        , NULL AS extra_info
       ,esp.ds_especialid
       ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,setor.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from dbamv.atendime, dbamv.paciente, dbamv.ori_ate, dbamv.convenio, dbamv.especialid  esp, setor                                            
  where atendime.cd_paciente = paciente.cd_paciente                                                                                    
    and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                       
    and atendime.cd_convenio = convenio.cd_convenio
    and ori_ate.cd_setor = setor.cd_setor
    and atendime.cd_especialid =  esp.cd_especialid(+)                                                                                 
    /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br')           
                        and paciente.email not like ('nao%') and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%')*/ --COMENTADO POR 26521 EM 20/06/25 13:30 
    and TRUNC(atendime.dt_atendimento) =  (SELECT ontem FROM variaveis)     
--AND trunc(atendime.dt_atendimento) BETWEEN TO_DATE('01/02/2025', 'dd/mm/rrrr') AND TO_DATE('02/02/2025', 'DD/MM/RRRR')                                       
    and atendime.cd_ori_ate in (185,216,236)                                                                                                   
    and ori_ate.cd_multi_empresa in ('1','2')                                                                                          
    and CD_ATENDIMENTO_PAI is null
    AND paciente.tp_situacao <> 'O'
    
UNION

--NPS_HEMODIALISE_CONV
  SELECT 
  'NPS_HEMODIALISE_CONV' AS TABELA
  ,NULL AS ID_CLIENTE_HFOCUS
  ,cte_selecao.cd_atendimento
  ,TO_CHAR(ATE.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(ATE.hr_atendimento, 'hh24:mi:ss') AS Data_Base
  ,cte_selecao.cd_paciente
  ,PAC.nm_paciente                   AS Nome_Completo_Paciente                                                    
  ,PAC.email                         AS Email                                                                                                           
  ,PAC.tp_sexo                       AS Genero  
  ,Fn_Idade(PAC.dt_nascimento, 'a')  AS Idade  
  ,TO_CHAR(PAC.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento
  ,'55' || PAC.nr_ddd_celular || CASE
      WHEN Length(PAC.nr_celular) = 8 THEN 9 || PAC.nr_celular
      ELSE PAC.nr_celular
  END Telefone_Celular
  ,
  PAC.NR_CPF AS CPF,
  'HEMODIALISE CONV' as Area_Pesquisa,
  case
      when OA.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM'
      else 'REAL HOSPITAL PORTUGUES'
  end as segmentacao_1
  ,OA.cd_multi_empresa cd_multi_empresa                                                                                      
  ,OA.cd_ori_ate                                                                                                             
  ,OA.ds_ori_ate segmentacao_2                                                                                            
  ,CONV.nm_convenio segmentacao_3
  ,NULL AS segmentacao_4                                                                                                                                               
  ,NULL AS segmentacao_5
  ,NULL AS extra_info
  ,esp.ds_especialid       
  ,PAC.NM_BAIRRO
  ,PAC.nr_cep
  ,ATE.tp_atendimento
  ,NULL AS cd_prestador
  ,NULL AS nm_prestador
  ,OA.cd_setor
  ,st.nm_setor
  ,NULL AS cd_con_pla
  ,NULL AS ds_con_pla
  ,CASE 
      WHEN TO_CHAR(ATE.hr_alta, 'hh24:mi') <> '23:59' AND ATE.hr_alta IS NOT NULL THEN
          ROUND((TO_DATE(TO_CHAR(ATE.dt_alta, 'dd/mm/yyyy') || TO_CHAR(ATE.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
          TO_DATE(TO_CHAR(ATE.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(ATE.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
      ELSE NULL 
  END AS tempo_permanencia
  ,NULL AS telefone_residencial
  ,NULL AS dt_integracao
  ,CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = ate.CD_PACIENTE AND A.DT_ATENDIMENTO < ate.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
  ATE.NM_USUARIO
  
  FROM cte_selecao
  LEFT JOIN ATENDIME ATE ON ATE.CD_ATENDIMENTO = cte_selecao.CD_ATENDIMENTO
  LEFT JOIN PACIENTE PAC ON PAC.CD_PACIENTE = cte_selecao.CD_PACIENTE
  LEFT JOIN DBAMV.ORI_ATE OA ON OA.CD_ORI_ATE = ATE.CD_ORI_ATE
  LEFT JOIN DBAMV.SETOR ST ON ST.CD_SETOR = OA.CD_SETOR
  LEFT JOIN DBAMV.CONVENIO CONV ON CONV.CD_CONVENIO = ATE.CD_CONVENIO
  LEFT JOIN DBAMV.ESPECIALID ESP ON ESP.CD_ESPECIALID = ATE.CD_ESPECIALID
  
  WHERE TRUNC(ATE.dt_atendimento) = (SELECT ontem FROM variaveis)
    
UNION 

--NPS_LCC
 select 'NPS_LCC' AS TABELA
 		,NULL AS ID_CLIENTE_HFOCUS
    ,to_number(P.CD_ATENDIMENTO || to_char(DH_FECHAMENTO, 'yyyymmdd')) CD_ATENDIMENTO -- Particularidade para os casos de LCC: CD_ATENDIMENTO + DH_FECHAMENTO
    ,TO_CHAR(DH_FECHAMENTO, 'dd/mm/yyyy') || ' ' || TO_CHAR(DH_FECHAMENTO, 'hh24:mi:ss') AS Data_Base
    ,P.CD_PACIENTE
    ,PA.nm_paciente Nome_Completo_Paciente 
    ,PA.email Email                                                                                                           
       ,PA.tp_sexo Genero                                                                                                        
       ,Fn_Idade(PA.dt_nascimento, 'a') Idade                                                                                    
       ,TO_CHAR(PA.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                    
       ,'55' || PA.nr_ddd_celular || CASE WHEN  Length(PA.nr_celular) = 8 THEN                                             
                                         9 || PA.nr_celular                                                                      
                                       ELSE                                                                                            
                                         PA.nr_celular                                                                           
                                       END Telefone_Celular
       ,PA.NR_CPF AS CPF
       ,'LINHA CUIDADO CARDIO' as Area_Pesquisa                                                                                     
       ,case when ori_ate.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM' else 'REAL HOSPITAL PORTUGUES' end as segmentacao_1  
       ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                      
       ,ori_ate.cd_ori_ate                                                                                                             
       ,ori_ate.ds_ori_ate segmentacao_2                                                                                               
       ,CONV.nm_convenio segmentacao_3
        ,NULL AS segmentacao_4                                                                                                                                               
        ,NULL AS segmentacao_5
        , NULL AS extra_info
       ,esp.ds_especialid
       ,PA.NM_BAIRRO
	     ,PA.nr_cep
	    ,A.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,S.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(A.hr_alta, 'hh24:mi') <> '23:59' AND A.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(A.dt_alta, 'dd/mm/yyyy') || TO_CHAR(A.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(A.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(A.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME AT WHERE AT.CD_PACIENTE = A.CD_PACIENTE AND AT.DT_ATENDIMENTO < A.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    A.NM_USUARIO
    
    
    
--    ,TO_CHAR(A.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(A.hr_atendimento, 'hh24:mi:ss') AS DT_ATENDIMENTO
--    ,TO_CHAR(A.DT_ALTA, 'dd/mm/yyyy') || ' ' || TO_CHAR(A.HR_ALTA, 'hh24:mi:ss') AS DT_ALTA
--    ,P.CD_DOCUMENTO_CLINICO
--    ,E.CD_DOCUMENTO
--    ,O.CD_OBJETO
--    ,P.NM_DOCUMENTO
--    ,P.DH_DOCUMENTO
--    ,DH_FECHAMENTO
 
FROM  PW_DOCUMENTO_CLINICO P
     ,PAGU_OBJETO          O
     ,PW_EDITOR_CLINICO    E
     ,ATENDIME             A
     ,PACIENTE             PA
     ,ESPECIALID           ESP
     ,CONVENIO             CONV
     ,ORI_ATE
     ,SETOR                S
     ,UNID_INT             UI
     ,LEITO
 
WHERE P.CD_OBJETO = O.CD_OBJETO
AND   P.CD_DOCUMENTO_CLINICO =  E.CD_DOCUMENTO_CLINICO
AND A.CD_ATENDIMENTO = P.CD_ATENDIMENTO
AND A.CD_PACIENTE = PA.CD_PACIENTE
--AND   P.CD_ATENDIMENTO IN ( 6215651)
AND   E.CD_DOCUMENTO IN (1513)
and A.cd_especialid =  esp.cd_especialid(+)
and A.cd_convenio = CONV.cd_convenio
AND ORI_ATE.CD_ORI_ATE = A.CD_ORI_ATE
AND S.CD_SETOR = UI.CD_SETOR
AND P.TP_STATUS = 'FECHADO'
AND leito.cd_leito =DBAMV.FNCDES_REP_LEITO_ATENDIMENTO(A.CD_ATENDIMENTO,dbamv.fnc_mv_recupera_data_hora(A.dt_alta, A.hr_alta)) 
and UI.cd_unid_int = leito.cd_unid_int 
and S.cd_setor = UI.cd_setor
and TRUNC(DH_FECHAMENTO) =  (SELECT ontem FROM variaveis)     
--AND trunc(DH_FECHAMENTO) BETWEEN TRUNC (SYSDATE-30) AND TRUNC (SYSDATE)

UNION

--DAY CLINIC INTERNACAO
SELECT 'NPS_INT_DAY_CLINIC' AS TABELA
		,null AS ID_Cliente_Hfocus
  		,atendime.cd_atendimento                                                                                                                                    
        ,TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss') AS Data_Base                                                                                                  
        ,paciente.cd_paciente                                                                                                                                       
        ,paciente.nm_paciente Nome_Completo_Paciente                                                                                                                
        ,paciente.email Email                                                                                                                                       
        ,paciente.tp_sexo Genero                                                                                                                                    
        ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                                                
        ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                                                
        ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                                                         
                                          9 || paciente.nr_celular                                                                                                  
                                        ELSE                                                                                                                        
                                          paciente.nr_celular                                                                                                       
                                        END Telefone_Celular 
		,paciente.nr_cpf AS CPF
        ,'INTERNACAO_DAY_CLINIC' AS Area_Pesquisa
        ,CASE 
	        WHEN ori_ate.cd_multi_empresa = '2' THEN 'POSTO AVANÇADO BOA VIAGEM' 
	        ELSE 'REAL HOSPITAL PORTUGUES' 
	    END AS segmentacao_1
	    ,ori_ate.cd_multi_empresa
	    ,ori_ate.cd_ori_ate                                                                                                                                    
        ,unid_int.ds_unid_int segmentacao_2                                                                                                                         
        ,convenio.nm_convenio AS segmentacao_3
        ,NULL AS segmentacao_4
    	,NULL AS segmentacao_5
	    ,NULL AS extra_info
        ,esp.ds_especialid
        ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,unid_int.cd_setor
      ,setor.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
    from dbamv.atendime, dbamv.paciente, dbamv.ori_ate, dbamv.convenio, dbamv.especialid  esp, dbamv.unid_int, dbamv.leito, dbamv.setor                                          
   where atendime.cd_paciente = paciente.cd_paciente                                                                                                                
     and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                                                   
     and atendime.cd_convenio = convenio.cd_convenio                                                                                                                
     AND unid_int.cd_unid_int =  leito.cd_unid_int 
     and setor.cd_setor = unid_int.cd_setor
     and leito.cd_leito =DBAMV.FNCDES_REP_LEITO_ATENDIMENTO(atendime.CD_ATENDIMENTO,dbamv.fnc_mv_recupera_data_hora(atendime.dt_alta, atendime.hr_alta))            
     and atendime.cd_especialid =  esp.cd_especialid(+)                                                                                                             
     /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br') and paciente.email not like ('nao%')  
								    and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%') */                                                      
     and TRUNC(atendime.dt_alta) = (SELECT ontem FROM variaveis)
--     and trunc(atendime.dt_alta) BETWEEN TO_DATE('01/07/2025', 'dd/mm/rrrr') AND TO_DATE('29/07/2025', 'DD/MM/RRRR')                                                                               
     and atendime.tp_atendimento = 'I'                                                                                                                              
     and atendime.cd_ori_ate in (121,159) 
     and ori_ate.cd_multi_empresa in (1,2)                                                                                                                          
     and atendime.dt_alta is not null                
     and paciente.tp_situacao NOT IN ('O')

UNION 

--AMB_DAY_CLINIC
 select 'NPS_AMB_DAY_CLINIC' AS TABELA
 		,NULL AS ID_CLIENTE_HFOCUS
 		,atendime.cd_atendimento                                                                                                        
       ,TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss') AS Data_Base                                                                      
       ,paciente.cd_paciente                                                                                                           
       ,paciente.nm_paciente Nome_Completo_Paciente                                                                                    
       ,paciente.email Email                                                                                                           
       ,paciente.tp_sexo Genero                                                                                                        
       ,Fn_Idade(paciente.dt_nascimento, 'a') Idade                                                                                    
       ,TO_CHAR(paciente.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento                                                                    
       ,'55' || paciente.nr_ddd_celular || CASE WHEN  Length(paciente.nr_celular) = 8 THEN                                             
                                         9 || paciente.nr_celular                                                                      
                                       ELSE                                                                                            
                                         paciente.nr_celular                                                                           
                                       END Telefone_Celular
       ,PACIENTE.NR_CPF AS CPF
       ,'AMBULATORIO_DAY_CLINIC' as Area_Pesquisa                                                                                     
       ,case when ori_ate.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM' else 'REAL HOSPITAL PORTUGUES' end as segmentacao_1  
       ,ori_ate.cd_multi_empresa cd_multi_empresa                                                                                      
       ,ori_ate.cd_ori_ate                                                                                                             
       ,ori_ate.ds_ori_ate segmentacao_2                                                                                               
       ,convenio.nm_convenio segmentacao_3
        ,NULL AS segmentacao_4                                                                                                                                               
        ,NULL AS segmentacao_5
        , NULL AS extra_info
       ,esp.ds_especialid
       ,paciente.NM_BAIRRO
	    ,paciente.nr_cep
	    ,atendime.tp_atendimento
	    ,NULL AS cd_prestador
	    ,NULL AS nm_prestador
	    ,ori_ate.cd_setor
	    ,setor.nm_setor
	    ,NULL AS cd_con_pla
	    ,NULL AS ds_con_pla
	    ,CASE 
    	WHEN TO_CHAR(atendime.hr_alta, 'hh24:mi') <> '23:59' AND atendime.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(atendime.dt_alta, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(atendime.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(atendime.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno,
    atendime.NM_USUARIO
   from dbamv.atendime, dbamv.paciente, dbamv.ori_ate, dbamv.convenio, dbamv.especialid  esp, setor                                            
  where atendime.cd_paciente = paciente.cd_paciente                                                                                    
    and atendime.cd_ori_ate = ori_ate.cd_ori_ate                                                                                       
    and atendime.cd_convenio = convenio.cd_convenio
    and ori_ate.cd_setor = setor.cd_setor
    and atendime.cd_especialid =  esp.cd_especialid(+)                                                                                 
    /*and (paciente.email like '%@%' and paciente.email not in('nao@tem.email') and paciente.email not in('naotem@rhp.com.br')           
                        and paciente.email not like ('nao%') and paciente.email not like 'rhp@%'and paciente.email not like 'notem@%') */
    and TRUNC(atendime.dt_atendimento) =  (SELECT ontem FROM variaveis)     
--    and trunc(atendime.dt_alta) BETWEEN TO_DATE('01/07/2025', 'dd/mm/rrrr') AND TO_DATE('29/07/2025', 'DD/MM/RRRR')                                  
    and atendime.cd_ori_ate in (121,159)   
    and atendime.tp_atendimento NOT IN ('I')
    and ori_ate.cd_multi_empresa in ('1','2')                                                                                          
    and CD_ATENDIMENTO_PAI is null
    AND paciente.tp_situacao NOT IN ('O')
    
UNION 

--NPS_UTIS
select  
        'NPS_UTIS' AS TABELA, 
        null AS ID_Cliente_Hfocus,
        base.cd_atendimento,
        TO_CHAR(base.dt_atendimento, 'dd/mm/yyyy') || ' ' || TO_CHAR(base.hr_atendimento, 'hh24:mi:ss') AS Data_Base,
        base.cd_paciente,
        p.nm_paciente Nome_Completo_Paciente,
        p.email email,
        p.tp_sexo genero,
        Fn_Idade(p.dt_nascimento, 'a') Idade, 
        TO_CHAR(p.dt_nascimento, 'YYYY-MM-DD') AS dt_nascimento,      
        '55' || p.nr_ddd_celular || CASE WHEN  Length(p.nr_celular) = 8 THEN                                             
                                          9 || p.nr_celular                                                                      
                                        ELSE                                                                                            
                                          p.nr_celular                                                                           
                                        END Telefone_Celular ,
                                        p.nr_cpf AS CPF,
        'SAIDA_UTI' Area_Pesquisa,
         case                                                                                                                           
          when base.cd_multi_empresa = '2' then 'POSTO AVANÇADO BOA VIAGEM'                                                          
         else                                                                                                                            
          'REAL HOSPITAL PORTUGUES'                                                                                                     
         end as segmentacao_1,  
         ori_ate.cd_multi_empresa cd_multi_empresa,                                                                                      
         ori_ate.cd_ori_ate,                                                                                                             
         ori_ate.ds_ori_ate segmentacao_2,
         convenio.nm_convenio AS segmentacao_3,
         NULL AS segmentacao_4,
    	   NULL AS segmentacao_5,
         NULL AS extra_info,
         esp.ds_especialid,
         p.NM_BAIRRO,
         p.nr_cep,
	       base.tp_atendimento,
	       NULL AS cd_prestador,
         NULL AS nm_prestador,
	       ui.cd_unid_int,
         ui.ds_unid_int,
         NULL AS cd_con_pla,
	       NULL AS ds_con_pla,
         CASE 
    	WHEN TO_CHAR(base.hr_alta, 'hh24:mi') <> '23:59' AND base.hr_alta IS NOT NULL THEN
            ROUND((TO_DATE(TO_CHAR(base.dt_alta, 'dd/mm/yyyy') || TO_CHAR(base.hr_alta, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') - 
            TO_DATE(TO_CHAR(base.dt_atendimento, 'dd/mm/yyyy') || TO_CHAR(base.hr_atendimento, 'hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) * 24 * 60)
        ELSE NULL 
    	END AS tempo_permanencia,
    NULL AS telefone_residencial,
    NULL AS dt_integracao,
    --CASE WHEN(SELECT MAX (DT_ATENDIMENTO) FROM ATENDIME A WHERE A.CD_PACIENTE = atendime.CD_PACIENTE AND A.DT_ATENDIMENTO < atendime.DT_ATENDIMENTO) IS NOT NULL THEN 'RETORNO' ELSE 'PRIMEIRA_VISITA' END retorno
      NULL RETORNO,
      NULL NM_USUARIO
          
  from dbamv.mov_int mi, dbamv.leito le, dbamv.tip_acom ta, dbamv.paciente p, dbamv.ori_Ate, dbamv.especialid  esp, dbamv.convenio, dbamv.unid_int ui, 
	   (
	   	   select a.cd_atendimento, a.cd_paciente, a.dt_atendimento, a.hr_atendimento, a.cd_multi_empresa, a.cd_ori_ate, a.cd_especialid, a.cd_convenio, a.tp_atendimento, l.cd_unid_int, st.cd_setor, st.nm_setor, u.ds_unid_int, a.hr_alta, a.dt_alta,
	   (
	   select max(m.cd_mov_int) from dbamv.mov_int m
	   where m.cd_atendimento = a.cd_atendimento
	   and m.tp_mov = 'O'
	   ) cd_mov_int,
     (select max(mov.cd_mov_int) from dbamv.mov_int mov, dbamv.leito le, dbamv.tip_acom ta where mov.cd_atendimento = a.cd_atendimento and mov.cd_leito = le.cd_leito and le.cd_tip_acom = ta.cd_tip_acom and ta.tp_acomodacao in ('U') and mov.tp_mov = 'O' ) mov_int_saida_uti
	   from dbamv.atendime a, dbamv.leito l, dbamv.unid_int u, dbamv.tip_acom t, setor st
	   where a.cd_leito = l.cd_leito
	     and l.cd_unid_int = u.cd_unid_int
	     and l.cd_tip_acom = t.cd_tip_acom
	     and a.tp_atendimento = 'I'
	     and a.dt_alta is null
       --and trunc(a.dt_alta) = trunc(sysdate)
       and st.cd_setor = u.cd_setor
	     and t.tp_acomodacao not in ('U')
	     --and u.cd_unid_int in (4,6,8,9,14,20,75,48,89,59,60,90)
	     and trunc(a.dt_atendimento) < trunc(sysdate)
       --and a.cd_atendimento = 5582009
	     ) base
where base.mov_int_saida_uti = mi.cd_mov_int
  and mi.cd_leito = le.cd_leito
  and le.cd_tip_acom = ta.cd_tip_acom
  and le.cd_unid_int = ui.cd_unid_int
  AND base.cd_paciente = p.cd_paciente
  and base.cd_ori_ate = ori_ate.cd_ori_ate
  and base.cd_especialid =  esp.cd_especialid(+)  
  and base.cd_convenio = convenio.cd_convenio
  and ori_ate.cd_multi_empresa in (1,2)
  and ta.tp_acomodacao in ('U')
  and TRUNC(mi.dt_lib_mov) =  (SELECT ontem FROM variaveis)     
  --and base.cd_atendimento = 5582009