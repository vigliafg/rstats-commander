---
id: t-tests
title: Test t
type: task
category: statistics
keywords: [test t, media, confronto, appaiato, indipendente, welch, ipotesi]
aliases: []
dialogs: [independentSamplesTTest, pairedTTest, singleSampleTTest]
commands: [t.test]
packages: [stats]
related: [one-way-anova, cross-tables]
language: it
status: documented
---

# Test t

Tre dialoghi coprono i test classici sulle medie.

| Domanda | Dialogo |
|---|---|
| La media di una variabile è diversa da un valore? | **Statistiche > Medie > Test t a un campione...** |
| Due gruppi indipendenti differiscono? | **Statistiche > Medie > Test t per campioni indipendenti...** |
| Misure appaiate sono cambiate? | **Statistiche > Medie > Test t per campioni appaiati...** |

## Come compilarlo

1. **Variabili**: scegliere la risposta numerica; per il test appaiato,
   entrambe le misure.
2. **Gruppo** (solo test indipendente): fattore a due livelli.
3. **Ipotesi alternativa**: bidirezionale, minore o maggiore.
4. **Ipotesi nulla**: la media o la differenza tra medie.
5. **Livello di confidenza**: di solito `0.95`.
6. **Varianze uguali**: lasciare disattivato per Welch.
7. Premere **OK**.

## Cosa produce

```r
t.test(risposta ~ gruppo, data = Dataset, alternative = "two.sided",
       conf.level = 0.95, var.equal = FALSE)
```

## Leggere l'output

- `t` è la statistica, `df` i gradi di libertà e `p-value` la probabilità di un
  risultato almeno così estremo sotto l'ipotesi nulla.
- L'intervallo di confidenza riguarda la differenza (o la media).
- Con `var.equal = FALSE` R usa l'approssimazione di Welch.

## Assunzioni

- Osservazioni indipendenti e normalità approssimativa entro i gruppi.
- Per i dati appaiati, le differenze dovrebbero essere normali.
- Usare **Statistiche > Varianze > Test di Levene...** per l'omogeneità e
  **Statistiche > Riassunti > Test di normalità...** per la normalità.

## Vedi anche

- `topic:one-way-anova`
- `topic:frequency-distributions`
