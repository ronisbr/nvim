; Copy of Neovim's built-in `markdown_inline` highlights query with the support for shortcut
; links (`[text]`) removed, since we often use square brackets for units. Notice that this
; file does **not** have the `; extends` modeline, meaning that it replaces the built-in
; query.
;
; Differences w.r.t. the built-in query:
;
;   - The pattern that conceals the square brackets of `shortcut_link` nodes was removed.
;   - The `link_text` of `shortcut_link` nodes is not captured as `@markup.link.label`
;     anymore, avoiding the underline applied by the color scheme.

; From MDeiml/tree-sitter-markdown
(code_span) @markup.raw @nospell

(emphasis) @markup.italic

(strong_emphasis) @markup.strong

(strikethrough) @markup.strikethrough

(shortcut_link
  (link_text) @nospell)

[
  (backslash_escape)
  (hard_line_break)
] @string.escape

; Conceal codeblock and text style markers
([
  (code_span_delimiter)
  (emphasis_delimiter)
] @conceal
  (#set! conceal ""))

; Conceal inline links
(inline_link
  [
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link
  (#set! conceal ""))

[
  (link_label)
  (link_title)
  (image_description)
] @markup.link.label

; `link_text` is only highlighted for real links, i.e. not for `shortcut_link` nodes.
(inline_link
  (link_text) @markup.link.label)

(full_reference_link
  (link_text) @markup.link.label)

(collapsed_reference_link
  (link_text) @markup.link.label)

((inline_link
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

((image
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

; Conceal image links
(image
  [
    "!"
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link
  (#set! conceal ""))

; Conceal full reference links
(full_reference_link
  [
    "["
    "]"
    (link_label)
  ] @markup.link
  (#set! conceal ""))

; Conceal collapsed reference links
(collapsed_reference_link
  [
    "["
    "]"
  ] @markup.link
  (#set! conceal ""))

[
  (link_destination)
  (uri_autolink)
  (email_autolink)
] @markup.link.url @nospell

((uri_autolink) @_url
  (#offset! @_url 0 1 0 -1)
  (#set! @_url url @_url))

(entity_reference) @nospell

; Replace common HTML entities.
((entity_reference) @character.special
  (#eq? @character.special "&nbsp;")
  (#set! conceal " "))

((entity_reference) @character.special
  (#eq? @character.special "&lt;")
  (#set! conceal "<"))

((entity_reference) @character.special
  (#eq? @character.special "&gt;")
  (#set! conceal ">"))

((entity_reference) @character.special
  (#eq? @character.special "&amp;")
  (#set! conceal "&"))

((entity_reference) @character.special
  (#eq? @character.special "&quot;")
  (#set! conceal "\""))

((entity_reference) @character.special
  (#any-of? @character.special "&ensp;" "&emsp;")
  (#set! conceal " "))
