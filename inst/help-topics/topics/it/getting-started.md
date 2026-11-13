---
id: getting-started
title: La prima analisi
type: tutorial
category: getting-started
keywords: [inizio, prima, tutorial, panoramica, flusso]
aliases: []
dialogs: []
commands: []
packages: [RcmdrShiny]
related: [data-import, numerical-summaries, linear-model]
language: it
status: documented
---

Questa esercitazione segue una sessione completa: caricare i dati, descriverli,
stimare un modello ed esportare i risultati.  Ogni azione scrive codice R
riproducibile nella scheda **Script**.

## 1. Avviare l'applicazione

```r
RcmdrShiny::run()
```

## 2. Caricare i dati

Aprire **Dati > Importa dati > da file di testo, appunti o URL...** e scegliere
un file, oppure usare un insieme di dati già caricato in R.

## 3. Descrivere i dati

- **Statistiche > Riassunti > Insieme di dati attivo** stampa `summary()`.
- **Statistiche > Riassunti > Riassunti numerici...** produce media, deviazione
  standard e conteggi.
- **Statistiche > Riassunti > Distribuzioni di frequenza...** tabula i fattori.

## 4. Stimare un modello

Aprire **Modelli > Modello lineare...**, scegliere la risposta e le variabili
esplicative e premere **OK**.  Il modello diventa il modello attivo.

## 5. Esportare

Aprire **Dati > Insieme di dati attivo > Esporta insieme di dati attivo...**
oppure copiare il codice dalla scheda **Script**.

## Vedi anche

- `topic:data-import`
- `topic:numerical-summaries`
- `topic:linear-model`
