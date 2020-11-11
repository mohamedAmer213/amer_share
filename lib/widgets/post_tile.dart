import 'package:amer_share/pages/post_screen.dart';
import 'package:amer_share/widgets/post.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleShowingCompletePost(context,
          postId: post.postId, userId: post.ownerId),
      child: CustomCachedNetworkImage(post.photoUrl),
    );
  }

  handleShowingCompletePost(BuildContext context,
      {String postId, String userId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PostScreen(
            userId: userId,
            postId: postId,
          );
        },
      ),
    );
  }
}
