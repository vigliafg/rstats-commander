---
id: gumbel-distribution
title: Distribuzione di Gumbel
type: task
category: distributions
keywords: [gumbel, valori estremi, massimo, quantili, probabilità, densità, campioni, vgam]
aliases: []
dialogs: [GumbelQuantiles, GumbelProbabilities, GumbelDistributionPlot, GumbelDistributionSamples]
commands: [qgumbel, pgumbel, dgumbel, rgumbel]
packages: [VGAM]
related: [normal-distribution, weibull-distribution]
language: it
status: documented
---

# Distribuzione di Gumbel

La distribuzione di Gumbel modella il massimo (o il minimo) di molte
osservazioni indipendenti: picchi di piena, velocità massime del vento,
precipitazioni estreme, durata dei componenti.  RcmdrShiny la espone con gli
stessi quattro dialoghi delle altre famiglie continue.

## Requisiti

La distribuzione è fornita dal pacchetto **VGAM**.  Se VGAM non è installato le
quattro voci di menu restano nascoste invece di fallire a runtime:

```r
install.packages("VGAM")
```

## Dialoghi disponibili

| Dialogo | Funzione | Uso |
|---|---|---|
| Quantili di Gumbel | `VGAM::qgumbel()` | Valore con una data probabilità cumulata |
| Probabilità di Gumbel | `VGAM::pgumbel()` | Probabilità cumulata di un valore |
| Grafico della distribuzione | `VGAM::dgumbel()` | Densità o funzione di ripartizione |
| Campioni da Gumbel | `VGAM::rgumbel()` | Simulare un insieme di dati |

## Parametri

| Parametro | Significato |
|---|---|
| `location` | Moda della distribuzione; sposta la curva |
| `scale` | Dispersione; deve essere positiva |

La Gumbel standard ha `location = 0` e `scale = 1`.

## Cosa produce

```r
VGAM::qgumbel(c(0.5, 0.9, 0.99), location = 20, scale = 4,
              lower.tail = TRUE)
```

oppure, per un grafico:

```r
curve(VGAM::dgumbel(x, location = 20, scale = 4),
      xlab = "x", ylab = "Densità")
```

## Leggere l'output

- La distribuzione è asimmetrica a destra; la media è `location + 0.5772 * scale`.
- I quantili sopra 0.9 crescono rapidamente: è la coda che conta per i valori
  di progetto.
- Il tempo di ritorno di un valore `x` è `1 / (1 - pgumbel(x))`.

## Vedi anche

- `topic:weibull-distribution`
- `topic:normal-distribution`
- `topic:histogram`
