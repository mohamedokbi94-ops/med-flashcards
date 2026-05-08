# MedFlashcards — Maladies Infectieuses
## Application Flutter — Guide de Compilation APK

---

## Prérequis

1. **Flutter SDK** ≥ 3.16 — https://docs.flutter.dev/get-started/install
2. **Android Studio** (pour les outils Android SDK)
3. **Java JDK 17** ou supérieur

---

## Installation rapide (Ubuntu/Linux)

```bash
# 1. Télécharger et extraire Flutter
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux_3.24.5-stable.tar.xz

# 2. Ajouter Flutter au PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Installer les dépendances Android SDK (via sdkmanager)
flutter doctor --android-licenses

# 4. Vérifier l'installation
flutter doctor
```

---

## Compilation APK

```bash
# Aller dans le dossier du projet
cd med_flashcards

# Récupérer les dépendances
flutter pub get

# Compiler APK release (optimisé, signé en mode debug)
flutter build apk --release

# L'APK se trouve ici :
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Compilation APK debug (plus rapide)

```bash
flutter build apk --debug
# Fichier : build/app/outputs/flutter-apk/app-debug.apk
```

---

## Installation directe sur Android (via USB)

```bash
# Activer le mode développeur + débogage USB sur votre téléphone
flutter devices          # Lister les appareils connectés
flutter install          # Installer sur l'appareil
```

---

## Structure du projet

```
med_flashcards/
├── lib/
│   ├── main.dart                    # Point d'entrée, navigation bottom bar
│   ├── models/
│   │   └── models.dart              # Flashcard, Course, AntibioticEntry
│   ├── screens/
│   │   ├── home_screen.dart         # Grille des cours
│   │   ├── session_screen.dart      # Session de révision (flip + SM-2)
│   │   └── antibiotic_screen.dart   # Tableau des antibiotiques
│   └── utils/
│       ├── data.dart                # Toutes les données (22 cours, tableau ATB)
│       ├── storage.dart             # Persistance SharedPreferences
│       └── theme.dart               # Couleurs et thème
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml
└── pubspec.yaml
```

---

## Fonctionnalités

### Onglet 1 — Flashcards
- **22 cours** de maladies infectieuses (~120 flashcards)
- **Sélection du cours** par grille avec badge "cartes à réviser"
- **Animation de retournement** 3D à 180° lors du clic
- **Évaluation binaire** : ✓ Je savais / ✗ Je ne savais pas
- **Algorithme SM-2** (SuperMemo 2) : les cartes bien connues reviennent
  dans 1 → 6 → N jours (selon le facteur de facilité). Les cartes
  échouées reviennent le lendemain.
- **Persistance** locale via SharedPreferences (survit aux fermetures d'app)
- **Statistiques de session** : score %, connu/à revoir, cards demain

### Onglet 2 — Tableau Antibiotiques
- **26 maladies** avec : agent causal, ATB 1ère intention, alternative,
  durée, remarques
- **Filtre par catégorie** : Bactériennes / Parasitaires / Virales
- **Recherche** en temps réel (maladie, germe, antibiotique)
- **Fiches dépliables** (accordéon) pour chaque maladie

---

## Algorithme SM-2 (Révision Espacée)

```
Qualité 1 (Je savais) :
  - Répétitions = 0 → intervalle = 1 jour
  - Répétitions = 1 → intervalle = 6 jours
  - Répétitions ≥ 2 → intervalle = ancien_intervalle × facteur_de_facilité
  - Facteur de facilité augmente légèrement

Qualité 0 (Je ne savais pas) :
  - Répétitions remises à 0
  - Intervalle = 1 jour (revient le lendemain)
```

---

## Signature pour publication (optionnel)

Pour publier sur le Play Store, créez un keystore :
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 \
        -validity 10000 -alias medflashcards
```

Puis configurez `android/key.properties` et `android/app/build.gradle`.

---

*Usage pédagogique uniquement — Module Maladies Infectieuses & Tropicales*
