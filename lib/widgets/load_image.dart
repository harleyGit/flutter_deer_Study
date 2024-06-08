import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deer/util/image_utils.dart';

/// 图片加载（支持本地与网络图片）
class LoadImage extends StatelessWidget {
  
  const LoadImage(this.image, {
    super.key,
    this.width, 
    this.height,
    this.fit = BoxFit.cover, 
    this.format = ImageFormat.png,
    this.holderImg = 'none',
    this.cacheWidth,
    this.cacheHeight,
  });
  
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageFormat format;
  final String holderImg;
  final int? cacheWidth;
  final int? cacheHeight;
  
  @override
  Widget build(BuildContext context) {

    if (image.isEmpty || image.startsWith('http')) {
      final Widget holder = LoadAssetImage(holderImg, height: height, width: width, fit: fit);
      return CachedNetworkImage(
        imageUrl: image,
        placeholder: (_, __) => holder,
        errorWidget: (_, __, dynamic error) => holder,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
      );
    } else {
      return LoadAssetImage(image,
        height: height,
        width: width,
        fit: fit,
        format: format,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }
  }
}

/// 加载本地资源图片
class LoadAssetImage extends StatelessWidget {
  
  const LoadAssetImage(this.image, {
    super.key,
    this.width,
    this.height, 
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.format = ImageFormat.png,
    this.color
  });

  final String image;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final ImageFormat format;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {

    return Image.asset(
      ImageUtils.getImgPath(image, format: format),
      height: height,
      width: width,
      //cacheWidth 和 cacheHeight： 这两个参数用于设置图片在缓存中的宽度和高度。
      //它们并不改变图片的实际显示大小，而是用于在加载图片时为缓存系统提供建议。这可以在某些情况下提高性能
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      //这是一个枚举类型的参数，表示图片在布局中的放置方式。可能的值包括 BoxFit.contain、BoxFit.cover 等，用于确定图片在给定的空间内如何适应。
      fit: fit,
      color: color,
      /// 忽略图片语义
      /// 这是一个布尔值，如果设置为 true，表示图片将被排除在语义树之外，即屏幕阅读器等辅助技术将忽略这个图片。这可以用于指定图片不应该提供语义信息，通常在一些纯展示性的图片上使用
      excludeFromSemantics: true,
    );
  }
}

/**
 * 
 * cacheWidth 参数在Flutter中的Image小部件中用于指定图像在内存中的缓存宽度。使用这个参数可以在一定程度上提高性能，特别是当显示的图像尺寸较大时。

当Image小部件加载图像时，Flutter会将图像解码为位图，并将其存储在内存中。如果图像尺寸很大，加载和处理大图可能会占用大量的内存。在这种情况下，使用cacheWidth参数可以告诉Flutter将图像缓存为指定宽度，而不是原始宽度。这样可以减少内存消耗，提高性能，特别是在显示图像的尺寸较小的情况下。

例如，如果原始图像宽度为1000像素，而cacheWidth被设置为500像素，那么Flutter会将图像缓存为500像素的宽度，从而减少内存占用。当图像在UI中显示时，Flutter会根据需要动态缩放图像以适应布局。
*/
