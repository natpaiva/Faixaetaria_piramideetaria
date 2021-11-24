# Idade, faixa etária e pirâmide etária - SIM
Natalia Paiva IESC UFRJ

Trabalhando com a variável Idade no Sistema de Informação sobre Mortalidade; Criando faixa etária e Pirâmide etária usando pacote ggplot2

Exemplo: Opendatasus - Sistema de Informação sobre Mortalidade – SIM; 

Base de Registros de 2019 - Mortalidade geral
Disponivel em: https://opendatasus.saude.gov.br/dataset/sistema-de-informacao-sobre-mortalidade

Importando microdados do SIM diretamente da URL;
Filtrando e selecionando variáveis usando pacote dplyr
Trabalhando com variável Idade 

Idade: composto de dois subcampos. O primeiro, de 1 dígito, indica a unidade da idade, conforme a tabela a seguir. O segundo, de dois dígitos, indica a quantidade de unidades: 
-  0 – Idade menor de 1 hora, o subcampo varia de 01 e 59; 
- 1 – Hora, o subcampo varia de 01 a 23; 
- 2 – Dias, o subcampo varia de 01 a 29; 
- 3 – Meses, o subcampo varia de 01 a 11; 
- 4 – Anos, o subcampo varia de 00 a 99;
- 5 – Anos (mais de 100 anos), o segundo subcampo varia de 0 a 99. 

Criando faixa etária
Pirâmide etária usando pacote ggplot2
