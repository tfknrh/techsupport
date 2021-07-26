import 'dart:io';

import 'package:flutter/material.dart';

//import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:extended_image/extended_image.dart';
import 'package:share/share.dart';

class ImageDetail extends StatefulWidget {
  final String image;
  final String name;

  const ImageDetail({Key key, this.image, this.name}) : super(key: key);
  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
//class ImageDetail extends StatelessWidget {

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child:
                  //  ExtendedImage.memory(
                  //   Utility.dataFromBase64String(image),
                  ExtendedImage.file(
                File(widget.image),
                fit: BoxFit.contain,
                //enableLoadState: false,
                mode: ExtendedImageMode.gesture,
                extendedImageEditorKey: editorKey,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 3.0,
                    animationMaxScale: 3.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                    initialAlignment: InitialAlignment.center,
                  );
                },
              ),
            ),
            // PinchZoom(
            //     image: Utility.imageFromBase64String(image),
            //     zoomedBackgroundColor: Colors.white)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:
                    // Text(
                    //   name,
                    //   style: TextStyle(color: Colors.white, fontSize: 30),
                    // ),
                    Row(children: [
                  IconButton(
                      onPressed: () {
                        editorKey.currentState.rotate(right: false);
                      },
                      icon: Icon(Icons.rotate_left)),
                  IconButton(
                      onPressed: () {
                        editorKey.currentState.rotate(right: true);
                      },
                      icon: Icon(Icons.rotate_right)),
                  IconButton(
                      onPressed: () {
                        editorKey.currentState.reset();
                      },
                      icon: Icon(Icons.restore)),
                  IconButton(
                      onPressed: () {
                        _onShare(context);
                      },
                      icon: Icon(Icons.share)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (File(widget.image) != null) {
      await Share.shareFiles([widget.image],
          text: widget.name,
          subject: widget.name,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(widget.name,
          subject: widget.name,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
}
