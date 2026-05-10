# Governança e Monitoramento Estratégico de Projetos de TI

## Objetivo
Desenvolvimento de uma arquitetura automatizada cruzando dados de gestão de tarefas (Asana) com controles internos (MS Lists), culminando em um painel interativo com auditoria em tempo real.

## Problema de Negócio
gestão de projetos tecnológicos sofria com a falta de visibilidade em tempo real sobre o avanço das tarefas, dificultando a identificação de gargalos de tempo e exigindo auditorias manuais demoradas.

## Solução Proposta
Criação de dashboards e indicadores estratégicos com Power BI, MS List e API ASANA para acompanhamento da operações dos projetos internos.

## Indicadores Monitorados
- MAP - Controle dos Projetos
  - Qtde. Task No Prazo por Analista
  - Qtde. Task No Prazo por Projeto
  - Qtde. Tasks Previstas e Fechadas na Mesma Competência
  - Qtde. Task No Prazo por Analista
  - 
- MAP - Projects Timeline
  - Projeção Projetos a partir da reunião kick-off
  - Projeção Finalização dos Projetos
- MAP - Project Tracker
  - Status Report da ultima atualização do Projeto
  - Volume de projetos por gerente e seus respectivos status
  - Distribuição gráfica dos projetos por meses de acordo com o grau de atividades
- OnePage Executivo
  - Titulo Projeto
  - Status
  - Progresso de taks (Em Barra)
  - Gerente Projeto
  - Data da realização da ultima atualização do status (Asana)
  - Resumo do Projeto
  - Descritivo do Ultimo Status
  - Matriz de taks pendentes de execução e seus respectivos prazos
- MAP - Governança e Padronização de Projetos
  - Riscos com resolução dentro do prazo
  - Metodologia TAP
  - Metodologia DEP
  - Metodologia Cronograma
- MAP - Matriz Risco PMO Tech
  - Qtde. Tasks Previstas e Fechadas na Mesma Competência
  - Acompanhamento de Riscos Identificados por Analista Auditor
  - Big Number
    - Resolução no Prazo
    - Resolução Fora do Prazo
    - Resposta ao Risco
    - Probabilidade
    - Impacto

## Ferramentas Utilizadas

- MS List
- Linguagem M (Power Query)
- Power BI
- API Asana
- GitHub

## Estrutura do Projeto

- `data/`: bases de dados
- `docs/`: documentação executiva
- `PoqerQuery/`: scripts Power Query
- `powerbi/`: dashboards
- `images/`: imagens do dashboard

## Principais Insights

- Identificação de projetos com maior risco.
- Correlação entre atrasos e aumento de retrabalho.
- Priorização de iniciativas críticas.

## Dashboard

![Dashboard](images/dashboard_geral.png)

## Resultados Obtidos

- Maior visibilidade executiva.
- Redução do tempo de consolidação manual.
- Apoio à tomada de decisão.

## Autor
> Massáro Júnio
> www.linkedin.com/in/massáro-júnio-1025a082
> massarojunio@gmail.com 
