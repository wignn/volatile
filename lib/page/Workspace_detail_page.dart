import 'package:flutter/material.dart';
import 'package:vasvault/models/workspace_model.dart';
import 'package:vasvault/models/workspace_file_model.dart';
import 'package:vasvault/services/workspace_service.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/workspace_member_model.dart';
import 'add_member_page.dart';
import 'manage_members_page.dart';
import 'package:vasvault/utils/session_meneger.dart';

class WorkspaceDetailPage extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailPage({super.key, required this.workspace});

  @override
  State<WorkspaceDetailPage> createState() => _WorkspaceDetailPageState();
}

class _WorkspaceDetailPageState extends State<WorkspaceDetailPage> {
  final WorkspaceService _service = WorkspaceService();
  final SessionManager _sessionManager = SessionManager();
  late Future<List<WorkspaceFile>> _filesFuture;
  String _currentUserRole = 'owner';

  @override
  void initState() {
    super.initState();
    _refreshFiles();
    _fetchCurrentUserRole();
  }

  void _refreshFiles() {
    setState(() {
      _filesFuture = _service.getWorkspaceFiles(widget.workspace.id);
    });
  }

  Future<void> _fetchCurrentUserRole() async {
    final currentUserId = await _sessionManager.getUserId();
    print('Current User ID: $currentUserId');
    if (currentUserId == null) return;

    try {
      final members = await _service.getWorkspaceMembers(widget.workspace.id);

      final userMember = members.firstWhere(
        (member) => member.id == currentUserId,

        orElse: () =>
            WorkspaceMember(id: currentUserId, email: '', role: 'viewer'),
      );

      if (mounted) {
        setState(() {
          _currentUserRole = userMember.role;
          debugPrint(
            'Peran pengguna saat ini di Workspace ID ${widget.workspace.id}: $_currentUserRole',
          );
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch role: $e");
    }
  }

  Future<void> _openFile(String url) async {
    final Uri uri = Uri.parse(url);
    debugPrint("Mencoba buka URL: $url"); 

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka file ini')),
        );
      }
    }
  }

  void _showDeleteDialog(int fileId, String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus File?'),
        content: Text('Yakin ingin menghapus "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _service.deleteFile(fileId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File berhasil dihapus')),
                  );
                  _refreshFiles();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus file'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document'))
      return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet'))
      return Icons.table_chart;
    if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('archive'))
      return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.workspace.name,
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),

        actions: [
          FutureBuilder(
            future: _filesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final canManageMembers =
                  _currentUserRole == 'owner' || _currentUserRole == 'admin';

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    tooltip: 'Tambah Anggota',
                    onPressed: canManageMembers
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddMemberPage(workspace: widget.workspace),
                              ),
                            );
                            print(result);

                            if (result == true) {
                              _refreshFiles();
                              _fetchCurrentUserRole();
                            }
                          }
                        : null,
                  ),
                  

                  if (canManageMembers)
                    IconButton(
                      icon: const Icon(Icons.group_outlined),
                      tooltip: 'Kelola Anggota',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageMembersPage(
                              workspaceId: widget.workspace.id,
                              currentUserRole: _currentUserRole,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<WorkspaceFile>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final files = snapshot.data ?? [];

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada file di sini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                elevation: 0,
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: file.isImage
                        ? Image.network(
                            file.thumbnailUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getFileIcon(file.mimeType),
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  title: Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${_formatSize(file.size)} • ${DateFormat('dd MMM').format(file.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () => _openFile(file.fullDownloadUrl),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () =>
                            _showDeleteDialog(file.id, file.fileName),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            File file = File(result.files.single.path!);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sedang mengupload...')),
            );
            debugPrint(
              'Mengupload file ke Workspace ID: ${widget.workspace.id}',
            );
            bool success = await _service.uploadFile(widget.workspace.id, file);
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil upload!'),
                  backgroundColor: Colors.green,
                ),
              );
              _refreshFiles();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gagal upload file'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text("Upload File", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
