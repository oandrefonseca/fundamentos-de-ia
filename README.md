# Introdução à Inteligência Artificial — IMD3001

Apostila de apoio construída como um site de páginas com [Quarto](https://quarto.org/), a partir dos laboratórios da disciplina.

## Estrutura

- `capitulos/`: laboratórios em Quarto Markdown (`.qmd`), fonte editorial oficial de cada tutorial;
- `apendices/`: conteúdos complementares (mesmo formato dos capítulos);
- `index.qmd`, `apresentacao.qmd`: páginas institucionais do site;
- `_quarto.yml`: estrutura, navegação e configuração do site;
- `styles.css`: identidade visual (cores, banner, blocos `<details>`);
- `old/`: notebooks `.ipynb` originais (Colab), material histórico não publicado — ignorado pelo git.

Cada capítulo declara `format: {html: default, ipynb: default}` no front matter, então o Quarto gera automaticamente, além da página HTML, um `.ipynb` equivalente com o mesmo conteúdo — é esse arquivo que aparece como link de download ("Baixar notebook") em cada tutorial publicado. O arquivo `capitulos/_metadata.yml` (espelhado em `apendices/_metadata.yml`) só contém `format-links: [ipynb]`, que habilita esse botão.

## Renderização e publicação

A execução dos laboratórios e a publicação do site acontecem **inteiramente no GitHub Actions** (`.github/workflows/publish.yml`), a cada push em `main`: o workflow instala Quarto, Python, as dependências de sistema (`graphviz`, `graphviz-dev`, `libcairo2-dev`) e os pacotes de `requirements.txt`, executa os notebooks e publica `_site/` na branch `gh-pages`. Não é preciso instalar nada localmente nem rodar a renderização na sua máquina para publicar — basta editar o `.qmd` e dar push.

É preciso configurar, uma única vez, em **Settings → Pages** do repositório no GitHub, a fonte de deploy como a branch `gh-pages`.

Os capítulos **09 (Naive Bayes)** e **10 (Redes Bayesianas)** têm `execute: {enabled: false}` no próprio front matter e exibem um aviso no início da página: eles dependem de datasets externos (`email_dataset.csv` e `heart.csv`, respectivamente) que não fazem parte do repositório. Assim que esses arquivos forem adicionados, remova o `execute: {enabled: false}` do capítulo correspondente.

### Rodando localmente (opcional)

Só é necessário se você quiser conferir um capítulo com outputs reais antes de dar push. Como o projeto usa `execute: {enabled: true, freeze: true}`, um `quarto preview`/`quarto render` local vai tentar executar o código Python da página que estiver sendo aberta:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
sudo apt-get install graphviz graphviz-dev  # necessário para pygraphviz (cap. 10)
./scripts/renderizar-site.sh                # ou: quarto preview
```

Todo o resultado dessa renderização local (`.venv/`, `_site/`, `_freeze/`, `.quarto/`, e os artefatos que o Quarto deposita ao lado dos `.qmd` como `capitulos/*_files/`) é ignorado pelo git — não precisa (e não deve) ser commitado.

## Atualizar um capítulo

Edite o `.qmd` correspondente em `capitulos/` ou `apendices/` diretamente — ele é a fonte oficial do tutorial. Não é necessário (nem recomendado) editar o `.ipynb` gerado, já que ele é reconstruído a cada renderização a partir do `.qmd`.
