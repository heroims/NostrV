import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatelessWidget{
  final ImageProvider imageProvider;

  const PhotoPage({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              context.pop();
            },
          ),
      ),
      body: PhotoView(
        imageProvider: imageProvider,
      ),
    );
  }

}