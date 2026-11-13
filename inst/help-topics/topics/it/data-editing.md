---
id: data-editing
title: Modificare e trasformare i dati
type: task
category: data
keywords: [calcolare, ricodificare, rinominare, eliminare, sottoinsieme, trasformare, variabile, fattore]
aliases: []
dialogs: [Compute, RecodeDialog, deleteVariable, renameVariables, subsetDataSet, binVariable, numericToFactor, characterToFactor, reorderFactor, standardize]
commands: [within, Recode, subset, cut, factor, scale]
packages: [RcmdrMisc]
related: [data-import, numerical-summaries]
language: it
status: documented
---

# Modificare e trasformare i dati

Il menu **Dati** offre trasformazioni non distruttive: l'insieme di dati
originale viene sostituito solo dopo la conferma del dialogo, e per ogni
modifica viene scritto il codice R.

## Operazioni comuni

| Operazione | Dove |
|---|---|
| Creare una variabile da un'espressione | **Dati > Gestisci variabili > Calcola nuova variabile...** |
| Ricodificare i valori | **Dati > Gestisci variabili > Ricodifica variabili...** |
| Convertire numerico in fattore | **Dati > Gestisci variabili > Converti variabili numeriche in fattori...** |
| Rinominare variabili | **Dati > Insieme di dati attivo > Rinomina variabili...** |
| Eliminare variabili | **Dati > Gestisci variabili > Elimina variabili...** |
| Tenere un sottoinsieme di righe | **Dati > Insieme di dati attivo > Sottoinsieme...** |
| Raggruppare una variabile numerica | **Dati > Gestisci variabili > Raggruppa variabile numerica...** |
| Standardizzare | **Dati > Gestisci variabili > Standardizza variabili...** |

## Come compilarlo

1. Scegliere l'insieme di dati attivo se il dialogo lo richiede.
2. Selezionare le variabili da modificare.
3. Digitare il nuovo nome o l'espressione; in **Calcola nuova variabile** si
   possono usare le colonne per nome, per esempio `(altezza + peso) / 2`.
4. Per **Ricodifica** definire i valori di partenza e quelli di arrivo.
5. Premere **OK**.

## Cosa produce

```r
Dataset <- within(Dataset, {
  bmi <- peso / (altezza / 100)^2
})
```

oppure, per una ricodifica:

```r
Dataset <- within(Dataset, {
  fasciaEta <- Recode(eta, "'0:17'='bambino'; '18:64'='adulto'; else='anziano'")
})
```

## Suggerimenti

- **Reimposta** riporta i valori iniziali del dialogo; **Annulla** lascia i
  dati invariati.
- Un comando fallito appare nella scheda **Messaggi** e il dialogo resta
  aperto per correggere l'input.
- `topic:data-import` spiega come caricare i dati.

## Vedi anche

- `topic:data-import`
- `topic:exporting-results`
