import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/career_model.dart';
import '../../providers/career_provider.dart';
import '../../services/hive_service.dart';
import 'career_detail_screen.dart';

/// Career Explorer Screen - Grade-adaptive UI with optimized density
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
// RESPONSIVE GRID HELPER - 2 columns for Web/Desktop
// ============================================================
int _getGridCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 900) return 3; // Large desktop
  if (width >= 600) return 2; // Tablet/Small desktop
  return 1; // Mobile - single column for list view
}

double _getGridChildAspectRatio(BuildContext context, {bool isCompact = false}) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 600) return isCompact ? 3.5 : 2.8; // Wider cards on larger screens
  return isCompact ? 4.0 : 3.2; // Taller cards on mobile
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
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('🎯 Interest Lab'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiscoveryHeader(context),
            const SizedBox(height: 16),
            _buildStreamCards(context),
            const SizedBox(height: 16),
            const Text('🌟 Explore Careers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCareerGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('👋 Welcome, Explorer!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text('Discover what excites you!',
              style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(230)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStreamCards(BuildContext context) {
    final streams = [
      {'tag': StreamTag.mpc, 'emoji': '🔬', 'color': Colors.blue},
      {'tag': StreamTag.bipc, 'emoji': '🧬', 'color': Colors.green},
      {'tag': StreamTag.mec, 'emoji': '💰', 'color': Colors.purple},
      {'tag': StreamTag.cec, 'emoji': '📊', 'color': Colors.orange},
      {'tag': StreamTag.hec, 'emoji': '⚖️', 'color': Colors.indigo},
      {'tag': StreamTag.vocational, 'emoji': '🛠️', 'color': Colors.teal},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: streams.length,
        itemBuilder: (context, index) {
          final stream = streams[index];
          final tag = stream['tag'] as StreamTag;
          final isSelected = provider.selectedStream == tag;

          return GestureDetector(
            // Tap to select, tap again to show all
            onTap: () => provider.filterByStream(isSelected ? null : tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? (stream['color'] as Color) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stream['color'] as Color,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (stream['color'] as Color).withAlpha(75),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stream['emoji'] as String,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 2),
                  Text(tag.shortName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : stream['color'] as Color,
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
    final crossAxisCount = MediaQuery.of(context).size.width >= 600 ? 3 : 2;

    // Empty state when no careers match the filter
    if (provider.filteredCareers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No careers found for ${provider.selectedStream?.shortName ?? "this filter"}',
              style: const TextStyle(fontSize: 14, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => provider.filterByStream(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show All Careers'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.95,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: CareerDetailScreen(career: career),
            ),
          )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStreamColor(career.streamTag).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(_getCareerIcon(career.iconName),
                  size: 28, color: _getStreamColor(career.streamTag)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(career.title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStreamColor(career.streamTag).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(career.streamTag.shortName,
                  style: TextStyle(
                      fontSize: 9, color: _getStreamColor(career.streamTag))),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GRADE 9-10: BRIDGE UI - Decision Matrix (OPTIMIZED)
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBridgeHeader(context),
            const SizedBox(height: 12),
            _buildStreamFilter(context),
            const SizedBox(height: 12),
            const Text('Compare Career Paths',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildCareerGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBridgeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryDark]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 Decision Time',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Understand your options and choose wisely.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(230))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('${provider.careers.length} Careers',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
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
          ...StreamTag.values
              .map((tag) => _buildFilterChip(tag.shortName, tag, provider)),
        ],
      ),
    );
  }

  /// Filter Chip with distinct primary color background when selected
  Widget _buildFilterChip(
      String label, StreamTag? tag, CareerProvider provider) {
    final isSelected = provider.selectedStream == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => provider.filterByStream(tag),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            // Distinct primary color background when selected
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(50),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareerGrid(BuildContext context) {
    final crossAxisCount = _getGridCrossAxisCount(context);
    final aspectRatio = _getGridChildAspectRatio(context);

    // Empty state when no careers match the filter
    if (provider.filteredCareers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No careers found for ${provider.selectedStream?.shortName ?? "this filter"}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => provider.filterByStream(null),
              child: const Text('Show All Careers'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: provider.filteredCareers.length,
      itemBuilder: (context, index) {
        final career = provider.filteredCareers[index];
        return _BridgeCareerCard(career: career, provider: provider);
      },
    );
  }
}

/// Dense Bridge Career Card - Optimized for information density
class _BridgeCareerCard extends StatelessWidget {
  final CareerModel career;
  final CareerProvider provider;
  const _BridgeCareerCard({required this.career, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: CareerDetailScreen(career: career),
              ),
            )),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Leading icon - 40x40
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStreamColor(career.streamTag).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getCareerIcon(career.iconName),
                    color: _getStreamColor(career.streamTag), size: 20),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(career.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(career.bridgeContent.required11thStream,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMiniChip(
                            '${career.realityCheck.jobStressIndex}/10',
                            Icons.psychology),
                        const SizedBox(width: 6),
                        _buildMiniChip(
                            career.realityCheck.avgSalary, Icons.currency_rupee),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[600]),
          const SizedBox(width: 2),
          Text(text,
              style: TextStyle(fontSize: 9, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

// ============================================================
// GRADE 11-12: EXECUTION UI - Execution Dashboard (OPTIMIZED)
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExecutionHeader(context),
            const SizedBox(height: 12),
            _buildQuickStats(context),
            const SizedBox(height: 12),
            _buildStreamFilter(context),
            const SizedBox(height: 12),
            const Text('Career Paths',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            _buildCareerGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0F3460), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(75)),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch, color: Colors.amber, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Execution Mode',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Focus on exams & career prep.',
                    style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(200))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Careers', '${provider.careers.length}', Icons.work, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(
            child:
                _buildStatCard('Streams', '5', Icons.category, Colors.green)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard('Exams', '15+', Icons.school, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[400])),
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
          ...StreamTag.values
              .map((tag) => _buildDarkFilterChip(tag.shortName, tag, provider)),
        ],
      ),
    );
  }

  /// Dark theme filter chip with distinct selection state
  Widget _buildDarkFilterChip(
      String label, StreamTag? tag, CareerProvider provider) {
    final isSelected = provider.selectedStream == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => provider.filterByStream(tag),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            // Distinct primary color when selected
            color: isSelected ? Colors.blue : const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.withAlpha(100),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withAlpha(75),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareerGrid(BuildContext context) {
    final crossAxisCount = _getGridCrossAxisCount(context);
    final aspectRatio = _getGridChildAspectRatio(context, isCompact: true);

    // Empty state when no careers match the filter
    if (provider.filteredCareers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'No careers found for ${provider.selectedStream?.shortName ?? "this filter"}',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => provider.filterByStream(null),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Show All Careers'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: provider.filteredCareers.length,
      itemBuilder: (context, index) {
        final career = provider.filteredCareers[index];
        return _ExecutionCareerCard(career: career, provider: provider);
      },
    );
  }
}

/// Dense Execution Career Card - Optimized for information density
class _ExecutionCareerCard extends StatelessWidget {
  final CareerModel career;
  final CareerProvider provider;
  const _ExecutionCareerCard({required this.career, required this.provider});

  @override
  Widget build(BuildContext context) {
    final exams = career.executionContent.entranceExams;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withAlpha(50)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: CareerDetailScreen(career: career),
              ),
            )),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Leading icon - 40x40
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStreamColor(career.streamTag).withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getCareerIcon(career.iconName),
                    color: _getStreamColor(career.streamTag), size: 20),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(career.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(career.streamTag.shortName,
                            style: TextStyle(
                                fontSize: 10,
                                color: _getStreamColor(career.streamTag))),
                        const SizedBox(width: 8),
                        Text(career.executionContent.financialReality.entrySalary,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                    if (exams.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: exams
                            .take(2)
                            .map((e) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(e.name,
                                      style: const TextStyle(
                                          fontSize: 8, color: Colors.blue)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================
Color _getStreamColor(StreamTag tag) {
  switch (tag) {
    case StreamTag.mpc:
      return Colors.blue;
    case StreamTag.bipc:
      return Colors.green;
    case StreamTag.mec:
      return Colors.purple;
    case StreamTag.cec:
      return Colors.orange;
    case StreamTag.hec:
      return Colors.indigo;
    case StreamTag.vocational:
      return Colors.teal;
  }
}

IconData _getCareerIcon(String iconName) {
  switch (iconName) {
    case 'computer':
      return Icons.computer;
    case 'medical_services':
      return Icons.medical_services;
    case 'account_balance':
      return Icons.account_balance;
    case 'gavel':
      return Icons.gavel;
    case 'web':
      return Icons.web;
    case 'rocket_launch':
      return Icons.rocket_launch;
    case 'directions_boat':
      return Icons.directions_boat;
    case 'architecture':
      return Icons.architecture;
    case 'science':
      return Icons.science;
    case 'biotech':
      return Icons.biotech;
    case 'vaccines':
      return Icons.vaccines;
    case 'trending_up':
      return Icons.trending_up;
    case 'calculate':
      return Icons.calculate;
    case 'balance':
      return Icons.balance;
    case 'design_services':
      return Icons.design_services;
    case 'psychology':
      return Icons.psychology;
    case 'public':
      return Icons.public;
    case 'engineering':
      return Icons.engineering;
    case 'movie_creation':
      return Icons.movie_creation;
    case 'restaurant':
      return Icons.restaurant;
    default:
      return Icons.work;
  }
}
