// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get list_of_names => 'Bierdrinkerslijst';

  @override
  String get add_name_tooltip => 'Naam toevoegen';

  @override
  String get pick_random_name_button => 'Wie moet er bier gaan halen?';

  @override
  String get add_new_name_dialog_title => 'Een nieuwe naam toevoegen';

  @override
  String get name_label => 'Naam';

  @override
  String get enter_name_hint => 'Voer de naam in';

  @override
  String get cancel_button => 'Annuleren';

  @override
  String get add_button => 'Toevoegen';

  @override
  String get no_names_warning => 'Voeg eerst wat namen toe aan de lijst!';

  @override
  String get must_get_beer => 'moet bier halen';

  @override
  String get authScreenTitle => 'Authenticatie';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Wachtwoord';

  @override
  String get loginButton => 'Inloggen';

  @override
  String get registerButton => 'Registreren';

  @override
  String get forgotPasswordButton => 'Wachtwoord vergeten?';

  @override
  String get continueOfflineButton => 'Doorgaan zonder in te loggen';

  @override
  String get enterEmailAndPasswordMessage =>
      'Voer zowel e-mail als wachtwoord in.';

  @override
  String get resetPasswordTitle => 'Wachtwoord opnieuw instellen';

  @override
  String get resetPasswordInstruction =>
      'Voer hieronder uw e-mailadres in om een link voor het opnieuw instellen van uw wachtwoord te ontvangen.';

  @override
  String get sendResetEmailButton => 'Stuur reset e-mail';

  @override
  String get enterEmailToResetPasswordMessage =>
      'Voer uw e-mailadres in om uw wachtwoord opnieuw in te stellen.';

  @override
  String get passwordResetEmailSentMessage =>
      'E-mail voor het opnieuw instellen van het wachtwoord is verzonden. Controleer uw inbox.';

  @override
  String get drinkBeer => 'Bier';

  @override
  String get drinkWhiskey => 'Whisky';

  @override
  String get drinkWine => 'Wijn';

  @override
  String get drinkCola => 'Cola';

  @override
  String get localGroupName => 'Lokale Groep (Op dit apparaat)';

  @override
  String get unnamedGroup => 'Naamloze Groep';

  @override
  String get unknownUser => 'Onbekend';

  @override
  String get addNamesFirstError => 'Voeg eerst wat namen toe.';

  @override
  String get groupHasNoMembersError => 'Deze groep heeft geen leden.';

  @override
  String get couldNotLoadMemberDataError =>
      'Kon geen lidmaatschapsgegevens laden.';

  @override
  String get localCountersReset => 'Lokale tellers zijn gereset.';

  @override
  String get groupCountersReset => 'Groepstellers zijn gereset.';

  @override
  String get groupHasNoMembersYet => 'Deze groep heeft nog geen leden.';

  @override
  String get couldNotLoadMemberDetailsError =>
      'Kon de details van de leden niet laden.';

  @override
  String get groupsTooltip => 'Groepen';

  @override
  String get accountAndSettings => 'Account & Instellingen';

  @override
  String get showGroupQRTooltip => 'Toon Groep QR';

  @override
  String prefersDrink(Object drinkName) {
    return 'Voorkeur: $drinkName';
  }

  @override
  String get fetchBeerMessage => 'moet bier halen';

  @override
  String get createNewGroupTitle => 'Nieuwe Groep Maken';

  @override
  String get groupNameHint => 'Groepsnaam';

  @override
  String get createButton => 'Maken';

  @override
  String get yourGroupsTitle => 'Jouw Groepen';

  @override
  String get joinGroupQRTooltip => 'Deelnemen aan groep via QR';

  @override
  String get createAccountTitle => 'Account aanmaken';

  @override
  String get firstNameLabel => 'Voornaam';

  @override
  String get firstNameEmptyError => 'Voer uw voornaam in';

  @override
  String get lastNameInitialLabel => 'Eerste letter van achternaam';

  @override
  String get lastNameInitialEmptyError =>
      'Voer de eerste letter van uw achternaam in';

  @override
  String get emailInvalidError => 'Voer een geldig e-mailadres in';

  @override
  String get passwordLengthError =>
      'Wachtwoord moet minimaal 6 tekens lang zijn';

  @override
  String get preferredDrinkLabel => 'Voorkeursdrank';

  @override
  String get preferredDrinkEmptyError => 'Selecteer uw voorkeursdrank';

  @override
  String get unknownError => 'Er is een onbekende fout opgetreden.';

  @override
  String get unexpectedError =>
      'Er is een onverwachte fout opgetreden. Probeer het opnieuw.';

  @override
  String get scanGroupQRCodeTitle => 'Scan Groep QR Code';

  @override
  String get mustBeLoggedInToJoinGroupError =>
      'U moet ingelogd zijn om lid te worden van een groep.';

  @override
  String get successfullyJoinedGroupMessage =>
      'Succesvol lid geworden van de groep!';

  @override
  String get accountSettingsTitle => 'Account & Instellingen';

  @override
  String get loginOrRegisterButton => 'Inloggen of Registreren';

  @override
  String get loggedInAsLabel => 'Ingelogd als:';

  @override
  String get noEmailProvidedLabel => 'Geen e-mailadres opgegeven';

  @override
  String loadUserDataError(Object error) {
    return 'Kon gebruikersgegevens niet laden: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Profiel succesvol bijgewerkt!';

  @override
  String profileUpdateError(Object error) {
    return 'Kon profiel niet bijwerken: $error';
  }

  @override
  String get updateProfileButton => 'Profiel bijwerken';

  @override
  String get logoutButton => 'Uitloggen';

  @override
  String get resetCountersTitle => 'Tellers resetten';

  @override
  String get resetCountersConfirmation =>
      'Weet u zeker dat u de lokale biertellers wilt resetten?';

  @override
  String get resetButton => 'Resetten';

  @override
  String get countersResetSuccess => 'Tellers zijn gereset.';

  @override
  String get resetAllCountersButton => 'Lokale Biertellers Resetten';
}
