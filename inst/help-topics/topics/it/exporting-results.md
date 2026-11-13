---
id: exporting-results
title: Esportare dati e risultati
type: task
category: data
keywords: [esportare, salvare, csv, scrivere, output, tabella, script, report]
aliases: []
dialogs: [exportDataSet, saveOptions, loadLog, exportReport]
commands: [write.table, capture.output, xtable]
packages: [utils]
related: [data-import, getting-started]
language: it
status: documented
---

# Esportare dati e risultati

RcmdrShiny può scrivere l'insieme di dati attivo su disco e permette di
copiare o salvare i comandi e l'output della sessione.

## Esportare l'insieme di dati attivo

Aprire **Dati > Insieme di dati attivo > Esporta insieme di dati attivo...**.

1. Scegliere il file di destinazione.
2. Scegliere il separatore (virgola, punto e virgola, tabulazione o spazio).
3. Decidere se scrivere nomi delle variabili, nomi delle righe e virgolette.
4. Indicare la stringa per i valori mancanti, di solito `NA`.
5. Premere **OK**.

```r
write.table(Dataset, "data/clean.csv", sep = ",", col.names = TRUE,
            row.names = FALSE, quote = TRUE, na = "NA")
```

## Esportare output e codice

- La scheda **Script** contiene tutti i comandi generati; i pulsanti
  dell'editor permettono di salvarli come file `.R`.
- La scheda **Output** contiene i risultati stampati.
- **File > Esporta report...** raccoglie script, output e grafici in un
  documento R Markdown (o HTML) scaricabile.

## Report riproducibili

Poiché ogni azione è registrata come codice R, un flusso affidabile è:

1. Lavorare con i dialoghi.
2. Copiare la scheda **Script** in un documento R Markdown.
3. Renderizzare il documento in HTML, PDF o Word.

La vignetta `getting-started` mostra il flusso completo.

## Vedi anche

- `topic:data-import`
- `topic:getting-started`
