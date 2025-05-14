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

#pagebreak()

#outline(target: selector(heading).before(heading.where(body: [Appendix])))

*Figurlista*

- Fig. 1: Inspirationsbild s. 4

- Fig. 2: Blockschema s. 5

- Fig. 3: Schema för LCD HD44780 s. 9

- Fig. 4: Processor <> SPI diagram s. 10

- Fig. 5: SPI-kommunikation vid DAMatrix-kontakten s. 10

- Fig. 6: Schema för högtalare & IR-sändare s. 12

- Fig. 7: Bild av spelet, grafiskt renderat på skärmen s. 16

= Översikt

Syftet med denna rapport är att redogöra för utvecklingen av ett spel som har implementerats inom ramen för kursen Mikrodatorprojekt, TSIU51. Rapporten innehåller en beskrivning av spelets funktion och syfte, en genomgång av de komponenter som har använts samt en övergripande presentation av den programlogik som ligger till grund för spelets funktionalitet.

== Beskrivning av spel

Denna rapport beskriver hur ett sidskrollande spel konstruerades. Spelet använder sig av en OLED-display (ssd1309) som spelplan, LCD-display för att skriva ut spelmeny samt två tryckknappar för att hoppa och ducka. Spelet går ut på att försöka undvika de hinder som kommer och överleva så långt som möjligt. Vid en kollision med hinder kommer ett ljud ut från högtalarna och spelaren får sitt resultat utskrivet och möjligheten att börja om spelet från början.

=== Bakgrund

Vid uppstarten av projektet hölls ett möte med mål att fundera ut vilken sorts spel vi skulle försöka skapa. Många olika förslag framfördes men det slutade med att gruppen enades om att skapa ett sidskrollande spel som skulle likna Googles Dinosuar Game vilket visas i figur 1. Gruppens tanke var att försöka göra en kopia av spelet med given hårdvara. Svårighetsgrad och implementeringen var inget som gruppen tänkte särskilt mycket på utan idén var det viktiga för oss. Efter detta började vi diskutera val av hårdvara samt skall-krav med examinator och handledare.

#figure(
  image("images/chrome.png", width: 80%),
  caption: [_En bild på Googles Dinosaur game som var inspirationskällan till vårt projekt. Dinosaurien springer längs planen och målet är att undvika kaktusar genom att hoppa eller ducka. _ ],
)

=== Uppdelning av arbetet

Vid starten av projektet delades arbetet upp i två grupper. Fokuset låg på att intiera de två displayer som projektet använde sig av. Anledningen för detta var att gruppen trodde att detta skulle vara en stor del av arbetet. När sedan displayerna var korrekt initierade arbetade båda grupperna med lättförståeliga kodfunktioner till vardera display. Anledningen för detta var att hela gruppen skulle kunna arbeta med båda displayerna. Efter detta integrerade vi våra respektive koder i en gemensam fil, vilket gjorde att den delade filen blev sammanhängande och använde samma TWI-kod. Slutligen arbetade hela gruppen med resterande delar i spelet, dess funktioner och logik.

== Blockschema

I figur 2 visas ett blockschema över de komponenter som används i projektet, och en översiktlig bild av deras interna kommunikation med varandra.  I nästa avsnitt beskrivs varje komponent för sig.

#figure(
  image("images/blockschema.png", width: 90%),
  caption: [_Blockschema som visar de olika komponenterna som används i projektet, och hur den interna kommunikationen sker mellan dem. Processorn läser in data från tryckknapparna, behandlar dem och skickar sedan ut till LCD HD44780, SSD1309, och högtalaren._],
)

== Kravspecifikation

Vid starten av projektet bestämdes vissa krav på spelets funktionalitet. Dessa krav delades in i Skall-krav samt utökade krav. Skall-kraven var funktioner som var nödvändiga att implementera i spelet. De utökade kraven kunde implementeras vid mån av tid men inte nödvändigt för projektet. Alla skall-krav implementerades, däremot implementerades inte de utökade kraven. Dessa krav redovisas i kravspecifikationen som följer nedan.

#linebreak()
Skall-krav:
+ Animerad figur och en spelplan som scrollar åt höger under spelets gång. Detta skall renderas på den grafiska displayen. 
+ Den högra tryckknappen skall få spelarens figur att hoppa.
+ Den vänstra tryckknappen skall få spelarens figur att ducka.
+ Poängsystem som uppdateras i realtid och skrivs ut på textdisplayen.
+ Spelmeny på textdisplayen för att starta spelet samt visa grundläggande info. 
+ Ljudeffekt när man förlorar.

#linebreak()
Utökade krav:
+ Spara tidigare omgångar och ha möjlighet att visa upp dem efteråt, lämpligen på 47C16.
+ Mer ingående ljudeffekter under spelet samt vid start av spelet.

= Projektets delar

I detta projekt har det använts en LCD-display HD4480, en OLED-display ssd1309, en ATmega16A-processor, en ljud-enhet i form av en piezoelektrisk högtalare samt två tryckknappar. Dessa komponenter är monterade på ett DAvid-kort. I denna del av rapporten fokuserar vi på att beskriva de olika delar och förklara hårdvarans funktioner och hur de användes i projektet.

== DAvid-kort

I detta projekt har ett DAvid-kort använts. Detta är ett kort som är utvecklat och framtaget av Linköpings universitet för kursen mikrodatorprojekt (TSIU51). Kortet är utrustat med en mängd olika ingångs- och utgångs-komponenter vilket möjliggör enkel mjukvaruutveckling på en låg nivå. I den ursprungliga versionen av DAvid-kortet användes en Arduino Uno med en ATmega328p processor. Denna ersattes sedan av processorkortet Dart, som bygger på ATmega16. Då tidigare versionen blev mer begränsad under mer avancerade projekt. Dart erbjuder fler funktioner och mer avancerad felsökning med hjälp av JTAG.

== Processor ATmega16A

Atmega16A är hjärnan på DAvid-kortet och styr alla ingångs- och utgångs-komponenter, via sina I/O-pinnar eller TWI (IC2). Den är utrustad med ett 16 kb flashminne för lagring av programkod, 1 kb SRAM för variabelhantering under körning samt 512 byte EEPROM för permanent lagring på processorn.

Atmega16A ingår i AVR-familjen vilket innebär att det är en 8-bitars mikrokontroller, vilket innebär att den hanterar och arbetar med data 8 bitar (1 byte) åt gången.

== TWI (I2C)

TWI (Two Wire Interface) är ett kommunikationsprotokoll som möjliggör dataöverföring mellan en master (en mikrokontroller) och en eller flera slavenheter (skärmar m.m). Det är mastern som initierar transaktionerna med slavenheterna, där mastern först adresserar slavenheten och därefter begär antingen en skrivning eller läsning från slavenheten.

TWI-bussen använder endast två ledare SDA (data) och SCL (klockan). SDA används för att skicka och ta emot data. De är själva överföringen av data och är i vilande tillstånd hög. SCL är klocksignaler som masterenheten genererar. Dessa signaler styr tempot i dataöverföringen, där endast data får ändras vid fallande flank på SCL och läses av vid stigande flank.

En transaktion på TWI-bussen inleds alltid av masterenheten. Mastern skickar en startsignal vilket innebär att SDA går lågt medan SCL fortfarande är hög. Därefter skickar master-enheten en 7-bitars adress som motsvarar en av slavenheternas adress, följt av en R/W-bit. Därefter kommer en ack-bit som visar att denna del av transaktionen är klar. Därefter kommer dataöverföringen, beroende på R/W biten skickas data eller tas de emot data. Data skickas och tas emot med en sekvens av en byte, där varje byte följs av en ack bit. När hela transaktionen sedan är färdig skickar mastern en stoppsignal med hjälp av SDA och SCL, vilket frigör TWI-bussen för nya transaktioner.

== LCD HD4480 (textdisplay)

Denna display är en LCD-display vilket betyder att det är en “Liquid Crystal Display”. De betyder att den har ett lager av flytande kristaller som kan ändra hur ljus passerar genom dem med hjälp av elektrisk spänning, så pixlar blir ljus/ mörka.

#figure(
  image("images/hd44780-schematic.png", width: 100%),
  caption: [_Kopplingsschema för en LCD HD44780 16x2-display (till höger), styrd via I2C med en PCF8574T I/O-expander (till vänster)._],
)

Displayen är en alfanumerisk display som har 2 rader med 16 tecken på vardera rad. Varje teckenkolumn består av 5x8 pixlar.  I displayen finns det ett DDRAM och en CGROM. I DDRAM sparas adressen som ett tecken skrivs ut på skärmen och CGROM är ett inbyggt minne i displayen som har färdiga tecken lagrade som pixelmönster som kan skriva ut på displayen.

För att få en utskrift på displayen behövs det en initiering. Där får man möjlighet att använda 4 eller 8 bitars mode, antalet rader man vill använda och om bakgrundsbelysningen ska vara på eller av med mera. Dessutom kan man välja om man vill skriva till specifika platser på displayen eller om man vill göra en utskrift från vänster till höger. 

== SSD1309 (grafisk display)

En drivkrets av typ SSD1309 kopplat till en monokrom OLED-panel med upplösning på 128x64. Det är på denna display som spelets grafik finns.

#figure(
  image("damatrix-cpu-schematic.png", width: 50%),
  caption: [_PB4..PB7 för SPI som går ut mot DAMatrix-kontakten från processorn._],
)

Drivkretsen är kopplad till DAvid-kortet med en DAMatrix-kontakt och likt DAMatrix så styrs den från processorn med 4-pin SPI. Den har ett internt GDDRAM av storlek 1 KiB, en bit för varje pixel. Detta GDDRAM skrivs via kommandon skickade över SPI och på detta vis uppdateras innehållet på skärmen kontinuerligt.

#figure(
  image("damatrix-connector-schematic.png", width: 50%),
  caption: [_Pindiagram för hur SPI-kommunikation sköts över pinnarna på DAMatrix-kontakten._],
)

Innan något kan visas måste drivkretsen först startas och konfigureras. Drivkretsen har ett extremt avancerat kommandosystem för att möjliggöra avancerad användning. Vi har i detta projekt valt att inte använda något förutom de simplaste funktionerna, då annat skulle kräva tid som vi ej hade.

I stora drag skickas 18 olika kommandon, 8 bitar vardera till drivkretsen för att initiera och konfigurera den. Dessa kommandon återfinns nedan. Dess exakta funktion kan återfinnas i databladet för SSD1309. Direkt efter detta börjar displayen visa vad som finns i dess interna minne och vårt spel riktar sitt fokus till att uppdatera detta kontinuerligt från SRAM.

```asm
INIT_PARAMS: .db $81,$ff,$a4,$20,$00,$a6,$d9,$f1,$af,$2e,$a1,$40,$d3,$00,$d5,$80,$c8,$e3
.equ INIT_PARAMS_LEN = 18
```

== Tryckknappar L/R

På DAvid kortet finns 6 tryckknappar. 3 till vänster (L1, L, L2) och till höger (R1, R, R2). Knapparna L1, L2, R1 och R2 nås via en I/O-expander IC5. Medan L och R är direkt kopplade till processorns I/O pinnar och nås via PD1 och PD0. Knapparna är avstudsade och är i vilande läge höga, samt i tryckläge låga.

== Högtalare

Kortet är utrustat med en piezoelektrisk högtalare, som fungerar enligt den piezoelektriska effekten – ett fysikaliskt fenomen där vissa material deformeras och alstrar ljudvågor när en elektrisk växelspänning appliceras. Denna typ av högtalare är särskilt effektiv vid höga frekvenser och har högst verkningsgrad i området 3000–4000 Hz. Även andra hörbara frekvenser kan återges, men med minskad effektivitet.

#figure(
  image("images/speaker-schematic.png", width: 50%),
  caption: [_Kopplingsschema för högtalare & IR-sändare._],
)

Ljudstyrkan regleras med en potentiometer som gör det möjligt att ställa volymen från full styrka ned till helt tyst läge. Högtalaren kan dessutom kopplas bort helt genom att ta bort byglingen på jumpern *SPEAKER JP*.

Eftersom högtalaren är passiv kräver den ingen separat matningsspänning; den drivs enbart av en signal från port *PB1* på mikrokontrollern. Notera att denna utgång även delas med IR-sändaren, vilket innebär att dessa två komponenter inte kan användas oberoende av varandra. Deras samverkan måste alltså hanteras i mjukvara eller hårdvara. 

= Beskrivning av programvara

== Control flow

Bortsett från den minimala kod som krävs för att initiera processorn och annan hårdvara, så omfamnas all logik i kodbasen av en *Game Loop* som på en abstraherad nivå ser till att nödvänliga funktioner alltid sker i en enkel ordning. Det är en oändlig loop som börjar direkt efter initeringen. Programmet stannar kvar i denna loop tills processorn återställs eller tappar ström.

#linebreak()
Dessa steg är:
- Inläsning samt hantering av inputs (dvs knapptryck) från hårdvara
- Simulering av fysik såsom gravitation och acceleration
- Flytt av spelaren framåt längs spelbanan
- Procedurell generation av nästkommande del av spelbanan
- Loopa över alla saker som skulle kunna vara inom spelarens syn, och beräkna vilka pixlar på skärmen som skall tändas i VRAM
- Överför VRAM över SPI till SSD1309s interna GDDRAM
- Testa om spelaren kolliderar med ett hinder och har förlorat

```asm
game_update:
	call update_player
	call update_player_input
	call step_cacti
	call clear_vram
	call draw_frame
	call write_frame
	...
	call test_death
	ret
```

== Rendering

För att förenkla överföring av VRAM till SSD1309ans GDDRAM så efterliknar strukturen av data i VRAM det som krävs av displayen. Det är en array av 768 bytes, där varje byte representerar en vertikal kolumn av 8 pixlar. Den första byten innehåller datan för kolumnen på plats (0, 0) på skärmen, högst upp till vänster. Nästkommande byte representerar kolumnen ett steg till höger; detta repeterar 128 gånger då högra sidan på skärmen är nådd. Därefter forsätter detta för kolumnerna 8 pixlar nedåt, nästa rad på skärmen.

Proceduren för att rendera ett objekt, exempelvis spelaren, blir därför att loopa över varje pixel som ska tändas och pixelns (x, y)-koordinat. För varje pixel anropas en funktion `light_pixel` med koordinaterna som argument. Denna funktion ansvarar för att kalkylera vilken byte i VRAM pixeln tillhör, samt positionen av biten inuti byten (0..7). När den aktuella positionen i VRAM är funnen så används en bitmask samt en or-instruktion för att sätta biten till 1.

```asm
; x/y i r16/r17
light_pixel:
	mov r23, r17
	asr r17
	asr r17
	asr r17
	ldi r18, 5
	sub r18, r17
	LDIW Z, VRAM
light_pixel_loop:
	ldi r19, 128
	add ZL, r19
	ldi r19, 0
	adc ZH, r19
	dec r18
	brne light_pixel_loop
  ;---
	add ZL, r16
	ldi r20, 0
	adc ZH, r20
	;---
	ld r21, Z
	andi r23, 0b0000_0111
	;---
	ldi r22, 0b1000_0000
light_pixel_shift_loop:
	cpi r23, 0
	breq light_pixel_end
	lsr r22
	dec r23
	rjmp light_pixel_shift_loop
light_pixel_end:
	or r21, r22
	st Z, r21
	ret
```

Spelarens figur i sitt normaltillstånd utgörs av en 5x5 kub av tända pixlar och renderas således utav följande kod:

```asm
draw_cube_1:
	ldi r16, POS_X
	lds r17, POS_Y
	ldi YL, 5
	sbis PIND, 1
	ldi YL, 3
	ldi r25, 5
in2:
	mov r24, YL
in1:
	push r16
	push r17
	rcall light_pixel
	pop r17
	pop r16
	subi r17, -1
	dec r24
	brne in1
	subi r16, -1
	sub r17, YL
	dec r25
	brne in2
	ret
```

#linebreak()
Denna renderingsprocedur repeteras för varje distinkt objekt som ska visas, under normala omständigheter är dessa följande:
- Himmel, ovan spelaren
- Mark, under spelaren
- Spelarens figur
- Alla befintliga hinder, dessa lagras i en lista på 128 bitar, en bit för varje x-position på skärmen

#figure(
  image("images/render.png", width: 60%),
  caption: [_En frame, renderad och visad på OLED skärmen._],
)

= Diskussion

== Misstag under projektet

Vid starten av utvecklingen så hade vi stora problem med initieringen av de båda skärmarna. Flera veckor av projekttiden spenderades utan att några framsteg togs. Vi fick sedan hjälp av vår handledare som gjorde att större framsteg kunde tas.

Vid starten av projektet kämpade även gruppen med hårdvara som var defekt. Det var vår display SSD1309 som vi fick från början som inte fungerade. Effekten av detta var att vi satt i många timmar utan att något fungerade. Vi fick sedan hjälp av handledaren med att felsöka med logikanalysator. Efter detta felsökande konstaterade vi att Oled displayen var defekt och vi fick en ny som vi använde under projektets gång.

Ett annat misstag som vi stötte på under projektets gång var att animera en dinosaurie på en 128 x 64 pixels skärm var väsentligt mer komplicerat än vad vi hade kunnat förvänta oss. Detta blev ett avgörande val för vår utveckling då vi hade lyckats skapa en punkt som hoppade och hinder. Efter en tids arbete utan större framgång så diskuterade gruppen med examinatorn om det var möjligt att skapa ett annat objekt som spelare i stället för dinosaurien vilket vi fick audiens för.

== Förslag till förbättringar

Några förbättringar som vi under projektet kunde ha innefattar just de utökade kraven. Att skapa en lista med alla ”high-score” hade gjort det möjligt för spelaren att tävla mot sig själv samt andra på ett mer sofistikerat sätt. Då hade till exempel spelaren själv inte behövt komma ihåg sin egen score och kan lätt se vem som har lyckats bäst och sprungit längst.  

En annan förbättring hade varit att skapa mer ingående ljudeffekter. Specifikt att kunna ha ljud samtidigt som man är inne i spelet. När vi skapade ljudeffekterna när spelaren kolliderar med ett hinder var det endast simpla ljudeffekter. Vid mer tid hade vi kunnat skapa olika ljud för spel-loopen, hoppljud och duckljud. Vi ansåg rätt så snabbt när spelet skapades att våra skall-krav var rätt så avancerade. Effekten av detta var att när skall-kraven var implementerade så kände gruppen sig rätt så nöjda med projektet.

== Gruppsamarbete och tidsplan

 Emellertid, så kan vi fastställa att samarbetet i gruppen fungerade mycket väl. Dessutom så lyckades vi precis följa den tidsplan som vi tidigt skapade. Alla gruppmedlemmar arbetade hårt för att nå önskvärt resultat. Trots de utmaningar som vi mötte under utvecklingen.

= Slutsats

Slutligen kan man konstatera att gruppen är väldigt belåtna med arbetet vi lyckats utföra. Spelet som vi har konstruerat har varit över förväntan. Även fast vi inte hann implementera de utökade kraven så känner vi att slutprodukten är väldigt lik det vi hade tänkt att projektet skulle spegla när vi började att planera i starten av projektet. Det hade varit roligt att kunna implementera en funktion som sparade resultaten och visade upp en lista med de högsta poängen. Vi konstaterade att spelet ändå fungerar mycket väl utan dessa funktioner. Vi är mycket nöjda över hur snabbt spelet går och hur stabilt det fungerar under spelets gång.

= Referenslista

- Josefsson, M. (2025)._ Datorteknik DAvid Hårdvarubeskrivning._ [Internt material]

- Josefsson, M. (2024, 12). _DAvid/Dart principschema_. [Internt material]

- Atmel Corporation. (2002). _ATmega16A datasheet_. [Internt material]

- Solomon Systech Limited. (2011). _SSD1309 datasheet_. [Internt material]

- Hitachi, Ltd. (1999). _HD44780U datasheet_. [Internt material]


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