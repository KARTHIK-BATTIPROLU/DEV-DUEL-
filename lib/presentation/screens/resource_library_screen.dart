import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/teacher_models.dart';
import '../../services/teacher_service.dart';

/// Turquoise/Teal brand color
const Color kBrandTeal = Color(0xFF0FACB0);

/// Resource Library Screen for Students
class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({super.key});

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  final _teacherService = TeacherService();
  String _selectedCategory = 'All';

  static const _categories = ['All', 'video', 'article', 'course', 'pdf', 'tool', 'other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Library'),
        backgroundColor: kBrandTeal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(cat)),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: kBrandTeal.withOpacity(0.2),
                    checkmarkColor: kBrandTeal,
                  ),
                )).toList(),
              ),
            ),
          ),
          
          // Resources List
          Expanded(
            child: StreamBuilder<List<Resource>>(
              stream: _teacherService.resourcesByCategoryStream(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kBrandTeal));
                }
                final resources = snapshot.data ?? [];
                if (resources.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resources.length,
                  itemBuilder: (context, index) => _ResourceCard(resource: resources[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No resources available', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Check back later for learning materials', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'All': return 'All';
      case 'video': return '🎬 Videos';
      case 'article': return '📄 Articles';
      case 'course': return '🎓 Courses';
      case 'pdf': return '📑 PDFs';
      case 'tool': return '🔧 Tools';
      case 'other': return '🔗 Other';
      default: return cat;
    }
  }
}

/// Resource Card Widget
class _ResourceCard extends StatelessWidget {
  final Resource resource;

  const _ResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
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
                    color: kBrandTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getCategoryIcon(resource.category), color: kBrandTeal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resource.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(resource.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          resource.category.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getCategoryColor(resource.category)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (resource.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(resource.description, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            ],
            if (resource.careerTitle != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.work_outline, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('Related: ${resource.careerTitle}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openResource(context, resource.url),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open Resource'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResource(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link'), backgroundColor: Colors.red),
        );
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'video': return Icons.play_circle_fill;
      case 'article': return Icons.article;
      case 'course': return Icons.school;
      case 'pdf': return Icons.picture_as_pdf;
      case 'tool': return Icons.build;
      default: return Icons.link;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'video': return Colors.red;
      case 'article': return Colors.blue;
      case 'course': return Colors.purple;
      case 'pdf': return Colors.orange;
      case 'tool': return Colors.green;
      default: return Colors.grey;
    }
  }
}
