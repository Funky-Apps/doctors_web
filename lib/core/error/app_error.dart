//
//
// import '../constants/app_colors.dart';
//
//
// void firebaseExceptionHandler(String errorCode) {
//   {
//     switch (errorCode) {
//       case 'account-exists-with-different-credential':
//         showToastMessage(
//             color: AppColors.dangerColor,
//             text: 'You already have an account with us. Use correct provider');
//         break;
//       case 'wrong-password':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'Password is invalid for the given email');
//         break;
//       case 'invalid-email':
//         showToastMessage(color: AppColors.dangerColor, text: 'Email address is not valid');
//         break;
//       case 'user-disabled':
//         showToastMessage(
//             color: AppColors.dangerColor,
//             text: 'User corresponding to the given email has been disabled');
//         break;
//       case 'user-not-found':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'No user corresponding to the given email');
//         break;
//       case 'operation-not-allowed':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'Email/password accounts are not enabled');
//         break;
//       case 'email-already-in-use':
//         showToastMessage(
//             color: AppColors.dangerColor,
//             text: 'already exists an account with the given email address');
//         break;
//       case 'weak-password':
//         showToastMessage(color: AppColors.dangerColor, text: 'Password is not strong enough');
//         break;
//       case 'invalid-credential':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'Credential is malformed or has expired');
//         break;
//       case 'invalid-verification-code':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'verification code of the credential is not valid');
//         break;
//       case 'invalid-verification-id':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'Verification ID of the credential is not valid');
//         break;
//       case 'user-mismatch':
//         showToastMessage(
//             color: AppColors.dangerColor, text: 'Credential given does not correspond to the user');
//         break;
//       case 'expired-action-code':
//         showToastMessage(color: AppColors.dangerColor, text: 'Thrown if OTP in email link expires');
//         break;
//       case 'non':
//         showToastMessage(color: AppColors.dangerColor, text: 'Something not right');
//         break;
//       case 'RDND':
//         showToastMessage(color: AppColors.dangerColor, text: 'Failed to fetch requested data');
//         break;
//       case 'DNS':
//         showToastMessage(color: AppColors.dangerColor, text: 'Failed to save selected data');
//         break;
//     }
//   }
// }
