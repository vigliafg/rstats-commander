---
id: troubleshooting
title: Risoluzione dei problemi
type: concept
category: troubleshooting
keywords: [errore, problema, non funziona, debug, messaggi, diagnostica]
aliases: []
dialogs: []
commands: [diagnostics_report]
packages: [RcmdrShiny]
related: [keyboard-shortcuts, plugins]
language: it
status: documented
---

# Risoluzione dei problemi

## I menu sono disattivati

La maggior parte dei comandi richiede un insieme di dati attivo: importarne o
selezionarne uno (`topic:data-import`).  I comandi sui modelli richiedono anche
un modello attivo, creato da un dialogo di stima riuscito.

## Un comando ha prodotto un errore

L'errore appare nella scheda **Messaggi** e, per i dialoghi, in una finestra con
**Riprova**.  Leggere il messaggio: di solito nomina la variabile o l'argomento
che ha fallito.

| Messaggio | Causa |
|---|---|
| `object 'x' not found` | La variabile o l'insieme di dati è stato rinominato o rimosso |
| `contrasts can be applied only to factors with 2 or more levels` | Un fattore ha un solo livello; eliminare i livelli vuoti |
| `NA/NaN/Inf in 'y'` | Valori mancanti in una variabile del modello |
| `there are aliased coefficients in the model` | Predittori collineari |

## Un grafico non appare

I grafici vengono catturati nella scheda **Grafici**.  Se la scheda resta
vuota, controllare **Messaggi**: può mancare un pacchetto grafico, per esempio
`rgl` per i grafici 3D o `ggplot2` per KMggplot2.

## Un plugin non si carica

- Verificare che il pacchetto sia installato: `requireNamespace("RcmdrShinyPlugin.Export")`.
- Controllare la versione: i plugin richiedono `RcmdrShiny (>= 1.1.0)`.
- Leggere gli avvisi stampati al caricamento: nominano le voci saltate.
- EZR sostituisce i menu del nucleo per scelta progettuale.

## Acquisire un report diagnostico

**Aiuto > Diagnostica** raccoglie versione di R, versione di RcmdrShiny, plugin
caricati e messaggi recenti.

```r
RcmdrShiny::diagnostics_report()
```

## Reimpostare la sessione

```r
RcmdrShiny::unload_plugins()
```

e riavviare l'app con una sessione R pulita se lo stato sembra incoerente.

## Vedi anche

- `topic:keyboard-shortcuts`
- `topic:plugins`
