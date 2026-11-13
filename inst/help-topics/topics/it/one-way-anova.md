---
id: one-way-anova
title: ANOVA a una via
type: task
category: statistics
keywords: [anova, varianza, gruppi, test f, medie, confronti post hoc]
aliases: []
dialogs: [oneWayAnova, multiWayAnova, oneWayRepeatedMeasures]
commands: [aov, Anova, summary]
packages: [stats, car]
related: [t-tests, linear-model]
language: it
status: documented
---

# ANOVA a una via

**Statistiche > Medie > ANOVA a una via...** confronta le medie di due o più
gruppi definiti da un unico fattore.

## Quando usarlo

- Si ha una risposta numerica e una variabile esplicativa categoriale con tre o
  più livelli.
- Si vuole un test F complessivo prima dei confronti a coppie.

## Come compilarlo

1. **Variabile risposta**: l'esito numerico.
2. **Fattore**: la variabile di raggruppamento.
3. **Confronti a coppie**: facoltativamente, i contrasti di Tukey.
4. Premere **OK**.

## Cosa produce

```r
.Anova <- aov(risposta ~ fattore, data = Dataset)
summary(.Anova)
```

Con i confronti a coppie il dialogo aggiunge `TukeyHSD()`; con **ANOVA a più
vie** usa `car::Anova()` e può includere interazioni.

## Leggere l'output

- Le colonne `F value` e `Pr(>F)` verificano che tutte le medie siano uguali.
- Un risultato significativo dice che almeno una media differisce, non quale.

## Assunzioni

- Osservazioni indipendenti e varianze circa uguali.
- Residui approssimativamente normali; **Modelli > Grafici > Grafici
  diagnostici di base** mostra i residui.

## Vedi anche

- `topic:t-tests`
- `topic:linear-model`
