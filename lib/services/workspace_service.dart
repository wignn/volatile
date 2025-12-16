import 'dart:io';
import 'package:dio/dio.dart';
import '../models/workspace_member_model.dart';
import '../models/workspace_model.dart';
import 'package:vasvault/models/workspace_file_model.dart';
import 'package:vasvault/services/dio_client.dart';

class WorkspaceService {
  final Dio _dio = DioClient().dio;

  Future<List<Workspace>> getWorkspaces({String query = ''}) async {
    try {
      final response = await _dio.get(
        '/workspaces',
        queryParameters: query.isNotEmpty ? {'search': query} : null,
      );

      final List result = response.data['data'] ?? [];
      return result.map((e) => Workspace.fromJson(e)).toList();
    } on DioException {
      return [];
    }
  }

  Future<bool> createWorkspace(String name, String description) async {
    try {
      await _dio.post(
        '/workspaces',
        data: {'name': name, 'description': description},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Workspace?> getWorkspaceDetail(int id) async {
    try {
      final response = await _dio.get('/workspaces/$id');
      return Workspace.fromJson(response.data['data']);
    } on DioException {
      return null;
    }
  }

  Future<List<WorkspaceFile>> getWorkspaceFiles(int workspaceId) async {
    try {
      final response = await _dio.get('/workspaces/$workspaceId/files');

      if (response.data['data'] != null) {
        final List result = response.data['data'];
        return result.map((e) => WorkspaceFile.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateWorkspace(int id, String name, String description) async {
    try {
      await _dio.put(
        '/workspaces/$id',
        data: {'name': name, 'description': description},
      );
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteWorkspace(int id) async {
    try {
      await _dio.delete('/workspaces/$id');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> uploadFile(int workspaceId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      if (fileName.contains('\\')) {
        fileName = file.path.split('\\').last;
      }

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'workspace_id': workspaceId,
      });

      await _dio.post(
        '/files',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteFile(int fileId) async {
    try {
      await _dio.delete('/files/$fileId');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> renameFile(int fileId, String newName) async {
    try {
      await _dio.put('/files/$fileId', data: {'new_name': newName});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addMember(int workspaceId, String email) async {
    try {
      await _dio.post(
        '/workspaces/$workspaceId/members',
        data: {'email': email, 'role': 'viewer'},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<WorkspaceMember>> getWorkspaceMembers(int workspaceId) async {
    try {
      final response = await _dio.get('/workspaces/$workspaceId');

      final List members = response.data['data']['members'] ?? [];
      return members.map((e) => WorkspaceMember.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateMemberRole(
    int workspaceId,
    int userId,
    String newRole,
  ) async {
    try {
      await _dio.put(
        '/workspaces/$workspaceId/members/$userId',
        data: {'role': newRole},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeMember(int workspaceId, int userId) async {
    try {
      await _dio.delete('/workspaces/$workspaceId/members/$userId');
      return true;
    } on DioException {
      return false;
    }
  }
}
