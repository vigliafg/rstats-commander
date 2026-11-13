---
id: help-center
title: Usare il centro assistenza
type: concept
category: help
keywords: [aiuto, ricerca, argomenti, documentazione, guida]
aliases: []
dialogs: []
commands: [help_search, help_topic, help_index]
packages: [RcmdrShiny]
related: [keyboard-shortcuts, writing-help-topics]
language: it
status: documented
---

La scheda **Help** raccoglie gli argomenti del nucleo e dei plugin caricati.
Funziona offline.

## Aprire il centro assistenza

- Fare clic sulla scheda **Help**.
- Usare **Aiuto > Centro assistenza** nella barra laterale.
- Premere **Aiuto** in una finestra di dialogo per aprire l'argomento
  corrispondente.

## Ricerca

Digitare una o più parole.  I risultati sono ordinati in base al punto in cui
compaiono: titolo, parole chiave, alias e nomi dei comandi, corpo del testo.
Anche le parole parziali funzionano: `riass` trova "Riassunti numerici".

## Dalla riga di comando

```r
RcmdrShiny::help_search("regressione logistica")
RcmdrShiny::help_topic("linear-model")
RcmdrShiny::help_index()
```

## Vedi anche

- `topic:keyboard-shortcuts`
- `topic:getting-started`
