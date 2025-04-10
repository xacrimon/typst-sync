#import "@preview/elsearticle:0.4.2": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#set text(lang: "se")

#show: codly-init.with()

#codly(languages: codly-languages, zebra-fill: none)

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}

#let abstract = lorem(100)

#show: elsearticle.with(
  title: "Sidescroller på en mikrokontroller",

  authors: (
    (
      name: "J. Wejdenstål",
      affiliation: "Linköpings Universitet",
    ),
    ( name: "K. Westberg" ),
    ( name: "E. Allison" ),
    ( name: "G. Gunnarson", ),
  ),
  abstract: abstract,
  // keywords: ("keyword 1", "keyword 2"),
  format: "review",
  // line-numbering: true,
)

#outline()

= Inleding

```rust
pub fn main() {
    println!("Hello, world!");
}
```

== Blockschema

== Kravspecifikation

= Översikt

== Uppdeling av arbetet

== Komponenternas placering

= Projektets delar

== Processor ATmega16A

== LCD

== SSD1309

== Kontrollknappar

= Kopplingsschema

= Diskussion

#bibliography("refs.bib")

#show: appendix

#outline(target: heading.where(supplement: [Appendix]), title: [Appendix])

= LCD.inc

#raw(read("code/LCD.inc", encoding: "utf8"), block: true, lang: "asm")

= error.asm

#raw(read("code/error.asm", encoding: "utf8"), block: true, lang: "asm")

= functions.inc

#raw(read("code/functions.inc", encoding: "utf8"), block: true, lang: "asm")

= i2c.asm

#raw(read("code/i2c.asm", encoding: "utf8"), block: true, lang: "asm")

= m_util.inc

#raw(read("code/m_util.inc", encoding: "utf8"), block: true, lang: "asm")

= main.asm

#raw(read("code/main.asm", encoding: "utf8"), block: true, lang: "asm")

= psm.asm

#raw(read("code/psm.asm", encoding: "utf8"), block: true, lang: "asm")

= ssd1309.asm

#raw(read("code/ssd1309.asm", encoding: "utf8"), block: true, lang: "asm")