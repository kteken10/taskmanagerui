import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'taskList': 'Task List',
      'addTask': 'Add Task',
      'title': 'Title',
      'description': 'Description',
      'deadline': 'Deadline',
      'cancel': 'Cancel',
      'add': 'Add',
      'startTask': 'Start Task',
      'markComplete': 'Mark Complete',
      'revert': 'Revert',
      'reopen': 'Reopen',
      'noTasks': 'No tasks found',
    },
    'fr': {
      'taskList': 'Liste des Tâches',
      'addTask': 'Ajouter une Tâche',
      'title': 'Titre',
      'description': 'Description',
      'deadline': 'Échéance',
      'cancel': 'Annuler',
      'add': 'Ajouter',
      'startTask': 'Commencer',
      'markComplete': 'Terminer',
      'revert': 'Retour',
      'reopen': 'Rouvrir',
      'noTasks': 'Aucune tâche trouvée',
    },
  };

  String get taskList => _localizedValues[locale.languageCode]!['taskList']!;
  String get addTask => _localizedValues[locale.languageCode]!['addTask']!;
  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get deadline => _localizedValues[locale.languageCode]!['deadline']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get startTask => _localizedValues[locale.languageCode]!['startTask']!;
  String get markComplete => _localizedValues[locale.languageCode]!['markComplete']!;
  String get revert => _localizedValues[locale.languageCode]!['revert']!;
  String get reopen => _localizedValues[locale.languageCode]!['reopen']!;
  String get noTasks => _localizedValues[locale.languageCode]!['noTasks']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}