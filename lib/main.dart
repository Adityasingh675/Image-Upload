import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Uploader',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Column(
        children: [
          (imageUrl != null)
              ? Image.network(imageUrl)
              : Placeholder(
                  fallbackHeight: 200.0,
                  fallbackWidth: double.infinity,
                ),
          SizedBox(height: 30.0),
          RaisedButton(
            color: Colors.deepOrange,
            child: Text('Upload'),
            onPressed: () {
              return uploadImage();
            },
          ),
        ],
      ),
    );
  }

  uploadImage () async{
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;

    // Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;
    if(permissionStatus.isGranted) {
      // Select Image
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image.path);
      
      if(image != null) {
        // Upload to firebase
        var snapshot = await _storage.ref().child('folderName/imageName').putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No image received');
      }
    } else {
      print('Grant Permission and try again');
    }
  }
}
