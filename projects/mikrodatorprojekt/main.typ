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

#let abstract = [
  Gruppen har implementerat ett spel med realtidsgrafik inspirerat av Dino Run spelet som återfinns i ett easter egg i webbläsaren Google Chrome. Vi redogör för hårdvara, kopplingar, programvara och metoder som använts för att realisera vår idé på ATmega16A, DAvid-kortet och en grafisk OLED-display.
]

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
  format: "review",
)

#outline(target: selector(heading).before(heading.where(body: [Appendix])))

= Översikt

Syftet med denna rapport är att redogöra för utvecklingen av ett spel som har implementerats inom ramen för kursen Mikrodatorprojekt. Rapporten innehåller en beskrivning av spelets funktion och syfte, en genomgång av de komponenter som har använts samt en övergripande presentation av den programlogik som ligger till grund för spelets funktionalitet.

== Beskrivning av spel

Denna rapport beskriver hur ett ”Side-scroller” spel konstruerades i kursen mikrodatorprojekt TSIU51. Spelet använder sig av en OLED display (ssd1309) som spelplan. LCD för att skriva ut en spelmeny. Två tryckknappar för att kunna hoppa och ducka för hinder. Spelet går ut på att försöka undvika de hinder som kommer och komma så långt som möjligt.  Vid en kollision med hinder så kommer ett ljud ut från högtalarna och spelaren får sitt resultat utskrivet och möjligheten att börja om spelet igen.

=== Bakgrund

Vid uppstart av projektet så hölls ett möte med mål att fundera ut vad för spel som vi ville försöka skapa. Många olika förslag framfördes men det slutade med att gruppen enades om att skapa ett ”side-scroller” spel som skulle likna Googles Dinosuar Game. Gruppens tanke var att försöka göra en kopia av spelet med given hårdvara. Svårighetsgrad och implementeringen var inget som gruppen tänkte särskilt mycket på utan idén var det viktiga för oss. Efter detta började vi diskutera val av hårdvara samt skall-krav med examinator samt handledare.

#figure(
  image("images/chrome.png", width: 80%),
  caption: [En bild på Googles Dinosaur game som var inspirationskällan till vårt projekt.],
)

=== Uppdelning av arbetet

Vid starten av projektet delades arbetet upp i två grupper. Där vardera grupper började jobba på varsin display. Då detta var något gruppen trodde skulle ta en stor tid av arbetsbelastningen, vilket stämde. När sedan displayerna var i gång och fungerande arbetade båda grupperna med lättförståeliga kodfunktioner till vardera displayen, så hela gruppen kunde arbeta med båda displayerna. Efter detta integrerade vi ihop våra respektive koder i en delad fil, vilket gjorde att den delade filen blev sammanhängande och använde samma TWI-kod. Till sist arbetade hela gruppen åt själva spelet och dess funktioner och logik.

== Blockschema

Nedanstående figur visar ett blockschema över de komponenter som används i projektet, och övergripande bild på deras interna kommunikation med varandra.  I nästa avsnitt beskrivs varje komponent för sig.

#figure(
  image("images/blockschema.png", width: 90%),
  caption: [Blockschema som visar de olika komponenterna som används i projektet, och hur den interna kommunikationen sker mellan dem. Processorn läser in data från tryckknapparna, behandlar dem och skickar sedan ut till LCD HD44780, SSD1309, och högtalaren.],
)

== Kravspecifikation

Under projektets start bestämdes vissa krav som fanns på spelets funktionalitet. Skall-kraven var funktioner som var nödvändiga att implementera i spelet. De utökade kraven kunde implementeras vid mån av tid men inget nödvändigt för projektet. Alla skall-krav implementerades, däremot implementerades inte de utökade kraven. Dessa krav redovisas i kravspecifikationen som följer nedan.

#linebreak()
Skall-krav:
+ Animerad figur och en spelplan som scrollar åt höger under spelets gång. Detta skall renderas på den grafiska displayen. 
+ Den högra tryckknappen får spelarens figur att hoppa.
+ Den vänstra tryckknappen får spelarens figur att ducka.
+ Poängsystem som uppdateras i realtid och skrivs ut på textdisplayen.
+ Spelmeny på textdisplayen för att starta spelet samt visa grundläggande info. 
+ Ljudeffekt när man förlorar.

#linebreak()
Utökade krav:
+ Spara tidigare omgångar och ha möjlighet att visa upp dem efteråt, lämpligen på 47C16.
+ Mer ingående ljudeffekter under spelet samt vid start av spelet.

= Projektets delar

I detta projekt har det använts en LCD-display HD4480, OLED-display ssd1309, en ATmega16 processor, en ljud-enhet i form av en piezoelektrisk högtalare samt två tryckknappar. Dessa komponenter är monterade på ett DAvid kort. I denna del av rapporten kommer vi gå igenom dessa olika delar och förklara hårdvarans funktioner och hur det användes i projektet.

== DAvid-kort

I detta projekt har ett David-kort använts. Vilket är ett kort som är utvecklat och framtaget av Linköpings universitet för kursen mikrodatorprojekt (TSIU51). Kortet är utrustat med en mängd olika ingångs och utgångs komponenter vilket möjliggör enkel mjukvaruutveckling på en låg nivå. I den ursprungliga versionen av DAvid-kortet användes en Arduino Uno med en ATmega328p processor, men bytes sedan ut mot processorkortet Dart, som bygger på ATmega16. Då tidigare versionen blev mer begränsad under mer avancerade projekt. Dart erbjuder fler funktioner och mer avancerad felsökning med hjälp av JTAG.

== Processor ATmega16A

Atmega16 är hjärnan på DAvid-kortet och styr alla ingångs och utgångs komponenter, med antingen sina I/O-pinnar eller TWI (IC2). Den är utrustad med ett 16 kb flashminne för lagring av programkod, 1 kb SRAM för variabelhantering under körning samt 512 byte EEPROM för permanent lagring på processorn.

Atmega16 ingår i AVR-familjen vilket innebär att det är en 8-bitars mikrokontroller. Att vara en 8-bitars mikrokontroller byter att den hanterar och arbetar med data 8 bitar (1 byte) åt gången.

== TWI (I2C)

TWI (Two Wire Interface) är ett kommunikationsprotokoll som möjliggör dataöverföring mellan en master (en mikrokontroller) och en eller flera slavenheter (skärmar m.m). Det är mastern som initierar transaktionerna med slavenheterna. Där mastern först adresserar slavenheten och därefter begär antingen en skrivning eller läsning från slavenheten.

TWI-bussen använder endast två ledare en SDA (data) och SCL (klockan). SDA används för att skicka och ta emot data, det är själva överföringen av data och är i vilande tillstånd hög. Medan SCL är klocksignaler som masterenheten genererar. Dessa signaler styr tempot i dataöverföringen, där endast data får ändras i fallande flank på SCL och läses av i stigande flank.

En transaktion på TWI-bussen inleds alltid av masterenheten. Där mastern för skickar en startsignal vilket innebär att SDA går lågt medan SCL fortfarande är hög. Därefter skickar master-enheten en 7-bitars adress som motsvarar en av slavenheterna adress. Följt av en R/W-bit. Därefter kommer en ack bit som visar att denna del av transaktionen är klar. Därefter kommer dataöverföringen, där beroende på R/W skickas data eller tas det emot data. Data skickas och tas emot med en sekvens av en byte. Där varje byte följs av en ack bit. När hela transaktionen sedan är färdig skickar mastern en stoppsignal med hjälp av SDA och SCL. Vilket frigör TWI-bussen för nya transaktioner.

== LCD HD4480 (textdisplay)

Denna display är en LCD display vilket betyder att det är en “Liquid Crystal Display”. Som i sin tur betyder att den har ett lager av flytande kristaller som kan ändra hur ljus passerar genom dem med hjälp av elektrisk spänning, så pixlar blir ljus/ mörka.

#figure(
  image("images/hd44780-schematic.png", width: 100%),
  caption: [Kopplingsschema för en LCD HD44780 16x2-display (till höger), styrd via I2C med en PCF8574T I/O-expander (till vänster).],
)

Displayen är en alfanumerisk display som har 2 rader med 16 tecken på vardera rader. Varje teckenkolumn består av 5x8 pixlar.  I displayen finns det ett DDRAM och en CGROM. I DDRAM sparas adressen som ett tecken ska skivas ut på skärmen och CGROM är ett inbyggt minne i displayen som har färdiga tecken lagrade som pixelmönster som kan skriva ut på displayen.

För att få en utskrift på displayen behövs det förs göras en initiering. Där man får välja om man vill arbeta med 4 eller 8 bitars mode, hur många rader man vill använda, om bakgrundsbelysningen ska vara på eller av med mera. Man kan även välja själv om man vill skriva till specifika platser på displayen eller om man vill ha så den skriver från vänster till höger. 

== SSD1309 (grafisk display)

En drivkrets av typ SSD1309 kopplat till en monokrom OLED-panel med upplösning på 128x64. Detta är displayen där själva spelet tar plats.

#figure(
  image("damatrix-cpu-schematic.png", width: 50%),
  caption: [PB4..PB7 för SPI som går ut mot DAMatrix-kontakten från processorn.],
)

Drivkretsen är kopplad till DAvid-kortet med en DAMatrix-kontakt och likt DAMatrix så styrs från processorn med 4-pin SPI. Den har ett internt GDDRAM av storlek 1 KiB, en bit för varje pixel. Detta GDDRAM skrivs via kommandon skickade över SPI och på så vis uppdateras innehållet på skärmen kontinueligt.

#figure(
  image("damatrix-connector-schematic.png", width: 50%),
  caption: [Pindiagram för hur SPI-kommunikation sköts över pinnarna på DAMatrix-kontakten.],
)

Innan något kan visas måste drivkretsen först startas och konfigureras. Drivkretsen har ett extremt advancerat kommandosystem för att möjliggöra advancerad användning. Vi har i detta projekt valt att inte använda något förutom de simplaste funktionerna, då annat skulle kräva tid som vi ej hade.

I stora drag så skickas 18 olika kommandon, 8 bitar vardera till drivkretsen för att initiera och konfigurera den, dessa återfinns nedan. Dess exakta funktion kan återfinnas i databladet för SSD1309. Direkt efter detta början displayen visa vad som finns i dess interna minne och vårt spel riktar sitt fokus till att uppdatera detta kontinuerligt från SRAM.

```asm
INIT_PARAMS: .db $81,$ff,$a4,$20,$00,$a6,$d9,$f1,$af,$2e,$a1,$40,$d3,$00,$d5,$80,$c8,$e3
.equ INIT_PARAMS_LEN = 18
```

== Tryckknappar L/R

På David kortet finns 6 tryckknappar. 3 till vänster (L1, L, L2) och till höger (R1, R, R2). Knapparna L1, L2, R1 och R2 nås via en I/O-expander IC5. Medan L och R är direkt kopplade till processorns I/O pinnar och nås via PD1 och PD0. Knapparna är avstudsade och är i vilande läge höga, samt i tryckläge låga.

== Högtalare

Kortet är utrustat med en piezoelektrisk högtalare, som fungerar enligt den piezoelektriska effekten – ett fysikaliskt fenomen där vissa material deformeras och alstrar ljudvågor när en elektrisk växelspänning appliceras. Denna typ av högtalare är särskilt effektiv vid höga frekvenser och har högst verkningsgrad i området 3000–4000 Hz. Även andra hörbara frekvenser kan återges, men med minskad effektivitet.

#figure(
  image("images/speaker-schematic.png", width: 50%),
  caption: [Kopplingsschema för högtalare & IR-sändare.],
)

Ljudstyrkan regleras med en potentiometer som gör det möjligt att ställa volymen från full styrka ned till helt tyst läge. Högtalaren kan dessutom kopplas bort helt genom att ta bort byglingen på jumpern *SPEAKER JP*.

Eftersom högtalaren är passiv kräver den ingen separat matningsspänning; den drivs enbart av en signal från port *PB1* på mikrokontrollern. Notera att denna utgång även delas med IR-sändaren, vilket innebär att dessa två komponenter inte kan användas oberoende av varandra utan att samverkan hanteras i mjukvara eller hårdvara. 

= Beskrivning av programvara

== Control flow

== Interaktion med hårdvara

== Spelsimulering

== Rendering

= Diskussion

== Misstag under projektet

Vid starten av utvecklingen så hade vi stora problem med initieringen av de båda skärmarna.  Flera veckor av projekttiden spenderades utan att några framsteg togs. Vi fick sedan hjälp av vår handledare som gjorde att större framsteg kunde tas.

Vid starten av projektet kämpade även gruppen med hårdvara som var defekt. Det var den SSD1309 som vi fick från början som inte fungerade. Effekten av detta var att vi satt i många timmar utan att något fungerade. Vi fick sedan hjälp av handledaren med att felsöka med logikanalysator. Efter detta felsökande konstaterade vi att Oled displayen var defekt och vi fick en ny som vi använde under projektets gång.

Ett annat misstag som vi stötte på under projektets gång var att animera en dinosaurie på en 128 x 64 pixels skärm var väsentligt mer komplicerat än vad vi hade kunnat förvänta oss. Detta blev ett avgörande val för vår utveckling då vi hade lyckats skapa en punkt som hoppade och hinder. Efter en tids arbete utan större framgång så diskuterade gruppen med examinatorn om det var möjligt att skapa ett annat objekt som spelare i stället för dinosaurien vilket vi fick audiens för.

== Förslag till förbättringar

Några förbättringar som vi under projektet kunde ha innefattat är just de utökade kraven. Att skapa en lista med alla ”high-score” hade gjort det möjligt för spelaren att tävla mot sig själv samt andra på ett mer sofistikerat sätt. Då hade till exempel spelaren själv inte behövt komma ihåg sin egen score och kan lätt se vem som har lyckats bäst och sprungit längst.  

En annan förbättring hade varit att skapa mer ingående ljudeffekter. Specifikt att kunna ha ljud samtidigt som man är inne i spelet. När vi skapade ljudeffekterna när spelaren kolliderar med ett hinder var det endast simpla ljudeffekter. Vid mer tid hade vi kunnat skapa olika ljud för spel-loopen, hoppljud och duckljud. Vi ansåg rätt så snabbt när spelet skapades att våra skall-krav var rätt så avancerade. Effekten av detta var att när skall-kraven var implementerade så kände gruppen sig rätt så nöjda med projektet.

== Gruppsamarbete och tidsplan

Följaktligen så kan vi fastställa att samarbetet i gruppen fungerade mycket väl. Dessutom så lyckades vi precis följa den tidsplan som vi tidigt skapade. Alla gruppmedlemmar arbetade hårt för att nå önskvärt resultat. Emellertid anser gruppen att val av projekt var en utmaning.

= Slutsats

Slutligen kan man konstatera att gruppen är väldigt belåtna med arbetet vi lyckats utföra. Spelet som vi har konstruerat har varit över förväntan. Även fast vi inte hann implementera de utökade kraven så känner vi att slutprodukten är väldigt lik det vi hade tänkt att projektet skulle spegla när vi började att planera i starten av projektet. Det hade varit roligt att kunna implementera en funktion som sparade resultaten och visade upp en lista med de högsta poängen. Vi konstaterade att spelet ändå fungerar mycket väl utan dessa funktioner. Vi är mycket nöjda över hur snabbt spelet går och hur stabilt det fungerar under spelets gång.

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