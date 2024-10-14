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
trouw-tecn-omnilink-wstt-5033
trouw-tecn-onixsat-13
trouw-tecn-sascarga-14

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

---

### Omnilink-WSTT [TS-536](https://trouw-tecnologia.atlassian.net/browse/TS-536)

* Consulta simultaneamente ObtemEventosNormais e ObtemEventosCtrl, retorno XML
* Armazena em cache o último id de cada uma das consultas anteriores
* Possui um cache com a VTEC de cada terminal, é possível que a omnilink retorne com a versão correta ou como genérica, armazena então a versão correta e atribui quando vier genérica
* Existe tratamento na stored procedure `trouw_insere_pacote_recebimento_simples` para recebimentos gerados por essa integração
* Pode ter um tempo entre consultas baixo (30s)
* Possui múltiplas VTECs

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |&check;   |&check;       |        |    |

| Código | Evento                                           | Descrição                                               | Notas |
|--------|--------------------------------------------------|---------------------------------------------------------|-------|
| 1      | EVENTO DE ENGATE 01                              | INTEIRO - 0;1;2;3. 0=CARRETA1 DESENGATADA; 1=CARRETA1 ENGATADA; 2=CARRETA1 VIOLADA; 3=STATUS DESCONHECIDO |       |
| 3      | EVENTO DE PORTAS DO CARONEIRO                    | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;3   |
| 4      | EVENTO DE PORTAS DO MOTORISTA                    | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;3   |
| 8      | EVENTO DE VELOCIDADE                             | INTEIRO - VALOR DA VELOCIDADE RECEBIDA                  |       |
| 10     | EVENTO DE HODÔMETRO                              | INTEIRO - VALOR DO HODÔMETRO RECEBIDO                   |       |
| 12     | EVENTO DE GPS                                    | INTEIRO - 0;1;2;3. 0=GPS PARADO; 1=GPS FUNCIONANDO; 2=GPS VIOLADO; 3=STATUS DESCONHECIDO |0;1;2    |
| 17     | EVENTO DE BOTÃO DE PÂNICO                        | INTEIRO - 0;1;2;3. 0=PÂNICO NÃO PRESSIONADO; 1=PÂNICO PRESSIONADO; 2=NÃO USAR; 3=NÃO USAR |1      |
| 30     | EVENTO DE IGNIÇÃO                                | INTEIRO - 0;1;2;3. 0=IGNIÇÃO DESLIGADA; 1=IGNIÇÃO LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO |       |
| 67     | EVENTO DO SENSOR DE PORTA DE BAÚ 01              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;3    |
| 77     | EVENTO DE DESVIO DE ROTA DA TECNOLOGIA           | INTEIRO - 0;1;2;3. 0=NORMAL; 1=FORA DA ROTA; 2=NÃO USAR; 3=NÃO USAR |1      |

---

### Onixsat [TS-533](https://trouw-tecnologia.atlassian.net/browse/TS-533)

* Consulta RequestMensagemCB, retorno ZIP com XMLs
* Armazena em cache o último id de pacote
* Possui um cache com a VTEC de cada terminal, que é recebido em consulta posterior, essa consulta só pode ser feita a cada 5min então caso receba um que não está em cache e não pode consultar os veículos então segura em memória até a próxima consulta
* Tempo mínimo entre consultas (30s)
* Possui múltiplas VTECs

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |&check;   |&check;       |&check; |    |

| Código | Evento                                           | Descrição                                               | Notas |
|--------|--------------------------------------------------|---------------------------------------------------------|-------|
| 1      | EVENTO DE ENGATE 01                              | INTEIRO - 0;1;2;3. 0=CARRETA1 DESENGATADA; 1=CARRETA1 ENGATADA; 2=CARRETA1 VIOLADA; 3=STATUS DESCONHECIDO |0;1     |
| 3      | EVENTO DE PORTAS DO CARONEIRO                    | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;2   |
| 4      | EVENTO DE PORTAS DO MOTORISTA                    | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1;2   |
| 6      | EVENTO DE TRAVA DE 5 RODA                        | INTEIRO - 0;1;2;3. 0=5RODA DESTRAVADA; 1=5RODA TRAVADA; 2=5RODA VIOLADA; 3=STATUS DESCONHECIDO |0;1    |
| 7      | EVENTO DE SENSOR DE PAINEL                       | INTEIRO - 0;1;2;3. 0=PAINEL NÃO VIOLADO; 1=NÃO USAR; 2=PAINEL VIOLADO; 3=STATUS DESCONHECIDO |2      |
| 8      | EVENTO DE VELOCIDADE                             | INTEIRO - VALOR DA VELOCIDADE RECEBIDA                  |       |
| 9      | EVENTO DE RPM                                    | INTEIRO - VALOR DO RPM RECEBIDO                         |       |
| 10     | EVENTO DE HODÔMETRO                              | INTEIRO - VALOR DO HODÔMETRO RECEBIDO                   |       |
| 11     | EVENTO DE TEMPERATURA SENSOR 01                  | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
| 13     | EVENTO DE TECLADO                                | INTEIRO - 0;1;2;3. 0=TECLADO PARADO; 1=TECLADO FUNCIONANDO; 2=TECLADO VIOLADO; 3=STATUS DESCONHECIDO |0      |
| 14     | EVENTO DE SENSOR DE ANTENA                       | INTEIRO - 0;1;2;3. 0=ANTENA COM PROBLEMA; 1=ANTENA FUNCIONANDO; 2=ANTENA VIOLADA; 3=STATUS DESCONHECIDO |2      |
| 16     | EVENTO DE PERDA DE SINAL                         | INTEIRO - 0;1;2;3. 0=SEM SINAL; 1=COM SINAL; 2=NÃO USAR; 3=NÃO USAR |1      |
| 17     | EVENTO DE BOTÃO DE PÂNICO                        | INTEIRO - 0;1;2;3. 0=PÂNICO NÃO PRESSIONADO; 1=PÂNICO PRESSIONADO; 2=NÃO USAR; 3=NÃO USAR |1      |
| 30     | EVENTO DE IGNIÇÃO                                | INTEIRO - 0;1;2;3. 0=IGNIÇÃO DESLIGADA; 1=IGNIÇÃO LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1     |
| 32     | EVENTO DE BLOQUEIO                               | INTEIRO - 0;1;2;3. 0=VEÍCULO NÃO BLOQUEADO; 1=VEÍCULO BLOQUEADO; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1     |
| 33     | EVENTO DE TEMPERATURA SENSOR 02                  | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
| 34     | EVENTO DE TEMPERATURA SENSOR 03                  | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
| 42     | EVENTO DE ENGATE 02                              | INTEIRO - 0;1;2;3. 0=CARRETA2 DESENGATADA; 1=CARRETA2 ENGATADA; 2=CARRETA2 VIOLADA; 3=STATUS DESCONHECIDO |0;1     |
| 46     | EVENTO DE AVISO SONORO SIRENE                    | INTEIRO - 0;1;2;3. 0=SIRENE DESLIGADA; 1=SIRENE LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO |1      |
| 48     | EVENTO DE AVISO SONORO BUZZER                    | INTEIRO - 0;1;2;3. 0=BUZZER DESLIGADO; 1=BUZZER LIGADO; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1    |
| 51     | EVENTO DE BATERIA                                | INTEIRO - 0;1;2;3. 0=BATERIA DESLIGADA; 1=BATERIA LIGADA; 2=BATERIA VIOLADA; 3=STATUS DESCONHECIDO |2      |
| 52     | EVENTO DE VELOCÍMETRO                            | INTEIRO - 0;1;2;3. 0=NÃO USAR; 1=VELOCÍMETRO NÃO VIOLADO; 2=VELOCÍMETRO VIOLADO; 3=STATUS DESCONHECIDO |2      |
| 53     | EVENTO DE PISCA ALERTA                           | INTEIRO - 0;1;2;3. 0=PISCA ALERTA DESLIGADO; 1=PISCA ALERTA LIGADO; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1     |
| 54     | EVENTO DE JANELA DO MOTORISTA                    | INTEIRO - 0;1;2;3. 0=JANELA FECHADA; 1=JANELA ABERTA; 2=JANELA VIOLADA; 3=STATUS DESCONHECIDO |2      |
| 55     | EVENTO DE JANELA DO CARONEIRO                    | INTEIRO - 0;1;2;3. 0=JANELA FECHADA; 1=JANELA ABERTA; 2=JANELA VIOLADA; 3=STATUS DESCONHECIDO |2      |
| 67     | EVENTO DO SENSOR DE PORTA DE BAÚ 01              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |0;1     |
| 68     | EVENTO DO SENSOR DE PORTA DE BAÚ 02              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |1      |
| 69     | EVENTO DO SENSOR DE PORTA DE BAÚ 03              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |1      |
| 70     | EVENTO DO SENSOR DE PORTA DE BAÚ 04              | INTEIRO - 0;1;2;3. 0=PORTA FECHADA; 1=PORTA ABERTA; 2=PORTA VIOLADA; 3=STATUS DESCONHECIDO |1      |
| 79     | EVENTO DE SENSOR DE JAMMER DETECTADO             | 1=JAMMER DETECTADO                                      |       |
| 112    | EVENTO DE SENHA DE COAÇÃO DO MOTORISTA DA TECNOLOGIA |                                                         |1      |

---

### Sascar Sascarga [TS-538](https://trouw-tecnologia.atlassian.net/browse/TS-538)

* Consulta obterPacotePosicoes, retorno XML
* A própria sascar controla quais pacotes foram consumidos, então 2 requisições não vão retornar os mesmo dados
* Armazena em cache o último id de cada uma das consultas anteriores para caso exista um gap no sequencial de id, consulta obterPacotePosicaoPorRange, também salva o range em cache
* Possui um cache com a placa de cada terminal que usa como número, caso não tenha em cache consulta em obterVeiculos em no mínimo 5min de intervalo, mantem os veículos sem placa ainda em memória até próxima consulta  
* Pode ter um tempo entre consultas baixo (30s)

|Lat/Lng|Data Comp. Bordo|Data Tecn.|Endereço Tecn.|Mensagem|Viag|
|-------|----------------|----------|--------------|--------|----|
|&check;|&check;         |&check;   |&check;       |&check; |    |

| Código | Evento                                           | Descrição                                               | Notas |
|--------|--------------------------------------------------|---------------------------------------------------------|-------|
| 11     | EVENTO DE TEMPERATURA SENSOR 01                  | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
| 12     | EVENTO DE GPS                                    | INTEIRO - 0;1;2;3. 0=GPS PARADO; 1=GPS FUNCIONANDO; 2=GPS VIOLADO; 3=STATUS DESCONHECIDO |1;2     |
| 30     | EVENTO DE IGNIÇÃO                                | INTEIRO - 0;1;2;3. 0=IGNIÇÃO DESLIGADA; 1=IGNIÇÃO LIGADA; 2=NÃO USAR; 3=STATUS DESCONHECIDO |0;1     |
| 32     | EVENTO DE BLOQUEIO                               | INTEIRO - 0;1;2;3. 0=VEÍCULO NÃO BLOQUEADO; 1=VEÍCULO BLOQUEADO; 2=NÃO USAR; 3=STATUS DESCONHECIDO |       |
| 33     | EVENTO DE TEMPERATURA SENSOR 02                  | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
| 34     | EVENTO DE TEMPERATURA SENSOR 03                  | INTEIRO - VALOR DA TEMPERATURA RECEBIDA                 |       |
