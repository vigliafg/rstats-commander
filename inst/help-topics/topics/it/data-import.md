---
id: data-import
title: Importare i dati
type: task
category: data
keywords: [importare, leggere, csv, excel, spss, stata, sas, appunti, url, testo]
aliases: []
dialogs: [readDataSet, importExcel, importSPSS, importSTATA, importSAS, importSASb7dat, importMinitab, readDataFromPackage]
commands: [read.table, readXL, readSPSS, readStata, read.xport, readSAS, read.mtp]
packages: [utils, RcmdrMisc]
related: [data-editing, exporting-results]
language: it
status: documented
---

# Importare i dati

I dialoghi di import leggono un file nella sessione R e lo rendono l'insieme di
dati attivo.  L'import non modifica mai il file su disco.

## Quando usarlo

- Si ha un file di testo separato da virgole, tabulazioni o spazi.
- Si ha un file Excel, SPSS, Stata, SAS o Minitab.
- Si vuole usare un insieme di dati incluso in un pacchetto R installato.

## Scegliere il dialogo

| Sorgente | Voce di menu |
|---|---|
| File di testo, appunti o URL | **Dati > Importa dati > da file di testo, appunti o URL...** |
| Excel | **Dati > Importa dati > da file Excel...** |
| SPSS | **Dati > Importa dati > da insieme di dati SPSS...** |
| Stata | **Dati > Importa dati > da insieme di dati Stata...** |
| SAS | **Dati > Importa dati > da insieme di dati SAS...** |
| Minitab | **Dati > Importa dati > da insieme di dati Minitab...** |
| Pacchetto installato | **Dati > Leggi insieme di dati da un pacchetto allegato...** |

## Come compilarlo

1. Digitare il nome del file oppure usare **Sfoglia**.
2. Impostare separatore, segno decimale e carattere di quoting.
3. Indicare se la prima riga contiene i nomi delle variabili.
4. Scegliere come sono codificati i valori mancanti (`NA`, stringa vuota,
   un codice come `-99`).
5. Assegnare un nome all'insieme di dati.
6. Premere **OK**.

## Cosa produce

```r
Dataset <- read.table("data/survey.csv", header = TRUE, sep = ",",
                      na.strings = "NA")
```

Il nuovo oggetto appare nella scheda **Ambiente** e diventa l'insieme di dati
attivo, quindi le voci di menu che richiedono dati si attivano.

## Suggerimenti

- Le colonne di testo vengono importate come fattori, come fa Rcmdr.
- Usare **Dati > Insieme di dati attivo > Converti variabili di carattere in
  fattori...** se una colonna arriva come testo.
- La directory di lavoro è indicata in **File > Cambia directory di lavoro...**.

## Vedi anche

- `topic:data-editing`
- `topic:exporting-results`
