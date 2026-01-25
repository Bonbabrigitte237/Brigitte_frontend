import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      final userData = userDoc.data();

      if (userData != null) {
        final user = User.fromJson({
          ...userData,
          'id': userCredential.user!.uid,
          'email': userCredential.user!.email,
        });

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userCredential.user!.uid);
        await prefs.setString('user', user.toJsonString());

        return {
          'success': true,
          'user': user,
          'message': 'Connexion réussie',
        };
      } else {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé dans la base de données',
        };
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé';
          break;
        default:
          message = 'Erreur de connexion: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        ...userData,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final user = User.fromJson({
        ...userData,
        'id': userCredential.user!.uid,
        'email': email,
      });

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);
      await prefs.setString('user', user.toJsonString());

      return {
        'success': true,
        'user': user,
        'message': 'Inscription réussie',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Le mot de passe est trop faible';
          break;
        case 'email-already-in-use':
          message = 'Un compte existe déjà avec cet email';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        default:
          message = 'Erreur d\'inscription: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur d\'inscription: ${e.toString()}',
      };
    }
  }

  Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        return User.fromJsonString(userString);
      }
    } catch (e) {
      // Error retrieving user from cache
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('user');
  }

  firebase_auth.User? get currentUser => _auth.currentUser;
}
