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

  @override
  String get authScreenTitle => 'Authentication';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get forgotPasswordButton => 'Forgot Password?';

  @override
  String get continueOfflineButton => 'Continue without signing in';

  @override
  String get enterEmailAndPasswordMessage =>
      'Please enter both email and password.';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordInstruction =>
      'Enter your email address below to receive a password reset link.';

  @override
  String get sendResetEmailButton => 'Send Reset Email';

  @override
  String get enterEmailToResetPasswordMessage =>
      'Please enter your email to reset your password.';

  @override
  String get passwordResetEmailSentMessage =>
      'Password reset email sent. Please check your inbox.';

  @override
  String get drinkBeer => 'Beer';

  @override
  String get drinkWhiskey => 'Whiskey';

  @override
  String get drinkWine => 'Wine';

  @override
  String get drinkCola => 'Cola';

  @override
  String get localGroupName => 'Local Group (On this device)';

  @override
  String get unnamedGroup => 'Unnamed Group';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get addNamesFirstError => 'Please add some names first.';

  @override
  String get groupHasNoMembersError => 'This group has no members.';

  @override
  String get couldNotLoadMemberDataError => 'Could not load any member data.';

  @override
  String get localCountersReset => 'Local counters have been reset.';

  @override
  String get groupCountersReset => 'Group counters have been reset.';

  @override
  String get groupHasNoMembersYet => 'This group has no members yet.';

  @override
  String get couldNotLoadMemberDetailsError => 'Could not load member details.';

  @override
  String get groupsTooltip => 'Groups';

  @override
  String get accountAndSettings => 'Account & Settings';

  @override
  String get showGroupQRTooltip => 'Show Group QR';

  @override
  String prefersDrink(Object drinkName) {
    return 'Prefers: $drinkName';
  }

  @override
  String get fetchBeerMessage => 'must fetch beer';

  @override
  String get createNewGroupTitle => 'Create New Group';

  @override
  String get groupNameHint => 'Group Name';

  @override
  String get createButton => 'Create';

  @override
  String get yourGroupsTitle => 'Your Groups';

  @override
  String get joinGroupQRTooltip => 'Join Group via QR';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get firstNameEmptyError => 'Please enter your first name';

  @override
  String get lastNameInitialLabel => 'First Letter of Last Name';

  @override
  String get lastNameInitialEmptyError =>
      'Please enter the first letter of your last name';

  @override
  String get emailInvalidError => 'Please enter a valid email';

  @override
  String get passwordLengthError =>
      'Password must be at least 6 characters long';

  @override
  String get preferredDrinkLabel => 'Preferred Drink';

  @override
  String get preferredDrinkEmptyError => 'Please select your preferred drink';

  @override
  String get unknownError => 'An unknown error occurred.';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get scanGroupQRCodeTitle => 'Scan Group QR Code';

  @override
  String get mustBeLoggedInToJoinGroupError =>
      'You must be logged in to join a group.';

  @override
  String get successfullyJoinedGroupMessage => 'Successfully joined group!';

  @override
  String get accountSettingsTitle => 'Account & Settings';

  @override
  String get loginOrRegisterButton => 'Login or Register';

  @override
  String get loggedInAsLabel => 'Logged in as:';

  @override
  String get noEmailProvidedLabel => 'No email provided';

  @override
  String loadUserDataError(Object error) {
    return 'Failed to load user data: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String profileUpdateError(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get updateProfileButton => 'Update Profile';

  @override
  String get logoutButton => 'Logout';

  @override
  String get resetCountersTitle => 'Reset Counters';

  @override
  String get resetCountersConfirmation =>
      'Are you sure you want to reset the local beer counters?';

  @override
  String get resetButton => 'Reset';

  @override
  String get countersResetSuccess => 'Counters have been reset.';

  @override
  String get resetAllCountersButton => 'Reset Local Beer Counters';

  @override
  String get appTitle => 'Who has to go get beer?';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account?';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action is permanent and will delete all your data.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get reauthenticateTitle => 'Re-authentication Required';

  @override
  String get reauthenticateInstruction =>
      'For security reasons, please log in again before deleting your account.';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully.';

  @override
  String accountDeleteError(Object error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get groupDoesNotExistError => 'This group does not exist.';

  @override
  String get shareUrlLabel => 'Share Group';

  @override
  String get drinkCustom => 'Custom';

  @override
  String get customDrinkLabel => 'Custom Drink Name';

  @override
  String get customDrinkHelper =>
      'Letters, numbers, spaces, dots and % only, max 15 characters';
}
