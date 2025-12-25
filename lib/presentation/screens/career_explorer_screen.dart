import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/career_model.dart';
import '../../providers/career_provider.dart';
import '../../services/hive_service.dart';
import 'career_detail_screen.dart';

/// Career Explorer Screen - Grade-adaptive UI
class CareerExplorerScreen extends StatefulWidget {
  const CareerExplorerScreen({super.key});

  @override
  State<CareerExplorerScreen> createState() => _CareerExplorerScreenState();
}

class _CareerExplorerScreenState extends State<CareerExplorerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CareerProvider>();
      provider.initialize();
      final grade = HiveService.getUserGrade() ?? 10;
      provider.updateUserGrade(grade);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CareerProvider>(
      builder: (context, provider, _) {
        final uiStyle = provider.getUIStyle();
        
        switch (uiStyle) {
          case 'discovery':
            return _DiscoveryUI(provider: provider);
          case 'bridge':
            return _BridgeUI(provider: provider);
          default:
            return _ExecutionUI(provider: provider);
        }
      },
    );
  }
}

// ============================================================
// GRADE 7-8: DISCOVERY UI - Gamified Interest Lab
// ============================================================
class _DiscoveryUI extends StatelessWidget {
  final CareerProvider provider;
  const _DiscoveryUI({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Warm playful background
      appBar: AppBar(
        title: const Text('🎯 Interest Lab'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiscoveryHeader(context),
            const SizedBox(height: 20),
            _buildStreamCards(context),
            const SizedBox(height: 20),
            const Text('🌟 Explore Careers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildCareerGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('👋 Welcome, Explorer!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Discover what excites you. Every career is an adventure!', 
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStreamCards(BuildContext context) {
    final streams = [
      {'tag': StreamTag.mpc, 'emoji': '🔬', 'color': Colors.blue},
      {'tag': StreamTag.bipc, 'emoji': '🧬', 'color': Colors.green},
      {'tag': StreamTag.mec, 'emoji': '💰', 'color': Colors.purple},
      {'tag': StreamTag.hec, 'emoji': '⚖️', 'color': Colors.indigo},
      {'tag': StreamTag.vocational, 'emoji': '🛠️', 'color': Colors.teal},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: streams.length,
        itemBuilder: (context, index) {
          final stream = streams[index];
          final tag = stream['tag'] as StreamTag;
          final isSelected = provider.selectedStream == tag;
          
          return GestureDetector(
            onTap: () => provider.filterByStream(isSelected ? null : tag),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? (stream['color'] as Color) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: stream['color'] as Color, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stream['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(tag.shortName, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : stream['color'] as Color,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareerGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: provider.filteredCareers.length,
      itemBuilder: (context, index) {
        final career = provider.filteredCareers[index];
        return _DiscoveryCareerCard(career: career, provider: provider);
      },
    );
  }
}

class _DiscoveryCareerCard extends StatelessWidget {
  final CareerModel career;
  final CareerProvider provider;
  const _DiscoveryCareerCard({required this.career, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider, child: CareerDetailScreen(career: career),
        ),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStreamColor(career.streamTag).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getCareerIcon(career.iconName), size: 36, color: _getStreamColor(career.streamTag)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(career.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStreamColor(career.streamTag).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(career.streamTag.shortName, style: TextStyle(fontSize: 10, color: _getStreamColor(career.streamTag))),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// GRADE 9-10: BRIDGE UI - Decision Matrix
// ============================================================
class _BridgeUI extends StatelessWidget {
  final CareerProvider provider;
  const _BridgeUI({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Decision Matrix'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.compare_arrows), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBridgeHeader(context),
            const SizedBox(height: 20),
            _buildStreamFilter(context),
            const SizedBox(height: 20),
            const Text('Compare Career Paths', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildCareerList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBridgeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryDark]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯 Decision Time', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Class 10 is crucial. Understand your options and choose wisely.', 
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('5 Streams', Icons.category),
              const SizedBox(width: 12),
              _buildStatChip('${provider.careers.length} Careers', Icons.work),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStreamFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null, provider),
          ...StreamTag.values.map((tag) => _buildFilterChip(tag.shortName, tag, provider)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StreamTag? tag, CareerProvider provider) {
    final isSelected = provider.selectedStream == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.filterByStream(isSelected ? null : tag),
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildCareerList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.filteredCareers.length,
      itemBuilder: (context, index) {
        final career = provider.filteredCareers[index];
        return _BridgeCareerCard(career: career, provider: provider);
      },
    );
  }
}

class _BridgeCareerCard extends StatelessWidget {
  final CareerModel career;
  final CareerProvider provider;
  const _BridgeCareerCard({required this.career, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider, child: CareerDetailScreen(career: career),
          ),
        )),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStreamColor(career.streamTag).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCareerIcon(career.iconName), color: _getStreamColor(career.streamTag), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(career.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(career.bridgeContent.required11thStream, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip('Stress: ${career.realityCheck.jobStressIndex}/10', Icons.psychology),
                        const SizedBox(width: 8),
                        _buildInfoChip(career.realityCheck.avgSalary, Icons.currency_rupee),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }
}


// ============================================================
// GRADE 11-12: EXECUTION UI - Execution Dashboard
// ============================================================
class _ExecutionUI extends StatelessWidget {
  final CareerProvider provider;
  const _ExecutionUI({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Execution Dashboard'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExecutionHeader(context),
            const SizedBox(height: 20),
            _buildQuickStats(context),
            const SizedBox(height: 20),
            _buildStreamFilter(context),
            const SizedBox(height: 20),
            const Text('Career Paths', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _buildCareerList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F3460), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rocket_launch, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text('Execution Mode', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Focus on entrance exams, college selection, and career preparation.', 
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Careers', '${provider.careers.length}', Icons.work, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Streams', '5', Icons.category, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Exams', '15+', Icons.school, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildStreamFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDarkFilterChip('All', null, provider),
          ...StreamTag.values.map((tag) => _buildDarkFilterChip(tag.shortName, tag, provider)),
        ],
      ),
    );
  }

  Widget _buildDarkFilterChip(String label, StreamTag? tag, CareerProvider provider) {
    final isSelected = provider.selectedStream == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => provider.filterByStream(isSelected ? null : tag),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3)),
          ),
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildCareerList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.filteredCareers.length,
      itemBuilder: (context, index) {
        final career = provider.filteredCareers[index];
        return _ExecutionCareerCard(career: career, provider: provider);
      },
    );
  }
}

class _ExecutionCareerCard extends StatelessWidget {
  final CareerModel career;
  final CareerProvider provider;
  const _ExecutionCareerCard({required this.career, required this.provider});

  @override
  Widget build(BuildContext context) {
    final exams = career.executionContent.entranceExams;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider, child: CareerDetailScreen(career: career),
          ),
        )),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStreamColor(career.streamTag).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getCareerIcon(career.iconName), color: _getStreamColor(career.streamTag), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(career.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text(career.streamTag.shortName, style: TextStyle(fontSize: 12, color: _getStreamColor(career.streamTag))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDataPoint('Entry Salary', career.executionContent.financialReality.entrySalary),
                  _buildDataPoint('5-Year', career.executionContent.financialReality.fiveYearSalary),
                  _buildDataPoint('Exams', '${exams.length}'),
                ],
              ),
              if (exams.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: exams.take(3).map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(e.name, style: const TextStyle(fontSize: 10, color: Colors.blue)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataPoint(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================
Color _getStreamColor(StreamTag tag) {
  switch (tag) {
    case StreamTag.mpc: return Colors.blue;
    case StreamTag.bipc: return Colors.green;
    case StreamTag.mec: return Colors.purple;
    case StreamTag.cec: return Colors.orange;
    case StreamTag.hec: return Colors.indigo;
    case StreamTag.vocational: return Colors.teal;
  }
}

IconData _getCareerIcon(String iconName) {
  switch (iconName) {
    case 'computer': return Icons.computer;
    case 'medical_services': return Icons.medical_services;
    case 'account_balance': return Icons.account_balance;
    case 'gavel': return Icons.gavel;
    case 'web': return Icons.web;
    case 'rocket_launch': return Icons.rocket_launch;
    case 'directions_boat': return Icons.directions_boat;
    case 'architecture': return Icons.architecture;
    case 'science': return Icons.science;
    case 'biotech': return Icons.biotech;
    case 'vaccines': return Icons.vaccines;
    case 'trending_up': return Icons.trending_up;
    case 'calculate': return Icons.calculate;
    case 'balance': return Icons.balance;
    case 'design_services': return Icons.design_services;
    case 'psychology': return Icons.psychology;
    case 'public': return Icons.public;
    case 'engineering': return Icons.engineering;
    case 'movie_creation': return Icons.movie_creation;
    case 'restaurant': return Icons.restaurant;
    default: return Icons.work;
  }
}
