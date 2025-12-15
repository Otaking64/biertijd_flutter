// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get list_of_names => 'Beer drinkers list';

  @override
  String get add_name_tooltip => 'Add Name';

  @override
  String get pick_random_name_button => 'Who has to go get beer?';

  @override
  String get add_new_name_dialog_title => 'Add a New Name';

  @override
  String get name_label => 'Name';

  @override
  String get enter_name_hint => 'Enter the name';

  @override
  String get cancel_button => 'Cancel';

  @override
  String get add_button => 'Add';

  @override
  String get no_names_warning => 'Please add some names to the list first!';

  @override
  String get must_get_beer => 'must get beer';
}
