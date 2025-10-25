// lib/features/admin/presentation/screens/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/admin/presentation/controllers/admin_controller.dart';
import '../providers/admin_presentation_providers.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String? _selectedGradeFilter;
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminControllerProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final theme = Theme.of(context);

    // Listen for errors
    ref.listen<AdminState>(adminControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: theme.colorScheme.onError,
              onPressed: () {
                ref.read(adminControllerProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => _performSearch(),
                ),
                
                const SizedBox(height: 16),
                
                // Filters Row
                Row(
                  children: [
                    // Grade Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGradeFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Grade',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Grades'),
                          ),
                          ...['GRADE_10', 'GRADE_11', 'GRADE_12'].map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text(grade.replaceAll('_', ' ')),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedGradeFilter = value);
                          _performSearch();
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Role Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRoleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Role',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Roles'),
                          ),
                          ...['USER', 'ADMIN'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRoleFilter = value);
                          _performSearch();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminState.users.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(adminControllerProvider.notifier)
                            .loadUsers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: adminState.users.length,
                          itemBuilder: (context, index) {
                            final user = adminState.users[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: user.role == 'ADMIN'
                                      ? Colors.purple.withValues(alpha: 0.2)
                                      : Colors.blue.withValues(alpha: 0.2),
                                  child: Icon(
                                    user.role == 'ADMIN'
                                        ? Icons.admin_panel_settings
                                        : Icons.person,
                                    color: user.role == 'ADMIN'
                                        ? Colors.purple
                                        : Colors.blue,
                                  ),
                                ),
                                title: Text(
                                  user.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.email),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            user.gradeDisplayName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (!user.isEmailVerified)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Unverified',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange[700],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Role Toggle
                                    Container(
                                      decoration: BoxDecoration(
                                        color: user.role == 'ADMIN'
                                            ? Colors.purple.withValues(alpha: 0.1)
                                            : Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: TextButton(
                                        onPressed: adminState.isLoading
                                            ? null
                                            : () => _toggleUserRole(user.id, user.role),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                        ),
                                        child: Text(
                                          user.role,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: user.role == 'ADMIN'
                                                ? Colors.purple[700]
                                                : Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    // Email Verification Toggle
                                    IconButton(
                                      onPressed: adminState.isLoading
                                          ? null
                                          : () => _toggleEmailVerification(
                                              user.id, user.isEmailVerified),
                                      icon: Icon(
                                        user.isEmailVerified
                                            ? Icons.verified
                                            : Icons.mail_outline,
                                        color: user.isEmailVerified
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      tooltip: user.isEmailVerified
                                          ? 'Unverify Email'
                                          : 'Verify Email',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    ref.read(adminControllerProvider.notifier).loadUsers(
      search: _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim(),
      grade: _selectedGradeFilter,
      role: _selectedRoleFilter,
    );
  }

  void _toggleUserRole(String userId, String currentRole) {
    final newRole = currentRole == 'ADMIN' ? 'USER' : 'ADMIN';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role to $newRole'),
        content: Text(
          'Are you sure you want to change this user\'s role to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminControllerProvider.notifier)
                  .updateUserRole(userId, newRole);
            },
            child: const Text('Change Role'),
          ),
        ],
      ),
    );
  }

  void _toggleEmailVerification(String userId, bool currentStatus) {
    final newStatus = !currentStatus;
    
    ref.read(adminControllerProvider.notifier)
        .updateUserEmailVerification(userId, newStatus);
  }
}
