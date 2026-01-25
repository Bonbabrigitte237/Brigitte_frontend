import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class DossierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // Créer un dossier
  Future<Map<String, dynamic>> createDossier({
    required String typeService,
    required String mairieId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non authentifié',
        };
      }

      final numeroDossier = 'DOS-${DateTime.now().millisecondsSinceEpoch}';
      final dossierId = _uuid.v4();

      final dossierData = {
        'id': dossierId,
        'numeroDossier': numeroDossier,
        'userId': user.uid,
        'typeService': typeService,
        'mairieId': mairieId,
        'status': 'en_cours',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'informations': {}, // Pour les données du formulaire
      };

      await _firestore.collection('dossiers').doc(dossierId).set(dossierData);

      return {
        'success': true,
        'numeroDossier': numeroDossier,
        'dossier': dossierData,
        'message': 'Dossier créé avec succès',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la création du dossier: ${e.toString()}',
      };
    }
  }

  // Mettre à jour les informations du dossier
  Future<Map<String, dynamic>> updateDossierInfo({
    required String dossierId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non authentifié',
        };
      }

      await _firestore.collection('dossiers').doc(dossierId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _firestore.collection('dossiers').doc(dossierId).get();
      final updatedData = updatedDoc.data();

      return {
        'success': true,
        'message': 'Informations mises à jour',
        'dossier': updatedData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour: ${e.toString()}',
      };
    }
  }

  // Récupérer les dossiers de l'utilisateur
  Future<Map<String, dynamic>> getUserDossiers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non authentifié',
        };
      }

      final querySnapshot = await _firestore
          .collection('dossiers')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final dossiers = querySnapshot.docs.map((doc) => doc.data()).toList();

      return {
        'success': true,
        'dossiers': dossiers,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la récupération: ${e.toString()}',
      };
    }
  }

  // Récupérer tous les dossiers (pour les officiers)
  Future<Map<String, dynamic>> getAllDossiers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non authentifié',
        };
      }

      // TODO: Add role check to ensure user is officer
      final querySnapshot = await _firestore
          .collection('dossiers')
          .orderBy('createdAt', descending: true)
          .get();

      final dossiers = querySnapshot.docs.map((doc) => doc.data()).toList();

      return {
        'success': true,
        'dossiers': dossiers,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la récupération: ${e.toString()}',
      };
    }
  }

  // Récupérer les mairies
  Future<Map<String, dynamic>> getMairies() async {
    try {
      // Pour le MVP, on retourne une liste statique de mairies
      // En production, cela pourrait venir d'une collection Firestore
      final mairies = [
        {'id': '1', 'nom': 'Mairie de Yaoundé Centre', 'ville': 'Yaoundé'},
        {'id': '2', 'nom': 'Mairie de Douala', 'ville': 'Douala'},
        {'id': '3', 'nom': 'Mairie de Bafoussam', 'ville': 'Bafoussam'},
        {'id': '4', 'nom': 'Mairie de Garoua', 'ville': 'Garoua'},
        {'id': '5', 'nom': 'Mairie de Maroua', 'ville': 'Maroua'},
      ];

      return {
        'success': true,
        'mairies': mairies,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
      };
    }
  }
}
