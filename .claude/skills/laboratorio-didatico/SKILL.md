---
name: laboratorio-didatico
description: Guia o estilo didático e de código para os laboratórios de Fundamentos de IA (capitulos/*.qmd) — paradigma procedural, convenções de nomes, code annotations, estrutura de seções. Use ao refatorar um capítulo existente ou ao escrever um novo laboratório .qmd para este repositório.
---

# Estilo dos laboratórios de Fundamentos de IA

Este skill descreve o formato que `capitulos/01-metodos-de-busca-i.qmd` estabeleceu como referência, depois de uma refatoração de OOP (classes `Problem`/`Node`/`SearchAgent` no estilo AIMA) para um estilo procedural focado em reduzir carga cognitiva e deixar a implementação do algoritmo o mais visível possível. Use `01-metodos-de-busca-i.qmd` como exemplo vivo de tudo abaixo — quando em dúvida, olhe como ele resolveu o mesmo problema.

Aplica-se ao refatorar qualquer um dos outros capítulos (`capitulos/02-*.qmd` a `capitulos/11-*.qmd`) para este padrão, e ao escrever laboratórios novos.

## 1. Princípio central: procedural, nunca OOP

Algoritmos são funções que recebem e devolvem estruturas simples (`dict`, `list`, `tuple`) — nunca classes, herança, ou hierarquias de agente. O objetivo é que o leitor veja o corpo da função e já esteja vendo o algoritmo, sem precisar rastrear `self.*`, métodos de uma classe base, ou construtores.

Isso não é só preferência de estilo — é uma decisão tomada a partir de um contraste real dentro do próprio repositório: os capítulos que já eram procedurais (03 em diante) sempre foram mais fáceis de ler que 01/02 quando estes ainda usavam `Problem`/`GraphProblem`/`Node`/`SearchAgent`. Se o capítulo que você está escrevendo/refatorando tem uma "camada de agente" ou uma "classe de ambiente" que só é instanciada uma vez e nunca é reaproveitada com outro comportamento, ela deve virar uma função simples.

## 2. Estado de busca = caminho como lista

Em problemas de busca em grafo, cada candidato na fronteira é **o caminho percorrido até ali** (`['Natal', 'Macaíba']`), não um objeto `Node` com ponteiro para o pai:

```python
frontier = [[start]]
...
path = frontier.pop(0)
current = path[-1]          # estado atual = último elemento do caminho
```

O caminho encontrado já é a solução — não existe passo de "reconstruir o caminho a partir de ponteiros de pai".

## 3. Assinatura e nomes de variável idênticos entre algoritmos-irmãos

Toda função de busca sobre grafo segue a mesma assinatura:

```python
def nome_do_algoritmo(graph, start, goal, return_expansion_order=False):
```

E as mesmas variáveis internas, nesta ordem de aparição: `frontier`, `visited`, `expansion_order`, `path`, `current`, `neighbor`. O objetivo é que o leitor consiga comparar duas implementações lado a lado e enxergar exatamente onde elas divergem (ex.: BFS usa `frontier.pop(0)`, DFS usa `frontier.pop()`, UCS usa `frontier.sort(...)` antes de `pop(0)` — o resto do esqueleto é idêntico).

Retorno também é consistente: `(path, expansion_order)` se `return_expansion_order=True`, senão só `path`; `None` (ou `(None, expansion_order)`) quando não há solução.

**Nenhuma dependência externa por variável global ou closure.** Se o algoritmo precisa de uma heurística ou de qualquer outro dado além do grafo/estado, ele entra como parâmetro explícito (`heuristics`, por exemplo) — nunca como uma variável de módulo reatribuída em células diferentes do notebook (esse foi um bug real encontrado e corrigido: `h = make_h(...)` global no capítulo 02, que mudava o resultado de uma célula dependendo da ordem de execução).

## 4. Docstring de uma linha, sem Args/Returns

```python
def breadth_first_search(graph, start, goal, return_expansion_order=False):
    """Busca em largura: expande o caminho mais raso primeiro (fila FIFO)."""
```

Uma frase, descrevendo o mecanismo (não repete os nomes dos parâmetros — eles já são autoexplicativos, e a prosa acima da célula já dá o contexto conceitual).

## 5. Formatação das células de código

Toda célula ` ```{python} ` tem uma linha em branco logo após a abertura e outra logo antes do fechamento:

```
```{python}

def foo():
    ...

```
```

**Exceção:** se a primeira linha precisa ser um IPython magic (`%%capture`), ele tem que ser literalmente a primeira linha da célula — uma linha em branco antes quebra o magic. Nesse caso, só a quebra de linha final é adicionada.

## 6. Code annotation no lugar de `<details>` linha a linha

Não escreva um bloco `<details><summary>Explicação</summary>` comentando o código linha a linha — isso duplica o que o código+docstring já comunicam e é a maior fonte de carga cognitiva desnecessária identificada neste material.

Em vez disso, use [code annotation](https://quarto.org/docs/authoring/code-annotation.html) nativo do Quarto, e só nas 1–3 linhas que carregam a diferença algorítmica real:

```python
        path = frontier.pop(0)  # <1>
        ...
            if neighbor == goal:  # <2>
```
1. Remove sempre o caminho mais antigo — a fronteira se comporta como uma fila FIFO, garantindo exploração nível por nível.
2. Teste de objetivo na geração do vizinho, não na retirada — é isso que garante o caminho com o menor número de passos.

A lista numerada vem imediatamente após o ` ``` ` de fechamento, sem `<details>` ao redor (annotations já são discretas visualmente — não precisam de collapse). Não anote linhas óbvias (`frontier = [[start]]`, `expansion_order.append(current)`) — só o que exige explicação.

## 7. Estrutura de seções do capítulo, em ordem

1. **Front matter**: `title`, `format: {html: default, ipynb: default}`, `jupyter: python3` (mais `date: last-modified`/`toc: true` quando fizer sentido). O `format-links: [ipynb]` fica centralizado em `capitulos/_metadata.yml`, não precisa repetir por arquivo.
2. `## Ajustando ambiente` — só os imports necessários.
3. `## Motivação` — um parágrafo de prosa, por que o conteúdo importa.
4. `## Objetivos de Aprendizagem` — **lista plana**, sem sub-itens aninhados. Um bullet por objetivo concreto, formato `* **Verbo + objeto:** elaboração curta.`. Precisa refletir exatamente o que o capítulo ensina/implementa — ao adicionar um algoritmo novo, adicione o bullet correspondente (não deixe a lista dessincronizar do conteúdo real, como aconteceu quando a UCS foi citada na Motivação mas não tinha nem objetivo nem implementação).
5. `## Implementação`
   - `### Representação do ambiente` — mostre o dado concreto (o dict de verdade) **antes** de qualquer função. Grafo primeiro, função depois.
   - `### Funções auxiliares` — helpers pequenos e reaproveitáveis (ex. `path_cost`), cada um com docstring de uma linha + uma frase de prosa sobre o papel dele (não o mecanismo linha a linha).
6. `## Exemplo prático` — instancia `estado_inicial`/`objetivo` concretos e imprime uma checagem rápida (`print('Ações possíveis em Natal:', ...)`).
7. Uma `###` por algoritmo, sempre no mesmo sub-padrão:
   1. Parágrafo de prosa conceitual (o que a estratégia faz, propriedades de completude/otimalidade) — não fale de código aqui, isso é papel da annotation.
   2. Célula de código com docstring + annotations estratégicas.
   3. Lista numerada das annotations.
   4. Célula de demonstração que reaproveita `graph`/`estado_inicial`/`objetivo` já definidos (nunca recria estrutura já existente) e imprime o resultado (`print('Caminho encontrado (BFS):', resultado_bfs)`).
8. `## Desafio` — um ou mais exercícios como sub-`###`, cada um com o mesmo sub-padrão acima, mas a função tem uma lacuna real (`pass`) e um comentário indicando o que falta (`# Adicione os novos caminhos à fronteira.`). Desafios podem se encadear (ex.: busca em profundidade iterativa reaproveitando a busca em profundidade limitada do desafio anterior) — isso é preferível a exercícios soltos.
   - Feche com `<details><summary>Dicas</summary>` contendo a(s) resposta(s) completas em blocos ` ```python ` **sem** `{python}` (não executáveis) — um bloco `{python}` executável na resposta sobrescreveria silenciosamente a célula do aluno acima quando o notebook rodasse do início ao fim.
9. `## Perguntas para reflexão` — **menos de 5** perguntas, cada uma exigindo síntese (comparar dois algoritmos, justificar uma escolha de design, conectar um exercício ao conteúdo principal) — nunca uma pergunta de simples recall/definição.
10. `## Key takeaways` — 2 a 4 bullets curtos, o resumo mínimo.
11. `## Referencias` — lista numerada, pelo menos a citação do Russell & Norvig (AIMA).

## 8. Princípio anti-redundância

Cada mecanismo é explicado em exatamente **um** lugar. Ordem de preferência: annotation (mais próxima do código) > frase curta de prosa > nunca duplicar em dois lugares diferentes. Sinais de que há redundância a remover:
- Um `<details>` explicando algo que a docstring ou uma annotation já cobrem.
- Uma célula recalculando algo que uma célula anterior já calculou (reaproveite a variável, ex. `resultado_bfs` já calculado, em vez de rodar a busca de novo numa "Simulação do Agente").
- Uma função wrapper cujo único papel é chamar outra função uma vez, sem agregar comportamento (isso foi removido — `agent_simulation` existia só para reformatar o retorno de uma busca).

## 9. Sem resíduo de conversão do Colab

Remova `#| colab: {...}`, `#| executionInfo: {...}`, `#| cellView: form`, `# @title ...` — são artefatos da conversão original de notebooks Colab e não têm valor didático. `%%capture` só se realmente for necessário suprimir saída de instalação/import.

## 10. Idioma

Prosa, comentários, rótulos de `print` e nomes de seção em português. Identificadores de código (funções, variáveis) em inglês, seguindo a terminologia padrão de IA (`frontier`, `visited`, `breadth_first_search`) — é a convenção já dominante no repositório.

## Checklist rápido ao aplicar este skill a um capítulo

- [ ] Nenhuma classe; tudo é função sobre `dict`/`list`.
- [ ] Estado de busca representado como caminho (lista), não como `Node`.
- [ ] Mesma assinatura e mesmos nomes de variável em todas as funções de busca do capítulo.
- [ ] Nenhuma variável global/closure carregando estado entre células.
- [ ] Toda função tem docstring de uma linha.
- [ ] Blocos de código com linha em branco no início/fim (exceto célula com `%%capture`).
- [ ] Explicações como code annotation em pontos estratégicos, não `<details>` linha a linha.
- [ ] Objetivos de Aprendizagem em lista plana e sincronizados com o conteúdo real.
- [ ] Ambiente concreto mostrado antes das funções auxiliares.
- [ ] Desafios com `pass` real e, se houver, bloco "Dicas" em ```python não executável.
- [ ] Perguntas para reflexão: menos de 5, exigindo síntese.
- [ ] Sem tags `#| colab`/`#| executionInfo`/`# @title` remanescentes.
