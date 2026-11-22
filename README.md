# Sherlock HnS — [UPDATE SOON] Zajcu37 Archiv Pill Pack

![Workshop preview de [UPDATE SOON] Zajcu37 Archiv Pill Pack](workshop-preview.jpg)

> **Aviso de autoria:** esta pill não foi criada originalmente pela equipe Sherlock HnS. O conteúdo original pertence aos seus respectivos autores. Este repositório contém uma adaptação comunitária, e não reivindica a autoria do addon original.

## Créditos e origem

- **Nome original:** [UPDATE SOON] Zajcu37 Archiv Pill Pack
- **Autor original:** kaleb
- **Workshop oficial:** [[UPDATE SOON] Zajcu37 Archiv Pill Pack no Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3637838829)

## Sobre esta adaptação

Esta versão foi adaptada para se integrar melhor ao servidor **Sherlock HnS**, incluindo os ajustes de compatibilidade necessários para trabalhar com a estrutura do gamemode, a base Parakeets Pill Base utilizada pelo servidor e sua API de pills.

As alterações deste repositório dizem respeito à integração e manutenção da versão usada pelo Sherlock HnS. Elas não alteram a autoria do trabalho original nem substituem a página oficial. Para consultar a publicação original, seus créditos e informações do criador, utilize o link acima.

Os créditos, avisos e condições aplicáveis ao conteúdo de terceiros continuam válidos. Esta adaptação não concede direitos adicionais sobre modelos, materiais, sons ou quaisquer outros recursos originais.

## Suporte e comunicação

Encontrou algum problema com esta adaptação ou com o funcionamento da pill no Sherlock HnS? Entre em contato com **tomate007_** ou **sherlockvitinho** no Discord.

Você também pode participar da nossa comunidade para tirar dúvidas, relatar problemas e acompanhar o projeto:

**[Entrar no Discord da comunidade Sherlock HnS](https://discord.gg/EHXbAmpbse)**

## Estrutura do repositório

- `addon/`: conteúdo do addon que é empacotado para publicação.
- `source/`: manifestos e arquivos de referência preservados durante a importação.
- `workshop-preview.jpg`: imagem de apresentação utilizada neste README e como referência visual do addon.

A pasta `addon/` é empacotada integralmente pelo workflow, usando o manifesto de publicação. Os arquivos de documentação, metadados de origem e workflow ficam fora do pacote.

Dependências externas não são incorporadas automaticamente. Confira os itens obrigatórios na página da nova publicação do Workshop e mantenha instalada a **Enhanced Parakeets Pill Base**, além de quaisquer dependências específicas desta pill.

## Publicação

O workflow utiliza [linventif/gmod-workshop-cicd](https://github.com/linventif/gmod-workshop-cicd), fixado no commit `923dae0a327040b2f01cf6876cbecbbb97462bdf`. Pull requests e pushes validam o empacotamento sem exigir credenciais Steam.

Configure os secrets `STEAM_USER`, `STEAM_PASS` e `STEAM_SHARED_SECRET`. Para a primeira publicação, execute manualmente o workflow na branch `main` com `dry_run=false` e `create_new=true`. Após a criação, registre o ID da nova publicação na variável `WORKSHOP_ID`.

**Não utilize o ID da publicação original como destino de upload.** Depois da configuração inicial, pushes na branch `main` que alterem o conteúdo podem publicar atualizações. Evite executar publicações de repositórios diferentes simultaneamente usando a mesma conta Steam.
