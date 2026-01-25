# NovoAct - Plateforme de gestion des actes de naissance

Application Flutter pour la gestion des actes de naissance - République du Cameroun.

## Configuration Firebase

### Prérequis
- Compte Firebase (https://console.firebase.google.com/)
- Projet Firebase configuré avec Authentication et Firestore

### Configuration Android
Le fichier `google-services.json` est déjà placé dans `android/app/`.

### Configuration iOS
1. Téléchargez le fichier `GoogleService-Info.plist` depuis la console Firebase
2. Placez-le dans `ios/Runner/GoogleService-Info.plist`

### Configuration Web
La configuration Firebase est déjà ajoutée dans `web/index.html`.

### Clés et Sécurité
- Les fichiers de clés Firebase sont ignorés par Git (.gitignore)
- Le fichier `novoact-fa1e1-firebase-adminsdk-fbsvc-7907eca8c4.json` est utilisé côté backend uniquement

## Installation

1. Installez les dépendances :
```bash
flutter pub get
```

2. Configurez Firebase selon les étapes ci-dessus

3. Lancez l'application :
```bash
flutter run
```

## Fonctionnalités
- Authentification utilisateur via Firebase Auth
- Gestion des dossiers d'actes de naissance
- Interface adaptée pour mobile et web

## Technologies
- Flutter
- Firebase (Auth, Firestore)
- Shared Preferences pour le stockage local
