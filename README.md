# Serviços de integração Trouw

Todas as integrações estão no mesmo projeto hospedado em https://github.com/Trouw-Tecnologia/trouw-integracoes \
O projeto na máquina de homologação `[vm-microservices]` e produção `[microservices]` no diretório `/app/localapps/trouw-integracoes`\
Utilizar sempre a versão do NodeJS definida no arquivo `package.json`

O ponto de partida de cada integração segue o padrão src/tecnologias/{{nome da tecnologia}}/trouw-tecn-{{nome da tecnologia}}-index.ts\
Ex: `src/tecnologias/3s/trouw-tecn-3s-index.ts`

O arquivo de configuração de cada integração de estar na pasta `conf/` com o padrão de nome seguido de -{{ctec_codigo}}.json\
Ex: `conf/trouw-tecn-sighra-52.json`

As integrações que possuem algum tipo de cache, como último id gravado, ultima data, etc, le e grava arquivo(s) em `cache/` \
Ex: `cache/trouw-tecn-addlog-6622-cahce-ult.json`\
Esses arquivos não precisam ser criados mas podem ser manipulados, alterando a ultima data para uma anterior fará que a integração reconsulte informações.\
Cada aplicação usa esses arquivos de uma forma diferente então é necessário saber como eles são interpretados antes de fazer alguma alteração manual.

Cada serviço está localizado no diretório `/etc/systemd/system/` com o mesmo padrão de nomenclatura de seu arquivo de configuração.\
Ex: `/etc/systemd/system/trouw-tecn-maxtrack-44212.service` \
Para configuração de um novo serviço é aconselhável clonar de um já estabelecido e alterar nomes e parametros passados para o arquivo `.js`

O monitor do RabbitMQ pode ser acessado em https://customer.cloudamqp.com/ \
As aplicações enviam os pacotes para as 10 filas do RabbitMQ `r01, r02, r03, r04, r05, r06, r07, r08, r09, r10` \
Os serviços de consumo de fila são divididos em 10, um para cada fila \
Ex: \
`trouw-gravador-de-pacotes-01-001` é o primeiro serviço que consome a fila `r01` \
`trouw-gravador-de-pacotes-08-003` é o terceiro serviço que consome a fila `r08`

## Comandos úteis para verificar situação dos serviços

```bash
# recarregar configurações quando alterado algum arquivo .service
systemctl daemon-reload

# exibir status do serviço
systemctl status trouw-tecn-3s-0052

# reiniciar serviço
systemctl restart trouw-tecn-3s-0052

# parar serviço
systemctl stop trouw-tecn-3s-0052

# desabilitar serviço
systemctl disable trouw-tecn-3s-0052

# acompanhar logs em tempo real (-n para definir o número de linhas)
journalctl -n 40 -lf -u trouw-tecn-3s-0052

```

## Serviços ativos em produção

```
trouw-tecn-addlog-5047
trouw-tecn-3s-5036
trouw-tecn-sighra-16
trouw-tecn-maxtrack-5043

trouw-gravador-de-pacotes-01-001
trouw-gravador-de-pacotes-02-001
trouw-gravador-de-pacotes-03-001
trouw-gravador-de-pacotes-04-001
trouw-gravador-de-pacotes-05-001
trouw-gravador-de-pacotes-06-001
trouw-gravador-de-pacotes-07-001
trouw-gravador-de-pacotes-08-001
trouw-gravador-de-pacotes-09-001
trouw-gravador-de-pacotes-10-001
```

## Recursos integrados por Tecnologia

### 3S [TS-486](https://trouw-tecnologia.atlassian.net/browse/TS-486)

* Requisita um único endpoint que trás o histórico de dados de posições e periféricos num único XML
* Armazena em cache o último id de posição e o últumo id de sensor
* O intervalo entre consultas pode ser alto (30s)
* O envio de comandos ainda está pendente

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |&check;   |&check;       |        |    |

| Código | Evento                               | Preenchimento                                           | Notas |
|--------|--------------------------------------|---------------------------------------------------------|-------|
| 8      | EVENTO DE VELOCIDADE                 | INTEIRO - VALOR DA VELOCIDADE RECEBIDA                  ||
| 10     | EVENTO DE HODÔMETRO                  | INTEIRO - VALOR DO HODÔMETRO RECEBIDO                   ||
| 30     | EVENTO DE IGNIÇÃO                    | INTEIRO - 0;1;2;3. 0=IGNIÇÃO DESLIGADA; 1=IGNIÇÃO LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO ||
| 32     | EVENTO DE BLOQUEIO                   | INTEIRO - 0;1;2;3. 0=VEÍCULO NÃO BLOQUEADO; 1=VEÍCULO BLOQUEADO; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1|
| 79     | EVENTO DE SENSOR DE JAMMER DETECTADO | 1=JAMMER DETECTADO                                      ||
| 88     | EVENTO DE STATUS DA BATERIA DO RASTREADOR | INTEIRO - 0;1;2. 0=SEM BATERIA; 1=BATERIA NORMAL; 2=BATERIA FRACA |0;1|
| 109    | Evento de Horímetro                  | VALOR DO HORÍMETRO EM MINUTOS                           |

---

### Addlog [TS-494](https://trouw-tecnologia.atlassian.net/browse/TS-494)

* Requisita um único endpoint que trás a última posição de todos os veículos
* O cliente é identificado na url, é um endepoint diferente para cada cliente
* Armazena em cache a data de da última posição de cada terminal
* O tempo entre requisições pode ser baixíssimo (1s)

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |          |&check;       |        |    |

| Código | Evento                               | Descrição                                               | Notas |
|--------|--------------------------------------|---------------------------------------------------------|-------|
| 8      | EVENTO DE VELOCIDADE                 | INTEIRO - VALOR DA VELOCIDADE RECEBIDA                  |       |
| 10     | EVENTO DE HODÔMETRO                  | INTEIRO - VALOR DO HODÔMETRO RECEBIDO                   |       |
| 30     | EVENTO DE IGNIÇÃO                    | INTEIRO - 0;1;2;3. 0=IGNIÇÃO DESLIGADA; 1=IGNIÇÃO LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO |       |
| 106    | EVENTO DE NÍVEL DE BATERIA BAIXO     | VALOR DO NÍVEL DE BATERIA                               |       |
| 109    | Evento de Horímetro                  | VALOR DO HORÍMETRO EM MINUTOS                           |       |

---

### Maxtrack [TS-493](https://trouw-tecnologia.atlassian.net/browse/TS-493)

* Consome uma fila do RabbitMQ da Maxtrack

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |          |&check;       |        |    |

| Código | Evento                               | Preenchimento                                           | Notas |
|--------|--------------------------------------|---------------------------------------------------------|-------|
| 8      | EVENTO DE VELOCIDADE                 | INTEIRO - VALOR DA VELOCIDADE RECEBIDA                  |       |
| 10     | EVENTO DE HODÔMETRO                  | INTEIRO - VALOR DO HODÔMETRO RECEBIDO                   |       |
| 11     | EVENTO DE TEMPERATURA SENSOR 01      | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
| 79     | EVENTO DE SENSOR DE JAMMER DETECTADO | 1=JAMMER DETECTADO                                      |       |
| 109    | Evento de Horímetro                  | VALOR DO HORÍMETRO EM MINUTOS                           |       |

---

### Sighra [TS-487](https://trouw-tecnologia.atlassian.net/browse/TS-487)

* Consulta o banco de dados mysql da Sighra diretamente (instalado em rede local da Trouw)
* Armazena em cache o último id de periféricos, mensagens e posições
* As tabelas de posição são diárias no formato DDMMYYYY
* Pode ter um tempo entre consultas baixíssimo (3s) 

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |&check;   |              |&check; |    |

| Código | Evento                                           | Descrição                                               | Notas |
|--------|--------------------------------------------------|---------------------------------------------------------|-------|
| 1      | EVENTO DE ENGATE 01                              | INTEIRO - 0;1;2;3. 0=CARRETA1 DESENGATADA; 1=CARRETA1 ENGATADA; 2=CARRETA1 VIOLADA; 3=STATUS DESCONHECIDO |0;1       |
| 3      | EVENTO DE PORTAS DO CARONEIRO                    | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1       |
| 4      | EVENTO DE PORTAS DO MOTORISTA                    | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;2       |
| 7      | EVENTO DE SENSOR DE PAINEL                       | INTEIRO - 0;1;2;3. 0=PAINEL NÃO VIOLADO; 1=NÃO USAR; 2=PAINEL VIOLADO; 3=STATUS DESCONHECIDO |1;2       |
| 8      | EVENTO DE VELOCIDADE                             | INTEIRO - VALOR DA VELOCIDADE RECEBIDA                  |       |
| 12     | EVENTO DE GPS                                    | INTEIRO - 0;1;2;3. 0=GPS PARADO; 1=GPS FUNCIONANDO; 2=GPS VIOLADO; 3=STATUS DESCONHECIDO |1;2       |
| 13     | EVENTO DE TECLADO                                | INTEIRO - 0;1;2;3. 0=TECLADO PARADO; 1=TECLADO FUNCIONANDO; 2=TECLADO VIOLADO; 3=STATUS DESCONHECIDO |0;1       |
| 14     | EVENTO DE SENSOR DE ANTENA                       | INTEIRO - 0;1;2;3. 0=ANTENA COM PROBLEMA; 1=ANTENA FUNCIONANDO; 2=ANTENA VIOLADA; 3=STATUS DESCONHECIDO |0;1;2       |
| 16     | EVENTO DE PERDA DE SINAL                         | INTEIRO - 0;1;2;3. 0=SEM SINAL; 1=COM SINAL; 2=NÃO USAR; 3=NÃO USAR |0       |
| 17     | EVENTO DE BOTÃO DE PÂNICO                        | INTEIRO - 0;1;2;3. 0=PÂNICO NÃO PRESSIONADO; 1=PÂNICO PRESSIONADO; 2=NÃO USAR; 3=NÃO USAR |       |
| 30     | EVENTO DE IGNIÇÃO                                | INTEIRO - 0;1;2;3. 0=IGNIÇÃO DESLIGADA; 1=IGNIÇÃO LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1       |
| 42     | EVENTO DE ENGATE 02                              | INTEIRO - 0;1;2;3. 0=CARRETA2 DESENGATADA; 1=CARRETA2 ENGATADA; 2=CARRETA2 VIOLADA; 3=STATUS DESCONHECIDO |0;1       |
| 51     | EVENTO DE BATERIA                                | INTEIRO - 0;1;2;3. 0=BATERIA DESLIGADA; 1=BATERIA LIGADA; 2=BATERIA VIOLADA; 3=STATUS DESCONHECIDO |2       |
| 53     | EVENTO DE PISCA ALERTA                           | INTEIRO - 0;1;2;3. 0=PISCA ALERTA DESLIGADO; 1=PISCA ALERTA LIGADO; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1       |
| 66     | EVENTO DE JANELAS                                | INTEIRO - 0;1;2;3. 0=JANELA FECHADA; 1=JANELA ABERTA; 2=JANELA VIOLADA; 3=STATUS DESCONHECIDO |0;2       |
| 67     | EVENTO DO SENSOR DE PORTA DE BAÚ 01              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;2       |
| 68     | EVENTO DO SENSOR DE PORTA DE BAÚ 02              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1       |
| 69     | EVENTO DO SENSOR DE PORTA DE BAÚ 03              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1       |
| 88     | EVENTO DE STATUS DA BATERIA DO RASTREADOR        | INTEIRO - 0;1;2. 0=SEM BATERIA; 1=BATERIA NORMAL; 2=BATERIA FRACA |       |
| 112    | EVENTO DE SENHA DE COAÇÃO DO MOTORISTA DA TECNOLOGIA |                                                         |1      |
