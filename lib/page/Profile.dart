import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/profile_bloc.dart';
import 'package:vasvault/models/profile_response.dart';
import 'package:vasvault/routes.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:vasvault/utils/session_meneger.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _updateControllers(state.profile);
            } else if (state is ProfileUpdated) {
              _updateControllers(state.profile);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError && state.profile == null) {
              return _buildErrorState(context, state.message, isDark);
            }

            final profile = _getProfileFromState(state);
            final isEditing =
                state is ProfileEditing || state is ProfileUpdating;
            final isUpdating = state is ProfileUpdating;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(LoadProfile());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture Section
                    _buildProfilePicture(profile, isDark),
                    const SizedBox(height: 24),

                    // Profile Info
                    _buildProfileInfoCard(profile, isDark, context),
                    const SizedBox(height: 24),

                    // Edit/Save/Cancel Buttons
                    if (!isEditing && profile != null)
                      _buildEditButton(context),

                    if (isEditing) _buildEditModeButtons(context, isUpdating),

                    const SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton(context, isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfilePicture(ProfileResponse? profile, bool isDark) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: profile?.profilePicture != null
              ? NetworkImage(profile!.profilePicture!)
              : null,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.grey[200],
          child: profile?.profilePicture == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(
    ProfileResponse? profile,
    bool isDark,
    BuildContext context,
  ) {
    final isEditing = _isEditingState(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            label: 'Username',
            value: profile?.username ?? '',
            controller: _usernameController,
            isEditing: isEditing,
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            label: 'Email',
            value: profile?.email ?? '',
            controller: _emailController,
            isEditing: isEditing,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),

          if (profile?.createdAt != null)
            _buildInfoRow(
              label: 'Member Since',
              value: DateFormat('dd MMMM yyyy').format(profile!.createdAt!),
              controller: null,
              isEditing: false,
              icon: Icons.calendar_today,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required TextEditingController? controller,
    required bool isEditing,
    required IconData icon,
  }) {
    if (controller != null && value.isNotEmpty) {
      controller.text = value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        isEditing && controller != null
            ? TextField(
                controller: controller,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ProfileBloc>().add(StartEditingProfile());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditModeButtons(BuildContext context, bool isUpdating) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: ElevatedButton(
            onPressed: isUpdating
                ? null
                : () {
                    context.read<ProfileBloc>().add(CancelEditingProfile());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Save Button
        Expanded(
          child: ElevatedButton(
            onPressed: isUpdating
                ? null
                : () {
                    context.read<ProfileBloc>().add(
                      UpdateProfileEvent(
                        username: _usernameController.text,
                        email: _emailController.text,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    final sessionManager = SessionManager();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('LogoutButton'),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            await sessionManager.removeAccessToken();
            if (context.mounted) {
              Future.microtask(() {
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyRoute.login.name,
                  (route) => false,
                );
              });
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.red[900] : Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    final sessionManager = SessionManager();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(LoadProfile());
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await sessionManager.removeAccessToken();
              if (context.mounted) {
                Future.microtask(() {
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MyRoute.login.name,
                    (route) => false,
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateControllers(ProfileResponse profile) {
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
  }

  ProfileResponse? _getProfileFromState(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileEditing) return state.profile;
    if (state is ProfileUpdating) return state.profile;
    if (state is ProfileUpdated) return state.profile;
    if (state is ProfileError) return state.profile;
    return null;
  }

  bool _isEditingState(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    return state is ProfileEditing || state is ProfileUpdating;
  }
}
