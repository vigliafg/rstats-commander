---
id: scatterplot
title: Grafico a dispersione
type: task
category: graphs
keywords: [dispersione, scatter, relazione, xy, smoother, gruppi]
aliases: []
dialogs: [scatterPlot, scatterPlotMatrix, Scatter3D, Xyplot]
commands: [scatterplot, scatterplotMatrix, xyplot, scatter3d]
packages: [car, lattice]
related: [correlation, linear-model]
language: it
status: documented
---

# Grafico a dispersione

**Grafici > Grafico a dispersione...** pone una variabile numerica contro
un'altra e può aggiungere uno smoother, una retta di regressione e gruppi.

## Come compilarlo

1. **Variabile X** e **variabile Y**: le due variabili numeriche.
2. **Raggruppa per** (facoltativo): colora i punti per un fattore.
3. **Smoother**: loess, lineare o nessuno.
4. **Opzioni**: jitter, etichette, span.
5. Premere **OK**.

## Cosa produce

```r
scatterplot(y ~ x | gruppo, data = Dataset, smooth = TRUE)
```

Con `plotly` installato la scheda **Grafici** mostra anche una versione
interattiva con zoom, hover e selezione.

## Leggere il grafico

- Controllare la forma prima di fidarsi di una correlazione: una curva fa
  sottostimare il coefficiente di Pearson.
- Un ventaglio crescente suggerisce eteroschedasticità; una trasformazione
  logaritmica di `y` spesso aiuta.
- I punti lontani dalla nuvola sono candidati per la diagnostica di influenza.

## Varianti

| Dialogo | Uso |
|---|---|
| **Matrice di dispersione** | Più variabili insieme |
| **Grafico 3D** | Tre variabili numeriche, richiede `rgl` |
| **XY conditioning plot** | Pannelli per combinazione di fattori |

## Vedi anche

- `topic:correlation`
- `topic:linear-model`
- `topic:histogram`
