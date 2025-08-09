# 📋 Task Manager App

A Flutter task management application, multilingual and with dark mode support, developed using **Riverpod** for state management and **Hive** for local storage.

---

## ✨ Features

- **Complete Task Management**
  - Create, edit, delete tasks
  - Track status: `NotStarted`, `Started`, `Completed`
  - Set start and end dates
  - Task prioritization
  - Drag-and-drop reordering
- **Filters and Search**
  - Filter by status (All, Not Started, In Progress, Completed, Overdue)
  - Search by title or description
- **Internationalization**
  - English 🇬🇧 and French 🇫🇷
  - Switch language instantly
- **Themes**
  - Light 🌞 and dark 🌙 mode
  - One-click theme switching
- **Smooth UI**
  - Animations for theme and language changes
  - Animated reorderable task list
- **Local Storage**
  - Data persistence via **Hive**
  - Automatic save after each change

---

## 📂 Project Structure

```
lib/
│
├── model/
│   └── task.dart          # Task data model + TaskStatus enum
│
├── providers/
│   ├── task_provider.dart   # Task list management with Riverpod
│   ├── theme_provider.dart  # Light/dark theme management
│   └── locale_provider.dart # Language management
│
├── screens/
│   └── task_list_screen.dart # Main screen displaying the task list
│
├── services/
│   └── hive_service.dart   # Hive storage management (not included here)
│
├── ui/
│   ├── pulsing_avatar.dart   # Animated avatar (online status)
│   ├── reorderable_task_list.dart # Reorderable task list
│   ├── task_filter.dart      # Filter bar + search
│   └── add_task_dialog.dart  # Dialog to add a task
│
└── l10n/
    └── app_localizations.dart # Localization files
```

---

## 🛠️ Technologies Used

- **[Flutter](https://flutter.dev/)**
- **[Riverpod](https://riverpod.dev/)**
- **[Hive](https://docs.hivedb.dev/#/)**
- **[intl](https://pub.dev/packages/intl)** for date management
- **ReorderableListView** for task reordering
- **Flutter localization** for multilingual support

---

## 🚀 Installation

1. **Clone the project**
   ```bash
   git clone https://github.com/kteken10/taskmanagerui
   cd task-manager-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

---

## 📖 Usage

- Press the **+** button to add a new task
- Use the **filter bar** to sort by status
- Click the 🌙 / 🌞 icon to switch theme
- Click the 🌐 icon to change language
- Long press and drag a task to reorder

---

## 📸 Screenshots

*(Add screenshots of the application here)*

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.