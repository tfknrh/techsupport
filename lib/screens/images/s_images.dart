import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:typed_data';
import 'package:techsupport/api.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/screens.dart';
import 'package:techsupport/models.dart';
import 'package:provider/provider.dart';

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  Images images;
//  List<Images> imageList;
  bool result;
  int count = 0;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Provider.of<ImagesProvider>(context, listen: false).getListImagess();
    // getImageList();

    // List<String> gps = widget.customer.customerGps.split("|");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagesProvider>(builder: (context, value, child) {
      return Scaffold(
          appBar: AppBar(
            brightness: Theme.of(context).brightness,
            backgroundColor: MColors.backgroundColor(context),
            elevation: 2,
            title: Text(
              "Daftar Images",
              style: CText.primarycustomText(2.5, context, "CircularStdBook"),
            ),
            actions: <Widget>[
              IconButton(
                  onPressed: () async {
                    if (mounted) setState(() {});
                    showSearch(
                      context: context,
                      delegate: SearchPage<Images>(
                        onQueryUpdate: (s) => print(s),
                        items: value.images,
                        searchLabel: 'Cari image',
                        suggestion: Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Text('Tidak ditemukan aktivitas :(',
                                  style: CText.primarycustomText(
                                      1.8, context, 'CircularStdBook')),
                              SizedBox(height: 20),
                              Image.asset(
                                'assets/images/not_found.png',
                              ),
                            ])),
                        failure: Center(
                          child: Text('tidak ditemukan image :('),
                        ),
                        filter: (img) => [img.imgName],
                        builder: (img) {
                          return Column(children: [
                            ExtendedImage.file(
                              File(img.imgImage),
                              fit: BoxFit.fitHeight,
                            ),
                            SizedBox(height: 5),
                            Text(img.imgName,
                                style: CText.primarycustomText(
                                    1.6, context, 'CircularStdBook')),
                            SizedBox(height: 20),
                          ]);
                        },
                      ),
                    );
                  },
                  icon: Icon(
                    AntDesign.search1,
                    color: MColors.buttonColor(),
                  )),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                value.getListImagess();
              },
              child: GridView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: value.images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1),
                itemBuilder: (context, index) {
                  if (value.images.isEmpty) {
                    return CircularProgressIndicator();
                  } else {
                    return GestureDetector(
                      onLongPress: () async {},
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDetail(
                              //   image: value.images[index].imgImage,
                              //   name: value.images[index].imgName,
                              images: value.images[index],
                            ),
                          )),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Stack(children: [
                            ExtendedImage.file(
                              File(value.images[index].imgImage),
                              fit: BoxFit.fitHeight,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                verticalDirection: VerticalDirection.up,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    color:
                                        MColors.buttonColor().withOpacity(.3),
                                    child: Text(
                                      value.images[index].imgName,
                                      style: CText.primarycustomText(
                                          1.4, context, 'CircularStdBook'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ]
                              //Utility.imageFromBase64String(imageList[index].imgImage),
                              ),
                        ),
                        //  Image.file(File(imageList[index].imgImage),
                        //   fit: BoxFit.cover,
                        //  ),
                        //  ),
                      ),
                    );
                  }
                },
              ),
            ),
          )
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () async {
          //     result = await Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => AddImage(),
          //         ));

          //     if (result == true) {
          //       Navigator.pushReplacement(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => ImageList(),
          //           ));
          //     }
          //   },
          //   child: Icon(Icons.add),
          // ),
          );
    });
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: Provider.of<ImagesProvider>(context, listen: false)
            .images
            .map((photo) {
          return Utility.imageFromBase64String(photo.imgImage);
        }).toList(),
      ),
    );
  }

  // void _delete(BuildContext context, Images image) async {
  //   AlertDialog alertDialog = AlertDialog(
  //     title: Text("Hapus Image"),
  //     content: Text("Yakin akan akan menghapus image ini?"),
  //     actions: [
  //       ElevatedButton(
  //         child: Text("Iya"),
  //         onPressed: () async {
  //           int result = await DataBaseMain.deleteImages(image);
  //           if (result != 0) {
  //             _showSnackBar(context, 'Hapus image berhasil');
  //             getImageList();
  //           }
  //           Navigator.pop(context, true);
  //         },
  //       ),
  //       ElevatedButton(
  //         child: Text("Tidak"),
  //         onPressed: () {
  //           Navigator.pop(context, false);
  //         },
  //       ),
  //     ],
  //   );
  //   showDialog(context: context, builder: (_) => alertDialog);
  // }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  // void getImageList() async {
  //   imageList = await DataBaseMain.getListImages();
  //   setState(() {});

  // } on Exception catch (e) {
  //   _showSnackBar(context, e.toString());
  // }
  //}

  BuildContext myScaContext;
  void _delete(BuildContext context, Images image) async {
    AlertDialog alertDialog = AlertDialog(
      title: Text("Hapus Image"),
      content: Text("Yakin akan akan menghapus image ini?"),
      actions: [
        ElevatedButton(
          child: Text("Iya"),
          onPressed: () async {
            final x = await Provider.of<ImagesProvider>(context, listen: false)
                .deleteImages(image);

            if (x.identifier == "success") {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        ElevatedButton(
          child: Text("Tidak"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
