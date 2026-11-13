---
id: frequency-distributions
title: Distribuzioni di frequenza
type: task
category: statistics
keywords: [frequenza, conteggi, tabella, fattore, categoriale, proporzioni, percentuali]
aliases: []
dialogs: [frequencyDistribution]
commands: [table, prop.table, chisq.test]
packages: [stats]
related: [numerical-summaries, cross-tables]
language: it
status: documented
---

# Distribuzioni di frequenza

**Statistiche > Riassunti > Distribuzioni di frequenza...** conta i valori di
un fattore o di una variabile numerica discreta e, se richiesto, confronta i
conteggi con proporzioni attese.

## Quando usarlo

- Si vogliono conteggi e percentuali per una variabile categoriale.
- Si vuole un test chi-quadro di bontà di adattamento.
- Si vogliono controllare livelli vuoti o rari prima di modellare.

## Come compilarlo

1. **Variabili**: scegliere uno o più fattori.
2. **Test delle proporzioni**: attivare il test e digitare le proporzioni
   attese separate da virgole.
3. **Grafici**: richiedere facoltativamente un grafico a barre.
4. Premere **OK**.

## Cosa produce

```r
local({
  .Table <- with(Dataset, table(gruppo))
  cat("\nconteggi:\n")
  print(.Table)
  cat("\npercentuali:\n")
  print(round(100 * .Table / sum(.Table), 2))
})
```

Con il test attivo viene aggiunto un blocco `chisq.test(.Table, p = .Probs)`.

## Suggerimenti

- Un livello vuoto appare con conteggio zero; eliminarlo con
  **Dati > Gestisci variabili > Elimina livelli inutilizzati...**.
- Per tabelle a due vie usare `topic:cross-tables`.

## Vedi anche

- `topic:cross-tables`
- `topic:numerical-summaries`
