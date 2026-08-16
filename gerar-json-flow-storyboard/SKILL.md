---
name: gerar-json-flow-storyboard
description: Converte um roteiro/narração em texto corrido num arquivo .json pronto pra importar (Load) na ferramenta de storyboard do Google Flow (Nano Banana) — já com o roteiro segmentado em frames (cenas/shots), os assets (characters/locations/props) extraídos do texto, e os metadados do projeto preenchidos, seguindo exatamente o schema que a ferramenta espera. Existe porque colar o roteiro puro direto na ferramenta faz o agente dela se perder em roteiros grandes na hora de gerar o JSON e identificar os assets — pré-gerar o JSON aqui evita isso, e a ferramenta só precisa ler e criar os wireframes pro usuário preencher/subir foto. Use quando o usuário tiver um roteiro pronto (fora do canal Viva o Secreto) e quiser o .json de importação da ferramenta de storyboard, ou pedir "gera o json do storyboard", "monta o projeto pra importar no Flow", "segmenta esse roteiro em frames". NÃO usar para o canal Viva o Secreto (lá o fluxo é a skill preparar-video, que gera um dossiê em Markdown, não esse schema JSON).
---

# Gerar JSON de Storyboard pro Flow

Pré-processa um roteiro inteiro aqui (segmentação em frames + extração de assets) e entrega um `.json` pronto pra importar via **Load** na ferramenta de storyboard, no schema exato que ela lê. Isso evita que o agente da ferramenta tenha que interpretar um roteiro grande inteiro numa passada só — que é onde ele se perde e falha ao gerar o JSON/identificar assets.

## Schema de referência (formato exato que a ferramenta espera)

```json
{
  "projectTitle": "Meu Vídeo Incrível",
  "fullMarkdown": "Era uma vez em uma cidade futurista...",
  "videoDuration": "05:00",
  "format": "long",
  "wordsPerSecond": 2.5,
  "assetStyle": "Oil Painting (Canonical)",
  "storyboardStyle": "Realistic",
  "customStyleLibrary": {
    "Estilo Especial": "Uma descrição detalhada do estilo visual personalizado..."
  },
  "assets": [
    {
      "id": "uuid-1",
      "type": "character",
      "name": "Herói",
      "physicalCharacteristics": "Alto, olhos azuis",
      "clothingAccessories": "Capa vermelha",
      "backstory": "Um viajante do tempo",
      "supportingImages": []
    }
  ],
  "frames": [
    {
      "id": "frame-1",
      "sceneNumber": "01",
      "shotNumber": "01",
      "title": "Abertura",
      "visualDescription": "O herói olhando para o horizonte",
      "linkedAssetIds": ["uuid-1"],
      "imageUrl": ""
    }
  ]
}
```

Note que `frames[]` não guarda timestamp/duração explícita — a ferramenta recalcula o tempo em runtime a partir de `fullMarkdown` + `wordsPerSecond` + `videoDuration`. O trabalho deste skill é decidir **quantos frames existem e o que cada um mostra**, na ordem certa; o tempo por trás disso é só pra calibrar essa quantidade.

## Passos

1. **Coletar inputs do usuário**: roteiro completo (texto corrido), `projectTitle`, `videoDuration` alvo (MM:SS ou HH:MM:SS), `assetStyle` e `storyboardStyle` (estilo visual desejado — perguntar se ele não tiver um definido ainda; pode deixar `""` pra preencher depois na ferramenta). `format` é `"long"` pra esse canal (vídeo 16:9, não Shorts). `wordsPerSecond` default `2.5`, ajustável se o usuário informar um ritmo de narração diferente.

2. **Preencher `fullMarkdown`**: o texto do roteiro, verbatim.

3. **Extrair assets**: ler o roteiro inteiro e identificar todo character, location e prop que se repete ou é relevante o bastante pra precisar de consistência visual entre frames (o mesmo critério do Etapa 2 da ferramenta: harry potter = character, salão comunal da grifinória = location, pomo de ouro / luva de quadribol = props). Pra cada um, criar uma entrada em `assets[]`:
   - `id`: `"<type>-<nome-em-kebab-case>"` (ex: `"character-harry-potter"`, `"location-salao-comunal-grifinoria"`, `"prop-pomo-de-ouro"`) — legível e estável, facilita conferir `linkedAssetIds` depois.
   - `type`: `"character"`, `"location"` ou `"prop"`.
   - `name`: nome legível.
   - `physicalCharacteristics`, `clothingAccessories`, `backstory`: preencher com o que der pra inferir do roteiro; deixar `""` quando o roteiro não descrever (o usuário completa isso depois na ferramenta, via autofill ou upload).
   - `supportingImages`: sempre `[]` (o usuário sobe as imagens de referência na própria ferramenta).

4. **Segmentar em `frames[]`**: quebrar o roteiro em frases e agrupar em quadros usando a mesma lógica de ritmo pra vídeo longo:
   - Duração estimada de cada frase = contagem de palavras ÷ `wordsPerSecond`.
   - Alvo de **~15s por frame**, banda **10~20s**.
   - Cortar pra um frame novo sempre que entrar um character/location/prop diferente do que já está no frame atual — mesmo antes de bater os ~15s. Só deixar passar de 15s (até o teto de 20s) quando não houver troca de asset no trecho.
   - Conferência: `duração_total_estimada` (soma dos frames) deve bater aproximadamente com `videoDuration` informado. Se destoar muito, avisar o usuário (pode ser sinal de roteiro longo/curto demais pro tempo alvo).

5. **Montar cada frame**:
   - `id`: `"frame-1"`, `"frame-2"`, ... sequencial.
   - `sceneNumber`: incrementa (`"01"`, `"02"`, ...) a cada mudança de location/contexto narrativo.
   - `shotNumber`: reinicia em `"01"` a cada novo `sceneNumber`, incrementa dentro da mesma cena.
   - `title`: título curto do quadro (estilo slugline).
   - `visualDescription`: descrição visual direta do que aparece — cite os assets envolvidos explicitamente (igual ao exemplo do usuário: "harry potter no salão comunal da grifinória, segurando o pomo de ouro").
   - `linkedAssetIds`: ids (do passo 3) de todo asset presente na cena descrita.
   - `imageUrl`: sempre `""` (a ferramenta/usuário gera depois).

6. **Montar o JSON final** com todos os campos do schema preenchidos e salvar como arquivo `.json` (nome sugerido: slug do `projectTitle`). Entregar o arquivo pronto pra importar via **Load** na ferramenta.

## Observações

- Sem documentação de identidade visual desse canal ainda (diferente do Viva o Secreto, que tem `assetStyle`/`storyboardStyle` implícitos nos docs do projeto) — perguntar o estilo a cada uso até existir um padrão fixo, ou reaproveitar o de um projeto anterior se o usuário indicar.
- Se o roteiro for muito longo e a quantidade de frames passar bem de 60 (pro alvo de 12~15min), avisar o usuário — pode ser sinal de cortar o roteiro ou revisar o `videoDuration`.
