// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nation_one/featuers/auth/provider/get_user_info_as_stream_provider.dart';

// class UserChecki ngScreen extends ConsumerStatefulWidget {
//   const UserCheckingScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _UserCheckingScreenState();
// }

// class _UserCheckingScreenState extends ConsumerState<UserCheckingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     ref.watch(userInfoAsStreamProvider(FirebaseAuth.instance.currentUser!.uid)).value;
//     Future.delayed(const Duration(microseconds: 500)).then((value) {
//       return Container();
//     });
//     return Container();
//   }
// }
