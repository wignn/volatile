import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workspace_member_model.dart';
import '../models/workspace_model.dart';
import '../constants/app_constant.dart';
import '../utils/session_meneger.dart';
import 'package:flutter/material.dart';
import 'package:vasvault/models/workspace_file_model.dart';

class WorkspaceService {
  final String baseUrl = '${AppConstants.baseUrl}/api/v1';

  final Dio _dio = Dio();

  WorkspaceService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Workspace>> getWorkspaces({String query = ''}) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

    print("TOKEN SAYA: $token");

    try {
      final response = await _dio.get(
        '$baseUrl/workspaces',
        queryParameters: query.isNotEmpty ? {'search': query} : null,

        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );

      final List result = response.data['data'] ?? [];

      return result.map((e) => Workspace.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    }
  }

  Future<bool> createWorkspace(String name, String description) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    if (token == null) {
      debugPrint('Gagal buat workspace: Token null');
      return false;
    }

    try {
      await _dio.post(
        '/workspaces',
        data: {'name': name, 'description': description},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Gagal buat workspace: $e');
      return false;
    }
  }

  Future<Workspace> getWorkspaceDetail(int id) async {
    try {
      final response = await _dio.get('/workspaces/$id');
      return Workspace.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<WorkspaceFile>> getWorkspaceFiles(int workspaceId) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    try {
      final response = await _dio.get(
        '/workspaces/$workspaceId/files',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );

      if (response.data['data'] != null) {
        final List result = response.data['data'];
        debugPrint('DATA SERVER: $result');
        return result.map((e) => WorkspaceFile.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Gagal ambil file workspace: $e');
      return [];
    }
  }

  Future<void> updateWorkspace(int id, String name, String description) async {
    try {
      await _dio.put(
        '/workspaces/$id',
        data: {'name': name, 'description': description},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteWorkspace(int id) async {
    try {
      await _dio.delete('/workspaces/$id');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> uploadFile(int workspaceId, File file) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    if (token == null) return false;

    try {
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'workspace_id': workspaceId,
      });

      await _dio.post(
        '/files',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return true;
    } on DioException catch (e) {
      debugPrint('--- ERROR UPLOAD ---');
      debugPrint('URL: ${e.requestOptions.path}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Error upload: $e');
      return false;
    }
  }

  Future<bool> deleteFile(int fileId) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    try {
      await _dio.delete(
        '/files/$fileId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Gagal hapus file: $e');
      return false;
    }
  }

  Future<bool> addMember(int workspaceId, String email) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    if (token == null) return false;

    try {
      await _dio.post(
        '/workspaces/$workspaceId/members',
        data: {'email': email, 'role': 'viewer'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Error add member: ${e.response?.data}');

      return false;
    } catch (e) {
      debugPrint('Error add member: $e');
      return false;
    }
  }

  Future<List<WorkspaceMember>> getWorkspaceMembers(int workspaceId) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    if (token == null) return [];

    try {
      final response = await _dio.get(
        '/workspaces/$workspaceId/members',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );

      final List result = response.data['data'] ?? [];

      return result.map((e) => WorkspaceMember.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Gagal ambil list member: $e');
      return [];
    }
  }

  Future<bool> updateMemberRole(
    int workspaceId,
    int userId,
    String newRole,
  ) async {
    final session = SessionManager();
    final String? token = await session.getAccessToken();

    if (token == null) return false;

    try {
      await _dio.put(
        '/workspaces/$workspaceId/members/$userId',
        data: {'role': newRole},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.tokenKey,
          },
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Gagal update role: $e');
      return false;
    }
  }

  Future<void> removeMember(int workspaceId, int userId) async {
    try {
      await _dio.delete('/workspaces/$workspaceId/members/$userId');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['error'] ?? 'Terjadi kesalahan pada server';
    } else {
      return 'Koneksi bermasalah: ${e.message}';
    }
  }
}
