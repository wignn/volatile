import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/vault_bloc.dart';
import 'package:vasvault/bloc/vault_event.dart';
import 'package:vasvault/bloc/vault_state.dart';
import 'package:vasvault/models/file_item.dart';

class Vault extends StatefulWidget {
  const Vault({super.key});

  @override
  State<Vault> createState() => _VaultState();
}

class _VaultState extends State<Vault> {
  @override
  void initState() {
    super.initState();
    context.read<VaultBloc>().add(LoadVaultFiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VaultBloc>().add(RefreshVaultFiles());
            },
          ),
        ],
      ),
      body: BlocBuilder<VaultBloc, VaultState>(
        builder: (context, state) {
          if (state is VaultLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VaultError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VaultBloc>().add(LoadVaultFiles());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is VaultLoaded) {
            if (state.files.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No files uploaded yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your first file to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<VaultBloc>().add(RefreshVaultFiles());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.files.length,
                itemBuilder: (context, index) {
                  final file = state.files[index];
                  return _buildFileCard(file);
                },
              ),
            );
          }
          return const Center(child: Text('Welcome to your Vault'));
        },
      ),
    );
  }

  Widget _buildFileCard(FileItem file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Implement file preview/download
          _showFileOptions(file);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getFileColor(file.mimeType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(file.mimeType),
                  color: _getFileColor(file.mimeType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file.formattedSize} • ${_formatDate(file.createdAt)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType.startsWith('video/')) {
      return Icons.video_file;
    } else if (mimeType.startsWith('audio/')) {
      return Icons.audio_file;
    } else if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('document') ||
        mimeType.contains('word') ||
        mimeType.contains('text')) {
      return Icons.description;
    } else if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Icons.table_chart;
    } else if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('compressed')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return Colors.blue;
    } else if (mimeType.startsWith('video/')) {
      return Colors.purple;
    } else if (mimeType.startsWith('audio/')) {
      return Colors.orange;
    } else if (mimeType.contains('pdf')) {
      return Colors.red;
    } else if (mimeType.contains('document') ||
        mimeType.contains('word') ||
        mimeType.contains('text')) {
      return Colors.indigo;
    } else if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Colors.green;
    } else if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('compressed')) {
      return Colors.amber;
    }
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFileOptions(FileItem file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      file.formattedSize,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement download
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download feature coming soon'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showFileDetails(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(file);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showFileDetails(FileItem file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('File Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Name', file.fileName),
              _detailRow('Size', file.formattedSize),
              _detailRow('Type', file.mimeType),
              _detailRow('Uploaded', _formatFullDate(file.createdAt)),
              if (file.updatedAt != null)
                _detailRow('Modified', _formatFullDate(file.updatedAt!)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(FileItem file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: Text('Are you sure you want to delete "${file.fileName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement delete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete feature coming soon')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
