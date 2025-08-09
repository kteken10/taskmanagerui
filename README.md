# 📋 Task Manager App

Une application Flutter de gestion de tâches, multilingue et avec support du mode sombre, développée avec **Riverpod** pour la gestion d’état et **Hive** pour le stockage local.

---

## ✨ Fonctionnalités

- **Gestion complète des tâches**
  - Création, modification, suppression
  - Suivi du statut : `NotStarted`, `Started`, `Completed`
  - Définition de dates de début et de fin
  - Priorisation des tâches
  - Réorganisation par glisser-déposer
- **Filtres et recherche**
  - Filtrage par état (Toutes, Non commencées, En cours, Terminées, En retard)
  - Recherche par titre ou description
- **Internationalisation**
  - Anglais 🇬🇧 et Français 🇫🇷
  - Changement de langue à la volée
- **Thèmes**
  - Mode clair 🌞 et mode sombre 🌙
  - Changement en un clic
- **Interface fluide**
  - Animations lors des changements de thème et de langue
  - Liste réorganisable avec animation
- **Stockage local**
  - Persistance des données via **Hive**
  - Sauvegarde automatique après chaque modification

---

## 📂 Structure du projet

```
lib/
│
├── model/
│   └── task.dart          # Modèle de données des tâches + enum TaskStatus
│
├── providers/
│   ├── task_provider.dart   # Gestion de la liste des tâches avec Riverpod
│   ├── theme_provider.dart  # Gestion du thème clair/sombre
│   └── locale_provider.dart # Gestion de la langue
│
├── screens/
│   └── task_list_screen.dart # Écran principal affichant la liste des tâches
│
├── services/
│   └── hive_service.dart   # Gestion du stockage Hive (non inclus ici)
│
├── ui/
│   ├── pulsing_avatar.dart   # Avatar animé (statut en ligne)
│   ├── reorderable_task_list.dart # Liste de tâches réorganisable
│   ├── task_filter.dart      # Barre de filtre + recherche
│   └── add_task_dialog.dart  # Dialog pour ajouter une tâche
│
└── l10n/
    └── app_localizations.dart # Fichiers de localisation
```

---

## 🛠️ Technologies utilisées

- **[Flutter](https://flutter.dev/)**
- **[Riverpod](https://riverpod.dev/)**
- **[Hive](https://docs.hivedb.dev/#/)**
- **[intl](https://pub.dev/packages/intl)** pour la gestion des dates
- **ReorderableListView** pour la réorganisation des tâches
- **Localisation Flutter** pour la gestion multilingue

---

## 🚀 Installation

1. **Cloner le projet**
   ```bash
   git clone https://github.com/kteken10/taskmanagerui
   cd task-manager-app
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Générer les adaptateurs Hive**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Lancer l’application**
   ```bash
   flutter run
   ```

---

## 📖 Utilisation

- Appuyer sur le bouton **+** pour ajouter une nouvelle tâche
- Utiliser la **barre de filtre** pour trier par état
- Cliquer sur l’icône 🌙 / 🌞 pour changer de thème
- Cliquer sur l’icône 🌐 pour changer de langue
- Maintenir et glisser une tâche pour la réorganiser

---

## 📸 Captures d’écran

*(Ajouter ici des captures d’écran de l’application)*

---

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.
