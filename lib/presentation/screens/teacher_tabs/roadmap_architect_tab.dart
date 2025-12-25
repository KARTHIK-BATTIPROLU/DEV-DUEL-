import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/career_model.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';

/// Roadmap Architect Tab - Build step-by-step career roadmaps with Firestore persistence
class RoadmapArchitectTab extends StatefulWidget {
  const RoadmapArchitectTab({super.key});

  @override
  State<RoadmapArchitectTab> createState() => _RoadmapArchitectTabState();
}

class _RoadmapArchitectTabState extends State<RoadmapArchitectTab> {
  final _teacherService = TeacherService();
  ManagedCareer? _selectedCareer;
  List<RoadmapNode> _editingNodes = [];
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Career List (Left Panel) - StreamBuilder from Firestore
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.teacherColor.withOpacity(0.1),
                child: const Row(
                  children: [
                    Icon(Icons.work, color: AppTheme.teacherColor),
                    SizedBox(width: 8),
                    Text('Select Career', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<ManagedCareer>>(
                  stream: _teacherService.careersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final careers = snapshot.data ?? [];
                    if (careers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('No careers yet.\nAdd careers in the Careers tab.', 
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: careers.length,
                      itemBuilder: (context, index) {
                        final career = careers[index];
                        final isSelected = _selectedCareer?.id == career.id;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AppTheme.teacherColor.withOpacity(0.1),
                          leading: Icon(_getCareerIcon(career.iconName), color: isSelected ? AppTheme.teacherColor : Colors.grey),
                          title: Text(career.title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Row(
                            children: [
                              Text(career.streamTag.shortName, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: career.roadmap.nodes.isEmpty ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${career.roadmap.nodes.length} steps',
                                  style: TextStyle(fontSize: 10, color: career.roadmap.nodes.isEmpty ? Colors.orange : Colors.green),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _selectCareer(career),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Roadmap Editor (Right Panel)
        Expanded(
          child: _selectedCareer == null ? _buildEmptyState() : _buildRoadmapEditor(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Select a career to edit its roadmap', style: TextStyle(fontSize: 16)),
          Text('Choose from the list on the left', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRoadmapEditor() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedCareer!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${_editingNodes.length} steps in roadmap', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (_isEditing) ...[
                TextButton(onPressed: _cancelEditing, child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveRoadmap,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save to Firestore'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ] else
                ElevatedButton.icon(
                  onPressed: _startEditing,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Roadmap'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teacherColor),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Roadmap Timeline
        Expanded(
          child: _editingNodes.isEmpty ? _buildEmptyRoadmap() : _buildRoadmapTimeline(),
        ),

        // Add Node Button (when editing)
        if (_isEditing)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNode,
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyRoadmap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No roadmap steps defined'),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: _addNode,
                icon: const Icon(Icons.add),
                label: const Text('Add First Step'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Click "Edit Roadmap" to add steps', style: TextStyle(color: Colors.grey[600])),
            ),
        ],
      ),
    );
  }

  Widget _buildRoadmapTimeline() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _editingNodes.length,
      onReorder: _isEditing ? _reorderNodes : (_, __) {},
      buildDefaultDragHandles: _isEditing,
      itemBuilder: (context, index) {
        final node = _editingNodes[index];
        final isLast = index == _editingNodes.length - 1;

        return _RoadmapNodeCard(
          key: ValueKey('${node.order}_${node.title}'),
          node: node,
          index: index,
          isLast: isLast,
          isEditing: _isEditing,
          onEdit: () => _editNode(index),
          onDelete: () => _deleteNode(index),
        );
      },
    );
  }

  void _selectCareer(ManagedCareer career) {
    setState(() {
      _selectedCareer = career;
      _editingNodes = List.from(career.roadmap.nodes);
      _isEditing = false;
    });
  }

  void _startEditing() => setState(() => _isEditing = true);

  void _cancelEditing() {
    setState(() {
      _editingNodes = List.from(_selectedCareer!.roadmap.nodes);
      _isEditing = false;
    });
  }

  Future<void> _saveRoadmap() async {
    setState(() => _isSaving = true);
    try {
      await _teacherService.updateCareerRoadmap(_selectedCareer!.id, _editingNodes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Roadmap saved! Students will see changes instantly.'), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addNode() {
    _showNodeEditor(null, (node) {
      setState(() {
        _editingNodes.add(RoadmapNode(
          title: node.title,
          description: node.description,
          duration: node.duration,
          order: _editingNodes.length,
        ));
      });
    });
  }

  void _editNode(int index) {
    _showNodeEditor(_editingNodes[index], (node) {
      setState(() => _editingNodes[index] = node);
    });
  }

  void _deleteNode(int index) {
    setState(() {
      _editingNodes.removeAt(index);
      _reindexNodes();
    });
  }

  void _reorderNodes(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final node = _editingNodes.removeAt(oldIndex);
      _editingNodes.insert(newIndex, node);
      _reindexNodes();
    });
  }

  void _reindexNodes() {
    for (int i = 0; i < _editingNodes.length; i++) {
      _editingNodes[i] = RoadmapNode(
        title: _editingNodes[i].title,
        description: _editingNodes[i].description,
        duration: _editingNodes[i].duration,
        order: i,
      );
    }
  }

  void _showNodeEditor(RoadmapNode? existingNode, Function(RoadmapNode) onSave) {
    final titleController = TextEditingController(text: existingNode?.title ?? '');
    final descController = TextEditingController(text: existingNode?.description ?? '');
    final durationController = TextEditingController(text: existingNode?.duration ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNode == null ? 'Add Step' : 'Edit Step'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Step Title *', hintText: 'e.g., Complete 12th Grade', border: OutlineInputBorder()),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'What needs to be done?', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration', hintText: 'e.g., 2 years', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              titleController.dispose();
              descController.dispose();
              durationController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title is required'), backgroundColor: Colors.orange),
                );
                return;
              }
              onSave(RoadmapNode(
                title: titleController.text.trim(),
                description: descController.text.trim(),
                duration: durationController.text.trim(),
                order: existingNode?.order ?? _editingNodes.length,
              ));
              titleController.dispose();
              descController.dispose();
              durationController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  IconData _getCareerIcon(String iconName) {
    switch (iconName) {
      case 'computer': return Icons.computer;
      case 'medical_services': return Icons.medical_services;
      case 'account_balance': return Icons.account_balance;
      case 'gavel': return Icons.gavel;
      case 'web': return Icons.web;
      case 'science': return Icons.science;
      case 'engineering': return Icons.engineering;
      default: return Icons.work;
    }
  }
}

/// Roadmap Node Card Widget
class _RoadmapNodeCard extends StatelessWidget {
  final RoadmapNode node;
  final int index;
  final bool isLast;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoadmapNodeCard({
    super.key,
    required this.node,
    required this.index,
    required this.isLast,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: _getStepColor(index), shape: BoxShape.circle),
                  child: Center(
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: Colors.grey[300])),
              ],
            ),
          ),

          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStepColor(index).withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(node.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      if (isEditing) ...[
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ],
                    ],
                  ),
                  if (node.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(node.description, style: TextStyle(color: Colors.grey[700])),
                  ],
                  if (node.duration.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(node.duration, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.indigo];
    return colors[index % colors.length];
  }
}
