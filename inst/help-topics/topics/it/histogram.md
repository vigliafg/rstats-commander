---
id: histogram
title: Istogramma
type: task
category: graphs
keywords: [istogramma, distribuzione, classi, densità, grafico]
aliases: []
dialogs: [Histogram, DensityPlot, stemAndLeaf]
commands: [Hist, hist, densityPlot]
packages: [RcmdrMisc, graphics]
related: [numerical-summaries, scatterplot]
language: it
status: documented
---

# Istogramma

**Grafici > Istogramma...** mostra la distribuzione di una variabile numerica
con densità, curva normale e raggruppamento opzionali.

## Come compilarlo

1. **Variabile**: una variabile numerica.
2. **Gruppi** (facoltativo): un pannello per livello del fattore.
3. **Numero di classi** o **ampiezza**: controlla la risoluzione.
4. **Scala**: frequenza, densità o percentuale.
5. **Sovrapposizioni**: curva normale, stima di densità, rug plot.
6. Premere **OK**.

## Cosa produce

```r
with(Dataset, Hist(variabile, scale = "frequency", groups = fattore,
                   breaks = "Sturges"))
```

Il grafico appare nella scheda **Grafici**, dove può essere salvato in PNG o PDF.

## Leggere il grafico

- Cercare asimmetria, più mode e outlier prima di scegliere un riassunto o un
  modello.
- Una coda destra lunga suggerisce una trasformazione logaritmica; usare
  **Dati > Gestisci variabili > Calcola nuova variabile...** con `log(x)`.

## Grafici correlati

- **Grafici > Boxplot...** riassume la stessa distribuzione con i quartili.
- **Grafici > Stima di densità...** è un istogramma levigato.
- **Grafici > Diagramma a foglie...** ne dà una versione testuale.

## Vedi anche

- `topic:numerical-summaries`
- `topic:scatterplot`
