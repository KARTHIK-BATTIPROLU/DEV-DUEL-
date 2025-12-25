import 'package:flutter/material.dart';
import '../../../models/notice_model.dart';
import '../../../services/notice_service.dart';
import '../../../services/hive_service.dart';

/// Notice Board Tab - Teacher's Source of Truth
/// Manages notices with persistent Firestore collection
/// Deep Corporate Blue (#003F75) for administrative actions
class NoticeBoardTab extends StatefulWidget {
  const NoticeBoardTab({super.key});

  @override
  State<NoticeBoardTab> createState() => _NoticeBoardTabState();
}

class _NoticeBoardTabState extends State<NoticeBoardTab> {
  final _noticeService = NoticeService();

  // Deep Corporate Blue for admin actions
  static const Color _corporateBlue = Color(0xFF003F75);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<NoticeModel>>(
        stream: _noticeService.allNoticesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading notices', style: TextStyle(color: Colors.red[400])),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }

          final notices = snapshot.data ?? [];

          if (notices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No notices yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to create your first notice',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) => _NoticeCard(
              notice: notices[index],
              onDelete: () => _deleteNotice(notices[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoticeDialog,
        backgroundColor: _corporateBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Notice', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// Show Add Notice Dialog - Functional Form
  void _showAddNoticeDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    NoticeType selectedType = NoticeType.alert;
    TargetGrade selectedGrade = TargetGrade.all;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _corporateBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign, color: _corporateBlue),
              ),
              const SizedBox(width: 12),
              const Text('Create Notice'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter notice heading',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Body Field
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Details',
                    hintText: 'Enter notice details',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Target Grade Dropdown
                DropdownButtonFormField<TargetGrade>(
                  value: selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'Target Grade',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.school),
                  ),
                  items: TargetGrade.values.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(grade.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedGrade = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notice Type Dropdown
                DropdownButtonFormField<NoticeType>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Notice Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: NoticeType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getTypeIcon(type), size: 20, color: _getTypeColor(type)),
                          const SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _postNotice(
                context,
                titleController,
                bodyController,
                selectedType,
                selectedGrade,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _corporateBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  /// Post Notice - Write to Firestore
  Future<void> _postNotice(
    BuildContext dialogContext,
    TextEditingController titleController,
    TextEditingController bodyController,
    NoticeType type,
    TargetGrade targetGrade,
  ) async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get teacher info
    final teacher = HiveService.getTeacher();
    final teacherId = teacher?.uid ?? 'unknown';

    final notice = NoticeModel(
      id: '', // Will be set by Firestore
      title: title,
      body: body,
      targetGrade: targetGrade.firestoreValue,
      type: type.displayName,
      createdBy: teacherId,
    );

    try {
      await _noticeService.createNotice(notice);

      // Clear text fields
      titleController.clear();
      bodyController.clear();

      // Close dialog
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      // Show success SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white),
                SizedBox(width: 12),
                Text('Notice uploaded to Cloud'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete Notice - Removes from all Student screens instantly
  Future<void> _deleteNotice(NoticeModel notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Notice'),
        content: Text('Are you sure you want to delete "${notice.title}"?\n\nThis will remove it from all student feeds immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _noticeService.deleteNotice(notice.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notice deleted'),
              backgroundColor: Colors.grey[700],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _getTypeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.webinar:
        return Icons.video_call;
      case NoticeType.session:
        return Icons.groups;
      case NoticeType.workshop:
        return Icons.build;
      case NoticeType.alert:
        return Icons.warning_amber;
    }
  }

  Color _getTypeColor(NoticeType type) {
    switch (type) {
      case NoticeType.webinar:
        return Colors.blue;
      case NoticeType.session:
        return Colors.purple;
      case NoticeType.workshop:
        return Colors.green;
      case NoticeType.alert:
        return Colors.orange;
    }
  }
}

/// Notice Card Widget - Displays individual notice
class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onDelete;

  const _NoticeCard({required this.notice, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTypeColor(notice.noticeType).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(notice.noticeType),
                  color: _getTypeColor(notice.noticeType),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  notice.type,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getTypeColor(notice.noticeType),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Grade: ${notice.targetGrade}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notice.body,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(notice.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Just now';
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  IconData _getTypeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.webinar:
        return Icons.video_call;
      case NoticeType.session:
        return Icons.groups;
      case NoticeType.workshop:
        return Icons.build;
      case NoticeType.alert:
        return Icons.warning_amber;
    }
  }

  Color _getTypeColor(NoticeType type) {
    switch (type) {
      case NoticeType.webinar:
        return Colors.blue;
      case NoticeType.session:
        return Colors.purple;
      case NoticeType.workshop:
        return Colors.green;
      case NoticeType.alert:
        return Colors.orange;
    }
  }
}
