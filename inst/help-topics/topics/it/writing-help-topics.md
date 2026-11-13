---
id: writing-help-topics
title: Scrivere argomenti di help
type: reference
category: help
keywords: [help, autore, markdown, front matter, argomenti, documentazione]
aliases: []
dialogs: []
commands: [help_parse_front_matter, help_register, help_render]
packages: [RcmdrShiny]
related: [writing-plugins, help-center]
language: it
status: documented
---

# Scrivere argomenti di help

Gli argomenti di help sono file Markdown con un front matter YAML.  Nucleo e
plugin usano lo stesso formato.

## Struttura dei file

```text
inst/help-topics/
├─ index.yml
├─ topics/
│  ├─ mio-argomento.md
│  └─ it/
│     └─ mio-argomento.md
└─ assets/
```

## Front matter

```yaml
---
id: mio-argomento
title: Il mio argomento
type: task
category: statistics
keywords: [parola, sinonimo]
aliases: [nome-breve]
dialogs: [mioDialogo]
commands: [mioComando]
packages: [mioPacchetto]
related: [altro-argomento]
language: it
status: documented
---
```

| Campo | Significato |
|---|---|
| `id` | Identificatore stabile; per i plugin viene prefissato |
| `title` | Mostrato nel catalogo e nei risultati |
| `type` | `concept`, `task`, `reference` o `tutorial` |
| `category` | Deve corrispondere a una categoria di `index.yml` |
| `keywords` | Parole aggiuntive per la ricerca |
| `aliases` | Nomi alternativi accettati da `help_topic()` |
| `dialogs` | Id dei dialoghi che aprono l'argomento |
| `commands` | Funzioni R documentate |
| `related` | Altri argomenti |
| `language` | Codice ISO; predefinito `en` |
| `status` | `documented`, `draft` o `fallback` |

## Regole editoriali

- Il titolo nomina il compito, non la funzione.
- Includere **Cosa fa**, **Come compilarlo** e **Cosa produce**.
- Mostrare il codice R generato in un blocco recintato.
- Collegare gli argomenti con `topic:altro-argomento`.
- Lasciare il file Rd come riferimento tecnico.

## Validare

```bash
Rscript tools/inventory_help.R
Rscript tools/check_help_links.R
```

## Vedi anche

- `topic:writing-plugins`
- `topic:help-center`
