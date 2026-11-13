---
id: linear-model
title: Modello lineare
type: task
category: models
keywords: [lineare, regressione, lm, modello, ols, predittori, diagnostica]
aliases: []
dialogs: [linearModel, linearRegressionModel]
commands: [lm, summary, Anova, vif]
packages: [stats, car]
related: [generalized-linear-model, correlation, one-way-anova]
language: it
status: documented
---

# Modello lineare

**Modelli > Modello lineare...** stima una regressione ai minimi quadrati e
rende il risultato il modello attivo, così i menu dei modelli e i grafici
diagnostici possono usarlo.

## Quando usarlo

- La risposta è numerica e circa continua.
- Si vuole quantificare l'effetto di uno o più predittori aggiustando per gli
  altri.

## Come compilarlo

1. **Variabile risposta**: l'esito numerico.
2. **Variabili esplicative**: uno o più predittori numerici o fattori.
3. **Sottoinsieme**: facoltativamente, un'espressione che restringe il modello.
4. **Interazioni**: richiedere quelle necessarie; il dialogo le scrive con `*`
   o `:`.
5. Premere **OK**.

## Cosa produce

```r
.Model <- lm(risposta ~ predittore1 + predittore2 + fattore1, data = Dataset)
summary(.Model)
```

Il modello appare nella scheda **Ambiente** e diventa attivo, attivando
**Modelli > Test di ipotesi**, **Modelli > Diagnostica numerica** e i grafici.

## Leggere l'output

- `Estimate` è la variazione della risposta per una variazione unitaria del
  predittore, a parità degli altri.
- `Std. Error`, `t value` e `Pr(>|t|)` verificano ogni coefficiente contro zero.
- `Multiple R-squared` è la quota di varianza spiegata.
- Per i fattori il primo livello è il riferimento; cambiarlo con
  **Dati > Gestisci variabili > Riordina livelli del fattore...**.

## Diagnostica

Dopo la stima, **Modelli > Grafici** produce residui vs valori adattati, QQ
plot, scala-location e leverage.

## Vedi anche

- `topic:generalized-linear-model`
- `topic:one-way-anova`
- `topic:correlation`
