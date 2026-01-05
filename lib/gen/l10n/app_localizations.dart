import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @list_of_names.
  ///
  /// In en, this message translates to:
  /// **'Beer drinkers list'**
  String get list_of_names;

  /// No description provided for @add_name_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Name'**
  String get add_name_tooltip;

  /// No description provided for @pick_random_name_button.
  ///
  /// In en, this message translates to:
  /// **'Who has to go get beer?'**
  String get pick_random_name_button;

  /// No description provided for @add_new_name_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Add a New Name'**
  String get add_new_name_dialog_title;

  /// No description provided for @name_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name_label;

  /// No description provided for @enter_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name'**
  String get enter_name_hint;

  /// No description provided for @cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button;

  /// No description provided for @add_button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_button;

  /// No description provided for @no_names_warning.
  ///
  /// In en, this message translates to:
  /// **'Please add some names to the list first!'**
  String get no_names_warning;

  /// The phrase that appears under the selected name
  ///
  /// In en, this message translates to:
  /// **'must get beer'**
  String get must_get_beer;

  /// No description provided for @authScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authScreenTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;

  /// No description provided for @continueOfflineButton.
  ///
  /// In en, this message translates to:
  /// **'Continue without signing in'**
  String get continueOfflineButton;

  /// No description provided for @enterEmailAndPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password.'**
  String get enterEmailAndPasswordMessage;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address below to receive a password reset link.'**
  String get resetPasswordInstruction;

  /// No description provided for @sendResetEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get sendResetEmailButton;

  /// No description provided for @enterEmailToResetPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to reset your password.'**
  String get enterEmailToResetPasswordMessage;

  /// No description provided for @passwordResetEmailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get passwordResetEmailSentMessage;

  /// No description provided for @drinkBeer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get drinkBeer;

  /// No description provided for @drinkWhiskey.
  ///
  /// In en, this message translates to:
  /// **'Whiskey'**
  String get drinkWhiskey;

  /// No description provided for @drinkWine.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get drinkWine;

  /// No description provided for @drinkCola.
  ///
  /// In en, this message translates to:
  /// **'Cola'**
  String get drinkCola;

  /// No description provided for @localGroupName.
  ///
  /// In en, this message translates to:
  /// **'Local Group (On this device)'**
  String get localGroupName;

  /// No description provided for @unnamedGroup.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Group'**
  String get unnamedGroup;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUser;

  /// No description provided for @addNamesFirstError.
  ///
  /// In en, this message translates to:
  /// **'Please add some names first.'**
  String get addNamesFirstError;

  /// No description provided for @groupHasNoMembersError.
  ///
  /// In en, this message translates to:
  /// **'This group has no members.'**
  String get groupHasNoMembersError;

  /// No description provided for @couldNotLoadMemberDataError.
  ///
  /// In en, this message translates to:
  /// **'Could not load any member data.'**
  String get couldNotLoadMemberDataError;

  /// No description provided for @localCountersReset.
  ///
  /// In en, this message translates to:
  /// **'Local counters have been reset.'**
  String get localCountersReset;

  /// No description provided for @groupCountersReset.
  ///
  /// In en, this message translates to:
  /// **'Group counters have been reset.'**
  String get groupCountersReset;

  /// No description provided for @groupHasNoMembersYet.
  ///
  /// In en, this message translates to:
  /// **'This group has no members yet.'**
  String get groupHasNoMembersYet;

  /// No description provided for @couldNotLoadMemberDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load member details.'**
  String get couldNotLoadMemberDetailsError;

  /// No description provided for @groupsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTooltip;

  /// No description provided for @accountAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountAndSettings;

  /// No description provided for @showGroupQRTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Group QR'**
  String get showGroupQRTooltip;

  /// No description provided for @prefersDrink.
  ///
  /// In en, this message translates to:
  /// **'Prefers: {drinkName}'**
  String prefersDrink(Object drinkName);

  /// No description provided for @fetchBeerMessage.
  ///
  /// In en, this message translates to:
  /// **'must fetch beer'**
  String get fetchBeerMessage;

  /// No description provided for @createNewGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get createNewGroupTitle;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupNameHint;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @yourGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Groups'**
  String get yourGroupsTitle;

  /// No description provided for @joinGroupQRTooltip.
  ///
  /// In en, this message translates to:
  /// **'Join Group via QR'**
  String get joinGroupQRTooltip;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @firstNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameEmptyError;

  /// No description provided for @lastNameInitialLabel.
  ///
  /// In en, this message translates to:
  /// **'First Letter of Last Name'**
  String get lastNameInitialLabel;

  /// No description provided for @lastNameInitialEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the first letter of your last name'**
  String get lastNameInitialEmptyError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalidError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordLengthError;

  /// No description provided for @preferredDrinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred Drink'**
  String get preferredDrinkLabel;

  /// No description provided for @preferredDrinkEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred drink'**
  String get preferredDrinkEmptyError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @scanGroupQRCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Group QR Code'**
  String get scanGroupQRCodeTitle;

  /// No description provided for @mustBeLoggedInToJoinGroupError.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to join a group.'**
  String get mustBeLoggedInToJoinGroupError;

  /// No description provided for @successfullyJoinedGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined group!'**
  String get successfullyJoinedGroupMessage;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountSettingsTitle;

  /// No description provided for @loginOrRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Login or Register'**
  String get loginOrRegisterButton;

  /// No description provided for @loggedInAsLabel.
  ///
  /// In en, this message translates to:
  /// **'Logged in as:'**
  String get loggedInAsLabel;

  /// No description provided for @noEmailProvidedLabel.
  ///
  /// In en, this message translates to:
  /// **'No email provided'**
  String get noEmailProvidedLabel;

  /// No description provided for @loadUserDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user data: {error}'**
  String loadUserDataError(Object error);

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String profileUpdateError(Object error);

  /// No description provided for @updateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @resetCountersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Counters'**
  String get resetCountersTitle;

  /// No description provided for @resetCountersConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the local beer counters?'**
  String get resetCountersConfirmation;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @countersResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Counters have been reset.'**
  String get countersResetSuccess;

  /// No description provided for @resetAllCountersButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Local Beer Counters'**
  String get resetAllCountersButton;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Who has to go get beer?'**
  String get appTitle;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and will delete all your data.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @reauthenticateTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication Required'**
  String get reauthenticateTitle;

  /// No description provided for @reauthenticateInstruction.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please log in again before deleting your account.'**
  String get reauthenticateInstruction;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccess;

  /// No description provided for @accountDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String accountDeleteError(Object error);

  /// No description provided for @groupDoesNotExistError.
  ///
  /// In en, this message translates to:
  /// **'This group does not exist.'**
  String get groupDoesNotExistError;

  /// No description provided for @shareUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Share Group'**
  String get shareUrlLabel;

  /// No description provided for @drinkCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get drinkCustom;

  /// No description provided for @customDrinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Drink Name'**
  String get customDrinkLabel;

  /// No description provided for @customDrinkHelper.
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, spaces, dots and % only, max 15 characters'**
  String get customDrinkHelper;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
