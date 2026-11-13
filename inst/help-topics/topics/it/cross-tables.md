---
id: cross-tables
title: Tabelle di contingenza e test
type: task
category: statistics
keywords: [contingenza, incrocio, tabella, chiquadro, fisher, due vie, percentuali]
aliases: []
dialogs: [twoWayTable, twoWayTableFromCounts, multiWayTable, enterTable]
commands: [xtabs, chisq.test, fisher.test, rowPercents, colPercents]
packages: [stats, RcmdrMisc]
related: [frequency-distributions, t-tests]
language: it
status: documented
---

# Tabelle di contingenza e test

I dialoghi di contingenza incrociano due o più fattori, stampano percentuali di
riga e di colonna ed eseguono il test chi-quadro o esatto di Fisher.

## Scegliere il dialogo

| Situazione | Dialogo |
|---|---|
| Due fattori nell'insieme di dati attivo | **Statistiche > Tabelle di contingenza > Tabella a due vie...** |
| Conteggi già tabulati | **Statistiche > Tabelle di contingenza > Inserisci e analizza tabella a due vie...** |
| Tre o più fattori | **Statistiche > Tabelle di contingenza > Tabella a più vie...** |

## Come compilarlo

1. **Variabile di riga** e **variabile di colonna**: scegliere due fattori.
2. **Percentuali**: nessuna, di riga, di colonna o sul totale.
3. **Test di ipotesi**: chi-quadro, esatto di Fisher o nessuno.
4. **Conteggi attesi** e **componenti chi-quadro**: output aggiuntivo.
5. Premere **OK**.

## Cosa produce

```r
local({
  .Table <- xtabs(~ gruppo + esito, data = Dataset)
  cat("\nTabella di frequenza:\n")
  print(.Table)
  cat("\nPercentuali di riga:\n")
  print(rowPercents(.Table))
  print(chisq.test(.Table, correct = FALSE))
})
```

## Leggere l'output

- Il test chi-quadro assume conteggi attesi sopra circa cinque in ogni cella.
  Se non è vero, R stampa un avviso ed è più sicuro il test di Fisher.
- Le percentuali di riga rispondono a "quota di ogni riga in ogni colonna"; le
  percentuali di colonna alla domanda inversa.

## Suggerimenti

- Ricodificare insieme le categorie rare prima del test.
- `topic:frequency-distributions` copre i conteggi a una via.

## Vedi anche

- `topic:frequency-distributions`
- `topic:t-tests`
