import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../services/dossier_service.dart';

class UploadDocumentsScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> dossier;
  final String numeroDossier;

  const UploadDocumentsScreen({
    super.key,
    required this.user,
    required this.dossier,
    required this.numeroDossier,
  });

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final _dossierService = DossierService();
  final List<Map<String, dynamic>> _documents = [];
  bool _isUploading = false;

  final List<String> _requiredDocuments = [
    'Certificat de naissance',
    'Carte d\'identité du père',
    'Carte d\'identité de la mère',
    'Certificat de mariage (si applicable)',
    'Autres documents',
  ];

  Future<void> _pickImage(String documentType) async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Caméra'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galerie'),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        _addDocument(documentType, File(pickedFile.path), 'image');
      }
    }
  }

  Future<void> _pickFile(String documentType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      _addDocument(documentType, File(result.files.single.path!), 'file');
    }
  }

  void _addDocument(String type, File file, String fileType) {
    setState(() {
      _documents.add({
        'type': type,
        'file': file,
        'fileType': fileType,
        'uploading': false,
        'uploaded': false,
        'url': null,
      });
    });
  }

  Future<void> _uploadDocument(int index) async {
    final doc = _documents[index];
    setState(() {
      doc['uploading'] = true;
    });

    try {
      final fileName = '${widget.numeroDossier}_${doc['type']}_${DateTime.now().millisecondsSinceEpoch}.${doc['file'].path.split('.').last}';
      final ref = FirebaseStorage.instance.ref().child('documents/$fileName');
      await ref.putFile(doc['file']);
      final url = await ref.getDownloadURL();

      setState(() {
        doc['uploading'] = false;
        doc['uploaded'] = true;
        doc['url'] = url;
      });
    } catch (e) {
      setState(() {
        doc['uploading'] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'upload: $e')),
        );
      }
    }
  }

  Future<void> _submitDocuments() async {
    if (_documents.isEmpty || _documents.any((doc) => !doc['uploaded'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez uploader tous les documents requis')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final documentsData = _documents.map((doc) => {
      'type': doc['type'],
      'url': doc['url'],
      'uploadedAt': DateTime.now().toIso8601String(),
    }).toList();

    final result = await _dossierService.updateDossierInfo(
      dossierId: widget.dossier['id'],
      data: {'documents': documentsData},
    );

    setState(() => _isUploading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents uploadés avec succès')),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007A3D),
        foregroundColor: Colors.white,
        title: Text('Documents - ${widget.numeroDossier}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Veuillez uploader les documents requis pour votre demande d\'acte de naissance.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DOCUMENTS REQUIS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007A3D),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            ..._requiredDocuments.map((docType) => _buildDocumentItem(docType)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitDocuments,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF007A3D),
                  foregroundColor: Colors.white,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Finaliser la demande'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String docType) {
    final existingDoc = _documents.cast<Map<String, dynamic>?>().firstWhere(
          (doc) => doc?['type'] == docType,
          orElse: () => null,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            docType,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (existingDoc == null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(docType),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickFile(docType),
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Fichier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  existingDoc['uploaded'] ? Icons.check_circle : Icons.hourglass_empty,
                  color: existingDoc['uploaded'] ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    existingDoc['uploaded'] ? 'Uploadé' : 'En cours...',
                    style: TextStyle(
                      color: existingDoc['uploaded'] ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                if (!existingDoc['uploaded'] && !existingDoc['uploading'])
                  TextButton(
                    onPressed: () => _uploadDocument(_documents.indexOf(existingDoc)),
                    child: const Text('Uploader'),
                  ),
                if (existingDoc['uploading'])
                  const CircularProgressIndicator(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}