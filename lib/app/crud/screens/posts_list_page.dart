import 'package:crud/app/crud/screens/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../repo/post.dart';


class PostsListPage extends StatefulWidget {
  const PostsListPage({Key? key}) : super(key: key);

  @override
  State<PostsListPage> createState() => _PostsListPageState();
}

class _PostsListPageState extends State<PostsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PostsBloc>().add(LoadPosts());
        },
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildPostsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostsList() {
    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state is PostsInitial) {
          return const Center(
            child: Text('No posts loaded yet'),
          );
        }

        if (state is PostsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is PostsLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: state.posts[index]);
            },
          );
        }

        if (state is PostsError) {
          return _buildErrorView(state.message);
        }

        return Container();
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PostsBloc>().add(LoadPosts());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Filter by User ID',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final userId = int.tryParse(value) ?? 0;
          context.read<PostsBloc>().add(FilterPosts(userId));
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Post'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter post content';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newPost = Post(
                  id: 0,
                  userId: 1,
                  title: titleController.text.trim(),
                  body: bodyController.text.trim(),
                );
                context.read<PostsBloc>().add(CreatePost(newPost));
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post created successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}