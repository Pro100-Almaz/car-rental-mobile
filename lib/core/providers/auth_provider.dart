import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

final currentUserProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  return UserNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);

class UserNotifier extends StateNotifier<AppUser?> {
  UserNotifier() : super(null);

  Future<bool> login({required String phone, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (phone.isEmpty || password.isEmpty) return false;
    state = AppUser(
      id: 'u1',
      fullName: 'Temirlan Zhumbayev',
      phone: phone,
      email: 'temirlan@example.com',
      isVerified: true,
      trustLevel: TrustLevel.verified,
    );
    return true;
  }

  Future<bool> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (phone.isEmpty || name.isEmpty || password.isEmpty) return false;
    state = AppUser(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      fullName: name,
      phone: phone,
      trustLevel: TrustLevel.newUser,
    );
    return true;
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return code.length == 4;
  }

  void updateProfile({String? fullName, String? email, String? phone}) {
    if (state == null) return;
    state = state!.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
    );
  }

  void setDocumentStatus({bool? driverLicense, bool? idDocument}) {
    if (state == null) return;
    state = state!.copyWith(
      hasDriverLicense: driverLicense,
      hasIdDocument: idDocument,
    );
    if ((state!.hasDriverLicense) && (state!.hasIdDocument)) {
      state = state!.copyWith(
        isVerified: true,
        trustLevel: TrustLevel.verified,
      );
    }
  }

  void logout() => state = null;
}
