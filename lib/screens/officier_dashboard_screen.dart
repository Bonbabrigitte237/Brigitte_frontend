import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/dossier_service.dart';
import 'officier_dossier_detail_screen.dart';

class OfficierDashboardScreen extends StatefulWidget {
  final User user;

  const OfficierDashboardScreen({super.key, required this.user});

  @override
  State<OfficierDashboardScreen> createState() => _OfficierDashboardScreenState();
}

class _OfficierDashboardScreenState extends State<OfficierDashboardScreen> {
  final _dossierService = DossierService();
  List<Map<String, dynamic>> _dossiers = [];
  bool _isLoading = true;
  String _filterStatus = 'soumis';
  String _filterMairie = 'all';

  @override
  void initState() {
    super.initState();
    _loadDossiers();
  }

  Future<void> _loadDossiers() async {
    setState(() => _isLoading = true);
    // For officers, load all dossiers (in production, add role check)
    final result = await _dossierService.getAllDossiers();
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _dossiers = List<Map<String, dynamic>>.from(result['dossiers'])
            .where((d) => d['status'] == 'soumis')
            .toList();
      }
    });
  }

  List<Map<String, dynamic>> get _filteredDossiers {
    return _dossiers.where((dossier) {
      final statusMatch = _filterStatus == 'all' || dossier['status'] == _filterStatus;
      final mairieMatch = _filterMairie == 'all' || dossier['mairieId'] == _filterMairie;
      return statusMatch && mairieMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007A3D),
        foregroundColor: Colors.white,
        title: const Text('Tableau de bord - Officier'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDossiers.isEmpty
                    ? const Center(
                        child: Text('Aucun dossier en attente'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredDossiers.length,
                        itemBuilder: (context, index) {
                          final dossier = _filteredDossiers[index];
                          return _buildDossierCard(dossier);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(value: 'soumis', child: Text('Soumis')),
                DropdownMenuItem(value: 'valide', child: Text('Validé')),
                DropdownMenuItem(value: 'rejete', child: Text('Rejeté')),
              ],
              onChanged: (value) {
                setState(() => _filterStatus = value!);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterMairie,
              decoration: const InputDecoration(
                labelText: 'Mairie',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Toutes')),
                DropdownMenuItem(value: '1', child: Text('Yaoundé Centre')),
                DropdownMenuItem(value: '2', child: Text('Douala')),
                DropdownMenuItem(value: '3', child: Text('Bafoussam')),
              ],
              onChanged: (value) {
                setState(() => _filterMairie = value!);
              },
            ),
          ),
        ],
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
              builder: (context) => OfficierDossierDetailScreen(
                user: widget.user,
                dossier: dossier,
              ),
            ),
          ).then((_) => _loadDossiers()); // Refresh after processing
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Soumis',
                      style: TextStyle(
                        color: Colors.blue,
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
                'Soumis le: ${_formatDate(dossier['updatedAt'])}',
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
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return 'N/A';
    }
  }
}