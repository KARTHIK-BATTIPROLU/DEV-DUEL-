import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';

/// Review Hub Tab - Manage student submissions
class ReviewHubTab extends StatefulWidget {
  const ReviewHubTab({super.key});

  @override
  State<ReviewHubTab> createState() => _ReviewHubTabState();
}

class _ReviewHubTabState extends State<ReviewHubTab> {
  final _teacherService = TeacherService();
  SubmissionStatus? _filterStatus;
  
  // Sample data for demonstration
  final List<StudentSubmission> _sampleSubmissions = [
    StudentSubmission(
      id: '1',
      studentId: 'student1',
      studentName: 'Rahul Sharma',
      studentGrade: 10,
      type: 'reflection',
      title: 'My Career Exploration Journey',
      content: 'After exploring the Software Architect career path, I realized that I enjoy problem-solving and logical thinking. The day-in-life story was very inspiring...',
      careerId: 'software_architect',
      status: SubmissionStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    StudentSubmission(
      id: '2',
      studentId: 'student2',
      studentName: 'Priya Patel',
      studentGrade: 9,
      type: 'journal',
      title: 'Stream Selection Thoughts',
      content: 'I am confused between MPC and BiPC. I like both biology and mathematics. Need guidance on which stream would be better for my interests...',
      status: SubmissionStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    StudentSubmission(
      id: '3',
      studentId: 'student3',
      studentName: 'Amit Kumar',
      studentGrade: 11,
      type: 'task_result',
      title: 'Logic Puzzle Completion',
      content: 'Completed the discount calculator task with 100% accuracy. Found it very helpful in understanding programming logic.',
      careerId: 'software_architect',
      status: SubmissionStatus.approved,
      teacherComment: 'Excellent work! Your logical thinking is impressive.',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      reviewedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  List<StudentSubmission> get _filteredSubmissions {
    if (_filterStatus == null) return _sampleSubmissions;
    return _sampleSubmissions.where((s) => s.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Bar
        _buildFilterBar(),
        
        // Submissions List
        Expanded(
          child: _filteredSubmissions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredSubmissions.length,
                  itemBuilder: (context, index) {
                    return _SubmissionCard(
                      submission: _filteredSubmissions[index],
                      onReview: (status, comment) => _handleReview(_filteredSubmissions[index], status, comment),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null, Icons.all_inbox),
            _buildFilterChip('Pending', SubmissionStatus.pending, Icons.pending),
            _buildFilterChip('Approved', SubmissionStatus.approved, Icons.check_circle),
            _buildFilterChip('Rejected', SubmissionStatus.rejected, Icons.cancel),
            _buildFilterChip('Revision', SubmissionStatus.revisionRequired, Icons.edit),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, SubmissionStatus? status, IconData icon) {
    final isSelected = _filterStatus == status;
    final count = status == null
        ? _sampleSubmissions.length
        : _sampleSubmissions.where((s) => s.status == status).length;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterStatus = isSelected ? null : status),
        selectedColor: AppTheme.teacherColor,
        labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No submissions found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _handleReview(StudentSubmission submission, SubmissionStatus status, String comment) {
    // In real app, this would call the service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submission ${status.displayName.toLowerCase()}'),
        backgroundColor: _getStatusColor(status),
      ),
    );
  }

  Color _getStatusColor(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.pending: return Colors.orange;
      case SubmissionStatus.approved: return Colors.green;
      case SubmissionStatus.rejected: return Colors.red;
      case SubmissionStatus.revisionRequired: return Colors.blue;
    }
  }
}

/// Submission Card Widget
class _SubmissionCard extends StatelessWidget {
  final StudentSubmission submission;
  final Function(SubmissionStatus, String) onReview;

  const _SubmissionCard({required this.submission, required this.onReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(submission.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getGradeColor(submission.studentGrade),
                  child: Text(
                    submission.studentName[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(submission.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Grade ${submission.studentGrade} • ${_getTypeLabel(submission.type)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                _buildStatusBadge(submission.status),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(submission.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  submission.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(_formatTime(submission.submittedAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
                
                // Teacher Comment (if reviewed)
                if (submission.teacherComment != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.comment, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            submission.teacherComment!,
                            style: const TextStyle(fontSize: 13, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions (only for pending)
          if (submission.status == SubmissionStatus.pending)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showReviewDialog(context, SubmissionStatus.revisionRequired),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Revision'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showReviewDialog(context, SubmissionStatus.rejected),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReviewDialog(context, SubmissionStatus.approved),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, SubmissionStatus status) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status.displayName} Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add a comment for ${submission.studentName}:'),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onReview(status, commentController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _getStatusColor(status)),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SubmissionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getStatusColor(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.pending: return Colors.orange;
      case SubmissionStatus.approved: return Colors.green;
      case SubmissionStatus.rejected: return Colors.red;
      case SubmissionStatus.revisionRequired: return Colors.blue;
    }
  }

  Color _getGradeColor(int grade) {
    if (grade <= 8) return Colors.teal;
    if (grade <= 10) return Colors.indigo;
    return Colors.deepOrange;
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'reflection': return 'Reflection';
      case 'journal': return 'Journal';
      case 'task_result': return 'Task Result';
      default: return type;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
