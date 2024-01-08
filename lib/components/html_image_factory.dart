import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class PopupPhotoViewWidgetFactory extends WidgetFactory {

  @override
  Widget buildImageWidget(BuildTree meta, ImageSource src) {

    // return CachedNetworkImage( imageUrl: src.url,);
    final built = super.buildImageWidget(meta, src);

    if (built is Image) {
      final url = src.url;
      return Builder(
        builder: (context) => GestureDetector(
          onTap: (){

          },
          child: Hero(tag: url, child: built),
        ),
      );
    }
    if (built is CachedNetworkImage) {
      final url = src.url;
      return Builder(
        builder: (context) => CachedNetworkImage(
            cacheManager: cacheManager,
            imageBuilder: (context, imageProvider) {
              return GestureDetector(
                onTap: (){
                  context.pushNamed(Routers.photoView.value,extra: imageProvider);
                },
                child: Image(image: imageProvider, fit: BoxFit.fill,),
              );
            },
            errorWidget: (context, _, error) =>
            onErrorBuilder(context, meta, error, src) ?? widget0,
            fit: BoxFit.fill,
            imageUrl: url,
            progressIndicatorBuilder: (context, _, progress) {
              final t = progress.totalSize;
              final v = t != null && t > 0 ? progress.downloaded / t : null;
              return onLoadingBuilder(context, meta, v, src) ?? widget0;
            }
        ),
      );
    }
    return built ?? const SizedBox.shrink();
  }
}