import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/networking/network_util.dart';
import '../repo/post.dart';
import '../repo/posts_api_service.dart';


// Events
abstract class PostsEvent {}

class LoadPosts extends PostsEvent {}

class CreatePost extends PostsEvent {
  final Post post;
  CreatePost(this.post);
}

class UpdatePost extends PostsEvent {
  final Post post;
  UpdatePost(this.post);
}

class DeletePost extends PostsEvent {
  final int id;
  DeletePost(this.id);
}

class FilterPosts extends PostsEvent {
  final int userId;
  FilterPosts(this.userId);
}

// States
abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

class PostsError extends PostsState {
  final String message;
  PostsError(this.message);
}

// BLoC
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsApiService _apiService;
  List<Post> _allPosts = [];
  // Add this to track locally created posts
  final Map<int, Post> _localPosts = {};
  int _localPostId = 1000; // Start with a high number to avoid conflicts

  PostsBloc(this._apiService) : super(PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<FilterPosts>(_onFilterPosts);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      final hasNetwork = await NetworkUtil.hasNetwork();
      if (!hasNetwork) {
        emit(PostsError('No internet connection. Please check your network settings.'));
        return;
      }

      _allPosts = await _apiService.getPosts();
      emit(PostsLoaded(_allPosts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      final response = await _apiService.createPost(event.post);
      // Store the created post locally with a unique ID
      final localPost = Post(
        id: _localPostId++,
        userId: response.userId,
        title: response.title,
        body: response.body,
      );
      _localPosts[localPost.id] = localPost;
      _allPosts = [localPost, ..._allPosts];
      emit(PostsLoaded(_allPosts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      // Check if it's a local post
      if (_localPosts.containsKey(event.post.id)) {
        _localPosts[event.post.id] = event.post;
        _allPosts = _allPosts.map((post) {
          return post.id == event.post.id ? event.post : post;
        }).toList();
        emit(PostsLoaded(_allPosts));
      } else {
        // It's a server post
        final updatedPost = await _apiService.updatePost(event.post);
        _allPosts = _allPosts.map((post) {
          return post.id == updatedPost.id ? updatedPost : post;
        }).toList();
        emit(PostsLoaded(_allPosts));
      }
    } catch (e) {
      emit(PostsError('Failed to update post. Please try again.'));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      // Check if it's a local post
      if (_localPosts.containsKey(event.id)) {
        _localPosts.remove(event.id);
        _allPosts = _allPosts.where((post) => post.id != event.id).toList();
        emit(PostsLoaded(_allPosts));
      } else {
        // It's a server post
        await _apiService.deletePost(event.id);
        _allPosts = _allPosts.where((post) => post.id != event.id).toList();
        emit(PostsLoaded(_allPosts));
      }
    } catch (e) {
      emit(PostsError('Failed to delete post. Please try again.'));
    }
  }

  Future<void> _onFilterPosts(FilterPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      if (event.userId == 0) {
        emit(PostsLoaded(_allPosts));
      } else {
        final filteredPosts = _allPosts
            .where((post) => post.userId == event.userId)
            .toList();
        emit(PostsLoaded(filteredPosts));
      }
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  // Helper method to check if a post is local
  bool isLocalPost(int id) => _localPosts.containsKey(id);
}