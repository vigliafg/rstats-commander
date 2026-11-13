---
id: converting-character-variables
title: Convertire colonne di testo in fattori
type: task
category: data
keywords: [carattere, stringa, fattore, convertire, categoriale]
aliases: []
dialogs: [characterToFactor]
commands: [factor, as.factor, convertStrings2Factors]
packages: [RcmdrShiny]
related: [data-editing, numericToFactor]
language: it
status: documented
---

# Convertire colonne di testo in fattori

R importa le colonne di testo come vettori di caratteri.  Modelli, tabelle e
grafici trattano i caratteri come fattori nella maggior parte dei casi, ma un
fattore esplicito dà il controllo sull'ordine dei livelli, da cui dipende la
categoria di riferimento di un modello.

## Due modi

| Situazione | Comando |
|---|---|
| Convertire tutte le colonne di testo | **Dati > Insieme di dati attivo > Converti tutte le variabili di carattere in fattori** |
| Scegliere colonne e nuovi nomi | **Dati > Gestisci variabili > Converti variabili di carattere in fattori...** |

Il primo è un comando diretto: scrive un blocco `within()` e lo esegue subito.
Il secondo apre un dialogo in cui si può rinominare il risultato o creare una
copia con un prefisso.

## Cosa produce

```r
Dataset <- within(Dataset, {
  gruppo <- as.factor(gruppo)
})
```

## Perché conta l'ordine dei livelli

`factor()` ordina i livelli alfabeticamente.  In un modello il primo livello è
il riferimento, quindi `controllo` e `trattamento` danno un coefficiente
comprensibile.  Impostare l'ordine con **Dati > Gestisci variabili > Riordina
livelli del fattore...**.

## Quando non convertire

- Identificatori liberi (nomi, numeri di record) restano caratteri.
- Le date vanno lette con `as.Date()`.
- Una colonna numerica importata come testo di solito indica un problema di
  separatore decimale o migliaia: correggere l'import.

## Vedi anche

- `topic:data-editing`
- `topic:data-import`
- `topic:linear-model`
