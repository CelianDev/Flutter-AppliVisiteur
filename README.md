# 📱 Flutter Visiteur - Application de Compte-Rendus

> Projet réalisé dans le cadre du **BTS SIO SLAM** en centre d'alternance

## 📋 Description

Application mobile Flutter développée pour la gestion des comptes-rendus de visites médicales. Cette application permet aux visiteurs médicaux de gérer leurs rapports de visite, consulter les informations des praticiens et suivre les médicaments présentés.

## 🎯 Contexte Pédagogique

- **Formation** : BTS SIO (Services Informatiques aux Organisations)
- **Spécialité** : SLAM (Solutions Logicielles et Applications Métier)  
- **Période** : Alternance en centre
- **Technologies** : Flutter, Dart, API REST

## ⚡ Fonctionnalités

- 🔐 **Authentification JWT** sécurisée
- 📊 **Dashboard** avec statistiques
- 👨‍⚕️ **Gestion des praticiens**
- 💊 **Catalogue des médicaments**
- 📝 **Création et gestion des comptes-rendus**
- 🎨 **Interface moderne** avec animations
- 🌙 **Design responsive**

## 🛠️ Technologies Utilisées

### Frontend (Flutter)
- **Flutter SDK** : Framework principal
- **Dart** : Langage de programmation
- **Provider** : Gestion d'état
- **Dio** : Client HTTP pour API REST
- **flutter_secure_storage** : Stockage sécurisé des tokens
- **jwt_decoder** : Gestion des tokens JWT

### UI/UX
- **Google Fonts** : Polices personnalisées
- **Flutter Animate** : Animations fluides
- **Shimmer** : Effets de chargement
- **Timeline Tile** : Interface chronologique
- **Lottie** : Animations vectorielles

## 📁 Structure du Projet

```
lib/
├── src/
│   ├── auth/           # Service d'authentification
│   ├── login/          # Écrans de connexion
│   ├── dashboard/      # Tableau de bord
│   ├── compte-rendus/  # Gestion des rapports
│   │   ├── models/     # Modèles de données
│   │   ├── services/   # Services API
│   │   └── views/      # Interfaces utilisateur
│   ├── menu/           # Navigation
│   └── settings/       # Paramètres
```

## 🚀 Installation

### Prérequis
- Flutter SDK (>=3.3.0)
- Dart SDK
- Android Studio / VS Code
- Git

### Configuration

1. **Cloner le repository**
```bash
git clone [URL_DU_REPO]
cd flutter
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer l'environnement**
```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer le fichier .env avec vos paramètres
# API_URL=votre_url_api
```

4. **Lancer l'application**
```bash
# Debug
flutter run

# Release
flutter run --release
```

## 🏗️ Architecture

### Pattern MVC
- **Models** : Structures de données (Praticien, CompteRendu, etc.)
- **Views** : Interfaces utilisateur Flutter
- **Controllers** : Services de gestion métier

### Services
- `AuthService` : Gestion de l'authentification JWT
- `LoginService` : Service de connexion
- `CompteRendusApiService` : API des comptes-rendus

### Sécurité
- Stockage sécurisé des tokens JWT
- Validation des sessions utilisateur
- Protection des routes API

## 🎓 Compétences Développées

### Techniques
- Développement d'applications mobiles cross-platform
- Intégration d'APIs REST
- Gestion de l'authentification et de la sécurité
- Architecture MVC et bonnes pratiques
- Interface utilisateur moderne et responsive

### Méthodologiques
- Gestion de projet en mode agile
- Versioning avec Git
- Tests et débogage
- Documentation technique

## 🔧 Développement

### Commandes utiles
```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Exécuter les tests
flutter test

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

## 📊 API Backend

L'application communique avec une API REST développée pour ce projet :
- Authentification JWT
- Endpoints sécurisés
- Gestion des praticiens et médicaments
- CRUD des comptes-rendus

## 🤝 Contribution

Ce projet étant un travail d'étudiant, les contributions externes ne sont pas acceptées. Cependant, n'hésitez pas à consulter le code pour inspiration !

## 📄 Licence

Projet à des fins pédagogiques - BTS SIO SLAM

---

**Développé avec ❤️ dans le cadre du BTS SIO SLAM**
