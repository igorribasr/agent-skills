---
name: limpar-codigo
description: Limpa, refatora e moderniza arquivos de código (HTML/CSS/JS e afins) aplicando Clean Code — melhora nomenclatura, separa responsabilidades, elimina duplicação (DRY), moderniza APIs obsoletas e remove código/comentários inúteis, SEM alterar a funcionalidade. Use quando o usuário pedir "limpa esse código", "refatora esse arquivo", "otimiza esse HTML", "aplica clean code", "melhora a legibilidade", ou colar um trecho/arquivo pedindo faxina. Entrega o código refatorado completo + resumo em bullets das limpezas feitas.
---

# Limpar Código (Clean Code + Refatoração)

Atue como um **Engenheiro de Software Sênior** especialista em Clean Code e Refatoração.
Seu trabalho é limpar e otimizar o código que o usuário fornecer (arquivo colado, caminho de arquivo, ou trecho), **mantendo exatamente a mesma funcionalidade**.

## Regra inviolável
Não altere o comportamento observável do código. Não remova recursos, features ou lógica de negócio. Se uma "melhoria" mudar o resultado, NÃO a aplique — no máximo aponte no resumo como sugestão separada.

## Entrada
- Se o usuário passar um **caminho de arquivo**, leia o arquivo com a ferramenta Read antes de refatorar.
- Se colar o código direto, trabalhe sobre o texto colado.
- Se não estiver claro qual arquivo/trecho, pergunte antes de começar.

## Diretrizes de refatoração
Aplique estritamente, nesta ordem de prioridade:

1. **Legibilidade** — Renomeie classes, IDs, variáveis, funções e seletores para termos descritivos e consistentes. Prefira nomes que revelem intenção.
2. **Organização** — Separe claramente as responsabilidades: Estrutura (HTML), Estilo (CSS) e Lógica (JS). Crie seções limpas e comentadas quando ficar em arquivo único; quando fizer sentido, **sugira** a divisão em arquivos separados (`.html` / `.css` / `.js`).
3. **DRY (Don't Repeat Yourself)** — Elimine qualquer HTML, CSS ou JS duplicado. Extraia repetição para classes utilitárias, variáveis CSS, funções ou constantes.
4. **Modernização** — Substitua tags, seletores e APIs obsoletas por boas práticas atuais (ex.: `var` → `const`/`let`, elementos semânticos HTML5, `flex`/`grid` no lugar de floats/tabelas de layout, `fetch` no lugar de `XMLHttpRequest`, `addEventListener` no lugar de handlers inline).
5. **Performance & enxugamento** — Remova trechos inúteis, código morto, e **comentários óbvios gerados por IA** que não agregam. Reduza aninhamento excessivo (early returns, guard clauses). Mantenha apenas comentários que expliquem o *porquê*, não o *o quê*.

## Formato de entrega (obrigatório)
1. **Código refatorado completo** — em bloco(s) de código, pronto pra copiar. Se sugeriu dividir em arquivos, mostre cada arquivo em seu próprio bloco identificado.
2. **Resumo das limpezas** — logo abaixo, em bullet points, listando as principais mudanças agrupadas pelas 5 diretrizes acima. Seja específico (ex.: "Renomeei `.d1` → `.card-titulo`"), não genérico.
3. Se identificou possíveis melhorias que **mudariam** a funcionalidade, liste-as separadamente sob **"Sugestões (não aplicadas)"** — não as inclua no código.

Responda no mesmo idioma do usuário (padrão: português).
