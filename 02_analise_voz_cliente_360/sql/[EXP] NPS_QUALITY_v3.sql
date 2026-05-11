with base_quality as (
   select 'Enfermagem' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do atendimento da equipe de enfermagem hoje?'
   union all
   select 'Equipe Médica' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'Masc',
                'F',
                'Fem',
                tp_sexo
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do atendimento da equipe médica hoje?'
   union all
   select 'Concierges' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do atendimento da nossa equipe de concierges de hospitalidade?'
   union all
   select 'Higienização' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do nosso serviço de higienização hoje?'
   union all
   select 'Lavanderia' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do nosso serviço de lavanderia/enxoval hoje?'
   union all
   select 'Transporte' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do nosso serviço de transporte/remoção hoje?'
   union all
   select 'Nutrição' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade do nosso serviço de nutrição hoje?'
   union all
   select 'Exames' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade dos exames realizados hoje?'
   union all
   select 'Acomodações' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a qualidade de nossas acomodações hoje?'
   union all
   select 'Hig. Mãos' as pesquisa,
          nps.id,
          nps.status,
          nps.cd_paciente,
          (
             select regexp_replace(
                nm_paciente,
                '\s([A-Za-z])[A-Za-z]+',
                ' \1.'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as nm_paciente_abrev,
          (
             select case
                when extract(year from sysdate) - extract(year from dt_nascimento) < 18 then
                   '0 - 17 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 17
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 31 then
                   '18 - 30 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 30
                   and extract(year from sysdate) - extract(year from dt_nascimento) < 61 then
                   '31 - 60 Anos'
                when extract(year from sysdate) - extract(year from dt_nascimento) > 61 then
                   '60+ Anos'
                    end
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as idade,
          (
             select decode(
                tp_sexo,
                'M',
                'MASC',
                'F',
                'FEM'
             )
               from dbamv.paciente
              where cd_paciente = nps.cd_paciente
          ) as genero,
          nps.cd_atendimento,
          (
             select dt_atendimento
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_atendimento,
          (
             select dt_alta
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as dt_alta,
          (
             select case
                when dt_alta is null then
                   'Internado'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 3 then
                   '0 - 2 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 2
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 6 then
                   '3 - 5 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 5
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento < 9 then
                   '6 - 8 Dias'
                when dt_alta is not null
                   and nvl(
                   dt_alta,
                   trunc(sysdate)
                ) - dt_atendimento > 9 then
                   '9+ Dias'
                    end
               from dbamv.atendime
              where cd_atendimento = nps.cd_atendimento
          ) as tmp_perman_dias,
          case
             when (
                select ds_unid_int
                  from dbamv.unid_int ui,
                       dbamv.leito lei,
                       dbamv.atendime ate
                 where ui.cd_unid_int = lei.cd_unid_int
                   and lei.cd_leito = ate.cd_leito
                   and cd_atendimento = nps.cd_atendimento
             ) is not null then
                (
                   select ds_unid_int
                     from dbamv.unid_int ui,
                          dbamv.leito lei,
                          dbamv.atendime ate
                    where ui.cd_unid_int = lei.cd_unid_int
                      and lei.cd_leito = ate.cd_leito
                      and cd_atendimento = nps.cd_atendimento
                )
             else
                (
                   select nm_setor
                     from dbamv.setor st,
                          dbamv.ori_ate oa,
                          dbamv.atendime ate
                    where st.cd_setor = oa.cd_setor
                      and oa.cd_ori_ate = ate.cd_ori_ate
                      and cd_atendimento = nps.cd_atendimento
                )
          end as ds_local,
          nps.dh_resposta,
          nps.dh_integracao,
          resp.vl_resposta
  --, resp.DS_QUESTIONARIO
          ,
          resp.ds_comentario,
          resp.ds_melhoria,
          (
             select count(cd_quality_resposta_nps) + ( 10 - count(cd_quality_resposta_nps) )
               from rhpleitura.des_quality_nps resp2
              where resp2.id = nps.id
          ) nr_quest_disparado
     from rhpleitura.des_quality_nps nps
     left join rhpleitura.des_quality_resposta_nps resp
   on resp.id = nps.id
    where ds_questionario = 'Como você avalia a frequência da higienização das mãos dos profissionais de saúde antes de realizarem os cuidados?'
)
select *
  from base_quality