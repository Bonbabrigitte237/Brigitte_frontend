import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/dossier_service.dart';
import 'dossier_form_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final User user;

  const ServiceSelectionScreen({super.key, required this.user});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? _selectedService;
  String? _selectedMairie;
  List<dynamic> _mairies = [];
  bool _isLoading = false;
  final _dossierService = DossierService();

  @override
  void initState() {
    super.initState();
    _loadMairies();
  }

  Future<void> _loadMairies() async {
    final result = await _dossierService.getMairies();
    if (result['success'] && mounted) {
      setState(() {
        _mairies = result['mairies'];
      });
    }
  }

  Future<void> _createDossier() async {
    if (_selectedService == null || _selectedMairie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un service et une mairie'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _dossierService.createDossier(
      typeService: _selectedService!,
      mairieId: _selectedMairie!,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DossierFormScreen(
            user: widget.user,
            dossier: result['dossier'],
            numeroDossier: result['numeroDossier'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007A3D),
        foregroundColor: Colors.white,
        title: const Text('Nouvelle Demande'),
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
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sélectionnez le type de service et la mairie de retrait',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'TYPE DE SERVICE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007A3D),
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildServiceOption(
              'declaration',
              'Déclaration de Naissance',
              'Pour les naissances de moins de 90 jours',
              Icons.baby_changing_station,
              'Attestation d\'accouchement requise',
            ),
            
            const SizedBox(height: 12),
            
            _buildServiceOption(
              'duplicata',
              'Duplicata d\'Acte Perdu',
              'Pour remplacer un acte égaré',
              Icons.content_copy,
              'Certificat de perte requis',
            ),
            
            const SizedBox(height: 12),
            
            _buildServiceOption(
              'jugement',
              'Établissement pour Adulte',
              'Avec jugement supplétif',
              Icons.gavel,
              'Ordonnance du tribunal requise',
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'MAIRIE DE RETRAIT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007A3D),
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Sélectionnez une mairie'),
                  value: _selectedMairie,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _mairies.map((mairie) {
                    return DropdownMenuItem<String>(
                      value: mairie['id'],
                      child: Text(mairie['nom']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedMairie = value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createDossier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'CONTINUER',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(
    String value,
    String title,
    String description,
    IconData icon,
    String requirement,
  ) {
    final isSelected = _selectedService == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedService = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007A3D).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF007A3D) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007A3D)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF007A3D) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          requirement,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF007A3D),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
