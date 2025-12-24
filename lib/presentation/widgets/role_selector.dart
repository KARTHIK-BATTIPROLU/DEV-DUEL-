import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Role Selector Widget
/// Allows users to select between Student and Teacher roles during registration

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Student Role Option
        Expanded(
          child: _RoleCard(
            role: AppConstants.roleStudent,
            title: 'Student',
            subtitle: 'I want to learn',
            icon: Icons.school_outlined,
            color: AppTheme.studentColor,
            isSelected: selectedRole == AppConstants.roleStudent,
            onTap: () => onRoleChanged(AppConstants.roleStudent),
          ),
        ),
        const SizedBox(width: 12),

        // Teacher Role Option
        Expanded(
          child: _RoleCard(
            role: AppConstants.roleTeacher,
            title: 'Teacher',
            subtitle: 'I want to teach',
            icon: Icons.cast_for_education,
            color: AppTheme.teacherColor,
            isSelected: selectedRole == AppConstants.roleTeacher,
            onTap: () => onRoleChanged(AppConstants.roleTeacher),
          ),
        ),
      ],
    );
  }
}

/// Individual Role Card Widget
class _RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Selection Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Icon
            Icon(
              icon,
              size: 40,
              color: isSelected ? color : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color.withOpacity(0.8) : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
