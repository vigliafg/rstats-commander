---
id: keyboard-shortcuts
title: Scorciatoie da tastiera e accessibilità
type: reference
category: help
keywords: [tastiera, scorciatoie, accessibilità, focus, tab, screen reader]
aliases: []
dialogs: []
commands: []
packages: [RcmdrShiny]
related: [help-center, troubleshooting]
language: it
status: documented
---

# Scorciatoie da tastiera e accessibilità

RcmdrShiny è un'applicazione browser, quindi valgono anche le scorciatoie del
browser.

## Navigazione

| Azione | Scorciatoia |
|---|---|
| Controllo successivo | `Tab` |
| Controllo precedente | `Shift` + `Tab` |
| Attivare il pulsante o link con focus | `Invio` o `Spazio` |
| Chiudere un dialogo | `Esc` se consentito, altrimenti **Annulla** |
| Saltare al contenuto principale | `Tab` dall'inizio pagina, poi `Invio` su "Salta al contenuto" |

## Campi dei dialoghi

- Le liste di variabili supportano `Ctrl`+clic e `Shift`+clic.
- **Reimposta** riporta i valori iniziali del dialogo.

## Scheda Help

| Azione | Scorciatoia |
|---|---|
| Portare il focus sulla ricerca | `Tab` fino al campo |
| Aprire il primo risultato | `Invio` nel campo |
| Spostarsi tra le categorie | `Tab` e frecce |

I risultati sono annunciati tramite una regione `aria-live`.

## Funzioni di accessibilità

- Landmark: la sidebar ha `role="navigation"` e l'area contenuti `role="main"`.
- Un link "Salta al contenuto principale" è il primo elemento focalizzabile.
- Il tema scuro mantiene i rapporti di contrasto del tema chiaro.
- Il testo si adatta allo zoom del browser senza rompere il layout.

## Vedi anche

- `topic:help-center`
- `topic:troubleshooting`
