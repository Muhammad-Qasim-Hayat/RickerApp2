import 'package:flutter/material.dart';
import 'package:ricker_app/screens/image_screen.dart';
import 'package:ricker_app/utils/helper.dart';

class ThumbnailImage extends StatelessWidget {
  final String url;
  final Function(String) onDelete;

  const ThumbnailImage(this.url, {Key key, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink.image(
      image: NetworkImage(Helper.getUploadedFileThumbnailURL(url)),
      fit: BoxFit.cover,
      child: InkWell(
        onTap: () {
          var originalImageURL = Helper.getUploadedFileURL(url);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageScreen(
                originalImageURL,
                tag: originalImageURL,
                onDelete: onDelete,
              ),
            )
          );
        },
      ),
    );
  }
}
