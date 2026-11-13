---
id: plugins
title: Usare i plugin
type: concept
category: plugins
keywords: [plugin, estensione, pacchetto, caricare, menu]
aliases: []
dialogs: [loadPlugins]
commands: [load_plugin, load_plugin_package, list_plugins, unload_plugins]
packages: [RcmdrShiny]
related: [writing-plugins, writing-help-topics]
language: it
status: documented
---

# Usare i plugin

Un plugin è un pacchetto R che aggiunge menu, dialoghi e comandi a RcmdrShiny.
I 15 plugin ufficiali vivono sotto `plugins/` nel repository e sono distribuiti
tramite GitHub.

## Caricare un plugin

Dall'interfaccia: **Strumenti > Carica plugin Rcmdr...**, poi scegliere uno o
più pacchetti installati.

Da R:

```r
RcmdrShiny::run(plugins = c("RcmdrShinyPlugin.Export", "RcmdrShinyPlugin.ROC"))
```

oppure, in una sessione attiva:

```r
RcmdrShiny::load_plugin_package("RcmdrShinyPlugin.Export")
```

## Cosa può aggiungere un plugin

- un menu di primo livello o voci nei menu esistenti;
- dialoghi con validazione e generazione di comandi;
- comandi diretti senza dialogo;
- argomenti di help, mostrati nella scheda **Help** e dal pulsante **Aiuto**
  dei dialoghi.

## Plugin ufficiali

| Plugin | Scopo |
|---|---|
| `Export` | Tabelle LaTeX e HTML |
| `sos` | Ricerca di help e pacchetti R |
| `PcaRobust` | PCA robusta |
| `ROC` | Curve ROC e accuratezza diagnostica |
| `UCA` | Controllo statistico di processo |
| `TeachingDemos` | Dimostrazioni didattiche |
| `KMggplot2` | Grafici con ggplot2 |
| `HH` | Grafici e tabelle HH |
| `TeachStat` | Statistica per l'insegnamento |
| `survival` | Analisi di sopravvivenza |
| `aRnova` | Ausili per l'ANOVA |
| `NMBU` | Strumenti dei corsi NMBU |
| `DoE` | Disegno degli esperimenti |
| `FactoMineR` | Analisi multivariata |
| `EZR` | Flusso clinico EZR |

## Note

- EZR sostituisce i menu del nucleo: caricarlo da solo o per ultimo.
- Un plugin che riusa un id di menu viene fuso con il menu esistente; i
  comandi in conflitto producono un avviso.
- Per scaricare tutto: `RcmdrShiny::unload_plugins()`.

## Vedi anche

- `topic:writing-plugins`
- `topic:writing-help-topics`
