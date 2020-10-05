import 'package:flutter/material.dart';

import 'package:path/path.dart';

class ImageScreen extends StatelessWidget {
  final String src;
  final String tag;
  final void Function(String) onDelete;

  ImageScreen(this.src, {Key key, this.tag, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Image Screen');
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Colors.black,
        actions: <Widget>[
          onDelete != null
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Tem certeza que deseja excluir esta imagem?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          textColor: Colors.grey,
                          child: Text('CANCELAR'),
                        ),
                        FlatButton(
                          onPressed: () {
                            onDelete(basename(src));
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          textColor: Colors.red,
                          child: Text('EXCLUIR'),
                        )
                      ],
                    )
                  );
                },
              )
            : const SizedBox(),
        ],
      ),
      backgroundColor: Colors.black,
      body: Hero(
        tag: tag,
        child: InteractiveViewer(
          minScale: 0.3,
          maxScale: 2.0,
          // default factor is 1.0, use 0.0 to disable boundary
          child: Container(
            child: Image(
              image: NetworkImage(src),
              // This is the default placeholder widget at loading status,
              // you can write your own widget with CustomPainter.
              // This is default duration
            ),
          ),
        ),
      ),
    );
  }
}
