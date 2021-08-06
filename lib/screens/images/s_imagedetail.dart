import 'dart:io';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:share/share.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/api.dart';
import 'package:techsupport/models.dart';
import 'package:techsupport/controllers.dart';
import 'package:provider/provider.dart';

class ImageDetail extends StatefulWidget {
//  final String image;
  // final String name;
  final Images images;

  const ImageDetail({Key key, this.images}) : super(key: key);
  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
//class ImageDetail extends StatelessWidget {

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  ExtendedImageMode mode = ExtendedImageMode.gesture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: MColors.backgroundColor(context),
        elevation: 2,
        title: Text(
          "Images",
          style: CText.primarycustomText(2.5, context, "CircularStdBook"),
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
                File(widget.images.imgImage),
                fit: BoxFit.contain,
                //enableLoadState: false,
                mode: mode,
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
            Positioned(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              child: Card(
                color: MColors.cardColor(context),
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(widget.images.imgName),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: MColors.backgroundColor(context),
                padding: const EdgeInsets.all(20),
                child:
                    // Text(
                    //   name,
                    //   style: TextStyle(color: Colors.white, fontSize: 30),
                    // ),
                    Row(children: [
                  // IconButton(
                  //     onPressed: () {
                  //       mode = ExtendedImageMode.editor;
                  //       editorKey.currentState.rotate(right: false);
                  //     },
                  //     icon: Icon(Icons.rotate_left)),
                  // IconButton(
                  //     onPressed: () {
                  //       mode = ExtendedImageMode.editor;
                  //       editorKey.currentState.rotate(right: true);
                  //     },
                  //     icon: Icon(Icons.rotate_right)),
                  // IconButton(
                  //     onPressed: () {
                  //       mode = ExtendedImageMode.editor;
                  //       editorKey.currentState.reset();
                  //       mode = ExtendedImageMode.gesture;
                  //     },
                  //     icon: Icon(Icons.restore)),
                  IconButton(
                      onPressed: () {
                        _onShare(context);
                      },
                      icon: Icon(AntDesign.sharealt,
                          color: MColors.buttonColor())),
                  IconButton(
                    onPressed: () async {
                      final x = await Provider.of<ImagesProvider>(context,
                              listen: false)
                          .deleteImages(widget.images);
                      if (x.identifier == "success") {
                        Navigator.pop(context);
                      } else {
                        SnackBars.showErrorSnackBar(myScaContext, context,
                            Icons.error, "Images", x.message);
                      }
                    },
                    icon: Icon(AntDesign.delete, color: MColors.buttonColor()),
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BuildContext myScaContext;
  _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (File(widget.images.imgImage) != null) {
      await Share.shareFiles([widget.images.imgImage],
          text: "",
          subject: widget.images.imgName,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share("",
          subject: "",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
}
