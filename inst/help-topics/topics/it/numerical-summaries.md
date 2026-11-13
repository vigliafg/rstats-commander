---
id: numerical-summaries
title: Riassunti numerici
type: task
category: statistics
keywords: [riassunto, media, mediana, deviazione, quantili, numSummary]
aliases: []
dialogs: [numericalSummaries]
commands: [numSummary]
packages: [RcmdrMisc]
related: [frequency-distributions, correlation]
language: it
status: documented
---

**Statistiche > Riassunti > Riassunti numerici...** descrive le variabili
numeriche con media, deviazione standard, quantili e valori mancanti.

## Quando usarlo

- Per un primo sguardo alla distribuzione di una variabile numerica.
- Per ottenere la stessa tabella separata per un fattore di raggruppamento.
- Per confrontare più variabili affiancate.

## Come compilarlo

1. **Variabili**: selezionare una o più variabili numeriche.
2. **Raggruppa per**: fattore facoltativo che separa la tabella.
3. **Statistiche**: media, deviazione standard, mediana, quantili, asimmetria
   e conteggio dei valori mancanti.
4. **Quantili**: le probabilità da riportare, per esempio `0, .25, .5, .75, 1`.
5. Premere **OK**.

## Cosa produce

```r
numSummary(Dataset[, c("altezza", "peso")],
           statistics = c("mean", "sd", "quantiles", "missing"))
```

Il risultato appare nella scheda **Output**.

## Vedi anche

- `topic:frequency-distributions`
- `topic:histogram`
