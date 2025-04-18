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
  title: "Mikrodatorprojekt - Dino Run",

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

#outline(target: selector(heading).before(heading.where(body: [Appendix])))

= Inleding

Syftet med denna rapport är att redogöra för utvecklingen av ett spel som har implementerats inom ramen för kursen Mikrodatorprojekt. Rapporten innehåller en beskrivning av spelets funktion och syfte, en genomgång av de komponenter som har använts samt en övergripande presentation av den programlogik som ligger till grund för spelets funktionalitet.

== Beskrivning av spel

Denna rapport beskriver hur ett ”Side-scroller” spel konstruerades i kursen mikrodatorprojekt TSIU51. Spelet använder sig av en OLED display (ssd1309) som spelplan. LCD för att skriva ut en spelmeny. Två tryckknappar för att kunna hoppa och ducka för hinder. Spelet går ut på att försöka undvika de hinder som kommer och komma så långt som möjligt.  Vid en kollision med hinder så kommer ett ljud ut från högtalarna och spelaren får sitt resultat utskrivet och möjligheten att börja om spelet igen.

=== Bakgrund

Vid uppstart av projektet så hölls ett möte med mål att fundera ut vad för spel som vi ville försöka skapa. Många olika förslag framfördes men det slutade med att gruppen enades om att skapa ett ”side-scroller” spel som skulle likna Googles Dinosuar Game. Gruppens tanke var att försöka göra en kopia av spelet med given hårdvara. Svårighetsgrad och implementeringen var inget som gruppen tänkte särskilt mycket på utan idén var det viktiga för oss. Efter detta började vi diskutera val av hårdvara samt skall-krav med examinator samt handledare.

TODO: infoga bild

=== Uppdelning av arbetet

Vid starten av projektet delades arbetet upp i två grupper. Där vardera grupper började jobba på varsin display. Då detta var något gruppen trodde skulle ta en stor tid av arbetsbelastningen, vilket stämde. När sedan displayerna var i gång och fungerande arbetade båda grupperna med lättförståeliga kodfunktioner till vardera displayen, så hela gruppen kunde arbeta med båda displayerna. Efter detta integrerade vi ihop våra respektive koder i en delad fil, vilket gjorde att den delade filen blev sammanhängande och använde samma TWI-kod. Till sist arbetade hela gruppen åt själva spelet och dess funktioner och logik.

== Blockschema

Nedanstående figur visar ett blockschema över de komponenter som används i projektet, och övergripande bild på deras interna kommunikation med varandra.  I nästa avsnitt beskrivs varje komponent för sig.

TODO: infoga blockschema

== Kravspecifikation

Under projektets start bestämdes vissa krav som fanns på spelets funktionalitet. Skall-kraven var funktioner som var nödvändiga att implementera i spelet. De utökade kraven kunde implementeras vid mån av tid men inget nödvändigt för projektet. Alla skall-krav implementerades, däremot implementerades inte de utökade kraven. Dessa krav redovisas i kravspecifikationen som följer nedan.

Skall-krav:
1. Animerad figur och en spelplan som scrollar åt höger under spelets gång. Detta skall renderas på den grafiska displayen. 
2. Den högra tryckknappen får spelarens figur att hoppa.
3. Den vänstra tryckknappen får spelarens figur att ducka.
4. Poängsystem som uppdateras i realtid och skrivs ut på textdisplayen.
5. Spelmeny på textdisplayen för att starta spelet samt visa grundläggande info. 
6. Ljudeffekt när man förlorar.

Utökade krav:
1. Spara tidigare omgångar och ha möjlighet att visa upp dem efteråt, lämpligen på 47C16.
2. Mer ingående ljudeffekter under spelet samt vid start av spelet.


= Projektets delar

== DAVID-kort

== Processor ATmega16A

== TWI (I2C)

== LCD HD4480 (textdisplay)

== SSD1309 (grafisk display)

== Tryckknappar L/R

== Högtalare

== Spelsimulering

== Rendering

= Beskrivning av programvara

== Control flow

== Interaktion med hårdvara

= Diskussion

#bibliography("refs.bib")

TODO: add references

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