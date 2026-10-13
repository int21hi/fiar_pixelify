# Prompt Tehnic: Aplicație Flutter "Four in a Row" (Stil Retro Pixel Art)

---

### Context și Obiectiv
Creează o aplicație completă Flutter (iOS/Android/Web) cu stil retro 8-bit / pixel art, care include o bară de navigare inferioară cu 3 tab-uri. Pagina principală (centru) conține jocul complet funcțional **Four-in-a-Row (Connect Four)**, cu moduri de joc împotriva AI (trei niveluri de dificultate) și împotriva altui jucător local (Pass & Play).

---

### Dependințe și Pachete Necesare (`pubspec.yaml`)
Adaugă următoarele pachete în secțiunea `dependencies`:
- `pixelify_flutter`: pentru efecte de pixelare, containere și stil retro.
- `google_fonts`: pentru fonturi pixelate specifice (de ex. `Press Start 2P`, `VT323`).
- `provider` sau `flutter_riverpod` / `bloc` (la alegere pentru state management; se recomandă `provider` sau `ValueNotifier` pentru simplitate și performanță).
- `audioplayers` (opțional, pentru sunete retro 8-bit la plasarea pieselor).

```yaml
dependencies:
  flutter:
    sdk: flutter
  pixelify_flutter: ^0.0.1 # verifică ultima versiune stabilă
  google_fonts: ^6.2.1
```

---

### 1. Structura Navigării (Bottom Navigation Bar)
Aplicația trebuie să conțină un `Scaffold` cu un `BottomNavigationBar` (stilizat retro cu borduri groase și font pixelat):
- **Tab 1 (Stânga) - Profil / Istoric (Profile / Stats):**
  - Statistici de joc: victorii vs AI (pe nivele), jocuri jucate, rată de câștig.
- **Tab 2 (Mijloc) - Jocul Four-in-a-Row (Main Game):**
  - Grila de joc interactivă (6 rânduri x 7 coloane).
  - Selector mod de joc:
    - **1 vs Player** (Local 2-Player / Pass & Play).
    - **1 vs AI** cu selecție dificultate:
      - `Easy`: Mișcări aleatorii / euristice minime.
      - `Normal`: Minimax de adâncime 2-3 sau blocare directă a victoriei iminente a adversarului.
      - `Hard`: Algoritm Minimax cu Alpha-Beta Pruning (adâncime 4-6) optimizat pentru conectare de 4.
  - Butoane: *Restart*, *Schimbă Modul*, *Undo*.
  - Indicator vizual pentru tura curentă (Jucătorul 1: Roșu / Jucătorul 2/AI: Galben).
- **Tab 3 (Dreapta) - Setări (Settings):**
  - Comutator temă / culori retro.
  - Sunete on/off.
  - Informații despre joc / credite.

---

### 2. Logica Jocului (Inspirat din `imtoori/flutter_fiar`)
Implementează motorul de joc Four-in-a-Row:
- **Dimensiune matrice:** 6 rânduri x 7 coloane (`List<List<int>>` unde 0 = liber, 1 = Jucător 1, 2 = Jucător 2 / AI).
- **Gravitație:** Când utilizatorul atinge o coloană, piesa cade pe cel mai de jos rând disponibil în acea coloană.
- **Verificare Victorie:**
  - Orizontală (4 consecutiv).
  - Verticală (4 consecutiv).
  - Diagonale (în ambele direcții).
  - Egalitate / Remiză (grilă plină fără 4 în linie).
- **Inteligență Artificială (AI Engine):**
  - **Easy:** Alege o coloană validă la întâmplare; dacă AI-ul poate câștiga în mișcarea curentă, alege acea poziție.
  - **Normal:** Verifică mai întâi dacă adversarul are 3 piese aliniate și blochează; altfel, caută să plaseze piese în centrul tablei.
  - **Hard:** Minimax cu Alpha-Beta Pruning:
    - Funcție de evaluare care acordă punctaje favorabile pentru piese centrale, aliniamente de 3 neblocate și aliniamente de 2 deschise;
    - Penalizează mișcările care permit adversarului să câștige imediat în rândul de deasupra.

---

### 3. Integrarea `pixelify_flutter` și Designul UI
- Îmbracă elementele cheie (butoane, piese de joc, panouri de scor și moduri de selecție) folosind widget-urile oferite de `pixelify_flutter` (sau aplică efectul `Pixelify` pe imaginile/texturile pieselor).
- Stilul vizual:
  - Paletă de culori Arcade (fundal închis, contraste neon sau culori clasice 8-bit).
  - Piese de joc cu margini pixelate (roșu pixelat și galben pixelat).
  - Textele din UI să folosească fontul pixelat `GoogleFonts.pressStart2p()`.
  - Animație fluidă de cădere a pieselor menținând aspectul de grilă retro.

---

### 4. Structura de Fișiere Recomandată
```text
lib/
├── main.dart
├── game/
│   ├── ai/
│   │   ├── ai_easy.dart
│   │   ├── ai_normal.dart
│   │   └── ai_minimax.dart
│   ├── game_controller.dart
│   ├── game_state.dart
│   └── board_logic.dart
├── screens/
│   ├── home_screen.dart (Scaffold cu BottomNavigationBar)
│   ├── tabs/
│   │   ├── stats_tab.dart
│   │   ├── game_tab.dart (Tabla de joc 6x7 cu pixelify)
│   │   └── settings_tab.dart
├── widgets/
│   ├── pixel_board.dart
│   ├── pixel_coin.dart
│   └── retro_button.dart
└── theme/
    └── retro_theme.dart
```

---

### 5. Cerințe Funcționale de Ieșire
1. Cod curat, modular, separat pe layere (Logică de joc vs. UI).
2. Fără bug-uri de overflow pe ecrane de diferite dimensiuni (responsivitate pe telefon și tabletă).
3. Feedback vizual clar la victorie (evidențierea celor 4 piese câștigătoare și dialog retro de victorie/înfrângere).