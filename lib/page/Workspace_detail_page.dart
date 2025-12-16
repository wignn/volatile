import 'package:flutter/material.dart';
import 'package:vasvault/models/workspace_model.dart';
import 'package:vasvault/models/workspace_file_model.dart';
import 'package:vasvault/services/workspace_service.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:vasvault/constants/app_constant.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/workspace_member_model.dart';
import 'add_member_page.dart';
import 'manage_members_page.dart';
import 'package:vasvault/utils/session_meneger.dart';
import 'package:vasvault/page/FileViewer.dart';

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
  String _currentUserRole = 'viewer';

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
    if (currentUserId == null) {
      return;
    }

    try {
      final workspaceDetail = await _service.getWorkspaceDetail(
        widget.workspace.id,
      );

      if (workspaceDetail == null) {
        return;
      }

      final members = workspaceDetail.members;

      final userMember = members.firstWhere(
        (member) => member.id == currentUserId,
        orElse: () {
          return WorkspaceMember(id: currentUserId, email: '', role: 'viewer');
        },
      );

      if (mounted) {
        setState(() {
          _currentUserRole = userMember.role;
        });
      }
    } catch (_) {
      // Handle silently
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

  Future<void> _downloadFile(WorkspaceFile file) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mengunduh file...')));

    try {
      final token = await _sessionManager.getAccessToken();
      final request = http.Request('GET', Uri.parse(file.fileUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-api-key'] = AppConstants.tokenKey;

      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${file.fileName}';
        final localFile = File(filePath);

        final List<int> bytes = [];
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
        }
        await localFile.writeAsBytes(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File disimpan: ${file.fileName}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Buka',
                textColor: Colors.white,
                onPressed: () => OpenFilex.open(filePath),
              ),
            ),
          );
        }
      } else {
        throw Exception('Download gagal: ${response.statusCode}');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengunduh file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRenameDialog(WorkspaceFile file) {
    final controller = TextEditingController(text: file.fileName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nama File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama File',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.fileName) {
                final success = await _service.renameFile(file.id, newName);
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama file berhasil diubah'),
                      ),
                    );
                    _refreshFiles();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal mengubah nama file'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
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
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    }
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart;
    }
    if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('archive')) {
      return Icons.folder_zip;
    }
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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final isAdminOrOwner =
                  _currentUserRole == 'owner' || _currentUserRole == 'admin';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FileViewerPage(file: file.toLatestFile()),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail area
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: file.isImage
                              ? Image.network(
                                  file.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                )
                              : Center(
                                  child: Icon(
                                    _getFileIcon(file.mimeType),
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                      // File info area
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.fileName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatSize(file.size),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 3-dot menu
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                switch (value) {
                                  case 'download':
                                    _downloadFile(file);
                                    break;
                                  case 'rename':
                                    _showRenameDialog(file);
                                    break;
                                  case 'delete':
                                    _showDeleteDialog(file.id, file.fileName);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'download',
                                  child: Row(
                                    children: [
                                      Icon(Icons.download, size: 20),
                                      SizedBox(width: 12),
                                      Text('Download'),
                                    ],
                                  ),
                                ),
                                if (isAdminOrOwner) ...[
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 12),
                                        Text('Edit Nama'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          (_currentUserRole == 'owner' || _currentUserRole == 'admin')
          ? FloatingActionButton.extended(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform
                    .pickFiles();
                if (result != null) {
                  File file = File(result.files.single.path!);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sedang mengupload...')),
                  );
                  bool success = await _service.uploadFile(
                    widget.workspace.id,
                    file,
                  );
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
              label: const Text(
                "Upload File",
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
