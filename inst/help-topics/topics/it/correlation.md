---
id: correlation
title: Correlazione
type: task
category: statistics
keywords: [correlazione, pearson, spearman, kendall, matrice, associazione]
aliases: []
dialogs: [correlationMatrix, correlationTest]
commands: [cor, cor.test, rcorr.adjust]
packages: [stats, RcmdrMisc]
related: [scatterplot, linear-model]
language: it
status: documented
---

# Correlazione

Due dialoghi misurano l'associazione tra variabili numeriche: una matrice per
più variabili e un test per una singola coppia.

| Dialogo | Uso |
|---|---|
| **Statistiche > Riassunti > Matrice di correlazione...** | Più variabili, con p-value facoltativi |
| **Statistiche > Riassunti > Test di correlazione...** | Una coppia, con intervallo di confidenza |

## Come compilarlo

1. **Variabili**: almeno due variabili numeriche.
2. **Tipo di correlazione**: Pearson (lineare), Spearman (ranghi) o Kendall.
3. **Ipotesi alternativa** e **livello di confidenza** per il test.
4. **Osservazioni appaiate**: come trattare i valori mancanti.
5. Premere **OK**.

## Cosa produce

```r
rcorr.adjust(Dataset[, c("altezza", "peso")], type = "pearson",
             use = "complete.obs")
```

e, per la coppia singola:

```r
cor.test(Dataset$altezza, Dataset$peso, alternative = "two.sided",
         method = "pearson")
```

## Leggere l'output

- `r` va da -1 a 1; il segno dà la direzione e il valore assoluto la forza.
- La correlazione misura l'associazione lineare: una relazione curva può dare
  `r` piccolo, quindi va sempre affiancata a `topic:scatterplot`.
- Correlazione non implica causalità ed è sensibile agli outlier.

## Vedi anche

- `topic:scatterplot`
- `topic:linear-model`
