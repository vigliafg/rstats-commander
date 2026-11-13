---
id: writing-help-topics
title: Writing help topics
type: reference
category: help
keywords: [help, authoring, markdown, frontmatter, front matter, topics, documentation]
aliases: [help-authoring, contribute-docs]
dialogs: []
commands: [help_parse_front_matter, help_register, help_render]
packages: [RcmdrShiny]
related: [writing-plugins, help-center]
language: en
status: documented
---

# Writing help topics

Help topics are Markdown files with a YAML front matter.  Both the core and the
plugins use the same format.

## File layout

```text
inst/help/
├─ index.yml
├─ topics/
│  ├─ my-topic.md
│  └─ it/
│     └─ my-topic.md
└─ assets/
```

## Front matter

```yaml
---
id: my-topic
title: My topic
type: task
category: statistics
keywords: [keyword, synonym]
aliases: [short-name]
dialogs: [myDialog]
commands: [myCommand]
packages: [myPackage]
related: [other-topic]
language: en
status: documented
---
```

| Field | Meaning |
|---|---|
| `id` | Stable identifier; for plugins the registry prefixes it |
| `title` | Shown in the catalogue and in search results |
| `type` | `concept`, `task`, `reference` or `tutorial` |
| `category` | Must match a category declared in `index.yml` |
| `keywords` | Extra words for search |
| `aliases` | Alternate names accepted by `help_topic()` |
| `dialogs` | Dialog ids that should open this topic |
| `commands` | R functions the topic documents |
| `related` | Other topic ids |
| `language` | ISO code; defaults to `en` |
| `status` | `documented`, `draft` or `fallback` |

## Manifest entry

```yaml
topics:
  - id: my-topic
    file: topics/my-topic.md
    category: statistics
    order: 40
```

## Editorial rules

- The title names the task, not the function.
- Include **When to use it**, **How to fill it in** and **What it produces**.
- Show the generated R code in a fenced block.
- Link related topics with `topic:other-topic`.
- Keep the Rd file as the technical reference; the topic explains the workflow.

## Validate

```bash
Rscript tools/inventory_help.R
Rscript tools/check_help_links.R
```

`inventory_help.R` reports dialogs without a topic or a declared fallback;
`check_help_links.R` reports broken `topic:` links and missing images.

## Translations

Put translated files under `topics/<language>/` with the same id and
`language: <code>`.  The registry falls back to English when a translation is
missing.

## See also

- `topic:writing-plugins`
- `topic:help-center`
