###################################################
###  Sistema de Informação sobre Mortalidade – SIM   
###  TRABALHANDO COM A IDADE
###  CRIANDO FAIXA ETÁRIA               
###  PIRAMIDE ETARIA USANDO GGPLOT2     
###  NATALIA PAIVA - IESC UFRJ          
###################################################


library(rio) #importar bases de dados de varias extensoes: dta, csv, xlsx...
library(dplyr) #manipular dados; usar %>%
library(ggplot2) #graficos
library(stringr) # mexer com strings

# exemplo: Opendatasus - Sistema de Informação sobre Mortalidade – SIM; 
# Base de Registros de 2019 - Mortalidade geral
# Os registros são oriundos do sistema SIM, contendo dados socioeconômicos, local de residência e ocorrência, óbitos fetais e não fetais, condições e causas do óbito, e informações de causas externas.
# disponivel em: https://opendatasus.saude.gov.br/dataset/sistema-de-informacao-sobre-mortalidade
# script criado em 24/nov/21


### COMO FAZER DOWNLOAD DA BASE DADOS COMPLETA DIRETAMENTE PELA INTERNET?

# URL do arquivo csv - vindo direto da internet
url_csv <- "https://s3-sa-east-1.amazonaws.com/ckan.saude.gov.br/SIM/Mortalidade_Geral_2019.csv"

# Leitura do arquivo csv deixando a função definir o tipo de cada coluna
sim <- import(url_csv) # vai demorar um cadinho pois o banco de dados é grande;


names(sim) # nome das variaveis

# para diminuir a base de dados:
# Vamos filtrar para MUNIC de Residencia = Rio de Janeiro (330455) e
# selecionar as variaveis referentes a idade e sexo
# ver mais detalhes no dicionario do SIM
# http://svs.aids.gov.br/dantps/cgiae/sim/documentacao/dicionario-de-dados-SIM-tabela-DO.pdf


sim.final <- sim %>% filter(CODMUNRES == "330455") %>%
                      select(IDADE, SEXO) %>%
                       mutate(IDADE = as.character(IDADE),
                              SEXO = as.factor(SEXO))

rm(sim) # remover a base sim, original

table(sim.final$IDADE)
table(sim.final$SEXO, useNA = "always") 


# no dicionario temos F,M,I mas na base de dados 0,1,2
# fui no tabnet e puxei 
# Óbitos p/Residênc por Sexo segundo Município
# Município: 330455 Rio de Janeiro
# Período: 2019
# comparando tabnet e table(sim.final$SEXO) vi que Sexo:
# 1 – masculino; 2 – feminino; 0 ignorado. 
# talvez tenha um dicionario mais recente ja com catgorias 0,1,2


# Idade: composto de dois subcampos. O primeiro, de 1 dígito, indica a unidade da idade, 
# conforme a tabela a seguir. O segundo, de dois dígitos, indica a quantidade de unidades: 
# 0 – Idade menor de 1 hora, o subcampo varia de 01 e 59; 
# 1 – Hora, o subcampo varia de 01 a 23; 
# 2 – Dias, o subcampo varia de 01 a 29; 
# 3 – Meses, o subcampo varia de 01 a 11; 
# 4 – Anos, o subcampo varia de 00 a 99;
# 5 – Anos (mais de 100 anos), o segundo subcampo varia de 0 a 99. 


# vamos criar variaveis auxiliares: IDADE.UNIDADE (1o digito) e IDADE.AUX (2o digito em diante)
# OBJETIVO: criar a variavel idade em anos (IDADE.ANOS)

sim.final <- sim.final %>% 
  mutate(IDADE.UNIDADE = str_sub(IDADE, start = 1, end= 1), # 1o digito da IDADE (que veio na base)
         IDADE.AUX = str_sub(IDADE, start = 2)) # 2o digito em diante da IDADE (que veio na base)

table(sim.final$IDADE.UNIDADE)

# remover unidades acima de 5 (pelo dicionario, nao existem e nao sei dizer quais sao as idades em anos)
# e reclass as variaveis novas
# IDADE.AUX numerica
sim.final <- sim.final %>% filter(IDADE.UNIDADE <= 5) %>%
                            mutate(IDADE.AUX = as.numeric(IDADE.AUX))

table(sim.final$IDADE.UNIDADE)
table(sim.final$IDADE)


#######
## CRIANDO VARIAVEL EM ANOS
######


# Se a unidade da idade for menor que 4 (ou seja, 0,1,2 ou 3) a idade.anos receberá 0; 
# se a unidade da idade for = 4, idade.anos receberá idade.aux, caso contrario (unidade = 5), 
# idade.anos receberá idade.anos + 100

sim.final$IDADE.ANOS <- ifelse(sim.final$IDADE.UNIDADE < 4, 0, 
                               ifelse(sim.final$IDADE.UNIDADE == "4", sim.final$IDADE.AUX,
                                      (sim.final$IDADE.AUX + 100))) 

summary(sim.final$IDADE.ANOS)
boxplot(sim.final$IDADE.ANOS)
hist(sim.final$IDADE.ANOS)


#######
## CRIANDO FAIXA ETARIA a partir da IDADE EM ANOS (NOVA)
######


# quero criar as seguintes faixas de idade

#  0 a 14 anos
# 15 a 19 anos
# 20 a 29 anos
# 30 a 39 anos
# 40 a 49 anos
# 50 a 59 anos
# 60 a 69 anos
# 70 a 79 anos
# 80 anos e mais

# no R (na matematica) seria algo como:

#[0 , 15) 
#[15 , 20)
#[20, 30)
#[30 , 40) 
#[40 , 50)
#[50, 60)
#[60, 70)
#[70, 80)
#[80, Infinito)


# notem que so entram: o 1o valor que no meu caso é o 0, os valores valores inferiores de cada intervalo, e o infinito

sim.final$fxetaria <- cut(sim.final$IDADE.ANOS,
                         breaks = c(0,15,20,30,40,50,60,70,80,Inf))

table(sim.final$fxetaria) # observe que os [ e ) nao estao iguais ao que queremos.
# para ajeitar podemos usar o argumento right = FALSE (ou seja, fechado a direita? NAO)

# ah! fechado  a direita significa ] ou seja o limite superior ta dentro do intervalo
# e aberto  a direita significa ) ou seja o limite superior nao ta dentro do intervalo

sim.final$fxetaria <- cut(sim.final$IDADE.ANOS,
                          breaks = c(0,15,20,30,40,50,60,70,80,Inf),
                          right = FALSE)

table(sim.final$fxetaria)  # agora sim esta igual ao que queremos

# Agora que vi o comando certo que retorna o que quero, vou mudar os labels


sim.final$fxetaria <- cut(sim.final$IDADE.ANOS,
                          breaks = c(0,15,20,30,40,50,60,70,80,Inf),
                          right = FALSE,
                          labels =  c("0 a 14 anos",
                                      "15 a 19 anos",
                                      "20 a 29 anos",
                                      "30 a 39 anos",
                                      "40 a 49 anos",
                                      "50 a 59 anos",
                                      "60 a 69 anos",
                                      "70 a 79 anos",
                                      "80 anos e mais"))

table(sim.final$fxetaria)  # agora sim esta igual ao que queremos


#################
### PIRAMIDE ETARIA
#################

# renomear sexo
sim.final <- sim.final %>% 
  mutate(SEXO = recode( SEXO, "1" = "Masculino", "2" = "Feminino", "0" = "Ignorado" ))

piramide <- sim.final %>% group_by(fxetaria, SEXO) %>% tally() 

piramide

piramide <- piramide %>%
  filter(SEXO != "Ignorado" & !is.na(fxetaria)) %>% # excluir sexo ignorado e fxetaria faltamte (NA / missing)
  mutate(SEXO = as.factor(SEXO))

piramide %>%
  ggplot(aes(x = fxetaria,
                       y = ifelse(test = SEXO == "Masculino",  yes = -n, no = n), 
                       fill = SEXO)) + # se sexo masc, recene freq absoluta negativa, caso contrario (fem) recebe freq positiva
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = abs, limits = (max(piramide$n))* c(-1,1)) +
  labs(y = "Número de óbitos", x = "Faixa etária (em anos)",
       fill = "Sexo",
       title = "Óbitos segundo Sexo e Faixa etária, MRJ 2019",
       caption= "Fonte: SIM, 2019") + # nomes dos eixos e legenda
  scale_fill_brewer(palette = "Set1", direction = -1) + # cor
  coord_flip() + # faz coluna virar barra
  theme_minimal(base_size = 12) +
  theme(legend.position= "bottom")


###### piramide ( usando % )

N <- sum(piramide$n)

piramide <- piramide %>% mutate(porcent = n/N*100)

piramide %>%
  ggplot(aes(x = fxetaria,
             y = ifelse(test = SEXO == "Masculino",  yes = -porcent, no = porcent), 
             fill = SEXO)) + # se sexo masc, recene freq absoluta negativa, caso contrario (fem) recebe freq positiva
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = abs, limits = (max(piramide$porcent))* c(-1,1)) +
  labs(y = "% de óbitos", x = "Faixa etária (em anos)",
       fill = "Sexo",
       title = "Óbitos segundo Sexo e Faixa etária, MRJ 2019",
       caption= "Fonte: SIM, 2019") + # nomes dos eixos e legenda
  scale_fill_brewer(palette = "Set2") + # cor
  coord_flip() + # faz coluna virar barra
  theme_minimal(base_size = 12) +
  theme(legend.position= "bottom")




#### tentei fazer passo a passo para que você consiga entender o raciocinio e consiga aplicar em outras bases;
#### daria p/ fazer um script c/ bem menos linhas
