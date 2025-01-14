import 'package:crud/app/crud/repo/post.dart';
import 'package:dio/dio.dart';


class PostsApiService {
  final Dio _dio;

  PostsApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('/posts');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      return (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network settings.');
      } else {
        throw Exception('Failed to fetch posts: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<Post> createPost(Post post) async {
    try {
      final response = await _dio.post(
        '/posts',
        data: post.toJson(),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create post');
      }

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create post: ${e.message}');
    }
  }

  Future<Post> updatePost(Post post) async {
    try {
      final response = await _dio.put(
        '/posts/${post.id}',
        data: post.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update post');
      }

      return post;
    } on DioException catch (e) {
      throw Exception('Failed to update post: ${e.message}');
    }
  }

  Future<void> deletePost(int id) async {
    try {
      final response = await _dio.delete('/posts/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete post: ${e.message}');
    }
  }
}