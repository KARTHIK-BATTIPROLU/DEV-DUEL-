import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';
import '../../../services/hive_service.dart';
import '../../../models/user_model.dart';

/// Resource Manager Tab for Teachers - Upload and manage resources
class ResourceManagerTab extends StatefulWidget {
  const ResourceManagerTab({super.key});

  @override
  State<ResourceManagerTab> createState() => _ResourceManagerTabState();
}

class _ResourceManagerTabState extends State<ResourceManagerTab> {
  final _teacherService = TeacherService();
  String _selectedCategory = 'All';
  TeacherModel? _teacher;

  static const _categories = ['All', 'video', 'article', 'course', 'pdf', 'tool', 'other'];

  @override
  void initState() {
    super.initState();
    _teacher = HiveService.getTeacher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getCategoryLabel(cat)),
                          selected: _selectedCategory == cat,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppTheme.teacherColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.teacherColor,
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Resources List
          Expanded(
            child: StreamBuilder<List<Resource>>(
              stream: _teacherService.resourcesByCategoryStream(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final resources = snapshot.data ?? [];
                if (resources.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    return Dismissible(
                      key: Key(resource.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmDelete(resource),
                      onDismissed: (_) => _teacherService.deleteResource(resource.id),
                      child: _ResourceManageCard(
                        resource: resource,
                        onEdit: () => _editResource(resource),
                        onToggleActive: (active) => _teacherService.updateResource(resource.id, {'isActive': active}),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addResource,
        backgroundColor: AppTheme.teacherColor,
        icon: const Icon(Icons.add),
        label: const Text('Upload Resource'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_add_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No resources yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap + to upload a resource', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Resource resource) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resource?'),
        content: Text('Are you sure you want to delete "${resource.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _addResource() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditResourceScreen(teacher: _teacher)),
    );
  }

  void _editResource(Resource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditResourceScreen(teacher: _teacher, resource: resource)),
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

/// Resource Management Card
class _ResourceManageCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onEdit;
  final Function(bool) onToggleActive;

  const _ResourceManageCard({
    required this.resource,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: resource.isActive ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: resource.isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getCategoryColor(resource.category).withOpacity(resource.isActive ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getCategoryIcon(resource.category), color: resource.isActive ? _getCategoryColor(resource.category) : Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: resource.isActive ? null : Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(resource.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(resource.category.toUpperCase(), style: TextStyle(fontSize: 10, color: _getCategoryColor(resource.category))),
                      ),
                      if (resource.careerTitle != null) ...[
                        const SizedBox(width: 8),
                        Text('• ${resource.careerTitle}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit, color: Colors.grey),
            Switch(value: resource.isActive, onChanged: onToggleActive, activeColor: AppTheme.teacherColor),
          ],
        ),
      ),
    );
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

/// Add/Edit Resource Screen
class AddEditResourceScreen extends StatefulWidget {
  final TeacherModel? teacher;
  final Resource? resource;

  const AddEditResourceScreen({super.key, this.teacher, this.resource});

  @override
  State<AddEditResourceScreen> createState() => _AddEditResourceScreenState();
}

class _AddEditResourceScreenState extends State<AddEditResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teacherService = TeacherService();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  
  String _selectedCategory = 'article';
  bool _isLoading = false;

  bool get _isEditing => widget.resource != null;

  static const _categoryOptions = ['video', 'article', 'course', 'pdf', 'tool', 'other'];

  @override
  void initState() {
    super.initState();
    final r = widget.resource;
    _titleController = TextEditingController(text: r?.title ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _urlController = TextEditingController(text: r?.url ?? '');
    if (r != null) _selectedCategory = r.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Resource' : 'Upload Resource'),
        backgroundColor: AppTheme.teacherColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            ))
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveResource),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resource Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title *', hintText: 'e.g., Introduction to Python', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(labelText: 'URL/Link *', hintText: 'https://...', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        if (!v!.startsWith('http')) return 'Must be a valid URL';
                        return null;
                      },
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                      items: _categoryOptions.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(cat), size: 20, color: _getCategoryColor(cat)),
                            const SizedBox(width: 8),
                            Text(_getCategoryLabel(cat)),
                          ],
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', hintText: 'Brief description of the resource...', border: OutlineInputBorder()),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveResource,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teacherColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isEditing ? 'Update Resource' : 'Upload Resource', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final resource = Resource(
        id: widget.resource?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        url: _urlController.text.trim(),
        category: _selectedCategory,
        isActive: widget.resource?.isActive ?? true,
        createdAt: widget.resource?.createdAt ?? now,
        updatedAt: now,
        createdBy: widget.teacher?.uid ?? '',
      );

      if (_isEditing) {
        await _teacherService.updateResource(resource.id, resource.toMap());
      } else {
        await _teacherService.createResource(resource);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Resource updated!' : 'Resource uploaded!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'video': return 'Video';
      case 'article': return 'Article';
      case 'course': return 'Course';
      case 'pdf': return 'PDF';
      case 'tool': return 'Tool';
      case 'other': return 'Other';
      default: return cat;
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
