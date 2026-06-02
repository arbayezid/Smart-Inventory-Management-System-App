import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;

  AuthState({this.user, this.token, this.isLoading = false});

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({UserModel? user, String? token, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _loadUser();
    return AuthState(isLoading: true);
  }

  Future<void> _loadUser() async {
    final token = await storage.read(key: 'token');
    final userStr = await storage.read(key: 'userInfo');
    
    if (token == 'fake_token_for_testing') {
      await storage.delete(key: 'token');
      await storage.delete(key: 'userInfo');
      state = AuthState(isLoading: false);
      return;
    }
    
    if (token != null && userStr != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userStr));
        state = AuthState(user: user, token: token, isLoading: false);
        return;
      } catch (e) {
        // ignore and fallback to unauthenticated state
      }
    }
    
    state = AuthState(isLoading: false);
  }

  Future<void> _syncWithBackend({
    required String firebaseUid,
    required String email,
    required String name,
    required String role,
    String? shopName,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    try {
      final res = await dio.post(
        '/auth/sync',
        data: {
          'firebaseUid': firebaseUid,
          'email': email,
          'name': name,
          'role': role,
          'shopName': shopName ?? 'My Shop',
        },
      );

      final token = res.data['token'];
      final user = UserModel.fromJson(res.data);

      await storage.write(key: 'token', value: token);
      await storage.write(key: 'userInfo', value: jsonEncode(user.toJson()));
      state = AuthState(user: user, token: token, isLoading: false);
    } on DioException catch (e) {
      // In case of 403 (pending approval), sign out of Firebase
      try {
        await FirebaseAuth.instance.signOut();
        if (!kIsWeb) {
          await GoogleSignIn.instance.signOut();
        }
      } catch (_) {}

      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        final message = data is Map ? data['message'] : null;
        throw Exception(message ?? 'Shop request pending or restricted.');
      }
      throw Exception(e.response?.data?['message'] ?? 'Failed to sync with backend server.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Sign-in failed.');
      }

      await _syncWithBackend(
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: firebaseUser.displayName ?? firebaseUser.email ?? 'Shop Owner',
        role: 'ShopOwner',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // v7: authenticate() triggers the sign-in dialog
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();

        // v7: idToken is on .authentication, accessToken requires a separate
        // authorization step via .authorizationClient.authorizeScopes()
        final String? idToken = googleUser.authentication.idToken;
        final GoogleSignInClientAuthorization clientAuth =
            await googleUser.authorizationClient
                .authorizeScopes(['email', 'profile']);

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: clientAuth.accessToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Google Sign-In failed.');
      }

      await _syncWithBackend(
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email ?? 'Google User',
        role: 'ShopOwner',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String shopName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed.');
      }

      await firebaseUser.updateDisplayName(name);

      await _syncWithBackend(
        firebaseUid: firebaseUser.uid,
        email: email,
        name: name,
        role: 'ShopOwner',
        shopName: shopName,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> loginWithMockAuth(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _syncWithBackend(
        firebaseUid: 'mock-uid-${email.isNotEmpty ? email : "demo"}',
        email: email.isNotEmpty ? email : 'demo@example.com',
        name: 'Demo Shop Owner',
        role: 'ShopOwner',
        shopName: 'Demo Shop',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> login(String token, UserModel user) async {
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'userInfo', value: jsonEncode(user.toJson()));
    state = AuthState(user: user, token: token, isLoading: false);
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}
    await storage.delete(key: 'token');
    await storage.delete(key: 'userInfo');
    state = AuthState(isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
