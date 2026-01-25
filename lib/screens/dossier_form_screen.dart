import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/dossier_service.dart';
import 'upload_documents_screen.dart';

class DossierFormScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> dossier;
  final String numeroDossier;

  const DossierFormScreen({
    super.key,
    required this.user,
    required this.dossier,
    required this.numeroDossier,
  });

  @override
  State<DossierFormScreen> createState() => _DossierFormScreenState();
}

class _DossierFormScreenState extends State<DossierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _lieuNaissanceController = TextEditingController();
  final _nomPereController = TextEditingController();
  final _nomMereController = TextEditingController();
  final _dossierService = DossierService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _lieuNaissanceController.dispose();
    _nomPereController.dispose();
    _nomMereController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final data = {
        'informations': {
          'nomEnfant': _nomController.text,
          'prenomsEnfant': _prenomController.text,
          'dateNaissance': _dateNaissanceController.text,
          'lieuNaissance': _lieuNaissanceController.text,
          'nomPere': _nomPereController.text,
          'nomMere': _nomMereController.text,
        },
        'status': 'soumis',
      };

      final result = await _dossierService.updateDossierInfo(
        dossierId: widget.dossier['id'],
        data: data,
      );

      setState(() => _isSubmitting = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informations enregistrées')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadDocumentsScreen(
                user: widget.user,
                dossier: result['dossier'],
                numeroDossier: widget.numeroDossier,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
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
        title: Text('Dossier ${widget.numeroDossier}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
                        'Veuillez remplir les informations requises pour votre acte de naissance.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'INFORMATIONS DE L\'ENFANT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007A3D),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'enfant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénoms de l\'enfant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateNaissanceController,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance (JJ/MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lieuNaissanceController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de naissance',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'INFORMATIONS DES PARENTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007A3D),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomPereController,
                decoration: const InputDecoration(
                  labelText: 'Nom du père',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomMereController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la mère',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF007A3D),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Soumettre la demande'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}