---
id: keyboard-shortcuts
title: Keyboard shortcuts and accessibility
type: reference
category: help
keywords: [keyboard, shortcut, accessibility, focus, tab, screen reader]
aliases: [shortcuts, accessibility]
dialogs: []
commands: []
packages: [RcmdrShiny]
related: [help-center, troubleshooting]
language: en
status: documented
---

# Keyboard shortcuts and accessibility

RcmdrShiny is a browser application, so the browser's own shortcuts apply in
addition to the ones listed here.

## Navigation

| Action | Shortcut |
|---|---|
| Move to the next control | `Tab` |
| Move to the previous control | `Shift` + `Tab` |
| Activate the focused button or link | `Enter` or `Space` |
| Close a dialog | `Esc` when the dialog allows it, otherwise **Cancel** |
| Skip to the main content | `Tab` from the top of the page, then `Enter` on "Skip to main content" |

## Dialog fields

- Variable lists support `Ctrl`-click and `Shift`-click for multiple selection.
- `Enter` in a single-line field submits the dialog when the field is the last
  control.
- **Reset** restores the values the dialog had when it opened.

## Help tab

| Action | Shortcut |
|---|---|
| Focus the search box | `Tab` until the box is focused |
| Open the first result | `Enter` in the search box |
| Move between categories | `Tab` and arrow keys |

Search results are announced through an `aria-live` region, and each category
link has a descriptive label.

## Accessibility features

- Landmarks: the sidebar has `role="navigation"` and the content area
  `role="main"`.
- A "Skip to main content" link is the first focusable element.
- Dialog titles are announced by the browser's modal implementation.
- The dark theme keeps the same contrast ratios as the light theme.
- Text scales with the browser zoom without breaking the layout.

## Reporting a problem

If a control cannot be reached with the keyboard, open **Help > Diagnostics**,
copy the report and include it in the issue.

## See also

- `topic:help-center`
- `topic:troubleshooting`
