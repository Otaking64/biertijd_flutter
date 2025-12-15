// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get list_of_names => 'Bier drinkers lijst';

  @override
  String get add_name_tooltip => 'Naam Toevoegen';

  @override
  String get pick_random_name_button => 'Wie moet er bier gaan halen';

  @override
  String get add_new_name_dialog_title => 'Voeg een Nieuwe Naam Toe';

  @override
  String get name_label => 'Naam';

  @override
  String get enter_name_hint => 'Voer de naam in';

  @override
  String get cancel_button => 'Annuleren';

  @override
  String get add_button => 'Toevoegen';

  @override
  String get no_names_warning => 'Voeg eerst namen toe aan de lijst!';

  @override
  String get must_get_beer => 'moet bier gaan halen';
}
