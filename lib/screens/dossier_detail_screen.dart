import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/dossier_service.dart';

class DossierDetailScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> dossier;
  final bool isOfficer;

  const DossierDetailScreen({
    super.key,
    required this.user,
    required this.dossier,
    this.isOfficer = false,
  });

  @override
  State<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends State<DossierDetailScreen> {
  final _dossierService = DossierService();
  bool _isProcessing = false;

  void _validateDossier() async {
    setState(() => _isProcessing = true);
    final result = await _dossierService.updateDossierInfo(
      dossierId: widget.dossier['id'],
      data: {'status': 'valide'},
    );
    setState(() => _isProcessing = false);
    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dossier validé')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  void _rejectDossier() async {
    final motif = await showDialog<String>(
      context: context,
      builder: (context) => _RejectDialog(),
    );
    if (motif != null && motif.isNotEmpty) {
      setState(() => _isProcessing = true);
      final result = await _dossierService.updateDossierInfo(
        dossierId: widget.dossier['id'],
        data: {'status': 'rejete', 'motifRejet': motif},
      );
      setState(() => _isProcessing = false);
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dossier rejeté')),
          );
          Navigator.pop(context);
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
    final informations = widget.dossier['informations'] as Map<String, dynamic>? ?? {};
    final documents = widget.dossier['documents'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007A3D),
        foregroundColor: Colors.white,
        title: Text('Dossier ${widget.dossier['numeroDossier']}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildInfoSection('Informations de l\'enfant', [
              _buildInfoRow('Nom', informations['nomEnfant']),
              _buildInfoRow('Prénoms', informations['prenomsEnfant']),
              _buildInfoRow('Date de naissance', informations['dateNaissance']),
              _buildInfoRow('Lieu de naissance', informations['lieuNaissance']),
            ]),
            const SizedBox(height: 20),
            _buildInfoSection('Informations des parents', [
              _buildInfoRow('Nom du père', informations['nomPere']),
              _buildInfoRow('Nom de la mère', informations['nomMere']),
            ]),
            const SizedBox(height: 20),
            _buildDocumentsSection(documents),
            if (widget.isOfficer && widget.dossier['status'] == 'soumis') ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _validateDossier,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Valider'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _rejectDossier,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Rejeter'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = widget.dossier['status'] ?? 'en_cours';
    return Container(
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
      child: Row(
        children: [
          Icon(
            status == 'valide' ? Icons.check_circle : Icons.hourglass_empty,
            color: status == 'valide' ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut: ${status == 'valide' ? 'Validé' : status == 'rejete' ? 'Rejeté' : 'En cours'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.dossier['motifRejet'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Motif: ${widget.dossier['motifRejet']}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007A3D),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Non spécifié'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(List<dynamic> documents) {
    return Container(
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
          const Text(
            'Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007A3D),
            ),
          ),
          const SizedBox(height: 12),
          if (documents.isEmpty)
            const Text('Aucun document uploadé')
          else
            ...documents.map((doc) => _buildDocumentItem(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(dynamic doc) {
    return ListTile(
      leading: const Icon(Icons.attach_file),
      title: Text(doc['type'] ?? 'Document'),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () async {
          final url = doc['url'];
          if (url != null && await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impossible d\'ouvrir le document')),
              );
            }
          }
        },
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Motif de rejet'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Entrez le motif du rejet',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Rejeter'),
        ),
      ],
    );
  }
}