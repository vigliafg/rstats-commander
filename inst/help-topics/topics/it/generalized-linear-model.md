---
id: generalized-linear-model
title: Modello lineare generalizzato
type: task
category: models
keywords: [glm, logistico, poisson, binomiale, link, regressione, devianza]
aliases: []
dialogs: [generalizedLinearModel]
commands: [glm, summary, Anova]
packages: [stats, car]
related: [linear-model, cross-tables]
language: it
status: documented
---

# Modello lineare generalizzato

**Modelli > Modello lineare generalizzato...** stima un modello con una
distribuzione degli errori non normale: regressione logistica per esiti
binari, Poisson per conteggi e le altre famiglie di `glm`.

## Quando usarlo

- La risposta è binaria (0/1, successo/fallimento).
- La risposta è un conteggio.
- La varianza cresce con la media e i minimi quadrati non sono adatti.

## Come compilarlo

1. **Variabile risposta**: fattore binario, numerico 0/1 o conteggio.
2. **Variabili esplicative**: i predittori.
3. **Famiglia**: `binomial` per proporzioni, `poisson` per conteggi,
   `gaussian` per un modello lineare tramite `glm`.
4. **Link**: di solito quello canonico.
5. Premere **OK**.

## Cosa produce

```r
.Model <- glm(esito ~ eta + trattamento, data = Dataset, family = binomial)
summary(.Model)
```

## Leggere l'output

- I coefficienti sono sulla scala del link: per `binomial` sono log-odds,
  quindi `exp(stima)` dà l'odds ratio.
- `Null deviance` e `Residual deviance` svolgono il ruolo della somma dei
  quadrati residui; la differenza verifica il modello contro quello nullo.
- `AIC` confronta modelli non annidati sugli stessi dati.

## Note pratiche

- La separazione — un predittore che predice perfettamente l'esito — produce
  coefficienti e errori standard enormi.
- Per una risposta binaria 0/1, R la tratta come proporzione.

## Vedi anche

- `topic:linear-model`
- `topic:cross-tables`
