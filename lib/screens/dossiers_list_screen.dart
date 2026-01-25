import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/dossier_service.dart';
import 'dossier_detail_screen.dart';

class DossiersListScreen extends StatefulWidget {
  final User user;

  const DossiersListScreen({super.key, required this.user});

  @override
  State<DossiersListScreen> createState() => _DossiersListScreenState();
}

class _DossiersListScreenState extends State<DossiersListScreen> {
  final _dossierService = DossierService();
  List<Map<String, dynamic>> _dossiers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDossiers();
  }

  Future<void> _loadDossiers() async {
    setState(() => _isLoading = true);
    final result = await _dossierService.getUserDossiers();
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _dossiers = List<Map<String, dynamic>>.from(result['dossiers']);
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_cours':
        return Colors.orange;
      case 'soumis':
        return Colors.blue;
      case 'valide':
        return Colors.green;
      case 'rejete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'en_cours':
        return 'En cours';
      case 'soumis':
        return 'Soumis';
      case 'valide':
        return 'Validé';
      case 'rejete':
        return 'Rejeté';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007A3D),
        foregroundColor: Colors.white,
        title: const Text('Mes Dossiers'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDossiers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _dossiers.isEmpty
                ? const Center(
                    child: Text('Aucun dossier trouvé'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _dossiers.length,
                    itemBuilder: (context, index) {
                      final dossier = _dossiers[index];
                      return _buildDossierCard(dossier);
                    },
                  ),
      ),
    );
  }

  Widget _buildDossierCard(Map<String, dynamic> dossier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DossierDetailScreen(
                user: widget.user,
                dossier: dossier,
                isOfficer: false,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dossier['numeroDossier'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(dossier['status'] ?? 'en_cours')
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(dossier['status'] ?? 'en_cours'),
                      style: TextStyle(
                        color: _getStatusColor(dossier['status'] ?? 'en_cours'),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${dossier['typeService'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Mairie: ${dossier['mairieId'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Créé le: ${_formatDate(dossier['createdAt'])}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
